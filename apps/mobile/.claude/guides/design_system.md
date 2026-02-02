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

## CustomPainter

다양한 도형을 손그림 스타일로 렌더링하는 CustomPainter 클래스들.

### 1. SketchPainter

**기본 둥근 사각형 렌더러**

```dart
CustomPaint(
  painter: SketchPainter(
    fillColor: Colors.white,
    borderColor: Colors.black,
    strokeWidth: 2.0,
    roughness: 0.8,
    seed: 0,
    enableNoise: true,
  ),
  child: SizedBox(width: 200, height: 100),
)
```

### 2. SketchCirclePainter

**원형/타원 렌더러**

```dart
// 원
CustomPaint(
  painter: SketchCirclePainter(
    fillColor: Colors.blue,
    borderColor: Colors.black,
  ),
  child: SizedBox(width: 100, height: 100),
)

// 타원
CustomPaint(
  painter: SketchCirclePainter(
    fillColor: Colors.red,
    borderColor: Colors.black,
  ),
  child: SizedBox(width: 150, height: 100),
)
```

### 3. SketchLinePainter

**선/화살표 렌더러**

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
    start: Offset(20, 50),
    end: Offset(180, 50),
    color: Colors.blue,
    arrowStyle: SketchArrowStyle.end, // none, start, end, both
    arrowSize: 15.0,
  ),
  child: SizedBox(width: 200, height: 100),
)

// 점선
CustomPaint(
  painter: SketchLinePainter(
    start: Offset(0, 50),
    end: Offset(200, 50),
    color: Colors.black,
    dashPattern: [5.0, 3.0], // 5px 선, 3px 간격
  ),
  child: SizedBox(width: 200, height: 100),
)
```

### 4. SketchPolygonPainter

**다각형 렌더러 (삼각형~다각형, 별)**

```dart
// 삼각형
CustomPaint(
  painter: SketchPolygonPainter(
    sides: 3,
    fillColor: Colors.green,
    borderColor: Colors.black,
  ),
  child: SizedBox(width: 100, height: 100),
)

// 육각형
CustomPaint(
  painter: SketchPolygonPainter(
    sides: 6,
    fillColor: SketchDesignTokens.accentPrimary,
    borderColor: SketchDesignTokens.accentPrimary,
  ),
  child: SizedBox(width: 80, height: 80),
)

// 별 (5각 별)
CustomPaint(
  painter: SketchPolygonPainter(
    sides: 5,
    pointy: true, // 별 모양
    fillColor: SketchDesignTokens.warning,
    borderColor: SketchDesignTokens.warning,
  ),
  child: SizedBox(width: 100, height: 100),
)

// 회전
CustomPaint(
  painter: SketchPolygonPainter(
    sides: 4,
    rotation: pi / 4, // 45도 회전
    fillColor: Colors.red,
    borderColor: Colors.black,
  ),
  child: SizedBox(width: 100, height: 100),
)
```

### 5. AnimatedSketchPainter

**손으로 그리는 애니메이션 효과**

```dart
class AnimatedSketchExample extends StatefulWidget {
  @override
  State<AnimatedSketchExample> createState() => _AnimatedSketchExampleState();
}

class _AnimatedSketchExampleState extends State<AnimatedSketchExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward(); // 또는 ..repeat() 반복
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

---

## 테마 시스템

### Light/Dark 모드 자동 전환

**SketchThemeController 사용:**

```dart
// main.dart에서 초기화
void main() {
  Get.put(SketchThemeController());
  runApp(MyApp());
}

// 앱에서 사용
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SketchThemeController>();

    return Obx(() => MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [controller.currentTheme],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [SketchThemeExtension.dark()],
      ),
      themeMode: controller.themeMode.value,
      home: HomeScreen(),
    ));
  }
}

// 테마 토글
final controller = Get.find<SketchThemeController>();
controller.toggleBrightness(); // Light <-> Dark

// 특정 모드 설정
controller.setThemeMode(ThemeMode.light);   // 항상 Light
controller.setThemeMode(ThemeMode.dark);    // 항상 Dark
controller.setThemeMode(ThemeMode.system);  // 시스템 따름
```

### Roughness 프리셋

