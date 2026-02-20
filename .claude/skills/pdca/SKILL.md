---
name: pdca
description: |
  Project-level PDCA skill override for gaegulzip.
  Integrates with project agents (CTO, PO, Tech Lead, etc.) and
  uses platform-specific document paths from bkit.config.json.

  Agent workflow per phase:
  - Research: clarify (Skill) → research-director (brainstorming + 조사)
  - Plan: PO → interactive-review:review (Skill, 사용자 승인) → CTO (platform routing)
  - Design: ui-ux-designer → frontend-design (Skill) → tech-lead (per frontend platform)
  - Do: CTO (work distribution) → node-developer + flutter-developer + react-developer → test-scenario-generator (mobile only)
  - Analyze: gap-detector + independent-reviewer (mobile) + CTO (integration review)
  - Iterate/Report: bkit agents

  Triggers: pdca, research, plan, design, analyze, report, status, next, iterate
argument-hint: "[action] [feature]"
user-invocable: true
agents:
  research-brainstorm: clarify (Skill)
  research-director: bkit/research-director
  plan: product-owner
  plan-review: interactive-review:review (Skill)
  routing: cto
  design-server: server/tech-lead
  design-mobile-ui: mobile/ui-ux-designer
  design-mobile-visual: frontend-design (Skill)
  design-mobile-tech: mobile/tech-lead
  design-web-ui: web/ui-ux-designer
  design-web-visual: frontend-design (Skill)
  design-web-tech: web/tech-lead
  do-distribute: cto
  do-server: server/node-developer
  do-mobile: mobile/flutter-developer
  do-web: web/react-developer
  test-scenario: test-scenario-generator
  analyze: bkit:gap-detector
  review: cto
  iterate: bkit:pdca-iterator
  report: bkit:report-generator
  verify: independent-reviewer
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TaskCreate
  - TaskUpdate
  - TaskList
  - AskUserQuestion
imports:
  - ${PLUGIN_ROOT}/templates/plan.template.md
  - ${PLUGIN_ROOT}/templates/design.template.md
  - ${PLUGIN_ROOT}/templates/do.template.md
  - ${PLUGIN_ROOT}/templates/analysis.template.md
  - ${PLUGIN_ROOT}/templates/report.template.md
  - ${PLUGIN_ROOT}/templates/iteration-report.template.md
next-skill: null
pdca-phase: null
task-template: "[PDCA] {feature}"
---

# PDCA Skill (gaegulzip Project Override)

> Unified Skill for managing PDCA cycle with **agent-integrated workflow**.
> Each PDCA phase automatically invokes the appropriate project agents from `bkit.config.json`.

## Config Reference

Read `bkit.config.json` to determine:
- `context.defaultLanguage` → **모든 출력(문서, 상태 메시지, 에이전트 응답)에 이 언어 사용**
- `pdca.planDocPaths` → document output paths
- `pdca.designDocPaths` → document output paths
- `pdca.analyzeDocPaths` → analysis document output paths
- `pdca.reportDocPaths` → report document output paths
- `platforms.{platform}.agents` → agent mapping per phase
- `pdca.statusFile` → `.pdca-status.json` path
- `pdca.matchRateThreshold` → 90 (default)
- `pdca.maxIterations` → 5 (default)

## Language Rule

**All output MUST be in the language specified by `bkit.config.json` → `context.defaultLanguage`.**
When calling agents via Task tool, always append to the prompt:
`\nIMPORTANT: Respond and write all documents in {defaultLanguage}. Code, paths, and technical terms stay in English.`

## Status Tracking

`.pdca-status.json` stores platform and phase per feature:

```json
{
  "features": {
    "{feature}": {
      "phase": "plan | design | do | check | act | completed | archived",
      "platform": "server | mobile | web | fullstack",
      "frontendType": "mobile | web",
      "startedAt": "ISO timestamp",
      "documents": {}
    }
  }
}
```

**IMPORTANT**:
- `platform` is determined during Plan phase by CTO and reused in all subsequent phases.
- `frontendType` is set when platform is `fullstack` to distinguish Mobile vs Web frontend agents.

---

## Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `research [feature]` | clarify → research-director | `/pdca research user-auth` |
| `plan [feature]` | PO → interactive-review → CTO routing | `/pdca plan user-auth` |
| `design [feature]` | Design docs (per platform) | `/pdca design user-auth` |
| `do [feature]` | CTO distribution → dev agents | `/pdca do user-auth` |
| `analyze [feature]` | Gap analysis + CTO review | `/pdca analyze user-auth` |
| `iterate [feature]` | Auto improvement | `/pdca iterate user-auth` |
| `report [feature]` | Completion report | `/pdca report user-auth` |
| `archive [feature]` | Archive documents | `/pdca archive user-auth` |
| `cleanup [feature]` | Cleanup archived | `/pdca cleanup` |
| `status` | Current status | `/pdca status` |
| `next` | Next phase guide | `/pdca next` |

---

## Phase Details

### research (Research Phase) — clarify Skill → research-director Agent

**Step 1: clarify Skill로 아이디어 브레인스토밍 (필수)**

```
Skill("clarify", args="{feature} — {user's description}")
```

> clarify Skill은 소크라테스식 질문법으로 모호한 아이디어를 구체화합니다.
> 사용자의 요구사항이 충분히 명확해질 때까지 질의응답을 진행합니다.

**Step 2: research-director Agent로 기술 조사**

clarify로 요구사항이 구체화된 후, 기술 조사를 진행합니다:

```
Task(subagent_type="bkit:research-director", prompt="""
Feature: {feature}
Context: [clarify 결과 요약]

Perform technical research for this feature.
Output: docs/{product}/{feature}/research.md
""")
```

**Step 3: Update status**

```json
{ "phase": "research", "documents": { "research": "docs/{product}/{feature}/research.md" } }
```

---

### plan (Plan Phase) — PO Agent → interactive-review → CTO Agent

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

Call `product-owner` agent via Task tool:

```
Task(subagent_type="product-owner", prompt="""
Feature: {feature}
Context: [PRD, research docs, or user's description]
Clarified Requirements: [clarify skill 결과 요약]

Create a unified user story focusing on WHAT (user needs), not HOW (technical implementation).
Do NOT determine platform yet. Do NOT include API specs or UI details.

Output: docs/{product}/{feature}/user-story.md
""")
```

**Step 1.5: 사용자 승인 (MANDATORY — interactive-review 사용)**

PO가 user-story.md를 작성한 후, **반드시** `interactive-review:review` Skill로 사용자 검토를 받습니다.

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

---

### design (Design Phase) — Platform-Based Agent Dispatch

**Step 1: Read platform from status**

```
Read .pdca-status.json → features.{feature}.platform
```

**Step 2: Call design agents based on platform**

| Platform | Agents | Output |
|----------|--------|--------|
| **Server** | `server/tech-lead` | `docs/{product}/{feature}/server-brief.md` |
| **Mobile** | `mobile/ui-ux-designer` → `frontend-design` (Skill) → `mobile/tech-lead` | `docs/{product}/{feature}/mobile-design-spec.md`, `docs/{product}/{feature}/mobile-brief.md` |
| **Web** | `web/ui-ux-designer` → `frontend-design` (Skill) → `web/tech-lead` | `docs/{product}/{feature}/web-design-spec.md`, `docs/{product}/{feature}/web-brief.md` |
| **Fullstack** | Server + frontend (Mobile or Web based on `frontendType`) | Both server + frontend docs |

**Server** — call `tech-lead` (server):
```
Task(subagent_type="tech-lead", prompt="""
Feature: {feature}
Platform: Server
User Story: docs/{product}/{feature}/user-story.md

Create technical design brief (including API specs, DB schema, business logic).
Output: docs/{product}/{feature}/server-brief.md
""")
```

**Mobile** — call `ui-ux-designer` first, then `frontend-design` skill, then `tech-lead` (mobile):
```
Task(subagent_type="ui-ux-designer", prompt="""
Feature: {feature}
User Story: docs/{product}/{feature}/user-story.md

Create design specification (including UI layouts, interactions, components).
Output: docs/{product}/{feature}/mobile-design-spec.md
""")

# After ui-ux-designer completes, invoke frontend-design skill:
Skill("frontend-design", args="""
Feature: {feature}
Design Spec: docs/{product}/{feature}/mobile-design-spec.md

Review and enhance the design spec with distinctive, production-grade visual design.
Apply high-quality UI patterns and creative aesthetics.
Update: docs/{product}/{feature}/mobile-design-spec.md
""")

# After frontend-design completes:
Task(subagent_type="tech-lead", prompt="""
Feature: {feature}
Platform: Mobile
User Story: docs/{product}/{feature}/user-story.md
Design Spec: docs/{product}/{feature}/mobile-design-spec.md

Create technical brief based on design spec.
Output: docs/{product}/{feature}/mobile-brief.md
""")
```

