# Mobile 작업 분배 계획: SDK 데모 시스템

## 개요

design_system_demo 앱을 확장하여 qna, notice SDK의 UI/UX를 실제 환경에서 검증할 수 있는 데모 시스템을 구축합니다. Mock Controller 패턴을 사용하여 서버 연동 없이도 SDK 동작을 시뮬레이션하며, SDK 원본 코드는 수정하지 않습니다.

---

## 작업 분배 전략

### 병렬 작업 가능 기준

- **그룹 1 (병렬)**: Model, Mock Controllers, SdkListController, Bindings → 서로 독립적으로 개발 가능
- **그룹 2 (순차)**: Views, Routing → 그룹 1 완료 후 Controller 인터페이스 참조하여 개발

### 파일 충돌 방지

- 모든 신규 파일은 `lib/app/modules/sdk_demos/` 하위에 생성
- 기존 파일 수정은 순차 실행 (home_controller.dart, app_routes.dart, app_pages.dart)

---

## 실행 그룹

### Group 1 (병렬 실행) — 기반 작업

**실행 조건**: 의존성 업데이트 후 즉시 시작

| Agent | 작업 범위 | 출력 파일 | 예상 소요 |
|-------|----------|----------|----------|
| flutter-developer | Model + SdkListController | sdk_item.dart, sdk_list_controller.dart | 30분 |
| flutter-developer | MockQnaController | mock_qna_controller.dart | 45분 |
| flutter-developer | MockNoticeListController + Data Generator | mock_notice_list_controller.dart | 1시간 |
| flutter-developer | Bindings (3개) | sdk_list_binding.dart, sdk_qna_demo_binding.dart, sdk_notice_demo_binding.dart | 20분 |

**병렬 실행 가능 이유**:
- 각 Controller는 독립적인 파일에 작성
- Mock Controllers는 SDK 원본 Controller를 상속하므로 SDK 패키지만 import
- Bindings는 Controller 타입만 참조 (구현 내용 불필요)

---

### Group 2 (병렬 실행) — Group 1 완료 후

**실행 조건**: Group 1의 모든 Controller 및 Binding 완성 후

| Agent | 작업 범위 | 출력 파일 | 예상 소요 |
|-------|----------|----------|----------|
| flutter-developer | SdkListView | sdk_list_view.dart | 40분 |
| flutter-developer | SdkQnaDemoView + SdkNoticeDemoView | sdk_qna_demo_view.dart, sdk_notice_demo_view.dart | 30분 |
| flutter-developer | Routing 업데이트 (app_routes.dart, app_pages.dart) | app_routes.dart, app_pages.dart | 20분 |
| flutter-developer | 홈 화면 수정 (home_controller.dart) | home_controller.dart | 15분 |

**병렬 실행 가능 이유**:
- SdkListView는 SdkListController의 메서드/상태만 참조 (충돌 없음)
- SDK 데모 Views는 SDK 원본 View를 렌더링하므로 단순 (충돌 없음)
- Routing, 홈 화면 수정은 각각 다른 파일 (충돌 없음)

---

## 작업 상세

### 1. Model + SdkListController (flutter-developer A)

#### 작업 내용

1. **SdkItem 모델 생성** (`lib/app/modules/sdk_demos/models/sdk_item.dart`)
   - 속성: name, icon, route, description
   - const 생성자 사용

2. **SdkListController 생성** (`lib/app/modules/sdk_demos/controllers/sdk_list_controller.dart`)
   - SDK 항목 리스트 정의 (QnA, Notice)
   - navigateToSdk(String route) 메서드 구현

#### Module Contracts (Controller 인터페이스)

```dart
// SdkListController
class SdkListController extends GetxController {
  /// SDK 항목 목록 (비반응형)
  final List<SdkItem> sdkItems = const [
    SdkItem(
      name: 'QnA SDK',
      icon: Icons.question_answer,
      route: Routes.SDK_QNA_DEMO,
      description: '질문 제출 기능 테스트',
    ),
    SdkItem(
      name: 'Notice SDK',
      icon: Icons.notifications,
      route: Routes.SDK_NOTICE_DEMO,
      description: '공지사항 목록/상세 테스트',
    ),
  ];

  /// SDK 데모 화면으로 네비게이션
  void navigateToSdk(String route);
}
```

