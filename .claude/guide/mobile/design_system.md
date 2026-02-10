# Sketch Design System 가이드

Frame0 스타일의 손그림 디자인 시스템 - 완전한 컴포넌트 라이브러리 및 사용 가이드

## 목차

1. [개요](#개요)
2. [Frame0 디자인 철학](#frame0-디자인-철학)
3. [설치 및 설정](#설치-및-설정)
4. [디자인 토큰](#디자인-토큰)
5. [컴포넌트 카탈로그](#컴포넌트-카탈로그)
6. [CustomPainter](#custompainter)
7. [테마 시스템](#테마-시스템)
8. [컬러 팔레트](#컬러-팔레트)
9. [애니메이션](#애니메이션)
10. [베스트 프랙티스](#베스트-프랙티스)
11. [예제 및 패턴](#예제-및-패턴)

---

## 개요

Sketch Design System은 [Frame0.app](https://frame0.app)에서 영감을 받은 손그림 스타일의 Flutter 디자인 시스템입니다. 저충실도(low-fidelity) 프로토타이핑과 스케치 스타일 UI에 최적화되어 있습니다.

Frame0는 [DGM.js](https://dgmjs.dev/) 기반의 와이어프레임 도구로, 데스크탑/모바일/스마트워치/웹 UI 컴포넌트 라이브러리와 1,500개 이상의 스케치 스타일 Lucide 아이콘을 제공합니다.

### 주요 특징

- **손그림 효과**: Bezier 곡선 기반 불규칙 테두리, 흔들리는 선, 노이즈 텍스처
- **13개 UI 컴포넌트**: Button, Card, Input, Modal, Switch, Slider, SocialLoginButton 등
- **5개 CustomPainter**: 다양한 도형 렌더링 (사각형, 원, 선, 다각형, 애니메이션)
- **완전한 테마 시스템**: Light/Dark 모드, 6개 Roughness 프리셋
- **6개 컬러 팔레트**: Pastel, Vibrant, Monochrome, Earthy, Ocean, Sunset
- **GetX 호환**: 모든 위젯이 반응형 상태 관리 지원
- **애니메이션 지원**: 손으로 그리는 효과, 상태 전환 애니메이션
- **4가지 폰트 카테고리**: Hand (PatrickHand), Sans (Roboto), Mono (JetBrainsMono), Serif (Georgia)

### 파일 구조

```
packages/
├── core/
│   ├── sketch_design_tokens.dart      # 디자인 토큰 상수
│   └── sketch_color_palettes.dart     # 컬러 팔레트
└── design_system/
    ├── painters/                       # CustomPainter 클래스
    │   ├── sketch_painter.dart        # 기본 사각형 렌더러
    │   ├── sketch_circle_painter.dart # 원형/타원
    │   ├── sketch_line_painter.dart   # 선/화살표
    │   ├── sketch_polygon_painter.dart # 다각형 (3~8각형, 별)
    │   └── animated_sketch_painter.dart # 그려지는 애니메이션
    ├── enums/                          # 열거형
    │   ├── social_login_platform.dart # 소셜 로그인 플랫폼
    │   └── apple_sign_in_style.dart   # 애플 로그인 스타일
    ├── theme/                          # 테마 시스템
    │   ├── sketch_theme_extension.dart # ThemeExtension (6 프리셋)
    │   └── sketch_theme_controller.dart # GetX 컨트롤러
    └── widgets/                        # UI 컴포넌트 (13개)
        ├── sketch_container.dart
        ├── sketch_button.dart
        ├── sketch_card.dart
        ├── sketch_input.dart
        ├── sketch_modal.dart
        ├── sketch_icon_button.dart
        ├── sketch_chip.dart
        ├── sketch_progress_bar.dart
        ├── sketch_switch.dart
        ├── sketch_checkbox.dart
        ├── sketch_slider.dart
        ├── sketch_dropdown.dart
        └── social_login_button.dart
```

---

## Frame0 디자인 철학

Frame0의 핵심 디자인 원칙을 이해해야 올바른 스케치 스타일 UI를 만들 수 있습니다.

### 핵심 원칙: "프로토타입임을 알리는 디자인"

> "The hand-drawn aesthetic frees you from pixel-perfect precision, encouraging rapid ideation and collaboration. The sketchy appearance signals to stakeholders that this is a prototype, not final design."

- **불완전함이 핵심**: 완벽한 직선, 정확한 원이 아닌 흔들리는 손그림 느낌
- **의도적 거칠기**: roughness 파라미터로 스케치 정도를 제어
- **노이즈 텍스처**: 종이 위에 그린 듯한 미세한 점 노이즈

### Frame0 스타일링 속성 (참조)

Frame0에서 사용하는 스타일링 속성과 우리 시스템의 대응:

| Frame0 속성 | 설명 | 우리 시스템 대응 |
|-------------|------|-----------------|
| **Fill color** | 도형 내부 채우기 색상 | `fillColor` 파라미터 |
| **Fill style** | None / Solid / Hachure / Cross hatch | 현재 Solid만 지원 (Hachure 미구현) |
| **Stroke color** | 테두리 색상 | `borderColor` 파라미터 |
| **Stroke width** | 테두리 두께 | `strokeWidth` 파라미터 |
| **Stroke pattern** | Solid / Dotted / Dashed | `SketchLinePainter`의 `dashPattern` |
| **Roughness** | 손그림 흔들림 정도 | `roughness` 파라미터 (0.0~1.8) |
| **Shadow** | 그림자 오프셋 + 색상 | `SketchThemeExtension`의 shadow 속성들 |
| **Padding** | 내부 여백 | Flutter 표준 Padding |
| **Corners** | 모서리 둥글기 | `irregularBorderRadius` 토큰 |
| **Font family** | 4가지 카테고리 | Hand (Sketch), Sans (Solid), Mono (코드), Serif (본문) |

### 미구현 Frame0 기능 (향후 확장 가능)

- **Hachure fill**: 사선 빗금 채우기 (rough.js 스타일)
- **Cross hatch fill**: 교차 빗금 채우기
- **Freehand drawing**: 자유 그리기 도구
- **Container 시스템**: 도형 안에 도형 포함

### 아이콘

Frame0는 1,500개 이상의 Lucide 아이콘을 스케치 스타일로 변환하여 사용합니다. 우리 시스템에서는 `lucide_icons_flutter` 패키지를 사용합니다:

```dart
import 'package:lucide_icons_flutter/lucide_icons.dart';

Icon(LucideIcons.layoutGrid)
Icon(LucideIcons.paintbrush)
Icon(LucideIcons.palette)
```

### 폰트 (Frame0 Default Fonts)

Frame0는 4가지 폰트 카테고리를 지원합니다:

| 카테고리 | 폰트 | 용도 | 토큰 상수 |
|---------|------|------|----------|
| **Hand** | PatrickHand | Sketch 테마 기본, 손글씨 느낌 | `SketchDesignTokens.fontFamilyHand` |
| **Sans** | Roboto | Solid 테마 기본, 산세리프 | `SketchDesignTokens.fontFamilySans` |
| **Mono** | JetBrainsMono | 코드, 숫자, 기술적 텍스트 | `SketchDesignTokens.fontFamilyMono` |
| **Serif** | Georgia | 본문, 장문 텍스트 | `SketchDesignTokens.fontFamilySerif` |

- Sketch 테마 사용 시 Hand 폰트가 기본 적용
- Solid 테마 사용 시 Sans 폰트가 기본 적용

```dart
// 토큰 상수로 접근 (권장)
Text('스케치', style: TextStyle(fontFamily: SketchDesignTokens.fontFamilyHand))
Text('0x1A2B', style: TextStyle(fontFamily: SketchDesignTokens.fontFamilyMono))
```

---

## 설치 및 설정

### 1. 의존성 추가

이미 monorepo 구조에 포함되어 있으므로 별도 설치 불필요. `melos bootstrap`만 실행.

```bash
melos bootstrap
```

### 2. Import

```dart
import 'package:design_system/design_system.dart';
import 'package:core/core.dart'; // 디자인 토큰용
```

### 3. 테마 설정

**기본 설정:**

```dart
void main() {
  // 테마 컨트롤러 초기화 (선택사항)
  Get.put(SketchThemeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [
          SketchThemeExtension(), // 기본 테마
        ],
      ),
      home: HomeScreen(),
    );
  }
}
```

**Light/Dark 모드 자동 전환:**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<SketchThemeController>();

    return Obx(() => MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [themeController.currentTheme],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [SketchThemeExtension.dark()],
      ),
      themeMode: themeController.themeMode.value,
      home: HomeScreen(),
    ));
  }
}
```

---

## 디자인 토큰

모든 디자인 값은 `SketchDesignTokens` 클래스에 상수로 정의되어 있습니다.

### 색상

```dart
// 기본 색상 (그레이스케일)
SketchDesignTokens.white           // #FFFFFF
SketchDesignTokens.base100         // #F7F7F7 (거의 흰색)
SketchDesignTokens.base300         // #DCDCDC (밝은 회색)
SketchDesignTokens.base500         // #8E8E8E (중간 회색)
SketchDesignTokens.base700         // #5E5E5E (어두운 회색, 다크모드 테두리)
SketchDesignTokens.base900         // #343434 (거의 검은색, 다크모드 배경)
SketchDesignTokens.black           // #000000

// 강조 색상 (Frame0의 코랄/오렌지 시그니처 컬러)
SketchDesignTokens.accentPrimary   // #DF7D5F (코랄/오렌지)
SketchDesignTokens.accentLight     // #F19E7E (밝은 코랄)
SketchDesignTokens.accentDark      // #C86947 (어두운 코랄)

// 의미론적 색상
SketchDesignTokens.success         // #4CAF50 (녹색)
SketchDesignTokens.warning         // #FFC107 (노란색)
SketchDesignTokens.error           // #F44336 (빨간색)
SketchDesignTokens.info            // #2196F3 (파란색)
```

### 선 두께

```dart
SketchDesignTokens.strokeThin      // 1.0px - 텍스트 밑줄, 아이콘, smooth 프리셋
SketchDesignTokens.strokeStandard  // 2.0px - 대부분의 UI 요소 (기본값)
SketchDesignTokens.strokeBold      // 3.0px - 강조, 선택 상태, rough 프리셋
SketchDesignTokens.strokeThick     // 4.0px - 타이틀, 포커스
```

### 간격 (8px 그리드)

```dart
SketchDesignTokens.spacingXs       // 4px
SketchDesignTokens.spacingSm       // 8px
SketchDesignTokens.spacingMd       // 12px
SketchDesignTokens.spacingLg       // 16px
SketchDesignTokens.spacingXl       // 24px
SketchDesignTokens.spacing2Xl      // 32px
SketchDesignTokens.spacing3Xl      // 48px
SketchDesignTokens.spacing4Xl      // 64px
```

### 타이포그래피

```dart
SketchDesignTokens.fontSizeXs      // 12px
SketchDesignTokens.fontSizeSm      // 14px
SketchDesignTokens.fontSizeBase    // 16px
SketchDesignTokens.fontSizeLg      // 18px
SketchDesignTokens.fontSizeXl      // 20px
SketchDesignTokens.fontSize2Xl     // 24px
SketchDesignTokens.fontSize3Xl     // 30px
SketchDesignTokens.fontSize4Xl     // 36px
SketchDesignTokens.fontSize5Xl     // 48px
SketchDesignTokens.fontSize6Xl     // 60px
```

### 손그림 효과

```dart
SketchDesignTokens.roughness       // 0.8 - 거칠기 (0.0~1.8)
SketchDesignTokens.bowing          // 0.5 - 휘어짐 정도
SketchDesignTokens.noiseIntensity  // 0.035 - 노이즈 강도
SketchDesignTokens.noiseGrainSize  // 1.5 - 노이즈 입자 크기
SketchDesignTokens.irregularBorderRadius // 모서리 불규칙 반경
```

### 그림자

```dart
SketchDesignTokens.shadowOffsetMd  // 기본 그림자 오프셋
SketchDesignTokens.shadowBlurMd    // 기본 그림자 블러
SketchDesignTokens.shadowColor     // 기본 그림자 색상
```

### 불투명도

```dart
SketchDesignTokens.opacityDisabled // 0.4
SketchDesignTokens.opacitySubtle   // 0.6
SketchDesignTokens.opacitySketch   // 0.8
SketchDesignTokens.opacityFull     // 1.0
```

---

## 컴포넌트 카탈로그

### 1. SketchButton

**3가지 스타일 x 3가지 크기 버튼 위젯**

```dart
// Primary 버튼
SketchButton(
  text: '확인',
  onPressed: () {},
)

// 스타일 변형
SketchButton(
  text: '취소',
  style: SketchButtonStyle.secondary,  // primary, secondary, outline
  size: SketchButtonSize.large,        // small, medium, large
  onPressed: () {},
)

// 아이콘 + 텍스트
SketchButton(
  text: '저장',
  icon: Icon(Icons.save),
  onPressed: () {},
)

// 로딩 상태
SketchButton(
  text: '제출',
  isLoading: true,
  onPressed: () {},
)
```

### 2. SketchCard

**Header/Body/Footer 구조의 카드 위젯**

```dart
SketchCard(
  header: Text('카드 제목'),
  body: Column(
    children: [
      Text('카드 내용'),
      Text('추가 내용'),
    ],
  ),
  footer: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      SketchButton(text: '취소', onPressed: () {}),
      SketchButton(text: '확인', onPressed: () {}),
    ],
  ),
  elevation: 2, // 0-3 (그림자 강도)
)

// 클릭 가능한 카드
SketchCard(
  body: Text('탭하세요'),
  onTap: () => print('카드 클릭됨'),
)
```

### 3. SketchInput

**Label, Hint, Error 상태를 지원하는 입력 필드**

```dart
// 기본 입력 필드
SketchInput(
  label: '이메일',
  hint: 'you@example.com',
  controller: emailController,
  onChanged: (value) => print(value),
)

// 에러 상태
SketchInput(
  label: '비밀번호',
  hint: '비밀번호 입력',
  obscureText: true,
  errorText: '비밀번호는 8자 이상이어야 합니다',
)

// Prefix/Suffix 아이콘
SketchInput(
  label: '검색',
  prefixIcon: Icon(Icons.search),
  suffixIcon: IconButton(
    icon: Icon(Icons.clear),
    onPressed: () => controller.clear(),
  ),
)
```

### 4. SketchModal

**애니메이션 다이얼로그**

```dart
// 기본 모달
await SketchModal.show(
  context: context,
  title: '알림',
  child: Text('작업이 완료되었습니다.'),
  actions: [
    SketchButton(
      text: '확인',
      onPressed: () => Navigator.pop(context),
    ),
  ],
);

// 커스텀 모달
await SketchModal.show<bool>(
  context: context,
  title: '삭제 확인',
  child: Text('정말로 삭제하시겠습니까?'),
  actions: [
    SketchButton(
      text: '취소',
      style: SketchButtonStyle.outline,
      onPressed: () => Navigator.pop(context, false),
    ),
    SketchButton(
      text: '삭제',
      onPressed: () => Navigator.pop(context, true),
    ),
  ],
  showCloseButton: true,
  barrierDismissible: false,
);
```

### 5. SketchIconButton

**원형/사각형 아이콘 버튼 + 뱃지**

```dart
// 기본 아이콘 버튼
SketchIconButton(
  icon: Icons.settings,
  onPressed: () {},
)

// 툴팁 포함
SketchIconButton(
  icon: Icons.favorite,
  tooltip: '좋아요',
  onPressed: () {},
)

// 뱃지 표시 (알림 개수)
SketchIconButton(
  icon: Icons.notifications,
  badgeCount: 5,
  onPressed: () {},
)

// 사각형 모양
SketchIconButton(
  icon: Icons.menu,
  shape: SketchIconButtonShape.square,
  onPressed: () {},
)
```

### 6. SketchChip

**선택 가능한 태그/칩 위젯**

```dart
// 기본 칩
SketchChip(
  label: 'Flutter',
)

// 아이콘 포함
SketchChip(
  label: '즐겨찾기',
  icon: Icon(Icons.star, size: 16),
)

// 선택 가능한 칩
SketchChip(
  label: '옵션 1',
  selected: true,
  onSelected: (selected) {
    setState(() => isSelected = selected);
  },
)

// 닫기 버튼 포함
SketchChip(
  label: '태그',
  onDeleted: () => removeTag(),
)
```

### 7. SketchProgressBar

**Linear/Circular 진행률 표시**

```dart
// Linear 스타일
SketchProgressBar(
  value: 0.7, // 70%
)

// Circular 스타일
SketchProgressBar(
  value: 0.5,
  style: SketchProgressBarStyle.circular,
  showPercentage: true, // "50%" 표시
)

// Indeterminate (진행률 미정)
SketchProgressBar(
  value: null, // null = 애니메이션
)
```

### 8. SketchSwitch

**토글 스위치**

```dart
SketchSwitch(
  value: isOn,
  onChanged: (value) {
    setState(() => isOn = value);
  },
)

// 레이블과 함께
Row(
  children: [
    Text('알림 받기'),
    SizedBox(width: 8),
    SketchSwitch(
      value: notificationsEnabled,
      onChanged: (value) {},
    ),
  ],
)
```

### 9. SketchCheckbox

**체크박스 (Tristate 지원)**

```dart
// 기본 체크박스
SketchCheckbox(
  value: isChecked,
  onChanged: (value) {
    setState(() => isChecked = value ?? false);
  },
)

// Tristate (true/false/null)
SketchCheckbox(
  value: allSelected ? true : (someSelected ? null : false),
  tristate: true,
  onChanged: (value) {},
)
```

### 10. SketchSlider

**드래그 슬라이더**

```dart
// 기본 슬라이더
SketchSlider(
  value: volume,
  min: 0.0,
  max: 100.0,
  onChanged: (value) {
    setState(() => volume = value);
  },
)

// 구분선 (Divisions)
SketchSlider(
  value: rating,
  min: 0.0,
  max: 5.0,
  divisions: 5, // 0, 1, 2, 3, 4, 5
  label: '${rating.round()}',
  onChanged: (value) {},
)
```

### 11. SketchDropdown

**드롭다운 선택 위젯**

```dart
// 기본 드롭다운
SketchDropdown<String>(
  value: selectedOption,
  items: ['옵션 1', '옵션 2', '옵션 3'],
  onChanged: (value) {
    setState(() => selectedOption = value!);
  },
)

// 커스텀 항목 빌더
SketchDropdown<User>(
  value: selectedUser,
  items: users,
  itemBuilder: (user) => Text(user.name),
  onChanged: (user) {},
)

// 힌트 텍스트
SketchDropdown<String>(
  value: null,
  hint: '선택하세요',
  items: ['A', 'B', 'C'],
  onChanged: (value) {},
)
```

### 12. SketchContainer

**재사용 가능한 스케치 컨테이너 (SketchPainter 기반)**

모든 스케치 위젯의 기반. SketchPainter를 내부적으로 사용하여 불규칙한 테두리와 노이즈 텍스처를 렌더링합니다.

```dart
// 기본 컨테이너
SketchContainer(
  child: Text('손그림 스타일 컨테이너'),
)

// 커스텀 스타일
SketchContainer(
  width: 300,
  height: 200,
  fillColor: SketchDesignTokens.accentLight,
  borderColor: SketchDesignTokens.accentPrimary,
  strokeWidth: SketchDesignTokens.strokeBold,
  roughness: 1.0, // 더 거칠게
  child: child,
)

// GetX Obx와 함께 사용
Obx(() => SketchContainer(
  borderColor: controller.isSelected.value
      ? SketchDesignTokens.accentPrimary
      : SketchDesignTokens.base300,
  child: Text(controller.title.value),
))
```

### 13. SocialLoginButton

**소셜 로그인 버튼 (카카오/네이버/구글/애플 공식 가이드라인 준수)**

일반 스케치 스타일이 아닌, 각 플랫폼의 공식 디자인 가이드라인을 따릅니다.

```dart
// 카카오 로그인
SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  onPressed: () {},
)

// 네이버 로그인
SocialLoginButton(
  platform: SocialLoginPlatform.naver,
  onPressed: () {},
)

// 구글 로그인
SocialLoginButton(
  platform: SocialLoginPlatform.google,
  onPressed: () {},
)

// 애플 로그인 (다크/라이트 스타일)
SocialLoginButton(
  platform: SocialLoginPlatform.apple,
  appleStyle: AppleSignInStyle.dark,  // dark, light
  onPressed: () {},
)

// 크기 변형
SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  size: SocialLoginButtonSize.large,  // small, medium, large
  onPressed: () {},
)
```

---

## CustomPainter

5개의 CustomPainter로 손그림 도형을 렌더링합니다. 모든 페인터는 공통 속성(`fillColor`, `borderColor`, `strokeWidth`, `roughness`, `bowing`, `seed`)을 공유합니다.

### 손그림 렌더링 원리

모든 SketchPainter의 핵심 알고리즘:

1. **Bezier 곡선 기반 불규칙 경로**: 직선 대신 `quadraticBezierTo()`로 흔들리는 경로 생성
2. **다중 스트로크**: roughness > 0.5이면 2개의 약간 오프셋된 경로를 겹쳐 그림
3. **노이즈 텍스처**: `fillColor` 위에 미세한 점들을 랜덤 배치 (종이 질감)
4. **시드 기반 무작위**: 동일한 seed = 동일한 스케치 모양 (재현 가능)

### 1. SketchPainter (기본 사각형)

불규칙한 둥근 사각형을 렌더링. `SketchContainer`의 내부 구현.

```dart
CustomPaint(
  painter: SketchPainter(
    fillColor: Colors.white,
    borderColor: SketchDesignTokens.accentPrimary,
    strokeWidth: SketchDesignTokens.strokeBold,
    roughness: 1.0,
    seed: 42,        // 재현 가능한 무작위성
    enableNoise: true, // 노이즈 텍스처
  ),
  child: SizedBox(width: 200, height: 100),
)
```

**주요 파라미터:**

| 파라미터 | 기본값 | 설명 |
|---------|-------|------|
| `fillColor` | 필수 | 내부 채우기 색상 |
| `borderColor` | 필수 | 테두리 색상 |
| `strokeWidth` | 2.0 | 테두리 두께 |
| `roughness` | 0.8 | 흔들림 정도 (0.0=부드러움, 1.0+=매우 스케치) |
| `bowing` | 0.5 | 직선이 곡선으로 휘는 정도 |
| `seed` | 0 | 랜덤 시드 (동일 시드 = 동일 모양) |
| `enableNoise` | true | 노이즈 텍스처 on/off |

### 2. SketchCirclePainter (원형/타원)

불규칙한 원형과 타원을 렌더링. 세그먼트 수를 조절하여 다각형 근사.

```dart
// 원형
CustomPaint(
  painter: SketchCirclePainter(
    fillColor: Colors.blue,
    borderColor: Colors.black,
  ),
  child: SizedBox(width: 100, height: 100),
)

// 타원 (SizedBox 비율로 결정)
CustomPaint(
  painter: SketchCirclePainter(
    fillColor: Colors.red,
    borderColor: Colors.black,
    segments: 30, // 세그먼트 수 (높을수록 부드러움)
  ),
  child: SizedBox(width: 150, height: 100),
)
```

### 3. SketchLinePainter (선/화살표)

불규칙한 선을 렌더링. 시작/끝점에 화살표 지원.

```dart
// 기본 선
CustomPaint(
  painter: SketchLinePainter(
    start: Offset(0, 50),
    end: Offset(200, 50),
    color: Colors.black,
  ),
  child: SizedBox(width: 200, height: 100),
)

// 화살표
CustomPaint(
  painter: SketchLinePainter(
    start: Offset(10, 50),
    end: Offset(190, 50),
    color: Colors.black,
    arrowStyle: SketchArrowStyle.end,  // none, start, end, both
  ),
  child: SizedBox(width: 200, height: 100),
)

// 대시 패턴
CustomPaint(
  painter: SketchLinePainter(
    start: Offset(0, 50),
    end: Offset(200, 50),
    color: Colors.black,
    dashPattern: [8.0, 4.0], // 8px 선, 4px 공백
  ),
  child: SizedBox(width: 200, height: 100),
)
```

**SketchArrowStyle 열거형:**
- `none`: 화살표 없음
- `end`: 끝점에 화살표
- `start`: 시작점에 화살표
- `both`: 양쪽 끝 화살표

### 4. SketchPolygonPainter (다각형)

N각형과 별 모양을 렌더링. `sides`로 변 수, `rotation`으로 회전, `pointy`로 별 모양 지원.

```dart
// 삼각형
CustomPaint(
  painter: SketchPolygonPainter(
    sides: 3,
    fillColor: Colors.blue,
    borderColor: Colors.black,
  ),
  child: SizedBox(width: 100, height: 100),
)

// 육각형
CustomPaint(
  painter: SketchPolygonPainter(
    sides: 6,
    fillColor: SketchDesignTokens.accentPrimary,
    borderColor: SketchDesignTokens.accentDark,
  ),
  child: SizedBox(width: 80, height: 80),
)

// 별 모양
CustomPaint(
  painter: SketchPolygonPainter(
    sides: 5,
    pointy: true, // 별 모양 활성화
    fillColor: Colors.yellow,
    borderColor: Colors.orange,
  ),
  child: SizedBox(width: 100, height: 100),
)
```

### 5. AnimatedSketchPainter (애니메이션)

경로를 점진적으로 그려나가는 애니메이션 효과. `AnimationController`와 함께 사용.

```dart
class _AnimatedExampleState extends State<AnimatedExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedSketchPainter(
            progress: _controller.value, // 0.0 ~ 1.0
            fillColor: Colors.blue,
            borderColor: Colors.black,
          ),
          child: SizedBox(width: 200, height: 100),
        );
      },
    );
  }
}
```

**애니메이션 단계:**
- `progress 0.0~0.8`: 테두리만 점진적으로 그려짐
- `progress 0.8~1.0`: 채우기 색상이 페이드인
- `progress 1.0`: 노이즈 텍스처 추가

---

## 테마 시스템

### SketchThemeExtension

Flutter의 `ThemeExtension`을 활용한 스케치 테마. 8개 속성을 제어합니다.

```dart
const SketchThemeExtension({
  strokeWidth,    // 테두리 두께
  roughness,      // 거칠기
  bowing,         // 휘어짐
  borderColor,    // 테두리 색상
  fillColor,      // 채우기 색상
  shadowOffset,   // 그림자 오프셋
  shadowBlur,     // 그림자 블러
  shadowColor,    // 그림자 색상
})
```

### 6개 프리셋

| 프리셋 | strokeWidth | roughness | bowing | 용도 |
|--------|------------|-----------|--------|------|
| `light()` | 2.0 (standard) | 0.8 | 0.5 | 라이트 모드 기본 |
| `dark()` | 2.0 (standard) | 0.8 | 0.5 | 다크 모드 기본 |
| `rough()` | 3.0 (bold) | 1.2 | 0.8 | 더 거친 스케치 느낌 |
| `smooth()` | 1.0 (thin) | 0.3 | 0.2 | 부드러운 스케치 |
| `ultraSmooth()` | 1.0 (thin) | 0.0 | 0.0 | 스케치 효과 거의 없음 |
| `veryRough()` | 3.0 (bold) | 1.8 | 1.2 | 매우 거친 예술적 효과 |

```dart
// 프리셋 사용
SketchThemeExtension.light()      // 라이트 기본
SketchThemeExtension.dark()       // 다크 기본 (borderColor: base700, fillColor: base900)
SketchThemeExtension.rough()      // 거친 스케치
SketchThemeExtension.smooth()     // 부드러운
SketchThemeExtension.ultraSmooth() // 거의 직선
SketchThemeExtension.veryRough()  // 매우 거친

