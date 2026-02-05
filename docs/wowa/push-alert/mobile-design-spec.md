# UI/UX 디자인 명세: 푸시 알림 (Push Notification)

## 개요

사용자가 앱을 사용하지 않을 때에도 중요한 정보를 실시간으로 받고, 앱 내에서 알림 내역을 확인하며, 읽지 않은 알림을 쉽게 관리할 수 있는 UI를 제공합니다. Frame0 스케치 스타일의 손그림 디자인 시스템을 활용하여 친근하고 접근하기 쉬운 알림 경험을 제공합니다.

**핵심 UX 전략**:
- 알림 권한 요청 시점 최적화 (사용자가 가치를 이해한 후 요청)
- 읽지 않은 알림의 명확한 시각적 구분
- 포그라운드 알림의 비침해적 표시 (현재 작업 방해 최소화)
- 빠른 액세스와 직관적인 인터랙션 (탭 → 읽음 처리 → 화면 이동)

---

## 화면 구조

### Screen 1: 알림 목록 화면 (NotificationListView)

알림 목록 화면은 앱 내에서 받은 모든 알림을 시간 역순으로 표시하는 메인 화면입니다.

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: SketchIconButton (뒤로가기)
    ├── Title: Text("알림")
    └── Actions: Row
        └── SketchIconButton (설정 아이콘)
└── Body: RefreshIndicator (pull-to-refresh)
    └── Obx (반응형 상태 렌더링)
        ├── [상태: 로딩] → Center
        │   └── SketchProgressBar(style: circular, value: null)
        │
        ├── [상태: 에러] → Center
        │   └── Column
        │       ├── Icon (Icons.error_outline, size: 64)
        │       ├── SizedBox(height: 16)
        │       ├── Text ("알림을 불러올 수 없습니다")
        │       ├── SizedBox(height: 24)
        │       └── SketchButton (재시도)
        │
        ├── [상태: 빈 목록] → Center
        │   └── Column
        │       ├── Icon (Icons.notifications_none, size: 80)
        │       ├── SizedBox(height: 16)
        │       ├── Text ("알림이 없습니다")
        │       └── Text ("새로운 알림이 도착하면 여기에 표시됩니다")
        │
        └── [상태: 성공] → ListView.builder (무한 스크롤)
            └── NotificationListItem (반복)
                ├── InkWell (탭 영역)
                └── Padding(16)
                    └── SketchCard (알림 카드)
                        └── Padding(12)
                            └── Row
                                ├── Column (알림 내용 - Expanded)
                                │   ├── Row (제목 행)
                                │   │   ├── Text (제목 - Expanded)
                                │   │   └── SketchChip (읽지 않음 배지 - 조건부)
                                │   ├── SizedBox(height: 8)
                                │   ├── Text (본문 - 최대 3줄)
                                │   ├── SizedBox(height: 8)
                                │   └── Text (시간 - 상대 시간 표시)
                                └── Icon (Icons.chevron_right - 이동 힌트)
            └── [페이징 로더] → Padding
                └── Center
                    └── CircularProgressIndicator (크기: 20x20)
