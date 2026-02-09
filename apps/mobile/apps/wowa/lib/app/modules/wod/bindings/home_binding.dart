import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../data/clients/box_api_client.dart';
import '../../../data/clients/wod_api_client.dart';

/// WOD 홈 화면 바인딩
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoxApiClient>(() => BoxApiClient());
    Get.lazyPut<WodApiClient>(() => WodApiClient());
    Get.lazyPut<BoxRepository>(() => BoxRepository());
    Get.lazyPut<WodRepository>(() => WodRepository());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
