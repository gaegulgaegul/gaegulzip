# User Story: SketchImagePlaceholder 디자인 개선

## 개요

디자인 시스템의 `SketchImagePlaceholder` 위젯이 레퍼런스 이미지의 **펜/마커 질감**을 충실하게 표현하도록 `XCrossPainter`를 개선한다.

## 사용자 스토리

> 앱 사용자로서, 이미지 플레이스홀더가 손으로 그린 마커 스타일의 자연스러운 질감을 갖기를 원한다. 라이트/다크 모드에서 각각 적절한 색상으로 표현되어야 한다.

## 요구사항

### 핵심 요구사항

1. **질감 표현**: 레퍼런스 이미지(prompt/archives/)의 펜/마커 질감을 컴포넌트에서 재현
   - 가변 두께 선 (중앙이 두껍고 끝이 얇은 자연스러운 펜 스트로크)
   - 현재의 균일한 `strokeWidth` 기반 렌더링을 개선
2. **크기 유지**: 기존 프리셋 (xs: 40x40, sm: 80x80, md: 120x120, lg: 200x200) 및 커스텀 크기 동일
3. **Light/Dark 모드 지원**: 테마에 따라 적절한 색상 자동 적용
   - Light: 검은 선 + 흰 배경
   - Dark: 흰 선 + 어두운 배경

### 레퍼런스 이미지 분석

- `prompt/archives/image-placeholder-light-mode.png`: 흰 배경, 검정 마커 스타일 선
- `prompt/archives/image-placeholder-dark-mode.png`: 검정 배경, 흰 마커 스타일 선
- 공통 특징: 두꺼운 테두리, X자 대각선, 가변 두께, 자연스러운 곡률

### 제약 사항

- 기존 위젯 API (SketchImagePlaceholder의 생성자 파라미터) 호환성 유지
- 기존 프리셋 크기 변경 없음
- 데모 앱(design_system_demo)에서 변경 확인 가능

## 수정 대상 파일

| 파일 | 변경 유형 |
|------|---------|
| `XCrossPainter` | 핵심: 가변 두께 렌더링 로직 추가 |
| `SketchImagePlaceholder` | 테마 색상 매핑 검증/개선 |
| `ImagePlaceholderDemo` | 데모 뷰 업데이트 (필요 시) |

## 플랫폼

- **Mobile** (Flutter design_system 패키지)
