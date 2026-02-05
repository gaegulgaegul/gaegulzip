import 'package:get/get.dart';
import 'package:api/api.dart';
import '../controllers/box_create_controller.dart';
import '../../../data/repositories/box_repository.dart';

/// 박스 생성 화면 바인딩
class BoxCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoxApiClient>(() => BoxApiClient());
    Get.lazyPut<BoxRepository>(() => BoxRepository());
    Get.lazyPut<BoxCreateController>(() => BoxCreateController());
  }
}
