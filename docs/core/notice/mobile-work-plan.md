# 모바일 작업 분배 계획: 공지사항 (Notice SDK)

## 개요

공지사항 SDK 패키지의 모바일 구현을 위한 작업 분배 계획입니다. GetX 패턴(Controller/View/Binding)과 Freezed 데이터 모델을 활용하여 재사용 가능한 패키지로 설계합니다.

**Feature**: notice
**Platform**: Mobile (Flutter)
**Package**: packages/notice/

---

## 실행 그룹 (Execution Groups)

### Group 1 (병렬) — 선행 작업 (Server API 비의존)

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| flutter-developer | models | Freezed 데이터 모델 정의 | models/notice_model.dart, notice_list_response.dart, unread_count_response.dart |
| flutter-developer | widgets | 재사용 위젯 구현 | widgets/notice_list_card.dart, unread_notice_badge.dart |
| flutter-developer | routes | 라우트 이름 정의 | routes/notice_routes.dart |

**병렬 실행 가능 이유**:
- Server API 없이도 구현 가능 (모델은 서버 명세 기반)
- 위젯은 독립적 (API 데이터 mock으로 테스트 가능)
- 라우트는 문자열 상수만 정의

**Server API 의존성**: ❌ 없음

---

### Group 2 (순차) — Group 1 완료 후, Server API 완료 후

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| flutter-developer | api-service | API 클라이언트 구현 (Dio 기반) | services/notice_api_service.dart |

**순차 실행 이유**:
- Server API 엔드포인트 필요 (실제 HTTP 호출)
- Group 1의 models에 의존 (응답 파싱)

**Server API 의존성**: ✅ 필수 (Server Group 2 완료 후)

---

### Group 3 (병렬) — Group 2 완료 후

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| flutter-developer | list-controller | 목록 컨트롤러 구현 | controllers/notice_list_controller.dart |
| flutter-developer | detail-controller | 상세 컨트롤러 구현 | controllers/notice_detail_controller.dart |

**병렬 실행 가능 이유**:
- 두 컨트롤러는 독립적 (서로 다른 화면 관리)
- 동일한 API Service 의존 (Get.find로 주입)

**Server API 의존성**: ✅ 필수 (API Service 완료 필수)

---

### Group 4 (병렬) — Group 3 완료 후

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| flutter-developer | list-view | 목록 화면 UI 구현 | views/notice_list_view.dart |
| flutter-developer | detail-view | 상세 화면 UI 구현 | views/notice_detail_view.dart |

**병렬 실행 가능 이유**:
- 두 화면은 독립적
- 각각 자신의 컨트롤러만 사용 (GetView)

**Server API 의존성**: ✅ 필수 (Controller → API Service 의존)

---

### Group 5 (순차) — Group 4 완료 후

| Agent | Module | 설명 | 파일 |
|-------|--------|------|------|
| flutter-developer | barrel-export | public API export 정리 | lib/notice.dart |
| flutter-developer | readme | 사용 가이드 작성 | README.md |

**순차 실행 이유**:
- 모든 구현 완료 후 export 정리
- README는 전체 API 확정 후 작성

**Server API 의존성**: ✅ 필수 (전체 기능 동작 필요)

---

## 크로스 플랫폼 의존성 분석 (Server ↔ Mobile)

### Server API 완료 전 Mobile 작업 (병렬 가능)

✅ **Group 1 전체**:
- Freezed 모델: 서버 API 명세 기반 (docs/core/notice/server-brief.md)
- 위젯: 독립적 UI 컴포넌트 (mock 데이터로 렌더링 테스트)
- 라우트: 문자열 상수만 정의

### Server API 완료 후 Mobile 작업 (순차 진행)

❌ **Group 2~5**:
- API Service: 실제 서버 엔드포인트 호출 필요
- Controller: API Service 의존
- View: Controller 의존

### 실행 순서 (Server ↔ Mobile 동기화)

