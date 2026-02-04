# 모바일 기술 설계: QnA (질문과 답변)

## 개요

QnA 질문 작성 기능의 Flutter 모바일 기술 아키텍처입니다.
기존 Login 모듈 패턴(GetX + Repository + Freezed)을 따르며, Design System의 Sketch 컴포넌트를 활용합니다.

**디자인 명세**: [`mobile-design-spec.md`](./mobile-design-spec.md)

---

## 1. 디렉토리 구조

### App 모듈

```
apps/wowa/lib/app/modules/qna/
├── controllers/
│   └── qna_controller.dart       # GetxController (입력 검증, 제출 로직)
├── views/
│   └── qna_submit_view.dart      # GetView<QnaController> (질문 작성 화면)
├── bindings/
│   └── qna_binding.dart          # Bindings (DI 등록)
```

### API 패키지 (packages/api)

```
packages/api/lib/src/models/qna/
├── qna_submit_request.dart       # @freezed QnaSubmitRequest
├── qna_submit_request.freezed.dart
├── qna_submit_request.g.dart
├── qna_submit_response.dart      # @freezed QnaSubmitResponse
├── qna_submit_response.freezed.dart
└── qna_submit_response.g.dart

packages/api/lib/src/services/
└── qna_api_service.dart          # Dio 기반 API 호출
```

### Data 레이어

```
apps/wowa/lib/app/data/repositories/
└── qna_repository.dart           # API 호출 + 에러 변환
```

---

## 2. API 모델 설계 (Freezed)

### QnaSubmitRequest

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'qna_submit_request.freezed.dart';
part 'qna_submit_request.g.dart';

@freezed
class QnaSubmitRequest with _$QnaSubmitRequest {
  const factory QnaSubmitRequest({
    required String appCode,
    required String title,
    required String body,
  }) = _QnaSubmitRequest;

  factory QnaSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$QnaSubmitRequestFromJson(json);
}
```

### QnaSubmitResponse

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'qna_submit_response.freezed.dart';
part 'qna_submit_response.g.dart';

@freezed
class QnaSubmitResponse with _$QnaSubmitResponse {
  const factory QnaSubmitResponse({
    required int questionId,
    required int issueNumber,
    required String issueUrl,
    required String createdAt,
  }) = _QnaSubmitResponse;

  factory QnaSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$QnaSubmitResponseFromJson(json);
}
```

### QnaApiService

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class QnaApiService {
  final Dio _dio = Get.find<Dio>();

  Future<QnaSubmitResponse> submitQuestion(QnaSubmitRequest request) async {
    final response = await _dio.post(
      '/api/qna/questions',
      data: request.toJson(),
    );
    return QnaSubmitResponse.fromJson(response.data);
  }
}
```

**barrel export**: `packages/api/lib/api.dart`에 모델 및 서비스 export 추가

---

## 3. Repository 설계

### QnaRepository

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:api/api.dart';

class QnaRepository {
  final QnaApiService _apiService = Get.find<QnaApiService>();

  Future<QnaSubmitResponse> submitQuestion({
    required String title,
    required String body,
  }) async {
    try {
      final request = QnaSubmitRequest(
        appCode: 'wowa', // 앱별 코드 (향후 설정에서 로드)
        title: title,
        body: body,
      );
      return await _apiService.submitQuestion(request);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(message: '네트워크 연결을 확인해주세요');
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 400) {
      return NetworkException(
        message: '제목과 내용을 확인해주세요',
        statusCode: statusCode,
      );
    }
    if (statusCode == 404) {
      return NetworkException(
        message: '서비스 설정 오류가 발생했습니다',
        statusCode: statusCode,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return NetworkException(
        message: '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요',
        statusCode: statusCode,
      );
    }
    return NetworkException(message: '알 수 없는 오류가 발생했습니다');
  }
}
```

**에러 변환 패턴**: Login 모듈의 `AuthRepository._mapDioError` 패턴과 동일

---

## 4. GetX 상태 관리 설계

### QnaController

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';

class QnaController extends GetxController {
  final QnaRepository _repository = Get.find<QnaRepository>();

  // TextEditingController
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  // 반응형 상태 (.obs)
  final isSubmitting = false.obs;
  final titleError = ''.obs;
  final bodyError = ''.obs;
  final bodyLength = 0.obs;
  final errorMessage = ''.obs;

  // 제출 버튼 활성화 조건
  bool get isSubmitEnabled =>
      titleController.text.isNotEmpty &&
      bodyController.text.isNotEmpty &&
      titleController.text.length <= 256 &&
      bodyController.text.length <= 65536 &&
      !isSubmitting.value;

