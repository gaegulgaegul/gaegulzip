import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:design_system/design_system.dart';
import '../controllers/wod_select_controller.dart';

/// WOD 선택 화면
///
/// 라디오 버튼으로 WOD를 선택하고, 최종 확인 후 서버에 전송합니다.
class WodSelectView extends GetView<WodSelectController> {
  const WodSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WOD 선택')),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '한 번 선택하면 변경할 수 없습니다. 신중하게 선택해주세요.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
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
      final isSelected = controller.selectedWodId.value == wod.id;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => controller.selectWod(wod.id),
          child: SketchCard(
            header: Row(
              children: [
                // 라디오 버튼
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isBase ? Colors.blue[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isBase ? 'BASE' : 'PERSONAL',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(wod.programData.type,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (wod.selectedCount != null && wod.selectedCount! > 0) ...[
                  const Spacer(),
                  Text('${wod.selectedCount}명 선택',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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
