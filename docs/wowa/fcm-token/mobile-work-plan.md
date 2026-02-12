# Mobile Work Plan: FCM 토큰 저장

## 개요

FCM 토큰 저장 기능의 모바일 작업은 **기존 코드에 최소한의 변경**만 추가합니다. 로그인 후 자동으로 푸시 알림 토큰을 서버에 등록하고, 토큰 갱신 시 자동 재등록하며, 로그아웃 시 비활성화하는 백그라운드 기능입니다.

**핵심 전략**:
- PushService는 이미 구현됨 (FCM 초기화, 토큰 획득, 리스너 등록 완료)
- PushApiClient에 메서드 1개 추가
- PushService에 메서드 3개 추가, 리스너 1줄 수정
- LoginController에 메서드 1개 추가, 기존 메서드 1줄 추가
- AuthRepository의 `logout()` 메서드 3줄 추가

---

## 실행 그룹

### Group 1 (병렬) — 전체 작업

| Agent | Module | 설명 |
|-------|--------|------|
| flutter-developer | push + login + auth | FCM 토큰 등록/비활성화 전체 플로우 구현 |

**참고**: Mobile 작업은 의존성 체인이 있어 단일 개발자가 순차 진행하는 것이 안전합니다.
- PushApiClient → PushService → LoginController/AuthRepository

---

## 작업 범위

### 패키지: push

**위치**: `apps/mobile/packages/push/`

**변경 파일**:
1. `lib/src/push_api_client.dart` — `deactivateDeviceByToken()` 메서드 추가
2. `lib/src/push_service.dart` — 메서드 3개 추가, 리스너 1줄 수정

### 앱: wowa

**위치**: `apps/mobile/apps/wowa/`

**변경 파일**:
1. `lib/app/modules/login/controllers/login_controller.dart` — `_registerFcmToken()` 메서드 추가, `_handleSocialLogin()` 수정

### 패키지: auth_sdk

**위치**: `apps/mobile/packages/auth_sdk/`

**변경 파일**:
1. `lib/src/repositories/auth_repository.dart` — `logout()` 메서드 수정

---

## 작업 상세

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
  await _dio.delete(
    '/api/push/devices/by-token',
    data: {'token': token},
  );
}
```

**설계 근거**:
- 서버 API: `DELETE /api/push/devices/by-token`
- 로그아웃 시 디바이스 ID를 모르는 경우 토큰으로 비활성화
- 에러 발생 시 DioException throw (호출 측에서 조용히 실패 처리)
- 반환값 없음 (204 No Content)

---

### 2. PushService 확장 (packages/push/)

#### 파일: `lib/src/push_service.dart`

**추가 메서드 1: registerDeviceTokenToServer()**

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
```

**추가 메서드 2: deactivateDeviceTokenOnServer()**

```dart
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
```

**추가 메서드 3: _getDeviceId() (스텁)**

```dart
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

### 3. LoginController 확장 (apps/wowa/)

#### 파일: `lib/app/modules/login/controllers/login_controller.dart`

**추가 메서드**:

```dart
/// FCM 토큰 서버 등록 (백그라운드 자동 처리)
///
/// 권한이 거부되거나 등록 실패 시 조용히 실패합니다.
/// 앱의 다른 기능에 영향을 주지 않습니다.
Future<void> _registerFcmToken() async {
  try {
    final pushService = Get.find<PushService>();

    // PushService에 토큰 등록 요청 (성공 여부는 무시)
    await pushService.registerDeviceTokenToServer();
  } catch (e) {
    // PushService가 등록되지 않았거나 예외 발생 시 조용히 실패
    Logger.error('FCM 토큰 등록 중 예외 발생', error: e);
  }
}
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

    // 3. FCM 토큰 등록 (백그라운드 자동 처리, 실패해도 계속 진행)
    await _registerFcmToken();

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
- 로그인 성공 직후 FCM 토큰 등록 시도
- 등록 실패 시 홈 화면 이동은 계속 진행 (조용한 실패)
- PushService가 없어도 앱은 정상 동작

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
    // FCM 토큰 비활성화 (조용한 실패)
    try {
      final pushService = Get.find<PushService>();
      await pushService.deactivateDeviceTokenOnServer();
    } catch (_) {
      // PushService가 없거나 실패해도 무시
    }

    await _storageService.clearAll();
  }
}
```

**설계 근거**:
- 로그아웃 시 FCM 토큰 비활성화 (서버 정책에 따라)
- 비활성화 실패해도 로그아웃은 계속 진행 (finally 블록)
- PushService가 DI에 없어도 앱은 정상 동작

---

## 의존성 체인

```
PushApiClient (deactivateDeviceByToken 추가)
    ↓
PushService (registerDeviceTokenToServer, deactivateDeviceTokenOnServer 추가)
    ↓
┌───────────────────┬──────────────────┐
│ LoginController   │ AuthRepository   │
│ (_registerFcmToken)│ (logout 수정)    │
└───────────────────┴──────────────────┘
```

**작업 순서**:
1. PushApiClient 확장
2. PushService 확장
3. LoginController 확장
4. AuthRepository 확장

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
| 토큰 획득 실패 (null) | WARN | 없음 | 정상 (홈 이동) |
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

---

## GetX 패턴 준수

### Controller vs Service 역할 분리

**PushService (GetxService)**:
- FCM 초기화, 토큰 획득, 리스너 등록
- 서버 API 호출 (registerDeviceTokenToServer, deactivateDeviceTokenOnServer)
- 앱 전역에서 사용 가능 (permanent: true)

**LoginController (GetxController)**:
- 로그인 플로우 관리
- PushService 호출 (`_registerFcmToken()`)
- 조용한 실패 처리 (try-catch)

**AuthRepository (Repository)**:
- 로그아웃 API 호출
- 로컬 저장소 초기화
- PushService 호출 (토큰 비활성화)

---

## DI (Dependency Injection) 검증

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

### DELETE /api/push/devices/by-token — 토큰 기반 비활성화

**Request**:
```json
DELETE /api/push/devices/by-token
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

