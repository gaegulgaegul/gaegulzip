import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../data/models/box/box_model.dart';

/// 박스 검색 컨트롤러
///
/// 통합 키워드 검색, 300ms debounce, 5가지 UI 상태 지원
class BoxSearchController extends GetxController {
  // ===== Repository 의존성 =====
  late final BoxRepository _repository;

  // ===== 반응형 상태 (.obs) =====

  /// 통합 검색 키워드 (박스 이름 또는 지역)
  final keyword = ''.obs;

  /// 검색 중 로딩 상태
  final isLoading = false.obs;

  /// 검색 결과 목록
  final searchResults = <BoxModel>[].obs;

  /// 현재 소속 박스 (단일 박스 정책)
  final currentBox = Rxn<BoxModel>();

  /// API 에러 메시지
  final errorMessage = ''.obs;

  // ===== 비반응형 상태 =====

  /// 검색 입력 컨트롤러
  late final TextEditingController searchController;

  /// Debounce Worker
  Worker? _debounceWorker;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();

    // Repository 의존성 주입
    _repository = Get.find<BoxRepository>();

    // TextEditingController 초기화
    searchController = TextEditingController();

    // Debounce 설정 (300ms)
    _debounceWorker = debounce(
      keyword,
      (_) => searchBoxes(),
      time: const Duration(milliseconds: 300),
    );

    // TextEditingController 리스너 (keyword 동기화)
    searchController.addListener(() {
      keyword.value = searchController.text;
    });
  }

  // ===== 메서드 =====

  /// 박스 검색 (API 호출)
  ///
  /// 300ms debounce 적용, 검색어가 비어있으면 목록 초기화
  Future<void> searchBoxes() async {
    // 1. 검색어 빈 값 체크 (비어있으면 목록 초기화)
    if (keyword.value.trim().isEmpty) {
      searchResults.clear();
      errorMessage.value = '';
      return;
    }

    // 2. 로딩 시작
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 3. API 호출 (Repository)
      final boxes = await _repository.searchBoxes(keyword.value.trim());

      // 4. 성공: searchResults 업데이트
      searchResults.value = boxes;
    } on NetworkException catch (e) {
      // 5. 네트워크 에러: errorMessage 업데이트
      errorMessage.value = e.message;
      searchResults.clear();
      Get.snackbar(
        '오류',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SketchDesignTokens.error.withValues(alpha: 0.1),
        colorText: SketchDesignTokens.error,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // 6. 기타 에러
      errorMessage.value = '일시적인 문제가 발생했습니다';
      searchResults.clear();
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SketchDesignTokens.error.withValues(alpha: 0.1),
        colorText: SketchDesignTokens.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      // 7. 로딩 종료
      isLoading.value = false;
    }
  }

  /// 검색어 지우기
  void clearSearch() {
    searchController.clear();
    keyword.value = '';
    searchResults.clear();
    errorMessage.value = '';
  }

  /// 박스 가입 (단일 박스 정책)
  ///
  /// 현재 박스에 이미 소속되어 있으면 확인 모달 표시
  Future<void> joinBox(int boxId) async {
    // 1. 현재 박스에 이미 소속되어 있으면 확인 모달 표시
    if (currentBox.value != null) {
      final confirm = await SketchModal.show<bool>(
        context: Get.context!,
        title: '박스 변경',
        child: Text(
          '현재 "${currentBox.value?.name}"에서 탈퇴하고 새 박스에 가입합니다. 계속하시겠습니까?',
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            color: SketchDesignTokens.base900,
          ),
        ),
        actions: [
          SketchButton(
            text: '취소',
            onPressed: () => Navigator.of(Get.context!).pop(false),
            style: SketchButtonStyle.outline,
          ),
          SketchButton(
            text: '변경',
            onPressed: () => Navigator.of(Get.context!).pop(true),
            style: SketchButtonStyle.primary,
          ),
        ],
        barrierDismissible: true,
      );

      if (confirm != true) return;
    }

    try {
      // 2. 박스 가입 (기존 박스 자동 탈퇴)
      await _repository.joinBox(boxId);

      // 3. 성공: currentBox 업데이트
      final joinedBox = searchResults.firstWhere(
        (box) => box.id == boxId,
        orElse: () => throw Exception('가입한 박스를 찾을 수 없습니다'),
      );
      currentBox.value = joinedBox;

      // 4. 성공 스낵바
      Get.snackbar(
        '가입 완료',
        '박스에 가입되었습니다',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SketchDesignTokens.success.withValues(alpha: 0.1),
        colorText: SketchDesignTokens.success,
        duration: const Duration(seconds: 2),
      );
    } on BusinessException catch (e) {
      // 비즈니스 로직 에러 (409 등)
      SketchModal.show(
        context: Get.context!,
        title: '오류',
        child: Text(
          e.message,
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            color: SketchDesignTokens.base900,
          ),
        ),
        actions: [
          SketchButton(
            text: '확인',
            onPressed: () => Navigator.of(Get.context!).pop(),
            style: SketchButtonStyle.primary,
          ),
        ],
      );
    } on NetworkException catch (e) {
      Get.snackbar(
        '오류',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SketchDesignTokens.error.withValues(alpha: 0.1),
        colorText: SketchDesignTokens.error,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '박스 가입에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SketchDesignTokens.error.withValues(alpha: 0.1),
        colorText: SketchDesignTokens.error,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ===== 정리 =====

  @override
  void onClose() {
    searchController.dispose();
    _debounceWorker?.dispose();
    super.onClose();
  }
}
