# User Story: Design System Dialog 리디자인

## 개요

디자인 시스템의 `SketchModal` 컴포넌트를 에셋 이미지(dialog-light-mode.png, dialog-dark-mode.png)와 일치하도록 리디자인한다.
수정된 컴포넌트는 `design_system_demo` 앱에서 확인할 수 있어야 한다.

## 에셋 분석

### Light Mode (`prompt/archives/dialog-light-mode.png`)
- **배경**: 흰색/크림색, 손그림 스타일 둥근 사각형 테두리
- **테두리**: 두꺼운 불규칙 스트로크 (SketchPainter 질감)
- **제목**: 좌상단 "Dialog" (손글씨 폰트)
- **닫기 버튼**: 우상단 손그림 스타일 X 마크 (Material 아이콘 아님)
- **본문**: "This is dialog message ..."
- **액션 버튼**:
  - "Cancel" — outline 스타일 (테두리만, 채우기 없음)
  - "OK" — outline + 대각선 빗금(hatching) 패턴 채우기

### Dark Mode (`prompt/archives/dialog-dark-mode.png`)
- **배경**: 어두운/검정 배경
- **테두리**: 흰색/밝은 손그림 스타일 테두리
- **텍스트/아이콘**: 모두 밝은 색상
- **버튼**: 같은 레이아웃, 반전 색상, OK 버튼에 밝은 빗금 패턴

## 사용자 스토리

### US-1: SketchModal에 SketchPainter 적용
**AS** 디자인 시스템 사용자
**I WANT** 모달 다이얼로그가 손그림 스케치 질감을 가지길
**SO THAT** 다른 스케치 컴포넌트와 일관된 시각 경험을 제공함

**인수 조건:**
- 기존 `BoxDecoration` → `CustomPaint` + `SketchPainter` 교체
- 노이즈 텍스처, 불규칙 테두리 렌더링
- 기존 크기/레이아웃 유지 (width: 400, padding, spacing 동일)
- light/dark 모드 각각 적용

### US-2: 손그림 스타일 닫기 버튼 (X 마크)
**AS** 디자인 시스템 사용자
**I WANT** 닫기 버튼이 Material 아이콘이 아닌 손그림 스타일 X 마크이길
**SO THAT** 에셋 이미지와 일치하는 손그림 느낌의 X 버튼을 제공함

**인수 조건:**
- Material `Icons.close` → CustomPaint 손그림 X 렌더링
- 누를 때 애니메이션 효과 유지
- light/dark 모드 색상 자동 적용

### US-3: 빗금 패턴(Hatching) 버튼 스타일
**AS** 디자인 시스템 사용자
**I WANT** 확인 버튼에 대각선 빗금 패턴이 적용되길
**SO THAT** 에셋 이미지의 OK 버튼 디자인과 동일한 시각 효과를 제공함

**인수 조건:**
- `SketchButton`에 `hatching` 옵션 추가 또는 새로운 스타일 변형
- 대각선 빗금 패턴이 버튼 내부에 렌더링됨
- light/dark 모드 각각 적용

### US-4: Demo 앱에 Dialog 데모 추가/업데이트
**AS** 개발자
**I WANT** design_system_demo 앱에서 리디자인된 Dialog를 확인할 수 있길
**SO THAT** 변경사항을 시각적으로 검증할 수 있음

**인수 조건:**
- 기존 ModalDemo 업데이트 또는 별도 DialogDemo 추가
- light/dark 모드 토글 가능
- 에셋 이미지와 동일한 프리뷰 제공

## 영향 범위

| 파일 | 변경 유형 |
|------|----------|
| `sketch_modal.dart` | 수정 — BoxDecoration → SketchPainter |
| `sketch_button.dart` | 수정 — hatching 패턴 옵션 추가 |
| `sketch_painter.dart` 또는 새 painter | 수정/추가 — hatching 패턴 렌더링 |
| `modal_demo.dart` | 수정 — 리디자인 반영 |
| `design_system.dart` | 수정 가능 — 새 export 추가 시 |

## 기술 노트

- `SketchPainter`가 이미 path metric 기반 스케치 렌더링을 지원함
- `SketchButton`은 이미 `CustomPaint` + `SketchPainter`를 사용함 — modal도 같은 패턴 적용
- 빗금 패턴은 `SketchPainter`에 옵션으로 추가하거나 별도 painter로 구현 가능
- 닫기 버튼의 손그림 X는 기존 `XCrossPainter` 참고하여 소형 버전 제작

## 병렬/순차 실행 계획

### 병렬 실행 가능 (의존성 없음)
- US-1 (SketchModal 리디자인) — 독립 작업
- US-2 (닫기 버튼) — US-1과 동시 진행 가능하나 같은 파일이므로 순차 권장

### 순차 실행 필요 (의존성 있음)
1. **Group 1**: US-3 (hatching 패턴) — painter 수정 필요
2. **Group 2**: US-1 + US-2 (SketchModal 리디자인) — Group 1의 painter 수정 사용
3. **Group 3**: US-4 (Demo 업데이트) — Group 2 완료 후 진행
