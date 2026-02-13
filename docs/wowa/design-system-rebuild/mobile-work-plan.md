# Mobile Work Plan: SketchInput 리빌드

## 실행 그룹

### Group 1: 핵심 인프라 (병렬 없음 — 단일 파일)
- `sketch_input.dart`: SketchInputMode enum + SketchPainter 교체 + _ColorSpec 조정 + 모드 인프라
- `sketch_search_input.dart`: deprecated 처리 + SketchInput(mode: search) 위임

### Group 2: 모드별 동작 구현 (Group 1 의존)
- `sketch_input.dart`: `_resolveModeDefaults()` — 모드별 기본 아이콘/힌트/readOnly 결정

### Group 3: 데모 업데이트 (Group 2 의존)
- `input_demo.dart`: 모드 선택기 + 모드별 갤러리 섹션

## 모듈 계약

| 입력 | 출력 |
|------|------|
| `SketchInputMode` enum | 모드별 `_ModeDefaults` (icon, hint, readOnly) |
| `_ColorSpec` | `SketchPainter` 파라미터 (fillColor, borderColor, strokeWidth) |
| `widget.*` 속성 | 모드 기본값 + 사용자 오버라이드 병합 |

## 하위호환 검증

기존 사용처 7곳 모두 `mode` 파라미터 없이 호출 → `defaultMode`로 동작하여 호환.
