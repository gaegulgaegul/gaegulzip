# 작업 분배 계획: wowa 로그인 화면 SDK 재사용성 개선

## 개요

로그인 화면 컴포넌트(LoginView, LoginController, LoginBinding)를 wowa 앱에서 auth_sdk 패키지로 이동하여 모든 앱에서 재사용 가능하도록 개선합니다. Senior Developer는 AuthSdk 설정, Controller, Binding 로직을 담당하고, Junior Developer는 View와 앱 통합 작업을 담당합니다.

**핵심 전략**:
1. AuthSdkConfig 클래스 도입으로 UI 설정(homeRoute, showBrowseButton) 주입
2. 프로바이더 등록을 AuthSdk.initialize()로 이동하여 중복 제거
3. LoginView 둘러보기 버튼 조건부 렌더링
4. wowa 앱에서 SDK 로그인 화면 사용 (기존 login 모듈 제거)

---

## 실행 그룹

### Group 1 (순차) — 핵심 SDK 아키텍처 구축 (Senior Developer 단독)

| 작업 | 파일 | 개발자 | 설명 |
|------|------|--------|------|
| 1-1 | `packages/auth_sdk/lib/src/config/auth_sdk_config.dart` | flutter-developer (senior) | AuthSdkConfig 클래스 작성 (homeRoute, showBrowseButton 필드 추가) |
| 1-2 | `packages/auth_sdk/lib/src/auth_sdk.dart` | flutter-developer (senior) | AuthSdk.initialize() 수정 (AuthSdkConfig 객체 받기, _registerProviders() 추가, config getter 추가) |
| 1-3 | `packages/auth_sdk/lib/src/ui/controllers/login_controller.dart` | flutter-developer (senior) | LoginController 수정 (Routes.HOME → AuthSdk.config.homeRoute, import 경로 수정) |
| 1-4 | `packages/auth_sdk/lib/src/ui/bindings/login_binding.dart` | flutter-developer (senior) | LoginBinding 단순화 (프로바이더 등록 제거, LoginController만 등록) |
| 1-5 | `packages/auth_sdk/lib/auth_sdk.dart` | flutter-developer (senior) | barrel export 수정 (LoginView, LoginController, LoginBinding export 추가) |

**의존성 근거**: AuthSdkConfig → AuthSdk.initialize() → LoginController → LoginBinding → export 순서로 의존성이 있으므로 순차 실행 필요.

**완료 조건**: LoginController가 AuthSdk.config.homeRoute를 사용하도록 수정 완료, 프로바이더 등록이 AuthSdk.initialize()에서 처리됨.

---

### Group 2 (병렬) — View 및 앱 통합 (Group 1 완료 후)

| 작업 | 파일 | 개발자 | 설명 |
|------|------|--------|------|
| 2-1 | `packages/auth_sdk/lib/src/ui/views/login_view.dart` | flutter-developer (junior) | LoginView 수정 (둘러보기 버튼 조건부 렌더링, AuthSdk.config.homeRoute 사용, import 경로 수정) |
| 2-2 | `apps/wowa/lib/main.dart` | flutter-developer (senior) | main.dart 수정 (AuthSdkConfig 객체로 initialize() 호출, homeRoute/showBrowseButton 설정) |
| 2-3 | `apps/wowa/lib/app/routes/app_pages.dart` | flutter-developer (junior) | app_pages.dart 수정 (LoginView, LoginBinding import 경로 변경 → auth_sdk에서 가져오기) |

**병렬 가능 근거**: LoginView는 Controller 완성(Group 1) 후 독립적으로 수정 가능. main.dart도 AuthSdk.initialize() 시그니처 변경(Group 1) 후 독립적으로 수정 가능. app_pages.dart는 export(1-5) 완성 후 독립적으로 수정 가능. 세 작업 모두 파일 충돌 없음.

**완료 조건**: LoginView가 둘러보기 버튼을 조건부 렌더링, wowa 앱이 AuthSdkConfig로 SDK 초기화, app_pages.dart가 auth_sdk에서 LoginView/LoginBinding import.

---

