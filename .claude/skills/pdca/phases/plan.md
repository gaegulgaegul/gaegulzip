# plan (Plan Phase) — PO Agent → interactive-review → CTO Agent

**Step 0: 아이디어 브레인스토밍 (MANDATORY — PO 호출 전)**

사용자의 초기 아이디어가 모호하거나 구체화가 필요한 경우, PO 에이전트 호출 **전에** `clarify` Skill을 반드시 실행하여 요구사항을 명확히 합니다.

```
Skill("clarify", args="""
Feature idea: {user's initial description}

소크라테스 질문법으로 아이디어를 구체화합니다:
- 핵심 사용자는 누구인가?
- 어떤 문제를 해결하는가?
- 성공 기준은 무엇인가?
- 범위(scope)는 어디까지인가?
""")
```

> **규칙**: research 단계 또는 plan 시작 시 아이디어 브레인스토밍이 필요하면 **반드시** `clarify` Skill을 먼저 실행합니다. clarify 없이 바로 PO를 호출하지 않습니다.

**Step 1: Product Owner creates unified user story**

Call `product-owner` agent via Task tool.

> **Research Integration Gate**: research.md가 존재하면 PO prompt에 반드시 포함합니다.
> 특히 "Decision Points (PO 필독)" 섹션의 각 DP에 대한 결정을 user-story에 반영해야 합니다.

```
# research.md 존재 여부 확인
Glob("docs/{product}/{feature}/research.md")

Task(subagent_type="product-owner", prompt="""
Feature: {feature}
Context: [PRD, research docs, or user's description]
Clarified Requirements: [clarify skill 결과 요약]

{if research.md exists}
Research: docs/{product}/{feature}/research.md
IMPORTANT: research.md의 "## Decision Points (PO 필독)" 섹션을 반드시 읽고,
각 Decision Point에 대한 결정을 user-story의 "## 비즈니스 규칙" 또는 "## 비기능 요구사항"에 반영하세요.
Decision Point를 무시하거나 누락하지 마세요.
{endif}

Create a unified user story focusing on WHAT (user needs), not HOW (technical implementation).
Do NOT determine platform yet. Do NOT include API specs or UI details.

Output: docs/{product}/{feature}/user-story.md
""")
```

**Step 1.3: CTO 경량 타당성 스캔 (PO 완료 후, 사용자 승인 전)**

PO가 user-story.md를 작성한 후, 사용자에게 보여주기 **전에** CTO가 기술 타당성만 빠르게 확인합니다.
이 단계는 플랫폼 라우팅(Step 2)과 별개로, "이 요구사항이 기술적으로 실현 가능한가?"만 판단합니다.

```
Task(subagent_type="cto", prompt="""
Feature: {feature}

PO가 user-story.md를 작성했습니다. 사용자 승인 전에 기술 타당성을 빠르게 검증합니다.
Read: docs/{product}/{feature}/user-story.md

아래 3가지만 확인합니다 (5분 이내 완료):
1. **기술적 실현 가능성**: 현재 기술 스택(Express/Flutter/Next.js)으로 구현 가능한가?
2. **외부 의존성 위험**: 필요한 외부 서비스/SDK가 있는가? 비용/제약은?
3. **범위 적절성**: MVP로 적절한 크기인가? 과대한 범위는 아닌가?

판정:
- **PASS**: 기술적 문제 없음 → user-story.md에 "<!-- CTO Feasibility: PASS -->" 주석 추가
- **WARN**: 주의 사항 있음 → user-story.md 끝에 "## CTO 기술 검토 메모" 섹션 추가 (사용자가 리뷰 시 함께 확인)
- **BLOCK**: 근본적 문제 → PO에게 수정 요청 사항을 반환 (user-story.md에 반영 후 Step 1.3 재실행)

NOTE: 플랫폼 결정은 하지 않습니다. Step 2에서 별도로 진행합니다.
""")
```

> **BLOCK 시 처리**: CTO가 BLOCK을 반환하면 PO를 재호출하여 user-story를 수정합니다.
> 수정 후 Step 1.3을 재실행합니다. 최대 2회 반복 후에도 BLOCK이면 사용자에게 에스컬레이션합니다.

**Step 1.5: 사용자 승인 (MANDATORY — interactive-review 사용)**

PO가 user-story.md를 작성하고 CTO 타당성 스캔을 통과한 후, **반드시** `interactive-review:review` Skill로 사용자 검토를 받습니다.

```
Skill("interactive-review:review", args="""
title: "[Plan Review] {feature} 사용자 스토리"
content: docs/{product}/{feature}/user-story.md
""")
```

> **규칙**: 사용자가 리뷰에서 수정을 요청하면 PO를 재호출하여 반영 후 다시 리뷰를 요청합니다. 승인(approve) 후에만 Step 2로 진행합니다.

**Step 2: CTO determines platform**

After user approval, call `cto` agent via Task tool:

```
Task(subagent_type="cto", prompt="""
Feature: {feature}

PO has written user story (user approved). Read it and perform platform routing:
- Read docs/{product}/{feature}/user-story.md

Execute your ⓪ 플랫폼 라우팅 (4-step routing) to determine: Server / Mobile / Fullstack.

Output your decision. The result will be stored in .pdca-status.json as "platform".
""")
```

**Step 2.5: Scope Mismatch 감지 (CTO 라우팅 직후)**

CTO의 플랫폼 결정이 user-story의 암시적 범위와 다를 경우를 감지합니다.

```
# Mismatch 조건:
# - user-story가 "모바일 화면" 위주인데 CTO가 Fullstack 결정 → 서버 요구사항 누락 가능
# - user-story가 단일 플랫폼만 언급하는데 CTO가 Fullstack 결정 → 범위 확장 필요
# - user-story에 "API", "데이터 저장" 언급 없는데 CTO가 Server 포함 결정

if CTO_platform != user_story_implied_scope:
    # CTO가 mismatch를 감지하면:
    # 1. user-story.md 끝에 "## Scope 확장 메모 (CTO)" 섹션 추가
    #    - 왜 scope가 확장/변경되었는지 설명
    #    - user-story에 추가되어야 할 요구사항 목록
    # 2. PO 재호출하여 user-story 보완
    # 3. interactive-review로 사용자 재승인

    Task(subagent_type="product-owner", prompt="""
    Feature: {feature}
    기존 user-story: docs/{product}/{feature}/user-story.md

    CTO가 플랫폼을 {platform}으로 결정했습니다.
    user-story.md 하단의 "## Scope 확장 메모 (CTO)" 섹션을 읽고,
    누락된 요구사항을 user-story에 반영하세요.
    기존 사용자 스토리 구조를 유지하면서 보완합니다.
    """)

    # 보완된 user-story를 사용자에게 재승인 요청
    Skill("interactive-review:review", args="""
    title: "[Plan 재승인] {feature} — 범위 변경"
    content: docs/{product}/{feature}/user-story.md
    """)
```

> **Mismatch가 없으면 이 단계를 건너뜁니다.**
> CTO는 Step 2에서 mismatch 여부를 판단하여, 불일치가 있을 때만 "## Scope 확장 메모 (CTO)" 섹션을 작성합니다.

**Step 3: Update status**

```json
{
  "features": {
    "{feature}": {
      "phase": "plan",
      "platform": "{CTO's decision}",
      "startedAt": "now",
      "documents": {
        "plan": "docs/{product}/{feature}/user-story.md"
      }
    }
  }
}
```

**Step 4: Create Task**

`TaskCreate: [Plan] {feature}` → status: completed
