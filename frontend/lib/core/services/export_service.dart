import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as xl;
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/receipt.dart';

/// Client-side PDF/Excel export service.
/// Gera relatórios diretamente no dispositivo sem depender do backend.
class ExportService {
  ExportService._();

  // ── Currency / Date formatters ────────────────────────────────────────────

  static final _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _date = DateFormat('dd/MM/yyyy', 'pt_BR');

  // ── PDF ───────────────────────────────────────────────────────────────────

  /// Gera e compartilha o PDF mensal de gastos.
  static Future<void> exportMonthlyPdf(
    BuildContext context,
    List<Receipt> receipts,
    int month,
    int year,
  ) async {
    final filtered = _filterByMonth(receipts, month, year);
    final pdf = pw.Document();

    // Totais por categoria
    final byCategory = <String, double>{};
    for (final r in filtered) {
      for (final item in r.items) {
        final cat = item.category ?? 'Outros';
        byCategory[cat] = (byCategory[cat] ?? 0) + item.totalPrice;
      }
    }
    final totalSpent = filtered.fold(0.0, (s, r) => s + r.totalAmount);
    final monthLabel =
        DateFormat('MMMM yyyy', 'pt_BR').format(DateTime(year, month));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Notinha — Relatório de Gastos',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '${monthLabel[0].toUpperCase()}${monthLabel.substring(1)}',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Total: ${_currency.format(totalSpent)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Resumo por categoria
          if (byCategory.isNotEmpty) ...[
            pw.Text('Gastos por Categoria',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
              },
              children: [
                _pdfHeaderRow(['Categoria', 'Total', '% do Gasto']),
                ...(() {
                  final sorted = byCategory.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  return sorted.map((e) {
                    final pct = totalSpent > 0
                        ? (e.value / totalSpent * 100).toStringAsFixed(1)
                        : '0.0';
                    return _pdfDataRow([e.key, _currency.format(e.value), '$pct%']);
                  }).toList();
                })(),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Notas fiscais
          pw.Text('Notas Fiscais',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...filtered.map(
            (r) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  color: PdfColors.grey100,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(r.storeName,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_currency.format(r.totalAmount)),
                    ],
                  ),
                ),
                pw.Text(
                  _date.format(r.date),
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600),
                ),
                if (r.items.isNotEmpty)
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey200),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      _pdfHeaderRow(['Item', 'Qtd', 'Total'], small: true),
                      ...r.items.map((item) => _pdfDataRow(
                            [
                              item.productName,
                              item.quantity.toStringAsFixed(
                                  item.quantity % 1 == 0 ? 0 : 2),
                              _currency.format(item.totalPrice),
                            ],
                            small: true,
                          )),
                    ],
                  ),
                pw.SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );

    await _shareFile(
      bytes: await pdf.save(),
      fileName: 'notinha_${year}_${_pad(month)}.pdf',
      mimeType: 'application/pdf',
    );
  }

  // ── Excel ─────────────────────────────────────────────────────────────────

  /// Gera e compartilha a planilha Excel mensal.
  static Future<void> exportMonthlyExcel(
    BuildContext context,
    List<Receipt> receipts,
    int month,
    int year,
  ) async {
    final filtered = _filterByMonth(receipts, month, year);
    final excel = xl.Excel.createExcel();

    // Sheet: Resumo
    final summary = excel['Resumo'];
    _xlRow(summary, ['Loja', 'Data', 'Total', 'Itens'], bold: true);
    for (final r in filtered) {
      _xlRow(summary, [
        r.storeName,
        _date.format(r.date),
        r.totalAmount,
        r.items.length,
      ]);
    }
    final totalSpent = filtered.fold(0.0, (s, r) => s + r.totalAmount);
    _xlRow(summary, ['TOTAL', '', totalSpent, ''], bold: true);

    // Sheet: Itens
    final items = excel['Itens'];
    _xlRow(items, ['Loja', 'Data', 'Produto', 'Categoria', 'Qtd', 'Preço Unit.', 'Total'],
        bold: true);
    for (final r in filtered) {
      for (final item in r.items) {
        _xlRow(items, [
          r.storeName,
          _date.format(r.date),
          item.productName,
          item.category ?? 'Outros',
          item.quantity,
          item.unitPrice,
          item.totalPrice,
        ]);
      }
    }

    // Sheet: Por Categoria
    final byCategory = <String, double>{};
    for (final r in filtered) {
      for (final item in r.items) {
        final cat = item.category ?? 'Outros';
        byCategory[cat] = (byCategory[cat] ?? 0) + item.totalPrice;
      }
    }
    final catSheet = excel['Por Categoria'];
    _xlRow(catSheet, ['Categoria', 'Total', '% do Gasto'], bold: true);
    for (final e in byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))) {
      final pct = totalSpent > 0 ? e.value / totalSpent * 100 : 0.0;
      _xlRow(catSheet, [e.key, e.value, '${pct.toStringAsFixed(1)}%']);
    }

    await _shareFile(
      bytes: excel.encode()!,
      fileName: 'notinha_${year}_${_pad(month)}.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  // ── Single Receipt PDF ────────────────────────────────────────────────────

  /// Gera o PDF de uma única nota fiscal.
  static Future<void> exportReceiptPdf(
    BuildContext context,
    Receipt receipt,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(receipt.storeName,
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(_date.format(receipt.date),
                style: const pw.TextStyle(
                    fontSize: 12, color: PdfColors.grey600)),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                _pdfHeaderRow(['Produto', 'Qtd', 'Unit.', 'Total']),
                ...receipt.items.map(
                  (item) => _pdfDataRow([
                    item.productName,
                    item.quantity.toStringAsFixed(
                        item.quantity % 1 == 0 ? 0 : 2),
                    _currency.format(item.unitPrice),
                    _currency.format(item.totalPrice),
                  ]),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: ${_currency.format(receipt.totalAmount)}',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
    await _shareFile(
      bytes: await pdf.save(),
      fileName: 'recibo_${receipt.id}.pdf',
      mimeType: 'application/pdf',
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<Receipt> _filterByMonth(
      List<Receipt> receipts, int month, int year) {
    return receipts
        .where((r) => r.date.month == month && r.date.year == year)
        .toList();
  }

  static Future<void> _shareFile({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      text: 'Relatório Notinha — $fileName',
    );
  }

  static pw.TableRow _pdfHeaderRow(List<String> cells,
      {bool small = false}) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  c,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: small ? 8 : 10,
                  ),
                ),
              ))
          .toList(),
    );
  }

  static pw.TableRow _pdfDataRow(List<String> cells,
      {bool small = false}) {
    return pw.TableRow(
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(c,
                    style: pw.TextStyle(fontSize: small ? 8 : 10)),
              ))
          .toList(),
    );
  }

  static void _xlRow(xl.Sheet sheet, List<dynamic> values,
      {bool bold = false}) {
    final row = sheet.maxRows;
    for (var i = 0; i < values.length; i++) {
      final cell = sheet.cell(
          xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = xl.TextCellValue(values[i].toString());
      if (bold) {
        cell.cellStyle = xl.CellStyle(bold: true);
      }
    }
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
