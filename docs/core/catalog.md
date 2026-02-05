# Core 기능 카탈로그

> 제품 간 공유되는 공통 기능의 상세 분석 문서 인덱스입니다.
> 각 문서는 서버/모바일 양쪽의 구현 현황, 플로우, 개선점을 포함합니다.

## 기능 목록

| 기능 | 상세 문서 | 서버 | 모바일 |
|------|----------|------|--------|
| 소셜 로그인 | [`social-login.md`](./social-login.md) | ✅ 완료 | ⚠️ SDK 연동 완료 (실 서버 테스트 필요) |
| FCM 푸시 알림 | [`fcm-push-notification.md`](./fcm-push-notification.md) | ✅ 완료 | ❌ 미구현 |
| QnA (질문과 답변) | [`qna/`](./qna/) | ✅ 완료 | ✅ 완료 |

## 소셜 로그인

- **프로바이더**: 카카오, 네이버, 구글, 애플 (4개)
- **서버**: OAuth 토큰 검증 → 사용자 Upsert → JWT 발급 + Refresh Token 로테이션
- **모바일**: SocialLoginButton 위젯, OAuth SDK 연동 (4개 프로바이더), AuthRepository, SecureStorageService
- **핵심 진입점**:
  - 서버 로그인: `apps/server/src/modules/auth/handlers.ts` > `oauthLogin()`
  - 서버 토큰 갱신: `apps/server/src/modules/auth/handlers.ts` > `refreshToken()`
  - 인증 미들웨어: `apps/server/src/middleware/auth.ts` > `authenticate()`
  - 모바일 컨트롤러: `apps/mobile/apps/wowa/lib/app/modules/login/controllers/login_controller.dart`
  - 모바일 Repository: `apps/mobile/apps/wowa/lib/app/data/repositories/auth_repository.dart`
  - 소셜 프로바이더: `apps/mobile/apps/wowa/lib/app/services/social_login/`
- **주요 개선 필요**: Apple 공개키 서명 검증, 실 서버 연동 테스트

## FCM 푸시 알림

- **발송 대상**: 단건(userId), 다건(userIds), 전체(all)
- **서버**: Firebase Admin SDK 래퍼, 배치 발송(500건), 무효 토큰 자동 비활성화
- **모바일**: Firebase 패키지 미설치, 토큰 등록/알림 수신 미구현
- **핵심 진입점**:
  - 서버 디바이스 등록: `apps/server/src/modules/push-alert/handlers.ts` > `registerDevice()`
  - 서버 알림 발송: `apps/server/src/modules/push-alert/handlers.ts` > `sendPush()`
  - FCM 래퍼: `apps/server/src/modules/push-alert/fcm.ts` > `sendToMultipleDevices()`
- **주요 개선 필요**: 모바일 Firebase 설정, 발송 재시도 로직, send 엔드포인트 인증

## QnA (질문과 답변)

- **GitHub Issue 연동**: 사용자 질문을 GitHub Issue로 자동 생성
- **멀티테넌트**: `appCode`로 앱별 GitHub 저장소 분리 (앱당 독립적 설정)
- **선택적 인증**: 로그인/비로그인 사용자 모두 질문 가능
- **서버**: GitHub App 인증 (Octokit SDK), Rate Limit 자동 대응, Domain Probe 로그
- **모바일**: 질문 작성 화면 (SketchInput + SketchButton + SketchModal), GetX 상태 관리
- **핵심 진입점**:
  - 서버 질문 제출: `apps/server/src/modules/qna/handlers.ts` > `submitQuestion()`
  - 서버 GitHub 연동: `apps/server/src/modules/qna/github.ts` > `createGitHubIssue()`
  - 서버 Octokit 캐싱: `apps/server/src/modules/qna/octokit.ts` > `getOctokitInstance()`
  - 선택적 인증: `apps/server/src/middleware/optional-auth.ts` > `optionalAuthenticate()`
  - 모바일 컨트롤러: `apps/mobile/apps/wowa/lib/app/modules/qna/controllers/qna_controller.dart`
  - 모바일 Repository: `apps/mobile/apps/wowa/lib/app/data/repositories/qna_repository.dart`
  - 모바일 화면: `apps/mobile/apps/wowa/lib/app/modules/qna/views/qna_submit_view.dart`
- **새 제품 적용 방법**:
  1. `qna_config` 테이블에 앱별 GitHub App 설정 추가 (appId, repoOwner, repoName, installationId, privateKey)
  2. `apps` 테이블에 새 앱 레코드 추가 (code: "새앱코드")
  3. 모바일에서 `Get.toNamed(Routes.QNA)` 호출 (QnaRepository의 appCode 변경)
  4. API 호출: `POST /qna/questions { appCode: "새앱코드", title: "...", body: "..." }`
- **설계 문서**: [`qna/server-brief.md`](./qna/server-brief.md), [`qna/mobile-design-spec.md`](./qna/mobile-design-spec.md), [`qna/mobile-brief.md`](./qna/mobile-brief.md)

## 제품별 카탈로그 참조

| 제품 | 서버 카탈로그 | 모바일 카탈로그 |
|------|------------|--------------|
| wowa | [`docs/wowa/server-catalog.md`](../wowa/server-catalog.md) | [`docs/wowa/mobile-catalog.md`](../wowa/mobile-catalog.md) |
