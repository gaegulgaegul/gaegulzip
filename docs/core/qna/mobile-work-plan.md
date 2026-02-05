# Mobile 작업 분배 계획: QnA

## 개요

QnA 기능의 Flutter 모바일 개발 작업 분배 계획입니다.
GetX 패턴(Controller/View/Binding)을 따르며, Design System의 Sketch 컴포넌트를 활용합니다.

**참조 문서**:
- User Story: [`user-story.md`](./user-story.md)
- Mobile Design Spec: [`mobile-design-spec.md`](./mobile-design-spec.md)
- Mobile Brief: [`mobile-brief.md`](./mobile-brief.md)
- Mobile CLAUDE.md: [`apps/mobile/CLAUDE.md`](../../../apps/mobile/CLAUDE.md)

---

## 작업 순서 및 의존성

```
[1] API 모델 정의 (Freezed) → [2] 코드 생성 (melos generate)
      ↓
[3] API 서비스 (QnaApiService)
      ↓
[4] Repository (QnaRepository)
      ↓
[5] Controller (QnaController)
      ↓                    ↓
[6] Binding (QnaBinding)  [7] View (QnaSubmitView)
      ↓                    ↓
[8] 라우팅 등록 (app_routes.dart, app_pages.dart)
      ↓
[9] 통합 테스트 및 빌드 검증
```

---

## 작업 분배

### Task 1: API 모델 정의 (Freezed)

**담당**: Junior Developer (API 모델 경험자 선호)
**소요 시간**: 1시간
**의존성**: 없음 (독립 작업)

#### 작업 내용

1. `packages/api/lib/src/models/qna/qna_submit_request.dart` 생성:
   - @freezed 클래스 정의
   - 필드: appCode, title, body (모두 required String)
   - fromJson 팩토리 메서드
   - part 파일 선언 (.freezed.dart, .g.dart)

2. `packages/api/lib/src/models/qna/qna_submit_response.dart` 생성:
   - @freezed 클래스 정의
   - 필드: questionId (int), issueNumber (int), issueUrl (String), createdAt (String)
   - fromJson 팩토리 메서드
   - part 파일 선언

3. JSDoc 스타일 주석 작성 (한글)

#### 체크리스트

- [ ] QnaSubmitRequest:
  - [ ] @freezed 클래스 정의
  - [ ] 필드: appCode, title, body (모두 required String)
  - [ ] fromJson 팩토리
  - [ ] part 'qna_submit_request.freezed.dart';
  - [ ] part 'qna_submit_request.g.dart';
- [ ] QnaSubmitResponse:
  - [ ] @freezed 클래스 정의
  - [ ] 필드: questionId (int), issueNumber (int), issueUrl (String), createdAt (String)
  - [ ] fromJson 팩토리
  - [ ] part 'qna_submit_response.freezed.dart';
  - [ ] part 'qna_submit_response.g.dart';
- [ ] 주석 작성 (한글)

#### 참조

- Mobile Brief의 2. API 모델 설계 섹션
- 기존 모델: `packages/api/lib/src/models/login/login_request.dart`

---

### Task 2: 코드 생성 (Freezed)

**담당**: Junior Developer (Task 1 담당자)
**소요 시간**: 10분
**의존성**: Task 1 완료

#### 작업 내용

1. Freezed 코드 생성:
   ```bash
   cd /Users/lms/dev/repository/feature-qna/apps/mobile
   melos generate
   ```

2. 생성된 파일 확인:
   - `qna_submit_request.freezed.dart`
   - `qna_submit_request.g.dart`
   - `qna_submit_response.freezed.dart`
   - `qna_submit_response.g.dart`

3. 빌드 에러 없는지 확인

#### 완료 조건

- [ ] 모든 .freezed.dart, .g.dart 파일 생성됨
- [ ] `melos generate` 성공 (에러 없음)
- [ ] IDE에서 import 에러 없음

---

### Task 3: API 서비스 (QnaApiService)

**담당**: Junior Developer
**소요 시간**: 1시간
**의존성**: Task 2 완료

#### 작업 내용

