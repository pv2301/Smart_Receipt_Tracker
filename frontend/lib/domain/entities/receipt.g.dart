// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => _ReceiptItem(
  id: (json['id'] as num).toInt(),
  productName: json['productName'] as String,
  productCode: json['productCode'] as String?,
  quantity: (json['quantity'] as num).toDouble(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  category: json['category'] as String?,
);

Map<String, dynamic> _$ReceiptItemToJson(_ReceiptItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'productCode': instance.productCode,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'category': instance.category,
    };

_Receipt _$ReceiptFromJson(Map<String, dynamic> json) => _Receipt(
  id: (json['id'] as num).toInt(),
  storeName: json['storeName'] as String,
  merchantId: json['merchantId'] as String?,
  date: DateTime.parse(json['date'] as String),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  taxes: (json['taxes'] as num?)?.toDouble(),
  qrData: json['qrData'] as String?,
  accessKey: json['accessKey'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ReceiptToJson(_Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'storeName': instance.storeName,
  'merchantId': instance.merchantId,
  'date': instance.date.toIso8601String(),
  'totalAmount': instance.totalAmount,
  'taxes': instance.taxes,
  'qrData': instance.qrData,
  'accessKey': instance.accessKey,
  'items': instance.items,
};
