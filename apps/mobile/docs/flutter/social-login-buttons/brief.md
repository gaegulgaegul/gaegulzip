# 기술 아키텍처 설계: 소셜 로그인 버튼 컴포넌트

> **참고**: design-spec.md는 초기 디자인 단계 참고 자료입니다.
> Sketch 스타일 관련 내용은 무시하고, 본 brief.md의 표준 Material 위젯 구현을 따라주세요.

---

## 개요

카카오, 네이버, 애플, 구글의 소셜 로그인 버튼을 **표준 Material 위젯**으로 구현합니다. 각 플랫폼의 공식 디자인 가이드라인만 정확히 준수하며, **Sketch 스타일은 완전히 제거**합니다.

**핵심 기술 전략**:
- Container + InkWell 기반 커스텀 버튼 위젯
- flutter_svg로 로고 렌더링
- GetX 상태 관리
- 각 플랫폼 공식 가이드라인 100% 준수

---

## 모듈 구조 (packages/design_system)

### 디렉토리 구조

```
packages/design_system/
├── lib/
│   ├── src/
│   │   ├── widgets/
│   │   │   └── social_login_button.dart  # 메인 위젯
│   │   └── enums/
│   │       ├── social_login_platform.dart
│   │       └── apple_sign_in_style.dart
│   ├── design_system.dart
│   └── assets/
│       └── social_login/                   # 로고 SVG 파일
│           ├── kakao_symbol.svg
│           ├── naver_logo.svg
│           ├── apple_logo.svg
│           └── google_logo.svg
└── pubspec.yaml                             # flutter_svg 추가
```

---

## GetX 상태 관리 설계 (앱에서 사용)

### Controller: LoginController

**파일**: `apps/wowa/lib/app/modules/login/controllers/login_controller.dart`

#### 반응형 상태 (.obs)

```dart
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
```

**설계 근거**:
- 각 플랫폼별 독립적인 로딩 상태 관리
- 버튼의 CircularProgressIndicator 표시 제어
- 동시 다중 로그인 시도 방지

#### 비반응형 상태

```dart
/// 인증 서비스 (의존성 주입)
late final AuthRepository _authRepository;
```

#### 메서드 인터페이스

```dart
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
  } on AuthException catch (e) {
    errorMessage.value = e.message;
    _showErrorSnackbar('카카오 로그인 실패', e.message);
  } finally {
    isKakaoLoading.value = false;
  }
}

/// 네이버 로그인 처리
///
/// API 호출을 통해 네이버 계정으로 로그인합니다.
Future<void> handleNaverLogin() async { /* 동일 패턴 */ }

/// 애플 로그인 처리
///
/// API 호출을 통해 Apple ID로 로그인합니다.
Future<void> handleAppleLogin() async { /* 동일 패턴 */ }

/// 구글 로그인 처리
///
/// API 호출을 통해 Google 계정으로 로그인합니다.
Future<void> handleGoogleLogin() async { /* 동일 패턴 */ }

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
  _authRepository = Get.find<AuthRepository>();
}

/// 정리
@override
void onClose() {
  // 리소스 정리
  super.onClose();
}
```

### Binding: LoginBinding

**파일**: `apps/wowa/lib/app/modules/login/bindings/login_binding.dart`

```dart
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Controller 지연 로딩
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );

    // Repository 지연 로딩
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(),
    );
  }
}
```

---

## View 설계 (Junior Developer가 구현)

### LoginView

**파일**: `apps/wowa/lib/app/modules/login/views/login_view.dart`

#### Widget 구조

