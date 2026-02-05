# 서버 기술 설계: QnA (질문과 답변)

## 개요

사용자 질문을 GitHub Issues로 자동 등록하는 API 설계. GitHub App 인증을 통해 앱 코드별로 서로 다른 GitHub 레포지토리에 질문을 등록합니다.

**핵심 기술 스택**:
- GitHub App Installation Token (1시간 자동 갱신)
- Octokit SDK (공식 Node.js SDK)
- Drizzle ORM (PostgreSQL, Supabase)
- Express 미들웨어 패턴

---

## 1. API 엔드포인트 설계

### POST /qna/questions

**설명**: 사용자 질문을 제출하고 GitHub Issue로 자동 등록

#### Request

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <accessToken>  // 선택적 (비로그인 사용자는 생략 가능)
```

**Body**:
```typescript
{
  "appCode": "wowa",              // 앱 식별 코드 (필수)
  "title": "운동 강도 조절",       // 질문 제목 (필수, 1-256자)
  "body": "운동 강도를..."         // 질문 내용 (필수, 1-65536자)
}
```

#### Response

**성공 (201 Created)**:
```typescript
{
  "questionId": 1,                                    // 로컬 DB에 저장된 질문 ID
  "issueNumber": 1347,                                // GitHub Issue 번호
  "issueUrl": "https://github.com/org/repo/issues/1347",  // GitHub Issue URL
  "createdAt": "2026-02-04T10:00:00Z"                 // 생성 시각 (ISO-8601, UTC)
}
```

**에러 응답**:

| HTTP 코드 | code | message | 상황 |
|-----------|------|---------|------|
| 400 | VALIDATION_ERROR | Title is required | 제목 누락 |
| 400 | VALIDATION_ERROR | Title must be 1-256 characters | 제목 길이 초과 |
| 400 | VALIDATION_ERROR | Body must be 1-65536 characters | 본문 길이 초과 |
| 404 | APP_NOT_FOUND | App not found: wowa | 앱 코드 미등록 |
| 404 | QNA_CONFIG_NOT_FOUND | QnA config not found for app: wowa | 앱에 GitHub 연동 설정 없음 |
| 502 | GITHUB_API_ERROR | GitHub API error: rate limit exceeded | GitHub API Rate Limit 초과 |
| 502 | GITHUB_API_ERROR | GitHub API error: repository not found | 레포지토리 접근 권한 없음 |
| 500 | INTERNAL_ERROR | Internal server error | 예상치 못한 오류 |

---

## 2. DB 스키마 설계

### 테이블: qna_config

**설명**: 앱별 GitHub 레포지토리 연동 설정

```typescript
// src/modules/qna/schema.ts
import { pgTable, serial, integer, varchar, timestamp, index } from 'drizzle-orm/pg-core';

/**
 * QnA GitHub 연동 설정 테이블
 */
export const qnaConfig = pgTable('qna_config', {
  /** 고유 ID */
  id: serial('id').primaryKey(),

  /** 앱 ID (외래키, FK 제약조건 없음) */
  appId: integer('app_id').notNull().unique(),

  /** GitHub 레포지토리 소유자 (조직/사용자명) */
  githubRepoOwner: varchar('github_repo_owner', { length: 255 }).notNull(),

  /** GitHub 레포지토리 이름 */
  githubRepoName: varchar('github_repo_name', { length: 255 }).notNull(),

  /** GitHub App ID */
  githubAppId: varchar('github_app_id', { length: 50 }).notNull(),

  /** GitHub App Private Key (PEM 형식, 암호화 권장) */
  githubPrivateKey: varchar('github_private_key', { length: 5000 }).notNull(),

  /** GitHub App Installation ID */
  githubInstallationId: varchar('github_installation_id', { length: 50 }).notNull(),

  /** 자동 적용할 GitHub Issue 라벨 목록 (JSON 배열, 예: ["qna", "user-question"]) */
  githubLabels: varchar('github_labels', { length: 500 }).notNull().default('["qna"]'),

  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),

  /** 수정 시간 */
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  appIdIdx: index('idx_qna_config_app_id').on(table.appId),
}));
```

**데이터 예시**:
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

### 테이블: qna_questions

**설명**: 제출된 질문 이력 저장 (선택적)

```typescript
/**
 * QnA 질문 이력 테이블 (선택적)
 */
