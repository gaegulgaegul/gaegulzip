# 작업 분배 계획: 스케치 디자인 시스템 비활성화 상태 개선

## 작업 개요

**기능**: design-system-disabled
**플랫폼**: Mobile (Flutter)
**작업 유형**: 위젯 내부 렌더링 수정 (API 변경 없음)
**예상 소요 시간**: 1-2시간

**핵심 전략**:
- 기존 HatchingPainter 재사용 (새 컴포넌트 불필요)
- Stack + Positioned.fill 패턴으로 빗금 오버레이 추가
- 5개 파일 독립적 수정 (파일 충돌 없음)

## 실행 그룹

### Group 1 (순차) — 단일 Flutter Developer

| Agent | 파일 | 수정 라인 | 설명 |
|-------|------|-----------|------|
| flutter-developer | `sketch_button.dart` | 303 | `enableHatching: true` 1줄 추가 |
| flutter-developer | `sketch_checkbox.dart` | 231-256 | `if (isDisabled)` 빗금 오버레이 추가 |
| flutter-developer | `sketch_radio.dart` | 169-201 | 비활성화 색상 로직 + ClipOval 빗금 추가 |
| flutter-developer | `sketch_switch.dart` | 160-261 | 비활성화 색상 로직 + 트랙 빗금 추가 |
| flutter-developer | `modal_demo.dart` | 80, 190 | `hatching` → `primary` (2곳) |

**작업 순서**: 위에서 아래로 순차 진행 (병렬 불필요)

**순차 작업 근거**:
1. **작업 규모 소형**: 각 파일당 1-10줄 수정
2. **컨텍스트 공유**: 동일한 HatchingPainter 패턴 반복 적용
3. **효율성**: 단일 개발자 순차 작업이 병렬보다 빠름 (1-2시간 내 완료)
4. **파일 독립성**: 충돌 가능성 제로

## 작업 상세

### 1. SketchButton 수정

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_button.dart`

**수정 위치**: 라인 303

**변경 내용**:
```dart
// 기존 (라인 297-303)
if (isDisabled) {
  return _ColorSpec(
    fillColor: theme?.disabledFillColor ?? SketchDesignTokens.base200,
    borderColor: theme?.disabledBorderColor ?? SketchDesignTokens.base300,
    textColor: theme?.disabledTextColor ?? SketchDesignTokens.base500,
    strokeWidth: SketchDesignTokens.strokeStandard,
  );
}

// 수정 후
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

**검증 기준**:
- `onPressed: null` 일 때 대각선 빗금 표시
- `isLoading: true`일 때는 빗금 표시 안 함

---

### 2. SketchCheckbox 수정

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_checkbox.dart`

**수정 위치**: 라인 231-256 (Stack children)

**변경 내용**:
```dart
// Stack children 수정 (라인 211-256)
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
            seed: widget.seed + 500,
            borderRadius: 4.0,
          ),
        ),
      ),

    // 3. 체크 마크 또는 대시 — 기존
    if (widget.value == true)
      Padding(...),
    else if (widget.value == null && widget.tristate)
      Center(...),
  ],
);
```

**필요한 import**:
```dart
import 'dart:math'; // pi 상수
import '../painters/hatching_painter.dart';
```

**검증 기준**:
- `onChanged: null` 일 때 대각선 빗금 표시
- tristate null 값도 빗금 표시
- 24x24 크기에서 약 5개 빗금 선 표시

---

### 3. SketchRadio 수정

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_radio.dart`

**수정 위치 1**: 라인 169-175 (비활성화 색상 로직)

**변경 내용**:
```dart
// 현재 (라인 169-175)
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

**수정 위치 2**: 라인 189-201 (AnimatedBuilder builder)

**변경 내용**:
```dart
// AnimatedBuilder builder 내부 수정
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
              borderRadius: 9999, // 원형
            ),
          ),
        ),
    ],
  );
},
```

**필요한 import**:
```dart
import 'dart:math'; // pi 상수
import '../painters/hatching_painter.dart';
```

**검증 기준**:
- `onChanged: null` 일 때 원형 빗금 표시
- ClipOval로 원형 마스킹 정상 작동
- 선택/비선택 상태 모두 빗금 표시

---

### 4. SketchSwitch 수정

**파일**: `apps/mobile/packages/design_system/lib/src/widgets/sketch_switch.dart`

**수정 위치 1**: 라인 160-172 (비활성화 색상 로직)

**변경 내용**:
```dart
// 현재 (라인 160-172)
final effectiveActiveColor = widget.activeColor ??
    sketchTheme?.textColor ??
    SketchDesignTokens.base900;
final effectiveInactiveColor = widget.inactiveColor ??
    sketchTheme?.disabledBorderColor ??
    SketchDesignTokens.base300;

