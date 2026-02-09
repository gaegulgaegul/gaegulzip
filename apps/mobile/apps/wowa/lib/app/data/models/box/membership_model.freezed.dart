// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MembershipModel _$MembershipModelFromJson(Map<String, dynamic> json) {
  return _MembershipModel.fromJson(json);
}

/// @nodoc
mixin _$MembershipModel {
  /// 멤버십 고유 ID
  int get id => throw _privateConstructorUsedError;

  /// 박스 ID
  int get boxId => throw _privateConstructorUsedError;

  /// 사용자 ID
  int get userId => throw _privateConstructorUsedError;

  /// 가입 일시 (ISO 8601 형식)
  String get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this MembershipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipModelCopyWith<MembershipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipModelCopyWith<$Res> {
  factory $MembershipModelCopyWith(
    MembershipModel value,
    $Res Function(MembershipModel) then,
  ) = _$MembershipModelCopyWithImpl<$Res, MembershipModel>;
  @useResult
  $Res call({int id, int boxId, int userId, String joinedAt});
}

/// @nodoc
class _$MembershipModelCopyWithImpl<$Res, $Val extends MembershipModel>
    implements $MembershipModelCopyWith<$Res> {
  _$MembershipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boxId = null,
    Object? userId = null,
    Object? joinedAt = null,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MembershipModelImplCopyWith<$Res>
    implements $MembershipModelCopyWith<$Res> {
  factory _$$MembershipModelImplCopyWith(
    _$MembershipModelImpl value,
    $Res Function(_$MembershipModelImpl) then,
  ) = __$$MembershipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, int boxId, int userId, String joinedAt});
}

/// @nodoc
class __$$MembershipModelImplCopyWithImpl<$Res>
    extends _$MembershipModelCopyWithImpl<$Res, _$MembershipModelImpl>
    implements _$$MembershipModelImplCopyWith<$Res> {
  __$$MembershipModelImplCopyWithImpl(
    _$MembershipModelImpl _value,
    $Res Function(_$MembershipModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boxId = null,
    Object? userId = null,
    Object? joinedAt = null,
  }) {
    return _then(
      _$MembershipModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        boxId: null == boxId
            ? _value.boxId
            : boxId // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MembershipModelImpl implements _MembershipModel {
  const _$MembershipModelImpl({
    required this.id,
    required this.boxId,
    required this.userId,
    required this.joinedAt,
  });

  factory _$MembershipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MembershipModelImplFromJson(json);

  /// 멤버십 고유 ID
  @override
  final int id;

  /// 박스 ID
  @override
  final int boxId;

  /// 사용자 ID
  @override
  final int userId;

  /// 가입 일시 (ISO 8601 형식)
  @override
  final String joinedAt;

  @override
  String toString() {
    return 'MembershipModel(id: $id, boxId: $boxId, userId: $userId, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boxId, boxId) || other.boxId == boxId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, boxId, userId, joinedAt);

  /// Create a copy of MembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipModelImplCopyWith<_$MembershipModelImpl> get copyWith =>
      __$$MembershipModelImplCopyWithImpl<_$MembershipModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MembershipModelImplToJson(this);
  }
}

abstract class _MembershipModel implements MembershipModel {
  const factory _MembershipModel({
    required final int id,
    required final int boxId,
    required final int userId,
    required final String joinedAt,
  }) = _$MembershipModelImpl;

  factory _MembershipModel.fromJson(Map<String, dynamic> json) =
      _$MembershipModelImpl.fromJson;

  /// 멤버십 고유 ID
  @override
  int get id;

  /// 박스 ID
  @override
  int get boxId;

  /// 사용자 ID
  @override
  int get userId;

  /// 가입 일시 (ISO 8601 형식)
  @override
  String get joinedAt;

  /// Create a copy of MembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipModelImplCopyWith<_$MembershipModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
