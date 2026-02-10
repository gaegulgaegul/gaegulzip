import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 아이콘 위치.
enum SketchLinkIconPosition {
  /// 텍스트 앞.
  leading,

  /// 텍스트 뒤.
  trailing,
}

/// 클릭 가능한 텍스트 링크 widget.
///
/// Frame0 스타일의 파란색 텍스트 링크.
/// 밑줄 효과와 호버 상태를 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchLink(
///   text: '자세히 보기',
///   onTap: () => navigateToDetail(),
/// )
/// ```
///
/// **외부 URL:**
/// ```dart
/// SketchLink(
///   text: 'Frame0 홈페이지',
///   icon: Icons.open_in_new,
///   onTap: () => launchUrl('https://frame0.app'),
/// )
/// ```
///
/// **방문한 링크:**
/// ```dart
/// SketchLink(
///   text: '이미 본 문서',
///   isVisited: true,
///   onTap: () => navigateToDoc(),
/// )
/// ```
///
/// **인라인 링크:**
/// ```dart
/// Text.rich(
///   TextSpan(
///     text: '더 많은 정보는 ',
///     children: [
///       WidgetSpan(
///         child: SketchLink(
///           text: '여기',
///           onTap: () {},
///         ),
///       ),
///       TextSpan(text: '를 참고하세요.'),
///     ],
///   ),
/// )
/// ```
class SketchLink extends StatefulWidget {
  /// 링크 텍스트.
  final String text;

  /// 탭 시 콜백 (내부 라우팅 또는 URL 열기).
  final VoidCallback? onTap;

  /// 방문 여부.
  final bool isVisited;

  /// 텍스트 색상 (기본값: linkBlue).
  final Color? color;

  /// 폰트 크기.
  final double? fontSize;

  /// 아이콘 (선택).
  final IconData? icon;

  /// 아이콘 위치.
  final SketchLinkIconPosition iconPosition;

  const SketchLink({
    super.key,
    required this.text,
    this.onTap,
    this.isVisited = false,
    this.color,
    this.fontSize,
    this.icon,
    this.iconPosition = SketchLinkIconPosition.trailing,
  });

  @override
  State<SketchLink> createState() => _SketchLinkState();
}

class _SketchLinkState extends State<SketchLink> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ??
        (widget.isVisited
            ? SketchDesignTokens.linkBlue.withValues(alpha: 0.7)
            : SketchDesignTokens.linkBlue);

    final effectiveFontSize = widget.fontSize ?? SketchDesignTokens.fontSizeBase;

    // 상태별 스타일 결정
    final textColor = _isPressed || _isHovered
        ? SketchDesignTokens.linkBlue.withValues(alpha: 0.7)
        : effectiveColor;

    final decorationStyle = _isPressed || _isHovered
        ? TextDecorationStyle.solid
        : TextDecorationStyle.dashed;

    final decorationThickness = _isPressed || _isHovered ? 1.5 : 1.0;

    final backgroundColor = _isPressed
        ? SketchDesignTokens.linkBlue.withValues(alpha: 0.15)
        : (_isHovered
            ? SketchDesignTokens.linkBlue.withValues(alpha: 0.08)
            : Colors.transparent);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null && widget.iconPosition == SketchLinkIconPosition.leading) ...[
                Icon(
                  widget.icon,
                  size: effectiveFontSize,
                  color: textColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontFamily: SketchDesignTokens.fontFamilyHand,
                  fontSize: effectiveFontSize,
                  color: textColor,
                  decoration: TextDecoration.underline,
                  decorationStyle: decorationStyle,
                  decorationColor: textColor,
                  decorationThickness: decorationThickness,
                ),
              ),
              if (widget.icon != null && widget.iconPosition == SketchLinkIconPosition.trailing) ...[
                const SizedBox(width: 4),
                Icon(
                  widget.icon,
                  size: effectiveFontSize,
                  color: textColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 링크 탭 처리.
  void _handleTap() {
    widget.onTap?.call();
  }
}
