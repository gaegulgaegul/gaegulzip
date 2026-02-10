import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../enums/sketch_nav_label_behavior.dart';
import '../theme/sketch_theme_extension.dart';

/// 스케치 스타일 하단 네비게이션 바 (2~5개 항목 권장)
///
/// Frame0 스타일의 손으로 그린 미학을 가진 하단 네비게이션을 생성함.
/// 항목 선택, 라벨 표시 모드, 배지 카운트, 활성 아이콘을 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchBottomNavigationBar(
///   items: [
///     SketchNavItem(label: 'Home', icon: Icons.home_outlined),
///     SketchNavItem(label: '알림', icon: Icons.notifications_outlined),
///     SketchNavItem(label: '프로필', icon: Icons.person_outline),
///   ],
///   currentIndex: 0,
///   onTap: (index) => setState(() => selectedIndex = index),
/// )
/// ```
///
/// **활성 아이콘과 배지:**
/// ```dart
/// SketchBottomNavigationBar(
///   items: [
///     SketchNavItem(
///       label: 'Home',
///       icon: Icons.home_outlined,
///       activeIcon: Icons.home,
///     ),
///     SketchNavItem(
///       label: '알림',
///       icon: Icons.notifications_outlined,
///       activeIcon: Icons.notifications,
///       badgeCount: 3,
///     ),
///     SketchNavItem(
///       label: '프로필',
///       icon: Icons.person_outline,
///       activeIcon: Icons.person,
///     ),
///   ],
///   currentIndex: selectedIndex,
///   onTap: (index) => controller.changePage(index),
/// )
/// ```
///
/// **라벨 표시 모드:**
/// ```dart
/// SketchBottomNavigationBar(
///   items: items,
///   currentIndex: 0,
///   labelBehavior: SketchNavLabelBehavior.onlyShowSelected, // 선택된 항목만
///   onTap: (index) {},
/// )
/// ```
///
/// **GetX 반응형 상태:**
/// ```dart
/// // Controller
/// final currentIndex = 0.obs;
///
/// // View
/// Obx(() => SketchBottomNavigationBar(
///   items: items,
///   currentIndex: currentIndex.value,
///   onTap: (index) => currentIndex.value = index,
/// ))
/// ```
class SketchBottomNavigationBar extends StatelessWidget {
  /// 네비게이션 항목 목록 (2~5개 권장).
  final List<SketchNavItem> items;

  /// 현재 선택된 항목 인덱스.
  final int currentIndex;

  /// 항목 선택 시 콜백.
  final ValueChanged<int> onTap;

  /// 네비게이션 바 높이.
  final double height;

  /// 선택된 항목 색상 (null이면 accentPrimary 사용).
  final Color? selectedColor;

  /// 비선택 항목 색상 (null이면 base700 사용).
  final Color? unselectedColor;

  /// 라벨 표시 모드.
  final SketchNavLabelBehavior labelBehavior;

  const SketchBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 64.0,
    this.selectedColor,
    this.unselectedColor,
    this.labelBehavior = SketchNavLabelBehavior.onlyShowSelected,
  }) : assert(
          items.length >= 2 && items.length <= 5,
          '네비게이션 바는 2~5개 항목을 권장합니다',
        );

  @override
  Widget build(BuildContext context) {
    final theme = SketchThemeExtension.of(context);
    final effectiveSelectedColor = selectedColor ?? SketchDesignTokens.accentPrimary;
    final effectiveUnselectedColor = unselectedColor ?? SketchDesignTokens.base700;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.fillColor,
        border: Border(
          top: BorderSide(
            color: theme.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return _buildNavItem(
            item: item,
            isSelected: isSelected,
            selectedColor: effectiveSelectedColor,
            unselectedColor: effectiveUnselectedColor,
            showLabel: _shouldShowLabel(index),
            onTap: () => onTap(index),
          );
        }),
      ),
    );
  }

  /// 라벨을 표시해야 하는지 판단함.
  bool _shouldShowLabel(int index) {
    switch (labelBehavior) {
      case SketchNavLabelBehavior.alwaysShow:
        return true;
      case SketchNavLabelBehavior.onlyShowSelected:
        return index == currentIndex;
      case SketchNavLabelBehavior.neverShow:
        return false;
    }
  }

  /// 개별 네비게이션 항목을 빌드함.
  Widget _buildNavItem({
    required SketchNavItem item,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required bool showLabel,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? selectedColor : unselectedColor;
    final icon = isSelected && item.activeIcon != null ? item.activeIcon! : item.icon;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          label: '${item.label} 메뉴',
          selected: isSelected,
          button: true,
          child: Container(
            color: Colors.transparent, // 터치 영역 확보
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘 + 배지
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: isSelected ? 28 : 24,
                      color: color,
                    ),
                    if (item.badgeCount != null && item.badgeCount! > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: _buildBadge(item.badgeCount!),
                      ),
                  ],
                ),
                if (showLabel) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: SketchDesignTokens.fontFamilyHand,
                      fontSize: 12,
                      color: color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 배지를 빌드함.
  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      decoration: BoxDecoration(
        color: SketchDesignTokens.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: SketchDesignTokens.white,
          width: 1.5,
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

/// 네비게이션 항목 데이터 클래스.
///
/// 각 항목의 라벨, 아이콘, 활성 아이콘, 배지 정보를 포함함.
class SketchNavItem {
  /// 항목 라벨 (필수).
  final String label;

  /// 항목 아이콘 (필수).
  final IconData icon;

  /// 선택 시 사용할 아이콘 (선택 사항).
  ///
  /// null이면 기본 [icon]을 사용함.
  final IconData? activeIcon;

  /// 배지 카운트 (선택 사항, 예: 알림 개수).
  ///
  /// 0보다 큰 값일 때만 배지가 표시됨.
  final int? badgeCount;

  const SketchNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badgeCount,
  });
}
