# WOWA MVP Mobile Work Plan

> Feature: wowa-mvp
> Created: 2026-02-04
> Platform: Mobile (Flutter/GetX)
> Prerequisites: Server API Phase 1-3 완료 필요

---

## 개요

이 문서는 Flutter Developer (Senior + Junior) 를 위한 WOWA MVP 모바일 구현 작업 분배 계획서입니다. **서버 API 완성 후 시작**합니다.

**작업 분배 전략**:
- **Senior Developer**: API 모델, 클라이언트, Controller (복잡한 비즈니스 로직)
- **Junior Developer**: Repository, View, Routing (정형화된 패턴)

**핵심 원칙**:
- GetX 패턴: Controller → Binding → View 분리
- const 최적화 (정적 위젯)
- Obx 범위 최소화 (변경되는 부분만)
- 에러 처리 완비 (NetworkException, BusinessException)
- 주석 한글 정책 (JSDoc 스타일)

**기존 인프라**:
- Design System 12개 위젯 완성 (packages/design_system)
- Core Package (DI, logging, exceptions) 완성 (packages/core)
- Login UI 완성 (apps/wowa/lib/app/modules/login/) — OAuth 연동은 Phase 5

---

## Phase 1: API 모델 & 클라이언트 (Senior)

**목적**: Freezed 모델 생성, Dio 클라이언트 구현, 코드 생성 실행

### 1.1 Box Models (Senior)

**파일**: `packages/api/lib/src/models/box/`

- [ ] `box_model.dart` — BoxModel (Freezed)
  - id, name, region, description, memberCount, joinedAt
- [ ] `create_box_request.dart` — CreateBoxRequest (Freezed)
  - name, region, description
- [ ] `box_member_model.dart` — BoxMemberModel (Freezed)
  - id, boxId, userId, role, joinedAt, user (nested UserModel)

### 1.2 WOD Models (Senior)

**파일**: `packages/api/lib/src/models/wod/`

- [ ] `movement.dart` — Movement (Freezed)
  - name, reps, weight, unit
- [ ] `program_data.dart` — ProgramData (Freezed)
  - type, timeCap, rounds, movements
- [ ] `wod_model.dart` — WodModel (Freezed)
  - id, boxId, date, programData, rawText, isBase, createdBy, registeredBy, selectedCount, createdAt
- [ ] `register_wod_request.dart` — RegisterWodRequest (Freezed)
  - boxId, date, programData, rawText
- [ ] `wod_list_response.dart` — WodListResponse (Freezed)
  - baseWod, personalWods

### 1.3 Proposal Models (Senior)

**파일**: `packages/api/lib/src/models/proposal/`

- [ ] `proposal_model.dart` — ProposalModel (Freezed)
  - id, baseWodId, proposedWodId, status, proposedAt, resolvedAt, resolvedBy

### 1.4 Selection Models (Senior)

**파일**: `packages/api/lib/src/models/selection/`

- [ ] `selection_model.dart` — WodSelectionModel (Freezed)
  - id, userId, wodId, boxId, date, snapshotData, createdAt

### 1.5 Code Generation (Senior)

**실행**:
```bash
cd /Users/lms/dev/repository/feature-wowa-mvp
melos generate
```

**생성되는 파일**:
- `*.freezed.dart` — Freezed 코드 생성
- `*.g.dart` — json_serializable 코드 생성

**검증**: 빌드 에러 없음 확인

---

## Phase 2: API Clients (Senior)

**목적**: Dio 클라이언트로 서버 API 호출

### 2.1 BoxApiClient (Senior)

**파일**: `packages/api/lib/src/clients/box_api_client.dart`

- [ ] getCurrentBox() — GET /boxes/me
- [ ] searchBoxes({name, region}) — GET /boxes/search
- [ ] createBox(CreateBoxRequest) — POST /boxes
- [ ] joinBox(boxId) — POST /boxes/:boxId/join
- [ ] getBoxById(boxId) — GET /boxes/:boxId
- [ ] getBoxMembers(boxId) — GET /boxes/:boxId/members

