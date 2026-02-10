# UI/UX 디자인 명세: 박스 관리 기능 개선

## 개요
크로스핏 박스를 더 쉽게 찾고 관리할 수 있도록 검색 경험을 단순화합니다. 기존의 이름/지역 분리 입력 방식을 통합 키워드 검색으로 변경하여 사용자가 빠르게 원하는 박스를 찾을 수 있도록 개선합니다.

## 화면 구조

### Screen 1: 박스 찾기 (BoxSearchView) — 개선

#### 레이아웃 계층
```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("박스 찾기")
└── Body: SafeArea
    ├── Column
    │   ├── Container (검색 영역, padding: 16)
    │   │   └── SketchInput (통합 검색)
    │   │       ├── prefixIcon: Icons.search
    │   │       ├── hint: "박스 이름이나 지역을 검색하세요"
    │   │       ├── onChanged: 300ms debounce → search()
    │   │       └── suffixIcon: IconButton(Icons.clear) — 검색어 있을 때만
    │   │
    │   ├── SizedBox(height: 16)
    │   │
    │   └── Expanded (검색 결과 영역)
    │       └── Obx(() => _buildSearchResults())
    │           ├── [로딩] → Center(CircularProgressIndicator)
    │           ├── [검색어 없음] → Center(Column)
    │           │   ├── Icon(Icons.search, size: 64, color: base300)
    │           │   ├── SizedBox(height: 16)
    │           │   └── Text("박스 이름이나 지역을 검색해보세요", style: textSecondary)
    │           ├── [결과 없음] → Center(Column)
    │           │   ├── Icon(Icons.location_off, size: 64, color: base300)
    │           │   ├── SizedBox(height: 16)
    │           │   ├── Text("검색 결과가 없습니다", style: textPrimary)
    │           │   ├── SizedBox(height: 8)
    │           │   └── Text("다른 검색어를 시도해보세요", style: textTertiary)
    │           └── [결과 목록] → ListView.builder
    │               └── _buildBoxCard(box) × N
└── FloatingActionButton: SketchButton
    ├── text: "새 박스 만들기"
    ├── style: SketchButtonStyle.primary
    └── onPressed: → Routes.BOX_CREATE
```

#### 위젯 상세

**SketchInput (통합 검색)**
- label: null (플레이스홀더만 사용)
- hint: "박스 이름이나 지역을 검색하세요"
- prefixIcon: Icon(Icons.search, color: base500)
- suffixIcon: 조건부 렌더링
  - query.isNotEmpty → IconButton(Icons.clear, onPressed: clearSearch)
  - query.isEmpty → null
- controller: searchController (TextEditingController)
- onChanged: (value) → controller.keyword.value = value
- autofocus: false
- textInputAction: TextInputAction.search
- 반응형 상태: `.obs` keyword 변수로 변경 감지

**Empty State (검색어 없음)**
- Center 정렬
- Column:
  - Icon(Icons.search, size: 64, color: SketchDesignTokens.base300)
  - SizedBox(height: 16)
  - Text("박스 이름이나 지역을 검색해보세요")
    - fontSize: 16 (fontSizeBase)
    - color: SketchDesignTokens.base500 (textTertiary)
    - fontWeight: regular

**Empty State (결과 없음)**
- Center 정렬
- Column:
  - Icon(Icons.location_off, size: 64, color: SketchDesignTokens.base300)
  - SizedBox(height: 16)
  - Text("검색 결과가 없습니다")
    - fontSize: 18 (fontSizeLg)
    - color: SketchDesignTokens.black (textPrimary)
    - fontWeight: medium
  - SizedBox(height: 8)
  - Text("다른 검색어를 시도해보세요")
    - fontSize: 14 (fontSizeSm)
    - color: SketchDesignTokens.base700 (textTertiary)

