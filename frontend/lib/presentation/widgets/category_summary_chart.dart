import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/entities/receipt.dart';
import 'package:intl/intl.dart';

class CategorySummaryChart extends StatefulWidget {
  final List<Receipt> receipts;

  const CategorySummaryChart({super.key, required this.receipts});

  @override
  State<CategorySummaryChart> createState() => _CategorySummaryChartState();
}

class _CategorySummaryChartState extends State<CategorySummaryChart> {
  bool _isCurrentMonthOnly = true;
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // 1. Filtragem por data
    final filteredReceipts = _isCurrentMonthOnly
        ? widget.receipts.where((r) {
            final now = DateTime.now();
            return r.date.year == now.year && r.date.month == now.month;
          }).toList()
        : widget.receipts;

    // 2. Agrupamento por categoria
    final categoryTotals = <String, double>{};
    for (final receipt in filteredReceipts) {
      for (final item in receipt.items) {
        final cat = item.category ?? "Outros";
        categoryTotals[cat] = (categoryTotals[cat] ?? 0) + item.totalPrice;
      }
    }

    final totalValue = categoryTotals.values.fold(0.0, (s, v) => s + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header com Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gastos por Categoria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _TimeToggle(
                  isCurrentMonth: _isCurrentMonthOnly,
                  onChanged: (val) => setState(() => _isCurrentMonthOnly = val),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (categoryTotals.isEmpty)
              const SizedBox(
                height: 200,
                child: Center(child: Text('Sem dados suficientes')),
              )
            else
              Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = response.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: _generateSections(categoryTotals, totalValue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legenda
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryTotals.entries.map((e) {
                        return _LegendItem(
                          color: _getColorForCategory(e.key),
                          label: e.key,
                          value: NumberFormat.simpleCurrency(locale: 'pt_BR').format(e.value),
                          isFocused: categoryTotals.keys.toList().indexOf(e.key) == _touchedIndex,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, double> data, double total) {
    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 55.0 : 45.0;
      final percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        color: _getColorForCategory(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'ALIMENTOS':
        return AppTheme.primaryAction;
      case 'LIMPEZA':
        return Colors.blueAccent;
      case 'HIGIENE':
        return Colors.purpleAccent;
      case 'BEBIDAS':
        return Colors.orangeAccent;
      case 'LAZER':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }
}

class _TimeToggle extends StatelessWidget {
  final bool isCurrentMonth;
  final ValueChanged<bool> onChanged;

  const _TimeToggle({required this.isCurrentMonth, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleButton(
            label: 'Mês',
            selected: isCurrentMonth,
            onTap: () => onChanged(true),
          ),
          _ToggleButton(
            label: 'Tudo',
            selected: !isCurrentMonth,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryAction.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected ? Border.all(color: AppTheme.primaryAction.withOpacity(0.5)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppTheme.primaryAction : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool isFocused;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