1. `packages/api/lib/src/services/qna_api_service.dart` 생성
2. Dio 기반 API 호출 메서드 구현:
   - `submitQuestion(QnaSubmitRequest request)`: POST /api/qna/questions
3. Dio 인스턴스 Get.find로 주입
4. JSDoc 주석 작성

#### 체크리스트

- [ ] QnaApiService 클래스 정의
- [ ] Dio 인스턴스 Get.find<Dio>()
- [ ] submitQuestion 메서드:
  - [ ] POST /api/qna/questions
  - [ ] request.toJson() 전송
  - [ ] QnaSubmitResponse.fromJson(response.data) 반환
- [ ] 주석 작성 (한글)

#### 참조

- Mobile Brief의 QnaApiService 예시
- 기존 서비스: `packages/api/lib/src/services/login_api_service.dart`

---

### Task 4: Barrel Export 업데이트

**담당**: Junior Developer (Task 3 담당자)
**소요 시간**: 10분
**의존성**: Task 3 완료

#### 작업 내용

1. `packages/api/lib/api.dart`에 모델 및 서비스 export 추가:
   ```dart
   export 'src/models/qna/qna_submit_request.dart';
   export 'src/models/qna/qna_submit_response.dart';
   export 'src/services/qna_api_service.dart';
   ```

2. 다른 패키지에서 `import 'package:api/api.dart';`로 접근 가능 확인

#### 완료 조건

- [ ] api.dart에 QnA 관련 export 추가
- [ ] wowa 앱에서 import 'package:api/api.dart'; 성공

---

### Task 5: Repository (QnaRepository)

**담당**: Senior Developer (에러 처리 경험 필요)
**소요 시간**: 1.5시간
**의존성**: Task 3, 4 완료

#### 작업 내용

1. `apps/wowa/lib/app/data/repositories/qna_repository.dart` 생성
2. QnaRepository 클래스 구현:
   - QnaApiService 주입 (Get.find)
   - `submitQuestion({ required title, required body })`: QnaSubmitResponse 반환
   - DioException → NetworkException 변환 (_mapDioError)
3. 에러 매핑:
   - 네트워크 오류: "네트워크 연결을 확인해주세요"
   - 400: "제목과 내용을 확인해주세요"
   - 404: "서비스 설정 오류가 발생했습니다"
   - 5xx: "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
4. JSDoc 주석 작성

#### 체크리스트

- [ ] QnaRepository 클래스 정의
- [ ] QnaApiService 주입
- [ ] submitQuestion 메서드:
  - [ ] QnaSubmitRequest 생성 (appCode: 'wowa')
  - [ ] _apiService.submitQuestion 호출
  - [ ] try-catch로 DioException 처리
- [ ] _mapDioError 메서드:
  - [ ] connectionTimeout, receiveTimeout, connectionError → NetworkException
  - [ ] 400 → NetworkException (제목과 내용 확인)
  - [ ] 404 → NetworkException (서비스 설정 오류)
  - [ ] 5xx → NetworkException (일시적 오류)
  - [ ] 기타 → NetworkException (알 수 없는 오류)
- [ ] 주석 작성 (한글)

#### 참조

- Mobile Brief의 3. Repository 설계 섹션
- 기존 Repository: `apps/wowa/lib/app/data/repositories/auth_repository.dart`
- 에러 처리 가이드: `.claude/guide/mobile/error_handling.md`

---

### Task 6: Controller (QnaController)

**담당**: Senior Developer (Task 5 담당자)
**소요 시간**: 2.5시간
**의존성**: Task 5 완료

#### 작업 내용

1. `apps/wowa/lib/app/modules/qna/controllers/qna_controller.dart` 생성
2. GetxController 상속
3. TextEditingController (titleController, bodyController)
4. 반응형 상태 (.obs):
   - isSubmitting (RxBool)
   - titleError, bodyError, errorMessage (RxString)
   - bodyLength (RxInt)
5. onInit에서 TextEditingController 리스너 등록
6. onClose에서 dispose
7. 입력 검증 메서드 (validateTitle, validateBody)
8. 질문 제출 메서드 (submitQuestion)
9. 성공/실패 모달 표시 (_showSuccessModal, _showErrorModal)
10. JSDoc 주석 작성

