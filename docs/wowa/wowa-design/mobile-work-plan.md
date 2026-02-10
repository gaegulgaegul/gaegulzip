# 작업 분배 계획: wowa 앱 디자인 시스템 적용 (Mobile)

## 전체 작업 개요

**작업 유형:** View 레이어 UI 위젯 교체 (Controller/Binding 변경 없음)

**목표:** wowa 앱의 모든 화면에서 Flutter 기본 위젯을 design_system 패키지의 Frame0 스케치 스타일 컴포넌트로 교체하여 일관된 디자인 경험 제공

**핵심 원칙:**
- Controller 파일 절대 수정 금지
- View에서 `controller.변수명`, `controller.메서드명` 그대로 유지
- Obx 반응형 패턴 유지
- const 생성자 적극 활용

**예상 작업 기간:** 4일 (2개 그룹 순차 실행)

**작업 대상 파일:** 10개 View 파일

---

## 실행 그룹

### Group 1 (병렬) — 공통 패턴 교체 (최우선)

**목표:** 모든 화면에 공통적으로 적용되는 위젯을 먼저 교체하여 시각적 일관성 확보

**예상 기간:** 2일

| Agent | 담당 화면 | 교체 항목 | 우선순위 |
|-------|---------|---------|---------|
| flutter-developer-1 | WodRegisterView, WodDetailView, WodSelectView, ProposalReviewView | AppBar → SketchAppBar (4개)<br>CircularProgressIndicator → SketchProgressBar (4개)<br>Container 배지 → SketchChip (4개) | 높음 |
| flutter-developer-2 | BoxSearchView, BoxCreateView, SettingsView, NotificationView | AppBar → SketchAppBar (4개)<br>CircularProgressIndicator → SketchProgressBar (2개) | 높음 |
| flutter-developer-3 | HomeView, LoginView | AppBar는 없음<br>CircularProgressIndicator → SketchProgressBar (HomeView)<br>Container 배지 → SketchChip (HomeView 2개)<br>TextButton → SketchButton (LoginView) | 높음 |

#### flutter-developer-1 상세 작업

**담당 화면:**
1. `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_register_view.dart`
2. `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`
3. `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`
4. `apps/mobile/apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`

**교체 항목:**

##### 1. WodRegisterView
- [ ] AppBar → SketchAppBar (title: 'WOD 등록')
- [ ] import 추가: `import 'package:design_system/design_system.dart';`

##### 2. WodDetailView
- [ ] AppBar → SketchAppBar (title: 'WOD 상세')
- [ ] CircularProgressIndicator → SketchProgressBar (style: circular, value: null, size: 48)
- [ ] Container (BASE 배지) → SketchChip (label: 'BASE WOD', selected: true, fillColor: SketchDesignTokens.info)
- [ ] Container (PERSONAL 배지) → SketchChip (label: 'PERSONAL', selected: true, fillColor: SketchDesignTokens.warning)

##### 3. WodSelectView
- [ ] AppBar → SketchAppBar (title: 'WOD 선택')
- [ ] CircularProgressIndicator → SketchProgressBar (style: circular, value: null, size: 48)
- [ ] Container (BASE 배지) → SketchChip (label: 'BASE', selected: true, fillColor: SketchDesignTokens.info)
- [ ] Container (PERSONAL 배지) → SketchChip (label: 'PERSONAL', selected: true, fillColor: SketchDesignTokens.warning)

##### 4. ProposalReviewView
- [ ] AppBar → SketchAppBar (title: '제안 검토')
- [ ] CircularProgressIndicator → SketchProgressBar (style: circular, value: null, size: 48)
- [ ] Container (Before/After 라벨 배지) → SketchChip (label: title, selected: true, fillColor: 적절한 색상)

**교체 패턴:**
```dart
// Before
AppBar(title: const Text('WOD 등록'))

// After
SketchAppBar(title: 'WOD 등록')

// Before
const CircularProgressIndicator()

// After
const SketchProgressBar(
  style: SketchProgressBarStyle.circular,
  value: null,
  size: 48,
)

// Before - BASE 배지
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.blue[100],
    borderRadius: BorderRadius.circular(4),
  ),
  child: const Text('BASE',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
)

// After
const SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)
```

