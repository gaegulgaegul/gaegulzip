# 모바일 작업 분배 계획: 푸시 알림 (Push Notification)

## 개요

**재사용 가능한 FCM SDK 패키지**(packages/push/)를 구축하고, 서버 API 연동 모델을 packages/api/에 추가하며, apps/wowa/에서 알림 목록 UI와 딥링크 처리를 구현합니다.

**작업 방식**: GetX 패턴 준수 (Controller, View, Binding 분리), const 최적화, Obx 범위 최소화

---

## 실행 그룹

### Group 1 (병렬) — Server API 비의존 작업

Server API 완료를 기다리지 않고 즉시 시작 가능한 작업들입니다.

| 모듈 | 개발자 | 설명 | Server 의존성 |
|------|--------|------|--------------|
| packages/push/ | flutter-developer | FCM SDK 패키지 (토큰 관리, 알림 리스너) | ❌ 없음 |
| packages/api/ 모델 | flutter-developer | Freezed 모델 4개 (Server brief 기반) | ⚠️ API 계약만 (구현 불필요) |
| apps/wowa/ 라우팅 | flutter-developer | Route 정의, 빈 View 생성 | ❌ 없음 |
| Firebase 설정 | flutter-developer | iOS/Android 설정 파일 배치 | ❌ 없음 |

**의존성**: 각 작업 독립적 (병렬 실행 가능)

---

### Group 2 (병렬) — Server API 의존 작업

**Group 1 완료** + **Server API 완료** 후 시작 가능한 작업들입니다.

| 모듈 | 개발자 | 설명 | 의존성 |
|------|--------|------|--------|
| packages/api/ 클라이언트 | flutter-developer | PushApiClient 구현 (4개 API 메서드) | Server API 완료 |
| apps/wowa/ Controller | flutter-developer | NotificationController (상태 관리, API 연동) | packages/api/ 완료 |
| apps/wowa/ View | flutter-developer | NotificationView (UI) | Controller 완료 |
| apps/wowa/ Binding | flutter-developer | NotificationBinding (DI) | Controller 완료 |
| apps/wowa/ main.dart | flutter-developer | PushService 초기화, 핸들러 등록 | packages/push/ 완료 |

**의존성**: packages/api/ 클라이언트 → apps/wowa/ Controller → View → Binding → main.dart

---

## Module Contracts (모듈 간 계약)

### 1. packages/push/ → apps/wowa/ main.dart

**Input**: 없음 (독립적 패키지)

**Output**:
- `PushService` (GetxService)
  - `deviceToken: Rxn<String>` — 현재 디바이스 토큰 (반응형)
  - `isInitialized: RxBool` — 초기화 완료 여부
  - `initialize()` — Firebase 초기화, 권한 요청, 토큰 획득
  - 콜백 주입:
    - `onForegroundMessage: PushHandlerCallback?`
    - `onBackgroundMessageOpened: PushHandlerCallback?`
    - `onTerminatedMessageOpened: PushHandlerCallback?`
- `PushNotification` 모델
  - `title: String`, `body: String`, `imageUrl: String?`, `data: Map<String, dynamic>`

**검증 기준**:
- PushService 초기화 성공 (로그 확인)
- 디바이스 토큰 획득 (deviceToken.value != null)
- 콜백 호출 확인 (포그라운드 알림 수신 시)

---

### 2. packages/api/ 모델 → packages/api/ 클라이언트

**Input**: 없음 (Freezed 모델 독립 생성 가능)

**Output** (Freezed 모델 4개):
- `DeviceTokenRequest` — 토큰 등록 요청
  - `token: String`, `platform: String`, `deviceId: String?`
- `NotificationModel` — 알림 수신 기록
  - `id: int`, `title: String`, `body: String`, `imageUrl: String?`, `data: Map<String, dynamic>`, `isRead: bool`, `readAt: String?`, `receivedAt: String`
- `NotificationListResponse` — 알림 목록 응답
  - `notifications: List<NotificationModel>`, `total: int`
- `UnreadCountResponse` — 읽지 않은 개수 응답
  - `unreadCount: int`

**검증 기준**:
- `melos generate` 성공 (Freezed 코드 생성)
- `.freezed.dart`, `.g.dart` 파일 생성 확인
- fromJson/toJson 메서드 동작 확인