#### 체크리스트

- [ ] QnaController 클래스 정의 (extends GetxController)
- [ ] QnaRepository 주입 (Get.find)
- [ ] TextEditingController:
  - [ ] titleController
  - [ ] bodyController
- [ ] 반응형 상태 (.obs):
  - [ ] isSubmitting = false.obs
  - [ ] titleError = ''.obs
  - [ ] bodyError = ''.obs
  - [ ] bodyLength = 0.obs
  - [ ] errorMessage = ''.obs
- [ ] Getter:
  - [ ] isSubmitEnabled (제목/본문 비어있지 않고, 길이 제한 내, 제출 중 아님)
- [ ] onInit:
  - [ ] bodyController.addListener (bodyLength 업데이트, 에러 재검증)
  - [ ] titleController.addListener (에러 재검증)
- [ ] onClose:
  - [ ] titleController.dispose()
  - [ ] bodyController.dispose()
- [ ] validateTitle 메서드:
  - [ ] 빈 값: "제목을 입력해주세요"
  - [ ] 256자 초과: "제목은 256자 이내로 입력해주세요"
  - [ ] 정상: titleError.value = ''
- [ ] validateBody 메서드:
  - [ ] 빈 값: "질문 내용을 입력해주세요"
  - [ ] 65536자 초과: "본문은 65536자 이내로 입력해주세요"
  - [ ] 정상: bodyError.value = ''
- [ ] submitQuestion 메서드:
  - [ ] validateTitle, validateBody 호출
  - [ ] 에러 있으면 return
  - [ ] isSubmitting.value = true
  - [ ] _repository.submitQuestion 호출
  - [ ] 성공 시: _showSuccessModal()
  - [ ] NetworkException 시: errorMessage.value 설정, _showErrorModal()
  - [ ] finally: isSubmitting.value = false
- [ ] _showSuccessModal 메서드:
  - [ ] SketchModal.show 호출
  - [ ] "확인" 버튼 탭 시: Get.back() x2
- [ ] _showErrorModal 메서드:
  - [ ] SketchModal.show 호출
  - [ ] "닫기" / "재시도" 버튼
  - [ ] 재시도 탭 시: submitQuestion() 재호출
- [ ] 주석 작성 (한글)

#### 참조

- Mobile Brief의 4. GetX 상태 관리 설계 섹션
- 기존 Controller: `apps/wowa/lib/app/modules/login/controllers/login_controller.dart`

---

### Task 7: Binding (QnaBinding)

**담당**: Junior Developer
**소요 시간**: 30분
**의존성**: Task 3, 5, 6 완료

#### 작업 내용

1. `apps/wowa/lib/app/modules/qna/bindings/qna_binding.dart` 생성
2. Bindings 상속
3. dependencies() 메서드에서 DI 등록:
   - QnaApiService (Get.lazyPut)
   - QnaRepository (Get.lazyPut)
   - QnaController (Get.lazyPut)
4. JSDoc 주석 작성

#### 체크리스트

- [ ] QnaBinding 클래스 정의 (extends Bindings)
- [ ] dependencies() 메서드:
  - [ ] Get.lazyPut<QnaApiService>(() => QnaApiService())
  - [ ] Get.lazyPut<QnaRepository>(() => QnaRepository())
  - [ ] Get.lazyPut<QnaController>(() => QnaController())
- [ ] 주석 작성 (한글)

#### 참조

- Mobile Brief의 5. Binding 설계 섹션
- 기존 Binding: `apps/wowa/lib/app/modules/login/bindings/login_binding.dart`

---

### Task 8: View (QnaSubmitView)

**담당**: Junior Developer
**소요 시간**: 3시간
**의존성**: Task 6 완료

#### 작업 내용

1. `apps/wowa/lib/app/modules/qna/views/qna_submit_view.dart` 생성
2. GetView<QnaController> 상속
3. Scaffold 구조:
   - AppBar (leading: IconButton, title: "질문하기")
   - body: SafeArea → SingleChildScrollView → Padding → Column
