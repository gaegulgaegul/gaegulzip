# WOWA Mobile Technical Architecture Brief

> Feature: wowa
> Created: 2026-02-03
> Status: Draft
> Phase: Technical Design
> Platform: Mobile (Flutter)

---

## 1. Overview

WOWA 모바일 앱의 기술 아키텍처 설계서. `mobile-design-spec.md`의 9개 화면 설계를 기반으로 GetX 패턴, Freezed 모델, Dio 클라이언트, 라우팅을 정의한다.

**참조 문서**:
- UI/UX 설계: `docs/mobile/wowa/mobile-design-spec.md`
- 서버 API 계약: `docs/server/wowa/server-brief.md`
- 모바일 가이드: `apps/mobile/CLAUDE.md`

---

## 2. Module Architecture

```
apps/wowa/lib/app/
├── modules/
│   ├── login/                    # (기존 완료)
│   │   ├── controllers/login_controller.dart
│   │   ├── views/login_view.dart
│   │   └── bindings/login_binding.dart
│   │
│   ├── home/                     # 홈 (오늘의 WOD)
│   │   ├── controllers/home_controller.dart
│   │   ├── views/home_view.dart
│   │   └── bindings/home_binding.dart
│   │
│   ├── wod_registration/         # WOD 등록
│   │   ├── controllers/wod_registration_controller.dart
│   │   ├── views/wod_registration_view.dart
│   │   └── bindings/wod_registration_binding.dart
│   │
│   ├── wod_detail/               # WOD 상세
│   │   ├── controllers/wod_detail_controller.dart
│   │   ├── views/wod_detail_view.dart
│   │   └── bindings/wod_detail_binding.dart
│   │
│   ├── wod_selection/            # WOD 선택
│   │   ├── controllers/wod_selection_controller.dart
│   │   ├── views/wod_selection_view.dart
│   │   └── bindings/wod_selection_binding.dart
│   │
│   ├── propose_change/           # 변경 제안
│   │   ├── controllers/propose_change_controller.dart
│   │   ├── views/propose_change_view.dart
│   │   └── bindings/propose_change_binding.dart
│   │
│   ├── approve_change/           # 변경 승인
│   │   ├── controllers/approve_change_controller.dart
│   │   ├── views/approve_change_view.dart
│   │   └── bindings/approve_change_binding.dart
│   │
│   ├── box_management/           # 박스 관리
│   │   ├── controllers/box_management_controller.dart
│   │   ├── views/box_management_view.dart
│   │   └── bindings/box_management_binding.dart
│   │
│   ├── box_create/               # 박스 생성
│   │   ├── controllers/box_create_controller.dart
│   │   ├── views/box_create_view.dart
│   │   └── bindings/box_create_binding.dart
│   │
│   └── box_join/                 # 박스 가입
│       ├── controllers/box_join_controller.dart
│       ├── views/box_join_view.dart
│       └── bindings/box_join_binding.dart
│
├── data/
│   └── repositories/
│       └── auth_repository.dart  # (기존)
│
├── services/
│   ├── social_login/             # (기존)
│   └── app_state_service.dart    # 전역 상태 (현재 박스, 사용자)
│
└── routes/
    ├── app_routes.dart           # 라우트 상수
    └── app_pages.dart            # GetPage 등록
```

**API 패키지 구조** (`packages/api/`):

```
packages/api/lib/
├── src/
│   ├── client/
│   │   ├── api_client.dart          # Dio 인스턴스 설정
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart     # JWT 토큰 첨부
│   │       ├── refresh_interceptor.dart  # 토큰 갱신
│   │       └── error_interceptor.dart    # 에러 변환
│   │
│   ├── models/
│   │   ├── box/
│   │   │   ├── box_model.dart           # Box Freezed 모델
│   │   │   └── box_member_model.dart    # BoxMember Freezed 모델
│   │   ├── wod/
│   │   │   ├── wod_model.dart           # Wod Freezed 모델
│   │   │   ├── program_data_model.dart  # ProgramData Freezed 모델
│   │   │   ├── movement_model.dart      # Movement Freezed 모델
│   │   │   └── wod_selection_model.dart # WodSelection Freezed 모델
│   │   ├── proposal/
│   │   │   └── proposed_change_model.dart
│   │   └── common/
│   │       └── user_profile_model.dart  # 공통 사용자 프로필
│   │
│   └── services/
│       ├── box_api_service.dart      # Box API 호출
│       └── wod_api_service.dart      # WOD API 호출
│
└── api.dart                          # barrel export
```

