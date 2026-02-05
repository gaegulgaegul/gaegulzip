import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/notice_model.dart';
import '../models/notice_list_response.dart';
import '../models/unread_count_response.dart';

/// 공지사항 API 서비스
///
/// 서버 API와의 HTTP 통신을 담당합니다.
class NoticeApiService {
  /// Dio 인스턴스 (api 패키지에서 제공)
  final Dio _dio = Get.find<Dio>();

  /// 공지사항 목록 조회
  ///
  /// [page] 페이지 번호 (기본: 1)
  /// [limit] 페이지 크기 (기본: 20)
  /// [category] 카테고리 필터 (선택)
  /// [pinnedOnly] 고정 공지만 조회 (선택)
  ///
  /// Returns: [NoticeListResponse] 목록 응답
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<NoticeListResponse> getNotices({
    int page = 1,
    int limit = 20,
    String? category,
    bool? pinnedOnly,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null) {
        queryParameters['category'] = category;
      }
      if (pinnedOnly != null) {
        queryParameters['pinnedOnly'] = pinnedOnly;
      }

      final response = await _dio.get(
        '/notices',
        queryParameters: queryParameters,
      );

      return NoticeListResponse.fromJson(response.data);
    } on DioException {
      // DioException을 그대로 throw (Controller에서 처리)
      rethrow;
    }
  }

  /// 공지사항 상세 조회
  ///
  /// [id] 공지사항 ID
  ///
  /// Returns: [NoticeModel] 상세 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류 (404: 공지사항 미존재)
  Future<NoticeModel> getNoticeDetail(int id) async {
    try {
      final response = await _dio.get('/notices/$id');

      return NoticeModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// 읽지 않은 공지 개수 조회
  ///
  /// Returns: [UnreadCountResponse] 읽지 않은 개수
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final response = await _dio.get('/notices/unread-count');

      return UnreadCountResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}
