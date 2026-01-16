import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../painters/sketch_circle_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손그림 스타일 슬라이더 위젯
///
/// Frame0 스타일의 슬라이더.
/// 드래그하여 값을 조절할 수 있음.
///
/// **기본 사용법:**
/// ```dart
/// SketchSlider(
///   value: 50.0,
///   min: 0.0,
///   max: 100.0,
///   onChanged: (value) {
///     setState(() => volume = value);
///   },
/// )
/// ```
///
/// **비활성화 상태:**
/// ```dart
/// SketchSlider(
///   value: 75.0,
///   min: 0.0,
///   max: 100.0,
///   onChanged: null, // null이면 비활성화
/// )
/// ```
///
/// **구분선 (divisions):**
/// ```dart
/// SketchSlider(
///   value: 3.0,
///   min: 0.0,
///   max: 5.0,
///   divisions: 5, // 0, 1, 2, 3, 4, 5로 나뉨
///   onChanged: (value) {},
/// )
/// ```
///
/// **레이블 표시:**
/// ```dart
/// SketchSlider(
///   value: brightness,
///   min: 0.0,
///   max: 100.0,
///   label: '${brightness.round()}%',
///   onChanged: (value) {
///     setState(() => brightness = value);
///   },
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// SketchSlider(
///   value: 50.0,
///   min: 0.0,
///   max: 100.0,
///   activeColor: SketchDesignTokens.success,
///   inactiveColor: SketchDesignTokens.base200,
///   onChanged: (value) {},
/// )
/// ```
class SketchSlider extends StatefulWidget {
  /// 현재 값
  final double value;

  /// 최소값
  final double min;

  /// 최대값
  final double max;

  /// 값 변경 콜백 (null이면 비활성화)
  final ValueChanged<double>? onChanged;

  /// 변경 시작 콜백
  final ValueChanged<double>? onChangeStart;

  /// 변경 종료 콜백
  final ValueChanged<double>? onChangeEnd;

  /// 구분선 개수 (null이면 연속적)
  final int? divisions;

  /// 라벨 텍스트 (null이면 표시 안함)
  final String? label;

  /// 활성 부분 (채워진 부분) 색상
  final Color? activeColor;

  /// 비활성 부분 (빈 부분) 색상
  final Color? inactiveColor;

  /// 썸(원형 손잡이) 색상
  final Color? thumbColor;

  /// 트랙 높이
  final double trackHeight;

  /// 썸 크기
  final double thumbSize;

  /// 선 두께
  final double? strokeWidth;

  /// 거칠기 계수
  final double? roughness;

  /// 랜덤 시드
  final int seed;

  const SketchSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.trackHeight = 6.0,
    this.thumbSize = 20.0,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
  }) : assert(min < max, 'min은 max보다 작아야 함'),
       assert(value >= min && value <= max, 'value는 min과 max 사이여야 함');

  @override
  State<SketchSlider> createState() => _SketchSliderState();
}

class _SketchSliderState extends State<SketchSlider> {
  bool _isDragging = false;
  double? _dragValue;

  double get _effectiveValue => _dragValue ?? widget.value;

  void _handleDragStart(double localX, double trackWidth) {
    if (widget.onChanged != null) {
      setState(() => _isDragging = true);

      final value = _calculateValue(localX, trackWidth);
      widget.onChangeStart?.call(value);
      _updateValue(value);
    }
  }

  void _handleDragUpdate(double localX, double trackWidth) {
    if (widget.onChanged != null && _isDragging) {
      final value = _calculateValue(localX, trackWidth);
      _updateValue(value);
    }
  }

  void _handleDragEnd() {
    if (widget.onChanged != null && _isDragging) {
      setState(() => _isDragging = false);

      widget.onChangeEnd?.call(_effectiveValue);
      _dragValue = null;
    }
  }