---

## 3. Route Definitions

### 3.1 Route Constants

```dart
// app_routes.dart (기존 확장)
abstract class Routes {
  // 기존
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const SETTINGS = '/settings';

  // WOD
  static const WOD_REGISTER = '/wod/register';
  static const WOD_DETAIL = '/wod/detail';
  static const WOD_SELECT = '/wod/select';
  static const WOD_PROPOSE = '/wod/propose';
  static const WOD_APPROVE = '/wod/approve';

  // Box
  static const BOX_MANAGE = '/box/manage';
  static const BOX_CREATE = '/box/create';
  static const BOX_JOIN = '/box/join';
}
```

### 3.2 GetPage Registrations

```dart
// app_pages.dart (추가될 페이지)
GetPage(
  name: Routes.HOME,
  page: () => const HomeView(),
  binding: HomeBinding(),
  transition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 300),
),
GetPage(
  name: Routes.WOD_REGISTER,
  page: () => const WodRegistrationView(),
  binding: WodRegistrationBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: Routes.WOD_DETAIL,
  page: () => const WodDetailView(),
  binding: WodDetailBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: Routes.WOD_SELECT,
  page: () => const WodSelectionView(),
  binding: WodSelectionBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: Routes.WOD_PROPOSE,
  page: () => const ProposeChangeView(),
  binding: ProposeChangeBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: Routes.WOD_APPROVE,
  page: () => const ApproveChangeView(),
  binding: ApproveChangeBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: Routes.BOX_MANAGE,
  page: () => const BoxManagementView(),
  binding: BoxManagementBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: Routes.BOX_CREATE,
  page: () => const BoxCreateView(),
  binding: BoxCreateBinding(),
  transition: Transition.rightToLeft,
),
GetPage(
  name: Routes.BOX_JOIN,
  page: () => const BoxJoinView(),
  binding: BoxJoinBinding(),
  transition: Transition.rightToLeft,
),
```

### 3.3 Navigation Flow

```
Login → Home (offAllNamed, 로그인 스택 제거)
Home → WOD Register (toNamed)
Home → WOD Detail (toNamed, arguments: wodId)
Home → Box Manage (toNamed)
WOD Detail → WOD Select (toNamed, arguments: {date, boxId})
WOD Detail → WOD Propose (toNamed, arguments: wodId)
WOD Propose → WOD Approve (알림으로 진입, toNamed, arguments: proposalId)
Box Manage → Box Create (toNamed)
Box Manage → Box Join (toNamed)
Box Create → Box Manage (back)
Box Join → Box Manage (back)
WOD Register → Home (back, with refresh)
WOD Select → Home (back, with refresh)
```

---

## 4. API Models (Freezed)

### 4.1 Box Models

```dart
// packages/api/lib/src/models/box/box_model.dart
@freezed
class BoxModel with _$BoxModel {
  const factory BoxModel({
    required int id,
    required String name,
    String? description,
    required String inviteCode,
    required int createdBy,
    int? memberCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BoxModel;

  factory BoxModel.fromJson(Map<String, dynamic> json) =>
      _$BoxModelFromJson(json);
}
```

```dart
// packages/api/lib/src/models/box/box_member_model.dart
@freezed
class BoxMemberModel with _$BoxMemberModel {
  const factory BoxMemberModel({
    required int id,
    required int boxId,
    required int userId,
    required String role,
    required DateTime joinedAt,
    UserProfileModel? user,
  }) = _BoxMemberModel;

  factory BoxMemberModel.fromJson(Map<String, dynamic> json) =>
      _$BoxMemberModelFromJson(json);
}
```

```dart
// packages/api/lib/src/models/common/user_profile_model.dart
@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required int id,
    String? nickname,
    String? profileImage,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}
```

