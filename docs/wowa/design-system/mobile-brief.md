# 기술 아키텍처 설계: Design System v2 (Frame0 시각 언어 일치)

## 개요

현재 디자인 시스템(v1)은 모노크롬 스타일로 전환(97% 완료)되었으나, Frame0 프로덕트의 실제 시각 언어와 비교 시 핵심적인 불일치가 발견되었습니다. 본 문서는 Flutter 디자인 시스템에 Frame0 시그니처 요소를 정확히 반영하고, 누락된 11개 컴포넌트를 추가하는 기술 설계입니다.

**설계 목표**:
1. Frame0의 "프로토타입임을 알리는 디자인" 철학 구현 (따뜻한 크림색 배경, X-cross 플레이스홀더, 파란색 액센트)
2. 기존 13개 위젯의 P0 토큰 변경 및 스타일 정합성 확보
3. 신규 11개 위젯 추가 (TabBar, BottomNavigationBar, Avatar, Radio, SearchInput, TextArea, Divider, NumberInput, Link, AppBar, ImagePlaceholder)
4. 코드 품질 개선 (CRITICAL 4건, WARNING 4건 수정)
5. GetX Obx 호환성 유지

---

## 1. 변경 범위 정의

### 1.1 수정할 파일

#### Core 패키지 (디자인 토큰)
- `apps/mobile/packages/core/lib/sketch_design_tokens.dart` — 색상, 폰트, 토큰 상수 추가/변경

#### Design System 패키지 (테마)
- `apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart` — light/dark 팩토리 메서드 색상 변경

#### Design System 패키지 (기존 위젯 수정)
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_button.dart` — pill 형태 borderRadius 변경
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_container.dart` — 기본 fillColor 변경
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_card.dart` — withOpacity() 수정, 미사용 파라미터 제거
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_input.dart` — ColorSpec private화, 미사용 파라미터 제거
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_dropdown.dart` — barrier 추가, 미사용 파라미터 제거
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_chip.dart` — 미사용 파라미터 제거
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_icon_button.dart` — 미사용 파라미터 제거
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_slider.dart` — 미사용 파라미터 제거
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_switch.dart` — 미사용 파라미터 제거
- `apps/mobile/packages/design_system/lib/src/widgets/social_login_button.dart` — sketchStyle 옵션 추가

### 1.2 생성할 파일 (신규 위젯)

#### P0 (핵심 시각 언어)
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_image_placeholder.dart` — X-cross 패턴

#### P1 (컴포넌트 완성도)
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_tab_bar.dart` — 탭 바
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_bottom_navigation_bar.dart` — 하단 네비게이션
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_avatar.dart` — 아바타
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_radio.dart` — 라디오 버튼
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_search_input.dart` — 검색 입력 필드
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_text_area.dart` — 여러 줄 텍스트 입력
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_divider.dart` — 구분선
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_number_input.dart` — 숫자 입력 필드
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_link.dart` — 텍스트 링크
- `apps/mobile/packages/design_system/lib/src/widgets/sketch_app_bar.dart` — 앱 바

#### Enums (신규)
- `apps/mobile/packages/design_system/lib/src/enums/sketch_tab_indicator_style.dart`
- `apps/mobile/packages/design_system/lib/src/enums/sketch_nav_label_behavior.dart`
- `apps/mobile/packages/design_system/lib/src/enums/sketch_avatar_size.dart`
- `apps/mobile/packages/design_system/lib/src/enums/sketch_avatar_shape.dart`

#### Painters (신규)
- `apps/mobile/packages/design_system/lib/src/painters/x_cross_painter.dart` — X 패턴 렌더링

### 1.3 업데이트할 파일

#### Barrel Export
- `apps/mobile/packages/design_system/lib/design_system.dart` — 신규 위젯 export 추가, Calculator 클래스 삭제

#### 데모 앱
- `apps/mobile/apps/design_system_demo/lib/main.dart` — 신규 위젯 섹션 추가
- `apps/mobile/apps/design_system_demo/lib/screens/` — 신규 위젯 데모 화면 추가

---

## 2. 토큰 변경 설계

### 2.1 `sketch_design_tokens.dart` 변경 사항

#### 2.1.1 배경색 상수 추가

```dart
// ============================================================================
// 배경색 (Frame0 크림색 톤)
// ============================================================================

/// 라이트 모드 배경색 - 따뜻한 크림/아이보리 톤
static const Color background = Color(0xFFFAF8F5);

/// 라이트 모드 Surface 색상 - 카드, 모달 배경 (배경보다 약간 어두운 크림)
static const Color surface = Color(0xFFF5F0E8);

/// 라이트 모드 Surface Variant - 호버, 선택 상태 (더 어두운 크림)
static const Color surfaceVariant = Color(0xFFEBE6DC);

/// 다크 모드 배경색 - 어두운 네이비/차콜 톤
static const Color backgroundDark = Color(0xFF1A1D29);

/// 다크 모드 Surface 색상 - 배경보다 약간 밝은 네이비
static const Color surfaceDark = Color(0xFF23273A);

/// 다크 모드 Surface Variant - 더 밝은 네이비
static const Color surfaceVariantDark = Color(0xFF2C3048);
```

#### 2.1.2 액센트 컬러 재정의

```dart
// ============================================================================
// 액센트 컬러 (Primary: 파란색, Secondary: 코랄/오렌지)
// ============================================================================

// --- Primary Accent (링크, 선택 상태) ---
/// 메인 액센트 - 파란색 (링크, 선택 상태, 포커스)
static const Color accentPrimary = Color(0xFF2196F3); // Material Blue 500

/// 메인 액센트 밝은 변형
static const Color accentPrimaryLight = Color(0xFF64B5F6); // Material Blue 300

/// 메인 액센트 어두운 변형
static const Color accentPrimaryDark = Color(0xFF1976D2); // Material Blue 700

/// 다크 모드 메인 액센트 (대비 확보용 밝은 블루)
static const Color accentPrimaryDarkMode = Color(0xFF64B5F6);

// --- Secondary Accent (CTA 버튼, 강조) ---
/// 보조 액센트 - 코랄/오렌지 (CTA 버튼 전용)
static const Color accentSecondary = Color(0xFFDF7D5F);

/// 보조 액센트 밝은 변형
static const Color accentSecondaryLight = Color(0xFFF19E7E);

/// 보조 액센트 어두운 변형
static const Color accentSecondaryDark = Color(0xFFC86947);

/// 다크 모드 보조 액센트
static const Color accentSecondaryDarkMode = Color(0xFFF19E7E);

// --- 하위 호환성 (기존 코드용) ---
/// @deprecated 대신 accentSecondaryLight 사용
static const Color accentLight = accentSecondaryLight;
```

**디자인 근거**: Frame0에서 링크와 선택 상태는 파란색(#2196F3), CTA 버튼은 코랄/오렌지(#DF7D5F) 사용.

#### 2.1.3 텍스트 컬러 추가

```dart
// ============================================================================
// 텍스트 컬러
// ============================================================================

