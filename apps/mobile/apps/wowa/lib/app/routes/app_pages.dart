import 'package:get/get.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';
import 'app_routes.dart';

/// 앱 페이지 정의
///
/// 모든 라우트와 해당하는 View, Binding을 등록합니다.
class AppPages {
  /// GetPage 리스트
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
