import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 손그림 스타일의 X 마크를 렌더링하는 CustomPainter.
///
/// Material Icons.close를 대체하여 Frame0 스케치 스타일의 닫기 버튼을 제공함.
/// 두 개의 대각선(좌상→우하, 우상→좌하)을 path metric 기반으로 렌더링하여
/// 손으로 그린 느낌의 불규칙한 X 모양을 만듦.
///
/// **사용법:**
/// ```dart
/// CustomPaint(
///   painter: SketchXClosePainter(
///     strokeColor: Colors.black,
///     strokeWidth: 2.0,
///     roughness: 0.8,
///     seed: 42,
///   ),
///   child: SizedBox(width: 18, height: 18),
/// )
/// ```
///
/// **SketchModal에서 사용:**
/// ```dart
/// SizedBox(
///   width: 18,
///   height: 18,
///   child: CustomPaint(
///     painter: SketchXClosePainter(
///       strokeColor: theme.iconColor,
///       strokeWidth: SketchDesignTokens.strokeStandard,
///       roughness: SketchDesignTokens.roughness,
///       seed: 42, // 고정 시드로 일관된 X 모양
///     ),
///   ),
/// )
/// ```
class SketchXClosePainter extends CustomPainter {
  /// X 마크 색상.
  final Color strokeColor;

  /// 선 두께 (기본값: 2.0).
  final double strokeWidth;

  /// 거칠기 계수 (기본값: 0.8).
  ///
  /// - 0.0: 부드러운 직선
  /// - 0.8: 권장 기본값, 손그림 효과
  /// - 1.0+: 매우 흔들리는 선
  final double roughness;

  /// 재현 가능한 무작위 시드.
  ///
  /// 동일한 시드 = 매번 동일한 X 모양.
  /// 다른 시드 = 다른 변형.
  final int seed;

  const SketchXClosePainter({
    required this.strokeColor,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final maxJitter = roughness * 0.6;

    // Line 1: 좌상단 → 우하단
    final line1Path = _createSketchLine(
      Offset(2, 2),
      Offset(size.width - 2, size.height - 2),
      random,
      maxJitter,
    );

    // Line 2: 우상단 → 좌하단
    final line2Path = _createSketchLine(
      Offset(size.width - 2, 2),
      Offset(2, size.height - 2),
      Random(seed + 1), // 다른 시드로 다른 변형
      maxJitter,
    );

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(line1Path, paint);
    canvas.drawPath(line2Path, paint);
  }

  /// 손으로 그린 스타일의 선 경로를 생성함.
  ///
  /// [start] 시작점
  /// [end] 끝점
  /// [random] Random 인스턴스
  /// [maxJitter] 최대 흔들림 거리
  ///
  /// Returns: 스케치 스타일의 Path
  Path _createSketchLine(
    Offset start,
    Offset end,
    Random random,
    double maxJitter,
  ) {
    // roughness가 0에 가까우면 직선 폴백
    if (roughness <= 0.01) {
      return Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
    }

    final distance = (end - start).distance;
    final numPoints = (distance / 6).round().clamp(3, 20);

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
  bool shouldRepaint(covariant SketchXClosePainter oldDelegate) {
    return strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed;
  }
}
