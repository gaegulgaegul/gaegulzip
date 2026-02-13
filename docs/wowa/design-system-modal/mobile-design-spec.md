# Mobile Design Spec: SketchModal 스케치 스타일 리디자인

## 1. 컴포넌트 해부도

```
┌──────────────────────────────────────────────────┐
│  [Shadow Layer - SketchPainter 기반 오프셋 그림자]   │
│                                                    │
│  ┌─── SketchPainter (불규칙 둥근 테두리) ──────────┐ │
│  │                                                │ │
│  │  ┌─ Header ─────────────────── Close(X) ──┐   │ │
│  │  │  "Modal"                     ╳          │   │ │
│  │  │  (fontFamilyHand)    (SketchLinePainter)│   │ │
│  │  └────────────────────────────────────────┘   │ │
│  │                                                │ │
│  │  ┌─ Content Area ───────────────────────────┐ │ │
│  │  │  child (스크롤 가능)                       │ │ │
│  │  └──────────────────────────────────────────┘ │ │
│  │                                                │ │
│  │  ┌─ Actions (optional) ─────────────────────┐ │ │
│  │  │  [Cancel]  [OK]                           │ │ │
│  │  └──────────────────────────────────────────┘ │ │
│  │                                                │ │
│  └────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

## 2. 시각 사양

### 2.1 Light Mode

| 속성 | 값 | 토큰/테마 참조 |
|------|-----|----------------|
| 배경색 | `#FAF8F5` (크림색) | `sketchTheme.fillColor` |
| 테두리색 | `#343434` (base900) | `sketchTheme.borderColor` |
| 테두리 두께 | `3.0px` | `SketchDesignTokens.strokeBold` |
| 테두리 roughness | `0.8` | `SketchDesignTokens.roughness` |
| borderRadius | `12.0` | `SketchDesignTokens.irregularBorderRadius` |
| 노이즈 텍스처 | enabled | `SketchPainter.enableNoise = true` |
| 그림자 색상 | `#000000` alpha 0.25 | `sketchTheme.shadowColor` |
| 그림자 오프셋 | `Offset(4, 4)` | `sketchTheme.shadowOffset` |
| 제목 색상 | `#343434` | `sketchTheme.textColor` |
| X 버튼 색상 | `#343434` | `sketchTheme.borderColor` |

### 2.2 Dark Mode

| 속성 | 값 | 토큰/테마 참조 |
|------|-----|----------------|
| 배경색 | `#1A1D29` (네이비) | `sketchTheme.fillColor` |
| 테두리색 | `#E0E0E0` (밝은 회색) | `sketchTheme.borderColor` |
| 테두리 두께 | `3.0px` | `SketchDesignTokens.strokeBold` |
| 테두리 roughness | `0.8` | 동일 |
| borderRadius | `12.0` | 동일 |
| 노이즈 텍스처 | enabled | 동일 |
| 그림자 색상 | `#000000` alpha 0.40 | `sketchTheme.shadowColor` |
| 그림자 오프셋 | `Offset(4, 4)` | `sketchTheme.shadowOffset` |
| 제목 색상 | `#F5F5F5` | `sketchTheme.textColor` |
| X 버튼 색상 | `#E0E0E0` | `sketchTheme.borderColor` |

## 3. 닫기 버튼 (X) 디자인

### 참조 이미지 분석
- 두꺼운 선으로 그린 X 마크 (Material 아이콘이 아님)
- 약간 기울어지고 불규칙한 손그림 스타일
- 크기: 약 20x20px 터치 영역 내

### 구현 방식
`SketchLinePainter`를 사용하여 두 개의 대각선을 그림:
- 선 1: 좌상 → 우하 (Offset(0,0) → Offset(size,size))
- 선 2: 우상 → 좌하 (Offset(size,0) → Offset(0,size))
- strokeWidth: `SketchDesignTokens.strokeBold` (3.0)
- roughness: `0.8`
- 색상: `sketchTheme.borderColor` (light: 검정, dark: 흰색)

### 터치 영역
- 실제 X 그림 크기: 16x16px
- 터치 대상 크기: 32x32px (접근성 최소 기준)
- 눌림 시: `AnimatedScale(0.95)` + 배경색 변경

## 4. 그림자 효과

### 구현 방식
`SketchPainter`를 **두 번** 사용하는 Stack 구조:

1. **그림자 레이어** (뒤쪽):
   - `SketchPainter(fillColor: shadowColor, borderColor: Colors.transparent, showBorder: false)`
   - `Transform.translate(offset: shadowOffset)` 적용
   - 같은 seed 사용하여 본체와 동일한 모양

2. **본체 레이어** (앞쪽):
   - `SketchPainter(fillColor: fillColor, borderColor: borderColor, showBorder: true)`
   - 노이즈 텍스처 활성화

### 그림자 색상
- Light mode: `Colors.black.withValues(alpha: 0.25)` (디자인 이미지에서 진한 그림자)
- Dark mode: `Colors.black.withValues(alpha: 0.40)` (어두운 모드에서 더 어두운 그림자)

## 5. 크기 사양

| 속성 | 값 | 비고 |
|------|-----|------|
| 기본 너비 | 400px | 기존과 동일 |
| 최대 너비 | 화면의 90% | 기존과 동일 |
| 최대 높이 | 화면의 90% | 기존과 동일 |
| 내부 패딩 | `spacingLg` (24px) | 기존과 동일 |
| 헤더-콘텐츠 간격 | `spacingMd` (12px) | 기존과 동일 |
| 액션-콘텐츠 간격 | `spacingLg` (24px) | 기존과 동일 |

## 6. 타이포그래피

| 요소 | 폰트 | 크기 | 굵기 | 비고 |
|------|------|------|------|------|
| 제목 | `fontFamilyHand` | `fontSizeLg` (18px) | w600 | 핸드라이팅 폰트 적용 |

## 7. 애니메이션

| 상태 | 애니메이션 | 값 | 비고 |
|------|----------|-----|------|
| 모달 등장 | Scale + Fade | 250ms, easeOutBack | 기존과 동일 |
| X 버튼 눌림 | Scale | 100ms, 0.95 배율 | 기존과 동일 |
| X 버튼 눌림 배경 | 색상 변경 | `disabledFillColor` | 기존과 동일 |

## 8. 접근성

- 모달에 `Semantics(label: title)` 적용
- X 버튼에 `Semantics(label: '닫기')` 적용
- barrier 탭으로 닫기 지원 (기존 barrierDismissible)
