import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggestion.freezed.dart';
part 'suggestion.g.dart';

@freezed
abstract class Suggestion with _$Suggestion {
  const factory Suggestion({
    @JsonKey(name: 'product_name') required String productName,
    required String category,
    @JsonKey(name: 'avg_interval_days') required double avgIntervalDays,
    @JsonKey(name: 'last_purchase_date') required DateTime lastPurchaseDate,
    @JsonKey(name: 'days_since_last') required int daysSinceLast,
    @JsonKey(name: 'predicted_next_date') required DateTime predictedNextDate,
    required String status,
  }) = _Suggestion;

  factory Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);
}
