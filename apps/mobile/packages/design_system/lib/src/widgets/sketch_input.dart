import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/sketch_line_painter.dart';
import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 입력 모드 — 하나의 SketchInput에서 mode 파라미터로 전환.
enum SketchInputMode {
  /// 기본 텍스트 입력.
  defaultMode,

  /// 검색 입력 (돋보기 아이콘 + 지우기 버튼).
  search,

  /// 날짜 입력 (YYYY/MM/DD, readOnly).
  date,

  /// 시간 입력 (HH:MM AM/PM, readOnly).
  time,

  /// 날짜+시간 입력 (readOnly).
  datetime,

  /// 숫자 입력 (위/아래 chevron 버튼, min/max/step).
  number,
}

/// 손으로 그린 스케치 스타일 모양의 텍스트 입력 필드.
///
/// Frame0 스타일의 스케치 미학을 가진 TextField를 생성함.
/// [SketchPainter]를 사용하여 불규칙한 손그림 테두리와 노이즈 텍스처를 렌더링.
///
/// **기본 사용법:**
/// ```dart
/// SketchInput(
///   hint: 'Enter your name',
/// )
/// ```
///
/// **검색 모드:**
/// ```dart
/// SketchInput(
///   mode: SketchInputMode.search,
///   hint: '박스 이름 검색',
///   onChanged: (query) => search(query),
/// )
/// ```
///
/// **날짜 모드:**
/// ```dart
/// SketchInput(
///   mode: SketchInputMode.date,
///   controller: dateController,
///   onTap: () => showDatePicker(...),
/// )
/// ```
///
/// **상태:**
/// - 일반: strokeBold 테두리, 스케치 질감
/// - 포커스: strokeThick 테두리, 더 두꺼운 스케치 효과
/// - 에러: 빨간 테두리, strokeBold
/// - 비활성화: 흐릿한 색상, strokeStandard
class SketchInput extends StatefulWidget {
  /// 입력 모드 (default, search, date, time, datetime).
  final SketchInputMode mode;

  /// 입력 필드 위에 표시되는 라벨 텍스트.
  final String? label;

  /// 필드가 비어있을 때 내부에 표시되는 힌트 텍스트.
  final String? hint;

  /// 필드 아래에 표시되는 도움말 텍스트.
  final String? helperText;

  /// 필드 아래에 표시되는 에러 텍스트 (있으면 helperText 오버라이드).
  final String? errorText;

  /// 입력 필드 시작 부분에 표시되는 아이콘.
  /// mode별 기본 아이콘이 있으며, 이 값이 제공되면 기본 아이콘을 오버라이드.
  final Widget? prefixIcon;

  /// 입력 필드 끝 부분에 표시되는 아이콘.
  /// search 모드에서는 자동 지우기 버튼이 표시됨.
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

  /// 테두리 표시 여부.
  final bool showBorder;

  /// 필드 탭 시 콜백 (date/time/datetime 모드에서 picker 트리거).
  final VoidCallback? onTap;

  /// search 모드에서 지우기 버튼 표시 여부 (기본값: search 모드일 때 true).
  final bool? showClearButton;

  // ── Number 모드 전용 ──

  /// 현재 숫자 값 (number 모드 필수).
  final double? numberValue;

  /// 숫자 변경 콜백 (number 모드 필수).
  final ValueChanged<double>? onNumberChanged;

  /// 최소값.
  final double? min;

  /// 최대값.
  final double? max;

  /// 증감 단위 (기본 1.0).
  final double step;

  /// 소수점 자릿수 (기본 0).
  final int decimalPlaces;

  /// 접미사 텍스트 (예: "kg", "회").
  final String? suffix;

  const SketchInput({
    super.key,
    this.mode = SketchInputMode.defaultMode,
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
    this.showBorder = true,
    this.onTap,
    this.showClearButton,
    this.numberValue,
    this.onNumberChanged,
    this.min,
    this.max,
    this.step = 1.0,
    this.decimalPlaces = 0,
    this.suffix,
  });

  @override
  State<SketchInput> createState() => _SketchInputState();
}

