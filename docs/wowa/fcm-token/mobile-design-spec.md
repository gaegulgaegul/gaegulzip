# UI/UX 디자인 명세: FCM 토큰 저장

## 개요

FCM 토큰 저장 기능은 **대부분 백그라운드에서 자동 처리**되는 기능입니다. 사용자에게 직접 보이는 UI는 매우 제한적이며, 핵심은 **투명하고 조용한 사용자 경험**입니다. 로그인 시 자동으로 푸시 알림 권한을 요청하고, 허용 시 토큰을 서버에 등록하며, 거부 시에도 앱의 다른 기능은 정상적으로 동작합니다.

**디자인 목표:**
- 사용자에게 방해가 되지 않는 자연스러운 흐름
- 권한 거부 시에도 앱 사용에 제약 없음
- 에러 발생 시 조용한 실패 (사용자에게 표시하지 않음)
- 기존 LoginView와 완벽한 통합

---

## 화면 구조

### 기존 화면 활용: LoginView

FCM 토큰 등록은 **기존 LoginView 화면에서 로그인 성공 직후 백그라운드로 처리**됩니다. 새로운 화면을 추가하지 않습니다.

#### 화면 흐름

```
LoginView
└── Scaffold
    └── SafeArea
        └── Center
            └── Padding (24, 32)
                └── Column
                    ├── SizedBox(height: 64)
                    ├── Text ("로그인") — 타이틀
                    ├── SizedBox(height: 8)
                    ├── Text ("소셜 계정으로...") — 부제목
                    ├── SizedBox(height: 48)
                    │
                    ├── Obx → SocialLoginButton (카카오)
                    │   └── isLoading: controller.isKakaoLoading
                    │
                    ├── SizedBox(height: 16)
                    ├── Obx → SocialLoginButton (네이버)
                    ├── SizedBox(height: 16)
                    ├── Obx → SocialLoginButton (애플)
                    ├── SizedBox(height: 16)
                    ├── Obx → SocialLoginButton (구글)
                    │
                    ├── Spacer()
                    └── TextButton ("둘러보기")
```

**LoginController의 로그인 플로우 확장:**

```dart
Future<void> _handleSocialLogin({...}) async {
  try {
    loadingState.value = true;

    // 1. 기존: AuthSdk를 통한 소셜 로그인
    final loginResponse = await AuthSdk.login(provider);

    // 2. 신규: FCM 토큰 등록 (비동기, 논블로킹 처리)
    // AuthSdkConfig.onPostLogin 콜백으로 변경됨 (formerly blocking _registerFcmToken 호출)
    // 실패해도 홈 이동에 영향 없음 (조용한 실패 정책)
    await _registerFcmToken(); // await 유지하지만 타임아웃/실패 시 Exception throw 안 함

    // 3. 기존: 홈 화면으로 이동
    Get.offAllNamed(Routes.HOME);
  } on AuthException catch (e) {
    // 기존 에러 처리...
  } finally {
    loadingState.value = false;
  }
}
```

**설계 변경 히스토리:**
- **기존**: `_registerFcmToken()`이 blocking 콜백으로 작동 (로그인 성공 후 토큰 등록 완료까지 대기)
- **현재**: `AuthSdkConfig.onPostLogin` 콜백으로 변경 (비동기, 타임아웃/실패 시에도 홈 이동 지연 없음)
- **효과**: 로그인 후 홈 화면 이동이 FCM 토큰 등록 결과에 영향받지 않음

---

## 사용자 플로우 다이어그램

### 시나리오 1: 최초 로그인 + 권한 허용 (정상 플로우)

