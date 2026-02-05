# UI/UX 디자인 명세: SDK 통합 (Notice 네비게이션)

## 개요

이 디자인 명세는 notice SDK의 화면(NoticeListView, NoticeDetailView)을 wowa 앱의 기존 UI에 통합하는 방법을 정의합니다. push, qna SDK는 이미 완전 통합되어 있으므로 이 문서는 **공지사항 접근 경로 추가**에 집중합니다.

**디자인 목표**:
- 사용자가 설정 화면에서 2탭 이내로 공지사항에 접근 가능
- 읽지 않은 공지사항 개수를 시각적으로 강조
- 기존 wowa 앱의 Sketch Design System 스타일 유지
- notice SDK가 제공하는 UI를 그대로 활용 (새 디자인 불필요)

## 화면 구조

### Screen 1: SettingsView (수정)

기존 설정 화면에 "공지사항" 메뉴 항목을 추가합니다.

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: BackButton
    └── Title: Text("설정")
└── Body: SafeArea → Obx
    └── SingleChildScrollView
        ├── Padding(16)
        │   ├── _buildCurrentBoxCard()  # 기존
        │   ├── SizedBox(height: 24)
        │   ├── _buildMenuSection()     # 수정: 공지사항 항목 추가
        │   │   ├── _buildMenuItem(icon: Icons.notifications, title: '공지사항', ...)  # 신규
        │   │   ├── SizedBox(height: 12)
        │   │   └── _buildMenuItem(icon: Icons.swap_horiz, title: '박스 변경', ...)  # 기존
        │   ├── SizedBox(height: 32)
        │   └── _buildLogoutButton()    # 기존
```

#### 위젯 상세

**_buildMenuItem (공지사항 항목) - 신규**
- icon: Icons.notifications_outlined (알림 벨 아이콘)
- title: "공지사항"
- subtitle: "앱 업데이트 및 중요 안내사항"
- onTap: → Get.toNamed(NoticeRoutes.list)
- 뱃지: UnreadNoticeBadge 위젯으로 아이콘을 감싸서 읽지 않은 개수 표시

**GestureDetector (공지사항 메뉴) 구조**:
```
GestureDetector(onTap: → Get.toNamed('/notice/list'))
└── SketchCard
    └── Row
        ├── UnreadNoticeBadge(unreadCount: controller.unreadCount.value)
        │   └── Icon(Icons.notifications_outlined, size: 24, color: base700)
        ├── SizedBox(width: 12)
        ├── Expanded
        │   └── Column(crossAxisAlignment: start)
        │       ├── Text("공지사항", fontWeight: w500)
        │       └── Text("앱 업데이트 및 중요 안내사항", color: base500, fontSize: 12)
        └── Icon(Icons.chevron_right)
```

**뱃지 위치**:
- 공지사항 메뉴 항목의 아이콘(Icon) 위에 UnreadNoticeBadge를 오버레이
- 읽지 않은 개수가 0이면 뱃지 자동 숨김
- 읽지 않은 개수가 1 이상이면 우상단에 빨간색 원형 뱃지 표시

### Screen 2: NoticeListView (SDK 제공)

**SDK에서 이미 완성된 화면**이므로 wowa 앱에서 디자인 변경 불필요.

#### 화면 구성 (참고)
- AppBar: "공지사항" 제목, 새로고침 버튼
- Body:
  - 고정 공지사항 (pinnedNotices) - 📌 아이콘과 함께 상단에 표시
  - 일반 공지사항 (notices) - 최신순 정렬
  - 무한 스크롤 지원
  - Pull to Refresh 지원
- 읽지 않은 공지: NoticeListCard에서 시각적으로 강조 (배경색 차이)

### Screen 3: NoticeDetailView (SDK 제공)

**SDK에서 이미 완성된 화면**이므로 wowa 앱에서 디자인 변경 불필요.

#### 화면 구성 (참고)
- AppBar: "공지사항" 제목, 뒤로 가기 버튼
- Body:
  - 제목 (headline)
  - 카테고리 칩 (선택사항)
  - 작성일 / 조회수
  - 본문 (Markdown 렌더링)
- 상세 조회 시 자동 읽음 처리 → 목록으로 돌아가면 읽음 상태 반영

## 네비게이션 플로우

```
SettingsView
  ↓ (사용자가 "공지사항" 메뉴 탭)
Get.toNamed('/notice/list')
  ↓
NoticeListView (SDK)
  ↓ (사용자가 특정 공지사항 탭)
Get.toNamed('/notice/detail', arguments: noticeId)
  ↓
