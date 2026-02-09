import 'package:get/get.dart';
import '../controllers/box_create_controller.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../data/clients/box_api_client.dart';

/// 박스 생성 화면 바인딩
class BoxCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoxApiClient>(() => BoxApiClient());
    Get.lazyPut<BoxRepository>(() => BoxRepository());
    Get.lazyPut<BoxCreateController>(() => BoxCreateController());
  }
}
