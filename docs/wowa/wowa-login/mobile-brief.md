# 기술 아키텍처 설계: wowa 로그인 화면 SDK 재사용성 개선

## 개요

wowa 앱의 로그인 화면 컴포넌트(LoginView, LoginController, LoginBinding)를 auth_sdk 패키지로 이동하여 모든 앱에서 재사용 가능한 SDK로 전환합니다. SDK 독립성 원칙을 준수하며, 앱별 커스터마이징(homeRoute, showBrowseButton)을 설정 객체로 주입받아 처리합니다.

**설계 목표**:
1. auth_sdk 패키지에서 완전한 로그인 화면 제공 (View, Controller, Binding)
2. 앱 독립성 보장 (하드코딩된 라우트 제거, config로 주입)
3. 기존 wowa 앱 동작 100% 유지
4. GetX 패턴 준수 (Controller, View, Binding 분리)

## 핵심 설계 과제

### 1. AuthSdk.initialize() 확장
**현재**: appCode, apiBaseUrl, providers만 설정
**변경**: UI 관련 설정 추가 → AuthSdkConfig 클래스로 통합

```dart
class AuthSdkConfig {
  final String appCode;
  final String apiBaseUrl;
  final Map<SocialProvider, ProviderConfig> providers;

  // 새로 추가되는 UI 설정
  final String homeRoute;               // 로그인 성공 후 이동 라우트
  final bool showBrowseButton;          // 둘러보기 버튼 표시 여부
  final SecureStorageService? secureStorage; // 기존 유지
}
```

### 2. LoginController 앱 독립성 확보
**문제점**: `Get.offAllNamed(Routes.HOME)` 하드코딩 (wowa 앱에 의존)
**해결책**: AuthSdk에서 homeRoute를 주입받아 사용

```dart
// Before (wowa 앱 의존)
Get.offAllNamed(Routes.HOME);

// After (SDK 독립)
Get.offAllNamed(AuthSdk.config.homeRoute);
```

### 3. LoginBinding 프로바이더 등록 이동
**현재**: wowa 앱의 LoginBinding에서 4개 프로바이더 등록
**변경**: AuthSdk.initialize()에서 프로바이더 등록 → LoginBinding 단순화

### 4. LoginView 둘러보기 버튼 조건부 렌더링
**현재**: TextButton이 항상 표시됨
**변경**: `if (AuthSdk.config.showBrowseButton)` 조건문 추가

## 모듈 구조

### auth_sdk 패키지 디렉토리 구조 (변경 후)

```
packages/auth_sdk/
├── lib/
│   ├── src/
│   │   ├── config/
│   │   │   └── auth_sdk_config.dart        # 새로 추가: SDK 설정 클래스
│   │   ├── ui/                              # 새로 추가: UI 컴포넌트
│   │   │   ├── controllers/
│   │   │   │   └── login_controller.dart   # wowa에서 이동
│   │   │   ├── views/
│   │   │   │   └── login_view.dart         # wowa에서 이동
│   │   │   └── bindings/
│   │   │       └── login_binding.dart      # wowa에서 이동
│   │   ├── providers/                       # 기존 유지
│   │   ├── services/                        # 기존 유지
│   │   ├── repositories/                    # 기존 유지
│   │   ├── interceptors/                    # 기존 유지
│   │   ├── models/                          # 기존 유지
│   │   └── auth_sdk.dart                    # 수정: initialize() 확장
│   └── auth_sdk.dart                        # 수정: LoginView, LoginController, LoginBinding export
└── pubspec.yaml
```

### wowa 앱 디렉토리 구조 (변경 후)

```
apps/wowa/lib/app/modules/
├── login/                                    # 삭제: 전체 모듈 제거
└── home/                                     # 기존 유지
```

```
apps/wowa/lib/app/routes/
├── app_routes.dart                           # 수정: Routes.LOGIN은 유지 (경로만)
└── app_pages.dart                            # 수정: auth_sdk의 LoginView, LoginBinding import
```

