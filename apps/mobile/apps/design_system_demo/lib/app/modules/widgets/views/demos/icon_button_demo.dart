import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// SketchIconButton 데모
///
/// icon, tooltip, badgeCount, shape 속성을 실시간으로 조절할 수 있습니다.
class IconButtonDemo extends StatefulWidget {
  const IconButtonDemo({super.key});

  @override
  State<IconButtonDemo> createState() => _IconButtonDemoState();
}

class _IconButtonDemoState extends State<IconButtonDemo> {
  // 조절 가능한 속성들
  IconData _selectedIcon = LucideIcons.heart;
  SketchIconButtonShape _shape = SketchIconButtonShape.circle;
  int _badgeCount = 0;

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
          child: SketchIconButton(
            icon: _selectedIcon,
            shape: _shape,
            badgeCount: _badgeCount > 0 ? _badgeCount : null,
            tooltip: '아이콘 버튼',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('아이콘 버튼 클릭됨!')),
              );
            },
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

        // Icon 선택
        const Text('Icon', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Heart',
              selected: _selectedIcon == LucideIcons.heart,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIcon = LucideIcons.heart);
              },
            ),
            SketchChip(
              label: 'Star',
              selected: _selectedIcon == LucideIcons.star,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIcon = LucideIcons.star);
              },
            ),
            SketchChip(
              label: 'Bell',
              selected: _selectedIcon == LucideIcons.bell,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIcon = LucideIcons.bell);
              },
            ),
            SketchChip(
              label: 'Settings',
              selected: _selectedIcon == LucideIcons.settings,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIcon = LucideIcons.settings);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Shape 선택
        const Text('Shape', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Circle',
              selected: _shape == SketchIconButtonShape.circle,
              onSelected: (selected) {
                if (selected) setState(() => _shape = SketchIconButtonShape.circle);
              },
            ),
            SketchChip(
              label: 'Square',
              selected: _shape == SketchIconButtonShape.square,
              onSelected: (selected) {
                if (selected) setState(() => _shape = SketchIconButtonShape.square);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Badge Count 슬라이더
        Text('Badge Count: $_badgeCount', style: const TextStyle(fontWeight: FontWeight.w500)),
        SketchSlider(
          value: _badgeCount.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: _badgeCount.toString(),
          onChanged: (value) => setState(() => _badgeCount = value.toInt()),
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

        // Circle 버튼들
        const Text('Circle', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchIconButton(
              icon: LucideIcons.heart,
              shape: SketchIconButtonShape.circle,
              onPressed: () {},
            ),
            SketchIconButton(
              icon: LucideIcons.star,
              shape: SketchIconButtonShape.circle,
              badgeCount: 5,
              onPressed: () {},
            ),
            SketchIconButton(
              icon: LucideIcons.bell,
              shape: SketchIconButtonShape.circle,
              badgeCount: 99,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Square 버튼들
        const Text('Square', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchIconButton(
              icon: LucideIcons.settings,
              shape: SketchIconButtonShape.square,
              onPressed: () {},
            ),
            SketchIconButton(
              icon: LucideIcons.user,
              shape: SketchIconButtonShape.square,
              onPressed: () {},
            ),
            SketchIconButton(
              icon: LucideIcons.menu,
              shape: SketchIconButtonShape.square,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
