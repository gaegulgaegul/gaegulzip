# 기술 아키텍처 설계: 박스 관리 기능 개선 (wowa-box)

## 개요
크로스핏 박스 검색 UX를 단순화하고, 박스 생성 안정성을 개선합니다. 기존의 이름/지역 분리 검색을 통합 키워드 검색으로 변경하고, 300ms debounce를 적용하여 실시간 검색 경험을 제공합니다. 5가지 UI 상태(초기/로딩/결과 없음/결과 표시/에러)를 명확히 구분하여 사용자 피드백을 강화합니다.

## 모듈 구조 (apps/wowa/lib/app/modules/box/)

### 디렉토리 구조
```
modules/
└── box/
    ├── controllers/
    │   ├── box_search_controller.dart       # 박스 검색 컨트롤러 (개선)
    │   └── box_create_controller.dart       # 박스 생성 컨트롤러 (현행 유지)
    ├── views/
    │   ├── box_search_view.dart             # 박스 검색 화면 (개선)
    │   └── box_create_view.dart             # 박스 생성 화면 (현행 유지)
    └── bindings/
        ├── box_search_binding.dart          # 박스 검색 바인딩
        └── box_create_binding.dart          # 박스 생성 바인딩
```

## GetX 상태 관리 설계

### Controller 1: BoxSearchController (개선)

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_search_controller.dart`

#### 반응형 상태 (.obs)
```dart
/// 통합 검색 키워드 (박스 이름 또는 지역)
final keyword = ''.obs;

/// 검색 중 로딩 상태
final isLoading = false.obs;

/// 검색 결과 목록
final searchResults = <BoxModel>[].obs;

/// 현재 소속 박스 (단일 박스 정책)
final currentBox = Rxn<BoxModel>();

/// API 에러 메시지
final errorMessage = ''.obs;
```

**설계 근거**:
- `keyword`: TextEditingController.onChanged로 업데이트, Obx로 UI 상태 결정 (초기/검색어 입력)
- `isLoading`: API 호출 중 CircularProgressIndicator 표시
- `searchResults`: ListView.builder 데이터 소스, 반응형 필요
- `currentBox`: 박스 생성 시 단일 박스 정책 적용 (기존 박스에서 탈퇴)
- `errorMessage`: 네트워크 에러 시 Empty State로 표시

#### 비반응형 상태
```dart
/// Repository 의존성
late final BoxRepository _repository;

/// 검색 입력 컨트롤러
late final TextEditingController searchController;

/// Debounce Worker
Worker? _debounceWorker;
```

**설계 근거**:
- Repository는 의존성 주입, UI 변경 불필요
- searchController는 TextField 바인딩, 반응형 아님
- _debounceWorker는 onClose에서 dispose 필요

#### 메서드 인터페이스
```dart
/// 박스 검색 (API 호출) — 300ms debounce 적용
Future<void> searchBoxes() async {
  // 1. 검색어 빈 값 체크 (비어있으면 목록 초기화)
  if (keyword.value.trim().isEmpty) {
    searchResults.clear();
    errorMessage.value = '';
    return;
  }

  // 2. 로딩 시작
  isLoading.value = true;
  errorMessage.value = '';

  try {
    // 3. API 호출 (Repository)
    final boxes = await _repository.searchBoxes(keyword.value.trim());

    // 4. 성공: searchResults 업데이트
    searchResults.value = boxes;
  } on NetworkException catch (e) {
    // 5. 네트워크 에러: errorMessage 업데이트
    errorMessage.value = e.message;
    searchResults.clear();
    Get.snackbar(
      '오류',
      e.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SketchDesignTokens.error.withOpacity(0.1),
      colorText: SketchDesignTokens.error,
      duration: const Duration(seconds: 3),
    );
  } catch (e) {
    // 6. 기타 에러
    errorMessage.value = '일시적인 문제가 발생했습니다';
    searchResults.clear();
    Get.snackbar(
      '오류',
      errorMessage.value,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SketchDesignTokens.error.withOpacity(0.1),
      colorText: SketchDesignTokens.error,
      duration: const Duration(seconds: 3),
    );
  } finally {
    // 7. 로딩 종료
    isLoading.value = false;
  }
}

/// 검색어 지우기
void clearSearch() {
  searchController.clear();
  keyword.value = '';
  searchResults.clear();
  errorMessage.value = '';
}

