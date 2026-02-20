# Mobile CLAUDE.md

Flutter 모노레포 (Melos) — wowa 앱 + 공유 패키지

## Commands

```bash
melos bootstrap                     # 항상 flutter pub get 대신 사용
melos clean && melos bootstrap      # Full reset
melos generate                      # 일회성 코드 생성
melos generate:watch                # Watch mode
melos analyze                       # 정적 분석
melos format                        # 코드 포맷
cd apps/wowa && flutter run         # Default device
```

## Testing Policy

**테스트 코드 작성 금지** — features, bug fixes에 테스트 불필요

## Analyze 기준

- **단일 패키지 수정**: `flutter analyze` (해당 패키지 디렉토리에서 실행)
- **모노레포 전체 검증**: `melos analyze` (cross-package 영향 확인 필요 시)

## Package Architecture

```
core (foundation — no internal dependencies)
  ↑
  ├── design_system (UI components, theme, reactive widgets)
  ├── push / auth_sdk / notice / qna / admob (각 SDK)
  └── wowa app (state management, routing, features)
```

- **의존성 규칙**: 단방향 (core <- design_system/sdk <- wowa), 순환 의존 금지
- 각 SDK는 자체 Dio 클라이언트와 Freezed 모델 포함 (독립성 유지)

## SDK Convention

- **SDK = Flutter 패키지만** — 서버는 `apps/server/src/modules/`로 유지
- SDK 위치: `packages/*_sdk/` 또는 `packages/[feature]/`
- SDK는 `core`, `design_system`에 의존 가능, `wowa` 앱에 의존 금지
- SDK는 앱에 독립적 — 하드코딩된 앱 이름, 라우트, 화면 이동 금지
- SDK 초기화는 config 객체로 주입 (appCode, apiBaseUrl 등)

## Quick Reference

- **Flutter**: `const` 생성자, 위젯 소형화, 리빌드 최소화
- **GetX**: 화면/기능당 1 controller, binding으로 DI, named routes
- **Design System**: `SketchContainer`, `SketchButton` 등 -> `packages/design_system/CLAUDE.md`
- **주석**: **모든 주석 한글**, 기술 용어(API, JSON 등)만 영어
- **코드 생성**: Freezed 모델 수정 후 `melos generate` 실행
- **의존성 추가**: `pubspec.yaml` 수정 -> `melos bootstrap` (flutter pub get 금지)

## Important Notes

- **`melos bootstrap`** 필수 (`flutter pub get` 금지)
- **`resolution: workspace`** pubspec.yaml에 추가 금지 (bootstrap 실패 원인)
- **코드 생성**은 `build_runner` 의존성 있는 패키지만 (SDK, wowa)

## Troubleshooting

- **Bootstrap 실패**: `resolution: workspace` 제거 -> `melos clean && melos bootstrap`
- **코드 생성 안 됨**: `build_runner` in dev_dependencies 확인 -> `melos generate`
- **Import 에러**: `pubspec.yaml` 의존성 확인 -> `melos bootstrap`
- **GetX controller not found**: binding 등록 확인, `Get.lazyPut()` 사용
- **Obx 업데이트 안 됨**: `.obs` 확인, `.value` 사용, const 위젯 내부 확인

## Documentation References

| 상황 | 참조 가이드 |
|------|------------|
| 새 화면/기능 추가 | `.claude/guide/mobile/directory_structure.md` |
| GetX Controller, Binding | `.claude/guide/mobile/getx_best_practices.md` |
| 위젯, 성능 최적화 | `.claude/guide/mobile/flutter_best_practices.md` |
| UI 컴포넌트, Frame0 테마 | `.claude/guide/mobile/design_system.md` |
| 디자인 시스템 연동 | `packages/design_system/README.md` |
| 주석 작성 (한글 정책) | `.claude/guide/mobile/comments.md` |
| 에러 처리 | `.claude/guide/mobile/error_handling.md` |
| 자주 쓰는 위젯 | `.claude/guide/mobile/common_widgets.md` |
| Import, 의존성 패턴 | `.claude/guide/mobile/common_patterns.md` |
| 렌더링 성능 | `.claude/guide/mobile/performance.md` |
| 디자인 토큰 | `.claude/guide/mobile/design-tokens.json` |
