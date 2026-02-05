# Wowa 모바일 기능 카탈로그

> 모바일 앱에 구현된 모듈, 패키지, 위젯을 빠르게 찾기 위한 카탈로그입니다.
> 상세 분석은 `docs/core/` 하위 문서를 참조하세요.

## 앱 모듈

### 로그인 (Login)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/login/`
- **상태**: ⚠️ OAuth SDK 연동 완료, 서버 연동 구현됨 (실 서버 테스트 필요)
- **핵심 파일**:
  - `controllers/login_controller.dart` — GetX 컨트롤러 (4개 프로바이더별 로딩 상태, 에러 처리, 스낵바/모달 피드백)
  - `views/login_view.dart` — 소셜 로그인 4개 버튼 + 둘러보기 버튼
  - `bindings/login_binding.dart` — AuthApiService, SecureStorageService, AuthRepository, 4개 소셜 프로바이더, LoginController DI 등록
- **사용 패키지**: core (예외 클래스, SecureStorageService), api (AuthApiService, 모델), design_system (SocialLoginButton)
- **서버 연동 API**:
  | 메서드 | 경로 | 용도 |
  |--------|------|------|
  | POST | `/api/auth/oauth/login` | OAuth 소셜 로그인 |
  | POST | `/api/auth/refresh` | 토큰 갱신 |
- **Quick Start**:
  1. `.env`에 `API_BASE_URL` 설정
  2. 각 플랫폼 SDK 키 설정 (카카오 앱키, 네이버 클라이언트 ID 등)
  3. `LoginBinding`이 모든 의존성 자동 주입
  4. `LoginController._handleSocialLogin(provider)` 호출로 전체 플로우 실행
  5. 성공 시 토큰 저장 → 홈 이동, 실패 시 스낵바/모달 표시
- **상세 분석**: [`docs/core/social-login.md`](../core/social-login.md)

---

### QnA 질문 작성 (QnA)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/qna/`
- **상태**: ✅ 완료 (flutter analyze 0 errors)
- **핵심 파일**:
  - `controllers/qna_controller.dart` — GetxController (입력 검증, 제출, 성공/실패 모달)
  - `views/qna_submit_view.dart` — GetView 화면 (SketchInput x2, 글자 수 카운터, SketchButton)
  - `bindings/qna_binding.dart` — QnaApiService, QnaRepository, QnaController DI 등록
- **사용 패키지**: core (NetworkException), api (QnaSubmitRequest/Response, QnaApiService), design_system (SketchInput, SketchButton, SketchModal)
- **서버 연동 API**:
  | 메서드 | 경로 | 용도 |
  |--------|------|------|
  | POST | `/api/qna/questions` | 질문 제출 (GitHub Issue 자동 생성) |
- **반응형 상태 (.obs)**:
  | 변수 | 타입 | 용도 |
  |------|------|------|
  | `isSubmitting` | RxBool | 제출 중 로딩 상태 |
  | `titleError` | RxString | 제목 유효성 검증 에러 |
  | `bodyError` | RxString | 본문 유효성 검증 에러 |
  | `bodyLength` | RxInt | 본문 글자 수 (색상 변화: 60000 warning, 65000 error) |
  | `errorMessage` | RxString | API 에러 메시지 |
- **Quick Start**:
  1. `QnaBinding`이 모든 의존성 자동 주입
  2. `Get.toNamed(Routes.QNA)` 호출로 질문 작성 화면 이동
  3. 제목(1-256자) + 본문(1-65536자) 입력 후 "질문 제출" 버튼 클릭
  4. 성공 시 SketchModal → 확인 → 이전 화면으로 복귀
  5. 실패 시 SketchModal → 닫기/재시도 선택
- **새 앱에 적용**: `QnaRepository`의 `appCode: 'wowa'`를 새 앱 코드로 변경
- **상세 설계**: [`docs/core/qna/mobile-design-spec.md`](../core/qna/mobile-design-spec.md), [`docs/core/qna/mobile-brief.md`](../core/qna/mobile-brief.md)

---

