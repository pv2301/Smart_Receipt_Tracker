// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReceiptItem {

 int get id; String get productName; String? get productCode; double get quantity; double get unitPrice; double get totalPrice; String? get category;
/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptItemCopyWith<ReceiptItem> get copyWith => _$ReceiptItemCopyWithImpl<ReceiptItem>(this as ReceiptItem, _$identity);

  /// Serializes this ReceiptItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName,productCode,quantity,unitPrice,totalPrice,category);

@override
String toString() {
  return 'ReceiptItem(id: $id, productName: $productName, productCode: $productCode, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, category: $category)';
}


}

/// @nodoc
abstract mixin class $ReceiptItemCopyWith<$Res>  {
  factory $ReceiptItemCopyWith(ReceiptItem value, $Res Function(ReceiptItem) _then) = _$ReceiptItemCopyWithImpl;
@useResult
$Res call({
 int id, String productName, String? productCode, double quantity, double unitPrice, double totalPrice, String? category
});




}
/// @nodoc
class _$ReceiptItemCopyWithImpl<$Res>
    implements $ReceiptItemCopyWith<$Res> {
  _$ReceiptItemCopyWithImpl(this._self, this._then);

  final ReceiptItem _self;
  final $Res Function(ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productName = null,Object? productCode = freezed,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? category = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptItem].
extension ReceiptItemPatterns on ReceiptItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptItem value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String productName,  String? productCode,  double quantity,  double unitPrice,  double totalPrice,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.id,_that.productName,_that.productCode,_that.quantity,_that.unitPrice,_that.totalPrice,_that.category);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String productName,  String? productCode,  double quantity,  double unitPrice,  double totalPrice,  String? category)  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem():
return $default(_that.id,_that.productName,_that.productCode,_that.quantity,_that.unitPrice,_that.totalPrice,_that.category);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String productName,  String? productCode,  double quantity,  double unitPrice,  double totalPrice,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptItem() when $default != null:
return $default(_that.id,_that.productName,_that.productCode,_that.quantity,_that.unitPrice,_that.totalPrice,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiptItem implements ReceiptItem {
  const _ReceiptItem({required this.id, required this.productName, this.productCode, required this.quantity, required this.unitPrice, required this.totalPrice, this.category});
  factory _ReceiptItem.fromJson(Map<String, dynamic> json) => _$ReceiptItemFromJson(json);

@override final  int id;
@override final  String productName;
@override final  String? productCode;
@override final  double quantity;
@override final  double unitPrice;
@override final  double totalPrice;
@override final  String? category;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptItemCopyWith<_ReceiptItem> get copyWith => __$ReceiptItemCopyWithImpl<_ReceiptItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName,productCode,quantity,unitPrice,totalPrice,category);

@override
String toString() {
  return 'ReceiptItem(id: $id, productName: $productName, productCode: $productCode, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ReceiptItemCopyWith<$Res> implements $ReceiptItemCopyWith<$Res> {
  factory _$ReceiptItemCopyWith(_ReceiptItem value, $Res Function(_ReceiptItem) _then) = __$ReceiptItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String productName, String? productCode, double quantity, double unitPrice, double totalPrice, String? category
});




}
/// @nodoc
class __$ReceiptItemCopyWithImpl<$Res>
    implements _$ReceiptItemCopyWith<$Res> {
  __$ReceiptItemCopyWithImpl(this._self, this._then);

  final _ReceiptItem _self;
  final $Res Function(_ReceiptItem) _then;

/// Create a copy of ReceiptItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productName = null,Object? productCode = freezed,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? category = freezed,}) {
  return _then(_ReceiptItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Receipt {

 int get id; String get storeName; String? get merchantId; DateTime get date; double get totalAmount; double? get taxes; String? get qrData; String? get accessKey; List<ReceiptItem> get items;
/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptCopyWith<Receipt> get copyWith => _$ReceiptCopyWithImpl<Receipt>(this as Receipt, _$identity);

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.date, date) || other.date == date)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.taxes, taxes) || other.taxes == taxes)&&(identical(other.qrData, qrData) || other.qrData == qrData)&&(identical(other.accessKey, accessKey) || other.accessKey == accessKey)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeName,merchantId,date,totalAmount,taxes,qrData,accessKey,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Receipt(id: $id, storeName: $storeName, merchantId: $merchantId, date: $date, totalAmount: $totalAmount, taxes: $taxes, qrData: $qrData, accessKey: $accessKey, items: $items)';
}


}

