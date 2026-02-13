# SketchTextArea - Frame0 스케치 스타일 리빌드

## 요약

기존 `SketchTextArea` 위젯을 Frame0 스케치 스타일로 리빌드한다.
현재 `BoxDecoration`으로 구현된 테두리를 `CustomPaint` + `SketchPainter` 기반으로 교체하여
손으로 그린 느낌의 질감을 표현하고, 레퍼런스 이미지에 맞는 디자인을 적용한다.

## 사용자 스토리

**AS** 디자인 시스템 사용자
**I WANT** 여러 줄 텍스트 입력 필드가 다른 스케치 위젯과 동일한 손그림 스타일을 가지길 원한다
**SO THAT** 앱 전체에서 일관된 Frame0 스케치 미학을 유지할 수 있다

## 플랫폼

- **Mobile** (Flutter)

## 요구사항

### 디자인 레퍼런스

| 모드 | 에셋 경로 |
|------|----------|
| Light | `prompt/archives/textarea-light-mode.png` |
| Dark | `prompt/archives/textarea-dark-mode.png` |

### 핵심 요구사항

1. **스케치 질감 테두리**: `CustomPaint` + `SketchPainter`를 사용하여 손그림 스타일 테두리 렌더링
2. **노이즈 텍스처**: 종이 같은 질감 (SketchPainter의 enableNoise)
3. **Resize Handle**: 우하단에 대각선 두 줄 — 장식용, 기능 없음
4. **Light/Dark 모드**: `SketchThemeExtension`의 테마 색상 자동 적용
5. **크기 유지**: 기존 `SketchTextArea`의 minLines/maxLines 기반 크기 동일
6. **손글씨 폰트**: `fontFamilyHand` + `fontFamilyHandFallback` 적용

### 기존 기능 유지

- label, hint, errorText, maxLength, showCounter
- controller, onChanged, enabled, readOnly
- fillColor, borderColor, strokeWidth 커스텀 옵션
- showBorder 옵션

## 영향 범위

| 파일 | 변경 유형 |
|------|----------|
| `design_system/lib/src/widgets/sketch_text_area.dart` | **수정** — CustomPaint + SketchPainter 적용, resize handle 추가 |
| `design_system_demo/.../widget_demo_view.dart` | **수정** — SketchTextArea 데모 등록 |
| `design_system_demo/.../widget_catalog_controller.dart` | **수정** — 카탈로그 항목 추가 |
| `design_system_demo/.../demos/text_area_demo.dart` | **신규** — TextArea 데모 화면 |

## 구현 전략

1. **SketchTextArea 리빌드** — `SketchInput` 패턴을 따라 `Container` → `CustomPaint` + `SketchPainter`로 교체
2. **Resize Handle Painter** — 우하단 대각선 줄무늬를 그리는 간단한 CustomPainter (또는 build 메서드 내 Canvas 직접 그리기)
3. **데모 페이지** — 카탈로그 등록 + 데모 화면 생성