#### 참고 문서

- `docs/demo-system/mobile-brief.md` (Section: 모델 설계)
- `docs/demo-system/mobile-design-spec.md` (Section: Screen 2)

---

### 2. MockQnaController (flutter-developer B)

#### 작업 내용

**MockQnaController 생성** (`lib/app/modules/sdk_demos/controllers/mock_qna_controller.dart`)

- QnaController 상속
- submitQuestion() 메서드 오버라이드
  - 입력 검증 (부모 클래스 메서드 활용)
  - 2초 딜레이 시뮬레이션
  - 성공 스낵바 표시
  - 입력 필드 초기화
  - 에러 처리 (catch 블록)

#### Module Contracts (Controller 인터페이스)

```dart
// MockQnaController
class MockQnaController extends QnaController {
  @override
  Future<void> submitQuestion() async {
    // 1. 입력 검증
    // 2. isLoading.value = true
    // 3. 2초 딜레이 (await Future.delayed)
    // 4. 성공 스낵바 (Get.snackbar)
    // 5. 입력 필드 초기화 (title.value = '', body.value = '')
    // 6. finally: isLoading.value = false
  }
}
```

#### 참고 문서

- `docs/demo-system/mobile-brief.md` (Section: GetX 상태 관리 설계 - MockQnaController)
- `packages/qna/lib/src/controllers/qna_controller.dart` (부모 클래스 참조)

---

### 3. MockNoticeListController + Data Generator (flutter-developer C)

#### 작업 내용

**MockNoticeListController 생성** (`lib/app/modules/sdk_demos/controllers/mock_notice_list_controller.dart`)

1. **MockNoticeListController 클래스**
   - NoticeListController 상속
   - loadNotices({bool refresh = false}) 메서드 오버라이드
     - refresh=true: 페이지 1로 초기화, generalNotices.clear()
     - 500ms 딜레이 시뮬레이션
     - 첫 페이지: 고정 공지 2개 + 일반 공지 10개
     - 추가 페이지: 일반 공지 10개씩 추가
     - hasMorePages: currentPage ≤ 3 (최대 3페이지)
   - loadMoreNotices() 메서드 오버라이드
     - hasMorePages 체크 후 loadNotices() 호출

2. **MockNoticeDataGenerator 클래스** (동일 파일 내)
   - generatePinnedNotices() 메서드: 고정 공지 2개 생성
   - generateGeneralNotices({required int page}) 메서드: 일반 공지 10개 생성

#### Module Contracts (Controller 인터페이스)

```dart
// MockNoticeListController
class MockNoticeListController extends NoticeListController {
  @override
  Future<void> loadNotices({bool refresh = false}) async {
    // 1. refresh=true → currentPage=1, generalNotices.clear()
    // 2. isLoading.value = true
    // 3. 500ms 딜레이
    // 4. currentPage==1 → pinnedNotices + generalNotices 로드
    // 5. currentPage>1 → generalNotices만 추가
    // 6. currentPage++, hasMorePages 설정
    // 7. finally: isLoading.value = false
  }

  @override
  Future<void> loadMoreNotices() async {
    // hasMorePages 체크 후 loadNotices() 호출
  }
}

// MockNoticeDataGenerator
class MockNoticeDataGenerator {
  List<NoticeModel> generatePinnedNotices();
  List<NoticeModel> generateGeneralNotices({required int page});
}
```

#### 참고 문서

- `docs/demo-system/mobile-brief.md` (Section: GetX 상태 관리 설계 - MockNoticeListController)
- `packages/notice/lib/src/controllers/notice_list_controller.dart` (부모 클래스 참조)

---

### 4. Bindings (flutter-developer D)

#### 작업 내용

1. **SdkListBinding** (`lib/app/modules/sdk_demos/bindings/sdk_list_binding.dart`)
   - SdkListController를 Get.lazyPut으로 등록

2. **SdkQnaDemoBinding** (`lib/app/modules/sdk_demos/bindings/sdk_qna_demo_binding.dart`)
   - MockQnaController를 QnaController 타입으로 등록

3. **SdkNoticeDemoBinding** (`lib/app/modules/sdk_demos/bindings/sdk_notice_demo_binding.dart`)
   - MockNoticeListController를 NoticeListController 타입으로 등록