```dart
class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 64),

                // 타이틀
                _buildTitle(),

                SizedBox(height: 8),

                // 부제목
                _buildSubtitle(),

                SizedBox(height: 48),

                // 카카오 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.kakao,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isKakaoLoading.value,
                  onPressed: controller.handleKakaoLogin,
                )),

                SizedBox(height: 16),

                // 네이버 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.naver,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isNaverLoading.value,
                  onPressed: controller.handleNaverLogin,
                )),

                SizedBox(height: 16),

                // 애플 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.apple,
                  appleStyle: AppleSignInStyle.dark,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isAppleLoading.value,
                  onPressed: controller.handleAppleLogin,
                )),

                SizedBox(height: 16),

                // 구글 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.google,
                  size: SocialLoginButtonSize.large,
                  isLoading: controller.isGoogleLoading.value,
                  onPressed: controller.handleGoogleLogin,
                )),

                Spacer(),

                // 둘러보기 버튼
                TextButton(
                  onPressed: () => Get.toNamed(Routes.HOME),
                  child: Text('둘러보기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '로그인',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

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

#### const 최적화 전략

- 정적 위젯: `const` 생성자 사용 (`const SizedBox`, `const EdgeInsets`)
- `Obx` 범위 최소화: 버튼별로 개별 Obx 사용 (전체 화면이 아닌 각 버튼만 반응)
- 로딩 상태에서만 rebuild (isLoading 변경 시)

---

## Design System 컴포넌트 구현 (Senior Developer가 구현)

### SocialLoginButton 위젯

**파일**: `packages/design_system/lib/src/widgets/social_login_button.dart`

#### 위젯 클래스

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

### Enum 정의

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

---

## 플랫폼 가이드라인 준수 상세

### 카카오 로그인

**공식 가이드**: https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide

```dart
// 색상
backgroundColor: Color(0xFFFEE500)  // 카카오 옐로우 (필수)
borderColor: Color(0xFFFEE500)     // 테두리 없음 또는 동일 색상
textColor: Color(0xFF000000)       // 검은색 텍스트

// 로고
- 말풍선 심볼 포함 필수
- 검은색 단색
- 크기 비율 유지 (1:1)
- 변형 금지

// 레이아웃
borderRadius: 12.0px               // 둥근 모서리
padding: 16px (vertical), 32px (horizontal)
height: 48px (권장)

// 텍스트
- "카카오 계정으로 로그인" (완성형 문장)
- 시스템 기본 서체 사용
- fontSize: 18px (Large)
```

### 네이버 로그인

**공식 가이드**: https://developers.naver.com/docs/login/bi/bi.md

```dart
// 색상
backgroundColor: Color(0xFF03C75A)  // 네이버 그린 (필수)
borderColor: Color(0xFF03C75A)
textColor: Color(0xFFFFFFFF)       // 흰색 텍스트

// 로고
- N 로고 포함
- 흰색 단색
- 변형 금지

// 레이아웃
borderRadius: 8.0px                // 약간 둥근 모서리
padding: 16px (vertical), 32px (horizontal)
height: 48px

// 텍스트
- "네이버 계정으로 로그인"
- fontSize: 18px (Large)
```

### 애플 로그인

**공식 가이드**: https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple

```dart
// Dark 스타일 (기본)
backgroundColor: Color(0xFF000000)  // 검은색
borderColor: Color(0xFF000000)
textColor: Color(0xFFFFFFFF)       // 흰색

// Light 스타일
backgroundColor: Color(0xFFFFFFFF)  // 흰색
borderColor: Color(0xFF000000)     // 검은색 테두리
textColor: Color(0xFF000000)

// 로고
- 애플 심볼 (Apple logo)
- 색상: 텍스트와 동일 (흰색 또는 검은색)

// 레이아웃
borderRadius: 6.0px                // 부드러운 모서리
padding: 16px (vertical), 32px (horizontal)
height: 48px

// 텍스트
- "Apple로 로그인" (공식 표현)
- "Sign in with Apple" (영문)
- fontSize: 18px
```

### 구글 로그인

**공식 가이드**: https://developers.google.com/identity/branding-guidelines

```dart
// 색상
backgroundColor: Color(0xFFFFFFFF)  // 흰색 배경 (필수)
borderColor: Color(0xFFDCDCDC)     // 밝은 회색 테두리
textColor: Color(0xFF000000)       // 검은색 텍스트

