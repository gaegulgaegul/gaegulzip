import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../controllers/login_controller.dart';
import '../../auth_sdk.dart';

/// 로그인 화면
///
/// 카카오, 네이버, 애플, 구글 소셜 로그인 버튼을 제공합니다.
class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 64),

                // 타이틀
                _buildTitle(context),

                const SizedBox(height: 8),

                // 부제목
                _buildSubtitle(context),

                const SizedBox(height: 48),

                // 카카오 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.kakao,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isKakaoLoading.value,
                  onPressed: controller.handleKakaoLogin,
                )),

                const SizedBox(height: 16),

                // 네이버 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.naver,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isNaverLoading.value,
                  onPressed: controller.handleNaverLogin,
                )),

                const SizedBox(height: 16),

                // 애플 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.apple,
                  appleStyle: AppleSignInStyle.dark,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isAppleLoading.value,
                  onPressed: controller.handleAppleLogin,
                )),

                const SizedBox(height: 16),

                // 구글 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.google,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isGoogleLoading.value,
                  onPressed: controller.handleGoogleLogin,
                )),

                const Spacer(),

                // 둘러보기 버튼 (조건부 렌더링)
                if (AuthSdk.config.showBrowseButton)
                  SketchButton(
                    text: '둘러보기',
                    style: SketchButtonStyle.outline,
                    size: SketchButtonSize.medium,
                    onPressed: () => Get.toNamed(AuthSdk.config.homeRoute),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 타이틀 위젯
  Widget _buildTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      '로그인',
      style: TextStyle(
        fontSize: SketchDesignTokens.fontSize3Xl,
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
        color: isDark ? SketchDesignTokens.white : SketchDesignTokens.base900,
      ),
    );
  }

  /// 부제목 위젯
  Widget _buildSubtitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      '소셜 계정으로 간편하게 시작하세요',
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
        fontSize: SketchDesignTokens.fontSizeSm,
        color: isDark ? SketchDesignTokens.base400 : SketchDesignTokens.base700,
      ),
    );
  }
}
