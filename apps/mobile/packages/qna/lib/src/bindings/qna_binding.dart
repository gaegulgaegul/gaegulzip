import 'package:get/get.dart';
import '../services/qna_api_service.dart';
import '../repositories/qna_repository.dart';
import '../controllers/qna_controller.dart';

/// QnA 화면 바인딩
///
/// [appCode]를 외부에서 주입받아 Repository에 전달합니다.
class QnaBinding extends Bindings {
  /// 앱 식별 코드 (예: 'wowa', 'other-app')
  final String appCode;

  /// 생성자
  ///
  /// [appCode] 필수 파라미터 — 앱별 GitHub 레포지토리 매핑
  const QnaBinding({required this.appCode});

  @override
  void dependencies() {
    // API 서비스 (lazyPut - 필요 시 생성)
    Get.lazyPut<QnaApiService>(() => QnaApiService());

    // Repository (appCode 주입)
    Get.lazyPut<QnaRepository>(
      () => QnaRepository(appCode: appCode),
    );

    // Controller (lazyPut)
    Get.lazyPut<QnaController>(() => QnaController());
  }
}
