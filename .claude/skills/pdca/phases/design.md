# design (Design Phase) — Platform-Based Agent Dispatch

> ⚠️ **INTENT-ONLY RULE 적용**: 모든 설계 문서는 의도(무엇을/왜)만 작성한다. 구현(어떻게)은 절대 작성하지 않는다.
> 파일명, 코드 구조, 함수 시그니처, DB 쿼리, 라이브러리 사용법 금지.
> 허용: 사용자 행동, 비즈니스 규칙, 데이터 요구사항, API 계약(엔드포인트+타입), 제약조건.
> 구현 결정은 Do 단계의 개발자 에이전트 몫이다.

> 📊 **불확실성 지도 (MANDATORY)**: 모든 brief.md 문서는 끝에 "## 불확실성 지도" 섹션을 포함해야 한다.
> 사용자가 설계 승인 시 어디에 집중 검토해야 하는지 투명하게 안내한다.
> - **자신있는 판단**: 근거가 명확하여 확신도가 높은 설계 결정
> - **단순화했을 수 있는 부분**: 복잡도를 과소평가했거나 세부사항을 생략했을 수 있는 영역
> - **의견이 바뀔 수 있는 조건**: 어떤 정보나 질문이 현재 설계를 변경시킬 수 있는지

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

**Step 1.5: research.md 참조 (존재하는 경우)**

```
# Research 단계를 거친 경우 research.md가 존재
research_exists = Glob("docs/{product}/{feature}/research.md")

# research.md가 있으면 모든 설계 에이전트 프롬프트에 아래 참조를 추가:
# Research: docs/{product}/{feature}/research.md
# (기술 조사 결과와 Decision Points를 설계에 반영)
```

**Server** — call `server/tech-lead`:
```
Task(subagent_type="server/tech-lead", prompt="""
Feature: {feature}
Platform: Server
User Story: docs/{product}/{feature}/user-story.md
{if research_exists: "Research: docs/{product}/{feature}/research.md"}

Create technical design brief (including API specs, DB schema, business logic).

⚠️ INTENT-ONLY RULE: 의도(무엇을/왜)만 작성. 구현(어떻게)은 절대 금지.
- ❌ 금지: 파일명, 코드 구조, 함수 시그니처, SQL 쿼리, 라이브러리 사용법
- ✅ 허용: 엔드포인트 계약(method+path+타입), 데이터 모델(엔티티+관계), 비즈니스 규칙, 제약조건
구현 결정은 Do 단계의 node-developer가 한다.

📊 문서 끝에 "## 불확실성 지도" 섹션을 반드시 포함하세요:
- 자신있는 판단: 근거가 명확한 설계 결정
- 단순화했을 수 있는 부분: 복잡도를 과소평가했을 수 있는 영역
- 의견이 바뀔 수 있는 조건: 추가 정보가 있으면 설계가 달라질 수 있는 부분

Output: docs/{product}/{feature}/server-brief.md
""")
```

**Mobile** — call `mobile/ui-ux-designer` first, then `frontend-design` skill, then `mobile/tech-lead`:
```
Task(subagent_type="mobile/ui-ux-designer", prompt="""
Feature: {feature}
User Story: docs/{product}/{feature}/user-story.md
{if research_exists: "Research: docs/{product}/{feature}/research.md"}

Create design specification (including UI layouts, interactions, components).

⚠️ INTENT-ONLY RULE: 의도(무엇을/왜)만 작성. 구현(어떻게)은 절대 금지.
- ❌ 금지: 위젯 트리, 코드 구조, 클래스명, 상태관리 코드, 패키지 import
- ✅ 허용: 화면 구성, 인터랙션 흐름, 컴포넌트 역할, 시각 요소, 사용자 행동
구현 결정은 Do 단계의 flutter-developer가 한다.

Output: docs/{product}/{feature}/mobile-design-spec.md
""")

# After ui-ux-designer completes, invoke frontend-design skill:
Skill("frontend-design", args="""
Feature: {feature}
Design Spec: docs/{product}/{feature}/mobile-design-spec.md

Review and enhance the design spec with distinctive visual design.
텍스트 기반으로 디자인 명세를 보강합니다 (색상, 타이포그래피, 스페이싱, 인터랙션 등).
코드나 목업 이미지를 생성하지 않습니다. design-spec.md의 텍스트 품질을 높이는 역할입니다.
Update: docs/{product}/{feature}/mobile-design-spec.md
""")

# After frontend-design completes:
Task(subagent_type="mobile/tech-lead", prompt="""
Feature: {feature}
Platform: Mobile
User Story: docs/{product}/{feature}/user-story.md
Design Spec: docs/{product}/{feature}/mobile-design-spec.md
{if research_exists: "Research: docs/{product}/{feature}/research.md"}

Create technical brief based on design spec.

IMPORTANT: 기술적으로 구현 불가능하거나 과도한 복잡도를 초래하는 디자인 요소가 있으면,
brief.md 끝에 "## Design Pushback" 섹션을 작성하세요.
각 항목에 대해:
- 문제점 설명
- 대안 제안
- 복잡도 영향 (Low/Medium/High)

Design Pushback 섹션이 없으면 모든 디자인 요소가 구현 가능하다는 의미입니다.

📊 문서 끝에 "## 불확실성 지도" 섹션을 반드시 포함하세요:
- 자신있는 판단: 근거가 명확한 설계 결정
- 단순화했을 수 있는 부분: 복잡도를 과소평가했을 수 있는 영역
- 의견이 바뀔 수 있는 조건: 추가 정보가 있으면 설계가 달라질 수 있는 부분

Output: docs/{product}/{feature}/mobile-brief.md
""")
```

