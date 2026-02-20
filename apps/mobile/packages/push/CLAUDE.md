# push — FCM 푸시 알림 SDK

## 개요

- **역할**: Firebase Cloud Messaging 기반 푸시 알림 수신, 디바이스 토큰 관리, 알림 목록 조회
- **사용처**: wowa 앱 (앱 독립적 설계로 다른 앱에서도 재사용 가능)
- **독립성**: `core`에만 의존. Firebase 초기화는 앱 책임, SDK는 FCM 기능만 담당

## 연동 가이드

```dart
// 1. main.dart에서 Firebase 초기화 후 PushService 등록
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
Get.put(PushApiClient());
final pushService = Get.put(PushService(), permanent: true);

// 2. 디바이스 토큰 변경 감지 (서버 등록)
ever(pushService.deviceToken, (_) async {
  await pushService.registerDeviceTokenToServer();
});

// 3. PushService 초기화 (권한 요청 + 토큰 획득 + 리스너 등록)
await pushService.initialize();

// 4. 포그라운드 알림 핸들러 주입
pushService.onForegroundMessage = (notification) {
  Get.snackbar(notification.title, notification.body);
};
```

## Public API

| 클래스/함수 | 역할 | 사용 예 |
|------------|------|---------|
| `PushService` | FCM 초기화, 토큰 관리, 알림 처리 (GetxService) | `Get.put(PushService())` |
| `PushApiClient` | 서버 API 통신 (토큰 등록, 알림 조회/읽음 처리) | `Get.put(PushApiClient())` |
| `PushNotification` | 알림 데이터 모델 (title, body, data) | 핸들러 콜백 파라미터 |
| `PushHandlerCallback` | 알림 핸들러 타입 정의 | `onForegroundMessage` |
| `DeviceTokenRequest` | 토큰 등록 요청 모델 (Freezed) | `PushApiClient.registerDevice()` |
| `NotificationModel` | 알림 모델 (Freezed) | `PushApiClient.getMyNotifications()` |
| `NotificationListResponse` | 알림 목록 응답 (Freezed) | API 응답 |
| `UnreadCountResponse` | 읽지 않은 알림 수 (Freezed) | API 응답 |

## Configuration

별도 설정 객체 없음. 앱에서 핸들러 콜백을 직접 주입:

- `onForegroundMessage` — 포그라운드 알림 수신 시
- `onBackgroundMessageOpened` — 백그라운드 알림 탭 시
- `onTerminatedMessageOpened` — 종료 상태 알림 탭 시

## Architecture

```
lib/
├── push.dart                   # 배럴 파일
└── src/
    ├── push_service.dart       # FCM 초기화, 권한, 토큰, 리스너 (GetxService)
    ├── push_api_client.dart    # 서버 API (토큰 등록/비활성화, 알림 조회/읽음)
    ├── push_notification.dart  # 알림 DTO (RemoteMessage -> PushNotification)
    ├── push_handler_callback.dart  # 핸들러 타입 정의
    └── models/                 # Freezed 모델 (DeviceTokenRequest, NotificationModel 등)
```

- `PushService`는 `GetxService` 상속 — 앱 생명주기 동안 싱글턴 유지
- iOS APNS 토큰 대기 로직 내장 (최대 5초 재시도)
- 디바이스 ID: iOS `identifierForVendor`, Android `Build.ID`
- `deviceToken`은 `Rxn<String>` — `ever()`로 변경 감지 가능

## 확장/수정 시

1. 서버 API 엔드포인트 추가: `push_api_client.dart`에 메서드 추가
2. 모델 수정: Freezed 파일 수정 후 `melos generate` 실행
3. 알림 처리 로직 변경: `PushService`의 `_handle*` 메서드 수정

## 의존성

| 패키지 | 역할 |
|--------|------|
| `core` | Logger |
| `firebase_messaging` | FCM 연동 |
| `device_info_plus` | 디바이스 고유 ID |
| `dio` | HTTP 클라이언트 |
| `freezed_annotation` / `json_annotation` | 데이터 모델 |
