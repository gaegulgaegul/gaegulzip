# 서버 작업 분배 계획: 푸시 알림 (Push Notification)

## 개요

기존 FCM 발송 인프라를 기반으로 **사용자별 알림 수신 기록(Receipt) 관리**, **읽음 상태 처리**, **앱 내 알림 목록 API**를 추가합니다.

**작업 방식**: TDD 사이클 (Red → Green → Refactor) 준수

---

## 실행 그룹

### Group 1 (순차 실행) — Server 전체 작업

모든 Server 작업은 **단일 개발자(node-developer)**가 **순차적으로** TDD 방식으로 진행합니다.

| 순서 | 모듈 | 개발자 | 설명 |
|------|------|--------|------|
| 1 | DB Schema | node-developer | push_notification_receipts 테이블 생성 |
| 2 | Service 함수 | node-developer | Receipt CRUD, 읽음 처리, 알림 목록 조회 |
| 3 | Validator | node-developer | 알림 목록 조회 쿼리 파라미터 검증 |
| 4 | Handler | node-developer | 신규 API 핸들러 3개 + sendPush 수정 |
| 5 | Router | node-developer | 라우트 등록 및 인증 미들웨어 추가 |
| 6 | Probe | node-developer | 운영 로그 함수 추가 |
| 7 | 통합 테스트 | node-developer | 전체 플로우 검증 |

**의존성**: 1 → 2 → 3 → 4 → 5 → 6 → 7 (순차 실행)

---

## Module Contracts (모듈 간 계약)

### 1. DB Schema → Service 함수

**Input**:
- `pushNotificationReceipts` 테이블 정의 (schema.ts)
- 인덱스: `(userId, appId, receivedAt)` 복합 인덱스

**Output**:
- Drizzle 마이그레이션 파일 생성
- 로컬 DB 적용 완료

**검증 기준**:
- `pnpm drizzle-kit generate` 성공
- `pnpm drizzle-kit migrate` 성공
- Supabase Studio에서 테이블 및 인덱스 확인

---

### 2. Service 함수 → Handler

**Input**:
- `createReceiptsForUsers(data)` — 발송 시 Receipt 생성
- `findNotificationsByUser(userId, appId, options)` — 알림 목록 조회
- `countUnreadNotifications(userId, appId)` — 읽지 않은 개수
- `markNotificationAsRead(id, userId, appId)` — 읽음 처리
- `findNotificationById(id, userId, appId)` — 알림 상세 조회 (권한 검증 포함)

**Output**:
- 각 함수의 반환값:
  - `createReceiptsForUsers`: `Promise<Array<Receipt>>`
  - `findNotificationsByUser`: `Promise<Array<Receipt>>`
  - `countUnreadNotifications`: `Promise<number>`
  - `markNotificationAsRead`: `Promise<boolean>`
  - `findNotificationById`: `Promise<Receipt | null>`

**검증 기준**:
- 단위 테스트 통과 (Vitest)
- 권한 검증 동작 확인 (다른 사용자 알림 접근 불가)

---

### 3. Validator → Handler

**Input**:
- `listMyNotificationsSchema` (Zod 스키마)
  - `limit`: number (1~100, 기본값 20)
  - `offset`: number (≥0, 기본값 0)
  - `unreadOnly`: boolean (optional)

**Output**:
- Zod 파싱 결과 객체: `{ limit, offset, unreadOnly? }`

**검증 기준**:
- 유효한 입력 파싱 성공
- 잘못된 입력 시 `ZodError` 발생

---

### 4. Handler → Router

**Input**:
- 신규 핸들러:
  - `listMyNotifications` — GET /push/notifications/me
  - `getUnreadCount` — GET /push/notifications/unread-count
  - `markAsRead` — PATCH /push/notifications/:id/read
- 수정 핸들러:
  - `sendPush` — POST /push/send (Receipt 생성 로직 추가)

**Output**:
- HTTP 응답 (JSON):
  - `listMyNotifications`: `{ notifications: Array<Notification>, total: number }`
  - `getUnreadCount`: `{ unreadCount: number }`
  - `markAsRead`: `{ success: true }`

**검증 기준**:
- 단위 테스트 통과 (핸들러 mock 테스트)
- 에러 처리 정상 동작 (NotFoundException, ValidationException)

---

### 5. Router → 통합 테스트

