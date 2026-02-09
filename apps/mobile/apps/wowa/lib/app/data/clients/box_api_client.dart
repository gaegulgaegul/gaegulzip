import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/box/box_model.dart';
import '../models/box/box_search_response.dart';
import '../models/box/create_box_request.dart';
import '../models/box/box_create_response.dart';
import '../models/box/membership_model.dart';
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

  /// 박스 검색 (통합 키워드)
  ///
  /// [keyword] 통합 검색 키워드 (박스 이름 또는 지역)
  ///
  /// Returns: [List<BoxModel>] 검색된 박스 목록
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<List<BoxModel>> searchBoxes(String keyword) async {
    final response = await _dio.get(
      '/boxes/search',
      queryParameters: {'keyword': keyword},
    );

    final searchResponse = BoxSearchResponse.fromJson(response.data);
    return searchResponse.boxes;
  }

  /// 박스 생성
  ///
  /// [request] 박스 생성 요청 (이름, 지역)
  ///
  /// Returns: [BoxCreateResponse] 생성된 박스 + 멤버십 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<BoxCreateResponse> createBox(CreateBoxRequest request) async {
    final response = await _dio.post(
      '/boxes',
      data: request.toJson(),
    );
    return BoxCreateResponse.fromJson(response.data);
  }

  /// 박스 가입
  ///
  /// [boxId] 가입할 박스 ID
  ///
  /// Returns: [MembershipModel] 생성된 멤버십
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<MembershipModel> joinBox(int boxId) async {
    final response = await _dio.post('/boxes/$boxId/join');
    return MembershipModel.fromJson(response.data['membership']);
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