// 수정 후
final effectiveActiveColor = isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (widget.activeColor ?? sketchTheme?.textColor ?? SketchDesignTokens.base900);
final effectiveInactiveColor = isDisabled
    ? (sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300)
    : (widget.inactiveColor ?? sketchTheme?.disabledBorderColor ?? SketchDesignTokens.base300);
final effectiveThumbColor = isDisabled
    ? (sketchTheme?.disabledFillColor ?? SketchDesignTokens.base200)
    : (widget.thumbColor ?? sketchTheme?.fillColor ?? Colors.white);
final hatchingColor = sketchTheme?.disabledTextColor ?? SketchDesignTokens.base500;
```

**수정 위치 2**: 라인 204-261 (AnimatedBuilder builder, Stack)

**변경 내용**:
```dart
// Stack children 수정
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
    CustomPaint(
      painter: SketchPainter(...),
      child: SizedBox(...),
    ),

    // 3. 트랙 빗금 오버레이 (비활성화 시만) — ✅ 추가
    if (isDisabled)
      Positioned.fill(
        child: CustomPaint(
          painter: HatchingPainter(
            fillColor: hatchingColor, // disabledTextColor
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

**필요한 import**:
```dart
import 'dart:math'; // pi 상수
import '../painters/hatching_painter.dart';
```

**검증 기준**:
- `onChanged: null` 일 때 트랙에만 빗금 표시
- 썸은 빗금 없이 정상 표시
- ON/OFF 상태 모두 빗금 표시 (비활성화 시)

---

### 5. modal_demo.dart 수정

**파일**: `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/modal_demo.dart`

**수정 위치 1**: 라인 80

**변경 내용**:
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

**수정 위치 2**: 라인 190 (동일한 변경)

**검증 기준**:
- OK 버튼이 검은 배경 + 흰 텍스트로 표시 (Light 모드)
- 모달 데모에서 시각적으로 확인 가능

---

## 작업 흐름

```
flutter-developer 작업 시작
  ↓
1. sketch_button.dart 수정 (1줄)
  ↓
2. sketch_checkbox.dart 수정 (빗금 오버레이)
  ↓
3. sketch_radio.dart 수정 (색상 로직 + ClipOval 빗금)
  ↓
4. sketch_switch.dart 수정 (색상 로직 + 트랙 빗금)
  ↓
5. modal_demo.dart 수정 (스타일 변경 2곳)
  ↓
검증 (데모 앱 실행)
  ↓
완료
```

**총 소요 시간**: 1-2시간

## 검증 절차

### 1. 앱 실행

```bash
cd apps/design_system_demo
flutter run
```

### 2. 위젯별 시각적 확인

| 위젯 | 확인 항목 |
|------|----------|
| SketchButton | Button Demo에서 `onPressed: null` 버튼 빗금 확인 |
| SketchCheckbox | Checkbox Demo에서 `onChanged: null` 체크박스 빗금 확인 |
| SketchRadio | Radio Demo에서 `onChanged: null` 라디오 빗금 확인 |
| SketchSwitch | Switch Demo에서 `onChanged: null` 스위치 트랙 빗금 확인 |
| Modal | Modal Demo에서 OK 버튼 primary 스타일 확인 |

### 3. Light/Dark 모드 전환

- 데모 앱에서 테마 전환 버튼 클릭
- Light 모드: base500 (#8E8E8E) 빗금
- Dark 모드: textDisabledDark (#6E6E8E) 빗금

### 4. 엣지 케이스 확인

- [ ] `SketchButtonStyle.hatching + disabled`: 비활성화 빗금만 표시 (색상만 다름)
- [ ] `isLoading: true`: 빗금 표시 안 함
- [ ] 체크박스 tristate null: 대시 + 빗금 동시 표시
- [ ] 작은 위젯 (24x24): 빗금 가독성 확인

## 설계 문서 참조

| 문서 | 경로 |
|------|------|
| 사용자 스토리 | `docs/wowa/design-system-disabled/user-story.md` |
| 디자인 명세 | `docs/wowa/design-system-disabled/mobile-design-spec.md` |
| 기술 설계 | `docs/wowa/design-system-disabled/mobile-brief.md` |

## 중요 원칙

1. **API 변경 금지**: 기존 위젯 파라미터 변경 없음
2. **HatchingPainter 재사용**: 새 컴포넌트 생성 금지
3. **성능 유지**: HatchingPainter 렌더링 비용 ≤ SketchPainter
4. **테마 연동**: SketchThemeExtension의 disabledTextColor 사용
5. **테스트 코드 작성 금지**: 데모 앱으로 시각적 검증만 수행

## 다음 단계

- **flutter-developer**: 위 작업 순서대로 5개 파일 수정
- **검증**: 데모 앱 실행 후 시각적 확인
- **완료**: CTO 통합 리뷰 요청

---

**작성일**: 2026-02-13
**작성자**: CTO (Claude)
**승인 상태**: ✅ 설계 승인 완료 (작업 시작 가능)
