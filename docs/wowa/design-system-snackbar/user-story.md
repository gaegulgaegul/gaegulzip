# User Story: Design System Snackbar

## 기능 개요

디자인 시스템에 Frame0 스케치 스타일의 Snackbar 컴포넌트를 추가한다.
4가지 타입(success, info, warning, error)별로 light/dark 모드를 지원하며,
모든 색상은 디자인 시스템 테마에서 관리한다.

## 사용자 스토리

**AS A** 디자인 시스템 사용자 (Flutter 개발자)
**I WANT** 스케치 스타일의 Snackbar 컴포넌트를 사용하여 사용자에게 알림을 표시하고 싶다
**SO THAT** 앱 전체에서 일관된 Frame0 스케치 디자인으로 피드백 메시지를 보여줄 수 있다

## 수용 기준

### AC1: 4가지 Snackbar 타입
- [ ] **Success**: 체크마크 아이콘 + 초록 계열 배경
- [ ] **Info**: 정보 아이콘 + 파란 계열 배경
- [ ] **Warning**: 경고 아이콘 + 노란 계열 배경
- [ ] **Error**: X 아이콘 + 빨간/분홍 계열 배경

### AC2: Light/Dark 모드 지원
- [ ] Light 모드: 연한 배경 + 검은 테두리/텍스트/아이콘
- [ ] Dark 모드: 진한 배경 + 흰 테두리/텍스트/아이콘
- [ ] 테마 전환 시 자동으로 색상 변경

### AC3: 스케치 스타일 디자인
- [ ] SketchPainter 기반 hand-drawn 테두리 (roughness, noise 텍스처)
- [ ] 아이콘은 스케치 스타일 커스텀 아이콘 (Material 아이콘 아닌 CustomPainter)
- [ ] Hand 폰트(PatrickHand/KyoboHandwriting) 사용

### AC4: 색상 관리
- [ ] 모든 색상은 SketchThemeExtension에서 관리 (하드코딩 금지)
- [ ] snackbar 전용 색상 토큰 추가 (8가지: 4타입 x light/dark 배경)

### AC5: 데모 앱
- [ ] design_system_demo 앱에서 4가지 타입 모두 확인 가능
- [ ] light/dark 모드 전환하여 확인 가능

### AC6: 기존 크기 유지
- [ ] Flutter 기본 SnackBar와 동일한 크기 규격 적용
- [ ] 아이콘 + 텍스트 수평 배치

## 디자인 참조 (Asset 이미지)

| 타입 | Light Mode | Dark Mode |
|------|-----------|-----------|
| Success | snackbar-success-light-mode.png | snackbar-success-dark-mode.png |
| Info | snackbar-info-light-mode.png | snackbar-info-dark-mode.png |
| Warning | snackbar-warn-light-mode.png | snackbar-warn-dark-mode.png |
| Error | snackbar-error-light-mode.png | snackbar-error-dark-mode.png |

### 디자인 분석

**공통 특징:**
- 둥근 사각형 형태의 스케치 테두리 (두꺼운 hand-drawn 스트로크)
- 왼쪽에 스케치 스타일 아이콘 + 오른쪽에 메시지 텍스트
- 배경에 노이즈 텍스처 (종이 질감)

**타입별 아이콘 스타일:**
- Success: 원 안에 체크마크 (✓)
- Info: 불규칙한 원/blob 안에 "i"
- Warning: 삼각형 안에 "!"
- Error: 둥근 사각형 안에 "x"

**색상 분석:**
| 타입 | Light 배경 | Dark 배경 |
|------|-----------|-----------|
| Success | #D4EDDA (연한 민트) | #1B3B2A (진한 초록) |
| Info | #D6EEFF (연한 하늘) | #0C2D4A (진한 네이비) |
| Warning | #FFF9D6 (연한 레몬) | #3B3515 (진한 올리브) |
| Error | #FFE0E0 (연한 분홍) | #4A1B1B (진한 마룬) |

**테두리/텍스트 색상:**
- Light: 검은색 계열 (base900: #343434)
- Dark: 흰색 계열 (textOnDark: #F5F5F5)

## 플랫폼

**Mobile** — Flutter Design System 패키지

## 영향 범위

| 패키지 | 파일 | 변경 내용 |
|--------|------|----------|
| `core` | `sketch_design_tokens.dart` | snackbar 배경색 토큰 추가 |
| `design_system` | `sketch_theme_extension.dart` | snackbar 색상 속성 추가 |
| `design_system` | `sketch_snackbar_icon_painter.dart` (신규) | 4가지 스케치 아이콘 painter |
| `design_system` | `sketch_snackbar.dart` (신규) | SketchSnackbar 위젯 |
| `design_system` | `design_system.dart` | export 추가 |
| `design_system_demo` | snackbar_demo.dart (신규) | 데모 화면 |
| `design_system_demo` | widget_catalog_controller.dart | 카탈로그 항목 추가 |
| `design_system_demo` | widget_demo_view.dart | 데모 라우팅 추가 |

## 작업 순서 (의존성 기반)

```
[1] 색상 토큰 추가 (core, theme_extension) ← 기반
    ↓
[2] 스케치 아이콘 painter 구현 ← 아이콘 렌더링
    ↓
[3] SketchSnackbar 위젯 구현 ← [1] + [2] 의존
    ↓
[4] design_system.dart export 추가
    ↓
[5] 데모 앱 연동 (demo + catalog)
```

- [1]과 [2]는 **병렬 진행 가능** (서로 독립적)
- [3]은 [1]+[2] 완료 후 진행
- [4]와 [5]는 [3] 완료 후 순차 진행
