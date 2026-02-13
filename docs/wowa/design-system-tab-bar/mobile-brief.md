# 기술 아키텍처 설계: SketchTabBar 스케치 스타일 리빌드

## 개요

SketchTabBar 위젯을 폴더 탭(folder tab) 형태로 리빌드한다.
기존 `BoxDecoration` + underline indicator 방식에서, `SketchTabPainter` 기반의 손그림 탭 카드 + 하단 기준선 방식으로 전환한다.

**핵심 전략**:
1. `SketchTabPainter` 신규 생성 — 상단만 둥근 탭 형태의 스케치 경로
2. `SketchTabBar.build()` 전면 리빌드 — CustomPaint 기반 탭 렌더링
3. 하단 기준선 — `SketchLinePainter`로 탭 아래 수평선
4. overflow 해결 — 아이콘 유무에 따른 동적 높이 결정

## 위젯 트리 구조 변경

### 현재 구조 (BoxDecoration + underline)

```
SketchTabBar
└── Container (BoxDecoration: bottom border)
    └── Row
        └── Expanded × N
            └── GestureDetector
                └── Container (transparent)
                    └── Column
                        ├── Icon (optional)
                        ├── SizedBox(4)
                        ├── Text (label)
                        ├── SizedBox(4)
                        └── AnimatedContainer (underline indicator)
```

**문제점**:
- 고정 height(48px)에 Icon(24)+SizedBox(4)+Text(14)+SizedBox(4)+Indicator(3) = 49px → overflow
- `BoxDecoration`으로 평면적 border → 스케치 느낌 없음
- underline indicator → 참조 디자인과 불일치

### 변경 후 구조 (CustomPaint + 폴더 탭)

```
SketchTabBar
└── Column(mainAxisSize: min)
    ├── Row
    │   └── Expanded × N
    │       └── GestureDetector
    │           └── CustomPaint(painter: SketchTabPainter)
    │               └── Padding
    │                   └── Column(mainAxisAlignment: center)
    │                       ├── Stack [Icon + Badge] (optional)
    │                       ├── SizedBox(2) (optional)
    │                       └── Text (label)
    │
    └── CustomPaint(painter: SketchLinePainter) ← 하단 기준선
        └── SizedBox(height: strokeWidth)
```

## SketchTabPainter 설계 (신규)

### 파일 위치

`apps/mobile/packages/design_system/lib/src/painters/sketch_tab_painter.dart`

### 경로 생성 알고리즘

상단만 둥근 직사각형 경로를 `SketchPainter`와 동일한 방식(jitter 기반)으로 생성한다.

```dart
class SketchTabPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;
  final double roughness;
  final int seed;
  final bool enableNoise;
  final double topRadius;      // 상단 모서리 반경 (기본: 12.0)
  final bool isSelected;       // 선택 상태 (하단 테두리 생략용)
  final bool showLeftBorder;   // 좌측 테두리 표시
  final bool showRightBorder;  // 우측 테두리 표시
}
```

### 경로 생성 핵심 로직

```
Path 구성:
1. 좌하단에서 시작 (0, height)
2. 좌측 변을 위로 올라감 → (0, topRadius)
3. 좌상단 둥근 모서리 → (topRadius, 0)
4. 상단 변을 오른쪽으로 → (width - topRadius, 0)
5. 우상단 둥근 모서리 → (width, topRadius)
6. 우측 변을 아래로 → (width, height)
7. 하단은 close하지 않음 (선택 탭) 또는 직선으로 close (비선택 탭)
```

**선택된 탭**: 하단 변을 그리지 않음 → 기준선과 "연결"되어 열린 폴더 느낌
**비선택 탭**: 하단 변 포함하여 닫힌 형태

### jitter 적용

`SketchPainter._createSketchPath`와 동일한 방식:
1. 기본 경로(상단만 둥근 RRect)를 생성
2. `PathMetric`으로 포인트 균등 샘플링 (약 6px 간격)
3. 법선 방향으로 `roughness * 1.0` 범위의 jitter 추가
4. 이차 베지어 곡선으로 부드럽게 연결

### 노이즈 텍스처

`SketchPainter._drawNoiseTexture`와 동일:
- `enableNoise: true`일 때 스케치 경로 내부에 노이즈 도트 렌더링
- 클립 경로로 영역 제한

### shouldRepaint

모든 속성 비교: `fillColor`, `borderColor`, `strokeWidth`, `roughness`, `seed`, `enableNoise`, `topRadius`, `isSelected`, `showLeftBorder`, `showRightBorder`

## SketchTabBar 위젯 변경

### 높이 자동 결정

```dart
/// 탭에 아이콘이 있는지 확인하여 높이 결정.
double get _effectiveHeight {
  if (height != null) return height!; // 명시적 높이 우선
  final hasIcon = tabs.any((tab) => tab.icon != null);
  return hasIcon ? 56.0 : 44.0;
}
```

### height 파라미터 변경

