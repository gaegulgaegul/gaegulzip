import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchSlider 데모
///
/// value, min, max, divisions, label 속성을 실시간으로 조절할 수 있습니다.
class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});

  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  // 조절 가능한 속성들
  double _value = 50.0;
  double _min = 0.0;
  double _max = 100.0;
  int? _divisions;
  bool _showLabel = false;

  // 갤러리 상태
  double _galleryValue1 = 30.0;
  double _galleryValue2 = 3.0;
  double _galleryValue3 = 75.0;

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
        SketchSlider(
          value: _value,
          min: _min,
          max: _max,
          divisions: _divisions,
          label: _showLabel ? '${_value.round()}' : null,
          onChanged: (value) => setState(() => _value = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Center(
          child: Text(
            'Value: ${_value.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: SketchDesignTokens.fontSizeBase, fontWeight: FontWeight.w500),
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

        // Min 슬라이더
        Text('Min: ${_min.toInt()}', style: const TextStyle(fontWeight: FontWeight.w500)),
        SketchSlider(
          value: _min,
          min: 0,
          max: 50,
          divisions: 5,
          label: _min.toInt().toString(),
          onChanged: (value) {
            setState(() {
              _min = value;
              if (_value < _min) _value = _min;
            });
          },
        ),

        // Max 슬라이더
        Text('Max: ${_max.toInt()}', style: const TextStyle(fontWeight: FontWeight.w500)),
        SketchSlider(
          value: _max,
          min: 50,
          max: 200,
          divisions: 15,
          label: _max.toInt().toString(),
          onChanged: (value) {
            setState(() {
              _max = value;
              if (_value > _max) _value = _max;
            });
          },
        ),

        // Divisions 선택
        const Text('Divisions', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'None',
              selected: _divisions == null,
              onSelected: (selected) {
                if (selected) setState(() => _divisions = null);
              },
            ),
            SketchChip(
              label: '5',
              selected: _divisions == 5,
              onSelected: (selected) {
                if (selected) setState(() => _divisions = 5);
              },
            ),
            SketchChip(
              label: '10',
              selected: _divisions == 10,
              onSelected: (selected) {
                if (selected) setState(() => _divisions = 10);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Show Label', style: TextStyle(fontSize: SketchDesignTokens.fontSizeBase)),
            SketchSwitch(
              value: _showLabel,
              onChanged: (value) => setState(() => _showLabel = value),
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

        // 기본 (연속)
        const Text('기본 (연속)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchSlider(
          value: _galleryValue1,
          min: 0,
          max: 100,
          onChanged: (value) => setState(() => _galleryValue1 = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Divisions
        const Text('Divisions (5단계)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchSlider(
          value: _galleryValue2,
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (value) => setState(() => _galleryValue2 = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Label
        const Text('Label 표시', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SketchSlider(
          value: _galleryValue3,
          min: 0,
          max: 100,
          label: '${_galleryValue3.round()}%',
          onChanged: (value) => setState(() => _galleryValue3 = value),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // 비활성화
        const Text('비활성화', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        const SketchSlider(
          value: 50,
          min: 0,
          max: 100,
          onChanged: null,
        ),
      ],
    );
  }
}
