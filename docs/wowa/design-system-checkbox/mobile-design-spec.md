# UI/UX 디자인 명세: SketchCheckbox 스케치 스타일 적용

## 개요

SketchCheckbox 컴포넌트의 테두리와 체크마크를 `SketchPainter` 기반 손그림(스케치) 스타일로 개선하여, SketchButton 등 다른 Frame0 스타일 컴포넌트와 시각적 일관성을 확보한다. 직선 기반 `Border.all()`과 완벽한 직선 체크마크 대신, 불규칙한 흔들림(roughness)과 미세한 곡선을 적용한 자연스러운 손그림 느낌을 표현한다.

## 디자인 원칙 (에셋 이미지 분석 기반)

### 핵심 특징
- **투명 배경 유지**: checked 상태에서도 배경색을 채우지 않고 투명 유지 (기존 코드와 달리)
- **스케치 테두리**: 완벽한 직선 대신 불규칙한 손그림 선 (SketchPainter 활용)
- **스케치 체크마크**: V 모양에 roughness 기반 jitter와 미세한 곡선 적용
- **다크 모드 반전**: 라이트=검정선, 다크=흰색선 (Frame0 모노크롬 스타일)

### 에셋 이미지 분석 결과
- **Light Mode**: 검은색 테두리 + 체크마크, 흰색 배경, 손글씨 폰트
- **Dark Mode**: 흰색 테두리 + 체크마크, 검은색 배경, 손글씨 폰트
- **공통**: 배경 채우기 없음, 테두리 + 체크마크만 표시

## 화면 구조

### Widget 계층

```
SketchCheckbox (StatefulWidget)
└── Opacity (비활성화 시 opacityDisabled)
    └── GestureDetector (onTap 핸들링)
        └── SizedBox (width: size, height: size)
            └── AnimatedBuilder (체크 애니메이션)
                └── Stack
                    ├── CustomPaint (테두리 — SketchPainter)
                    │   └── painter: SketchPainter(
                    │         fillColor: transparent,
                    │         borderColor: borderColor,
                    │         strokeWidth: strokeWidth,
                    │         roughness: roughness,
                    │         seed: seed,
                    │         showBorder: showBorder,
                    │         borderRadius: 4,
                    │       )
                    │
                    └── [조건부 렌더링]
                        ├── if (value == true)
                        │   └── CustomPaint (체크마크 — _SketchCheckMarkPainter)
                        │       └── painter: _SketchCheckMarkPainter(
                        │             color: checkColor,
                        │             strokeWidth: strokeWidth,
                        │             roughness: roughness,
                        │             seed: seed + 1,
                        │             progress: animation.value,
                        │           )
                        │
                        └── else if (value == null && tristate)
                            └── Center (대시 — 기존 Container 유지)
                                └── Container(
                                      width: size * 0.4,
                                      height: strokeWidth,
                                      color: checkColor,
                                    )
```

## 위젯 상세

### CustomPaint (테두리)

**위치**: Stack의 첫 번째 자식 (배경 레이어)

**Painter**: SketchPainter

**파라미터**:
- `fillColor`: `Colors.transparent` (에셋 이미지처럼 배경 없음)
- `borderColor`: 상태에 따라 변경
  - Unchecked (Light): `sketchTheme.textColor` (base900, 검정)
  - Unchecked (Dark): `sketchTheme.textColor` (textOnDark, 흰색)
  - Checked (Light): `sketchTheme.textColor` (base900, 검정)
  - Checked (Dark): `sketchTheme.textColor` (textOnDark, 흰색)
  - Disabled: `sketchTheme.disabledBorderColor` (base300 또는 outlinePrimaryDark)
- `strokeWidth`: `effectiveStrokeWidth` (기본 2.0, SketchDesignTokens.strokeStandard)
- `roughness`: `effectiveRoughness` (기본 0.8, SketchDesignTokens.roughness)
- `seed`: `widget.seed` (재현 가능한 무작위성)
- `showBorder`: `widget.showBorder` (기본 true)
- `borderRadius`: `4.0` (작은 둥근 모서리)

