# 기술 아키텍처 설계: WOWA MVP (Mobile)

> Feature: wowa-mvp
> Created: 2026-02-04
> Phase: Technical Architecture Design
> Platform: Flutter (GetX)

---

## 개요

WOWA MVP의 모바일 기술 아키텍처를 정의합니다. mobile-design-spec.md의 UI/UX 설계를 기반으로 GetX 상태 관리, API 통합, 라우팅 설계를 제공합니다.

**핵심 기술 전략**:
- GetX 상태 관리로 반응형 UI 구현
- Freezed 모델로 타입 안전성 확보
- Repository 패턴으로 비즈니스 로직 분리
- const 최적화 및 Obx 범위 최소화로 성능 최적화

**기술 스택**:
- Framework: Flutter 3.x
- State Management: GetX
- HTTP Client: Dio
- Code Generation: Freezed + json_serializable
- Design System: Frame0 스케치 스타일 (packages/design_system)

---

## 모듈 구조 (apps/wowa/lib/app/modules/)

### 박스 관리 (Box)

```
modules/box/
├── controllers/
│   ├── box_search_controller.dart      # 박스 검색 및 가입
│   └── box_create_controller.dart      # 박스 생성
├── views/
│   ├── box_search_view.dart            # 박스 검색 화면
│   └── box_create_view.dart            # 박스 생성 화면
└── bindings/
    ├── box_search_binding.dart
    └── box_create_binding.dart
```

### WOD 관리 (WOD)

```
modules/wod/
├── controllers/
│   ├── home_controller.dart            # 홈 (오늘의 WOD)
│   ├── wod_register_controller.dart    # WOD 등록
│   ├── wod_detail_controller.dart      # WOD 상세
│   ├── wod_select_controller.dart      # WOD 선택
│   └── proposal_review_controller.dart # 변경 승인 (Base 등록자만)
├── views/
│   ├── home_view.dart
│   ├── wod_register_view.dart
│   ├── wod_detail_view.dart
│   ├── wod_select_view.dart
│   └── proposal_review_view.dart
└── bindings/
    ├── home_binding.dart
    ├── wod_register_binding.dart
    ├── wod_detail_binding.dart
    ├── wod_select_binding.dart
    └── proposal_review_binding.dart
```

### 설정 (Settings)

```
modules/settings/
├── controllers/
│   └── settings_controller.dart
├── views/
│   └── settings_view.dart
└── bindings/
    └── settings_binding.dart
```

---

## GetX 상태 관리 설계

### 1. BoxSearchController

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_search_controller.dart`

#### 반응형 상태 (.obs)

```dart
/// 검색 중 로딩 상태
final isLoading = false.obs;

/// 검색 결과 박스 목록
final searchResults = <BoxModel>[].obs;

/// 현재 가입된 박스 (설정에서 박스 변경 시만 표시)
final currentBox = Rxn<BoxModel>();

/// 박스 이름 검색어
final nameQuery = ''.obs;

/// 박스 지역 검색어
final regionQuery = ''.obs;
```

**설계 근거**:
- `isLoading`: 검색 API 호출 중 CircularProgressIndicator 표시
- `searchResults`: ListView에 반응형 렌더링
- `currentBox`: 설정에서 진입 시 박스 변경 확인 모달 표시 (기존 박스 자동 탈퇴)
- `nameQuery`, `regionQuery`: TextField 입력값, debounce 300ms

#### 비반응형 상태

```dart
/// 박스 검색 이름 입력 컨트롤러
late final TextEditingController nameController;

/// 박스 검색 지역 입력 컨트롤러
late final TextEditingController regionController;

