# UI/UX 디자인 명세: Design System v2 (Frame0 시각 언어 일치)

## 개요

현재 디자인 시스템(v1)은 모노크롬 스타일로 전환되었으나, Frame0 프로덕트의 실제 시각 언어와 비교 시 핵심적인 불일치가 발견되었습니다. 본 명세는 Frame0 참조 이미지 분석을 기반으로 따뜻한 크림색 배경, X-cross 이미지 플레이스홀더, 파란색 액센트 등 Frame0 시그니처 요소를 Flutter 디자인 시스템에 정확히 반영하고, 누락된 11개 컴포넌트를 추가하여 완전한 브랜드 일관성을 확보하는 것을 목표로 합니다.

**핵심 디자인 목표**:
1. Frame0의 "프로토타입임을 알리는 디자인" 철학 구현
2. 손그림 스케치 느낌의 시각적 통일성 유지
3. Material Design 3 접근성 기준 충족
4. GetX 반응형 상태 관리 지원

---

## 화면 구조

본 명세는 개별 화면이 아닌 **디자인 시스템 컴포넌트 라이브러리**를 다루므로, 위젯별 구조와 사용 패턴을 정의합니다.

---

## 1. 테마 토큰 변경 명세

### 1.1 배경색 (Background Colors)

Frame0 참조 이미지에서 확인된 따뜻한 크림/오프화이트 배경을 정확히 재현합니다.

#### Light Mode
```dart
// 기본 배경색 (현재 #FFFFFF → 변경)
backgroundColor: Color(0xFFFAF8F5)  // 따뜻한 아이보리/크림 톤

// Surface 색상 (카드, 모달 배경)
surfaceColor: Color(0xFFF5F0E8)     // 배경보다 약간 어두운 크림 톤

// Surface Variant (호버, 선택 상태)
surfaceVariant: Color(0xFFEBE6DC)   // 더 어두운 크림 톤
```

**디자인 근거**: Frame0 홈페이지와 컴포넌트 이미지에서 배경이 순수 흰색이 아닌 따뜻한 크림색임을 확인. 손그림 종이 위에 그린 듯한 자연스러운 느낌 제공.

#### Dark Mode
```dart
// 기본 배경색 (현재 #343434 → 변경)
backgroundColor: Color(0xFF1A1D29)  // 어두운 네이비/차콜 톤

// Surface 색상
surfaceColor: Color(0xFF23273A)     // 배경보다 약간 밝은 네이비

// Surface Variant
surfaceVariant: Color(0xFF2C3048)   // 더 밝은 네이비
```

**디자인 근거**: Frame0 에디터의 다크 모드에서 순수 검은색이 아닌 네이비/차콜 톤 사용. 눈의 피로 감소와 손그림 효과 유지.

