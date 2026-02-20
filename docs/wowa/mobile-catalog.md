# Wowa 모바일 기능 카탈로그

> 모바일 앱에 구현된 모듈, 패키지, 위젯을 빠르게 찾기 위한 카탈로그입니다.
> 상세 분석은 `docs/core/` 하위 문서를 참조하세요.

## 앱 모듈

### 박스 (Box)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/box/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `controllers/box_create_controller.dart` — 박스 생성 (이름 2~50자, 지역 2~100자 실시간 검증)
  - `controllers/box_search_controller.dart` — 박스 검색 (300ms debounce), 가입 (단일 박스 정책)
  - `views/box_create_view.dart` — 이름/지역/설명 입력 폼
  - `views/box_search_view.dart` — 통합 키워드 검색, 5가지 UI 상태
  - `bindings/box_create_binding.dart`, `box_search_binding.dart`
- **사용 패키지**: `core`, `design_system`
- **서버 연동 API**: `POST /boxes`, `GET /boxes/search`, `POST /boxes/:boxId/join`, `GET /boxes/me`
- **라우트**: `Routes.BOX_SEARCH` = `/box/search`, `Routes.BOX_CREATE` = `/box/create`

---

### WOD (Workout of the Day)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/wod/`
- **상태**: ✅ 완료 (5 Controller + 5 View + 5 Binding)
- **핵심 파일**:
  - `controllers/home_controller.dart` — WOD 홈 (날짜 네비게이션, 박스 미가입 시 리다이렉트)
  - `controllers/wod_register_controller.dart` — WOD 등록 (AMRAP/FOR_TIME/EMOM/CUSTOM, 동적 운동 리스트)
  - `controllers/wod_detail_controller.dart` — Base WOD + Personal WOD 비교
  - `controllers/wod_select_controller.dart` — WOD 선택 (확인 모달 필수)
  - `controllers/proposal_review_controller.dart` — 제안 승인/거부 (Before/After 비교)
  - `views/`, `bindings/` — 각 컨트롤러에 대응
- **사용 패키지**: `core`, `design_system`
- **서버 연동 API**: `POST /wods`, `GET /wods/:boxId/:date`, `POST /wods/proposals`, `POST /wods/:wodId/select`
- **라우트**: `Routes.HOME`, `Routes.WOD_REGISTER`, `Routes.WOD_DETAIL`, `Routes.WOD_SELECT`, `Routes.PROPOSAL_REVIEW`

---

### 알림 (Notification)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/notification/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `controllers/notification_controller.dart` — 알림 목록, 무한 스크롤 (page=20), 미읽음 수, 딥링크 처리
  - `views/notification_view.dart` — RefreshIndicator, 4가지 상태, NEW 배지, 상대시간
  - `bindings/notification_binding.dart`
- **사용 패키지**: `push`, `core`, `design_system`
- **서버 연동 API**: `GET /push/notifications/me`, `GET /push/notifications/unread-count`, `PATCH /push/notifications/:id/read`
- **라우트**: `Routes.NOTIFICATIONS` = `/notifications`

---

### 설정 (Settings)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/settings/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `controllers/settings_controller.dart` — 현재 박스 조회, 공지 미읽음 수, 박스 변경, 로그아웃
  - `views/settings_view.dart` — 박스 카드, 공지 메뉴 (미읽음 뱃지), 로그아웃
  - `bindings/settings_binding.dart`
- **사용 패키지**: `auth_sdk`, `notice`, `core`, `design_system`
- **라우트**: `Routes.SETTINGS` = `/settings`

---

## 라우팅

- **정의**: `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart`
- **페이지**: `apps/mobile/apps/wowa/lib/app/routes/app_pages.dart`
- **등록된 라우트**:
  | 경로 | 모듈 | 설명 |
  |------|------|------|
  | `/login` | auth_sdk | 소셜 로그인 화면 |
  | `/home` | wod | WOD 홈 (날짜별 WOD 표시) |
  | `/box/search` | box | 박스 검색 |
  | `/box/create` | box | 박스 생성 |
  | `/wod/register` | wod | WOD 등록 |
  | `/wod/detail` | wod | WOD 상세/비교 |
  | `/wod/select` | wod | WOD 선택 |
  | `/wod/proposal/review` | wod | 제안 검토 |
  | `/notifications` | notification | 알림 목록 |
  | `/notice/list` | notice SDK | 공지사항 목록 |
  | `/notice/detail` | notice SDK | 공지사항 상세 |
  | `/qna` | qna SDK | 질문 작성 |
  | `/settings` | settings | 설정 |
- **초기 라우트**: 인증 상태에 따라 `/home` 또는 `/login`
- **딥링크 허용 화면**: `notifications`, `home`, `qna`

---

## 앱 데이터 레이어