## 1️⃣ AuthSdkConfig 클래스 설계 (Senior Developer)

### 파일: `packages/auth_sdk/lib/src/config/auth_sdk_config.dart`

```dart
/// Auth SDK 설정 클래스
///
/// SDK 초기화 시 필요한 모든 설정을 담는 불변 객체
class AuthSdkConfig {
  /// 앱 식별 코드 (예: 'wowa')
  final String appCode;

  /// API 기본 URL (예: 'https://api.gaegulzip.com')
  final String apiBaseUrl;

  /// 소셜 프로바이더별 OAuth 설정
  final Map<SocialProvider, ProviderConfig> providers;

  /// 로그인 성공 후 이동할 라우트 (기본값: '/home')
  final String homeRoute;

  /// 둘러보기 버튼 표시 여부 (기본값: false)
  final bool showBrowseButton;

  /// 커스텀 SecureStorage (선택적)
  final SecureStorageService? secureStorage;

  const AuthSdkConfig({
    required this.appCode,
    required this.apiBaseUrl,
    required this.providers,
    this.homeRoute = '/home',
    this.showBrowseButton = false,
    this.secureStorage,
  });
}
```

**설계 근거**:
- 불변 객체 (const 생성자)로 설정 안전성 보장
- 기본값 제공 (`homeRoute: '/home'`, `showBrowseButton: false`)
- 기존 providers 파라미터 유지 (기존 API 호환성)

## 2️⃣ AuthSdk 클래스 수정 (Senior Developer)

### 파일: `packages/auth_sdk/lib/src/auth_sdk.dart`

#### 변경 사항

**1. config 필드 추가**

```dart
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
}
```

**2. initialize() 메서드 시그니처 변경**

```dart
/// SDK 초기화 (AuthSdkConfig 객체로 단순화)
///
/// [config] SDK 설정 객체
static Future<void> initialize(AuthSdkConfig config) async {
  if (_initialized) {
    throw Exception('AuthSdk는 이미 초기화되었습니다');
  }

  _config = config;

  // 카카오 SDK 초기화
  final kakaoConfig = config.providers[SocialProvider.kakao];
  if (kakaoConfig?.clientId != null && kakaoConfig!.clientId!.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: kakaoConfig.clientId!);
  }

  // SecureStorageService 초기화
  if (config.secureStorage != null) {
    Get.put<SecureStorageService>(config.secureStorage!);
  } else if (!Get.isRegistered<SecureStorageService>()) {
    Get.put<SecureStorageService>(SecureStorageService());
  }

  // Dio 초기화
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
    Get.lazyPut<AuthApiService>(() => AuthApiService());
  }

  // AuthRepository 등록
  if (!Get.isRegistered<AuthRepository>()) {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
  }

  // AuthInterceptor 등록
  final dio = Get.find<Dio>();
  final hasAuthInterceptor = dio.interceptors.any((i) => i is AuthInterceptor);
  if (!hasAuthInterceptor) {
    dio.interceptors.add(AuthInterceptor());
  }

  // AuthStateService 초기화
  await Get.putAsync(() => AuthStateService().init());

  // SocialLoginProvider 등록 (LoginBinding에서 이동)
  _registerProviders(config);

  _initialized = true;
}
```

**3. _registerProviders() 메서드 추가**

```dart
/// 소셜 로그인 프로바이더 등록 (tag로 구분)
///
/// [config] SDK 설정
static void _registerProviders(AuthSdkConfig config) {
  // Kakao
  if (config.providers.containsKey(SocialProvider.kakao)) {
    Get.lazyPut<SocialLoginProvider>(
      () => KakaoLoginProvider(),
      tag: 'kakao',
    );
  }

  // Naver
  if (config.providers.containsKey(SocialProvider.naver)) {
    Get.lazyPut<SocialLoginProvider>(
      () => NaverLoginProvider(),
      tag: 'naver',
    );
  }

  // Apple
  if (config.providers.containsKey(SocialProvider.apple)) {
    Get.lazyPut<SocialLoginProvider>(
      () => AppleLoginProvider(),
      tag: 'apple',
    );
  }

  // Google
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
```

