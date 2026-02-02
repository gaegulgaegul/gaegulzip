import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 애니메이션 스케치 CustomPainter
///
/// 손으로 그리는 듯한 애니메이션 효과를 제공.
/// 경로를 점진적으로 그려나가는 효과.
///
/// **기본 사용법:**
/// ```dart
/// class AnimatedSketchExample extends StatefulWidget {
///   @override
///   State<AnimatedSketchExample> createState() => _AnimatedSketchExampleState();
/// }
///
/// class _AnimatedSketchExampleState extends State<AnimatedSketchExample>
///     with SingleTickerProviderStateMixin {
///   late AnimationController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = AnimationController(
///       duration: Duration(seconds: 2),
///       vsync: this,
///     )..forward();
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return AnimatedBuilder(
///       animation: _controller,
///       builder: (context, child) {
///         return CustomPaint(
///           painter: AnimatedSketchPainter(
///             progress: _controller.value,
///             fillColor: Colors.blue,
///             borderColor: Colors.black,
///           ),
///           child: SizedBox(width: 200, height: 100),
///         );
///       },
///     );
///   }
/// }
/// ```
///
/// **반복 애니메이션:**
/// ```dart
/// _controller.repeat();
/// ```
///
/// **역방향 애니메이션:**
/// ```dart
/// _controller.reverse();
/// ```
class AnimatedSketchPainter extends CustomPainter {
  /// 애니메이션 진행률 (0.0 ~ 1.0)
  final double progress;

  /// 채우기 색상
  final Color fillColor;

  /// 테두리 색상
  final Color borderColor;

  /// 선 두께
  final double strokeWidth;

  /// 거칠기 계수
  final double roughness;

  /// 휘어짐 계수
  final double bowing;

  /// 랜덤 시드
  final int seed;

  /// 노이즈 텍스처 활성화
  final bool enableNoise;

  const AnimatedSketchPainter({
    required this.progress,
    required this.fillColor,
    required this.borderColor,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.bowing = SketchDesignTokens.bowing,
    this.seed = 0,
    this.enableNoise = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final random = Random(seed);

    // 불규칙한 경로 생성
    final path = _createIrregularPath(size, random);

    // PathMetric으로 경로를 progress만큼 추출
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      final extractLength = metric.length * progress;

      // 테두리 그리기 (2개 선으로 손그림 효과)
      for (int i = 0; i < 2; i++) {
        final borderPath = metric.extractPath(0.0, extractLength);
        final borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        canvas.drawPath(borderPath, borderPaint);
      }

      // progress가 1.0에 가까우면 채우기 시작
      if (progress > 0.8) {
        final fillProgress = (progress - 0.8) / 0.2; // 0.8~1.0을 0~1로 매핑

        final fillPaint = Paint()
          ..color = fillColor.withOpacity(fillProgress)
          ..style = PaintingStyle.fill;

        canvas.drawPath(path, fillPaint);

        // 노이즈 텍스처
        if (enableNoise && progress >= 1.0) {
          _drawNoiseTexture(canvas, size, random);
        }
      }
    }
  }

  /// 불규칙한 둥근 사각형 경로 생성
  Path _createIrregularPath(Size size, Random random) {
    final path = Path();
    final radius = SketchDesignTokens.irregularBorderRadius;

    // Helper: 점에 불규칙성 추가
    Offset addRoughness(Offset point) {
      final offsetX = (random.nextDouble() - 0.5) * roughness * 2;
      final offsetY = (random.nextDouble() - 0.5) * roughness * 2;
      return point.translate(offsetX, offsetY);
    }

    // Helper: 곡선 제어점에 휘어짐 추가
    Offset addBowing(Offset start, Offset end) {
      final midX = (start.dx + end.dx) / 2;
      final midY = (start.dy + end.dy) / 2;
      final bowOffset = (random.nextDouble() - 0.5) * bowing * 20;

      // 선에 수직인 방향으로 휘어짐
      final angle = atan2(end.dy - start.dy, end.dx - start.dx) + pi / 2;
      final controlX = midX + cos(angle) * bowOffset;
      final controlY = midY + sin(angle) * bowOffset;

      return Offset(controlX, controlY);
    }

    // 4개의 모서리 점
    final topLeft = addRoughness(Offset(radius, 0));
    final topRight = addRoughness(Offset(size.width - radius, 0));
    final bottomRight = addRoughness(Offset(size.width - radius, size.height));
    final bottomLeft = addRoughness(Offset(radius, size.height));

    // 경로 그리기 시작
    path.moveTo(topLeft.dx, topLeft.dy);

    // 위쪽 변
    final topControl = addBowing(topLeft, topRight);
    path.quadraticBezierTo(
      topControl.dx,
      topControl.dy,
      topRight.dx,
      topRight.dy,
    );

    // 오른쪽 변
    final rightControl = addBowing(topRight, bottomRight);
    path.quadraticBezierTo(
      rightControl.dx,
      rightControl.dy,
      bottomRight.dx,
      bottomRight.dy,
    );

    // 아래쪽 변
    final bottomControl = addBowing(bottomRight, bottomLeft);
    path.quadraticBezierTo(
      bottomControl.dx,
      bottomControl.dy,
      bottomLeft.dx,
      bottomLeft.dy,
    );

    // 왼쪽 변
    final leftControl = addBowing(bottomLeft, topLeft);
    path.quadraticBezierTo(
      leftControl.dx,
      leftControl.dy,
      topLeft.dx,
      topLeft.dy,
    );

    path.close();
    return path;
  }

  /// 노이즈 텍스처 그리기
  void _drawNoiseTexture(Canvas canvas, Size size, Random random) {
    final noisePaint = Paint()
      ..color = Colors.black.withOpacity(SketchDesignTokens.noiseIntensity)
      ..style = PaintingStyle.fill;

    final dotCount = (size.width * size.height / 100).toInt();

    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final grainSize = SketchDesignTokens.noiseGrainSize;
      canvas.drawCircle(Offset(x, y), grainSize, noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedSketchPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        bowing != oldDelegate.bowing ||
        seed != oldDelegate.seed ||
        enableNoise != oldDelegate.enableNoise;
  }
}
