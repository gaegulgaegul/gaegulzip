# Notice SDK 연동 가이드

공지사항 기능을 앱에 통합하기 위한 Flutter SDK 패키지입니다.
목록/상세 화면, 읽음 처리, 무한 스크롤, 고정 공지 분리를 제공합니다.

## 의존성 구조

```
core (DI, 로깅, extensions)
  ↑
  api (Dio 클라이언트, HTTP 인터셉터)
  ↑
  notice ← design_system (SketchCard, SketchChip, SketchButton)
```

## 연동 절차

### 1. pubspec.yaml에 의존성 추가

```yaml
# apps/wowa/pubspec.yaml
dependencies:
  notice:
    path: ../../packages/notice
```

```bash
melos bootstrap
```

### 2. Freezed 코드 생성

```bash
cd apps/mobile/packages/notice
flutter pub run build_runner build --delete-conflicting-outputs
```

또는 Melos 사용:

```bash
melos generate
```

### 3. NoticeApiService 등록

`NoticeApiService`는 내부에서 `Get.find<Dio>()`로 Dio 인스턴스를 가져옵니다.
Dio가 먼저 등록되어 있어야 합니다.

```dart
// app_binding.dart 또는 main.dart
import 'package:notice/notice.dart';

Get.put<NoticeApiService>(NoticeApiService(), permanent: true);
```

### 4. GetX 라우트 등록

```dart
// app_pages.dart
import 'package:notice/notice.dart';

class AppPages {
  static final routes = [
    // ... 기존 라우트

    // 공지사항 목록
    GetPage(
      name: NoticeRoutes.list,       // '/notice/list'
      page: () => const NoticeListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NoticeListController());
      }),
    ),

    // 공지사항 상세
    GetPage(
      name: NoticeRoutes.detail,     // '/notice/detail'
      page: () => const NoticeDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NoticeDetailController());
      }),
    ),
  ];
}
```

### 5. 네비게이션

```dart
// 목록 화면으로 이동
Get.toNamed(NoticeRoutes.list);

// 상세 화면으로 이동 (noticeId를 arguments로 전달)
Get.toNamed(NoticeRoutes.detail, arguments: noticeId);
```

> **주의**: 상세 화면은 `Get.arguments as int`로 ID를 추출합니다.
> 반드시 `int` 타입의 noticeId를 arguments로 전달해야 합니다.

## 읽지 않은 공지 뱃지 (선택)

앱바 등에 읽지 않은 공지 개수를 표시하려면 `UnreadNoticeBadge` 위젯을 사용합니다.

### 뱃지 컨트롤러 구현

SDK에는 뱃지용 컨트롤러가 포함되지 않으므로, 앱 측에서 구현합니다:

```dart
class UnreadCountController extends GetxController {
  final _apiService = Get.find<NoticeApiService>();
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.getUnreadCount();
      unreadCount.value = response.unreadCount;
    } catch (_) {
      // 비치명적 — 실패 시 0 유지
    }
  }
}
```

### 뱃지 위젯 사용

```dart
Obx(() {
  final count = Get.find<UnreadCountController>().unreadCount.value;
  return UnreadNoticeBadge(
    unreadCount: count,
    child: IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () => Get.toNamed(NoticeRoutes.list),
    ),
  );
})
```

뱃지는 99 초과 시 `99+`로 표시되며, 0이면 숨겨집니다.

## API Reference

### Models

| 클래스 | 용도 | 주요 필드 |
|--------|------|----------|
| `NoticeModel` | 공지사항 데이터 | `id`, `title`, `content?`, `category?`, `isPinned`, `isRead`, `viewCount`, `createdAt`, `updatedAt?` |
| `NoticeListResponse` | 목록 응답 래퍼 | `items`, `totalCount`, `page`, `limit`, `hasNext` |
| `UnreadCountResponse` | 읽지 않은 개수 | `unreadCount` |

### Services

**`NoticeApiService`** — 서버 API 호출 (내부에서 `Get.find<Dio>()` 사용)

