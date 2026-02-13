# UI/UX 디자인 명세: SketchBottomNavigationBar 스케치 스타일 적용

## 개요

SketchBottomNavigationBar 위젯에 **SketchPainter 기반 손그림 스케치 스타일 둥근 사각형 테두리**를 적용한다.
현재 `BoxDecoration`의 단순 상단 직선 `BorderSide`를 제거하고, 전체 네비게이션 바를 `CustomPaint(painter: SketchPainter(...))`로 래핑하여 img_28/img_29와 동일한 스케치 질감의 테두리와 노이즈 텍스처를 구현한다.

## 화면 구조

### Widget: SketchBottomNavigationBar

#### 변경 전 레이아웃

```
SketchBottomNavigationBar
└── Container (BoxDecoration: top BorderSide) ← 평면 직선 테두리
    └── Row (items)
        ├── Expanded → GestureDetector → Column (icon + label)
        ├── Expanded → ...
        └── Expanded → ...
```

#### 변경 후 레이아웃

```
SketchBottomNavigationBar
└── CustomPaint (SketchPainter — 전체 둥근 사각형 스케치 테두리)
    └── Padding (strokeWidth/2 inset)
        └── Row (items)
            ├── Expanded → GestureDetector → Column (icon + label)
            ├── Expanded → ...
            └── Expanded → ...
```

#### 핵심 변경

1. **Container + BoxDecoration** → **CustomPaint + SketchPainter** 교체
2. SketchPainter가 전체 네비게이션 바를 둥근 사각형으로 감싸며 스케치 테두리 렌더링
3. 내부 child는 Padding으로 stroke 두께만큼 inset 적용

## SketchPainter 설정

### 파라미터 매핑

| SketchPainter 파라미터 | 값 | 설명 |
|----------------------|---|------|
| `fillColor` | `theme.fillColor` | 네비게이션 바 배경 (라이트: 크림색, 다크: 네이비) |
| `borderColor` | `theme.borderColor` | 테두리 색상 (라이트: 검정 계열, 다크: 회색 계열) |
| `strokeWidth` | `SketchDesignTokens.strokeBold` (3.0) | 두꺼운 손그림 테두리 |
| `roughness` | `theme.roughness` | 테마 기본 거칠기 (0.8) |
| `bowing` | `theme.bowing` | 테마 기본 휘어짐 (0.5) |
| `seed` | 고정값 (예: 42) | 재현 가능한 렌더링 |
| `enableNoise` | `true` | 종이 질감 노이즈 텍스처 |
| `showBorder` | `showBorder` 파라미터 연동 | 테두리 표시/숨김 |
| `borderRadius` | `SketchDesignTokens.irregularBorderRadius` (12.0) | 둥근 모서리 |

## 참조 디자인 분석

### img_28.png (라이트 모드 참조)

- 배경: 밝은 흰색/크림색
- 테두리: 검정, 굵은 선 (약 3px), 손그림 스타일 (약간의 흔들림)
- 모서리: 둥근 사각형 (약 12px radius)
- 텍스트: 검정, 손글씨 폰트 (PatrickHand/Loranthus)
- 노이즈: 미세한 점 노이즈 (종이 질감)

### img_29.png (다크 모드 참조)

- 배경: 검정/어두운 색
- 테두리: 흰색/밝은 회색, 굵은 선 (약 3px), 손그림 스타일
- 모서리: 둥근 사각형 (약 12px radius)
- 텍스트: 흰색, 손글씨 폰트
- 노이즈: 미세한 점 노이즈

### img_30.png (현재 구현 — 문제점)

- 테두리: 상단에만 평면 직선 `BorderSide` → 스케치 스타일 없음
- 오버플로: "BOTTOM OVERFLOWED BY 2.0 PIXELS" 에러 발생
- 원인: 아이콘 크기(28px) + 라벨 + 패딩이 64px 높이를 초과

## 치수 사양

### 네비게이션 바 전체

| 속성 | 값 | 설명 |
|------|---|------|
| 기본 높이 | 68px (64→68 조정) | overflow 방지 + stroke 여유 |
| 모서리 반경 | 12.0px (`irregularBorderRadius`) | 스케치 스타일 둥근 사각형 |
| 테두리 두께 | 3.0px (`strokeBold`) | 참조 이미지 기준 |
| 내부 패딩 | 좌우 4px, 수직 0px | 테두리 안쪽 여유 |

### 네비게이션 아이템

| 속성 | 선택됨 | 비선택 |
|------|-------|-------|
| 아이콘 크기 | 26px | 24px |
| 라벨 크기 | 12px | 12px |
| 아이콘-라벨 간격 | 2px | 2px |
| 수직 패딩 | 6px | 8px |
| 수평 패딩 | 12px | 12px |
| 아이콘 FontWeight | — | — |
| 라벨 FontWeight | w600 | w400 |