#### 접근성 검증
- Light Mode 텍스트(#000000) vs 배경(#FAF8F5): 대비 20.67:1 (WCAG AAA 충족)
- Dark Mode 텍스트(#FFFFFF) vs 배경(#1A1D29): 대비 15.89:1 (WCAG AAA 충족)

---

### 1.2 액센트 컬러 (Accent Colors)

Frame0 스케치 스타일에서 링크와 선택 상태에 사용되는 파란색 계열로 변경합니다.

#### Primary Accent (링크, 선택 상태)
```dart
// 기존: accentPrimary #DF7D5F (코랄/오렌지) → 변경
accentPrimary: Color(0xFF2196F3)    // Material Blue 500

// Light 변형
accentPrimaryLight: Color(0xFF64B5F6)  // Material Blue 300

// Dark 변형
accentPrimaryDark: Color(0xFF1976D2)   // Material Blue 700
```

**사용처**:
- 텍스트 링크 (SketchLink)
- 선택된 탭 (SketchTabBar)
- 선택된 라디오 버튼 (SketchRadio)
- 체크박스 활성 상태 (SketchCheckbox)
- 포커스 테두리 (SketchInput, SketchSearchInput)

#### Secondary Accent (CTA 버튼, 강조)
```dart
// 기존 코랄/오렌지 유지 (CTA 전용)
accentSecondary: Color(0xFFDF7D5F)  // Frame0 웹사이트 브랜드 색상
accentSecondaryLight: Color(0xFFF19E7E)
accentSecondaryDark: Color(0xFFC86947)
```

**사용처**:
- Primary 버튼 (SketchButton - primary 스타일)
- 소셜 로그인 강조 (SocialLoginButton)
- FAB, 주요 액션 버튼

#### Dark Mode 파란색 조정
```dart
// 다크 모드에서 너무 밝은 파란색 방지
accentPrimary (dark): Color(0xFF64B5F6)  // 더 밝은 블루 (대비 확보)
accentSecondary (dark): Color(0xFFF19E7E) // 더 밝은 코랄
```

---

### 1.3 텍스트 컬러 (Text Colors)

크림색 배경과의 대비를 고려한 텍스트 색상.

#### Light Mode
```dart
textPrimary: Color(0xFF000000)      // 순수 검은색 (최고 대비)
textSecondary: Color(0xFF2C2C2C)    // base900보다 약간 밝음
textTertiary: Color(0xFF5E5E5E)     // base700 유지
textDisabled: Color(0xFF8E8E8E)     // base500 유지
textOnAccent: Color(0xFFFFFFFF)     // 액센트 위의 텍스트 (버튼)
```

#### Dark Mode
```dart
textPrimary: Color(0xFFFFFFFF)      // 순수 흰색
textSecondary: Color(0xFFE5E5E5)    // 약간 어두운 흰색
textTertiary: Color(0xFFAAAAAA)     // 회색
textDisabled: Color(0xFF6E6E6E)     // 어두운 회색
textOnAccent: Color(0xFF000000)     // 밝은 액센트 위의 텍스트
```

---

### 1.4 Border 및 Outline 컬러

#### Light Mode
```dart
// 기존: borderColor #343434 (base900) → 유지 (충분한 대비)
outlinePrimary: Color(0xFF343434)   // base900 (주요 테두리)
outlineSecondary: Color(0xFF5E5E5E) // base700 (보조 테두리)
outlineSubtle: Color(0xFFDCDCDC)    // base300 (미묘한 구분선)
```

#### Dark Mode
```dart
// 기존: borderColor #5E5E5E (base700) → 유지
outlinePrimary: Color(0xFF5E5E5E)   // base700 (다크모드 주요 테두리)
outlineSecondary: Color(0xFF8E8E8E) // base500 (보조 테두리)
outlineSubtle: Color(0xFF3A3A3A)    // 어두운 회색 (미묘한 구분선)
```

---

### 1.5 의미론적 색상 (Semantic Colors)

기존 유지하되, 다크모드 변형 추가.

#### Light Mode
```dart
success: Color(0xFF4CAF50)   // Material Green 500
warning: Color(0xFFFFC107)   // Material Amber 500
error: Color(0xFFF44336)     // Material Red 500
info: Color(0xFF2196F3)      // Material Blue 500 (accentPrimary와 동일)
```

#### Dark Mode
```dart
success: Color(0xFF66BB6A)   // Material Green 400 (더 밝음)
warning: Color(0xFFFFCA28)   // Material Amber 400
error: Color(0xFFEF5350)     // Material Red 400
info: Color(0xFF64B5F6)      // Material Blue 300
```

---

### 1.6 디자인 토큰 파일 업데이트

#### `packages/core/lib/src/sketch_design_tokens.dart` 변경

```dart
// 기존 색상 상수 변경
class SketchDesignTokens {
  // ========== 배경색 ==========
  // Light Mode
  static const Color background = Color(0xFFFAF8F5);        // 변경: 따뜻한 크림
  static const Color surface = Color(0xFFF5F0E8);           // 변경: 어두운 크림
  static const Color surfaceVariant = Color(0xFFEBE6DC);    // 추가: 더 어두운 크림

  // Dark Mode
  static const Color backgroundDark = Color(0xFF1A1D29);    // 변경: 네이비/차콜
  static const Color surfaceDark = Color(0xFF23273A);       // 변경: 밝은 네이비
  static const Color surfaceVariantDark = Color(0xFF2C3048); // 추가: 더 밝은 네이비

  // ========== 액센트 컬러 ==========
  // Primary (링크, 선택 상태)
  static const Color accentPrimary = Color(0xFF2196F3);     // 변경: 파란색
  static const Color accentPrimaryLight = Color(0xFF64B5F6); // 추가
  static const Color accentPrimaryDark = Color(0xFF1976D2);  // 추가

  // Secondary (CTA 버튼)
  static const Color accentSecondary = Color(0xFFDF7D5F);   // 기존 유지
  static const Color accentSecondaryLight = Color(0xFFF19E7E); // accentLight에서 이름 변경
  static const Color accentSecondaryDark = Color(0xFFC86947);  // 추가

  // Dark Mode 액센트
  static const Color accentPrimaryDarkMode = Color(0xFF64B5F6);
  static const Color accentSecondaryDarkMode = Color(0xFFF19E7E);

  // ========== 텍스트 컬러 ==========
  // Light Mode
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF2C2C2C);     // 추가
  static const Color textTertiary = Color(0xFF5E5E5E);      // base700
  static const Color textDisabled = Color(0xFF8E8E8E);      // base500
  static const Color textOnAccent = Color(0xFFFFFFFF);      // 추가

  // Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFE5E5E5); // 추가
  static const Color textTertiaryDark = Color(0xFFAAAAAA);  // 추가
  static const Color textDisabledDark = Color(0xFF6E6E6E);  // 추가
  static const Color textOnAccentDark = Color(0xFF000000);  // 추가

  // ========== 기존 base 색상 유지 (하위 호환) ==========
  static const Color white = Color(0xFFFFFFFF);
  static const Color base100 = Color(0xFFF7F7F7);
  static const Color base200 = Color(0xFFEBEBEB);
  static const Color base300 = Color(0xFFDCDCDC);
  static const Color base500 = Color(0xFF8E8E8E);
  static const Color base700 = Color(0xFF5E5E5E);
  static const Color base900 = Color(0xFF343434);
  static const Color black = Color(0xFF000000);

  // ... (기존 상수 유지)
}
```

---

## 2. 기존 위젯 수정 명세

### 2.1 SketchButton

#### 변경 사항: Pill 형태로 변경

**현재**: borderRadius = 6.0 (고정)
**변경**: borderRadius = 9999 (pill/캡슐 형태 기본값)

#### 구현 명세

```dart
class SketchButton extends StatelessWidget {
  // ... 기존 파라미터 유지

  final double? borderRadius; // 추가: nullable로 변경

  const SketchButton({
    // ...
    this.borderRadius,  // 기본값 null = pill 형태
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 9999.0; // pill 기본값

    // CustomPaint로 SketchPainter 사용 시
    // borderRadius를 큰 값으로 전달하여 완전한 둥근 모서리 생성
  }
}
```

#### 크기별 pill 형태

| Size | Height | Padding Horizontal | Border Radius |
|------|--------|-------------------|---------------|
| small | 32 | 16 | 9999 (pill) |
| medium | 44 | 24 | 9999 (pill) |
| large | 56 | 32 | 9999 (pill) |

#### 하위 호환성

```dart
// 기본 사용 (pill 형태)
SketchButton(text: '확인', onPressed: () {})

// 기존 스타일 유지 (선택적)
SketchButton(
  text: '확인',
  borderRadius: 6.0,  // 명시적으로 지정
  onPressed: () {},
)
```

---

### 2.2 SketchContainer

#### 변경 사항: 기본 배경색 변경

**현재**: fillColor = Colors.white
**변경**: fillColor = SketchDesignTokens.surface (크림색)

#### 구현 명세

```dart
class SketchContainer extends StatelessWidget {
  final Color? fillColor;

  const SketchContainer({
    // ...
    this.fillColor,  // null = 테마 surface 사용
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchThemeExtension.of(context);
    final effectiveFillColor = fillColor ?? theme.fillColor; // 크림색 기본값

    // ...
  }
}
```

---

### 2.3 모든 위젯: 기본 폰트 변경

#### 변경 사항: Hand 폰트(PatrickHand)를 기본으로

**현재**: fontFamily 파라미터 없음 (Material 기본 폰트)
**변경**: fontFamily = SketchDesignTokens.fontFamilyHand 기본 적용

#### 영향 받는 위젯
- SketchButton (text)
- SketchCard (header, body, footer 내부 텍스트)
- SketchInput (label, hint, value)
- SketchChip (label)
- SketchDropdown (hint, items)
- SketchModal (title, child 내부 텍스트)
- SocialLoginButton (button label)
- 모든 신규 위젯

#### 구현 명세

```dart
// TextStyle 생성 시 기본 폰트 적용
TextStyle(
  fontFamily: SketchDesignTokens.fontFamilyHand, // PatrickHand
  fontSize: fontSize ?? SketchDesignTokens.fontSizeBase,
  fontWeight: fontWeight ?? FontWeight.w400,
)
```

#### 예외 케이스

특정 위젯에서 Sans/Mono 폰트 명시 가능:

```dart
SketchInput(
  label: '코드 입력',
  fontFamily: SketchDesignTokens.fontFamilyMono, // 숫자 입력 필드
)
```

---

### 2.4 SketchThemeExtension

#### 변경 사항: 기본 색상 업데이트

#### light() 팩토리 메서드

```dart
factory SketchThemeExtension.light() {
  return const SketchThemeExtension(
    borderColor: Color(0xFF343434),   // base900 유지
    fillColor: Color(0xFFFAF8F5),      // 변경: 크림색 배경
    strokeWidth: 2.0,
    roughness: 0.8,
    bowing: 0.5,
  );
}
```

#### dark() 팩토리 메서드

```dart
factory SketchThemeExtension.dark() {
  return const SketchThemeExtension(
    borderColor: Color(0xFF5E5E5E),   // base700 유지
    fillColor: Color(0xFF1A1D29),      // 변경: 네이비/차콜
    strokeWidth: 2.0,
    roughness: 0.8,
    bowing: 0.5,
    shadowColor: Color(0x40000000),   // 더 어두운 그림자
  );
}
```

---

### 2.5 SocialLoginButton

#### 변경 사항: 스케치 스타일 옵션 추가

**현재**: 공식 브랜드 가이드라인 스타일만 제공
**변경**: 스케치 스타일 옵션 추가 (`sketchStyle: true/false`)

#### 구현 명세

```dart
class SocialLoginButton extends StatelessWidget {
  // ...
  final bool sketchStyle; // 추가: 스케치 스타일 여부

  const SocialLoginButton({
    // ...
    this.sketchStyle = false, // 기본값: 공식 스타일 유지 (하위 호환)
  });

  @override
  Widget build(BuildContext context) {
    if (sketchStyle) {
      // SketchContainer 기반 렌더링
      return SketchContainer(
        fillColor: _getPlatformBackgroundColor(platform),
        borderColor: _getPlatformBorderColor(platform),
        child: Row(
          children: [
            _getPlatformIcon(platform), // 공식 로고 유지
            SizedBox(width: 12),
            Text(
              _getPlatformText(platform),
              style: TextStyle(
                fontFamily: SketchDesignTokens.fontFamilyHand, // 손글씨체
                color: _getPlatformTextColor(platform),
              ),
            ),
          ],
        ),
      );
    } else {
      // 기존 공식 스타일 유지
      // ...
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

## 3. 신규 위젯 디자인 명세

### 3.1 SketchImagePlaceholder (X-cross 패턴)

**우선순위**: P0 (Frame0 시그니처 요소)

#### 개요

이미지가 없는 영역에 대각선 X 패턴을 렌더링하는 플레이스홀더 위젯. Frame0의 가장 대표적인 시각 요소.

#### 시각적 구조

```
┌─────────────────┐
│       ╱╲        │  ← X-cross 패턴 (대각선 2개)
│      ╱  ╲       │
│     ╱    ╲      │
│    ╱      ╲     │
│   ╱        ╲    │
│  ╲        ╱     │
│   ╲      ╱      │
│    ╲    ╱       │
│     ╲  ╱        │
│      ╲╱         │
└─────────────────┘
```

#### API 명세

```dart
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
}
```

#### 상태

| 상태 | 설명 | 스타일 |
|------|------|--------|
| Normal | 기본 상태 | X 선: base500, 배경: base100 |
| Hover | 마우스 오버 (웹/데스크탑) | X 선: base700 (어두움) |
| Empty | 이미지 없음 (명시적) | centerIcon 표시 (예: Icons.image_outlined) |

#### 크기 변형

| Size | Width | Height | Stroke Width | 용도 |
|------|-------|--------|--------------|------|
| xs | 40 | 40 | 1.5 | 작은 썸네일 |
| sm | 80 | 80 | 2.0 | 프로필 이미지 |
| md | 120 | 120 | 2.5 | 카드 썸네일 |
| lg | 200 | 200 | 3.0 | 배너 이미지 |
| custom | 지정 | 지정 | 2.0 | 자유 크기 |

#### 렌더링 로직 (CustomPainter)

```dart
class _XCrossPainter extends CustomPainter {
  final Color lineColor;
  final double strokeWidth;
  final Color backgroundColor;
  final double roughness;

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
    // Bezier 곡선으로 불규칙한 선 생성
    // (SketchLinePainter와 동일한 알고리즘 사용)
  }
}
```

#### 사용 예시

```dart
// 프로필 이미지 플레이스홀더
SketchImagePlaceholder(
  width: 80,
  height: 80,
  centerIcon: Icons.person_outline,
)

// 썸네일 플레이스홀더
SketchImagePlaceholder.md()  // 프리셋 사용

// 배너 플레이스홀더
SketchImagePlaceholder(
  width: double.infinity,
  height: 200,
  lineColor: SketchDesignTokens.accentPrimary,
)