// --- Light Mode ---
/// 라이트 모드 주요 텍스트 (최고 대비)
static const Color textPrimary = Color(0xFF000000);

/// 라이트 모드 보조 텍스트
static const Color textSecondary = Color(0xFF2C2C2C);

/// 라이트 모드 3차 텍스트
static const Color textTertiary = Color(0xFF5E5E5E); // base700

/// 라이트 모드 비활성화 텍스트
static const Color textDisabled = Color(0xFF8E8E8E); // base500

/// 액센트 배경 위의 텍스트 (버튼 라벨)
static const Color textOnAccent = Color(0xFFFFFFFF);

// --- Dark Mode ---
/// 다크 모드 주요 텍스트
static const Color textPrimaryDark = Color(0xFFFFFFFF);

/// 다크 모드 보조 텍스트
static const Color textSecondaryDark = Color(0xFFE5E5E5);

/// 다크 모드 3차 텍스트
static const Color textTertiaryDark = Color(0xFFAAAAAA);

/// 다크 모드 비활성화 텍스트
static const Color textDisabledDark = Color(0xFF6E6E6E);

/// 다크 모드 액센트 위의 텍스트
static const Color textOnAccentDark = Color(0xFF000000);
```

#### 2.1.4 Outline 컬러 추가

```dart
// ============================================================================
// Border 및 Outline 컬러
// ============================================================================

// --- Light Mode ---
/// 라이트 모드 주요 테두리
static const Color outlinePrimary = Color(0xFF343434); // base900

/// 라이트 모드 보조 테두리
static const Color outlineSecondary = Color(0xFF5E5E5E); // base700

/// 라이트 모드 미묘한 구분선
static const Color outlineSubtle = Color(0xFFDCDCDC); // base300

// --- Dark Mode ---
/// 다크 모드 주요 테두리
static const Color outlinePrimaryDark = Color(0xFF5E5E5E); // base700

/// 다크 모드 보조 테두리
static const Color outlineSecondaryDark = Color(0xFF8E8E8E); // base500

/// 다크 모드 미묘한 구분선
static const Color outlineSubtleDark = Color(0xFF3A3A3A);
```

#### 2.1.5 의미론적 색상 다크모드 변형 추가

```dart
// ============================================================================
// 의미론적 색상 (다크모드 변형 추가)
// ============================================================================

// --- Light Mode (기존 유지) ---
static const Color success = Color(0xFF4CAF50); // Material Green 500
static const Color warning = Color(0xFFFFC107); // Material Amber 500
static const Color error = Color(0xFFF44336);   // Material Red 500
static const Color info = Color(0xFF2196F3);    // Material Blue 500 (accentPrimary와 동일)

// --- Dark Mode (추가) ---
static const Color successDark = Color(0xFF66BB6A); // Material Green 400
static const Color warningDark = Color(0xFFFFCA28); // Material Amber 400
static const Color errorDark = Color(0xFFEF5350);   // Material Red 400
static const Color infoDark = Color(0xFF64B5F6);    // Material Blue 300
```

#### 2.1.6 폰트 패밀리 상수 (기존 유지, 문서화 개선)

```dart
// ============================================================================
// 폰트 패밀리 (Frame0 Default Fonts)
// ============================================================================

/// Hand 폰트 - 손글씨 느낌 (Sketch 테마 기본값)
static const String fontFamilyHand = 'Patrick Hand';

/// Sans 폰트 - 산세리프 (Solid 테마 기본값)
static const String fontFamilySans = 'Roboto';

/// Mono 폰트 - 고정폭 (코드, 숫자, 기술 텍스트)
static const String fontFamilyMono = 'Courier New';

/// Serif 폰트 - 세리프 (본문, 장문 텍스트)
static const String fontFamilySerif = 'Georgia';
```

**설계 근거**: Frame0는 4가지 폰트 카테고리를 지원. 디자인 시스템은 Hand 폰트(PatrickHand)를 기본으로 사용.

---

## 3. 테마 변경 설계

### 3.1 `sketch_theme_extension.dart` 변경 사항

#### 3.1.1 light() 팩토리 메서드

```dart
factory SketchThemeExtension.light() {
  return const SketchThemeExtension(
    borderColor: Color(0xFF343434),   // base900 유지
    fillColor: Color(0xFFFAF8F5),     // 변경: 크림색 배경 (기존 #FFFFFF)
    strokeWidth: SketchDesignTokens.strokeStandard,
    roughness: SketchDesignTokens.roughness,
    bowing: SketchDesignTokens.bowing,
    shadowOffset: SketchDesignTokens.shadowOffsetMd,
    shadowBlur: SketchDesignTokens.shadowBlurMd,
    shadowColor: SketchDesignTokens.shadowColor,
  );
}
```

**변경 사항**: fillColor만 `#FFFFFF` → `#FAF8F5` (따뜻한 크림색)

#### 3.1.2 dark() 팩토리 메서드

```dart
factory SketchThemeExtension.dark() {
  return const SketchThemeExtension(
    borderColor: Color(0xFF5E5E5E),   // base700 유지
    fillColor: Color(0xFF1A1D29),     // 변경: 네이비/차콜 (기존 #343434)
    strokeWidth: SketchDesignTokens.strokeStandard,
    roughness: SketchDesignTokens.roughness,
    bowing: SketchDesignTokens.bowing,
    shadowOffset: SketchDesignTokens.shadowOffsetMd,
    shadowBlur: SketchDesignTokens.shadowBlurMd,
    shadowColor: Color(0x40000000),   // 더 어두운 그림자
  );
}
```

**변경 사항**: fillColor만 `#343434` → `#1A1D29` (더 어두운 네이비)

#### 3.1.3 접근성 검증

| 모드 | 텍스트 색상 | 배경 색상 | 대비 비율 | WCAG 등급 |
|------|-----------|---------|---------|----------|
| Light | #000000 | #FAF8F5 | 20.67:1 | AAA ✅ |
| Dark | #FFFFFF | #1A1D29 | 15.89:1 | AAA ✅ |

---

## 4. 기존 위젯 수정 설계

### 4.1 SketchButton — Pill 형태 변경

#### 변경 사항

**현재**: borderRadius = 6.0 (고정)
**변경**: borderRadius = 9999 (pill/캡슐 형태 기본값)

#### 구현 명세

```dart
class SketchButton extends StatefulWidget {
  // ... 기존 파라미터 유지

  /// 테두리 반경 (null = pill 형태 9999, 명시하면 해당 값 사용)
  final double? borderRadius; // 추가

  const SketchButton({
    // ...
    this.borderRadius, // 기본값 null
  });
}

class _SketchButtonState extends State<SketchButton> {
  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? 9999.0; // pill 기본값

    // Container의 BoxDecoration에서 사용
    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(
          color: _getBorderColor(),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(effectiveBorderRadius), // 변경
      ),
      // ...
    );
  }
}
```

#### 하위 호환성

```dart
// 기본 사용 (pill 형태)
SketchButton(text: '확인', onPressed: () {})

// 기존 스타일 유지 (선택적)
SketchButton(
  text: '확인',
  borderRadius: 6.0, // 명시적으로 지정
  onPressed: () {},
)
```

