import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../enums/snackbar_type.dart';

/// Snackbar 타입별 스케치 스타일 아이콘을 렌더링하는 CustomPainter.
///
/// 4가지 의미론적 타입에 따라 다른 아이콘을 그림:
/// - **success**: 원 + 체크마크 (✓)
/// - **info**: 불규칙한 원 + "i" 텍스트
/// - **warning**: 삼각형 + "!" 텍스트
/// - **error**: 둥근 사각형 + "x" 텍스트
///
/// 기존 painter(SketchCirclePainter, SketchPolygonPainter, SketchPainter)의
/// 경로 생성 로직을 독립적으로 재현하여 결합도를 최소화함.
///
/// **사용법:**
/// ```dart
/// CustomPaint(
///   painter: SketchSnackbarIconPainter(
///     type: SnackbarType.success,
///     iconColor: Colors.black,
///   ),
///   size: const Size(32, 32),
/// )
/// ```
class SketchSnackbarIconPainter extends CustomPainter {
  /// 아이콘 타입
  final SnackbarType type;

  /// 아이콘 색상 (테두리, 내부 기호 동일)
  final Color iconColor;

  /// 아이콘 크기 (정사각형 기준)
  final double size;

  /// 선 두께
  final double strokeWidth;

  /// 거칠기 계수
  final double roughness;

  /// 랜덤 시드
  final int seed;

  const SketchSnackbarIconPainter({
    required this.type,
    required this.iconColor,
    this.size = 32.0,
    this.strokeWidth = 2.0,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    switch (type) {
      case SnackbarType.success:
        _paintSuccess(canvas, canvasSize);
        break;
      case SnackbarType.info:
        _paintInfo(canvas, canvasSize);
        break;
      case SnackbarType.warning:
        _paintWarning(canvas, canvasSize);
        break;
      case SnackbarType.error:
        _paintError(canvas, canvasSize);
        break;
    }
  }

  /// Success 아이콘: 원 + 체크마크
  void _paintSuccess(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2 - strokeWidth;
    final random = Random(seed);

    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 스케치 원형 테두리
    final circlePath = _createSketchCircle(center, radius, radius, random);
    canvas.drawPath(circlePath, paint);

    // 체크마크 (✓) — 손그림 스타일 bezier 곡선
    final checkPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(
        center.dx - radius * 0.35,
        center.dy + radius * 0.05,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.1,
        center.dy + radius * 0.35,
        center.dx - radius * 0.0,
        center.dy + radius * 0.3,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.15,
        center.dy - radius * 0.1,
        center.dx + radius * 0.4,
        center.dy - radius * 0.35,
      );

    canvas.drawPath(checkPath, checkPaint);
  }

  /// Info 아이콘: 불규칙한 원 + "i" 텍스트
  void _paintInfo(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2 - strokeWidth;
    final random = Random(seed);

    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 불규칙한 원형 (roughness 높임)
    final circlePath = _createSketchCircle(
      center,
      radius,
      radius,
      random,
      roughnessOverride: roughness * 1.5,
    );
    canvas.drawPath(circlePath, paint);

    // "i" 텍스트
    _drawCenterText(canvas, center, 'i', 18.0);
  }

  /// Warning 아이콘: 삼각형 + "!" 텍스트
  void _paintWarning(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2 - strokeWidth;
    final random = Random(seed);

    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 삼각형 (꼭짓점 위쪽, rotation = -pi/2)
    final trianglePath = _createSketchPolygon(
      center,
      radius,
      3,
      -pi / 2,
      random,
    );
    canvas.drawPath(trianglePath, paint);

    // "!" 텍스트 (삼각형 무게중심 기준 약간 아래)
    final textCenter = Offset(center.dx, center.dy + radius * 0.12);
    _drawCenterText(canvas, textCenter, '!', 16.0);
  }

  /// Error 아이콘: 둥근 사각형 + "x" 텍스트
  void _paintError(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final rectSize = size * 0.75;
    final random = Random(seed);

    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 둥근 사각형
    final rect = Rect.fromCenter(
      center: center,
      width: rectSize,
      height: rectSize,
    );
    final rectPath = _createSketchRoundedRect(rect, 4.0, random);
    canvas.drawPath(rectPath, paint);

    // "x" 텍스트
    _drawCenterText(canvas, center, 'x', 16.0);
  }

  // ─── Private 유틸리티 메서드 ───

  /// 중앙 정렬 텍스트 렌더링 (Hand 폰트)
  void _drawCenterText(
    Canvas canvas,
    Offset center,
    String text,
    double fontSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyHand,
          fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: iconColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  /// 불규칙한 원형 경로 생성 (SketchCirclePainter 로직 재현)
  Path _createSketchCircle(
    Offset center,
    double radiusX,
    double radiusY,
    Random random, {
    double? roughnessOverride,
    int segments = 16,
  }) {
    final path = Path();
    final r = roughnessOverride ?? roughness;

    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final offsetRadius = r * 2;
      final irregularRx = radiusX + (random.nextDouble() - 0.5) * offsetRadius;
      final irregularRy = radiusY + (random.nextDouble() - 0.5) * offsetRadius;
      final x = center.dx + cos(angle) * irregularRx;
      final y = center.dy + sin(angle) * irregularRy;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // 제어점으로 부드러운 곡선
        final prevAngle = ((i - 1) / segments) * 2 * pi;
        final controlAngle = (prevAngle + angle) / 2;
        final controlRadius = r * (random.nextDouble() - 0.5);
        final cx = center.dx + cos(controlAngle) * (radiusX + controlRadius);
        final cy = center.dy + sin(controlAngle) * (radiusY + controlRadius);
        path.quadraticBezierTo(cx, cy, x, y);
      }
    }

    path.close();
    return path;
  }

