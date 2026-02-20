# 에이전트 간 통신 프로토콜

> 에이전트가 구현 중 모호한 상황을 만났을 때, 자가 해결을 시도하고 실패 시 구조화된 질문으로 반환하는 표준 절차.

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

---

## 대화 원칙

- 친절하되 **확인된 사실만** 이야기한다
- 추측은 "~일 수 있습니다"로 명시한다
- 출처를 밝힌다: "brief.md 3섹션에 따르면..."
- 질문은 구체적으로: "에러 처리를 어떻게 할까요?" ❌ → "401 응답 시 토큰 갱신을 자동으로 할지, 로그인 화면으로 이동할지?" ✅