NoticeDetailView (SDK)
  ↓ (자동 읽음 처리)
NoticeListController.markAsRead(noticeId)
  ↓ (뒤로 가기)
NoticeListView (읽음 상태 업데이트됨)
  ↓ (뒤로 가기)
SettingsView (뱃지 개수 자동 감소)
```

## 색상 팔레트 (Sketch Design System)

기존 wowa 앱의 Sketch Design System 색상을 그대로 사용합니다.

### Primary Colors
- **accentPrimary**: `Color(0xFFDF7D5F)` - 강조 색상 (코랄/오렌지)
- **accentLight**: `Color(0xFFF19E7E)` - 밝은 강조
- **accentDark**: `Color(0xFFC86947)` - 어두운 강조

### Grayscale
- **white**: `Color(0xFFFFFFFF)` - 배경
- **base100**: `Color(0xFFF7F7F7)` - 카드 배경
- **base300**: `Color(0xFFDCDCDC)` - 테두리
- **base500**: `Color(0xFF8E8E8E)` - 보조 텍스트
- **base700**: `Color(0xFF5E5E5E)` - 아이콘
- **base900**: `Color(0xFF343434)` - 본문 텍스트
- **black**: `Color(0xFF000000)` - 제목

### Semantic Colors
- **error**: `Color(0xFFF44336)` - 뱃지 배경색 (읽지 않은 개수 표시)
- **success**: `Color(0xFF4CAF50)` - 성공 상태
- **warning**: `Color(0xFFFFC107)` - 경고 상태
- **info**: `Color(0xFF2196F3)` - 정보 상태

## 타이포그래피 (Material Design 3 기반)

### 사용될 스타일

**설정 화면 (SettingsView)**
- **메뉴 제목**: fontSize: 16, fontWeight: 500 (medium) - "공지사항"
- **메뉴 설명**: fontSize: 12, fontWeight: 400, color: base500 - "앱 업데이트 및..."

**공지사항 목록 (NoticeListView - SDK 제공)**
- **AppBar 제목**: fontSize: 20, fontWeight: 500 - "공지사항"
- **섹션 헤더**: fontSize: 16, fontWeight: 600 - "📌 고정 공지", "최신 공지"
- **카드 제목**: fontSize: 14, fontWeight: 500 - 공지사항 제목
- **카드 날짜**: fontSize: 12, fontWeight: 400, color: base500

**공지사항 상세 (NoticeDetailView - SDK 제공)**
- **제목**: fontSize: 20, fontWeight: 700
- **본문**: fontSize: 16, fontWeight: 400, lineHeight: 1.5

## 스페이싱 시스템 (8dp 그리드)

### 설정 화면 스페이싱

**화면 레벨**:
- **화면 패딩**: 16dp (좌우상하)
- **카드 간 간격**: 12dp (메뉴 항목 사이)
- **섹션 간 간격**: 24dp (현재 박스 카드 ↔ 메뉴 섹션)
- **로그아웃 버튼 상단**: 32dp

**카드 내부**:
- **SketchCard 내부 패딩**: 16dp (기본값)
- **아이콘 ↔ 텍스트**: 12dp
- **제목 ↔ 설명**: 2dp

**뱃지**:
- **뱃지 padding**: horizontal: 6dp (1자리), 4dp (2자리+), vertical: 2dp
- **뱃지 minWidth**: 18dp
- **뱃지 minHeight**: 18dp
- **뱃지 border**: 2dp (흰색 테두리)

## 인터랙션 상태

### 메뉴 항목 터치 피드백

**GestureDetector (공지사항 메뉴)**:
- **Default**: SketchCard 기본 상태
- **Pressed**: InkWell 효과 없음 (SketchCard는 GestureDetector 사용)
- **시각적 피드백**: 카드 전체가 살짝 scale down (0.98) - 선택사항

### 뱃지 상태

- **읽지 않은 개수 0**: 뱃지 숨김 (if unreadCount > 0)
- **읽지 않은 개수 1-99**: 숫자 표시 (예: "5")
- **읽지 않은 개수 100+**: "99+" 표시

### 네비게이션 애니메이션

- **SettingsView → NoticeListView**: Material 슬라이드 전환 (우→좌)
- **NoticeListView → NoticeDetailView**: Material 슬라이드 전환 (우→좌)
- **Duration**: 300ms
- **Curve**: Curves.easeInOut

## 반응형 상태 관리 (GetX)

### SettingsController에 추가될 속성

```dart
// UnreadCountController를 별도 생성하거나, SettingsController에 통합
class SettingsController extends GetxController {
  // 기존 속성들...