**검증 방법:**
```bash
cd apps/mobile
melos analyze
flutter run
```

**검증 기준:**
- [ ] 모든 AppBar가 스케치 스타일로 표시됨
- [ ] 로딩 상태에서 스케치 프로그레스 바가 표시됨
- [ ] BASE/PERSONAL 배지가 스케치 칩으로 표시됨
- [ ] 버튼 클릭, 라우팅 정상 작동

---

#### flutter-developer-2 상세 작업

**담당 화면:**
1. `apps/mobile/apps/wowa/lib/app/modules/box/views/box_search_view.dart`
2. `apps/mobile/apps/wowa/lib/app/modules/box/views/box_create_view.dart`
3. `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`
4. `apps/mobile/apps/wowa/lib/app/modules/notification/views/notification_view.dart`

**교체 항목:**

##### 1. BoxSearchView
- [ ] AppBar → SketchAppBar (title: '박스 찾기', centerTitle: true)
- [ ] CircularProgressIndicator → SketchProgressBar (style: circular, value: null, size: 48)
- [ ] import 추가: `import 'package:design_system/design_system.dart';` (이미 있을 수 있음)

**비고:** 이 화면은 이미 SketchDesignTokens를 잘 활용 중이므로 AppBar와 ProgressBar만 교체

##### 2. BoxCreateView
- [ ] AppBar → SketchAppBar (title: '새 박스 만들기', centerTitle: true)

**비고:** 이 화면은 거의 완벽하게 디자인 시스템을 사용 중이므로 AppBar만 교체

##### 3. SettingsView
- [ ] AppBar → SketchAppBar (title: '설정')
- [ ] CircularProgressIndicator → SketchProgressBar (style: circular, value: null, size: 48)

##### 4. NotificationView
- [ ] AppBar → SketchAppBar (title: '알림', leading: back 버튼)

**비고:** 이 화면은 가장 잘 구현된 예시로, AppBar만 교체

**교체 패턴:**
```dart
// Before
AppBar(
  title: const Text('박스 찾기'),
  centerTitle: true,
)

// After
SketchAppBar(
  title: '박스 찾기',
  centerTitle: true,
)
```

**검증 방법:**
```bash
cd apps/mobile
melos analyze
flutter run
```

**검증 기준:**
- [ ] 모든 AppBar가 스케치 스타일로 표시됨
- [ ] ProgressBar가 스케치 스타일로 표시됨 (BoxSearchView, SettingsView)
- [ ] 기존 기능 정상 작동 (검색, 생성, 설정, 알림)

---

#### flutter-developer-3 상세 작업

**담당 화면:**
1. `apps/mobile/apps/wowa/lib/app/modules/wod/views/home_view.dart`
2. `apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`

**교체 항목:**

##### 1. HomeView
- [ ] CircularProgressIndicator → SketchProgressBar (style: circular, value: null, size: 48)
- [ ] Container (BASE 배지) → SketchChip (label: 'BASE', selected: true, fillColor: SketchDesignTokens.info)
- [ ] Container (PERSONAL 배지) → SketchChip (label: 'PERSONAL', selected: true, fillColor: SketchDesignTokens.warning)
- [ ] import 추가: `import 'package:design_system/design_system.dart';`

**비고:** HomeView는 AppBar가 없고, 이미 SketchButton과 SketchCard를 사용 중

##### 2. LoginView
- [ ] TextButton (둘러보기) → SketchButton (text: '둘러보기', style: SketchButtonStyle.outline, size: SketchButtonSize.medium)
- [ ] import 추가: `import 'package:design_system/design_system.dart';` (이미 있을 수 있음)

**교체 패턴:**
```dart
// Before - 둘러보기 버튼
TextButton(
  onPressed: () => Get.toNamed(Routes.HOME),
  child: const Text('둘러보기'),
)

// After
SketchButton(
  text: '둘러보기',
  style: SketchButtonStyle.outline,
  size: SketchButtonSize.medium,
  onPressed: () => Get.toNamed(Routes.HOME),
)

// Before - BASE 배지
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.blue[100],
    borderRadius: BorderRadius.circular(4),
  ),
  child: const Text('BASE',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
)

// After
const SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)
```

