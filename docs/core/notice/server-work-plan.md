# 서버 작업 분배 계획: 공지사항 (Notice)

## 개요

공지사항 기능의 서버 API 구현을 위한 작업 분배 계획입니다. TDD 사이클(Red → Green → Refactor)을 준수하며, Express 미들웨어 패턴과 Drizzle ORM을 활용합니다.

**Feature**: notice
**Platform**: Server (Node.js, TypeScript, Express)
**Package**: apps/server/src/modules/notice/

---

## 실행 그룹 (Execution Groups)

### Group 1 (병렬) — 선행 작업

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| node-developer | schema | DB 스키마 정의 (notices, notice_reads 테이블) | schema.ts |
| node-developer | validators | Zod 유효성 검증 스키마 작성 | validators.ts |
| node-developer | types | TypeScript 타입 정의 | types.ts |
| node-developer | probe | Domain Probe 로깅 포인트 | notice.probe.ts |

**병렬 실행 가능 이유**:
- 서로 다른 파일에서 작업
- 파일 간 의존성 없음 (각각 독립적인 export)
- schema.ts는 handlers.ts에서 import하지만, Group 1 완료 후 Group 2 진입

**의존성 분석**:
- **Group 1 내부**: 의존성 없음 (완전 독립)
- **Group 2 의존**: handlers.ts는 schema.ts, validators.ts, types.ts, notice.probe.ts를 모두 import

---

### Group 2 (순차) — Group 1 완료 후

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| node-developer | handlers | API 핸들러 구현 (7개 엔드포인트) | handlers.ts |
| node-developer | router | Express Router 설정 | index.ts |

**순차 실행 이유**:
- handlers.ts가 index.ts에서 import됨
- handlers.ts는 Group 1의 모든 파일에 의존

**의존성 분석**:
- **handlers.ts 의존**: schema.ts, validators.ts, types.ts, notice.probe.ts
- **index.ts 의존**: handlers.ts

---

### Group 3 (병렬) — Group 2 완료 후

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| node-developer | tests-handlers | 핸들러 단위 테스트 | tests/unit/notice/handlers.test.ts |
| node-developer | tests-integration | 통합 테스트 (API 엔드투엔드) | tests/integration/notice/api.test.ts |

**병렬 실행 가능 이유**:
- 서로 다른 테스트 파일
- 테스트 간 의존성 없음

**의존성 분석**:
- **tests 의존**: handlers.ts, schema.ts (구현 코드 완료 필수)

---