### 4.2 WOD Models

```dart
// packages/api/lib/src/models/wod/movement_model.dart
@freezed
class MovementModel with _$MovementModel {
  const factory MovementModel({
    required String name,
    int? reps,
    double? weight,
    String? unit,
  }) = _MovementModel;

  factory MovementModel.fromJson(Map<String, dynamic> json) =>
      _$MovementModelFromJson(json);
}
```

```dart
// packages/api/lib/src/models/wod/program_data_model.dart
@freezed
class ProgramDataModel with _$ProgramDataModel {
  const factory ProgramDataModel({
    required String type,          // AMRAP | ForTime | EMOM | Strength | Custom
    int? timeCap,
    int? rounds,
    @Default([]) List<MovementModel> movements,
  }) = _ProgramDataModel;

  factory ProgramDataModel.fromJson(Map<String, dynamic> json) =>
      _$ProgramDataModelFromJson(json);
}
```

```dart
// packages/api/lib/src/models/wod/wod_model.dart
@freezed
class WodModel with _$WodModel {
  const factory WodModel({
    required int id,
    required int boxId,
    required String date,            // "2026-02-03" (ISO date)
    required ProgramDataModel programData,
    String? rawText,
    required bool isBase,
    required int createdBy,
    String? comparisonResult,        // identical | similar | different
    required DateTime createdAt,
  }) = _WodModel;

  factory WodModel.fromJson(Map<String, dynamic> json) =>
      _$WodModelFromJson(json);
}
```

```dart
// packages/api/lib/src/models/wod/wod_selection_model.dart
@freezed
class WodSelectionModel with _$WodSelectionModel {
  const factory WodSelectionModel({
    required int id,
    required int userId,
    required int wodId,
    required int boxId,
    required String date,
    required ProgramDataModel snapshotData,
    required DateTime createdAt,
  }) = _WodSelectionModel;

  factory WodSelectionModel.fromJson(Map<String, dynamic> json) =>
      _$WodSelectionModelFromJson(json);
}
```

### 4.3 Proposal Models

```dart
// packages/api/lib/src/models/proposal/proposed_change_model.dart
@freezed
class ProposedChangeModel with _$ProposedChangeModel {
  const factory ProposedChangeModel({
    required int id,
    required int wodId,
    required int proposedBy,
    required ProgramDataModel proposedProgramData,
    required String status,          // pending | approved | rejected
    int? resolvedBy,
    DateTime? resolvedAt,
    required DateTime createdAt,
  }) = _ProposedChangeModel;

  factory ProposedChangeModel.fromJson(Map<String, dynamic> json) =>
      _$ProposedChangeModelFromJson(json);
}
```

### 4.4 API Response Wrappers

```dart
// packages/api/lib/src/models/wod/wod_list_response.dart
@freezed
class WodListResponse with _$WodListResponse {
  const factory WodListResponse({
    WodModel? baseWod,
    @Default([]) List<WodModel> personalWods,
  }) = _WodListResponse;

  factory WodListResponse.fromJson(Map<String, dynamic> json) =>
      _$WodListResponseFromJson(json);
}
```

```dart
// packages/api/lib/src/models/box/box_members_response.dart
@freezed
class BoxMembersResponse with _$BoxMembersResponse {
  const factory BoxMembersResponse({
    @Default([]) List<BoxMemberModel> members,
    @Default(0) int totalCount,
  }) = _BoxMembersResponse;

  factory BoxMembersResponse.fromJson(Map<String, dynamic> json) =>
      _$BoxMembersResponseFromJson(json);
}
```

```dart
// packages/api/lib/src/models/wod/approve_response.dart
@freezed
class ApproveResponse with _$ApproveResponse {
  const factory ApproveResponse({
    required bool approved,
    required int oldBaseWodId,
    required int newBaseWodId,
    required DateTime updatedAt,
  }) = _ApproveResponse;

  factory ApproveResponse.fromJson(Map<String, dynamic> json) =>
      _$ApproveResponseFromJson(json);
}
```

---

## 5. Dio Client Setup

### 5.1 ApiClient

