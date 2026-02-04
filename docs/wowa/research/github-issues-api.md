# GitHub Issues REST API 리서치

> 작성일: 2026-02-04
> 목적: 서버 사이드에서 GitHub Issues를 프로그래밍 방식으로 생성하기 위한 API, 인증, 보안, 에러 처리 종합 분석

---

## 목차

1. [GitHub Issues REST API](#1-github-issues-rest-api)
2. [서버 사이드 인증 방법](#2-서버-사이드-인증-방법)
3. [GitHub App Installation Token 흐름](#3-github-app-installation-token-흐름)
4. [Rate Limit 및 모범 사례](#4-rate-limit-및-모범-사례)
5. [에러 처리](#5-에러-처리)
6. [Octokit (공식 GitHub SDK for Node.js)](#6-octokit-공식-github-sdk-for-nodejs)
7. [보안 고려사항](#7-보안-고려사항)
8. [멀티 테넌트 서버 아키텍처 권장사항](#8-멀티-테넌트-서버-아키텍처-권장사항)
9. [참고 자료](#9-참고-자료)

---

## 1. GitHub Issues REST API

### 1.1 엔드포인트

```
POST /repos/{owner}/{repo}/issues
```

### 1.2 필수 헤더

```http
Accept: application/vnd.github+json
Authorization: Bearer <TOKEN>
X-GitHub-Api-Version: 2022-11-28
```

### 1.3 Path 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `owner` | string | 필수 | 레포지토리 소유자(사용자 또는 조직) |
| `repo` | string | 필수 | 레포지토리 이름 |

### 1.4 Body 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `title` | string | **필수** | 이슈 제목 |
| `body` | string | 선택 | 이슈 본문 (Markdown 지원) |
| `assignees` | string[] | 선택 | 할당할 사용자 login 목록 |
| `milestone` | integer | 선택 | 연결할 마일스톤 번호 |
| `labels` | string[] | 선택 | 적용할 라벨 이름 목록 |
| `type` | string | 선택 | 이슈 유형 (2025년 신규, 예: `"Bug"`) |

### 1.5 요청 예시

```bash
curl -X POST \
  https://api.github.com/repos/myorg/myrepo/issues \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ghp_xxxxxxxxxxxx" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{
    "title": "[QnA] 사용자 질문: 운동 강도 조절",
    "body": "## 질문 내용\n\n운동 강도를 어떻게 조절하나요?\n\n---\n*자동 생성된 이슈입니다.*",
    "labels": ["qna", "user-question"],
    "assignees": ["coach-kim"]
  }'
```

### 1.6 응답 형식

**성공 시: `201 Created`**

```json
{
  "id": 1,
  "node_id": "MDU6SXNzdWUx",
  "url": "https://api.github.com/repos/myorg/myrepo/issues/1347",
  "html_url": "https://github.com/myorg/myrepo/issues/1347",
  "number": 1347,
  "state": "open",
  "title": "[QnA] 사용자 질문: 운동 강도 조절",
  "body": "## 질문 내용\n\n운동 강도를 어떻게 조절하나요?",
  "user": {
    "login": "myapp[bot]",
    "id": 12345,
    "type": "Bot"
  },
  "labels": [
    { "id": 1, "name": "qna", "color": "fc2929" }
  ],
  "assignees": [],
  "milestone": null,
  "comments": 0,
  "created_at": "2026-02-04T10:00:00Z",
  "updated_at": "2026-02-04T10:00:00Z",
  "closed_at": null
}
```

**응답에서 활용 가능한 핵심 필드:**

| 필드 | 용도 |
|------|------|
| `number` | 이슈 번호 (레포 내 고유) |
| `html_url` | 브라우저에서 접근 가능한 URL |
| `id` | GitHub 전역 고유 ID |
| `node_id` | GraphQL API용 ID |
| `created_at` | 생성 시각 (UTC, ISO 8601) |

### 1.7 커스텀 미디어 타입

| 미디어 타입 | 설명 |
|------------|------|
| `application/vnd.github.raw+json` | 원본 Markdown body (기본값) |
| `application/vnd.github.text+json` | 텍스트 전용, `body_text` 포함 |
| `application/vnd.github.html+json` | HTML 렌더링, `body_html` 포함 |
| `application/vnd.github.full+json` | raw + text + html 모두 포함 |

---

## 2. 서버 사이드 인증 방법

### 2.1 인증 방법 비교

| 방법 | Rate Limit | 토큰 수명 | 권한 세분화 | 멀티 테넌트 적합성 | 관리 부담 |
|------|-----------|----------|-----------|------------------|----------|
| **GitHub App** | 5,000~12,500/시간 | 1시간 (자동 갱신) | 매우 세밀 | **최적** | 중간 |
| **Fine-grained PAT** | 5,000/시간 | 최대 1년 | 세밀 | 낮음 | 낮음 |
| **Classic PAT** | 5,000/시간 | 무제한 가능 | 넓은 scope | 낮음 | 낮음 |
| **OAuth App** | 5,000/시간 | 사용자 폐기까지 | scope 기반 | 중간 | 높음 |

### 2.2 GitHub App (프로덕션 권장)

**장점:**
- 설치(installation) 단위로 권한 범위가 자동 분리됨
- 봇 계정으로 동작하여 개인 계정과 분리
- 토큰이 1시간 후 자동 만료 (보안 강화)
- Rate Limit이 레포지토리/사용자 수에 따라 스케일링
- Webhook 이벤트 수신 가능

**적합한 시나리오:**
- 프로덕션 서버에서 자동화된 이슈 생성
- 앱 코드별로 다른 레포에 이슈를 생성하는 멀티 테넌트 서버
- 봇 아이덴티티가 필요한 경우

### 2.3 Fine-grained Personal Access Token

**장점:**
- 레포지토리별 접근 제한 가능
- 세밀한 권한 설정 (Issues: Read and Write)
- 만료일 필수 (최대 1년)

**단점:**
- 특정 개인 계정에 종속
- 멀티 테넌트에서 토큰 관리가 복잡
- 해당 사용자가 조직을 떠나면 토큰 무효화
- 조직 소유자의 승인이 필요할 수 있음

**적합한 시나리오:**
- 개발/테스트 환경
- 단일 레포에만 접근하는 간단한 자동화

### 2.4 Classic Personal Access Token

**장점:**
- 설정이 가장 간단
- 만료 없이 사용 가능

**단점:**
- `repo` scope가 너무 넓음 (모든 private 레포 접근)
- 보안 위험이 가장 높음
- GitHub이 fine-grained PAT으로 이전 권장

**적합한 시나리오:**
- 로컬 개발/프로토타이핑 전용

### 2.5 멀티 테넌트 서버에서의 인증 전략

앱 코드별로 다른 레포에 이슈를 생성해야 하는 경우:

```
[앱 A] --> [레포: org/app-a-issues]
[앱 B] --> [레포: org/app-b-issues]
[앱 C] --> [레포: org/app-c-issues]
```

**권장: GitHub App**
- 하나의 GitHub App을 생성하고, 해당 조직에 설치
- 설치 시 접근 가능한 레포지토리를 선택하거나 전체 허용
- 서버에서 앱 코드와 레포 매핑을 관리하고, 동일한 installation token으로 모든 레포에 접근
- 같은 조직 내 레포라면 하나의 installation으로 충분

**주의사항:**
- 하나의 installation은 하나의 사용자/조직에만 속함
- 다른 조직의 레포에 접근하려면 해당 조직에 별도 설치 필요
- installation별로 별도의 access token 발급 필요

---

## 3. GitHub App Installation Token 흐름

### 3.1 전체 흐름

```
1. App 등록 시 발급받은 Private Key + App ID 보관
2. Private Key로 JWT 생성 (RS256, 최대 10분 유효)
3. JWT로 Installation Access Token 교환 (1시간 유효)
4. Installation Access Token으로 API 호출
5. 토큰 만료 시 2~4 반복
```

### 3.2 JWT 생성

JWT Payload 구조:

| 클레임 | 설명 |
|--------|------|
| `iat` | 발급 시각 (현재 시각 - 60초 권장, 시간 차이 대응) |
| `exp` | 만료 시각 (최대 10분 후) |
| `iss` | GitHub App의 Client ID (또는 App ID) |

서명 알고리즘: **RS256** (RSA + SHA-256)

```typescript
import jwt from "jsonwebtoken";
import fs from "fs";

function generateJWT(appId: string, privateKeyPath: string): string {
  const privateKey = fs.readFileSync(privateKeyPath, "utf8");

  const now = Math.floor(Date.now() / 1000);

  const payload = {
    iat: now - 60,        // 발급 시각 (시계 오차 대비 60초 전)
    exp: now + (10 * 60), // 만료 시각 (10분 후)
    iss: appId,           // GitHub App의 Client ID
  };

  return jwt.sign(payload, privateKey, { algorithm: "RS256" });
}
```

### 3.3 Installation ID 확인

Installation ID는 다음 방법으로 확인 가능:

```bash
# 방법 1: App의 모든 installation 목록 조회
curl -H "Authorization: Bearer <JWT>" \
  https://api.github.com/app/installations

# 방법 2: 특정 레포의 installation 조회
curl -H "Authorization: Bearer <JWT>" \
  https://api.github.com/repos/{owner}/{repo}/installation

# 방법 3: 특정 조직의 installation 조회
curl -H "Authorization: Bearer <JWT>" \
  https://api.github.com/orgs/{org}/installation
```

### 3.4 Installation Access Token 교환

```bash
curl -X POST \
  https://api.github.com/app/installations/{installation_id}/access_tokens \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <JWT>" \
  -H "X-GitHub-Api-Version: 2022-11-28"
```

선택적으로 접근 범위를 제한할 수 있음:

```json
{
  "repositories": ["app-a-issues"],
  "permissions": {
    "issues": "write"
  }
}
```

응답:

```json
{
  "token": "ghs_xxxxxxxxxxxxxxxxxxxx",
  "expires_at": "2026-02-04T11:00:00Z",
  "permissions": {
    "issues": "write",
    "metadata": "read"
  },
  "repository_selection": "selected"
}
```

### 3.5 토큰 수명 및 갱신 전략

| 토큰 | 수명 | 갱신 방법 |
|------|------|----------|
| JWT | 최대 10분 | Private Key로 재생성 |
| Installation Access Token | 1시간 | JWT로 재교환 |

**갱신 전략 권장 사항:**

```typescript
class GitHubTokenManager {
  private token: string | null = null;
  private expiresAt: Date | null = null;

  async getToken(): Promise<string> {
    // 만료 5분 전에 미리 갱신
    if (!this.token || !this.expiresAt || this.isExpiringSoon()) {
      await this.refreshToken();
    }
    return this.token!;
  }

  private isExpiringSoon(): boolean {
    if (!this.expiresAt) return true;
    const fiveMinutesFromNow = new Date(Date.now() + 5 * 60 * 1000);
    return this.expiresAt <= fiveMinutesFromNow;
  }

  private async refreshToken(): Promise<void> {
    const jwt = generateJWT(this.appId, this.privateKeyPath);
    const response = await fetch(
      `https://api.github.com/app/installations/${this.installationId}/access_tokens`,
      {
        method: "POST",
        headers: {
          Accept: "application/vnd.github+json",
          Authorization: `Bearer ${jwt}`,
          "X-GitHub-Api-Version": "2022-11-28",
        },
      }
    );
    const data = await response.json();
    this.token = data.token;
    this.expiresAt = new Date(data.expires_at);
  }
}
```

### 3.6 필요 권한

이슈 생성에 필요한 최소 권한:

| 권한 | 수준 | 설명 |
|------|------|------|
| `issues` | `write` | 이슈 생성, 수정, 코멘트 |
| `metadata` | `read` | 자동 부여됨 (레포 메타데이터 접근) |

Label을 사용하려면 이슈에 대한 write 권한이면 충분. Assignee 지정도 동일.

---

## 4. Rate Limit 및 모범 사례

### 4.1 인증 방법별 Rate Limit

| 인증 방법 | 시간당 요청 수 |
|----------|--------------|
| 비인증 | 60 |
| Personal Access Token (PAT) | 5,000 |
| OAuth Token | 5,000 |
| GitHub App (Installation Token) | 5,000 ~ 12,500 (스케일링) |
| GitHub App (Enterprise Cloud) | 15,000 |
| GITHUB_TOKEN (Actions) | 1,000/레포 |

**GitHub App Installation Token 스케일링 규칙:**
- 기본: 5,000/시간
- 20개 초과 레포: 레포당 +50
- 20명 초과 사용자(조직): 사용자당 +50
- 최대: 12,500/시간

### 4.2 Secondary Rate Limit (2차 제한)

이슈 생성과 같은 콘텐츠 생성 요청에 특히 중요:

| 제한 유형 | 한도 |
|----------|------|
| 콘텐츠 생성 (분당) | 80건 |
| 콘텐츠 생성 (시간당) | 500건 |
| REST API 점수 (분당) | 900점 |
| 동시 요청 | 100건 |

**핵심 주의사항:**
> 이슈, 코멘트, PR 등 **알림을 트리거하는 콘텐츠 생성 요청**에는 `Retry-After` 헤더가 포함되지 않을 수 있음. 이 경우 최소 1분 대기 후 재시도 필요.

### 4.3 Rate Limit 응답 헤더

```http
X-RateLimit-Limit: 5000          # 시간당 허용 총 요청 수
X-RateLimit-Remaining: 4999      # 남은 요청 수
X-RateLimit-Reset: 1706957400    # 제한 리셋 시각 (Unix Epoch, UTC)
X-RateLimit-Resource: core       # Rate Limit 카테고리
```

### 4.4 Rate Limit 현황 확인

```bash
curl -H "Authorization: Bearer <TOKEN>" \
  https://api.github.com/rate_limit
```

### 4.5 Rate Limit 에러 처리

```typescript
async function handleRateLimit(response: Response): Promise<void> {
  if (response.status === 403 || response.status === 429) {
    const retryAfter = response.headers.get("retry-after");
    const rateLimitRemaining = response.headers.get("x-ratelimit-remaining");
    const rateLimitReset = response.headers.get("x-ratelimit-reset");

    if (retryAfter) {
      // Retry-After 헤더가 있으면 해당 초만큼 대기
      const waitSeconds = parseInt(retryAfter, 10);
      await sleep(waitSeconds * 1000);
    } else if (rateLimitRemaining === "0" && rateLimitReset) {
      // Primary rate limit: 리셋 시각까지 대기
      const resetTime = parseInt(rateLimitReset, 10) * 1000;
      const waitMs = Math.max(0, resetTime - Date.now());
      await sleep(waitMs);
    } else {
      // Secondary rate limit (Retry-After 없음): 최소 1분 대기
      await sleep(60_000);
    }
  }
}
```

### 4.6 Exponential Backoff 재시도 전략

```typescript
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  baseDelay: number = 1000
): Promise<T> {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries) throw error;

      // 429 또는 403이면서 rate limit인 경우만 재시도
      if (!isRetryableError(error)) throw error;

      const delay = baseDelay * Math.pow(2, attempt);
      const jitter = Math.random() * 1000;
      await sleep(delay + jitter);
    }
  }
  throw new Error("Unreachable");
}
```

### 4.7 서버 사이드 통합 모범 사례

1. **요청을 직렬로 처리**: 동시 다발적 요청 대신 직렬 처리
2. **Conditional Request 활용**: `ETag`/`Last-Modified` 헤더로 304 응답 유도 (rate limit 미차감)
3. **Webhook 우선 사용**: 폴링 대신 Webhook으로 이벤트 수신
4. **Rate Limit 사전 확인**: 요청 전 `X-RateLimit-Remaining` 확인
5. **큐 시스템 도입**: 이슈 생성 요청을 큐에 넣고 순차 처리
6. **Rate Limit 소진 시 요청 중단**: 제한 중 계속 요청하면 차단(ban) 위험

---

## 5. 에러 처리

### 5.1 주요 에러 코드

| HTTP 코드 | 의미 | 일반적인 원인 |
|-----------|------|-------------|
| `201` | Created | 성공 |
| `401` | Unauthorized | 토큰 누락, 만료, 잘못된 형식 |
| `403` | Forbidden | 권한 부족, Rate Limit 초과, IP 차단 |
| `404` | Not Found | 레포가 없음 **또는** 인증 부족 (private 레포 존재 숨김) |
| `410` | Gone | 리소스가 삭제됨 |
| `422` | Unprocessable Entity | 유효성 검증 실패 (필수 필드 누락 등) |
| `429` | Too Many Requests | Rate Limit 초과 |
| `503` | Service Unavailable | GitHub 서비스 일시 장애 |

### 5.2 에러 응답 형식

**422 Validation Error 예시:**

```json
{
  "message": "Validation Failed",
  "errors": [
    {
      "resource": "Issue",
      "field": "title",
      "code": "missing_field"
    }
  ],
  "documentation_url": "https://docs.github.com/rest/issues/issues#create-an-issue"
}
```

**Validation error의 `code` 값들:**

| code | 의미 |
|------|------|
| `missing` | 리소스가 존재하지 않음 |
| `missing_field` | 필수 필드가 누락됨 |
| `invalid` | 필드 값의 형식이 잘못됨 |
| `already_exists` | 동일한 리소스가 이미 존재 |
| `custom` | 커스텀 에러 (message 필드에 상세 설명) |

**403 Rate Limit 에러 예시:**

```json
{
  "message": "API rate limit exceeded for user ID 12345.",
  "documentation_url": "https://docs.github.com/rest/overview/rate-limits-for-the-rest-api"
}
```

**403 Secondary Rate Limit 에러 예시:**

```json
{
  "message": "You have exceeded a secondary rate limit and have been temporarily blocked from content creation. Please retry your request again later.",
  "documentation_url": "https://docs.github.com/rest/overview/rate-limits-for-the-rest-api"
}
```

### 5.3 404의 특수성

GitHub는 private 레포의 존재를 숨기기 위해 인증 실패 시에도 403 대신 **404를 반환**한다. 따라서 404를 받으면:

1. 토큰의 권한(scope) 확인
2. URL 오타 확인 (trailing slash도 404 유발)
3. 레포 이름의 대소문자 확인
4. fine-grained PAT의 경우 해당 레포에 대한 접근 권한 확인

### 5.4 에러 처리 구현 예시

```typescript
interface GitHubError {
  message: string;
  errors?: Array<{
    resource: string;
    field: string;
    code: string;
    message?: string;
  }>;
  documentation_url?: string;
}

async function createIssue(
  owner: string,
  repo: string,
  title: string,
  body: string
): Promise<GitHubIssueResponse> {
  const response = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/issues`,
    {
      method: "POST",
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: `Bearer ${await tokenManager.getToken()}`,
        "X-GitHub-Api-Version": "2022-11-28",
      },
      body: JSON.stringify({ title, body }),
    }
  );

  if (response.status === 201) {
    return response.json();
  }

  const error: GitHubError = await response.json();

  switch (response.status) {
    case 401:
      // 토큰 갱신 후 재시도
      await tokenManager.refreshToken();
      throw new AppError("GITHUB_AUTH_EXPIRED", "GitHub 인증 만료");

    case 403:
    case 429:
      // Rate Limit 처리
      await handleRateLimit(response);
      throw new AppError("GITHUB_RATE_LIMIT", "GitHub Rate Limit 초과");

    case 404:
      throw new AppError(
        "GITHUB_REPO_NOT_FOUND",
        `레포지토리를 찾을 수 없음: ${owner}/${repo} (권한 부족 가능)`
      );

    case 422:
      const fieldErrors = error.errors
        ?.map((e) => `${e.field}: ${e.code}`)
        .join(", ");
      throw new AppError(
        "GITHUB_VALIDATION_ERROR",
        `유효성 검증 실패: ${fieldErrors}`
      );

    default:
      throw new AppError(
        "GITHUB_UNKNOWN_ERROR",
        `GitHub API 에러: ${response.status} - ${error.message}`
      );
  }
}
```

---

## 6. Octokit (공식 GitHub SDK for Node.js)

### 6.1 패키지 비교

| 패키지 | 크기 | 특징 | 사용 사례 |
|--------|------|------|----------|
| `@octokit/core` | 최소 | `octokit.request()` 저수준 API | 최소 번들, 세밀 제어 필요 시 |
| `@octokit/rest` | 중간 | `octokit.rest.issues.create()` 고수준 메서드 | REST API 전용, 타입 지원 |
| `octokit` | 전체 | REST + GraphQL + App Auth + Webhook | 풀스택 GitHub 통합 |

**서버 사이드 이슈 생성 권장: `octokit` (전체 SDK)**
- GitHub App 인증이 내장
- 토큰 자동 갱신
- Throttling/Retry 플러그인 지원

### 6.2 설치

```bash
pnpm add octokit @octokit/auth-app @octokit/plugin-throttling @octokit/plugin-retry
```

### 6.3 GitHub App 인증으로 이슈 생성

```typescript
import { Octokit } from "@octokit/rest";
import { createAppAuth } from "@octokit/auth-app";
import { throttling } from "@octokit/plugin-throttling";
import { retry } from "@octokit/plugin-retry";

// 1. 플러그인 적용
const MyOctokit = Octokit.plugin(throttling, retry);

// 2. GitHub App 인증으로 인스턴스 생성
const octokit = new MyOctokit({
  authStrategy: createAppAuth,
  auth: {
    appId: process.env.GITHUB_APP_ID,
    privateKey: process.env.GITHUB_APP_PRIVATE_KEY,
    installationId: process.env.GITHUB_INSTALLATION_ID,
  },
  throttle: {
    onRateLimit: (retryAfter, options, octokit, retryCount) => {
      octokit.log.warn(
        `Rate limit hit: ${options.method} ${options.url}`
      );
      if (retryCount < 2) {
        octokit.log.info(`Retrying after ${retryAfter}s`);
        return true; // 재시도
      }
      return false; // 포기
    },
    onSecondaryRateLimit: (retryAfter, options, octokit) => {
      octokit.log.warn(
        `Secondary rate limit: ${options.method} ${options.url}`
      );
      // 콘텐츠 생성은 secondary rate limit에 민감하므로 재시도
      return true;
    },
  },
  retry: {
    doNotRetry: ["429"],  // throttling 플러그인이 429를 처리
  },
});

// 3. 이슈 생성
const { data: issue } = await octokit.rest.issues.create({
  owner: "myorg",
  repo: "myrepo",
  title: "[QnA] 사용자 질문",
  body: "질문 내용...",
  labels: ["qna"],
});

console.log(`Issue created: ${issue.html_url}`);
```

### 6.4 `@octokit/auth-app`의 자동 토큰 관리

`@octokit/auth-app`을 사용하면 다음이 자동으로 처리됨:

- JWT 생성 불필요 (SDK가 내부적으로 처리)
- Installation Access Token 자동 교환
- 토큰 만료 시 자동 재발급
- 토큰 캐싱 (동일 installation의 토큰 재사용)

```typescript
// 토큰 직접 조회도 가능
const { token } = await octokit.auth({ type: "installation" });
console.log(`Current token: ${token}`);
```

### 6.5 `octokit.request()`를 사용한 저수준 호출

```typescript
const { data } = await octokit.request(
  "POST /repos/{owner}/{repo}/issues",
  {
    owner: "myorg",
    repo: "myrepo",
    title: "[QnA] 사용자 질문",
    body: "질문 내용...",
    labels: ["qna"],
  }
);
```

### 6.6 Throttling + Retry 플러그인 상세

**`@octokit/plugin-throttling` 기본 동작:**
- Primary Rate Limit: `X-RateLimit-Reset`까지 대기
- Secondary Rate Limit: `retry-after` 헤더 값만큼 대기 (없으면 기본 60초)
- `minimumSecondaryRateRetryAfter` 옵션으로 최소 대기 시간 조정 가능

**`@octokit/plugin-retry` 기본 동작:**
- 500, 502, 503 등 서버 에러에 대해 자동 재시도
- 최대 3회 재시도
- 429와 함께 사용 시 충돌 방지를 위해 `doNotRetry: ["429"]` 설정

**분산 서버 환경 (Clustering):**

```typescript
import Bottleneck from "bottleneck";

const octokit = new MyOctokit({
  auth: { /* ... */ },
  throttle: {
    Bottleneck,
    id: "my-app-github",   // 동일 ID를 공유하는 인스턴스 간 throttling 공유
    connection: new Bottleneck.RedisConnection({
      client: redisClient,
    }),
    onRateLimit: (retryAfter, options, octokit, retryCount) => {
      return retryCount < 2;
    },
    onSecondaryRateLimit: (retryAfter, options, octokit) => {
      return true;
    },
  },
});
```

---

## 7. 보안 고려사항

### 7.1 토큰/키 안전한 저장

| 방법 | 설명 | 권장 환경 |
|------|------|----------|
| 환경 변수 | `process.env`로 읽기 | 개발/스테이징 |
| Secret Manager | AWS Secrets Manager, HashiCorp Vault | 프로덕션 |
| .env 파일 | dotenv로 로컬 로드 | 로컬 개발 전용 |

**절대 하지 말아야 할 것:**
- 코드에 토큰/키 하드코딩 금지
- `.env` 파일 Git 커밋 금지
- 로그에 토큰 출력 금지
- 클라이언트 사이드에 private key 노출 금지

```typescript
// .env (Git에서 제외)
GITHUB_APP_ID=123456
GITHUB_APP_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n..."
GITHUB_INSTALLATION_ID=789012
```

```gitignore
# .gitignore
.env
*.pem
```

### 7.2 입력 새니타이제이션

사용자 생성 콘텐츠가 GitHub Issue의 title/body로 들어갈 때 주의:

```typescript
function sanitizeForGitHub(input: string): string {
  // 1. null/undefined 방어
  if (!input) return "";

  // 2. 길이 제한 (GitHub Issue title은 256자 제한)
  const truncated = input.slice(0, 256);

  // 3. 제어 문자 제거 (탭, 개행은 유지)
  const cleaned = truncated.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");

  return cleaned;
}

function sanitizeIssueBody(input: string): string {
  if (!input) return "";

  // 1. 길이 제한 (GitHub Issue body는 65536자 제한)
  const truncated = input.slice(0, 65536);

  // 2. 제어 문자 제거 (탭, 개행은 유지)
  const cleaned = truncated.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, "");

  return cleaned;
}
```

### 7.3 Markdown 주입 방지

GitHub Issue body는 Markdown으로 렌더링되므로, 사용자 입력이 의도치 않은 Markdown 구조를 만들 수 있음:

```typescript
function escapeMarkdown(text: string): string {
  // 사용자 입력을 코드 블록으로 감싸서 Markdown 해석 방지
  // 단, 전체 body가 아닌 사용자 입력 부분만 감싸야 함
  return text
    .replace(/\\/g, "\\\\")
    .replace(/`/g, "\\`")
    .replace(/\*/g, "\\*")
    .replace(/#/g, "\\#")
    .replace(/\[/g, "\\[")
    .replace(/\]/g, "\\]")
    .replace(/\(/g, "\\(")
    .replace(/\)/g, "\\)")
    .replace(/!/g, "\\!")
    .replace(/</g, "&lt;")   // HTML 태그 방지
    .replace(/>/g, "&gt;");
}

// 이슈 body 조립 시
function buildIssueBody(userQuestion: string, metadata: object): string {
  const sanitizedQuestion = escapeMarkdown(sanitizeIssueBody(userQuestion));

  return [
    "## 질문 내용",
    "",
    sanitizedQuestion,
    "",
    "---",
    "",
    "## 메타데이터",
    "",
    `- 앱: ${metadata.appCode}`,
    `- 작성 시각: ${new Date().toISOString()}`,
    "",
    "*이 이슈는 자동 생성되었습니다.*",
  ].join("\n");
}
```

### 7.4 URL 인젝션 방지

`owner`/`repo` 파라미터가 URL path에 들어가므로 Path Traversal 방지 필요:

```typescript
function validateRepoParam(param: string): string {
  // GitHub 레포 이름 규칙: 알파벳, 숫자, -, _, .만 허용
  if (!/^[a-zA-Z0-9._-]+$/.test(param)) {
    throw new AppError(
      "INVALID_REPO_PARAM",
      `유효하지 않은 레포지토리 파라미터: ${param}`
    );
  }
  return param;
}
```

### 7.5 토큰 유출 대응 계획

1. 유출 감지 시 즉시 토큰/키 폐기
2. 새 토큰/키 발급
3. 모든 서비스에 새 자격 증명 배포
4. 유출된 토큰으로 수행된 작업 감사 로그 확인
5. GitHub Secret Scanning 알림 활성화

---

## 8. 멀티 테넌트 서버 아키텍처 권장사항

### 8.1 앱 코드별 레포 매핑 구조

```typescript
// config/github-repos.ts
interface GitHubRepoConfig {
  owner: string;
  repo: string;
  labels: string[];
}

const REPO_MAP: Record<string, GitHubRepoConfig> = {
  "app-a": {
    owner: "myorg",
    repo: "app-a-issues",
    labels: ["auto-created"],
  },
  "app-b": {
    owner: "myorg",
    repo: "app-b-issues",
    labels: ["auto-created"],
  },
};
```

### 8.2 같은 조직 내 레포인 경우

하나의 GitHub App, 하나의 installation으로 충분:

```
GitHub App (1개)
  └── Installation (myorg에 설치, 1개)
        ├── app-a-issues 레포 접근
        ├── app-b-issues 레포 접근
        └── app-c-issues 레포 접근
```

### 8.3 다른 조직에 걸친 레포인 경우

조직별 installation이 필요하고, installation별 토큰 관리 필요:

```typescript
// 조직별 installation ID 매핑
const INSTALLATION_MAP: Record<string, number> = {
  "org-a": 111111,
  "org-b": 222222,
};

class MultiTenantGitHubClient {
  private octokitCache: Map<number, Octokit> = new Map();

  async getOctokit(orgName: string): Promise<Octokit> {
    const installationId = INSTALLATION_MAP[orgName];
    if (!installationId) {
      throw new Error(`Unknown org: ${orgName}`);
    }

    if (!this.octokitCache.has(installationId)) {
      const octokit = new MyOctokit({
        authStrategy: createAppAuth,
        auth: {
          appId: process.env.GITHUB_APP_ID,
          privateKey: process.env.GITHUB_APP_PRIVATE_KEY,
          installationId,
        },
        // throttle 설정 생략
      });
      this.octokitCache.set(installationId, octokit);
    }

    return this.octokitCache.get(installationId)!;
  }

  async createIssue(
    appCode: string,
    title: string,
    body: string
  ): Promise<string> {
    const config = REPO_MAP[appCode];
    if (!config) throw new Error(`Unknown app code: ${appCode}`);

    const octokit = await this.getOctokit(config.owner);
    const { data } = await octokit.rest.issues.create({
      owner: config.owner,
      repo: config.repo,
      title,
      body,
      labels: config.labels,
    });

    return data.html_url;
  }
}
```

### 8.4 큐 기반 이슈 생성 (Rate Limit 대응)

```typescript
// 이슈 생성 요청을 큐에 넣고 순차 처리
import PQueue from "p-queue";

const issueQueue = new PQueue({
  concurrency: 1,         // 동시 1건만 처리
  interval: 1000,          // 1초 간격
  intervalCap: 1,          // 간격당 1건
});

async function queueIssueCreation(
  appCode: string,
  title: string,
  body: string
): Promise<string> {
  return issueQueue.add(() =>
    gitHubClient.createIssue(appCode, title, body)
  );
}
```

---

## 9. 참고 자료

### 공식 문서
- [REST API endpoints for issues](https://docs.github.com/en/rest/issues/issues)
- [Rate limits for the REST API](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api)
- [About authentication with a GitHub App](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/about-authentication-with-a-github-app)
- [Generating a JWT for a GitHub App](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app)
- [Generating an installation access token](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app)
- [Best practices for using the REST API](https://docs.github.com/en/rest/using-the-rest-api/best-practices-for-using-the-rest-api)
- [Troubleshooting the REST API](https://docs.github.com/en/rest/using-the-rest-api/troubleshooting-the-rest-api)
- [Keeping your API credentials secure](https://docs.github.com/en/rest/authentication/keeping-your-api-credentials-secure)
- [Managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [Choosing permissions for a GitHub App](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/choosing-permissions-for-a-github-app)
- [Rate limits for GitHub Apps](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/rate-limits-for-github-apps)
- [Updated rate limits for unauthenticated requests (2025)](https://github.blog/changelog/2025-05-08-updated-rate-limits-for-unauthenticated-requests/)

### SDK / 라이브러리
- [octokit/octokit.js](https://github.com/octokit/octokit.js) - 올인원 GitHub SDK
- [octokit/rest.js](https://github.com/octokit/rest.js) - REST API 클라이언트
- [octokit/core.js](https://github.com/octokit/core.js/) - 최소 코어 클라이언트
- [octokit/auth-app.js](https://github.com/octokit/auth-app.js/) - GitHub App 인증
- [octokit/plugin-throttling.js](https://github.com/octokit/plugin-throttling.js/) - Rate Limit 자동 처리
- [@octokit/plugin-retry (npm)](https://www.npmjs.com/package/@octokit/plugin-retry) - 자동 재시도

### 커뮤니티 / 참고
- [GitHub Issues API tutorial](https://medium.com/@hi_7807/github-issues-api-tutorial-b7a12b1bcada)
- [A Developer's Guide: Managing Rate Limits for the GitHub API](https://www.lunar.dev/post/a-developers-guide-managing-rate-limits-for-the-github-api)
- [Understanding GitHub API Rate Limits (Community Discussion)](https://github.com/orgs/community/discussions/163553)
- [Hitting secondary rate limit on issues creation (Community Discussion)](https://github.com/orgs/community/discussions/50326)
- [Fine-grained vs Classic PAT](https://www.finecloud.ch/blog/github-classic-vs-fine-grained-personal-access-tokens/)
