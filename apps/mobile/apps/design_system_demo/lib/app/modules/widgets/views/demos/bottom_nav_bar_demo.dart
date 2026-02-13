import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchBottomNavigationBar 데모
///
/// 기본 네비게이션, 배지 포함, 라벨 모드를 확인할 수 있습니다.
class BottomNavBarDemo extends StatefulWidget {
  const BottomNavBarDemo({super.key});

  @override
  State<BottomNavBarDemo> createState() => _BottomNavBarDemoState();
}

class _BottomNavBarDemoState extends State<BottomNavBarDemo> {
  int _basicIndex = 0;
  int _badgeIndex = 0;
  int _labelIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '변형 갤러리',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          // 기본
          const Text('기본 네비게이션', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchBottomNavigationBar(
            items: const [
              SketchNavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
              SketchNavItem(label: '검색', icon: Icons.search_outlined),
              SketchNavItem(label: '프로필', icon: Icons.person_outline, activeIcon: Icons.person),
            ],
            currentIndex: _basicIndex,
            onTap: (i) => setState(() => _basicIndex = i),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 배지 포함
          const Text('배지 포함', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchBottomNavigationBar(
            items: const [
              SketchNavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
              SketchNavItem(label: '알림', icon: Icons.notifications_outlined, activeIcon: Icons.notifications, badgeCount: 3),
              SketchNavItem(label: '채팅', icon: Icons.chat_outlined, activeIcon: Icons.chat, badgeCount: 12),
              SketchNavItem(label: '프로필', icon: Icons.person_outline, activeIcon: Icons.person),
            ],
            currentIndex: _badgeIndex,
            onTap: (i) => setState(() => _badgeIndex = i),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 항상 라벨 표시
          const Text('항상 라벨 표시', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchBottomNavigationBar(
            items: const [
              SketchNavItem(label: 'Home', icon: Icons.home_outlined),
              SketchNavItem(label: '검색', icon: Icons.search_outlined),
              SketchNavItem(label: '프로필', icon: Icons.person_outline),
            ],
            currentIndex: _labelIndex,
            labelBehavior: SketchNavLabelBehavior.alwaysShow,
            onTap: (i) => setState(() => _labelIndex = i),
          ),
        ],
      ),
    );
  }
}