// 커스텀
SketchThemeExtension(
  strokeWidth: 2.5,
  roughness: 1.0,
  bowing: 0.6,
  borderColor: SketchDesignTokens.accentPrimary,
  fillColor: Colors.white,
)
```

### 위젯에서 테마 접근

```dart
// 안전한 접근 (없으면 예외)
final sketchTheme = SketchThemeExtension.of(context);

// null 안전 접근 (없으면 null)
final sketchTheme = SketchThemeExtension.maybeOf(context);

// 속성 사용
Container(
  decoration: BoxDecoration(
    color: sketchTheme.fillColor,
    border: Border.all(
      color: sketchTheme.borderColor,
      width: sketchTheme.strokeWidth,
    ),
  ),
)
```

### SketchThemeController (GetX)

테마 모드와 밝기를 반응형으로 관리합니다.

```dart
final controller = Get.find<SketchThemeController>();

// 현재 상태 확인
controller.isDarkMode      // bool
controller.isLightMode     // bool
controller.brightness      // Brightness.light 또는 Brightness.dark
controller.currentTheme    // 현재 SketchThemeExtension

// 테마 전환
controller.toggleBrightness();           // 토글
controller.setBrightness(Brightness.dark); // 특정 밝기
controller.setThemeMode(ThemeMode.system); // 시스템 따르기
```

### SketchThemeObserver (시스템 밝기 감지)

시스템 밝기 변경을 자동 감지하려면 mixin을 사용합니다:

```dart
class _MyAppState extends State<MyApp> with SketchThemeObserver {
  @override
  void initState() {
    super.initState();
    initThemeObserver();
  }