**5단계 거칠기 레벨:**

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      SketchThemeExtension.ultraSmooth(), // roughness: 0.0
      // SketchThemeExtension.smooth(),    // roughness: 0.3
      // SketchThemeExtension(),           // roughness: 0.8 (기본)
      // SketchThemeExtension.rough(),     // roughness: 1.2
      // SketchThemeExtension.veryRough(), // roughness: 1.8
    ],
  ),
)
```

| 프리셋 | Roughness | 설명 |
|--------|-----------|------|
| `ultraSmooth()` | 0.0 | 거의 스케치 효과 없음 (매끄러움) |
| `smooth()` | 0.3 | 약간의 손그림 느낌 |
| 기본값 | 0.8 | 적당한 스케치 느낌 (권장) |
| `rough()` | 1.2 | 확실한 손그림 느낌 |
| `veryRough()` | 1.8 | 매우 거친 스케치 |

### 커스텀 테마

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      SketchThemeExtension(
        strokeWidth: SketchDesignTokens.strokeBold,
        roughness: 1.0,
        borderColor: SketchDesignTokens.accentPrimary,
        fillColor: Colors.white,
      ),
    ],
  ),
)
```

### 위젯에서 테마 접근

```dart
// 테마 가져오기
final sketchTheme = SketchThemeExtension.of(context);

// 테마 값 사용
Container(
  decoration: BoxDecoration(
    color: sketchTheme.fillColor,
    border: Border.all(
      color: sketchTheme.borderColor,
      width: sketchTheme.strokeWidth,
    ),
  ),
)

// 안전한 접근 (nullable)
final sketchTheme = SketchThemeExtension.maybeOf(context);
if (sketchTheme != null) {
  // 테마 사용
}
```

---

## 컬러 팔레트

**6개의 프리셋 컬러 팔레트** (`SketchColorPalettes`)

### 1. Pastel 팔레트

**부드러운 파스텔 톤**

```dart
SketchButton(
  text: 'Pastel',
  fillColor: SketchColorPalettes.pastelPrimary,     // #FFB3BA (soft pink)
  onPressed: () {},
)

// 전체 팔레트
SketchColorPalettes.pastelPrimary      // #FFB3BA
SketchColorPalettes.pastelSecondary    // #BAE1FF
SketchColorPalettes.pastelAccent       // #FFDFBA
SketchColorPalettes.pastelSuccess      // #BAFFC9
SketchColorPalettes.pastelWarning      // #FFCCB3
SketchColorPalettes.pastelError        // #FFABAB
SketchColorPalettes.pastelBackground   // #FFFBF5
SketchColorPalettes.pastelSurface      // #FFF5E8
```

### 2. Vibrant 팔레트

**선명한 비비드 컬러**

```dart
SketchColorPalettes.vibrantPrimary     // #FF6B6B (bright coral)
SketchColorPalettes.vibrantSecondary   // #4ECDC4 (bright teal)
SketchColorPalettes.vibrantAccent      // #FFE66D (bright yellow)
// ... 외 5개
```

### 3. Monochrome 팔레트

**그레이스케일 전용**

```dart
SketchColorPalettes.monochromePrimary  // #2D3436 (dark gray)
SketchColorPalettes.monochromeSecondary // #636E72 (medium gray)
// ... 외 6개
```

### 4. Earthy 팔레트

**자연스러운 따뜻한 톤**

```dart
SketchColorPalettes.earthyPrimary      // #E07A5F (terracotta)
SketchColorPalettes.earthySecondary    // #81B29A (sage green)
// ... 외 6개
```

### 5. Ocean 팔레트

**시원한 블루/틸 톤**

```dart
SketchColorPalettes.oceanPrimary       // #0077B6 (deep blue)
SketchColorPalettes.oceanSecondary     // #00B4D8 (turquoise)
// ... 외 6개
```

### 6. Sunset 팔레트

**따뜻한 오렌지/핑크 톤**

```dart
SketchColorPalettes.sunsetPrimary      // #FF6B9D (coral)
SketchColorPalettes.sunsetSecondary    // #FFA384 (peach)
// ... 외 6개
```

### 팔레트 일괄 가져오기

```dart
// 팔레트 전체 색상 Map으로 가져오기
final colors = SketchColorPalettes.getPalette('pastel');
// {
//   'primary': Color(0xFFFFB3BA),
//   'secondary': Color(0xFFBAE1FF),
//   'accent': Color(0xFFFFDFBA),
//   ...
// }

// 사용 가능한 팔레트 목록
final palettes = SketchColorPalettes.availablePalettes;
// ['pastel', 'vibrant', 'monochrome', 'earthy', 'ocean', 'sunset']
```

---

## 애니메이션

### 1. 버튼 Press 애니메이션

**자동 포함 (SketchButton):**

- Scale: 0.98로 축소
- Roughness: +0.3 증가
- Seed 변경: 다른 모양

### 2. Switch/Slider 애니메이션

