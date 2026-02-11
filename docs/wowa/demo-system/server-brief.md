# Server Brief: demo-system 로깅 강화

## 변경 대상

| 파일 | 변경 유형 |
|------|----------|
| `src/modules/qna/services.ts` | debug 로그 추가 (각 단계별) |
| `src/modules/qna/github.ts` | logger.error → probe 전환, 성공 debug 로그 |
| `src/modules/qna/qna.probe.ts` | configNotFound probe 추가 |
| `src/modules/notice/handlers.ts` | resolveAppCode debug 로그 추가 |

## 변경 상세

### 1. QnA services.ts — 단계별 debug 로그 추가

현재: handler에만 debug 로그 1개, services.ts에는 DB 저장 실패 error만 있음.

**추가할 로그:**

```
createQuestion() 진입 시:
  logger.debug({ appCode, userId }, 'Creating question: starting')

앱 조회 성공 후:
  logger.debug({ appId: app.id, appCode }, 'Creating question: app found')

앱 조회 실패 시 (NotFoundException throw 전):
  — probe 아닌 debug/warn 로그 불필요 (NotFoundException은 전역 에러 핸들러가 처리)

GitHub Issue 생성 시작 전:
  logger.debug({ owner, repo, appCode }, 'Creating question: creating GitHub issue')

GitHub Issue 생성 성공 후:
  logger.debug({ issueNumber, issueUrl }, 'Creating question: GitHub issue created')

DB 저장 시작 전:
  logger.debug({ appId: app.id, issueNumber }, 'Creating question: saving to DB')
```

### 2. QnA github.ts — probe 패턴 전환

현재: `logger.error(...)` 직접 호출 (probe 패턴 미준수).

**변경:**
- 기존 `logger.error({ status, message, ... }, 'GitHub API error')` → `qnaProbe.githubApiError(...)` 호출로 대체
- probe 호출 시 appCode 정보를 전달해야 하므로, `createGitHubIssue` 파라미터에 **appCode 추가 불필요** — probe에서 owner/repo 정보만으로 충분하므로 probe 시그니처를 수정

**qna.probe.ts 수정:**
```typescript
// githubApiError 시그니처 변경 (appCode → owner/repo 기반)
export const githubApiError = (data: {
  owner: string;
  repo: string;
  error: string;
  statusCode: number;
}) => { ... }
```

- rate limit (429) 시 `qnaProbe.rateLimitWarning()` 호출 추가
- `rateLimitWarning` 시그니처도 수정 (appCode 대신 owner/repo)

### 3. QnA qna.probe.ts — configNotFound 추가

현재: `NotFoundException('App', appCode)` 발생 시 probe 호출 없음.

**추가:**
```typescript
export const configNotFound = (data: {
  appCode: string;
  resource: string;
}) => {
  logger.warn({ ... }, 'QnA config not found');
};
```

services.ts에서 앱 조회 실패 시 호출:
```typescript
if (!app) {
  qnaProbe.configNotFound({ appCode: params.appCode, resource: 'App' });
  throw new NotFoundException('App', params.appCode);
}
```

### 4. Notice handlers.ts — resolveAppCode 로그

현재: resolveAppCode 내부에 로그 없음.

**추가:**
```
resolveAppCode() 내:
  JWT 경로:  logger.debug({ appId }, 'Resolving appCode from JWT')
  query 경로: logger.debug({ appCode }, 'Using appCode from query param')
```

## 변경하지 않을 것

- Notice probe는 이미 충분 — 추가 불필요
- Notice handlers의 기존 debug 로그 — 이미 모든 엔드포인트에 있음
- QnA handlers.ts — 이미 적절한 debug + probe 호출 있음
- 전역 에러 핸들러 — 이미 잘 동작함

## 테스트 영향

- 로깅 추가만이므로 기존 테스트 동작 변경 없음
- probe mock 테스트가 있다면 새 probe 함수(configNotFound) 테스트 추가 필요
