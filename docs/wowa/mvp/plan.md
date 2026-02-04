# WOWA MVP Plan

> Feature: wowa
> Created: 2026-02-03
> Status: Draft
> Phase: Plan

---

## 1. Background & Research Summary

### 1.1 Problem Statement

CrossFit 박스에서 WOD(Workout of the Day) 정보가 카카오톡, 인스타그램, 네이버 카페 등에 **파편화**되어 있다.

- 코치가 올린 WOD가 대화에 묻혀 검색 불가
- 코치 간 전달 오류, 화이트보드 오타 등 정보 불일치
- 기존 앱(SugarWOD, BTWB, Wodify)은 **코치 권한 필수** → 비용/운영 부담

### 1.2 Validated Hypotheses (Research)

| Hypothesis | Validation | Confidence |
|-----------|-----------|------------|
| WOD 정보 파편화는 실재 문제 | **Strongly confirmed** — 글로벌/한국 공통 | High |
| 역할 기반 권한이 채택 장벽 | **Partially confirmed** — 비용이 더 큰 요인 | Medium |
| 합의 모델이 파편화 해결 가능 | **Conditionally possible** — 품질 통제 필수 | Medium |
| 기술적 구현 가능성 | **High** — 현재 스택으로 전부 가능 | High |

### 1.3 Key Research Decisions

**가설 수정**: "권한 제거"가 아닌 **"명시적 권한 부여 불필요"** 프레이밍

- 코치가 먼저 등록하면 자연스럽게 Base WOD가 됨
- 코치 권위를 부정하지 않으면서도 권한 관리 불필요
- 리서치에서 확인된 코치 반발 리스크 완화

### 1.4 Competitive Advantage

```
기존 시장의 상식              →  WOWA의 전복
─────────────────────        ─────────────────────
WOD는 코치가 정한다           →  먼저 등록한 사람이 Base, 합의로 확정
역할 관리가 필요하다           →  역할 관리 자체가 불필요
시스템이 정답을 판단한다        →  시스템은 중립, 사용자가 선택
WOD는 하나다 (Rx/Scaled)      →  Base WOD와 Personal WOD가 공존
```

---

## 2. MVP Scope

### 2.1 MVP Definition of Done (PRD 9장)

1. 역할 구분 없이 WOD 등록 가능
2. Base / Personal WOD 자동 분리
3. 변경 제안 및 승인 흐름 존재
4. 사용자가 기록할 WOD를 직접 선택 가능

### 2.2 In Scope (MVP)

| Feature | Server | Mobile | Priority |
|---------|--------|--------|----------|
| Box 관리 (검색/가입/변경) | Box(+region) + BoxMember 스키마, 검색/가입(자동탈퇴)/생성(자동가입) API | 박스 검색/가입/변경 UI (단일 박스 정책) | P0 |
| WOD 등록 (텍스트) | WOD 등록 API, Base 자동 지정 | WOD 등록 화면 | P0 |
| WOD 조회 (날짜별) | 날짜별 WOD 조회 API | 홈 화면 (오늘의 WOD) | P0 |
| Base/Personal 분리 | 구조적 비교, Personal 자동 분류 | WOD 상세 (Base vs Personal) | P0 |
| 변경 제안/승인 | 변경 제안 API, 승인 API | 변경 제안 UI | P0 |
| WOD 선택/기록 | 선택 API, 기록 불변성 | WOD 선택 화면 | P0 |
| 알림 연동 | WOD 이벤트 푸시 (기존 모듈 활용) | FCM 수신 | P1 |
| 모바일 OAuth 연동 | - (기존 완료) | 실제 OAuth 연동 | P1 |

### 2.3 Out of Scope (Post-MVP)

- 화이트보드 사진 OCR + AI 분석
- Box 신뢰도 시스템 / 코치 배지
- 변경 히스토리 시각화
- 난이도 계산 시스템
- Apple Watch 연동
- 멀티 박스 전환

---

## 3. Implementation Phases

### Phase 1: Box + WOD 기본 구조 (Server Focus)

**목표**: Box 관리와 WOD 등록/조회의 핵심 데이터 파이프라인 완성

