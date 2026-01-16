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
    this.borderColor = const Color(0xFFDCDCDC), // base300
    this.fillColor = const Color(0xFFFFFFFF), // white
    this.shadowOffset = SketchDesignTokens.shadowOffsetMd,
    this.shadowBlur = SketchDesignTokens.shadowBlurMd,
    this.shadowColor = SketchDesignTokens.shadowColor,
  });

  /// 라이트 테마 변형을 생성함.
  factory SketchThemeExtension.light() {
    return const SketchThemeExtension(
      borderColor: Color(0xFFDCDCDC), // base300
      fillColor: Color(0xFFFFFFFF), // white
    );
  }

  /// 다크 테마 변형을 생성함.
  factory SketchThemeExtension.dark() {
    return const SketchThemeExtension(
      borderColor: Color(0xFF5E5E5E), // base700
      fillColor: Color(0xFF343434), // base900
      shadowColor: Color(0x40000000), // 다크 모드용 더 어두운 그림자
    );
  }

  /// 더 두드러진 스케치 변형을 생성함.
  factory SketchThemeExtension.rough() {
    return const SketchThemeExtension(
      strokeWidth: SketchDesignTokens.strokeBold,
      roughness: 1.2,
      bowing: 0.8,
    );
  }

  /// 부드럽고 미니멀한 스케치 변형을 생성함.
  factory SketchThemeExtension.smooth() {
    return const SketchThemeExtension(
      strokeWidth: SketchDesignTokens.strokeThin,
      roughness: 0.3,
      bowing: 0.2,
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
    );
  }

  @override
  ThemeExtension<SketchThemeExtension> copyWith({
    double? strokeWidth,
    double? roughness,
    double? bowing,
    Color? borderColor,
    Color? fillColor,
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
        other.shadowOffset == shadowOffset &&
        other.shadowBlur == shadowBlur &&
        other.shadowColor == shadowColor;
  }

  @override
  int get hashCode {
    return Object.hash(
      strokeWidth,
      roughness,
      bowing,
      borderColor,
      fillColor,
      shadowOffset,
      shadowBlur,
      shadowColor,
    );
  }

  @override
  String toString() {
    return 'SketchThemeExtension('
        'strokeWidth: $strokeWidth, '
        'roughness: $roughness, '
        'bowing: $bowing, '
        'borderColor: $borderColor, '
        'fillColor: $fillColor, '
        'shadowOffset: $shadowOffset, '
        'shadowBlur: $shadowBlur, '
        'shadowColor: $shadowColor'
        ')';
  }
}