```
Server Group 1 (schema, validators, types, probe) ║ Mobile Group 1 (models, widgets, routes)
                    ↓                                ║              (병렬 실행 가능)
Server Group 2 (handlers, router)                   ║
                    ↓                                ║
                [Server API 완료]                    ║
                    ↓                                ║
                    ╠════════════════════════════════╣
                    ↓                                ↓
                                          Mobile Group 2 (api-service)
                                                     ↓
                                          Mobile Group 3 (controllers)
                                                     ↓
                                          Mobile Group 4 (views)
                                                     ↓
                                          Mobile Group 5 (barrel, readme)
```

---

## 모듈 간 의존성 그래프

```
Group 1 (병렬, Server API 비의존)
├── models/*.dart (독립, 서버 명세 기반)
├── widgets/*.dart (독립, UI만)
└── routes/notice_routes.dart (독립, 문자열 상수)
    ↓
Group 2 (순차, Server API 완료 후)
└── services/notice_api_service.dart (← models, Server API)
    ↓
Group 3 (병렬)
├── controllers/notice_list_controller.dart (← api_service)
└── controllers/notice_detail_controller.dart (← api_service)
    ↓
Group 4 (병렬)
├── views/notice_list_view.dart (← list_controller, widgets)
└── views/notice_detail_view.dart (← detail_controller)
    ↓
Group 5 (순차)
├── lib/notice.dart (← 모든 public API)
└── README.md (← 전체 사용법)
```

---

## 작업 상세 (Task Details)

### Group 1: models (flutter-developer)

**목표**: Freezed 데이터 모델 정의

**파일**:
- `lib/src/models/notice_model.dart`
- `lib/src/models/notice_list_response.dart`
- `lib/src/models/unread_count_response.dart`

**작업 내용**:
1. NoticeModel:
   - @freezed 어노테이션
   - fromJson/toJson factory
   - 필드: id, title, content (nullable), category (nullable), isPinned, isRead, viewCount, createdAt, updatedAt (nullable)
2. NoticeListResponse:
   - items (List<NoticeModel>)
   - totalCount, page, limit, hasNext
3. UnreadCountResponse:
   - unreadCount

**코드 생성**:
```bash
cd packages/notice
flutter pub run build_runner build --delete-conflicting-outputs
```

**검증**:
- *.freezed.dart, *.g.dart 생성 확인
- fromJson/toJson 동작 확인 (단위 테스트 X, 컴파일만)

**참조 문서**:
- docs/core/notice/mobile-brief.md (Freezed 모델 명세)
- docs/core/notice/server-brief.md (API 응답 형식)

---

### Group 1: widgets (flutter-developer)

**목표**: 재사용 가능한 위젯 구현

**파일**:
- `lib/src/widgets/notice_list_card.dart`
- `lib/src/widgets/unread_notice_badge.dart`

**작업 내용**:

#### NoticeListCard
- Props: NoticeModel, onTap
- SketchCard 기반
- 읽지 않은 공지: 빨간 점, 굵은 글씨, 연한 오렌지 배경
- 고정 공지: 핀 아이콘
- 카테고리 태그 (SketchChip)
- 메타 정보: 조회수, 작성일

#### UnreadNoticeBadge
- Props: unreadCount, child
- Stack으로 뱃지 위치 조정
- 99+ 표시
- 빨간색 배경, 흰색 테두리

**검증**:
- 위젯 렌더링 확인 (독립적으로 테스트 가능)
- design_system 패키지 import 성공

**참조 문서**:
- docs/core/notice/mobile-design-spec.md (위젯 명세)
- .claude/guide/mobile/flutter_best_practices.md

---

### Group 1: routes (flutter-developer)

**목표**: 라우트 이름 정의

**파일**: `lib/src/routes/notice_routes.dart`

**작업 내용**:
```dart
abstract class NoticeRoutes {
  static const list = '/notice/list';
  static const detail = '/notice/detail';
}
```

**검증**:
- 컴파일 성공

