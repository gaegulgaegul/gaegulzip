import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// 알림 수신 기록 모델 (서버 API 응답)
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
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