/// 박스 가입 (단일 박스 정책)
Future<void> joinBox(int boxId) async {
  // 1. 현재 박스에 이미 소속되어 있으면 확인 모달 표시
  if (currentBox.value != null) {
    final confirm = await Get.dialog<bool>(
      SketchModal(
        title: '박스 변경',
        child: Text(
          '현재 "${currentBox.value?.name}"에서 탈퇴하고 새 박스에 가입합니다. 계속하시겠습니까?',
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            color: SketchDesignTokens.base900,
          ),
        ),
        primaryButton: SketchButton(
          text: '변경',
          onPressed: () => Get.back(result: true),
          style: SketchButtonStyle.primary,
        ),
        secondaryButton: SketchButton(
          text: '취소',
          onPressed: () => Get.back(result: false),
          style: SketchButtonStyle.outline,
        ),
      ),
      barrierDismissible: true,
    );

    if (confirm != true) return;
  }

  try {
    // 2. 박스 가입 (기존 박스 자동 탈퇴)
    final membership = await _repository.joinBox(boxId);

    // 3. 성공: currentBox 업데이트
    final joinedBox = searchResults.firstWhere((box) => box.id == boxId);
    currentBox.value = joinedBox;

    // 4. 성공 스낵바
    Get.snackbar(
      '가입 완료',
      '박스에 가입되었습니다',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SketchDesignTokens.success.withOpacity(0.1),
      colorText: SketchDesignTokens.success,
      duration: const Duration(seconds: 2),
    );
  } on NetworkException catch (e) {
    Get.snackbar(
      '오류',
      e.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SketchDesignTokens.error.withOpacity(0.1),
      colorText: SketchDesignTokens.error,
      duration: const Duration(seconds: 3),
    );
  } catch (e) {
    Get.snackbar(
      '오류',
      '박스 가입에 실패했습니다',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SketchDesignTokens.error.withOpacity(0.1),
      colorText: SketchDesignTokens.error,
      duration: const Duration(seconds: 3),
    );
  }
}

/// 초기화
@override
void onInit() {
  super.onInit();

  // Repository 의존성 주입
  _repository = Get.find<BoxRepository>();

  // TextEditingController 초기화
  searchController = TextEditingController();

  // Debounce 설정 (300ms)
  _debounceWorker = debounce(
    keyword,
    (_) => searchBoxes(),
    time: const Duration(milliseconds: 300),
  );

  // TextEditingController 리스너 (keyword 동기화)
  searchController.addListener(() {
    keyword.value = searchController.text;
  });

  // 현재 박스 정보 로드 (필요 시)
  // fetchCurrentBox();
}

/// 정리
@override
void onClose() {
  searchController.dispose();
  _debounceWorker?.dispose();
  super.onClose();
}
```

---

### Controller 2: BoxCreateController (현행 유지)

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_create_controller.dart`

#### 반응형 상태 (.obs)
```dart
/// 박스 생성 중 로딩 상태
final isLoading = false.obs;

/// 박스 이름 유효성 에러
final nameError = RxnString();

/// 박스 지역 유효성 에러
final regionError = RxnString();

/// 제출 가능 여부 (이름 + 지역 모두 유효)
final canSubmit = false.obs;
```

**설계 근거**:
- `isLoading`: 생성 버튼 로딩 상태 (SketchButton.isLoading)
- `nameError`, `regionError`: SketchInput.errorText 바인딩 (Obx로 감싸기)
- `canSubmit`: 버튼 활성화 조건 (Obx로 감싸기)

#### 비반응형 상태
```dart
/// Repository 의존성
late final BoxRepository _repository;

/// 입력 컨트롤러
late final TextEditingController nameController;
late final TextEditingController regionController;
late final TextEditingController descriptionController;
```

**설계 근거**:
- Repository는 의존성 주입
- TextEditingController는 반응형 아님 (리스너로 유효성 검증)

