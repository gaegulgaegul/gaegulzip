import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../data/repositories/proposal_repository.dart';
import '../../../routes/app_routes.dart';

/// WOD 상세/비교 화면 컨트롤러
///
/// Base WOD와 Personal WOD 목록을 표시하고, 제안 검토/선택 화면으로 이동합니다.
class WodDetailController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// Base WOD
  final baseWod = Rxn<WodModel>();

  /// Personal WOD 목록
  final personalWods = <WodModel>[].obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// 대기 중인 변경 제안 존재 여부
  final hasPendingProposal = false.obs;

  /// 현재 사용자가 Base WOD 등록자인지
  final isBaseCreator = false.obs;

  // ===== 비반응형 상태 =====

  late final WodRepository _wodRepository;
  late final ProposalRepository _proposalRepository;

  /// 박스 ID
  late final int boxId;

  /// 날짜 (YYYY-MM-DD)
  late final String date;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();
    _wodRepository = Get.find<WodRepository>();
    _proposalRepository = Get.find<ProposalRepository>();

    final args = Get.arguments as Map<String, dynamic>;
    boxId = args['boxId'] as int;
    date = args['date'] as String;

    _loadWods();
  }

  // ===== 데이터 로드 =====

  /// WOD 데이터 및 제안 상태 로드
  Future<void> _loadWods() async {
    try {
      isLoading.value = true;

      final response = await _wodRepository.getWodsByDate(
        boxId: boxId,
        date: date,
      );

      baseWod.value = response.baseWod;
      personalWods.assignAll(response.personalWods);

      // Base WOD가 있으면 제안 상태 확인
      if (response.baseWod != null) {
        hasPendingProposal.value = await _proposalRepository.hasPendingProposal(
          baseWodId: response.baseWod!.id,
        );

        // TODO: 현재 사용자 ID와 비교 (SecureStorageService에서 가져와야 함)
        // isBaseCreator.value = currentUserId == response.baseWod!.createdBy;
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

  // ===== 네비게이션 =====

  /// 제안 검토 화면으로 이동
  void goToReview() {
    final base = baseWod.value;
    if (base == null) return;

    Get.toNamed(Routes.PROPOSAL_REVIEW, arguments: {
      'baseWodId': base.id,
      'boxId': boxId,
      'date': date,
    });
  }

  /// WOD 선택 화면으로 이동
  void goToSelect() {
    Get.toNamed(Routes.WOD_SELECT, arguments: {
      'boxId': boxId,
      'date': date,
    });
  }

  /// WOD 등록 화면으로 이동
  void goToRegister() {
    Get.toNamed(Routes.WOD_REGISTER, arguments: {
      'boxId': boxId,
      'date': date,
    });
  }
}
