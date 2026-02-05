import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../models/qna_submit_request.dart';
import '../models/qna_submit_response.dart';
import '../services/qna_api_service.dart';

/// QnA Repository
///
/// API 서비스를 통합하여 질문 제출을 처리합니다.
class QnaRepository {
  /// 앱 코드 (생성자로 주입)
  final String appCode;

  final QnaApiService _apiService;

  /// 생성자
  ///
  /// [appCode] 앱 식별 코드 (예: 'wowa', 'other-app')
  /// [apiService] API 서비스 (테스트 시 주입 가능, 기본값: Get.find)
  QnaRepository({required this.appCode, QnaApiService? apiService})
      : _apiService = apiService ?? Get.find<QnaApiService>();

  /// 질문 제출 처리
  ///
  /// [title] 질문 제목 (최대 256자)
  /// [body] 질문 본문 (최대 65536자)
  ///
  /// Returns: [QnaSubmitResponse] 제출된 질문 정보
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 기타 서버 오류
  Future<QnaSubmitResponse> submitQuestion({
    required String title,
    required String body,
  }) async {
    try {
      // 1. 요청 생성 (appCode 동적 주입)
      final request = QnaSubmitRequest(
        appCode: appCode, // 생성자로 받은 appCode 사용
        title: title,
        body: body,
      );

      // 2. API 호출
      return await _apiService.submitQuestion(request);
    } on DioException catch (e) {
      // DioException을 도메인 예외로 변환
      throw _mapDioError(e);
    }
  }

  /// DioException을 도메인 예외로 변환
  ///
  /// [e] DioException
  ///
  /// Returns: 변환된 예외 (NetworkException 또는 Exception)
  Exception _mapDioError(DioException e) {
    // 네트워크 연결 오류
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(message: '네트워크 연결을 확인해주세요');
    }

    // HTTP 상태 코드별 처리
    final statusCode = e.response?.statusCode;

    if (statusCode == 400) {
      // 입력 검증 오류
      return NetworkException(
        message: '제목과 내용을 확인해주세요',
        statusCode: statusCode,
      );
    }

    if (statusCode == 404) {
      // 앱 설정 없음
      return NetworkException(
        message: '서비스 설정 오류가 발생했습니다',
        statusCode: statusCode,
      );
    }

    if (statusCode == 401 || statusCode == 403) {
      return NetworkException(
        message: '인증이 필요합니다. 다시 로그인해주세요',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      // 서버 오류
      return NetworkException(
        message: '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요',
        statusCode: statusCode,
      );
    }

    // 기타 오류
    return NetworkException(
      message: '알 수 없는 오류가 발생했습니다',
    );
  }
}