// 로고
- 구글 G 로고 (4색 버전)
- 색상 변경 금지
- 파랑/빨강/노랑/녹색 조합

// 레이아웃
borderRadius: 4.0px                // 약간 둥근 모서리
padding: 16px (vertical), 32px (horizontal)
height: 48px

// 텍스트
- "Google 계정으로 로그인"
- "Sign in with Google" (영문)
- Roboto 폰트 권장 (또는 시스템 기본)
- fontSize: 18px
```

---

## 라우팅 설계

### Route Name (app_routes.dart)

**파일**: `apps/wowa/lib/app/routes/app_routes.dart`

```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const SETTINGS = '/settings';
}
```

### Route Definition (app_pages.dart)

**파일**: `apps/wowa/lib/app/routes/app_pages.dart`

```dart
GetPage(
  name: Routes.LOGIN,
  page: () => const LoginView(),
  binding: LoginBinding(),
  transition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 300),
)
```

### Navigation

```dart
// 로그인 화면으로 이동
Get.toNamed(Routes.LOGIN);

// 로그인 성공 후 메인 화면 (이전 화면 스택 제거)
Get.offAllNamed(Routes.HOME);

// 뒤로가기
Get.back();
```

---

## 성능 최적화 전략

### const 생성자

```dart
// ✅ 정적 위젯은 const 사용
const SizedBox(height: 16)
const EdgeInsets.symmetric(horizontal: 24)

// ✅ Obx는 버튼별로 개별 적용
Obx(() => SocialLoginButton(
  isLoading: controller.isKakaoLoading.value,
  onPressed: controller.handleKakaoLogin,
))
```

### Obx 범위 최소화

```dart
// ❌ Bad - 전체 화면 rebuild
Obx(() => Scaffold(
  body: Column(
    children: [
      SocialLoginButton(...),
      SocialLoginButton(...),
    ],
  ),
))

// ✅ Good - 버튼별 독립 rebuild
Column(
  children: [
    Obx(() => SocialLoginButton(
      isLoading: controller.isKakaoLoading.value,
      onPressed: controller.handleKakaoLogin,
    )),
    Obx(() => SocialLoginButton(
      isLoading: controller.isNaverLoading.value,
      onPressed: controller.handleNaverLogin,
    )),
  ],
)
```

### Material InkWell 최적화

- `InkWell`의 `borderRadius`를 `Container`의 `borderRadius`와 일치시켜 Ripple 효과 정확히 표시
- `Material` 위젯으로 감싸서 InkWell 효과 활성화

---

## 에러 처리 전략

### Exception 클래스 정의 필요 여부

**필요한 Exception 클래스**:

1. **AuthException** (인증 오류)
   - 위치: `packages/core/lib/src/exceptions/auth_exception.dart`
   - 용도: 소셜 로그인 실패, 토큰 만료, 권한 거부 등
   - 필드: `String code`, `String message`

2. **NetworkException** (네트워크 오류)
   - 위치: `packages/core/lib/src/exceptions/network_exception.dart`
   - 용도: 네트워크 연결 실패, 타임아웃 등
   - 필드: `String message`, `int? statusCode`

**Senior Developer가 먼저 구현해야 합니다.**

### Controller 에러 처리

```dart
/// 카카오 로그인 처리
Future<void> handleKakaoLogin() async {
  try {
    isKakaoLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepository.loginWithKakao();
    Get.offAllNamed(Routes.HOME);

  } on NetworkException catch (e) {
    // 네트워크 오류
    errorMessage.value = '네트워크 연결을 확인해주세요';
    _showErrorSnackbar('로그인 실패', errorMessage.value);

  } on AuthException catch (e) {
    // 인증 오류 (사용자 취소, 권한 거부 등)
    if (e.code == 'user_cancelled') {
      // 사용자가 취소한 경우 - 에러로 처리하지 않음
      return;
    }
    errorMessage.value = e.message;
    _showErrorSnackbar('로그인 실패', errorMessage.value);

  } catch (e) {
    // 기타 오류
    errorMessage.value = '로그인 중 오류가 발생했습니다';
    _showErrorSnackbar('로그인 실패', errorMessage.value);

  } finally {
    isKakaoLoading.value = false;
  }
}
```

### View 에러 표시

```dart
// GetX Snackbar 사용 (Controller에서 호출)
Get.snackbar(
  '로그인 실패',
  errorMessage.value,
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.red.shade100,
  colorText: Colors.red.shade900,
  icon: Icon(Icons.error_outline, color: Colors.red.shade900),
  margin: EdgeInsets.all(16),
  borderRadius: 8,
  duration: Duration(seconds: 3),
);
```

---

## 패키지 의존성

### pubspec.yaml 수정

**파일**: `packages/design_system/pubspec.yaml`

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
    - packages/design_system/assets/social_login/
```

