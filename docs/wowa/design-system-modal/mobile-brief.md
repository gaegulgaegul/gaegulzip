# Mobile Brief: SketchModal 스케치 스타일 리디자인

## 1. 개요

SketchModal을 `BoxDecoration` 기반에서 `CustomPaint` + `SketchPainter` 기반으로 전환한다.
`SketchButton`이 이미 동일한 패턴을 사용하고 있으므로 이를 참조 구현으로 활용한다.

## 2. 수정 파일

| 파일 | 변경 내용 | 우선순위 |
|------|----------|---------|
| `sketch_modal.dart` | 핵심 컴포넌트 리디자인 | P0 |
| `modal_demo.dart` | 데모 앱 업데이트 | P1 |

**신규 파일: 없음** (기존 `SketchPainter`, `SketchLinePainter` 재사용)

## 3. 구현 상세

### 3.1 _SketchModalDialog.build() 변경

**Before** (현재):
```dart
Container(
  decoration: BoxDecoration(
    color: effectiveFillColor,
    border: showBorder ? Border.all(...) : null,
    borderRadius: BorderRadius.circular(8),
  ),
  child: content,
)
```

**After** (변경 후):
```dart
Stack(
  children: [
    // 1. 그림자 레이어
    Positioned(
      left: shadowOffset.dx,
      top: shadowOffset.dy,
      child: CustomPaint(
        painter: SketchPainter(
          fillColor: shadowColor,
          borderColor: Colors.transparent,
          showBorder: false,
          seed: seed,
          roughness: roughness,
          borderRadius: SketchDesignTokens.irregularBorderRadius,
        ),
        child: SizedBox(width: modalWidth, height: modalHeight),
      ),
    ),
    // 2. 본체 레이어
    CustomPaint(
      painter: SketchPainter(
        fillColor: effectiveFillColor,
        borderColor: effectiveBorderColor,
        strokeWidth: effectiveStrokeWidth,
        showBorder: showBorder,
        seed: seed,
        roughness: roughness,
        enableNoise: true,
        borderRadius: SketchDesignTokens.irregularBorderRadius,
      ),
      child: SizedBox(
        width: modalWidth,
        child: Padding(
          padding: EdgeInsets.all(spacingLg),
          child: content,
        ),
      ),
    ),
  ],
)
```

**핵심 변경점:**
- `BoxDecoration` → `CustomPaint` + `SketchPainter`
- `Border.all()` → `SketchPainter.showBorder` (불규칙 손그림 테두리)
- 노이즈 텍스처 자동 활성화
- 그림자: 별도 `SketchPainter` 레이어로 오프셋 그림자 구현

### 3.2 그림자 크기 문제 해결

`CustomPaint`는 child 크기에 의존하므로, 그림자 레이어는 본체와 동일한 크기를 가져야 한다.
이를 위해 Modal 전체를 계산된 크기로 감싸는 대신, 더 간단한 접근법을 사용:

```dart
// Container로 크기를 정하고, 외부 여백으로 그림자 공간 확보
Padding(
  padding: EdgeInsets.only(
    right: shadowOffset.dx,
    bottom: shadowOffset.dy,
  ),
  child: CustomPaint(
    painter: SketchModalPainterWithShadow(...),
    child: content,
  ),
)
```

또는 **단일 CustomPainter에서 그림자까지 처리**하는 접근:

```dart
// SketchPainter의 paint() 메서드에서:
// 1. 그림자용 경로를 오프셋하여 먼저 그림
// 2. 본체 경로를 그 위에 그림
```

**권장 접근: Padding + Stack** — 기존 SketchPainter를 수정하지 않고 조합으로 해결.

### 3.3 닫기 버튼 (X) 변경

**Before**:
```dart
Icon(Icons.close, size: 18, color: iconColor)
```

**After**:
```dart
CustomPaint(
  size: Size(16, 16),
  painter: _SketchXPainter(
    color: effectiveBorderColor,
    strokeWidth: SketchDesignTokens.strokeBold,
    roughness: 0.8,
    seed: 42,
  ),
)
```

