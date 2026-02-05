# Server 작업 분배 계획: QnA

## 개요

QnA 기능의 서버 개발 작업 분배 계획입니다.
TDD(Red-Green-Refactor) 사이클을 따르며, 독립적인 작업 단위로 분할하여 병렬 개발을 지원합니다.

**참조 문서**:
- User Story: [`user-story.md`](./user-story.md)
- Server Brief: [`server-brief.md`](./server-brief.md)
- Server CLAUDE.md: [`apps/server/CLAUDE.md`](../../../apps/server/CLAUDE.md)

---

## 작업 순서 및 의존성

```
[1] 환경 준비 (패키지 설치)
      ↓
[2] DB 스키마 설계 (schema.ts) → [3] 마이그레이션 적용
      ↓                                    ↓
[4] 입력 검증 (validators.ts)              ↓
      ↓                                    ↓
[5] Octokit 유틸 (octokit.ts)              ↓
      ↓                                    ↓
[6] GitHub API 래퍼 (github.ts)            ↓
      ↓                                    ↓
[7] 비즈니스 로직 (services.ts) ←─────────┘
      ↓
[8] 핸들러 (handlers.ts)
      ↓
[9] 라우터 (index.ts)
      ↓
[10] Domain Probe (qna.probe.ts)
      ↓
[11] 통합 및 수동 테스트
```

---

## TDD 테스트 계획

### 테스트 우선순위

**Red-Green-Refactor 사이클**을 각 모듈별로 적용합니다.

#### Phase 1: 입력 검증 테스트 (validators.test.ts)

**목표**: Zod 스키마 검증 로직 TDD

1. **Red**: 제목 누락 시 검증 실패 테스트 작성 (실패)
2. **Green**: `submitQuestionSchema`에 `title` 필수 규칙 추가
3. **Red**: 제목 256자 초과 시 검증 실패 테스트 작성 (실패)
4. **Green**: `title.max(256)` 규칙 추가
5. **Red**: 본문 누락 시 검증 실패 테스트 작성 (실패)
6. **Green**: `body` 필수 규칙 추가
7. **Red**: 본문 65536자 초과 시 검증 실패 테스트 작성 (실패)
8. **Green**: `body.max(65536)` 규칙 추가
9. **Red**: appCode 누락 시 검증 실패 테스트 작성 (실패)
10. **Green**: `appCode` 필수 규칙 추가
11. **Refactor**: 테스트 중복 제거, 공통 픽스처 추출

#### Phase 2: Octokit 인스턴스 생성 테스트 (octokit.test.ts)

**목표**: GitHub App 인증 Octokit 인스턴스 생성 TDD

1. **Red**: 동일 appId로 2번 호출 시 캐시된 인스턴스 반환 테스트 (실패)
2. **Green**: `octokitCache` Map 구현
3. **Red**: 다른 appId로 호출 시 새 인스턴스 생성 테스트 (실패)
4. **Green**: `getOctokitInstance` 분기 로직 추가
5. **Refactor**: createOctokitInstance의 auth 설정 명확화

#### Phase 3: GitHub API 래퍼 테스트 (github.test.ts)

**목표**: Issue 생성 및 에러 처리 TDD

1. **Red**: 정상 Issue 생성 시 issueNumber, issueUrl, createdAt 반환 테스트 (실패)
2. **Green**: `createGitHubIssue` 기본 구현 (octokit.rest.issues.create 호출)
3. **Red**: GitHub 401 에러 시 ExternalApiException 발생 테스트 (실패)
4. **Green**: try-catch 및 status === 401 분기 추가
5. **Red**: GitHub 404 에러 시 NotFoundException 발생 테스트 (실패)
6. **Green**: status === 404 분기 추가
7. **Red**: GitHub 429 에러 시 ExternalApiException 발생 테스트 (실패)
8. **Green**: status === 429 분기 추가
9. **Red**: GitHub 422 에러 시 BusinessException 발생 테스트 (실패)
10. **Green**: status === 422 분기 추가
11. **Refactor**: 에러 매핑 로직 함수 분리, 테스트 헬퍼 함수 추출