// 이미지 로딩 실패 시 자동 교체
FadeInImage(
  placeholder: AssetImage('loading.png'),
  image: NetworkImage(imageUrl),
  imageErrorBuilder: (context, error, stackTrace) {
    return SketchImagePlaceholder(
      width: 120,
      height: 120,
    );
  },
)
```

---

### 3.2 SketchTabBar

**우선순위**: P1

#### 개요

2~5개 탭을 수평으로 배치한 탭 바 위젯. 선택된 탭을 파란색 액센트로 강조.

#### 시각적 구조

```
┌─────────┬─────────┬─────────┐
│  Home   │  알림   │  설정   │  ← 탭 (평상시: base700, 선택: accentPrimary)
└─────────┴─────────┴─────────┘
    ↑                           ← 선택 인디케이터 (파란색 밑줄 또는 배경)
```

#### API 명세

```dart
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
  });
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
  underline,  // 하단 밑줄
  background, // 배경 강조
}
```

#### 상태별 스타일

| 상태 | 텍스트 색상 | 아이콘 색상 | 인디케이터 |
|------|------------|------------|-----------|
| Unselected | base700 | base700 | 없음 |
| Selected | accentPrimary | accentPrimary | 파란색 밑줄/배경 |
| Hover | base900 | base900 | 미묘한 배경 |
| Disabled | textDisabled | textDisabled | 없음 |

#### 인디케이터 렌더링

**Underline 스타일**:
```dart
// 선택된 탭 하단에 3px 두께 밑줄
Container(
  height: 3.0,
  decoration: BoxDecoration(
    color: selectedColor ?? SketchDesignTokens.accentPrimary,
    borderRadius: BorderRadius.circular(1.5),
  ),
)
```

**Background 스타일**:
```dart
// 선택된 탭 전체 배경 강조
SketchContainer(
  fillColor: selectedColor?.withValues(alpha: 0.1),
  borderColor: selectedColor ?? SketchDesignTokens.accentPrimary,
  strokeWidth: 2.0,
  child: TabContent(),
)
```

#### 애니메이션

- 탭 전환 시 인디케이터가 부드럽게 슬라이드 (250ms)
- Curve: Curves.easeInOut

```dart
AnimatedPositioned(
  duration: Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  left: _getIndicatorPosition(currentIndex),
  child: _buildIndicator(),
)
```

#### 사용 예시

```dart
class _MyScreenState extends State<MyScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SketchTabBar(
          tabs: [
            SketchTab(label: 'Home', icon: Icons.home),
            SketchTab(label: '알림', icon: Icons.notifications, badgeCount: 5),
            SketchTab(label: '설정', icon: Icons.settings),
          ],
          currentIndex: _selectedTab,
          onTap: (index) {
            setState(() => _selectedTab = index);
          },
        ),
        Expanded(
          child: _buildTabContent(_selectedTab),
        ),
      ],
    );
  }
}
```

---

### 3.3 SketchBottomNavigationBar

**우선순위**: P1

#### 개요

화면 하단에 고정된 네비게이션 바. 3~5개 항목을 표시하며, 현재 선택된 항목을 파란색으로 강조.

#### 시각적 구조

```
┌──────────────────────────────────────────────┐
│  ◯      ●      ◯      ◯      ◯               │  ← 아이콘
│ Home   알림   검색  프로필  설정              │  ← 라벨
└──────────────────────────────────────────────┘
         ↑ 선택된 항목 (파란색)
```

#### API 명세

```dart
class SketchBottomNavigationBar extends StatelessWidget {
  /// 네비게이션 항목 목록 (3~5개 권장)
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
  });
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
  showAll,       // 모든 항목 라벨 표시
  showSelected,  // 선택된 항목만 라벨 표시
  hideAll,       // 모든 라벨 숨김 (아이콘만)
}
```

#### 상태별 스타일

| 상태 | 아이콘 색상 | 라벨 색상 | 아이콘 크기 | 배경 |
|------|-----------|----------|-----------|------|
| Unselected | base700 | base700 | 24 | 투명 |
| Selected | accentPrimary | accentPrimary | 28 | 미묘한 파란색 배경 (선택) |
| Hover | base900 | base900 | 24 | 미묘한 회색 배경 |
| Disabled | textDisabled | textDisabled | 24 | 투명 |

#### 레이아웃

```dart
// 각 항목 레이아웃 (Column)
Column(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // 아이콘 + 뱃지
    Stack(
      children: [
        Icon(item.icon, size: isSelected ? 28 : 24),
        if (item.badgeCount != null && item.badgeCount! > 0)
          Positioned(
            right: -4,
            top: -4,
            child: _buildBadge(item.badgeCount!),
          ),
      ],
    ),
    SizedBox(height: 4),
    // 라벨 (조건부)
    if (_shouldShowLabel(index, labelBehavior))
      Text(
        item.label,
        style: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyHand,
          fontSize: 12,
          color: isSelected ? selectedColor : unselectedColor,
        ),
      ),
  ],
)
```

#### 뱃지 스타일

```dart
Widget _buildBadge(int count) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: SketchDesignTokens.error,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white, width: 1.5),
    ),
    child: Text(
      count > 99 ? '99+' : count.toString(),
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyMono,
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
```

#### 애니메이션

- 항목 선택 시 아이콘 크기와 색상이 부드럽게 전환 (200ms)
- Curve: Curves.easeOut

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  child: Icon(
    isSelected ? item.activeIcon ?? item.icon : item.icon,
    size: isSelected ? 28 : 24,
    color: isSelected ? selectedColor : unselectedColor,
  ),
)
```

#### 사용 예시

```dart
class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(_currentIndex),
      bottomNavigationBar: SketchBottomNavigationBar(
        items: [
          SketchNavItem(
            label: 'Home',
            icon: LucideIcons.home,
            activeIcon: LucideIcons.homeFilled,
          ),
          SketchNavItem(
            label: '알림',
            icon: LucideIcons.bell,
            activeIcon: LucideIcons.bellFilled,
            badgeCount: 3,
          ),
          SketchNavItem(
            label: '검색',
            icon: LucideIcons.search,
          ),
          SketchNavItem(
            label: '프로필',
            icon: LucideIcons.user,
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
```

---

### 3.4 SketchAvatar

**우선순위**: P1

#### 개요

사용자 프로필 이미지를 표시하는 아바타 위젯. 이미지 URL, 이니셜, 플레이스홀더를 지원.

#### 시각적 구조

```
  ◯  ← 원형 (기본)
 ┌──┐ ← 사각형 (옵션)
 │AS│ ← 이니셜 (이미지 없을 때)
 └──┘
  X  ← X-cross 패턴 (이미지 로딩 실패)
```

#### API 명세

```dart
class SketchAvatar extends StatelessWidget {
  /// 이미지 URL (network image)
  final String? imageUrl;

  /// 로컬 이미지 (asset)
  final String? assetPath;

  /// 이니셜 (이미지 없을 때 표시)
  final String? initials;

  /// 플레이스홀더 아이콘
  final IconData? placeholderIcon;

  /// 아바타 크기
  final SketchAvatarSize size;

  /// 아바타 형태
  final SketchAvatarShape shape;

  /// 배경 색상
  final Color? backgroundColor;

  /// 텍스트 색상 (이니셜)
  final Color? textColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 테두리 두께
  final double strokeWidth;

  /// 탭 콜백 (선택)
  final VoidCallback? onTap;

  const SketchAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.initials,
    this.placeholderIcon,
    this.size = SketchAvatarSize.medium,
    this.shape = SketchAvatarShape.circle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.strokeWidth = 2.0,
    this.onTap,
  });
}

/// 아바타 크기
enum SketchAvatarSize {
  small(32),
  medium(56),
  large(80),
  xlarge(120);

  final double value;
  const SketchAvatarSize(this.value);
}

/// 아바타 형태
enum SketchAvatarShape {
  circle,   // 원형
  square,   // 사각형 (rounded)
}
```

#### 크기별 스타일

| Size | Diameter | Font Size (이니셜) | Icon Size | Border Width |
|------|---------|-------------------|-----------|--------------|
| small | 32 | 14 | 16 | 1.5 |
| medium | 56 | 20 | 28 | 2.0 |
| large | 80 | 28 | 40 | 2.5 |
| xlarge | 120 | 40 | 60 | 3.0 |

#### 상태별 렌더링

**1. 이미지 로딩 성공**
```dart
CustomPaint(
  painter: shape == SketchAvatarShape.circle
      ? SketchCirclePainter(...)
      : SketchPainter(...),
  child: ClipPath(
    clipper: _getClipper(shape),
    child: Image.network(imageUrl!),
  ),
)
```

**2. 이미지 없음 (이니셜 표시)**
```dart
SketchContainer(
  width: size.value,
  height: size.value,
  fillColor: backgroundColor ?? SketchDesignTokens.accentSecondaryLight,
  borderColor: borderColor ?? SketchDesignTokens.base700,
  strokeWidth: strokeWidth,
  child: Center(
    child: Text(
      initials ?? '',
      style: TextStyle(
        fontFamily: SketchDesignTokens.fontFamilyHand,
        fontSize: _getFontSize(size),
        color: textColor ?? Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

**3. 이미지 로딩 실패 (X-cross)**
```dart
SketchImagePlaceholder(
  width: size.value,
  height: size.value,
  centerIcon: placeholderIcon ?? Icons.person_outline,
)
```

#### 이니셜 생성 로직

```dart
String _getInitials(String? name) {
  if (name == null || name.isEmpty) return '';

  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    // 이름 + 성 첫 글자
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  } else {
    // 첫 2글자
    return name.substring(0, min(2, name.length)).toUpperCase();
  }
}
```

#### 사용 예시

```dart
// 이미지 URL
SketchAvatar(
  imageUrl: 'https://example.com/avatar.jpg',
  size: SketchAvatarSize.medium,
)

