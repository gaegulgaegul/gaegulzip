---
name: pdca
description: |
  Project-level PDCA skill override for gaegulzip.
  Integrates with project agents (CTO, PO, Tech Lead, etc.) and
  uses platform-specific document paths from bkit.config.json.

  Agent workflow per phase:
  - Plan: PO → CTO (platform routing)
  - Design: tech-lead + ui-ux-designer (per platform)
  - Do: CTO (work distribution) → node-developer + flutter-developer
  - Analyze: gap-detector + CTO (integration review)
  - Iterate/Report: bkit agents

  Triggers: pdca, plan, design, analyze, report, status, next, iterate
argument-hint: "[action] [feature]"
user-invocable: true
agents:
  plan: product-owner
  routing: cto
  design-server: server/tech-lead
  design-mobile-ui: mobile/ui-ux-designer
  design-mobile-tech: mobile/tech-lead
  do-distribute: cto
  do-server: server/node-developer
  do-mobile: mobile/flutter-developer
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
      "platform": "server | mobile | fullstack",
      "startedAt": "ISO timestamp",
      "documents": {}
    }
  }
}
```

**IMPORTANT**: `platform` is determined during Plan phase by CTO and reused in all subsequent phases.

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
| **Server** | `server/tech-lead` | `docs/server/{feature}/server-brief.md` |
| **Mobile** | `mobile/ui-ux-designer` → `mobile/tech-lead` | `docs/mobile/{feature}/mobile-design-spec.md`, `docs/mobile/{feature}/mobile-brief.md` |
| **Fullstack** | All above (parallel where possible) | Both server + mobile docs |

**Server** — call `tech-lead` (server):
```
Task(subagent_type="tech-lead", prompt="""
Feature: {feature}
Platform: Server
User Story: docs/{product}/{feature}/user-story.md

Create technical design brief (including API specs, DB schema, business logic).
Output: docs/server/{feature}/server-brief.md
""")
```

**Mobile** — call `ui-ux-designer` first, then `tech-lead` (mobile):
```
Task(subagent_type="ui-ux-designer", prompt="""
Feature: {feature}
User Story: docs/{product}/{feature}/user-story.md

Create design specification (including UI layouts, interactions, components).
Output: docs/mobile/{feature}/mobile-design-spec.md
""")

# After ui-ux-designer completes:
Task(subagent_type="tech-lead", prompt="""
Feature: {feature}
Platform: Mobile
User Story: docs/{product}/{feature}/user-story.md
Design Spec: docs/mobile/{feature}/mobile-design-spec.md

Create technical brief based on design spec.
Output: docs/mobile/{feature}/mobile-brief.md
""")
```

**Fullstack** — run Server and Mobile in parallel where possible.

**Step 3: Update status**

```json
{ "phase": "design", "documents": { "design-server": "...", "design-mobile": "..." } }
```

**Step 4: Create Task**

`TaskCreate: [Design] {feature}` (blockedBy: Plan task)

---

### do (Do Phase) — CTO Distribution → Dev Agents

**Step 1: CTO creates work plan**

```
Task(subagent_type="cto", prompt="""
Feature: {feature}
Platform: {platform from status}

Read design documents and create work distribution plan.
Determine how to split work between developers.
Define parallel/sequential execution order.
Define module contracts (Controller ↔ View connections).

Output: docs/{platform}/{feature}/{platform}-work-plan.md
(For fullstack: both docs/server/{feature}/server-work-plan.md and docs/mobile/{feature}/mobile-work-plan.md)
""")
```

**Step 2: Call dev agents based on platform and work plan**

| Platform | Agent | Task |
|----------|-------|------|
| **Server** | `node-developer` | Implement server feature per work-plan.md |
| **Mobile** | `flutter-developer` | Implement mobile feature per work-plan.md |
| **Fullstack** | Both (parallel) | Each implements their platform |

```
# Server
Task(subagent_type="node-developer", prompt="""
Feature: {feature}
Work Plan: docs/server/{feature}/server-work-plan.md
Brief: docs/server/{feature}/server-brief.md

Implement the feature following TDD cycle.
""")

# Mobile
Task(subagent_type="flutter-developer", prompt="""
Feature: {feature}
Work Plan: docs/mobile/{feature}/mobile-work-plan.md
Brief: docs/mobile/{feature}/mobile-brief.md
Design Spec: docs/mobile/{feature}/mobile-design-spec.md

Implement the feature.
""")
```

**Step 3: Update status**

```json
{ "phase": "do" }
```

**Step 4: Create Task**

`TaskCreate: [Do] {feature}` (blockedBy: Design task)

---

### analyze (Check Phase) — Gap Detector + CTO Review

**Step 1: Call gap-detector agent**

```
Task(subagent_type="bkit:gap-detector", prompt="""
Feature: {feature}
Platform: {platform}

Compare design documents vs implementation code.
Design docs: docs/{platform}/{feature}/{platform}-brief.md
Source dirs: (from bkit.config.json platforms.{platform}.sourceDirectories)

Calculate Match Rate and list gaps.
Output: docs/03-analysis/{feature}.analysis.md
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
- Fullstack: API contract consistency between server and mobile

Output: docs/{platform}/{feature}/{platform}-cto-review.md
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

**Output Path**: `docs/04-report/{feature}.report.md`

---

### archive (Archive Phase)

1. Verify Report completion (phase = "completed" or matchRate >= 90%)
2. Create `docs/archive/YYYY-MM/{feature}/` folder
3. Move all documents (check all platform-specific paths)
4. Update `.pdca-status.json`: phase = "archived"

**Documents to Archive** (check all locations per platform):
- Plan: `docs/{product}/{feature}/user-story.md`
- Server: `docs/server/{feature}/` (server-brief, server-work-plan, server-cto-review)
- Mobile: `docs/mobile/{feature}/` (mobile-design-spec, mobile-brief, mobile-work-plan, mobile-cto-review)
- Analysis: `docs/03-analysis/{feature}.analysis.md`
- Report: `docs/04-report/{feature}.report.md`

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
Plan:    PO (user-story.md) ──→ CTO (platform routing)
              │                        │
              │                        ↓ platform stored
Design:  tech-lead ←── platform ──→ ui-ux-designer → tech-lead(mobile)
         (server-brief)               (design-spec)    (mobile-brief)
              │                              │
Do:      CTO (work-plan) ──→ node-developer + flutter-developer
              │                    │                │
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
| **Do** (before devs) | ② 작업 분배 | `{platform}-work-plan.md` |
| **Analyze** (after gap) | ③ 통합 리뷰 | `{platform}-cto-review.md` |
