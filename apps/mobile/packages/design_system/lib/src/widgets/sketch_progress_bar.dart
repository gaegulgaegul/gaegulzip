import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../painters/sketch_circle_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 프로그레스 바 스타일
enum SketchProgressBarStyle {
  /// 가로 바 형태
  linear,

  /// 원형 형태
  circular,
}

/// 손그림 스타일 프로그레스 바 위젯
///
/// Frame0 스타일의 스케치 진행률 표시 위젯.
/// Linear(가로 바)와 Circular(원형) 두 가지 스타일 지원.
///
/// **기본 사용법 (Linear):**
/// ```dart
/// SketchProgressBar(
///   value: 0.7, // 70%
/// )
/// ```
///
/// **Circular 스타일:**
/// ```dart
/// SketchProgressBar(
///   value: 0.5, // 50%
///   style: SketchProgressBarStyle.circular,
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// SketchProgressBar(
///   value: 0.3,
///   progressColor: SketchDesignTokens.success,
///   backgroundColor: SketchDesignTokens.base200,
/// )
/// ```
///
/// **크기 조절:**
/// ```dart
/// SketchProgressBar(
///   value: 0.8,
///   style: SketchProgressBarStyle.linear,
///   height: 12.0, // 두께
/// )
///
/// SketchProgressBar(
///   value: 0.6,
///   style: SketchProgressBarStyle.circular,
///   size: 100.0, // 원 크기
/// )
/// ```
///
/// **중앙 텍스트 (Circular):**
/// ```dart
/// SketchProgressBar(
///   value: 0.75,
///   style: SketchProgressBarStyle.circular,
///   showPercentage: true, // "75%" 표시
/// )
/// ```
///
/// **Indeterminate (진행률 미정):**
/// ```dart
/// SketchProgressBar(
///   value: null, // null = indeterminate
/// )
/// ```
class SketchProgressBar extends StatefulWidget {
  /// 진행률 값 (0.0 ~ 1.0), null이면 indeterminate 상태
  final double? value;

  /// 프로그레스 바 스타일 (linear 또는 circular)
  final SketchProgressBarStyle style;

  /// Linear: 바의 높이, Circular: 선 두께
  final double height;

  /// Circular: 원의 크기 (지름)
  final double? size;

  /// 진행된 부분의 색상
  final Color? progressColor;

  /// 배경 색상
  final Color? backgroundColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 선 두께
  final double? strokeWidth;

  /// 거칠기 계수
  final double? roughness;

  /// 랜덤 시드
  final int seed;

  /// Circular: 중앙에 퍼센트 표시 여부
  final bool showPercentage;

  /// Circular: 중앙 텍스트 (showPercentage가 false일 때만 사용)
  final String? centerText;

  const SketchProgressBar({
    super.key,
    this.value,
    this.style = SketchProgressBarStyle.linear,
    this.height = 8.0,
    this.size,
    this.progressColor,
    this.backgroundColor,
    this.borderColor,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
    this.showPercentage = false,
    this.centerText,
  }) : assert(value == null || (value >= 0.0 && value <= 1.0), 'value는 0.0~1.0 사이여야 함');

  @override
  State<SketchProgressBar> createState() => _SketchProgressBarState();
}

