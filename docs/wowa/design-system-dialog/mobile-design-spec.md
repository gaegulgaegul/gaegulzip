# UI/UX 디자인 명세: Design System Dialog 리디자인

## 개요

`SketchModal` 컴포넌트를 Frame0 스케치 스타일로 완전히 리디자인하여 에셋 이미지(dialog-light-mode.png, dialog-dark-mode.png)와 일치시킨다. 기존의 `BoxDecoration` 기반 렌더링을 `CustomPaint` + `SketchPainter` 기반으로 전환하고, 손그림 스타일의 닫기 버튼(X 마크)과 빗금 패턴(hatching) 버튼 스타일을 추가한다.

## 화면 구조

### Screen 1: SketchModal (리디자인)

#### 레이아웃 계층

```
Dialog (Material)
└── FadeTransition (진입 애니메이션)
    └── ScaleTransition (팝업 애니메이션)
        └── CustomPaint (SketchPainter — 모달 배경/테두리)
            └── Padding (내부 패딩: 24dp)
                ├── Row (헤더)
                │   ├── Text (제목 — 손글씨 폰트)
                │   └── CustomPaint (손그림 X 닫기 버튼)
                │
                ├── SizedBox(height: 16dp)
                │
                ├── Flexible (본문 콘텐츠)
                │   └── SingleChildScrollView
                │       └── [child widget]
                │
                └── Wrap (액션 버튼들 — 우측 정렬)
                    ├── SketchButton (Cancel — outline 스타일)
                    └── SketchButton (OK — hatching 스타일)
```

#### 위젯 상세