```dart
// 기존: final double height; (기본값 48.0)
// 변경: final double? height; (기본값 null → 자동 결정)
const SketchTabBar({
  // ...
  this.height, // null이면 자동 결정 (아이콘 유무에 따라 44/56)
});
```

### build() 메서드 전면 리빌드

```dart
@override
Widget build(BuildContext context) {
  final theme = SketchThemeExtension.of(context);
  final tabHeight = _effectiveHeight;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 탭 Row
      SizedBox(
        height: tabHeight,
        child: Row(
          children: List.generate(tabs.length, (index) {
            return Expanded(
              child: _buildTabItem(
                index: index,
                tab: tabs[index],
                isSelected: index == currentIndex,
                theme: theme,
                tabHeight: tabHeight,
              ),
            );
          }),
        ),
      ),
      // 하단 기준선
      if (showBorder)
        CustomPaint(
          painter: SketchLinePainter(
            start: Offset.zero,
            end: Offset(MediaQuery.of(context).size.width, 0),
            color: theme.borderColor,
            strokeWidth: SketchDesignTokens.strokeBold,
            roughness: theme.roughness,
            seed: tabs.length * 100, // 탭 수 기반 seed
          ),
          child: SizedBox(
            height: SketchDesignTokens.strokeBold,
            width: double.infinity,
          ),
        ),
    ],
  );
}
```

### _buildTabItem 리빌드

```dart
Widget _buildTabItem({
  required int index,
  required SketchTab tab,
  required bool isSelected,
  required SketchThemeExtension theme,
  required double tabHeight,
}) {
  // 색상 결정
  final fillColor = isSelected ? theme.fillColor : theme.surfaceColor;
  final textIconColor = isSelected
      ? (selectedColor ?? theme.textColor)
      : (unselectedColor ?? theme.textSecondaryColor);

  return GestureDetector(
    onTap: () => onTap(index),
    child: Semantics(
      label: '${tab.label} 탭',
      selected: isSelected,
      button: true,
      child: CustomPaint(
        painter: SketchTabPainter(
          fillColor: fillColor,
          borderColor: theme.borderColor,
          strokeWidth: SketchDesignTokens.strokeBold,
          roughness: theme.roughness,
          seed: index * 42, // 탭별 고유 seed
          enableNoise: true,
          topRadius: 12.0,
          isSelected: isSelected,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: _buildTabContent(tab, textIconColor, theme),
        ),
      ),
    ),
  );
}
```

### _buildTabContent (신규)

```dart
Widget _buildTabContent(SketchTab tab, Color color, SketchThemeExtension theme) {
  final hasIcon = tabs.any((t) => t.icon != null);
  final fontSize = hasIcon ? 13.0 : 14.0;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (tab.icon != null) ...[
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(tab.icon, size: 22, color: color),
            if (tab.badgeCount != null && tab.badgeCount! > 0)
              Positioned(
                right: -6,
                top: -6,
                child: _buildBadge(tab.badgeCount!, theme),
              ),
          ],
        ),
        const SizedBox(height: 2),
      ],
      Text(
        tab.label,
        style: TextStyle(
          fontFamily: SketchDesignTokens.fontFamilyHand,
          fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
          fontSize: fontSize,
          color: color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ],
  );
}
```

## 하단 기준선 전략

### LayoutBuilder 기반 너비 결정

`MediaQuery.of(context).size.width` 대신 `LayoutBuilder`를 사용하여 실제 위젯 너비에 맞춤:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    return CustomPaint(
      painter: SketchLinePainter(
        start: Offset(0, 0),
        end: Offset(constraints.maxWidth, 0),
        color: theme.borderColor,
        strokeWidth: SketchDesignTokens.strokeBold,
        roughness: theme.roughness,
        seed: tabs.length * 100,
      ),
      child: SizedBox(
        height: SketchDesignTokens.strokeBold,
        width: double.infinity,
      ),
    );
  },
)
```

## 제거 대상

### _buildIndicator 메서드 제거

기존 underline/filled 인디케이터 빌드 로직 전체 제거.
선택 상태는 이제 탭 배경색으로 표현.

### indicatorStyle 파라미터 처리

- **완전 제거하지 않음** — 기존 사용처에서 컴파일 에러 방지
- `@Deprecated` 어노테이션 추가
- 내부에서 무시 (사용하지 않음)

```dart
@Deprecated('카드형 탭 디자인으로 변경되어 더 이상 사용되지 않습니다')
final SketchTabIndicatorStyle indicatorStyle;
```

## 수정 대상 파일 및 영향도

### 파일 1: sketch_tab_painter.dart (신규 생성)

**위치**: `apps/mobile/packages/design_system/lib/src/painters/sketch_tab_painter.dart`

**내용**:
- `SketchTabPainter` CustomPainter 클래스
- 상단만 둥근 탭 형태 경로 생성
- fill, border, noise 렌더링
- `SketchPainter`의 jitter/noise 알고리즘 재사용

**영향도**: ✅ 없음 — 신규 파일

### 파일 2: sketch_tab_bar.dart (전면 수정)

**위치**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_tab_bar.dart`

