# 기술 아키텍처 설계: 스케치 디자인 시스템 비활성화 상태 개선

## 개요

스케치 디자인 시스템의 인터랙티브 위젯(Button, Checkbox, Radio, Switch)에 비활성화 상태 시각화를 개선합니다. 기존 opacity 처리에 더해 HatchingPainter를 활용한 대각선 빗금 패턴을 추가하여, 사용자가 비활성화 상태를 명확하게 인지할 수 있도록 합니다. 추가로 모달 다이얼로그의 OK 버튼을 hatching 스타일에서 primary 스타일로 변경하여 주요 액션을 강조합니다.

**핵심 기술 전략:**
- 기존 HatchingPainter 재사용 (새 컴포넌트 불필요)
- 각 위젯의 비활성화 조건에 따라 Stack + Positioned.fill 패턴으로 빗금 오버레이 추가
- SketchButton의 `_ColorSpec.enableHatching` 패턴 확장 (체계적 관리)
- API 변경 없이 내부 렌더링만 수정 (기존 코드 호환성 유지)

## 모듈 구조

### 수정 대상 파일

```
packages/design_system/lib/src/
├── widgets/
│   ├── sketch_button.dart        # enableHatching 조건 추가
│   ├── sketch_checkbox.dart      # 비활성화 시 빗금 오버레이 추가
│   ├── sketch_radio.dart         # 비활성화 시 빗금 오버레이 추가 (ClipOval)
│   └── sketch_switch.dart        # 비활성화 시 빗금 오버레이 추가 (트랙만)
└── painters/
    └── hatching_painter.dart     # 변경 없음 (재사용)

apps/design_system_demo/lib/app/modules/widgets/views/demos/
└── modal_demo.dart                # 라인 80, 190 스타일 변경
```

## 위젯별 기술 설계

### 1. SketchButton 비활성화 빗금

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_button.dart`

#### 현재 구조 분석

```dart
// _getColorSpec 메서드 (라인 296-343)
_ColorSpec _getColorSpec(..., bool isDisabled) {
  if (isDisabled) {
    return _ColorSpec(
      fillColor: theme?.disabledFillColor ?? SketchDesignTokens.base200,
      borderColor: theme?.disabledBorderColor ?? SketchDesignTokens.base300,
      textColor: theme?.disabledTextColor ?? SketchDesignTokens.base500,
      strokeWidth: SketchDesignTokens.strokeStandard,
      // enableHatching: false (기본값)
    );
  }
  // ... 스타일별 분기
}

// build 메서드 (라인 182-195)
if (colorSpec.enableHatching)
  Positioned.fill(
    child: CustomPaint(
      painter: HatchingPainter(
        fillColor: colorSpec.textColor,
        // ...
      ),
    ),
  ),
```

#### 수정 전략

**1. `_ColorSpec` 비활성화 케이스 수정 (라인 298-303)**

```dart
if (isDisabled) {
  return _ColorSpec(
    fillColor: theme?.disabledFillColor ?? SketchDesignTokens.base200,
    borderColor: theme?.disabledBorderColor ?? SketchDesignTokens.base300,
    textColor: theme?.disabledTextColor ?? SketchDesignTokens.base500,
    strokeWidth: SketchDesignTokens.strokeStandard,
    enableHatching: true, // ✅ 추가
  );
}
```

**2. SketchButtonStyle.hatching + disabled 엣지 케이스 처리**

- 현재: `enableHatching`은 스타일별로만 설정됨
- 수정 후: 비활성화 상태는 스타일 무시, 항상 disabled 색상 + 빗금 표시
- 결과: 활성 hatching과 비활성 hatching은 색상만 다름 (패턴 동일)

**설계 근거:**
- 비활성화 상태는 "상태"가 "스타일"보다 우선
- hatching 패턴이 "비활성화"를 의미하도록 일관성 확립
- 기존 `enableHatching` 인프라 재사용 (새 플래그 불필요)

### 2. SketchCheckbox 비활성화 빗금

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_checkbox.dart`

#### 현재 구조 분석

