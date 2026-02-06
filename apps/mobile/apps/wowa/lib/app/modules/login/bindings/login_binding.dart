import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart';
import '../controllers/login_controller.dart';

/// 로그인 화면 바인딩
///
/// 로그인 화면 전용 의존성을 주입합니다.
/// AuthSdk는 main.dart에서 전역 초기화됩니다.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Social Login Providers (tag로 등록 - AuthSdk에서 사용)
    Get.lazyPut<SocialLoginProvider>(() => KakaoLoginProvider(), tag: 'kakao');
    Get.lazyPut<SocialLoginProvider>(() => NaverLoginProvider(), tag: 'naver');
    Get.lazyPut<SocialLoginProvider>(() => AppleLoginProvider(), tag: 'apple');
    Get.lazyPut<SocialLoginProvider>(
      () => GoogleLoginProvider(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      ),
      tag: 'google',
    );

    // LoginController (lazyPut)
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
