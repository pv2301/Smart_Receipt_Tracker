// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetStatus _$BudgetStatusFromJson(Map<String, dynamic> json) =>
    _BudgetStatus(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      currentGoal: (json['currentGoal'] as num).toDouble(),
      isFixed: json['isFixed'] as bool,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentUsed: (json['percentUsed'] as num).toDouble(),
    );

Map<String, dynamic> _$BudgetStatusToJson(_BudgetStatus instance) =>
    <String, dynamic>{
      'month': instance.month,
      'year': instance.year,
      'currentGoal': instance.currentGoal,
      'isFixed': instance.isFixed,
      'totalSpent': instance.totalSpent,
      'remaining': instance.remaining,
      'percentUsed': instance.percentUsed,
    };
