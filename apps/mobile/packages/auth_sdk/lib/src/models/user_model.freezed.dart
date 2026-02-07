// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  /// 사용자 고유 ID
  int get id => throw _privateConstructorUsedError;

  /// 가입 시 사용한 소셜 플랫폼
  String get provider => throw _privateConstructorUsedError;

  /// 이메일 주소 (nullable: 애플은 이메일 제공 거부 가능)
  String? get email => throw _privateConstructorUsedError;

  /// 사용자 닉네임 (nullable: 애플은 이름을 제공하지 않음)
  String? get nickname => throw _privateConstructorUsedError;

  /// 프로필 이미지 URL (nullable)
  String? get profileImage => throw _privateConstructorUsedError;

  /// 앱 식별 코드
  String get appCode => throw _privateConstructorUsedError;

  /// 마지막 로그인 시각 (ISO 8601 형식)
  String get lastLoginAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    int id,
    String provider,
    String? email,
    String? nickname,
    String? profileImage,
    String appCode,
    String lastLoginAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? email = freezed,
    Object? nickname = freezed,
    Object? profileImage = freezed,
    Object? appCode = null,
    Object? lastLoginAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            nickname: freezed == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImage: freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            appCode: null == appCode
                ? _value.appCode
                : appCode // ignore: cast_nullable_to_non_nullable
                      as String,
            lastLoginAt: null == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String provider,
    String? email,
    String? nickname,
    String? profileImage,
    String appCode,
    String lastLoginAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? email = freezed,
    Object? nickname = freezed,
    Object? profileImage = freezed,
    Object? appCode = null,
    Object? lastLoginAt = null,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        nickname: freezed == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImage: freezed == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        appCode: null == appCode
            ? _value.appCode
            : appCode // ignore: cast_nullable_to_non_nullable
                  as String,
        lastLoginAt: null == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.provider,
    this.email,
    this.nickname,
    this.profileImage,
    required this.appCode,
    required this.lastLoginAt,
  });

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  /// 사용자 고유 ID
  @override
  final int id;

  /// 가입 시 사용한 소셜 플랫폼
  @override
  final String provider;

  /// 이메일 주소 (nullable: 애플은 이메일 제공 거부 가능)
  @override
  final String? email;

  /// 사용자 닉네임 (nullable: 애플은 이름을 제공하지 않음)
  @override
  final String? nickname;

  /// 프로필 이미지 URL (nullable)
  @override
  final String? profileImage;

  /// 앱 식별 코드
  @override
  final String appCode;

  /// 마지막 로그인 시각 (ISO 8601 형식)
  @override
  final String lastLoginAt;

  @override
  String toString() {
    return 'UserModel(id: $id, provider: $provider, email: $email, nickname: $nickname, profileImage: $profileImage, appCode: $appCode, lastLoginAt: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.appCode, appCode) || other.appCode == appCode) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    provider,
    email,
    nickname,
    profileImage,
    appCode,
    lastLoginAt,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final int id,
    required final String provider,
    final String? email,
    final String? nickname,
    final String? profileImage,
    required final String appCode,
    required final String lastLoginAt,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  /// 사용자 고유 ID
  @override
  int get id;

  /// 가입 시 사용한 소셜 플랫폼
  @override
  String get provider;

  /// 이메일 주소 (nullable: 애플은 이메일 제공 거부 가능)
  @override
  String? get email;

  /// 사용자 닉네임 (nullable: 애플은 이름을 제공하지 않음)
  @override
  String? get nickname;

  /// 프로필 이미지 URL (nullable)
  @override
  String? get profileImage;

  /// 앱 식별 코드
  @override
  String get appCode;

  /// 마지막 로그인 시각 (ISO 8601 형식)
  @override
  String get lastLoginAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
