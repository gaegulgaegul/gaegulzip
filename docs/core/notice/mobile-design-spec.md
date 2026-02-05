# UI/UX 디자인 명세: 공지사항 (Notice)

## 개요

공지사항 SDK 패키지의 모바일 UI/UX 디자인입니다. 사용자 조회 기능만 포함하며, 관리자 UI는 제공하지 않습니다. Frame0 스케치 스타일을 활용하여 손그림 느낌의 친근한 인터페이스를 제공합니다.

**핵심 UX 전략**:
- 안 읽은 공지는 시각적으로 명확하게 구분 (굵은 글씨, 점 표시)
- 고정 공지는 상단에 핀 아이콘으로 강조
- 무한 스크롤 페이지네이션으로 부드러운 탐색 경험
- 마크다운 렌더링으로 풍부한 콘텐츠 표현
- 빈 상태, 로딩, 에러 상태를 친절하게 안내

---

## 화면 구조

### 네비게이션 흐름

```
앱 메인 화면
├── UnreadNoticeBadge (뱃지 위젯 - 읽지 않은 개수 표시)
│
└── 공지사항 버튼 탭
    │
    ├─→ Screen 1: NoticeListView (목록)
    │   ├── 고정 공지 섹션 (상단)
    │   ├── 일반 공지 목록 (최신순)
    │   └── 무한 스크롤 페이지네이션
    │
    └─→ Screen 2: NoticeDetailView (상세)
        ├── 제목, 카테고리, 날짜, 조회수
        ├── 마크다운 본문
        └── 뒤로가기 버튼
```

---

## Screen 1: NoticeListView (공지사항 목록)

### 레이아웃 계층

```
Scaffold
├── AppBar
│   ├── title: Text("공지사항")
│   └── actions: [
│       IconButton (새로고침)
│     ]
│
└── body: RefreshIndicator
    └── CustomScrollView
        ├── SliverToBoxAdapter (패딩 상단)
        │
        ├── SliverList (고정 공지 섹션 - 조건부 렌더링)
        │   └── _buildPinnedNoticesSection()
        │       ├── Padding (좌우 16)
        │       │   └── Text("📌 고정 공지", style: titleMedium, semibold)
        │       │
        │       ├── SizedBox(height: 12)
        │       │
        │       └── ListView.separated (고정 공지 목록)
        │           ├── itemCount: pinnedNotices.length
        │           ├── separatorBuilder: SizedBox(height: 8)
        │           └── itemBuilder: NoticeListCard (isPinned: true)
        │
        ├── SliverToBoxAdapter (구분선)
        │   └── Padding(16)
        │       └── Divider(thickness: 1, color: base300)
        │
        ├── SliverToBoxAdapter (일반 공지 헤더)
        │   └── Padding(좌우 16)
        │       └── Text("최신 공지", style: titleMedium, semibold)
        │
        ├── SliverList (일반 공지 목록)
        │   ├── itemCount: notices.length + 1 (로딩 인디케이터용)
        │   └── itemBuilder:
        │       ├── if (index < notices.length): NoticeListCard
        │       └── if (index == notices.length && hasMore):
        │           Padding(16)
        │             └── Center(CircularProgressIndicator)
        │
        └── SliverToBoxAdapter (패딩 하단)
```

### 위젯 상세

#### AppBar (상단 바)

- **backgroundColor**: Surface (white)
- **elevation**: 0 (그림자 없음)
- **title**:
  - Text: "공지사항"
  - style: titleLarge (22sp, fontWeight: 500)
  - color: textPrimary (black)
- **actions**:
  - IconButton:
    - icon: Icons.refresh
    - iconSize: 24
    - color: base700
    - onPressed: `controller.refreshNotices()`
    - tooltip: "새로고침"

#### RefreshIndicator (당겨서 새로고침)

