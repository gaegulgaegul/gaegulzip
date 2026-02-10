import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// AnimatedSketchPainter 데모
///
/// progress(자동재생/수동), roughness 조절
class AnimatedPainterDemo extends StatefulWidget {
  const AnimatedPainterDemo({super.key});

  @override
  State<AnimatedPainterDemo> createState() => _AnimatedPainterDemoState();
}

class _AnimatedPainterDemoState extends State<AnimatedPainterDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _roughness = SketchDesignTokens.roughness;
  int _seed = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 자동 재생 토글
  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
      if (_isAutoPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  /// 리셋
  void _reset() {
    _controller.reset();
    setState(() {
      _isAutoPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 페인터 렌더링
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: AnimatedSketchPainter(
                    progress: _controller.value,
                    fillColor: SketchDesignTokens.accentPrimary,
                    borderColor: SketchDesignTokens.base900,
                    roughness: _roughness,
                    seed: _seed,
                  ),
                  child: const SizedBox(width: 300, height: 200),
                );
              },
            ),
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 자동 재생 컨트롤
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleAutoPlay,
                icon: Icon(_isAutoPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_isAutoPlaying ? 'Pause' : 'Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAutoPlaying
                      ? SketchDesignTokens.warning
                      : SketchDesignTokens.accentPrimary,
                ),
              ),
              const SizedBox(width: SketchDesignTokens.spacingLg),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SketchDesignTokens.base600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SketchDesignTokens.spacingXl),

          // 수동 진행률 슬라이더
          _buildSectionTitle('Manual Progress'),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                children: [
                  Expanded(
                    child: SketchSlider(
                      value: _controller.value,
                      min: 0.0,
                      max: 1.0,
                      label: '${(_controller.value * 100).toStringAsFixed(0)}%',
                      onChanged: _isAutoPlaying
                          ? null
                          : (value) {
                              _controller.value = value;
                            },
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${(_controller.value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: SketchDesignTokens.fontSizeSm),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              );
            },
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
}