**Input**:
- 라우트 등록:
  - `GET /push/notifications/me` — `authenticate` 미들웨어 포함
  - `GET /push/notifications/unread-count` — `authenticate` 미들웨어 포함
  - `PATCH /push/notifications/:id/read` — `authenticate` 미들웨어 포함
  - `POST /push/send` — `authenticate` 미들웨어 추가

**Output**:
- Express Router 인스턴스

**검증 기준**:
- 인증 없는 요청 시 401 응답
- 라우트 순서 정확 (`/notifications/me`가 `/notifications/:id`보다 먼저 등록)

---

## 작업 상세

### 작업 1: DB Schema 정의 및 마이그레이션

**담당자**: node-developer
**예상 소요 시간**: 30분

#### 목표
- `push_notification_receipts` 테이블 생성
- 복합 인덱스 추가 (성능 최적화)

#### 구현 파일
- `apps/server/src/modules/push-alert/schema.ts` (수정)

#### TDD 사이클
1. **Red**: 마이그레이션 파일 없음 (당연히 실패)
2. **Green**: Drizzle 스키마 정의 작성
3. **Refactor**: 주석 추가, 인덱스 최적화

#### 체크리스트
- [ ] `pushNotificationReceipts` 테이블 정의 추가
- [ ] 모든 컬럼에 JSDoc 주석 작성 (한국어)
- [ ] 인덱스 5개 추가:
  - `appId`, `userId`, `alertId`, `isRead`, `receivedAt`
  - 복합 인덱스: `(userId, appId, receivedAt)`
- [ ] `pnpm drizzle-kit generate` 실행
- [ ] `pnpm drizzle-kit migrate` 실행 (로컬 DB)
- [ ] Supabase Studio에서 테이블 확인

#### 참조 문서
- `docs/wowa/push-alert/server-brief.md` (스키마 정의 섹션)
- `.claude/guide/server/exception-handling.md`

---

### 작업 2: Service 함수 구현

**담당자**: node-developer
**예상 소요 시간**: 2시간

#### 목표
- Receipt CRUD 로직 구현
- 권한 검증 포함 (userId, appId)

#### 구현 파일
- `apps/server/src/modules/push-alert/services.ts` (수정)

#### TDD 사이클 (함수별)
각 함수마다 Red → Green → Refactor 사이클 반복

**createReceiptsForUsers**:
1. **Red**: 테스트 작성 — "should create receipts for all target users"
2. **Green**: 배치 INSERT 구현
3. **Refactor**: 빈 배열 처리, 에러 핸들링

**findNotificationsByUser**:
1. **Red**: 테스트 작성 — "should return notifications ordered by receivedAt DESC"
2. **Green**: Drizzle 쿼리 작성 (limit, offset, unreadOnly 필터)
3. **Refactor**: 복합 인덱스 활용 확인

**countUnreadNotifications**:
1. **Red**: 테스트 작성 — "should count unread notifications"
2. **Green**: `count()` 쿼리 작성
3. **Refactor**: 기본값 0 반환

**markNotificationAsRead**:
1. **Red**: 테스트 작성 — "should prevent access to other user notification"
2. **Green**: UPDATE with userId, appId WHERE 조건
3. **Refactor**: 멱등성 보장 (중복 읽음 처리 안전)

**findNotificationById**:
1. **Red**: 테스트 작성 — "should return null for non-existent notification"
2. **Green**: SELECT with WHERE 조건
3. **Refactor**: 권한 검증 포함

#### 체크리스트
- [ ] 5개 Service 함수 구현
- [ ] 모든 함수에 JSDoc 주석 작성 (한국어)
- [ ] 권한 검증 로직 포함 (userId, appId)
- [ ] 단위 테스트 작성 (`tests/unit/push-alert/services.test.ts`)
- [ ] 모든 테스트 통과 (`pnpm test`)

#### 참조 문서
- `docs/wowa/push-alert/server-brief.md` (Service 함수 섹션)
- `.claude/guide/server/api-response-design.md`

---

### 작업 3: Validator 추가

**담당자**: node-developer
**예상 소요 시간**: 15분

#### 목표
- 알림 목록 조회 쿼리 파라미터 검증

#### 구현 파일
- `apps/server/src/modules/push-alert/validators.ts` (수정)

#### TDD 사이클
1. **Red**: 테스트 작성 — "should parse valid query parameters"
2. **Green**: Zod 스키마 작성 (`listMyNotificationsSchema`)
3. **Refactor**: 기본값 설정, 최대값 제한 (limit ≤ 100)