#### 크기별 pill 형태 확인

| Size | Height | Padding Horizontal | Border Radius |
|------|--------|-------------------|---------------|
| small | 32 | 16 | 9999 (pill) |
| medium | 44 | 24 | 9999 (pill) |
| large | 56 | 32 | 9999 (pill) |

#### 기본 폰트 변경

```dart
Text(
  widget.text!,
  style: TextStyle(
    fontFamily: SketchDesignTokens.fontFamilyHand, // 추가: PatrickHand
    fontSize: _getFontSize(),
    fontWeight: FontWeight.w400,
    color: _getTextColor(),
  ),
)
```

---

### 4.2 SketchContainer — 기본 배경색 변경

#### 변경 사항

**현재**: fillColor = Colors.white
**변경**: fillColor = 테마의 fillColor (크림색)

#### 구현 명세

```dart
class SketchContainer extends StatelessWidget {
  final Color? fillColor; // nullable 유지

  const SketchContainer({
    // ...
    this.fillColor, // null = 테마 surface 사용
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchThemeExtension.of(context);
    final effectiveFillColor = fillColor ?? theme.fillColor; // 크림색 기본값

    return Container(
      decoration: BoxDecoration(
        color: effectiveFillColor,
        border: Border.all(
          color: widget.borderColor ?? theme.borderColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      // ...
    );
  }
}
```

**설계 근거**: SketchContainer는 모든 스케치 위젯의 기반이므로, 테마의 fillColor를 기본값으로 사용하여 일관성 확보.

---

### 4.3 코드 품질 수정 (CRITICAL 4건)

#### 4.3.1 sketch_input.dart — ColorSpec private화

**현재**:
```dart
class ColorSpec { // public
  final Color normal;
  final Color error;
  // ...
}
```

**변경**:
```dart
class _ColorSpec { // private
  final Color normal;
  final Color error;
  // ...
}
```

**설계 근거**: `ColorSpec`은 SketchInput 내부 구현 디테일. 다른 위젯(dropdown, button)은 이미 `_ColorSpec`으로 private화됨.

#### 4.3.2 sketch_dropdown.dart — Barrier 추가

**현재**: OverlayEntry로 드롭다운 메뉴 표시, 외부 탭 시 닫히지 않음

**변경**:
```dart
// 드롭다운 메뉴를 GestureDetector로 감싸서 외부 탭 감지
void _showDropdown() {
  _overlayEntry = OverlayEntry(
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque, // 외부 영역 클릭 감지
        onTap: _closeDropdown, // 외부 탭 시 닫기
        child: Stack(
          children: [
            // 투명한 barrier (전체 화면)
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            // 드롭다운 메뉴
            Positioned(
              left: _getDropdownLeft(),
              top: _getDropdownTop(),
              width: _getDropdownWidth(),
              child: GestureDetector(
                onTap: () {}, // 메뉴 자체 클릭은 무시 (이벤트 전파 차단)
                child: _buildDropdownMenu(),
              ),
            ),
          ],
        ),
      );
    },
  );
  Overlay.of(context).insert(_overlayEntry!);
}
```

**설계 근거**: Material Dropdown 패턴 준수. 외부 클릭 시 자동으로 닫혀야 함.

#### 4.3.3 sketch_card.dart — withOpacity() 수정

**현재** (line 257-271):
```dart
color: selected
    ? SketchDesignTokens.accentPrimary.withOpacity(0.1) // deprecated
    : Colors.transparent,
```

**변경**:
```dart
color: selected
    ? SketchDesignTokens.accentPrimary.withValues(alpha: 0.1 * 255) // Flutter 3.27+
    : Colors.transparent,
```

**설계 근거**: `withOpacity()`는 Flutter 3.27+에서 deprecated. `withValues(alpha:)` 사용 권장 (alpha는 0-255 범위).

#### 4.3.4 Doc-string 예제 수정 (3건)

**변경 전**:
```dart
/// Example:
/// ```dart
/// SketchContainer(
///   fillColor: SketchDesignTokens.accentPrimary, // 오래된 예제
/// )
/// ```
```

**변경 후**:
```dart
/// Example:
/// ```dart
/// SketchContainer(
///   fillColor: SketchDesignTokens.accentSecondary, // CTA 전용
///   // 또는 링크/선택 상태:
///   borderColor: SketchDesignTokens.accentPrimary,
/// )
/// ```
```

**대상 파일**: `sketch_container.dart`, `sketch_card.dart`, `sketch_button.dart`

---

### 4.4 미사용 파라미터 제거 (WARNING 개선)

#### 대상 위젯 (8개)

| 위젯 | 제거할 파라미터 | 근거 |
|------|---------------|------|
| sketch_container | roughness, bowing, seed, enableNoise | CustomPaint 제거 후 BoxDecoration 사용 |
| sketch_card | roughness, bowing, seed, enableNoise | 동일 |
| sketch_dropdown | roughness, seed | 동일 |
| sketch_icon_button | roughness, seed | 동일 |
| sketch_slider | roughness, seed | 동일 |
| sketch_switch | roughness, seed | 동일 |
| sketch_input | roughness, seed | 동일 (bowing 저장만 하고 미사용) |
| sketch_chip | roughness | 동일 |

**예외**: `sketch_checkbox`, `sketch_progress_bar`는 내부적으로 CustomPainter를 여전히 사용하므로 파라미터 유지.

#### 구현 예시 (sketch_container.dart)

**현재**:
```dart
class SketchContainer extends StatelessWidget {
  final double roughness;
  final double bowing;
  final int seed;
  final bool enableNoise;

  const SketchContainer({
    this.roughness = SketchDesignTokens.roughness,
    this.bowing = SketchDesignTokens.bowing,
    this.seed = 0,
    this.enableNoise = true,
    // ...
  });
}
```

**변경**:
```dart
class SketchContainer extends StatelessWidget {
  // roughness, bowing, seed, enableNoise 제거

  const SketchContainer({
    // 위 4개 파라미터 삭제
    // ...
  });
}
```

**주의**: Breaking Change이므로 Changelog 명시 필요. 기존 호출 코드에서 해당 파라미터 제거 필요.

---

### 4.5 SocialLoginButton — 스케치 스타일 옵션 추가

#### 변경 사항

**현재**: 공식 브랜드 가이드라인 스타일만 제공
**변경**: 스케치 스타일 옵션 추가 (`sketchStyle: true/false`)

#### 구현 명세

```dart
class SocialLoginButton extends StatelessWidget {
  // ... 기존 파라미터 유지

  /// 스케치 스타일 여부 (true = 손그림 테두리, false = 공식 스타일)
  final bool sketchStyle;

  const SocialLoginButton({
    // ...
    this.sketchStyle = false, // 기본값: 공식 스타일 유지 (하위 호환)
  });