**SketchCard (박스 카드)**
- elevation: 1 (가벼운 그림자)
- margin: EdgeInsets.only(bottom: 12)
- padding: 내부 자동 (SketchCard 기본값)
- body: Column
  - Row (제목 + 배지)
    - Expanded → Text(box.name)
      - fontSize: 18 (fontSizeLg)
      - fontWeight: bold
    - if (box.memberCount > 10) → SketchChip
      - label: "인기"
      - icon: Icon(Icons.local_fire_department, size: 14)
      - selected: false
  - SizedBox(height: 4)
  - Row (지역 + 아이콘)
    - Icon(Icons.location_on, size: 16, color: base500)
    - SizedBox(width: 4)
    - Text(box.region)
      - fontSize: 14 (fontSizeSm)
      - color: SketchDesignTokens.base700
  - if (box.description != null) ...
    - SizedBox(height: 8)
    - Text(box.description)
      - fontSize: 14 (fontSizeSm)
      - color: SketchDesignTokens.base900
      - maxLines: 2
      - overflow: TextOverflow.ellipsis
  - SizedBox(height: 8)
  - Row (멤버 수 + 가입 버튼 사이 간격 조정)
    - if (box.memberCount != null) ...
      - Icon(Icons.group, size: 14, color: base500)
      - SizedBox(width: 4)
      - Text("${box.memberCount}명")
        - fontSize: 12 (fontSizeXs)
        - color: SketchDesignTokens.base500
- footer: Align
  - alignment: Alignment.centerRight
  - child: SketchButton
    - text: "가입"
    - style: SketchButtonStyle.outline
    - size: SketchButtonSize.small
    - onPressed: () → controller.joinBox(box.id)

**FloatingActionButton (새 박스 만들기)**
- SketchButton 사용
  - text: "새 박스 만들기"
  - style: SketchButtonStyle.primary
  - size: SketchButtonSize.medium
  - icon: Icon(Icons.add, size: 20)
  - onPressed: () → Get.toNamed(Routes.BOX_CREATE)

### Screen 2: 박스 생성 (BoxCreateView) — 현행 유지

#### 레이아웃 계층
```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("새 박스 만들기")
└── Body: SafeArea
    ├── Padding(16)
    │   ├── Column
    │   │   ├── Expanded → SingleChildScrollView
    │   │   │   ├── Obx(() => SketchInput) — 이름
    │   │   │   │   ├── label: "박스 이름"
    │   │   │   │   ├── hint: "크로스핏 박스 이름"
    │   │   │   │   ├── controller: nameController
    │   │   │   │   └── errorText: nameError.value
    │   │   │   │
    │   │   │   ├── SizedBox(height: 16)
    │   │   │   │
    │   │   │   ├── Obx(() => SketchInput) — 지역
    │   │   │   │   ├── label: "지역"
    │   │   │   │   ├── hint: "서울 강남구"
    │   │   │   │   ├── controller: regionController
    │   │   │   │   └── errorText: regionError.value
    │   │   │   │
    │   │   │   ├── SizedBox(height: 16)
    │   │   │   │
    │   │   │   └── SketchInput — 설명 (선택)
    │   │   │       ├── label: "설명 (선택)"
    │   │   │       ├── hint: "박스에 대한 간단한 설명"
    │   │   │       ├── controller: descriptionController
    │   │   │       ├── maxLines: 3
    │   │   │       └── errorText: null
    │   │   │
    │   │   ├── SizedBox(height: 16)
    │   │   │
    │   │   └── Obx(() => SizedBox) — 버튼
    │   │       └── SketchButton
    │   │           ├── text: "박스 생성"
    │   │           ├── style: SketchButtonStyle.primary
    │   │           ├── size: SketchButtonSize.large
    │   │           ├── onPressed: canSubmit && !isLoading ? create : null
    │   │           └── isLoading: isLoading.value
```

#### 위젯 상세

**SketchInput (박스 이름)**
- label: "박스 이름"
- hint: "크로스핏 박스 이름"
- controller: nameController
- errorText: nameError.value (반응형 — Obx로 감싸기)
- maxLength: 50
- textInputAction: TextInputAction.next
- keyboardType: TextInputType.text

**SketchInput (지역)**
- label: "지역"
- hint: "서울 강남구"
- controller: regionController
- errorText: regionError.value (반응형)
- maxLength: 100
- textInputAction: TextInputAction.next
- keyboardType: TextInputType.text

