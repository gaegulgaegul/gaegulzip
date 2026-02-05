# 설계 승인 (Design Approval) - 소셜 로그인 SDK

## ⓪ 플랫폼 라우팅 결정 (Platform Routing Decision)

### 결정: **Mobile**

**판단 근거**:
- **SDK는 항상 모바일(Flutter) 패키지만 해당** (프로젝트 컨벤션)
- **서버는 모듈로 유지** — `apps/server/src/modules/auth/`는 그대로 두고 SDK로 추출하지 않음
- 모바일 SDK가 서버 API를 호출하는 구조

**기존 모바일 구현** (`apps/mobile/apps/wowa/lib/app/`):
- 4개 소셜 로그인 프로바이더 구현체 (Kakao, Naver, Google, Apple)
- AuthStateService (인증 상태 관리)
- AuthInterceptor (토큰 자동 갱신)
- auth_api_service.dart (서버 API 통신)
- API 모델 (Freezed/json_serializable)

**작업 특성**: WOWA 앱에 종속된 모바일 인증 코드를 독립 Flutter 패키지로 추출 (Extraction)

---

## ① 패키지 구조 (Package Structure)

### 모바일 SDK 위치
```
gaegulzip/
├── apps/
│   └── mobile/
│       ├── packages/
│       │   ├── core/                 # 기존 유지
│       │   ├── api/                  # 기존 유지
│       │   ├── design_system/        # 기존 유지
│       │   └── auth_sdk/             # 새 패키지
│       │       ├── pubspec.yaml      # Flutter 패키지
│       │       ├── lib/
│       │       │   ├── auth_sdk.dart # Public API
│       │       │   └── src/
│       │       │       ├── providers/          # 소셜 로그인 프로바이더
│       │       │       │   ├── social_login_provider.dart  # 추상 클래스
│       │       │       │   ├── kakao_login_provider.dart
│       │       │       │   ├── naver_login_provider.dart
│       │       │       │   ├── google_login_provider.dart
│       │       │       │   └── apple_login_provider.dart
│       │       │       ├── services/           # 인증 상태/API 통신
│       │       │       │   ├── auth_state_service.dart
│       │       │       │   └── auth_api_service.dart
│       │       │       ├── interceptors/       # 토큰 자동 갱신
│       │       │       │   └── auth_interceptor.dart
│       │       │       ├── models/             # API 모델 (Freezed)
│       │       │       │   ├── login_request.dart
│       │       │       │   ├── login_response.dart
│       │       │       │   ├── refresh_request.dart
│       │       │       │   ├── refresh_response.dart
│       │       │       │   └── user_model.dart
│       │       │       └── widgets/            # UI 위젯 (선택적)
│       │       │           └── social_login_button.dart
│       │       └── README.md         # 사용법, 통합 가이드
│       └── apps/wowa/
│           ├── pubspec.yaml          # dependencies: auth_sdk
│           └── lib/app/
│               ├── services/social_login/      # 제거 → SDK로 대체
│               ├── services/auth_state_service.dart  # 제거 → SDK로 대체
│               └── interceptors/auth_interceptor.dart  # 제거 → SDK로 대체
```

### melos.yaml 업데이트
```yaml
packages:
  - packages/**                # packages/auth_sdk 포함
  - apps/**
```

---

## ② 아키텍처 접근 방식 (Architecture Approach)

### 서버 (변경 없음)
- `apps/server/src/modules/auth/` 모듈 그대로 유지
- SDK 추출 대상 아님

### 모바일 SDK 설계 원칙
1. **GetX Pattern 유지**: Controller/View/Binding 분리 패턴
2. **core/api 의존성**: 기존 패키지 활용, design_system은 선택적
3. **Stateless API**: AuthSdk.initialize() 후 static 메서드로 사용
4. **Provider Pattern**: 4개 소셜 로그인 프로바이더를 추상화
5. **Interceptor 분리**: AuthInterceptor를 SDK 내부로 이동, Dio 설정 자동화

#### Public API 설계
```dart
// packages/auth_sdk/lib/auth_sdk.dart
class AuthSdk {
  static Future<void> initialize({
    required String appCode,
    required String apiBaseUrl,
    required Map<SocialProvider, ProviderConfig> providers,
    SecureStorageService? secureStorage,
  });

  static Future<LoginResponse> login(SocialProvider provider);
  static Future<void> logout();
  static Future<bool> isAuthenticated();
  static AuthStateService get authState;
}

// 프로바이더 설정
enum SocialProvider { kakao, naver, google, apple }

class ProviderConfig {
  final String? clientId;      // 네이티브 SDK 설정용
  final String? clientSecret;  // iOS 앱 전용
}
```

### 의존성 그래프
```
apps/wowa → packages/auth_sdk → packages/api → packages/core
                             → kakao_flutter_sdk
                             → flutter_naver_login
                             → google_sign_in
                             → sign_in_with_apple
```

---

## ③ 작업 할당 (Task Allocation)

### 작업 순서 (Sequential Execution)

SDK 추출 작업은 기존 코드를 이동하는 리팩토링입니다.

#### Phase 1: 모바일 SDK 추출 (Mobile SDK Extraction)
**담당**: Flutter Developer (1명)

1. **패키지 초기화** (30분)
   - [ ] `apps/mobile/packages/auth_sdk` 디렉토리 생성
   - [ ] pubspec.yaml 작성 (name: auth_sdk, dependencies: core, api, kakao_flutter_sdk 등)
   - [ ] lib/auth_sdk.dart (public API) 생성
   - [ ] melos bootstrap 실행