### 알림 (Notification)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/notification/`
- **상태**: ⚠️ UI 스캐폴드 완료 (서버 연동 필요)
- **핵심 파일**:
  - `controllers/notification_controller.dart` — GetxController
  - `views/notification_view.dart` — 알림 목록 화면
  - `bindings/notification_binding.dart` — DI 등록
- **사용 패키지**: notice (SDK 패키지)

---

### 홈 (Home)

- **상태**: ❌ 미구현 (라우트만 정의됨)
- **라우트**: `Routes.HOME` = `/home`

### 설정 (Settings)

- **상태**: ❌ 미구현 (라우트만 정의됨)
- **라우트**: `Routes.SETTINGS` = `/settings`

---

## 라우팅

- **정의**: `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart`
- **페이지**: `apps/mobile/apps/wowa/lib/app/routes/app_pages.dart`
- **등록된 라우트**:
  | 경로 | 뷰 | 바인딩 | 트랜지션 |
  |------|-----|--------|---------|
  | `/login` | `LoginView` | `LoginBinding` | fadeIn (300ms) |
  | `/qna` | `QnaSubmitView` | `QnaBinding` | cupertino (300ms) |
  | `/home` | 미구현 | - | - |
  | `/settings` | 미구현 | - | - |
- **초기 라우트**: `Routes.LOGIN`

---

## 앱 데이터 레이어

### QnaRepository

- **경로**: `apps/mobile/apps/wowa/lib/app/data/repositories/qna_repository.dart`
- **상태**: ✅ 완료
- **의존성**: QnaApiService (Get.find)
- **메서드**:
  | 메서드 | 반환 | 설명 |
  |--------|------|------|
  | `submitQuestion(title, body)` | `QnaSubmitResponse` | 질문 제출 (appCode 자동 설정) |
- **에러 처리 패턴**:
  - `DioException` timeout/connection → `NetworkException('네트워크 연결을 확인해주세요')`
  - `DioException` 400 → `NetworkException('제목과 내용을 확인해주세요')`
  - `DioException` 404 → `NetworkException('서비스 설정 오류가 발생했습니다')`
  - `DioException` 5xx → `NetworkException('일시적인 오류가 발생했습니다')`

### AuthRepository

- **경로**: `apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart`
- **상태**: ✅ 완료
- **의존성**: AuthApiService, SecureStorageService (Get.find)
- **메서드**:
  | 메서드 | 반환 | 설명 |
  |--------|------|------|
  | `login(provider, code)` | `UserModel` | OAuth 로그인 → 토큰/유저정보 저장 |
  | `refreshAccessToken()` | `void` | 토큰 갱신 → 저장소 업데이트 |
  | `logout()` | `void` | 저장소 전체 삭제 |
  | `isLoggedIn()` | `bool` | 액세스 토큰 존재 여부 |
  | `isTokenExpired()` | `bool` | 토큰 만료 여부 |
- **에러 처리 패턴**:
  - `DioException` timeout/connection → `NetworkException`
  - `DioException` 401 → `AuthException(code: 'invalid_code')`
  - `DioException` 409 → `AuthException(code: 'account_conflict')` (기존 프로바이더 정보 포함)
  - `DioException` 5xx → 일반 예외 (서버 오류)

---

## 소셜 로그인 프로바이더

- **경로**: `apps/mobile/apps/wowa/lib/app/services/social_login/`
- **상태**: ✅ 4개 프로바이더 구현 완료
- **기반 클래스**: `SocialLoginProvider` (abstract)
  - 추상 속성: `platformName`, `isInitialized`
  - 추상 메서드: `signIn()` → `String` (인가 코드/토큰), `signOut()`

| 프로바이더 | 파일 | SDK | signIn() 반환값 |
|-----------|------|-----|----------------|
| `KakaoLoginProvider` | `kakao_login_provider.dart` | `kakao_flutter_sdk` | accessToken |
| `NaverLoginProvider` | `naver_login_provider.dart` | `flutter_naver_login` | accessToken |
| `GoogleLoginProvider` | `google_login_provider.dart` | `google_sign_in` | serverAuthCode (우선) / idToken |
| `AppleLoginProvider` | `apple_login_provider.dart` | `sign_in_with_apple` | authorizationCode |

