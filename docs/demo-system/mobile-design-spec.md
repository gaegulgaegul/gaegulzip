# UI/UX 디자인 명세: SDK 데모 시스템

## 개요

개발자가 QnA 및 Notice SDK의 UI/UX를 실제 환경에서 검증하고, Design System(Frame0 스케치 스타일)과의 통합 동작을 확인할 수 있는 데모 시스템을 제공합니다. 기존 design_system_demo 앱의 홈 화면에 "SDK Demos" 카테고리를 추가하고, SDK별 데모 화면을 제공하여 다양한 상태(로딩, 에러, 성공)를 시뮬레이션할 수 있도록 합니다.

## 화면 구조

### Screen 1: 홈 화면 (수정)

**기존 화면에 SDK Demos 카테고리 추가**

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Title: Text("Sketch Design System")
    └── Actions: IconButton (테마 토글 - 라이트/다크)
└── Body: Padding (16dp)
    └── GridView.builder (2열 그리드)
        ├── CategoryCard (Widgets - 13 items)
        ├── CategoryCard (Painters - 5 items)
        ├── CategoryCard (Theme - 6 items)
        ├── CategoryCard (Colors - 6 items)
        ├── CategoryCard (Tokens)
        └── CategoryCard (SDK Demos - 2 items) ← NEW
```

#### 위젯 상세

**CategoryCard (SDK Demos - 신규)**

- **Container** (라운드 카드)
  - decoration:
    - color: 라이트모드 `SketchDesignTokens.white`, 다크모드 `SketchDesignTokens.surfaceDark` (또는 `Color(0xFF2A2A2A)`)
    - borderRadius: `BorderRadius.circular(SketchDesignTokens.radiusXl)` (12dp)
  - child: Column (mainAxisAlignment: center)
    - Icon: `LucideIcons.package` (size: 48)
    - SizedBox(height: 12)
    - Text: "SDK Demos" (fontSize: 16, fontWeight: bold)
    - SizedBox(height: 4)
    - Text: "2 items" (fontSize: 14, color: base500)

- **GestureDetector**
  - onTap: `controller.navigateTo(Routes.SDK_DEMOS)`

**HomeController 수정 사항**:
- `categories` 리스트에 신규 CategoryItem 추가:
  ```dart
  CategoryItem(
    name: 'SDK Demos',
    icon: LucideIcons.package,
    route: Routes.SDK_DEMOS,
    itemCount: 2,
    description: 'QnA 및 Notice SDK 데모',
  )
  ```

---

### Screen 2: SDK 목록 화면 (신규)

**SDK 패키지별 진입점 제공**

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("SDK Demos")
└── Body: Padding (horizontal: 16, vertical: 16)
    └── ListView
        ├── SizedBox(height: 8)
        ├── Text ("SDK 패키지를 선택하세요", 안내 문구)
        ├── SizedBox(height: 16)
        ├── SDKItemCard (QnA)
        ├── SizedBox(height: 12)
        ├── SDKItemCard (Notice)
        └── SizedBox(height: 16)
```

#### 위젯 상세

**SDKItemCard (QnA)**

- **SketchCard** (Frame0 스타일 카드)
  - child: InkWell
    - onTap: `Get.toNamed(Routes.SDK_QNA_DEMO)`
    - child: Padding (16dp)
      - Row
        - Icon: `Icons.question_answer` (size: 40, color: accentPrimary)
        - SizedBox(width: 16)
        - Expanded
          - Column (crossAxisAlignment: start)
            - Text: "QnA SDK" (fontSize: 18, fontWeight: 600)
            - SizedBox(height: 4)
            - Text: "질문 제출 기능 테스트" (fontSize: 14, color: base700)
        - Icon: `Icons.chevron_right` (color: base500)

**SDKItemCard (Notice)**

- **SketchCard** (Frame0 스타일 카드)
  - child: InkWell
    - onTap: `Get.toNamed(Routes.SDK_NOTICE_DEMO)`
    - child: Padding (16dp)
      - Row
        - Icon: `Icons.notifications` (size: 40, color: accentPrimary)
        - SizedBox(width: 16)
        - Expanded
          - Column (crossAxisAlignment: start)
            - Text: "Notice SDK" (fontSize: 18, fontWeight: 600)
            - SizedBox(height: 4)
            - Text: "공지사항 목록/상세 테스트" (fontSize: 14, color: base700)
        - Icon: `Icons.chevron_right` (color: base500)