#### 메서드 인터페이스
```dart
/// 박스 생성
Future<void> createBox() async {
  // 1. 유효성 재검증
  _validateName();
  _validateRegion();

  if (!canSubmit.value) return;

  // 2. 로딩 시작
  isLoading.value = true;

  try {
    // 3. API 호출 (Repository)
    final box = await _repository.createBox(
      name: nameController.text.trim(),
      region: regionController.text.trim(),
      description: descriptionController.text.trim().isEmpty
        ? null
        : descriptionController.text.trim(),
    );

    // 4. 성공: 스낵바 + 홈 이동
    Get.snackbar(
      '박스 생성 완료',
      '박스가 생성되었습니다',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SketchDesignTokens.success.withOpacity(0.1),
      colorText: SketchDesignTokens.success,
      duration: const Duration(seconds: 2),
    );

    // 5. 홈으로 이동 (스택 초기화)
    Get.offAllNamed(Routes.HOME);
  } on NetworkException catch (e) {
    // 6. 네트워크 에러: 모달 표시
    Get.dialog(
      SketchModal(
        title: '오류',
        child: Text(
          e.message,
          style: TextStyle(
            fontSize: SketchDesignTokens.fontSizeBase,
            color: SketchDesignTokens.base900,
          ),
        ),
        primaryButton: SketchButton(
          text: '재시도',
          onPressed: () {
            Get.back();
            createBox();
          },
          style: SketchButtonStyle.primary,
        ),
        secondaryButton: SketchButton(
          text: '닫기',
          onPressed: () => Get.back(),
          style: SketchButtonStyle.outline,
        ),
      ),
      barrierDismissible: false,
    );
  } catch (e) {
    // 7. 기타 에러
    Get.dialog(
      SketchModal(
        title: '오류',
        child: const Text('박스 생성에 실패했습니다'),
        primaryButton: SketchButton(
          text: '확인',
          onPressed: () => Get.back(),
          style: SketchButtonStyle.primary,
        ),
      ),
    );
  } finally {
    // 8. 로딩 종료
    isLoading.value = false;
  }
}

/// 박스 이름 유효성 검증
void _validateName() {
  final name = nameController.text.trim();

  if (name.isEmpty) {
    nameError.value = null; // 빈 값은 에러 표시 안 함
  } else if (name.length < 2) {
    nameError.value = '박스 이름은 2자 이상이어야 합니다';
  } else if (name.length > 50) {
    nameError.value = '박스 이름은 50자 이하여야 합니다';
  } else {
    nameError.value = null;
  }

  _updateCanSubmit();
}

/// 박스 지역 유효성 검증
void _validateRegion() {
  final region = regionController.text.trim();

  if (region.isEmpty) {
    regionError.value = null;
  } else if (region.length < 2) {
    regionError.value = '지역은 2자 이상이어야 합니다';
  } else if (region.length > 100) {
    regionError.value = '지역은 100자 이하여야 합니다';
  } else {
    regionError.value = null;
  }

  _updateCanSubmit();
}

/// 제출 가능 여부 업데이트
void _updateCanSubmit() {
  final nameValid = nameController.text.trim().length >= 2 &&
                    nameError.value == null;
  final regionValid = regionController.text.trim().length >= 2 &&
                      regionError.value == null;

  canSubmit.value = nameValid && regionValid;
}

/// 초기화
@override
void onInit() {
  super.onInit();

  // Repository 의존성 주입
  _repository = Get.find<BoxRepository>();

  // TextEditingController 초기화
  nameController = TextEditingController();
  regionController = TextEditingController();
  descriptionController = TextEditingController();

  // 입력 리스너 (실시간 유효성 검증)
  nameController.addListener(_validateName);
  regionController.addListener(_validateRegion);
}

/// 정리
@override
void onClose() {
  nameController.dispose();
  regionController.dispose();
  descriptionController.dispose();
  super.onClose();
}
```

---

### Binding 1: BoxSearchBinding

**파일**: `apps/wowa/lib/app/modules/box/bindings/box_search_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/box_search_controller.dart';
import '../../../data/repositories/box_repository.dart';

class BoxSearchBinding extends Bindings {
  @override
  void dependencies() {
    // Repository 지연 로딩 (필요 시 생성)
    Get.lazyPut<BoxRepository>(
      () => BoxRepository(),
    );

    // Controller 지연 로딩
    Get.lazyPut<BoxSearchController>(
      () => BoxSearchController(),
    );
  }
}
```

---

### Binding 2: BoxCreateBinding

**파일**: `apps/wowa/lib/app/modules/box/bindings/box_create_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/box_create_controller.dart';
import '../../../data/repositories/box_repository.dart';

class BoxCreateBinding extends Bindings {
  @override
  void dependencies() {
    // Repository 지연 로딩 (이미 생성되어 있으면 재사용)
    Get.lazyPut<BoxRepository>(
      () => BoxRepository(),
    );

    // Controller 지연 로딩
    Get.lazyPut<BoxCreateController>(
      () => BoxCreateController(),
    );
  }
}
```

---

## View 설계 (Junior Developer가 구현)

### View 1: BoxSearchView (개선)

**파일**: `apps/wowa/lib/app/modules/box/views/box_search_view.dart`

