import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchProgressBar 데모
///
/// value, style, showPercentage 속성을 실시간으로 조절할 수 있습니다.
class ProgressBarDemo extends StatefulWidget {
  const ProgressBarDemo({super.key});

  @override
  State<ProgressBarDemo> createState() => _ProgressBarDemoState();
}

class _ProgressBarDemoState extends State<ProgressBarDemo> {
  // 조절 가능한 속성들
  double _value = 0.7;
  SketchProgressBarStyle _style = SketchProgressBarStyle.linear;
  bool _showPercentage = false;

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
          child: SketchProgressBar(
            value: _value,
            style: _style,
            showPercentage: _showPercentage,
            size: _style == SketchProgressBarStyle.circular ? 100 : null,
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

        // Value 슬라이더
        Text('Value: ${(_value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w500)),
        SketchSlider(
          value: _value,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: '${(_value * 100).toInt()}%',
          onChanged: (value) => setState(() => _value = value),
        ),

        // Style 선택
        const Text('Style', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Linear',
              selected: _style == SketchProgressBarStyle.linear,
              onSelected: (selected) {
                if (selected) setState(() => _style = SketchProgressBarStyle.linear);
              },
            ),
            SketchChip(
              label: 'Circular',
              selected: _style == SketchProgressBarStyle.circular,
              onSelected: (selected) {
                if (selected) setState(() => _style = SketchProgressBarStyle.circular);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show Percentage (Circular만)', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showPercentage,
              onChanged: (value) => setState(() => _showPercentage = value),
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

        // Linear 프로그레스 바들
        const Text('Linear', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchProgressBar(
          value: 0.3,
          style: SketchProgressBarStyle.linear,
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchProgressBar(
          value: 0.7,
          style: SketchProgressBarStyle.linear,
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchProgressBar(
          value: 1.0,
          style: SketchProgressBarStyle.linear,
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Circular 프로그레스 바들
        const Text('Circular', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingLg,
          runSpacing: SketchDesignTokens.spacingLg,
          children: [
            const SketchProgressBar(
              value: 0.3,
              style: SketchProgressBarStyle.circular,
              size: 80,
            ),
            const SketchProgressBar(
              value: 0.7,
              style: SketchProgressBarStyle.circular,
              size: 80,
              showPercentage: true,
            ),
            const SketchProgressBar(
              value: 1.0,
              style: SketchProgressBarStyle.circular,
              size: 80,
              showPercentage: true,
            ),
          ],
        ),
      ],
    );
  }
}
