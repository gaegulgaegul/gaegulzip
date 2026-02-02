# Sketch Design System 가이드

Frame0 스타일의 손그림 디자인 시스템 - 완전한 컴포넌트 라이브러리 및 사용 가이드

## 목차

1. [개요](#개요)
2. [설치 및 설정](#설치-및-설정)
3. [디자인 토큰](#디자인-토큰)
4. [컴포넌트 카탈로그](#컴포넌트-카탈로그)
5. [CustomPainter](#custompainter)
6. [테마 시스템](#테마-시스템)
7. [컬러 팔레트](#컬러-팔레트)
8. [애니메이션](#애니메이션)
9. [베스트 프랙티스](#베스트-프랙티스)
10. [예제 및 패턴](#예제-및-패턴)

---

## 개요

Sketch Design System은 Frame0.app에서 영감을 받은 손그림 스타일의 Flutter 디자인 시스템입니다. 저충실도(low-fidelity) 프로토타이핑과 스케치 스타일 UI에 최적화되어 있습니다.

### 주요 특징

- **손그림 효과**: 불규칙한 테두리, 흔들리는 선, 노이즈 텍스처
- **12개 UI 컴포넌트**: Button, Card, Input, Modal, Switch, Slider 등
- **5개 CustomPainter**: 다양한 도형 렌더링 (사각형, 원, 선, 다각형, 애니메이션)
- **완전한 테마 시스템**: Light/Dark 모드, 5단계 Roughness 프리셋
- **6개 컬러 팔레트**: Pastel, Vibrant, Monochrome, Earthy, Ocean, Sunset
- **GetX 호환**: 모든 위젯이 반응형 상태 관리 지원
- **애니메이션 지원**: 손으로 그리는 효과, 상태 전환 애니메이션

### 파일 구조

```
packages/
├── core/
│   ├── sketch_design_tokens.dart      # 디자인 토큰 상수
│   └── sketch_color_palettes.dart     # 컬러 팔레트
└── design_system/
    ├── painters/                       # CustomPainter 클래스
    │   ├── sketch_painter.dart        # 기본 렌더러
    │   ├── sketch_circle_painter.dart # 원형
    │   ├── sketch_line_painter.dart   # 선/화살표
    │   ├── sketch_polygon_painter.dart # 다각형
    │   └── animated_sketch_painter.dart # 애니메이션
    ├── theme/                          # 테마 시스템
    │   ├── sketch_theme_extension.dart # ThemeExtension
    │   └── sketch_theme_controller.dart # GetX 컨트롤러
    └── widgets/                        # UI 컴포넌트 (12개)
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
        └── sketch_dropdown.dart
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
// 기본 색상
SketchDesignTokens.white           // #FFFFFF
SketchDesignTokens.base100         // #F7F7F7 (거의 흰색)
SketchDesignTokens.base300         // #DCDCDC (밝은 회색)
SketchDesignTokens.base500         // #8E8E8E (중간 회색)
SketchDesignTokens.base900         // #343434 (거의 검은색)
SketchDesignTokens.black           // #000000

// 강조 색상
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
SketchDesignTokens.strokeThin      // 1.0px - 텍스트 밑줄, 아이콘
SketchDesignTokens.strokeStandard  // 2.0px - 대부분의 UI 요소
SketchDesignTokens.strokeBold      // 3.0px - 강조, 선택 상태
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
SketchDesignTokens.roughness       // 0.8 - 거칠기 (0.0~1.5+)
SketchDesignTokens.bowing          // 0.5 - 휘어짐 정도
SketchDesignTokens.noiseIntensity  // 0.035 - 노이즈 강도
SketchDesignTokens.noiseGrainSize  // 1.5 - 노이즈 입자 크기
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

**3가지 스타일 × 3가지 크기 버튼 위젯**

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

**재사용 가능한 스케치 컨테이너**

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

---

## 추가 리소스

### design-tokens.json

모든 디자인 값의 원본 JSON 파일:

- 위치: `/Users/lms/dev/repository/gaegulzip/.claude/guide/mobile/design-tokens.json`
- 용도: 디자인 토큰 참조, 다른 플랫폼 포팅

### 소스 코드

- **Core Package**: `packages/core/lib/`
- **Design System Package**: `packages/design_system/lib/`

### Frame0.app

디자인 영감의 원천: https://frame0.app
