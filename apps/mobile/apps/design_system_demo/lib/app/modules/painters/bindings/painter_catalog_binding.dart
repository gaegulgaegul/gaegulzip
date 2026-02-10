import 'package:get/get.dart';
import '../controllers/painter_catalog_controller.dart';

/// 페인터 카탈로그 바인딩
///
/// 페인터 카탈로그 화면에 필요한 의존성 주입
class PainterCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PainterCatalogController>(
      () => PainterCatalogController(),
    );
  }
}