```
[LoginView]
    ↓ 사용자가 "카카오로 로그인" 탭
    ↓
[카카오 SDK] → OAuth 인증 → 인가 코드 획득
    ↓
[서버 API] → POST /api/auth/oauth/login → JWT 토큰 + 유저 정보 반환
    ↓
[SecureStorage] → 토큰 저장 (access_token, refresh_token, user_id 등)
    ↓
[iOS 시스템] → 푸시 알림 권한 다이얼로그 표시
    ↓ 사용자가 "허용" 탭
    ↓
[PushService] → FCM 토큰 획득
    ↓
[서버 API] → POST /push/devices → 토큰 등록 (백그라운드)
    ↓ 성공
    ↓
[Get.offAllNamed(Routes.HOME)] → 홈 화면 이동
```

**UI 상태:**
- 로그인 버튼: `isLoading: true` → 버튼 내 스피너 표시
- 권한 다이얼로그: iOS/Android 시스템 UI (커스텀 불가)
- 에러 표시: 없음 (토큰 등록 실패해도 조용히 실패)

---

### 시나리오 2: 권한 거부 (대안 플로우)

```
[LoginView]
    ↓ 사용자가 "네이버로 로그인" 탭
    ↓
[네이버 SDK] → OAuth 인증 → 인가 코드 획득
    ↓
[서버 API] → 로그인 성공 → 토큰 저장
    ↓
[iOS 시스템] → 푸시 알림 권한 다이얼로그 표시
    ↓ 사용자가 "허용 안 함" 탭
    ↓
[PushService] → 권한 거부 감지 → 토큰 등록 시도하지 않음
    ↓
[Get.offAllNamed(Routes.HOME)] → 홈 화면 이동 (정상 동작)
```

**UI 상태:**
- 로그인 버튼: `isLoading: true` → 스피너 표시
- 권한 거부 후: **에러 표시 없음**, 앱 정상 동작
- 스낵바/모달: 표시하지 않음 (조용한 실패)

---

### 시나리오 3: 토큰 등록 실패 (네트워크 오류)

```
[LoginView]
    ↓ 사용자가 "애플로 로그인" 탭
    ↓
[애플 SDK] → OAuth 인증 → 인가 코드 획득
    ↓
[서버 API] → 로그인 성공 → 토큰 저장
    ↓
[iOS 시스템] → 권한 허용
    ↓
[PushService] → FCM 토큰 획득
    ↓
[서버 API] → POST /push/devices → 네트워크 오류 (Timeout)
    ↓
[Logger.error(...)] → 로그만 기록
    ↓
[Get.offAllNamed(Routes.HOME)] → 홈 화면 이동 (정상 동작)
```

**UI 상태:**
- 에러 표시: **없음** (사용자에게 표시하지 않음)
- 로그: `Logger.error('FCM 토큰 등록 실패: 네트워크 오류')`
- 백그라운드 재시도: 다음 앱 실행 시 자동 재시도

---

## 상태 전이 다이어그램

```
┌─────────────────┐
│  LoginView      │
│  (로그인 대기)   │
└────────┬────────┘
         │
         │ 사용자가 로그인 버튼 탭
         ↓
┌─────────────────┐
│  로그인 중       │ ← isKakaoLoading.value = true
│  (버튼 스피너)   │
└────────┬────────┘
         │
         │ OAuth 인증 성공
         ↓
┌─────────────────┐
│  권한 요청       │ ← iOS/Android 시스템 다이얼로그
│  (시스템 UI)     │
└────┬───────┬────┘
     │       │
 허용 │       │ 거부
     │       │
     ↓       ↓
┌────────┐ ┌────────────────┐
│ FCM    │ │ 토큰 등록      │
│ 토큰   │ │ 건너뜀         │
│ 등록   │ │ (조용히 실패)  │
└────┬───┘ └────────┬───────┘
     │              │
     │ 성공/실패    │
     │ (조용히)     │
     ↓              ↓
┌───────────────────┐
│  홈 화면 이동      │ ← Get.offAllNamed(Routes.HOME)
│  (Routes.HOME)     │
└───────────────────┘
```

