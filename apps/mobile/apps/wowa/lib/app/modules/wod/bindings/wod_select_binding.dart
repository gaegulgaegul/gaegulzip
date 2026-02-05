import 'package:get/get.dart';
import 'package:api/api.dart';
import '../controllers/wod_select_controller.dart';
import '../../../data/repositories/wod_repository.dart';

/// WOD 선택 화면 바인딩
class WodSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WodApiClient>(() => WodApiClient());
    Get.lazyPut<WodRepository>(() => WodRepository());
    Get.lazyPut<WodSelectController>(() => WodSelectController());
  }
}
