# UI/UX 디자인 명세: wowa 앱 디자인 시스템 적용

## 개요

wowa 앱의 모든 화면에서 일관된 디자인 경험을 제공하기 위해, Flutter 기본 위젯을 design_system 패키지의 Frame0 스케치 스타일 컴포넌트로 교체합니다. 이번 작업은 **기존 디자인 시스템 컴포넌트를 이미 사용 중인 화면**을 분석하고, **Flutter 기본 위젯이 남아있는 부분**을 식별하여 교체 계획을 수립하는 것이 목표입니다.

**핵심 원칙:**
- Frame0 스케치 스타일의 손그림 느낌 유지 (프로토타입임을 알리는 디자인)
- 모든 디자인 값은 SketchDesignTokens에서 가져옴 (하드코딩 금지)
- roughness 기본값 0.8 유지
- accentPrimary (#DF7D5F 코랄/오렌지) 기본 강조색 사용
- const 생성자 적극 활용, seed 고정으로 불필요한 리페인트 방지

---

## 현재 상태 분석

### 디자인 시스템 컴포넌트 목록 (design_system 패키지 제공)

| 컴포넌트 | 용도 | 주요 속성 |
|---------|------|---------|
| **SketchButton** | 버튼 (primary/secondary/outline) | text, icon, isLoading, size |
| **SketchCard** | 카드 레이아웃 (header/body/footer) | elevation, onTap, padding |
| **SketchInput** | 텍스트 입력 필드 | label, hint, errorText, prefixIcon, suffixIcon |
| **SketchChip** | 선택 가능한 태그/칩 | label, selected, onSelected, icon, onDeleted |
| **SketchProgressBar** | 로딩 표시 (linear/circular) | value, style, showPercentage |
| **SketchModal** | 다이얼로그 모달 | title, child, actions, barrierDismissible |
| **SketchIconButton** | 아이콘 버튼 | icon, tooltip, badgeCount, shape |
| **SketchContainer** | 기본 스케치 컨테이너 | fillColor, borderColor, strokeWidth, roughness |
| **SketchSwitch** | 토글 스위치 | value, onChanged |
| **SketchCheckbox** | 체크박스 | value, tristate, onChanged |
| **SketchSlider** | 슬라이더 | value, min, max, divisions, label |
| **SketchDropdown** | 드롭다운 선택 | value, items, hint, itemBuilder |
| **SketchAppBar** | 앱바 | title, leading, actions |
| **SketchBottomNavigationBar** | 하단 네비게이션 | items, currentIndex, onTap |
| **SketchAvatar** | 아바타 | imageUrl, name, size, shape |
| **SketchDivider** | 구분선 | height, thickness, color |
| **SketchLink** | 링크 텍스트 | text, url, style |
| **SketchNumberInput** | 숫자 입력 | value, min, max, step |
| **SketchRadio** | 라디오 버튼 | value, groupValue, onChanged |
| **SketchSearchInput** | 검색 입력 | controller, hint, onSearch, onClear |
| **SketchTabBar** | 탭 바 | tabs, controller |
| **SketchTextArea** | 여러 줄 텍스트 | controller, maxLines, maxLength |
| **SocialLoginButton** | 소셜 로그인 버튼 | platform, size, isLoading, appleStyle |

---

## 화면별 현재 상태 및 변경 계획

### 1. LoginView (로그인 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SocialLoginButton` | 36-72 | ✅ 이미 디자인 시스템 사용 (변경 불필요) |
| `TextButton` | 77-80 | "둘러보기" 버튼 |
| `Text` (타이틀) | 91-98 | "로그인" 제목 - 하드코딩된 스타일 |
| `Text` (부제목) | 103-109 | "소셜 계정으로..." - 하드코딩된 색상 |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `TextButton` (둘러보기) | `SketchButton` | style: outline, size: medium | 높음 |
| `Text` (타이틀) | `Text` + SketchDesignTokens | fontSize: fontSize3Xl, fontWeight 제거 (Hand 폰트 사용) | 중간 |
| `Text` (부제목) | `Text` + SketchDesignTokens | fontSize: fontSizeSm, color: base700 | 중간 |

#### 교체 후 코드 예시

```dart
// Before
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

---

### 2. HomeView (홈 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/home_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchButton` | 126-130, 236-250 | ✅ 이미 디자인 시스템 사용 |
| `SketchCard` | 172-214 | ✅ 이미 디자인 시스템 사용 |
| `IconButton` | 75-77, 95-97 | 날짜 좌우 화살표 |
| `Icon` | 51, 122 | 박스 아이콘, 빈 상태 아이콘 |
| `CircularProgressIndicator` | 111 | 로딩 표시 |
| `Container` (배지) | 175-186, 187-198 | BASE/PERSONAL 배지 - 하드코딩 색상 |
| `Text` (다양한 위치) | 53-56, 58-61, 83-90, 124, 150-155 | 하드코딩된 색상/크기 |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `IconButton` | `SketchIconButton` | icon: chevron_left/chevron_right | 중간 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (BASE 배지) | `SketchChip` | label: 'BASE', selected: true, fillColor: info | 높음 |
| `Container` (PERSONAL 배지) | `SketchChip` | label: 'PERSONAL', selected: true, fillColor: warning | 높음 |
| `Icon` (빈 상태) | `Icon` + SketchDesignTokens | color: base300, size: 48 | 중간 |
| `Text` (박스명) | `Text` + SketchDesignTokens | fontSize: fontSizeLg, fontWeight 제거 | 낮음 |
| `Text` (지역) | `Text` + SketchDesignTokens | color: base700, fontSize: fontSizeSm | 낮음 |
| `Text` (날짜) | `Text` + SketchDesignTokens | fontSize: fontSizeXl, fontWeight 제거 | 낮음 |
| `Text` (요일) | `Text` + SketchDesignTokens | color: base700, fontSize: fontSizeSm | 낮음 |

#### 교체 후 코드 예시

```dart
// Before
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

// Before
const Center(
  child: Padding(
    padding: EdgeInsets.all(32),
    child: CircularProgressIndicator(),
  ),
)

// After
const Center(
  child: Padding(
    padding: EdgeInsets.all(SketchDesignTokens.spacing2Xl),
    child: SketchProgressBar(
      style: SketchProgressBarStyle.circular,
      value: null,
      size: 48,
    ),
  ),
)
```

---

### 3. WodRegisterView (WOD 등록 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_register_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchChip` | 69-74 | ✅ 이미 디자인 시스템 사용 |
| `SketchInput` | 90-96, 100-106, 112-118, 128-133, 195-198, 202-207, 210-216, 219-224 | ✅ 이미 디자인 시스템 사용 |
| `SketchCard` | 175-231 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 147-152, 240-247 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 15 | Flutter 기본 AppBar |
| `Icon` | 181, 189 | 드래그 핸들, 닫기 아이콘 - 하드코딩 색상 |
| `Text` | 63-64, 144-145, 183 | 하드코딩된 크기/굵기 |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: 'WOD 등록' | 높음 |
| `Icon` (닫기) | `Icon` + SketchDesignTokens | color: error, size: 18 | 중간 |
| `Text` (섹션 제목) | `Text` + SketchDesignTokens | fontSize: fontSizeBase, fontWeight 제거 | 낮음 |

#### 교체 후 코드 예시

```dart
// Before
AppBar(title: const Text('WOD 등록'))

// After
SketchAppBar(title: 'WOD 등록')

// Before
const Icon(Icons.close, size: 18, color: Colors.red)

// After
const Icon(Icons.close, size: 18, color: SketchDesignTokens.error)
```

---

### 4. WodDetailView (WOD 상세 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchCard` | 61-79, 120-140, 155-179 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 189-202 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 19 | Flutter 기본 AppBar |
| `CircularProgressIndicator` | 23 | 로딩 표시 |
| `Container` (배지) | 64-71, 111-116, 158-164 | BASE/PERSONAL 배지 - 하드코딩 색상 |
| `Icon` | 123, 136 | 알림 아이콘, 화살표 - 하드코딩 색상 |
| `Text` | 149-150 | 하드코딩된 크기/굵기 |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: 'WOD 상세' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (BASE 배지) | `SketchChip` | label: 'BASE WOD', selected: true, fillColor: info | 높음 |
| `Container` (PERSONAL 배지) | `SketchChip` | label: 'PERSONAL', selected: true, fillColor: warning | 높음 |
| `Icon` (알림) | `Icon` + SketchDesignTokens | color: warning | 중간 |

---

### 5. WodSelectView (WOD 선택 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchCard` | 102-146 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 156-163 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 18 | Flutter 기본 AppBar |
| `CircularProgressIndicator` | 22 | 로딩 표시 |
| `Container` (경고 배너) | 44-64 | 하드코딩된 색상, BorderRadius |
| `Icon` (라디오) | 106-109 | 라디오 버튼 - 하드코딩 색상 |
| `Container` (배지) | 111-122 | BASE/PERSONAL 배지 - 하드코딩 색상 |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: 'WOD 선택' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (경고 배너) | `SketchCard` | elevation: 1, borderColor: warning, strokeWidth: bold | 높음 |
| `Icon` (라디오) | `SketchRadio` | value: wod.id, groupValue: selectedWodId | 중간 |
| `Container` (배지) | `SketchChip` | label, selected: true, fillColor | 높음 |

#### 교체 후 코드 예시

```dart
// Before
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
  fillColor: Color(0xFFFFF8E1), // amber[50] 대응
  padding: const EdgeInsets.all(SketchDesignTokens.spacingMd),
  body: Row(...),
)

// Before
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

---

### 6. ProposalReviewView (제안 검토 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchCard` | 90-142 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 152-168 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 18 | Flutter 기본 AppBar |
| `CircularProgressIndicator` | 22 | 로딩 표시 |
| `Container` (배경 강조) | 98-102 | Before/After 배경색 - 하드코딩 |
| `Container` (라벨 배지) | 106-114 | Before/After 라벨 - 하드코딩 색상 |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '제안 검토' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (배경 강조) | 제거 후 SketchCard의 fillColor 활용 | fillColor 직접 설정 | 중간 |
| `Container` (라벨 배지) | `SketchChip` | label: title, selected: true, fillColor | 높음 |

---

### 7. BoxSearchView (박스 검색 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/box/views/box_search_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchInput` | 50-68 | ✅ 이미 디자인 시스템 사용 |
| `SketchCard` | 205-294 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 180-184, 286-291, 298-304 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 34-42 | Flutter 기본 AppBar |
| `CircularProgressIndicator` | 78 | 로딩 표시 |
| `Icon` | 54, 60, 108, 133, 166, 231, 268 | 다양한 아이콘 - SketchDesignTokens 사용 중 ✅ |
| `Text` | 114-120, 138-157, 171-178 | SketchDesignTokens 사용 중 ✅ |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '박스 찾기', centerTitle: true | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |

**비고:** 이 화면은 이미 SketchDesignTokens를 매우 잘 활용하고 있어 추가 교체가 거의 불필요합니다.

---

### 8. BoxCreateView (박스 생성 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/box/views/box_create_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchInput` | 58-65, 70-78, 83-89 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 97-106 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 44-52 | Flutter 기본 AppBar |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '새 박스 만들기', centerTitle: true | 높음 |

**비고:** 이 화면은 거의 완벽하게 디자인 시스템을 사용 중입니다.

---

### 9. SettingsView (설정 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchCard` | 50-73, 141-174 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 181-187 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 15 | Flutter 기본 AppBar |
| `CircularProgressIndicator` | 19 | 로딩 표시 |
| `Container` (뱃지) | 89-114 | 공지사항 미읽음 배지 - 하드코딩 색상 |
| `Icon` | 59, 123, 148, 170 | 다양한 아이콘 - 하드코딩 색상 |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '설정' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (뱃지) | `SketchIconButton` + badgeCount | badgeCount: unreadCount | 높음 |
| `Icon` | `Icon` + SketchDesignTokens | color: base700 등 | 중간 |

#### 교체 후 코드 예시

```dart
// Before
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

---

### 10. NotificationView (알림 목록 화면)

**경로:** `apps/mobile/apps/wowa/lib/app/modules/notification/views/notification_view.dart`

#### 현재 상태

| 현재 위젯 | 라인 | 용도 |
|----------|------|------|
| `SketchProgressBar` | 59-63 | ✅ 이미 디자인 시스템 사용 |
| `SketchButton` | 99-103 | ✅ 이미 디자인 시스템 사용 |
| `SketchCard` | 222-301 | ✅ 이미 디자인 시스템 사용 |
| `SketchChip` | 259-263 | ✅ 이미 디자인 시스템 사용 |
| `AppBar` | 19-33 | Flutter 기본 AppBar - SketchDesignTokens 사용 중 |
| `RefreshIndicator` | 35-38 | SketchDesignTokens.accentPrimary 사용 중 ✅ |
| `CircularProgressIndicator` | 195-198 | 페이징 로더 - SketchDesignTokens 사용 중 ✅ |
| `Icon` | 75-79, 118-122, 292-296 | SketchDesignTokens 사용 중 ✅ |
| `Text` | 26-32, 81-97, 124-140, 244-288 | SketchDesignTokens 사용 중 ✅ |

#### 교체 계획

| 현재 위젯 | 교체 위젯 | 변경 사항 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '알림', leading: back 버튼 | 중간 |

**비고:** 이 화면은 **가장 잘 구현된 예시**로, SketchDesignTokens를 완벽하게 활용하고 있습니다. AppBar만 SketchAppBar로 교체하면 됩니다.

---

## 공통 패턴 교체 가이드

### 1. AppBar → SketchAppBar

**모든 화면에 적용 (최우선)**

| 화면 | 현재 | 교체 후 |
|-----|------|--------|
| WodRegisterView | `AppBar(title: const Text('WOD 등록'))` | `SketchAppBar(title: 'WOD 등록')` |
| WodDetailView | `AppBar(title: const Text('WOD 상세'))` | `SketchAppBar(title: 'WOD 상세')` |
| WodSelectView | `AppBar(title: const Text('WOD 선택'))` | `SketchAppBar(title: 'WOD 선택')` |
| ProposalReviewView | `AppBar(title: const Text('제안 검토'))` | `SketchAppBar(title: '제안 검토')` |
| BoxSearchView | `AppBar(...)` | `SketchAppBar(title: '박스 찾기', centerTitle: true)` |
| BoxCreateView | `AppBar(...)` | `SketchAppBar(title: '새 박스 만들기', centerTitle: true)` |
| SettingsView | `AppBar(title: const Text('설정'))` | `SketchAppBar(title: '설정')` |
| NotificationView | `AppBar(...)` | `SketchAppBar(title: '알림', leading: back)` |

**주의사항:**
- `SketchAppBar`는 자동으로 뒤로가기 버튼을 표시합니다 (leading 생략 가능)
- `centerTitle`, `actions` 등의 속성은 동일하게 사용 가능

### 2. CircularProgressIndicator → SketchProgressBar

**로딩 상태 표시 통일**

```dart
// Before
const CircularProgressIndicator()

// After
const SketchProgressBar(
  style: SketchProgressBarStyle.circular,
  value: null, // indeterminate
  size: 48,
)
```

**적용 화면:** HomeView, WodDetailView, WodSelectView, ProposalReviewView, BoxSearchView, SettingsView

### 3. Container (배지) → SketchChip

**BASE/PERSONAL 배지 통일**

```dart
// Before - BASE
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.blue[100],
    borderRadius: BorderRadius.circular(4),
  ),
  child: const Text('BASE',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
)

