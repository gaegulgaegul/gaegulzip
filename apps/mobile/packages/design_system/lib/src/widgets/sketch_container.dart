import 'package:core/core.dart';
import 'package:flutter/material.dart';

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
///   borderColor: SketchDesignTokens.accentSecondary,
///   strokeWidth: SketchDesignTokens.strokeBold,
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
///       ? SketchDesignTokens.accentSecondary
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

  /// 컨테이너 주위의 여백 (스케치 테두리 외부).
  final EdgeInsetsGeometry? margin;

  /// 컨테이너 내 자식의 정렬.
  final AlignmentGeometry? alignment;

  /// 테두리 표시 여부.
  final bool showBorder;

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
    this.margin,
    this.alignment,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // 테마 기본값 가져오기 (테마가 구성되지 않은 경우 폴백 사용)
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    final effectiveFillColor = fillColor ?? sketchTheme?.fillColor ?? SketchDesignTokens.white;
    final effectiveBorderColor = borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
    final effectiveStrokeWidth = strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectivePadding = padding ?? const EdgeInsets.all(SketchDesignTokens.spacingMd);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveFillColor,
        border: showBorder
            ? Border.all(
                color: effectiveBorderColor,
                width: effectiveStrokeWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: effectivePadding,
      alignment: alignment,
      child: child,
    );
  }
}
