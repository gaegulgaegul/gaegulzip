import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../routes/app_routes.dart';

/// 홈 화면 카테고리 데이터 모델
class CategoryItem {
  /// 카테고리 이름
  final String name;

  /// 카테고리 아이콘
  final IconData icon;

  /// 네비게이션 라우트
  final String route;

  /// 아이템 수 (null이면 표시하지 않음)
  final int? itemCount;

  /// 카테고리 설명
  final String description;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.route,
    this.itemCount,
    required this.description,
  });
}

/// 홈 화면 컨트롤러
///
/// 디자인 시스템 카탈로그의 메인 카테고리를 관리합니다.
class HomeController extends GetxController {
  /// 카테고리 목록
  final List<CategoryItem> categories = const [
    CategoryItem(
      name: 'Widgets',
      icon: LucideIcons.layoutGrid,
      route: Routes.WIDGET_CATALOG,
      itemCount: 13,
      description: '스케치 스타일 UI 컴포넌트',
    ),
    CategoryItem(
      name: 'Painters',
      icon: LucideIcons.paintbrush,
      route: Routes.PAINTER_CATALOG,
      itemCount: 5,
      description: 'CustomPainter 기반 그래픽',
    ),
    CategoryItem(
      name: 'Theme',
      icon: LucideIcons.palette,
      route: Routes.THEME_SHOWCASE,
      itemCount: 6,
      description: '테마 변형 및 밝기 모드',
    ),
    CategoryItem(
      name: 'Colors',
      icon: LucideIcons.droplets,
      route: Routes.COLOR_PALETTES,
      itemCount: 6,
      description: 'Base, Semantic, Custom 팔레트',
    ),
    CategoryItem(
      name: 'Tokens',
      icon: LucideIcons.ruler,
      route: Routes.TOKENS,
      description: 'Spacing, Stroke, Shadow 토큰',
    ),
    CategoryItem(
      name: 'SDK Demos',
      icon: LucideIcons.package,
      route: Routes.SDK_DEMOS,
      itemCount: 2,
      description: 'QnA 및 Notice SDK 데모',
    ),
  ];

  /// 카테고리로 네비게이션
  ///
  /// [route] 이동할 라우트 경로
  void navigateTo(String route) {
    Get.toNamed(route);
  }
}