| Step | Task | Details |
|------|------|---------|
| 1-1 | Box 스키마 설계 | `boxes` (region 필드 포함), `box_members` 테이블 (Drizzle), 단일 박스 정책 |
| 1-2 | Box API | 내 박스 확인, 박스 검색(이름+지역), 생성(+자동가입), 가입(+자동탈퇴), 상세조회, 멤버 목록 |
| 1-3 | WOD 스키마 설계 | `wods` 테이블 (program_data JSONB, is_base) |
| 1-4 | WOD 등록 API | POST /wod — 텍스트 입력, Base 자동 지정 |
| 1-5 | WOD 조회 API | GET /wod/:boxId/:date — Base + Personal 반환 |

**TDD 순서**: 스키마 → 핸들러 단위테스트 → 구현

### Phase 2: Base/Personal WOD 분리 (Server Focus)

**목표**: WOD 구조적 비교 및 자동 분류 로직 완성

| Step | Task | Details |
|------|------|---------|
| 2-1 | WOD 구조 비교 로직 | 타입/시간/운동명/반복수 필드별 비교 |
| 2-2 | 운동명 정규화 | 동의어 매핑 (pullup→pull-up, c&j→clean-and-jerk) |
| 2-3 | Personal WOD 자동 분류 | Base와 다르면 is_base=false 처리 |
| 2-4 | 변경 제안 스키마/API | `proposed_changes` 테이블, POST /wod/:id/propose |
| 2-5 | 변경 승인 API | POST /wod/:id/approve, Base 교체 로직 |

### Phase 3: WOD 선택 및 기록 (Server + Mobile)

**목표**: 사용자가 WOD를 선택하여 기록하는 전체 플로우 완성

| Step | Task | Details |
|------|------|---------|
| 3-1 | WOD 선택 스키마/API | `wod_selections` 테이블, POST /wod/:id/select |
| 3-2 | 기록 불변성 보장 | 선택 시점의 WOD 스냅샷 저장 |
| 3-3 | 선택 조회 API | GET /wod/selections/:date |

### Phase 4: 모바일 핵심 화면 (Mobile Focus)

**목표**: API 모델 생성 및 핵심 화면 구현

| Step | Task | Details |
|------|------|---------|
| 4-1 | API 모델 (Freezed) | Box, Wod, WodSelection, ProposedChange, Movement |
| 4-2 | Dio 클라이언트 설정 | 인증 인터셉터, 토큰 갱신, 에러 핸들링 |
| 4-3 | 홈 화면 | 오늘의 WOD 표시, 박스 선택 |
| 4-4 | WOD 등록 화면 | 텍스트 입력 폼 |
| 4-5 | WOD 상세 화면 | Base vs Personal 표시, 변경 제안 UI |
| 4-6 | WOD 선택 화면 | Base/Personal 중 선택 |

### Phase 5: 알림 연동 (Integration)

**목표**: WOD 이벤트 알림으로 실시간 커뮤니케이션

| Step | Task | Details |
|------|------|---------|
| 5-1 | 서버 알림 발송 | WOD 등록/차이발생/변경승인 시 FCM 발송 |
| 5-2 | 모바일 FCM 수신 | FCM 토큰 등록, 알림 수신 처리 |
| 5-3 | 실제 OAuth 연동 | LoginController mock 제거, 서버 API 호출 |

---

## 4. Technical Decisions

### 4.1 Server Architecture

- **Module pattern**: `src/modules/wod/`, `src/modules/box/`
- **Handler-first**: Controller/Service 분리 없이 핸들러에서 직접 처리 (복잡해지면 분리)
- **Validation**: Zod 스키마로 입력 검증
- **Error handling**: 기존 AppException 계층 활용

### 4.2 WOD Data Model

```json
{
  "type": "AMRAP | ForTime | EMOM | Strength | Custom",
  "timeCap": 15,
  "rounds": null,
  "movements": [
    { "name": "Pull-up", "reps": 10, "weight": null, "unit": null },
    { "name": "Push-up", "reps": 20, "weight": null, "unit": null }
  ]
}
```

- `program_data`는 JSONB 컬럼으로 유연하게 저장
- Zod로 서버 측 구조 검증

### 4.3 WOD Comparison Strategy

- LLM/NLP 불필요 — 구조화 JSON 필드별 비교
- 운동명 정규화 테이블로 동의어 처리
- 비교 결과: `identical | similar | different`

### 4.4 Mobile Architecture

- GetX 패턴: Controller → Binding → View
- 기존 패키지 구조 유지: core / api / design_system / wowa app
- Freezed 모델로 API 타입 안전성 확보

