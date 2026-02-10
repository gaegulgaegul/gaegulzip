import 'package:get/get.dart';
import '../controllers/color_palette_controller.dart';

/// 컬러 팔레트 모듈 바인딩
///
/// 컬러 팔레트 화면에 필요한 의존성을 주입합니다.
class ColorPaletteBinding extends Bindings {
  @override
  void dependencies() {
    // Controller 지연 로딩
    Get.lazyPut<ColorPaletteController>(
      () => ColorPaletteController(),
    );
  }
}
