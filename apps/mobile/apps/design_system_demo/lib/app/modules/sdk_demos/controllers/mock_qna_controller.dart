import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qna/qna.dart';

/// QnA 모의 컨트롤러
///
/// QnaController를 상속하여 서버 연동 없이 UI 동작을 검증합니다.
/// onInit()을 오버라이드하여 QnaRepository 의존성을 제거합니다.
class MockQnaController extends QnaController {
  @override
  // ignore: must_call_super
  void onInit() {
    // 부모의 onInit()을 호출하지 않음 (QnaRepository Get.find 회피)
    // TextEditingController 리스너만 수동 등록
    bodyController.addListener(() {
      bodyText.value = bodyController.text;
      bodyLength.value = bodyController.text.length;
      if (bodyError.value.isNotEmpty) {
        validateBody();
      }
    });

    titleController.addListener(() {
      titleText.value = titleController.text;
      if (titleError.value.isNotEmpty) {
        validateTitle();
      }
    });
  }

  /// 질문 제출 모의 처리
  ///
  /// 실제 API 호출 대신 2초 딜레이 후 성공 스낵바를 표시합니다.
  @override
  Future<void> submitQuestion() async {
    // 중복 제출 방지
    if (isSubmitting.value) return;

    errorMessage.value = '';

    // 입력 검증
    validateTitle();
    validateBody();
    if (titleError.value.isNotEmpty || bodyError.value.isNotEmpty) {
      return;
    }

    try {
      isSubmitting.value = true;

      // 모의 딜레이 (2초)
      await Future.delayed(const Duration(seconds: 2));

      // 성공 스낵바
      Get.snackbar(
        '성공',
        '질문이 제출되었습니다. (Mock)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 입력 필드 초기화
      titleController.clear();
      bodyController.clear();
      titleText.value = '';
      bodyText.value = '';
      bodyLength.value = 0;
    } catch (e) {
      // 에러 스낵바
      Get.snackbar(
        '오류',
        '네트워크 연결을 확인해주세요',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
