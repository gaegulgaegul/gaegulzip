# 기술 아키텍처 설계: wowa 앱 디자인 시스템 적용

## 개요

wowa 앱의 모든 화면에서 Flutter 기본 위젯을 design_system 패키지의 Frame0 스케치 스타일 컴포넌트로 교체하여 일관된 디자인 경험을 제공합니다. 이 작업은 **기존 기능 변경 없이 UI 레이어만 교체**하는 작업으로, GetX Controller 로직은 변경하지 않습니다.

## 아키텍처 영향 분석

### 패키지 의존성

```
core (foundation)
  ↑
  ├── design_system (Frame0 스케치 컴포넌트)
  │   ├── SketchButton, SketchCard, SketchInput 등
  │   ├── SketchDesignTokens (색상, 간격, 폰트 상수)
  │   └── SketchAppBar, SketchProgressBar 등
  └── wowa (메인 앱)
      ├── View 파일들 (UI 레이어)
      ├── Controller 파일들 (비즈니스 로직)
      └── Binding 파일들 (DI)
```

**의존성 확인:**
- wowa 앱의 `pubspec.yaml`에 이미 `design_system: path: ../../packages/design_system` 포함됨
- design_system의 `pubspec.yaml`에 `core: path: ../core` 포함됨
- **추가 의존성 불필요** — 이미 모든 패키지 연결 완료

### GetX 아키텍처 영향

| 레이어 | 변경 여부 | 변경 내용 |
|--------|----------|---------|
| **Controller** | ✅ **변경 없음** | 비즈니스 로직, .obs 변수, 메서드 모두 유지 |
| **View** | ⚠️ **변경** | Flutter 기본 위젯 → Sketch 컴포넌트 교체 |
| **Binding** | ✅ **변경 없음** | DI 로직 유지 |
| **Model** | ✅ **변경 없음** | 데이터 모델 유지 |
| **Routing** | ✅ **변경 없음** | app_routes.dart, app_pages.dart 유지 |

**핵심 원칙:**
- Controller의 `.obs` 변수명, 메서드명 변경 금지
- View에서 `controller.변수명`으로 접근하는 모든 코드는 그대로 유지
- Obx 반응형 패턴 유지

---

## 모듈별 작업 분류

### Phase 1: 공통 패턴 교체 (최우선)

모든 화면에 공통적으로 적용되는 위젯을 먼저 교체합니다.

#### 1.1 AppBar → SketchAppBar (8개 화면)

**변경 대상 파일:**
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_register_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/box/views/box_search_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/box/views/box_create_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/notification/views/notification_view.dart`

**교체 패턴:**
```dart
// Before
AppBar(title: const Text('WOD 등록'))

// After
SketchAppBar(title: 'WOD 등록')
```

**주요 변경사항:**
- `AppBar` → `SketchAppBar`
- `title` 파라미터는 String 직접 전달 (Text 위젯 불필요)
- `centerTitle`, `actions`, `leading` 속성은 동일하게 사용 가능
- SketchAppBar는 자동으로 뒤로가기 버튼 표시

**검증 기준:**
- [ ] 모든 화면에서 AppBar가 일관된 스케치 스타일로 표시됨
- [ ] 뒤로가기 버튼이 정상 작동
- [ ] actions 버튼들이 정상 작동

#### 1.2 CircularProgressIndicator → SketchProgressBar (6개 화면)

**변경 대상 파일:**
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/home_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/box/views/box_search_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`

**교체 패턴:**
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

**주요 변경사항:**
- `CircularProgressIndicator` → `SketchProgressBar`
- `style: SketchProgressBarStyle.circular` 추가
- `value: null`로 indeterminate 애니메이션 유지
- `size: 48` (기본 크기)

**검증 기준:**
- [ ] 로딩 상태에서 스케치 스타일 프로그레스 바가 표시됨
- [ ] 회전 애니메이션 정상 작동

#### 1.3 Container (배지) → SketchChip (4개 화면)

**변경 대상 파일:**
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/home_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`
- `apps/mobile/apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`

**교체 패턴:**
```dart
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

