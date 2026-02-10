import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sketch_icon_button.dart';
import 'sketch_input.dart';

/// 숫자만 입력할 수 있는 전용 입력 필드.
///
/// Frame0 스타일의 스케치 미학을 가진 숫자 입력 필드로,
/// 증가/감소 버튼과 소수점 지원을 제공함.
///
/// **기본 사용법:**
/// ```dart
/// double _weight = 75.0;
///
/// SketchNumberInput(
///   label: '무게',
///   value: _weight,
///   min: 0,
///   max: 300,
///   suffix: 'kg',
///   onChanged: (value) {
///     setState(() => _weight = value);
///   },
/// )
/// ```
///
/// **소수점 입력:**
/// ```dart
/// double _distance = 5.5;
///
/// SketchNumberInput(
///   label: '거리',
///   value: _distance,
///   step: 0.5,
///   decimalPlaces: 1,
///   suffix: 'km',
///   onChanged: (value) {
///     setState(() => _distance = value);
///   },
/// )
/// ```
///
/// **버튼 없이 (텍스트 입력만):**
/// ```dart
/// SketchNumberInput(
///   label: '나이',
///   value: _age,
///   showButtons: false,
///   onChanged: (value) {
///     setState(() => _age = value.toInt());
///   },
/// )
/// ```
///
/// **상태:**
/// - 증가/감소 버튼: min/max 범위 검증 자동 처리
/// - 직접 입력: 숫자 포맷터로 숫자만 입력 가능
/// - 범위 검증: 입력 시 자동 clamp 적용
class SketchNumberInput extends StatefulWidget {
  /// 라벨
  final String? label;

  /// 현재 값
  final double value;

  /// 최소값
  final double? min;

  /// 최대값
  final double? max;

  /// 증가/감소 단위
  final double step;

  /// 소수점 자릿수
  final int decimalPlaces;

  /// 값 변경 시 콜백
  final ValueChanged<double> onChanged;

  /// 증가/감소 버튼 표시 여부
  final bool showButtons;

  /// 접미사 (예: "kg", "회")
  final String? suffix;

  const SketchNumberInput({
    super.key,
    this.label,
    required this.value,
    this.min,
    this.max,
    this.step = 1.0,
    this.decimalPlaces = 0,
    required this.onChanged,
    this.showButtons = true,
    this.suffix,
  });

  @override
  State<SketchNumberInput> createState() => _SketchNumberInputState();
}

class _SketchNumberInputState extends State<SketchNumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant SketchNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 값이 변경되었거나 min/max 경계가 변경되어 clamp가 필요한 경우
    if (oldWidget.value != widget.value ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      final clamped = _clampValue(widget.value);
      _controller.text = _formatValue(clamped);
      if (clamped != widget.value) {
        // clamp된 값이 다르면 부모에게 알림
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onChanged(clamped);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 값을 지정된 소수점 자릿수에 맞춰 포맷팅
  String _formatValue(double value) {
    if (widget.decimalPlaces == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(widget.decimalPlaces);
  }

  /// 값을 min/max 범위로 제한
  double _clampValue(double value) {
    if (widget.min != null && value < widget.min!) return widget.min!;
    if (widget.max != null && value > widget.max!) return widget.max!;
    return value;
  }

  /// 증가 가능 여부
  bool get _canIncrement {
    return widget.max == null || widget.value < widget.max!;
  }

  /// 감소 가능 여부
  bool get _canDecrement {
    return widget.min == null || widget.value > widget.min!;
  }

  /// 증가 동작
  void _increment() {
    final newValue = _clampValue(widget.value + widget.step);
    widget.onChanged(newValue);
  }

  /// 감소 동작
  void _decrement() {
    final newValue = _clampValue(widget.value - widget.step);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: SketchDesignTokens.fontFamilyHand,
              fontSize: SketchDesignTokens.fontSizeSm,
              color: SketchDesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            // 감소 버튼
            if (widget.showButtons)
              SketchIconButton(
                icon: Icons.remove,
                onPressed: _canDecrement ? _decrement : null,
              ),
            if (widget.showButtons) const SizedBox(width: 8),

            // 숫자 입력 필드
            Expanded(
              child: SketchInput(
                controller: _controller,
                hint: '0',
                keyboardType: TextInputType.numberWithOptions(
                  decimal: widget.decimalPlaces > 0,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(widget.decimalPlaces > 0 ? r'^\d*\.?\d*$' : r'^\d*$'),
                  ),
                ],
                onChanged: (text) {
                  if (text.isEmpty) return;
                  final parsedValue = double.tryParse(text);
                  if (parsedValue != null) {
                    widget.onChanged(_clampValue(parsedValue));
                  }
                },
                suffixIcon: widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          widget.suffix!,
                          style: const TextStyle(
                            fontFamily: SketchDesignTokens.fontFamilyMono,
                            color: SketchDesignTokens.textTertiary,
                          ),
                        ),
                      )
                    : null,
              ),
            ),

            // 증가 버튼
            if (widget.showButtons) const SizedBox(width: 8),
            if (widget.showButtons)
              SketchIconButton(
                icon: Icons.add,
                onPressed: _canIncrement ? _increment : null,
              ),
          ],
        ),
      ],
    );
  }
}
