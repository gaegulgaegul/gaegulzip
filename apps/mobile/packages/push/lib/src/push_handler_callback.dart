import 'push_notification.dart';

/// 푸시 알림 처리 콜백 타입
///
/// 알림 수신 시 호출되는 콜백 함수의 시그니처를 정의합니다.
typedef PushHandlerCallback = void Function(PushNotification notification);
