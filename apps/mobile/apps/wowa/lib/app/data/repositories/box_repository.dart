import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';

/// 박스 Repository
///
/// BoxApiClient를 래핑하여 박스 관련 데이터 액세스를 처리합니다.
/// DioException을 도메인 예외(NetworkException)로 변환합니다.
class BoxRepository {
  final BoxApiClient _apiClient = Get.find<BoxApiClient>();

  /// 현재 사용자의 박스 조회
  ///
  /// Returns: [BoxModel] 사용자가 속한 박스 (없으면 null)
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  Future<BoxModel?> getCurrentBox() async {
    try {
      return await _apiClient.getCurrentBox();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 박스 검색
  ///
  /// [name] 박스 이름 (선택, 부분 일치)
  /// [region] 지역 (선택, 부분 일치)
  ///
  /// Returns: [List<BoxModel>] 검색된 박스 목록
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  Future<List<BoxModel>> searchBoxes({String? name, String? region}) async {
    try {
      return await _apiClient.searchBoxes(name: name, region: region);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 박스 생성
  ///
  /// [request] 박스 생성 요청
  ///
  /// Returns: [BoxModel] 생성된 박스
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 이미 박스에 소속된 경우 (409)
  Future<BoxModel> createBox(CreateBoxRequest request) async {
    try {
      return await _apiClient.createBox(request);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('이미 박스에 소속되어 있습니다. 먼저 기존 박스를 탈퇴해주세요.');
      }
      throw _handleDioException(e);
    }
  }

  /// 박스 가입
  ///
  /// [boxId] 가입할 박스 ID
  ///
  /// Returns: 가입 결과 (membership 정보)
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 이미 동일 박스에 소속된 경우 (409)
  Future<Map<String, dynamic>> joinBox(int boxId) async {
    try {
      return await _apiClient.joinBox(boxId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('이미 해당 박스에 소속되어 있습니다.');
      }
      throw _handleDioException(e);
    }
  }

  /// 박스 상세 조회
  ///
  /// [boxId] 조회할 박스 ID
  ///
  /// Returns: [BoxModel] 박스 상세 정보
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 박스를 찾을 수 없는 경우 (404)
  Future<BoxModel> getBoxById(int boxId) async {
    try {
      return await _apiClient.getBoxById(boxId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('박스를 찾을 수 없습니다.');
      }
      throw _handleDioException(e);
    }
  }

  /// 박스 멤버 목록 조회
  ///
  /// [boxId] 조회할 박스 ID
  ///
  /// Returns: [List<BoxMemberModel>] 박스 멤버 목록
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  Future<List<BoxMemberModel>> getBoxMembers(int boxId) async {
    try {
      return await _apiClient.getBoxMembers(boxId);
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