4. 위젯 구성:
   - 안내 문구 Text
   - SketchInput (제목) - Obx로 errorText 반응형
   - SketchInput (본문) - Obx로 errorText 반응형
   - 글자 수 카운터 Text - Obx로 bodyLength 반응형
   - SketchButton (제출) - Obx로 isLoading, onPressed 조건부
5. const 최적화 (정적 위젯)
6. JSDoc 주석 작성

#### 체크리스트

- [ ] QnaSubmitView 클래스 정의 (extends GetView<QnaController>)
- [ ] Scaffold:
  - [ ] AppBar:
    - [ ] leading: IconButton (Icons.arrow_back, Get.back())
    - [ ] title: Text('질문하기')
  - [ ] body: SafeArea → SingleChildScrollView → Padding (24h, 16v)
- [ ] Column (crossAxisAlignment: start):
  - [ ] SizedBox(height: 8)
  - [ ] const Text('궁금한 점을 남겨주세요...')
  - [ ] SizedBox(height: 24)
  - [ ] Obx(() => SketchInput (제목)):
    - [ ] label: '제목 *'
    - [ ] hint: '질문 제목을 입력하세요 (최대 256자)'
    - [ ] controller: controller.titleController
    - [ ] maxLength: 256
    - [ ] errorText: controller.titleError.value (빈 문자열이면 null)
    - [ ] prefixIcon: Icons.edit
  - [ ] SizedBox(height: 24)
  - [ ] Obx(() => SketchInput (본문)):
    - [ ] label: '질문 내용 *'
    - [ ] hint: '구체적으로 작성할수록...'
    - [ ] controller: controller.bodyController
    - [ ] maxLength: 65536
    - [ ] minLines: 8
    - [ ] maxLines: 20
    - [ ] errorText: controller.bodyError.value
    - [ ] prefixIcon: Icons.description
  - [ ] SizedBox(height: 12)
  - [ ] Obx(() => _buildCharCounter()):
    - [ ] Text: "본문: ${controller.bodyLength.value} / 65536자"
    - [ ] 색상: 60000자 초과 시 warning, 65000자 초과 시 error
  - [ ] SizedBox(height: 32)
  - [ ] Obx(() => SketchButton):
    - [ ] text: '질문 제출'
    - [ ] icon: Icons.send
    - [ ] size: SketchButtonSize.large
    - [ ] style: SketchButtonStyle.primary
    - [ ] isLoading: controller.isSubmitting.value
    - [ ] onPressed: controller.isSubmitEnabled ? controller.submitQuestion : null
  - [ ] SizedBox(height: 16)
- [ ] const 최적화 (SizedBox, 안내 문구 Text 등)
- [ ] 주석 작성 (한글)

#### 참조

- Mobile Design Spec: [`mobile-design-spec.md`](./mobile-design-spec.md)
- Mobile Brief의 6. View 설계 섹션
- Design System: `packages/design_system/lib/src/components/`
- 기존 View: `apps/wowa/lib/app/modules/login/views/login_view.dart`

---

### Task 9: 라우팅 등록

**담당**: Junior Developer (Task 8 담당자)
**소요 시간**: 30분
**의존성**: Task 7, 8 완료

#### 작업 내용

1. `apps/wowa/lib/app/routes/app_routes.dart` 업데이트:
   - `static const QNA = '/qna';` 추가

2. `apps/wowa/lib/app/routes/app_pages.dart` 업데이트:
   - GetPage 등록:
     - name: Routes.QNA
     - page: () => const QnaSubmitView()
     - binding: QnaBinding()
     - transition: Transition.cupertino
     - transitionDuration: 300ms

#### 체크리스트

- [ ] app_routes.dart:
  - [ ] Routes.QNA = '/qna' 추가
- [ ] app_pages.dart:
  - [ ] GetPage 등록 (QNA)
  - [ ] binding: QnaBinding()
  - [ ] transition: Transition.cupertino
- [ ] 다른 화면에서 Get.toNamed(Routes.QNA) 호출 가능 확인

#### 참조

