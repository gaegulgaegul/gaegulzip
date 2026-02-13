import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../enums/sketch_avatar_shape.dart';
import '../enums/sketch_avatar_size.dart';
import '../painters/sketch_circle_painter.dart';
import '../painters/sketch_painter.dart';
import '../theme/sketch_theme_extension.dart';

/// 손으로 그린 스케치 스타일의 아바타 위젯
///
/// 사용자 프로필 이미지를 표시하는 아바타 위젯. 이미지 URL, 이니셜,
/// 플레이스홀더를 지원함. Frame0 스타일의 스케치 미학을 적용.
///
/// **이미지 URL 사용:**
/// ```dart
/// SketchAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   size: SketchAvatarSize.md,
/// )
/// ```
///
/// **이니셜 표시 (이미지 없음):**
/// ```dart
/// SketchAvatar(
///   initials: 'AS',
///   backgroundColor: SketchDesignTokens.accentPrimary,
///   size: SketchAvatarSize.lg,
/// )
/// ```
///
/// **플레이스홀더 아이콘:**
/// ```dart
/// SketchAvatar(
///   placeholderIcon: Icons.person,
///   size: SketchAvatarSize.sm,
/// )
/// ```
///
/// **사각형 아바타 (탭 가능):**
/// ```dart
/// SketchAvatar(
///   imageUrl: userImageUrl,
///   shape: SketchAvatarShape.roundedSquare,
///   onTap: () => navigateToProfile(),
/// )
/// ```
///
/// **리스트 아이템:**
/// ```dart
/// ListTile(
///   leading: SketchAvatar(
///     imageUrl: user.avatarUrl,
///     initials: user.initials,
///     size: SketchAvatarSize.md,
///   ),
///   title: Text(user.name),
/// )
/// ```
class SketchAvatar extends StatelessWidget {
  /// 이미지 URL (network image)
  final String? imageUrl;

  /// 로컬 이미지 (asset)
  final String? assetPath;

  /// 이니셜 (이미지 없을 때 표시)
  final String? initials;

  /// 플레이스홀더 아이콘
  final IconData? placeholderIcon;

  /// 아바타 크기
  final SketchAvatarSize size;

  /// 아바타 형태
  final SketchAvatarShape shape;

  /// 배경 색상
  final Color? backgroundColor;

  /// 텍스트 색상 (이니셜)
  final Color? textColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 테두리 두께
  final double? strokeWidth;

  /// 탭 콜백 (선택)
  final VoidCallback? onTap;

  /// 테두리 표시 여부.
  final bool showBorder;

  /// 아이콘 색상 (플레이스홀더 아이콘).
  final Color? iconColor;

  const SketchAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.initials,
    this.placeholderIcon,
    this.size = SketchAvatarSize.md,
    this.shape = SketchAvatarShape.circle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.strokeWidth,
    this.onTap,
    this.showBorder = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    // 크기별 스타일 계산
    final sizeConfig = _getSizeConfig(size);
    final effectiveStrokeWidth = strokeWidth ?? sizeConfig.borderWidth;
    final effectiveBorderColor = borderColor ??
        sketchTheme?.borderColor ??
        SketchDesignTokens.base900;

    // seed 생성
    final seed = _generateSeed();

    // 아바타 컨텐츠
    Widget avatar = Stack(
      children: [
        // 스케치 테두리 (showBorder가 true일 때만)
        if (showBorder)
          CustomPaint(
            painter: shape == SketchAvatarShape.circle
                ? SketchCirclePainter(
                    fillColor: Colors.transparent,
                    borderColor: effectiveBorderColor,
                    strokeWidth: effectiveStrokeWidth,
                    roughness: 0.8,
                    seed: seed,
                    segments: 16,
                    enableNoise: false,
                  )
                : SketchPainter(
                    fillColor: Colors.transparent,
                    borderColor: effectiveBorderColor,
                    strokeWidth: effectiveStrokeWidth,
                    roughness: 0.8,
                    bowing: 0.5,
                    seed: seed,
                    enableNoise: false,
                    showBorder: true,
                    borderRadius: 6.0,
                  ),
            child: SizedBox(
              width: size.size,
              height: size.size,
            ),
          ),
        // 클리핑된 컨텐츠
        _buildClippedContent(context, sizeConfig, seed),
      ],
    );

    // 탭 가능하면 GestureDetector로 감싸기
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  /// 스케치 경로로 클리핑된 컨텐츠 빌드
  Widget _buildClippedContent(BuildContext context, _SizeConfig config, int seed) {
    final clippingPath = shape == SketchAvatarShape.circle
        ? SketchCirclePainter.createClipPath(
            size: Size(size.size, size.size),
            roughness: 0.8,
            seed: seed,
            segments: 16,
            strokeWidth: strokeWidth ?? config.borderWidth,
          )
        : SketchPainter.createClipPath(
            size: Size(size.size, size.size),
            roughness: 0.8,
            seed: seed,
            borderRadius: 6.0,
            strokeWidth: strokeWidth ?? config.borderWidth,
          );

    return ClipPath(
      clipper: _SketchClipper(clippingPath, seed: seed),
      child: _buildAvatarContent(context, config),
    );
  }

  /// 이미지 URL 또는 이니셜 기반 일관된 seed 생성.
  int _generateSeed() {
    // 1. 이미지 URL이 있으면 URL hashCode 사용
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!.hashCode.abs() % 10000;
    }