```dart
// packages/api/lib/src/client/api_client.dart
class ApiClient {
  late final Dio dio;

  ApiClient({required String baseUrl, required TokenStorage tokenStorage}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      AuthInterceptor(tokenStorage: tokenStorage),
      RefreshInterceptor(dio: dio, tokenStorage: tokenStorage),
      ErrorInterceptor(),
    ]);
  }
}
```

### 5.2 Auth Interceptor

```dart
// packages/api/lib/src/client/interceptors/auth_interceptor.dart
/// 요청 헤더에 JWT Access Token 자동 첨부
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### 5.3 Refresh Interceptor

```dart
// packages/api/lib/src/client/interceptors/refresh_interceptor.dart
/// 401 응답 시 Refresh Token으로 자동 갱신 후 재시도
class RefreshInterceptor extends QueuedInterceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 1. refreshToken으로 새 accessToken 요청
      // 2. 성공 시 원래 요청 재시도
      // 3. 실패 시 로그인 화면으로 이동
    }
    handler.next(err);
  }
}
```

### 5.4 Error Interceptor

```dart
// packages/api/lib/src/client/interceptors/error_interceptor.dart
/// DioException을 앱 내부 예외로 변환
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(message: '네트워크 연결 시간 초과');
      case DioExceptionType.badResponse:
        _handleBadResponse(err.response!);
      default:
        throw NetworkException(message: '네트워크 오류가 발생했습니다');
    }
  }
}
```

### 5.5 API Services

```dart
// packages/api/lib/src/services/box_api_service.dart
class BoxApiService {
  final Dio _dio;

  /// 박스 생성
  Future<BoxModel> createBox({required String name, String? description});

  /// 박스 가입 (초대 코드)
  Future<BoxMemberModel> joinBox({required String inviteCode});

  /// 박스 상세 조회
  Future<BoxModel> getBox({required int boxId});

  /// 박스 멤버 목록
  Future<BoxMembersResponse> getMembers({required int boxId});
}
```

```dart
// packages/api/lib/src/services/wod_api_service.dart
class WodApiService {
  final Dio _dio;

  /// WOD 등록
  Future<WodModel> registerWod({
    required int boxId,
    required String date,
    required ProgramDataModel programData,
    String? rawText,
  });

  /// 날짜별 WOD 조회
  Future<WodListResponse> getWodsByDate({
    required int boxId,
    required String date,
  });

  /// 변경 제안
  Future<ProposedChangeModel> proposeChange({
    required int wodId,
    required ProgramDataModel proposedProgramData,
  });

  /// 변경 승인
  Future<ApproveResponse> approveChange({
    required int wodId,
    required int proposalId,
  });

  /// WOD 선택 (기록)
  Future<WodSelectionModel> selectWod({
    required int wodId,
    required int boxId,
    required String date,
  });

  /// 선택 조회
  Future<WodSelectionModel?> getSelection({
    required int boxId,
    required String date,
  });
}
```

---

## 6. GetX Controllers

### 6.1 AppStateService (전역 상태)

```dart
// app/services/app_state_service.dart
/// 앱 전역 상태 관리 (현재 사용자, 선택된 박스)
class AppStateService extends GetxService {
  // 상태
  final currentUser = Rxn<UserProfileModel>();
  final currentBox = Rxn<BoxModel>();
  final boxes = <BoxModel>[].obs;

  // 메서드
  Future<void> loadUserBoxes();
  void switchBox(BoxModel box);
  void clearState();  // 로그아웃 시
}
```

> `GetxService`는 앱 생명주기 동안 유지. `Get.put<AppStateService>(AppStateService(), permanent: true)`로 등록.

### 6.2 HomeController

```dart
class HomeController extends GetxController {
  // 의존성
  final WodApiService _wodApi;
  final AppStateService _appState;

  // 반응 상태
  final selectedDate = DateTime.now().obs;
  final isLoading = false.obs;
  final baseWod = Rxn<WodModel>();
  final personalWods = <WodModel>[].obs;
  final selection = Rxn<WodSelectionModel>();

  // Computed
  bool get hasWod => baseWod.value != null;
  bool get hasSelection => selection.value != null;
  BoxModel? get currentBox => _appState.currentBox.value;

