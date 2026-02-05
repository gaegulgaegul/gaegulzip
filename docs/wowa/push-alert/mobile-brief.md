# 기술 아키텍처 설계: 푸시 알림 (모바일)

## 개요

푸시 알림 기능의 모바일 측 설계입니다. **재사용 가능한 Push SDK 패키지**(`packages/push/`)를 구축하고, 서버 API 연동 모델을 `packages/api/`에 추가하며, `apps/wowa/`에서 알림 목록 UI와 딥링크 처리를 구현합니다.

**핵심 설계 원칙**:
- `packages/push/`는 앱 독립적(app-agnostic) — Firebase FCM 초기화, 토큰 관리, 포그라운드/백그라운드 알림 처리만 담당
- `packages/api/`는 서버 API 계약(Contract) 구현 — 디바이스 등록, 알림 목록, 읽음 처리 API
- `apps/wowa/`는 UI + 비즈니스 로직 — GetX 컨트롤러, 알림 목록 화면, 딥링크, 읽지 않은 배지

## 패키지 구조 설계

### 1. packages/push/ (신규 생성)

**목적**: 재사용 가능한 FCM Push Notification SDK

**의존성**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../core
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.5
  get: ^4.6.6  # core에서 이미 사용 중

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

**디렉토리 구조**:
```
packages/push/
├── lib/
│   ├── src/
│   │   ├── push_service.dart          # PushService (GetxService)
│   │   ├── push_notification.dart     # PushNotification 모델
│   │   └── push_handler_callback.dart # 알림 처리 콜백 타입
│   └── push.dart                      # Public exports
├── pubspec.yaml
└── README.md
```

#### 1-1. PushService (GetxService)

**파일**: `packages/push/lib/src/push_service.dart`

```dart
/// FCM 푸시 알림 서비스 (앱 독립적 SDK)
class PushService extends GetxService {
  /// Firebase Messaging 인스턴스
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 현재 디바이스 토큰 (반응형)
  final Rxn<String> deviceToken = Rxn<String>();

  /// 초기화 완료 여부
  final isInitialized = false.obs;

  /// 포그라운드 알림 핸들러 (앱에서 주입)
  PushHandlerCallback? onForegroundMessage;

  /// 백그라운드 알림 탭 핸들러 (앱에서 주입)
  PushHandlerCallback? onBackgroundMessageOpened;

  /// 종료 상태 알림 탭 핸들러 (앱에서 주입)
  PushHandlerCallback? onTerminatedMessageOpened;

  /// Firebase 초기화 및 권한 요청
  Future<void> initialize() async {
    if (isInitialized.value) return;

    try {
      // 1. Firebase 초기화
      await Firebase.initializeApp();

      // 2. 권한 요청
      await _requestPermission();

      // 3. 디바이스 토큰 획득
      await _getDeviceToken();

      // 4. 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen((newToken) {
        deviceToken.value = newToken;
        Logger.info('FCM token refreshed: $newToken');
      });

      // 5. 포그라운드 메시지 리스너
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. 백그라운드 메시지 탭 리스너
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageOpened);

      // 7. 종료 상태 메시지 확인
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleTerminatedMessageOpened(initialMessage);
      }

      isInitialized.value = true;
      Logger.info('PushService initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize PushService', error: e);
      rethrow;
    }
  }

  /// 권한 요청
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      Logger.warn('User denied push notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info('Push notification permission granted');
    }
  }

  /// 디바이스 토큰 획득
  Future<void> _getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        deviceToken.value = token;
        Logger.info('FCM device token obtained: $token');
      }
    } catch (e) {
      Logger.error('Failed to get FCM token', error: e);
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    Logger.debug('Foreground message received: ${message.messageId}');

    final notification = PushNotification.fromRemoteMessage(message);

    if (onForegroundMessage != null) {
      onForegroundMessage!(notification);
    } else {
      Logger.warn('No foreground message handler registered');
    }
  }

  /// 백그라운드 메시지 탭 처리
  void _handleBackgroundMessageOpened(RemoteMessage message) {
    Logger.debug('Background message opened: ${message.messageId}');

    final notification = PushNotification.fromRemoteMessage(message);

    if (onBackgroundMessageOpened != null) {
      onBackgroundMessageOpened!(notification);
    } else {
      Logger.warn('No background message handler registered');
    }
  }

  /// 종료 상태 메시지 탭 처리
  void _handleTerminatedMessageOpened(RemoteMessage message) {
    Logger.debug('Terminated message opened: ${message.messageId}');

    final notification = PushNotification.fromRemoteMessage(message);

    if (onTerminatedMessageOpened != null) {
      onTerminatedMessageOpened!(notification);
    } else {
      Logger.warn('No terminated message handler registered');
    }
  }

  /// 토큰 수동 갱신
  Future<void> refreshToken() async {
    await _getDeviceToken();
  }
}
```

