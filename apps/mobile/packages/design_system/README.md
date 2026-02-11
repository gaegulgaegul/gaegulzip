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
        const SketchThemeExtension(fillColor: SketchDesignTokens.background),
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

스케치 스타일 속성(strokeWidth, roughness, fillColor 등)을 Flutter ThemeExtension으로 제공합니다.

```dart
// 위젯에서 접근
final sketchTheme = SketchThemeExtension.of(context);
```

미리 정의된 변형: `.light()`, `.dark()`, `.rough()`, `.smooth()`, `.ultraSmooth()`, `.veryRough()`

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

| 위젯 | 설명 |
|------|------|
| `SketchContainer` | 스케치 스타일 컨테이너 |
| `SketchButton` | 버튼 (filled, outline, ghost) |
| `SketchCard` | 카드 |
| `SketchInput` | 텍스트 입력 |
| `SketchSearchInput` | 검색 입력 |
| `SketchTextArea` | 텍스트 에리어 |
| `SketchNumberInput` | 숫자 입력 |
| `SketchModal` | 모달 다이얼로그 |
| `SketchIconButton` | 아이콘 버튼 |
| `SketchChip` | 칩/태그 |
| `SketchProgressBar` | 프로그레스 바 |
| `SketchSwitch` | 스위치 토글 |
| `SketchCheckbox` | 체크박스 |
| `SketchRadio` | 라디오 버튼 |
| `SketchSlider` | 슬라이더 |
| `SketchDropdown` | 드롭다운 |
| `SketchAvatar` | 아바타 |
| `SketchDivider` | 구분선 |
| `SketchLink` | 링크 텍스트 |
| `SketchAppBar` | 앱바 |
| `SketchTabBar` | 탭바 |
| `SketchBottomNavigationBar` | 하단 네비게이션 |
| `SocialLoginButton` | 소셜 로그인 버튼 |

## 레퍼런스

- 디자인 토큰 정의: `packages/core/lib/sketch_design_tokens.dart`
- 레퍼런스 앱: `apps/design_system_demo/`