- **공통 에러 처리**: 사용자 취소 → `AuthException(code: 'user_cancelled')`, 토큰 미반환 → 프로바이더별 에러 코드
- **Quick Start** (새 프로바이더 추가):
  1. `SocialLoginProvider` 상속 클래스 생성
  2. `signIn()`, `signOut()` 구현
  3. `LoginBinding`에서 `Get.lazyPut` 등록
  4. `LoginController`에서 호출 로직 추가

---

## 패키지별 제공 기능

### Core (`apps/mobile/packages/core/`)

기반 패키지. 다른 모든 패키지가 의존합니다.

**의존성**: `get`, `flutter_secure_storage`, `flutter`

#### 예외 클래스

| 클래스 | 속성 | 용도 |
|--------|------|------|
| `AuthException` | `code`, `message`, `data?` | 인증 실패, 토큰 만료, 계정 충돌 |
| `NetworkException` | `message`, `statusCode?` | 네트워크 연결 실패, 타임아웃 |

- **사용법**: `throw AuthException(code: 'user_cancelled', message: '사용자가 취소함')`
- **Controller에서 처리 패턴**:
  ```dart
  try { /* 로직 */ }
  on NetworkException catch (e) { /* 네트워크 에러 */ }
  on AuthException catch (e) {
    if (e.code == 'user_cancelled') return; // 무시
    if (e.code == 'account_conflict') { /* 계정 충돌 모달 */ }
    /* 인증 에러 */
  }
  catch (e) { /* 기타 에러 */ }
  ```

#### SecureStorageService

- **경로**: `apps/mobile/packages/core/lib/src/services/secure_storage_service.dart`
- **용도**: JWT 토큰 및 사용자 정보 암호화 저장
- **저장 키**:
  | 메서드 | 키 | 설명 |
  |--------|-----|------|
  | `saveAccessToken()` / `getAccessToken()` | `access_token` | JWT 액세스 토큰 |
  | `saveRefreshToken()` / `getRefreshToken()` | `refresh_token` | JWT 리프레시 토큰 |
  | `saveTokenExpiresAt()` / `isTokenExpired()` | `token_expires_at` | 토큰 만료 시간 |
  | `saveUserId()` / `getUserId()` | `user_id` | 사용자 ID |
  | `saveUserProvider()` / `getUserProvider()` | `user_provider` | 인증 프로바이더 |
  | `clearAll()` | 전체 | 로그아웃 시 전체 삭제 |

#### 디자인 토큰 (SketchDesignTokens)

Frame0 스케치 스타일 디자인 시스템의 기본 토큰입니다.

| 카테고리 | 주요 토큰 | 예시 |
|---------|---------|------|
| 선 두께 | `strokeThin(1)`, `strokeStandard(2)`, `strokeBold(3)` | 테두리, 구분선 |
| 간격 | `spacingXs(4)` ~ `spacing4Xl(64)` | 8px 그리드 기반 |
| 모서리 | `radiusSm(2)` ~ `radiusPill(9999)` | 카드, 버튼 |
| 색상 | `accentPrimary(#DF7D5F)`, `success`, `error` 등 | 테마 색상 |
| 폰트 | `fontSizeXs(12)` ~ `fontSize6Xl(60)` | 텍스트 크기 |
| 투명도 | `opacityDisabled(0.4)`, `opacitySketch(0.8)` | 비활성/스케치 효과 |

#### 컬러 팔레트 (SketchColorPalettes)

| 팔레트 | 특징 |
|--------|------|
| `pastel` | 부드러운 파스텔 톤 |
| `vibrant` | 선명한 원색 계열 |
| `monochrome` | 흑백 계열 |
| `earthy` | 자연스러운 따뜻한 톤 |
| `ocean` | 시원한 블루/틸 계열 |
| `sunset` | 따뜻한 오렌지/핑크 계열 |