#### Phase 4: 서비스 레이어 테스트 (services.test.ts)

**목표**: 비즈니스 로직 (DB 조회 + GitHub Issue 생성) TDD

1. **Red**: 앱이 존재하지 않을 때 NotFoundException 발생 테스트 (실패)
2. **Green**: `createQuestion`에서 앱 조회 후 없으면 throw
3. **Red**: QnA 설정이 존재하지 않을 때 NotFoundException 발생 테스트 (실패)
4. **Green**: qna_config 조회 후 없으면 throw
5. **Red**: 정상 플로우에서 GitHub Issue 생성 및 DB 저장 테스트 (실패)
6. **Green**: `createGitHubIssue` 호출 및 `qna_questions` 삽입 구현
7. **Red**: 익명 사용자(userId null)일 때 Issue 본문에 "익명 사용자" 포함 테스트 (실패)
8. **Green**: `buildIssueBody`에서 userId null 처리
9. **Red**: 제목에 제어 문자가 포함될 때 sanitize 되는지 테스트 (실패)
10. **Green**: `buildIssueBody`에서 제어 문자 제거 로직 추가
11. **Refactor**: buildIssueBody 함수 분리, Mock DB 헬퍼 함수 추출

#### Phase 5: 핸들러 테스트 (handlers.test.ts)

**목표**: Express 핸들러 (submitQuestion) TDD

1. **Red**: 인증된 사용자의 질문 제출 시 201 응답 테스트 (실패)
2. **Green**: `submitQuestion` 핸들러 기본 구현 (createQuestion 호출)
3. **Red**: 비인증 사용자의 질문 제출 시 userId null로 처리 테스트 (실패)
4. **Green**: req.user 체크 로직 추가
5. **Red**: 제목 누락 시 Zod 에러 발생 테스트 (실패)
6. **Green**: submitQuestionSchema.parse(req.body) 추가
7. **Red**: 질문 제출 성공 시 Domain Probe 로그 호출 테스트 (실패)
8. **Green**: `qnaProbe.questionSubmitted` 호출 추가
9. **Refactor**: Mock Request/Response 헬퍼 함수 추출

#### Phase 6: 통합 테스트

- 실제 GitHub API 호출 없이 전체 플로우 테스트 (모든 의존성 Mock)
- 에러 시나리오 엔드투엔드 검증

---

## 작업 분배

### Task 1: 환경 준비 및 패키지 설치

**담당**: 누구나 (독립 작업)
**소요 시간**: 10분

#### 작업 내용

1. npm 패키지 설치:
   ```bash
   cd /Users/lms/dev/repository/feature-qna/apps/server
   pnpm add octokit @octokit/rest @octokit/auth-app @octokit/plugin-throttling @octokit/plugin-retry p-queue
   ```

2. 설치 확인:
   ```bash
   pnpm list octokit
   ```

#### 완료 조건

- [ ] package.json의 dependencies에 모든 패키지 추가됨
- [ ] pnpm-lock.yaml 업데이트됨

---

### Task 2: DB 스키마 설계 (schema.ts)

**담당**: Junior Developer (DB 설계 경험자 선호)
**소요 시간**: 1시간
**의존성**: Task 1 완료

#### 작업 내용

1. `apps/server/src/modules/qna/schema.ts` 생성
2. Drizzle 테이블 정의:
   - `qnaConfig` 테이블 (앱별 GitHub 연동 설정)
   - `qnaQuestions` 테이블 (질문 이력, 선택적)
3. JSDoc 주석 작성 (한국어)
4. 컬럼 comment 필수 추가 (Drizzle `.comment()`)

#### TDD 사이클

**이 작업은 스키마 정의이므로 TDD 적용 안 함** (마이그레이션 적용 후 DB에서 검증)

#### 체크리스트

