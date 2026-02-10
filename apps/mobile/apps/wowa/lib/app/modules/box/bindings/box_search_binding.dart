import 'package:get/get.dart';
import '../controllers/box_search_controller.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../data/clients/box_api_client.dart';

/// 박스 검색 화면 바인딩
///
/// Controller, Repository, ApiClient 의존성 주입
class BoxSearchBinding extends Bindings {
  @override
  void dependencies() {
    // Repository 지연 로딩 (필요 시 생성)
    Get.lazyPut<BoxRepository>(
      () => BoxRepository(),
    );

    // ApiClient 지연 로딩 (필요 시 생성)
    Get.lazyPut<BoxApiClient>(
      () => BoxApiClient(),
    );

    // Controller 지연 로딩
    Get.lazyPut<BoxSearchController>(
      () => BoxSearchController(),
    );
  }
}
