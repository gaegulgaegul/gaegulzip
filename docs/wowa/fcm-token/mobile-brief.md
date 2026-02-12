# 기술 아키텍처 설계: FCM 토큰 저장

## 개요

FCM 토큰 저장 기능은 **기존 코드에 최소한의 변경만 추가**하여 구현합니다. 로그인 후 자동으로 푸시 알림 토큰을 서버에 등록하고, 토큰 갱신 시 자동 재등록하며, 로그아웃 시 비활성화하는 백그라운드 기능입니다.

**핵심 전략**:
- PushService는 이미 구현됨 (FCM 초기화, 토큰 획득, 리스너 등록 완료)
- PushApiClient는 이미 구현됨 (registerDevice 메서드 존재)
- AuthSdkConfig에 onPostLogin/onPreLogout 콜백 추가 (SDK 독립성 유지)
- main.dart에서 콜백으로 PushService 연동 주입
- 토큰 갱신 시 ever() 워처가 자동 서버 등록 처리

---

## 기존 코드 분석

### PushService (packages/push/lib/src/push_service.dart)

**이미 구현된 기능**:
- ✅ Firebase Messaging 초기화
- ✅ 푸시 알림 권한 요청
- ✅ FCM 토큰 획득 (`deviceToken.value`)
- ✅ 토큰 갱신 리스너 (`_messaging.onTokenRefresh.listen`)
- ✅ 포그라운드/백그라운드 메시지 처리

**현재 상태**:
```dart
class PushService extends GetxService {
  final Rxn<String> deviceToken = Rxn<String>(); // 반응형 토큰

  Future<void> initialize() async {
    // ...
    await _getDeviceToken(); // 토큰 획득

    // 토큰 갱신 리스너
    _subscriptions.add(_messaging.onTokenRefresh.listen((newToken) {
      deviceToken.value = newToken;
      Logger.info('FCM token refreshed: ${newToken.substring(0, 20)}...');
      // ⚠️ 서버 API 호출 없음 (추가 필요)
    }));
  }
}
```

### PushApiClient (packages/push/lib/src/push_api_client.dart)

**이미 구현된 기능**:
- ✅ `registerDevice(DeviceTokenRequest)` — 토큰 등록 API
- ✅ `getMyNotifications()` — 알림 목록 조회
- ✅ `getUnreadCount()` — 읽지 않은 알림 개수
- ✅ `markAsRead(int notificationId)` — 알림 읽음 처리

**누락된 기능**:
- ❌ `deactivateDeviceByToken(String token)` — 토큰 기반 비활성화 (추가 필요)

### LoginController (apps/wowa/.../login/controllers/login_controller.dart)

**현재 로그인 플로우**:
```dart
Future<void> _handleSocialLogin({...}) async {
  try {
    loadingState.value = true;

    // 1. AuthSdk를 통한 소셜 로그인
    final loginResponse = await AuthSdk.login(provider);

    // 2. ⚠️ FCM 토큰 등록 없음 (추가 필요)

    // 3. 홈 화면으로 이동
    Get.offAllNamed(Routes.HOME);
  } catch (e) {
    // 에러 처리...
  } finally {
    loadingState.value = false;
  }
}
```

### AuthRepository (packages/auth_sdk/.../auth_repository.dart)

**로그아웃 메서드**:
```dart
Future<void> logout({bool revokeAll = false}) async {
  try {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken != null) {
      await _apiService.logout(refreshToken: refreshToken, revokeAll: revokeAll);
    }
  } catch (_) {
    // 서버 로그아웃 실패해도 로컬 데이터는 삭제
  } finally {
    await _storageService.clearAll();
    // ⚠️ FCM 토큰 비활성화 없음 (추가 필요)
  }
}
```

---

## 버그 수정: 자동 로그인 시 FCM 토큰 미등록 (ever 타이밍 이슈)

### 문제

`main.dart`의 `ever(pushService.deviceToken, ...)` 리스너가 `pushService.initialize()` **이후에** 등록됨.
GetX의 `ever()`는 등록 이후의 변경만 감지하므로, `initialize()` 내부에서 설정된 초기 토큰을 놓침.

```
현재 (버그):
① pushService.initialize()    → deviceToken.value = "abc..."  (값 설정)
② ever(deviceToken, callback) → 등록 시점에 이미 값 있음       (감지 불가)
→ 자동 로그인 사용자는 FCM 토큰이 서버에 등록되지 않음
```

