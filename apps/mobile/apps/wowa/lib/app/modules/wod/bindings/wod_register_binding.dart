import 'package:get/get.dart';
import '../controllers/wod_register_controller.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../data/clients/wod_api_client.dart';

/// WOD 등록 화면 바인딩
class WodRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WodApiClient>(() => WodApiClient());
    Get.lazyPut<WodRepository>(() => WodRepository());
    Get.lazyPut<WodRegisterController>(() => WodRegisterController());
  }
}
