# Push Notification SDK

FCM(Firebase Cloud Messaging) 기반 푸시 알림 패키지.
Firebase 초기화, 권한 요청, 토큰 관리, 알림 수신 처리를 제공합니다.

## 아키텍처

```
packages/push/          ← Firebase SDK 래퍼 (이 패키지)
  PushService           - FCM 초기화, 토큰, 리스너
  PushNotification      - RemoteMessage → DTO 변환
  PushHandlerCallback   - 콜백 타입 정의

packages/api/           ← 서버 통신
  PushApiClient         - 디바이스 등록, 알림 CRUD
  NotificationModel     - 알림 Freezed 모델
  DeviceTokenRequest    - 토큰 등록 요청 모델

apps/wowa/              ← 앱 레벨 통합
  main.dart             - SDK 초기화 + 콜백 주입 + 토큰 자동등록
  NotificationController - 알림 목록, 읽음 처리, 딥링크
  NotificationView      - 알림 UI (SketchCard 기반)
  NotificationBinding   - DI 바인딩
```

### 의존성 방향

```
core ← push (Firebase, GetxService)
core ← api  (Dio, Freezed)
push + api ← wowa (앱에서 조합)
```

> push 패키지는 api 패키지를 모릅니다. 서버 통신은 앱(wowa)에서 연결합니다.

## 사전 준비 (Firebase 설정)

### Android

