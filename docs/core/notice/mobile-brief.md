# 모바일 기술 아키텍처: 공지사항 (Notice SDK)

## 개요

공지사항 SDK 패키지의 모바일 기술 아키텍처입니다. 모든 앱(wowa 등)에서 재사용 가능한 독립 패키지로 설계하며, 사용자 조회 기능만 포함합니다.

**핵심 설계 전략**:
- SDK 패키지 (`packages/notice/`) 구조
- Freezed 데이터 모델로 불변 객체 보장
- GetX Controller로 상태 관리 및 페이지네이션
- Dio 기반 API Service 계층
- Design System 활용한 일관된 UI
- 앱 레벨 통합 가이드 제공

---

## 패키지 구조 (packages/notice/)

### 디렉토리 트리

```
packages/notice/
├── lib/
│   ├── notice.dart                      # barrel export (public API)
│   └── src/
│       ├── models/                      # Freezed 데이터 모델
│       │   ├── notice_model.dart
│       │   ├── notice_model.freezed.dart (generated)
│       │   ├── notice_model.g.dart (generated)
│       │   ├── notice_list_response.dart
│       │   ├── notice_list_response.freezed.dart (generated)
│       │   └── notice_list_response.g.dart (generated)
│       │
│       ├── services/                    # API 호출 계층
│       │   └── notice_api_service.dart
│       │
│       ├── controllers/                 # GetX 상태 관리
│       │   ├── notice_list_controller.dart
│       │   └── notice_detail_controller.dart
│       │
│       ├── views/                       # 재사용 가능한 화면 위젯
│       │   ├── notice_list_view.dart
│       │   └── notice_detail_view.dart
│       │
│       └── widgets/                     # 공지사항 전용 위젯
│           ├── notice_list_card.dart
│           └── unread_notice_badge.dart
│
├── pubspec.yaml                         # 패키지 설정
└── README.md                            # 사용 가이드
```

### 파일별 역할

| 파일 | 역할 | 핵심 기능 |
|------|------|----------|
| `models/notice_model.dart` | Notice 데이터 클래스 | Freezed + json_serializable |
| `models/notice_list_response.dart` | 목록 응답 래퍼 | 페이지네이션 메타 포함 |
| `services/notice_api_service.dart` | API 클라이언트 | Dio 기반 HTTP 호출 |
| `controllers/notice_list_controller.dart` | 목록 화면 상태 관리 | 무한 스크롤, 새로고침 |
| `controllers/notice_detail_controller.dart` | 상세 화면 상태 관리 | 조회, 읽음 처리 |
| `views/notice_list_view.dart` | 목록 화면 UI | 고정/일반 공지 렌더링 |
| `views/notice_detail_view.dart` | 상세 화면 UI | 마크다운 렌더링 |
| `widgets/notice_list_card.dart` | 목록 카드 위젯 | 재사용 가능 |
| `widgets/unread_notice_badge.dart` | 뱃지 위젯 | 읽지 않은 개수 표시 |

---

## 의존성 그래프

### 패키지 간 관계

```
core (foundation: GetX, logger, extensions)
  ↑
  ├── api (Dio, HTTP client, base models)
  │   ↑
  │   └── notice (Notice 모델, API Service)
  │       ↑
  │       └── design_system (SketchCard, SketchButton, SketchChip)
  │           ↑
  │           └── wowa (앱, Notice SDK 통합)
```

### pubspec.yaml 의존성 설정

```yaml
# packages/notice/pubspec.yaml
name: notice
description: Notice SDK package - reusable across all apps
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # 내부 패키지
  core:
    path: ../core
  api:
    path: ../api
  design_system:
    path: ../design_system

  # GetX (core에서 제공하지만 명시적 의존성)
  get: ^4.6.6

  # Freezed (불변 객체)
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # 마크다운 렌더링
  flutter_markdown: ^0.6.18

  # URL 실행 (마크다운 내 링크)
  url_launcher: ^6.2.5

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

---

## Freezed 데이터 모델 정의

### Notice Model

**파일**: `packages/notice/lib/src/models/notice_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notice_model.freezed.dart';
part 'notice_model.g.dart';

