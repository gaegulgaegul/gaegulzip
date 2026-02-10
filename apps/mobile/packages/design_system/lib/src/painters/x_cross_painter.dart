import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Frame0 스타일의 X-cross 패턴을 그리는 CustomPainter.
///
/// 이미지 플레이스홀더에서 사용하는 손그림 스타일의 대각선 X 패턴을 렌더링함:
/// - 배경 사각형 (채우기)
/// - 테두리 사각형 (불규칙한 손그림 스타일)
/// - 왼쪽 위 → 오른쪽 아래 대각선
/// - 오른쪽 위 → 왼쪽 아래 대각선
/// - 모든 선은 roughness가 적용된 흔들리는 손그림 효과
///
/// **기본 사용법:**
/// ```dart
/// CustomPaint(
///   painter: XCrossPainter(),
///   child: SizedBox(width: 200, height: 150),
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// CustomPaint(
///   painter: XCrossPainter(
///     lineColor: Colors.red,
///     backgroundColor: Colors.white,
///     borderColor: Colors.black,
///   ),
///   child: SizedBox(width: 200, height: 150),
/// )
/// ```
///
/// **거칠기 조정:**
/// ```dart
/// CustomPaint(
///   painter: XCrossPainter(
///     roughness: 1.2, // 더 흔들리는 효과
///   ),
///   child: SizedBox(width: 200, height: 150),
/// )
/// ```
class XCrossPainter extends CustomPainter {
  /// X-cross 라인 색상.
  final Color lineColor;

  /// 배경 채우기 색상.
  final Color backgroundColor;

  /// 테두리 색상.
  final Color borderColor;

  /// 선 두께.
  final double strokeWidth;

  /// 거칠기 계수 (0.0-1.0+) - 흔들림 정도를 제어함.
  ///
  /// - 0.0: 부드러운 직선
  /// - 0.8: 권장 기본값, 손그림 효과
  /// - 1.0+: 매우 흔들리는 선
  final double roughness;

  /// 재현 가능한 렌더링을 위한 무작위 시드.
  ///
  /// 동일한 시드 = 매번 동일한 모양
  final int seed;

  const XCrossPainter({
    this.lineColor = SketchDesignTokens.base500,
    this.backgroundColor = SketchDesignTokens.base100,
    this.borderColor = SketchDesignTokens.base300,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = 0.8,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    // 1. 배경 사각형 채우기
    _drawBackground(canvas, size);

    // 2. 테두리 사각형 그리기 (불규칙한 손그림 스타일)
    _drawBorder(canvas, size, random);

    // 3. X-cross 라인 그리기
    _drawXCross(canvas, size, random);
  }

  /// 배경 사각형 채우기.
  void _drawBackground(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, fillPaint);
  }

  /// 불규칙한 손그림 스타일의 테두리 사각형.
  void _drawBorder(Canvas canvas, Size size, Random random) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 손으로 그린 효과를 위해 2개 선 그리기
    for (int i = 0; i < 2; i++) {
      final path = _createIrregularRect(size, Random(seed + i * 100));
      canvas.drawPath(path, borderPaint);
    }
  }

  /// 불규칙한 사각형 경로 생성 (베지어 곡선 사용).
  Path _createIrregularRect(Size size, Random random) {
    final path = Path();

    // 4개 모서리 점 (거칠기 적용)
    final topLeft = _addRoughness(Offset(0, 0), random);
    final topRight = _addRoughness(Offset(size.width, 0), random);
    final bottomRight = _addRoughness(Offset(size.width, size.height), random);
    final bottomLeft = _addRoughness(Offset(0, size.height), random);

    // 시작점
    path.moveTo(topLeft.dx, topLeft.dy);

    // 위쪽 가장자리 (흔들림 적용)
    final topControl = _addBowing(topLeft, topRight, random);
    path.quadraticBezierTo(
      topControl.dx,
      topControl.dy,
      topRight.dx,
      topRight.dy,
    );

    // 오른쪽 가장자리
    final rightControl = _addBowing(topRight, bottomRight, random);
    path.quadraticBezierTo(
      rightControl.dx,
      rightControl.dy,
      bottomRight.dx,
      bottomRight.dy,
    );

    // 아래쪽 가장자리
    final bottomControl = _addBowing(bottomRight, bottomLeft, random);
    path.quadraticBezierTo(
      bottomControl.dx,
      bottomControl.dy,
      bottomLeft.dx,
      bottomLeft.dy,
    );

    // 왼쪽 가장자리
    final leftControl = _addBowing(bottomLeft, topLeft, random);
    path.quadraticBezierTo(
      leftControl.dx,
      leftControl.dy,
      topLeft.dx,
      topLeft.dy,
    );

    path.close();
    return path;
  }

  /// X-cross 라인 그리기 (2개 대각선).
  void _drawXCross(Canvas canvas, Size size, Random random) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 손으로 그린 효과를 위해 각 대각선을 2번씩 그림
    for (int i = 0; i < 2; i++) {
      // 왼쪽 위 → 오른쪽 아래
      final diagonal1 = _createIrregularLine(
        Offset(0, 0),
        Offset(size.width, size.height),
        Random(seed + 200 + i * 10),
      );
      canvas.drawPath(diagonal1, linePaint);

      // 오른쪽 위 → 왼쪽 아래
      final diagonal2 = _createIrregularLine(
        Offset(size.width, 0),
        Offset(0, size.height),
        Random(seed + 300 + i * 10),
      );
      canvas.drawPath(diagonal2, linePaint);
    }
  }

  /// 불규칙한 선 경로 생성 (베지어 곡선 사용).
  Path _createIrregularLine(Offset start, Offset end, Random random) {
    final path = Path();
    final segments = 8; // 선을 8개 세그먼트로 분할

    // 선의 수직 방향 각도 (루프 밖에서 한 번만 계산)
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final perpAngle = angle + pi / 2;

    // 모든 점을 미리 계산하여 이전 점 참조 시 일관성 보장
    final points = <Offset>[];
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;
      final offset = (random.nextDouble() - 0.5) * roughness * 4;
      points.add(Offset(
        x + cos(perpAngle) * offset,
        y + sin(perpAngle) * offset,
      ));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= segments; i++) {
      // 이전 점과 현재 점의 중간을 제어점으로 사용
      final controlX = (points[i - 1].dx + points[i].dx) / 2;
      final controlY = (points[i - 1].dy + points[i].dy) / 2;
      path.quadraticBezierTo(controlX, controlY, points[i].dx, points[i].dy);
    }

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

    // 약간의 휘어짐 추가
    final bowing = 0.5; // 고정된 휘어짐 계수
    final offset = (random.nextDouble() - 0.5) * bowing * 10;

    return Offset(mid.dx + offset, mid.dy + offset);
  }

  @override
  bool shouldRepaint(covariant XCrossPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed;
  }
}
