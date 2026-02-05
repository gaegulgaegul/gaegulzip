# WOWA MVP Mobile Work Plan v2 (CTO 재분배)

> Feature: wowa-mvp
> Created: 2026-02-04
> Platform: Mobile (Flutter/GetX)
> Status: Ready for Parallel Execution
> Server Status: 100% Complete (192 tests PASS, 13 endpoints, 5 tables)

---

## 개요

서버 구현이 **100% 완료**되었으므로, 모바일 구현을 **최대한 병렬로** 진행합니다.

**핵심 전략**:
- Phase 1-2 (API 모델 & 클라이언트): 선행 작업 (병렬 가능)
- Phase 3-7 (각 모듈): API 인프라 완성 후 **모듈별 병렬 실행**
- Phase 8 (라우팅): 모든 View 완성 후
- Phase 9 (Settings): P1 우선순위, 별도 진행

**작업 분배 원칙**:
1. **모듈 독립성**: 각 flutter-developer는 독립적인 모듈 담당 (파일 충돌 없음)
2. **Controller → View 순서**: 동일 모듈 내에서는 Controller 완성 후 View/Binding 구현
3. **병렬성 극대화**: 서로 다른 모듈은 동시에 작업 가능
4. **의존성 최소화**: API 모델/클라이언트 완성 후 모든 모듈 동시 시작 가능

---

## 실행 그룹 요약

### Group 1: API 인프라 (병렬 3명 투입) — 선행 작업
**예상 소요 시간**: 2~3시간

| Developer | 작업 | 파일 수 | 설명 |
|-----------|------|--------|------|
| flutter-developer-1 | Box & WOD Models | 8개 | Freezed 모델 작성 + melos generate |
| flutter-developer-2 | Proposal & Selection Models | 2개 | Freezed 모델 작성 + melos generate |
| flutter-developer-3 | API Clients (Box/WOD/Proposal) | 3개 | Dio 클라이언트 구현 |

**Group 1 완료 조건**: `melos generate` 성공, `flutter analyze` 에러 없음

---

### Group 2: Core Modules — Controllers (병렬 5명 투입)
**의존성**: Group 1 완료 후 시작
**예상 소요 시간**: 4~5시간

| Developer | 모듈 | Controller 수 | 복잡도 |
|-----------|------|--------------|--------|
| flutter-developer-1 | Box Search & Create | 2개 | 중 (검색, 유효성 검증) |
| flutter-developer-2 | WOD Home | 1개 | 높음 (날짜 관리, 다중 상태) |
| flutter-developer-3 | WOD Register | 1개 | 높음 (동적 리스트, 드래그) |
| flutter-developer-4 | WOD Detail & Select | 2개 | 중 (Diff 비교, 선택 로직) |
| flutter-developer-5 | Proposal Review | 1개 | 중 (승인/거부 로직) |

**Group 2 완료 조건**: 모든 Controller 구현 완료, Repository 인터페이스 정의 완료

---

### Group 3: Views & Repositories (병렬 5명 투입)
**의존성**: Group 2 완료 후 시작
**예상 소요 시간**: 3~4시간

| Developer | 모듈 | 작업 내용 | 파일 수 |
|-----------|------|----------|--------|
| flutter-developer-1 | Box Module | Repository + 2 Views + 2 Bindings | 5개 |
| flutter-developer-2 | WOD Home | Repository + 1 View + 1 Binding | 3개 |
| flutter-developer-3 | WOD Register | 1 View + 1 Binding | 2개 |
| flutter-developer-4 | WOD Detail & Select | 2 Views + 2 Bindings | 4개 |
| flutter-developer-5 | Proposal Review | 1 View + 1 Binding | 2개 |

**Group 3 완료 조건**: 모든 View 렌더링 정상, Controller-View 연결 확인

---

### Group 4: Routing & Integration (1명 투입)
**의존성**: Group 3 완료 후 시작
**예상 소요 시간**: 1~2시간