**Web** — call `ui-ux-designer` first, then `frontend-design` skill, then `tech-lead` (web):
```
Task(subagent_type="ui-ux-designer", prompt="""
Feature: {feature}
User Story: docs/{product}/{feature}/user-story.md

Create web UI/UX design specification (shadcn/ui components, Tailwind CSS, responsive layout).
Output: docs/{product}/{feature}/web-design-spec.md
""")

# After ui-ux-designer completes, invoke frontend-design skill:
Skill("frontend-design", args="""
Feature: {feature}
Design Spec: docs/{product}/{feature}/web-design-spec.md

Review and enhance the design spec with distinctive, production-grade visual design.
Apply high-quality UI patterns, creative aesthetics, and modern design trends.
Update: docs/{product}/{feature}/web-design-spec.md
""")

# After frontend-design completes:
Task(subagent_type="tech-lead", prompt="""
Feature: {feature}
Platform: Web
User Story: docs/{product}/{feature}/user-story.md
Design Spec: docs/{product}/{feature}/web-design-spec.md

Create technical brief (Next.js App Router, Server/Client Components, auth, API integration).
Output: docs/{product}/{feature}/web-brief.md
""")
```

**Fullstack** — run Server + frontend (Mobile or Web based on `frontendType`) in parallel where possible.
- `frontendType: "mobile"` → Server + Mobile agents
- `frontendType: "web"` → Server + Web agents

**Step 2.5: API Contract 생성 (Fullstack 전용)**

Fullstack 모드에서 server-brief.md 생성 후, frontend design 시작 전에 CTO가 api-contract.md를 생성합니다.
Frontend tech-lead는 brief 작성 시 이 문서를 참조합니다.

```
if platform == "fullstack":
    # server-brief.md 완료 후, frontend design 시작 전
    Task(subagent_type="cto", prompt="""
    Feature: {feature}
    Platform: Fullstack

    server-brief.md가 완료되었습니다.
    Read docs/{product}/{feature}/server-brief.md and create API Contract.

    API Contract에 포함할 내용:
    - 엔드포인트 목록 (method, path, auth)
    - 요청/응답 TypeScript 인터페이스
    - 인증 요구사항
    - 공유 타입 정의

    Output: docs/{product}/{feature}/api-contract.md
    """)
```

Frontend tech-lead 호출 시 api-contract.md 참조를 프롬프트에 추가:
```
Task(subagent_type="tech-lead", prompt="""
...
API Contract: docs/{product}/{feature}/api-contract.md
(이 문서의 엔드포인트와 타입을 참조하여 API 통합 설계)
...
""")
```

**Step 3: Update status**

```json
{ "phase": "design", "documents": { "design-server": "...", "design-mobile": "..." } }
```

**Step 4: Create Task**

`TaskCreate: [Design] {feature}` (blockedBy: Plan task)

---

### do (Do Phase) — CTO Distribution → Dev Agents

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

# ✅ 모든 선행조건 충족 → Step 1로 진행
```

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
Task(subagent_type="node-developer", prompt="""
Feature: {feature}
Module: {group1-module-A}
Work Plan: docs/{product}/{feature}/server-work-plan.md
Brief: docs/{product}/{feature}/server-brief.md

Implement module {group1-module-A} following TDD cycle.
""")

Task(subagent_type="node-developer", prompt="""
Feature: {feature}
Module: {group1-module-B}
Work Plan: docs/{product}/{feature}/server-work-plan.md
Brief: docs/{product}/{feature}/server-brief.md

Implement module {group1-module-B} following TDD cycle.
""")

Task(subagent_type="flutter-developer", prompt="""
Feature: {feature}
Module: {group1-mobile-module} (API 비의존 작업)
Work Plan: docs/{product}/{feature}/mobile-work-plan.md
Brief: docs/{product}/{feature}/mobile-brief.md
Design Spec: docs/{product}/{feature}/mobile-design-spec.md

Implement module {group1-mobile-module}.
""")

# ── Group 1 완료 대기 ──

# ── Group 2 (병렬): Group 1 완료 후 하나의 메시지에서 동시 호출 ──
Task(subagent_type="flutter-developer", prompt="""
Feature: {feature}
Module: {group2-module-A} (Server API 의존 작업)
Work Plan: docs/{product}/{feature}/mobile-work-plan.md
Brief: docs/{product}/{feature}/mobile-brief.md
Design Spec: docs/{product}/{feature}/mobile-design-spec.md

Implement module {group2-module-A}.
""")

Task(subagent_type="flutter-developer", prompt="""
Feature: {feature}
Module: {group2-module-B}
...
""")

# ── 모든 그룹 완료까지 반복 ──
```

