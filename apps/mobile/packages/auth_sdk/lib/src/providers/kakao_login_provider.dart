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
  bool get isInitialized => true; // kakao_flutter_sdk는 main.dart에서 초기화

  @override
  Future<String> signIn() async {
    try {
      // 1. 카카오톡 앱 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        // 카카오톡으로 로그인
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정으로 로그인 (웹뷰)
        await UserApi.instance.loginWithKakaoAccount();
      }

      // 2. authorization code 획득 (OAuth code flow)
      // 주의: kakao_flutter_sdk는 암시적 승인 방식을 사용하므로
      // 백엔드에서 accessToken을 받아 검증하는 방식으로 변경 필요
      // 현재는 임시로 accessToken을 code처럼 사용
      final accessToken = await TokenManagerProvider.instance.manager.getToken();
      if (accessToken?.accessToken == null) {
        throw AuthException(code: 'kakao_token_null', message: '카카오 토큰 획득 실패');
      }

      return accessToken!.accessToken;
    } on KakaoException catch (e) {
      // 사용자 취소
      if (e.toString().contains('User cancelled')) {
        throw AuthException(code: 'user_cancelled', message: '로그인을 취소했습니다');
      }
      throw AuthException(code: 'kakao_error', message: '카카오 로그인 실패: ${e.message}');
    } catch (e) {
      throw Exception('카카오 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await UserApi.instance.logout();
    } catch (e) {
      // 로그아웃 실패는 무시 (이미 로그아웃 상태일 수 있음)
    }
  }
}
