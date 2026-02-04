import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/social_login/social_login_provider.dart';
import '../../../services/social_login/kakao_login_provider.dart';
import '../../../services/social_login/naver_login_provider.dart';
import '../../../services/social_login/apple_login_provider.dart';
import '../../../services/social_login/google_login_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_state_service.dart';

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

  // ===== 비반응형 상태 (의존성) =====

  late final AuthRepository _authRepository;
  late final SocialLoginProvider _kakaoProvider;
  late final SocialLoginProvider _naverProvider;
  late final SocialLoginProvider _appleProvider;
  late final SocialLoginProvider _googleProvider;

  // ===== 초기화 =====

  @override
  void onInit() {
    super.onInit();

    // Repository 및 Provider 주입
    _authRepository = Get.find<AuthRepository>();
    _kakaoProvider = Get.find<KakaoLoginProvider>();
    _naverProvider = Get.find<NaverLoginProvider>();
    _appleProvider = Get.find<AppleLoginProvider>();
    _googleProvider = Get.find<GoogleLoginProvider>();
  }

  // ===== 소셜 로그인 메서드 =====

  /// 카카오 로그인 처리
  Future<void> handleKakaoLogin() async {
    await _handleSocialLogin(
      provider: _kakaoProvider,
      loadingState: isKakaoLoading,
    );
  }

  /// 네이버 로그인 처리
  Future<void> handleNaverLogin() async {
    await _handleSocialLogin(
      provider: _naverProvider,
      loadingState: isNaverLoading,
    );
  }

  /// 애플 로그인 처리
  Future<void> handleAppleLogin() async {
    await _handleSocialLogin(
      provider: _appleProvider,
      loadingState: isAppleLoading,
    );
  }

  /// 구글 로그인 처리
  Future<void> handleGoogleLogin() async {
    await _handleSocialLogin(
      provider: _googleProvider,
      loadingState: isGoogleLoading,
    );
  }

  /// 공통 소셜 로그인 처리 로직
  ///
  /// [provider] SocialLoginProvider 인스턴스
  /// [loadingState] 로딩 상태 (.obs)
  Future<void> _handleSocialLogin({
    required SocialLoginProvider provider,
    required RxBool loadingState,
  }) async {
    try {
      // 1. 로딩 시작
      loadingState.value = true;

      // 2. 소셜 SDK에서 OAuth access token 획득
      final accessToken = await provider.signIn();

      // 3. 백엔드 API 호출 (로그인)
      final user = await _authRepository.login(
        provider: provider.platformName,
        accessToken: accessToken,
      );

      // 4. 전역 인증 상태 업데이트
      Get.find<AuthStateService>().onLoginSuccess();

      // 5. 성공 - 메인 화면으로 이동
      Get.offAllNamed(Routes.HOME);

      // 5. 성공 메시지
      _showSuccessSnackbar('로그인 성공', '${user.nickname}님 환영합니다!');
    } on AuthException catch (e) {
      // 인증 오류
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
      _showErrorSnackbar(
        '네트워크 오류',
        e.message,
        onRetry: () => _handleSocialLogin(
          provider: provider,
          loadingState: loadingState,
        ),
      );
    } catch (e) {
      // 기타 오류
      _showErrorSnackbar(
        '로그인 오류',
        '로그인 중 오류가 발생했습니다',
        onRetry: () => _handleSocialLogin(
          provider: provider,
          loadingState: loadingState,
        ),
      );
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
  /// [onRetry] 재시도 콜백 (선택적)
  void _showErrorSnackbar(
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFB00020), // Material 3 error
        duration: onRetry != null
            ? const Duration(days: 1) // 재시도 버튼 있으면 무한 표시
            : const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        mainButton: onRetry != null
            ? TextButton(
                onPressed: () {
                  Get.back(); // SnackBar 닫기
                  onRetry();
                },
                child: const Text(
                  '재시도',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
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
