# 에이전트 간 통신 프로토콜

> 모든 PDCA phase에서 에이전트 간 양방향 통신을 보장하는 표준 절차.
> 하류 에이전트가 문제를 발견하면 상류 에이전트에게 구조화된 피드백을 반환합니다.

## 핵심 원칙

1. **양방향 필수**: 모든 에이전트 상호작용에 피드백 경로가 있어야 합니다
2. **구조화된 형식**: 피드백은 정해진 형식(JSON/Markdown)으로 반환합니다
3. **반복 제한**: 피드백 루프는 최대 2회. 초과 시 사용자 에스컬레이션
4. **문서 = 진실의 원천**: 결정 사항은 반드시 문서에 반영합니다

---

## Phase별 양방향 통신 패턴

### Research Phase

| 상호작용 | 방향 | 트리거 | 반환 형식 |
|-----------|------|--------|-----------|
| research-director → CTO 통합 평가 | CTO 단독 리뷰 (아키텍처 + 복잡도) | research.md 작성 완료 | JSON (verdict/complexity) |
| CTO BLOCK → clarify 재호출 | 양방향 피드백 | verdict == "BLOCK" | clarify Skill 재실행 |
| CTO CONCERN → 사용자 | 에스컬레이션 | verdict == "CONCERN" or complexity == "High" | AskUserQuestion |
| CTO prerequisites → 사용자 | 사전 준비 안내 | prerequisites 있음 | 사용자 알림 (진행 계속) |

**CTO 통합 평가 결과 형식:**
```json
{
  "verdict": "PASS | CONCERN | BLOCK",
  "complexity": "Low | Medium | High",
  "concerns": [], "risks": [], "prerequisites": [],
  "recommendations": [], "affectedModules": []
}
```

### Plan Phase

| 상호작용 | 방향 | 트리거 | 반환 형식 |
|-----------|------|--------|-----------|
| PO → CTO 타당성 스캔 | CTO가 user-story 검증 | user-story.md 작성 완료 | PASS/WARN/BLOCK |
| CTO BLOCK → PO 재호출 | 양방향 피드백 | CTO verdict == "BLOCK" | PO가 user-story 수정 |
| CTO 라우팅 → Scope Mismatch → PO | 양방향 피드백 | platform ≠ user-story scope | PO 보완 + 사용자 재승인 |
| Research Decision Points → PO | 단방향 전달 | research.md 존재 시 | PO가 user-story에 반영 |

**CTO 타당성 스캔 결과:**
- `PASS`: user-story.md에 `<!-- CTO Feasibility: PASS -->` 주석
- `WARN`: user-story.md에 `## CTO 기술 검토 메모` 섹션 추가
- `BLOCK`: PO 재호출 → user-story 수정 → CTO 재스캔 (max 2회)

### Design Phase

| 상호작용 | 방향 | 트리거 | 반환 형식 |
|-----------|------|--------|-----------|
| tech-lead → designer Pushback | 양방향 피드백 | brief.md에 "## Design Pushback" | designer가 design-spec 수정 |
| API Contract → server tech-lead 검증 | 양방향 피드백 | api-contract.md 생성 완료 | JSON (verdict/mismatches) |
| API Contract → frontend tech-lead 검증 | 양방향 피드백 | api-contract.md 생성 완료 | JSON (verdict/gaps) |
| tech-lead 검증 REVISE → CTO | 양방향 피드백 | verdict == "REVISE" | CTO가 api-contract 수정 |

**Design Pushback 형식** (brief.md 내):
```markdown
## Design Pushback
### 항목 1: [문제 요소]
- 문제점: ...
- 대안: ...
- 복잡도 영향: Low/Medium/High
```

**API Contract 검증 형식:**
```json
// Server Tech Lead
{ "verdict": "PASS | REVISE", "mismatches": [{"endpoint": "", "issue": "", "fix": ""}], "additions": [] }
// Frontend Tech Lead
{ "verdict": "PASS | REVISE", "gaps": [{"screen": "", "neededData": "", "missingFrom": ""}], "suggestions": [] }
```

### Do Phase

| 상호작용 | 방향 | 트리거 | 반환 형식 |
|-----------|------|--------|-----------|
| developer → BLOCKED:QUESTIONS | 개발자 → CTO | 자가 해결 3단계 실패 | Markdown (아래 형식) |
| CTO → 답변 에이전트 라우팅 | CTO → 해당 에이전트 | BLOCKED 수신 | 라우팅 테이블 참조 |
| 답변 → developer 재개 | 답변자 → 개발자 | 답변 완료 | ANSWER 형식 |

### Analyze Phase

| 상호작용 | 방향 | 트리거 | 반환 형식 |
|-----------|------|--------|-----------|
| gap-detector → CTO 리뷰 | CTO 통합 리뷰 | analysis.md 작성 완료 | cto-review.md |
| CTO → 해당 에이전트 수정 지시 | 양방향 피드백 | 리뷰에서 이슈 발견 | FINDINGS 구조화 |

---

## 자가 해결 3단계 (질문 전 필수)

에이전트가 "모르겠다"는 상황을 만나면 **질문하기 전에** 아래 3단계를 순서대로 시도합니다.

### Step 1: 문서 확인

현재 작업과 관련된 설계 문서를 재확인합니다:

```
Read("docs/{product}/{feature}/[server-|mobile-|web-]brief.md")
Read("docs/{product}/{feature}/[mobile-|web-]design-spec.md")
Read("docs/{product}/{feature}/api-contract.md")
```