  @override
  void onInit() {
    super.onInit();
    // 본문 글자 수 실시간 추적
    bodyController.addListener(() {
      bodyLength.value = bodyController.text.length;
      if (bodyError.value.isNotEmpty) validateBody();
    });
    titleController.addListener(() {
      if (titleError.value.isNotEmpty) validateTitle();
    });
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  // 입력 검증
  void validateTitle() {
    if (titleController.text.isEmpty) {
      titleError.value = '제목을 입력해주세요';
    } else if (titleController.text.length > 256) {
      titleError.value = '제목은 256자 이내로 입력해주세요';
    } else {
      titleError.value = '';
    }
  }

  void validateBody() {
    if (bodyController.text.isEmpty) {
      bodyError.value = '질문 내용을 입력해주세요';
    } else if (bodyController.text.length > 65536) {
      bodyError.value = '본문은 65536자 이내로 입력해주세요';
    } else {
      bodyError.value = '';
    }
  }

  // 질문 제출
  Future<void> submitQuestion() async {
    validateTitle();
    validateBody();
    if (titleError.value.isNotEmpty || bodyError.value.isNotEmpty) return;

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      await _repository.submitQuestion(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
      );

      // 성공 모달 표시
      _showSuccessModal();
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      _showErrorModal();
    } catch (e) {
      errorMessage.value = '알 수 없는 오류가 발생했습니다';
      _showErrorModal();
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccessModal() {
    // SketchModal.show() 사용 → "확인" 탭 시 Get.back() x2
  }

  void _showErrorModal() {
    // SketchModal.show() 사용 → "닫기" / "재시도" 버튼
  }
}
```

### 반응형 상태 요약

| 변수 | 타입 | 초기값 | Obx 위젯 |
|------|------|--------|---------|
| `isSubmitting` | `RxBool` | `false` | 제출 버튼 (isLoading) |
| `titleError` | `RxString` | `''` | 제목 SketchInput (errorText) |
| `bodyError` | `RxString` | `''` | 본문 SketchInput (errorText) |
| `bodyLength` | `RxInt` | `0` | 글자 수 카운터 |
| `errorMessage` | `RxString` | `''` | 실패 모달 에러 메시지 |

---

## 5. Binding 설계

### QnaBinding

```dart
import 'package:get/get.dart';
import 'package:api/api.dart';

class QnaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QnaApiService>(() => QnaApiService());
    Get.lazyPut<QnaRepository>(() => QnaRepository());
    Get.lazyPut<QnaController>(() => QnaController());
  }
}
```

**패턴**: Login 모듈과 동일 — ApiService → Repository → Controller 순서로 등록

---

## 6. View 설계

### QnaSubmitView

```dart
class QnaSubmitView extends GetView<QnaController> {
  const QnaSubmitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('질문하기'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('궁금한 점을 남겨주세요. 빠르게 답변드리겠습니다.'),
              const SizedBox(height: 24),

              // 제목 입력
              Obx(() => SketchInput(
                label: '제목 *',
                hint: '질문 제목을 입력하세요 (최대 256자)',
                controller: controller.titleController,
                maxLength: 256,
                errorText: controller.titleError.value.isEmpty
                    ? null
                    : controller.titleError.value,
                prefixIcon: Icons.edit,
              )),
              const SizedBox(height: 24),

              // 본문 입력
              Obx(() => SketchInput(
                label: '질문 내용 *',
                hint: '구체적으로 작성할수록 빠른 답변을 받을 수 있습니다',
                controller: controller.bodyController,
                maxLength: 65536,
                minLines: 8,
                maxLines: 20,
                errorText: controller.bodyError.value.isEmpty
                    ? null
                    : controller.bodyError.value,
                prefixIcon: Icons.description,
              )),
              const SizedBox(height: 12),

              // 글자 수 카운터
              Obx(() => _buildCharCounter()),
              const SizedBox(height: 32),

              // 제출 버튼
              Obx(() => SketchButton(
                text: '질문 제출',
                icon: Icons.send,
                size: SketchButtonSize.large,
                style: SketchButtonStyle.primary,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.isSubmitEnabled
                    ? controller.submitQuestion
                    : null,
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Design System 컴포넌트 사용**:
- `SketchButton` — 제출 버튼 (isLoading 지원)
- `SketchInput` — 제목/본문 입력 (errorText 지원)
- `SketchModal` — 성공/실패 모달

---

## 7. 라우팅 설계

### app_routes.dart

```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const SETTINGS = '/settings';
  static const QNA = '/qna';          // 추가
}
```

### app_pages.dart

```dart
GetPage(
  name: Routes.QNA,
  page: () => const QnaSubmitView(),
  binding: QnaBinding(),
  transition: Transition.cupertino,  // iOS 슬라이드
  transitionDuration: const Duration(milliseconds: 300),
),
```

### 네비게이션

```dart
// 질문하기 화면으로 이동
Get.toNamed(Routes.QNA);

// 성공 모달 확인 후 이전 화면으로 돌아감
Get.back(); // 모달 닫기
Get.back(); // 화면 닫기
```

---

## 8. 에러 처리 전략

### 에러 유형별 처리

| 에러 유형 | Exception | 사용자 메시지 | UI 동작 |
|----------|-----------|-------------|---------|
| 네트워크 끊김 | `NetworkException` | 네트워크 연결을 확인해주세요 | 실패 모달 + 재시도 |
| 타임아웃 | `NetworkException` | 네트워크 연결을 확인해주세요 | 실패 모달 + 재시도 |
| 입력 검증 (400) | `NetworkException` | 제목과 내용을 확인해주세요 | 실패 모달 + 닫기 |
| 설정 없음 (404) | `NetworkException` | 서비스 설정 오류가 발생했습니다 | 실패 모달 + 닫기 |
| 서버 오류 (5xx) | `NetworkException` | 일시적인 오류가 발생했습니다 | 실패 모달 + 재시도 |
| 기타 | `Exception` | 알 수 없는 오류가 발생했습니다 | 실패 모달 + 닫기 |

### Controller 에러 처리 패턴

```dart
try {
  // API 호출
} on NetworkException catch (e) {
  errorMessage.value = e.message;
  _showErrorModal();
} catch (e) {
  errorMessage.value = '알 수 없는 오류가 발생했습니다';
  _showErrorModal();
}
```

**기존 패턴 참고**: `LoginController._handleSocialLogin`의 에러 처리 구조와 동일

---

## 9. 인증 처리 (선택적)

QnA는 **인증 없이도 사용 가능** (익명 질문 지원).

로그인 사용자의 경우, Dio interceptor에서 자동으로 `Authorization` 헤더를 추가합니다.
서버의 `optionalAuthenticate` 미들웨어가 토큰 있으면 검증하고, 없으면 통과시킵니다.

```dart
// Dio interceptor (이미 설정되어 있다면)
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await Get.find<SecureStorageService>().getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
));
```

---

## 10. 성능 최적화

- **const 생성자**: 정적 위젯 (`SizedBox`, 안내 문구 `Text`)에 적용
- **Obx 범위 최소화**: 변경되는 위젯만 Obx로 감쌈 (전체 Column X)
- **GetView 패턴**: StatelessWidget 기반, controller 자동 연결
- **TextEditingController 리스너**: `onInit`에서 등록, `onClose`에서 dispose

---

## 11. 코드 생성

```bash
# Freezed 모델 코드 생성
melos generate

# 또는 watch 모드
melos generate:watch
```

---

## 12. 작업 분배 (CTO 참조)

**Senior Developer**:
- QnaRepository (에러 처리 매핑)
- QnaController (상태 관리, 제출 로직, 모달 표시)
- Dio interceptor 인증 연동

**Junior Developer**:
- Freezed 모델 (QnaSubmitRequest, QnaSubmitResponse)
- QnaApiService
- QnaBinding
- QnaSubmitView (design-spec 기반 위젯 트리)
- 라우팅 등록 (app_routes, app_pages)

### 작업 의존성

1. Freezed 모델 작성 (Junior) → `melos generate`
2. QnaApiService 작성 (Junior) → QnaRepository 작성 (Senior)
3. QnaRepository 완성 (Senior) → QnaController 작성 (Senior)
4. design-spec 확인 → QnaSubmitView 작성 (Junior)
5. QnaBinding 등록 + 라우팅 추가 (Junior)
6. Controller + View 통합 테스트

---

## 13. 참고 자료

- 디자인 명세: [`mobile-design-spec.md`](./mobile-design-spec.md)
- 사용자 스토리: [`user-story.md`](./user-story.md)
- Login 모듈 패턴: `apps/mobile/apps/wowa/lib/app/modules/login/`
- AuthRepository 패턴: `apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart`
- Design System: `apps/mobile/packages/design_system/`