**실행 그룹이 1개뿐인 단순한 경우** (모듈 분리 불필요):
```
# Server만
Task(subagent_type="node-developer", prompt="""
Feature: {feature}
Work Plan: docs/{product}/{feature}/server-work-plan.md
Brief: docs/{product}/{feature}/server-brief.md

Implement the feature following TDD cycle.
""")

# Mobile만
Task(subagent_type="flutter-developer", prompt="""
Feature: {feature}
Work Plan: docs/{product}/{feature}/mobile-work-plan.md
Brief: docs/{product}/{feature}/mobile-brief.md
Design Spec: docs/{product}/{feature}/mobile-design-spec.md

Implement the feature.
""")

# Web만
Task(subagent_type="react-developer", prompt="""
Feature: {feature}
Work Plan: docs/{product}/{feature}/web-work-plan.md
Brief: docs/{product}/{feature}/web-brief.md
Design Spec: docs/{product}/{feature}/web-design-spec.md

Implement the feature using Next.js App Router + shadcn/ui.
Run Playwright E2E tests to verify.
""")
```

**Fullstack (Web) 병렬 예시** — Server + Web agents 동시 실행:
```
# ── Group 1 (병렬): Server + Web 동시 시작 ──
Task(subagent_type="node-developer", prompt="""
Feature: {feature}
Module: {server-module}
Work Plan: docs/{product}/{feature}/server-work-plan.md
Brief: docs/{product}/{feature}/server-brief.md

Implement server module following TDD cycle.
""")

Task(subagent_type="react-developer", prompt="""
Feature: {feature}
Module: {web-module} (API 비의존 페이지/컴포넌트)
Work Plan: docs/{product}/{feature}/web-work-plan.md
Brief: docs/{product}/{feature}/web-brief.md
Design Spec: docs/{product}/{feature}/web-design-spec.md

Implement web module using Next.js App Router + shadcn/ui.
""")

# ── Group 1 완료 후 Group 2 ──
Task(subagent_type="react-developer", prompt="""
Feature: {feature}
Module: {web-api-dependent-module} (Server API 의존 페이지)
Work Plan: docs/{product}/{feature}/web-work-plan.md
Brief: docs/{product}/{feature}/web-brief.md
Design Spec: docs/{product}/{feature}/web-design-spec.md

Implement web module. Server API is now available.
Run Playwright E2E tests.
""")
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

---

### analyze (Check Phase) — Gap Detector + CTO Review

**Step 1: Call gap-detector agent**

```
Task(subagent_type="bkit:gap-detector", prompt="""
Feature: {feature}
Platform: {platform}

Compare design documents vs implementation code.

Design docs (by platform):
- Server: docs/{product}/{feature}/server-brief.md
- Mobile: docs/{product}/{feature}/mobile-brief.md, mobile-design-spec.md
- Web: docs/{product}/{feature}/web-brief.md, web-design-spec.md
- Fullstack: server-brief.md + frontend docs (by frontendType)

Source dirs: (from bkit.config.json platforms.{platform}.sourceDirectories)

Calculate Match Rate and list gaps.
Output: docs/{product}/{feature}/analysis.md
""")
```

**Step 1.5: Structured FINDINGS 후처리**

gap-detector 실행 후 analysis.md에 구조화된 FINDINGS 섹션을 추가합니다.
이 FINDINGS는 Act 단계에서 에이전트 디스패치에 사용됩니다.

```
# analysis.md 읽기
Read("docs/{product}/{feature}/analysis.md")