  // 메서드
  void onBoxChanged(BoxModel? box);       // 박스 전환 → WOD 새로고침
  void onDateChanged(DateTime date);      // 날짜 변경 → WOD 새로고침
  Future<void> loadWods();                // API 호출
  Future<void> loadSelection();           // 선택 조회
  void goToRegister();                    // WOD 등록 화면
  void goToDetail(int wodId);            // WOD 상세 화면
  void goToSelect();                      // WOD 선택 화면

  // 생명주기
  @override
  void onInit() {
    super.onInit();
    ever(_appState.currentBox, (_) => loadWods());  // 박스 변경 감지
    loadWods();
  }
}
```

### 6.3 WodRegistrationController

```dart
class WodRegistrationController extends GetxController {
  // 의존성
  final WodApiService _wodApi;
  final AppStateService _appState;

  // 반응 상태
  final selectedType = 'AMRAP'.obs;       // WOD 타입
  final timeCap = Rxn<int>();             // 시간 제한
  final rounds = Rxn<int>();              // 라운드 수
  final movements = <MovementModel>[].obs; // 운동 목록
  final rawText = ''.obs;                 // 원본 텍스트
  final isSubmitting = false.obs;

  // 비반응 상태
  final timeCapController = TextEditingController();
  final roundsController = TextEditingController();

  // 메서드
  void addMovement();                     // 빈 운동 추가
  void removeMovement(int index);         // 운동 삭제
  void reorderMovement(int old, int new); // 순서 변경
  void updateMovement(int index, MovementModel m); // 운동 수정
  bool validate();                        // 입력 검증
  Future<void> submit();                  // WOD 등록 API 호출 → 성공 시 Home으로 back

  @override
  void onClose() {
    timeCapController.dispose();
    roundsController.dispose();
    super.onClose();
  }
}
```

### 6.4 WodDetailController

```dart
class WodDetailController extends GetxController {
  // 의존성
  final WodApiService _wodApi;

  // 반응 상태
  final wod = Rxn<WodModel>();            // 선택된 WOD
  final baseWod = Rxn<WodModel>();        // Base WOD (비교용)
  final personalWods = <WodModel>[].obs;  // Personal WODs
  final proposals = <ProposedChangeModel>[].obs;
  final isLoading = false.obs;

  // Arguments
  late final int wodId;

  // 메서드
  Future<void> loadWodDetail();
  void goToPropose();                     // 변경 제안 화면
  void goToSelect();                      // WOD 선택 화면
  void goToApprove(int proposalId);      // 변경 승인 화면

  @override
  void onInit() {
    super.onInit();
    wodId = Get.arguments as int;
    loadWodDetail();
  }
}
```

### 6.5 WodSelectionController

```dart
class WodSelectionController extends GetxController {
  // 의존성
  final WodApiService _wodApi;

  // 반응 상태
  final selectedWodId = Rxn<int>();       // 선택한 WOD ID
  final baseWod = Rxn<WodModel>();
  final personalWods = <WodModel>[].obs;
  final isSubmitting = false.obs;
  final isConfirmed = false.obs;          // 불변성 경고 확인

  // Arguments
  late final String date;
  late final int boxId;

  // 메서드
  void selectWod(int wodId);             // 라디오 선택
  void toggleConfirmation();             // 불변성 경고 체크박스
  Future<void> confirmSelection();       // 선택 확정 API 호출

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    date = args['date'];
    boxId = args['boxId'];
    loadWods();
  }
}
```

### 6.6 ProposeChangeController

```dart
class ProposeChangeController extends GetxController {
  // 의존성
  final WodApiService _wodApi;

  // 반응 상태
  final currentBase = Rxn<WodModel>();    // 현재 Base WOD
  final selectedType = ''.obs;
  final timeCap = Rxn<int>();
  final rounds = Rxn<int>();
  final movements = <MovementModel>[].obs;
  final isSubmitting = false.obs;

  // Arguments
  late final int wodId;

  // 메서드
  void initFromBase();                    // Base WOD 값으로 초기화
  bool validate();
  Future<void> submitProposal();          // 변경 제안 API 호출

