import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

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
/// SketchPainter와 동일한 불규칙 테두리 + 노이즈 텍스처 적용.
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

  /// 테두리 표시 여부.
  final bool showBorder;

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
    this.showBorder = true,
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

    final effectiveProgressColor = widget.progressColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
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
        sketchTheme,
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
    if (widget.value != null) {
      // Determinate
      return SizedBox(
        width: double.infinity,
        height: widget.height,
        child: CustomPaint(
          painter: _SketchLinearProgressPainter(
            progress: widget.value!,
            progressColor: progressColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            strokeWidth: strokeWidth,
            roughness: roughness,
            seed: widget.seed,
            showBorder: widget.showBorder,
          ),
        ),
      );
    }

    // Indeterminate 애니메이션
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: _SketchLinearProgressPainter(
              progress: null,
              indeterminatePosition: _animationController.value,
              progressColor: progressColor,
              backgroundColor: backgroundColor,
              borderColor: borderColor,
              strokeWidth: strokeWidth,
              roughness: roughness,
              seed: widget.seed,
              showBorder: widget.showBorder,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircular(
    Color progressColor,
    Color backgroundColor,
    Color borderColor,
    double strokeWidth,
    double roughness,
    SketchThemeExtension? sketchTheme,
  ) {
    final effectiveSize = widget.size ?? 80.0;

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          Container(
            width: effectiveSize,
            height: effectiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: widget.showBorder
                  ? Border.all(
                      color: backgroundColor,
                      width: widget.height,
                    )
                  : null,
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
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeBase,
                fontWeight: FontWeight.w600,
                color: sketchTheme?.textColor ?? SketchDesignTokens.base900,
              ),
            )
          else if (widget.centerText != null)
            Text(
              widget.centerText!,
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeSm,
                color: sketchTheme?.textSecondaryColor ?? SketchDesignTokens.base700,
              ),
            ),
        ],
      ),
    );
  }
}

/// 손그림 스타일 Linear 프로그레스 CustomPainter
///
/// SketchPainter와 동일한 알고리즘으로 불규칙 pill 테두리 + 노이즈 텍스처 렌더링.
/// 트랙 배경과 진행 fill을 하나의 paint pass에서 처리.
class _SketchLinearProgressPainter extends CustomPainter {
  final double? progress;
  final double indeterminatePosition;
  final Color progressColor;
  final Color backgroundColor;
  final Color borderColor;
  final double strokeWidth;
  final double roughness;
  final int seed;
  final bool showBorder;

  const _SketchLinearProgressPainter({
    required this.progress,
    this.indeterminatePosition = 0.0,
    required this.progressColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.strokeWidth,
    required this.roughness,
    required this.seed,
    required this.showBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // width나 height가 너무 작으면 그릴 수 없음
    if (size.width < 1 || size.height < 1) return;

    final random = Random(seed);
    final inset = showBorder ? strokeWidth / 2 : 0.0;
    final trackRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final radius = min(trackRect.height / 2, trackRect.width / 2);

    // 트랙 경로 (스케치 스타일 pill)
    final trackPath = _createSketchPath(trackRect, radius, random);

    // 1. 트랙 배경 채우기
    canvas.drawPath(
      trackPath,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    // 2. 트랙 배경 노이즈
    if (backgroundColor.a > 0.01) {
      canvas.save();
      canvas.clipPath(trackPath);
      _drawNoise(canvas, size, seed + 1000, backgroundColor);
      canvas.restore();
    }

    // 3. 진행 fill (트랙에 클리핑)
    final fillProgress = progress;
    if (fillProgress != null && fillProgress > 0) {
      canvas.save();
      canvas.clipPath(trackPath);

      final fillWidth = trackRect.width * fillProgress + inset;
      final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
      canvas.drawRect(
        fillRect,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.fill,
      );

      // fill 위 노이즈 (색상 반전)
      canvas.clipRect(fillRect);
      _drawNoise(canvas, Size(fillWidth, size.height), seed + 2000, progressColor);
      canvas.restore();
    } else if (fillProgress == null) {
      // Indeterminate: 30% 폭 fill이 좌→우 슬라이드
      canvas.save();
      canvas.clipPath(trackPath);

      final fillWidth = size.width * 0.3;
      final maxTravel = size.width - fillWidth;
      final xOffset = maxTravel * indeterminatePosition;
      final fillRect = Rect.fromLTWH(xOffset, 0, fillWidth, size.height);

      canvas.drawRect(
        fillRect,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }

    // 4. 트랙 테두리
    if (showBorder) {
      canvas.drawPath(
        trackPath,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  /// 노이즈 텍스처 그리기 — 배경색 명도에 따라 dot 색상 자동 결정
  void _drawNoise(Canvas canvas, Size size, int noiseSeed, Color baseColor) {
    // 밝은 배경에는 검정 점, 어두운 배경에는 흰 점
    final isLight = baseColor.computeLuminance() > 0.5;
    final dotColor = isLight
        ? Colors.black.withValues(alpha: SketchDesignTokens.noiseIntensity)
        : Colors.white.withValues(alpha: SketchDesignTokens.noiseIntensity);

    final noisePaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final noiseRandom = Random(noiseSeed);
    final dotCount = (size.width * size.height / 100).toInt().clamp(20, 300);

    for (int i = 0; i < dotCount; i++) {
      final x = noiseRandom.nextDouble() * size.width;
      final y = noiseRandom.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        SketchDesignTokens.noiseGrainSize / 2,
        noisePaint,
      );
    }
  }

  /// SketchPainter와 동일한 스케치 경로 생성 알고리즘
  Path _createSketchPath(Rect rect, double radius, Random random) {
    if (roughness <= 0.01) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    }

    final idealPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final metrics = idealPath.computeMetrics().toList();
    if (metrics.isEmpty) return idealPath;

    final metric = metrics.first;
    final totalLength = metric.length;

    final numPoints = (totalLength / 6).round().clamp(20, 200);
    final maxJitter = roughness * 0.6;

    final points = <Offset>[];

    for (int i = 0; i < numPoints; i++) {
      final distance = totalLength * i / numPoints;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
        points.add(tangent.position + normal * jitter);
      }
    }

    if (points.length < 3) return idealPath;

    final sketchPath = Path();
    sketchPath.moveTo(
      (points.last.dx + points.first.dx) / 2,
      (points.last.dy + points.first.dy) / 2,
    );

    for (int i = 0; i < points.length; i++) {
      final curr = points[i];
      final next = points[(i + 1) % points.length];
      final midX = (curr.dx + next.dx) / 2;
      final midY = (curr.dy + next.dy) / 2;
      sketchPath.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
    }

    sketchPath.close();
    return sketchPath;
  }

  @override
  bool shouldRepaint(covariant _SketchLinearProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        indeterminatePosition != oldDelegate.indeterminatePosition ||
        progressColor != oldDelegate.progressColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        showBorder != oldDelegate.showBorder;
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