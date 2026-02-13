# UI/UX 디자인 명세: 스케치 디자인 시스템 비활성화 상태

## 개요

스케치 스타일 디자인 시스템에서 비활성화 상태를 시각적으로 명확하게 구분하기 위해 대각선 빗금(hatching) 패턴을 추가합니다. 기존의 투명도(opacity) 처리와 조합하여 색약자를 포함한 모든 사용자가 비활성화 상태를 직관적으로 인지할 수 있도록 합니다. 추가로 모달의 OK 버튼 스타일을 hatching에서 primary로 변경하여 주요 액션을 명확히 강조합니다.

**핵심 UX 전략:**
- 비활성화 상태 = 기존 opacity 0.5 + 대각선 빗금 패턴 (이중 시각적 신호)
- hatching 패턴의 의미 고정: "비활성화 상태"만을 나타냄 (장식 용도 제거)
- 모달 주요 액션 버튼: primary 스타일로 통일 (검은 배경 + 흰 텍스트)

## 화면 구조

### Screen 1: 비활성화 상태 위젯 예시 (각 위젯별 적용)

#### 레이아웃 계층

```
Scaffold
└── Body: SingleChildScrollView
    ├── Container (padding: 16)
    │   ├── Text ("비활성화 예시")
    │   ├── SizedBox(height: 16)
    │   │
    │   ├── SketchButton (비활성화)
    │   │   ├── onPressed: null → isDisabled: true
    │   │   ├── Opacity(0.5)
    │   │   ├── Stack
    │   │   │   ├── CustomPaint (SketchPainter — 배경/테두리)
    │   │   │   └── Positioned.fill (HatchingPainter — 빗금 오버레이)
    │   │   └── Text (버튼 텍스트)
    │   │
    │   ├── SizedBox(height: 16)
    │   │
    │   ├── SketchCheckbox (비활성화)
    │   │   ├── onChanged: null → isDisabled: true
    │   │   ├── Opacity(0.5)
    │   │   ├── Stack
    │   │   │   ├── CustomPaint (SketchPainter — 테두리)
    │   │   │   └── Positioned.fill (HatchingPainter — 빗금 오버레이)
    │   │   └── (체크 마크는 value에 따라 조건부 렌더링)
    │   │
    │   ├── SizedBox(height: 16)
    │   │
    │   ├── SketchRadio (비활성화)
    │   │   ├── onChanged: null → isDisabled: true
    │   │   ├── Opacity(0.5)
    │   │   ├── Row
    │   │   │   ├── Stack
    │   │   │   │   ├── CustomPaint (_SketchRadioPainter — 원형 테두리)
    │   │   │   │   └── ClipOval (HatchingPainter — 원형 빗금 오버레이)
    │   │   │   └── Text (라벨)
    │   │
    │   ├── SizedBox(height: 16)
    │   │
    │   └── SketchSwitch (비활성화)
    │       ├── onChanged: null → isDisabled: true
    │       ├── Opacity(0.5)
    │       └── Stack
    │           ├── CustomPaint (SketchPainter — 트랙)
    │           ├── Positioned.fill (HatchingPainter — 트랙 빗금 오버레이)
    │           └── Positioned (CustomPaint: SketchCirclePainter — 썸)
```

### Screen 2: 모달 다이얼로그 (수정된 OK 버튼)

#### 레이아웃 계층

```
SketchModal
├── SketchContainer (모달 배경)
│   ├── Row (상단 제목 + 닫기 버튼)
│   │   ├── Text ("Confirm")
│   │   └── IconButton (X — 닫기)
│   │
│   ├── SizedBox(height: 16)
│   │
│   ├── Text (모달 내용)
│   │
│   ├── SizedBox(height: 24)
│   │
│   └── Row (액션 버튼)
│       ├── SketchButton (Cancel)
│       │   ├── style: SketchButtonStyle.outline
│       │   ├── size: SketchButtonSize.small
│       │   └── onPressed: 닫기
│       │
│       ├── SizedBox(width: 8)
│       │
│       └── SketchButton (OK) — **변경됨**
│           ├── style: SketchButtonStyle.primary ← (기존: hatching)
│           ├── size: SketchButtonSize.small
│           ├── fillColor: textColor (검은색)
│           ├── textColor: fillColor (흰색)
│           └── onPressed: 확인
```