// After - BASE 배지
const SketchChip(
  label: 'BASE',
  selected: true,
  fillColor: SketchDesignTokens.info,
)

// Before - PERSONAL 배지
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: Colors.orange[100],
    borderRadius: BorderRadius.circular(4),
  ),
  child: const Text('PERSONAL',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
)

// After - PERSONAL 배지
const SketchChip(
  label: 'PERSONAL',
  selected: true,
  fillColor: SketchDesignTokens.warning,
)
```

**색상 매핑:**
| 기존 색상 | SketchDesignTokens |
|----------|-------------------|
| `Colors.blue[100]` (BASE) | `SketchDesignTokens.info` |
| `Colors.orange[100]` (PERSONAL) | `SketchDesignTokens.warning` |

**검증 기준:**
- [ ] BASE 배지가 파란색 스케치 칩으로 표시됨
- [ ] PERSONAL 배지가 오렌지색 스케치 칩으로 표시됨
- [ ] 배지 크기와 위치가 적절함

---

### Phase 2: 화면별 세부 교체

#### 2.1 LoginView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `TextButton` (둘러보기) | `SketchButton` | style: outline, size: medium | 높음 |
| `Text` (타이틀) | `Text` + SketchDesignTokens | fontSize: fontSize3Xl, fontFamily: fontFamilyHand | 중간 |
| `Text` (부제목) | `Text` + SketchDesignTokens | fontSize: fontSizeSm, color: base700 | 중간 |

**교체 예시:**
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

// Before - 타이틀
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

**Controller 변경:** 없음

**검증 기준:**
- [ ] "둘러보기" 버튼이 아웃라인 스타일로 표시됨
- [ ] 타이틀이 Hand 폰트로 표시됨
- [ ] 버튼 클릭 시 정상 라우팅

#### 2.2 HomeView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/home_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `IconButton` | `SketchIconButton` | icon: chevron_left/chevron_right | 중간 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (BASE 배지) | `SketchChip` | label: 'BASE', selected: true, fillColor: info | 높음 |
| `Container` (PERSONAL 배지) | `SketchChip` | label: 'PERSONAL', selected: true, fillColor: warning | 높음 |
| `Icon` (빈 상태) | `Icon` + SketchDesignTokens | color: base300, size: 48 | 중간 |
| `Text` (박스명/날짜/지역) | `Text` + SketchDesignTokens | fontSize, color, fontFamily | 낮음 |

**교체 예시:**
```dart
// Before - 날짜 화살표
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

// Before - 빈 상태 아이콘
const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey)

// After
const Icon(
  Icons.inbox_outlined,
  size: 48,
  color: SketchDesignTokens.base300,
)
```

**Controller 변경:** 없음

**검증 기준:**
- [ ] 날짜 화살표가 스케치 아이콘 버튼으로 표시됨
- [ ] BASE/PERSONAL 배지가 스케치 칩으로 표시됨
- [ ] 빈 상태가 일관된 색상으로 표시됨

#### 2.3 WodRegisterView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_register_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: 'WOD 등록' | 높음 |
| `Icon` (닫기) | `Icon` + SketchDesignTokens | color: error, size: 18 | 중간 |
| `Text` (섹션 제목) | `Text` + SketchDesignTokens | fontSize: fontSizeBase | 낮음 |

**교체 예시:**
```dart
// Before
AppBar(title: const Text('WOD 등록'))

// After
SketchAppBar(title: 'WOD 등록')

// Before - 닫기 아이콘
const Icon(Icons.close, size: 18, color: Colors.red)

