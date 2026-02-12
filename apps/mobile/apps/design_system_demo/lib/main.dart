import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:notice/notice.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

/// 앱 엔트리포인트
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경변수 로드
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    Logger.warn('환경변수 파일(.env) 로드 실패: $e');
  }

  // 2. API_BASE_URL 확인
  final apiBaseUrl = dotenv.env['API_BASE_URL'];
  if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
    throw Exception('API_BASE_URL이 .env 파일에 설정되지 않았습니다');
  }

  // 3. Dio 직접 등록 (JWT 인증 없이 동작)
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  Get.put<Dio>(dio, permanent: true);

  // 4. NoticeApiService 전역 등록
  Get.put<NoticeApiService>(NoticeApiService(), permanent: true);

  // 5. 테마 컨트롤러 초기화
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
