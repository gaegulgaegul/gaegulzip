# 기술 아키텍처 설계: QnA SDK 패키지 추출

## 개요

기존 wowa 앱의 QnA 기능을 재사용 가능한 Flutter SDK 패키지(`packages/qna/`)로 추출합니다. 각 앱은 자신의 `appCode`만 주입하면 독립적인 GitHub 레포지토리에 질문이 자동 등록됩니다.

**핵심 전략**:
1. **패키지 추출**: 기존 코드를 `packages/qna/`로 이동 (models, services, repository, controller, binding, view)
2. **appCode 파라미터화**: 하드코딩된 `'wowa'` 제거, QnaBinding 생성자로 주입
3. **API 패키지 정리**: `packages/api/`에서 QnA 관련 코드 제거
4. **wowa 앱 전환**: SDK 패키지를 import하여 사용

---

## 새 패키지 구조: packages/qna/

### 디렉토리 구조

```
packages/qna/
├── lib/
│   ├── src/
│   │   ├── models/                      # Freezed API 모델
│   │   │   ├── qna_submit_request.dart
│   │   │   ├── qna_submit_request.freezed.dart
│   │   │   ├── qna_submit_request.g.dart
│   │   │   ├── qna_submit_response.dart
│   │   │   ├── qna_submit_response.freezed.dart
│   │   │   └── qna_submit_response.g.dart
│   │   ├── services/                    # API 서비스
│   │   │   └── qna_api_service.dart
│   │   ├── repositories/                # Repository 계층
│   │   │   └── qna_repository.dart
│   │   ├── controllers/                 # GetX Controller
│   │   │   └── qna_controller.dart
│   │   ├── bindings/                    # GetX Binding
│   │   │   └── qna_binding.dart
│   │   └── views/                       # UI 화면
│   │       └── qna_submit_view.dart
│   └── qna.dart                         # 배럴 export
├── pubspec.yaml
└── README.md                            # 통합 가이드
```

---

## 의존성 그래프 (패키지 간)

### 기존 구조
```
core (foundation)
  ↑
  ├── api          (Dio, Freezed models — QnA 모델 포함)
  ├── design_system (UI components, theme)
  └── wowa app     (QnA modules, state management)
```

### 새 구조 (SDK 추출 후)
```
core (foundation — NetworkException 등)
  ↑
  ├── design_system (SketchButton, SketchInput, SketchModal, SketchDesignTokens)
  ├── api          (Auth 모델만 유지, QnA 모델 제거됨)
  ├── qna          (QnA SDK — models, services, repository, controller, binding, view)
  └── wowa app     (qna 패키지 import, appCode 주입)
```

**핵심 변경**:
- `packages/qna/`는 `core`, `design_system`에 의존 (GetX, Dio, Freezed 포함)
- `packages/api/`에서 QnA 관련 코드 제거
- `wowa` 앱은 `qna` 패키지를 import하여 사용

---

## appCode 주입 메커니즘

### 설계 방식: QnaBinding 생성자 파라미터

**선택 이유**:
- GetX 패턴과 일관성 유지
- 라우트 등록 시점에 앱별 설정 주입
- 컴파일 타임에 appCode 누락 감지 가능 (required 파라미터)

### QnaBinding 설계

**파일**: `packages/qna/lib/src/bindings/qna_binding.dart`

```dart
import 'package:get/get.dart';
import '../services/qna_api_service.dart';
import '../repositories/qna_repository.dart';
import '../controllers/qna_controller.dart';

/// QnA 화면 바인딩
///
/// [appCode]를 외부에서 주입받아 Repository에 전달합니다.
class QnaBinding extends Bindings {
  /// 앱 식별 코드 (예: 'wowa', 'other-app')
  final String appCode;

  /// 생성자
  ///
  /// [appCode] 필수 파라미터 — 앱별 GitHub 레포지토리 매핑
  QnaBinding({required this.appCode});

  @override
  void dependencies() {
    // API 서비스 (lazyPut)
    Get.lazyPut<QnaApiService>(() => QnaApiService());

    // Repository (appCode 주입)
    Get.lazyPut<QnaRepository>(
      () => QnaRepository(appCode: appCode),
    );

    // Controller (lazyPut)
    Get.lazyPut<QnaController>(() => QnaController());
  }
}
```

