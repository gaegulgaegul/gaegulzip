import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../enums/sketch_tab_indicator_style.dart';
import '../theme/sketch_theme_extension.dart';

/// 스케치 스타일 탭 바 (2~5개 탭 지원)
///
/// Frame0 스타일의 손으로 그린 미학을 가진 탭 네비게이션 바를 생성함.
/// 탭 선택, 인디케이터 스타일, 배지 카운트를 지원함.
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
/// **인디케이터 스타일:**
/// ```dart
/// SketchTabBar(
///   tabs: tabs,
///   currentIndex: 0,
///   indicatorStyle: SketchTabIndicatorStyle.filled,
///   onTap: (index) {},
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

  /// 인디케이터 스타일 (underline/filled).
  final SketchTabIndicatorStyle indicatorStyle;

  /// 탭 바 높이.
  final double height;

  /// 선택된 탭 색상 (null이면 accentPrimary 사용).
  final Color? selectedColor;

  /// 비선택 탭 색상 (null이면 base700 사용).
  final Color? unselectedColor;

  /// 테두리 표시 여부.
  final bool showBorder;

  const SketchTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.indicatorStyle = SketchTabIndicatorStyle.underline,
    this.height = 48.0,
    this.selectedColor,
    this.unselectedColor,
    this.showBorder = true,
  }) : assert(
          tabs.length >= 2 && tabs.length <= 5,
          'TabBar는 2~5개 탭만 지원합니다',
        ),
        assert(
          currentIndex >= 0 && currentIndex < tabs.length,
          'currentIndex($currentIndex)가 tabs 범위(0~${tabs.length - 1})를 벗어남',
        );

  @override
  Widget build(BuildContext context) {
    final theme = SketchThemeExtension.of(context);
    final effectiveSelectedColor = selectedColor ?? SketchDesignTokens.accentPrimary;
    final effectiveUnselectedColor = unselectedColor ?? theme.textSecondaryColor;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.fillColor,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: theme.borderColor,
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: _buildTabItem(
              tab: tab,
              isSelected: isSelected,
              selectedColor: effectiveSelectedColor,
              unselectedColor: effectiveUnselectedColor,
              badgeBorderColor: theme.fillColor,
              onTap: () => onTap(index),
            ),
          );
        }),
      ),
    );
  }

  /// 개별 탭 항목을 빌드함.
  Widget _buildTabItem({
    required SketchTab tab,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required Color badgeBorderColor,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: '${tab.label} 탭',
        selected: isSelected,
        button: true,
        child: Container(
          color: Colors.transparent, // 터치 영역 확보
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 + 배지
              if (tab.icon != null)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(tab.icon, size: 24, color: color),
                    if (tab.badgeCount != null && tab.badgeCount! > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: _buildBadge(tab.badgeCount!, badgeBorderColor),
                      ),
                  ],
                ),
              if (tab.icon != null) const SizedBox(height: 4),

              // 라벨
              Text(
                tab.label,
                style: TextStyle(
                  fontFamily: SketchDesignTokens.fontFamilyHand,
                  fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                  fontSize: 14,
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),

              // 인디케이터
              _buildIndicator(
                isSelected: isSelected,
                color: selectedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 선택 상태 인디케이터를 빌드함.
  Widget _buildIndicator({
    required bool isSelected,
    required Color color,
  }) {
    if (!isSelected) {
      return const SizedBox(height: 3);
    }

    if (indicatorStyle == SketchTabIndicatorStyle.underline) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 3.0,
        width: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1.5),
        ),
      );
    } else {
      // filled 스타일은 향후 구현 예정
      return const SizedBox(height: 3);
    }
  }

  /// 배지를 빌드함.
  Widget _buildBadge(int count, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      decoration: BoxDecoration(
        color: SketchDesignTokens.error,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: backgroundColor,
          width: 1.0,
        ),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyMono,
          fontSize: 10,
          color: SketchDesignTokens.white,
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
