import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_line_painter.dart';

/// 콘텐츠 영역을 구분하는 수평/수직 구분선.
///
/// Frame0 스타일의 손그림 스타일 또는 직선 스타일 선택 가능.
///
/// **기본 사용법 (수평 구분선):**
/// ```dart
/// SketchDivider()
/// ```
///
/// **두꺼운 구분선:**
/// ```dart
/// SketchDivider(
///   thickness: 2.0,
///   color: SketchDesignTokens.base500,
/// )
/// ```
///
/// **직선 스타일:**
/// ```dart
/// SketchDivider(
///   isSketch: false,
///   thickness: 1.0,
/// )
/// ```
///
/// **수직 구분선:**
/// ```dart
/// Row(
///   children: [
///     Text('왼쪽'),
///     SketchDivider.vertical(
///       thickness: 1.5,
///       margin: EdgeInsets.symmetric(horizontal: 16),
///     ),
///     Text('오른쪽'),
///   ],
/// )
/// ```
///
/// **섹션 구분:**
/// ```dart
/// Column(
///   children: [
///     _buildSection1(),
///     SketchDivider(
///       margin: EdgeInsets.symmetric(vertical: 24),
///       thickness: 2.0,
///     ),
///     _buildSection2(),
///   ],
/// )
/// ```
class SketchDivider extends StatelessWidget {
  /// 방향 (수평/수직).
  final Axis direction;

  /// 선 두께.
  final double thickness;

  /// 선 색상.
  final Color? color;

  /// 손그림 스타일 여부.
  final bool isSketch;

  /// 손그림 거칠기 (isSketch = true일 때).
  final double roughness;

  /// 여백 (선 주변).
  final EdgeInsetsGeometry? margin;

  /// 길이 (null = 최대).
  final double? length;

  const SketchDivider({
    super.key,
    this.direction = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.isSketch = true,
    this.roughness = 0.8,
    this.margin,
    this.length,
  });

  /// 수평 구분선 팩토리.
  const SketchDivider.horizontal({
    Key? key,
    double thickness = 1.0,
    Color? color,
    bool isSketch = true,
    EdgeInsetsGeometry? margin,
  }) : this(
          key: key,
          direction: Axis.horizontal,
          thickness: thickness,
          color: color,
          isSketch: isSketch,
          margin: margin,
        );

  /// 수직 구분선 팩토리.
  const SketchDivider.vertical({
    Key? key,
    double thickness = 1.0,
    Color? color,
    bool isSketch = true,
    EdgeInsetsGeometry? margin,
  }) : this(
          key: key,
          direction: Axis.vertical,
          thickness: thickness,
          color: color,
          isSketch: isSketch,
          margin: margin,
        );

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? SketchDesignTokens.base300;

    Widget divider;

    if (isSketch) {
      // 손그림 스타일
      divider = LayoutBuilder(
        builder: (context, constraints) {
          final Offset start;
          final Offset end;

          if (direction == Axis.horizontal) {
            final lineLength = length ?? constraints.maxWidth;
            start = Offset(0, thickness / 2);
            end = Offset(lineLength, thickness / 2);
          } else {
            final lineLength = length ?? constraints.maxHeight;
            start = Offset(thickness / 2, 0);
            end = Offset(thickness / 2, lineLength);
          }

          return CustomPaint(
            size: Size(
              direction == Axis.horizontal
                  ? (length ?? double.infinity)
                  : thickness,
              direction == Axis.vertical
                  ? (length ?? double.infinity)
                  : thickness,
            ),
            painter: SketchLinePainter(
              start: start,
              end: end,
              color: effectiveColor,
              strokeWidth: thickness,
              roughness: roughness,
            ),
          );
        },
      );
    } else {
      // 직선 스타일
      divider = Container(
        width: direction == Axis.horizontal ? length : thickness,
        height: direction == Axis.vertical ? length : thickness,
        color: effectiveColor,
      );
    }

    // margin 적용
    if (margin != null) {
      return Padding(
        padding: margin!,
        child: divider,
      );
    }

    return divider;
  }
}
