import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

/// 앱 엔트리포인트
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 테마 컨트롤러 초기화
  Get.put(SketchThemeController());

  runApp(const MyApp());
}

/// 메인 앱 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<SketchThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Sketch Design System',
        initialRoute: Routes.HOME,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light, themeController.currentTheme),
        darkTheme: _buildTheme(Brightness.dark, SketchThemeExtension.dark()),
        themeMode: themeController.themeMode.value,
      ),
    );
  }

  /// 스케치 스타일 테마 빌드
  ///
  /// PatrickHand 폰트를 기본으로 설정하고,
  /// 스케치 느낌의 배경색과 앱바 스타일을 적용합니다.
  ThemeData _buildTheme(Brightness brightness, SketchThemeExtension ext) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark
        ? SketchDesignTokens.base900
        : SketchDesignTokens.base100;
    final surfaceColor = isDark
        ? const Color(0xFF2A2A2A)
        : SketchDesignTokens.white;
    final textColor = isDark
        ? SketchDesignTokens.white
        : SketchDesignTokens.base900;

    return ThemeData(
      brightness: brightness,
      fontFamily: SketchDesignTokens.fontFamilyHand,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SketchDesignTokens.accentPrimary,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyHand,
          fontSize: SketchDesignTokens.fontSizeXl,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      extensions: [ext],
    );
  }
}
