import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../enums/social_login_platform.dart';
import '../enums/apple_sign_in_style.dart';

/// 소셜 로그인 버튼 위젯
///
/// 카카오, 네이버, 애플, 구글의 공식 디자인 가이드라인을 준수합니다.
class SocialLoginButton extends StatelessWidget {
  /// 소셜 로그인 플랫폼
  final SocialLoginPlatform platform;

  /// 버튼 크기
  final SocialLoginButtonSize size;

  /// 애플 버튼 스타일 (애플 전용)
  final AppleSignInStyle appleStyle;

  /// 로딩 상태
  final bool isLoading;

  /// 버튼 텍스트 (null이면 플랫폼별 기본값)
  final String? text;

  /// 클릭 이벤트
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.platform,
    this.size = SocialLoginButtonSize.medium,
    this.appleStyle = AppleSignInStyle.dark,
    this.isLoading = false,
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _getPlatformSpec();
    final sizeSpec = _getSizeSpec();

    return SizedBox(
      width: double.infinity,
      height: sizeSpec.height,
      child: Material(
        color: spec.backgroundColor,
        borderRadius: BorderRadius.circular(spec.borderRadius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(spec.borderRadius),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: spec.borderColor,
                width: spec.borderWidth,
              ),
              borderRadius: BorderRadius.circular(spec.borderRadius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: sizeSpec.horizontalPadding,
              vertical: sizeSpec.verticalPadding,
            ),
            child: isLoading ? _buildLoading(spec) : _buildContent(spec, sizeSpec),
          ),
        ),
      ),
    );
  }

  /// 로딩 인디케이터
  Widget _buildLoading(_PlatformSpec spec) {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(spec.textColor),
        ),
      ),
    );
  }

  /// 버튼 내용 (로고 + 텍스트)
  Widget _buildContent(_PlatformSpec spec, _SizeSpec sizeSpec) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 로고
        SvgPicture.asset(
          spec.logoPath,
          width: sizeSpec.logoSize,
          height: sizeSpec.logoSize,
          package: 'design_system',
          colorFilter: spec.logoColorFilter,
        ),

        const SizedBox(width: 12),

        // 텍스트
        Text(
          text ?? spec.defaultText,
          style: TextStyle(
            fontSize: sizeSpec.fontSize,
            fontWeight: FontWeight.w500,
            color: spec.textColor,
          ),
        ),
      ],
    );
  }

  /// 플랫폼별 스펙 반환
  _PlatformSpec _getPlatformSpec() {
    switch (platform) {
      case SocialLoginPlatform.kakao:
        return _PlatformSpec(
          backgroundColor: const Color(0xFFFEE500), // 카카오 옐로우
          borderColor: const Color(0xFFFEE500),
          borderWidth: 0, // 테두리 없음
          textColor: const Color(0xFF000000),
          logoPath: 'assets/social_login/kakao_symbol.svg',
          logoColorFilter: null,
          defaultText: '카카오 계정으로 로그인',
          borderRadius: 12.0, // 카카오 공식 가이드라인
        );

      case SocialLoginPlatform.naver:
        return _PlatformSpec(
          backgroundColor: const Color(0xFF03C75A), // 네이버 그린
          borderColor: const Color(0xFF03C75A),
          borderWidth: 0,
          textColor: const Color(0xFFFFFFFF),
          logoPath: 'assets/social_login/naver_logo.svg',
          logoColorFilter: null,
          defaultText: '네이버 계정으로 로그인',
          borderRadius: 8.0, // 네이버 권장
        );

      case SocialLoginPlatform.apple:
        return appleStyle == AppleSignInStyle.dark
            ? _PlatformSpec(
                backgroundColor: const Color(0xFF000000),
                borderColor: const Color(0xFF000000),
                borderWidth: 0,
                textColor: const Color(0xFFFFFFFF),
                logoPath: 'assets/social_login/apple_logo.svg',
                logoColorFilter: const ColorFilter.mode(
                  Color(0xFFFFFFFF),
                  BlendMode.srcIn,
                ),
                defaultText: 'Apple로 로그인',
                borderRadius: 6.0, // Apple HIG 권장
              )
            : _PlatformSpec(
                backgroundColor: const Color(0xFFFFFFFF),
                borderColor: const Color(0xFF000000),
                borderWidth: 1.0,
                textColor: const Color(0xFF000000),
                logoPath: 'assets/social_login/apple_logo.svg',
                logoColorFilter: const ColorFilter.mode(
                  Color(0xFF000000),
                  BlendMode.srcIn,
                ),
                defaultText: 'Apple로 로그인',
                borderRadius: 6.0,
              );

      case SocialLoginPlatform.google:
        return _PlatformSpec(
          backgroundColor: const Color(0xFFFFFFFF),
          borderColor: const Color(0xFFDCDCDC), // 밝은 회색
          borderWidth: 1.0,
          textColor: const Color(0xFF000000),
          logoPath: 'assets/social_login/google_logo.svg',
          logoColorFilter: null,
          defaultText: 'Google 계정으로 로그인',
          borderRadius: 4.0, // Google 권장
        );
    }
  }

  /// 크기별 스펙 반환
  _SizeSpec _getSizeSpec() {
    switch (size) {
      case SocialLoginButtonSize.small:
        return _SizeSpec(
          height: 40,
          horizontalPadding: 16,
          verticalPadding: 8,
          fontSize: 13,
          logoSize: 18,
        );

      case SocialLoginButtonSize.medium:
        return _SizeSpec(
          height: 48,
          horizontalPadding: 20,
          verticalPadding: 10,
          fontSize: 15,
          logoSize: 20,
        );

      case SocialLoginButtonSize.large:
        return _SizeSpec(
          height: 56,
          horizontalPadding: 24,
          verticalPadding: 12,
          fontSize: 17,
          logoSize: 24,
        );
    }
  }
}

/// 플랫폼별 스타일 스펙
class _PlatformSpec {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color textColor;
  final String logoPath;
  final ColorFilter? logoColorFilter;
  final String defaultText;
  final double borderRadius;

  _PlatformSpec({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.textColor,
    required this.logoPath,
    required this.logoColorFilter,
    required this.defaultText,
    required this.borderRadius,
  });
}

/// 크기별 스펙
class _SizeSpec {
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double logoSize;

  _SizeSpec({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.logoSize,
  });
}
