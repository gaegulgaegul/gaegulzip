# User Story: SketchAvatar 스케치 스타일 적용

## 개요

SketchAvatar 위젯의 테두리와 플레이스홀더를 Frame0 스케치 스타일로 개선한다.

## 사용자 스토리

**AS** 디자인 시스템 사용자
**I WANT** SketchAvatar의 테두리가 손으로 그린 듯한 불규칙한 스케치 질감으로 렌더링되고, 플레이스홀더가 사람 실루엣 아이콘으로 표시되길
**SO THAT** 다른 디자인 시스템 컴포넌트(SketchButton, SketchContainer 등)와 시각적 일관성을 유지할 수 있다

## 요구사항

### 1. 테두리 스케치 스타일 적용

- **현재**: `Border.all()`로 완벽한 원/사각형 테두리 렌더링
- **변경**: `SketchCirclePainter` (원형) / `SketchPainter` (사각형) 활용하여 손그림 질감 적용
- 참조 디자인: `prompt/archives/img_19.png`, `prompt/archives/img_20.png`의 테두리 질감
- 원형(circle): 불규칙한 흔들리는 원형 테두리 (2중 선)
- 사각형(roundedSquare): 불규칙한 둥근 사각형 테두리

### 2. 플레이스홀더 디자인 변경

- **현재**: `SketchImagePlaceholder` (X-cross 패턴 + person_outline 아이콘)
- **변경**: `prompt/archives/img_19.png`, `prompt/archives/img_20.png`와 동일한 사람 실루엣 아이콘
- X-cross 패턴 제거, 사람 아이콘만 중앙 배치
- 라이트 모드: 검은 테두리 + 밝은 배경 위 검은 아이콘
- 다크 모드: 흰 테두리 + 어두운 배경 위 흰 아이콘

### 3. 기존 API 호환

- 모든 기존 프로퍼티(size, shape, backgroundColor, borderColor, strokeWidth 등) 유지
- `showBorder: false` 옵션 정상 동작
- 이니셜, 이미지 URL, asset 이미지 기능 그대로 유지

### 4. 데모 앱 업데이트

- `design_system_demo` 앱의 `AvatarDemo`에서 변경 사항 확인 가능

## 수정 대상

| 파일 | 변경 내용 |
|------|----------|
| `design_system/lib/src/widgets/sketch_avatar.dart` | SketchCirclePainter 기반 테두리 + 플레이스홀더 변경 |
| `design_system_demo/.../demos/avatar_demo.dart` | 데모 업데이트 (필요시) |

## 플랫폼

- **Mobile** (Flutter design_system 패키지)

## 참조 리소스

- `SketchCirclePainter`: 이미 구현된 스케치 원형 페인터
- `SketchPainter`: 이미 구현된 스케치 사각형 페인터
- `prompt/archives/img_19.png`: 다크 배경 사람 실루엣 (흰 테두리)
- `prompt/archives/img_20.png`: 라이트 배경 사람 실루엣 (검은 테두리)
- `prompt/archives/img_21.png`: 현재 SketchAvatar 데모 스크린샷