| Developer | 작업 | 설명 |
|-----------|------|------|
| flutter-developer-1 | Routing 통합 | app_routes.dart, app_pages.dart 업데이트 |

**Group 4 완료 조건**: 모든 화면 네비게이션 정상, `flutter build apk --debug` 성공

---

### Group 5 (Optional): Settings Module (P1) — 별도 진행
**의존성**: 없음 (독립 모듈)
**예상 소요 시간**: 2~3시간

| Developer | 작업 | 설명 |
|-----------|------|------|
| flutter-developer-1 | Settings 전체 | Controller + View + Binding |

---

## Group 1 상세: API 인프라 (병렬 3명)

### flutter-developer-1: Box & WOD Models

#### 구현할 파일 (8개)

**Box Models** (`packages/api/lib/src/models/box/`)
1. `box_model.dart` — BoxModel (Freezed, json_serializable)
   - id, name, region, description, memberCount, joinedAt
2. `create_box_request.dart` — CreateBoxRequest (Freezed, json_serializable)
   - name, region, description
3. `box_member_model.dart` — BoxMemberModel (Freezed, json_serializable)
   - id, boxId, userId, role, joinedAt, user (nested UserModel)

**WOD Models** (`packages/api/lib/src/models/wod/`)
4. `movement.dart` — Movement (Freezed, json_serializable)
   - name, reps, weight, unit
5. `program_data.dart` — ProgramData (Freezed, json_serializable)
   - type, timeCap, rounds, movements
6. `wod_model.dart` — WodModel (Freezed, json_serializable)
   - id, boxId, date, programData, rawText, isBase, createdBy, registeredBy, selectedCount, createdAt
7. `register_wod_request.dart` — RegisterWodRequest (Freezed, json_serializable)
   - boxId, date, programData, rawText
8. `wod_list_response.dart` — WodListResponse (Freezed, json_serializable)
   - baseWod, personalWods

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (Line 610~731)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/server-brief.md` (API 응답 스키마)

#### 기존 코드 패턴 참조
- Auth 모델 패턴 (있다면): `packages/api/lib/src/models/auth/`
- Freezed + json_serializable 사용법

#### 완료 조건
- [ ] 8개 파일 작성 완료
- [ ] `melos generate` 실행 (*.freezed.dart, *.g.dart 생성)
- [ ] `flutter analyze` 에러 없음
- [ ] 모든 모델에 한글 JSDoc 주석 추가

---

### flutter-developer-2: Proposal & Selection Models

#### 구현할 파일 (2개)

**Proposal Models** (`packages/api/lib/src/models/proposal/`)
1. `proposal_model.dart` — ProposalModel (Freezed, json_serializable)
   - id, baseWodId, proposedWodId, status, proposedAt, resolvedAt, resolvedBy

**Selection Models** (`packages/api/lib/src/models/selection/`)
2. `selection_model.dart` — WodSelectionModel (Freezed, json_serializable)
   - id, userId, wodId, boxId, date, snapshotData, createdAt

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (API 모델 설계)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/server-brief.md` (API 응답 스키마)

#### 완료 조건
- [ ] 2개 파일 작성 완료
- [ ] `melos generate` 실행
- [ ] `flutter analyze` 에러 없음

---

### flutter-developer-3: API Clients (Box/WOD/Proposal)

#### 구현할 파일 (3개)

**API Clients** (`packages/api/lib/src/clients/`)
1. `box_api_client.dart` — BoxApiClient (Dio)
   - getCurrentBox(), searchBoxes(), createBox(), joinBox(), getBoxById(), getBoxMembers()
2. `wod_api_client.dart` — WodApiClient (Dio)
   - registerWod(), getWodsByDate(), selectWod(), getSelections()
