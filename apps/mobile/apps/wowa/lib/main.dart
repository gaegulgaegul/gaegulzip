import 'package:admob/admob.dart';
import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:push/push.dart';
import 'package:auth_sdk/auth_sdk.dart';
import 'package:notice/notice.dart';
import 'package:design_system/design_system.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경변수 로드
  await dotenv.load(fileName: ".env");

  // 2. API_BASE_URL 확인
  final apiBaseUrl = dotenv.env['API_BASE_URL'];
  if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
    throw Exception('API_BASE_URL이 .env 파일에 설정되지 않았습니다');
  }

  // 3. 소셜 로그인 환경변수 검증
  final kakaoAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  final googleClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
  if (kakaoAppKey == null || kakaoAppKey.isEmpty) {
    Logger.warn('KAKAO_NATIVE_APP_KEY가 .env에 설정되지 않았습니다. 카카오 로그인이 동작하지 않습니다.');
  }
  if (googleClientId == null || googleClientId.isEmpty) {
    Logger.warn('GOOGLE_SERVER_CLIENT_ID가 .env에 설정되지 않았습니다. 구글 로그인이 동작하지 않습니다.');
  }

  // 4. AuthSdk 초기화 (AuthSdkConfig 객체로 전달)
  await AuthSdk.initialize(
    AuthSdkConfig(
      appCode: 'wowa',
      apiBaseUrl: apiBaseUrl,
      homeRoute: Routes.HOME,
      showBrowseButton: true,
      providers: {
        SocialProvider.kakao: ProviderConfig(clientId: kakaoAppKey),
        SocialProvider.naver: const ProviderConfig(),
        SocialProvider.google: ProviderConfig(clientId: googleClientId),
        SocialProvider.apple: const ProviderConfig(),
      },
      onPreLogout: () async {
        final pushService = Get.find<PushService>();
        await pushService.deactivateDeviceTokenOnServer();
      },
    ),
  );

  // 5. Firebase 초기화 (AdMob, Push 등 Firebase 의존 서비스보다 먼저)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 6. AdMob 초기화
  final adMobService = Get.put(AdMobService());
  await adMobService.initialize();

  // 7. PushApiClient 전역 등록 (디바이스 토큰 자동 등록에 필요)
  Get.put(PushApiClient());

  // 8. NoticeApiService 전역 등록
  Get.put<NoticeApiService>(NoticeApiService(), permanent: true);

  // 9. PushService 생성 + 토큰/인증 워처 등록 (initialize 전에 등록해야 초기 토큰 감지 가능)
  final pushService = Get.put(PushService(), permanent: true);

  // 디바이스 토큰 서버 등록 헬퍼 (인증 + 토큰 조건 확인, 실패해도 앱 계속 실행)
  Future<void> registerDeviceToken() async {
    final token = pushService.deviceToken.value;
    if (token == null || token.isEmpty) return;
    if (!AuthSdk.authState.isAuthenticated) return;

    try {
      await pushService.registerDeviceTokenToServer();
    } catch (e) {
      Logger.error('디바이스 토큰 서버 등록 실패', error: e);
    }
  }

  // 디바이스 토큰 변경 시 서버에 자동 등록
  ever(pushService.deviceToken, (_) async {
    await registerDeviceToken();
  });

  // 인증 상태 변경 시에도 토큰 등록 시도 (로그인 후 토큰 이미 발급된 경우 대응)
  ever(AuthSdk.authState.status, (status) async {
    if (status == AuthStatus.authenticated) await registerDeviceToken();
  });

  // 10. PushService 초기화 (실패해도 앱 계속 실행)
  try {
    await pushService.initialize();
  } catch (e) {
    Logger.error('PushService 초기화 실패, 푸시 알림 없이 계속 진행', error: e);
  }

  // 11. 포그라운드 알림 핸들러 (인앱 스낵바 표시)
  pushService.onForegroundMessage = (notification) {
    Get.snackbar(
      notification.title.isNotEmpty ? notification.title : '새 알림',
      notification.body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      onTap: (_) {
        final screen = notification.data['screen'] as String?;
        if (screen != null && Routes.deepLinkAllowedScreens.contains(screen)) {
          Get.toNamed('/$screen', arguments: notification.data);
        }
      },
    );
  };

  // 12. 백그라운드/종료 상태 알림 탭 핸들러 (딥링크 이동)
  void handleDeepLink(PushNotification notification) {
    final screen = notification.data['screen'] as String?;
    if (screen != null && Routes.deepLinkAllowedScreens.contains(screen)) {
      Get.toNamed('/$screen', arguments: notification.data);
    }
  }

  pushService.onBackgroundMessageOpened = handleDeepLink;
  pushService.onTerminatedMessageOpened = handleDeepLink;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 인증 상태에 따라 초기 라우트 결정
    final authService = AuthSdk.authState;
    final initialRoute =
        authService.isAuthenticated ? Routes.HOME : Routes.LOGIN;

    return GetMaterialApp(
      title: 'Wowa App',
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(
        Brightness.light,
        const SketchThemeExtension(fillColor: SketchDesignTokens.background),
      ),
      darkTheme: _buildTheme(Brightness.dark, SketchThemeExtension.dark()),
    );
  }

  /// 스케치 스타일 테마 빌드
  ThemeData _buildTheme(Brightness brightness, SketchThemeExtension ext) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor =
        isDark ? SketchDesignTokens.base900 : SketchDesignTokens.base100;
    final surfaceColor =
        isDark ? SketchDesignTokens.surfaceDark : SketchDesignTokens.white;
    final textColor =
        isDark ? SketchDesignTokens.white : SketchDesignTokens.base900;

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
          fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
          fontSize: SketchDesignTokens.fontSizeXl,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      extensions: [ext],
    );
  }
}
