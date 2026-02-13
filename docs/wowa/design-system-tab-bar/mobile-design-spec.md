# UI/UX 디자인 명세: SketchTabBar 스케치 스타일 리빌드

## 개요

SketchTabBar 위젯을 **폴더 탭(folder tab)** 형태의 카드형 디자인으로 리빌드한다.
각 탭이 독립적인 SketchPainter 기반 스케치 테두리를 가지며, 상단 모서리만 둥글고 하단은 직선인 형태이다.
선택/비선택 상태는 배경색 차이로 표현한다.

## 화면 구조

### Widget: SketchTabBar

#### 레이아웃 계층

```
SketchTabBar
└── Column
    ├── Row (탭 항목들)
    │   ├── Expanded
    │   │   └── GestureDetector
    │   │       └── CustomPaint (SketchTabPainter)
    │   │           └── 탭 컨텐츠 (라벨 / 아이콘+라벨 / 아이콘+라벨+배지)
    │   ├── Expanded
    │   │   └── ... (동일 구조)
    │   └── Expanded
    │       └── ... (동일 구조)
    │
    └── CustomPaint (하단 기준선 — SketchLinePainter)
```

#### 위젯 상세

**탭 아이템 (CustomPaint + SketchTabPainter)**

- Painter: `SketchTabPainter` (신규)
- 렌더링: 상단만 둥근 사각형 (폴더 탭 모양)
- 속성:
  - `fillColor`: 선택 탭 → 테마 `fillColor` / 비선택 탭 → 테마 `surfaceColor`
  - `borderColor`: 테마 `borderColor`
  - `strokeWidth`: `SketchDesignTokens.strokeBold` (3.0)
  - `roughness: 0.8` (기본값 — 손그림 흔들림)
  - `seed`: 탭 index 기반 고정 seed
  - `topRadius: 12.0` (상단 모서리 둥글기)
  - `enableNoise: true` (종이 질감)

