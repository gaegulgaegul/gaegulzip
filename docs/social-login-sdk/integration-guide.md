# Auth SDK 통합 가이드

> 소셜 로그인 SDK를 새 Flutter 앱에 통합하는 단계별 가이드입니다.

## 개요

Auth SDK는 gaegulzip 모노레포에서 재사용 가능한 소셜 로그인 패키지입니다. 카카오, 네이버, 구글, 애플 로그인을 지원하며, 토큰 관리와 인증 상태를 자동으로 처리합니다.

**SDK가 해결하는 문제**:
- 새 앱마다 소셜 로그인을 처음부터 구현할 필요 없음
- 검증된 보안 로직(토큰 갱신, Secure Storage) 재사용
- 서버 API와의 통합이 이미 구현되어 있어 설정만으로 동작

---

## 1. 모바일 SDK 설치

### 1.1 pubspec.yaml에 의존성 추가

새 Flutter 앱의 `pubspec.yaml`에 auth_sdk를 추가합니다:

```yaml
dependencies:
  auth_sdk:
    path: ../../packages/auth_sdk
```

### 1.2 melos bootstrap 실행

```bash
cd apps/mobile
melos bootstrap
```

> **주의**: `flutter pub get` 대신 반드시 `melos bootstrap`을 사용하세요. 모노레포 내 패키지 간 의존성을 올바르게 해결합니다.

### 1.3 Import 확인

```dart
import 'package:auth_sdk/auth_sdk.dart';
```

이 한 줄로 AuthSdk, SocialProvider, ProviderConfig, SocialLoginButton 등 모든 public API에 접근할 수 있습니다.

---

## 2. SDK 초기화