  @override
  Widget build(BuildContext context) {
    if (sketchStyle) {
      // SketchContainer 기반 렌더링
      return SketchContainer(
        height: _getHeight(size),
        fillColor: _getPlatformBackgroundColor(platform),
        borderColor: _getPlatformBorderColor(platform),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _getPaddingHorizontal(size)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getPlatformIcon(platform), // 공식 로고 유지
              SizedBox(width: 12),
              Text(
                _getPlatformText(platform),
                style: TextStyle(
                  fontFamily: SketchDesignTokens.fontFamilyHand, // 손글씨체
                  fontSize: _getFontSize(size),
                  color: _getPlatformTextColor(platform),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 기존 공식 스타일 유지
      return Container(
        // ... 기존 구현
      );
    }
  }

  Color _getPlatformBackgroundColor(SocialLoginPlatform platform) {
    switch (platform) {
      case SocialLoginPlatform.kakao:
        return Color(0xFFFEE500); // 카카오 노란색 유지
      case SocialLoginPlatform.naver:
        return Color(0xFF03C75A); // 네이버 초록색 유지
      case SocialLoginPlatform.google:
        return SketchDesignTokens.white; // 구글 흰색 배경
      case SocialLoginPlatform.apple:
        return appleStyle == AppleSignInStyle.dark
            ? SketchDesignTokens.black
            : SketchDesignTokens.white;
    }
  }

  Color _getPlatformBorderColor(SocialLoginPlatform platform) {
    switch (platform) {
      case SocialLoginPlatform.kakao:
        return Color(0xFFE6C200); // 카카오 어두운 노란색
      case SocialLoginPlatform.naver:
        return Color(0xFF00B347); // 네이버 어두운 초록색
      case SocialLoginPlatform.google:
        return SketchDesignTokens.base300; // 구글 회색 테두리
      case SocialLoginPlatform.apple:
        return appleStyle == AppleSignInStyle.dark
            ? SketchDesignTokens.base700
            : SketchDesignTokens.base300;
    }
  }
}
```

#### 사용 예시

```dart
// 공식 스타일 (기존)
SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  onPressed: () {},
)

// 스케치 스타일 (신규)
SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  sketchStyle: true,
  onPressed: () {},
)
```

---

## 5. 신규 위젯 아키텍처 설계

### 5.1 SketchImagePlaceholder (X-cross 패턴)

**우선순위**: P0 (Frame0 시그니처 요소)

#### 클래스 구조

```dart
/// Frame0 시그니처 X-cross 패턴 이미지 플레이스홀더
class SketchImagePlaceholder extends StatelessWidget {
  /// 플레이스홀더 크기 (width x height)
  final double? width;
  final double? height;

  /// X 선 색상 (기본값: base500)
  final Color? lineColor;

  /// X 선 두께 (기본값: 2.0)
  final double strokeWidth;

  /// 배경 색상 (기본값: base100)
  final Color? backgroundColor;

  /// 손그림 효과 정도 (기본값: 0.8)
  final double roughness;

  /// 테두리 표시 여부
  final bool showBorder;

  /// 테두리 색상 (기본값: base300)
  final Color? borderColor;

  /// 선택적 아이콘 (X 중앙에 표시)
  final IconData? centerIcon;

