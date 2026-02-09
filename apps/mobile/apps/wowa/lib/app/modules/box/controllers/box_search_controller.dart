import 'package:get/get.dart';
import 'package:core/core.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/box/box_model.dart';

/// 박스 검색 컨트롤러
///
/// 이름/지역 기반 박스 검색 및 가입을 처리합니다.
/// debounce 300ms 적용으로 불필요한 API 호출을 방지합니다.
class BoxSearchController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// 로딩 상태
  final isLoading = false.obs;

  /// 검색 결과 목록
  final searchResults = <BoxModel>[].obs;

  /// 현재 소속 박스 (null이면 미가입)
  final currentBox = Rxn<BoxModel>();

  /// 이름 검색어
  final nameQuery = ''.obs;

  /// 지역 검색어
  final regionQuery = ''.obs;

  // ===== 비반응형 상태 (의존성) =====

  late final BoxRepository _boxRepository;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();
    _boxRepository = Get.find<BoxRepository>();
    _loadCurrentBox();

    // 검색어 변경 시 debounce 300ms
    debounce(nameQuery, (_) => search(), time: const Duration(milliseconds: 300));
    debounce(regionQuery, (_) => search(), time: const Duration(milliseconds: 300));
  }

  /// 현재 소속 박스 로드
  Future<void> _loadCurrentBox() async {
    try {
      currentBox.value = await _boxRepository.getCurrentBox();
    } on NetworkException catch (e) {
      Get.snackbar('오류', e.message);
    } catch (e) {
      // 현재 박스 로드 실패는 무시 (검색은 계속 가능)
    }
  }

  // ===== 검색 =====

  /// 박스 검색 실행
  Future<void> search() async {
    if (nameQuery.value.isEmpty && regionQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      final results = await _boxRepository.searchBoxes(
        name: nameQuery.value.isNotEmpty ? nameQuery.value : null,
        region: regionQuery.value.isNotEmpty ? regionQuery.value : null,
      );
      searchResults.assignAll(results);
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

  // ===== 박스 가입 =====

  /// 박스 가입 처리 (Single Box Policy)
  Future<void> joinBox(int boxId) async {
    if (currentBox.value != null) {
      _showBoxChangeConfirmModal(boxId);
      return;
    }
    await _performJoinBox(boxId);
  }

  /// 박스 변경 확인 모달
  void _showBoxChangeConfirmModal(int newBoxId) {
    Get.defaultDialog(
      title: '박스 변경',
      middleText: '현재 "${currentBox.value?.name}"에서 탈퇴하고 새 박스에 가입합니다. 계속하시겠습니까?',
      textConfirm: '변경',
      textCancel: '취소',
      onConfirm: () {
        Get.back();
        _performJoinBox(newBoxId);
      },
    );
  }

  /// 실제 가입 처리
  Future<void> _performJoinBox(int boxId) async {
    try {
      isLoading.value = true;
      await _boxRepository.joinBox(boxId);
      Get.snackbar('가입 완료', '박스에 가입되었습니다');
      Get.offAllNamed(Routes.HOME);
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
}
