# WOWA MVP Server Work Plan

> Feature: wowa-mvp
> Created: 2026-02-04
> Platform: Server (Node.js/Express)
> TDD Cycle: Red → Green → Refactor
> Test Command: `cd apps/server && pnpm test`

---

## 개요

이 문서는 Node Developer를 위한 WOWA MVP 서버 구현 작업 계획서입니다. Kent Beck TDD 원칙을 엄격히 준수하여 **테스트 먼저 작성 → 최소 구현 → 리팩터링** 순서로 진행합니다.

**핵심 원칙**:
1. 실패하는 테스트 먼저 작성 (Red)
2. 테스트를 통과하는 최소한의 코드 구현 (Green)
3. 테스트 통과 후에만 리팩터링 (Refactor)
4. 모든 테스트는 `- [ ]` 체크리스트로 관리
5. 구조 변경(Structural)과 기능 변경(Behavioral)은 분리

**기존 코드 상태**:
- Box 모듈 부분 구현 완료 (`region` 필드 누락)
- WOD 모듈 미구현
- 일부 테스트 FAIL 상태 (단일 박스 정책 미반영)

---

## Phase 0: 기존 코드 구조 변경 (Structural)

**목적**: 설계와 기존 코드의 차이점 해결 (region 필드 추가, 단일 박스 정책)

### 0.1 Box Schema — region 필드 추가

**파일**: `apps/server/src/modules/box/schema.ts`

- [ ] boxes 테이블에 region 컬럼 추가 (varchar 255, notNull)
- [ ] region 컬럼 인덱스 추가 (idx_boxes_region)
- [ ] name 컬럼 인덱스 추가 (idx_boxes_name) — 검색 최적화

**마이그레이션**:
```bash
cd apps/server
pnpm drizzle-kit generate
# 생성된 migration 파일 확인 후 적용
pnpm drizzle-kit push
```

### 0.2 Box Types — region 필드 추가

**파일**: `apps/server/src/modules/box/types.ts`

- [ ] Box 인터페이스에 region: string 추가
- [ ] CreateBoxInput에 region: string 추가
- [ ] SearchBoxInput 타입 추가 (name?: string, region?: string)
- [ ] BoxWithMemberCount 타입 추가 (검색 결과용)
- [ ] MyBoxResult 타입 추가 (GET /boxes/me 응답용)

### 0.3 기존 테스트 수정 — Mock 데이터에 region 추가

**파일**: `apps/server/tests/unit/box/services.test.ts`

- [ ] createBox 테스트의 mockBox에 region 필드 추가
- [ ] joinBox 테스트의 mockBox에 region 필드 추가
- [ ] getBoxById 테스트의 mockBox에 region 필드 추가

**실행**: `pnpm test` — 모든 테스트 통과 확인 후 다음 단계 진행

---

## Phase 1: Box Module (핵심 CRUD + 단일 박스 정책)

### 1.1 Box Services — 구조 변경 후 단위 테스트

**파일**: `apps/server/tests/unit/box/services.test.ts`

#### createBox 테스트 (이미 구현됨, region 추가만 필요)

- [x] should create box with valid data (기존 통과 → region 추가하여 재확인)

#### joinBox 테스트 (단일 박스 정책 추가 필요)

- [x] should join box with valid boxId (기존 통과)
- [x] should throw NotFoundException for non-existent box (기존 통과)
- [ ] should auto-leave previous box when joining new box (단일 박스 정책)
- [ ] should return existing membership when joining same box (멱등성)

**새 테스트 설명**:
- **자동 탈퇴**: userId가 다른 박스에 이미 가입되어 있으면 기존 멤버십 삭제 후 새 박스 가입
- **멱등성**: 이미 같은 박스에 가입되어 있으면 기존 멤버십 그대로 반환

#### getBoxById 테스트 (이미 구현됨)

- [x] should return box details by id (기존 통과)
- [x] should throw NotFoundException for non-existent id (기존 통과)

#### 새 서비스: searchBoxes 테스트

**파일**: `apps/server/tests/unit/box/services.test.ts`