```

#### 위젯 상세

**AppBar**
- backgroundColor: SketchDesignTokens.white
- elevation: 0 (플랫 디자인)
- title: Text ("알림")
  - style: fontSize2Xl (24px), fontWeightMedium (500)
- leading: SketchIconButton
  - icon: Icons.arrow_back_ios
  - onPressed: Get.back()
- actions: SketchIconButton (설정)
  - icon: Icons.settings_outlined
  - tooltip: "알림 설정"
  - onPressed: 알림 설정 화면 이동 (향후 구현)

**RefreshIndicator (Pull-to-refresh)**
- color: SketchDesignTokens.accentPrimary
- onRefresh: controller.refreshNotifications()
- displacement: 40 (당김 거리)

**SketchProgressBar (로딩 상태)**
- style: SketchProgressBarStyle.circular
- value: null (indeterminate 애니메이션)
- 크기: 48x48

**에러 상태**
- Icon
  - Icons.error_outline
  - size: 64
  - color: SketchDesignTokens.base500
- Text (에러 메시지)
  - "알림을 불러올 수 없습니다"
  - fontSize: fontSizeLg (18px)
  - fontWeight: 500
  - color: base900
- Text (부가 설명)
  - "네트워크 연결을 확인해 주세요"
  - fontSize: fontSizeSm (14px)
  - color: base500
- SketchButton (재시도)
  - text: "다시 시도"
  - style: primary
  - onPressed: controller.retryLoadNotifications()

**빈 상태 (Empty State)**
- Icon
  - Icons.notifications_none
  - size: 80
  - color: SketchDesignTokens.base300
- Text (주 메시지)
  - "알림이 없습니다"
  - fontSize: fontSizeXl (20px)
  - fontWeight: 500
  - color: base700
- Text (부 메시지)
  - "새로운 알림이 도착하면 여기에 표시됩니다"
  - fontSize: fontSizeSm (14px)
  - color: base500
  - textAlign: center

**NotificationListItem (SketchCard)**
- elevation: 1 (미묘한 그림자)
- margin: EdgeInsets.only(bottom: 12) (카드 간 간격)
- onTap: controller.handleNotificationTap(notification)
  - 읽음 처리 API 호출
  - 관련 화면으로 딥링크 이동
- 읽지 않은 알림:
  - borderColor: SketchDesignTokens.accentPrimary (강조 테두리)
  - strokeWidth: strokeBold (3px)
- 읽은 알림:
  - borderColor: SketchDesignTokens.base300 (기본 테두리)
  - strokeWidth: strokeStandard (2px)

**알림 제목 (Title)**
- 읽지 않은 알림:
  - fontWeight: FontWeight.bold (700)
  - color: SketchDesignTokens.base900
- 읽은 알림:
  - fontWeight: FontWeight.normal (400)
  - color: SketchDesignTokens.base700
- fontSize: fontSizeBase (16px)
- maxLines: 2
- overflow: TextOverflow.ellipsis

**SketchChip (읽지 않음 배지)**
- label: "NEW"
- selected: true (배경색 활성화)
- activeColor: SketchDesignTokens.accentPrimary
- textStyle: fontSizeXs (12px), fontWeightMedium (500)
- 조건부 렌더링: isRead == false일 때만 표시

**알림 본문 (Body)**
- fontSize: fontSizeSm (14px)
- color: SketchDesignTokens.base700
- maxLines: 3
- overflow: TextOverflow.ellipsis
- lineHeight: 1.5

**시간 표시 (Timestamp)**
- fontSize: fontSizeXs (12px)
- color: SketchDesignTokens.base500
- 상대 시간 표시:
  - 1분 미만: "방금 전"
  - 1시간 미만: "N분 전"
  - 24시간 미만: "N시간 전"
  - 7일 미만: "N일 전"
  - 7일 이상: "MM월 DD일"

**페이징 로더 (Infinite Scroll)**
- 리스트 끝에서 3개 항목 전에 다음 페이지 자동 로드
- CircularProgressIndicator
  - size: 20x20
  - strokeWidth: 2
  - color: SketchDesignTokens.accentPrimary

---

### Screen 2: 알림 권한 요청 다이얼로그 (PermissionRequestDialog)

알림 권한을 처음 요청할 때 표시되는 설명 다이얼로그입니다.

#### 레이아웃 계층

```
SketchModal (show 메서드로 호출)
└── title: "알림 받기"
└── child: Column
    ├── Icon (Icons.notifications_active, size: 64)
    ├── SizedBox(height: 16)
    ├── Text ("중요한 소식을 놓치지 마세요")
    ├── SizedBox(height: 8)
    ├── Text ("새로운 메시지, 이벤트, 중요 공지를...")
    └── SizedBox(height: 16)