**검증 방법:**
```bash
cd apps/mobile
melos analyze
flutter run
```

**검증 기준:**
- [ ] "둘러보기" 버튼이 아웃라인 스타일로 표시됨
- [ ] HomeView의 BASE/PERSONAL 배지가 스케치 칩으로 표시됨
- [ ] 로딩 상태가 스케치 프로그레스로 표시됨
- [ ] 라우팅 정상 작동

---

### Group 2 (병렬) — 화면별 세부 교체 (Group 1 완료 후)

**목표:** 각 화면의 세부적인 위젯을 교체하여 완전한 디자인 일관성 확보

**예상 기간:** 2일

| Agent | 담당 화면 | 교체 항목 | 우선순위 |
|-------|---------|---------|---------|
| flutter-developer-4 | HomeView, WodSelectView | IconButton → SketchIconButton (HomeView)<br>경고 배너 Container → SketchCard (WodSelectView)<br>Icon 라디오 → SketchRadio (WodSelectView)<br>Icon 색상 → SketchDesignTokens (HomeView) | 중간 |
| flutter-developer-5 | LoginView, WodRegisterView, SettingsView | Text 스타일 → SketchDesignTokens (LoginView 타이틀/부제목)<br>Icon 색상 → SketchDesignTokens (WodRegisterView)<br>Container 뱃지 → SketchIconButton.badgeCount (SettingsView)<br>Icon 색상 → SketchDesignTokens (SettingsView) | 중간 |
| flutter-developer-6 | WodDetailView, ProposalReviewView | Icon 색상 → SketchDesignTokens (알림 아이콘 등)<br>Text 스타일 → SketchDesignTokens | 낮음 |

#### flutter-developer-4 상세 작업

**담당 화면:**
1. `apps/mobile/apps/wowa/lib/app/modules/wod/views/home_view.dart`
2. `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`

**교체 항목:**

##### 1. HomeView
- [ ] IconButton (날짜 좌우 화살표) → SketchIconButton (icon: Icons.chevron_left/chevron_right, tooltip: '이전/다음 날짜')
- [ ] Icon (빈 상태) → Icon + SketchDesignTokens (color: SketchDesignTokens.base300, size: 48)
- [ ] Text (박스명, 날짜, 지역 등) → Text + SketchDesignTokens (fontSize, color, fontFamily)

**교체 패턴:**
```dart
// Before
IconButton(
  icon: const Icon(Icons.chevron_left),
  onPressed: controller.previousDay,
)

// After
SketchIconButton(
  icon: Icons.chevron_left,
  tooltip: '이전 날짜',
  onPressed: controller.previousDay,
)

// Before
const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey)

// After
const Icon(
  Icons.inbox_outlined,
  size: 48,
  color: SketchDesignTokens.base300,
)
```

##### 2. WodSelectView
- [ ] Container (경고 배너) → SketchCard (margin: all(SketchDesignTokens.spacingLg), borderColor: SketchDesignTokens.warning, strokeWidth: SketchDesignTokens.strokeBold, fillColor: Color(0xFFFFF8E1), body: Row(...))
- [ ] Icon (라디오 버튼) → SketchRadio (value: wod.id, groupValue: controller.selectedWodId.value, onChanged: (_) => controller.selectWod(wod.id))

**교체 패턴:**
```dart
// Before - 경고 배너
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  margin: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.amber[50],
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.amber[300]!),
  ),
  child: const Row(...),
)

// After
SketchCard(
  margin: const EdgeInsets.all(SketchDesignTokens.spacingLg),
  borderColor: SketchDesignTokens.warning,
  strokeWidth: SketchDesignTokens.strokeBold,
  fillColor: const Color(0xFFFFF8E1), // amber[50] 대응
  padding: const EdgeInsets.all(SketchDesignTokens.spacingMd),
  body: const Row(...),
)

// Before - 라디오 버튼
Icon(
  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
  color: isSelected ? Colors.blue : Colors.grey,
)

// After
SketchRadio(
  value: wod.id,
  groupValue: controller.selectedWodId.value,
  onChanged: (_) => controller.selectWod(wod.id),
)
```

