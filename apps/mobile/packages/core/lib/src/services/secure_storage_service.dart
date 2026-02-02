import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage 서비스
///
/// flutter_secure_storage를 래핑하여 토큰 및 사용자 정보를 안전하게 저장합니다.
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _userIdKey = 'user_id';
  static const String _userProviderKey = 'user_provider';

  /// accessToken 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// accessToken 읽기
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// refreshToken 저장
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// refreshToken 읽기
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 토큰 만료 시각 저장 (ISO 8601 형식)
  ///
  /// [expiresIn] 만료 시간 (초)
  Future<void> saveTokenExpiresAt(int expiresIn) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(key: _tokenExpiresAtKey, value: expiresAt.toIso8601String());
  }

  /// 토큰 만료 시각 읽기
  Future<DateTime?> getTokenExpiresAt() async {
    final expiresAtString = await _storage.read(key: _tokenExpiresAtKey);
    if (expiresAtString == null) return null;
    return DateTime.tryParse(expiresAtString);
  }

  /// 토큰 만료 여부 확인
  Future<bool> isTokenExpired() async {
    final expiresAt = await getTokenExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }

  /// 사용자 ID 저장
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  /// 사용자 ID 읽기
  Future<int?> getUserId() async {
    final userIdString = await _storage.read(key: _userIdKey);
    if (userIdString == null) return null;
    return int.tryParse(userIdString);
  }

  /// 사용자 소셜 플랫폼 저장
  Future<void> saveUserProvider(String provider) async {
    await _storage.write(key: _userProviderKey, value: provider);
  }

  /// 사용자 소셜 플랫폼 읽기
  Future<String?> getUserProvider() async {
    return await _storage.read(key: _userProviderKey);
  }

  /// 모든 인증 정보 삭제 (로그아웃)
  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiresAtKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userProviderKey);
  }
}
