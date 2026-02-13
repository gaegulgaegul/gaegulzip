import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일 모양의 모달 다이얼로그.
///
/// Frame0 스타일의 스케치 미학을 가진 다이얼로그를 생성함.
/// 제목, 콘텐츠, 액션 버튼, 닫기 버튼을 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchModal.show(
///   context: context,
///   child: Text('Modal content'),
/// )
/// ```
///
/// **제목과 액션:**
/// ```dart
/// SketchModal.show(
///   context: context,
///   title: 'Confirm Delete',
///   child: Text('Are you sure you want to delete this item?'),
///   actions: [
///     SketchButton(
///       text: 'Cancel',
///       style: SketchButtonStyle.outline,
///       onPressed: () => Navigator.of(context).pop(),
///     ),
///     SketchButton(
///       text: 'Delete',
///       onPressed: () {
///         // 삭제 수행
///         Navigator.of(context).pop(true);
///       },
///     ),
///   ],
/// )
/// ```
///
/// **커스텀 스타일링:**
/// ```dart
/// SketchModal.show(
///   context: context,
///   title: 'Custom Modal',
///   child: Column(
///     children: [
///       Text('Line 1'),
///       Text('Line 2'),
///     ],
///   ),
///   width: 500,
///   fillColor: SketchDesignTokens.accentLight,
///   barrierDismissible: false,
/// )
/// ```
///
/// **닫기 버튼 없이:**
/// ```dart
/// SketchModal.show(
///   context: context,
///   child: Text('No close button'),
///   showCloseButton: false,
/// )
/// ```
///
/// **반환값:**
/// ```dart
/// final result = await SketchModal.show<bool>(
///   context: context,
///   child: Text('Confirm?'),
///   actions: [
///     SketchButton(
///       text: 'Yes',
///       onPressed: () => Navigator.pop(context, true),
///     ),
///   ],
/// );
/// if (result == true) {
///   print('User confirmed');
/// }
/// ```
class SketchModal {
  /// 스케치 스타일 모달 다이얼로그를 표시함.
  ///
  /// 다이얼로그가 닫힐 때 해결되는 Future를 반환함.
  /// 반환된 값은 Navigator.pop()에 전달된 결과임.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool showCloseButton = true,
    bool barrierDismissible = true,
    double? width,
    double? height,
    Color? fillColor,
    Color? borderColor,
    double? strokeWidth,
    double? roughness,
    int seed = 0,
    bool showBorder = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _SketchModalDialog(
        title: title,
        actions: actions,
        showCloseButton: showCloseButton,
        width: width,
        height: height,
        fillColor: fillColor,
        borderColor: borderColor,
        strokeWidth: strokeWidth,
        roughness: roughness,
        seed: seed,
        showBorder: showBorder,
        child: child,
      ),
    );
  }
}

/// 내부 모달 다이얼로그 widget.
class _SketchModalDialog extends StatefulWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool showCloseButton;
  final double? width;
  final double? height;
  final Color? fillColor;
  final Color? borderColor;
  final double? strokeWidth;
  final double? roughness;
  final int seed;
  final bool showBorder;

  const _SketchModalDialog({
    this.title,
    required this.child,
    this.actions,
    this.showCloseButton = true,
    this.width,
    this.height,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
    this.showBorder = true,
  });

  @override
  State<_SketchModalDialog> createState() => _SketchModalDialogState();
}

