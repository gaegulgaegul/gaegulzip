import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchLink 데모
///
/// 기본 링크, 방문한 링크, 아이콘 포함, 비활성 상태를 확인할 수 있습니다.
class LinkDemo extends StatefulWidget {
  const LinkDemo({super.key});

  @override
  State<LinkDemo> createState() => _LinkDemoState();
}

class _LinkDemoState extends State<LinkDemo> {
  bool _isVisited = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildGallerySection(),
        ],
      ),
    );
  }

  /// 실시간 프리뷰
  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '실시간 프리뷰',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),
        Center(
          child: SketchLink(
            text: '스케치 링크 클릭',
            isVisited: _isVisited,
            onTap: () => setState(() => _isVisited = true),
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingMd),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('방문 상태: '),
              SketchSwitch(
                value: _isVisited,
                onChanged: (v) => setState(() => _isVisited = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 변형 갤러리
  Widget _buildGallerySection() {
    return Column(
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

        // 기본 링크
        const Text('기본 링크', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchLink(text: '자세히 보기', onTap: () {}),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 방문한 링크
        const Text('방문한 링크', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchLink(text: '이미 본 문서', isVisited: true, onTap: () {}),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 아이콘 포함 (trailing)
        const Text('아이콘 포함 (trailing)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchLink(
          text: '외부 링크',
          icon: Icons.open_in_new,
          onTap: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 아이콘 포함 (leading)
        const Text('아이콘 포함 (leading)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchLink(
          text: '다운로드',
          icon: Icons.download,
          iconPosition: SketchLinkIconPosition.leading,
          onTap: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비활성화
        const Text('비활성화', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchLink(text: '클릭 불가', onTap: null),
      ],
    );
  }
}