export const qnaQuestions = pgTable('qna_questions', {
  /** 고유 ID */
  id: serial('id').primaryKey(),

  /** 앱 ID (외래키, FK 제약조건 없음) */
  appId: integer('app_id').notNull(),

  /** 사용자 ID (null = 익명 사용자) */
  userId: integer('user_id'),

  /** 질문 제목 */
  title: varchar('title', { length: 256 }).notNull(),

  /** 질문 내용 */
  body: varchar('body', { length: 65536 }).notNull(),

  /** GitHub Issue 번호 */
  issueNumber: integer('issue_number').notNull(),

  /** GitHub Issue URL */
  issueUrl: varchar('issue_url', { length: 500 }).notNull(),

  /** 생성 시간 */
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  appIdIdx: index('idx_qna_questions_app_id').on(table.appId),
  userIdIdx: index('idx_qna_questions_user_id').on(table.userId),
  issueNumberIdx: index('idx_qna_questions_issue_number').on(table.issueNumber),
  createdAtIdx: index('idx_qna_questions_created_at').on(table.createdAt),
}));
```

**설계 근거**:
- `appId` 컬럼으로 apps 테이블과 논리적 연결 (FK 제약조건 없음)
- `userId`는 nullable (익명 사용자 지원)
- `issueNumber`, `issueUrl`로 GitHub Issue 추적 가능
- Phase 1에서는 질문 이력 저장 선택적 (향후 질문 목록 조회 기능 대비)

---

## 3. 비즈니스 로직 설계

### 3.1 전체 흐름

```
1. 요청 검증 (Zod validator)
   ├─ appCode, title, body 필수 확인
   └─ 길이 제한 검증

2. 인증 확인 (선택적)
   ├─ Authorization 헤더 있으면 → userId 추출
   └─ 없으면 → 익명 사용자 (userId = null)

3. 앱 설정 조회
   ├─ appCode로 apps 테이블에서 앱 조회
   ├─ appId로 qna_config 테이블에서 GitHub 설정 조회
   └─ 설정 없으면 → 404 NOT_FOUND

4. Octokit 인스턴스 생성
   ├─ GitHub App 인증 (Installation Token 자동 발급)
   └─ 토큰 캐싱 (동일 appId는 인스턴스 재사용)

5. GitHub Issue 생성
   ├─ 제목: 사용자 입력 그대로
   ├─ 본문: 질문 내용 + 메타데이터 (Markdown)
   ├─ 라벨: qna_config.githubLabels
   └─ API 호출: octokit.rest.issues.create()

6. 응답 반환
   ├─ 성공: issueNumber, issueUrl, createdAt 반환
   └─ 실패: GitHub API 에러 → ExternalApiException
```

### 3.2 GitHub App 인증 흐름

**Octokit SDK 사용 시 자동 처리**:

```typescript
// src/modules/qna/octokit.ts
import { Octokit } from '@octokit/rest';
import { createAppAuth } from '@octokit/auth-app';
import { throttling } from '@octokit/plugin-throttling';
import { retry } from '@octokit/plugin-retry';

const MyOctokit = Octokit.plugin(throttling, retry);

/**
 * GitHub App 인증으로 Octokit 인스턴스 생성 (캐싱 권장)
 */
export const createOctokitInstance = (config: {
  appId: string;
  privateKey: string;
  installationId: string;
}): Octokit => {
  return new MyOctokit({
    authStrategy: createAppAuth,
    auth: {
      appId: config.appId,
      privateKey: config.privateKey,
      installationId: parseInt(config.installationId, 10),
    },
    throttle: {
      onRateLimit: (retryAfter, options, octokit, retryCount) => {
        octokit.log.warn(`Rate limit hit: ${options.method} ${options.url}`);
        if (retryCount < 2) {
          octokit.log.info(`Retrying after ${retryAfter}s`);
          return true; // 재시도
        }
        return false; // 포기
      },
      onSecondaryRateLimit: (retryAfter, options, octokit) => {
        octokit.log.warn(`Secondary rate limit: ${options.method} ${options.url}`);
        return true; // 콘텐츠 생성은 secondary rate limit에 민감하므로 재시도
      },
    },
    retry: {
      doNotRetry: ['429'], // throttling 플러그인이 429를 처리
    },
  });
};

/**
 * Octokit 인스턴스 캐시 (appId 기준)
 */
const octokitCache = new Map<number, Octokit>();