/// @nodoc
abstract mixin class $ReceiptCopyWith<$Res>  {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) _then) = _$ReceiptCopyWithImpl;
@useResult
$Res call({
 int id, String storeName, String? merchantId, DateTime date, double totalAmount, double? taxes, String? qrData, String? accessKey, List<ReceiptItem> items
});




}
/// @nodoc
class _$ReceiptCopyWithImpl<$Res>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._self, this._then);

  final Receipt _self;
  final $Res Function(Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeName = null,Object? merchantId = freezed,Object? date = null,Object? totalAmount = null,Object? taxes = freezed,Object? qrData = freezed,Object? accessKey = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,merchantId: freezed == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,taxes: freezed == taxes ? _self.taxes : taxes // ignore: cast_nullable_to_non_nullable
as double?,qrData: freezed == qrData ? _self.qrData : qrData // ignore: cast_nullable_to_non_nullable
as String?,accessKey: freezed == accessKey ? _self.accessKey : accessKey // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Receipt].
extension ReceiptPatterns on Receipt {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Receipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Receipt value)  $default,){
final _that = this;
switch (_that) {
case _Receipt():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Receipt value)?  $default,){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String storeName,  String? merchantId,  DateTime date,  double totalAmount,  double? taxes,  String? qrData,  String? accessKey,  List<ReceiptItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.storeName,_that.merchantId,_that.date,_that.totalAmount,_that.taxes,_that.qrData,_that.accessKey,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String storeName,  String? merchantId,  DateTime date,  double totalAmount,  double? taxes,  String? qrData,  String? accessKey,  List<ReceiptItem> items)  $default,) {final _that = this;
switch (_that) {
case _Receipt():
return $default(_that.id,_that.storeName,_that.merchantId,_that.date,_that.totalAmount,_that.taxes,_that.qrData,_that.accessKey,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String storeName,  String? merchantId,  DateTime date,  double totalAmount,  double? taxes,  String? qrData,  String? accessKey,  List<ReceiptItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.storeName,_that.merchantId,_that.date,_that.totalAmount,_that.taxes,_that.qrData,_that.accessKey,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receipt implements Receipt {
  const _Receipt({required this.id, required this.storeName, this.merchantId, required this.date, required this.totalAmount, this.taxes, this.qrData, this.accessKey, final  List<ReceiptItem> items = const []}): _items = items;
  factory _Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);

@override final  int id;
@override final  String storeName;
@override final  String? merchantId;
@override final  DateTime date;
@override final  double totalAmount;
@override final  double? taxes;
@override final  String? qrData;
@override final  String? accessKey;
 final  List<ReceiptItem> _items;
@override@JsonKey() List<ReceiptItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptCopyWith<_Receipt> get copyWith => __$ReceiptCopyWithImpl<_Receipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.date, date) || other.date == date)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.taxes, taxes) || other.taxes == taxes)&&(identical(other.qrData, qrData) || other.qrData == qrData)&&(identical(other.accessKey, accessKey) || other.accessKey == accessKey)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeName,merchantId,date,totalAmount,taxes,qrData,accessKey,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Receipt(id: $id, storeName: $storeName, merchantId: $merchantId, date: $date, totalAmount: $totalAmount, taxes: $taxes, qrData: $qrData, accessKey: $accessKey, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ReceiptCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$ReceiptCopyWith(_Receipt value, $Res Function(_Receipt) _then) = __$ReceiptCopyWithImpl;
@override @useResult
$Res call({
 int id, String storeName, String? merchantId, DateTime date, double totalAmount, double? taxes, String? qrData, String? accessKey, List<ReceiptItem> items
});




}
/// @nodoc
class __$ReceiptCopyWithImpl<$Res>
    implements _$ReceiptCopyWith<$Res> {
  __$ReceiptCopyWithImpl(this._self, this._then);

  final _Receipt _self;
  final $Res Function(_Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeName = null,Object? merchantId = freezed,Object? date = null,Object? totalAmount = null,Object? taxes = freezed,Object? qrData = freezed,Object? accessKey = freezed,Object? items = null,}) {
  return _then(_Receipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,merchantId: freezed == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,taxes: freezed == taxes ? _self.taxes : taxes // ignore: cast_nullable_to_non_nullable
as double?,qrData: freezed == qrData ? _self.qrData : qrData // ignore: cast_nullable_to_non_nullable
as String?,accessKey: freezed == accessKey ? _self.accessKey : accessKey // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,
  ));
}


}

// dart format on