// 이니셜 (이미지 없음)
SketchAvatar(
  initials: 'AS',
  backgroundColor: SketchDesignTokens.accentPrimary,
  size: SketchAvatarSize.large,
)

// 플레이스홀더 아이콘
SketchAvatar(
  placeholderIcon: Icons.person,
  size: SketchAvatarSize.small,
)

// 사각형 아바타
SketchAvatar(
  imageUrl: userImageUrl,
  shape: SketchAvatarShape.square,
  onTap: () => navigateToProfile(),
)

// 리스트 아이템
ListTile(
  leading: SketchAvatar(
    imageUrl: user.avatarUrl,
    initials: user.initials,
    size: SketchAvatarSize.medium,
  ),
  title: Text(user.name),
)
```

---

### 3.5 SketchRadio

**우선순위**: P1

#### 개요

단일 선택 라디오 버튼. 그룹 내 하나만 선택 가능.

#### 시각적 구조

```
◯  Option 1  ← 비선택 (테두리만)
●  Option 2  ← 선택 (내부 점 + 파란색)
◯  Option 3
```

#### API 명세

```dart
class SketchRadio<T> extends StatelessWidget {
  /// 라디오 버튼의 값
  final T value;

  /// 그룹의 현재 선택된 값
  final T groupValue;

  /// 선택 변경 시 콜백
  final ValueChanged<T>? onChanged;

  /// 라디오 버튼 라벨
  final String? label;

  /// 라디오 버튼 크기
  final double size;

  /// 선택 시 색상
  final Color? activeColor;

  /// 비선택 시 색상
  final Color? inactiveColor;

  const SketchRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
  });
}
```

#### 상태별 스타일

| 상태 | 테두리 색상 | 내부 점 | 라벨 색상 | 투명도 |
|------|-----------|---------|----------|--------|
| Unselected | base700 | 없음 | textSecondary | 1.0 |
| Selected | accentPrimary | 파란색 원 | textPrimary | 1.0 |
| Hover | base900 | - | textPrimary | 1.0 |
| Disabled | textDisabled | - | textDisabled | 0.4 |

#### 렌더링 로직

```dart
@override
Widget build(BuildContext context) {
  final isSelected = value == groupValue;
  final isDisabled = onChanged == null;

  return GestureDetector(
    onTap: isDisabled ? null : () => onChanged?.call(value),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라디오 버튼 원형
        CustomPaint(
          size: Size(size, size),
          painter: SketchCirclePainter(
            fillColor: isSelected
                ? (activeColor ?? SketchDesignTokens.accentPrimary).withValues(alpha: 0.1)
                : Colors.transparent,
            borderColor: isSelected
                ? (activeColor ?? SketchDesignTokens.accentPrimary)
                : (inactiveColor ?? SketchDesignTokens.base700),
            strokeWidth: 2.0,
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: size * 0.5,
                    height: size * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor ?? SketchDesignTokens.accentPrimary,
                    ),
                  ),
                )
              : null,
        ),
        // 라벨
        if (label != null) ...[
          SizedBox(width: 8),
          Text(
            label!,
            style: TextStyle(
              fontFamily: SketchDesignTokens.fontFamilyHand,
              fontSize: SketchDesignTokens.fontSizeBase,
              color: isDisabled
                  ? SketchDesignTokens.textDisabled
                  : (isSelected
                      ? SketchDesignTokens.textPrimary
                      : SketchDesignTokens.textSecondary),
            ),
          ),
        ],
      ],
    ),
  );
}
```

#### 애니메이션

- 선택 시 내부 점이 페이드인 + 스케일 (200ms)
- 테두리 색상 전환 (200ms)

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  width: isSelected ? size * 0.5 : 0,
  height: isSelected ? size * 0.5 : 0,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: activeColor,
  ),
)
```

#### 사용 예시 (RadioGroup)

```dart
class _SettingsScreenState extends State<SettingsScreen> {
  String _notificationFrequency = 'hourly';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('알림 빈도', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        SketchRadio<String>(
          value: 'instant',
          groupValue: _notificationFrequency,
          label: '즉시',
          onChanged: (value) {
            setState(() => _notificationFrequency = value);
          },
        ),
        SketchRadio<String>(
          value: 'hourly',
          groupValue: _notificationFrequency,
          label: '1시간마다',
          onChanged: (value) {
            setState(() => _notificationFrequency = value);
          },
        ),
        SketchRadio<String>(
          value: 'daily',
          groupValue: _notificationFrequency,
          label: '하루 1번',
          onChanged: (value) {
            setState(() => _notificationFrequency = value);
          },
        ),
      ],
    );
  }
}
```

---

### 3.6 SketchSearchInput

**우선순위**: P1

#### 개요

검색 아이콘이 포함된 입력 필드. 입력 중 지우기 버튼 표시.

#### 시각적 구조

```
┌──────────────────────────────┐
│ 🔍  검색어 입력...       ✕   │  ← prefixIcon + hint + suffixIcon
└──────────────────────────────┘
```

#### API 명세

```dart
class SketchSearchInput extends StatelessWidget {
  /// 힌트 텍스트
  final String? hint;

  /// 텍스트 컨트롤러
  final TextEditingController? controller;

  /// 입력 변경 시 콜백
  final ValueChanged<String>? onChanged;

  /// 검색 실행 시 콜백 (엔터 또는 검색 아이콘 탭)
  final ValueChanged<String>? onSubmitted;

  /// 검색 아이콘 (기본값: Icons.search)
  final IconData searchIcon;

  /// 지우기 버튼 표시 여부
  final bool showClearButton;

  /// 자동 포커스 여부
  final bool autofocus;

  const SketchSearchInput({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.searchIcon = Icons.search,
    this.showClearButton = true,
    this.autofocus = false,
  });
}
```

#### 상태별 스타일

| 상태 | 테두리 색상 | 아이콘 색상 | 배경 색상 |
|------|-----------|-----------|----------|
| Normal | base300 | base500 | surface |
| Focused | accentPrimary | accentPrimary | surface |
| Filled | base700 | base700 | surface |
| Disabled | base300 | textDisabled | surfaceVariant |

#### 레이아웃

```dart
@override
Widget build(BuildContext context) {
  return SketchInput(
    controller: controller,
    hint: hint ?? '검색...',
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    autofocus: autofocus,
    prefixIcon: Icon(
      searchIcon,
      color: _getIconColor(context),
    ),
    suffixIcon: showClearButton && _hasText
        ? IconButton(
            icon: Icon(Icons.clear, color: SketchDesignTokens.base500),
            onPressed: () {
              controller?.clear();
              onChanged?.call('');
            },
          )
        : null,
  );
}
```

#### 지우기 버튼 표시 로직

```dart
bool get _hasText {
  return controller != null && controller!.text.isNotEmpty;
}
```

#### 사용 예시

```dart
// 기본 검색 입력
SketchSearchInput(
  hint: '박스 이름 검색',
  onSubmitted: (query) {
    searchBoxes(query);
  },
)

// 실시간 검색
SketchSearchInput(
  hint: '운동 검색',
  onChanged: (query) {
    setState(() {
      _searchResults = _filterWorkouts(query);
    });
  },
)

// 컨트롤러 사용
final _searchController = TextEditingController();

SketchSearchInput(
  controller: _searchController,
  hint: '검색어 입력',
  onSubmitted: (query) {
    print('검색: $query');
  },
)
```

---

### 3.7 SketchTextArea

**우선순위**: P1

#### 개요

여러 줄 텍스트 입력 필드. 글자 수 제한 및 카운터 표시 지원.

#### 시각적 구조

```
┌──────────────────────────────┐
│ 긴 텍스트를 입력하세요...     │
│                               │  ← 여러 줄 입력 영역
│                               │
│                               │
│                     150 / 500 │  ← 글자 수 카운터 (오른쪽 하단)
└──────────────────────────────┘
```

#### API 명세

