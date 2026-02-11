import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart';

/// 데모 앱 로그인 컨트롤러
///
/// 카카오, 네이버, 애플, 구글 소셜 로그인을 처리합니다.
class LoginController extends GetxController {
  /// 카카오 로그인 로딩 상태
  final isKakaoLoading = false.obs;

  /// 네이버 로그인 로딩 상태
  final isNaverLoading = false.obs;

  /// 애플 로그인 로딩 상태
  final isAppleLoading = false.obs;

  /// 구글 로그인 로딩 상태
  final isGoogleLoading = false.obs;

  /// 카카오 로그인 처리
  Future<void> handleKakaoLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.kakao,
      loadingState: isKakaoLoading,
    );
  }

  /// 네이버 로그인 처리
  Future<void> handleNaverLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.naver,
      loadingState: isNaverLoading,
    );
  }

  /// 애플 로그인 처리
  Future<void> handleAppleLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.apple,
      loadingState: isAppleLoading,
    );
  }

  /// 구글 로그인 처리
  Future<void> handleGoogleLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.google,
      loadingState: isGoogleLoading,
    );
  }

  // TODO(human): 공통 소셜 로그인 처리 로직 구현
  //
  // 이 메서드는 provider와 loadingState를 받아서:
  // 1. loadingState.value = true 로 로딩 시작
  // 2. AuthSdk.login(provider) 호출
  // 3. 성공 시 Get.offAllNamed(Routes.HOME) 으로 홈 이동
  // 4. AuthException 처리 (user_cancelled는 무시, 나머지는 스낵바)
  // 5. NetworkException 처리 (네트워크 오류 스낵바)
  // 6. finally에서 loadingState.value = false
  //
  // 참고: wowa 앱의 LoginController._handleSocialLogin() 패턴
  // 위치: apps/wowa/lib/app/modules/login/controllers/login_controller.dart:64-110
  Future<void> _handleSocialLogin({
    required SocialProvider provider,
    required RxBool loadingState,
  }) async {
    // TODO(human): 여기에 구현
  }
}
