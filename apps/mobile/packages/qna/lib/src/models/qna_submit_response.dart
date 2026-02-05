import 'package:freezed_annotation/freezed_annotation.dart';

part 'qna_submit_response.freezed.dart';
part 'qna_submit_response.g.dart';

/// 질문 제출 응답 모델
@freezed
class QnaSubmitResponse with _$QnaSubmitResponse {
  const factory QnaSubmitResponse({
    /// 생성된 질문 ID
    required int questionId,

    /// GitHub Issue 번호
    required int issueNumber,

    /// GitHub Issue URL
    required String issueUrl,

    /// 생성 일시 (ISO 8601)
    required String createdAt,
  }) = _QnaSubmitResponse;

  factory QnaSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$QnaSubmitResponseFromJson(json);
}