**핵심 원칙:**
- 모든 상태 전이는 사용자에게 투명 (에러 표시 없음)
- 권한 거부 또는 등록 실패 시에도 앱은 정상 동작
- 로딩 상태는 로그인 버튼의 스피너로만 표시

---

## 인터랙션 상태

### 1. SocialLoginButton 로딩 상태

**LoginView에서 이미 구현됨:**

```dart
Obx(() => SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  size: SocialLoginButtonSize.large,
  isLoading: controller.isKakaoLoading.value, // ← .obs 반응형
  onPressed: controller.handleKakaoLogin,
))
```

**상태 변화:**
- `isKakaoLoading: false` → 기본 상태 (버튼 활성화)
- `isKakaoLoading: true` → 로딩 중 (버튼 내 CircularProgressIndicator 표시, 버튼 비활성화)
- 로그인 성공/실패 후 → `false`로 복귀

**디자인:**
- SocialLoginButton의 기본 로딩 UI 사용 (이미 구현됨)
- 스피너 색상: 각 플랫폼 브랜드 컬러 대비색
- 스피너 크기: 16x16 (버튼 내부)

---

### 2. 권한 요청 다이얼로그 (시스템 UI)

**iOS:**
```
┌──────────────────────────────────┐
│  "wowa"에서 알림을 보내려고      │
│  합니다                           │
│                                   │
│  알림에는 사운드, 배지 및 배너가  │
│  포함될 수 있습니다.              │
│                                   │
│  [ 허용 안 함 ]  [ 허용 ]         │
└──────────────────────────────────┘
```

**Android:**
```
┌──────────────────────────────────┐
│  wowa에서 알림을 보내도록 허용   │
│  하시겠습니까?                    │
│                                   │
│  [ 차단 ]  [ 허용 ]               │
└──────────────────────────────────┘
```

**특징:**
- 시스템 기본 다이얼로그 (커스텀 불가)
- 앱 내 UI 컨트롤 없음
- 사용자 선택에 따라 `PushService`가 자동으로 권한 상태 감지

---

### 3. 에러 처리: 조용한 실패 (Silent Failure)

**에러 발생 시 UI 동작:**

| 에러 유형 | 사용자 UI | 개발자 로그 |
|----------|----------|------------|
| 권한 거부 | **표시 없음** (홈 이동) | `Logger.warn('푸시 알림 권한 거부됨')` |
| 네트워크 오류 | **표시 없음** (홈 이동) | `Logger.error('FCM 토큰 등록 실패: 네트워크 오류')` |
| 서버 5xx 오류 | **표시 없음** (홈 이동) | `Logger.error('FCM 토큰 등록 실패: 서버 오류')` |
| FCM 토큰 획득 실패 | **표시 없음** (홈 이동) | `Logger.error('FCM 토큰 획득 실패')` |

**비교: 로그인 에러는 표시함**

LoginController에서 이미 구현된 패턴:

```dart
on AuthException catch (e) {
  if (e.code == 'user_cancelled') {
    return; // 조용히 실패
  }
  if (e.code == 'account_conflict') {
    _showAccountLinkModal(existingProvider); // 모달 표시
    return;
  }
  _showErrorSnackbar('로그인 실패', e.message); // 스낵바 표시
}
```

**FCM 토큰 등록은 다름:**
- 로그인은 사용자 액션 → 에러 표시 필요
- FCM 토큰은 백그라운드 작업 → 에러 표시하지 않음

---

## 비주얼 디자인

### 색상 팔레트 (기존 LoginView 스타일 유지)

```dart
// 타이틀
TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
)

// 부제목
TextStyle(
  fontSize: 14,
  color: Colors.grey.shade600,
)

// 둘러보기 버튼
TextButton(
  child: Text('둘러보기'), // Material 기본 색상
)

// SocialLoginButton
// 각 플랫폼별 브랜드 컬러 (design_system 패키지에서 제공)
```

**FCM 관련 새 UI 없음** → 기존 LoginView 색상 그대로 사용

---