**변경 전 (기존 코드)**:
```dart
Container(
  decoration: BoxDecoration(
    color: backgroundColor, // 체크 시 activeColor
    border: Border.all(
      color: borderColor,
      width: effectiveStrokeWidth,
    ),
    borderRadius: BorderRadius.circular(4),
  ),
)
```

**변경 후 (스케치 스타일)**:
```dart
CustomPaint(
  painter: SketchPainter(
    fillColor: Colors.transparent, // 에셋: 배경 없음
    borderColor: borderColor, // 라이트=검정, 다크=흰색
    strokeWidth: effectiveStrokeWidth,
    roughness: effectiveRoughness,
    seed: widget.seed,
    showBorder: widget.showBorder,
    borderRadius: 4,
  ),
  child: SizedBox(
    width: widget.size,
    height: widget.size,
  ),
)
```

### CustomPaint (체크마크)

**위치**: Stack의 두 번째 자식 (전경 레이어, 조건부 렌더링)

**Painter**: `_SketchCheckMarkPainter` (개선 필요)

**파라미터**:
- `color`: `effectiveCheckColor` (기본 흰색, 에셋에서는 textColor와 동일)
- `strokeWidth`: `effectiveStrokeWidth`
- `roughness`: `effectiveRoughness` (새로 추가)
- `seed`: `widget.seed + 1` (테두리와 다른 무작위성)
- `progress`: `_checkAnimation.value` (0.0~1.0)

**변경 전 (기존 코드)**:
```dart
// 완벽한 직선 drawLine
canvas.drawLine(p1Start, currentEnd, paint);
canvas.drawLine(p2Start, currentEnd, paint);
```

**변경 후 (스케치 스타일)**:
```dart
// Path + quadraticBezierTo로 roughness 기반 jitter 적용
final path = _createSketchCheckPath(
  p1Start, p1End, p2Start, p2End,
  progress, roughness, seed
);
canvas.drawPath(path, paint);
```

**구현 전략**:
- 각 선분(p1Start→p1End, p2Start→p2End)을 여러 포인트로 샘플링
- 각 포인트에 법선 방향 jitter 추가 (Random(seed), 범위: roughness * 0.3)
- quadraticBezierTo로 부드럽게 연결

### Container (대시, tristate)

**위치**: Stack의 두 번째 자식 (조건부 렌더링, value == null && tristate)

**변경 없음**: 기존 코드 유지 (수평선)

```dart
Center(
  child: Container(
    width: widget.size * 0.4,
    height: effectiveStrokeWidth,
    color: effectiveCheckColor,
  ),
)
```

## 색상 팔레트 (SketchThemeExtension 기반)

### Light Mode

#### Unchecked (미체크)
- **fillColor**: `Colors.transparent` (투명 배경)
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFF343434)`, base900)
- **checkColor**: `sketchTheme.textColor` (체크마크 색상, 표시 안 됨)

#### Checked (체크됨)
- **fillColor**: `Colors.transparent` (에셋: 배경 채우기 없음)
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFF343434)`, base900)
- **checkColor**: `sketchTheme.textColor` (에셋과 일치, 기본값: base900)

#### Tristate (일부 선택)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor`
- **dashColor**: `sketchTheme.textColor` (대시 색상)

#### Disabled (비활성화)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.disabledBorderColor` (기본값: `Color(0xFFDCDCDC)`, base300)
- **checkColor**: `sketchTheme.disabledTextColor` (기본값: `Color(0xFF8E8E8E)`, base500)
- **opacity**: `SketchDesignTokens.opacityDisabled` (0.5)

### Dark Mode

#### Unchecked (미체크)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFFF5F5F5)`, textOnDark)
- **checkColor**: `sketchTheme.textColor` (표시 안 됨)

