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
  - `handlers.ts` — 디바이스 등록, 알림 발송, 이력 조회 핸들러
  - `services.ts` — 디바이스/알림 DB 조작
  - `schema.ts` — pushDeviceTokens, pushAlerts 테이블
  - `fcm.ts` — Firebase Admin SDK 래퍼 (인스턴스 캐싱, 배치 발송)
  - `validators.ts` — Zod 입력 검증 스키마
  - `push.probe.ts` — 운영 로그 (발송 성공/실패, 무효 토큰 탐지)
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | POST | `/push/devices` | ✅ | 디바이스 토큰 등록 |
  | GET | `/push/devices` | ✅ | 내 디바이스 목록 |
  | DELETE | `/push/devices/:id` | ✅ | 디바이스 비활성화 |
  | POST | `/push/send` | ❌ | 푸시 알림 발송 (관리자) |
  | GET | `/push/notifications` | ❌ | 알림 이력 목록 |
  | GET | `/push/notifications/:id` | ❌ | 알림 상세 조회 |
- **DB 테이블**: `push_device_tokens`, `push_alerts`
- **Quick Start**:
  1. `apps` 테이블에 FCM 인증 정보 설정 (`fcmProjectId`, `fcmPrivateKey`, `fcmClientEmail`)
  2. 모바일에서 FCM 토큰 획득 후 `POST /push/devices` 호출
  3. `POST /push/send`로 알림 발송: `{ appCode: "wowa", userId: 1, title: "...", body: "..." }`
  4. 무효 토큰은 발송 시 자동 비활성화됨
- **상세 분석**: [`docs/core/fcm-push-notification.md`](../core/fcm-push-notification.md)

---

### QnA 질문과 답변 (QnA)

- **모듈 경로**: `apps/server/src/modules/qna/`
- **상태**: ✅ 완료 (28 테스트 통과)
- **핵심 파일**:
  - `handlers.ts` — 질문 제출 핸들러 (submitQuestion)
  - `services.ts` — 질문 생성 로직 (createQuestion, buildIssueBody)
  - `github.ts` — GitHub Issue 생성 (createGitHubIssue), 에러 매핑
  - `octokit.ts` — GitHub App Octokit 인스턴스 팩토리 (캐싱, throttling, retry)
  - `schema.ts` — qna_config, qna_questions Drizzle 테이블
  - `validators.ts` — Zod 입력 검증 (appCode, title 1-256, body 1-65536)
  - `qna.probe.ts` — 운영 로그 (questionSubmitted, rateLimitWarning, githubApiError, configNotFound)
  - `index.ts` — Router 정의 및 export
- **API 엔드포인트**:
  | 메서드 | 경로 | 인증 | 설명 |
  |--------|------|------|------|
  | POST | `/qna/questions` | ⚪ 선택적 | 질문 제출 (GitHub Issue 자동 생성) |
- **DB 테이블**: `qna_config` (앱별 GitHub 설정), `qna_questions` (질문 이력)
- **Quick Start**:
  1. `apps` 테이블에 앱 레코드 확인 (code: "wowa")
  2. `qna_config` 테이블에 GitHub App 설정 추가:
     - `appId`, `githubRepoOwner`, `githubRepoName`, `githubAppId`, `githubInstallationId`, `githubPrivateKey`
  3. `POST /qna/questions` 호출: `{ appCode: "wowa", title: "질문 제목", body: "질문 내용" }`
  4. 응답: `{ questionId, issueNumber, issueUrl, createdAt }` (201 Created)
  5. 인증된 사용자: `Authorization: Bearer <token>` 헤더 추가 시 질문에 userId 기록
- **새 앱에 적용**: `qna_config` 테이블에 새 앱의 GitHub App 설정 행 추가만 하면 됨
- **상세 설계**: [`docs/core/qna/server-brief.md`](../core/qna/server-brief.md)

---

## 공유 미들웨어

### authenticate

