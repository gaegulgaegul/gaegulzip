# UI/UX 디자인 명세: wowa 로그인 화면 SDK 재사용성 개선

## 개요

로그인 화면 컴포넌트(LoginView, LoginController, LoginBinding)를 auth_sdk 패키지로 이동하여 모든 앱에서 동일한 로그인 경험을 재사용할 수 있도록 합니다. Frame0 스케치 스타일을 유지하면서 SDK 독립성을 보장하고, 앱별 커스터마이징(homeRoute, showBrowseButton)을 지원합니다.

**디자인 목표**: 소셜 로그인 버튼의 브랜드 가이드라인을 준수하면서, 일관된 에러 피드백과 로딩 상태 표시로 직관적인 사용자 경험을 제공합니다.

## 화면 구조

### Screen 1: 로그인 화면 (LoginView)

#### 레이아웃 계층

```
Scaffold
└── Body: SafeArea
    └── Center
        └── Padding (horizontal: 24, vertical: 32)
            └── Column (mainAxisAlignment: center)
                ├── SizedBox(height: 64)
                │
                ├── Text (타이틀 - "로그인")
                │   ├── fontSize: 30px
                │   ├── fontWeight: bold
                │   └── color: base900 (#343434)
                │
                ├── SizedBox(height: 8)
                │
                ├── Text (부제목 - "소셜 계정으로 간편하게 시작하세요")
                │   ├── fontSize: 14px
                │   └── color: base700 (#5E5E5E) (다크모드: base400)
                │
                ├── SizedBox(height: 48)
                │
                ├── Obx: SocialLoginButton (카카오)
                │   ├── platform: SocialLoginPlatform.kakao
                │   ├── size: SocialLoginButtonSize.large
                │   ├── isLoading: controller.isKakaoLoading.value
                │   └── onPressed: controller.handleKakaoLogin
                │
                ├── SizedBox(height: 16)
                │
                ├── Obx: SocialLoginButton (네이버)
                │   ├── platform: SocialLoginPlatform.naver
                │   ├── size: SocialLoginButtonSize.large
                │   ├── isLoading: controller.isNaverLoading.value
                │   └── onPressed: controller.handleNaverLogin
                │
                ├── SizedBox(height: 16)
                │
                ├── Obx: SocialLoginButton (애플)
                │   ├── platform: SocialLoginPlatform.apple
                │   ├── appleStyle: AppleSignInStyle.dark
                │   ├── size: SocialLoginButtonSize.large
                │   ├── isLoading: controller.isAppleLoading.value
                │   └── onPressed: controller.handleAppleLogin
                │
                ├── SizedBox(height: 16)
                │
                ├── Obx: SocialLoginButton (구글)
                │   ├── platform: SocialLoginPlatform.google
                │   ├── size: SocialLoginButtonSize.large
                │   ├── isLoading: controller.isGoogleLoading.value
                │   └── onPressed: controller.handleGoogleLogin
                │
                ├── Spacer
                │
                └── if (showBrowseButton)  // SDK 설정으로 제어
                    TextButton ("둘러보기")
                    ├── onPressed: () => Get.toNamed(homeRoute)
                    └── style: TextButton 기본 스타일
```

#### 위젯 상세

