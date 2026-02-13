# UI/UX 디자인 명세: SketchAppBar 스케치 스타일 개선

## 개요

SketchAppBar 위젯에 SketchPainter 기반의 손으로 그린 듯한 테두리 질감을 적용하여, SketchContainer 및 SketchModal과 동일한 Frame0 스케치 미학을 구현합니다. 현재 BoxDecoration + BoxShadow를 사용하는 렌더링 방식을 CustomPaint + SketchPainter 2-pass 렌더링으로 교체하여 시각적 일관성을 확보합니다.

## 화면 구조

### Screen 1: SketchAppBar (기본 화면)

#### 레이아웃 계층

```
Scaffold
└── AppBar: SketchAppBar
    ├── [showSketchBorder: false] Container (기존 방식)
    │   ├── decoration: BoxDecoration
    │   │   ├── color: effectiveBgColor
    │   │   └── boxShadow: [BoxShadow] (showShadow: true)
    │   └── child: SizedBox(height: 56)
    │       └── Row
    │           ├── leading: SketchIconButton or auto back button
    │           ├── Expanded: titleWidget or Text
    │           └── actions: List<Widget>
    │
    └── [showSketchBorder: true] Stack (새 방식)
        ├── [0] Container (그림자 레이어 - showShadow: true)
        │   └── decoration: BoxDecoration(boxShadow: [...])
        │
        └── [1] CustomPaint (스케치 테두리 레이어)
            ├── painter: SketchPainter (1st pass)
            │   ├── fillColor: effectiveBgColor
            │   ├── borderColor: effectiveBorderColor
            │   ├── strokeWidth: effectiveStrokeWidth * 1.5
            │   ├── roughness: effectiveRoughness * 1.75
            │   ├── seed: 100 (고정값)
            │   ├── enableNoise: true
            │   └── borderRadius: 0.0 (직각)
            │
            ├── child: CustomPaint (2nd pass)
            │   ├── painter: SketchPainter
            │   │   ├── fillColor: Colors.transparent
            │   │   ├── borderColor: effectiveBorderColor
            │   │   ├── strokeWidth: effectiveStrokeWidth * 1.5
            │   │   ├── roughness: effectiveRoughness * 1.75
            │   │   ├── seed: 150 (1st pass + 50)
            │   │   ├── enableNoise: false
            │   │   └── borderRadius: 0.0
            │   │
            │   └── child: Container
            │       └── padding: EdgeInsets.only(top: statusBarHeight, left: 8, right: 8)
            │       └── SizedBox(height: 56)
            │           └── Row
            │               ├── leading
            │               ├── Expanded: title
            │               └── actions
```

#### 위젯 상세

**Container (showSketchBorder: false - 기존 방식)**
- decoration:
  - color: effectiveBgColor (backgroundColor ?? theme.fillColor)
  - boxShadow: showShadow가 true일 때만 표시
    - color: theme.shadowColor (default: black 10%)
    - offset: Offset(0, 2)
    - blurRadius: 4
- padding:
  - top: MediaQuery.of(context).padding.top (status bar 높이)
  - left: SketchDesignTokens.spacingSm (8dp)
  - right: SketchDesignTokens.spacingSm (8dp)
- child: SizedBox(height: 56)

**Stack (showSketchBorder: true - 새 방식)**
- 레이어 구조:
  1. 그림자 레이어 (하단, showShadow: true일 때만)
  2. SketchPainter 1st pass (배경 + 테두리 + 노이즈)
  3. SketchPainter 2nd pass (테두리만 겹쳐 그리기)
  4. 컨텐츠 레이어 (leading + title + actions)