**참조 문서**:
- docs/core/notice/mobile-brief.md (라우팅 설계)

---

### Group 2: api-service (flutter-developer)

**목표**: Dio 기반 API 클라이언트 구현

**파일**: `lib/src/services/notice_api_service.dart`

**작업 내용**:
1. getNotices() — GET /notices (페이지네이션, 필터링)
2. getNoticeDetail(int id) — GET /notices/:id
3. getUnreadCount() — GET /notices/unread-count

**Dio 인스턴스**:
- Get.find<Dio>() (api 패키지에서 제공)

**응답 파싱**:
- NoticeListResponse.fromJson()
- NoticeModel.fromJson()
- UnreadCountResponse.fromJson()

**에러 처리**:
- DioException catch
- 404, 5xx 구분 안 함 (Controller에서 처리)

**검증**:
- Server API 엔드포인트 호출 성공
- 응답 파싱 성공

**Server API 의존**:
- ✅ Server Group 2 (handlers.ts, router) 완료 필수

**참조 문서**:
- docs/core/notice/mobile-brief.md (API Service 명세)
- docs/core/notice/server-brief.md (API 엔드포인트)

---

### Group 3: list-controller (flutter-developer)

**목표**: 목록 화면 상태 관리

**파일**: `lib/src/controllers/notice_list_controller.dart`

**작업 내용**:
1. 상태 변수:
   - notices (.obs)
   - pinnedNotices (.obs)
   - isLoading, isLoadingMore, errorMessage (.obs)
   - hasMore (.obs)
   - _currentPage (int)
2. 메서드:
   - fetchNotices() — 초기 로드
   - refreshNotices() — Pull to Refresh
   - loadMoreNotices() — 무한 스크롤
   - markAsRead(int id) — 읽음 상태 업데이트

**비즈니스 로직**:
- 고정 공지와 일반 공지 분리 조회
- 페이지네이션 (page, limit)
- hasMore 플래그 관리

**에러 처리**:
- DioException: errorMessage.value 업데이트
- Get.snackbar로 사용자 알림

**검증**:
- API Service 호출 성공
- 무한 스크롤 동작 확인

**Server API 의존**:
- ✅ API Service 완료 필수

**참조 문서**:
- docs/core/notice/mobile-brief.md (Controller 명세)
- .claude/guide/mobile/getx_best_practices.md

---

### Group 3: detail-controller (flutter-developer)

**목표**: 상세 화면 상태 관리

**파일**: `lib/src/controllers/notice_detail_controller.dart`

**작업 내용**:
1. 상태 변수:
   - notice (Rxn<NoticeModel>)
   - isLoading, errorMessage (.obs)
   - noticeId (int, Get.arguments)
2. 메서드:
   - fetchNoticeDetail() — 상세 조회

**비즈니스 로직**:
- Get.arguments로 noticeId 전달
- 404 에러: "삭제되었거나 존재하지 않는 공지사항"
- 목록 컨트롤러 연동: markAsRead() 호출

**에러 처리**:
- 404 분리 처리
- Get.snackbar로 알림

**검증**:
- 상세 조회 성공
- 읽음 처리 API 자동 호출 (서버에서 처리)

**Server API 의존**:
- ✅ API Service 완료 필수

**참조 문서**:
- docs/core/notice/mobile-brief.md (Controller 명세)

---

### Group 4: list-view (flutter-developer)

**목표**: 목록 화면 UI 구현

**파일**: `lib/src/views/notice_list_view.dart`

**작업 내용**:
1. Scaffold + AppBar (제목, 새로고침 버튼)
2. RefreshIndicator (Pull to Refresh)
3. CustomScrollView:
   - 고정 공지 섹션 (조건부 렌더링)
   - 구분선 (Divider)
   - 일반 공지 목록 (SliverList)
   - 무한 스크롤 로딩 인디케이터