# gap-detector의 Gap 목록을 구조화된 FINDINGS로 변환
# 각 Gap을 아래 형식으로 분류:

## Structured FINDINGS

### FINDING-001
- **Category**: {LOGIC_GAP | DESIGN_GAP | SECURITY | PERFORMANCE | BUILD_ERROR | TYPE_ERROR | LINT_ERROR | CONTRACT_MISMATCH}
- **Severity**: {CRITICAL | HIGH | MEDIUM | LOW}
- **File**: {file_path}
- **Description**: {설명}
- **Suggested Fix**: {수정 방안}
- **Recommended Agent**: {매핑된 에이전트}
```

Category 분류 기준:
- LOGIC_GAP: 설계 문서에 명시된 기능이 구현에 누락
- DESIGN_GAP: UI/UX 설계와 구현 불일치
- SECURITY: 보안 취약점 (SQL 인젝션, XSS, 인증 누락 등)
- PERFORMANCE: 성능 문제 (N+1 쿼리, 누락된 인덱스 등)
- BUILD_ERROR: 빌드 실패
- TYPE_ERROR: TypeScript/Dart 타입 에러
- LINT_ERROR: 린트 규칙 위반
- CONTRACT_MISMATCH: API 계약과 구현 불일치

**Step 2: CTO integration review**

```
Task(subagent_type="cto", prompt="""
Feature: {feature}
Platform: {platform}

Perform ③ 통합 리뷰.
Read implementation code and verify:
- Server: test pass, build success, code quality
- Mobile: analyze pass, design-spec compliance, GetX patterns
- Web: build success, E2E pass, Server/Client Component boundaries, shadcn/ui usage
- Fullstack: API contract consistency between server and frontend (mobile or web)

Output (by platform):
- Server: docs/{product}/{feature}/server-cto-review.md
- Mobile: docs/{product}/{feature}/mobile-cto-review.md
- Web: docs/{product}/{feature}/web-cto-review.md
- Fullstack: both server + frontend cto-review files
""")
```

**Step 3: Update status**

```json
{ "phase": "check", "matchRate": N }
```

**Step 4: Create Task**

`TaskCreate: [Check] {feature}` (blockedBy: Do task)

---

### iterate (Act Phase) — Severity-Based Agent Dispatch

matchRate < 90% 시 FINDINGS를 기반으로 적절한 에이전트에 자동 디스패치합니다.

**Step 1: FINDINGS 파싱**
```
Read("docs/{product}/{feature}/analysis.md")
# Structured FINDINGS 섹션에서 모든 FINDING 항목 추출
```

**Step 2: Severity 순 정렬**
정렬 순서: CRITICAL → HIGH → MEDIUM → LOW

**Step 3: Finding → Agent 매핑 + 디스패치**

| Category | Agent |
|----------|-------|
| SECURITY | security-specialist |
| PERFORMANCE | performance-optimizer |
| BUILD_ERROR / TYPE_ERROR / LINT_ERROR | bug-fixer |
| LOGIC_GAP / DESIGN_GAP | node-developer / flutter-developer / react-developer (플랫폼별) |
| CONTRACT_MISMATCH | 양쪽 developer 재투입 |

**Step 4: Severity별 처리**
- **CRITICAL / HIGH**: 즉시 수정 필수. 수정 후 재분석 실행
  ```
  Task(subagent_type="{mapped-agent}", prompt="""
  Fix FINDING-{id}:
  Category: {category}
  Severity: {severity}
  File: {file}
  Description: {description}
  Suggested Fix: {suggested_fix}

  Feature: {feature}
  Brief: docs/{product}/{feature}/{platform}-brief.md
  """)
  ```
- **MEDIUM**: 1회 시도. 실패해도 진행 가능
- **LOW**: 리포트에 기록만 (수정 시도 안 함)

**Step 5: 재분석**
수정 완료 후 gap-detector 재실행하여 matchRate 갱신

**Step 6: 중단 조건**
- Match Rate >= 90% 도달 → 중단, report로 진행
- 최대 5회 이터레이션 도달 → 중단, 현재 상태로 report

**Step 7: Task 생성**
`TaskCreate: [Act-N] {feature}` (N = iteration count)

---

### report (Completion Report) — report-generator Agent

1. Verify matchRate >= 90% (warn if below)
2. **Call report-generator Agent**
3. Integrated report of Plan, Design, Implementation, Analysis
4. **CHANGELOG 자동 생성**
5. Create Task: `[Report] {feature}`
6. Update status: phase = "completed"

**Output Path**: `docs/{product}/{feature}/report.md`

**Step 4: CHANGELOG 자동 생성**

Feature 시작 이후의 git 변경사항을 추출하여 CHANGELOG.md에 추가합니다.

```
# Feature 시작 시점 확인
Read(".pdca-status.json") → features.{feature}.startedAt

