import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Keys ────────────────────────────────────────────────────────────────────
const _kDefaultBudget        = 'default_budget';
const _kIsBudgetFixed        = 'is_budget_fixed';
const _kDefaultState         = 'default_state';
const _kDetectFromQr         = 'detect_state_from_qr';
const _kAskOnStateChange     = 'ask_on_state_change';
const _kDailyReminder        = 'daily_reminder_enabled';
const _kReminderHour         = 'reminder_hour';
const _kReminderMinute       = 'reminder_minute';
const _kBudgetAlert          = 'budget_alert_enabled';
const _kBudgetAlertPercent   = 'budget_alert_percent';

// ── Model ────────────────────────────────────────────────────────────────────
class AppSettings {
  final double defaultBudget;
  final bool isBudgetFixed;
  final String defaultState;
  final bool detectStateFromQr;
  final bool askOnStateChange;
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool budgetAlertEnabled;
  final int budgetAlertPercent;

  const AppSettings({
    this.defaultBudget      = 0.0,
    this.isBudgetFixed      = true,
    this.defaultState       = 'PE',
    this.detectStateFromQr  = true,
    this.askOnStateChange   = true,
    this.dailyReminderEnabled = false,
    this.reminderHour       = 9,
    this.reminderMinute     = 0,
    this.budgetAlertEnabled = true,
    this.budgetAlertPercent = 80,
  });

  AppSettings copyWith({
    double? defaultBudget,
    bool? isBudgetFixed,
    String? defaultState,
    bool? detectStateFromQr,
    bool? askOnStateChange,
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? budgetAlertEnabled,
    int? budgetAlertPercent,
  }) {
    return AppSettings(
      defaultBudget:        defaultBudget        ?? this.defaultBudget,
      isBudgetFixed:        isBudgetFixed        ?? this.isBudgetFixed,
      defaultState:         defaultState         ?? this.defaultState,
      detectStateFromQr:    detectStateFromQr    ?? this.detectStateFromQr,
      askOnStateChange:     askOnStateChange     ?? this.askOnStateChange,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour:         reminderHour         ?? this.reminderHour,
      reminderMinute:       reminderMinute       ?? this.reminderMinute,
      budgetAlertEnabled:   budgetAlertEnabled   ?? this.budgetAlertEnabled,
      budgetAlertPercent:   budgetAlertPercent   ?? this.budgetAlertPercent,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _load();
  }

  AppSettings _load() {
    return AppSettings(
      defaultBudget:        _prefs.getDouble(_kDefaultBudget)      ?? 0.0,
      isBudgetFixed:        _prefs.getBool(_kIsBudgetFixed)         ?? true,
      defaultState:         _prefs.getString(_kDefaultState)        ?? 'PE',
      detectStateFromQr:    _prefs.getBool(_kDetectFromQr)          ?? true,
      askOnStateChange:     _prefs.getBool(_kAskOnStateChange)      ?? true,
      dailyReminderEnabled: _prefs.getBool(_kDailyReminder)         ?? false,
      reminderHour:         _prefs.getInt(_kReminderHour)           ?? 9,
      reminderMinute:       _prefs.getInt(_kReminderMinute)         ?? 0,
      budgetAlertEnabled:   _prefs.getBool(_kBudgetAlert)           ?? true,
      budgetAlertPercent:   _prefs.getInt(_kBudgetAlertPercent)     ?? 80,
    );
  }

  Future<void> update(AppSettings updated) async {
    await _prefs.setDouble(_kDefaultBudget,       updated.defaultBudget);
    await _prefs.setBool(_kIsBudgetFixed,          updated.isBudgetFixed);
    await _prefs.setString(_kDefaultState,         updated.defaultState);
    await _prefs.setBool(_kDetectFromQr,           updated.detectStateFromQr);
    await _prefs.setBool(_kAskOnStateChange,       updated.askOnStateChange);
    await _prefs.setBool(_kDailyReminder,          updated.dailyReminderEnabled);
    await _prefs.setInt(_kReminderHour,            updated.reminderHour);
    await _prefs.setInt(_kReminderMinute,          updated.reminderMinute);
    await _prefs.setBool(_kBudgetAlert,            updated.budgetAlertEnabled);
    await _prefs.setInt(_kBudgetAlertPercent,      updated.budgetAlertPercent);
    state = AsyncData(updated);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