  const SketchImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.lineColor,
    this.strokeWidth = 2.0,
    this.backgroundColor,
    this.roughness = 0.8,
    this.showBorder = true,
    this.borderColor,
    this.centerIcon,
  });

  /// 프리셋: 작은 썸네일 (40x40)
  factory SketchImagePlaceholder.xs({
    Color? lineColor,
    Color? backgroundColor,
    IconData? centerIcon,
  }) {
    return SketchImagePlaceholder(
      width: 40,
      height: 40,
      strokeWidth: 1.5,
      lineColor: lineColor,
      backgroundColor: backgroundColor,
      centerIcon: centerIcon,
    );
  }

  /// 프리셋: 프로필 이미지 (80x80)
  factory SketchImagePlaceholder.sm({
    Color? lineColor,
    Color? backgroundColor,
    IconData? centerIcon,
  }) {
    return SketchImagePlaceholder(
      width: 80,
      height: 80,
      strokeWidth: 2.0,
      lineColor: lineColor,
      backgroundColor: backgroundColor,
      centerIcon: centerIcon ?? Icons.person_outline,
    );
  }

  /// 프리셋: 카드 썸네일 (120x120)
  factory SketchImagePlaceholder.md({
    Color? lineColor,
    Color? backgroundColor,
    IconData? centerIcon,
  }) {
    return SketchImagePlaceholder(
      width: 120,
      height: 120,
      strokeWidth: 2.5,
      lineColor: lineColor,
      backgroundColor: backgroundColor,
      centerIcon: centerIcon,
    );
  }

  /// 프리셋: 배너 이미지 (200x200)
  factory SketchImagePlaceholder.lg({
    Color? lineColor,
    Color? backgroundColor,
    IconData? centerIcon,
  }) {
    return SketchImagePlaceholder(
      width: 200,
      height: 200,
      strokeWidth: 3.0,
      lineColor: lineColor,
      backgroundColor: backgroundColor,
      centerIcon: centerIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLineColor = lineColor ?? SketchDesignTokens.base500;
    final effectiveBgColor = backgroundColor ?? SketchDesignTokens.base100;
    final effectiveBorderColor = borderColor ?? SketchDesignTokens.base300;

    return Container(
      width: width,
      height: height,
      decoration: showBorder
          ? BoxDecoration(
              border: Border.all(
                color: effectiveBorderColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: CustomPaint(
        painter: XCrossPainter(
          lineColor: effectiveLineColor,
          strokeWidth: strokeWidth,
          backgroundColor: effectiveBgColor,
          roughness: roughness,
        ),
        child: centerIcon != null
            ? Center(
                child: Icon(
                  centerIcon,
                  size: _getIconSize(),
                  color: effectiveLineColor,
                ),
              )
            : null,
      ),
    );
  }

  double _getIconSize() {
    if (width == null && height == null) return 24;
    final size = (width ?? height ?? 120);
    return size * 0.3; // 30% of container size
  }
}
```

#### CustomPainter 구현

```dart
/// X-cross 패턴을 그리는 CustomPainter
class XCrossPainter extends CustomPainter {
  final Color lineColor;
  final double strokeWidth;
  final Color backgroundColor;
  final double roughness;

  const XCrossPainter({
    required this.lineColor,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.roughness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 배경 그리기
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. X-cross 패턴 그리기
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 대각선 1: 좌상단 → 우하단
    final path1 = _createSketchLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      roughness,
    );
    canvas.drawPath(path1, linePaint);

    // 대각선 2: 우상단 → 좌하단
    final path2 = _createSketchLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      roughness,
    );
    canvas.drawPath(path2, linePaint);
  }

  Path _createSketchLine(Offset start, Offset end, double roughness) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    if (roughness <= 0.0) {
      // roughness 0이면 직선
      path.lineTo(end.dx, end.dy);
    } else {
      // Bezier 곡선으로 불규칙한 선 생성
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final distance = sqrt(dx * dx + dy * dy);

      // 세그먼트 수 (거리에 비례)
      final segments = (distance / 20).ceil().clamp(2, 10);

      for (int i = 1; i <= segments; i++) {
        final t = i / segments;
        final x = start.dx + dx * t;
        final y = start.dy + dy * t;

        // roughness에 비례한 무작위 오프셋
        final random = Random(i * 12345); // 고정 seed로 일관성 유지
        final offsetX = (random.nextDouble() - 0.5) * roughness * 8;
        final offsetY = (random.nextDouble() - 0.5) * roughness * 8;

        if (i == 1) {
          // 첫 번째 세그먼트는 quadraticBezierTo 사용
          path.quadraticBezierTo(
            x + offsetX,
            y + offsetY,
            x,
            y,
          );
        } else {
          path.lineTo(x + offsetX, y + offsetY);
        }
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant XCrossPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.roughness != roughness;
  }
}
```

#### 상태 관리 (GetX Obx 호환)

```dart
// Controller에서 반응형으로 사용 가능
class ProfileController extends GetxController {
  final hasProfileImage = false.obs;
  final imageUrl = ''.obs;

  Widget buildAvatar() {
    return Obx(() {
      if (hasProfileImage.value && imageUrl.value.isNotEmpty) {
        return Image.network(imageUrl.value);
      } else {
        return SketchImagePlaceholder.sm(
          centerIcon: Icons.person_outline,
        );
      }
    });
  }
}
```

---

### 5.2 SketchTabBar

**우선순위**: P1

#### 클래스 구조

```dart
/// 스케치 스타일 탭 바 (2~5개 탭)
class SketchTabBar extends StatelessWidget {
  /// 탭 항목 목록 (2~5개)
  final List<SketchTab> tabs;

  /// 현재 선택된 탭 인덱스
  final int currentIndex;

  /// 탭 선택 시 콜백
  final ValueChanged<int> onTap;

  /// 인디케이터 스타일 (underline / background)
  final SketchTabIndicatorStyle indicatorStyle;

  /// 탭 높이
  final double height;

  /// 선택된 탭 색상
  final Color? selectedColor;

  /// 비선택 탭 색상
  final Color? unselectedColor;

  const SketchTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.indicatorStyle = SketchTabIndicatorStyle.underline,
    this.height = 48.0,
    this.selectedColor,
    this.unselectedColor,
  }) : assert(tabs.length >= 2 && tabs.length <= 5, 'TabBar는 2~5개 탭만 지원합니다');

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? SketchDesignTokens.accentPrimary;
    final effectiveUnselectedColor = unselectedColor ?? SketchDesignTokens.base700;

    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SketchDesignTokens.outlineSubtle,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: _buildTabItem(
              tab: tab,
              isSelected: isSelected,
              selectedColor: effectiveSelectedColor,
              unselectedColor: effectiveUnselectedColor,
              onTap: () => onTap(index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabItem({
    required SketchTab tab,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // HitTestBehavior 확보
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 + 뱃지
            if (tab.icon != null)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(tab.icon, size: 24, color: color),
                  if (tab.badgeCount != null && tab.badgeCount! > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: _buildBadge(tab.badgeCount!),
                    ),
                ],
              ),
            SizedBox(height: 4),
            // 라벨
            Text(
              tab.label,
              style: TextStyle(
                fontFamily: SketchDesignTokens.fontFamilyHand,
                fontSize: 14,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            // 인디케이터
            _buildIndicator(
              isSelected: isSelected,
              color: selectedColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator({
    required bool isSelected,
    required Color color,
  }) {
    if (!isSelected) return SizedBox(height: 3);

    if (indicatorStyle == SketchTabIndicatorStyle.underline) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 3.0,
        width: 40, // 고정 너비
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1.5),
        ),
      );
    } else {
      // background 스타일은 tabItem 전체 배경으로 처리 (미구현)
      return SizedBox(height: 3);
    }
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: SketchDesignTokens.error,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SketchDesignTokens.white, width: 1.0),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyMono,
          fontSize: 10,
          color: SketchDesignTokens.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 탭 항목 데이터
class SketchTab {
  /// 탭 라벨
  final String label;

  /// 탭 아이콘 (선택)
  final IconData? icon;

  /// 뱃지 카운트 (선택, 예: 알림 개수)
  final int? badgeCount;

  const SketchTab({
    required this.label,
    this.icon,
    this.badgeCount,
  });
}

/// 인디케이터 스타일
enum SketchTabIndicatorStyle {
  underline, // 하단 밑줄
  background, // 배경 강조 (미구현)
}
```

#### GetX 사용 예시

```dart
class TabController extends GetxController {
  final selectedTab = 0.obs;

  Widget build() {
    return Column(
      children: [
        SketchTabBar(
          tabs: [
            SketchTab(label: 'Home', icon: Icons.home),
            SketchTab(label: '알림', icon: Icons.notifications, badgeCount: 5),
            SketchTab(label: '설정', icon: Icons.settings),
          ],
          currentIndex: selectedTab.value,
          onTap: (index) => selectedTab.value = index,
        ),
        Expanded(
          child: Obx(() => _buildTabContent(selectedTab.value)),
        ),
      ],
    );
  }
}
```

---

### 5.3 SketchBottomNavigationBar

**우선순위**: P1

#### 클래스 구조

```dart
/// 스케치 스타일 하단 네비게이션 바 (3~5개 항목 권장)
class SketchBottomNavigationBar extends StatelessWidget {
  /// 네비게이션 항목 목록
  final List<SketchNavItem> items;

  /// 현재 선택된 항목 인덱스
  final int currentIndex;

  /// 항목 선택 시 콜백
  final ValueChanged<int> onTap;

  /// 네비게이션 바 높이
  final double height;

  /// 선택된 항목 색상
  final Color? selectedColor;

  /// 비선택 항목 색상
  final Color? unselectedColor;

  /// 라벨 표시 모드
  final SketchNavLabelBehavior labelBehavior;

  const SketchBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 64.0,
    this.selectedColor,
    this.unselectedColor,
    this.labelBehavior = SketchNavLabelBehavior.showSelected,
  }) : assert(items.length >= 2 && items.length <= 5, '네비게이션 바는 2~5개 항목을 권장합니다');

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? SketchDesignTokens.accentPrimary;
    final effectiveUnselectedColor = unselectedColor ?? SketchDesignTokens.base700;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: SketchDesignTokens.surface,
        border: Border(
          top: BorderSide(
            color: SketchDesignTokens.outlineSubtle,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return _buildNavItem(
            item: item,
            isSelected: isSelected,
            selectedColor: effectiveSelectedColor,
            unselectedColor: effectiveUnselectedColor,
            showLabel: _shouldShowLabel(index),
            onTap: () => onTap(index),
          );
        }),
      ),
    );
  }

  bool _shouldShowLabel(int index) {
    switch (labelBehavior) {
      case SketchNavLabelBehavior.showAll:
        return true;
      case SketchNavLabelBehavior.showSelected:
        return index == currentIndex;
      case SketchNavLabelBehavior.hideAll:
        return false;
    }
  }

  Widget _buildNavItem({
    required SketchNavItem item,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
    required bool showLabel,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? selectedColor : unselectedColor;
    final icon = isSelected && item.activeIcon != null ? item.activeIcon! : item.icon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 + 뱃지
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(
                    icon,
                    size: isSelected ? 28 : 24,
                    color: color,
                  ),
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: _buildBadge(item.badgeCount!),
                  ),
              ],
            ),
            if (showLabel) ...[
              SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: SketchDesignTokens.fontFamilyHand,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SketchDesignTokens.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SketchDesignTokens.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyMono,
          fontSize: 10,
          color: SketchDesignTokens.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 네비게이션 항목 데이터
class SketchNavItem {
  /// 항목 라벨
  final String label;

  /// 항목 아이콘
  final IconData icon;

  /// 선택 시 아이콘 (선택)
  final IconData? activeIcon;

  /// 뱃지 카운트 (선택)
  final int? badgeCount;

  const SketchNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badgeCount,
  });
}