// After - BASE
const SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)

// Before - PERSONAL
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.orange[100],
    borderRadius: BorderRadius.circular(4),
  ),
  child: const Text('PERSONAL',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
)

// After - PERSONAL
const SketchChip(
  label: 'PERSONAL',
  selected: true,
  fillColor: SketchDesignTokens.warning,
)
```

**적용 화면:** HomeView, WodDetailView, WodSelectView, ProposalReviewView

### 4. IconButton → SketchIconButton

**아이콘 버튼 통일**

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
```

**적용 화면:** HomeView (날짜 화살표)

### 5. 하드코딩된 색상/크기 → SketchDesignTokens

**모든 Text 위젯 스타일링 통일**

```dart
// Before
Text(
  '제목',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
)

// After
Text(
  '제목',
  style: TextStyle(
    fontSize: SketchDesignTokens.fontSizeLg,
    fontFamily: SketchDesignTokens.fontFamilyHand,
    color: SketchDesignTokens.base900,
  ),
)

// Before
Icon(Icons.error_outline, size: 48, color: Colors.grey[400])

// After
const Icon(
  Icons.error_outline,
  size: 48,
  color: SketchDesignTokens.base300,
)
```

**공통 색상 매핑:**
| 기존 | SketchDesignTokens |
|-----|-------------------|
| `Colors.black87` | `base900` |
| `Colors.grey[600]` | `base700` |
| `Colors.grey[400]` | `base300` |
| `Colors.grey[500]` | `base500` |
| `Colors.blue` | `info` |
| `Colors.orange` | `warning` |
| `Colors.red` | `error` |

