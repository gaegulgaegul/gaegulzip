import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손그림 스타일 드롭다운 위젯
///
/// Frame0 스타일의 드롭다운 선택 위젯.
/// 여러 옵션 중 하나를 선택할 수 있음.
///
/// **기본 사용법:**
/// ```dart
/// SketchDropdown<String>(
///   value: selectedValue,
///   items: ['옵션 1', '옵션 2', '옵션 3'],
///   onChanged: (value) {
///     setState(() => selectedValue = value!);
///   },
/// )
/// ```
///
/// **커스텀 항목 빌더:**
/// ```dart
/// SketchDropdown<User>(
///   value: selectedUser,
///   items: users,
///   itemBuilder: (user) => Text(user.name),
///   onChanged: (user) {
///     setState(() => selectedUser = user!);
///   },
/// )
/// ```
///
/// **힌트 텍스트:**
/// ```dart
/// SketchDropdown<String>(
///   value: null,
///   hint: '옵션을 선택하세요',
///   items: ['A', 'B', 'C'],
///   onChanged: (value) {},
/// )
/// ```
///
/// **비활성화:**
/// ```dart
/// SketchDropdown<String>(
///   value: 'A',
///   items: ['A', 'B', 'C'],
///   onChanged: null, // null이면 비활성화
/// )
/// ```
class SketchDropdown<T> extends StatefulWidget {
  /// 현재 선택된 값
  final T? value;

  /// 선택 가능한 항목 목록
  final List<T> items;

  /// 값 변경 콜백 (null이면 비활성화)
  final ValueChanged<T?>? onChanged;

  /// 항목을 위젯으로 변환하는 빌더 (null이면 toString() 사용)
  final Widget Function(T item)? itemBuilder;

  /// 값이 null일 때 표시할 힌트
  final String? hint;

  /// 드롭다운 높이
  final double height;

  /// 배경 색상
  final Color? fillColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 선 두께
  final double? strokeWidth;

  /// 거칠기 계수
  final double? roughness;

  /// 랜덤 시드
  final int seed;

  const SketchDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.itemBuilder,
    this.hint,
    this.height = 44.0,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
  });

  @override
  State<SketchDropdown<T>> createState() => _SketchDropdownState<T>();
}

class _SketchDropdownState<T> extends State<SketchDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (widget.onChanged == null) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final effectiveFillColor = widget.fillColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base300;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: CustomPaint(
                painter: SketchPainter(
                  fillColor: effectiveFillColor,
                  borderColor: effectiveBorderColor,
                  strokeWidth: effectiveStrokeWidth,
                  roughness: effectiveRoughness,
                  seed: widget.seed + 1,
                  enableNoise: false,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = item == widget.value;

                    return InkWell(
                      onTap: () {
                        widget.onChanged?.call(item);
                        _closeDropdown();
                      },
                      child: Container(
                        height: widget.height,
                        padding: const EdgeInsets.symmetric(
                          horizontal: SketchDesignTokens.spacingMd,
                        ),
                        color: isSelected
                            ? SketchDesignTokens.accentPrimary.withOpacity(0.1)
                            : Colors.transparent,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: widget.itemBuilder != null
                              ? widget.itemBuilder!(item)
                              : Text(
                                  item.toString(),
                                  style: TextStyle(
                                    fontSize: SketchDesignTokens.fontSizeBase,
                                    color: isSelected
                                        ? SketchDesignTokens.accentPrimary
                                        : SketchDesignTokens.base900,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final isDisabled = widget.onChanged == null;

    final effectiveFillColor = widget.fillColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base300;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;

    return Opacity(
      opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: isDisabled ? null : _toggleDropdown,
          child: SizedBox(
            height: widget.height,
            child: CustomPaint(
              painter: SketchPainter(
                fillColor: effectiveFillColor,
                borderColor: effectiveBorderColor,
                strokeWidth: effectiveStrokeWidth,
                roughness: effectiveRoughness,
                seed: widget.seed,
                enableNoise: false,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SketchDesignTokens.spacingMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: widget.value != null
                          ? (widget.itemBuilder != null
                              ? widget.itemBuilder!(widget.value as T)
                              : Text(
                                  widget.value.toString(),
                                  style: const TextStyle(
                                    fontSize: SketchDesignTokens.fontSizeBase,
                                    color: SketchDesignTokens.base900,
                                  ),
                                ))
                          : Text(
                              widget.hint ?? '',
                              style: const TextStyle(
                                fontSize: SketchDesignTokens.fontSizeBase,
                                color: SketchDesignTokens.base500,
                              ),
                            ),
                    ),
                    Icon(
                      _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: SketchDesignTokens.base700,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
