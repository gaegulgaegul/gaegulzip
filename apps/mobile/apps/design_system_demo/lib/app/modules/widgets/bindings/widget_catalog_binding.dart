import 'package:get/get.dart';

import '../controllers/widget_catalog_controller.dart';

/// 위젯 카탈로그 바인딩
///
/// 위젯 카탈로그 화면에 필요한 의존성을 주입합니다.
class WidgetCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WidgetCatalogController>(
      () => WidgetCatalogController(),
    );
  }
}
