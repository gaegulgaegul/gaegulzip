# 기술 아키텍처 설계: SDK 데모 시스템

## 개요

기존 design_system_demo 앱을 확장하여 qna, notice SDK의 UI/UX를 실제 환경에서 검증할 수 있는 데모 시스템을 구축합니다. SDK 원본 Binding(`QnaBinding`, `NoticeBinding`)을 `appCode='demo'`로 직접 사용하여 실서버와 연동하며, SDK 원본 코드는 수정하지 않고 데모 앱에서 SDK 위젯을 래핑하는 전략을 사용합니다.

## 모듈 구조 (apps/mobile/apps/design_system_demo/)

### 디렉토리 구조

```
lib/
├── app/
│   ├── modules/
│   │   ├── home/                 # 기존 홈 화면 (수정)
│   │   │   └── controllers/home_controller.dart  # SDK Demos 카테고리 추가
│   │   ├── sdk_demos/            # 신규 모듈
│   │   │   ├── controllers/
│   │   │   │   └── sdk_list_controller.dart         # SDK 목록 관리
│   │   │   ├── views/
│   │   │   │   ├── sdk_list_view.dart               # SDK 목록 화면
│   │   │   │   ├── sdk_qna_demo_view.dart           # QnA 데모 화면
│   │   │   │   └── sdk_notice_demo_view.dart        # Notice 데모 화면
│   │   │   ├── bindings/
│   │   │   │   └── sdk_list_binding.dart            # SDK 목록 바인딩
│   │   │   └── models/
│   │   │       └── sdk_item.dart                    # SDK 항목 모델
│   │   └── [기존 모듈들...]
│   └── routes/
│       ├── app_routes.dart       # 라우트 이름 추가
│       └── app_pages.dart        # GetPage 등록 (SDK 원본 Binding 사용)
└── main.dart                     # Dio, NoticeApiService 전역 등록
```

### 신규 파일 목록

1. `lib/app/modules/sdk_demos/models/sdk_item.dart`
2. `lib/app/modules/sdk_demos/controllers/sdk_list_controller.dart`
3. `lib/app/modules/sdk_demos/views/sdk_list_view.dart`
4. `lib/app/modules/sdk_demos/views/sdk_qna_demo_view.dart`
5. `lib/app/modules/sdk_demos/views/sdk_notice_demo_view.dart`
6. `lib/app/modules/sdk_demos/bindings/sdk_list_binding.dart`

### 수정 파일 목록

1. `lib/app/modules/home/controllers/home_controller.dart` - SDK Demos 카테고리 추가
2. `lib/app/routes/app_routes.dart` - 라우트 상수 추가
3. `lib/app/routes/app_pages.dart` - GetPage 등록
4. `pubspec.yaml` - qna, notice 패키지 의존성 추가

## 실서버 연동 전략

### 핵심 전략

SDK 원본 Binding을 `appCode='demo'`로 직접 사용하여 실서버와 연동합니다. Mock Controller 없이 SDK의 실제 동작을 검증할 수 있습니다.

**선택한 전략: SDK 원본 Binding 직접 사용** (Mock 불필요)

### QnA SDK 연동

**SDK 의존성 체인:**
```
QnaSubmitView → QnaController → QnaRepository → QnaApiService → Dio
```

**구현:**

1. **main.dart에서 Dio 전역 등록** (JWT 인증 없이 동작)
2. **QnaBinding(appCode: 'demo')을 라우트에 직접 사용**
   ```dart
   GetPage(
     name: Routes.SDK_QNA_DEMO,
     page: () => const SdkQnaDemoView(),
     binding: QnaBinding(appCode: 'demo'),
   )
   ```
3. **QnaSubmitView는 SDK 원본 사용** — Controller, Repository, ApiService 모두 SDK 원본 동작

### Notice SDK 연동

**SDK 의존성 체인:**
```
NoticeListView → NoticeListController → NoticeApiService → Dio
NoticeDetailView → NoticeDetailController → NoticeApiService → Dio
```

**구현:**

1. **NoticeApiService를 main.dart에서 전역 등록**
2. **NoticeBinding(appCode: 'demo')을 라우트에 직접 사용**
   ```dart
   GetPage(
     name: Routes.SDK_NOTICE_DEMO,
     page: () => const SdkNoticeDemoView(),
     binding: NoticeBinding(appCode: 'demo'),
   )
   ```
3. **NoticeListView는 SDK 원본 사용** — 실서버에서 공지사항 목록/상세 조회
4. **NoticeDetailView는 SDK 원본 라우팅** — Notice SDK가 제공하는 상세 화면 라우트 사용

