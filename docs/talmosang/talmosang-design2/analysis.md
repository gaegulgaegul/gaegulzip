# talmosang-design2 Gap Analysis

> **Match Rate: 78%** (90% 임계값 미달)
> **분석일**: 2026-02-19
> **디자인 문서**: user-story.md, web-design-spec.md, web-brief.md
> **구현 경로**: apps/web/talmosang/

---

## Acceptance Criteria 충족 현황

| AC | 항목 | Match Rate |
|----|------|:----------:|
| AC-1 | 전폭 히어로 레이아웃 | 100% (3/3) |
| AC-2 | 메인 카피 텍스트 | 80% (4/5) |
| AC-3 | 이미지 업로드 영역 | 100% (3/3) |
| AC-4 | 캐릭터 배치 | 75% (접근법 변경 감안) |
| AC-5 | 기존 기능 유지 | 75% (3/4) |

---

## 미구현/누락 항목

| 우선순위 | 항목 | 디자인 위치 | 영향도 |
|----------|------|------------|--------|
| 1 | `overflow-x: hidden` 미적용 | web-design-spec 섹션 2-1 | 중간 |
| 2 | upload 상태 AdBanner 미렌더링 | user-story AC-5 | 낮음 |

## 의도적 변경 항목 (25개)

### 텍스트 크기 전반 축소 (한 화면 맞춤 목적)

| 항목 | 디자인 | 구현 |
|------|--------|------|
| 타이틀 (upload) | `text-7xl md:text-9xl` | `text-5xl md:text-7xl` |
| 헤드라인 | `text-4xl md:text-6xl` | `text-2xl md:text-5xl` |
| 서브카피 | `text-lg md:text-xl` | `text-sm md:text-lg` |
| 상단 패딩 | `pt-12 md:pt-20` | `pt-6 md:pt-10` |
| 카피 간격 | `mb-3`, `mb-8` | `mb-1`, `mb-3` |
| 업로드 영역 너비 | `max-w-lg` | `max-w-md` |
| 타이틀 테두리 | `border-[6px]` | `border-[5px]` |

### 캐릭터 구현 방식 변경

| 항목 | 디자인 | 구현 |
|------|--------|------|
| 구현 방식 | 개별 SVG 4개 + flex 배열 | 단일 합쳐진 characters.svg |
| 반응형 크기 | `h-[120px] sm:h-[180px] md:h-[250px]` | `w-full block` 자동 스케일 |
| 반응형 단계 | 3단계 (mobile/tablet/desktop) | 2단계 (mobile/desktop) |

### 디자인에 없는 추가 구현

| 항목 | 구현 위치 |
|------|----------|
| 캐릭터 배너 하단 검정 테두리 `border-b-[8px]` | CharacterBanner.tsx |
| `pointer-events-none` | CharacterBanner.tsx |

---

## 권장 조치

| 옵션 | 설명 |
|------|------|
| **권장: 옵션 3 (양쪽 통합)** | `overflow-x: hidden`은 구현에 추가 + 나머지 차이는 디자인 문서 업데이트 |

대부분의 갭이 "한 화면 레이아웃" 목표를 위한 합리적 축소이므로, 디자인 문서를 현재 구현에 맞게 업데이트하는 방향이 적합합니다.

---

## CTO 리뷰 요약 (75/80점, 조건부 승인)

| 우선순위 | 문제 | 해결책 |
|----------|------|--------|
| 릴리스 전 필수 | `overflow-x: hidden` 누락 | main 태그에 추가 |
| 중기 | `characters.svg` 912KB (base64 PNG 내포) | 순수 벡터 SVG 또는 WebP 교체 |
| 낮음 | 텍스트 크기 스펙 미달 | 디자인 문서 업데이트 |
| 낮음 | `UploadSection`의 `alert()` 사용 | `setError` 콜백으로 통일 |