- [ ] `qnaConfig` 테이블 정의:
  - [ ] `appId` (integer, unique, not null)
  - [ ] `githubRepoOwner`, `githubRepoName` (varchar)
  - [ ] `githubAppId`, `githubPrivateKey`, `githubInstallationId` (varchar)
  - [ ] `githubLabels` (varchar, JSON 배열, default: `["qna"]`)
  - [ ] `createdAt`, `updatedAt` (timestamp)
  - [ ] `appIdIdx` 인덱스 추가
- [ ] `qnaQuestions` 테이블 정의:
  - [ ] `appId`, `userId` (integer, userId는 nullable)
  - [ ] `title`, `body` (varchar)
  - [ ] `issueNumber` (integer)
  - [ ] `issueUrl` (varchar)
  - [ ] `createdAt` (timestamp)
  - [ ] 인덱스: appId, userId, issueNumber, createdAt
- [ ] 모든 테이블/컬럼에 JSDoc 주석 작성
- [ ] FK 사용 안 함 (gaegulzip 컨벤션)

#### 참조

- Server Brief의 2. DB 스키마 설계 섹션
- 기존 모듈 스키마: `apps/server/src/modules/auth/schema.ts`

---

### Task 3: 마이그레이션 생성 및 적용

**담당**: Junior Developer (Task 2 담당자)
**소요 시간**: 30분
**의존성**: Task 2 완료

#### 작업 내용

1. Drizzle 마이그레이션 파일 생성:
   ```bash
   pnpm drizzle-kit generate
   ```

2. 생성된 SQL 파일 검토 (`apps/server/drizzle/` 디렉토리)

3. 마이그레이션 적용:
   ```bash
   pnpm drizzle-kit migrate
   ```

4. Supabase Studio에서 테이블 생성 확인

#### 완료 조건

- [ ] `drizzle/` 디렉토리에 새 마이그레이션 파일 생성됨
- [ ] Supabase DB에 `qna_config`, `qna_questions` 테이블 생성됨
- [ ] 테이블 컬럼 타입 및 제약조건 올바름

---

### Task 4: 입력 검증 스키마 (validators.ts)

**담당**: Junior Developer
**소요 시간**: 1시간
**의존성**: 없음 (독립 작업)

#### 작업 내용

1. `apps/server/src/modules/qna/validators.ts` 생성
2. Zod 스키마 작성:
   - `submitQuestionSchema`: appCode, title, body 검증
3. TypeScript 타입 export
4. JSDoc 주석 작성

#### TDD 사이클 (Phase 1)

**테스트 파일**: `apps/server/tests/unit/qna/validators.test.ts`

1. **Red**: 제목 누락 시 검증 실패 테스트 작성
   ```typescript
   it('should fail when title is missing', () => {
     expect(() => submitQuestionSchema.parse({
       appCode: 'wowa',
       body: '내용',
     })).toThrow();
   });
   ```
2. **Green**: `title: z.string().min(1)` 추가
3. **Red**: 제목 256자 초과 시 검증 실패 테스트
4. **Green**: `title.max(256)` 추가
5. **Red**: 본문 누락, 65536자 초과 테스트
6. **Green**: `body` 규칙 추가
7. **Red**: appCode 누락 테스트
8. **Green**: `appCode` 규칙 추가
9. **Refactor**: 테스트 픽스처 공통화

#### 체크리스트

- [ ] `submitQuestionSchema` 정의:
  - [ ] `appCode`: string, 1-50자, 필수
  - [ ] `title`: string, 1-256자, 필수
  - [ ] `body`: string, 1-65536자, 필수
- [ ] TypeScript 타입 export (`SubmitQuestionRequest`)
- [ ] JSDoc 주석 작성
- [ ] TDD 테스트 통과 (모든 검증 규칙)

#### 참조

- Server Brief의 validators.ts 예시
- Zod 공식 문서: https://zod.dev

---

### Task 5: Octokit 인스턴스 생성 유틸 (octokit.ts)

**담당**: Senior Developer (GitHub App 인증 이해 필요)
**소요 시간**: 1.5시간
**의존성**: Task 1 완료

#### 작업 내용

