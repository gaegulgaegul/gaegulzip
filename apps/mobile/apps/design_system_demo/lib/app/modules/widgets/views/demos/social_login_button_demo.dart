import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// SocialLoginButton 데모
///
/// platform, size, appleStyle 속성을 실시간으로 조절할 수 있습니다.
class SocialLoginButtonDemo extends StatefulWidget {
  const SocialLoginButtonDemo({super.key});

  @override
  State<SocialLoginButtonDemo> createState() => _SocialLoginButtonDemoState();
}

class _SocialLoginButtonDemoState extends State<SocialLoginButtonDemo> {
  // 조절 가능한 속성들
  SocialLoginPlatform _platform = SocialLoginPlatform.kakao;
  SocialLoginButtonSize _size = SocialLoginButtonSize.medium;
  AppleSignInStyle _appleStyle = AppleSignInStyle.dark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SketchDesignTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPreviewSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildControlsSection(),
          const SizedBox(height: SketchDesignTokens.spacing2Xl),
          _buildGallerySection(),
        ],
      ),
    );
  }

  /// 실시간 프리뷰 섹션
  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '실시간 프리뷰',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),
        SocialLoginButton(
          platform: _platform,
          size: _size,
          appleStyle: _appleStyle,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${_platform.name} 로그인 버튼 클릭됨!')),
            );
          },
        ),
      ],
    );
  }

  /// 속성 조절 패널
  Widget _buildControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '속성 조절',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Platform 선택
        const Text('Platform', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Kakao',
              selected: _platform == SocialLoginPlatform.kakao,
              onSelected: (selected) {
                if (selected) setState(() => _platform = SocialLoginPlatform.kakao);
              },
            ),
            SketchChip(
              label: 'Naver',
              selected: _platform == SocialLoginPlatform.naver,
              onSelected: (selected) {
                if (selected) setState(() => _platform = SocialLoginPlatform.naver);
              },
            ),
            SketchChip(
              label: 'Apple',
              selected: _platform == SocialLoginPlatform.apple,
              onSelected: (selected) {
                if (selected) setState(() => _platform = SocialLoginPlatform.apple);
              },
            ),
            SketchChip(
              label: 'Google',
              selected: _platform == SocialLoginPlatform.google,
              onSelected: (selected) {
                if (selected) setState(() => _platform = SocialLoginPlatform.google);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Size 선택
        const Text('Size', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        Wrap(
          spacing: SketchDesignTokens.spacingSm,
          children: [
            SketchChip(
              label: 'Small',
              selected: _size == SocialLoginButtonSize.small,
              onSelected: (selected) {
                if (selected) setState(() => _size = SocialLoginButtonSize.small);
              },
            ),
            SketchChip(
              label: 'Medium',
              selected: _size == SocialLoginButtonSize.medium,
              onSelected: (selected) {
                if (selected) setState(() => _size = SocialLoginButtonSize.medium);
              },
            ),
            SketchChip(
              label: 'Large',
              selected: _size == SocialLoginButtonSize.large,
              onSelected: (selected) {
                if (selected) setState(() => _size = SocialLoginButtonSize.large);
              },
            ),
          ],
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Apple Style 선택 (Apple 전용)
        if (_platform == SocialLoginPlatform.apple) ...[
          const Text('Apple Style', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: SketchDesignTokens.spacingSm),
          Wrap(
            spacing: SketchDesignTokens.spacingSm,
            children: [
              SketchChip(
                label: 'Dark',
                selected: _appleStyle == AppleSignInStyle.dark,
                onSelected: (selected) {
                  if (selected) setState(() => _appleStyle = AppleSignInStyle.dark);
                },
              ),
              SketchChip(
                label: 'Light',
                selected: _appleStyle == AppleSignInStyle.light,
                onSelected: (selected) {
                  if (selected) setState(() => _appleStyle = AppleSignInStyle.light);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 변형 갤러리 섹션
  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '변형 갤러리',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Kakao
        const Text('Kakao', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SocialLoginButton(
          platform: SocialLoginPlatform.kakao,
          size: SocialLoginButtonSize.medium,
          onPressed: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Naver
        const Text('Naver', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SocialLoginButton(
          platform: SocialLoginPlatform.naver,
          size: SocialLoginButtonSize.medium,
          onPressed: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Apple Dark
        const Text('Apple (Dark)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SocialLoginButton(
          platform: SocialLoginPlatform.apple,
          size: SocialLoginButtonSize.medium,
          appleStyle: AppleSignInStyle.dark,
          onPressed: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Apple Light
        const Text('Apple (Light)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SocialLoginButton(
          platform: SocialLoginPlatform.apple,
          size: SocialLoginButtonSize.medium,
          appleStyle: AppleSignInStyle.light,
          onPressed: () {},
        ),
        const SizedBox(height: SketchDesignTokens.spacingLg),

        // Google
        const Text('Google', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: SketchDesignTokens.spacingSm),
        SocialLoginButton(
          platform: SocialLoginPlatform.google,
          size: SocialLoginButtonSize.medium,
          onPressed: () {},
        ),
      ],
    );
  }
}