3. `proposal_api_client.dart` — ProposalApiClient (Dio)
   - hasPendingProposal(), approveProposal(), rejectProposal()

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (Line 735~855)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/server-brief.md` (API 엔드포인트 명세)

#### 서버 API 엔드포인트 (참조)
**Box Endpoints**:
- GET `/boxes/me` — 현재 박스 조회
- GET `/boxes/search?name=&region=` — 박스 검색
- POST `/boxes` — 박스 생성
- POST `/boxes/:boxId/join` — 박스 가입
- GET `/boxes/:boxId` — 박스 상세
- GET `/boxes/:boxId/members` — 박스 멤버 조회

**WOD Endpoints**:
- POST `/wods` — WOD 등록
- GET `/wods/:boxId/:date` — 날짜별 WOD 조회
- POST `/wods/:wodId/select` — WOD 선택
- GET `/wods/selections?startDate=&endDate=` — 선택 기록 조회

**Proposal Endpoints**:
- GET `/wods/proposals?baseWodId=&status=pending` — 대기 중인 제안 확인
- POST `/wods/proposals/:proposalId/approve` — 제안 승인
- POST `/wods/proposals/:proposalId/reject` — 제안 거부

#### 완료 조건
- [ ] 3개 클라이언트 구현 완료
- [ ] Dio 에러 처리 (DioException → NetworkException/BusinessException)
- [ ] `flutter analyze` 에러 없음
- [ ] 모든 메서드에 한글 JSDoc 주석

---

## Group 2 상세: Core Modules — Controllers (병렬 5명)

### flutter-developer-1: Box Search & Create Controllers

#### 구현할 파일 (2개)

**Controllers** (`apps/wowa/lib/app/modules/box/controllers/`)
1. `box_search_controller.dart` — BoxSearchController (GetxController)
   - 반응형 상태: isLoading, searchResults, currentBox, nameQuery, regionQuery
   - 메서드: onInit(), search(), joinBox(), _showBoxChangeConfirmModal(), onClose()
2. `box_create_controller.dart` — BoxCreateController (GetxController)
   - 반응형 상태: isLoading, nameError, regionError, canSubmit
   - 메서드: onInit(), _validateInputs(), create(), onClose()

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (Line 86~407)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 56~310)

#### 기존 코드 패턴 참조
- `/Users/lms/dev/repository/feature-wowa-mvp/apps/mobile/apps/wowa/lib/app/modules/login/controllers/login_controller.dart`

#### Repository 인터페이스 정의 (Group 3에서 구현)
- `BoxRepository`: getCurrentBox(), searchBoxes(), createBox(), joinBox()

#### 완료 조건
- [ ] 2개 Controller 구현 완료
- [ ] .obs 변수 정확히 정의
- [ ] debounce 300ms 적용 (search 메서드)
- [ ] 에러 처리 (NetworkException, BusinessException)
- [ ] 한글 JSDoc 주석

---

### flutter-developer-2: WOD Home Controller

#### 구현할 파일 (1개)

**Controller** (`apps/wowa/lib/app/modules/wod/controllers/`)
1. `home_controller.dart` — HomeController (GetxController)
   - 반응형 상태: currentBox, selectedDate, baseWod, personalWods, isLoading, hasWod, unreadCount
   - Computed Properties: formattedDate, dayOfWeek, isToday
   - 메서드: onInit(), _loadInitialData(), _loadWodForDate(), previousDay(), nextDay(), showDatePicker(), refresh(), goToRegister(), goToDetail(), goToSelect()

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (Line 409~601)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 312~602)

#### Repository 인터페이스 정의
- `BoxRepository`: getCurrentBox()
- `WodRepository`: getWodsByDate()

#### 완료 조건
- [ ] HomeController 구현 완료
- [ ] 날짜 관리 로직 (selectedDate, 좌우 화살표)
- [ ] WodListResponse → baseWod + personalWods 매핑
- [ ] Pull-to-refresh 지원
- [ ] 한글 JSDoc 주석

---

### flutter-developer-3: WOD Register Controller

#### 구현할 파일 (1개)

**Controller** (`apps/wowa/lib/app/modules/wod/controllers/`)
1. `wod_register_controller.dart` — WodRegisterController (GetxController)
   - 반응형 상태: selectedType, movements (List<MovementInput>), isLoading, canSubmit
   - 메서드: onInit(), selectType(), addMovement(), removeMovement(), reorderMovements(), submit(), onClose()

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 604~793)

#### Repository 인터페이스 정의
- `WodRepository`: registerWod(RegisterWodRequest)

#### 완료 조건
- [ ] WodRegisterController 구현 완료
- [ ] 동적 운동 리스트 관리 (add, remove, reorder)
- [ ] 유효성 검증 (타입 + 운동 1개 이상)
- [ ] RegisterWodRequest 생성 로직
- [ ] 한글 JSDoc 주석

---

### flutter-developer-4: WOD Detail & Select Controllers

#### 구현할 파일 (2개)

**Controllers** (`apps/wowa/lib/app/modules/wod/controllers/`)
1. `wod_detail_controller.dart` — WodDetailController (GetxController)
   - 반응형 상태: baseWod, personalWods, isLoading, hasPendingProposal, isBaseCreator
   - 메서드: onInit(), _loadWods(), goToReview(), goToSelect(), goToRegister()
2. `wod_select_controller.dart` — WodSelectController (GetxController)
   - 반응형 상태: baseWod, personalWods, selectedWodId, isLoading
   - 메서드: onInit(), selectWod(), confirmSelection(), _showFinalConfirmModal()

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 795~1274)

#### Repository 인터페이스 정의
- `WodRepository`: getWodsByDate(), selectWod()
- `ProposalRepository`: hasPendingProposal()

#### 완료 조건
- [ ] 2개 Controller 구현 완료
- [ ] Diff 비교 로직 (Base vs Personal)
- [ ] 최종 확인 모달 로직
- [ ] 한글 JSDoc 주석

---

### flutter-developer-5: Proposal Review Controller

#### 구현할 파일 (1개)

**Controller** (`apps/wowa/lib/app/modules/wod/controllers/`)
1. `proposal_review_controller.dart` — ProposalReviewController (GetxController)
   - 반응형 상태: proposal, currentBase, proposedWod, proposer, isLoading
   - 메서드: onInit(), approve(), reject(), _showApproveConfirmModal()

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 1276~1481)

#### Repository 인터페이스 정의
- `ProposalRepository`: approveProposal(), rejectProposal()

#### 완료 조건
- [ ] ProposalReviewController 구현 완료
- [ ] Before/After 비교 로직
- [ ] 승인 확인 모달 로직
- [ ] 한글 JSDoc 주석

---

## Group 3 상세: Views & Repositories (병렬 5명)

### flutter-developer-1: Box Module (Repository + Views + Bindings)

#### 구현할 파일 (5개)

**Repository** (`apps/wowa/lib/app/data/repositories/`)
1. `box_repository.dart` — BoxRepository
   - getCurrentBox(), searchBoxes(), createBox(), joinBox()
   - DioException → NetworkException/BusinessException 변환

**Views** (`apps/wowa/lib/app/modules/box/views/`)
2. `box_search_view.dart` — BoxSearchView (GetView<BoxSearchController>)
   - _SearchInputs, _SearchResults (4가지 상태), 신규 생성 버튼
3. `box_create_view.dart` — BoxCreateView (GetView<BoxCreateController>)
   - Form (이름, 지역, 설명), 생성 버튼

**Bindings** (`apps/wowa/lib/app/modules/box/bindings/`)
4. `box_search_binding.dart` — BoxSearchBinding
5. `box_create_binding.dart` — BoxCreateBinding

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (Line 862~946)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 56~310)

#### 기존 코드 패턴 참조
- `/Users/lms/dev/repository/feature-wowa-mvp/apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`
- Design System 위젯: SketchInput, SketchCard, SketchButton

#### 완료 조건
- [ ] BoxRepository 구현 (에러 처리 완비)
- [ ] 2개 View 렌더링 정상
- [ ] Controller-View 연결 확인 (Obx 범위 최소화)
- [ ] const 최적화
- [ ] 한글 주석

---

### flutter-developer-2: WOD Home (Repository + View + Binding)

#### 구현할 파일 (3개)

**Repository** (`apps/wowa/lib/app/data/repositories/`)
1. `wod_repository.dart` — WodRepository
   - getWodsByDate(), registerWod(), selectWod()

**View** (`apps/wowa/lib/app/modules/wod/views/`)
2. `home_view.dart` — HomeView (GetView<HomeController>)
   - _CurrentBoxHeader, _DateHeader, _WodCardSection (3가지 상태), _QuickActionButtons

**Binding** (`apps/wowa/lib/app/modules/wod/bindings/`)
3. `home_binding.dart` — HomeBinding

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (Line 248~256)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 312~602)

#### 완료 조건
- [ ] WodRepository 구현
- [ ] HomeView 렌더링 정상
- [ ] RefreshIndicator 작동
- [ ] 날짜 헤더 (좌우 화살표, DatePicker)
- [ ] const 최적화

---

### flutter-developer-3: WOD Register (View + Binding)

#### 구현할 파일 (2개)

**View** (`apps/wowa/lib/app/modules/wod/views/`)
1. `wod_register_view.dart` — WodRegisterView (GetView<WodRegisterController>)
   - _WodTypeSelector, _TimeCapInput, _MovementListBuilder, _MovementCard (드래그 재배치)

**Binding** (`apps/wowa/lib/app/modules/wod/bindings/`)
2. `wod_register_binding.dart` — WodRegisterBinding

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 604~793)

#### 완료 조건
- [ ] WodRegisterView 렌더링 정상
- [ ] ReorderableListView 작동 (운동 순서 변경)
- [ ] SketchChip (타입 선택)
- [ ] const 최적화

---

### flutter-developer-4: WOD Detail & Select (Views + Bindings)

#### 구현할 파일 (4개)

**Views** (`apps/wowa/lib/app/modules/wod/views/`)
1. `wod_detail_view.dart` — WodDetailView (GetView<WodDetailController>)
   - _BaseWodCard, _PersonalWodsSection, _WodContentWidget, _DiffHighlight
2. `wod_select_view.dart` — WodSelectView (GetView<WodSelectController>)
   - _WarningBanner, _WodOptionsList, _WodOptionCard (라디오 버튼), _ConfirmButton

**Bindings** (`apps/wowa/lib/app/modules/wod/bindings/`)
3. `wod_detail_binding.dart` — WodDetailBinding
4. `wod_select_binding.dart` — WodSelectBinding

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 795~1274)

#### 완료 조건
- [ ] 2개 View 렌더링 정상
- [ ] Diff 하이라이트 표시 (Base vs Personal)
- [ ] 최종 확인 모달 작동
- [ ] const 최적화

---

### flutter-developer-5: Proposal Review (View + Binding)

#### 구현할 파일 (2개)

**Repository** (`apps/wowa/lib/app/data/repositories/`)
1. `proposal_repository.dart` — ProposalRepository
   - hasPendingProposal(), approveProposal(), rejectProposal()

**View** (`apps/wowa/lib/app/modules/wod/views/`)
2. `proposal_review_view.dart` — ProposalReviewView (GetView<ProposalReviewController>)
   - _ProposerInfo, _ComparisonView (Before/After), _ApprovalButtons

**Binding** (`apps/wowa/lib/app/modules/wod/bindings/`)
3. `proposal_review_binding.dart` — ProposalReviewBinding

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 1276~1481)

#### 완료 조건
- [ ] ProposalRepository 구현
- [ ] ProposalReviewView 렌더링 정상
- [ ] Before/After 비교 UI
- [ ] 승인/거부 버튼 작동
- [ ] const 최적화

---

## Group 4 상세: Routing & Integration (1명)

### flutter-developer-1: Routing 통합

#### 구현할 파일 (2개)

**Routes** (`apps/wowa/lib/app/routes/`)
1. `app_routes.dart` — Route Names 정의
   - BOX_SEARCH, BOX_CREATE, HOME, WOD_REGISTER, WOD_DETAIL, WOD_SELECT, PROPOSAL_REVIEW, SETTINGS
2. `app_pages.dart` — Route Definitions
   - GetPage 설정 (name, page, binding, transition)

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md` (Line 963~1065)
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 1790~1823)

