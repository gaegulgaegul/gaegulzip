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
  // 상태
  late Color _fillColor;
  late Color _borderColor;
  double _strokeWidth = SketchDesignTokens.strokeStandard;
  double _roughness = SketchDesignTokens.roughness;
  double _bowing = SketchDesignTokens.bowing;
  int _seed = 0;
  bool _enableNoise = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final sketchTheme = SketchThemeExtension.of(context);
      _fillColor = sketchTheme.fillColor;
      _borderColor = sketchTheme.borderColor;
      _initialized = true;
    }
  }

  /// 테마 기반 색상 팔레트
  List<Color> _buildColors(SketchThemeExtension theme) {
    return [
      theme.fillColor,
      SketchDesignTokens.accentPrimary,
      SketchDesignTokens.accentLight,
      SketchDesignTokens.error,
      SketchDesignTokens.warning,
      SketchDesignTokens.success,
      theme.borderColor,
      theme.textSecondaryColor,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.of(context);
    final colors = _buildColors(sketchTheme);

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
          _buildSectionTitle('Fill Color', sketchTheme),
          _buildColorPicker(colors, _fillColor, (color) {
            setState(() => _fillColor = color);
          }),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSectionTitle('Border Color', sketchTheme),
          _buildColorPicker(colors, _borderColor, (color) {
            setState(() => _borderColor = color);
          }),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            sketchTheme,
            'Stroke Width',
            _strokeWidth,
            1.0,
            5.0,
            (value) => setState(() => _strokeWidth = value),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            sketchTheme,
            'Roughness',
            _roughness,
            0.0,
            2.0,
            (value) => setState(() => _roughness = value),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            sketchTheme,
            'Bowing',
            _bowing,
            0.0,
            2.0,
            (value) => setState(() => _bowing = value),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSlider(
            sketchTheme,
            'Seed',
            _seed.toDouble(),
            0.0,
            100.0,
            (value) => setState(() => _seed = value.toInt()),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSwitch(
            sketchTheme,
            'Enable Noise',
            _enableNoise,
            (value) => setState(() => _enableNoise = value),
          ),
        ],
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title, SketchThemeExtension theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: SketchDesignTokens.fontSizeBase,
        fontWeight: FontWeight.bold,
        color: theme.textSecondaryColor,
      ),
    );
  }

  /// 컬러 피커
  Widget _buildColorPicker(
    List<Color> colors,
    Color selected,
    ValueChanged<Color> onChanged,
  ) {
    return Wrap(
      spacing: SketchDesignTokens.spacingSm,
      runSpacing: SketchDesignTokens.spacingSm,
      children: colors.map((color) {
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
    SketchThemeExtension theme,
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
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeSm,
            color: theme.textSecondaryColor,
          ),
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
    SketchThemeExtension theme,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            color: theme.textColor,
          ),
        ),
        SketchSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
