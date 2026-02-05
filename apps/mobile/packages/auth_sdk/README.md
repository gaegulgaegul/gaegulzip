# Auth SDK

재사용 가능한 소셜 로그인 Flutter 패키지입니다.

카카오, 네이버, 구글, 애플 소셜 로그인을 지원하며, 인증 상태 관리, 토큰 자동 갱신, API 통신을 제공합니다.

## 기능

- ✅ 4개 소셜 로그인 프로바이더 (카카오, 네이버, 구글, 애플)
- ✅ 자동 토큰 갱신 (AuthInterceptor)
- ✅ 인증 상태 관리 (AuthStateService)
- ✅ Secure Storage를 통한 안전한 토큰 저장
- ✅ 멀티테넌트 지원 (앱 코드 기반)
- ✅ GetX 상태 관리 패턴

## 설치

`pubspec.yaml`에 의존성을 추가합니다:

```yaml
dependencies:
  auth_sdk:
    path: ../../packages/auth_sdk
```

`melos bootstrap`을 실행합니다:

```bash
melos bootstrap
```

## 사용법

### 1. SDK 초기화 (main.dart)

```dart
import 'package:auth_sdk/auth_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수 로드
  await dotenv.load(fileName: ".env");

  // AuthSdk 초기화
  final apiBaseUrl = dotenv.env['API_BASE_URL'] ??
      (throw Exception('API_BASE_URL이 .env 파일에 설정되지 않았습니다'));

  await AuthSdk.initialize(
    appCode: 'wowa',
    apiBaseUrl: apiBaseUrl,
    providers: {
      SocialProvider.kakao: const ProviderConfig(),
      SocialProvider.naver: const ProviderConfig(),
      SocialProvider.google: const ProviderConfig(),
      SocialProvider.apple: const ProviderConfig(),
    },
  );

  runApp(const MyApp());
}
```

### 2. 프로바이더 등록 (Binding)

로그인 화면의 Binding에서 프로바이더를 등록합니다:

```dart
import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Social Login Providers (tag로 등록)
    Get.lazyPut<SocialLoginProvider>(() => KakaoLoginProvider(), tag: 'kakao');
    Get.lazyPut<SocialLoginProvider>(() => NaverLoginProvider(), tag: 'naver');
    Get.lazyPut<SocialLoginProvider>(() => AppleLoginProvider(), tag: 'apple');
    Get.lazyPut<SocialLoginProvider>(() => GoogleLoginProvider(), tag: 'google');

    // LoginController
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
```

### 3. 로그인 (Controller)

```dart
import 'package:auth_sdk/auth_sdk.dart';

class LoginController extends GetxController {
  Future<void> handleKakaoLogin() async {
    try {
      // AuthSdk를 통한 소셜 로그인
      final loginResponse = await AuthSdk.login(SocialProvider.kakao);

      // 성공 처리
      Get.offAllNamed(Routes.HOME);
      print('${loginResponse.user.nickname}님 환영합니다!');
    } on AuthException catch (e) {
      // 에러 처리
      print('로그인 실패: ${e.message}');
    }
  }
}
```

### 4. 로그아웃

```dart
await AuthSdk.logout();
```

### 5. 인증 상태 확인

```dart
// 인증 여부 확인
final isAuthenticated = await AuthSdk.isAuthenticated();

// AuthStateService 접근
final authState = AuthSdk.authState;
print('인증 상태: ${authState.status.value}');
```

## API

### AuthSdk

#### `initialize()`
SDK를 초기화합니다. 앱 시작 시 한 번만 호출합니다.

**파라미터**:
- `appCode` (String): 앱 코드 (서버에서 앱 식별용)
- `apiBaseUrl` (String): API 베이스 URL
- `providers` (Map<SocialProvider, ProviderConfig>): 프로바이더별 OAuth 설정
- `secureStorage` (SecureStorageService?): 토큰 저장소 (선택적)

#### `login(SocialProvider provider)`
소셜 로그인을 수행합니다.

**Returns**: `Future<LoginResponse>` 로그인 응답 (토큰, 사용자 정보)

**Throws**:
- `AuthException`: 인증 오류 (사용자 취소, 권한 거부 등)
- `NetworkException`: 네트워크 오류

#### `logout({bool revokeAll = false})`
로그아웃을 수행합니다.

**파라미터**:
- `revokeAll` (bool): true이면 사용자의 모든 토큰 무효화

#### `isAuthenticated()`
인증 여부를 확인합니다.

**Returns**: `Future<bool>`

#### `authState`
AuthStateService 인스턴스에 접근합니다.

**Returns**: `AuthStateService`

### SocialProvider

소셜 로그인 프로바이더 열거형:
- `SocialProvider.kakao`
- `SocialProvider.naver`
- `SocialProvider.google`
- `SocialProvider.apple`

## 아키텍처

```
auth_sdk/
├── lib/
│   ├── auth_sdk.dart              # Public API
│   └── src/
│       ├── providers/             # 소셜 로그인 프로바이더
│       │   ├── social_login_provider.dart
│       │   ├── kakao_login_provider.dart
│       │   ├── naver_login_provider.dart
│       │   ├── google_login_provider.dart
│       │   └── apple_login_provider.dart
│       ├── services/              # 인증 상태/API 통신
│       │   ├── auth_state_service.dart
│       │   └── auth_api_service.dart
│       ├── interceptors/          # 토큰 자동 갱신
│       │   └── auth_interceptor.dart
│       ├── repositories/          # 로그인/로그아웃 처리
│       │   └── auth_repository.dart
│       ├── models/                # API 모델 (Freezed)
│       │   ├── login_request.dart
│       │   ├── login_response.dart
│       │   ├── refresh_response.dart
│       │   └── user_model.dart
│       └── auth_sdk.dart          # AuthSdk 메인 클래스
└── pubspec.yaml
```

## 의존성

- `core`: 기초 유틸리티 (SecureStorageService, Exceptions)
- `api`: HTTP 통신 (Dio)
- `get`: 상태 관리 및 DI
- `kakao_flutter_sdk_user`: 카카오 로그인
- `flutter_naver_login`: 네이버 로그인
- `google_sign_in`: 구글 로그인
- `sign_in_with_apple`: 애플 로그인
- `freezed` / `json_serializable`: API 모델 코드 생성

## 에러 처리

SDK는 다음 예외를 발생시킵니다:

- **AuthException**: 인증 오류
  - `user_cancelled`: 사용자가 로그인을 취소
  - `permission_denied`: 권한 거부
  - `account_conflict`: 계정 연동 충돌
  - `invalid_code`: 인증 코드 검증 실패
  - `refresh_token_expired`: 리프레시 토큰 만료

- **NetworkException**: 네트워크 연결 오류

## 개발자 가이드

### 새 프로바이더 추가

1. `SocialLoginProvider`를 구현하는 새 클래스 생성
2. `lib/src/providers/` 디렉토리에 파일 추가
3. `lib/auth_sdk.dart`에서 export
4. `SocialProvider` 열거형에 새 프로바이더 추가

### 코드 생성

Freezed 모델 수정 후 코드 생성:

```bash
cd apps/mobile
melos generate
```

## 라이선스

Private package - 프로젝트 내부 사용 전용