**설계 근거**:
- **GetxService 상속**: 앱 생명주기 동안 단일 인스턴스 유지
- **콜백 주입 패턴**: 앱별 알림 처리 로직을 외부에서 주입 (앱 독립성 유지)
- **토큰 자동 갱신**: `onTokenRefresh` 스트림으로 토큰 변경 감지
- **3가지 알림 상태 처리**: 포그라운드, 백그라운드, 종료 상태

#### 1-2. PushNotification 모델

**파일**: `packages/push/lib/src/push_notification.dart`

```dart
/// 푸시 알림 데이터 모델 (앱 독립적)
class PushNotification {
  /// 알림 ID (서버에서 발급, optional)
  final String? notificationId;

  /// 제목
  final String title;

  /// 본문
  final String body;

  /// 이미지 URL
  final String? imageUrl;

  /// 커스텀 데이터 (딥링크 정보 등)
  final Map<String, dynamic> data;

  /// 수신 시각
  final DateTime receivedAt;

  PushNotification({
    this.notificationId,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data = const {},
    required this.receivedAt,
  });

  /// RemoteMessage에서 변환
  factory PushNotification.fromRemoteMessage(RemoteMessage message) {
    return PushNotification(
      notificationId: message.data['notificationId']?.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ??
                message.notification?.apple?.imageUrl,
      data: message.data,
      receivedAt: DateTime.now(),
    );
  }
}
```

**설계 근거**:
- **앱 독립적 모델**: 서버 API 모델(`NotificationModel`)과 분리
- **RemoteMessage 변환**: FCM 메시지를 간단한 DTO로 변환
- **data 필드**: 딥링크, 앱별 메타데이터 포함

#### 1-3. 콜백 타입 정의

**파일**: `packages/push/lib/src/push_handler_callback.dart`

```dart
/// 푸시 알림 처리 콜백 타입
typedef PushHandlerCallback = void Function(PushNotification notification);
```

#### 1-4. Public Exports

**파일**: `packages/push/lib/push.dart`

```dart
library push;

export 'src/push_service.dart';
export 'src/push_notification.dart';
export 'src/push_handler_callback.dart';
```

---

### 2. packages/api/ (기존 패키지 확장)

**목적**: 푸시 알림 서버 API 연동

**추가 의존성**: 없음 (Freezed, Dio 이미 사용 중)

#### 2-1. API 모델 (Freezed)

**파일**: `packages/api/lib/src/models/push/device_token_request.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_token_request.freezed.dart';
part 'device_token_request.g.dart';

/// 디바이스 토큰 등록 요청
@freezed
class DeviceTokenRequest with _$DeviceTokenRequest {
  factory DeviceTokenRequest({
    /// FCM 디바이스 토큰
    required String token,
    /// 플랫폼 (ios, android, web)
    required String platform,
    /// 디바이스 고유 ID (선택)
    String? deviceId,
  }) = _DeviceTokenRequest;

  factory DeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenRequestFromJson(json);
}
```

**파일**: `packages/api/lib/src/models/push/notification_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// 알림 수신 기록 모델 (서버 API 응답)
@freezed
class NotificationModel with _$NotificationModel {
  factory NotificationModel({
    /// 알림 ID
    required int id,
    /// 제목
    required String title,
    /// 본문
    required String body,
    /// 이미지 URL
    String? imageUrl,
    /// 커스텀 데이터 (JSON)
    @Default({}) Map<String, dynamic> data,
    /// 읽음 상태
    required bool isRead,
    /// 읽은 시각 (ISO-8601)
    String? readAt,
    /// 수신 시각 (ISO-8601)
    required String receivedAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
```