**공통 크기 매핑:**
| 기존 | SketchDesignTokens |
|-----|-------------------|
| 30px | `fontSize3Xl` |
| 24px | `fontSize2Xl` |
| 20px | `fontSizeXl` |
| 18px | `fontSizeLg` |
| 16px | `fontSizeBase` |
| 14px | `fontSizeSm` |
| 12px | `fontSizeXs` |

---

## 우선순위별 작업 계획

### 우선순위 1 (높음) - 시각적 일관성에 즉시 영향

1. **모든 AppBar → SketchAppBar** (8개 화면)
2. **모든 CircularProgressIndicator → SketchProgressBar** (6개 화면)
3. **모든 Container 배지 → SketchChip** (4개 화면)
4. **TextButton (둘러보기) → SketchButton** (LoginView)
5. **경고 배너 Container → SketchCard** (WodSelectView)

**예상 파일 수정:** 10개 파일, 약 30개 위젯 교체

### 우선순위 2 (중간) - 사용자 인터랙션 개선

1. **IconButton → SketchIconButton** (HomeView 날짜 화살표)
2. **Icon 색상 → SketchDesignTokens** (모든 화면)
3. **라디오 버튼 → SketchRadio** (WodSelectView)
4. **뱃지 Container → SketchIconButton.badgeCount** (SettingsView)

