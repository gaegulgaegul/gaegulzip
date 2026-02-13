import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일 모양의 여러 줄 텍스트 입력 필드.
///
/// Frame0 스타일의 스케치 미학을 가진 여러 줄 TextField를 생성함.
/// [SketchPainter]를 사용하여 불규칙한 손그림 테두리와 노이즈 텍스처를 렌더링.
/// 우하단에 장식용 resize handle 표시.
///
/// **기본 사용법:**
/// ```dart
/// SketchTextArea(
///   hint: '의견을 자유롭게 작성하세요',
/// )
/// ```
///
/// **글자 수 제한과 카운터:**
/// ```dart
/// SketchTextArea(
///   label: '댓글',
///   hint: '댓글 입력',
///   maxLength: 500,
///   showCounter: true,
/// )
/// ```
///
/// **상태:**
/// - 일반: strokeBold 테두리, 스케치 질감
/// - 포커스: strokeThick 테두리, 더 두꺼운 스케치 효과
/// - 에러: 빨간 테두리, strokeBold
/// - 비활성화: 흐릿한 색상, strokeStandard
class SketchTextArea extends StatefulWidget {
  /// 입력 필드 위에 표시되는 라벨 텍스트.
  final String? label;

  /// 필드가 비어있을 때 내부에 표시되는 힌트 텍스트.
  final String? hint;

  /// 텍스트 입력 관리를 위한 controller.
  final TextEditingController? controller;

  /// 텍스트가 변경될 때 콜백.
  final ValueChanged<String>? onChanged;

  /// 최소 줄 수.
  final int minLines;

  /// 최대 줄 수 (null = 무제한 자동 확장).
  final int? maxLines;

  /// 최대 글자 수 (null = 무제한).
  final int? maxLength;

  /// 글자 수 카운터 표시 여부.
  final bool showCounter;

  /// 필드 아래에 표시되는 에러 텍스트.
  final String? errorText;

  /// 입력 포맷터.
  final List<TextInputFormatter>? inputFormatters;

  /// 필드 활성화 여부.
  final bool enabled;

  /// 필드 읽기 전용 여부.
  final bool readOnly;

  /// 이 필드 자동 포커스.
  final bool autofocus;

  /// 텍스트 정렬.
  final TextAlign textAlign;

  /// 텍스트 스타일.
  final TextStyle? style;

  /// 커스텀 채우기 색상.
  final Color? fillColor;

  /// 커스텀 테두리 색상.
  final Color? borderColor;

  /// 커스텀 스트로크 너비.
  final double? strokeWidth;

  /// 테두리 표시 여부.
  final bool showBorder;

  const SketchTextArea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 10,
    this.maxLength,
    this.showCounter = false,
    this.errorText,
    this.inputFormatters,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.style,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.showBorder = true,
  });

  @override
  State<SketchTextArea> createState() => _SketchTextAreaState();
}