- Mobile Brief의 7. 라우팅 설계 섹션
- 기존 라우팅: `apps/wowa/lib/app/routes/app_routes.dart`

---

### Task 10: 통합 테스트 및 빌드 검증

**담당**: Senior Developer + Junior Developer (협업)
**소요 시간**: 1.5시간
**의존성**: Task 1~9 모두 완료

#### 작업 내용

1. Flutter analyze 실행:
   ```bash
   cd /Users/lms/dev/repository/feature-qna/apps/mobile/apps/wowa
   flutter analyze
   ```

2. 앱 빌드 (Android):
   ```bash
   flutter build apk --debug
   ```

3. 시뮬레이터/에뮬레이터에서 앱 실행:
   ```bash
   flutter run
   ```

4. QnA 화면 진입 테스트:
   - Get.toNamed(Routes.QNA) 호출 (임시 버튼 추가)
   - 화면 렌더링 확인

5. 입력 검증 테스트:
   - 제목 256자 초과 입력 → 에러 메시지 표시
   - 본문 65536자 초과 입력 → 에러 메시지 표시
   - 제목/본문 비어있을 때 제출 버튼 비활성화

6. API 호출 테스트:
   - 서버 실행 확인
   - 질문 제출 → 성공 모달 표시
   - 네트워크 끊고 제출 → 실패 모달 + 에러 메시지

7. Controller-View 연결 검증:
   - 모든 .obs 변수가 Obx로 반응형 렌더링되는지 확인
   - titleController, bodyController가 SketchInput과 정확히 연결되었는지 확인

8. GetX 패턴 검증:
   - Controller/View/Binding 분리 확인
   - Get.find<QnaController>() 정상 동작

#### 완료 조건

- [ ] flutter analyze 성공 (에러 0개)
- [ ] 앱 빌드 성공
- [ ] QnA 화면 진입 성공
- [ ] 입력 검증 정상 동작 (에러 메시지 표시)
- [ ] 제출 버튼 활성화/비활성화 정상
- [ ] API 호출 성공 (성공 모달 표시)
- [ ] 네트워크 오류 시 실패 모달 + 재시도 버튼
- [ ] Controller-View 연결 정상 (모든 .obs 반응형)
- [ ] GetX 패턴 준수 (Controller/View/Binding 분리)

---

## 작업 병렬화 전략

### 병렬 가능한 작업

- **Group A**: Task 1, 2 (Freezed 모델 + 코드 생성)
- **Group B**: Task 7 (Binding) - Task 3, 5, 6 완료 후
- **Group C**: Task 8 (View) - Task 6 완료 후

### 순차 작업

- Task 1 → Task 2 (모델 정의 후 코드 생성)
- Task 2 → Task 3 (코드 생성 후 API 서비스)
- Task 3 → Task 4 (API 서비스 후 barrel export)
- Task 4 → Task 5 (API 서비스 후 Repository)
- Task 5 → Task 6 (Repository 후 Controller)
- Task 6 → Task 7, 8 (Controller 후 Binding과 View)
- Task 7, 8 → Task 9 (Binding, View 후 라우팅)
- Task 9 → Task 10 (라우팅 후 통합 테스트)

### 개발자별 작업 할당 예시

**Senior Developer**:
- Task 5: Repository (에러 처리)
- Task 6: Controller (상태 관리, 제출 로직, 모달)
- Task 10: 통합 테스트 (협업)

**Junior Developer**:
- Task 1, 2: Freezed 모델 + 코드 생성
- Task 3, 4: API 서비스 + barrel export
- Task 7: Binding
- Task 8: View
- Task 9: 라우팅
- Task 10: 통합 테스트 (협업)

### 예상 총 소요 시간

- **Senior**: 4시간
- **Junior**: 6.5시간
- **병렬 작업 시 전체**: ~7시간 (일부 대기 시간 포함)

---

## Module Contracts (공통 인터페이스)

### Controller ↔ View 연결점

**Controller가 View에 제공하는 상태**:
- `titleController: TextEditingController`
- `bodyController: TextEditingController`
- `isSubmitting: RxBool`
- `titleError: RxString`
- `bodyError: RxString`
- `bodyLength: RxInt`
- `errorMessage: RxString`
- `isSubmitEnabled: bool` (getter)