**안내 문구**:
- fontSize: 14
- color: base700
- text: "각 SDK 패키지의 UI/UX를 테스트할 수 있습니다."

---

### Screen 3: QnA 데모 화면 (신규)

**QnA SDK의 QnaSubmitView를 래핑하는 데모 화면**

#### 레이아웃 계층

```
Scaffold
└── AppBar (QnaSubmitView 자체 AppBar 사용)
    ├── Leading: IconButton (뒤로가기) ← SDK 원본
    ├── Title: Text("질문하기")
    └── centerTitle: true
└── Body: QnaSubmitView 위젯 직접 렌더링
    └── (SDK 패키지의 QnaSubmitView 그대로 표시)
```

#### 위젯 상세

**QnA 데모 래핑 전략**:
- **SDK 원본 수정 금지**: `packages/qna/lib/src/views/qna_submit_view.dart` 파일 수정하지 않음
- **데모 앱에서 래핑**: 데모 앱에서 `QnaSubmitView`를 직접 렌더링
- **GetX Binding**: `QnaBinding(appCode: 'demo')`을 라우트에 직접 사용하여 `QnaController`, `QnaRepository`, `QnaApiService`를 자동 등록

**데모 화면 구성**:
```dart
class SdkQnaDemoView extends StatelessWidget {
  const SdkQnaDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const QnaSubmitView(); // SDK 위젯 직접 사용
  }
}
```

**실서버 연동**:
- QnaBinding(appCode: 'demo')을 사용하여 실서버 API와 연동
- main.dart에서 Dio를 전역 등록하고, .env의 API_BASE_URL을 사용
- 별도의 Mock Controller 없이 SDK 원본 동작 검증

**QnA SDK UI 요소** (원본 그대로 유지):
- **제목 입력 필드**: SketchInput (최대 256자)
  - label: "제목 *"
  - hint: "질문 제목을 입력하세요 (최대 256자)"
  - prefixIcon: Icons.edit (size: 20)
  - errorText: 유효성 검증 에러 메시지

- **본문 입력 필드**: SketchInput (최대 65536자)
  - label: "질문 내용 *"
  - hint: "구체적으로 작성할수록 빠른 답변을 받을 수 있습니다"
  - minLines: 8, maxLines: 20
  - prefixIcon: Icons.description (size: 20)

- **글자 수 카운터**: 본문 우측 하단
  - "본문: {count} / 65536자"
  - 60000자 초과: warning 색상 (노란색)
  - 65000자 초과: error 색상 (빨간색)

- **제출 버튼**: SketchButton
  - text: "질문 제출"
  - icon: Icons.send (size: 16)
  - size: SketchButtonSize.large
  - style: SketchButtonStyle.primary
  - isLoading: 제출 중 로딩 표시
  - onPressed: 유효성 검증 통과 시 활성화

---

### Screen 4: Notice 데모 화면 (신규)

**Notice SDK의 NoticeListView를 래핑하는 데모 화면**

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    ├── Title: Text("공지사항")
    └── Actions: IconButton (새로고침)
└── Body: NoticeListView 위젯 직접 렌더링
    └── (SDK 패키지의 NoticeListView 그대로 표시)
