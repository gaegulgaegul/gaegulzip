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
///   borderColor: SketchDesignTokens.accentPrimary,
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

  /// 손으로 그린 흔들림을 위한 거칠기 계수 (0.0-1.0+).
  ///
  /// null이면 테마의 `SketchThemeExtension.roughness` 사용.
  final double? roughness;

  /// 곡선 왜곡을 위한 휘어짐 계수.
  ///
  /// null이면 테마의 `SketchThemeExtension.bowing` 사용.
  final double? bowing;

  /// 재현 가능한 스케치 모양을 위한 무작위 시드.
  final int seed;

  /// 노이즈 텍스처 채우기 활성화 여부.
  final bool enableNoise;

  /// 커스텀 너비 (null이면 콘텐츠에 맞춰 확장).
  final double? width;

  /// 커스텀 높이 (null이면 콘텐츠에 맞춰 확장).
  final double? height;

  /// 카드 주위의 여백 (스케치 테두리 외부).
  final EdgeInsetsGeometry? margin;

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
    this.roughness,
    this.bowing,
    this.seed = 0,
    this.enableNoise = true,
    this.width,
    this.height,
    this.margin,
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
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? const Color(0xFFDCDCDC);
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;
    final effectiveBowing = widget.bowing ?? sketchTheme?.bowing ?? SketchDesignTokens.bowing;
    final effectivePadding = widget.padding ?? const EdgeInsets.all(SketchDesignTokens.spacingMd);

    // elevation 기반 속성 계산
    final elevationSpec = _getElevationSpec(widget.elevation, _isHovered);

    // 호버 효과 적용
    final hoverRoughness = _isHovered ? effectiveRoughness + 0.1 : effectiveRoughness;
    final hoverSeed = _isHovered ? widget.seed + 1 : widget.seed;

    final cardContent = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: CustomPaint(
        painter: _SketchCardPainter(
          fillColor: effectiveFillColor,
          borderColor: effectiveBorderColor,
          strokeWidth: effectiveStrokeWidth,
          roughness: hoverRoughness,
          bowing: effectiveBowing,
          seed: hoverSeed,
          enableNoise: widget.enableNoise,
          shadowOffset: elevationSpec.shadowOffset,
          shadowBlur: elevationSpec.shadowBlur,
          shadowColor: elevationSpec.shadowColor,
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
          shadowColor: SketchDesignTokens.shadowColor.withOpacity(0.1),
        );
      case 2:
        return _ElevationSpec(
          shadowOffset: const Offset(0, 4),
          shadowBlur: 8.0,
          shadowColor: SketchDesignTokens.shadowColor.withOpacity(0.15),
        );
      case 3:
        return _ElevationSpec(
          shadowOffset: const Offset(0, 8),
          shadowBlur: 16.0,
          shadowColor: SketchDesignTokens.shadowColor.withOpacity(0.2),
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

/// 그림자 렌더링을 포함하는 SketchCard용 CustomPainter.
class _SketchCardPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;
  final double roughness;
  final double bowing;
  final int seed;
  final bool enableNoise;
  final Offset shadowOffset;
  final double shadowBlur;
  final Color shadowColor;

  const _SketchCardPainter({
    required this.fillColor,
    required this.borderColor,
    required this.strokeWidth,
    required this.roughness,
    required this.bowing,
    required this.seed,
    required this.enableNoise,
    required this.shadowOffset,
    required this.shadowBlur,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 필요한 경우 먼저 그림자를 그림
    if (shadowBlur > 0 && shadowColor != Colors.transparent) {
      _drawSketchyShadow(canvas, size);
    }

    // 주요 카드 렌더링을 위해 SketchPainter 사용
    final mainPainter = SketchPainter(
      fillColor: fillColor,
      borderColor: borderColor,
      strokeWidth: strokeWidth,
      roughness: roughness,
      bowing: bowing,
      seed: seed,
      enableNoise: enableNoise,
    );

    mainPainter.paint(canvas, size);
  }

  void _drawSketchyShadow(Canvas canvas, Size size) {
    final random = Random(seed + 9999); // 그림자용 다른 시드

    // 약간 불규칙한 그림자 경로 생성
    final shadowPath = _createIrregularPath(size, random);

    // 그림자 오프셋 적용
    final offsetPath = shadowPath.shift(shadowOffset);

    // 블러 효과로 그림자 그리기
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);

    canvas.drawPath(offsetPath, shadowPaint);
  }

  Path _createIrregularPath(Size size, Random random) {
    final path = Path();
    final radius = SketchDesignTokens.irregularBorderRadius;

    // 점에 거칠기를 추가하는 헬퍼
    Offset addRoughness(Offset point) {
      final offsetX = (random.nextDouble() - 0.5) * roughness * 2;
      final offsetY = (random.nextDouble() - 0.5) * roughness * 2;
      return point.translate(offsetX, offsetY);
    }

    // 약간의 불규칙성을 가진 둥근 사각형 생성
    final topLeft = addRoughness(Offset(radius, 0));
    final topRight = addRoughness(Offset(size.width - radius, 0));
    final bottomRight = addRoughness(Offset(size.width - radius, size.height));
    final bottomLeft = addRoughness(Offset(radius, size.height));

    path.moveTo(topLeft.dx, topLeft.dy);

    // 위쪽 가장자리
    final topControl = addRoughness(Offset(size.width / 2, 0));
    path.quadraticBezierTo(
      topControl.dx,
      topControl.dy,
      topRight.dx,
      topRight.dy,
    );

    // 오른쪽 가장자리
    final rightControl = addRoughness(Offset(size.width, size.height / 2));
    path.quadraticBezierTo(
      rightControl.dx,
      rightControl.dy,
      bottomRight.dx,
      bottomRight.dy,
    );

    // 아래쪽 가장자리
    final bottomControl = addRoughness(Offset(size.width / 2, size.height));
    path.quadraticBezierTo(
      bottomControl.dx,
      bottomControl.dy,
      bottomLeft.dx,
      bottomLeft.dy,
    );

    // 왼쪽 가장자리
    final leftControl = addRoughness(Offset(0, size.height / 2));
    path.quadraticBezierTo(
      leftControl.dx,
      leftControl.dy,
      topLeft.dx,
      topLeft.dy,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _SketchCardPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        bowing != oldDelegate.bowing ||
        seed != oldDelegate.seed ||
        enableNoise != oldDelegate.enableNoise ||
        shadowOffset != oldDelegate.shadowOffset ||
        shadowBlur != oldDelegate.shadowBlur ||
        shadowColor != oldDelegate.shadowColor;
  }
}
