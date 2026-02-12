import 'package:get/get.dart';
import 'package:qna/qna.dart';

import '../controllers/mock_qna_controller.dart';

/// QnA 데모 화면 바인딩
///
/// MockQnaController를 QnaController 타입으로 등록합니다.
/// QnaSubmitView 내부의 GetView가 Mock을 자동 사용합니다.
class SdkQnaDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QnaController>(() => MockQnaController());
  }
}
