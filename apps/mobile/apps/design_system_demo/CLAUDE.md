# Design System Demo — Sketch Design System 쇼케이스 앱

## 제품 개요

- **목적**: Sketch Design System의 위젯, 페인터, 테마, 컬러, 토큰을 시각적으로 확인하는 데모 앱
- **대상 사용자**: 개발자, 디자이너 (내부 도구)
- **핵심 기능**:
  - 위젯 카탈로그 (Button, Card, Input, Modal 등 20+ 위젯 데모)
  - 페인터 카탈로그 (Circle, Line, Polygon, Animated, Sketch 페인터)
  - 테마 쇼케이스 (라이트/다크 모드 전환)
  - 컬러 팔레트 뷰어
  - 디자인 토큰 뷰어
  - SDK 데모 (QnA, Notice 실서버 연동)

## Commands

```bash
cd apps/mobile/apps/design_system_demo && flutter run
melos bootstrap    # 의존성 설치 (flutter pub get 금지)
```

## Environment Variables

`.env` 파일 필수:

| 변수 | 설명 | 필수 |
|------|------|------|
| `API_BASE_URL` | 서버 API 기본 URL (SDK 데모용) | Yes |

## Project Structure

```
lib/
├── main.dart                        # 엔트리포인트 — Dio, NoticeApiService, 테마 초기화
└── app/
    ├── modules/
    │   ├── home/                    # 홈 — 카탈로그 네비게이션 허브
    │   ├── widgets/                 # 위젯 데모 (20+ 위젯, 각각 별도 파일)
    │   ├── painters/                # 페인터 데모 (5종)
    │   ├── theme/                   # 테마 쇼케이스
    │   ├── colors/                  # 컬러 팔레트
    │   ├── tokens/                  # 디자인 토큰
    │   └── sdk_demos/               # QnA, Notice SDK 실서버 연동 데모
    └── routes/                      # 라우트 정의
```

## Architecture

- **상태 관리**: GetX (Controller + Binding)
- **라우팅**: GetX named routes
- **테마 전환**: `SketchThemeController`로 라이트/다크 모드 실시간 전환
- **인증 없음**: JWT 인증 없이 Dio 직접 사용 (데모 앱)
- SDK 데모는 `appCode: 'demo'`로 초기화

## 사용 중인 SDK/패키지

| 패키지 | 역할 | 초기화 위치 |
|--------|------|------------|
| `design_system` | 모든 UI 위젯, 테마, 페인터 | `main.dart`, 각 데모 뷰 |
| `core` | Logger, 디자인 토큰 | `main.dart` |
| `qna` | QnA 질문 제출 데모 | `app_pages.dart` (QnaBinding) |
| `notice` | 공지사항 목록/상세 데모 | `app_pages.dart` (NoticeBinding) |

## 새 화면/기능 추가 시

1. `app/modules/{category}/views/demos/` 아래 데모 뷰 파일 추가
2. 해당 카탈로그 컨트롤러의 아이템 목록에 등록
3. 필요 시 `app/routes/`에 라우트 추가

## Important Notes

- `auth_sdk` 미사용 — 인증 없이 동작하는 순수 데모 앱
- SDK 데모의 `appCode`는 `'demo'`로 고정
- Lucide Icons (`lucide_icons_flutter`) 사용
