# do (Do Phase) — CTO Distribution → Dev Agents

**Step 0: Prerequisite Validation (MANDATORY — before any agent call)**

CTO를 호출하기 **전에** 아래 선행조건을 모두 검증합니다. 하나라도 누락되면 **즉시 중단**하고 사용자에게 원인을 알려줍니다.

```
# 1. 플랫폼 결정 여부 확인
Read(".pdca-status.json") → features.{feature}.platform
IF platform is missing or empty:
  ❌ STOP — 사용자에게 알림:
  "Do 단계를 실행할 수 없습니다.
   원인: 플랫폼이 결정되지 않았습니다. Plan 단계에서 CTO가 플랫폼 라우팅을 완료해야 합니다.
   해결: `/pdca plan {feature}`를 먼저 실행하세요."

# 2. Plan 문서 존재 확인
Glob("docs/{product}/{feature}/user-story.md")
IF not found:
  ❌ STOP — 사용자에게 알림:
  "Do 단계를 실행할 수 없습니다.
   원인: user-story.md가 없습니다. Plan 단계가 완료되지 않았습니다.
   해결: `/pdca plan {feature}`를 먼저 실행하세요."

# 3. Design 문서 존재 확인 (플랫폼별)
IF platform == "server" or "fullstack":
  Glob("docs/{product}/{feature}/server-brief.md")
  IF not found:
    ❌ STOP — "원인: server-brief.md가 없습니다. Design 단계가 완료되지 않았습니다.
     해결: `/pdca design {feature}`를 먼저 실행하세요."

IF platform == "mobile" or (platform == "fullstack" and frontendType == "mobile"):
  Glob("docs/{product}/{feature}/mobile-brief.md")
  Glob("docs/{product}/{feature}/mobile-design-spec.md")
  IF either not found:
    ❌ STOP — "원인: mobile-brief.md 또는 mobile-design-spec.md가 없습니다. Design 단계가 완료되지 않았습니다.
     해결: `/pdca design {feature}`를 먼저 실행하세요."

IF platform == "web" or (platform == "fullstack" and frontendType == "web"):
  Glob("docs/{product}/{feature}/web-brief.md")
  Glob("docs/{product}/{feature}/web-design-spec.md")
  IF either not found:
    ❌ STOP — "원인: web-brief.md 또는 web-design-spec.md가 없습니다. Design 단계가 완료되지 않았습니다.
     해결: `/pdca design {feature}`를 먼저 실행하세요."

# ✅ 모든 선행조건 충족 → Step 0.5로 진행
```

**Step 0.5: 설계 리뷰 (MANDATORY — plan-review Skill)**

구현 전 설계 품질을 자동으로 검증합니다:

```
Skill("plan-review", args="design {feature}")
# 리뷰 결과에서 Action Items가 있으면 Design 문서 수정 후 재진행
```

> plan-review Skill 내부에서 BIG/SMALL CHANGE 선택을 받습니다.
> 참조: `.claude/skills/plan-review/SKILL.md`

**Step 1: CTO creates work plan**

```
Task(subagent_type="cto", prompt="""
Feature: {feature}
Platform: {platform from status}

Read design documents and create work distribution plan.
Determine how to split work between developers.
Define parallel/sequential execution order.
Define module contracts (Controller ↔ View connections).

Output: docs/{product}/{feature}/{platform}-work-plan.md
(For fullstack: server-work-plan.md + frontend work-plan based on frontendType:
  mobile → mobile-work-plan.md, web → web-work-plan.md)
""")
```

**Step 1.5: work-plan 사용자 승인 (MANDATORY)**

CTO가 work-plan.md를 작성한 후, 구현 시작 전에 사용자에게 실행 계획을 요약 보고하고 승인을 받습니다.

```
# work-plan.md 요약을 사용자에게 보고
# 포함 내용: 실행 그룹 수, 투입 에이전트, 예상 작업 범위, 핵심 결정 사항

AskUserQuestion(
  question: "위 작업 계획대로 진행할까요?",
  options: [
    "진행 (Recommended)",
    "수정 요청"
  ]
)
```

