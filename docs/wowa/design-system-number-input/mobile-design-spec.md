# Mobile Design Spec: SketchInput Number 모드

## 디자인 개요

기존 `SketchNumberInput`(양쪽 +/- 버튼)을 폐지하고, `SketchInput`에 `number` 모드를 추가한다.
에셋 이미지 기반으로 **단일 컨테이너 안에 텍스트 영역 + 세로 구분선 + 위/아래 chevron 버튼**을 배치한다.

## 에셋 이미지 분석

### 공통 레이아웃 구조

```
┌─────────────────────────────────────────┬────────┐
│                                         │   ^    │
│              365                        │--------│
│                                         │   v    │
└─────────────────────────────────────────┴────────┘
 ← 텍스트 입력 영역 →                      ← 버튼 →
                        │
                   세로 구분선
```

- **전체 형태**: 둥근 사각형 (SketchPainter, irregularBorderRadius)
- **텍스트 영역**: 왼쪽, Expanded로 가용 공간 차지
- **세로 구분선**: SketchLinePainter 또는 CustomPaint로 스케치 스타일 세로선
- **버튼 영역**: 오른쪽 고정 폭 (48px), 위/아래 두 칸으로 분할
- **가로 구분선**: 버튼 영역 내부 상/하 구분

### Light Mode

| 요소 | 값 |
|------|-----|
| 배경 (fill) | `white` (#FFFFFF) → `theme.fillColor` |
| 테두리 (border) | `base900` (#343434) → `theme.borderColor` |
| 테두리 두께 | `strokeBold` (3.0) |
| 텍스트 색상 | `base900` (#343434) → `theme.textColor` |
| chevron 색상 | `base900` (#343434) → `theme.textColor` |
| 구분선 색상 | `base900` (#343434) → `theme.borderColor` |
| 노이즈 텍스처 | 활성 (enableNoise: true) |

### Dark Mode

| 요소 | 값 |
|------|-----|
| 배경 (fill) | `surfaceDark` (#23273A) → `theme.fillColor` |
| 테두리 (border) | `white` (#FFFFFF) → `theme.borderColor` |
| 테두리 두께 | `strokeBold` (3.0) |
| 텍스트 색상 | `white` (#FFFFFF) → `theme.textColor` |
| chevron 색상 | `white` (#FFFFFF) → `theme.textColor` |
| 구분선 색상 | `white` (#FFFFFF) → `theme.borderColor` |
| 노이즈 텍스처 | 활성 (enableNoise: true) |

## 크기 사양

| 항목 | 값 | 비고 |
|------|-----|------|
| 전체 높이 | 44px | 기존 SketchInput과 동일 |
| 버튼 영역 폭 | 48px | 고정 |
| 세로 구분선 두께 | strokeBold (3.0) | SketchPainter 테두리와 동일 |
| 가로 구분선 두께 | strokeStandard (2.0) | 내부 구분, 약간 가늘게 |
| chevron 아이콘 크기 | 16px | compact하게 |
| 텍스트 패딩 | horizontal: spacingMd (12px) | 기존 SketchInput과 동일 |

## Label

| 항목 | 사양 |
|------|------|
| 위치 | 항상 상단 고정 |
| 옵셔널 | `label` 파라미터 (String?) |
| 스타일 | fontFamilyHand, fontSizeSm, fontWeight w500 |
| 간격 | label 하단 6px (기존 SketchInput과 동일) |

## 인터랙션

### 증가/감소 버튼
- **탭 영역**: 각 chevron 버튼은 48x22px (전체 높이의 절반)
- **비활성 상태**: max 도달 시 위 chevron 비활성, min 도달 시 아래 chevron 비활성
- **비활성 색상**: `base500` (50% opacity) / 다크: `base500`
- **탭 피드백**: 없음 (스케치 스타일은 미니멀)

### 텍스트 직접 입력
- 텍스트 영역 탭 시 숫자 키보드 활성화
- 숫자만 입력 가능 (FilteringTextInputFormatter)
- 포커스 시 테두리 두께 strokeThick (4.0)으로 변경 (기존 패턴과 동일)

### 포커스 상태
| 상태 | 테두리 두께 | 테두리 색상 |
|------|-----------|-----------|
| 일반 | strokeBold (3.0) | theme.borderColor |
| 포커스 | strokeThick (4.0) | theme.focusBorderColor |
| 에러 | strokeBold (3.0) | error (#F44336) |
| 비활성 | strokeStandard (2.0) | theme.disabledBorderColor |

## Number 모드 전용 파라미터

| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|-------|------|
| `numberValue` | `double` | 필수 (number 모드일 때) | 현재 숫자 값 |
| `onNumberChanged` | `ValueChanged<double>` | 필수 (number 모드일 때) | 숫자 변경 콜백 |
| `min` | `double?` | null | 최소값 |
| `max` | `double?` | null | 최대값 |
| `step` | `double` | 1.0 | 증감 단위 |
| `decimalPlaces` | `int` | 0 | 소수점 자릿수 |
| `suffix` | `String?` | null | 접미사 (예: "kg", "회") |

## 사용 예시

```dart
// 기본 숫자 입력
SketchInput(
  mode: SketchInputMode.number,
  numberValue: 365,
  onNumberChanged: (v) => setState(() => _value = v),
)

// 라벨 + 범위 + 접미사
SketchInput(
  mode: SketchInputMode.number,
  label: '무게',
  numberValue: 75.0,
  min: 0,
  max: 300,
  suffix: 'kg',
  onNumberChanged: (v) => setState(() => _weight = v),
)

// 소수점
SketchInput(
  mode: SketchInputMode.number,
  label: '거리',
  numberValue: 5.5,
  step: 0.5,
  decimalPlaces: 1,
  suffix: 'km',
  onNumberChanged: (v) => setState(() => _distance = v),
)
```

## Widget Tree 구조

```
Column
├── Text (label, 옵셔널)
├── SizedBox(height: 6)
└── GestureDetector
    └── CustomPaint(SketchPainter)  ← 전체 컨테이너
        └── SizedBox(height: 44)
            └── Row
                ├── Expanded  ← 텍스트 입력 영역
                │   └── Padding(horizontal: 12)
                │       └── Row
                │           ├── Expanded(TextField)
                │           └── Text(suffix, 옵셔널)
                ├── CustomPaint(세로 구분선)  ← SketchLinePainter 또는 직접 그리기
                └── SizedBox(width: 48)  ← 버튼 영역
                    └── Column
                        ├── Expanded  ← 위쪽 chevron (증가)
                        │   └── GestureDetector
                        │       └── Icon(chevronUp, 16px)
                        ├── CustomPaint(가로 구분선)
                        └── Expanded  ← 아래쪽 chevron (감소)
                            └── GestureDetector
                                └── Icon(chevronDown, 16px)
```