### 타이포그래피 (Material Design 기본)

LoginView는 Material Design 기본 타이포그래피 사용:

| 요소 | 스타일 | 크기 | 굵기 | 색상 |
|------|--------|------|------|------|
| 타이틀 ("로그인") | Custom | 30px | bold | Colors.black87 |
| 부제목 ("소셜 계정으로...") | Custom | 14px | regular | Colors.grey.shade600 |
| 버튼 텍스트 | SocialLoginButton | 플랫폼별 | 플랫폼별 | 플랫폼별 |

**FCM 관련 새 텍스트 없음**

---

### 스페이싱 시스템 (기존 LoginView 유지)

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  child: Column(
    children: [
      const SizedBox(height: 64),  // 상단 여백
      _buildTitle(),
      const SizedBox(height: 8),   // 타이틀 - 부제목 간격
      _buildSubtitle(),
      const SizedBox(height: 48),  // 부제목 - 버튼 그룹 간격

      // 버튼들
      SocialLoginButton(...),
      const SizedBox(height: 16),  // 버튼 간 간격
      SocialLoginButton(...),
      const SizedBox(height: 16),
      SocialLoginButton(...),
      const SizedBox(height: 16),
      SocialLoginButton(...),

      const Spacer(),              // 하단 푸시
      TextButton(...),             // 둘러보기 버튼
    ],
  ),
)
```

**FCM 관련 UI 추가 없음** → 스페이싱 변경 없음

---

## 애니메이션

### 1. 로그인 버튼 로딩 상태 애니메이션

**SocialLoginButton의 기본 애니메이션 사용:**

- `isLoading: false → true` 전환 시:
  - 텍스트 페이드아웃 (150ms)
  - CircularProgressIndicator 페이드인 (150ms)
  - 버튼 비활성화 (터치 불가)

- `isLoading: true → false` 전환 시:
  - 스피너 페이드아웃 (150ms)
  - 텍스트 페이드인 (150ms)
  - 버튼 활성화

**Duration:** 150ms (Material Design 기본)
**Curve:** Curves.easeInOut

---

### 2. 화면 전환 애니메이션

**LoginView → HomeView 전환:**

```dart
Get.offAllNamed(Routes.HOME);
```

**app_pages.dart 설정 (이미 구현됨):**

```dart
GetPage(
  name: Routes.HOME,
  page: () => HomeView(),
  binding: HomeBinding(),
  transition: Transition.fadeIn, // 부드러운 페이드 전환
  transitionDuration: Duration(milliseconds: 300),
),
```

**Duration:** 300ms
**Transition:** fadeIn (기존 라우트 설정)

---

## 로깅 전략

### LoginController 내 FCM 토큰 등록 로그

```dart
/// FCM 토큰 서버 등록 (백그라운드 자동 처리)
Future<void> _registerFcmToken() async {
  try {
    // 1. 푸시 알림 권한 확인
    final hasPermission = await PushService.instance.hasPermission();

    if (!hasPermission) {
      Logger.warn('푸시 알림 권한 거부됨 - FCM 토큰 등록 건너뜀');
      return; // 조용히 실패
    }

    // 2. FCM 토큰 획득
    final token = await PushService.instance.getToken();

    if (token == null) {
      Logger.error('FCM 토큰 획득 실패 - null 반환');
      return; // 조용히 실패
    }

    Logger.info('FCM 토큰 획득 성공: ${token.substring(0, 20)}...');

    // 3. 서버에 토큰 등록
    await PushService.instance.registerDeviceToken(token);

    Logger.info('FCM 토큰 서버 등록 성공');
  } on NetworkException catch (e) {
    Logger.error('FCM 토큰 등록 실패: 네트워크 오류 - ${e.message}', error: e);
    // 조용히 실패 - UI에 표시하지 않음
  } catch (e) {
    Logger.error('FCM 토큰 등록 실패: 예기치 않은 오류', error: e);
    // 조용히 실패
  }
}
```

**로그 레벨:**
- `Logger.info`: 정상 플로우 (토큰 획득, 등록 성공)
- `Logger.warn`: 권한 거부 (사용자 선택)
- `Logger.error`: 에러 발생 (네트워크, 서버, 예외)

**로그 출력 예시:**

```
[INFO] FCM 토큰 획득 성공: eM9FZXJwZjR3a3F5cGY...
[INFO] FCM 토큰 서버 등록 성공
```

```
[WARN] 푸시 알림 권한 거부됨 - FCM 토큰 등록 건너뜀
```

```
[ERROR] FCM 토큰 등록 실패: 네트워크 오류 - 연결 시간 초과
```

---

## 접근성 (Accessibility)

### 1. 스크린 리더 지원

**기존 LoginView 요소:**

```dart
// SocialLoginButton은 이미 Semantics 지원
SocialLoginButton(
  platform: SocialLoginPlatform.kakao,
  // Semantics: "카카오 로그인 버튼"
  onPressed: controller.handleKakaoLogin,
)
```

**FCM 관련 새 UI 없음** → 접근성 변경 없음

---

### 2. 로딩 상태 안내

**SocialLoginButton이 이미 지원:**

- `isLoading: true` 시:
  - Semantics: "카카오 로그인 중..."
  - CircularProgressIndicator가 스크린 리더에 "로딩 중" 안내

---

## Design System 컴포넌트 활용

### 기존 컴포넌트 사용 (변경 없음)

| 컴포넌트 | 용도 | 위치 |
|---------|------|------|
| `SocialLoginButton` | 소셜 로그인 버튼 (4개 플랫폼) | `design_system` 패키지 |
| `SketchModal` | 계정 충돌 다이얼로그 (기존 로직) | `design_system` 패키지 |

**FCM 관련 새 UI 컴포넌트 없음**

---

### 새로운 컴포넌트 필요 여부

**없음** — FCM 토큰 등록은 백그라운드 자동 처리, UI 추가 불필요

---

## 사용자 경험 플로우 정리

### 1. 로그인 → 권한 → 토큰 등록 → 홈 이동

**타임라인 (정상 플로우):**

```
T+0s:  사용자가 "카카오로 로그인" 버튼 탭
T+0s:  버튼 로딩 상태 (스피너 표시)
T+1s:  카카오 SDK OAuth 인증 (외부 브라우저 또는 앱)
T+3s:  인가 코드 획득 → 서버 API 호출 (/api/auth/oauth/login)
T+4s:  JWT 토큰 저장 → SecureStorage
T+4s:  iOS 시스템 권한 다이얼로그 표시
T+5s:  사용자가 "허용" 탭
T+5s:  FCM 토큰 획득 (백그라운드)
T+6s:  서버 API 호출 (/push/devices) - 백그라운드
T+7s:  홈 화면 이동 (Get.offAllNamed)
```

**사용자가 보는 것:**
- 0~7초: 로그인 버튼 스피너
- 4~5초: 시스템 권한 다이얼로그
- 7초: 홈 화면 표시

**사용자가 보지 못하는 것:**
- FCM 토큰 획득 과정
- 서버 토큰 등록 API 호출
- 등록 성공/실패 여부

---

### 2. 권한 거부 시 UX 전략

**전략: "조용히 실패, 앱은 정상 동작"**

```
사용자가 권한 거부
    ↓
