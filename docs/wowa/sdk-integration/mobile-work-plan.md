# Mobile 작업 분배 계획: SDK 통합

## 개요

wowa 앱에서 auth_sdk 중복 코드 제거 및 notice SDK 신규 통합 작업입니다. 작업이 단순하고 파일 충돌이 없으므로 **Flutter Developer 1명**으로 충분합니다.

**작업 기간**: 1일 예상
**투입 인원**: Flutter Developer 1명
**플랫폼**: Mobile (Flutter)

## 작업 범위

### 작업 1: auth_sdk 중복 코드 제거
- wowa 앱 내 4개 dead code 파일 삭제
- 삭제 대상: auth_interceptor.dart, auth_repository.dart, auth_state_service.dart, social_login_provider.dart
- 이미 import 0개로 확인됨 (안전 삭제)

### 작업 2: notice SDK 신규 통합
- pubspec.yaml에 notice 의존성 추가
- main.dart에 NoticeApiService 전역 등록
- app_routes.dart에 NOTICE_LIST, NOTICE_DETAIL 상수 추가
- app_pages.dart에 GetPage 2개 등록
- SettingsController에 unreadCount + goToNoticeList() 추가
- SettingsView에 공지사항 메뉴 항목 + UnreadNoticeBadge 추가

## 실행 그룹 (Execution Groups)

### Group 1 (순차 실행) — 중복 제거 우선

작업 1을 먼저 완료하여 코드 정리 후, 작업 2를 진행하는 것이 안전합니다.

| Agent | Module | 설명 | 예상 시간 |
|-------|--------|------|----------|
| flutter-developer | auth-sdk-cleanup | 중복 코드 제거 (4개 파일 삭제) | 30분 |

**완료 조건**:
- 4개 파일 삭제 완료
- flutter analyze 통과
- 컴파일 에러 없음

### Group 2 (순차 실행) — Group 1 완료 후

| Agent | Module | 설명 | 예상 시간 |
|-------|--------|------|----------|
| flutter-developer | notice-sdk-integration | notice SDK 통합 (의존성, 라우트, UI) | 2-3시간 |

**완료 조건**:
- pubspec.yaml 업데이트 완료
- main.dart, app_routes.dart, app_pages.dart 수정 완료
- SettingsController, SettingsView 수정 완료
- flutter analyze 통과
- 앱 빌드 성공
- 설정 화면에 공지사항 메뉴 표시됨

## 작업 상세

### 작업 1: auth_sdk 중복 코드 제거

#### 담당: Flutter Developer

#### 작업 내용

1. 삭제할 파일 4개 확인 및 제거:
   ```bash
   rm apps/mobile/apps/wowa/lib/app/interceptors/auth_interceptor.dart
   rm apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart
   rm apps/mobile/apps/wowa/lib/app/services/auth_state_service.dart
   rm apps/mobile/apps/wowa/lib/app/services/social_login/social_login_provider.dart
   ```

2. 검증:
   ```bash
   cd apps/mobile/apps/wowa
   flutter clean
   flutter pub get
   flutter analyze
   flutter build apk --debug
   ```

3. 예상 결과:
   - 컴파일 에러 없음 (이미 사용되지 않는 dead code이므로)
   - flutter analyze 경고 없음
   - 앱 빌드 성공

#### 파일별 변경 목록

| 파일 경로 | 변경 유형 | 설명 |
|----------|----------|------|
| `apps/mobile/apps/wowa/lib/app/interceptors/auth_interceptor.dart` | 삭제 | auth_sdk와 중복 |
| `apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart` | 삭제 | auth_sdk와 중복 |
| `apps/mobile/apps/wowa/lib/app/services/auth_state_service.dart` | 삭제 | auth_sdk와 중복 |
| `apps/mobile/apps/wowa/lib/app/services/social_login/social_login_provider.dart` | 삭제 | auth_sdk와 중복 |

### 작업 2: notice SDK 신규 통합

#### 담당: Flutter Developer

#### 작업 내용

##### 2.1 pubspec.yaml 변경

**파일**: `apps/mobile/apps/wowa/pubspec.yaml`

**추가할 의존성**:
```yaml
dependencies:
  # ... 기존 의존성

  # Notice SDK 추가
  notice:
    path: ../../packages/notice
```

**변경 후 실행**:
```bash
cd apps/mobile
melos bootstrap
```

##### 2.2 main.dart 변경

**파일**: `apps/mobile/apps/wowa/lib/main.dart`

**추가할 import**:
```dart
import 'package:notice/notice.dart';
```

**DI 등록 추가** (AuthSdk.initialize() 이후, runApp() 이전):
```dart
// 6. NoticeApiService 전역 등록 (Dio가 먼저 등록되어 있어야 함)
Get.put<NoticeApiService>(NoticeApiService(), permanent: true);
```

**위치**: `PushApiClient` 등록 이후, `pushService.initialize()` 이전

##### 2.3 app_routes.dart 변경

**파일**: `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart`

