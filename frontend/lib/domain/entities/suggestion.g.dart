// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => _Suggestion(
  productName: json['product_name'] as String,
  category: json['category'] as String,
  avgIntervalDays: (json['avg_interval_days'] as num).toDouble(),
  lastPurchaseDate: DateTime.parse(json['last_purchase_date'] as String),
  daysSinceLast: (json['days_since_last'] as num).toInt(),
  predictedNextDate: DateTime.parse(json['predicted_next_date'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$SuggestionToJson(_Suggestion instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'category': instance.category,
      'avg_interval_days': instance.avgIntervalDays,
      'last_purchase_date': instance.lastPurchaseDate.toIso8601String(),
      'days_since_last': instance.daysSinceLast,
      'predicted_next_date': instance.predictedNextDate.toIso8601String(),
      'status': instance.status,
    };
