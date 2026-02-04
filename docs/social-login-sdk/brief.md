# 사용자 스토리: 소셜 로그인 SDK 패키지화

## 개요

현재 WOWA 앱에 구현된 소셜 로그인 기능을 재사용 가능한 SDK로 추출하여, gaegulzip 모노레포 내 다른 제품(앱)에서도 손쉽게 소셜 로그인을 도입할 수 있도록 합니다. 서버는 이미 멀티테넌트 구조(apps 테이블)로 여러 앱을 지원하지만, 현재 auth 모듈이 WOWA 앱에 종속되어 있어 다른 앱에서 재사용하기 어렵습니다. 모바일도 마찬가지로 소셜 로그인 프로바이더와 인증 상태 관리 로직을 독립적인 패키지로 분리하여 새 Flutter 앱을 만들 때 즉시 사용할 수 있도록 합니다.

**비즈니스 가치**: 새 제품 출시 시 소셜 로그인 구현 시간을 단축하고, 검증된 보안 로직을 재사용하여 품질을 높입니다.

---

## 사용자 스토리

### US-1: 모바일 Auth SDK 패키지 추출

- **As a** Flutter 앱 개발자
- **I want to** 소셜 로그인 프로바이더 및 인증 상태 관리를 독립적인 Flutter 패키지로 사용하고 싶다
- **So that** 새 Flutter 앱을 만들 때 `packages/auth_sdk`를 의존성에 추가하고 프로바이더 설정만 하면 소셜 로그인이 작동한다

### US-2: 앱별 OAuth 설정 관리

- **As a** 서비스 운영자
- **I want to** 각 앱(WOWA, 미래의 앱2, 앱3)마다 독립적인 OAuth 인증 키를 관리하고 싶다
- **So that** 하나의 서버로 여러 앱의 소셜 로그인을 처리할 수 있다 (이미 구현됨, SDK에서 유지)

### US-3: SDK 통합 가이드 문서화

- **As a** 신규 개발자
- **I want to** SDK 설치부터 실제 로그인까지 단계별 가이드를 따라하고 싶다
- **So that** 코드를 깊이 이해하지 않아도 소셜 로그인을 빠르게 통합할 수 있다

### US-4: SDK 버전 관리 및 독립 테스트

- **As a** DevOps 엔지니어
- **I want to** SDK가 WOWA 앱과 독립적으로 버전 관리되고 테스트되길 원한다
- **So that** WOWA 앱 변경과 관계없이 SDK를 안전하게 업데이트하고 배포할 수 있다

---

## 사용자 시나리오

### 시나리오 1: 새 Flutter 앱에 소셜 로그인 추가 (모바일 SDK)

1. 개발자가 새 Flutter 앱을 생성한다
2. `pubspec.yaml`에 `auth_sdk: { path: ../../packages/auth_sdk }`를 추가한다
3. `melos bootstrap`을 실행하여 패키지를 설치한다
4. `main.dart`에서 `AuthSdk.initialize(appCode: 'new-app')`를 호출한다
5. 로그인 화면에서 `SocialLoginButton`을 배치하고 `AuthSdk.login(provider)`를 호출한다
6. SDK가 OAuth 플로우, 토큰 저장, 상태 관리를 자동으로 처리한다
7. 결과: 사용자가 카카오/네이버/구글/애플로 로그인할 수 있다

### 시나리오 2: 앱별 독립 OAuth 키 설정

1. 운영자가 새 앱 "날씨플러스"를 출시한다
2. `apps` 테이블에 `{ code: 'weather-plus', name: '날씨플러스' }` 레코드를 추가한다
3. 카카오 개발자 콘솔에서 "날씨플러스" 앱을 생성하고 인증 키를 받는다
4. `apps.kakaoRestApiKey`, `apps.kakaoClientSecret` 필드에 키를 저장한다
5. 클라이언트가 `POST /auth/oauth { code: 'weather-plus', provider: 'kakao', accessToken: '...' }`를 호출한다
6. 서버가 `weather-plus` 앱 설정으로 카카오 API를 검증한다
7. 결과: WOWA와 날씨플러스가 독립적인 OAuth 앱으로 운영된다

### 시나리오 3: SDK 문서를 따라 통합

1. 신규 개발자가 `docs/social-login-sdk/integration-guide.md`를 연다
2. "서버 SDK 설치" 섹션을 따라 npm 패키지를 설치한다
3. "앱 등록" 섹션을 따라 DB에 앱 레코드를 추가한다
4. "라우트 등록" 섹션의 코드 예제를 복사-붙여넣기한다
5. "모바일 SDK 설치" 섹션을 따라 Flutter 패키지를 추가한다
6. "로그인 버튼 추가" 섹션의 위젯 예제를 화면에 배치한다
7. 앱을 실행하고 소셜 로그인을 테스트한다
8. 결과: 30분 이내에 소셜 로그인이 작동한다

### 시나리오 4: SDK 독립 업데이트

1. 보안 취약점이 발견되어 토큰 검증 로직을 개선해야 한다
2. 개발자가 `packages/server-auth-sdk`의 코드를 수정한다
3. SDK 테스트를 실행한다 (`pnpm test --filter @gaegulzip/auth-sdk`)
4. 테스트가 통과하면 SDK 버전을 `1.0.1`로 업데이트한다
5. WOWA 앱과 날씨플러스 앱 모두 `pnpm update @gaegulzip/auth-sdk`로 업데이트한다
6. 각 앱의 테스트를 실행하여 호환성을 확인한다
7. 결과: 하나의 수정으로 모든 앱이 보안 개선을 적용받는다

---