```dart
class SketchTextArea extends StatelessWidget {
  /// 라벨
  final String? label;

  /// 힌트 텍스트
  final String? hint;

  /// 텍스트 컨트롤러
  final TextEditingController? controller;

  /// 입력 변경 시 콜백
  final ValueChanged<String>? onChanged;

  /// 최소 줄 수
  final int minLines;

  /// 최대 줄 수 (null = 무제한)
  final int? maxLines;

  /// 최대 글자 수 (null = 무제한)
  final int? maxLength;

  /// 글자 수 카운터 표시 여부
  final bool showCounter;

  /// 에러 텍스트
  final String? errorText;

  const SketchTextArea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 10,
    this.maxLength,
    this.showCounter = false,
    this.errorText,
  });
}
```

#### 상태별 스타일

SketchInput과 동일한 스타일 적용 (다만 높이가 자동 확장됨)

#### 글자 수 카운터

```dart
Widget _buildCounter() {
  final currentLength = controller?.text.length ?? 0;

  return Padding(
    padding: EdgeInsets.only(top: 4, right: 8),
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(
        maxLength != null
            ? '$currentLength / $maxLength'
            : '$currentLength',
        style: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyMono, // 숫자는 Mono
          fontSize: SketchDesignTokens.fontSizeXs,
          color: _getCounterColor(currentLength),
        ),
      ),
    ),
  );
}

Color _getCounterColor(int currentLength) {
  if (maxLength == null) {
    return SketchDesignTokens.textTertiary;
  }

  final ratio = currentLength / maxLength!;
  if (ratio >= 1.0) {
    return SketchDesignTokens.error;
  } else if (ratio >= 0.9) {
    return SketchDesignTokens.warning;
  } else {
    return SketchDesignTokens.textTertiary;
  }
}
```

#### 자동 확장 로직

```dart
TextField(
  controller: controller,
  minLines: minLines,
  maxLines: maxLines,
  maxLength: maxLength,
  decoration: InputDecoration(
    counterText: '', // 기본 카운터 숨김 (커스텀 카운터 사용)
    // ...
  ),
)
```

#### 사용 예시

```dart
// 기본 텍스트 에어리어
SketchTextArea(
  label: '피드백',
  hint: '의견을 자유롭게 작성하세요',
  minLines: 5,
  maxLines: 10,
)

// 글자 수 제한
SketchTextArea(
  label: '댓글',
  hint: '댓글 입력',
  maxLength: 500,
  showCounter: true,
  onChanged: (text) {
    print('현재 길이: ${text.length}');
  },
)

// 에러 상태
SketchTextArea(
  label: '질문',
  hint: '질문 내용',
  errorText: '최소 20자 이상 입력하세요',
  maxLength: 1000,
  showCounter: true,
)
```

---

### 3.8 SketchDivider

**우선순위**: P1

#### 개요

콘텐츠 영역을 구분하는 수평/수직 구분선. 손그림 스타일 또는 직선 스타일 선택 가능.

#### 시각적 구조

```
─────────────────────  ← 수평 (기본)
│                      ← 수직 (회전)
```

#### API 명세

```dart
class SketchDivider extends StatelessWidget {
  /// 방향 (수평/수직)
  final Axis direction;

  /// 선 두께
  final double thickness;

  /// 선 색상
  final Color? color;

  /// 손그림 스타일 여부
  final bool isSketch;

  /// 손그림 거칠기 (isSketch = true일 때)
  final double roughness;

  /// 여백 (선 주변)
  final EdgeInsetsGeometry? margin;

  /// 길이 (null = 최대)
  final double? length;

  const SketchDivider({
    super.key,
    this.direction = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.isSketch = true,
    this.roughness = 0.8,
    this.margin,
    this.length,
  });

  /// 수평 구분선 팩토리
  const SketchDivider.horizontal({
    Key? key,
    double thickness = 1.0,
    Color? color,
    bool isSketch = true,
    EdgeInsetsGeometry? margin,
  }) : this(
    key: key,
    direction: Axis.horizontal,
    thickness: thickness,
    color: color,
    isSketch: isSketch,
    margin: margin,
  );

  /// 수직 구분선 팩토리
  const SketchDivider.vertical({
    Key? key,
    double thickness = 1.0,
    Color? color,
    bool isSketch = true,
    EdgeInsetsGeometry? margin,
  }) : this(
    key: key,
    direction: Axis.vertical,
    thickness: thickness,
    color: color,
    isSketch: isSketch,
    margin: margin,
  );
}
```

#### 렌더링 로직

**손그림 스타일 (isSketch = true)**:
```dart
// SketchLinePainter 사용
CustomPaint(
  size: Size(
    direction == Axis.horizontal ? double.infinity : thickness,
    direction == Axis.vertical ? double.infinity : thickness,
  ),
  painter: SketchLinePainter(
    start: Offset(0, thickness / 2),
    end: Offset(length ?? constraints.maxWidth, thickness / 2),
    color: color ?? SketchDesignTokens.base300,
    strokeWidth: thickness,
    roughness: roughness,
  ),
)
```

**직선 스타일 (isSketch = false)**:
```dart
Container(
  width: direction == Axis.horizontal ? length : thickness,
  height: direction == Axis.vertical ? length : thickness,
  color: color ?? SketchDesignTokens.base300,
)
```

#### 사용 예시

```dart
// 수평 구분선 (기본)
SketchDivider()

// 두꺼운 구분선
SketchDivider(
  thickness: 2.0,
  color: SketchDesignTokens.base500,
)

// 직선 스타일
SketchDivider(
  isSketch: false,
  thickness: 1.0,
)

// 수직 구분선
Row(
  children: [
    Text('왼쪽'),
    SketchDivider.vertical(
      thickness: 1.5,
      margin: EdgeInsets.symmetric(horizontal: 16),
    ),
    Text('오른쪽'),
  ],
)

// 섹션 구분
Column(
  children: [
    _buildSection1(),
    SketchDivider(
      margin: EdgeInsets.symmetric(vertical: 24),
      thickness: 2.0,
    ),
    _buildSection2(),
  ],
)
```

---

### 3.9 SketchNumberInput

**우선순위**: P1

#### 개요

숫자만 입력할 수 있는 전용 입력 필드. 증가/감소 버튼 선택적 표시.

#### 시각적 구조

```
┌──────────────────────────────┐
│       ─     75     +          │  ← minus / value / plus 버튼
└──────────────────────────────┘
```

#### API 명세

```dart
class SketchNumberInput extends StatelessWidget {
  /// 라벨
  final String? label;

  /// 현재 값
  final double value;

  /// 최소값
  final double? min;

  /// 최대값
  final double? max;

  /// 증가/감소 단위
  final double step;

  /// 소수점 자릿수
  final int decimalPlaces;

  /// 값 변경 시 콜백
  final ValueChanged<double> onChanged;

  /// 증가/감소 버튼 표시 여부
  final bool showButtons;

  /// 접미사 (예: "kg", "회")
  final String? suffix;

  const SketchNumberInput({
    super.key,
    this.label,
    required this.value,
    this.min,
    this.max,
    this.step = 1.0,
    this.decimalPlaces = 0,
    required this.onChanged,
    this.showButtons = true,
    this.suffix,
  });
}
```

#### 레이아웃

```dart
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null) ...[
        Text(
          label!,
          style: TextStyle(
            fontFamily: SketchDesignTokens.fontFamilyHand,
            fontSize: SketchDesignTokens.fontSizeSm,
            color: SketchDesignTokens.textSecondary,
          ),
        ),
        SizedBox(height: 8),
      ],
      Row(
        children: [
          // 감소 버튼
          if (showButtons)
            SketchIconButton(
              icon: Icons.remove,
              onPressed: _canDecrement ? _decrement : null,
            ),
          if (showButtons) SizedBox(width: 8),

          // 숫자 입력 필드
          Expanded(
            child: SketchInput(
              controller: _controller,
              hint: '0',
              keyboardType: TextInputType.numberWithOptions(
                decimal: decimalPlaces > 0,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(decimalPlaces > 0 ? r'^\d*\.?\d*' : r'^\d*'),
                ),
              ],
              onChanged: (text) {
                final parsedValue = double.tryParse(text);
                if (parsedValue != null) {
                  onChanged(_clampValue(parsedValue));
                }
              },
              suffixIcon: suffix != null
                  ? Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text(
                        suffix!,
                        style: TextStyle(
                          fontFamily: SketchDesignTokens.fontFamilyMono,
                          color: SketchDesignTokens.textTertiary,
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          // 증가 버튼
          if (showButtons) SizedBox(width: 8),
          if (showButtons)
            SketchIconButton(
              icon: Icons.add,
              onPressed: _canIncrement ? _increment : null,
            ),
        ],
      ),
    ],
  );
}
```

#### 값 검증 로직

```dart
double _clampValue(double value) {
  if (min != null && value < min!) return min!;
  if (max != null && value > max!) return max!;
  return value;
}

bool get _canIncrement {
  return max == null || value < max!;
}

bool get _canDecrement {
  return min == null || value > min!;
}

void _increment() {
  final newValue = _clampValue(value + step);
  onChanged(newValue);
}

void _decrement() {
  final newValue = _clampValue(value - step);
  onChanged(newValue);
}
```

#### 사용 예시