```

#### 위젯 상세

**Notice 데모 래핑 전략**:
- **SDK 원본 수정 금지**: `packages/notice/lib/src/views/notice_list_view.dart` 파일 수정하지 않음
- **데모 앱에서 래핑**: 데모 앱에서 `NoticeListView`를 직접 렌더링
- **GetX Binding**: `NoticeListController`를 데모 앱의 Binding에 등록

**데모 화면 구성**:
```dart
class SdkNoticeDemoView extends StatelessWidget {
  const SdkNoticeDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoticeListView(); // SDK 위젯 직접 사용
  }
}
```

**실서버 연동**:
- NoticeBinding(appCode: 'demo')을 사용하여 실서버 API와 연동
- NoticeApiService가 main.dart에서 전역 등록된 Dio를 사용
- 실서버에서 공지사항 목록/상세를 조회하여 SDK 원본 동작 검증

**Notice SDK UI 요소** (원본 그대로 유지):
- **RefreshIndicator**: 아래로 당겨 새로고침
  - color: accentPrimary

- **고정 공지 섹션**:
  - 헤더: "📌 고정 공지" (fontSize: 16, fontWeight: 600)
  - NoticeListCard 목록 (고정 공지)

- **구분선**: Divider (thickness: 1)

- **일반 공지 섹션**:
  - 헤더: "최신 공지" (fontSize: 16, fontWeight: 600)
  - NoticeListCard 목록 (일반 공지)

- **무한 스크롤 로딩**: 하단 CircularProgressIndicator

- **로딩 상태**:
  - 중앙 Column
    - CircularProgressIndicator
    - SizedBox(height: 16)
    - Text: "공지사항을 불러오는 중..."

- **에러 상태**:
  - 중앙 Column
    - Icon: Icons.wifi_off (size: 64, color: grey)
    - SizedBox(height: 16)
    - Text: "인터넷 연결을 확인해주세요" (fontSize: 16)
    - Text: 에러 메시지 (color: grey)
    - SketchButton: "다시 시도" (style: primary)

- **빈 상태**:
  - 중앙 Column
    - Icon: Icons.notifications_none (size: 64, color: grey)
    - SizedBox(height: 16)
    - Text: "아직 등록된 공지사항이 없습니다" (fontSize: 16)
    - Text: "새로운 공지사항이 등록되면 알려드릴게요" (color: grey)

---

### Screen 5: Notice 상세 화면 (SDK 원본)

**Notice SDK의 NoticeDetailView 그대로 사용**

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("공지사항 상세")
└── Body: NoticeDetailView
    └── (SDK 패키지의 NoticeDetailView 그대로 표시)
```

**라우팅**:
- NoticeListCard의 onTap 이벤트 → `Get.toNamed('/notice/detail', arguments: noticeId)`
- 데모 앱 `app_pages.dart`에서 `Routes.NOTICE_DETAIL` GetPage를 별도 등록
- `NoticeDetailController(appCode: 'demo')`를 `BindingsBuilder`로 주입 (SDK NoticeBinding과 별도)

---

## 네비게이션 맵

```
홈 화면 (HomeView)
  ├── Widgets → WidgetCatalogView (기존)
  ├── Painters → PainterCatalogView (기존)
  ├── Theme → ThemeShowcaseView (기존)
  ├── Colors → ColorPaletteView (기존)
  ├── Tokens → TokensView (기존)
  └── SDK Demos → SdkListView (신규)
       ├── QnA → SdkQnaDemoView (신규)
       │   └── (QnaSubmitView - SDK 원본)
       └── Notice → SdkNoticeDemoView (신규)
           └── (NoticeListView - SDK 원본)
               └── NoticeDetailView - SDK 원본
```

**라우팅 경로** (`Routes` 클래스에 추가):
```dart
static const SDK_DEMOS = '/sdk-demos';
static const SDK_QNA_DEMO = '/sdk-demos/qna';
static const SDK_NOTICE_DEMO = '/sdk-demos/notice';
static const SDK_NOTICE_DETAIL = '/sdk-demos/notice/detail';
```

---

## 색상 팔레트 (Frame0 스케치 스타일)

### Primary Colors

- **accentPrimary**: `Color(0xFF2196F3)` - 주요 액션, 버튼, 링크
- **accentPrimaryLight**: `Color(0xFF64B5F6)` - 호버 상태, 밝은 강조
- **accentPrimaryDark**: `Color(0xFF1976D2)` - Pressed 상태, 어두운 강조

### Secondary Colors (CTA 버튼용)

- **accentSecondary**: `Color(0xFFDF7D5F)` - 코랄/오렌지 (CTA 전용)
- **accentSecondaryLight**: `Color(0xFFF19E7E)` - 밝은 코랄
- **accentSecondaryDark**: `Color(0xFFC86947)` - 어두운 코랄

### Background Colors (라이트모드)

- **background**: `Color(0xFFFAF8F5)` - 앱 배경 (크림색)
- **surface**: `Color(0xFFF5F0E8)` - 카드/모달 표면 (따뜻한 크림)
- **white**: `Color(0xFFFFFFFF)` - 순수 흰색

### Background Colors (다크모드)

