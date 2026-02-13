import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchImagePlaceholder 데모
///
/// 프리셋 크기, 커스텀 크기, 아이콘 포함 변형을 확인할 수 있습니다.
class ImagePlaceholderDemo extends StatelessWidget {
  const ImagePlaceholderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPresetSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildVariantSection(),
        ],
      ),
    );
  }

  /// 프리셋 크기
  Widget _buildPresetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '프리셋 크기',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),
        Wrap(
          spacing: SketchDesignTokens.spacingMd,
          runSpacing: SketchDesignTokens.spacingMd,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Column(
              children: const [
                SketchImagePlaceholder.xs(),
                SizedBox(height: 4),
                Text('XS', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: const [
                SketchImagePlaceholder.sm(),
                SizedBox(height: 4),
                Text('SM', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: const [
                SketchImagePlaceholder.md(),
                SizedBox(height: 4),
                Text('MD', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),
        const SketchImagePlaceholder.lg(),
        const SizedBox(height: 4),
        const Text('LG', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 변형
  Widget _buildVariantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '변형',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 아이콘 포함
        const Text('아이콘 포함', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchImagePlaceholder(
          width: 120,
          height: 120,
          centerIcon: Icons.image_outlined,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 테두리 없음
        const Text('테두리 없음', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchImagePlaceholder(
          width: 120,
          height: 120,
          showBorder: false,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 커스텀 크기 (와이드)
        const Text('와이드 (300x100)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchImagePlaceholder(
          width: 300,
          height: 100,
          centerIcon: Icons.panorama_outlined,
        ),
      ],
    );
  }
}
