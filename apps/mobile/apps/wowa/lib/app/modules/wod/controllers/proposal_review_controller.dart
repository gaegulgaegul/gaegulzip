import 'package:get/get.dart';

import 'package:core/core.dart';
import '../../../data/models/proposal/proposal_model.dart';
import '../../../data/models/wod/wod_model.dart';
import '../../../data/repositories/proposal_repository.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../routes/app_routes.dart';

/// WOD 변경 제안 검토 컨트롤러
///
/// Base WOD와 제안된 WOD를 Before/After로 비교하고,
/// 승인/거부를 처리합니다.
class ProposalReviewController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// 검토할 변경 제안
  final proposal = Rxn<ProposalModel>();

  /// 현재 Base WOD
  final currentBase = Rxn<WodModel>();

  /// 제안된 새 WOD
  final proposedWod = Rxn<WodModel>();

  /// 제안자 정보
  final proposer = ''.obs;

  /// 로딩 상태
  final isLoading = false.obs;

  // ===== 비반응형 상태 =====

  late final ProposalRepository _proposalRepository;
  late final WodRepository _wodRepository;

  /// 기준 WOD ID
  late final int baseWodId;

  /// 박스 ID
  late final int boxId;

  /// 날짜 (YYYY-MM-DD)
  late final String date;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();
    _proposalRepository = Get.find<ProposalRepository>();
    _wodRepository = Get.find<WodRepository>();

    final args = Get.arguments as Map<String, dynamic>;
    baseWodId = args['baseWodId'] as int;
    boxId = args['boxId'] as int;
    date = args['date'] as String;

    _loadProposalData();
  }

  // ===== 데이터 로드 =====

  /// 제안 데이터 로드
  Future<void> _loadProposalData() async {
    try {
      isLoading.value = true;

      // 대기 중인 제안 목록에서 해당 제안 찾기
      final proposals = await _proposalRepository.getPendingProposals(
        baseWodId: baseWodId,
      );

      if (proposals.isEmpty) {
        Get.snackbar('안내', '대기 중인 제안이 없습니다');
        Get.back();
        return;
      }

      proposal.value = proposals.first;

      // WOD 정보 로드 (Base + Personal에서 찾기)
      final response = await _wodRepository.getWodsByDate(
        boxId: boxId,
        date: date,
      );

      currentBase.value = response.baseWod;

      // 제안된 WOD는 personalWods에서 proposedWodId로 찾기
      final proposed = response.personalWods.firstWhereOrNull(
        (w) => w.id == proposals.first.proposedWodId,
      );
      proposedWod.value = proposed;

      // 제안자 정보 (registeredBy 필드 활용)
      if (proposed?.registeredBy != null) {
        proposer.value = proposed!.registeredBy!;
      }
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } on AuthException catch (e) {
      Get.snackbar('인증 오류', e.message);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ===== 승인/거부 =====

  /// 승인 처리 (확인 모달)
  void approve() {
    _showApproveConfirmModal();
  }

  /// 승인 확인 모달
  void _showApproveConfirmModal() {
    Get.defaultDialog(
      title: '제안 승인',
      middleText: '이 제안을 승인하면 Base WOD가 변경됩니다. 계속하시겠습니까?',
      textConfirm: '승인',
      textCancel: '취소',
      onConfirm: () async {
        Get.back();
        await _performApprove();
      },
    );
  }

  /// 실제 승인 처리
  Future<void> _performApprove() async {
    final p = proposal.value;
    if (p == null) return;

    try {
      isLoading.value = true;
      await _proposalRepository.approveProposal(p.id);
      Get.snackbar('승인 완료', '제안이 승인되었습니다');
      Get.back(result: 'approved');
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 거부 처리 (확인 모달)
  void reject() {
    Get.defaultDialog(
      title: '제안 거부',
      middleText: '이 제안을 거부하시겠습니까?',
      textConfirm: '거부',
      textCancel: '취소',
      onConfirm: () async {
        Get.back();
        await _performReject();
      },
    );
  }

  /// 실제 거부 처리
  Future<void> _performReject() async {
    final p = proposal.value;
    if (p == null) return;

    try {
      isLoading.value = true;
      await _proposalRepository.rejectProposal(p.id);
      Get.snackbar('거부 완료', '제안이 거부되었습니다');
      Get.back(result: 'rejected');
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } catch (e) {
      Get.snackbar('오류', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