> **규칙**: 사용자가 "수정 요청"을 선택하면 피드백을 반영하여 CTO가 work-plan을 수정한 후 다시 승인을 요청합니다.
> 사용자가 문제를 발견하면 즉시 반영. 구현 시작 후 되돌리는 것보다 계획 단계에서 수정하는 것이 훨씬 효율적.

**Step 1.7: 실행 모드 선택 (MANDATORY)**

작업 계획 승인 후, 실행 방식을 선택합니다:

```
AskUserQuestion(
  question: "구현 실행 모드를 선택해주세요.",
  options: [
    "CTO 관리형 (Recommended)" — CTO가 에이전트 간 작업 분배·조율,
    "Ralph Loop 자율형" — 단일 에이전트가 반복 루프로 자율 구현
  ]
)
```

**실행 모드 가이드라인:**

| 상황 | 권장 모드 | 이유 |
|------|----------|------|
| 멀티모듈 (server + frontend) | CTO 관리형 | 에이전트 간 계약·순서 조율 필요 |
| 단일 모듈 (한 플랫폼만) | Ralph Loop 자율형 | 조율 오버헤드 불필요, 빠른 반복 |
| 기존 코드 수정 / 버그 수정 | Ralph Loop 자율형 | 단일 컨텍스트에서 수정→검증 반복이 효율적 |
| 신규 기능 + 복잡한 의존성 | CTO 관리형 | 파일 충돌 방지, 통합 테스트 조율 |

**Ralph Loop 실행 시:**
```
# 1. 프롬프트 구성
PROMPT = """
Feature: {feature}
Brief: docs/{product}/{feature}/{platform}-brief.md
Work Plan: docs/{product}/{feature}/{platform}-work-plan.md

위 문서를 읽고 work-plan의 모든 항목을 구현하세요.
구현 완료 후 검증 명령어를 실행하세요:
- Server: pnpm test && pnpm build
- Mobile: melos analyze
- Web: pnpm build && pnpm lint

모든 검증을 통과하면 <promise>IMPLEMENTATION COMPLETE</promise>를 출력하세요.
"""

# 2. Ralph Loop 시작
Skill("ralph-loop:ralph-loop", args="{PROMPT} --max-iterations 15 --completion-promise 'IMPLEMENTATION COMPLETE'")

# 3. 완료 후 → analyze 단계로 진행
```

> **주의**: Ralph Loop 모드에서는 CTO 통합 리뷰가 생략됩니다. analyze 단계에서 gap-detector가 품질을 검증합니다.

**Step 1.9: 양방향 통신 프로토콜 안내 (개발자 에이전트 공통)**

모든 개발자 에이전트(node-developer, flutter-developer, react-developer)는 구현 중 모호한 상황을 만나면
`.claude/guide/agent-communication-protocol.md`의 **자가 해결 3단계 → BLOCKED: QUESTIONS** 프로토콜을 따릅니다.

```
# 개발자 에이전트 프롬프트에 반드시 포함:
"""
구현 중 설계 문서에 없거나 모호한 부분을 만나면:
1. brief.md, design-spec.md, api-contract.md를 재확인
2. claude-mem에서 유사 결정 검색
3. serena로 기존 코드 패턴 확인

3단계를 모두 시도해도 해결 안 되면, 가능한 작업은 계속하고
막힌 부분만 아래 형식으로 반환하세요:

## BLOCKED: QUESTIONS
### Q1: [질문 제목]
- 맥락: ...
- 모호한 점: ...
- 시도한 것: ...
- 선택지: A) ... / B) ...
- 추천 에이전트: ...
"""
```

**BLOCKED: QUESTIONS 수신 시 CTO 처리 흐름:**