---

### 3. packages/api/ 클라이언트 → apps/wowa/ Controller

**Input**: Freezed 모델 (Group 1에서 생성)

**Output** (PushApiClient):
- `registerDevice(DeviceTokenRequest)` — POST /push/devices
- `getMyNotifications({limit, offset, unreadOnly})` — GET /push/notifications/me
- `getUnreadCount()` — GET /push/notifications/unread-count
- `markAsRead(notificationId)` — PATCH /push/notifications/:id/read

**검증 기준**:
- Dio 인스턴스 주입 성공 (`Get.find<Dio>()`)
- 인증 헤더 자동 포함 (Dio Interceptor)
- API 호출 성공 (Server API 완료 후 통합 테스트)

---

### 4. apps/wowa/ Controller → View

**Input**: PushApiClient (Group 2에서 생성)

**Output** (NotificationController):
- **반응형 상태**:
  - `notifications: RxList<NotificationModel>` — 알림 목록
  - `unreadCount: RxInt` — 읽지 않은 개수
  - `isLoading: RxBool` — 로딩 상태
  - `errorMessage: RxString` — 에러 메시지
  - `isLoadingMore: RxBool` — 페이징 로딩
  - `hasMore: RxBool` — 더 불러올 데이터 존재 여부
- **메서드**:
  - `fetchNotifications({refresh})` — 알림 목록 조회
  - `loadMore()` — 무한 스크롤
  - `fetchUnreadCount()` — 읽지 않은 개수 조회
  - `handleNotificationTap(notification)` — 알림 탭 처리 (읽음 처리 + 딥링크)
  - `refreshNotifications()` — Pull-to-refresh
  - `retryLoadNotifications()` — 재시도

**검증 기준**:
- 반응형 변수 정확히 정의 (.obs)
- onInit에서 초기 데이터 로드
- 에러 처리 (NetworkException 분기)
- 낙관적 업데이트 (읽음 처리 시 UI 즉시 업데이트)

---

### 5. apps/wowa/ View → Binding

**Input**: NotificationController (Group 2에서 생성)

**Output** (NotificationView):
- AppBar (제목, 뒤로가기, 설정 아이콘)
- RefreshIndicator (Pull-to-refresh)
- Obx 상태별 렌더링:
  - 로딩: SketchProgressBar (circular)
  - 에러: 에러 아이콘 + 메시지 + 재시도 버튼
  - 빈 목록: 빈 상태 아이콘 + 안내 메시지
  - 성공: ListView.builder (NotificationCard 반복)
- 무한 스크롤 (페이징 로더)

**검증 기준**:
- const 생성자 적절히 사용
- Obx 범위 최소화 (상태별 분기만)
- SketchCard 활용 (elevation, borderColor)
- 읽지 않은 알림 시각적 구분 (굵은 글씨, 배지, 테두리)

---

### 6. apps/wowa/ Binding → main.dart

**Input**: NotificationController (Group 2에서 생성)

**Output** (NotificationBinding):
- PushApiClient 지연 로딩 (`Get.lazyPut`)
- NotificationController 지연 로딩 (`Get.lazyPut`)

**검증 기준**:
- GetPage에 binding 등록 확인
- Controller 의존성 자동 주입 (Get.find)

---

## 작업 상세

### Group 1 작업

---

#### 작업 1-1: packages/push/ 패키지 생성

**담당자**: flutter-developer
**예상 소요 시간**: 2시간

##### 목표
재사용 가능한 FCM SDK 패키지 구축 (앱 독립적)

##### 구현 파일
- `packages/push/pubspec.yaml` (신규)
- `packages/push/lib/src/push_service.dart` (신규)
- `packages/push/lib/src/push_notification.dart` (신규)
- `packages/push/lib/src/push_handler_callback.dart` (신규)
- `packages/push/lib/push.dart` (신규)

##### 체크리스트
- [ ] pubspec.yaml 작성:
  - firebase_core: ^3.8.1
  - firebase_messaging: ^15.1.5
  - get: ^4.6.6
  - core: path: ../core
- [ ] PushService (GetxService) 구현:
  - `initialize()` — Firebase 초기화, 권한 요청, 토큰 획득
  - `deviceToken: Rxn<String>` — 토큰 반응형 변수
  - 3가지 알림 상태 리스너 (포그라운드, 백그라운드, 종료)
  - 콜백 주입 패턴 (onForegroundMessage, etc.)