PushService.hasPermission() → false
    ↓
Logger.warn('푸시 알림 권한 거부됨')
    ↓
토큰 등록 건너뜀
    ↓
홈 화면 이동 (정상)
```

**UI:**
- 에러 표시 없음
- 스낵바 없음
- 모달 없음
- 홈 화면에서 모든 기능 사용 가능

**향후 확장 (Phase 2):**
- 설정 화면에 "푸시 알림" 섹션 추가
- 권한 거부 상태 표시 + "설정에서 활성화" 버튼

---

### 3. 네트워크 오류 시 UX 전략

**전략: "백그라운드 재시도, 사용자에게 표시하지 않음"**

```
FCM 토큰 등록 API 호출
    ↓
NetworkException (Timeout)
    ↓
Logger.error('FCM 토큰 등록 실패: 네트워크 오류')
    ↓
홈 화면 이동 (정상)
    ↓
다음 앱 실행 시 자동 재시도
```

**UI:**
- 에러 표시 없음
- 사용자는 네트워크 오류를 모름
- 앱 정상 동작

**타임아웃 처리 (조용한 실패 패턴):**

FCM 토큰 등록은 `PushService`의 조용한 실패 정책을 따릅니다:

```dart
// PushService.registerDeviceTokenToServer()
Future<bool> registerDeviceTokenToServer() async {
  try {
    // 1. API 호출 (타임아웃 없음, Dio 기본 타임아웃 사용)
    // Dio의 기본 타임아웃: 30초
    // 30초 이상 걸리면 DioException throw
    await apiClient.registerDevice(
      DeviceTokenRequest(
        token: token,
        platform: platform,
        deviceId: deviceId,
      ),
    );

    Logger.info('FCM 토큰 서버 등록 성공');
    return true;
  } on DioException catch (e) {
    // 네트워크 타임아웃, 연결 오류, HTTP 오류 모두 catch
    Logger.error('FCM 토큰 등록 실패 (네트워크 오류)', error: e);
    return false; // 예외 throw 안 함, 조용히 실패
  } catch (e, stackTrace) {
    Logger.error('FCM 토큰 등록 실패 (예외)', error: e, stackTrace: stackTrace);
    return false;
  }
}
```

**백그라운드 재시도 메커니즘:**

1. **첫 로그인**: `LoginController._registerFcmToken()` 호출
   - 성공: 등록 완료
   - 실패 (타임아웃 포함): 조용히 실패, 홈 화면 이동

2. **토큰 갱신**: `PushService.onTokenRefresh` 리스너에서 자동 호출
   - 성공: 새 토큰 자동 등록
   - 실패: 다음 앱 실행 시 재시도

3. **다음 앱 실행**: `PushService.initialize()`에서 자동 재시도
   - 이전에 등록되지 않은 토큰이 있으면 자동 재등록 시도
   - `main.dart`의 `ever(pushService.deviceToken, ...)` 콜백에서 감지 후 등록

**결과:**
- 타임아웃 발생 시에도 사용자는 앱 사용 가능 (홈 화면 즉시 이동)
- 네트워크 복구 시 다음 토큰 갱신 또는 다음 앱 실행 시 자동 재시도
- 재시도 횟수 제한 없음 (매 앱 실행 시 확인)

---

## 엣지 케이스 처리

### 1. 권한 다이얼로그 무시 (사용자가 닫음)

**동작:**
- iOS: 권한 다이얼로그를 닫으면 "거부"로 간주
- `PushService.hasPermission()` → false 반환
- 토큰 등록 건너뜀 → 홈 화면 이동

**UI:** 에러 표시 없음

---

### 2. FCM 토큰이 null 반환

**원인:**
- iOS에서 APNS 토큰이 아직 준비되지 않음
- FCM SDK 초기화 실패

**동작:**
```dart
final token = await PushService.instance.getToken();