  @override
  void dispose() {
    disposeThemeObserver();
    super.dispose();
  }
}
```

---

## 컬러 팔레트

6개의 사전 정의된 컬러 팔레트. 각 팔레트는 8개 의미론적 색상을 포함합니다.

### 팔레트 목록

| 팔레트 | 분위기 | Primary 색상 |
|--------|--------|-------------|
| **Pastel** | 부드럽고 차분한 | #FFB3BA (소프트 핑크) |
| **Vibrant** | 대담하고 활기찬 | #FF6B6B (브라이트 코랄) |
| **Monochrome** | 미니멀 그레이스케일 | #2D3436 (다크 그레이) |
| **Earthy** | 자연스럽고 따뜻한 | #E07A5F (테라코타) |
| **Ocean** | 시원한 블루/틸 | #0077B6 (딥 블루) |
| **Sunset** | 따뜻한 오렌지/핑크 | #FF6B9D (코랄) |

### 팔레트 색상 구조

각 팔레트에 포함된 8개 색상:

```
primary    - 주요 액션, 버튼
secondary  - 보조 요소
accent     - 강조, 하이라이트
success    - 성공 상태
warning    - 경고 상태
error      - 에러 상태
background - 배경
surface    - 카드, 패널 표면
```

### 사용법

```dart
// 직접 접근
SketchColorPalettes.pastelPrimary
SketchColorPalettes.oceanBackground