## 인수 조건 (Acceptance Criteria)

### 모바일 SDK (Mobile Auth SDK)

- [ ] `packages/auth_sdk` 디렉토리에 독립적인 Flutter 패키지가 생성된다
- [ ] 패키지가 `SocialLoginProvider` 추상 클래스를 export한다
- [ ] 패키지가 4개 프로바이더 구현체(Kakao, Naver, Google, Apple)를 포함한다
- [ ] 패키지가 `AuthStateService` (인증 상태 관리), `AuthInterceptor` (자동 토큰 갱신), `AuthRepository` (API 통신)를 포함한다
- [ ] 패키지가 `SocialLoginButton` 위젯을 포함한다 (design_system 패키지에서 이동)
- [ ] 패키지가 `AuthSdk.initialize(appCode, apiBaseUrl)` 메서드로 초기화된다
- [ ] 패키지가 WOWA 앱에 특정한 로직(하드코딩된 라우트, 화면 이동 등)을 포함하지 않는다
- [ ] 패키지가 `core`, `api` 패키지에 의존한다 (design_system은 필요 시 포함)
- [ ] 패키지가 `AuthSdk.login(provider)`, `AuthSdk.logout()`, `AuthSdk.isAuthenticated` 등의 public API를 제공한다
- [ ] WOWA 앱이 SDK를 의존성으로 사용하도록 리팩토링된다

### 설정 및 문서

- [ ] `docs/social-login-sdk/integration-guide.md` 파일이 생성된다
- [ ] 가이드가 "모바일 SDK 설치", "초기화", "로그인 버튼 추가", "서버 API 연동" 섹션을 포함한다
- [ ] 가이드가 각 단계별 코드 예제를 포함한다
- [ ] 가이드가 OAuth 키 설정 방법 (카카오/네이버/구글/애플 개발자 콘솔)을 설명한다
- [ ] 가이드가 멀티테넌트 설정 (여러 앱 운영) 예제를 포함한다
- [ ] `packages/auth_sdk/README.md` 파일이 Flutter 패키지 사용법을 포함한다

### 테스트 및 독립성

- [ ] 모바일 SDK가 WOWA 앱과 독립적으로 `flutter analyze`로 검증된다
- [ ] SDK 버전이 `pubspec.yaml`에서 관리된다
- [ ] WOWA 앱이 SDK 의존성을 사용하도록 변경한 후에도 `melos analyze` 통과한다

---

## 엣지 케이스

- **모바일 SDK가 Flutter 버전 업그레이드로 동작하지 않는 경우**: melos.yaml의 SDK 버전 제약을 명확히 설정, 가이드에서 지원 버전 명시
- **앱 코드가 중복되어 등록된 경우**: DB unique 제약으로 방지, SDK가 명확한 에러 메시지 반환
- **OAuth 키가 설정되지 않은 프로바이더 호출**: SDK가 `ValidationException('Provider kakao not configured for app xxx')`을 발생시킴
- **새 앱 개발자가 SDK 버전을 고정하지 않은 경우**: 가이드에서 semantic versioning 및 `^1.0.0` 형식 사용 권장

---

## 비즈니스 규칙

- SDK는 모바일(Flutter) 패키지로만 생성한다 (서버는 모듈로 유지, SDK 추출 안 함)
- SDK는 OAuth 인증 키를 코드에 포함하지 않는다 (서버 API를 통해 관리)
- SDK는 GetX 상태 관리를 사용한다 (기존 앱과의 일관성)
- SDK는 기존 WOWA 앱의 기능을 100% 유지한다 (회귀 방지)

---

## 필요한 데이터

### 모바일 SDK 초기화 데이터

| 데이터 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| appCode | String | ✅ | 앱 코드 (서버와 동일) |
| apiBaseUrl | String | ✅ | API 베이스 URL (예: 'https://api.gaegulzip.com') |
| oauthProviders | Map<Provider, Config> | ✅ | 프로바이더별 OAuth 설정 (앱키, 클라이언트 ID 등) |
| secureStorage | SecureStorageService | ❌ | 토큰 저장소 (기본: flutter_secure_storage) |

---

## 비기능 요구사항

### 성능

- SDK 초기화는 앱 시작 시 100ms 이내에 완료되어야 한다

### 접근성

- SDK 문서는 신규 개발자가 30분 이내에 첫 로그인을 구현할 수 있을 정도로 명확해야 한다
- 에러 메시지는 문제 원인과 해결 방법을 포함한다

### 호환성

- 모바일 SDK는 Flutter 3.24.0 이상, Dart 3.10.7 이상에서 작동한다

### 에러 처리

- SDK는 모든 에러를 명확한 에러 코드와 함께 반환한다 (INVALID_TOKEN, PROVIDER_NOT_CONFIGURED 등)
- 외부 API(카카오/네이버/구글/애플) 호출 실패 시 ExternalApiException으로 래핑한다
- 설정 누락(OAuth 키 미등록) 시 앱 시작 단계에서 명확한 에러 메시지를 출력한다

### 보안

- SDK는 OAuth 시크릿, JWT 시크릿을 로그에 출력하지 않는다
- SDK는 토큰 재사용 탐지, bcrypt 해시 저장 등 기존 보안 메커니즘을 유지한다
- SDK는 민감한 정보(이메일, 프로필 이미지 URL)를 로그에 마스킹한다

### 유지보수성

- SDK 코드는 WOWA 앱 코드와 명확히 분리되어 독립적으로 버전 관리된다
- SDK 변경 시 CHANGELOG.md에 변경 사항을 기록한다
- SDK는 breaking change 시 메이저 버전을 업데이트한다 (semantic versioning)