### 2.2 WodApiClient (Senior)

**파일**: `packages/api/lib/src/clients/wod_api_client.dart`

- [ ] registerWod(RegisterWodRequest) — POST /wods
- [ ] getWodsByDate({boxId, date}) — GET /wods/:boxId/:date
- [ ] selectWod({wodId, boxId, date}) — POST /wods/:wodId/select
- [ ] getSelections({startDate, endDate}) — GET /wods/selections

### 2.3 ProposalApiClient (Senior)

**파일**: `packages/api/lib/src/clients/proposal_api_client.dart`

- [ ] hasPendingProposal({baseWodId}) — GET /wods/proposals
- [ ] approveProposal({proposalId}) — POST /wods/proposals/:proposalId/approve
- [ ] rejectProposal({proposalId}) — POST /wods/proposals/:proposalId/reject

---

## Phase 3: Box Module (Senior Controller + Junior View)

**의존성**: BoxApiClient 완성 후 시작

### 3.1 BoxSearchController (Senior)

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_search_controller.dart`

#### 반응형 상태 (.obs)

- [ ] isLoading — 검색/가입 로딩 상태
- [ ] searchResults — 검색 결과 박스 목록
- [ ] currentBox — 현재 가입된 박스 (설정에서 진입 시)
- [ ] nameQuery — 박스 이름 검색어
- [ ] regionQuery — 박스 지역 검색어

#### 메서드

- [ ] onInit() — 초기화 (진입 경로에 따라 currentBox 설정)
- [ ] search() — 박스 검색 (debounce 300ms)
- [ ] joinBox(box) — 박스 가입 (기존 박스 자동 탈퇴 확인 모달)
- [ ] _showBoxChangeConfirmModal() — 박스 변경 확인 모달
- [ ] onClose() — TextEditingController 정리

### 3.2 BoxCreateController (Senior)

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_create_controller.dart`

#### 반응형 상태 (.obs)

- [ ] isLoading — 생성 중 로딩 상태
- [ ] nameError — 박스 이름 에러 메시지
- [ ] regionError — 박스 지역 에러 메시지
- [ ] canSubmit — 제출 가능 여부

#### 메서드

- [ ] onInit() — 초기화, 입력 유효성 검증 리스너 등록
- [ ] _validateInputs() — 입력 유효성 검증
- [ ] create() — 박스 생성 (+ 자동 가입)
- [ ] onClose() — TextEditingController 정리

### 3.3 BoxRepository (Junior)

**파일**: `apps/wowa/lib/app/data/repositories/box_repository.dart`

- [ ] getCurrentBox() — BoxApiClient.getCurrentBox() 호출, 에러 처리
- [ ] searchBoxes({name, region}) — BoxApiClient.searchBoxes() 호출, 에러 처리
- [ ] createBox({name, region, description}) — BoxApiClient.createBox() 호출, 에러 처리
- [ ] joinBox(boxId) — BoxApiClient.joinBox() 호출, 에러 처리

### 3.4 BoxSearchView (Junior)

**파일**: `apps/wowa/lib/app/modules/box/views/box_search_view.dart`

#### 위젯 구조

- [ ] AppBar (뒤로가기 버튼, 제목)
- [ ] _SearchInputs (이름 + 지역 검색 필드)
- [ ] _SearchResults (검색 결과 또는 안내)
  - 검색어 없음 → 안내 메시지
  - 검색 중 → CircularProgressIndicator
  - 결과 없음 → 안내 메시지
  - 결과 목록 → ListView.separated
- [ ] 신규 생성 버튼 (SketchButton)

### 3.5 BoxCreateView (Junior)

**파일**: `apps/wowa/lib/app/modules/box/views/box_create_view.dart`

#### 위젯 구조

- [ ] AppBar (뒤로가기 버튼, 제목)
- [ ] Form (SingleChildScrollView)
  - SketchInput (박스 이름)
  - SketchInput (지역)
  - SketchInput (설명, 선택)
  - SketchButton (생성하기, isLoading)