**예상 파일 수정:** 5개 파일, 약 15개 위젯 교체

### 우선순위 3 (낮음) - 세부 폴리싱

1. **Text 스타일 → SketchDesignTokens** (모든 화면)
2. **하드코딩된 spacing → SketchDesignTokens.spacing*** (필요 시)
3. **BorderRadius → SketchDesignTokens** (일부 Container)

**예상 파일 수정:** 10개 파일, 약 50개 스타일 속성 교체

---

## 디자인 토큰 참조

### 색상

```dart
// 기본 색상 (그레이스케일)
SketchDesignTokens.white           // #FFFFFF
SketchDesignTokens.base100         // #F7F7F7
SketchDesignTokens.base300         // #DCDCDC (밝은 회색)
SketchDesignTokens.base500         // #8E8E8E (중간 회색)
SketchDesignTokens.base700         // #5E5E5E (어두운 회색)
SketchDesignTokens.base900         // #343434 (거의 검은색)
SketchDesignTokens.black           // #000000

// 강조 색상 (코랄/오렌지)
SketchDesignTokens.accentPrimary   // #DF7D5F
SketchDesignTokens.accentLight     // #F19E7E
SketchDesignTokens.accentDark      // #C86947

// 의미론적 색상
SketchDesignTokens.success         // #4CAF50
SketchDesignTokens.warning         // #FFC107
SketchDesignTokens.error           // #F44336
SketchDesignTokens.info            // #2196F3
```