- [ ] should search boxes by name (ILIKE 부분 일치)
- [ ] should search boxes by region (ILIKE 부분 일치)
- [ ] should search boxes by name and region (AND 조건)
- [ ] should return empty array when no match
- [ ] should include memberCount in search results
- [ ] should return empty array when no query params (전체 목록 제공 안 함)

#### 새 서비스: getCurrentBox 테스트

**파일**: `apps/server/tests/unit/box/services.test.ts`

- [ ] should return current box when user has membership
- [ ] should return null when user has no membership
- [ ] should include memberCount in response
- [ ] should include joinedAt timestamp

#### 새 서비스: getBoxMembers 테스트

**파일**: `apps/server/tests/unit/box/services.test.ts`

- [ ] should list all members of a box
- [ ] should include joinedAt timestamp
- [ ] should return empty array for box with no members

### 1.2 Box Services 구현

**파일**: `apps/server/src/modules/box/services.ts`

- [ ] createBox 구현 (region 추가)
- [ ] joinBox 구현 (단일 박스 정책: 기존 멤버십 자동 삭제)
- [ ] getBoxById 구현 (이미 완료)
- [ ] searchBoxes 구현 (name/region ILIKE 검색)
- [ ] getCurrentBox 구현 (userId로 현재 박스 조회)
- [ ] getBoxMembers 구현 (boxId로 멤버 목록 조회)

**실행**: `pnpm test` — 모든 Box services 테스트 통과 확인

### 1.3 Box Handlers 단위 테스트

**파일**: `apps/server/tests/unit/box/handlers.test.ts`

#### GET /boxes/me

- [ ] should return current box when user has membership
- [ ] should return null when user has no membership
- [ ] should require authentication

#### GET /boxes/search

- [ ] should search boxes by name query param
- [ ] should search boxes by region query param
- [ ] should search boxes by name and region
- [ ] should return empty array when no query params
- [ ] should require authentication

#### POST /boxes

- [ ] should create box with name, region, and description
- [ ] should throw ValidationException for missing name
- [ ] should throw ValidationException for missing region
- [ ] should auto-join creator after box creation
- [ ] should auto-leave previous box when creating new box
- [ ] should require authentication

#### POST /boxes/:boxId/join

- [ ] should join box with valid boxId
- [ ] should throw NotFoundException for non-existent box
- [ ] should auto-leave previous box when joining new box
- [ ] should return existing membership when joining same box
- [ ] should require authentication

#### GET /boxes/:boxId

- [ ] should return box details by id
- [ ] should throw NotFoundException for non-existent id
- [ ] should require authentication

#### GET /boxes/:boxId/members

- [ ] should list all members of a box
- [ ] should include user details (nickname, profileImage)
- [ ] should include totalCount in response
- [ ] should require authentication

### 1.4 Box Handlers 구현

**파일**: `apps/server/src/modules/box/handlers.ts`

- [ ] getMyBox 구현 (GET /boxes/me)
- [ ] searchBoxes 구현 (GET /boxes/search)
- [ ] createBox 구현 (POST /boxes, 자동 가입)
- [ ] joinBox 구현 (POST /boxes/:boxId/join, 자동 탈퇴)
- [ ] getBoxById 구현 (GET /boxes/:boxId)
- [ ] getBoxMembers 구현 (GET /boxes/:boxId/members)

**실행**: `pnpm test` — 모든 Box handlers 테스트 통과 확인

### 1.5 Box Validators (Zod)

**파일**: `apps/server/src/modules/box/validators.ts`

- [ ] createBoxSchema 정의 (name, region required, description optional)
- [ ] searchBoxQuerySchema 정의 (name, region optional)
- [ ] joinBoxParamsSchema 정의 (boxId number)

### 1.6 Box Router 통합

**파일**: `apps/server/src/modules/box/index.ts`

- [ ] Router 생성 및 모든 핸들러 등록
- [ ] 인증 미들웨어 적용 (authenticate)
- [ ] Zod validation 미들웨어 적용

**실행**: `pnpm test` — 전체 Box 모듈 테스트 통과 확인

---

## Phase 2: WOD Module — 기본 구조

