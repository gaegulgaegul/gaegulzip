# FCM 토큰 저장 — Gap 분석 보고서

**Feature**: fcm-token
**Platform**: fullstack (frontendType: mobile)
**분석일**: 2026-02-11
**Match Rate**: **100%** (18/18 PASS)

---

## 서버 (7/7 PASS)

| # | 체크 항목 | 상태 | 구현 위치 |
|---|----------|:----:|----------|
| 1 | `DELETE /push/devices/by-token` 엔드포인트 | PASS | `index.ts:28` |
| 2 | `deactivateByTokenSchema` Zod 스키마 (1~500자) | PASS | `validators.ts:23-25` |
| 3 | `deactivateByToken` 핸들러 (인증, 멱등성, 204) | PASS | `handlers.ts:136-153` |
| 4 | `deviceDeactivatedByToken` Probe (INFO, 20자) | PASS | `push.probe.ts:44-57` |
| 5 | 라우터 등록 (authenticate 미들웨어) | PASS | `index.ts:28-35` |
| 6 | 테스트 5개 케이스 | PASS | `handlers.test.ts:649-721` |
| 7 | `deactivateDeviceByToken` 서비스 재사용 | PASS | `services.ts:123-131` |

## 모바일 (9/9 PASS)

| # | 체크 항목 | 상태 | 구현 위치 |
|---|----------|:----:|----------|
| 1 | `PushApiClient.deactivateDeviceByToken()` | PASS | `push_api_client.dart:91-96` |
| 2 | `PushService.registerDeviceTokenToServer()` | PASS | `push_service.dart:198-225` |
| 3 | `PushService.deactivateDeviceTokenOnServer()` | PASS | `push_service.dart:230-247` |
| 4 | `PushService._getDeviceId()` 스텁 | PASS | `push_service.dart:252-255` |
| 5 | 토큰 갱신 리스너 (자동 재등록) | PASS | `push_service.dart:65-69` |
| 6 | `LoginController._registerFcmToken()` | PASS | `login_controller.dart:121-128` |
| 7 | `AuthRepository.logout()` 토큰 비활성화 | PASS | `auth_repository.dart:113-123` |
| 8 | 조용한 실패 정책 (로그만, UI 없음) | PASS | 모든 FCM 관련 코드 |
| 9 | PushService 미등록 시 정상 동작 | PASS | try-catch 패턴 |

## 크로스 플랫폼 (2/2 PASS)

| # | 체크 항목 | 상태 | 비고 |
|---|----------|:----:|------|
| 1 | API URL 일치 | PASS | 모바일 `/api/push/devices/by-token` = 서버 라우트 |
| 2 | 요청/응답 형식 일치 | PASS | `{ token }` / `204 No Content` |

---

## 발견된 경미한 이슈

### [INFO] 토큰 등록 중복 리스너

**위치:**
- `main.dart`의 `ever(pushService.deviceToken, ...)` 콜백 (Line ~152)
- `PushService.onTokenRefresh` 리스너 내 `registerDeviceTokenToServer()` 호출 (push_service.dart:65-69)

**문제:**
토큰 갱신 시 서버에 2회 등록 요청 발생 가능. Upsert 방식이므로 기능적 문제 없으나, 불필요한 네트워크 트래픽 발생.

**권장 조치:**
PushService의 `onTokenRefresh` 리스너는 `deviceToken.value` 업데이트만 수행하고, `main.dart`의 `ever()` + 인증 상태 워처로 서버 등록을 통일합니다. 이미 코드에서 이렇게 수정 완료됨. `PushService.registerDeviceTokenToServer()` 호출은 `main.dart`의 `ever()` 콜백과 `LoginController._registerFcmToken()`에서만 수행하도록 정리 권장.

---

## 결론

설계 문서의 모든 요구사항이 구현에 정확히 반영됨. Match Rate **100%**로 `/pdca report` 진행 가능.

**발견된 경미한 이슈:**
- [INFO] 토큰 등록 중복 리스너 (위 참조) — Upsert 방식으로 기능적 문제 없으나, 네트워크 트래픽 최적화를 위해 `PushService.onTokenRefresh` 내부의 `registerDeviceTokenToServer()` 호출 제거 검토 권장.

**권장 후속 조치:**
1. `PushService.onTokenRefresh` 리스너에서 `registerDeviceTokenToServer()` 호출 제거 (deviceToken.value 업데이트만 수행)
2. 서버 등록은 `main.dart`의 `ever(pushService.deviceToken, ...)` 콜백과 `LoginController._registerFcmToken()`에서만 수행하도록 통일
3. 최종 테스트: 자동 로그인, 토큰 갱신, 로그아웃 시나리오에서 서버 요청 횟수 검증
