import 'package:get/get.dart';
import 'package:api/api.dart';
import '../../../data/repositories/box_repository.dart';
import '../controllers/settings_controller.dart';

/// 설정 화면 바인딩
///
/// SettingsController와 의존성을 등록합니다.
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoxApiClient>(() => BoxApiClient());
    Get.lazyPut<BoxRepository>(() => BoxRepository());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
