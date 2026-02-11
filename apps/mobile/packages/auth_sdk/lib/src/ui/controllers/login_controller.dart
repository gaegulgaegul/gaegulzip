import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../auth_sdk.dart';

/// 로그인 화면 컨트롤러
///
/// 카카오, 네이버, 애플, 구글 소셜 로그인을 처리합니다.
class LoginController extends GetxController {
  // ===== 반응형 상태 (.obs) =====

  /// 카카오 로그인 로딩 상태
  final isKakaoLoading = false.obs;

  /// 네이버 로그인 로딩 상태
  final isNaverLoading = false.obs;

  /// 애플 로그인 로딩 상태
  final isAppleLoading = false.obs;

  /// 구글 로그인 로딩 상태
  final isGoogleLoading = false.obs;

  // ===== 소셜 로그인 메서드 =====

  /// 카카오 로그인 처리
  Future<void> handleKakaoLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.kakao,
      loadingState: isKakaoLoading,
    );
  }

  /// 네이버 로그인 처리
  Future<void> handleNaverLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.naver,
      loadingState: isNaverLoading,
    );
  }

  /// 애플 로그인 처리
  Future<void> handleAppleLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.apple,
      loadingState: isAppleLoading,
    );
  }

  /// 구글 로그인 처리
  Future<void> handleGoogleLogin() async {
    await _handleSocialLogin(
      provider: SocialProvider.google,
      loadingState: isGoogleLoading,
    );
  }

  /// 공통 소셜 로그인 처리 로직
  ///
  /// [provider] SocialProvider 열거형
  /// [loadingState] 로딩 상태 (.obs)
  Future<void> _handleSocialLogin({
    required SocialProvider provider,
    required RxBool loadingState,
  }) async {
    try {
      // 1. 로딩 시작
      loadingState.value = true;

      // 2. AuthSdk를 통한 소셜 로그인
      await AuthSdk.login(provider);

      // 3. 성공 - SDK 설정의 homeRoute로 이동
      Get.offAllNamed(AuthSdk.config.homeRoute);
    } on AuthException catch (e) {
      // 인증 오류
      Logger.error('AuthException [${e.code}]: ${e.message}', error: e);
      if (e.code == 'user_cancelled') {
        // 사용자 취소 - 조용히 실패
        return;
      }

      if (e.code == 'account_conflict') {
        // 계정 연동 충돌 - Modal 표시
        final existingProvider = e.data?['existingProvider'] ?? 'unknown';
        _showAccountLinkModal(existingProvider);
        return;
      }

      if (e.code == 'permission_denied') {
        _showErrorSnackbar('권한 오류', '권한을 허용해주세요');
        return;
      }

      _showErrorSnackbar('로그인 실패', e.message);
    } on NetworkException catch (e) {
      // 네트워크 오류
      Logger.error('NetworkException: ${e.message}', error: e);
      _showErrorSnackbar('네트워크 오류', e.message);
    } catch (e) {
      // 기타 오류
      Logger.error('로그인 중 예기치 않은 오류', error: e);
      _showErrorSnackbar('로그인 오류', '로그인 중 오류가 발생했습니다');
    } finally {
      // 6. 로딩 종료
      loadingState.value = false;
    }
  }

  // ===== UI 피드백 메서드 =====

  /// 에러 스낵바 표시
  ///
  /// [title] 에러 제목
  /// [message] 에러 메시지
  void _showErrorSnackbar(
    String title,
    String message,
  ) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFB00020), // Material 3 error
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      ),
    );
  }

  /// 성공 스낵바 표시
  void _showSuccessSnackbar(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      ),
    );
  }

  /// 계정 연동 충돌 다이얼로그 표시
  ///
  /// [existingProvider] 기존 가입 플랫폼 (예: 'kakao', 'google')
  void _showAccountLinkModal(String existingProvider) {
    // 플랫폼 이름 한글 변환
    final providerName = _getProviderNameKorean(existingProvider);

    SketchModal.show(
      context: Get.context!,
      title: '다른 계정으로 가입되어 있습니다',
      barrierDismissible: false,
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이 이메일은 $providerName 계정으로 가입되어 있습니다. 계정을 연동하시겠습니까?',
            style: const TextStyle(
              fontSize: 14,
              color: SketchDesignTokens.base700,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        SketchButton(
          text: '취소',
          style: SketchButtonStyle.outline,
          onPressed: () => Navigator.of(Get.context!).pop(),
        ),
        SketchButton(
          text: '연동하기',
          style: SketchButtonStyle.primary,
          onPressed: () {
            Navigator.of(Get.context!).pop();
            // TODO: 계정 연동 API 호출 (향후 구현)
            _showSuccessSnackbar('준비 중', '계정 연동 기능은 향후 추가됩니다');
          },
        ),
      ],
    );
  }

  /// 플랫폼 이름 한글 변환
  String _getProviderNameKorean(String provider) {
    switch (provider.toLowerCase()) {
      case 'kakao':
        return '카카오';
      case 'naver':
        return '네이버';
      case 'apple':
        return '애플';
      case 'google':
        return '구글';
      default:
        return provider;
    }
  }

  @override
  void onClose() {
    // 리소스 정리
    super.onClose();
  }
}
