import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchCard 데모
///
/// elevation, header, body, footer 속성을 실시간으로 조절할 수 있습니다.
class CardDemo extends StatefulWidget {
  const CardDemo({super.key});

  @override
  State<CardDemo> createState() => _CardDemoState();
}

class _CardDemoState extends State<CardDemo> {
  // 조절 가능한 속성들
  int _elevation = 2;
  bool _showHeader = true;
  bool _showFooter = true;
  bool _onTapEnabled = true;

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
        SketchCard(
          header: _showHeader
              ? const Text(
                  'Card Header',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
          body: const Text(
            'This is the card body. It can contain any widget you want.',
            style: TextStyle(fontSize: SketchDesignTokens.fontSizeSm),
          ),
          footer: _showFooter
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SketchButton(
                      text: 'Cancel',
                      style: SketchButtonStyle.outline,
                      size: SketchButtonSize.small,
                      onPressed: () {},
                    ),
                    const SizedBox(width: SketchDesignTokens.spacingSm),
                    SketchButton(
                      text: 'OK',
                      style: SketchButtonStyle.primary,
                      size: SketchButtonSize.small,
                      onPressed: () {},
                    ),
                  ],
                )
              : null,
          elevation: _elevation,
          onTap: _onTapEnabled
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('카드 클릭됨!')),
                  );
                }
              : null,
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

        // Elevation 슬라이더
        Text('Elevation: $_elevation', style: const TextStyle(fontWeight: FontWeight.w500)),
        SketchSlider(
          value: _elevation.toDouble(),
          min: 0,
          max: 3,
          divisions: 3,
          label: _elevation.toString(),
          onChanged: (value) => setState(() => _elevation = value.toInt()),
        ),

        // Header 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show Header', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showHeader,
              onChanged: (value) => setState(() => _showHeader = value),
            ),
          ],
        ),

        // Footer 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show Footer', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showFooter,
              onChanged: (value) => setState(() => _showFooter = value),
            ),
          ],
        ),

        // OnTap 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enable Tap', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _onTapEnabled,
              onChanged: (value) => setState(() => _onTapEnabled = value),
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

        // Elevation 0
        const Text('Elevation 0', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchCard(
          body: Text('No shadow'),
          elevation: 0,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Elevation 1
        const Text('Elevation 1', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchCard(
          body: Text('Subtle shadow'),
          elevation: 1,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Elevation 2
        const Text('Elevation 2', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchCard(
          body: Text('Medium shadow (default)'),
          elevation: 2,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Elevation 3
        const Text('Elevation 3', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchCard(
          body: Text('Strong shadow'),
          elevation: 3,
        ),
      ],
    );
  }
}