// After
const Icon(Icons.close, size: 18, color: SketchDesignTokens.error)
```

**Controller 변경:** 없음

**검증 기준:**
- [ ] AppBar가 스케치 스타일로 표시됨
- [ ] 닫기 아이콘 색상이 일관됨

#### 2.4 WodDetailView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_detail_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: 'WOD 상세' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (BASE 배지) | `SketchChip` | label: 'BASE WOD', selected: true, fillColor: info | 높음 |
| `Container` (PERSONAL 배지) | `SketchChip` | label: 'PERSONAL', selected: true, fillColor: warning | 높음 |
| `Icon` (알림) | `Icon` + SketchDesignTokens | color: warning | 중간 |

**Controller 변경:** 없음

**검증 기준:**
- [ ] AppBar가 스케치 스타일로 표시됨
- [ ] 로딩 상태가 스케치 프로그레스로 표시됨
- [ ] 배지가 스케치 칩으로 표시됨

#### 2.5 WodSelectView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/wod_select_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: 'WOD 선택' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (경고 배너) | `SketchCard` | elevation: 1, borderColor: warning, strokeWidth: bold | 높음 |
| `Icon` (라디오) | `SketchRadio` | value: wod.id, groupValue: selectedWodId | 중간 |
| `Container` (배지) | `SketchChip` | label, selected: true, fillColor | 높음 |

**교체 예시:**
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

**Controller 변경:** 없음 (단, `selectedWodId`가 이미 `.obs`로 정의되어 있어야 함)

**검증 기준:**
- [ ] 경고 배너가 스케치 카드로 표시됨
- [ ] 라디오 버튼이 스케치 라디오로 표시됨
- [ ] 선택 상태가 정상 반응

#### 2.6 ProposalReviewView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/wod/views/proposal_review_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '제안 검토' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (배경 강조) | 제거 후 SketchCard의 fillColor 활용 | fillColor 직접 설정 | 중간 |
| `Container` (라벨 배지) | `SketchChip` | label: title, selected: true, fillColor | 높음 |

**Controller 변경:** 없음

**검증 기준:**
- [ ] AppBar가 스케치 스타일로 표시됨
- [ ] Before/After 라벨이 스케치 칩으로 표시됨

#### 2.7 BoxSearchView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/box/views/box_search_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '박스 찾기', centerTitle: true | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |

**비고:** 이 화면은 이미 SketchDesignTokens를 매우 잘 활용하고 있어 추가 교체가 거의 불필요합니다.

**Controller 변경:** 없음

**검증 기준:**
- [ ] AppBar가 스케치 스타일로 표시됨

#### 2.8 BoxCreateView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/box/views/box_create_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '새 박스 만들기', centerTitle: true | 높음 |

**비고:** 이 화면은 거의 완벽하게 디자인 시스템을 사용 중입니다.

**Controller 변경:** 없음

**검증 기준:**
- [ ] AppBar가 스케치 스타일로 표시됨

#### 2.9 SettingsView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/settings/views/settings_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '설정' | 높음 |
| `CircularProgressIndicator` | `SketchProgressBar` | style: circular, value: null | 높음 |
| `Container` (뱃지) | `SketchIconButton` + badgeCount | badgeCount: unreadCount | 높음 |
| `Icon` | `Icon` + SketchDesignTokens | color: base700 등 | 중간 |

**교체 예시:**
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

**Controller 변경:** 없음 (단, `unreadCount`가 이미 `.obs`로 정의되어 있어야 함)

**검증 기준:**
- [ ] AppBar가 스케치 스타일로 표시됨
- [ ] 미읽음 뱃지가 SketchIconButton으로 표시됨

#### 2.10 NotificationView

**파일:** `apps/mobile/apps/wowa/lib/app/modules/notification/views/notification_view.dart`

**변경 사항:**

| 현재 위젯 | 교체 위젯 | 변경 내용 | 우선순위 |
|----------|----------|---------|---------|
| `AppBar` | `SketchAppBar` | title: '알림', leading: back 버튼 | 중간 |

**비고:** 이 화면은 **가장 잘 구현된 예시**로, SketchDesignTokens를 완벽하게 활용하고 있습니다. AppBar만 SketchAppBar로 교체하면 됩니다.

**Controller 변경:** 없음

**검증 기준:**
- [ ] AppBar가 스케치 스타일로 표시됨

---

## 공통 색상/크기 매핑 가이드

### 색상 매핑

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

### 크기 매핑

| 기존 크기 | SketchDesignTokens |
|---------|-------------------|
| 30px | `SketchDesignTokens.fontSize3Xl` |
| 24px | `SketchDesignTokens.fontSize2Xl` |
| 20px | `SketchDesignTokens.fontSizeXl` |
| 18px | `SketchDesignTokens.fontSizeLg` |
| 16px | `SketchDesignTokens.fontSizeBase` |
| 14px | `SketchDesignTokens.fontSizeSm` |
| 12px | `SketchDesignTokens.fontSizeXs` |

### 간격 매핑

| 기존 간격 | SketchDesignTokens |
|---------|-------------------|
| 4px | `SketchDesignTokens.spacingXs` |
| 8px | `SketchDesignTokens.spacingSm` |
| 12px | `SketchDesignTokens.spacingMd` |
| 16px | `SketchDesignTokens.spacingLg` |
| 24px | `SketchDesignTokens.spacingXl` |
| 32px | `SketchDesignTokens.spacing2Xl` |

---

## 성능 최적화 전략

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

### 2. Obx 범위 최소화

```dart
// 좋은 예: 반응형 필요한 부분만 Obx
Column(
  children: [
    const Text('고정 텍스트'),
    Obx(() => Text('${controller.count.value}')),
  ],
)

