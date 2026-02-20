# Wowa — 크로스핏 박스 운영 모바일 앱

## 제품 개요

- **목적**: 크로스핏 박스(체육관) 회원/코치를 위한 WOD(Workout of the Day) 관리 앱
- **대상 사용자**: 크로스핏 박스 코치, 회원
- **핵심 기능**:
  - 소셜 로그인 (카카오, 네이버, 구글, 애플)
  - 박스 검색/생성 및 멤버십 관리
  - WOD 등록, 조회, 상세 비교, 선택
  - 제안(Proposal) 검토
  - 푸시 알림 및 딥링크 네비게이션
  - 공지사항, Q&A, 배너 광고

## Commands

```bash
cd apps/mobile/apps/wowa && flutter run          # 기본 디바이스
cd apps/mobile/apps/wowa && flutter run -d ios    # iOS 시뮬레이터
melos generate                                    # Freezed 모델 코드 생성
melos generate:watch                              # Watch mode
```

## Environment Variables

`.env` 파일 필수 (앱 assets로 번들링):

| 변수 | 설명 | 필수 |
|------|------|------|
| `API_BASE_URL` | 서버 API 기본 URL | Yes |
| `KAKAO_NATIVE_APP_KEY` | 카카오 네이티브 앱 키 | No (없으면 카카오 로그인 비활성) |
| `GOOGLE_SERVER_CLIENT_ID` | 구글 서버 클라이언트 ID | No (없으면 구글 로그인 비활성) |

## Project Structure

```
lib/
├── main.dart                    # 엔트리포인트 — SDK 초기화 순서 정의
├── firebase_options.dart        # Firebase 자동 생성 설정
└── app/
    ├── data/
    │   ├── clients/             # API 클라이언트 (box, proposal, wod)
    │   ├── models/              # Freezed 데이터 모델
    │   └── repositories/        # Repository 패턴 (클라이언트 래핑)
    ├── modules/                 # 기능별 모듈 (GetX MVC 패턴)
    │   ├── box/                 # 박스 검색/생성
    │   ├── wod/                 # WOD 홈/등록/상세/선택/제안검토
    │   ├── notification/        # 알림 목록
    │   └── settings/            # 설정
    └── routes/                  # 라우트 정의 (app_routes.dart, app_pages.dart)
```

## Architecture

- **상태 관리**: GetX (화면별 Controller + Binding)
- **라우팅**: GetX named routes (`app_routes.dart`에 상수, `app_pages.dart`에 매핑)
- **API 통신**: Dio + AuthInterceptor (토큰 자동 갱신)
- **데이터 모델**: Freezed + json_serializable (코드 생성 필수)
- **테마**: Sketch Design System (SketchDesignTokens, SketchThemeExtension)

## 사용 중인 SDK/패키지

| 패키지 | 역할 | 초기화 위치 |
|--------|------|------------|
| `auth_sdk` | 소셜 로그인, 인증 상태, 토큰 관리 | `main.dart` (AuthSdk.initialize) |
| `push` | FCM 푸시 알림, 디바이스 토큰 관리 | `main.dart` (PushService) |
| `notice` | 공지사항 목록/상세 화면 | `main.dart` (NoticeApiService), `app_pages.dart` |
| `qna` | Q&A 질문 제출 화면 | `app_pages.dart` (QnaBinding) |
| `admob` | 배너 광고 | `main.dart` (AdMobService) |
| `core` | Logger, SecureStorage, 예외 클래스, 디자인 토큰 | auth_sdk 내부에서 자동 등록 |
| `design_system` | UI 위젯, 테마 확장 | `main.dart` (ThemeData.extensions) |

## 새 화면/기능 추가 시

1. `app/routes/app_routes.dart`에 라우트 상수 추가
2. `app/modules/{feature}/` 아래 `views/`, `controllers/`, `bindings/` 생성
3. `app/routes/app_pages.dart`에 GetPage 등록 (View + Binding)
4. API 연동 필요 시 `app/data/clients/`에 클라이언트, `app/data/models/`에 Freezed 모델 추가
5. `melos generate` 실행하여 `.freezed.dart`, `.g.dart` 생성

## Deployment

- Firebase 프로젝트 연동 (firebase_options.dart)
- 커스텀 폰트: Loranthus, KyoboHandwriting2019 (assets/fonts/)

## Important Notes

- **초기화 순서**: .env -> AuthSdk -> Firebase -> AdMob -> Push (main.dart 참조)
- 푸시 딥링크 허용 화면: `Routes.deepLinkAllowedScreens` (`notifications`, `home`, `qna`)
- 로그아웃 시 `PushService.deactivateDeviceTokenOnServer()` 자동 호출 (onPreLogout 콜백)
