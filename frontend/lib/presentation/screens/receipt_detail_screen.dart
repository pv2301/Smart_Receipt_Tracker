import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../../data/receipt_repository.dart';
import '../../domain/entities/receipt.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _displayCategory(String? cat) {
  if (cat == null || cat.isEmpty) return '';
  final parts = cat.split('/');
  if (parts.length < 2) return cat;
  final prefix = parts[0].length >= 5 ? '${parts[0].substring(0, 5)}.' : parts[0];
  return '$prefix ${parts[1]}';
}

// ─────────────────────────────────────────────────────────────────────────────

class ReceiptDetailScreen extends ConsumerStatefulWidget {
  final int receiptId;

  /// IDs de todos os recibos da lista de histórico, para swipe entre eles.
  /// Quando null, a tela exibe apenas o recibo informado sem navegação por swipe.
  final List<int>? allIds;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
    this.allIds,
  });

  @override
  ConsumerState<ReceiptDetailScreen> createState() =>
      _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  late final PageController _pageCtrl;
  late final List<int> _ids;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _ids = widget.allIds ?? [widget.receiptId];
    _currentIndex = _ids.indexOf(widget.receiptId);
    if (_currentIndex < 0) _currentIndex = 0;
    _pageCtrl = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current receipt purely for the AppBar actions
    final currentId = _ids[_currentIndex];
    final currentReceipt = ref.watch(receiptByIdProvider(currentId)).asData?.value;
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < _ids.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Detalhe do Recibo',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (_ids.length > 1)
              Text(
                '${_currentIndex + 1} / ${_ids.length}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: currentReceipt == null
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'Compartilhar / Exportar',
                  onPressed: () =>
                      _showShareSheet(context, ref, currentReceipt),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  tooltip: 'Apagar recibo',
                  onPressed: () =>
                      _confirmDelete(context, ref, currentReceipt),
                ),
              ],
      ),
      body: Stack(
        children: [
          // ── PageView — swipe horizontal entre recibos ──
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _ids.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final idAtIndex = _ids[index];
              final asyncAtIndex = ref.watch(receiptByIdProvider(idAtIndex));
              return asyncAtIndex.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryAction)),
                error: (err, _) => Center(
                    child: Text('Erro: $err',
                        style: const TextStyle(
                            color: AppTheme.textSecondary))),
                data: (receipt) => _ReceiptDetailContent(
                  receipt: receipt,
                  receiptId: idAtIndex,
                ),
              );
            },
          ),

          // ── Chevron hints (purely decorative) ──
          if (hasPrev)
            const Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: Icon(Icons.chevron_left_rounded,
                      size: 28, color: Colors.white24),
                ),
              ),
            ),
          if (hasNext)
            const Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: Icon(Icons.chevron_right_rounded,
                      size: 28, color: Colors.white24),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Share ─────────────────────────────────────────────────────────────────

  void _showShareSheet(BuildContext context, WidgetRef ref, Receipt receipt) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Compartilhar recibo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.message_rounded,
                  color: AppTheme.primaryAction),
              title: const Text('Compartilhar como texto'),
              onTap: () {
                Navigator.pop(ctx);
                _shareText(receipt);
              },
            ),
            if (!kIsWeb) ...[
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppTheme.primaryAction),
                title: const Text('Exportar PDF'),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportFile(context, ref, receipt, 'pdf');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded,
                    color: AppTheme.primaryAction),
                title: const Text('Exportar Planilha'),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportFile(context, ref, receipt, 'excel');
                },
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _shareText(Receipt receipt) {
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
    final hasBreakdown = receipt.taxState != null &&
        receipt.taxFederal != null &&
        (receipt.taxState! > 0 || receipt.taxFederal! > 0);
    if (hasBreakdown) {
      buf.writeln(
          'Impostos: Estadual ${currFmt.format(receipt.taxState ?? 0)} | Federal ${currFmt.format(receipt.taxFederal ?? 0)}');
    } else if (receipt.taxes != null && receipt.taxes! > 0) {
      buf.writeln('Impostos: ${currFmt.format(receipt.taxes)}');
    }
    buf.writeln('');
    buf.writeln('Enviado via Notinha 🧾');
    Share.share(buf.toString(), subject: 'Nota ${receipt.storeName}');
  }

  Future<void> _exportFile(BuildContext context, WidgetRef ref,
      Receipt receipt, String format) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(receiptRepositoryProvider);
      final bytes =
          await repo.exportSingleReceipt(id: receipt.id, format: format);
      final ext = format == 'pdf' ? 'pdf' : 'xlsx';
      final xfile = XFile.fromData(
        bytes,
        name: 'recibo_${receipt.id}.$ext',
        mimeType: format == 'pdf'
            ? 'application/pdf'
            : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      await Share.shareXFiles([xfile], subject: 'Recibo ${receipt.storeName}');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.redAccent),
      );
    }
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
  final int receiptId;
  const _ReceiptDetailContent(
      {required this.receipt, required this.receiptId});

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
                  // ── Fix: impostos com wrap para não cortar ──
                  if (receipt.taxState != null &&
                      receipt.taxFederal != null &&
                      (receipt.taxState! > 0 || receipt.taxFederal! > 0)) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Impostos',
                      value:
                          'Estadual ${currencyFmt.format(receipt.taxState ?? 0)} | Federal ${currencyFmt.format(receipt.taxFederal ?? 0)}',
                      icon: Icons.receipt_rounded,
                      wrap: true, // quebra linha em vez de ellipsis
                    ),
                  ] else if (receipt.taxes != null &&
                      receipt.taxes! > 0) ...[
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
                  return _ItemTile(
                    item: item,
                    formatter: currencyFmt,
                    receiptId: receiptId,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── _InfoRow ──────────────────────────────────────────────────────────────────

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
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            style: valueStyle ?? const TextStyle(fontSize: 13),
            softWrap: wrap,
            overflow:
                wrap ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Categorias disponíveis para seleção manual ────────────────────────────────

const _kCategories = [
  'Alimentos/Frios',
  'Alimentos/Carnes',
  'Alimentos/Hortifruti',
  'Alimentos/Panificação',
  'Alimentos/Grãos',
  'Alimentos/Laticínios',
  'Alimentos/Mercearia',
  'Alimentos',
  'Bebidas',
  'Limpeza',
  'Higiene',
  'Lazer',
  'Outros',
];

// ── _ItemTile ─────────────────────────────────────────────────────────────────

class _ItemTile extends ConsumerWidget {
  final ReceiptItem item;
  final NumberFormat formatter;
  final int receiptId;
  const _ItemTile(
      {required this.item,
      required this.formatter,
      required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qtyStr = item.quantity % 1 == 0
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(3);

    return InkWell(
      onTap: () => _showActionsSheet(context, ref),
      child: Padding(
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
                  if (item.category != null && item.category!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAction.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _displayCategory(item.category),
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
      ),
    );
  }

  void _showActionsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                item.productName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading:
                  const Icon(Icons.notifications_rounded, color: Colors.amber),
              title: const Text('Monitorar preço'),
              subtitle: const Text('Em breve',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Monitoramento disponível em breve!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_alert_rounded,
                  color: AppTheme.primaryAction),
              title: const Text('Criar alerta de preço'),
              subtitle: const Text('Em breve',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Alertas disponíveis em breve!')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_rounded,
                  color: AppTheme.primaryAction),
              title: const Text('Categorizar'),
              subtitle: Text(
                  item.category != null
                      ? 'Atual: ${_displayCategory(item.category)}'
                      : 'Sem categoria',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                _showCategoryPicker(context, ref);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Selecionar categoria',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kCategories.map((cat) {
                      final selected = item.category == cat;
                      return FilterChip(
                        label: Text(_displayCategory(cat)),
                        selected: selected,
                        onSelected: (_) async {
                          Navigator.pop(ctx);
                          try {
                            await ref
                                .read(receiptRepositoryProvider)
                                .patchReceiptItemCategory(item.id, cat);
                            ref.invalidate(receiptByIdProvider(receiptId));
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Erro ao salvar: $e'),
                                    backgroundColor: Colors.redAccent),
                              );
                            }
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
