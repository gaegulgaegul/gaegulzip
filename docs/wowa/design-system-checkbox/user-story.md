# User Story: SketchCheckbox 스케치 스타일 적용

## 요약

디자인 시스템의 SketchCheckbox 컴포넌트가 에셋 이미지처럼 손그림(스케치) 질감을 표현하도록 개선한다.

## 배경

현재 SketchCheckbox는 Flutter 기본 `Border.all()`로 완벽한 직선 테두리를 그리고 있어, 다른 컴포넌트(SketchButton 등)가 `SketchPainter`로 표현하는 손그림 스타일과 일관성이 없다.

## 요구사항

### 필수 요구사항

1. **스케치 스타일 테두리**: `SketchPainter`를 사용하여 불규칙한 손그림 느낌의 테두리 표현
2. **스케치 스타일 체크마크**: 체크마크(V)에 roughness/jitter를 적용하여 손으로 그린 느낌 표현
3. **Light/Dark 모드 지원**: `SketchThemeExtension` 색상 체계에 따라 라이트/다크 모드 각각 적용
4. **크기 유지**: 기존 기본 크기(24x24)와 동일하게 유지
5. **데모 앱 확인**: `design_system_demo` 앱에서 변경 사항 확인 가능

### 에셋 디자인 참고

- **Light mode**: 검은색 스케치 테두리 + 체크마크, 흰색/밝은 배경
- **Dark mode**: 흰색 스케치 테두리 + 체크마크, 어두운 배경

### 비기능 요구사항

- 기존 API(value, onChanged, tristate, activeColor 등) 호환성 유지
- 애니메이션 동작 유지
- 비활성화 상태 동작 유지

## 플랫폼

- **Mobile** (Flutter design_system 패키지)

## 관련 파일

- `apps/mobile/packages/design_system/lib/src/widgets/sketch_checkbox.dart`
- `apps/mobile/packages/design_system/lib/src/painters/sketch_painter.dart`
- `apps/mobile/apps/design_system_demo/lib/app/modules/widgets/views/demos/checkbox_demo.dart`