**파일**: `packages/api/lib/src/models/push/notification_list_response.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'notification_model.dart';

part 'notification_list_response.freezed.dart';
part 'notification_list_response.g.dart';

/// 알림 목록 조회 응답
@freezed
class NotificationListResponse with _$NotificationListResponse {
  factory NotificationListResponse({
    /// 알림 목록
    required List<NotificationModel> notifications,
    /// 총 개수
    required int total,
  }) = _NotificationListResponse;

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);
}
```

**파일**: `packages/api/lib/src/models/push/unread_count_response.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unread_count_response.freezed.dart';
part 'unread_count_response.g.dart';

/// 읽지 않은 알림 개수 응답
@freezed
class UnreadCountResponse with _$UnreadCountResponse {
  factory UnreadCountResponse({
    /// 읽지 않은 알림 개수
    required int unreadCount,
  }) = _UnreadCountResponse;

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
}
```

#### 2-2. API 클라이언트

**파일**: `packages/api/lib/src/clients/push_api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/push/device_token_request.dart';
import '../models/push/notification_list_response.dart';
import '../models/push/unread_count_response.dart';

/// 푸시 알림 API 클라이언트
class PushApiClient {
  final Dio _dio = Get.find<Dio>();

  /// 디바이스 토큰 등록
  Future<void> registerDevice(DeviceTokenRequest request) async {
    await _dio.post(
      '/push/devices',
      data: request.toJson(),
    );
  }

  /// 내 알림 목록 조회
  Future<NotificationListResponse> getMyNotifications({
    int limit = 20,
    int offset = 0,
    bool? unreadOnly,
  }) async {
    final response = await _dio.get(
      '/push/notifications/me',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (unreadOnly != null) 'unreadOnly': unreadOnly,
      },
    );
    return NotificationListResponse.fromJson(response.data);
  }

  /// 읽지 않은 알림 개수 조회
  Future<UnreadCountResponse> getUnreadCount() async {
    final response = await _dio.get('/push/notifications/unread-count');
    return UnreadCountResponse.fromJson(response.data);
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    await _dio.patch('/push/notifications/$notificationId/read');
  }
}
```

**설계 근거**:
- **Dio 의존성**: `Get.find<Dio>()`로 앱의 Dio 인스턴스 재사용
- **인증 헤더**: Dio Interceptor에서 자동 추가 (기존 구조 유지)
- **에러 처리**: Dio Interceptor에서 전역 처리

#### 2-3. Exports 업데이트

**파일**: `packages/api/lib/api.dart` (기존 파일 수정)

```dart
library api;

// ... 기존 exports

// Push models
export 'src/models/push/device_token_request.dart';
export 'src/models/push/notification_model.dart';
export 'src/models/push/notification_list_response.dart';
export 'src/models/push/unread_count_response.dart';

// Push client
export 'src/clients/push_api_client.dart';
```

#### 2-4. 코드 생성

```bash
cd /Users/lms/dev/repository/feature-push-alert
melos generate
```

---

### 3. apps/wowa/ (앱 모듈 구현)

**목적**: 알림 목록 UI, 비즈니스 로직, 딥링크 처리

**추가 의존성**:
```yaml
dependencies:
  # ... 기존 의존성
  push:
    path: ../../packages/push
```

#### 3-1. NotificationController (GetX)

