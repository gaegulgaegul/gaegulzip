import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/models/wod/wod_model.dart';
import '../../../data/models/wod/movement.dart';
import '../controllers/wod_detail_controller.dart';

/// WOD 상세/비교 화면
///
/// Base WOD와 Personal WOD를 비교하고,
/// 제안 검토, WOD 선택, 추가 등록으로 이동합니다.
class WodDetailView extends GetView<WodDetailController> {
  const WodDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SketchAppBar(title: 'WOD 상세'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: SketchProgressBar(
                    style: SketchProgressBarStyle.circular,
                    value: null,
                    size: 48));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Base WOD 카드
                if (controller.baseWod.value != null)
                  _buildBaseWodCard(controller.baseWod.value!),

                const SizedBox(height: 20),

                // 제안 검토 버튼 (Base 등록자에게만)
                if (controller.hasPendingProposal.value)
                  _buildProposalBanner(),

                // Personal WODs 섹션
                if (controller.personalWods.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildPersonalWodsSection(),
                ],

                const SizedBox(height: 24),

                // 액션 버튼들
                _buildActionButtons(),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Base WOD 카드
  Widget _buildBaseWodCard(WodModel wod) {
    return SketchCard(
      header: Row(
        children: [
          const SketchChip(
            label: 'BASE WOD',
            selected: true,
            fillColor: SketchDesignTokens.info,
          ),
          const SizedBox(width: 8),
          Text(wod.programData.type,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
      body: _buildWodContent(wod),
    );
  }

  /// WOD 내용 위젯
  Widget _buildWodContent(WodModel wod) {
    final pd = wod.programData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임캡/라운드 정보
        if (pd.timeCap != null || pd.rounds != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              [
                if (pd.timeCap != null) '${pd.timeCap}분',
                if (pd.rounds != null) '${pd.rounds}라운드',
              ].join(' / '),
              style: const TextStyle(color: SketchDesignTokens.base700),
            ),
          ),

        // 운동 목록
        ...pd.movements.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${m.name}${_formatMovementDetails(m)}'),
            )),

        // 자유 텍스트
        if (wod.rawText != null && wod.rawText!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(wod.rawText!, style: const TextStyle(color: SketchDesignTokens.base700)),
        ],
      ],
    );
  }

  /// 제안 검토 배너
  Widget _buildProposalBanner() {
    return GestureDetector(
      onTap: controller.goToReview,
      child: SketchCard(
        body: Row(
          children: [
            const Icon(Icons.notification_important, color: SketchDesignTokens.warning),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('변경 제안이 있습니다',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('탭하여 검토하세요',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  /// Personal WODs 섹션
  Widget _buildPersonalWodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal WODs (${controller.personalWods.length})',
          style: const TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontFamily: SketchDesignTokens.fontFamilyHand,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...controller.personalWods.map((wod) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SketchCard(
                header: Row(
                  children: [
                    const SketchChip(
                      label: 'PERSONAL',
                      selected: true,
                      fillColor: SketchDesignTokens.warning,
                    ),
                    if (wod.registeredBy != null) ...[
                      const SizedBox(width: 8),
                      Text(wod.registeredBy!,
                          style: const TextStyle(
                              color: SketchDesignTokens.base700, fontSize: SketchDesignTokens.fontSizeXs)),
                    ],
                  ],
                ),
                body: _buildWodContent(wod),
              ),
            )),
      ],
    );
  }

  /// 액션 버튼
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SketchButton(
            text: 'WOD 등록',
            style: SketchButtonStyle.outline,
            onPressed: controller.goToRegister,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SketchButton(
            text: 'WOD 선택',
            style: SketchButtonStyle.primary,
            onPressed: controller.goToSelect,
          ),
        ),
      ],
    );
  }

  /// 운동 상세 포맷팅
  String _formatMovementDetails(Movement m) {
    final parts = <String>[];
    if (m.reps != null) parts.add('${m.reps}reps');
    if (m.weight != null) parts.add('${m.weight}${m.unit ?? 'kg'}');
    return parts.isEmpty ? '' : ' (${parts.join(', ')})';
  }
}
