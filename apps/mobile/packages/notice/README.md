# Notice SDK Package

공지사항 기능을 제공하는 재사용 가능한 Flutter 패키지입니다.

## 개요

- **사용자 조회 기능**: 공지사항 목록, 상세 조회, 읽지 않은 개수 확인
- **GetX 패턴**: Controller/View/Binding 분리
- **Freezed 모델**: 불변 데이터 클래스
- **Frame0 Sketch 스타일**: Design System 컴포넌트 활용
- **마크다운 렌더링**: 풍부한 콘텐츠 표현

## 설치

### 1. pubspec.yaml에 의존성 추가

```yaml
dependencies:
  notice:
    path: ../../packages/notice
```

### 2. 의존성 설치

```bash
melos bootstrap
```

## 앱 통합 가이드

### 1단계: Dio 설정 (api 패키지에서 제공)

Dio 인스턴스는 `api` 패키지에서 제공되어야 합니다. JWT 토큰 인터셉터를 포함해야 합니다.

```dart
// main.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

void setupDio() {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    headers: {'Content-Type': 'application/json'},
  ));

  // JWT 토큰 인터셉터
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = Get.find<AuthService>().accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));

  Get.put<Dio>(dio, permanent: true);
}
```

### 2단계: NoticeApiService 등록

```dart
// main.dart
import 'package:notice/notice.dart';

void main() {
  setupDio(); // Dio 초기화

  // NoticeApiService 전역 등록
  Get.put<NoticeApiService>(NoticeApiService(), permanent: true);

  runApp(const MyApp());
}
```

### 3단계: 라우트 등록

```dart
// app_pages.dart
import 'package:get/get.dart';
import 'package:notice/notice.dart';

class AppPages {
  static final routes = [
    // 공지사항 목록
    GetPage(
      name: NoticeRoutes.list,
      page: () => const NoticeListView(),
      binding: BindingsBuilder(() {
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

### 4단계: 메인 화면에서 UnreadNoticeBadge 사용 (선택)

```dart
// home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notice/notice.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // 읽지 않은 공지 개수를 표시하는 뱃지
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

### 5단계: UnreadCountController 구현 (선택)

```dart
// unread_count_controller.dart
import 'package:get/get.dart';
import 'package:notice/notice.dart';

class UnreadCountController extends GetxController {
  final NoticeApiService _apiService = Get.find<NoticeApiService>();

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
    } catch (e) {
      // 에러 무시 (비치명적)
    }
  }
}
```

## 네비게이션

```dart
// 공지사항 목록으로 이동
Get.toNamed(NoticeRoutes.list);

// 특정 공지사항 상세로 이동
Get.toNamed(NoticeRoutes.detail, arguments: noticeId);
```

## Public API

### Models

- `NoticeModel`: 공지사항 데이터 모델
- `NoticeListResponse`: 목록 응답 래퍼
- `UnreadCountResponse`: 읽지 않은 개수 응답

### Services

- `NoticeApiService`: API 클라이언트

### Controllers

- `NoticeListController`: 목록 화면 상태 관리
- `NoticeDetailController`: 상세 화면 상태 관리

### Views

- `NoticeListView`: 목록 화면 UI
- `NoticeDetailView`: 상세 화면 UI

### Widgets

- `NoticeListCard`: 목록 카드 위젯
- `UnreadNoticeBadge`: 읽지 않은 개수 뱃지

### Routes

- `NoticeRoutes`: 라우트 이름 상수

## 코드 생성

Freezed 및 json_serializable 코드 생성:

```bash
cd packages/notice
flutter pub run build_runner build --delete-conflicting-outputs
```

또는 Melos 사용:

```bash
melos generate
```

## 의존성

- `core`: 기초 유틸리티
- `api`: Dio 클라이언트
- `design_system`: Frame0 스타일 UI 컴포넌트
- `get`: 상태 관리
- `freezed_annotation`, `json_annotation`: 데이터 모델
- `flutter_markdown`: 마크다운 렌더링
- `url_launcher`: 링크 열기

## 핵심 기능

### 무한 스크롤 페이지네이션

목록 화면에서 자동으로 다음 페이지를 로드합니다.

### 고정 공지 분리 표시

상단에 고정 공지를 별도 섹션으로 표시합니다.

### 읽음 상태 관리

읽지 않은 공지는 시각적으로 강조 표시됩니다.

### 마크다운 렌더링

공지사항 본문을 풍부한 포맷으로 표시합니다.

## 라이선스

Private - Not for public distribution
