# Server 작업 계획: 박스 관리 기능 개선 (wowa-box)

## 개요

박스 검색 API를 통합 키워드 방식으로 변경하고, 박스 생성 시 트랜잭션으로 데이터 정합성을 보장합니다. 1명의 Node Developer가 단독으로 작업하며, Mobile 팀과 병렬로 진행합니다.

## 실행 그룹

### Group 1 (병렬) — Server 단독 작업

| Agent | Module | 설명 | 파일 경로 |
|-------|--------|------|----------|
| node-developer | box-search | 통합 키워드 검색 API 구현 | `apps/server/src/modules/box/` |
| node-developer | box-create | 박스 생성 트랜잭션 처리 | `apps/server/src/modules/box/` |

**병렬 진행**: Mobile View 레이아웃 (Group 1)과 동시 실행 가능

---

## 작업 범위

### Task 1: 통합 키워드 검색 API 구현

**담당**: node-developer
**우선순위**: 높음 (Mobile API 클라이언트 의존)

#### 수정 파일
1. **`apps/server/src/modules/box/validators.ts`**
   - `searchBoxQuerySchema` 변경: `name`, `region` → `keyword` 통합
   - 유효성 검증: `keyword` 최대 255자

2. **`apps/server/src/modules/box/services.ts`**
   - `searchBoxes(keyword: string)` 함수 수정
   - ILIKE 쿼리: `name ILIKE %keyword% OR region ILIKE %keyword%`
   - 빈 키워드 처리: 빈 배열 반환
   - memberCount 집계 (LEFT JOIN + COUNT)

3. **`apps/server/src/modules/box/handlers.ts`**
   - `search` 핸들러 수정
   - 쿼리 파라미터: `keyword` 사용
   - 로깅: `boxProbe.searchExecuted({ keyword, resultCount })`

4. **`apps/server/src/modules/box/box.probe.ts`**
   - 새 Probe 함수 추가:
     ```typescript
     export const searchExecuted = (data: { keyword: string; resultCount: number }) => {
       logger.debug({ keyword: data.keyword, resultCount: data.resultCount }, 'Box search executed');
     };
     ```

#### 단위 테스트
**파일**: `apps/server/tests/unit/box/services.test.ts`

**테스트 시나리오**:
- [x] 빈 키워드 입력 시 빈 배열 반환
- [x] 박스 이름으로 검색 성공 (ILIKE)
- [x] 박스 지역으로 검색 성공 (ILIKE)
- [x] 대소문자 무시 검색
- [x] memberCount 집계 정확성
- [x] 공백 키워드 처리 (trim)

**커버리지 목표**: 80% 이상

---

### Task 2: 박스 생성 트랜잭션 처리

**담당**: node-developer
**우선순위**: 높음

#### 수정 파일
1. **`apps/server/src/modules/box/services.ts`**
   - 새 함수 추가: `createBoxWithMembership(data: CreateBoxInput)`
   - Drizzle ORM 트랜잭션 사용:
     ```typescript
     return await db.transaction(async (tx) => {
       // 1. 박스 생성
       // 2. 기존 박스 멤버십 확인 및 삭제 (단일 박스 정책)
       // 3. 생성자를 새 박스 멤버로 등록
       // 4. 로깅 (boxSwitched 또는 created + memberJoined)
     });
     ```

2. **`apps/server/src/modules/box/handlers.ts`**
   - `create` 핸들러 수정
   - `createBoxWithMembership` 호출
   - 에러 핸들링: try-catch, `boxProbe.creationFailed`

3. **`apps/server/src/modules/box/validators.ts`**
   - `createBoxSchema` 강화:
     - `name`: min(2), max(255), trim()
     - `region`: min(2), max(255), trim()
     - `description`: max(1000), trim(), optional()

4. **`apps/server/src/modules/box/box.probe.ts`**
   - 새 Probe 함수 추가:
     ```typescript
     export const creationFailed = (data: { userId: number; name: string; error: string }) => {
       logger.error({ userId: data.userId, name: data.name, error: data.error }, 'Box creation failed');
     };

     export const transactionRolledBack = (data: { userId: number; reason: string }) => {
       logger.warn({ userId: data.userId, reason: data.reason }, 'Box creation transaction rolled back');
     };
     ```

5. **`apps/server/src/modules/box/types.ts`**
   - 새 타입 추가:
     ```typescript
     export interface CreateBoxResponse {
       box: Box;
       membership: BoxMember;
       previousBoxId: number | null;
     }
     ```

#### 단위 테스트
**파일**: `apps/server/tests/unit/box/services.test.ts`

**테스트 시나리오**:
- [x] 박스 생성 + 멤버 등록 트랜잭션 성공
- [x] 기존 박스 멤버십 자동 탈퇴 (단일 박스 정책)
- [x] `previousBoxId` 반환 정확성
- [x] 트랜잭션 실패 시 전체 롤백 (박스 생성 취소)
- [x] 멤버 등록 실패 시 박스 생성 롤백
- [x] 유효성 검증 실패 (name < 2자)
- [x] 동시성 테스트 (선택 사항)

**커버리지 목표**: 80% 이상

---

## DB 스키마 변경 (선택 사항)

### 옵션 A: 유니크 제약 추가 (권장)

**마이그레이션 스크립트**: `apps/server/src/modules/box/migrations/add_unique_user_constraint.sql`

