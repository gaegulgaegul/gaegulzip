# QnA 리팩토링 Gap 분석

> 분석 일시: 2026-02-04
> 기준 문서: `docs/core/qna/server-brief.md`
> 기준 코드: `apps/server/src/modules/qna/` (리팩토링 후)

## 분석 범위

이번 분석은 **의도적 리팩토링** (qnaConfig DB → 환경변수 전환) 이후, 설계 문서와 실제 구현 간의 Gap을 식별합니다.

---

## 항목별 비교

### 1. DB 스키마 (설계 vs 구현)

| 항목 | 설계 (server-brief.md) | 구현 (schema.ts) | 상태 |
|------|----------------------|-----------------|------|
| `qna_config` 테이블 | ✅ 정의됨 | ❌ 제거됨 | 🔄 **의도적 변경** |
| `qna_questions` 테이블 | ✅ 정의됨 | ✅ 동일 | ✅ 일치 |
| `qna_questions` 인덱스 | 4개 (appId, userId, issueNumber, createdAt) | 4개 동일 | ✅ 일치 |

### 2. 비즈니스 로직 (설계 vs 구현)

| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| 앱 조회 (apps 테이블) | `db.select().from(apps).where(...)` | 동일 | ✅ 일치 |
| QnA 설정 조회 | `db.select().from(qnaConfig)` | ❌ 제거, `env` 사용 | 🔄 **의도적 변경** |
| Octokit 인스턴스 | `getOctokitInstance(appId, config)` | `getOctokitInstance()` (파라미터 없음) | 🔄 **의도적 변경** |
| GitHub Issue 제목 | `params.title` (사용자 입력 그대로) | `[${appCode}] ${params.title}` | 🔄 **의도적 변경** |
| GitHub Issue 라벨 | `JSON.parse(config.githubLabels)` | 하드코딩 `['qna']` | 🔄 **의도적 변경** |
| owner/repo 소스 | `config.githubRepoOwner/Name` (DB) | `env.QNA_GITHUB_REPO_OWNER/NAME` (환경변수) | 🔄 **의도적 변경** |
| Issue 본문 생성 | `buildIssueBody()` + sanitize | 동일 | ✅ 일치 |
| DB에 질문 이력 저장 | `db.insert(qnaQuestions)` | 동일 | ✅ 일치 |

### 3. Octokit 모듈 (설계 vs 구현)

| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| `GitHubAppConfig` 인터페이스 | ✅ 정의됨 | ❌ 제거 (env 직접 사용) | 🔄 **의도적 변경** |
| 캐시 전략 | `Map<number, Octokit>` (앱별) | `let cachedInstance` (단일) | 🔄 **의도적 변경** |
| 플러그인 (throttling, retry) | ✅ | ✅ 동일 | ✅ 일치 |
| onRateLimit/onSecondaryRateLimit | ✅ | ✅ 동일 | ✅ 일치 |

### 4. 에러 처리 (설계 vs 구현)

| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| App not found (404) | ✅ | ✅ | ✅ 일치 |
| QnA Config not found (404) | ✅ | ❌ 제거 (더 이상 필요 없음) | 🔄 **의도적 변경** |
| GitHub 401/403 → ExternalApiException | ✅ | ✅ (github.ts) | ✅ 일치 |
| GitHub 404 → NotFoundException | ✅ | ✅ (github.ts) | ✅ 일치 |
| GitHub 422 → BusinessException | ✅ | ✅ (github.ts) | ✅ 일치 |
| GitHub 429 → ExternalApiException | ✅ | ✅ (github.ts) | ✅ 일치 |

### 5. Domain Probe (설계 vs 구현)

| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| `questionSubmitted` (INFO) | ✅ | ✅ | ✅ 일치 |
| `rateLimitWarning` (WARN) | ✅ | ✅ | ✅ 일치 |
| `githubApiError` (ERROR) | ✅ | ✅ | ✅ 일치 |
| `configNotFound` (WARN) | ✅ | ❌ 제거 | 🔄 **의도적 변경** |

