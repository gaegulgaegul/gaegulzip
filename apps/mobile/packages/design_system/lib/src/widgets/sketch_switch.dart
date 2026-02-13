import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/hatching_painter.dart';
import '../painters/sketch_circle_painter.dart';
import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손그림 스타일 스위치 위젯
///
/// Frame0 스타일의 토글 스위치.
/// SketchPainter로 트랙을, SketchCirclePainter로 썸을 렌더링하여
/// 손으로 그린 듯한 불규칙한 질감을 표현.
///
/// **기본 사용법:**
/// ```dart
/// SketchSwitch(
///   value: true,
///   onChanged: (value) {
///     setState(() => isOn = value);
///   },
/// )
/// ```
///
/// **비활성화 상태:**
/// ```dart
/// SketchSwitch(
///   value: false,
///   onChanged: null, // null이면 비활성화
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// SketchSwitch(
///   value: true,
///   onChanged: (value) {},
///   activeColor: SketchDesignTokens.success,
///   inactiveColor: SketchDesignTokens.base300,
/// )
/// ```
///
/// **레이블과 함께 사용:**
/// ```dart
/// Row(
///   children: [
///     Text('알림 받기'),
///     SizedBox(width: 8),
///     SketchSwitch(
///       value: notificationsEnabled,
///       onChanged: (value) {
///         setState(() => notificationsEnabled = value);
///       },
///     ),
///   ],
/// )
/// ```
class SketchSwitch extends StatefulWidget {
  /// 현재 스위치 상태 (true = ON, false = OFF)
  final bool value;

  /// 상태 변경 콜백 (null이면 비활성화)
  final ValueChanged<bool>? onChanged;

  /// ON 상태일 때 배경 색상
  final Color? activeColor;

  /// OFF 상태일 때 배경 색상
  final Color? inactiveColor;

  /// 썸(동그란 손잡이) 색상
  final Color? thumbColor;

  /// 스위치 너비
  final double width;

  /// 스위치 높이
  final double height;

  /// 선 두께
  final double? strokeWidth;

  /// 거칠기 계수 (0.0-1.0+)
  final double? roughness;

  /// 재현 가능한 렌더링을 위한 무작위 시드
  final int seed;

  const SketchSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.width = 50.0,
    this.height = 28.0,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
  });

  @override
  State<SketchSwitch> createState() => _SketchSwitchState();
}

class _SketchSwitchState extends State<SketchSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _positionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SketchSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      if (widget.value) {
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

  void _handleTap() {
    if (widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final isDisabled = widget.onChanged == null;

    final effectiveActiveColor = isDisabled
        ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
        : widget.activeColor ??
            sketchTheme?.textColor ??
            SketchDesignTokens.base900;
    final effectiveInactiveColor = isDisabled
        ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
        : widget.inactiveColor ??
            sketchTheme?.disabledBorderColor ??
            SketchDesignTokens.base300;
    final effectiveThumbColor = isDisabled
        ? (sketchTheme?.disabledFillColor ?? SketchDesignTokens.base200)
        : widget.thumbColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveStrokeWidth = widget.strokeWidth ??
        sketchTheme?.strokeWidth ??
        SketchDesignTokens.strokeStandard;
    final effectiveRoughness =
        widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;
    final hatchingColor =
        sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500;

    // 스위치 작은 크기에 맞게 질감 증폭 (70%)
    final switchRoughness = effectiveRoughness * 1.75;
    final switchStrokeWidth = effectiveStrokeWidth * 1.05;

    // 썸 크기 계산
    final thumbSize = widget.height - 8.0;
    final thumbPadding = 4.0;

    return Opacity(
      opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : _handleTap,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _positionAnimation,
            builder: (context, child) {
              // 트랙 색상 보간
              final trackColor = Color.lerp(
                effectiveInactiveColor,
                effectiveActiveColor,
                _positionAnimation.value,
              )!;

              // 썸 위치 계산
              final thumbPosition = thumbPadding +
                  (widget.width - thumbSize - thumbPadding * 2) *
                      _positionAnimation.value;

              return Stack(
                children: [
                  // 트랙 (pill shape — SketchPainter, 채우기 + 테두리)
                  CustomPaint(
                    painter: SketchPainter(
                      fillColor: trackColor,
                      borderColor: trackColor,
                      strokeWidth: switchStrokeWidth,
                      roughness: switchRoughness,
                      seed: widget.seed,
                      enableNoise: true,
                      showBorder: true,
                      borderRadius: 9999,
                    ),
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),

                  // 트랙 2차 테두리 (다른 시드로 겹쳐 그려 손그림 효과 강화)
                  CustomPaint(
                    painter: SketchPainter(
                      fillColor: Colors.transparent,
                      borderColor: trackColor,
                      strokeWidth: switchStrokeWidth,
                      roughness: switchRoughness,
                      seed: widget.seed + 50,
                      enableNoise: false,
                      showBorder: true,
                      borderRadius: 9999,
                    ),
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),

                  // 비활성화 빗금 오버레이
                  if (isDisabled)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HatchingPainter(
                          fillColor: hatchingColor,
                          strokeWidth: 1.0,
                          angle: pi / 4,
                          spacing: 6.0,
                          roughness: 0.5,
                          seed: widget.seed + 500,
                          borderRadius: 9999,
                        ),
                      ),
                    ),

                  // 썸 (원형 — SketchCirclePainter, 이미 2-pass 테두리 내장)
                  Positioned(
                    left: thumbPosition,
                    top: thumbPadding,
                    child: CustomPaint(
                      painter: SketchCirclePainter(
                        fillColor: effectiveThumbColor,
                        borderColor: effectiveThumbColor,
                        strokeWidth: switchStrokeWidth,
                        roughness: switchRoughness,
                        seed: widget.seed + 100,
                        enableNoise: true,
                      ),
                      child: SizedBox(
                        width: thumbSize,
                        height: thumbSize,
                      ),
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