- **사용법**: `SketchColorPalettes.getPalette('pastel')` → 색상 Map 반환

#### Logger

- **경로**: `apps/mobile/packages/core/lib/src/utils/logger.dart`
- **메서드**: `Logger.info()`, `Logger.warn()`, `Logger.error()`, `Logger.debug()`
- **특징**: kDebugMode 체크 (릴리스 빌드에서 자동 비활성화)

---

### API (`apps/mobile/packages/api/`)

HTTP 통신 패키지. Dio 기반.

**의존성**: `core`, `dio`, `json_annotation`, `freezed`, `build_runner`
**상태**: ✅ Auth + QnA API 구현 완료

#### 데이터 모델 (Freezed)

| 모델 | 경로 | 주요 필드 |
|------|------|---------|
| `QnaSubmitRequest` | `src/models/qna/qna_submit_request.dart` | `appCode`, `title`, `body` |
| `QnaSubmitResponse` | `src/models/qna/qna_submit_response.dart` | `questionId`, `issueNumber`, `issueUrl`, `createdAt` |
| `LoginRequest` | `src/models/auth/login_request.dart` | `provider`, `code` |
| `LoginResponse` | `src/models/auth/login_response.dart` | `accessToken`, `refreshToken`, `tokenType`, `expiresIn`, `user` |
| `RefreshRequest` | `src/models/auth/refresh_request.dart` | `refreshToken` |
| `RefreshResponse` | `src/models/auth/refresh_response.dart` | `accessToken`, `refreshToken`, `expiresIn` |
| `UserModel` | `src/models/auth/user_model.dart` | `id`, `provider`, `email?`, `nickname`, `profileImage?`, `appCode`, `lastLoginAt` |

#### API 서비스

| 서비스 | 메서드 | 엔드포인트 | 반환 |
|--------|--------|-----------|------|
| `QnaApiService` | `submitQuestion(request)` | POST `/api/qna/questions` | `QnaSubmitResponse` |
| `AuthApiService` | `login(provider, code)` | POST `/api/auth/oauth/login` | `LoginResponse` |
| `AuthApiService` | `refreshToken(refreshToken)` | POST `/api/auth/refresh` | `RefreshResponse` |

- **Dio 인스턴스**: `Get.find<Dio>()` (main.dart에서 등록, `API_BASE_URL` 환경변수 사용)

**Quick Start** (새 API 모델 추가):
1. `lib/src/models/` 하위에 Freezed 모델 파일 생성
2. `@freezed` + `@JsonSerializable` 어노테이션 적용
3. `melos generate` 실행 (또는 `melos generate:watch`)
4. 생성된 `.g.dart`, `.freezed.dart` 파일 자동 생성됨
5. `api.dart` barrel 파일에 export 추가

---

### Auth SDK (`apps/mobile/packages/auth_sdk/`)

인증 기능 SDK 패키지. 앱 간 재사용 가능한 독립 패키지.

**의존성**: `core`, `api`, `dio`, `freezed`, 소셜 로그인 SDK들
**상태**: ✅ 완료

#### 핵심 클래스

| 클래스 | 용도 |
|--------|------|
| `AuthSdk` | SDK 초기화 및 DI 등록 (config 기반) |
| `AuthRepository` | 로그인/로그아웃/토큰 갱신 |
| `AuthStateService` | 인증 상태 관리 (로그인 여부, 토큰 만료) |
| `AuthInterceptor` | Dio 인터셉터 (자동 토큰 주입, 401 갱신) |
| `AuthApiService` | 서버 API 호출 (login, refresh) |

#### 소셜 로그인 프로바이더

| 프로바이더 | SDK |
|-----------|-----|
| `KakaoLoginProvider` | `kakao_flutter_sdk` |
| `NaverLoginProvider` | `flutter_naver_login` |
| `GoogleLoginProvider` | `google_sign_in` |
| `AppleLoginProvider` | `sign_in_with_apple` |

- **기반 클래스**: `SocialLoginProvider` (abstract — `signIn()`, `signOut()`)

#### Freezed 모델

