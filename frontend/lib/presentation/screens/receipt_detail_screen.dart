import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../../data/receipt_repository.dart';
import '../../domain/entities/receipt.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final int receiptId;
  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptAsync = ref.watch(receiptByIdProvider(receiptId));

    return receiptAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryAction)),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text('Erro ao carregar: $err',
              style: const TextStyle(color: AppTheme.textSecondary)),
        ),
      ),
      data: (receipt) => Scaffold(
        appBar: AppBar(
          title: const Text('Detalhe do Recibo',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Compartilhar',
              onPressed: () => _shareReceipt(receipt),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              tooltip: 'Apagar recibo',
              onPressed: () => _confirmDelete(context, ref, receipt),
            ),
          ],
        ),
        body: _ReceiptDetailContent(receipt: receipt),
      ),
    );
  }

  void _shareReceipt(Receipt receipt) {
    final currFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

    final buf = StringBuffer();
    buf.writeln('🧾 *${receipt.storeName}*');
    if (receipt.merchantId != null && receipt.merchantId!.isNotEmpty) {
      buf.writeln('CNPJ: ${receipt.merchantId}');
    }
    buf.writeln('Data: ${dateFmt.format(receipt.date)}');
    buf.writeln('');
    for (final item in receipt.items) {
      final qty = item.quantity % 1 == 0
          ? item.quantity.toInt().toString()
          : item.quantity.toStringAsFixed(3);
      buf.writeln(
          '• ${item.productName}  $qty × ${currFmt.format(item.unitPrice)}  = ${currFmt.format(item.totalPrice)}');
    }
    buf.writeln('');
    buf.writeln('*Total: ${currFmt.format(receipt.totalAmount)}*');
    if (receipt.taxes != null && receipt.taxes! > 0) {
      buf.writeln('Impostos: ${currFmt.format(receipt.taxes)}');
    }
    buf.writeln('');
    buf.writeln('Enviado via Notinha 🧾');

    Share.share(buf.toString(), subject: 'Nota ${receipt.storeName}');
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Receipt receipt) async {
    final confirmed = await showDialog<bool>(
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
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(receiptRepositoryProvider).deleteReceipt(receipt.id);
      ref.invalidate(receiptsProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao apagar: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReceiptDetailContent extends StatelessWidget {
  final Receipt receipt;
  const _ReceiptDetailContent({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFmt = DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            AppTheme.primaryAction.withOpacity(0.15),
                        child: const Icon(Icons.store_rounded,
                            color: AppTheme.primaryAction, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.storeName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 2,
                            ),
                            if (receipt.merchantId != null)
                              Text(receipt.merchantId!,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Data',
                    value: dateFmt.format(receipt.date),
                    icon: Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Total',
                    value: currencyFmt.format(receipt.totalAmount),
                    icon: Icons.attach_money_rounded,
                    valueStyle: const TextStyle(
                        color: AppTheme.primaryAction,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  if (receipt.taxes != null && receipt.taxes! > 0) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Impostos',
                      value: currencyFmt.format(receipt.taxes),
                      icon: Icons.receipt_rounded,
                    ),
                  ],
                  if (receipt.accessKey != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Chave de Acesso',
                      value: receipt.accessKey!,
                      icon: Icons.key_rounded,
                      valueStyle: const TextStyle(
                          fontSize: 10, fontFamily: 'monospace'),
                      wrap: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Items ──
          Text(
            'Itens (${receipt.items.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          if (receipt.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Sem itens detalhados',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: receipt.items.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.white.withOpacity(0.06)),
                itemBuilder: (context, index) {
                  final item = receipt.items[index];
                  return _ItemTile(item: item, formatter: currencyFmt);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final TextStyle? valueStyle;
  final bool wrap;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueStyle,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          wrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            style: valueStyle ?? const TextStyle(fontSize: 13),
            softWrap: wrap,
            overflow: wrap ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final ReceiptItem item;
  final NumberFormat formatter;
  const _ItemTile({required this.item, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final qtyStr = item.quantity % 1 == 0
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2),
                const SizedBox(height: 2),
                Text(
                  '$qtyStr × ${formatter.format(item.unitPrice)}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                if (item.category != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAction.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category!,
                      style: const TextStyle(
                          color: AppTheme.primaryAction, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatter.format(item.totalPrice),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
