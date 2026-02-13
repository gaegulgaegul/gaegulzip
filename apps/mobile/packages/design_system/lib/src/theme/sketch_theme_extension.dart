import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 스케치 스타일 디자인 속성을 위한 ThemeExtension.
///
/// 스케치 디자인 토큰을 Flutter의 테마 시스템에 통합함.
/// `Theme.of(context).extension<SketchThemeExtension>()!`로 접근하거나
/// 편의 getter `SketchThemeExtension.of(context)` 사용.
///
/// **MaterialApp에서 설정:**
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       SketchThemeExtension(), // 기본값 사용
///       // 또는 커스터마이징:
///       SketchThemeExtension(
///         strokeWidth: SketchDesignTokens.strokeBold,
///         roughness: 1.2,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// **Widget에서 사용:**
/// ```dart
/// final sketchTheme = SketchThemeExtension.of(context);
/// Container(
///   decoration: BoxDecoration(
///     color: sketchTheme.fillColor,
///     border: Border.all(
///       color: sketchTheme.borderColor,
///       width: sketchTheme.strokeWidth,
///     ),
///   ),
/// )
/// ```
class SketchThemeExtension extends ThemeExtension<SketchThemeExtension> {
  /// 스케치 테두리의 스트로크 너비.
  final double strokeWidth;

  /// 손으로 그린 흔들림 효과를 위한 거칠기 계수 (0.0-1.0+).
  final double roughness;

  /// 곡선 왜곡을 위한 휘어짐 계수.
  final double bowing;

  /// 기본 테두리 색상.
  final Color borderColor;

  /// 기본 채우기 색상.
  final Color fillColor;

  /// 카드/모달 표면 색상.
  final Color surfaceColor;

  /// 링크/선택 상태 색상.
  final Color linkColor;

  /// 주요 텍스트 색상 (라벨, 입력값 등).
  final Color textColor;

  /// 보조 텍스트 색상 (힌트, 도움말 등).
  final Color textSecondaryColor;

  /// 아이콘 기본 색상.
  final Color iconColor;

  /// 포커스 테두리 색상.
  final Color focusBorderColor;

  /// 비활성화 배경 색상.
  final Color disabledFillColor;

  /// 비활성화 테두리 색상.
  final Color disabledBorderColor;

  /// 비활성화 텍스트 색상.
  final Color disabledTextColor;

  /// 그림자 오프셋.
  final Offset shadowOffset;

  /// 그림자 블러 반경.
  final double shadowBlur;

  /// 그림자 색상.
  final Color shadowColor;

  /// 커스텀 또는 기본값으로 스케치 테마 확장을 생성함.
  const SketchThemeExtension({
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.roughness = SketchDesignTokens.roughness,
    this.bowing = SketchDesignTokens.bowing,
    this.borderColor = const Color(0xFF343434), // base900 — Frame0 스케치 스타일: 어두운 테두리
    this.fillColor = const Color(0xFFFFFFFF), // white
    this.surfaceColor = const Color(0xFFF7F7F7), // surface — 카드/모달 표면색
    this.linkColor = const Color(0xFF2196F3), // linkBlue — 링크/선택 상태
    this.textColor = const Color(0xFF343434), // base900
    this.textSecondaryColor = const Color(0xFF8E8E8E), // base500
    this.iconColor = const Color(0xFF767676), // base600
    this.focusBorderColor = const Color(0xFF000000), // black
    this.disabledFillColor = const Color(0xFFF7F7F7), // base100
    this.disabledBorderColor = const Color(0xFFDCDCDC), // base300
    this.disabledTextColor = const Color(0xFF8E8E8E), // base500
    this.shadowOffset = SketchDesignTokens.shadowOffsetMd,
    this.shadowBlur = SketchDesignTokens.shadowBlurMd,
    this.shadowColor = SketchDesignTokens.shadowColor,
  });

  /// 라이트 테마 변형을 생성함.
  factory SketchThemeExtension.light() {
    return const SketchThemeExtension(
      borderColor: Color(0xFF343434), // base900 — Frame0 모노크롬
      fillColor: Color(0xFFFAF8F5), // background — 크림색 배경
      surfaceColor: Color(0xFFF7F7F7), // surface — 카드/모달 표면색
      linkColor: Color(0xFF2196F3), // linkBlue — 링크/선택 상태
      textColor: Color(0xFF343434), // base900
      textSecondaryColor: Color(0xFF8E8E8E), // base500
      iconColor: Color(0xFF767676), // base600
      focusBorderColor: Color(0xFF000000), // black
      disabledFillColor: Color(0xFFF7F7F7), // base100
      disabledBorderColor: Color(0xFFDCDCDC), // base300
      disabledTextColor: Color(0xFF8E8E8E), // base500
    );
  }

