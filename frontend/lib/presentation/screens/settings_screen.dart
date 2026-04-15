import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/services/export_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/receipt_repository.dart';
import '../providers/settings_provider.dart';
import '../providers/receipt_providers.dart';

const _kVersion = '1.0.0';

const _brazilStates = [
  'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA',
  'MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN',
  'RS','RO','RR','SC','SP','SE','TO',
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryAction)),
        error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: Colors.redAccent))),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          children: [
            _SectionHeader('ORÇAMENTO'),
            _BudgetSection(settings: settings),
            const SizedBox(height: AppTheme.spaceLG),

            _SectionHeader('LOCALIZAÇÃO & SEFAZ'),
            _LocationSection(settings: settings),
            const SizedBox(height: AppTheme.spaceLG),

            _SectionHeader('NOTIFICAÇÕES'),
            _NotificationsSection(settings: settings),
            const SizedBox(height: AppTheme.spaceLG),

            _SectionHeader('DADOS'),
            _DataSection(),
            const SizedBox(height: AppTheme.spaceLG),

            Center(
              child: Text(
                'Notinha v$_kVersion',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: AppTheme.fontSM),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppTheme.fontSM,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryAction,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: children
            .expand((w) => [w, const Divider(height: 1, color: Colors.white10)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

// ── Orçamento ─────────────────────────────────────────────────────────────────

class _BudgetSection extends ConsumerWidget {
  final AppSettings settings;
  const _BudgetSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return _SettingsCard(children: [
      ListTile(
        title: const Text('Meta mensal padrão'),
        trailing: Text(
          currFmt.format(settings.defaultBudget),
          style: const TextStyle(color: AppTheme.primaryAction, fontWeight: FontWeight.w600),
        ),
        onTap: () => _showBudgetDialog(context, ref, settings),
      ),
      ListTile(
        title: const Text('Tipo de meta'),
        trailing: ToggleButtons(
          isSelected: [settings.isBudgetFixed, !settings.isBudgetFixed],
          onPressed: (i) async {
            final updated = settings.copyWith(isBudgetFixed: i == 0);
            await ref.read(settingsProvider.notifier).save(updated);
            await ref.read(receiptRepositoryProvider).updateBudgetSettings(
              updated.defaultBudget, updated.isBudgetFixed,
            );
            ref.invalidate(budgetStatusProvider);
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          selectedColor: AppTheme.darkBackground,
          fillColor: AppTheme.primaryAction,
          color: AppTheme.textSecondary,
          constraints: const BoxConstraints(minHeight: 32, minWidth: 72),
          children: const [Text('Fixo'), Text('Por mês')],
        ),
      ),
    ]);
  }

  Future<void> _showBudgetDialog(BuildContext context, WidgetRef ref, AppSettings settings) async {
    final controller = TextEditingController(
      text: settings.defaultBudget > 0 ? settings.defaultBudget.toStringAsFixed(2) : '',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Meta mensal padrão'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            hintText: '0,00',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (confirmed != true) return;
    final value = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
    final updated = settings.copyWith(defaultBudget: value);
    await ref.read(settingsProvider.notifier).save(updated);
    await ref.read(receiptRepositoryProvider).updateBudgetSettings(
      updated.defaultBudget, updated.isBudgetFixed,
    );
    ref.invalidate(budgetStatusProvider);
  }
}

// ── Localização & SEFAZ ───────────────────────────────────────────────────────

class _LocationSection extends ConsumerWidget {
  final AppSettings settings;
  const _LocationSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsCard(children: [
      ListTile(
        title: const Text('Estado padrão'),
        subtitle: const Text('Usado quando o QR não identifica o estado',
            style: TextStyle(fontSize: AppTheme.fontSM, color: AppTheme.textSecondary)),
        trailing: DropdownButton<String>(
          value: settings.defaultState,
          dropdownColor: AppTheme.cardColor,
          underline: const SizedBox(),
          style: const TextStyle(color: AppTheme.primaryAction, fontWeight: FontWeight.w600),
          items: _brazilStates
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) async {
            if (v == null) return;
            await ref.read(settingsProvider.notifier).save(settings.copyWith(defaultState: v));
          },
        ),
      ),
      SwitchListTile(
        title: const Text('Detectar estado pelo QR'),
        subtitle: const Text('Identifica automaticamente a SEFAZ do QR code',
            style: TextStyle(fontSize: AppTheme.fontSM, color: AppTheme.textSecondary)),
        value: settings.detectStateFromQr,
        activeColor: AppTheme.primaryAction,
        onChanged: (v) async {
          await ref.read(settingsProvider.notifier).save(settings.copyWith(detectStateFromQr: v));
        },
      ),
      SwitchListTile(
        title: const Text('Perguntar ao detectar outro estado'),
        subtitle: const Text('Sugere trocar SEFAZ quando você está em outro estado',
            style: TextStyle(fontSize: AppTheme.fontSM, color: AppTheme.textSecondary)),
        value: settings.askOnStateChange,
        activeColor: AppTheme.primaryAction,
        onChanged: settings.detectStateFromQr
            ? (v) async {
                await ref.read(settingsProvider.notifier).save(settings.copyWith(askOnStateChange: v));
              }
            : null,
      ),
    ]);
  }
}

// ── Notificações ──────────────────────────────────────────────────────────────

class _NotificationsSection extends ConsumerWidget {
  final AppSettings settings;
  const _NotificationsSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsCard(children: [
      SwitchListTile(
        title: const Text('Lembrete diário'),
        subtitle: const Text('Lembra de registrar suas compras',
            style: TextStyle(fontSize: AppTheme.fontSM, color: AppTheme.textSecondary)),
        value: settings.dailyReminderEnabled,
        activeColor: AppTheme.primaryAction,
        onChanged: (v) async {
          final updated = settings.copyWith(dailyReminderEnabled: v);
          await ref.read(settingsProvider.notifier).save(updated);
          final svc = NotificationService();
          if (v) {
            await svc.scheduleDailyReminder(
              id: 1000,
              hour: updated.reminderHour,
              minute: updated.reminderMinute,
            );
          } else {
            // Cancela notificação agendada
            await svc.cancelNotification(1000);
          }
        },
      ),
      ListTile(
        title: const Text('Horário do lembrete'),
        enabled: settings.dailyReminderEnabled,
        trailing: Text(
          '${settings.reminderHour.toString().padLeft(2, '0')}:${settings.reminderMinute.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: settings.dailyReminderEnabled ? AppTheme.primaryAction : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: settings.dailyReminderEnabled
            ? () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.reminderHour,
                    minute: settings.reminderMinute,
                  ),
                );
                if (picked == null) return;
                final updated = settings.copyWith(
                  reminderHour: picked.hour,
                  reminderMinute: picked.minute,
                );
                await ref.read(settingsProvider.notifier).save(updated);
                await NotificationService().scheduleDailyReminder(
                  id: 1000,
                  hour: picked.hour,
                  minute: picked.minute,
                );
              }
            : null,
      ),
      SwitchListTile(
        title: const Text('Alerta de orçamento'),
        subtitle: const Text('Notifica quando você está próximo do limite',
            style: TextStyle(fontSize: AppTheme.fontSM, color: AppTheme.textSecondary)),
        value: settings.budgetAlertEnabled,
        activeColor: AppTheme.primaryAction,
        onChanged: (v) async {
          await ref.read(settingsProvider.notifier).save(settings.copyWith(budgetAlertEnabled: v));
        },
      ),
      ListTile(
        title: const Text('Avisar ao atingir'),
        enabled: settings.budgetAlertEnabled,
        trailing: DropdownButton<int>(
          value: settings.budgetAlertPercent,
          dropdownColor: AppTheme.cardColor,
          underline: const SizedBox(),
          style: TextStyle(
            color: settings.budgetAlertEnabled ? AppTheme.primaryAction : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          items: [50, 70, 80, 90, 100]
              .map((p) => DropdownMenuItem(value: p, child: Text('$p%')))
              .toList(),
          onChanged: settings.budgetAlertEnabled
              ? (v) async {
                  if (v == null) return;
                  await ref.read(settingsProvider.notifier).save(
                    settings.copyWith(budgetAlertPercent: v),
                  );
                }
              : null,
        ),
      ),
    ]);
  }
}

// ── Dados ─────────────────────────────────────────────────────────────────────

class _DataSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsCard(children: [
      ListTile(
        leading: const Icon(Icons.file_download_outlined,
            color: AppTheme.primaryAction),
        title: const Text('Exportar histórico completo'),
        subtitle: const Text('Gera PDF ou Excel do mês atual',
            style: TextStyle(
                fontSize: AppTheme.fontSM, color: AppTheme.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppTheme.textSecondary),
        onTap: () => _showExportSheet(context, ref),
      ),
      ListTile(
        title: const Text('Limpar todo o histórico',
            style: TextStyle(color: Colors.redAccent)),
        trailing: const Icon(Icons.delete_outline_rounded,
            color: Colors.redAccent),
        onTap: () => _confirmClear(context, ref),
      ),
    ]);
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final receipts =
            ref.read(receiptsProvider).asData?.value ?? const [];
        final now = DateTime.now();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Exportar Histórico',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Mês atual: ${_monthLabel(now)}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.redAccent),
                  title: const Text('Relatório PDF'),
                  subtitle: const Text('Resumo + notas detalhadas',
                      style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _export(context, 'pdf', receipts, now);
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
                    _export(context, 'excel', receipts, now);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _export(
    BuildContext context,
    String format,
    List receipts,
    DateTime now,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gerando relatório…'),
            duration: Duration(seconds: 1)),
      );
      if (format == 'pdf') {
        await ExportService.exportMonthlyPdf(
            context, List.from(receipts), now.month, now.year);
      } else {
        await ExportService.exportMonthlyExcel(
            context, List.from(receipts), now.month, now.year);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao exportar: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  String _monthLabel(DateTime dt) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Limpar histórico'),
        content: const Text(
          'Todos os recibos serão apagados permanentemente. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar tudo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final count = await ref.read(receiptRepositoryProvider).clearAllReceipts();
      ref.invalidate(receiptsProvider);
      ref.invalidate(budgetStatusProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                count == 1 ? '1 recibo apagado.' : '$count recibos apagados.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao limpar: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}
