# 기술 아키텍처 설계: SDK 통합

## 개요

wowa 앱에서 4개 SDK(auth_sdk, push, notice, qna)를 올바르게 통합하는 작업입니다. push와 qna는 이미 완전 통합되어 있으며, 실제 작업은 **auth_sdk 중복 코드 제거**와 **notice SDK 신규 통합** 2가지입니다.

**설계 목표**:
- auth_sdk와 중복되는 wowa 앱 내부 코드 완전 제거
- notice SDK를 wowa 앱에 통합하여 공지사항 기능 제공
- GetX 패턴과 모노레포 구조 유지
- SDK 독립성 보장 (앱 코드와 SDK의 명확한 분리)

## 아키텍처 개요

### 변경 전 의존성 구조

```
wowa 앱
  ├── auth_sdk (외부 SDK) ✅
  ├── 자체 구현 (중복) ❌
  │   ├── app/interceptors/auth_interceptor.dart
  │   ├── app/data/repositories/auth_repository.dart
  │   ├── app/services/auth_state_service.dart
  │   └── app/services/social_login/social_login_provider.dart
  ├── push SDK ✅ (완전 통합됨)
  ├── qna SDK ✅ (완전 통합됨)
  └── notice SDK ❌ (미통합)
```

### 변경 후 의존성 구조

```
wowa 앱
  ├── auth_sdk ✅ (중복 제거 완료)
  ├── push SDK ✅ (기존 유지)
  ├── notice SDK ✅ (신규 통합)
  └── qna SDK ✅ (기존 유지)
```

**패키지 의존성 관계**:
```
core (foundation)
  ↑
  ├── api (Dio, Freezed models)
  ├── design_system (UI)
  ├── auth_sdk (소셜 로그인, 토큰 관리)
  ├── notice SDK (공지사항)
  ├── push SDK (푸시 알림)
  ├── qna SDK (질문 제출)
  └── wowa (메인 앱)
```

## 작업 1: auth_sdk 중복 코드 제거

### 1.1 중복 파일 목록

wowa 앱 내부에 auth_sdk와 중복되는 4개 파일이 존재하며, 이를 삭제해야 합니다:

| 삭제할 파일 | 역할 | auth_sdk 대체 |
|------------|------|--------------|
| `apps/mobile/apps/wowa/lib/app/interceptors/auth_interceptor.dart` | Dio 인터셉터 (Authorization 헤더 주입, 401 토큰 갱신) | `auth_sdk/src/interceptors/auth_interceptor.dart` |
| `apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart` | 로그인/로그아웃/토큰 갱신 Repository | `auth_sdk/src/repositories/auth_repository.dart` |
| `apps/mobile/apps/wowa/lib/app/services/auth_state_service.dart` | 전역 인증 상태 관리 Service | `auth_sdk/src/services/auth_state_service.dart` |
| `apps/mobile/apps/wowa/lib/app/services/social_login/social_login_provider.dart` | 소셜 로그인 Provider 인터페이스 | `auth_sdk/src/providers/social_login_provider.dart` |

### 1.2 영향 범위 분석

**현재 상황**:
- ✅ 위 4개 파일을 import하는 곳이 **0개** (Grep 결과로 확인)
- ✅ wowa 앱은 이미 auth_sdk를 통해 인증 기능 사용 중 (main.dart의 AuthSdk.initialize 확인)
- ✅ 중복 파일은 사용되지 않는 dead code

**결론**: 파일 삭제 시 컴파일 에러 없음. 안전하게 제거 가능.

### 1.3 변경 작업 (Senior Developer 담당)

#### 삭제 대상 파일 목록

```bash
# 삭제할 파일 4개
apps/mobile/apps/wowa/lib/app/interceptors/auth_interceptor.dart
apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart
apps/mobile/apps/wowa/lib/app/services/auth_state_service.dart
apps/mobile/apps/wowa/lib/app/services/social_login/social_login_provider.dart
```

#### 변경 후 import 패턴

**다른 파일에서 auth 관련 기능이 필요하면 auth_sdk에서 import**:
```dart
// ❌ 삭제된 파일 (사용 금지)
// import '../data/repositories/auth_repository.dart';
// import '../services/auth_state_service.dart';
// import '../interceptors/auth_interceptor.dart';

// ✅ auth_sdk 사용
import 'package:auth_sdk/auth_sdk.dart';

// 사용 가능한 클래스들
// - AuthRepository
// - AuthStateService
// - AuthInterceptor
// - SocialLoginProvider
// - KakaoLoginProvider, NaverLoginProvider, GoogleLoginProvider, AppleLoginProvider
```

### 1.4 검증 방법