### Group 3 (순차) — 정리 (Group 2 완료 후)

| 작업 | 파일 | 개발자 | 설명 |
|------|------|--------|------|
| 3-1 | `apps/wowa/lib/app/modules/login/` | flutter-developer (junior) | wowa 앱 login 모듈 디렉토리 삭제 (SDK로 이동 완료했으므로 제거) |

**완료 조건**: wowa 앱에서 login 모듈 디렉토리가 삭제됨, 모든 로그인 기능이 auth_sdk에서 제공됨.

---

## 모듈 계약 (Module Contracts)

### LoginController ↔ LoginView 연결

**Controller 제공 (반응형 상태)**:
- `isKakaoLoading: RxBool` — 카카오 로그인 로딩 상태
- `isNaverLoading: RxBool` — 네이버 로그인 로딩 상태
- `isAppleLoading: RxBool` — 애플 로그인 로딩 상태
- `isGoogleLoading: RxBool` — 구글 로그인 로딩 상태

**Controller 제공 (메서드)**:
- `handleKakaoLogin()` — 카카오 로그인 처리
- `handleNaverLogin()` — 네이버 로그인 처리
- `handleAppleLogin()` — 애플 로그인 처리
- `handleGoogleLogin()` — 구글 로그인 처리

**View 사용**:
```dart
Obx(() => SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  isLoading: controller.isKakaoLoading.value,
  onPressed: controller.handleKakaoLogin,
))
```

**View가 AuthSdk.config 접근**:
```dart
if (AuthSdk.config.showBrowseButton)
  TextButton(
    onPressed: () => Get.toNamed(AuthSdk.config.homeRoute),
    child: const Text('둘러보기'),
  )
```

### AuthSdk ↔ wowa 앱 계약

**wowa 앱이 SDK 초기화 시 제공**:
- `appCode: 'wowa'` — 앱 식별 코드
- `apiBaseUrl: dotenv.env['API_BASE_URL']` — 서버 API URL
- `homeRoute: Routes.HOME` — 로그인 성공 후 이동 라우트
- `showBrowseButton: true` — 둘러보기 버튼 표시
- `providers: { ... }` — 소셜 프로바이더 OAuth 설정

**SDK가 제공**:
- `LoginView` — 로그인 화면 위젯
- `LoginController` — 로그인 로직
- `LoginBinding` — 의존성 주입

---

## 충돌 방지 전략

### 파일 레벨 분리

**auth_sdk 패키지 내부**:
- Senior Developer: `config/`, `auth_sdk.dart`, `controllers/`, `bindings/`
- Junior Developer: `views/`
- 충돌 없음: Senior가 Controller 완성 후 Junior가 View 수정

**wowa 앱 내부**:
- Senior Developer: `main.dart`
- Junior Developer: `app_pages.dart`, `login/` 삭제
- 충돌 없음: 서로 다른 파일 수정

### 공통 파일 순차 업데이트

**auth_sdk.dart barrel export**:
- Senior Developer가 Group 1에서 한 번에 수정
- Junior Developer는 이미 export된 LoginView/LoginBinding만 사용

### 순차 실행 보장

**Group 1 → Group 2 → Group 3** 순서를 엄격히 준수:
1. Group 1 완료 후 Group 2 시작 (AuthSdk, Controller, Binding 완성 필수)
2. Group 2 완료 후 Group 3 시작 (View, main.dart, app_pages.dart 완성 필수)

---

## 작업별 상세 가이드

### Group 1: Senior Developer

#### 작업 1-1: AuthSdkConfig 클래스 작성

**파일**: `packages/auth_sdk/lib/src/config/auth_sdk_config.dart`

**필수 구현**:
- 불변 객체 (const 생성자)
- 기본값 제공 (`homeRoute: '/home'`, `showBrowseButton: false`)
- 기존 providers 필드 유지

**검증 기준**:
- [ ] AuthSdkConfig 클래스가 const 생성자를 가짐
- [ ] homeRoute, showBrowseButton 필드 존재
- [ ] 기본값이 설정되어 있음

---

#### 작업 1-2: AuthSdk.initialize() 수정

