import 'package:get/get.dart';

import '../controllers/home_controller.dart';

/// 홈 모듈 바인딩
///
/// 홈 화면에 필요한 의존성을 주입합니다.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
