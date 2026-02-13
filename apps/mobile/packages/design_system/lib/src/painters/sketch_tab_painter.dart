import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 스케치 스타일 탭 항목을 렌더링하는 CustomPainter.
///
/// 상단만 둥근 직사각형 (폴더 탭 형태) 경로를 손으로 그린 느낌으로 렌더링함.
/// 선택 탭과 비선택 탭의 차이는 배경색과 하단 테두리 생략 여부로 표현됨.
///
/// **사용법:**
/// ```dart
/// CustomPaint(
///   painter: SketchTabPainter(
///     fillColor: Colors.white,
///     borderColor: Colors.black,
///     strokeWidth: SketchDesignTokens.strokeBold,
///     roughness: 0.8,
///     seed: 42,
///     topRadius: 12.0,
///     isSelected: true,
///   ),
///   child: tabContent,
/// )
/// ```
class SketchTabPainter extends CustomPainter {
  /// 탭 배경 채우기 색상.
  final Color fillColor;

  /// 테두리 색상.
  final Color borderColor;

  /// 테두리 굵기 (기본값: strokeBold = 3.0).
  final double strokeWidth;

  /// 거칠기 계수 (0.0-1.0+) - 흔들림 정도를 제어함.
  ///
  /// - 0.0: 부드러움, 스케치 효과 없음
  /// - 0.8: 권장 기본값
  /// - 1.0+: 매우 스케치 같은 효과
  final double roughness;

  /// 재현 가능한 렌더링을 위한 무작위 시드.
  ///
  /// 동일한 시드 = 매번 동일한 스케치 모양.
  /// 다른 시드 = 다른 변형.
  final int seed;

  /// 노이즈 텍스처 채우기 그리기 여부.
  final bool enableNoise;

  /// 상단 모서리 반경 (기본값: 12.0).
  final double topRadius;

  /// 선택 상태 여부 (true면 하단 테두리 생략).
  final bool isSelected;

  const SketchTabPainter({
    required this.fillColor,
    required this.borderColor,
    this.strokeWidth = SketchDesignTokens.strokeBold,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
    this.enableNoise = true,
    this.topRadius = 12.0,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    // 채우기용 닫힌 경로 (선택/비선택 모두 전체 영역 채움)
    final fillPath = _createSketchTabPath(size, Random(seed), closePath: true);

    // 1. 채우기
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 2. 노이즈 텍스처 (채우기 경로 내부에만 렌더링)
    if (enableNoise && fillColor.a > 0.01) {
      canvas.save();
      canvas.clipPath(fillPath);
      _drawNoiseTexture(canvas, size, random);
      canvas.restore();
    }

    // 3. 테두리 (선택 탭은 하단 열림, 비선택 탭은 닫힘)
    final borderPath = _createSketchTabPath(
      size,
      Random(seed),
      closePath: !isSelected,
    );
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(borderPath, borderPaint);
  }

  /// 상단만 둥근 탭 형태의 스케치 경로를 생성함.
  ///
  /// 기본 경로를 따라 포인트를 균등 샘플링하고,
  /// 법선 방향으로 약간의 무작위 변위를 추가하여 스케치 느낌을 만듦.
  ///
  /// [closePath]가 false면 하단 변을 그리지 않는 열린 경로를 생성함.
  Path _createSketchTabPath(Size size, Random random, {bool closePath = true}) {
    if (roughness <= 0.01) {
      return _createBasicTabPath(size, closePath: closePath);
    }

    // 기본 탭 경로 생성 (열린 경로 — 좌하단→좌측→상단→우측→우하단)
    final idealPath = _createBasicTabPath(size, closePath: false);

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
    sketchPath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final curr = points[i];
      final next = points[i + 1];
      final midX = (curr.dx + next.dx) / 2;
      final midY = (curr.dy + next.dy) / 2;
      sketchPath.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
    }
    // 마지막 포인트까지 연결
    sketchPath.lineTo(points.last.dx, points.last.dy);

    if (closePath) {
      sketchPath.close();
    }

    return sketchPath;
  }

  /// 기본 탭 경로를 생성함 (상단만 둥근 직사각형).
  ///
  /// [closePath]가 true면 하단 변을 포함하여 닫힌 형태로 렌더링함.
  /// false면 좌하단→좌측→상단→우측→우하단 순서의 열린 경로를 생성함.
  Path _createBasicTabPath(Size size, {bool closePath = true}) {
    final path = Path();
    final r = min(topRadius, min(size.width, size.height) / 2);

    // 좌하단 → 좌측 → 좌상단 둥근 모서리 → 상단 → 우상단 둥근 모서리 → 우측 → 우하단
    path.moveTo(0, size.height);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width, size.height);

    if (closePath) {
      path.close(); // 하단 변 추가하여 닫힘
    }

    return path;
  }

  /// 종이 같은 질감을 위한 미묘한 노이즈 텍스처를 그림.
  void _drawNoiseTexture(Canvas canvas, Size size, Random random) {
    final noisePaint = Paint()
      ..color = Colors.black.withValues(alpha: SketchDesignTokens.noiseIntensity)
      ..style = PaintingStyle.fill;

    final noiseRandom = Random(seed + 1000); // 노이즈용 다른 시드
    final dotCount = (size.width * size.height / 100).toInt().clamp(50, 500);

    for (int i = 0; i < dotCount; i++) {
      final x = noiseRandom.nextDouble() * size.width;
      final y = noiseRandom.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        SketchDesignTokens.noiseGrainSize / 2,
        noisePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SketchTabPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        enableNoise != oldDelegate.enableNoise ||
        topRadius != oldDelegate.topRadius ||
        isSelected != oldDelegate.isSelected;
  }
}