**4. appCode getter 수정**

```dart
/// 앱 코드 반환 (내부 사용)
static String get appCode {
  if (_config == null) {
    throw Exception('AuthSdk.initialize()를 먼저 호출하세요');
  }
  return _config!.appCode;
}
```

**설계 근거**:
- AuthSdkConfig 객체로 통합하여 파라미터 수 감소 (6개 → 1개)
- _registerProviders()로 프로바이더 등록 로직 캡슐화 (LoginBinding 중복 제거)
- config getter로 UI 컴포넌트가 설정 접근 가능

## 3️⃣ LoginController 수정 (Senior Developer)

### 파일: `packages/auth_sdk/lib/src/ui/controllers/login_controller.dart`

#### 변경 사항

**Import 수정**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../auth_sdk.dart'; // AuthSdk import
```

**Routes.HOME 제거, AuthSdk.config.homeRoute 사용**

```dart
Future<void> _handleSocialLogin({
  required SocialProvider provider,
  required RxBool loadingState,
}) async {
  try {
    loadingState.value = true;

    final loginResponse = await AuthSdk.login(provider);

    // 3. 성공 - SDK 설정의 homeRoute로 이동
    Get.offAllNamed(AuthSdk.config.homeRoute);
  } on AuthException catch (e) {
    // ... (기존 에러 처리 유지)
  } finally {
    loadingState.value = false;
  }
}
```

**나머지 코드 동일** (반응형 상태, 메서드, 에러 처리 모두 기존과 동일)

**설계 근거**:
- wowa 앱의 Routes 클래스 의존성 제거
- AuthSdk.config.homeRoute로 앱별 라우트 주입
- 에러 처리, 스낵바, 모달 로직은 모두 SDK 내부에서 처리 (앱 독립)

## 4️⃣ LoginView 수정 (Junior Developer)

### 파일: `packages/auth_sdk/lib/src/ui/views/login_view.dart`

#### 변경 사항

**Import 수정**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../controllers/login_controller.dart';
import '../../auth_sdk.dart'; // AuthSdk import
```

**Routes.HOME 제거, 둘러보기 버튼 조건부 렌더링**

```dart
class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 48),

                // 카카오 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.kakao,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isKakaoLoading.value,
                  onPressed: controller.handleKakaoLogin,
                )),
                const SizedBox(height: 16),

                // 네이버 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.naver,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isNaverLoading.value,
                  onPressed: controller.handleNaverLogin,
                )),
                const SizedBox(height: 16),

                // 애플 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.apple,
                  appleStyle: AppleSignInStyle.dark,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isAppleLoading.value,
                  onPressed: controller.handleAppleLogin,
                )),
                const SizedBox(height: 16),

                // 구글 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.google,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isGoogleLoading.value,
                  onPressed: controller.handleGoogleLogin,
                )),

                const Spacer(),

                // 둘러보기 버튼 (조건부 렌더링)
                if (AuthSdk.config.showBrowseButton)
                  TextButton(
                    onPressed: () => Get.toNamed(AuthSdk.config.homeRoute),
                    child: const Text('둘러보기'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      '로그인',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '소셜 계정으로 간편하게 시작하세요',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    );
  }
}
```

**설계 근거**:
- `if (AuthSdk.config.showBrowseButton)` 조건문으로 버튼 표시 제어
- `Get.toNamed(AuthSdk.config.homeRoute)`로 앱별 라우트 사용
- design-spec.md의 UI 구조 100% 준수 (기존 코드와 동일)

## 5️⃣ LoginBinding 수정 (Senior Developer)

