import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 스케치 스타일 UI 요소를 렌더링하는 CustomPainter.
///
/// Frame0 스타일의 미학을 생성함:
/// - 손으로 그린 느낌의 불규칙한 테두리
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

  /// 스케치 테두리 그리기 여부.
  final bool showBorder;

  /// 테두리의 둥근 모서리 반경.
  ///
  /// 기본값은 irregularBorderRadius (12.0).
  /// 알약(pill) 모양은 9999 사용.
  final double borderRadius;

  const SketchPainter({
    required this.fillColor,
    required this.borderColor,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.bowing = SketchDesignTokens.bowing,
    this.seed = 0,
    this.enableNoise = true,
    this.showBorder = true,
    this.borderRadius = SketchDesignTokens.irregularBorderRadius,
  });

  /// 외부에서 ClipPath에 사용할 수 있도록 경로를 생성하는 정적 메서드.
  ///
  /// ClipPath 위젯에서 컨텐츠를 스케치 스타일 둥근 사각형으로 클리핑할 때 사용.
  ///
  /// **사용법:**
  /// ```dart
  /// ClipPath(
  ///   clipper: _SketchClipper(
  ///     SketchPainter.createClipPath(
  ///       size: Size(100, 100),
  ///       roughness: 0.8,
  ///       seed: 42,
  ///       borderRadius: 6.0,
  ///       strokeWidth: 2.0,
  ///     ),
  ///   ),
  ///   child: Image.network(imageUrl),
  /// )
  /// ```
  static Path createClipPath({
    required Size size,
    required double roughness,
    required int seed,
    required double borderRadius,
    double strokeWidth = 0,
  }) {
    final random = Random(seed);
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final r = min(borderRadius, min(rect.width, rect.height) / 2);

    return _createSketchPathStatic(rect, r, random, roughness);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final inset = showBorder ? strokeWidth / 2 : 0.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final r = min(borderRadius, min(rect.width, rect.height) / 2);

    // 스케치 스타일 경로 생성
    final sketchPath = _createSketchPathStatic(rect, r, random, roughness);

    // 1. 채우기
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(sketchPath, fillPaint);

    // 2. 노이즈 텍스처 (스케치 경로 내부에만 렌더링)
    if (enableNoise && fillColor.a > 0.01) {
      canvas.save();
      canvas.clipPath(sketchPath);
      _drawNoiseTexture(canvas, size);
      canvas.restore();
    }

    // 3. 테두리
    if (showBorder) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(sketchPath, borderPaint);
    }
  }

  /// 종이 같은 질감을 위한 미묘한 노이즈 텍스처를 그림.
  void _drawNoiseTexture(Canvas canvas, Size size) {
    final noisePaint = Paint()
      ..color = Colors.black.withValues(alpha: SketchDesignTokens.noiseIntensity)
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

  /// 손으로 그린 스타일의 둥근 사각형 경로를 생성함 (정적 버전).
  ///
  /// 기본 RRect 경로를 따라 포인트를 균등 샘플링하고,
  /// 법선 방향으로 약간의 무작위 변위를 추가하여 스케치 느낌을 만듦.
  static Path _createSketchPathStatic(
    Rect rect,
    double radius,
    Random random,
    double roughness,
  ) {
    if (roughness <= 0.01) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    }

    // 기본 RRect 경로 생성
    final idealPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    // 경로 메트릭으로 포인트 샘플링
    final metrics = idealPath.computeMetrics().toList();
    if (metrics.isEmpty) return idealPath;

    final metric = metrics.first;
    final totalLength = metric.length;

    // 약 6px마다 포인트 하나 샘플링
    final numPoints = (totalLength / 6).round().clamp(20, 200);
    final maxJitter = roughness * 1.0;

    final points = <Offset>[];

    for (int i = 0; i < numPoints; i++) {
      final distance = totalLength * i / numPoints;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        // 법선 방향 (접선에 수직) 으로 jitter 적용
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
        points.add(tangent.position + normal * jitter);
      }
    }

    if (points.length < 3) return idealPath;

    // 이차 베지어 곡선으로 부드럽게 연결
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
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        bowing != oldDelegate.bowing ||
        seed != oldDelegate.seed ||
        enableNoise != oldDelegate.enableNoise ||
        showBorder != oldDelegate.showBorder ||
        borderRadius != oldDelegate.borderRadius;
  }
}
