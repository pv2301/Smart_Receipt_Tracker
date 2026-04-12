import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

enum SuggestionLevel { normal, proximo, critico }

class SuggestionCard extends StatelessWidget {
  final String productName;
  final String category;
  final String status;
  final DateTime lastPurchase;
  final int daysSinceLast;
  final DateTime predictedNext;

  const SuggestionCard({
    super.key,
    required this.productName,
    required this.category,
    required this.status,
    required this.lastPurchase,
    required this.daysSinceLast,
    required this.predictedNext,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    Color accentColor;
    IconData statusIcon;
    String statusLabel;
    
    switch (status) {
      case 'Crítico':
        accentColor = Colors.redAccent;
        statusIcon = Icons.warning_amber_rounded;
        statusLabel = 'Reposição Urgente';
        break;
      case 'Próximo':
        accentColor = Colors.orangeAccent;
        statusIcon = Icons.info_outline_rounded;
        statusLabel = 'Comprar em breve';
        break;
      default:
        accentColor = AppTheme.primaryAction;
        statusIcon = Icons.check_circle_outline_rounded;
        statusLabel = 'Estoque OK';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAction.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryAction,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(color: accentColor, icon: statusIcon, label: statusLabel),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoTile(
                  label: 'Última compra',
                  value: dateFormat.format(lastPurchase),
                  subValue: '$daysSinceLast dias atrás',
                ),
                _InfoTile(
                  label: 'Previsão próxima',
                  value: dateFormat.format(predictedNext),
                  subValue: 'Baseado na frequência',
                  isHighlighted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _StatusBadge({required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final bool isHighlighted;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.subValue,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppTheme.primaryAction : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subValue,
          style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 10),
        ),
      ],
    );
  }
}