### 파일: `packages/auth_sdk/lib/src/ui/bindings/login_binding.dart`

#### 변경 사항

**프로바이더 등록 제거, LoginController만 등록**

```dart
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// 로그인 화면 바인딩
///
/// LoginController만 등록 (프로바이더는 AuthSdk.initialize()에서 등록)
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // LoginController (lazyPut)
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
```

**설계 근거**:
- 프로바이더 등록은 AuthSdk.initialize()로 이동 (중복 제거)
- LoginBinding은 LoginController 생성만 담당 (단일 책임 원칙)
- dotenv 의존성 제거 (googleServerClientId는 AuthSdkConfig에서 주입)

## 6️⃣ auth_sdk.dart barrel export 수정 (Senior Developer)

### 파일: `packages/auth_sdk/lib/auth_sdk.dart`

```dart
/// Auth SDK - 재사용 가능한 소셜 로그인 패키지
///
/// 카카오, 네이버, 구글, 애플 소셜 로그인을 지원하며,
/// 인증 상태 관리, 토큰 자동 갱신, API 통신, 로그인 화면을 제공합니다.
library auth_sdk;

// 설정
export 'src/config/auth_sdk_config.dart';

// UI 컴포넌트 (새로 추가)
export 'src/ui/controllers/login_controller.dart';
export 'src/ui/views/login_view.dart';
export 'src/ui/bindings/login_binding.dart';

// 프로바이더
export 'src/providers/social_login_provider.dart';
export 'src/providers/kakao_login_provider.dart';
export 'src/providers/naver_login_provider.dart';
export 'src/providers/google_login_provider.dart';
export 'src/providers/apple_login_provider.dart';

// 서비스
export 'src/services/auth_state_service.dart';
export 'src/services/auth_api_service.dart';

// 인터셉터
export 'src/interceptors/auth_interceptor.dart';

// 리포지토리
export 'src/repositories/auth_repository.dart';

// 모델
export 'src/models/login_request.dart';
export 'src/models/login_response.dart';
export 'src/models/refresh_request.dart';
export 'src/models/refresh_response.dart';
export 'src/models/user_model.dart';

// 위젯 (design_system에서 재export)
export 'package:design_system/design_system.dart'
    show SocialLoginButton, SocialLoginPlatform, AppleSignInStyle, SocialLoginButtonSize;

// SDK 메인 클래스
export 'src/auth_sdk.dart';
```

**설계 근거**:
- LoginView, LoginController, LoginBinding을 public API로 노출
- SocialLoginButtonSize도 re-export (design-spec.md에서 사용)
- AuthSdkConfig도 export (앱에서 설정 객체 생성 시 필요)

## 7️⃣ wowa 앱 main.dart 수정 (Senior Developer)

### 파일: `apps/wowa/lib/main.dart`

#### 변경 사항