// getPalette() API로 동적 접근
final palette = SketchColorPalettes.getPalette('earthy');
// palette = {'primary': Color, 'secondary': Color, ...}

final primaryColor = palette['primary']!;
final bgColor = palette['background']!;

// 사용 가능한 팔레트 목록
final names = SketchColorPalettes.availablePalettes;
// ['pastel', 'vibrant', 'monochrome', 'earthy', 'ocean', 'sunset']
```

### 팔레트로 테마 구성

```dart
final palette = SketchColorPalettes.getPalette('ocean');

SketchThemeExtension(
  borderColor: palette['primary']!,
  fillColor: palette['background']!,
)

SketchButton(
  text: '오션 버튼',
  fillColor: palette['primary'],
  onPressed: () {},
)
```

---

## 애니메이션

### 그려지는 효과 (AnimatedSketchPainter)

`AnimationController`의 `value`(0.0~1.0)를 `AnimatedSketchPainter`의 `progress`에 연결하여 손으로 그리는 듯한 효과를 만듭니다.

**자동 재생:**
```dart
_controller = AnimationController(
  duration: Duration(seconds: 2),
  vsync: this,
)..forward(); // 한 번 재생
```

**반복 재생:**
```dart
_controller.repeat(); // 무한 반복
```

**역방향:**
```dart
_controller.reverse(); // 되감기
```

### 상태 전환 애니메이션

`SketchThemeExtension`의 `lerp()` 메서드를 통해 테마 프리셋 간 부드러운 전환이 가능합니다:

```dart
// light -> dark 전환 시 strokeWidth, roughness, borderColor 등이 보간됨
theme: ThemeData(
  extensions: [themeController.currentTheme],
),
```

---

## 베스트 프랙티스

### 1. Roughness 가이드라인

| roughness 값 | 용도 |
|-------------|------|
| 0.0 | 정확한 UI, 정보 표시 (ultraSmooth) |
| 0.3 | 미묘한 스케치 느낌 (smooth) |
| 0.8 | 기본값, 자연스러운 손그림 |
| 1.2 | 의도적으로 거친 프로토타입 느낌 (rough) |
| 1.8 | 예술적, 매우 표현력 있는 (veryRough) |

### 2. 성능 최적화

- **seed 고정**: `SketchPainter`의 seed를 고정하여 불필요한 리페인트 방지
- **enableNoise: false**: 노이즈가 불필요한 작은 위젯에서 성능 향상
- **const 생성자**: `SketchContainer`, `SketchButton` 등에 const 사용

```dart
// 좋은 예: seed 고정으로 동일한 렌더링 보장
SketchContainer(
  seed: 42,
  child: Text('안정적'),
)

