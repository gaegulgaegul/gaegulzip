import 'package:get/get.dart';
import '../controllers/theme_showcase_controller.dart';

/// 테마 쇼케이스 모듈 바인딩
///
/// 테마 쇼케이스 화면에 필요한 의존성을 주입합니다.
class ThemeShowcaseBinding extends Bindings {
  @override
  void dependencies() {
    // Controller 지연 로딩
    Get.lazyPut<ThemeShowcaseController>(
      () => ThemeShowcaseController(),
    );
  }
}
