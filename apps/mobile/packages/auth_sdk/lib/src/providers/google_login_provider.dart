import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:core/core.dart';
import 'social_login_provider.dart';

/// 구글 로그인 Provider
///
/// google_sign_in을 사용하여 Google 계정 인증을 처리합니다.
/// idToken을 서버에 전달하여 서버에서 토큰 검증을 수행합니다.
class GoogleLoginProvider implements SocialLoginProvider {
  final GoogleSignIn _googleSignIn;

  GoogleLoginProvider({GoogleSignIn? googleSignIn, String? serverClientId})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              serverClientId: serverClientId,
            );

  @override
  String get platformName => 'google';

  @override
  bool get isInitialized => true;

  @override
  Future<String> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        throw AuthException(code: 'user_cancelled', message: '로그인을 취소했습니다');
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw AuthException(
          code: 'google_id_token_null',
          message: '구글 idToken 획득 실패',
        );
      }

      return idToken;
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