**수정 내용**:
1. `build()` 메서드 전면 리빌드
2. `_buildTabItem()` 리빌드
3. `_buildTabContent()` 신규 추가
4. `_buildIndicator()` 제거
5. `height` 파라미터를 `double?`로 변경 (자동 결정)
6. `indicatorStyle` deprecated 처리
7. import 추가: `SketchTabPainter`, `SketchLinePainter`

**영향도**: ⚠️ 중간 — 시각적 변경 (기능/API 호환)

### 파일 3: tab_bar_demo.dart (업데이트)

**위치**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/tab_bar_demo.dart`

**수정 내용**:
- `height` 파라미터 제거 (자동 결정)
- 필요시 추가 데모 예제

**영향도**: ✅ 낮음 — 데모 앱만 영향

### 파일 4: design_system.dart (export 추가)

**위치**: 디자인 시스템 barrel export 파일

**수정 내용**:
- `sketch_tab_painter.dart` export 추가

**영향도**: ✅ 낮음

## 구현 단계별 계획

### 단계 1: SketchTabPainter 생성

**작업**:
1. `sketch_tab_painter.dart` 파일 생성
2. 상단만 둥근 직사각형 기본 경로 생성
3. `SketchPainter._createSketchPath` 방식의 jitter 적용
4. fill + noise + border 렌더링 구현
5. `isSelected`에 따른 하단 테두리 생략 로직

**검증**: `SketchTabPainter` 단독 테스트 (CustomPaint에 직접 적용)

### 단계 2: SketchTabBar 위젯 리빌드

**작업**:
1. `build()` 메서드를 Column(Row + 기준선)으로 재구성
2. `_buildTabItem()` CustomPaint 기반으로 리빌드
3. `_buildTabContent()` 신규 구현
4. `_buildIndicator()` 제거
5. height 자동 결정 로직 추가
6. `indicatorStyle` deprecated 처리

**검증**: 데모 앱에서 기본 탭, 아이콘 탭, 배지 탭 렌더링 확인

### 단계 3: 하단 기준선 추가

**작업**:
1. LayoutBuilder로 실제 너비 확보
2. SketchLinePainter로 수평 기준선 렌더링
3. showBorder에 따른 기준선 표시/숨김

**검증**: 기준선이 탭 아래에 정확히 위치하는지 확인

### 단계 4: 데모 앱 업데이트 및 최종 검증

**작업**:
1. `tab_bar_demo.dart` 업데이트 (height 파라미터 정리)
2. 시각적 QA: 라이트/다크 모드
3. overflow 에러 해결 확인
4. 배지 정상 표시 확인

## 성능 고려사항

### CustomPaint 최적화

- `shouldRepaint()`로 불필요한 리페인트 방지
- seed 고정(index 기반)으로 일관된 렌더링
- 탭 수 최대 5개 → CustomPaint 인스턴스 5개 이하 (성능 영향 미미)

### noise 텍스처

- 탭 면적이 작으므로 노이즈 도트 수 제한적 (dotCount = area/100)
- `enableNoise: true`지만 성능 부담 낮음

## API 호환성 체크리스트

- [x] `tabs` (List<SketchTab>) — 유지
- [x] `currentIndex` (int) — 유지
- [x] `onTap` (ValueChanged<int>) — 유지
- [x] `indicatorStyle` — deprecated (무시됨)
- [x] `height` — `double` → `double?` (null이면 자동 결정)
- [x] `selectedColor` — 유지 (탭 텍스트/아이콘 색상)
- [x] `unselectedColor` — 유지
- [x] `showBorder` — 유지 (하단 기준선 + 탭 테두리)
- [x] `SketchTab` — 유지 (label, icon, badgeCount)

## 검증 기준

- [ ] SketchTabPainter가 상단만 둥근 스케치 경로를 정확히 렌더링
- [ ] 선택 탭: 밝은 배경 + 굵은 텍스트 + 하단 테두리 없음
- [ ] 비선택 탭: 어두운 배경 + 일반 텍스트 + 하단 테두리 있음
- [ ] 하단 기준선이 탭 Row 아래에 정확히 위치
- [ ] 아이콘 탭에서 overflow 에러 없음
- [ ] 배지 정상 표시 (99+ 포함)
- [ ] 라이트/다크 모드 테마 색상 정상 적용
- [ ] showBorder: false 시 테두리/기준선 모두 숨김
- [ ] 기존 API 100% 호환 (height 기본값 변경 외)

## 참고 자료

- **SketchPainter**: `painters/sketch_painter.dart` — jitter/noise 알고리즘 참조
- **SketchLinePainter**: `painters/sketch_line_painter.dart` — 기준선 렌더링
- **SketchThemeExtension**: `theme/sketch_theme_extension.dart` — 테마 색상
- **디자인 명세**: `docs/wowa/design-system-tab-bar/mobile-design-spec.md`
- **User Story**: `docs/wowa/design-system-tab-bar/user-story.md`
