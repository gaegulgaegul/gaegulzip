# Wowa 모바일 기능 카탈로그

> 모바일 앱에 구현된 모듈, 패키지, 위젯을 빠르게 찾기 위한 카탈로그입니다.
> 상세 분석은 `docs/core/` 하위 문서를 참조하세요.

## 앱 모듈

### 로그인 (Login)

- **모듈 경로**: `apps/mobile/apps/wowa/lib/app/modules/login/`
- **상태**: ⚠️ UI만 구현 (서버 연동 스텁)
- **핵심 파일**:
  - `controllers/login_controller.dart` — GetX 컨트롤러 (4개 프로바이더별 로딩 상태, 에러 처리)
  - `views/login_view.dart` — 소셜 로그인 4개 버튼 + 둘러보기 버튼
  - `bindings/login_binding.dart` — `LoginController` DI 등록
- **사용 패키지**: core (예외 클래스), design_system (SocialLoginButton)
- **서버 연동**: 미연동 (핸들러가 2초 딜레이 스텁)
- **Quick Start**:
  1. 실제 연동 시 `packages/api`에 AuthRepository 구현
  2. `LoginBinding`에서 AuthRepository 주입
  3. `LoginController`의 `handleXxxLogin()` 메서드에서 SDK → API 호출 구현
- **상세 분석**: [`docs/core/social-login.md`](../core/social-login.md)

---

### 홈 (Home)

- **상태**: ❌ 미구현 (라우트만 정의됨)
- **라우트**: `Routes.HOME` = `/home`

### 설정 (Settings)

- **상태**: ❌ 미구현 (라우트만 정의됨)
- **라우트**: `Routes.SETTINGS` = `/settings`

---

## 라우팅

- **정의**: `apps/mobile/apps/wowa/lib/app/routes/app_routes.dart`
- **페이지**: `apps/mobile/apps/wowa/lib/app/routes/app_pages.dart`
- **등록된 라우트**:
  | 경로 | 뷰 | 바인딩 | 트랜지션 |
  |------|-----|--------|---------|
  | `/login` | `LoginView` | `LoginBinding` | fadeIn (300ms) |
  | `/home` | 미구현 | - | - |
  | `/settings` | 미구현 | - | - |
- **초기 라우트**: `Routes.LOGIN`

---

## 패키지별 제공 기능

### Core (`apps/mobile/packages/core/`)

기반 패키지. 다른 모든 패키지가 의존합니다.

**의존성**: `get`, `logger`, `flutter`

#### 예외 클래스

| 클래스 | 속성 | 용도 |
|--------|------|------|
| `AuthException` | `code`, `message` | 인증 실패, 토큰 만료, 권한 거부 |
| `NetworkException` | `message`, `statusCode?` | 네트워크 연결 실패, 타임아웃 |

- **사용법**: `throw AuthException(code: 'user_cancelled', message: '사용자가 취소함')`
- **Controller에서 처리 패턴**:
  ```dart
  try { /* 로직 */ }
  on NetworkException catch (e) { /* 네트워크 에러 */ }
  on AuthException catch (e) {
    if (e.code == 'user_cancelled') return; // 무시
    /* 인증 에러 */
  }
  catch (e) { /* 기타 에러 */ }
  ```

#### 디자인 토큰 (SketchDesignTokens)

Frame0 스케치 스타일 디자인 시스템의 기본 토큰입니다.

| 카테고리 | 주요 토큰 | 예시 |
|---------|---------|------|
| 선 두께 | `strokeThin(1)`, `strokeStandard(2)`, `strokeBold(3)` | 테두리, 구분선 |
| 간격 | `spacingXs(4)` ~ `spacing4Xl(64)` | 8px 그리드 기반 |
| 모서리 | `radiusSm(2)` ~ `radiusPill(9999)` | 카드, 버튼 |
| 색상 | `accentPrimary(#DF7D5F)`, `success`, `error` 등 | 테마 색상 |
| 폰트 | `fontSizeXs(12)` ~ `fontSize6Xl(60)` | 텍스트 크기 |
| 투명도 | `opacityDisabled(0.4)`, `opacitySketch(0.8)` | 비활성/스케치 효과 |

#### 컬러 팔레트 (SketchColorPalettes)

| 팔레트 | 특징 |
|--------|------|
| `pastel` | 부드러운 파스텔 톤 |
| `vibrant` | 선명한 원색 계열 |
| `monochrome` | 흑백 계열 |
| `earthy` | 자연스러운 따뜻한 톤 |
| `ocean` | 시원한 블루/틸 계열 |
| `sunset` | 따뜻한 오렌지/핑크 계열 |

- **사용법**: `SketchColorPalettes.getPalette('pastel')` → 색상 Map 반환

---

### API (`apps/mobile/packages/api/`)

HTTP 통신 패키지. Dio 기반.

**의존성**: `core`, `dio`, `json_annotation`, `freezed`, `build_runner`

