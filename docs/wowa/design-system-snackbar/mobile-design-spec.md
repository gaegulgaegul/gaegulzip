# UI/UX 디자인 명세: Design System Snackbar

## 개요

Frame0 스케치 스타일의 Snackbar 컴포넌트를 디자인 시스템에 추가하여, 앱 전체에서 일관된 손그림 미학으로 사용자 피드백 메시지를 표시합니다. 4가지 의미론적 타입(success, info, warning, error)과 light/dark 모드를 지원하며, 모든 색상은 디자인 시스템 테마에서 중앙 관리됩니다.

**핵심 UX 전략**: 손으로 그린 듯한 스케치 테두리와 스케치 아이콘으로 친근하고 부드러운 피드백 경험 제공

## 화면 구조

### Snackbar Widget

#### 레이아웃 계층

```
ScaffoldMessenger
└── SnackBar
    └── SketchSnackbar (커스텀 위젯)
        ├── CustomPaint (SketchPainter - 배경 + 테두리)
        │   ├── fillColor: 타입별 배경색 (light/dark)
        │   ├── borderColor: 테두리 색상 (light: 검정, dark: 흰색)
        │   ├── strokeWidth: strokeBold (3.0)
        │   ├── borderRadius: 16.0
        │   ├── enableNoise: true
        │   └── showBorder: true
        │
        └── Padding (16dp)
            └── Row
                ├── CustomPaint (아이콘 - SketchSnackbarIconPainter)
                │   ├── type: SnackbarType (success/info/warning/error)
                │   ├── iconColor: 테두리색과 동일 (light: 검정, dark: 흰색)
                │   └── size: 32x32
                │
                ├── SizedBox(width: 12)
                │
                └── Expanded
                    └── Text (메시지)
                        ├── style: Hand 폰트
                        ├── fontSize: 14.0
                        ├── color: textColor (light: #343434, dark: #F5F5F5)
                        └── maxLines: 3, overflow: ellipsis
```

## 위젯 상세

### SketchSnackbar 위젯

**생성자 파라미터:**
```dart
SketchSnackbar({
  required String message,
  required SnackbarType type,
  Duration duration = const Duration(seconds: 3),
  Key? key,
})
```

**SnackbarType enum:**
```dart
enum SnackbarType { success, info, warning, error }
```

### CustomPaint (배경 + 테두리)

**SketchPainter 설정:**
- fillColor: SketchThemeExtension에서 타입별 배경색 조회
  - success: `successSnackbarBgColor`
  - info: `infoSnackbarBgColor`
  - warning: `warningSnackbarBgColor`
  - error: `errorSnackbarBgColor`
