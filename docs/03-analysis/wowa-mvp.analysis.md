# wowa-mvp Gap Analysis Report

> Feature: wowa-mvp
> Platform: fullstack (Server + Mobile)
> Date: 2026-02-04
> Scope: Server-side analysis (Phase 1-4)

---

## 1. Summary

```
+---------------------------------------------+
|  Overall Match Rate: 75%                     |
+---------------------------------------------+
|  API Endpoints:      100%  (11/11)           |
|  DB Schema:          100%  (5/5 tables)      |
|  Business Logic:     100%  (7/7 services)    |
|  TDD Checklist:       75%  (63/84 tests)     |
|  Error Classes:        0%  (0/5 classes)     |
|  Probe (Logging):      0%  (0/2 files)       |
|  Handler Tests:        0%  (0/14 test cases) |
|  Build:              PASS                     |
|  All Tests:          PASS  (170/170)         |
+---------------------------------------------+
```

---

## 2. Category-wise Analysis

### 2.1 API Endpoints (100%)

| Endpoint | Design | Implemented | Router | Handler |
|----------|:------:|:-----------:|:------:|:-------:|
| GET /boxes/me | server-brief.md 4.1 | O | O | O |
| GET /boxes/search | server-brief.md 4.1 | O | O | O |
| POST /boxes | server-brief.md 4.1 | O | O | O |
| POST /boxes/:boxId/join | server-brief.md 4.1 | O | O | O |
| GET /boxes/:boxId | server-brief.md 4.1 | O | O | O |
| GET /boxes/:boxId/members | server-brief.md 4.1 | O | O | O |
| POST /wods | server-brief.md 4.2 | O | O | O |
| GET /wods/:boxId/:date | server-brief.md 4.2 | O | O | O |
| POST /wods/proposals | server-brief.md 4.2 | O | O | O |
| POST /wods/proposals/:id/approve | server-brief.md 4.2 | O | O | O |
| POST /wods/proposals/:id/reject | extra (plan.md) | O | O | O |
| POST /wods/:wodId/select | server-brief.md 4.2 | O | O | O |
| GET /wods/selections | server-brief.md 4.2 | O | O | O |

**Note**: `reject` endpoint is implemented beyond original design (good).

### 2.2 DB Schema (100%)

| Table | Design | schema.ts |
|-------|:------:|:---------:|
| boxes | server-brief.md 3.1 | `box/schema.ts` |
| box_members | server-brief.md 3.1 | `box/schema.ts` |
| wods | server-brief.md 3.2 | `wod/schema.ts` |
| proposed_changes | server-brief.md 3.2 | `wod/schema.ts` |
| wod_selections | server-brief.md 3.3 | `wod/schema.ts` |

### 2.3 Business Logic Services (100%)

| Service Function | Design | Implemented |
|-----------------|:------:|:-----------:|
| registerWod | server-brief.md 5.1 | `wod/services.ts` |
| getWodsByDate | server-brief.md 4.2 | `wod/services.ts` |
| createProposal | server-brief.md 5.4 | `wod/services.ts` |
| approveProposal | server-brief.md 5.4 | `wod/services.ts` |
| rejectProposal | plan.md | `wod/services.ts` |
| selectWod | server-brief.md 5.5 | `wod/services.ts` |
| getSelections | server-brief.md 4.2 | `wod/services.ts` |

### 2.4 TDD Checklist (75% — 63/84)

| Phase | Total | Done | Remaining |
|-------|------:|-----:|----------:|
| Phase 0: Structural | 3 | 3 | 0 |
| Phase 1: Box Services | 15 | 15 | 0 |
| Phase 1: Box Handlers | 12 | 12 | 0 |
| Phase 2: WOD Services | 8 | 7 | **1** |
| Phase 2: WOD Handlers | 5 | 0 | **5** |
| Phase 3: Normalization | 5 | 5 | 0 |
| Phase 3: Comparison | 7 | 7 | 0 |
| Phase 3: Proposal Services | 12 | 9 | **3** |
| Phase 3: Proposal Handlers | 5 | 0 | **5** |
| Phase 4: Selection Services | 8 | 5 | **3** |
| Phase 4: Selection Handlers | 4 | 0 | **4** |
| **Total** | **84** | **63** | **21** |

### 2.5 Custom Error Classes (0%)

| Error Class | Design | Implemented |
|-------------|:------:|:-----------:|
| BoxNotFoundException | server-brief.md 6.1 | X |
| WodNotFoundException | server-brief.md 6.1 | X |
| DuplicateWodSelectionException | server-brief.md 6.1 | X |
| ProposalNotFoundException | server-brief.md 6.1 | X |
| UnauthorizedApprovalException | server-brief.md 6.1 | X |

**Note**: Services use generic AppException/NotFoundException/BusinessException directly instead of custom subclasses.

### 2.6 Domain Probe Files (0%)

| Probe File | Design | Implemented |
|------------|:------:|:-----------:|
| box.probe.ts | server-brief.md 9.1 | X |
| wod.probe.ts | server-brief.md 9.2 | X |

### 2.7 Handler Test Files (0%)

