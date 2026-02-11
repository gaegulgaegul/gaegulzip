import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/qna_controller.dart';

/// QnA 질문 작성 화면
///
/// 질문 제목과 본문을 입력하고 제출할 수 있습니다.
class QnaSubmitView extends GetView<QnaController> {
  /// 본문 글자 수 경고 임계값
  static const int bodyWarningThreshold = 60000;

  /// 본문 글자 수 오류 임계값
  static const int bodyErrorThreshold = 65000;

  /// 본문 최대 글자 수
  static const int bodyMaxLength = 65536;

  const QnaSubmitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// AppBar 빌드
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      title: const Text('질문하기'),
      centerTitle: true,
      elevation: 0,
    );
  }

  /// Body 빌드
  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          // 스크롤 가능한 입력 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // 안내 문구
                  const Text(
                    '궁금한 점을 남겨주세요. 빠르게 답변드리겠습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: SketchDesignTokens.base700,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 제목 입력 필드
                  _buildTitleInput(),

                  const SizedBox(height: 24),

                  // 본문 입력 필드
                  _buildBodyInput(),

                  const SizedBox(height: 12),

                  // 글자 수 카운터
                  _buildCharCounter(),
                ],
              ),
            ),
          ),

          // 하단 고정 제출 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  /// 제목 입력 필드 빌드
  Widget _buildTitleInput() {
    return Obx(() => SketchInput(
          label: '제목 *',
          hint: '질문 제목을 입력하세요 (최대 256자)',
          controller: controller.titleController,
          maxLength: 256,
          errorText: controller.titleError.value.isEmpty
              ? null
              : controller.titleError.value,
        ));
  }

  /// 본문 입력 필드 빌드
  Widget _buildBodyInput() {
    return Obx(() => SketchInput(
          label: '질문 내용 *',
          hint: '구체적으로 작성할수록 빠른 답변을 받을 수 있습니다',
          controller: controller.bodyController,
          maxLength: bodyMaxLength,
          minLines: 8,
          maxLines: 20,
          errorText: controller.bodyError.value.isEmpty
              ? null
              : controller.bodyError.value,
        ));
  }

  /// 글자 수 카운터 빌드
  Widget _buildCharCounter() {
    return Obx(() {
      final count = controller.bodyLength.value;
      final isWarning = count > bodyWarningThreshold;
      final isError = count > bodyErrorThreshold;

      return Align(
        alignment: Alignment.centerRight,
        child: Text(
          '본문: $count / $bodyMaxLength자',
          style: TextStyle(
            fontSize: 12,
            color: isError
                ? SketchDesignTokens.error
                : isWarning
                    ? SketchDesignTokens.warning
                    : SketchDesignTokens.base500,
            fontWeight: isWarning ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      );
    });
  }

  /// 제출 버튼 빌드
  Widget _buildSubmitButton() {
    return Obx(() => SketchButton(
          text: '등록',
          size: SketchButtonSize.large,
          style: SketchButtonStyle.primary,
          width: double.infinity,
          isLoading: controller.isSubmitting.value,
          onPressed:
              controller.isSubmitEnabled ? controller.submitQuestion : null,
        ));
  }
}
