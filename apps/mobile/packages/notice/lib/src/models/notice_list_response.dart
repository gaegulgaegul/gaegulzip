import 'package:freezed_annotation/freezed_annotation.dart';
import 'notice_model.dart';

part 'notice_list_response.freezed.dart';
part 'notice_list_response.g.dart';

/// 공지사항 목록 응답 래퍼
///
/// 페이지네이션 메타 정보를 포함합니다.
@freezed
class NoticeListResponse with _$NoticeListResponse {
  const factory NoticeListResponse({
    /// 공지사항 목록
    required List<NoticeModel> items,

    /// 전체 개수
    required int totalCount,

    /// 현재 페이지
    required int page,

    /// 페이지 크기
    required int limit,

    /// 다음 페이지 존재 여부
    required bool hasNext,
  }) = _NoticeListResponse;

  /// JSON에서 역직렬화
  factory NoticeListResponse.fromJson(Map<String, dynamic> json) =>
      _$NoticeListResponseFromJson(json);
}