#### Module Contracts (Binding 인터페이스)

```dart
// SdkListBinding
class SdkListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SdkListController>(() => SdkListController());
  }
}

// SdkQnaDemoBinding
class SdkQnaDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QnaController>(() => MockQnaController());
  }
}

// SdkNoticeDemoBinding
class SdkNoticeDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoticeListController>(() => MockNoticeListController());
  }
}
```

#### 참고 문서

- `docs/demo-system/mobile-brief.md` (Section: Binding 설계)

---

### 5. SdkListView (flutter-developer E)

#### 작업 내용

**SdkListView 생성** (`lib/app/modules/sdk_demos/views/sdk_list_view.dart`)

- GetView<SdkListController> 상속
- AppBar: 제목 "SDK Demos", 뒤로가기 버튼
- Body: ListView
  - 안내 문구 ("각 SDK 패키지의 UI/UX를 테스트할 수 있습니다.")
  - SDKItemCard (QnA) - SketchCard 기반, InkWell, onTap: navigateToSdk(route)
  - SDKItemCard (Notice) - SketchCard 기반, InkWell, onTap: navigateToSdk(route)

#### Controller 연결점

```dart
// View에서 Controller 메서드 호출
onTap: () => controller.navigateToSdk(item.route)

// View에서 Controller 상태 참조
controller.sdkItems[0] // QnA 항목
controller.sdkItems[1] // Notice 항목
```

#### 참고 문서

- `docs/demo-system/mobile-design-spec.md` (Section: Screen 2)
- `docs/demo-system/mobile-brief.md` (Section: View 설계 - SdkListView)
- `.claude/guide/mobile/getx_best_practices.md`

---

### 6. SDK 데모 Views (flutter-developer F)

#### 작업 내용

1. **SdkQnaDemoView** (`lib/app/modules/sdk_demos/views/sdk_qna_demo_view.dart`)
   - StatelessWidget
   - build() 메서드: `return const QnaSubmitView();`

2. **SdkNoticeDemoView** (`lib/app/modules/sdk_demos/views/sdk_notice_demo_view.dart`)
   - StatelessWidget
   - build() 메서드: `return const NoticeListView();`

#### Controller 연결점

- **QnA**: QnaSubmitView 내부에서 Get.find<QnaController>() 호출 → MockQnaController 주입됨
- **Notice**: NoticeListView 내부에서 Get.find<NoticeListController>() 호출 → MockNoticeListController 주입됨

#### 참고 문서

- `docs/demo-system/mobile-design-spec.md` (Section: Screen 3, 4)
- `docs/demo-system/mobile-brief.md` (Section: View 설계)

---

### 7. Routing 업데이트 (flutter-developer G)

#### 작업 내용

1. **app_routes.dart 수정** (`lib/app/routes/app_routes.dart`)
   - Routes 클래스에 상수 추가:
     ```dart
     static const SDK_DEMOS = '/sdk-demos';
     static const SDK_QNA_DEMO = '/sdk-demos/qna';
     static const SDK_NOTICE_DEMO = '/sdk-demos/notice';
     ```

2. **app_pages.dart 수정** (`lib/app/routes/app_pages.dart`)
   - GetPage 등록:
     ```dart
     GetPage(
       name: Routes.SDK_DEMOS,
       page: () => const SdkListView(),
       binding: SdkListBinding(),
       transition: Transition.fadeIn,
       transitionDuration: const Duration(milliseconds: 300),
     ),
     GetPage(
       name: Routes.SDK_QNA_DEMO,
       page: () => const SdkQnaDemoView(),
       binding: SdkQnaDemoBinding(),
       transition: Transition.fadeIn,
       transitionDuration: const Duration(milliseconds: 300),
     ),
     GetPage(
       name: Routes.SDK_NOTICE_DEMO,
       page: () => const SdkNoticeDemoView(),
       binding: SdkNoticeDemoBinding(),
       transition: Transition.fadeIn,
       transitionDuration: const Duration(milliseconds: 300),
     ),
     ```

#### 참고 문서

- `docs/demo-system/mobile-brief.md` (Section: 라우팅 설계)

---

### 8. 홈 화면 수정 (flutter-developer H)

#### 작업 내용

**home_controller.dart 수정** (`lib/app/modules/home/controllers/home_controller.dart`)

