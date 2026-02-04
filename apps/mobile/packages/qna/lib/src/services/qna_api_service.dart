import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/qna_submit_request.dart';
import '../models/qna_submit_response.dart';

/// QnA API 서비스
///
/// 질문 제출 API를 호출합니다.
class QnaApiService {
  final Dio _dio = Get.find<Dio>();

  /// 질문 제출 API 호출
  ///
  /// [request] 질문 제출 요청 (appCode, title, body)
  ///
  /// Returns: [QnaSubmitResponse] 질문 제출 응답 (questionId, issueNumber, issueUrl, createdAt)
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<QnaSubmitResponse> submitQuestion(QnaSubmitRequest request) async {
    try {
      final response = await _dio.post(
        '/api/qna/questions',
        data: request.toJson(),
      );
      return QnaSubmitResponse.fromJson(response.data);
    } on DioException {
      // DioException을 그대로 throw (Repository에서 처리)
      rethrow;
    }
  }
}
