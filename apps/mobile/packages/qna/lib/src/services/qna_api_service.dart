import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../models/qna_submit_request.dart';
import '../models/qna_submit_response.dart';

/// QnA API 서비스
///
/// 질문 제출 API를 호출합니다.
class QnaApiService {
  late final Dio _dio = Get.find<Dio>();

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
      Logger.debug('QnA: POST /qna/questions 요청');
      final response = await _dio.post(
        '/qna/questions',
        data: request.toJson(),
      );
      Logger.debug('QnA: POST /qna/questions 응답 - status=${response.statusCode}');
      return QnaSubmitResponse.fromJson(response.data);
    } on DioException catch (e) {
      Logger.warn('QnA: POST /qna/questions 실패 - ${e.type} ${e.response?.statusCode}');
      // DioException을 그대로 throw (Repository에서 처리)
      rethrow;
    }
  }
}
