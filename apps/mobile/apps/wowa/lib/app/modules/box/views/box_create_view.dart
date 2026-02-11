import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../controllers/box_create_controller.dart';

/// 박스 생성 화면
///
/// 이름, 지역, 설명을 입력하여 새 박스를 생성합니다.
class BoxCreateView extends GetView<BoxCreateController> {
  const BoxCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildNameInput(),
                      const SizedBox(height: 16),
                      _buildRegionInput(),
                      const SizedBox(height: 16),
                      _buildDescriptionInput(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return SketchAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      title: '새 박스 만들기',
    );
  }

  /// 박스 이름 입력
  Widget _buildNameInput() {
    return Obx(
      () => SketchInput(
        controller: controller.nameController,
        label: '박스 이름',
        hint: '크로스핏 박스 이름',
        errorText: controller.nameError.value,
        maxLength: 50,
      ),
    );
  }

  /// 지역 입력
  Widget _buildRegionInput() {
    return Obx(
      () => SketchInput(
        controller: controller.regionController,
        label: '지역',
        hint: '서울 강남구',
        errorText: controller.regionError.value,
        maxLength: 100,
      ),
    );
  }

  /// 설명 입력 (선택)
  Widget _buildDescriptionInput() {
    return SketchInput(
      controller: controller.descriptionController,
      label: '설명 (선택)',
      hint: '박스에 대한 간단한 설명',
      maxLines: 3,
      maxLength: 1000,
    );
  }

  /// 생성 버튼
  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: SketchButton(
          text: '박스 생성',
          style: SketchButtonStyle.primary,
          size: SketchButtonSize.large,
          onPressed: controller.canSubmit.value && !controller.isLoading.value
              ? controller.createBox
              : null,
          isLoading: controller.isLoading.value,
        ),
      ),
    );
  }
}
