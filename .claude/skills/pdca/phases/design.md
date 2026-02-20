# design (Design Phase) — Platform-Based Agent Dispatch

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

IMPORTANT: 기술적으로 구현 불가능하거나 과도한 복잡도를 초래하는 디자인 요소가 있으면,
brief.md 끝에 "## Design Pushback" 섹션을 작성하세요.
각 항목에 대해:
- 문제점 설명
- 대안 제안
- 복잡도 영향 (Low/Medium/High)

Design Pushback 섹션이 없으면 모든 디자인 요소가 구현 가능하다는 의미입니다.

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

IMPORTANT: 기술적으로 구현 불가능하거나 과도한 복잡도를 초래하는 디자인 요소가 있으면,
brief.md 끝에 "## Design Pushback" 섹션을 작성하세요.
각 항목에 대해:
- 문제점 설명
- 대안 제안
- 복잡도 영향 (Low/Medium/High)

Design Pushback 섹션이 없으면 모든 디자인 요소가 구현 가능하다는 의미입니다.

Output: docs/{product}/{feature}/web-brief.md
""")
```

**Step 2.3: Design Pushback 처리 (양방향 — tech-lead → designer)**

Tech-lead가 brief.md에 "## Design Pushback" 섹션을 작성한 경우, 디자이너에게 피드백을 전달하여 design-spec을 수정합니다.

```
# brief.md에서 Design Pushback 섹션 확인
Read("docs/{product}/{feature}/{platform}-brief.md")

if "## Design Pushback" in brief_content:
    # 1. 디자이너에게 pushback 전달하여 design-spec 수정
    Task(subagent_type="ui-ux-designer", prompt="""
    Feature: {feature}
    기존 Design Spec: docs/{product}/{feature}/{platform}-design-spec.md
    Tech Lead Pushback: docs/{product}/{feature}/{platform}-brief.md의 "## Design Pushback" 섹션

    Tech Lead가 아래 디자인 요소에 대해 기술적 문제를 지적했습니다.
    brief.md의 "## Design Pushback" 섹션을 읽고,
    각 항목의 대안을 반영하여 design-spec.md를 수정하세요.

    수정 시 원본 디자인 의도는 최대한 살리되, 기술적 실현 가능성을 우선합니다.
    수정된 부분은 "<!-- Revised: {이유} -->" 주석으로 표시합니다.

    Output: docs/{product}/{feature}/{platform}-design-spec.md (수정)
    """)

    # 2. frontend-design으로 수정된 디자인 재보강
    Skill("frontend-design", args="""
    Feature: {feature}
    Design Spec: docs/{product}/{feature}/{platform}-design-spec.md

    Design Pushback 반영 후 수정된 디자인입니다.
    수정된 부분(<!-- Revised --> 주석)의 시각적 품질을 재보강하세요.
    Update: docs/{product}/{feature}/{platform}-design-spec.md
    """)

    # 3. tech-lead 재호출하여 brief 갱신 (Pushback 해소 확인)
    Task(subagent_type="tech-lead", prompt="""
    Feature: {feature}
    Platform: {platform}
    수정된 Design Spec: docs/{product}/{feature}/{platform}-design-spec.md

    디자이너가 Design Pushback을 반영하여 design-spec을 수정했습니다.
    수정된 design-spec을 확인하고 brief.md를 갱신하세요.

    더 이상 Pushback이 없으면 "## Design Pushback" 섹션을 제거합니다.
    여전히 문제가 있으면 섹션을 유지합니다 (최대 2회 반복 후 사용자 에스컬레이션).

    Output: docs/{product}/{feature}/{platform}-brief.md (갱신)
    """)

    # 최대 2회 반복. 2회 후에도 Pushback이 남아있으면:
    if still_has_pushback_after_2_rounds:
        AskUserQuestion(
          question: "디자인 Pushback이 해소되지 않았습니다:\n{remaining_pushback}\n\nTech Lead와 Designer 간 의견이 다릅니다.",
          options: [
            "Tech Lead 의견 수용 (기술 우선)",
            "Designer 의견 유지 (디자인 우선)",
            "직접 조정"
          ]
        )
```

> **Pushback이 없으면 이 단계를 건너뜁니다.** 대부분의 경우 tech-lead가 design-spec을 문제 없이 brief로 변환합니다.

**Fullstack** — run Server + frontend (Mobile or Web based on `frontendType`) in parallel where possible.
- `frontendType: "mobile"` → Server + Mobile agents
- `frontendType: "web"` → Server + Web agents

**Step 2.5: API Contract 생성 + 양방향 검증 (Fullstack 전용)**

Fullstack 모드에서 server-brief.md 생성 후, CTO가 api-contract.md를 생성하고
server tech-lead와 frontend tech-lead가 각각 검증합니다.

```
if platform == "fullstack":
    # 1. CTO가 server-brief 기반으로 API Contract 초안 생성
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

    # 2. 양방향 검증: server tech-lead + frontend tech-lead 병렬 리뷰
    # server tech-lead: "내가 설계한 API가 올바르게 반영되었는가?"
    Task(subagent_type="tech-lead", model="sonnet", prompt="""
    Role: API Contract Reviewer (Server Side)
    Feature: {feature}

    Read:
    - docs/{product}/{feature}/server-brief.md (내가 작성한 서버 설계)
    - docs/{product}/{feature}/api-contract.md (CTO가 생성한 계약)

    server-brief.md의 API 설계가 api-contract.md에 정확히 반영되었는지 검증합니다.

    검증 항목:
    1. 엔드포인트 누락/불일치
    2. 요청/응답 타입 정확성
    3. 인증 요구사항 반영 여부
    4. 에러 응답 형식 일관성

    Output format (JSON):
    {
      "verdict": "PASS | REVISE",
      "mismatches": [{"endpoint": "...", "issue": "...", "fix": "..."}],
      "additions": ["누락된 엔드포인트/타입"]
    }

    NOTE: 서버 관점에서만 검증. 5분 이내 완료.
    """)

    # frontend tech-lead: "이 API로 프론트엔드를 구현할 수 있는가?"
    Task(subagent_type="tech-lead", model="sonnet", prompt="""
    Role: API Contract Reviewer (Frontend Side)
    Feature: {feature}

    Read:
    - docs/{product}/{feature}/{frontendType}-design-spec.md (프론트엔드 설계)
    - docs/{product}/{feature}/api-contract.md (CTO가 생성한 계약)

    프론트엔드 화면/기능 구현에 필요한 데이터가 api-contract.md에 모두 포함되었는지 검증합니다.

    검증 항목:
    1. 화면별 필요 데이터 vs API 응답 필드 매칭
    2. 페이지네이션/필터 등 UX 패턴 지원 여부
    3. 실시간 데이터 필요 시 WebSocket/SSE 지원 여부
    4. 파일 업로드 등 특수 요구사항 반영 여부

    Output format (JSON):
    {
      "verdict": "PASS | REVISE",
      "gaps": [{"screen": "...", "neededData": "...", "missingFrom": "api-contract"}],
      "suggestions": ["제안사항"]
    }

    NOTE: 프론트엔드 관점에서만 검증. 5분 이내 완료.
    """)

    # 3. 리뷰 결과 종합
    if server_verdict == "REVISE" or frontend_verdict == "REVISE":
        # CTO에게 수정 요청
        Task(subagent_type="cto", prompt="""
        Feature: {feature}

        API Contract 리뷰 결과 수정이 필요합니다.

        Server Tech Lead 피드백:
        {server_review_result}

        Frontend Tech Lead 피드백:
        {frontend_review_result}

        위 피드백을 반영하여 api-contract.md를 수정하세요.
        수정 후 "## Revision Log" 섹션에 변경 사항을 기록합니다.

        Output: docs/{product}/{feature}/api-contract.md (수정)
        """)

        # 수정 후 재검증 (최대 1회 추가 — 총 2라운드)
        # 2라운드 후에도 REVISE면 사용자에게 에스컬레이션
```

> **API Contract 검증이 PASS이면 바로 Step 3으로 진행합니다.**

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