  // 읽지 않은 공지사항 개수
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final noticeApiService = Get.find<NoticeApiService>();
      final response = await noticeApiService.getUnreadCount();
      unreadCount.value = response.unreadCount;
    } catch (e) {
      // 비치명적 오류 — 실패 시 0 유지
      logError('Failed to fetch unread notice count: $e');
    }
  }

  void goToNoticeList() {
    Get.toNamed('/notice/list');
  }
}
```

### Obx로 감싸야 할 위젯

**설정 화면 메뉴 항목**:
```dart
Obx(() => UnreadNoticeBadge(
  unreadCount: controller.unreadCount.value,
  child: Icon(Icons.notifications_outlined),
))
```

## 접근성 (Accessibility)

### 색상 대비

- **뱃지 배경(error red) vs 텍스트(white)**: 4.5:1 이상 (WCAG AA 준수)
- **메뉴 제목(base900) vs 배경(white)**: 10:1 이상 (WCAG AAA 준수)
- **메뉴 설명(base500) vs 배경(white)**: 4.5:1 이상

### 의미 전달

- **읽지 않은 공지**: 뱃지(빨간색 원) + 숫자 병행 표시
- **메뉴 아이콘**: 알림 벨 아이콘 + "공지사항" 텍스트 병행

### 스크린 리더 지원

- **공지사항 메뉴 항목**: Semantics(label: "공지사항, 읽지 않은 공지 3개")
- **뱃지**: Semantics(label: "읽지 않은 공지 3개")
- **아이콘 버튼**: Tooltip 제공 (IconButton의 tooltip 속성)

### 터치 영역

- **메뉴 항목 (SketchCard)**: 최소 48dp 높이 (SketchCard 기본값으로 충족)
- **뒤로 가기 버튼**: 48x48dp (AppBar 기본값)
- **새로고침 버튼 (NoticeListView)**: 48x48dp

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

**SettingsView에서 사용**:
- **SketchCard**: 메뉴 항목 카드 (공지사항, 박스 변경)
- **SketchButton**: 로그아웃 버튼 (기존)

**NoticeListView에서 사용 (SDK 내부)**:
- **SketchButton**: "다시 시도" 버튼 (에러 상태)
- **SketchDesignTokens**: 색상, 간격 상수

**UnreadNoticeBadge (packages/notice)**:
- notice SDK에서 제공하는 위젯
- wowa 앱의 SettingsView에서 import하여 사용
- Frame0 스타일은 아니지만, Material Design 기본 뱃지로 충분

### 새로운 컴포넌트 필요 여부

❌ 새로운 컴포넌트 불필요 — 모든 UI 요소가 기존 SDK/Design System에 존재

## 에러 처리

### 읽지 않은 개수 조회 실패

**UI 동작**:
- 뱃지를 숨기지 않고 `0`으로 표시
- 사용자는 공지사항 메뉴에 여전히 접근 가능
- 비치명적 오류로 처리 (앱 크래시 없음)

**로그**:
```dart
catch (e) {
  logError('Failed to fetch unread notice count: $e');
  unreadCount.value = 0; // 안전한 기본값
}
```

### 네비게이션 실패

**증상**: NoticeRoutes.list 라우트가 미등록
**에러 메시지**: GetX 기본 에러 메시지 ("Route not found")
**해결**: app_pages.dart에 NoticeRoutes 등록 필수 (mobile-work-plan.md에서 정의)

## 구현 우선순위

### Phase 1: 기본 네비게이션 (필수)
1. SettingsView에 "공지사항" 메뉴 항목 추가
2. Get.toNamed(NoticeRoutes.list) 연결
3. 기본 아이콘 (Icons.notifications_outlined) 표시

### Phase 2: 뱃지 통합 (선택)
1. SettingsController에 unreadCount 속성 추가
2. fetchUnreadCount() 메서드 구현
3. UnreadNoticeBadge 위젯으로 아이콘 감싸기
4. Obx로 반응형 업데이트

### Phase 3: 읽음 상태 동기화 (자동)
- notice SDK가 자동으로 처리 (NoticeDetailView 진입 시)
- wowa 앱에서 추가 구현 불필요

## 참고 자료

- **Notice SDK README**: `apps/mobile/packages/notice/README.md`
- **Design System Guide**: `.claude/guide/mobile/design_system.md`
- **Design Tokens**: `.claude/guide/mobile/design-tokens.json`
- **Material Design 3**: https://m3.material.io/
- **Flutter Widget Catalog**: https://docs.flutter.dev/ui/widgets