### QnaRepository 수정

**파일**: `packages/qna/lib/src/repositories/qna_repository.dart`

**변경 사항**:
- `appCode: 'wowa'` 하드코딩 제거
- 생성자로 `appCode` 파라미터 받기

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../models/qna_submit_request.dart';
import '../models/qna_submit_response.dart';
import '../services/qna_api_service.dart';

/// QnA Repository
///
/// API 서비스를 통합하여 질문 제출을 처리합니다.
class QnaRepository {
  /// 앱 코드 (생성자로 주입)
  final String appCode;

  final QnaApiService _apiService = Get.find<QnaApiService>();

  /// 생성자
  ///
  /// [appCode] 앱 식별 코드 (예: 'wowa', 'other-app')
  QnaRepository({required this.appCode});

  /// 질문 제출 처리
  ///
  /// [title] 질문 제목 (최대 256자)
  /// [body] 질문 본문 (최대 65536자)
  ///
  /// Returns: [QnaSubmitResponse] 제출된 질문 정보
  ///
  /// Throws:
  ///   - [NetworkException] 네트워크 오류
  ///   - [Exception] 기타 서버 오류
  Future<QnaSubmitResponse> submitQuestion({
    required String title,
    required String body,
  }) async {
    try {
      // 1. 요청 생성 (appCode 동적 주입)
      final request = QnaSubmitRequest(
        appCode: appCode, // 생성자로 받은 appCode 사용
        title: title,
        body: body,
      );

      // 2. API 호출
      return await _apiService.submitQuestion(request);
    } on DioException catch (e) {
      // DioException을 도메인 예외로 변환
      throw _mapDioError(e);
    }
  }

  /// DioException을 도메인 예외로 변환
  Exception _mapDioError(DioException e) {
    // (기존 로직 유지)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
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

    return NetworkException(
      message: '알 수 없는 오류가 발생했습니다',
    );
  }
}
```

---

## 마이그레이션 플랜 (Tidy First)

### Phase 1: 구조적 변경 (파일 이동)

#### 1.1 새 패키지 생성

**Action**:
```bash
mkdir -p apps/mobile/packages/qna/lib/src/{models,services,repositories,controllers,bindings,views}
```

**파일 생성**:
- `apps/mobile/packages/qna/pubspec.yaml` (아래 참조)
- `apps/mobile/packages/qna/lib/qna.dart` (배럴 export)
- `apps/mobile/packages/qna/README.md`

#### 1.2 파일 이동 (packages/api → packages/qna)

**이동할 파일**:
```bash
# Models
mv apps/mobile/packages/api/lib/src/models/qna/qna_submit_request.dart \
   apps/mobile/packages/qna/lib/src/models/

mv apps/mobile/packages/api/lib/src/models/qna/qna_submit_response.dart \
   apps/mobile/packages/qna/lib/src/models/

# API Service
mv apps/mobile/packages/api/lib/src/services/qna_api_service.dart \
   apps/mobile/packages/qna/lib/src/services/
```

**중요**: `.freezed.dart`, `.g.dart` 파일은 이동 후 재생성됨

#### 1.3 파일 이동 (apps/wowa → packages/qna)

**이동할 파일**:
```bash
# Repository
mv apps/mobile/apps/wowa/lib/app/data/repositories/qna_repository.dart \
   apps/mobile/packages/qna/lib/src/repositories/

# Controller
mv apps/mobile/apps/wowa/lib/app/modules/qna/controllers/qna_controller.dart \
   apps/mobile/packages/qna/lib/src/controllers/

# Binding
mv apps/mobile/apps/wowa/lib/app/modules/qna/bindings/qna_binding.dart \
   apps/mobile/packages/qna/lib/src/bindings/

# View
mv apps/mobile/apps/wowa/lib/app/modules/qna/views/qna_submit_view.dart \
   apps/mobile/packages/qna/lib/src/views/
```

#### 1.4 Import 경로 수정 (qna 패키지 내부)

**수정 대상 파일**: 모든 이동된 파일

**변경 예시** (`qna_repository.dart`):
```dart
// Before (wowa 앱 내부 import)
import 'package:api/api.dart';
import 'package:core/core.dart';

