// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wod_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WodModel _$WodModelFromJson(Map<String, dynamic> json) {
  return _WodModel.fromJson(json);
}

/// @nodoc
mixin _$WodModel {
  /// WOD 고유 ID
  int get id => throw _privateConstructorUsedError;

  /// 박스 ID
  int get boxId => throw _privateConstructorUsedError;

  /// 날짜 (YYYY-MM-DD 형식)
  String get date => throw _privateConstructorUsedError;

  /// 프로그램 데이터
  ProgramData get programData => throw _privateConstructorUsedError;

  /// 원본 텍스트 (nullable)
  String? get rawText => throw _privateConstructorUsedError;

  /// Base WOD 여부
  bool get isBase => throw _privateConstructorUsedError;

  /// 등록자 ID
  int get createdBy => throw _privateConstructorUsedError;

  /// 등록자 닉네임 (nullable)
  String? get registeredBy => throw _privateConstructorUsedError;

  /// 선택 횟수 (nullable)
  int? get selectedCount => throw _privateConstructorUsedError;

  /// 생성 시간 (ISO 8601 형식)
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WodModelCopyWith<WodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WodModelCopyWith<$Res> {
  factory $WodModelCopyWith(WodModel value, $Res Function(WodModel) then) =
      _$WodModelCopyWithImpl<$Res, WodModel>;
  @useResult
  $Res call({
    int id,
    int boxId,
    String date,
    ProgramData programData,
    String? rawText,
    bool isBase,
    int createdBy,
    String? registeredBy,
    int? selectedCount,
    String createdAt,
  });

  $ProgramDataCopyWith<$Res> get programData;
}

/// @nodoc
class _$WodModelCopyWithImpl<$Res, $Val extends WodModel>
    implements $WodModelCopyWith<$Res> {
  _$WodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boxId = null,
    Object? date = null,
    Object? programData = null,
    Object? rawText = freezed,
    Object? isBase = null,
    Object? createdBy = null,
    Object? registeredBy = freezed,
    Object? selectedCount = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            boxId: null == boxId
                ? _value.boxId
                : boxId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            programData: null == programData
                ? _value.programData
                : programData // ignore: cast_nullable_to_non_nullable
                      as ProgramData,
            rawText: freezed == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String?,
            isBase: null == isBase
                ? _value.isBase
                : isBase // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as int,
            registeredBy: freezed == registeredBy
                ? _value.registeredBy
                : registeredBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedCount: freezed == selectedCount
                ? _value.selectedCount
                : selectedCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of WodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgramDataCopyWith<$Res> get programData {
    return $ProgramDataCopyWith<$Res>(_value.programData, (value) {
      return _then(_value.copyWith(programData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WodModelImplCopyWith<$Res>
    implements $WodModelCopyWith<$Res> {
  factory _$$WodModelImplCopyWith(
    _$WodModelImpl value,
    $Res Function(_$WodModelImpl) then,
  ) = __$$WodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int boxId,
    String date,
    ProgramData programData,
    String? rawText,
    bool isBase,
    int createdBy,
    String? registeredBy,
    int? selectedCount,
    String createdAt,
  });

  @override
  $ProgramDataCopyWith<$Res> get programData;
}

/// @nodoc
class __$$WodModelImplCopyWithImpl<$Res>
    extends _$WodModelCopyWithImpl<$Res, _$WodModelImpl>
    implements _$$WodModelImplCopyWith<$Res> {
  __$$WodModelImplCopyWithImpl(
    _$WodModelImpl _value,
    $Res Function(_$WodModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boxId = null,
    Object? date = null,
    Object? programData = null,
    Object? rawText = freezed,
    Object? isBase = null,
    Object? createdBy = null,
    Object? registeredBy = freezed,
    Object? selectedCount = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$WodModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        boxId: null == boxId
            ? _value.boxId
            : boxId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        programData: null == programData
            ? _value.programData
            : programData // ignore: cast_nullable_to_non_nullable
                  as ProgramData,
        rawText: freezed == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String?,
        isBase: null == isBase
            ? _value.isBase
            : isBase // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as int,
        registeredBy: freezed == registeredBy
            ? _value.registeredBy
            : registeredBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedCount: freezed == selectedCount
            ? _value.selectedCount
            : selectedCount // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$WodModelImpl implements _WodModel {
  const _$WodModelImpl({
    required this.id,
    required this.boxId,
    required this.date,
    required this.programData,
    this.rawText,
    required this.isBase,
    required this.createdBy,
    this.registeredBy,
    this.selectedCount,
    required this.createdAt,
  });

  factory _$WodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WodModelImplFromJson(json);

  /// WOD 고유 ID
  @override
  final int id;

  /// 박스 ID
  @override
  final int boxId;

  /// 날짜 (YYYY-MM-DD 형식)
  @override
  final String date;

  /// 프로그램 데이터
  @override
  final ProgramData programData;

  /// 원본 텍스트 (nullable)
  @override
  final String? rawText;

  /// Base WOD 여부
  @override
  final bool isBase;

  /// 등록자 ID
  @override
  final int createdBy;

  /// 등록자 닉네임 (nullable)
  @override
  final String? registeredBy;

  /// 선택 횟수 (nullable)
  @override
  final int? selectedCount;

  /// 생성 시간 (ISO 8601 형식)
  @override
  final String createdAt;

  @override
  String toString() {
    return 'WodModel(id: $id, boxId: $boxId, date: $date, programData: $programData, rawText: $rawText, isBase: $isBase, createdBy: $createdBy, registeredBy: $registeredBy, selectedCount: $selectedCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boxId, boxId) || other.boxId == boxId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.programData, programData) ||
                other.programData == programData) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.isBase, isBase) || other.isBase == isBase) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.registeredBy, registeredBy) ||
                other.registeredBy == registeredBy) &&
            (identical(other.selectedCount, selectedCount) ||
                other.selectedCount == selectedCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    boxId,
    date,
    programData,
    rawText,
    isBase,
    createdBy,
    registeredBy,
    selectedCount,
    createdAt,
  );

  /// Create a copy of WodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WodModelImplCopyWith<_$WodModelImpl> get copyWith =>
      __$$WodModelImplCopyWithImpl<_$WodModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WodModelImplToJson(this);
  }
}

abstract class _WodModel implements WodModel {
  const factory _WodModel({
    required final int id,
    required final int boxId,
    required final String date,
    required final ProgramData programData,
    final String? rawText,
    required final bool isBase,
    required final int createdBy,
    final String? registeredBy,
    final int? selectedCount,
    required final String createdAt,
  }) = _$WodModelImpl;

  factory _WodModel.fromJson(Map<String, dynamic> json) =
      _$WodModelImpl.fromJson;

  /// WOD 고유 ID
  @override
  int get id;

  /// 박스 ID
  @override
  int get boxId;

  /// 날짜 (YYYY-MM-DD 형식)
  @override
  String get date;

  /// 프로그램 데이터
  @override
  ProgramData get programData;

  /// 원본 텍스트 (nullable)
  @override
  String? get rawText;

  /// Base WOD 여부
  @override
  bool get isBase;

  /// 등록자 ID
  @override
  int get createdBy;

  /// 등록자 닉네임 (nullable)
  @override
  String? get registeredBy;

  /// 선택 횟수 (nullable)
  @override
  int? get selectedCount;

  /// 생성 시간 (ISO 8601 형식)
  @override
  String get createdAt;

  /// Create a copy of WodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WodModelImplCopyWith<_$WodModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
