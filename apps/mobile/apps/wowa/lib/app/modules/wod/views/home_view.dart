import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/models/wod/wod_model.dart';
import '../../../data/models/wod/movement.dart';
import '../controllers/home_controller.dart';

/// WOD 홈 화면
///
/// 날짜별 WOD를 표시하고, 등록/상세/선택 화면으로 이동합니다.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              // 현재 박스 헤더
              SliverToBoxAdapter(child: _buildCurrentBoxHeader()),
              // 날짜 헤더
              SliverToBoxAdapter(child: _buildDateHeader(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // WOD 카드 섹션
              SliverToBoxAdapter(child: _buildWodSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // 빠른 액션 버튼
              SliverToBoxAdapter(child: _buildQuickActions()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  /// 현재 박스 헤더
  Widget _buildCurrentBoxHeader() {
    return Obx(() {
      final box = controller.currentBox.value;
      if (box == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, size: 20, color: SketchDesignTokens.base700),
            const SizedBox(width: 8),
            Text(
              box.name,
              style: const TextStyle(
                fontSize: SketchDesignTokens.fontSizeLg,
                fontFamily: SketchDesignTokens.fontFamilyHand,
                color: SketchDesignTokens.base900,
              ),
            ),
            const Spacer(),
            Text(
              box.region,
              style: const TextStyle(color: SketchDesignTokens.base700, fontSize: SketchDesignTokens.fontSizeSm),
            ),
          ],
        ),
      );
    });
  }

  /// 날짜 헤더 (좌우 화살표 + DatePicker)
  Widget _buildDateHeader(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SketchIconButton(
                icon: Icons.chevron_left,
                tooltip: '이전 날짜',
                onPressed: controller.previousDay,
              ),
              GestureDetector(
                onTap: () => controller.openDatePicker(context),
                child: Column(
                  children: [
                    Text(
                      controller.formattedDate,
                      style: const TextStyle(
                        fontSize: SketchDesignTokens.fontSizeXl,
                        fontFamily: SketchDesignTokens.fontFamilyHand,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${controller.dayOfWeek}요일${controller.isToday ? ' (오늘)' : ''}',
                      style: const TextStyle(color: SketchDesignTokens.base700, fontSize: SketchDesignTokens.fontSizeSm),
                    ),
                  ],
                ),
              ),
              SketchIconButton(
                icon: Icons.chevron_right,
                tooltip: '다음 날짜',
                onPressed: controller.isToday ? null : controller.nextDay,
              ),
            ],
          ),
        ));
  }

  /// WOD 카드 섹션
  Widget _buildWodSection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: SketchProgressBar(
              style: SketchProgressBarStyle.circular,
              value: null,
              size: 48,
            ),
          ),
        );
      }

      if (!controller.hasWod.value) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.event_busy, size: 48, color: SketchDesignTokens.base300),
                const SizedBox(height: 12),
                const Text('WOD가 아직 등록되지 않았습니다'),
                const SizedBox(height: 16),
                SketchButton(
                  text: 'WOD 등록하기',
                  style: SketchButtonStyle.primary,
                  onPressed: controller.goToRegister,
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Base WOD 카드
            if (controller.baseWod.value != null)
              _buildWodCard(controller.baseWod.value!, isBase: true),

            // Personal WODs
            if (controller.personalWods.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Personal WODs (${controller.personalWods.length})',
                style: const TextStyle(
                    color: SketchDesignTokens.base700,
                    fontSize: SketchDesignTokens.fontSizeSm,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...controller.personalWods
                  .map((wod) => _buildWodCard(wod, isBase: false)),
            ],
          ],
        ),
      );
    });
  }

  /// WOD 카드
  Widget _buildWodCard(WodModel wod, {required bool isBase}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => controller.goToDetail(wod),
        child: SketchCard(
          header: Row(
            children: [
              if (isBase)
                const SketchChip(
                  label: 'BASE',
                  selected: true,
                  fillColor: SketchDesignTokens.info,
                ),
              if (!isBase)
                const SketchChip(
                  label: 'PERSONAL',
                  selected: true,
                  fillColor: SketchDesignTokens.warning,
                ),
              const SizedBox(width: 8),
              Text(wod.programData.type,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...wod.programData.movements.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${m.name}${_formatMovementDetails(m)}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  /// 운동 상세 포맷팅
  String _formatMovementDetails(Movement m) {
    final parts = <String>[];
    if (m.reps != null) parts.add('${m.reps}reps');
    if (m.weight != null) parts.add('${m.weight}${m.unit ?? 'kg'}');
    return parts.isEmpty ? '' : ' (${parts.join(', ')})';
  }

  /// 빠른 액션 버튼
  Widget _buildQuickActions() {
    return Obx(() {
      if (!controller.hasWod.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
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
        ),
      );
    });
  }
}