#### Checked (체크됨)
- **fillColor**: `Colors.transparent` (에셋: 배경 채우기 없음)
- **borderColor**: `sketchTheme.textColor` (기본값: `Color(0xFFF5F5F5)`, textOnDark)
- **checkColor**: `sketchTheme.textColor` (에셋과 일치, 기본값: textOnDark)

#### Tristate (일부 선택)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.textColor`
- **dashColor**: `sketchTheme.textColor`

#### Disabled (비활성화)
- **fillColor**: `Colors.transparent`
- **borderColor**: `sketchTheme.disabledBorderColor` (기본값: `Color(0xFF5E5E5E)`, outlinePrimaryDark)
- **checkColor**: `sketchTheme.disabledTextColor` (기본값: `Color(0xFF6E6E6E)`, textDisabledDark)
- **opacity**: `SketchDesignTokens.opacityDisabled` (0.5)

### 색상 로직 변경 사항

**기존 코드 (변경 전)**:
```dart
final backgroundColor = widget.value == true
    ? effectiveActiveColor          // 체크 시 배경 채움
    : widget.value == null && widget.tristate
        ? effectiveActiveColor
        : Colors.transparent;

final borderColor = widget.value == true ||
        (widget.value == null && widget.tristate)
    ? effectiveActiveColor
    : effectiveInactiveColor;
```

**새로운 로직 (변경 후)**:
```dart
// 에셋 이미지처럼 항상 투명 배경
final fillColor = Colors.transparent;

// 상태와 무관하게 textColor 사용 (라이트=검정, 다크=흰색)
final borderColor = isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (sketchTheme?.textColor ?? SketchDesignTokens.base900);

// 체크마크도 textColor 사용 (에셋과 일치)
final checkColor = isDisabled
    ? (sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500)
    : (sketchTheme?.textColor ?? SketchDesignTokens.base900);
```

## 스케치 파라미터

### Roughness (거칠기)

- **기본값**: `SketchDesignTokens.roughness` (0.8)
- **범위**: 0.0 (부드러움) ~ 1.0+ (거친 손그림)
- **역할**: 테두리와 체크마크의 흔들림 강도 제어
- **SketchPainter**: 샘플링된 포인트에 법선 방향 jitter 적용 (maxJitter = roughness * 0.6)
- **체크마크**: 각 선분 포인트에 jitter 적용 (maxJitter = roughness * 0.3, 테두리보다 약간 작게)

### Stroke Width (선 두께)

- **기본값**: `SketchDesignTokens.strokeStandard` (2.0)
- **용도**: 테두리와 체크마크 선 두께
- **SketchTheme 연동**: `sketchTheme?.strokeWidth`로 테마별 두께 조정 가능

### Seed (무작위 시드)

- **테두리 seed**: `widget.seed` (기본 0)
- **체크마크 seed**: `widget.seed + 1` (테두리와 다른 변형)
- **역할**: 동일한 시드 = 동일한 스케치 모양 (재현 가능성)
- **활용**: 각 체크박스마다 다른 시드 사용 시 각기 다른 손그림 느낌

### Border Radius (모서리 반경)

- **기본값**: `4.0` (작은 둥근 모서리)
- **SketchPainter**: RRect 경로 생성 후 roughness 적용
- **결과**: 둥근 모서리가 약간 불규칙하게 흔들림

## 스페이싱 시스템

### 체크박스 크기
- **기본 크기**: `24.0 x 24.0` (widget.size)
- **변경 가능**: size 파라미터로 조정 가능

### 체크마크 패딩
- **Padding**: `EdgeInsets.all(widget.size * 0.2)` (기존 유지, 크기의 20%)
- **24x24 기준**: 4.8px 패딩 → 체크마크 영역 14.4x14.4

### 체크마크 좌표
- **첫 번째 선 (짧은 선)**:
  - 시작점: `Offset(size.width * 0.2, size.height * 0.5)` (왼쪽 중간)
  - 끝점: `Offset(size.width * 0.4, size.height * 0.7)` (중간 아래)
