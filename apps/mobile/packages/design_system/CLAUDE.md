# Design System — Frame0 Sketch Style Flutter UI

손으로 그린 와이어프레임 미학의 Flutter UI 컴포넌트 패키지.

## 렌더링 원칙 (5대 시각 특징)

1. **Jittered Border**: RRect → 6px 샘플링 → 법선 ±roughness jitter → quadraticBezierTo. roughness: 0.0(직선) / 0.8(기본) / 1.8(거친)
2. **2-pass 렌더링**: 동일 경로를 다른 seed로 2회 (1st: fill+noise+border seed, 2nd: border only seed+50). 컨테이너: strokeWidth×1.5, roughness×1.75
3. **노이즈 텍스처**: `enableNoise: true`, intensity=0.035, grainSize=1.5px, seed+1000, clipPath 내부
4. **빗금(Hatching)**: 45° / 6dp / 4px 샘플링 → 비활성화 상태 표현
5. **모노크롬 + 손글씨**: Light(크림 `#FAF8F5`) / Dark(네이비 `#1A1D29`). 폰트: Loranthus(라틴) → KyoboHandwriting2019(한글 폴백) → JetBrainsMono(코드)

## 위젯 규칙

**네이밍**: 클래스 `Sketch`+PascalCase, 파일 `sketch_`+snake_case, Painter 접미사 `Painter`. 예외: `SocialLoginButton`, `HatchingPainter`, `XCrossPainter`

**공통 파라미터**: `fillColor?`, `borderColor?`, `strokeWidth?`, `roughness?`, `showBorder = true`, `seed = 0`

**3단계 테마 폴백**: 위젯 직접값 → `SketchThemeExtension.maybeOf(context)` → `SketchDesignTokens` 상수

**const 생성자 필수** (GetX Obx 호환). **주석 한글**, 기술 용어만 영어.

## 테마 시스템

### SketchThemeExtension (23속성)

렌더링(`strokeWidth`, `roughness`, `bowing`) | 색상(`borderColor`, `fillColor`, `surfaceColor`) | 텍스트(`textColor`, `textSecondaryColor`) | 인터랙션(`linkColor`, `iconColor`, `focusBorderColor`) | 비활성화(`disabledFillColor/BorderColor/TextColor`) | 그림자(`shadowOffset/Blur/Color`) | 배지(`badgeColor/TextColor`) | 스낵바(`success/info/warning/error SnackbarBgColor`)

### 프리셋 6가지

| 팩토리 | strokeWidth | roughness | bowing | 용도 |
|--------|-------------|-----------|--------|------|
| `.light()` / `.dark()` | standard (2.0) | 0.8 | 0.5 | 기본 테마 |
| `.rough()` | bold (3.0) | 1.2 | 0.8 | 거친 스케치 강조 |
| `.smooth()` | thin (1.0) | 0.3 | 0.2 | 미니멀 |
| `.ultraSmooth()` | thin (1.0) | 0.0 | 0.0 | 스케치 효과 없음 |
| `.veryRough()` | bold (3.0) | 1.8 | 1.2 | 예술적/표현적 |

**새 속성 추가 시**: final 필드 → 생성자 기본값(DesignTokens) → 6개 팩토리 → copyWith → lerp → == / hashCode → toString

## 디자인 토큰

`packages/core/lib/sketch_design_tokens.dart` — UI 무의존 순수 상수.

- **선 두께**: thin(1.0) / standard(2.0) / bold(3.0) / thick(4.0)
- **색상**: Grayscale 10단계(white~black) + accentPrimary(`#2196F3`) / accentSecondary(`#DF7D5F`) + 의미론 4색(success/warning/error/info) + 80% 투명 변형(`graySketch*`)
- **간격**: 8px 그리드 — xs(4) ~ 4xl(64)
- **타이포**: xs(12) ~ 6xl(60)
- **불투명도**: disabled(0.4) / subtle(0.6) / sketch(0.8) / full(1.0)

## Painter 아키텍처

**핵심 렌더러 SketchPainter**: fill → noise(clipPath) → border 순서.

| Painter | 도형 | 특수 기법 |
|---------|------|----------|
| `SketchPainter` | RRect | 6px 샘플링 + 법선 jitter + 노이즈 |
| `SketchCirclePainter` | 원/타원 | 세그먼트 기반, 2-pass |
| `SketchLinePainter` | 선/화살표 | 점선, 화살촉(none/start/end/both), 4px |
| `SketchPolygonPainter` | 다각형/별 | 3변+, 회전 |
| `AnimatedSketchPainter` | RRect | progress 0~1 |
| `XCrossPainter` | X-cross | 배경+테두리+대각선 |
| `HatchingPainter` | 빗금 | 45°, 6dp, 4px |
| `SketchSnackbarIconPainter` | 아이콘 | 원+기호(✓, i, !, ✗) |
| `SketchXClosePainter` | X 닫기 | 2-pass, 4세그먼트 |
| `SketchTabPainter` | 폴더 탭 | 상단 둥근, 하단 직선 |

**새 Painter 규칙**: CustomPainter 상속, DesignTokens 기본값, seed 재현, shouldRepaint 전필드 비교, 직선 4px / 곡선 6px, strokeCap/Join = round

## 위젯 카탈로그 (25개, deprecated 3)

- **입력**: `SketchInput`(6모드 통합), `SketchTextArea`, `SketchDropdown<T>` | ~~NumberInput, SearchInput~~ → `SketchInput(mode:)`
- **버튼**: `SketchButton`(4style×3size), `SketchIconButton`(circle/square, 배지), `SocialLoginButton`(4사)
- **선택**: `SketchCheckbox`(tristate), `SketchRadio<T>`, `SketchSwitch`(빗금), `SketchSlider`(divisions), `SketchChip`
- **레이아웃**: `SketchContainer`(기반, 2-pass), `SketchCard`(h/b/f, elevation 0-3), `SketchModal`(scale+fade), `SketchDivider`
- **피드백**: `SketchSnackbar`(4타입, `showSketchSnackbar()`), `SketchProgressBar`(linear/circular)
- **내비게이션**: `SketchAppBar`, `SketchTabBar`(폴더형, 배지), `SketchBottomNavigationBar`(3라벨모드), `SketchLink`
- **표시**: `SketchAvatar`(6크기, 2모양), `SketchImagePlaceholder`(X-cross)

## 새 위젯 추가 체크리스트

파일(`lib/src/widgets/sketch_[name].dart`) → export(`design_system.dart`) → 공통 파라미터 → 3단계 테마 폴백 → const 생성자 → Painter(필요시 2-pass) → 다크모드(`brightness` 분기) → `Semantics` 접근성 → 한글 dartdoc → Enum(`lib/src/enums/`, 배럴 export)

## 의존성

flutter, get(^4.6.6), flutter_svg(^2.0.10+1), core(path). 외부 의존성 최소화, core 외 내부 패키지 의존 금지.

## 구조

`lib/design_system.dart`(배럴) → `src/` { `enums/`(7) | `painters/`(10) | `theme/` | `widgets/`(25) }
`assets/` { `fonts/`(3family) | `social_login/`(4svg) }

## 참고

- 디자인 토큰 정의: `packages/core/lib/sketch_design_tokens.dart`
- 디자인 토큰 JSON: `.claude/guide/mobile/design-tokens.json`
- 레퍼런스 앱: `apps/design_system_demo/`
- 디자인 시스템 가이드: `.claude/guide/mobile/design_system.md`