- **onRefresh**: `controller.refreshNotices()`
- **color**: accentPrimary (#DF7D5F)
- **strokeWidth**: 2.0

#### NoticeListCard (목록 카드 - 재사용 위젯)

```dart
// 구조
InkWell (탭 영역)
└── SketchCard (Frame0 스타일 카드)
    └── Padding (horizontal: 12, vertical: 10)
        └── Row (crossAxisAlignment: start)
            ├── Column (읽음 표시 점)
            │   ├── if (!isRead):
            │   │   Container (8x8, borderRadius: 4, color: accentPrimary)
            │   ├── if (isRead):
            │       SizedBox(width: 8) // 빈 공간 유지
            │   └── SizedBox(height: 24) // 제목 줄과 높이 맞춤
            │
            ├── SizedBox(width: 8)
            │
            ├── Expanded (콘텐츠 영역)
            │   └── Column (crossAxisAlignment: start)
            │       ├── Row (제목 + 고정 아이콘)
            │       │   ├── if (isPinned):
            │       │   │   Icon(Icons.push_pin, size: 16, color: accentDark)
            │       │   ├── if (isPinned):
            │       │   │   SizedBox(width: 4)
            │       │   └── Expanded:
            │       │       Text(
            │       │         title,
            │       │         style: titleMedium (16sp, fontWeight: !isRead ? 600 : 500),
            │       │         maxLines: 2,
            │       │         overflow: ellipsis,
            │       │       )
            │       │
            │       ├── SizedBox(height: 4)
            │       │
            │       ├── if (category != null):
            │       │   Row:
            │       │     └── SketchChip (작고 귀여운 태그)
            │       │         ├── label: category
            │       │         ├── backgroundColor: base100
            │       │         ├── textStyle: labelSmall (11sp)
            │       │         └── padding: (horizontal: 8, vertical: 2)
            │       │
            │       ├── if (category != null):
            │       │   SizedBox(height: 6)
            │       │
            │       └── Row (메타 정보)
            │           ├── Icon(Icons.visibility, size: 14, color: base500)
            │           ├── SizedBox(width: 4)
            │           ├── Text("${viewCount}회", style: bodySmall, color: textTertiary)
            │           ├── SizedBox(width: 12)
            │           ├── Icon(Icons.calendar_today, size: 14, color: base500)
            │           ├── SizedBox(width: 4)
            │           └── Text(formatDate(createdAt), style: bodySmall, color: textTertiary)
            │
            └── Icon (화살표)
                ├── Icons.chevron_right
                ├── size: 20
                └── color: base500
```

**스타일 속성**:

- **SketchCard**:
  - elevation: 1 (기본), 2 (안 읽은 공지)
  - borderColor: !isRead ? accentPrimary : base300
  - fillColor: !isRead ? Color(0xFFFFF9F7) (아주 연한 오렌지) : white
  - roughness: 0.8 (기본 스케치 효과)
- **읽지 않은 공지 점**:
  - Container (8x8)
  - decoration: BoxDecoration(
      color: accentPrimary,
      borderRadius: BorderRadius.circular(4),
    )
- **제목**:
  - !isRead ? fontWeight: 600 (semibold) : 500 (medium)
  - color: textPrimary (black)
- **카테고리 태그**:
  - SketchChip (작은 크기)
  - backgroundColor: base100
  - textColor: base700
  - fontSize: 11sp
- **메타 정보**:
  - fontSize: 12sp (bodySmall)
  - color: textTertiary (base700)

**인터랙션**:

- **onTap**: `Get.to(() => NoticeDetailView(noticeId: notice.id))`
- **Ripple Effect**: InkWell 기본 splash, color: base300 (12% 투명도)

#### 빈 상태 (공지사항 없음)

```
Center
└── Padding (32)
    └── Column (mainAxisSize: min)
        ├── Icon (Icons.notifications_none, size: 64, color: base500)
        ├── SizedBox(height: 16)
        ├── Text ("아직 등록된 공지사항이 없습니다", style: titleMedium, color: textSecondary)
        ├── SizedBox(height: 8)
        └── Text ("새로운 공지사항이 등록되면 알려드릴게요", style: bodyMedium, color: textTertiary)
```

#### 로딩 상태 (초기 로딩)

```
Center
└── Column (mainAxisSize: min)
    ├── CircularProgressIndicator (color: accentPrimary)
    ├── SizedBox(height: 16)
    └── Text ("공지사항을 불러오는 중...", style: bodyMedium, color: textTertiary)
```

#### 에러 상태 (네트워크 오류)

```
Center
└── Padding (32)
    └── Column (mainAxisSize: min)
        ├── Icon (Icons.wifi_off, size: 64, color: error)
        ├── SizedBox(height: 16)
        ├── Text ("인터넷 연결을 확인해주세요", style: titleMedium, color: textSecondary)
        ├── SizedBox(height: 8)
        ├── Text (errorMessage, style: bodyMedium, color: textTertiary)
        ├── SizedBox(height: 24)
        └── SketchButton (
            text: "다시 시도",
            style: SketchButtonStyle.primary,
            onPressed: controller.refreshNotices,
          )
```

#### 무한 스크롤 로딩 인디케이터

```
// 목록 하단에 표시
Padding (vertical: 16)
└── Center
    └── CircularProgressIndicator (color: accentPrimary, size: 24)
```

---

## Screen 2: NoticeDetailView (공지사항 상세)

### 레이아웃 계층

```
Scaffold
├── AppBar
│   ├── leading: IconButton (뒤로가기)
│   └── title: Text ("공지사항")
│
└── body: SingleChildScrollView
    └── Padding (horizontal: 16, vertical: 16)
        └── Column (crossAxisAlignment: start)
            ├── _buildHeader() — 제목, 카테고리, 메타 정보
            │
            ├── SizedBox(height: 24)
            │
            ├── _buildMetaRow() — 조회수, 작성일시
            │
            ├── SizedBox(height: 16)
            │
            ├── Divider (thickness: 1, color: base300)
            │
            ├── SizedBox(height: 16)
            │
            └── _buildMarkdownBody() — 본문 (마크다운 렌더링)
```

### 위젯 상세

#### AppBar

- **leading**:
  - IconButton:
    - icon: Icons.arrow_back
    - onPressed: `Get.back()`
- **title**:
  - Text: "공지사항"
  - style: titleLarge (22sp)
- **backgroundColor**: Surface (white)
- **elevation**: 0

#### _buildHeader (헤더 - 제목 + 카테고리)

```dart
Column (crossAxisAlignment: start)
├── Row (고정 아이콘 + 제목)
│   ├── if (isPinned):
│   │   Container
│   │     ├── padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)
│   │     ├── decoration: BoxDecoration(
│   │     │     color: accentLight.withOpacity(0.2),
│   │     │     borderRadius: BorderRadius.circular(4),
│   │     │   )
│   │     └── Row
│   │         ├── Icon(Icons.push_pin, size: 14, color: accentDark)
│   │         ├── SizedBox(width: 4)
│   │         └── Text("고정", style: labelSmall, color: accentDark, fontWeight: 600)
│   │
│   ├── if (isPinned):
│   │   SizedBox(width: 8)
│   │
│   └── Expanded:
│       // 빈 공간 (제목은 아래 줄로)
│
├── SizedBox(height: 8)
│
├── Text (제목)
│   ├── text: title
│   ├── style: headlineMedium (28sp, fontWeight: 600)
│   └── color: textPrimary
│
├── SizedBox(height: 12)
│
└── if (category != null):
    SketchChip
      ├── label: category
      ├── backgroundColor: base100
      ├── textColor: base700
      ├── fontSize: 12sp (labelMedium)
      └── padding: (horizontal: 12, vertical: 4)
```

#### _buildMetaRow (메타 정보 행)

```dart
Wrap (spacing: 16, runSpacing: 8)
├── Row (mainAxisSize: min)
│   ├── Icon (Icons.visibility, size: 16, color: base500)
│   ├── SizedBox(width: 6)
│   └── Text ("조회 ${viewCount}회", style: bodyMedium, color: textTertiary)
│
└── Row (mainAxisSize: min)
    ├── Icon (Icons.calendar_today, size: 16, color: base500)
    ├── SizedBox(width: 6)
    └── Text (formatDateTime(createdAt), style: bodyMedium, color: textTertiary)
        // 예: "2026년 2월 4일 14:30"
```

#### _buildMarkdownBody (본문 - 마크다운)

```dart
// flutter_markdown 패키지 사용
MarkdownBody (
  data: content,
  styleSheet: MarkdownStyleSheet(
    // 헤딩
    h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
    h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
    h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textSecondary),

    // 본문
    p: TextStyle(fontSize: 16, height: 1.6, color: textPrimary),

    // 링크
    a: TextStyle(color: accentPrimary, decoration: TextDecoration.underline),

    // 코드
    code: TextStyle(
      fontFamily: 'Courier',
      fontSize: 14,
      backgroundColor: base100,
      color: base900,
    ),
    codeblockDecoration: BoxDecoration(
      color: base100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: base300, width: 1),
    ),

    // 리스트
    listBullet: TextStyle(fontSize: 16, color: accentPrimary),

    // 구분선
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: base300, width: 1)),
    ),

    // 인용구
    blockquote: TextStyle(fontSize: 16, color: textTertiary, fontStyle: FontStyle.italic),
    blockquoteDecoration: BoxDecoration(
      color: base100.withOpacity(0.5),
      borderRadius: BorderRadius.circular(4),
      border: Border(left: BorderSide(color: accentLight, width: 4)),
    ),
  ),

  // 링크 탭 핸들러
  onTapLink: (text, href, title) {
    if (href != null) {
      // url_launcher로 브라우저 열기
      launchUrl(Uri.parse(href));
    }
  },
)
```

**마크다운 지원 요소**:
- 제목 (# ~ ######)
- 굵은 글씨, 기울임 (**bold**, *italic*)
- 링크 ([텍스트](URL))
- 이미지 (![alt](URL))
- 리스트 (순서, 비순서)
- 코드 블록 (```)
- 인용구 (>)
- 구분선 (---)

#### 로딩 상태 (상세 조회 중)

```
Center (전체 화면 중앙)
└── Column (mainAxisSize: min)
    ├── CircularProgressIndicator (color: accentPrimary)
    ├── SizedBox(height: 16)
    └── Text ("공지사항을 불러오는 중...", style: bodyMedium, color: textTertiary)
```

#### 에러 상태 (삭제된 공지사항 등)

```
Center (전체 화면 중앙)
└── Padding (32)
    └── Column (mainAxisSize: min)
        ├── Icon (Icons.error_outline, size: 64, color: error)
        ├── SizedBox(height: 16)
        ├── Text ("삭제되었거나 존재하지 않는 공지사항입니다", style: titleMedium, color: textSecondary, textAlign: center)
        ├── SizedBox(height: 24)
        └── SketchButton (
            text: "목록으로",
            style: SketchButtonStyle.outline,
            onPressed: () => Get.back(),
          )
```

---

## Widget 3: UnreadNoticeBadge (읽지 않은 공지 뱃지)

### 레이아웃

```dart
// 앱 메인 화면 어디든 배치 가능 (독립 위젯)
// 예: AppBar actions, BottomNavigationBar 아이템 위

Obx(() {
  final unreadCount = controller.unreadCount.value;

  return Stack (
    clipBehavior: Clip.none,
    children: [
      // 원래 위젯 (예: IconButton)
      IconButton (
        icon: Icon(Icons.notifications),
        onPressed: () => Get.to(() => NoticeListView()),
      ),

      // 뱃지 (조건부 표시)
      if (unreadCount > 0)
        Positioned (
          right: 8,
          top: 8,
          child: Container (
            padding: EdgeInsets.symmetric(
              horizontal: unreadCount < 10 ? 6 : 4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: error, // #F44336 (빨간색)
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            constraints: BoxConstraints(minWidth: 18, minHeight: 18),
            child: Center(
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
    ],
  );
})
```

**스타일 속성**:

- **뱃지 Container**:
  - backgroundColor: error (#F44336)
  - borderRadius: 10 (pill 모양)
  - border: 2px solid white (주변과 구분)
  - padding: 6px horizontal (1~9), 4px (10+)
  - minWidth: 18, minHeight: 18 (읽기 쉬운 크기)
- **텍스트**:
  - fontSize: 10sp
  - fontWeight: bold
  - color: white
- **위치**:
  - right: 8, top: 8 (부모 위젯의 우상단)

---

## 색상 팔레트 (Frame0 Sketch Style)

### Primary Colors

- **accentPrimary**: `#DF7D5F` — 주요 강조 (버튼, 링크, 읽지 않은 표시)
- **accentLight**: `#F19E7E` — 밝은 강조 (고정 공지 배경)
- **accentDark**: `#C86947` — 어두운 강조 (고정 아이콘)

### Grayscale Colors

- **white**: `#FFFFFF` — 배경
- **base100**: `#F7F7F7` — Surface, 카드 배경
- **base200**: `#EBEBEB` — Surface variant
- **base300**: `#DCDCDC` — 테두리, Divider
- **base500**: `#8E8E8E` — 아이콘, 비활성 텍스트
- **base700**: `#5E5E5E` — 보조 텍스트
- **base900**: `#343434` — 제목, 강조 텍스트
- **black**: `#000000` — 주요 텍스트

### Semantic Colors

- **success**: `#4CAF50` — 성공 상태
- **warning**: `#FFC107` — 경고 상태
- **error**: `#F44336` — 에러, 삭제, 긴급 (뱃지)
- **info**: `#2196F3` — 정보 상태

### Sketch Alpha (80% 투명도 - 레이어 효과용)

- **accentPrimaryAlpha**: `#DF7D5FCC` (80%)
- **base300Alpha**: `#DCDCDCCC` (80%)

### 읽지 않은 공지 전용 배경

- **unreadBackground**: `#FFF9F7` (RGB: 255, 249, 247) — 아주 연한 오렌지 배경

---

## 타이포그래피 (Type Scale)

### Display (사용 안 함)

- displayLarge: 57sp, 400
- displayMedium: 45sp, 400
- displaySmall: 36sp, 400

### Headline

- **headlineLarge**: 32sp, 400 — (사용 안 함)
- **headlineMedium**: 28sp, 600 — 상세 화면 제목
- **headlineSmall**: 24sp, 400 — (사용 안 함)

### Title

- **titleLarge**: 22sp, 500 — AppBar 제목
- **titleMedium**: 16sp, 500 (안 읽음 600) — 목록 카드 제목
- **titleSmall**: 14sp, 500 — (사용 안 함)

### Body

- **bodyLarge**: 16sp, 400, height: 1.6 — 마크다운 본문
- **bodyMedium**: 14sp, 400 — 버튼, 일반 텍스트
- **bodySmall**: 12sp, 400 — 메타 정보, 날짜

### Label

- **labelLarge**: 14sp, 500 — 버튼 텍스트
- **labelMedium**: 12sp, 500 — 카테고리 태그
- **labelSmall**: 11sp, 500 — 고정 공지 작은 태그

---

## 스페이싱 시스템 (8dp 그리드)

### Padding/Margin

- **xs**: 4dp — 아주 작은 간격
- **sm**: 8dp — 작은 간격 (카드 내부 요소)
- **md**: 12dp — 기본 간격
- **lg**: 16dp — 화면 패딩, 섹션 간격
- **xl**: 24dp — 큰 간격 (헤더와 본문 구분)
- **2xl**: 32dp — 아주 큰 간격
- **3xl**: 48dp — 특별한 강조

### 컴포넌트별 스페이싱

- **화면 패딩**: 16dp (좌우), 16dp (상하)
- **카드 간 간격**: 8dp (목록)
- **카드 내부 패딩**: 12dp (horizontal), 10dp (vertical)
- **섹션 간격**: 16dp (일반), 24dp (큰 구분)
- **텍스트 행 간격**: 4dp (제목-메타), 8dp (제목-설명)

---

## Border Radius

- **sm**: 2dp — 작은 태그
- **md**: 4dp — 읽지 않은 점, 카테고리 칩
- **lg**: 8dp — 카드, 버튼, 마크다운 코드 블록
- **xl**: 12dp — 큰 카드
- **pill**: 9999dp — 뱃지

---

## Elevation (그림자)

- **Level 0**: 0dp — 배경, 평면
- **Level 1**: 1dp — 일반 카드
- **Level 2**: 2dp — 읽지 않은 공지 카드, 버튼
- **Level 3**: 4dp — 모달 다이얼로그
- **Level 4**: 8dp — (사용 안 함)

---

## 인터랙션 상태

### 카드 탭 상태

- **Default**: SketchCard elevation: 1 (일반), 2 (안 읽음)
- **Pressed**: InkWell splash (base300 12% 투명도)
- **Ripple Effect**: 기본 Material ripple, color: base300

### 버튼 상태 (SketchButton)

- **Default**: accentPrimary 배경, white 텍스트
- **Pressed**: accentDark (10% 어두움)
- **Loading**: CircularProgressIndicator (16x16) + 텍스트 비활성
- **Disabled**: opacity: 0.4

### TextField 상태 (SketchInput - 검색 기능 추가 시)

- **Default**: border 2px, base300
- **Focused**: border 2px, accentPrimary
- **Error**: border 2px, error

---

## 애니메이션

### 화면 전환

- **Route Transition**: fadeIn (300ms)
- **Curve**: Curves.easeInOut

### 상태 변경

- **Fade In/Out**: Duration: 200ms, Curve: Curves.easeIn
- **목록 아이템 등장**: 순차적 fadeIn (50ms delay)

### 로딩

- **CircularProgressIndicator**: Material 기본 스피너, color: accentPrimary
- **RefreshIndicator**: Material 기본 애니메이션

### 스크롤

- **무한 스크롤**: 부드러운 자동 로드 (하단 200px 진입 시 트리거)

---

## 반응형 레이아웃

### Breakpoints

- **Mobile**: width < 600dp (주요 타겟)
- **Tablet**: 600dp ≤ width < 1024dp (동일 레이아웃, 패딩만 증가)

### 적응형 레이아웃 전략

- **세로 모드**: 기본 1열 레이아웃
- **가로 모드** (모바일):
  - 목록: 1열 유지
  - 상세: 좌우 패딩 증가 (24dp → 48dp)

### 터치 영역

- **최소 크기**: 48x48dp (Material Design 가이드라인)
- **카드 전체**: 터치 영역 (전체 InkWell)
- **뒤로가기 버튼**: 48x48dp

---

## 접근성 (Accessibility)

### 색상 대비

- **제목 대 배경** (black on white): 21:1 (AAA 등급)
- **본문 대 배경** (base900 on white): 12.6:1 (AAA 등급)
- **메타 정보 대 배경** (base700 on white): 7.3:1 (AAA 등급)
- **읽지 않은 점** (accentPrimary): 읽음과 시각적 차이 명확

### 의미 전달

- **읽지 않은 공지**: 빨간 점 + 굵은 글씨 + 배경색 (3가지 신호)
- **고정 공지**: 핀 아이콘 + "고정" 텍스트 + 배경색
- **에러 상태**: 아이콘 + 텍스트 + 액션 버튼

### 스크린 리더 지원

- **Semantics**:
  - IconButton: "공지사항 새로고침", "뒤로가기"
  - NoticeListCard: "공지사항 제목, [읽지 않음], [고정], 카테고리, 조회수, 작성일"
  - UnreadNoticeBadge: "읽지 않은 공지 {count}개"

---

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

| 컴포넌트 | 용도 | 사용 화면 |
|---------|------|---------|
| `SketchCard` | 목록 카드 | NoticeListView |
| `SketchButton` | 재시도, 액션 버튼 | 에러 상태, 상세 화면 |
| `SketchChip` | 카테고리 태그 | 목록, 상세 |
| `SketchContainer` | (필요 시) 커스텀 컨테이너 | - |
| `SketchModal` | (확장 기능) 삭제 확인 다이얼로그 | - |

### 새로운 컴포넌트 (design-specialist 구현 필요)

| 컴포넌트 | 목적 | 재사용 가능성 |
|---------|------|-------------|
| `NoticeListCard` | 공지사항 목록 카드 위젯 | ✅ 다른 앱의 공지사항 목록 |
| `UnreadNoticeBadge` | 읽지 않은 개수 뱃지 | ✅ 모든 알림/공지 기능 |

---

## 상태별 UI 정의

### 1. 로딩 상태

| 화면 | UI |
|------|-----|
| 목록 초기 로딩 | 중앙 CircularProgressIndicator + "공지사항을 불러오는 중..." |
| 무한 스크롤 로딩 | 목록 하단 CircularProgressIndicator (24px) |
| 상세 조회 로딩 | 중앙 CircularProgressIndicator + "공지사항을 불러오는 중..." |

### 2. 빈 상태

| 화면 | UI |
|------|-----|
| 목록 (공지 없음) | 중앙 아이콘 (notifications_none) + "아직 등록된 공지사항이 없습니다" + 보조 텍스트 |

### 3. 에러 상태

| 상황 | UI | 액션 |
|------|-----|------|
| 네트워크 오류 | 중앙 wifi_off 아이콘 + "인터넷 연결을 확인해주세요" | "다시 시도" 버튼 |
| 삭제된 공지 (404) | 중앙 error_outline 아이콘 + "삭제되었거나 존재하지 않는 공지사항입니다" | "목록으로" 버튼 |
| 서버 오류 (5xx) | 중앙 error_outline 아이콘 + "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요" | "다시 시도" 버튼 |

### 4. 데이터 있음 (정상 상태)

| 화면 | UI |
|------|-----|
| 목록 (고정 + 일반) | 고정 공지 섹션 → 구분선 → 일반 공지 목록 |
| 목록 (일반만) | 일반 공지 목록만 표시 |
| 상세 | 헤더 (제목, 카테고리) → 메타 정보 → 구분선 → 마크다운 본문 |

---

## 인터랙션 정의

### 탭 (Tap)

| 요소 | 액션 | 피드백 |
|------|------|--------|
| NoticeListCard | 상세 화면으로 이동 | InkWell ripple + 읽음 처리 API 호출 |
| 새로고침 버튼 (AppBar) | 목록 새로고침 | RefreshIndicator 애니메이션 |
| 뒤로가기 버튼 | 이전 화면으로 | 기본 Navigator pop |
| 재시도 버튼 (에러 상태) | 데이터 재요청 | 로딩 상태 전환 |
| 링크 (마크다운 내) | 브라우저로 URL 열기 | url_launcher |

### 스크롤 (Scroll)

| 동작 | 액션 |
|------|------|
| 하단 200px 진입 | 다음 페이지 자동 로드 (hasMore == true) |
| 당겨서 새로고침 (Pull to Refresh) | 목록 처음부터 재요청 |

### 새로고침 (Refresh)

| 트리거 | 동작 |
|--------|------|
| RefreshIndicator 당김 | `controller.refreshNotices()` 호출 |
| AppBar 새로고침 버튼 | `controller.refreshNotices()` 호출 |

---

## 디자인 토큰 적용

### SketchDesignTokens (core 패키지)

모든 디자인 값은 `SketchDesignTokens`에서 가져옵니다.

```dart
import 'package:core/core.dart';

// 선 두께
SketchDesignTokens.strokeStandard // 2.0 (카드 테두리)

// 간격
SketchDesignTokens.spacingLg      // 16.0 (화면 패딩)
SketchDesignTokens.spacingSm      // 8.0 (카드 간격)

// 모서리
SketchDesignTokens.radiusLg       // 8.0 (카드)
SketchDesignTokens.radiusMd       // 4.0 (칩, 점)

// 색상
SketchDesignTokens.accentPrimary  // #DF7D5F
SketchDesignTokens.base300        // #DCDCDC (테두리)
SketchDesignTokens.error          // #F44336 (뱃지)

// 폰트 크기
SketchDesignTokens.fontSizeBase   // 16.0
SketchDesignTokens.fontSize2Xl    // 24.0

// 투명도
SketchDesignTokens.opacitySketch  // 0.8
```

---

## 재사용 가능한 위젯 목록

### 1. NoticeListCard (공지사항 목록 카드)

**경로**: `packages/notice/lib/src/widgets/notice_list_card.dart`

**Props**:
```dart
class NoticeListCard extends StatelessWidget {
  final String noticeId;
  final String title;
  final String? category;
  final bool isPinned;
  final bool isRead;
  final int viewCount;
  final DateTime createdAt;
  final VoidCallback onTap;

  const NoticeListCard({
    required this.noticeId,
    required this.title,
    this.category,
    required this.isPinned,
    required this.isRead,
    required this.viewCount,
    required this.createdAt,
    required this.onTap,
  });
}
```

**용도**: 목록 화면에서 각 공지사항 표시

**재사용성**: ✅ 다른 앱의 공지사항 목록에서 사용 가능

---

### 2. UnreadNoticeBadge (읽지 않은 공지 뱃지)

**경로**: `packages/notice/lib/src/widgets/unread_notice_badge.dart`

**Props**:
```dart
class UnreadNoticeBadge extends StatelessWidget {
  final int unreadCount;
  final Widget child;

  const UnreadNoticeBadge({
    required this.unreadCount,
    required this.child,
  });
}
```

**용도**: 앱 메인 화면에서 읽지 않은 공지 개수 표시

**재사용성**: ✅ 모든 알림/공지 기능에서 사용 가능

---

## Frame0 Sketch 스타일 적용 방안

### 1. SketchCard 활용

모든 공지사항 카드는 `SketchCard` 위젯을 기반으로 합니다.

```dart
SketchCard(
  elevation: !isRead ? 2 : 1,
  borderColor: !isRead ? SketchDesignTokens.accentPrimary : SketchDesignTokens.base300,
  fillColor: !isRead ? Color(0xFFFFF9F7) : Colors.white,
  roughness: 0.8,
  body: /* 카드 내용 */,
  onTap: onTap,
)
```

### 2. 손그림 효과 (Roughness)

- **roughness**: 0.8 (기본값)
- 카드, 버튼, 입력 필드의 테두리가 약간 불규칙하게 표시됨
- Frame0 스타일의 친근한 느낌 제공

### 3. 노이즈 텍스처 (선택 사항)

- `SketchContainer`의 `enableNoise: true` 옵션
- 종이 질감 효과 추가 (미묘한 노이즈 오버레이)
- 성능 고려하여 필요한 경우만 적용

### 4. 스케치 색상 활용

- **accentPrimary** (#DF7D5F): 따뜻한 코랄/오렌지 계열
- **base 그레이스케일**: 부드러운 회색 톤
- Frame0 앱의 색상 팔레트와 일치

---

## 참고 자료

- **Material Design 3**: https://m3.material.io/
- **Flutter Widget Catalog**: https://docs.flutter.dev/ui/widgets
- **Frame0.app**: https://frame0.app (디자인 영감)
- **flutter_markdown**: https://pub.dev/packages/flutter_markdown (마크다운 렌더링)
- **디자인 토큰**: `.claude/guide/mobile/design-tokens.json`
- **기존 UI 패턴**: `docs/wowa/mobile-catalog.md`

---

## 다음 단계

이 디자인 명세를 기반으로 **tech-lead**가 기술 아키텍처를 설계합니다.

- **서버 API 설계**: 목록 조회, 상세 조회, 읽음 처리, 읽지 않은 개수 API
- **모바일 패키지 구조**: `packages/notice/` 내 models, services, controllers, views, widgets 구성
- **GetX 상태 관리**: NoticeListController, NoticeDetailController
- **Freezed 모델**: Notice, NoticeListResponse
- **무한 스크롤 페이지네이션**: Offset 기반 또는 Cursor 기반 결정
- **마크다운 렌더링**: flutter_markdown 패키지 통합
