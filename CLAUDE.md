# CLAUDE.md

**모든 대화는 한국어로 진행**

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
│   │       ├── api/         # HTTP client, data models
│   │       └── design_system/ # UI components, theme
│   └── web/
│       └── admin/           # Next.js admin dashboard (shadcn/ui)
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
| Web | `apps/web/admin/CLAUDE.md` | Next.js 16 + shadcn/ui, Tailwind CSS, Playwright E2E only |

## Core Principles

- **Avoid over-engineering**: Make only necessary changes, don't add features beyond what's requested
- **No backwards-compatibility hacks**: Delete unused code completely instead of renaming or commenting

## SDK Convention

- **SDK는 항상 모바일(Flutter) 패키지만 해당** — `apps/mobile/packages/` 하위에 생성
- **서버는 SDK로 추출하지 않음** — 서버 기능은 `apps/server/src/modules/` 내 모듈로 유지
- 서버 API를 모바일에서 사용할 때: 모바일 SDK 패키지가 서버 API를 호출하는 구조

## Core Features (재사용 가능한 공통 기능)

새 제품/기능 개발 시 아래 카탈로그에서 기존 구현을 확인하고 재사용하세요.

| 플랫폼 | 카탈로그 | 설명 |
|--------|---------|------|
| Server | `docs/wowa/server-catalog.md` | 서버 모듈, API, 미들웨어, 유틸리티 |
| Mobile | `docs/wowa/mobile-catalog.md` | 앱 모듈, 패키지, 위젯, 예외 클래스 |
| Core (상세) | `docs/core/catalog.md` | 공통 기능 상세 분석 인덱스 |

## Documentation References

**Read the relevant guide before implementing.**

### Server

| 상황 | 참조 가이드 |
|------|------------|
| API 엔드포인트 작성, 응답 형식 설계 | `.claude/guide/server/api-response-design.md` |
| 에러 처리, AppError 클래스 사용 | `.claude/guide/server/exception-handling.md` |
| 로그 추가, Domain Probe 패턴 | `.claude/guide/server/logging-best-practices.md` |

### Mobile

| 상황 | 참조 가이드 |
|------|------------|
| 새 화면/기능 추가, 디렉토리 구조 결정 | `.claude/guide/mobile/directory_structure.md` |
| GetX Controller, Binding, 상태 관리 | `.claude/guide/mobile/getx_best_practices.md` |
| 위젯 개발, const 생성자, 성능 최적화 | `.claude/guide/mobile/flutter_best_practices.md` |
| UI 컴포넌트, Frame0 스케치 스타일 테마 | `.claude/guide/mobile/design_system.md` |
| 주석 작성 (한글 정책) | `.claude/guide/mobile/comments.md` |
| 에러 처리 (Controller/View) | `.claude/guide/mobile/error_handling.md` |
| 자주 쓰는 위젯, 레이아웃 패턴 | `.claude/guide/mobile/common_widgets.md` |
| Import, 패키지 간 의존성 패턴 | `.claude/guide/mobile/common_patterns.md` |
| 렌더링 성능, 리빌드 최소화 | `.claude/guide/mobile/performance.md` |
| 디자인 토큰 (색상, 타이포, 간격) | `.claude/guide/mobile/design-tokens.json` |