**파일**: `apps/wowa/lib/app/modules/notification/controllers/notification_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:push/push.dart';
import 'package:core/core.dart';

/// 알림 목록 화면 컨트롤러
class NotificationController extends GetxController {
  /// 알림 목록
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  /// 읽지 않은 알림 개수
  final unreadCount = 0.obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// 에러 메시지
  final errorMessage = ''.obs;

  /// 페이지네이션 상태
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _currentOffset = 0;
  final int _limit = 20;

  /// 의존성
  late final PushApiClient _apiClient;

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.find<PushApiClient>();

    // 초기 데이터 로드
    fetchNotifications();

    // 읽지 않은 개수 로드
    fetchUnreadCount();
  }

  /// 알림 목록 조회 (초기 로딩 또는 Pull-to-refresh)
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentOffset = 0;
      hasMore.value = true;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiClient.getMyNotifications(
        limit: _limit,
        offset: 0,
      );

      if (refresh) {
        notifications.value = response.notifications;
      } else {
        notifications.assignAll(response.notifications);
      }

      _currentOffset = _limit;
      hasMore.value = response.notifications.length >= _limit;
    } on NetworkException catch (e) {
      errorMessage.value = '네트워크 연결을 확인해 주세요';
      Logger.error('Failed to fetch notifications', error: e);
    } catch (e) {
      errorMessage.value = '알림을 불러올 수 없습니다';
      Logger.error('Unexpected error fetching notifications', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 알림 목록 더 불러오기 (무한 스크롤)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      final response = await _apiClient.getMyNotifications(
        limit: _limit,
        offset: _currentOffset,
      );

      notifications.addAll(response.notifications);
      _currentOffset += _limit;
      hasMore.value = response.notifications.length >= _limit;
    } catch (e) {
      Logger.error('Failed to load more notifications', error: e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 읽지 않은 알림 개수 조회
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.getUnreadCount();
      unreadCount.value = response.unreadCount;
    } catch (e) {
      Logger.error('Failed to fetch unread count', error: e);
    }
  }

  /// 알림 탭 처리 (읽음 처리 + 딥링크 이동)
  Future<void> handleNotificationTap(NotificationModel notification) async {
    // 1. 이미 읽은 알림은 스킵
    if (!notification.isRead) {
      // 2. 읽음 처리 API 호출 (낙관적 업데이트)
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(isRead: true);
        unreadCount.value = (unreadCount.value - 1).clamp(0, 9999);
      }

      try {
        await _apiClient.markAsRead(notification.id);
      } catch (e) {
        Logger.error('Failed to mark notification as read', error: e);
        // 실패 시 롤백
        if (index != -1) {
          notifications[index] = notification;
          unreadCount.value++;
        }
      }
    }

    // 3. 딥링크 처리
    _handleDeepLink(notification.data);
  }

  /// 딥링크 처리
  void _handleDeepLink(Map<String, dynamic> data) {
    try {
      final screen = data['screen'] as String?;

      if (screen == null || screen.isEmpty) {
        // 딥링크 데이터 없음 → 알림 목록 화면 유지
        Logger.warn('No deep link data in notification');
        return;
      }

      // 라우트 이동
      Get.toNamed('/$screen', arguments: data);
    } catch (e) {
      Logger.error('Failed to handle deep link', error: e);
      Get.snackbar(
        '알림',
        '페이지를 찾을 수 없습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 재시도 (에러 상태에서)
  Future<void> retryLoadNotifications() async {
    await fetchNotifications();
  }

  /// Pull-to-refresh
  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }
}
```

**설계 근거**:
- **낙관적 업데이트**: 읽음 처리 시 UI 즉시 업데이트 후 API 호출 (UX 개선)
- **무한 스크롤**: `loadMore()` 메서드로 페이지네이션 지원
- **에러 처리**: `NetworkException` 분기 처리, 일반 에러는 로그만 기록
- **딥링크**: `data['screen']` 기반 GetX 네비게이션

#### 3-2. NotificationView (UI)

