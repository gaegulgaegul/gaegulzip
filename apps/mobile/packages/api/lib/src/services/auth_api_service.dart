import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/refresh_response.dart';

/// 인증 API 서비스
///
/// 소셜 로그인 및 토큰 갱신 API를 호출합니다.
class AuthApiService {
  final Dio _dio = Get.find<Dio>();

  /// 소셜 로그인 API 호출
  ///
  /// [provider] 소셜 플랫폼 ('kakao', 'naver', 'apple', 'google')
  /// [code] OAuth authorization code
  ///
  /// Returns: [LoginResponse] 로그인 응답 (토큰, 사용자 정보)
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<LoginResponse> login({
    required String provider,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/oauth/login',
        data: LoginRequest(provider: provider, code: code).toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException {
      // DioException을 그대로 throw (Repository에서 처리)
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
        '/api/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );
      return RefreshResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}
