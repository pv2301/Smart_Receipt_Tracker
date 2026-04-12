// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetStatus {

 int get month; int get year; double get currentGoal; bool get isFixed; double get totalSpent; double get remaining; double get percentUsed;
/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<BudgetStatus> get copyWith => _$BudgetStatusCopyWithImpl<BudgetStatus>(this as BudgetStatus, _$identity);

  /// Serializes this BudgetStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetStatus&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.currentGoal, currentGoal) || other.currentGoal == currentGoal)&&(identical(other.isFixed, isFixed) || other.isFixed == isFixed)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.percentUsed, percentUsed) || other.percentUsed == percentUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,currentGoal,isFixed,totalSpent,remaining,percentUsed);

@override
String toString() {
  return 'BudgetStatus(month: $month, year: $year, currentGoal: $currentGoal, isFixed: $isFixed, totalSpent: $totalSpent, remaining: $remaining, percentUsed: $percentUsed)';
}


}

/// @nodoc
abstract mixin class $BudgetStatusCopyWith<$Res>  {
  factory $BudgetStatusCopyWith(BudgetStatus value, $Res Function(BudgetStatus) _then) = _$BudgetStatusCopyWithImpl;
@useResult
$Res call({
 int month, int year, double currentGoal, bool isFixed, double totalSpent, double remaining, double percentUsed
});




}
/// @nodoc
class _$BudgetStatusCopyWithImpl<$Res>
    implements $BudgetStatusCopyWith<$Res> {
  _$BudgetStatusCopyWithImpl(this._self, this._then);

  final BudgetStatus _self;
  final $Res Function(BudgetStatus) _then;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? currentGoal = null,Object? isFixed = null,Object? totalSpent = null,Object? remaining = null,Object? percentUsed = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,currentGoal: null == currentGoal ? _self.currentGoal : currentGoal // ignore: cast_nullable_to_non_nullable
as double,isFixed: null == isFixed ? _self.isFixed : isFixed // ignore: cast_nullable_to_non_nullable
as bool,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double,percentUsed: null == percentUsed ? _self.percentUsed : percentUsed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetStatus].
extension BudgetStatusPatterns on BudgetStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetStatus value)  $default,){
final _that = this;
switch (_that) {
case _BudgetStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetStatus value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int month,  int year,  double currentGoal,  bool isFixed,  double totalSpent,  double remaining,  double percentUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
return $default(_that.month,_that.year,_that.currentGoal,_that.isFixed,_that.totalSpent,_that.remaining,_that.percentUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int month,  int year,  double currentGoal,  bool isFixed,  double totalSpent,  double remaining,  double percentUsed)  $default,) {final _that = this;
switch (_that) {
case _BudgetStatus():
return $default(_that.month,_that.year,_that.currentGoal,_that.isFixed,_that.totalSpent,_that.remaining,_that.percentUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int month,  int year,  double currentGoal,  bool isFixed,  double totalSpent,  double remaining,  double percentUsed)?  $default,) {final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
return $default(_that.month,_that.year,_that.currentGoal,_that.isFixed,_that.totalSpent,_that.remaining,_that.percentUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetStatus implements BudgetStatus {
  const _BudgetStatus({required this.month, required this.year, required this.currentGoal, required this.isFixed, required this.totalSpent, required this.remaining, required this.percentUsed});
  factory _BudgetStatus.fromJson(Map<String, dynamic> json) => _$BudgetStatusFromJson(json);

@override final  int month;
@override final  int year;
@override final  double currentGoal;
@override final  bool isFixed;
@override final  double totalSpent;
@override final  double remaining;
@override final  double percentUsed;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetStatusCopyWith<_BudgetStatus> get copyWith => __$BudgetStatusCopyWithImpl<_BudgetStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetStatus&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.currentGoal, currentGoal) || other.currentGoal == currentGoal)&&(identical(other.isFixed, isFixed) || other.isFixed == isFixed)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.percentUsed, percentUsed) || other.percentUsed == percentUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,currentGoal,isFixed,totalSpent,remaining,percentUsed);

@override
String toString() {
  return 'BudgetStatus(month: $month, year: $year, currentGoal: $currentGoal, isFixed: $isFixed, totalSpent: $totalSpent, remaining: $remaining, percentUsed: $percentUsed)';
}


}

/// @nodoc
abstract mixin class _$BudgetStatusCopyWith<$Res> implements $BudgetStatusCopyWith<$Res> {
  factory _$BudgetStatusCopyWith(_BudgetStatus value, $Res Function(_BudgetStatus) _then) = __$BudgetStatusCopyWithImpl;
@override @useResult
$Res call({
 int month, int year, double currentGoal, bool isFixed, double totalSpent, double remaining, double percentUsed
});




}
/// @nodoc
class __$BudgetStatusCopyWithImpl<$Res>
    implements _$BudgetStatusCopyWith<$Res> {
  __$BudgetStatusCopyWithImpl(this._self, this._then);

  final _BudgetStatus _self;
  final $Res Function(_BudgetStatus) _then;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? currentGoal = null,Object? isFixed = null,Object? totalSpent = null,Object? remaining = null,Object? percentUsed = null,}) {
  return _then(_BudgetStatus(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,currentGoal: null == currentGoal ? _self.currentGoal : currentGoal // ignore: cast_nullable_to_non_nullable
as double,isFixed: null == isFixed ? _self.isFixed : isFixed // ignore: cast_nullable_to_non_nullable
as bool,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as double,percentUsed: null == percentUsed ? _self.percentUsed : percentUsed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
