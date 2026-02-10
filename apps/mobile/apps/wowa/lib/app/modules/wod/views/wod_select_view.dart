import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/models/wod/wod_model.dart';
import '../../../data/models/wod/movement.dart';
import '../controllers/wod_select_controller.dart';

/// WOD 선택 화면
///
/// 라디오 버튼으로 WOD를 선택하고, 최종 확인 후 서버에 전송합니다.
class WodSelectView extends GetView<WodSelectController> {
  const WodSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SketchAppBar(title: 'WOD 선택'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: SketchProgressBar(
                    style: SketchProgressBarStyle.circular,
                    value: null,
                    size: 48));
          }

          return Column(
            children: [
              // 경고 배너
              _buildWarningBanner(),

              // WOD 옵션 리스트
              Expanded(child: _buildWodOptionsList()),

              // 확인 버튼
              _buildConfirmButton(),
            ],
          );
        }),
      ),
    );
  }

  /// 경고 배너
  Widget _buildWarningBanner() {
    return Padding(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: SketchCard(
        borderColor: SketchDesignTokens.warning,
        strokeWidth: SketchDesignTokens.strokeBold,
        fillColor: const Color(0xFFFFF8E1),
        body: const Row(
          children: [
            Icon(Icons.warning_amber, color: SketchDesignTokens.warning, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '한 번 선택하면 변경할 수 없습니다. 신중하게 선택해주세요.',
                style: TextStyle(fontSize: SketchDesignTokens.fontSizeSm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// WOD 옵션 리스트
  Widget _buildWodOptionsList() {
    return Obx(() {
      final allWods = <WodModel>[];
      if (controller.baseWod.value != null) {
        allWods.add(controller.baseWod.value!);
      }
      allWods.addAll(controller.personalWods);

      if (allWods.isEmpty) {
        return const Center(child: Text('선택할 수 있는 WOD가 없습니다'));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allWods.length,
        itemBuilder: (context, index) {
          final wod = allWods[index];
          final isBase = wod.isBase;
          return _buildWodOptionCard(wod, isBase: isBase);
        },
      );
    });
  }

  /// WOD 옵션 카드 (라디오 버튼)
  Widget _buildWodOptionCard(WodModel wod, {required bool isBase}) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => controller.selectWod(wod.id),
          child: SketchCard(
            header: Row(
              children: [
                // 라디오 버튼
                SketchRadio<int?>(
                  value: wod.id,
                  groupValue: controller.selectedWodId.value,
                  onChanged: (_) => controller.selectWod(wod.id),
                ),
                const SizedBox(width: 8),
                SketchChip(
                  label: isBase ? 'BASE' : 'PERSONAL',
                  selected: true,
                  fillColor: isBase
                      ? SketchDesignTokens.info
                      : SketchDesignTokens.warning,
                ),
                const SizedBox(width: 8),
                Text(wod.programData.type,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (wod.selectedCount != null && wod.selectedCount! > 0) ...[
                  const Spacer(),
                  Text('${wod.selectedCount}명 선택',
                      style: const TextStyle(color: SketchDesignTokens.base500, fontSize: SketchDesignTokens.fontSizeXs)),
                ],
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...wod.programData.movements.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                          '• ${m.name}${_formatMovementDetails(m)}'),
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 확인 버튼
  Widget _buildConfirmButton() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: SketchButton(
              text: 'WOD 선택 확인',
              style: SketchButtonStyle.primary,
              size: SketchButtonSize.large,
              onPressed: controller.selectedWodId.value != null
                  ? controller.confirmSelection
                  : null,
            ),
          ),
        ));
  }

  /// 운동 상세 포맷팅
  String _formatMovementDetails(Movement m) {
    final parts = <String>[];
    if (m.reps != null) parts.add('${m.reps}reps');
    if (m.weight != null) parts.add('${m.weight}${m.unit ?? 'kg'}');
    return parts.isEmpty ? '' : ' (${parts.join(', ')})';
  }
}