**현재 상태**: ❌ 빈 상태 (인프라만 구성됨)

- Dio HTTP 클라이언트 설정: 미구현
- API 모델 (Freezed): 미구현
- Auth/Push API 서비스: 미구현

**Quick Start** (새 API 모델 추가):
1. `lib/src/models/` 하위에 Freezed 모델 파일 생성
2. `@freezed` + `@JsonSerializable` 어노테이션 적용
3. `melos generate` 실행 (또는 `melos generate:watch`)
4. 생성된 `.g.dart`, `.freezed.dart` 파일 자동 생성됨

---

### Design System (`apps/mobile/packages/design_system/`)

Frame0 스케치 스타일 UI 컴포넌트 패키지.

**의존성**: `core`, `get`, `flutter_svg`

#### 테마 시스템

| 클래스 | 용도 |
|--------|------|
| `SketchThemeExtension` | ThemeData에 스케치 스타일 속성 추가 |
| `SketchThemeController` | GetX 기반 테마 모드 관리 (라이트/다크) |

- **프리셋**: `.light()`, `.dark()`, `.rough()`, `.smooth()`, `.ultraSmooth()`, `.veryRough()`
- **테마 접근**: `SketchThemeExtension.of(context)`

#### 재사용 가능한 위젯 (12개)

| 위젯 | 용도 | 주요 속성 |
|------|------|---------|
| `SketchButton` | 버튼 | text, style(primary/secondary/outline), size, isLoading |
| `SketchContainer` | 컨테이너 | child, fillColor, borderColor, roughness, enableNoise |
| `SketchCard` | 카드 | header, body, footer, elevation(0-3), onTap |
| `SketchInput` | 텍스트 입력 | label, hint, errorText, controller, obscureText |
| `SketchModal` | 모달 다이얼로그 | `SketchModal.show(context, child:, title:)` (static) |
| `SketchCheckbox` | 체크박스 | value, tristate, activeColor |
| `SketchChip` | 칩/태그 | label, selected, onDeleted, icon |
| `SketchIconButton` | 아이콘 버튼 | icon, shape(circle/square), badgeCount |
| `SketchProgressBar` | 진행바 | value, style(linear/circular), showPercentage |
| `SketchSwitch` | 스위치 토글 | value, activeColor |
| `SketchSlider` | 슬라이더 | value, min, max, divisions |
| `SketchDropdown<T>` | 드롭다운 | value, items, itemBuilder |

#### 소셜 로그인 버튼

| 위젯 | 용도 |
|------|------|
| `SocialLoginButton` | 브랜드 가이드라인 준수 소셜 로그인 버튼 |

- **플랫폼**: kakao, naver, apple, google
- **사이즈**: small(40), medium(48), large(56)
- **애플 스타일**: dark, light
- **사용법**: `SocialLoginButton(platform: SocialLoginPlatform.kakao, onPressed: () {}, size: SocialLoginButtonSize.large)`

#### CustomPainter

| Painter | 용도 |
|---------|------|
| `SketchPainter` | 스케치 스타일 사각형 테두리 |
| `SketchCirclePainter` | 스케치 스타일 원형 |
| `SketchLinePainter` | 스케치 스타일 선 |
| `SketchPolygonPainter` | 스케치 스타일 다각형 |
| `AnimatedSketchPainter` | 애니메이션 스케치 효과 |

#### Enum

| Enum | 값 |
|------|-----|
| `SocialLoginPlatform` | kakao, naver, apple, google |
| `SocialLoginButtonSize` | small, medium, large |
| `AppleSignInStyle` | dark, light |
| `SketchButtonStyle` | primary, secondary, outline |
| `SketchButtonSize` | small, medium, large |
| `SketchIconButtonShape` | circle, square |
| `SketchProgressBarStyle` | linear, circular |

#### SVG 에셋

```
packages/design_system/assets/social_login/
├── kakao_symbol.svg
├── naver_logo.svg
├── apple_logo.svg
└── google_logo.svg
```

---

## 패키지 의존성 그래프

```
core (기반 - 내부 의존성 없음)
  ↑
  ├── api (HTTP 통신, 데이터 모델)
  ├── design_system (UI 컴포넌트, 테마)
  └── wowa app (모듈, 라우팅, 통합)
```

---

## 새 모듈 추가 체크리스트

1. `apps/wowa/lib/app/modules/[feature]/` 디렉토리 생성
2. `controllers/[feature]_controller.dart` — GetxController 상속
3. `views/[feature]_view.dart` — GetView<Controller> 상속
4. `bindings/[feature]_binding.dart` — Bindings 구현, `Get.lazyPut<Controller>()`
5. `app_routes.dart`에 라우트 상수 추가
6. `app_pages.dart`에 `GetPage` 등록 (binding + transition)
7. 필요 시 `packages/api`에 모델 및 API 서비스 추가
8. `melos bootstrap` 실행 (의존성 변경 시)
