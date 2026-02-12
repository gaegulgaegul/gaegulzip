import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_token_request.freezed.dart';
part 'device_token_request.g.dart';

/// 디바이스 토큰 등록 요청
@freezed
class DeviceTokenRequest with _$DeviceTokenRequest {
  const factory DeviceTokenRequest({
    /// FCM 디바이스 토큰
    required String token,

    /// 플랫폼 (ios, android, web)
    required String platform,

    /// 디바이스 고유 ID (선택, null이면 JSON에서 제외)
    @JsonKey(includeIfNull: false) String? deviceId,
  }) = _DeviceTokenRequest;

  factory DeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenRequestFromJson(json);
}