**파일**: `apps/wowa/lib/app/modules/notification/views/notification_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../controllers/notification_controller.dart';

/// 알림 목록 화면
class NotificationView extends GetView<NotificationController> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: SketchDesignTokens.white,
      elevation: 0,
      leading: SketchIconButton(
        icon: Icons.arrow_back_ios,
        onPressed: () => Get.back(),
      ),
      title: const Text(
        '알림',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        SketchIconButton(
          icon: Icons.settings_outlined,
          onPressed: () {
            // 향후 알림 설정 화면 이동
          },
          tooltip: '알림 설정',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      color: SketchDesignTokens.accentPrimary,
      onRefresh: controller.refreshNotifications,
      child: Obx(() {
        // 로딩 상태
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return Center(
            child: SketchProgressBar(
              style: SketchProgressBarStyle.circular,
              value: null,
            ),
          );
        }

        // 에러 상태
        if (controller.errorMessage.value.isNotEmpty &&
            controller.notifications.isEmpty) {
          return _buildErrorState();
        }

        // 빈 목록
        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        // 알림 목록
        return _buildNotificationList();
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: SketchDesignTokens.base500,
          ),
          const SizedBox(height: 16),
          const Text(
            '알림을 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: SketchDesignTokens.base900,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            controller.errorMessage.value,
            style: const TextStyle(
              fontSize: 14,
              color: SketchDesignTokens.base500,
            ),
          )),
          const SizedBox(height: 24),
          SketchButton(
            text: '다시 시도',
            style: SketchButtonStyle.primary,
            onPressed: controller.retryLoadNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: SketchDesignTokens.base300,
          ),
          SizedBox(height: 16),
          Text(
            '알림이 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: SketchDesignTokens.base700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '새로운 알림이 도착하면 여기에 표시됩니다',
            style: TextStyle(
              fontSize: 14,
              color: SketchDesignTokens.base500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.notifications.length +
                 (controller.hasMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        // 페이징 로더
        if (index == controller.notifications.length) {
          return _buildPagingLoader();
        }

        final notification = controller.notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SketchCard(
        elevation: 1,
        borderColor: notification.isRead
            ? SketchDesignTokens.base300
            : SketchDesignTokens.accentPrimary,
        strokeWidth: notification.isRead
            ? SketchDesignTokens.strokeStandard
            : SketchDesignTokens.strokeBold,
        onTap: () => controller.handleNotificationTap(notification),
        body: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 배지
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: notification.isRead
                                ? SketchDesignTokens.base700
                                : SketchDesignTokens.base900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 8),
                        SketchChip(
                          label: 'NEW',
                          selected: true,
                          activeColor: SketchDesignTokens.accentPrimary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 본문
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: SketchDesignTokens.base700,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 시간
                  Text(
                    _formatRelativeTime(notification.receivedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: SketchDesignTokens.base500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: SketchDesignTokens.base500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagingLoader() {
    // 리스트 끝에서 3개 항목 전에 다음 페이지 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoadingMore.value) {
        controller.loadMore();
      }
    });

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              SketchDesignTokens.accentPrimary,
            ),
          ),
        ),
      ),
    );
  }

  /// 상대 시간 포맷팅
  String _formatRelativeTime(String isoString) {
    try {
      final receivedAt = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(receivedAt);

      if (difference.inMinutes < 1) {
        return '방금 전';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}시간 전';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 전';
      } else {
        return '${receivedAt.month}월 ${receivedAt.day}일';
      }
    } catch (e) {
      return '';
    }
  }
}
```

**설계 근거**:
- **const 최적화**: 정적 위젯은 `const` 사용
- **Obx 최소화**: 상태별 렌더링 분기와 개별 카드만 Obx
- **무한 스크롤**: `ListView.builder`의 마지막 항목에서 `loadMore()` 호출
- **상대 시간**: "방금 전", "5분 전" 등 사용자 친화적 표시

#### 3-3. NotificationBinding

**파일**: `apps/wowa/lib/app/modules/notification/bindings/notification_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:api/api.dart';
import '../controllers/notification_controller.dart';

/// 알림 모듈 바인딩
class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // PushApiClient 지연 로딩
    Get.lazyPut<PushApiClient>(() => PushApiClient());

    // NotificationController 지연 로딩
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
```

#### 3-4. 라우팅 업데이트

**파일**: `apps/wowa/lib/app/routes/app_routes.dart` (기존 파일 수정)

```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const SETTINGS = '/settings';

  // ✅ 신규
  static const NOTIFICATIONS = '/notifications';
}
```

**파일**: `apps/wowa/lib/app/routes/app_pages.dart` (기존 파일 수정)