`LoginRequest`, `LoginResponse`, `RefreshRequest`, `RefreshResponse`, `UserModel`

- **Quick Start**:
  1. `AuthSdk.initialize(config)` 호출 (appCode, apiBaseUrl 설정)
  2. `AuthRepository.login(provider, code)` 으로 OAuth 로그인
  3. `AuthInterceptor`가 자동으로 토큰 주입 및 갱신 처리

---

### Notice SDK (`apps/mobile/packages/notice/`)

공지사항 기능 SDK 패키지.

**의존성**: `core`, `api`, `design_system`, `dio`, `get`
**상태**: ✅ 완료

#### 핵심 클래스

| 클래스 | 용도 |
|--------|------|
| `NoticeListController` | 공지 목록 조회, 페이지네이션, 새로고침 |
| `NoticeDetailController` | 공지 상세 조회 |
| `NoticeApiService` | 서버 API 호출 (목록, 상세, 미읽음 수) |
| `NoticeRoutes` | 공지 관련 라우트 정의 |

#### 모델

| 모델 | 용도 |
|------|------|
| `NoticeModel` | 공지 데이터 (id, title, content, category, isPinned, viewCount) |
| `NoticeListResponse` | 목록 응답 (items, totalCount, page, hasNext) |
| `UnreadCountResponse` | 미읽음 수 응답 |

#### 위젯

| 위젯 | 용도 |
|------|------|
| `NoticeListCard` | 공지 목록 카드 (읽음/미읽음 표시, 고정 배지) |
| `UnreadNoticeBadge` | 미읽음 공지 수 배지 |
| `NoticeListView` | 공지 목록 화면 |
| `NoticeDetailView` | 공지 상세 화면 |

- **서버 연동 API**:
  | 메서드 | 경로 | 용도 |
  |--------|------|------|
  | GET | `/notices` | 공지 목록 |
  | GET | `/notices/:id` | 공지 상세 |
  | GET | `/notices/unread-count` | 미읽음 수 |

- **Quick Start**:
  1. `NoticeRoutes`를 앱 라우트에 등록
  2. `NoticeListController`가 목록 자동 로드
  3. `UnreadNoticeBadge` 위젯으로 미읽음 수 표시

---

### Design System (`apps/mobile/packages/design_system/`)

Frame0 스케치 스타일 UI 컴포넌트 패키지.

**의존성**: `core`, `get`, `flutter_svg`
**상태**: ✅ 완료

#### 테마 시스템

| 클래스 | 용도 |
|--------|------|
| `SketchThemeExtension` | ThemeData에 스케치 스타일 속성 추가 |
| `SketchThemeController` | GetX 기반 테마 모드 관리 (라이트/다크) |

- **프리셋**: `.light()`, `.dark()`, `.rough()`, `.smooth()`, `.ultraSmooth()`, `.veryRough()`
- **테마 접근**: `SketchThemeExtension.of(context)`

#### 재사용 가능한 위젯 (12개)

| 위젯 | 용도 | 주요 속성 |
|------|------|---------|
| `SketchButton` | 버튼 | text, style(primary/secondary/outline), size, isLoading |
| `SketchContainer` | 컨테이너 | child, fillColor, borderColor, roughness, enableNoise |
| `SketchCard` | 카드 | header, body, footer, elevation(0-3), onTap |
| `SketchInput` | 텍스트 입력 | label, hint, errorText, controller, obscureText |
| `SketchModal` | 모달 다이얼로그 | `SketchModal.show(context, child:, title:)` (static) |
| `SketchCheckbox` | 체크박스 | value, tristate, activeColor |
| `SketchChip` | 칩/태그 | label, selected, onDeleted, icon |
| `SketchIconButton` | 아이콘 버튼 | icon, shape(circle/square), badgeCount |
| `SketchProgressBar` | 진행바 | value, style(linear/circular), showPercentage |
| `SketchSwitch` | 스위치 토글 | value, activeColor |
| `SketchSlider` | 슬라이더 | value, min, max, divisions |
| `SketchDropdown<T>` | 드롭다운 | value, items, itemBuilder |

