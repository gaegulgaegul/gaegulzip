import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// SketchButton 데모
///
/// style, size, isLoading, icon 속성을 실시간으로 조절할 수 있습니다.
class ButtonDemo extends StatefulWidget {
  const ButtonDemo({super.key});

  @override
  State<ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  // 조절 가능한 속성들
  SketchButtonStyle _style = SketchButtonStyle.primary;
  SketchButtonSize _size = SketchButtonSize.medium;
  bool _isLoading = false;
  bool _showIcon = false;

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
          child: SketchButton(
            text: 'Button',
            style: _style,
            size: _size,
            isLoading: _isLoading,
            icon: _showIcon ? const Icon(LucideIcons.star) : null,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('버튼 클릭됨!')),
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

        // Style 선택
        const Text('Style', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Primary',
              selected: _style == SketchButtonStyle.primary,
              onSelected: (selected) {
                if (selected) setState(() => _style = SketchButtonStyle.primary);
              },
            ),
            SketchChip(
              label: 'Secondary',
              selected: _style == SketchButtonStyle.secondary,
              onSelected: (selected) {
                if (selected) setState(() => _style = SketchButtonStyle.secondary);
              },
            ),
            SketchChip(
              label: 'Outline',
              selected: _style == SketchButtonStyle.outline,
              onSelected: (selected) {
                if (selected) setState(() => _style = SketchButtonStyle.outline);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Size 선택
        const Text('Size', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Small',
              selected: _size == SketchButtonSize.small,
              onSelected: (selected) {
                if (selected) setState(() => _size = SketchButtonSize.small);
              },
            ),
            SketchChip(
              label: 'Medium',
              selected: _size == SketchButtonSize.medium,
              onSelected: (selected) {
                if (selected) setState(() => _size = SketchButtonSize.medium);
              },
            ),
            SketchChip(
              label: 'Large',
              selected: _size == SketchButtonSize.large,
              onSelected: (selected) {
                if (selected) setState(() => _size = SketchButtonSize.large);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Loading 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Loading', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _isLoading,
              onChanged: (value) => setState(() => _isLoading = value),
            ),
          ],
        ),

        // Icon 토글
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

        // Primary 버튼들
        const Text('Primary', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchButton(
              text: 'Small',
              style: SketchButtonStyle.primary,
              size: SketchButtonSize.small,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Medium',
              style: SketchButtonStyle.primary,
              size: SketchButtonSize.medium,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Large',
              style: SketchButtonStyle.primary,
              size: SketchButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Secondary 버튼들
        const Text('Secondary', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchButton(
              text: 'Small',
              style: SketchButtonStyle.secondary,
              size: SketchButtonSize.small,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Medium',
              style: SketchButtonStyle.secondary,
              size: SketchButtonSize.medium,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Large',
              style: SketchButtonStyle.secondary,
              size: SketchButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Outline 버튼들
        const Text('Outline', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          runSpacing: SketchDesignTokens.spacingSm,
          children: [
            SketchButton(
              text: 'Small',
              style: SketchButtonStyle.outline,
              size: SketchButtonSize.small,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Medium',
              style: SketchButtonStyle.outline,
              size: SketchButtonSize.medium,
              onPressed: () {},
            ),
            SketchButton(
              text: 'Large',
              style: SketchButtonStyle.outline,
              size: SketchButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
