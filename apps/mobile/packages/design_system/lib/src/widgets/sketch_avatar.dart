import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../enums/sketch_avatar_shape.dart';
import '../enums/sketch_avatar_size.dart';
import '../theme/sketch_theme_extension.dart';
import 'sketch_image_placeholder.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final sketchTheme = SketchThemeExtension.maybeOf(context);

    // 크기별 스타일 계산
    final sizeConfig = _getSizeConfig(size);
    final effectiveStrokeWidth = strokeWidth ?? sizeConfig.borderWidth;
    final effectiveBorderColor = borderColor ??
        sketchTheme?.borderColor ??
        SketchDesignTokens.base700;

    // 아바타 컨텐츠
    Widget avatar = _buildAvatarContent(context, sizeConfig);

    // 형태에 따른 클리핑
    if (shape == SketchAvatarShape.circle) {
      avatar = ClipOval(child: avatar);
    } else {
      avatar = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: avatar,
      );
    }

    // 테두리 적용
    avatar = Container(
      width: size.size,
      height: size.size,
      decoration: BoxDecoration(
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveStrokeWidth,
        ),
        shape: shape == SketchAvatarShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: shape == SketchAvatarShape.circle
            ? null
            : BorderRadius.circular(6),
      ),
      child: avatar,
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
          return _buildPlaceholder(config);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          // 로딩 중에는 플레이스홀더 표시
          return _buildPlaceholder(config);
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
          return _buildPlaceholder(config);
        },
      );
    }

    // 3. 이니셜이 있으면 이니셜 표시
    if (initials != null && initials!.isNotEmpty) {
      return _buildInitials(context, config);
    }

    // 4. 모두 없으면 플레이스홀더
    return _buildPlaceholder(config);
  }

  /// 이니셜 렌더링
  Widget _buildInitials(BuildContext context, _SizeConfig config) {
    final effectiveBackgroundColor = backgroundColor ??
        SketchDesignTokens.accentSecondaryLight;
    final effectiveTextColor = textColor ?? Colors.white;

    return Container(
      width: size.size,
      height: size.size,
      color: effectiveBackgroundColor,
      child: Center(
        child: Text(
          initials!,
          style: TextStyle(
            fontFamily: SketchDesignTokens.fontFamilyHand,
            fontSize: config.fontSize,
            color: effectiveTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 플레이스홀더 렌더링 (X-cross 패턴)
  Widget _buildPlaceholder(_SizeConfig config) {
    return SketchImagePlaceholder(
      width: size.size,
      height: size.size,
      centerIcon: placeholderIcon ?? Icons.person_outline,
      showBorder: false, // 외부에 이미 테두리가 있음
    );
  }

  /// 크기별 스타일 설정 가져오기
  _SizeConfig _getSizeConfig(SketchAvatarSize size) {
    switch (size) {
      case SketchAvatarSize.xs:
        return const _SizeConfig(
          fontSize: 10,
          borderWidth: 1.0,
        );
      case SketchAvatarSize.sm:
        return const _SizeConfig(
          fontSize: 14,
          borderWidth: 1.5,
        );
      case SketchAvatarSize.md:
        return const _SizeConfig(
          fontSize: 18,
          borderWidth: 2.0,
        );
      case SketchAvatarSize.lg:
        return const _SizeConfig(
          fontSize: 20,
          borderWidth: 2.0,
        );
      case SketchAvatarSize.xl:
        return const _SizeConfig(
          fontSize: 28,
          borderWidth: 2.5,
        );
      case SketchAvatarSize.xxl:
        return const _SizeConfig(
          fontSize: 36,
          borderWidth: 3.0,
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

  const _SizeConfig({
    required this.fontSize,
    required this.borderWidth,
  });
}