**AuthSdk.initialize() 호출 수정**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: '.env');

  // AuthSdk 초기화 (AuthSdkConfig 객체로 전달)
  await AuthSdk.initialize(
    AuthSdkConfig(
      appCode: 'wowa',
      apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'https://api.gaegulzip.com',
      homeRoute: Routes.HOME,         // wowa 앱의 홈 라우트
      showBrowseButton: true,          // 둘러보기 버튼 활성화
      providers: {
        SocialProvider.kakao: ProviderConfig(
          clientId: dotenv.env['KAKAO_NATIVE_APP_KEY'],
        ),
        SocialProvider.naver: ProviderConfig(
          clientId: dotenv.env['NAVER_CLIENT_ID'],
          clientSecret: dotenv.env['NAVER_CLIENT_SECRET'],
        ),
        SocialProvider.google: ProviderConfig(
          clientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
        ),
        SocialProvider.apple: ProviderConfig(),
      },
    ),
  );

  runApp(const WowaApp());
}
```

**설계 근거**:
- AuthSdkConfig 객체로 모든 설정 통합 (가독성 향상)
- `homeRoute: Routes.HOME`으로 wowa 앱 라우트 주입
- `showBrowseButton: true`로 둘러보기 활성화 (기존 동작 유지)

## 8️⃣ wowa 앱 app_pages.dart 수정 (Junior Developer)

### 파일: `apps/wowa/lib/app/routes/app_pages.dart`

#### 변경 사항

**LoginView, LoginBinding import 수정**

```dart
import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart'; // LoginView, LoginBinding import
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),       // auth_sdk에서 가져옴
      binding: LoginBinding(),             // auth_sdk에서 가져옴
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // ... (다른 라우트)
  ];
}
```

**설계 근거**:
- `package:auth_sdk/auth_sdk.dart`에서 LoginView, LoginBinding import
- wowa 앱의 login 모듈 디렉토리 제거 가능
- Routes.LOGIN 경로는 유지 (앱 내부 라우팅 일관성)

## 9️⃣ wowa 앱 app_routes.dart 수정 (Junior Developer)

### 파일: `apps/wowa/lib/app/routes/app_routes.dart`

**변경 없음** - Routes.LOGIN, Routes.HOME 경로는 그대로 유지

```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  // ... (다른 라우트)
}
```

**설계 근거**:
- 앱 내부 라우트 경로는 변경하지 않음 (기존 코드 호환성)
- auth_sdk는 경로를 정의하지 않고 주입받기만 함

## 라이브러리 의존성

### auth_sdk pubspec.yaml

**변경 없음** - 기존 의존성 유지

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5
  dio: ^5.4.0
  core:
    path: ../core
  design_system:
    path: ../design_system
  kakao_flutter_sdk_user: ^1.9.1+2
  flutter_naver_login: ^1.8.0
  google_sign_in: ^6.1.5
  sign_in_with_apple: ^5.0.0
```

**설계 근거**:
- design_system 패키지에서 SocialLoginButton 사용 (이미 의존 중)
- core 패키지에서 Logger, SecureStorageService, AuthException 사용

### wowa 앱 pubspec.yaml

**변경 없음** - auth_sdk 의존성 이미 존재

```yaml
dependencies:
  auth_sdk:
    path: ../../packages/auth_sdk
  design_system:
    path: ../../packages/design_system
  core:
    path: ../../packages/core
```

## 작업 분배 계획 (CTO가 참조)

### Senior Developer 작업

1. **AuthSdkConfig 클래스 작성** (`packages/auth_sdk/lib/src/config/auth_sdk_config.dart`)
   - 불변 객체 설계, 기본값 설정

2. **AuthSdk 클래스 수정** (`packages/auth_sdk/lib/src/auth_sdk.dart`)
   - initialize() 메서드 시그니처 변경
   - _registerProviders() 메서드 추가
   - config getter 추가

3. **LoginController 수정** (`packages/auth_sdk/lib/src/ui/controllers/login_controller.dart`)
   - Routes.HOME → AuthSdk.config.homeRoute 변경
   - import 경로 수정

4. **LoginBinding 단순화** (`packages/auth_sdk/lib/src/ui/bindings/login_binding.dart`)
   - 프로바이더 등록 제거
   - LoginController만 등록

5. **auth_sdk.dart barrel export 수정** (`packages/auth_sdk/lib/auth_sdk.dart`)
   - LoginView, LoginController, LoginBinding export 추가

6. **wowa 앱 main.dart 수정** (`apps/wowa/lib/main.dart`)
   - AuthSdkConfig 객체로 initialize() 호출 변경

### Junior Developer 작업

1. **LoginView 수정** (`packages/auth_sdk/lib/src/ui/views/login_view.dart`)
   - 둘러보기 버튼 조건부 렌더링 추가
   - Routes.HOME → AuthSdk.config.homeRoute 변경
   - import 경로 수정

