import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import '../controllers/login_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/social_login/kakao_login_provider.dart';
import '../../../services/social_login/naver_login_provider.dart';
import '../../../services/social_login/apple_login_provider.dart';
import '../../../services/social_login/google_login_provider.dart';

/// 로그인 화면 바인딩
///
/// 로그인 화면에서 사용하는 모든 의존성을 주입합니다.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // API 서비스 (lazyPut - 필요 시 생성)
    Get.lazyPut<AuthApiService>(() => AuthApiService());

    // Secure Storage (lazyPut)
    Get.lazyPut<SecureStorageService>(() => SecureStorageService());

    // Repository (lazyPut)
    Get.lazyPut<AuthRepository>(() => AuthRepository());

    // Social Login Providers (lazyPut)
    Get.lazyPut<KakaoLoginProvider>(() => KakaoLoginProvider());
    Get.lazyPut<NaverLoginProvider>(() => NaverLoginProvider());
    Get.lazyPut<AppleLoginProvider>(() => AppleLoginProvider());
    Get.lazyPut<GoogleLoginProvider>(() => GoogleLoginProvider());

    // LoginController (lazyPut)
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
