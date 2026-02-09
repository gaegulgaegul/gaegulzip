import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/box/box_model.dart';
import '../models/box/create_box_request.dart';
import '../models/box/box_member_model.dart';

/// 박스 API 클라이언트
///
/// 박스 조회, 생성, 가입, 멤버 관리 API를 호출합니다.
class BoxApiClient {
  final Dio _dio = Get.find<Dio>();

  /// 현재 사용자의 박스 조회
  ///
  /// Returns: [BoxModel] 사용자가 속한 박스 (없으면 null)
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<BoxModel?> getCurrentBox() async {
    final response = await _dio.get('/boxes/me');
    final data = response.data['box'];
    return data != null ? BoxModel.fromJson(data) : null;
  }

  /// 박스 검색
  ///
  /// [name] 박스 이름 (선택, 부분 일치)
  /// [region] 지역 (선택, 부분 일치)
  ///
  /// Returns: [List<BoxModel>] 검색된 박스 목록
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<List<BoxModel>> searchBoxes({String? name, String? region}) async {
    final queryParameters = <String, dynamic>{};
    if (name != null) queryParameters['name'] = name;
    if (region != null) queryParameters['region'] = region;

    final response = await _dio.get(
      '/boxes/search',
      queryParameters: queryParameters,
    );
    final data = response.data['boxes'] as List?;
    if (data == null) return [];
    return data.map((json) => BoxModel.fromJson(json)).toList();
  }

  /// 박스 생성
  ///
  /// [request] 박스 생성 요청 (이름, 지역)
  ///
  /// Returns: [BoxModel] 생성된 박스
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<BoxModel> createBox(CreateBoxRequest request) async {
    final response = await _dio.post(
      '/boxes',
      data: request.toJson(),
    );
    return BoxModel.fromJson(response.data['box']);
  }

  /// 박스 가입
  ///
  /// [boxId] 가입할 박스 ID
  ///
  /// Returns: membership + previousBoxId 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<Map<String, dynamic>> joinBox(int boxId) async {
    final response = await _dio.post('/boxes/$boxId/join');
    return response.data as Map<String, dynamic>;
  }

  /// 박스 상세 조회
  ///
  /// [boxId] 조회할 박스 ID
  ///
  /// Returns: [BoxModel] 박스 상세 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<BoxModel> getBoxById(int boxId) async {
    final response = await _dio.get('/boxes/$boxId');
    return BoxModel.fromJson(response.data);
  }

  /// 박스 멤버 목록 조회
  ///
  /// [boxId] 조회할 박스 ID
  ///
  /// Returns: [List<BoxMemberModel>] 박스 멤버 목록
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<List<BoxMemberModel>> getBoxMembers(int boxId) async {
    final response = await _dio.get('/boxes/$boxId/members');
    final data = response.data['members'] as List?;
    if (data == null) return [];
    return data.map((json) => BoxMemberModel.fromJson(json)).toList();
  }
}
