# research (Research Phase) — clarify Skill → research-director Agent → Feasibility Council

**Step 1: clarify Skill로 아이디어 브레인스토밍 (필수)**

```
Skill("clarify", args="{feature} — {user's description}")
```

> clarify Skill은 소크라테스식 질문법으로 모호한 아이디어를 구체화합니다.
> 사용자의 요구사항이 충분히 명확해질 때까지 질의응답을 진행합니다.

**clarify 진행 시 필수 원칙**:
- **가정 도전**: 사용자의 가정을 식별하고 적극적으로 질문. "정말 그 기능이 필요한가? 어떤 문제를 해결하는가?"
- **MVP 스코핑**: "Must Have v1" vs "Nice to Have v2"를 반드시 분류. 범위가 너무 넓으면 더 작고 현실적인 시작점을 제안.
- **복잡도 투명성**: "이 기능은 간단/보통/도전적입니다. 이유는 ~~"와 같이 복잡도를 솔직하게 전달.
- **사전 준비 식별**: 필요한 외부 서비스, 계정, API 키 등을 미리 파악하여 사용자에게 알림.

**Step 2: research-director Agent로 기술 조사**

clarify로 요구사항이 구체화된 후, 기술 조사를 진행합니다:

```
Task(subagent_type="bkit:research-director", prompt="""
Feature: {feature}
Context: [clarify 결과 요약]

Perform technical research for this feature.

IMPORTANT: research.md 마지막에 반드시 "## Decision Points (PO 필독)" 섹션을 포함하세요.
각 Decision Point는 아래 형식으로 작성합니다:

### DP-N: [결정 제목]
- **옵션**: A) ... / B) ...
- **제약**: [기술적/비용적/정책적 제약]
- **권장**: [조사 기반 권장안과 근거]
- **PO 결정 필요**: [PO가 판단해야 할 구체적 질문]

Decision Point가 될 수 있는 항목:
- 유료 서비스 의존성 (비용 영향)
- 복수 기술 옵션 (OAuth vs Magic Link 등)
- 플랫폼 정책 제약 (App Store 규정 등)
- MVP 범위에 영향을 주는 기술적 발견

Decision Point가 없으면 "## Decision Points (PO 필독)\n\n조사 결과 별도 결정 필요 사항 없음."으로 작성합니다.

Output: docs/{product}/{feature}/research.md
""")
```

**Step 2.5: Feasibility Council (research-director 완료 후)**

research-director가 research.md를 작성한 후, CTO가 **아키텍처 적합성 + 구현 복잡도**를 통합 평가합니다.

> 이 단계는 Plan에서 user-story를 작성하기 전에 기술적 리스크를 조기에 발견하기 위한 것입니다.
> Plan Step 1.3의 CTO 타당성 스캔은 user-story 기반이지만, 이 단계는 raw research 기반이므로 더 기술적입니다.

```
# CTO: 아키텍처 적합성 + 인프라 제약 + 구현 복잡도 통합 평가
Task(subagent_type="cto", prompt="""
Role: Research Feasibility Reviewer (NOT full CTO role — 경량 리뷰만)
Feature: {feature}
Research: docs/{product}/{feature}/research.md

아래 관점에서 간결하게 리뷰합니다:

[아키텍처 & 인프라]
1. **아키텍처 적합성**: 현재 모노레포 구조(Express/Flutter/Next.js)에 맞는가?
2. **인프라 제약**: Supabase Free, Vercel Hobby 플랜 제약에 걸리는가?
3. **기존 모듈 영향**: 기존 구현과 충돌하거나 중복되는 부분이 있는가?

[구현 복잡도]
4. **구현 복잡도**: Low / Medium / High (근거 포함)
5. **핵심 기술 리스크**: 구현 시 가장 어려운 부분
6. **사전 준비 사항**: 필요한 외부 SDK, API 키, 유료 서비스

Output format (JSON):
{
  "verdict": "PASS | CONCERN | BLOCK",
  "complexity": "Low | Medium | High",
  "concerns": ["문제1", "문제2"],
  "risks": ["기술 리스크1"],
  "prerequisites": ["사전준비1"],
  "recommendations": ["권장사항1"],
  "affectedModules": ["module1"],
  "uncertaintyMap": {
    "confident": ["자신있는 판단과 근거"],
    "maybeOversimplified": ["단순화했을 수 있는 부분"],
    "couldChangeWith": ["이 정보가 있으면 판단이 달라질 수 있음"]
  }
}

NOTE: 5분 이내 완료. 상세 설계는 하지 않습니다.
""")
```

**Step 2.7: Council 결과 종합 + 양방향 피드백**

CTO 평가 결과를 research.md에 추가하고, 문제가 있으면 이전 단계로 피드백합니다.

```
# CTO 평가 결과를 research.md에 추가
# research.md 끝에 "## Feasibility Review" 섹션 작성:
## Feasibility Review

### CTO 통합 평가
- Verdict: {PASS/CONCERN/BLOCK}
- Complexity: {Low/Medium/High}
- Concerns: {concerns}
- Risks: {risks}
- Prerequisites: {prerequisites}
- Recommendations: {recommendations}

### 불확실성 지도
- **자신있는 판단**: {confident} — 근거가 명확하여 확신도 높음
- **단순화했을 수 있는 부분**: {maybeOversimplified} — 실제로는 더 복잡할 수 있음
- **의견이 바뀔 수 있는 조건**: {couldChangeWith} — 이 정보가 추가되면 판단이 달라질 수 있음
```

**양방향 피드백 규칙:**

| CTO 평가 결과 | 동작 |
|-------------|------|
| PASS + Low/Medium complexity | → Step 3으로 진행 |
| CONCERN 또는 High complexity | → `AskUserQuestion`으로 사용자에게 리스크 고지 + 진행 여부 확인 |
| BLOCK | → clarify Skill 재호출 (스코프 축소/변경 논의) → research-director 재호출 → Council 재실행 (max 2회) |
| prerequisites 있음 | → 사용자에게 사전 준비 사항 안내 (진행은 계속) |

```
if cto_verdict == "BLOCK":
    # 양방향: research → clarify로 되돌아감
    Skill("clarify", args="""
    Feature: {feature}

    기술 조사 결과 다음 문제가 발견되었습니다:
    - Verdict: {block_reason}
    - Risks: {risks}

    이 제약을 고려하여 스코프를 조정하거나 대안을 논의합니다.
    """)
    # clarify 완료 후 research-director 재호출 (Step 2부터 재실행)
    # max 2회 반복 후에도 BLOCK이면 사용자에게 에스컬레이션

elif cto_verdict == "CONCERN" or complexity == "High":
    AskUserQuestion(
      question: "기술 조사 결과 다음 리스크가 발견되었습니다:\n{concerns}\n\n이대로 진행할까요?",
      options: [
        "진행 (리스크 수용)",
        "스코프 조정 (clarify 재실행)",
        "중단"
      ]
    )
```

**Step 3: Update status**

```json
{ "phase": "research", "documents": { "research": "docs/{product}/{feature}/research.md" } }
```
