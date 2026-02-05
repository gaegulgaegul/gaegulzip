import 'package:freezed_annotation/freezed_annotation.dart';

part 'unread_count_response.freezed.dart';
part 'unread_count_response.g.dart';

/// 읽지 않은 알림 개수 응답
@freezed
class UnreadCountResponse with _$UnreadCountResponse {
  const factory UnreadCountResponse({
    /// 읽지 않은 알림 개수
    required int unreadCount,
  }) = _UnreadCountResponse;

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
}
