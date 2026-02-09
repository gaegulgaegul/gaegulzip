# Mobile CTO Review: wowa-box

**Feature**: wowa-box (박스 관리 기능 개선)
**Platform**: Mobile (Flutter/GetX)
**Reviewer**: CTO
**Date**: 2026-02-09

---

## 검증 결과 요약

### 정적 분석 결과
- **flutter analyze**: ✅ 통과
- **Info 레벨**: 14개 (constant_identifier_names, use_super_parameters)
- **Warning/Error**: 0개
- **상태**: ✅ 문제 없음 (Info는 스타일 권장 사항)

### 패키지 구조 검증
```
api/
├── models/box/
│   ├── box_model.dart (Freezed) ✅
│   ├── box_search_response.dart (Freezed) ✅
│   ├── create_box_request.dart (Freezed) ✅
│   ├── box_create_response.dart (Freezed) ✅
│   ├── membership_model.dart (Freezed) ✅
│   └── box_member_model.dart (Freezed) ✅
└── clients/
    └── box_api_client.dart ✅

wowa/lib/app/modules/box/
├── controllers/
│   ├── box_search_controller.dart ✅
│   └── box_create_controller.dart ✅
├── views/
│   ├── box_search_view.dart ✅
│   └── box_create_view.dart ✅
└── bindings/
    ├── box_search_binding.dart ✅
    └── box_create_binding.dart ✅
```

---

## 코드 품질 평가

### 1. GetX 패턴 준수 (Controller/View/Binding 분리) ✅

#### Controller 1: BoxSearchController

**반응형 상태 (.obs)**:
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

**평가**: ✅ 우수
- .obs 사용 올바름 (반응형 필요한 상태만)
- Rxn 사용 (nullable 타입)
- 상태 이름 명확 (keyword, isLoading, errorMessage)

**비반응형 상태**:
```dart
late final BoxRepository _repository;
late final TextEditingController searchController;
Worker? _debounceWorker;
```

**평가**: ✅ 적절
- Repository는 의존성 주입 (반응형 불필요)
- TextEditingController는 리스너로 keyword 동기화
- Worker는 onClose에서 dispose

**Debounce 구현**:
```dart
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

  // TextEditingController 리스너 (keyword 동기화)
  searchController.addListener(() {
    keyword.value = searchController.text;
  });
}
```

**평가**: ✅ 우수
- 300ms debounce 적용 (design-spec 준수)
- TextEditingController → keyword.obs 동기화
- onClose에서 dispose 처리

#### Controller 2: BoxCreateController

**반응형 상태**:
```dart
final isLoading = false.obs;
final nameError = RxnString();
final regionError = RxnString();
final canSubmit = false.obs;
```

**평가**: ✅ 우수
- RxnString 사용 (nullable error message)
- 실시간 유효성 검증 (TextEditingController listener)
- canSubmit 계산 정확 (nameError, regionError 체크)

#### Binding: BoxSearchBinding, BoxCreateBinding

```dart
class BoxSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoxRepository>(() => BoxRepository());
    Get.lazyPut<BoxSearchController>(() => BoxSearchController());
  }
}
```

**평가**: ✅ 올바름
- Get.lazyPut 사용 (화면 진입 시 생성)
- Repository 의존성 주입
- Controller 생성 시 Repository 자동 찾기

### 2. API 모델 (Freezed/json_serializable) ✅

**BoxModel**:
```dart
@freezed
class BoxModel with _$BoxModel {
  const factory BoxModel({
    required int id,
    required String name,
    required String region,
    String? description,
    int? memberCount,
    String? joinedAt,
  }) = _BoxModel;

  factory BoxModel.fromJson(Map<String, dynamic> json) =>
      _$BoxModelFromJson(json);
}
```

**평가**: ✅ 우수
- Freezed 어노테이션 올바름
- nullable 필드 명시 (description, memberCount, joinedAt)
- json_serializable 통합

**BoxSearchResponse**:
```dart
@freezed
class BoxSearchResponse with _$BoxSearchResponse {
  const factory BoxSearchResponse({
    required List<BoxModel> boxes,
  }) = _BoxSearchResponse;

  factory BoxSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$BoxSearchResponseFromJson(json);
}
```

**평가**: ✅ 우수
- Server 응답 구조와 일치
- List<BoxModel> 타입 안전성

**CreateBoxRequest**:
```dart
@freezed
class CreateBoxRequest with _$CreateBoxRequest {
  const factory CreateBoxRequest({
    required String name,
    required String region,
    String? description,
  }) = _CreateBoxRequest;

  factory CreateBoxRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBoxRequestFromJson(json);
}
```

**평가**: ✅ Server API와 일치

### 3. API Client (Dio) ✅