### 수정 방법 (Method C: 순서 이동 + 인증 조건 추가)

```
수정 후:
① ever(deviceToken, callback) → 리스너 대기 (콜백에 인증 체크 포함)
② pushService.initialize()    → deviceToken.value = "abc..."
③ callback 호출됨             → 인증됨? → registerDevice()
                                 미인증? → 스킵 (LoginController가 처리)
```

### 구현 계획

**파일: `apps/wowa/lib/main.dart`**

1. `ever` 블록을 `pushService.initialize()` **앞으로** 이동
2. 콜백 내부에 `AuthSdk.authState.isAuthenticated` 체크 추가
3. 미인증 상태면 스킵 (첫 설치 시 불필요한 401 방지)
4. 인증 상태면 `pushApiClient.registerDevice()` 호출

**변경 전**:
```dart
// 9. PushService 초기화
final pushService = Get.put(PushService(), permanent: true);
await pushService.initialize();        // ← 여기서 토큰 설정됨

// ... (콜백 등록 등) ...

// 12. ever 등록 (너무 늦음)
ever(pushService.deviceToken, (token) { ... });
```

**변경 후**:
```dart
// 9. PushService 생성 + 토큰 리스너 등록 (initialize 전에 등록)
final pushService = Get.put(PushService(), permanent: true);
final pushApiClient = Get.find<PushApiClient>();

// 디바이스 토큰 서버 등록 헬퍼 (인증 + 토큰 조건 확인)
Future<void> registerDeviceToken() async {
  final token = pushService.deviceToken.value;
  if (token == null || token.isEmpty) return;
  if (!AuthSdk.authState.isAuthenticated) return;

  await pushService.registerDeviceTokenToServer();
}

// 디바이스 토큰 변경 시 서버에 자동 등록
ever(pushService.deviceToken, (_) => registerDeviceToken());

// 인증 상태 변경 시에도 토큰 등록 시도 (로그인 후 토큰 이미 발급된 경우 대응)
ever(AuthSdk.authState.status, (status) {
  if (status == AuthStatus.authenticated) registerDeviceToken();
});

// 10. PushService 초기화 (이제 ever가 초기 토큰을 감지할 수 있음)
await pushService.initialize();
```

### 영향 범위

| 시나리오 | 변경 전 | 변경 후 |
|---------|---------|---------|
| 첫 로그인 | LoginController가 처리 (OK) | LoginController가 처리 (동일) |
| **자동 로그인** | **ever가 초기 토큰 놓침 (BUG)** | **ever가 감지 + 인증 확인 후 등록** |
| 토큰 갱신 | onTokenRefresh + ever 중복 호출 | ever만 호출 (인증 체크 포함) |
| 미인증 상태 | ever가 401 실패 | 인증 체크로 스킵 (네트워크 요청 없음) |

### 중복 리스너 정리

기존 `PushService.onTokenRefresh` 리스너의 `registerDeviceTokenToServer()` 호출과 `main.dart`의 `ever` 콜백이 토큰 갱신 시 **2회 등록 요청**을 발생시킴. `ever`에 인증 체크가 포함되었으므로, `onTokenRefresh` 내부의 `registerDeviceTokenToServer()` 호출 제거를 검토.

---

## 변경 사항 설계

### 1. PushApiClient 확장 (packages/push/)

#### 파일: `lib/src/push_api_client.dart`

**추가 메서드**:

```dart
/// 토큰으로 디바이스 비활성화 (로그아웃 시 사용)
///
/// [token] FCM 디바이스 토큰
///
/// Throws:
///   - [DioException] 네트워크 오류, HTTP 오류
Future<void> deactivateDeviceByToken(String token) async {
  await _dio.post(
    '/push/devices/deactivate',
    data: {'token': token},
  );
}
```

**설계 근거**:
- 서버 API: `POST /push/devices/deactivate` (server-brief.md 참조)
- HTTP 스펙상 DELETE body 처리가 비표준이므로 POST 채택
- 로그아웃 시 디바이스 ID를 모르는 경우 토큰으로 비활성화
- 에러 발생 시 DioException throw (호출 측에서 조용히 실패 처리)

---

### 2. PushService 확장 (packages/push/)

#### 파일: `lib/src/push_service.dart`

**추가 메서드**:

```dart
/// 서버에 디바이스 토큰 등록 (로그인 후 호출)
///
/// 권한이 허용되지 않았거나 토큰이 없으면 조용히 실패합니다.
///
/// Returns: 등록 성공 여부
Future<bool> registerDeviceTokenToServer() async {
  try {
    // 1. 토큰 확인
    final token = deviceToken.value;
    if (token == null || token.isEmpty) {
      Logger.warn('FCM 토큰이 없어 서버 등록을 건너뜁니다');
      return false;
    }

    // 2. PushApiClient 획득
    final apiClient = Get.find<PushApiClient>();

    // 3. 플랫폼 및 디바이스 ID
    final platform = Platform.isIOS ? 'ios' : 'android';
    final deviceId = await _getDeviceId(); // 선택적

    // 4. API 호출
    await apiClient.registerDevice(DeviceTokenRequest(
      token: token,
      platform: platform,
      deviceId: deviceId,
    ));

    Logger.info('FCM 토큰 서버 등록 성공: ${token.substring(0, 20)}...');
    return true;
  } on DioException catch (e) {
    Logger.error('FCM 토큰 서버 등록 실패 (네트워크 오류)', error: e);
    return false;
  } catch (e, stackTrace) {
    Logger.error('FCM 토큰 서버 등록 실패 (예외)', error: e, stackTrace: stackTrace);
    return false;
  }
}

/// 서버에서 디바이스 토큰 비활성화 (로그아웃 시 호출)
///
/// 토큰이 없거나 에러 발생 시 조용히 실패합니다.
Future<void> deactivateDeviceTokenOnServer() async {
  try {
    final token = deviceToken.value;
    if (token == null || token.isEmpty) {
      Logger.warn('FCM 토큰이 없어 비활성화를 건너뜁니다');
      return;
    }

    final apiClient = Get.find<PushApiClient>();
    await apiClient.deactivateDeviceByToken(token);

    Logger.info('FCM 토큰 서버 비활성화 성공: ${token.substring(0, 20)}...');
  } on DioException catch (e) {
    Logger.error('FCM 토큰 서버 비활성화 실패 (네트워크 오류)', error: e);
  } catch (e, stackTrace) {
    Logger.error('FCM 토큰 서버 비활성화 실패 (예외)', error: e, stackTrace: stackTrace);
  }
}

/// 디바이스 고유 ID 획득 (선택적)
///
/// 향후 device_info_plus 패키지로 구현 가능
/// 현재는 null 반환 (서버는 선택적으로 처리)
Future<String?> _getDeviceId() async {
  // TODO: device_info_plus로 구현
  return null;
}
```

**토큰 갱신 리스너 수정**:

```dart
// 기존
_subscriptions.add(_messaging.onTokenRefresh.listen((newToken) {
  deviceToken.value = newToken;
  Logger.info('FCM token refreshed: ${newToken.substring(0, 20)}...');
}));

// 수정 후
_subscriptions.add(_messaging.onTokenRefresh.listen((newToken) async {
  deviceToken.value = newToken;
  Logger.info('FCM token refreshed: ${newToken.substring(0, 20)}...');

  // 서버에 자동 재등록 (백그라운드)
  await registerDeviceTokenToServer();
}));
```

**설계 근거**:
- `registerDeviceTokenToServer()`: LoginController에서 호출
- `deactivateDeviceTokenOnServer()`: AuthRepository.logout()에서 호출
- 조용한 실패 정책: 에러 발생 시 로그만 기록, UI 표시 없음
- 토큰 갱신 시 자동 재등록 (Upsert 방식이므로 안전)

---

### 3. LoginController 확장 (apps/wowa/.../login/)

#### 파일: `controllers/login_controller.dart`

**설계 변경**: `_registerFcmToken()` 메서드를 직접 추가하지 않고, `AuthSdkConfig.onPostLogin` 콜백으로 대체합니다.

main.dart에서 콜백 주입:
```dart
onPostLogin: () async {
  final pushService = Get.find<PushService>();
  await pushService.registerDeviceTokenToServer();
},
```

**_handleSocialLogin 메서드 수정**:

```dart
Future<void> _handleSocialLogin({
  required SocialProvider provider,
  required RxBool loadingState,
}) async {
  try {
    // 1. 로딩 시작
    loadingState.value = true;

    // 2. AuthSdk를 통한 소셜 로그인
    final loginResponse = await AuthSdk.login(provider);

    // 3. FCM 토큰 등록 (onPostLogin 콜백, 실패해도 계속 진행)
    await AuthSdk.config.onPostLogin?.call();

    // 4. 성공 - 메인 화면으로 이동
    Get.offAllNamed(Routes.HOME);
  } on AuthException catch (e) {
    // 기존 에러 처리 그대로...
  } finally {
    loadingState.value = false;
  }
}
```

