# 작업 분배 계획: 소셜 로그인 버튼 컴포넌트

> **작성일**: 2026-01-18
> **프로젝트**: wowa Flutter App
> **기능**: 카카오/네이버/애플/구글 소셜 로그인 버튼 (Material 위젯 기반)

---

## 작업 개요

brief.md 설계를 바탕으로 **Senior Developer**와 **Junior Developer**에게 작업을 분배합니다.

**핵심 원칙**:
1. **순차 실행**: Senior 작업 완료 → Junior 작업 시작
2. **명확한 인터페이스 계약**: Controller와 View 간 정확한 연결
3. **충돌 방지**: 메서드명, .obs 변수명 정확히 일치

---

## 📋 작업 의존성 다이어그램

```
Senior Developer 작업 (우선 실행)
├── 1. Exception 클래스 작성 (AuthException, NetworkException)
├── 2. Enum 클래스 작성 (SocialLoginPlatform, SocialLoginButtonSize, AppleSignInStyle)
├── 3. SocialLoginButton 위젯 구현 (design_system 패키지)
├── 4. 에셋 리소스 준비 (로고 SVG 파일)
├── 5. pubspec.yaml 업데이트 (flutter_svg 추가)
├── 6. LoginController 작성 (wowa 앱)
└── 7. LoginBinding 작성 (wowa 앱)
     ↓
     ↓ (Senior 완료 후)
     ↓
Junior Developer 작업 (Senior 완료 후 실행)
├── 1. LoginView 작성 (Senior의 Controller 읽기 필수)
└── 2. Routing 업데이트 (app_routes.dart, app_pages.dart)
```

---

## 👨‍💻 Senior Developer 작업 범위

### 우선순위 1: Exception 클래스 작성

#### 1-1. AuthException 클래스

**파일**: `packages/core/lib/src/exceptions/auth_exception.dart`

**요구사항**:
```dart
/// 인증 관련 예외
///
/// 소셜 로그인 실패, 토큰 만료, 권한 거부 등의 상황에서 발생합니다.
class AuthException implements Exception {
  /// 에러 코드 (예: 'user_cancelled', 'invalid_token')
  final String code;

  /// 에러 메시지 (사용자에게 표시할 메시지)
  final String message;

  const AuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AuthException($code): $message';
}
```

#### 1-2. NetworkException 클래스

**파일**: `packages/core/lib/src/exceptions/network_exception.dart`

**요구사항**:
```dart
/// 네트워크 관련 예외
///
/// 네트워크 연결 실패, 타임아웃 등의 상황에서 발생합니다.
class NetworkException implements Exception {
  /// 에러 메시지
  final String message;

  /// HTTP 상태 코드 (선택 사항)
  final int? statusCode;

  const NetworkException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'NetworkException(${statusCode ?? 'N/A'}): $message';
}
```

#### 1-3. core 패키지 export 업데이트

**파일**: `packages/core/lib/core.dart`

```dart
// Exceptions
export 'src/exceptions/auth_exception.dart';
export 'src/exceptions/network_exception.dart';
```

---

### 우선순위 2: Enum 클래스 작성

#### 2-1. SocialLoginPlatform enum

**파일**: `packages/design_system/lib/src/enums/social_login_platform.dart`

```dart
/// 소셜 로그인 플랫폼
enum SocialLoginPlatform {
  /// 카카오 로그인
  kakao,

  /// 네이버 로그인
  naver,

  /// 애플 로그인
  apple,

  /// 구글 로그인
  google,
}

/// 소셜 로그인 버튼 크기
enum SocialLoginButtonSize {
  /// 작은 크기 (32px)
  small,

  /// 중간 크기 (40px)
  medium,

  /// 큰 크기 (48px)
  large,
}
```

#### 2-2. AppleSignInStyle enum

**파일**: `packages/design_system/lib/src/enums/apple_sign_in_style.dart`

```dart
/// 애플 로그인 버튼 스타일
enum AppleSignInStyle {
  /// 검은 배경, 흰 텍스트 (기본값)
  dark,

  /// 흰 배경, 검은 텍스트
  light,
}
```

#### 2-3. design_system 패키지 export 업데이트

**파일**: `packages/design_system/lib/design_system.dart`

```dart
// Enums
export 'src/enums/social_login_platform.dart';
export 'src/enums/apple_sign_in_style.dart';

// Widgets
export 'src/widgets/social_login_button.dart';
```