#### Widget 구조
```dart
class BoxSearchView extends GetView<BoxSearchController> {
  const BoxSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchSection(),
            const SizedBox(height: 16),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
      floatingActionButton: _buildCreateButton(),
    );
  }

  /// AppBar
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      title: const Text('박스 찾기'),
      centerTitle: true,
    );
  }

  /// 검색 영역
  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SketchInput(
        controller: controller.searchController,
        hint: '박스 이름이나 지역을 검색하세요',
        prefixIcon: const Icon(Icons.search, color: SketchDesignTokens.base500),
        suffixIcon: Obx(() {
          if (controller.keyword.value.isEmpty) return null;

          return IconButton(
            icon: const Icon(Icons.clear, color: SketchDesignTokens.base500),
            onPressed: controller.clearSearch,
            tooltip: '검색어 지우기',
          );
        }),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  /// 검색 결과 영역 (5가지 상태)
  Widget _buildSearchResults() {
    return Obx(() {
      // 1. 로딩 상태
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 2. 검색어 없음 (초기 상태)
      if (controller.keyword.value.isEmpty) {
        return _buildEmptySearch();
      }

      // 3. 에러 상태
      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }

      // 4. 검색 결과 없음
      if (controller.searchResults.isEmpty) {
        return _buildNoResults();
      }

      // 5. 검색 결과 표시
      return _buildResultsList();
    });
  }

  /// Empty State: 검색어 없음
  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: SketchDesignTokens.base300,
          ),
          const SizedBox(height: 16),
          Text(
            '박스 이름이나 지역을 검색해보세요',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeBase,
              color: SketchDesignTokens.base500,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State: 검색 결과 없음
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: SketchDesignTokens.base300,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeLg,
              fontWeight: FontWeight.w500,
              color: SketchDesignTokens.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 검색어를 시도해보세요',
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeSm,
              color: SketchDesignTokens.base700,
            ),
          ),
        ],
      ),
    );
  }

  /// Error State: 에러 발생
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: SketchDesignTokens.error,
          ),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeBase,
              color: SketchDesignTokens.error,
            ),
          ),
          const SizedBox(height: 16),
          SketchButton(
            text: '재시도',
            onPressed: controller.searchBoxes,
            style: SketchButtonStyle.outline,
          ),
        ],
      ),
    );
  }

  /// 검색 결과 목록
  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final box = controller.searchResults[index];
        return _buildBoxCard(box);
      },
    );
  }

  /// 박스 카드
  Widget _buildBoxCard(BoxModel box) {
    return SketchCard(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 인기 배지
          Row(
            children: [
              Expanded(
                child: Text(
                  box.name,
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeLg,
                    fontWeight: FontWeight.bold,
                    color: SketchDesignTokens.black,
                  ),
                ),
              ),
              if (box.memberCount != null && box.memberCount! > 10)
                SketchChip(
                  label: '인기',
                  icon: const Icon(Icons.local_fire_department, size: 14),
                  selected: false,
                ),
            ],
          ),
          const SizedBox(height: 4),

          // 지역
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: SketchDesignTokens.base500),
              const SizedBox(width: 4),
              Text(
                box.region,
                style: TextStyle(
                  fontSize: SketchDesignTokens.fontSizeSm,
                  color: SketchDesignTokens.base700,
                ),
              ),
            ],
          ),

          // 설명 (선택)
          if (box.description != null && box.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              box.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeSm,
                color: SketchDesignTokens.base900,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 멤버 수
          if (box.memberCount != null)
            Row(
              children: [
                const Icon(Icons.group, size: 14, color: SketchDesignTokens.base500),
                const SizedBox(width: 4),
                Text(
                  '${box.memberCount}명',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeXs,
                    color: SketchDesignTokens.base500,
                  ),
                ),
              ],
            ),
        ],
      ),
      footer: Align(
        alignment: Alignment.centerRight,
        child: SketchButton(
          text: '가입',
          style: SketchButtonStyle.outline,
          size: SketchButtonSize.small,
          onPressed: () => controller.joinBox(box.id),
        ),
      ),
    );
  }

  /// 새 박스 만들기 버튼
  Widget _buildCreateButton() {
    return SketchButton(
      text: '새 박스 만들기',
      icon: const Icon(Icons.add, size: 20),
      style: SketchButtonStyle.primary,
      size: SketchButtonSize.medium,
      onPressed: () => Get.toNamed(Routes.BOX_CREATE),
    );
  }
}
```

#### const 최적화 전략
- 정적 위젯: `const SizedBox`, `const Icon`, `const Text` 사용
- Obx 범위 최소화: `suffixIcon` 부분만 Obx로 감싸기, 전체 _buildSearchResults()는 Obx 하나로 처리
- ListView.builder: 데이터 바인딩이므로 const 불가

---

