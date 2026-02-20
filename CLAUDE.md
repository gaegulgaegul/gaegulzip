# CLAUDE.md

**모든 대화는 한국어로 진행**
**TODO(human) 절대 금지! 의사결정이 필요한 부분은 질의응답으로 사용자와 의논**
**삭제해야 하는 파일이 있으면 명령어를 사용자에게 알려주면서 요청**

gaegulzip — TypeScript/Express 백엔드 + Flutter 모바일 + Next.js 웹의 하이브리드 모노레포

## Monorepo Structure

```
gaegulzip/
├── apps/
│   ├── server/              # TypeScript/Express backend (Node.js)
│   ├── mobile/              # Flutter monorepo (managed by Melos)
│   │   ├── apps/wowa/       # Main Flutter application
│   │   └── packages/        # Shared Flutter packages
│   └── web/
│       ├── admin/           # Next.js admin dashboard (shadcn/ui)
│       └── talmosang/       # Next.js 탈모상 AI 두피 분석 웹앱
├── turbo.json              # Turborepo task configuration
├── pnpm-workspace.yaml     # pnpm workspace definition
└── melos.yaml              # Melos configuration for Flutter packages
```

## Common Commands

```bash
pnpm install                # Install all Node.js dependencies
pnpm dev                    # Run all dev tasks (Turborepo)
pnpm build                  # Build all projects
```

Turborepo tasks (`turbo.json`): `dev`, `dev:server`, `dev:mobile`, `build`

## Platform Guides

| Platform | CLAUDE.md | 역할 |
|----------|-----------|------|
| Server | `apps/server/CLAUDE.md` | 서버 커맨드, Express 컨벤션, API 설계, Drizzle ORM, 로깅, 테스팅 |
| Mobile | `apps/mobile/CLAUDE.md` | 모바일 커맨드, 패키지 구조, Flutter/GetX/Design System, 코드 생성 |
| Web (admin) | `apps/web/admin/CLAUDE.md` | Next.js 16 + shadcn/ui, Tailwind CSS, Playwright E2E only |
| Web (talmosang) | `apps/web/talmosang/CLAUDE.md` | Next.js 15 + Tailwind CSS v4, Gemini API 두피 분석 |
| Design System | `apps/mobile/packages/design_system/CLAUDE.md` | Frame0 Sketch Style Flutter UI |

## Core Principles

> 상세: `.claude/guide/coding-discipline.md` (Anti-pattern 포함)

- **Surface Assumptions**: 구현 전 가정 명시. 여러 해석 가능하면 제시하고 질문.
- **Simplicity First**: 요청된 것만 구현. "시니어 엔지니어가 과하다고 할까?" 자가 검증.
- **Surgical Changes**: 요청과 직접 관련된 코드만 변경. 미사용 코드는 완전 삭제.
- **Goal-Driven Execution**: 모든 작업을 검증 가능한 목표로 변환.
- **File System = SSOT**: 에이전트 간 상태 전달 시 파일에서 직접 읽기
- **Context Recovery**: 압축 후 복구: `.pdca-status.json` -> 작업 문서 -> `git diff` -> `CLAUDE.md`. 부패 징후 시 `/compact`.
- **User = PO**: 기술 옵션 제시, 선택은 사용자 몫. 한계는 솔직히 말하고 대안 제시.
- **Prompt Coach**: 매 응답 마지막에 사용자 프롬프트를 Core Principles 기준으로 분석. 프롬프트가 충분히 구체적이면 생략. 부족하면 `💡 Prompt Coach` 섹션을 한두 줄로 추가하여 어떤 정보(범위, 제약조건, 기대 결과, 영향 범위 등)를 추가하면 더 정확한 응답을 받을 수 있는지 제안.

## Documentation References

공통: `.claude/guide/engineering-preferences.md` (품질 기준) | `.claude/guide/coding-discipline.md` (구현 규칙). 플랫폼별은 각 CLAUDE.md 참조.

## Disabled Skills

| Skill | 이유 |
|-------|------|
| `feature-planner` | PDCA 워크플로우로 대체됨 |
| `commit-commands:commit-push-pr` | 수동 커밋 워크플로우 사용 |
| `coderabbit:review` | CTO 통합 리뷰 + gap-detector로 대체됨 |
| `coderabbit:code-review` | 위와 동일 |
| `commit-commands:commit` | `/커밋` 스킬로 대체 |
| `commit-commands:clean_gone` | 수동 관리 |

## Hook System

| Hook | Event | 동작 |
|------|-------|------|
| `auto-validate` | PostToolUse (Edit/Write) | TS/Dart 자동 타입체크 + 린트 |
| `sql-injection-check` | PostToolUse (Edit/Write) | SQL 인젝션 패턴 탐지 |
| `context-enrichment` | UserPromptSubmit | PDCA 상태 + 최근 git 변경사항 자동 주입 |

설정: `.claude/settings.json` / 스크립트: `.claude/hooks/`

## Model Selection Guide

Task 에이전트: 탐색 `haiku` | 단순 구현 `sonnet` | 설계/리뷰/복잡한 구현 `opus` (기본값)

## Serena Usage (MANDATORY)

- `find_symbol` / `get_symbols_overview` / `find_referencing_symbols`: 코드 탐색
- `insert_after_symbol` / `insert_before_symbol` / `replace_symbol`: 코드 수정
- grep/ripgrep 대신 serena 시맨틱 검색. 전체 파일 읽기 금지. 미사용 MCP 플러그인은 비활성화.
