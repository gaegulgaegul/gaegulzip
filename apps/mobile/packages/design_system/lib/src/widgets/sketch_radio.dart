import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/hatching_painter.dart';
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

  /// 비활성화 시 대각선 빗금 오버레이 표시 여부
  final bool enableDisabledHatching;

  const SketchRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.enableDisabledHatching = false,
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
    final textColor = sketchTheme?.textColor ?? SketchDesignTokens.base900;

    // 빗금 활성화 여부
    final showHatching = _isDisabled && widget.enableDisabledHatching;

    // 모노크롬 스타일: 선택/비선택 모두 textColor 기반
    final effectiveBorderColor = showHatching
        ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
        : _isSelected
            ? (widget.activeColor ?? textColor)
            : (widget.inactiveColor ?? textColor);
    final effectiveDotColor = showHatching
        ? (sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500)
        : (widget.activeColor ?? textColor);

    return Opacity(
      opacity: _isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: GestureDetector(
        onTap: _isDisabled ? null : _handleTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 라디오 버튼 원형 (스케치 스타일)
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _SketchRadioPainter(
                          borderColor: effectiveBorderColor,
                          dotColor: effectiveDotColor,
                          strokeWidth: SketchDesignTokens.strokeStandard,
                          innerDotScale: _scaleAnimation.value,
                          roughness: sketchTheme?.roughness ?? SketchDesignTokens.roughness,
                          seed: widget.value.hashCode,
                        ),
                      ),
                      if (showHatching)
                        ClipOval(
                          child: CustomPaint(
                            painter: HatchingPainter(
                              fillColor: effectiveDotColor,
                              strokeWidth: 1.0,
                              angle: pi / 4,
                              spacing: 6.0,
                              roughness: 0.5,
                              seed: widget.value.hashCode + 500,
                              borderRadius: 9999,
                            ),
                            child: SizedBox(
                              width: widget.size,
                              height: widget.size,
                            ),
                          ),
                        ),
                    ],
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
                      : textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 스케치 스타일 라디오 버튼 CustomPainter.
///
/// 외부 원과 내부 점을 모두 손그림 스타일로 렌더링.
/// [innerDotScale]로 선택 애니메이션 제어 (0.0=비선택, 1.0=선택).
class _SketchRadioPainter extends CustomPainter {
  final Color borderColor;
  final Color dotColor;
  final double strokeWidth;
  final double innerDotScale;
  final double roughness;
  final int seed;

  const _SketchRadioPainter({
    required this.borderColor,
    required this.dotColor,
    this.strokeWidth = SketchDesignTokens.strokeStandard,
    this.innerDotScale = 0.0,
    this.roughness = SketchDesignTokens.roughness,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (min(size.width, size.height) - strokeWidth) / 2;
    final random = Random(seed);

    // 1. 외부 원 (스케치 스타일 테두리)
    final outerPath = _createSketchCirclePath(center, outerRadius, random);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(outerPath, borderPaint);

    // 2. 내부 점 (스케치 스타일 채우기)
    if (innerDotScale > 0.01) {
      final dotRadius = outerRadius * 0.45 * innerDotScale;
      final dotRandom = Random(seed + 100);
      final dotPath = _createSketchCirclePath(center, dotRadius, dotRandom);
      final dotPaint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(dotPath, dotPaint);
    }
  }

  /// 손그림 스타일 원형 경로 생성.
  ///
  /// 이상적 원 경로를 따라 포인트를 샘플링하고
  /// 법선 방향으로 jitter를 추가하여 불규칙한 원을 만듦.
  Path _createSketchCirclePath(Offset center, double radius, Random random) {
    if (roughness <= 0.01 || radius < 2) {
      return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    }

    final idealPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final metrics = idealPath.computeMetrics().toList();
    if (metrics.isEmpty) return idealPath;

    final metric = metrics.first;
    final totalLength = metric.length;

    // 원 둘레에 따라 포인트 수 조정 (약 4px마다 1개)
    final numPoints = (totalLength / 4).round().clamp(16, 80);
    // 반지름에 비례하여 jitter 스케일링 (작은 원은 더 적은 jitter)
    final maxJitter = roughness * 0.6 * min(1.0, radius / 6);

    final points = <Offset>[];

    for (int i = 0; i < numPoints; i++) {
      final distance = totalLength * i / numPoints;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
        points.add(tangent.position + normal * jitter);
      }
    }

    if (points.length < 3) return idealPath;

    // 이차 베지어 곡선으로 부드럽게 연결
    final sketchPath = Path();
    sketchPath.moveTo(
      (points.last.dx + points.first.dx) / 2,
      (points.last.dy + points.first.dy) / 2,
    );

    for (int i = 0; i < points.length; i++) {
      final curr = points[i];
      final next = points[(i + 1) % points.length];
      sketchPath.quadraticBezierTo(
        curr.dx,
        curr.dy,
        (curr.dx + next.dx) / 2,
        (curr.dy + next.dy) / 2,
      );
    }

    sketchPath.close();
    return sketchPath;
  }

  @override
  bool shouldRepaint(covariant _SketchRadioPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
        dotColor != oldDelegate.dotColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        innerDotScale != oldDelegate.innerDotScale ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed;
  }
}
