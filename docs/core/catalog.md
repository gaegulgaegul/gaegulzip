# Core 기능 카탈로그

> 제품 간 공유되는 공통 기능의 상세 분석 문서 인덱스입니다.
> 각 문서는 서버/모바일 양쪽의 구현 현황, 플로우, 개선점을 포함합니다.

## 기능 목록

| 기능 | 상세 문서 | 서버 | 모바일 |
|------|----------|------|--------|
| 소셜 로그인 | [`social-login.md`](./social-login.md) | ✅ 완료 | ✅ auth_sdk 패키지 완료 |
| FCM 푸시 알림 | [`fcm-push-notification.md`](./fcm-push-notification.md) | ✅ 완료 | ✅ push 패키지 완료 |
| QnA (질문과 답변) | [`qna/`](./qna/) | ✅ 완료 | ✅ qna 패키지 완료 |
| 공지사항 (Notice) | - | ✅ 완료 | ✅ notice 패키지 완료 |
| 박스 관리 (Box) | - | ✅ 완료 | ✅ wowa 앱 모듈 완료 |
| WOD 관리 | - | ✅ 완료 | ✅ wowa 앱 모듈 완료 |

## 소셜 로그인

- **프로바이더**: 카카오, 네이버, 구글, 애플 (4개)
- **서버**: OAuth 토큰 검증 → 사용자 Upsert → JWT 발급 + Refresh Token 로테이션
- **모바일**: SocialLoginButton 위젯, OAuth SDK 연동, AuthRepository, SecureStorageService
- **핵심 진입점**:
  - 서버 로그인: `apps/server/src/modules/auth/handlers.ts` > `oauthLogin()`
  - 서버 토큰 갱신: `apps/server/src/modules/auth/handlers.ts` > `refreshToken()`
  - 인증 미들웨어: `apps/server/src/middleware/auth.ts` > `authenticate()`
  - 모바일 SDK: `apps/mobile/packages/auth_sdk/lib/src/`
  - 모바일 facade: `AuthSdk.initialize()`, `AuthSdk.login()`
  - 소셜 프로바이더: `apps/mobile/packages/auth_sdk/lib/src/providers/`
- **새 제품 적용**:
  1. `apps` 테이블에 앱 레코드 추가 (OAuth 키 설정)
  2. `AuthSdk.initialize(config)` 호출 (appCode, apiBaseUrl 설정)
  3. `LoginView`/`LoginBinding` 라우트에 등록

## FCM 푸시 알림

- **발송 대상**: 단건(userId), 다건(userIds), 전체(all)
- **서버**: Firebase Admin SDK 래퍼, 배치 발송(500건), 무효 토큰 자동 비활성화, 수신 기록 추적
- **모바일**: FCM 토큰 자동 등록, 알림 수신 핸들링 (foreground/background/terminated), 알림 목록/미읽음 수
- **핵심 진입점**:
  - 서버 디바이스 등록: `apps/server/src/modules/push-alert/handlers.ts` > `registerDevice()`
  - 서버 알림 발송: `apps/server/src/modules/push-alert/handlers.ts` > `sendPush()`
  - FCM 래퍼: `apps/server/src/modules/push-alert/fcm.ts` > `sendToMultipleDevices()`
  - 모바일 SDK: `apps/mobile/packages/push/lib/src/`
  - 모바일 서비스: `PushService` (FCM 초기화, 토큰 관리)
  - 모바일 API: `PushApiClient` (디바이스 등록, 알림 조회)
- **새 제품 적용**:
  1. `apps` 테이블에 FCM 인증 정보 설정
  2. `PushService` 전역 등록 + `PushApiClient` 초기화
  3. FCM 토큰 변경 시 `ever` watcher로 자동 서버 동기화

## QnA (질문과 답변)

- **GitHub Issue 연동**: 사용자 질문을 GitHub Issue로 자동 생성
- **멀티테넌트**: `appCode`로 앱별 GitHub 저장소 분리
- **선택적 인증**: 로그인/비로그인 사용자 모두 질문 가능
- **핵심 진입점**:
  - 서버 질문 제출: `apps/server/src/modules/qna/handlers.ts` > `submitQuestion()`
  - 서버 GitHub 연동: `apps/server/src/modules/qna/github.ts` > `createGitHubIssue()`
  - 선택적 인증: `apps/server/src/middleware/optional-auth.ts` > `optionalAuthenticate()`
  - 모바일 SDK: `apps/mobile/packages/qna/lib/src/`
  - 모바일 컨트롤러: `QnaController` (qna 패키지 내장)
  - 모바일 화면: `QnaSubmitView` (qna 패키지 내장)
- **새 제품 적용**:
  1. `qna_config` 테이블에 앱별 GitHub App 설정 추가
  2. `QnaBinding(appCode: '새앱코드')` 라우트에 등록
  3. `POST /qna/questions { appCode: "새앱코드", ... }` 자동 처리

## 공지사항 (Notice)

- **멀티테넌트**: `appCode`로 앱별 공지 분리
- **서버**: CRUD + 고정/해제, 읽음 추적, soft delete, 관리자 인증 (X-Admin-Secret)
- **모바일**: 목록/상세 화면, 미읽음 배지, 페이지네이션
- **핵심 진입점**:
  - 서버 핸들러: `apps/server/src/modules/notice/handlers.ts`
  - 서버 관리자: `apps/server/src/modules/notice/admin-handlers.ts`
  - 모바일 SDK: `apps/mobile/packages/notice/lib/src/`
  - 모바일 API: `NoticeApiService`
  - 모바일 위젯: `NoticeListCard`, `UnreadNoticeBadge`
- **새 제품 적용**:
  1. `apps` 테이블에 앱 레코드 추가
  2. notice 패키지를 앱 의존성에 추가, 라우트 등록
  3. `NoticeApiService` 전역 등록 (appCode 자동 필터링)

## 박스 관리 (Box)

- **서버**: CRUD + 검색 + 멤버십 관리 (단일 박스 정책, 가입 시 기존 탈퇴)
- **모바일**: 박스 검색/생성, 가입 확인 모달
- **핵심 진입점**:
  - 서버: `apps/server/src/modules/box/handlers.ts`
  - 모바일: `apps/mobile/apps/wowa/lib/app/modules/box/`
- **특이사항**: 제품 전용 기능 (CrossFit 박스 개념). 재사용 시 SDK 추출 검토 필요

## WOD 관리

- **서버**: WOD 등록/조회, 변경 제안 시스템 (승인/거부), WOD 선택 (스냅샷)
- **모바일**: 5개 화면 (홈, 등록, 상세, 선택, 제안 검토), 4가지 WOD 타입 지원
- **핵심 진입점**:
  - 서버: `apps/server/src/modules/wod/handlers.ts`
  - 모바일: `apps/mobile/apps/wowa/lib/app/modules/wod/`
- **특이사항**: 제품 전용 기능. 재사용 시 SDK 추출 검토 필요

## 제품별 카탈로그 참조

| 제품 | 서버 카탈로그 | 모바일 카탈로그 |
|------|------------|--------------|
| wowa | [`docs/wowa/server-catalog.md`](../wowa/server-catalog.md) | [`docs/wowa/mobile-catalog.md`](../wowa/mobile-catalog.md) |
