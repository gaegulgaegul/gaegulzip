# 작업 분배 계획: QnA SDK 패키지 추출 (Mobile)

## 개요

기존 wowa 앱의 QnA 기능을 재사용 가능한 Flutter SDK 패키지(`packages/qna/`)로 추출하는 리팩토링 작업입니다.

**작업 유형**: 코드 추출 및 리팩토링 (Tidy First 방법론 적용)

**담당 에이전트**: Flutter Developer 1명 (순차 작업)

**소요 시간 예상**: 2~3시간

**병렬 실행 불가**: 파일 이동과 import 경로 수정이 상호 의존적이므로 단일 개발자가 순차적으로 진행해야 합니다.

---

## 실행 그룹

### Group 1 (순차) — 전체 리팩토링

| Agent | 작업 범위 | 설명 |
|-------|----------|------|
| flutter-developer | Phase 1~4 전체 | 새 패키지 생성, 파일 이동, appCode 파라미터화, API 패키지 정리, wowa 앱 전환 |

**순차 실행 이유**:
- Phase 1 완료 후 Phase 2 실행 가능 (구조적 변경 → 동작 변경)
- Phase 3는 Phase 1~2 완료 후 안전하게 정리
- Phase 4는 모든 SDK 패키지 완성 후 통합

---

## Phase 1: 구조적 변경 (파일 이동)

### 목표
기존 코드를 새 SDK 패키지(`packages/qna/`)로 이동하고, import 경로를 수정하여 컴파일 가능한 상태로 만듭니다.

### 작업 항목

#### 1.1 새 패키지 생성

**생성할 디렉토리**:
```
apps/mobile/packages/qna/
├── lib/
│   └── src/
│       ├── models/
│       ├── services/
│       ├── repositories/
│       ├── controllers/
│       ├── bindings/
│       └── views/
```

**생성할 파일**:
- `apps/mobile/packages/qna/pubspec.yaml` (mobile-brief.md의 pubspec.yaml 참조)
- `apps/mobile/packages/qna/lib/qna.dart` (배럴 export — mobile-brief.md 참조)
- `apps/mobile/packages/qna/README.md` (통합 가이드 — mobile-brief.md 참조)

**주의사항**:
- pubspec.yaml에 `resolution: workspace` 추가 금지 (melos bootstrap 실패 원인)
- version 필드는 `0.0.1`로 설정
- publish_to는 `'none'`으로 설정

#### 1.2 파일 이동 (packages/api → packages/qna)

**이동할 파일**:
```
apps/mobile/packages/api/lib/src/models/qna/qna_submit_request.dart
  → apps/mobile/packages/qna/lib/src/models/qna_submit_request.dart

apps/mobile/packages/api/lib/src/models/qna/qna_submit_response.dart
  → apps/mobile/packages/qna/lib/src/models/qna_submit_response.dart

apps/mobile/packages/api/lib/src/services/qna_api_service.dart
  → apps/mobile/packages/qna/lib/src/services/qna_api_service.dart
```

**주의사항**:
- `.freezed.dart`, `.g.dart` 파일은 이동하지 말고, 이동 후 `melos generate`로 재생성
- 디렉토리명 변경: `models/qna/` → `models/` (qna 하위 디렉토리 제거)

#### 1.3 파일 이동 (apps/wowa → packages/qna)

**이동할 파일**:
```
apps/mobile/apps/wowa/lib/app/data/repositories/qna_repository.dart
  → apps/mobile/packages/qna/lib/src/repositories/qna_repository.dart

apps/mobile/apps/wowa/lib/app/modules/qna/controllers/qna_controller.dart
  → apps/mobile/packages/qna/lib/src/controllers/qna_controller.dart

apps/mobile/apps/wowa/lib/app/modules/qna/bindings/qna_binding.dart
  → apps/mobile/packages/qna/lib/src/bindings/qna_binding.dart

apps/mobile/apps/wowa/lib/app/modules/qna/views/qna_submit_view.dart
  → apps/mobile/packages/qna/lib/src/views/qna_submit_view.dart
```

**주의사항**:
- 파일 이동 시 기존 위치의 파일은 삭제 (`mv` 명령어 사용)
- wowa 앱의 `modules/qna/` 디렉토리는 전체 삭제 (Phase 4에서 수행)

#### 1.4 Import 경로 수정 (qna 패키지 내부)

**수정 대상 파일 및 변경 예시**:

**qna_submit_request.dart, qna_submit_response.dart**:
- 변경 사항 없음 (Freezed 모델)

**qna_api_service.dart**:
```dart
// Before
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/qna/qna_submit_request.dart';
import '../models/qna/qna_submit_response.dart';

// After
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/qna_submit_request.dart';
import '../models/qna_submit_response.dart';
```