### 2.1 WOD Schema 정의

**파일**: `apps/server/src/modules/wod/schema.ts`

- [ ] wods 테이블 정의 (id, boxId, date, programData, rawText, isBase, createdBy)
- [ ] Partial UNIQUE index 정의 (boxId + date + isBase=true)
- [ ] 인덱스 추가 (boxId + date 복합, createdBy)

**마이그레이션**:
```bash
pnpm drizzle-kit generate
pnpm drizzle-kit push
```

### 2.2 WOD Types 정의

**파일**: `apps/server/src/modules/wod/types.ts`

- [ ] WodType enum 정의 (AMRAP, ForTime, EMOM, Strength, Custom)
- [ ] WeightUnit enum 정의 (kg, lb, bw)
- [ ] Movement 인터페이스 정의
- [ ] ProgramData 인터페이스 정의
- [ ] Wod 인터페이스 정의
- [ ] ComparisonResult enum 정의 (identical, similar, different)

### 2.3 WOD Validators (Zod)

**파일**: `apps/server/src/modules/wod/validators.ts`

- [ ] movementSchema 정의
- [ ] programDataSchema 정의
- [ ] registerWodSchema 정의
- [ ] Zod 테스트 작성 (유효한 데이터 통과, 잘못된 데이터 거부)

### 2.4 WOD Services — Base WOD 자동 지정 테스트

**파일**: `apps/server/tests/unit/wod/services.test.ts`

#### registerWod 테스트

- [ ] should create Base WOD when first for date/box (isBase=true)
- [ ] should auto-set isBase=true for first WOD
- [ ] should validate programData structure with Zod
- [ ] should store rawText as-is
- [ ] should throw ValidationException for invalid programData

#### getWodsByDate 테스트

- [ ] should return Base WOD for given date/box
- [ ] should return empty personalWods array when none exist
- [ ] should return null baseWod when none exist

### 2.5 WOD Services 구현

**파일**: `apps/server/src/modules/wod/services.ts`

- [ ] registerWod 구현 (Base 자동 지정 로직)
- [ ] getWodsByDate 구현 (Base + Personal WODs 반환)

**실행**: `pnpm test` — WOD services 테스트 통과 확인

### 2.6 WOD Handlers 단위 테스트

**파일**: `apps/server/tests/unit/wod/handlers.test.ts`

#### POST /wods

- [ ] should register WOD with valid data
- [ ] should auto-set isBase=true for first WOD
- [ ] should throw ValidationException for invalid programData
- [ ] should require authentication

#### GET /wods/:boxId/:date

- [ ] should return Base and Personal WODs for date
- [ ] should return empty arrays when no WODs
- [ ] should require authentication

### 2.7 WOD Handlers 구현

**파일**: `apps/server/src/modules/wod/handlers.ts`

- [ ] registerWod 구현 (POST /wods)
- [ ] getWodsByDate 구현 (GET /wods/:boxId/:date)

**실행**: `pnpm test` — WOD handlers 테스트 통과 확인

---

## Phase 3: WOD Comparison & Proposals

### 3.1 Exercise Normalization

**파일**: `apps/server/src/modules/wod/normalization.ts`

- [ ] EXERCISE_SYNONYMS 매핑 테이블 정의 (100개 주요 동작)
- [ ] normalizeExerciseName 함수 구현

**테스트 파일**: `apps/server/tests/unit/wod/normalization.test.ts`

- [ ] should normalize 'pullup' to 'pull-up'
- [ ] should normalize 'c&j' to 'clean-and-jerk'
- [ ] should normalize 'box jump' to 'box-jump'
- [ ] should return lowercase and trimmed name
- [ ] should handle unknown exercises

### 3.2 WOD Comparison Logic

**파일**: `apps/server/src/modules/wod/comparison.ts`

- [ ] compareWods 함수 구현 (구조적 비교)

**테스트 파일**: `apps/server/tests/unit/wod/comparison.test.ts`

