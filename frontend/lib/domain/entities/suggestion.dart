import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggestion.freezed.dart';
part 'suggestion.g.dart';

@freezed
abstract class Suggestion with _$Suggestion {
  const factory Suggestion({
    required String productName,
    required String category,
    required double avgIntervalDays,
    required DateTime lastPurchaseDate,
    required int daysSinceLast,
    required DateTime predictedNextDate,
    required String status,
  }) = _Suggestion;

  factory Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);
}