- borderColor: SketchThemeExtension.borderColor (light: #343434, dark: #5E5E5E)
- strokeWidth: `SketchDesignTokens.strokeBold` (3.0)
- borderRadius: 16.0
- roughness: `SketchDesignTokens.roughness` (0.8)
- enableNoise: true
- showBorder: true

**크기:**
- height: 자동 (내용 + 패딩)
- maxWidth: MediaQuery.of(context).size.width - 32 (좌우 16dp 마진)
- minHeight: 64dp

### 아이콘 (CustomPaint)

**SketchSnackbarIconPainter 구현 (각 타입별):**

#### Success 아이콘 (원 + 체크마크)
```
원형 테두리 (SketchCirclePainter)
└── 내부: 체크마크 (✓) - Path로 손그림 스타일 그리기
    ├── 시작점: (0.35, 0.55)
    ├── 중간점: (0.45, 0.65)
    ├── 끝점: (0.65, 0.35)
    └── strokeWidth: 2.0, roughness 적용
```

#### Info 아이콘 (불규칙 원 + "i")
```
불규칙한 원형 (SketchCirclePainter, roughness: 1.2)
└── 내부: "i" 텍스트
    ├── fontSize: 18.0
    ├── fontWeight: FontWeight.bold
    └── fontFamily: Hand 폰트
```

#### Warning 아이콘 (삼각형 + "!")
```
삼각형 (SketchPolygonPainter)
└── sides: 3
    ├── rotation: -pi/2 (위쪽 꼭짓점)
    ├── 내부: "!" 텍스트
    │   ├── fontSize: 18.0
    │   └── fontWeight: FontWeight.bold
```

#### Error 아이콘 (둥근사각형 + "x")
```
둥근 사각형 (SketchPainter)
└── borderRadius: 4.0
    ├── 내부: "x" 텍스트
    │   ├── fontSize: 16.0
    │   └── fontWeight: FontWeight.bold
```

**아이콘 공통 스펙:**
- size: 32x32dp
- iconColor: SketchThemeExtension.borderColor (light: #343434, dark: #5E5E5E)
- strokeWidth: 2.0
- roughness: SketchDesignTokens.roughness (0.8)

### 메시지 텍스트

**Text 위젯:**
- style:
  - fontFamily: `SketchDesignTokens.fontFamilyHand` (Loranthus)
  - fontFamilyFallback: `SketchDesignTokens.fontFamilyHandFallback` (KyoboHandwriting2019)
  - fontSize: 14.0
  - color: SketchThemeExtension.textColor (light: #343434, dark: #F5F5F5)
  - height: 1.4 (line height)
- maxLines: 3
- overflow: TextOverflow.ellipsis

## 색상 팔레트

### Snackbar 배경 색상 (SketchThemeExtension 추가 속성)

#### Success Snackbar
- **Light Mode**:
  - successSnackbarBgColor: `Color(0xFFD4EDDA)` — 연한 민트/초록
- **Dark Mode**:
  - successSnackbarBgColor: `Color(0xFF1B3B2A)` — 진한 초록

#### Info Snackbar
- **Light Mode**:
  - infoSnackbarBgColor: `Color(0xFFD6EEFF)` — 연한 하늘색
- **Dark Mode**:
  - infoSnackbarBgColor: `Color(0xFF0C2D4A)` — 진한 네이비

#### Warning Snackbar
- **Light Mode**:
  - warningSnackbarBgColor: `Color(0xFFFFF9D6)` — 연한 레몬
- **Dark Mode**:
  - warningSnackbarBgColor: `Color(0xFF3B3515)` — 진한 올리브

#### Error Snackbar
- **Light Mode**:
  - errorSnackbarBgColor: `Color(0xFFFFE0E0)` — 연한 분홍
- **Dark Mode**:
  - errorSnackbarBgColor: `Color(0xFF4A1B1B)` — 진한 마룬

### 테두리 및 텍스트 색상

**Light Mode:**
- borderColor: `Color(0xFF343434)` — base900 (기존 테마 사용)
- textColor: `Color(0xFF343434)` — base900 (기존 테마 사용)

**Dark Mode:**
- borderColor: `Color(0xFF5E5E5E)` — base700 (기존 테마 사용)
- textColor: `Color(0xFFF5F5F5)` — textOnDark (기존 테마 사용)

## 타이포그래피

### Snackbar 메시지 텍스트

**TextStyle:**
- **fontFamily**: `Loranthus` (라틴/그리스/키릴)
- **fontFamilyFallback**: `['KyoboHandwriting2019']` (한글)
- **fontSize**: 14.0
- **fontWeight**: FontWeight.normal (400)
- **height**: 1.4 (19.6px line height)
- **color**: SketchThemeExtension.textColor
- **용도**: Snackbar 메시지 본문

### 아이콘 내부 텍스트 (i, !, x)

**TextStyle:**
- **fontFamily**: `Loranthus`
- **fontSize**: 16.0 - 18.0 (아이콘 타입별 조정)
- **fontWeight**: FontWeight.bold (700)
- **color**: SketchThemeExtension.borderColor
- **용도**: 아이콘 내부 문자

## 스페이싱 시스템

### Snackbar 전체 마진
- **좌우 마진**: 16dp (화면 양쪽 여백)
- **하단 마진**: 16dp (화면 하단 여백, SafeArea 고려)

### Snackbar 내부 패딩
- **전체 패딩**: 16dp (상하좌우)

### 위젯 간 간격
- **아이콘 <-> 텍스트**: 12dp (SizedBox)

### 아이콘 크기
- **size**: 32x32dp

## Border Radius

### Snackbar 배경
- **borderRadius**: 16dp — 둥근 사각형, 부드러운 느낌

### Error 아이콘 (둥근사각형)
- **borderRadius**: 4dp — 작은 둥근 모서리

## Elevation (그림자)

**Snackbar 그림자:**
- **elevation**: 6dp — Material SnackBar 기본값 사용
- **shadowColor**: `Color(0x40000000)` — 25% 투명도 검정
- **offset**: (0, 3) — 아래쪽 그림자

## 인터랙션 상태

### 표시 애니메이션
- **SlideTransition**: 화면 하단에서 위로 슬라이드
- **Duration**: 250ms
- **Curve**: Curves.easeOut

### 사라짐 애니메이션
- **FadeTransition**: 서서히 투명해짐
- **Duration**: 150ms
- **Curve**: Curves.easeIn

### 사용자 인터랙션
- **자동 닫힘**: 3초 후 자동 사라짐 (duration 파라미터로 조정 가능)
- **스와이프 닫기**: 좌우 스와이프로 닫기 (SnackBar 기본 동작 활용)
- **탭 닫기**: 불필요 (자동 닫힘 + 스와이프로 충분)

## 애니메이션

### 진입 애니메이션
- **Type**: Slide + Fade
- **Duration**: 250ms
- **Curve**: Curves.easeOut
- **From**: Offset(0, 1) — 화면 하단 밖
- **To**: Offset(0, 0) — 정상 위치

### 퇴장 애니메이션
- **Type**: Fade
- **Duration**: 150ms
- **Curve**: Curves.easeIn
- **From**: Opacity 1.0
- **To**: Opacity 0.0

## 반응형 레이아웃

### Breakpoints
- **Mobile**: width < 600dp — 기본 레이아웃
- **Tablet**: 600dp ≤ width < 1024dp — 동일 레이아웃 (Snackbar는 고정 크기)
- **Desktop**: width ≥ 1024dp — 동일 레이아웃

### 적응형 전략
- **세로 모드**: 화면 하단, 좌우 16dp 마진
- **가로 모드**: 동일 (Snackbar는 방향 무관)

### 터치 영역
- **최소 크기**: 64dp 높이 (메시지 짧을 때도 충분한 터치 영역)
- **스와이프 영역**: Snackbar 전체 영역

## 접근성 (Accessibility)

### 색상 대비
- **Light Mode**:
  - 텍스트(#343434) vs 배경(#D4EDDA~#FFE0E0): 최소 4.5:1 충족
  - 아이콘(#343434) vs 배경: 최소 3:1 충족
- **Dark Mode**:
  - 텍스트(#F5F5F5) vs 배경(#1B3B2A~#4A1B1B): 최소 4.5:1 충족
  - 아이콘(#5E5E5E) vs 배경: 최소 3:1 충족

### 의미 전달
- **색상 + 아이콘**: 색상만으로 의미 전달하지 않음, 아이콘 병행
  - Success: 초록 배경 + 체크마크
  - Info: 파랑 배경 + "i"
  - Warning: 노랑 배경 + 삼각형 + "!"
  - Error: 빨강 배경 + "x"

### 스크린 리더 지원
- **Semantics**: SnackBar의 `content`에 자동 적용 (Flutter 기본)
- **Announcement**:
  - Success: "성공: [메시지]"
  - Info: "정보: [메시지]"
  - Warning: "경고: [메시지]"
  - Error: "오류: [메시지]"
- **Role**: "Alert" (자동)

### 타이밍
- **최소 표시 시간**: 3초 (WCAG 2.2 — 충분한 읽기 시간)
- **사용자 제어**: 스와이프로 언제든 닫을 수 있음

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

**SketchPainter:**
- 용도: Snackbar 배경 + 스케치 테두리 렌더링
- 설정: fillColor (타입별 배경), borderColor, strokeWidth=3.0, borderRadius=16.0, enableNoise=true

**SketchCirclePainter:**
- 용도: Success, Info 아이콘의 원형 테두리
- 설정: fillColor=Colors.transparent, borderColor, strokeWidth=2.0

**SketchPolygonPainter:**
- 용도: Warning 아이콘의 삼각형 테두리
- 설정: sides=3, rotation=-pi/2, fillColor=Colors.transparent, borderColor

### 새로운 컴포넌트 필요

**SketchSnackbarIconPainter (신규):**
- **목적**: 4가지 타입의 스케치 스타일 아이콘 렌더링
- **재사용 가능성**: 높음 (다른 위젯에서도 의미론적 아이콘 필요 시)
- **구현 위치**: `packages/design_system/lib/src/painters/sketch_snackbar_icon_painter.dart`
- **기능**:
  - SnackbarType에 따라 다른 아이콘 렌더링
  - 내부적으로 기존 painter(SketchCirclePainter, SketchPolygonPainter 등) 활용
  - 아이콘 내부 텍스트/체크마크 그리기

**SketchSnackbar (신규):**
- **목적**: Frame0 스타일 Snackbar 위젯
- **재사용 가능성**: 높음 (앱 전체에서 사용)
- **구현 위치**: `packages/design_system/lib/src/widgets/sketch_snackbar.dart`
- **기능**:
  - 4가지 타입별 배경색 + 아이콘 자동 선택
  - 테마 통합 (SketchThemeExtension에서 색상 조회)
  - Flutter SnackBar API와 통합
  - Helper 메서드 제공 (`showSketchSnackbar()`)

## 테마 통합 방법

### SketchThemeExtension 확장

**신규 속성 추가 (8가지):**
```dart
class SketchThemeExtension extends ThemeExtension<SketchThemeExtension> {
  // 기존 속성들...

  /// Snackbar 배경 색상 (Success - Light Mode)
  final Color successSnackbarBgColor;

  /// Snackbar 배경 색상 (Info - Light Mode)
  final Color infoSnackbarBgColor;

  /// Snackbar 배경 색상 (Warning - Light Mode)
  final Color warningSnackbarBgColor;

  /// Snackbar 배경 색상 (Error - Light Mode)
  final Color errorSnackbarBgColor;
}
```

**factory 생성자 업데이트:**
```dart
factory SketchThemeExtension.light() {
  return SketchThemeExtension(
    // 기존 속성들...
    successSnackbarBgColor: Color(0xFFD4EDDA),
    infoSnackbarBgColor: Color(0xFFD6EEFF),
    warningSnackbarBgColor: Color(0xFFFFF9D6),
    errorSnackbarBgColor: Color(0xFFFFE0E0),
  );
}

factory SketchThemeExtension.dark() {
  return SketchThemeExtension(
    // 기존 속성들...
    successSnackbarBgColor: Color(0xFF1B3B2A),
    infoSnackbarBgColor: Color(0xFF0C2D4A),
    warningSnackbarBgColor: Color(0xFF3B3515),
    errorSnackbarBgColor: Color(0xFF4A1B1B),
  );
}
```

### 테마 조회 예시

```dart
// SketchSnackbar 위젯 내부
final sketchTheme = SketchThemeExtension.of(context);

Color getBgColor(SnackbarType type) {
  switch (type) {
    case SnackbarType.success:
      return sketchTheme.successSnackbarBgColor;
    case SnackbarType.info:
      return sketchTheme.infoSnackbarBgColor;
    case SnackbarType.warning:
      return sketchTheme.warningSnackbarBgColor;
    case SnackbarType.error:
      return sketchTheme.errorSnackbarBgColor;
  }
}
```

## 사용 예제

### 기본 사용법

```dart
import 'package:design_system/design_system.dart';

// Success Snackbar 표시
showSketchSnackbar(
  context,
  message: '저장되었습니다!',
  type: SnackbarType.success,
);

// Error Snackbar 표시
showSketchSnackbar(
  context,
  message: '네트워크 오류가 발생했습니다.',
  type: SnackbarType.error,
  duration: Duration(seconds: 5),
);

// Info Snackbar 표시
showSketchSnackbar(
  context,
  message: '새로운 업데이트가 있습니다.',
  type: SnackbarType.info,
);

// Warning Snackbar 표시
showSketchSnackbar(
  context,
  message: '입력 항목을 확인해주세요.',
  type: SnackbarType.warning,
);
```

### 수동 SnackBar 구성

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: SketchSnackbar(
      message: '처리가 완료되었습니다.',
      type: SnackbarType.success,
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0, // SketchPainter 자체 그림자 사용
    duration: Duration(seconds: 3),
  ),
);
```

### GetX Controller 예시

```dart
class MyController extends GetxController {
  void saveData() async {
    try {
      await repository.save();

      showSketchSnackbar(
        Get.context!,
        message: '데이터가 저장되었습니다.',
        type: SnackbarType.success,
      );
    } catch (e) {
      showSketchSnackbar(
        Get.context!,
        message: '저장 실패: ${e.toString()}',
        type: SnackbarType.error,
        duration: Duration(seconds: 5),
      );
    }
  }
}
```

## 구현 우선순위

### Phase 1: Core (핵심 기능)
1. SketchThemeExtension에 Snackbar 배경색 추가
2. SketchSnackbarIconPainter 구현 (4가지 아이콘)
3. SketchSnackbar 위젯 구현
4. showSketchSnackbar() helper 함수

### Phase 2: Integration (통합)
5. design_system.dart에 export 추가
6. design_system_demo 앱에 데모 추가

### Phase 3: Polish (완성도)
7. 애니메이션 미세 조정
8. 접근성 테스트
9. light/dark 모드 전환 테스트

## 기술 노트

### Flutter SnackBar API 제약
- **SnackBar.content**: Widget을 받음 → SketchSnackbar를 content로 전달
- **SnackBar.backgroundColor**: Colors.transparent로 설정 (SketchPainter 배경 사용)
- **SnackBar.elevation**: 0으로 설정 (CustomPaint 그림자 사용 가능)
- **SnackBar.behavior**: SnackBarBehavior.floating 권장 (좌우 마진)

### 노이즈 텍스처 최적화
- **enableNoise=true**: SketchPainter가 자동으로 종이 질감 렌더링
- **성능**: 작은 영역이므로 성능 영향 미미
- **시드 고정**: seed=0 (재현 가능한 텍스처)

### 다크모드 색상 선택 원칙
- **배경색**: 기존 의미론적 색상에서 어두운 변형 선택
- **대비**: WCAG AA 기준 (4.5:1) 충족
- **일관성**: 테두리/텍스트는 기존 테마 색상 재사용

## 참고 자료

- Material Design Snackbar: https://m3.material.io/components/snackbar
- Flutter SnackBar API: https://api.flutter.dev/flutter/material/SnackBar-class.html
- WCAG 2.2 Color Contrast: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- Frame0 Design Language: 내부 디자인 가이드라인