**파일**: `packages/auth_sdk/lib/src/auth_sdk.dart`

**필수 구현**:
- initialize() 메서드 시그니처 변경 (AuthSdkConfig 객체 받기)
- _registerProviders() 메서드 추가 (카카오/네이버/애플/구글 등록)
- config getter 추가 (`static AuthSdkConfig get config`)

**검증 기준**:
- [ ] initialize()가 AuthSdkConfig 객체를 파라미터로 받음
- [ ] _registerProviders()가 4개 프로바이더를 Get.lazyPut으로 등록
- [ ] config getter가 _config를 반환 (null 체크 포함)

---

#### 작업 1-3: LoginController 수정

**파일**: `packages/auth_sdk/lib/src/ui/controllers/login_controller.dart`

**필수 구현**:
- `Routes.HOME` → `AuthSdk.config.homeRoute` 변경
- import 경로 수정 (`../../auth_sdk.dart` 추가)

**검증 기준**:
- [ ] Get.offAllNamed()에서 AuthSdk.config.homeRoute 사용
- [ ] Routes 클래스 import 제거됨
- [ ] 반응형 상태(.obs), 메서드, 에러 처리 모두 기존과 동일

---

#### 작업 1-4: LoginBinding 단순화

**파일**: `packages/auth_sdk/lib/src/ui/bindings/login_binding.dart`

**필수 구현**:
- 프로바이더 등록 제거 (AuthSdk.initialize()로 이동)
- LoginController만 등록 (Get.lazyPut)

**검증 기준**:
- [ ] dependencies() 메서드에서 LoginController만 등록
- [ ] 프로바이더 등록 코드 제거됨
- [ ] dotenv import 제거됨

---

#### 작업 1-5: auth_sdk.dart barrel export 수정

**파일**: `packages/auth_sdk/lib/auth_sdk.dart`

**필수 구현**:
- LoginView, LoginController, LoginBinding export 추가
- AuthSdkConfig export 추가

**검증 기준**:
- [ ] export 'src/config/auth_sdk_config.dart'; 추가됨
- [ ] export 'src/ui/controllers/login_controller.dart'; 추가됨
- [ ] export 'src/ui/views/login_view.dart'; 추가됨
- [ ] export 'src/ui/bindings/login_binding.dart'; 추가됨

---

### Group 2: Junior Developer + Senior Developer (병렬)

#### 작업 2-1: LoginView 수정 (Junior)

**파일**: `packages/auth_sdk/lib/src/ui/views/login_view.dart`

**필수 구현**:
- 둘러보기 버튼 조건부 렌더링 (`if (AuthSdk.config.showBrowseButton)`)
- `Routes.HOME` → `AuthSdk.config.homeRoute` 변경
- import 경로 수정 (`../../auth_sdk.dart` 추가)

**검증 기준**:
- [ ] TextButton이 `if (AuthSdk.config.showBrowseButton)` 조건문으로 감싸짐
- [ ] Get.toNamed()에서 AuthSdk.config.homeRoute 사용
- [ ] Routes 클래스 import 제거됨
- [ ] design-spec.md의 UI 구조 100% 준수

---

#### 작업 2-2: main.dart 수정 (Senior)

**파일**: `apps/wowa/lib/main.dart`

**필수 구현**:
- AuthSdk.initialize() 호출을 AuthSdkConfig 객체로 변경
- homeRoute: Routes.HOME 설정
- showBrowseButton: true 설정

**검증 기준**:
- [ ] AuthSdkConfig 객체로 initialize() 호출
- [ ] homeRoute: Routes.HOME 설정됨
- [ ] showBrowseButton: true 설정됨
- [ ] providers 설정 유지됨

---

#### 작업 2-3: app_pages.dart 수정 (Junior)

**파일**: `apps/wowa/lib/app/routes/app_pages.dart`

**필수 구현**:
- LoginView, LoginBinding import 경로 변경 (`package:auth_sdk/auth_sdk.dart`에서 가져오기)
- login 모듈 import 제거

