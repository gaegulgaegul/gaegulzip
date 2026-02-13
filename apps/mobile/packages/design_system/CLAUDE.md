# Design System CLAUDE.md

Frame0 스케치 스타일 Flutter UI 컴포넌트 패키지. 손으로 그린 와이어프레임 미학을 코드로 구현.

## 디자인 정체성 — Frame0 Sketch Style

**핵심 미학**: 손으로 노트에 스케치한 와이어프레임 느낌

이 디자인 시스템의 모든 요소는 아래 5가지 시각적 특징을 따른다:

### 1. 불규칙한 테두리 (Jittered Border)

RRect 경로를 6px 간격으로 포인트 샘플링 → 법선 방향으로 `±roughness` jitter → 이차 베지어 곡선으로 연결.

```
[이상적 RRect] → computeMetrics() → 6px 간격 샘플링 (20~200개)
    → 각 포인트의 접선에서 법선 방향 jitter ±(roughness * 1.0)
    → quadraticBezierTo로 부드럽게 연결 → 스케치 경로
```

- `roughness 0.0`: 완벽한 직선 (스케치 효과 없음)
- `roughness 0.8`: 기본값 (은은한 손그림 느낌)
- `roughness 1.8`: 매우 거친 손그림

### 2. 2-pass 테두리 렌더링

`SketchContainer`는 동일 경로를 **다른 seed**로 2번 겹쳐 그린다:

```dart
// 1st pass: 채우기 + 노이즈 + 테두리 (seed)
// 2nd pass: 테두리만 (seed + 50, fillColor: transparent, enableNoise: false)
```

컨테이너 전용 질감 증폭:
- `containerStrokeWidth = effectiveStrokeWidth * 1.5`
- `containerRoughness = effectiveRoughness * 1.75`

새 위젯에서 2-pass가 필요한 경우 이 패턴을 따른다.

### 3. 노이즈 텍스처 (Paper Texture)

종이 같은 질감을 위한 미세한 점 패턴. `SketchPainter`의 `enableNoise: true`로 활성화.

- 강도: `noiseIntensity = 0.035` (0.02-0.05 권장)
- 입자 크기: `noiseGrainSize = 1.5px` (반지름 0.75)
- 점 개수: `(width * height / 100).clamp(50, 500)`
- 시드: `seed + 1000` (테두리와 다른 시드)
- 스케치 경로 내부에만 렌더링 (`canvas.clipPath`)

### 4. 빗금 패턴 (Hatching)

비활성화/특수 상태를 표현하는 대각선 빗금:

- 각도: 45도
- 간격: 6dp
- 라인 샘플링: 4px
- 용도: `SketchButton(style: hatching)`, `SketchSwitch` 비활성화 상태

### 5. 모노크롬 미학 + 손글씨 폰트

| 요소 | Light | Dark |
|------|-------|------|
| 배경 | 크림색 `#FAF8F5` | 네이비 `#1A1D29` |
| 테두리 | `base900` `#343434` | `base700` `#5E5E5E` |
| 텍스트 | `base900` `#343434` | `textOnDark` `#F5F5F5` |
| 표면(카드) | `base100` `#F7F7F7` | `surfaceDark` `#23273A` |
| 강조 | `accentPrimary` `#2196F3` | `linkBlueDark` `#64B5F6` |

폰트:
- **Loranthus** — 메인 손글씨 (라틴/그리스/키릴)
- **KyoboHandwriting2019** — 한글 손글씨 (폴백)
- **JetBrainsMono** — 코드, 숫자, 기술적 텍스트

## 위젯 개발 규칙

### 네이밍

- 위젯 클래스: `Sketch` 접두사 + PascalCase → `SketchButton`, `SketchCard`
- 파일명: `sketch_` 접두사 + snake_case → `sketch_button.dart`
- Enum: `Sketch` 접두사 + 기능명 → `SketchButtonStyle`, `SketchAvatarSize`
- Painter: `Sketch` 접두사 + `Painter` 접미사 → `SketchCirclePainter`
- 예외: `SocialLoginButton` (외부 가이드라인 준수 위젯), `HatchingPainter`, `XCrossPainter` (범용 painter)

### 공통 파라미터 패턴

모든 스케치 스타일 위젯은 아래 파라미터를 **선택적으로** 지원한다:

