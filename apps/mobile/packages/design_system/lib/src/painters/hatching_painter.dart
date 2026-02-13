import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 대각선 빗금 패턴을 렌더링하는 CustomPainter.
///
/// SketchButton.hatching 스타일에서 사용되며,
/// 손으로 그린 스타일의 대각선 빗금 선을 반복 렌더링함.
///
/// **렌더링 순서:**
/// 1. RRect 버튼 경로 생성
/// 2. canvas.clipPath(buttonPath) - 버튼 내부만 렌더링
/// 3. 대각선 빗금 선 반복 생성 (간격 6dp, 45도 각도)
/// 4. 각 빗금 선에 스케치 효과 적용 (4px 간격 포인트 샘플링, jitter ±roughness*0.4)
///
/// **사용법:**
/// ```dart
/// CustomPaint(
///   painter: HatchingPainter(
///     fillColor: Colors.black,
///     strokeWidth: 1.0,
///     angle: pi / 4, // 45도
///     spacing: 6.0,
///     roughness: 0.5,
///     seed: 42,
///     borderRadius: 12.0,
///   ),
/// )
/// ```
class HatchingPainter extends CustomPainter {
  /// 빗금 선 색상.
  final Color fillColor;

  /// 빗금 선 두께 (기본값: 1.0).
  final double strokeWidth;

  /// 빗금 각도 (기본값: 45도 = π/4).
  final double angle;

  /// 빗금 선 간격 (기본값: 6.0).
  final double spacing;

  /// 거칠기 계수 (기본값: 0.5 — 버튼보다 미묘함).
  final double roughness;

  /// 재현 가능한 무작위 시드.
  final int seed;

  /// 테두리 둥글기 (버튼 borderRadius와 일치).
  final double borderRadius;

  const HatchingPainter({
    required this.fillColor,
    this.strokeWidth = 1.0,
    this.angle = pi / 4, // 45도
    this.spacing = 6.0,
    this.roughness = 0.5,
    this.seed = 0,
    this.borderRadius = SketchDesignTokens.irregularBorderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 버튼 경로 생성 (클립 영역)
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final r = min(borderRadius, min(size.width, size.height) / 2);
    final buttonPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));

    // 2. 클립 - 버튼 내부만 렌더링
    canvas.save();
    canvas.clipPath(buttonPath);

    // 3. 빗금 선 생성
    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    final numLines = (diagonal / spacing).ceil();

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = -numLines; i <= numLines; i++) {
      final offset = i * spacing;

      // angle 각도 방향으로 선 계산
      final cosA = cos(angle);
      final sinA = sin(angle);

      // 법선 방향(angle에 수직)으로 offset 이동
      final perpX = -sinA * offset;
      final perpY = cosA * offset;

      // angle 방향으로 선 그리기
      final startX = perpX;
      final startY = perpY;
      final endX = perpX + cosA * diagonal;
      final endY = perpY + sinA * diagonal;

      final start = Offset(startX, startY);
      final end = Offset(endX, endY);

      final random = Random(seed + i); // 각 선마다 다른 시드
      final maxJitter = roughness * 0.4;

      final linePath = _createSketchLine(start, end, random, maxJitter);
      canvas.drawPath(linePath, paint);
    }

    canvas.restore();
  }

  /// 손으로 그린 스타일의 선 경로를 생성함.
  ///
  /// 이상적 직선 경로를 따라 포인트를 4px 간격으로 샘플링하고,
  /// 법선 방향으로 무작위 변위를 추가하여 스케치 느낌을 만듦.
  Path _createSketchLine(
      Offset start, Offset end, Random random, double maxJitter) {
    // roughness가 매우 작으면 직선 폴백
    if (roughness <= 0.01) {
      return Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
    }

    final distance = (end - start).distance;

    // 4px 간격으로 포인트 샘플링
    final numPoints = (distance / 4).round().clamp(3, 50);

    final points = <Offset>[];
    for (int i = 0; i < numPoints; i++) {
      final t = i / (numPoints - 1);
      final point = Offset.lerp(start, end, t)!;

      // 법선 방향 (선에 수직)
      final tangent = (end - start) / distance;
      final normal = Offset(-tangent.dy, tangent.dx);
      final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;

      points.add(point + normal * jitter);
    }

    if (points.length < 2) {
      return Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
    }

    // 이차 베지어 곡선으로 부드럽게 연결
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final curr = points[i];
      final next = points[i + 1];
      final midX = (curr.dx + next.dx) / 2;
      final midY = (curr.dy + next.dy) / 2;
      path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
    }

    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant HatchingPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        angle != oldDelegate.angle ||
        spacing != oldDelegate.spacing ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        borderRadius != oldDelegate.borderRadius;
  }
}
