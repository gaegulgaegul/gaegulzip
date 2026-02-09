// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'box_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BoxMemberModel _$BoxMemberModelFromJson(Map<String, dynamic> json) {
  return _BoxMemberModel.fromJson(json);
}

/// @nodoc
mixin _$BoxMemberModel {
  /// 멤버십 고유 ID
  int get id => throw _privateConstructorUsedError;

  /// 박스 ID
  int get boxId => throw _privateConstructorUsedError;

  /// 사용자 ID
  int get userId => throw _privateConstructorUsedError;

  /// 역할 (nullable)
  String? get role => throw _privateConstructorUsedError;

  /// 가입 시간 (ISO 8601 형식)
  String get joinedAt => throw _privateConstructorUsedError;

  /// 사용자 정보 (nested, nullable)
  UserModel? get user => throw _privateConstructorUsedError;

  /// Serializes this BoxMemberModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoxMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoxMemberModelCopyWith<BoxMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoxMemberModelCopyWith<$Res> {
  factory $BoxMemberModelCopyWith(
    BoxMemberModel value,
    $Res Function(BoxMemberModel) then,
  ) = _$BoxMemberModelCopyWithImpl<$Res, BoxMemberModel>;
  @useResult
  $Res call({
    int id,
    int boxId,
    int userId,
    String? role,
    String joinedAt,
    UserModel? user,
  });

  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class _$BoxMemberModelCopyWithImpl<$Res, $Val extends BoxMemberModel>
    implements $BoxMemberModelCopyWith<$Res> {
  _$BoxMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoxMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boxId = null,
    Object? userId = null,
    Object? role = freezed,
    Object? joinedAt = null,
    Object? user = freezed,
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
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of BoxMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BoxMemberModelImplCopyWith<$Res>
    implements $BoxMemberModelCopyWith<$Res> {
  factory _$$BoxMemberModelImplCopyWith(
    _$BoxMemberModelImpl value,
    $Res Function(_$BoxMemberModelImpl) then,
  ) = __$$BoxMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int boxId,
    int userId,
    String? role,
    String joinedAt,
    UserModel? user,
  });

  @override
  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class __$$BoxMemberModelImplCopyWithImpl<$Res>
    extends _$BoxMemberModelCopyWithImpl<$Res, _$BoxMemberModelImpl>
    implements _$$BoxMemberModelImplCopyWith<$Res> {
  __$$BoxMemberModelImplCopyWithImpl(
    _$BoxMemberModelImpl _value,
    $Res Function(_$BoxMemberModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BoxMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boxId = null,
    Object? userId = null,
    Object? role = freezed,
    Object? joinedAt = null,
    Object? user = freezed,
  }) {
    return _then(
      _$BoxMemberModelImpl(
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
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BoxMemberModelImpl implements _BoxMemberModel {
  const _$BoxMemberModelImpl({
    required this.id,
    required this.boxId,
    required this.userId,
    this.role,
    required this.joinedAt,
    this.user,
  });

  factory _$BoxMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoxMemberModelImplFromJson(json);

  /// 멤버십 고유 ID
  @override
  final int id;

  /// 박스 ID
  @override
  final int boxId;

  /// 사용자 ID
  @override
  final int userId;

  /// 역할 (nullable)
  @override
  final String? role;

  /// 가입 시간 (ISO 8601 형식)
  @override
  final String joinedAt;

  /// 사용자 정보 (nested, nullable)
  @override
  final UserModel? user;

  @override
  String toString() {
    return 'BoxMemberModel(id: $id, boxId: $boxId, userId: $userId, role: $role, joinedAt: $joinedAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoxMemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boxId, boxId) || other.boxId == boxId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, boxId, userId, role, joinedAt, user);

  /// Create a copy of BoxMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoxMemberModelImplCopyWith<_$BoxMemberModelImpl> get copyWith =>
      __$$BoxMemberModelImplCopyWithImpl<_$BoxMemberModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BoxMemberModelImplToJson(this);
  }
}

abstract class _BoxMemberModel implements BoxMemberModel {
  const factory _BoxMemberModel({
    required final int id,
    required final int boxId,
    required final int userId,
    final String? role,
    required final String joinedAt,
    final UserModel? user,
  }) = _$BoxMemberModelImpl;

  factory _BoxMemberModel.fromJson(Map<String, dynamic> json) =
      _$BoxMemberModelImpl.fromJson;

  /// 멤버십 고유 ID
  @override
  int get id;

  /// 박스 ID
  @override
  int get boxId;

  /// 사용자 ID
  @override
  int get userId;

  /// 역할 (nullable)
  @override
  String? get role;

  /// 가입 시간 (ISO 8601 형식)
  @override
  String get joinedAt;

  /// 사용자 정보 (nested, nullable)
  @override
  UserModel? get user;

  /// Create a copy of BoxMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoxMemberModelImplCopyWith<_$BoxMemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
