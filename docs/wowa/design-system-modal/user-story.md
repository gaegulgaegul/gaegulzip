# User Story: SketchModal 스케치 스타일 리디자인

## 개요

디자인 시스템의 Modal 컴포넌트를 Frame0 스케치 스타일로 리디자인한다.
기존 `BoxDecoration` 기반의 클린한 테두리를 `CustomPaint` + `SketchPainter` 기반의 손그림 스타일로 교체하여,
다른 스케치 컴포넌트(SketchButton, SketchContainer 등)와 시각적 일관성을 확보한다.

## 사용자 스토리

**AS** 디자인 시스템 사용자
**I WANT** Modal이 다른 스케치 컴포넌트와 동일한 손그림 스타일 질감을 가지길
**SO THAT** 앱 전체에서 일관된 Frame0 스케치 미학이 유지됨

## 수용 기준

### AC-1: 스케치 스타일 테두리
- [ ] `BoxDecoration` → `CustomPaint` + `SketchPainter`로 교체
- [ ] 손으로 그린 불규칙한 둥근 모서리 테두리 렌더링
- [ ] roughness, seed 파라미터로 스케치 느낌 조절 가능
- [ ] 종이 같은 노이즈 텍스처 적용

### AC-2: 스케치 스타일 닫기 버튼 (X)
- [ ] Material `Icons.close` → 손그림 X 마크로 교체
- [ ] 디자인 이미지와 동일한 두꺼운 X 형태
- [ ] 테마에 따른 색상 대응 (light: 검정, dark: 흰색)

### AC-3: 그림자 효과
- [ ] 디자인 이미지와 동일한 오프셋 그림자 추가
- [ ] light mode: 우하단 어두운 그림자
- [ ] dark mode: 우하단 밝은/반투명 그림자
- [ ] `SketchThemeExtension`의 shadow 속성 연동

### AC-4: Light/Dark 모드
- [ ] light mode: 흰색/크림색 배경 + 검은 테두리 + 어두운 그림자
- [ ] dark mode: 어두운 배경 + 흰색/밝은 테두리 + 반투명 그림자
- [ ] `SketchThemeExtension.light()` / `.dark()` 연동

### AC-5: 기존 API 호환성
- [ ] `SketchModal.show()` 시그니처 유지 (기존 사용 코드 변경 없음)
- [ ] width, height, fillColor, borderColor 등 기존 파라미터 동작 유지
- [ ] title, child, actions, showCloseButton 등 레이아웃 동일

### AC-6: 데모 앱 검증
- [ ] `design_system_demo`의 `ModalDemo`에서 light/dark 모드 확인 가능
- [ ] 기존 데모 기능(속성 조절, 변형 갤러리) 유지

## 디자인 참조

### Light Mode
- 배경: 흰색/크림색
- 테두리: 두꺼운 검은색, 불규칙한 둥근 모서리
- 그림자: 우하단 진한 오프셋 그림자
- 제목: 검은색, 핸드라이팅 폰트
- 닫기(X): 검은색 두꺼운 X 마크

### Dark Mode
- 배경: 진한 어두운 색
- 테두리: 흰색/밝은색, 불규칙한 둥근 모서리
- 그림자: 우하단 밝은/반투명 그림자
- 제목: 흰색, 핸드라이팅 폰트
- 닫기(X): 흰색 두꺼운 X 마크

## 영향 범위

### 수정 파일
1. `apps/mobile/packages/design_system/lib/src/widgets/sketch_modal.dart` — 핵심 컴포넌트
2. `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/modal_demo.dart` — 데모

### 의존 관계
- `SketchPainter` (기존) — 스케치 테두리 렌더링
- `SketchThemeExtension` (기존) — 테마 색상
- `SketchDesignTokens` (기존) — 디자인 토큰

## 플랫폼

**Mobile** (Flutter Design System)