/// Repository (의존성 주입)
late final BoxRepository _repository;
```

**설계 근거**:
- TextEditingController는 UI 변경 불필요 (TextField가 자체 관리)
- Repository는 비즈니스 로직 분리

#### 메서드 인터페이스

```dart
/// 초기화 (진입 경로에 따라 currentBox 설정)
@override
void onInit() {
  super.onInit();
  nameController = TextEditingController();
  regionController = TextEditingController();
  _repository = Get.find<BoxRepository>();

  // 설정에서 진입 시 현재 박스 조회
  _loadCurrentBox();
}

/// 현재 박스 조회 (설정에서 진입 시)
Future<void> _loadCurrentBox() async {
  try {
    final box = await _repository.getCurrentBox();
    currentBox.value = box;
  } catch (e) {
    // 가입된 박스 없음 (정상 플로우)
    currentBox.value = null;
  }
}

/// 박스 검색 (debounce 300ms)
Future<void> search() async {
  final name = nameController.text.trim();
  final region = regionController.text.trim();

  nameQuery.value = name;
  regionQuery.value = region;

  // 둘 다 비어있으면 검색하지 않음
  if (name.isEmpty && region.isEmpty) {
    searchResults.clear();
    return;
  }

  isLoading.value = true;
  try {
    final results = await _repository.searchBoxes(
      name: name.isEmpty ? null : name,
      region: region.isEmpty ? null : region,
    );
    searchResults.value = results;
  } on NetworkException catch (e) {
    Get.snackbar(
      '네트워크 오류',
      '인터넷 연결을 확인해주세요',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      '오류',
      '박스 검색에 실패했습니다',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
}

/// 박스 가입 (기존 박스 자동 탈퇴)
Future<void> joinBox(BoxModel box) async {
  // 기존 박스가 있으면 확인 모달
  if (currentBox.value != null) {
    final confirmed = await _showBoxChangeConfirmModal(box);
    if (confirmed != true) return;
  }

  isLoading.value = true;
  try {
    await _repository.joinBox(box.id);

    Get.snackbar(
      '가입 완료',
      '${box.name}에 가입되었습니다',
      snackPosition: SnackPosition.BOTTOM,
    );

    // 홈으로 이동 (기존 스택 전부 제거)
    Get.offAllNamed(Routes.HOME);
  } on NetworkException catch (e) {
    Get.snackbar(
      '네트워크 오류',
      '인터넷 연결을 확인해주세요',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      '오류',
      '박스 가입에 실패했습니다',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
}

/// 박스 변경 확인 모달
Future<bool?> _showBoxChangeConfirmModal(BoxModel newBox) async {
  return await SketchModal.show<bool>(
    context: Get.context!,
    title: '박스 변경',
    child: Column(
      children: [
        Text("현재 '${currentBox.value!.name}'에서 탈퇴하고"),
        Text("'${newBox.name}'에 가입합니다."),
        const SizedBox(height: 8),
        const Text(
          '기존 박스의 데이터는 유지됩니다.',
          style: TextStyle(fontSize: 12, color: Color(0xFF8E8E8E)),
        ),
      ],
    ),
    actions: [
      SketchButton(
        text: '취소',
        style: SketchButtonStyle.outline,
        onPressed: () => Navigator.pop(Get.context!, false),
      ),
      SketchButton(
        text: '변경',
        onPressed: () => Navigator.pop(Get.context!, true),
      ),
    ],
  );
}

/// 정리
@override
void onClose() {
  nameController.dispose();
  regionController.dispose();
  super.onClose();
}
```

---

### 2. BoxCreateController

**파일**: `apps/wowa/lib/app/modules/box/controllers/box_create_controller.dart`

#### 반응형 상태 (.obs)

```dart
/// 생성 중 로딩 상태
final isLoading = false.obs;

/// 박스 이름 에러 메시지
final nameError = ''.obs;

/// 박스 지역 에러 메시지
final regionError = ''.obs;

/// 제출 가능 여부
final canSubmit = false.obs;
```

**설계 근거**:
- `isLoading`: 생성 API 호출 중 버튼 로딩 상태
- `nameError`, `regionError`: TextField 하단 에러 메시지
- `canSubmit`: 버튼 활성화/비활성화 (이름+지역 모두 입력 시 true)

#### 비반응형 상태

```dart
/// 박스 이름 입력 컨트롤러
late final TextEditingController nameController;

/// 박스 지역 입력 컨트롤러
late final TextEditingController regionController;

/// 박스 설명 입력 컨트롤러 (선택)
late final TextEditingController descriptionController;

/// Repository
late final BoxRepository _repository;
```

#### 메서드 인터페이스

```dart
/// 초기화
@override
void onInit() {
  super.onInit();
  nameController = TextEditingController();
  regionController = TextEditingController();
  descriptionController = TextEditingController();
  _repository = Get.find<BoxRepository>();

  // 입력 값 변경 시 유효성 검증
  nameController.addListener(_validateInputs);
  regionController.addListener(_validateInputs);
}

/// 입력 유효성 검증
void _validateInputs() {
  final name = nameController.text.trim();
  final region = regionController.text.trim();

  nameError.value = name.isEmpty ? '박스 이름을 입력하세요' : '';
  regionError.value = region.isEmpty ? '지역을 입력하세요' : '';

  canSubmit.value = name.isNotEmpty && region.isNotEmpty;
}

/// 박스 생성 (+ 자동 가입)
Future<void> create() async {
  final name = nameController.text.trim();
  final region = regionController.text.trim();
  final description = descriptionController.text.trim();

  if (!canSubmit.value) return;

  isLoading.value = true;
  try {
    final box = await _repository.createBox(
      name: name,
      region: region,
      description: description.isEmpty ? null : description,
    );

    Get.snackbar(
      '생성 완료',
      '${box.name}이(가) 생성되었습니다',
      snackPosition: SnackPosition.BOTTOM,
    );

    // 홈으로 이동 (기존 스택 전부 제거)
    Get.offAllNamed(Routes.HOME);
  } on NetworkException catch (e) {
    Get.snackbar(
      '네트워크 오류',
      '인터넷 연결을 확인해주세요',
      snackPosition: SnackPosition.BOTTOM,
    );
  } on BusinessException catch (e) {
    // 409: 중복 박스 에러
    if (e.code == 'DUPLICATE_BOX') {
      Get.snackbar(
        '중복된 박스',
        '이미 같은 이름의 박스가 존재합니다. 검색해보세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        '오류',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    Get.snackbar(
      '오류',
      '박스 생성에 실패했습니다',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
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

### 3. HomeController

**파일**: `apps/wowa/lib/app/modules/wod/controllers/home_controller.dart`

#### 반응형 상태 (.obs)

```dart
/// 현재 가입된 박스
final currentBox = Rxn<BoxModel>();

/// 선택된 날짜 (기본값: 오늘)
final selectedDate = DateTime.now().obs;

/// Base WOD
final baseWod = Rxn<WodModel>();

/// Personal WODs
final personalWods = <WodModel>[].obs;

/// 로딩 상태
final isLoading = false.obs;

/// WOD 존재 여부
final hasWod = false.obs;

/// 알림 개수
final unreadCount = 0.obs;
```

**설계 근거**:
- `selectedDate`: 날짜 변경 시 WOD 다시 조회
- `baseWod`, `personalWods`: WOD 카드 섹션 렌더링
- `hasWod`: 버튼 활성화/비활성화 (상세보기, WOD 선택)
- `unreadCount`: AppBar 알림 배지

#### 비반응형 상태

```dart
/// Repository
late final BoxRepository _boxRepository;
late final WodRepository _wodRepository;
```

#### Computed Properties

```dart
/// 날짜 포맷 (2026년 2월 4일)
String get formattedDate => DateFormat('yyyy년 M월 d일').format(selectedDate.value);

/// 요일 (화요일)
String get dayOfWeek => DateFormat('EEEE', 'ko').format(selectedDate.value);

/// 오늘 날짜 여부
bool get isToday {
  final now = DateTime.now();
  final date = selectedDate.value;
  return now.year == date.year && now.month == date.month && now.day == date.day;
}
```

#### 메서드 인터페이스

```dart
/// 초기화
@override
void onInit() {
  super.onInit();
  _boxRepository = Get.find<BoxRepository>();
  _wodRepository = Get.find<WodRepository>();

  // 현재 박스 조회 후 오늘의 WOD 조회
  _loadInitialData();
}

/// 초기 데이터 로드
Future<void> _loadInitialData() async {
  isLoading.value = true;
  try {
    // 1. 현재 박스 조회
    final box = await _boxRepository.getCurrentBox();
    currentBox.value = box;

    // 2. 오늘의 WOD 조회
    await _loadWodForDate(selectedDate.value);
  } on NetworkException catch (e) {
    Get.snackbar(
      '네트워크 오류',
      '인터넷 연결을 확인해주세요',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      '오류',
      '데이터를 불러오는데 실패했습니다',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
}

/// 특정 날짜의 WOD 조회
Future<void> _loadWodForDate(DateTime date) async {
  try {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final wods = await _wodRepository.getWodsByDate(
      boxId: currentBox.value!.id,
      date: dateStr,
    );

    baseWod.value = wods.baseWod;
    personalWods.value = wods.personalWods;
    hasWod.value = wods.baseWod != null;
  } catch (e) {
    // 날짜 변경 시 에러는 무시 (WOD 없을 수 있음)
    baseWod.value = null;
    personalWods.clear();
    hasWod.value = false;
  }
}

/// 이전 날짜로 이동
void previousDay() {
  selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  _loadWodForDate(selectedDate.value);
}

/// 다음 날짜로 이동
void nextDay() {
  selectedDate.value = selectedDate.value.add(const Duration(days: 1));
  _loadWodForDate(selectedDate.value);
}

/// DatePicker 표시
Future<void> showDatePicker() async {
  final picked = await Get.dialog<DateTime>(
    DatePickerDialog(
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ),
  );

  if (picked != null && picked != selectedDate.value) {
    selectedDate.value = picked;
    _loadWodForDate(selectedDate.value);
  }
}

/// Pull-to-refresh
Future<void> refresh() async {
  await _loadWodForDate(selectedDate.value);
}

/// WOD 등록 화면으로 이동
void goToRegister() {
  Get.toNamed(
    Routes.WOD_REGISTER,
    arguments: {
      'boxId': currentBox.value!.id,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
    },
  );
}

/// WOD 상세 화면으로 이동
void goToDetail() {
  if (!hasWod.value) return;

  Get.toNamed(
    Routes.WOD_DETAIL,
    arguments: {
      'boxId': currentBox.value!.id,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
    },
  );
}

/// WOD 선택 화면으로 이동
void goToSelect() {
  if (!hasWod.value) return;

  Get.toNamed(
    Routes.WOD_SELECT,
    arguments: {
      'boxId': currentBox.value!.id,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate.value),
    },
  );
}
```

---

## API 통합 설계

### API 모델 (packages/api/lib/src/models/)

Senior Developer가 구현합니다.

#### Box Models

```dart
// packages/api/lib/src/models/box/box_model.dart

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
    required int memberCount,
    DateTime? joinedAt, // 내 박스 조회 시만 포함
  }) = _BoxModel;

  factory BoxModel.fromJson(Map<String, dynamic> json) =>
      _$BoxModelFromJson(json);
}

// packages/api/lib/src/models/box/create_box_request.dart

@freezed
class CreateBoxRequest with _$CreateBoxRequest {
  factory CreateBoxRequest({
    required String name,
    required String region,
    String? description,
  }) = _CreateBoxRequest;

  factory CreateBoxRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBoxRequestFromJson(json);
}
```

#### WOD Models

```dart
// packages/api/lib/src/models/wod/movement.dart

@freezed
class Movement with _$Movement {
  factory Movement({
    required String name,
    int? reps,
    double? weight,
    String? unit, // 'kg' | 'lb' | 'bw'
  }) = _Movement;

  factory Movement.fromJson(Map<String, dynamic> json) =>
      _$MovementFromJson(json);
}

// packages/api/lib/src/models/wod/program_data.dart

@freezed
class ProgramData with _$ProgramData {
  factory ProgramData({
    required String type, // 'AMRAP' | 'ForTime' | 'EMOM' | 'Strength' | 'Custom'
    int? timeCap,
    int? rounds,
    required List<Movement> movements,
  }) = _ProgramData;

  factory ProgramData.fromJson(Map<String, dynamic> json) =>
      _$ProgramDataFromJson(json);
}

// packages/api/lib/src/models/wod/wod_model.dart

@freezed
class WodModel with _$WodModel {
  factory WodModel({
    required int id,
    required int boxId,
    required String date, // YYYY-MM-DD
    required ProgramData programData,
    required String rawText,
    required bool isBase,
    required int createdBy,
    String? registeredBy, // 등록자 닉네임 (서버에서 조인)
    int? selectedCount, // 선택한 사용자 수 (서버에서 계산)
    required String createdAt,
  }) = _WodModel;

  factory WodModel.fromJson(Map<String, dynamic> json) =>
      _$WodModelFromJson(json);
}

// packages/api/lib/src/models/wod/register_wod_request.dart

@freezed
class RegisterWodRequest with _$RegisterWodRequest {
  factory RegisterWodRequest({
    required int boxId,
    required String date,
    required ProgramData programData,
    required String rawText,
  }) = _RegisterWodRequest;

  factory RegisterWodRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterWodRequestFromJson(json);
}

// packages/api/lib/src/models/wod/wod_list_response.dart

@freezed
class WodListResponse with _$WodListResponse {
  factory WodListResponse({
    WodModel? baseWod,
    @Default([]) List<WodModel> personalWods,
  }) = _WodListResponse;

  factory WodListResponse.fromJson(Map<String, dynamic> json) =>
      _$WodListResponseFromJson(json);
}
```

### API Clients (packages/api/lib/src/clients/)

Senior Developer가 구현합니다.

#### BoxApiClient

```dart
// packages/api/lib/src/clients/box_api_client.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/box/box_model.dart';
import '../models/box/create_box_request.dart';

class BoxApiClient {
  final Dio _dio = Get.find<Dio>();

  /// 내 현재 박스 조회
  Future<BoxModel?> getCurrentBox() async {
    final response = await _dio.get('/boxes/me');
    final data = response.data['box'];
    return data != null ? BoxModel.fromJson(data) : null;
  }

  /// 박스 검색
  Future<List<BoxModel>> searchBoxes({
    String? name,
    String? region,
  }) async {
    final response = await _dio.get(
      '/boxes/search',
      queryParameters: {
        if (name != null) 'name': name,
        if (region != null) 'region': region,
      },
    );
    final List boxes = response.data['boxes'];
    return boxes.map((b) => BoxModel.fromJson(b)).toList();
  }

  /// 박스 생성 (+ 자동 가입)
  Future<BoxModel> createBox(CreateBoxRequest request) async {
    final response = await _dio.post('/boxes', data: request.toJson());
    return BoxModel.fromJson(response.data['box']);
  }

  /// 박스 가입 (+ 기존 박스 자동 탈퇴)
  Future<void> joinBox(int boxId) async {
    await _dio.post('/boxes/$boxId/join');
  }

  /// 박스 상세 조회
  Future<BoxModel> getBoxById(int boxId) async {
    final response = await _dio.get('/boxes/$boxId');
    return BoxModel.fromJson(response.data);
  }
}
```

#### WodApiClient

```dart
// packages/api/lib/src/clients/wod_api_client.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/wod/wod_model.dart';
import '../models/wod/register_wod_request.dart';
import '../models/wod/wod_list_response.dart';

class WodApiClient {
  final Dio _dio = Get.find<Dio>();

  /// WOD 등록
  Future<WodModel> registerWod(RegisterWodRequest request) async {
    final response = await _dio.post('/wods', data: request.toJson());
    return WodModel.fromJson(response.data);
  }

  /// 날짜별 WOD 조회 (Base + Personal)
  Future<WodListResponse> getWodsByDate({
    required int boxId,
    required String date,
  }) async {
    final response = await _dio.get('/wods/$boxId/$date');
    return WodListResponse.fromJson(response.data);
  }

  /// WOD 선택
  Future<void> selectWod({
    required int wodId,
    required int boxId,
    required String date,
  }) async {
    await _dio.post(
      '/wods/$wodId/select',
      data: {'boxId': boxId, 'date': date},
    );
  }

  /// 대기 중인 변경 제안 확인
  Future<bool> hasPendingProposal({required int baseWodId}) async {
    final response = await _dio.get('/wods/proposals',
      queryParameters: {
        'baseWodId': baseWodId,
        'status': 'pending',
      },
    );
    final List proposals = response.data['proposals'];
    return proposals.isNotEmpty;
  }

  /// 변경 제안 승인
  Future<void> approveProposal({required int proposalId}) async {
    await _dio.post('/wods/proposals/$proposalId/approve');
  }

  /// 변경 제안 거부
  Future<void> rejectProposal({required int proposalId}) async {
    await _dio.post('/wods/proposals/$proposalId/reject');
  }
}
```

### Repository 패턴 (apps/wowa/lib/app/data/repositories/)

Junior Developer가 구현합니다.

#### BoxRepository

```dart
// apps/wowa/lib/app/data/repositories/box_repository.dart

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';

class BoxRepository {
  final BoxApiClient _client = Get.find<BoxApiClient>();

  /// 현재 박스 조회
  Future<BoxModel?> getCurrentBox() async {
    try {
      return await _client.getCurrentBox();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: '네트워크 연결이 불안정합니다');
      }
      rethrow;
    }
  }

  /// 박스 검색
  Future<List<BoxModel>> searchBoxes({
    String? name,
    String? region,
  }) async {
    try {
      return await _client.searchBoxes(name: name, region: region);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: '네트워크 연결이 불안정합니다');
      }
      rethrow;
    }
  }

  /// 박스 생성
  Future<BoxModel> createBox({
    required String name,
    required String region,
    String? description,
  }) async {
    try {
      final request = CreateBoxRequest(
        name: name,
        region: region,
        description: description,
      );
      return await _client.createBox(request);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw BusinessException(
          message: '이미 같은 이름의 박스가 존재합니다',
          code: 'DUPLICATE_BOX',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: '네트워크 연결이 불안정합니다');
      }
      rethrow;
    }
  }

  /// 박스 가입
  Future<void> joinBox(int boxId) async {
    try {
      await _client.joinBox(boxId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: '박스를 찾을 수 없습니다');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: '네트워크 연결이 불안정합니다');
      }
      rethrow;
    }
  }
}
```

### build_runner 실행

Senior Developer가 API 모델 작성 후 실행:

```bash
cd /Users/lms/dev/repository/feature-wowa-mvp
melos generate
```

생성되는 파일:
- `*.freezed.dart` — Freezed 코드 생성
- `*.g.dart` — json_serializable 코드 생성

---

## 라우팅 설계

### Route Names

**파일**: `apps/wowa/lib/app/routes/app_routes.dart`

```dart
abstract class Routes {
  static const LOGIN = '/login';

  // Box
  static const BOX_SEARCH = '/box/search';
  static const BOX_CREATE = '/box/create';

  // WOD
  static const HOME = '/home';
  static const WOD_REGISTER = '/wod/register';
  static const WOD_DETAIL = '/wod/detail';
  static const WOD_SELECT = '/wod/select';
  static const PROPOSAL_REVIEW = '/proposal/review';

  // Settings
  static const SETTINGS = '/settings';
}
```

### Route Definitions

**파일**: `apps/wowa/lib/app/routes/app_pages.dart`

```dart
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // Login (이미 구현됨)
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Box
    GetPage(
      name: Routes.BOX_SEARCH,
      page: () => const BoxSearchView(),
      binding: BoxSearchBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.BOX_CREATE,
      page: () => const BoxCreateView(),
      binding: BoxCreateBinding(),
      transition: Transition.downToUp,
    ),

    // WOD
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.WOD_REGISTER,
      page: () => const WodRegisterView(),
      binding: WodRegisterBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.WOD_DETAIL,
      page: () => const WodDetailView(),
      binding: WodDetailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.WOD_SELECT,
      page: () => const WodSelectView(),
      binding: WodSelectBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PROPOSAL_REVIEW,
      page: () => const ProposalReviewView(),
      binding: ProposalReviewBinding(),
      transition: Transition.fadeIn,
    ),

    // Settings
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.leftToRight,
    ),
  ];
}
```

---

## 작업 분배 계획

### Phase 1: Box 관리

#### Senior Developer 작업
1. API 모델 작성 (packages/api/)
   - `BoxModel`, `CreateBoxRequest`
2. `BoxApiClient` 구현 (packages/api/)
   - `getCurrentBox()`, `searchBoxes()`, `createBox()`, `joinBox()`
3. `melos generate` 실행 (Freezed 코드 생성)
4. `BoxSearchController` 작성 (apps/wowa/)
   - 검색 로직, 박스 가입 로직, 박스 변경 확인 모달
5. `BoxCreateController` 작성 (apps/wowa/)
   - 유효성 검증, 박스 생성 로직
6. `BoxSearchBinding`, `BoxCreateBinding` 작성

#### Junior Developer 작업
1. `BoxRepository` 작성 (apps/wowa/)
   - Senior의 `BoxApiClient` 메서드 호출, 에러 처리
2. `BoxSearchView` 작성 (apps/wowa/)
   - TextField, 검색 결과 ListView, 박스 변경 확인 모달
3. `BoxCreateView` 작성 (apps/wowa/)
   - SketchInput, 생성 버튼
4. `app_routes.dart`, `app_pages.dart` 업데이트

**작업 의존성**: Junior는 Senior의 Controller + API Client 완성 후 시작

---

## 검증 기준

- [ ] GetX 패턴 준수 (Controller, View, Binding 분리)
- [ ] 반응형 상태 정확히 정의 (.obs)
- [ ] const 최적화 적용 (정적 위젯)
- [ ] Obx 범위 최소화 (변경되는 부분만)
- [ ] 에러 처리 완비 (NetworkException, BusinessException)
- [ ] 라우팅 정확히 설정 (named routes, arguments)
- [ ] CLAUDE.md 표준 준수 (주석 한글, import 패턴)

---

## 참고 자료

### Design System
- Design Tokens: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/design-tokens.json`
- Design System Guide: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/design_system.md`

### Flutter Guides
- Flutter Best Practices: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/flutter_best_practices.md`
- GetX Best Practices: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/getx_best_practices.md`
- Common Patterns: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/common_patterns.md`
- Error Handling: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/error_handling.md`

### Project References
- User Story: `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/user-story.md`
- Mobile Design Spec: `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/mobile-design-spec.md`
- Server Brief: `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mvp/server-brief.md`
- Mobile Catalog: `/Users/lms/dev/repository/feature-wowa-mvp/docs/wowa/mobile-catalog.md`

---

**작성일**: 2026-02-04
**버전**: 2.0.0
**상태**: Design Complete

다음 단계: CTO 검증 후 Senior/Junior Developer에게 작업 분배