// 나쁜 예: 매번 다른 모양이 렌더링됨
SketchContainer(
  seed: DateTime.now().millisecondsSinceEpoch,
  child: Text('불안정'),
)
```

### 3. 테마 활용

```dart
// 좋은 예: 테마에서 값을 가져옴
final theme = SketchThemeExtension.of(context);
SketchContainer(
  borderColor: theme.borderColor,
  strokeWidth: theme.strokeWidth,
  child: child,
)

// 나쁜 예: 하드코딩
SketchContainer(
  borderColor: Color(0xFFDCDCDC),
  strokeWidth: 2.0,
  child: child,
)
```

### 4. 색상 사용

```dart
// 좋은 예: 디자인 토큰 사용
SketchDesignTokens.accentPrimary
SketchDesignTokens.base300

// 좋은 예: 팔레트 사용
SketchColorPalettes.getPalette('earthy')['primary']

// 나쁜 예: 매직 넘버
Color(0xFFDF7D5F)
```

### 5. 접근성

- 다크 모드에서 충분한 대비를 유지 (`dark()` 프리셋 사용)
- 버튼의 `isLoading` 상태를 활용하여 사용자 피드백 제공
- `SketchIconButton`의 `tooltip`을 항상 설정

---

## 예제 및 패턴

### 스케치 스타일 폼

```dart
Column(
  children: [
    SketchInput(
      label: '이름',
      hint: '이름을 입력하세요',
      controller: nameController,
    ),
    SizedBox(height: SketchDesignTokens.spacingLg),
    SketchInput(
      label: '이메일',
      hint: 'you@example.com',
      controller: emailController,
    ),
    SizedBox(height: SketchDesignTokens.spacingXl),
    SketchButton(
      text: '제출',
      size: SketchButtonSize.large,
      onPressed: onSubmit,
    ),
  ],
)
```

### 카드 그리드

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: SketchDesignTokens.spacingLg,
    crossAxisSpacing: SketchDesignTokens.spacingLg,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return SketchCard(
      elevation: 2,
      onTap: () => navigateTo(items[index]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(items[index].icon, size: 48),
          SizedBox(height: SketchDesignTokens.spacingMd),
          Text(items[index].name),
        ],
      ),
    );
  },
)
```

