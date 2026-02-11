import 'package:get/get.dart';
import '../services/notice_api_service.dart';
import '../controllers/notice_list_controller.dart';

/// Notice 화면 바인딩
///
/// [appCode]를 외부에서 주입받습니다.
/// QnaBinding과 동일한 인터페이스로 SDK 초기화 패턴을 통일합니다.
class NoticeBinding extends Bindings {
  /// 앱 식별 코드 (예: 'wowa', 'demo')
  final String appCode;

  /// 생성자
  ///
  /// [appCode] 필수 파라미터 — 향후 서버 확장 시 활용
  NoticeBinding({required this.appCode});

  @override
  void dependencies() {
    // API 서비스 (lazyPut - 필요 시 생성)
    Get.lazyPut<NoticeApiService>(() => NoticeApiService());

    // Controller (lazyPut — appCode 주입)
    Get.lazyPut<NoticeListController>(
      () => NoticeListController()..appCode = appCode,
    );
  }
}