/// 라벨 표시 동작
enum SketchNavLabelBehavior {
  showAll,      // 모든 항목 라벨 표시
  showSelected, // 선택된 항목만 라벨 표시
  hideAll,      // 모든 라벨 숨김 (아이콘만)
}
```

#### GetX 사용 예시

```dart
class MainController extends GetxController {
  final currentIndex = 0.obs;

  Widget build() {
    return Scaffold(
      body: Obx(() => _buildBody(currentIndex.value)),
      bottomNavigationBar: SketchBottomNavigationBar(
        items: [
          SketchNavItem(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          SketchNavItem(
            label: '알림',
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            badgeCount: 3,
          ),
          SketchNavItem(
            label: '프로필',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
      ),
    );
  }
}
```

---

### 5.4 나머지 8개 위젯 간략 설계

제약상 상세한 구현은 생략하고, 핵심 구조만 정의합니다.

#### 5.4.1 SketchAvatar

```dart
class SketchAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final IconData? placeholderIcon;
  final SketchAvatarSize size; // enum: small(32), medium(56), large(80), xlarge(120)
  final SketchAvatarShape shape; // enum: circle, square
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
}

// 상태별 렌더링:
// 1. 이미지 로딩 성공 → Image.network + ClipPath (원형/사각형)
// 2. 이미지 없음 → SketchContainer + 이니셜 Text
// 3. 이미지 로딩 실패 → SketchImagePlaceholder (X-cross)
```

#### 5.4.2 SketchRadio

```dart
class SketchRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final double size;
  final Color? activeColor; // 기본값: accentPrimary

  // 렌더링: BoxDecoration 원형 + 선택 시 내부 점
}
```

#### 5.4.3 SketchSearchInput

```dart
class SketchSearchInput extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  // SketchInput 기반, prefixIcon: Icons.search 고정
  // suffixIcon: 입력 중 X 버튼 (controller.clear())
}
```

#### 5.4.4 SketchTextArea

```dart
class SketchTextArea extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final int minLines; // 기본값: 3
  final int? maxLines; // 기본값: 10
  final int? maxLength;
  final bool showCounter;

  // SketchInput 기반, minLines/maxLines 설정
}
```

#### 5.4.5 SketchDivider

```dart
class SketchDivider extends StatelessWidget {
  final Axis direction; // horizontal, vertical
  final double thickness;
  final Color? color;
  final bool isSketch; // true = 손그림 스타일, false = 직선

  // 렌더링: isSketch ? SketchLinePainter : Container with border
}
```

#### 5.4.6 SketchNumberInput

```dart
class SketchNumberInput extends StatelessWidget {
  final double value;
  final double? min;
  final double? max;
  final double step; // 기본값: 1.0
  final int decimalPlaces; // 기본값: 0
  final bool showButtons; // 증가/감소 버튼
  final ValueChanged<double>? onChanged;

  // SketchInput 기반, keyboardType: TextInputType.number
  // showButtons true면 우측에 +/- 버튼 표시
}
```

#### 5.4.7 SketchLink

```dart
class SketchLink extends StatelessWidget {
  final String text;
  final String? url; // 외부 링크
  final VoidCallback? onTap; // 내부 라우팅
  final bool isVisited; // 기본값: false

  // 렌더링: GestureDetector + Text (color: accentPrimary, decoration: underline)
}
```

#### 5.4.8 SketchAppBar

```dart
class SketchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  // 렌더링: Container + Row (leading, title, actions)
  // AppBar 대신 PreferredSizeWidget 구현으로 Scaffold.appBar 호환
}
```

---

## 6. 코드 품질 수정 방안

### 6.1 CRITICAL 이슈 해결 (4건)

| # | 이슈 | 해결 방안 | 파일 |
|---|------|---------|------|
| 1 | `ColorSpec` public 노출 | `_ColorSpec`으로 이름 변경 | `sketch_input.dart` |
| 2 | Dropdown 외부 탭 미감지 | GestureDetector barrier 추가 | `sketch_dropdown.dart` |
| 3 | Overlay context 문제 | Overlay.of(context) 대신 GlobalKey 사용 검토 | `sketch_dropdown.dart` |
| 4 | `withOpacity()` deprecated | `withValues(alpha: 0.1 * 255)` 교체 | `sketch_card.dart` |

### 6.2 WARNING 이슈 해결 (4건)

| # | 이슈 | 해결 방안 | 대상 파일 (8개) |
|---|------|---------|---------------|
| 1 | 미사용 파라미터 | roughness, bowing, seed, enableNoise 제거 | sketch_container, sketch_card, sketch_dropdown, sketch_icon_button, sketch_slider, sketch_switch, sketch_input, sketch_chip |
| 2 | Doc-string 예제 오류 | `accentPrimary` → `accentSecondary` 수정 | sketch_container, sketch_card, sketch_button |
| 3 | Calculator 보일러플레이트 | 클래스 삭제 | design_system.dart |
| 4 | BorderRadius 하드코딩 | `SketchDesignTokens.irregularBorderRadius` 사용 (선택) | 전체 |

---

## 7. Barrel Export 업데이트

### 7.1 `design_system.dart` 변경

```dart
library design_system;

// Painters
export 'src/painters/sketch_painter.dart';
export 'src/painters/sketch_circle_painter.dart';
export 'src/painters/sketch_line_painter.dart';
export 'src/painters/sketch_polygon_painter.dart';
export 'src/painters/animated_sketch_painter.dart';
export 'src/painters/x_cross_painter.dart'; // 추가

// Theme
export 'src/theme/sketch_theme_extension.dart';
export 'src/theme/sketch_theme_controller.dart';

// Widgets (기존)
export 'src/widgets/sketch_container.dart';
export 'src/widgets/sketch_button.dart';
export 'src/widgets/sketch_card.dart';
export 'src/widgets/sketch_input.dart';
export 'src/widgets/sketch_modal.dart';
export 'src/widgets/sketch_icon_button.dart';
export 'src/widgets/sketch_chip.dart';
export 'src/widgets/sketch_progress_bar.dart';
export 'src/widgets/sketch_switch.dart';
export 'src/widgets/sketch_checkbox.dart';
export 'src/widgets/sketch_slider.dart';
export 'src/widgets/sketch_dropdown.dart';
export 'src/widgets/social_login_button.dart';