```bash
cd /Users/lms/dev/repository/feature-wowa-mvp/apps/mobile/apps/wowa
flutter clean
flutter pub get
flutter analyze
flutter build apk --debug  # 또는 flutter build ios --debug
```

- ❌ 컴파일 에러 발생 시: 누락된 import 확인
- ✅ 빌드 성공: 중복 제거 완료

## 작업 2: notice SDK 통합

### 2.1 pubspec.yaml 변경

**파일**: `apps/mobile/apps/wowa/pubspec.yaml`

#### 추가할 의존성

```yaml
dependencies:
  # ... 기존 의존성

  # Notice SDK 추가
  notice:
    path: ../../packages/notice
```

#### 변경 후 실행

```bash
cd /Users/lms/dev/repository/feature-wowa-mvp/apps/mobile
melos bootstrap
```

### 2.2 NoticeApiService 전역 등록 (main.dart)

**파일**: `apps/mobile/apps/wowa/lib/main.dart`

#### 추가할 import

```dart
import 'package:notice/notice.dart';
```

#### DI 등록 (main 함수 내부)

`AuthSdk.initialize()` 이후, `runApp()` 이전에 추가:

```dart
// 6. NoticeApiService 전역 등록 (Dio가 먼저 등록되어 있어야 함)
Get.put<NoticeApiService>(NoticeApiService(), permanent: true);
```

**위치**: `PushApiClient` 등록 이후, `pushService.initialize()` 이전

**최종 main.dart 구조**:
```dart
Future<void> main() async {
  // 1-3. 환경변수, AuthSdk 초기화 (기존)

  // 4. AdMob 초기화 (기존)

  // 5. PushApiClient 전역 등록 (기존)

  // 6. NoticeApiService 전역 등록 (신규)
  Get.put<NoticeApiService>(NoticeApiService(), permanent: true);

  // 7. PushService 초기화 (기존)

  // 8-10. 푸시 알림 핸들러 등록 (기존)

  runApp(const MyApp());
}
```

### 2.3 라우트 등록

#### app_routes.dart 변경

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

**주의**: NoticeRoutes는 SDK에서 제공하지만, wowa 앱의 Routes 클래스에도 명시적으로 추가하여 일관성 유지

#### app_pages.dart 변경

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

**설계 근거**:
- `BindingsBuilder()` 사용으로 Controller를 지연 로딩
- `Transition.cupertino` — iOS 스타일 슬라이드 전환
- `transitionDuration: 300ms` — 기존 화면들과 일관성 유지

### 2.4 SettingsView 수정 (공지사항 메뉴 추가)

#### SettingsController 변경

**파일**: `apps/mobile/apps/wowa/lib/app/modules/settings/controllers/settings_controller.dart`

#### 추가할 import

```dart
import 'package:notice/notice.dart';
```

#### 추가할 반응형 상태

```dart
class SettingsController extends GetxController {
  // ... 기존 상태

  /// 읽지 않은 공지사항 개수
  final unreadCount = 0.obs;

  // ... 기존 비반응형 상태

  late final NoticeApiService _noticeApiService;
```

#### 초기화 메서드 변경

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

#### 추가할 메서드

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

#### SettingsView 변경

**파일**: `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`

#### 추가할 import

```dart
import 'package:notice/notice.dart';
```

#### _buildMenuSection 메서드 수정

기존 "박스 변경" 메뉴 위에 "공지사항" 메뉴 추가:

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

#### _buildMenuItem 메서드 수정 (badge 지원)

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

**설계 근거**:
- `UnreadNoticeBadge` — notice SDK에서 제공하는 위젯
- `Obx` — unreadCount가 변경되면 자동으로 뱃지 업데이트
- `if (count == 0) return null` — 읽지 않은 공지가 없으면 뱃지 숨김
- `Stack` + `Positioned` — 아이콘 우상단에 뱃지 오버레이

## GetX 상태 관리 설계

### SettingsController 상태 정의

#### 반응형 상태 (.obs)

```dart
/// 읽지 않은 공지사항 개수
final unreadCount = 0.obs;
```

**설계 근거**:
- SettingsView의 뱃지 UI가 반응형으로 업데이트되어야 함
- 공지사항을 읽으면 자동으로 뱃지 숫자 감소
- 0이면 뱃지 자동 숨김

#### 비반응형 상태

```dart
late final NoticeApiService _noticeApiService;
```

**설계 근거**:
- API 서비스는 의존성 주입으로 관리
- UI 변경 불필요 (반응형 불필요)

### NoticeListController / NoticeDetailController

**SDK에서 완전히 제공** — wowa 앱에서 추가 구현 불필요

- `NoticeListController` — 목록 조회, 무한 스크롤, Pull to Refresh
- `NoticeDetailController` — 상세 조회, 자동 읽음 처리

## 의존성 변경 사항

### pubspec.yaml 변경 전/후