```dart
const SketchWidget({
  this.fillColor,       // Color? — null이면 테마 기본값
  this.borderColor,     // Color? — null이면 테마 기본값
  this.strokeWidth,     // double? — null이면 테마 기본값
  this.roughness,       // double? — null이면 테마 기본값
  this.showBorder = true, // bool — 테두리 표시 여부
  this.seed = 0,        // int — 재현 가능한 무작위 시드
});
```

### 테마 폴백 패턴

위젯 `build()` 내에서 항상 3단계 폴백을 따른다:

```dart
final sketchTheme = SketchThemeExtension.maybeOf(context);

final effectiveFillColor =
    fillColor ?? sketchTheme?.fillColor ?? SketchDesignTokens.white;
final effectiveBorderColor =
    borderColor ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
final effectiveStrokeWidth =
    strokeWidth ?? sketchTheme?.strokeWidth ?? SketchDesignTokens.strokeStandard;
final effectiveRoughness =
    roughness ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;
```

1. 위젯에 직접 전달된 값
2. `SketchThemeExtension`의 테마 값
3. `SketchDesignTokens`의 상수 폴백

**`maybeOf(context)` 사용** — 테마 미설정 환경에서도 동작하도록.

### const 생성자 필수

모든 위젯은 `const` 생성자를 제공한다. GetX `Obx` 반응형 위젯과의 호환성을 위해 필수.

### 주석 언어

모든 주석은 **한글**로 작성. 기술 용어(API, JSON, Widget 등)만 영어.

## 테마 시스템

### SketchThemeExtension (23개 속성)

