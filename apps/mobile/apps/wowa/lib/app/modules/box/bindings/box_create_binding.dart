import 'package:get/get.dart';
import '../controllers/box_create_controller.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../data/clients/box_api_client.dart';

/// 박스 생성 화면 바인딩
///
/// Controller, Repository, ApiClient 의존성 주입
class BoxCreateBinding extends Bindings {
  @override
  void dependencies() {
    // Repository 지연 로딩 (이미 생성되어 있으면 재사용)
    Get.lazyPut<BoxRepository>(
      () => BoxRepository(),
    );

    // ApiClient 지연 로딩 (이미 생성되어 있으면 재사용)
    Get.lazyPut<BoxApiClient>(
      () => BoxApiClient(),
    );

    // Controller 지연 로딩
    Get.lazyPut<BoxCreateController>(
      () => BoxCreateController(),
    );
  }
}
