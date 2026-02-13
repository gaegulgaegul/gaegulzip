# Plan: SketchCheckbox 스케치 스타일 적용

## 현재 상태 분석

### 문제점
| 항목 | 현재 | 목표 |
|------|------|------|
| 테두리 | `Border.all()` (완벽한 직선) | `SketchPainter` (불규칙한 손그림) |
| 체크마크 | 직선 `drawLine` | roughness/jitter 적용된 손그림 |
| 배경 | `Container` + `BoxDecoration` | `CustomPaint` + `SketchPainter` |
| 노이즈 텍스처 | 없음 | `SketchPainter`의 noise 활용 |

### 참조 패턴 (SketchButton)
```dart
// SketchButton이 사용하는 패턴 (sketch_button.dart:152-161)
CustomPaint(
  painter: SketchPainter(
    fillColor: colorSpec.fillColor,
    borderColor: colorSpec.borderColor,
    strokeWidth: colorSpec.strokeWidth,
    roughness: sketchTheme?.roughness,
    seed: widget.text?.hashCode ?? 0,
    showBorder: widget.showBorder,
    borderRadius: SketchDesignTokens.irregularBorderRadius,
  ),
  child: SizedBox(...)
)
```

## 구현 계획

### Step 1: 테두리를 SketchPainter로 교체 (영향도: 핵심)

**파일**: `sketch_checkbox.dart`

**변경 내용**:
- `Container` + `BoxDecoration`(배경+테두리) → `CustomPaint` + `SketchPainter`
- SketchPainter가 fillColor, borderColor, roughness, noise 모두 처리
- 체크 상태에 따른 색상 로직은 유지하되, SketchPainter 파라미터로 전달

**색상 매핑** (에셋 이미지 기반):
- **Unchecked (Light)**: fillColor=transparent, borderColor=base900 (검정 테두리)
- **Checked (Light)**: fillColor=transparent, borderColor=base900 (검정 테두리, 배경 채우기 없음)
- **Unchecked (Dark)**: fillColor=transparent, borderColor=textOnDark (흰색 테두리)
- **Checked (Dark)**: fillColor=transparent, borderColor=textOnDark (흰색 테두리)

> 에셋 이미지 분석: checked 상태에서도 배경색을 채우지 않고, 체크마크만 표시하는 스타일

### Step 2: 체크마크 painter에 roughness 적용

**파일**: `sketch_checkbox.dart` (`_SketchCheckMarkPainter`)

**변경 내용**:
- 체크마크 선에 `roughness` 기반 jitter 추가
- 직선 `drawLine` → `Path` + quadraticBezierTo (미세한 곡선)
- seed 기반 Random으로 재현 가능한 불규칙성

### Step 3: Light/Dark 모드 색상 보정

**파일**: `sketch_checkbox.dart`

**변경 내용**:
- checked 상태 색상 로직 수정: 에셋처럼 배경색 없이 테두리 + 체크마크만
- Light: borderColor=textColor(base900), checkColor=textColor(base900)
- Dark: borderColor=textColor(textOnDark), checkColor=textColor(textOnDark)

### Step 4: 데모 확인

**파일**: `checkbox_demo.dart`

- 기존 데모 코드가 이미 충분히 다양한 케이스를 커버하므로 추가 수정 불필요
- 빌드 후 시각적 확인만 진행

## 실행 순서

```
Step 1 (테두리 교체) → Step 2 (체크마크 개선) → Step 3 (색상 보정) → Step 4 (데모 확인)
```

모든 Step은 같은 파일(`sketch_checkbox.dart`)에서 순차적으로 진행.

## 영향도

- **sketch_checkbox.dart**: 주요 변경 (테두리 + 체크마크 + 색상)
- **checkbox_demo.dart**: 변경 없음 (기존 데모로 확인 가능)
- **sketch_painter.dart**: 변경 없음 (기존 SketchPainter 재사용)
- **기존 API**: 변경 없음 (모든 public 파라미터 유지)
