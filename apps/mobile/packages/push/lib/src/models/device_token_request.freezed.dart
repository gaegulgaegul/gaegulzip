// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_token_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeviceTokenRequest _$DeviceTokenRequestFromJson(Map<String, dynamic> json) {
  return _DeviceTokenRequest.fromJson(json);
}

/// @nodoc
mixin _$DeviceTokenRequest {
  /// FCM 디바이스 토큰
  String get token => throw _privateConstructorUsedError;

  /// 플랫폼 (ios, android, web)
  String get platform => throw _privateConstructorUsedError;

  /// 디바이스 고유 ID (선택)
  String? get deviceId => throw _privateConstructorUsedError;

  /// Serializes this DeviceTokenRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceTokenRequestCopyWith<DeviceTokenRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceTokenRequestCopyWith<$Res> {
  factory $DeviceTokenRequestCopyWith(
    DeviceTokenRequest value,
    $Res Function(DeviceTokenRequest) then,
  ) = _$DeviceTokenRequestCopyWithImpl<$Res, DeviceTokenRequest>;
  @useResult
  $Res call({String token, String platform, String? deviceId});
}

/// @nodoc
class _$DeviceTokenRequestCopyWithImpl<$Res, $Val extends DeviceTokenRequest>
    implements $DeviceTokenRequestCopyWith<$Res> {
  _$DeviceTokenRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? platform = null,
    Object? deviceId = freezed,
  }) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceId: freezed == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceTokenRequestImplCopyWith<$Res>
    implements $DeviceTokenRequestCopyWith<$Res> {
  factory _$$DeviceTokenRequestImplCopyWith(
    _$DeviceTokenRequestImpl value,
    $Res Function(_$DeviceTokenRequestImpl) then,
  ) = __$$DeviceTokenRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String platform, String? deviceId});
}

/// @nodoc
class __$$DeviceTokenRequestImplCopyWithImpl<$Res>
    extends _$DeviceTokenRequestCopyWithImpl<$Res, _$DeviceTokenRequestImpl>
    implements _$$DeviceTokenRequestImplCopyWith<$Res> {
  __$$DeviceTokenRequestImplCopyWithImpl(
    _$DeviceTokenRequestImpl _value,
    $Res Function(_$DeviceTokenRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? platform = null,
    Object? deviceId = freezed,
  }) {
    return _then(
      _$DeviceTokenRequestImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceId: freezed == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceTokenRequestImpl implements _DeviceTokenRequest {
  const _$DeviceTokenRequestImpl({
    required this.token,
    required this.platform,
    this.deviceId,
  });

  factory _$DeviceTokenRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceTokenRequestImplFromJson(json);

  /// FCM 디바이스 토큰
  @override
  final String token;

  /// 플랫폼 (ios, android, web)
  @override
  final String platform;

  /// 디바이스 고유 ID (선택)
  @override
  final String? deviceId;

  @override
  String toString() {
    return 'DeviceTokenRequest(token: $token, platform: $platform, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceTokenRequestImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, platform, deviceId);

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceTokenRequestImplCopyWith<_$DeviceTokenRequestImpl> get copyWith =>
      __$$DeviceTokenRequestImplCopyWithImpl<_$DeviceTokenRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceTokenRequestImplToJson(this);
  }
}

abstract class _DeviceTokenRequest implements DeviceTokenRequest {
  const factory _DeviceTokenRequest({
    required final String token,
    required final String platform,
    final String? deviceId,
  }) = _$DeviceTokenRequestImpl;

  factory _DeviceTokenRequest.fromJson(Map<String, dynamic> json) =
      _$DeviceTokenRequestImpl.fromJson;

  /// FCM 디바이스 토큰
  @override
  String get token;

  /// 플랫폼 (ios, android, web)
  @override
  String get platform;

  /// 디바이스 고유 ID (선택)
  @override
  String? get deviceId;

  /// Create a copy of DeviceTokenRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceTokenRequestImplCopyWith<_$DeviceTokenRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