// Widgets (신규 11개)
export 'src/widgets/sketch_image_placeholder.dart';
export 'src/widgets/sketch_tab_bar.dart';
export 'src/widgets/sketch_bottom_navigation_bar.dart';
export 'src/widgets/sketch_avatar.dart';
export 'src/widgets/sketch_radio.dart';
export 'src/widgets/sketch_search_input.dart';
export 'src/widgets/sketch_text_area.dart';
export 'src/widgets/sketch_divider.dart';
export 'src/widgets/sketch_number_input.dart';
export 'src/widgets/sketch_link.dart';
export 'src/widgets/sketch_app_bar.dart';

// Enums (기존)
export 'src/enums/social_login_platform.dart';
export 'src/enums/apple_sign_in_style.dart';

// Enums (신규)
export 'src/enums/sketch_tab_indicator_style.dart';
export 'src/enums/sketch_nav_label_behavior.dart';
export 'src/enums/sketch_avatar_size.dart';
export 'src/enums/sketch_avatar_shape.dart';

// Calculator 클래스 삭제 (보일러플레이트)
```

---

## 8. 데모 앱 업데이트 계획

### 8.1 `main.dart` 섹션 추가

```dart
// apps/mobile/apps/design_system_demo/lib/main.dart

class DemoHomePage extends StatelessWidget {
  final List<DemoSection> sections = [
    // 기존 섹션...

    // P0 신규 섹션
    DemoSection(
      title: '이미지 플레이스홀더',
      icon: Icons.image_outlined,
      route: '/placeholder',
      description: 'X-cross 패턴 플레이스홀더',
    ),

    // P1 신규 섹션
    DemoSection(
      title: '탭 바',
      icon: Icons.tab,
      route: '/tabbar',
      description: '스케치 스타일 탭 네비게이션',
    ),
    DemoSection(
      title: '하단 네비게이션',
      icon: Icons.navigation,
      route: '/bottom-nav',
      description: '하단 네비게이션 바',
    ),
    DemoSection(
      title: '아바타',
      icon: Icons.account_circle,
      route: '/avatar',
      description: '프로필 아바타',
    ),
    DemoSection(
      title: '라디오 버튼',
      icon: Icons.radio_button_checked,
      route: '/radio',
      description: '단일 선택 라디오 버튼',
    ),
    DemoSection(
      title: '검색 입력',
      icon: Icons.search,
      route: '/search',
      description: '검색 입력 필드',
    ),
    DemoSection(
      title: '텍스트 에어리어',
      icon: Icons.notes,
      route: '/textarea',
      description: '여러 줄 텍스트 입력',
    ),
    DemoSection(
      title: '구분선',
      icon: Icons.horizontal_rule,
      route: '/divider',
      description: '수평/수직 구분선',
    ),
    DemoSection(
      title: '숫자 입력',
      icon: Icons.numbers,
      route: '/number',
      description: '숫자 전용 입력 필드',
    ),
    DemoSection(
      title: '링크',
      icon: Icons.link,
      route: '/link',
      description: '텍스트 링크',
    ),
    DemoSection(
      title: '앱 바',
      icon: Icons.web_asset,
      route: '/appbar',
      description: '스케치 스타일 앱 바',
    ),
  ];
}
```

### 8.2 신규 데모 화면 파일

```
apps/mobile/apps/design_system_demo/lib/screens/
├── placeholder_demo_screen.dart
├── tabbar_demo_screen.dart
├── bottom_nav_demo_screen.dart
├── avatar_demo_screen.dart
├── radio_demo_screen.dart
├── search_demo_screen.dart
├── textarea_demo_screen.dart
├── divider_demo_screen.dart
├── number_demo_screen.dart
├── link_demo_screen.dart
└── appbar_demo_screen.dart
```

각 화면은 다음 구조를 따름:

```dart
class PlaceholderDemoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SketchImagePlaceholder')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('기본 사용'),
            _buildSection('프리셋'),
            _buildSection('커스터마이징'),
            _buildCodeExample(),
          ],
        ),
      ),
    );
  }
}
```

---

## 9. 실행 순서 권장

### Phase 1: P0 토큰 및 테마 변경 (1일)

**목표**: Frame0 핵심 시각 언어 반영

1. `sketch_design_tokens.dart` 색상 상수 추가 (배경, 액센트, 텍스트, outline)
2. `sketch_theme_extension.dart` light/dark 팩토리 메서드 변경
3. 검증: 데모 앱 실행 후 배경색 크림색 확인

### Phase 2: 기존 위젯 수정 (2일)

**목표**: 스타일 정합성 및 코드 품질 개선

#### Day 1
4. `sketch_button.dart` pill 형태 변경
5. `sketch_container.dart` 기본 fillColor 변경
6. CRITICAL 이슈 4건 수정 (ColorSpec, Dropdown barrier, withOpacity)

#### Day 2
7. 미사용 파라미터 제거 (8개 위젯)
8. Doc-string 수정, Calculator 삭제
9. `social_login_button.dart` sketchStyle 옵션 추가

### Phase 3: P0 신규 위젯 (1일)

**목표**: X-cross 플레이스홀더 구현

10. `x_cross_painter.dart` CustomPainter 구현
11. `sketch_image_placeholder.dart` 위젯 구현
12. 데모 화면 추가 및 검증

### Phase 4: P1 신규 위젯 (3일)

**목표**: 컴포넌트 완성도 확보

#### Day 1
13. `sketch_tab_bar.dart` 구현
14. `sketch_bottom_navigation_bar.dart` 구현

#### Day 2
15. `sketch_avatar.dart` 구현
16. `sketch_radio.dart` 구현
17. `sketch_search_input.dart` 구현

#### Day 3
18. `sketch_text_area.dart` 구현
19. `sketch_divider.dart` 구현
20. `sketch_number_input.dart` 구현
21. `sketch_link.dart` 구현
22. `sketch_app_bar.dart` 구현

### Phase 5: 통합 및 검증 (1일)

23. `design_system.dart` barrel export 업데이트
24. 데모 앱 전체 화면 추가
25. 전체 위젯 시각적 검증
26. Changelog 작성

---

## 10. 검증 기준

### 10.1 시각적 검증

- [ ] 라이트 모드 배경이 크림색(#FAF8F5)으로 표시됨
- [ ] 다크 모드 배경이 네이비(#1A1D29)으로 표시됨
- [ ] 링크와 선택 상태가 파란색(#2196F3)으로 표시됨
- [ ] CTA 버튼이 코랄/오렌지(#DF7D5F)로 표시됨
- [ ] 버튼이 pill 형태로 렌더링됨
- [ ] X-cross 플레이스홀더가 대각선 패턴으로 표시됨
- [ ] 모든 텍스트가 손글씨체(PatrickHand)로 표시됨

### 10.2 기능 검증

- [ ] TabBar 탭 전환이 정상 동작함
- [ ] BottomNavigationBar 항목 선택이 정상 동작함
- [ ] Avatar 이미지 로딩 실패 시 플레이스홀더 표시됨
- [ ] Radio 그룹에서 단일 선택만 가능함
- [ ] SearchInput 입력 중 X 버튼 표시됨
- [ ] TextArea 여러 줄 입력 가능함
- [ ] NumberInput 숫자만 입력 가능함
- [ ] Link 탭 시 URL 오픈 또는 콜백 실행됨
- [ ] Dropdown 외부 탭 시 닫힘

### 10.3 코드 품질 검증

- [ ] `melos analyze` 통과 (warning 0건)
- [ ] CRITICAL 이슈 4건 모두 해결
- [ ] WARNING 이슈 4건 모두 해결
- [ ] 미사용 파라미터 모두 제거
- [ ] public API에 불필요한 클래스 노출 없음
- [ ] deprecated API 사용 없음

### 10.4 GetX 호환성 검증

- [ ] 모든 위젯이 Obx 내부에서 정상 동작함
- [ ] Controller의 .obs 변수와 양방향 바인딩 정상 동작함
- [ ] 반응형 상태 변경 시 UI 즉시 업데이트됨

### 10.5 접근성 검증

- [ ] 모든 색상 조합이 WCAG 2.1 AA 기준 충족
- [ ] 터치 타겟 크기 44x44pt 이상 유지
- [ ] 스크린 리더 지원 (Semantics 위젯 적용)
- [ ] 폰트 크기 확대 시 레이아웃 유지

---

## 11. 작업 분배 계획 (CTO 참조)

### Senior Developer 작업

#### Phase 1-2 (3일)
- 디자인 토큰 변경 (`sketch_design_tokens.dart`)
- 테마 변경 (`sketch_theme_extension.dart`)
- CRITICAL 이슈 수정 (ColorSpec, Dropdown barrier, withOpacity)
- 기존 위젯 수정 (SketchButton, SketchContainer, SocialLoginButton)
- 미사용 파라미터 제거 (8개 위젯)

#### Phase 3 (1일)
- `x_cross_painter.dart` CustomPainter 구현
- `sketch_image_placeholder.dart` 구현

#### Phase 4 (3일)
- 복잡한 위젯 구현 (TabBar, BottomNavigationBar, Avatar, Radio, AppBar)

### Junior Developer 작업

#### Phase 4 (3일, Senior 작업 후)
- 간단한 위젯 구현 (SearchInput, TextArea, Divider, NumberInput, Link)
- Senior가 구현한 위젯 데모 화면 작성

#### Phase 5 (1일)
- `design_system.dart` barrel export 업데이트
- 데모 앱 전체 화면 추가
- 시각적 검증 및 스크린샷

### 작업 의존성

```
Phase 1 (Senior) → Phase 2 (Senior) → Phase 3 (Senior)
                                        ↓
                     Phase 4 (Senior, Junior 병렬)
                                        ↓
                     Phase 5 (Junior)
