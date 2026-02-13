import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 아이콘 버튼의 모양 변형.
enum SketchIconButtonShape {
  /// 원형 버튼 (기본값).
  circle,

  /// 둥근 모서리를 가진 사각형 버튼.
  square,
}

/// 손으로 그린 스케치 스타일 모양의 아이콘 버튼.
///
/// Frame0 스타일의 스케치 미학을 가진 아이콘 전용 버튼을 생성함.
/// 원형과 사각형 모양, 툴팁, 배지 알림을 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchIconButton(
///   icon: Icons.settings,
///   onPressed: () => print('Settings'),
/// )
/// ```
///
/// **툴팁과 함께:**
/// ```dart
/// SketchIconButton(
///   icon: Icons.favorite,
///   tooltip: 'Add to favorites',
///   onPressed: () {},
/// )
/// ```
///
/// **배지와 함께:**
/// ```dart
/// SketchIconButton(
///   icon: Icons.notifications,
///   badgeCount: 5,
///   onPressed: () => showNotifications(),
/// )
/// ```
///
/// **다양한 모양:**
/// ```dart
/// SketchIconButton(
///   icon: Icons.menu,
///   shape: SketchIconButtonShape.square,
///   onPressed: () {},
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// SketchIconButton(
///   icon: Icons.delete,
///   iconColor: SketchDesignTokens.error,
///   fillColor: SketchDesignTokens.errorLight,
///   onPressed: () {},
/// )
/// ```
///
/// **크기:**
/// ```dart
/// SketchIconButton(
///   icon: Icons.add,
///   size: 56.0, // 큰 버튼
///   iconSize: 28.0,
///   onPressed: () {},
/// )
/// ```
class SketchIconButton extends StatefulWidget {
  /// 표시할 아이콘.
  final IconData icon;

  /// 버튼이 눌렸을 때 콜백 (null = 비활성화).
  final VoidCallback? onPressed;

  /// 툴팁 텍스트 (길게 누르면 표시됨).
  final String? tooltip;

  /// 오른쪽 위에 표시되는 배지 개수 (null = 배지 없음).
  final int? badgeCount;

  /// 버튼 모양 (원형 또는 사각형).
  final SketchIconButtonShape shape;

  /// 버튼 크기 (너비와 높이).
  final double size;

  /// 아이콘 크기.
  final double iconSize;

  /// 아이콘 색상.
  final Color? iconColor;

  /// 버튼 배경의 채우기 색상.
  final Color? fillColor;

  /// 테두리/스트로크 색상.
  final Color? borderColor;

  /// 테두리의 스트로크 너비.
  final double? strokeWidth;

  /// 테두리 표시 여부.
  final bool showBorder;

  const SketchIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.badgeCount,
    this.shape = SketchIconButtonShape.circle,
    this.size = 44.0,
    this.iconSize = 24.0,
    this.iconColor,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.showBorder = true,
  });

  @override
  State<SketchIconButton> createState() => _SketchIconButtonState();
}

class _SketchIconButtonState extends State<SketchIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final isDisabled = widget.onPressed == null;

    final effectiveFillColor = widget.fillColor ?? sketchTheme?.fillColor ?? Colors.transparent;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base300;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveIconColor = widget.iconColor ?? sketchTheme?.iconColor ?? SketchDesignTokens.base900;

    final button = Opacity(
      opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: isDisabled
            ? null
            : (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              },
        onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 버튼
                CustomPaint(
                  painter: SketchPainter(
                    fillColor: effectiveFillColor,
                    borderColor: effectiveBorderColor,
                    strokeWidth: effectiveStrokeWidth,
                    roughness: sketchTheme?.roughness ??
                        SketchDesignTokens.roughness,
                    seed: widget.icon.hashCode,
                    enableNoise: true,
                    showBorder: widget.showBorder,
                    borderRadius:
                        widget.shape == SketchIconButtonShape.circle
                            ? 9999.0
                            : 6.0,
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: widget.iconSize,
                      color: isDisabled
                          ? (sketchTheme?.disabledTextColor ??
                              SketchDesignTokens.base500)
                          : effectiveIconColor,
                    ),
                  ),
                ),

                // 배지
                if (widget.badgeCount != null && widget.badgeCount! > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: _SketchBadge(
                      count: widget.badgeCount!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// 알림 개수를 위한 스케치 스타일 배지.
class _SketchBadge extends StatelessWidget {
  final int count;

  const _SketchBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: SketchDesignTokens.error,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              displayCount,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