- [ ] PushNotification 모델 구현:
  - `fromRemoteMessage(RemoteMessage)` 팩토리 메서드
  - title, body, imageUrl, data 필드
- [ ] PushHandlerCallback 타입 정의
- [ ] push.dart exports 작성
- [ ] melos bootstrap 실행
- [ ] 모든 주석 한글 작성 (JSDoc 스타일)

##### 참조 문서
- `docs/wowa/push-alert/mobile-brief.md` (packages/push 섹션)
- `.claude/guide/mobile/getx_best_practices.md`

---

#### 작업 1-2: packages/api/ Freezed 모델 추가

**담당자**: flutter-developer
**예상 소요 시간**: 1시간

##### 목표
푸시 알림 API 모델 4개 생성 (Server brief 기반)

##### 구현 파일
- `packages/api/lib/src/models/push/device_token_request.dart` (신규)
- `packages/api/lib/src/models/push/notification_model.dart` (신규)
- `packages/api/lib/src/models/push/notification_list_response.dart` (신규)
- `packages/api/lib/src/models/push/unread_count_response.dart` (신규)
- `packages/api/lib/api.dart` (수정 — exports 추가)

##### 체크리스트
- [ ] DeviceTokenRequest 모델 작성
- [ ] NotificationModel 모델 작성
- [ ] NotificationListResponse 모델 작성
- [ ] UnreadCountResponse 모델 작성
- [ ] api.dart에 exports 추가
- [ ] melos generate 실행
- [ ] .freezed.dart, .g.dart 파일 생성 확인
- [ ] fromJson/toJson 메서드 동작 확인

##### 참조 문서
- `docs/wowa/push-alert/mobile-brief.md` (API 모델 섹션)
- `docs/wowa/push-alert/server-brief.md` (API 응답 형식)

---

#### 작업 1-3: apps/wowa/ 라우팅 설정

**담당자**: flutter-developer
**예상 소요 시간**: 30분

##### 목표
알림 목록 화면 라우트 정의 및 빈 View 생성

##### 구현 파일
- `apps/wowa/lib/app/routes/app_routes.dart` (수정)
- `apps/wowa/lib/app/routes/app_pages.dart` (수정)
- `apps/wowa/lib/app/modules/notification/views/notification_view.dart` (신규 — 빈 Scaffold)

##### 체크리스트
- [ ] Routes.NOTIFICATIONS 상수 추가 (`/notifications`)
- [ ] app_pages.dart에 GetPage 추가:
  - name: Routes.NOTIFICATIONS
  - page: () => const NotificationView()
  - transition: Transition.fadeIn
- [ ] 빈 NotificationView 생성 (Scaffold + AppBar만)
- [ ] 라우트 순서 확인 (명시적 경로 우선)

##### 참조 문서
- `.claude/guide/mobile/directory_structure.md`
- 기존 app_routes.dart, app_pages.dart 파일 참조

---

#### 작업 1-4: Firebase 프로젝트 설정

**담당자**: flutter-developer
**예상 소요 시간**: 1시간

##### 목표
Firebase Console 설정 및 iOS/Android 설정 파일 배치

##### 구현 파일
- `apps/wowa/ios/Runner/GoogleService-Info.plist` (Firebase Console에서 다운로드)
- `apps/wowa/android/app/google-services.json` (Firebase Console에서 다운로드)
- `apps/wowa/ios/Runner/Info.plist` (수정)
- `apps/wowa/android/app/build.gradle` (수정)
- `apps/wowa/android/build.gradle` (수정)

##### 체크리스트
- [ ] Firebase Console에서 iOS 앱 추가 → GoogleService-Info.plist 다운로드
- [ ] Firebase Console에서 Android 앱 추가 → google-services.json 다운로드
- [ ] iOS Info.plist에 권한 메시지 추가
- [ ] iOS Xcode에서 Push Notifications Capability 활성화
- [ ] Android build.gradle에 google-services 플러그인 추가
- [ ] flutter clean && flutter pub get 실행
- [ ] flutter run 성공 확인 (에러 없음)