`_SketchXPainter`는 `SketchLinePainter`를 참조하여 모달 내부에 private class로 구현:
- 두 개의 대각선을 그리되, 각 선을 2번씩 그려 손그림 효과 강화
- roughness로 선의 흔들림 제어
- seed로 재현 가능한 렌더링

### 3.4 테마 연동

```dart
final sketchTheme = SketchThemeExtension.maybeOf(context);

final effectiveFillColor = widget.fillColor
    ?? sketchTheme?.fillColor ?? Colors.white;
final effectiveBorderColor = widget.borderColor
    ?? sketchTheme?.borderColor ?? SketchDesignTokens.base900;
final effectiveStrokeWidth = widget.strokeWidth
    ?? SketchDesignTokens.strokeBold;  // Modal은 Bold 기본값
final effectiveRoughness = widget.roughness
    ?? sketchTheme?.roughness ?? SketchDesignTokens.roughness;
final effectiveShadowColor = sketchTheme?.shadowColor
    ?? SketchDesignTokens.shadowColor;
final effectiveShadowOffset = sketchTheme?.shadowOffset
    ?? SketchDesignTokens.shadowOffsetMd;
```

### 3.5 제목 폰트 변경

```dart
Text(
  widget.title!,
  style: TextStyle(
    fontFamily: SketchDesignTokens.fontFamilyHand,
    fontFamilyFallback: SketchDesignTokens.fontFamilyHandFallback,
    fontSize: SketchDesignTokens.fontSizeLg,
    fontWeight: FontWeight.w600,
    color: sketchTheme?.textColor ?? SketchDesignTokens.base900,
  ),
)
```

## 4. API 호환성

### 유지되는 파라미터
| 파라미터 | 동작 | 비고 |
|---------|------|------|
| `title` | 동일 | 폰트만 핸드라이팅으로 변경 |
| `child` | 동일 | 변경 없음 |
| `actions` | 동일 | 변경 없음 |
| `showCloseButton` | 동일 | X 아이콘만 손그림으로 변경 |
| `barrierDismissible` | 동일 | 변경 없음 |
| `width` / `height` | 동일 | 변경 없음 |
| `fillColor` | 동일 | SketchPainter에 전달 |
| `borderColor` | 동일 | SketchPainter에 전달 |
| `strokeWidth` | 동일 | SketchPainter에 전달 |
| `roughness` | 동일 | SketchPainter에 전달 |
| `seed` | 동일 | SketchPainter에 전달 |
| `showBorder` | 동일 | SketchPainter.showBorder에 전달 |

### 변경 없는 메서드
- `SketchModal.show<T>()` 시그니처 완전 유지
- 반환 타입 `Future<T?>` 유지

## 5. 실행 순서

### Group 1 (단일 작업 — 순차 실행)

| 단계 | 작업 | 파일 |
|------|------|------|
| 1 | `_SketchModalDialog.build()` — BoxDecoration → CustomPaint+SketchPainter 전환 | `sketch_modal.dart` |
| 2 | 그림자 레이어 추가 (Stack + 오프셋 SketchPainter) | `sketch_modal.dart` |
| 3 | `_SketchCloseButton` — Material Icon → 손그림 X (`_SketchXPainter`) | `sketch_modal.dart` |
| 4 | 제목 폰트 핸드라이팅으로 변경 | `sketch_modal.dart` |
| 5 | 테마 색상 연동 확인 (light/dark) | `sketch_modal.dart` |
| 6 | 데모 앱 업데이트 | `modal_demo.dart` |

## 6. import 변경

```dart
// 추가 필요
import '../painters/sketch_painter.dart';

// 기존 유지
import '../theme/sketch_theme_extension.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
```

## 7. 주의사항

- `SketchPainter`는 `CustomPaint`의 child 크기에 맞춰 렌더링되므로, `SizedBox` 또는 `Container`로 크기를 명시해야 함
- 그림자의 불규칙한 모양이 본체와 동일하려면 **같은 seed 값** 사용 필수
- `height`가 null인 경우 (기본) Column의 `MainAxisSize.min`으로 콘텐츠 크기에 맞춤 — 이 경우 CustomPaint는 child 크기를 따라감
- `SketchPainter`는 `enableNoise: true` 시 내부에 노이즈 점을 그리므로 추가 작업 불필요