```dart
// 기본 숫자 입력
double _weight = 75.0;

SketchNumberInput(
  label: '무게',
  value: _weight,
  min: 0,
  max: 300,
  suffix: 'kg',
  onChanged: (value) {
    setState(() => _weight = value);
  },
)

// 소수점 입력
double _distance = 5.5;

SketchNumberInput(
  label: '거리',
  value: _distance,
  step: 0.5,
  decimalPlaces: 1,
  suffix: 'km',
  onChanged: (value) {
    setState(() => _distance = value);
  },
)

// 버튼 없이 (텍스트 입력만)
SketchNumberInput(
  label: '나이',
  value: _age,
  showButtons: false,
  onChanged: (value) {
    setState(() => _age = value.toInt());
  },
)
```

---

### 3.10 SketchLink

**우선순위**: P1

#### 개요

클릭 가능한 텍스트 링크. 파란색으로 표시되며 밑줄 효과 포함.

#### 시각적 구조

```
자세히 보기 →  ← 텍스트 + 밑줄 + 호버 효과
```

#### API 명세

```dart
class SketchLink extends StatelessWidget {
  /// 링크 텍스트
  final String text;

  /// URL (외부 링크)
  final String? url;

  /// 탭 시 콜백 (내부 라우팅)
  final VoidCallback? onTap;

  /// 방문 여부
  final bool isVisited;

  /// 텍스트 색상 (기본값: accentPrimary)
  final Color? color;

  /// 폰트 크기
  final double? fontSize;

  /// 아이콘 (선택)
  final IconData? icon;

  /// 아이콘 위치
  final SketchLinkIconPosition iconPosition;

  const SketchLink({
    super.key,
    required this.text,
    this.url,
    this.onTap,
    this.isVisited = false,
    this.color,
    this.fontSize,
    this.icon,
    this.iconPosition = SketchLinkIconPosition.trailing,
  });
}

/// 아이콘 위치
enum SketchLinkIconPosition {
  leading,   // 텍스트 앞
  trailing,  // 텍스트 뒤
}
```

#### 상태별 스타일

| 상태 | 텍스트 색상 | 밑줄 | 배경 |
|------|-----------|------|------|
| Normal (unvisited) | accentPrimary | 점선 (1px) | 투명 |
| Normal (visited) | accentPrimaryDark | 점선 (1px) | 투명 |
| Hover | accentPrimaryDark | 실선 (1.5px) | 미묘한 파란색 배경 |
| Pressed | accentPrimaryDark | 실선 (1.5px) | 진한 파란색 배경 |

#### 레이아웃

```dart
@override
Widget build(BuildContext context) {
  final effectiveColor = color ??
      (isVisited
          ? SketchDesignTokens.accentPrimaryDark
          : SketchDesignTokens.accentPrimary);

  return GestureDetector(
    onTap: () {
      if (url != null) {
        _launchUrl(url!);
      }
      onTap?.call();
    },
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && iconPosition == SketchLinkIconPosition.leading) ...[
            Icon(icon, size: fontSize ?? SketchDesignTokens.fontSizeBase, color: effectiveColor),
            SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: SketchDesignTokens.fontFamilyHand,
              fontSize: fontSize ?? SketchDesignTokens.fontSizeBase,
              color: effectiveColor,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
              decorationColor: effectiveColor,
            ),
          ),
          if (icon != null && iconPosition == SketchLinkIconPosition.trailing) ...[
            SizedBox(width: 4),
            Icon(icon, size: fontSize ?? SketchDesignTokens.fontSizeBase, color: effectiveColor),
          ],
        ],
      ),
    ),
  );
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}
```

#### 사용 예시

```dart
// 기본 링크
SketchLink(
  text: '자세히 보기',
  onTap: () => navigateToDetail(),
)

// 외부 URL
SketchLink(
  text: 'Frame0 홈페이지',
  url: 'https://frame0.app',
  icon: Icons.open_in_new,
)

// 방문한 링크
SketchLink(
  text: '이미 본 문서',
  url: 'https://example.com',
  isVisited: true,
)

// 인라인 링크
Text.rich(
  TextSpan(
    text: '더 많은 정보는 ',
    children: [
      WidgetSpan(
        child: SketchLink(
          text: '여기',
          onTap: () {},
        ),
      ),
      TextSpan(text: '를 참고하세요.'),
    ],
  ),
)
```

---

### 3.11 SketchAppBar

**우선순위**: P1

#### 개요

화면 상단의 앱 바. 제목, 뒤로가기 버튼, 액션 버튼을 포함.

#### 시각적 구조

```
┌──────────────────────────────┐
│ ←  타이틀         ⋮  🔍      │  ← leading / title / actions
└──────────────────────────────┘
```

#### API 명세

```dart
class SketchAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 타이틀
  final String? title;

  /// 타이틀 위젯 (커스텀)
  final Widget? titleWidget;

  /// 좌측 위젯 (뒤로가기 버튼 등)
  final Widget? leading;

  /// 우측 액션 버튼 목록
  final List<Widget>? actions;

  /// 배경색
  final Color? backgroundColor;

  /// 텍스트 색상
  final Color? foregroundColor;

  /// 그림자 표시 여부
  final bool showShadow;

  /// 손그림 테두리 표시 여부
  final bool showSketchBorder;

  /// 앱 바 높이
  final double height;

  const SketchAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.showShadow = true,
    this.showSketchBorder = false,
    this.height = 56.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);
}
```

#### 레이아웃

```dart
@override
Widget build(BuildContext context) {
  final theme = SketchThemeExtension.of(context);
  final effectiveBgColor = backgroundColor ?? theme.fillColor;
  final effectiveFgColor = foregroundColor ?? SketchDesignTokens.textPrimary;

  Widget appBarContent = Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: effectiveBgColor,
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ]
          : null,
    ),
    child: Row(
      children: [
        // Leading
        if (leading != null)
          leading!
        else if (Navigator.canPop(context))
          SketchIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),

        // Title
        Expanded(
          child: titleWidget ??
              Text(
                title ?? '',
                style: TextStyle(
                  fontFamily: SketchDesignTokens.fontFamilyHand,
                  fontSize: SketchDesignTokens.fontSizeLg,
                  fontWeight: FontWeight.w600,
                  color: effectiveFgColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
        ),

        // Actions
        if (actions != null) ...actions!,
      ],
    ),
  );

  // 손그림 테두리 추가 (옵션)
  if (showSketchBorder) {
    appBarContent = CustomPaint(
      painter: SketchPainter(
        fillColor: effectiveBgColor,
        borderColor: theme.borderColor,
        strokeWidth: theme.strokeWidth,
      ),
      child: appBarContent,
    );
  }

  return appBarContent;
}
```

#### 사용 예시

```dart
// 기본 앱 바
Scaffold(
  appBar: SketchAppBar(
    title: '홈',
  ),
  body: body,
)

// 액션 버튼 포함
Scaffold(
  appBar: SketchAppBar(
    title: '설정',
    actions: [
      SketchIconButton(
        icon: Icons.search,
        onPressed: () => showSearch(),
      ),
      SketchIconButton(
        icon: Icons.more_vert,
        onPressed: () => showMenu(),
      ),
    ],
  ),
)

// 커스텀 leading
Scaffold(
  appBar: SketchAppBar(
    leading: SketchIconButton(
      icon: Icons.menu,
      onPressed: () => openDrawer(),
    ),
    title: '메뉴',
  ),
)

// 손그림 테두리 포함
Scaffold(
  appBar: SketchAppBar(
    title: '스케치 스타일',
    showSketchBorder: true,
  ),
)
```

---

## 4. 색상 팔레트 (Color Palette)

### Light Mode

| 토큰 | HEX | 용도 |
|------|-----|------|
| `backgroundColor` | `#FAF8F5` | 전체 앱 배경 |
| `surfaceColor` | `#F5F0E8` | 카드, 모달 배경 |
| `surfaceVariant` | `#EBE6DC` | 호버, 선택 배경 |
| `accentPrimary` | `#2196F3` | 링크, 선택 상태 |
| `accentPrimaryLight` | `#64B5F6` | 호버, 미묘한 강조 |
| `accentPrimaryDark` | `#1976D2` | 방문한 링크, 눌림 상태 |
| `accentSecondary` | `#DF7D5F` | CTA 버튼 |
| `accentSecondaryLight` | `#F19E7E` | 버튼 호버 |
| `accentSecondaryDark` | `#C86947` | 버튼 눌림 |
| `textPrimary` | `#000000` | 주요 텍스트 |
| `textSecondary` | `#2C2C2C` | 보조 텍스트 |
| `textTertiary` | `#5E5E5E` | 덜 중요한 텍스트 |
| `textDisabled` | `#8E8E8E` | 비활성 텍스트 |
| `outlinePrimary` | `#343434` | 주요 테두리 |
| `outlineSecondary` | `#5E5E5E` | 보조 테두리 |
| `outlineSubtle` | `#DCDCDC` | 미묘한 구분선 |
| `success` | `#4CAF50` | 성공 상태 |
| `warning` | `#FFC107` | 경고 상태 |
| `error` | `#F44336` | 에러 상태 |
| `info` | `#2196F3` | 정보 (accentPrimary와 동일) |

