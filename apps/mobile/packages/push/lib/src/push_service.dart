import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'push_notification.dart';
import 'push_handler_callback.dart';

/// FCM 푸시 알림 서비스 (앱 독립적 SDK)
///
/// Firebase Cloud Messaging을 초기화하고 알림을 처리하는 서비스입니다.
/// GetxService를 상속하여 앱 생명주기 동안 단일 인스턴스를 유지합니다.
class PushService extends GetxService {
  /// Firebase Messaging 인스턴스
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 스트림 구독 관리 (메모리 누수 방지)
  final List<StreamSubscription> _subscriptions = [];

  /// 현재 디바이스 토큰 (반응형)
  final Rxn<String> deviceToken = Rxn<String>();

  /// 초기화 완료 여부
  final isInitialized = false.obs;

  /// 포그라운드 알림 핸들러 (앱에서 주입)
  ///
  /// 앱이 포그라운드 상태일 때 알림 수신 시 호출됩니다.
  PushHandlerCallback? onForegroundMessage;

  /// 백그라운드 알림 탭 핸들러 (앱에서 주입)
  ///
  /// 앱이 백그라운드 상태일 때 사용자가 알림을 탭한 경우 호출됩니다.
  PushHandlerCallback? onBackgroundMessageOpened;

  /// 종료 상태 알림 탭 핸들러 (앱에서 주입)
  ///
  /// 앱이 종료된 상태에서 사용자가 알림을 탭하여 앱이 실행된 경우 호출됩니다.
  PushHandlerCallback? onTerminatedMessageOpened;

  /// Firebase 초기화 및 권한 요청
  ///
  /// Firebase를 초기화하고, 푸시 알림 권한을 요청하며,
  /// 디바이스 토큰을 획득합니다. 또한 알림 리스너를 등록합니다.
  Future<void> initialize() async {
    if (isInitialized.value) {
      Logger.info('PushService already initialized');
      return;
    }

    try {
      // 1. Firebase 초기화
      await Firebase.initializeApp();
      Logger.info('Firebase initialized successfully');

      // 2. 권한 요청
      await _requestPermission();

      // 3. 디바이스 토큰 획득
      await _getDeviceToken();

      // 4. 토큰 갱신 리스너
      _subscriptions.add(_messaging.onTokenRefresh.listen((newToken) {
        deviceToken.value = newToken;
        Logger.info('FCM token refreshed: ${newToken.substring(0, 20)}...');
      }));

      // 5. 포그라운드 메시지 리스너
      _subscriptions.add(FirebaseMessaging.onMessage.listen(_handleForegroundMessage));

      // 6. 백그라운드 메시지 탭 리스너
      _subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageOpened));

      // 7. 종료 상태 메시지 확인
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleTerminatedMessageOpened(initialMessage);
      }

      isInitialized.value = true;
      Logger.info('PushService initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize PushService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 권한 요청
  ///
  /// iOS에서는 사용자에게 알림 권한을 요청하는 다이얼로그를 표시합니다.
  /// Android는 기본적으로 알림이 허용되어 있습니다.
  Future<void> _requestPermission() async {
    try {
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
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        Logger.info('Push notification permission granted (provisional)');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to request push notification permission', error: e, stackTrace: stackTrace);
    }
  }

  /// 디바이스 토큰 획득
  ///
  /// FCM 디바이스 토큰을 가져옵니다.
  /// 이 토큰은 서버에서 특정 디바이스로 푸시 알림을 보낼 때 사용됩니다.
  Future<void> _getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        deviceToken.value = token;
        Logger.info('FCM device token obtained: ${token.substring(0, 20)}...');
      } else {
        Logger.warn('Failed to obtain FCM device token');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to get FCM token', error: e, stackTrace: stackTrace);
    }
  }

  /// 포그라운드 메시지 처리
  ///
  /// 앱이 포그라운드 상태일 때 알림이 수신되면 호출됩니다.
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
  ///
  /// 앱이 백그라운드 상태일 때 사용자가 알림을 탭하면 호출됩니다.
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
  ///
  /// 앱이 종료된 상태에서 사용자가 알림을 탭하여 앱이 실행되면 호출됩니다.
  void _handleTerminatedMessageOpened(RemoteMessage message) {
    Logger.debug('Terminated message opened: ${message.messageId}');

    final notification = PushNotification.fromRemoteMessage(message);

    if (onTerminatedMessageOpened != null) {
      onTerminatedMessageOpened!(notification);
    } else {
      Logger.warn('No terminated message handler registered');
    }
  }

  @override
  void onClose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.onClose();
  }

  /// 토큰 수동 갱신
  ///
  /// 필요한 경우 디바이스 토큰을 수동으로 갱신합니다.
  Future<void> refreshToken() async {
    Logger.info('Manually refreshing FCM token');
    await _getDeviceToken();
  }
}