#### 소셜 로그인 버튼

| 위젯 | 용도 |
|------|------|
| `SocialLoginButton` | 브랜드 가이드라인 준수 소셜 로그인 버튼 |

- **플랫폼**: kakao, naver, apple, google
- **사이즈**: small(40), medium(48), large(56)
- **애플 스타일**: dark, light
- **사용법**: `SocialLoginButton(platform: SocialLoginPlatform.kakao, onPressed: () {}, size: SocialLoginButtonSize.large)`

#### CustomPainter

| Painter | 용도 |
|---------|------|
| `SketchPainter` | 스케치 스타일 사각형 테두리 |
| `SketchCirclePainter` | 스케치 스타일 원형 |
| `SketchLinePainter` | 스케치 스타일 선 |
| `SketchPolygonPainter` | 스케치 스타일 다각형 |
| `AnimatedSketchPainter` | 애니메이션 스케치 효과 |

#### Enum

| Enum | 값 |
|------|-----|
| `SocialLoginPlatform` | kakao, naver, apple, google |
| `SocialLoginButtonSize` | small, medium, large |
| `AppleSignInStyle` | dark, light |
| `SketchButtonStyle` | primary, secondary, outline |
| `SketchButtonSize` | small, medium, large |
| `SketchIconButtonShape` | circle, square |
| `SketchProgressBarStyle` | linear, circular |

#### SVG 에셋

```
packages/design_system/assets/social_login/
├── kakao_symbol.svg
├── naver_logo.svg
├── apple_logo.svg
└── google_logo.svg
```

---

### AdMob (`apps/mobile/packages/admob/`)

Google 모바일 광고 패키지.

**의존성**: `core`, `google_mobile_ads`, `get`
**상태**: ✅ 완료

#### 핵심 클래스

| 클래스 | 용도 |
|--------|------|
| `AdMobService` | GetxService — AdMob SDK 초기화 및 광고 생성 |
| `BannerAdWidget` | StatefulWidget — 배너 광고 자동 로드/표시 |
| `AdMobConfig` | 플랫폼별 광고 단위 ID 설정 |

- **AdMobService 메서드**:
  | 메서드 | 설명 |
  |--------|------|
  | `initialize()` | MobileAds SDK 초기화 |
  | `createBannerAd(adSize, listener)` | 배너 광고 생성 |
  | `loadInterstitialAd(callback)` | 전면 광고 로드 |
  | `loadRewardedAd(callback)` | 리워드 광고 로드 |

- **Quick Start**:
  1. `main.dart`에서 `AdMobService().initialize()` 호출 (이미 설정됨)
  2. 뷰에서 `BannerAdWidget(adSize: AdSize.banner)` 배치
  3. 광고 로드 실패 시 `SizedBox.shrink()` 자동 반환 (빈 공간)

---

## 패키지 의존성 그래프

```
core (기반 - 내부 의존성 없음)
  ↑
  ├── api (HTTP 통신, 데이터 모델)
  ├── admob (Google 모바일 광고)
  ├── design_system (UI 컴포넌트, 테마)
  ├── auth_sdk (인증 SDK — core, api 의존)
  ├── qna (QnA SDK — core, api, design_system 의존)
  ├── notice (공지사항 SDK — core, api, design_system 의존)
  └── wowa app (모듈, 라우팅, 통합)
```

---

## 새 모듈 추가 체크리스트

1. `apps/wowa/lib/app/modules/[feature]/` 디렉토리 생성
2. `controllers/[feature]_controller.dart` — GetxController 상속
3. `views/[feature]_view.dart` — GetView<Controller> 상속
4. `bindings/[feature]_binding.dart` — Bindings 구현, `Get.lazyPut<Controller>()`
5. `app_routes.dart`에 라우트 상수 추가
6. `app_pages.dart`에 `GetPage` 등록 (binding + transition)
7. 필요 시 `packages/api`에 모델 및 API 서비스 추가
8. `melos bootstrap` 실행 (의존성 변경 시)