- categories 리스트에 신규 CategoryItem 추가:
  ```dart
  CategoryItem(
    name: 'SDK Demos',
    icon: LucideIcons.package,
    route: Routes.SDK_DEMOS,
    itemCount: 2,
    description: 'QnA 및 Notice SDK 데모',
  ),
  ```

#### 참고 문서

- `docs/demo-system/mobile-design-spec.md` (Section: Screen 1)

---

## 의존성 업데이트 (사전 작업)

### pubspec.yaml 수정

**파일**: `apps/mobile/apps/design_system_demo/pubspec.yaml`

```yaml
dependencies:
  # 기존 의존성...
  qna:
    path: ../../packages/qna
  notice:
    path: ../../packages/notice
```

### 실행 명령

```bash
cd apps/mobile
melos bootstrap
```

---

## 에러 계약 (Error Contracts)

### API 에러 코드별 처리
- **400**: 입력 검증 실패 → "제목과 내용을 확인해주세요"
- **401/403**: 인증 필요 → "인증이 필요합니다. 다시 로그인해주세요"
- **404**: 리소스 미존재 → "서비스 설정 오류가 발생했습니다"
- **500+**: 서버 오류 → "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
- **네트워크 타임아웃**: → "네트워크 연결을 확인해주세요"

### View 에러 표시
- QnA: Get.snackbar + SketchModal (에러 모달)
- Notice: errorMessage.obs → 에러 상태 UI (아이콘 + 메시지 + 재시도 버튼)

---

## 검증 기준 (CTO 리뷰)

### GetX 패턴

- [ ] Controller, View, Binding 분리 준수
- [ ] GetView<T> 패턴 사용
- [ ] Get.lazyPut으로 의존성 등록
- [ ] .obs 변수는 Controller에만 존재

### Mock 전략

- [ ] MockQnaController가 QnaController 상속
- [ ] MockNoticeListController가 NoticeListController 상속
- [ ] submitQuestion(), loadNotices() 메서드 오버라이드
- [ ] SDK 원본 코드 수정 없음

### 성능 최적화

- [ ] const 생성자 사용 (정적 위젯)
- [ ] Obx 범위 최소화 (SDK 위젯 내부에서만)
- [ ] GetView 사용으로 불필요한 rebuild 방지

### 코드 품질

- [ ] 주석은 한글로 작성 (기술 용어는 영어)
- [ ] 파일 구조: modules/sdk_demos/controllers|views|bindings|models
- [ ] Import 정리: 패키지 → 상대 경로 순서

### 에러 처리

- [ ] MockQnaController: try-catch-finally 구조
- [ ] MockNoticeListController: errorMessage.value 설정
- [ ] 스낵바로 사용자 피드백 제공

### Design System 준수

- [ ] SketchCard 사용 (SDK 아이템 카드)
- [ ] QnaSubmitView, NoticeListView 원본 렌더링
- [ ] 라이트/다크 테마 자동 적용

### Routing

- [ ] app_routes.dart에 상수 정의
- [ ] app_pages.dart에 GetPage 등록
- [ ] Binding 연결 정확

---

## 실행 순서 (CTO가 Task 호출 시)

### 단계 1: 의존성 업데이트
```bash
# pubspec.yaml 수정 (qna, notice 추가)
# melos bootstrap 실행
```

### 단계 2: Group 1 병렬 실행

**4개 Task 동시 호출** (flutter-developer A, B, C, D)

1. Task A: Model + SdkListController
2. Task B: MockQnaController
3. Task C: MockNoticeListController + Data Generator
4. Task D: Bindings (3개)

### 단계 3: Group 2 병렬 실행 (Group 1 완료 후)

**4개 Task 동시 호출** (flutter-developer E, F, G, H)

5. Task E: SdkListView
6. Task F: SDK 데모 Views (QnA, Notice)
7. Task G: Routing 업데이트 (app_routes.dart, app_pages.dart)
8. Task H: 홈 화면 수정 (home_controller.dart)

---

## Task 프롬프트 템플릿

### Group 1 - Task A (Model + SdkListController)