##### 참조 문서
- `docs/wowa/push-alert/mobile-brief.md` (Firebase 설정 섹션)

---

### Group 2 작업 (Server API 완료 후)

---

#### 작업 2-1: packages/api/ PushApiClient 구현

**담당자**: flutter-developer
**예상 소요 시간**: 1시간

##### 목표
푸시 알림 API 클라이언트 구현 (4개 API 메서드)

##### 구현 파일
- `packages/api/lib/src/clients/push_api_client.dart` (신규)
- `packages/api/lib/api.dart` (수정 — exports 추가)

##### 체크리스트
- [ ] PushApiClient 클래스 작성
- [ ] Dio 의존성 주입 (`Get.find<Dio>()`)
- [ ] 4개 API 메서드 구현:
  - `registerDevice(DeviceTokenRequest)` — POST /push/devices
  - `getMyNotifications({limit, offset, unreadOnly})` — GET /push/notifications/me
  - `getUnreadCount()` — GET /push/notifications/unread-count
  - `markAsRead(notificationId)` — PATCH /push/notifications/:id/read
- [ ] api.dart에 exports 추가
- [ ] Server API 완료 후 통합 테스트 (Postman 또는 curl)

##### 참조 문서
- `docs/wowa/push-alert/mobile-brief.md` (API 클라이언트 섹션)
- `docs/wowa/push-alert/server-brief.md` (API 엔드포인트)

---

#### 작업 2-2: apps/wowa/ NotificationController 구현

**담당자**: flutter-developer
**예상 소요 시간**: 2시간

##### 목표
알림 목록 화면 비즈니스 로직 구현 (상태 관리, API 연동, 딥링크)

##### 구현 파일
- `apps/wowa/lib/app/modules/notification/controllers/notification_controller.dart` (신규)

##### 체크리스트
- [ ] NotificationController (GetxController) 클래스 작성
- [ ] 반응형 상태 정의:
  - `notifications: RxList<NotificationModel>`
  - `unreadCount: RxInt`
  - `isLoading: RxBool`
  - `errorMessage: RxString`
  - `isLoadingMore: RxBool`
  - `hasMore: RxBool`
- [ ] PushApiClient 의존성 주입 (`Get.find<PushApiClient>()`)
- [ ] onInit에서 초기 데이터 로드
- [ ] 메서드 구현:
  - `fetchNotifications({refresh})`
  - `loadMore()` — 무한 스크롤
  - `fetchUnreadCount()`
  - `handleNotificationTap(notification)` — 읽음 처리 + 딥링크
  - `refreshNotifications()` — Pull-to-refresh
  - `retryLoadNotifications()` — 재시도
- [ ] 낙관적 업데이트 구현 (읽음 처리 시 UI 즉시 업데이트)
- [ ] 에러 처리 (NetworkException 분기)
- [ ] 딥링크 처리 로직 (`_handleDeepLink(data)`)
- [ ] 모든 주석 한글 작성

##### 참조 문서
- `docs/wowa/push-alert/mobile-brief.md` (Controller 섹션)
- `.claude/guide/mobile/getx_best_practices.md`
- `.claude/guide/mobile/error_handling.md`

---

#### 작업 2-3: apps/wowa/ NotificationView 구현

**담당자**: flutter-developer
**예상 소요 시간**: 3시간

##### 목표
알림 목록 화면 UI 구현 (상태별 렌더링, 무한 스크롤, 카드 레이아웃)

##### 구현 파일
- `apps/wowa/lib/app/modules/notification/views/notification_view.dart` (수정 — Group 1의 빈 View 확장)

##### 체크리스트
- [ ] NotificationView (GetView<NotificationController>) 클래스 작성
- [ ] AppBar 구현:
  - 제목: "알림"
  - leading: SketchIconButton (뒤로가기)
  - actions: SketchIconButton (설정)
- [ ] RefreshIndicator 추가 (Pull-to-refresh)
- [ ] Obx 상태별 렌더링:
  - 로딩: SketchProgressBar (circular, value: null)
  - 에러: 에러 화면 (아이콘, 메시지, 재시도 버튼)
  - 빈 목록: 빈 상태 화면 (아이콘, 안내 메시지)
  - 성공: ListView.builder (NotificationCard 반복)
