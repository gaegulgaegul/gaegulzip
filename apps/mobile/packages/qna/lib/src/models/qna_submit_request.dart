import 'package:freezed_annotation/freezed_annotation.dart';

part 'qna_submit_request.freezed.dart';
part 'qna_submit_request.g.dart';

/// 질문 제출 요청 모델
@freezed
class QnaSubmitRequest with _$QnaSubmitRequest {
  const factory QnaSubmitRequest({
    /// 앱 코드 ('wowa')
    required String appCode,

    /// 질문 제목 (최대 256자)
    required String title,

    /// 질문 본문 (최대 65536자)
    required String body,
  }) = _QnaSubmitRequest;

  factory QnaSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$QnaSubmitRequestFromJson(json);
}
