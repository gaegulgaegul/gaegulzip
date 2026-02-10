import 'package:get/get.dart';
import '../controllers/tokens_controller.dart';

/// 디자인 토큰 모듈 바인딩
///
/// 디자인 토큰 화면에 필요한 의존성을 주입합니다.
class TokensBinding extends Bindings {
  @override
  void dependencies() {
    // Controller 지연 로딩
    Get.lazyPut<TokensController>(
      () => TokensController(),
    );
  }
}
