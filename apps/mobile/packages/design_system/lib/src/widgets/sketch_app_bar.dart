import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';
import 'sketch_icon_button.dart';

/// 화면 상단의 손그림 스타일 앱 바.
///
/// Frame0 스케치 스타일의 앱 바로, 제목, 뒤로가기 버튼, 액션 버튼을 포함함.
/// Flutter의 `Scaffold.appBar`에서 사용할 수 있도록 `PreferredSizeWidget`을 구현함.
///
/// **기본 사용법:**
/// ```dart
/// Scaffold(
///   appBar: SketchAppBar(
///     title: '홈',
///   ),
///   body: body,
/// )
/// ```
///
/// **액션 버튼 포함:**
/// ```dart
/// Scaffold(
///   appBar: SketchAppBar(
///     title: '설정',
///     actions: [
///       SketchIconButton(
///         icon: Icons.search,
///         onPressed: () => showSearch(),
///       ),
///       SketchIconButton(
///         icon: Icons.more_vert,
///         onPressed: () => showMenu(),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// **커스텀 leading:**
/// ```dart
/// Scaffold(
///   appBar: SketchAppBar(
///     leading: SketchIconButton(
///       icon: Icons.menu,
///       onPressed: () => openDrawer(),
///     ),
///     title: '메뉴',
///   ),
/// )
/// ```
///
/// **손그림 테두리 포함:**
/// ```dart
/// Scaffold(
///   appBar: SketchAppBar(
///     title: '스케치 스타일',
///     showSketchBorder: true,
///   ),
/// )
/// ```
///
/// **커스텀 타이틀 위젯:**
/// ```dart
/// Scaffold(
///   appBar: SketchAppBar(
///     titleWidget: Row(
///       children: [
///         Icon(Icons.star),
///         SizedBox(width: 8),
///         Text('즐겨찾기'),
///       ],
///     ),
///   ),
/// )
/// ```
class SketchAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 타이틀 텍스트.
  ///
  /// `titleWidget`이 지정되지 않은 경우 이 텍스트를 표시함.
  final String? title;

  /// 커스텀 타이틀 위젯.
  ///
  /// 지정되면 `title`보다 우선 사용됨.
  final Widget? titleWidget;

  /// 좌측 위젯 (뒤로가기 버튼 등).
  ///
  /// null이면 자동으로 뒤로가기 버튼을 표시함 (네비게이션 스택에 있는 경우).
  final Widget? leading;

  /// 우측 액션 버튼 목록.
  final List<Widget>? actions;

  /// 배경색.
  ///
  /// null이면 테마의 `fillColor` 사용.
  final Color? backgroundColor;

  /// 텍스트 색상.
  ///
  /// null이면 `SketchDesignTokens.textPrimary` 사용.
  final Color? foregroundColor;

  /// 그림자 표시 여부.
  final bool showShadow;

  /// 손그림 테두리 표시 여부.
  ///
  /// true이면 SketchPainter 기반의 2-pass 렌더링으로 손으로 그린 듯한 테두리를 추가함.
  /// false이면 기존 BoxDecoration 방식 사용 (하위 호환).
  final bool showSketchBorder;

  /// 앱 바 높이.
  final double height;

  /// 스케치 테두리의 두께 (null이면 테마 기본값 사용).
  final double? strokeWidth;

  /// 스케치 거칠기 (null이면 테마 기본값 사용).
  final double? roughness;

  /// 스케치 렌더링 시드 (재현 가능한 무작위성).
  final int seed;

  const SketchAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.showShadow = true,
    this.showSketchBorder = false,
    this.height = 56.0,
    this.strokeWidth,
    this.roughness,
    this.seed = 100,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = SketchThemeExtension.maybeOf(context);
    final effectiveBgColor = backgroundColor ?? theme?.fillColor ?? SketchDesignTokens.white;
    final effectiveFgColor = foregroundColor ?? theme?.textColor ?? SketchDesignTokens.textPrimary;
    final effectiveBorderColor = theme?.borderColor ?? SketchDesignTokens.base900;
    final effectiveStrokeWidth = strokeWidth ?? theme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = roughness ?? theme?.roughness ?? SketchDesignTokens.roughness;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // 앱바 컨텐츠 위젯 (leading + title + actions)
    final contentWidget = Container(
      padding: EdgeInsets.only(
        top: statusBarHeight,
        left: SketchDesignTokens.spacingSm,
        right: SketchDesignTokens.spacingSm,
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            // Leading
            if (leading != null)
              leading!
            else if (Navigator.canPop(context))
              SketchIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),

            // Title
            Expanded(
              child: titleWidget ??
                  Text(
                    title ?? '',
                    style: TextStyle(
                      fontFamily: SketchDesignTokens.fontFamilyHand,
                      fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                      fontSize: SketchDesignTokens.fontSizeLg,
                      fontWeight: FontWeight.w600,
                      color: effectiveFgColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
            ),

            // Actions
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );

    // showSketchBorder: false (기존 방식)
    if (!showSketchBorder) {
      return Container(
        decoration: BoxDecoration(
          color: effectiveBgColor,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: theme?.shadowColor ?? Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: contentWidget,
      );
    }

    // showSketchBorder: true (새 방식 - 2-pass SketchPainter)
    final containerStrokeWidth = effectiveStrokeWidth * 1.5;
    final containerRoughness = effectiveRoughness * 1.75;

    return Stack(
      children: [
        // 그림자 레이어 (showShadow: true일 때만)
        if (showShadow)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: theme?.shadowColor ?? Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

        // 스케치 테두리 레이어 (2-pass CustomPaint)
        CustomPaint(
          painter: SketchPainter(
            fillColor: effectiveBgColor,
            borderColor: effectiveBorderColor,
            strokeWidth: containerStrokeWidth,
            roughness: containerRoughness,
            seed: seed,
            enableNoise: true,
            showBorder: true,
            borderRadius: 0.0, // 앱바는 직각
          ),
          child: CustomPaint(
            painter: SketchPainter(
              fillColor: Colors.transparent,
              borderColor: effectiveBorderColor,
              strokeWidth: containerStrokeWidth,
              roughness: containerRoughness,
              seed: seed + 50,
              enableNoise: false,
              showBorder: true,
              borderRadius: 0.0, // 앱바는 직각
            ),
            child: contentWidget,
          ),
        ),
      ],
    );
  }
}