/// 공지사항 데이터 모델
///
/// 서버 API 응답을 파싱하여 불변 객체로 관리합니다.
@freezed
class NoticeModel with _$NoticeModel {
  const factory NoticeModel({
    /// 공지사항 ID
    required int id,

    /// 제목
    required String title,

    /// 본문 (마크다운 형식, 상세 조회 시에만 포함)
    String? content,

    /// 카테고리 (업데이트, 점검, 이벤트 등)
    String? category,

    /// 상단 고정 여부
    required bool isPinned,

    /// 읽음 여부 (현재 사용자 기준)
    @Default(false) bool isRead,

    /// 조회수
    required int viewCount,

    /// 작성일시
    required DateTime createdAt,

    /// 수정일시 (상세 조회 시에만 포함)
    DateTime? updatedAt,
  }) = _NoticeModel;

  /// JSON 역직렬화
  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);
}
```

**설계 근거**:
- `content`: 목록 조회에서는 null, 상세 조회에서만 포함 (트래픽 최적화)
- `isRead`: 클라이언트 표시용 (서버 JOIN 결과 반영)
- `@Default(false)`: Freezed 기본값 지정
- `DateTime`: ISO-8601 문자열 자동 파싱 (json_serializable)

### NoticeListResponse Model

**파일**: `packages/notice/lib/src/models/notice_list_response.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'notice_model.dart';

part 'notice_list_response.freezed.dart';
part 'notice_list_response.g.dart';

/// 공지사항 목록 응답 래퍼
///
/// 페이지네이션 메타 정보를 포함합니다.
@freezed
class NoticeListResponse with _$NoticeListResponse {
  const factory NoticeListResponse({
    /// 공지사항 목록
    required List<NoticeModel> items,

    /// 전체 개수
    required int totalCount,

    /// 현재 페이지
    required int page,

    /// 페이지 크기
    required int limit,

    /// 다음 페이지 존재 여부
    required bool hasNext,
  }) = _NoticeListResponse;

  /// JSON 역직렬화
  factory NoticeListResponse.fromJson(Map<String, dynamic> json) =>
      _$NoticeListResponseFromJson(json);
}
```

### UnreadCountResponse Model

**파일**: `packages/notice/lib/src/models/unread_count_response.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unread_count_response.freezed.dart';
part 'unread_count_response.g.dart';

/// 읽지 않은 공지 개수 응답
@freezed
class UnreadCountResponse with _$UnreadCountResponse {
  const factory UnreadCountResponse({
    /// 읽지 않은 개수
    required int unreadCount,
  }) = _UnreadCountResponse;

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
}
```

---

## API Service 클래스 (Dio 기반)

### NoticeApiService

**파일**: `packages/notice/lib/src/services/notice_api_service.dart`

```dart
import 'package:api/api.dart'; // Dio 인스턴스
import 'package:get/get.dart';
import '../models/notice_model.dart';
import '../models/notice_list_response.dart';
import '../models/unread_count_response.dart';

/// 공지사항 API 서비스
///
/// 서버 API와의 HTTP 통신을 담당합니다.
class NoticeApiService {
  /// Dio 인스턴스 (api 패키지에서 제공)
  final Dio _dio = Get.find<Dio>();

  /// 공지사항 목록 조회
  ///
  /// [page]: 페이지 번호 (기본: 1)
  /// [limit]: 페이지 크기 (기본: 20)
  /// [category]: 카테고리 필터 (선택)
  /// [pinnedOnly]: 고정 공지만 조회 (선택)
  Future<NoticeListResponse> getNotices({
    int page = 1,
    int limit = 20,
    String? category,
    bool? pinnedOnly,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (category != null) {
      queryParameters['category'] = category;
    }
    if (pinnedOnly != null) {
      queryParameters['pinnedOnly'] = pinnedOnly;
    }

    final response = await _dio.get(
      '/notices',
      queryParameters: queryParameters,
    );

    return NoticeListResponse.fromJson(response.data);
  }

  /// 공지사항 상세 조회
  ///
  /// [id]: 공지사항 ID
  Future<NoticeModel> getNoticeDetail(int id) async {
    final response = await _dio.get('/notices/$id');

    return NoticeModel.fromJson(response.data);
  }

  /// 읽지 않은 공지 개수 조회
  Future<UnreadCountResponse> getUnreadCount() async {
    final response = await _dio.get('/notices/unread-count');

    return UnreadCountResponse.fromJson(response.data);
  }
}
```

**설계 근거**:
- Dio는 `api` 패키지에서 제공하는 인스턴스 사용 (Get.find)
- 서버 API 엔드포인트와 1:1 매핑
- 쿼리 파라미터는 선택적 Named Parameter로 처리
- 응답은 Freezed 모델로 파싱

---

## GetX Controller 설계

### NoticeListController

**파일**: `packages/notice/lib/src/controllers/notice_list_controller.dart`

```dart
import 'package:get/get.dart';
import '../models/notice_model.dart';
import '../services/notice_api_service.dart';

/// 공지사항 목록 화면 컨트롤러
///
/// 무한 스크롤 페이지네이션을 지원합니다.
class NoticeListController extends GetxController {
  /// API 서비스
  late final NoticeApiService _apiService;

