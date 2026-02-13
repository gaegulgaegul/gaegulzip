import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../enums/sketch_tab_indicator_style.dart';
import '../painters/sketch_line_painter.dart';
import '../painters/sketch_tab_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 스케치 스타일 탭 바 (2~5개 탭 지원)
///
/// Frame0 스타일의 손으로 그린 미학을 가진 탭 네비게이션 바를 생성함.
/// 각 탭이 폴더 탭(folder tab) 형태의 카드형 디자인으로 렌더링됨.
///
/// **기본 사용법:**
/// ```dart
/// SketchTabBar(
///   tabs: [
///     SketchTab(label: 'Home', icon: Icons.home),
///     SketchTab(label: '알림', icon: Icons.notifications),
///   ],
///   currentIndex: 0,
///   onTap: (index) => setState(() => selectedIndex = index),
/// )
/// ```
///
/// **배지와 함께:**
/// ```dart
/// SketchTabBar(
///   tabs: [
///     SketchTab(label: 'Home', icon: Icons.home),
///     SketchTab(label: '알림', icon: Icons.notifications, badgeCount: 5),
///     SketchTab(label: '설정', icon: Icons.settings),
///   ],
///   currentIndex: selectedIndex,
///   onTap: (index) => controller.changeTab(index),
/// )
/// ```
///
/// **GetX 반응형 상태:**
/// ```dart
/// // Controller
/// final selectedTab = 0.obs;
///
/// // View
/// Obx(() => SketchTabBar(
///   tabs: tabs,
///   currentIndex: selectedTab.value,
///   onTap: (index) => selectedTab.value = index,
/// ))
/// ```
class SketchTabBar extends StatelessWidget {
  /// 탭 항목 목록 (2~5개).
  final List<SketchTab> tabs;

  /// 현재 선택된 탭 인덱스.
  final int currentIndex;

  /// 탭 선택 시 콜백.
  final ValueChanged<int> onTap;

  /// 인디케이터 스타일 (deprecated - 카드형 탭 디자인으로 변경되어 더 이상 사용되지 않음).
  @Deprecated('카드형 탭 디자인으로 변경되어 더 이상 사용되지 않습니다')
  final SketchTabIndicatorStyle indicatorStyle;

  /// 탭 바 높이 (null이면 자동 결정: 아이콘 유무에 따라 44/56).
  final double? height;

  /// 선택된 탭 텍스트/아이콘 색상 (null이면 textColor 사용).
  final Color? selectedColor;

  /// 비선택 탭 텍스트/아이콘 색상 (null이면 textSecondaryColor 사용).
  final Color? unselectedColor;

  /// 테두리 및 하단 기준선 표시 여부.
  final bool showBorder;

  const SketchTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    @Deprecated('카드형 탭 디자인으로 변경되어 더 이상 사용되지 않습니다')
    this.indicatorStyle = SketchTabIndicatorStyle.underline,
    this.height,
    this.selectedColor,
    this.unselectedColor,
    this.showBorder = true,
  })  : assert(
          tabs.length >= 2 && tabs.length <= 5,
          'TabBar는 2~5개 탭만 지원합니다',
        ),
        assert(
          currentIndex >= 0 && currentIndex < tabs.length,
          'currentIndex($currentIndex)가 tabs 범위(0~${tabs.length - 1})를 벗어남',
        );

  /// 탭에 아이콘이 있는지 확인하여 높이 결정.
  double _effectiveHeight() {
    if (height != null) return height!;
    final hasIcon = tabs.any((tab) => tab.icon != null);
    return hasIcon ? 56.0 : 44.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SketchThemeExtension.of(context);
    final tabHeight = _effectiveHeight();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 탭 Row
        SizedBox(
          height: tabHeight,
          child: Row(
            children: List.generate(tabs.length, (index) {
              return Expanded(
                child: _buildTabItem(
                  index: index,
                  tab: tabs[index],
                  isSelected: index == currentIndex,
                  theme: theme,
                  tabHeight: tabHeight,
                ),
              );
            }),
          ),
        ),
        // 하단 기준선
        if (showBorder)
          LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                painter: SketchLinePainter(
                  start: Offset.zero,
                  end: Offset(constraints.maxWidth, 0),
                  color: theme.borderColor,
                  strokeWidth: SketchDesignTokens.strokeBold,
                  roughness: theme.roughness,
                  seed: tabs.length * 100,
                ),
                child: SizedBox(
                  height: SketchDesignTokens.strokeBold,
                  width: double.infinity,
                ),
              );
            },
          ),
      ],
    );
  }

  /// 개별 탭 항목을 빌드함.
  Widget _buildTabItem({
    required int index,
    required SketchTab tab,
    required bool isSelected,
    required SketchThemeExtension theme,
    required double tabHeight,
  }) {
    // 색상 결정
    final fillColor = isSelected ? theme.fillColor : theme.surfaceColor;
    final textIconColor = isSelected
        ? (selectedColor ?? theme.textColor)
        : (unselectedColor ?? theme.textSecondaryColor);

    return GestureDetector(
      onTap: () => onTap(index),
      child: Semantics(
        label: '${tab.label} 탭',
        selected: isSelected,
        button: true,
        child: CustomPaint(
          painter: SketchTabPainter(
            fillColor: fillColor,
            borderColor: showBorder ? theme.borderColor : Colors.transparent,
            strokeWidth: SketchDesignTokens.strokeBold,
            roughness: theme.roughness,
            seed: index * 42,
            enableNoise: true,
            topRadius: 12.0,
            isSelected: isSelected,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: _buildTabContent(tab, textIconColor, theme, isSelected: isSelected),
          ),
        ),
      ),
    );
  }

  /// 탭 컨텐츠를 빌드함 (아이콘 + 배지 + 라벨).
  Widget _buildTabContent(
    SketchTab tab,
    Color color,
    SketchThemeExtension theme, {
    required bool isSelected,
  }) {
    final hasIcon = tabs.any((t) => t.icon != null);
    final fontSize = hasIcon ? 13.0 : 14.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (tab.icon != null) ...[
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(tab.icon, size: 22, color: color),
              if (tab.badgeCount != null && tab.badgeCount! > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: _buildBadge(tab.badgeCount!, theme),
                ),
            ],
          ),
          const SizedBox(height: 2),
        ],
        Text(
          tab.label,
          style: TextStyle(
            fontFamily: SketchDesignTokens.fontFamilyHand,
            fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
            fontSize: fontSize,
            color: color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  /// 배지를 빌드함.
  Widget _buildBadge(int count, SketchThemeExtension theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      decoration: BoxDecoration(
        color: theme.badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.fillColor,
          width: 1.0,
        ),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyMono,
          fontSize: 10,
          color: theme.badgeTextColor,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 탭 항목 데이터 클래스.
///
/// 각 탭의 라벨, 아이콘, 배지 정보를 포함함.
class SketchTab {
  /// 탭 라벨 (필수).
  final String label;

  /// 탭 아이콘 (선택 사항).
  final IconData? icon;

  /// 배지 카운트 (선택 사항, 예: 알림 개수).
  ///
  /// 0보다 큰 값일 때만 배지가 표시됨.
  final int? badgeCount;

  const SketchTab({
    required this.label,
    this.icon,
    this.badgeCount,
  });
}
