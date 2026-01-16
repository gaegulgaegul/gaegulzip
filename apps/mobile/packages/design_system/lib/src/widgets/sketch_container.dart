import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일 모양의 컨테이너 widget.
///
/// 자식 widget을 Frame0 스타일의 스케치 테두리와 채우기를 렌더링하는
/// CustomPaint로 감쌈. 커스터마이징 가능한 스트로크 너비, 거칠기,
/// 색상, 크기를 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchContainer(
///   child: Text('Hello Sketch!'),
/// )
/// ```
///
/// **커스텀 스타일링:**
/// ```dart
/// SketchContainer(
///   width: 300,
///   height: 200,
///   fillColor: Colors.white,
///   borderColor: SketchDesignTokens.accentPrimary,
///   strokeWidth: SketchDesignTokens.strokeBold,
///   roughness: 1.0, // 더 스케치 같은 효과
///   padding: EdgeInsets.all(SketchDesignTokens.spacingLg),
///   child: Column(
///     children: [
///       Text('Sketch Card'),
///       Text('Hand-drawn style container'),
///     ],
///   ),
/// )
/// ```
///
/// **테마 통합:**
/// 속성이 지정되지 않은 경우, 현재 테마의 `SketchThemeExtension`에서
/// 기본값을 가져옴.
///
/// **GetX 호환성:**
/// 이 widget은 const constructor를 사용하며 Obx와 같은
/// GetX 반응형 widget과 완벽히 호환됨:
/// ```dart
/// Obx(() => SketchContainer(
///   borderColor: controller.isSelected.value
///       ? SketchDesignTokens.accentPrimary
///       : SketchDesignTokens.base300,
///   child: Text(controller.title.value),
/// ))
/// ```
class SketchContainer extends StatelessWidget {
  /// 스케치 컨테이너 내부에 표시할 widget.
  final Widget? child;

  /// 컨테이너 너비 (null이면 자식에 맞춤).
  final double? width;

  /// 컨테이너 높이 (null이면 자식에 맞춤).
  final double? height;

  /// 자식 주위의 내부 패딩.
  ///
  /// 기본값은 `EdgeInsets.all(SketchDesignTokens.spacingMd)` (12px).
  final EdgeInsetsGeometry? padding;

  /// 컨테이너 배경의 채우기 색상.
  ///
  /// null이면 테마의 `SketchThemeExtension.fillColor` 사용.
  final Color? fillColor;

  /// 테두리/스트로크 색상.
  ///
  /// null이면 테마의 `SketchThemeExtension.borderColor` 사용.
  final Color? borderColor;

  /// 테두리의 스트로크 너비.
  ///
  /// null이면 테마의 `SketchThemeExtension.strokeWidth` 사용.
  final double? strokeWidth;

  /// 손으로 그린 흔들림을 위한 거칠기 계수 (0.0-1.0+).
  ///
  /// - 0.0: 부드러움, 스케치 효과 없음
  /// - 0.8: 기본값, 미묘한 손으로 그린 효과
  /// - 1.0+: 매우 스케치 같은 효과
  ///
  /// null이면 테마의 `SketchThemeExtension.roughness` 사용.
  final double? roughness;

  /// 곡선 왜곡을 위한 휘어짐 계수.
  ///
  /// null이면 테마의 `SketchThemeExtension.bowing` 사용.
  final double? bowing;

  /// 재현 가능한 스케치 모양을 위한 무작위 시드.
  ///
  /// - 동일한 시드 = 매번 동일한 스케치
  /// - 다른 시드 = 다른 변형
  /// - 일관된 UI 또는 테스트에 유용함
  final int seed;

  /// 노이즈 텍스처 채우기 활성화 여부.
  ///
  /// 배경에 미묘한 종이 같은 질감을 추가함.
  final bool enableNoise;

  /// 컨테이너 주위의 여백 (스케치 테두리 외부).
  final EdgeInsetsGeometry? margin;

  /// 컨테이너 내 자식의 정렬.
  final AlignmentGeometry? alignment;

  /// 스케치 스타일 컨테이너를 생성함.
  ///
  /// 모든 스타일 속성은 선택 사항이며 지정하지 않으면 테마 값
  /// 또는 디자인 토큰 기본값을 사용함.
  const SketchContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.roughness,
    this.bowing,
    this.seed = 0,
    this.enableNoise = true,
    this.margin,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    // 테마 기본값 가져오기 (테마가 구성되지 않은 경우 폴백 사용)
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    final effectiveFillColor = fillColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? sketchTheme?.borderColor ?? const Color(0xFFDCDCDC);
    final effectiveStrokeWidth = strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;
    final effectiveBowing = bowing ?? sketchTheme?.bowing ?? SketchDesignTokens.bowing;
    final effectivePadding = padding ?? const EdgeInsets.all(SketchDesignTokens.spacingMd);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: CustomPaint(
        painter: SketchPainter(
          fillColor: effectiveFillColor,
          borderColor: effectiveBorderColor,
          strokeWidth: effectiveStrokeWidth,
          roughness: effectiveRoughness,
          bowing: effectiveBowing,
          seed: seed,
          enableNoise: enableNoise,
        ),
        child: Container(
          padding: effectivePadding,
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}
