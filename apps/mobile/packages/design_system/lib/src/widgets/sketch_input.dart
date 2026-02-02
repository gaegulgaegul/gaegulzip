import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일 모양의 텍스트 입력 필드.
///
/// Frame0 스타일의 스케치 미학을 가진 TextField를 생성함.
/// 라벨, 힌트, 도움말 텍스트, 에러 상태, 접두사/접미사 아이콘을 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchInput(
///   hint: 'Enter your name',
/// )
/// ```
///
/// **라벨과 도움말:**
/// ```dart
/// SketchInput(
///   label: 'Email',
///   hint: 'you@example.com',
///   helperText: 'We will never share your email',
/// )
/// ```
///
/// **아이콘과 함께:**
/// ```dart
/// SketchInput(
///   label: 'Password',
///   hint: 'Enter password',
///   obscureText: true,
///   prefixIcon: Icon(Icons.lock),
///   suffixIcon: IconButton(
///     icon: Icon(Icons.visibility),
///     onPressed: () => toggleVisibility(),
///   ),
/// )
/// ```
///
/// **에러 상태:**
/// ```dart
/// SketchInput(
///   label: 'Username',
///   hint: 'Enter username',
///   errorText: 'Username is required',
/// )
/// ```
///
/// **Controller와 함께:**
/// ```dart
/// final controller = TextEditingController();
/// SketchInput(
///   controller: controller,
///   hint: 'Type here',
///   onChanged: (value) => print(value),
/// )
/// ```
///
/// **다양한 입력 타입:**
/// ```dart
/// SketchInput(
///   keyboardType: TextInputType.emailAddress,
///   hint: 'Email',
/// )
/// ```
///
/// **상태:**
/// - 일반: 기본 테두리 색상
/// - 포커스: 액센트 색상 테두리, 굵은 스트로크
/// - 에러: 빨간 테두리, 굵은 스트로크, 아래 에러 메시지
/// - 비활성화: 흐릿한 색상, 상호작용 없음
class SketchInput extends StatefulWidget {
  /// 입력 필드 위에 표시되는 라벨 텍스트.
  final String? label;

  /// 필드가 비어있을 때 내부에 표시되는 힌트 텍스트.
  final String? hint;

  /// 필드 아래에 표시되는 도움말 텍스트.
  final String? helperText;

  /// 필드 아래에 표시되는 에러 텍스트 (있으면 helperText 오버라이드).
  final String? errorText;

  /// 입력 필드 시작 부분에 표시되는 아이콘.
  final Widget? prefixIcon;

  /// 입력 필드 끝 부분에 표시되는 아이콘.
  final Widget? suffixIcon;

  /// 텍스트 입력 관리를 위한 controller.
  final TextEditingController? controller;

  /// 텍스트를 숨길지 여부 (비밀번호용).
  final bool obscureText;

  /// 입력 키보드 타입.
  final TextInputType? keyboardType;

  /// 텍스트 대문자 변환 동작.
  final TextCapitalization textCapitalization;

  /// 최대 줄 수 (null = 한 줄).
  final int? maxLines;

  /// 최소 줄 수 (여러 줄 입력용).
  final int? minLines;

  /// 입력 최대 길이.
  final int? maxLength;

  /// 입력 포맷터.
  final List<TextInputFormatter>? inputFormatters;

  /// 텍스트가 변경될 때 콜백.
  final ValueChanged<String>? onChanged;

  /// 편집이 완료될 때 콜백 (Enter 키).
  final VoidCallback? onEditingComplete;

  /// 필드가 제출될 때 콜백.
  final ValueChanged<String>? onSubmitted;

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

  /// 커스텀 거칠기.
  final double? roughness;

  /// 스케치 모양을 위한 무작위 시드.
  final int seed;

  const SketchInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.style,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
  });

  @override
  State<SketchInput> createState() => _SketchInputState();
}

