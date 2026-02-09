import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../clients/wod_api_client.dart';
import '../models/wod/wod_list_response.dart';
import '../models/wod/register_wod_request.dart';
import '../models/selection/selection_model.dart';

/// WOD Repository
///
/// WodApiClient를 래핑하여 WOD 관련 데이터 액세스를 처리합니다.
/// DioException을 도메인 예외(NetworkException)로 변환합니다.
class WodRepository {
  final WodApiClient _apiClient = Get.find<WodApiClient>();

  /// 특정 날짜의 WOD 목록 조회
  ///
  /// [boxId] 박스 ID
  /// [date] 날짜 (YYYY-MM-DD 형식)
  ///
  /// Returns: [WodListResponse] WOD 목록 응답 (baseWod, personalWods)
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  Future<WodListResponse> getWodsByDate({
    required int boxId,
    required String date,
  }) async {
    try {
      return await _apiClient.getWodsByDate(boxId: boxId, date: date);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// WOD 등록
  ///
  /// [request] WOD 등록 요청
  ///
  /// Returns: wod + comparisonResult + proposal 정보
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 박스 미가입 (403), 유효하지 않은 요청 (422)
  Future<Map<String, dynamic>> registerWod(RegisterWodRequest request) async {
    try {
      return await _apiClient.registerWod(request);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('박스에 가입되어 있지 않습니다.');
      }
      if (e.response?.statusCode == 422) {
        throw Exception('WOD 정보가 올바르지 않습니다. 다시 확인해주세요.');
      }
      throw _handleDioException(e);
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
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 이미 선택한 경우 (409)
  Future<Map<String, dynamic>> selectWod({
    required int wodId,
    required int boxId,
    required String date,
  }) async {
    try {
      return await _apiClient.selectWod(
        wodId: wodId,
        boxId: boxId,
        date: date,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('이미 오늘의 WOD를 선택했습니다.');
      }
      throw _handleDioException(e);
    }
  }

  /// WOD 선택 이력 조회
  ///
  /// [startDate] 시작 날짜 (선택)
  /// [endDate] 종료 날짜 (선택)
  ///
  /// Returns: [List<WodSelectionModel>] 선택 이력 목록
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  Future<List<WodSelectionModel>> getSelections({
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _apiClient.getSelections(
        startDate: startDate,
        endDate: endDate,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// DioException을 도메인 예외로 변환
  Exception _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(message: '네트워크 연결을 확인해주세요');
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkException(message: '서버에 연결할 수 없습니다');
    }

    if (e.response?.statusCode == 401) {
      return AuthException(code: 'unauthorized', message: '로그인이 필요합니다');
    }

    if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      return Exception('일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요');
    }

    return NetworkException(
      message: '요청 중 오류가 발생했습니다',
      statusCode: e.response?.statusCode,
    );
  }
}