## GetX 상태 관리 설계

### 1. SdkListController (SDK 목록 관리)

**파일:** `lib/app/modules/sdk_demos/controllers/sdk_list_controller.dart`

#### 반응형 상태 (.obs)

```dart
/// SDK 항목 목록 (비반응형)
final List<SdkItem> sdkItems = [
  SdkItem(...),
  SdkItem(...),
];
```

**설계 근거:**
- 목록은 정적이므로 반응형 불필요
- const 리스트로 선언 가능

#### 메서드 인터페이스

```dart
/// SDK 데모 화면으로 네비게이션
void navigateToSdk(String route) {
  Get.toNamed(route);
}
```

---

### 2. MockQnaController (QnA Mock 응답)

**파일:** `lib/app/modules/sdk_demos/controllers/mock_qna_controller.dart`

**상속:** `extends QnaController`

#### 반응형 상태 (.obs)

QnaController의 기존 상태 유지:
```dart
final title = ''.obs;
final body = ''.obs;
final isLoading = false.obs;
final titleError = ''.obs;
final bodyError = ''.obs;
final currentBodyLength = 0.obs;
```

#### 메서드 인터페이스

```dart
@override
Future<void> submitQuestion() async {
  // 1. 입력 검증 (부모 클래스 메서드 활용)
  if (!_validateInputs()) return;

  isLoading.value = true;

  try {
    // 2. 모의 딜레이 (2초)
    await Future.delayed(const Duration(seconds: 2));

    // 3. 성공 응답 시뮬레이션
    Get.snackbar(
      '성공',
      '질문이 제출되었습니다. 빠르게 답변드리겠습니다.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );

    // 4. 입력 필드 초기화
    title.value = '';
    body.value = '';
    currentBodyLength.value = 0;
  } catch (e) {
    // 5. 에러 응답 시뮬레이션 (선택적)
    Get.snackbar(
      '오류',
      '네트워크 연결을 확인해주세요',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}
```

**설계 근거:**
- QnaController를 상속하여 기존 상태와 유효성 검증 로직 재사용
- submitQuestion() 메서드만 오버라이드하여 모의 응답 처리
- QnaRepository, QnaApiService 호출 제거 (Dio 의존성 불필요)

---

### 3. MockNoticeListController (Notice Mock 데이터)

**파일:** `lib/app/modules/sdk_demos/controllers/mock_notice_list_controller.dart`

**상속:** `extends NoticeListController`

#### 반응형 상태 (.obs)

NoticeListController의 기존 상태 유지:
```dart
final pinnedNotices = <NoticeModel>[].obs;
final generalNotices = <NoticeModel>[].obs;
final isLoading = false.obs;
final errorMessage = ''.obs;
final currentPage = 1.obs;
final hasMorePages = true.obs;
```

#### 비반응형 상태

```dart
/// 모의 데이터 생성기
late final MockNoticeDataGenerator _dataGenerator;
```

#### 메서드 인터페이스

```dart
@override
void onInit() {
  super.onInit();
  _dataGenerator = MockNoticeDataGenerator();
  loadNotices(); // 초기 데이터 로드
}

@override
Future<void> loadNotices({bool refresh = false}) async {
  if (refresh) {
    currentPage.value = 1;
    generalNotices.clear();
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    // 모의 딜레이 (500ms)
    await Future.delayed(const Duration(milliseconds: 500));

    if (currentPage.value == 1) {
      // 첫 페이지: 고정 공지 + 일반 공지
      pinnedNotices.value = _dataGenerator.generatePinnedNotices();
      generalNotices.value = _dataGenerator.generateGeneralNotices(page: 1);
    } else {
      // 추가 페이지: 일반 공지만 추가
      final newNotices = _dataGenerator.generateGeneralNotices(page: currentPage.value);
      generalNotices.addAll(newNotices);
    }

    currentPage.value++;
    hasMorePages.value = currentPage.value <= 3; // 최대 3페이지
  } catch (e) {
    errorMessage.value = '네트워크 연결을 확인해주세요';
  } finally {
    isLoading.value = false;
  }
}

@override
Future<void> loadMoreNotices() async {
  if (!hasMorePages.value || isLoading.value) return;
  await loadNotices();
}
```

**설계 근거:**
- NoticeListController를 상속하여 기존 상태와 무한 스크롤 로직 재사용
- loadNotices() 메서드만 오버라이드하여 모의 데이터 생성
- NoticeApiService 호출 제거 (Dio 의존성 불필요)
- MockNoticeDataGenerator 클래스로 데이터 생성 로직 분리