  double _calculateValue(double localX, double trackWidth) {
    // thumbSize의 절반만큼 패딩 고려
    final padding = widget.thumbSize / 2;
    final effectiveWidth = trackWidth - widget.thumbSize;
    final clampedX = (localX - padding).clamp(0.0, effectiveWidth);

    final percentage = clampedX / effectiveWidth;
    double value = widget.min + (widget.max - widget.min) * percentage;

    // divisions가 있으면 해당 값으로 반올림
    if (widget.divisions != null) {
      final step = (widget.max - widget.min) / widget.divisions!;
      value = (value / step).round() * step;
    }

    return value.clamp(widget.min, widget.max);
  }

  void _updateValue(double value) {
    setState(() => _dragValue = value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final isDisabled = widget.onChanged == null;

    final effectiveActiveColor = widget.activeColor ?? SketchDesignTokens.accentPrimary;
    final effectiveInactiveColor = widget.inactiveColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base300;
    final effectiveThumbColor = widget.thumbColor ?? effectiveActiveColor;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;

    return Opacity(
      opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.thumbSize / 2,
          vertical: widget.label != null ? 24.0 : 12.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;

            // 현재 값에 대한 위치 계산
            final percentage = (_effectiveValue - widget.min) / (widget.max - widget.min);
            final thumbPosition = percentage * trackWidth;

            return GestureDetector(
              onHorizontalDragStart: isDisabled
                  ? null
                  : (details) => _handleDragStart(details.localPosition.dx, trackWidth),
              onHorizontalDragUpdate: isDisabled
                  ? null
                  : (details) => _handleDragUpdate(details.localPosition.dx, trackWidth),
              onHorizontalDragEnd: isDisabled ? null : (_) => _handleDragEnd(),
              onTapDown: isDisabled
                  ? null
                  : (details) {
                      _handleDragStart(details.localPosition.dx, trackWidth);
                      _handleDragEnd();
                    },
              child: SizedBox(
                height: widget.thumbSize + (widget.label != null ? 20.0 : 0.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 비활성 트랙 (전체)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: (widget.thumbSize - widget.trackHeight) / 2,
                      child: CustomPaint(
                        painter: SketchPainter(
                          fillColor: effectiveInactiveColor,
                          borderColor: effectiveInactiveColor,
                          strokeWidth: effectiveStrokeWidth,
                          roughness: effectiveRoughness,
                          seed: widget.seed,
                          enableNoise: false,
                        ),
                        child: SizedBox(
                          height: widget.trackHeight,
                          width: trackWidth,
                        ),
                      ),
                    ),

                    // 활성 트랙 (채워진 부분)
                    Positioned(
                      left: 0,
                      top: (widget.thumbSize - widget.trackHeight) / 2,
                      child: CustomPaint(
                        painter: SketchPainter(
                          fillColor: effectiveActiveColor,
                          borderColor: effectiveActiveColor,
                          strokeWidth: effectiveStrokeWidth,
                          roughness: effectiveRoughness,
                          seed: widget.seed + 1,
                          enableNoise: false,
                        ),
                        child: SizedBox(
                          height: widget.trackHeight,
                          width: thumbPosition,
                        ),
                      ),
                    ),

                    // 썸 (원형 손잡이)
                    Positioned(
                      left: thumbPosition - widget.thumbSize / 2,
                      top: 0,
                      child: CustomPaint(
                        painter: SketchCirclePainter(
                          fillColor: effectiveThumbColor,
                          borderColor: effectiveThumbColor,
                          strokeWidth: effectiveStrokeWidth,
                          roughness: effectiveRoughness,
                          seed: widget.seed + 2,
                        ),
                        child: SizedBox(
                          width: widget.thumbSize,
                          height: widget.thumbSize,
                        ),
                      ),
                    ),

                    // 라벨
                    if (widget.label != null && _isDragging)
                      Positioned(
                        left: thumbPosition - 20,
                        top: widget.thumbSize + 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SketchDesignTokens.base900,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.label!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: SketchDesignTokens.fontSizeXs,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