**추가할 라우트 상수**:
```dart
abstract class Routes {
  // ... 기존 라우트

  /// 공지사항 목록 화면
  static const NOTICE_LIST = '/notice/list';

  /// 공지사항 상세 화면
  static const NOTICE_DETAIL = '/notice/detail';
}
```

##### 2.4 app_pages.dart 변경

**파일**: `apps/mobile/apps/wowa/lib/app/routes/app_pages.dart`

**추가할 import**:
```dart
import 'package:notice/notice.dart';
```

**추가할 GetPage**:
```dart
class AppPages {
  static final routes = [
    // ... 기존 라우트

    // 공지사항 목록
    GetPage(
      name: Routes.NOTICE_LIST,
      page: () => const NoticeListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NoticeListController>(() => NoticeListController());
      }),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // 공지사항 상세
    GetPage(
      name: Routes.NOTICE_DETAIL,
      page: () => const NoticeDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NoticeDetailController>(() => NoticeDetailController());
      }),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

##### 2.5 SettingsController 변경

**파일**: `apps/mobile/apps/wowa/lib/app/modules/settings/controllers/settings_controller.dart`

**추가할 import**:
```dart
import 'package:notice/notice.dart';
```

**추가할 반응형 상태**:
```dart
class SettingsController extends GetxController {
  // ... 기존 상태

  /// 읽지 않은 공지사항 개수
  final unreadCount = 0.obs;

  // ... 기존 비반응형 상태