- [ ] should return 'identical' for same structure
- [ ] should return 'different' for different type
- [ ] should return 'different' for different movements count
- [ ] should return 'different' for >10% timeCap difference
- [ ] should return 'similar' for >10% reps difference
- [ ] should return 'similar' for >5% weight difference
- [ ] should normalize exercise names before comparison

**실행**: `pnpm test` — comparison 테스트 통과 확인

### 3.3 Proposal Schema 정의

**파일**: `apps/server/src/modules/wod/schema.ts`

- [ ] proposedChanges 테이블 정의 (id, baseWodId, proposedWodId, status, proposedAt, resolvedAt, resolvedBy)
- [ ] 인덱스 추가 (baseWodId, proposedWodId, status)

**마이그레이션**:
```bash
pnpm drizzle-kit generate
pnpm drizzle-kit push
```

### 3.4 Proposal Types 정의

**파일**: `apps/server/src/modules/wod/types.ts`

- [ ] ProposalStatus enum 정의 (pending, approved, rejected)
- [ ] ProposedChange 인터페이스 정의

### 3.5 Proposal Services 테스트

**파일**: `apps/server/tests/unit/wod/services.test.ts`

#### createProposal 테스트

- [ ] should create proposal when Personal WOD differs from Base
- [ ] should set status to 'pending' by default
- [ ] should not create proposal for 'identical' WODs
- [ ] should associate proposal with Base and Personal WOD

#### approveProposal 테스트

- [ ] should swap Base and Personal WOD on approval
- [ ] should set old Base isBase=false
- [ ] should set new Base isBase=true
- [ ] should update proposal status to 'approved'
- [ ] should throw ProposalNotFoundException for invalid id
- [ ] should throw UnauthorizedApprovalException for non-creator

### 3.6 Proposal Services 구현

**파일**: `apps/server/src/modules/wod/services.ts`

- [ ] createProposal 구현 (변경 제안 생성)
- [ ] approveProposal 구현 (Base 교체 트랜잭션)
- [ ] rejectProposal 구현 (제안 거부)

**실행**: `pnpm test` — proposal 테스트 통과 확인

### 3.7 registerWod 업데이트 — Personal WOD 처리

**파일**: `apps/server/src/modules/wod/services.ts`

- [ ] Base WOD 존재 시 Personal WOD로 등록
- [ ] 구조적 비교 수행 (compareWods)
- [ ] 'different' 결과 시 자동 제안 생성 (createProposal)
- [ ] comparisonResult 반환

**테스트 추가**: `apps/server/tests/unit/wod/services.test.ts`

- [ ] should create Personal WOD when Base exists
- [ ] should set isBase=false for Personal WOD
- [ ] should auto-create proposal when Personal differs from Base
- [ ] should not create proposal when Personal is identical to Base

**실행**: `pnpm test` — 업데이트된 registerWod 테스트 통과 확인

### 3.8 Proposal Handlers 단위 테스트

**파일**: `apps/server/tests/unit/wod/handlers.test.ts`

#### POST /wods/proposals

- [ ] should create proposal with valid data
- [ ] should require authentication

#### POST /wods/proposals/:proposalId/approve

- [ ] should approve proposal when Base creator
- [ ] should throw UnauthorizedApprovalException for non-creator
- [ ] should throw ProposalNotFoundException for invalid id
- [ ] should require authentication

#### POST /wods/proposals/:proposalId/reject

- [ ] should reject proposal with valid id
- [ ] should require authentication

### 3.9 Proposal Handlers 구현

**파일**: `apps/server/src/modules/wod/handlers.ts`

- [ ] createProposal 구현 (POST /wods/proposals)
- [ ] approveProposal 구현 (POST /wods/proposals/:proposalId/approve)
- [ ] rejectProposal 구현 (POST /wods/proposals/:proposalId/reject)

**실행**: `pnpm test` — proposal handlers 테스트 통과 확인

---

## Phase 4: WOD Selection (불변성 보장)

### 4.1 Selection Schema 정의

**파일**: `apps/server/src/modules/wod/schema.ts`

- [ ] wodSelections 테이블 정의 (id, userId, wodId, boxId, date, snapshotData, createdAt)
- [ ] UNIQUE 제약조건 (userId + boxId + date)
- [ ] 인덱스 추가 (userId, boxId + date)