if (token == null) {
  Logger.error('FCM 토큰 획득 실패 - null 반환');
  return; // 조용히 실패
}
```

**UI:** 에러 표시 없음
**재시도:** 다음 앱 실행 시 자동 재시도

---

### 3. 서버 등록 실패 (401 Unauthorized)

**원인:** 인증 토큰 만료 (매우 드묾 - 로그인 직후이므로)

**동작:**
```dart
on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    Logger.error('FCM 토큰 등록 실패: 인증 실패 (401)');
    // 토큰 갱신 시도 (AuthInterceptor가 자동 처리)
    return; // 조용히 실패
  }
}
```

**UI:** 에러 표시 없음
**재시도:** AuthInterceptor가 자동으로 토큰 갱신 후 재시도

---

### 4. 빠른 로그인/로그아웃 반복

**시나리오:**
- 사용자가 로그인 → 즉시 로그아웃 → 다시 로그인

**동작:**
- 로그인 시: FCM 토큰 등록
- 로그아웃 시: 토큰 비활성화 (DELETE /push/devices/:id)
- 재로그인 시: 토큰 재등록 (Upsert 방식)

**서버 처리:**
- 동일한 토큰이면 업데이트 (isActive = true)
- 새 토큰이면 새로 생성

**UI:** 모든 과정이 백그라운드, 사용자는 모름

---

## 기술적 제약사항

### 1. PushService 초기화

**main.dart에서 이미 초기화됨:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // PushService 초기화
  await PushService.instance.initialize();

  runApp(MyApp());
}
```

