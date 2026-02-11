import 'package:get/get.dart';
import 'package:qna/qna.dart';
import 'package:notice/notice.dart';

import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/widgets/views/widget_catalog_view.dart';
import '../modules/widgets/bindings/widget_catalog_binding.dart';
import '../modules/widgets/views/widget_demo_view.dart';
import '../modules/painters/views/painter_catalog_view.dart';
import '../modules/painters/bindings/painter_catalog_binding.dart';
import '../modules/painters/views/painter_demo_view.dart';
import '../modules/theme/views/theme_showcase_view.dart';
import '../modules/theme/bindings/theme_showcase_binding.dart';
import '../modules/colors/views/color_palette_view.dart';
import '../modules/colors/bindings/color_palette_binding.dart';
import '../modules/tokens/views/tokens_view.dart';
import '../modules/tokens/bindings/tokens_binding.dart';
import '../modules/sdk_demos/views/sdk_list_view.dart';
import '../modules/sdk_demos/bindings/sdk_list_binding.dart';
import '../modules/sdk_demos/views/sdk_qna_demo_view.dart';
import '../modules/sdk_demos/views/sdk_notice_demo_view.dart';
import 'app_routes.dart';

/// 앱 페이지 정의
///
/// 모든 라우트와 해당하는 View, Binding을 등록합니다.
class AppPages {
  /// GetPage 리스트
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 위젯 카탈로그
    GetPage(
      name: Routes.WIDGET_CATALOG,
      page: () => const WidgetCatalogView(),
      binding: WidgetCatalogBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 위젯 데모
    GetPage(
      name: Routes.WIDGET_DEMO,
      page: () => const WidgetDemoView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 페인터 카탈로그
    GetPage(
      name: Routes.PAINTER_CATALOG,
      page: () => const PainterCatalogView(),
      binding: PainterCatalogBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 페인터 데모
    GetPage(
      name: Routes.PAINTER_DEMO,
      page: () => const PainterDemoView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 테마 쇼케이스
    GetPage(
      name: Routes.THEME_SHOWCASE,
      page: () => const ThemeShowcaseView(),
      binding: ThemeShowcaseBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 컬러 팔레트
    GetPage(
      name: Routes.COLOR_PALETTES,
      page: () => const ColorPaletteView(),
      binding: ColorPaletteBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 디자인 토큰
    GetPage(
      name: Routes.TOKENS,
      page: () => const TokensView(),
      binding: TokensBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // SDK 데모 목록
    GetPage(
      name: Routes.SDK_DEMOS,
      page: () => const SdkListView(),
      binding: SdkListBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // QnA SDK 데모 (실서버 연동)
    GetPage(
      name: Routes.SDK_QNA_DEMO,
      page: () => const SdkQnaDemoView(),
      binding: QnaBinding(appCode: 'demo'),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Notice SDK 데모 (실서버 연동)
    GetPage(
      name: Routes.SDK_NOTICE_DEMO,
      page: () => const SdkNoticeDemoView(),
      binding: NoticeBinding(appCode: 'demo'),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // 공지사항 상세 (Notice SDK 내부 네비게이션용)
    GetPage(
      name: Routes.NOTICE_DETAIL,
      page: () => const NoticeDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NoticeDetailController>(
          () => NoticeDetailController()..appCode = 'demo',
        );
      }),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