```dart
// build 메서드 (라인 185-263)
return Opacity(
  opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
  child: GestureDetector(
    onTap: isDisabled ? null : _handleTap,
    child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _checkAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // 1. 테두리 (SketchPainter)
              CustomPaint(painter: SketchPainter(...)),

              // 2. 체크 마크 또는 대시
              if (widget.value == true) ...,
              else if (widget.value == null && widget.tristate) ...,
            ],
          );
        },
      ),
    ),
  ),
);
```

#### 수정 전략

**Stack children 수정 (라인 212-256 사이)**

```dart
return Stack(
  children: [
    // 1. 테두리 (SketchPainter) — 기존
    CustomPaint(
      painter: SketchPainter(
        fillColor: Colors.transparent,
        borderColor: borderColor,
        strokeWidth: effectiveStrokeWidth,
        roughness: effectiveRoughness,
        seed: widget.seed,
        showBorder: widget.showBorder,
        borderRadius: 4,
        enableNoise: false,
      ),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
      ),
    ),

    // 2. 빗금 오버레이 (비활성화 시만) — ✅ 추가
    if (isDisabled)
      Positioned.fill(
        child: CustomPaint(
          painter: HatchingPainter(
            fillColor: checkColor, // disabledTextColor
            strokeWidth: 1.0,
            angle: pi / 4,
            spacing: 6.0,
            roughness: 0.5,
            seed: widget.seed + 500, // 다른 시드
            borderRadius: 4.0, // 체크박스 테두리와 일치
          ),
        ),
      ),

    // 3. 체크 마크 또는 대시 — 기존
    if (widget.value == true) ...,
    else if (widget.value == null && widget.tristate) ...,
  ],
);
```

**변수 위치:**
- `isDisabled`: 이미 라인 187에 정의됨
- `checkColor`: 이미 라인 197-199에 정의됨 (비활성화 시 disabledTextColor)

**설계 근거:**
- HatchingPainter는 RRect 클립 내장 → borderRadius: 4.0으로 사각형 클립
- 빗금은 체크 마크 아래 렌더링 (Stack 순서)
- 24x24 크기에서 spacing: 6.0 → 약 5개 선 (적절)

### 3. SketchRadio 비활성화 빗금

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_radio.dart`

#### 현재 구조 분석

```dart
// build 메서드 (라인 166-224)
return Opacity(
  opacity: _isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
  child: GestureDetector(
    onTap: _isDisabled ? null : _handleTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _SketchRadioPainter(
                  borderColor: effectiveBorderColor,
                  dotColor: effectiveDotColor,
                  strokeWidth: SketchDesignTokens.strokeStandard,
                  innerDotScale: _scaleAnimation.value,
                  roughness: sketchTheme?.roughness ?? SketchDesignTokens.roughness,
                  seed: widget.value.hashCode,
                ),
              );
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 8),
          Text(widget.label!, ...),
        ],
      ],
    ),
  ),
);
```

#### 수정 전략

**AnimatedBuilder builder 내부 수정 (라인 189-201)**

```dart
builder: (context, child) {
  return Stack(
    children: [
      // 1. 원형 테두리 + 내부 점 (_SketchRadioPainter) — 기존
      CustomPaint(
        painter: _SketchRadioPainter(
          borderColor: effectiveBorderColor,
          dotColor: effectiveDotColor,
          strokeWidth: SketchDesignTokens.strokeStandard,
          innerDotScale: _scaleAnimation.value,
          roughness: sketchTheme?.roughness ?? SketchDesignTokens.roughness,
          seed: widget.value.hashCode,
        ),
      ),

      // 2. 원형 빗금 오버레이 (비활성화 시만) — ✅ 추가
      if (_isDisabled)
        ClipOval(
          child: CustomPaint(
            painter: HatchingPainter(
              fillColor: effectiveDotColor, // disabledTextColor
              strokeWidth: 1.0,
              angle: pi / 4,
              spacing: 6.0,
              roughness: 0.5,
              seed: widget.value.hashCode + 500,
              borderRadius: 9999, // 원형 (HatchingPainter는 RRect 클립)
            ),
          ),
        ),
    ],
  );
},
```

**변수 추가:**
- `_isDisabled`: 이미 라인 158에 정의됨 (`widget.onChanged == null`)
- `effectiveDotColor`: 이미 라인 175에 정의됨 (비활성화 시 disabledTextColor 아님)

**비활성화 색상 수정 필요 (라인 169-175):**

```dart
// 현재
final effectiveBorderColor = _isSelected
    ? (widget.activeColor ?? textColor)
    : (widget.inactiveColor ?? textColor);