---

### 4. MockNoticeDataGenerator (Helper 클래스)

**파일:** `lib/app/modules/sdk_demos/controllers/mock_notice_list_controller.dart` (동일 파일 내 정의)

```dart
/// 모의 공지사항 데이터 생성기
class MockNoticeDataGenerator {
  /// 고정 공지 생성 (2개)
  List<NoticeModel> generatePinnedNotices() {
    return [
      NoticeModel(
        id: 1,
        title: '🎉 v1.0.0 업데이트 안내',
        content: '새로운 기능이 추가되었습니다.\n\n- QnA 기능 추가\n- 디자인 시스템 개선',
        category: 'update',
        isPinned: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NoticeModel(
        id: 2,
        title: '🔧 서비스 점검 안내',
        content: '2026년 2월 15일 오전 2시~5시 서비스 점검 예정입니다.',
        category: 'maintenance',
        isPinned: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// 일반 공지 생성 (페이지당 10개)
  List<NoticeModel> generateGeneralNotices({required int page}) {
    return List.generate(10, (index) {
      final id = (page - 1) * 10 + index + 3; // ID는 3부터 시작 (고정 공지 2개 이후)
      return NoticeModel(
        id: id,
        title: '공지사항 제목 $id',
        content: '공지사항 내용입니다. 마크다운 형식으로 작성할 수 있습니다.\n\n# 제목\n- 항목 1\n- 항목 2',
        category: 'general',
        isPinned: false,
        createdAt: DateTime.now().subtract(Duration(days: id)),
        updatedAt: DateTime.now().subtract(Duration(days: id)),
      );
    });
  }
}
```

---

## View 설계 (Junior Developer가 구현)

### 1. SdkListView (SDK 목록 화면)

**파일:** `lib/app/modules/sdk_demos/views/sdk_list_view.dart`

#### Widget 구조

```dart
class SdkListView extends GetView<SdkListController> {
  const SdkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('SDK Demos'),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          _buildDescriptionText(),
          const SizedBox(height: 16),
          _buildSdkItem(controller.sdkItems[0]), // QnA
          const SizedBox(height: 12),
          _buildSdkItem(controller.sdkItems[1]), // Notice
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDescriptionText() {
    return const Text(
      '각 SDK 패키지의 UI/UX를 테스트할 수 있습니다.',
      style: TextStyle(fontSize: 14, color: Color(0xFF5E5E5E)),
    );
  }

  Widget _buildSdkItem(SdkItem item) {
    // SketchCard 기반 SDK 항목 카드
    // design-spec.md 참조
    return SketchCard(
      child: InkWell(
        onTap: () => controller.navigateToSdk(item.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(item.icon, size: 40, color: const Color(0xFF2196F3)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF5E5E5E)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8E8E8E)),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 2. SdkQnaDemoView (QnA 데모 화면)

**파일:** `lib/app/modules/sdk_demos/views/sdk_qna_demo_view.dart`

#### Widget 구조

```dart
class SdkQnaDemoView extends StatelessWidget {
  const SdkQnaDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    // SDK 위젯 직접 사용 (SDK 원본 수정 불필요)
    return const QnaSubmitView();
  }
}
```

**설계 근거:**
- QnaSubmitView는 SDK 패키지의 원본 위젯
- Binding에서 MockQnaController를 등록했으므로 모의 응답 동작
- AppBar, 입력 필드, 버튼 모두 SDK 위젯 그대로 사용

---

### 3. SdkNoticeDemoView (Notice 데모 화면)

**파일:** `lib/app/modules/sdk_demos/views/sdk_notice_demo_view.dart`

#### Widget 구조

```dart
class SdkNoticeDemoView extends StatelessWidget {
  const SdkNoticeDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    // SDK 위젯 직접 사용 (SDK 원본 수정 불필요)
    return const NoticeListView();
  }
}
```

**설계 근거:**
- NoticeListView는 SDK 패키지의 원본 위젯
- Binding에서 MockNoticeListController를 등록했으므로 모의 데이터 표시
- AppBar, RefreshIndicator, 카드 목록 모두 SDK 위젯 그대로 사용

---

## Binding 설계

### 1. SdkListBinding

**파일:** `lib/app/modules/sdk_demos/bindings/sdk_list_binding.dart`

```dart
class SdkListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SdkListController>(() => SdkListController());
  }
}
```

---

### 2. SdkQnaDemoBinding

**파일:** `lib/app/modules/sdk_demos/bindings/sdk_qna_demo_binding.dart`

```dart
class SdkQnaDemoBinding extends Bindings {
  @override
  void dependencies() {
    // MockQnaController를 QnaController로 등록
    Get.lazyPut<QnaController>(() => MockQnaController());
  }
}
```

**설계 근거:**
- QnaController 타입으로 등록하되 실제 인스턴스는 MockQnaController
- QnaSubmitView는 Get.find<QnaController>()로 가져오므로 MockQnaController가 주입됨
- QnaApiService, QnaRepository 등록 불필요 (Mock Controller가 직접 응답 처리)

---

### 3. SdkNoticeDemoBinding

**파일:** `lib/app/modules/sdk_demos/bindings/sdk_notice_demo_binding.dart`

```dart
class SdkNoticeDemoBinding extends Bindings {
  @override
  void dependencies() {
    // MockNoticeListController를 NoticeListController로 등록
    Get.lazyPut<NoticeListController>(() => MockNoticeListController());
  }
}
```

**설계 근거:**
- NoticeListController 타입으로 등록하되 실제 인스턴스는 MockNoticeListController
- NoticeListView는 Get.find<NoticeListController>()로 가져오므로 MockNoticeListController가 주입됨
- NoticeApiService 등록 불필요 (Mock Controller가 직접 데이터 생성)

---

## 모델 설계

### SdkItem (SDK 항목 모델)

**파일:** `lib/app/modules/sdk_demos/models/sdk_item.dart`

```dart
import 'package:flutter/material.dart';

