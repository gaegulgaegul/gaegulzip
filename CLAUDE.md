# CLAUDE.md

**모든 대화는 한국어로 진행**
**TODO(human) 절대 금지! 의사결정이 필요한 부분은 질의응답으로 사용자와 의논**

gaegulzip — TypeScript/Express 백엔드 + Flutter 모바일 + Next.js 웹의 하이브리드 모노레포

## Monorepo Structure

```
gaegulzip/
├── apps/
│   ├── server/              # TypeScript/Express backend (Node.js)
│   ├── mobile/              # Flutter monorepo (managed by Melos)
│   │   ├── apps/wowa/       # Main Flutter application
│   │   └── packages/        # Shared Flutter packages
│   │       ├── core/        # Foundation utilities, DI, logging
│   │       ├── design_system/ # UI components, theme
│   │       ├── auth_sdk/    # Authentication SDK (social login, token management)
│   │       ├── push/        # Push notification SDK
│   │       ├── notice/      # Notice SDK
│   │       ├── qna/         # Q&A SDK
│   │       └── admob/       # Google AdMob SDK
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
| Mobile | `apps/mobile/CLAUDE.md` | 모바일 커맨드, 패키지 구조, Flutter/GetX/Design System, 코드 생성, Troubleshooting |
| Web (admin) | `apps/web/admin/CLAUDE.md` | Next.js 16 + shadcn/ui, Tailwind CSS, Playwright E2E only |
| Web (talmosang) | `apps/web/talmosang/` | Next.js 15 + Tailwind CSS v4, Gemini API 두피 분석 |

## Core Principles

- **Surface Assumptions**: 구현 전 가정을 명시. 여러 해석이 가능하면 조용히 하나를 선택하지 말고 제시. 불확실하면 멈추고 질문.
- **Simplicity First**: 요청된 것만 구현. 단일 사용 추상화 금지. 200줄을 50줄로 줄일 수 있으면 줄일 것. 자가 검증: "시니어 엔지니어가 과하다고 할까?"
- **Surgical Changes**: 요청과 직접 관련된 코드만 변경. 인접 코드 "개선" 금지. 기존 스타일과 다르더라도 맞출 것. 자기 변경으로 생긴 고아만 정리하고 기존 dead code는 언급만. 검증: "모든 변경 라인이 요청에 직접 연결되는가?"
- **Goal-Driven Execution**: 모든 작업을 검증 가능한 목표로 변환. "버그 수정" → "버그 재현 테스트 작성 후 통과시키기". 멀티스텝 작업은 각 스텝에 verify 체크포인트 명시.
- **No backwards-compatibility hacks**: Delete unused code completely instead of renaming or commenting
- **SDK = Flutter 패키지만** — 서버는 `modules/`로 유지 (상세: Mobile CLAUDE.md)
- **File System = SSOT**: 파일 시스템이 유일한 진실의 원천(Single Source of Truth). 에이전트 간 상태 전달 시 결과 텍스트가 아닌 파일에서 직접 읽기
- **Context Compaction Recovery**: 컨텍스트 압축 후 복구 우선순위: (1) `.pdca-status.json` → (2) 작업 문서 (`work-plan.md`, `brief.md`) → (3) `git diff` → (4) `CLAUDE.md`

## Core Features (재사용 가능한 공통 기능)

새 제품/기능 개발 시 아래 카탈로그에서 기존 구현을 확인하고 재사용하세요.

| 플랫폼 | 카탈로그 | 설명 |
|--------|---------|------|
| Server | `docs/wowa/server-catalog.md` | 서버 모듈, API, 미들웨어, 유틸리티 |
| Mobile | `docs/wowa/mobile-catalog.md` | 앱 모듈, 패키지, 위젯, 예외 클래스 |
| Core (상세) | `docs/core/catalog.md` | 공통 기능 상세 분석 인덱스 |

## Documentation References

구현 전 해당 플랫폼 가이드를 먼저 읽으세요.

- **Server**: `.claude/guide/server/` — API 설계, 예외 처리, 로깅
- **Mobile**: `.claude/guide/mobile/` — 디렉토리 구조, GetX, 위젯, 디자인 시스템, 성능
- 각 플랫폼 CLAUDE.md에 상세 가이드 테이블 포함

## Disabled Skills

이 프로젝트에서 다음 Skill은 **사용 금지**입니다. 호출하지 마세요:

| Skill | 이유 |
|-------|------|
| `feature-planner` | PDCA 워크플로우로 대체됨 |
| `commit-commands:commit-push-pr` | 수동 커밋 워크플로우 사용 |
| `coderabbit:review` | CTO 통합 리뷰 + gap-detector로 대체됨 |

> `coderabbit:code-review` (자동 코드 리뷰)는 별도 skill이며 비활성화 대상 아님.
> `commit-commands:commit`, `commit-commands:clean_gone`은 사용 가능.

## Hook System

| Hook | Event | 동작 |
|------|-------|------|
| `auto-validate` | PostToolUse (Edit/Write) | TS/Dart 자동 타입체크 + 린트 |
| `sql-injection-check` | PostToolUse (Edit/Write) | SQL 인젝션 패턴 탐지 |
| `context-enrichment` | UserPromptSubmit | PDCA 상태 + 최근 git 변경사항 자동 주입 |

설정: `.claude/settings.json` / 스크립트: `.claude/hooks/`

## Serena Usage (MANDATORY)

- `find_symbol`: Locate classes, functions, variables
- `get_symbols_overview`: Understand file structure
- `find_referencing_symbols`: Check dependencies before changes
- `insert_after_symbol` / `insert_before_symbol`: For code insertion
- `replace_symbol`: For refactoring
- Never use grep/ripgrep when serena can do semantic search
- Never read entire files — use serena to get relevant symbols only