### 타이포그래피

```dart
SketchDesignTokens.fontSizeXs      // 12px
SketchDesignTokens.fontSizeSm      // 14px
SketchDesignTokens.fontSizeBase    // 16px
SketchDesignTokens.fontSizeLg      // 18px
SketchDesignTokens.fontSizeXl      // 20px
SketchDesignTokens.fontSize2Xl     // 24px
SketchDesignTokens.fontSize3Xl     // 30px
SketchDesignTokens.fontSize4Xl     // 36px
SketchDesignTokens.fontSize5Xl     // 48px
```

### 폰트 패밀리

```dart
SketchDesignTokens.fontFamilyHand  // 'Patrick Hand' - Sketch 테마 기본
SketchDesignTokens.fontFamilySans  // 'Roboto' - Solid 테마 기본
SketchDesignTokens.fontFamilyMono  // 'JetBrains Mono' - 코드, 숫자
SketchDesignTokens.fontFamilySerif // 'Georgia' - 본문, 장문
```

### 간격 (8px 그리드)

```dart
SketchDesignTokens.spacingXs       // 4px
SketchDesignTokens.spacingSm       // 8px
SketchDesignTokens.spacingMd       // 12px
SketchDesignTokens.spacingLg       // 16px
SketchDesignTokens.spacingXl       // 24px
SketchDesignTokens.spacing2Xl      // 32px
SketchDesignTokens.spacing3Xl      // 48px
```

