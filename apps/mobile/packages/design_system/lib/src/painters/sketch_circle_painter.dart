import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 스케치 스타일 원과 타원을 렌더링하는 CustomPainter.
///
/// 불규칙하고 흔들리는 가장자리를 가진 손으로 그린 듯한 원형 도형을 생성함.
/// 원형 버튼, 배지, 아바타 또는 장식 요소에 사용 가능.
///
/// **기본 사용법:**
/// ```dart
/// CustomPaint(
///   painter: SketchCirclePainter(
///     fillColor: Colors.blue,
///     borderColor: Colors.black,
///   ),
///   child: SizedBox(width: 100, height: 100),
/// )
/// ```
///
/// **타원 (가로세로 비율이 다른 원):**
/// ```dart
/// CustomPaint(
///   painter: SketchCirclePainter(
///     fillColor: Colors.red,
///     borderColor: Colors.black,
///   ),
///   child: SizedBox(width: 150, height: 100), // 타원 형태
/// )
/// ```
///
/// **높은 roughness를 가진 배지:**
/// ```dart
/// CustomPaint(
///   painter: SketchCirclePainter(
///     fillColor: SketchDesignTokens.error,
///     borderColor: SketchDesignTokens.error,
///     roughness: 1.5,
///     strokeWidth: SketchDesignTokens.strokeBold,
///   ),
///   child: SizedBox(width: 24, height: 24),
/// )
/// ```
///
/// **테두리만 있는 투명한 원:**
/// ```dart
/// CustomPaint(
///   painter: SketchCirclePainter(
///     fillColor: Colors.transparent,
///     borderColor: SketchDesignTokens.accentPrimary,
///     strokeWidth: SketchDesignTokens.strokeBold,
///   ),
///   child: SizedBox(width: 80, height: 80),
/// )
/// ```
class SketchCirclePainter extends CustomPainter {
  /// 원 내부의 채우기 색상.
  final Color fillColor;

  /// 테두리/선 색상.
  final Color borderColor;

  /// 테두리의 선 두께.
  final double strokeWidth;

  /// 가장자리 흔들림의 거칠기 계수 (0.0-1.0+).
  ///
  /// - 0.0: 완벽한 원
  /// - 0.8: 기본값, 은은한 손으로 그린 효과
  /// - 1.5+: 매우 불규칙하고 거친 원
  final double roughness;

  /// 재현 가능한 외형을 위한 랜덤 시드.
  ///
  /// 같은 시드 = 매번 동일한 원
  final int seed;

  /// 원을 근사하는 세그먼트 수.
  ///
  /// 세그먼트가 많을수록 = 더 부드러운 곡선
  /// 기본값: 16 (좋은 균형)
  final int segments;

  /// 노이즈 텍스처 채우기 활성화 여부.
  final bool enableNoise;

  const SketchCirclePainter({
    required this.fillColor,
    required this.borderColor,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
    this.segments = 16,
    this.enableNoise = false,
  }) : assert(segments >= 8, 'Segments must be at least 8');

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2;
    final radiusY = size.height / 2;

    // 채우기 그리기
    if (fillColor != Colors.transparent) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final fillPath = _createIrregularCircle(center, radiusX, radiusY, random);
      canvas.drawPath(fillPath, fillPaint);

      // 활성화된 경우 노이즈 텍스처 그리기
      if (enableNoise) {
        _drawNoiseTexture(canvas, size, random);
      }
    }

    // 테두리 그리기 (손으로 그린 효과를 위한 2개 선)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 2; i++) {
      final borderPath = _createIrregularCircle(
        center,
        radiusX - strokeWidth / 2,
        radiusY - strokeWidth / 2,
        Random(seed + i * 100),
      );
      canvas.drawPath(borderPath, borderPaint);
    }
  }

  /// 이차 베지어 곡선을 사용하여 불규칙한 원 경로 생성.
  Path _createIrregularCircle(
    Offset center,
    double radiusX,
    double radiusY,
    Random random,
  ) {
    final path = Path();

    // 점에 거칠기를 추가하는 헬퍼 함수
    Offset addRoughness(double angle, double rx, double ry) {
      final offsetRadius = roughness * 2;
      final irregularRx = rx + (random.nextDouble() - 0.5) * offsetRadius;
      final irregularRy = ry + (random.nextDouble() - 0.5) * offsetRadius;

      final x = center.dx + cos(angle) * irregularRx;
      final y = center.dy + sin(angle) * irregularRy;

      return Offset(x, y);
    }

    // 타원 주변의 점들 생성
    Offset? firstPoint;

    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final point = addRoughness(angle, radiusX, radiusY);

      if (i == 0) {
        firstPoint = point;
        path.moveTo(point.dx, point.dy);
      } else {
        // 더 부드러운 곡선을 위한 제어점 사용
        final prevAngle = ((i - 1) / segments) * 2 * pi;
        final prevPoint = addRoughness(prevAngle, radiusX, radiusY);

        // 이전 점과 현재 점 사이의 제어점
        final controlAngle = (prevAngle + angle) / 2;
        final controlRadius = roughness * (random.nextDouble() - 0.5);
        final controlX = center.dx + cos(controlAngle) * (radiusX + controlRadius);
        final controlY = center.dy + sin(controlAngle) * (radiusY + controlRadius);

        path.quadraticBezierTo(controlX, controlY, point.dx, point.dy);
      }
    }

    path.close();
    return path;
  }

  /// 종이 같은 외형을 위한 노이즈 텍스처 그리기.
  void _drawNoiseTexture(Canvas canvas, Size size, Random random) {
    final noisePaint = Paint()
      ..color = Colors.black.withOpacity(SketchDesignTokens.noiseIntensity)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2;
    final radiusY = size.height / 2;

    // 면적 기준으로 점 개수 계산
    final area = pi * radiusX * radiusY;
    final dotCount = (area / 100).toInt();

    for (int i = 0; i < dotCount; i++) {
      // 타원 내부의 랜덤 점 생성
      final angle = random.nextDouble() * 2 * pi;
      final r = sqrt(random.nextDouble()); // 균등 분포를 위한 제곱근

      final x = center.dx + cos(angle) * r * radiusX;
      final y = center.dy + sin(angle) * r * radiusY;

      final grainSize = SketchDesignTokens.noiseGrainSize;
      canvas.drawCircle(Offset(x, y), grainSize, noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SketchCirclePainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        segments != oldDelegate.segments ||
        enableNoise != oldDelegate.enableNoise;
  }
}