## 색상 팔레트

### 라이트 모드

| 요소 | 색상 | 토큰 |
|------|------|------|
| 배경 | 크림색 (#FAF8F5) | `theme.fillColor` |
| 테두리 | 진한 검정 (#343434) | `theme.borderColor` |
| 선택된 아이콘/라벨 | 코랄 (#DF7D5F) | `SketchDesignTokens.accentPrimary` |
| 비선택 아이콘/라벨 | 중간 회색 (#8E8E8E) | `theme.textSecondaryColor` |

### 다크 모드

| 요소 | 색상 | 토큰 |
|------|------|------|
| 배경 | 네이비 (#1A1D29) | `theme.fillColor` |
| 테두리 | 어두운 회색 (#5E5E5E) | `theme.borderColor` |
| 선택된 아이콘/라벨 | 코랄 (#DF7D5F) | `SketchDesignTokens.accentPrimary` |
| 비선택 아이콘/라벨 | 밝은 회색 (#B0B0B0) | `theme.textSecondaryColor` |

## 타이포그래피

### 라벨 텍스트

- **Font Family**: `SketchDesignTokens.fontFamilyHand`
- **Fallback**: `SketchDesignTokens.fontFamilyHandFallback`
- **Font Size**: 12px
- **Font Weight**: 선택 → w600, 비선택 → w400
- **Overflow**: `TextOverflow.ellipsis`, `maxLines: 1`

## 배지 스타일

기존 배지 스타일 유지 (변경 없음):

- 위치: 아이콘 우상단 (-4, -4)
- 배경: `theme.badgeColor` (#F44336)
- 텍스트: `theme.badgeTextColor` (#FFFFFF)
- 폰트: `SketchDesignTokens.fontFamilyMono`, 10px, w600
- 테두리: 배경색과 동일한 1.5px border
- 99 초과 시 "99+" 표시

## 인터랙션 상태

### 아이템 선택

- **탭(onTap)**: 선택된 아이템 변경
- **시각적 변화**: 아이콘 크기 + 아이콘 변경(activeIcon) + 색상 + 라벨 표시/숨김
- **애니메이션**: 없음 (즉시 전환)

### 아이템 수

- **최소**: 2개, **최대**: 5개
- **assert**로 범위 검증

## 접근성 (Accessibility)

### 의미 전달

```dart
Semantics(
  label: '${item.label} 메뉴',
  selected: isSelected,
  button: true,
  child: navItemContent,
)
```

### 색상 대비

- 라이트: 선택 코랄(#DF7D5F) vs 배경(#FAF8F5) — 3:1 이상
- 다크: 선택 코랄(#DF7D5F) vs 배경(#1A1D29) — 4.5:1 이상

## Design System 컴포넌트 활용

### 기존 재사용 컴포넌트

**SketchPainter**:
- 위치: `painters/sketch_painter.dart`
- 용도: 네비게이션 바 전체 스케치 둥근 사각형 테두리 + 노이즈 텍스처

### 신규 컴포넌트

없음 — 기존 `SketchPainter`로 충분

### 제거 대상

없음 — 기존 API 완전 유지

## API 호환성

### 기존 API 유지 (변경 없음)

```dart
class SketchBottomNavigationBar extends StatelessWidget {
  final List<SketchNavItem> items;         // 유지
  final int currentIndex;                  // 유지
  final ValueChanged<int> onTap;           // 유지
  final double height;                     // 유지 (기본값 64→68 변경)
  final Color? selectedColor;              // 유지
  final Color? unselectedColor;            // 유지
  final SketchNavLabelBehavior labelBehavior; // 유지
  final bool showBorder;                   // 유지 (SketchPainter.showBorder로 연동)
}
```

### SketchNavItem 유지

```dart
class SketchNavItem {
  final String label;          // 유지
  final IconData icon;         // 유지
  final IconData? activeIcon;  // 유지
  final int? badgeCount;       // 유지
}
```

## 구현 우선순위

1. **SketchPainter 래핑** (High): Container+BoxDecoration → CustomPaint+SketchPainter
2. **높이/패딩 조정** (High): overflow 에러 해결
3. **데모 앱 확인** (Medium): 3가지 변형 모두 정상 렌더링 확인
4. **다크 모드 테마 검증** (Low): 테마 색상 자동 전환

## 참고 자료

- **참조 이미지**:
  - `prompt/archives/img_28.png`: 라이트 모드 스케치 메뉴 바
  - `prompt/archives/img_29.png`: 다크 모드 스케치 메뉴 바
  - `prompt/archives/img_30.png`: 현재 SketchBottomNavigationBar (overflow 에러)
- **기존 컴포넌트**:
  - `SketchPainter`: 스케치 둥근 사각형 렌더링
  - `SketchThemeExtension`: 테마 색상/렌더링 시스템
