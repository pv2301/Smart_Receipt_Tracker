// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetStatus _$BudgetStatusFromJson(Map<String, dynamic> json) =>
    _BudgetStatus(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      currentGoal: (json['current_goal'] as num).toDouble(),
      isFixed: json['is_fixed'] as bool,
      totalSpent: (json['total_spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentUsed: (json['percent_used'] as num).toDouble(),
    );

Map<String, dynamic> _$BudgetStatusToJson(_BudgetStatus instance) =>
    <String, dynamic>{
      'month': instance.month,
      'year': instance.year,
      'current_goal': instance.currentGoal,
      'is_fixed': instance.isFixed,
      'total_spent': instance.totalSpent,
      'remaining': instance.remaining,
      'percent_used': instance.percentUsed,
    };