  @override
  void onInit() {
    super.onInit();
    wodId = Get.arguments as int;
    loadBaseAndInit();
  }
}
```

### 6.7 ApproveChangeController

```dart
class ApproveChangeController extends GetxController {
  // 의존성
  final WodApiService _wodApi;

  // 반응 상태
  final proposal = Rxn<ProposedChangeModel>();
  final baseWod = Rxn<WodModel>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // Arguments
  late final int proposalId;

  // 메서드
  Future<void> loadProposal();
  Future<void> approve();                 // 승인 → Base 교체
  Future<void> reject();                  // 거부 → 유지
}
```

### 6.8 BoxManagementController

```dart
class BoxManagementController extends GetxController {
  // 의존성
  final BoxApiService _boxApi;
  final AppStateService _appState;

  // 반응 상태
  final isLoading = false.obs;

  // Computed
  List<BoxModel> get boxes => _appState.boxes;

  // 메서드
  Future<void> loadBoxes();
  void goToCreate();
  void goToJoin();
  void selectBox(BoxModel box);           // 박스 선택 후 Home으로
}
```

### 6.9 BoxCreateController

```dart
class BoxCreateController extends GetxController {
  // 반응 상태
  final isSubmitting = false.obs;

  // 비반응 상태
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // 메서드
  bool validate();
  Future<void> createBox();               // API 호출 → 성공 시 back

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
```

### 6.10 BoxJoinController

```dart
class BoxJoinController extends GetxController {
  // 반응 상태
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  // 비반응 상태
  final inviteCodeController = TextEditingController();

  // 메서드
  bool validate();
  Future<void> joinBox();                 // API 호출 → 성공 시 back

  @override
  void onClose() {
    inviteCodeController.dispose();
    super.onClose();
  }
}
```

---

## 7. Bindings

### 패턴

모든 Binding은 `Get.lazyPut`으로 Controller를 등록한다. API 서비스 의존성이 필요한 경우 함께 등록.

```dart
// 예시: HomeBinding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(
      wodApi: Get.find<WodApiService>(),
      appState: Get.find<AppStateService>(),
    ));
  }
}
```

### 전역 서비스 초기화

앱 시작 시 (`main.dart`) 전역 서비스를 등록:

```dart
Future<void> initServices() async {
  // API 클라이언트
  Get.put(ApiClient(
    baseUrl: Environment.apiBaseUrl,
    tokenStorage: Get.find<TokenStorage>(),
  ), permanent: true);

  // API 서비스
  Get.put(BoxApiService(dio: Get.find<ApiClient>().dio), permanent: true);
  Get.put(WodApiService(dio: Get.find<ApiClient>().dio), permanent: true);

  // 앱 전역 상태
  Get.put(AppStateService(), permanent: true);
}
```

---

## 8. State Management Strategy

### 8.1 전역 상태 (AppStateService)

| 상태 | 타입 | 용도 |
|------|------|------|
| `currentUser` | `Rxn<UserProfileModel>` | 로그인된 사용자 |
| `currentBox` | `Rxn<BoxModel>` | 현재 선택된 박스 |
| `boxes` | `RxList<BoxModel>` | 가입한 박스 목록 |

> 로그인 성공 → `AppStateService.loadUserBoxes()` → 첫 번째 박스 자동 선택

### 8.2 화면 로컬 상태

| Controller | 로컬 상태 | 공유 안 함 |
|-----------|---------|-----------|
| HomeController | `selectedDate`, `baseWod`, `personalWods` | 날짜별 WOD 캐시는 화면 내에서만 |
| WodRegistrationController | `movements`, `selectedType` | 등록 폼 상태 |
| WodSelectionController | `selectedWodId`, `isConfirmed` | 선택 확인 상태 |

### 8.3 박스 전환 흐름

```
사용자가 BoxSelector에서 다른 박스 선택
  → AppStateService.switchBox(newBox)
  → HomeController의 ever() 리스너 트리거
  → loadWods() 호출 (새 박스의 오늘 WOD 로드)
  → UI 자동 갱신 (Obx)