**검증 기준:**
- [ ] 날짜 화살표가 스케치 아이콘 버튼으로 표시됨
- [ ] 경고 배너가 스케치 카드로 표시됨
- [ ] 라디오 버튼이 스케치 라디오로 표시됨
- [ ] 선택 상태가 정상 반응

---

#### flutter-developer-5 상세 작업

**담당 화면:**
1. `apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`
2. `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_register_view.dart`
3. `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`

**교체 항목:**

##### 1. LoginView
- [ ] Text (타이틀 "로그인") → Text + SketchDesignTokens (fontSize: fontSize3Xl, fontFamily: fontFamilyHand, color: base900)
- [ ] Text (부제목 "소셜 계정으로...") → Text + SketchDesignTokens (fontSize: fontSizeSm, color: base700)

**교체 패턴:**
```dart
// Before
const Text(
  '로그인',
  style: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
)

// After
const Text(
  '로그인',
  style: TextStyle(
    fontSize: SketchDesignTokens.fontSize3Xl,
    fontFamily: SketchDesignTokens.fontFamilyHand,
    color: SketchDesignTokens.base900,
  ),
)
```

##### 2. WodRegisterView
- [ ] Icon (닫기) → Icon + SketchDesignTokens (color: SketchDesignTokens.error, size: 18)
- [ ] Text (섹션 제목) → Text + SketchDesignTokens (fontSize: fontSizeBase, fontFamily: fontFamilyHand)

##### 3. SettingsView
- [ ] Container (공지사항 미읽음 뱃지) → SketchIconButton (icon: Icons.notifications_outlined, badgeCount: controller.unreadCount.value, onPressed: controller.goToNoticeList)
- [ ] Icon (다양한 아이콘) → Icon + SketchDesignTokens (color: base700 등)

**교체 패턴:**
```dart
// Before - 공지사항 미읽음 뱃지
Container(
  padding: EdgeInsets.symmetric(
    horizontal: count < 10 ? 6 : 4,
    vertical: 2,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFF44336),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.white, width: 2),
  ),
  child: Text(...),
)

// After - SketchIconButton의 badgeCount 속성 활용
SketchIconButton(
  icon: Icons.notifications_outlined,
  badgeCount: controller.unreadCount.value,
  onPressed: controller.goToNoticeList,
)
```

**검증 기준:**
- [ ] LoginView 타이틀이 Hand 폰트로 표시됨
- [ ] SettingsView 미읽음 뱃지가 SketchIconButton으로 표시됨
- [ ] 아이콘 색상이 일관됨

---

#### flutter-developer-6 상세 작업

**담당 화면:**
1. `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`
2. `apps/mobile/apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`

**교체 항목:**

##### 1. WodDetailView
- [ ] Icon (알림 아이콘) → Icon + SketchDesignTokens (color: SketchDesignTokens.warning)
- [ ] Text (다양한 텍스트) → Text + SketchDesignTokens (fontSize, color, fontFamily)

##### 2. ProposalReviewView
- [ ] Container (Before/After 배경 강조) → 제거 후 SketchCard의 fillColor 활용
- [ ] Text (다양한 텍스트) → Text + SketchDesignTokens (fontSize, color, fontFamily)

**교체 패턴:**
```dart
// Before
const Icon(Icons.warning_amber_outlined, size: 18, color: Colors.orange)

// After
const Icon(
  Icons.warning_amber_outlined,
  size: 18,
  color: SketchDesignTokens.warning,
)
```

**검증 기준:**
- [ ] 아이콘 색상이 일관됨
- [ ] 텍스트 스타일이 디자인 토큰 사용

---

## 공통 가이드라인

### Import 패턴

모든 View 파일에 다음 import 추가 (이미 있는 경우 생략):

```dart
import 'package:design_system/design_system.dart';
```

### 색상 매핑 가이드

