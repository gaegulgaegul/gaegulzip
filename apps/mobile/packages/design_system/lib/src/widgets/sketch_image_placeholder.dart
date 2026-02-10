import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../painters/x_cross_painter.dart';

/// Frame0 시그니처 X-cross 패턴 이미지 플레이스홀더
///
/// 이미지가 아직 로드되지 않았거나 없는 경우 표시하는 위젯.
/// X-cross 패턴으로 "이미지 영역"을 시각적으로 표현함.
///
/// **기본 사용법:**
/// ```dart
/// SketchImagePlaceholder(width: 200, height: 150)
/// ```
///
/// **프리셋:**
/// ```dart
/// SketchImagePlaceholder.xs()  // 40x40 썸네일
/// SketchImagePlaceholder.sm()  // 80x80 프로필
/// SketchImagePlaceholder.md()  // 120x120 카드
/// SketchImagePlaceholder.lg()  // 200x200 배너
/// ```
class SketchImagePlaceholder extends StatelessWidget {
  /// 플레이스홀더 너비
  final double? width;

  /// 플레이스홀더 높이
  final double? height;

  /// X-cross 라인 색상 (기본: base500)
  final Color? lineColor;

  /// 선 두께 (기본: 2.0)
  final double strokeWidth;

  /// 배경 색상 (기본: base100)
  final Color? backgroundColor;

  /// 거칠기 계수 (기본: 0.8) - 손그림 흔들림 정도
  final double roughness;

  /// 테두리 표시 여부 (기본: true)
  final bool showBorder;

  /// 테두리 색상 (기본: base300)
  final Color? borderColor;

  /// 중앙에 표시할 아이콘 (선택적)
  final IconData? centerIcon;

  const SketchImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.lineColor,
    this.strokeWidth = 2.0,
    this.backgroundColor,
    this.roughness = 0.8,
    this.showBorder = true,
    this.borderColor,
    this.centerIcon,
  });

  /// XS 프리셋 — 40x40 썸네일
  const SketchImagePlaceholder.xs({
    super.key,
    this.lineColor,
    this.backgroundColor,
    this.roughness = 0.8,
    this.showBorder = true,
    this.borderColor,
    this.centerIcon,
  })  : width = 40,
        height = 40,
        strokeWidth = 1.5;

  /// SM 프리셋 — 80x80 프로필 (기본 아이콘: person_outline)
  const SketchImagePlaceholder.sm({
    super.key,
    this.lineColor,
    this.backgroundColor,
    this.roughness = 0.8,
    this.showBorder = true,
    this.borderColor,
    this.centerIcon = Icons.person_outline,
  })  : width = 80,
        height = 80,
        strokeWidth = 2.0;

  /// MD 프리셋 — 120x120 카드
  const SketchImagePlaceholder.md({
    super.key,
    this.lineColor,
    this.backgroundColor,
    this.roughness = 0.8,
    this.showBorder = true,
    this.borderColor,
    this.centerIcon,
  })  : width = 120,
        height = 120,
        strokeWidth = 2.5;

  /// LG 프리셋 — 200x200 배너
  const SketchImagePlaceholder.lg({
    super.key,
    this.lineColor,
    this.backgroundColor,
    this.roughness = 0.8,
    this.showBorder = true,
    this.borderColor,
    this.centerIcon,
  })  : width = 200,
        height = 200,
        strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    // 색상 기본값 적용
    final effectiveLineColor = lineColor ?? SketchDesignTokens.base500;
    final effectiveBgColor = backgroundColor ?? SketchDesignTokens.base100;
    final effectiveBorderColor = borderColor ?? SketchDesignTokens.base300;

    // 접근성: 스크린 리더에 "이미지 플레이스홀더"로 읽힘
    return Semantics(
      label: '이미지 플레이스홀더',
      child: Container(
        width: width,
        height: height,
        decoration: showBorder
            ? BoxDecoration(
                border: Border.all(
                  color: effectiveBorderColor,
                  width: strokeWidth,
                ),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Stack(
          children: [
            // X-cross 패턴 렌더링
            Positioned.fill(
              child: CustomPaint(
                painter: XCrossPainter(
                  lineColor: effectiveLineColor,
                  backgroundColor: effectiveBgColor,
                  borderColor: effectiveBorderColor,
                  strokeWidth: strokeWidth,
                  roughness: roughness,
                ),
              ),
            ),

            // 중앙 아이콘 (선택적)
            if (centerIcon != null)
              Center(
                child: Icon(
                  centerIcon,
                  size: _calculateIconSize(),
                  color: effectiveLineColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 아이콘 크기 계산 — 컨테이너 크기의 30%
  double _calculateIconSize() {
    // width와 height 중 작은 값의 30%
    final size = width != null && height != null
        ? (width! < height! ? width! : height!)
        : (width ?? height ?? 100);

    return size * 0.3;
  }
}
