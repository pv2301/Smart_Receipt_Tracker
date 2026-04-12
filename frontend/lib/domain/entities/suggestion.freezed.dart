// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Suggestion {

 String get productName; String get category; double get avgIntervalDays; DateTime get lastPurchaseDate; int get daysSinceLast; DateTime get predictedNextDate; String get status;
/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestionCopyWith<Suggestion> get copyWith => _$SuggestionCopyWithImpl<Suggestion>(this as Suggestion, _$identity);

  /// Serializes this Suggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Suggestion&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.category, category) || other.category == category)&&(identical(other.avgIntervalDays, avgIntervalDays) || other.avgIntervalDays == avgIntervalDays)&&(identical(other.lastPurchaseDate, lastPurchaseDate) || other.lastPurchaseDate == lastPurchaseDate)&&(identical(other.daysSinceLast, daysSinceLast) || other.daysSinceLast == daysSinceLast)&&(identical(other.predictedNextDate, predictedNextDate) || other.predictedNextDate == predictedNextDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,category,avgIntervalDays,lastPurchaseDate,daysSinceLast,predictedNextDate,status);

@override
String toString() {
  return 'Suggestion(productName: $productName, category: $category, avgIntervalDays: $avgIntervalDays, lastPurchaseDate: $lastPurchaseDate, daysSinceLast: $daysSinceLast, predictedNextDate: $predictedNextDate, status: $status)';
}


}

/// @nodoc
abstract mixin class $SuggestionCopyWith<$Res>  {
  factory $SuggestionCopyWith(Suggestion value, $Res Function(Suggestion) _then) = _$SuggestionCopyWithImpl;
@useResult
$Res call({
 String productName, String category, double avgIntervalDays, DateTime lastPurchaseDate, int daysSinceLast, DateTime predictedNextDate, String status
});




}
/// @nodoc
class _$SuggestionCopyWithImpl<$Res>
    implements $SuggestionCopyWith<$Res> {
  _$SuggestionCopyWithImpl(this._self, this._then);

  final Suggestion _self;
  final $Res Function(Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productName = null,Object? category = null,Object? avgIntervalDays = null,Object? lastPurchaseDate = null,Object? daysSinceLast = null,Object? predictedNextDate = null,Object? status = null,}) {
  return _then(_self.copyWith(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,avgIntervalDays: null == avgIntervalDays ? _self.avgIntervalDays : avgIntervalDays // ignore: cast_nullable_to_non_nullable
as double,lastPurchaseDate: null == lastPurchaseDate ? _self.lastPurchaseDate : lastPurchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,daysSinceLast: null == daysSinceLast ? _self.daysSinceLast : daysSinceLast // ignore: cast_nullable_to_non_nullable
as int,predictedNextDate: null == predictedNextDate ? _self.predictedNextDate : predictedNextDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Suggestion].
extension SuggestionPatterns on Suggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Suggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Suggestion value)  $default,){
final _that = this;
switch (_that) {
case _Suggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Suggestion value)?  $default,){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productName,  String category,  double avgIntervalDays,  DateTime lastPurchaseDate,  int daysSinceLast,  DateTime predictedNextDate,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.productName,_that.category,_that.avgIntervalDays,_that.lastPurchaseDate,_that.daysSinceLast,_that.predictedNextDate,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productName,  String category,  double avgIntervalDays,  DateTime lastPurchaseDate,  int daysSinceLast,  DateTime predictedNextDate,  String status)  $default,) {final _that = this;
switch (_that) {
case _Suggestion():
return $default(_that.productName,_that.category,_that.avgIntervalDays,_that.lastPurchaseDate,_that.daysSinceLast,_that.predictedNextDate,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productName,  String category,  double avgIntervalDays,  DateTime lastPurchaseDate,  int daysSinceLast,  DateTime predictedNextDate,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.productName,_that.category,_that.avgIntervalDays,_that.lastPurchaseDate,_that.daysSinceLast,_that.predictedNextDate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Suggestion implements Suggestion {
  const _Suggestion({required this.productName, required this.category, required this.avgIntervalDays, required this.lastPurchaseDate, required this.daysSinceLast, required this.predictedNextDate, required this.status});
  factory _Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);

@override final  String productName;
@override final  String category;
@override final  double avgIntervalDays;
@override final  DateTime lastPurchaseDate;
@override final  int daysSinceLast;
@override final  DateTime predictedNextDate;
@override final  String status;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestionCopyWith<_Suggestion> get copyWith => __$SuggestionCopyWithImpl<_Suggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Suggestion&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.category, category) || other.category == category)&&(identical(other.avgIntervalDays, avgIntervalDays) || other.avgIntervalDays == avgIntervalDays)&&(identical(other.lastPurchaseDate, lastPurchaseDate) || other.lastPurchaseDate == lastPurchaseDate)&&(identical(other.daysSinceLast, daysSinceLast) || other.daysSinceLast == daysSinceLast)&&(identical(other.predictedNextDate, predictedNextDate) || other.predictedNextDate == predictedNextDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,category,avgIntervalDays,lastPurchaseDate,daysSinceLast,predictedNextDate,status);

@override
String toString() {
  return 'Suggestion(productName: $productName, category: $category, avgIntervalDays: $avgIntervalDays, lastPurchaseDate: $lastPurchaseDate, daysSinceLast: $daysSinceLast, predictedNextDate: $predictedNextDate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SuggestionCopyWith<$Res> implements $SuggestionCopyWith<$Res> {
  factory _$SuggestionCopyWith(_Suggestion value, $Res Function(_Suggestion) _then) = __$SuggestionCopyWithImpl;
@override @useResult
$Res call({
 String productName, String category, double avgIntervalDays, DateTime lastPurchaseDate, int daysSinceLast, DateTime predictedNextDate, String status
});




}
/// @nodoc
class __$SuggestionCopyWithImpl<$Res>
    implements _$SuggestionCopyWith<$Res> {
  __$SuggestionCopyWithImpl(this._self, this._then);

  final _Suggestion _self;
  final $Res Function(_Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productName = null,Object? category = null,Object? avgIntervalDays = null,Object? lastPurchaseDate = null,Object? daysSinceLast = null,Object? predictedNextDate = null,Object? status = null,}) {
  return _then(_Suggestion(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,avgIntervalDays: null == avgIntervalDays ? _self.avgIntervalDays : avgIntervalDays // ignore: cast_nullable_to_non_nullable
as double,lastPurchaseDate: null == lastPurchaseDate ? _self.lastPurchaseDate : lastPurchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,daysSinceLast: null == daysSinceLast ? _self.daysSinceLast : daysSinceLast // ignore: cast_nullable_to_non_nullable
as int,predictedNextDate: null == predictedNextDate ? _self.predictedNextDate : predictedNextDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