| 기존 색상 | SketchDesignTokens |
|---------|-------------------|
| `Colors.black87` | `SketchDesignTokens.base900` |
| `Colors.grey[600]` | `SketchDesignTokens.base700` |
| `Colors.grey[500]` | `SketchDesignTokens.base500` |
| `Colors.grey[400]` | `SketchDesignTokens.base300` |
| `Colors.grey` | `SketchDesignTokens.base500` |
| `Colors.blue` | `SketchDesignTokens.info` |
| `Colors.orange` | `SketchDesignTokens.warning` |
| `Colors.red` | `SketchDesignTokens.error` |
| `Colors.green` | `SketchDesignTokens.success` |

### 크기 매핑 가이드

| 기존 크기 | SketchDesignTokens |
|---------|-------------------|
| 30px | `SketchDesignTokens.fontSize3Xl` |
| 24px | `SketchDesignTokens.fontSize2Xl` |
| 20px | `SketchDesignTokens.fontSizeXl` |
| 18px | `SketchDesignTokens.fontSizeLg` |
| 16px | `SketchDesignTokens.fontSizeBase` |
| 14px | `SketchDesignTokens.fontSizeSm` |
| 12px | `SketchDesignTokens.fontSizeXs` |

### 간격 매핑 가이드

| 기존 간격 | SketchDesignTokens |
|---------|-------------------|
| 4px | `SketchDesignTokens.spacingXs` |
| 8px | `SketchDesignTokens.spacingSm` |
| 12px | `SketchDesignTokens.spacingMd` |
| 16px | `SketchDesignTokens.spacingLg` |
| 24px | `SketchDesignTokens.spacingXl` |
| 32px | `SketchDesignTokens.spacing2Xl` |

### const 생성자 활용

모든 위젯은 가능한 한 const 생성자를 사용하여 성능 최적화:

```dart
// 좋은 예
const SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)

// 나쁜 예
SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)
```

### Controller 변경 금지

**절대 금지:**
- Controller 파일 수정
- `.obs` 변수명 변경
- 메서드명 변경
- Obx 패턴 제거

**반드시 유지:**
- View에서 `controller.변수명`, `controller.메서드명` 그대로 사용
- Obx 내부의 `.value` 접근 패턴 유지

---

## 검증 방법

### 정적 분석

모든 작업 완료 후 다음 명령어로 정적 분석 실행:

```bash
cd apps/mobile
melos analyze
```

**검증 기준:**
- [ ] 모든 파일에서 린트 에러 없음
- [ ] import 에러 없음
- [ ] 타입 에러 없음

### 화면별 시각적 검증

각 화면을 실행하여 다음을 확인:

```bash
cd apps/mobile/apps/wowa
flutter run
```

**검증 항목:**
- [ ] LoginView: 둘러보기 버튼, 타이틀 폰트
- [ ] HomeView: 프로그레스바, 배지, 아이콘 버튼
- [ ] WodRegisterView: AppBar, 아이콘 색상
- [ ] WodDetailView: AppBar, 프로그레스바, 배지
- [ ] WodSelectView: AppBar, 경고 배너, 라디오 버튼, 배지
- [ ] ProposalReviewView: AppBar, 프로그레스바, 배지
- [ ] BoxSearchView: AppBar, 프로그레스바
- [ ] BoxCreateView: AppBar
- [ ] SettingsView: AppBar, 프로그레스바, 뱃지
- [ ] NotificationView: AppBar

### 기능 테스트

각 화면의 주요 기능이 정상 작동하는지 확인:

- [ ] 버튼 클릭 시 정상 액션 실행
- [ ] 라우팅 정상 작동
- [ ] 입력 필드 정상 입력
- [ ] 로딩 상태 정상 표시
- [ ] 에러 상태 정상 표시

### 성능 테스트

- [ ] 화면 전환 시 렌더링 지연 없음
- [ ] 스크롤 성능 저하 없음
- [ ] 리빌드 최소화 확인 (Flutter DevTools)

### 다크 모드 테스트

- [ ] 다크 모드에서 색상 대비 충분
- [ ] SketchThemeExtension.dark() 적용 확인

---

## 참고 문서