---

## 5. Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|-----------|
| 합의 모델로 잘못된 WOD 확정 | High | Phase 2에서 구조적 비교 경고 UI 제공. Post-MVP에서 신뢰도 시스템 |
| 코치 반발 | High | "명시적 권한 부여 불필요" 프레이밍. 코치가 먼저 등록 → 자연스레 Base |
| Base 선점 경쟁 | Medium | 변경 제안 → 승인 플로우로 합의 도달 |
| 운동명 정규화 누락 | Medium | 초기에 주요 크로스핏 동작 100여개 매핑. 점진적 확장 |
| 모바일 OAuth 연동 복잡성 | Low | 서버 인증 모듈 이미 완성. 모바일 SDK 연동만 필요 |

---

## 6. Success Metrics (PRD 8장)

| Metric | Target | Measurement |
|--------|--------|-------------|
| WOD 등록 후 조회율 | > 70% | 등록 대비 조회 수 비율 |
| Personal WOD 발생 비율 | 10-30% | Base 대비 Personal 비율 |
| Base 변경 승인율 | > 50% | 제안 대비 승인 비율 |
| 사용자 선택 완료율 | > 80% | 조회 대비 선택 완료 비율 |

---

## 7. Dependencies (Existing Infrastructure)

| Dependency | Status | Module |
|-----------|--------|--------|
| 인증 (JWT + OAuth) | ✅ 완료 | apps/server/src/modules/auth/ |
| FCM 푸시 알림 | ✅ 완료 | apps/server/src/modules/push-alert/ |
| Design System (12 widgets) | ✅ 완료 | apps/mobile/packages/design_system/ |
| Core Package | ✅ 완료 | apps/mobile/packages/core/ |
| Login UI | ⚠️ mock | apps/mobile/apps/wowa/lib/app/modules/login/ |

---

## 8. Implementation Order Summary

```
Phase 1: Box + WOD 기본 구조 (Server)
  ↓
Phase 2: Base/Personal 분리 (Server)
  ↓
Phase 3: WOD 선택/기록 (Server + Mobile)
  ↓
Phase 4: 모바일 핵심 화면 (Mobile)
  ↓
Phase 5: 알림 + OAuth 연동 (Integration)
```

> Phase 1~3은 서버 TDD로 빠르게 진행.
> Phase 4에서 모바일 화면 구현.
> Phase 5에서 전체 통합.

---

## 9. Server TDD Test Checklist

> 상세 작업 계획: `docs/wowa/mvp/server-work-plan.md`
> TDD Cycle: Red → Green → Refactor
> Test Command: `cd apps/server && pnpm test`

### Phase 0: 구조 변경 (Structural)

- [x] boxes 테이블에 region 컬럼 추가
- [x] Box types에 region 필드 추가 (Box, CreateBoxInput, SearchBoxInput, BoxWithMemberCount, MyBoxResult)
- [x] 기존 테스트 mock 데이터에 region 추가

### Phase 1: Box Services

- [x] createBox — should create box with valid data
- [x] joinBox — should auto-leave previous box when joining new box
- [x] joinBox — should return existing membership when joining same box
- [x] searchBoxes — should search boxes by name (ILIKE)
- [x] searchBoxes — should search boxes by region (ILIKE)
- [x] searchBoxes — should search boxes by name and region (AND)
- [x] searchBoxes — should return empty array when no match
- [x] searchBoxes — should include memberCount in search results
- [x] searchBoxes — should return empty array when no query params
- [x] getCurrentBox — should return current box when user has membership
- [x] getCurrentBox — should return null when user has no membership
- [x] getCurrentBox — should include memberCount in response
- [x] getCurrentBox — should include joinedAt timestamp
- [x] getBoxMembers — should list all members of a box
- [x] getBoxMembers — should include joinedAt timestamp
- [x] getBoxMembers — should return empty array for box with no members

### Phase 1: Box Handlers

- [x] GET /boxes/me — should return current box when user has membership
- [x] GET /boxes/me — should return null when user has no membership
- [x] GET /boxes/search — should search boxes by name query param
- [x] GET /boxes/search — should search boxes by region query param
- [x] GET /boxes/search — should return empty array when no query params
- [x] POST /boxes — should create box with name, region, and description
- [x] POST /boxes — should auto-join creator after box creation
- [x] POST /boxes/:boxId/join — should join box with valid boxId
- [x] POST /boxes/:boxId/join — should include previousBoxId when switching boxes
- [x] GET /boxes/:boxId — should return box details by id
- [x] GET /boxes/:boxId — should include memberCount in response
- [x] GET /boxes/:boxId/members — should list all members of a box

