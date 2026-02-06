import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../routes/app_routes.dart';

/// WOD 선택 화면 컨트롤러
///
/// WOD 옵션을 라디오 버튼으로 표시하고, 선택 확인 후 서버에 전송합니다.
/// 선택은 되돌릴 수 없으므로 최종 확인 모달을 필수로 표시합니다.
class WodSelectController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// Base WOD
  final baseWod = Rxn<WodModel>();

  /// Personal WOD 목록
  final personalWods = <WodModel>[].obs;

  /// 선택한 WOD의 ID
  final selectedWodId = RxnInt();

  /// 로딩 상태
  final isLoading = false.obs;

  // ===== 비반응형 상태 =====

  late final WodRepository _wodRepository;

  /// 박스 ID
  late final int boxId;

  /// 날짜 (YYYY-MM-DD)
  late final String date;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();
    _wodRepository = Get.find<WodRepository>();

    final args = Get.arguments;
    if (args is! Map<String, dynamic>) {
      Get.snackbar('오류', '잘못된 화면 전환입니다');
      Get.back();
      return;
    }
    boxId = args['boxId'] as int;
    date = args['date'] as String;

    _loadWods();
  }

  /// WOD 목록 로드
  Future<void> _loadWods() async {
    try {
      isLoading.value = true;

      final response = await _wodRepository.getWodsByDate(
        boxId: boxId,
        date: date,
      );

      baseWod.value = response.baseWod;
      personalWods.assignAll(response.personalWods);
    } on NetworkException catch (e) {
      Get.snackbar('네트워크 오류', e.message);
    } on AuthException catch (e) {
      Get.snackbar('인증 오류', e.message);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('오류', 'WOD 목록을 불러올 수 없습니다');
    } finally {
      isLoading.value = false;
    }
  }

  // ===== WOD 선택 =====

  /// WOD 선택 (라디오 버튼)
  void selectWod(int wodId) {
    selectedWodId.value = wodId;
  }

  /// 선택 확인 (최종 모달 호출)
  void confirmSelection() {
    if (selectedWodId.value == null) {
      Get.snackbar('안내', 'WOD를 선택해주세요');
      return;
    }
    _showFinalConfirmModal();
  }

  /// 최종 확인 모달
  void _showFinalConfirmModal() {
    Get.defaultDialog(
      title: 'WOD 선택 확인',
      middleText: '한 번 선택하면 변경할 수 없습니다. 이 WOD를 선택하시겠습니까?',
      textConfirm: '선택',
      textCancel: '취소',
      onConfirm: () {
        Get.back();
        _performSelection();
      },
    );
  }

  /// 실제 선택 처리
  Future<void> _performSelection() async {
    try {
      isLoading.value = true;
      await _wodRepository.selectWod(
        wodId: selectedWodId.value!,
        boxId: boxId,
        date: date,
      );
      Get.snackbar('선택 완료', 'WOD를 선택했습니다');
      Get.back(result: true);
    } on NetworkException catch (e) {
      Get.snackbar('네트워크 오류', e.message);
    } on AuthException catch (e) {
      Get.snackbar('인증 오류', e.message);
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('오류', 'WOD 선택에 실패했습니다');
    } finally {
      isLoading.value = false;
    }
  }
}