**설계 근거**:
- `AuthSdkConfig.onPostLogin` 콜백 패턴으로 SDK 간 의존성 제거
- auth_sdk가 push 패키지에 직접 의존하지 않음 (SDK 독립성 원칙)
- 로그인 성공 직후 콜백을 통해 FCM 토큰 등록 시도
- 등록 실패 시 홈 화면 이동은 계속 진행 (조용한 실패)

---

### 4. AuthRepository 확장 (packages/auth_sdk/)

#### 파일: `lib/src/repositories/auth_repository.dart`

**logout 메서드 수정**:

```dart
/// 로그아웃
///
/// 서버에 토큰 무효화 요청 후 로컬 저장소를 초기화합니다.
/// 서버 API 실패 시에도 로컬 데이터는 삭제합니다.
Future<void> logout({bool revokeAll = false}) async {
  try {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken != null) {
      await _apiService.logout(
        refreshToken: refreshToken,
        revokeAll: revokeAll,
      );
    }
  } catch (_) {
    // 서버 로그아웃 실패해도 로컬 데이터는 삭제
  } finally {
    // FCM 토큰 비활성화 (onPreLogout 콜백, 조용한 실패)
    try {
      await onPreLogout?.call();
    } catch (_) {
      // 콜백 실패해도 무시
    }

    await _storageService.clearAll();
  }
}
```

**설계 근거**:
- `onPreLogout` 콜백 패턴으로 SDK 간 의존성 제거
- auth_sdk가 push 패키지에 직접 의존하지 않음 (SDK 독립성 원칙)
- main.dart에서 콜백 주입: `onPreLogout: () async { pushService.deactivateDeviceTokenOnServer(); }`
- 비활성화 실패해도 로그아웃은 계속 진행 (finally 블록)

---

## 패키지 의존성

### push 패키지 (packages/push/pubspec.yaml)

**현재 의존성** (변경 없음):
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  dio: ^5.7.0
  firebase_messaging: ^15.1.4
  core:
    path: ../core
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

### wowa 앱 (apps/wowa/pubspec.yaml)

**현재 의존성** (변경 없음):
```yaml
dependencies:
  core:
    path: ../../packages/core
  design_system:
    path: ../../packages/design_system
  auth_sdk:
    path: ../../packages/auth_sdk
  push:
    path: ../../packages/push
```

**의존성 그래프**:
```
core (foundation)
  ↑
  ├── auth_sdk (login, token)
  ├── push (FCM, API)
  └── wowa app (LoginController)
```

---

## DI (Dependency Injection) 설정

### main.dart (apps/wowa/lib/main.dart)

**PushService 및 PushApiClient 등록 확인**:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // Dio 인스턴스 등록
  Get.put<Dio>(/* ... */);

  // PushService 초기화 및 등록
  final pushService = PushService();
  await pushService.initialize();
  Get.put<PushService>(pushService, permanent: true);

  // PushApiClient 등록
  Get.lazyPut<PushApiClient>(() => PushApiClient());

  runApp(MyApp());
}
```

**확인 사항**:
- PushService가 main.dart에서 초기화되고 permanent로 등록되어야 함
- PushApiClient가 DI에 등록되어야 함 (Lazy 가능)

---

## 서버 API 연동

### POST /api/push/devices — 디바이스 토큰 등록

**Request**:
```json
{
  "token": "FCM_DEVICE_TOKEN",
  "platform": "ios",  // "ios" | "android" | "web"
  "deviceId": null    // 선택적
}
```

**Response (200)**:
```json
{
  "id": 1,
  "token": "FCM_DEVICE_TOKEN",
  "platform": "ios",
  "isActive": true,
  "lastUsedAt": "2026-02-10T12:00:00Z",
  "createdAt": "2026-02-10T12:00:00Z"
}
```

**Error (401)**:
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "인증이 필요합니다"
  }
}
```

**특징**:
- Upsert 방식: 동일 (userId, appId, token) 조합이면 업데이트
- 인증 필수: Authorization Bearer 토큰

### POST /push/devices/deactivate — 토큰 기반 비활성화

**Request**:
```json
POST /push/devices/deactivate
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "token": "FCM_DEVICE_TOKEN"
}
```

