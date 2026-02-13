# Design System

Frame0 스케치 스타일 UI 컴포넌트 및 테마 패키지.

## 의존성 추가

```yaml
# pubspec.yaml
dependencies:
  design_system:
    path: ../design_system  # 또는 ../../packages/design_system
  core:
    path: ../core            # SketchDesignTokens 포함
```

```dart
import 'package:design_system/design_system.dart';
import 'package:core/core.dart'; // SketchDesignTokens
```

## 테마 연동

### _buildTheme() 패턴

light/dark 테마를 하나의 함수로 구성합니다. `design_system_demo`가 레퍼런스 구현입니다.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: _buildTheme(
        Brightness.light,
        SketchThemeExtension.light(),
      ),
      darkTheme: _buildTheme(Brightness.dark, SketchThemeExtension.dark()),
    );
  }

  ThemeData _buildTheme(Brightness brightness, SketchThemeExtension ext) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor =
        isDark ? SketchDesignTokens.base900 : SketchDesignTokens.base100;
    final surfaceColor =
        isDark ? SketchDesignTokens.surfaceDark : SketchDesignTokens.white;
    final textColor =
        isDark ? SketchDesignTokens.white : SketchDesignTokens.base900;

    return ThemeData(
      brightness: brightness,
      fontFamily: SketchDesignTokens.fontFamilyHand,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SketchDesignTokens.accentPrimary,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyHand,
          fontSize: SketchDesignTokens.fontSizeXl,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      extensions: [ext],
    );
  }
}
```

### 핵심 규칙

| 항목 | Light | Dark |
|------|-------|------|
| scaffoldBackground | `base100` (#F7F7F7) | `base900` (#343434) |
| surfaceColor | `white` (#FFFFFF) | `surfaceDark` (#23273A) |
| textColor | `base900` (#343434) | `white` (#FFFFFF) |
| seedColor | `accentPrimary` (#2196F3) | 동일 |
| fontFamily | `fontFamilyHand` (Loranthus) | 동일 |

### SketchThemeExtension

스케치 스타일 속성을 Flutter ThemeExtension으로 제공합니다.

```dart
// 위젯에서 접근
final sketchTheme = SketchThemeExtension.of(context);
```

#### 테마 속성

| 카테고리 | 속성 | 설명 |
|---------|------|------|
| 렌더링 | `strokeWidth`, `roughness`, `bowing` | 스케치 테두리 굵기, 거칠기, 휘어짐 |
| 색상 | `borderColor`, `fillColor`, `surfaceColor` | 테두리, 채우기, 표면 색상 |
| 텍스트 | `textColor`, `textSecondaryColor` | 주요/보조 텍스트 색상 |
| 인터랙션 | `linkColor`, `iconColor`, `focusBorderColor` | 링크, 아이콘, 포커스 색상 |
| 비활성화 | `disabledFillColor`, `disabledBorderColor`, `disabledTextColor` | 비활성화 상태 색상 |
| 그림자 | `shadowOffset`, `shadowBlur`, `shadowColor` | 그림자 위치, 블러, 색상 |
| 배지 | `badgeColor`, `badgeTextColor` | 배지 배경색, 배지 텍스트 색상 |
| 스낵바 | `successSnackbarBgColor`, `infoSnackbarBgColor`, `warningSnackbarBgColor`, `errorSnackbarBgColor` | 타입별 스낵바 배경색 |

#### 프리셋 변형

| 팩토리 | 설명 |
|--------|------|
| `.light()` | 라이트 테마 (크림색 배경, 어두운 테두리) |
| `.dark()` | 다크 테마 (네이비 배경, 밝은 텍스트) |
| `.rough()` | 거친 스케치 (strokeBold, roughness 1.2) |
| `.smooth()` | 부드러운 스케치 (strokeThin, roughness 0.3) |
| `.ultraSmooth()` | 거의 직선 (roughness 0.0) |
| `.veryRough()` | 매우 거친 손그림 (roughness 1.8) |

### SketchThemeController

GetX 컨트롤러. `themeMode`(system/light/dark) 관리 및 시스템 밝기 변경 자동 감지.

## 폰트 설정

폰트 파일은 `design_system/assets/fonts/`에 포함되어 있습니다.
앱에서 plain name으로 사용하려면 **폰트 파일을 앱 로컬에 복사하고 pubspec.yaml에 선언**해야 합니다.

```bash
# 폰트 파일 복사
cp packages/design_system/assets/fonts/Loranthus.ttf apps/[앱이름]/assets/fonts/
cp packages/design_system/assets/fonts/KyoboHandwriting2019.ttf apps/[앱이름]/assets/fonts/
```

```yaml
# apps/[앱이름]/pubspec.yaml
flutter:
  fonts:
    - family: Loranthus
      fonts:
        - asset: assets/fonts/Loranthus.ttf
    - family: KyoboHandwriting2019
      fonts:
        - asset: assets/fonts/KyoboHandwriting2019.ttf