#### Transition 설정
- 기본: `Transition.fadeIn` (300ms)
- 모달 (Register, Review): `Transition.downToUp`
- 설정: `Transition.leftToRight`

#### 완료 조건
- [ ] 8개 라우트 정의 완료
- [ ] 모든 화면 네비게이션 정상 (Get.toNamed, Get.offAllNamed)
- [ ] Arguments 전달 정상 (boxId, date, proposalId)
- [ ] `flutter analyze` 에러 없음

---

## Group 5 상세 (Optional): Settings Module (P1)

### flutter-developer-1: Settings 전체

#### 구현할 파일 (3개)

**Controller** (`apps/wowa/lib/app/modules/settings/controllers/`)
1. `settings_controller.dart` — SettingsController
   - currentBox, notificationEnabled, user
   - goToBoxChange(), toggleNotification(), logout()

**View** (`apps/wowa/lib/app/modules/settings/views/`)
2. `settings_view.dart` — SettingsView
   - 프로필 카드, 박스 변경 버튼, 알림 설정 스위치, 로그아웃 버튼

**Binding** (`apps/wowa/lib/app/modules/settings/bindings/`)
3. `settings_binding.dart` — SettingsBinding

#### 참조 설계 문서
- `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md` (Line 1483~1504)

#### 완료 조건
- [ ] 3개 파일 구현 완료
- [ ] 박스 변경 → BoxSearchView 연결
- [ ] `flutter analyze` 에러 없음