**qna_repository.dart**:
```dart
// Before
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:api/api.dart';
import 'package:core/core.dart';

// After
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../models/qna_submit_request.dart';
import '../models/qna_submit_response.dart';
import '../services/qna_api_service.dart';
```

**qna_controller.dart**:
```dart
// Before
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../../../data/repositories/qna_repository.dart';

// After
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../repositories/qna_repository.dart';
```

**qna_binding.dart**:
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

**qna_submit_view.dart**:
```dart
// Before (변경 없음)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/qna_controller.dart';

// After (동일)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_system/design_system.dart';
import 'package:core/core.dart';
import '../controllers/qna_controller.dart';
```

**주의사항**:
- `package:api/api.dart` import를 제거하고 상대 경로로 변경
- 상대 경로 깊이 확인: `../models/`, `../services/`, `../repositories/`

#### 1.5 코드 생성 실행

**명령어**:
```bash
cd /Users/lms/dev/repository/feature-qna/apps/mobile
melos bootstrap
melos generate
```

**검증 항목**:
- `packages/qna/lib/src/models/qna_submit_request.freezed.dart` 생성
- `packages/qna/lib/src/models/qna_submit_request.g.dart` 생성
- `packages/qna/lib/src/models/qna_submit_response.freezed.dart` 생성
- `packages/qna/lib/src/models/qna_submit_response.g.dart` 생성

**오류 발생 시**:
- `melos clean && melos bootstrap` 재실행
- import 경로 오류 확인

---

## Phase 2: 동작 변경 (appCode 파라미터화)

### 목표
SDK 패키지가 특정 앱에 종속되지 않도록 `appCode`를 하드코딩에서 파라미터로 변경합니다.

### 작업 항목

#### 2.1 QnaBinding 수정

**파일**: `packages/qna/lib/src/bindings/qna_binding.dart`

**변경 사항**:
1. `final String appCode;` 필드 추가
2. `QnaBinding({required this.appCode})` 생성자 파라미터 추가
3. `dependencies()` 메서드에서 `QnaRepository(appCode: appCode)` 주입

**변경 후 코드** (mobile-brief.md 87~119행 참조):
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

**주의사항**:
- `required` 키워드 필수 (컴파일 타임에 appCode 누락 감지)
- JSDoc 주석 한글로 작성

#### 2.2 QnaRepository 수정

**파일**: `packages/qna/lib/src/repositories/qna_repository.dart`

**변경 사항**:
1. `final String appCode;` 필드 추가
2. `QnaRepository({required this.appCode})` 생성자
3. `submitQuestion()` 메서드 내부: `appCode: 'wowa'` → `appCode: appCode`

**변경 후 코드** (mobile-brief.md 131~220행 참조):
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
    // (기존 로직 유지 — 변경 없음)
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

**주의사항**:
- `_mapDioError()` 메서드는 변경하지 말 것
- JSDoc 주석 한글로 작성

#### 2.3 QnaController 검증

**파일**: `packages/qna/lib/src/controllers/qna_controller.dart`

**변경 사항**: 없음

**검증 항목**:
- Controller는 `Get.find<QnaRepository>()`로 Repository를 주입받으므로 변경 불필요
- Repository의 appCode를 직접 알 필요 없음

---

## Phase 3: API 패키지 정리

### 목표
`packages/api/`에서 QnA 관련 코드를 제거하여 SDK 패키지로 완전히 분리합니다.

### 작업 항목

#### 3.1 QnA 관련 파일 삭제

**삭제할 디렉토리 및 파일**:
```bash
rm -rf apps/mobile/packages/api/lib/src/models/qna/
# (qna_submit_request.dart, qna_submit_response.dart, .freezed.dart, .g.dart 모두 삭제)
```

**주의사항**:
- Phase 1에서 이미 이동했으므로 기존 위치의 파일은 삭제만 수행
- `.freezed.dart`, `.g.dart` 파일도 함께 삭제

#### 3.2 API 서비스 삭제

**삭제할 파일**:
```bash
rm apps/mobile/packages/api/lib/src/services/qna_api_service.dart
```

#### 3.3 배럴 Export 수정

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

**주의사항**:
- QnA 관련 export 2줄 제거
- Auth 관련 코드는 유지

---

## Phase 4: wowa 앱 전환

### 목표
기존 wowa 앱을 SDK 패키지를 사용하도록 전환하고 회귀 테스트를 수행합니다.

### 작업 항목

#### 4.1 기존 QnA 모듈 삭제

