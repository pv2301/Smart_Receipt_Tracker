import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../widgets/suggestion_card.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  // Categorias padrão de mercado (conforme solicitado)
  final List<String> _marketCategories = ["Alimentos", "Bebidas", "Limpeza", "Higiene"];

  @override
  Widget build(BuildContext context) {
    // Busca as sugestões passando as categorias de mercado
    final suggestionsAsync = ref.watch(suggestionsProvider(_marketCategories));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Inteligente', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryAction),
            onPressed: () => ref.invalidate(suggestionsProvider),
            tooltip: 'Atualizar sugestões',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(suggestionsProvider(_marketCategories).future),
        color: AppTheme.primaryAction,
        backgroundColor: AppTheme.cardColor,
        child: suggestionsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryAction),
          ),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(suggestionsProvider),
          ),
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return _EmptySuggestions();
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final s = suggestions[index];
                return SuggestionCard(
                  productName: s.productName,
                  category: s.category,
                  status: s.status,
                  lastPurchase: s.lastPurchaseDate,
                  daysSinceLast: s.daysSinceLast,
                  predictedNext: s.predictedNextDate,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

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
              child: const Icon(
                Icons.shopping_basket_outlined,
                size: 64,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ainda não temos sugestões',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
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
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Erro ao carregar lista: $message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