### melos bootstrap 실행

```bash
cd /Users/lms/dev/repository/app_gaegulzip
melos bootstrap
```

---

## 에셋 리소스 준비

### 로고 SVG 파일

**위치**: `packages/design_system/assets/social_login/`

#### 필요한 파일

1. **kakao_symbol.svg** (20x20px)
   - 카카오 말풍선 심볼
   - 검은색 단색
   - 다운로드: https://developers.kakao.com/tool/resource/login

2. **naver_logo.svg** (20x20px)
   - 네이버 N 로고
   - 흰색 단색
   - 다운로드: 네이버 개발자센터

3. **apple_logo.svg** (20x20px)
   - 애플 심볼
   - 흰색/검은색 2개 버전 필요 (또는 코드에서 colorFilter 사용)
   - 다운로드: https://developer.apple.com/design/resources/

4. **google_logo.svg** (20x20px)
   - 구글 G 로고
   - 4색 버전 (변경 불가)
   - 다운로드: https://developers.google.com/identity/branding-guidelines

---

## 작업 분배 계획 (CTO가 참조)

### Senior Developer 작업

**우선순위 1: Exception 클래스**
1. `AuthException` 클래스 작성
   - `packages/core/lib/src/exceptions/auth_exception.dart`

2. `NetworkException` 클래스 작성
   - `packages/core/lib/src/exceptions/network_exception.dart`

**우선순위 2: 컴포넌트 구현**
1. `SocialLoginButton` 위젯 작성
   - `packages/design_system/lib/src/widgets/social_login_button.dart`
   - Material + InkWell 기반 구현
   - 플랫폼별 스펙 정확히 적용

2. Enum 클래스 작성
   - `SocialLoginPlatform` enum
   - `SocialLoginButtonSize` enum
   - `AppleSignInStyle` enum

3. 에셋 리소스 준비
   - 로고 SVG 파일 다운로드
   - `packages/design_system/assets/social_login/` 폴더에 배치
   - `pubspec.yaml`에 flutter_svg 추가 및 assets 등록

4. Controller 작성
   - `LoginController` 구현
   - 로딩 상태 관리
   - 에러 처리 로직

5. Binding 작성
   - `LoginBinding` 구현

**예상 소요 시간**: 4-6시간

**참고**: 이 작업에서는 **melos generate 불필요** (API 모델 사용 안 함)

### Junior Developer 작업

**우선순위 2: View 구현**
1. `LoginView` 작성
   - Scaffold + SafeArea 구조
   - 4개 버튼 배치 (세로 나열)
   - Obx로 로딩 상태 반영

2. Routing 업데이트
   - `app_routes.dart`에 LOGIN 추가
   - `app_pages.dart`에 GetPage 등록

**예상 소요 시간**: 2-3시간

### 작업 의존성

- Junior는 Senior의 `SocialLoginButton` 위젯 완성 후 시작
- Senior가 먼저 커밋 후 Junior가 View 구현
- Controller의 메서드명과 .obs 변수명 정확히 일치시켜야 함

