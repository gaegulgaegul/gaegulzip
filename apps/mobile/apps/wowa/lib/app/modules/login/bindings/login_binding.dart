import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// 로그인 모듈 바인딩
///
/// LoginController와 AuthRepository를 지연 로딩합니다.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Controller 지연 로딩
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );

    // Repository 지연 로딩 (추후 구현 시 활성화)
    // Get.lazyPut<AuthRepository>(
    //   () => AuthRepository(),
    // );
  }
}