- **두 번째 선 (긴 선)**:
  - 시작점: 첫 번째 선 끝점 (연결)
  - 끝점: `Offset(size.width * 0.8, size.height * 0.2)` (오른쪽 위)

### Tristate 대시
- **너비**: `widget.size * 0.4` (24x24 기준 9.6px)
- **높이**: `effectiveStrokeWidth` (기본 2.0)
- **위치**: Center (수평/수직 중앙)

## 애니메이션

### 체크 애니메이션

**Duration**: `200ms`

**Curve**: `Curves.easeInOut`

**상태 전환**:
- `false → true`: `_animationController.forward()` (0.0 → 1.0)
- `true → false`: `_animationController.reverse()` (1.0 → 0.0)
- `false → null` (tristate): `_animationController.animateTo(0.5)` (0.0 → 0.5)
- `true → null` (tristate): `_animationController.animateTo(0.5)` (1.0 → 0.5)

**체크마크 그리기 단계**:
- `progress 0.0 ~ 0.5`: 첫 번째 선 그리기 (왼쪽→중간)
- `progress 0.5 ~ 1.0`: 두 번째 선 그리기 (중간→오른쪽)

**Painter 업데이트**: `AnimatedBuilder`로 `_checkAnimation` 리스닝, progress 변화 시 CustomPaint 리빌드

## 인터랙션 상태

### Default (기본)
- **테두리**: borderColor, strokeWidth
- **체크마크**: 상태에 따라 표시/숨김
- **애니메이션**: 상태 변경 시 200ms 전환

### Pressed (터치 중)
- **시각적 피드백 없음** (기존 코드 유지)
- **GestureDetector**: onTap만 처리

### Disabled (비활성화)
- **조건**: `widget.onChanged == null`
- **Opacity**: `SketchDesignTokens.opacityDisabled` (0.5)
- **색상**: disabledBorderColor, disabledTextColor
- **GestureDetector**: onTap 비활성화

### Loading (로딩 중)
- **지원 안 함** (체크박스는 로딩 상태 없음)

## 접근성 (Accessibility)

### 색상 대비

**라이트 모드**:
- **체크마크 대 배경**: base900 (검정) 대 transparent (배경 흰색) = 21:1 (WCAG AAA)
- **테두리 대 배경**: base900 (검정) 대 흰색 배경 = 21:1 (WCAG AAA)

**다크 모드**:
- **체크마크 대 배경**: textOnDark (흰색) 대 transparent (배경 검정) = 21:1 (WCAG AAA)
- **테두리 대 배경**: textOnDark (흰색) 대 어두운 배경 = 21:1 (WCAG AAA)

### 터치 영역
- **최소 크기**: `24x24` (Material 권장 최소 48x48보다 작음, 레이블과 함께 사용 권장)
- **권장 사용법**: Row로 레이블 추가, 터치 영역 확장

```dart
Row(
  children: [
    SketchCheckbox(
      value: agreeToTerms,
      onChanged: (value) {
        setState(() => agreeToTerms = value ?? false);
      },
    ),
    SizedBox(width: 8),
    Text('이용약관에 동의합니다'), // 터치 영역 확장
  ],
)
```

### 의미 전달
- **색상만으로 의미 전달 금지**: 체크마크 + 레이블 병행 사용
- **Tristate**: 대시(-)로 시각적으로 구분

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

**SketchPainter**:
- 테두리 렌더링에 활용
- fillColor=transparent로 배경 없이 테두리만 그리기
- roughness로 손그림 느낌 조절

**SketchThemeExtension**:
- textColor: 테두리 및 체크마크 색상
- disabledBorderColor, disabledTextColor: 비활성화 상태 색상
- strokeWidth, roughness: 스케치 파라미터

### 새로운 컴포넌트 필요 여부

**_SketchCheckMarkPainter (개선)**:
- 기존 CustomPainter를 roughness 기반 스케치 스타일로 개선
- `_createSketchCheckPath()` 헬퍼 메서드 추가
- 재사용 가능성: 낮음 (체크박스 전용)