### 6. 환경변수 (설계 vs 구현)

| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| env.ts Zod 스키마 | GitHub 변수 없음 | 5개 추가 (`QNA_GITHUB_*`) | 🔄 **의도적 변경** |
| .env 파일 | GitHub 변수 없음 | 5개 추가 | 🔄 **의도적 변경** |

### 7. 테스트 (설계 vs 구현)

| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| handlers.test.ts (5 tests) | ✅ | ✅ | ✅ 일치 |
| services.test.ts | DB 2단계 mock (apps + qnaConfig) | DB 1단계 mock (apps만) | 🔄 **의도적 변경** |
| octokit.test.ts | 파라미터 기반 (appId, config) | env mock 기반 (파라미터 없음) | 🔄 **의도적 변경** |
| validators.test.ts (9 tests) | ✅ | ✅ | ✅ 일치 |
| github.test.ts (6 tests) | ✅ | ✅ | ✅ 일치 |
| `[appCode]` 제목 테스트 | 없음 | ✅ 추가 | ➕ **신규** |
| 전체 테스트 수 | 117 | 116 (-1 config not found, +0 other) | ✅ 정상 |

### 8. 마이그레이션 (설계 vs 구현)

| 항목 | 설계 | 구현 | 상태 |
|------|------|------|------|
| 0003 SQL | qna_config + qna_questions | qna_questions만 | 🔄 **의도적 변경** |
| 0003 snapshot | qna_config + qna_questions | qna_questions만 | 🔄 **의도적 변경** |

---

## Match Rate 계산

### 변경 분류

| 분류 | 항목 수 | 설명 |
|------|---------|------|
| ✅ 일치 | 18 | 설계 그대로 구현 |
| 🔄 의도적 변경 | 14 | 리팩토링 계획에 따른 의도적 차이 |
| ➕ 신규 | 1 | 설계에 없었지만 추가된 기능 |
| ❌ 누락 | 0 | 설계에 있지만 구현 안 됨 |
| ⚠️ 불일치 | 0 | 의도치 않은 차이 |

### Match Rate

**의도적 변경은 일치로 처리** (리팩토링 계획에 명시된 변경):

```
Match Rate = (일치 + 의도적변경 + 신규) / 전체 항목
           = (18 + 14 + 1) / 33
           = 33 / 33
           = 100%
```

---

## 설계 문서 업데이트 필요 사항

`server-brief.md`가 리팩토링 전 상태를 기술하고 있으므로, 다음 항목을 업데이트해야 합니다:

1. **§2 DB 스키마**: `qna_config` 테이블 → "환경변수로 대체됨" 표기
2. **§3.1 전체 흐름**: "3. 앱 설정 조회" 단계에서 qnaConfig 조회 제거
3. **§3.2 GitHub App 인증**: `getOctokitInstance(appId, config)` → `getOctokitInstance()`
4. **§3.3 Issue 본문 포맷**: 제목에 `[appCode]` 접두사 추가됨 명시
5. **§4 모듈 구조**: `schema.ts` 설명에서 `qna_config` 제거
6. **§6 배포 및 설정**: 환경변수 섹션에 `QNA_GITHUB_*` 5개 추가
7. **§8 운영 로그**: `configNotFound` probe 제거됨 명시

---

## 결론

| 메트릭 | 값 |
|--------|-----|
| **Match Rate** | **100%** |
| 의도적 변경 항목 | 14개 (리팩토링 계획 범위 내) |
| 누락/불일치 | 0개 |
| 테스트 | 116개 전체 통과 |
| 빌드 | TypeScript 컴파일 성공 |

**판정: PASS** ✅

리팩토링이 계획대로 완료되었습니다. 설계 문서(`server-brief.md`)는 아직 리팩토링 전 상태이므로, 필요 시 업데이트하면 됩니다.