**삭제할 디렉토리 및 파일**:
```bash
rm -rf apps/mobile/apps/wowa/lib/app/modules/qna/
# (controllers, bindings, views 전체 삭제)

rm apps/mobile/apps/wowa/lib/app/data/repositories/qna_repository.dart
```

**주의사항**:
- Phase 1에서 이미 이동했으므로 삭제만 수행
- `modules/qna/` 디렉토리 전체 삭제

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

**주의사항**:
- `qna` 패키지 의존성을 Internal packages 섹션에 추가
- 경로는 `../../packages/qna`

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

**주의사항**:
- `../modules/qna/` import 제거
- `package:qna/qna.dart` import 추가
- `QnaBinding(appCode: 'wowa')` 파라미터 추가 (필수)

**파일**: `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart`

**변경 사항**: 없음 (기존 `Routes.QNA` 유지)

#### 4.4 melos bootstrap 실행

**명령어**:
```bash
cd /Users/lms/dev/repository/feature-qna/apps/mobile
melos clean && melos bootstrap
```

**검증 항목**:
- `melos list` 실행 시 `qna` 패키지가 리스트에 포함됨
- 의존성 해결 성공

**오류 발생 시**:
- pubspec.yaml 경로 확인 (`../../packages/qna`)
- `resolution: workspace` 제거 (qna 패키지 pubspec.yaml)

---

## 검증 기준

### SDK 패키지 빌드 검증

**명령어**:
```bash
cd /Users/lms/dev/repository/feature-qna/apps/mobile
melos bootstrap
melos generate
melos analyze
```

**검증 항목**:
- [ ] `melos bootstrap` 성공
- [ ] `melos generate` 성공 (Freezed 코드 생성)
- [ ] `melos analyze` 경고 없음
- [ ] `packages/qna/` 패키지 단독 빌드 가능

### 파일 이동 완료 검증

**검증 항목**:
- [ ] `packages/api/lib/src/models/qna/` 디렉토리 삭제됨
- [ ] `packages/api/lib/src/services/qna_api_service.dart` 삭제됨
- [ ] `apps/wowa/lib/app/modules/qna/` 디렉토리 삭제됨
- [ ] `apps/wowa/lib/app/data/repositories/qna_repository.dart` 삭제됨
- [ ] `packages/qna/lib/src/` 하위에 모든 파일 존재

### appCode 파라미터화 검증

**검증 항목**:
- [ ] `QnaRepository`에 `final String appCode;` 필드 존재
- [ ] `QnaBinding`에 `required String appCode` 생성자 파라미터 존재
- [ ] `QnaRepository`의 `submitQuestion()` 메서드에서 `appCode` 사용
- [ ] wowa 앱 라우트에서 `QnaBinding(appCode: 'wowa')` 주입

### wowa 앱 전환 검증

**검증 항목**:
- [ ] `apps/wowa/pubspec.yaml`에 `qna` 패키지 의존성 추가
- [ ] `app_pages.dart`에서 `package:qna/qna.dart` import
- [ ] `QnaBinding(appCode: 'wowa')` 주입

### API 패키지 정리 검증

**검증 항목**:
- [ ] `packages/api/lib/api.dart`에 QnA export 제거
- [ ] `packages/api/lib/src/models/qna/` 디렉토리 삭제
- [ ] `packages/api/lib/src/services/qna_api_service.dart` 삭제

### 기능 회귀 테스트

**테스트 항목**:
- [ ] wowa 앱 실행 성공 (`flutter run`)
- [ ] Routes.QNA로 이동 가능 (`Get.toNamed(Routes.QNA)`)
- [ ] QnaSubmitView가 정상적으로 렌더링됨
- [ ] 질문 제목 입력 가능
- [ ] 질문 본문 입력 가능
- [ ] 제출 버튼 클릭 시 API 호출 (`POST /api/qna/questions`)
- [ ] 성공 모달 표시 후 화면 닫기
- [ ] 실패 모달 표시 후 재시도 가능
- [ ] appCode가 'wowa'로 서버에 전달됨 (서버 로그 확인 또는 네트워크 패킷 확인)

**검증 방법**:
1. wowa 앱 실행 후 QnA 화면 접근
2. 질문 제출 후 서버 로그에서 `appCode: 'wowa'` 확인
3. GitHub Issues에 질문 등록 확인 (wowa 레포지토리)

### 의존성 순환 검증

**검증 항목**:
- [ ] `packages/qna/`는 `core`, `design_system`만 의존 (pubspec.yaml 확인)
- [ ] `packages/api/`는 QnA에 의존하지 않음
- [ ] `wowa` 앱은 `qna` 패키지 import

---

## 위험 요소 및 대응

### 1. 코드 생성 실패 (.freezed.dart, .g.dart)

