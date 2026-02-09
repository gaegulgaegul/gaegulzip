// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WodSelectionModel _$WodSelectionModelFromJson(Map<String, dynamic> json) {
  return _WodSelectionModel.fromJson(json);
}

/// @nodoc
mixin _$WodSelectionModel {
  /// 선택 기록 ID
  int get id => throw _privateConstructorUsedError;

  /// 사용자 ID
  int get userId => throw _privateConstructorUsedError;

  /// 선택한 WOD ID
  int get wodId => throw _privateConstructorUsedError;

  /// 박스 ID
  int get boxId => throw _privateConstructorUsedError;

  /// 날짜 (YYYY-MM-DD 형식)
  String get date => throw _privateConstructorUsedError;

  /// 선택 시점의 WOD 스냅샷 (불변, JSONB 데이터)
  Map<String, dynamic> get snapshotData => throw _privateConstructorUsedError;

  /// 생성 시간 (ISO 8601 형식)
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WodSelectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WodSelectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WodSelectionModelCopyWith<WodSelectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WodSelectionModelCopyWith<$Res> {
  factory $WodSelectionModelCopyWith(
    WodSelectionModel value,
    $Res Function(WodSelectionModel) then,
  ) = _$WodSelectionModelCopyWithImpl<$Res, WodSelectionModel>;
  @useResult
  $Res call({
    int id,
    int userId,
    int wodId,
    int boxId,
    String date,
    Map<String, dynamic> snapshotData,
    String createdAt,
  });
}

/// @nodoc
class _$WodSelectionModelCopyWithImpl<$Res, $Val extends WodSelectionModel>
    implements $WodSelectionModelCopyWith<$Res> {
  _$WodSelectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WodSelectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? wodId = null,
    Object? boxId = null,
    Object? date = null,
    Object? snapshotData = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            wodId: null == wodId
                ? _value.wodId
                : wodId // ignore: cast_nullable_to_non_nullable
                      as int,
            boxId: null == boxId
                ? _value.boxId
                : boxId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            snapshotData: null == snapshotData
                ? _value.snapshotData
                : snapshotData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WodSelectionModelImplCopyWith<$Res>
    implements $WodSelectionModelCopyWith<$Res> {
  factory _$$WodSelectionModelImplCopyWith(
    _$WodSelectionModelImpl value,
    $Res Function(_$WodSelectionModelImpl) then,
  ) = __$$WodSelectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int userId,
    int wodId,
    int boxId,
    String date,
    Map<String, dynamic> snapshotData,
    String createdAt,
  });
}

/// @nodoc
class __$$WodSelectionModelImplCopyWithImpl<$Res>
    extends _$WodSelectionModelCopyWithImpl<$Res, _$WodSelectionModelImpl>
    implements _$$WodSelectionModelImplCopyWith<$Res> {
  __$$WodSelectionModelImplCopyWithImpl(
    _$WodSelectionModelImpl _value,
    $Res Function(_$WodSelectionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WodSelectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? wodId = null,
    Object? boxId = null,
    Object? date = null,
    Object? snapshotData = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$WodSelectionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        wodId: null == wodId
            ? _value.wodId
            : wodId // ignore: cast_nullable_to_non_nullable
                  as int,
        boxId: null == boxId
            ? _value.boxId
            : boxId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        snapshotData: null == snapshotData
            ? _value._snapshotData
            : snapshotData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WodSelectionModelImpl implements _WodSelectionModel {
  const _$WodSelectionModelImpl({
    required this.id,
    required this.userId,
    required this.wodId,
    required this.boxId,
    required this.date,
    required final Map<String, dynamic> snapshotData,
    required this.createdAt,
  }) : _snapshotData = snapshotData;

  factory _$WodSelectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WodSelectionModelImplFromJson(json);

  /// 선택 기록 ID
  @override
  final int id;

  /// 사용자 ID
  @override
  final int userId;

  /// 선택한 WOD ID
  @override
  final int wodId;

  /// 박스 ID
  @override
  final int boxId;

  /// 날짜 (YYYY-MM-DD 형식)
  @override
  final String date;

  /// 선택 시점의 WOD 스냅샷 (불변, JSONB 데이터)
  final Map<String, dynamic> _snapshotData;

  /// 선택 시점의 WOD 스냅샷 (불변, JSONB 데이터)
  @override
  Map<String, dynamic> get snapshotData {
    if (_snapshotData is EqualUnmodifiableMapView) return _snapshotData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_snapshotData);
  }

  /// 생성 시간 (ISO 8601 형식)
  @override
  final String createdAt;

  @override
  String toString() {
    return 'WodSelectionModel(id: $id, userId: $userId, wodId: $wodId, boxId: $boxId, date: $date, snapshotData: $snapshotData, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WodSelectionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.wodId, wodId) || other.wodId == wodId) &&
            (identical(other.boxId, boxId) || other.boxId == boxId) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._snapshotData,
              _snapshotData,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    wodId,
    boxId,
    date,
    const DeepCollectionEquality().hash(_snapshotData),
    createdAt,
  );

  /// Create a copy of WodSelectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WodSelectionModelImplCopyWith<_$WodSelectionModelImpl> get copyWith =>
      __$$WodSelectionModelImplCopyWithImpl<_$WodSelectionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WodSelectionModelImplToJson(this);
  }
}

abstract class _WodSelectionModel implements WodSelectionModel {
  const factory _WodSelectionModel({
    required final int id,
    required final int userId,
    required final int wodId,
    required final int boxId,
    required final String date,
    required final Map<String, dynamic> snapshotData,
    required final String createdAt,
  }) = _$WodSelectionModelImpl;

  factory _WodSelectionModel.fromJson(Map<String, dynamic> json) =
      _$WodSelectionModelImpl.fromJson;

  /// 선택 기록 ID
  @override
  int get id;

  /// 사용자 ID
  @override
  int get userId;

  /// 선택한 WOD ID
  @override
  int get wodId;

  /// 박스 ID
  @override
  int get boxId;

  /// 날짜 (YYYY-MM-DD 형식)
  @override
  String get date;

  /// 선택 시점의 WOD 스냅샷 (불변, JSONB 데이터)
  @override
  Map<String, dynamic> get snapshotData;

  /// 생성 시간 (ISO 8601 형식)
  @override
  String get createdAt;

  /// Create a copy of WodSelectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WodSelectionModelImplCopyWith<_$WodSelectionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
