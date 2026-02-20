# auth_sdk — 소셜 로그인 및 인증 관리 SDK

## 개요

- **역할**: 카카오, 네이버, 구글, 애플 소셜 로그인 + JWT 토큰 관리 + 인증 상태 + 로그인 화면 제공
- **사용처**: wowa 앱 (향후 다른 앱에서도 재사용 가능)
- **독립성**: `core`, `design_system`에만 의존. 앱별 설정은 `AuthSdkConfig`로 주입

## 연동 가이드

```dart
// 1. main.dart에서 초기화
await AuthSdk.initialize(AuthSdkConfig(
  appCode: 'wowa',
  apiBaseUrl: 'https://api.example.com',
  homeRoute: '/home',
  providers: {
    SocialProvider.kakao: ProviderConfig(clientId: 'kakao_key'),
    SocialProvider.google: ProviderConfig(clientId: 'google_id'),
    SocialProvider.apple: const ProviderConfig(),
  },
  onPreLogout: () async { /* 로그아웃 전 정리 작업 */ },
));

// 2. 로그인 (프로그래밍 방식)
final response = await AuthSdk.login(SocialProvider.kakao);

// 3. 인증 상태 확인
final isAuth = AuthSdk.authState.isAuthenticated;

// 4. 로그아웃
await AuthSdk.logout();
```

## Public API

| 클래스/함수 | 역할 | 사용 예 |
|------------|------|---------|
| `AuthSdk` | SDK 메인 클래스 (initialize, login, logout, authState) | `AuthSdk.initialize(config)` |
| `AuthSdkConfig` | 설정 객체 (appCode, apiBaseUrl, providers, 콜백) | 생성자에 전달 |
| `SocialProvider` | 소셜 플랫폼 열거형 (kakao, naver, google, apple) | `SocialProvider.kakao` |
| `ProviderConfig` | 플랫폼별 설정 (clientId, clientSecret) | `ProviderConfig(clientId: 'xxx')` |
| `AuthStateService` | 인증 상태 관리 (Rx, isAuthenticated, status) | `AuthSdk.authState.isAuthenticated` |
| `AuthInterceptor` | Dio 인터셉터 (토큰 자동 첨부/갱신) | SDK 초기화 시 자동 등록 |
| `LoginView` | 소셜 로그인 화면 위젯 | 라우트에 등록 |
| `LoginBinding` | 로그인 화면 바인딩 | GetPage에 사용 |
| `LoginResponse` | 로그인 응답 모델 (Freezed) | `AuthSdk.login()` 반환값 |
| `SocialLoginButton` | 소셜 로그인 버튼 (design_system 재export) | LoginView 내부에서 사용 |

## Configuration

`AuthSdkConfig` 생성자 파라미터:

| 필드 | 타입 | 설명 | 필수 |
|------|------|------|------|
| `appCode` | `String` | 앱 식별 코드 | Yes |
| `apiBaseUrl` | `String` | API 기본 URL | Yes |
| `providers` | `Map<SocialProvider, ProviderConfig>` | 플랫폼별 OAuth 설정 | Yes |
| `homeRoute` | `String` | 로그인 후 이동 라우트 (기본: '/home') | No |
| `showBrowseButton` | `bool` | 둘러보기 버튼 표시 (기본: false) | No |
| `onPreLogout` | `Future<void> Function()?` | 로그아웃 전 콜백 | No |
| `onPostLogin` | `Future<void> Function()?` | 로그인 후 콜백 | No |

## Architecture

```
lib/
├── auth_sdk.dart              # 배럴 파일 (전체 export)
└── src/
    ├── auth_sdk.dart          # SDK 메인 클래스 (정적 메서드)
    ├── config/                # AuthSdkConfig, SocialProvider, ProviderConfig
    ├── providers/             # 소셜 로그인 프로바이더 (Kakao, Naver, Google, Apple)
    ├── services/              # AuthApiService (Dio), AuthStateService (상태 관리)
    ├── interceptors/          # AuthInterceptor (JWT 자동 첨부/갱신)
    ├── repositories/          # AuthRepository (프로바이더 + API 조합)
    ├── models/                # Freezed 모델 (LoginRequest/Response, RefreshRequest/Response, UserModel)
    └── ui/                    # LoginView, LoginController, LoginBinding
```

- `AuthSdk.initialize()` 호출 시 Dio, SecureStorage, Provider, Interceptor 등이 GetX DI에 자동 등록
- `AuthInterceptor`가 모든 API 요청에 JWT 토큰 자동 첨부 및 만료 시 자동 갱신

## 확장/수정 시

1. 새 소셜 프로바이더: `src/providers/`에 `SocialLoginProvider` 구현체 추가, `auth_sdk.dart`의 `_registerProviders`에 등록
2. 모델 수정: Freezed 파일 수정 후 `melos generate` 실행
3. 인증 흐름 변경: `AuthRepository` 수정

## 의존성

| 패키지 | 역할 |
|--------|------|
| `core` | Logger, SecureStorageService, 예외 클래스 |
| `design_system` | SocialLoginButton 위젯 |
| `kakao_flutter_sdk_user` | 카카오 OAuth |
| `flutter_naver_login` | 네이버 OAuth |
| `google_sign_in` | 구글 OAuth |
| `sign_in_with_apple` | 애플 OAuth |
| `dio` | HTTP 클라이언트 |
| `freezed_annotation` / `json_annotation` | 데이터 모델 코드 생성 |
