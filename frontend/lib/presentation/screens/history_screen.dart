import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/services/export_service.dart';
import '../providers/receipt_providers.dart';
import '../../data/receipt_repository.dart';
import '../../domain/entities/receipt.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportData(String format, List<Receipt> receipts) async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gerando relatório...'),
            duration: Duration(seconds: 1)),
      );
      final now = DateTime.now();
      if (format == 'pdf') {
        await ExportService.exportMonthlyPdf(
            context, receipts, now.month, now.year);
      } else {
        await ExportService.exportMonthlyExcel(
            context, receipts, now.month, now.year);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao exportar: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showExportOptions(List<Receipt> receipts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Exportar Relatório Mensal',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Escolha o formato desejado para o mês atual',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent),
                title: const Text('Relatório PDF'),
                subtitle: const Text('Resumo + lista detalhada',
                    style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportData('pdf', receipts);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded,
                    color: Colors.greenAccent),
                title: const Text('Planilha Excel'),
                subtitle: const Text('3 abas: Resumo, Itens, Por Categoria',
                    style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportData('excel', receipts);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Export button — reads receipts from provider state
          Consumer(
            builder: (_, ref, __) {
              final receipts =
                  ref.watch(receiptsProvider).asData?.value ?? const [];
              return IconButton(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Exportar Relatórios',
                onPressed: () => _showExportOptions(receipts),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(receiptsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar por loja...',
              leading: const Icon(Icons.search_rounded),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    ]
                  : null,
              onChanged: (v) => setState(() => _searchQuery = v),
              backgroundColor: WidgetStatePropertyAll(AppTheme.cardColor),
              shadowColor:
                  const WidgetStatePropertyAll(Colors.transparent),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12)),
            ),
          ),

          // ── Category filter chips ──
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // "Todos" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedCategory == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = null),
                    selectedColor:
                        AppTheme.primaryAction.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryAction,
                    labelStyle: TextStyle(
                      color: _selectedCategory == null
                          ? AppTheme.primaryAction
                          : AppTheme.textSecondary,
                      fontSize: AppTheme.fontSM,
                    ),
                    side: BorderSide(
                      color: _selectedCategory == null
                          ? AppTheme.primaryAction
                          : Colors.white12,
                    ),
                    backgroundColor: AppTheme.cardColor,
                  ),
                ),
                // Category chips
                ...AppCategories.labels.map((label) {
                  final info = AppCategories.get(label);
                  final isSelected = _selectedCategory == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Text(info.emoji,
                          style: const TextStyle(fontSize: 14)),
                      label: Text(info.label),
                      selected: isSelected,
                      onSelected: (_) => setState(() =>
                          _selectedCategory = isSelected ? null : label),
                      selectedColor: info.color.withOpacity(0.2),
                      checkmarkColor: info.color,
                      labelStyle: TextStyle(
                        color: isSelected ? info.color : AppTheme.textSecondary,
                        fontSize: AppTheme.fontSM,
                      ),
                      side: BorderSide(
                        color: isSelected ? info.color : Colors.white12,
                      ),
                      backgroundColor: AppTheme.cardColor,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── List ──
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(receiptsProvider.future),
              color: AppTheme.primaryAction,
              backgroundColor: AppTheme.cardColor,
              child: receiptsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryAction),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 56, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text('Erro: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(receiptsProvider),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
                data: (receipts) {
                  // Filter by search query
                  var filtered = _searchQuery.isEmpty
                      ? receipts
                      : receipts
                          .where((r) => r.storeName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();

                  // Filter by selected category
                  if (_selectedCategory != null) {
                    filtered = filtered
                        .where((r) => r.items.any(
                              (item) => item.category == _selectedCategory,
                            ))
                        .toList();
                  }

                  return _HistoryList(
                    receipts: filtered,
                    onDelete: (id) async {
                      await ref
                          .read(receiptRepositoryProvider)
                          .deleteReceipt(id);
                      ref.invalidate(receiptsProvider);
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

// ─────────────────────────────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  final List<Receipt> receipts;
  final Future<void> Function(int id) onDelete;

  const _HistoryList({required this.receipts, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded,
                size: 64,
                color: AppTheme.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Nenhum recibo encontrado',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    final currencyFmt =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat('dd/MM/yyyy • HH:mm', 'pt_BR');

    // Group by month
    final grouped = <String, List<Receipt>>{};
    for (final r in receipts) {
      final key = DateFormat('MMMM y', 'pt_BR').format(r.date);
      grouped.putIfAbsent(key, () => []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      itemCount: grouped.length,
      itemBuilder: (context, groupIdx) {
        final month = grouped.keys.elementAt(groupIdx);
        final monthReceipts = grouped[month]!;
        final monthTotal =
            monthReceipts.fold(0.0, (s, r) => s + r.totalAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppTheme.spaceSM, top: AppTheme.spaceSM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${month[0].toUpperCase()}${month.substring(1)}',
                    style: const TextStyle(
                        fontSize: AppTheme.fontLG,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryAction),
                  ),
                  Text(
                    currencyFmt.format(monthTotal),
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontSM),
                  ),
                ],
              ),
            ),
            ...monthReceipts.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
                  child: _SwipeToDeleteCard(
                    receipt: r,
                    currencyFmt: currencyFmt,
                    dateFmt: dateFmt,
                    onDelete: onDelete,
                  ),
                )),
            const Divider(height: AppTheme.spaceLG, color: Colors.white12),
          ],
        );
      },
    );
  }
}

// ── Swipe-to-delete wrapper ──────────────────────────────────────────────────

class _SwipeToDeleteCard extends StatelessWidget {
  final Receipt receipt;
  final NumberFormat currencyFmt;
  final DateFormat dateFmt;
  final Future<void> Function(int) onDelete;

  const _SwipeToDeleteCard({
    required this.receipt,
    required this.currencyFmt,
    required this.dateFmt,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(receipt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 6),
            Text('Apagar',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: const Text('Apagar recibo'),
            content: Text(
                'Deseja apagar permanentemente o recibo de ${receipt.storeName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Apagar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(receipt.id),
      child: _ReceiptCard(
        receipt: receipt,
        currencyFmt: currencyFmt,
        dateFmt: dateFmt,
      ),
    );
  }
}

// ── Receipt Card ─────────────────────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final NumberFormat currencyFmt;
  final DateFormat dateFmt;

  const _ReceiptCard({
    required this.receipt,
    required this.currencyFmt,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = receipt.items.length;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        onTap: () => context.push('/receipt/${receipt.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAction.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Icon(Icons.receipt_rounded,
                    color: AppTheme.primaryAction,
                    size: AppTheme.iconSizeMD),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.storeName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppTheme.fontMD),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 11, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          dateFmt.format(receipt.date),
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppTheme.fontSM),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.shopping_basket_rounded,
                            size: 11, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '$itemCount ${itemCount == 1 ? "item" : "itens"}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: AppTheme.fontSM),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFmt.format(receipt.totalAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontLG,
                        color: AppTheme.primaryAction),
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
