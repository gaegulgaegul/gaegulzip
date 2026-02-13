# User Story: SketchInput 컴포넌트 리빌드

## 개요

디자인 시스템의 SketchInput 컴포넌트를 리빌드하여 **실제 손으로 그린 스케치 질감**을 표현하고, 하나의 컴포넌트에서 **모드 전환**으로 다양한 입력 타입을 지원하도록 개선한다.

## 사용자 스토리

> **사용자로서**, 입력 필드가 손으로 그린 스케치 느낌의 테두리와 질감을 가지기를 원한다.
> 그래서 앱 전체에서 일관된 Frame0 스케치 스타일을 경험할 수 있다.

> **개발자로서**, 하나의 `SketchInput` 컴포넌트에서 mode 옵션 하나로 default/search/date/time/datetime 입력을 전환할 수 있기를 원한다.
> 그래서 별도의 위젯을 만들 필요 없이 일관된 API로 모든 입력 타입을 사용할 수 있다.

## 기능 요구사항

### 1. 스케치 질감 적용
- `BoxDecoration` 대신 `SketchPainter`(`CustomPaint`)를 사용하여 불규칙한 손으로 그린 테두리 렌더링
- 노이즈 텍스처로 종이 같은 질감 표현
- 시드 기반 랜덤으로 재현 가능한 스케치 모양

### 2. 입력 모드 (SketchInputMode)
| 모드 | 설명 | 특징 |
|------|------|------|
| `default` | 기본 텍스트 입력 | 라벨 + 입력 필드 |
| `search` | 검색 입력 | 스케치 스타일 돋보기 아이콘 + "Search" 힌트 + 지우기 버튼 |
| `date` | 날짜 입력 | "YYYY/MM/DD" 포맷 표시 |
| `time` | 시간 입력 | "HH:MM AM/PM" 포맷 표시 |
| `datetime` | 날짜+시간 입력 | 날짜와 시간 조합 |

### 3. Light/Dark 모드
- `SketchThemeExtension`의 light/dark 테마 값 활용
- Light: 흰색 배경 + 검정 테두리 (두꺼운 스케치 선)
- Dark: 어두운 배경 + 흰색 테두리 (두꺼운 스케치 선)

### 4. 라벨
- 항상 입력 필드 상단에 고정 위치
- 옵셔널 값 (null이면 표시하지 않음)
- 손글씨 폰트 (기존과 동일)

### 5. 크기
- 기존과 동일한 크기 유지 (한 줄: 44px 높이)

## 디자인 레퍼런스

| 모드 | Light | Dark |
|------|-------|------|
| Default | `prompt/archives/input-light-mode.png` | `prompt/archives/input-dark-mode.png` |
| Search | `prompt/archives/search-input-light-mode.png` | `prompt/archives/search-input-dark-mode.png` |
| Date | `prompt/archives/date-input-light-mode.png` | — |
| Time | `prompt/archives/time-input-light-mode.png` | `prompt/archives/time-input-dark-mode.png` |

## 영향 범위

### 직접 변경
- `sketch_input.dart` — 핵심 리빌드 (SketchPainter 적용 + 모드 시스템)
- `sketch_search_input.dart` — deprecated 또는 SketchInput(mode: search)로 대체

### 간접 영향
- `design_system.dart` — export 업데이트
- `input_demo.dart` — 데모 앱에 모드별 데모 추가

### 데모 확인
- `apps/mobile/apps/design_system_demo/` 에서 모든 모드의 light/dark 변형을 확인 가능해야 함

## 수락 기준

- [ ] SketchInput이 SketchPainter를 사용하여 손으로 그린 스케치 테두리 렌더링
- [ ] mode 파라미터로 default/search/date/time/datetime 전환 가능
- [ ] Light/Dark 모드 각각 디자인 이미지와 일치
- [ ] 기존 크기(높이 44px) 유지
- [ ] label이 옵셔널하고 상단에 고정 위치
- [ ] 데모 앱에서 모든 모드/테마 조합 확인 가능
- [ ] 기존 SketchInput 사용처의 호환성 유지
