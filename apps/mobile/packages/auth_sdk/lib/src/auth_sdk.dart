import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:core/core.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' show KakaoSdk;
import 'config/auth_sdk_config.dart';
export 'config/auth_sdk_config.dart' show SocialProvider, ProviderConfig;
import 'services/auth_api_service.dart';
import 'services/auth_state_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'repositories/auth_repository.dart';
import 'providers/social_login_provider.dart';
import 'providers/kakao_login_provider.dart';
import 'providers/naver_login_provider.dart';
import 'providers/google_login_provider.dart';
import 'providers/apple_login_provider.dart';
import 'models/login_response.dart';

/// Auth SDK - 재사용 가능한 소셜 로그인 패키지
///
/// 카카오, 네이버, 구글, 애플 소셜 로그인을 지원하며,
/// 인증 상태 관리, 토큰 자동 갱신, API 통신, 로그인 화면을 제공합니다.
///
/// 사용법:
/// ```dart
/// // main.dart에서 초기화
/// await AuthSdk.initialize(
///   AuthSdkConfig(
///     appCode: 'wowa',
///     apiBaseUrl: 'https://api.example.com',
///     homeRoute: '/home',
///     showBrowseButton: true,
///     providers: {
///       SocialProvider.kakao: ProviderConfig(clientId: 'xxx'),
///       SocialProvider.naver: ProviderConfig(clientId: 'xxx', clientSecret: 'xxx'),
///     },
///   ),
/// );
///
/// // 로그인
/// final response = await AuthSdk.login(SocialProvider.kakao);
///
/// // 로그아웃
/// await AuthSdk.logout();
///
/// // 인증 상태 확인
/// final isAuth = await AuthSdk.isAuthenticated();
/// ```
class AuthSdk {
  static AuthSdkConfig? _config;
  static bool _initialized = false;

  /// 현재 SDK 설정 (내부 사용 + UI 컴포넌트 접근용)
  static AuthSdkConfig get config {
    if (_config == null) {
      throw Exception('AuthSdk.initialize()를 먼저 호출하세요');
    }
    return _config!;
  }