**Web** — call `web/ui-ux-designer` first, then `frontend-design` skill, then `web/tech-lead`:
```
Task(subagent_type="web/ui-ux-designer", prompt="""
Feature: {feature}
User Story: docs/{product}/{feature}/user-story.md
{if research_exists: "Research: docs/{product}/{feature}/research.md"}

Create web UI/UX design specification (shadcn/ui components, Tailwind CSS, responsive layout).

⚠️ INTENT-ONLY RULE: 의도(무엇을/왜)만 작성. 구현(어떻게)은 절대 금지.
- ❌ 금지: JSX 코드, 컴포넌트 파일 구조, hook 구현, CSS 코드
- ✅ 허용: 화면 구성, 인터랙션 흐름, 컴포넌트 역할, 시각 요소, 사용자 행동
구현 결정은 Do 단계의 react-developer가 한다.

Output: docs/{product}/{feature}/web-design-spec.md
""")

# After ui-ux-designer completes, invoke frontend-design skill:
Skill("frontend-design", args="""
Feature: {feature}
Design Spec: docs/{product}/{feature}/web-design-spec.md

Review and enhance the design spec with distinctive visual design.
텍스트 기반으로 디자인 명세를 보강합니다 (색상, 타이포그래피, 스페이싱, 인터랙션 등).
코드나 목업 이미지를 생성하지 않습니다. design-spec.md의 텍스트 품질을 높이는 역할입니다.
Update: docs/{product}/{feature}/web-design-spec.md
""")

# After frontend-design completes:
Task(subagent_type="web/tech-lead", prompt="""
Feature: {feature}
Platform: Web
User Story: docs/{product}/{feature}/user-story.md
Design Spec: docs/{product}/{feature}/web-design-spec.md
{if research_exists: "Research: docs/{product}/{feature}/research.md"}

Create technical brief (Next.js App Router, Server/Client Components, auth, API integration).

IMPORTANT: 기술적으로 구현 불가능하거나 과도한 복잡도를 초래하는 디자인 요소가 있으면,
brief.md 끝에 "## Design Pushback" 섹션을 작성하세요.
각 항목에 대해:
- 문제점 설명
- 대안 제안
- 복잡도 영향 (Low/Medium/High)

Design Pushback 섹션이 없으면 모든 디자인 요소가 구현 가능하다는 의미입니다.

📊 문서 끝에 "## 불확실성 지도" 섹션을 반드시 포함하세요:
- 자신있는 판단: 근거가 명확한 설계 결정
- 단순화했을 수 있는 부분: 복잡도를 과소평가했을 수 있는 영역
- 의견이 바뀔 수 있는 조건: 추가 정보가 있으면 설계가 달라질 수 있는 부분

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
    Task(subagent_type="{platform}/ui-ux-designer", prompt="""
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
    Task(subagent_type="{platform}/tech-lead", prompt="""
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

**Pushback 해소 후 brief.md에 변경 요약 추가:**

Pushback이 해소된 경우, brief.md 끝에 `## Design Changes Summary` 섹션을 추가합니다:

```markdown
## Design Changes Summary

| 변경 항목 | 원본 디자인 | 수정 결과 | 이유 | 복잡도 영향 |
|-----------|------------|----------|------|------------|
| {항목} | {원본} | {수정} | {Tech Lead 피드백 요약} | Low/Medium/High |
```

> 이 섹션은 Do 단계에서 개발자가 변경 맥락을 이해하는 데 사용됩니다.

**Fullstack** — **Server 선행 → API Contract → Frontend** 순서로 실행합니다.
- Server brief 완성 후 API Contract를 생성하고, 그 다음 Frontend 설계를 진행합니다.
- `frontendType: "mobile"` → Server brief → API Contract → Mobile agents
- `frontendType: "web"` → Server brief → API Contract → Web agents
- Frontend 에이전트는 api-contract.md를 참조하여 설계합니다.

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
    Task(subagent_type="server/tech-lead", prompt="""
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
    Task(subagent_type="{frontendType}/tech-lead", prompt="""
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

**Step 2.7: 설계 리뷰 (MANDATORY — design-review Skill)**

모든 설계 문서 작성 완료 후, 구현 단계 진입 전에 설계 품질을 검증합니다:

```
Skill("plan-review", args="design {feature}")
# 리뷰 결과에서 Action Items가 있으면 설계 문서 수정 후 재진행
```

> plan-review Skill 내부에서 BIG/SMALL CHANGE 선택을 받습니다.
> 리뷰 결과를 사용자에게 보여주고 최종 확인을 받습니다.
> 참조: `.claude/skills/plan-review/SKILL.md`

**Step 3: Update status**

```json
{ "phase": "design", "documents": { "design-server": "...", "design-mobile": "..." } }
```

**Step 4: Create Task**

`TaskCreate: [Design] {feature}` (blockedBy: Plan task)
