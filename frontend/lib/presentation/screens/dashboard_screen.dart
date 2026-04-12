import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/budget_status.dart';
import '../widgets/category_summary_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(receiptsProvider);

    final now = DateTime.now();
    final budgetAsync = ref.watch(budgetStatusProvider((month: now.month, year: now.year)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(receiptsProvider);
              ref.invalidate(budgetStatusProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(receiptsProvider.future);
          await ref.refresh(budgetStatusProvider((month: now.month, year: now.year)).future);
        },
        color: AppTheme.primaryAction,
        backgroundColor: AppTheme.cardColor,
        child: receiptsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryAction),
          ),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: () {
              ref.invalidate(receiptsProvider);
              ref.invalidate(budgetStatusProvider);
            },
          ),
          data: (receipts) => _DashboardContent(
            receipts: receipts,
            budgetAsync: budgetAsync,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content layout when data is available
// ---------------------------------------------------------------------------
class _DashboardContent extends ConsumerWidget {
  final List<Receipt> receipts;
  final AsyncValue<BudgetStatus> budgetAsync;
  const _DashboardContent({required this.receipts, required this.budgetAsync});

  double _totalThisMonth(List<Receipt> receipts) {
    final now = DateTime.now();
    return receipts
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold(0.0, (sum, r) => sum + r.totalAmount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final recentReceipts = receipts.take(5).toList();
    final total = _totalThisMonth(receipts);

    return RefreshIndicator(
      color: AppTheme.primaryAction,
      onRefresh: () async {
        // Handled via button; this is a visual affordance only
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Total Card ──
              _TotalCard(total: total, formatter: currencyFmt)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),

              // ── Budget Progress Card ──
              budgetAsync.when(
                loading: () => const SizedBox(height: 80, child: Center(child: LinearProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
                data: (budget) => _BudgetCard(status: budget, formatter: currencyFmt)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms),
              ),
              const SizedBox(height: 24),

              // ── Quick stats row ──
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.receipt_long_rounded,
                      label: 'Recibos',
                      value: '${receipts.length}',
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideX(begin: -0.1, end: 0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.shopping_cart_rounded,
                      label: 'Itens',
                      value: '${receipts.fold<int>(0, (s, r) => s + r.items.length)}',
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideX(begin: 0.1, end: 0),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Spending by Category Chart ──
              CategorySummaryChart(receipts: receipts)
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 600.ms)
                  .slideY(begin: 0.05, end: 0),
              const SizedBox(height: 32),

              // ── Recent receipts header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recibos Recentes',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () => context.go('/history'),
                    child: const Text('Ver tudo',
                        style: TextStyle(color: AppTheme.primaryAction)),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),

              if (receipts.isEmpty)
                _EmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentReceipts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _ReceiptTile(
                      receipt: recentReceipts[index],
                      formatter: currencyFmt,
                    )
                        .animate()
                        .fadeIn(delay: (500 + (index * 100)).ms, duration: 500.ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total spending card (glassmorphism style from theme)
// ---------------------------------------------------------------------------
class _TotalCard extends StatelessWidget {
  final double total;
  final NumberFormat formatter;
  const _TotalCard({required this.total, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat.MMMM('pt_BR').format(now);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Gastos em ${monthName[0].toUpperCase()}${monthName.substring(1)}',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(total),
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryAction,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini stat chip
// ---------------------------------------------------------------------------
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryAction, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(label,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt list tile
// ---------------------------------------------------------------------------
class _ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final NumberFormat formatter;
  const _ReceiptTile({required this.receipt, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/receipt/${receipt.id}'),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryAction.withOpacity(0.15),
            child: const Icon(Icons.receipt_rounded, color: AppTheme.primaryAction),
          ),
          title: Text(
            receipt.storeName,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${dateFmt.format(receipt.date)} · ${receipt.items.length} itens',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          trailing: Text(
            formatter.format(receipt.totalAmount),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.primaryAction),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Nenhum recibo ainda',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque no botão de câmera para escanear\nm primeira nota fiscal!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Budget Progress Card
// ---------------------------------------------------------------------------
class _BudgetCard extends ConsumerWidget {
  final BudgetStatus status;
  final NumberFormat formatter;
  const _BudgetCard({required this.status, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If goal is zero, we show a simplified "No budget set" card
    if (status.currentGoal <= 0) {
      return Card(
        color: AppTheme.cardColor.withOpacity(0.3),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 20),
              SizedBox(width: 12),
              Text('Nenhuma meta de gasto definida para este mês.', 
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    // Determine color based on usage
    Color progressColor;
    if (status.percentUsed < 80) {
      progressColor = AppTheme.primaryAction; // Neon Green
    } else if (status.percentUsed < 100) {
      progressColor = Colors.orangeAccent;
    } else {
      progressColor = Colors.redAccent; // Neon Red equivalent
    }

    final double progressValue = (status.percentUsed / 100).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Orçamento Mensal', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, size: 20, color: AppTheme.primaryAction),
                  onPressed: () => _showEditBudgetDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              status.percentUsed >= 100 ? 'Meta Atingida!' : 'Restam ${formatter.format(status.remaining)}',
              style: TextStyle(
                color: status.percentUsed >= 100 ? Colors.redAccent : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 10,
                backgroundColor: Colors.white12,
                color: progressColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Meta: ${formatter.format(status.currentGoal)}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text('${status.percentUsed.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: status.currentGoal.toString());
    bool isFixed = status.isFixed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('Configurar Meta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor da Meta (R\$)',
                  prefixText: 'R\$ ',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Meta Fixa', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Repetir nos próximos meses', style: TextStyle(fontSize: 11)),
                value: isFixed,
                onChanged: (v) => setState(() => isFixed = v),
                activeColor: AppTheme.primaryAction,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text) ?? 0.0;
                final repo = ref.read(receiptRepositoryProvider);
                
                // If the user wants to set for this specific month
                if (!isFixed) {
                  await repo.setMonthlyGoal(status.month, status.year, amount);
                }
                
                // Update global setting
                await repo.updateBudgetSettings(amount, isFixed);
                
                if (context.mounted) {
                  ref.invalidate(budgetStatusProvider);
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Erro ao conectar ao servidor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
