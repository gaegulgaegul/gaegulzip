# notice — 공지사항 SDK

## 개요

- **역할**: 공지사항 목록/상세 화면, API 통신, 읽지 않은 공지 배지를 제공하는 풀스택 UI SDK
- **사용처**: wowa 앱, design_system_demo 앱
- **독립성**: `core`, `design_system`에 의존. 앱별 `appCode`를 외부에서 주입받아 멀티테넌트 지원

## 연동 가이드

```dart
// 1. NoticeApiService 전역 등록 (main.dart)
Get.put<NoticeApiService>(NoticeApiService(), permanent: true);

// 2. 라우트 등록 (app_pages.dart)
GetPage(
  name: '/notice/list',
  page: () => const NoticeListView(),
  binding: NoticeBinding(appCode: 'wowa'),
),
GetPage(
  name: '/notice/detail',
  page: () => const NoticeDetailView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => NoticeDetailController(appCode: 'wowa'));
  }),
),

// 3. 읽지 않은 공지 배지 표시
UnreadNoticeBadge(appCode: 'wowa')
```

## Public API

| 클래스/함수 | 역할 | 사용 예 |
|------------|------|---------|
| `NoticeBinding` | 바인딩 (appCode 주입) | `NoticeBinding(appCode: 'wowa')` |
| `NoticeListView` | 공지사항 목록 화면 | 라우트에 등록 |
| `NoticeDetailView` | 공지사항 상세 화면 (Markdown 렌더링) | 라우트에 등록 |
| `NoticeListController` | 목록 상태 관리 (페이지네이션) | Binding에서 자동 생성 |
| `NoticeDetailController` | 상세 상태 관리 | Binding에서 자동 생성 |
| `NoticeApiService` | API 통신 (목록/상세/읽지않은수) | `Get.put()` 전역 등록 |
| `NoticeListCard` | 공지사항 카드 위젯 | 목록 뷰 내부 |
| `UnreadNoticeBadge` | 읽지 않은 공지 배지 | 앱바, 메뉴에서 사용 |
| `NoticeRoutes` | 라우트 경로 상수 | `NoticeRoutes.list`, `NoticeRoutes.detail` |
| `NoticeModel` | 공지사항 모델 (Freezed) | API 응답 |

## Configuration

`NoticeBinding` 생성자로 `appCode` 전달. 별도 설정 객체 없음.
`NoticeApiService`는 GetX DI에서 `Dio` 인스턴스를 자동 주입받음.

## Architecture

```
lib/
├── notice.dart                  # 배럴 파일
└── src/
    ├── bindings/                # NoticeBinding (appCode 주입)
    ├── controllers/             # NoticeListController, NoticeDetailController
    ├── models/                  # Freezed 모델 (NoticeModel, NoticeListResponse, UnreadCountResponse)
    ├── routes/                  # NoticeRoutes (경로 상수)
    ├── services/                # NoticeApiService (GET /notices, /notices/:id, /notices/unread-count)
    ├── views/                   # NoticeListView, NoticeDetailView
    └── widgets/                 # NoticeListCard, UnreadNoticeBadge
```

- Markdown 렌더링: `flutter_markdown` 사용 (상세 화면)
- URL 링크 클릭: `url_launcher` 사용
- 페이지네이션 지원 (page, limit 쿼리 파라미터)

## 확장/수정 시

1. API 엔드포인트 추가: `notice_api_service.dart`에 메서드 추가
2. 모델 수정: Freezed 파일 수정 후 `melos generate` 실행
3. 위젯 추가: `src/widgets/`에 파일 추가 후 `notice.dart`에 export

## 의존성

| 패키지 | 역할 |
|--------|------|
| `core` | Logger, 디자인 토큰 |
| `design_system` | UI 컴포넌트 |
| `dio` | HTTP 클라이언트 |
| `flutter_markdown` | Markdown 렌더링 |
| `url_launcher` | 외부 URL 열기 |
| `freezed_annotation` / `json_annotation` | 데이터 모델 |
