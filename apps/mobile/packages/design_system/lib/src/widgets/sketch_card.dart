import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일 모양의 카드 widget.
///
/// Frame0 스타일의 스케치 미학을 가진 카드 레이아웃을 생성함.
/// 커스터마이징 가능한 elevation과 함께 헤더, 본문, 푸터 섹션을 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchCard(
///   body: Text('Card content'),
/// )
/// ```
///
/// **헤더와 푸터:**
/// ```dart
/// SketchCard(
///   header: Text('Card Title'),
///   body: Column(
///     children: [
///       Text('Card content'),
///       Text('More content'),
///     ],
///   ),
///   footer: Row(
///     children: [
///       SketchButton(text: 'Cancel', onPressed: () {}),
///       SketchButton(text: 'OK', onPressed: () {}),
///     ],
///   ),
/// )
/// ```
///
/// **클릭 가능한 카드:**
/// ```dart
/// SketchCard(
///   body: Text('Tap me'),
///   onTap: () => print('Card tapped!'),
///   elevation: 2,
/// )
/// ```
///
/// **커스텀 스타일링:**
/// ```dart
/// SketchCard(
///   body: Text('Custom card'),
///   fillColor: SketchDesignTokens.accentLight,
///   borderColor: SketchDesignTokens.accentSecondary,
///   elevation: 3,
///   padding: EdgeInsets.all(SketchDesignTokens.spacingLg),
/// )
/// ```
///
/// **Elevation 레벨:**
/// - 0: 그림자 없음 (평면)
/// - 1: 미묘한 그림자 (오프셋 2px, 블러 4px)
/// - 2: 중간 그림자 (오프셋 4px, 블러 8px) - 기본값
/// - 3: 강한 그림자 (오프셋 8px, 블러 16px)
class SketchCard extends StatefulWidget {
  /// 헤더 widget (카드 상단에 표시됨).
  final Widget? header;

  /// 본문 widget (주요 콘텐츠, 필수).
  final Widget body;

  /// 푸터 widget (카드 하단에 표시됨).
  final Widget? footer;

  /// 카드가 탭되었을 때 콜백 (null = 클릭 불가).
  final VoidCallback? onTap;

  /// 그림자 강도를 제어하는 elevation 레벨 (0-3).
  ///
  /// - 0: 그림자 없음
  /// - 1: 미묘한 그림자
  /// - 2: 중간 그림자 (기본값)
  /// - 3: 강한 그림자
  final int elevation;

  /// 전체 카드의 내부 패딩.
  ///
  /// 기본값은 `EdgeInsets.all(SketchDesignTokens.spacingMd)` (12px).
  final EdgeInsetsGeometry? padding;

  /// 헤더와 본문 사이 패딩.
  final double headerSpacing;

  /// 본문과 푸터 사이 패딩.
  final double footerSpacing;

  /// 카드 배경의 채우기 색상.
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

  /// 커스텀 너비 (null이면 콘텐츠에 맞춰 확장).
  final double? width;

  /// 커스텀 높이 (null이면 콘텐츠에 맞춰 확장).
  final double? height;

  /// 카드 주위의 여백 (스케치 테두리 외부).
  final EdgeInsetsGeometry? margin;

  /// 테두리 표시 여부.
  final bool showBorder;

  const SketchCard({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.onTap,
    this.elevation = 2,
    this.padding,
    this.headerSpacing = 12.0,
    this.footerSpacing = 12.0,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.width,
    this.height,
    this.margin,
    this.showBorder = true,
  }) : assert(elevation >= 0 && elevation <= 3, 'Elevation must be between 0 and 3');

  @override
  State<SketchCard> createState() => _SketchCardState();
}

class _SketchCardState extends State<SketchCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // 테마 기본값 가져오기
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    final effectiveFillColor = widget.fillColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectivePadding = widget.padding ?? const EdgeInsets.all(SketchDesignTokens.spacingMd);

    // elevation 기반 속성 계산
    final elevationSpec = _getElevationSpec(widget.elevation, _isHovered);

    final cardContent = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: elevationSpec.shadowBlur > 0
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(
                  SketchDesignTokens.irregularBorderRadius),
              boxShadow: [
                BoxShadow(
                  offset: elevationSpec.shadowOffset,
                  blurRadius: elevationSpec.shadowBlur,
                  color: elevationSpec.shadowColor,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        painter: SketchPainter(
          fillColor: effectiveFillColor,
          borderColor: effectiveBorderColor,
          strokeWidth: effectiveStrokeWidth,
          roughness:
              sketchTheme?.roughness ?? SketchDesignTokens.roughness,
          seed: 0,
          enableNoise: true,
          showBorder: widget.showBorder,
          borderRadius: SketchDesignTokens.irregularBorderRadius,
        ),
        child: Padding(
          padding: effectivePadding,
          child: _buildCardLayout(),
        ),
      ),
    );

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }

  Widget _buildCardLayout() {
    final children = <Widget>[];

    if (widget.header != null) {
      children.add(widget.header!);
      children.add(SizedBox(height: widget.headerSpacing));
    }

    children.add(widget.body);

    if (widget.footer != null) {
      children.add(SizedBox(height: widget.footerSpacing));
      children.add(widget.footer!);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  _ElevationSpec _getElevationSpec(int elevation, bool isHovered) {
    // 호버 시 elevation을 약간 증가시킴
    final effectiveElevation = isHovered && widget.onTap != null ? elevation + 1 : elevation;
    final clampedElevation = effectiveElevation.clamp(0, 3);

    switch (clampedElevation) {
      case 0:
        return const _ElevationSpec(
          shadowOffset: Offset.zero,
          shadowBlur: 0.0,
          shadowColor: Colors.transparent,
        );
      case 1:
        return _ElevationSpec(
          shadowOffset: const Offset(0, 2),
          shadowBlur: 4.0,
          shadowColor: SketchDesignTokens.shadowColor.withValues(alpha: 0.1),
        );
      case 2:
        return _ElevationSpec(
          shadowOffset: const Offset(0, 4),
          shadowBlur: 8.0,
          shadowColor: SketchDesignTokens.shadowColor.withValues(alpha: 0.15),
        );
      case 3:
        return _ElevationSpec(
          shadowOffset: const Offset(0, 8),
          shadowBlur: 16.0,
          shadowColor: SketchDesignTokens.shadowColor.withValues(alpha: 0.2),
        );
      default:
        return const _ElevationSpec(
          shadowOffset: Offset.zero,
          shadowBlur: 0.0,
          shadowColor: Colors.transparent,
        );
    }
  }
}

/// 내부 elevation 사양.
class _ElevationSpec {
  final Offset shadowOffset;
  final double shadowBlur;
  final Color shadowColor;

  const _ElevationSpec({
    required this.shadowOffset,
    required this.shadowBlur,
    required this.shadowColor,
  });
}