### Dark Mode

| 토큰 | HEX | 용도 |
|------|-----|------|
| `backgroundColor` | `#1A1D29` | 전체 앱 배경 (네이비/차콜) |
| `surfaceColor` | `#23273A` | 카드, 모달 배경 |
| `surfaceVariant` | `#2C3048` | 호버, 선택 배경 |
| `accentPrimary` | `#64B5F6` | 링크, 선택 상태 (더 밝음) |
| `accentPrimaryLight` | `#90CAF9` | 호버 |
| `accentPrimaryDark` | `#42A5F5` | 방문한 링크 |
| `accentSecondary` | `#F19E7E` | CTA 버튼 (더 밝음) |
| `accentSecondaryLight` | `#FFBFA0` | 버튼 호버 |
| `accentSecondaryDark` | `#DF7D5F` | 버튼 눌림 |
| `textPrimary` | `#FFFFFF` | 주요 텍스트 |
| `textSecondary` | `#E5E5E5` | 보조 텍스트 |
| `textTertiary` | `#AAAAAA` | 덜 중요한 텍스트 |
| `textDisabled` | `#6E6E6E` | 비활성 텍스트 |
| `outlinePrimary` | `#5E5E5E` | 주요 테두리 |
| `outlineSecondary` | `#8E8E8E` | 보조 테두리 |
| `outlineSubtle` | `#3A3A3A` | 미묘한 구분선 |
| `success` | `#66BB6A` | 성공 상태 (더 밝음) |
| `warning` | `#FFCA28` | 경고 상태 (더 밝음) |
| `error` | `#EF5350` | 에러 상태 (더 밝음) |
| `info` | `#64B5F6` | 정보 (accentPrimary와 동일) |

---

## 5. 타이포그래피 (Typography)

### 폰트 패밀리

| 카테고리 | 폰트 | 용도 | Dart 상수 |
|---------|------|------|----------|
| **Hand** | PatrickHand | 기본 UI 텍스트, 손글씨 느낌 | `SketchDesignTokens.fontFamilyHand` |
| **Sans** | Roboto | 버튼, 짧은 라벨 (옵션) | `SketchDesignTokens.fontFamilySans` |
| **Mono** | Courier | 숫자, 코드, 기술 정보 | `SketchDesignTokens.fontFamilyMono` |
| **Serif** | Georgia | 본문, 긴 텍스트 (옵션) | `SketchDesignTokens.fontFamilySerif` |

### Type Scale

| 레벨 | Size (px) | Weight | Line Height | 용도 |
|------|----------|--------|-------------|------|
| `6xl` | 60 | 600 | 1.2 | 히어로 타이틀 |
| `5xl` | 48 | 600 | 1.2 | 페이지 타이틀 |
| `4xl` | 36 | 600 | 1.3 | 섹션 헤딩 |
| `3xl` | 30 | 600 | 1.3 | 서브 헤딩 |
| `2xl` | 24 | 500 | 1.4 | 카드 타이틀 |
| `xl` | 20 | 500 | 1.5 | 리스트 타이틀 |
| `lg` | 18 | 400 | 1.5 | 강조 텍스트 |
| `base` | 16 | 400 | 1.5 | 본문 (기본) |
| `sm` | 14 | 400 | 1.5 | 보조 텍스트 |
| `xs` | 12 | 400 | 1.5 | 캡션, 라벨 |

### 사용 예시

```dart
// 타이틀
Text(
  '페이지 제목',
  style: TextStyle(
    fontFamily: SketchDesignTokens.fontFamilyHand,
    fontSize: SketchDesignTokens.fontSize4Xl,
    fontWeight: FontWeight.w600,
    color: SketchDesignTokens.textPrimary,
  ),
)

// 본문
Text(
  '일반 본문 텍스트',
  style: TextStyle(
    fontFamily: SketchDesignTokens.fontFamilyHand,
    fontSize: SketchDesignTokens.fontSizeBase,
    color: SketchDesignTokens.textSecondary,
  ),
)

// 숫자 (Mono 폰트)
Text(
  '1,234',
  style: TextStyle(
    fontFamily: SketchDesignTokens.fontFamilyMono,
    fontSize: SketchDesignTokens.fontSizeLg,
    color: SketchDesignTokens.textPrimary,
  ),
)
```

---

## 6. 스페이싱 시스템 (Spacing System)

### 8dp 그리드

| 토큰 | Value (dp) | 용도 |
|------|-----------|------|
| `xs` | 4 | 작은 간격 (아이콘-텍스트) |
| `sm` | 8 | 기본 간격 (위젯 내부) |
| `md` | 12 | 중간 간격 |
| `lg` | 16 | 큰 간격 (위젯 간) |
| `xl` | 24 | 섹션 간격 |
| `2xl` | 32 | 그룹 간격 |
| `3xl` | 48 | 메이저 섹션 |
| `4xl` | 64 | 페이지 구분 |

### 컴포넌트별 권장 스페이싱

| 컴포넌트 | 내부 Padding | 외부 Margin | 요소 간 간격 |
|---------|-------------|------------|------------|
| SketchButton | horizontal: 24, vertical: 12 | lg (16) | md (12) |
| SketchCard | xl (24) | lg (16) | lg (16) |
| SketchInput | horizontal: 16, vertical: 12 | lg (16) | sm (8) |
| SketchModal | 2xl (32) | - | lg (16) |
| SketchTabBar | horizontal: 16 | - | md (12) |
| SketchBottomNavigationBar | lg (16) | - | sm (8) |
| SketchAvatar | - | sm (8) | sm (8) |

### 화면 레이아웃

```dart
// 화면 전체 패딩
Scaffold(
  body: Padding(
    padding: EdgeInsets.all(SketchDesignTokens.spacingLg), // 16
    child: Column(
      children: [
        _buildHeader(),
        SizedBox(height: SketchDesignTokens.spacingXl), // 24 (섹션 간격)
        _buildContent(),
      ],
    ),
  ),
)
```

---

## 7. Border Radius

| 토큰 | Value (dp) | 용도 |
|------|-----------|------|
| `none` | 0 | 직각 모서리 |
| `sm` | 2 | 매우 작은 둥글기 |
| `md` | 4 | 작은 둥글기 (Input) |
| `lg` | 8 | 기본 둥글기 (Card) |
| `xl` | 12 | 큰 둥글기 (Modal) |
| `2xl` | 16 | 매우 큰 둥글기 |
| `pill` | 9999 | 캡슐 형태 (Button) |
| `circle` | 50% | 완전한 원형 (Avatar) |

---

## 8. Elevation (그림자)

| 레벨 | Offset Y (dp) | Blur (dp) | 색상 | 용도 |
|------|-------------|----------|------|------|
| 0 | 0 | 0 | - | 평면 (배경) |
| 1 | 1 | 2 | rgba(0,0,0,0.1) | 미묘한 강조 |
| 2 | 2 | 4 | rgba(0,0,0,0.15) | 기본 카드 |
| 3 | 4 | 8 | rgba(0,0,0,0.2) | 떠있는 요소 |
| 4 | 8 | 16 | rgba(0,0,0,0.25) | 모달, 드롭다운 |

---

## 9. 인터랙션 상태 (Interaction States)

### 버튼 상태

| 상태 | 배경 색상 | 텍스트 색상 | Elevation | 투명도 |
|------|----------|-----------|-----------|--------|
| Default | accentSecondary | white | 2 | 1.0 |
| Hover | accentSecondaryLight | white | 3 | 1.0 |
| Pressed | accentSecondaryDark | white | 1 | 1.0 |
| Disabled | base300 | textDisabled | 0 | 0.4 |
| Loading | accentSecondary | white | 2 | 0.8 |

### 입력 필드 상태

| 상태 | 테두리 색상 | 테두리 두께 | 배경 색상 | 라벨 색상 |
|------|-----------|-----------|----------|----------|
| Default | base300 | 2px | surface | textSecondary |
| Focused | accentPrimary | 2.5px | surface | accentPrimary |
| Filled | base700 | 2px | surface | textSecondary |
| Error | error | 2px | surface | error |
| Disabled | base300 | 1.5px | surfaceVariant | textDisabled |

### 터치 피드백

- **Ripple Effect**: `InkWell` 사용, `splashColor: accentPrimary.withValues(alpha: 0.1)`
- **Highlight Color**: `accentPrimary.withValues(alpha: 0.05)`
- **Duration**: 150ms (fast feedback)

---

## 10. 애니메이션 (Animation)

### 기본 Duration

| 타입 | Duration (ms) | 용도 |
|------|-------------|------|
| Fast | 150 | 터치 피드백, 호버 |
| Normal | 250 | 상태 전환, 페이드 |
| Slow | 350 | 화면 전환, 슬라이드 |

### Curve