final effectiveDotColor = widget.activeColor ?? textColor;

// 수정 후
final effectiveBorderColor = _isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (_isSelected
        ? (widget.activeColor ?? textColor)
        : (widget.inactiveColor ?? textColor));
final effectiveDotColor = _isDisabled
    ? (sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500)
    : (widget.activeColor ?? textColor);
```

**설계 근거:**
- ClipOval로 원형 마스킹 (HatchingPainter는 RRect 클립이지만 borderRadius: 9999로 원형 근사)
- 빗금은 내부 점 위에 렌더링 (비활성화 시각화 강조)
- 24x24 원형에서 대각선 길이 약 34px → spacing 6.0으로 5~6개 선

### 4. SketchSwitch 비활성화 빗금

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_switch.dart`

#### 현재 구조 분석

```dart
// build 메서드 (라인 182-268)
return Opacity(
  opacity: isDisabled ? SketchDesignTokens.opacityDisabled : 1.0,
  child: GestureDetector(
    onTap: isDisabled ? null : _handleTap,
    child: SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _positionAnimation,
        builder: (context, child) {
          final trackColor = Color.lerp(...);
          final thumbPosition = ...;

          return Stack(
            children: [
              // 1. 트랙 배경 (SketchPainter)
              CustomPaint(painter: SketchPainter(...)),

              // 2. 트랙 2차 테두리
              CustomPaint(painter: SketchPainter(...)),

              // 3. 썸 (SketchCirclePainter)
              Positioned(left: thumbPosition, ...),
            ],
          );
        },
      ),
    ),
  ),
);
```

#### 수정 전략

**AnimatedBuilder builder 내부 Stack 수정 (라인 204-261)**

```dart
return Stack(
  children: [
    // 1. 트랙 배경 (SketchPainter) — 기존
    CustomPaint(
      painter: SketchPainter(
        fillColor: trackColor,
        borderColor: trackColor,
        strokeWidth: switchStrokeWidth,
        roughness: switchRoughness,
        seed: widget.seed,
        enableNoise: true,
        showBorder: true,
        borderRadius: 9999,
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
      ),
    ),

    // 2. 트랙 2차 테두리 — 기존
    CustomPaint(painter: SketchPainter(...)),

    // 3. 트랙 빗금 오버레이 (비활성화 시만) — ✅ 추가
    if (isDisabled)
      Positioned.fill(
        child: CustomPaint(
          painter: HatchingPainter(
            fillColor: effectiveInactiveColor, // disabledTextColor
            strokeWidth: 1.0,
            angle: pi / 4,
            spacing: 6.0,
            roughness: 0.5,
            seed: widget.seed + 500,
            borderRadius: 9999, // pill shape
          ),
        ),
      ),

    // 4. 썸 (SketchCirclePainter) — 기존 (빗금 없음)
    Positioned(
      left: thumbPosition,
      top: thumbPadding,
      child: CustomPaint(
        painter: SketchCirclePainter(...),
        child: SizedBox(
          width: thumbSize,
          height: thumbSize,
        ),
      ),
    ),
  ],
);
```

**비활성화 색상 수정 필요 (라인 160-172):**

```dart
// 현재
final effectiveActiveColor = widget.activeColor ??
    sketchTheme?.textColor ??
    SketchDesignTokens.base900;
final effectiveInactiveColor = widget.inactiveColor ??
    sketchTheme?.disabledBorderColor ??
    SketchDesignTokens.base300;

// 수정 후 (트랙 색상 로직 추가)
final effectiveActiveColor = isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (widget.activeColor ?? sketchTheme?.textColor ?? SketchDesignTokens.base900);
final effectiveInactiveColor = isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (widget.inactiveColor ?? sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300);
final effectiveThumbColor = isDisabled
    ? (sketchTheme?.disabledFillColor ?? SketchDesignTokens.base200)
    : (widget.thumbColor ?? sketchTheme?.fillColor ?? Colors.white);

// 빗금 색상
final hatchingColor = sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500;
```