---

## 작업 체크리스트

### 구현
- [ ] `PushApiClient`: `deactivateDeviceByToken()` 메서드 추가
- [ ] `PushService`: `registerDeviceTokenToServer()` 메서드 추가
- [ ] `PushService`: `deactivateDeviceTokenOnServer()` 메서드 추가
- [ ] `PushService`: `_getDeviceId()` 스텁 메서드 추가
- [ ] `PushService`: 토큰 갱신 리스너 수정 (서버 API 호출 추가)
- [ ] `LoginController`: `_registerFcmToken()` 메서드 추가
- [ ] `LoginController`: `_handleSocialLogin()` 메서드 수정
- [ ] `AuthRepository`: `logout()` 메서드 수정 (토큰 비활성화 추가)

### 검증
- [ ] `flutter analyze` — 린트 오류 없음
- [ ] 로그인 후 서버에 FCM 토큰 등록 확인 (로그 확인)
- [ ] 권한 거부 시 홈 화면 정상 이동 (에러 표시 없음)
- [ ] 로그아웃 시 서버에 토큰 비활성화 요청 전송 (로그 확인)
- [ ] 네트워크 오류 시 조용히 실패, 홈 화면 정상 이동
- [ ] PushService 미등록 시에도 앱 정상 동작 (try-catch 검증)

### 코드 품질
- [ ] GetX 패턴 준수 (Service, Controller 분리)
- [ ] 조용한 실패 정책 (에러 UI 표시 없음)
- [ ] 로그 레벨 적절 (INFO, WARN, ERROR)
- [ ] 주석 한글 작성 (기술 용어만 영어)
- [ ] import 정리 (core → design_system → wowa 순서)

---

## 성능 최적화

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

---

## 엣지 케이스 처리

### 1. PushService 초기화 전 로그인

**처리**:
```dart
Future<void> _registerFcmToken() async {
  try {
    final pushService = Get.find<PushService>();
    await pushService.registerDeviceTokenToServer();
  } catch (e) {
    // PushService가 등록되지 않았거나 예외 발생 시 조용히 실패
    Logger.error('FCM 토큰 등록 중 예외 발생', error: e);
  }
}
```

### 2. FCM 토큰이 null 반환 (iOS APNS 지연)

**처리**:
```dart
final token = deviceToken.value;
if (token == null || token.isEmpty) {
  Logger.warn('FCM 토큰이 없어 서버 등록을 건너뜁니다');
  return false;
}
```

**재시도**: 토큰 갱신 리스너가 토큰 획득 후 자동 호출

### 3. 로그아웃 시 네트워크 오류

**처리**:
```dart
finally {
  try {
    await pushService.deactivateDeviceTokenOnServer();
  } catch (_) {
    // 비활성화 실패해도 로그아웃은 계속 진행
  }
  await _storageService.clearAll();
}
```

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
- Comments: `.claude/guide/mobile/comments.md`

### 설계 문서
- mobile-brief.md: `docs/wowa/fcm-token/mobile-brief.md`
- mobile-design-spec.md: `docs/wowa/fcm-token/mobile-design-spec.md`
- 사용자 스토리: `docs/wowa/fcm-token/user-story.md`

---

## 예상 소요 시간

| 작업 | 예상 시간 |
|------|----------|
| PushApiClient 확장 | 10분 |
| PushService 확장 | 30분 |
| LoginController 확장 | 20분 |
| AuthRepository 확장 | 10분 |
| DI 검증 | 10분 |
| 통합 테스트 (수동) | 30분 |
| **합계** | **1시간 50분** |

---

## Developer 역할 분배

### flutter-developer (1명)

**담당 범위**: 전체 작업
- 패키지: `push`, `auth_sdk`
- 앱: `wowa`

**작업 순서**:
1. `PushApiClient` — `deactivateDeviceByToken()` 추가
2. `PushService` — 메서드 3개 추가, 리스너 수정
3. `LoginController` — `_registerFcmToken()` 추가, `_handleSocialLogin()` 수정
4. `AuthRepository` — `logout()` 수정
5. `flutter analyze` — 린트 검증
6. 통합 테스트 (로그인 → 토큰 등록 → 로그아웃 → 비활성화)

---

## 완료 조건

### Acceptance Criteria
- [ ] 로그인 성공 후 서버에 FCM 토큰 등록됨 (로그 확인)
- [ ] 권한 거부 시 토큰 등록 건너뛰고 홈 화면 정상 이동
- [ ] 토큰 갱신 시 서버에 자동 재등록됨 (로그 확인)
- [ ] 로그아웃 시 서버에 토큰 비활성화 요청 전송 (로그 확인)
- [ ] 네트워크 오류 시 조용히 실패, 홈 화면 정상 이동
- [ ] PushService 미등록 시에도 앱 정상 동작

### Definition of Done
- [ ] 코드 리뷰 완료 (CTO 승인)
- [ ] `flutter analyze` 통과 (린트 오류 0개)
- [ ] 주석 한글 작성 완료 (기술 용어만 영어)
- [ ] GetX 패턴 준수 (Service, Controller 분리)
- [ ] 조용한 실패 정책 준수 (에러 UI 표시 없음)
- [ ] 로깅 정책 준수 (INFO, WARN, ERROR)
- [ ] import 정리 (common_patterns.md 준수)