**경로**: `apps/mobile/apps/wowa/lib/app/data/`

### API 클라이언트

| 클라이언트 | 주요 엔드포인트 |
|-----------|---------------|
| `BoxApiClient` | `GET /boxes/me`, `GET /boxes/search`, `POST /boxes`, `POST /boxes/:id/join` |
| `WodApiClient` | `POST /wods`, `GET /wods/:boxId/:date`, `POST /wods/:id/select`, `GET /wods/selections` |
| `ProposalApiClient` | `GET /wods/proposals`, `POST /wods/proposals/:id/approve`, `POST /wods/proposals/:id/reject` |

### Repository

| Repository | 역할 |
|-----------|------|
| `BoxRepository` | BoxApiClient 래핑 + 에러 변환 |
| `WodRepository` | WodApiClient 래핑 |
| `ProposalRepository` | ProposalApiClient 래핑, 미결 제안 조회 |

### Freezed 모델

- **Box**: `BoxModel`, `BoxCreateResponse`, `BoxSearchResponse`, `CreateBoxRequest`, `BoxMemberModel`, `MembershipModel`
- **WOD**: `WodModel`, `WodListResponse`, `RegisterWodRequest`, `Movement`, `ProgramData`
- **Proposal**: `ProposalModel`
- **Selection**: `SelectionModel`

---

## 패키지별 제공 기능

### Core (`apps/mobile/packages/core/`)

기반 패키지. 다른 모든 패키지가 의존합니다.

| 제공 기능 | 설명 |
|----------|------|
| `AuthException` | 인증 예외 (`code`, `message`, `data?`) |
| `NetworkException` | 네트워크 예외 (`message`, `statusCode?`) |
| `BusinessException` | 비즈니스 로직 예외 |
| `SecureStorageService` | JWT 토큰/사용자 정보 암호화 저장 |
| `Logger` | 로그 유틸리티 (kDebugMode 체크) |
| `SketchDesignTokens` | 색상, 간격, 타이포, 선두께, 불투명도 상수 |
| `SketchColorPalettes` | 6종 색상 팔레트 (pastel, vibrant, monochrome, earthy, ocean, sunset) |

---

### Auth SDK (`apps/mobile/packages/auth_sdk/`)

인증 기능 SDK 패키지. 앱 간 재사용 가능한 독립 패키지.

**의존성**: `core`, `design_system`, `dio`, 소셜 로그인 SDK들
**상태**: ✅ 완료

| 클래스 | 용도 |
|--------|------|
| `AuthSdk` | 정적 facade — `initialize()`, `login()`, `logout()`, `isAuthenticated()`, `authState` |
| `AuthSdkConfig` | 설정 객체 (appCode, apiBaseUrl, homeRoute, providers, onPreLogout) |
| `AuthStateService` | GetxService — 인증 상태 반응형 관리 |
| `AuthRepository` | 로그인/로그아웃/토큰갱신 + SecureStorage 연동 |
| `AuthApiService` | `POST /auth/oauth`, `POST /auth/refresh`, `POST /auth/logout` |
| `AuthInterceptor` | Dio 인터셉터 — Access Token 자동 주입, 401 시 자동 갱신 |

**소셜 로그인 프로바이더**: `KakaoLoginProvider`, `NaverLoginProvider`, `GoogleLoginProvider`, `AppleLoginProvider`
**내장 UI**: `LoginView`, `LoginController`, `LoginBinding`
**Freezed 모델**: `LoginRequest`, `LoginResponse`, `RefreshRequest`, `RefreshResponse`, `UserModel`

- **Quick Start**:
  1. `AuthSdk.initialize(config)` 호출 (appCode, apiBaseUrl 설정)
  2. `LoginView`/`LoginBinding` 라우트 등록
  3. `AuthInterceptor`가 자동으로 토큰 주입 및 갱신 처리

---

### Push SDK (`apps/mobile/packages/push/`)

FCM 푸시 알림 SDK 패키지.

**의존성**: `core`, `firebase_messaging`, `device_info_plus`, `dio`, `get`
**상태**: ✅ 완료

| 클래스 | 용도 |
|--------|------|
| `PushService` | GetxService — FCM 초기화, 권한 요청, 토큰 획득/갱신, 알림 핸들링 |
| `PushApiClient` | 디바이스 등록/비활성화, 알림 목록/미읽음 수/읽음 처리 |

- **서버 연동 API**: `POST /push/devices`, `POST /push/devices/deactivate`, `GET /push/notifications/me`, `GET /push/notifications/unread-count`, `PATCH /push/notifications/:id/read`
- **Freezed 모델**: `DeviceTokenRequest`, `NotificationModel`, `NotificationListResponse`, `UnreadCountResponse`

---

### Notice SDK (`apps/mobile/packages/notice/`)

공지사항 기능 SDK 패키지.

