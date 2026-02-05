import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/proposal/proposal_model.dart';

/// 변경 제안 API 클라이언트
///
/// WOD 변경 제안 조회, 승인, 거부 API를 호출합니다.
class ProposalApiClient {
  final Dio _dio = Get.find<Dio>();

  /// 대기 중인 변경 제안 목록 조회
  ///
  /// [baseWodId] 기준 WOD ID
  ///
  /// Returns: [List<ProposalModel>] 대기 중인 변경 제안 목록
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<List<ProposalModel>> getPendingProposals({
    required int baseWodId,
  }) async {
    final response = await _dio.get(
      '/wods/proposals',
      queryParameters: {
        'baseWodId': baseWodId,
        'status': 'pending',
      },
    );
    final data = response.data['proposals'] as List?;
    if (data == null) return [];
    return data.map((json) => ProposalModel.fromJson(json)).toList();
  }

  /// 변경 제안 승인
  ///
  /// [proposalId] 승인할 제안 ID
  ///
  /// Returns: [ProposalModel] 승인된 제안 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<ProposalModel> approveProposal(int proposalId) async {
    final response = await _dio.post('/wods/proposals/$proposalId/approve');
    return ProposalModel.fromJson(response.data);
  }

  /// 변경 제안 거부
  ///
  /// [proposalId] 거부할 제안 ID
  ///
  /// Returns: [ProposalModel] 거부된 제안 정보
  ///
  /// Throws:
  ///   - [DioException] 네트워크 오류, HTTP 오류
  Future<ProposalModel> rejectProposal(int proposalId) async {
    final response = await _dio.post('/wods/proposals/$proposalId/reject');
    return ProposalModel.fromJson(response.data);
  }
}
