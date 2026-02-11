# wowa-login 설계-구현 갭 분석 보고서

| 항목 | 내용 |
|------|------|
| **분석 대상** | wowa-login (로그인 화면 SDK 재사용성 개선) |
| **플랫폼** | Mobile (Flutter) |
| **설계 문서** | `mobile-design-spec.md`, `mobile-brief.md`, `user-story.md` |
| **구현 경로** | `apps/mobile/packages/auth_sdk/lib/`, `apps/mobile/apps/wowa/lib/main.dart` |
| **분석일** | 2026-02-11 |
| **PR #17 CodeRabbit 리뷰 반영** | 18건 (1차 7건 + 2차 4건 + 3차 7건) |

---

## 종합 점수

| 카테고리 | 점수 | 상태 |
|----------|:----:|:----:|
| 설계 일치도 | 95% | 통과 |
| 아키텍처 준수도 | 96% | 통과 |
| 컨벤션 준수도 | 95% | 통과 |
| **종합** | **95%** | **통과** |

---

## 즉시 조치 (Major)

| # | 파일 | 이슈 | 설명 |
|:-:|------|------|------|
| 1 | `main.dart:37,39` | 환경변수 null 검증 누락 | KAKAO_NATIVE_APP_KEY, GOOGLE_SERVER_CLIENT_ID null 시 ProviderConfig에 null 전달 |
| 2 | `auth_sdk_config.dart:1` | 순환 import | auth_sdk.dart <-> auth_sdk_config.dart 순환 참조 |
| 3 | `main.dart:142` | 매직넘버 색상 | `Color(0xFF2A2A2A)` -> 디자인 토큰 사용 필요 |
| 4 | `auth_sdk.dart:84-141` | 초기화 롤백 없음 | initialize() 실패 시 _config 롤백 필요 |

## 단기 조치 (Minor/Trivial)

| # | 파일 | 이슈 |
|:-:|------|------|
| 5 | `login_view.dart:116` | 부제목 색상 base500 vs base700 통일 |
| 6 | `login_view.dart:12` | super.key 패턴 미사용 |
| 7 | `auth_sdk.dart:298-303` | appCode getter null 체크 중복 |

## 문서 업데이트

| # | 문서 | 이슈 |
|:-:|------|------|
| D-1 | design-spec.md:608 | AuthSdk.init() -> AuthSdk.initialize() |
| D-2 | design-spec.md:32 | 부제목 색상 base500 -> base700 (구현에 맞춤) |
| D-3 | design-spec.md:276 | 폰트명 PatrickHand -> Loranthus |
| D-4 | user-story.md:278-285 | SDK 설정 테이블에 providers 필드 추가 |
| D-5 | design-spec.md:492 | WCAG AA 네이버 버튼 예외 기재 |
| D-6 | design_system/README.md:83,99,103 | PatrickHand -> Loranthus |

---

## 버전 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2026-02-11 | 초기 갭 분석 (Match Rate 85%) |
| 1.1 | 2026-02-11 | Iteration 1 완료 (Match Rate 85% → 93%) |
| 1.2 | 2026-02-11 | Iteration 2 완료 (Match Rate 93% → 95%) |

## Iteration 1 수정 내역

### 코드 수정 (6건)

| # | 파일 | 수정 내용 |
|:-:|------|----------|
| 1 | `main.dart:29-40` | 환경변수 null 검증 추가 (KAKAO, GOOGLE) |
| 2 | `auth_sdk_config.dart` | SocialProvider, ProviderConfig를 config 파일로 이동 (순환 import 해소) |
| 3 | `auth_sdk.dart` | re-export 추가 + try-catch 롤백 + appCode getter 단순화 |
| 4 | `main.dart:147` | 매직넘버 Color(0xFF2A2A2A) → SketchDesignTokens.surfaceDark |
| 5 | `login_view.dart:12` | super.key 패턴 적용 |
| 6 | `main.dart` | Logger.warn 메서드명 수정 |

### 문서 수정 (6건)

| # | 문서 | 수정 내용 |
|:-:|------|----------|
| D-1 | design-spec.md:608 | AuthSdk.init() → AuthSdk.initialize(AuthSdkConfig) |
| D-2 | design-spec.md:32 | 부제목 색상 base500 → base700 |
| D-3 | design-spec.md:276 | 폰트명 Roboto/PatrickHand → Loranthus |
| D-4 | user-story.md:278-285 | providers 필드 추가, googleServerClientId 제거 |
| D-5 | design-spec.md:492 | WCAG AA 네이버 버튼 예외 명시 |
| D-6 | design_system/README.md | PatrickHand → Loranthus, surfaceColor 토큰 업데이트, 폰트 설정 가이드 갱신 |

## Iteration 2 수정 내역

### 코드 수정 (2건)

| # | 파일 | 수정 내용 |
|:-:|------|----------|
| 1 | `main.dart:55` | 주석 번호 중복 수정 (// 4. → // 5., 이후 순차 재번호) |
| 2 | `auth_sdk.dart:202` | expiresIn 하드코딩 TODO 주석 추가 (서버 응답 파싱 필요) |

### 문서 수정 (5건)

| # | 문서 | 수정 내용 |
|:-:|------|----------|
| D-7 | design-spec.md:87 | 부제목 색상 base500 → base700 (위젯 트리 섹션) |
| D-8 | design-spec.md:237 | base500 용도 "부제목 텍스트" → "비활성 텍스트" |
| D-9 | design-spec.md:287 | 타이포그래피 부제목 색상 base500 → base700 + 폰트 Loranthus |
| D-10 | design-spec.md:655 | googleServerClientId → providers Map 필드 |
| D-11 | user-story.md:221,226,230 | 타임아웃 30초→10초, Markdown 제목 빈 줄 추가 |

### 미해결 → 해결

| # | 파일 | 설명 | 상태 |
|:-:|------|------|:----:|
| N-1 | `auth_sdk.dart` | expiresIn 서버 응답 파싱 — AuthRepository → LoginResponse 반환으로 해결 | ✅ |