// After (qna 패키지 내부 import)
import 'package:core/core.dart';
import '../models/qna_submit_request.dart';
import '../models/qna_submit_response.dart';
import '../services/qna_api_service.dart';
```

**변경 예시** (`qna_controller.dart`):
```dart
// Before
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../../../data/repositories/qna_repository.dart';

// After
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../repositories/qna_repository.dart';
```

**변경 예시** (`qna_binding.dart`):
```dart
// Before
import 'package:get/get.dart';
import 'package:api/api.dart';
import '../controllers/qna_controller.dart';
import '../../../data/repositories/qna_repository.dart';

// After
import 'package:get/get.dart';
import '../services/qna_api_service.dart';
import '../repositories/qna_repository.dart';
import '../controllers/qna_controller.dart';
```

**변경 예시** (`qna_submit_view.dart`):
```dart
// Before
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/qna_controller.dart';

// After (동일 — 패키지 import는 유지, 상대 경로만 수정)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/qna_controller.dart';
```

#### 1.5 코드 생성 실행

**Action**:
```bash
cd /Users/lms/dev/repository/feature-qna/apps/mobile
melos bootstrap
melos generate
```

**검증**:
- `packages/qna/lib/src/models/qna_submit_request.freezed.dart` 생성 확인
- `packages/qna/lib/src/models/qna_submit_request.g.dart` 생성 확인
- `packages/qna/lib/src/models/qna_submit_response.freezed.dart` 생성 확인
- `packages/qna/lib/src/models/qna_submit_response.g.dart` 생성 확인

### Phase 2: 동작 변경 (appCode 파라미터화)

#### 2.1 QnaBinding 수정

**파일**: `packages/qna/lib/src/bindings/qna_binding.dart`

**변경 사항**:
- 생성자에 `required String appCode` 파라미터 추가
- `QnaRepository(appCode: appCode)` 주입

**코드**:
```dart
import 'package:get/get.dart';
import '../services/qna_api_service.dart';
import '../repositories/qna_repository.dart';
import '../controllers/qna_controller.dart';

class QnaBinding extends Bindings {
  final String appCode;

  QnaBinding({required this.appCode});

  @override
  void dependencies() {
    Get.lazyPut<QnaApiService>(() => QnaApiService());
    Get.lazyPut<QnaRepository>(() => QnaRepository(appCode: appCode));
    Get.lazyPut<QnaController>(() => QnaController());
  }
}
```

#### 2.2 QnaRepository 수정

**파일**: `packages/qna/lib/src/repositories/qna_repository.dart`

**변경 사항**:
- `final String appCode;` 필드 추가
- 생성자 `QnaRepository({required this.appCode})`
- `appCode: 'wowa'` → `appCode: appCode`

**코드**: (위 "QnaRepository 수정" 섹션 참조)

#### 2.3 QnaController 수정 (필요 시)

**파일**: `packages/qna/lib/src/controllers/qna_controller.dart`

**변경 사항**: 없음 (Repository를 `Get.find<QnaRepository>()`로 주입받으므로)

**검증**: Controller는 Repository의 appCode를 직접 알 필요 없음

### Phase 3: packages/api 정리

#### 3.1 QnA 관련 코드 삭제

**삭제할 파일**:
```bash
rm -rf apps/mobile/packages/api/lib/src/models/qna/
rm apps/mobile/packages/api/lib/src/services/qna_api_service.dart
```

#### 3.2 배럴 export 수정

**파일**: `packages/api/lib/api.dart`

**변경 사항**:
```dart
// Before
library api;

// Auth Models
export 'src/models/auth/login_request.dart';
export 'src/models/auth/login_response.dart';
export 'src/models/auth/user_model.dart';
export 'src/models/auth/refresh_request.dart';
export 'src/models/auth/refresh_response.dart';

// QnA Models (제거)
export 'src/models/qna/qna_submit_request.dart';
export 'src/models/qna/qna_submit_response.dart';

// Services
export 'src/services/auth_api_service.dart';
export 'src/services/qna_api_service.dart'; // 제거
```

**After**:
```dart
library api;

// Auth Models
export 'src/models/auth/login_request.dart';
export 'src/models/auth/login_response.dart';
export 'src/models/auth/user_model.dart';
export 'src/models/auth/refresh_request.dart';
export 'src/models/auth/refresh_response.dart';