2. **프로바이더 추출** (1.5시간)
   - [ ] apps/wowa/lib/app/services/social_login/ 코드를 packages/auth_sdk/lib/src/providers/로 이동
   - [ ] SocialLoginProvider 추상 클래스 유지
   - [ ] 4개 프로바이더 구현체 이동 (Kakao, Naver, Google, Apple)

3. **인증 서비스 추출** (1.5시간)
   - [ ] apps/wowa/lib/app/services/auth_state_service.dart → packages/auth_sdk/lib/src/services/로 이동
   - [ ] apps/mobile/packages/api/lib/src/services/auth_api_service.dart → packages/auth_sdk/lib/src/services/로 이동
   - [ ] apps/wowa/lib/app/interceptors/auth_interceptor.dart → packages/auth_sdk/lib/src/interceptors/로 이동

4. **API 모델 추출** (30분)
   - [ ] apps/mobile/packages/api/lib/src/models/auth/ → packages/auth_sdk/lib/src/models/로 이동
   - [ ] Freezed 코드 생성 실행 (melos generate)

5. **AuthSdk 클래스 작성** (1시간)
   - [ ] lib/auth_sdk.dart에서 AuthSdk.initialize(), login(), logout() 구현
   - [ ] 하드코딩된 'wowa', 라우트 경로 제거
   - [ ] appCode, apiBaseUrl을 config로 주입받도록 수정

6. **WOWA 앱 리팩토링** (1시간)
   - [ ] apps/wowa/pubspec.yaml에 dependencies: { auth_sdk: { path: ../../packages/auth_sdk } } 추가
   - [ ] main.dart에서 AuthSdk.initialize(appCode: 'wowa', apiBaseUrl: '...') 호출
   - [ ] 기존 social_login/, auth_state_service.dart, auth_interceptor.dart 제거
   - [ ] Import 경로를 package:auth_sdk/auth_sdk.dart로 변경
   - [ ] melos bootstrap 실행
   - [ ] flutter analyze 성공 확인

7. **문서 작성** (30분)
   - [ ] packages/auth_sdk/README.md 작성 (Flutter 패키지 사용법)
   - [ ] 설치, 초기화, 로그인 버튼 예제 코드 포함

**예상 소요 시간**: 6.5시간

#### Phase 2: 통합 문서 작성 (Integration Guide)

1. **통합 가이드 작성**
   - [ ] docs/social-login-sdk/integration-guide.md 생성
   - [ ] 섹션 구성:
     - 개요 (SDK가 해결하는 문제)
     - 모바일 SDK 설치 (pubspec.yaml, melos)
     - 모바일 초기화 (AuthSdk.initialize 예제)
     - 로그인 버튼 추가 (UI 위젯 예제)
     - 서버 API 연동 설명
     - 트러블슈팅 (FAQ)

---

## ④ 위험 평가 (Risk Assessment)

### 중위험 (Medium Risk) - 주의 필요

| 위험 | 영향 | 완화 전략 |
|------|------|---------|
| **melos bootstrap 실패** | Flutter 패키지 인식 안 됨 | melos.yaml packages 경로 확인, melos clean && melos bootstrap |
| **Freezed 코드 생성 오류** | API 모델 타입 오류 | melos generate 실행, .g.dart/.freezed.dart 파일 생성 확인 |
| **GetX Binding 누락** | Controller not found 에러 | SDK에서 Binding 제공, Get.lazyPut으로 의존성 주입 |
| **Import 경로 깨짐** | WOWA 앱 빌드 실패 | SDK 이동 후 import를 package:auth_sdk/auth_sdk.dart로 일괄 변경 |

### 저위험 (Low Risk) - 모니터링

| 위험 | 영향 | 완화 전략 |
|------|------|---------|
| **SDK 버전 불일치** | 호환성 문제 | semantic versioning 사용 |
| **문서 불충분** | 신규 개발자 혼란 | integration-guide.md에 단계별 예제 포함 |

---

## ⑤ 승인 체크리스트 (Approval Checklist)

### 모바일 SDK 설계 검증
- [x] GetX 패턴: Controller, View, Binding 분리 유지
- [x] 모노레포 구조: core → api/design_system ← auth_sdk ← wowa
- [x] 디렉토리 구조: packages/auth_sdk/lib/src/providers|services|interceptors|models
- [x] const 최적화, Obx 범위 최소화 (기존 코드 이동)
- [x] Freezed/json_serializable 패턴 유지
- [x] 하드코딩 제거 (AuthSdk.initialize로 config 주입)

### 아키텍처 일관성
- [x] CLAUDE.md 모바일 가이드 준수 (melos, GetX, core/api 의존성)
- [x] SDK 컨벤션 준수 (모바일만 SDK, 서버는 모듈 유지)
- [x] Over-engineering 방지 (기존 코드 이동, 새 기능 추가 안 함)
- [x] 역방향 호환성 (WOWA 앱 기능 100% 유지)

---

## ⑥ 다음 단계 (Next Steps)

1. **사용자 승인 대기**: 이 설계 승인 문서를 검토하고 승인
2. **작업 시작**: Phase 1 (모바일 SDK 추출)
3. **문서화**: Phase 2 통합 가이드 작성

---

**승인자**: CTO (Platform: Mobile)
**작성일**: 2026-02-04