### 3.6 Box Bindings (Junior)

**파일**: `apps/wowa/lib/app/modules/box/bindings/`

- [ ] `box_search_binding.dart` — BoxSearchController 의존성 주입
- [ ] `box_create_binding.dart` — BoxCreateController 의존성 주입

---

## Phase 4: WOD Home (Senior Controller + Junior View)

**의존성**: WodApiClient 완성 후 시작

### 4.1 HomeController (Senior)

**파일**: `apps/wowa/lib/app/modules/wod/controllers/home_controller.dart`

#### 반응형 상태 (.obs)

- [ ] currentBox — 현재 가입된 박스
- [ ] selectedDate — 선택된 날짜 (기본값: 오늘)
- [ ] baseWod — Base WOD
- [ ] personalWods — Personal WODs
- [ ] isLoading — 로딩 상태
- [ ] hasWod — WOD 존재 여부
- [ ] unreadCount — 알림 개수 (Phase 5)

#### Computed Properties

- [ ] formattedDate — 날짜 포맷 (2026년 2월 4일)
- [ ] dayOfWeek — 요일 (화요일)
- [ ] isToday — 오늘 날짜 여부

#### 메서드

- [ ] onInit() — 현재 박스 조회 후 오늘의 WOD 조회
- [ ] _loadWodForDate(date) — 특정 날짜의 WOD 조회
- [ ] previousDay() — 이전 날짜로 이동
- [ ] nextDay() — 다음 날짜로 이동
- [ ] showDatePicker() — DatePicker 표시
- [ ] refresh() — Pull-to-refresh
- [ ] goToRegister() — WOD 등록 화면으로 이동
- [ ] goToDetail() — WOD 상세 화면으로 이동
- [ ] goToSelect() — WOD 선택 화면으로 이동

### 4.2 WodRepository (Junior)

**파일**: `apps/wowa/lib/app/data/repositories/wod_repository.dart`

- [ ] getWodsByDate({boxId, date}) — WodApiClient.getWodsByDate() 호출, 에러 처리
- [ ] registerWod(request) — WodApiClient.registerWod() 호출, 에러 처리
- [ ] selectWod({wodId, boxId, date}) — WodApiClient.selectWod() 호출, 에러 처리

### 4.3 HomeView (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/views/home_view.dart`

#### 위젯 구조

- [ ] AppBar (메뉴, 제목, 알림, 설정)
- [ ] RefreshIndicator (onRefresh: controller.refresh)
- [ ] _CurrentBoxHeader (박스 이름 + 지역)
- [ ] _DateHeader (날짜 표시 + 좌우 화살표)
- [ ] _WodCardSection (Base WOD + Personal WODs)
  - 로딩 → CircularProgressIndicator
  - WOD 없음 → Empty State
  - Base WOD 있음 → Base WOD 카드 + Personal WODs 요약
- [ ] _QuickActionButtons (등록/상세/선택 버튼)

### 4.4 Home Binding (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/bindings/home_binding.dart`

- [ ] HomeController 의존성 주입

---

## Phase 5: WOD Register (Senior Controller + Junior View)

**의존성**: WodApiClient 완성 후 시작

### 5.1 WodRegisterController (Senior)

**파일**: `apps/wowa/lib/app/modules/wod/controllers/wod_register_controller.dart`

#### 반응형 상태 (.obs)

- [ ] selectedType — WOD 타입 (AMRAP, ForTime 등)
- [ ] movements — 운동 목록 (List<MovementInput>)
- [ ] isLoading — 등록 중 로딩 상태
- [ ] canSubmit — 제출 가능 여부 (타입 + 운동 1개 이상)

#### 메서드