**재사용 불필요**: 체크마크는 체크박스 전용이므로 design_system에 별도 export 불필요

## 구현 시 주의사항

### 1. 색상 로직 변경

**기존 코드 제거**:
```dart
// 배경색 로직 (체크 시 activeColor로 배경 채움)
final backgroundColor = widget.value == true
    ? effectiveActiveColor
    : widget.value == null && widget.tristate
        ? effectiveActiveColor
        : Colors.transparent;
```

**새로운 로직 추가**:
```dart
// 에셋: 항상 투명 배경, 테두리만 표시
final fillColor = Colors.transparent;
final borderColor = isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (sketchTheme?.textColor ?? SketchDesignTokens.base900);
final checkColor = isDisabled
    ? (sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500)
    : (sketchTheme?.textColor ?? SketchDesignTokens.base900);
```

### 2. Container → CustomPaint 교체

**기존 위젯 구조**:
```dart
Stack(
  children: [
    Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(...),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    // 체크마크
  ],
)
```

**새로운 위젯 구조**:
```dart
Stack(
  children: [
    CustomPaint(
      painter: SketchPainter(
        fillColor: Colors.transparent,
        borderColor: borderColor,
        strokeWidth: effectiveStrokeWidth,
        roughness: effectiveRoughness,
        seed: widget.seed,
        showBorder: widget.showBorder,
        borderRadius: 4,
      ),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
      ),
    ),
    // 체크마크
  ],
)
```

### 3. 체크마크 Painter 개선

**기존 코드 (직선)**:
```dart
canvas.drawLine(p1Start, currentEnd, paint);
```

**새로운 코드 (스케치 스타일)**:
```dart
// 1. 샘플링 (6개 포인트로 분할)
final points = _samplePoints(p1Start, p1End, numPoints: 6);

// 2. Jitter 적용
final random = Random(seed);
final maxJitter = roughness * 0.3;
final jitteredPoints = points.map((p) {
  final jitter = (random.nextDouble() - 0.5) * 2 * maxJitter;
  // 선분 법선 방향으로 jitter 적용
  return p + normalDirection * jitter;
}).toList();

// 3. Path로 부드럽게 연결
final path = Path();
path.moveTo(jitteredPoints.first.dx, jitteredPoints.first.dy);
for (int i = 0; i < jitteredPoints.length - 1; i++) {
  final curr = jitteredPoints[i];
  final next = jitteredPoints[i + 1];
  final midX = (curr.dx + next.dx) / 2;
  final midY = (curr.dy + next.dy) / 2;
  path.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
}

canvas.drawPath(path, paint);
```

### 4. API 호환성 유지

**변경 금지**:
- `value`, `onChanged`, `tristate`, `activeColor`, `inactiveColor`, `checkColor` 파라미터
- `size`, `strokeWidth`, `roughness`, `seed`, `showBorder` 파라미터

**주의**: `activeColor`, `inactiveColor` 파라미터는 deprecated 예정이지만, 기존 API 호환성을 위해 유지하고 내부적으로 무시

### 5. 애니메이션 유지

**변경 없음**: 기존 AnimationController, CurvedAnimation 로직 유지

**Painter progress 전달**: `_SketchCheckMarkPainter`의 progress 파라미터로 애니메이션 진행도 전달

## 참고 자료

- **SketchPainter 구현**: `apps/mobile/packages/design_system/lib/src/painters/sketch_painter.dart`
- **SketchButton 예시**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_button.dart`
- **SketchTheme**: `apps/mobile/packages/design_system/lib/src/theme/sketch_theme_extension.dart`
- **Design Tokens**: `core/lib/src/utils/sketch_design_tokens.dart`
- **에셋 이미지**:
  - Light: `prompt/archives/checkbox-light-mode.png`
  - Dark: `prompt/archives/checkbox-dark-mode.png`