- **backgroundDark**: `Color(0xFF1A1D29)` - 앱 배경 (네이비)
- **surfaceDark**: `Color(0xFF23273A)` - 카드/모달 표면 (어두운 네이비)

### Base Grayscale

- **base100**: `Color(0xFFF7F7F7)` - 거의 흰색
- **base200**: `Color(0xFFEBEBEB)` - 밝은 회색
- **base300**: `Color(0xFFDCDCDC)` - 부드러운 회색
- **base500**: `Color(0xFF8E8E8E)` - 중간 회색 (보조 텍스트, 아이콘)
- **base700**: `Color(0xFF5E5E5E)` - 어두운 회색 (본문 텍스트)
- **base900**: `Color(0xFF343434)` - 거의 검은색 (제목, 테두리)

### Semantic Colors

- **success**: `Color(0xFF4CAF50)` - 성공 상태
- **warning**: `Color(0xFFFFC107)` - 경고 상태 (글자 수 초과)
- **error**: `Color(0xFFF44336)` - 에러 상태
- **info**: `Color(0xFF2196F3)` - 정보 색상

### Semantic Colors (다크모드)

- **successDark**: `Color(0xFF66BB6A)`
- **warningDark**: `Color(0xFFFFCA28)`
- **errorDark**: `Color(0xFFEF5350)`
- **infoDark**: `Color(0xFF64B5F6)`

---

## 타이포그래피 (Frame0 스타일)

### 폰트 패밀리

- **fontFamilyHand**: `'Loranthus'` - 손글씨 스타일 (Sketch 테마 기본)
- **fontFamilyHandKr**: `'KyoboHandwriting2019'` - 한글 손글씨 (fallback)
- **fontFamilySans**: `'Roboto'` - 산세리프 (Solid 테마 기본)
- **fontFamilyMono**: `'JetBrainsMono'` - 코드, 숫자

### 폰트 크기 스케일

- **fontSizeXs**: 12dp - 작은 라벨, 캡션
- **fontSizeSm**: 14dp - 본문 (작음), 보조 텍스트
- **fontSizeBase**: 16dp - 본문 (기본)
- **fontSizeLg**: 18dp - 큰 본문, 카드 제목
- **fontSizeXl**: 20dp - 작은 헤딩
- **fontSize2Xl**: 24dp - 중간 헤딩
- **fontSize3Xl**: 30dp - 큰 헤딩
- **fontSize4Xl**: 36dp - 매우 큰 헤딩
- **fontSize5Xl**: 48dp - 타이틀
- **fontSize6Xl**: 60dp - 히어로 타이틀

### 타이포그래피 사용 예시

- **AppBar Title**: fontSize: 20px (fontSizeXl), fontWeight: 600
- **Category Card Name**: fontSize: 16px (fontSizeBase), fontWeight: bold
- **SDK Item Title**: fontSize: 18px (fontSizeLg), fontWeight: 600
- **SDK Item Description**: fontSize: 14px (fontSizeSm), color: base700
- **안내 문구**: fontSize: 14px (fontSizeSm), color: base700, height: 1.5
- **글자 수 카운터**: fontSize: 12px (fontSizeXs)

---

## 스페이싱 시스템 (8dp 그리드)

### Padding/Margin

- **spacingXs**: 4dp - 아주 작은 간격
- **spacingSm**: 8dp - 작은 간격
- **spacingMd**: 12dp - 중간 간격
- **spacingLg**: 16dp - 기본 간격 (화면 패딩, 카드 내부)
- **spacingXl**: 24dp - 큰 간격 (섹션 구분)
- **spacing2Xl**: 32dp - 매우 큰 간격
- **spacing3Xl**: 48dp - 특별한 강조

### 컴포넌트별 스페이싱

- **화면 패딩**: 16dp (좌우) - `Padding(horizontal: 16)`
- **그리드 간격**: 16dp (mainAxisSpacing, crossAxisSpacing)
- **카드 간격**: 12dp (ListView.separated)
- **위젯 간 간격**: 8dp (작은 요소), 12dp (중간), 16dp (기본), 24dp (섹션)
- **SketchCard 내부 패딩**: 16dp
- **SketchButton 내부 패딩**: horizontal: 24dp, vertical: 12dp (large)

---

## Border Radius