**CustomPaint (모달 배경)**
- painter: SketchPainter
  - fillColor: theme.fillColor (light: #FAF8F5, dark: #1A1D29)
  - borderColor: theme.borderColor (light: #343434, dark: #5E5E5E)
  - strokeWidth: SketchDesignTokens.strokeStandard (2.0)
  - roughness: SketchDesignTokens.roughness (0.8)
  - enableNoise: true
  - showBorder: true
  - borderRadius: SketchDesignTokens.irregularBorderRadius (12.0)
- size:
  - width: 400dp (기본값), maxWidth: 화면 너비의 90%
  - height: 자동 (콘텐츠 높이), maxHeight: 화면 높이의 90%

**Text (제목)**
- fontFamily: SketchDesignTokens.fontFamilyHand ('Loranthus')
- fontFamilyFallback: ['KyoboHandwriting2019']
- fontSize: SketchDesignTokens.fontSizeLg (18.0)
- fontWeight: FontWeight.w600
- color: theme.textColor (light: #343434, dark: #F5F5F5)
- 위치: 좌상단

**CustomPaint (손그림 X 닫기 버튼)**
- painter: SketchXClosePainter (신규 생성)
  - strokeColor: theme.iconColor (light: #767676, dark: #B5B5B5)
  - strokeWidth: SketchDesignTokens.strokeStandard (2.0)
  - roughness: SketchDesignTokens.roughness (0.8)
- size: 32x32dp
- 터치 영역: 48x48dp (Material 가이드라인 최소 터치 영역)
- 인터랙션:
  - onTapDown: AnimatedScale (scale: 0.95), background: theme.disabledFillColor
  - onTapUp: 원래 크기 복귀, Navigator.pop()
  - duration: 100ms

**SingleChildScrollView (본문)**
- padding: EdgeInsets.zero (부모 Padding에서 처리)
- physics: BouncingScrollPhysics (iOS 스타일)
- child: 사용자 제공 위젯

**Wrap (액션 버튼 영역)**
- spacing: SketchDesignTokens.spacingSm (8.0)
- runSpacing: SketchDesignTokens.spacingSm (8.0)
- alignment: WrapAlignment.end (우측 정렬)
- children: 사용자 제공 액션 버튼 리스트

**SketchButton (Cancel — outline 스타일)**
- style: SketchButtonStyle.outline
- fillColor: Colors.transparent
- borderColor: theme.textColor
- textColor: theme.textColor
- strokeWidth: SketchDesignTokens.strokeStandard (2.0)

**SketchButton (OK — hatching 스타일)**
- style: SketchButtonStyle.hatching (신규 추가)
- fillColor: Colors.transparent
- borderColor: theme.textColor
- textColor: theme.textColor
- strokeWidth: SketchDesignTokens.strokeStandard (2.0)
- hatchingPattern: 대각선 빗금 패턴 (45도)

## 색상 팔레트 (Frame0 스케치 스타일)

### Light Mode

**배경/표면**
- **fillColor**: `Color(0xFFFAF8F5)` — 크림색 배경, 종이 질감
- **surfaceColor**: `Color(0xFFF5F0E8)` — 카드/모달 표면색 (따뜻한 크림)

**테두리/선**
- **borderColor**: `Color(0xFF343434)` — base900, 어두운 손그림 테두리
- **outlinePrimary**: `Color(0xFF343434)` — 주요 테두리

**텍스트/아이콘**
- **textColor**: `Color(0xFF343434)` — base900, 주요 텍스트
- **textSecondaryColor**: `Color(0xFF8E8E8E)` — base500, 보조 텍스트
- **iconColor**: `Color(0xFF767676)` — base600, 아이콘

**비활성화**
- **disabledFillColor**: `Color(0xFFF7F7F7)` — base100
- **disabledBorderColor**: `Color(0xFFDCDCDC)` — base300
- **disabledTextColor**: `Color(0xFF8E8E8E)` — base500

### Dark Mode

**배경/표면**
- **fillColor**: `Color(0xFF1A1D29)` — 어두운 네이비 배경
- **surfaceColor**: `Color(0xFF23273A)` — 카드/모달 표면색

**테두리/선**
- **borderColor**: `Color(0xFF5E5E5E)` — base700, 밝은 손그림 테두리
- **outlinePrimary**: `Color(0xFF5E5E5E)` — 주요 테두리

**텍스트/아이콘**
- **textColor**: `Color(0xFFF5F5F5)` — 밝은 주요 텍스트
- **textSecondaryColor**: `Color(0xFFB0B0B0)` — 밝은 보조 텍스트
- **iconColor**: `Color(0xFFB5B5B5)` — base400, 밝은 아이콘

**비활성화**
- **disabledFillColor**: `Color(0xFF2C3048)` — surfaceVariantDark
- **disabledBorderColor**: `Color(0xFF5E5E5E)` — outlinePrimaryDark
- **disabledTextColor**: `Color(0xFF6E6E6E)` — textDisabledDark

## 타이포그래피 (Frame0 손글씨 폰트)

### 제목 (Title)
- **fontFamily**: 'Loranthus' — 손글씨 폰트 (라틴/그리스/키릴)
- **fontFamilyFallback**: ['KyoboHandwriting2019'] — 한글 손글씨 폰트
- **fontSize**: 18.0 (SketchDesignTokens.fontSizeLg)
- **fontWeight**: FontWeight.w600
- **height**: 1.3 (line height)
- **용도**: 모달 제목 "Dialog"

### 본문 (Body)
- **fontFamily**: 'Loranthus' — 손글씨 폰트
- **fontFamilyFallback**: ['KyoboHandwriting2019']
- **fontSize**: 16.0 (SketchDesignTokens.fontSizeBase)
- **fontWeight**: FontWeight.w400
- **height**: 1.5 (line height)
- **용도**: 모달 본문 "This is dialog message ..."

### 버튼 라벨 (Button Label)
- **fontFamily**: 'Loranthus' — 손글씨 폰트
- **fontFamilyFallback**: ['KyoboHandwriting2019']
- **fontSize**: 16.0 (SketchDesignTokens.fontSizeBase)
- **fontWeight**: FontWeight.w400
- **height**: 1.2 (line height)
- **용도**: "Cancel", "OK" 버튼 텍스트

## 스페이싱 시스템 (8dp 그리드)

### Padding/Margin

**모달 내부 패딩**
- **전체 패딩**: 24dp (SketchDesignTokens.spacingXl)
- **헤더 하단 간격**: 16dp (SketchDesignTokens.spacingLg)
- **본문 하단 간격**: 24dp (SketchDesignTokens.spacingXl)

**액션 버튼 간격**
- **버튼 사이 간격**: 8dp (SketchDesignTokens.spacingSm)
- **버튼 줄 간격**: 8dp (runSpacing)

**닫기 버튼**
- **터치 영역**: 48x48dp (Material 최소 터치 영역)
- **시각 영역**: 32x32dp
- **내부 아이콘**: 18x18dp

### 컴포넌트별 스페이싱

| 요소 | 간격 | 토큰 |
|------|------|------|
| 모달 전체 패딩 | 24dp | spacingXl |
| 헤더-본문 간격 | 16dp | spacingLg |
| 본문-액션 간격 | 24dp | spacingXl |
| 액션 버튼 간격 | 8dp | spacingSm |
| 닫기 버튼 터치 영역 | 48dp | — |
| 닫기 버튼 시각 영역 | 32dp | — |

## Border Radius

**모달 테두리**
- **borderRadius**: 12dp (SketchDesignTokens.irregularBorderRadius)
- **스케치 효과**: roughness 0.8 적용으로 불규칙한 둥근 모서리

**버튼 테두리**
- **borderRadius**: 12dp (SketchDesignTokens.irregularBorderRadius)
- **스케치 효과**: roughness 0.8 적용

**닫기 버튼 배경 (pressed 상태)**
- **borderRadius**: 4dp (작은 둥근 모서리)

## Elevation (그림자)

**모달 다이얼로그**
- **elevation**: 0 (Material Dialog elevation = 0)
- **그림자**: 없음 (스케치 스타일은 그림자 대신 두꺼운 테두리 사용)

**버튼**
- **elevation**: 0 (평면 스타일)
- **그림자**: 없음

## 인터랙션 상태

### 닫기 버튼 (X 마크)

**Default**
- background: Colors.transparent
- strokeColor: theme.iconColor (light: #767676, dark: #B5B5B5)
- scale: 1.0

**Pressed**
- background: theme.disabledFillColor (light: #F7F7F7, dark: #2C3048)
- strokeColor: theme.iconColor (동일)
- scale: 0.95
- duration: 100ms
- curve: Curves.easeOut

**Hover** (웹/데스크탑)
- background: theme.disabledFillColor with opacity 0.5
- 커서: pointer

### 버튼 (Cancel, OK)

**Default**
- fillColor: Colors.transparent
- borderColor: theme.textColor
- textColor: theme.textColor
- scale: 1.0

**Pressed**
- scale: 0.98
- duration: 100ms
- curve: Curves.easeOut

**Disabled**
- opacity: 0.4 (SketchDesignTokens.opacityDisabled)
- borderColor: theme.disabledBorderColor
- textColor: theme.disabledTextColor

### 모달 진입 애니메이션

**Fade**
- duration: 250ms
- curve: Curves.easeOut
- opacity: 0.0 → 1.0

**Scale**
- duration: 250ms
- curve: Curves.easeOutBack (팝업 효과)
- scale: 0.9 → 1.0

## 애니메이션

### 화면 전환

**모달 진입 (showDialog)**
- **FadeTransition**: 0.0 → 1.0, 250ms, Curves.easeOut
- **ScaleTransition**: 0.9 → 1.0, 250ms, Curves.easeOutBack
- **설명**: 모달이 페이드인과 함께 약간 확대되면서 나타남 (팝업 느낌)

**모달 종료 (Navigator.pop)**
- **FadeTransition**: 1.0 → 0.0, 200ms, Curves.easeIn
- **ScaleTransition**: 1.0 → 0.95, 200ms, Curves.easeIn
- **설명**: 모달이 축소되면서 페이드아웃

### 상태 변경

**닫기 버튼 누름**
- **AnimatedScale**: 1.0 → 0.95, 100ms, Curves.easeOut
- **배경색 변경**: transparent → disabledFillColor, 100ms

**버튼 누름**
- **AnimatedScale**: 1.0 → 0.98, 100ms, Curves.easeOut

### 로딩 (버튼 내부)

- **CircularProgressIndicator**: Material 기본 스피너
- **크기**: 버튼 fontSize와 동일
- **색상**: 버튼 textColor

## 손그림 X 닫기 버튼 스펙

### SketchXClosePainter (CustomPainter)

**렌더링 방식**
- Material `Icons.close` 대체 → CustomPaint 손그림 X 렌더링
- 두 개의 대각선 (왼쪽 상단→우측 하단, 우측 상단→왼쪽 하단)
- 각 선은 path metric 기반 스케치 렌더링 (SketchPainter와 동일한 기법)

**파라미터**
- **strokeColor**: Color — X 마크 색상 (theme.iconColor)
- **strokeWidth**: double — 선 두께 (기본값: 2.0)
- **roughness**: double — 거칠기 계수 (기본값: 0.8)
- **seed**: int — 재현 가능한 무작위성

**렌더링 상세**

```
Canvas size: 18x18dp (실제 X 마크 크기)
Padding: 7dp (32dp 터치 영역 - 18dp 시각 영역 = 14dp / 2)

Line 1: 좌상단(2, 2) → 우하단(16, 16)
Line 2: 우상단(16, 2) → 좌하단(2, 16)

각 선:
1. 이상적 경로 생성 (직선)
2. 6px 간격으로 포인트 샘플링
3. 각 포인트에 법선 방향으로 jitter 추가 (±roughness * 0.6)
4. 이차 베지어 곡선으로 부드럽게 연결
```

**스케치 효과**
- **roughness 0.8**: 약간 흔들리는 손그림 느낌
- **seed**: X 버튼마다 다른 변형 (예: title.hashCode)
- **strokeCap**: StrokeCap.round — 둥근 선 끝
- **strokeJoin**: StrokeJoin.round — 둥근 연결

**상태별 색상**
- **Default**: theme.iconColor (light: #767676, dark: #B5B5B5)
- **Pressed**: 동일 (배경만 변경)
- **Disabled**: theme.disabledTextColor (light: #8E8E8E, dark: #6E6E6E)

## 빗금 패턴 (Hatching) 스펙

### SketchButtonStyle.hatching (신규 추가)

**개요**
- OK 버튼 전용 스타일
- outline 스타일 + 내부에 대각선 빗금 패턴 채우기
- 에셋 이미지의 OK 버튼과 동일한 시각 효과

### HatchingPainter (CustomPainter)

**렌더링 방식**
- 버튼 내부 영역을 clipPath로 설정
- 대각선 빗금 선들을 반복 렌더링
- 각 빗금 선은 path metric 기반 스케치 렌더링 (약간의 흔들림)

**파라미터**
- **fillColor**: Color — 빗금 선 색상 (theme.textColor)
- **strokeWidth**: double — 빗금 선 두께 (기본값: 1.0)
- **angle**: double — 빗금 각도 (기본값: 45도 = π/4)
- **spacing**: double — 빗금 선 간격 (기본값: 6.0)
- **roughness**: double — 거칠기 계수 (기본값: 0.5 — 버튼보다 미묘함)
- **seed**: int — 재현 가능한 무작위성

**렌더링 상세**

```
1. 버튼 경로 (RRect) 생성
2. canvas.clipPath(buttonPath) — 버튼 내부만 렌더링
3. 대각선 빗금 선 생성:
   - 각도: 45도 (좌하단→우상단)
   - 간격: 6dp
   - 시작점: 좌상단 외곽 → 우하단 외곽
   - 각 선마다 seed 다르게 설정 (seed + lineIndex)

4. 각 빗금 선 렌더링:
   - 이상적 경로 생성 (직선)
   - 4px 간격으로 포인트 샘플링
   - 법선 방향으로 jitter 추가 (±roughness * 0.4)
   - 이차 베지어 곡선으로 부드럽게 연결
   - canvas.drawPath()
```

**빗금 패턴 파라미터**

| 속성 | 값 | 설명 |
|------|-----|------|
| angle | 45° (π/4) | 대각선 방향 (좌하→우상) |
| spacing | 6.0dp | 빗금 선 간격 |
| strokeWidth | 1.0dp | 빗금 선 두께 |
| roughness | 0.5 | 미묘한 흔들림 (버튼보다 부드러움) |
| opacity | 1.0 | 완전 불투명 |

**Light/Dark 모드 색상**
- **Light Mode**: fillColor = theme.textColor (#343434)
- **Dark Mode**: fillColor = theme.textColor (#F5F5F5)

### SketchButton 수정 사항

**새로운 enum 값 추가**
```dart
enum SketchButtonStyle {
  primary,
  secondary,
  outline,
  hatching, // 신규 추가
}
```

**_getColorSpec 수정**
```dart
case SketchButtonStyle.hatching:
  return _ColorSpec(
    fillColor: Colors.transparent, // 투명 배경
    borderColor: textColor,
    textColor: textColor,
    strokeWidth: SketchDesignTokens.strokeStandard,
    enableHatching: true, // 빗금 패턴 활성화
  );
```

**CustomPaint painter 수정**
- hatching 스타일일 때 HatchingPainter를 SketchPainter 위에 추가로 렌더링
- Stack 사용 또는 SketchPainter 내부에 hatching 옵션 추가

## 반응형 레이아웃

### Breakpoints

**Mobile**: width < 600dp
- 모달 width: 400dp 또는 화면 너비의 90%
- 버튼: 세로 방향 스택 가능 (Wrap이 자동 처리)

**Tablet**: 600dp ≤ width < 1024dp
- 모달 width: 500dp 또는 화면 너비의 80%
- 버튼: 가로 방향 정렬

**Desktop**: width ≥ 1024dp
- 모달 width: 600dp 또는 화면 너비의 70%
- 버튼: 가로 방향 정렬

### 적응형 레이아웃 전략

**화면 크기 감지**
```dart
final width = MediaQuery.of(context).size.width;
final modalWidth = width < 600 ? width * 0.9 :
                  width < 1024 ? 500.0 : 600.0;
```

**터치 영역**
- **최소 크기**: 48x48dp (Material Design 가이드라인)
- **닫기 버튼**: 48x48dp 터치 영역, 32x32dp 시각 영역

## 접근성 (Accessibility)

### 색상 대비

**Light Mode**
- **텍스트 대 배경**: #343434 on #FAF8F5 — 대비 11.5:1 (WCAG AAA)
- **테두리 대 배경**: #343434 on #FAF8F5 — 대비 11.5:1 (WCAG AAA)
- **아이콘 대 배경**: #767676 on #FAF8F5 — 대비 5.1:1 (WCAG AA)

**Dark Mode**
- **텍스트 대 배경**: #F5F5F5 on #1A1D29 — 대비 13.8:1 (WCAG AAA)
- **테두리 대 배경**: #5E5E5E on #1A1D29 — 대비 4.8:1 (WCAG AA)
- **아이콘 대 배경**: #B5B5B5 on #1A1D29 — 대비 7.2:1 (WCAG AAA)

### 의미 전달

**색상만으로 의미 전달 금지**
- Cancel 버튼: outline + "Cancel" 텍스트
- OK 버튼: hatching 패턴 + "OK" 텍스트
- 닫기 버튼: X 아이콘 + Semantics label

**에러 표시**
- 색상 + 아이콘 + 텍스트 메시지 병행

### 스크린 리더 지원

**Semantics**
- **모달 제목**: Semantics(label: widget.title, header: true)
- **닫기 버튼**: Semantics(label: "닫기 버튼", button: true)
- **액션 버튼**: Semantics(label: "${text} 버튼", button: true)

**포커스 순서**
1. 모달 제목
2. 본문 콘텐츠
3. 액션 버튼 (Cancel → OK)
4. 닫기 버튼

**키보드 내비게이션**
- **ESC**: 모달 닫기 (barrierDismissible이 true일 때)
- **Tab**: 포커스 이동 (제목 → 본문 → 버튼)
- **Enter/Space**: 포커스된 버튼 활성화

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

**SketchPainter** (기존 활용)
- 모달 배경/테두리 렌더링
- 노이즈 텍스처, 불규칙 테두리
- path metric 기반 스케치 렌더링

**SketchButton** (수정 활용)
- Cancel 버튼: `SketchButtonStyle.outline`
- OK 버튼: `SketchButtonStyle.hatching` (신규 추가)

### 새로운 컴포넌트 필요 여부

**SketchXClosePainter** (신규 생성)
- **목적**: 손그림 스타일 X 마크 렌더링 (Material Icons.close 대체)
- **재사용 가능성**: 높음 — SketchModal, SketchSheet, SketchBottomSheet 등에서 공통 사용 가능
- **위치**: `packages/design_system/lib/src/painters/sketch_x_close_painter.dart`

**HatchingPainter** (신규 생성)
- **목적**: 대각선 빗금 패턴 렌더링 (SketchButton.hatching 스타일 지원)
- **재사용 가능성**: 중간 — 특정 버튼 스타일이지만 다른 위젯에서도 활용 가능
- **위치**: `packages/design_system/lib/src/painters/hatching_painter.dart`

**SketchModal** (수정)
- **변경 사항**: BoxDecoration → CustomPaint + SketchPainter 교체
- **재사용 가능성**: 기존과 동일 — 모든 다이얼로그에서 사용

## 구현 전략

### 1단계: SketchXClosePainter 구현
- path metric 기반 스케치 라인 렌더링
- 두 개의 대각선 (좌상→우하, 우상→좌하)
- roughness, seed 파라미터 지원

### 2단계: HatchingPainter 구현
- clipPath 기반 영역 제한
- 대각선 빗금 선 반복 렌더링
- angle, spacing, roughness 파라미터 지원

### 3단계: SketchButton 수정
- SketchButtonStyle.hatching enum 추가
- _getColorSpec에 hatching 케이스 추가
- hatching 스타일일 때 HatchingPainter 추가 렌더링

### 4단계: SketchModal 수정
- BoxDecoration → CustomPaint + SketchPainter 교체
- Icons.close → SketchXClosePainter 교체
- 기존 레이아웃/패딩 유지

### 5단계: design_system_demo 업데이트
- ModalDemo 또는 DialogDemo에 리디자인 반영
- light/dark 모드 토글 기능
- Cancel/OK 버튼 예시 추가

## 참고 자료

- **Material Design 3**: https://m3.material.io/components/dialogs
- **Flutter CustomPaint**: https://api.flutter.dev/flutter/widgets/CustomPaint-class.html
- **Frame0 스케치 스타일**: 기존 SketchButton, SketchPainter 구현
- **에셋 이미지**: `docs/wowa/design-system-dialog/dialog-light-mode.png`, `dialog-dark-mode.png`

## 기술 노트

### SketchPainter 재사용
- 기존 path metric 기반 렌더링 로직 그대로 활용
- 모달 배경/테두리에 동일한 스케치 질감 적용
- enableNoise: true로 종이 질감 유지

### 손그림 X 마크
- Material Icons 대신 CustomPaint 사용
- SketchPainter와 동일한 path metric 기법
- 작은 크기(18x18)에서도 명확한 시각성 유지

### 빗금 패턴 렌더링 최적화
- clipPath 사용으로 버튼 외곽 렌더링 방지
- 빗금 선 개수 최소화 (spacing 6dp)
- 각 선의 포인트 샘플링 간격 조정 (4px)

### 성능 고려사항
- CustomPaint shouldRepaint 정확히 구현
- 애니메이션 중 불필요한 리페인트 방지
- const 생성자 적극 활용
