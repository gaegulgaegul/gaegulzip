import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 스케치 버튼의 스타일 변형.
enum SketchButtonStyle {
  /// 액센트 색상 배경의 채워진 버튼.
  primary,

  /// 밝은 배경의 버튼.
  secondary,

  /// 테두리만 있는 투명 버튼.
  outline,
}

/// 버튼 크기 변형.
enum SketchButtonSize {
  /// 작은 버튼: 32px 높이, 8px/16px 패딩.
  small,

  /// 중간 버튼: 40px 높이, 12px/24px 패딩 (기본값).
  medium,

  /// 큰 버튼: 48px 높이, 16px/32px 패딩.
  large,
}

/// 손으로 그린 모양의 스케치 스타일 버튼 widget.
///
/// Frame0 스타일의 손으로 그린 미학을 가진 버튼을 생성함.
/// 여러 스타일, 크기, 상태, 상호작용을 지원함.
///
/// **기본 사용법:**
/// ```dart
/// SketchButton(
///   text: 'Click Me',
///   onPressed: () => print('Pressed!'),
/// )
/// ```
///
/// **스타일과 크기:**
/// ```dart
/// SketchButton(
///   text: 'Primary Large',
///   style: SketchButtonStyle.primary,
///   size: SketchButtonSize.large,
///   onPressed: () {},
/// )
/// ```
///
/// **아이콘과 함께:**
/// ```dart
/// SketchButton(
///   text: 'Save',
///   icon: Icon(Icons.save),
///   onPressed: () {},
/// )
/// ```
///
/// **로딩 상태:**
/// ```dart
/// SketchButton(
///   text: 'Submit',
///   isLoading: true,
///   onPressed: () {},
/// )
/// ```
///
/// **스타일:**
/// - [SketchButtonStyle.primary]: 액센트 색상으로 채워짐
/// - [SketchButtonStyle.secondary]: 밝은 회색 배경
/// - [SketchButtonStyle.outline]: 테두리만 있는 투명
///
/// **크기:**
/// - [SketchButtonSize.small]: 32px 높이
/// - [SketchButtonSize.medium]: 40px 높이 (기본값)
/// - [SketchButtonSize.large]: 48px 높이
class SketchButton extends StatefulWidget {
  /// 버튼 텍스트 (아이콘만 사용할 경우 null 가능).
  final String? text;

  /// 아이콘 widget (텍스트와 함께 제공되면 텍스트 앞에 표시됨).
  final Widget? icon;

  /// 버튼이 눌렸을 때 콜백 (null = 비활성화).
  final VoidCallback? onPressed;

  /// 시각적 스타일 변형.
  final SketchButtonStyle style;

  /// 크기 변형.
  final SketchButtonSize size;

  /// 버튼이 로딩 상태인지 여부.
  ///
  /// true일 때 스피너를 표시하고 텍스트/아이콘을 숨김.
  final bool isLoading;

  /// 커스텀 너비 (null이면 콘텐츠에 맞춤).
  final double? width;

  /// 아이콘과 텍스트 사이 간격.
  final double iconSpacing;

  const SketchButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.style = SketchButtonStyle.primary,
    this.size = SketchButtonSize.medium,
    this.isLoading = false,
    this.width,
    this.iconSpacing = 8.0,
  }) : assert(text != null || icon != null, 'Either text or icon must be provided');

  @override
  State<SketchButton> createState() => _SketchButtonState();
}