#### 체크리스트
- [ ] `listMyNotificationsSchema` 작성
- [ ] `limit` 기본값 20, 최대값 100
- [ ] `offset` 기본값 0, 최소값 0
- [ ] `unreadOnly` 선택적 boolean
- [ ] 단위 테스트 작성 (optional)

#### 참조 문서
- 기존 `validators.ts` 파일 참조

---

### 작업 4: Handler 구현

**담당자**: node-developer
**예상 소요 시간**: 1.5시간

#### 목표
- 신규 API 핸들러 3개 구현
- `sendPush` 핸들러 수정 (Receipt 생성 로직 추가)

#### 구현 파일
- `apps/server/src/modules/push-alert/handlers.ts` (수정)

#### TDD 사이클 (핸들러별)

**listMyNotifications**:
1. **Red**: 테스트 작성 — "should return user notifications"
2. **Green**: Service 함수 호출 + JSON 응답
3. **Refactor**: camelCase 필드명, ISO-8601 날짜 변환

**getUnreadCount**:
1. **Red**: 테스트 작성 — "should return unread count"
2. **Green**: Service 함수 호출 + JSON 응답
3. **Refactor**: 간결한 응답 형식

**markAsRead**:
1. **Red**: 테스트 작성 — "should mark notification as read"
2. **Green**: Service 함수 호출 + Domain Probe 호출
3. **Refactor**: 404 에러 처리 (권한 없거나 존재하지 않는 알림)

**sendPush (수정)**:
1. **Red**: 테스트 작성 — "should create receipts after FCM send"
2. **Green**: FCM 발송 후 `createReceiptsForUsers()` 호출 추가
3. **Refactor**: 기존 로직 유지, Receipt 생성 로직만 추가

#### 체크리스트
- [ ] 4개 핸들러 구현/수정
- [ ] 모든 핸들러에 JSDoc 주석 작성 (한국어, @param, @returns)
- [ ] `req.user`에서 userId, appId 추출 (타입 단언)
- [ ] 응답 형식: camelCase, ISO-8601 날짜, null 처리
- [ ] 단위 테스트 작성 (`tests/unit/push-alert/handlers.test.ts`)
- [ ] 모든 테스트 통과

#### 참조 문서
- `docs/wowa/push-alert/server-brief.md` (Handler 섹션)
- `.claude/guide/server/api-response-design.md`
- `.claude/guide/server/exception-handling.md`

---

### 작업 5: 라우터 업데이트

**담당자**: node-developer
**예상 소요 시간**: 15분

#### 목표
- 신규 라우트 등록
- 기존 라우트에 인증 미들웨어 추가

#### 구현 파일
- `apps/server/src/modules/push-alert/index.ts` (수정)

#### TDD 사이클
1. **Red**: 테스트 작성 — "should require authentication for user endpoints"
2. **Green**: 라우트 등록 + `authenticate` 미들웨어 추가
3. **Refactor**: 라우트 순서 최적화 (`/notifications/me`가 `/notifications/:id`보다 먼저)

#### 체크리스트
- [ ] 신규 라우트 3개 등록:
  - `GET /notifications/me` (authenticate)
  - `GET /notifications/unread-count` (authenticate)
  - `PATCH /notifications/:id/read` (authenticate)
- [ ] 기존 라우트에 인증 추가:
  - `POST /send` (authenticate)
  - `GET /notifications` (authenticate)
  - `GET /notifications/:id` (authenticate)
- [ ] 라우트 순서 확인 (명시적 경로 우선)
- [ ] 통합 테스트 작성 (optional)

#### 참조 문서
- `docs/wowa/push-alert/server-brief.md` (라우터 섹션)
- 기존 `index.ts` 파일 참조

---

### 작업 6: 운영 로그 추가

**담당자**: node-developer
**예상 소요 시간**: 15분

#### 목표
- Domain Probe 패턴으로 운영 로그 함수 추가

#### 구현 파일
- `apps/server/src/modules/push-alert/push.probe.ts` (수정)

#### TDD 사이클
1. **Red**: 테스트 작성 (optional) — "should log notification read event"
2. **Green**: Probe 함수 2개 추가
3. **Refactor**: 민감 정보 제외 (title, body 로깅 금지)