**마이그레이션**:
```bash
pnpm drizzle-kit generate
pnpm drizzle-kit push
```

### 4.2 Selection Types 정의

**파일**: `apps/server/src/modules/wod/types.ts`

- [ ] WodSelection 인터페이스 정의

### 4.3 Selection Services 테스트

**파일**: `apps/server/tests/unit/wod/services.test.ts`

#### selectWod 테스트

- [ ] should create selection with snapshot of current WOD
- [ ] should copy programData to snapshotData
- [ ] should enforce UNIQUE(userId, boxId, date) via upsert
- [ ] should preserve snapshotData when Base WOD changes
- [ ] should return same selection for same date

#### getSelections 테스트

- [ ] should return selections by userId and date range
- [ ] should return empty array for no selections
- [ ] should include snapshotData in response

### 4.4 Selection Services 구현

**파일**: `apps/server/src/modules/wod/services.ts`

- [ ] selectWod 구현 (스냅샷 생성, 멱등성 보장)
- [ ] getSelections 구현 (날짜 범위 조회)

**실행**: `pnpm test` — selection 테스트 통과 확인

### 4.5 Selection Handlers 단위 테스트

**파일**: `apps/server/tests/unit/wod/handlers.test.ts`

#### POST /wods/:wodId/select

- [ ] should select WOD with valid data
- [ ] should throw NotFoundException for non-existent WOD
- [ ] should return existing selection when selecting same WOD
- [ ] should require authentication

#### GET /wods/selections

- [ ] should return selections for date range
- [ ] should return selections without date range
- [ ] should require authentication

### 4.6 Selection Handlers 구현

**파일**: `apps/server/src/modules/wod/handlers.ts`

- [ ] selectWod 구현 (POST /wods/:wodId/select)
- [ ] getSelections 구현 (GET /wods/selections)

**실행**: `pnpm test` — selection handlers 테스트 통과 확인

---

## Phase 5: Operational Logging (Domain Probe)

### 5.1 Box Probe

**파일**: `apps/server/src/modules/box/box.probe.ts`

- [ ] created 함수 구현 (박스 생성 성공 — INFO)
- [ ] memberJoined 함수 구현 (박스 가입 성공 — INFO)
- [ ] boxSwitched 함수 구현 (박스 변경 — INFO)

**테스트 파일**: `apps/server/tests/unit/box/box.probe.test.ts`

- [ ] should log box created event
- [ ] should log member joined event
- [ ] should log box switched event

### 5.2 WOD Probe

**파일**: `apps/server/src/modules/wod/wod.probe.ts`

- [ ] baseWodRegistered 함수 구현 (Base WOD 등록 — INFO)
- [ ] personalWodRegistered 함수 구현 (Personal WOD 등록 — INFO)
- [ ] proposalCreated 함수 구현 (변경 제안 생성 — INFO)
- [ ] proposalApproved 함수 구현 (변경 승인 — INFO)
- [ ] wodSelected 함수 구현 (WOD 선택 — INFO)
- [ ] duplicateSelectionAttempt 함수 구현 (중복 선택 시도 — WARN)

**테스트 파일**: `apps/server/tests/unit/wod/wod.probe.test.ts`

- [ ] should log base WOD registered event
- [ ] should log personal WOD registered event
- [ ] should log proposal created event
- [ ] should log proposal approved event
- [ ] should log WOD selected event
- [ ] should log duplicate selection attempt warning

**실행**: `pnpm test` — probe 테스트 통과 확인

---

## Phase 6: Integration & Router Setup

### 6.1 WOD Router 통합

**파일**: `apps/server/src/modules/wod/index.ts`

- [ ] Router 생성 및 모든 핸들러 등록
- [ ] 인증 미들웨어 적용
- [ ] Zod validation 미들웨어 적용

### 6.2 App Router 통합

**파일**: `apps/server/src/app.ts`

- [ ] Box router 등록 (`/boxes`)
- [ ] WOD router 등록 (`/wods`)

### 6.3 E2E Smoke Test (수동)