- **경로**: `apps/server/src/middleware/auth.ts`
- **별칭**: `authenticate` (필수 인증)
- **용도**: JWT 검증 및 사용자 컨텍스트 주입
- **사용법**: `router.post('/route', authenticate, handler)`
- **동작**: `Authorization: Bearer <token>` 헤더에서 JWT 추출 → 앱별 시크릿으로 검증 → `req.user = { userId, appId }` 설정
- **에러**: `UnauthorizedException` (INVALID_TOKEN, EXPIRED_TOKEN)

### optionalAuthenticate

- **경로**: `apps/server/src/middleware/optional-auth.ts`
- **용도**: JWT가 있으면 검증하고, 없어도 통과시키는 선택적 인증
- **사용법**: `router.post('/route', optionalAuthenticate, handler)`
- **동작**: Authorization 헤더 있으면 JWT 검증 → `req.user` 설정, 없거나 실패 시 `req.user = undefined`로 통과
- **사용 모듈**: QnA (익명 + 로그인 사용자 모두 질문 가능)

### errorHandler

- **경로**: `apps/server/src/middleware/error-handler.ts`
- **용도**: 전역 에러 처리 (미들웨어 체인 마지막에 등록)
- **사용법**: `app.use(errorHandler)` (app.ts에서 이미 등록됨)
- **동작**: Zod 에러 → 400, AppException → 커스텀 상태코드, 기타 → 500

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
  ├── NotFoundException (404)
  └── ExternalApiException (502)
  ```
- **ErrorCode 상수**: `VALIDATION_ERROR`, `INVALID_TOKEN`, `EXPIRED_TOKEN`, `REFRESH_TOKEN_REUSE_DETECTED`, `FCM_NOT_CONFIGURED` 등
- **사용법**: `throw new NotFoundException('App', code)`

### JWT 유틸리티

- **경로**: `apps/server/src/utils/jwt.ts`
- **함수**:
  - `signToken(payload, secret, expiresIn)` — JWT 생성
  - `verifyToken(token, secret)` — JWT 검증 및 디코딩

### Logger

- **경로**: `apps/server/src/utils/logger.ts`
- **구현**: Pino (pretty-print)
- **사용법**: `logger.info({ key: value }, 'message')`

---

## 앱 설정 (app.ts)

**미들웨어 체인 순서**:
1. `express.json()` — JSON 파싱
2. Swagger UI — `/api-docs` (OpenAPI 문서)
3. 라우트 마운트: `/auth/*`, `/push/*`, `/qna/*`
4. `errorHandler` — 전역 에러 핸들러 (마지막)

**헬스 체크**:
- `GET /` → `{ message, version }`
- `GET /health` → `{ status, uptime }`

---

## 환경 변수

| 변수 | 필수 | 설명 | 기본값 |
|------|------|------|--------|
| `DATABASE_URL` | ✅ | PostgreSQL 연결 문자열 | - |
| `JWT_SECRET_FALLBACK` | ✅ | JWT 폴백 시크릿 (32자 이상) | - |
| `PORT` | ❌ | 서버 포트 | `3001` |
| `NODE_ENV` | ❌ | 환경 | `development` |
| `LOG_LEVEL` | ❌ | 로그 레벨 | `info` |

---

## 새 모듈 추가 체크리스트

1. `src/modules/[feature]/` 디렉토리 생성
2. `schema.ts` — Drizzle 테이블 정의 (FK 제약 없이, 컬럼 코멘트 필수)
3. `validators.ts` — Zod 입력 검증 스키마
4. `handlers.ts` — Express 미들웨어 함수 작성
5. `services.ts` — DB 조작 로직 (복잡한 경우에만)
6. `[feature].probe.ts` — 운영 로그 함수
7. `index.ts` — Router 정의 및 export
8. `app.ts`에 라우터 마운트
9. 마이그레이션: `pnpm drizzle-kit generate && pnpm drizzle-kit migrate`
10. 테스트: `tests/unit/[feature]/` 하위에 핸들러 단위 테스트
