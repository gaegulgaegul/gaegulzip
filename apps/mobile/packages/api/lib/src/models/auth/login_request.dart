import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

/// 소셜 로그인 요청 모델
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    /// 소셜 로그인 플랫폼 ('kakao' | 'naver' | 'apple' | 'google')
    required String provider,

    /// OAuth authorization code
    required String code,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