```bash
# 서버 실행
pnpm dev

# 박스 생성
curl -X POST http://localhost:3001/boxes \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"name":"CrossFit Seoul","region":"서울 강남구","description":"Best gym"}'

# WOD 등록
curl -X POST http://localhost:3001/wods \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "boxId": 1,
    "date": "2026-02-04",
    "rawText": "AMRAP 15min\n10 Pull-ups\n20 Push-ups",
    "programData": {
      "type": "AMRAP",
      "timeCap": 15,
      "movements": [
        {"name": "Pull-up", "reps": 10},
        {"name": "Push-up", "reps": 20}
      ]
    }
  }'

# WOD 조회
curl http://localhost:3001/wods/1/2026-02-04 \
  -H "Authorization: Bearer {token}"
```

**실행**: 모든 엔드포인트 정상 동작 확인

---

## 체크리스트 요약

### Phase 0: 구조 변경
- [ ] 0.1 Box schema region 필드 추가
- [ ] 0.2 Box types region 필드 추가
- [ ] 0.3 기존 테스트 mock 데이터 수정

### Phase 1: Box Module
- [ ] 1.1 Box services 단위 테스트 (7개 테스트)
- [ ] 1.2 Box services 구현
- [ ] 1.3 Box handlers 단위 테스트 (15개 테스트)
- [ ] 1.4 Box handlers 구현
- [ ] 1.5 Box validators (Zod)
- [ ] 1.6 Box router 통합

### Phase 2: WOD Module 기본
- [ ] 2.1 WOD schema 정의
- [ ] 2.2 WOD types 정의
- [ ] 2.3 WOD validators (Zod)
- [ ] 2.4 WOD services 테스트 (5개 테스트)
- [ ] 2.5 WOD services 구현
- [ ] 2.6 WOD handlers 테스트 (4개 테스트)
- [ ] 2.7 WOD handlers 구현

### Phase 3: Comparison & Proposals
- [ ] 3.1 Exercise normalization (5개 테스트)
- [ ] 3.2 WOD comparison logic (7개 테스트)
- [ ] 3.3 Proposal schema 정의
- [ ] 3.4 Proposal types 정의
- [ ] 3.5 Proposal services 테스트 (10개 테스트)
- [ ] 3.6 Proposal services 구현
- [ ] 3.7 registerWod 업데이트 (4개 테스트)
- [ ] 3.8 Proposal handlers 테스트 (6개 테스트)
- [ ] 3.9 Proposal handlers 구현

### Phase 4: WOD Selection
- [ ] 4.1 Selection schema 정의
- [ ] 4.2 Selection types 정의
- [ ] 4.3 Selection services 테스트 (5개 테스트)
- [ ] 4.4 Selection services 구현
- [ ] 4.5 Selection handlers 테스트 (5개 테스트)
- [ ] 4.6 Selection handlers 구현

### Phase 5: Logging
- [ ] 5.1 Box probe (3개 함수 + 테스트)
- [ ] 5.2 WOD probe (6개 함수 + 테스트)

### Phase 6: Integration
- [ ] 6.1 WOD router 통합
- [ ] 6.2 App router 통합
- [ ] 6.3 E2E smoke test (수동)

---

## 참고 자료

### Server Guides
- **Server CLAUDE.md**: `apps/server/CLAUDE.md`
- **API Response Design**: `.claude/guide/server/api-response-design.md`
- **Exception Handling**: `.claude/guide/server/exception-handling.md`
- **Logging Best Practices**: `.claude/guide/server/logging-best-practices.md`

### Design Documents
- **Server Brief**: `docs/wowa/mvp/server-brief.md`
- **Plan**: `docs/wowa/mvp/plan.md`
- **User Story**: `docs/wowa/mvp/user-story.md`

### Catalog
- **Server Catalog**: `docs/wowa/server-catalog.md` (재사용 가능한 모듈)

---

**작성일**: 2026-02-04
**버전**: 1.0.0
**상태**: Ready for Implementation

다음 단계: Node Developer가 Phase 0부터 순차적으로 TDD 사이클 진행