**Response (204)**:
```
No Content
```

**Error (401)**:
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "인증이 필요합니다"
  }
}
```

**특징**:
- 토큰 기반 비활성화 (디바이스 ID 불필요)
- 서버에서 isActive = false로 업데이트 (소프트 삭제)
- 토큰이 없어도 204 반환 (멱등성 보장)

---

## 에러 처리 전략

### 조용한 실패 (Silent Failure) 정책

**원칙**:
- FCM 토큰 등록/비활성화는 백그라운드 작업
- 실패해도 사용자에게 에러 표시하지 않음
- 로그만 기록 (Logger.error)
- 앱의 다른 기능은 정상 동작

**에러 케이스별 처리**:

| 에러 | 로그 레벨 | UI 표시 | 앱 동작 |
|------|----------|---------|---------|
| 권한 거부 | WARN | 없음 | 정상 (홈 이동) |
| 토큰 획득 실패 (null) | ERROR | 없음 | 정상 (홈 이동) |
| 네트워크 오류 | ERROR | 없음 | 정상 (홈 이동) |
| 서버 5xx 오류 | ERROR | 없음 | 정상 (홈 이동) |
| 401 Unauthorized | ERROR | 없음 | 정상 (홈 이동) |
| PushService 미등록 | ERROR | 없음 | 정상 (홈 이동) |

### 에러 로깅 예시

```dart
// 성공
Logger.info('FCM 토큰 서버 등록 성공: eM9FZXJwZjR3a3F5cGY...');

// 권한 거부
Logger.warn('FCM 토큰이 없어 서버 등록을 건너뜁니다');

// 네트워크 오류
Logger.error('FCM 토큰 서버 등록 실패 (네트워크 오류)', error: e);

// 예외 발생
Logger.error('FCM 토큰 등록 중 예외 발생', error: e, stackTrace: stackTrace);
```

---

## 사용자 플로우

### 시나리오 1: 최초 로그인 + 권한 허용

```
1. 사용자가 "카카오로 로그인" 버튼 탭
   ↓
2. LoginController.handleKakaoLogin() 호출
   ↓
3. AuthSdk.login(SocialProvider.kakao) → 로그인 성공
   ↓
4. _registerFcmToken() 호출 (백그라운드)
   ├─ PushService.registerDeviceTokenToServer()
   │  ├─ deviceToken.value 확인 (이미 PushService.initialize()에서 획득)
   │  ├─ PushApiClient.registerDevice() 호출
   │  └─ Logger.info('FCM 토큰 서버 등록 성공...')
   └─ 성공/실패 여부 무관
   ↓
5. Get.offAllNamed(Routes.HOME) → 홈 화면 이동
```

### 시나리오 1.1: 자동 로그인 시 토큰 등록 (Method C 수정 후)

```
1. 사용자가 이전에 로그인한 상태로 앱을 종료했다
   ↓
2. 사용자가 앱을 다시 실행한다
   ↓
3. main.dart 실행:
   ├─ AuthSdk.initialize() → SecureStorage에서 인증 토큰 복원
   ├─ ever(pushService.deviceToken, callback) 등록  ← 먼저 등록
   └─ pushService.initialize() 호출               ← 토큰 획득
      ├─ _getDeviceToken() → deviceToken.value = "abc..."
      └─ ever 콜백 트리거됨!
         ├─ token != null → ✅
         ├─ AuthSdk.authState.isAuthenticated → ✅ (자동 로그인)
         └─ pushApiClient.registerDevice() → 서버에 토큰 등록
   ↓
4. MyApp 빌드 → initialRoute = Routes.HOME (자동 로그인)
   ↓
5. 결과: 자동 로그인 사용자도 즉시 푸시 알림 수신 가능
```

### 시나리오 2: 권한 거부

```
1. 사용자가 로그인 버튼 탭
   ↓
2. AuthSdk.login() → 로그인 성공
   ↓
3. iOS 시스템 권한 다이얼로그 → 사용자가 "허용 안 함" 탭
   ↓
4. _registerFcmToken() 호출
   ├─ PushService.registerDeviceTokenToServer()
   │  ├─ deviceToken.value == null (권한 거부로 토큰 없음)
   │  ├─ Logger.warn('FCM 토큰이 없어 서버 등록을 건너뜁니다')
   │  └─ return false
   └─ 조용히 종료
   ↓
