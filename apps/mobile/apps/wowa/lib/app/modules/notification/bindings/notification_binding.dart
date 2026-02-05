import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

/// 알림 화면 바인딩
///
/// 알림 목록 화면에서 사용하는 의존성을 주입합니다.
class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // PushApiClient는 main.dart에서 전역 등록됨 (디바이스 토큰 자동 등록용)
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
