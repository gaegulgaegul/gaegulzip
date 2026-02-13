import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Frame0 스타일의 X-cross 패턴을 그리는 CustomPainter.
///
/// 이미지 플레이스홀더에서 사용하는 손그림 스타일의 대각선 X 패턴을 렌더링함:
/// - 배경 사각형 (채우기)
/// - 테두리 사각형 (가변 두께 손그림 스타일)
/// - 왼쪽 위 → 오른쪽 아래 대각선
/// - 오른쪽 위 → 왼쪽 아래 대각선
/// - 모든 선은 tapered stroke (중앙 두껍고 끝 얇은 마커 질감)
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
///   ),
///   child: SizedBox(width: 200, height: 150),
/// )
/// ```
class XCrossPainter extends CustomPainter {
  /// 테두리 + X-cross 통합 색상.
  final Color lineColor;

  /// 배경 채우기 색상.
  final Color backgroundColor;

  /// 최대 선 두께 (tapered stroke의 가장 두꺼운 부분).
  final double strokeWidth;

  /// 거칠기 계수 (0.0-1.0+) - 흔들림 정도를 제어함.
  final double roughness;

  /// 재현 가능한 렌더링을 위한 무작위 시드.
  final int seed;

  /// 시작/끝 두께 비율 (기본: 0.3).
  ///
  /// 0.0이면 끝이 완전히 뾰족, 1.0이면 균일 두께.
  final double taperRatio;

  /// 테두리 표시 여부.
  final bool showBorder;

  const XCrossPainter({
    this.lineColor = SketchDesignTokens.base900,
    this.backgroundColor = SketchDesignTokens.base100,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = 0.8,
    this.seed = 0,
    this.taperRatio = 0.3,
    this.showBorder = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 배경 사각형 채우기
    _drawBackground(canvas, size);

    // 2. 테두리 (4개 변을 각각 tapered line으로)
    if (showBorder) {
      _drawBorder(canvas, size);
    }

    // 3. X-cross 대각선
    _drawXCross(canvas, size);
  }

  /// 배경 사각형 채우기.
  void _drawBackground(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fillPaint);
  }

  /// 4개 변을 각각 tapered line으로 그리는 테두리.
  void _drawBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final corners = [
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];

    // 2-pass로 손그림 효과 강화
    for (int pass = 0; pass < 2; pass++) {
      for (int edge = 0; edge < 4; edge++) {
        final path = _createTaperedLine(
          corners[edge],
          corners[(edge + 1) % 4],
          Random(seed + pass * 100 + edge * 10),
        );
        canvas.drawPath(path, paint);
      }
    }
  }

  /// X-cross 대각선 (2개 대각선, 각 2-pass).
  void _drawXCross(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int pass = 0; pass < 2; pass++) {
      // 왼쪽 위 → 오른쪽 아래
      final d1 = _createTaperedLine(
        Offset(0, 0),
        Offset(size.width, size.height),
        Random(seed + 200 + pass * 10),
      );
      canvas.drawPath(d1, paint);

      // 오른쪽 위 → 왼쪽 아래
      final d2 = _createTaperedLine(
        Offset(size.width, 0),
        Offset(0, size.height),
        Random(seed + 300 + pass * 10),
      );
      canvas.drawPath(d2, paint);
    }
  }

  /// 가변 두께(tapered) 선을 닫힌 Path로 생성.
  ///
  /// 선의 양쪽 윤곽(outline)을 계산하여 닫힌 형태로 만들고
  /// PaintingStyle.fill로 렌더링함. 이를 통해 중앙이 두껍고
  /// 끝이 얇은 마커/펜 질감을 표현함.
  Path _createTaperedLine(Offset start, Offset end, Random random) {
    const segments = 12;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = sqrt(dx * dx + dy * dy);
    if (length < 1) return Path();

    // 법선 방향 (선에 수직)
    final nx = -dy / length;
    final ny = dx / length;

    // 중심선 점 생성 (roughness jitter 적용)
    final centerPoints = <Offset>[];
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = start.dx + dx * t;
      final y = start.dy + dy * t;

      final jitter = (random.nextDouble() - 0.5) * roughness * 4;
      centerPoints.add(Offset(
        x + nx * jitter,
        y + ny * jitter,
      ));
    }

    // 상단/하단 윤곽 점 생성 (taper 프로파일 적용)
    final upperPoints = <Offset>[];
    final lowerPoints = <Offset>[];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      // sin(t * π): 0 → 1 → 0 (양 끝 얇고 중앙 두꺼움)
      final widthFactor = taperRatio + (1.0 - taperRatio) * sin(t * pi);
      final halfWidth = strokeWidth * widthFactor / 2;

      final center = centerPoints[i];
      upperPoints.add(Offset(
        center.dx + nx * halfWidth,
        center.dy + ny * halfWidth,
      ));
      lowerPoints.add(Offset(
        center.dx - nx * halfWidth,
        center.dy - ny * halfWidth,
      ));
    }

    // 닫힌 Path 구성: 상단 순방향 → 하단 역방향
    final path = Path();

    // 상단 윤곽 (순방향)
    path.moveTo(upperPoints[0].dx, upperPoints[0].dy);
    for (int i = 1; i < upperPoints.length - 1; i++) {
      final curr = upperPoints[i];
      final next = upperPoints[i + 1];
      path.quadraticBezierTo(
        curr.dx,
        curr.dy,
        (curr.dx + next.dx) / 2,
        (curr.dy + next.dy) / 2,
      );
    }
    path.lineTo(upperPoints.last.dx, upperPoints.last.dy);

    // 하단 윤곽 (역방향)
    path.lineTo(lowerPoints.last.dx, lowerPoints.last.dy);
    for (int i = lowerPoints.length - 2; i > 0; i--) {
      final curr = lowerPoints[i];
      final next = lowerPoints[i - 1];
      path.quadraticBezierTo(
        curr.dx,
        curr.dy,
        (curr.dx + next.dx) / 2,
        (curr.dy + next.dy) / 2,
      );
    }
    path.lineTo(lowerPoints.first.dx, lowerPoints.first.dy);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant XCrossPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        taperRatio != oldDelegate.taperRatio ||
        showBorder != oldDelegate.showBorder;
  }
}
