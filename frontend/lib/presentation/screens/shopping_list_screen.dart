import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/smart_list_warmup_banner.dart';
import '../../core/services/notification_service.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() =>
      _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  static const _allCategories = [
    'Todos',
    'Alimentos',
    'Bebidas',
    'Limpeza',
    'Higiene',
  ];

  final List<String> _marketCategories = [
    'Alimentos',
    'Bebidas',
    'Limpeza',
    'Higiene'
  ];

  String _selectedCategory = 'Todos';
  final Set<String> _dismissed = {};

  @override
  Widget build(BuildContext context) {
    ref.listen(suggestionsProvider(_marketCategories), (previous, next) {
      if (next.hasValue && next.value != null) {
        final criticalItems =
            next.value!.where((s) => s.status == 'Crítico').toList();
        if (criticalItems.isNotEmpty) {
          NotificationService().showCriticalAlert(
            id: 100,
            title: 'Reposição Necessária',
            body: criticalItems.length == 1
                ? 'Sugerimos comprar ${criticalItems.first.productName} em breve.'
                : 'Você tem ${criticalItems.length} itens essenciais acabando. Confira sua lista!',
          );
        }
      }
    });

    final suggestionsAsync = ref.watch(suggestionsProvider(_marketCategories));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Inteligente',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded,
                color: AppTheme.primaryAction),
            onPressed: () {
              setState(() => _dismissed.clear());
              ref.invalidate(suggestionsProvider);
            },
            tooltip: 'Atualizar sugestões',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Warm-up banner (auto-hides at 5+ receipts) ──
          const SmartListWarmupBanner(),

          // ── Category filter chips ──
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _allCategories[i];
                final selected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  selectedColor: AppTheme.primaryAction,
                  checkmarkColor: AppTheme.darkBackground,
                  labelStyle: TextStyle(
                    color: selected
                        ? AppTheme.darkBackground
                        : AppTheme.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  backgroundColor: AppTheme.cardColor,
                  side: BorderSide(
                    color: selected
                        ? AppTheme.primaryAction
                        : Colors.white12,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Suggestions list ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                setState(() => _dismissed.clear());
                return ref
                    .refresh(suggestionsProvider(_marketCategories).future);
              },
              color: AppTheme.primaryAction,
              backgroundColor: AppTheme.cardColor,
              child: suggestionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryAction),
                ),
                error: (err, _) => _ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(suggestionsProvider),
                ),
                data: (suggestions) {
                  final visible = suggestions
                      .where((s) => !_dismissed.contains(s.productName))
                      .where((s) {
                        if (_selectedCategory == 'Todos') return true;
                        final cat = s.category;
                        // "Alimentos" cobre todas as subcategorias "Alimentos/X"
                        return cat == _selectedCategory ||
                            cat.startsWith('$_selectedCategory/');
                      })
                      .toList();

                  if (visible.isEmpty) {
                    return _EmptySuggestions();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final s = visible[index];
                      return _DismissibleSuggestion(
                        key: ValueKey(s.productName),
                        suggestion: s,
                        onIgnore: () =>
                            setState(() => _dismissed.add(s.productName)),
                        onBought: () {
                          setState(() => _dismissed.add(s.productName));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${s.productName} marcado como comprado!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dismissible suggestion item ───────────────────────────────────────────────

class _DismissibleSuggestion extends StatelessWidget {
  final dynamic suggestion;
  final VoidCallback onIgnore;
  final VoidCallback onBought;

  const _DismissibleSuggestion({
    super.key,
    required this.suggestion,
    required this.onIgnore,
    required this.onBought,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      // Swipe right = Comprei
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent),
            SizedBox(width: 6),
            Text('Comprei',
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      // Swipe left = Ignorar
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ignorar',
                style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w600)),
            SizedBox(width: 6),
            Icon(Icons.remove_circle_outline_rounded,
                color: Colors.orangeAccent),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onBought();
        } else {
          onIgnore();
        }
      },
      child: SuggestionCard(
        productName: suggestion.productName,
        category: suggestion.category,
        status: suggestion.status,
        lastPurchase: suggestion.lastPurchaseDate,
        daysSinceLast: suggestion.daysSinceLast,
        predictedNext: suggestion.predictedNextDate,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptySuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryAction.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_basket_outlined,
                  size: 64, color: Colors.white24),
            ),
            const SizedBox(height: 24),
            const Text('Nenhum item para mostrar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Continue escaneando suas notas fiscais para que possamos aprender seus hábitos de consumo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Erro ao carregar lista: $message',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
