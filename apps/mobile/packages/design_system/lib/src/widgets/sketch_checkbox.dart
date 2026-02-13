import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/hatching_painter.dart';
import '../painters/sketch_painter.dart';
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

  /// 테두리 표시 여부.
  final bool showBorder;

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
    this.showBorder = true,
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

    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;

    // 에셋 이미지 분석: 항상 투명 배경, 상태와 무관하게 textColor 사용
    final borderColor = isDisabled
        ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
        : (sketchTheme?.textColor ?? SketchDesignTokens.base900);

    final checkColor = isDisabled
        ? (sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500)
        : (sketchTheme?.textColor ?? SketchDesignTokens.base900);

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
              return Stack(
                children: [
                  // 테두리 (SketchPainter)
                  CustomPaint(
                    painter: SketchPainter(
                      fillColor: Colors.transparent,
                      borderColor: borderColor,
                      strokeWidth: effectiveStrokeWidth,
                      roughness: effectiveRoughness,
                      seed: widget.seed,
                      showBorder: widget.showBorder,
                      borderRadius: 4,
                      enableNoise: false, // 작은 체크박스에서는 노이즈 과함
                    ),
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                    ),
                  ),

                  // 비활성화 빗금 오버레이
                  if (isDisabled)
                    CustomPaint(
                      painter: HatchingPainter(
                        fillColor: checkColor,
                        strokeWidth: 1.0,
                        angle: pi / 4,
                        spacing: 6.0,
                        roughness: 0.5,
                        seed: widget.seed + 500,
                        borderRadius: 4.0,
                      ),
                      child: SizedBox(
                        width: widget.size,
                        height: widget.size,
                      ),
                    ),

                  // 체크 마크 또는 대시
                  if (widget.value == true)
                    // 체크 마크 (V 모양)
                    Padding(
                      padding: EdgeInsets.all(widget.size * 0.2),
                      child: CustomPaint(
                        painter: _SketchCheckMarkPainter(
                          color: checkColor,
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
                    Center(
                      child: Container(
                        width: widget.size * 0.4,
                        height: effectiveStrokeWidth,
                        color: checkColor,
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
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 첫 번째 선 (짧은 선)
    final p1Start = Offset(size.width * 0.2, size.height * 0.5);
    final p1End = Offset(size.width * 0.4, size.height * 0.7);

    // 두 번째 선 (긴 선)
    final p2Start = p1End;
    final p2End = Offset(size.width * 0.8, size.height * 0.2);

    // 스케치 스타일 Path 생성
    final path = _createSketchCheckPath(
      p1Start,
      p1End,
      p2Start,
      p2End,
      progress,
      roughness,
      seed,
    );

    canvas.drawPath(path, paint);
  }

  /// 두 점 사이를 균등하게 샘플링
  List<Offset> _samplePoints(Offset start, Offset end, int numPoints) {
    final points = <Offset>[];
    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints;
      points.add(Offset.lerp(start, end, t)!);
    }
    return points;
  }

  /// roughness 기반 스케치 스타일 체크마크 Path 생성
  Path _createSketchCheckPath(
    Offset p1Start,
    Offset p1End,
    Offset p2Start,
    Offset p2End,
    double progress,
    double roughness,
    int seed,
  ) {
    final random = Random(seed);
    final maxJitter = roughness * 0.3; // 테두리보다 작게
    final path = Path();

    // 첫 번째 선 (짧은 선)
    if (progress > 0) {
      final currentProgress = (progress * 2).clamp(0.0, 1.0);
      final currentEnd = Offset.lerp(p1Start, p1End, currentProgress)!;

      // 샘플링
      final line1Points = _samplePoints(p1Start, currentEnd, 6);

      // 선분 방향 벡터
      final direction = (p1End - p1Start);
      final length = direction.distance;
      if (length > 0) {
        final normalized = direction / length;
        // 법선 벡터 (선분에 수직)
        final normal = Offset(-normalized.dy, normalized.dx);

        // Jitter 적용
        final jitteredPoints = line1Points.map((p) {
          final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
          return p + normal * jitter;
        }).toList();

        // Path 생성
        if (jitteredPoints.isNotEmpty) {
          path.moveTo(jitteredPoints.first.dx, jitteredPoints.first.dy);
          for (int i = 0; i < jitteredPoints.length - 1; i++) {
            final curr = jitteredPoints[i];
            final next = jitteredPoints[i + 1];
            final midX = (curr.dx + next.dx) / 2;
            final midY = (curr.dy + next.dy) / 2;
            path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
          }
          // 마지막 포인트
          final last = jitteredPoints.last;
          path.lineTo(last.dx, last.dy);
        }
      }
    }

    // 두 번째 선 (긴 선)
    if (progress > 0.5) {
      final currentProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
      final currentEnd = Offset.lerp(p2Start, p2End, currentProgress)!;

      // 샘플링 (더 많은 포인트로 긴 선 표현)
      final line2Points = _samplePoints(p2Start, currentEnd, 8);

      // 선분 방향 벡터
      final direction = (p2End - p2Start);
      final length = direction.distance;
      if (length > 0) {
        final normalized = direction / length;
        final normal = Offset(-normalized.dy, normalized.dx);

        // Jitter 적용 (다른 seed로 다른 변형)
        final random2 = Random(seed + 100);
        final jitteredPoints = line2Points.map((p) {
          final jitter = (random2.nextDouble() - 0.5) * 2 * maxJitter;
          return p + normal * jitter;
        }).toList();

        // Path에 추가
        if (jitteredPoints.isNotEmpty) {
          path.moveTo(jitteredPoints.first.dx, jitteredPoints.first.dy);
          for (int i = 0; i < jitteredPoints.length - 1; i++) {
            final curr = jitteredPoints[i];
            final next = jitteredPoints[i + 1];
            final midX = (curr.dx + next.dx) / 2;
            final midY = (curr.dy + next.dy) / 2;
            path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
          }
          final last = jitteredPoints.last;
          path.lineTo(last.dx, last.dy);
        }
      }
    }

    return path;
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
