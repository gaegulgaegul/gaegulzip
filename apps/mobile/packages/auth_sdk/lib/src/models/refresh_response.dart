import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_response.freezed.dart';
part 'refresh_response.g.dart';

/// 토큰 갱신 응답 모델
///
/// 서버 API: POST /auth/refresh
@freezed
class RefreshResponse with _$RefreshResponse {
  const factory RefreshResponse({
    /// 새로운 accessToken
    required String accessToken,

    /// 새로운 refreshToken
    required String refreshToken,

    /// 토큰 타입 (항상 "Bearer")
    required String tokenType,

    /// 만료 시간 (초)
    required int expiresIn,
  }) = _RefreshResponse;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseFromJson(json);
}
