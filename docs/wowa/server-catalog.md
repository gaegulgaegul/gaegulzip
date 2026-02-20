# Wowa 서버 기능 카탈로그

> 서버에 구현된 기능, 미들웨어, 유틸리티를 빠르게 찾기 위한 카탈로그입니다.
> 상세 분석은 `docs/core/` 하위 문서를 참조하세요.

## 모듈 목록

### 소셜 로그인 (Auth)

- **모듈 경로**: `apps/server/src/modules/auth/`
- **상태**: ✅ 완료 (Apple 서명 검증만 미구현)
- **핵심 파일**:
  - `handlers.ts` — OAuth 로그인, 토큰 갱신, 로그아웃 핸들러
  - `services.ts` — 사용자 Upsert, JWT 생성, 토큰 로테이션
  - `schema.ts` — apps, users, refreshTokens 테이블
  - `providers/` — 카카오, 네이버, 구글, 애플 OAuth 프로바이더
  - `validators.ts` — Zod 입력 검증 스키마
  - `auth.probe.ts` — 운영 로그 (로그인 성공/실패, 토큰 재사용 탐지)
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | POST | `/auth/oauth` | ❌ | OAuth 소셜 로그인 |
  | GET | `/auth/oauth/callback` | ❌ | 카카오 인가 코드 콜백 (테스트용) |
  | POST | `/auth/refresh` | ❌ | Access Token 갱신 |
  | POST | `/auth/logout` | ❌ | 로그아웃 (토큰 폐기) |
- **DB 테이블**: `apps`, `users`, `refresh_tokens`
- **Quick Start**:
  1. `apps` 테이블에 앱 레코드 추가 (OAuth 키, JWT 시크릿 포함)
  2. 클라이언트에서 OAuth SDK로 프로바이더 액세스 토큰 획득
  3. `POST /auth/oauth` 호출: `{ code: "wowa", provider: "kakao", accessToken: "..." }`
  4. 응답의 `accessToken`을 `Authorization: Bearer` 헤더로 사용
  5. 만료 시 `POST /auth/refresh`로 갱신
- **새 프로바이더 추가**: `providers/` 디렉토리에 `IOAuthProvider` 인터페이스 구현 → `providers/index.ts`의 팩토리에 등록
- **상세 분석**: [`docs/core/social-login.md`](../core/social-login.md)

---

### FCM 푸시 알림 (Push Alert)