2. **wowa 앱 app_pages.dart 수정** (`apps/wowa/lib/app/routes/app_pages.dart`)
   - LoginView, LoginBinding import 경로 변경

3. **wowa 앱 login 모듈 제거** (`apps/wowa/lib/app/modules/login/` 디렉토리 삭제)

### 작업 의존성

```
Senior: AuthSdkConfig 작성
  ↓
Senior: AuthSdk.initialize() 수정
  ↓
Senior: LoginController 수정
  ↓
Junior: LoginView 수정 (Controller 완성 후 시작)
  ↓
Senior: auth_sdk.dart export 수정
  ↓
Senior: main.dart 수정
Junior: app_pages.dart 수정
  ↓
Junior: login 모듈 삭제
```

## 검증 기준

### 기능 검증
- [ ] wowa 앱에서 카카오/네이버/애플/구글 로그인 정상 동작
- [ ] 로그인 성공 시 홈 화면(`/home`)으로 이동
- [ ] 둘러보기 버튼 클릭 시 홈 화면으로 이동
- [ ] 로딩 상태 표시 (로그인 중 해당 버튼만 스피너)
- [ ] 에러 처리 (네트워크 오류, 계정 충돌, 사용자 취소)
- [ ] 계정 충돌 모달 표시 (SketchModal)

### 아키텍처 검증
- [ ] auth_sdk 패키지가 wowa 앱에 의존하지 않음 (import 검증)
- [ ] LoginController, LoginView, LoginBinding이 auth_sdk에 위치
- [ ] wowa 앱의 login 모듈 디렉토리가 삭제됨
- [ ] AuthSdk.initialize()가 AuthSdkConfig 객체로 호출됨
- [ ] 프로바이더 등록이 AuthSdk.initialize()에서 처리됨

### GetX 패턴 검증
- [ ] LoginController가 GetxController 상속
- [ ] LoginView가 GetView<LoginController> 상속
- [ ] LoginBinding이 Bindings 구현
- [ ] 반응형 상태(.obs)가 Obx로 바인딩됨
- [ ] const 생성자 사용 (SizedBox, Text, SocialLoginButton 등)

### 코드 품질 검증
- [ ] 모든 주석이 한글로 작성됨 (기술 용어 제외)
- [ ] import 순서가 가이드라인 준수 (flutter → package → relative)
- [ ] 에러 로그가 Logger.error()로 기록됨
- [ ] 민감 정보(토큰)가 로그에 기록되지 않음

## 성능 최적화 전략

### const 생성자
```dart
// LoginView에서 const 사용 (정적 위젯)
const SizedBox(height: 64)
const SizedBox(height: 16)
const Text('로그인')
```

### Obx 범위 최소화
```dart
// 좋은 예: 버튼만 Obx로 감싸기
Obx(() => SocialLoginButton(
  isLoading: controller.isKakaoLoading.value,
  onPressed: controller.handleKakaoLogin,
))

// 나쁜 예: 전체 Column을 Obx로 감싸기 (불필요한 rebuild)
Obx(() => Column(...))
```

### 불필요한 rebuild 방지
- GetView 사용으로 controller 한 번만 생성
- const 생성자로 rebuild 스킵
- Obx는 로딩 상태만 감지 (title, subtitle은 정적)

## 에러 처리 전략

**Controller 에러 처리** (기존과 동일)

```dart
try {
  loadingState.value = true;
  await AuthSdk.login(provider);
  Get.offAllNamed(AuthSdk.config.homeRoute);
} on AuthException catch (e) {
  if (e.code == 'user_cancelled') return; // 조용히 실패
  if (e.code == 'account_conflict') {
    _showAccountLinkModal(e.data?['existingProvider']);
    return;
  }
  _showErrorSnackbar('로그인 실패', e.message);
} on NetworkException catch (e) {
  _showErrorSnackbar('네트워크 오류', e.message);
} catch (e) {
  _showErrorSnackbar('로그인 오류', '로그인 중 오류가 발생했습니다');
} finally {
  loadingState.value = false;
}
```