/// SDK 항목 데이터 모델
class SdkItem {
  /// SDK 이름
  final String name;

  /// SDK 아이콘
  final IconData icon;

  /// 네비게이션 라우트
  final String route;

  /// SDK 설명
  final String description;

  const SdkItem({
    required this.name,
    required this.icon,
    required this.route,
    required this.description,
  });
}
```

**사용 예시:**
```dart
const SdkItem(
  name: 'QnA SDK',
  icon: Icons.question_answer,
  route: Routes.SDK_QNA_DEMO,
  description: '질문 제출 기능 테스트',
)
```

---

## 라우팅 설계

### Route Name (app_routes.dart)

**파일:** `lib/app/routes/app_routes.dart`

```dart
abstract class Routes {
  static const HOME = '/';
  static const WIDGET_CATALOG = '/widgets';
  static const WIDGET_DEMO = '/widgets/demo';
  static const PAINTER_CATALOG = '/painters';
  static const PAINTER_DEMO = '/painters/demo';
  static const THEME_SHOWCASE = '/theme';
  static const COLOR_PALETTES = '/colors';
  static const TOKENS = '/tokens';

  /// SDK 데모 목록 (신규)
  static const SDK_DEMOS = '/sdk-demos';

  /// QnA 데모 (신규)
  static const SDK_QNA_DEMO = '/sdk-demos/qna';

  /// Notice 데모 (신규)
  static const SDK_NOTICE_DEMO = '/sdk-demos/notice';
}
```

---

### Route Definition (app_pages.dart)

**파일:** `lib/app/routes/app_pages.dart`

```dart
import '../modules/sdk_demos/views/sdk_list_view.dart';
import '../modules/sdk_demos/bindings/sdk_list_binding.dart';
import '../modules/sdk_demos/views/sdk_qna_demo_view.dart';
import '../modules/sdk_demos/bindings/sdk_qna_demo_binding.dart';
import '../modules/sdk_demos/views/sdk_notice_demo_view.dart';
import '../modules/sdk_demos/bindings/sdk_notice_demo_binding.dart';

