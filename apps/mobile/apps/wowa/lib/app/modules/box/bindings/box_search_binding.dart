import 'package:get/get.dart';
import '../controllers/box_search_controller.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../data/clients/box_api_client.dart';

/// 박스 검색 화면 바인딩
class BoxSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoxApiClient>(() => BoxApiClient());
    Get.lazyPut<BoxRepository>(() => BoxRepository());
    Get.lazyPut<BoxSearchController>(() => BoxSearchController());
  }
}
