import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:design_system/design_system.dart';
import '../controllers/proposal_review_controller.dart';

/// 변경 제안 검토 화면
///
/// Before(현재 Base) / After(제안된 WOD)를 비교하고 승인/거부합니다.
class ProposalReviewView extends GetView<ProposalReviewController> {
  const ProposalReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('제안 검토')),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제안자 정보
                      if (controller.proposer.value.isNotEmpty)
                        _buildProposerInfo(),

                      const SizedBox(height: 16),

                      // Before: 현재 Base WOD
                      _buildComparisonCard(
                        title: 'Before (현재 Base)',
                        wod: controller.currentBase.value,
                        color: Colors.red[50]!,
                        labelColor: Colors.red[100]!,
                      ),

                      const SizedBox(height: 16),

                      // After: 제안된 WOD
                      _buildComparisonCard(
                        title: 'After (제안)',
                        wod: controller.proposedWod.value,
                        color: Colors.green[50]!,
                        labelColor: Colors.green[100]!,
                      ),
                    ],
                  ),
                ),
              ),

              // 승인/거부 버튼
              _buildActionButtons(),
            ],
          );
        }),
      ),
    );
  }

  /// 제안자 정보
  Widget _buildProposerInfo() {
    return Obx(() => Row(
          children: [
            const Icon(Icons.person, size: 18),
            const SizedBox(width: 4),
            Text('제안자: ${controller.proposer.value}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ));
  }

  /// Before/After 비교 카드
  Widget _buildComparisonCard({
    required String title,
    required WodModel? wod,
    required Color color,
    required Color labelColor,
  }) {
    if (wod == null) {
      return SketchCard(
        header: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        body: const Text('WOD 정보를 불러올 수 없습니다'),
      );
    }

    final pd = wod.programData;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SketchCard(
        header: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: labelColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(pd.type,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pd.timeCap != null || pd.rounds != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  [
                    if (pd.timeCap != null) '${pd.timeCap}분',
                    if (pd.rounds != null) '${pd.rounds}라운드',
                  ].join(' / '),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ...pd.movements.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${m.name}${_formatMovementDetails(m)}'),
                )),
          ],
        ),
      ),
    );
  }

  /// 승인/거부 버튼
  Widget _buildActionButtons() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SketchButton(
                  text: '거부',
                  style: SketchButtonStyle.outline,
                  size: SketchButtonSize.large,
                  onPressed:
                      controller.isLoading.value ? null : controller.reject,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SketchButton(
                  text: '승인',
                  style: SketchButtonStyle.primary,
                  size: SketchButtonSize.large,
                  onPressed:
                      controller.isLoading.value ? null : controller.approve,
                ),
              ),
            ],
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