---

## 전체 검증 기준

### 코드 품질
- [ ] GetX 패턴 준수 (Controller, View, Binding 분리)
- [ ] 반응형 상태 정확히 정의 (.obs)
- [ ] const 최적화 적용 (정적 위젯)
- [ ] Obx 범위 최소화 (변경되는 부분만)
- [ ] 에러 처리 완비 (NetworkException, BusinessException)

### 라우팅
- [ ] Named routes 정확히 설정
- [ ] Arguments 전달 정확히 처리
- [ ] Transition 적절히 설정

### CLAUDE.md 표준
- [ ] 주석 한글 정책 (JSDoc 스타일)
- [ ] import 패턴 준수
- [ ] 디렉토리 구조 준수

### 빌드 & 분석
```bash
cd apps/mobile/apps/wowa
flutter analyze
flutter build apk --debug
```

- [ ] flutter analyze 에러 없음
- [ ] 빌드 성공

---

## 작업 의존성 다이어그램

```
Group 1 (API 인프라) — 병렬 3명
  ├── flutter-developer-1: Box & WOD Models
  ├── flutter-developer-2: Proposal & Selection Models
  └── flutter-developer-3: API Clients
       ↓
Group 2 (Controllers) — 병렬 5명
  ├── flutter-developer-1: Box Search & Create Controllers
  ├── flutter-developer-2: WOD Home Controller
  ├── flutter-developer-3: WOD Register Controller
  ├── flutter-developer-4: WOD Detail & Select Controllers
  └── flutter-developer-5: Proposal Review Controller
       ↓
Group 3 (Views & Repositories) — 병렬 5명
  ├── flutter-developer-1: Box Module (Repository + 2 Views + 2 Bindings)
  ├── flutter-developer-2: WOD Home (Repository + 1 View + 1 Binding)
  ├── flutter-developer-3: WOD Register (1 View + 1 Binding)
  ├── flutter-developer-4: WOD Detail & Select (2 Views + 2 Bindings)
  └── flutter-developer-5: Proposal Review (Repository + 1 View + 1 Binding)
       ↓
Group 4 (Routing) — 1명
  └── flutter-developer-1: app_routes.dart, app_pages.dart

Group 5 (Settings, P1) — 독립 실행, 1명
  └── flutter-developer-1: Settings 전체 (Controller + View + Binding)
```