class AppPages {
  static final routes = [
    // 기존 라우트들...

    // SDK 데모 목록 (신규)
    GetPage(
      name: Routes.SDK_DEMOS,
      page: () => const SdkListView(),
      binding: SdkListBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // QnA 데모 (신규)
    GetPage(
      name: Routes.SDK_QNA_DEMO,
      page: () => const SdkQnaDemoView(),
      binding: SdkQnaDemoBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Notice 데모 (신규)
    GetPage(
      name: Routes.SDK_NOTICE_DEMO,
      page: () => const SdkNoticeDemoView(),
      binding: SdkNoticeDemoBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

---

### Navigation

```dart
// 홈에서 SDK 데모 목록으로 이동
Get.toNamed(Routes.SDK_DEMOS);

// SDK 목록에서 QnA 데모로 이동
Get.toNamed(Routes.SDK_QNA_DEMO);

// SDK 목록에서 Notice 데모로 이동
Get.toNamed(Routes.SDK_NOTICE_DEMO);

// Notice 목록에서 상세로 이동 (SDK 원본 라우팅)
// NoticeListCard의 onTap에서 처리 (SDK 내부 로직)
```

---

## 홈 화면 수정

### HomeController 수정

**파일:** `lib/app/modules/home/controllers/home_controller.dart`

```dart
final List<CategoryItem> categories = const [
  CategoryItem(
    name: 'Widgets',
    icon: LucideIcons.layoutGrid,
    route: Routes.WIDGET_CATALOG,
    itemCount: 13,
    description: '스케치 스타일 UI 컴포넌트',
  ),
  CategoryItem(
    name: 'Painters',
    icon: LucideIcons.paintbrush,
    route: Routes.PAINTER_CATALOG,
    itemCount: 5,
    description: 'CustomPainter 기반 그래픽',
  ),
  CategoryItem(
    name: 'Theme',
    icon: LucideIcons.palette,
    route: Routes.THEME_SHOWCASE,
    itemCount: 6,
    description: '테마 변형 및 밝기 모드',
  ),
  CategoryItem(
    name: 'Colors',
    icon: LucideIcons.droplets,
    route: Routes.COLOR_PALETTES,
    itemCount: 6,
    description: 'Base, Semantic, Custom 팔레트',
  ),
  CategoryItem(
    name: 'Tokens',
    icon: LucideIcons.ruler,
    route: Routes.TOKENS,
    description: 'Spacing, Stroke, Shadow 토큰',
  ),
  // 신규 추가
  CategoryItem(
    name: 'SDK Demos',
    icon: LucideIcons.package,
    route: Routes.SDK_DEMOS,
    itemCount: 2,
    description: 'QnA 및 Notice SDK 데모',
  ),
];
```

---

## 성능 최적화 전략

### const 생성자

- 정적 위젯은 `const` 사용
- `const SdkListView()`, `const QnaSubmitView()`, `const NoticeListView()`
- `const EdgeInsets`, `const SizedBox`, `const Text`

### Obx 범위 최소화

- SDK 위젯 내부에서 Obx 사용 (SDK 원본)
- 데모 View는 const StatelessWidget으로 선언
- Mock Controller의 상태 변경이 SDK 위젯 내부 Obx에서만 반응

### GetView 사용

- SDK 위젯들이 GetView<Controller> 패턴 사용
- Controller는 Binding에서 한 번만 생성
- 불필요한 rebuild 방지

---

## 에러 처리 전략

### Mock Controller 에러 처리

```dart
// MockQnaController
try {
  await Future.delayed(const Duration(seconds: 2));
  // 성공 스낵바
} catch (e) {
  Get.snackbar(
    '오류',
    '네트워크 연결을 확인해주세요',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFF44336),
    colorText: Colors.white,
  );
} finally {
  isLoading.value = false;
}
```

### View 에러 표시

- SDK 위젯이 errorMessage.value 확인 후 UI 표시
- Mock Controller에서 errorMessage.value 설정 가능
- 재시도 버튼 제공 (SDK 원본 기능)

---

## 패키지 의존성 확인

### pubspec.yaml 수정

**파일:** `apps/mobile/apps/design_system_demo/pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  core:
    path: ../../packages/core
  design_system:
    path: ../../packages/design_system
  qna:                      # 신규 추가
    path: ../../packages/qna
  notice:                   # 신규 추가
    path: ../../packages/notice
  lucide_icons_flutter: ^1.1.0
```

**주의사항:**
- `melos bootstrap` 실행 필수
- `resolution: workspace` 추가 금지 (bootstrap 실패 원인)

---

## 작업 분배 계획 (CTO가 참조)

### Senior Developer 작업

1. **Mock Controller 구현**
   - `MockQnaController` 작성 (lib/app/modules/sdk_demos/controllers/mock_qna_controller.dart)
   - `MockNoticeListController` 작성 (lib/app/modules/sdk_demos/controllers/mock_notice_list_controller.dart)
   - `MockNoticeDataGenerator` 작성 (동일 파일 내)

2. **Controller + 비즈니스 로직**
   - `SdkListController` 작성 (lib/app/modules/sdk_demos/controllers/sdk_list_controller.dart)

3. **Binding 작성**
   - `SdkListBinding` 작성 (lib/app/modules/sdk_demos/bindings/sdk_list_binding.dart)
   - `SdkQnaDemoBinding` 작성 (lib/app/modules/sdk_demos/bindings/sdk_qna_demo_binding.dart)
   - `SdkNoticeDemoBinding` 작성 (lib/app/modules/sdk_demos/bindings/sdk_notice_demo_binding.dart)

4. **모델 작성**
   - `SdkItem` 작성 (lib/app/modules/sdk_demos/models/sdk_item.dart)

### Junior Developer 작업

1. **View + UI 위젯**
   - `SdkListView` 작성 (lib/app/modules/sdk_demos/views/sdk_list_view.dart)
   - `SdkQnaDemoView` 작성 (lib/app/modules/sdk_demos/views/sdk_qna_demo_view.dart)
   - `SdkNoticeDemoView` 작성 (lib/app/modules/sdk_demos/views/sdk_notice_demo_view.dart)

2. **Routing 업데이트**
   - `app_routes.dart` 수정 (SDK_DEMOS, SDK_QNA_DEMO, SDK_NOTICE_DEMO 추가)
   - `app_pages.dart` 수정 (GetPage 등록)

3. **홈 화면 수정**
   - `home_controller.dart` 수정 (SDK Demos 카테고리 추가)

4. **의존성 업데이트**
   - `pubspec.yaml` 수정 (qna, notice 패키지 추가)
   - `melos bootstrap` 실행

### 작업 의존성

- Junior는 Senior의 Controller/Binding 완성 후 시작 가능
- Controller 메서드, .obs 변수 정확히 일치시켜야 함
- pubspec.yaml 수정 후 반드시 `melos bootstrap` 실행

---

## 구현 순서 (파일별)

### 1단계: 의존성 및 모델 (Senior)

1. `pubspec.yaml` 수정 (qna, notice 패키지 추가)
2. `melos bootstrap` 실행
3. `lib/app/modules/sdk_demos/models/sdk_item.dart` 작성

### 2단계: Mock Controller (Senior)

4. `lib/app/modules/sdk_demos/controllers/mock_qna_controller.dart` 작성
5. `lib/app/modules/sdk_demos/controllers/mock_notice_list_controller.dart` 작성 (MockNoticeDataGenerator 포함)

### 3단계: SDK 목록 Controller (Senior)

6. `lib/app/modules/sdk_demos/controllers/sdk_list_controller.dart` 작성

### 4단계: Binding (Senior)

7. `lib/app/modules/sdk_demos/bindings/sdk_list_binding.dart` 작성
8. `lib/app/modules/sdk_demos/bindings/sdk_qna_demo_binding.dart` 작성
9. `lib/app/modules/sdk_demos/bindings/sdk_notice_demo_binding.dart` 작성

### 5단계: View (Junior)

10. `lib/app/modules/sdk_demos/views/sdk_list_view.dart` 작성
11. `lib/app/modules/sdk_demos/views/sdk_qna_demo_view.dart` 작성
12. `lib/app/modules/sdk_demos/views/sdk_notice_demo_view.dart` 작성

### 6단계: Routing (Junior)

13. `lib/app/routes/app_routes.dart` 수정 (Routes 추가)
14. `lib/app/routes/app_pages.dart` 수정 (GetPage 등록)

### 7단계: 홈 화면 수정 (Junior)

15. `lib/app/modules/home/controllers/home_controller.dart` 수정 (SDK Demos 카테고리 추가)

---

## 검증 기준

- [ ] GetX 패턴 준수 (Controller, View, Binding 분리)
- [ ] Mock Controller가 SDK Controller를 상속하여 구현
- [ ] SDK 원본 코드 수정 없음 (packages/qna/, packages/notice/)
- [ ] const 최적화 적용 (정적 위젯)
- [ ] 에러 처리 완비 (스낵바)
- [ ] 라우팅 설정 정확 (GetPage 등록)
- [ ] pubspec.yaml 의존성 추가 (qna, notice)
- [ ] melos bootstrap 실행 확인
- [ ] CLAUDE.md 표준 준수 (한글 주석, 테스트 코드 없음)

---

## 참고 자료

- **GetX 문서**: https://pub.dev/packages/get
- **QnA SDK README**: `packages/qna/README.md`
- **Notice SDK README**: `packages/notice/README.md`
- **Design System**: `.claude/guide/mobile/design_system.md`
- **GetX Best Practices**: `.claude/guide/mobile/getx_best_practices.md`
- **Common Patterns**: `.claude/guide/mobile/common_patterns.md`
