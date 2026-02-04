import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../repositories/qna_repository.dart';

/// QnA 화면 컨트롤러
///
/// 질문 작성 및 제출 로직을 관리합니다.
class QnaController extends GetxController {
  // ===== 의존성 =====

  late final QnaRepository _repository;

  // ===== TextEditingController =====

  /// 제목 입력 컨트롤러
  final titleController = TextEditingController();

  /// 본문 입력 컨트롤러
  final bodyController = TextEditingController();

  // ===== 반응형 상태 (.obs) =====

  /// 제출 중 여부
  final isSubmitting = false.obs;

  /// 제목 에러 메시지
  final titleError = ''.obs;

  /// 본문 에러 메시지
  final bodyError = ''.obs;

  /// 본문 글자 수
  final bodyLength = 0.obs;

  /// 에러 메시지 (API 에러)
  final errorMessage = ''.obs;

  // ===== Getter =====

  /// 제출 버튼 활성화 조건
  ///
  /// - 제목이 비어있지 않음
  /// - 본문이 비어있지 않음
  /// - 제목 길이가 256자 이하
  /// - 본문 길이가 65536자 이하
  /// - 제출 중이 아님
  bool get isSubmitEnabled =>
      titleController.text.trim().isNotEmpty &&
      bodyController.text.trim().isNotEmpty &&
      titleController.text.length <= 256 &&
      bodyController.text.length <= 65536 &&
      !isSubmitting.value;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();

    // Repository 주입
    _repository = Get.find<QnaRepository>();

    // 본문 입력 리스너 (글자 수 추적, 에러 재검증)
    bodyController.addListener(() {
      bodyLength.value = bodyController.text.length;
      if (bodyError.value.isNotEmpty) {
        validateBody();
      }
    });

    // 제목 입력 리스너 (에러 재검증)
    titleController.addListener(() {
      if (titleError.value.isNotEmpty) {
        validateTitle();
      }
    });
  }

  @override
  void onClose() {
    // TextEditingController 정리
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  // ===== 입력 검증 =====

  /// 제목 입력 검증
  ///
  /// - 빈 값: "제목을 입력해주세요"
  /// - 256자 초과: "제목은 256자 이내로 입력해주세요"
  /// - 정상: titleError.value = ''
  void validateTitle() {
    if (titleController.text.trim().isEmpty) {
      titleError.value = '제목을 입력해주세요';
    } else if (titleController.text.length > 256) {
      titleError.value = '제목은 256자 이내로 입력해주세요';
    } else {
      titleError.value = '';
    }
  }

  /// 본문 입력 검증
  ///
  /// - 빈 값: "질문 내용을 입력해주세요"
  /// - 65536자 초과: "본문은 65536자 이내로 입력해주세요"
  /// - 정상: bodyError.value = ''
  void validateBody() {
    if (bodyController.text.trim().isEmpty) {
      bodyError.value = '질문 내용을 입력해주세요';
    } else if (bodyController.text.length > 65536) {
      bodyError.value = '본문은 65536자 이내로 입력해주세요';
    } else {
      bodyError.value = '';
    }
  }

  // ===== 질문 제출 =====

  /// 질문 제출 처리
  ///
  /// 1. 입력 검증
  /// 2. API 호출
  /// 3. 성공 시: 성공 모달 표시 → 이전 화면 복귀
  /// 4. 실패 시: 실패 모달 표시 → 재시도 옵션
  Future<void> submitQuestion() async {
    // 1. 입력 검증
    validateTitle();
    validateBody();
    if (titleError.value.isNotEmpty || bodyError.value.isNotEmpty) {
      return;
    }

    try {
      // 2. 로딩 시작
      isSubmitting.value = true;
      errorMessage.value = '';

      // 3. API 호출
      await _repository.submitQuestion(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
      );

      // 4. 성공 - 성공 모달 표시
      _showSuccessModal();
    } on NetworkException catch (e) {
      // 5. 네트워크 오류 - 실패 모달 표시
      errorMessage.value = e.message;
      _showErrorModal();
    } catch (e) {
      // 6. 기타 오류
      errorMessage.value = '알 수 없는 오류가 발생했습니다';
      _showErrorModal();
    } finally {
      // 7. 로딩 종료
      isSubmitting.value = false;
    }
  }

  // ===== UI 피드백 =====

  /// 성공 모달 표시
  ///
  /// "확인" 버튼 탭 시:
  /// - 모달 닫기 (Get.back)
  /// - QnA 화면 닫기 (Get.back)
  void _showSuccessModal() {
    SketchModal.show(
      context: Get.context!,
      title: '질문이 등록되었습니다',
      barrierDismissible: false,
      width: 340,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 시일 내에 답변드리겠습니다.',
            style: TextStyle(
              fontSize: 14,
              color: SketchDesignTokens.base700,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        SketchButton(
          text: '확인',
          style: SketchButtonStyle.primary,
          onPressed: () {
            Navigator.of(Get.context!).pop(); // 모달 닫기
            Get.back(); // QnA 화면 닫기
          },
        ),
      ],
    );
  }

  /// 실패 모달 표시
  ///
  /// "닫기" 버튼: 모달만 닫기
  /// "재시도" 버튼: 모달 닫기 → submitQuestion() 재호출
  void _showErrorModal() {
    SketchModal.show(
      context: Get.context!,
      title: '질문 등록에 실패했습니다',
      barrierDismissible: false,
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            errorMessage.value,
            style: const TextStyle(
              fontSize: 14,
              color: SketchDesignTokens.error,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        SketchButton(
          text: '닫기',
          style: SketchButtonStyle.outline,
          onPressed: () => Navigator.of(Get.context!).pop(),
        ),
        SketchButton(
          text: '재시도',
          style: SketchButtonStyle.primary,
          onPressed: () {
            Navigator.of(Get.context!).pop(); // 모달 닫기
            submitQuestion(); // 재시도
          },
        ),
      ],
    );
  }
}
