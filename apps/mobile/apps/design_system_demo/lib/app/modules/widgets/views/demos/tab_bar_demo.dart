import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchTabBar 데모
///
/// 기본 탭, 아이콘 탭, 배지 포함 탭을 확인할 수 있습니다.
class TabBarDemo extends StatefulWidget {
  const TabBarDemo({super.key});

  @override
  State<TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<TabBarDemo> {
  int _basicIndex = 0;
  int _iconIndex = 0;
  int _badgeIndex = 0;
  int _noBorderIndex = 0;

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

          // 기본 탭 (텍스트 전용)
          const Text('기본 탭 (텍스트 전용)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchTabBar(
            tabs: const [
              SketchTab(label: '전체'),
              SketchTab(label: '인기'),
              SketchTab(label: '최신'),
            ],
            currentIndex: _basicIndex,
            onTap: (i) => setState(() => _basicIndex = i),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 아이콘 탭
          const Text('아이콘 탭', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchTabBar(
            tabs: const [
              SketchTab(label: 'Home', icon: Icons.home),
              SketchTab(label: '검색', icon: Icons.search),
              SketchTab(label: '설정', icon: Icons.settings),
            ],
            currentIndex: _iconIndex,
            onTap: (i) => setState(() => _iconIndex = i),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 배지 포함
          const Text('배지 포함', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchTabBar(
            tabs: const [
              SketchTab(label: 'Home', icon: Icons.home),
              SketchTab(label: '알림', icon: Icons.notifications, badgeCount: 5),
              SketchTab(label: '채팅', icon: Icons.chat, badgeCount: 99),
            ],
            currentIndex: _badgeIndex,
            onTap: (i) => setState(() => _badgeIndex = i),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 테두리 없음
          const Text('테두리 없음 (showBorder: false)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchTabBar(
            tabs: const [
              SketchTab(label: '탭 1', icon: Icons.star),
              SketchTab(label: '탭 2', icon: Icons.favorite),
              SketchTab(label: '탭 3', icon: Icons.bookmark),
            ],
            currentIndex: _noBorderIndex,
            onTap: (i) => setState(() => _noBorderIndex = i),
            showBorder: false,
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 5개 탭 (최대)
          const Text('5개 탭 (최대)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SketchTabBar(
            tabs: const [
              SketchTab(label: '1'),
              SketchTab(label: '2'),
              SketchTab(label: '3'),
              SketchTab(label: '4'),
              SketchTab(label: '5'),
            ],
            currentIndex: 0,
            onTap: (_) {},
          ),
        ],
      ),
    );
  }
}
