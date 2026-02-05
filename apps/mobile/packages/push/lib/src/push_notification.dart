import 'package:firebase_messaging/firebase_messaging.dart';

/// 푸시 알림 데이터 모델 (앱 독립적)
///
/// FCM RemoteMessage를 간단한 DTO로 변환하여 사용합니다.
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
  ///
  /// FCM의 RemoteMessage를 PushNotification으로 변환합니다.
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
