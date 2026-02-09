# Mobile 작업 계획: 박스 관리 기능 개선 (wowa-box)

## 개요

박스 검색 UX를 통합 키워드 방식으로 개선하고, 300ms debounce를 적용하여 실시간 검색 경험을 제공합니다. Server API 완성 후 API 통합을 진행하며, UI 레이아웃은 Server와 병렬로 선행 작업합니다.

## 실행 그룹

### Group 1 (병렬) — UI 레이아웃 선행 작업 (Server와 동시)

| Agent | Module | 설명 | 파일 경로 |
|-------|--------|------|----------|
| flutter-developer | box-ui | View 레이아웃, Binding, Routing | `apps/wowa/lib/app/modules/box/views/`, `bindings/`, `routes/` |

**병렬 진행**: Server API 구현 (Group 1)과 동시 실행 가능
**의존성**: Controller 인터페이스만 정의 (실제 구현은 Group 2에서)

### Group 2 (병렬) — API 통합 (Server 완료 후)

| Agent | Module | 설명 | 파일 경로 |
|-------|--------|------|----------|
| flutter-developer | box-api | API 모델, 클라이언트, Repository, Controller | `packages/api/`, `apps/wowa/lib/app/data/`, `modules/box/controllers/` |

**의존성**: Server API 완성 후 시작 (Group 1 완료 필요)

---

## Group 1: UI 레이아웃 선행 작업

### Task 1: View 구현 (Controller 인터페이스 기반)

**담당**: flutter-developer
**우선순위**: 높음 (Server와 병렬)

#### 작업 파일
1. **`apps/wowa/lib/app/modules/box/views/box_search_view.dart`** (개선)
   - SketchInput (통합 검색): prefixIcon, suffixIcon (조건부)
   - 5가지 UI 상태 구현:
     - 초기 상태 (검색어 없음) → Empty State
     - 로딩 상태 → CircularProgressIndicator
     - 에러 상태 → Error State + 재시도 버튼
     - 결과 없음 → Empty State
     - 결과 표시 → ListView.builder (SketchCard)
   - FloatingActionButton (새 박스 만들기)

2. **`apps/wowa/lib/app/modules/box/views/box_create_view.dart`** (현행 유지)
   - SketchInput (이름, 지역, 설명)
   - SketchButton (생성) — isLoading, onPressed 조건부

#### Controller 인터페이스 정의 (임시 목 사용)

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_search_controller.dart` (스텁)

```dart
import 'package:get/get.dart';

/// 박스 검색 컨트롤러 (임시 인터페이스, Group 2에서 구현)
class BoxSearchController extends GetxController {
  // 반응형 상태 (Group 2에서 구현)
  final keyword = ''.obs;
  final isLoading = false.obs;
  final searchResults = <dynamic>[].obs; // BoxModel 대신 dynamic 임시 사용
  final errorMessage = ''.obs;

  // 비반응형 상태
  late final TextEditingController searchController;

  // 메서드 (Group 2에서 구현)
  Future<void> searchBoxes() async {
    // 임시: 빈 구현
  }

  void clearSearch() {
    searchController.clear();
    keyword.value = '';
    searchResults.clear();
    errorMessage.value = '';
  }