---

### 우선순위 3: SocialLoginButton 위젯 구현

**파일**: `packages/design_system/lib/src/widgets/social_login_button.dart`

**요구사항**:
- **기술 스택**: Container + InkWell + Material (표준 위젯)
- **로고 렌더링**: flutter_svg 사용
- **스타일**: 각 플랫폼 공식 가이드라인 100% 준수
- **주석**: 모든 public API에 JSDoc (한글)

**구현 내용**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    Key? key,
    required this.platform,
    this.size = SocialLoginButtonSize.medium,
    this.appleStyle = AppleSignInStyle.dark,
    this.isLoading = false,
    this.text,
    this.onPressed,
  }) : super(key: key);

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
        ),

        SizedBox(width: 12),

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
          backgroundColor: Color(0xFFFEE500), // 카카오 옐로우
          borderColor: Color(0xFFFEE500),
          borderWidth: 0, // 테두리 없음
          textColor: Color(0xFF000000),
          logoPath: 'assets/social_login/kakao_symbol.svg',
          defaultText: '카카오 계정으로 로그인',
          borderRadius: 12.0, // 카카오 공식 가이드라인
        );

      case SocialLoginPlatform.naver:
        return _PlatformSpec(
          backgroundColor: Color(0xFF03C75A), // 네이버 그린
          borderColor: Color(0xFF03C75A),
          borderWidth: 0,
          textColor: Color(0xFFFFFFFF),
          logoPath: 'assets/social_login/naver_logo.svg',
          defaultText: '네이버 계정으로 로그인',
          borderRadius: 8.0, // 네이버 권장
        );

      case SocialLoginPlatform.apple:
        return appleStyle == AppleSignInStyle.dark
            ? _PlatformSpec(
                backgroundColor: Color(0xFF000000),
                borderColor: Color(0xFF000000),
                borderWidth: 0,
                textColor: Color(0xFFFFFFFF),
                logoPath: 'assets/social_login/apple_logo.svg',
                defaultText: 'Apple로 로그인',
                borderRadius: 6.0, // Apple HIG 권장
              )
            : _PlatformSpec(
                backgroundColor: Color(0xFFFFFFFF),
                borderColor: Color(0xFF000000),
                borderWidth: 1.0,
                textColor: Color(0xFF000000),
                logoPath: 'assets/social_login/apple_logo.svg',
                defaultText: 'Apple로 로그인',
                borderRadius: 6.0,
              );

      case SocialLoginPlatform.google:
        return _PlatformSpec(
          backgroundColor: Color(0xFFFFFFFF),
          borderColor: Color(0xFFDCDCDC), // 밝은 회색
          borderWidth: 1.0,
          textColor: Color(0xFF000000),
          logoPath: 'assets/social_login/google_logo.svg',
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
          height: 32,
          horizontalPadding: 16,
          verticalPadding: 8,
          fontSize: 14,
          logoSize: 16,
        );

      case SocialLoginButtonSize.medium:
        return _SizeSpec(
          height: 40,
          horizontalPadding: 24,
          verticalPadding: 12,
          fontSize: 16,
          logoSize: 18,
        );

      case SocialLoginButtonSize.large:
        return _SizeSpec(
          height: 48,
          horizontalPadding: 32,
          verticalPadding: 16,
          fontSize: 18,
          logoSize: 20,
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
  final String defaultText;
  final double borderRadius;

  _PlatformSpec({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.textColor,
    required this.logoPath,
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
```

---

### 우선순위 4: 에셋 리소스 준비

#### 4-1. 디렉토리 생성

```bash
mkdir -p packages/design_system/assets/social_login
```

#### 4-2. 로고 SVG 파일 다운로드 및 배치

**필요한 파일**:

1. **kakao_symbol.svg** (20x20px)
   - 카카오 말풍선 심볼
   - 검은색 단색
   - 출처: https://developers.kakao.com/tool/resource/login

2. **naver_logo.svg** (20x20px)
   - 네이버 N 로고
   - 흰색 단색
   - 출처: 네이버 개발자센터

3. **apple_logo.svg** (20x20px)
   - 애플 심볼
   - 흰색/검은색 (SVG colorFilter로 처리 가능)
   - 출처: https://developer.apple.com/design/resources/

4. **google_logo.svg** (20x20px)
   - 구글 G 로고
   - 4색 버전 (파랑, 빨강, 노랑, 녹색)
   - 출처: https://developers.google.com/identity/branding-guidelines

**위치**: `packages/design_system/assets/social_login/`

---

### 우선순위 5: pubspec.yaml 업데이트

**파일**: `packages/design_system/pubspec.yaml`

**추가 내용**:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # SVG 렌더링 (로고 이미지)
  flutter_svg: ^2.0.10+1

  # State management
  get: ^4.6.6

  # Internal dependencies
  core:
    path: ../core

flutter:
  assets:
    - assets/social_login/
```

**실행 명령**:
```bash
cd /Users/lms/dev/repository/app_gaegulzip
melos bootstrap
```

---

### 우선순위 6: LoginController 작성

**파일**: `apps/wowa/lib/app/modules/login/controllers/login_controller.dart`

**요구사항**:
- GetxController 상속
- 4개 플랫폼별 로딩 상태 관리 (.obs)
- 에러 처리 (try-catch, Get.snackbar)
- JSDoc 주석 (한글)

**구현 내용**:

```dart
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

  /// 인증 Repository (의존성 주입)
  late final AuthRepository _authRepository;

  // ===== 메서드 =====

  /// 카카오 로그인 처리
  ///
  /// API 호출을 통해 카카오 계정으로 로그인합니다.
  /// 성공 시 메인 화면으로 이동하며, 실패 시 에러 메시지를 표시합니다.
  Future<void> handleKakaoLogin() async {
    try {
      isKakaoLoading.value = true;
      errorMessage.value = '';

      // API 호출
      final result = await _authRepository.loginWithKakao();

      // 성공 시 메인 화면으로 이동
      Get.offAllNamed(Routes.HOME);

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

      final result = await _authRepository.loginWithNaver();
      Get.offAllNamed(Routes.HOME);

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

      final result = await _authRepository.loginWithApple();
      Get.offAllNamed(Routes.HOME);

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

      final result = await _authRepository.loginWithGoogle();
      Get.offAllNamed(Routes.HOME);

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
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 3),
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
```

**주의사항**:
- `AuthRepository`는 추후 구현 예정이므로 임시로 주석 처리
- `.obs 변수명`, `메서드명`을 정확히 Junior에게 전달

---

### 우선순위 7: LoginBinding 작성

**파일**: `apps/wowa/lib/app/modules/login/bindings/login_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// 로그인 모듈 바인딩
///
/// LoginController와 AuthRepository를 지연 로딩합니다.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Controller 지연 로딩
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );

    // Repository 지연 로딩 (추후 구현 시 활성화)
    // Get.lazyPut<AuthRepository>(
    //   () => AuthRepository(),
    // );
  }
}
```

---

### Senior 작업 완료 조건

- [ ] Exception 클래스 2개 작성 완료 (`AuthException`, `NetworkException`)
- [ ] Enum 클래스 2개 작성 완료 (`SocialLoginPlatform`, `AppleSignInStyle`)
- [ ] `SocialLoginButton` 위젯 구현 완료
- [ ] 로고 SVG 파일 4개 배치 완료
- [ ] `pubspec.yaml` 업데이트 및 `melos bootstrap` 실행 완료
- [ ] `LoginController` 작성 완료
- [ ] `LoginBinding` 작성 완료
- [ ] 컴파일 에러 없음 (flutter analyze 통과)
- [ ] JSDoc 주석 완비 (한글)

**예상 소요 시간**: 4-6시간

**중요**: **melos generate 불필요** (API 모델 사용하지 않음)

---

## 👨‍💼 Junior Developer 작업 범위

⚠️ **작업 시작 전 필수**: Senior의 `LoginController` 파일을 Read 도구로 정확히 읽고 이해해야 합니다.

### 우선순위 1: LoginView 작성

**파일**: `apps/wowa/lib/app/modules/login/views/login_view.dart`

**참조 파일** (반드시 읽기):
- `design-spec.md`: UI 구조, 레이아웃
- `brief.md`: View 구조, Widget 상세
- `apps/wowa/lib/app/modules/login/controllers/login_controller.dart`: Controller 인터페이스

**요구사항**:
- GetView<LoginController> 상속
- design-spec.md의 UI 구조 정확히 따름
- Controller의 .obs 변수와 메서드 정확히 연결
- Obx 범위 최소화 (버튼별 개별 Obx)
- const 최적화 적용
- JSDoc 주석 (한글)

**구현 내용**:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
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
```

**const 최적화 전략**:
- `const SizedBox(height: ...)`: 정적 위젯은 const 사용
- `const EdgeInsets.symmetric(...)`: 정적 패딩은 const
- `Obx` 범위 최소화: 버튼별로 개별 Obx 사용 (전체 화면이 아님)

---

### 우선순위 2: Routing 업데이트

#### 2-1. app_routes.dart 업데이트

**파일**: `apps/wowa/lib/app/routes/app_routes.dart`

**추가 내용**:
```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const SETTINGS = '/settings';
  // ... 기존 라우트
}
```

#### 2-2. app_pages.dart 업데이트

**파일**: `apps/wowa/lib/app/routes/app_pages.dart`

**추가 내용**:
```dart
import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // ... 기존 라우트
  ];
}
```

---

### Junior 작업 완료 조건

- [ ] `LoginView` 작성 완료 (design-spec.md 정확히 따름)
- [ ] Controller의 `.obs 변수`와 `메서드` 정확히 연결
- [ ] Obx 범위 최소화 (버튼별 개별 Obx)
- [ ] const 최적화 적용
- [ ] Routing 업데이트 완료 (`app_routes.dart`, `app_pages.dart`)
- [ ] 컴파일 에러 없음
- [ ] JSDoc 주석 완비 (한글)

**예상 소요 시간**: 2-3시간

---

## 🔗 인터페이스 계약 (Controller ↔ View)

### Controller → View 연결점

Junior Developer는 아래 인터페이스를 **정확히 일치**시켜야 합니다.

#### .obs 변수 (반응형 상태)

| Controller 변수명 | View 사용 위치 | 용도 |
|---|---|---|
| `isKakaoLoading.value` | `SocialLoginButton(isLoading: ...)` | 카카오 버튼 로딩 상태 |
| `isNaverLoading.value` | `SocialLoginButton(isLoading: ...)` | 네이버 버튼 로딩 상태 |
| `isAppleLoading.value` | `SocialLoginButton(isLoading: ...)` | 애플 버튼 로딩 상태 |
| `isGoogleLoading.value` | `SocialLoginButton(isLoading: ...)` | 구글 버튼 로딩 상태 |
| `errorMessage.value` | (사용 안 함 - Controller에서 snackbar 처리) | 에러 메시지 |

#### 메서드 (이벤트 핸들러)

| Controller 메서드 | View 사용 위치 | 시그니처 |
|---|---|---|
| `handleKakaoLogin()` | `SocialLoginButton(onPressed: ...)` | `Future<void> Function()` |
| `handleNaverLogin()` | `SocialLoginButton(onPressed: ...)` | `Future<void> Function()` |
| `handleAppleLogin()` | `SocialLoginButton(onPressed: ...)` | `Future<void> Function()` |
| `handleGoogleLogin()` | `SocialLoginButton(onPressed: ...)` | `Future<void> Function()` |

### ⚠️ 절대 규칙

1. **메서드명 일치**: `handleKakaoLogin` (O) / `kakaoLogin` (X)
2. **변수명 일치**: `isKakaoLoading` (O) / `kakaoLoading` (X)
3. **타입 일치**: `Future<void>` 반환 타입 유지
4. **Controller 수정 금지**: Junior는 Controller 메서드 임의 추가/변경 금지

---

## 🚨 충돌 방지 전략

### Senior의 책임

1. **Controller 인터페이스 확정**:
   - `.obs 변수명` 변경 시 Junior에게 즉시 알림
   - 메서드 시그니처 변경 시 Junior에게 즉시 알림

2. **코드 리뷰**:
   - Junior의 View 코드에서 Controller 연결 정확성 검증

### Junior의 책임

1. **Controller 먼저 읽기**:
   - `LoginController` 파일을 Read 도구로 읽고 정확히 이해
   - `.obs 변수명`, 메서드명 메모

2. **의문점 즉시 질문**:
   - Controller 인터페이스 이해 안 되면 Senior에게 질문
   - 임의로 추측하지 않음

3. **Controller 수정 금지**:
   - View에서 필요한 메서드가 없어도 Controller 임의 추가 금지
   - Senior에게 요청

### 문제 발생 시 에스컬레이션

- **충돌 발생**: Senior와 Junior가 동시 작업으로 충돌 시
- **인터페이스 불일치**: View가 Controller를 잘못 참조 시
- **해결 방법**: CTO에게 즉시 에스컬레이션, CTO가 중재 및 조율

---

## 📊 작업 진행 체크리스트

### Phase 1: Senior 작업 (우선 실행)

- [ ] Exception 클래스 작성 (AuthException, NetworkException)
- [ ] Enum 클래스 작성 (SocialLoginPlatform, AppleSignInStyle)
- [ ] SocialLoginButton 위젯 구현
- [ ] 로고 SVG 파일 배치
- [ ] pubspec.yaml 업데이트 + melos bootstrap
- [ ] LoginController 작성
- [ ] LoginBinding 작성
- [ ] flutter analyze 통과
- [ ] JSDoc 주석 완비

### Phase 2: Junior 작업 (Senior 완료 후)

- [ ] Senior의 LoginController 읽기 (Read 도구 사용)
- [ ] .obs 변수명, 메서드명 확인 및 메모
- [ ] LoginView 작성
- [ ] Controller와 View 연결 (Obx, onPressed)
- [ ] const 최적화 적용
- [ ] Routing 업데이트 (app_routes.dart, app_pages.dart)
- [ ] flutter analyze 통과
- [ ] JSDoc 주석 완비

### Phase 3: 통합 검증 (CTO)

- [ ] Senior + Junior 코드 통합 확인
- [ ] Controller ↔ View 인터페이스 일치 확인
- [ ] flutter run --debug 실행
- [ ] UI가 design-spec.md와 일치하는지 확인
- [ ] 각 플랫폼 버튼 클릭 시 에러 없이 동작
- [ ] 로딩 상태 정확히 표시
- [ ] GetX 패턴 준수 확인

---

## 🎯 성공 기준

### 기능 검증

- [ ] 4개 플랫폼 버튼이 각각 정확히 렌더링됨
- [ ] 로딩 상태에서 CircularProgressIndicator 표시
- [ ] 버튼 클릭 시 onPressed 콜백 호출
- [ ] 각 플랫폼별 독립적인 로딩 상태 관리
- [ ] 에러 발생 시 Get.snackbar 표시

### 디자인 검증

- [ ] 카카오: 노란 배경 (#FEE500), 검은 텍스트, 말풍선 로고, borderRadius 12px
- [ ] 네이버: 녹색 배경 (#03C75A), 흰 텍스트, N 로고, borderRadius 8px
- [ ] 애플: 검은 배경 (#000000), 흰 텍스트, 애플 로고, borderRadius 6px
- [ ] 구글: 흰 배경 (#FFFFFF), 검은 텍스트, 회색 테두리 (#DCDCDC), G 로고, borderRadius 4px

### 성능 검증

- [ ] Obx 범위가 버튼별로 최소화됨
- [ ] const 생성자 적용 (SizedBox, EdgeInsets)
- [ ] 불필요한 rebuild 없음

### 코드 품질

- [ ] GetX 패턴 준수 (Controller, View, Binding 분리)
- [ ] 에러 처리 완비 (try-catch, Get.snackbar)
- [ ] 모든 public API에 JSDoc 주석 (한글)
- [ ] CLAUDE.md 표준 준수
- [ ] flutter analyze 통과

---

## 📝 다음 단계

1. **Senior Developer**: 이 작업 계획을 리뷰하고 작업 시작
2. **Junior Developer**: Senior 작업 완료를 기다린 후 LoginController 읽기
3. **CTO**: Senior + Junior 코드 통합 후 cto-review.md 작성
4. **QA**: 각 플랫폼 디자인 가이드라인 체크리스트 검증

---

## 🔧 트러블슈팅

### flutter_svg 패키지 오류 시

```bash
cd /Users/lms/dev/repository/app_gaegulzip
melos clean
melos bootstrap
cd packages/design_system
flutter pub get
```

### 로고 SVG 파일이 표시 안 됨 시

1. `pubspec.yaml`에 assets 경로 정확히 등록했는지 확인
2. SVG 파일 경로: `packages/design_system/assets/social_login/`
3. `melos bootstrap` 재실행

### Controller와 View 연결 안 됨 시

1. Junior가 Controller 파일을 정확히 읽었는지 확인
2. `.obs` 변수명, 메서드명 정확히 일치하는지 확인
3. `Get.find<LoginController>()` 호출 가능한지 확인 (Binding 등록 확인)

---

**작성자**: CTO
**승인**: 사용자 승인 대기
**버전**: 1.0