**검증 기준**:
- [ ] import 'package:auth_sdk/auth_sdk.dart'; 추가됨
- [ ] LoginView, LoginBinding이 auth_sdk에서 import됨
- [ ] app/modules/login/ import 제거됨

---

### Group 3: Junior Developer

#### 작업 3-1: login 모듈 디렉토리 삭제

**파일**: `apps/wowa/lib/app/modules/login/`

**필수 구현**:
- login 모듈 디렉토리 삭제 (controllers, views, bindings 포함)

**검증 기준**:
- [ ] `apps/wowa/lib/app/modules/login/` 디렉토리가 존재하지 않음
- [ ] wowa 앱이 auth_sdk의 LoginView/LoginController/LoginBinding 사용

---

## 검증 기준

### 기능 검증 (통합 테스트)

- [ ] wowa 앱에서 카카오 로그인 정상 동작 (토큰 저장, 홈 화면 이동)
- [ ] wowa 앱에서 네이버 로그인 정상 동작
- [ ] wowa 앱에서 애플 로그인 정상 동작
- [ ] wowa 앱에서 구글 로그인 정상 동작
- [ ] 로그인 성공 시 `/home` 라우트로 이동 (wowa 앱 홈 화면)
- [ ] 둘러보기 버튼 클릭 시 `/home` 라우트로 이동
- [ ] 로딩 상태 표시 (로그인 중 해당 버튼만 스피너)
- [ ] 에러 처리 (네트워크 오류, 계정 충돌, 사용자 취소) 정상 동작
- [ ] 계정 충돌 모달 표시 (SketchModal)

### 아키텍처 검증

- [ ] auth_sdk 패키지가 wowa 앱에 의존하지 않음 (import 검증)
- [ ] LoginController, LoginView, LoginBinding이 `packages/auth_sdk/lib/src/ui/`에 위치
- [ ] wowa 앱의 `app/modules/login/` 디렉토리가 삭제됨
- [ ] AuthSdk.initialize()가 AuthSdkConfig 객체로 호출됨
- [ ] 프로바이더 등록이 AuthSdk.initialize()에서 처리됨 (LoginBinding에 없음)

### GetX 패턴 검증

- [ ] LoginController가 GetxController 상속
- [ ] LoginView가 GetView<LoginController> 상속
- [ ] LoginBinding이 Bindings 구현
- [ ] 반응형 상태(.obs)가 Obx로 바인딩됨
- [ ] const 생성자 사용 (SizedBox, Text 등)

### 코드 품질 검증

- [ ] 모든 주석이 한글로 작성됨 (기술 용어 제외)
- [ ] import 순서가 가이드라인 준수 (flutter → package → relative)
- [ ] 에러 로그가 Logger.error()로 기록됨
- [ ] 민감 정보(토큰)가 로그에 기록되지 않음

---

## 참고 자료

### 설계 문서

- **User Story**: `docs/wowa/wowa-login/user-story.md`
- **Design Spec**: `docs/wowa/wowa-login/mobile-design-spec.md`
- **Technical Brief**: `docs/wowa/wowa-login/mobile-brief.md`

### 가이드 문서

- **GetX Best Practices**: `.claude/guide/mobile/getx_best_practices.md`
- **Directory Structure**: `.claude/guide/mobile/directory_structure.md`
- **Common Patterns**: `.claude/guide/mobile/common_patterns.md`
- **Design System**: `.claude/guide/mobile/design_system.md`
- **Error Handling**: `.claude/guide/mobile/error_handling.md`

### 기존 코드

- **현재 LoginView**: `apps/wowa/lib/app/modules/login/views/login_view.dart`
- **현재 LoginController**: `apps/wowa/lib/app/modules/login/controllers/login_controller.dart`
- **현재 LoginBinding**: `apps/wowa/lib/app/modules/login/bindings/login_binding.dart`
- **AuthSdk**: `packages/auth_sdk/lib/src/auth_sdk.dart`

---

**작성일**: 2026-02-10
**CTO**: Claude Code
**다음 단계**: Task 도구로 flutter-developer 서브에이전트 호출하여 Group 1 → Group 2 → Group 3 순차 실행