5. Get.offAllNamed(Routes.HOME) → 홈 화면 이동 (정상)
```

### 시나리오 3: 토큰 갱신

```
1. 앱이 백그라운드 또는 포그라운드 상태
   ↓
2. FCM 시스템이 토큰 갱신 (예: 앱 재설치, APNS 토큰 갱신)
   ↓
3. _messaging.onTokenRefresh 리스너 호출
   ├─ deviceToken.value = newToken (반응형 상태 업데이트)
   ├─ Logger.info('FCM token refreshed: ...')
   └─ registerDeviceTokenToServer() 호출 (백그라운드)
      ├─ PushApiClient.registerDevice() → Upsert 방식
      └─ Logger.info('FCM 토큰 서버 등록 성공...')
   ↓
4. 사용자는 알림을 계속 받을 수 있음
```

### 시나리오 4: 로그아웃

```
1. 사용자가 설정 화면에서 로그아웃 버튼 탭
   ↓
2. AuthRepository.logout() 호출
   ├─ 서버 로그아웃 API 호출 (refresh token 폐기)
   └─ finally 블록:
      ├─ PushService.deactivateDeviceTokenOnServer()
      │  ├─ PushApiClient.deactivateDeviceByToken() 호출
      │  └─ Logger.info('FCM 토큰 서버 비활성화 성공...')
      └─ _storageService.clearAll() (로컬 데이터 삭제)
   ↓
3. Get.offAllNamed(Routes.LOGIN) → 로그인 화면 이동
   ↓
4. 서버: 해당 토큰으로 푸시 알림 발송 중단 (isActive = false)
```

### 시나리오 5: 네트워크 오류

```
1. 사용자가 로그인 완료
   ↓
2. _registerFcmToken() 호출
   ├─ PushApiClient.registerDevice() → Timeout 예외
   ├─ catch (DioException e) { Logger.error('...'); return false; }
   └─ 조용히 종료 (UI 표시 없음)
   ↓
3. Get.offAllNamed(Routes.HOME) → 홈 화면 이동 (정상)
   ↓
4. 다음 앱 실행 시 토큰 갱신 리스너에서 자동 재시도
```

---

## 성능 최적화 전략

### 1. 토큰 등록 비동기 처리

```dart
// LoginController._handleSocialLogin
await AuthSdk.login(provider);
await _registerFcmToken(); // 백그라운드 처리, 실패해도 계속 진행
Get.offAllNamed(Routes.HOME);
```

**효과**:
- 토큰 등록 실패해도 홈 화면 이동은 즉시 진행
- 사용자는 로그인 완료 후 약 1~2초 내에 홈 화면 진입

### 2. 토큰 갱신 리스너에서 백그라운드 호출

```dart
_messaging.onTokenRefresh.listen((newToken) async {
  deviceToken.value = newToken;
  await registerDeviceTokenToServer(); // 백그라운드 자동 처리
});
```

**효과**:
- 사용자가 토큰 갱신을 인지하지 못함
- UI 블로킹 없음

### 3. 조용한 실패로 재시도 로직 단순화

```dart
Future<bool> registerDeviceTokenToServer() async {
  try {
    await apiClient.registerDevice(...);
    return true;
  } catch (e) {
    Logger.error('...', error: e);
    return false; // 재시도 없음, 다음 앱 실행 시 자동 재시도
  }
}
```

**효과**:
- 복잡한 재시도 로직 불필요
- 토큰 갱신 리스너가 자동으로 재시도 역할 수행

---

## 로깅 전략

### PushService 로그

```dart
// 토큰 획득 성공
Logger.info('FCM device token obtained: ${token.substring(0, 20)}...');

// 토큰 갱신
Logger.info('FCM token refreshed: ${newToken.substring(0, 20)}...');

// 서버 등록 성공
Logger.info('FCM 토큰 서버 등록 성공: ${token.substring(0, 20)}...');

// 서버 등록 실패 (네트워크)
Logger.error('FCM 토큰 서버 등록 실패 (네트워크 오류)', error: e);

// 토큰 없음 (권한 거부)
Logger.warn('FCM 토큰이 없어 서버 등록을 건너뜁니다');