```
if developer returns "BLOCKED: QUESTIONS":
    # CTO가 질문 유형별로 라우팅 (agent-communication-protocol.md의 라우팅 테이블 참조)
    # 1. 적절한 에이전트에게 질문 전달
    Task(subagent_type="{routing_table[question_type]}", prompt="""
    개발자가 구현 중 아래 질문을 반환했습니다:
    {blocked_questions}

    해당 질문에 대해 답변하세요. 답변 형식:
    ## ANSWER: Q{N}
    - 결정: ...
    - 근거: ...
    - 반영할 문서: {brief.md | design-spec.md | api-contract.md} (해당 시)
    """)

    # 2. 답변을 개발자에게 전달하여 구현 재개
    # 방법 A: 에이전트 resume (선호 — 이전 컨텍스트 보존)
    if developer_agent_id is available:
        Task(subagent_type="{developer}", resume="{developer_agent_id}", prompt="""
        이전 BLOCKED: QUESTIONS에 대한 답변입니다:
        {answers}

        답변을 반영하여 구현을 계속하세요.
        """)

    # 방법 B: 파일 기반 fallback (resume 불가 시 — 새 에이전트에 컨텍스트 전달)
    else:
        Task(subagent_type="{developer}", prompt="""
        이전 개발자가 구현 중 BLOCKED 상태가 되어 새로 시작합니다.

        참조 문서:
        - Brief: docs/{product}/{feature}/{platform}-brief.md
        - Work Plan: docs/{product}/{feature}/{platform}-work-plan.md
        - 이전 작업물: {developer's previous output or git diff}

        BLOCKED QUESTIONS 답변:
        {answers}

        답변을 반영하여 구현을 계속하세요.
        이전 작업물에서 이어서 진행하되, 이미 완료된 부분은 건드리지 마세요.
        """)

    # 3. 필요 시 설계 문서 업데이트 (향후 동일 문제 방지)
    if answer requires document update:
        # 해당 문서 수정 (brief.md, api-contract.md 등)
```

> **참조**: `.claude/guide/agent-communication-protocol.md` — 자가 해결 3단계, 구조화된 질문 형식, CTO 라우팅 테이블 상세

**Step 2: Read work-plan.md and invoke agents per execution group**

CTO가 작성한 work-plan.md에서 **실행 그룹(execution groups)**을 읽고, 그룹 단위로 Task를 호출합니다.

**핵심 규칙**:
- 같은 실행 그룹의 Task는 **반드시 하나의 메시지에서 동시 호출** (병렬 실행)
- 다음 실행 그룹은 **이전 그룹의 모든 Task 완료 후** 호출 (순차 대기)
- 개발자는 1~N명까지 투입 가능 (Sub Agent 최대 100개)
- Server와 Mobile 개발자가 같은 그룹에 섞일 수 있음 (크로스 플랫폼 병렬)

```
# 1. work-plan.md 읽기
Read("docs/{product}/{feature}/{platform}-work-plan.md")
# (Fullstack인 경우 server-work-plan.md + frontend work-plan 모두 읽기:
#  frontendType == "mobile" → mobile-work-plan.md
#  frontendType == "web" → web-work-plan.md)

# 2. 실행 그룹별 병렬 Task 호출

# ── Group 1 (병렬): 하나의 메시지에서 모든 Task 동시 호출 ──
Task(subagent_type="node-developer", prompt="... module A ...")
Task(subagent_type="flutter-developer", prompt="... mobile module (API 비의존) ...")

# ── Group 1 완료 대기 ──

# ── Group 2 (병렬): Group 1 완료 후 동시 호출 ──
Task(subagent_type="flutter-developer", prompt="... module (Server API 의존) ...")

# ── 모든 그룹 완료까지 반복 ──
```

**실행 그룹이 1개뿐인 단순한 경우** (모듈 분리 불필요):
```
# Server만
Task(subagent_type="node-developer", prompt="Feature + Work Plan + Brief → TDD cycle")

# Mobile만
Task(subagent_type="flutter-developer", prompt="Feature + Work Plan + Brief + Design Spec → implement")

# Web만
Task(subagent_type="react-developer", prompt="Feature + Work Plan + Brief + Design Spec → Next.js + shadcn/ui + Playwright E2E")
```

**Step 3: Update status**

```json
{ "phase": "do" }
```

**Step 4: Generate test scenarios (Mobile/Fullstack only)**

> 모바일 플랫폼(mobile, fullstack)인 경우에만 실행합니다.

```
if platform in ["mobile", "fullstack"]:
    Skill("test-scenario-generator", args="{feature}")
```

Output: `docs/{product}/{feature}/mobile-test-scenarios.md`

이 문서는 이후 Analyze 단계에서 `independent-reviewer`가 검증에 사용합니다.

**Step 5: Create Task**

`TaskCreate: [Do] {feature}` (blockedBy: Design task)