class _SketchProgressBarState extends State<SketchProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Indeterminate 애니메이션용
    if (widget.value == null) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat();
    } else {
      _animationController = AnimationController(vsync: this);
    }
  }

  @override
  void didUpdateWidget(SketchProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // value가 null로 변경되면 애니메이션 시작
    if (widget.value == null && oldWidget.value != null) {
      _animationController.duration = const Duration(milliseconds: 1500);
      _animationController.repeat();
    } else if (widget.value != null && oldWidget.value == null) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    final effectiveProgressColor = widget.progressColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.accentPrimary;
    final effectiveBackgroundColor = widget.backgroundColor ?? sketchTheme?.fillColor ?? SketchDesignTokens.base200;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base300;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;

    if (widget.style == SketchProgressBarStyle.linear) {
      return _buildLinear(
        effectiveProgressColor,
        effectiveBackgroundColor,
        effectiveBorderColor,
        effectiveStrokeWidth,
        effectiveRoughness,
      );
    } else {
      return _buildCircular(
        effectiveProgressColor,
        effectiveBackgroundColor,
        effectiveBorderColor,
        effectiveStrokeWidth,
        effectiveRoughness,
      );
    }
  }

  Widget _buildLinear(
    Color progressColor,
    Color backgroundColor,
    Color borderColor,
    double strokeWidth,
    double roughness,
  ) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // 배경
          CustomPaint(
            painter: SketchPainter(
              fillColor: backgroundColor,
              borderColor: borderColor,
              strokeWidth: strokeWidth,
              roughness: roughness,
              seed: widget.seed,
              enableNoise: false,
            ),
            child: const SizedBox.expand(),
          ),

          // 진행 바
          if (widget.value != null)
            FractionallySizedBox(
              widthFactor: widget.value,
              child: CustomPaint(
                painter: SketchPainter(
                  fillColor: progressColor,
                  borderColor: progressColor,
                  strokeWidth: strokeWidth,
                  roughness: roughness,
                  seed: widget.seed + 1,
                  enableNoise: false,
                ),
                child: const SizedBox.expand(),
              ),
            )
          else
            // Indeterminate 애니메이션
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment(
                    -1.0 + 2.0 * _animationController.value,
                    0.0,
                  ),
                  widthFactor: 0.3,
                  child: CustomPaint(
                    painter: SketchPainter(
                      fillColor: progressColor,
                      borderColor: progressColor,
                      strokeWidth: strokeWidth,
                      roughness: roughness,
                      seed: widget.seed + 1,
                      enableNoise: false,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCircular(
    Color progressColor,
    Color backgroundColor,
    Color borderColor,
    double strokeWidth,
    double roughness,
  ) {
    final effectiveSize = widget.size ?? 80.0;

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          CustomPaint(
            painter: SketchCirclePainter(
              fillColor: Colors.transparent,
              borderColor: backgroundColor,
              strokeWidth: widget.height,
              roughness: roughness,
              seed: widget.seed,
            ),
            child: SizedBox(
              width: effectiveSize,
              height: effectiveSize,
            ),
          ),

          // 진행 호
          if (widget.value != null)
            CustomPaint(
              painter: _SketchCircularProgressPainter(
                progress: widget.value!,
                progressColor: progressColor,
                strokeWidth: widget.height,
                roughness: roughness,
                seed: widget.seed + 1,
              ),
              child: SizedBox(
                width: effectiveSize,
                height: effectiveSize,
              ),
            )
          else
            // Indeterminate 애니메이션
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 2 * pi,
                  child: CustomPaint(
                    painter: _SketchCircularProgressPainter(
                      progress: 0.25,
                      progressColor: progressColor,
                      strokeWidth: widget.height,
                      roughness: roughness,
                      seed: widget.seed + 1,
                    ),
                    child: SizedBox(
                      width: effectiveSize,
                      height: effectiveSize,
                    ),
                  ),
                );
              },
            ),

          // 중앙 텍스트
          if (widget.showPercentage && widget.value != null)
            Text(
              '${(widget.value! * 100).toInt()}%',
              style: const TextStyle(
                fontSize: SketchDesignTokens.fontSizeBase,
                fontWeight: FontWeight.w600,
                color: SketchDesignTokens.base900,
              ),
            )
          else if (widget.centerText != null)
            Text(
              widget.centerText!,
              style: const TextStyle(
                fontSize: SketchDesignTokens.fontSizeSm,
                color: SketchDesignTokens.base700,
              ),
            ),
        ],
      ),
    );
  }
}

/// 원형 프로그레스 CustomPainter
class _SketchCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;
  final double roughness;
  final int seed;

  const _SketchCircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
    required this.roughness,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 시작 각도 (-90도 = 12시 방향)
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    // 호를 여러 세그먼트로 나눠서 불규칙하게 그림
    const segments = 20;
    final anglePerSegment = sweepAngle / segments;

    for (int i = 0; i < segments; i++) {
      final currentAngle = startAngle + anglePerSegment * i;
      final nextAngle = startAngle + anglePerSegment * (i + 1);

      // 약간의 불규칙성 추가
      final currentRadius = radius + (random.nextDouble() - 0.5) * roughness;
      final nextRadius = radius + (random.nextDouble() - 0.5) * roughness;

      final startPoint = Offset(
        center.dx + cos(currentAngle) * currentRadius,
        center.dy + sin(currentAngle) * currentRadius,
      );

      final endPoint = Offset(
        center.dx + cos(nextAngle) * nextRadius,
        center.dy + sin(nextAngle) * nextRadius,
      );

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SketchCircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        progressColor != oldDelegate.progressColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed;
  }
}