#### 변경 전

```yaml
dependencies:
  api:
    path: ../../packages/api
  core:
    path: ../../packages/core
  design_system:
    path: ../../packages/design_system
  admob:
    path: ../../packages/admob
  push:
    path: ../../packages/push
  auth_sdk:
    path: ../../packages/auth_sdk
  qna:
    path: ../../packages/qna
```

#### 변경 후

```yaml
dependencies:
  api:
    path: ../../packages/api
  core:
    path: ../../packages/core
  design_system:
    path: ../../packages/design_system
  admob:
    path: ../../packages/admob
  push:
    path: ../../packages/push
  auth_sdk:
    path: ../../packages/auth_sdk
  qna:
    path: ../../packages/qna
  notice:                              # 신규
    path: ../../packages/notice        # 신규
```

### 실행 명령

```bash
cd /Users/lms/dev/repository/feature-wowa-mvp/apps/mobile
melos bootstrap
```

## 파일별 변경 목록

### 삭제할 파일 (4개)

| 파일 경로 | 역할 |
|----------|------|
| `apps/mobile/apps/wowa/lib/app/interceptors/auth_interceptor.dart` | 인증 인터셉터 (중복) |
| `apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart` | 인증 Repository (중복) |
| `apps/mobile/apps/wowa/lib/app/services/auth_state_service.dart` | 인증 상태 서비스 (중복) |
| `apps/mobile/apps/wowa/lib/app/services/social_login/social_login_provider.dart` | 소셜 로그인 인터페이스 (중복) |

### 수정할 파일 (5개)

| 파일 경로 | 변경 내용 |
|----------|----------|
| `apps/mobile/apps/wowa/pubspec.yaml` | notice 의존성 추가 |
| `apps/mobile/apps/wowa/lib/main.dart` | NoticeApiService 전역 등록, import 추가 |
| `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart` | NOTICE_LIST, NOTICE_DETAIL 라우트 상수 추가 |
| `apps/mobile/apps/wowa/lib/app/routes/app_pages.dart` | 공지사항 목록/상세 GetPage 등록, import 추가 |
| `apps/mobile/apps/wowa/lib/app/modules/settings/controllers/settings_controller.dart` | unreadCount 상태 추가, _fetchUnreadCount() 메서드 추가, goToNoticeList() 메서드 추가, import 추가 |
| `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart` | 공지사항 메뉴 항목 추가, _buildMenuItem에 badge 파라미터 추가, import 추가 |

### 신규 파일 (0개)

모든 기능이 SDK에서 제공되므로 신규 파일 불필요.

## 네비게이션 플로우

### 공지사항 접근 경로

```
SettingsView
  ↓ (사용자가 "공지사항" 메뉴 탭)
controller.goToNoticeList()
  ↓
Get.toNamed(Routes.NOTICE_LIST)
  ↓
NoticeListView (SDK 제공)
  ↓ (사용자가 특정 공지사항 탭)
Get.toNamed(Routes.NOTICE_DETAIL, arguments: noticeId)
  ↓
NoticeDetailView (SDK 제공)
  ↓ (자동 읽음 처리)
NoticeDetailController.fetchNoticeDetail()
  ↓ (서버에서 viewCount +1, notice_reads INSERT)
NoticeListController.markAsRead(noticeId)
  ↓ (뒤로 가기)
NoticeListView (읽음 상태 업데이트됨)
  ↓ (뒤로 가기)
SettingsView (뱃지 개수 자동 감소는 수동 갱신 필요*)
```

**주의**: 뱃지 자동 갱신은 NoticeListView에서 돌아올 때 `SettingsController._fetchUnreadCount()`를 다시 호출해야 함. 현재 설계에서는 화면 재진입 시 자동 갱신되지 않으므로, 필요하면 `onResume()` 또는 `ever()` 사용.

### 화면 전환 애니메이션

- **SettingsView → NoticeListView**: `Transition.cupertino` (300ms)
- **NoticeListView → NoticeDetailView**: `Transition.cupertino` (300ms)
- 일관된 iOS 스타일 슬라이드 전환

## 에러 처리 전략

### NoticeApiService 미등록

**증상**: `Get.find<NoticeApiService>()` 실패
**에러 메시지**: "NoticeApiService not found"
**해결**:
```dart
// main.dart에서 등록 확인
Get.put<NoticeApiService>(NoticeApiService(), permanent: true);
```

### 라우트 미등록

**증상**: `Get.toNamed(Routes.NOTICE_LIST)` 호출 시 "Route not found"
**해결**: `app_pages.dart`에 NoticeListView, NoticeDetailView GetPage 등록 확인

### 읽지 않은 개수 조회 실패