export const getOctokitInstance = (appId: number, config: {
  appId: string;
  privateKey: string;
  installationId: string;
}): Octokit => {
  if (!octokitCache.has(appId)) {
    octokitCache.set(appId, createOctokitInstance(config));
  }
  return octokitCache.get(appId)!;
};
```

**장점**:
- `@octokit/auth-app`이 JWT 생성 및 Installation Token 교환을 자동 처리
- 토큰 만료 시 자동 재발급
- Rate Limit 자동 처리 (재시도, 대기)

### 3.3 GitHub Issue 본문 포맷

**메타데이터 포함 Markdown**:

```typescript
// src/modules/qna/services.ts
/**
 * GitHub Issue 본문 생성 (질문 내용 + 메타데이터)
 */
const buildIssueBody = (
  body: string,
  metadata: {
    userId: number | null;
    appCode: string;
    timestamp: string;
  }
): string => {
  // 사용자 입력 새니타이징 (제어 문자 제거)
  const sanitizedBody = body
    .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '')
    .trim();

  const userInfo = metadata.userId
    ? `사용자 ID: ${metadata.userId}`
    : '익명 사용자';

  return [
    '## 질문 내용',
    '',
    sanitizedBody,
    '',
    '---',
    '',
    '## 메타데이터',
    '',
    `- ${userInfo}`,
    `- 앱: ${metadata.appCode}`,
    `- 작성 시각: ${metadata.timestamp}`,
    '',
    '*이 이슈는 자동 생성되었습니다.*',
  ].join('\n');
};
```

**생성된 Issue 예시**:

```
제목: 운동 강도 조절

## 질문 내용

운동 강도를 어떻게 조절하나요? 초보자에게 적합한 강도는 무엇인가요?

---

## 메타데이터

- 사용자 ID: 123
- 앱: wowa
- 작성 시각: 2026-02-04T10:00:00Z

*이 이슈는 자동 생성되었습니다.*
```

### 3.4 에러 처리 전략

#### GitHub API 에러 매핑

```typescript
// src/modules/qna/services.ts
import { ExternalApiException, NotFoundException, BusinessException } from '../../utils/errors';
import { logger } from '../../utils/logger';

/**
 * GitHub Issue 생성 (에러 처리 포함)
 */
export const createGitHubIssue = async (
  octokit: Octokit,
  params: {
    owner: string;
    repo: string;
    title: string;
    body: string;
    labels: string[];
  }
) => {
  try {
    const { data: issue } = await octokit.rest.issues.create({
      owner: params.owner,
      repo: params.repo,
      title: params.title,
      body: params.body,
      labels: params.labels,
    });

    return {
      issueNumber: issue.number,
      issueUrl: issue.html_url,
      createdAt: issue.created_at,
    };
  } catch (error: any) {
    // Octokit 에러는 error.status로 HTTP 상태코드 확인 가능
    const status = error.status || 500;
    const message = error.message || 'Unknown error';

    logger.error(
      {
        status,
        message,
        owner: params.owner,
        repo: params.repo,
        error: error.response?.data || error,
      },
      'GitHub API error'
    );

    // HTTP 상태코드별 처리
    if (status === 401 || status === 403) {
      // 인증 실패 또는 권한 부족 (서버 설정 오류)
      throw new ExternalApiException('GitHub', error);
    }

    if (status === 404) {
      // 레포지토리 없음 또는 접근 권한 없음
      throw new NotFoundException('GitHub Repository', `${params.owner}/${params.repo}`);
    }

    if (status === 422) {
      // 유효성 검증 실패 (제목 누락 등)
      throw new BusinessException(`GitHub validation error: ${message}`, 'GITHUB_VALIDATION_ERROR');
    }

    if (status === 429 || status === 403) {
      // Rate Limit 초과 (throttling 플러그인이 재시도하지만, 최종 실패 시)
      throw new ExternalApiException('GitHub', {
        message: 'GitHub API rate limit exceeded. Please try again later.',
      });
    }

    // 기타 에러
    throw new ExternalApiException('GitHub', error);
  }
};
```

#### Rate Limit 대응

**Primary Rate Limit**:
- GitHub App: 시간당 5,000 ~ 12,500건 (레포/사용자 수에 따라 스케일링)
- `@octokit/plugin-throttling`이 자동으로 대기 및 재시도

**Secondary Rate Limit**:
- 콘텐츠 생성 (Issue 등): 분당 80건, 시간당 500건
- Retry-After 헤더 없을 수 있음 → 최소 60초 대기 후 재시도
- `onSecondaryRateLimit` 핸들러에서 `return true`로 재시도 설정

**큐 기반 순차 처리 (선택적)**:

```typescript
// src/modules/qna/queue.ts
import PQueue from 'p-queue';