**BoxApiClient**:
```dart
class BoxApiClient {
  final Dio _dio = Get.find<Dio>();

  /// 박스 검색 (통합 키워드)
  Future<List<BoxModel>> searchBoxes(String keyword) async {
    final response = await _dio.get(
      '/boxes/search',
      queryParameters: {'keyword': keyword},
    );

    final searchResponse = BoxSearchResponse.fromJson(response.data);
    return searchResponse.boxes;
  }

  /// 박스 생성
  Future<BoxCreateResponse> createBox(CreateBoxRequest request) async {
    final response = await _dio.post(
      '/boxes',
      data: request.toJson(),
    );
    return BoxCreateResponse.fromJson(response.data);
  }

  /// 박스 가입
  Future<MembershipModel> joinBox(int boxId) async {
    final response = await _dio.post('/boxes/$boxId/join');
    return MembershipModel.fromJson(response.data['membership']);
  }
}
```

**평가**: ✅ 우수
- JSDoc 주석 충실 (한국어)
- GET/POST 메서드 정확
- queryParameters, data 사용 올바름
- Freezed 모델 활용 (타입 안전성)

**⚠️ 발견 사항**: `joinBox` 메서드가 `response.data['membership']`만 파싱
- Server는 `{ membership, previousBoxId }` 반환
- `previousBoxId` 정보 손실 (UX 개선 기회 상실)
- 권장: `JoinBoxResponse` 모델 추가하여 전체 응답 파싱

### 4. Controller-View 연결 검증 ✅

#### BoxSearchView

**Obx 사용 (검색 결과 영역)**:
```dart
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
```

**평가**: ✅ 우수
- 5가지 UI 상태 명확히 구분 (design-spec 준수)
- Obx 범위 최소화 (검색 결과 영역만)
- 조건 분기 순서 올바름 (로딩 → 빈 값 → 에러 → 결과 없음 → 결과 표시)

**⚠️ 발견 사항**: BoxSearchView에서 박스 카드가 placeholder로 구현됨
```dart
Widget _buildBoxCard(dynamic box) {
  // 임시 플레이스홀더 UI
  return SketchCard(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Row(
          children: [
            Expanded(
              child: Text(
                'Box Name Placeholder',  // ⚠️ 하드코딩
                style: TextStyle(
                  fontSize: SketchDesignTokens.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: SketchDesignTokens.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 지역
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: SketchDesignTokens.base500,
            ),
            const SizedBox(width: 4),
            Text(
              'Region Placeholder',  // ⚠️ 하드코딩
              style: TextStyle(
                fontSize: SketchDesignTokens.fontSizeSm,
                color: SketchDesignTokens.base700,
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
        onPressed: () {
          // ⚠️ 구현 안 됨
        },
      ),
    ),
  );
}
```

**문제**:
- `box.name`, `box.region` 대신 'Placeholder' 문자열 사용
- `controller.joinBox(box.id)` 대신 빈 onPressed
- BoxModel 필드를 실제로 사용하지 않음

**영향**: 검색 기능이 UI 레벨에서 작동하지 않음 (API는 정상)

**권장**: BoxModel 필드를 실제로 바인딩
```dart
Widget _buildBoxCard(BoxModel box) {  // dynamic → BoxModel
  return SketchCard(
    body: Column(
      children: [
        Text(box.name),  // Placeholder → box.name
        Text(box.region),  // Placeholder → box.region
        if (box.description != null) Text(box.description!),
        if (box.memberCount != null) Text('${box.memberCount}명'),
      ],
    ),
    footer: SketchButton(
      text: '가입',
      onPressed: () => controller.joinBox(box.id),  // 구현
    ),
  );
}
```

#### BoxCreateView

**Obx 사용 (입력 필드)**:
```dart
Widget _buildNameInput() {
  return Obx(
    () => SketchInput(
      controller: controller.nameController,
      label: '박스 이름',
      hint: '크로스핏 박스 이름',
      errorText: controller.nameError.value,
      maxLength: 50,
    ),
  );
}
```

**평가**: ✅ 우수
- Obx로 errorText 반응형 처리
- 나머지 속성은 정적 (const 불가능하지만 최적화됨)

### 5. Design System 컴포넌트 활용 ✅

**사용 컴포넌트**:
- ✅ SketchInput: 검색, 이름, 지역, 설명
- ✅ SketchButton: 가입, 생성, FAB
- ✅ SketchCard: 박스 카드
- ✅ SketchModal: 박스 변경 확인 (BoxSearchController.joinBox)
- ✅ Get.snackbar: 성공/에러 메시지

**평가**: ✅ 우수 (Design System 재사용)

### 6. 에러 처리 ✅