    // 2. Asset 경로가 있으면 경로 hashCode 사용
    if (assetPath != null && assetPath!.isNotEmpty) {
      return assetPath!.hashCode.abs() % 10000;
    }

    // 3. 이니셜이 있으면 이니셜 hashCode 사용
    if (initials != null && initials!.isNotEmpty) {
      return initials!.hashCode.abs() % 10000;
    }

    // 4. 플레이스홀더는 항상 동일한 seed (0)
    return 0;
  }

  /// 아바타 컨텐츠 빌드 (우선순위: 이미지 > 이니셜 > 플레이스홀더)
  Widget _buildAvatarContent(BuildContext context, _SizeConfig config) {
    // 1. 이미지 URL이 있으면 네트워크 이미지
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size.size,
        height: size.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 이미지 로딩 실패 시 플레이스홀더
          return _buildPlaceholder(context, config);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          // 로딩 중에는 플레이스홀더 표시
          return _buildPlaceholder(context, config);
        },
      );
    }

    // 2. Asset 이미지
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        width: size.size,
        height: size.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context, config);
        },
      );
    }

    // 3. 이니셜이 있으면 이니셜 표시
    if (initials != null && initials!.isNotEmpty) {
      return _buildInitials(context, config);
    }

    // 4. 모두 없으면 플레이스홀더
    return _buildPlaceholder(context, config);
  }

  /// 이니셜 렌더링
  Widget _buildInitials(BuildContext context, _SizeConfig config) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final effectiveBackgroundColor = backgroundColor ??
        sketchTheme?.fillColor ??
        SketchDesignTokens.accentSecondaryLight;
    final effectiveTextColor = textColor ??
        sketchTheme?.textColor ??
        Colors.white;

    return Container(
      width: size.size,
      height: size.size,
      color: effectiveBackgroundColor,
      child: Center(
        child: Text(
          initials!,
          style: TextStyle(
            fontFamily: SketchDesignTokens.fontFamilyHand,
            fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
            fontSize: config.fontSize,
            color: effectiveTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 플레이스홀더 렌더링 (사람 아이콘)
  Widget _buildPlaceholder(BuildContext context, _SizeConfig config) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);
    final effectiveBackgroundColor = backgroundColor ??
        sketchTheme?.fillColor ??
        SketchDesignTokens.base100;
    final effectiveIconColor = iconColor ??
        sketchTheme?.iconColor ??
        SketchDesignTokens.base600;

    return Container(
      width: size.size,
      height: size.size,
      color: effectiveBackgroundColor,
      child: Center(
        child: Icon(
          placeholderIcon ?? Icons.person,
          size: config.iconSize,
          color: effectiveIconColor,
        ),
      ),
    );
  }

  /// 크기별 스타일 설정 가져오기
  _SizeConfig _getSizeConfig(SketchAvatarSize size) {
    switch (size) {
      case SketchAvatarSize.xs: // 24px
        return const _SizeConfig(
          fontSize: 10,
          borderWidth: 1.5,
          iconSize: 9.6, // 24 * 0.4
        );
      case SketchAvatarSize.sm: // 32px
        return const _SizeConfig(
          fontSize: 14,
          borderWidth: 2.0,
          iconSize: 12.8, // 32 * 0.4
        );
      case SketchAvatarSize.md: // 40px
        return const _SizeConfig(
          fontSize: 18,
          borderWidth: 2.5,
          iconSize: 16, // 40 * 0.4
        );
      case SketchAvatarSize.lg: // 56px
        return const _SizeConfig(
          fontSize: 20,
          borderWidth: 2.5,
          iconSize: 22.4, // 56 * 0.4
        );
      case SketchAvatarSize.xl: // 80px
        return const _SizeConfig(
          fontSize: 28,
          borderWidth: 3.0,
          iconSize: 32, // 80 * 0.4
        );
      case SketchAvatarSize.xxl: // 120px
        return const _SizeConfig(
          fontSize: 36,
          borderWidth: 3.5,
          iconSize: 48, // 120 * 0.4
        );
    }
  }

  /// 이니셜 자동 생성 헬퍼 (static)
  ///
  /// 이름에서 이니셜을 자동으로 추출함.
  /// - 공백으로 구분된 2개 이상의 단어: 첫 단어 + 두번째 단어의 첫 글자
  /// - 1개 단어: 처음 2글자
  ///
  /// ```dart
  /// SketchAvatar.getInitials('John Doe')    // 'JD'
  /// SketchAvatar.getInitials('Alice')       // 'AL'
  /// SketchAvatar.getInitials('김철수 박사')  // '김박'
  /// ```
  static String getInitials(String? name) {
    if (name == null || name.isEmpty) return '';

    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      // 이름 + 성 첫 글자
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      // 첫 2글자
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
  }
}

/// 크기별 스타일 설정
class _SizeConfig {
  final double fontSize;
  final double borderWidth;
  final double iconSize;

  const _SizeConfig({
    required this.fontSize,
    required this.borderWidth,
    required this.iconSize,
  });
}

/// ClipPath용 CustomClipper.
/// seed 비교를 통해 이미지/이니셜 변경 시 클리핑 경로를 갱신한다.
class _SketchClipper extends CustomClipper<Path> {
  final Path path;
  final int seed;

  _SketchClipper(this.path, {required this.seed});

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _SketchClipper oldClipper) =>
      seed != oldClipper.seed;
}
