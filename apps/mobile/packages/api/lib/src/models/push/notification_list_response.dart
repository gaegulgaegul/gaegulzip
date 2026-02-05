import 'package:freezed_annotation/freezed_annotation.dart';
import 'notification_model.dart';

part 'notification_list_response.freezed.dart';
part 'notification_list_response.g.dart';

/// 알림 목록 조회 응답
@freezed
class NotificationListResponse with _$NotificationListResponse {
  const factory NotificationListResponse({
    /// 알림 목록
    required List<NotificationModel> notifications,

    /// 총 개수
    required int total,
  }) = _NotificationListResponse;

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);
}
