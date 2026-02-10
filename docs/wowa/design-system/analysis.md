# Design System 갭 분석 보고서

- **피처**: design-system (Frame0 모노크롬 스타일 전환)
- **플랫폼**: Mobile (Flutter)
- **분석일**: 2026-02-10
- **Match Rate**: **97%**

---

## 전체 점수

| 카테고리 | 점수 | 상태 |
|---------|:----:|:----:|
| 모노크롬 전환 완성도 | 100% | PASS |
| CustomPaint 제거 완성도 | 100% | PASS |
| BoxDecoration 일관성 | 100% | PASS |
| 테마 연동 | 92% | PASS |
| 비활성화 상태 패턴 | 86% | PASS |
| 버튼 레이아웃 (클리핑 수정) | 100% | PASS |
| 미사용 코드 정리 | 100% | PASS |
| 가이드 문서 동기화 | 72% | WARN |

---

## 코드 품질 분석 (72/100)

### CRITICAL — 즉시 수정 필요

| # | 파일 | 이슈 |
|---|------|------|
| 1 | `sketch_input.dart` | `ColorSpec` 클래스가 public으로 노출됨 (다른 위젯은 `_ColorSpec`) |
| 2 | `sketch_dropdown.dart` | 외부 탭 시 드롭다운이 닫히지 않음 (barrier 없음) |
| 3 | `sketch_dropdown.dart` | Overlay가 위젯 트리 외부 context 참조 — stale reference 가능성 |
| 4 | `sketch_card.dart:257-271` | `withOpacity()` deprecated — `withValues(alpha:)` 사용 필요 |

### WARNING — 개선 권장

| # | 파일 | 이슈 |
|---|------|------|
| 1 | 8개 위젯 | `roughness`, `bowing`, `seed`, `enableNoise` 파라미터 미사용 (CustomPaint 제거 후 잔존) |
| 2 | doc-string 3건 | `accentPrimary` 오래된 예제 잔존 (sketch_container, sketch_card) |
| 3 | `design_system.dart` | `Calculator` 보일러플레이트 클래스 잔존 |
| 4 | 전체 | `BorderRadius.circular(6)` 등 하드코딩 — 토큰 활용 가능 |

### 미사용 파라미터 매트릭스

| 위젯 | roughness | bowing | seed | enableNoise |
|------|:---------:|:------:|:----:|:-----------:|
| sketch_container | 미사용 | 미사용 | 미사용 | 미사용 |
| sketch_card | 미사용 | 미사용 | 미사용 | 미사용 |
| sketch_dropdown | 미사용 | — | 미사용 | — |
| sketch_icon_button | 미사용 | — | 미사용 | — |
| sketch_slider | 미사용 | — | 미사용 | — |
| sketch_switch | 미사용 | — | 미사용 | — |
| sketch_input | 부분(저장만) | — | 미사용 | — |
| sketch_chip | 부분(저장만) | — | — | — |
| sketch_checkbox | **사용됨** | — | **사용됨** | — |
| sketch_progress_bar | **사용됨** | — | **사용됨** | — |

> checkbox, progress_bar는 내부 CustomPainter를 유지하므로 정당한 사용

---

## 권장 조치 우선순위

### 즉시

1. `sketch_input.dart`의 `ColorSpec` → `_ColorSpec` 변경
2. `sketch_dropdown.dart`에 외부 탭 닫힘 처리 추가
3. `sketch_card.dart`의 `withOpacity()` → `withValues(alpha:)` 수정
4. doc-string의 `accentPrimary` 예제 3건 수정

### 단기

5. 8개 위젯에서 미사용 `roughness`/`seed`/`bowing`/`enableNoise` 파라미터 제거
6. `design_system.dart`의 `Calculator` 클래스 삭제

### 백로그

7. `BorderRadius` 값을 `SketchDesignTokens` 토큰으로 통일
8. `sketch_button` 테마 연동 검토