**View 에러 표시** (기존과 동일)

- GetSnackBar로 에러 메시지 표시 (화면 하단, 3초)
- SketchModal로 계정 충돌 안내 (모달)

## 패키지 의존성 그래프 (변경 후)

```
core (foundation)
  ↑
  ├── design_system (UI, SocialLoginButton)
  │     ↑
  │     └── auth_sdk (로그인 로직 + 로그인 화면)
  │           ↑
  │           └── wowa (앱, LoginView/LoginController/LoginBinding 사용)
  └── wowa (앱, core + design_system + auth_sdk)
```

**변경 사항**: auth_sdk가 design_system에 의존 (SocialLoginButton 사용)

## SDK 통합 가이드 (다른 앱 개발자용)

### 1. 의존성 추가

```yaml
# pubspec.yaml
dependencies:
  auth_sdk:
    path: ../../packages/auth_sdk
```

### 2. SDK 초기화

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthSdk.initialize(
    AuthSdkConfig(
      appCode: 'your_app_code',
      apiBaseUrl: 'https://api.example.com',
      homeRoute: '/dashboard',      // 앱별 홈 라우트
      showBrowseButton: false,       // 둘러보기 비활성화
      providers: {
        SocialProvider.kakao: ProviderConfig(clientId: 'xxx'),
        SocialProvider.naver: ProviderConfig(
          clientId: 'xxx',
          clientSecret: 'xxx',
        ),
        SocialProvider.google: ProviderConfig(clientId: 'xxx'),
        SocialProvider.apple: ProviderConfig(),
      },
    ),
  );

  runApp(MyApp());
}
```

### 3. 라우트 등록

```dart
// app_pages.dart
import 'package:auth_sdk/auth_sdk.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}
```

### 4. 앱별 커스터마이징

| 설정 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| appCode | String | ✅ | - | 앱 식별 코드 |
| apiBaseUrl | String | ✅ | - | 서버 API 기본 URL |
| providers | Map | ✅ | - | 소셜 프로바이더 OAuth 설정 |
| homeRoute | String | ❌ | '/home' | 로그인 성공 후 이동 라우트 |
| showBrowseButton | bool | ❌ | false | 둘러보기 버튼 표시 여부 |
| secureStorage | SecureStorageService? | ❌ | null | 커스텀 저장소 (테스트용) |

## 참고 자료

### 디자인 명세
- **User Story**: `docs/wowa/wowa-login/user-story.md`
- **Design Spec**: `docs/wowa/wowa-login/mobile-design-spec.md`

### 가이드 문서
- **GetX Best Practices**: `.claude/guide/mobile/getx_best_practices.md`
- **Directory Structure**: `.claude/guide/mobile/directory_structure.md`
- **Common Patterns**: `.claude/guide/mobile/common_patterns.md`
- **Design System**: `.claude/guide/mobile/design_system.md`
- **Error Handling**: `.claude/guide/mobile/error_handling.md`

### 기존 코드
- **현재 LoginView**: `apps/wowa/lib/app/modules/login/views/login_view.dart`
- **현재 LoginController**: `apps/wowa/lib/app/modules/login/controllers/login_controller.dart`
- **현재 LoginBinding**: `apps/wowa/lib/app/modules/login/bindings/login_binding.dart`
- **AuthSdk**: `packages/auth_sdk/lib/src/auth_sdk.dart`

### 카탈로그
- **서버 카탈로그**: `docs/wowa/server-catalog.md`
- **모바일 카탈로그**: `docs/wowa/mobile-catalog.md`

---

**작성일**: 2026-02-10
**Tech Lead**: Claude Code
**다음 단계**: 사용자 승인 후 CTO가 설계를 검증하고 작업을 분배합니다.
