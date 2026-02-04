import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/refresh_response.dart';

/// 인증 API 서비스
///
/// 소셜 로그인, 토큰 갱신, 로그아웃 API를 호출합니다.
class AuthApiService {
  final Dio _dio = Get.find<Dio>();

  /// 앱 코드 (서버에서 앱 식별용)
  static const String _appCode = 'wowa';

  /// 소셜 로그인 API 호출
  ///
  /// [provider] 소셜 플랫폼 ('kakao', 'naver', 'apple', 'google')
  /// [accessToken] 소셜 SDK에서 획득한 OAuth access token
  ///
  /// Returns: [LoginResponse] 로그인 응답 (토큰, 사용자 정보)
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<LoginResponse> login({
    required String provider,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/oauth',
        data: LoginRequest(
          code: _appCode,
          provider: provider,
          accessToken: accessToken,
        ).toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// 토큰 갱신 API 호출
  ///
  /// [refreshToken] 리프레시 토큰
  ///
  /// Returns: [RefreshResponse] 새로운 토큰
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류 (401: refreshToken 만료)
  Future<RefreshResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return RefreshResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// 로그아웃 API 호출
  ///
  /// [refreshToken] 무효화할 리프레시 토큰
  /// [revokeAll] true이면 사용자의 모든 토큰 무효화
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<void> logout({
    required String refreshToken,
    bool revokeAll = false,
  }) async {
    try {
      await _dio.post(
        '/auth/logout',
        data: {
          'refreshToken': refreshToken,
          'revokeAll': revokeAll,
        },
      );
    } on DioException {
      rethrow;
    }
  }
}