**SketchInput (설명)**
- label: "설명 (선택)"
- hint: "박스에 대한 간단한 설명"
- controller: descriptionController
- errorText: null (선택 필드)
- maxLines: 3
- maxLength: 1000
- textInputAction: TextInputAction.done
- keyboardType: TextInputType.multiline

**SketchButton (생성)**
- text: "박스 생성"
- style: SketchButtonStyle.primary
- size: SketchButtonSize.large
- width: double.infinity (전체 너비)
- onPressed: 조건부
  - canSubmit.value && !isLoading.value → controller.create
  - else → null (비활성화)
- isLoading: isLoading.value (반응형)
- 비활성화 시: opacity 0.4, 터치 불가

## 색상 팔레트 (Frame0 Sketch Style)

### Primary Colors
- **accentPrimary**: `Color(0xFFDF7D5F)` — 주요 액션 버튼, 강조
- **accentLight**: `Color(0xFFF19E7E)` — 호버 상태, 밝은 강조
- **accentDark**: `Color(0xFFC86947)` — 눌림 상태, 어두운 강조

### Grayscale
- **white**: `Color(0xFFFFFFFF)` — 배경, 카드 배경
- **base100**: `Color(0xFFF7F7F7)` — Surface 배경
- **base300**: `Color(0xFFDCDCDC)` — 테두리, 구분선
- **base500**: `Color(0xFF8E8E8E)` — 아이콘, 플레이스홀더
- **base700**: `Color(0xFF5E5E5E)` — 보조 텍스트
- **base900**: `Color(0xFF343434)` — 본문 텍스트
- **black**: `Color(0xFF000000)` — 제목, 강조 텍스트

### Semantic Colors
- **success**: `Color(0xFF4CAF50)` — 성공 메시지
- **warning**: `Color(0xFFFFC107)` — 경고 메시지
- **error**: `Color(0xFFF44336)` — 에러 상태, 에러 메시지
- **info**: `Color(0xFF2196F3)` — 정보 표시

### Opacity
- **opacityDisabled**: 0.4 — 비활성화 상태
- **opacitySubtle**: 0.6 — 미세한 강조
- **opacitySketch**: 0.8 — 스케치 효과 레이어

## 타이포그래피 (SketchDesignTokens)

### Font Sizes
- **fontSizeXs**: 12px — 보조 정보 (멤버 수)
- **fontSizeSm**: 14px — 보조 텍스트 (지역, 설명)
- **fontSizeBase**: 16px — 본문, 입력 필드
- **fontSizeLg**: 18px — 카드 제목
- **fontSizeXl**: 20px — 화면 제목
- **fontSize2Xl**: 24px — AppBar 제목

### Font Weights
- **light**: 300 — 사용 안 함
- **regular**: 400 — 본문, 입력 필드
- **medium**: 500 — 보조 제목
- **bold**: 700 — 카드 제목, 강조

### Line Heights
- **tight**: 1.25 — 제목
- **normal**: 1.5 — 본문 (기본값)
- **relaxed**: 1.75 — 긴 텍스트

### 사용 패턴
- **AppBar Title**: fontSize2Xl (24px) + medium (500)
- **Card Title**: fontSizeLg (18px) + bold (700)
- **Body Text**: fontSizeBase (16px) + regular (400)
- **Caption**: fontSizeXs (12px) + regular (400)
- **Input Label**: fontSizeSm (14px) + medium (500)
- **Input Text**: fontSizeBase (16px) + regular (400)
- **Button Text**: fontSizeBase (16px) + regular (400)

## 스페이싱 시스템 (8dp 그리드)

### Padding/Margin
- **spacingXs**: 4dp — 아이콘-텍스트 간격
- **spacingSm**: 8dp — 작은 요소 간격
- **spacingMd**: 12dp — 카드 내부 요소 간격
- **spacingLg**: 16dp — 화면 패딩, 위젯 간 기본 간격
- **spacingXl**: 24dp — 섹션 구분
- **spacing2Xl**: 32dp — 큰 섹션 구분
- **spacing3Xl**: 48dp — 특별한 강조
- **spacing4Xl**: 64dp — Empty state 아이콘-텍스트

### 컴포넌트별 스페이싱