## 위젯별 비활성화 상태 상세

### SketchButton (비활성화)

**조건:**
- `onPressed == null && !isLoading`

**시각적 구조:**

```dart
Opacity(
  opacity: 0.5, // 기존 유지
  child: Stack(
    children: [
      // 1. 배경/테두리 (SketchPainter)
      CustomPaint(
        painter: SketchPainter(
          fillColor: disabledFillColor, // base200 또는 테마
          borderColor: disabledBorderColor, // base300
          strokeWidth: strokeStandard,
          showBorder: true,
        ),
        child: Container(...),
      ),

      // 2. 빗금 오버레이 (HatchingPainter) — NEW
      Positioned.fill(
        child: CustomPaint(
          painter: HatchingPainter(
            fillColor: disabledTextColor, // base500
            strokeWidth: 1.0,
            angle: pi / 4, // 45도
            spacing: 6.0,
            roughness: 0.5,
            seed: ...,
            borderRadius: 12.0,
          ),
        ),
      ),
    ],
  ),
)
```

**빗금 패턴 파라미터:**
- `fillColor`: `disabledTextColor` (base500) — Light: #8E8E8E, Dark: #6E6E6E
- `strokeWidth`: 1.0 (얇은 선)
- `angle`: π/4 (45도 대각선)
- `spacing`: 6.0 (선 간격)
- `roughness`: 0.5 (미묘한 스케치 효과)
- `borderRadius`: 12.0 (버튼 테두리와 일치)