```

> `KyoboHandwriting2019`는 한글 손글씨 폴백 폰트입니다.

> `packages/design_system/assets/fonts/...` 경로로 선언하면 빌드 에러가 발생합니다.
> 반드시 로컬 `assets/fonts/`에 복사 후 로컬 경로로 참조하세요.
>
> 폰트 변경은 핫 리로드로 반영되지 않으므로 **핫 리스타트**가 필요합니다.

## 다크모드 텍스트 색상

위젯에서 텍스트 색상을 직접 지정할 때는 `Theme.of(context).brightness`로 분기합니다.

```dart
Widget _buildTitle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Text(
    '제목',
    style: TextStyle(
      color: isDark ? SketchDesignTokens.white : SketchDesignTokens.base900,
    ),
  );
}
```

하드코딩하면 다크모드에서 텍스트가 배경에 묻힙니다. 토큰 매핑 참고:

| 용도 | Light | Dark |
|------|-------|------|
| 주요 텍스트 | `base900` | `white` |
| 보조 텍스트 | `base700` | `base400` |
| 비활성 텍스트 | `base500` | `base400` |

## 위젯 목록

### 입력 (Input)

| 위젯 | 설명 |
|------|------|
| `SketchInput` | 텍스트 입력 (6가지 모드: default, search, date, time, datetime, number) |
| `SketchTextArea` | 여러 줄 텍스트 입력 (글자 수 카운터, resize handle) |
| `SketchNumberInput` | **[deprecated]** `SketchInput(mode: SketchInputMode.number)` 사용 |
| `SketchDropdown` | 드롭다운 선택 (overlay 항목 목록, 커스텀 아이템 빌더) |
| `SketchSearchInput` | **[deprecated]** `SketchInput(mode: SketchInputMode.search)` 사용 |

### 버튼 (Button)

| 위젯 | 설명 |
|------|------|
| `SketchButton` | 버튼 (primary, secondary, outline, hatching / small, medium, large) |
| `SketchIconButton` | 아이콘 버튼 (circle/square, 배지, 툴팁) |
| `SocialLoginButton` | 소셜 로그인 버튼 (카카오, 네이버, 애플, 구글) |

### 선택 (Selection)

| 위젯 | 설명 |
|------|------|
| `SketchCheckbox` | 체크박스 (tristate 지원, 체크마크 애니메이션) |
| `SketchRadio` | 라디오 버튼 (그룹 단일 선택, 내부 점 애니메이션) |
| `SketchSwitch` | 스위치 토글 (애니메이션 전환, 비활성화 시 빗금) |
| `SketchSlider` | 슬라이더 (divisions, 드래그 중 라벨 표시) |
| `SketchChip` | 칩/태그 (선택 가능, 삭제 버튼, 아이콘) |

### 레이아웃 (Layout)

| 위젯 | 설명 |
|------|------|
| `SketchContainer` | 스케치 스타일 컨테이너 (2-pass 테두리 렌더링) |
| `SketchCard` | 카드 (header/body/footer, elevation 0-3) |
| `SketchModal` | 모달 다이얼로그 (scale+fade 애니메이션, 스케치 X 닫기 버튼) |
| `SketchDivider` | 구분선 (수평/수직, 손그림/직선 스타일) |

### 피드백 (Feedback)

| 위젯 | 설명 |
|------|------|
| `SketchSnackbar` | 스낵바 (success, info, warning, error / 스케치 아이콘) |
| `SketchProgressBar` | 프로그레스 바 (linear/circular, determinate/indeterminate) |

### 내비게이션 (Navigation)

| 위젯 | 설명 |
|------|------|
| `SketchAppBar` | 앱바 (자동 뒤로가기, 액션, 그림자) |
| `SketchTabBar` | 탭바 (폴더 탭 카드형 디자인, 배지) |
| `SketchBottomNavigationBar` | 하단 네비게이션 (활성 아이콘, 배지, 라벨 모드) |
| `SketchLink` | 링크 텍스트 (밑줄, 호버/눌림, 방문 여부, 아이콘) |

### 표시 (Display)

| 위젯 | 설명 |
|------|------|
| `SketchAvatar` | 아바타 (이미지/이니셜/플레이스홀더, 6가지 크기, 2가지 모양) |
| `SketchImagePlaceholder` | 이미지 플레이스홀더 (X-cross 패턴, xs/sm/md/lg 프리셋) |

## 스낵바 사용법

```dart
// 편의 함수 (권장)
showSketchSnackbar(
  context,
  message: '저장되었습니다!',
  type: SnackbarType.success,
);