---

## 예상 소요 시간

| Group | 인원 | 예상 시간 | 누적 시간 |
|-------|------|----------|----------|
| Group 1 | 3명 | 2~3시간 | 3시간 |
| Group 2 | 5명 | 4~5시간 | 8시간 |
| Group 3 | 5명 | 3~4시간 | 12시간 |
| Group 4 | 1명 | 1~2시간 | 14시간 |
| **Total** | **최대 5명 동시** | **약 2일** | **14시간** |

**Settings (P1)**: 별도 2~3시간 (독립 진행 가능)

---

## 참고 자료

### Mobile Guides
- **Mobile CLAUDE.md**: `apps/mobile/CLAUDE.md`
- **Directory Structure**: `.claude/guide/mobile/directory_structure.md`
- **GetX Best Practices**: `.claude/guide/mobile/getx_best_practices.md`
- **Flutter Best Practices**: `.claude/guide/mobile/flutter_best_practices.md`
- **Design System**: `.claude/guide/mobile/design_system.md`
- **Common Patterns**: `.claude/guide/mobile/common_patterns.md`
- **Error Handling**: `.claude/guide/mobile/error_handling.md`
- **Performance**: `.claude/guide/mobile/performance.md`

### Design Documents
- **Mobile Brief**: `docs/wowa/mvp/mobile-brief.md`
- **Mobile Design Spec**: `docs/wowa/mvp/mobile-design-spec.md`
- **Plan**: `docs/wowa/mvp/plan.md`