- [ ] NotificationCard 위젯 구현:
  - SketchCard 활용 (elevation, borderColor, strokeWidth)
  - 읽지 않은 알림: accentPrimary 테두리 (3px), 제목 bold, "NEW" 배지
  - 읽은 알림: base300 테두리 (2px), 제목 normal
  - onTap: controller.handleNotificationTap(notification)
- [ ] 무한 스크롤 로더 (리스트 끝에 CircularProgressIndicator)
- [ ] 상대 시간 포맷팅 함수 (`_formatRelativeTime`)
- [ ] const 최적화 (정적 위젯)
- [ ] Obx 범위 최소화
- [ ] 모든 주석 한글 작성

##### 참조 문서
- `docs/wowa/push-alert/mobile-design-spec.md` (화면 구조)
- `.claude/guide/mobile/flutter_best_practices.md`
- `.claude/guide/mobile/design_system.md`
- `.claude/guide/mobile/common_widgets.md`

---

#### 작업 2-4: apps/wowa/ NotificationBinding 구현

**담당자**: flutter-developer
**예상 소요 시간**: 15분

##### 목표
알림 모듈 의존성 주입 (DI)

##### 구현 파일
- `apps/wowa/lib/app/modules/notification/bindings/notification_binding.dart` (신규)

##### 체크리스트
- [ ] NotificationBinding (Bindings) 클래스 작성
- [ ] dependencies() 메서드 구현:
  - PushApiClient 지연 로딩 (`Get.lazyPut`)
  - NotificationController 지연 로딩 (`Get.lazyPut`)
- [ ] app_pages.dart의 GetPage에 binding 등록 확인
- [ ] 모든 주석 한글 작성

##### 참조 문서
- `.claude/guide/mobile/getx_best_practices.md`

---

#### 작업 2-5: apps/wowa/ main.dart 수정

**담당자**: flutter-developer
**예상 소요 시간**: 1시간

##### 목표
PushService 초기화, 알림 핸들러 등록, 디바이스 토큰 자동 등록

##### 구현 파일
- `apps/wowa/lib/main.dart` (수정)

##### 체크리스트
- [ ] packages/push 패키지 import
- [ ] PushService 초기화 (`await pushService.initialize()`)
- [ ] PushService 전역 등록 (`Get.put<PushService>(pushService, permanent: true)`)
- [ ] 포그라운드 알림 핸들러 등록 (onForegroundMessage):
  - Get.snackbar로 간단한 배너 표시
  - 탭 시 딥링크 처리
- [ ] 백그라운드/종료 상태 알림 핸들러 등록:
  - onBackgroundMessageOpened
  - onTerminatedMessageOpened
  - 딥링크 처리 (Get.toNamed)
- [ ] 디바이스 토큰 자동 등록 (ever):
  - pushService.deviceToken 변경 감지
  - PushApiClient.registerDevice() 호출
  - 플랫폼 판단 (GetPlatform.isIOS ? 'ios' : 'android')
- [ ] 에러 처리 (try-catch)
- [ ] 모든 주석 한글 작성

##### 참조 문서
- `docs/wowa/push-alert/mobile-brief.md` (main.dart 섹션)
- `.claude/guide/mobile/getx_best_practices.md`

---

#### 작업 2-6: apps/wowa/ UnreadBadgeIcon 위젯 구현 (선택 사항)

**담당자**: flutter-developer
**예상 소요 시간**: 30분

##### 목표
읽지 않은 알림 배지 표시 (네비게이션 바 또는 홈 화면)

##### 구현 파일
- `apps/wowa/lib/app/widgets/unread_badge_icon.dart` (신규)

##### 체크리스트
- [ ] UnreadBadgeIcon (StatelessWidget) 클래스 작성
- [ ] Stack + Positioned 레이아웃
- [ ] SketchIconButton (알림 아이콘)
- [ ] Obx로 배지 조건부 렌더링 (unreadCount > 0)
- [ ] Container (배지):
  - color: SketchDesignTokens.error
  - borderRadius: pill (원형)
  - border: white 2px
  - 개수 표시: 1~99 또는 "99+"
- [ ] const 최적화
- [ ] 모든 주석 한글 작성

##### 참조 문서
- `docs/wowa/push-alert/mobile-design-spec.md` (UnreadBadge 섹션)