4. 상태별 UI:
   - 로딩: CircularProgressIndicator + 메시지
   - 에러: Icon + 에러 메시지 + 재시도 버튼
   - 빈 상태: Icon + "아직 등록된 공지사항이 없습니다"

**위젯 활용**:
- NoticeListCard (widgets/)
- SketchButton (design_system)

**네비게이션**:
- Get.toNamed(NoticeRoutes.detail, arguments: noticeId)

**검증**:
- 고정/일반 공지 구분 표시
- 무한 스크롤 동작
- Pull to Refresh 동작

**참조 문서**:
- docs/core/notice/mobile-design-spec.md (UI 명세)
- .claude/guide/mobile/flutter_best_practices.md

---

### Group 4: detail-view (flutter-developer)

**목표**: 상세 화면 UI 구현

**파일**: `lib/src/views/notice_detail_view.dart`

**작업 내용**:
1. Scaffold + AppBar (뒤로가기)
2. SingleChildScrollView:
   - 헤더 (고정 태그, 제목, 카테고리)
   - 메타 정보 (조회수, 작성일시)
   - 구분선 (Divider)
   - 마크다운 본문 (MarkdownBody)
3. 상태별 UI:
   - 로딩: CircularProgressIndicator + 메시지
   - 에러: Icon + 에러 메시지 + "목록으로" 버튼

**마크다운 렌더링**:
- flutter_markdown 패키지
- MarkdownStyleSheet 커스텀 (색상, 폰트, 코드 블록 스타일)
- onTapLink: url_launcher로 브라우저 열기

**검증**:
- 마크다운 렌더링 확인
- 링크 클릭 동작

**참조 문서**:
- docs/core/notice/mobile-design-spec.md (UI 명세)
- .claude/guide/mobile/flutter_best_practices.md

---

### Group 5: barrel-export (flutter-developer)

**목표**: public API export 정리

**파일**: `lib/notice.dart`

**작업 내용**:
```dart
library notice;

// Models
export 'src/models/notice_model.dart';
export 'src/models/notice_list_response.dart';
export 'src/models/unread_count_response.dart';

// Services
export 'src/services/notice_api_service.dart';

// Controllers
export 'src/controllers/notice_list_controller.dart';
export 'src/controllers/notice_detail_controller.dart';

// Views
export 'src/views/notice_list_view.dart';
export 'src/views/notice_detail_view.dart';

// Widgets
export 'src/widgets/notice_list_card.dart';
export 'src/widgets/unread_notice_badge.dart';

// Routes
export 'src/routes/notice_routes.dart';
```

**검증**:
- wowa 앱에서 `import 'package:notice/notice.dart';` 성공

**참조 문서**:
- docs/core/notice/mobile-brief.md (패키지 구조)

---

### Group 5: readme (flutter-developer)

**목표**: 사용 가이드 작성

**파일**: `packages/notice/README.md`

**작업 내용**:
1. 패키지 개요
2. 설치 방법 (pubspec.yaml 의존성)
3. 앱 통합 가이드:
   - Dio 설정
   - NoticeApiService 등록
   - 라우트 등록
   - UnreadNoticeBadge 사용
4. API 문서 (public exports)
5. 예시 코드

**참조 문서**:
- docs/core/notice/mobile-brief.md (앱 통합 가이드)

---

## 작업 순서 요약

1. **Server Group 1~2 완료 대기**: Server API 엔드포인트 준비
2. **Mobile Group 1 시작**: 3명의 flutter-developer를 동시에 투입하여 models, widgets, routes 병렬 작업 (Server API 비의존)
3. **Mobile Group 1 완료 확인**: Freezed 코드 생성, 위젯 렌더링 확인
4. **Server Group 2 완료 확인**: Server API 동작 확인 (Postman/Insomnia)
5. **Mobile Group 2 시작**: api-service 구현 (Server API 호출)
6. **Mobile Group 2 완료 확인**: API 응답 파싱 성공
7. **Mobile Group 3 시작**: 2명의 flutter-developer가 list-controller, detail-controller 병렬 작업
8. **Mobile Group 3 완료 확인**: Controller 비즈니스 로직 동작
9. **Mobile Group 4 시작**: 2명의 flutter-developer가 list-view, detail-view 병렬 작업
10. **Mobile Group 4 완료 확인**: 화면 렌더링 성공, 네비게이션 동작
11. **Mobile Group 5 시작**: barrel-export → README 순차 작업
12. **Mobile Group 5 완료 확인**: wowa 앱 통합 성공, `flutter analyze` 통과