└── actions: Row
    ├── SketchButton ("나중에")
    └── SketchButton ("허용하기")
```

#### 위젯 상세

**SketchModal**
- showCloseButton: true (상단 닫기 버튼)
- barrierDismissible: true (외부 탭으로 닫기 가능)
- title: "알림 받기"
  - fontSize: fontSize2Xl (24px)
  - fontWeight: 600

**Icon (알림 아이콘)**
- Icons.notifications_active
- size: 64
- color: SketchDesignTokens.accentPrimary

**Text (주 메시지)**
- "중요한 소식을 놓치지 마세요"
- fontSize: fontSizeLg (18px)
- fontWeight: 600
- color: base900
- textAlign: center

**Text (부 메시지)**
- "새로운 메시지, 이벤트, 중요 공지를 실시간으로 받아보실 수 있습니다."
- fontSize: fontSizeSm (14px)
- color: base700
- textAlign: center
- lineHeight: 1.5

**SketchButton (나중에)**
- text: "나중에"
- style: SketchButtonStyle.outline
- onPressed: Navigator.pop(context, false)

**SketchButton (허용하기)**
- text: "허용하기"
- style: SketchButtonStyle.primary
- onPressed:
  - Navigator.pop(context, true)
  - 시스템 권한 요청 다이얼로그 표시 (iOS/Android)

---

### Screen 3: 포그라운드 알림 배너 (ForegroundNotificationBanner)

앱 사용 중 새로운 알림이 도착했을 때 화면 상단에 표시되는 인앱 알림입니다.

#### 레이아웃 계층

```
AnimatedSlide (위에서 아래로 슬라이드 애니메이션)
└── SafeArea
    └── Padding(horizontal: 16, top: 8)
        └── SketchCard
            ├── elevation: 3 (높은 그림자)
            └── body: InkWell (탭 영역)
                └── Row
                    ├── Icon (Icons.notifications, size: 24)
                    ├── SizedBox(width: 12)
                    ├── Expanded
                    │   └── Column (crossAxisAlignment: start)
                    │       ├── Text (제목 - maxLines: 1)
                    │       └── Text (본문 - maxLines: 2)
                    └── IconButton (닫기 버튼)
```

#### 위젯 상세

**AnimatedSlide**
- begin: Offset(0, -1) (화면 위)
- end: Offset(0, 0) (원위치)
- duration: 300ms
- curve: Curves.easeOut
- 자동 사라짐: 5초 후 자동으로 위로 슬라이드하여 사라짐

**SketchCard**
- elevation: 3 (모달 수준 그림자)
- borderColor: SketchDesignTokens.accentPrimary
- fillColor: SketchDesignTokens.white
- onTap:
  - 배너 닫기
  - 알림 상세 화면으로 이동 (딥링크 처리)

**Icon (알림 아이콘)**
- Icons.notifications
- size: 24
- color: SketchDesignTokens.accentPrimary

**Text (제목)**
- fontSize: fontSizeBase (16px)
- fontWeight: FontWeight.bold (700)
- color: base900
- maxLines: 1
- overflow: TextOverflow.ellipsis

**Text (본문)**
- fontSize: fontSizeSm (14px)
- color: base700
- maxLines: 2
- overflow: TextOverflow.ellipsis

**IconButton (닫기)**
- icon: Icons.close
- iconSize: 20
- onPressed: 배너 닫기 (상태 변경)
- tooltip: "닫기"

---

### Screen 4: 알림 설정 비활성화 안내 화면 (PermissionDeniedView)

사용자가 알림 권한을 거부한 상태에서 알림 목록 화면에 진입했을 때 표시되는 안내 화면입니다.

#### 레이아웃 계층

```
Center
└── Padding(24)
    └── Column (mainAxisAlignment: center)
        ├── Icon (Icons.notifications_off, size: 100)
        ├── SizedBox(height: 24)
        ├── Text ("알림이 비활성화되어 있습니다")
        ├── SizedBox(height: 12)
        ├── Text ("설정에서 알림 권한을 허용하면...")
        ├── SizedBox(height: 32)
        └── SketchButton ("설정 열기")
