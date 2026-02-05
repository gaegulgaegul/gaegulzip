import 'package:get/get.dart';
import 'package:qna/qna.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/box/views/box_search_view.dart';
import '../modules/box/bindings/box_search_binding.dart';
import '../modules/box/views/box_create_view.dart';
import '../modules/box/bindings/box_create_binding.dart';
import '../modules/wod/views/home_view.dart';
import '../modules/wod/bindings/home_binding.dart';
import '../modules/wod/views/wod_register_view.dart';
import '../modules/wod/bindings/wod_register_binding.dart';
import '../modules/wod/views/wod_detail_view.dart';
import '../modules/wod/bindings/wod_detail_binding.dart';
import '../modules/wod/views/wod_select_view.dart';
import '../modules/wod/bindings/wod_select_binding.dart';
import '../modules/wod/views/proposal_review_view.dart';
import '../modules/wod/bindings/proposal_review_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
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
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.BOX_SEARCH,
      page: () => const BoxSearchView(),
      binding: BoxSearchBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.BOX_CREATE,
      page: () => const BoxCreateView(),
      binding: BoxCreateBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.WOD_REGISTER,
      page: () => const WodRegisterView(),
      binding: WodRegisterBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.WOD_DETAIL,
      page: () => const WodDetailView(),
      binding: WodDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.WOD_SELECT,
      page: () => const WodSelectView(),
      binding: WodSelectBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.PROPOSAL_REVIEW,
      page: () => const ProposalReviewView(),
      binding: ProposalReviewBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.QNA,
      page: () => const QnaSubmitView(),
      binding: QnaBinding(appCode: 'wowa'),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