/**
 * Issue 생성 요청 큐 (동시성 제어)
 */
export const issueQueue = new PQueue({
  concurrency: 1,        // 동시 1건만 처리
  interval: 1000,         // 1초 간격
  intervalCap: 1,         // 간격당 1건
});

/**
 * 큐에 Issue 생성 작업 추가
 */
export const queueIssueCreation = (fn: () => Promise<any>) => {
  return issueQueue.add(fn);
};
```

---

## 4. 모듈 구조

### 디렉토리 구조

```
apps/server/src/modules/qna/
├── index.ts              # Router 정의 및 export
├── handlers.ts           # Express 미들웨어 함수 (submitQuestion)
├── services.ts           # 비즈니스 로직 (GitHub Issue 생성, DB 조작)
├── schema.ts             # Drizzle 테이블 정의 (qna_config, qna_questions)
├── validators.ts         # Zod 입력 검증 스키마
├── types.ts              # TypeScript 타입 정의
├── octokit.ts            # Octokit 인스턴스 생성 및 캐싱
├── qna.probe.ts          # 운영 로그 함수 (Domain Probe 패턴)
└── README.md             # 모듈 사용법 및 설정 가이드
```

### 파일별 책임

#### index.ts

```typescript
import { Router } from 'express';
import { submitQuestion } from './handlers';
import { optionalAuthenticate } from '../../middleware/auth';

const router = Router();

/**
 * POST /qna/questions - 질문 제출 (선택적 인증)
 */
router.post('/questions', optionalAuthenticate, submitQuestion);

export default router;
```

**설계 근거**:
- `optionalAuthenticate`: Authorization 헤더가 있으면 검증하고 req.user 설정, 없으면 통과
- 익명 사용자도 질문 제출 가능

#### handlers.ts

```typescript
import { Request, Response } from 'express';
import { submitQuestionSchema } from './validators';
import { createQuestion } from './services';
import * as qnaProbe from './qna.probe';
import { logger } from '../../utils/logger';

/**
 * 질문 제출 핸들러 (선택적 인증)
 */
export const submitQuestion = async (req: Request, res: Response) => {
  const { appCode, title, body } = submitQuestionSchema.parse(req.body);
  const user = (req as any).user as { userId: number; appId: number } | undefined;

  logger.debug({ appCode, title: title.substring(0, 50), userId: user?.userId }, 'Submitting question');

  const result = await createQuestion({
    appCode,
    userId: user?.userId || null,
    title,
    body,
  });

  qnaProbe.questionSubmitted({
    questionId: result.questionId,
    appCode,
    userId: user?.userId || null,
    issueNumber: result.issueNumber,
  });

  res.status(201).json({
    questionId: result.questionId,
    issueNumber: result.issueNumber,
    issueUrl: result.issueUrl,
    createdAt: result.createdAt,
  });
};
```

#### services.ts

```typescript
import { db } from '../../config/database';
import { qnaConfig, qnaQuestions } from './schema';
import { apps } from '../auth/schema';
import { getOctokitInstance } from './octokit';
import { createGitHubIssue } from './github';
import { NotFoundException } from '../../utils/errors';
import { eq } from 'drizzle-orm';

/**
 * 질문 생성 (GitHub Issue 생성 + DB 저장)
 */
