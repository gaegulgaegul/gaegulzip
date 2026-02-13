import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../theme/sketch_theme_extension.dart';

/// 손그림 스타일 라디오 버튼 위젯
///
/// Frame0 스타일의 라디오 버튼.
/// 그룹 내에서 하나만 선택 가능한 단일 선택 컨트롤.
///
/// **기본 사용법:**
/// ```dart
/// SketchRadio<String>(
///   value: 'option1',
///   groupValue: selectedValue,
///   label: 'Option 1',
///   onChanged: (value) {
///     setState(() => selectedValue = value);
///   },
/// )
/// ```
///
/// **비활성화 상태:**
/// ```dart
/// SketchRadio<String>(
///   value: 'option1',
///   groupValue: selectedValue,
///   label: 'Option 1',
///   onChanged: null, // null이면 비활성화
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// SketchRadio<String>(
///   value: 'option1',
///   groupValue: selectedValue,
///   label: 'Option 1',
///   activeColor: SketchDesignTokens.accentSecondary,
///   onChanged: (value) {},
/// )
/// ```
///
/// **라디오 그룹 예시:**
/// ```dart
/// Column(
///   children: [
///     SketchRadio<String>(
///       value: 'instant',
///       groupValue: _notificationFrequency,
///       label: '즉시',
///       onChanged: (value) {
///         setState(() => _notificationFrequency = value);
///       },
///     ),
///     SketchRadio<String>(
///       value: 'hourly',
///       groupValue: _notificationFrequency,
///       label: '1시간마다',
///       onChanged: (value) {
///         setState(() => _notificationFrequency = value);
///       },
///     ),
///     SketchRadio<String>(
///       value: 'daily',
///       groupValue: _notificationFrequency,
///       label: '하루 1번',
///       onChanged: (value) {
///         setState(() => _notificationFrequency = value);
///       },
///     ),
///   ],
/// )
/// ```
class SketchRadio<T> extends StatefulWidget {
  /// 라디오 버튼의 값
  final T value;

  /// 그룹의 현재 선택된 값
  final T groupValue;

  /// 선택 변경 시 콜백 (null이면 비활성화)
  final ValueChanged<T>? onChanged;

  /// 라디오 버튼 라벨
  final String? label;

  /// 라디오 버튼 크기
  final double size;

  /// 선택 시 색상
  final Color? activeColor;

  /// 비선택 시 색상
  final Color? inactiveColor;

  const SketchRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<SketchRadio<T>> createState() => _SketchRadioState<T>();
}

class _SketchRadioState<T> extends State<SketchRadio<T>> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    if (_isSelected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SketchRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value || widget.groupValue != oldWidget.groupValue) {
      if (_isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isSelected => widget.value == widget.groupValue;

  bool get _isDisabled => widget.onChanged == null;

  void _handleTap() {
    if (widget.onChanged != null && !_isSelected) {
      widget.onChanged!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final effectiveActiveColor = widget.activeColor ?? SketchDesignTokens.accentPrimary;
    final effectiveInactiveColor = widget.inactiveColor ?? sketchTheme?.iconColor ?? SketchDesignTokens.base700;

    return Opacity(
      opacity: _isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: GestureDetector(
        onTap: _isDisabled ? null : _handleTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 라디오 버튼 원형
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SketchCirclePainter(
                      fillColor: _isSelected
                          ? effectiveActiveColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderColor: _isSelected ? effectiveActiveColor : effectiveInactiveColor,
                      strokeWidth: 2.0,
                    ),
                    child: _isSelected
                        ? Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              width: widget.size * 0.5 * _scaleAnimation.value,
                              height: widget.size * 0.5 * _scaleAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: effectiveActiveColor,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),

            // 라벨
            if (widget.label != null) ...[
              const SizedBox(width: 8),
              Text(
                widget.label!,
                style: TextStyle(
                  fontFamily: SketchDesignTokens.fontFamilyHand,
                  fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                  fontSize: SketchDesignTokens.fontSizeBase,
                  color: _isDisabled
                      ? (sketchTheme?.disabledTextColor ?? SketchDesignTokens.textDisabled)
                      : (_isSelected
                          ? (sketchTheme?.textColor ?? SketchDesignTokens.textPrimary)
                          : (sketchTheme?.textSecondaryColor ?? SketchDesignTokens.textSecondary)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 원형 테두리 CustomPainter
class _SketchCirclePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  const _SketchCirclePainter({
    required this.fillColor,
    required this.borderColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원 (채우기)
    if (fillColor != Colors.transparent) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);
    }

    // 테두리 원
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SketchCirclePainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