1. `apps/server/src/modules/qna/octokit.ts` 생성
2. Octokit 인스턴스 생성 함수 구현:
   - `createOctokitInstance`: GitHub App 인증 Octokit 생성
   - `getOctokitInstance`: appId 기준 캐싱
3. throttling, retry 플러그인 설정
4. JSDoc 주석 작성

#### TDD 사이클 (Phase 2)

**테스트 파일**: `apps/server/tests/unit/qna/octokit.test.ts`

1. **Red**: 동일 appId로 2번 호출 시 캐시된 인스턴스 반환 테스트
2. **Green**: `octokitCache` Map 구현
3. **Red**: 다른 appId로 호출 시 새 인스턴스 생성 테스트
4. **Green**: `getOctokitInstance` 분기 로직
5. **Refactor**: createOctokitInstance 옵션 명확화

#### 체크리스트

- [ ] `createOctokitInstance` 함수:
  - [ ] `@octokit/auth-app` 사용
  - [ ] throttling 플러그인 설정 (onRateLimit, onSecondaryRateLimit)
  - [ ] retry 플러그인 설정 (doNotRetry: ['429'])
- [ ] `getOctokitInstance` 함수:
  - [ ] octokitCache Map으로 캐싱
  - [ ] appId 기준으로 인스턴스 재사용
- [ ] JSDoc 주석 작성
- [ ] TDD 테스트 통과

#### 참조

- Server Brief의 3.2 GitHub App 인증 흐름 섹션
- Octokit 공식 문서: https://github.com/octokit/octokit.js

---

### Task 6: GitHub Issue 생성 래퍼 (github.ts)

**담당**: Senior Developer (Task 5 담당자)
**소요 시간**: 2시간
**의존성**: Task 5 완료

#### 작업 내용

1. `apps/server/src/modules/qna/github.ts` 생성
2. `createGitHubIssue` 함수 구현:
   - octokit.rest.issues.create() 호출
   - GitHub API 에러 → gaegulzip Exception 변환
3. 에러 매핑: 401/403/404/422/429 → 각각 적절한 Exception
4. JSDoc 주석 작성

#### TDD 사이클 (Phase 3)

**테스트 파일**: `apps/server/tests/unit/qna/github.test.ts`

1. **Red**: 정상 Issue 생성 시 issueNumber, issueUrl, createdAt 반환 테스트
2. **Green**: `createGitHubIssue` 기본 구현
3. **Red**: GitHub 401 에러 시 ExternalApiException 테스트
4. **Green**: status === 401 분기 추가
5. **Red**: GitHub 404 에러 시 NotFoundException 테스트
6. **Green**: status === 404 분기 추가
7. **Red**: 429, 422 에러 테스트
8. **Green**: 각 에러 분기 추가
9. **Refactor**: 에러 매핑 로직 함수 분리

#### 체크리스트

- [ ] `createGitHubIssue` 함수:
  - [ ] octokit.rest.issues.create() 호출
  - [ ] 반환: `{ issueNumber, issueUrl, createdAt }`
- [ ] 에러 처리:
  - [ ] 401/403 → ExternalApiException('GitHub', error)
  - [ ] 404 → NotFoundException('GitHub Repository', ...)
  - [ ] 422 → BusinessException('GitHub validation error', ...)
  - [ ] 429 → ExternalApiException (rate limit exceeded)
  - [ ] 기타 → ExternalApiException
- [ ] logger.error로 에러 상세 로깅
- [ ] JSDoc 주석 작성
- [ ] TDD 테스트 통과 (모든 에러 케이스)

#### 참조

- Server Brief의 3.4 에러 처리 전략 섹션
- 예외 처리 가이드: `.claude/guide/server/exception-handling.md`

---

### Task 7: 비즈니스 로직 (services.ts)

**담당**: Senior Developer (Task 6 담당자)
**소요 시간**: 3시간
**의존성**: Task 2, 3, 5, 6 완료

#### 작업 내용