1. [Firebase Console](https://console.firebase.google.com)에서 Android 앱 등록
2. `google-services.json` 다운로드
3. `apps/wowa/android/app/` 에 배치

```
apps/wowa/android/app/google-services.json
```

### iOS

1. Firebase Console에서 iOS 앱 등록
2. `GoogleService-Info.plist` 다운로드
3. Xcode에서 Runner 타겟에 추가

```
apps/wowa/ios/Runner/GoogleService-Info.plist
```

> Firebase 파일 없이 빌드하면 런타임에서 `Firebase.initializeApp()` 실패합니다.

## 설치

### 1. pubspec.yaml에 의존성 추가

```yaml
# apps/wowa/pubspec.yaml
dependencies:
  push:
    path: ../../packages/push
  api:
    path: ../../packages/api
```

### 2. Bootstrap

```bash
melos bootstrap
```

## 연동 가이드

### Step 1: main.dart — SDK 초기화

앱 시작 시 PushService를 초기화하고, 콜백을 주입합니다.

```dart
import 'dart:io';
import 'package:api/api.dart';
import 'package:get/get.dart';
import 'package:push/push.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dio 초기화 (생략)

  // 1. PushApiClient 전역 등록 (토큰 자동등록에 필요)
  Get.put(PushApiClient());

  // 2. PushService 초기화
  final pushService = Get.put(PushService(), permanent: true);
  await pushService.initialize();

  // 3. 포그라운드 알림 → 인앱 스낵바
  pushService.onForegroundMessage = (notification) {
    Get.snackbar(
      notification.title.isNotEmpty ? notification.title : '새 알림',
      notification.body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      onTap: (_) {
        final screen = notification.data['screen'] as String?;
        if (screen != null && screen.isNotEmpty) {
          Get.toNamed('/$screen', arguments: notification.data);
        }
      },
    );
  };

  // 4. 백그라운드/종료 상태 알림 탭 → 딥링크
  void handleDeepLink(PushNotification notification) {
    final screen = notification.data['screen'] as String?;
    if (screen != null && screen.isNotEmpty) {
      Get.toNamed('/$screen', arguments: notification.data);
    }
  }
  pushService.onBackgroundMessageOpened = handleDeepLink;
  pushService.onTerminatedMessageOpened = handleDeepLink;

  // 5. 토큰 변경 → 서버 자동등록
  final pushApiClient = Get.find<PushApiClient>();
  ever(pushService.deviceToken, (String? token) {
    if (token != null && token.isNotEmpty) {
      pushApiClient.registerDevice(DeviceTokenRequest(
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      ));
    }
  });

  runApp(const MyApp());
}
```

**주의**: `PushApiClient`는 `main.dart`에서 전역 등록(`Get.put`)해야 합니다.
`ever()` 리스너가 PushService 초기화 직후 토큰을 받을 수 있기 때문입니다.

### Step 2: NotificationBinding — DI 등록

```dart
// bindings/notification_binding.dart
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // PushApiClient는 main.dart에서 전역 등록됨
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
```

### Step 3: 라우트 등록

```dart
// routes/app_pages.dart
GetPage(
  name: Routes.NOTIFICATIONS,
  page: () => const NotificationView(),
  binding: NotificationBinding(),
  transition: Transition.rightToLeft,
),
```

### Step 4: NotificationController — 비즈니스 로직

주요 메서드:

| 메서드 | 역할 |
|--------|------|
| `fetchNotifications()` | 알림 목록 조회 (페이지네이션) |
| `loadMore()` | 무한 스크롤 다음 페이지 |
| `fetchUnreadCount()` | 읽지 않은 개수 조회 |
| `handleNotificationTap()` | 읽음 처리 (낙관적 업데이트) + 딥링크 |
| `refreshNotifications()` | Pull-to-refresh |

**낙관적 업데이트 패턴** (`handleNotificationTap`):

```
1. 이미 읽은 알림 → 딥링크만 처리
2. 원본 보존 → UI 즉시 변경 (isRead: true, unreadCount--)
3. API 호출 (markAsRead)
4. 실패 시 원본으로 롤백
5. 딥링크 처리
```

### Step 5: NotificationView — UI 구현

4가지 상태를 `Obx`로 분기:

| 상태 | 조건 | UI |
|------|------|-----|
| 로딩 | `isLoading && notifications.isEmpty` | SketchProgressBar |
| 에러 | `errorMessage.isNotEmpty` | 에러 + 재시도 버튼 |
| 빈 목록 | `notifications.isEmpty` | 빈 상태 안내 |
| 목록 | 기본 | ListView + SketchCard |

## API 레퍼런스

### PushService (packages/push)

```dart
class PushService extends GetxService {
  // 상태
  final Rxn<String> deviceToken;       // 현재 FCM 토큰
  final RxBool isInitialized;          // 초기화 완료 여부

  // 콜백 (앱에서 주입)
  PushHandlerCallback? onForegroundMessage;
  PushHandlerCallback? onBackgroundMessageOpened;
  PushHandlerCallback? onTerminatedMessageOpened;

  // 메서드
  Future<void> initialize();           // Firebase 초기화 + 권한 + 토큰 + 리스너
  Future<void> refreshToken();         // 토큰 수동 갱신
}
```

### PushNotification (packages/push)

```dart
class PushNotification {
  final String? notificationId;        // 서버 알림 ID
  final String title;                  // 제목 (non-nullable)
  final String body;                   // 본문 (non-nullable)
  final String? imageUrl;              // 이미지 URL
  final Map<String, dynamic> data;     // 커스텀 데이터 (non-nullable)
  final DateTime receivedAt;           // 수신 시각

  factory PushNotification.fromRemoteMessage(RemoteMessage message);
}
```

### PushApiClient (packages/api)

```dart
class PushApiClient {
  Future<void> registerDevice(DeviceTokenRequest request);
  Future<NotificationListResponse> getMyNotifications({
    int limit = 20, int offset = 0, bool? unreadOnly,
  });
  Future<UnreadCountResponse> getUnreadCount();
  Future<void> markAsRead(int notificationId);
}
```

### 서버 API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/api/push/devices` | 디바이스 토큰 등록 (Upsert) |
| GET | `/api/push/notifications/me` | 내 알림 목록 조회 |
| GET | `/api/push/notifications/unread-count` | 읽지 않은 개수 |
| PATCH | `/api/push/notifications/:id/read` | 읽음 처리 |

## 딥링크 규칙

서버에서 알림 발송 시 `data.screen` 필드로 이동할 화면을 지정합니다:

```json
{
  "title": "새 메시지",
  "body": "홍길동님이 메시지를 보냈습니다",
  "data": {
    "screen": "chat",
    "chatId": "123"
  }
}
```

앱에서 `Get.toNamed('/chat', arguments: data)` 로 변환됩니다.

## 알림 수신 플로우

```
[앱 상태별 처리]

포그라운드 (앱 사용 중)
  → FirebaseMessaging.onMessage
  → PushService._handleForegroundMessage
  → onForegroundMessage 콜백
  → Get.snackbar (인앱 배너)

백그라운드 (앱 전환됨)
  → 시스템 알림 표시
  → 사용자 탭
  → FirebaseMessaging.onMessageOpenedApp
  → PushService._handleBackgroundMessageOpened
  → onBackgroundMessageOpened 콜백
  → Get.toNamed (딥링크)

종료 상태 (앱 꺼짐)
  → 시스템 알림 표시
  → 사용자 탭 → 앱 실행
  → FirebaseMessaging.getInitialMessage
  → PushService._handleTerminatedMessageOpened
  → onTerminatedMessageOpened 콜백
  → Get.toNamed (딥링크)
```

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `Firebase.initializeApp()` 실패 | Firebase 설정 파일 누락 | `google-services.json` / `GoogleService-Info.plist` 배치 |
| 토큰이 null | Firebase 초기화 전 호출 | `await pushService.initialize()` 후 토큰 확인 |
| 포그라운드 알림 안 뜸 | 콜백 미등록 | `pushService.onForegroundMessage = ...` 확인 |
| 서버에 토큰 미등록 | PushApiClient 미등록 | `main.dart`에서 `Get.put(PushApiClient())` 확인 |
| `Get.find<PushApiClient>()` 실패 | 전역 등록 누락 | `Get.put()`으로 main.dart에서 등록 (lazyPut 아님) |
| iOS 알림 안 옴 | 권한 미허용 | 설정 > 알림 > 앱 허용 확인 |
| 백그라운드 탭 후 화면 안 열림 | `data.screen` 누락 | 서버 발송 시 data 필드에 screen 포함 확인 |