**탭 컨텐츠 (Column)**

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (tab.icon != null) ...[
      Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(tab.icon, size: 22, color: tabTextColor),
          if (tab.badgeCount != null && tab.badgeCount! > 0)
            Positioned(right: -6, top: -6, child: badge),
        ],
      ),
      SizedBox(height: 2),
    ],
    Text(tab.label, style: tabTextStyle),
  ],
)
```

**하단 기준선**

- Painter: `SketchLinePainter` (기존)
- 렌더링: 탭 바 하단에 수평 스케치 라인
- 선택된 탭 아래는 라인 없음 (탭이 "열린" 폴더처럼 보이도록)

## 탭 형태 시각 사양

### 참조 디자인 분석

**img_25.png (다크 모드)**:
- 탭 배경: 선택 → 검정(#000000), 비선택 → 진한 회색(#4A4A4A)
- 테두리: 밝은 회색/흰색, 두꺼운 선 (약 3px)
- 텍스트: 흰색 "Tab"
- 모서리: 상단만 둥근 형태 (약 10-14px radius)
- 하단: 직선 (기준선과 연결)

**img_26.png (라이트 모드)**:
- 탭 배경: 선택 → 흰색(#FFFFFF), 비선택 → 연한 회색(#E0E0E0)
- 테두리: 검정, 두꺼운 선 (약 3px)
- 텍스트: 검정 "Tab"
- 모서리: 상단만 둥근 형태 (약 10-14px radius)
- 하단: 직선 (기준선과 연결)

### 탭 치수

| 속성 | 텍스트 전용 탭 | 아이콘 + 텍스트 탭 |
|------|--------------|------------------|
| 탭 높이 | 44px | 56px |
| 상단 모서리 반경 | 12px | 12px |
| 내부 패딩 (수평) | 12px | 12px |
| 내부 패딩 (수직) | 8px | 6px |
| 아이콘 크기 | — | 22px |
| 아이콘-라벨 간격 | — | 2px |
| 텍스트 크기 | 14px | 13px |
| 하단 기준선 높이 | 3px (strokeBold) | 3px |

### 탭 높이 자동 결정

탭에 아이콘이 있는지 여부로 높이를 자동 결정:
- 모든 탭이 텍스트 전용: `height = 44px`
- 하나라도 아이콘이 있으면: `height = 56px`

## 색상 팔레트

### 라이트 모드

**선택된 탭**:
- 배경: `SketchThemeExtension.fillColor` (#FAF8F5 — 크림색)
- 테두리: `SketchThemeExtension.borderColor` (#343434 — base900)
- 텍스트/아이콘: `SketchThemeExtension.textColor` (#343434)

**비선택 탭**:
- 배경: `SketchThemeExtension.surfaceColor` (#F7F7F7 — surface)
- 테두리: `SketchThemeExtension.borderColor` (#343434 — base900)
- 텍스트/아이콘: `SketchThemeExtension.textSecondaryColor` (#8E8E8E)

**하단 기준선**:
- 색상: `SketchThemeExtension.borderColor` (#343434)
- 굵기: `SketchDesignTokens.strokeBold` (3.0)

### 다크 모드

**선택된 탭**:
- 배경: `SketchThemeExtension.dark().fillColor` (#1A1D29 — 네이비)
- 테두리: `SketchThemeExtension.dark().borderColor` (#5E5E5E — base700)
- 텍스트/아이콘: `SketchThemeExtension.dark().textColor` (#F5F5F5)

**비선택 탭**:
- 배경: `SketchThemeExtension.dark().surfaceColor` (#2A2D3A — surfaceDark)
- 테두리: `SketchThemeExtension.dark().borderColor` (#5E5E5E)
- 텍스트/아이콘: `SketchThemeExtension.dark().textSecondaryColor` (#B0B0B0)

**하단 기준선**:
- 색상: `SketchThemeExtension.dark().borderColor` (#5E5E5E)

## 타이포그래피

### 탭 라벨

- **Font Family**: `SketchDesignTokens.fontFamilyHand` ("Kalam")
- **Fallback**: `SketchDesignTokens.fontFamilyHandFallback`
- **Font Weight**: 선택 → `FontWeight.w600`, 비선택 → `FontWeight.w400`
- **Font Size**: 텍스트 전용 14px, 아이콘 포함 13px
- **Overflow**: `TextOverflow.ellipsis`, `maxLines: 1`

## 배지 스타일

### 배지 (badgeCount > 0)

- 위치: 아이콘 우상단 (-6, -6)
- 배경: `SketchThemeExtension.badgeColor` (#F44336)
- 텍스트: `SketchThemeExtension.badgeTextColor` (#FFFFFF)
- 폰트: `SketchDesignTokens.fontFamilyMono`, 10px, w600
- 테두리: 탭 배경색과 동일한 색의 1px border
- 크기: 최소 16x16, padding 수평 4px / 수직 2px
- 99 초과 시 "99+" 표시

## 인터랙션 상태

### 탭 선택

- **탭(onTap)**: 선택된 탭 변경
- **시각적 변화**: 배경색 + 텍스트 색상 + 폰트 굵기 변경
- **애니메이션**: 없음 (즉시 전환 — 스케치 스타일 특성)

### 탭 항목 수

- **최소**: 2개
- **최대**: 5개
- **assert**로 범위 검증

## 스페이싱 시스템

### 탭 간 간격

- 탭 간 간격: 없음 (Expanded로 균등 분배, 경계가 맞닿음)
- 탭들이 붙어있는 형태 (참조 이미지와 동일)

### 전체 TabBar 외부 스페이싱

- 탭 바 주변 margin: 없음 (사용처에서 결정)
- 하단 기준선은 탭 아래에 바로 붙음

## 접근성 (Accessibility)

### 의미 전달

```dart
Semantics(
  label: '${tab.label} 탭',
  selected: isSelected,
  button: true,
  child: tabContent,
)
```

### 색상 대비

- 라이트: 선택 텍스트 (#343434) vs 배경 (#FAF8F5) — 충분
- 라이트: 비선택 텍스트 (#8E8E8E) vs 배경 (#F7F7F7) — 3:1 이상
- 다크: 선택 텍스트 (#F5F5F5) vs 배경 (#1A1D29) — 충분
- 다크: 비선택 텍스트 (#B0B0B0) vs 배경 (#2A2D3A) — 3:1 이상

## Design System 컴포넌트 활용

### 기존 재사용 컴포넌트

**SketchLinePainter**:
- 위치: `painters/sketch_line_painter.dart`
- 용도: 하단 기준선 렌더링

### 신규 컴포넌트

**SketchTabPainter** (신규):
- 위치: `painters/sketch_tab_painter.dart`
- 용도: 탭 형태(상단 둥근, 하단 직선) 렌더링
- SketchPainter의 `_createSketchPath` 방식을 참고하되, 상단 모서리만 radius 적용

### 제거 대상

- `SketchTabIndicatorStyle` enum: 더 이상 불필요 (underline/filled 인디케이터 제거)
  - 단, 다른 곳에서 참조 시 호환성을 위해 유지하되 deprecated 처리

## API 호환성

### 기존 API 유지

```dart
class SketchTabBar extends StatelessWidget {
  final List<SketchTab> tabs;        // 유지
  final int currentIndex;            // 유지
  final ValueChanged<int> onTap;     // 유지
  final SketchTabIndicatorStyle indicatorStyle; // deprecated (무시됨)
  final double height;               // 유지 (기본값 변경: 48→자동 계산)
  final Color? selectedColor;        // 유지 (탭 텍스트/아이콘 색상으로 용도 변경)
  final Color? unselectedColor;      // 유지
  final bool showBorder;             // 유지
}
```

### SketchTab 데이터 클래스 유지

```dart
class SketchTab {
  final String label;       // 유지
  final IconData? icon;     // 유지
  final int? badgeCount;    // 유지
}
```

## 구현 우선순위

1. **SketchTabPainter 생성** (High): 상단만 둥근 탭 형태 커스텀 페인터
2. **SketchTabBar 위젯 리빌드** (High): CustomPaint 기반 탭 렌더링
3. **하단 기준선 추가** (Medium): SketchLinePainter로 기준선
4. **데모 앱 업데이트** (Medium): overflow 수정 확인
5. **다크 모드 테마 검증** (Low): 테마 색상 자동 전환

## 참고 자료

- **참조 이미지**:
  - `prompt/archives/img_25.png`: 다크 모드 폴더 탭 (흰 테두리)
  - `prompt/archives/img_26.png`: 라이트 모드 폴더 탭 (검은 테두리)
  - `prompt/archives/img_27.png`: 현재 SketchTabBar 데모 (overflow 에러)
- **기존 컴포넌트**:
  - `SketchPainter`: 기본 스케치 경로 생성 로직 참조
  - `SketchLinePainter`: 스케치 직선 렌더링
  - `SketchThemeExtension`: 테마 색상 시스템
