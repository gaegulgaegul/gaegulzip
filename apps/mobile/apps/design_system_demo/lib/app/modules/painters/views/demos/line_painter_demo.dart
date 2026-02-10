import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SketchLinePainter 데모
///
/// roughness, dashPattern, startPoint, endPoint 조절
class LinePainterDemo extends StatefulWidget {
  const LinePainterDemo({super.key});

  @override
  State<LinePainterDemo> createState() => _LinePainterDemoState();
}

class _LinePainterDemoState extends State<LinePainterDemo> {
  // 상태
  double _roughness = SketchDesignTokens.roughness;
  int _seed = 0;
  SketchArrowStyle _arrowStyle = SketchArrowStyle.none;
  bool _isDashed = false;

  // 선 좌표 (캔버스 크기 300x200 기준)
  Offset _start = const Offset(20, 100);
  Offset _end = const Offset(280, 100);

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
              painter: SketchLinePainter(
                start: _start,
                end: _end,
                color: SketchDesignTokens.base900,
                roughness: _roughness,
                seed: _seed,
                arrowStyle: _arrowStyle,
                dashPattern: _isDashed ? [5.0, 3.0] : null,
              ),
              child: const SizedBox(width: 300, height: 200),
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 컨트롤
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

          _buildSectionTitle('Arrow Style'),
          _buildArrowStylePicker(),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSwitch(
            'Dashed Line',
            _isDashed,
            (value) => setState(() => _isDashed = value),
          ),
          const SizedBox(height: SketchDesignTokens.spacingLg),

          _buildSectionTitle('Line Presets'),
          _buildLinePresets(),
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

  /// 화살표 스타일 선택
  Widget _buildArrowStylePicker() {
    final styles = [
      SketchArrowStyle.none,
      SketchArrowStyle.end,
      SketchArrowStyle.start,
      SketchArrowStyle.both,
    ];

    return Wrap(
      spacing: SketchDesignTokens.spacingSm,
      runSpacing: SketchDesignTokens.spacingSm,
      children: styles.map((style) {
        final isSelected = style == _arrowStyle;
        return SketchChip(
          label: style.name,
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _arrowStyle = style);
            }
          },
        );
      }).toList(),
    );
  }

  /// 선 프리셋
  Widget _buildLinePresets() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _start = const Offset(20, 100);
              _end = const Offset(280, 100);
            });
          },
          child: const Text('Horizontal'),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _start = const Offset(150, 20);
              _end = const Offset(150, 180);
            });
          },
          child: const Text('Vertical'),
        ),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _start = const Offset(20, 20);
              _end = const Offset(280, 180);
            });
          },
          child: const Text('Diagonal'),
        ),
      ],
    );
  }
}