// 서버 비활성화 성공
Logger.info('FCM 토큰 서버 비활성화 성공: ${token.substring(0, 20)}...');
```

### LoginController 로그

```dart
// 토큰 등록 시도
try {
  await pushService.registerDeviceTokenToServer();
} catch (e) {
  Logger.error('FCM 토큰 등록 중 예외 발생', error: e);
}
```

**로그 레벨 정책**:
- INFO: 정상 플로우 (토큰 획득, 등록 성공, 비활성화 성공)
- WARN: 권한 거부, 토큰 없음 (사용자 선택)
- ERROR: 네트워크 오류, 서버 오류, 예외 발생

---

## 작업 분배 계획

### Senior Developer 작업

1. **PushApiClient 확장** (packages/push/)
   - `deactivateDeviceByToken(String token)` 메서드 추가
   - 파일: `lib/src/push_api_client.dart`

2. **PushService 확장** (packages/push/)
   - `registerDeviceTokenToServer()` 메서드 추가
   - `deactivateDeviceTokenOnServer()` 메서드 추가
   - `_getDeviceId()` 스텁 메서드 추가
   - 토큰 갱신 리스너 수정 (서버 API 호출 추가)
   - 파일: `lib/src/push_service.dart`

3. **LoginController 확장** (apps/wowa/)
   - `_registerFcmToken()` 메서드 추가
   - `_handleSocialLogin()` 메서드 수정 (FCM 등록 호출 추가)
   - 파일: `lib/app/modules/login/controllers/login_controller.dart`

4. **AuthRepository 확장** (packages/auth_sdk/)
   - `logout()` 메서드 수정 (FCM 비활성화 추가)
   - 파일: `lib/src/repositories/auth_repository.dart`

5. **DI 검증** (apps/wowa/)
   - main.dart에서 PushService, PushApiClient 등록 확인
   - 파일: `lib/main.dart`

### Junior Developer 작업

**없음** — UI 변경 없음, 백그라운드 기능만 추가

---

## 검증 기준

### 기능 검증

- [ ] 로그인 성공 후 서버에 FCM 토큰 등록됨 (POST /api/push/devices 호출 확인)
- [ ] 권한 거부 시 토큰 등록 건너뛰고 홈 화면 정상 이동
- [ ] 토큰 갱신 시 서버에 자동 재등록됨 (Upsert 방식)
- [ ] 로그아웃 시 서버에 토큰 비활성화 요청 전송 (POST /push/devices/deactivate)
- [ ] 네트워크 오류 시 조용히 실패, 홈 화면 정상 이동
- [ ] PushService 미등록 시에도 앱 정상 동작 (try-catch)

### 코드 품질

- [ ] GetX 패턴 준수 (Service, Controller 분리)
- [ ] 조용한 실패 정책 (에러 UI 표시 없음)
- [ ] 로그 레벨 적절 (INFO, WARN, ERROR)
- [ ] 주석 한글 작성 (기술 용어만 영어)
- [ ] DioException 처리 (NetworkException 변환 없이 로그만 기록)

### 성능

- [ ] 토큰 등록 실패해도 홈 화면 이동 지연 없음 (비동기 처리)
- [ ] 토큰 갱신 리스너에서 UI 블로킹 없음 (백그라운드)

---

## 참고 자료

### 기존 코드

- PushService: `packages/push/lib/src/push_service.dart`
- PushApiClient: `packages/push/lib/src/push_api_client.dart`
- LoginController: `apps/wowa/lib/app/modules/login/controllers/login_controller.dart`
- AuthRepository: `packages/auth_sdk/lib/src/repositories/auth_repository.dart`

### 가이드

- GetX Best Practices: `.claude/guide/mobile/getx_best_practices.md`
- Error Handling: `.claude/guide/mobile/error_handling.md`
- Common Patterns: `.claude/guide/mobile/common_patterns.md`

### 서버 API

- server-brief.md: `docs/wowa/fcm-token/server-brief.md`
- API 엔드포인트: `POST /push/devices`, `POST /push/devices/deactivate`

---

## 엣지 케이스 처리

### 1. PushService 초기화 전 로그인

**시나리오**: PushService.initialize()가 완료되기 전에 로그인 성공

**처리**:
```dart
Future<void> _registerFcmToken() async {
  try {
    final pushService = Get.find<PushService>();

    // PushService 초기화 대기 (최대 3초)
    for (var i = 0; i < 30 && !pushService.isInitialized.value; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!pushService.isInitialized.value) {
      Logger.warn('PushService 초기화 미완료, 토큰 등록 건너뜀');
      return;
    }

    await pushService.registerDeviceTokenToServer();
  } catch (e) {
    Logger.error('FCM 토큰 등록 중 예외 발생', error: e);
  }
}
```

### 2. 빠른 로그인/로그아웃 반복

**시나리오**: 로그인 → 즉시 로그아웃 → 재로그인

**처리**:
- 서버는 Upsert 방식이므로 안전
- 로그아웃 시 isActive = false
- 재로그인 시 isActive = true로 갱신

### 3. FCM 토큰이 null 반환 (iOS APNS 지연)

**시나리오**: iOS에서 APNS 토큰이 준비되지 않아 FCM 토큰이 null

**처리**:
```dart
// PushService.registerDeviceTokenToServer()
final token = deviceToken.value;
if (token == null || token.isEmpty) {
  Logger.warn('FCM 토큰이 없어 서버 등록을 건너뜁니다');
  return false;
}
```

**재시도**: 토큰 갱신 리스너가 토큰 획득 후 자동 호출

### 4. 로그아웃 시 네트워크 오류

**시나리오**: 로그아웃 API는 성공했지만 FCM 비활성화 실패

**처리**:
```dart
// AuthRepository.logout()
finally {
  try {
    await pushService.deactivateDeviceTokenOnServer();
  } catch (_) {
    // 비활성화 실패해도 로그아웃은 계속 진행
  }
  await _storageService.clearAll();
}
```

**결과**: 로컬 데이터는 삭제되고 로그인 화면으로 이동, 서버 토큰은 활성 상태로 남음 (무효 토큰 자동 정리 정책에 의해 나중에 정리)

---

## 향후 개선 사항 (Phase 2)

### 1. ~~디바이스 ID 획득 (device_info_plus)~~ ✅ 구현 완료

`device_info_plus` 패키지를 사용하여 iOS `identifierForVendor`, Android `Build.ID`를 반환하도록 구현 완료.

### 2. 토큰 등록 재시도 큐

**현재**: 등록 실패 시 다음 앱 실행 시 재시도

**개선**: 로컬 DB에 실패한 토큰 저장 → 네트워크 복구 시 자동 재시도

### 3. 설정 화면에 푸시 알림 상태 표시

**추가 UI**: 설정 화면에 "푸시 알림" 섹션
- 권한 상태 표시 (허용/거부)
- 권한 거부 시 "설정에서 활성화" 버튼 → 시스템 설정 앱 이동

### 4. 권한 재허용 감지 및 토큰 등록

**현재**: 권한 거부 후 변경 감지 안 함 (사용자가 설정에서 수동으로 권한 활성화 시에도 앱에서 자동 반응 없음)

**개선**:
- `AppLifecycleState` 감지: `resumed` 상태로 전환 시 권한 재확인
- PushService에 `checkAndRegisterIfPermissionGranted()` 메서드 추가
- 앱이 포그라운드로 돌아올 때마다 권한 상태 확인 후 필요하면 자동 등록

```dart
// main.dart 또는 App 레벨 위젯에서
appLifecycleListener = AppLifecycleListener(
  onResume: () async {
    // 앱이 포그라운드로 돌아왔을 때
    final pushService = Get.find<PushService>();
    if (await pushService.hasPermission()) {
      // 권한이 새로 허용된 경우 토큰 자동 등록
      await pushService.registerDeviceTokenToServer();
    }
  },
);
```

**효과**: 사용자가 설정에서 권한을 재허용한 후 앱으로 돌아오면 자동으로 FCM 토큰이 등록됨 (수동 조작 불필요)

---

## 요약

### 최소 변경 사항

1. **PushApiClient**: `deactivateDeviceByToken()` 메서드 1개 추가
2. **PushService**: 메서드 3개 추가, 리스너 1줄 수정
3. **LoginController**: 메서드 1개 추가, 기존 메서드 1줄 추가
4. **AuthRepository**: `logout()` 메서드 3줄 추가

### 핵심 설계 원칙

- **조용한 실패**: 에러 발생 시 UI 표시 없음, 로그만 기록
- **독립성**: FCM 기능 실패해도 앱의 다른 기능은 정상 동작
- **자동화**: 토큰 갱신 시 자동 재등록, 사용자 개입 불필요
- **멱등성**: Upsert 방식으로 중복 등록 방지

### 다음 단계

1. Senior Developer가 PushService, PushApiClient, LoginController, AuthRepository 수정
2. melos generate 실행 (Freezed 모델 재생성)
3. 서버 API `POST /push/devices/deactivate` 구현 확인
4. 통합 테스트: 로그인 → 토큰 등록 → 로그아웃 → 비활성화 검증
