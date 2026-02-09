import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../clients/proposal_api_client.dart';
import '../models/proposal/proposal_model.dart';

/// 변경 제안 Repository
///
/// ProposalApiClient를 래핑하여 제안 관련 데이터 액세스를 처리합니다.
/// DioException을 도메인 예외(NetworkException)로 변환합니다.
class ProposalRepository {
  final ProposalApiClient _apiClient = Get.find<ProposalApiClient>();

  /// 대기 중인 변경 제안 목록 조회
  ///
  /// [baseWodId] 기준 WOD ID
  ///
  /// Returns: [List<ProposalModel>] 대기 중인 제안 목록
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  Future<List<ProposalModel>> getPendingProposals({
    required int baseWodId,
  }) async {
    try {
      return await _apiClient.getPendingProposals(baseWodId: baseWodId);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 대기 중인 제안 존재 여부 확인
  ///
  /// [baseWodId] 기준 WOD ID
  ///
  /// Returns: 대기 중인 제안이 있으면 true
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  Future<bool> hasPendingProposal({required int baseWodId}) async {
    final proposals = await getPendingProposals(baseWodId: baseWodId);
    return proposals.isNotEmpty;
  }

  /// 변경 제안 승인
  ///
  /// [proposalId] 승인할 제안 ID
  ///
  /// Returns: [ProposalModel] 승인된 제안 정보
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 이미 처리된 제안 (409)
  Future<ProposalModel> approveProposal(int proposalId) async {
    try {
      return await _apiClient.approveProposal(proposalId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw BusinessException(
          code: 'already_processed',
          message: '이미 처리된 제안입니다.',
        );
      }
      throw _handleDioException(e);
    }
  }

  /// 변경 제안 거부
  ///
  /// [proposalId] 거부할 제안 ID
  ///
  /// Returns: [ProposalModel] 거부된 제안 정보
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 이미 처리된 제안 (409)
  Future<ProposalModel> rejectProposal(int proposalId) async {
    try {
      return await _apiClient.rejectProposal(proposalId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw BusinessException(
          code: 'already_processed',
          message: '이미 처리된 제안입니다.',
        );
      }
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
