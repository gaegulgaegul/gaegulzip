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
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _SketchModalDialog(
        title: title,
        child: child,
        actions: actions,
        showCloseButton: showCloseButton,
        width: width,
        height: height,
        fillColor: fillColor,
        borderColor: borderColor,
        strokeWidth: strokeWidth,
        roughness: roughness,
        seed: seed,
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
    final effectiveBorderColor = widget.borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base300;
    final effectiveStrokeWidth = widget.strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
    final effectiveRoughness = widget.roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;

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
            child: CustomPaint(
              painter: SketchPainter(
                fillColor: effectiveFillColor,
                borderColor: effectiveBorderColor,
                strokeWidth: effectiveStrokeWidth,
                roughness: effectiveRoughness,
                seed: widget.seed,
                enableNoise: true,
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // 제목
        if (widget.title != null)
          Expanded(
            child: Text(
              widget.title!,
              style: const TextStyle(
                fontSize: SketchDesignTokens.fontSizeLg,
                fontWeight: FontWeight.w600,
                color: SketchDesignTokens.base900,
              ),
            ),
          ),

        // 닫기 버튼
        if (widget.showCloseButton)
          _SketchCloseButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: SketchDesignTokens.spacingSm,
      runSpacing: SketchDesignTokens.spacingSm,
      alignment: WrapAlignment.end,
      children: widget.actions!,
    );
  }
}

/// 스케치 스타일 닫기 버튼 (X 아이콘).
class _SketchCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SketchCloseButton({
    required this.onPressed,
  });

  @override
  State<_SketchCloseButton> createState() => _SketchCloseButtonState();
}

class _SketchCloseButtonState extends State<_SketchCloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
          child: CustomPaint(
            painter: SketchPainter(
              fillColor: _isPressed ? SketchDesignTokens.base200 : Colors.transparent,
              borderColor: SketchDesignTokens.base400,
              strokeWidth: SketchDesignTokens.strokeStandard,
              roughness: SketchDesignTokens.roughness,
              seed: _isPressed ? 1 : 0,
              enableNoise: false,
            ),
            child: const Center(
              child: Icon(
                Icons.close,
                size: 18,
                color: SketchDesignTokens.base700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