**LoginController는 초기화된 PushService를 사용:**

```dart
final token = await PushService.instance.getToken();
```

---

### 2. 플랫폼별 설정

**iOS:**
- `GoogleService-Info.plist` 필요 (Firebase 프로젝트)
- `Info.plist`에 백그라운드 모드 권한 추가 (푸시 알림)

**Android:**
- `google-services.json` 필요
- `AndroidManifest.xml`에 권한 추가 (`POST_NOTIFICATIONS` for Android 13+)

---

### 3. 서버 API

**이미 구현됨:**
- `POST /push/devices` — 디바이스 토큰 등록 (Upsert)
- `DELETE /push/devices/:id` — 토큰 비활성화

**PushService가 API 호출:**

```dart
class PushService {
  Future<void> registerDeviceToken(String token) async {
    final response = await _dio.post('/push/devices', data: {
      'token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'deviceId': await _getDeviceId(),
    });
    // 응답 처리
  }
}
```

---

## 참고 자료

### 1. 기존 구현 참조

- **LoginView:** `apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`
- **LoginController:** `apps/mobile/apps/wowa/lib/app/modules/login/controllers/login_controller.dart`
- **PushService:** `apps/mobile/packages/push/lib/src/services/push_service.dart`

---

### 2. 디자인 시스템

- **SocialLoginButton:** `packages/design_system/lib/widgets/social_login_button.dart`
- **SketchModal:** `packages/design_system/lib/widgets/sketch_modal.dart`

---

### 3. 에러 처리

- **AuthException, NetworkException:** `packages/core/lib/src/exceptions/`
- **에러 처리 가이드:** `.claude/guide/mobile/error_handling.md`

---

### 4. 서버 API

- **서버 카탈로그:** `docs/wowa/server-catalog.md`
- **푸시 API 엔드포인트:** `POST /push/devices`, `DELETE /push/devices/:id`

---

## 요약

### UI가 거의 없는 백그라운드 기능

**사용자에게 보이는 것:**
1. 로그인 버튼 로딩 상태 (기존과 동일)
2. iOS/Android 시스템 권한 다이얼로그 (커스텀 불가)

**사용자에게 보이지 않는 것:**
1. FCM 토큰 획득
2. 서버 토큰 등록
3. 등록 성공/실패
4. 네트워크 오류

**핵심 디자인 원칙:**
- **투명성 (Transparency):** 사용자는 FCM 토큰 등록을 의식하지 않음
- **조용한 실패 (Silent Failure):** 에러 발생 시 UI에 표시하지 않음
- **정상 동작 보장 (Graceful Degradation):** 권한 거부나 등록 실패 시에도 앱은 정상 동작
- **기존 UX 유지:** LoginView의 디자인과 플로우를 그대로 유지

**다음 단계:**
- tech-lead가 LoginController의 `_registerFcmToken()` 메서드 설계
- PushService API 클라이언트 구현
- 토큰 갱신 리스너 구현