- **radiusNone**: 0dp - 모서리 둥글기 없음
- **radiusSm**: 2dp - 작은 모서리
- **radiusMd**: 4dp - 중간 모서리
- **radiusLg**: 8dp - 큰 모서리 (카드 기본)
- **radiusXl**: 12dp - 매우 큰 모서리 (카테고리 카드)
- **radius2Xl**: 16dp - 2배 큰 모서리
- **radiusPill**: 9999dp - 완전히 둥근 (버튼)

### 컴포넌트별 적용

- **CategoryCard**: 12dp (radiusXl)
- **SketchCard**: 8dp (radiusLg)
- **SketchButton**: 9999dp (radiusPill)
- **SketchInput**: 4dp (radiusMd)

---

## Elevation (그림자)

### Frame0 스타일 그림자

- **shadowOffsetMd**: Offset(0, 2) - 중간 높이 그림자 오프셋
- **shadowBlurMd**: 4.0 - 중간 높이 그림자 블러 반경
- **shadowColor**: `Color(0x26000000)` - rgba(0, 0, 0, 0.15)

### 컴포넌트별 적용

- **SketchCard**: shadowOffsetMd, shadowBlurMd, shadowColor (기본)
- **CategoryCard**: elevation 없음 (깔끔한 카드 스타일)
- **SketchButton**: elevation 없음 (평면 버튼)

---

## 인터랙션 상태

### 버튼 상태

- **Default**:
  - Primary: backgroundColor: accentPrimary, textColor: white
  - Secondary: backgroundColor: transparent, textColor: base900, border: base300
  - Disabled: backgroundColor: base300, textColor: base500, opacity: 0.4

- **Pressed**: 색상 약간 어두워짐 (darken 10%)
  - Primary: accentPrimaryDark

- **Loading**: CircularProgressIndicator (16x16) + 텍스트

### TextField 상태 (SketchInput)

- **Default**:
  - Border: 2px, color: base300
  - Hint: color: base500

- **Focused**:
  - Border: 2px, color: accentPrimary
  - Hint: color: base700

- **Error**:
  - Border: 2px, color: error
  - 하단 에러 메시지: color: error, fontSize: 12px

- **Disabled**:
  - Border: 1px, color: base300
  - Background: base100
  - opacity: 0.4

### 터치 피드백

- **Ripple Effect**: InkWell 기본 ripple
- **Splash Color**: accentPrimary 12% 투명도
- **Highlight Color**: accentPrimary 8% 투명도

### 카드 터치 상태

- **GestureDetector**: 카테고리 카드 (Scaffold 색상 유지)
- **InkWell**: SDK 아이템 카드 (ripple 효과)

---

## 애니메이션

### 화면 전환

- **Route Transition**: GetX 기본 전환 (Fade + Slide)
- **Duration**: 300ms
- **Curve**: Curves.easeInOut

### 상태 변경

- **Fade In/Out**: Duration: 200ms, Curve: Curves.easeIn (로딩 상태 표시)
- **Obx 리빌드**: 즉시 반영 (애니메이션 없음)

### 로딩

- **CircularProgressIndicator**: Material 기본 스피너
- **색상**: accentPrimary (RefreshIndicator)

---

## 반응형 레이아웃

### Breakpoints

- **Mobile**: width < 600dp (기본)
- **Tablet**: 600dp ≤ width < 1024dp (2열 그리드 유지)
- **Desktop**: width ≥ 1024dp (3열 그리드로 변경 가능)

### 적응형 레이아웃 전략

- **세로 모드**: 2열 그리드 (홈 화면), 1열 리스트 (SDK 목록)
- **가로 모드**: 2열 그리드 유지 (홈 화면), 1열 리스트 유지 (SDK 목록)

### 터치 영역

- **최소 크기**: 48x48dp (Material Design 가이드라인)
- **권장 크기**: 56x56dp (IconButton)
- **카드 높이**: GridView childAspectRatio: 1.0 (정사각형 카드)

---

## 접근성 (Accessibility)

### 색상 대비

- **텍스트 대 배경**: 최소 4.5:1 (WCAG AA)
  - base900 on white: 11.8:1 (통과)
  - base700 on white: 7.9:1 (통과)
  - base500 on white: 4.6:1 (통과)

- **큰 텍스트 대 배경**: 최소 3:1 (WCAG AA)
  - base500 on white: 4.6:1 (통과)