```

### 8.4 날짜 변경 흐름

```
사용자가 DateHeader에서 날짜 변경
  → HomeController.onDateChanged(newDate)
  → selectedDate.value = newDate
  → loadWods() 호출
  → UI 자동 갱신
```

### 8.5 WOD 캐시 전략

MVP에서는 캐시 없이 API 호출. 이유:
- WOD가 실시간으로 변경될 수 있음 (변경 승인 등)
- 데이터 양이 많지 않음 (하루 1-3개 WOD)
- Post-MVP에서 `GetStorage` 기반 캐시 고려

---

## 9. Data Flow

### 9.1 Login → Home

```
LoginController.handleXxxLogin()
  → SDK에서 accessToken 획득
  → POST /auth/oauth (서버)
  → TokenStorage에 JWT 저장
  → AppStateService.loadUserBoxes()
  → Get.offAllNamed(Routes.HOME)
```

### 9.2 Box 선택 → WOD 표시

```
HomeView._BoxSelector에서 박스 선택
  → AppStateService.switchBox(box)
  → HomeController.loadWods()
  → GET /wods/:boxId/:date
  → baseWod.value = response.baseWod
  → personalWods.value = response.personalWods
  → Obx로 WodCard 자동 갱신
```

### 9.3 WOD 등록 → Home 갱신

```
WodRegistrationView에서 submit
  → WodRegistrationController.submit()
  → POST /wods (서버)
  → 서버가 isBase 자동 판단
  → Get.back(result: true)
  → HomeController에서 result 감지 → loadWods()
```

### 9.4 변경 제안 → 승인 알림

```
ProposeChangeController.submitProposal()
  → POST /wods/:id/propose
  → 서버가 Base 등록자에게 FCM 발송
  → Base 등록자의 알림 탭 → ApproveChangeView 진입
  → approve() → POST /wods/:id/approve
  → 서버가 Base 교체 + 기존 선택자에게 FCM
```

### 9.5 WOD 선택 → 기록 확정

```
WodSelectionView에서 WOD 선택 + 불변성 확인
  → WodSelectionController.confirmSelection()
  → POST /wods/:id/select
  → 서버가 snapshotData 저장 (불변)
  → Get.back(result: true)
  → HomeController에서 선택 상태 갱신
```

---

## 10. Error Handling

### 10.1 예외 타입 (core 패키지 확장)

기존 `AuthException`, `NetworkException` 외 추가:

```dart
// packages/core/lib/src/exceptions/business_exception.dart
/// 비즈니스 로직 예외 (서버에서 400 응답)
class BusinessException implements Exception {
  final String code;
  final String message;

  const BusinessException({required this.code, required this.message});
}
```

### 10.2 Controller 에러 처리 패턴

```dart
Future<void> loadWods() async {
  try {
    isLoading.value = true;
    final response = await _wodApi.getWodsByDate(
      boxId: currentBox!.id,
      date: _formatDate(selectedDate.value),
    );
    baseWod.value = response.baseWod;
    personalWods.value = response.personalWods;
  } on NetworkException catch (e) {
    Get.snackbar('네트워크 오류', e.message);
  } on AuthException catch (e) {
    if (e.code == 'expired_token') return;  // RefreshInterceptor가 처리
    Get.offAllNamed(Routes.LOGIN);
  } on BusinessException catch (e) {
    Get.snackbar('오류', e.message);
  } catch (e) {
    Get.snackbar('오류', '알 수 없는 오류가 발생했습니다');
  } finally {
    isLoading.value = false;
  }
}
```

### 10.3 View 에러 표시 패턴

```dart
// 로딩 상태
Obx(() => controller.isLoading.value
    ? const Center(child: SketchProgressBar(style: SketchProgressBarStyle.circular))
    : _buildContent())

// 빈 상태
Obx(() => controller.hasWod
    ? _buildWodCard()
    : _buildEmptyState())