**BoxSearchController - searchBoxes**:
```dart
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
    backgroundColor: SketchDesignTokens.error.withValues(alpha: 0.1),
    colorText: SketchDesignTokens.error,
    duration: const Duration(seconds: 3),
  );
} catch (e) {
  errorMessage.value = '일시적인 문제가 발생했습니다';
  searchResults.clear();
  Get.snackbar(/* ... */);
} finally {
  isLoading.value = false;
}
```

**평가**: ✅ 우수
- NetworkException 명시적 처리
- 일반 예외 catch 처리
- errorMessage 업데이트 (UI 상태 변경)
- 스낵바로 사용자 피드백
- finally로 로딩 종료

**BoxCreateController - createBox**:
```dart
try {
  await _repository.createBox(/* ... */);
  Get.snackbar('박스 생성 완료', '박스가 생성되었습니다');
  Get.offAllNamed(Routes.HOME);
} on NetworkException catch (e) {
  SketchModal.show(
    context: Get.context!,
    title: '오류',
    child: Text(e.message),
    actions: [
      SketchButton(text: '닫기', onPressed: () => Navigator.of(Get.context!).pop()),
      SketchButton(text: '재시도', onPressed: () { Navigator.of(Get.context!).pop(); createBox(); }),
    ],
    barrierDismissible: false,
  );
} catch (e) {
  SketchModal.show(/* ... */);
} finally {
  isLoading.value = false;
}
```

**평가**: ✅ 우수
- 모달로 에러 표시 (중요 작업이므로 스낵바 대신 모달)
- 재시도 버튼 제공
- barrierDismissible: false (사용자 명시적 선택 강제)

### 7. mobile-design-spec.md 준수 검증 ✅

#### 레이아웃 계층
- ✅ Scaffold → AppBar + Body + FAB
- ✅ SafeArea 사용
- ✅ Column → SketchInput + Expanded(검색 결과)
- ✅ FloatingActionButton: SketchButton (primary)

#### 색상 팔레트
- ✅ SketchDesignTokens.error (에러 색상)
- ✅ SketchDesignTokens.success (성공 색상)
- ✅ SketchDesignTokens.base500 (아이콘 색상)
- ✅ SketchDesignTokens.base700 (보조 텍스트)

#### 타이포그래피
- ✅ fontSizeLg (18px) — 카드 제목
- ✅ fontSizeBase (16px) — 입력 필드, 본문
- ✅ fontSizeSm (14px) — 지역, 설명
- ✅ FontWeight.bold — 카드 제목

#### 스페이싱
- ✅ EdgeInsets.all(16) — 화면 패딩
- ✅ SizedBox(height: 16) — 위젯 간 간격
- ✅ margin: EdgeInsets.only(bottom: 12) — 카드 간격

#### 애니메이션
- ⚠️ Route Transition 설정 확인 안 됨 (app_pages.dart에서 설정 필요)
- ✅ CircularProgressIndicator (로딩 상태)

### 8. const 최적화 ✅

**BoxSearchView**:
```dart
const SizedBox(height: 16),
const Icon(Icons.search, size: 64, color: SketchDesignTokens.base300),
const Center(child: CircularProgressIndicator()),
```

**평가**: ✅ 우수
- 정적 위젯 const 사용
- Obx 내부는 const 불가 (정상)

**BoxCreateView**:
```dart
const SizedBox(height: 16),
const Text('박스 생성'),
```

**평가**: ✅ 적절

---

## API Contract 검증 (Mobile ↔ Server)

### 1. 박스 검색
- ✅ 엔드포인트: `/boxes/search?keyword=...` (일치)
- ✅ Response: `{ boxes: BoxModel[] }` (일치)
- ✅ BoxModel 필드: id, name, region, description, memberCount (일치)

### 2. 박스 생성
- ✅ 엔드포인트: `/boxes` (일치)
- ✅ Request: `{ name, region, description }` (일치)
- ✅ Response: `{ box, membership, previousBoxId }` (일치)

### 3. 박스 가입
- ✅ 엔드포인트: `/boxes/:boxId/join` (일치)
- ⚠️ Response: Server는 `{ membership, previousBoxId }` 반환하지만, Mobile은 `membership`만 파싱

---

## 발견된 이슈 및 권장 사항

### 🔴 Critical: BoxSearchView - 박스 카드 미구현

**위치**: `apps/wowa/lib/app/modules/box/views/box_search_view.dart:203-261`

**문제**:
```dart
Widget _buildBoxCard(dynamic box) {
  // 임시 플레이스홀더 UI
  return SketchCard(
    body: Column(
      children: [
        Text('Box Name Placeholder'),  // ❌ 하드코딩
        Text('Region Placeholder'),     // ❌ 하드코딩
      ],
    ),
    footer: SketchButton(
      text: '가입',
      onPressed: () {
        // ❌ 구현 안 됨
      },
    ),
  );
}
```