### 의미 전달

- **색상만으로 의미 전달 금지**: 에러는 빨간색 + 에러 아이콘 + 에러 메시지
- **에러 표시**: error 색상 + Icons.wifi_off + "인터넷 연결을 확인해주세요"
- **성공 표시**: success 색상 + Icons.check_circle + "제출되었습니다"

### 스크린 리더 지원

- **Semantics**: 모든 인터랙티브 요소에 label 제공
- **Button**: "SDK Demos 카테고리 카드", "QnA SDK 항목", "질문 제출 버튼"
- **TextField**: "질문 제목 입력 필드", "질문 내용 입력 필드"

---

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

- **SketchCard**: SDK 아이템 카드, Notice 카드
- **SketchButton**: "질문 제출" 버튼, "다시 시도" 버튼
- **SketchInput**: 제목 입력, 본문 입력 (QnA)
- **SketchContainer**: 래퍼 컨테이너 (필요 시)
- **SketchModal**: 성공/에러 모달 (필요 시)
- **SketchDivider**: 구분선 (고정 공지 섹션 하단)

### 새로운 컴포넌트 필요 여부

**현재 design_system 패키지로 충분**:
- SDK 아이템 카드는 SketchCard로 구현 가능
- 카테고리 카드는 Container (라운드 카드 스타일)로 구현 가능
- 모든 입력 필드는 SketchInput으로 구현됨 (SDK 원본)
- 버튼은 SketchButton으로 구현됨 (SDK 원본)

**신규 컴포넌트 불필요**:
- 기존 컴포넌트로 모든 요구사항 충족

---

## 모의 데이터 시뮬레이션

### QnA SDK 모의 응답

**성공 시나리오**:
- `submitQuestion()` 호출 → 2초 딜레이 → 성공 모달 표시
- 모달 내용: "질문이 제출되었습니다. 빠르게 답변드리겠습니다."
- 모달 닫기 → 입력 필드 초기화

**에러 시나리오**:
- 네트워크 에러: "인터넷 연결을 확인해주세요" (에러 모달)
- 서버 에러: "잠시 후 다시 시도해주세요" (에러 모달)

### Notice SDK 모의 데이터

**고정 공지 (2개)**:
```dart
[
  NoticeModel(
    id: 1,
    title: "v1.0.0 업데이트 안내",
    content: "새로운 기능이 추가되었습니다.",
    isPinned: true,
    createdAt: DateTime.now().subtract(Duration(days: 3)),
  ),
  NoticeModel(
    id: 2,
    title: "서비스 점검 안내",
    content: "2026년 2월 15일 오전 2시~5시 서비스 점검 예정",
    isPinned: true,
    createdAt: DateTime.now().subtract(Duration(days: 5)),
  ),
]
```

**일반 공지 (10개 + 무한 스크롤)**:
- 초기 로드: 10개 공지 생성
- 무한 스크롤: 스크롤 하단 도달 시 5개씩 추가 로드
- 읽음 상태: 카드 탭 시 읽음 상태로 변경 (UnreadNoticeBadge 숨김)

**상태별 UI**:
- 로딩 상태: CircularProgressIndicator + "공지사항을 불러오는 중..."
- 에러 상태: Icons.wifi_off + "인터넷 연결을 확인해주세요" + "다시 시도" 버튼
- 빈 상태: Icons.notifications_none + "아직 등록된 공지사항이 없습니다"
- 성공 상태: 고정 공지 섹션 + 일반 공지 섹션 + 무한 스크롤

---

## 라이트/다크 테마 적용 가이드

### 테마 전환 메커니즘

- **AppBar Actions**: IconButton (라이트/다크 모드 아이콘)
- **SketchThemeController**: `toggleBrightness()` 메서드 호출
- **Obx**: 반응형으로 아이콘 변경 (Icons.light_mode_outlined / Icons.dark_mode_outlined)

### 라이트 테마