```
Feature: demo-system
Platform: mobile

작업 범위: Model + SdkListController 구현

출력 파일:
- lib/app/modules/sdk_demos/models/sdk_item.dart
- lib/app/modules/sdk_demos/controllers/sdk_list_controller.dart

참고 문서:
- docs/demo-system/mobile-brief.md (Section: 모델 설계, GetX 상태 관리 설계 - SdkListController)
- docs/demo-system/mobile-design-spec.md (Section: Screen 2)
- docs/demo-system/mobile-work-plan.md (Section: 1. Model + SdkListController)

Module Contracts:
- SdkItem: name, icon, route, description (const 생성자)
- SdkListController.sdkItems: List<SdkItem> (QnA, Notice 항목)
- SdkListController.navigateToSdk(String route): void

검증:
- const 생성자 사용
- sdkItems 리스트에 QnA, Notice 2개 항목 포함
- navigateToSdk() 메서드 Get.toNamed() 호출
```

### Group 1 - Task B (MockQnaController)

```
Feature: demo-system
Platform: mobile

작업 범위: MockQnaController 구현

출력 파일:
- lib/app/modules/sdk_demos/controllers/mock_qna_controller.dart

참고 문서:
- docs/demo-system/mobile-brief.md (Section: GetX 상태 관리 설계 - MockQnaController)
- docs/demo-system/mobile-work-plan.md (Section: 2. MockQnaController)
- packages/qna/lib/src/controllers/qna_controller.dart (부모 클래스)

Module Contracts:
- extends QnaController
- submitQuestion() 메서드 오버라이드
- 2초 딜레이 시뮬레이션
- 성공 스낵바 표시
- 입력 필드 초기화

검증:
- QnaController 상속
- try-catch-finally 구조
- Get.snackbar 사용 (성공/에러)
- isLoading.value 상태 관리
```

### Group 1 - Task C (MockNoticeListController)

```
Feature: demo-system
Platform: mobile

작업 범위: MockNoticeListController + MockNoticeDataGenerator 구현

출력 파일:
- lib/app/modules/sdk_demos/controllers/mock_notice_list_controller.dart

참고 문서:
- docs/demo-system/mobile-brief.md (Section: GetX 상태 관리 설계 - MockNoticeListController)
- docs/demo-system/mobile-work-plan.md (Section: 3. MockNoticeListController)
- packages/notice/lib/src/controllers/notice_list_controller.dart (부모 클래스)

Module Contracts:
- MockNoticeListController extends NoticeListController
- loadNotices({bool refresh = false}) 메서드 오버라이드
- MockNoticeDataGenerator.generatePinnedNotices() → List<NoticeModel>
- MockNoticeDataGenerator.generateGeneralNotices({required int page}) → List<NoticeModel>

검증:
- NoticeListController 상속
- 고정 공지 2개, 일반 공지 10개씩 생성
- 페이지네이션 (최대 3페이지)
- 500ms 딜레이 시뮬레이션
```

### Group 1 - Task D (Bindings)

```
Feature: demo-system
Platform: mobile

작업 범위: Bindings 3개 구현

출력 파일:
- lib/app/modules/sdk_demos/bindings/sdk_list_binding.dart
- lib/app/modules/sdk_demos/bindings/sdk_qna_demo_binding.dart
- lib/app/modules/sdk_demos/bindings/sdk_notice_demo_binding.dart

참고 문서:
- docs/demo-system/mobile-brief.md (Section: Binding 설계)
- docs/demo-system/mobile-work-plan.md (Section: 4. Bindings)

Module Contracts:
- SdkListBinding: Get.lazyPut<SdkListController>
- SdkQnaDemoBinding: Get.lazyPut<QnaController>(() => MockQnaController())
- SdkNoticeDemoBinding: Get.lazyPut<NoticeListController>(() => MockNoticeListController())

검증:
- Get.lazyPut 사용
- MockQnaController를 QnaController 타입으로 등록
- MockNoticeListController를 NoticeListController 타입으로 등록
```

### Group 2 - Task E (SdkListView)

```
Feature: demo-system
Platform: mobile

작업 범위: SdkListView 구현

출력 파일:
- lib/app/modules/sdk_demos/views/sdk_list_view.dart

참고 문서:
- docs/demo-system/mobile-design-spec.md (Section: Screen 2)
- docs/demo-system/mobile-brief.md (Section: View 설계 - SdkListView)
- docs/demo-system/mobile-work-plan.md (Section: 5. SdkListView)

Controller 연결점:
- controller.sdkItems: SDK 항목 리스트
- controller.navigateToSdk(String route): 네비게이션 메서드

검증:
- GetView<SdkListController> 상속
- SketchCard 기반 SDK 아이템 카드
- InkWell onTap: controller.navigateToSdk(item.route)
- const 생성자 사용
```

