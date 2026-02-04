import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../services/social_login/kakao_login_provider.dart';
import '../../../services/social_login/naver_login_provider.dart';
import '../../../services/social_login/apple_login_provider.dart';
import '../../../services/social_login/google_login_provider.dart';

/// 로그인 화면 바인딩
///
/// 로그인 화면 전용 의존성을 주입합니다.
/// AuthApiService, SecureStorageService, AuthRepository는 main.dart에서 전역 등록됩니다.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Social Login Providers (lazyPut - 로그인 화면에서만 필요)
    Get.lazyPut<KakaoLoginProvider>(() => KakaoLoginProvider());
    Get.lazyPut<NaverLoginProvider>(() => NaverLoginProvider());
    Get.lazyPut<AppleLoginProvider>(() => AppleLoginProvider());
    Get.lazyPut<GoogleLoginProvider>(() => GoogleLoginProvider());

    // LoginController (lazyPut)
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
