import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../enums/snackbar_type.dart';
import '../painters/sketch_painter.dart';
import '../painters/sketch_snackbar_icon_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// Frame0 스케치 스타일의 Snackbar 위젯.
///
/// 4가지 의미론적 타입(success, info, warning, error)에 따라
/// 배경색과 아이콘이 자동으로 변경됨.
/// 모든 색상은 [SketchThemeExtension]에서 관리.
///
/// **직접 사용:**
/// ```dart
/// SketchSnackbar(
///   message: '저장되었습니다!',
///   type: SnackbarType.success,
/// )
/// ```
///
/// **편의 함수 사용 (권장):**
/// ```dart
/// showSketchSnackbar(
///   context,
///   message: '저장되었습니다!',
///   type: SnackbarType.success,
/// );
/// ```
class SketchSnackbar extends StatelessWidget {
  /// Snackbar 메시지 텍스트
  final String message;

  /// Snackbar 타입 (success, info, warning, error)
  final SnackbarType type;

  const SketchSnackbar({
    required this.message,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final borderColor =
        sketchTheme?.borderColor ?? SketchDesignTokens.base900;
    final roughness = sketchTheme?.roughness ?? SketchDesignTokens.roughness;
    final bowing = sketchTheme?.bowing ?? 0.5;
    final textColor = sketchTheme?.textColor ?? SketchDesignTokens.base900;
    final bgColor = _getBgColor(sketchTheme);

    return Semantics(
      label: '${_getTypeLabel(type)}: $message',
      liveRegion: true,
      child: CustomPaint(
        painter: SketchPainter(
          fillColor: bgColor,
          borderColor: borderColor,
          strokeWidth: SketchDesignTokens.strokeBold,
          roughness: roughness,
          bowing: bowing,
          borderRadius: 16.0,
          enableNoise: true,
          showBorder: true,
          seed: type.index,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 스케치 아이콘
              CustomPaint(
                painter: SketchSnackbarIconPainter(
                  type: type,
                  iconColor: borderColor,
                  size: 32.0,
                  strokeWidth: 2.0,
                  roughness: roughness,
                  seed: type.index,
                ),
                size: const Size(32, 32),
              ),
              const SizedBox(width: 12),
              // 메시지 텍스트
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: SketchDesignTokens.fontFamilyHand,
                    fontFamilyFallback:
                        SketchDesignTokens.fontFamilyHandFallback,
                    fontSize: 14.0,
                    color: textColor,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 타입별 접근성 라벨 (스크린 리더용)
  String _getTypeLabel(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return '성공';
      case SnackbarType.info:
        return '정보';
      case SnackbarType.warning:
        return '경고';
      case SnackbarType.error:
        return '오류';
    }
  }

  /// 타입별 배경색 조회 (null-safe 폴백 적용)
  Color _getBgColor(SketchThemeExtension? theme) {
    switch (type) {
      case SnackbarType.success:
        return theme?.successSnackbarBgColor ?? const Color(0xFFD4EDDA);
      case SnackbarType.info:
        return theme?.infoSnackbarBgColor ?? const Color(0xFFD6EEFF);
      case SnackbarType.warning:
        return theme?.warningSnackbarBgColor ?? const Color(0xFFFFF9D6);
      case SnackbarType.error:
        return theme?.errorSnackbarBgColor ?? const Color(0xFFFFE0E0);
    }
  }
}

/// SketchSnackbar를 표시하는 편의 함수.
///
/// [ScaffoldMessenger]를 사용하여 floating SnackBar를 표시함.
/// 호출하는 위치에 [Scaffold]가 존재해야 함.
///
/// **사용법:**
/// ```dart
/// showSketchSnackbar(
///   context,
///   message: '작업이 완료되었습니다!',
///   type: SnackbarType.success,
/// );
/// ```
void showSketchSnackbar(
  BuildContext context, {
  required String message,
  required SnackbarType type,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: SketchSnackbar(
        message: message,
        type: type,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      margin: const EdgeInsets.all(16.0),
      padding: EdgeInsets.zero,
    ),
  );
}
