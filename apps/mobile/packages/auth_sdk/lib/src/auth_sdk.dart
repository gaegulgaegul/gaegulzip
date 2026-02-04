import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:core/core.dart';
import 'services/auth_api_service.dart';
import 'services/auth_state_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'repositories/auth_repository.dart';
import 'providers/social_login_provider.dart';
import 'models/login_response.dart';

/// 소셜 로그인 프로바이더 열거형
enum SocialProvider {
  kakao,
  naver,
  google,
  apple,
}

/// 프로바이더별 설정
class ProviderConfig {
  /// 클라이언트 ID (네이티브 SDK 설정용)
  final String? clientId;

  /// 클라이언트 시크릿 (iOS 앱 전용)
  final String? clientSecret;

  const ProviderConfig({
    this.clientId,
    this.clientSecret,
  });
}

/// Auth SDK - 재사용 가능한 소셜 로그인 패키지
///
/// 카카오, 네이버, 구글, 애플 소셜 로그인을 지원하며,
/// 인증 상태 관리, 토큰 자동 갱신, API 통신을 제공합니다.
///
/// 사용법:
/// ```dart
/// // main.dart에서 초기화
/// await AuthSdk.initialize(
///   appCode: 'wowa',
///   apiBaseUrl: 'https://api.example.com',
///   providers: {
///     SocialProvider.kakao: ProviderConfig(clientId: 'xxx'),
///     SocialProvider.naver: ProviderConfig(clientId: 'xxx', clientSecret: 'xxx'),
///   },
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
  static String? _appCode;
  static bool _initialized = false;

  /// SDK 초기화
  ///
  /// [appCode] 앱 코드 (서버에서 앱 식별용)
  /// [apiBaseUrl] API 베이스 URL
  /// [providers] 프로바이더별 OAuth 설정
  /// [secureStorage] 토큰 저장소 (기본: flutter_secure_storage)
  static Future<void> initialize({
    required String appCode,
    required String apiBaseUrl,
    required Map<SocialProvider, ProviderConfig> providers,
    SecureStorageService? secureStorage,
  }) async {
    if (_initialized) {
      throw Exception('AuthSdk는 이미 초기화되었습니다');
    }

    _appCode = appCode;

    // SecureStorageService 초기화 (필요 시)
    if (secureStorage != null) {
      Get.put<SecureStorageService>(secureStorage);
    } else if (!Get.isRegistered<SecureStorageService>()) {
      Get.put<SecureStorageService>(SecureStorageService());
    }

    // Dio 초기화 (필요 시)
    if (!Get.isRegistered<Dio>()) {
      final dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));
      Get.put<Dio>(dio);
    }

    // AuthApiService 등록
    Get.lazyPut<AuthApiService>(() => AuthApiService());

    // AuthRepository 등록
    Get.lazyPut<AuthRepository>(() => AuthRepository());

    // AuthInterceptor 등록
    final dio = Get.find<Dio>();
    dio.interceptors.add(AuthInterceptor());

    // AuthStateService 초기화
    await Get.putAsync(() => AuthStateService().init());

    _initialized = true;
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

    // 2. 서버 API 호출 (AuthRepository.login은 UserModel 반환)
    final user = await authRepository.login(
      provider: socialProvider.platformName,
      accessToken: accessToken,
    );

    // 3. 인증 상태 업데이트
    final authState = Get.find<AuthStateService>();
    authState.onLoginSuccess();

    // 4. Storage에서 토큰 정보 조회
    final storage = Get.find<SecureStorageService>();
    final storedAccessToken = await storage.getAccessToken();
    final storedRefreshToken = await storage.getRefreshToken();

    // 5. LoginResponse 객체 반환
    return LoginResponse(
      accessToken: storedAccessToken ?? '',
      refreshToken: storedRefreshToken ?? '',
      tokenType: 'Bearer',
      expiresIn: 1800, // 30분 (서버 기본값)
      user: user,
      token: storedAccessToken ?? '',
    );
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
    // 프로바이더 구현체는 앱에서 직접 등록해야 합니다.
    // 여기서는 Get.find로 찾습니다.
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
  static String get appCode {
    if (_appCode == null) {
      throw Exception('AuthSdk.initialize()를 먼저 호출하세요');
    }
    return _appCode!;
  }
}