// Services
export 'src/services/auth_api_service.dart';
```

### Phase 4: wowa 앱 전환

#### 4.1 기존 QnA 모듈 삭제

**삭제할 디렉토리**:
```bash
rm -rf apps/mobile/apps/wowa/lib/app/modules/qna/
rm apps/mobile/apps/wowa/lib/app/data/repositories/qna_repository.dart
```

#### 4.2 pubspec.yaml 의존성 추가

**파일**: `apps/mobile/apps/wowa/pubspec.yaml`

**변경 사항**:
```yaml
dependencies:
  # ... 기존 의존성 ...

  # Internal packages
  core:
    path: ../../packages/core
  api:
    path: ../../packages/api
  design_system:
    path: ../../packages/design_system
  qna:  # 추가
    path: ../../packages/qna
```

#### 4.3 라우트 등록 수정

**파일**: `apps/mobile/apps/wowa/lib/app/routes/app_pages.dart`

**변경 사항**:
```dart
// Before
import 'package:get/get.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/qna/views/qna_submit_view.dart';
import '../modules/qna/bindings/qna_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.QNA,
      page: () => const QnaSubmitView(),
      binding: QnaBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

**After**:
```dart
import 'package:get/get.dart';
import 'package:qna/qna.dart'; // SDK 패키지 import
import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.QNA,
      page: () => const QnaSubmitView(),
      binding: QnaBinding(appCode: 'wowa'), // appCode 주입
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

**파일**: `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart`

**변경 사항**: 없음 (기존 `Routes.QNA` 유지)

#### 4.4 melos bootstrap 실행

**Action**:
```bash
cd /Users/lms/dev/repository/feature-qna/apps/mobile
melos clean && melos bootstrap
```

---

## pubspec.yaml (packages/qna/)

**파일**: `apps/mobile/packages/qna/pubspec.yaml`

```yaml
name: qna
description: "QnA SDK package for multi-tenant apps"
version: 0.0.1
publish_to: 'none'

environment:
  sdk: ">=3.10.7 <4.0.0"
  flutter: ">=3.24.0"

dependencies:
  flutter:
    sdk: flutter

  # HTTP client
  dio: ^5.4.0

  # JSON serialization
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1

  # State management
  get: ^4.6.6

  # Internal dependencies
  core:
    path: ../core
  design_system:
    path: ../design_system

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

  # Code generation tools
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  freezed: ^2.4.7

flutter:
```

**의존성 설명**:
- `dio`: API 호출 (QnaApiService)
- `freezed_annotation`, `json_annotation`: API 모델 (Freezed)
- `get`: 상태 관리, DI (GetxController, Bindings)
- `core`: NetworkException, Logger 등
- `design_system`: SketchButton, SketchInput, SketchModal, SketchDesignTokens

---

## 배럴 Export (qna.dart)

**파일**: `apps/mobile/packages/qna/lib/qna.dart`

```dart
library qna;

// Models
export 'src/models/qna_submit_request.dart';
export 'src/models/qna_submit_response.dart';

// Services
export 'src/services/qna_api_service.dart';

// Repositories
export 'src/repositories/qna_repository.dart';

// Controllers
export 'src/controllers/qna_controller.dart';

// Bindings
export 'src/bindings/qna_binding.dart';

// Views
export 'src/views/qna_submit_view.dart';
```

**사용 예시** (wowa 앱):
```dart
import 'package:qna/qna.dart';