  /// 공지사항 목록
  final notices = <NoticeModel>[].obs;

  /// 고정 공지사항 목록 (상단 표시용)
  final pinnedNotices = <NoticeModel>[].obs;

  /// 로딩 상태
  final isLoading = false.obs;

  /// 더 많은 데이터 로딩 중 (무한 스크롤)
  final isLoadingMore = false.obs;

  /// 에러 메시지
  final errorMessage = ''.obs;

  /// 다음 페이지 존재 여부
  final hasMore = true.obs;

  /// 현재 페이지
  int _currentPage = 1;

  /// 페이지 크기
  final int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<NoticeApiService>();
    fetchNotices();
  }

  /// 공지사항 목록 조회 (초기 로드)
  Future<void> fetchNotices() async {
    isLoading.value = true;
    errorMessage.value = '';
    _currentPage = 1;

    try {
      // 고정 공지사항 조회
      final pinnedResponse = await _apiService.getNotices(
        page: 1,
        limit: 100, // 고정 공지는 최대 100개로 제한
        pinnedOnly: true,
      );
      pinnedNotices.value = pinnedResponse.items;

      // 일반 공지사항 조회
      final response = await _apiService.getNotices(
        page: _currentPage,
        limit: _pageSize,
      );

      notices.value = response.items;
      hasMore.value = response.hasNext;
    } on DioException catch (e) {
      errorMessage.value = e.message ?? '네트워크 오류가 발생했습니다';
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = '예상치 못한 오류가 발생했습니다';
      Get.snackbar('오류', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// 새로고침 (Pull to Refresh)
  Future<void> refreshNotices() async {
    _currentPage = 1;
    await fetchNotices();
  }

  /// 다음 페이지 로드 (무한 스크롤)
  Future<void> loadMoreNotices() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      _currentPage++;
      final response = await _apiService.getNotices(
        page: _currentPage,
        limit: _pageSize,
      );

      notices.addAll(response.items);
      hasMore.value = response.hasNext;
    } on DioException catch (e) {
      Get.snackbar(
        '오류',
        e.message ?? '추가 데이터를 불러오는 중 오류가 발생했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 특정 공지사항 읽음 처리 (목록에서 UI 업데이트)
  void markAsRead(int noticeId) {
    // 일반 목록에서 업데이트
    final index = notices.indexWhere((n) => n.id == noticeId);
    if (index != -1) {
      notices[index] = notices[index].copyWith(isRead: true);
    }

    // 고정 목록에서 업데이트
    final pinnedIndex = pinnedNotices.indexWhere((n) => n.id == noticeId);
    if (pinnedIndex != -1) {
      pinnedNotices[pinnedIndex] =
          pinnedNotices[pinnedIndex].copyWith(isRead: true);
    }
  }
}
```

**설계 근거**:
- 고정 공지와 일반 공지를 별도 리스트로 관리 (UI 구분 표시)
- 무한 스크롤: `loadMoreNotices()` 메서드로 다음 페이지 자동 로드
- `markAsRead()`: 상세 화면에서 읽음 처리 후 목록 UI 업데이트
- 에러 처리: DioException 분리, 사용자 친화적 메시지

### NoticeDetailController

**파일**: `packages/notice/lib/src/controllers/notice_detail_controller.dart`

```dart
import 'package:get/get.dart';
import '../models/notice_model.dart';
import '../services/notice_api_service.dart';
import 'notice_list_controller.dart';

/// 공지사항 상세 화면 컨트롤러
class NoticeDetailController extends GetxController {
  /// API 서비스
  late final NoticeApiService _apiService;

  /// 공지사항 상세 데이터
  final notice = Rxn<NoticeModel>();

  /// 로딩 상태
  final isLoading = false.obs;

  /// 에러 메시지
  final errorMessage = ''.obs;

  /// 공지사항 ID (route argument)
  late final int noticeId;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<NoticeApiService>();

    // Get.arguments로 전달된 ID 추출
    noticeId = Get.arguments as int;

    fetchNoticeDetail();
  }

  /// 공지사항 상세 조회
  Future<void> fetchNoticeDetail() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiService.getNoticeDetail(noticeId);
      notice.value = response;

      // 목록 컨트롤러에 읽음 상태 반영 (있을 경우만)
      if (Get.isRegistered<NoticeListController>()) {
        Get.find<NoticeListController>().markAsRead(noticeId);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        errorMessage.value = '삭제되었거나 존재하지 않는 공지사항입니다';
      } else {
        errorMessage.value = e.message ?? '네트워크 오류가 발생했습니다';
      }
      Get.snackbar(
        '오류',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = '예상치 못한 오류가 발생했습니다';
      Get.snackbar('오류', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
```

**설계 근거**:
- `Get.arguments`로 noticeId 전달 (라우팅 파라미터)
- 404 에러 분리 처리 (사용자 친화적 메시지)
- `markAsRead()`: 목록 컨트롤러와 상태 동기화

---

## View 설계 (재사용 가능한 화면)

### NoticeListView

**파일**: `packages/notice/lib/src/views/notice_list_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import '../controllers/notice_list_controller.dart';
import '../widgets/notice_list_card.dart';

/// 공지사항 목록 화면
class NoticeListView extends GetView<NoticeListController> {
  const NoticeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // 로딩 상태
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        // 에러 상태
        if (controller.errorMessage.value.isNotEmpty &&
            controller.notices.isEmpty) {
          return _buildErrorState();
        }

        // 빈 상태
        if (controller.notices.isEmpty && controller.pinnedNotices.isEmpty) {
          return _buildEmptyState();
        }

        // 데이터 있음
        return _buildNoticeList();
      }),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('공지사항'),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.refreshNotices,
          tooltip: '새로고침',
        ),
      ],
    );
  }

