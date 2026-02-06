import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import '../../../data/repositories/box_repository.dart';
import '../../../routes/app_routes.dart';

/// 박스 생성 컨트롤러
///
/// 새 박스 생성 폼의 입력 관리 및 유효성 검증을 처리합니다.
class BoxCreateController extends GetxController {
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

  late final BoxRepository _boxRepository;

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
    _boxRepository = Get.find<BoxRepository>();

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
  Future<void> create() async {
    if (!canSubmit.value) return;

    try {
      isLoading.value = true;
      final request = CreateBoxRequest(
        name: nameController.text.trim(),
        region: regionController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
      );
      await _boxRepository.createBox(request);
      Get.snackbar('생성 완료', '박스가 생성되었습니다');
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

  // ===== 정리 =====

  @override
  void onClose() {
    nameController.dispose();
    regionController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