### Group 4 (순차) — Group 3 완료 후

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| node-developer | migration | Drizzle 마이그레이션 생성 및 적용 | migrations/*.sql |
| node-developer | app-integration | app.ts에 Router 등록 | apps/server/src/app.ts |

**순차 실행 이유**:
- migration은 schema.ts 기반
- app.ts 수정은 router 완료 후

**의존성 분석**:
- **migration 의존**: schema.ts
- **app.ts 의존**: index.ts (router export)

---

## 모듈 간 의존성 그래프

```
Group 1 (병렬)
├── schema.ts (독립)
├── validators.ts (독립)
├── types.ts (독립)
└── notice.probe.ts (독립)
    ↓
Group 2 (순차)
├── handlers.ts (← schema, validators, types, probe)
└── index.ts (← handlers)
    ↓
Group 3 (병렬)
├── handlers.test.ts (← handlers, schema)
└── api.test.ts (← handlers, schema)
    ↓
Group 4 (순차)
├── migration (← schema)
└── app.ts (← index)
```

---

## 작업 상세 (Task Details)

### Group 1: schema (node-developer)

**목표**: Drizzle ORM 스키마 정의

**파일**: `apps/server/src/modules/notice/schema.ts`

**작업 내용**:
1. notices 테이블 정의:
   - 컬럼: id, appCode, title, content, category, isPinned, viewCount, authorId, createdAt, updatedAt, deletedAt
   - 인덱스: appCode, isPinned, deletedAt, createdAt, category
2. notice_reads 테이블 정의:
   - 컬럼: id, noticeId, userId, readAt
   - UNIQUE 제약: (noticeId, userId)
   - 인덱스: userId, noticeId
3. JSDoc 주석 (한국어)

**TDD 사이클**:
1. Red: 스키마 타입 추론 테스트 작성
2. Green: 스키마 정의 작성
3. Refactor: 주석 추가, 인덱스 최적화

**참조 문서**:
- docs/core/notice/server-brief.md (스키마 명세)

---

### Group 1: validators (node-developer)

**목표**: Zod 유효성 검증 스키마 작성

**파일**: `apps/server/src/modules/notice/validators.ts`

**작업 내용**:
1. listNoticesSchema (쿼리 파라미터)
2. createNoticeSchema (공지 작성)
3. updateNoticeSchema (공지 수정)
4. pinNoticeSchema (고정/해제)
5. noticeIdSchema (ID 파라미터)

**TDD 사이클**:
1. Red: 각 스키마 검증 실패 테스트
2. Green: Zod 스키마 정의
3. Refactor: 에러 메시지 한국어 추가

**참조 문서**:
- docs/core/notice/server-brief.md (검증 규칙)

---

### Group 1: types (node-developer)

**목표**: TypeScript 타입 정의

**파일**: `apps/server/src/modules/notice/types.ts`

**작업 내용**:
1. NoticeSummary (목록 응답)
2. NoticeDetail (상세 응답)
3. NoticeListResponse (페이지네이션 래퍼)
4. UnreadCountResponse (읽지 않은 개수)
5. JwtPayload (인증 토큰)

**TDD 사이클**:
- 타입 정의는 컴파일 타임 검증 (별도 테스트 불필요)

**참조 문서**:
- docs/core/notice/server-brief.md (응답 형식)

---

### Group 1: probe (node-developer)

**목표**: Domain Probe 로깅 포인트 작성

**파일**: `apps/server/src/modules/notice/notice.probe.ts`

**작업 내용**:
1. created() — 공지 생성 성공
2. updated() — 공지 수정
3. deleted() — 공지 삭제 (soft)
4. pinToggled() — 고정/해제
5. viewed() — 상세 조회
6. notFound() — 공지 미존재

**TDD 사이클**:
1. Red: logger.info, logger.warn 호출 확인 테스트
2. Green: 각 함수 구현
3. Refactor: 로그 메시지 명확화

**참조 문서**:
- .claude/guide/server/logging-best-practices.md

---

### Group 2: handlers (node-developer)

**목표**: API 핸들러 구현 (7개 엔드포인트)

**파일**: `apps/server/src/modules/notice/handlers.ts`

**작업 내용**:
1. listNotices — GET /notices (목록 조회)
2. getNotice — GET /notices/:id (상세 조회)
3. getUnreadCount — GET /notices/unread-count (읽지 않은 개수)
4. createNotice — POST /notices (작성)
5. updateNotice — PUT /notices/:id (수정)
6. deleteNotice — DELETE /notices/:id (삭제)
7. pinNotice — PATCH /notices/:id/pin (고정/해제)

**TDD 사이클 (각 핸들러마다)**:
1. Red: 핸들러 실패 테스트 작성 (Mock DB)
2. Green: 비즈니스 로직 구현
3. Refactor: 중복 코드 제거, 에러 처리 개선

**핵심 비즈니스 로직**:
- appCode 기반 멀티테넌트 분리
- 고정/일반 공지 정렬 (isPinned DESC, createdAt DESC)
- LEFT JOIN으로 isRead 계산
- 조회수 증가 + 읽음 처리 (상세 조회 시)
- 관리자 권한 검증 (X-Admin-Secret)

**참조 문서**:
- docs/core/notice/server-brief.md (비즈니스 로직)
- .claude/guide/server/exception-handling.md

---

### Group 2: router (node-developer)

**목표**: Express Router 설정

**파일**: `apps/server/src/modules/notice/index.ts`

**작업 내용**:
1. Router 인스턴스 생성
2. authMiddleware 적용 (전체 라우트)
3. 사용자 API 라우트 등록 (GET /, GET /unread-count, GET /:id)
4. 관리자 API 라우트 등록 (POST /, PUT /:id, DELETE /:id, PATCH /:id/pin)
5. Router export

**TDD 사이클**:
1. Red: 라우트 매핑 확인 테스트
2. Green: Router 설정
3. Refactor: 미들웨어 순서 최적화

**참조 문서**:
- docs/core/notice/server-brief.md (Router 설정)

---

### Group 3: tests-handlers (node-developer)

**목표**: 핸들러 단위 테스트

**파일**: `apps/server/tests/unit/notice/handlers.test.ts`

**작업 내용**:
1. listNotices 테스트 (페이지네이션, 고정 공지 정렬)
2. getNotice 테스트 (조회수 증가, 읽음 처리)
3. getUnreadCount 테스트 (COUNT 쿼리)
4. createNotice 테스트 (관리자 권한, Zod 검증)
5. updateNotice 테스트 (appCode 확인)
6. deleteNotice 테스트 (soft delete)
7. pinNotice 테스트 (isPinned 토글)

**TDD 사이클**:
- 이미 TDD로 작성된 핸들러를 테스트 (검증)

**참조 문서**:
- docs/core/notice/server-brief.md (테스트 전략)

---

### Group 3: tests-integration (node-developer)

**목표**: 통합 테스트 (API 엔드투엔드)

**파일**: `apps/server/tests/integration/notice/api.test.ts`

**작업 내용**:
1. 공지 작성 → 목록 조회 → 상세 조회 → 읽음 상태 확인 (전체 플로우)
2. 고정 공지 정렬 확인
3. 페이지네이션 동작 확인
4. 404 에러 (삭제된 공지)
5. 403 에러 (관리자 권한 없음)

**TDD 사이클**:
- 통합 테스트는 구현 완료 후 검증

**참조 문서**:
- docs/core/notice/user-story.md (시나리오)

---

### Group 4: migration (node-developer)

**목표**: Drizzle 마이그레이션 생성 및 적용

**작업 내용**:
1. `pnpm drizzle-kit generate` 실행
2. 생성된 마이그레이션 파일 확인 (apps/server/migrations/*)
3. `pnpm drizzle-kit migrate` 실행 (개발 환경)
4. Supabase MCP로 테이블 생성 확인 (SELECT 쿼리만)

**중요**:
- ⚠️ Supabase MCP는 읽기 전용 (SELECT만 허용)
- ⚠️ DDL 작업은 사용자에게 실행 요청

**참조 문서**:
- apps/server/CLAUDE.md (마이그레이션 정책)

---

### Group 4: app-integration (node-developer)

**목표**: app.ts에 Router 등록

**파일**: `apps/server/src/app.ts`

**작업 내용**:
1. notice router import
2. `app.use('/notices', noticeRouter)` 추가
3. 앱 재시작 후 동작 확인

**TDD 사이클**:
- 통합 테스트로 검증 (Group 3에서 이미 작성)

**참조 문서**:
- docs/core/notice/server-brief.md (Router 설정)

---

## 작업 순서 요약

1. **Group 1 시작**: 4명의 node-developer를 동시에 투입하여 schema, validators, types, probe 병렬 작업
2. **Group 1 완료 확인**: 모든 파일이 export되고 컴파일 성공
3. **Group 2 시작**: handlers.ts 작성 (TDD), 완료 후 index.ts 작성
4. **Group 2 완료 확인**: 모든 핸들러 구현 완료, 테스트 통과
5. **Group 3 시작**: 2명의 node-developer가 단위 테스트와 통합 테스트 병렬 작업
6. **Group 3 완료 확인**: 모든 테스트 통과 (`pnpm test`)
7. **Group 4 시작**: migration 생성 → app.ts 수정
8. **Group 4 완료 확인**: 마이그레이션 적용 완료, 앱 재시작 성공

---

## 공통 원칙 (모든 Agent 준수)

### TDD 사이클 (Red → Green → Refactor)

1. **Red**: 실패하는 테스트 작성
2. **Green**: 테스트를 통과하는 최소한의 코드 작성
3. **Refactor**: 중복 제거, 구조 개선, 주석 추가

### Express 미들웨어 패턴

- Controller/Service 분리 안 함
- 비즈니스 로직은 handlers.ts에 직접 작성
- 복잡한 DB 쿼리만 services.ts로 분리 (YAGNI)

### Drizzle ORM

- Prepared Statement 자동 적용
- SQL Injection 방지
- camelCase → snake_case 자동 변환

### 에러 처리

- AppException 계층 구조 활용
- NotFoundException (404)
- ValidationException (400)
- ForbiddenException (403)

### JSDoc 주석

- 모든 함수, 테이블, 컬럼에 한국어 주석
- 복잡한 비즈니스 로직은 상세 주석

### Domain Probe

- logger.info: 성공 이벤트
- logger.warn: 복구 가능 오류
- logger.error: 예상 밖 오류 (Global Error Handler 처리)

---

## 환경변수 설정

**파일**: `apps/server/.env`

```bash
# 관리자 인증 (향후 개선 필요)
ADMIN_SECRET=your-strong-secret-key
```

---

## 검증 기준 (CTO 통합 리뷰)

- [ ] 모든 테스트 통과 (`pnpm test`)
- [ ] 빌드 성공 (`pnpm build`)
- [ ] Drizzle 마이그레이션 적용 완료
- [ ] API 엔드포인트 7개 동작 확인 (Postman/Insomnia)
- [ ] appCode 멀티테넌트 분리 검증
- [ ] 관리자 권한 검증 (X-Admin-Secret)
- [ ] Soft delete (deletedAt) 동작 확인
- [ ] 페이지네이션 hasNext 정확성
- [ ] Domain Probe 로그 출력 확인
- [ ] JSDoc 주석 완성도

---

## 참고 문서

- **사용자 스토리**: docs/core/notice/user-story.md
- **서버 설계**: docs/core/notice/server-brief.md
- **API Response 가이드**: .claude/guide/server/api-response-design.md
- **예외 처리 가이드**: .claude/guide/server/exception-handling.md
- **로깅 가이드**: .claude/guide/server/logging-best-practices.md
- **서버 CLAUDE.md**: apps/server/CLAUDE.md

---

## 다음 단계

1. CTO가 work-plan 검토 및 승인
2. Task 도구로 각 Agent에게 작업 위임 (subagent_type="node-developer")
3. Group 1 → 2 → 3 → 4 순차 진행
4. CTO 통합 리뷰 (server-cto-review.md 작성)
5. Independent Reviewer 최종 검증