### Catalog
- **Mobile Catalog**: `docs/wowa/mobile-catalog.md` (재사용 가능한 모듈)

---

## Task 도구 호출 예시 (CTO → flutter-developer)

### Group 1 실행 예시

```
Task(
  subagent_type="flutter-developer",
  prompt="""
You are a Flutter Developer working on WOWA MVP.

## 작업 범위
Group 1: API 인프라 — Box & WOD Models

## 구현할 파일 (8개)
1. packages/api/lib/src/models/box/box_model.dart
2. packages/api/lib/src/models/box/create_box_request.dart
3. packages/api/lib/src/models/box/box_member_model.dart
4. packages/api/lib/src/models/wod/movement.dart
5. packages/api/lib/src/models/wod/program_data.dart
6. packages/api/lib/src/models/wod/wod_model.dart
7. packages/api/lib/src/models/wod/register_wod_request.dart
8. packages/api/lib/src/models/wod/wod_list_response.dart

## 필수 포함 사항
- Freezed + json_serializable 사용
- 한글 JSDoc 주석 (클래스, 필드)
- 모든 필드 nullable 여부 정확히 지정

## 참조 문서
- /Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-brief.md (Line 610~731)
- /Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/server-brief.md

## 완료 후 실행
cd /Users/lms/dev/repository/feature-wowa-mvp
melos generate
flutter analyze

## 완료 조건
- [ ] 8개 파일 작성 완료
- [ ] melos generate 성공 (*.freezed.dart, *.g.dart 생성)
- [ ] flutter analyze 에러 없음
  """
)
```

---

**작성일**: 2026-02-04
**버전**: 2.0.0
**상태**: Ready for Execution

다음 단계:
1. CTO가 Group 1의 3개 Task 동시 실행 (병렬)
2. Group 1 완료 확인 후 Group 2 실행
3. Group 3, 4 순차 진행
4. 최종 통합 리뷰 (CTO)
