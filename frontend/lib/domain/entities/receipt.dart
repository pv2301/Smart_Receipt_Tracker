import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

@freezed
abstract class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required int id,
    required String productName,
    String? productCode,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
    String? category,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);
}

@freezed
abstract class Receipt with _$Receipt {
  const factory Receipt({
    required int id,
    required String storeName,
    String? merchantId,
    required DateTime date,
    required double totalAmount,
    double? taxes,
    String? qrData,
    String? accessKey,
    @Default([]) List<ReceiptItem> items,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
}
