import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// 소셜 로그인 응답 모델
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    /// API 요청 시 사용할 JWT 토큰
    required String accessToken,

    /// accessToken 갱신용 JWT 토큰
    required String refreshToken,

    /// 토큰 타입 (항상 "Bearer")
    required String tokenType,

    /// accessToken 만료 시간 (초 단위, 기본 1800초 = 30분)
    required int expiresIn,

    /// 사용자 정보
    required UserModel user,

    /// 레거시 필드 (token과 accessToken은 동일)
    required String token,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