  Future<void> joinBox(int boxId) async {
    // 임시: 빈 구현
  }

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    searchController.addListener(() {
      keyword.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
```

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_create_controller.dart` (스텁)

```dart
import 'package:get/get.dart';

/// 박스 생성 컨트롤러 (임시 인터페이스, Group 2에서 구현)
class BoxCreateController extends GetxController {
  // 반응형 상태
  final isLoading = false.obs;
  final nameError = RxnString();
  final regionError = RxnString();
  final canSubmit = false.obs;

  // 비반응형 상태
  late final TextEditingController nameController;
  late final TextEditingController regionController;
  late final TextEditingController descriptionController;

  // 메서드 (Group 2에서 구현)
  Future<void> createBox() async {
    // 임시: 빈 구현
  }

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    regionController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    regionController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
```

---

### Task 2: Binding 작성

**담당**: flutter-developer

#### 작업 파일
1. **`apps/wowa/lib/app/modules/box/bindings/box_search_binding.dart`**
   ```dart
   import 'package:get/get.dart';
   import '../controllers/box_search_controller.dart';

   class BoxSearchBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<BoxSearchController>(() => BoxSearchController());
     }
   }
   ```

2. **`apps/wowa/lib/app/modules/box/bindings/box_create_binding.dart`**
   ```dart
   import 'package:get/get.dart';
   import '../controllers/box_create_controller.dart';

   class BoxCreateBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<BoxCreateController>(() => BoxCreateController());
     }
   }
   ```

---

### Task 3: Routing 업데이트

**담당**: flutter-developer

#### 작업 파일
1. **`apps/wowa/lib/app/routes/app_routes.dart`**
   ```dart
   abstract class Routes {
     // 기존 라우트...

     // 박스 관련 라우트 (신규 추가)
     static const BOX_SEARCH = '/box/search';
     static const BOX_CREATE = '/box/create';
   }
   ```

2. **`apps/wowa/lib/app/routes/app_pages.dart`**
   ```dart
   import 'package:get/get.dart';
   import '../modules/box/bindings/box_search_binding.dart';
   import '../modules/box/bindings/box_create_binding.dart';
   import '../modules/box/views/box_search_view.dart';
   import '../modules/box/views/box_create_view.dart';

   class AppPages {
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

### Group 1 검증 기준

- [ ] View 레이아웃 구현 (5가지 UI 상태)
- [ ] Controller 인터페이스 정의 (스텁)
- [ ] Binding 작성 완료
- [ ] Routing 설정 완료
- [ ] const 최적화 적용
- [ ] Obx 범위 최소화
- [ ] `flutter analyze` 통과

---

## Group 2: API 통합 작업 (Server 완료 후)

### Task 1: API 모델 작성

**담당**: flutter-developer
**우선순위**: 높음
**의존성**: Server API 명세 확인 필요

#### 작업 파일

1. **`packages/api/lib/src/models/box/box_model.dart`** (기존 유지)
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

2. **`packages/api/lib/src/models/box/box_search_response.dart`** (신규)
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

3. **`packages/api/lib/src/models/box/box_create_request.dart`** (기존 유지)
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

4. **`packages/api/lib/src/models/box/box_create_response.dart`** (신규)
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
       int? previousBoxId,
     }) = _BoxCreateResponse;

     factory BoxCreateResponse.fromJson(Map<String, dynamic> json) =>
         _$BoxCreateResponseFromJson(json);
   }
   ```

5. **`packages/api/lib/src/models/box/membership_model.dart`** (신규)
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

#### build_runner 실행
```bash
cd /Users/lms/dev/repository/feature-wowa-box
melos generate
```

---

### Task 2: API 클라이언트 구현

**담당**: flutter-developer

#### 작업 파일

**`packages/api/lib/src/clients/box_api_service.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/box/box_model.dart';
import '../models/box/box_search_response.dart';
import '../models/box/box_create_request.dart';
import '../models/box/box_create_response.dart';
import '../models/box/membership_model.dart';

/// 박스 API 서비스
class BoxApiService {
  final Dio _dio = Get.find<Dio>();

  /// 박스 검색 (통합 키워드)
  /// GET /boxes/search?keyword=...
  Future<List<BoxModel>> searchBoxes(String keyword) async {
    final response = await _dio.get(
      '/boxes/search',
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

### Task 3: Repository 구현

**담당**: flutter-developer

#### 작업 파일

**`apps/wowa/lib/app/data/repositories/box_repository.dart`**

```dart
import 'package:core/core.dart';
import 'package:api/api.dart';
import 'package:get/get.dart';

/// 박스 Repository
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

### Task 4: Controller 구현 (Group 1 스텁 대체)

**담당**: flutter-developer

#### 작업 파일

1. **`apps/wowa/lib/app/modules/box/controllers/box_search_controller.dart`** (완성)

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/repositories/box_repository.dart';

/// 박스 검색 컨트롤러
class BoxSearchController extends GetxController {
  // Repository 의존성
  late final BoxRepository _repository;

  // 반응형 상태
  final keyword = ''.obs;
  final isLoading = false.obs;
  final searchResults = <BoxModel>[].obs;
  final currentBox = Rxn<BoxModel>();
  final errorMessage = ''.obs;

  // 비반응형 상태
  late final TextEditingController searchController;
  Worker? _debounceWorker;

  /// 박스 검색 (API 호출)
  Future<void> searchBoxes() async {
    if (keyword.value.trim().isEmpty) {
      searchResults.clear();
      errorMessage.value = '';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final boxes = await _repository.searchBoxes(keyword.value.trim());
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
    // 현재 박스 확인 모달
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
      await _repository.joinBox(boxId);

      final joinedBox = searchResults.firstWhere((box) => box.id == boxId);
      currentBox.value = joinedBox;

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

  @override
  void onInit() {
    super.onInit();

    _repository = Get.find<BoxRepository>();
    searchController = TextEditingController();

    // Debounce 설정 (300ms)
    _debounceWorker = debounce(
      keyword,
      (_) => searchBoxes(),
      time: const Duration(milliseconds: 300),
    );

    searchController.addListener(() {
      keyword.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounceWorker?.dispose();
    super.onClose();
  }
}
```

2. **`apps/wowa/lib/app/modules/box/controllers/box_create_controller.dart`** (완성)

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/repositories/box_repository.dart';
import '../../routes/app_routes.dart';

/// 박스 생성 컨트롤러
class BoxCreateController extends GetxController {
  // Repository 의존성
  late final BoxRepository _repository;

  // 반응형 상태
  final isLoading = false.obs;
  final nameError = RxnString();
  final regionError = RxnString();
  final canSubmit = false.obs;

  // 비반응형 상태
  late final TextEditingController nameController;
  late final TextEditingController regionController;
  late final TextEditingController descriptionController;

  /// 박스 생성
  Future<void> createBox() async {
    _validateName();
    _validateRegion();

    if (!canSubmit.value) return;

    isLoading.value = true;

    try {
      await _repository.createBox(
        name: nameController.text.trim(),
        region: regionController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );

      Get.snackbar(
        '박스 생성 완료',
        '박스가 생성되었습니다',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SketchDesignTokens.success.withOpacity(0.1),
        colorText: SketchDesignTokens.success,
        duration: const Duration(seconds: 2),
      );

      Get.offAllNamed(Routes.HOME);
    } on NetworkException catch (e) {
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
      isLoading.value = false;
    }
  }

  /// 박스 이름 유효성 검증
  void _validateName() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      nameError.value = null;
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

  @override
  void onInit() {
    super.onInit();

    _repository = Get.find<BoxRepository>();

    nameController = TextEditingController();
    regionController = TextEditingController();
    descriptionController = TextEditingController();

    nameController.addListener(_validateName);
    regionController.addListener(_validateRegion);
  }

  @override
  void onClose() {
    nameController.dispose();
    regionController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
```

---

### Task 5: Binding 업데이트 (Repository 의존성 추가)

**담당**: flutter-developer

#### 작업 파일

1. **`apps/wowa/lib/app/modules/box/bindings/box_search_binding.dart`** (업데이트)
   ```dart
   import 'package:get/get.dart';
   import '../controllers/box_search_controller.dart';
   import '../../../data/repositories/box_repository.dart';

   class BoxSearchBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<BoxRepository>(() => BoxRepository());
       Get.lazyPut<BoxSearchController>(() => BoxSearchController());
     }
   }
   ```

2. **`apps/wowa/lib/app/modules/box/bindings/box_create_binding.dart`** (업데이트)
   ```dart
   import 'package:get/get.dart';
   import '../controllers/box_create_controller.dart';
   import '../../../data/repositories/box_repository.dart';

   class BoxCreateBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<BoxRepository>(() => BoxRepository());
       Get.lazyPut<BoxCreateController>(() => BoxCreateController());
     }
   }
   ```

---

## 파일 구조

### Group 1 (UI 레이아웃)
```
apps/wowa/lib/app/
├── modules/box/
│   ├── controllers/
│   │   ├── box_search_controller.dart    # 스텁 (Group 1)
│   │   └── box_create_controller.dart    # 스텁 (Group 1)
│   ├── views/
│   │   ├── box_search_view.dart          # 완성 (Group 1)
│   │   └── box_create_view.dart          # 완성 (Group 1)
│   └── bindings/
│       ├── box_search_binding.dart       # 완성 (Group 1)
│       └── box_create_binding.dart       # 완성 (Group 1)
└── routes/
    ├── app_routes.dart                   # 수정 (Group 1)
    └── app_pages.dart                    # 수정 (Group 1)
```

### Group 2 (API 통합)
```
packages/api/lib/src/
├── models/box/
│   ├── box_model.dart                    # 기존 유지
│   ├── box_search_response.dart          # 신규 (Group 2)
│   ├── box_create_request.dart           # 기존 유지
│   ├── box_create_response.dart          # 신규 (Group 2)
│   └── membership_model.dart             # 신규 (Group 2)
└── clients/
    └── box_api_service.dart              # 수정 (Group 2)

apps/wowa/lib/app/
├── data/repositories/
│   └── box_repository.dart               # 완성 (Group 2)
├── modules/box/controllers/
│   ├── box_search_controller.dart        # 완성 (Group 2, 스텁 대체)
│   └── box_create_controller.dart        # 완성 (Group 2, 스텁 대체)
└── modules/box/bindings/
    ├── box_search_binding.dart           # 업데이트 (Group 2, Repository 의존성)
    └── box_create_binding.dart           # 업데이트 (Group 2, Repository 의존성)
```

---

## 검증 기준

### Group 1 (UI 레이아웃)
- [ ] View 5가지 UI 상태 구현 (초기/로딩/에러/결과 없음/결과 표시)
- [ ] Controller 인터페이스 정의 (스텁)
- [ ] Binding 작성 완료
- [ ] Routing 설정 완료
- [ ] const 최적화 적용
- [ ] Obx 범위 최소화
- [ ] `flutter analyze` 통과

### Group 2 (API 통합)
- [ ] API 모델 Freezed + json_serializable 적용
- [ ] `melos generate` 성공
- [ ] API 클라이언트 Dio 통합
- [ ] Repository NetworkException 처리
- [ ] Controller 완성 (debounce 300ms, 에러 처리)
- [ ] Binding Repository 의존성 추가
- [ ] GetX 패턴 준수 (Controller/View/Binding 분리)
- [ ] CLAUDE.md 표준 준수

---

## 실행 명령어

### melos generate (Group 2)
```bash
cd /Users/lms/dev/repository/feature-wowa-box
melos generate
```

### flutter analyze
```bash
cd /Users/lms/dev/repository/feature-wowa-box
flutter analyze apps/wowa
```

---

## 참고 자료

- **Mobile Brief**: `/Users/lms/dev/repository/feature-wowa-box/docs/wowa/wowa-box/mobile-brief.md`
- **Mobile Design Spec**: `/Users/lms/dev/repository/feature-wowa-box/docs/wowa/wowa-box/mobile-design-spec.md`
- **Mobile CLAUDE.md**: `/Users/lms/dev/repository/feature-wowa-box/apps/mobile/CLAUDE.md`
- **GetX Best Practices**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/mobile/getx_best_practices.md`
- **Design System**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/mobile/design_system.md`
- **Error Handling**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/mobile/error_handling.md`