  /// SDK 초기화
  ///
  /// [config] SDK 설정 객체
  static Future<void> initialize(AuthSdkConfig config) async {
    if (_initialized) {
      throw Exception('AuthSdk는 이미 초기화되었습니다');
    }

    try {
      _config = config;

      // 카카오 SDK 초기화
      final kakaoConfig = config.providers[SocialProvider.kakao];
      if (kakaoConfig?.clientId != null && kakaoConfig!.clientId!.isNotEmpty) {
        KakaoSdk.init(nativeAppKey: kakaoConfig.clientId!);
      }

      // SecureStorageService 초기화 (필요 시)
      if (config.secureStorage != null) {
        Get.put<SecureStorageService>(config.secureStorage!);
      } else if (!Get.isRegistered<SecureStorageService>()) {
        Get.put<SecureStorageService>(SecureStorageService());
      }

      // Dio 초기화 (필요 시)
      if (!Get.isRegistered<Dio>()) {
        final dio = Dio(BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
        Get.put<Dio>(dio);
      }

      // AuthApiService 등록
      if (!Get.isRegistered<AuthApiService>()) {
        Get.lazyPut<AuthApiService>(() => AuthApiService(), fenix: true);
      }

      // AuthRepository 등록
      if (!Get.isRegistered<AuthRepository>()) {
        Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
      }

      // AuthInterceptor 등록 (중복 방지)
      final dio = Get.find<Dio>();
      final hasAuthInterceptor = dio.interceptors.any((i) => i is AuthInterceptor);
      if (!hasAuthInterceptor) {
        dio.interceptors.add(AuthInterceptor());
      }

      // AuthStateService 초기화 (중복 등록 방지)
      if (!Get.isRegistered<AuthStateService>()) {
        await Get.putAsync(() => AuthStateService().init());
      }

      // 소셜 로그인 프로바이더 등록 (LoginBinding에서 이동)
      _registerProviders(config);

      _initialized = true;
    } catch (e) {
      _config = null;
      _initialized = false;
      rethrow;
    }
  }

  /// 소셜 로그인 프로바이더 등록 (tag로 구분)
  ///
  /// [config] SDK 설정
  static void _registerProviders(AuthSdkConfig config) {
    if (config.providers.containsKey(SocialProvider.kakao)) {
      Get.lazyPut<SocialLoginProvider>(
        () => KakaoLoginProvider(),
        tag: 'kakao',
      );
    }

    if (config.providers.containsKey(SocialProvider.naver)) {
      Get.lazyPut<SocialLoginProvider>(
        () => NaverLoginProvider(),
        tag: 'naver',
      );
    }

    if (config.providers.containsKey(SocialProvider.apple)) {
      Get.lazyPut<SocialLoginProvider>(
        () => AppleLoginProvider(),
        tag: 'apple',
      );
    }

    if (config.providers.containsKey(SocialProvider.google)) {
      final googleConfig = config.providers[SocialProvider.google];
      Get.lazyPut<SocialLoginProvider>(
        () => GoogleLoginProvider(
          serverClientId: googleConfig?.clientId,
        ),
        tag: 'google',
      );
    }
  }

  /// 소셜 로그인
  ///
  /// [provider] 소셜 플랫폼
  ///
  /// Returns: [LoginResponse] 로그인 응답 (토큰, 사용자 정보)
  ///
  /// Throws:
  ///   - [Exception] SDK 미초기화
  ///   - [AuthException] 인증 오류
  ///   - [NetworkException] 네트워크 오류
  static Future<LoginResponse> login(SocialProvider provider) async {
    _ensureInitialized();

    final authRepository = Get.find<AuthRepository>();
    final socialProvider = _getProvider(provider);

    // 1. 소셜 SDK로 OAuth 인증
    final accessToken = await socialProvider.signIn();

    // 2. 서버 API 호출 (토큰 + 사용자 정보 포함)
    final response = await authRepository.login(
      provider: socialProvider.platformName,
      accessToken: accessToken,
    );

    // 3. 인증 상태 업데이트
    final authState = Get.find<AuthStateService>();
    authState.onLoginSuccess();

    // 4. 서버 응답 반환
    return response;
  }

  /// 로그아웃
  ///
  /// [revokeAll] true이면 사용자의 모든 토큰 무효화
  static Future<void> logout({bool revokeAll = false}) async {
    _ensureInitialized();

    final authState = Get.find<AuthStateService>();
    await authState.logout(revokeAll: revokeAll);
  }

  /// 인증 여부 확인
  ///
  /// Returns: 인증 상태
  static Future<bool> isAuthenticated() async {
    _ensureInitialized();

    final authState = Get.find<AuthStateService>();
    return authState.isAuthenticated;
  }

  /// 인증 상태 서비스 접근
  ///
  /// Returns: [AuthStateService] 인스턴스
  static AuthStateService get authState {
    _ensureInitialized();
    return Get.find<AuthStateService>();
  }

  /// 현재 사용자 정보 조회 (로컬 저장소에서)
  ///
  /// Returns: 사용자 ID, 프로바이더
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    _ensureInitialized();

    final storage = Get.find<SecureStorageService>();
    final userId = await storage.getUserId();
    final provider = await storage.getUserProvider();

    if (userId == null || provider == null) {
      return null;
    }

    return {
      'id': userId,
      'provider': provider,
    };
  }

  /// SDK 초기화 확인
  static void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('AuthSdk.initialize()를 먼저 호출하세요');
    }
  }

  /// 프로바이더 인스턴스 가져오기
  static SocialLoginProvider _getProvider(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.kakao:
        return Get.find<SocialLoginProvider>(tag: 'kakao');
      case SocialProvider.naver:
        return Get.find<SocialLoginProvider>(tag: 'naver');
      case SocialProvider.google:
        return Get.find<SocialLoginProvider>(tag: 'google');
      case SocialProvider.apple:
        return Get.find<SocialLoginProvider>(tag: 'apple');
    }
  }

  /// 앱 코드 반환 (내부 사용)
  static String get appCode => config.appCode;
}
