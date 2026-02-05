import 'package:freezed_annotation/freezed_annotation.dart';

part 'notice_model.freezed.dart';
part 'notice_model.g.dart';

/// 공지사항 데이터 모델
///
/// 서버 API 응답을 파싱하여 불변 객체로 관리합니다.
@freezed
class NoticeModel with _$NoticeModel {
  const factory NoticeModel({
    /// 공지사항 ID
    required int id,

    /// 제목
    required String title,

    /// 본문 (마크다운 형식, 상세 조회 시에만 포함)
    String? content,

    /// 카테고리 (업데이트, 점검, 이벤트 등)
    String? category,

    /// 상단 고정 여부
    required bool isPinned,

    /// 읽음 여부 (현재 사용자 기준)
    @Default(false) bool isRead,

    /// 조회수
    required int viewCount,

    /// 작성일시 (ISO-8601 문자열)
    required String createdAt,

    /// 수정일시 (상세 조회 시에만 포함)
    String? updatedAt,
  }) = _NoticeModel;

  /// JSON에서 역직렬화
  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);
}