  /// 다크 테마 변형을 생성함.
  factory SketchThemeExtension.dark() {
    return const SketchThemeExtension(
      borderColor: Color(0xFF5E5E5E), // base700
      fillColor: Color(0xFF1A1D29), // backgroundDark — 네이비 배경
      surfaceColor: Color(0xFF2A2D3A), // surfaceDark — 어두운 표면색
      linkColor: Color(0xFF64B5F6), // linkBlueDark — 밝은 링크색 (다크 모드용)
      textColor: Color(0xFFF5F5F5), // textOnDark
      textSecondaryColor: Color(0xFFB0B0B0), // textSecondaryOnDark
      iconColor: Color(0xFFB5B5B5), // base400
      focusBorderColor: Color(0xFFFFFFFF), // white
      disabledFillColor: Color(0xFF2C3048), // surfaceVariantDark
      disabledBorderColor: Color(0xFF5E5E5E), // outlinePrimaryDark
      disabledTextColor: Color(0xFF6E6E6E), // textDisabledDark
      shadowColor: Color(0x40000000), // 다크 모드용 더 어두운 그림자
    );
  }

  /// 더 두드러진 스케치 변형을 생성함.
  factory SketchThemeExtension.rough() {
    return const SketchThemeExtension(
      strokeWidth: SketchDesignTokens.strokeBold,
      roughness: 1.2,
      bowing: 0.8,
      fillColor: Color(0xFFFAF8F5), // background — 크림색 배경
    );
  }

  /// 부드럽고 미니멀한 스케치 변형을 생성함.
  factory SketchThemeExtension.smooth() {
    return const SketchThemeExtension(
      strokeWidth: SketchDesignTokens.strokeThin,
      roughness: 0.3,
      bowing: 0.2,
      fillColor: Color(0xFFFAF8F5), // background — 크림색 배경
    );
  }

  /// 매우 부드러운 변형을 생성함 (스케치 효과 거의 없음).
  ///
  /// 거의 완벽하고 스케치 같지 않은 모양을 만듦.
  /// 격식있거나 정확한 UI 요소에 유용함.
  factory SketchThemeExtension.ultraSmooth() {
    return const SketchThemeExtension(
      strokeWidth: SketchDesignTokens.strokeThin,
      roughness: 0.0,
      bowing: 0.0,
      fillColor: Color(0xFFFAF8F5), // background — 크림색 배경
    );
  }

  /// 매우 거칠고 스케치가 많은 변형을 생성함.
  ///
  /// 매우 두드러진 손으로 그린 효과를 만듦.
  /// 예술적이거나 표현력 있는 UI 요소에 유용함.
  factory SketchThemeExtension.veryRough() {
    return const SketchThemeExtension(
      strokeWidth: SketchDesignTokens.strokeBold,
      roughness: 1.8,
      bowing: 1.2,
      fillColor: Color(0xFFFAF8F5), // background — 크림색 배경
    );
  }

