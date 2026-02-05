import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/push/device_token_request.dart';
import '../models/push/notification_list_response.dart';
import '../models/push/unread_count_response.dart';

/// 푸시 알림 API 클라이언트
///
/// 알림 조회, 읽음 처리, 디바이스 토큰 등록 API를 호출합니다.
class PushApiClient {
  final Dio _dio = Get.find<Dio>();

  /// 디바이스 토큰 등록
  ///
  /// FCM 디바이스 토큰을 서버에 등록합니다.
  ///
  /// [request] 디바이스 토큰 등록 요청 (token, platform, deviceId)
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<void> registerDevice(DeviceTokenRequest request) async {
    try {
      await _dio.post(
        '/api/push/devices',
        data: request.toJson(),
      );
    } on DioException {
      rethrow;
    }
  }

  /// 내 알림 목록 조회
  ///
  /// 인증된 사용자의 알림 목록을 페이지네이션으로 조회합니다.
  ///
  /// [limit] 한 페이지 당 개수 (기본 20, 최대 100)
  /// [offset] 시작 위치 (기본 0)
  /// [unreadOnly] 읽지 않은 알림만 조회 (선택)
  ///
  /// Returns: [NotificationListResponse] 알림 목록 + 총 개수
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<NotificationListResponse> getMyNotifications({
    int limit = 20,
    int offset = 0,
    bool? unreadOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (unreadOnly != null) {
        queryParams['unreadOnly'] = unreadOnly;
      }

      final response = await _dio.get(
        '/api/push/notifications/me',
        queryParameters: queryParams,
      );
      return NotificationListResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// 읽지 않은 알림 개수 조회
  ///
  /// Returns: [UnreadCountResponse] 읽지 않은 알림 개수
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final response = await _dio.get(
        '/api/push/notifications/unread-count',
      );
      return UnreadCountResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// 알림 읽음 처리
  ///
  /// [notificationId] 읽음 처리할 알림 ID
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류 (404: 알림 없음)
  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.patch(
        '/api/push/notifications/$notificationId/read',
      );
    } on DioException {
      rethrow;
    }
  }
}
