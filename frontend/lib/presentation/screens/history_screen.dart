import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../../domain/entities/receipt.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

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
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, groupIdx) {
        final month = grouped.keys.elementAt(groupIdx);
        final monthReceipts = grouped[month]!;
        final monthTotal = monthReceipts.fold(0.0, (s, r) => s + r.totalAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${month[0].toUpperCase()}${month.substring(1)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryAction),
                  ),
                  Text(
                    currencyFmt.format(monthTotal),
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Receipts in month
            ...monthReceipts.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/receipt/${r.id}'),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryAction.withOpacity(0.12),
                          child: const Icon(Icons.receipt_rounded,
                              color: AppTheme.primaryAction, size: 20),
                        ),
                        title: Text(r.storeName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          '${dateFmt.format(r.date)} · ${r.items.length} itens',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        trailing: Text(
                          currencyFmt.format(r.totalAmount),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryAction),
                        ),
                      ),
                    ),
                  ),
                )),
            const Divider(height: 24),
          ],
        );
      },
    );
  }
}
