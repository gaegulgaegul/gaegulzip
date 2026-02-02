import 'dart:math';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 손으로 그린 스케치 스타일 UI 요소를 렌더링하는 CustomPainter.
///
/// Frame0 스타일의 와이어프레임 미학을 생성함:
/// - Bézier 곡선을 사용한 불규칙하고 흔들리는 테두리
/// - 손으로 그린 효과를 위한 여러 겹의 스트로크
/// - 종이 같은 질감을 위한 선택적 노이즈 텍스처 채우기
/// - 재현 가능한 렌더링을 위한 시드 기반 무작위성
///
/// **사용법:**
/// ```dart
/// CustomPaint(
///   painter: SketchPainter(
///     fillColor: Colors.white,
///     borderColor: SketchDesignTokens.accentPrimary,
///     strokeWidth: SketchDesignTokens.strokeBold,
///     roughness: 1.0, // 더 스케치 같은 효과
///     seed: 42, // 재현 가능한 무작위성
///   ),
///   child: child,
/// )
/// ```
class SketchPainter extends CustomPainter {
  /// 도형 내부의 채우기 색상.
  final Color fillColor;

  /// 테두리/스트로크 색상.
  final Color borderColor;

  /// 스트로크의 너비 (기본값: strokeStandard = 2.0).
  final double strokeWidth;

  /// 거칠기 계수 (0.0-1.0+) - 흔들림 정도를 제어함.
  ///
  /// - 0.0: 부드러움, 스케치 효과 없음
  /// - 0.8: 권장 기본값
  /// - 1.0+: 매우 스케치 같은 효과
  final double roughness;

  /// 휘어짐 계수 - 직선이 얼마나 곡선으로 변하는지 제어함.
  final double bowing;

  /// 재현 가능한 렌더링을 위한 무작위 시드.
  ///
  /// 동일한 시드 = 매번 동일한 스케치 모양.
  /// 다른 시드 = 다른 변형.
  final int seed;

  /// 노이즈 텍스처 채우기 그리기 여부.
  final bool enableNoise;

  const SketchPainter({
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
    // 1. 선택적 노이즈 텍스처와 함께 채우기를 그림
    _drawNoisyFill(canvas, size);

    // 2. 여러 스트로크로 불규칙한 스케치 테두리를 그림
    _drawSketchyBorder(canvas, size);
  }

  /// 선택적 노이즈 텍스처 오버레이와 함께 채우기 색상을 그림.
  void _drawNoisyFill(Canvas canvas, Size size) {
    // 기본 채우기
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(SketchDesignTokens.irregularBorderRadius),
    );

    canvas.drawRRect(fillRect, fillPaint);

    // 노이즈가 활성화되어 있으면 노이즈 텍스처 추가
    if (enableNoise && fillColor.opacity > 0.01) {
      _drawNoiseTexture(canvas, size);
    }
  }

