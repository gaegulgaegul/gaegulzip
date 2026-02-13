import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchAppBar 데모
///
/// 기본, 액션 버튼, 커스텀 leading, 그림자 ON/OFF를 확인할 수 있습니다.
class AppBarDemo extends StatefulWidget {
  const AppBarDemo({super.key});

  @override
  State<AppBarDemo> createState() => _AppBarDemoState();
}

class _AppBarDemoState extends State<AppBarDemo> {
  bool _showShadow = true;
  bool _showSketchBorder = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 그림자 토글
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('그림자 표시', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
              SketchSwitch(
                value: _showShadow,
                onChanged: (v) => setState(() => _showShadow = v),
              ),
            ],
          ),
          const SizedBox(height: SketchDesignTokens.spacingMd),

          // 스케치 테두리 토글
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('스케치 테두리', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
              SketchSwitch(
                value: _showSketchBorder,
                onChanged: (v) => setState(() => _showSketchBorder = v),
              ),
            ],
          ),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),

          const Text(
            '변형 갤러리',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          // 기본
          const Text('기본', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SizedBox(
            height: 56,
            child: SketchAppBar(
              title: '홈',
              showShadow: _showShadow,
              showSketchBorder: _showSketchBorder,
              leading: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 액션 버튼 포함
          const Text('액션 버튼 포함', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SizedBox(
            height: 56,
            child: SketchAppBar(
              title: '설정',
              showShadow: _showShadow,
              showSketchBorder: _showSketchBorder,
              leading: const SizedBox.shrink(),
              actions: [
                SketchIconButton(
                  icon: Icons.search,
                  showBorder: false,
                  onPressed: () {},
                ),
                SketchIconButton(
                  icon: Icons.more_vert,
                  showBorder: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 커스텀 leading
          const Text('커스텀 leading', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SizedBox(
            height: 56,
            child: SketchAppBar(
              title: '메뉴',
              showShadow: _showShadow,
              showSketchBorder: _showSketchBorder,
              leading: SketchIconButton(
                icon: Icons.menu,
                showBorder: false,
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 그림자 없음
          const Text('그림자 없음', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SizedBox(
            height: 56,
            child: SketchAppBar(
              title: '플랫 스타일',
              showShadow: false,
              showSketchBorder: _showSketchBorder,
              leading: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 스케치 + 그림자 동시 적용
          const Text('스케치 + 그림자 조합', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          SizedBox(
            height: 56,
            child: SketchAppBar(
              title: '조합 스타일',
              showShadow: true,
              showSketchBorder: true,
              leading: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