**의존성**: `core`, `design_system`, `dio`, `get`
**상태**: ✅ 완료

| 클래스 | 용도 |
|--------|------|
| `NoticeApiService` | `GET /notices`, `GET /notices/:id`, `GET /notices/unread-count` |
| `NoticeListController` | 공지 목록, 페이지네이션 |
| `NoticeDetailController` | 공지 상세 |

- **내장 UI**: `NoticeListView`, `NoticeDetailView`
- **위젯**: `NoticeListCard` (읽음/미읽음, 고정 배지), `UnreadNoticeBadge`
- **Freezed 모델**: `NoticeModel`, `NoticeListResponse`, `UnreadCountResponse`

---

### QnA SDK (`apps/mobile/packages/qna/`)

Q&A 질문 작성 SDK 패키지.

**의존성**: `core`, `design_system`, `dio`, `get`
**상태**: ✅ 완료

| 클래스 | 용도 |
|--------|------|
| `QnaApiService` | `POST /qna/questions` |
| `QnaRepository` | QnaApiService 래핑 + appCode 주입 |
| `QnaController` | 제목(256자)/본문(65536자) 검증, 제출, 성공/실패 모달 |
| `QnaBinding` | `QnaBinding(appCode: 'wowa')` |

- **내장 UI**: `QnaSubmitView`
- **Freezed 모델**: `QnaSubmitRequest`, `QnaSubmitResponse`

---

### AdMob (`apps/mobile/packages/admob/`)

Google 모바일 광고 패키지.

**의존성**: `core`, `google_mobile_ads`, `get`
**상태**: ✅ 완료

| 클래스 | 용도 |
|--------|------|
| `AdMobService` | GetxService — SDK 초기화, 배너/전면/리워드 광고 생성 |
| `BannerAdWidget` | 배너 광고 자동 로드/표시 (실패 시 빈 공간) |
| `AdMobConfig` | 플랫폼별 광고 단위 ID 설정 |

---

### Design System (`apps/mobile/packages/design_system/`)

Frame0 스케치 스타일 UI 컴포넌트 패키지.

**의존성**: `core`, `get`, `flutter_svg`
**상태**: ✅ 완료

#### 테마

| 클래스 | 용도 |
|--------|------|
| `SketchThemeExtension` | ThemeData에 스케치 스타일 속성 추가 (6 프리셋) |
| `SketchThemeController` | GetX 기반 테마 모드 관리 |

#### 재사용 위젯 (25개)

| 카테고리 | 위젯 |
|---------|------|
| 입력 | `SketchInput`, `SketchTextArea`, `SketchDropdown<T>` |
| 버튼 | `SketchButton` (4style x 3size), `SketchIconButton`, `SocialLoginButton` |
| 선택 | `SketchCheckbox`, `SketchRadio<T>`, `SketchSwitch`, `SketchSlider`, `SketchChip` |
| 레이아웃 | `SketchContainer`, `SketchCard`, `SketchModal`, `SketchDivider` |
| 피드백 | `SketchSnackbar`, `SketchProgressBar` |
| 내비게이션 | `SketchAppBar`, `SketchTabBar`, `SketchBottomNavigationBar`, `SketchLink` |
| 표시 | `SketchAvatar`, `SketchImagePlaceholder` |

#### CustomPainter (10개)

`SketchPainter`, `SketchCirclePainter`, `SketchLinePainter`, `SketchPolygonPainter`, `AnimatedSketchPainter`, `HatchingPainter`, `SketchSnackbarIconPainter`, `SketchTabPainter`, `SketchXClosePainter`, `XCrossPainter`

---

## 패키지 의존성 그래프

```
core (기반 - 내부 의존성 없음)
  ↑
  ├── design_system (UI 컴포넌트, 테마)
  ├── auth_sdk     (인증 SDK — core, design_system, Dio)
  ├── push         (푸시 알림 SDK — core, Dio)
  ├── notice       (공지사항 SDK — core, design_system, Dio)
  ├── qna          (QnA SDK — core, design_system, Dio)
  ├── admob        (광고 SDK — core)
  └── wowa app     (box, wod, notification, settings 모듈)
```

---

## 새 모듈 추가 체크리스트

1. `apps/wowa/lib/app/modules/[feature]/` 디렉토리 생성
2. `controllers/[feature]_controller.dart` — GetxController 상속
3. `views/[feature]_view.dart` — GetView<Controller> 상속
4. `bindings/[feature]_binding.dart` — Bindings 구현, `Get.lazyPut<Controller>()`
5. `app_routes.dart`에 라우트 상수 추가
6. `app_pages.dart`에 `GetPage` 등록 (binding + transition)
7. 필요 시 `data/` 하위에 API 클라이언트, Repository, Freezed 모델 추가
8. `melos bootstrap` 실행 (의존성 변경 시)