| 카테고리 | 속성 | 기본값 (Light) |
|---------|------|---------------|
| 렌더링 | `strokeWidth` | `strokeStandard` (2.0) |
| | `roughness` | `0.8` |
| | `bowing` | `0.5` |
| 색상 | `borderColor` | `base900` (#343434) |
| | `fillColor` | `white` (#FFFFFF) / light: `background` (#FAF8F5) |
| | `surfaceColor` | `base100` (#F7F7F7) |
| 텍스트 | `textColor` | `base900` (#343434) |
| | `textSecondaryColor` | `base500` (#8E8E8E) |
| 인터랙션 | `linkColor` | `linkBlue` (#2196F3) |
| | `iconColor` | `base600` (#767676) |
| | `focusBorderColor` | `black` (#000000) |
| 비활성화 | `disabledFillColor` | `base100` (#F7F7F7) |
| | `disabledBorderColor` | `base300` (#DCDCDC) |
| | `disabledTextColor` | `base500` (#8E8E8E) |
| 그림자 | `shadowOffset` | `Offset(0, 2)` |
| | `shadowBlur` | `4.0` |
| | `shadowColor` | `rgba(0,0,0,0.15)` |
| 배지 | `badgeColor` | `error` (#F44336) |
| | `badgeTextColor` | `white` (#FFFFFF) |
| 스낵바 | `successSnackbarBgColor` | `#D4EDDA` (연한 민트) |
| | `infoSnackbarBgColor` | `#D6EEFF` (연한 하늘) |
| | `warningSnackbarBgColor` | `#FFF9D6` (연한 레몬) |
| | `errorSnackbarBgColor` | `#FFE0E0` (연한 분홍) |

### 프리셋 6가지

| 팩토리 | strokeWidth | roughness | bowing | 용도 |
|--------|-------------|-----------|--------|------|
| `.light()` | standard (2.0) | 0.8 | 0.5 | 기본 라이트 테마 |
| `.dark()` | standard (2.0) | 0.8 | 0.5 | 기본 다크 테마 |
| `.rough()` | bold (3.0) | 1.2 | 0.8 | 거친 스케치 강조 |
| `.smooth()` | thin (1.0) | 0.3 | 0.2 | 미니멀, 부드러움 |
| `.ultraSmooth()` | thin (1.0) | 0.0 | 0.0 | 스케치 효과 없음 |
| `.veryRough()` | bold (3.0) | 1.8 | 1.2 | 예술적/표현적 |

### 새 테마 속성 추가 시 체크리스트

1. `SketchThemeExtension`에 `final` 필드 추가
2. 생성자 기본값 설정 (SketchDesignTokens 상수 사용)
3. `light()`, `dark()` 팩토리에 라이트/다크 값 설정
4. `rough()`, `smooth()`, `ultraSmooth()`, `veryRough()` — 해당하면 설정
5. `copyWith()`에 파라미터 추가
6. `lerp()`에 보간 로직 추가 (Color → `Color.lerp`, double → `lerpDouble`, Offset → `Offset.lerp`)
7. `==` 연산자와 `hashCode`에 추가
8. `toString()`에 추가

## 디자인 토큰 (core 패키지)

토큰은 `packages/core/lib/sketch_design_tokens.dart`에 정의. UI 의존성 없는 순수 상수 클래스.

### 선 두께

| 토큰 | 값 | 용도 |
|------|-----|------|
| `strokeThin` | 1.0px | 텍스트 밑줄, 세밀한 디테일 |
| `strokeStandard` | 2.0px | 도형 테두리, 대부분 UI 요소 (기본값) |
| `strokeBold` | 3.0px | 강조, 선택 상태 |
| `strokeThick` | 4.0px | 타이틀, 포커스 표시 |

### 색상 팔레트

**Grayscale (10단계)**: white → base100 → base200 → base300 → base400 → base500 → base600 → base700 → base900 → black

**강조색**:
- `accentPrimary` (#2196F3) — 메인 파랑, seedColor
- `accentSecondary` (#DF7D5F) — 코랄/오렌지, CTA 버튼 전용
- 각 강조색에 Light/Dark/Alpha 변형 존재

**의미론적**: success (#4CAF50), warning (#FFC107), error (#F44336), info (#2196F3) + Dark 변형

**80% 투명 변형** (`graySketch*`): 스케치 오버레이, 반투명 효과용

### 간격 (8px 그리드)

xs(4) → sm(8) → md(12) → lg(16) → xl(24) → 2xl(32) → 3xl(48) → 4xl(64)

### 타이포그래피

xs(12) → sm(14) → base(16) → lg(18) → xl(20) → 2xl(24) → 3xl(30) → 4xl(36) → 5xl(48) → 6xl(60)

### 불투명도

| 토큰 | 값 | 용도 |
|------|-----|------|
| `opacityDisabled` | 0.4 | 비활성화 상태 |
| `opacitySubtle` | 0.6 | 은은한 표현 |
| `opacitySketch` | 0.8 | 80% 투명 변형 (graySketch*) |
| `opacityFull` | 1.0 | 완전 불투명 |

## Painter 아키텍처

### 핵심 렌더러: SketchPainter

모든 위젯의 기반. 렌더링 순서:
1. **채우기** (fillPaint, PaintingStyle.fill)
2. **노이즈 텍스처** (clipPath 내부, seed+1000)
3. **테두리** (borderPaint, strokeCap/Join: round)

### Painter 목록 (10개)

| Painter | 도형 | 특수 기법 |
|---------|------|----------|
| `SketchPainter` | RRect | 6px 샘플링 + 법선 jitter + 노이즈 |
| `SketchCirclePainter` | 원/타원 | 세그먼트 기반, 2-pass |
| `SketchLinePainter` | 선/화살표 | 점선, 화살촉 (none/start/end/both), 4px 샘플링 |
| `SketchPolygonPainter` | 다각형/별 | 3변+, 회전 |
| `AnimatedSketchPainter` | RRect | progress 0~1 점진적 렌더링 |
| `XCrossPainter` | X-cross | 배경 + 테두리 + 대각선 2개 |
| `HatchingPainter` | 빗금 | 45도, 6dp 간격, 4px 샘플링 |
| `SketchSnackbarIconPainter` | 타입별 아이콘 | 원+기호 (✓, i, !, ✗) |
| `SketchXClosePainter` | X 닫기 | 대각선 2개, 2-pass, 4세그먼트 |
| `SketchTabPainter` | 폴더 탭 | 상단 둥근 모서리, 하단 직선 |

### 새 Painter 작성 규칙

1. `CustomPainter`를 상속
2. `SketchDesignTokens` 상수를 기본값으로 사용
3. `seed` 파라미터로 재현 가능한 무작위성 보장
4. `shouldRepaint()`에서 모든 필드 비교
5. 샘플링 간격: 직선 4px, 곡선/RRect 6px
6. `strokeCap`과 `strokeJoin`은 항상 `StrokeCap.round`, `StrokeJoin.round`

## 위젯 카탈로그

### 입력 (4개 활성)

| 위젯 | 핵심 기능 |
|------|----------|
| `SketchInput` | 6가지 모드 통합 (default, search, date, time, datetime, number) |
| `SketchTextArea` | 글자 수 카운터, resize handle |
| `SketchDropdown<T>` | overlay 항목 목록, 제네릭 타입 |
| ~~`SketchNumberInput`~~ | **deprecated** → `SketchInput(mode: number)` |
| ~~`SketchSearchInput`~~ | **deprecated** → `SketchInput(mode: search)` |

### 버튼 (3개)

| 위젯 | 핵심 기능 |
|------|----------|
| `SketchButton` | 4 스타일 × 3 크기 (primary/secondary/outline/hatching × small32/medium44/large56) |
| `SketchIconButton` | circle/square, 배지, 툴팁 |
| `SocialLoginButton` | 카카오/네이버/애플/구글 공식 가이드라인 |

### 선택 (5개)

| 위젯 | 핵심 기능 |
|------|----------|
| `SketchCheckbox` | tristate, 체크마크 애니메이션 |
| `SketchRadio<T>` | 그룹 단일 선택, 제네릭 타입 |
| `SketchSwitch` | 비활성화 시 빗금 |
| `SketchSlider` | divisions, 드래그 중 라벨 |
| `SketchChip` | 선택/삭제/아이콘 |

### 레이아웃 (4개)

| 위젯 | 핵심 기능 |
|------|----------|
| `SketchContainer` | **기반 위젯** — 2-pass 테두리, 노이즈 텍스처 |
| `SketchCard` | header/body/footer, elevation 0-3 |
| `SketchModal` | scale+fade, 스케치 X 닫기 |
| `SketchDivider` | 수평/수직, 손그림/직선 |

### 피드백 (2개)

| 위젯 | 핵심 기능 |
|------|----------|
| `SketchSnackbar` | 4 타입, `showSketchSnackbar()` 편의 함수 |
| `SketchProgressBar` | linear/circular, determinate/indeterminate |

### 내비게이션 (4개)

| 위젯 | 핵심 기능 |
|------|----------|
| `SketchAppBar` | 자동 뒤로가기, 액션 |
| `SketchTabBar` | 폴더 탭 카드형, 배지, 2~5개 탭 |
| `SketchBottomNavigationBar` | 라벨 모드 (alwaysShow/onlyShowSelected/neverShow) |
| `SketchLink` | 밑줄, 방문 여부, 아이콘 위치 |

### 표시 (2개)

| 위젯 | 핵심 기능 |
|------|----------|
| `SketchAvatar` | 6 크기 (xs24~xxl120), 2 모양 (circle/roundedSquare) |
| `SketchImagePlaceholder` | X-cross 패턴, 4 프리셋 크기 |

## 새 위젯 추가 체크리스트

1. **파일**: `lib/src/widgets/sketch_[name].dart` 생성
2. **Export**: `lib/design_system.dart`에 export 추가
3. **공통 파라미터**: fillColor, borderColor, strokeWidth, roughness, showBorder, seed 지원
4. **테마 폴백**: `SketchThemeExtension.maybeOf(context)` → 3단계 폴백
5. **const 생성자**: 필수
6. **렌더링**: `SketchPainter` 또는 전용 Painter 사용, 필요 시 2-pass
7. **다크모드**: `Theme.of(context).brightness` 분기 처리
8. **접근성**: `Semantics` 위젯으로 스크린 리더 지원
9. **주석**: 클래스/공개 API에 한글 dartdoc
10. **Enum**: 위젯 전용 Enum은 `lib/src/enums/`에, 배럴 파일에 export

## 의존성

```yaml
dependencies:
  flutter: sdk
  get: ^4.6.6              # GetX (SketchThemeController, 반응형 위젯)
  flutter_svg: ^2.0.10+1   # SVG (소셜 로그인 로고)
  core:                     # SketchDesignTokens (path 의존)
    path: ../core
```

새 외부 의존성 추가는 최소화. `core` 패키지 외 내부 패키지 의존 금지.

## 디렉토리 구조

```
lib/
├── design_system.dart           # 배럴 export
└── src/
    ├── enums/                   # 위젯별 Enum (7개)
    ├── painters/                # CustomPainter (10개)
    ├── theme/                   # 테마 확장 + 컨트롤러
    └── widgets/                 # UI 위젯 (25개, deprecated 3개 포함)
assets/
├── fonts/                       # Loranthus, KyoboHandwriting2019, JetBrainsMono
└── social_login/                # 소셜 로그인 SVG 로고 4개
```

## 참고

- 디자인 토큰 정의: `packages/core/lib/sketch_design_tokens.dart`
- 디자인 토큰 JSON: `.claude/guide/mobile/design-tokens.json`
- 레퍼런스 앱: `apps/design_system_demo/`
- 디자인 시스템 가이드: `.claude/guide/mobile/design_system.md`
