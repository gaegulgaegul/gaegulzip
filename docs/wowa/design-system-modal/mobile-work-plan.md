# Mobile Work Plan: SketchModal 스케치 스타일 리디자인

## 실행 그룹

### Group 1 (단일 개발자 — 순차 실행)

| 단계 | 작업 | 파일 |
|------|------|------|
| 1 | sketch_modal.dart 전체 리디자인 | `sketch_modal.dart` |
| 2 | modal_demo.dart 업데이트 | `modal_demo.dart` |

### 변경 요약

**sketch_modal.dart:**
- import 추가: `dart:math`, `../painters/sketch_painter.dart`
- `_SketchModalDialogState.build()`: BoxDecoration → CustomPaint+SketchPainter + 그림자 Stack
- `_SketchCloseButton`: Material Icon → _SketchXPainter 손그림 X
- 제목 폰트: fontFamilyHand 적용
- 테마 기본값: strokeBold, base900

**modal_demo.dart:**
- 기존 기능 유지, 변경 불필요 (API 호환)
