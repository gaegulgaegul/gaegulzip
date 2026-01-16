import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 스케치 선의 화살표 스타일.
enum SketchArrowStyle {
  /// 화살표 없음
  none,

  /// 끝점에 화살표
  end,

  /// 시작점에 화살표
  start,

  /// 양쪽 끝에 화살표
  both,
}

/// 스케치 스타일 선과 화살표를 렌더링하는 CustomPainter.
///
/// 불규칙하고 흔들리는 경로를 가진 손으로 그린 듯한 선을 생성함.
/// 시작/끝점에 화살표 지원.
///
/// **기본 사용법 (수평선):**
/// ```dart
/// CustomPaint(
///   painter: SketchLinePainter(
///     start: Offset(0, 50),
///     end: Offset(200, 50),
///     color: Colors.black,
///   ),
///   child: SizedBox(width: 200, height: 100),
/// )
/// ```
///
/// **대각선:**
/// ```dart
/// CustomPaint(
///   painter: SketchLinePainter(
///     start: Offset(0, 0),
///     end: Offset(100, 100),
///     color: SketchDesignTokens.accentPrimary,
///     strokeWidth: SketchDesignTokens.strokeBold,
///   ),
///   child: SizedBox(width: 100, height: 100),
/// )
/// ```
///
/// **화살표가 있는 선:**
/// ```dart
/// CustomPaint(
///   painter: SketchLinePainter(
///     start: Offset(20, 50),
///     end: Offset(180, 50),
///     color: Colors.blue,
///     arrowStyle: SketchArrowStyle.end,
///   ),
///   child: SizedBox(width: 200, height: 100),
/// )
/// ```
///
/// **양방향 화살표:**
/// ```dart
/// CustomPaint(
///   painter: SketchLinePainter(
///     start: Offset(20, 50),
///     end: Offset(180, 50),
///     color: SketchDesignTokens.base900,
///     arrowStyle: SketchArrowStyle.both,
///     arrowSize: 15.0,
///   ),
///   child: SizedBox(width: 200, height: 100),
/// )
/// ```
///
/// **점선:**
/// ```dart
/// CustomPaint(
///   painter: SketchLinePainter(
///     start: Offset(0, 50),
///     end: Offset(200, 50),
///     color: SketchDesignTokens.base500,
///     dashPattern: [5.0, 3.0], // 5px 선, 3px 간격
///   ),
///   child: SizedBox(width: 200, height: 100),
/// )
/// ```
class SketchLinePainter extends CustomPainter {
  /// 선의 시작점.
  final Offset start;

  /// 선의 끝점.
  final Offset end;

  /// 선 색상.
  final Color color;

  /// 선 두께.
  final double strokeWidth;

  /// 흔들림 효과의 거칠기 계수 (0.0-1.0+).
  ///
  /// - 0.0: 직선
  /// - 0.8: 기본값, 은은한 손으로 그린 효과
  /// - 1.5+: 매우 흔들리는 선
  final double roughness;

  /// 재현 가능한 외형을 위한 랜덤 시드.
  final int seed;

  /// 화살표 스타일 (none, start, end, both).
  final SketchArrowStyle arrowStyle;

  /// 화살표 머리 크기.
  final double arrowSize;

  /// 점선 패턴 (null = 실선).
  ///
  /// 예: [5.0, 3.0] = 5px 선, 3px 간격
  final List<double>? dashPattern;

  /// 선을 근사하는 세그먼트 수.
  ///
  /// 세그먼트가 많을수록 = 더 불규칙한 흔들림
  final int segments;

  const SketchLinePainter({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
    this.arrowStyle = SketchArrowStyle.none,
    this.arrowSize = 10.0,
    this.dashPattern,
    this.segments = 10,
  }) : assert(segments >= 2, 'Segments must be at least 2');

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    // 주 선 그리기 (손으로 그린 효과를 위한 2개 선)
    for (int i = 0; i < 2; i++) {
      final path = _createIrregularLine(Random(seed + i * 100));

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (dashPattern != null && dashPattern!.isNotEmpty) {
        // 점선 수동으로 생성
        _drawDashedPath(canvas, path, paint, dashPattern!);
      } else {
        canvas.drawPath(path, paint);
      }
    }

