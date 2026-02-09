// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proposal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProposalModel _$ProposalModelFromJson(Map<String, dynamic> json) {
  return _ProposalModel.fromJson(json);
}

/// @nodoc
mixin _$ProposalModel {
  /// 제안 고유 ID
  int get id => throw _privateConstructorUsedError;

  /// 기존 Base WOD ID
  int get baseWodId => throw _privateConstructorUsedError;

  /// 제안된 WOD ID
  int get proposedWodId => throw _privateConstructorUsedError;

  /// 상태 (pending, approved, rejected)
  String get status => throw _privateConstructorUsedError;

  /// 제안 시간 (ISO 8601 형식)
  String get proposedAt => throw _privateConstructorUsedError;

  /// 처리 시간 (ISO 8601 형식, nullable)
  String? get resolvedAt => throw _privateConstructorUsedError;

  /// 처리자 ID (nullable)
  int? get resolvedBy => throw _privateConstructorUsedError;

  /// Serializes this ProposalModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProposalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProposalModelCopyWith<ProposalModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProposalModelCopyWith<$Res> {
  factory $ProposalModelCopyWith(
    ProposalModel value,
    $Res Function(ProposalModel) then,
  ) = _$ProposalModelCopyWithImpl<$Res, ProposalModel>;
  @useResult
  $Res call({
    int id,
    int baseWodId,
    int proposedWodId,
    String status,
    String proposedAt,
    String? resolvedAt,
    int? resolvedBy,
  });
}

/// @nodoc
class _$ProposalModelCopyWithImpl<$Res, $Val extends ProposalModel>
    implements $ProposalModelCopyWith<$Res> {
  _$ProposalModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProposalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? baseWodId = null,
    Object? proposedWodId = null,
    Object? status = null,
    Object? proposedAt = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            baseWodId: null == baseWodId
                ? _value.baseWodId
                : baseWodId // ignore: cast_nullable_to_non_nullable
                      as int,
            proposedWodId: null == proposedWodId
                ? _value.proposedWodId
                : proposedWodId // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            proposedAt: null == proposedAt
                ? _value.proposedAt
                : proposedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolvedBy: freezed == resolvedBy
                ? _value.resolvedBy
                : resolvedBy // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProposalModelImplCopyWith<$Res>
    implements $ProposalModelCopyWith<$Res> {
  factory _$$ProposalModelImplCopyWith(
    _$ProposalModelImpl value,
    $Res Function(_$ProposalModelImpl) then,
  ) = __$$ProposalModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int baseWodId,
    int proposedWodId,
    String status,
    String proposedAt,
    String? resolvedAt,
    int? resolvedBy,
  });
}

/// @nodoc
class __$$ProposalModelImplCopyWithImpl<$Res>
    extends _$ProposalModelCopyWithImpl<$Res, _$ProposalModelImpl>
    implements _$$ProposalModelImplCopyWith<$Res> {
  __$$ProposalModelImplCopyWithImpl(
    _$ProposalModelImpl _value,
    $Res Function(_$ProposalModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProposalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? baseWodId = null,
    Object? proposedWodId = null,
    Object? status = null,
    Object? proposedAt = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(
      _$ProposalModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        baseWodId: null == baseWodId
            ? _value.baseWodId
            : baseWodId // ignore: cast_nullable_to_non_nullable
                  as int,
        proposedWodId: null == proposedWodId
            ? _value.proposedWodId
            : proposedWodId // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        proposedAt: null == proposedAt
            ? _value.proposedAt
            : proposedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolvedBy: freezed == resolvedBy
            ? _value.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProposalModelImpl implements _ProposalModel {
  const _$ProposalModelImpl({
    required this.id,
    required this.baseWodId,
    required this.proposedWodId,
    required this.status,
    required this.proposedAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory _$ProposalModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProposalModelImplFromJson(json);

  /// 제안 고유 ID
  @override
  final int id;

  /// 기존 Base WOD ID
  @override
  final int baseWodId;

  /// 제안된 WOD ID
  @override
  final int proposedWodId;

  /// 상태 (pending, approved, rejected)
  @override
  final String status;

  /// 제안 시간 (ISO 8601 형식)
  @override
  final String proposedAt;

  /// 처리 시간 (ISO 8601 형식, nullable)
  @override
  final String? resolvedAt;

  /// 처리자 ID (nullable)
  @override
  final int? resolvedBy;

  @override
  String toString() {
    return 'ProposalModel(id: $id, baseWodId: $baseWodId, proposedWodId: $proposedWodId, status: $status, proposedAt: $proposedAt, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProposalModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.baseWodId, baseWodId) ||
                other.baseWodId == baseWodId) &&
            (identical(other.proposedWodId, proposedWodId) ||
                other.proposedWodId == proposedWodId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.proposedAt, proposedAt) ||
                other.proposedAt == proposedAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    baseWodId,
    proposedWodId,
    status,
    proposedAt,
    resolvedAt,
    resolvedBy,
  );

  /// Create a copy of ProposalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProposalModelImplCopyWith<_$ProposalModelImpl> get copyWith =>
      __$$ProposalModelImplCopyWithImpl<_$ProposalModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProposalModelImplToJson(this);
  }
}

abstract class _ProposalModel implements ProposalModel {
  const factory _ProposalModel({
    required final int id,
    required final int baseWodId,
    required final int proposedWodId,
    required final String status,
    required final String proposedAt,
    final String? resolvedAt,
    final int? resolvedBy,
  }) = _$ProposalModelImpl;

  factory _ProposalModel.fromJson(Map<String, dynamic> json) =
      _$ProposalModelImpl.fromJson;

  /// 제안 고유 ID
  @override
  int get id;

  /// 기존 Base WOD ID
  @override
  int get baseWodId;

  /// 제안된 WOD ID
  @override
  int get proposedWodId;

  /// 상태 (pending, approved, rejected)
  @override
  String get status;

  /// 제안 시간 (ISO 8601 형식)
  @override
  String get proposedAt;

  /// 처리 시간 (ISO 8601 형식, nullable)
  @override
  String? get resolvedAt;

  /// 처리자 ID (nullable)
  @override
  int? get resolvedBy;

  /// Create a copy of ProposalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProposalModelImplCopyWith<_$ProposalModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