class _SketchButtonState extends State<SketchButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    // 크기 사양 가져오기
    final sizeSpec = _getSizeSpec(widget.size);

    // 스타일에 따른 색상 사양 가져오기
    final colorSpec = _getColorSpec(widget.style, isDisabled);

    // 상태에 따른 거칠기 계산
    final roughness = _isPressed
        ? SketchDesignTokens.roughness + 0.3
        : SketchDesignTokens.roughness;

    // 눌린 상태에 따라 시드를 변경하여 다른 모양을 만듦
    final seed = _isPressed ? 1 : 0;

    return Opacity(
      opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: isDisabled ? null : (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width,
            height: sizeSpec.height,
            child: CustomPaint(
              painter: SketchPainter(
                fillColor: colorSpec.fillColor,
                borderColor: colorSpec.borderColor,
                strokeWidth: colorSpec.strokeWidth,
                roughness: roughness,
                seed: seed,
                enableNoise: widget.style != SketchButtonStyle.outline,
              ),
              child: Padding(
                padding: sizeSpec.padding,
                child: _buildContent(sizeSpec, colorSpec),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(_SizeSpec sizeSpec, _ColorSpec colorSpec) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: sizeSpec.fontSize,
          height: sizeSpec.fontSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(colorSpec.textColor),
          ),
        ),
      );
    }

    final hasIcon = widget.icon != null;
    final hasText = widget.text != null;

    if (hasIcon && hasText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              color: colorSpec.textColor,
              size: sizeSpec.fontSize,
            ),
            child: widget.icon!,
          ),
          SizedBox(width: widget.iconSpacing),
          Text(
            widget.text!,
            style: TextStyle(
              color: colorSpec.textColor,
              fontSize: sizeSpec.fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    if (hasIcon) {
      return Center(
        child: IconTheme(
          data: IconThemeData(
            color: colorSpec.textColor,
            size: sizeSpec.fontSize,
          ),
          child: widget.icon!,
        ),
      );
    }

    return Center(
      child: Text(
        widget.text!,
        style: TextStyle(
          color: colorSpec.textColor,
          fontSize: sizeSpec.fontSize,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  _SizeSpec _getSizeSpec(SketchButtonSize size) {
    switch (size) {
      case SketchButtonSize.small:
        return _SizeSpec(
          height: 32.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          fontSize: SketchDesignTokens.fontSizeSm,
        );
      case SketchButtonSize.medium:
        return _SizeSpec(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          fontSize: SketchDesignTokens.fontSizeBase,
        );
      case SketchButtonSize.large:
        return _SizeSpec(
          height: 48.0,
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          fontSize: SketchDesignTokens.fontSizeLg,
        );
    }
  }

  _ColorSpec _getColorSpec(SketchButtonStyle style, bool isDisabled) {
    if (isDisabled) {
      // 비활성화 상태: 스타일에 관계없이 흐릿한 색상 사용
      return _ColorSpec(
        fillColor: SketchDesignTokens.base200,
        borderColor: SketchDesignTokens.base300,
        textColor: SketchDesignTokens.base500,
        strokeWidth: SketchDesignTokens.strokeStandard,
      );
    }

    switch (style) {
      case SketchButtonStyle.primary:
        return _ColorSpec(
          fillColor: SketchDesignTokens.accentPrimary,
          borderColor: SketchDesignTokens.accentPrimary,
          textColor: SketchDesignTokens.white,
          strokeWidth: SketchDesignTokens.strokeStandard,
        );
      case SketchButtonStyle.secondary:
        return _ColorSpec(
          fillColor: SketchDesignTokens.base200,
          borderColor: SketchDesignTokens.base300,
          textColor: SketchDesignTokens.base900,
          strokeWidth: SketchDesignTokens.strokeStandard,
        );
      case SketchButtonStyle.outline:
        return _ColorSpec(
          fillColor: Colors.transparent,
          borderColor: SketchDesignTokens.accentPrimary,
          textColor: SketchDesignTokens.accentPrimary,
          strokeWidth: SketchDesignTokens.strokeBold,
        );
    }
  }
}

/// 내부 크기 사양.
class _SizeSpec {
  final double height;
  final EdgeInsets padding;
  final double fontSize;

  const _SizeSpec({
    required this.height,
    required this.padding,
    required this.fontSize,
  });
}

/// 내부 색상 사양.
class _ColorSpec {
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final double strokeWidth;

  const _ColorSpec({
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.strokeWidth,
  });
}
