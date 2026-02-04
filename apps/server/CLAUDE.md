# Server CLAUDE.md

gaegulzip-server — TypeScript/Express backend with Drizzle ORM + PostgreSQL (Supabase)

## Commands

```bash
pnpm dev                    # Development (hot reload)
pnpm build                  # Build for production
pnpm start                  # Run production build
pnpm test                   # Run all unit tests
pnpm test:watch             # Watch mode

# Drizzle migrations
pnpm drizzle-kit generate   # Generate migration files
pnpm drizzle-kit migrate    # Apply migrations
pnpm drizzle-kit push       # Push schema changes (dev only)
```

## Environment Variables

Required in `.env`:
- `PORT` — Server port (default: 3001)
- `DATABASE_URL` — PostgreSQL connection string

## Project Structure

```
src/
├── config/                 # Configuration (db, env)
├── modules/                # Feature-based modules
│   └── [feature]/
│       ├── index.ts        # Router export
│       ├── handlers.ts     # Request handlers (middleware functions)
│       ├── schema.ts       # Drizzle schema
│       └── middleware.ts   # Feature-specific middleware (optional)
├── middleware/             # Shared Express middleware
├── utils/                  # Shared utilities
├── app.ts                  # Express app setup
└── server.ts               # Entry point
```

## Express Conventions

- Handler = 미들웨어 함수 `(req, res, next) => {}`
- Controller/Service 패턴 사용 안 함 (NestJS 스타일 금지)
- 비즈니스 로직은 handler에 유지, 복잡해지면 그때 분리 (YAGNI)
- 전역 에러 핸들러에서 에러 처리, 각 handler에서 try-catch 금지

📖 [예외 처리 가이드](../../.claude/guide/server/exception-handling.md): 예외 클래스 계층, 추적 가능한 예외, 외부 SDK 예외 감싸기

## API Response Design

📖 [API Response 설계 가이드](../../.claude/guide/server/api-response-design.md)

- 최소 스펙: 현재 필요한 필드만 (추가는 쉽지만 제거는 Breaking Change)
- camelCase 필드명, 축약 금지
- 빈 배열은 `[]` (null 금지), Boolean은 `true/false`만 (null 금지)
- ISO-8601 날짜, 문자열 Enum

## Drizzle ORM

- **테이블/컬럼 주석 필수**: 모든 테이블과 컬럼에 comment 추가
- **FK 사용 금지**: 애플리케이션 레벨에서 관계 관리

📖 Supabase Postgres 참조:
- [Supabase Postgres Best Practices](https://github.com/supabase/agent-skills/tree/main/skills/supabase-postgres-best-practices)
- [Postgres Best Practices](https://github.com/supabase/agent-skills/tree/main/skills/postgres-best-practices)

**주의**: RLS(Row Level Security) 사용 안 함, 참조 시 RLS 내용 무시

## Logging

📖 [로깅 베스트 프랙티스](../../.claude/guide/server/logging-best-practices.md)

- DEBUG(개발), INFO(비즈니스 이벤트), WARN(잠재적 문제), ERROR(즉시 대응)
- **Domain Probe 패턴**: 운영 로그는 별도 `*.probe.ts`로 분리, 디버그는 handler 내 직접 작성
- 민감 정보(비밀번호, 토큰) 로깅 금지

## Code Documentation

모든 코드에 JSDoc 주석 작성 (클래스, 함수, 상수)

## Testing

- Unit tests only (Vitest), 핸들러와 유틸리티 중심
- 외부 의존성 mock
- 테스트명: `should return user when valid id provided`