**화면 패딩**
- 좌우: 16dp (spacingLg)
- 상하: SafeArea 자동 처리

**SketchInput**
- label-input 간격: 8dp (spacingSm)
- input-error 간격: 4dp (spacingXs)
- 입력 필드 간격: 16dp (spacingLg)

**SketchCard**
- 카드 간 간격: 12dp (spacingMd) — margin.only(bottom: 12)
- 카드 내부 패딩: 16dp (spacingLg) — 자동
- body 내부 요소 간격: 4-8dp (spacingXs-spacingSm)

**Empty State**
- 아이콘-텍스트: 16dp (spacingLg)
- 제목-부제목: 8dp (spacingSm)

**버튼**
- 내부 패딩:
  - small: 8dp 상하, 16dp 좌우
  - medium: 12dp 상하, 24dp 좌우
  - large: 16dp 상하, 32dp 좌우

## Border Radius (SketchDesignTokens)

- **radiusSm**: 2dp — 작은 칩, 배지
- **radiusMd**: 4dp — 입력 필드
- **radiusLg**: 8dp — 카드
- **radiusXl**: 12dp — 큰 카드, 모달
- **radiusPill**: 9999dp — 버튼 (완전 라운드)

### 컴포넌트별 적용
- **SketchButton**: radiusPill (9999dp)
- **SketchCard**: radiusLg (8dp)
- **SketchInput**: radiusMd (4dp)
- **SketchChip**: radiusPill (9999dp)

## Stroke (손그림 효과)

### Stroke Widths
- **strokeThin**: 1.0px — 아이콘, 텍스트 밑줄
- **strokeStandard**: 2.0px — 대부분의 UI 요소 (기본값)
- **strokeBold**: 3.0px — 강조, 선택 상태
- **strokeThick**: 4.0px — 포커스 표시, 타이틀

### Roughness (거칠기)
- **default**: 0.8 — SketchContainer, SketchCard, SketchButton 기본값
- **smooth**: 0.5 — 입력 필드 (SketchInput)
- **rough**: 1.0 — 강조 요소, 선택 상태
- **veryRough**: 1.5 — 특별한 강조 (사용 드묾)

### 적용 패턴
- **SketchCard**: strokeStandard (2px), roughness 0.8
- **SketchInput**: strokeStandard (2px), roughness 0.5 (부드럽게)
- **SketchButton**: strokeStandard (2px), roughness 0.8

## Elevation (그림자)

### Levels
- **Level 0**: 없음 — 배경, 평면 요소
- **Level 1**: sm — SketchCard (기본)
  - offsetY: 1, blur: 2, color: rgba(0, 0, 0, 0.1)
- **Level 2**: md — SketchCard (hover), SketchButton
  - offsetY: 2, blur: 4, color: rgba(0, 0, 0, 0.15)
- **Level 3**: lg — SketchModal, 드롭다운
  - offsetY: 4, blur: 8, color: rgba(0, 0, 0, 0.2)
- **Level 4**: xl — 최상위 모달
  - offsetY: 8, blur: 16, color: rgba(0, 0, 0, 0.25)

### 컴포넌트별 적용
- **SketchCard**: elevation 1 (sm)
- **FloatingActionButton**: elevation 2 (md)
- **SketchModal**: elevation 3 (lg)

## 인터랙션 상태

### SketchButton 상태
- **Default**: accentPrimary (primary) / transparent (outline)
- **Hover**: accentLight (밝아짐)
- **Pressed**: accentDark (어두워짐) + elevation 증가
- **Disabled**: opacity 0.4, onPressed: null
- **Loading**: CircularProgressIndicator (16x16) + 텍스트