```dart
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // ... 기존 라우트

    // ✅ 신규 알림 목록
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

#### 3-5. Firebase 초기화 (main.dart)

**파일**: `apps/wowa/lib/main.dart` (기존 파일 수정)

```dart
import 'package:push/push.dart';
import 'package:api/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... 기존 초기화 (Dio 등)

  // ✅ PushService 초기화 및 전역 등록
  final pushService = PushService();
  await pushService.initialize();
  Get.put<PushService>(pushService, permanent: true);

  // ✅ 포그라운드 알림 핸들러 등록
  pushService.onForegroundMessage = (notification) {
    // 인앱 알림 배너 표시 (간단한 스낵바)
    Get.snackbar(
      notification.title,
      notification.body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      onTap: (_) {
        // 탭 시 딥링크 처리
        final screen = notification.data['screen'] as String?;
        if (screen != null && screen.isNotEmpty) {
          Get.toNamed('/$screen', arguments: notification.data);
        }
      },
    );
  };

  // ✅ 백그라운드/종료 상태 알림 탭 핸들러
  pushService.onBackgroundMessageOpened = (notification) {
    final screen = notification.data['screen'] as String?;
    if (screen != null && screen.isNotEmpty) {
      Get.toNamed('/$screen', arguments: notification.data);
    }
  };

  pushService.onTerminatedMessageOpened = (notification) {
    final screen = notification.data['screen'] as String?;
    if (screen != null && screen.isNotEmpty) {
      Get.toNamed('/$screen', arguments: notification.data);
    }
  };

  // ✅ 디바이스 토큰 등록 (토큰 획득 후)
  ever(pushService.deviceToken, (token) async {
    if (token != null) {
      try {
        final apiClient = PushApiClient();
        final platform = GetPlatform.isIOS ? 'ios' : 'android';

        await apiClient.registerDevice(
          DeviceTokenRequest(
            token: token,
            platform: platform,
          ),
        );

        Logger.info('Device token registered successfully');
      } catch (e) {
        Logger.error('Failed to register device token', error: e);
      }
    }
  });

  runApp(const MyApp());
}
```

**설계 근거**:
- **PushService 전역 등록**: `Get.put(permanent: true)`로 앱 생명주기 동안 유지
- **콜백 주입**: 앱별 알림 처리 로직을 main.dart에서 주입
- **토큰 자동 등록**: `ever()`로 토큰 변경 감지 시 서버에 자동 등록

#### 3-6. 읽지 않은 알림 배지 (선택 사항)

**파일**: `apps/wowa/lib/app/widgets/unread_badge_icon.dart` (신규 생성)

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../modules/notification/controllers/notification_controller.dart';

/// 읽지 않은 알림 배지 아이콘 (네비게이션 바에서 사용)
class UnreadBadgeIcon extends StatelessWidget {
  const UnreadBadgeIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NotificationController가 등록되어 있으면 배지 표시
    if (!Get.isRegistered<NotificationController>()) {
      return SketchIconButton(
        icon: Icons.notifications_outlined,
        onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
      );
    }

    final controller = Get.find<NotificationController>();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SketchIconButton(
          icon: Icons.notifications_outlined,
          onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
        ),
        Obx(() {
          if (controller.unreadCount.value == 0) {
            return const SizedBox.shrink();
          }

          return Positioned(
            right: 0,
            top: 0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: SketchDesignTokens.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  controller.unreadCount.value > 99
                      ? '99+'
                      : controller.unreadCount.value.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
```

**사용 예시** (홈 화면 AppBar):
```dart
AppBar(
  actions: [
    const UnreadBadgeIcon(),
  ],
)
```

---

## 에러 처리 전략

### Controller 에러 처리

```dart
try {
  // API 호출
} on NetworkException catch (e) {
  errorMessage.value = '네트워크 연결을 확인해 주세요';
  Logger.error('Network error', error: e);
} catch (e) {
  errorMessage.value = '알림을 불러올 수 없습니다';
  Logger.error('Unexpected error', error: e);
} finally {
  isLoading.value = false;
}
```

### View 에러 표시

- `errorMessage.value.isNotEmpty` 확인 후 에러 화면 렌더링
- 재시도 버튼 제공 (`controller.retryLoadNotifications()`)

### 디바이스 토큰 등록 실패

- 사용자에게 노출하지 않음 (로그만 기록)
- 토큰 갱신 시 자동 재시도

---

## 성능 최적화 전략

### const 생성자
```dart
const Text('알림')
const SizedBox(height: 16)
const Icon(Icons.notifications_none)
```

