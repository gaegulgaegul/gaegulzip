import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:core/core.dart';
import 'social_login_provider.dart';

/// 네이버 로그인 Provider
///
/// flutter_naver_login을 사용하여 네이버 OAuth 인증을 처리합니다.
class NaverLoginProvider implements SocialLoginProvider {
  @override
  String get platformName => 'naver';

  @override
  bool get isInitialized => true; // Native 설정으로 초기화됨

  @override
  Future<String> signIn() async {
    try {
      // 1. 네이버 로그인
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      // 2. 로그인 상태 확인
      if (result.status != NaverLoginStatus.loggedIn) {
        throw AuthException(
          code: 'naver_login_failed',
          message: result.errorMessage ?? '네이버 로그인 실패',
        );
      }

      // 3. accessToken 반환 (백엔드에서 검증)
      final token = result.accessToken?.accessToken ?? '';
      if (token.isEmpty) {
        throw AuthException(code: 'naver_token_null', message: '네이버 토큰 획득 실패');
      }

      return token;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(code: 'naver_unexpected', message: '네이버 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await FlutterNaverLogin.logOut();
    } catch (e) {
      // 로그아웃 실패는 무시
      debugPrint('네이버 로그아웃 실패: $e');
    }
  }
}