// 타입: SnackbarType.success / .info / .warning / .error
```

## Painter 목록

스케치 렌더링에 사용되는 CustomPainter 클래스들.

| Painter | 설명 |
|---------|------|
| `SketchPainter` | 핵심 — RRect path metric 기반 스케치 테두리 (6px 샘플링 + 법선 jitter) |
| `SketchCirclePainter` | 원형/타원 (세그먼트 기반, 2-pass) |
| `SketchLinePainter` | 선/화살표 (none/start/end/both, 점선) |
| `SketchPolygonPainter` | 다각형 (3변+, 별 모양, 회전) |
| `AnimatedSketchPainter` | 애니메이션 (progress 0~1 점진적 렌더링) |
| `XCrossPainter` | X-cross 패턴 (배경 + 테두리 + 대각선) |
| `HatchingPainter` | 대각선 빗금 (45도, 6dp 간격) |
| `SketchSnackbarIconPainter` | 스낵바 아이콘 (타입별 도형+기호) |
| `SketchXClosePainter` | X 닫기 버튼 (대각선 2개, 2-pass) |
| `SketchTabPainter` | 폴더 탭 (상단 둥글기, 선택 상태, 2-pass) |

## Enum 목록

| Enum | 값 |
|------|-----|
| `SnackbarType` | success, info, warning, error |
| `SocialLoginPlatform` | kakao, naver, apple, google |
| `SocialLoginButtonSize` | small, medium, large |
| `AppleSignInStyle` | dark, light |
| `SketchInputMode` | defaultMode, search, date, time, datetime, number |
| `SketchButtonStyle` | primary, secondary, outline, hatching |
| `SketchButtonSize` | small(32), medium(44), large(56) |
| `SketchIconButtonShape` | circle, square |
| `SketchProgressBarStyle` | linear, circular |
| `SketchAvatarSize` | xs(24), sm(32), md(40), lg(56), xl(80), xxl(120) |
| `SketchAvatarShape` | circle, roundedSquare |
| `SketchTabIndicatorStyle` | **[deprecated]** underline, filled — 카드형 탭으로 변경 |
| `SketchNavLabelBehavior` | alwaysShow, onlyShowSelected, neverShow |
| `SketchLinkIconPosition` | leading, trailing |
| `SketchArrowStyle` | none, start, end, both |

## 공통 파라미터

대부분의 위젯이 공유하는 커스터마이징 파라미터:

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `showBorder` | `bool` | 스케치 테두리 표시 여부 (기본 `true`) |
| `fillColor` | `Color?` | 채우기 색상 (null이면 테마 기본값) |
| `borderColor` | `Color?` | 테두리 색상 |
| `strokeWidth` | `double?` | 테두리 굵기 |

## 레퍼런스

- 디자인 토큰 정의: `packages/core/lib/sketch_design_tokens.dart`
- 레퍼런스 앱: `apps/design_system_demo/`