class _SketchTextAreaState extends State<SketchTextArea> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late TextEditingController _effectiveController;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
    _effectiveController.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(covariant SketchTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _effectiveController.removeListener(_onTextChange);
      if (oldWidget.controller == null) {
        _effectiveController.dispose();
      }
      _effectiveController = widget.controller ?? TextEditingController();
      _effectiveController.addListener(_onTextChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _effectiveController.removeListener(_onTextChange);
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    if (widget.showCounter) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final hasError = widget.errorText != null;

    final colorSpec = _getColorSpec(
      sketchTheme,
      isFocused: _isFocused,
      hasError: hasError,
      isDisabled: !widget.enabled,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 (선택 사항)
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontFamily: SketchDesignTokens.fontFamilyHand,
              fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
              fontSize: SketchDesignTokens.fontSizeSm,
              fontWeight: FontWeight.w500,
              color: hasError
                  ? SketchDesignTokens.error
                  : (sketchTheme?.textColor ?? SketchDesignTokens.base900),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // 입력 필드 — CustomPaint + SketchPainter
        CustomPaint(
          painter: SketchPainter(
            fillColor: colorSpec.fillColor,
            borderColor: colorSpec.borderColor,
            strokeWidth: colorSpec.strokeWidth,
            roughness:
                sketchTheme?.roughness ?? SketchDesignTokens.roughness,
            seed: widget.label?.hashCode ?? widget.hint?.hashCode ?? 0,
            enableNoise: true,
            showBorder: widget.showBorder,
            borderRadius: SketchDesignTokens.irregularBorderRadius,
          ),
          child: Stack(
            children: [
              // 텍스트 입력 영역
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SketchDesignTokens.spacingMd,
                  vertical: SketchDesignTokens.spacingSm,
                ),
                child: TextField(
                  controller: _effectiveController,
                  focusNode: _focusNode,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  autofocus: widget.autofocus,
                  textAlign: widget.textAlign,
                  style: widget.style ??
                      TextStyle(
                        fontFamily: SketchDesignTokens.fontFamilyHand,
                        fontFamilyFallback:
                            SketchDesignTokens.fontFamilyHandFallback,
                        fontSize: SketchDesignTokens.fontSizeBase,
                        color: colorSpec.textColor,
                      ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      fontFamily: SketchDesignTokens.fontFamilyHand,
                      fontFamilyFallback:
                          SketchDesignTokens.fontFamilyHandFallback,
                      color: colorSpec.hintColor,
                      fontSize: SketchDesignTokens.fontSizeBase,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    counterText: '',
                  ),
                ),
              ),

              // Resize Handle — 우하단 장식용 대각선 줄무늬
              Positioned(
                right: SketchDesignTokens.spacingSm,
                bottom: SketchDesignTokens.spacingSm,
                child: CustomPaint(
                  size: const Size(14, 14),
                  painter: _ResizeHandlePainter(
                    color: colorSpec.borderColor,
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 글자 수 카운터 (선택 사항)
        if (widget.showCounter) _buildCounter(),

        // 에러 텍스트
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontFamily: SketchDesignTokens.fontFamilyHand,
              fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
              fontSize: SketchDesignTokens.fontSizeXs,
              color: SketchDesignTokens.error,
            ),
          ),
        ],
      ],
    );
  }

  /// 글자 수 카운터 위젯 빌드.
  Widget _buildCounter() {
    final currentLength = _effectiveController.text.length;

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          widget.maxLength != null
              ? '$currentLength / ${widget.maxLength}'
              : '$currentLength',
          style: TextStyle(
            fontFamily: SketchDesignTokens.fontFamilyMono,
            fontSize: SketchDesignTokens.fontSizeXs,
            color: _getCounterColor(
                currentLength, SketchThemeExtension.maybeOf(context)),
          ),
        ),
      ),
    );
  }

  /// 글자 수에 따른 카운터 색상 결정.
  Color _getCounterColor(int currentLength, SketchThemeExtension? theme) {
    final tertiaryColor =
        theme?.textSecondaryColor ?? SketchDesignTokens.textTertiary;

    if (widget.maxLength == null || widget.maxLength! <= 0) {
      return tertiaryColor;
    }
    final ratio = currentLength / widget.maxLength!;
    if (ratio >= 1.0) {
      return SketchDesignTokens.error;
    } else if (ratio >= 0.9) {
      return SketchDesignTokens.warning;
    }
    return tertiaryColor;
  }

  _ColorSpec _getColorSpec(
    SketchThemeExtension? theme, {
    required bool isFocused,
    required bool hasError,
    required bool isDisabled,
  }) {
    if (isDisabled) {
      return _ColorSpec(
        fillColor: theme?.disabledFillColor ?? SketchDesignTokens.base100,
        borderColor: theme?.disabledBorderColor ?? SketchDesignTokens.base300,
        textColor: theme?.disabledTextColor ?? SketchDesignTokens.base500,
        hintColor: theme?.disabledTextColor ?? SketchDesignTokens.base400,
        strokeWidth:
            widget.strokeWidth ?? SketchDesignTokens.strokeStandard,
      );
    }

    final effectiveTextColor = theme?.textColor ?? SketchDesignTokens.base900;
    final effectiveHintColor =
        theme?.textSecondaryColor ?? SketchDesignTokens.base500;

    if (hasError) {
      return _ColorSpec(
        fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
        borderColor: SketchDesignTokens.error,
        textColor: effectiveTextColor,
        hintColor: effectiveHintColor,
        strokeWidth:
            widget.strokeWidth ?? SketchDesignTokens.strokeBold,
      );
    }

    if (isFocused) {
      return _ColorSpec(
        fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
        borderColor: widget.borderColor ??
            theme?.focusBorderColor ??
            SketchDesignTokens.black,
        textColor: effectiveTextColor,
        hintColor: effectiveHintColor,
        strokeWidth:
            widget.strokeWidth ?? SketchDesignTokens.strokeThick,
      );
    }

    // 일반 상태 — strokeBold로 두꺼운 스케치 테두리 재현
    return _ColorSpec(
      fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
      borderColor: widget.borderColor ??
          theme?.borderColor ??
          SketchDesignTokens.base900,
      textColor: effectiveTextColor,
      hintColor: effectiveHintColor,
      strokeWidth:
          widget.strokeWidth ?? SketchDesignTokens.strokeBold,
    );
  }
}

/// 우하단 resize handle — 대각선 2줄 장식용 painter.
class _ResizeHandlePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ResizeHandlePainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final random = Random(42);
    final maxJitter = 0.3;

    // 첫 번째 대각선 (좌하 → 우상)
    _drawSketchLine(
      canvas,
      Offset(size.width * 0.35 + _jitter(random, maxJitter),
          size.height + _jitter(random, maxJitter)),
      Offset(size.width + _jitter(random, maxJitter),
          size.height * 0.35 + _jitter(random, maxJitter)),
      paint,
    );

    // 두 번째 대각선 (더 짧은 선)
    _drawSketchLine(
      canvas,
      Offset(size.width * 0.65 + _jitter(random, maxJitter),
          size.height + _jitter(random, maxJitter)),
      Offset(size.width + _jitter(random, maxJitter),
          size.height * 0.65 + _jitter(random, maxJitter)),
      paint,
    );
  }

  double _jitter(Random random, double max) {
    return (random.nextDouble() - 0.5) * 2 * max;
  }

  void _drawSketchLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _ResizeHandlePainter oldDelegate) {
    return color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
  }
}

/// 내부 색상 사양.
class _ColorSpec {
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final Color hintColor;
  final double strokeWidth;

  const _ColorSpec({
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.hintColor,
    required this.strokeWidth,
  });
}