    // 화살표 그리기
    if (arrowStyle != SketchArrowStyle.none) {
      _drawArrows(canvas, random);
    }
  }

  /// 이차 베지어 곡선을 사용하여 불규칙한 선 경로 생성.
  Path _createIrregularLine(Random random) {
    final path = Path();

    // 선을 따라 중간 점들 생성
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;

      // 흔들림을 위한 수직 offset 추가
      final angle = atan2(end.dy - start.dy, end.dx - start.dx);
      final perpAngle = angle + pi / 2;
      final offset = (random.nextDouble() - 0.5) * roughness * 4;

      final wobbleX = x + cos(perpAngle) * offset;
      final wobbleY = y + sin(perpAngle) * offset;

      if (i == 0) {
        path.moveTo(wobbleX, wobbleY);
      } else {
        // 부드러운 곡선을 만들기 위해 이전 점 사용
        final prevT = (i - 1) / segments;
        final prevX = start.dx + (end.dx - start.dx) * prevT;
        final prevY = start.dy + (end.dy - start.dy) * prevT;
        final prevOffset = (random.nextDouble() - 0.5) * roughness * 4;
        final prevWobbleX = prevX + cos(perpAngle) * prevOffset;
        final prevWobbleY = prevY + sin(perpAngle) * prevOffset;

        // 이전과 현재 사이의 중간 제어점
        final controlX = (prevWobbleX + wobbleX) / 2;
        final controlY = (prevWobbleY + wobbleY) / 2;

        path.quadraticBezierTo(controlX, controlY, wobbleX, wobbleY);
      }
    }

    return path;
  }

  /// 점선 경로를 수동으로 그림.
  void _drawDashedPath(Canvas canvas, Path path, Paint paint, List<double> pattern) {
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      int patternIndex = 0;

      while (distance < metric.length) {
        final segmentLength = pattern[patternIndex % pattern.length];
        final nextDistance = min(distance + segmentLength, metric.length);

        if (draw) {
          final extractPath = metric.extractPath(distance, nextDistance);
          canvas.drawPath(extractPath, paint);
        }

        distance = nextDistance;
        draw = !draw;
        patternIndex++;
      }
    }
  }

  /// 화살표 머리 그리기.
  void _drawArrows(Canvas canvas, Random random) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 끝점에 화살표 그리기
    if (arrowStyle == SketchArrowStyle.end || arrowStyle == SketchArrowStyle.both) {
      final endArrowPath = _createArrowHead(end, start, random);
      canvas.drawPath(endArrowPath, arrowPaint);
    }

    // 시작점에 화살표 그리기
    if (arrowStyle == SketchArrowStyle.start || arrowStyle == SketchArrowStyle.both) {
      final startArrowPath = _createArrowHead(start, end, Random(seed + 999));
      canvas.drawPath(startArrowPath, arrowPaint);
    }
  }

  /// 화살표 머리 경로 생성.
  ///
  /// [tip]은 화살표의 끝점
  /// [from]은 화살표가 온 방향
  Path _createArrowHead(Offset tip, Offset from, Random random) {
    final path = Path();

    // 각도 계산
    final angle = atan2(tip.dy - from.dy, tip.dx - from.dx);

    // 주 선에서 30도 각도의 화살표 날개
    final wingAngle1 = angle + pi - pi / 6; // 150도
    final wingAngle2 = angle + pi + pi / 6; // 210도

    // 화살표에 약간의 불규칙성 추가
    final wobble1 = (random.nextDouble() - 0.5) * roughness * 2;
    final wobble2 = (random.nextDouble() - 0.5) * roughness * 2;

    final wing1 = Offset(
      tip.dx + cos(wingAngle1) * (arrowSize + wobble1),
      tip.dy + sin(wingAngle1) * (arrowSize + wobble1),
    );

    final wing2 = Offset(
      tip.dx + cos(wingAngle2) * (arrowSize + wobble2),
      tip.dy + sin(wingAngle2) * (arrowSize + wobble2),
    );

    // V자 형태로 화살표 그리기
    path.moveTo(wing1.dx, wing1.dy);
    path.lineTo(tip.dx, tip.dy);
    path.lineTo(wing2.dx, wing2.dy);

    return path;
  }

  @override
  bool shouldRepaint(covariant SketchLinePainter oldDelegate) {
    return start != oldDelegate.start ||
        end != oldDelegate.end ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        arrowStyle != oldDelegate.arrowStyle ||
        arrowSize != oldDelegate.arrowSize ||
        dashPattern != oldDelegate.dashPattern ||
        segments != oldDelegate.segments;
  }
}
