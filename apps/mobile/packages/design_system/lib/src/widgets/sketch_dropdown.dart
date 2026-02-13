import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손그림 스타일 드롭다운 위젯
///
/// Frame0 스타일의 드롭다운 선택 위젯.
/// SketchPainter를 사용하여 손그림 질감의 테두리와 노이즈 텍스처를 렌더링함.
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
/// **라벨과 함께:**
/// ```dart
/// SketchDropdown<String>(
///   label: '카테고리',
///   value: selectedValue,
///   items: ['음식', '음료', '디저트'],
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

  /// 드롭다운 위에 표시되는 라벨 텍스트 (옵셔널)
  final String? label;

  /// 드롭다운 높이
  final double height;

  /// 배경 색상
  final Color? fillColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 선 두께
  final double? strokeWidth;

  /// 테두리 표시 여부.
  final bool showBorder;

  const SketchDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.itemBuilder,
    this.hint,
    this.label,
    this.height = 44.0,
    this.fillColor,
    this.borderColor,
    this.strokeWidth,
    this.showBorder = true,
  });

  @override
  State<SketchDropdown<T>> createState() => _SketchDropdownState<T>();
}

class _SketchDropdownState<T> extends State<SketchDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  OverlayEntry? _barrierEntry;
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
    final overlay = Overlay.of(context);
    overlay.insert(_barrierEntry!);
    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _barrierEntry?.remove();
    _barrierEntry = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final fullWidth = renderBox.size.width;

    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final effectiveFillColor = widget.fillColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveTextColor = sketchTheme?.textColor ?? SketchDesignTokens.base900;
    final effectiveRoughness = sketchTheme?.roughness ?? SketchDesignTokens.roughness;

    // 외부 탭 감지용 투명 barrier
    _barrierEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );

    return OverlayEntry(
      builder: (context) => Positioned(
        width: fullWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          // widget.height 사용 — label이 있어도 셀렉트박스 바로 아래에 위치
          offset: Offset(0, widget.height + 4),
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
                  seed: (widget.hint?.hashCode ?? 0) + 100,
                  showBorder: widget.showBorder,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    SketchDesignTokens.irregularBorderRadius,
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
                              ? effectiveTextColor.withAlpha(20)
                              : Colors.transparent,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: widget.itemBuilder != null
                                ? widget.itemBuilder!(item)
                                : Text(
                                    item.toString(),
                                    style: TextStyle(
                                      fontFamily: SketchDesignTokens.fontFamilyHand,
                                      fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                                      fontSize: SketchDesignTokens.fontSizeBase,
                                      color: effectiveTextColor,
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
      ),
    );
  }

  @override
  void dispose() {
    // setState 없이 overlay entry만 직접 제거 — dispose 시점에서 setState는 defunct Element 크래시 유발
    _barrierEntry?.remove();
    _barrierEntry = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final isDisabled = widget.onChanged == null;

    final effectiveFillColor = widget.fillColor ?? sketchTheme?.fillColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = sketchTheme?.roughness ?? SketchDesignTokens.roughness;
    final buildTextColor = sketchTheme?.textColor ?? SketchDesignTokens.base900;
    final buildHintColor = sketchTheme?.textSecondaryColor ?? SketchDesignTokens.base500;
    final buildIconColor = sketchTheme?.iconColor ?? SketchDesignTokens.base700;

    return Opacity(
      opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: Column(
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
                color: sketchTheme?.textColor ?? SketchDesignTokens.base900,
              ),
            ),
            const SizedBox(height: 6),
          ],

          // 셀렉트박스
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onTap: isDisabled ? null : _toggleDropdown,
              child: CustomPaint(
                painter: SketchPainter(
                  fillColor: effectiveFillColor,
                  borderColor: effectiveBorderColor,
                  strokeWidth: effectiveStrokeWidth,
                  roughness: effectiveRoughness,
                  seed: widget.label?.hashCode ?? widget.hint?.hashCode ?? 0,
                  showBorder: widget.showBorder,
                ),
                child: SizedBox(
                  height: widget.height,
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
                                      style: TextStyle(
                                        fontFamily: SketchDesignTokens.fontFamilyHand,
                                        fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                                        fontSize: SketchDesignTokens.fontSizeBase,
                                        color: buildTextColor,
                                      ),
                                    ))
                              : Text(
                                  widget.hint ?? '',
                                  style: TextStyle(
                                    fontFamily: SketchDesignTokens.fontFamilyHand,
                                    fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
                                    fontSize: SketchDesignTokens.fontSizeBase,
                                    color: buildHintColor,
                                  ),
                                ),
                        ),
                        Icon(
                          _isOpen ? Icons.expand_less : Icons.expand_more,
                          color: buildIconColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