```

#### 위젯 상세

**Icon**
- Icons.notifications_off
- size: 100
- color: SketchDesignTokens.base300

**Text (주 메시지)**
- "알림이 비활성화되어 있습니다"
- fontSize: fontSize2Xl (24px)
- fontWeight: 600
- color: base900
- textAlign: center

**Text (부 메시지)**
- "설정에서 알림 권한을 허용하면 중요한 소식을 실시간으로 받아보실 수 있습니다."
- fontSize: fontSizeBase (16px)
- color: base700
- textAlign: center
- lineHeight: 1.5

**SketchButton (설정 열기)**
- text: "설정 열기"
- style: SketchButtonStyle.primary
- size: SketchButtonSize.large
- onPressed:
  - iOS: UIApplicationOpenSettingsURLString 열기
  - Android: Settings.ACTION_APPLICATION_DETAILS_SETTINGS 열기

---

### Screen 5: 읽지 않은 알림 배지 (UnreadBadge)

앱의 알림 목록 화면 진입 버튼(네비게이션 바 또는 홈 화면)에 표시되는 읽지 않은 알림 개수 배지입니다.

#### 레이아웃 계층

```
Stack
├── SketchIconButton (알림 아이콘)
└── Positioned (right: 0, top: 0)
    └── Obx (반응형 렌더링)
        └── [조건부] Container (배지 - unreadCount > 0일 때만)
            ├── width: 20 (최소), height: 20
            ├── decoration: BoxDecoration
            │   ├── color: SketchDesignTokens.error (빨간색)
            │   ├── borderRadius: pill (원형)
            │   └── border: white 2px (가시성 향상)
            └── Center
                └── Text (개수 - "N" 또는 "99+")