### 필수 참조 가이드

| 상황 | 참조 가이드 |
|------|------------|
| 디자인 시스템 컴포넌트 사용법 | `.claude/guide/mobile/design_system.md` |
| 디자인 토큰 (색상, 간격, 폰트) | `.claude/guide/mobile/design-tokens.json` |
| GetX 패턴 (Controller/View 분리) | `.claude/guide/mobile/getx_best_practices.md` |
| Flutter 위젯 개발 (const, 성능) | `.claude/guide/mobile/flutter_best_practices.md` |
| 공통 위젯 패턴 | `.claude/guide/mobile/common_widgets.md` |
| Import 패턴 | `.claude/guide/mobile/common_patterns.md` |
| 성능 최적화 | `.claude/guide/mobile/performance.md` |

### 관련 문서

- **사용자 스토리:** `docs/wowa/wowa-design/user-story.md`
- **디자인 명세:** `docs/wowa/wowa-design/mobile-design-spec.md`
- **기술 설계:** `docs/wowa/wowa-design/mobile-brief.md`
- **design_system 패키지:** `apps/mobile/packages/design_system/`
- **Frame0.app:** https://frame0.app

---

## 위험 요소 및 대응책

### 1. Controller 로직 깨짐 방지

**위험:**
- `.obs` 변수명 변경 시 Obx가 더 이상 반응하지 않음
- onPressed 콜백 제거 시 버튼 클릭 불가

**대응책:**
- Controller 파일 절대 수정 금지
- View의 `controller.변수명`, `controller.메서드명` 그대로 유지
- Obx 내부의 `.value` 접근 패턴 유지

### 2. 반응형 상태 유지

**위험:**
- Obx를 제거하면 UI가 더 이상 업데이트되지 않음

**대응책:**
- 기존 Obx 패턴 그대로 유지
- SketchButton의 `isLoading`을 `controller.isLoading.value`와 연결

### 3. 색상 대비 확인

**위험:**
- SketchDesignTokens의 색상이 기존 색상과 대비가 달라 가독성 저하

**대응책:**
- 다크 모드에서 충분한 대비 유지
- 에러 메시지는 색상 + 텍스트로 명확히 전달

### 4. 폰트 로딩

**위험:**
- PatrickHand 폰트가 로딩되지 않으면 기본 폰트로 fallback

**대응책:**
- design_system 패키지의 `pubspec.yaml`에 폰트 정의 확인
- 앱 시작 시 폰트 로딩 확인

---

## 커밋 메시지 가이드

### Group 1 커밋

```
refactor(wowa-design): Replace Flutter widgets with Sketch components in Group 1

- Replace AppBar → SketchAppBar (8 screens)
- Replace CircularProgressIndicator → SketchProgressBar (6 screens)
- Replace Container badges → SketchChip (4 screens)
- Replace TextButton → SketchButton (LoginView)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

### Group 2 커밋

```
refactor(wowa-design): Apply Sketch design tokens and detail refinements in Group 2

- Replace IconButton → SketchIconButton (HomeView)
- Replace warning banner Container → SketchCard (WodSelectView)
- Replace radio Icon → SketchRadio (WodSelectView)
- Replace badge Container → SketchIconButton.badgeCount (SettingsView)
- Apply SketchDesignTokens to Text, Icon colors

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

---

## 다음 단계

1. **CTO 승인** - 이 작업 분배 계획을 검토하고 승인
2. **Group 1 시작** - 3명의 Flutter Developer가 병렬로 공통 패턴 교체
3. **Group 1 검증** - 정적 분석 + 시각적 검증 + 기능 테스트
4. **Group 2 시작** - 3명의 Flutter Developer가 병렬로 세부 교체 (Group 1 완료 후)
5. **Group 2 검증** - 정적 분석 + 시각적 검증 + 기능 테스트
6. **최종 QA** - 모든 화면 통합 테스트 + 다크 모드 테스트
7. **PR 생성** - main 브랜치로 PR 생성 및 리뷰 요청

---

**이 작업 분배 계획은 wowa 앱의 디자인 일관성을 확보하기 위한 완전한 가이드입니다.**
