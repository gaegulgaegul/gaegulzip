# WOWA MVP Gap Analysis Report

> Feature: wowa-mvp
> Platform: Fullstack (Server + Mobile)
> Analysis Date: 2026-02-05
> Branch: feature/wowa-mvp

---

## Overall Scores

| Category | Score | Status |
|----------|:-----:|:------:|
| Server Design Match | 91% | PASS |
| Mobile Design Match | 82% | WARN |
| Fullstack Consistency | 62% | FAIL |
| **Overall Match Rate** | **78%** | **FAIL (< 90%)** |

---

## CRITICAL Findings (4)

### C-1. Mobile API Client 응답 파싱 불일치 (전체 13개 엔드포인트)

**문제**: Mobile API Client가 모든 응답을 `response.data['data']`로 파싱하지만, Server는 `data` 래퍼를 사용하지 않고 직접 JSON을 반환합니다.

| # | Endpoint | Server 응답 | Mobile 파싱 | Runtime 결과 |
|---|----------|-------------|-------------|:----------:|
| 1 | GET /boxes/me | `res.json({ box })` | `response.data['data']` | null |
| 2 | GET /boxes/search | `res.json({ boxes })` | `response.data['data']` as List | TypeError |
| 3 | POST /boxes | `res.json({ box, membership })` | `response.data['data']` | null |
| 4 | POST /boxes/:boxId/join | `res.json(result)` | `response.data['data']` | null |
| 5 | GET /boxes/:boxId | `res.json(box)` | `response.data['data']` | null |
| 6 | GET /boxes/:boxId/members | `res.json({ members, totalCount })` | `response.data['data']['members']` | TypeError |
| 7 | POST /wods | `res.json(wod)` (201) | `response.data['data']` | null |
| 8 | GET /wods/:boxId/:date | `res.json(result)` | `response.data['data']` | null |
| 9 | POST /wods/proposals | `res.json(proposal)` (201) | (mobile에서 직접 호출 안 함) | - |
| 10 | POST /wods/proposals/:id/approve | `res.json({ approved: true })` | `ProposalModel.fromJson(response.data['data'])` | TypeError |
| 11 | POST /wods/proposals/:id/reject | `res.json({ rejected: true })` | `ProposalModel.fromJson(response.data['data'])` | TypeError |
| 12 | POST /wods/:wodId/select | `res.json(selection)` (201) | `response.data['data']` | null |
| 13 | GET /wods/selections | `res.json({ selections, totalCount })` | `response.data['data']` as List | TypeError |

**영향**: CRITICAL - 모든 API 호출이 runtime에서 null 반환 또는 TypeError 발생. 앱 전체 기능 불능.

### C-2. GET /wods/proposals 엔드포인트 누락

- **Mobile**: `ProposalApiClient.getPendingProposals()` 가 `GET /api/wods/proposals?baseWodId=&status=pending` 호출
- **Server**: WOD 라우터에 `GET /proposals` 미등록. POST만 존재.
- **영향**: CRITICAL - 변경 제안 조회 기능 불가.

### C-3. approve/reject 응답 형식 불일치

- **Server approve**: `res.json({ approved: true })`
- **Server reject**: `res.json({ rejected: true })`
- **Mobile**: `ProposalModel.fromJson(response.data['data'])` -- ProposalModel 기대
- **영향**: HIGH - approve/reject 후 모바일에서 ProposalModel 파싱 실패

### C-4. Movement 필드명 불일치 (unit vs weightUnit)

- **Server types.ts**: `weightUnit?: WeightUnit`
- **Mobile movement.dart**: `String? unit`
- **설계 문서**: `unit` 사용 (server-brief.md)
- **영향**: HIGH - 무게 단위 정보 손실.

---

## HIGH Findings (2)

### H-1. URL 접두사 불일치 (/api/ prefix)

- **Server**: `app.use('/boxes', boxRouter)`, `app.use('/wods', wodRouter)` -- `/api` prefix 없음
- **Mobile 모든 API Client**: `/api/boxes/...`, `/api/wods/...` 사용
- **영향**: MEDIUM - Dio baseUrl 설정에 따라 다르지만, 서버 라우트와 직접 불일치