1. `apps/server/src/modules/qna/services.ts` 생성
2. `createQuestion` 함수 구현:
   - 앱 조회 (apps 테이블)
   - QnA 설정 조회 (qna_config)
   - Octokit 인스턴스 가져오기
   - Issue 본문 생성 (buildIssueBody)
   - GitHub Issue 생성 (createGitHubIssue)
   - DB 저장 (qna_questions)
3. `buildIssueBody` 헬퍼 함수 구현 (제어 문자 제거, 메타데이터 포함)
4. JSDoc 주석 작성

#### TDD 사이클 (Phase 4)

**테스트 파일**: `apps/server/tests/unit/qna/services.test.ts`

1. **Red**: 앱 없을 때 NotFoundException 테스트
2. **Green**: 앱 조회 후 없으면 throw
3. **Red**: QnA 설정 없을 때 NotFoundException 테스트
4. **Green**: qna_config 조회 후 없으면 throw
5. **Red**: 정상 플로우 테스트 (GitHub Issue 생성 + DB 저장)
6. **Green**: 전체 플로우 구현
7. **Red**: 익명 사용자 본문에 "익명 사용자" 포함 테스트
8. **Green**: buildIssueBody userId null 처리
9. **Red**: 제어 문자 제거 테스트
10. **Green**: buildIssueBody에 sanitize 로직 추가
11. **Refactor**: buildIssueBody 함수 분리, 테스트 헬퍼 추출

#### 체크리스트

- [ ] `createQuestion` 함수:
  - [ ] 앱 조회 (eq(apps.code, params.appCode))
  - [ ] 앱 없으면 NotFoundException('App', appCode)
  - [ ] QnA 설정 조회 (eq(qnaConfig.appId, app.id))
  - [ ] 설정 없으면 NotFoundException('QnA Config', appCode)
  - [ ] getOctokitInstance 호출
  - [ ] buildIssueBody로 본문 생성
  - [ ] createGitHubIssue 호출
  - [ ] qna_questions에 삽입
  - [ ] 반환: `{ questionId, issueNumber, issueUrl, createdAt }`
- [ ] `buildIssueBody` 함수:
  - [ ] 제어 문자 제거 (탭, 개행은 유지)
  - [ ] userId null이면 "익명 사용자" 표시
  - [ ] 메타데이터 섹션 포함 (사용자 ID, 앱 코드, 작성 시각)
- [ ] JSDoc 주석 작성
- [ ] TDD 테스트 통과 (모든 시나리오)

#### 참조

- Server Brief의 3.1 전체 흐름, 3.3 GitHub Issue 본문 포맷 섹션

---

### Task 8: Express 핸들러 (handlers.ts)

**담당**: Junior Developer
**소요 시간**: 1.5시간
**의존성**: Task 4, 7 완료

#### 작업 내용

1. `apps/server/src/modules/qna/handlers.ts` 생성
2. `submitQuestion` 핸들러 구현:
   - Zod 스키마 검증 (submitQuestionSchema.parse)
   - req.user에서 userId 추출 (optionalAuthenticate 미들웨어)
   - createQuestion 호출
   - Domain Probe 로그 호출
   - 201 응답 반환
3. JSDoc 주석 작성

#### TDD 사이클 (Phase 5)

**테스트 파일**: `apps/server/tests/unit/qna/handlers.test.ts`

1. **Red**: 인증 사용자 질문 제출 시 201 응답 테스트
2. **Green**: submitQuestion 기본 구현
3. **Red**: 비인증 사용자 질문 제출 시 userId null 테스트
4. **Green**: req.user 체크 로직 추가
5. **Red**: Zod 에러 발생 테스트
6. **Green**: submitQuestionSchema.parse 추가
7. **Red**: Domain Probe 호출 테스트
8. **Green**: qnaProbe.questionSubmitted 호출 추가
9. **Refactor**: Mock Request/Response 헬퍼 추출

#### 체크리스트

- [ ] `submitQuestion` 핸들러:
  - [ ] submitQuestionSchema.parse(req.body)
  - [ ] req.user에서 userId 추출 (없으면 null)
  - [ ] createQuestion 호출
  - [ ] qnaProbe.questionSubmitted 호출
  - [ ] res.status(201).json(result)
