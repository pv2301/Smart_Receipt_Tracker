// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => _Suggestion(
  productName: json['productName'] as String,
  category: json['category'] as String,
  avgIntervalDays: (json['avgIntervalDays'] as num).toDouble(),
  lastPurchaseDate: DateTime.parse(json['lastPurchaseDate'] as String),
  daysSinceLast: (json['daysSinceLast'] as num).toInt(),
  predictedNextDate: DateTime.parse(json['predictedNextDate'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$SuggestionToJson(_Suggestion instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'category': instance.category,
      'avgIntervalDays': instance.avgIntervalDays,
      'lastPurchaseDate': instance.lastPurchaseDate.toIso8601String(),
      'daysSinceLast': instance.daysSinceLast,
      'predictedNextDate': instance.predictedNextDate.toIso8601String(),
      'status': instance.status,
    };