**자동 포함:**

- 썸(손잡이) 이동: 200ms easeInOut
- 색상 전환: Lerp 보간

### 3. Checkbox 애니메이션

**체크 마크 그리기:**

- 2단계 애니메이션 (첫 번째 선 → 두 번째 선)
- 200ms 지속

### 4. ProgressBar Indeterminate

**자동 반복 애니메이션:**

```dart
SketchProgressBar(
  value: null, // null = indeterminate
  // Linear: 좌우 이동
  // Circular: 회전
)
```

### 5. 손으로 그리는 애니메이션

**AnimatedSketchPainter 사용:**

```dart
class DrawingAnimation extends StatefulWidget {
  @override
  State<DrawingAnimation> createState() => _DrawingAnimationState();
}

class _DrawingAnimationState extends State<DrawingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedSketchPainter(
            progress: _controller.value,
            fillColor: Colors.blue,
            borderColor: Colors.black,
          ),
          child: SizedBox(width: 300, height: 200),
        );
      },
    );
  }
}
```

---

## 베스트 프랙티스

### 1. Const 생성자 사용

**모든 위젯이 const 생성자 지원:**

```dart
// ✅ Good
const SketchButton(
  text: '확인',
  onPressed: null,
)

// ✅ Good - GetX Obx와 함께
Obx(() => SketchButton(
  text: controller.buttonText.value,
  onPressed: () {},
))
```

### 2. 테마 값 활용

**개별 색상 대신 테마 사용:**

```dart
// ❌ Bad - 하드코딩
SketchContainer(
  fillColor: Color(0xFFFFFFFF),
  borderColor: Color(0xFFDCDCDC),
)

// ✅ Good - 디자인 토큰 사용
SketchContainer(
  fillColor: SketchDesignTokens.white,
  borderColor: SketchDesignTokens.base300,
)

// ✅ Best - 테마에서 자동 가져오기
SketchContainer(
  // fillColor, borderColor 생략 시 테마에서 자동
  child: child,
)
```

### 3. Seed 값 관리

**일관된 모양 유지:**

```dart
// 같은 seed = 항상 같은 모양
SketchContainer(
  seed: 42, // 고정값
  child: child,
)

// 상태별 다른 seed = 다른 모양
SketchContainer(
  seed: isPressed ? 1 : 0,
  child: child,
)
```

### 4. 적절한 Roughness 선택

| 용도 | Roughness | 설명 |
|------|-----------|------|
| 정식 출시 앱 | 0.3 ~ 0.8 | 너무 거칠지 않게 |
| 프로토타입 | 0.8 ~ 1.2 | 명확한 스케치 느낌 |
| 아트/일러스트 | 1.2 ~ 1.8 | 강한 손그림 효과 |

### 5. 성능 최적화

**RepaintBoundary 사용:**

```dart
RepaintBoundary(
  child: CustomPaint(
    painter: SketchPainter(...),
    child: ComplexWidget(),
  ),
)
```

**shouldRepaint 최적화 (이미 구현됨):**

모든 CustomPainter는 필수 속성만 비교하도록 최적화되어 있음.

### 6. 접근성

**최소 터치 영역 (44x44):**

```dart
// ✅ 모든 버튼/체크박스/스위치는 이미 준수
SketchButton(
  size: SketchButtonSize.small, // 32px height, 충분한 padding
)

SketchCheckbox(size: 24.0) // 24px, 충분한 터치 영역
```

**색상 대비:**

```dart
// ✅ 기본 팔레트는 WCAG AA 준수 (4.5:1 이상)
SketchDesignTokens.accentPrimary // #DF7D5F
SketchDesignTokens.white         // #FFFFFF
// 대비율: 4.52:1 ✅
```

---

## 예제 및 패턴

### 로그인 화면 예제

```dart
class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SketchCard(
          header: Text(
            '로그인',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSize2Xl,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SketchInput(
                label: '이메일',
                hint: 'you@example.com',
                controller: emailController,
                prefixIcon: Icon(Icons.email),
              ),
              SizedBox(height: SketchDesignTokens.spacingMd),
              SketchInput(
                label: '비밀번호',
                hint: '비밀번호 입력',
                controller: passwordController,
                obscureText: true,
                prefixIcon: Icon(Icons.lock),
              ),
              SizedBox(height: SketchDesignTokens.spacingMd),
              Row(
                children: [
                  SketchCheckbox(
                    value: rememberMe,
                    onChanged: (value) {},
                  ),
                  SizedBox(width: SketchDesignTokens.spacingSm),
                  Text('로그인 상태 유지'),
                ],
              ),
            ],
          ),
          footer: SketchButton(
            text: '로그인',
            onPressed: () => handleLogin(),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
```

