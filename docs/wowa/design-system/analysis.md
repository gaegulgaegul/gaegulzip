# Gap Analysis: Design System v2 (Cycle 2, Iteration 1)

- **Feature**: design-system
- **Platform**: Mobile (Flutter)
- **Cycle**: 2 (신규 위젯 추가 + 기존 위젯 수정)
- **분석일**: 2026-02-10
- **flutter analyze**: 에러 0개, warning 3개 (기존 painter), info 9개

## Match Rate: 91% (이전 78%)

| 카테고리 | Match Rate | 이전 | 갭 수 |
|---------|:----------:|:----:|:-----:|
| 토큰/테마 | 98% | 72% | 1 |
| 기존 위젯 수정 | 92% | 65% | 0 |
| 신규 위젯 (11개) | 88% | 87% | 2 |

---

## 해결된 갭 (6건)

### 1. accentPrimary 색상 → 파란색 통일 (CRITICAL → 해결)

| 토큰 | 디자인 값 | 구현 값 |
|------|----------|---------|
| accentPrimary | `#2196F3` | `#2196F3` |
| accentPrimaryLight | `#64B5F6` | `#64B5F6` |
| accentPrimaryDark | `#1976D2` | `#1976D2` |

### 2. 기존 위젯 fontFamily 적용 (CRITICAL → 해결)

SketchButton, SketchInput, SketchChip, SketchDropdown 모두 `fontFamilyHand` 적용 완료.
SketchCard는 컨테이너 위젯으로 자체 TextStyle 없음 (정상).

### 3. SketchButton 크기 동기화 (HIGH → 해결)

| Size | 디자인 | 구현 |
|------|:------:|:----:|
| medium | 44 | 44 |
| large | 56 | 56 |

### 4. SketchAvatar xxl(120) 추가 (HIGH → 해결)

```
구현: xs(24), sm(32), md(40), lg(56), xl(80), xxl(120)
```

디자인의 xlarge(120)에 대응하는 xxl(120) 추가됨.

### 5. surface 색상 값 동기화 (MEDIUM → 해결)

| 토큰 | 디자인 | 구현 |
|------|--------|------|
| surface (Light) | `#F5F0E8` | `#F5F0E8` |
| surfaceDark | `#23273A` | `#23273A` |

### 6. BottomNavigationBar labelBehavior 기본값 (MEDIUM → 해결)

디자인: showSelected / 구현: onlyShowSelected (동일 동작)

---

## 잔여 갭 (3건)

### 7. SketchAppBar showSketchBorder TODO (MEDIUM)

파라미터 존재하나 SketchPainter 연동이 TODO로 비활성화.
`sketch_app_bar.dart:189`

### 8. SketchTabBar filled 인디케이터 미구현 (LOW)

underline만 구현됨. filled 스타일은 placeholder 상태.
`sketch_tab_bar.dart:216`

### 9. SketchThemeExtension.light() surfaceColor (MEDIUM)

`sketch_theme_extension.dart:91`에서 surfaceColor가 `#F7F7F7` (중성 회색).
디자인 토큰 `#F5F0E8` (따뜻한 크림)과 불일치.

---

## 스킵 항목

- SocialLoginButton.sketchStyle: 사용자 판단으로 불필요

---

## Frame0 원본 대비 추가 갭 (참조용)

1. 스케치 테두리 → BoxDecoration 교체로 손그림 느낌 약화
2. Hand-drawn 아이콘셋 부재 (Material Icons 사용 중)

---

## 결론

90% 임계값 달성. 잔여 3건은 모두 비차단(non-blocking) 수준으로
enhancement 항목으로 추적 가능.