class _SketchInputState extends State<SketchInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final hasError = widget.errorText != null;

    // 상태에 따라 색상 결정
    final ColorSpec colorSpec = _getColorSpec(
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
              fontSize: SketchDesignTokens.fontSizeSm,
              fontWeight: FontWeight.w500,
              color: hasError ? SketchDesignTokens.error : SketchDesignTokens.base900,
            ),
          ),
          const SizedBox(height: 6),
        ],

        // 입력 필드
        SizedBox(
          height: _calculateHeight(),
          child: CustomPaint(
            painter: SketchPainter(
              fillColor: colorSpec.fillColor,
              borderColor: colorSpec.borderColor,
              strokeWidth: colorSpec.strokeWidth,
              roughness: colorSpec.roughness,
              seed: _isFocused ? widget.seed + 1 : widget.seed,
              enableNoise: false, // 입력 필드에는 노이즈 없음
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SketchDesignTokens.spacingMd,
                vertical: SketchDesignTokens.spacingSm,
              ),
              child: Row(
                children: [
                  // 접두사 아이콘
                  if (widget.prefixIcon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: colorSpec.iconColor,
                        size: 20,
                      ),
                      child: widget.prefixIcon!,
                    ),
                    const SizedBox(width: SketchDesignTokens.spacingSm),
                  ],

                  // 텍스트 필드
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      textCapitalization: widget.textCapitalization,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      maxLength: widget.maxLength,
                      inputFormatters: widget.inputFormatters,
                      onChanged: widget.onChanged,
                      onEditingComplete: widget.onEditingComplete,
                      onSubmitted: widget.onSubmitted,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      autofocus: widget.autofocus,
                      textAlign: widget.textAlign,
                      style: widget.style ??
                          TextStyle(
                            fontSize: SketchDesignTokens.fontSizeBase,
                            color: colorSpec.textColor,
                          ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: colorSpec.hintColor,
                          fontSize: SketchDesignTokens.fontSizeBase,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        counterText: '', // 문자 카운터 숨김
                      ),
                    ),
                  ),

                  // 접미사 아이콘
                  if (widget.suffixIcon != null) ...[
                    const SizedBox(width: SketchDesignTokens.spacingSm),
                    IconTheme(
                      data: IconThemeData(
                        color: colorSpec.iconColor,
                        size: 20,
                      ),
                      child: widget.suffixIcon!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // 도움말 텍스트 또는 에러 텍스트
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText ?? widget.helperText!,
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeXs,
              color: hasError ? SketchDesignTokens.error : SketchDesignTokens.base600,
            ),
          ),
        ],
      ],
    );
  }

  double _calculateHeight() {
    if (widget.maxLines == null) {
      // 여러 줄
      return 120.0; // 기본 여러 줄 높이
    } else if (widget.maxLines == 1) {
      return 44.0; // 한 줄
    } else {
      // 고정된 여러 줄
      return 44.0 + (widget.maxLines! - 1) * 20.0;
    }
  }

  ColorSpec _getColorSpec(
    SketchThemeExtension? theme, {
    required bool isFocused,
    required bool hasError,
    required bool isDisabled,
  }) {
    if (isDisabled) {
      return ColorSpec(
        fillColor: SketchDesignTokens.base100,
        borderColor: SketchDesignTokens.base300,
        textColor: SketchDesignTokens.base500,
        hintColor: SketchDesignTokens.base400,
        iconColor: SketchDesignTokens.base400,
        strokeWidth: SketchDesignTokens.strokeStandard,
        roughness: SketchDesignTokens.roughness,
      );
    }

    if (hasError) {
      return ColorSpec(
        fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
        borderColor: SketchDesignTokens.error,
        textColor: SketchDesignTokens.base900,
        hintColor: SketchDesignTokens.base500,
        iconColor: SketchDesignTokens.error,
        strokeWidth: SketchDesignTokens.strokeBold,
        roughness: SketchDesignTokens.roughness + 0.1,
      );
    }

    if (isFocused) {
      return ColorSpec(
        fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
        borderColor: widget.borderColor ?? SketchDesignTokens.accentPrimary,
        textColor: SketchDesignTokens.base900,
        hintColor: SketchDesignTokens.base500,
        iconColor: SketchDesignTokens.accentPrimary,
        strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeBold,
        roughness: widget.roughness ?? SketchDesignTokens.roughness + 0.1,
      );
    }

    // 일반 상태
    return ColorSpec(
      fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
      borderColor: widget.borderColor ?? theme?.borderColor ?? SketchDesignTokens.base300,
      textColor: SketchDesignTokens.base900,
      hintColor: SketchDesignTokens.base500,
      iconColor: SketchDesignTokens.base600,
      strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeStandard,
      roughness: widget.roughness ?? SketchDesignTokens.roughness,
    );
  }
}

/// 내부 색상 사양.
class ColorSpec {
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final Color hintColor;
  final Color iconColor;
  final double strokeWidth;
  final double roughness;

  const ColorSpec({
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.hintColor,
    required this.iconColor,
    required this.strokeWidth,
    required this.roughness,
  });
}
