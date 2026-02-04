import 'package:admob/admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경변수 로드
  await dotenv.load(fileName: ".env");

  // 2. AuthSdk 초기화
  await AuthSdk.initialize(
    appCode: 'wowa',
    apiBaseUrl: dotenv.env['API_BASE_URL']!,
    providers: {
      SocialProvider.kakao: const ProviderConfig(),
      SocialProvider.naver: const ProviderConfig(),
      SocialProvider.google: const ProviderConfig(),
      SocialProvider.apple: const ProviderConfig(),
    },
  );

  // 3. AdMob 초기화
  final adMobService = Get.put(AdMobService());
  await adMobService.initialize();

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
