import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:core/core.dart';
import 'dart:io' show Platform;
import 'social_login_provider.dart';

/// 애플 로그인 Provider
///
/// sign_in_with_apple을 사용하여 Apple ID 인증을 처리합니다.
class AppleLoginProvider implements SocialLoginProvider {
  @override
  String get platformName => 'apple';

  @override
  bool get isInitialized =>
      Platform.isIOS || Platform.isMacOS; // iOS 13+ / macOS 10.15+에서만 사용 가능

  @override
  Future<String> signIn() async {
    try {
      // 1. Apple Sign In 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. authorizationCode 획득
      final authCode = credential.authorizationCode;
      if (authCode.isEmpty) {
        throw AuthException(code: 'apple_code_null', message: '애플 인증 코드 획득 실패');
      }

      // 3. authorizationCode 반환 (백엔드로 전송)
      return authCode;
    } on SignInWithAppleAuthorizationException catch (e) {
      // 사용자 취소
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthException(code: 'user_cancelled', message: '로그인을 취소했습니다');
      }

      // 권한 거부
      if (e.code == AuthorizationErrorCode.invalidResponse) {
        throw AuthException(code: 'apple_invalid_response', message: '권한을 허용해주세요');
      }

      throw AuthException(code: 'apple_error', message: '애플 로그인 실패: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(code: 'apple_unexpected', message: '애플 로그인 중 오류가 발생했습니다');
    }
  }

  @override
  Future<void> signOut() async {
    // 애플은 SDK 수준의 로그아웃이 없음
    // 백엔드 세션만 종료하면 됨
  }
}
