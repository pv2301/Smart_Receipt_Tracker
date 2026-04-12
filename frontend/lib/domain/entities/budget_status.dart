import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_status.freezed.dart';
part 'budget_status.g.dart';

@freezed
abstract class BudgetStatus with _$BudgetStatus {
  const factory BudgetStatus({
    required int month,
    required int year,
    @JsonKey(name: 'current_goal') required double currentGoal,
    @JsonKey(name: 'is_fixed') required bool isFixed,
    @JsonKey(name: 'total_spent') required double totalSpent,
    required double remaining,
    @JsonKey(name: 'percent_used') required double percentUsed,
  }) = _BudgetStatus;

  factory BudgetStatus.fromJson(Map<String, dynamic> json) =>
      _$BudgetStatusFromJson(json);
}