**설계 근거:**
- 트랙(pill shape)에만 빗금 표시, 썸은 빗금 없음
- 썸이 빗금 위에 렌더링되어 항상 보임
- pill shape는 borderRadius: 9999로 HatchingPainter의 RRect 클립으로 처리 가능

### 5. 모달 OK 버튼 스타일 변경

**파일**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/modal_demo.dart`

#### 수정 사항

**라인 80 수정:**

```dart
// 기존
SketchButton(
  text: 'OK',
  style: SketchButtonStyle.hatching,
  size: SketchButtonSize.small,
  onPressed: () => Navigator.of(context).pop(),
),

// 수정 후
SketchButton(
  text: 'OK',
  style: SketchButtonStyle.primary, // ✅ 변경
  size: SketchButtonSize.small,
  onPressed: () => Navigator.of(context).pop(),
),
```

**라인 190 수정 (동일):**

```dart
// 기존
SketchButton(
  text: 'OK',
  style: SketchButtonStyle.hatching,
  size: SketchButtonSize.small,
  onPressed: () => Navigator.of(context).pop(),
),

// 수정 후
SketchButton(
  text: 'OK',
  style: SketchButtonStyle.primary, // ✅ 변경
  size: SketchButtonSize.small,
  onPressed: () => Navigator.of(context).pop(),
),
```

**설계 근거:**
- hatching 스타일은 이제 "비활성화 상태"를 의미
- 모달 주요 액션(OK/확인)은 primary 스타일로 시각적 우선순위 부여
- Cancel(outline) vs OK(primary) → 명확한 계층 구조

## HatchingPainter 재사용 전략

### 기존 구현 분석

**파일**: `apps/mobile/packages/design_system/lib/src/painters/hatching_painter.dart`

```dart
class HatchingPainter extends CustomPainter {
  final Color fillColor;
  final double strokeWidth;   // 기본값: 1.0
  final double angle;          // 기본값: π/4 (45도)
  final double spacing;        // 기본값: 6.0
  final double roughness;      // 기본값: 0.5
  final int seed;
  final double borderRadius;   // 기본값: 12.0

