import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// SketchChip 데모
///
/// selected, icon, onDeleted 속성을 실시간으로 조절할 수 있습니다.
class ChipDemo extends StatefulWidget {
  const ChipDemo({super.key});

  @override
  State<ChipDemo> createState() => _ChipDemoState();
}

class _ChipDemoState extends State<ChipDemo> {
  // 조절 가능한 속성들
  bool _selected = false;
  bool _showIcon = false;
  bool _showDelete = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPreviewSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildControlsSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildGallerySection(),
        ],
      ),
    );
  }

  /// 실시간 프리뷰 섹션
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
          child: SketchChip(
            label: 'Chip',
            selected: _selected,
            icon: _showIcon ? const Icon(LucideIcons.star, size: 16) : null,
            onSelected: (value) => setState(() => _selected = value),
            onDeleted: _showDelete
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('칩 삭제됨!')),
                    );
                  }
                : null,
          ),
        ),
      ],
    );
  }

  /// 속성 조절 패널
  Widget _buildControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '속성 조절',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Selected', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _selected,
              onChanged: (value) => setState(() => _selected = value),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show Icon', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showIcon,
              onChanged: (value) => setState(() => _showIcon = value),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show Delete Button', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showDelete,
              onChanged: (value) => setState(() => _showDelete = value),
            ),
          ],
        ),
      ],
    );
  }

  /// 변형 갤러리 섹션
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

        // 기본
        const Text('기본', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Chip 1',
              selected: false,
              onSelected: (_) {},
            ),
            SketchChip(
              label: 'Chip 2',
              selected: true,
              onSelected: (_) {},
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 아이콘 포함
        const Text('아이콘 포함', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Favorite',
              icon: const Icon(LucideIcons.heart, size: 16),
              selected: false,
              onSelected: (_) {},
            ),
            SketchChip(
              label: 'Star',
              icon: const Icon(LucideIcons.star, size: 16),
              selected: true,
              onSelected: (_) {},
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 삭제 가능
        const Text('삭제 가능', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Tag 1',
              onDeleted: () {},
            ),
            SketchChip(
              label: 'Tag 2',
              icon: const Icon(LucideIcons.tag, size: 16),
              onDeleted: () {},
            ),
          ],
        ),
      ],
    );
  }
}
