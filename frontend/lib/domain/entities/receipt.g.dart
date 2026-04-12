// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => _ReceiptItem(
  id: (json['id'] as num).toInt(),
  productName: json['product_name'] as String,
  productCode: json['product_code'] as String?,
  quantity: (json['quantity'] as num).toDouble(),
  unitPrice: (json['unit_price'] as num).toDouble(),
  totalPrice: (json['total_price'] as num).toDouble(),
  category: json['category'] as String?,
);

Map<String, dynamic> _$ReceiptItemToJson(_ReceiptItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_name': instance.productName,
      'product_code': instance.productCode,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_price': instance.totalPrice,
      'category': instance.category,
    };

_Receipt _$ReceiptFromJson(Map<String, dynamic> json) => _Receipt(
  id: (json['id'] as num).toInt(),
  storeName: json['store_name'] as String,
  merchantId: json['merchant_id'] as String?,
  date: DateTime.parse(json['date'] as String),
  totalAmount: (json['total_amount'] as num).toDouble(),
  taxes: (json['taxes'] as num?)?.toDouble(),
  qrData: json['qr_data'] as String?,
  accessKey: json['access_key'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ReceiptToJson(_Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'store_name': instance.storeName,
  'merchant_id': instance.merchantId,
  'date': instance.date.toIso8601String(),
  'total_amount': instance.totalAmount,
  'taxes': instance.taxes,
  'qr_data': instance.qrData,
  'access_key': instance.accessKey,
  'items': instance.items,
};