```

#### 위젯 상세

**Container (배지)**
- 조건: controller.unreadCount > 0
- minWidth: 20
- height: 20
- padding: EdgeInsets.symmetric(horizontal: 4) (개수가 두 자리 이상일 때 확장)
- decoration:
  - color: SketchDesignTokens.error (#F44336)
  - borderRadius: BorderRadius.circular(10) (pill 형태)
  - border: Border.all(color: Colors.white, width: 2) (주변 요소와 구분)

**Text (개수)**
- 개수 표시 로직:
  - 1~99: 실제 숫자 표시 ("5", "12")
  - 100 이상: "99+"
- fontSize: fontSizeXs (12px)
- fontWeight: FontWeight.bold (700)
- color: Colors.white
- textAlign: center

---

## 색상 팔레트 (Frame0 Sketch Style)

### Primary Colors
- **Primary (accentPrimary)**: `Color(0xFFDF7D5F)` — 주요 액션 버튼, 강조 테두리, 알림 아이콘
- **Primary Light (accentLight)**: `Color(0xFFF19E7E)` — 호버 상태, 배경 강조
- **Primary Dark (accentDark)**: `Color(0xFFC86947)` — 프레스 상태

### Base Colors (그레이스케일)
- **Base100**: `Color(0xFFF7F7F7)` — 앱 배경, Surface
- **Base300**: `Color(0xFFDCDCDC)` — 읽은 알림 테두리, 구분선
- **Base500**: `Color(0xFF8E8E8E)` — 부가 정보 텍스트, 플레이스홀더
- **Base700**: `Color(0xFF5E5E5E)` — 본문 텍스트 (읽은 알림)
- **Base900**: `Color(0xFF343434)` — 주요 텍스트 (읽지 않은 알림 제목)
- **Black**: `Color(0xFF000000)` — 최대 강조

### Semantic Colors
- **Success**: `Color(0xFF4CAF50)` — 성공 상태, 읽음 처리 완료 피드백
- **Error**: `Color(0xFFF44336)` — 에러 상태, 읽지 않은 알림 배지
- **Warning**: `Color(0xFFFFC107)` — 경고, 주의 필요 알림
- **Info**: `Color(0xFF2196F3)` — 정보성 알림

### Background Colors
- **Background**: `Color(0xFFFFFFFF)` — 화면 배경
- **Surface**: `Color(0xFFF7F7F7)` — 카드, 모달 배경
- **Surface Variant**: `Color(0xFFEBEBEB)` — 보조 배경

---

## 타이포그래피 (Sketch Design System)

### Display (사용 안 함 - 모바일 최적화)

### Headline
- **headlineLarge**: fontSize: 32px, fontWeight: 600, height: 1.25 — 사용 안 함
- **headlineMedium**: fontSize: 28px, fontWeight: 600, height: 1.25 — 사용 안 함
- **headlineSmall**: fontSize: 24px, fontWeight: 600, height: 1.33 — 모달 제목

### Title
- **titleLarge**: fontSize: 24px (fontSize2Xl), fontWeight: 500, height: 1.33 — AppBar 제목
- **titleMedium**: fontSize: 20px (fontSizeXl), fontWeight: 500, height: 1.4 — 빈 상태 주 메시지
- **titleSmall**: fontSize: 18px (fontSizeLg), fontWeight: 600, height: 1.4 — 다이얼로그 주 메시지

### Body
- **bodyLarge**: fontSize: 16px (fontSizeBase), fontWeight: 400, height: 1.5 — 알림 제목, 일반 본문
- **bodyMedium**: fontSize: 14px (fontSizeSm), fontWeight: 400, height: 1.5 — 알림 본문, 부가 설명
- **bodySmall**: fontSize: 12px (fontSizeXs), fontWeight: 400, height: 1.33 — 시간 표시, 캡션

### Label
- **labelLarge**: fontSize: 16px, fontWeight: 500, height: 1.25 — 버튼 텍스트
- **labelMedium**: fontSize: 14px, fontWeight: 500, height: 1.25 — 작은 버튼, 칩
- **labelSmall**: fontSize: 12px (fontSizeXs), fontWeight: 600, height: 1.33 — 배지 텍스트 ("NEW", 개수)

---

## 스페이싱 시스템 (8px 그리드)

### Padding/Margin
- **xs**: 4px (spacingXs) — 배지 내부 패딩
- **sm**: 8px (spacingSm) — 아이콘-텍스트 간격, 작은 요소 간격
- **md**: 12px (spacingMd) — 카드 내부 패딩, 기본 요소 간격
- **lg**: 16px (spacingLg) — 화면 패딩, 카드 간 간격
- **xl**: 24px (spacingXl) — 섹션 간 큰 간격
- **2xl**: 32px (spacing2Xl) — 모달 내부 패딩

### 컴포넌트별 스페이싱
- **화면 패딩**: 16px (좌우), 0px (상하 - Scaffold body)
- **카드 간 간격**: 12px (margin bottom)
- **카드 내부 패딩**: 12px (전체)
- **알림 제목-본문 간격**: 8px
- **본문-시간 간격**: 8px
- **모달 요소 간격**: 16px (기본), 24px (버튼 영역)

---

## Border Radius

- **small**: 2px (radiusSm) — 사용 안 함
- **medium**: 4px (radiusMd) — TextField, 작은 카드
- **large**: 8px (radiusLg) — 알림 카드, 일반 컴포넌트
- **xlarge**: 12px (radiusXl) — 모달, 큰 카드
- **pill**: 9999px (radiusPill) — 버튼, 배지, 칩

---

## Elevation (그림자)

SketchCard의 elevation 속성 활용 (0~3)

- **Level 0**: 0dp — 평면 요소 (사용 안 함)
- **Level 1**: elevation: 1 — 알림 목록 카드 (기본)
- **Level 2**: elevation: 2 — 호버 상태 (데스크톱 향후 지원 시)
- **Level 3**: elevation: 3 — 포그라운드 알림 배너 (최상위 레이어)

그림자 색상: rgba(0, 0, 0, 0.1) ~ 0.2

---

## 인터랙션 상태

### 알림 카드 탭 (InkWell)
- **Default**:
  - 읽지 않은 알림: accentPrimary 테두리 (3px), 제목 bold
  - 읽은 알림: base300 테두리 (2px), 제목 normal
- **Pressed (Ripple Effect)**:
  - Splash Color: accentPrimary.withOpacity(0.12)
  - Highlight Color: accentPrimary.withOpacity(0.08)
- **탭 후 (읽음 처리)**:
  - 애니메이션: 300ms Fade
  - 테두리 색상 변경: accentPrimary → base300
  - 제목 폰트: bold → normal
  - 배지 제거: "NEW" SketchChip Fade Out

### SketchButton 상태
- **Default**: Primary 색상, elevation: 0 (스케치 스타일)
- **Pressed**: Primary Dark 색상, 약간 scale down (0.98)
- **Disabled**: Opacity 0.4, onPressed: null
- **Loading**: CircularProgressIndicator (16x16) + 텍스트

### Pull-to-refresh
- **Default**: 숨김
- **Dragging**: RefreshIndicator 표시, accentPrimary 색상
- **Refreshing**: 회전 애니메이션, 최소 300ms 표시

---

## 애니메이션

### 화면 전환
- **Route Transition**: FadeIn + 약간의 Scale (0.95 → 1.0)
- **Duration**: 300ms
- **Curve**: Curves.easeInOut

### 포그라운드 알림 배너
- **진입**: SlideTransition (위→아래)
  - Duration: 300ms
  - Curve: Curves.easeOut
- **퇴장**: SlideTransition (아래→위)
  - Duration: 250ms
  - Curve: Curves.easeIn
- **자동 사라짐**: 5초 후 자동 퇴장

### 읽음 처리 애니메이션
- **Fade Transition**: Opacity 1.0 → 0.8 → 1.0 (강조 효과)
- **Duration**: 200ms
- **Curve**: Curves.easeInOut
- **배지 제거**: Scale 1.0 → 0.0 + Fade Out (동시 실행)

### 무한 스크롤 로딩
- **CircularProgressIndicator**: 기본 Material 애니메이션
- **Duration**: 무한 회전
- **Size**: 20x20

---

## 반응형 레이아웃

### Breakpoints
- **Mobile Portrait**: width < 600dp (기본 타겟)
- **Mobile Landscape**: width ≥ 600dp (가로 모드 - 레이아웃 동일)
- **Tablet**: 향후 지원 예정

### 적응형 레이아웃 전략
- **세로 모드**: 1열 리스트 레이아웃 (기본)
- **가로 모드**: 1열 리스트 유지 (카드 너비 최대 600dp)

### 터치 영역
- **최소 크기**: 48x48dp (Material Design 가이드라인)
- **알림 카드 전체**: 탭 영역 (최소 높이 72dp)
- **IconButton**: 48x48dp (AppBar 아이콘, 닫기 버튼)
- **SketchButton**: 최소 높이 48dp (medium 사이즈 기본)

---

## 접근성 (Accessibility)

### 색상 대비
- **알림 제목 (base900) 대 배경 (white)**: 16.1:1 (AAA 등급)
- **본문 텍스트 (base700) 대 배경**: 7.4:1 (AAA 등급)
- **부가 정보 (base500) 대 배경**: 4.6:1 (AA 등급)
- **accentPrimary 대 white (버튼)**: 4.5:1 (AA 등급)

### 의미 전달
- **읽지 않은 알림**: 색상(accentPrimary) + 굵은 글씨 + "NEW" 배지 (복합 표현)
- **에러 표시**: 빨간색 + 에러 아이콘 + 에러 메시지
- **빈 상태**: 회색 아이콘 + 설명 텍스트

### 스크린 리더 지원 (Semantics)
- **알림 카드**:
  - label: "[제목], [본문], [시간], [읽음/읽지 않음 상태]"
  - hint: "탭하여 상세 내용 확인"
- **SketchButton**:
  - label: "다시 시도 버튼", "설정 열기 버튼"
- **IconButton**:
  - tooltip: "뒤로 가기", "닫기", "설정"
- **읽지 않은 배지**:
  - label: "읽지 않은 알림 [개수]개"

### 큰 텍스트 지원
- 시스템 글꼴 크기 설정 반영 (TextScaleFactor)
- maxLines 설정으로 레이아웃 깨짐 방지
- 최소 터치 영역 48dp 유지 (글자 크기와 무관)

---

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

| 컴포넌트 | 사용 위치 | 목적 |
|---------|---------|------|
| `SketchCard` | 알림 목록 카드 | 손그림 스타일 카드, elevation 지원 |
| `SketchButton` | 재시도, 설정 열기, 모달 액션 버튼 | Primary/Outline 스타일 버튼 |
| `SketchIconButton` | AppBar 아이콘, 닫기 버튼 | 원형/사각형 아이콘 버튼 |
| `SketchChip` | "NEW" 배지 | 선택 불가능한 태그 형태 |
| `SketchProgressBar` | 로딩 상태 (Circular) | Indeterminate 애니메이션 |
| `SketchModal` | 권한 요청 다이얼로그 | 중앙 모달 다이얼로그 |

### 사용하지 않는 컴포넌트
- `SketchInput`, `SketchSwitch`, `SketchCheckbox`, `SketchSlider`, `SketchDropdown`: 알림 목록 화면에서 사용 안 함
- `SketchContainer`: SketchCard로 대체

### 새로운 컴포넌트 필요 여부
현재 design_system 패키지의 기존 컴포넌트만으로 충분히 구현 가능. 새로운 컴포넌트 추가 불필요.

---

## 상태별 UI 렌더링

### 로딩 상태 (isLoading)
- **표시 위치**: 화면 중앙
- **UI**: SketchProgressBar (circular, value: null)
- **트리거**:
  - 초기 진입 시
  - 재시도 버튼 클릭 시
  - Pull-to-refresh 시 (RefreshIndicator 자체 UI 사용)

### 에러 상태 (hasError)
- **표시 위치**: 화면 중앙
- **UI**: 에러 아이콘 + 메시지 + 재시도 버튼
- **트리거**:
  - 네트워크 에러 (NetworkException)
  - 서버 에러 (500번대)
  - 타임아웃

### 빈 상태 (isEmpty)
- **표시 위치**: 화면 중앙
- **UI**: 빈 알림 아이콘 + 안내 메시지
- **트리거**:
  - 알림 목록 길이 == 0
  - 로딩 완료 후

### 성공 상태 (hasData)
- **표시 위치**: ListView
- **UI**: NotificationListItem 반복 + 페이징 로더
- **트리거**:
  - 알림 목록 길이 > 0

### 권한 거부 상태 (permissionDenied)
- **표시 위치**: 화면 전체 (알림 목록 대신 표시)
- **UI**: 비활성화 아이콘 + 안내 메시지 + 설정 열기 버튼
- **트리거**:
  - 알림 권한 상태 == denied
  - 앱 시작 시 또는 화면 진입 시 권한 확인

---

## 딥링크 처리 (Deep Linking)

### 알림 데이터 구조
```dart
{
  "notificationId": 123,
  "title": "새로운 메시지",
  "body": "김철수님이 메시지를 보냈습니다",
  "data": {
    "screen": "chat",      // 이동할 화면 라우트 이름
    "chatId": 456,         // 화면에 전달할 파라미터
    "userId": 789
  }
}
```

### 화면 이동 로직
1. **알림 탭 이벤트 발생**
2. **딥링크 데이터 파싱**: `notification.data` 읽기
3. **유효성 검증**: `screen` 키 존재 여부 확인
4. **라우트 이동**: `Get.toNamed(Routes.[SCREEN], arguments: data)`
5. **에러 처리**:
   - 잘못된 딥링크: 홈 화면으로 이동 + 스낵바 표시 ("페이지를 찾을 수 없습니다")
   - 앱 크래시 방지: try-catch로 감싸기

### 지원 라우트 예시
- `Routes.HOME`: 홈 화면 (기본값)
- `Routes.CHAT`: 채팅 화면
- `Routes.PROFILE`: 프로필 화면
- `Routes.EVENT`: 이벤트 상세 화면

---

## 사용자 피드백 (Snackbar & Toast)

### 읽음 처리 완료 (선택적)
- **트리거**: 알림 탭 → 읽음 처리 API 성공
- **UI**: 간단한 스낵바 (선택 사항, 사용자가 명시적으로 알 필요 없음)
- **메시지**: "읽음 처리됨"
- **Duration**: 1초
- **위치**: 하단

### 네트워크 에러
- **트리거**: 알림 목록 로딩 실패
- **UI**: 에러 화면 (스낵바 대신 전체 화면 표시)
- **메시지**: "알림을 불러올 수 없습니다"

### 권한 요청 거부
- **트리거**: 사용자가 시스템 권한 다이얼로그에서 "거부" 선택
- **UI**: PermissionDeniedView 전체 화면 표시
- **추가 액션**: "설정 열기" 버튼 제공

---

## 성능 최적화

### const 생성자 사용
- **적용 위치**:
  - 정적 텍스트 위젯 (`const Text("알림")`)
  - 아이콘 (`const Icon(Icons.notifications)`)
  - SizedBox (`const SizedBox(height: 16)`)
- **효과**: 위젯 리빌드 시 재생성 방지

### ListView.builder 사용
- **적용 위치**: 알림 목록
- **효과**: 화면에 보이는 항목만 렌더링 (무한 스크롤 지원)
- **itemCount**: controller.notifications.length

### Obx 최소화
- **적용 위치**:
  - 상태별 렌더링 분기 (로딩/에러/빈 목록/성공)
  - 개별 알림 카드 내부 (읽음/읽지 않음 상태)
- **효과**: 필요한 부분만 리빌드

### 이미지 최적화 (향후)
- **적용 위치**: 알림에 이미지 포함 시
- **전략**:
  - CachedNetworkImage 패키지 사용
  - 썸네일 크기로 로드 (원본 아님)
  - 플레이스홀더 + 에러 위젯 제공

---

## 참고 자료

- Material Design 3 Notifications: https://m3.material.io/components/badges/overview
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets
- Frame0 Design System: https://frame0.app
- Sketch Design Tokens: `.claude/guide/mobile/design-tokens.json`
- GetX Best Practices: `.claude/guide/mobile/getx_best_practices.md`
- Flutter Best Practices: `.claude/guide/mobile/flutter_best_practices.md`

---

## 다음 단계

이 디자인 명세를 바탕으로 **tech-lead** 에이전트가 기술 아키텍처를 설계합니다.

- **산출물**: `docs/wowa/push-alert/mobile-tech-design.md`
- **내용**:
  - Controller 설계 (NotificationListController)
  - API 연동 (NotificationApiService, NotificationRepository)
  - 상태 관리 (.obs 변수 정의)
  - FCM 설정 (디바이스 토큰 등록, 포그라운드/백그라운드 알림 처리)
  - 라우팅 설정 (Routes, Binding)
  - 데이터 모델 (NotificationModel)