### 팔레트 기반 테마 전환

```dart
class ThemeShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: SketchColorPalettes.availablePalettes.map((name) {
        final palette = SketchColorPalettes.getPalette(name);
        return GestureDetector(
          onTap: () => applyPalette(palette),
          child: SketchContainer(
            fillColor: palette['background']!,
            borderColor: palette['primary']!,
            child: Text(name),
          ),
        );
      }).toList(),
    );
  }
}
```

---

## 추가 리소스

### design-tokens.json

모든 디자인 값의 원본 JSON 파일:

- 위치: `.claude/guide/mobile/design-tokens.json`
- 용도: 디자인 토큰 참조, 다른 플랫폼 포팅

### 소스 코드

- **Core Package**: `packages/core/lib/`
- **Design System Package**: `packages/design_system/lib/`

### Frame0.app

디자인 영감의 원천:
- 홈페이지: https://frame0.app
- 문서: https://docs.frame0.app
- 스타일링 가이드: https://docs.frame0.app/styling/
- 라이브러리 가이드: https://docs.frame0.app/libraries/
- 기반 라이브러리: [DGM.js](https://dgmjs.dev/) (오픈소스)

### 데모 앱

`apps/mobile/apps/design_system_demo/` 에서 모든 컴포넌트를 인터랙티브하게 확인할 수 있습니다.

```bash
cd apps/mobile/apps/design_system_demo && flutter run
```