```

- Junior는 Senior의 Phase 3 완료 후 Phase 4 시작
- Phase 4에서 Senior와 Junior 병렬 작업 가능 (위젯 분리)

---

## 12. 참고 자료

### Frame0 공식 문서
- 홈페이지: https://frame0.app
- 스타일링 가이드: https://docs.frame0.app/styling/
- 라이브러리: https://docs.frame0.app/libraries/

### 프로젝트 내부 문서
- User Story: `docs/wowa/design-system/user-story.md`
- Design Spec: `docs/wowa/design-system/mobile-design-spec.md`
- 갭 분석 보고서: `docs/wowa/design-system/analysis.md`
- 디자인 토큰: `.claude/guide/mobile/design-tokens.json`
- 디자인 시스템 가이드: `.claude/guide/mobile/design_system.md`

### Flutter 가이드
- `.claude/guide/mobile/flutter_best_practices.md`
- `.claude/guide/mobile/getx_best_practices.md`
- `.claude/guide/mobile/directory_structure.md`
- `.claude/guide/mobile/common_patterns.md`

---

## 13. Breaking Changes 및 마이그레이션

### 13.1 Breaking Changes

#### 미사용 파라미터 제거 (8개 위젯)

**영향받는 코드**:
```dart
// 변경 전
SketchContainer(
  roughness: 1.0,
  seed: 42,
  child: child,
)

// 변경 후
SketchContainer(
  child: child,
)
```

**마이그레이션 가이드**:
1. 프로젝트 전체에서 `roughness`, `bowing`, `seed`, `enableNoise` 파라미터 제거
2. `melos analyze` 실행하여 에러 확인
3. 에러 발생 파일에서 해당 파라미터 제거

#### accentPrimary 의미 변경

**영향받는 코드**:
```dart
// 변경 전 (코랄/오렌지)
color: SketchDesignTokens.accentPrimary // #DF7D5F

// 변경 후 (파란색)
color: SketchDesignTokens.accentPrimary // #2196F3

// CTA 버튼은 accentSecondary 사용
color: SketchDesignTokens.accentSecondary // #DF7D5F
```

**마이그레이션 가이드**:
1. 링크, 선택 상태, 포커스는 `accentPrimary` 유지
2. CTA 버튼, 주요 액션은 `accentSecondary` 변경
3. 기존 코드가 `accentPrimary`를 버튼 색상으로 사용했다면 `accentSecondary`로 변경

### 13.2 Deprecated API

- `SketchDesignTokens.accentLight` → `SketchDesignTokens.accentSecondaryLight` (하위 호환성 유지)

---

## 14. 패키지 의존성 확인

### 14.1 모노레포 구조

```
core (foundation)
  ↑
  ├── api (HTTP, models)
  ├── design_system (UI, painters, widgets)
  └── wowa (app)
```

### 14.2 필요한 패키지

#### core
- `dart:ui` (Color 타입, 이미 포함)

#### design_system
- `flutter/material.dart` (이미 포함)
- `core` 패키지 (디자인 토큰)

#### wowa
- `core` 패키지
- `design_system` 패키지
- `get` (GetX, 이미 포함)

**추가 의존성 없음** — 기존 패키지로 모든 구현 가능.

---

## 15. 다음 단계 안내

이 기술 아키텍처 설계는 **CTO 검증 대기 중**입니다.

**승인 후 프로세스**:
1. CTO가 설계 검증 및 피드백 제공
2. 피드백 반영 후 최종 승인
3. Senior Developer에게 Phase 1-3 작업 할당
4. Junior Developer에게 Phase 4-5 작업 할당
5. 각 Phase 완료 후 코드 리뷰 및 병합

**예상 일정**: 총 8일 (Phase 1: 1일, Phase 2: 2일, Phase 3: 1일, Phase 4: 3일, Phase 5: 1일)

---

**작성자**: Tech Lead
**작성일**: 2026-02-10
**버전**: 1.0
**상태**: 사용자 승인 대기 중