  @override
  void paint(Canvas canvas, Size size) {
    // 1. RRect 클립 (borderRadius)
    final buttonPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
    canvas.clipPath(buttonPath);

    // 2. 대각선 빗금 선 생성
    // 3. 각 선에 스케치 효과 적용
  }
}
```

### 위젯별 재사용 파라미터

| 위젯 | fillColor | borderRadius | 클립 방법 | 비고 |
|------|----------|--------------|----------|------|
| SketchButton | disabledTextColor | 12.0 | HatchingPainter 내장 RRect | 기본 |
| SketchCheckbox | disabledTextColor | 4.0 | HatchingPainter 내장 RRect | 사각형 |
| SketchRadio | disabledTextColor | 9999 | ClipOval 래핑 | 원형 마스킹 |
| SketchSwitch | disabledTextColor | 9999 | HatchingPainter 내장 RRect | pill shape |

**공통 파라미터:**
- `strokeWidth`: 1.0 (고정)
- `angle`: π/4 (45도, 고정)
- `spacing`: 6.0 (고정)
- `roughness`: 0.5 (고정, 버튼보다 미묘함)

**테마 연동:**
- `fillColor`: `SketchThemeExtension.disabledTextColor` (Light: base500, Dark: textDisabledDark)
- 테마 미설정 시 fallback: `SketchDesignTokens.base500` (Light), `SketchDesignTokens.textDisabledDark` (Dark)

## 색상 전략 (Light/Dark 모드)

### 비활성화 색상 토큰

**SketchThemeExtension** (이미 구현됨):

```dart
class SketchThemeExtension extends ThemeExtension<SketchThemeExtension> {
  final Color fillColor;
  final Color textColor;
  final Color disabledFillColor;      // Light: base200, Dark: surfaceVariantDark
  final Color disabledBorderColor;    // Light: base300, Dark: outlinePrimaryDark
  final Color disabledTextColor;      // Light: base500, Dark: textDisabledDark
  // ...
}
```

### 위젯별 색상 매핑

| 위젯 | 배경 | 테두리 | 빗금/텍스트 |
|------|------|--------|------------|
| SketchButton | disabledFillColor | disabledBorderColor | disabledTextColor |
| SketchCheckbox | transparent | disabledBorderColor | disabledTextColor |
| SketchRadio | transparent | disabledBorderColor | disabledTextColor |
| SketchSwitch 트랙 | disabledBorderColor | disabledBorderColor | disabledTextColor (빗금) |
| SketchSwitch 썸 | disabledFillColor | disabledFillColor | - |

## 성능 최적화 전략

### const 생성자

- HatchingPainter는 `const` 불가 (seed가 동적)
- CustomPaint 외부 위젯은 const 유지

### Obx 범위

- 해당 없음 (design_system 패키지는 stateless/stateful widget)

### 불필요한 rebuild 방지

- AnimatedBuilder 내부에서만 Stack 재생성
- HatchingPainter는 shouldRepaint로 불필요한 재렌더링 방지 (이미 구현됨)

### HatchingPainter 렌더링 비용

- 24x24 체크박스: 약 5개 선 × 4px 샘플링 = ~25 포인트 (경량)
- 50x28 스위치: 약 8개 선 × 4px 샘플링 = ~40 포인트 (경량)
- 버튼: 크기에 비례하지만 SketchPainter와 동일한 알고리즘 → 성능 이슈 없음

## 에러 처리 전략

### Fallback 색상

- 테마 미설정 시: SketchDesignTokens 상수 사용
- 예: `sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500`

### HatchingPainter 렌더링 실패

- roughness가 매우 작거나 크기가 0일 때: 직선 폴백 (이미 구현됨, 라인 114-118)
- borderRadius가 size보다 클 때: `min()` 함수로 클램핑 (이미 구현됨, 라인 67)

### 엣지 케이스

**1. SketchButtonStyle.hatching + disabled:**
- 비활성화 상태는 스타일 무시
- `_getColorSpec`에서 `isDisabled`가 우선순위 최상위

**2. 아이콘만 있는 버튼:**
- 텍스트 없어도 빗금 패턴 정상 표시 (Positioned.fill)

**3. 로딩 상태 버튼:**
- `isDisabled = widget.onPressed == null && !widget.isLoading`
- `isLoading: true`일 때는 빗금 표시 안 함

**4. 체크박스 tristate (value: null):**
- 대시(-) 표시 + 빗금 오버레이 동시 표시

**5. 작은 위젯 (24x24):**
- spacing: 6.0 유지 (5개 선 → 적절)
- strokeWidth: 1.0 유지 (얇은 선)

## Design System 컴포넌트 활용

### 기존 컴포넌트 재사용

| 컴포넌트 | 역할 | 변경 사항 |
|----------|------|----------|
| `HatchingPainter` | 대각선 빗금 패턴 렌더링 | 변경 없음 (재사용) |
| `SketchPainter` | 위젯 테두리/배경 렌더링 | 변경 없음 |
| `SketchCirclePainter` | 스위치 썸 렌더링 | 변경 없음 |
| `SketchThemeExtension` | 테마 색상 제공 | 변경 없음 (disabledTextColor 이미 존재) |
| `SketchDesignTokens` | 디자인 토큰 상수 | 변경 없음 |

### 새로운 컴포넌트 필요 여부

**불필요:**
- 모든 기능을 기존 HatchingPainter + Stack 패턴으로 구현 가능

**향후 개선 제안 (선택적):**
- `SketchDisabledOverlay` 위젯: 빗금 + Opacity를 한 번에 적용하는 래퍼
  ```dart
  SketchDisabledOverlay(
    isDisabled: true,
    borderRadius: 12.0,
    child: SketchButton(...),
  )
  ```
- 현재는 각 위젯 내부에서 조건부 렌더링으로 충분

## 패키지 의존성 확인

### 현재 의존성

```yaml
# packages/design_system/pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../core

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 추가 의존성 필요 여부