class _SketchModalDialogState extends State<_SketchModalDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    final effectiveFillColor = widget.fillColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
    final effectiveStrokeWidth = widget.strokeWidth ?? SketchDesignTokens.strokeBold;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;
    final effectiveShadowColor = sketchTheme?.shadowColor ?? SketchDesignTokens.shadowColor;
    final effectiveShadowOffset = sketchTheme?.shadowOffset ?? SketchDesignTokens.shadowOffsetMd;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: widget.width ?? 400,
            height: widget.height,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 그림자 레이어 (본체와 동일한 모양, 오프셋 적용)
                Positioned(
                  left: effectiveShadowOffset.dx,
                  top: effectiveShadowOffset.dy,
                  right: -effectiveShadowOffset.dx,
                  bottom: -effectiveShadowOffset.dy,
                  child: CustomPaint(
                    painter: SketchPainter(
                      fillColor: effectiveShadowColor,
                      borderColor: Colors.transparent,
                      showBorder: false,
                      seed: widget.seed,
                      roughness: effectiveRoughness,
                      enableNoise: false,
                      borderRadius: SketchDesignTokens.irregularBorderRadius,
                    ),
                  ),
                ),
                // 본체 레이어 (Stack 크기를 결정하는 non-positioned child)
                CustomPaint(
                  painter: SketchPainter(
                    fillColor: effectiveFillColor,
                    borderColor: effectiveBorderColor,
                    strokeWidth: effectiveStrokeWidth,
                    showBorder: widget.showBorder,
                    seed: widget.seed,
                    roughness: effectiveRoughness,
                    enableNoise: true,
                    borderRadius: SketchDesignTokens.irregularBorderRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 헤더 (제목 + 닫기 버튼)
                        if (widget.title != null || widget.showCloseButton)
                          _buildHeader(context),

                        // 헤더 뒤 간격
                        if (widget.title != null || widget.showCloseButton)
                          const SizedBox(height: SketchDesignTokens.spacingMd),

                        // 콘텐츠
                        Flexible(
                          child: SingleChildScrollView(
                            child: widget.child,
                          ),
                        ),

                        // 액션
                        if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                          const SizedBox(height: SketchDesignTokens.spacingLg),
                          _buildActions(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;

    return Row(
      children: [
        // 제목 (핸드라이팅 폰트 적용)
        if (widget.title != null)
          Expanded(
            child: Text(
              widget.title!,
              style: TextStyle(
                fontFamily: SketchDesignTokens.fontFamilyHand,
                fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                fontSize: SketchDesignTokens.fontSizeLg,
                fontWeight: FontWeight.w600,
                color: sketchTheme?.textColor ?? SketchDesignTokens.base900,
              ),
            ),
          ),

        // 닫기 버튼 (손그림 X)
        if (widget.showCloseButton)
          _SketchCloseButton(
            color: effectiveBorderColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: SketchDesignTokens.spacingSm,
      children: widget.actions!,
    );
  }
}

/// 스케치 스타일 닫기 버튼 (손그림 X 마크).
class _SketchCloseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;

  const _SketchCloseButton({
    required this.onPressed,
    required this.color,
  });

  @override
  State<_SketchCloseButton> createState() => _SketchCloseButtonState();
}

class _SketchCloseButtonState extends State<_SketchCloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Container(
            decoration: BoxDecoration(
              color: _isPressed ? (sketchTheme?.disabledFillColor ?? SketchDesignTokens.base200) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(16, 16),
                painter: _SketchXPainter(
                  color: widget.color,
                  strokeWidth: SketchDesignTokens.strokeBold,
                  roughness: 0.8,
                  seed: 42,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 손그림 스타일 X 마크를 그리는 CustomPainter.
///
/// 두 개의 대각선을 각각 2번씩 그려 손으로 그린 효과를 만듦.
/// roughness로 선의 흔들림 정도를 제어함.
class _SketchXPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double roughness;
  final int seed;

  const _SketchXPainter({
    required this.color,
    this.strokeWidth = SketchDesignTokens.strokeBold,
    this.roughness = 0.8,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 대각선 2개를 각각 2번씩 그려 손그림 효과 생성 (총 4패스)
    final lines = [
      [Offset(0, 0), Offset(size.width, size.height)], // 좌상→우하
      [Offset(size.width, 0), Offset(0, size.height)], // 우상→좌하
    ];

    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final start = lines[lineIdx][0];
      final end = lines[lineIdx][1];

      for (int pass = 0; pass < 2; pass++) {
        final random = Random(seed + lineIdx * 100 + pass * 10);
        final path = _createWobblyLine(start, end, random);
        canvas.drawPath(path, paint);
      }
    }
  }

  /// 흔들리는 손그림 선 경로 생성.
  Path _createWobblyLine(Offset start, Offset end, Random random) {
    final path = Path();
    const segments = 4;

    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final perpAngle = angle + pi / 2;

    // 모든 점을 미리 계산
    final points = <Offset>[];
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;
      final offset = (random.nextDouble() - 0.5) * roughness * 2.0;
      points.add(Offset(
        x + cos(perpAngle) * offset,
        y + sin(perpAngle) * offset,
      ));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= segments; i++) {
      final controlX = (points[i - 1].dx + points[i].dx) / 2;
      final controlY = (points[i - 1].dy + points[i].dy) / 2;
      path.quadraticBezierTo(controlX, controlY, points[i].dx, points[i].dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _SketchXPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        roughness != oldDelegate.roughness ||
        seed != oldDelegate.seed;
  }
}
