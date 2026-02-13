# User Story: SketchSwitch 디자인 리빌드

## 요약

디자인 시스템의 `SketchSwitch` 위젯을 에셋 이미지 기반의 손그림 스케치 스타일로 리빌드한다.
수정된 결과물은 `design_system_demo` 앱에서 light/dark mode 전환으로 확인 가능해야 한다.

## 사용자 스토리

> 사용자로서, 스위치 토글이 다른 스케치 컴포넌트와 동일한 손그림 질감(불규칙한 테두리, 노이즈 텍스처)을 가지길 원한다.
> Light mode에서는 검은 트랙 + 흰 썸, Dark mode에서는 흰 트랙 + 어두운 썸으로 표현되어야 한다.

## 에셋 분석

### Light Mode (`switch-light-mode.png`)
- **트랙**: 검은색(#000000) 채우기, 불규칙한 pill 형태 테두리
- **썸**: 흰색 채우기 원형, 불규칙한 가장자리
- 오른쪽 배치 (ON 상태)

### Dark Mode (`switch-dark-mode.png`)
- **트랙**: 흰색(#FFFFFF) 채우기, 불규칙한 pill 형태 테두리
- **썸**: 검은색 채우기 원형, 불규칙한 가장자리
- 오른쪽 배치 (ON 상태)

## 수용 기준

- [ ] 트랙과 썸 모두 `SketchPainter`/`SketchCirclePainter`를 활용한 손그림 스타일 렌더링
- [ ] 노이즈 텍스처 적용으로 종이 같은 질감 표현
- [ ] 기존 크기 유지 (width: 50, height: 28)
- [ ] Light/Dark mode 각각 에셋 이미지에 맞는 색상 적용
- [ ] 기존 애니메이션(200ms easeInOut) 유지
- [ ] 비활성화 상태(opacity 처리) 유지
- [ ] `design_system_demo` 앱에서 확인 가능

## 플랫폼

- **Mobile** (Flutter Design System)

## 영향 범위

| 파일 | 변경 유형 |
|------|----------|
| `sketch_switch.dart` | 핵심 수정 - Container → CustomPaint 전환 |
| `switch_demo.dart` | 검증용 (수정 불필요 - 기존 데모로 충분) |
| `SketchPainter` | 읽기 전용 (수정 불필요) |
| `SketchCirclePainter` | 읽기 전용 (수정 불필요) |
| `SketchThemeExtension` | 읽기 전용 (기존 테마 속성 활용) |