**불필요:**
- HatchingPainter는 이미 구현됨
- `dart:math` (pi 상수): 이미 import됨
- 모든 필요한 토큰은 core 패키지에 존재

## 작업 분배 계획

### Senior Developer 작업

**Phase 1: 위젯 내부 수정**

1. **SketchButton 수정** (`sketch_button.dart`)
   - 라인 298-303: `_ColorSpec` 비활성화 케이스에 `enableHatching: true` 추가
   - 검증: hatching 스타일 + disabled 엣지 케이스 확인

2. **SketchCheckbox 수정** (`sketch_checkbox.dart`)
   - 라인 212-256: Stack children에 빗금 오버레이 추가
   - `if (isDisabled)` 조건부 렌더링

3. **SketchRadio 수정** (`sketch_radio.dart`)
   - 라인 169-175: 비활성화 색상 로직 추가
   - 라인 189-201: AnimatedBuilder builder 내부에 ClipOval + 빗금 오버레이 추가

4. **SketchSwitch 수정** (`sketch_switch.dart`)
   - 라인 160-172: 비활성화 색상 로직 추가
   - 라인 204-261: AnimatedBuilder builder 내부에 빗금 오버레이 추가 (트랙만)

**Phase 2: 데모 앱 수정**

5. **modal_demo.dart 수정**
   - 라인 80: `SketchButtonStyle.hatching` → `SketchButtonStyle.primary`
   - 라인 190: `SketchButtonStyle.hatching` → `SketchButtonStyle.primary`

### Junior Developer 작업

**없음** (모든 작업이 위젯 내부 로직 수정)

### 작업 의존성

- Phase 1과 Phase 2는 독립적 (동시 진행 가능)
- 각 위젯 수정은 독립적 (병렬 작업 가능)

## 검증 기준

- [ ] **SketchButton 비활성화 시 빗금 표시**
  - `onPressed: null` 일 때 대각선 빗금 오버레이
  - `isLoading: true`일 때는 빗금 표시 안 함

- [ ] **SketchCheckbox 비활성화 시 빗금 표시**
  - `onChanged: null` 일 때 대각선 빗금 오버레이
  - tristate null 값도 빗금 표시

- [ ] **SketchRadio 비활성화 시 빗금 표시**
  - `onChanged: null` 일 때 원형 빗금 오버레이
  - ClipOval로 원형 마스킹 정상 작동

- [ ] **SketchSwitch 비활성화 시 빗금 표시**
  - `onChanged: null` 일 때 트랙에만 빗금 오버레이
  - 썸은 빗금 없이 정상 표시

- [ ] **모달 OK 버튼 스타일 변경**
  - modal_demo.dart 라인 80, 190에서 primary 스타일 적용
  - 검은 배경 + 흰 텍스트로 표시 (Light 모드)

- [ ] **Light/Dark 모드 색상 정상 작동**
  - Light: base500 빗금
  - Dark: textDisabledDark 빗금

- [ ] **기존 API 호환성**
  - 모든 위젯의 public API 변경 없음
  - 기존 코드가 수정 없이 작동

- [ ] **성능**
  - HatchingPainter 렌더링 비용이 SketchPainter 수준
  - 작은 위젯(24x24)에서도 60fps 유지

## 테스트 정책

**CLAUDE.md 정책 준수: 테스트 코드 작성 금지**

검증은 다음 방법으로 진행:
1. 데모 앱 실행 (design_system_demo)
2. 각 위젯 데모에서 비활성화 상태 시각적 확인
3. Light/Dark 모드 전환 확인
4. Hot reload 후 정상 작동 확인

## 다음 단계

1. **Senior Developer**: 위 설계에 따라 5개 파일 수정
2. **검증**: 데모 앱 실행 후 시각적 확인
3. **피드백**: 필요 시 색상/spacing 미세 조정
4. **완료**: 커밋 및 PR

---

**설계 완료일**: 2026-02-13
**작성자**: Tech Lead (Claude)
**검토자**: CTO (검토 대기)
