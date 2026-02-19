---
name: pdca
description: |
  Project-level PDCA skill override for gaegulzip.
  Integrates with project agents (CTO, PO, Tech Lead, etc.) and
  uses platform-specific document paths from bkit.config.json.

  Agent workflow per phase:
  - Plan: PO → CTO (platform routing)
  - Design: ui-ux-designer → frontend-design (Skill) → tech-lead (per frontend platform)
  - Do: CTO (work distribution) → node-developer + flutter-developer + react-developer → test-scenario-generator (mobile only)
  - Analyze: gap-detector + independent-reviewer (mobile) + CTO (integration review)
  - Iterate/Report: bkit agents

  Triggers: pdca, plan, design, analyze, report, status, next, iterate
argument-hint: "[action] [feature]"
user-invocable: true
agents:
  plan: product-owner
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
| `plan [feature]` | PO → CTO routing | `/pdca plan user-auth` |
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

### plan (Plan Phase) — PO Agent → CTO Agent

**Step 1: Product Owner creates unified user story**

Call `product-owner` agent via Task tool:

```
Task(subagent_type="product-owner", prompt="""
Feature: {feature}
Context: [PRD, research docs, or user's description]

Create a unified user story focusing on WHAT (user needs), not HOW (technical implementation).
Do NOT determine platform yet. Do NOT include API specs or UI details.

Output: docs/{product}/{feature}/user-story.md
""")
```

**Step 2: CTO determines platform**

After PO completes, call `cto` agent via Task tool:

```
Task(subagent_type="cto", prompt="""
Feature: {feature}

PO has written user story. Read it and perform platform routing:
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

### iterate (Act Phase) — pdca-iterator Agent

1. Verify matchRate < 90%
2. **Call pdca-iterator Agent**
3. Auto-fix code based on Gap list
4. Auto re-run analyze after fixes
5. Create Task: `[Act-N] {feature}` (N = iteration count)
6. Stop when >= 90% reached or max iterations (5) hit

---

### report (Completion Report) — report-generator Agent

1. Verify matchRate >= 90% (warn if below)
2. **Call report-generator Agent**
3. Integrated report of Plan, Design, Implementation, Analysis
4. Create Task: `[Report] {feature}`
5. Update status: phase = "completed"

**Output Path**: `docs/{product}/{feature}/report.md`

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
[Plan] ✅ → [Design] ✅ → [Do] 🔄 → [Check] ⏳ → [Act] ⏳
```

---

### next (Next Phase)

| Current | Next | Action |
|---------|------|--------|
| None | plan | PO → CTO routing |
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
