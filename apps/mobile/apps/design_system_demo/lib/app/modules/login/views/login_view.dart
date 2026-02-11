import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

/// 로그인 화면
///
/// 카카오, 네이버, 애플, 구글 소셜 로그인 버튼과
/// "둘러보기" 버튼을 제공합니다.
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                const Text(
                  'Demo Login',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSize3Xl,
                    fontFamily: SketchDesignTokens.fontFamilyHand,
                    color: SketchDesignTokens.base900,
                  ),
                ),

                const SizedBox(height: 8),

                // 부제목
                const Text(
                  'SDK 데모를 위한 로그인',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeSm,
                    color: SketchDesignTokens.base700,
                  ),
                ),

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

                // 둘러보기 버튼 (로그인 없이 HOME 이동)
                SketchButton(
                  text: '둘러보기',
                  style: SketchButtonStyle.outline,
                  size: SketchButtonSize.medium,
                  onPressed: () => Get.offAllNamed(Routes.HOME),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