# git log에서 해당 시점 이후 변경사항 추출
Bash("git log --oneline --after={startedAt} --format='%h %s'")

# CHANGELOG.md에 추가 (파일 상단에)
## [{feature}] - {date}

### Added
- {새로 추가된 기능}

### Changed
- {변경된 기능}

### Fixed
- {수정된 버그}

### Documents
- Plan: docs/{product}/{feature}/user-story.md
- Design: docs/{product}/{feature}/{platform}-brief.md
- Analysis: docs/{product}/{feature}/analysis.md
- Report: docs/{product}/{feature}/report.md
```

---

### archive (Archive Phase)

1. Verify Report completion (phase = "completed" or matchRate >= 90%)
2. Create `docs/archive/YYYY-MM/{feature}/` folder
3. Move all documents (check all platform-specific paths)
4. Update `.pdca-status.json`: phase = "archived"

**Documents to Archive** (check all locations per platform):
- Plan: `docs/{product}/{feature}/user-story.md`
- Server: `docs/{product}/{feature}/` (server-brief, server-work-plan, server-cto-review)
- Mobile: `docs/{product}/{feature}/` (mobile-design-spec, mobile-brief, mobile-work-plan, mobile-cto-review)
- Web: `docs/{product}/{feature}/` (web-design-spec, web-brief, web-work-plan, web-cto-review)
- Analysis: `docs/{product}/{feature}/analysis.md`
- Report: `docs/{product}/{feature}/report.md`

---

### status (Status Check)

1. Read `.pdca-status.json`
2. Display: feature, phase, platform, matchRate, documents
3. Visualize progress

```
📊 PDCA Status
─────────────────────────────
Feature: {feature}
Platform: {platform}
Phase: {phase}
Match Rate: {matchRate}%
─────────────────────────────
[Research] ✅ → [Plan] ✅ → [Design] ✅ → [Do] 🔄 → [Check] ⏳ → [Act] ⏳
```

---

### next (Next Phase)

| Current | Next | Action |
|---------|------|--------|
| None | research | clarify → research-director |
| research | plan | PO → interactive-review → CTO routing |
| plan | design | Platform-based design agents |
| design | do | CTO distribution → dev agents |
| do | check | Gap analysis + CTO review |
| check (<90%) | act | Auto-iterate |
| check (>=90%) | report | Completion report |
| report | archive | Archive documents |

---

## Agent Integration Summary

```
Plan:    PO (user-story.md) ──→ CTO (platform routing + frontendType)
              │                        │
              │                        ↓ platform & frontendType stored
Design:  ┌── Server: tech-lead (server-brief)
         ├── Mobile: ui-ux-designer → frontend-design (Skill) → tech-lead (mobile-design-spec, mobile-brief)
         └── Web:    ui-ux-designer → frontend-design (Skill) → tech-lead (web-design-spec, web-brief)
              │      Fullstack = Server + frontend (by frontendType)
              │
Do:      CTO (work-plan) ──→ node-developer + flutter-developer + react-developer
              │                    │                │                │
Analyze: gap-detector ────→ CTO (review)
              │
Iterate: pdca-iterator (if < 90%)
              │
Report:  report-generator
              │
Verify:  independent-reviewer (optional)
```

## CTO Involvement (3 Points)

| Phase | CTO Role | Output |
|-------|---------|--------|
| **Plan** (after PO) | ⓪ 플랫폼 라우팅 | `platform` in status |
| **Do** (before devs) | ② 작업 분배 | `server-work-plan.md`, `mobile-work-plan.md`, `web-work-plan.md` (플랫폼별) |
| **Analyze** (after gap) | ③ 통합 리뷰 | `server-cto-review.md`, `mobile-cto-review.md`, `web-cto-review.md` (플랫폼별) |