  /// 불규칙한 다각형 경로 생성 (SketchPolygonPainter 로직 재현)
  Path _createSketchPolygon(
    Offset center,
    double radius,
    int sides,
    double rotation,
    Random random,
  ) {
    final path = Path();
    final anglePerSide = 2 * pi / sides;

    for (int i = 0; i <= sides; i++) {
      final angle = i * anglePerSide + rotation;
      final offsetRadius =
          radius + (random.nextDouble() - 0.5) * roughness * 4;
      final x = center.dx + cos(angle) * offsetRadius;
      final y = center.dy + sin(angle) * offsetRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevAngle = (i - 1) * anglePerSide + rotation;
        final prevOffsetR =
            radius + (random.nextDouble() - 0.5) * roughness * 4;
        final prevX = center.dx + cos(prevAngle) * prevOffsetR;
        final prevY = center.dy + sin(prevAngle) * prevOffsetR;

        final cx =
            (prevX + x) / 2 + (random.nextDouble() - 0.5) * roughness * 2;
        final cy =
            (prevY + y) / 2 + (random.nextDouble() - 0.5) * roughness * 2;

        path.quadraticBezierTo(cx, cy, x, y);
      }
    }

    path.close();
    return path;
  }

  /// 둥근 사각형 스케치 경로 생성 (SketchPainter 로직 재현)
  Path _createSketchRoundedRect(
    Rect rect,
    double borderRadius,
    Random random,
  ) {
    if (roughness <= 0.01) {
      return Path()
        ..addRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));
    }

    final r = min(borderRadius, min(rect.width, rect.height) / 2);
    final idealPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));

    final metrics = idealPath.computeMetrics().toList();
    if (metrics.isEmpty) return idealPath;

    final metric = metrics.first;
    final totalLength = metric.length;
    final numPoints = (totalLength / 4).round().clamp(12, 100);
    final maxJitter = roughness * 0.6;

    final points = <Offset>[];
    for (int i = 0; i < numPoints; i++) {
      final distance = totalLength * i / numPoints;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
        points.add(tangent.position + normal * jitter);
      }
    }

    if (points.length < 3) return idealPath;

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
  bool shouldRepaint(covariant SketchSnackbarIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.iconColor != iconColor ||
        oldDelegate.size != size ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.roughness != roughness ||
        oldDelegate.seed != seed;
  }
}