**영향**: 검색 기능이 UI 레벨에서 작동하지 않음

**해결 방법**:
```dart
Widget _buildBoxCard(BoxModel box) {  // dynamic → BoxModel
  return SketchCard(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Row(
          children: [
            Expanded(
              child: Text(
                box.name,  // ✅ 실제 데이터
                style: const TextStyle(
                  fontSize: SketchDesignTokens.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: SketchDesignTokens.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 지역
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: SketchDesignTokens.base500,
            ),
            const SizedBox(width: 4),
            Text(
              box.region,  // ✅ 실제 데이터
              style: const TextStyle(
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
            box.description!,  // ✅ 실제 데이터
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
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
                '${box.memberCount}명',  // ✅ 실제 데이터
                style: const TextStyle(
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
        onPressed: () => controller.joinBox(box.id),  // ✅ 구현
      ),
    ),
  );
}
```

### 🟡 Medium: previousBoxId 활용 안 됨

**위치**: `apps/mobile/packages/api/lib/src/clients/box_api_client.dart:70-73`

**문제**:
```dart
Future<MembershipModel> joinBox(int boxId) async {
  final response = await _dio.post('/boxes/$boxId/join');
  return MembershipModel.fromJson(response.data['membership']);
  // ❌ previousBoxId 정보 손실
}
```

**권장**:
```dart
// 1. 응답 모델 추가
@freezed
class JoinBoxResponse with _$JoinBoxResponse {
  const factory JoinBoxResponse({
    required MembershipModel membership,
    int? previousBoxId,
  }) = _JoinBoxResponse;

  factory JoinBoxResponse.fromJson(Map<String, dynamic> json) =>
      _$JoinBoxResponseFromJson(json);
}

// 2. API Client 수정
Future<JoinBoxResponse> joinBox(int boxId) async {
  final response = await _dio.post('/boxes/$boxId/join');
  return JoinBoxResponse.fromJson(response.data);
}

// 3. Controller에서 활용
if (result.previousBoxId != null) {
  Get.snackbar(
    '박스 변경 완료',
    '이전 박스에서 탈퇴하고 새 박스에 가입했습니다',
  );
}
```

### 🟢 Low: BoxModel 필드 확장 (향후)

**권장**:
```dart
@freezed
class BoxModel with _$BoxModel {
  const factory BoxModel({
    required int id,
    required String name,
    required String region,
    String? description,
    int? memberCount,
    String? joinedAt,
    int? createdBy,       // 추가
    String? createdAt,    // 추가
    String? updatedAt,    // 추가
  }) = _BoxModel;
}
```

**이유**: Server가 반환하는 모든 필드 수용 (Freezed는 알 수 없는 필드 무시하므로 하위 호환성 유지)

---

## Quality Scores

| 항목 | 점수 | 평가 |
|------|------|------|
| **GetX 패턴** | 9.5/10 | Controller/View/Binding 완벽 분리, .obs 사용 올바름 |
| **API 모델** | 9.5/10 | Freezed 완벽 활용, json_serializable 통합 |
| **API Client** | 8.5/10 | JSDoc 충실, previousBoxId 파싱 누락 |
| **Controller-View 연결** | 7.0/10 | ❌ BoxSearchView 카드 미구현 (placeholder) |
| **Design Spec 준수** | 9.0/10 | 5가지 UI 상태, 색상/타이포/스페이싱 정확 |
| **에러 처리** | 9.5/10 | NetworkException 명시적 처리, 스낵바/모달 적절 |
| **const 최적화** | 9.0/10 | 정적 위젯 const 사용, Obx 범위 최소화 |
| **성능** | 9.5/10 | Debounce 300ms, ListView 최적화 |

**종합 점수**: **8.9/10** (우수, 단 BoxSearchView 카드 구현 필요)

---

## 최종 승인

### 승인 상태: ⚠️ **CONDITIONAL APPROVAL**

**승인 조건**:
1. 🔴 **BoxSearchView - 박스 카드 구현 필수** (box.name, box.region, controller.joinBox 바인딩)

**승인 후 다음 단계**:
1. BoxSearchView 카드 구현 완료
2. `flutter analyze` 재실행 (문제 없어야 함)
3. Independent Reviewer 검증
4. 문서 생성 (DONE.md)

**선택 사항 (권장)**:
- 🟡 `JoinBoxResponse` 모델 추가하여 previousBoxId 활용
- 🟢 BoxModel 필드 확장 (createdBy, createdAt, updatedAt)

---

**Reviewer**: CTO
**Date**: 2026-02-09
**Signature**: ⚠️ Conditional Approval (BoxSearchView 카드 구현 후 재검토)