---

## 검증 기준

### 기능 검증
- [ ] 4개 플랫폼 버튼이 각각 정확히 렌더링됨
- [ ] 로딩 상태에서 CircularProgressIndicator 표시
- [ ] 버튼 클릭 시 onPressed 콜백 호출
- [ ] 각 플랫폼별 독립적인 로딩 상태 관리

### 디자인 검증
- [ ] 카카오: 노란 배경, 검은 텍스트, 말풍선 로고
- [ ] 네이버: 녹색 배경, 흰 텍스트, N 로고
- [ ] 애플: 검은/흰 배경 선택 가능, 대비 텍스트, 애플 로고
- [ ] 구글: 흰 배경, 회색 테두리, 4색 G 로고
- [ ] 각 플랫폼 공식 border-radius 적용

### 성능 검증
- [ ] Obx 범위가 버튼별로 최소화됨
- [ ] const 생성자 적용 (가능한 위젯)
- [ ] 불필요한 rebuild 없음

### 접근성 검증
- [ ] 최소 터치 영역 44x44dp 충족 (Large 버튼)
- [ ] 색상 대비 WCAG AA 기준 충족
- [ ] Semantics 레이블 제공 (선택사항)

### 코드 품질
- [ ] GetX 패턴 준수 (Controller, View, Binding)
- [ ] 에러 처리 완비
- [ ] 모든 public API에 JSDoc 주석 (한글)
- [ ] CLAUDE.md 표준 준수

---

## 중요 수정 사항 요약

### ❌ 제거된 것들
1. **Sketch 스타일 완전 제거**
   - SketchPainter 사용 금지
   - SketchButton 기반 구현 금지
   - roughness, seed, noise texture 파라미터 없음

2. **CustomPaint 사용 금지**
   - 손그림 효과 제거
   - 불규칙한 테두리 제거

### ✅ 추가/변경된 것들
1. **표준 Material 위젯 사용**
   - Material + InkWell + Container 조합
   - 표준 BorderRadius (각 플랫폼 공식 스펙)
   - 표준 Border.all (테두리)

2. **각 플랫폼 공식 가이드라인만 준수**
   - 카카오: borderRadius 12px, padding 16/32
   - 네이버: borderRadius 8px
   - 애플: borderRadius 6px
   - 구글: borderRadius 4px, border 1px

3. **flutter_svg 유지**
   - 로고 렌더링에 필수
   - SVG 파일 assets에 배치

4. **GetX 패턴 유지**
   - Controller, View, Binding 분리
   - Obx로 반응형 UI

5. **JSDoc 주석 추가 (한글)**
   - 모든 public API에 적용
   - Controller 메서드
   - .obs 변수
   - 위젯 파라미터

6. **Exception 클래스 정의 명시**
   - AuthException, NetworkException
   - Senior Developer 우선 작업

7. **melos generate 불필요 명시**
   - API 모델 사용 안 함
   - build_runner 실행 불필요

---

## 다음 단계

1. **Senior Developer**: Exception 클래스 → `SocialLoginButton` 위젯 구현
2. **Junior Developer**: `LoginView` 화면 구현
3. **CTO**: 코드 리뷰 및 플랫폼 가이드라인 준수 검증
4. **QA**: 각 플랫폼 디자인 가이드라인 체크리스트 검증

---

## 참고 자료

### 공식 디자인 가이드라인
- [카카오 로그인 디자인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide)
- [네이버 로그인 버튼 가이드](https://developers.naver.com/docs/login/bi/bi.md)
- [Apple Sign In HIG](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)
- [Google Sign-In Branding](https://developers.google.com/identity/branding-guidelines)

### 내부 가이드
- `.claude/guides/getx_best_practices.md`
- `.claude/guides/common_patterns.md`
- `CLAUDE.md` (프로젝트 표준)
