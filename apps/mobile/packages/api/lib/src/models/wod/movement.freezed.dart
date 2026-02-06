// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Movement _$MovementFromJson(Map<String, dynamic> json) {
  return _Movement.fromJson(json);
}

/// @nodoc
mixin _$Movement {
  /// 운동 이름
  String get name => throw _privateConstructorUsedError;

  /// 반복 횟수 (nullable)
  int? get reps => throw _privateConstructorUsedError;

  /// 무게 (nullable)
  double? get weight => throw _privateConstructorUsedError;

  /// 단위 (kg, lb, bw 등, nullable)
  String? get unit => throw _privateConstructorUsedError;

  /// Serializes this Movement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Movement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovementCopyWith<Movement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovementCopyWith<$Res> {
  factory $MovementCopyWith(Movement value, $Res Function(Movement) then) =
      _$MovementCopyWithImpl<$Res, Movement>;
  @useResult
  $Res call({String name, int? reps, double? weight, String? unit});
}

/// @nodoc
class _$MovementCopyWithImpl<$Res, $Val extends Movement>
    implements $MovementCopyWith<$Res> {
  _$MovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Movement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? reps = freezed,
    Object? weight = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            reps: freezed == reps
                ? _value.reps
                : reps // ignore: cast_nullable_to_non_nullable
                      as int?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovementImplCopyWith<$Res>
    implements $MovementCopyWith<$Res> {
  factory _$$MovementImplCopyWith(
    _$MovementImpl value,
    $Res Function(_$MovementImpl) then,
  ) = __$$MovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int? reps, double? weight, String? unit});
}

/// @nodoc
class __$$MovementImplCopyWithImpl<$Res>
    extends _$MovementCopyWithImpl<$Res, _$MovementImpl>
    implements _$$MovementImplCopyWith<$Res> {
  __$$MovementImplCopyWithImpl(
    _$MovementImpl _value,
    $Res Function(_$MovementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Movement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? reps = freezed,
    Object? weight = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _$MovementImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        reps: freezed == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as int?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovementImpl implements _Movement {
  const _$MovementImpl({required this.name, this.reps, this.weight, this.unit});

  factory _$MovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovementImplFromJson(json);

  /// 운동 이름
  @override
  final String name;

  /// 반복 횟수 (nullable)
  @override
  final int? reps;

  /// 무게 (nullable)
  @override
  final double? weight;

  /// 단위 (kg, lb, bw 등, nullable)
  @override
  final String? unit;

  @override
  String toString() {
    return 'Movement(name: $name, reps: $reps, weight: $weight, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovementImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, reps, weight, unit);

  /// Create a copy of Movement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovementImplCopyWith<_$MovementImpl> get copyWith =>
      __$$MovementImplCopyWithImpl<_$MovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MovementImplToJson(this);
  }
}

abstract class _Movement implements Movement {
  const factory _Movement({
    required final String name,
    final int? reps,
    final double? weight,
    final String? unit,
  }) = _$MovementImpl;

  factory _Movement.fromJson(Map<String, dynamic> json) =
      _$MovementImpl.fromJson;

  /// 운동 이름
  @override
  String get name;

  /// 반복 횟수 (nullable)
  @override
  int? get reps;

  /// 무게 (nullable)
  @override
  double? get weight;

  /// 단위 (kg, lb, bw 등, nullable)
  @override
  String? get unit;

  /// Create a copy of Movement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovementImplCopyWith<_$MovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
