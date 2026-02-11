import 'package:get/get.dart';

import '../controllers/sdk_list_controller.dart';

/// SDK 목록 화면 바인딩
class SdkListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SdkListController>(() => SdkListController());
  }
}