**Text (타이틀)**
- 텍스트: "로그인"
- fontSize: 30px (SketchDesignTokens.fontSize3Xl)
- fontWeight: FontWeight.bold
- color: SketchDesignTokens.base900 (#343434)
- 정렬: 중앙 (Column의 crossAxisAlignment 기본값)

**Text (부제목)**
- 텍스트: "소셜 계정으로 간편하게 시작하세요"
- fontSize: 14px (SketchDesignTokens.fontSizeSm)
- color: SketchDesignTokens.base700 (#5E5E5E) (다크모드: base400)
- 정렬: 중앙

**SocialLoginButton (카카오)**
- platform: SocialLoginPlatform.kakao
- size: SocialLoginButtonSize.large (높이: 56px)
- backgroundColor: #FEE500 (카카오 옐로우)
- textColor: #000000
- 로고: assets/social_login/kakao_symbol.svg (24px)
- 기본 텍스트: "카카오 계정으로 로그인"
- borderRadius: 12px
- isLoading: controller.isKakaoLoading.value (Obx로 반응형)
  - true일 때: CircularProgressIndicator (20px, 검은색) 표시
  - false일 때: 로고 + 텍스트
- onPressed: controller.handleKakaoLogin
- 로딩 중 다른 버튼 클릭 불가: isLoading이 true이면 onTap: null

**SocialLoginButton (네이버)**
- platform: SocialLoginPlatform.naver
- size: SocialLoginButtonSize.large (높이: 56px)
- backgroundColor: #03C75A (네이버 그린)
- textColor: #FFFFFF
- 로고: assets/social_login/naver_logo.svg (24px)
- 기본 텍스트: "네이버 계정으로 로그인"
- borderRadius: 8px
- isLoading: controller.isNaverLoading.value
- onPressed: controller.handleNaverLogin

**SocialLoginButton (애플)**
- platform: SocialLoginPlatform.apple
- appleStyle: AppleSignInStyle.dark (다크 스타일)
- size: SocialLoginButtonSize.large (높이: 56px)
- backgroundColor: #000000
- textColor: #FFFFFF
- 로고: assets/social_login/apple_logo.svg (24px, 흰색 필터)
- 기본 텍스트: "Apple로 로그인"
- borderRadius: 6px
- isLoading: controller.isAppleLoading.value
- onPressed: controller.handleAppleLogin

**SocialLoginButton (구글)**
- platform: SocialLoginPlatform.google
- size: SocialLoginButtonSize.large (높이: 56px)
- backgroundColor: #FFFFFF
- borderColor: #DCDCDC (밝은 회색)
- borderWidth: 1px
- textColor: #000000
- 로고: assets/social_login/google_logo.svg (24px)
- 기본 텍스트: "Google 계정으로 로그인"
- borderRadius: 4px
- isLoading: controller.isGoogleLoading.value
- onPressed: controller.handleGoogleLogin

**TextButton (둘러보기)**
- 표시 조건: SDK 초기화 시 showBrowseButton = true로 설정된 경우만
- 텍스트: "둘러보기"
- onPressed: () => Get.toNamed(homeRoute)
  - homeRoute는 SDK 초기화 시 주입받은 라우트 (기본값: '/home')
- style: TextButton 기본 스타일
  - color: SketchDesignTokens.accentPrimary (#DF7D5F)
  - fontSize: 14px
- 위치: 화면 하단 (Spacer 다음)

### Screen 2: 계정 충돌 모달 (SketchModal)

#### 레이아웃 계층

```
SketchModal
├── title: "다른 계정으로 가입되어 있습니다"
│   ├── fontSize: 18px (SketchDesignTokens.fontSizeLg)
│   ├── fontWeight: FontWeight.w600
│   └── color: SketchDesignTokens.base900
│
├── child: Column (crossAxisAlignment: start)
│   └── Text
│       ├── "이 이메일은 {providerName} 계정으로 가입되어 있습니다. 계정을 연동하시겠습니까?"
│       ├── fontSize: 14px
│       ├── color: SketchDesignTokens.base700 (#5E5E5E)
│       ├── fontWeight: FontWeight.w400
│       └── height: 1.5 (lineHeight)
│
├── actions: Row (spacing: 8px)
│   ├── SketchButton (취소)
│   │   ├── text: "취소"
│   │   ├── style: SketchButtonStyle.outline
│   │   └── onPressed: Navigator.pop(context)
│   │
│   └── SketchButton (연동하기)
│       ├── text: "연동하기"
│       ├── style: SketchButtonStyle.primary
│       └── onPressed: 계정 연동 로직 (현재 미구현, TODO 표시)
│
├── barrierDismissible: false (외부 클릭으로 닫기 불가)
├── width: 340px
└── showCloseButton: true (기본 X 버튼)
```

#### 위젯 상세

**SketchModal**
- title: "다른 계정으로 가입되어 있습니다"
- width: 340px
- barrierDismissible: false
- fillColor: Colors.white (기본값)
- borderColor: SketchDesignTokens.base300 (기본값)
- strokeWidth: SketchDesignTokens.strokeStandard (2px)
- 애니메이션: ScaleTransition + FadeTransition (250ms, Curves.easeOutBack)

**Text (모달 내용)**
- 텍스트: "이 이메일은 {providerName} 계정으로 가입되어 있습니다. 계정을 연동하시겠습니까?"
  - {providerName}: "카카오", "네이버", "애플", "구글" (한글 변환)
- fontSize: 14px
- color: SketchDesignTokens.base700 (#5E5E5E)
- fontWeight: FontWeight.w400
- height: 1.5 (lineHeight)

**SketchButton (취소)**
- text: "취소"
- style: SketchButtonStyle.outline
  - backgroundColor: transparent
  - borderColor: SketchDesignTokens.base300
  - textColor: SketchDesignTokens.base700
- onPressed: Navigator.of(context).pop()

**SketchButton (연동하기)**
- text: "연동하기"
- style: SketchButtonStyle.primary
  - backgroundColor: SketchDesignTokens.accentPrimary (#DF7D5F)
  - textColor: Colors.white
- onPressed:
  - Navigator.pop(context)
  - 현재: 성공 스낵바 표시 ("준비 중", "계정 연동 기능은 향후 추가됩니다")
  - 향후: 계정 연동 API 호출

## 색상 팔레트 (Frame0 Sketch Style)

### Primary Colors
- **accentPrimary**: `#DF7D5F` - Frame0 시그니처 코랄/오렌지
  - 용도: 둘러보기 텍스트 버튼, 모달 주요 액션 버튼
- **accentLight**: `#F19E7E` - 밝은 코랄
  - 용도: 버튼 hover 상태 (현재 미사용)
- **accentDark**: `#C86947` - 어두운 코랄
  - 용도: 버튼 pressed 상태 (현재 미사용)

### Grayscale Colors
- **base900**: `#343434` - 거의 검은색
  - 용도: 타이틀 텍스트, 모달 제목
- **base700**: `#5E5E5E` - 어두운 회색
  - 용도: 모달 본문 텍스트, 아웃라인 버튼 텍스트
- **base500**: `#8E8E8E` - 중간 회색
  - 용도: 비활성 텍스트
- **base300**: `#DCDCDC` - 밝은 회색
  - 용도: 구글 버튼 테두리, 모달 테두리, 아웃라인 버튼 테두리
- **base100**: `#F7F7F7` - 거의 흰색
  - 용도: 배경 (현재 미사용)
- **white**: `#FFFFFF` - 순수 흰색
  - 용도: 구글/애플 라이트 버튼 배경, 모달 배경

### Social Login Brand Colors (가이드라인 준수)
- **카카오 옐로우**: `#FEE500` - 카카오 공식 브랜드 색상
  - 용도: 카카오 버튼 배경
  - 텍스트: #000000 (검은색)
- **네이버 그린**: `#03C75A` - 네이버 공식 브랜드 색상
  - 용도: 네이버 버튼 배경
  - 텍스트: #FFFFFF (흰색)
- **애플 블랙**: `#000000` - 애플 다크 스타일
  - 용도: 애플 버튼 배경 (dark)
  - 텍스트: #FFFFFF (흰색)
- **구글 화이트**: `#FFFFFF` - 구글 공식 스타일
  - 용도: 구글 버튼 배경
  - 텍스트: #000000 (검은색)
  - 테두리: #DCDCDC (밝은 회색)

### Semantic Colors (에러/성공 피드백)
- **error**: `#F44336` - Material 3 에러 색상 (또는 `#B00020`)
  - 용도: 에러 스낵바 배경
- **success**: `#4CAF50` - 녹색
  - 용도: 성공 스낵바 배경 (#4CAF50 또는 Colors.green.shade700)
- **warning**: `#FFC107` - 노란색
  - 용도: 경고 스낵바 배경 (현재 미사용)
- **info**: `#2196F3` - 파란색
  - 용도: 정보 스낵바 배경 (현재 미사용)

## 타이포그래피 (Frame0 Design Tokens)

### 텍스트 스타일

**Title (타이틀 - "로그인")**
- fontFamily: Loranthus (SketchDesignTokens.fontFamilyHand)
- fontSize: 30px (SketchDesignTokens.fontSize3Xl)
- fontWeight: FontWeight.bold (700)
- height: 1.25 (tight)
- color: SketchDesignTokens.base900 (#343434)

**Subtitle (부제목)**
- fontFamily: Loranthus (SketchDesignTokens.fontFamilyHand)
- fontSize: 14px (SketchDesignTokens.fontSizeSm)
- fontWeight: FontWeight.w400 (regular)
- height: 1.5 (normal)
- color: SketchDesignTokens.base700 (#5E5E5E) (다크모드: base400)

**Button Label (버튼 텍스트)**
- fontFamily: Roboto
- fontSize: 17px (large 버튼)
- fontWeight: FontWeight.w500 (medium)
- color: 플랫폼별 textColor (카카오: 검은색, 네이버: 흰색 등)

**Modal Title (모달 제목)**
- fontFamily: Roboto
- fontSize: 18px (SketchDesignTokens.fontSizeLg)
- fontWeight: FontWeight.w600 (semibold)
- color: SketchDesignTokens.base900 (#343434)

**Modal Body (모달 본문)**
- fontFamily: Roboto
- fontSize: 14px (SketchDesignTokens.fontSizeSm)
- fontWeight: FontWeight.w400 (regular)
- height: 1.5 (normal)
- color: SketchDesignTokens.base700 (#5E5E5E)

**TextButton (둘러보기)**
- fontFamily: Roboto
- fontSize: 14px
- fontWeight: FontWeight.w500
- color: SketchDesignTokens.accentPrimary (#DF7D5F)

## 스페이싱 시스템 (8dp 그리드)

### Padding/Margin

- **화면 패딩**: EdgeInsets.symmetric(horizontal: 24, vertical: 32)
- **타이틀 상단 여백**: 64px (SketchDesignTokens.spacing4Xl)
- **타이틀-부제목 간격**: 8px (SketchDesignTokens.spacingSm)
- **부제목-첫 버튼 간격**: 48px (SketchDesignTokens.spacing3Xl)
- **버튼 간 간격**: 16px (SketchDesignTokens.spacingLg)
- **모달 내부 패딩**: 16px (SketchDesignTokens.spacingLg)
- **모달 헤더-본문 간격**: 12px (SketchDesignTokens.spacingMd)
- **모달 본문-액션 간격**: 16px (SketchDesignTokens.spacingLg)
- **모달 액션 버튼 간격**: 8px (SketchDesignTokens.spacingSm)

### 컴포넌트 크기

**SocialLoginButton (large)**
- height: 56px
- horizontalPadding: 24px
- verticalPadding: 12px
- logoSize: 24px
- fontSize: 17px

**TextButton (둘러보기)**
- minHeight: 48px (터치 영역)
- padding: 8px (기본값)

**SketchModal**
- width: 340px
- padding: 16px
- borderRadius: 8px
- strokeWidth: 2px

## Border Radius (플랫폼별 가이드라인 준수)

- **카카오 버튼**: 12px (카카오 공식 가이드라인)
- **네이버 버튼**: 8px (네이버 권장)
- **애플 버튼**: 6px (Apple HIG 권장)
- **구글 버튼**: 4px (Google 권장)
- **모달**: 8px (SketchDesignTokens.borderRadiusLg)
- **모달 닫기 버튼**: 4px

## Elevation (그림자)

소셜 로그인 버튼은 **브랜드 가이드라인을 준수**하므로 스케치 스타일 그림자를 사용하지 않습니다. 대신 플랫폼별 elevation을 적용합니다.

- **SocialLoginButton**: elevation 없음 (Material elevation: 0)
  - InkWell의 ripple 효과만 사용
- **SketchModal**: elevation 없음 (투명 배경 Dialog)
  - 테두리로 구분
- **스낵바**: Material 기본 elevation (6)

## 인터랙션 상태

### SocialLoginButton 상태

**Default (기본)**
- 배경: 플랫폼별 브랜드 색상
- 테두리: 플랫폼별 (카카오/네이버: 없음, 구글/애플 라이트: 있음)
- 로고 + 텍스트 표시

**Pressed (눌렸을 때)**
- InkWell의 ripple effect (기본값)
- splashColor: 플랫폼별 textColor 12% 투명도
- highlightColor: 플랫폼별 textColor 8% 투명도

**Loading (로딩 중)**
- 배경: 플랫폼별 브랜드 색상 유지
- 내용: CircularProgressIndicator (20x20px) 표시
  - color: 플랫폼별 textColor
  - strokeWidth: 2.0
- 다른 버튼: 클릭 비활성화 (onTap: null)

**Disabled (비활성화)**
- 현재 미사용 (로그인 화면에서는 로딩 중에만 상호작용 차단)

### TextButton (둘러보기) 상태

**Default**
- textColor: SketchDesignTokens.accentPrimary (#DF7D5F)

**Pressed**
- TextButton 기본 ripple effect
- overlayColor: SketchDesignTokens.accentPrimary 12% 투명도

### SketchModal 상태

**Appearing (나타날 때)**
- ScaleTransition: 0.0 → 1.0 (Curves.easeOutBack)
- FadeTransition: 0.0 → 1.0 (Curves.easeOut)
- duration: 250ms

**Dismissing (사라질 때)**
- 역방향 애니메이션 (reverse)
- duration: 250ms

### 터치 피드백

- **Ripple Effect**: Material InkWell 기본 ripple
- **Splash Color**: 플랫폼별 textColor 12% 투명도
- **Highlight Color**: 플랫폼별 textColor 8% 투명도
- **최소 터치 영역**: 48x48dp (Material Design 가이드라인)

## 애니메이션

### 로딩 인디케이터 (CircularProgressIndicator)

- **사이즈**: 20x20px
- **strokeWidth**: 2.0
- **color**: 플랫폼별 textColor
- **애니메이션**: Material 기본 회전 애니메이션 (무한 반복)
- **위치**: 버튼 중앙 (로고 + 텍스트 대신 표시)

### 모달 애니메이션 (SketchModal)

**진입 애니메이션**
- ScaleTransition: 0.0 → 1.0
  - curve: Curves.easeOutBack (약간 튀는 효과)
  - duration: 250ms
- FadeTransition: 0.0 → 1.0
  - curve: Curves.easeOut
  - duration: 250ms

**퇴장 애니메이션**
- 진입의 역방향
- duration: 250ms

### 버튼 피드백 애니메이션

**모달 닫기 버튼 (X)**
- AnimatedScale: 1.0 → 0.95 (눌렸을 때)
- duration: 100ms
- backgroundColor: transparent → base200

**스낵바**
- Material 기본 슬라이드 인/아웃 애니메이션
- position: bottom
- duration: 3초 (표시 시간)

## 반응형 레이아웃

### Breakpoints

이 화면은 **모바일 전용**이므로 별도 breakpoint 없이 세로 모드 1열 레이아웃만 지원합니다.

- **Mobile**: width < 600dp (기본)
- **Tablet/Desktop**: 미지원 (모바일 앱 전용)

### 적응형 레이아웃 전략

**세로 모드 (Portrait)**
- Column 레이아웃 (기본)
- 타이틀 → 부제목 → 버튼 4개 → Spacer → 둘러보기

**가로 모드 (Landscape)**
- 동일한 Column 레이아웃 유지
- SafeArea + Center로 화면 중앙 정렬
- 상단/하단 여백 축소 가능 (vertical: 16px)

### 터치 영역

- **최소 크기**: 48x48dp (Material Design 가이드라인)
- **SocialLoginButton (large)**: 56dp 높이 (권장 크기 이상)
- **TextButton (둘러보기)**: 48dp 최소 높이
- **모달 닫기 버튼**: 32x32dp (작은 터치 영역, 최소 40dp 권장보다 작음)
  - 개선 제안: 40x40dp 이상으로 확대

## 접근성 (Accessibility)

### 색상 대비

- **카카오 버튼**: 검은색(#000000) / 노란색(#FEE500) = 19.56:1 (AAA 등급)
- **네이버 버튼**: 흰색(#FFFFFF) / 초록색(#03C75A) = 3.76:1 (AA 등급)
- **애플 버튼**: 흰색(#FFFFFF) / 검은색(#000000) = 21:1 (AAA 등급)
- **구글 버튼**: 검은색(#000000) / 흰색(#FFFFFF) = 21:1 (AAA 등급)
- **타이틀**: base900(#343434) / 흰색(#FFFFFF) = 11.82:1 (AAA 등급)
- **부제목**: base500(#8E8E8E) / 흰색(#FFFFFF) = 3.95:1 (AA 등급)

네이버 버튼(3.76:1)을 제외한 모든 텍스트가 WCAG AA 기준(4.5:1) 이상을 충족합니다. 네이버 버튼은 대형 텍스트 AA 기준(3:1)은 충족하며, 공식 브랜드 가이드라인을 따릅니다.

### 의미 전달

- **색상만으로 의미 전달 금지**:
  - 로딩 상태: CircularProgressIndicator + 버튼 비활성화
  - 에러: 스낵바 빨간색 + 텍스트 메시지
  - 계정 충돌: 모달 + 구체적 텍스트 설명

### 스크린 리더 지원

**Semantics Label 권장**
- SocialLoginButton: "카카오 계정으로 로그인 버튼", "네이버 계정으로 로그인 버튼" 등
- TextButton (둘러보기): "둘러보기 버튼"
- 모달 닫기 버튼: "닫기 버튼"

**로딩 상태 알림**
- CircularProgressIndicator에 "로그인 중" semanticsLabel 추가 권장

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

**SocialLoginButton** ✅
- 위치: `packages/design_system/lib/src/widgets/social_login_button.dart`
- 용도: 4개 소셜 로그인 버튼 (카카오/네이버/애플/구글)
- 특징:
  - 공식 브랜드 가이드라인 준수
  - platform, size, appleStyle, isLoading, onPressed 지원
  - SVG 로고 asset 포함

**SketchModal** ✅
- 위치: `packages/design_system/lib/src/widgets/sketch_modal.dart`
- 용도: 계정 충돌 모달
- 특징:
  - Frame0 스케치 스타일 테두리
  - title, child, actions, showCloseButton 지원
  - ScaleTransition + FadeTransition 애니메이션
  - barrierDismissible 설정 가능

**SketchButton** ✅
- 위치: `packages/design_system/lib/src/widgets/sketch_button.dart`
- 용도: 모달 내 취소/연동 버튼
- 특징:
  - primary, secondary, outline 스타일
  - small, medium, large 크기
  - isLoading 상태 지원

**SketchDesignTokens** ✅
- 위치: `packages/core/lib/sketch_design_tokens.dart`
- 용도: 색상, 폰트, 간격 토큰
- 사용 예:
  - SketchDesignTokens.accentPrimary
  - SketchDesignTokens.base900
  - SketchDesignTokens.fontSize3Xl
  - SketchDesignTokens.spacingLg

### 새로운 컴포넌트 필요 여부

**없음** - 모든 UI 요소가 기존 design_system 컴포넌트로 구현 가능합니다.

- SocialLoginButton: 이미 완벽하게 구현됨
- SketchModal: 이미 완벽하게 구현됨
- SketchButton: 이미 완벽하게 구현됨
- TextButton: Flutter 기본 위젯 사용

## 에러 처리 UI

### 에러 스낵바 (GetSnackBar)

**레이아웃**
- position: SnackPosition.BOTTOM
- margin: EdgeInsets.all(16)
- borderRadius: 12px
- duration: 3초

**네트워크 오류**
- title: "네트워크 오류"
- message: "네트워크 연결을 확인해주세요"
- backgroundColor: #B00020 (error 색상)
- textColor: #FFFFFF

**서버 오류**
- title: "로그인 오류"
- message: "로그인 중 오류가 발생했습니다"
- backgroundColor: #B00020
- textColor: #FFFFFF

**권한 오류**
- title: "권한 오류"
- message: "권한을 허용해주세요"
- backgroundColor: #B00020
- textColor: #FFFFFF

**사용자 취소**
- 메시지 없음 (조용히 실패)

**계정 충돌**
- 스낵바 대신 SketchModal 표시 (상세 설명 + 해결 방법 제공)

### 성공 스낵바 (현재 계정 연동 TODO 안내용)

- title: "준비 중"
- message: "계정 연동 기능은 향후 추가됩니다"
- backgroundColor: Colors.green.shade700 (#4CAF50)
- textColor: #FFFFFF
- duration: 3초

## SDK 통합 가이드 (개발자 관점)

### SDK 초기화 설정

```dart
// app/main.dart
void main() {
  // AuthSdk 초기화
  await AuthSdk.initialize(
    AuthSdkConfig(
      appCode: 'wowa',
      apiBaseUrl: 'https://api.gaegulzip.com',
      homeRoute: '/home',
      showBrowseButton: true,
      providers: {
        SocialProvider.kakao: ProviderConfig(clientId: 'your-kakao-key'),
        SocialProvider.naver: const ProviderConfig(),
        SocialProvider.google: ProviderConfig(clientId: 'your-google-client-id'),
        SocialProvider.apple: const ProviderConfig(),
      },
    ),
  );

  runApp(MyApp());
}
```

### 라우트 등록

```dart
// app/routes/app_routes.dart
class AppRoutes {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => LoginView(),  // auth_sdk에서 export
      binding: LoginBinding(),  // auth_sdk에서 export
    ),
    GetPage(
      name: '/home',
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
```

### 앱별 커스터마이징 옵션

| 설정 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| appCode | String | ✅ | - | 앱 식별 코드 (예: 'wowa') |
| apiBaseUrl | String | ✅ | - | 서버 API 기본 URL |
| homeRoute | String | ❌ | '/home' | 로그인 성공 후 이동 라우트 |
| showBrowseButton | bool | ❌ | false | 둘러보기 버튼 표시 여부 |
| providers | Map\<SocialProvider, ProviderConfig\> | ✅ | - | 소셜 프로바이더별 설정 맵 |

## 상태 관리 (GetX)

### Controller 상태 (.obs)

```dart
class LoginController extends GetxController {
  final isKakaoLoading = false.obs;
  final isNaverLoading = false.obs;
  final isAppleLoading = false.obs;
  final isGoogleLoading = false.obs;
}
```

### View에서 반응형 바인딩 (Obx)

```dart
Obx(() => SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  isLoading: controller.isKakaoLoading.value,
  onPressed: controller.handleKakaoLogin,
))
```

### 로딩 상태 관리 흐름

1. 사용자가 버튼 클릭
2. `loadingState.value = true` → UI 업데이트 (Obx)
3. AuthSdk.login() 호출
4. 성공 시: Get.offAllNamed(homeRoute) 이동
5. 실패 시: 에러 처리 (스낵바 또는 모달)
6. finally: `loadingState.value = false` → UI 복원

## 참고 자료

### 디자인 가이드

- **Frame0 공식 문서**: https://frame0.app
- **디자인 시스템 가이드**: `.claude/guide/mobile/design_system.md`
- **디자인 토큰**: `.claude/guide/mobile/design-tokens.json`

### 브랜드 가이드라인

- **카카오 로그인 가이드**: https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide
- **네이버 로그인 가이드**: https://developers.naver.com/docs/login/bi/bi.md
- **애플 Sign in with Apple HIG**: https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple
- **구글 Sign-In Branding Guidelines**: https://developers.google.com/identity/branding-guidelines

### 구현 참조

- **기존 LoginView**: `apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`
- **기존 LoginController**: `apps/mobile/apps/wowa/lib/app/modules/login/controllers/login_controller.dart`
- **SocialLoginButton**: `apps/mobile/packages/design_system/lib/src/widgets/social_login_button.dart`
- **SketchModal**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_modal.dart`
- **auth_sdk**: `apps/mobile/packages/auth_sdk/`

### 문서

- **User Story**: `docs/wowa/wowa-login/user-story.md`
- **서버 카탈로그**: `docs/wowa/server-catalog.md`
- **모바일 카탈로그**: `docs/wowa/mobile-catalog.md`

---

**작성일**: 2026-02-10
**다음 단계**: tech-lead가 기술 아키텍처를 설계합니다.
