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

> 아래 1~4번은 `coding-discipline.md`에 Anti-pattern과 함께 상세 기술. 여기는 요약만.

- **Surface Assumptions**: 구현 전 가정을 명시. 여러 해석이 가능하면 조용히 하나를 선택하지 말고 제시. 불확실하면 멈추고 질문.
- **Simplicity First**: 요청된 것만 구현. 단일 사용 추상화 금지. 200줄을 50줄로 줄일 수 있으면 줄일 것. 자가 검증: "시니어 엔지니어가 과하다고 할까?"
- **Surgical Changes**: 요청과 직접 관련된 코드만 변경. 인접 코드 "개선" 금지. 기존 스타일과 다르더라도 맞출 것. 자기 변경으로 생긴 고아만 정리하고 기존 dead code는 언급만. 검증: "모든 변경 라인이 요청에 직접 연결되는가?"
- **Goal-Driven Execution**: 모든 작업을 검증 가능한 목표로 변환. "버그 수정" → "버그 재현 테스트 작성 후 통과시키기". 멀티스텝 작업은 각 스텝에 verify 체크포인트 명시.
- **No backwards-compatibility hacks**: Delete unused code completely instead of renaming or commenting
- **SDK = Flutter 패키지만** — 서버는 `modules/`로 유지 (상세: Mobile CLAUDE.md)
- **File System = SSOT**: 파일 시스템이 유일한 진실의 원천(Single Source of Truth). 에이전트 간 상태 전달 시 결과 텍스트가 아닌 파일에서 직접 읽기
- **Context Compaction Recovery**: 컨텍스트 압축 후 복구 우선순위: (1) `.pdca-status.json` → (2) 작업 문서 (`work-plan.md`, `brief.md`) → (3) `git diff` → (4) `CLAUDE.md`
- **Context Hygiene**: 실효 컨텍스트는 명시 윈도우의 ~50-60%. 복잡한 멀티에이전트 작업(Do, Iterate) 중 컨텍스트 부패 징후(목표 망각, 반복 실수, 이전 결정 무시)가 보이면 `/compact` 사용. 압축 후 `context-recovery.sh`가 핵심 정보 자동 재주입.
- **User = Product Owner**: 사용자가 최종 의사결정자. 기술적 옵션을 제시하되 선택은 사용자 몫. 사용자가 명시적으로 위임하지 않는 한 중요한 결정을 독단적으로 내리지 않는다.
- **Translate, Don't Jargon**: 기술 결정을 설명할 때 비유나 plain language 사용. "이렇게 하면 ~~한 장점이 있고, 대신 ~~한 트레이드오프가 있습니다" 형태로 전달. 사용자가 따라올 수 있는 속도로 진행.
- **Honest Limitations**: 한계가 있으면 솔직하게 말하고 대안 제시. 확신이 없는 부분을 확정적으로 말하지 않는다. "이건 잘 모르겠지만, ~~해볼 수 있습니다"가 "됩니다"보다 낫다.

## Core Features (재사용 가능한 공통 기능)

새 제품/기능 개발 시 아래 카탈로그에서 기존 구현을 확인하고 재사용하세요.

| 플랫폼 | 카탈로그 | 설명 |
|--------|---------|------|
| Server | `docs/wowa/server-catalog.md` | 서버 모듈, API, 미들웨어, 유틸리티 |
| Mobile | `docs/wowa/mobile-catalog.md` | 앱 모듈, 패키지, 위젯, 예외 클래스 |
| Core (상세) | `docs/core/catalog.md` | 공통 기능 상세 분석 인덱스 |

## Documentation References

구현 전 해당 플랫폼 가이드를 먼저 읽으세요.

- **공통**: `.claude/guide/engineering-preferences.md` — 엔지니어링 품질 기준 (DRY, 테스트, Edge Case 정책)
- **공통**: `.claude/guide/coding-discipline.md` — 구현 시점 판단 규칙
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

## Model Selection Guide

Task 에이전트 호출 시 `model` 파라미터로 비용/속도 최적화:

| 작업 유형 | 권장 모델 | 이유 |
|-----------|----------|------|
| 탐색/검색 (Explore) | `haiku` | 읽기 전용, 속도 우선 |
| 단순 구현 (단일 모듈, 린트 수정) | `sonnet` | 비용 효율, 충분한 능력 |
| 설계/리뷰/복잡한 구현 | `opus` (기본값) | 정확도와 판단력 필요 |

> 기본값은 opus. 명시적으로 지정하지 않으면 부모 세션의 모델을 상속.

## MCP Context Cost

MCP 서버 도구는 세션 시작 시 전부 로드되어 컨텍스트를 소비한다. 사용하지 않는 플러그인이 많으면 `settings.json`에서 비활성화하여 컨텍스트 여유를 확보할 것.

## Serena Usage (MANDATORY)

- `find_symbol`: Locate classes, functions, variables
- `get_symbols_overview`: Understand file structure
- `find_referencing_symbols`: Check dependencies before changes
- `insert_after_symbol` / `insert_before_symbol`: For code insertion
- `replace_symbol`: For refactoring
- Never use grep/ripgrep when serena can do semantic search
- Never read entire files — use serena to get relevant symbols only