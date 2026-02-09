// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'program_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProgramData _$ProgramDataFromJson(Map<String, dynamic> json) {
  return _ProgramData.fromJson(json);
}

/// @nodoc
mixin _$ProgramData {
  /// WOD 타입 (AMRAP, ForTime, EMOM, Strength, Custom)
  String get type => throw _privateConstructorUsedError;

  /// 시간 제한 (분, nullable)
  int? get timeCap => throw _privateConstructorUsedError;

  /// 라운드 수 (nullable)
  int? get rounds => throw _privateConstructorUsedError;

  /// 운동 목록
  List<Movement> get movements => throw _privateConstructorUsedError;

  /// Serializes this ProgramData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgramData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgramDataCopyWith<ProgramData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgramDataCopyWith<$Res> {
  factory $ProgramDataCopyWith(
    ProgramData value,
    $Res Function(ProgramData) then,
  ) = _$ProgramDataCopyWithImpl<$Res, ProgramData>;
  @useResult
  $Res call({String type, int? timeCap, int? rounds, List<Movement> movements});
}

/// @nodoc
class _$ProgramDataCopyWithImpl<$Res, $Val extends ProgramData>
    implements $ProgramDataCopyWith<$Res> {
  _$ProgramDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgramData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? timeCap = freezed,
    Object? rounds = freezed,
    Object? movements = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            timeCap: freezed == timeCap
                ? _value.timeCap
                : timeCap // ignore: cast_nullable_to_non_nullable
                      as int?,
            rounds: freezed == rounds
                ? _value.rounds
                : rounds // ignore: cast_nullable_to_non_nullable
                      as int?,
            movements: null == movements
                ? _value.movements
                : movements // ignore: cast_nullable_to_non_nullable
                      as List<Movement>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgramDataImplCopyWith<$Res>
    implements $ProgramDataCopyWith<$Res> {
  factory _$$ProgramDataImplCopyWith(
    _$ProgramDataImpl value,
    $Res Function(_$ProgramDataImpl) then,
  ) = __$$ProgramDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, int? timeCap, int? rounds, List<Movement> movements});
}

/// @nodoc
class __$$ProgramDataImplCopyWithImpl<$Res>
    extends _$ProgramDataCopyWithImpl<$Res, _$ProgramDataImpl>
    implements _$$ProgramDataImplCopyWith<$Res> {
  __$$ProgramDataImplCopyWithImpl(
    _$ProgramDataImpl _value,
    $Res Function(_$ProgramDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgramData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? timeCap = freezed,
    Object? rounds = freezed,
    Object? movements = null,
  }) {
    return _then(
      _$ProgramDataImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        timeCap: freezed == timeCap
            ? _value.timeCap
            : timeCap // ignore: cast_nullable_to_non_nullable
                  as int?,
        rounds: freezed == rounds
            ? _value.rounds
            : rounds // ignore: cast_nullable_to_non_nullable
                  as int?,
        movements: null == movements
            ? _value._movements
            : movements // ignore: cast_nullable_to_non_nullable
                  as List<Movement>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgramDataImpl implements _ProgramData {
  const _$ProgramDataImpl({
    required this.type,
    this.timeCap,
    this.rounds,
    required final List<Movement> movements,
  }) : _movements = movements;

  factory _$ProgramDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgramDataImplFromJson(json);

  /// WOD 타입 (AMRAP, ForTime, EMOM, Strength, Custom)
  @override
  final String type;

  /// 시간 제한 (분, nullable)
  @override
  final int? timeCap;

  /// 라운드 수 (nullable)
  @override
  final int? rounds;

  /// 운동 목록
  final List<Movement> _movements;

  /// 운동 목록
  @override
  List<Movement> get movements {
    if (_movements is EqualUnmodifiableListView) return _movements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_movements);
  }

  @override
  String toString() {
    return 'ProgramData(type: $type, timeCap: $timeCap, rounds: $rounds, movements: $movements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgramDataImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timeCap, timeCap) || other.timeCap == timeCap) &&
            (identical(other.rounds, rounds) || other.rounds == rounds) &&
            const DeepCollectionEquality().equals(
              other._movements,
              _movements,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    timeCap,
    rounds,
    const DeepCollectionEquality().hash(_movements),
  );

  /// Create a copy of ProgramData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgramDataImplCopyWith<_$ProgramDataImpl> get copyWith =>
      __$$ProgramDataImplCopyWithImpl<_$ProgramDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgramDataImplToJson(this);
  }
}

abstract class _ProgramData implements ProgramData {
  const factory _ProgramData({
    required final String type,
    final int? timeCap,
    final int? rounds,
    required final List<Movement> movements,
  }) = _$ProgramDataImpl;

  factory _ProgramData.fromJson(Map<String, dynamic> json) =
      _$ProgramDataImpl.fromJson;

  /// WOD 타입 (AMRAP, ForTime, EMOM, Strength, Custom)
  @override
  String get type;

  /// 시간 제한 (분, nullable)
  @override
  int? get timeCap;

  /// 라운드 수 (nullable)
  @override
  int? get rounds;

  /// 운동 목록
  @override
  List<Movement> get movements;

  /// Create a copy of ProgramData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgramDataImplCopyWith<_$ProgramDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