### Obx 범위 최소화
```dart
// ❌ 나쁜 예시: 전체 리스트를 Obx로 감쌈
Obx(() => ListView.builder(...))

// ✅ 좋은 예시: 상태별 분기만 Obx
Obx(() {
  if (controller.isLoading.value) return LoadingWidget();
  return ListView.builder(...);  // 리스트 자체는 반응형 아님
})
```

### ListView.builder 사용
- 화면에 보이는 항목만 렌더링
- 무한 스크롤 지원

### 낙관적 업데이트
- 읽음 처리 시 UI 즉시 업데이트 후 API 호출
- 실패 시 롤백

---

## 라우팅 설계

### Route Name
```dart
static const NOTIFICATIONS = '/notifications';
```

### Route Definition
```dart
GetPage(
  name: Routes.NOTIFICATIONS,
  page: () => const NotificationView(),
  binding: NotificationBinding(),
  transition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 300),
)
```

### Navigation
```dart
// 알림 목록 이동
Get.toNamed(Routes.NOTIFICATIONS);

// 딥링크 이동 (알림 데이터 기반)
Get.toNamed('/${data['screen']}', arguments: data);

// 뒤로가기
Get.back();
```

---

## 딥링크 처리

### 알림 데이터 구조 (서버 발송 시)
```json
{
  "title": "새로운 메시지",
  "body": "김철수님이 메시지를 보냈습니다",
  "data": {
    "screen": "chat",
    "chatId": "456",
    "userId": "789"
  }
}
```

### 처리 로직 (NotificationController)
```dart
void _handleDeepLink(Map<String, dynamic> data) {
  final screen = data['screen'] as String?;

  if (screen == null || screen.isEmpty) {
    Logger.warn('No deep link data');
    return;
  }

  Get.toNamed('/$screen', arguments: data);
}
```

### 에러 처리
- 잘못된 딥링크: 홈 화면 이동 + 스낵바 표시
- 앱 크래시 방지: try-catch로 감싸기

---

## 패키지 의존성 확인

### 모노레포 구조
```
core (foundation)
  ↑
  ├── push (FCM SDK, 앱 독립적)
  ├── api (HTTP, models)
  ├── design_system (UI)
  └── wowa (app)
```

### 필요한 패키지
- **core**: GetX, Logger, SecureStorageService (기존)
- **push**: firebase_core, firebase_messaging (신규)
- **api**: Dio, Freezed (기존)
- **wowa**: core, push, api, design_system (신규: push 추가)

---

## 작업 분배 계획 (CTO가 참조)

### Senior Developer 작업

1. **packages/push/ 패키지 생성**
   - `pubspec.yaml` 작성 (firebase_core, firebase_messaging 추가)
   - `PushService` 구현 (FCM 초기화, 토큰 관리, 알림 리스너)
   - `PushNotification` 모델 구현
   - `push.dart` exports 작성

2. **packages/api/ 확장**
   - Freezed 모델 4개 작성 (DeviceTokenRequest, NotificationModel, NotificationListResponse, UnreadCountResponse)
   - `PushApiClient` 구현 (4개 API 메서드)
   - `api.dart` exports 업데이트
   - `melos generate` 실행

3. **apps/wowa/ 모듈 구현**
   - `NotificationController` 구현 (상태 관리, API 연동, 딥링크)
   - `NotificationBinding` 구현 (DI)
   - 라우팅 업데이트 (app_routes.dart, app_pages.dart)

4. **main.dart 수정**
   - PushService 초기화 및 전역 등록
   - 알림 핸들러 등록 (포그라운드, 백그라운드, 종료 상태)
   - 디바이스 토큰 자동 등록 로직 추가

5. **Firebase 프로젝트 설정**
   - Firebase Console에서 iOS/Android 앱 등록
   - `google-services.json` (Android), `GoogleService-Info.plist` (iOS) 다운로드
   - 앱에 설정 파일 배치

### Junior Developer 작업

1. **NotificationView UI 구현**
   - AppBar, 상태별 렌더링 (로딩, 에러, 빈 목록, 알림 목록)
   - NotificationCard 위젯 (SketchCard 활용)
   - 페이징 로더 (무한 스크롤)
   - Pull-to-refresh

2. **UnreadBadgeIcon 위젯 구현**
   - 읽지 않은 알림 배지 표시
   - Stack + Obx 활용

