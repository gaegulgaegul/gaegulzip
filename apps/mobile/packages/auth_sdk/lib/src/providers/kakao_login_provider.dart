import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:core/core.dart';
import 'social_login_provider.dart';

/// 카카오 로그인 Provider
///
/// kakao_flutter_sdk를 사용하여 카카오 OAuth 인증을 처리합니다.
class KakaoLoginProvider implements SocialLoginProvider {
  @override
  String get platformName => 'kakao';

  @override
  bool get isInitialized => true; // AuthSdk.initialize()에서 KakaoSdk.init() 호출

  @override
  Future<String> signIn() async {
    try {
      // 카카오톡 설치 여부에 따라 로그인, 실패 시 카카오계정으로 fallback
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
        } catch (_) {
          await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      // 토큰 획득
      final token = await TokenManagerProvider.instance.manager.getToken();
      if (token?.accessToken == null) {
        throw AuthException(code: 'kakao_token_null', message: '카카오 토큰 획득 실패');
      }

      return token!.accessToken;
    } on PlatformException catch (e) {
      // iOS ASWebAuthenticationSession 취소 시 PlatformException(CANCELED) 발생
      if (e.code == 'CANCELED') {
        throw AuthException(code: 'user_cancelled', message: '로그인을 취소했습니다');
      }
      throw AuthException(code: 'kakao_error', message: '카카오 로그인 실패: ${e.message}');
    } on KakaoException catch (e) {
      if (e.toString().contains('CANCELLED')) {
        throw AuthException(code: 'user_cancelled', message: '로그인을 취소했습니다');
      }
      throw AuthException(code: 'kakao_error', message: '카카오 로그인 실패: ${e.toString()}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(code: 'kakao_unexpected', message: '카카오 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await UserApi.instance.logout();
    } catch (e) {
      // 로그아웃 실패는 무시 (이미 로그아웃 상태일 수 있음)
      debugPrint('카카오 로그아웃 실패 (무시됨): $e');
    }
  }
}
