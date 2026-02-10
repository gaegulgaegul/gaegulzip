import 'dart:math';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchPolygonPainter 데모
///
/// sides(3-8), rotation, roughness 조절
class PolygonPainterDemo extends StatefulWidget {
  const PolygonPainterDemo({super.key});

  @override
  State<PolygonPainterDemo> createState() => _PolygonPainterDemoState();
}

class _PolygonPainterDemoState extends State<PolygonPainterDemo> {
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
  int _sides = 3;
  double _rotation = 0.0;
  double _roughness = SketchDesignTokens.roughness;
  int _seed = 0;
  Color _fillColor = SketchDesignTokens.accentPrimary;
  Color _borderColor = SketchDesignTokens.base900;

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
              painter: SketchPolygonPainter(
                sides: _sides,
                fillColor: _fillColor,
                borderColor: _borderColor,
                rotation: _rotation,
                roughness: _roughness,
                seed: _seed,
              ),
              child: const SizedBox(width: 200, height: 200),
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 컨트롤
          _buildSlider(
            'Sides',
            _sides.toDouble(),
            3.0,
            8.0,
            (value) => setState(() => _sides = value.toInt()),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            'Rotation',
            _rotation * 180 / pi, // 라디안을 각도로 표시
            0.0,
            360.0,
            (value) => setState(() => _rotation = value * pi / 180),
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
            'Seed',
            _seed.toDouble(),
            0.0,
            100.0,
            (value) => setState(() => _seed = value.toInt()),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSectionTitle('Fill Color'),
          _buildColorPicker(_fillColor, (color) {
            setState(() => _fillColor = color);
          }),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSectionTitle('Border Color'),
          _buildColorPicker(_borderColor, (color) {
            setState(() => _borderColor = color);
          }),
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
}
