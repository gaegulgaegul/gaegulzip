import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

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
                _buildTitle(),

                const SizedBox(height: 8),

                // 부제목
                _buildSubtitle(),

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

                // 둘러보기 버튼
                TextButton(
                  onPressed: () => Get.toNamed(Routes.HOME),
                  child: const Text('둘러보기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 타이틀 위젯
  Widget _buildTitle() {
    return const Text(
      '로그인',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// 부제목 위젯
  Widget _buildSubtitle() {
    return Text(
      '소셜 계정으로 간편하게 시작하세요',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    );
  }
}