| Curve | 용도 |
|-------|------|
| `Curves.easeOut` | 요소 등장 (빠르게 시작, 부드럽게 끝) |
| `Curves.easeIn` | 요소 사라짐 (부드럽게 시작, 빠르게 끝) |
| `Curves.easeInOut` | 상태 전환 (부드러운 시작과 끝) |

### 애니메이션 패턴

**1. Fade In/Out**
```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 250),
  curve: Curves.easeIn,
  child: child,
)
```

**2. Scale**
```dart
AnimatedScale(
  scale: isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 150),
  curve: Curves.easeOut,
  child: child,
)
```

**3. Slide**
```dart
AnimatedSlide(
  offset: isOpen ? Offset.zero : Offset(0, 1),
  duration: Duration(milliseconds: 350),
  curve: Curves.easeInOut,
  child: child,
)
```

**4. Color Transition**
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  color: isSelected ? accentPrimary : base300,
  child: child,
)
```

---

## 11. 반응형 레이아웃 (Responsive Layout)

### Breakpoints

| Breakpoint | Width (dp) | 용도 |
|-----------|----------|------|
| Mobile | < 600 | 스마트폰 세로 |
| Tablet | 600 ~ 1024 | 태블릿, 스마트폰 가로 |
| Desktop | ≥ 1024 | 데스크탑, 큰 태블릿 |

### 적응형 레이아웃 전략

**세로 모드 (Mobile)**:
- 1열 레이아웃
- Full-width 컴포넌트
- 화면 패딩: 16dp

**가로 모드 (Tablet)**:
- 2열 그리드 (마스터-디테일)
- Fixed-width 컴포넌트 (max 800dp)
- 화면 패딩: 24dp

### 터치 영역

- **최소 크기**: 48x48 dp (Material Design 가이드라인)
- **권장 크기**: 56x56 dp (FAB, SketchIconButton)
- **밀집된 UI**: 최소 40x40 dp

---

## 12. 접근성 (Accessibility)

### 색상 대비

| 조합 | 대비율 | WCAG 레벨 |
|------|-------|----------|
| textPrimary (#000000) vs background (#FAF8F5) | 20.67:1 | AAA |
| accentPrimary (#2196F3) vs background (#FAF8F5) | 4.52:1 | AA |
| textSecondary (#2C2C2C) vs background (#FAF8F5) | 15.23:1 | AAA |
| accentPrimary (#64B5F6) vs backgroundDark (#1A1D29) | 7.89:1 | AAA |

**최소 요구사항**: WCAG 2.1 AA (4.5:1 for text, 3:1 for large text)

### 의미 전달

- **색상만으로 의미 전달 금지**: 아이콘 + 텍스트 병행
- **에러 표시**: 빨간색 + 에러 아이콘 + 에러 메시지
- **선택 상태**: 색상 + 체크 마크 + 굵은 테두리

### 스크린 리더 지원

```dart
// 모든 인터랙티브 요소에 Semantics 제공
Semantics(
  label: '검색 버튼',
  button: true,
  child: SketchIconButton(
    icon: Icons.search,
    onPressed: onSearch,
  ),
)

// TextField Semantics
Semantics(
  label: '이메일 입력 필드',
  textField: true,
  child: SketchInput(
    label: '이메일',
    hint: 'you@example.com',
  ),
)
```

### 폰트 크기 확대 대응

```dart
// MediaQuery.textScaleFactorOf(context)에 반응
Text(
  text,
  style: TextStyle(
    fontSize: SketchDesignTokens.fontSizeBase,
    // textScaleFactor 자동 적용됨
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis, // 확대 시 말줄임 처리
)
```

---

## 13. 코드 품질 수정 사항

### 13.1 ColorSpec → _ColorSpec (Private)

**파일**: `packages/design_system/lib/src/painters/sketch_painter.dart`

```dart
// 변경 전
class ColorSpec {
  final Color color;
  final int seed;
  // ...
}

// 변경 후
class _ColorSpec {  // private 클래스
  final Color color;
  final int seed;
  // ...
}
```

**이유**: 내부 구현 상세를 public API에서 숨김.

---

### 13.2 withOpacity() → withValues(alpha:)

**영향 파일**: 모든 위젯 파일

```dart
// 변경 전
color.withOpacity(0.5)

// 변경 후
color.withValues(alpha: 0.5)
```

**이유**: Dart 3 API 사용 (deprecated API 제거).

---

### 13.3 미사용 파라미터 제거

**영향**: 모든 위젯

제거할 파라미터:
- `roughness` (테마에서만 제어)
- `seed` (내부적으로 자동 생성)
- `bowing` (테마에서만 제어)
- `enableNoise` (성능 이유로 기본 활성화)

**예외**: `SketchContainer`, CustomPainter 클래스는 유지 (고급 사용자용).

```dart
// 변경 전
SketchButton(
  text: '버튼',
  roughness: 0.8,      // 제거
  seed: 42,            // 제거
  bowing: 0.5,         // 제거
  enableNoise: true,   // 제거
  onPressed: () {},
)

// 변경 후
SketchButton(
  text: '버튼',
  onPressed: () {},
)
```

---

### 13.4 SketchDropdown Barrier 추가

**파일**: `packages/design_system/lib/src/widgets/sketch_dropdown.dart`

```dart
// 변경 후
void _showDropdown() {
  showDialog(
    context: context,
    barrierDismissible: true,  // 추가: 외부 탭 시 닫힘
    barrierColor: Colors.transparent,  // 투명 barrier
    builder: (context) {
      return GestureDetector(
        onTap: () => Navigator.pop(context),  // 외부 탭 감지
        child: Material(
          color: Colors.transparent,
          child: _buildDropdownMenu(),
        ),
      );
    },
  );
}
```

---

## 14. Design System 컴포넌트 활용

### 기존 컴포넌트 (13개)

| 컴포넌트 | 파일 | 우선순위 |
|---------|------|---------|
| SketchButton | sketch_button.dart | 수정 (pill 형태) |
| SketchCard | sketch_card.dart | 유지 |
| SketchInput | sketch_input.dart | 유지 |
| SketchModal | sketch_modal.dart | 유지 |
| SketchIconButton | sketch_icon_button.dart | 유지 |
| SketchChip | sketch_chip.dart | 유지 |
| SketchProgressBar | sketch_progress_bar.dart | 유지 |
| SketchSwitch | sketch_switch.dart | 유지 |
| SketchCheckbox | sketch_checkbox.dart | 유지 |
| SketchSlider | sketch_slider.dart | 유지 |
| SketchDropdown | sketch_dropdown.dart | 수정 (barrier) |
| SketchContainer | sketch_container.dart | 수정 (배경색) |
| SocialLoginButton | social_login_button.dart | 수정 (스케치 옵션) |

### 신규 컴포넌트 (11개)

| 컴포넌트 | 파일 | 우선순위 |
|---------|------|---------|
| SketchImagePlaceholder | sketch_image_placeholder.dart | P0 |
| SketchTabBar | sketch_tab_bar.dart | P1 |
| SketchBottomNavigationBar | sketch_bottom_navigation_bar.dart | P1 |
| SketchAvatar | sketch_avatar.dart | P1 |
| SketchRadio | sketch_radio.dart | P1 |
| SketchSearchInput | sketch_search_input.dart | P1 |
| SketchTextArea | sketch_text_area.dart | P1 |
| SketchDivider | sketch_divider.dart | P1 |
| SketchNumberInput | sketch_number_input.dart | P1 |
| SketchLink | sketch_link.dart | P1 |
| SketchAppBar | sketch_app_bar.dart | P1 |

---

## 15. 참고 자료

### Frame0 공식 문서
- 홈페이지: https://frame0.app
- 스타일링 가이드: https://docs.frame0.app/styling/
- 라이브러리: https://docs.frame0.app/libraries/
- 기반 엔진: [DGM.js](https://dgmjs.dev/)

### 프로젝트 내부 문서
- 디자인 토큰: `.claude/guide/mobile/design-tokens.json`
- 디자인 시스템 가이드: `.claude/guide/mobile/design_system.md`
- User Story: `docs/wowa/design-system/user-story.md`
- 갭 분석 보고서: `docs/wowa/design-system/analysis.md`

### Material Design 3
- Material Design 3: https://m3.material.io/
- Color System: https://m3.material.io/styles/color/system
- Typography: https://m3.material.io/styles/typography/overview

### Flutter 위젯 카탈로그
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets
- CustomPainter: https://api.flutter.dev/flutter/rendering/CustomPainter-class.html

---

## 16. 다음 단계 안내

본 디자인 명세를 기반으로 다음 에이전트가 작업을 이어갑니다:

1. **tech-lead**: 기술 아키텍처 설계 (패키지 구조, 의존성, API 설계)
2. **design-specialist**: 신규 위젯 구현 (CustomPainter, 레이아웃, 애니메이션)
3. **code-reviewer**: 코드 품질 검증 (CLAUDE.md 준수, 성능, 접근성)

---

**문서 작성일**: 2026-02-10
**작성자**: UI/UX Designer Agent
**버전**: v2.0 (Frame0 시각 언어 일치)
