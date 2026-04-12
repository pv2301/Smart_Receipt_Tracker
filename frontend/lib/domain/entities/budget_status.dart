import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_status.freezed.dart';
part 'budget_status.g.dart';

@freezed
abstract class BudgetStatus with _$BudgetStatus {
  const factory BudgetStatus({
    required int month,
    required int year,
    required double currentGoal,
    required bool isFixed,
    required double totalSpent,
    required double remaining,
    required double percentUsed,
  }) = _BudgetStatus;

  factory BudgetStatus.fromJson(Map<String, dynamic> json) =>
      _$BudgetStatusFromJson(json);
}