- brief.md에 답이 있는 경우가 대부분입니다
- API 스펙 관련이면 api-contract.md를 먼저 확인합니다

### Step 2: 과거 결정 검색

claude-mem에서 유사한 결정이나 패턴을 검색합니다:

```
search(query="{관련 키워드}", limit=5)
```

- 이전 세션에서 동일 문제를 해결한 기록이 있을 수 있습니다
- 검색 키워드는 구체적으로: "인증 토큰 갱신", "에러 응답 형식" 등

### Step 3: 기존 코드 패턴 확인

serena를 사용하여 기존 코드에서 유사 구현을 참조합니다:

```
find_symbol(name_path_pattern="{관련 심볼}", include_body=true)
get_symbols_overview(relative_path="{관련 파일}")
search_for_pattern(substring_pattern="{패턴}")
```

- 기존에 동일/유사한 패턴이 이미 구현되어 있을 수 있습니다
- 기존 구현의 관례(네이밍, 에러 처리 방식 등)를 따릅니다

---

## 구조화된 질문 반환

3단계를 모두 시도했으나 해결이 안 되면, 작업을 중단하고 아래 형식으로 반환합니다.
**가능한 작업은 계속 진행하고 막힌 부분만 BLOCKED 처리합니다.**

```markdown
## BLOCKED: QUESTIONS

### Q1: [질문 제목]
- **맥락**: 무엇을 하려다 막혔는지
- **모호한 점**: 구체적으로 무엇이 불명확한지
- **시도한 것**: 자가 해결 3단계에서 확인한 내용
- **선택지**: 가능한 해석 A, B (있다면)
- **추천 에이전트**: 이 질문에 답할 수 있을 것 같은 에이전트

### Q2: [다른 질문이 있다면]
...
```

### 예시

```markdown
## BLOCKED: QUESTIONS

### Q1: 프로필 이미지 업로드 API 응답 형식
- **맥락**: 프로필 편집 화면에서 이미지 업로드 후 서버 응답을 처리하려 함
- **모호한 점**: server-brief.md에 업로드 API는 있으나 응답에 이미지 URL 필드명이 명시되지 않음
- **시도한 것**:
  - brief.md 3섹션 확인 → 응답 형식 미기재
  - claude-mem에서 "이미지 업로드 응답" 검색 → 결과 없음
  - serena로 기존 업로드 코드 검색 → 아직 구현 없음
- **선택지**:
  - A: `{ imageUrl: string }` (단순)
  - B: `{ imageUrl: string, thumbnailUrl: string, size: number }` (상세)
- **추천 에이전트**: server/tech-lead (API 스펙 결정 권한)
```

---

## 답변 형식

BLOCKED: QUESTIONS에 대한 답변은 아래 형식으로 반환합니다:

```markdown
## ANSWER: Q1
- **결정**: [선택한 방안]
- **근거**: [왜 이 결정인지]
- **반영할 문서**: [brief.md | design-spec.md | api-contract.md] (해당 시)
```

---

## CTO 질문 라우팅 테이블

CTO가 `BLOCKED: QUESTIONS`를 수신했을 때 질문 유형별로 적절한 답변자를 결정합니다.

| 질문 유형 | 1차 답변자 | 2차 답변자 |
|-----------|-----------|-----------|
| API 스펙 불명확 | server/tech-lead | node-developer (기존 구현 참조) |
| UI 요구사항 불명확 | ui-ux-designer | tech-lead |
| DB 스키마 관련 | schema-designer | server/tech-lead |
| 기존 코드 동작 방식 | 해당 플랫폼 developer | tech-lead |
| 디자인 시스템 관련 | design-specialist | ui-ux-designer |
| 크로스 플랫폼 의존성 | CTO 직접 판단 | — |
| 비즈니스 요구사항 불명확 | product-owner | 사용자 에스컬레이션 |
| 인프라/배포 관련 | CTO 직접 판단 | — |

**PO 재호출 컨텍스트 규칙:**
Do/Iterate 단계에서 PO를 재호출할 때는 반드시 아래 컨텍스트를 포함합니다:
- `docs/{product}/{feature}/user-story.md` (원본 사용자 스토리)
- `docs/{product}/{feature}/{platform}-brief.md` (현재 설계)
- BLOCKED:QUESTIONS 원문 (개발자가 제출한 질문)
- 이유: PO는 비즈니스 맥락이 없으면 기술적 질문에 적절히 답변할 수 없음

---

## 에스컬레이션 규칙

양방향 피드백 루프가 해결되지 않을 때:

| 상황 | 에스컬레이션 대상 | 방법 |
|------|------------------|------|
| 피드백 루프 2회 초과 | 사용자 | `AskUserQuestion`으로 옵션 제시 |
| 에이전트 간 의견 불일치 | 사용자 | 양측 의견 요약 + 선택지 제시 |
| 기술적 불확실성 | 사용자 | 리스크 설명 + 진행/중단/대안 선택 |
| 비용/정책 결정 | 사용자 | 옵션별 비용/장단점 비교 |

---

## 대화 원칙

- 친절하되 **확인된 사실만** 이야기한다
- 추측은 "~일 수 있습니다"로 명시한다
- 출처를 밝힌다: "brief.md 3섹션에 따르면..."
- 질문은 구체적으로: "에러 처리를 어떻게 할까요?" ❌ → "401 응답 시 토큰 갱신을 자동으로 할지, 로그인 화면으로 이동할지?" ✅
