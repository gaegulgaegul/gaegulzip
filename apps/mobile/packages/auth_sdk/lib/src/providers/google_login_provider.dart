import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:core/core.dart';
import 'social_login_provider.dart';

/// 구글 로그인 Provider
///
/// google_sign_in을 사용하여 Google 계정 인증을 처리합니다.
class GoogleLoginProvider implements SocialLoginProvider {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  @override
  String get platformName => 'google';

  @override
  bool get isInitialized => true;

  @override
  Future<String> signIn() async {
    try {
      // 1. Google Sign In
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // 2. 사용자 취소 확인
      if (account == null) {
        throw AuthException(code: 'user_cancelled', message: '로그인을 취소했습니다');
      }

      // 3. authentication 정보 획득
      final GoogleSignInAuthentication auth = await account.authentication;

      // 4. serverAuthCode 또는 idToken 반환
      // serverAuthCode는 백엔드에서 Google API로 토큰 교환 가능
      final code = account.serverAuthCode ?? auth.idToken;
      if (code == null || code.isEmpty) {
        throw AuthException(code: 'google_code_null', message: '구글 인증 코드 획득 실패');
      }

      return code;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(code: 'google_unexpected', message: '구글 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // 로그아웃 실패는 무시
      debugPrint('구글 로그아웃 실패: $e');
    }
  }
}
