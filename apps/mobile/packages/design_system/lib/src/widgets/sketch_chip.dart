import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일 모양의 칩/태그 widget.
///
/// Frame0 스타일의 스케치 미학을 가진 컴팩트한 요소를 생성함.
/// 텍스트, 선택적 아이콘, 선택 상태, 닫기 버튼을 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchChip(
///   label: 'Flutter',
/// )
/// ```
///
/// **아이콘과 함께:**
/// ```dart
/// SketchChip(
///   label: 'Favorites',
///   icon: Icon(Icons.favorite, size: 16),
/// )
/// ```
///
/// **선택 가능:**
/// ```dart
/// SketchChip(
///   label: 'Option 1',
///   selected: true,
///   onSelected: (selected) => setState(() => isSelected = selected),
/// )
/// ```
///
/// **닫기 가능:**
/// ```dart
/// SketchChip(
///   label: 'Tag',
///   onDeleted: () => removeTag(),
/// )
/// ```
///
/// **모든 기능:**
/// ```dart
/// SketchChip(
///   label: 'Advanced',
///   icon: Icon(Icons.star, size: 16),
///   selected: true,
///   onSelected: (selected) {},
///   onDeleted: () {},
/// )
/// ```
///
/// **커스텀 색상:**
/// ```dart
/// SketchChip(
///   label: 'Error',
///   fillColor: SketchDesignTokens.errorLight,
///   borderColor: SketchDesignTokens.error,
///   labelColor: SketchDesignTokens.error,
/// )
/// ```
class SketchChip extends StatefulWidget {
  /// 라벨 텍스트 (필수).
  final String label;

  /// 라벨 앞에 표시되는 아이콘 (선택 사항).
  final Widget? icon;

  /// 칩이 선택되었는지 여부.
  final bool selected;

  /// 선택 상태가 변경될 때 콜백 (null = 선택 불가).
  final ValueChanged<bool>? onSelected;

  /// 닫기 버튼이 눌렸을 때 콜백 (null = 닫기 버튼 없음).
  final VoidCallback? onDeleted;

  /// 칩 배경의 채우기 색상.
  ///
  /// null이면 선택/비선택 상태에 따라 다른 색상 사용.
  final Color? fillColor;

  /// 테두리/스트로크 색상.
  ///
  /// null이면 선택/비선택 상태에 따라 다른 색상 사용.
  final Color? borderColor;

  /// 라벨 텍스트 색상.
  ///
  /// null이면 선택/비선택 상태에 따라 다른 색상 사용.
  final Color? labelColor;

  /// 아이콘 색상.
  ///
  /// null이면 labelColor 사용.
  final Color? iconColor;

  /// 테두리의 스트로크 너비.
  final double? strokeWidth;

  /// 손으로 그린 흔들림을 위한 거칠기 계수.
  final double? roughness;

  /// 재현 가능한 스케치 모양을 위한 무작위 시드.
  final int seed;

  /// 내부 패딩.
  final EdgeInsetsGeometry padding;

  /// 아이콘과 라벨 사이 간격.
  final double iconSpacing;

  /// 라벨과 닫기 버튼 사이 간격.
  final double deleteSpacing;

  const SketchChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.fillColor,
    this.borderColor,
    this.labelColor,
    this.iconColor,
    this.strokeWidth,
    this.roughness,
    this.seed = 0,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 6.0,
    ),
    this.iconSpacing = 6.0,
    this.deleteSpacing = 6.0,
  });

  @override
  State<SketchChip> createState() => _SketchChipState();
}

class _SketchChipState extends State<SketchChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final isSelectable = widget.onSelected != null;

    // 상태에 따른 색상 결정
    final colorSpec = _getColorSpec(sketchTheme);

    final roughness = _isPressed ? colorSpec.roughness + 0.2 : colorSpec.roughness;
    final seed = _isPressed ? widget.seed + 1 : widget.seed;

    final chip = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: IntrinsicWidth(
        child: CustomPaint(
          painter: SketchPainter(
            fillColor: colorSpec.fillColor,
            borderColor: colorSpec.borderColor,
            strokeWidth: colorSpec.strokeWidth,
            roughness: roughness,
            seed: seed,
            enableNoise: false,
          ),
          child: Padding(
            padding: widget.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                if (widget.icon != null) ...[
                  IconTheme(
                    data: IconThemeData(
                      color: widget.iconColor ?? colorSpec.labelColor,
                      size: 16,
                    ),
                    child: widget.icon!,
                  ),
                  SizedBox(width: widget.iconSpacing),
                ],

                // 라벨
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeSm,
                    fontWeight: FontWeight.w500,
                    color: colorSpec.labelColor,
                  ),
                ),

                // 삭제 버튼
                if (widget.onDeleted != null) ...[
                  SizedBox(width: widget.deleteSpacing),
                  GestureDetector(
                    onTap: widget.onDeleted,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: colorSpec.labelColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (isSelectable) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onSelected?.call(!widget.selected);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: chip,
      );
    }

    return chip;
  }

  _ColorSpec _getColorSpec(SketchThemeExtension? theme) {
    // 커스텀 색상이 모든 것을 오버라이드함
    if (widget.fillColor != null || widget.borderColor != null || widget.labelColor != null) {
      return _ColorSpec(
        fillColor: widget.fillColor ?? Colors.transparent,
        borderColor: widget.borderColor ?? SketchDesignTokens.base300,
        labelColor: widget.labelColor ?? SketchDesignTokens.base900,
        strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeStandard,
        roughness: widget.roughness ?? SketchDesignTokens.roughness,
      );
    }

    // 선택된 상태
    if (widget.selected) {
      return _ColorSpec(
        fillColor: SketchDesignTokens.accentPrimary,
        borderColor: SketchDesignTokens.accentPrimary,
        labelColor: Colors.white,
        strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeStandard,
        roughness: widget.roughness ?? SketchDesignTokens.roughness,
      );
    }

    // 일반 상태
    return _ColorSpec(
      fillColor: theme?.fillColor ?? SketchDesignTokens.base100,
      borderColor: theme?.borderColor ?? SketchDesignTokens.base300,
      labelColor: SketchDesignTokens.base900,
      strokeWidth: widget.strokeWidth ?? SketchDesignTokens.strokeStandard,
      roughness: widget.roughness ?? SketchDesignTokens.roughness,
    );
  }
}

/// 내부 색상 사양.
class _ColorSpec {
  final Color fillColor;
  final Color borderColor;
  final Color labelColor;
  final double strokeWidth;
  final double roughness;

  const _ColorSpec({
    required this.fillColor,
    required this.borderColor,
    required this.labelColor,
    required this.strokeWidth,
    required this.roughness,
  });
}