**Controller가 View에 제공하는 메서드**:
- `submitQuestion(): Future<void>`

**View가 Controller를 사용하는 방식**:
- `Obx(() => SketchInput(errorText: controller.titleError.value))`
- `Obx(() => SketchButton(isLoading: controller.isSubmitting.value, onPressed: controller.isSubmitEnabled ? controller.submitQuestion : null))`

---

## 충돌 방지 전략

### 파일 레벨 분리

각 Developer는 독립적인 파일에서 작업합니다:
- **Senior**: Repository, Controller
- **Junior**: Freezed 모델, API 서비스, Binding, View, 라우팅

### 공통 파일 (app_routes.dart, app_pages.dart) 순차 업데이트

- Task 9 (라우팅 등록)는 Task 7, 8 완료 후 진행
- 한 명이 app_routes.dart와 app_pages.dart를 동시에 업데이트

---

## 체크리스트 (전체)

### 구현 전 확인

- [ ] 서버 API 엔드포인트 정의 확인 (POST /api/qna/questions)
- [ ] Design System 컴포넌트 확인 (SketchButton, SketchInput, SketchModal)

### 구현 중 확인

- [ ] Freezed 모델 정의 (QnaSubmitRequest, QnaSubmitResponse)
- [ ] melos generate 실행 (코드 생성)
- [ ] QnaApiService 작성
- [ ] barrel export 업데이트 (packages/api/lib/api.dart)
- [ ] QnaRepository 작성 (에러 매핑)
- [ ] QnaController 작성 (상태 관리, 입력 검증, 제출 로직)
- [ ] QnaBinding 작성 (DI 등록)
- [ ] QnaSubmitView 작성 (design-spec 기반)
- [ ] 라우팅 등록 (app_routes.dart, app_pages.dart)

### 구현 후 확인

- [ ] flutter analyze 성공
- [ ] 앱 빌드 성공
- [ ] QnA 화면 진입 성공
- [ ] 입력 검증 정상 동작
- [ ] API 호출 성공 (성공 모달)
- [ ] 네트워크 오류 처리 (실패 모달 + 재시도)
- [ ] Controller-View 연결 검증
- [ ] GetX 패턴 준수 (Controller/View/Binding 분리)
- [ ] const 최적화 (정적 위젯)
- [ ] Obx 범위 최소화 (변경되는 위젯만)

---

## 참고 자료

- Mobile Brief: [`mobile-brief.md`](./mobile-brief.md)
- Mobile Design Spec: [`mobile-design-spec.md`](./mobile-design-spec.md)
- User Story: [`user-story.md`](./user-story.md)
- Mobile CLAUDE.md: [`apps/mobile/CLAUDE.md`](../../../apps/mobile/CLAUDE.md)
- GetX 베스트 프랙티스: `.claude/guide/mobile/getx_best_practices.md`
- Flutter 베스트 프랙티스: `.claude/guide/mobile/flutter_best_practices.md`
- 에러 처리 가이드: `.claude/guide/mobile/error_handling.md`
- Design System 가이드: `.claude/guide/mobile/design_system.md`
- Login 모듈 참조: `apps/mobile/apps/wowa/lib/app/modules/login/`

---

## 다음 단계

작업 완료 후 **CTO의 통합 리뷰** 진행:

1. API 모델 확인 (Freezed, json_serializable, Dio 클라이언트)
2. Controller 확인 (GetxController, .obs, onInit/onClose, 에러 처리)
3. Binding 확인 (Get.lazyPut, 의존성 주입)
4. View 확인 (GetView, design-spec.md 준수, Obx 범위, const 최적화)
5. Routing 확인 (app_routes.dart, app_pages.dart)
6. Controller-View 연결 검증 (모든 .obs 변수와 메서드 정확히 연결)
7. GetX 패턴 검증 (Controller/View/Binding 분리)
8. 앱 빌드 확인 (flutter analyze)
9. 리뷰 문서 작성 (`mobile-cto-review.md`)