  /// 공지사항 목록
  Widget _buildNoticeList() {
    return RefreshIndicator(
      onRefresh: controller.refreshNotices,
      color: SketchDesignTokens.accentPrimary,
      child: CustomScrollView(
        slivers: [
          // 상단 패딩
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 고정 공지 섹션
          if (controller.pinnedNotices.isNotEmpty) ...[
            _buildPinnedSection(),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            _buildDivider(),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // 일반 공지 헤더
          _buildSectionHeader('최신 공지'),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 일반 공지 목록
          _buildNoticeItems(),

          // 무한 스크롤 로딩 인디케이터
          if (controller.isLoadingMore.value)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // 하단 패딩
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  /// 고정 공지 섹션
  Widget _buildPinnedSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '📌 고정 공지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...controller.pinnedNotices.map(
            (notice) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: NoticeListCard(
                notice: notice,
                onTap: () => _navigateToDetail(notice.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(thickness: 1),
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 일반 공지 아이템들
  Widget _buildNoticeItems() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // 마지막 아이템에서 무한 스크롤 트리거
          if (index == controller.notices.length - 1 &&
              controller.hasMore.value) {
            controller.loadMoreNotices();
          }

          final notice = controller.notices[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: NoticeListCard(
              notice: notice,
              onTap: () => _navigateToDetail(notice.id),
            ),
          );
        },
        childCount: controller.notices.length,
      ),
    );
  }

  /// 상세 화면으로 이동
  void _navigateToDetail(int noticeId) {
    Get.toNamed('/notice/detail', arguments: noticeId);
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('공지사항을 불러오는 중...'),
        ],
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '인터넷 연결을 확인해주세요',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 24),
            SketchButton(
              text: '다시 시도',
              style: SketchButtonStyle.primary,
              onPressed: controller.refreshNotices,
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 등록된 공지사항이 없습니다',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '새로운 공지사항이 등록되면 알려드릴게요',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

### NoticeDetailView

**파일**: `packages/notice/lib/src/views/notice_detail_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:design_system/design_system.dart';
import '../controllers/notice_detail_controller.dart';

/// 공지사항 상세 화면
class NoticeDetailView extends GetView<NoticeDetailController> {
  const NoticeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        // 로딩 상태
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        // 에러 상태
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        // 데이터 있음
        final notice = controller.notice.value;
        if (notice == null) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(notice),
              const SizedBox(height: 24),
              _buildMetaRow(notice),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              _buildMarkdownBody(notice.content ?? ''),
            ],
          ),
        );
      }),
    );
  }

  /// 헤더 (고정 태그 + 제목 + 카테고리)
  Widget _buildHeader(NoticeModel notice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 고정 태그
        if (notice.isPinned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: SketchDesignTokens.accentLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.push_pin, size: 14, color: Color(0xFFC86947)),
                SizedBox(width: 4),
                Text(
                  '고정',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC86947),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),

        // 제목
        Text(
          notice.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // 카테고리
        if (notice.category != null)
          SketchChip(
            label: notice.category!,
            backgroundColor: SketchDesignTokens.base100,
            textColor: SketchDesignTokens.base700,
          ),
      ],
    );
  }

  /// 메타 정보 (조회수, 작성일시)
  Widget _buildMetaRow(NoticeModel notice) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              '조회 ${notice.viewCount}회',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              _formatDateTime(notice.createdAt),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  /// 마크다운 본문
  Widget _buildMarkdownBody(String content) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        p: const TextStyle(fontSize: 16, height: 1.6),
        a: TextStyle(
          color: SketchDesignTokens.accentPrimary,
          decoration: TextDecoration.underline,
        ),
        code: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 14,
          backgroundColor: Color(0xFFF7F7F7),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDCDCDC), width: 1),
        ),
        listBullet: TextStyle(fontSize: 16, color: SketchDesignTokens.accentPrimary),
        blockquote: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFFF7F7F7).withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
          border: const Border(
            left: BorderSide(color: Color(0xFFF19E7E), width: 4),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
    );
  }

  /// 날짜/시간 포맷 (예: 2026년 2월 4일 14:30)
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('공지사항을 불러오는 중...'),
        ],
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 24),
            SketchButton(
              text: '목록으로',
              style: SketchButtonStyle.outline,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 재사용 가능한 위젯

### NoticeListCard

**파일**: `packages/notice/lib/src/widgets/notice_list_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/notice_model.dart';

/// 공지사항 목록 카드 위젯
///
/// 목록 화면에서 각 공지사항을 표시하는 재사용 가능한 위젯입니다.
class NoticeListCard extends StatelessWidget {
  /// 공지사항 데이터
  final NoticeModel notice;

  /// 탭 콜백
  final VoidCallback onTap;

  const NoticeListCard({
    super.key,
    required this.notice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SketchCard(
        elevation: notice.isRead ? 1 : 2,
        borderColor: notice.isRead
            ? SketchDesignTokens.base300
            : SketchDesignTokens.accentPrimary,
        fillColor: notice.isRead
            ? Colors.white
            : const Color(0xFFFFF9F7), // 아주 연한 오렌지
        roughness: 0.8,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 읽지 않음 점
              Column(
                children: [
                  if (!notice.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: SketchDesignTokens.accentPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  if (notice.isRead) const SizedBox(width: 8),
                  const SizedBox(height: 24),
                ],
              ),
              const SizedBox(width: 8),

              // 콘텐츠 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 고정 아이콘
                    Row(
                      children: [
                        if (notice.isPinned) ...[
                          const Icon(
                            Icons.push_pin,
                            size: 16,
                            color: Color(0xFFC86947),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            notice.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  notice.isRead ? FontWeight.w500 : FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 카테고리
                    if (notice.category != null) ...[
                      SketchChip(
                        label: notice.category!,
                        backgroundColor: SketchDesignTokens.base100,
                        textColor: SketchDesignTokens.base700,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    // 메타 정보 (조회수, 날짜)
                    Row(
                      children: [
                        const Icon(Icons.visibility, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${notice.viewCount}회',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(notice.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 날짜 포맷 (예: 2026.02.04)
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }
}
```

### UnreadNoticeBadge

**파일**: `packages/notice/lib/src/widgets/unread_notice_badge.dart`

```dart
import 'package:flutter/material.dart';

/// 읽지 않은 공지 뱃지 위젯
///
/// 앱 메인 화면에서 읽지 않은 공지 개수를 표시합니다.
class UnreadNoticeBadge extends StatelessWidget {
  /// 읽지 않은 개수
  final int unreadCount;

  /// 뱃지를 표시할 자식 위젯
  final Widget child;

  const UnreadNoticeBadge({
    super.key,
    required this.unreadCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: unreadCount < 10 ? 6 : 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336), // error red
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## 라우팅 설계

### SDK에서 제공하는 Route 이름

**파일**: `packages/notice/lib/src/routes/notice_routes.dart`

```dart
/// 공지사항 SDK 라우트 이름
abstract class NoticeRoutes {
  static const list = '/notice/list';
  static const detail = '/notice/detail';
}
```

### 앱 통합 예시 (wowa 앱)

**파일**: `apps/wowa/lib/app/routes/app_pages.dart`

```dart
import 'package:get/get.dart';
import 'package:notice/notice.dart'; // SDK import

class AppPages {
  static final routes = [
    // ... 기존 라우트

    // 공지사항 목록
    GetPage(
      name: NoticeRoutes.list,
      page: () => const NoticeListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NoticeApiService>(() => NoticeApiService());
        Get.lazyPut<NoticeListController>(() => NoticeListController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // 공지사항 상세
    GetPage(
      name: NoticeRoutes.detail,
      page: () => const NoticeDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NoticeDetailController>(() => NoticeDetailController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

### 네비게이션 사용 예시

```dart
// 앱의 다른 화면에서 공지사항 목록으로 이동
Get.toNamed(NoticeRoutes.list);

// 특정 공지사항 상세로 이동
Get.toNamed(NoticeRoutes.detail, arguments: noticeId);
```

---

## 에러 처리 전략

### Controller 레벨

| 에러 타입 | 처리 방법 | 사용자 메시지 |
|----------|---------|------------|
| `DioException` (네트워크) | `errorMessage.value` 업데이트 + Snackbar | "네트워크 오류가 발생했습니다" |
| `DioException` (404) | 상세 화면 에러 상태 + "목록으로" 버튼 | "삭제되었거나 존재하지 않는 공지사항입니다" |
| 일반 Exception | `errorMessage.value` 업데이트 + Snackbar | "예상치 못한 오류가 발생했습니다" |

### View 레벨

**로딩 상태**:
- `Obx(() => isLoading.value ? CircularProgressIndicator() : ...)`

**에러 상태**:
- 중앙 Icon (wifi_off, error_outline)
- 에러 메시지 텍스트
- 재시도 버튼 (SketchButton)

**빈 상태**:
- 중앙 Icon (notifications_none)
- 안내 메시지

---

## 앱 통합 가이드

### 1단계: 의존성 추가

**파일**: `apps/wowa/pubspec.yaml`

```yaml
dependencies:
  notice:
    path: ../../packages/notice
```

### 2단계: Dio 설정 (api 패키지)

Dio 인스턴스는 `api` 패키지에서 제공해야 합니다.

**파일**: `packages/api/lib/src/clients/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Dio 인스턴스 초기화
void setupDio() {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com', // 서버 URL
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // JWT 토큰 인터셉터
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // 토큰 추가 로직
      final token = Get.find<AuthService>().token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));

  Get.put<Dio>(dio, permanent: true);
}
```

### 3단계: 앱 초기화 시 Dio 등록

**파일**: `apps/wowa/lib/main.dart`

```dart
import 'package:api/api.dart';
import 'package:notice/notice.dart';

void main() {
  // Dio 초기화
  setupDio();

  // NoticeApiService 등록 (전역)
  Get.put<NoticeApiService>(NoticeApiService(), permanent: true);

  runApp(const MyApp());
}
```

### 4단계: 라우트 등록

위 "라우팅 설계" 섹션 참조

### 5단계: 메인 화면에서 UnreadNoticeBadge 사용

```dart
// 앱 메인 화면
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() {
            final unreadCount = Get.find<UnreadCountController>().unreadCount.value;

            return UnreadNoticeBadge(
              unreadCount: unreadCount,
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => Get.toNamed(NoticeRoutes.list),
              ),
            );
          }),
        ],
      ),
      // ...
    );
  }
}
```

### 6단계: UnreadCountController 구현 (선택)

**파일**: `apps/wowa/lib/app/controllers/unread_count_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:notice/notice.dart';

/// 읽지 않은 공지 개수 컨트롤러 (앱 레벨)
class UnreadCountController extends GetxController {
  final NoticeApiService _apiService = Get.find<NoticeApiService>();

  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();

    // 주기적 갱신 (선택)
    ever(unreadCount, (_) {
      // 개수 변경 시 추가 로직 (예: 푸시 배지)
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.getUnreadCount();
      unreadCount.value = response.unreadCount;
    } catch (e) {
      // 에러 무시 (비치명적)
    }
  }

  /// 공지 읽음 후 개수 감소
  void decrementUnreadCount() {
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }
  }
}
```

---

## 성능 최적화 전략

### const 생성자 사용

```dart
// Good
const NoticeListView({super.key});
const SizedBox(height: 16);

// Bad
NoticeListView(); // const 누락
SizedBox(height: 16); // const 누락
```

### Obx 범위 최소화

```dart
// Good - 특정 부분만 반응형
Obx(() => Text('${controller.count}'))

// Bad - 전체 화면 rebuild
Obx(() => Scaffold(...))
```

### ListView.builder 사용

```dart
// Good - 무한 스크롤 최적화
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => NoticeListCard(...),
    childCount: controller.notices.length,
  ),
)

// Bad - 모든 아이템 한 번에 생성
Column(children: controller.notices.map((n) => NoticeListCard(...)).toList())
```

### 이미지 로딩 최적화 (향후 첨부파일 지원 시)

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

## 코드 생성 (build_runner)

### 실행 명령어

```bash
# notice 패키지 디렉토리로 이동
cd /Users/lms/dev/repository/feature-notice/packages/notice

# Freezed + json_serializable 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

또는 melos 사용:

```bash
# 모노레포 루트에서
melos generate
```

### 생성되는 파일

- `*.freezed.dart`: Freezed 불변 클래스 구현
- `*.g.dart`: JSON 직렬화/역직렬화 코드

---

## 테스트 정책 (CLAUDE.md 준수)

**IMPORTANT**: CLAUDE.md에 따라 **테스트 코드 작성 금지**

- 단위 테스트, 통합 테스트는 작성하지 않음
- 기술 아키텍처 설계에 집중

---

## 검증 기준

- [ ] 패키지 구조 정의 완료 (models, services, controllers, views, widgets)
- [ ] Freezed 모델 3개 정의 (Notice, NoticeListResponse, UnreadCountResponse)
- [ ] API Service 클래스 정의 (Dio 기반, 3개 메서드)
- [ ] GetX Controller 2개 정의 (List, Detail)
- [ ] View 2개 정의 (List, Detail)
- [ ] 재사용 위젯 2개 정의 (NoticeListCard, UnreadNoticeBadge)
- [ ] 의존성 그래프 명확 (core ← api ← notice ← design_system ← app)
- [ ] 에러 처리 전략 정의 (DioException, 404, 일반 Exception)
- [ ] 앱 통합 가이드 작성 (6단계)
- [ ] 성능 최적화 전략 명시 (const, Obx 범위, ListView.builder)
- [ ] 라우팅 설계 완료 (NoticeRoutes, GetPage)
- [ ] 마크다운 렌더링 설정 (flutter_markdown, MarkdownStyleSheet)

---

## 다음 단계

1. **CTO 검증**: 설계 검토 및 피드백
2. **Senior Developer 작업**:
   - Freezed 모델 작성
   - API Service 구현
   - Controller 비즈니스 로직 작성
   - build_runner 실행
3. **Junior Developer 작업**:
   - View UI 구현
   - 재사용 위젯 구현
   - 앱 라우트 등록
4. **통합 테스트**: wowa 앱에서 SDK import 후 동작 확인

---

## 참고 자료

- **서버 API 명세**: docs/core/notice/server-brief.md
- **디자인 명세**: docs/core/notice/mobile-design-spec.md
- **GetX 베스트 프랙티스**: .claude/guide/mobile/getx_best_practices.md
- **Flutter 베스트 프랙티스**: .claude/guide/mobile/flutter_best_practices.md
- **디자인 토큰**: .claude/guide/mobile/design-tokens.json
- **Freezed 문서**: https://pub.dev/packages/freezed
- **flutter_markdown**: https://pub.dev/packages/flutter_markdown
- **GetX 문서**: https://pub.dev/packages/get
