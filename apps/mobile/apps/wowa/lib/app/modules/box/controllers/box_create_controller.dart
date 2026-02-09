import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/box/create_box_request.dart';

/// 박스 생성 컨트롤러
///
/// 새 박스 생성 폼의 입력 관리 및 유효성 검증 처리
class BoxCreateController extends GetxController {
  // ===== Repository 의존성 =====
  late final BoxRepository _repository;

  // ===== 반응형 상태 (.obs) =====

  /// 로딩 상태
  final isLoading = false.obs;

  /// 이름 유효성 에러 메시지
  final nameError = RxnString();

  /// 지역 유효성 에러 메시지
  final regionError = RxnString();

  /// 제출 가능 여부
  final canSubmit = false.obs;

  // ===== 비반응형 상태 =====

  /// 이름 입력
  final nameController = TextEditingController();

  /// 지역 입력
  final regionController = TextEditingController();

  /// 설명 입력
  final descriptionController = TextEditingController();

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();

    // Repository 의존성 주입
    _repository = Get.find<BoxRepository>();

    // 입력 리스너 (실시간 유효성 검증)
    nameController.addListener(_validateInputs);
    regionController.addListener(_validateInputs);
  }

  // ===== 유효성 검증 =====

  /// 입력값 유효성 검증
  void _validateInputs() {
    final name = nameController.text.trim();
    final region = regionController.text.trim();

    // 이름 검증 (2~50자)
    if (name.isEmpty) {
      nameError.value = null;
    } else if (name.length < 2) {
      nameError.value = '박스 이름은 2자 이상이어야 합니다';
    } else if (name.length > 50) {
      nameError.value = '박스 이름은 50자 이하여야 합니다';
    } else {
      nameError.value = null;
    }

    // 지역 검증 (2~100자)
    if (region.isEmpty) {
      regionError.value = null;
    } else if (region.length < 2) {
      regionError.value = '지역은 2자 이상이어야 합니다';
    } else if (region.length > 100) {
      regionError.value = '지역은 100자 이하여야 합니다';
    } else {
      regionError.value = null;
    }

    // 제출 가능 여부
    canSubmit.value = name.length >= 2 &&
        name.length <= 50 &&
        region.length >= 2 &&
        region.length <= 100 &&
        nameError.value == null &&
        regionError.value == null;
  }

  // ===== 박스 생성 =====

  /// 박스 생성 요청
  Future<void> createBox() async {
    // 1. 유효성 재검증
    _validateInputs();

    if (!canSubmit.value) return;

    // 2. 로딩 시작
    isLoading.value = true;

    try {
      // 3. API 호출 (Repository)
      await _repository.createBox(
        name: nameController.text.trim(),
        region: regionController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );

      // 4. 성공: 스낵바 + 홈 이동
      Get.snackbar(
        '박스 생성 완료',
        '박스가 생성되었습니다',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SketchDesignTokens.success.withValues(alpha: 0.1),
        colorText: SketchDesignTokens.success,
        duration: const Duration(seconds: 2),
      );

      // 5. 홈으로 이동 (스택 초기화)
      Get.offAllNamed(Routes.HOME);
    } on NetworkException catch (e) {
      // 6. 네트워크 에러: 모달 표시
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
            text: '닫기',
            onPressed: () => Navigator.of(Get.context!).pop(),
            style: SketchButtonStyle.outline,
          ),
          SketchButton(
            text: '재시도',
            onPressed: () {
              Navigator.of(Get.context!).pop();
              createBox();
            },
            style: SketchButtonStyle.primary,
          ),
        ],
        barrierDismissible: false,
      );
    } catch (e) {
      // 7. 기타 에러
      SketchModal.show(
        context: Get.context!,
        title: '오류',
        child: const Text('박스 생성에 실패했습니다'),
        actions: [
          SketchButton(
            text: '확인',
            onPressed: () => Navigator.of(Get.context!).pop(),
            style: SketchButtonStyle.primary,
          ),
        ],
      );
    } finally {
      // 8. 로딩 종료
      isLoading.value = false;
    }
  }

  // ===== 정리 =====

  @override
  void onClose() {
    nameController.dispose();
    regionController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