export const createQuestion = async (params: {
  appCode: string;
  userId: number | null;
  title: string;
  body: string;
}) => {
  // 1. 앱 조회
  const [app] = await db.select().from(apps).where(eq(apps.code, params.appCode));
  if (!app) {
    throw new NotFoundException('App', params.appCode);
  }

  // 2. QnA 설정 조회
  const [config] = await db.select().from(qnaConfig).where(eq(qnaConfig.appId, app.id));
  if (!config) {
    throw new NotFoundException('QnA Config', params.appCode);
  }

  // 3. Octokit 인스턴스 가져오기
  const octokit = getOctokitInstance(app.id, {
    appId: config.githubAppId,
    privateKey: config.githubPrivateKey,
    installationId: config.githubInstallationId,
  });

  // 4. Issue 본문 생성
  const issueBody = buildIssueBody(params.body, {
    userId: params.userId,
    appCode: params.appCode,
    timestamp: new Date().toISOString(),
  });

  // 5. GitHub Issue 생성
  const labels = JSON.parse(config.githubLabels) as string[];
  const githubResult = await createGitHubIssue(octokit, {
    owner: config.githubRepoOwner,
    repo: config.githubRepoName,
    title: params.title,
    body: issueBody,
    labels,
  });

  // 6. DB에 질문 이력 저장 (선택적)
  const [question] = await db
    .insert(qnaQuestions)
    .values({
      appId: app.id,
      userId: params.userId,
      title: params.title,
      body: params.body,
      issueNumber: githubResult.issueNumber,
      issueUrl: githubResult.issueUrl,
    })
    .returning();

  return {
    questionId: question.id,
    issueNumber: githubResult.issueNumber,
    issueUrl: githubResult.issueUrl,
    createdAt: githubResult.createdAt,
  };
};

/**
 * GitHub Issue 본문 생성
 */
const buildIssueBody = (
  body: string,
  metadata: { userId: number | null; appCode: string; timestamp: string }
): string => {
  const sanitizedBody = body
    .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '')
    .trim();

  const userInfo = metadata.userId ? `사용자 ID: ${metadata.userId}` : '익명 사용자';

  return [
    '## 질문 내용',
    '',
    sanitizedBody,
    '',
    '---',
    '',
    '## 메타데이터',
    '',
    `- ${userInfo}`,
    `- 앱: ${metadata.appCode}`,
    `- 작성 시각: ${metadata.timestamp}`,
    '',
    '*이 이슈는 자동 생성되었습니다.*',
  ].join('\n');
};
```

#### validators.ts

```typescript
import { z } from 'zod';

/**
 * 질문 제출 요청 스키마
 */
export const submitQuestionSchema = z.object({
  appCode: z.string().min(1, 'App code is required').max(50, 'App code is too long'),
  title: z.string().min(1, 'Title is required').max(256, 'Title must be 1-256 characters'),
  body: z.string().min(1, 'Body is required').max(65536, 'Body must be 1-65536 characters'),
});

export type SubmitQuestionRequest = z.infer<typeof submitQuestionSchema>;
```

#### qna.probe.ts

```typescript
import { logger } from '../../utils/logger';

/**
 * 질문 제출 성공 로그 (INFO)
 */
export const questionSubmitted = (data: {
  questionId: number;
  appCode: string;
  userId: number | null;
  issueNumber: number;
}) => {
  logger.info(
    {
      questionId: data.questionId,
      appCode: data.appCode,
      userId: data.userId || 'anonymous',
      issueNumber: data.issueNumber,
    },
    'Question submitted to GitHub'
  );
};

/**
 * GitHub API Rate Limit 경고 (WARN)
 */
export const rateLimitWarning = (data: {
  appCode: string;
  remaining: number;
  resetAt: string;
}) => {
  logger.warn(
    {
      appCode: data.appCode,
      remaining: data.remaining,
      resetAt: data.resetAt,
    },
    'GitHub API rate limit approaching'
  );
};

/**
 * GitHub API 에러 (ERROR)
 */
export const githubApiError = (data: {
  appCode: string;
  error: string;
  statusCode: number;
}) => {
  logger.error(
    {
      appCode: data.appCode,
      error: data.error,
      statusCode: data.statusCode,
    },
    'GitHub API error occurred'
  );
};

/**
 * QnA 설정 누락 (WARN)
 */
