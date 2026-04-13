import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../../data/receipt_repository.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/budget_status.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _exportData(BuildContext context, WidgetRef ref, String format) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gerando relatório...'), duration: Duration(seconds: 2)),
      );

      final now = DateTime.now();
      final repo = ref.read(receiptRepositoryProvider);
      final bytes = await repo.exportReceipts(
        format: format,
        month: now.month,
        year: now.year,
      );

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = format == 'pdf' 
          ? 'relatorio_gastos_${now.month}_${now.year}.pdf'
          : 'gastos_smart_tracker_${now.month}_${now.year}.xlsx';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'Meu relatório de gastos - Notinha');
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Exportar Relatório Mensal', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Escolha o formato desejado para o mês atual', 
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
                title: const Text('Relatório PDF (com Gráficos)'),
                onTap: () {
                  Navigator.pop(context);
                  _exportData(context, ref, 'pdf');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded, color: Colors.greenAccent),
                title: const Text('Planilha Excel (Contabilidade)'),
                onTap: () {
                  Navigator.pop(context);
                  _exportData(context, ref, 'excel');
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
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(receiptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Exportar Relatórios',
            onPressed: () => _showExportOptions(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(receiptsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(receiptsProvider.future),
        color: AppTheme.primaryAction,
        backgroundColor: AppTheme.cardColor,
        child: receiptsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryAction),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text('Erro: $err',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(receiptsProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
          data: (receipts) => _HistoryList(receipts: receipts),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Receipt> receipts;
  const _HistoryList({required this.receipts});

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded,
                size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('Nenhum recibo no histórico',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat('dd/MM/yyyy • HH:mm', 'pt_BR');

    // Group receipts by month
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
        final monthTotal = monthReceipts.fold(0.0, (s, r) => s + r.totalAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceSM, top: AppTheme.spaceSM),
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
                  child: _ReceiptCard(
                    receipt: r,
                    currencyFmt: currencyFmt,
                    dateFmt: dateFmt,
                  ),
                )),
            const Divider(height: AppTheme.spaceLG, color: Colors.white12),
          ],
        );
      },
    );
  }
}

// ── Receipt Card ──────────────────────────────────────────────────────────────

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
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAction.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Icon(Icons.receipt_rounded,
                    color: AppTheme.primaryAction, size: AppTheme.iconSizeMD),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              // Info
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
              // Value + arrow
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