### H-2. RegisterWodRequest.rawText nullable vs Server required

- **Server**: `rawText: text('raw_text').notNull()`
- **Mobile**: `String? rawText` (nullable)
- **영향**: MEDIUM - rawText 없이 전송 시 서버 422 에러

---

## MEDIUM Findings (3)

| # | Item | Description |
|---|------|-------------|
| M-1 | WodModel.comparisonResult 누락 | 서버 WodWithComparison에 포함, 모바일 WodModel에 없음 |
| M-2 | WodModel.rawText nullable 차이 | 서버 required, 모바일 nullable |
| M-3 | wods 테이블 partial unique index | 설계대로 SQL 마이그레이션 미생성 |

---

## LOW Findings (8)

| # | Item | Design | Implementation |
|---|------|--------|----------------|
| L-1 | PROPOSAL_REVIEW route | `/proposal/review` | `/wod/proposal/review` |
| L-2 | Movement extra fields | 4 fields | 서버 8 fields |
| L-3 | ProgramData.notes | 설계에 없음 | 서버에 추가 |
| L-4 | WodSelectionModel.snapshotData | ProgramData (typed) | Map<String, dynamic> |
| L-5 | approve response fields | oldBaseWodId, newBaseWodId 포함 | `{ approved: true }` only |
| L-6 | WodModel.registeredBy | 서버 미전송 | 모바일에만 존재 |
| L-7 | WodModel.selectedCount | 서버 미전송 | 모바일에만 존재 |
| L-8 | Probe test files | 계획됨 | 미작성 |

---

## Score Breakdown

### Server (91%)

| Item | Weight | Score | Note |
|------|:------:|:-----:|------|
| API Endpoints (13/13) | 20 | 20 | 전체 구현 |
| DB Schema (5/5) | 15 | 13 | partial unique index 미구현 |
| Types | 10 | 8 | Movement 필드명 변경 |
| Business Logic (8/8) | 25 | 25 | 전체 구현 |
| Error Handling | 10 | 10 | |
| Tests (6/8) | 10 | 8 | probe 테스트 2개 누락 |
| Response Format | 10 | 7 | approve 응답 축소 |
| **Total** | **100** | **91** | |

### Mobile (82%)

| Item | Weight | Score | Note |
|------|:------:|:-----:|------|
| API Models (15/15) | 15 | 12 | 5개 모델 필드 차이 |
| API Clients (3/3) | 20 | 6 | 응답 파싱 전체 불일치, URL prefix |
| Repositories (4/4) | 10 | 10 | |
| Controllers (9/9) | 15 | 15 | |
| Views (9/9) | 15 | 15 | |
| Bindings (9/9) | 10 | 10 | |
| Routes (10/9) | 10 | 9 | 경로 차이 |
| Module Structure | 5 | 5 | |
| **Total** | **100** | **82** | |

### Fullstack Consistency (62%)

| Item | Weight | Score | Note |
|------|:------:|:-----:|------|
| API 호출-응답 파싱 정합성 | 40 | 5 | 13개 중 0개 정상 |
| Request 모델-Validator 정합성 | 15 | 12 | rawText nullable |
| Response 모델-Type 정합성 | 15 | 10 | Movement, comparisonResult |
| Endpoint 존재 정합성 | 15 | 10 | GET /wods/proposals 누락 |
| URL 경로 정합성 | 15 | 10 | /api/ prefix |
| **Total** | **100** | **47→62** | Dio baseUrl 보정 |

---

## Recommended Actions (Priority Order)

1. **C-1**: Mobile API Client 응답 파싱을 설계 문서대로 수정 (server response key 직접 사용)
2. **C-2**: Server에 GET /wods/proposals endpoint 추가
3. **C-3**: Server approve/reject에서 ProposalModel 반환하도록 수정
4. **C-4**: Server `weightUnit` → `unit`으로 통일 (설계 문서 기준)
5. **H-1**: Mobile API URL prefix `/api/` 제거 또는 서버 router 일치 확인
6. **H-2**: Mobile `RegisterWodRequest.rawText`를 `required String`으로 변경
