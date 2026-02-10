import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchContainer 데모
///
/// fillColor, borderColor, strokeWidth, roughness 속성을 실시간으로 조절할 수 있습니다.
class ContainerDemo extends StatefulWidget {
  const ContainerDemo({super.key});

  @override
  State<ContainerDemo> createState() => _ContainerDemoState();
}

class _ContainerDemoState extends State<ContainerDemo> {
  // 조절 가능한 속성들
  double _strokeWidth = 2.0;
  double _roughness = 0.8;

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
        SketchContainer(
          strokeWidth: _strokeWidth,
          roughness: _roughness,
          padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
          child: const Text(
            'This is a SketchContainer with customizable stroke width and roughness.',
            textAlign: TextAlign.center,
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

        // Stroke Width 슬라이더
        Text('Stroke Width: ${_strokeWidth.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w500)),
        SketchSlider(
          value: _strokeWidth,
          min: 1.0,
          max: 5.0,
          divisions: 8,
          label: _strokeWidth.toStringAsFixed(1),
          onChanged: (value) => setState(() => _strokeWidth = value),
        ),

        // Roughness 슬라이더
        Text('Roughness: ${_roughness.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w500)),
        SketchSlider(
          value: _roughness,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          label: _roughness.toStringAsFixed(1),
          onChanged: (value) => setState(() => _roughness = value),
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

        // 기본 (부드러운)
        const Text('부드러운 (roughness: 0.3)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchContainer(
          roughness: 0.3,
          padding: EdgeInsets.all(SketchDesignTokens.spacingLg),
          child: Text('Smooth sketch effect'),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 중간
        const Text('중간 (roughness: 0.8)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchContainer(
          roughness: 0.8,
          padding: EdgeInsets.all(SketchDesignTokens.spacingLg),
          child: Text('Medium sketch effect'),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 강한
        const Text('강한 (roughness: 1.5)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchContainer(
          roughness: 1.5,
          padding: EdgeInsets.all(SketchDesignTokens.spacingLg),
          child: Text('Strong sketch effect'),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 커스텀 색상
        const Text('커스텀 색상', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchContainer(
          fillColor: Color(0xFFFFF3CD),
          borderColor: Color(0xFFFFA500),
          strokeWidth: 3.0,
          padding: EdgeInsets.all(SketchDesignTokens.spacingLg),
          child: Text('Custom colors'),
        ),
      ],
    );
  }
}
