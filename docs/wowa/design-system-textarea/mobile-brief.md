# SketchTextArea - Mobile Technical Brief

## 개요

기존 `SketchTextArea`를 Frame0 스케치 스타일로 리빌드.
`Container` + `BoxDecoration` → `CustomPaint` + `SketchPainter` 전환.

## 변경 파일

### 1. `sketch_text_area.dart` (수정)

**변경 내용:**
- `Container` + `BoxDecoration` → `CustomPaint` + `SketchPainter`로 교체
- `SketchPainter` import 추가
- Resize Handle 렌더링 추가 (Stack + Positioned + CustomPaint)
- `fontFamilyHand` + `fontFamilyHandFallback` 적용
- 기본 strokeWidth를 `strokeBold` (3.0)으로 변경

**구현 패턴:** `SketchInput` 위젯의 `CustomPaint` + `SketchPainter` 패턴을 따름

**Resize Handle 구현:**
- `Stack` 내부에 `Positioned(bottom, right)`로 배치
- `CustomPaint`로 대각선 2줄 그리기
- 색상: 현재 borderColor 사용
- 크기: 14×14, strokeWidth: 2.0

### 2. `text_area_demo.dart` (신규)

**내용:**
- 실시간 프리뷰: label, hint, error, counter 토글
- 속성 조절 패널: SketchSwitch로 토글
- 변형 갤러리: 기본, 라벨+힌트, 에러, 카운터, 비활성화

### 3. `widget_demo_view.dart` (수정)

- `case 'SketchTextArea'` 추가
- `TextAreaDemo` import 추가

### 4. `widget_catalog_controller.dart` (수정)

- `SketchTextArea` 항목 추가

## 실행 그룹

단일 그룹 (모듈 분리 불필요 — UI 컴포넌트 1개 + 데모 1개)

### Group 1 (병렬 가능)
- **Task A**: `sketch_text_area.dart` 리빌드
- **Task B**: `text_area_demo.dart` 작성 + 카탈로그 등록

의존성: Task B는 Task A의 위젯 API에 의존하므로, Task A를 먼저 완료한 후 Task B 진행이 안전.
단, 기존 API가 유지되므로 실질적으로 병렬 가능.