**원인**:
- `melos generate` 실패 시 컴파일 오류 발생

**대응**:
- Phase 1.5에서 `melos clean && melos bootstrap && melos generate` 재실행
- import 경로 오류 확인 (상대 경로 깊이)

### 2. Import 경로 오류

**원인**:
- 파일 이동 후 상대 경로 깊이가 맞지 않음
- 패키지 import 누락

**대응**:
- `melos analyze` 실행하여 오류 확인
- 각 파일의 import 경로를 mobile-brief.md와 대조

### 3. wowa 앱 컴파일 오류

**원인**:
- Phase 4 완료 전 `../modules/qna/` import가 남아있음
- `QnaBinding()` 파라미터 누락

**대응**:
- Phase 4.3에서 `package:qna/qna.dart` import 확인
- `QnaBinding(appCode: 'wowa')` 파라미터 확인

### 4. appCode 서버 전달 실패

**원인**:
- Phase 2에서 `appCode: appCode` 수정 누락
- QnaBinding에서 Repository 주입 시 appCode 전달 누락

**대응**:
- Phase 2.2에서 `QnaRepository` 코드 재확인
- Phase 2.1에서 `QnaBinding` 코드 재확인
- 네트워크 패킷 캡처 또는 서버 로그 확인

### 5. melos bootstrap 실패

**원인**:
- `pubspec.yaml`에 `resolution: workspace` 추가됨

**대응**:
- `packages/qna/pubspec.yaml`에서 `resolution: workspace` 제거
- `melos clean && melos bootstrap` 재실행

---

## 다음 단계 (Phase 4 완료 후)

1. **회귀 테스트 수행**: wowa 앱에서 QnA 기능이 정상 작동하는지 확인
2. **README.md 검토**: `packages/qna/README.md`에 통합 가이드가 정확한지 확인
3. **문서 업데이트**: `docs/wowa/mobile-catalog.md`에 QnA SDK 패키지 추가
4. **Git 커밋**: Tidy First 방법론에 따라 Phase 1~3을 구조적 변경 커밋, Phase 2를 동작 변경 커밋으로 분리
5. **향후 작업**: 다른 앱에서 SDK 패키지 통합 테스트 (Phase 2 스코프)

---

## 참고 문서

- User Story: `/Users/lms/dev/repository/feature-qna/docs/core/qna-sdk/user-story.md`
- Mobile Brief: `/Users/lms/dev/repository/feature-qna/docs/core/qna-sdk/mobile-brief.md`
- Mobile CLAUDE.md: `/Users/lms/dev/repository/feature-qna/apps/mobile/CLAUDE.md`
- GetX Best Practices: `/Users/lms/dev/repository/feature-qna/.claude/guide/mobile/getx_best_practices.md`
- Directory Structure: `/Users/lms/dev/repository/feature-qna/.claude/guide/mobile/directory_structure.md`

---

## 작업 체크리스트

### Phase 1: 구조적 변경
- [ ] 1.1 새 패키지 생성 (pubspec.yaml, qna.dart, README.md)
- [ ] 1.2 파일 이동 (packages/api → packages/qna)
- [ ] 1.3 파일 이동 (apps/wowa → packages/qna)
- [ ] 1.4 Import 경로 수정 (qna 패키지 내부)
- [ ] 1.5 코드 생성 실행 (melos bootstrap, melos generate)

### Phase 2: 동작 변경
- [ ] 2.1 QnaBinding 수정 (appCode 파라미터 추가)
- [ ] 2.2 QnaRepository 수정 (appCode 파라미터화)
- [ ] 2.3 QnaController 검증 (변경 없음 확인)

### Phase 3: API 패키지 정리
- [ ] 3.1 QnA 관련 파일 삭제 (models/qna/)
- [ ] 3.2 API 서비스 삭제 (qna_api_service.dart)
- [ ] 3.3 배럴 Export 수정 (api.dart)

### Phase 4: wowa 앱 전환
- [ ] 4.1 기존 QnA 모듈 삭제
- [ ] 4.2 pubspec.yaml 의존성 추가 (qna 패키지)
- [ ] 4.3 라우트 등록 수정 (package:qna/qna.dart import, appCode 주입)
- [ ] 4.4 melos bootstrap 실행

### 검증
- [ ] SDK 패키지 빌드 검증
- [ ] 파일 이동 완료 검증
- [ ] appCode 파라미터화 검증
- [ ] wowa 앱 전환 검증
- [ ] API 패키지 정리 검증
- [ ] 기능 회귀 테스트
- [ ] 의존성 순환 검증

---

**최종 확인**: Flutter Developer는 모든 체크리스트를 완료한 후 CTO에게 보고합니다.
