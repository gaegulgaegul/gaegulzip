# Mobile CLAUDE.md

Flutter 모노레포 (Melos) — wowa 앱 + 공유 패키지

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

- **의존성 규칙**: 단방향 (core ← design_system/sdk ← wowa), 순환 의존 금지
- 각 SDK는 자체 Dio 클라이언트와 Freezed 모델 포함 (독립성 유지)

## SDK Convention

- SDK 위치: `packages/*_sdk/` 또는 `packages/[feature]/`
- SDK는 `core`, `design_system`에 의존 가능, `wowa` 앱에 의존 금지
- SDK는 앱에 독립적 — 하드코딩된 앱 이름, 라우트, 화면 이동 금지
- SDK 초기화는 config 객체로 주입 (appCode, apiBaseUrl 등)
- 동일 엔드포인트 클라이언트는 한 곳에만 존재 (재사용 → SDK, 앱 전용 → wowa)

## Quick Reference

- **Flutter**: `const` 생성자 적극 사용, 위젯 소형화, 리빌드 최소화
- **GetX**: 화면/기능당 1 controller, binding으로 DI, named routes
- **Design System**: `SketchContainer`, `SketchButton` 등 Frame0 컴포넌트 → `packages/design_system/README.md`
- **주석**: **모든 주석 한글**, 기술 용어(API, JSON 등)만 영어
- **코드 생성**: Freezed 모델 수정 후 `melos generate` 실행
- **의존성 추가**: `pubspec.yaml` 수정 → `melos bootstrap` (flutter pub get 금지)

## Important Notes

- **`melos bootstrap`** 필수 (`flutter pub get` 금지)
- **`resolution: workspace`** pubspec.yaml에 추가 금지 (bootstrap 실패 원인)
- **코드 생성**은 `build_runner` 의존성 있는 패키지만 (SDK, wowa)

## Troubleshooting

- **Bootstrap 실패**: `resolution: workspace` 제거 → `melos clean && melos bootstrap`
- **코드 생성 안 됨**: `build_runner` in dev_dependencies 확인 → `melos generate`
- **Import 에러**: `pubspec.yaml` 의존성 확인 → `melos bootstrap`
- **GetX controller not found**: binding 등록 확인, `Get.lazyPut()` 사용
- **Obx 업데이트 안 됨**: `.obs` 확인, `.value` 사용, const 위젯 내부 확인

📖 상세 가이드 및 SDK 패키지 목록: Root `CLAUDE.md` > Documentation References / Core Features 참조