  late final NoticeApiService _noticeApiService;
```

**초기화 메서드 변경**:
```dart
@override
void onInit() {
  super.onInit();
  _authRepository = Get.find<AuthRepository>();
  _boxRepository = Get.find<BoxRepository>();
  _noticeApiService = Get.find<NoticeApiService>();  // 신규
  _loadSettings();
  _fetchUnreadCount();  // 신규
}
```

**추가할 메서드**:
```dart
/// 읽지 않은 공지사항 개수 조회
Future<void> _fetchUnreadCount() async {
  try {
    final response = await _noticeApiService.getUnreadCount();
    unreadCount.value = response.unreadCount;
  } catch (e) {
    // 비치명적 오류 — 실패 시 0 유지
    debugPrint('Failed to fetch unread notice count: $e');
  }
}

/// 공지사항 목록으로 이동
void goToNoticeList() {
  Get.toNamed(Routes.NOTICE_LIST);
}
```

##### 2.6 SettingsView 변경

**파일**: `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`

**추가할 import**:
```dart
import 'package:notice/notice.dart';
```

**_buildMenuSection 메서드 수정** (기존 "박스 변경" 위에 "공지사항" 추가):
```dart
Widget _buildMenuSection() {
  return Column(
    children: [
      // 공지사항 (신규)
      _buildMenuItem(
        icon: Icons.notifications_outlined,
        title: '공지사항',
        subtitle: '앱 업데이트 및 중요 안내사항',
        onTap: controller.goToNoticeList,
        badge: Obx(() {
          final count = controller.unreadCount.value;
          if (count == 0) return null;
          return UnreadNoticeBadge(
            unreadCount: count,
            child: const SizedBox.shrink(),
          );
        }),
      ),
      const SizedBox(height: 12),

      // 박스 변경 (기존)
      _buildMenuItem(
        icon: Icons.swap_horiz,
        title: '박스 변경',
        subtitle: '다른 박스를 검색하고 가입할 수 있습니다',
        onTap: controller.goToBoxChange,
      ),
    ],
  );
}
```

**_buildMenuItem 메서드 수정** (badge 파라미터 추가):
```dart
Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  Widget? badge,  // 신규: 뱃지 위젯 (선택사항)
}) {
  return GestureDetector(
    onTap: onTap,
    child: SketchCard(
      body: Row(
        children: [
          // 아이콘 + 뱃지
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: Colors.grey[700]),
              if (badge != null)
                Positioned(
                  right: -8,
                  top: -8,
                  child: badge,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}
```

#### 파일별 변경 목록

| 파일 경로 | 변경 유형 | 설명 |
|----------|----------|------|
| `apps/mobile/apps/wowa/pubspec.yaml` | 수정 | notice 의존성 추가 |
| `apps/mobile/apps/wowa/lib/main.dart` | 수정 | NoticeApiService 전역 등록, import 추가 |
| `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart` | 수정 | NOTICE_LIST, NOTICE_DETAIL 라우트 상수 추가 |
| `apps/mobile/apps/wowa/lib/app/routes/app_pages.dart` | 수정 | 공지사항 목록/상세 GetPage 등록, import 추가 |
| `apps/mobile/apps/wowa/lib/app/modules/settings/controllers/settings_controller.dart` | 수정 | unreadCount 상태 추가, _fetchUnreadCount() 메서드 추가, goToNoticeList() 메서드 추가, import 추가 |
| `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart` | 수정 | 공지사항 메뉴 항목 추가, _buildMenuItem에 badge 파라미터 추가, import 추가 |

## 의존성 분석

### 파일 간 의존성

```
작업 1 (중복 제거)
  └── 독립적 (다른 파일에 영향 없음)

작업 2 (notice 통합)
  ├── pubspec.yaml
  │   └── main.dart (NoticeApiService 등록 시 의존성 필요)
  ├── app_routes.dart
  │   └── app_pages.dart (Routes 상수 사용)
  │       └── SettingsController (Routes.NOTICE_LIST 사용)
  └── SettingsController
      └── SettingsView (controller.unreadCount 사용)
```

### 실행 순서

1. **Group 1**: auth_sdk 중복 제거 (독립적)
2. **Group 2**: notice SDK 통합 (순차)
   - pubspec.yaml → melos bootstrap
   - main.dart → NoticeApiService 등록
   - app_routes.dart → 라우트 상수
   - app_pages.dart → GetPage 등록
   - SettingsController → 상태 + 메서드
   - SettingsView → UI

## GetX 패턴 준수

### Controller-View 분리

- **SettingsController**: 비즈니스 로직, 상태 관리
  - `unreadCount.obs` (반응형 상태)
  - `_fetchUnreadCount()` (API 호출)
  - `goToNoticeList()` (네비게이션 로직)

- **SettingsView**: UI만 담당
  - `Obx(() => UnreadNoticeBadge(...))` (반응형 UI)
  - `controller.goToNoticeList` 호출

### Binding 전략

- **NoticeListController / NoticeDetailController**: `BindingsBuilder()`로 지연 로딩
- **SettingsController**: 기존 유지 (SettingsBinding에서 관리)

## 성능 최적화

### const 생성자 사용

```dart
// ✅ 정적 위젯은 const 사용
const SizedBox(height: 12)
const NoticeListView()
const NoticeDetailView()
```

### Obx 범위 최소화

```dart
// ✅ 뱃지만 Obx로 감싸기
badge: Obx(() {
  final count = controller.unreadCount.value;
  if (count == 0) return null;
  return UnreadNoticeBadge(...);
})

// ❌ 전체 메뉴 섹션을 Obx로 감싸면 불필요한 rebuild
```

### GetView 사용

```dart
class SettingsView extends GetView<SettingsController> {
  // Controller가 한 번만 생성되고 재사용됨
}
```

## 에러 처리

### NoticeApiService 미등록

**증상**: `Get.find<NoticeApiService>()` 실패
**에러 메시지**: "NoticeApiService not found"
**해결**: main.dart에서 등록 확인

### 라우트 미등록

**증상**: `Get.toNamed(Routes.NOTICE_LIST)` 호출 시 "Route not found"
**해결**: app_pages.dart에 NoticeListView, NoticeDetailView GetPage 등록 확인

### 읽지 않은 개수 조회 실패

**처리 방식**: 비치명적 오류
```dart
catch (e) {
  debugPrint('Failed to fetch unread notice count: $e');
  // unreadCount는 0 유지, 앱 크래시 없음
}
```

## 검증 기준

### 작업 1 검증

- [ ] 4개 중복 파일 삭제 완료
- [ ] `flutter analyze` 통과 (경고 없음)
- [ ] 앱 빌드 성공 (`flutter build apk --debug`)
- [ ] 로그인/로그아웃 정상 동작

### 작업 2 검증

- [ ] `pubspec.yaml`에 notice 의존성 추가됨
- [ ] `melos bootstrap` 성공
- [ ] `NoticeApiService` 전역 등록됨 (Get.find 성공)
- [ ] `app_routes.dart`에 NOTICE_LIST, NOTICE_DETAIL 상수 존재
- [ ] `app_pages.dart`에 NoticeListView, NoticeDetailView GetPage 등록됨
- [ ] SettingsView에 "공지사항" 메뉴 항목 표시됨
- [ ] 공지사항 메뉴 탭 시 NoticeListView로 이동
- [ ] 공지사항 목록에서 공지 탭 시 NoticeDetailView로 이동
- [ ] 공지사항 상세 조회 시 읽음 처리됨
- [ ] 읽지 않은 공지 개수 뱃지 표시됨 (0이면 숨김)
- [ ] `flutter analyze` 통과
- [ ] const 최적화 적용
- [ ] Obx 범위 최소화

## 참고 문서

### 설계 문서

- `docs/wowa/sdk-integration/user-story.md`
- `docs/wowa/sdk-integration/mobile-brief.md`
- `docs/wowa/sdk-integration/mobile-design-spec.md`

### 가이드

- `.claude/guide/mobile/directory_structure.md`
- `.claude/guide/mobile/getx_best_practices.md`
- `.claude/guide/mobile/flutter_best_practices.md`
- `.claude/guide/mobile/common_patterns.md`

### SDK 문서

- `apps/mobile/packages/notice/README.md`
- `apps/mobile/packages/auth_sdk/lib/auth_sdk.dart`

## 다음 단계

1. **CTO 검증**: mobile-work-plan.md 승인
2. **Flutter Developer 투입**: Task 도구로 서브에이전트 호출
3. **작업 실행**: Group 1 → Group 2 순차 진행
4. **통합 리뷰**: CTO가 코드 검증 및 mobile-cto-review.md 작성