// 나쁜 예: 전체를 Obx로 감싸기
Obx(() => Column(
  children: [
    const Text('고정 텍스트'),
    Text('${controller.count.value}'),
  ],
))
```

### 3. SketchPainter의 seed 고정

```dart
// 좋은 예: seed 고정으로 동일한 렌더링 보장
SketchContainer(
  seed: 42,
  child: Text('안정적'),
)

// 나쁜 예: 매번 다른 모양이 렌더링됨
SketchContainer(
  seed: DateTime.now().millisecondsSinceEpoch,
  child: Text('불안정'),
)
```

### 4. 불필요한 노이즈 비활성화

```dart
// 작은 위젯에서는 enableNoise: false로 성능 향상
SketchContainer(
  enableNoise: false,
  child: SmallWidget(),
)
```

---

## 리스크 및 주의사항

### 1. 기존 기능 깨짐 방지

**리스크:**
- Controller의 `.obs` 변수명 변경 시 Obx가 더 이상 반응하지 않음
- onPressed 콜백 제거 시 버튼 클릭 불가

**대응책:**
- Controller 파일 절대 수정 금지
- View의 `controller.변수명`, `controller.메서드명` 그대로 유지
- Obx 내부의 `.value` 접근 패턴 유지

### 2. 반응형 상태 유지

**리스크:**
- Obx를 제거하면 UI가 더 이상 업데이트되지 않음

**대응책:**
- 기존 Obx 패턴 그대로 유지
- SketchButton의 `isLoading`을 `controller.isLoading.value`와 연결

### 3. 색상 대비 확인

**리스크:**
- SketchDesignTokens의 색상이 기존 색상과 대비가 달라 가독성 저하

**대응책:**
- 다크 모드에서 충분한 대비 유지
- 에러 메시지는 색상 + 텍스트로 명확히 전달

### 4. 폰트 로딩

**리스크:**
- PatrickHand 폰트가 로딩되지 않으면 기본 폰트로 fallback

**대응책:**
- design_system 패키지의 `pubspec.yaml`에 폰트 정의 확인
- 앱 시작 시 폰트 로딩 확인

---

## 검증 계획

### 1. 정적 분석

```bash
cd apps/mobile
melos analyze
```

**검증 기준:**
- [ ] 모든 파일에서 린트 에러 없음
- [ ] import 에러 없음

### 2. 화면별 시각적 검증

각 화면을 실행하여 다음을 확인:

- [ ] LoginView: 둘러보기 버튼, 타이틀 폰트
- [ ] HomeView: AppBar, 프로그레스바, 배지, 아이콘 버튼
- [ ] WodRegisterView: AppBar, 아이콘 색상
- [ ] WodDetailView: AppBar, 프로그레스바, 배지
- [ ] WodSelectView: AppBar, 경고 배너, 라디오 버튼, 배지
- [ ] ProposalReviewView: AppBar, 프로그레스바, 배지
- [ ] BoxSearchView: AppBar, 프로그레스바
- [ ] BoxCreateView: AppBar
- [ ] SettingsView: AppBar, 프로그레스바, 뱃지
- [ ] NotificationView: AppBar

### 3. 기능 테스트

각 화면의 주요 기능이 정상 작동하는지 확인:

- [ ] 버튼 클릭 시 정상 액션 실행
- [ ] 라우팅 정상 작동
- [ ] 입력 필드 정상 입력
- [ ] 로딩 상태 정상 표시
- [ ] 에러 상태 정상 표시

### 4. 성능 테스트

- [ ] 화면 전환 시 렌더링 지연 없음
- [ ] 스크롤 성능 저하 없음
- [ ] 리빌드 최소화 확인 (Flutter DevTools)

### 5. 다크 모드 테스트

- [ ] 다크 모드에서 색상 대비 충분
- [ ] SketchThemeExtension.dark() 적용 확인

---

## 작업 분배 계획

### Junior Developer 작업 (Phase 1 + Phase 2)

**Phase 1: 공통 패턴 교체 (2일)**

1. **Day 1: AppBar + ProgressBar 교체 (8개 화면)**
   - WodRegisterView, WodDetailView, WodSelectView, ProposalReviewView
   - BoxSearchView, BoxCreateView, SettingsView, NotificationView
   - 각 파일에서 AppBar → SketchAppBar
   - 각 파일에서 CircularProgressIndicator → SketchProgressBar
   - 커밋 메시지: "refactor: Replace AppBar and CircularProgressIndicator with Sketch components"

2. **Day 2: 배지 교체 (4개 화면)**
   - HomeView, WodDetailView, WodSelectView, ProposalReviewView
   - Container 배지 → SketchChip
   - 커밋 메시지: "refactor: Replace badge Containers with SketchChip"

**Phase 2: 화면별 세부 교체 (2일)**

3. **Day 3: LoginView + HomeView + WodSelectView**
   - LoginView: TextButton → SketchButton, Text 스타일 교체
   - HomeView: IconButton → SketchIconButton, Icon 색상 교체
   - WodSelectView: 경고 배너 → SketchCard, 라디오 → SketchRadio
   - 커밋 메시지: "refactor: Apply Sketch design system to LoginView, HomeView, WodSelectView"

4. **Day 4: SettingsView + 나머지 화면 + 최종 검증**
   - SettingsView: 뱃지 → SketchIconButton.badgeCount
   - WodRegisterView, WodDetailView, ProposalReviewView: Icon 색상 교체
   - 모든 화면 시각적 검증
   - 커밋 메시지: "refactor: Finalize Sketch design system migration"

### 작업 의존성

- Phase 1과 Phase 2는 순차 진행 (Phase 1 완료 후 Phase 2 시작)
- 각 Phase 내에서는 병렬 작업 가능 (파일별로 독립적)
- Controller 수정 불필요 (View만 수정)

---

## 우선순위별 작업 요약

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

## 참고 자료

- **디자인 시스템 가이드:** `.claude/guide/mobile/design_system.md`
- **디자인 토큰:** `.claude/guide/mobile/design-tokens.json`
- **공통 패턴:** `.claude/guide/mobile/common_patterns.md`
- **성능 가이드:** `.claude/guide/mobile/performance.md`
- **GetX 가이드:** `.claude/guide/mobile/getx_best_practices.md`
- **Frame0.app:** https://frame0.app
- **design_system 패키지:** `apps/mobile/packages/design_system/`

---

## 다음 단계

1. **사용자 승인** - 이 설계를 검토하고 승인
2. **CTO 검증** - 아키텍처 검증 및 작업 분배
3. **Junior Developer 작업 시작** - Phase 1부터 순차 진행
4. **PR 리뷰** - 각 Phase 완료 후 PR 생성 및 리뷰
5. **QA** - 모든 화면 시각적 검증 및 기능 테스트

---

**이 문서는 wowa 앱의 디자인 일관성을 확보하기 위한 완전한 기술 아키텍처 설계입니다.**