- [ ] logger.debug로 디버그 로그 추가
- [ ] JSDoc 주석 작성
- [ ] TDD 테스트 통과

#### 참조

- Server Brief의 handlers.ts 예시
- Express 미들웨어 패턴: `apps/server/src/modules/auth/handlers.ts`

---

### Task 9: 라우터 설정 (index.ts)

**담당**: Junior Developer (Task 8 담당자)
**소요 시간**: 30분
**의존성**: Task 8 완료

#### 작업 내용

1. `apps/server/src/modules/qna/index.ts` 생성
2. Express Router 정의:
   - POST /questions → submitQuestion
   - optionalAuthenticate 미들웨어 적용
3. Router export

#### TDD 사이클

**이 작업은 라우터 설정이므로 TDD 적용 안 함** (통합 테스트에서 검증)

#### 체크리스트

- [ ] Router 생성
- [ ] POST /questions 등록 (optionalAuthenticate, submitQuestion)
- [ ] default export
- [ ] JSDoc 주석 작성

#### 참조

- Server Brief의 index.ts 예시

---

### Task 10: Domain Probe 로그 (qna.probe.ts)

**담당**: Junior Developer
**소요 시간**: 1시간
**의존성**: 없음 (독립 작업)

#### 작업 내용

1. `apps/server/src/modules/qna/qna.probe.ts` 생성
2. Domain Probe 함수 구현:
   - `questionSubmitted` (INFO)
   - `rateLimitWarning` (WARN)
   - `githubApiError` (ERROR)
   - `configNotFound` (WARN)
3. JSDoc 주석 작성

#### TDD 사이클

**Domain Probe는 로그 함수이므로 TDD 적용 안 함** (logger 호출 검증만)

#### 체크리스트

- [ ] `questionSubmitted` 함수:
  - [ ] logger.info 호출
  - [ ] 파라미터: questionId, appCode, userId, issueNumber
- [ ] `rateLimitWarning` 함수:
  - [ ] logger.warn 호출
  - [ ] 파라미터: appCode, remaining, resetAt
- [ ] `githubApiError` 함수:
  - [ ] logger.error 호출
  - [ ] 파라미터: appCode, error, statusCode
- [ ] `configNotFound` 함수:
  - [ ] logger.warn 호출
  - [ ] 파라미터: appCode
- [ ] JSDoc 주석 작성

#### 참조

- 로깅 베스트 프랙티스: `.claude/guide/server/logging-best-practices.md`
- Server Brief의 qna.probe.ts 예시

---

### Task 11: 통합 및 수동 테스트

**담당**: Senior Developer + Junior Developer (협업)
**소요 시간**: 2시간
**의존성**: Task 2~10 모두 완료

#### 작업 내용

1. 전체 TDD 테스트 실행:
   ```bash
   pnpm test
   ```

2. 빌드 검증:
   ```bash
   pnpm build
   ```

3. Supabase에 qna_config 데이터 삽입 (수동):
   ```sql
   INSERT INTO qna_config (app_id, github_repo_owner, github_repo_name, github_app_id, github_private_key, github_installation_id, github_labels)
   VALUES (
     1,  -- wowa 앱 ID
     'gaegulzip-org',
     'wowa-issues',
     '123456',
     '-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----',
     '789012',
     '["qna", "user-question"]'
   );
   ```

4. Postman/Insomnia로 API 수동 테스트:
   - POST /api/qna/questions (인증 O)
   - POST /api/qna/questions (인증 X, 익명)
   - 에러 시나리오 (제목 누락, 256자 초과 등)

5. GitHub Issues에서 실제 Issue 생성 확인

6. 로그 출력 확인:
   - INFO: questionSubmitted
   - WARN: rateLimitWarning (필요 시)
   - ERROR: githubApiError (에러 시)

#### 완료 조건