### 설정 화면 예제

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('설정')),
      body: ListView(
        padding: EdgeInsets.all(SketchDesignTokens.spacingLg),
        children: [
          // 알림 설정
          SketchCard(
            body: Column(
              children: [
                ListTile(
                  title: Text('푸시 알림'),
                  trailing: SketchSwitch(
                    value: pushEnabled,
                    onChanged: (value) {},
                  ),
                ),
                ListTile(
                  title: Text('이메일 알림'),
                  trailing: SketchSwitch(
                    value: emailEnabled,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SketchDesignTokens.spacingLg),

          // 테마 설정
          SketchCard(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '테마',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SketchDesignTokens.spacingMd),
                SketchDropdown<String>(
                  value: selectedTheme,
                  items: ['Light', 'Dark', 'System'],
                  onChanged: (value) {
                    final controller = Get.find<SketchThemeController>();
                    switch (value) {
                      case 'Light':
                        controller.setThemeMode(ThemeMode.light);
                        break;
                      case 'Dark':
                        controller.setThemeMode(ThemeMode.dark);
                        break;
                      case 'System':
                        controller.setThemeMode(ThemeMode.system);
                        break;
                    }
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: SketchDesignTokens.spacingLg),

          // 볼륨 조절
          SketchCard(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('볼륨'),
                SketchSlider(
                  value: volume,
                  min: 0.0,
                  max: 100.0,
                  label: '${volume.round()}%',
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 선택 목록 예제

```dart
class SelectionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SketchDesignTokens.spacingSm,
      runSpacing: SketchDesignTokens.spacingSm,
      children: [
        SketchChip(
          label: 'Flutter',
          icon: Icon(Icons.flutter_dash, size: 16),
          selected: selectedTags.contains('Flutter'),
          onSelected: (selected) {
            toggleTag('Flutter');
          },
        ),
        SketchChip(
          label: 'Dart',
          selected: selectedTags.contains('Dart'),
          onSelected: (selected) {
            toggleTag('Dart');
          },
        ),
        SketchChip(
          label: 'GetX',
          selected: selectedTags.contains('GetX'),
          onSelected: (selected) {
            toggleTag('GetX');
          },
        ),
      ],
    );
  }
}
```

### 진행률 표시 예제

```dart
class ProgressExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Linear 진행률
        Text('다운로드 중...'),
        SizedBox(height: SketchDesignTokens.spacingSm),
        SketchProgressBar(
          value: downloadProgress, // 0.0 ~ 1.0
        ),

        SizedBox(height: SketchDesignTokens.spacingXl),

        // Circular 진행률
        SketchProgressBar(
          value: uploadProgress,
          style: SketchProgressBarStyle.circular,
          showPercentage: true,
        ),

        SizedBox(height: SketchDesignTokens.spacingXl),

        // Indeterminate (로딩)
        SketchProgressBar(
          value: null, // 애니메이션
        ),
      ],
    );
  }
}
```

---

## 추가 리소스

### design-tokens.json

모든 디자인 값의 원본 JSON 파일:

- 위치: `/Users/lms/dev/repository/app_gaegulzip/design-tokens.json`
- 용도: 디자인 토큰 참조, 다른 플랫폼 포팅

### 소스 코드

- **Core Package**: `packages/core/lib/`
- **Design System Package**: `packages/design_system/lib/`

### Frame0.app

디자인 영감의 원천: https://frame0.app

---

## 마이그레이션 가이드

### 기존 Material 위젯에서 전환

```dart
// Material → Sketch 변환 예시

// ElevatedButton → SketchButton
ElevatedButton(
  onPressed: () {},
  child: Text('버튼'),
)
// ↓
SketchButton(
  text: '버튼',
  onPressed: () {},
)

// TextField → SketchInput
TextField(
  decoration: InputDecoration(
    labelText: '이메일',
    hintText: '입력하세요',
  ),
)
// ↓
SketchInput(
  label: '이메일',
  hint: '입력하세요',
)

// Slider → SketchSlider
Slider(
  value: value,
  min: 0,
  max: 100,
  onChanged: (v) {},
)
// ↓
SketchSlider(
  value: value,
  min: 0,
  max: 100,
  onChanged: (v) {},
)
```

---

이 가이드는 Sketch Design System의 완전한 사용법을 다룹니다. 추가 질문이나 특정 사용 사례가 있다면 팀에 문의하세요.