---

## 검증 기준

### 기능 검증
- [ ] Firebase 초기화 성공 (앱 시작 시 로그 확인)
- [ ] 디바이스 토큰 획득 및 서버 등록 성공
- [ ] 포그라운드 알림 수신 시 스낵바 표시
- [ ] 백그라운드 알림 탭 시 앱 열림 + 딥링크 이동
- [ ] 종료 상태 알림 탭 시 앱 실행 + 딥링크 이동
- [ ] 알림 목록 조회 성공 (인증된 사용자)
- [ ] 알림 탭 시 읽음 처리 성공 (UI 즉시 업데이트)
- [ ] 읽지 않은 알림 개수 정확히 표시
- [ ] 무한 스크롤 정상 동작
- [ ] Pull-to-refresh 정상 동작

### 보안 검증
- [ ] 디바이스 토큰 등록 시 인증 헤더 포함 (Dio Interceptor)
- [ ] 알림 목록 조회 시 인증 헤더 포함
- [ ] 다른 사용자의 알림 접근 불가 (서버 측 검증)

### 성능 검증
- [ ] 알림 목록 20개 로딩: 1초 이내
- [ ] 읽음 처리 응답: 500ms 이내
- [ ] const 생성자 적절히 사용됨
- [ ] Obx 범위 최소화됨
- [ ] ListView.builder 사용으로 무한 스크롤 지원

### 코드 품질
- [ ] GetX 패턴 준수 (Controller, View, Binding 분리)
- [ ] 반응형 상태 정확히 정의 (.obs)
- [ ] const 최적화 적용
- [ ] 에러 처리 완비 (NetworkException, 일반 에러)
- [ ] 라우팅 설정 정확
- [ ] 모든 주석 한글 작성
- [ ] CLAUDE.md 표준 준수

### Design System 준수
- [ ] SketchCard, SketchButton, SketchIconButton, SketchChip, SketchProgressBar 활용
- [ ] Frame0 스케치 스타일 (테두리, 손그림 느낌)
- [ ] 읽지 않은 알림 시각적 구분 (굵은 글씨, 배지, 테두리)
- [ ] 색상: SketchDesignTokens 사용
- [ ] 간격: 8px 그리드 시스템 준수

---

## 참고 자료

- **User Story**: `docs/wowa/push-alert/user-story.md`
- **Mobile Brief**: `docs/wowa/push-alert/mobile-brief.md`
- **Design Spec**: `docs/wowa/push-alert/mobile-design-spec.md`
- **Mobile Catalog**: `docs/wowa/mobile-catalog.md`
- **Flutter Best Practices**: `.claude/guide/mobile/flutter_best_practices.md`
- **GetX Best Practices**: `.claude/guide/mobile/getx_best_practices.md`
- **Directory Structure**: `.claude/guide/mobile/directory_structure.md`
- **Design System**: `.claude/guide/mobile/design_system.md`
- **Error Handling**: `.claude/guide/mobile/error_handling.md`
- **Performance**: `.claude/guide/mobile/performance.md`

---

## Firebase 프로젝트 설정 체크리스트

1. [ ] Firebase Console에서 프로젝트 생성 또는 선택
2. [ ] iOS 앱 추가 → GoogleService-Info.plist 다운로드 및 배치
3. [ ] Android 앱 추가 → google-services.json 다운로드 및 배치
4. [ ] iOS Info.plist에 권한 메시지 추가
5. [ ] iOS Xcode에서 Push Notifications Capability 활성화
6. [ ] Android build.gradle에 google-services 플러그인 추가
7. [ ] flutter clean && flutter pub get 실행
8. [ ] flutter run 성공 확인

---

## 완료 조건

- [ ] 모든 작업 체크리스트 완료
- [ ] Group 1 작업 완료 (Server API 비의존)
- [ ] Group 2 작업 완료 (Server API 완료 후)
- [ ] firebase_messaging 동작 확인 (포그라운드, 백그라운드, 종료 상태)
- [ ] 알림 목록 UI 완성 (상태별 렌더링, 무한 스크롤, 읽음 처리)
- [ ] 코드 리뷰 완료 (CTO)
- [ ] flutter analyze 통과 (경고 없음)
- [ ] 실제 디바이스에서 테스트 (iOS, Android)
