import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

@freezed
abstract class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required int id,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'product_code') String? productCode,
    required double quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    @JsonKey(name: 'total_price') required double totalPrice,
    String? category,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);
}

@freezed
abstract class Receipt with _$Receipt {
  const factory Receipt({
    required int id,
    @JsonKey(name: 'store_name') required String storeName,
    @JsonKey(name: 'merchant_id') String? merchantId,
    required DateTime date,
    @JsonKey(name: 'total_amount') required double totalAmount,
    double? taxes,
    @JsonKey(name: 'tax_state') double? taxState,
    @JsonKey(name: 'tax_federal') double? taxFederal,
    @JsonKey(name: 'qr_data') String? qrData,
    @JsonKey(name: 'access_key') String? accessKey,
    @Default([]) List<ReceiptItem> items,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
}