  /// 종이 같은 질감을 위한 미묘한 노이즈 텍스처를 그림.
  void _drawNoiseTexture(Canvas canvas, Size size) {
    final noisePaint = Paint()
      ..color = Colors.black.withOpacity(SketchDesignTokens.noiseIntensity)
      ..style = PaintingStyle.fill;

    final random = Random(seed + 1000); // 노이즈용 다른 시드
    final dotCount = (size.width * size.height / 100).toInt().clamp(50, 500);

    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        SketchDesignTokens.noiseGrainSize / 2,
        noisePaint,
      );
    }
  }

  /// 여러 겹의 스트로크로 불규칙한 테두리를 그림.
  void _drawSketchyBorder(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final random = Random(seed);

    // 진정한 손으로 그린 효과를 위해 2-3개의 약간 오프셋된 경로를 그림
    final strokeCount = roughness > 0.5 ? 2 : 1;

    for (int i = 0; i < strokeCount; i++) {
      // 각 스트로크마다 약간 다른 경로를 생성
      final path = _createIrregularPath(size, random, iteration: i);
      canvas.drawPath(path, borderPaint);
    }
  }

  /// 흔들림과 휘어짐이 있는 불규칙한 둥근 사각형 경로를 생성함.
  Path _createIrregularPath(Size size, Random random, {int iteration = 0}) {
    final path = Path();
    final radius = SketchDesignTokens.irregularBorderRadius;

    // 각 반복마다 작은 오프셋 추가 (다중 스트로크 효과)
    final iterationOffset = iteration * 0.3;

    // 거칠기가 적용된 모서리 점들
    final topLeft = _addRoughness(
      Offset(radius, 0 + iterationOffset),
      random,
    );
    final topRight = _addRoughness(
      Offset(size.width - radius, 0 + iterationOffset),
      random,
    );
    final bottomRight = _addRoughness(
      Offset(size.width - radius, size.height - iterationOffset),
      random,
    );
    final bottomLeft = _addRoughness(
      Offset(radius, size.height - iterationOffset),
      random,
    );

    // 왼쪽 위 모서리 호
    path.moveTo(topLeft.dx, topLeft.dy);

    // 휘어짐이 있는 위쪽 가장자리
    final topControl = _addBowing(topLeft, topRight, random);
    path.quadraticBezierTo(
      topControl.dx,
      topControl.dy,
      topRight.dx,
      topRight.dy,
    );

    // 오른쪽 위 모서리 호에서 오른쪽 가장자리로
    final rightStart = _addRoughness(
      Offset(size.width - iterationOffset, radius),
      random,
    );
    path.quadraticBezierTo(
      size.width - iterationOffset + _randomOffset(random),
      radius / 2 + _randomOffset(random),
      rightStart.dx,
      rightStart.dy,
    );

    // 휘어짐이 있는 오른쪽 가장자리
    final rightControl = _addBowing(rightStart, bottomRight, random);
    path.quadraticBezierTo(
      rightControl.dx,
      rightControl.dy,
      bottomRight.dx,
      bottomRight.dy,
    );

    // 오른쪽 아래 모서리 호에서 아래쪽 가장자리로
    final bottomStart = _addRoughness(
      Offset(size.width - radius, size.height - iterationOffset),
      random,
    );
    path.quadraticBezierTo(
      size.width - radius / 2 + _randomOffset(random),
      size.height - iterationOffset + _randomOffset(random),
      bottomStart.dx,
      bottomStart.dy,
    );

    // 휘어짐이 있는 아래쪽 가장자리
    final bottomControl = _addBowing(bottomStart, bottomLeft, random);
    path.quadraticBezierTo(
      bottomControl.dx,
      bottomControl.dy,
      bottomLeft.dx,
      bottomLeft.dy,
    );

    // 왼쪽 아래 모서리 호에서 왼쪽 가장자리로
    final leftStart = _addRoughness(
      Offset(0 + iterationOffset, size.height - radius),
      random,
    );
    path.quadraticBezierTo(
      radius / 2 + _randomOffset(random),
      size.height - radius / 2 + _randomOffset(random),
      leftStart.dx,
      leftStart.dy,
    );

    // 휘어짐이 있는 왼쪽 가장자리
    final leftControl = _addBowing(leftStart, topLeft, random);
    path.quadraticBezierTo(
      leftControl.dx,
      leftControl.dy,
      topLeft.dx,
      topLeft.dy,
    );

    path.close();
    return path;
  }

  /// 거칠기에 따라 점에 무작위 오프셋을 추가함.
  Offset _addRoughness(Offset point, Random random) {
    if (roughness == 0) return point;

    final dx = point.dx + (random.nextDouble() - 0.5) * roughness * 2;
    final dy = point.dy + (random.nextDouble() - 0.5) * roughness * 2;

    return Offset(dx, dy);
  }

  /// 휘어짐 효과를 위한 제어점을 계산함.
  Offset _addBowing(Offset start, Offset end, Random random) {
    final mid = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    if (bowing == 0) return mid;

    // 휘어짐을 위한 수직 오프셋 추가
    final offset = (random.nextDouble() - 0.5) * bowing * 10;

    return Offset(mid.dx + offset, mid.dy + offset);
  }

  /// 작은 무작위 오프셋 값을 가져옴.
  double _randomOffset(Random random) {
    return (random.nextDouble() - 0.5) * roughness;
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        bowing != oldDelegate.bowing ||
        seed != oldDelegate.seed ||
        enableNoise != oldDelegate.enableNoise;
  }
}
