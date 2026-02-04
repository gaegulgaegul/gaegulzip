import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

/// 소셜 로그인 요청 모델
///
/// 서버 API: POST /auth/oauth
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    /// 앱 코드 (서버에서 앱 식별용, 예: 'wowa')
    required String code,

    /// 소셜 로그인 플랫폼 ('kakao' | 'naver' | 'apple' | 'google')
    required String provider,

    /// 소셜 SDK에서 획득한 OAuth access token
    required String accessToken,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