### SketchInput 상태
- **Default**: border base300, strokeStandard (2px)
- **Focused**: border accentPrimary, strokeBold (3px)
- **Error**: border error (#F44336), strokeBold (3px)
  - errorText 하단 표시 (fontSize: fontSizeXs, color: error)
- **Disabled**: opacity 0.4, readOnly: true

### SketchCard 상태
- **Default**: elevation 1, border base300
- **Hover**: elevation 2 (터치 디바이스에서는 미적용)
- **Pressed**: elevation 1, scale 0.98 (짧은 애니메이션)

### 터치 피드백
- **InkWell 사용**: SketchCard.onTap, SketchButton.onPressed
- **Splash Color**: accentPrimary.withOpacity(0.1)
- **Highlight Color**: accentPrimary.withOpacity(0.05)
- **Ripple Duration**: 250ms (normal)

## 애니메이션

### 화면 전환
- **Route Transition**: Cupertino 슬라이드 (iOS 스타일)
- **Duration**: 300ms
- **Curve**: Curves.easeInOut
- **적용**: GetX transition 파라미터

### 상태 변경
- **Fade In/Out**: Duration: 200ms, Curve: Curves.easeIn
- **Scale**: Duration: 150ms, Curve: Curves.easeOut
- **Slide**: Duration: 250ms, Curve: Curves.easeInOut

### 로딩 상태
- **CircularProgressIndicator**: Material 기본 스피너
- **Duration**: 무한 반복
- **Color**: accentPrimary (SketchButton 내부)
- **Size**: 16x16 (버튼 내), 24x24 (전체 화면)

### 검색 결과 애니메이션
- **List Entry**: Fade + Slide (위에서 아래로)
- **Stagger**: 50ms 간격 (첫 5개만)
- **Empty State**: Fade In 300ms

## 반응형 레이아웃

### Breakpoints
- **Mobile Portrait**: width < 600dp (주요 타겟)
- **Mobile Landscape**: width ≥ 600dp && width < 1024dp
- **Tablet**: width ≥ 1024dp (미지원)

### 적응형 레이아웃 전략
- **세로 모드**: 1열 레이아웃 (기본)
- **가로 모드**: 1열 유지 (스크롤 가능)
- **큰 화면**: maxWidth 600dp 제한 (중앙 정렬)

### 터치 영역
- **최소 크기**: 48x48dp (Material Design 가이드라인)
- **SketchButton**: 자동 충족 (small: 40dp, medium: 48dp, large: 56dp)
- **SketchIconButton**: 48x48dp (기본)
- **카드 전체**: 터치 가능 영역 (onTap 있을 경우)

## 접근성 (Accessibility)

### 색상 대비
- **텍스트 대 배경**: black/base900 on white (최소 4.5:1 충족)
- **에러 텍스트**: error (#F44336) on white (4.52:1)
- **아이콘 대 배경**: base500 on white (3.54:1) — 보조 정보이므로 허용

### 의미 전달
- **색상만으로 의미 전달 금지**:
  - 에러: error 색상 + errorText + 아이콘
  - 성공: 스낵바 텍스트 + 아이콘
  - 로딩: CircularProgressIndicator + 버튼 텍스트 유지
- **빈 상태**: 아이콘 + 텍스트 조합

### 스크린 리더 지원
- **Semantics 레이블**:
  - SketchButton: 자동 (text 속성 활용)
  - SketchInput: label 속성 활용
  - 아이콘 버튼: tooltip 필수 (예: "검색어 지우기")
  - Empty State: "검색 결과 없음. 다른 검색어를 시도해보세요"

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)
- **SketchInput**: 모든 입력 필드 (이름, 지역, 설명, 검색)
- **SketchButton**: 모든 버튼 (가입, 생성, FAB)
- **SketchCard**: 박스 카드
- **SketchChip**: 인기 박스 배지 (memberCount > 10)
- **SketchModal**: 박스 변경 확인 (Get.defaultDialog 대체 권장)

### 새로운 컴포넌트 필요 여부
**없음** — 기존 Design System 컴포넌트로 모든 UI 구현 가능

### 컴포넌트 커스터마이징
- **SketchCard**: elevation 파라미터로 그림자 조정
- **SketchButton**: style, size 파라미터로 변형 (primary, outline, small, medium, large)
- **SketchInput**: prefixIcon, suffixIcon으로 검색/지우기 아이콘 추가

## GetX 반응형 상태 (.obs)

### BoxSearchController (개선 필요)
| 변수 | 타입 | 용도 | 변경 사항 |
|------|------|------|---------|
| `isLoading` | RxBool | 검색 중 로딩 상태 | 유지 |
| `searchResults` | RxList<BoxModel> | 검색 결과 목록 | 유지 |
| `currentBox` | Rxn<BoxModel> | 현재 소속 박스 | 유지 |
| `nameQuery` | RxString | 이름 검색어 | **삭제** |
| `regionQuery` | RxString | 지역 검색어 | **삭제** |
| `keyword` | RxString | 통합 검색 키워드 | **추가** |

### BoxCreateController
| 변수 | 타입 | 용도 | 변경 사항 |
|------|------|------|---------|
| `isLoading` | RxBool | 생성 중 로딩 상태 | 유지 |
| `nameError` | RxnString | 이름 유효성 에러 | 유지 |
| `regionError` | RxnString | 지역 유효성 에러 | 유지 |
| `canSubmit` | RxBool | 제출 가능 여부 | 유지 |

### Obx 사용 패턴
```dart
// 검색 결과 영역
Obx(() {
  if (controller.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }
  if (controller.keyword.value.isEmpty) {
    return _buildEmptySearch();
  }
  if (controller.searchResults.isEmpty) {
    return _buildNoResults();
  }
  return ListView.builder(...);
})

// 입력 필드 에러 상태
Obx(() => SketchInput(
  label: '박스 이름',
  errorText: controller.nameError.value,
))

// 버튼 활성화 상태
Obx(() => SketchButton(
  text: '박스 생성',
  onPressed: controller.canSubmit.value && !controller.isLoading.value
      ? controller.create
      : null,
  isLoading: controller.isLoading.value,
))
```

## 에러 처리 UI

### 스낵바 (Get.snackbar)
- **성공**: title: "가입 완료", message: "박스에 가입되었습니다"
  - duration: 2초
  - backgroundColor: success.withOpacity(0.1)
  - colorText: success
- **에러**: title: "오류", message: e.message
  - duration: 3초
  - backgroundColor: error.withOpacity(0.1)
  - colorText: error
- **네트워크**: title: "네트워크 오류", message: "연결을 확인해주세요"

### 모달 (Get.defaultDialog 또는 SketchModal)
- **박스 변경 확인**:
  - title: "박스 변경"
  - middleText: '현재 "{currentBox.value?.name}"에서 탈퇴하고 새 박스에 가입합니다. 계속하시겠습니까?'
  - textConfirm: "변경" (accentPrimary)
  - textCancel: "취소" (base500)
  - barrierDismissible: true

### 인라인 에러 (SketchInput.errorText)
- **이름 검증**:
  - 빈 값: null (에러 표시 안 함)
  - 2자 미만: "박스 이름은 2자 이상이어야 합니다"
  - 50자 초과: "박스 이름은 50자 이하여야 합니다"
- **지역 검증**:
  - 빈 값: null
  - 2자 미만: "지역은 2자 이상이어야 합니다"
  - 100자 초과: "지역은 100자 이하여야 합니다"

## 성능 최적화

### const 생성자 사용
- **정적 위젯**: const Text(), const Icon(), const SizedBox()
- **조건부 제외**: Obx() 내부는 const 불가
- **목록 아이템**: const 불가 (데이터 바인딩)

### 리빌드 최소화
- **Obx 범위 최소화**: 변경되는 위젯만 감싸기
- **const 분리**: Obx 외부에 정적 위젯 배치
- **컨트롤러 접근**: `controller.variable.value` (리빌드 트리거)

### Debounce 적용
- **검색**: 300ms debounce (onInit에서 설정)
  ```dart
  debounce(keyword, (_) => search(), time: const Duration(milliseconds: 300));
  ```
- **입력 검증**: TextEditingController listener (실시간)

### ListView 최적화
- **itemExtent**: 설정 안 함 (카드 높이 가변)
- **cacheExtent**: 기본값 (250.0) 유지
- **physics**: BouncingScrollPhysics() (iOS 스타일)

## 참고 자료
- **Frame0.app**: https://frame0.app (디자인 영감)
- **Design Tokens**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/mobile/design-tokens.json`
- **Design System 가이드**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/mobile/design_system.md`
- **GetX Best Practices**: `/Users/lms/dev/repository/feature-wowa-box/.claude/guide/mobile/getx_best_practices.md`