- [ ] onInit() — boxId, date 인자 받기
- [ ] selectType(type) — WOD 타입 선택
- [ ] addMovement() — 새 운동 추가
- [ ] removeMovement(id) — 운동 삭제
- [ ] reorderMovements(oldIndex, newIndex) — 운동 순서 변경
- [ ] submit() — WOD 등록 (RegisterWodRequest 생성)
- [ ] onClose() — TextEditingController 정리

### 5.2 WodRegisterView (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/views/wod_register_view.dart`

#### 위젯 구조

- [ ] AppBar (뒤로가기, 제목, 미리보기)
- [ ] Form (SingleChildScrollView)
  - _WodTypeSelector (Chip으로 타입 선택)
  - _TimeCapInput (시간 입력)
  - _MovementListBuilder (ReorderableListView)
    - _MovementCard (개별 운동 카드, 드래그 재배치)
  - SketchButton (등록하기, isLoading)

### 5.3 WodRegister Binding (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/bindings/wod_register_binding.dart`

- [ ] WodRegisterController 의존성 주입

---

## Phase 6: WOD Detail & Select (Senior Controller + Junior View)

**의존성**: ProposalApiClient 완성 후 시작

### 6.1 WodDetailController (Senior)

**파일**: `apps/wowa/lib/app/modules/wod/controllers/wod_detail_controller.dart`

#### 반응형 상태 (.obs)

- [ ] baseWod — Base WOD
- [ ] personalWods — Personal WODs
- [ ] isLoading — 로딩 상태
- [ ] hasPendingProposal — 변경 제안 대기 중 여부
- [ ] isBaseCreator — 현재 사용자가 Base 등록자인지

#### 메서드

- [ ] onInit() — boxId, date 인자 받기, WOD 조회
- [ ] _loadWods() — 날짜별 WOD 조회
- [ ] goToReview() — 변경 승인 화면으로 이동 (Base 등록자만)
- [ ] goToSelect() — WOD 선택 화면으로 이동
- [ ] goToRegister() — 새 WOD 등록 화면으로 이동

### 6.2 WodSelectController (Senior)

**파일**: `apps/wowa/lib/app/modules/wod/controllers/wod_select_controller.dart`

#### 반응형 상태 (.obs)

- [ ] baseWod — Base WOD
- [ ] personalWods — Personal WODs
- [ ] selectedWodId — 선택된 WOD ID
- [ ] isLoading — 선택 확정 로딩 상태

#### 메서드

- [ ] onInit() — boxId, date 인자 받기, WOD 조회
- [ ] selectWod(wodId) — WOD 선택 (라디오 버튼 효과)
- [ ] confirmSelection() — 최종 확인 모달 후 API 호출
- [ ] _showFinalConfirmModal() — 불변성 경고 모달

### 6.3 WodDetailView (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`

#### 위젯 구조

- [ ] AppBar (뒤로가기, 제목, 공유)
- [ ] SingleChildScrollView
  - _BaseWodCard (Base WOD 강조 표시)
  - 변경 제안 대기 중 배너 (조건부)
  - _PersonalWodsSection (Personal WODs 리스트)
    - _WodContentWidget (WOD 내용)
    - _DiffHighlight (차이점 강조)
  - _ActionButtons (WOD 선택, 새 WOD 등록)

### 6.4 WodSelectView (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`

#### 위젯 구조

- [ ] AppBar (뒤로가기, 제목)
- [ ] SingleChildScrollView
  - _WarningBanner (불변성 경고)
  - _WodOptionsList (Base + Personal WODs)
    - _WodOptionCard (선택 가능한 WOD 카드, 라디오 버튼)
  - _ConfirmButton (이 WOD로 기록하기, 잠금 아이콘)

### 6.5 WodDetail & WodSelect Bindings (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/bindings/`

- [ ] `wod_detail_binding.dart` — WodDetailController 의존성 주입
- [ ] `wod_select_binding.dart` — WodSelectController 의존성 주입

---

## Phase 7: Proposal Review (Senior Controller + Junior View)

**의존성**: ProposalApiClient 완성 후 시작

### 7.1 ProposalReviewController (Senior)