export const configNotFound = (data: { appCode: string }) => {
  logger.warn(
    {
      appCode: data.appCode,
    },
    'QnA config not found for app'
  );
};
```

---

## 5. 테스트 전략

### TDD 기반 단위 테스트

#### 테스트 파일 구조

```
apps/server/tests/unit/qna/
├── handlers.test.ts      # submitQuestion 핸들러 테스트
├── services.test.ts      # createQuestion 서비스 테스트
├── validators.test.ts    # Zod 스키마 테스트
└── octokit.test.ts       # Octokit 인스턴스 생성 테스트
```

#### handlers.test.ts

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Request, Response } from 'express';
import * as handlers from '../../../src/modules/qna/handlers';
import * as services from '../../../src/modules/qna/services';
import * as qnaProbe from '../../../src/modules/qna/qna.probe';

vi.mock('../../../src/modules/qna/services');
vi.mock('../../../src/modules/qna/qna.probe');

describe('QnA Handlers', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;

  beforeEach(() => {
    mockReq = {
      body: {},
      user: undefined,
    };
    mockRes = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    };
    vi.clearAllMocks();
  });

  describe('submitQuestion', () => {
    it('should submit question with authenticated user', async () => {
      mockReq.body = {
        appCode: 'wowa',
        title: '운동 강도 조절',
        body: '운동 강도를 어떻게 조절하나요?',
      };
      mockReq.user = { userId: 123, appId: 1 };

      vi.mocked(services.createQuestion).mockResolvedValue({
        questionId: 1,
        issueNumber: 1347,
        issueUrl: 'https://github.com/org/repo/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      await handlers.submitQuestion(mockReq as Request, mockRes as Response);

      expect(services.createQuestion).toHaveBeenCalledWith({
        appCode: 'wowa',
        userId: 123,
        title: '운동 강도 조절',
        body: '운동 강도를 어떻게 조절하나요?',
      });

      expect(qnaProbe.questionSubmitted).toHaveBeenCalled();
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        questionId: 1,
        issueNumber: 1347,
        issueUrl: 'https://github.com/org/repo/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });
    });

    it('should submit question with anonymous user', async () => {
      mockReq.body = {
        appCode: 'wowa',
        title: '질문',
        body: '내용',
      };
      mockReq.user = undefined; // 비인증 사용자

      vi.mocked(services.createQuestion).mockResolvedValue({
        questionId: 2,
        issueNumber: 1348,
        issueUrl: 'https://github.com/org/repo/issues/1348',
        createdAt: '2026-02-04T11:00:00Z',
      });

      await handlers.submitQuestion(mockReq as Request, mockRes as Response);

      expect(services.createQuestion).toHaveBeenCalledWith({
        appCode: 'wowa',
        userId: null, // 익명 사용자
        title: '질문',
        body: '내용',
      });

      expect(mockRes.status).toHaveBeenCalledWith(201);
    });

    it('should throw validation error for missing title', async () => {
      mockReq.body = {
        appCode: 'wowa',
        body: '내용',
      };

      await expect(
        handlers.submitQuestion(mockReq as Request, mockRes as Response)
      ).rejects.toThrow(); // Zod 에러
    });
  });
});
```

#### services.test.ts

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import * as services from '../../../src/modules/qna/services';
import * as github from '../../../src/modules/qna/github';
import { db } from '../../../src/config/database';
import { NotFoundException } from '../../../src/utils/errors';

vi.mock('../../../src/config/database');
vi.mock('../../../src/modules/qna/github');
vi.mock('../../../src/modules/qna/octokit');

describe('QnA Services', () => {
  describe('createQuestion', () => {
    it('should create GitHub issue and save to database', async () => {
      // Mock DB 조회
      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([
            { id: 1, code: 'wowa' }, // app
          ]),
        }),
      } as any);

      vi.mocked(db.select).mockReturnValueOnce({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([
            {
              appId: 1,
              githubRepoOwner: 'org',
              githubRepoName: 'repo',
              githubAppId: '123',
              githubPrivateKey: 'key',
              githubInstallationId: '456',
              githubLabels: '["qna"]',
            }, // qna_config
          ]),
        }),
      } as any);

      // Mock GitHub Issue 생성
      vi.mocked(github.createGitHubIssue).mockResolvedValue({
        issueNumber: 1347,
        issueUrl: 'https://github.com/org/repo/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      // Mock DB 삽입
      vi.mocked(db.insert).mockReturnValue({
        values: vi.fn().mockReturnValue({
          returning: vi.fn().mockResolvedValue([
            {
              id: 1,
              appId: 1,
              userId: 123,
              title: '질문',
              body: '내용',
              issueNumber: 1347,
              issueUrl: 'https://github.com/org/repo/issues/1347',
            },
          ]),
        }),
      } as any);

      const result = await services.createQuestion({
        appCode: 'wowa',
        userId: 123,
        title: '질문',
        body: '내용',
      });

      expect(result).toEqual({
        questionId: 1,
        issueNumber: 1347,
        issueUrl: 'https://github.com/org/repo/issues/1347',
        createdAt: '2026-02-04T10:00:00Z',
      });

      expect(github.createGitHubIssue).toHaveBeenCalled();
    });

    it('should throw NotFoundException when app not found', async () => {
      vi.mocked(db.select).mockReturnValue({
        from: vi.fn().mockReturnValue({
          where: vi.fn().mockResolvedValue([]), // 앱 없음
        }),
      } as any);

      await expect(
        services.createQuestion({
          appCode: 'invalid',
          userId: 123,
          title: '질문',
          body: '내용',
        })
      ).rejects.toThrow(NotFoundException);
    });
  });
});
```

---

## 6. 배포 및 설정

### 환경 변수

```bash
# .env
# (GitHub 인증 정보는 qna_config 테이블에서 관리하므로 환경 변수 불필요)
DATABASE_URL=postgresql://user:pass@localhost:5432/gaegulzip
```

### 데이터베이스 마이그레이션

```bash
# 1. 마이그레이션 파일 생성
pnpm drizzle-kit generate