| 메서드 | 엔드포인트 | 반환 |
|--------|-----------|------|
| `getNotices({page, limit, category?, pinnedOnly?})` | `GET /notices` | `NoticeListResponse` |
| `getNoticeDetail(int id)` | `GET /notices/:id` | `NoticeModel` |
| `getUnreadCount()` | `GET /notices/unread-count` | `UnreadCountResponse` |

### Controllers

| 클래스 | 역할 | Observable 상태 |
|--------|------|----------------|
| `NoticeListController` | 목록 + 무한 스크롤 | `notices`, `pinnedNotices`, `isLoading`, `isLoadingMore`, `hasMore`, `errorMessage` |
| `NoticeDetailController` | 상세 조회 + 읽음 동기화 | `notice`, `isLoading`, `errorMessage` |

**NoticeListController 주요 메서드:**

| 메서드 | 용도 |
|--------|------|
| `fetchNotices()` | 초기 로드 (고정 + 일반 공지) |
| `refreshNotices()` | Pull to Refresh |
| `loadMoreNotices()` | 무한 스크롤 다음 페이지 |
| `markAsRead(int noticeId)` | 읽음 상태 UI 반영 |

### Views

| 클래스 | 화면 |
|--------|------|
| `NoticeListView` | 목록 화면 (고정 공지 분리, 무한 스크롤) |
| `NoticeDetailView` | 상세 화면 (마크다운 렌더링) |

### Widgets

| 클래스 | 용도 | Props |
|--------|------|-------|
| `NoticeListCard` | 목록 카드 | `notice: NoticeModel`, `onTap: VoidCallback` |
| `UnreadNoticeBadge` | 읽지 않은 개수 뱃지 | `unreadCount: int`, `child: Widget` |

### Routes

| 상수 | 값 |
|------|---|
| `NoticeRoutes.list` | `'/notice/list'` |
| `NoticeRoutes.detail` | `'/notice/detail'` |

## 동작 흐름

### 목록 → 상세 → 읽음 처리

```
1. NoticeListView 진입
   → NoticeListController.fetchNotices()
   → 고정 공지 (pinnedOnly: true) + 일반 공지 조회

2. 카드 탭
   → Get.toNamed(NoticeRoutes.detail, arguments: noticeId)

3. NoticeDetailView 진입
   → NoticeDetailController.fetchNoticeDetail()
   → 서버: viewCount +1, notice_reads INSERT (자동)
   → NoticeListController.markAsRead(noticeId) (목록 UI 즉시 반영)

4. 뒤로 가기
   → 목록에서 해당 카드가 읽음 상태로 표시됨
```

### 무한 스크롤

```
스크롤 하단 도달
  → loadMoreNotices()
  → hasMore == true → 다음 페이지 요청
  → hasMore == false → 중단
```

## 서버 API 요구사항

이 SDK는 다음 서버 엔드포인트를 필요로 합니다:

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| GET | `/notices` | JWT | 목록 (page, limit, category, pinnedOnly) |
| GET | `/notices/:id` | JWT | 상세 (viewCount 자동 증가, 읽음 자동 처리) |
| GET | `/notices/unread-count` | JWT | 읽지 않은 공지 개수 |

JWT 토큰은 Dio 인터셉터에서 `Authorization: Bearer {token}` 형태로 자동 주입됩니다.

## Troubleshooting

| 증상 | 원인 | 해결 |
|------|------|------|
| `NoticeApiService` not found | DI 미등록 | `Get.put<NoticeApiService>(...)` 확인 |
| `Dio` not found | api 패키지 초기화 안 됨 | `Get.put<Dio>(...)` 먼저 등록 |
| 상세 화면 타입 에러 | arguments에 int 미전달 | `Get.toNamed(route, arguments: noticeId)` 확인 |
| `.freezed.dart` 파일 없음 | 코드 생성 안 됨 | `melos generate` 실행 |
| Import 에러 | 의존성 미설치 | `melos bootstrap` 실행 |
