import 'dart:io';

import 'package:admob/admob.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:push/push.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경변수 로드
  await dotenv.load(fileName: ".env");

  // 2. Dio 초기화
  Get.put(Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!)));

  // 3. AdMob 초기화
  final adMobService = Get.put(AdMobService());
  await adMobService.initialize();

  // 4. PushApiClient 전역 등록 (디바이스 토큰 자동 등록에 필요)
  Get.put(PushApiClient());

  // 5. PushService 초기화
  final pushService = Get.put(PushService(), permanent: true);
  await pushService.initialize();

  // 6. 포그라운드 알림 핸들러 (인앱 스낵바 표시)
  pushService.onForegroundMessage = (notification) {
    Get.snackbar(
      notification.title.isNotEmpty ? notification.title : '새 알림',
      notification.body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      onTap: (_) {
        final screen = notification.data['screen'] as String?;
        if (screen != null && screen.isNotEmpty) {
          Get.toNamed('/$screen', arguments: notification.data);
        }
      },
    );
  };

  // 7. 백그라운드/종료 상태 알림 탭 핸들러 (딥링크 이동)
  void handleDeepLink(PushNotification notification) {
    final screen = notification.data['screen'] as String?;
    if (screen != null && screen.isNotEmpty) {
      Get.toNamed('/$screen', arguments: notification.data);
    }
  }

  pushService.onBackgroundMessageOpened = handleDeepLink;
  pushService.onTerminatedMessageOpened = handleDeepLink;

  // 8. 디바이스 토큰 변경 시 서버에 자동 등록
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
    return GetMaterialApp(
      title: 'Wowa App',
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