class _SketchInputState extends State<SketchInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;

  // search 모드 지우기 버튼을 위한 controller 관리
  late TextEditingController _effectiveController;
  bool _isControllerInternal = false;

  // number 모드 전용 controller
  TextEditingController? _numberController;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _initController();
    _initNumberController();
  }

  void _initController() {
    if (widget.controller != null) {
      _effectiveController = widget.controller!;
      _isControllerInternal = false;
    } else {
      _effectiveController = TextEditingController();
      _isControllerInternal = true;
    }
    _effectiveController.addListener(_onTextChanged);
    _hasText = _effectiveController.text.isNotEmpty;
  }

  void _initNumberController() {
    if (widget.mode == SketchInputMode.number && widget.numberValue != null) {
      _numberController = TextEditingController(
        text: _formatNumberValue(widget.numberValue!),
      );
    }
  }

  @override
  void didUpdateWidget(covariant SketchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _effectiveController.removeListener(_onTextChanged);
      if (_isControllerInternal) {
        _effectiveController.dispose();
      }
      _initController();
    }
    // number 모드 값 동기화
    if (widget.mode == SketchInputMode.number) {
      if (_numberController == null) {
        _initNumberController();
      } else if (oldWidget.numberValue != widget.numberValue) {
        final clamped = _clampNumberValue(widget.numberValue ?? 0);
        _numberController!.text = _formatNumberValue(clamped);
      }
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChange);
    if (_isControllerInternal) {
      _effectiveController.dispose();
    }
    _numberController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  /// date/time/datetime 모드 여부.
  bool get _isPickerMode =>
      widget.mode == SketchInputMode.date ||
      widget.mode == SketchInputMode.time ||
      widget.mode == SketchInputMode.datetime;

  // ── Number 모드 헬퍼 ──

  /// 숫자를 지정된 소수점 자릿수에 맞춰 포맷팅.
  String _formatNumberValue(double value) {
    if (widget.decimalPlaces == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(widget.decimalPlaces);
  }

  /// 값을 min/max 범위로 제한.
  double _clampNumberValue(double value) {
    if (widget.min != null && value < widget.min!) return widget.min!;
    if (widget.max != null && value > widget.max!) return widget.max!;
    return value;
  }

  /// 증가 가능 여부.
  bool get _canIncrement {
    return widget.max == null ||
        (widget.numberValue ?? 0) < widget.max!;
  }

  /// 감소 가능 여부.
  bool get _canDecrement {
    return widget.min == null ||
        (widget.numberValue ?? 0) > widget.min!;
  }

  /// 증가 동작.
  void _incrementNumber() {
    final current = widget.numberValue ?? 0;
    final newValue = _clampNumberValue(current + widget.step);
    widget.onNumberChanged?.call(newValue);
  }

  /// 감소 동작.
  void _decrementNumber() {
    final current = widget.numberValue ?? 0;
    final newValue = _clampNumberValue(current - widget.step);
    widget.onNumberChanged?.call(newValue);
  }

  /// 텍스트 입력에서 숫자 파싱.
  void _onNumberTextChanged(String text) {
    if (text.isEmpty) return;
    final parsed = double.tryParse(text);
    if (parsed != null) {
      widget.onNumberChanged?.call(_clampNumberValue(parsed));
    }
  }

  @override
  Widget build(BuildContext context) {
    // number 모드는 별도 빌드
    if (widget.mode == SketchInputMode.number) {
      return _buildNumberMode(context);
    }

    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final hasError = widget.errorText != null;

    final colorSpec = _getColorSpec(
      sketchTheme,
      isFocused: _isFocused,
      hasError: hasError,
      isDisabled: !widget.enabled,
    );

    final modeDefaults = _resolveModeDefaults(colorSpec);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 (옵셔널, 항상 상단 고정)
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _isPickerMode ? widget.onTap : null,
          child: AbsorbPointer(
            absorbing: _isPickerMode,
            child: CustomPaint(
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
              child: SizedBox(
                height: _calculateHeight(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SketchDesignTokens.spacingMd,
                    vertical: SketchDesignTokens.spacingSm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 접두사 아이콘
                      if (modeDefaults.prefixIcon != null) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: colorSpec.iconColor,
                            size: 20,
                          ),
                          child: modeDefaults.prefixIcon!,
                        ),
                        const SizedBox(width: SketchDesignTokens.spacingSm),
                      ],

                      // 텍스트 필드
                      Expanded(
                        child: TextField(
                          controller: _effectiveController,
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
                          readOnly: modeDefaults.readOnly,
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
                            hintText: modeDefaults.hint,
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

                      // 접미사 아이콘
                      if (modeDefaults.suffixIcon != null) ...[
                        const SizedBox(width: SketchDesignTokens.spacingSm),
                        IconTheme(
                          data: IconThemeData(
                            color: colorSpec.iconColor,
                            size: 20,
                          ),
                          child: modeDefaults.suffixIcon!,
                        ),
                      ],
                    ],
                  ),
                ),
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
              fontFamily: SketchDesignTokens.fontFamilyHand,
              fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
              fontSize: SketchDesignTokens.fontSizeXs,
              color: hasError
                  ? SketchDesignTokens.error
                  : (sketchTheme?.textSecondaryColor ??
                      SketchDesignTokens.base600),
            ),
          ),
        ],
      ],
    );
  }

  /// Number 모드 전용 빌드 — 텍스트 + 세로 구분선 + chevron 버튼 레이아웃.
  Widget _buildNumberMode(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final hasError = widget.errorText != null;

    final colorSpec = _getColorSpec(
      sketchTheme,
      isFocused: _isFocused,
      hasError: hasError,
      isDisabled: !widget.enabled,
    );

    final roughness = sketchTheme?.roughness ?? SketchDesignTokens.roughness;
    final seed = widget.label?.hashCode ?? widget.hint?.hashCode ?? 0;
    final chevronColor = widget.enabled
        ? colorSpec.textColor
        : colorSpec.hintColor;
    final disabledChevronColor = colorSpec.hintColor.withAlpha(102);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨 (옵셔널, 항상 상단 고정)
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

        // Number Input 컨테이너
        CustomPaint(
          painter: SketchPainter(
            fillColor: colorSpec.fillColor,
            borderColor: colorSpec.borderColor,
            strokeWidth: colorSpec.strokeWidth,
            roughness: roughness,
            seed: seed,
            enableNoise: true,
            showBorder: widget.showBorder,
            borderRadius: SketchDesignTokens.irregularBorderRadius,
          ),
          child: SizedBox(
            height: 44.0,
            child: Row(
              children: [
                // 텍스트 입력 영역
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SketchDesignTokens.spacingMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _numberController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: widget.decimalPlaces > 0,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(widget.decimalPlaces > 0
                                    ? r'^-?\d*\.?\d*$'
                                    : r'^-?\d*$'),
                              ),
                            ],
                            enabled: widget.enabled,
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
                              hintText: widget.hint ?? '0',
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
                            onChanged: _onNumberTextChanged,
                          ),
                        ),
                        if (widget.suffix != null) ...[
                          const SizedBox(width: SketchDesignTokens.spacingXs),
                          Text(
                            widget.suffix!,
                            style: TextStyle(
                              fontFamily: SketchDesignTokens.fontFamilyMono,
                              fontSize: SketchDesignTokens.fontSizeSm,
                              color: colorSpec.hintColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // 세로 구분선 (스케치 스타일)
                CustomPaint(
                  size: const Size(3, 44),
                  painter: SketchLinePainter(
                    start: const Offset(1.5, 4),
                    end: const Offset(1.5, 40),
                    color: colorSpec.borderColor,
                    strokeWidth: colorSpec.strokeWidth * 0.7,
                    roughness: roughness,
                    seed: seed + 1,
                  ),
                ),

                // Chevron 버튼 영역
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      // 증가 버튼 (위)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.enabled && _canIncrement
                              ? _incrementNumber
                              : null,
                          child: Center(
                            child: CustomPaint(
                              size: const Size(14, 8),
                              painter: _ChevronPainter(
                                color: widget.enabled && _canIncrement
                                    ? chevronColor
                                    : disabledChevronColor,
                                strokeWidth: colorSpec.strokeWidth * 0.6,
                                roughness: roughness,
                                seed: seed + 2,
                                isUp: true,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 가로 구분선
                      CustomPaint(
                        size: const Size(48, 2),
                        painter: SketchLinePainter(
                          start: const Offset(4, 1),
                          end: const Offset(44, 1),
                          color: colorSpec.borderColor,
                          strokeWidth: SketchDesignTokens.strokeStandard * 0.7,
                          roughness: roughness,
                          seed: seed + 3,
                        ),
                      ),

                      // 감소 버튼 (아래)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.enabled && _canDecrement
                              ? _decrementNumber
                              : null,
                          child: Center(
                            child: CustomPaint(
                              size: const Size(14, 8),
                              painter: _ChevronPainter(
                                color: widget.enabled && _canDecrement
                                    ? chevronColor
                                    : disabledChevronColor,
                                strokeWidth: colorSpec.strokeWidth * 0.6,
                                roughness: roughness,
                                seed: seed + 4,
                                isUp: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 도움말 텍스트 또는 에러 텍스트
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText ?? widget.helperText!,
            style: TextStyle(
              fontFamily: SketchDesignTokens.fontFamilyHand,
              fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
              fontSize: SketchDesignTokens.fontSizeXs,
              color: hasError
                  ? SketchDesignTokens.error
                  : (sketchTheme?.textSecondaryColor ??
                      SketchDesignTokens.base600),
            ),
          ),
        ],
      ],
    );
  }

  double _calculateHeight() {
    if (widget.maxLines == null) {
      return 120.0;
    } else if (widget.maxLines == 1) {
      return 44.0;
    } else {
      return 44.0 + (widget.maxLines! - 1) * 20.0;
    }
  }

  /// 모드별 기본값 결정 — 사용자 제공 값이 모드 기본값을 오버라이드.
  _ModeDefaults _resolveModeDefaults(_ColorSpec colorSpec) {
    switch (widget.mode) {
      case SketchInputMode.search:
        final effectiveClear = widget.showClearButton ?? true;
        return _ModeDefaults(
          prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
          suffixIcon: widget.suffixIcon ??
              (effectiveClear && _hasText
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _effectiveController.clear();
                        widget.onChanged?.call('');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : null),
          hint: widget.hint ?? 'Search',
          readOnly: widget.readOnly,
        );

      case SketchInputMode.date:
        return _ModeDefaults(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          hint: widget.hint ?? 'YYYY/MM/DD',
          readOnly: true,
        );

      case SketchInputMode.time:
        return _ModeDefaults(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          hint: widget.hint ?? 'HH:MM AM',
          readOnly: true,
        );

      case SketchInputMode.datetime:
        return _ModeDefaults(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          hint: widget.hint ?? 'YYYY/MM/DD HH:MM',
          readOnly: true,
        );

      case SketchInputMode.defaultMode:
        return _ModeDefaults(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          hint: widget.hint,
          readOnly: widget.readOnly,
        );

      case SketchInputMode.number:
        // number 모드는 build()에서 별도 분기하므로 도달 불가.
        return const _ModeDefaults();
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
        fillColor: theme?.disabledFillColor ?? SketchDesignTokens.base100,
        borderColor: theme?.disabledBorderColor ?? SketchDesignTokens.base300,
        textColor: theme?.disabledTextColor ?? SketchDesignTokens.base500,
        hintColor: theme?.disabledTextColor ?? SketchDesignTokens.base400,
        iconColor: theme?.disabledTextColor ?? SketchDesignTokens.base400,
        strokeWidth:
            widget.strokeWidth ?? SketchDesignTokens.strokeStandard, // 2.0
      );
    }

    final effectiveTextColor = theme?.textColor ?? SketchDesignTokens.base900;
    final effectiveHintColor =
        theme?.textSecondaryColor ?? SketchDesignTokens.base500;
    final effectiveIconColor = theme?.iconColor ?? SketchDesignTokens.base600;

    if (hasError) {
      return _ColorSpec(
        fillColor: widget.fillColor ?? theme?.fillColor ?? Colors.white,
        borderColor: SketchDesignTokens.error,
        textColor: effectiveTextColor,
        hintColor: effectiveHintColor,
        iconColor: SketchDesignTokens.error,
        strokeWidth:
            widget.strokeWidth ?? SketchDesignTokens.strokeBold, // 3.0
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
        iconColor: effectiveTextColor,
        strokeWidth:
            widget.strokeWidth ?? SketchDesignTokens.strokeThick, // 4.0
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
      iconColor: effectiveIconColor,
      strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeBold, // 3.0
    );
  }
}

/// 모드별 해석된 기본값.
class _ModeDefaults {
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hint;
  final bool readOnly;

  const _ModeDefaults({
    this.prefixIcon,
    this.suffixIcon,
    this.hint,
    this.readOnly = false,
  });
}

/// 내부 색상 사양.
class _ColorSpec {
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final Color hintColor;
  final Color iconColor;
  final double strokeWidth;

  const _ColorSpec({
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.hintColor,
    required this.iconColor,
    required this.strokeWidth,
  });
}

/// 스케치 스타일 chevron(꺾쇠) 화살표 페인터.
class _ChevronPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double roughness;
  final int seed;
  final bool isUp;

  _ChevronPainter({
    required this.color,
    required this.strokeWidth,
    required this.roughness,
    required this.seed,
    required this.isUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final rng = Random(seed);
    final rx = roughness * 0.8;

    // chevron 꼭짓점 좌표
    final midX = size.width / 2;

    double leftX, leftY, tipX, tipY, rightX, rightY;

    if (isUp) {
      // ^ 모양
      leftX = 0;
      leftY = size.height;
      tipX = midX;
      tipY = 0;
      rightX = size.width;
      rightY = size.height;
    } else {
      // v 모양
      leftX = 0;
      leftY = 0;
      tipX = midX;
      tipY = size.height;
      rightX = size.width;
      rightY = 0;
    }

    // 손그림 느낌의 미세 떨림 적용
    final path = Path()
      ..moveTo(
        leftX + (rng.nextDouble() - 0.5) * rx,
        leftY + (rng.nextDouble() - 0.5) * rx,
      )
      ..lineTo(
        tipX + (rng.nextDouble() - 0.5) * rx,
        tipY + (rng.nextDouble() - 0.5) * rx,
      )
      ..lineTo(
        rightX + (rng.nextDouble() - 0.5) * rx,
        rightY + (rng.nextDouble() - 0.5) * rx,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      roughness != oldDelegate.roughness ||
      seed != oldDelegate.seed ||
      isUp != oldDelegate.isUp;
}