---

## 공통 원칙 (모든 Agent 준수)

### GetX 패턴

- Controller: 비즈니스 로직, 상태 관리 (.obs)
- View: GetView<Controller>, UI만 담당
- Binding: 라우트 레벨에서 Get.lazyPut

### Freezed 모델

- @freezed 어노테이션
- fromJson/toJson factory
- copyWith() 활용한 불변 업데이트

### const 최적화

- 모든 StatelessWidget에 const 생성자
- 정적 위젯은 const로 선언

### Obx 범위 최소화

- 필요한 부분만 Obx로 감싸기
- 전체 화면 rebuild 방지

### 주석 정책

- 한국어 주석 (/// Dart doc)
- 복잡한 로직은 상세 주석

### 에러 처리

- Controller 레벨: errorMessage.value 업데이트
- View 레벨: 에러 상태 UI 표시
- Get.snackbar로 사용자 알림

### 디자인 시스템 활용

- SketchCard, SketchButton, SketchChip (design_system)
- SketchDesignTokens (색상, 간격, 폰트)

---

## 의존성 설정

**파일**: `packages/notice/pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../core
  api:
    path: ../api
  design_system:
    path: ../design_system
  get: ^4.6.6
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  flutter_markdown: ^0.6.18
  url_launcher: ^6.2.5

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

---

## 코드 생성

```bash
cd packages/notice
flutter pub run build_runner build --delete-conflicting-outputs
```

또는 melos:

```bash
melos generate
```

---

## 검증 기준 (CTO 통합 리뷰)

- [ ] `flutter analyze` 통과 (0 issues)
- [ ] Freezed 코드 생성 성공 (*.freezed.dart, *.g.dart)
- [ ] API Service 호출 성공 (Server API 연동)
- [ ] Controller 비즈니스 로직 동작 (무한 스크롤, 읽음 처리)
- [ ] View UI 렌더링 성공 (목록, 상세)
- [ ] 마크다운 렌더링 확인
- [ ] 라우팅 동작 확인 (목록 → 상세 → 뒤로가기)
- [ ] 에러 상태 UI 표시 (네트워크 오류, 404)
- [ ] wowa 앱 통합 성공 (`import 'package:notice/notice.dart';`)
- [ ] UnreadNoticeBadge 동작 확인
- [ ] const 최적화 확인 (flutter analyze warnings 없음)
- [ ] Obx 범위 최소화 확인

---

## 참고 문서

- **사용자 스토리**: docs/core/notice/user-story.md
- **디자인 명세**: docs/core/notice/mobile-design-spec.md
- **모바일 설계**: docs/core/notice/mobile-brief.md
- **서버 API 명세**: docs/core/notice/server-brief.md
- **GetX 가이드**: .claude/guide/mobile/getx_best_practices.md
- **Flutter 가이드**: .claude/guide/mobile/flutter_best_practices.md
- **디자인 토큰**: .claude/guide/mobile/design-tokens.json
- **모바일 CLAUDE.md**: apps/mobile/CLAUDE.md

---

## 다음 단계

1. CTO가 work-plan 검토 및 승인
2. Server Group 1~2 완료 대기
3. Mobile Group 1 시작 (병렬, Server API 비의존)
4. Server API 완료 확인
5. Mobile Group 2~5 순차 진행
6. CTO 통합 리뷰 (mobile-cto-review.md 작성)
7. Independent Reviewer 최종 검증
