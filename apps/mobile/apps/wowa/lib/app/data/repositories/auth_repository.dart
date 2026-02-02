import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';

/// 인증 Repository
///
/// API 서비스와 Secure Storage를 통합하여 로그인, 로그아웃, 토큰 관리를 처리합니다.
class AuthRepository {
  final AuthApiService _apiService = Get.find<AuthApiService>();
  final SecureStorageService _storageService = Get.find<SecureStorageService>();

  /// 소셜 로그인 처리
  ///
  /// [provider] 소셜 플랫폼
  /// [code] OAuth code
  ///
  /// Returns: [UserModel] 로그인한 사용자 정보
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [AuthException] 인증 오류 (401, 409 등)
  ///   - [Exception] 기타 서버 오류
  Future<UserModel> login({
    required String provider,
    required String code,
  }) async {
    try {
      // 1. API 호출
      final response = await _apiService.login(
        provider: provider,
        code: code,
      );

      // 2. 토큰 저장
      await _storageService.saveAccessToken(response.accessToken);
      await _storageService.saveRefreshToken(response.refreshToken);
      await _storageService.saveTokenExpiresAt(response.expiresIn);

      // 3. 사용자 정보 저장
      await _storageService.saveUserId(response.user.id);
      await _storageService.saveUserProvider(response.user.provider);

      // 4. 사용자 정보 반환
      return response.user;
    } on DioException catch (e) {
      // DioException을 도메인 예외로 변환
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: '네트워크 연결을 확인해주세요');
      }

      if (e.response?.statusCode == 401) {
        throw AuthException(code: 'invalid_code', message: '인증에 실패했습니다');
      }

      if (e.response?.statusCode == 409) {
        // 계정 연동 충돌
        final existingProvider = e.response?.data['existingProvider'] ?? 'unknown';
        throw AuthException(
          code: 'account_conflict',
          message: '이미 다른 계정으로 가입되어 있습니다',
          data: {'existingProvider': existingProvider},
        );
      }

      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw Exception('일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요');
      }

      throw Exception('로그인 중 오류가 발생했습니다');
    }
  }

  /// 토큰 갱신
  ///
  /// Returns: 갱신 성공 여부
  ///
  /// Throws:
  ///   - [AuthException] refreshToken 만료 (자동 로그아웃 필요)
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException(code: 'no_refresh_token', message: '로그인이 필요합니다');
      }

      final response = await _apiService.refreshToken(refreshToken);

      // 새로운 토큰 저장
      await _storageService.saveAccessToken(response.accessToken);
      await _storageService.saveRefreshToken(response.refreshToken);
      await _storageService.saveTokenExpiresAt(response.expiresIn);

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // refreshToken 만료 - 로그아웃 필요
        throw AuthException(code: 'refresh_token_expired', message: '로그인이 만료되었습니다');
      }
      throw NetworkException(message: '네트워크 연결을 확인해주세요');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _storageService.clearAll();
  }

  /// 로그인 여부 확인
  Future<bool> isLoggedIn() async {
    final accessToken = await _storageService.getAccessToken();
    return accessToken != null;
  }

  /// 토큰 만료 여부 확인
  Future<bool> isTokenExpired() async {
    return await _storageService.isTokenExpired();
  }
}
