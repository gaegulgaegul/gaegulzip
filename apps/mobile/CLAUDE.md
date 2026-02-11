# Mobile CLAUDE.md

Flutter 모노레포 (Melos) — 날씨 및 가계부 앱 `wowa` + 공유 패키지

## Commands

```bash
# Setup
melos bootstrap                     # 항상 flutter pub get 대신 사용
melos clean && melos bootstrap      # Full reset

# Code generation
melos generate                      # 일회성 생성
melos generate:watch                # Watch mode

# Quality
melos analyze                       # 정적 분석
melos format                        # 코드 포맷

# Run
cd apps/wowa && flutter run         # Default device
cd apps/wowa && flutter run -d ios  # iOS simulator
```

## Testing Policy

**테스트 코드 작성 금지** — features, bug fixes에 테스트 불필요

## Package Architecture

```
core (foundation — no internal dependencies)
  ↑
  ├── design_system (UI components, theme, reactive widgets)
  ├── push         (Push notification SDK with Dio)
  ├── auth_sdk     (Authentication SDK with Dio)
  ├── notice       (Notice SDK with Dio)
  ├── qna          (Q&A SDK with Dio)
  └── wowa app     (state management, routing, features)
```

- `core` → 기초 유틸, DI, 로깅, extensions, 에러 처리
- `design_system` → Frame0 스케치 스타일 UI 컴포넌트, 테마
- `*_sdk` → 기능별 SDK 패키지 (예: `auth_sdk`, `push`). 각 SDK는 자체 Dio 클라이언트와 Freezed 모델 포함
- `wowa` → 메인 앱, GetX 상태관리, 라우팅, 앱 전용 도메인 모델

**의존성 규칙**: 단방향 (core ← design_system/sdk ← wowa), 순환 의존 금지

## SDK Packaging Convention

- SDK 패키지 위치: `packages/*_sdk/` 또는 `packages/[feature]/` (예: `packages/auth_sdk/`, `packages/push/`)
- SDK는 `core`, `design_system` 패키지에 의존 가능, `wowa` 앱에 의존 금지
- SDK는 앱에 독립적 — 하드코딩된 앱 이름, 라우트, 화면 이동 포함 금지
- SDK 초기화는 config 객체로 주입 (appCode, apiBaseUrl 등)
- 각 SDK는 자체 Dio 클라이언트와 Freezed 모델을 포함 (독립성 유지)

## SDK API Client Policy

**SDK별 API 클라이언트 구현:**
- `auth_sdk` - 자체 `AuthApiService` (multi-tenant 지원, 동적 appCode 주입)
- `notice`, `qna`, `push` - 자체 `*ApiService` (SDK 독립성 유지)
- **앱 전용 도메인 로직** - wowa 앱 내부에서 관리 (Box, WOD, Proposal 등)

**중복 방지 원칙:**
- 동일한 엔드포인트에 대한 클라이언트는 한 곳에만 존재
- 재사용 가능한 기능 → SDK로 분리 (인증, 푸시, 공지사항 등)
- 앱 전용 기능 → 앱 내부에서 관리 (Box, WOD 등)

## SDK Packages

| 패키지 | 사용 상황 | 참조 |
|--------|----------|------|
| `auth_sdk` | 소셜 로그인 (카카오/네이버/구글/애플), 토큰 관리, 인증 상태 | `packages/auth_sdk/README.md` |
| `push` | FCM 푸시 알림 수신, 디바이스 토큰 등록, 알림 콜백 처리 | `packages/push/README.md` |
| `notice` | 공지사항 목록/상세 조회, 읽음 추적, 미읽음 배지 | `packages/notice/README.md` |
| `qna` | QnA 질문 제출 (GitHub Issue 연동) | `packages/qna/README.md` |
| `admob` | Google 배너/전면/리워드 광고 | `packages/admob/README.md` |

## Quick Reference

- **Flutter**: `const` 생성자 적극 사용, 위젯 소형화, 리빌드 최소화
- **GetX**: 화면/기능당 1 controller, binding으로 DI, named routes
- **Design System**: `SketchContainer`, `SketchButton` 등 Frame0 컴포넌트 사용 → 연동 가이드: `packages/design_system/README.md`
- **주석**: **모든 주석 한글**, 기술 용어(API, JSON 등)만 영어

## Development Workflow

### 의존성 추가

1. 의존성 그래프에 맞는 패키지 선택 (UI→design_system, 재사용 기능→SDK, 앱→wowa)
2. `pubspec.yaml`에 추가 후 `melos bootstrap`
3. 코드 생성 도구면 `melos generate` 실행

### API 모델 작업

1. SDK 또는 wowa 앱 내부에 Freezed + json_serializable 모델 생성
   - 재사용 가능 → SDK 패키지 (`packages/*/lib/src/models/`)
   - 앱 전용 → wowa 앱 (`apps/wowa/lib/app/data/models/`)
2. `melos generate:watch` 실행 (자동 재생성)

### 패키지 간 의존성

```yaml
dependencies:
  core:
    path: ../core             # 패키지 간
  design_system:
    path: ../design_system    # 패키지 간
  auth_sdk:
    path: ../../packages/auth_sdk  # 앱에서
```

## Important Notes

- **`melos bootstrap`** 필수 (`flutter pub get` 금지)
- **`resolution: workspace`** pubspec.yaml에 추가 금지 (bootstrap 실패 원인)
- **코드 생성**은 `build_runner` 의존성 있는 패키지만 (SDK 패키지들, `wowa`)

## Troubleshooting

- **Bootstrap 실패**: `resolution: workspace` 제거 → `melos clean && melos bootstrap`
- **코드 생성 안 됨**: `build_runner` in dev_dependencies 확인 → `melos generate`
- **Import 에러**: `pubspec.yaml` 의존성 확인 → `melos bootstrap`
- **GetX controller not found**: binding 등록 확인, `Get.lazyPut()` 사용
- **Obx 업데이트 안 됨**: `.obs` 확인, `.value` 사용, const 위젯 내부 확인

## 📖 Detailed Guides

| 가이드 | 경로 |
|-------|------|
| Flutter Best Practices | `../../.claude/guide/mobile/flutter_best_practices.md` |
| GetX Best Practices | `../../.claude/guide/mobile/getx_best_practices.md` |
| Directory Structure | `../../.claude/guide/mobile/directory_structure.md` |
| Design System | `../../.claude/guide/mobile/design_system.md` |
| Common Patterns | `../../.claude/guide/mobile/common_patterns.md` |
| Common Widgets | `../../.claude/guide/mobile/common_widgets.md` |
| Error Handling | `../../.claude/guide/mobile/error_handling.md` |
| Performance | `../../.claude/guide/mobile/performance.md` |
| Comments | `../../.claude/guide/mobile/comments.md` |
| Design Tokens | `../../.claude/guide/mobile/design-tokens.json` |