`main.dart`에서 앱 시작 시 SDK를 초기화합니다:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auth_sdk/auth_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수 로드
  await dotenv.load(fileName: ".env");

  // AuthSdk 초기화
  await AuthSdk.initialize(
    appCode: 'your-app-code',    // 서버 apps 테이블의 code와 일치
    apiBaseUrl: dotenv.env['API_BASE_URL']!,
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

### 초기화 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|:----:|------|
| `appCode` | `String` | ✅ | 서버 `apps` 테이블의 `code` 컬럼과 동일한 값 |
| `apiBaseUrl` | `String` | ✅ | 서버 API URL (예: `https://api.gaegulzip.com`) |
| `providers` | `Map<SocialProvider, ProviderConfig>` | ✅ | 사용할 소셜 로그인 프로바이더 목록 |
| `secureStorage` | `SecureStorageService?` | ❌ | 커스텀 토큰 저장소 (기본: flutter_secure_storage) |

### ProviderConfig 설정

대부분의 OAuth 키는 서버 `apps` 테이블에서 관리되므로, 클라이언트에서는 빈 `ProviderConfig()`만 전달하면 됩니다. 네이티브 SDK 초기화가 필요한 경우에만 `clientId`를 설정합니다:

```dart
SocialProvider.kakao: ProviderConfig(
  clientId: 'kakao-native-app-key',  // 카카오 네이티브 앱 키 (필요 시)
),
```

---

## 3. 로그인 버튼 추가

### 3.1 GetX Binding에 프로바이더 등록

로그인 화면의 Binding에서 소셜 로그인 프로바이더를 등록합니다:

```dart
import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // 소셜 로그인 프로바이더 (tag로 구분)
    Get.lazyPut<SocialLoginProvider>(
      () => KakaoLoginProvider(), tag: 'kakao',
    );
    Get.lazyPut<SocialLoginProvider>(
      () => NaverLoginProvider(), tag: 'naver',
    );
    Get.lazyPut<SocialLoginProvider>(
      () => AppleLoginProvider(), tag: 'apple',
    );
    Get.lazyPut<SocialLoginProvider>(
      () => GoogleLoginProvider(), tag: 'google',
    );

    // 컨트롤러
    Get.lazyPut(() => LoginController());
  }
}
```

### 3.2 로그인 버튼 UI (SocialLoginButton)

```dart
import 'package:auth_sdk/auth_sdk.dart';

// 카카오 로그인 버튼
SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  size: SocialLoginButtonSize.large,
  isLoading: controller.isKakaoLoading.value,
  onPressed: controller.handleKakaoLogin,
),

// 네이버 로그인 버튼
SocialLoginButton(
  platform: SocialLoginPlatform.naver,
  onPressed: controller.handleNaverLogin,
),

// 구글 로그인 버튼
SocialLoginButton(
  platform: SocialLoginPlatform.google,
  onPressed: controller.handleGoogleLogin,
),

// 애플 로그인 버튼 (다크 스타일)
SocialLoginButton(
  platform: SocialLoginPlatform.apple,
  appleStyle: AppleSignInStyle.dark,
  onPressed: controller.handleAppleLogin,
),
```

### 3.3 Controller에서 로그인 처리

```dart
import 'package:get/get.dart';
import 'package:auth_sdk/auth_sdk.dart';
import 'package:core/core.dart';

class LoginController extends GetxController {
  final isKakaoLoading = false.obs;

  Future<void> handleKakaoLogin() async {
    try {
      isKakaoLoading.value = true;

      final response = await AuthSdk.login(SocialProvider.kakao);

      // 성공 — 메인 화면으로 이동
      Get.offAllNamed('/home');
    } on AuthException catch (e) {
      if (e.code == 'user_cancelled') return;  // 사용자 취소
      if (e.code == 'account_conflict') {
        // 계정 연동 충돌 처리
        final existing = e.data?['existingProvider'];
        // 다이얼로그 표시
      }
      // 에러 스낵바 표시
    } on NetworkException catch (e) {
      // 네트워크 에러 처리
    } finally {
      isKakaoLoading.value = false;
    }
  }
}
```

---

## 4. 서버 API 연동

### 4.1 서버 앱 등록

서버 `apps` 테이블에 앱을 등록합니다:

```sql
INSERT INTO apps (code, name, kakao_rest_api_key, kakao_client_secret)
VALUES ('your-app-code', '앱 이름', 'kakao-rest-api-key', 'kakao-client-secret');
```

### 4.2 OAuth 인증 흐름

```
1. 사용자가 SocialLoginButton 클릭
2. SDK가 네이티브 소셜 SDK로 OAuth 인증 수행
3. 소셜 플랫폼에서 access_token 반환
4. SDK가 서버 API 호출: POST /auth/oauth
   Body: { provider, accessToken, appCode }
5. 서버가 소셜 API로 사용자 정보 검증
6. 서버가 JWT(access_token + refresh_token) 반환
7. SDK가 Secure Storage에 JWT 저장
8. SDK가 AuthStateService 상태 업데이트
```

### 4.3 토큰 자동 갱신

SDK의 `AuthInterceptor`가 자동으로 토큰을 관리합니다:

- API 요청 시 `Authorization: Bearer {accessToken}` 헤더 자동 추가
- 401 응답 시 자동으로 `POST /auth/refresh` 호출
- refresh_token으로 새 access_token 발급
- 갱신 실패 시 자동 로그아웃

---

## 5. OAuth 키 설정 방법

### 카카오 (Kakao)

1. [카카오 개발자 콘솔](https://developers.kakao.com) 접속
2. 애플리케이션 추가
3. "앱 키" → "REST API 키" 복사
4. "카카오 로그인" → "활성화" 설정
5. "동의항목" → 이메일, 프로필 설정
6. 서버 `apps.kakao_rest_api_key`에 REST API 키 저장

### 네이버 (Naver)

1. [네이버 개발자 센터](https://developers.naver.com) 접속
2. "애플리케이션 등록"
3. "Client ID", "Client Secret" 복사
4. "API 설정" → "네이버 로그인" 추가
5. 서버 `apps.naver_client_id`, `apps.naver_client_secret`에 저장

### 구글 (Google)

1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. OAuth 2.0 클라이언트 ID 생성 (iOS/Android 각각)
3. iOS: `GoogleService-Info.plist`에 클라이언트 ID 설정
4. Android: `google-services.json` 설정
5. 서버 `apps.google_client_id`에 웹 클라이언트 ID 저장

### 애플 (Apple)

1. [Apple Developer](https://developer.apple.com) 접속
2. "Identifiers" → "Sign in with Apple" 활성화
3. "Keys" → "Sign in with Apple" 키 생성
4. Key ID, Team ID 기록
5. 서버 `apps.apple_team_id`, `apps.apple_key_id`에 저장

---

## 6. 멀티테넌트 설정

gaegulzip 서버는 하나의 서버로 여러 앱을 지원합니다.

### 6.1 새 앱 추가 절차

```
1. 서버 apps 테이블에 앱 레코드 추가
2. 각 소셜 플랫폼 개발자 콘솔에서 새 앱 등록
3. OAuth 키를 apps 레코드에 저장
4. Flutter 앱에서 AuthSdk.initialize(appCode: 'new-app-code')
```

### 6.2 예제: "날씨플러스" 앱 추가

```sql
-- 서버: 앱 등록
INSERT INTO apps (code, name, kakao_rest_api_key, naver_client_id)
VALUES ('weather-plus', '날씨플러스', 'wx_kakao_key', 'wx_naver_id');
```

```dart
// Flutter: SDK 초기화
await AuthSdk.initialize(
  appCode: 'weather-plus',
  apiBaseUrl: 'https://api.gaegulzip.com',
  providers: {
    SocialProvider.kakao: const ProviderConfig(),
    SocialProvider.naver: const ProviderConfig(),
  },
);
```

---

## 트러블슈팅

### SDK 초기화 오류

| 증상 | 원인 | 해결 |
|------|------|------|
| `AuthSdk는 이미 초기화되었습니다` | `initialize()` 중복 호출 | Hot restart 시 발생, 앱 재시작 |
| `AuthSdk.initialize()를 먼저 호출하세요` | 초기화 전 API 호출 | `main.dart`에서 `initialize()` 확인 |

### 로그인 오류

| 증상 | 원인 | 해결 |
|------|------|------|
| `user_cancelled` | 사용자 취소 | 정상 동작, 조용히 처리 |
| `account_conflict` | 다른 프로바이더로 가입된 이메일 | 계정 연동 안내 다이얼로그 표시 |
| `permission_denied` | OAuth 권한 거부 | 권한 허용 안내 |
| 401 반복 | refresh_token 만료 | 자동 로그아웃 후 재로그인 유도 |

### 빌드 오류

| 증상 | 원인 | 해결 |
|------|------|------|
| `target of uri doesn't exist` | 패키지 미설치 | `melos bootstrap` 실행 |
| `Could not find a file named 'pubspec.yaml'` | 경로 오류 | `pubspec.yaml`의 path 확인 |
| Freezed 코드 생성 오류 | `.freezed.dart` 미생성 | `melos generate` 실행 |
