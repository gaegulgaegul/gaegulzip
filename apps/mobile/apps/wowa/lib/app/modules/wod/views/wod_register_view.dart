import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../controllers/wod_register_controller.dart';

/// WOD 등록 화면
///
/// 운동 타입 선택, 운동 리스트 관리, WOD 등록을 처리합니다.
class WodRegisterView extends GetView<WodRegisterController> {
  const WodRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SketchAppBar(title: 'WOD 등록'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WOD 타입 선택
                    _buildWodTypeSelector(),
                    const SizedBox(height: 20),

                    // 타입별 설정 (타임캡, 라운드)
                    _buildTypeSettings(),
                    const SizedBox(height: 20),

                    // 운동 리스트 또는 자유 텍스트
                    Obx(() => controller.selectedType.value == 'CUSTOM'
                        ? _buildRawTextInput()
                        : _buildMovementList()),
                  ],
                ),
              ),
            ),

            // 등록 버튼
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// WOD 타입 선택 칩
  Widget _buildWodTypeSelector() {
    const types = ['AMRAP', 'FOR_TIME', 'EMOM', 'CUSTOM'];
    const labels = {
      'AMRAP': 'AMRAP',
      'FOR_TIME': 'For Time',
      'EMOM': 'EMOM',
      'CUSTOM': '자유 입력',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('운동 타입',
            style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase, fontFamily: SketchDesignTokens.fontFamilyHand, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              children: types.map((type) {
                return SketchChip(
                  label: labels[type] ?? type,
                  selected: controller.selectedType.value == type,
                  onSelected: (_) => controller.selectType(type),
                );
              }).toList(),
            )),
      ],
    );
  }

  /// 타입별 추가 설정 (타임캡, 라운드)
  Widget _buildTypeSettings() {
    return Obx(() {
      final type = controller.selectedType.value;
      if (type.isEmpty || type == 'CUSTOM') return const SizedBox.shrink();

      return Row(
        children: [
          if (type == 'AMRAP' || type == 'EMOM')
            Expanded(
              child: SketchInput(
                label: '타임캡 (분)',
                hint: '20',
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    controller.timeCap.value = int.tryParse(v),
              ),
            ),
          if (type == 'FOR_TIME') ...[
            Expanded(
              child: SketchInput(
                label: '타임캡 (분, 선택)',
                hint: '20',
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    controller.timeCap.value = int.tryParse(v),
              ),
            ),
          ],
          if (type == 'FOR_TIME' || type == 'EMOM') ...[
            const SizedBox(width: 12),
            Expanded(
              child: SketchInput(
                label: '라운드',
                hint: '5',
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    controller.rounds.value = int.tryParse(v),
              ),
            ),
          ],
        ],
      );
    });
  }

  /// 자유 텍스트 입력 (CUSTOM 타입)
  Widget _buildRawTextInput() {
    return SketchInput(
      label: 'WOD 내용',
      hint: '오늘의 WOD를 자유롭게 입력하세요',
      maxLines: 8,
      onChanged: (v) => controller.rawText.value = v,
    );
  }

  /// 운동 리스트 (비-CUSTOM 타입)
  Widget _buildMovementList() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('운동 목록',
                    style:
                        TextStyle(fontSize: SketchDesignTokens.fontSizeBase, fontFamily: SketchDesignTokens.fontFamilyHand, fontWeight: FontWeight.bold)),
                SketchButton(
                  text: '+ 운동 추가',
                  style: SketchButtonStyle.outline,
                  size: SketchButtonSize.small,
                  onPressed: controller.addMovement,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.movements.length,
              onReorder: controller.reorderMovements,
              itemBuilder: (context, index) {
                return _buildMovementCard(index, key: ValueKey(index));
              },
            ),
          ],
        ));
  }

  /// 운동 카드
  Widget _buildMovementCard(int index, {Key? key}) {
    final m = controller.movements[index];
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12),
      child: SketchCard(
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.drag_handle, size: 20),
                const SizedBox(width: 4),
                Text('운동 ${index + 1}'),
              ],
            ),
            if (controller.movements.length > 1)
              GestureDetector(
                onTap: () => controller.removeMovement(index),
                child: const Icon(Icons.close, size: 18, color: SketchDesignTokens.error),
              ),
          ],
        ),
        body: Column(
          children: [
            SketchInput(
              hint: '운동 이름 (예: Back Squat)',
              controller: m.nameController,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SketchInput(
                    hint: '횟수',
                    controller: m.repsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SketchInput(
                    hint: '무게',
                    controller: m.weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: SketchInput(
                    hint: '단위',
                    controller: m.unitController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 등록 버튼
  Widget _buildSubmitButton() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: SketchButton(
              text: controller.isLoading.value ? '등록 중...' : 'WOD 등록',
              style: SketchButtonStyle.primary,
              size: SketchButtonSize.large,
              onPressed: controller.canSubmit.value && !controller.isLoading.value
                  ? controller.submit
                  : null,
            ),
          ),
        ));
  }
}