### View 2: BoxCreateView (현행 유지)

**파일**: `apps/wowa/lib/app/modules/box/views/box_create_view.dart`

#### Widget 구조
```dart
class BoxCreateView extends GetView<BoxCreateController> {
  const BoxCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildNameInput(),
                      const SizedBox(height: 16),
                      _buildRegionInput(),
                      const SizedBox(height: 16),
                      _buildDescriptionInput(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
      title: const Text('새 박스 만들기'),
      centerTitle: true,
    );
  }

  /// 박스 이름 입력
  Widget _buildNameInput() {
    return Obx(() => SketchInput(
      controller: controller.nameController,
      label: '박스 이름',
      hint: '크로스핏 박스 이름',
      errorText: controller.nameError.value,
      maxLength: 50,
      textInputAction: TextInputAction.next,
    ));
  }

  /// 지역 입력
  Widget _buildRegionInput() {
    return Obx(() => SketchInput(
      controller: controller.regionController,
      label: '지역',
      hint: '서울 강남구',
      errorText: controller.regionError.value,
      maxLength: 100,
      textInputAction: TextInputAction.next,
    ));
  }

  /// 설명 입력
  Widget _buildDescriptionInput() {
    return SketchInput(
      controller: controller.descriptionController,
      label: '설명 (선택)',
      hint: '박스에 대한 간단한 설명',
      maxLines: 3,
      maxLength: 1000,
      textInputAction: TextInputAction.done,
    );
  }

  /// 생성 버튼
  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: SketchButton(
        text: '박스 생성',
        style: SketchButtonStyle.primary,
        size: SketchButtonSize.large,
        onPressed: controller.canSubmit.value && !controller.isLoading.value
            ? controller.createBox
            : null,
        isLoading: controller.isLoading.value,
      ),
    ));
  }
}
```

#### const 최적화 전략
- `const SizedBox`, `const EdgeInsets` 사용
- Obx는 반응형 필요한 위젯만 감싸기 (nameInput, regionInput, submitButton)
- descriptionInput은 에러 상태 없으므로 Obx 불필요

---

## API 통합 설계

### API 엔드포인트 변경

#### 기존 API (변경 전)
```
GET /boxes/search?name=...&region=...
```

#### 신규 API (변경 후)
```
GET /boxes?keyword=...
```

**변경 내용**:
- `name`, `region` 파라미터를 `keyword` 하나로 통합
- 서버에서 `keyword`로 박스 이름과 지역 모두 검색 (OR 조건)

---

### API 모델 (Senior Developer가 구현)

**패키지**: `packages/api/lib/src/models/box/`

#### BoxModel (기존 유지)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'box_model.freezed.dart';
part 'box_model.g.dart';

@freezed
class BoxModel with _$BoxModel {
  factory BoxModel({
    required int id,
    required String name,
    required String region,
    String? description,
    int? memberCount,
  }) = _BoxModel;

  factory BoxModel.fromJson(Map<String, dynamic> json) =>
      _$BoxModelFromJson(json);
}
```

#### BoxSearchResponse (신규 추가)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'box_model.dart';

part 'box_search_response.freezed.dart';
part 'box_search_response.g.dart';

@freezed
class BoxSearchResponse with _$BoxSearchResponse {
  factory BoxSearchResponse({
    required List<BoxModel> boxes,
  }) = _BoxSearchResponse;

  factory BoxSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$BoxSearchResponseFromJson(json);
}
```

#### BoxCreateRequest (기존 유지)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'box_create_request.freezed.dart';
part 'box_create_request.g.dart';

@freezed
class BoxCreateRequest with _$BoxCreateRequest {
  factory BoxCreateRequest({
    required String name,
    required String region,
    String? description,
  }) = _BoxCreateRequest;

  factory BoxCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$BoxCreateRequestFromJson(json);
}
```

#### BoxCreateResponse (신규 추가)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'box_model.dart';
import 'membership_model.dart';

part 'box_create_response.freezed.dart';
part 'box_create_response.g.dart';

@freezed
class BoxCreateResponse with _$BoxCreateResponse {
  factory BoxCreateResponse({
    required BoxModel box,
    required MembershipModel membership,
  }) = _BoxCreateResponse;

  factory BoxCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$BoxCreateResponseFromJson(json);
}
```

#### MembershipModel (신규 추가)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_model.freezed.dart';
part 'membership_model.g.dart';