**파일**: `apps/wowa/lib/app/modules/wod/controllers/proposal_review_controller.dart`

#### 반응형 상태 (.obs)

- [ ] proposal — 변경 제안 정보
- [ ] currentBase — 현재 Base WOD
- [ ] proposedWod — 제안된 WOD
- [ ] proposer — 제안자 정보
- [ ] isLoading — 승인/거부 로딩 상태

#### 메서드

- [ ] onInit() — proposalId 인자 받기, 제안 정보 조회
- [ ] approve() — 승인 확인 모달 후 API 호출
- [ ] reject() — 거부 API 호출
- [ ] _showApproveConfirmModal() — 승인 확인 모달

### 7.2 ProposalReviewView (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`

#### 위젯 구조

- [ ] AppBar (뒤로가기, 제목)
- [ ] SingleChildScrollView
  - _ProposerInfo (제안자 정보)
  - _ComparisonView (Before/After 비교)
    - Before (현재 Base WOD)
    - Arrow
    - After (제안된 WOD + Diff)
  - _ApprovalButtons (승인/거부 버튼)

### 7.3 ProposalReview Binding (Junior)

**파일**: `apps/wowa/lib/app/modules/wod/bindings/proposal_review_binding.dart`

- [ ] ProposalReviewController 의존성 주입

---

## Phase 8: Routing & Navigation (Junior)

**의존성**: 모든 Controller와 View 완성 후 시작

### 8.1 Route Names 정의

**파일**: `apps/wowa/lib/app/routes/app_routes.dart`

- [ ] BOX_SEARCH = '/box/search'
- [ ] BOX_CREATE = '/box/create'
- [ ] HOME = '/home'
- [ ] WOD_REGISTER = '/wod/register'
- [ ] WOD_DETAIL = '/wod/detail'
- [ ] WOD_SELECT = '/wod/select'
- [ ] PROPOSAL_REVIEW = '/proposal/review'
- [ ] SETTINGS = '/settings' (Phase 9)

### 8.2 Route Definitions

**파일**: `apps/wowa/lib/app/routes/app_pages.dart`

- [ ] LOGIN (이미 완료, 확인만)
- [ ] BOX_SEARCH — BoxSearchView + BoxSearchBinding
- [ ] BOX_CREATE — BoxCreateView + BoxCreateBinding
- [ ] HOME — HomeView + HomeBinding
- [ ] WOD_REGISTER — WodRegisterView + WodRegisterBinding
- [ ] WOD_DETAIL — WodDetailView + WodDetailBinding
- [ ] WOD_SELECT — WodSelectView + WodSelectBinding
- [ ] PROPOSAL_REVIEW — ProposalReviewView + ProposalReviewBinding

### 8.3 Transition 설정

- [ ] 기본: Transition.fadeIn (300ms)
- [ ] 모달: Transition.downToUp (Register, Review)
- [ ] 설정: Transition.leftToRight

---

## Phase 9: Settings (Senior Controller + Junior View)

**우선순위**: P1 (MVP 이후)

### 9.1 SettingsController (Senior)

**파일**: `apps/wowa/lib/app/modules/settings/controllers/settings_controller.dart`

#### 반응형 상태 (.obs)

- [ ] currentBox — 현재 가입된 박스
- [ ] notificationEnabled — 알림 설정
- [ ] user — 사용자 정보

#### 메서드

- [ ] onInit() — 현재 박스, 사용자 정보 조회
- [ ] goToBoxChange() — 박스 변경 화면으로 이동
- [ ] toggleNotification() — 알림 설정 토글
- [ ] logout() — 로그아웃

### 9.2 SettingsView (Junior)

**파일**: `apps/wowa/lib/app/modules/settings/views/settings_view.dart`

#### 위젯 구조

- [ ] AppBar (뒤로가기, 제목)
- [ ] ListView
  - SketchCard (프로필 정보)
  - SketchCard (박스 변경 버튼)
  - SketchCard (알림 설정 스위치)
  - SketchButton (로그아웃)