**CustomPaint (1st Pass - 배경 + 테두리 + 노이즈)**
- painter: SketchPainter
  - fillColor: effectiveBgColor (라이트: #FAF8F5, 다크: #23273A)
  - borderColor: effectiveBorderColor (라이트: #343434, 다크: #FFFFFF)
  - strokeWidth: effectiveStrokeWidth * 1.5 (기본 2.0 → 3.0)
  - roughness: effectiveRoughness * 1.75 (기본 0.8 → 1.4)
  - seed: 100 (고정값, 재현 가능한 무작위성)
  - enableNoise: true (종이 질감)
  - showBorder: true
  - borderRadius: 0.0 (앱바는 직각)

**CustomPaint (2nd Pass - 테두리만 겹침)**
- painter: SketchPainter
  - fillColor: Colors.transparent (채우기 없음)
  - borderColor: effectiveBorderColor
  - strokeWidth: effectiveStrokeWidth * 1.5 (3.0)
  - roughness: effectiveRoughness * 1.75 (1.4)
  - seed: 150 (1st pass seed + 50)
  - enableNoise: false
  - showBorder: true
  - borderRadius: 0.0

**Row (앱바 컨텐츠)**
- children:
  - leading: 조건부 렌더링
    - `leading != null` → 사용자 지정 위젯
    - `Navigator.canPop(context)` → SketchIconButton (뒤로가기)
    - 기본: 표시 안 함
  - Expanded: titleWidget 또는 Text
    - fontFamily: SketchDesignTokens.fontFamilyHand
    - fontSize: SketchDesignTokens.fontSizeLg (18sp)
    - fontWeight: FontWeight.w600
    - color: effectiveFgColor
  - actions: List<Widget> (우측 액션 버튼들)

### Screen 2: 데모 앱 (AppBarDemo)

#### 레이아웃 계층

```
SingleChildScrollView
└── Padding (24dp)
    └── Column
        ├── Row (토글 컨트롤)
        │   ├── Text("그림자 표시")
        │   ├── SketchSwitch (showShadow)
        │   ├── SizedBox(width: 16)
        │   ├── Text("스케치 테두리")
        │   └── SketchSwitch (showSketchBorder)
        │
        ├── SizedBox(height: 32)
        │
        ├── Text("변형 갤러리")
        ├── SizedBox(height: 24)
        │
        ├── [데모 1] 기본 스케치 앱바
        │   ├── Text("기본 (스케치 테두리)")
        │   ├── SizedBox(height: 8)
        │   └── SizedBox(height: 56)
        │       └── SketchAppBar(
        │           title: "홈",
        │           showSketchBorder: _showSketchBorder,
        │           showShadow: _showShadow,
        │         )
        │
        ├── SizedBox(height: 24)
        │
        ├── [데모 2] 액션 버튼 + 스케치
        │   ├── Text("액션 버튼 + 스케치")
        │   ├── SizedBox(height: 8)
        │   └── SizedBox(height: 56)
        │       └── SketchAppBar(
        │           title: "설정",
        │           showSketchBorder: _showSketchBorder,
        │           showShadow: _showShadow,
        │           actions: [search, menu],
        │         )
        │
        ├── SizedBox(height: 24)
        │
        ├── [데모 3] 커스텀 leading + 스케치
        │   ├── Text("커스텀 leading + 스케치")
        │   ├── SizedBox(height: 8)
        │   └── SizedBox(height: 56)
        │       └── SketchAppBar(
        │           title: "메뉴",
        │           showSketchBorder: _showSketchBorder,
        │           showShadow: _showShadow,
        │           leading: menu button,
        │         )
        │
        ├── SizedBox(height: 24)
        │
        ├── [데모 4] 스케치 + 그림자 동시 적용
        │   ├── Text("스케치 + 그림자")
        │   ├── SizedBox(height: 8)
        │   └── SizedBox(height: 56)
        │       └── SketchAppBar(
        │           title: "조합 스타일",
        │           showSketchBorder: true,
        │           showShadow: true,
        │         )
        │
        └── SizedBox(height: 24)
```

## 색상 팔레트

### Light Theme (SketchThemeExtension.light)

- **fillColor (배경)**: `Color(0xFFFAF8F5)` - 크림색 배경 (Frame0 스타일)
- **borderColor (테두리)**: `Color(0xFF343434)` - base900, 어두운 스케치 테두리
- **textColor (텍스트)**: `Color(0xFF343434)` - base900, 제목 텍스트
- **iconColor (아이콘)**: `Color(0xFF767676)` - base600, 액션 버튼
- **shadowColor (그림자)**: `Color(0x1A000000)` - black 10% (기본값)

### Dark Theme (SketchThemeExtension.dark)

- **fillColor (배경)**: `Color(0xFF23273A)` - surfaceDark, 어두운 네이비 배경
- **borderColor (테두리)**: `Color(0xFFFFFFFF)` - white, 밝은 스케치 테두리
- **textColor (텍스트)**: `Color(0xFFF5F5F5)` - textOnDark, 밝은 제목
- **iconColor (아이콘)**: `Color(0xFFB5B5B5)` - base400, 액션 버튼
- **shadowColor (그림자)**: `Color(0x33000000)` - black 20% (다크 모드용)

### Sketch Specific

- **strokeWidth**: 기본 2.0 (SketchDesignTokens.strokeStandard)
- **effectiveStrokeWidth**: 2.0 * 1.5 = 3.0 (앱바 전용 두께)
- **roughness**: 기본 0.8 (SketchDesignTokens.roughness)
- **effectiveRoughness**: 0.8 * 1.75 = 1.4 (앱바 전용 거칠기)
- **seed (1st pass)**: 100 (고정값)
- **seed (2nd pass)**: 150 (1st + 50)

## 타이포그래피

### 앱바 제목

- **fontFamily**: `SketchDesignTokens.fontFamilyHand` ("Nanum Pen Script")
- **fontFamilyFallback**: `SketchDesignTokens.fontFamilyHandFallback` (["Gochi Hand", "Patrick Hand", "cursive"])
- **fontSize**: `SketchDesignTokens.fontSizeLg` (18sp)
- **fontWeight**: FontWeight.w600
- **color**: effectiveFgColor (라이트: #343434, 다크: #F5F5F5)
- **overflow**: TextOverflow.ellipsis

### 데모 앱 레이블

- **섹션 제목**: fontSize 16sp, fontWeight: FontWeight.bold
- **변형 레이블**: fontSize 14sp, fontWeight: FontWeight.w500
- **토글 레이블**: fontSize 14sp (SketchDesignTokens.fontSizeBase)

## 스페이싱 시스템

### 앱바 내부 패딩

- **top**: `MediaQuery.of(context).padding.top` (status bar 높이, 가변)
- **left**: `SketchDesignTokens.spacingSm` (8dp)
- **right**: `SketchDesignTokens.spacingSm` (8dp)
- **bottom**: 0 (내용물이 56dp 높이로 정렬됨)

### 데모 앱 스페이싱

- **화면 패딩**: 24dp (SketchDesignTokens.spacingLg)
- **섹션 간격**: 32dp (SketchDesignTokens.spacing2Xl)
- **변형 간격**: 24dp (SketchDesignTokens.spacingLg)
- **레이블 ↔ 위젯**: 8dp (SketchDesignTokens.spacingSm)
- **토글 스위치 간격**: 16dp (SketchDesignTokens.spacingMd)

## Border Radius

### 앱바 스케치 테두리

- **borderRadius**: 0.0 (직각)
  - 이유: 앱바는 화면 상단 전체 너비를 차지하며, 둥근 모서리가 부자연스러움
  - SketchContainer (12.0)와 달리 앱바는 화면에 고정된 요소로 직각 처리

### 데모 카드 (데모 앱)

- **데모 영역 래퍼**: borderRadius 없음 (SizedBox 사용)
- **SketchContainer (비교용)**: 12.0 (SketchDesignTokens.irregularBorderRadius)

## Elevation (그림자)

### showShadow: true (기본값)

- **offset**: Offset(0, 2)
- **blurRadius**: 4
- **color**: theme.shadowColor (라이트: black 10%, 다크: black 20%)

### showShadow: false

- **그림자 없음**: BoxDecoration의 boxShadow: null

### 스케치 테두리와 그림자 동시 사용

- showSketchBorder: true && showShadow: true
  - Stack의 하단 레이어에 Container(decoration: BoxDecoration(boxShadow: [...]))
  - 상단 레이어에 CustomPaint (스케치 테두리)
  - 그림자는 스케치 영역 전체에 적용됨

## 인터랙션 상태

### 앱바 자체

- **정적 위젯**: 인터랙션 상태 없음 (클릭, 호버, 포커스 미지원)
- **일관된 스타일**: 스크롤 시에도 고정된 모습 유지

### 앱바 내부 버튼 (leading, actions)

- **SketchIconButton**: 자체 인터랙션 상태 관리
  - Default: border color (라이트: #343434, 다크: #FFFFFF)
  - Pressed: 살짝 어두워짐 (SketchIconButton 자체 로직)
  - Disabled: disabledBorderColor 사용

## 애니메이션

### 화면 전환

- **Route Transition**: 기본 Material 슬라이드 (앱바는 고정)
- **Duration**: 300ms (프레임워크 기본값)

### 상태 변경 (데모 앱)

- **토글 스위치 변경**: setState로 즉시 리빌드
- **애니메이션 없음**: showSketchBorder 토글 시 즉시 렌더링 방식 전환
  - 이유: CustomPaint와 BoxDecoration 간 전환은 애니메이션 없이 즉각 반영

### 스케치 테두리 렌더링

- **정적 렌더링**: seed가 고정값이므로 매번 동일한 모양
- **애니메이션 없음**: SketchPainter는 CustomPainter의 정적 렌더링 사용

## 반응형 레이아웃

### Breakpoints

- **앱바는 전체 화면 너비 사용**: 디바이스 크기 무관하게 `double.infinity`
- **높이 고정**: 56dp (preferredSize)
- **StatusBar 대응**: `MediaQuery.of(context).padding.top`으로 동적 조정

### 적응형 레이아웃 전략

- **세로 모드**: 기본 레이아웃 (leading + title + actions)
- **가로 모드**: 동일 (앱바는 방향에 무관하게 일관된 구조)

### 터치 영역

- **leading/actions 버튼**: 48x48dp 최소 터치 영역 (SketchIconButton 기본값)
- **title**: 터치 불가 (텍스트 표시만)

## 접근성 (Accessibility)

### 색상 대비

- **라이트 모드**:
  - 텍스트(#343434) vs 배경(#FAF8F5): 약 7.5:1 (WCAG AAA)
  - 테두리(#343434) vs 배경(#FAF8F5): 약 7.5:1 (WCAG AAA)
- **다크 모드**:
  - 텍스트(#F5F5F5) vs 배경(#23273A): 약 8.0:1 (WCAG AAA)
  - 테두리(#FFFFFF) vs 배경(#23273A): 약 10.0:1 (WCAG AAA)

### 의미 전달

- **스케치 테두리**: 장식적 요소, 정보 전달 없음
- **텍스트 제목**: 명확한 문자열로 의미 전달
- **버튼**: 아이콘 + Semantics 라벨 (SketchIconButton에서 처리)

### 스크린 리더 지원

- **AppBar Semantics**: 자동 "Navigation bar" 레이블 (Material 기본)
- **Title**: 자동으로 읽힘
- **leading/actions**: SketchIconButton이 각자 Semantics 제공

## Design System 컴포넌트 활용

### 기존 재사용 컴포넌트

- **SketchPainter**: 2-pass 렌더링으로 스케치 테두리 생성
  - 1st pass: 배경 + 테두리 + 노이즈
  - 2nd pass: 테두리만 겹쳐 그리기
- **SketchIconButton**: leading 및 actions에서 사용
- **SketchSwitch**: 데모 앱의 토글 스위치
- **SketchThemeExtension**: 테마별 색상, strokeWidth, roughness 제공

### 새로운 컴포넌트 필요 여부

- **없음**: 기존 SketchPainter를 활용하여 구현 가능
- **SketchAppBar 자체 개선**: showSketchBorder 파라미터 추가 및 렌더링 로직 수정

## SketchPainter 2-Pass 렌더링 전략

### 1st Pass (배경 + 테두리 + 노이즈)

```dart
SketchPainter(
  fillColor: effectiveBgColor,        // 라이트: #FAF8F5, 다크: #23273A
  borderColor: effectiveBorderColor,  // 라이트: #343434, 다크: #FFFFFF
  strokeWidth: effectiveStrokeWidth * 1.5,  // 2.0 * 1.5 = 3.0
  roughness: effectiveRoughness * 1.75,     // 0.8 * 1.75 = 1.4
  seed: 100,                          // 고정 시드
  enableNoise: true,                  // 종이 질감
  showBorder: true,                   // 테두리 그리기
  borderRadius: 0.0,                  // 직각
)
```

### 2nd Pass (테두리만 겹침)

```dart
SketchPainter(
  fillColor: Colors.transparent,      // 배경 투명
  borderColor: effectiveBorderColor,  // 동일
  strokeWidth: effectiveStrokeWidth * 1.5,  // 3.0 (동일)
  roughness: effectiveRoughness * 1.75,     // 1.4 (동일)
  seed: 150,                          // 1st pass + 50
  enableNoise: false,                 // 노이즈 없음
  showBorder: true,                   // 테두리만 그리기
  borderRadius: 0.0,                  // 직각
)
```

### 2-Pass 효과

- **겹쳐진 선 질감**: seed 값 차이로 인해 두 번째 테두리가 첫 번째와 약간 다른 경로로 그려짐
- **손으로 덧칠한 느낌**: 두 개의 불규칙한 선이 겹쳐져 더 진하고 풍부한 테두리
- **SketchContainer와 동일**: 동일한 2-pass 전략으로 시각적 일관성 확보

## 렌더링 로직 분기

### showSketchBorder: false (기존 방식)

```dart
Container(
  decoration: BoxDecoration(
    color: effectiveBgColor,
    boxShadow: showShadow ? [...] : null,
  ),
  padding: EdgeInsets.only(
    top: statusBarHeight,
    left: SketchDesignTokens.spacingSm,
    right: SketchDesignTokens.spacingSm,
  ),
  child: SizedBox(
    height: height,
    child: Row(
      children: [leading, Expanded(title), ...actions],
    ),
  ),
)
```

### showSketchBorder: true (새 방식)

```dart
Stack(
  children: [
    // 그림자 레이어 (showShadow: true)
    if (showShadow)
      Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme?.shadowColor ?? Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),

    // 스케치 테두리 레이어
    CustomPaint(
      painter: SketchPainter(...), // 1st pass
      child: CustomPaint(
        painter: SketchPainter(...), // 2nd pass
        child: Container(
          padding: EdgeInsets.only(
            top: statusBarHeight,
            left: SketchDesignTokens.spacingSm,
            right: SketchDesignTokens.spacingSm,
          ),
          child: SizedBox(
            height: height,
            child: Row(
              children: [leading, Expanded(title), ...actions],
            ),
          ),
        ),
      ),
    ),
  ],
)
```

## 파라미터 정의

### 기존 파라미터 (유지)

- **title**: String? - 타이틀 텍스트
- **titleWidget**: Widget? - 커스텀 타이틀 위젯 (우선순위 높음)
- **leading**: Widget? - 좌측 위젯
- **actions**: List<Widget>? - 우측 액션 버튼들
- **backgroundColor**: Color? - 배경색 (null이면 테마 fillColor)
- **foregroundColor**: Color? - 텍스트 색상 (null이면 테마 textColor)
- **showShadow**: bool - 그림자 표시 여부 (기본값: true)
- **height**: double - 앱바 높이 (기본값: 56.0)

### 새 파라미터 (추가)

- **showSketchBorder**: bool - 스케치 테두리 표시 여부 (기본값: false, 기존 앱 호환성)
- **strokeWidth**: double? - 스케치 테두리 두께 (null이면 테마 기본값)
- **roughness**: double? - 스케치 거칠기 (null이면 테마 기본값)
- **seed**: int - 스케치 렌더링 시드 (기본값: 100, 재현 가능한 무작위성)

## 데모 앱 화면 구성 (app_bar_demo.dart)

### 상태 변수

```dart
bool _showShadow = true;
bool _showSketchBorder = false; // 새로 추가
```

### 토글 컨트롤

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text('그림자 표시'),
    SketchSwitch(
      value: _showShadow,
      onChanged: (v) => setState(() => _showShadow = v),
    ),
    const SizedBox(width: SketchDesignTokens.spacingMd),
    const Text('스케치 테두리'),
    SketchSwitch(
      value: _showSketchBorder,
      onChanged: (v) => setState(() => _showSketchBorder = v),
    ),
  ],
)
```

### 데모 변형

1. **기본 스케치 앱바**
   - title: "홈"
   - showSketchBorder: _showSketchBorder
   - showShadow: _showShadow
   - leading: SizedBox.shrink() (뒤로가기 버튼 숨김)

2. **액션 버튼 + 스케치**
   - title: "설정"
   - showSketchBorder: _showSketchBorder
   - showShadow: _showShadow
   - actions: [search, menu] (SketchIconButton)

3. **커스텀 leading + 스케치**
   - title: "메뉴"
   - showSketchBorder: _showSketchBorder
   - showShadow: _showShadow
   - leading: SketchIconButton(icon: Icons.menu)

4. **스케치 + 그림자 동시 적용**
   - title: "조합 스타일"
   - showSketchBorder: true (강제)
   - showShadow: true (강제)
   - 토글과 무관하게 두 효과를 동시에 보여줌

## 엣지 케이스 처리

### 앱바 높이가 매우 작을 때 (height < 48)

- **최소 높이 제약**: preferredSize의 height는 최소 48dp 권장
- **strokeWidth 자동 조절 없음**: 개발자가 height를 작게 설정하면 테두리가 겹칠 수 있음 (의도적 선택)

### 커스텀 backgroundColor 사용

- **대비 보장**: 사용자 지정 배경색에서도 borderColor가 테마에서 자동 선택됨
- **수동 조정 가능**: strokeWidth, roughness 파라미터로 세밀 조정 가능

### 그림자와 스케치 테두리 동시 사용

- **시각적 충돌 없음**: Stack 레이어 분리로 그림자는 하단, 스케치는 상단
- **자연스러운 렌더링**: 그림자가 스케치 영역 전체에 적용되어 입체감 제공

### 다국어 긴 제목

- **TextOverflow.ellipsis**: 제목이 너무 길면 "..." 처리
- **스케치 테두리 레이아웃 유지**: 텍스트 길이와 무관하게 앱바 전체 너비에 테두리 렌더링

### StatusBar 높이 변화 (노치/펀치홀)

- **동적 padding**: MediaQuery.of(context).padding.top으로 자동 조정
- **스케치 테두리 위치**: Container의 padding이 아닌 전체 앱바 영역에 렌더링되므로 영향 없음

## 비즈니스 규칙

1. **스케치 테두리는 앱바 전체 영역에 표시** (상단, 하단, 좌우 모두 포함)
2. **기본값 showSketchBorder: false** 유지 (기존 앱 호환성, opt-in 방식)
3. **seed 파라미터는 고정값 100 사용** (매번 다른 모양 방지, 일관성 확보)
4. **roughness는 SketchThemeExtension 기본값 사용** (0.8 → 1.4로 증폭)
5. **스케치 테두리 두께는 strokeStandard * 1.5** (2.0 → 3.0, SketchContainer와 동일)
6. **borderRadius: 0.0** (앱바는 직각, SketchContainer와 달리 둥근 모서리 없음)

## SketchDesignTokens 참고값

- **strokeStandard**: 2.0
- **roughness**: 0.8
- **bowing**: 1.0
- **irregularBorderRadius**: 12.0 (앱바는 0.0 사용)
- **noiseIntensity**: 0.03
- **noiseGrainSize**: 1.5
- **spacingSm**: 8
- **spacingMd**: 16
- **spacingLg**: 24
- **spacing2Xl**: 32
- **fontFamilyHand**: "Nanum Pen Script"
- **fontSizeLg**: 18
- **fontSizeBase**: 14

## 구현 우선순위

1. **SketchAppBar 위젯 수정** (showSketchBorder 파라미터 추가 및 렌더링 로직 분기)
2. **2-pass SketchPainter 적용** (CustomPaint 중첩)
3. **그림자 + 스케치 동시 지원** (Stack 레이어 구조)
4. **데모 앱 업데이트** (토글 스위치 추가, 새 변형 예제)

## 성능 고려사항

- **CustomPaint 사용**: SketchPainter는 shouldRepaint에서 불필요한 리빌드 방지
- **2-pass 렌더링**: 두 번 그리지만 앱바 영역이 작아 성능 영향 미미
- **고정 seed**: 매번 동일한 경로 생성으로 렌더링 일관성 보장
- **const 생성자 제한**: SketchPainter는 CustomPainter이므로 const 불가, 하지만 앱바는 화면당 1개만 존재하므로 영향 적음

## 참고 자료

- **SketchContainer**: 2-pass SketchPainter 패턴의 참조 구현
- **SketchPainter**: RRect path metric 기반 스케치 테두리 생성 로직
- **SketchThemeExtension**: 라이트/다크 테마별 색상 및 스케치 속성 관리
- **Material Design 3**: AppBar 기본 가이드라인 (높이, 터치 영역 등)
- **Frame0 스타일**: 손그림 미학, 불규칙한 테두리, 종이 질감

## 구현 완료 후 검증 사항

1. **라이트 모드에서 스케치 테두리 표시**: 어두운 테두리(#343434)가 크림 배경(#FAF8F5) 위에 명확히 표시
2. **다크 모드에서 스케치 테두리 표시**: 밝은 테두리(#FFFFFF)가 어두운 배경(#23273A) 위에 명확히 표시
3. **2-pass 효과 확인**: 테두리가 겹쳐져 손으로 덧칠한 듯한 질감
4. **그림자 + 스케치 동시 적용**: 시각적 충돌 없이 조화롭게 렌더링
5. **데모 앱 토글 동작**: showSketchBorder, showShadow 토글이 즉시 반영됨
6. **SketchContainer와 일관성**: 동일한 seed 값일 때 유사한 스케치 느낌
7. **성능 확인**: 앱바 렌더링 시 버벅임 없음, 60fps 유지