@freezed
class MembershipModel with _$MembershipModel {
  factory MembershipModel({
    required int id,
    required int boxId,
    required int userId,
    required DateTime joinedAt,
  }) = _MembershipModel;

  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipModelFromJson(json);
}
```

---

### API 클라이언트 (Senior Developer가 구현)

**패키지**: `packages/api/lib/src/clients/box_api_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/box/box_model.dart';
import '../models/box/box_search_response.dart';
import '../models/box/box_create_request.dart';
import '../models/box/box_create_response.dart';
import '../models/box/membership_model.dart';

class BoxApiService {
  final Dio _dio = Get.find<Dio>();

  /// 박스 검색 (통합 키워드)
  /// GET /boxes?keyword=...
  Future<List<BoxModel>> searchBoxes(String keyword) async {
    final response = await _dio.get(
      '/boxes',
      queryParameters: {'keyword': keyword},
    );

    final searchResponse = BoxSearchResponse.fromJson(response.data);
    return searchResponse.boxes;
  }

  /// 박스 생성
  /// POST /boxes
  Future<BoxCreateResponse> createBox(BoxCreateRequest request) async {
    final response = await _dio.post(
      '/boxes',
      data: request.toJson(),
    );

    return BoxCreateResponse.fromJson(response.data);
  }

  /// 박스 가입
  /// POST /boxes/:boxId/join
  Future<MembershipModel> joinBox(int boxId) async {
    final response = await _dio.post('/boxes/$boxId/join');

    return MembershipModel.fromJson(response.data);
  }

  /// 현재 소속 박스 조회
  /// GET /boxes/current
  Future<BoxModel?> getCurrentBox() async {
    try {
      final response = await _dio.get('/boxes/current');
      return BoxModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // 소속 박스 없음
      }
      rethrow;
    }
  }
}
```

---

### Repository 패턴 (Controller에서 사용)

**파일**: `apps/wowa/lib/app/data/repositories/box_repository.dart`

```dart
import 'package:core/core.dart';
import 'package:api/api.dart';
import 'package:get/get.dart';

class BoxRepository {
  final BoxApiService _apiService = Get.find<BoxApiService>();

