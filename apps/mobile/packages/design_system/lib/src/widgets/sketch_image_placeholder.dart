import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../painters/x_cross_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// Frame0 시그니처 X-cross 패턴 이미지 플레이스홀더
///
/// 이미지가 아직 로드되지 않았거나 없는 경우 표시하는 위젯.
/// X-cross 패턴으로 "이미지 영역"을 시각적으로 표현함.
/// 가변 두께(tapered stroke)로 마커/펜 질감을 재현함.
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

  /// 스트로크 색상 (테두리 + 대각선 통합, 기본: 테마 textColor)
  final Color? lineColor;

  /// 선 두께 (기본: 2.0)
  final double strokeWidth;

  /// 배경 색상 (기본: 테마 fillColor)
  final Color? backgroundColor;

  /// 거칠기 계수 (기본: 0.8) - 손그림 흔들림 정도
  final double roughness;

  /// 테두리 표시 여부 (기본: true)
  final bool showBorder;

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
    this.centerIcon,
  });

  /// XS 프리셋 — 40x40 썸네일
  const SketchImagePlaceholder.xs({
    super.key,
    this.lineColor,
    this.backgroundColor,
    this.roughness = 0.8,
    this.showBorder = true,
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
    this.centerIcon,
  })  : width = 200,
        height = 200,
        strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    // 테두리와 대각선을 동일 색상으로 통합 (레퍼런스 디자인 기준)
    // textColor: Light=0xFF343434(검정), Dark=0xFFF5F5F5(흰색)
    final effectiveStrokeColor =
        lineColor ?? sketchTheme?.textColor ?? SketchDesignTokens.base900;
    final effectiveBgColor =
        backgroundColor ?? sketchTheme?.fillColor ?? SketchDesignTokens.base100;

    // 접근성: 스크린 리더에 "이미지 플레이스홀더"로 읽힘
    return Semantics(
      label: '이미지 플레이스홀더',
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // X-cross 패턴 렌더링 (배경 + 테두리 + 대각선 모두 포함)
            Positioned.fill(
              child: CustomPaint(
                painter: XCrossPainter(
                  lineColor: effectiveStrokeColor,
                  backgroundColor: effectiveBgColor,
                  strokeWidth: strokeWidth,
                  roughness: roughness,
                  showBorder: showBorder,
                ),
              ),
            ),

            // 중앙 아이콘 (선택적)
            if (centerIcon != null)
              Center(
                child: Icon(
                  centerIcon,
                  size: _calculateIconSize(),
                  color: effectiveStrokeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 아이콘 크기 계산 — 컨테이너 크기의 30%
  double _calculateIconSize() {
    final size = width != null && height != null
        ? (width! < height! ? width! : height!)
        : (width ?? height ?? 100);

    return size * 0.3;
  }
}