### 9.3 Settings Binding (Junior)

**파일**: `apps/wowa/lib/app/modules/settings/bindings/settings_binding.dart`

- [ ] SettingsController 의존성 주입

---

## 검증 기준

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

## 작업 의존성

**Phase 1-2 (API 모델 & 클라이언트)**: Senior 독립 작업
↓
**Phase 3-9**: Senior (Controller) → Junior (Repository + View) 병렬 작업

**병렬 작업 패턴**:
1. Senior가 Controller 완성
2. Junior가 Controller 인터페이스를 기반으로 Repository + View 구현
3. Senior가 다음 Controller 시작

**예시**:
- Senior: BoxSearchController 완성 → BoxCreateController 시작
- Junior: BoxSearchView + BoxRepository 구현

---

## 체크리스트 요약

### Phase 1: API 모델 (Senior)
- [ ] 1.1 Box Models (3개 파일)
- [ ] 1.2 WOD Models (5개 파일)
- [ ] 1.3 Proposal Models (1개 파일)
- [ ] 1.4 Selection Models (1개 파일)
- [ ] 1.5 Code Generation (melos generate)

### Phase 2: API Clients (Senior)
- [ ] 2.1 BoxApiClient (6개 메서드)
- [ ] 2.2 WodApiClient (4개 메서드)
- [ ] 2.3 ProposalApiClient (3개 메서드)

### Phase 3: Box Module
- [ ] 3.1 BoxSearchController (Senior, 5개 상태 + 4개 메서드)
- [ ] 3.2 BoxCreateController (Senior, 4개 상태 + 3개 메서드)
- [ ] 3.3 BoxRepository (Junior, 4개 메서드)
- [ ] 3.4 BoxSearchView (Junior)
- [ ] 3.5 BoxCreateView (Junior)
- [ ] 3.6 Box Bindings (Junior, 2개 파일)

### Phase 4: WOD Home
- [ ] 4.1 HomeController (Senior, 8개 상태 + 10개 메서드)
- [ ] 4.2 WodRepository (Junior, 3개 메서드)
- [ ] 4.3 HomeView (Junior)
- [ ] 4.4 Home Binding (Junior)

### Phase 5: WOD Register
- [ ] 5.1 WodRegisterController (Senior, 4개 상태 + 7개 메서드)
- [ ] 5.2 WodRegisterView (Junior)
- [ ] 5.3 WodRegister Binding (Junior)

### Phase 6: WOD Detail & Select
- [ ] 6.1 WodDetailController (Senior, 5개 상태 + 5개 메서드)
- [ ] 6.2 WodSelectController (Senior, 4개 상태 + 4개 메서드)
- [ ] 6.3 WodDetailView (Junior)
- [ ] 6.4 WodSelectView (Junior)
- [ ] 6.5 WodDetail & WodSelect Bindings (Junior, 2개 파일)

### Phase 7: Proposal Review
- [ ] 7.1 ProposalReviewController (Senior, 5개 상태 + 4개 메서드)
- [ ] 7.2 ProposalReviewView (Junior)
- [ ] 7.3 ProposalReview Binding (Junior)

### Phase 8: Routing & Navigation
- [ ] 8.1 Route Names 정의 (Junior)
- [ ] 8.2 Route Definitions (Junior, 7개 라우트)
- [ ] 8.3 Transition 설정 (Junior)

### Phase 9: Settings (P1)
- [ ] 9.1 SettingsController (Senior, 3개 상태 + 4개 메서드)
- [ ] 9.2 SettingsView (Junior)
- [ ] 9.3 Settings Binding (Junior)

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

**작성일**: 2026-02-04
**버전**: 1.0.0
**상태**: Ready for Implementation

다음 단계:
1. Server API Phase 1-3 완료 대기
2. Senior Developer가 Phase 1-2 (API 모델 & 클라이언트) 시작
3. Senior + Junior 병렬 작업으로 Phase 3-9 진행
