import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart';
import '../controllers/login_controller.dart';

/// 로그인 화면 바인딩
///
/// 소셜 로그인 프로바이더 4개와 LoginController를 등록합니다.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Social Login Providers (tag로 등록)
    Get.lazyPut<SocialLoginProvider>(() => KakaoLoginProvider(), tag: 'kakao');
    Get.lazyPut<SocialLoginProvider>(() => NaverLoginProvider(), tag: 'naver');
    Get.lazyPut<SocialLoginProvider>(() => AppleLoginProvider(), tag: 'apple');
    Get.lazyPut<SocialLoginProvider>(() => GoogleLoginProvider(), tag: 'google');

    // LoginController
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