# 2. 마이그레이션 적용
pnpm drizzle-kit migrate
```

### qna_config 테이블 데이터 삽입

```sql
-- wowa 앱에 대한 GitHub 연동 설정
INSERT INTO qna_config (
  app_id,
  github_repo_owner,
  github_repo_name,
  github_app_id,
  github_private_key,
  github_installation_id,
  github_labels
) VALUES (
  1,  -- wowa 앱 ID (apps.id)
  'gaegulzip-org',
  'wowa-issues',
  '123456',  -- GitHub App ID (Client ID)
  '-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
-----END RSA PRIVATE KEY-----',  -- GitHub App Private Key
  '789012',  -- GitHub App Installation ID
  '["qna", "user-question"]'
);
```

**GitHub App 생성 및 설정**:
1. GitHub → Settings → Developer settings → GitHub Apps → New GitHub App
2. App 이름, 권한 설정:
   - Repository permissions: Issues (Read & Write)
3. Private Key 생성 및 다운로드 (PEM 파일)
4. 조직에 App 설치 → Installation ID 확인
5. `qna_config` 테이블에 저장

---

## 7. 보안 고려사항

### 7.1 Private Key 암호화

**문제**: Private Key가 평문으로 DB에 저장됨 (보안 위험)

**해결책 1: 환경 변수 사용**
```bash
# .env
GITHUB_APP_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
```

**해결책 2: Secret Manager 사용 (프로덕션 권장)**
- AWS Secrets Manager
- HashiCorp Vault
- 서버 시작 시 Secret Manager에서 Private Key 로드

### 7.2 사용자 입력 새니타이징

```typescript
// 제어 문자 제거 (탭, 개행은 유지)
const sanitizedInput = input.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '');
```

### 7.3 Rate Limiting

**클라이언트 Rate Limiting** (선택적):
- express-rate-limit 사용
- IP당 분당 10건 제한

```typescript
// src/middleware/rate-limit.ts
import rateLimit from 'express-rate-limit';

export const qnaRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1분
  max: 10, // 분당 10건
  message: 'Too many questions submitted. Please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