3. **상대 시간 포맷팅 함수**
   - "방금 전", "5분 전" 등 사용자 친화적 표시

### 작업 의존성

```
Firebase 설정 → packages/push/ → packages/api/ → apps/wowa/ (Controller) → apps/wowa/ (View)
```

**예상 소요 시간**: Senior 4-5시간, Junior 2-3시간

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
- [ ] CLAUDE.md 표준 준수

---

## Firebase 프로젝트 설정 가이드

### 1. Firebase Console 설정

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. 프로젝트 생성 또는 기존 프로젝트 선택
3. iOS 앱 추가:
   - Bundle ID: `com.example.wowa` (실제 Bundle ID로 변경)
   - `GoogleService-Info.plist` 다운로드
   - `apps/wowa/ios/Runner/` 디렉토리에 배치
4. Android 앱 추가:
   - Package name: `com.example.wowa` (실제 Package name으로 변경)
   - `google-services.json` 다운로드
   - `apps/wowa/android/app/` 디렉토리에 배치

### 2. iOS 설정

**파일**: `apps/wowa/ios/Runner/Info.plist` (기존 파일 수정)

```xml
<!-- 푸시 알림 권한 요청 메시지 -->
<key>NSUserNotificationUsageDescription</key>
<string>중요한 소식을 실시간으로 받아보실 수 있습니다.</string>
```

**Capabilities 활성화** (Xcode):
1. Xcode에서 프로젝트 열기
2. Target → Signing & Capabilities → "+ Capability" 클릭
3. "Push Notifications" 추가
4. "Background Modes" 추가 → "Remote notifications" 체크

### 3. Android 설정

**파일**: `apps/wowa/android/app/build.gradle` (기존 파일 수정)

```gradle
plugins {
    // ... 기존 플러그인
    id 'com.google.gms.google-services'  // ✅ 추가
}

dependencies {
    // ... 기존 의존성
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

**파일**: `apps/wowa/android/build.gradle` (기존 파일 수정)

```gradle
buildscript {
    dependencies {
        // ... 기존 의존성
        classpath 'com.google.gms:google-services:4.4.0'  // ✅ 추가
    }
}
```

### 4. 검증

```bash
cd apps/wowa
flutter clean
flutter pub get
flutter run
```

앱 실행 후 로그에서 `PushService initialized successfully` 확인

---

## 참고 자료

- Firebase Messaging 문서: https://firebase.google.com/docs/cloud-messaging/flutter/client
- GetX 문서: https://pub.dev/packages/get
- Freezed 문서: https://pub.dev/packages/freezed
- `.claude/guide/mobile/` 가이드 모음
- `docs/wowa/mobile-catalog.md` (기존 구현 참조)

---

## 다음 단계

이 기술 아키텍처를 바탕으로 CTO가 작업을 검증하고 Senior/Junior Developer에게 분배합니다.

- **산출물**: `docs/wowa/push-alert/mobile-brief.md` (본 문서)
- **다음 단계**: CTO 검증 → 작업 분배 → 구현 → 테스트

---

## 요약

### 신규 추가 사항

1. **패키지**: `packages/push/` (재사용 가능한 FCM SDK)
2. **API 모델**: DeviceTokenRequest, NotificationModel, NotificationListResponse, UnreadCountResponse
3. **API 클라이언트**: PushApiClient (4개 API 메서드)
4. **앱 모듈**: NotificationController, NotificationView, NotificationBinding
5. **라우트**: `Routes.NOTIFICATIONS`
6. **위젯**: UnreadBadgeIcon (읽지 않은 배지)

### 핵심 설계 결정

- **packages/push/ 앱 독립성**: 콜백 주입 패턴으로 앱별 로직 분리
- **3가지 알림 상태 처리**: 포그라운드, 백그라운드, 종료 상태
- **낙관적 업데이트**: 읽음 처리 시 UI 즉시 업데이트 후 API 호출
- **무한 스크롤**: ListView.builder + 페이지네이션
- **딥링크**: `data['screen']` 기반 GetX 네비게이션

이 설계를 따르면 안전하고 확장 가능한 Push Notification 시스템을 구축할 수 있습니다.