- **모듈 경로**: `apps/server/src/modules/push-alert/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `handlers.ts` — 디바이스 등록, 알림 발송, 이력 조회, 읽음 처리 핸들러
  - `services.ts` — 디바이스/알림/수신 기록 DB 조작
  - `schema.ts` — pushDeviceTokens, pushAlerts, pushNotificationReceipts 테이블
  - `fcm.ts` — Firebase Admin SDK 래퍼 (인스턴스 캐싱, 배치 발송)
  - `validators.ts` — Zod 입력 검증 스키마
  - `push.probe.ts` — 운영 로그 (발송 성공/실패, 무효 토큰 탐지)
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | POST | `/push/devices` | ✅ | FCM 디바이스 토큰 등록 (upsert) |
  | GET | `/push/devices` | ✅ | 내 디바이스 목록 |
  | POST | `/push/devices/deactivate` | ✅ | 토큰으로 디바이스 비활성화 |
  | DELETE | `/push/devices/:id` | ✅ | ID로 디바이스 비활성화 |
  | POST | `/push/send` | ✅ | 푸시 알림 발송 (single/multiple/all) |
  | GET | `/push/notifications/me` | ✅ | 내 알림 목록 (limit/offset/unreadOnly) |
  | GET | `/push/notifications/unread-count` | ✅ | 읽지 않은 알림 개수 |
  | PATCH | `/push/notifications/:id/read` | ✅ | 알림 읽음 처리 |
  | GET | `/push/notifications` | ✅ | 알림 발송 이력 (관리자용) |
  | GET | `/push/notifications/:id` | ✅ | 알림 발송 상세 (관리자용) |
- **DB 테이블**: `push_device_tokens`, `push_alerts`, `push_notification_receipts`
- **Quick Start**:
  1. `apps` 테이블에 FCM 인증 정보 설정 (`fcmProjectId`, `fcmPrivateKey`, `fcmClientEmail`)
  2. 모바일에서 FCM 토큰 획득 후 `POST /push/devices` 호출
  3. `POST /push/send`로 알림 발송: `{ appCode: "wowa", userId: 1, title: "...", body: "..." }`
  4. 사용자: `GET /push/notifications/me`로 수신 알림 조회
  5. 무효 토큰은 발송 시 자동 비활성화됨
- **상세 분석**: [`docs/core/fcm-push-notification.md`](../core/fcm-push-notification.md)

---

### QnA 질문과 답변 (QnA)

- **모듈 경로**: `apps/server/src/modules/qna/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `handlers.ts` — 질문 제출 핸들러 (submitQuestion)
  - `services.ts` — 질문 생성 로직 (createQuestion, buildIssueBody)
  - `github.ts` — GitHub Issue 생성 (createGitHubIssue), 에러 매핑
  - `octokit.ts` — GitHub App Octokit 인스턴스 팩토리 (캐싱, throttling, retry)
  - `schema.ts` — qna_config, qna_questions Drizzle 테이블
  - `validators.ts` — Zod 입력 검증 (appCode, title 1-256, body 1-65536)
  - `qna.probe.ts` — 운영 로그
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | POST | `/qna/questions` | ⚪ 선택적 | 질문 제출 (GitHub Issue 자동 생성) |
- **DB 테이블**: `qna_config` (앱별 GitHub 설정), `qna_questions` (질문 이력)
- **Quick Start**:
  1. `qna_config` 테이블에 GitHub App 설정 추가
  2. `POST /qna/questions` 호출: `{ appCode: "wowa", title: "질문 제목", body: "질문 내용" }`
  3. 응답: `{ questionId, issueNumber, issueUrl, createdAt }` (201 Created)
  4. 인증된 사용자: `Authorization: Bearer <token>` 헤더 추가 시 질문에 userId 기록
- **상세 설계**: [`docs/core/qna/server-brief.md`](../core/qna/server-brief.md)

---

### 공지사항 (Notice)

