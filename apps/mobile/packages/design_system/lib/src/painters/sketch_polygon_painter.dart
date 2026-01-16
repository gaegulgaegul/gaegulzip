import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 손그림 스타일 다각형 CustomPainter
///
/// 불규칙한 손그림 느낌의 다각형을 그림.
/// 삼각형, 사각형, 오각형, 육각형 등 다양한 다각형 지원.
///
/// **삼각형:**
/// ```dart
/// CustomPaint(
///   painter: SketchPolygonPainter(
///     sides: 3,
///     fillColor: Colors.blue,
///     borderColor: Colors.black,
///   ),
///   child: SizedBox(width: 100, height: 100),
/// )
/// ```
///
/// **육각형:**
/// ```dart
/// CustomPaint(
///   painter: SketchPolygonPainter(
///     sides: 6,
///     fillColor: SketchDesignTokens.accentPrimary,
///     borderColor: SketchDesignTokens.accentPrimary,
///   ),
///   child: SizedBox(width: 80, height: 80),
/// )
/// ```
///
/// **별 모양 (pointy):**
/// ```dart
/// CustomPaint(
///   painter: SketchPolygonPainter(
///     sides: 5,
///     pointy: true,
///     fillColor: SketchDesignTokens.warning,
///     borderColor: SketchDesignTokens.warning,
///   ),
///   child: SizedBox(width: 100, height: 100),
/// )
/// ```
///
/// **회전:**
/// ```dart
/// CustomPaint(
///   painter: SketchPolygonPainter(
///     sides: 4,
///     rotation: pi / 4, // 45도 회전
///     fillColor: Colors.green,
///     borderColor: Colors.black,
///   ),
///   child: SizedBox(width: 100, height: 100),
/// )
/// ```
class SketchPolygonPainter extends CustomPainter {
  /// 변의 개수 (3 이상)
  final int sides;

  /// 채우기 색상
  final Color fillColor;

  /// 테두리 색상
  final Color borderColor;

  /// 선 두께
  final double strokeWidth;

  /// 거칠기 계수 (0.0-1.0+)
  ///
  /// - 0.0: 완벽한 다각형
  /// - 0.8: 기본값, 은은한 손그림
  /// - 1.5+: 매우 불규칙한 다각형
  final double roughness;

  /// 랜덤 시드
  final int seed;

  /// 회전 각도 (라디안)
  final double rotation;

  /// 별 모양 여부 (true이면 안쪽 점 추가)
  final bool pointy;

  /// 별 모양일 때 안쪽 점의 반경 비율 (0.0-1.0)
  final double innerRadiusRatio;

  /// 노이즈 텍스처 활성화 여부
  final bool enableNoise;

  const SketchPolygonPainter({
    required this.sides,
    required this.fillColor,
    required this.borderColor,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
    this.rotation = 0.0,
    this.pointy = false,
    this.innerRadiusRatio = 0.5,
    this.enableNoise = false,
  }) : assert(sides >= 3, '변의 개수는 3 이상이어야 함');

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 채우기
    if (fillColor != Colors.transparent) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final fillPath = _createIrregularPolygon(center, radius, random);
      canvas.drawPath(fillPath, fillPaint);

      // 노이즈 텍스처
      if (enableNoise) {
        _drawNoiseTexture(canvas, size, random);
      }
    }

    // 테두리 (2개 선으로 손그림 효과)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 2; i++) {
      final borderPath = _createIrregularPolygon(
        center,
        radius - strokeWidth / 2,
        Random(seed + i * 100),
      );
      canvas.drawPath(borderPath, borderPaint);
    }
  }

  /// 불규칙한 다각형 경로 생성
  Path _createIrregularPolygon(Offset center, double radius, Random random) {
    final path = Path();

    final actualSides = pointy ? sides * 2 : sides;
    final anglePerSide = 2 * pi / actualSides;

    Offset? firstPoint;

    for (int i = 0; i <= actualSides; i++) {
      final angle = i * anglePerSide + rotation - pi / 2;

      // 별 모양이면 안쪽/바깥쪽 교대로
      final currentRadius = pointy && i % 2 == 1
          ? radius * innerRadiusRatio
          : radius;

      // 불규칙성 추가
      final offsetRadius = currentRadius + (random.nextDouble() - 0.5) * roughness * 4;

      final x = center.dx + cos(angle) * offsetRadius;
      final y = center.dy + sin(angle) * offsetRadius;
      final point = Offset(x, y);

      if (i == 0) {
        firstPoint = point;
        path.moveTo(point.dx, point.dy);
      } else {
        // Bézier 곡선으로 부드럽게 연결
        final prevAngle = (i - 1) * anglePerSide + rotation - pi / 2;
        final prevRadius = pointy && (i - 1) % 2 == 1
            ? radius * innerRadiusRatio
            : radius;
        final prevOffsetRadius = prevRadius + (random.nextDouble() - 0.5) * roughness * 4;
        final prevX = center.dx + cos(prevAngle) * prevOffsetRadius;
        final prevY = center.dy + sin(prevAngle) * prevOffsetRadius;

        // 제어점
        final controlX = (prevX + x) / 2 + (random.nextDouble() - 0.5) * roughness * 2;
        final controlY = (prevY + y) / 2 + (random.nextDouble() - 0.5) * roughness * 2;

        path.quadraticBezierTo(controlX, controlY, point.dx, point.dy);
      }
    }

    path.close();
    return path;
  }

  /// 노이즈 텍스처 그리기
  void _drawNoiseTexture(Canvas canvas, Size size, Random random) {
    final noisePaint = Paint()
      ..color = Colors.black.withOpacity(SketchDesignTokens.noiseIntensity)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 다각형 영역 내부에만 노이즈 점 그리기
    final dotCount = (size.width * size.height / 100).toInt();

    for (int i = 0; i < dotCount; i++) {
      // 원 내부의 랜덤한 점 생성
      final angle = random.nextDouble() * 2 * pi;
      final r = sqrt(random.nextDouble()) * radius;

      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;

      final grainSize = SketchDesignTokens.noiseGrainSize;
      canvas.drawCircle(Offset(x, y), grainSize, noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SketchPolygonPainter oldDelegate) {
    return sides != oldDelegate.sides ||
        fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        rotation != oldDelegate.rotation ||
        pointy != oldDelegate.pointy ||
        innerRadiusRatio != oldDelegate.innerRadiusRatio ||
        enableNoise != oldDelegate.enableNoise;
  }
}