**처리 방식**: 비치명적 오류
```dart
catch (e) {
  debugPrint('Failed to fetch unread notice count: $e');
  // unreadCount는 0 유지, 앱 크래시 없음
}
```

**UI 동작**:
- 뱃지 숨김 (count == 0)
- 사용자는 여전히 공지사항 메뉴 접근 가능

### NoticeDetailView 타입 에러

**증상**: `arguments as int` 캐스팅 실패
**원인**: `Get.toNamed(route, arguments: noticeId)` 호출 시 int가 아닌 다른 타입 전달
**해결**: 항상 `int noticeId`를 arguments로 전달

## 성능 최적화 전략

### const 생성자

```dart
// ✅ 정적 위젯은 const 사용
const SizedBox(height: 12)
const Text('공지사항')
const UnreadNoticeBadge(...)
```

### Obx 범위 최소화

```dart
// ✅ 뱃지만 Obx로 감싸기
Obx(() {
  final count = controller.unreadCount.value;
  if (count == 0) return null;
  return UnreadNoticeBadge(...);
})

// ❌ 전체 메뉴 섹션을 Obx로 감싸면 불필요한 rebuild
// Obx(() => _buildMenuSection())  // 나쁜 예
```

### GetView 사용

```dart
class SettingsView extends GetView<SettingsController> {
  // Controller가 한 번만 생성되고 재사용됨
}
```

## 작업 분배 계획 (CTO가 참조)

### Senior Developer 작업

1. **auth_sdk 중복 제거** (작업 1)
   - 4개 파일 삭제
   - 컴파일 에러 확인 및 수정 (예상: 에러 없음)

2. **notice SDK 통합 — 백엔드 연동** (작업 2)
   - `pubspec.yaml` notice 의존성 추가
   - `melos bootstrap` 실행
   - `main.dart` NoticeApiService 전역 등록
   - `app_routes.dart` 라우트 상수 추가
   - `app_pages.dart` GetPage 등록
   - `SettingsController` unreadCount 상태 추가 및 메서드 구현

### Junior Developer 작업

1. **SettingsView UI 수정** (작업 2)
   - 공지사항 메뉴 항목 추가
   - `_buildMenuItem`에 badge 파라미터 추가
   - UnreadNoticeBadge 위젯 통합
   - Obx 반응형 UI 구현

### 작업 의존성

- Junior는 Senior의 SettingsController 완성 후 시작
- `unreadCount.obs`, `goToNoticeList()` 메서드가 정확히 구현되어야 함

## 검증 기준

### auth_sdk 중복 제거 검증

- [ ] 4개 중복 파일 삭제 완료
- [ ] 컴파일 에러 없음 (`flutter analyze` 통과)
- [ ] 로그인/로그아웃 정상 동작
- [ ] 토큰 자동 갱신 정상 동작 (401 → 갱신 → 재시도)

### notice SDK 통합 검증

- [ ] `pubspec.yaml`에 notice 의존성 추가됨
- [ ] `melos bootstrap` 성공
- [ ] `NoticeApiService` 전역 등록됨 (Get.find 성공)
- [ ] `app_pages.dart`에 NoticeListView, NoticeDetailView GetPage 등록됨
- [ ] SettingsView에 "공지사항" 메뉴 항목 표시됨
- [ ] 공지사항 메뉴 탭 시 NoticeListView로 이동
- [ ] 공지사항 목록에서 공지 탭 시 NoticeDetailView로 이동
- [ ] 공지사항 상세 조회 시 읽음 처리됨
- [ ] 읽지 않은 공지 개수 뱃지 표시됨 (0이면 숨김)
- [ ] 공지 읽은 후 목록으로 돌아가면 읽음 상태 반영됨

### 전체 통합 검증

- [ ] GetX 패턴 준수 (Controller, View, Binding 분리)
- [ ] const 최적화 적용
- [ ] Obx 범위 최소화
- [ ] 에러 처리 완비
- [ ] CLAUDE.md 표준 준수

## 참고 자료

- **Notice SDK README**: `apps/mobile/packages/notice/README.md`
- **Auth SDK 공개 API**: `apps/mobile/packages/auth_sdk/lib/auth_sdk.dart`
- **GetX Best Practices**: `.claude/guide/mobile/getx_best_practices.md`
- **Directory Structure**: `.claude/guide/mobile/directory_structure.md`
- **Common Patterns**: `.claude/guide/mobile/common_patterns.md`
- **Design System**: `.claude/guide/mobile/design_system.md`

## 다음 단계

1. **사용자 승인 대기** — interactive-review MCP로 설계 검토
2. **CTO 검증** — 기술 아키텍처 적합성 확인
3. **작업 분배** — Senior/Junior Developer에게 작업 할당
4. **구현 시작** — mobile-work-plan.md 기반 단계별 구현