```sql
-- 사전 작업: 중복 멤버십 정리 (가장 최근 가입만 남기기)
DELETE FROM box_members
WHERE id NOT IN (
  SELECT DISTINCT ON (user_id) id
  FROM box_members
  ORDER BY user_id, joined_at DESC
);

-- 유니크 제약 추가
ALTER TABLE box_members
ADD CONSTRAINT unique_user_single_box UNIQUE (user_id);
```

**실행 시점**: 코드 배포 전

**장점**:
- DB 레벨에서 단일 박스 정책 강제
- 동시성 문제 완전 해결

**단점**:
- 마이그레이션 필요 (운영 DB 영향)
- 기존 데이터 정합성 확인 필요

### 옵션 B: 스키마 변경 없음

**장점**:
- 마이그레이션 불필요
- 유연성 (향후 다중 박스 지원 가능)

**단점**:
- 애플리케이션 레벨 처리 (복잡도 증가)
- Advisory Lock 필요 (PostgreSQL 전용)

**최종 권장**: **옵션 A** (유니크 제약 추가)

---

## API 명세 (Mobile 팀 전달)

### 1. 박스 검색 (변경)

**엔드포인트**: `GET /boxes/search?keyword={keyword}`

**변경 사항**:
- 쿼리 파라미터: `name`, `region` → `keyword` 통합

**요청 예시**:
```bash
GET /boxes/search?keyword=강남 크로스핏
```

**응답 예시** (200 OK):
```json
{
  "boxes": [
    {
      "id": 1,
      "name": "CrossFit Seoul",
      "region": "서울 강남구",
      "description": "강남 최고의 크로스핏 박스",
      "memberCount": 42
    },
    {
      "id": 2,
      "name": "강남 크로스핏",
      "region": "서울 서초구",
      "description": null,
      "memberCount": 15
    }
  ]
}
```

### 2. 박스 생성 (응답 변경)

**엔드포인트**: `POST /boxes`

**변경 사항**:
- 응답에 `previousBoxId` 필드 추가
- 트랜잭션으로 처리 (박스 + 멤버십)

**요청 예시**:
```json
{
  "name": "CrossFit Gangnam",
  "region": "서울 강남구",
  "description": "최고의 크로스핏 박스"
}
```

**응답 예시** (201 Created):
```json
{
  "box": {
    "id": 5,
    "name": "CrossFit Gangnam",
    "region": "서울 강남구",
    "description": "최고의 크로스핏 박스",
    "createdBy": 123,
    "createdAt": "2026-02-09T10:30:00Z",
    "updatedAt": "2026-02-09T10:30:00Z"
  },
  "membership": {
    "id": 10,
    "boxId": 5,
    "userId": 123,
    "role": "member",
    "joinedAt": "2026-02-09T10:30:00Z"
  },
  "previousBoxId": 3
}
```

---

## 파일 구조

```
apps/server/src/modules/box/
├── handlers.ts           # 수정: search, create 핸들러
├── services.ts           # 수정: searchBoxes, 추가: createBoxWithMembership
├── validators.ts         # 수정: searchBoxQuerySchema, createBoxSchema
├── types.ts              # 추가: CreateBoxResponse
├── box.probe.ts          # 추가: searchExecuted, creationFailed, transactionRolledBack
└── schema.ts             # 변경 없음

apps/server/tests/unit/box/
└── services.test.ts      # 추가: 검색 테스트, 트랜잭션 테스트
```

---

## 의존성

### 패키지
- `drizzle-orm`: 트랜잭션 사용
- `zod`: 유효성 검증
- 추가 패키지 불필요

### 기존 코드
- `apps/server/src/config/database.ts`: `db` 인스턴스
- `apps/server/src/modules/box/schema.ts`: `boxes`, `boxMembers` 테이블
- `.claude/guide/server/`: API 설계, 에러 처리, 로깅 가이드

---

## 검증 기준

- [ ] 통합 키워드 검색이 박스 이름과 지역에서 모두 동작
- [ ] 박스 생성과 멤버 등록이 단일 트랜잭션으로 처리
- [ ] 트랜잭션 실패 시 전체 롤백 확인
- [ ] 단일 박스 정책이 동시성 환경에서도 보장
- [ ] 기존 박스 탈퇴 시 `previousBoxId` 반환
- [ ] 입력 유효성 검증 강화 (min 길이, trim)
- [ ] 단위 테스트 커버리지 80% 이상
- [ ] 로깅이 적절히 추가 (DEBUG, INFO, ERROR)
- [ ] Express 미들웨어 패턴 준수 (Controller/Service 패턴 사용 안 함)
- [ ] JSDoc 주석 (한국어)

---

## 실행 명령어

### 테스트 실행
```bash
cd /Users/lms/dev/repository/feature-wowa-box
pnpm test apps/server
```

### 빌드 확인
```bash
pnpm build --filter=@gaegulzip/server
```

### 마이그레이션 (옵션 A 선택 시)
```bash
# Supabase MCP로 실행 (읽기 전용이므로 사용자가 직접 실행)
```

---

## 참고 자료

- **Server Brief**: `/Users/lms/dev/repository/feature-wowa-box/docs/wowa/wowa-box/server-brief.md`
- **Server CLAUDE.md**: `/Users/lms/dev/repository/feature-wowa-box/apps/server/CLAUDE.md`
- **API Response 설계**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/server/api-response-design.md`
- **예외 처리 가이드**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/server/exception-handling.md`
- **로깅 베스트 프랙티스**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/server/logging-best-practices.md`
- **Drizzle Transactions**: https://orm.drizzle.team/docs/transactions