### Group 2 - Task F (SDK 데모 Views)

```
Feature: demo-system
Platform: mobile

작업 범위: SdkQnaDemoView + SdkNoticeDemoView 구현

출력 파일:
- lib/app/modules/sdk_demos/views/sdk_qna_demo_view.dart
- lib/app/modules/sdk_demos/views/sdk_notice_demo_view.dart

참고 문서:
- docs/demo-system/mobile-design-spec.md (Section: Screen 3, 4)
- docs/demo-system/mobile-brief.md (Section: View 설계)
- docs/demo-system/mobile-work-plan.md (Section: 6. SDK 데모 Views)

검증:
- StatelessWidget
- SdkQnaDemoView: return const QnaSubmitView();
- SdkNoticeDemoView: return const NoticeListView();
- SDK 원본 위젯 직접 렌더링
```

### Group 2 - Task G (Routing)

```
Feature: demo-system
Platform: mobile

작업 범위: app_routes.dart, app_pages.dart 수정

출력 파일:
- lib/app/routes/app_routes.dart (수정)
- lib/app/routes/app_pages.dart (수정)

참고 문서:
- docs/demo-system/mobile-brief.md (Section: 라우팅 설계)
- docs/demo-system/mobile-work-plan.md (Section: 7. Routing 업데이트)

검증:
- Routes.SDK_DEMOS = '/sdk-demos'
- Routes.SDK_QNA_DEMO = '/sdk-demos/qna'
- Routes.SDK_NOTICE_DEMO = '/sdk-demos/notice'
- GetPage 등록 (Binding, transition 포함)
```

### Group 2 - Task H (홈 화면 수정)

```
Feature: demo-system
Platform: mobile

작업 범위: home_controller.dart 수정

출력 파일:
- lib/app/modules/home/controllers/home_controller.dart (수정)

참고 문서:
- docs/demo-system/mobile-design-spec.md (Section: Screen 1)
- docs/demo-system/mobile-work-plan.md (Section: 8. 홈 화면 수정)

검증:
- categories 리스트에 SDK Demos CategoryItem 추가
- icon: LucideIcons.package
- itemCount: 2
- description: 'QnA 및 Notice SDK 데모'
```

---

## 예상 총 소요 시간

- **Group 1 (병렬)**: 최대 1시간 (가장 긴 Task C 기준)
- **Group 2 (병렬)**: 최대 40분 (가장 긴 Task E 기준)
- **총 예상 시간**: 약 1시간 40분

---

## 참고 자료

- **GetX 문서**: https://pub.dev/packages/get
- **QnA SDK**: `packages/qna/README.md`, `packages/qna/lib/src/controllers/qna_controller.dart`
- **Notice SDK**: `packages/notice/README.md`, `packages/notice/lib/src/controllers/notice_list_controller.dart`
- **Design System**: `.claude/guide/mobile/design_system.md`
- **GetX Best Practices**: `.claude/guide/mobile/getx_best_practices.md`
- **Common Patterns**: `.claude/guide/mobile/common_patterns.md`

---

## 통합 검증 단계

Group 2 완료 후, 다음 항목을 검증합니다:
- [ ] melos analyze — 정적 분석 이슈 없음
- [ ] SDK 목록 화면에서 QnA/Notice 진입 가능
- [ ] QnA 질문 제출 후 성공/에러 처리 정상
- [ ] Notice 목록 → 상세 네비게이션 정상
- [ ] 라이트/다크 테마 전환 시 SDK 위젯 스타일 정상

---

## 다음 단계

CTO가 이 work-plan.md를 참조하여:

1. **Group 1 Task 4개를 병렬 호출** (flutter-developer A, B, C, D)
2. Group 1 완료 확인
3. **Group 2 Task 4개를 병렬 호출** (flutter-developer E, F, G, H)
4. Group 2 완료 확인
5. 통합 리뷰 진행 (mobile-cto-review.md 생성)
