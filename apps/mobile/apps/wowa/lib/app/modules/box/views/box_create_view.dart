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
      appBar: AppBar(title: const Text('새 박스 만들기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 이름 입력
                      Obx(() => SketchInput(
                            label: '박스 이름',
                            hint: '크로스핏 박스 이름',
                            controller: controller.nameController,
                            errorText: controller.nameError.value,
                          )),
                      const SizedBox(height: 16),

                      // 지역 입력
                      Obx(() => SketchInput(
                            label: '지역',
                            hint: '서울 강남구',
                            controller: controller.regionController,
                            errorText: controller.regionError.value,
                          )),
                      const SizedBox(height: 16),

                      // 설명 입력 (선택)
                      SketchInput(
                        label: '설명 (선택)',
                        hint: '박스에 대한 간단한 설명',
                        controller: controller.descriptionController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 생성 버튼
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: SketchButton(
                      text: '박스 생성',
                      style: SketchButtonStyle.primary,
                      size: SketchButtonSize.large,
                      onPressed: controller.canSubmit.value && !controller.isLoading.value
                          ? controller.create
                          : null,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
