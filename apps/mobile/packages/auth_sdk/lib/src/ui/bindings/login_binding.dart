import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// 로그인 화면 바인딩
///
/// LoginController만 등록 (프로바이더는 AuthSdk.initialize()에서 등록)
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