| Test File | Design | Implemented |
|-----------|:------:|:-----------:|
| tests/unit/wod/handlers.test.ts | server-brief.md 8.1 | X |

**Note**: Box handler tests exist (`tests/unit/box/handlers.test.ts`). WOD handler tests are missing.

---

## 3. Gap List (21 items)

### 3.1 Critical (blocks functionality)

None — all API endpoints and business logic are implemented and tests pass.

### 3.2 High Priority (TDD checklist gaps)

| # | Gap | Category | plan.md Reference |
|---|-----|----------|-------------------|
| 1 | registerWod — should throw ValidationException for invalid programData | Service Test | Phase 2 |
| 2 | POST /wods — should register WOD with valid data | Handler Test | Phase 2 |
| 3 | POST /wods — should auto-set isBase=true for first WOD | Handler Test | Phase 2 |
| 4 | POST /wods — should throw ValidationException for invalid programData | Handler Test | Phase 2 |
| 5 | GET /wods/:boxId/:date — should return Base and Personal WODs for date | Handler Test | Phase 2 |
| 6 | GET /wods/:boxId/:date — should return empty arrays when no WODs | Handler Test | Phase 2 |
| 7 | createProposal — should not create for identical WODs | Service Test | Phase 3 |
| 8 | approveProposal — should set old Base isBase=false | Service Test | Phase 3 |
| 9 | approveProposal — should set new Base isBase=true | Service Test | Phase 3 |
| 10 | approveProposal — should update status to 'approved' | Service Test | Phase 3 |
| 11 | POST /wods/proposals — should create proposal with valid data | Handler Test | Phase 3 |
| 12 | POST /wods/proposals/:id/approve — should approve when Base creator | Handler Test | Phase 3 |
| 13 | POST /wods/proposals/:id/approve — should throw UnauthorizedApprovalException | Handler Test | Phase 3 |
| 14 | POST /wods/proposals/:id/approve — should throw ProposalNotFoundException | Handler Test | Phase 3 |
| 15 | POST /wods/proposals/:id/reject — should reject with valid id | Handler Test | Phase 3 |
| 16 | selectWod — should enforce UNIQUE(userId, boxId, date) | Service Test | Phase 4 |
| 17 | selectWod — should preserve snapshotData when Base changes | Service Test | Phase 4 |
| 18 | getSelections — should return empty array for no selections | Service Test | Phase 4 |
| 19 | POST /wods/:wodId/select — should select WOD with valid data | Handler Test | Phase 4 |
| 20 | POST /wods/:wodId/select — should throw NotFoundException | Handler Test | Phase 4 |
| 21 | GET /wods/selections — should return selections for date range | Handler Test | Phase 4 |

### 3.3 Medium Priority (Design completeness)

| # | Gap | Category |
|---|-----|----------|
| 22 | BoxNotFoundException 커스텀 에러 클래스 미구현 | Error Handling |
| 23 | WodNotFoundException 커스텀 에러 클래스 미구현 | Error Handling |
| 24 | DuplicateWodSelectionException 커스텀 에러 클래스 미구현 | Error Handling |
| 25 | ProposalNotFoundException 커스텀 에러 클래스 미구현 | Error Handling |
| 26 | UnauthorizedApprovalException 커스텀 에러 클래스 미구현 | Error Handling |

### 3.4 Low Priority (Operational readiness)

| # | Gap | Category |
|---|-----|----------|
| 27 | box.probe.ts Domain Probe 파일 미구현 | Logging |
| 28 | wod.probe.ts Domain Probe 파일 미구현 | Logging |

---

## 4. Match Rate Calculation

| Category | Weight | Score | Weighted |
|----------|-------:|------:|---------:|
| API Endpoints | 25% | 100% | 25.0 |
| DB Schema | 15% | 100% | 15.0 |
| Business Logic | 20% | 100% | 20.0 |
| TDD Checklist | 25% | 75% | 18.75 |
| Error Classes | 5% | 0% | 0.0 |
| Probe Files | 5% | 0% | 0.0 |
| Handler Tests | 5% | 0% | 0.0 |
| **Total** | **100%** | | **78.75%** |

**Rounded Match Rate: 79%**

---

## 5. Build & Test Status

| Check | Status |
|-------|--------|
| `pnpm build` (tsc) | PASS (0 errors) |
| `pnpm test` (vitest) | PASS (170/170, 14 files) |
| TypeScript strict | PASS |

---

## 6. Recommendations

### Immediate Actions (Match Rate -> 90%)

1. **WOD Handler 테스트 작성** (tests/unit/wod/handlers.test.ts) — 14개 핸들러 테스트 추가
2. **나머지 Service 테스트 완성** — 7개 서비스 테스트 추가
3. **커스텀 에러 클래스 추가** — 5개 클래스 (구현 영향 없이 타입만 추가)

### Optional (Post-90%)

4. Probe 파일 구현 (box.probe.ts, wod.probe.ts)
5. ErrorCode enum 확장

---

## 7. Mobile Side (Not Analyzed)

Mobile 구현은 서버 완성 후 Phase 4에서 시작 예정. 현재 미구현 상태.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-04 | Initial gap analysis (server-side) |
