import 'package:get/get.dart';
import 'package:api/api.dart';
import '../controllers/wod_register_controller.dart';
import '../../../data/repositories/wod_repository.dart';

/// WOD 등록 화면 바인딩
class WodRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WodApiClient>(() => WodApiClient());
    Get.lazyPut<WodRepository>(() => WodRepository());
    Get.lazyPut<WodRegisterController>(() => WodRegisterController());
  }
}