### 선 두께

```dart
SketchDesignTokens.strokeThin      // 1.0px - 아이콘, smooth 프리셋
SketchDesignTokens.strokeStandard  // 2.0px - 대부분의 UI (기본값)
SketchDesignTokens.strokeBold      // 3.0px - 강조, 선택 상태
SketchDesignTokens.strokeThick     // 4.0px - 타이틀, 포커스
```

### 손그림 효과

```dart
SketchDesignTokens.roughness       // 0.8 - 기본 거칠기
SketchDesignTokens.bowing          // 0.5 - 휘어짐 정도
SketchDesignTokens.noiseIntensity  // 0.035 - 노이즈 강도
```

---

## 성능 고려사항

### 1. const 생성자 적극 활용

```dart
// 좋은 예: const로 불필요한 리빌드 방지
const SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)

// 나쁜 예: 매번 새로 생성
SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)
```

### 2. seed 고정으로 동일한 렌더링 보장

```dart
// SketchPainter는 seed를 고정하여 동일한 스케치 모양 유지
SketchContainer(
  seed: 42, // 고정된 seed
  child: Text('안정적'),
)
```

### 3. 불필요한 노이즈 비활성화

```dart
// 작은 위젯에서는 enableNoise: false로 성능 향상
SketchContainer(
  enableNoise: false,
  child: SmallWidget(),
)
```

---

## 접근성 고려사항

### 1. 색상 대비

- 다크 모드에서 충분한 대비 유지 (`SketchThemeExtension.dark()` 프리셋 사용)
- 에러 메시지는 색상뿐 아니라 텍스트로도 명확히 전달

### 2. 터치 영역

- 버튼의 최소 터치 영역 확보 (`SketchButton`의 size 속성 활용)
- 48x48dp 최소 권장

### 3. 스크린 리더 지원

- `SketchIconButton`의 `tooltip`을 항상 설정
- 의미 있는 위젯에 Semantics label 제공

---

## 마이그레이션 체크리스트

### Phase 1: 핵심 컴포넌트 교체 (1-2일)

- [ ] LoginView - TextButton → SketchButton
- [ ] 모든 화면 - AppBar → SketchAppBar (8개)
- [ ] 모든 화면 - CircularProgressIndicator → SketchProgressBar (6개)
- [ ] 모든 화면 - Container 배지 → SketchChip (4개)

### Phase 2: 인터랙션 개선 (1일)

- [ ] HomeView - IconButton → SketchIconButton
- [ ] WodSelectView - 경고 배너 → SketchCard
- [ ] WodSelectView - Icon 라디오 → SketchRadio
- [ ] SettingsView - 뱃지 Container → SketchIconButton.badgeCount

### Phase 3: 세부 폴리싱 (1-2일)

- [ ] 모든 화면 - Text 스타일 → SketchDesignTokens
- [ ] 모든 화면 - Icon 색상 → SketchDesignTokens
- [ ] 하드코딩된 spacing → SketchDesignTokens

### Phase 4: QA 및 검증 (1일)

- [ ] 모든 화면 시각적 일관성 확인
- [ ] 다크 모드 테스트
- [ ] 성능 테스트 (리빌드 최소화 확인)
- [ ] 접근성 테스트 (스크린 리더, 색상 대비)

---

## 참고 자료

- **디자인 시스템 가이드:** `.claude/guide/mobile/design_system.md`
- **디자인 토큰:** `.claude/guide/mobile/design-tokens.json`
- **공통 위젯:** `.claude/guide/mobile/common_widgets.md`
- **Frame0.app:** https://frame0.app
- **design_system 패키지:** `apps/mobile/packages/design_system/`

---

## 다음 단계

이 디자인 명세를 바탕으로 **tech-lead** 에이전트가 다음 작업을 진행합니다:

1. **기술 아키텍처 설계** - 패키지 간 의존성, import 구조, 코드 생성 전략
2. **구현 계획 수립** - Phase별 상세 구현 전략, PR 단위
3. **개발자 할당** - developer 에이전트에게 구체적인 작업 지시

이 문서는 **wowa 앱의 디자인 일관성을 확보하기 위한 완전한 로드맵**을 제공합니다.