- **모듈 경로**: `apps/server/src/modules/notice/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `handlers.ts` — 사용자 목록/상세/미읽음 수, CRUD, 고정/해제 핸들러
  - `admin-handlers.ts` — 관리자 전용 핸들러 (appCode query param 기반)
  - `admin-routes.ts` — 관리자 라우터
  - `schema.ts` — notices, notice_reads 테이블 (soft delete, 읽음 추적)
  - `validators.ts` / `admin-validators.ts` — Zod 입력 검증
  - `notice.probe.ts` — 운영 로그
- **API 엔드포인트 (사용자)**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | GET | `/notices` | ⚪ 선택적 | 공지 목록 (페이지네이션, 카테고리/고정 필터) |
  | GET | `/notices/unread-count` | ⚪ 선택적 | 읽지 않은 공지 수 (미인증 시 0) |
  | GET | `/notices/:id` | ⚪ 선택적 | 공지 상세 (조회수 증가 + 읽음 처리) |
  | POST | `/notices` | ✅ | 공지 작성 |
  | PUT | `/notices/:id` | ✅ | 공지 수정 |
  | DELETE | `/notices/:id` | ✅ | 공지 삭제 (soft delete) |
  | PATCH | `/notices/:id/pin` | ✅ | 고정/해제 토글 |
- **API 엔드포인트 (관리자)**: `/admin/notices/*` — `requireAdmin` 미들웨어 적용
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | GET | `/admin/notices` | Admin | 공지 목록 (appCode query param) |
  | GET | `/admin/notices/:id` | Admin | 공지 상세 (조회수 증가 없음) |
  | POST | `/admin/notices` | Admin | 공지 작성 (appCode body) |
  | PUT | `/admin/notices/:id` | Admin | 공지 수정 |
  | DELETE | `/admin/notices/:id` | Admin | 공지 삭제 (soft delete) |
  | PATCH | `/admin/notices/:id/pin` | Admin | 고정/해제 |
- **DB 테이블**: `notices`, `notice_reads`
- **Quick Start**:
  1. `.env`에 `ADMIN_SECRET` 설정
  2. 사용자: `GET /notices?page=1&limit=10` (선택적 인증)
  3. 관리자: `POST /admin/notices` + `X-Admin-Secret` 헤더
  4. 읽음 추적: 상세 조회 시 자동 처리 (`notice_reads` 테이블)

---

### 박스 관리 (Box)

- **모듈 경로**: `apps/server/src/modules/box/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `handlers.ts` — 박스 생성, 검색, 가입, 조회, 멤버 목록 핸들러
  - `services.ts` — 박스/멤버 DB 조작 로직
  - `schema.ts` — boxes, boxMembers 테이블
  - `validators.ts` — Zod 입력 검증
  - `box.probe.ts` — 운영 로그
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | POST | `/boxes` | ✅ | 박스 생성 (자동 가입, 트랜잭션) |
  | GET | `/boxes/me` | ✅ | 내 박스 조회 |
  | GET | `/boxes/search` | ✅ | 박스 검색 (이름/지역/키워드) |
  | POST | `/boxes/:boxId/join` | ✅ | 박스 가입 (기존 박스 자동 탈퇴) |
  | GET | `/boxes/:boxId` | ✅ | 박스 상세 조회 |
  | GET | `/boxes/:boxId/members` | ✅ | 박스 멤버 목록 |
- **DB 테이블**: `boxes`, `box_members`
- **Quick Start**:
  1. 인증된 사용자로 `POST /boxes` 호출: `{ name: "박스명", region: "서울", description: "설명" }`
  2. `GET /boxes/search?keyword=크로스핏`으로 박스 검색
  3. `POST /boxes/:boxId/join`으로 박스 가입
  4. `GET /boxes/me`로 내 박스 정보 조회

---

### WOD 관리 (WOD)

- **모듈 경로**: `apps/server/src/modules/wod/`
- **상태**: ✅ 완료
- **핵심 파일**:
  - `handlers.ts` — WOD 등록, 조회, 제안 CRUD, 선택 핸들러
  - `services.ts` — WOD/제안/선택 DB 조작 로직
  - `schema.ts` — wods, proposedChanges, wodSelections 테이블
  - `validators.ts` — Zod 입력 검증
  - `normalization.ts` — WOD 데이터 정규화
  - `comparison.ts` — WOD 비교 로직
  - `wod.probe.ts` — 운영 로그
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | POST | `/wods` | ✅ | WOD 등록 |
  | GET | `/wods/:boxId/:date` | ✅ | 날짜별 WOD 조회 |
  | GET | `/wods/proposals` | ✅ | 제안 목록 조회 |
  | POST | `/wods/proposals` | ✅ | WOD 수정 제안 생성 |
  | POST | `/wods/proposals/:proposalId/approve` | ✅ | 제안 승인 |
  | POST | `/wods/proposals/:proposalId/reject` | ✅ | 제안 거절 |
  | POST | `/wods/:wodId/select` | ✅ | WOD 선택 (스냅샷 저장) |
  | GET | `/wods/selections` | ✅ | 내 WOD 선택 목록 |
- **DB 테이블**: `wods`, `proposed_changes`, `wod_selections`
- **Quick Start**:
  1. 박스 가입 후 `POST /wods` 호출: `{ boxId, date, sections: [...] }`
  2. `GET /wods/:boxId/:date`로 해당 날짜 WOD 조회
  3. 수정 필요 시 `POST /wods/proposals`로 제안 생성
  4. 관리자/코치가 `POST /wods/proposals/:id/approve`로 승인
  5. `POST /wods/:wodId/select`로 WOD 선택 (개인 기록)

---

## 공유 미들웨어

### authenticate

- **경로**: `apps/server/src/middleware/auth.ts`
- **용도**: JWT 필수 인증 — `Authorization: Bearer <token>` → `req.user = { userId, appId }`
- **사용법**: `router.post('/route', authenticate, handler)`
- **에러**: `UnauthorizedException` (INVALID_TOKEN, EXPIRED_TOKEN)

### optionalAuthenticate

- **경로**: `apps/server/src/middleware/optional-auth.ts`
- **용도**: JWT 선택적 인증 — 토큰 있으면 검증, 없으면 익명 통과
- **사용 모듈**: QnA, Notice (사용자 GET)

### requireAdmin

- **경로**: `apps/server/src/middleware/admin-auth.ts`
- **용도**: 관리자 JWT 검증 (SHA-256 비밀번호 해시 → 7일 유효 JWT)
- **사용 모듈**: Notice 관리자 CRUD (`/admin/notices/*`)
- **관련**: `adminLogin` — `POST /admin/auth/login`

### errorHandler

- **경로**: `apps/server/src/middleware/error-handler.ts`
- **용도**: 전역 에러 처리 — Zod→400, AppException→커스텀 코드, 기타→500
- **사용법**: `app.use(errorHandler)` (app.ts에서 등록됨)

---

## 공유 유틸리티

### 에러 클래스

- **경로**: `apps/server/src/utils/errors.ts`
- **클래스 계층**:
  ```
  AppException (500)
  ├── BusinessException (400)
  │   └── ValidationException (400)
  ├── UnauthorizedException (401)
  ├── ForbiddenException (403)
  ├── NotFoundException (404)
  └── ExternalApiException (502)
  ```
- **사용법**: `throw new NotFoundException('App', code)`

### JWT 유틸리티

- **경로**: `apps/server/src/utils/jwt.ts`
- **함수**: `signToken(payload, secret, expiresIn)`, `verifyToken(token, secret)`

### Logger

- **경로**: `apps/server/src/utils/logger.ts`
- **구현**: Pino (pretty-print), `LOG_LEVEL` 환경변수

### Username Generator

- **경로**: `apps/server/src/utils/username-generator.ts`
- **용도**: "형용사+명사+숫자" 패턴 한글 닉네임 자동 생성 (신규 OAuth 사용자용)

---

## 앱 설정 (app.ts)

**미들웨어 체인 순서**:
1. `cors()` → `express.json()` → Swagger UI (`/api-docs`)
2. 라우트 마운트: `/auth`, `/push`, `/boxes`, `/wods`, `/qna`, `/notices`
3. 관리자: `POST /admin/auth/login`, `/admin/notices/*` (requireAdmin)
4. `errorHandler` (마지막)

**헬스 체크**: `GET /` → `{ message, version }`, `GET /health` → `{ status, uptime }`

---

## DB 테이블 전체 목록

| 테이블 | 모듈 | 용도 |
|--------|------|------|
| `apps` | auth | 앱별 OAuth/FCM/JWT 설정 |
| `users` | auth | 멀티 OAuth 사용자 |
| `refresh_tokens` | auth | Refresh Token (Rotation + Reuse Detection) |
| `boxes` | box | CrossFit 박스 정보 |
| `box_members` | box | 박스 멤버십 (다대다) |
| `notices` | notice | 공지사항 (soft delete) |
| `notice_reads` | notice | 사용자별 읽음 추적 |
| `push_device_tokens` | push-alert | FCM 디바이스 토큰 |
| `push_alerts` | push-alert | 푸시 발송 이력 |
| `push_notification_receipts` | push-alert | 사용자별 수신/읽음 기록 |
| `qna_config` | qna | 앱별 GitHub App 설정 |
| `qna_questions` | qna | 질문 이력 + GitHub Issue 연동 |
| `wods` | wod | WOD 데이터 (JSONB) |
| `proposed_changes` | wod | WOD 변경 제안 |
| `wod_selections` | wod | 사용자 WOD 선택 스냅샷 |

---

## 새 모듈 추가 체크리스트

1. `src/modules/[feature]/` 디렉토리 생성
2. `schema.ts` — Drizzle 테이블 정의 (FK 없이, 컬럼 코멘트 필수)
3. `validators.ts` — Zod 입력 검증 스키마
4. `handlers.ts` — Express 미들웨어 함수 작성
5. `services.ts` — DB 조작 로직 (복잡한 경우에만)
6. `[feature].probe.ts` — 운영 로그 함수
7. `index.ts` — Router 정의 및 export
8. `app.ts`에 라우터 마운트
9. 마이그레이션: `pnpm drizzle-kit generate && pnpm drizzle-kit migrate`
10. 테스트: `tests/unit/[feature]/` 하위에 핸들러 단위 테스트