**색상 (Light 모드):**
- 배경: `disabledFillColor` = base200 (#F7F7F7)
- 테두리: `disabledBorderColor` = base300 (#DCDCDC)
- 빗금: `disabledTextColor` = base500 (#8E8E8E)
- 투명도: 0.5

**색상 (Dark 모드):**
- 배경: `disabledFillColor` = surfaceVariantDark (#2C3048)
- 테두리: `disabledBorderColor` = outlinePrimaryDark (#5E5E5E)
- 빗금: `disabledTextColor` = textDisabledDark (#6E6E6E)
- 투명도: 0.5

### SketchCheckbox (비활성화)

**조건:**
- `onChanged == null`

**시각적 구조:**

```dart
Opacity(
  opacity: 0.5,
  child: GestureDetector(
    onTap: null, // 비활성화
    child: SizedBox(
      width: 24, height: 24,
      child: Stack(
        children: [
          // 1. 테두리 (SketchPainter)
          CustomPaint(
            painter: SketchPainter(
              fillColor: Colors.transparent,
              borderColor: disabledBorderColor, // base300
              strokeWidth: strokeStandard,
              borderRadius: 4,
              showBorder: true,
            ),
          ),

          // 2. 빗금 오버레이 (HatchingPainter) — NEW
          Positioned.fill(
            child: CustomPaint(
              painter: HatchingPainter(
                fillColor: disabledTextColor, // base500
                strokeWidth: 1.0,
                angle: pi / 4,
                spacing: 6.0,
                roughness: 0.5,
                seed: ...,
                borderRadius: 4.0,
              ),
            ),
          ),

          // 3. 체크 마크 (value == true일 때만)
          if (value == true)
            CustomPaint(
              painter: _SketchCheckMarkPainter(
                color: disabledTextColor, // base500
                strokeWidth: strokeStandard,
                roughness: roughness,
                seed: seed + 1,
              ),
            ),
        ],
      ),
    ),
  ),
)
```

**빗금 패턴 파라미터:**
- `fillColor`: `disabledTextColor` (base500)
- `strokeWidth`: 1.0
- `angle`: π/4
- `spacing`: 6.0
- `roughness`: 0.5
- `borderRadius`: 4.0 (체크박스 테두리와 일치)

**색상 (Light 모드):**
- 테두리: `disabledBorderColor` = base300 (#DCDCDC)
- 빗금: `disabledTextColor` = base500 (#8E8E8E)
- 체크 마크: `disabledTextColor` = base500 (#8E8E8E)
- 투명도: 0.5

### SketchRadio (비활성화)

**조건:**
- `onChanged == null`

**시각적 구조:**

```dart
Opacity(
  opacity: 0.5,
  child: GestureDetector(
    onTap: null,
    child: Row(
      children: [
        SizedBox(
          width: 24, height: 24,
          child: Stack(
            children: [
              // 1. 원형 테두리 (_SketchRadioPainter)
              CustomPaint(
                painter: _SketchRadioPainter(
                  borderColor: disabledBorderColor, // base300
                  dotColor: disabledTextColor, // base500
                  strokeWidth: strokeStandard,
                  innerDotScale: isSelected ? 1.0 : 0.0,
                  roughness: roughness,
                  seed: seed,
                ),
              ),

              // 2. 원형 빗금 오버레이 — NEW
              ClipOval(
                child: CustomPaint(
                  painter: HatchingPainter(
                    fillColor: disabledTextColor, // base500
                    strokeWidth: 1.0,
                    angle: pi / 4,
                    spacing: 6.0,
                    roughness: 0.5,
                    seed: ...,
                    borderRadius: 9999, // 원형 (무한 반지름)
                  ),
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: disabledTextColor, // base500
              fontSize: fontSizeBase,
            ),
          ),
        ],
      ],
    ),
  ),
)
```

**빗금 패턴 파라미터:**
- `fillColor`: `disabledTextColor` (base500)
- `strokeWidth`: 1.0
- `angle`: π/4
- `spacing`: 6.0
- `roughness`: 0.5
- `borderRadius`: 9999 (원형 클립)

**ClipOval 적용:**
- `HatchingPainter`는 기본적으로 `RRect` 클립을 사용
- 원형 라디오 버튼에는 `ClipOval` 위젯으로 감싸서 원형 마스킹

**색상 (Light 모드):**
- 테두리: `disabledBorderColor` = base300 (#DCDCDC)
- 빗금: `disabledTextColor` = base500 (#8E8E8E)
- 내부 점: `disabledTextColor` = base500 (#8E8E8E)
- 라벨: `disabledTextColor` = base500 (#8E8E8E)
- 투명도: 0.5

### SketchSwitch (비활성화)

**조건:**
- `onChanged == null`

**시각적 구조:**

```dart
Opacity(
  opacity: 0.5,
  child: GestureDetector(
    onTap: null,
    child: SizedBox(
      width: 50, height: 28,
      child: Stack(
        children: [
          // 1. 트랙 배경 (SketchPainter)
          CustomPaint(
            painter: SketchPainter(
              fillColor: disabledBorderColor, // base300
              borderColor: disabledBorderColor,
              strokeWidth: strokeStandard * 1.05,
              roughness: roughness * 1.75,
              seed: seed,
              showBorder: true,
              borderRadius: 9999, // pill shape
            ),
          ),

          // 2. 트랙 빗금 오버레이 — NEW
          Positioned.fill(
            child: CustomPaint(
              painter: HatchingPainter(
                fillColor: disabledTextColor, // base500
                strokeWidth: 1.0,
                angle: pi / 4,
                spacing: 6.0,
                roughness: 0.5,
                seed: ...,
                borderRadius: 9999, // pill shape
              ),
            ),
          ),

          // 3. 썸 (원형 — SketchCirclePainter)
          Positioned(
            left: thumbPosition, // 애니메이션 위치
            top: 4.0,
            child: CustomPaint(
              painter: SketchCirclePainter(
                fillColor: disabledFillColor, // base200
                borderColor: disabledFillColor,
                strokeWidth: strokeStandard * 1.05,
                roughness: roughness * 1.75,
                seed: seed + 100,
              ),
              child: SizedBox(width: 20, height: 20),
            ),
          ),
        ],
      ),
    ),
  ),
)
```

**빗금 패턴 파라미터:**
- `fillColor`: `disabledTextColor` (base500)
- `strokeWidth`: 1.0
- `angle`: π/4
- `spacing`: 6.0
- `roughness`: 0.5
- `borderRadius`: 9999 (pill shape)

**색상 (Light 모드):**
- 트랙 배경: `disabledBorderColor` = base300 (#DCDCDC)
- 트랙 빗금: `disabledTextColor` = base500 (#8E8E8E)
- 썸: `disabledFillColor` = base200 (#F7F7F7)
- 투명도: 0.5

## 모달 OK 버튼 스타일 변경

### 변경 사항

**기존 (modal_demo.dart):**

```dart
SketchButton(
  text: 'OK',
  style: SketchButtonStyle.hatching, // ❌ 장식 용도로 사용 (혼동 유발)
  size: SketchButtonSize.small,
  onPressed: () => Navigator.of(context).pop(),
)
```

**수정 후:**

```dart
SketchButton(
  text: 'OK',
  style: SketchButtonStyle.primary, // ✅ 주요 액션 강조
  size: SketchButtonSize.small,
  onPressed: () => Navigator.of(context).pop(),
)
```

### 시각적 비교

| 스타일 | 배경 | 테두리 | 텍스트 | 빗금 | 용도 |
|--------|------|--------|--------|------|------|
| hatching (기존) | 투명 | textColor | textColor | ✅ | ❌ 장식 → 비활성화로 혼동 |
| primary (수정) | textColor (검은색) | textColor | fillColor (흰색) | ❌ | ✅ 주요 액션 강조 |

**변경 이유:**
- hatching 패턴이 "비활성화 상태"를 의미하도록 일관성 확립
- 모달 주요 액션(OK/확인)은 primary 스타일로 시각적 우선순위 부여
- Cancel(outline) vs OK(primary) → 명확한 시각적 계층 구조

## 색상 팔레트 (Light/Dark 모드)

### Light 모드

| 역할 | 토큰 이름 | HEX | 사용 위치 |
|------|----------|-----|----------|
| 비활성화 배경 | `disabledFillColor` | #F7F7F7 (base200) | 버튼 배경, 스위치 썸 |
| 비활성화 테두리 | `disabledBorderColor` | #DCDCDC (base300) | 모든 위젯 테두리, 스위치 트랙 |
| 비활성화 텍스트/빗금 | `disabledTextColor` | #8E8E8E (base500) | 버튼 텍스트, 빗금 선, 체크 마크, 라벨 |
| 기본 텍스트 | `textColor` | #343434 (base900) | 활성 상태 텍스트, primary 버튼 배경 |
| 기본 배경 | `fillColor` | #FAF8F5 (background) | 활성 상태 배경, primary 버튼 텍스트 |

### Dark 모드

| 역할 | 토큰 이름 | HEX | 사용 위치 |
|------|----------|-----|----------|
| 비활성화 배경 | `disabledFillColor` | #2C3048 (surfaceVariantDark) | 버튼 배경, 스위치 썸 |
| 비활성화 테두리 | `disabledBorderColor` | #5E5E5E (outlinePrimaryDark) | 모든 위젯 테두리, 스위치 트랙 |
| 비활성화 텍스트/빗금 | `disabledTextColor` | #6E6E6E (textDisabledDark) | 버튼 텍스트, 빗금 선, 체크 마크, 라벨 |
| 기본 텍스트 | `textColor` | #F5F5F5 (textOnDark) | 활성 상태 텍스트, primary 버튼 배경 |
| 기본 배경 | `fillColor` | #1A1D29 (backgroundDark) | 활성 상태 배경, primary 버튼 텍스트 |

## 타이포그래피 (Frame0 스케치 스타일)

### 폰트 패밀리

- **손글씨 폰트**: `SketchDesignTokens.fontFamilyHand` = "Shadows Into Light"
- **Fallback**: `SketchDesignTokens.fontFamilyHandFallback` = ["Courier New", "monospace"]

### 타입 스케일 (버튼, 라벨)

| 타입 | fontSize | fontWeight | 사용 위치 |
|------|----------|------------|----------|
| `fontSizeSm` | 14.0 | 400 | SketchButtonSize.small 텍스트 |
| `fontSizeBase` | 16.0 | 400 | SketchButtonSize.medium 텍스트, 체크박스/라디오 라벨 |
| `fontSizeLg` | 18.0 | 400 | SketchButtonSize.large 텍스트 |

### 비활성화 상태 텍스트

- **색상**: `disabledTextColor` (Light: #8E8E8E, Dark: #6E8E8E)
- **폰트**: 동일 (fontFamily, fontSize, fontWeight 유지)
- **투명도**: Opacity(0.5) 적용 (부모 위젯)

## 스페이싱 시스템 (8dp 그리드)

### Padding/Margin

| 토큰 | 값 (dp) | 사용 위치 |
|------|---------|----------|
| `spacingSm` | 8.0 | 라벨과 위젯 간 간격 (라디오, 체크박스) |
| `spacingMd` | 16.0 | 위젯 간 세로 간격 |
| `spacingLg` | 24.0 | 섹션 구분 |
| `spacing2Xl` | 48.0 | 큰 섹션 구분 |

### 위젯별 내부 스페이싱

**SketchButton:**
- Small: `EdgeInsets.symmetric(horizontal: 16.0)` (높이: 32.0)
- Medium: `EdgeInsets.symmetric(horizontal: 24.0)` (높이: 44.0)
- Large: `EdgeInsets.symmetric(horizontal: 32.0)` (높이: 56.0)

**SketchCheckbox:**
- 크기: 24x24 (패딩 없음)
- 체크 마크 패딩: `EdgeInsets.all(24 * 0.2)` = 4.8

**SketchRadio:**
- 크기: 24x24 (패딩 없음)
- 라벨 간격: `SizedBox(width: 8)`

**SketchSwitch:**
- 트랙 크기: 50x28
- 썸 패딩: 4.0 (상하좌우)
- 썸 크기: 28 - 8 = 20x20

## Border Radius

| 위젯 | borderRadius | 비고 |
|------|--------------|------|
| SketchButton | 12.0 | `irregularBorderRadius` 토큰 |
| SketchCheckbox | 4.0 | 사각형 (작은 둥글기) |
| SketchRadio | 9999 | 원형 (무한 반지름) |
| SketchSwitch 트랙 | 9999 | pill shape |
| SketchSwitch 썸 | 9999 | 원형 |

**HatchingPainter borderRadius:**
- 부모 위젯의 borderRadius와 일치
- 버튼: 12.0
- 체크박스: 4.0
- 라디오: 9999 (ClipOval 사용)
- 스위치 트랙: 9999

## 스트로크 두께 (Stroke Width)

### 테두리

| 토큰 | 값 | 사용 위치 |
|------|-----|----------|
| `strokeStandard` | 1.5 | 기본 테두리 (버튼, 체크박스, 라디오) |
| `strokeStandard * 1.05` | 1.575 | 스위치 (작은 크기 보정) |

### 빗금 선

| 파라미터 | 값 | 비고 |
|----------|-----|------|
| `strokeWidth` | 1.0 | HatchingPainter 선 두께 (고정) |

## 거칠기 계수 (Roughness)

### SketchPainter (테두리)

| 토큰 | 기본값 | 사용 위치 |
|------|--------|----------|
| `roughness` | 0.7 | 버튼, 체크박스, 라디오 |
| `roughness * 1.75` | 1.225 | 스위치 (작은 크기 보정) |

### HatchingPainter (빗금)

| 파라미터 | 값 | 비고 |
|----------|-----|------|
| `roughness` | 0.5 | 버튼보다 미묘한 스케치 효과 (고정) |

**이유:**
- 빗금 선이 너무 흔들리면 가독성 저하
- 비활성화 상태는 차분하고 안정적인 느낌 유지

## 인터랙션 상태

### 비활성화 상태 (Disabled)

| 위젯 | 조건 | 시각적 피드백 |
|------|------|--------------|
| SketchButton | `onPressed == null && !isLoading` | Opacity(0.5) + 빗금 오버레이 |
| SketchCheckbox | `onChanged == null` | Opacity(0.5) + 빗금 오버레이 |
| SketchRadio | `onChanged == null` | Opacity(0.5) + 빗금 오버레이 |
| SketchSwitch | `onChanged == null` | Opacity(0.5) + 빗금 오버레이 |

**터치 피드백:**
- `onTap: null` (제스처 비활성화)
- `AnimatedScale` 동작 안 함 (버튼만 해당)

### 로딩 상태 (Loading)

**SketchButton만 해당:**
- `isLoading: true` 일 때 비활성화로 간주하지 않음
- 빗금 오버레이 표시 안 함
- CircularProgressIndicator 표시 (색상: `textColor`)

### 활성 상태 (Active)

| 위젯 | 조건 | 시각적 피드백 |
|------|------|--------------|
| SketchButton | `onPressed != null` | AnimatedScale(0.98) on press |
| SketchCheckbox | `onChanged != null` | 체크 마크 애니메이션 (200ms) |
| SketchRadio | `onChanged != null` | 내부 점 scale 애니메이션 (200ms) |
| SketchSwitch | `onChanged != null` | 썸 위치 애니메이션 (200ms) |

## 애니메이션

### 비활성화 전환 애니메이션

**현재:**
- 빗금 오버레이 즉시 표시/제거 (애니메이션 없음)

**이유:**
- 비활성화 상태는 정적 상태 (전환 빈도 낮음)
- 성능 최적화 (HatchingPainter 렌더링 비용)

**개선 가능성:**
- 향후 필요 시 Opacity 애니메이션 추가 (100ms, Curves.easeIn)

### 위젯별 기존 애니메이션 (유지)

| 위젯 | 애니메이션 | Duration | Curve |
|------|----------|----------|-------|
| SketchButton | Scale (press) | 100ms | Curves.easeOut |
| SketchCheckbox | 체크 마크 progress | 200ms | Curves.easeInOut |
| SketchRadio | 내부 점 scale | 200ms | Curves.easeOut |
| SketchSwitch | 썸 위치 | 200ms | Curves.easeInOut |

## 반응형 레이아웃

### Breakpoints (해당 없음)

- 비활성화 상태는 위젯 크기에 독립적
- 모든 화면 크기에서 동일한 빗금 패턴 적용

### 빗금 패턴 스케일링

**작은 위젯 (24x24 — 체크박스, 라디오):**
- `spacing`: 6.0 유지 (변경 없음)
- `strokeWidth`: 1.0 유지 (변경 없음)

**큰 위젯 (버튼, 스위치):**
- `spacing`: 6.0 유지 (일관성)
- `strokeWidth`: 1.0 유지 (일관성)

**이유:**
- 6px 간격은 24x24 크기에서도 충분히 가독성 확보
- 고정된 패턴으로 디자인 일관성 유지

### 터치 영역

| 위젯 | 최소 터치 영역 | 비고 |
|------|--------------|------|
| SketchButton | 44x44 (medium) | Material Design 가이드라인 준수 |
| SketchCheckbox | 24x24 | 패딩 추가로 터치 영역 확장 가능 |
| SketchRadio | 24x24 | 패딩 추가로 터치 영역 확장 가능 |
| SketchSwitch | 50x28 | 충분한 터치 영역 (가로 50) |

**비활성화 상태:**
- 터치 영역 유지 (시각적 피드백 없음)
- `onTap: null`로 제스처 차단

## 접근성 (Accessibility)

### 색상 대비

**WCAG AA 준수:**

| 조합 | 대비율 | 기준 | 결과 |
|------|--------|------|------|
| 비활성화 텍스트(#8E8E8E) : 배경(#F7F7F7) | 3.2:1 | 3:1 (large text) | ✅ 통과 |
| 비활성화 테두리(#DCDCDC) : 배경(#FAF8F5) | 1.4:1 | 3:1 (UI components) | ⚠️ 경계선 (Opacity로 보완) |
| 빗금(#8E8E8E) : 배경(#F7F7F7) | 3.2:1 | 3:1 (UI components) | ✅ 통과 |

**색약자 고려:**
- 색상만으로 비활성화 표현 금지
- 이중 시각적 신호:
  1. Opacity 0.5 (명도 차이)
  2. 빗금 패턴 (텍스처 차이)

### 의미 전달 (Multi-modal)

| 채널 | 표현 방식 | 대상 |
|------|----------|------|
| 시각 (색상) | 어두운 회색 배경/테두리 | 일반 사용자 |
| 시각 (명도) | Opacity 0.5 (50% 투명도) | 색약자 |
| 시각 (텍스처) | 대각선 빗금 패턴 | 색각 장애 |
| 터치 | 제스처 차단 (onTap: null) | 모든 사용자 |

### 스크린 리더 지원 (향후 개선)

**현재:**
- Semantics 미구현

**권장사항:**
- 비활성화 상태에 `Semantics(enabled: false)` 추가
- 라벨에 "비활성화됨" 텍스트 추가

```dart
Semantics(
  enabled: false,
  label: '제출 버튼 (비활성화됨)',
  child: SketchButton(...),
)
```

## 엣지 케이스 처리

### 1. SketchButtonStyle.hatching + disabled

**문제:**
- hatching 스타일 버튼이 비활성화되면 이중 빗금 오버레이?

**해결:**

```dart
// _getColorSpec 메서드
_ColorSpec _getColorSpec(...) {
  if (isDisabled) {
    // 비활성화 상태는 스타일 무시, 항상 disabled 색상 + 빗금
    return _ColorSpec(
      fillColor: disabledFillColor,
      borderColor: disabledBorderColor,
      textColor: disabledTextColor,
      enableHatching: true, // 비활성화 빗금만 표시
    );
  }

  switch (style) {
    case SketchButtonStyle.hatching:
      // 활성 상태 hatching은 더 이상 사용 안 함 (모달 수정)
      return _ColorSpec(
        fillColor: Colors.transparent,
        borderColor: textColor,
        textColor: textColor,
        enableHatching: true, // 장식 빗금
      );
    // ...
  }
}
```

**시각적 결과:**
- 활성 hatching: 투명 배경 + textColor 테두리 + textColor 빗금
- 비활성 hatching: disabledFillColor 배경 + disabledBorderColor 테두리 + disabledTextColor 빗금
- 빗금은 1개만 표시 (색상만 다름)

### 2. 아이콘만 있는 버튼

**상황:**
- `text: null`, `icon: Icon(Icons.add)`

**처리:**

```dart
SketchButton(
  icon: Icon(Icons.add),
  onPressed: null, // 비활성화
)

// 빗금 오버레이는 동일하게 적용
// IconTheme 색상: disabledTextColor
```

**시각적 결과:**
- 아이콘 색상: disabledTextColor (#8E8E8E)
- 빗금 패턴: 버튼 전체에 표시 (텍스트 없어도 정상)

### 3. 로딩 상태 버튼

**상황:**
- `isLoading: true`

**처리:**

```dart
final isDisabled = widget.onPressed == null && !widget.isLoading;

if (widget.isLoading) {
  return Center(
    child: CircularProgressIndicator(
      color: colorSpec.textColor, // 비활성화 색상 아님
    ),
  );
}
```

**시각적 결과:**
- `isLoading: true` → 빗금 표시 안 함 (활성 상태 색상 유지)
- `onPressed: null && isLoading: false` → 빗금 표시

### 4. 체크박스 tristate (value: null)

**상황:**
- `value: null`, `tristate: true`, `onChanged: null`

**처리:**

```dart
if (value == null && tristate) {
  // 대시(-) 표시 + 빗금 오버레이
  Center(
    child: Container(
      width: 24 * 0.4,
      height: strokeWidth,
      color: disabledTextColor, // base500
    ),
  )
}
```

**시각적 결과:**
- 대시 색상: disabledTextColor (#8E8E8E)
- 빗금 오버레이: 전체에 표시

### 5. 작은 위젯에서 빗금 가독성 (24x24)

**문제:**
- 체크박스/라디오 24x24 크기에서 빗금이 너무 밀집?

**해결:**
- `spacing: 6.0` 유지 (4~5개 선만 표시)
- `strokeWidth: 1.0` 유지 (얇은 선)
- `roughness: 0.5` (미묘한 스케치 효과)

**시각적 검증:**
- 24x24 영역에 대각선 45도 → 대각선 길이: √(24² + 24²) ≈ 34px
- 선 개수: 34 / 6 ≈ 5~6개 (적절함)

## Design System 컴포넌트 활용

### 기존 컴포넌트 사용

| 컴포넌트 | 역할 | 패키지 |
|----------|------|--------|
| `SketchPainter` | 버튼/카드 테두리 렌더링 | design_system |
| `HatchingPainter` | 대각선 빗금 패턴 렌더링 | design_system |
| `SketchCirclePainter` | 스위치 썸 렌더링 | design_system |
| `SketchThemeExtension` | 테마 색상/거칠기 제공 | design_system |

### 새로운 컴포넌트 필요 여부

**불필요:**
- 모든 기능을 기존 `HatchingPainter`로 구현 가능
- `ClipOval`로 원형 마스킹 처리

**향후 개선 제안 (선택적):**
- `SketchDisabledOverlay` 위젯: 빗금 + Opacity를 한 번에 적용하는 래퍼
  ```dart
  SketchDisabledOverlay(
    isDisabled: true,
    borderRadius: 12.0,
    child: SketchButton(...),
  )
  ```

## 참고 자료

### Material Design 3
- Components: https://m3.material.io/components
- Disabled States: https://m3.material.io/foundations/interaction/states/state-layers

### Flutter Widget Catalog
- CustomPaint: https://api.flutter.dev/flutter/widgets/CustomPaint-class.html
- Opacity: https://api.flutter.dev/flutter/widgets/Opacity-class.html
- ClipOval: https://api.flutter.dev/flutter/widgets/ClipOval-class.html

### Frame0 스타일 참고
- RoughJS (유사 라이브러리): https://roughjs.com/
- Sketchy UI 패턴: Hatching은 CAD/엔지니어링에서 "재질 표현"으로 사용 (비활성화 표현으로 전용)

### 접근성 가이드라인
- WCAG 2.1 AA: https://www.w3.org/WAI/WCAG21/quickref/
- 색각 장애 시뮬레이터: https://www.color-blindness.com/coblis-color-blindness-simulator/

---

**다음 단계:**
- tech-lead가 기술 아키텍처를 설계합니다 (mobile-tech-design.md)