### Phase 2: WOD Services

- [x] registerWod — should create Base WOD when first for date/box
- [x] registerWod — should auto-set isBase=true for first WOD
- [x] registerWod — should validate programData structure
- [x] registerWod — should store rawText as-is
- [ ] registerWod — should throw ValidationException for invalid programData
- [x] getWodsByDate — should return Base WOD for given date/box
- [x] getWodsByDate — should return empty personalWods when none exist
- [x] getWodsByDate — should return null baseWod when none exist
- [x] getWodsByDate — should return Personal WODs with comparisonResult

### Phase 2: WOD Handlers

- [ ] POST /wods — should register WOD with valid data
- [ ] POST /wods — should auto-set isBase=true for first WOD
- [ ] POST /wods — should throw ValidationException for invalid programData
- [ ] GET /wods/:boxId/:date — should return Base and Personal WODs for date
- [ ] GET /wods/:boxId/:date — should return empty arrays when no WODs

### Phase 3: Normalization

- [x] normalizeExerciseName — should normalize 'pullup' to 'pull-up'
- [x] normalizeExerciseName — should normalize 'c&j' to 'clean-and-jerk'
- [x] normalizeExerciseName — should normalize 'box jump' to 'box-jump'
- [x] normalizeExerciseName — should return lowercase and trimmed name
- [x] normalizeExerciseName — should handle unknown exercises

### Phase 3: Comparison

- [x] compareWods — should return 'identical' for same structure
- [x] compareWods — should return 'different' for different type
- [x] compareWods — should return 'different' for different movements count
- [x] compareWods — should return 'different' for >10% timeCap difference
- [x] compareWods — should return 'similar' for >10% reps difference
- [x] compareWods — should return 'similar' for >5% weight difference
- [x] compareWods — should normalize exercise names before comparison

### Phase 3: Proposal Services

- [x] createProposal — should create proposal when Personal WOD differs
- [x] createProposal — should set status to 'pending'
- [ ] createProposal — should not create for identical WODs
- [x] approveProposal — should swap Base and Personal WOD
- [ ] approveProposal — should set old Base isBase=false
- [ ] approveProposal — should set new Base isBase=true
- [ ] approveProposal — should update status to 'approved'
- [x] approveProposal — should throw ProposalNotFoundException for invalid id
- [x] approveProposal — should throw UnauthorizedApprovalException for non-creator
- [x] registerWod — should create Personal WOD when Base exists
- [x] registerWod — should auto-create proposal when different
- [x] registerWod — should not create proposal when identical
- [x] rejectProposal — should throw NotFoundException for invalid proposal id
- [x] rejectProposal — should throw BusinessException for non-creator rejection attempt
- [x] rejectProposal — should update proposal status to rejected

### Phase 3: Proposal Handlers

- [ ] POST /wods/proposals — should create proposal with valid data
- [ ] POST /wods/proposals/:id/approve — should approve when Base creator
- [ ] POST /wods/proposals/:id/approve — should throw UnauthorizedApprovalException
- [ ] POST /wods/proposals/:id/approve — should throw ProposalNotFoundException
- [ ] POST /wods/proposals/:id/reject — should reject with valid id

### Phase 4: Selection Services

- [x] selectWod — should create selection with snapshot
- [x] selectWod — should copy programData to snapshotData
- [x] selectWod — should throw NotFoundException for invalid WOD id
- [ ] selectWod — should enforce UNIQUE(userId, boxId, date)
- [ ] selectWod — should preserve snapshotData when Base changes
- [x] getSelections — should return selections by date range
- [x] getSelections — should return all selections when no date range specified
- [ ] getSelections — should return empty array for no selections
- [x] getSelections — should include snapshotData

### Phase 4: Selection Handlers

- [ ] POST /wods/:wodId/select — should select WOD with valid data
- [ ] POST /wods/:wodId/select — should throw NotFoundException
- [ ] GET /wods/selections — should return selections for date range
- [ ] GET /wods/selections — should return selections without date range
