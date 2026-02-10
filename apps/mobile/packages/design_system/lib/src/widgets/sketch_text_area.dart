import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일 모양의 여러 줄 텍스트 입력 필드.
///
/// Frame0 스타일의 스케치 미학을 가진 여러 줄 TextField를 생성함.
/// 라벨, 힌트, 도움말 텍스트, 에러 상태, 글자 수 제한 및 카운터를 지원함.
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
///   onChanged: (text) {
///     print('현재 길이: ${text.length}');
///   },
/// )
/// ```
///
/// **에러 상태:**
/// ```dart
/// SketchTextArea(
///   label: '질문',
///   hint: '질문 내용',
///   errorText: '최소 20자 이상 입력하세요',
///   maxLength: 1000,
///   showCounter: true,
/// )
/// ```
///
/// **Controller와 함께:**
/// ```dart
/// final controller = TextEditingController();
/// SketchTextArea(
///   controller: controller,
///   hint: 'Type here',
///   minLines: 5,
///   maxLines: 10,
/// )
/// ```
///
/// **상태:**
/// - 일반: 기본 테두리 색상
/// - 포커스: 굵은 검정 테두리
/// - 에러: 빨간 테두리, 굵은 스트로크, 아래 에러 메시지
/// - 비활성화: 흐릿한 색상, 상호작용 없음
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
      _effectiveController = widget.controller ?? _effectiveController;
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
    // 카운터 업데이트를 위한 리빌드
    if (widget.showCounter) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final hasError = widget.errorText != null;

    // 상태에 따라 색상 결정
    final _ColorSpec colorSpec = _getColorSpec(
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
        Container(
          decoration: BoxDecoration(
            color: colorSpec.fillColor,
            border: Border.all(
              color: colorSpec.borderColor,
              width: colorSpec.strokeWidth,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
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
              counterText: '', // 기본 카운터 숨김 (커스텀 카운터 사용)
            ),
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
              fontSize: SketchDesignTokens.fontSizeXs,
              color: SketchDesignTokens.error,
            ),
          ),
        ],
      ],
    );
  }

  /// 글자 수 카운터 위젯 빌드
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
            color: _getCounterColor(currentLength),
          ),
        ),
      ),
    );
  }

  /// 글자 수에 따른 카운터 색상 결정
  Color _getCounterColor(int currentLength) {
    if (widget.maxLength == null) {
      return SketchDesignTokens.textTertiary;
    }

    final ratio = currentLength / widget.maxLength!;
    if (ratio >= 1.0) {
      return SketchDesignTokens.error;
    } else if (ratio >= 0.9) {
      return SketchDesignTokens.warning;
    } else {
      return SketchDesignTokens.textTertiary;
    }
  }

  _ColorSpec _getColorSpec(
    SketchThemeExtension? theme, {
    required bool isFocused,
    required bool hasError,
    required bool isDisabled,
  }) {
    if (isDisabled) {
      return _ColorSpec(
        fillColor: SketchDesignTokens.base100,
        borderColor: SketchDesignTokens.base300,
        textColor: SketchDesignTokens.base500,
        hintColor: SketchDesignTokens.base400,
        strokeWidth: SketchDesignTokens.strokeStandard,
      );
    }

    if (hasError) {
      return _ColorSpec(
        fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
        borderColor: SketchDesignTokens.error,
        textColor: SketchDesignTokens.base900,
        hintColor: SketchDesignTokens.base500,
        strokeWidth: SketchDesignTokens.strokeBold,
      );
    }

    if (isFocused) {
      // Frame0 스타일: 포커스 시 굵은 검정 테두리
      return _ColorSpec(
        fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
        borderColor: widget.borderColor ?? SketchDesignTokens.black,
        textColor: SketchDesignTokens.base900,
        hintColor: SketchDesignTokens.base500,
        strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeBold,
      );
    }

    // 일반 상태 — Frame0 스타일: 어두운 테두리
    return _ColorSpec(
      fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
      borderColor: widget.borderColor ?? theme?.borderColor ?? SketchDesignTokens.base900,
      textColor: SketchDesignTokens.base900,
      hintColor: SketchDesignTokens.base500,
      strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeStandard,
    );
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
