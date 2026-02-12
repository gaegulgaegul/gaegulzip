import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'models/device_token_request.dart';
import 'push_api_client.dart';
import 'push_notification.dart';
import 'push_handler_callback.dart';

/// 디바이스 플랫폼 식별 상수
class PushPlatform {
  static const String ios = 'ios';
  static const String android = 'android';

  /// 현재 플랫폼 문자열 반환
  static String get current => Platform.isIOS ? ios : android;
}

/// FCM 푸시 알림 서비스 (앱 독립적 SDK)
///
/// Firebase Cloud Messaging을 초기화하고 알림을 처리하는 서비스입니다.
/// GetxService를 상속하여 앱 생명주기 동안 단일 인스턴스를 유지합니다.
class PushService extends GetxService {
  /// Firebase Messaging 인스턴스 (initialize() 에서 할당)
  late final FirebaseMessaging _messaging;

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
      // 1. Firebase Messaging 인스턴스 획득 (Firebase는 앱에서 초기화됨)
      _messaging = FirebaseMessaging.instance;

      // 2. 권한 요청
      await _requestPermission();

      // 3. 디바이스 토큰 획득
      await _getDeviceToken();

      // 4. 토큰 갱신 리스너 (값 업데이트만 — 서버 등록은 ever 콜백에서 처리)
      _subscriptions.add(_messaging.onTokenRefresh.listen((newToken) {
        deviceToken.value = newToken;
        Logger.info('FCM token refreshed: ${newToken.length > 20 ? newToken.substring(0, 20) : newToken}...');
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
      // iOS: APNS 토큰 준비 대기 (FCM 토큰 발급에 필요)
      if (Platform.isIOS) {
        var apnsToken = await _messaging.getAPNSToken();
        for (var i = 0; i < 5 && apnsToken == null; i++) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _messaging.getAPNSToken();
        }
        if (apnsToken == null) {
          Logger.warn('APNS token not available after retries');
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) {
        deviceToken.value = token;
        Logger.info('FCM device token obtained: ${token.length > 20 ? token.substring(0, 20) : token}...');
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

  /// 서버에 디바이스 토큰 등록 (로그인 후 호출)
  ///
  /// 토큰이 없거나 에러 발생 시 조용히 실패합니다.
  /// Upsert 방식이므로 중복 호출해도 안전합니다.
  ///
  /// Returns: 등록 성공 여부
  Future<bool> registerDeviceTokenToServer() async {
    try {
      final token = deviceToken.value;
      if (token == null || token.isEmpty) {
        Logger.warn('FCM 토큰이 없어 서버 등록을 건너뜁니다');
        return false;
      }

      final apiClient = Get.find<PushApiClient>();
      final platform = PushPlatform.current;
      final deviceId = await _getDeviceId();

      await apiClient.registerDevice(DeviceTokenRequest(
        token: token,
        platform: platform,
        deviceId: deviceId,
      ));

      Logger.info('FCM 토큰 서버 등록 성공: ${token.length > 20 ? token.substring(0, 20) : token}...');
      return true;
    } on DioException catch (e) {
      Logger.error('FCM 토큰 서버 등록 실패 (네트워크)', error: e);
      return false;
    } catch (e, stackTrace) {
      Logger.error('FCM 토큰 서버 등록 실패', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 서버에서 디바이스 토큰 비활성화 (로그아웃 시 호출)
  ///
  /// 토큰이 없거나 에러 발생 시 조용히 실패합니다.
  Future<void> deactivateDeviceTokenOnServer() async {
    try {
      final token = deviceToken.value;
      if (token == null || token.isEmpty) {
        Logger.warn('FCM 토큰이 없어 비활성화를 건너뜁니다');
        return;
      }

      final apiClient = Get.find<PushApiClient>();
      await apiClient.deactivateDeviceByToken(token);

      Logger.info('FCM 토큰 서버 비활성화 성공: ${token.length > 20 ? token.substring(0, 20) : token}...');
    } on DioException catch (e) {
      Logger.error('FCM 토큰 서버 비활성화 실패 (네트워크 오류)', error: e);
    } catch (e, stackTrace) {
      Logger.error('FCM 토큰 서버 비활성화 실패 (예외)', error: e, stackTrace: stackTrace);
    }
  }

  /// 디바이스 고유 ID 획득 (선택적)
  ///
  /// iOS: identifierForVendor, Android: Build.ID
  /// 실패 시 null 반환 (서버에서 deviceId는 optional)
  Future<String?> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final id = iosInfo.identifierForVendor;
        Logger.debug('디바이스 ID (iOS identifierForVendor): $id');
        return id;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final id = androidInfo.id;
        Logger.debug('디바이스 ID (Android Build.ID): $id');
        return id;
      }
      Logger.debug('디바이스 ID: 지원하지 않는 플랫폼');
      return null;
    } catch (e) {
      Logger.warn('디바이스 ID 획득 실패: $e');
      return null;
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