```

```typescript
// src/modules/qna/index.ts
router.post('/questions', qnaRateLimiter, optionalAuthenticate, submitQuestion);
```

---

## 8. 모니터링 및 운영

### 8.1 운영 로그 (Domain Probe)

**주요 로그 포인트**:
- 질문 제출 성공 (INFO)
- GitHub API Rate Limit 경고 (WARN, remaining < 100)
- GitHub API 에러 (ERROR)
- QnA 설정 누락 (WARN)

### 8.2 알람 임계값

| 로그 레벨 | 임계값 | 설명 |
|----------|--------|------|
| ERROR | 분당 5개 이상 | 즉시 대응 (GitHub API 장애, DB 연결 실패) |
| WARN | 분당 20개 이상 | 주의 필요 (Rate Limit 접근, 설정 누락) |
| INFO | 기존 대비 ±50% 이상 | 트래픽 급변 감지 |

### 8.3 메트릭

**수집 권장 메트릭**:
- 질문 제출 수 (시간당/일별)
- GitHub API 호출 수
- GitHub API 에러율
- 평균 응답 시간
- 익명 사용자 비율

---

## 9. 향후 확장 계획

### Phase 2: 질문 목록 조회

```typescript
// GET /qna/questions?appCode=wowa&limit=50&offset=0
export const listQuestions = async (req: Request, res: Response) => {
  // qna_questions 테이블에서 조회
};
```

### Phase 3: GitHub Issue 상태 동기화

```typescript
// Webhook으로 Issue 상태 변경 수신
// qna_questions 테이블에 status 컬럼 추가
```

### Phase 4: 첨부파일 지원

```typescript
// 이미지 업로드 → S3 → GitHub Issue에 이미지 URL 포함
```

---

## 10. 의존성 패키지

### 필요한 npm 패키지

```json
{
  "dependencies": {
    "octokit": "^3.1.2",
    "@octokit/rest": "^20.0.2",
    "@octokit/auth-app": "^6.0.1",
    "@octokit/plugin-throttling": "^8.1.0",
    "@octokit/plugin-retry": "^6.0.1",
    "p-queue": "^8.0.1"
  }
}
```

### 설치

```bash
cd /Users/lms/dev/repository/feature-qna/apps/server
pnpm add octokit @octokit/rest @octokit/auth-app @octokit/plugin-throttling @octokit/plugin-retry p-queue
```

---

## 11. 체크리스트

### 구현 전 확인

- [ ] GitHub App 생성 및 Private Key 발급
- [ ] GitHub App을 조직에 설치 (Installation ID 확인)
- [ ] `qna_config` 테이블에 설정 데이터 삽입
- [ ] npm 패키지 설치 (`octokit` 등)

### 구현 중 확인

- [ ] Drizzle 스키마 정의 (qna_config, qna_questions)
- [ ] Zod 입력 검증 스키마 작성
- [ ] Octokit 인스턴스 생성 및 캐싱
- [ ] GitHub Issue 생성 로직 (메타데이터 포함)
- [ ] 에러 처리 (GitHub API 에러 매핑)
- [ ] Domain Probe 패턴으로 운영 로그 분리
- [ ] optionalAuthenticate 미들웨어 구현

### 구현 후 확인

- [ ] TDD 단위 테스트 작성 및 통과
- [ ] API 문서 작성 (Swagger/OpenAPI)
- [ ] 수동 테스트 (Postman/Insomnia)
- [ ] Rate Limit 동작 확인
- [ ] 로그 출력 확인 (INFO, WARN, ERROR)
- [ ] 익명 사용자 질문 제출 테스트
- [ ] GitHub Issue에 메타데이터 정확히 포함되는지 확인

---

## 12. 참고 자료

- [GitHub Issues REST API](https://docs.github.com/en/rest/issues/issues)
- [GitHub App 인증](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app)
- [Octokit.js 공식 문서](https://github.com/octokit/octokit.js)
- [Rate Limits for REST API](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api)
- 프로젝트 리서치: [`docs/wowa/research/github-issues-api.md`](../../wowa/research/github-issues-api.md)

---

## 요약

### 핵심 설계 결정

1. **GitHub App 인증**: Installation Token 자동 갱신, Rate Limit 스케일링
2. **Octokit SDK**: 공식 SDK로 JWT/토큰 관리 자동화
3. **선택적 인증**: 익명 사용자도 질문 제출 가능
4. **DB 스키마**: qna_config (앱별 설정), qna_questions (질문 이력, 선택적)
5. **Domain Probe 패턴**: 운영 로그와 비즈니스 로직 분리
6. **에러 처리**: GitHub API 에러 → ExternalApiException
7. **Rate Limit 대응**: throttling/retry 플러그인 + 큐 기반 순차 처리

### 작업 분배 (CTO가 참조)

**Senior Developer**:
- Octokit 인스턴스 생성 및 캐싱 (octokit.ts)
- GitHub Issue 생성 로직 (services.ts)
- 에러 처리 및 Rate Limit 대응
- Domain Probe 패턴 적용 (qna.probe.ts)
- TDD 단위 테스트 작성

**Junior Developer**:
- Drizzle 스키마 작성 (schema.ts)
- Zod 입력 검증 스키마 (validators.ts)
- Express 핸들러 작성 (handlers.ts)
- Router 설정 (index.ts)
- optionalAuthenticate 미들웨어 구현

### 작업 의존성

1. Drizzle 스키마 작성 (Junior) → DB 마이그레이션
2. Octokit 인스턴스 생성 (Senior) → GitHub Issue 생성 로직
3. GitHub Issue 생성 로직 (Senior) → 핸들러 작성 (Junior)
4. 전체 완성 후 → TDD 테스트 작성 (Senior)

작업이 완료되면 CTO가 설계를 검증하고 작업을 분배합니다.
