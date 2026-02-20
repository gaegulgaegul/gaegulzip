# analyze (Check Phase) — Gap Detector + CTO Review

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
- UX_POLISH: 로딩 상태, 빈 상태, 에러 상태, 성공 피드백 등 사용자 경험 완성도 부족
- EDGE_CASE: 경계값, 네트워크 오류, 빈 데이터, 권한 없음 등 엣지 케이스 미처리

**Step 1.7: 코드 리뷰 (MANDATORY — plan-review Skill)**

gap-detector + FINDINGS 후처리 완료 후, CTO 통합 리뷰 전에 코드 품질 리뷰를 자동 수행합니다:

```
Skill("plan-review", args="code {feature}")
# 리뷰 결과의 Action Items를 FINDINGS에 병합
```

> plan-review Skill 내부에서 BIG/SMALL CHANGE 선택을 받습니다.
> 참조: `.claude/skills/plan-review/SKILL.md`

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
