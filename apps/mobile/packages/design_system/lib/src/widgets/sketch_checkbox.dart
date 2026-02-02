import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../painters/sketch_line_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손그림 스타일 체크박스 위젯
///
/// Frame0 스타일의 체크박스.
/// 선택/미선택/일부선택 상태를 지원.
///
/// **기본 사용법:**
/// ```dart
/// SketchCheckbox(
///   value: true,
///   onChanged: (value) {
///     setState(() => isChecked = value);
///   },
/// )
/// ```
///
/// **비활성화 상태:**
/// ```dart
/// SketchCheckbox(
///   value: false,
///   onChanged: null, // null이면 비활성화
/// )
/// ```
///
/// **일부 선택 상태 (tristate):**
/// ```dart
/// SketchCheckbox(
///   value: null, // null = 일부 선택
///   tristate: true,
///   onChanged: (value) {
///     // value는 true, false, null 순환
///   },
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// SketchCheckbox(
///   value: true,
///   onChanged: (value) {},
///   activeColor: SketchDesignTokens.success,
/// )
/// ```
///
/// **레이블과 함께 사용:**
/// ```dart
/// Row(
///   children: [
///     SketchCheckbox(
///       value: agreeToTerms,
///       onChanged: (value) {
///         setState(() => agreeToTerms = value ?? false);
///       },
///     ),
///     SizedBox(width: 8),
///     Text('이용약관에 동의합니다'),
///   ],
/// )
/// ```
class SketchCheckbox extends StatefulWidget {
  /// 현재 체크 상태 (true = 체크됨, false = 체크 안됨, null = 일부 선택)
  final bool? value;

  /// 상태 변경 콜백 (null이면 비활성화)
  final ValueChanged<bool?>? onChanged;

  /// 3가지 상태 지원 여부 (true, false, null)
  final bool tristate;

  /// 체크됐을 때 배경 색상
  final Color? activeColor;

  /// 체크 안됐을 때 테두리 색상
  final Color? inactiveColor;

  /// 체크 마크 색상
  final Color? checkColor;

  /// 체크박스 크기
  final double size;

  /// 선 두께
  final double? strokeWidth;

  /// 거칠기 계수
  final double? roughness;

  /// 랜덤 시드
  final int seed;

  const SketchCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.tristate = false,
    this.activeColor,
    this.inactiveColor,
    this.checkColor,
    this.size = 24.0,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
  }) : assert(tristate || value != null, 'value는 tristate가 true일 때만 null 가능');

  @override
  State<SketchCheckbox> createState() => _SketchCheckboxState();
}

class _SketchCheckboxState extends State<SketchCheckbox> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.value == true) {
      _animationController.value = 1.0;
    } else if (widget.value == null && widget.tristate) {
      _animationController.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(SketchCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      if (widget.value == true) {
        _animationController.forward();
      } else if (widget.value == null && widget.tristate) {
        _animationController.animateTo(0.5);
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

  void _handleTap() {
    if (widget.onChanged != null) {
      if (widget.tristate) {
        // true -> false -> null -> true 순환
        if (widget.value == true) {
          widget.onChanged!(false);
        } else if (widget.value == false) {
          widget.onChanged!(null);
        } else {
          widget.onChanged!(true);
        }
      } else {
        // true <-> false 토글
        widget.onChanged!(!widget.value!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final isDisabled = widget.onChanged == null;

    final effectiveActiveColor = widget.activeColor ?? SketchDesignTokens.accentPrimary;
    final effectiveInactiveColor = widget.inactiveColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base300;
    final effectiveCheckColor = widget.checkColor ?? Colors.white;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;

    return Opacity(
      opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : _handleTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              // 배경 색상 보간
              final backgroundColor = widget.value == true
                  ? effectiveActiveColor
                  : Colors.transparent;

              final borderColor = widget.value == true
                  ? effectiveActiveColor
                  : effectiveInactiveColor;

              return Stack(
                children: [
                  // 배경
                  CustomPaint(
                    painter: SketchPainter(
                      fillColor: backgroundColor,
                      borderColor: borderColor,
                      strokeWidth: effectiveStrokeWidth,
                      roughness: effectiveRoughness,
                      seed: widget.seed,
                      enableNoise: false,
                    ),
                    child: const SizedBox.expand(),
                  ),

                  // 체크 마크 또는 대시
                  if (widget.value == true)
                    // 체크 마크 (V 모양)
                    Padding(
                      padding: EdgeInsets.all(widget.size * 0.2),
                      child: CustomPaint(
                        painter: _SketchCheckMarkPainter(
                          color: effectiveCheckColor,
                          strokeWidth: effectiveStrokeWidth,
                          roughness: effectiveRoughness,
                          seed: widget.seed + 1,
                          progress: _checkAnimation.value,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    )
                  else if (widget.value == null && widget.tristate)
                    // 대시 (-)
                    Padding(
                      padding: EdgeInsets.all(widget.size * 0.3),
                      child: CustomPaint(
                        painter: SketchLinePainter(
                          start: Offset(0, widget.size * 0.2),
                          end: Offset(widget.size * 0.4, widget.size * 0.2),
                          color: effectiveCheckColor,
                          strokeWidth: effectiveStrokeWidth,
                          roughness: effectiveRoughness,
                          seed: widget.seed + 2,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 체크 마크 CustomPainter
class _SketchCheckMarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double roughness;
  final int seed;
  final double progress;

  const _SketchCheckMarkPainter({
    required this.color,
    required this.strokeWidth,
    required this.roughness,
    required this.seed,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 체크 마크는 두 개의 선으로 구성
    // 1. 왼쪽 아래에서 중간으로 (짧은 선)
    // 2. 중간에서 오른쪽 위로 (긴 선)

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 첫 번째 선 (짧은 선)
    final p1Start = Offset(size.width * 0.2, size.height * 0.5);
    final p1End = Offset(size.width * 0.4, size.height * 0.7);

    // 두 번째 선 (긴 선)
    final p2Start = p1End;
    final p2End = Offset(size.width * 0.8, size.height * 0.2);

    // progress에 따라 선 그리기
    if (progress > 0) {
      if (progress <= 0.5) {
        // 첫 번째 선 그리기
        final currentProgress = progress * 2;
        final currentEnd = Offset.lerp(p1Start, p1End, currentProgress)!;
        canvas.drawLine(p1Start, currentEnd, paint);
      } else {
        // 첫 번째 선 완성, 두 번째 선 그리기
        canvas.drawLine(p1Start, p1End, paint);

        final currentProgress = (progress - 0.5) * 2;
        final currentEnd = Offset.lerp(p2Start, p2End, currentProgress)!;
        canvas.drawLine(p2Start, currentEnd, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SketchCheckMarkPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed ||
        progress != oldDelegate.progress;
  }
}