- **배경**: background (#FAF8F5 - 크림색)
- **카드**: white (#FFFFFF)
- **텍스트**: base900 (#343434 - 거의 검은색)
- **보조 텍스트**: base700 (#5E5E5E)
- **테두리**: base900 (#343434)
- **강조 색상**: accentPrimary (#2196F3)

### 다크 테마

- **배경**: backgroundDark (#1A1D29 - 네이비)
- **카드**: Color(0xFF2A2A2A) - 어두운 회색
- **텍스트**: textPrimaryDark (#FFFFFF)
- **보조 텍스트**: textSecondaryDark (#E5E5E5)
- **테두리**: base700 (#5E5E5E)
- **강조 색상**: accentPrimaryLight (#64B5F6)

### SDK 위젯 테마 적용

- **SketchInput**: `SketchThemeExtension`에서 테두리 색상 자동 변경
- **SketchButton**: `SketchThemeExtension`에서 텍스트 색상 자동 변경
- **SketchCard**: `SketchThemeExtension`에서 배경/테두리 색상 자동 변경
- **NoticeListCard**: `SketchDesignTokens` 토큰으로 테마별 색상 참조

**테마 전환 애니메이션**:
- Duration: 300ms (SketchThemeController 기본)
- Curve: Curves.easeInOut (Material 기본)

---

## 참고 자료

- **Material Design 3**: https://m3.material.io/
- **Flutter Widget Catalog**: https://docs.flutter.dev/ui/widgets
- **Frame0 Design System**: https://frame0.app
- **GetX Documentation**: https://pub.dev/packages/get
- **design-tokens.json**: `.claude/guide/mobile/design-tokens.json`

---

## 구현 우선순위

### 1단계: 라우팅 및 화면 구조

- [ ] Routes 클래스에 신규 라우트 추가 (`SDK_DEMOS`, `SDK_QNA_DEMO`, `SDK_NOTICE_DEMO`)
- [ ] SdkListView 생성 (SDK 목록 화면)
- [ ] SdkQnaDemoView 생성 (QnA 데모 화면)
- [ ] SdkNoticeDemoView 생성 (Notice 데모 화면)
- [ ] GetX Pages 테이블에 라우트 등록

### 2단계: 홈 화면 수정

- [ ] HomeController에 "SDK Demos" CategoryItem 추가
- [ ] 아이콘: LucideIcons.package
- [ ] itemCount: 2
- [ ] description: "QnA 및 Notice SDK 데모"

### 3단계: SDK 목록 화면 구현

- [ ] SdkListController 생성 (SDK 항목 관리)
- [ ] SDKItemCard 위젯 생성 (SketchCard 기반)
- [ ] QnA, Notice 항목 추가
- [ ] 네비게이션 연결

### 4단계: QnA 데모 화면 구현

- [ ] SdkQnaDemoBinding 생성 (QnaController 등록)
- [ ] SdkQnaDemoView에서 QnaSubmitView 렌더링
- [ ] 모의 응답 시뮬레이션 (성공/에러 모달)

### 5단계: Notice 데모 화면 구현

- [ ] SdkNoticeDemoBinding 생성 (NoticeListController 등록)
- [ ] SdkNoticeDemoView에서 NoticeListView 렌더링
- [ ] 모의 데이터 생성 (고정 공지 2개, 일반 공지 10개)
- [ ] 무한 스크롤 시뮬레이션

### 6단계: 테마 적용 검증

- [ ] 라이트/다크 모드 전환 테스트
- [ ] SDK 위젯 색상 변경 확인
- [ ] 카테고리 카드 배경 색상 확인

### 7단계: 접근성 및 최적화

- [ ] Semantics 라벨 추가
- [ ] 터치 영역 최소 48x48dp 확인
- [ ] const 생성자 적용 (성능 최적화)
- [ ] 주석 추가 (한글 정책)

---

## 기술적 제약사항

- **SDK 패키지 수정 금지**: `packages/qna/`, `packages/notice/` 원본 코드 수정 불가
- **데모 앱에서 래핑**: design_system_demo 앱에서 SDK 위젯을 import하여 렌더링
- **GetX Binding 패턴**: 각 SDK Controller를 Binding으로 등록
- **const 생성자 사용**: 정적 위젯은 const로 선언 (성능 최적화)
- **주석 한글 정책**: 모든 주석은 한글로 작성, 기술 용어만 영어 유지
- **테스트 코드 작성 금지**: CLAUDE.md 정책에 따라 테스트 코드 작성하지 않음

---

## 다음 단계

tech-lead 에이전트가 이어서 기술 아키텍처를 설계합니다.