#### 체크리스트
- [ ] `receiptsCreated(data)` 함수 추가
- [ ] `notificationRead(data)` 함수 추가
- [ ] 로그에 ID, userId, appId만 포함 (알림 내용 제외)
- [ ] 핸들러에서 Probe 함수 호출
- [ ] 로그 레벨: INFO

#### 참조 문서
- `.claude/guide/server/logging-best-practices.md`
- 기존 `push.probe.ts` 파일 참조

---

### 작업 7: 통합 테스트

**담당자**: node-developer
**예상 소요 시간**: 1시간

#### 목표
- 전체 플로우 검증 (발송 → 조회 → 읽음 처리)

#### 구현 파일
- `tests/integration/push-alert-flow.test.ts` (신규)

#### TDD 사이클
1. **Red**: 통합 테스트 작성 — "should create receipt and allow user to read"
2. **Green**: 전체 플로우 실행
3. **Refactor**: 테스트 데이터 정리, 트랜잭션 롤백

#### 체크리스트
- [ ] 테스트 시나리오:
  1. 알림 발송 (POST /push/send)
  2. 알림 목록 조회 (GET /push/notifications/me)
  3. 읽음 처리 (PATCH /push/notifications/:id/read)
  4. 읽음 상태 확인 (GET /push/notifications/me)
- [ ] 인증 토큰 모킹 (JWT)
- [ ] 데이터베이스 트랜잭션 롤백 (테스트 격리)
- [ ] 모든 테스트 통과

#### 참조 문서
- `docs/wowa/push-alert/server-brief.md` (통합 테스트 섹션)

---

## 검증 기준

### 기능 검증
- [ ] 알림 발송 시 Receipt가 대상 사용자별로 생성됨
- [ ] 사용자는 자신의 앱 알림만 조회 가능 (다른 앱/사용자 알림 접근 불가)
- [ ] 읽지 않은 알림 개수가 정확히 표시됨
- [ ] 알림 읽음 처리 후 `isRead = true`, `readAt` 업데이트됨
- [ ] 페이지네이션이 정상 작동함 (limit, offset)
- [ ] `unreadOnly=true` 필터링이 정상 작동함

### 보안 검증
- [ ] 인증되지 않은 요청은 401 응답
- [ ] 다른 사용자의 알림 접근 시 404 응답 (권한 오류 노출 방지)
- [ ] 다른 앱의 알림 접근 시 404 응답
- [ ] `/push/send` 엔드포인트에 인증 적용됨

### 성능 검증
- [ ] 1000명 대상 Receipt 생성: 1초 이내
- [ ] 알림 목록 조회 (20개): 100ms 이내
- [ ] 복합 인덱스가 쿼리에서 활용됨 (`EXPLAIN` 확인)

### 코드 품질
- [ ] Express 컨벤션 준수 (handler, service, validator 분리)
- [ ] API Response 가이드 준수 (camelCase, null 처리, ISO-8601)
- [ ] 예외 처리 가이드 준수 (AppException 계층, 추적 가능한 메시지)
- [ ] 로깅 가이드 준수 (Domain Probe 패턴, 민감 정보 제외)
- [ ] Drizzle ORM 패턴 준수 (FK 없음, 컬럼 주석)
- [ ] 단위 테스트 작성 완료
- [ ] 모든 테스트 통과 (`pnpm test`)

---

## 참고 자료

- **User Story**: `docs/wowa/push-alert/user-story.md`
- **Brief**: `docs/wowa/push-alert/server-brief.md`
- **Server Catalog**: `docs/wowa/server-catalog.md`
- **API 응답 설계**: `.claude/guide/server/api-response-design.md`
- **예외 처리**: `.claude/guide/server/exception-handling.md`
- **로깅**: `.claude/guide/server/logging-best-practices.md`

---

## 마이그레이션 체크리스트

1. [ ] 로컬 환경에서 마이그레이션 실행 및 검증
2. [ ] Staging 환경 배포 전 백업
3. [ ] Staging 환경 마이그레이션 및 smoke test
4. [ ] Production 배포 전 롤백 계획 수립
5. [ ] Production 마이그레이션 (off-peak 시간대)
6. [ ] Production 모니터링 (에러 로그, 쿼리 성능)

---

## 완료 조건

- [ ] 모든 작업 체크리스트 완료
- [ ] 단위 테스트 100% 통과
- [ ] 통합 테스트 통과
- [ ] 코드 리뷰 완료 (CTO)
- [ ] 마이그레이션 실행 완료
- [ ] Staging 환경 배포 및 검증
