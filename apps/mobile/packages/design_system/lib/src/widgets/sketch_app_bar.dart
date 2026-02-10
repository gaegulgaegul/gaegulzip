import 'package:core/core.dart';
import 'package:flutter/material.dart';

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
  /// true이면 앱 바 하단에 손으로 그린 듯한 테두리를 추가함.
  /// 현재는 미구현 상태이며, 향후 SketchPainter를 사용하여 구현 예정.
  final bool showSketchBorder;

  /// 앱 바 높이.
  final double height;

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
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = SketchThemeExtension.maybeOf(context);
    final effectiveBgColor = backgroundColor ?? theme?.fillColor ?? SketchDesignTokens.white;
    final effectiveFgColor = foregroundColor ?? SketchDesignTokens.textPrimary;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    Widget appBarContent = Container(
      padding: EdgeInsets.only(top: statusBarHeight, left: 8, right: 8),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ]
            : null,
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

    return appBarContent;
  }
}
