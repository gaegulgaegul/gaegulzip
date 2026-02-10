import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

/// 홈 화면 View
///
/// 디자인 시스템 카탈로그의 메인 화면을 표시합니다.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<SketchThemeController>();

    return Scaffold(
      appBar: _buildAppBar(themeController),
      body: _buildBody(context),
    );
  }

  /// AppBar 빌드
  AppBar _buildAppBar(SketchThemeController themeController) {
    return AppBar(
      title: const Text('Sketch Design System'),
      centerTitle: true,
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              themeController.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => themeController.toggleBrightness(),
            tooltip: themeController.isDarkMode ? '라이트 모드' : '다크 모드',
          ),
        ),
      ],
    );
  }

  /// Body 빌드
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: SketchDesignTokens.spacingLg,
          crossAxisSpacing: SketchDesignTokens.spacingLg,
          childAspectRatio: 1.0,
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  /// 카테고리 카드 빌드
  ///
  /// SketchCard 테두리 없이 깔끔한 카드 스타일 사용.
  /// Frame0 스타일: 컴포넌트만 스케치 테두리, 레이아웃 컨테이너는 깔끔하게.
  Widget _buildCategoryCard(BuildContext context, CategoryItem category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : SketchDesignTokens.white;

    return GestureDetector(
      onTap: () => controller.navigateTo(category.route),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(SketchDesignTokens.radiusXl),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 48,
            ),
            const SizedBox(height: SketchDesignTokens.spacingMd),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: SketchDesignTokens.fontSizeBase,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (category.itemCount != null) ...[
              const SizedBox(height: SketchDesignTokens.spacingXs),
              Text(
                '${category.itemCount} items',
                style: const TextStyle(
                  fontSize: SketchDesignTokens.fontSizeSm,
                  color: SketchDesignTokens.base500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