// 에러 후 재시도
SketchButton(
  text: '다시 시도',
  onPressed: controller.loadWods,
  style: SketchButtonStyle.outline,
)
```

---

## 11. Implementation Checklist

Phase 4 구현 순서 (plan.md 기반):

### Step 4-1: API 모델 (Freezed)

- [ ] `MovementModel` 생성 + fromJson
- [ ] `ProgramDataModel` 생성 + fromJson
- [ ] `WodModel` 생성 + fromJson
- [ ] `WodListResponse` 생성
- [ ] `WodSelectionModel` 생성
- [ ] `ProposedChangeModel` 생성
- [ ] `ApproveResponse` 생성
- [ ] `BoxModel` 생성 + fromJson
- [ ] `BoxMemberModel` 생성
- [ ] `BoxMembersResponse` 생성
- [ ] `UserProfileModel` 생성
- [ ] `melos generate` 실행 확인

### Step 4-2: Dio 클라이언트 설정

- [ ] `ApiClient` 클래스 구현
- [ ] `AuthInterceptor` 구현
- [ ] `RefreshInterceptor` 구현
- [ ] `ErrorInterceptor` 구현
- [ ] `TokenStorage` 구현 (GetStorage 기반)
- [ ] `BoxApiService` 구현
- [ ] `WodApiService` 구현
- [ ] `AppStateService` 구현

### Step 4-3: 홈 화면

- [ ] `Routes` 상수 추가 (app_routes.dart)
- [ ] `HomeController` 구현
- [ ] `HomeBinding` 구현
- [ ] `HomeView` 구현 (BoxSelector, DateHeader, WodCard, QuickActions)
- [ ] `GetPage` 등록 (app_pages.dart)
- [ ] 로그인 → 홈 네비게이션 연결

### Step 4-4: WOD 등록 화면

- [ ] `WodRegistrationController` 구현
- [ ] `WodRegistrationBinding` 구현
- [ ] `WodRegistrationView` 구현 (TypeSelector, MovementListBuilder, Preview)

### Step 4-5: WOD 상세 화면

- [ ] `WodDetailController` 구현
- [ ] `WodDetailBinding` 구현
- [ ] `WodDetailView` 구현 (Base/Personal 표시, Diff 하이라이트)
- [ ] `ProposeChangeController` + View + Binding
- [ ] `ApproveChangeController` + View + Binding

### Step 4-6: WOD 선택 화면

- [ ] `WodSelectionController` 구현
- [ ] `WodSelectionBinding` 구현
- [ ] `WodSelectionView` 구현 (라디오 선택, 불변성 경고, 확정)

### Box 관리 (홈 화면과 병렬 가능)

- [ ] `BoxManagementController` + View + Binding
- [ ] `BoxCreateController` + View + Binding
- [ ] `BoxJoinController` + View + Binding

---

## 12. Performance Optimization

### const 생성자

- 모든 StatelessWidget에 `const` 생성자 사용
- 고정 텍스트, 아이콘, 간격(SizedBox)은 const

### Obx 스코프 최소화

```dart
// Good: 변경되는 부분만 Obx로 감싸기
Column(
  children: [
    const Text('오늘의 WOD'),                    // const (리빌드 안 함)
    Obx(() => Text(controller.selectedDate.value.toString())), // 날짜만 리빌드
    Obx(() => _buildWodCard(controller.baseWod.value)),        // WOD만 리빌드
  ],
)
```

### GetBuilder 활용

- 리스트 항목처럼 빈번히 변경되지 않는 UI는 `GetBuilder` + `update()` 고려
- Movement 리스트 편집 등 복잡한 폼에서 유용

---

## 13. References

| 문서 | 경로 |
|------|------|
| UI/UX 설계 | `docs/mobile/wowa/mobile-design-spec.md` |
| 서버 API | `docs/server/wowa/server-brief.md` |
| 모바일 가이드 | `apps/mobile/CLAUDE.md` |
| GetX 가이드 | `.claude/guide/mobile/getx_best_practices.md` |
| Flutter 가이드 | `.claude/guide/mobile/flutter_best_practices.md` |
| 디자인 시스템 | `.claude/guide/mobile/design_system.md` |
| 에러 처리 | `.claude/guide/mobile/error_handling.md` |
| 디렉토리 구조 | `.claude/guide/mobile/directory_structure.md` |