- [ ] 모든 단위 테스트 통과
- [ ] pnpm build 성공
- [ ] Postman 테스트 성공 (정상 + 에러 시나리오)
- [ ] GitHub Issues에 Issue 생성 확인
- [ ] 로그 출력 확인 (INFO, WARN, ERROR)
- [ ] qna_questions 테이블에 데이터 저장 확인

---

## 작업 병렬화 전략

### 병렬 가능한 작업

- **Group A**: Task 1 → Task 2, 3 (DB 스키마)
- **Group B**: Task 1 → Task 4 (입력 검증)
- **Group C**: Task 1 → Task 5 (Octokit)
- **Group D**: Task 10 (Domain Probe)

### 순차 작업

- Task 5 → Task 6 (Octokit 완료 후 GitHub 래퍼)
- Task 2, 3, 6 → Task 7 (DB + GitHub 완료 후 서비스 로직)
- Task 4, 7 → Task 8 (검증 + 서비스 완료 후 핸들러)
- Task 8 → Task 9 (핸들러 완료 후 라우터)

### 개발자별 작업 할당 예시

**Senior Developer**:
- Task 5: Octokit 인스턴스 생성
- Task 6: GitHub API 래퍼
- Task 7: 비즈니스 로직
- Task 11: 통합 테스트 (협업)

**Junior Developer**:
- Task 1: 패키지 설치
- Task 2, 3: DB 스키마 및 마이그레이션
- Task 4: 입력 검증
- Task 8: 핸들러
- Task 9: 라우터
- Task 10: Domain Probe
- Task 11: 통합 테스트 (협업)

### 예상 총 소요 시간

- **Senior**: 6.5시간
- **Junior**: 6.5시간
- **병렬 작업 시 전체**: ~7시간 (일부 대기 시간 포함)

---

## 체크리스트 (전체)

### 구현 전 확인

- [ ] GitHub App 생성 및 Private Key 발급
- [ ] GitHub App을 조직에 설치 (Installation ID 확인)
- [ ] npm 패키지 설치 (octokit 등)

### 구현 중 확인

- [ ] Drizzle 스키마 정의 (qna_config, qna_questions)
- [ ] 마이그레이션 적용
- [ ] Zod 입력 검증 스키마 작성
- [ ] Octokit 인스턴스 생성 및 캐싱
- [ ] GitHub Issue 생성 로직 (메타데이터 포함)
- [ ] 에러 처리 (GitHub API 에러 매핑)
- [ ] Domain Probe 패턴으로 운영 로그 분리
- [ ] optionalAuthenticate 미들웨어 확인

### 구현 후 확인

- [ ] TDD 단위 테스트 작성 및 통과
- [ ] pnpm build 성공
- [ ] Supabase에 qna_config 데이터 삽입
- [ ] Postman 수동 테스트 (정상 + 에러)
- [ ] GitHub Issue에 메타데이터 정확히 포함 확인
- [ ] 익명 사용자 질문 제출 테스트
- [ ] 로그 출력 확인 (INFO, WARN, ERROR)

---

## 참고 자료

- Server Brief: [`server-brief.md`](./server-brief.md)
- User Story: [`user-story.md`](./user-story.md)
- Server CLAUDE.md: [`apps/server/CLAUDE.md`](../../../apps/server/CLAUDE.md)
- 예외 처리 가이드: `.claude/guide/server/exception-handling.md`
- 로깅 베스트 프랙티스: `.claude/guide/server/logging-best-practices.md`
- API Response 설계 가이드: `.claude/guide/server/api-response-design.md`

---

## 다음 단계

작업 완료 후 **CTO의 통합 리뷰** 진행:

1. 코드 읽기 (Glob/Read로 모든 파일 확인)
2. 테스트 실행 (`pnpm test`)
3. 빌드 검증 (`pnpm build`)
4. 마이그레이션 확인 (Supabase MCP로 SELECT 쿼리)
5. 코드 품질 검증 (Express 패턴, Drizzle 스키마, JSDoc, TDD 준수)
6. 리뷰 문서 작성 (`server-cto-review.md`)
