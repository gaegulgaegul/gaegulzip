import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';

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

  /// 에러 메시지
  final errorMessage = ''.obs;

  // ===== 비반응형 상태 =====

  /// 인증 Repository (의존성 주입) - 추후 구현 예정
  // late final AuthRepository _authRepository;

  // ===== 메서드 =====

  /// 카카오 로그인 처리
  ///
  /// API 호출을 통해 카카오 계정으로 로그인합니다.
  /// 성공 시 메인 화면으로 이동하며, 실패 시 에러 메시지를 표시합니다.
  Future<void> handleKakaoLogin() async {
    try {
      isKakaoLoading.value = true;
      errorMessage.value = '';

      // API 호출 (추후 구현)
      // final result = await _authRepository.loginWithKakao();

      // 임시: 2초 대기 후 성공
      await Future.delayed(const Duration(seconds: 2));

      // 성공 시 메인 화면으로 이동 (추후 구현)
      // Get.offAllNamed(Routes.HOME);

      _showSuccessSnackbar('카카오 로그인 성공', '환영합니다!');
    } on NetworkException catch (e) {
      // 네트워크 오류
      errorMessage.value = '네트워크 연결을 확인해주세요';
      _showErrorSnackbar('카카오 로그인 실패', errorMessage.value);
    } on AuthException catch (e) {
      // 인증 오류 (사용자 취소, 권한 거부 등)
      if (e.code == 'user_cancelled') {
        // 사용자가 취소한 경우 - 에러로 처리하지 않음
        return;
      }
      errorMessage.value = e.message;
      _showErrorSnackbar('카카오 로그인 실패', errorMessage.value);
    } catch (e) {
      // 기타 오류
      errorMessage.value = '로그인 중 오류가 발생했습니다';
      _showErrorSnackbar('카카오 로그인 실패', errorMessage.value);
    } finally {
      isKakaoLoading.value = false;
    }
  }

  /// 네이버 로그인 처리
  ///
  /// API 호출을 통해 네이버 계정으로 로그인합니다.
  Future<void> handleNaverLogin() async {
    try {
      isNaverLoading.value = true;
      errorMessage.value = '';

      // API 호출 (추후 구현)
      // final result = await _authRepository.loginWithNaver();

      // 임시: 2초 대기 후 성공
      await Future.delayed(const Duration(seconds: 2));

      // Get.offAllNamed(Routes.HOME);
      _showSuccessSnackbar('네이버 로그인 성공', '환영합니다!');
    } on NetworkException catch (e) {
      errorMessage.value = '네트워크 연결을 확인해주세요';
      _showErrorSnackbar('네이버 로그인 실패', errorMessage.value);
    } on AuthException catch (e) {
      if (e.code == 'user_cancelled') return;
      errorMessage.value = e.message;
      _showErrorSnackbar('네이버 로그인 실패', errorMessage.value);
    } catch (e) {
      errorMessage.value = '로그인 중 오류가 발생했습니다';
      _showErrorSnackbar('네이버 로그인 실패', errorMessage.value);
    } finally {
      isNaverLoading.value = false;
    }
  }

  /// 애플 로그인 처리
  ///
  /// API 호출을 통해 Apple ID로 로그인합니다.
  Future<void> handleAppleLogin() async {
    try {
      isAppleLoading.value = true;
      errorMessage.value = '';

      // API 호출 (추후 구현)
      // final result = await _authRepository.loginWithApple();

      // 임시: 2초 대기 후 성공
      await Future.delayed(const Duration(seconds: 2));

      // Get.offAllNamed(Routes.HOME);
      _showSuccessSnackbar('애플 로그인 성공', '환영합니다!');
    } on NetworkException catch (e) {
      errorMessage.value = '네트워크 연결을 확인해주세요';
      _showErrorSnackbar('애플 로그인 실패', errorMessage.value);
    } on AuthException catch (e) {
      if (e.code == 'user_cancelled') return;
      errorMessage.value = e.message;
      _showErrorSnackbar('애플 로그인 실패', errorMessage.value);
    } catch (e) {
      errorMessage.value = '로그인 중 오류가 발생했습니다';
      _showErrorSnackbar('애플 로그인 실패', errorMessage.value);
    } finally {
      isAppleLoading.value = false;
    }
  }

  /// 구글 로그인 처리
  ///
  /// API 호출을 통해 Google 계정으로 로그인합니다.
  Future<void> handleGoogleLogin() async {
    try {
      isGoogleLoading.value = true;
      errorMessage.value = '';

      // API 호출 (추후 구현)
      // final result = await _authRepository.loginWithGoogle();

      // 임시: 2초 대기 후 성공
      await Future.delayed(const Duration(seconds: 2));

      // Get.offAllNamed(Routes.HOME);
      _showSuccessSnackbar('구글 로그인 성공', '환영합니다!');
    } on NetworkException catch (e) {
      errorMessage.value = '네트워크 연결을 확인해주세요';
      _showErrorSnackbar('구글 로그인 실패', errorMessage.value);
    } on AuthException catch (e) {
      if (e.code == 'user_cancelled') return;
      errorMessage.value = e.message;
      _showErrorSnackbar('구글 로그인 실패', errorMessage.value);
    } catch (e) {
      errorMessage.value = '로그인 중 오류가 발생했습니다';
      _showErrorSnackbar('구글 로그인 실패', errorMessage.value);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// 에러 스낵바 표시
  ///
  /// [title] 에러 제목
  /// [message] 에러 메시지
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      icon: Icon(Icons.error_outline, color: Colors.red.shade900),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  /// 성공 스낵바 표시
  ///
  /// [title] 성공 제목
  /// [message] 성공 메시지
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      icon: Icon(Icons.check_circle_outline, color: Colors.green.shade900),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  /// 초기화
  @override
  void onInit() {
    super.onInit();
    // Repository 주입 (추후 구현 시 활성화)
    // _authRepository = Get.find<AuthRepository>();
  }

  /// 정리
  @override
  void onClose() {
    // 리소스 정리
    super.onClose();
  }
}
