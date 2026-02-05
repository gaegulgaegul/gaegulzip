# Gap Analysis: push-alert (Fullstack)

**Feature**: push-alert
**Platform**: Fullstack (Server + Mobile)
**분석 날짜**: 2026-02-05
**Iteration**: 1 (재분석)
**Match Rate**: 93.3% (Server 95% / Mobile 91.5%) ✅ 90% 임계값 초과

---

## 요약

| 플랫폼 | Iteration 0 | Iteration 1 | 변화 |
|--------|:-----------:|:-----------:|:----:|
| Server | 95% | 95% | - |
| Mobile | 57% | 91.5% | +34.5pp |
| **전체** | **71.5%** | **93.3%** | **+21.8pp** |

---

## Iteration 1 해결 항목 (7건 → 모두 검증 완료)

| # | 항목 | 파일 | 상태 |
|---|------|------|:----:|
| 1 | NotificationBinding 생성 | `bindings/notification_binding.dart` | ✅ |
| 2 | app_pages.dart binding 등록 | `app_pages.dart` | ✅ |
| 3 | handleNotificationTap 구현 | `notification_controller.dart:103-132` | ✅ |
| 4 | NotificationView 전체 UI | `notification_view.dart` (316줄) | ✅ |
| 5 | main.dart PushService 초기화 | `main.dart` (89줄) | ✅ |
| 6 | pubspec.yaml push 패키지 추가 | `pubspec.yaml` | ✅ |
| 7 | PushApiClient 전역 등록 | `main.dart:27` | ✅ |

---

## Server Gap (95% — 변동 없음)

### ✅ 완전 구현 (45 항목)
- Schema, Services(5), Validators, Handlers(3+1), Router(3), Probe(2)
- 93개 테스트 전체 통과, TypeScript 빌드 성공

### ❌ 미구현 (2 항목 — 운영/문서)
- 마이그레이션 실행 (`drizzle-kit generate && migrate`) — P2
- OpenAPI 문서 업데이트 — P2

---

## Mobile Gap (57% → 91.5%)

### ✅ 완전 구현 (65 항목)

**packages/push/ (17항목)** — PushService, PushNotification, 콜백, exports
**packages/api/ (12항목)** — Freezed 모델 4개, PushApiClient, exports
**apps/wowa/ Controller (17항목)** — 7개 메서드 전체 구현 (handleNotificationTap 포함)
**apps/wowa/ View (15항목)** — GetView, 4가지 상태 렌더링, SketchCard, 무한스크롤, 상대시간
**apps/wowa/ Binding+Routes (3항목)** — NotificationBinding, Routes.NOTIFICATIONS, GetPage+binding
**apps/wowa/ main.dart (5항목)** — PushService init, 핸들러 3종, 토큰 자동등록

### ❌ 미구현 (6 항목)

| # | 항목 | 설계 문서 | 우선순위 |
|---|------|----------|:--------:|
| 1 | UnreadBadgeIcon 위젯 | mobile-brief.md 3-6 | P1 |
| 2 | UnreadBadgeIcon 홈 화면 연동 | mobile-brief.md 3-6 | P1 |
| 3 | UnreadBadgeIcon 네비게이션 | mobile-brief.md 3-6 | P1 |
| 4 | GoogleService-Info.plist (iOS) | Firebase 설정 | P2 (수동) |
| 5 | google-services.json (Android) | Firebase 설정 | P2 (수동) |
| 6 | 화면 전환 스타일 (fadeIn vs rightToLeft) | design-spec | P2 (미세) |

---

## 변경 사항 (설계 ≠ 구현, 허용 가능)

| 항목 | 설계 | 구현 | 영향 |
|------|------|------|:----:|
| PushApiClient 등록 위치 | Binding lazyPut | main.dart Get.put (전역) | 낮음 |
| 에러 타입 | NetworkException | DioException | 낮음 |
| API 경로 | `/push/...` | `/api/push/...` | 없음 |
| hasMore 로직 | `length >= limit` | `length < total` | 없음 |
| 포그라운드 배너 | AnimatedSlide 커스텀 | Get.snackbar | 낮음 |

---

## 아키텍처 준수

| 항목 | 상태 |
|------|:----:|
| 패키지 의존성 방향 (core ← api/push/design_system ← wowa) | ✅ |
| GetX Controller/View/Binding 분리 | ✅ |
| Push SDK 앱 독립성 (콜백 주입) | ✅ |
| API 계약 Server ↔ Mobile 일치 | ✅ |
| 한글 주석 | ✅ |
| const 최적화 | ✅ |

---

## 버전 이력

| 버전 | 날짜 | Match Rate | 변경 사항 |
|------|------|:---------:|----------|
| 1.0 | 2026-02-05 | 71.5% | 최초 분석 (Server 95%, Mobile 57%) |
| 2.0 | 2026-02-05 | 93.3% | Iteration 1 재분석 (Mobile 57% → 91.5%) |
