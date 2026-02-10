import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchPainter 데모
///
/// fillColor, borderColor, strokeWidth, roughness, bowing, seed, enableNoise 조절
class SketchPainterDemo extends StatefulWidget {
  const SketchPainterDemo({super.key});

  @override
  State<SketchPainterDemo> createState() => _SketchPainterDemoState();
}

class _SketchPainterDemoState extends State<SketchPainterDemo> {
  // 미리 정의된 색상 목록
  final List<Color> _colors = [
    Colors.white,
    SketchDesignTokens.accentPrimary,
    SketchDesignTokens.accentLight,
    SketchDesignTokens.error,
    SketchDesignTokens.warning,
    SketchDesignTokens.success,
    SketchDesignTokens.base900,
    SketchDesignTokens.base600,
  ];

  // 상태
  Color _fillColor = Colors.white;
  Color _borderColor = SketchDesignTokens.base900;
  double _strokeWidth = SketchDesignTokens.strokeStandard;
  double _roughness = SketchDesignTokens.roughness;
  double _bowing = SketchDesignTokens.bowing;
  int _seed = 0;
  bool _enableNoise = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 페인터 렌더링
          Center(
            child: CustomPaint(
              painter: SketchPainter(
                fillColor: _fillColor,
                borderColor: _borderColor,
                strokeWidth: _strokeWidth,
                roughness: _roughness,
                bowing: _bowing,
                seed: _seed,
                enableNoise: _enableNoise,
              ),
              child: const SizedBox(width: 300, height: 200),
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 컨트롤
          _buildSectionTitle('Fill Color'),
          _buildColorPicker(_fillColor, (color) {
            setState(() => _fillColor = color);
          }),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSectionTitle('Border Color'),
          _buildColorPicker(_borderColor, (color) {
            setState(() => _borderColor = color);
          }),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            'Stroke Width',
            _strokeWidth,
            1.0,
            5.0,
            (value) => setState(() => _strokeWidth = value),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            'Roughness',
            _roughness,
            0.0,
            2.0,
            (value) => setState(() => _roughness = value),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            'Bowing',
            _bowing,
            0.0,
            2.0,
            (value) => setState(() => _bowing = value),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            'Seed',
            _seed.toDouble(),
            0.0,
            100.0,
            (value) => setState(() => _seed = value.toInt()),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSwitch(
            'Enable Noise',
            _enableNoise,
            (value) => setState(() => _enableNoise = value),
          ),
        ],
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: SketchDesignTokens.fontSizeBase,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 컬러 피커
  Widget _buildColorPicker(Color selected, ValueChanged<Color> onChanged) {
    return Wrap(
      spacing: SketchDesignTokens.spacingSm,
      runSpacing: SketchDesignTokens.spacingSm,
      children: _colors.map((color) {
        final isSelected = color == selected;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: isSelected
                    ? SketchDesignTokens.accentPrimary
                    : SketchDesignTokens.base300,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 슬라이더
  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: SketchDesignTokens.fontSizeSm),
        ),
        SketchSlider(
          value: value,
          min: min,
          max: max,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 스위치
  Widget _buildSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: SketchDesignTokens.fontSizeBase),
        ),
        SketchSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