  @override
  ThemeExtension<SketchThemeExtension> copyWith({
    double? strokeWidth,
    double? roughness,
    double? bowing,
    Color? borderColor,
    Color? fillColor,
    Color? surfaceColor,
    Color? linkColor,
    Color? textColor,
    Color? textSecondaryColor,
    Color? iconColor,
    Color? focusBorderColor,
    Color? disabledFillColor,
    Color? disabledBorderColor,
    Color? disabledTextColor,
    Offset? shadowOffset,
    double? shadowBlur,
    Color? shadowColor,
  }) {
    return SketchThemeExtension(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      roughness: roughness ?? this.roughness,
      bowing: bowing ?? this.bowing,
      borderColor: borderColor ?? this.borderColor,
      fillColor: fillColor ?? this.fillColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      linkColor: linkColor ?? this.linkColor,
      textColor: textColor ?? this.textColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      iconColor: iconColor ?? this.iconColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      disabledFillColor: disabledFillColor ?? this.disabledFillColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  ThemeExtension<SketchThemeExtension> lerp(
    covariant ThemeExtension<SketchThemeExtension>? other,
    double t,
  ) {
    if (other is! SketchThemeExtension) {
      return this;
    }

    return SketchThemeExtension(
      strokeWidth: lerpDouble(strokeWidth, other.strokeWidth, t)!,
      roughness: lerpDouble(roughness, other.roughness, t)!,
      bowing: lerpDouble(bowing, other.bowing, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      fillColor: Color.lerp(fillColor, other.fillColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      linkColor: Color.lerp(linkColor, other.linkColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      textSecondaryColor: Color.lerp(textSecondaryColor, other.textSecondaryColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      focusBorderColor: Color.lerp(focusBorderColor, other.focusBorderColor, t)!,
      disabledFillColor: Color.lerp(disabledFillColor, other.disabledFillColor, t)!,
      disabledBorderColor: Color.lerp(disabledBorderColor, other.disabledBorderColor, t)!,
      disabledTextColor: Color.lerp(disabledTextColor, other.disabledTextColor, t)!,
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
      shadowBlur: lerpDouble(shadowBlur, other.shadowBlur, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }

  /// context에서 SketchThemeExtension에 접근하기 위한 편의 getter.
  ///
  /// **사용법:**
  /// ```dart
  /// final sketchTheme = SketchThemeExtension.of(context);
  /// final strokeWidth = sketchTheme.strokeWidth;
  /// ```
  ///
  /// **주의:** SketchThemeExtension이 앱의 ThemeData에 등록되지 않은 경우
  /// 예외가 발생함. `theme.extensions`에 추가해야 함.
  static SketchThemeExtension of(BuildContext context) {
    final extension = Theme.of(context).extension<SketchThemeExtension>();

    if (extension == null) {
      throw FlutterError(
        'SketchThemeExtension not found in current theme.\n'
        'Make sure to add SketchThemeExtension() to ThemeData.extensions:\n\n'
        'MaterialApp(\n'
        '  theme: ThemeData(\n'
        '    extensions: [\n'
        '      SketchThemeExtension(),\n'
        '    ],\n'
        '  ),\n'
        ')',
      );
    }

    return extension;
  }

  /// context에서 SketchThemeExtension을 가져오되 없으면 null 반환.
  ///
  /// **사용법:**
  /// ```dart
  /// final sketchTheme = SketchThemeExtension.maybeOf(context);
  /// if (sketchTheme != null) {
  ///   // 스케치 테마 사용
  /// }
  /// ```
  static SketchThemeExtension? maybeOf(BuildContext context) {
    return Theme.of(context).extension<SketchThemeExtension>();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SketchThemeExtension &&
        other.strokeWidth == strokeWidth &&
        other.roughness == roughness &&
        other.bowing == bowing &&
        other.borderColor == borderColor &&
        other.fillColor == fillColor &&
        other.surfaceColor == surfaceColor &&
        other.linkColor == linkColor &&
        other.textColor == textColor &&
        other.textSecondaryColor == textSecondaryColor &&
        other.iconColor == iconColor &&
        other.focusBorderColor == focusBorderColor &&
        other.disabledFillColor == disabledFillColor &&
        other.disabledBorderColor == disabledBorderColor &&
        other.disabledTextColor == disabledTextColor &&
        other.shadowOffset == shadowOffset &&
        other.shadowBlur == shadowBlur &&
        other.shadowColor == shadowColor;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      strokeWidth,
      roughness,
      bowing,
      borderColor,
      fillColor,
      surfaceColor,
      linkColor,
      textColor,
      textSecondaryColor,
      iconColor,
      focusBorderColor,
      disabledFillColor,
      disabledBorderColor,
      disabledTextColor,
      shadowOffset,
      shadowBlur,
      shadowColor,
    ]);
  }

  @override
  String toString() {
    return 'SketchThemeExtension('
        'strokeWidth: $strokeWidth, '
        'roughness: $roughness, '
        'bowing: $bowing, '
        'borderColor: $borderColor, '
        'fillColor: $fillColor, '
        'surfaceColor: $surfaceColor, '
        'linkColor: $linkColor, '
        'textColor: $textColor, '
        'textSecondaryColor: $textSecondaryColor, '
        'iconColor: $iconColor, '
        'focusBorderColor: $focusBorderColor, '
        'disabledFillColor: $disabledFillColor, '
        'disabledBorderColor: $disabledBorderColor, '
        'disabledTextColor: $disabledTextColor, '
        'shadowOffset: $shadowOffset, '
        'shadowBlur: $shadowBlur, '
        'shadowColor: $shadowColor'
        ')';
  }
}