// QnaSubmitView, QnaBinding 모두 접근 가능
```

---

## Melos 통합

### melos.yaml 변경

**파일**: `apps/mobile/melos.yaml`

**변경 사항**: 없음

**이유**:
- `packages: - packages/**` 패턴이 이미 `packages/qna/` 포함
- `melos bootstrap`, `melos generate` 자동으로 qna 패키지 인식

**검증**:
```bash
cd /Users/lms/dev/repository/feature-qna/apps/mobile
melos list
# 출력: core, api, design_system, qna, wowa
```

---

## Breaking Change 분석

### wowa 앱에서 발생하는 변경 사항

#### 1. Import 경로 변경

**파일**: `app_pages.dart`

**Before**:
```dart
import '../modules/qna/views/qna_submit_view.dart';
import '../modules/qna/bindings/qna_binding.dart';
```

**After**:
```dart
import 'package:qna/qna.dart';
```

**영향**: wowa 앱의 `app_pages.dart` 1개 파일 수정 필요

#### 2. QnaBinding 생성자 파라미터 추가

**Before**:
```dart
binding: QnaBinding(),
```

**After**:
```dart
binding: QnaBinding(appCode: 'wowa'),
```

**영향**: wowa 앱의 `app_pages.dart` 1개 파일 수정 필요

#### 3. 컴파일 오류

**발생 시점**: `melos bootstrap` 후

**예상 오류**:
```
Error: The getter 'QnaSubmitView' isn't defined for the class 'AppPages'.
Error: The getter 'QnaBinding' isn't defined for the class 'AppPages'.
```

**해결 방법**: Phase 4 완료 후 자동 해결

#### 4. 기능 회귀

**테스트 항목**:
- [ ] wowa 앱에서 Routes.QNA로 이동 가능
- [ ] QnaSubmitView가 정상적으로 렌더링됨
- [ ] 질문 제목 입력 가능
- [ ] 질문 본문 입력 가능
- [ ] 제출 버튼 클릭 시 API 호출
- [ ] 성공 모달 표시 후 화면 닫기
- [ ] 실패 모달 표시 후 재시도 가능
- [ ] appCode가 'wowa'로 서버에 전달됨

**검증 방법**:
1. wowa 앱 실행 후 QnA 화면 접근
2. 질문 제출 후 서버 로그에서 `appCode: 'wowa'` 확인
3. GitHub Issues에 질문 등록 확인

---

## 다른 앱에서의 통합 예시

### other-app 통합 시나리오

**파일**: `apps/mobile/apps/other-app/pubspec.yaml`

```yaml
dependencies:
  qna:
    path: ../../packages/qna
  core:
    path: ../../packages/core
  design_system:
    path: ../../packages/design_system
```

**파일**: `apps/mobile/apps/other-app/lib/app/routes/app_pages.dart`

```dart
import 'package:get/get.dart';
import 'package:qna/qna.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.QNA,
      page: () => const QnaSubmitView(),
      binding: QnaBinding(appCode: 'other-app'), // 'other-app' appCode 주입
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
```

**Navigation**:
```dart
Get.toNamed(Routes.QNA); // SDK 화면으로 이동
```

**결과**:
- other-app 사용자의 질문이 `other-app` GitHub 레포지토리에 등록됨
- wowa와 동일한 UI, 동일한 UX 제공

---

## 검증 기준

### SDK 패키지 빌드

- [ ] `melos bootstrap` 성공
- [ ] `melos generate` 성공 (Freezed 코드 생성)
- [ ] `packages/qna/` 패키지 단독 빌드 가능

### 파일 이동 완료

- [ ] `packages/api/`에 QnA 관련 파일 없음
- [ ] `apps/wowa/lib/app/modules/qna/` 디렉토리 삭제됨
- [ ] `apps/wowa/lib/app/data/repositories/qna_repository.dart` 삭제됨
- [ ] `packages/qna/lib/src/` 하위에 모든 파일 존재

### appCode 파라미터화

- [ ] `QnaRepository`에 `final String appCode;` 필드 존재
- [ ] `QnaBinding`에 `required String appCode` 생성자 파라미터 존재
- [ ] `QnaRepository`의 `submitQuestion()` 메서드에서 `appCode` 사용

### wowa 앱 전환

- [ ] `apps/wowa/pubspec.yaml`에 `qna` 패키지 의존성 추가
- [ ] `app_pages.dart`에서 `package:qna/qna.dart` import
- [ ] `QnaBinding(appCode: 'wowa')` 주입
- [ ] 기존 기능 동일하게 작동 (회귀 테스트)

### API 패키지 정리

- [ ] `packages/api/lib/api.dart`에 QnA export 제거
- [ ] `packages/api/lib/src/models/qna/` 디렉토리 삭제
- [ ] `packages/api/lib/src/services/qna_api_service.dart` 삭제

### 의존성 순환 없음

- [ ] `packages/qna/`는 `core`, `design_system`만 의존
- [ ] `packages/api/`는 QnA에 의존하지 않음
- [ ] `wowa` 앱은 `qna` 패키지 import

---

## 에러 처리 전략

### appCode 누락 시

**시나리오**: 개발자가 `QnaBinding()`으로 생성 (appCode 누락)

**컴파일 오류**:
```
Error: Required named parameter 'appCode' must be provided.
```

**해결 방법**: 컴파일 타임에 감지되므로 런타임 에러 없음

### appCode 잘못 전달 시

**시나리오**: `QnaBinding(appCode: 'invalid-app')`

**서버 응답**: `404 Not Found`

**UI 피드백**: QnaRepository의 `_mapDioError()` 처리
```dart
if (statusCode == 404) {
  return NetworkException(
    message: '서비스 설정 오류가 발생했습니다',
    statusCode: statusCode,
  );
}
```

**결과**: 사용자에게 "서비스 설정 오류가 발생했습니다" 모달 표시

### 의존성 버전 충돌

**시나리오**: wowa 앱의 `get` 버전과 qna 패키지의 `get` 버전 불일치

**해결 방법**:
- Melos workspace는 루트 `pubspec.yaml`에서 버전 통일
- `melos bootstrap` 자동으로 의존성 해결

**검증**:
```bash
melos list --long
# 모든 패키지의 get 버전 확인
```

---

## 성능 최적화 전략

### const 생성자 (기존 유지)

QnaSubmitView의 위젯은 이미 const 최적화되어 있음:
```dart
const QnaSubmitView({Key? key}) : super(key: key);
const SizedBox(height: 8),
const Text('안내 문구...'),
```

**유지 사항**: 파일 이동 시 const 제거하지 말 것

### Obx 범위 최소화 (기존 유지)

```dart
Obx(() => SketchInput(
  errorText: controller.titleError.value.isEmpty
      ? null
      : controller.titleError.value,
))
```

**유지 사항**: Obx는 필요한 위젯만 감싸고 있음, 변경 불필요

### Get.lazyPut (기존 유지)

QnaBinding에서 이미 lazyPut 사용:
```dart
Get.lazyPut<QnaApiService>(() => QnaApiService());
Get.lazyPut<QnaRepository>(() => QnaRepository(appCode: appCode));
Get.lazyPut<QnaController>(() => QnaController());
```

**유지 사항**: 화면 접근 시에만 의존성 생성

---

## README.md (packages/qna/)

**파일**: `apps/mobile/packages/qna/README.md`

```markdown
# QnA SDK Package

멀티테넌트 Flutter 앱을 위한 재사용 가능한 QnA 기능 SDK입니다.

## 특징

- ✅ UI 포함 (질문 작성 화면)
- ✅ GetX 상태 관리
- ✅ Freezed API 모델
- ✅ appCode 파라미터화 (앱별 GitHub 레포지토리 매핑)
- ✅ 에러 처리 완비

## 통합 가이드

### 1. 의존성 추가

```yaml
dependencies:
  qna:
    path: ../../packages/qna
  core:
    path: ../../packages/core
  design_system:
    path: ../../packages/design_system
```

### 2. melos bootstrap

```bash
cd apps/mobile
melos bootstrap
```

### 3. 라우트 등록

```dart
import 'package:get/get.dart';
import 'package:qna/qna.dart';

GetPage(
  name: '/qna',
  page: () => const QnaSubmitView(),
  binding: QnaBinding(appCode: 'your-app'), // 필수: appCode 주입
  transition: Transition.cupertino,
)
```

### 4. 화면 이동

```dart
Get.toNamed('/qna');
```

## appCode 파라미터

`appCode`는 **필수** 파라미터입니다. 각 앱의 질문이 독립적인 GitHub 레포지토리에 등록되도록 보장합니다.

**예시**:
- wowa 앱: `QnaBinding(appCode: 'wowa')`
- other-app: `QnaBinding(appCode: 'other-app')`

**누락 시**: 컴파일 오류 발생

## 의존성 그래프

```
core (NetworkException, Logger)
  ↑
design_system (SketchButton, SketchInput, SketchModal)
  ↑
qna (SDK)
  ↑
your-app
```

## 라이선스

Private — gaegulzip 내부 사용
```

---

## 참고 자료

- User Story: `docs/core/qna-sdk/user-story.md`
- 기존 QnA 설계: `docs/core/qna/mobile-brief.md`
- GetX Best Practices: `.claude/guide/mobile/getx_best_practices.md`
- Directory Structure: `.claude/guide/mobile/directory_structure.md`
- Common Patterns: `.claude/guide/mobile/common_patterns.md`
