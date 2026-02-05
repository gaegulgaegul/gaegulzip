import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/wod/wod_list_response.dart';
import '../models/wod/register_wod_request.dart';
import '../models/selection/selection_model.dart';

/// WOD API 클라이언트
///
/// WOD 등록, 조회, 선택, 선택 이력 조회 API를 호출합니다.
class WodApiClient {
  final Dio _dio = Get.find<Dio>();

  /// WOD 등록
  ///
  /// [request] WOD 등록 요청 (날짜, 박스 ID, 운동 설명)
  ///
  /// Returns: wod + comparisonResult + proposal 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<Map<String, dynamic>> registerWod(RegisterWodRequest request) async {
    try {
      final response = await _dio.post(
        '/wods',
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException {
      // DioException을 그대로 throw (Repository에서 처리)
      rethrow;
    }
  }

  /// 특정 날짜의 WOD 목록 조회
  ///
  /// [boxId] 박스 ID
  /// [date] 날짜 (YYYY-MM-DD 형식)
  ///
  /// Returns: [WodListResponse] WOD 목록 응답 (boxWod, personalWods)
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<WodListResponse> getWodsByDate({
    required int boxId,
    required String date,
  }) async {
    try {
      final response = await _dio.get('/wods/$boxId/$date');
      return WodListResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// WOD 선택
  ///
  /// [wodId] 선택할 WOD ID
  /// [boxId] 박스 ID
  /// [date] 선택 날짜 (YYYY-MM-DD 형식)
  ///
  /// Returns: 선택 결과 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<Map<String, dynamic>> selectWod({
    required int wodId,
    required int boxId,
    required String date,
  }) async {
    try {
      final response = await _dio.post(
        '/wods/$wodId/select',
        data: {
          'boxId': boxId,
          'date': date,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    }
  }

  /// WOD 선택 이력 조회
  ///
  /// [startDate] 시작 날짜 (선택, YYYY-MM-DD 형식)
  /// [endDate] 종료 날짜 (선택, YYYY-MM-DD 형식)
  ///
  /// Returns: [List<WodSelectionModel>] 선택 이력 목록
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<List<WodSelectionModel>> getSelections({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (startDate != null) queryParameters['startDate'] = startDate;
      if (endDate != null) queryParameters['endDate'] = endDate;

      final response = await _dio.get(
        '/wods/selections',
        queryParameters: queryParameters,
      );
      final data = response.data['selections'] as List;
      return data.map((json) => WodSelectionModel.fromJson(json)).toList();
    } on DioException {
      rethrow;
    }
  }
}