  /// 박스 검색
  Future<List<BoxModel>> searchBoxes(String keyword) async {
    try {
      return await _apiService.searchBoxes(keyword);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('네트워크 연결을 확인해주세요');
      }

      if (e.response?.statusCode == 500) {
        throw NetworkException('일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요');
      }

      throw NetworkException('검색에 실패했습니다');
    }
  }

  /// 박스 생성
  Future<BoxCreateResponse> createBox({
    required String name,
    required String region,
    String? description,
  }) async {
    try {
      final request = BoxCreateRequest(
        name: name,
        region: region,
        description: description,
      );

      return await _apiService.createBox(request);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('네트워크 연결을 확인해주세요');
      }

      if (e.response?.statusCode == 400) {
        throw NetworkException('입력 정보를 확인해주세요');
      }

      if (e.response?.statusCode == 500) {
        throw NetworkException('일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요');
      }

      throw NetworkException('박스 생성에 실패했습니다');
    }
  }

  /// 박스 가입
  Future<MembershipModel> joinBox(int boxId) async {
    try {
      return await _apiService.joinBox(boxId);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('네트워크 연결을 확인해주세요');
      }

      if (e.response?.statusCode == 404) {
        throw NetworkException('박스를 찾을 수 없습니다');
      }

      if (e.response?.statusCode == 409) {
        throw NetworkException('이미 가입된 박스입니다');
      }

      throw NetworkException('박스 가입에 실패했습니다');
    }
  }

  /// 현재 소속 박스 조회
  Future<BoxModel?> getCurrentBox() async {
    try {
      return await _apiService.getCurrentBox();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('네트워크 연결을 확인해주세요');
      }

      // 404는 정상 (소속 박스 없음)
      if (e.response?.statusCode == 404) {
        return null;
      }

      throw NetworkException('박스 정보 조회에 실패했습니다');
    }
  }
}
```

---

### build_runner 실행 (Senior가 실행)
```bash
cd /Users/lms/dev/repository/feature-wowa-box
melos generate
```

**실행 후 생성되는 파일**:
- `box_model.freezed.dart`, `box_model.g.dart`
- `box_search_response.freezed.dart`, `box_search_response.g.dart`
- `box_create_request.freezed.dart`, `box_create_request.g.dart`
- `box_create_response.freezed.dart`, `box_create_response.g.dart`
- `membership_model.freezed.dart`, `membership_model.g.dart`

---

## Design System 컴포넌트 (필요 시)

### 재사용 컴포넌트 필요 여부
**없음** — 기존 Design System 컴포넌트로 모든 UI 구현 가능

**사용 컴포넌트**:
- `SketchInput`: 검색 입력, 박스 생성 입력 필드
- `SketchButton`: 가입 버튼, 생성 버튼, FAB
- `SketchCard`: 박스 카드
- `SketchChip`: 인기 박스 배지 (memberCount > 10)
- `SketchModal`: 박스 변경 확인 모달, 에러 모달

---

## 라우팅 설계

### Route Name (app_routes.dart)

**파일**: `apps/wowa/lib/app/routes/app_routes.dart`

```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const SETTINGS = '/settings';
  static const QNA = '/qna';

  // 박스 관련 라우트 (신규 추가)
  static const BOX_SEARCH = '/box/search';
  static const BOX_CREATE = '/box/create';
}
```

---

### Route Definition (app_pages.dart)

**파일**: `apps/wowa/lib/app/routes/app_pages.dart`

```dart
import 'package:get/get.dart';
import '../modules/box/bindings/box_search_binding.dart';
import '../modules/box/bindings/box_create_binding.dart';
import '../modules/box/views/box_search_view.dart';
import '../modules/box/views/box_create_view.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // 기존 라우트...

    // 박스 검색
    GetPage(
      name: Routes.BOX_SEARCH,
      page: () => const BoxSearchView(),
      binding: BoxSearchBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // 박스 생성
    GetPage(
      name: Routes.BOX_CREATE,
      page: () => const BoxCreateView(),
      binding: BoxCreateBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

---

### Navigation
```dart
// 박스 검색 화면 이동
Get.toNamed(Routes.BOX_SEARCH);

// 박스 생성 화면 이동
Get.toNamed(Routes.BOX_CREATE);

// 박스 생성 후 홈으로 이동 (스택 초기화)
Get.offAllNamed(Routes.HOME);

// 뒤로가기
Get.back();
```

---

## 성능 최적화 전략

### const 생성자
- 정적 위젯은 `const` 사용
- `const EdgeInsets.all(16)`, `const SizedBox(height: 16)`, `const Text()`
- `const Icon()`, `const AppBar()`

### Obx 범위 최소화
- 변경되는 부분만 Obx로 감싸기
- 전체 화면이 아닌 특정 위젯만 반응형 (예: `suffixIcon` 부분만 Obx)
- `_buildSearchResults()` 전체는 하나의 Obx로 처리 (5가지 상태 분기)

### Debounce 적용
- 검색어 입력 시 300ms debounce
- `debounce(keyword, (_) => searchBoxes(), time: Duration(milliseconds: 300))`
- 타이핑 중단 감지 후 API 호출 (불필요한 요청 방지)

### GetView 사용
- `GetView<Controller>` 상속으로 controller 한 번만 생성
- `Get.find<Controller>()` 자동 호출

### 불필요한 rebuild 방지
- `controller.variable.value`로 리빌드 트리거
- const 생성자로 rebuild 스킵

---

## 에러 처리 전략

### Controller 에러 처리
```dart
try {
  isLoading.value = true;
  errorMessage.value = '';

  final boxes = await _repository.searchBoxes(keyword.value);
  searchResults.value = boxes;
} on NetworkException catch (e) {
  errorMessage.value = e.message;
  searchResults.clear();

  Get.snackbar(
    '오류',
    e.message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: SketchDesignTokens.error.withOpacity(0.1),
    colorText: SketchDesignTokens.error,
    duration: const Duration(seconds: 3),
  );
} catch (e) {
  errorMessage.value = '일시적인 문제가 발생했습니다';
  searchResults.clear();

  Get.snackbar(
    '오류',
    errorMessage.value,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: SketchDesignTokens.error.withOpacity(0.1),
    colorText: SketchDesignTokens.error,
    duration: const Duration(seconds: 3),
  );
} finally {
  isLoading.value = false;
}
```

### View 에러 표시
- `errorMessage.value` 확인 후 Error State 표시
- 재시도 버튼 제공
- 아이콘 + 텍스트 조합으로 명확한 피드백

### 모달 에러 처리 (박스 생성)
```dart
Get.dialog(
  SketchModal(
    title: '오류',
    child: Text(e.message),
    primaryButton: SketchButton(
      text: '재시도',
      onPressed: () {
        Get.back();
        createBox();
      },
      style: SketchButtonStyle.primary,
    ),
    secondaryButton: SketchButton(
      text: '닫기',
      onPressed: () => Get.back(),
      style: SketchButtonStyle.outline,
    ),
  ),
  barrierDismissible: false,
);
```

---

## 패키지 의존성 확인

### 모노레포 구조
```
core (foundation)
  ↑
  ├── api (HTTP, models, Freezed)
  ├── design_system (UI)
  └── wowa (app)
```

### 필요한 패키지
- **core**: GetX, NetworkException (이미 포함)
- **api**: Dio, Freezed, json_serializable (이미 포함)
- **design_system**: SketchInput, SketchButton, SketchCard, SketchChip, SketchModal (이미 포함)
- **wowa**: core, api, design_system (이미 포함)

**추가 패키지 불필요** — 기존 의존성으로 모든 기능 구현 가능

---

## 작업 분배 계획 (CTO가 참조)

### Senior Developer 작업
1. **API 모델 작성** (`packages/api/lib/src/models/box/`)
   - `box_model.dart` (기존 유지)
   - `box_search_response.dart` (신규)
   - `box_create_request.dart` (기존 유지)
   - `box_create_response.dart` (신규)
   - `membership_model.dart` (신규)
   - Freezed + json_serializable 어노테이션 적용

2. **Dio 클라이언트 구현** (`packages/api/lib/src/clients/box_api_service.dart`)
   - `searchBoxes(keyword)` — GET /boxes?keyword=...
   - `createBox(request)` — POST /boxes
   - `joinBox(boxId)` — POST /boxes/:boxId/join
   - `getCurrentBox()` — GET /boxes/current

3. **melos generate 실행**
   ```bash
   cd /Users/lms/dev/repository/feature-wowa-box
   melos generate
   ```

4. **Controller 구현** (`apps/wowa/lib/app/modules/box/controllers/`)
   - `box_search_controller.dart` (개선)
     - `keyword.obs` 추가
     - `nameQuery`, `regionQuery` 삭제
     - `debounce(keyword, searchBoxes, 300ms)` 설정
     - `searchBoxes()` 메서드 수정 (통합 검색)
     - `joinBox(boxId)` 메서드 추가 (단일 박스 정책)
   - `box_create_controller.dart` (현행 유지)

5. **Repository 구현** (`apps/wowa/lib/app/data/repositories/box_repository.dart`)
   - `searchBoxes(keyword)` — NetworkException 처리
   - `createBox(name, region, description)` — NetworkException 처리
   - `joinBox(boxId)` — NetworkException 처리
   - `getCurrentBox()` — 404 정상 처리

6. **Binding 작성** (`apps/wowa/lib/app/modules/box/bindings/`)
   - `box_search_binding.dart`
   - `box_create_binding.dart`

### Junior Developer 작업
1. **View 구현** (`apps/wowa/lib/app/modules/box/views/`)
   - `box_search_view.dart` (개선)
     - SketchInput (검색) — prefixIcon, suffixIcon (조건부)
     - 5가지 상태 구현 (초기/로딩/에러/결과 없음/결과 표시)
     - SketchCard (박스 카드) — SketchChip (인기 배지)
     - FloatingActionButton (새 박스 만들기)
   - `box_create_view.dart` (현행 유지)
     - SketchInput (이름, 지역, 설명)
     - SketchButton (생성) — isLoading, onPressed 조건부

2. **Routing 업데이트** (`apps/wowa/lib/app/routes/`)
   - `app_routes.dart` — `BOX_SEARCH`, `BOX_CREATE` 추가
   - `app_pages.dart` — `GetPage` 2개 추가 (transition: cupertino)

### 작업 의존성
- Junior는 Senior의 **Controller + Repository + Binding** 완성 후 시작
- Controller 메서드, .obs 변수 정확히 일치시켜야 함
- Senior가 `melos generate` 실행 후 모델 파일 확인 필요

---

## 검증 기준

- [ ] GetX 패턴 준수 (Controller, View, Binding 분리)
- [ ] 반응형 상태 정확히 정의 (.obs)
- [ ] Debounce 300ms 적용 (검색)
- [ ] 5가지 UI 상태 명확히 구분 (초기/로딩/에러/결과 없음/결과 표시)
- [ ] const 최적화 적용
- [ ] Obx 범위 최소화
- [ ] 에러 처리 완비 (NetworkException)
- [ ] 라우팅 설정 정확 (cupertino transition)
- [ ] 단일 박스 정책 적용 (joinBox, createBox)
- [ ] CLAUDE.md 표준 준수

---

## 참고 자료
- GetX 문서: https://pub.dev/packages/get
- Freezed 문서: https://pub.dev/packages/freezed
- Design Spec: `docs/wowa/wowa-box/mobile-design-spec.md`
- User Story: `docs/wowa/wowa-box/user-story.md`
- `.claude/guide/mobile/` 참조
