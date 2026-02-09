import 'dart:io';

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

  // 3. AuthSdk 초기화
  await AuthSdk.initialize(
    appCode: 'wowa',
    apiBaseUrl: apiBaseUrl,
    providers: {
      SocialProvider.kakao: ProviderConfig(clientId: dotenv.env['KAKAO_NATIVE_APP_KEY']),
      SocialProvider.naver: const ProviderConfig(),
      SocialProvider.google: const ProviderConfig(),
      SocialProvider.apple: const ProviderConfig(),
    },
  );

  // 4. Firebase 초기화 (AdMob, Push 등 Firebase 의존 서비스보다 먼저)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 5. AdMob 초기화
  final adMobService = Get.put(AdMobService());
  await adMobService.initialize();

  // 6. PushApiClient 전역 등록 (디바이스 토큰 자동 등록에 필요)
  Get.put(PushApiClient());

  // 7. NoticeApiService 전역 등록
  Get.put<NoticeApiService>(NoticeApiService(), permanent: true);

  // 8. PushService 초기화 (실패해도 앱 계속 실행)
  final pushService = Get.put(PushService(), permanent: true);
  try {
    await pushService.initialize();
  } catch (e) {
    Logger.error('PushService 초기화 실패, 푸시 알림 없이 계속 진행', error: e);
  }

  // 9. 포그라운드 알림 핸들러 (인앱 스낵바 표시)
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

  // 11. 백그라운드/종료 상태 알림 탭 핸들러 (딥링크 이동)
  void handleDeepLink(PushNotification notification) {
    final screen = notification.data['screen'] as String?;
    if (screen != null && Routes.deepLinkAllowedScreens.contains(screen)) {
      Get.toNamed('/$screen', arguments: notification.data);
    }
  }

  pushService.onBackgroundMessageOpened = handleDeepLink;
  pushService.onTerminatedMessageOpened = handleDeepLink;

  // 12. 디바이스 토큰 변경 시 서버에 자동 등록
  final pushApiClient = Get.find<PushApiClient>();
  ever(pushService.deviceToken, (String? token) async {
    if (token != null && token.isNotEmpty) {
      try {
        await pushApiClient.registerDevice(DeviceTokenRequest(
          token: token,
          platform: Platform.isIOS ? 'ios' : 'android',
        ));
      } catch (e) {
        Logger.error('디바이스 토큰 등록 실패', error: e);
      }
    }
  });

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
