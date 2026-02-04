import 'package:admob/admob.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'app/data/repositories/auth_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/interceptors/auth_interceptor.dart';
import 'app/services/auth_state_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경변수 로드
  await dotenv.load(fileName: ".env");

  // 2. Dio 초기화
  Get.put(Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!)));

  // 3. 인증 관련 서비스 초기화
  Get.put(SecureStorageService());
  Get.put(AuthApiService());
  Get.put(AuthRepository());
  await Get.putAsync(() => AuthStateService().init());

  // 4. Dio 인터셉터 등록 (AuthStateService 초기화 이후)
  Get.find<Dio>().interceptors.add(AuthInterceptor());

  // 5. AdMob 초기화
  final adMobService = Get.put(AdMobService());
  await adMobService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 인증 상태에 따라 초기 라우트 결정
    final authService = Get.find<AuthStateService>();
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
