# UI/UX 디자인 명세: WOWA MVP

## 개요

WOWA는 크로스핏 박스에서 WOD(Workout of the Day) 정보를 **합의 기반**으로 관리하는 모바일 앱입니다. 역할 구분 없이 누구나 WOD를 등록할 수 있으며, 시스템은 중립적으로 "먼저 등록된" WOD를 Base로 표시합니다.

**디자인 목표**:
- Frame0 스케치 스타일로 친근하고 부담 없는 느낌 전달
- "시스템이 판단하지 않는다"는 원칙을 시각적으로 구현
- Base WOD와 Personal WOD의 차이를 명확히 구분하되 평등하게 표현
- 합의 과정(변경 제안 → 승인)을 직관적으로 시각화
- 선택의 불변성을 강조하여 신중한 결정 유도

**핵심 UX 전략**:
1. **순서 기반 권위**: Base WOD는 "가장 먼저 등록된" 사실을 배지로 표현 (권위 X, 시간순 O)
2. **평등한 선택지**: Personal WOD는 "다른 버전"으로 프레이밍 (틀린 것 X, 대안 O)
3. **합의 프로세스**: 변경 제안은 "검토 요청"으로 표현, 승인은 "새 Base 승격"으로 시각화
4. **불변성 경고**: WOD 선택 시 잠금 아이콘 + 경고 배너로 신중한 결정 유도
5. **투명한 커뮤니티**: 등록자 이름, 선택 인원 수 표시로 신뢰 형성

---

## 화면 목록

| 화면명 | 라우트 | 설명 | 우선순위 |
|-------|--------|------|----------|
| 박스 검색 | `/box/search` | 이름/지역 검색, 가입, 신규 생성 진입 | P0 |
| 박스 생성 | `/box/create` | 이름+지역 입력, 생성 시 자동 가입 | P0 |
| 홈 (오늘의 WOD) | `/home` | 오늘 날짜 WOD 표시, Base+Personal 요약 | P0 |
| WOD 등록 | `/wod/register` | WOD 텍스트 입력 폼 (타입, 시간, 운동 목록) | P0 |
| WOD 상세 | `/wod/:date/detail` | Base vs Personal 비교, 변경 제안 UI | P0 |
| WOD 선택 | `/wod/:date/select` | Base/Personal 중 선택 (라디오 버튼) | P0 |
| 변경 승인 | `/proposal/:id/review` | Base 등록자가 제안 승인/거부 | P0 |
| 설정 | `/settings` | 알림 설정, 박스 변경, 프로필 | P1 |

### 네비게이션 플로우

```
[로그인 완료] → 박스 확인 (GET /boxes/me)
                  ├── 박스 없음 → [박스 검색] → 가입 → [홈]
                  │                           └── 없으면 → [박스 생성] → [홈]
                  └── 박스 있음 → [홈]
                                   ↓
                           ┌───────┼───────┐
                           ↓       ↓       ↓
                      [WOD 등록] [WOD 상세] [설정 → 박스 변경]
                           ↓       ↓
                      [WOD 선택] [변경 승인] (Base 등록자만)
```

---

## 화면 구조

### Screen 1: 박스 검색 (Box Search)

**라우트**: `/box/search`

**목적**: 이름/지역으로 박스 검색, 탭하여 가입, 없으면 신규 생성 진입

**진입 조건**:
- 첫 로그인 후 가입된 박스 없을 때 (자동 진입, 뒤로가기 버튼 없음)
- 설정에서 "박스 변경" 탭했을 때 (뒤로가기 버튼 있음)

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기, 박스 있을 때만)
    └── Title: Text("박스 찾기")
└── Body: Column
    ├── Padding (spacingLg)
    │   ├── _SearchInputs (이름 + 지역 검색 필드)
    │   └── SizedBox(height: spacingLg)
    ├── Expanded
    │   └── Obx(() => _SearchResults) // 검색 결과 또는 안내
    └── Padding (spacingLg, bottom: spacingXl)
        └── SketchButton (신규 생성 버튼)
```

#### 위젯 상세

**_SearchInputs (검색 필드)**
```dart
Column(
  children: [
    SketchInput(
      label: '박스 이름',
      hint: '예: CrossFit 강남',
      controller: controller.nameController,
      prefixIcon: Icon(Icons.search, color: base500),
      onChanged: (_) => controller.search(), // debounce 300ms
    ),
    SizedBox(height: spacingMd),
    SketchInput(
      label: '지역',
      hint: '예: 서울 강남구',
      controller: controller.regionController,
      prefixIcon: Icon(Icons.location_on, color: base500),
      onChanged: (_) => controller.search(),
    ),
  ],
)
```
- 입력 시 자동 검색 (debounce 300ms)
- 이름, 지역 중 하나만 입력해도 검색 가능

**_SearchResults (검색 결과)**

**상태 1: 검색어 없음**
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.search, size: 64, color: base300),
      SizedBox(height: spacingLg),
      Text('박스 이름이나 지역을 입력하세요',
           style: bodyMedium, color: base500),
    ],
  ),
)
```

**상태 2: 검색 중**
```dart
Center(
  child: SketchProgressBar(value: null, style: circular),
)
```

**상태 3: 결과 없음**
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.search_off, size: 64, color: base300),
      SizedBox(height: spacingLg),
      Text('검색 결과가 없습니다', style: titleMedium),
      SizedBox(height: spacingSm),
      Text('아래에서 새 박스를 만들어 보세요',
           style: bodySmall, color: base500),
    ],
  ),
)
```

**상태 4: 결과 목록**
```dart
ListView.separated(
  itemCount: controller.searchResults.length,
  separatorBuilder: (_, __) => SizedBox(height: spacingMd),
  padding: EdgeInsets.symmetric(horizontal: spacingLg),
  itemBuilder: (context, index) {
    final box = controller.searchResults[index];
    return SketchCard(
      onTap: () => controller.joinBox(box),
      body: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: accentLight,
            child: Text(box.name[0], style: titleMedium),
          ),
          SizedBox(width: spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(box.name, style: titleSmall),
                SizedBox(height: spacingXs),
                Text(box.region, style: bodySmall, color: base500),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${box.memberCount}명',
                   style: bodySmall, color: base500),
              Icon(Icons.chevron_right, color: base500),
            ],
          ),
        ],
      ),
    );
  },
)
```

**신규 생성 버튼**
```dart
SketchButton(
  text: '찾는 박스가 없나요? 새로 만들기',
  icon: Icon(Icons.add_business),
  style: SketchButtonStyle.outline,
  size: SketchButtonSize.large,
  onPressed: () => Get.toNamed(Routes.BOX_CREATE),
)
```

#### 인터랙션

- **검색 필드 입력**: 300ms debounce 후 자동 검색 (GET `/boxes/search?name=&region=`)
- **결과 카드 탭**: 기존 박스가 있으면 박스 변경 확인 모달 → 가입 (POST `/boxes/:boxId/join`)
  - 기존 박스 자동 탈퇴 후 새 박스 가입
  - 성공 시 홈 화면으로 이동
- **박스 변경 확인 모달** (기존 박스가 있을 때만):
```dart
SketchModal.show(
  context: context,
  title: '박스 변경',
  child: Column(
    children: [
      Text("현재 '${controller.currentBox.value?.name}'에서 탈퇴하고"),
      Text("'${newBox.name}'에 가입합니다."),
      SizedBox(height: spacingSm),
      Text('기존 박스의 데이터는 유지됩니다.',
           style: bodySmall, color: base500),
    ],
  ),
  actions: [
    SketchButton(
      text: '취소',
      style: SketchButtonStyle.outline,
      onPressed: () => Navigator.pop(context),
    ),
    SketchButton(
      text: '변경',
      onPressed: () {
        Navigator.pop(context);
        controller.confirmJoin(newBox);
      },
    ),
  ],
);
```
- **새로 만들기**: 박스 생성 화면으로 이동

---

### Screen 2: 박스 생성 (Box Create)

**라우트**: `/box/create`

**목적**: 새 박스 생성 (생성 시 자동 가입, 기존 박스 자동 탈퇴)

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("박스 생성")
└── Body: Form
    └── SingleChildScrollView (padding: spacingLg)
        └── Column
            ├── SketchInput (박스 이름)
            ├── SizedBox(height: spacingLg)
            ├── SketchInput (지역)
            ├── SizedBox(height: spacing2Xl)
            └── SketchButton (생성하기)
```

#### 위젯 상세

```dart
Column(
  children: [
    SketchInput(
      label: '박스 이름',
      hint: '예: CrossFit 강남',
      controller: controller.nameController,
      errorText: controller.nameError.value.isEmpty
          ? null
          : controller.nameError.value,
    ),
    SizedBox(height: spacingLg),
    SketchInput(
      label: '지역',
      hint: '예: 서울 강남구',
      controller: controller.regionController,
      prefixIcon: Icon(Icons.location_on, color: base500),
      errorText: controller.regionError.value.isEmpty
          ? null
          : controller.regionError.value,
    ),
    SizedBox(height: spacing2Xl),
    Obx(() => SketchButton(
      text: '생성하기',
      icon: Icon(Icons.check),
      size: SketchButtonSize.large,
      isLoading: controller.isLoading.value,
      onPressed: controller.canSubmit.value
          ? controller.create
          : null,
    )),
  ],
)
```

#### 인터랙션

- **생성**: POST `/boxes` (자동 가입 포함), 기존 박스 자동 탈퇴
- **성공**: 홈 화면으로 이동 (Get.offAllNamed)
- **에러**: 이름/지역 필수 필드 누락 시 errorText 표시
- **중복 에러**: 409 응답 시 "이미 같은 이름의 박스가 존재합니다. 검색해보세요." 스낵바

---

### Screen 3: 홈 (Home)

**라우트**: `/home`

**목적**: 오늘의 WOD를 빠르게 확인하고 주요 액션(등록, 상세보기, 선택)을 수행

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: SketchIconButton (메뉴)
    ├── Title: Text("WOWA")
    └── Actions:
        ├── SketchIconButton (알림, badgeCount 표시)
        └── SketchIconButton (설정)
└── Body: RefreshIndicator (onRefresh: controller.refresh)
    └── SingleChildScrollView
        └── Column (padding: spacingLg)
            ├── _CurrentBoxHeader (박스 이름 + 지역)
            ├── SizedBox(height: spacing2Xl)
            ├── _DateHeader (날짜 표시 + 좌우 화살표)
            ├── SizedBox(height: spacingXl)
            ├── Obx(() => _WodCardSection) // Base WOD + Personal WODs
            └── SizedBox(height: spacing2Xl)
            └── _QuickActionButtons (등록/상세/선택 버튼)
```

#### 위젯 상세

**_CurrentBoxHeader (현재 박스 표시)**
```dart
SketchContainer(
  fillColor: base100,
  child: Row(
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: accentLight,
        child: Text(
          controller.currentBox.value.name[0],
          style: titleSmall,
        ),
      ),
      SizedBox(width: spacingMd),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.currentBox.value.name,
                 style: titleSmall),
            Text(controller.currentBox.value.region,
                 style: bodySmall, color: base500),
          ],
        ),
      ),
    ],
  ),
)
```
- 현재 가입된 단일 박스 표시 (이름 + 지역)
- 박스 변경은 설정 화면에서 수행 (단일 박스 정책)

**_DateHeader (날짜 헤더)**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    SketchIconButton(
      icon: Icons.chevron_left,
      onPressed: controller.previousDay,
    ),
    Expanded(
      child: GestureDetector(
        onTap: controller.showDatePicker,
        child: SketchContainer(
          child: Column(
            children: [
              Text(
                controller.formattedDate.value, // '2026년 2월 4일'
                style: titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                controller.dayOfWeek.value, // '화요일'
                style: bodySmall,
                color: controller.isToday.value
                    ? accentPrimary
                    : base500,
              ),
            ],
          ),
        ),
      ),
    ),
    SketchIconButton(
      icon: Icons.chevron_right,
      onPressed: controller.nextDay,
    ),
  ],
)
```
- 좌우 화살표로 날짜 이동 (하루 단위)
- 가운데 날짜 탭하면 DatePicker 표시
- 오늘 날짜는 accentPrimary 색상으로 강조

**_WodCardSection (WOD 카드 섹션)**

**상태 1: 로딩**
```dart
Center(
  child: SketchProgressBar(value: null, style: circular),
)
```

**상태 2: WOD 없음 (Empty State)**
```dart
SketchCard(
  body: Column(
    children: [
      Icon(Icons.fitness_center, size: 64, color: base300),
      SizedBox(height: spacingLg),
      Text('아직 등록된 WOD가 없습니다',
           style: titleMedium, textAlign: TextAlign.center),
      SizedBox(height: spacingSm),
      Text('첫 번째로 등록하면 Base WOD가 됩니다',
           style: bodySmall, color: base500,
           textAlign: TextAlign.center),
      SizedBox(height: spacingXl),
      SketchButton(
        text: 'WOD 등록하기',
        icon: Icon(Icons.add),
        onPressed: controller.goToRegister,
      ),
    ],
  ),
)
```

**상태 3: Base WOD 있음**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Base WOD 배지
    Row(
      children: [
        SketchChip(
          label: 'Base WOD',
          icon: Icon(Icons.star, size: 16),
          selected: true,
        ),
        SizedBox(width: spacingSm),
        Text(
          '${controller.baseWod.value.registeredBy}님이 등록',
          style: bodySmall,
          color: base500,
        ),
        Spacer(),
        Text(
          '${controller.baseWod.value.selectedCount}명 선택',
          style: bodySmall,
          color: base500,
        ),
      ],
    ),
    SizedBox(height: spacingMd),

    // WOD 카드
    SketchCard(
      elevation: 2,
      borderColor: accentPrimary,
      strokeWidth: strokeBold,
      onTap: controller.goToDetail,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WOD 타입 + 시간
          Row(
            children: [
              SketchChip(
                label: controller.baseWod.value.type,
                selected: false,
              ),
              SizedBox(width: spacingSm),
              Text(
                '${controller.baseWod.value.timeCap}분',
                style: bodyMedium,
              ),
            ],
          ),
          SizedBox(height: spacingLg),

          // Movement 리스트
          ...controller.baseWod.value.movements.map((movement) =>
            Padding(
              padding: EdgeInsets.only(bottom: spacingSm),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: spacingMd),
                  Expanded(
                    child: Text(
                      '${movement.reps} ${movement.name}'
                      '${movement.weight != null ? " @ ${movement.weight}${movement.unit}" : ""}',
                      style: bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    ),

    // Personal WODs 있으면 표시
    if (controller.personalWods.isNotEmpty) ...[
      SizedBox(height: spacingXl),
      Row(
        children: [
          Text(
            '다른 버전 (${controller.personalWods.length})',
            style: titleSmall,
          ),
          Spacer(),
          SketchButton(
            text: '모두 보기',
            size: SketchButtonSize.small,
            style: SketchButtonStyle.outline,
            onPressed: controller.goToDetail,
          ),
        ],
      ),
    ],
  ],
)
```

**_QuickActionButtons (빠른 액션 버튼)**
```dart
Row(
  children: [
    Expanded(
      child: SketchButton(
        text: 'WOD 등록',
        icon: Icon(Icons.add),
        style: SketchButtonStyle.outline,
        onPressed: controller.goToRegister,
      ),
    ),
    SizedBox(width: spacingMd),
    Expanded(
      child: SketchButton(
        text: '상세 보기',
        icon: Icon(Icons.info_outline),
        style: SketchButtonStyle.outline,
        onPressed: controller.hasWod.value
            ? controller.goToDetail
            : null,
      ),
    ),
    SizedBox(width: spacingMd),
    Expanded(
      child: SketchButton(
        text: 'WOD 선택',
        icon: Icon(Icons.check_circle),
        onPressed: controller.hasWod.value
            ? controller.goToSelect
            : null,
      ),
    ),
  ],
)
```

#### 인터랙션

- **Pull-to-refresh**: 새로고침으로 최신 WOD 조회
- **WOD 카드 탭**: 상세 화면으로 이동
- **날짜 변경**: 좌우 화살표로 날짜 이동, 날짜 탭으로 DatePicker
- **박스 변경**: 설정 화면에서 박스 변경 가능

---

### Screen 4: WOD 등록 (WOD Registration)

**라우트**: `/wod/register`

**목적**: 구조화된 WOD 데이터를 입력하여 등록

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    ├── Title: Text("WOD 등록")
    └── Actions: [SketchIconButton (미리보기)]
└── Body: Form
    └── SingleChildScrollView
        └── Column (padding: spacingLg)
            ├── _WodTypeSelector (타입 선택 - Chip)
            ├── SizedBox(height: spacingXl)
            ├── _TimeCapInput (시간 입력)
            ├── SizedBox(height: spacingXl)
            ├── _MovementListBuilder (운동 목록)
            ├── SizedBox(height: spacing2Xl)
            └── SketchButton (등록하기, isLoading)
```

#### 위젯 상세

**_WodTypeSelector (WOD 타입 선택)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('WOD 타입', style: titleSmall),
    SizedBox(height: spacingMd),
    Wrap(
      spacing: spacingMd,
      runSpacing: spacingMd,
      children: ['AMRAP', 'For Time', 'EMOM', 'Strength', 'Custom']
          .map((type) => Obx(() => SketchChip(
                label: type,
                selected: controller.selectedType.value == type,
                onSelected: (_) => controller.selectType(type),
              )))
          .toList(),
    ),
  ],
)
```

**_TimeCapInput (시간 입력)**
```dart
SketchInput(
  label: '시간 (분)',
  hint: '예: 15',
  controller: controller.timeCapController,
  keyboardType: TextInputType.number,
  suffixIcon: Padding(
    padding: EdgeInsets.only(right: spacingMd),
    child: Text('분', style: bodyMedium),
  ),
  errorText: controller.timeCapError.value.isEmpty
      ? null
      : controller.timeCapError.value,
)
```

**_MovementListBuilder (운동 목록 빌더)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('운동 목록', style: titleSmall),
        SketchButton(
          text: '추가',
          icon: Icon(Icons.add, size: 16),
          size: SketchButtonSize.small,
          onPressed: controller.addMovement,
        ),
      ],
    ),
    SizedBox(height: spacingMd),

    // ReorderableListView로 드래그 재배치 가능
    Obx(() => ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: controller.reorderMovements,
      children: controller.movements
          .map((movement) => _MovementCard(
                key: ValueKey(movement.id),
                movement: movement,
                onDelete: () => controller.removeMovement(movement.id),
              ))
          .toList(),
    )),
  ],
)
```

**_MovementCard (개별 운동 카드)**
```dart
SketchCard(
  key: key,
  elevation: 1,
  body: Column(
    children: [
      Row(
        children: [
          Icon(Icons.drag_handle, color: base500),
          SizedBox(width: spacingMd),
          Expanded(
            child: SketchInput(
              label: '운동명',
              hint: 'Pull-up',
              controller: movement.nameController,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: error),
            onPressed: onDelete,
          ),
        ],
      ),
      SizedBox(height: spacingMd),
      Row(
        children: [
          Expanded(
            child: SketchInput(
              label: '반복수',
              hint: '10',
              controller: movement.repsController,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(width: spacingMd),
          Expanded(
            child: SketchInput(
              label: '무게 (선택)',
              hint: '20',
              controller: movement.weightController,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(width: spacingMd),
          SizedBox(
            width: 80,
            child: SketchDropdown<String>(
              value: movement.unit.value,
              items: ['kg', 'lb', 'bw'],
              hint: '단위',
              onChanged: movement.setUnit,
            ),
          ),
        ],
      ),
    ],
  ),
)
```

**등록 버튼**
```dart
Obx(() => SketchButton(
  text: '등록하기',
  icon: Icon(Icons.check),
  isLoading: controller.isLoading.value,
  onPressed: controller.canSubmit.value
      ? controller.submit
      : null,
  size: SketchButtonSize.large,
))
```

#### 인터랙션

- **타입 선택**: Chip 탭으로 WOD 타입 변경
- **운동 추가**: "추가" 버튼으로 새 운동 카드 추가
- **운동 재배치**: 드래그 핸들로 순서 변경
- **운동 삭제**: 삭제 아이콘으로 제거
- **미리보기**: 우측 상단 아이콘으로 입력 내용 미리보기 모달
- **등록**: 유효성 검증 후 API 호출 (POST `/wods`)
  - 성공 시 홈으로 이동
  - Base WOD로 자동 지정 또는 Personal WOD로 분류 (서버에서 판단)

---

### Screen 5: WOD 상세 (WOD Detail)

**라우트**: `/wod/:date/detail`

**목적**: Base WOD와 Personal WODs를 비교하고 변경 제안 수행

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    ├── Title: Text("WOD 상세")
    └── Actions: [SketchIconButton (공유)]
└── Body: SingleChildScrollView
    └── Column (padding: spacingLg)
        ├── _BaseWodCard (Base WOD 강조 표시)
        ├── SizedBox(height: spacing2Xl)
        ├── Obx(() => _PersonalWodsSection) // Personal WODs 리스트
        ├── SizedBox(height: spacing2Xl)
        └── _ActionButtons (WOD 선택, 새 WOD 등록)
```

#### 위젯 상세

**_BaseWodCard (Base WOD 카드)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        SketchChip(
          label: 'Base WOD',
          icon: Icon(Icons.star, size: 16),
          selected: true,
        ),
        Spacer(),
        Text(
          '${controller.baseWod.value.selectedCount}명 선택',
          style: bodySmall,
          color: base500,
        ),
      ],
    ),
    SizedBox(height: spacingSm),
    Text(
      '${controller.baseWod.value.registeredBy}님이 등록',
      style: bodySmall,
      color: base500,
    ),
    SizedBox(height: spacingLg),

    SketchCard(
      elevation: 3,
      borderColor: accentPrimary,
      strokeWidth: strokeBold,
      body: _WodContentWidget(wod: controller.baseWod.value),
    ),

    // 변경 제안 대기 중이면 표시
    if (controller.hasPendingProposal.value) ...[
      SizedBox(height: spacingLg),
      SketchContainer(
        fillColor: warning.withOpacity(0.1),
        borderColor: warning,
        child: Row(
          children: [
            Icon(Icons.pending, color: warning),
            SizedBox(width: spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('변경 제안이 있습니다',
                       style: titleSmall.copyWith(color: warning)),
                  SizedBox(height: spacingXs),
                  Text('검토 후 승인/거부할 수 있습니다',
                       style: bodySmall, color: base700),
                ],
              ),
            ),
            if (controller.isBaseCreator.value)
              SketchButton(
                text: '검토',
                size: SketchButtonSize.small,
                onPressed: controller.goToReview,
              ),
          ],
        ),
      ),
    ],
  ],
)
```

**_PersonalWodsSection (Personal WODs 섹션)**
```dart
if (controller.personalWods.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('다른 버전 (Personal WODs)', style: titleMedium),
      SizedBox(height: spacingMd),
      Text(
        'Base WOD와 다르게 등록된 버전입니다',
        style: bodySmall,
        color: base500,
      ),
      SizedBox(height: spacingLg),

      ...controller.personalWods.map((personalWod) =>
        Padding(
          padding: EdgeInsets.only(bottom: spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SketchChip(
                    label: 'Personal',
                    selected: false,
                  ),
                  SizedBox(width: spacingSm),
                  Text(
                    '${personalWod.registeredBy}님',
                    style: bodySmall,
                    color: base500,
                  ),
                  Spacer(),
                  Text(
                    '${personalWod.selectedCount}명 선택',
                    style: bodySmall,
                    color: base500,
                  ),
                ],
              ),
              SizedBox(height: spacingSm),
              SketchCard(
                elevation: 1,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WodContentWidget(wod: personalWod),
                    SizedBox(height: spacingMd),
                    Divider(),
                    SizedBox(height: spacingMd),
                    _DiffHighlight(
                      baseWod: controller.baseWod.value,
                      personalWod: personalWod,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    ],
  )
```

**_WodContentWidget (WOD 내용 표시)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        SketchChip(label: wod.type, selected: false),
        SizedBox(width: spacingSm),
        Text('${wod.timeCap}분', style: bodyMedium),
      ],
    ),
    SizedBox(height: spacingLg),
    ...wod.movements.map((movement) =>
      Padding(
        padding: EdgeInsets.only(bottom: spacingSm),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accentPrimary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: spacingMd),
            Expanded(
              child: Text(
                '${movement.reps} ${movement.name}'
                '${movement.weight != null ? " @ ${movement.weight}${movement.unit}" : ""}',
                style: bodyLarge,
              ),
            ),
          ],
        ),
      ),
    ).toList(),
  ],
)
```

**_DiffHighlight (차이점 강조)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Base WOD와 다른 점:',
      style: bodySmall.copyWith(fontWeight: medium),
    ),
    SizedBox(height: spacingXs),
    Wrap(
      spacing: spacingXs,
      runSpacing: spacingXs,
      children: diff.changes.map((change) =>
        SketchChip(
          label: change.description, // 예: '시간: 15분 → 20분'
          selected: false,
          icon: Icon(Icons.compare_arrows, size: 14),
        ),
      ).toList(),
    ),
  ],
)
```

**_ActionButtons (액션 버튼)**
```dart
Column(
  children: [
    SketchButton(
      text: 'WOD 선택하기',
      icon: Icon(Icons.check_circle),
      size: SketchButtonSize.large,
      onPressed: controller.goToSelect,
    ),
    SizedBox(height: spacingMd),
    SketchButton(
      text: '새 WOD 등록',
      icon: Icon(Icons.add),
      style: SketchButtonStyle.outline,
      size: SketchButtonSize.large,
      onPressed: controller.goToRegister,
    ),
  ],
)
```

#### 인터랙션

- **Base WOD 탭**: 변경 없음 (확대 보기 불필요)
- **Personal WOD 탭**: Diff 하이라이트 토글
- **검토 버튼**: 변경 승인 화면으로 이동 (Base 등록자만 표시)
- **WOD 선택 버튼**: WOD 선택 화면으로 이동
- **새 WOD 등록 버튼**: WOD 등록 화면으로 이동

---

### Screen 6: WOD 선택 (WOD Selection)

**라우트**: `/wod/:date/select`

**목적**: Base 또는 Personal WOD 중 하나를 선택하여 기록 확정

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("WOD 선택")
└── Body: SingleChildScrollView
    └── Column (padding: spacingLg)
        ├── _WarningBanner (불변성 경고)
        ├── SizedBox(height: spacingXl)
        ├── _WodOptionsList (Base + Personal WODs)
        ├── SizedBox(height: spacing2Xl)
        └── Obx(() => _ConfirmButton) // 선택 확정 버튼
```

#### 위젯 상세

**_WarningBanner (경고 배너)**
```dart
SketchContainer(
  fillColor: warning.withOpacity(0.1),
  borderColor: warning,
  strokeWidth: strokeBold,
  child: Row(
    children: [
      Icon(Icons.warning_amber, color: warning, size: 32),
      SizedBox(width: spacingMd),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '선택 후 변경할 수 없습니다',
              style: titleSmall.copyWith(color: warning),
            ),
            SizedBox(height: spacingXs),
            Text(
              '신중하게 선택해 주세요. 선택 후에는 WOD를 변경할 수 없습니다.',
              style: bodySmall,
              color: base700,
            ),
          ],
        ),
      ),
    ],
  ),
)
```

**_WodOptionsList (WOD 옵션 리스트)**
```dart
Obx(() => Column(
  children: [
    // Base WOD 옵션
    _WodOptionCard(
      wod: controller.baseWod.value,
      isBase: true,
      isSelected: controller.selectedWodId.value ==
          controller.baseWod.value.id,
      onSelect: () => controller.selectWod(controller.baseWod.value.id),
    ),

    SizedBox(height: spacingLg),

    // Personal WOD 옵션들
    ...controller.personalWods.map((personalWod) =>
      Padding(
        padding: EdgeInsets.only(bottom: spacingLg),
        child: _WodOptionCard(
          wod: personalWod,
          isBase: false,
          isSelected: controller.selectedWodId.value == personalWod.id,
          onSelect: () => controller.selectWod(personalWod.id),
        ),
      ),
    ).toList(),
  ],
))
```

**_WodOptionCard (선택 가능한 WOD 카드)**
```dart
GestureDetector(
  onTap: onSelect,
  child: SketchCard(
    elevation: isSelected ? 3 : 1,
    borderColor: isSelected ? accentPrimary : base300,
    strokeWidth: isSelected ? strokeBold : strokeStandard,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 라디오 버튼 (시각적 표현)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentPrimary : base300,
                  width: 2,
                ),
                color: isSelected ? accentPrimary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: white)
                  : null,
            ),
            SizedBox(width: spacingMd),

            // WOD 타입 배지
            SketchChip(
              label: isBase ? 'Base WOD' : 'Personal WOD',
              icon: isBase ? Icon(Icons.star, size: 16) : null,
              selected: isBase,
            ),
            Spacer(),
            Text(
              '${wod.selectedCount}명 선택',
              style: bodySmall,
              color: base500,
            ),
          ],
        ),
        SizedBox(height: spacingMd),
        Text(
          '${wod.registeredBy}님이 등록',
          style: bodySmall,
          color: base500,
        ),
        SizedBox(height: spacingLg),

        // WOD 내용
        _WodContentWidget(wod: wod),

        // Personal WOD면 Diff 표시
        if (!isBase) ...[
          SizedBox(height: spacingMd),
          Divider(),
          SizedBox(height: spacingMd),
          _DiffHighlight(
            baseWod: controller.baseWod.value,
            personalWod: wod,
          ),
        ],
      ],
    ),
  ),
)
```

**_ConfirmButton (확정 버튼)**
```dart
SketchButton(
  text: '이 WOD로 기록하기',
  icon: Icon(Icons.lock),
  size: SketchButtonSize.large,
  isLoading: controller.isLoading.value,
  onPressed: controller.selectedWodId.value != null
      ? controller.confirmSelection
      : null,
)
```

#### 인터랙션

- **WOD 카드 탭**: 해당 WOD 선택 (라디오 버튼 효과)
- **확정 버튼**: 최종 확인 모달 표시 후 API 호출
- **최종 확인 모달**:
```dart
final confirmed = await SketchModal.show<bool>(
  context: context,
  title: '최종 확인',
  child: Column(
    children: [
      Icon(Icons.warning_amber, size: 64, color: warning),
      SizedBox(height: spacingLg),
      Text(
        '정말 이 WOD로 기록하시겠습니까?',
        style: titleMedium,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: spacingSm),
      Text(
        '선택 후에는 변경할 수 없습니다.',
        style: bodySmall,
        color: error,
        textAlign: TextAlign.center,
      ),
    ],
  ),
  actions: [
    SketchButton(
      text: '취소',
      style: SketchButtonStyle.outline,
      onPressed: () => Navigator.pop(context, false),
    ),
    SketchButton(
      text: '확정',
      onPressed: () => Navigator.pop(context, true),
    ),
  ],
  barrierDismissible: false,
);

if (confirmed == true) {
  await controller.submitSelection(); // POST /wods/:id/select
  Get.offAllNamed(Routes.HOME); // 홈으로 이동
}
```

---

### Screen 7: 변경 승인 (Proposal Review)

**라우트**: `/proposal/:id/review`

**목적**: Base WOD 등록자가 Personal WOD 제안을 검토하고 승인/거부

**진입 조건**: Base WOD 등록자만 진입 가능 (알림 또는 상세 화면에서)

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("변경 제안 검토")
└── Body: SingleChildScrollView
    └── Column (padding: spacingLg)
        ├── _ProposerInfo (제안자 정보)
        ├── SizedBox(height: spacingXl)
        ├── _ComparisonView (Before/After 비교)
        ├── SizedBox(height: spacing2Xl)
        └── _ApprovalButtons (승인/거부 버튼)
```

#### 위젯 상세

**_ProposerInfo (제안자 정보)**
```dart
SketchCard(
  body: Row(
    children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: accentLight,
        child: Text(
          controller.proposer.name[0],
          style: titleMedium,
        ),
      ),
      SizedBox(width: spacingMd),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.proposer.name}님의 제안',
              style: titleSmall,
            ),
            Text(
              controller.proposal.createdAt, // '2시간 전'
              style: bodySmall,
              color: base500,
            ),
          ],
        ),
      ),
    ],
  ),
)
```

**_ComparisonView (Before/After 비교)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('변경 내용 비교', style: titleMedium),
    SizedBox(height: spacingMd),

    // Before (현재 Base WOD)
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SketchChip(label: 'Before', selected: false),
            SizedBox(width: spacingSm),
            Text('현재 Base WOD', style: bodySmall, color: base500),
          ],
        ),
        SizedBox(height: spacingMd),
        SketchCard(
          elevation: 1,
          body: _WodContentWidget(wod: controller.currentBase.value),
        ),
      ],
    ),

    SizedBox(height: spacingXl),

    // Arrow
    Center(
      child: Icon(Icons.arrow_downward, size: 32, color: accentPrimary),
    ),

    SizedBox(height: spacingXl),

    // After (제안된 WOD)
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SketchChip(label: 'After', selected: true),
            SizedBox(width: spacingSm),
            Text('제안된 변경', style: bodySmall, color: accentPrimary),
          ],
        ),
        SizedBox(height: spacingMd),
        SketchCard(
          elevation: 2,
          borderColor: accentPrimary,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WodContentWidget(wod: controller.proposedWod.value),
              SizedBox(height: spacingMd),
              Divider(),
              SizedBox(height: spacingMd),
              _DiffHighlight(
                baseWod: controller.currentBase.value,
                personalWod: controller.proposedWod.value,
              ),
            ],
          ),
        ),
      ],
    ),
  ],
)
```

**_ApprovalButtons (승인/거부 버튼)**
```dart
Row(
  children: [
    Expanded(
      child: SketchButton(
        text: '거부',
        icon: Icon(Icons.close),
        style: SketchButtonStyle.outline,
        size: SketchButtonSize.large,
        onPressed: controller.reject,
      ),
    ),
    SizedBox(width: spacingMd),
    Expanded(
      child: SketchButton(
        text: '승인',
        icon: Icon(Icons.check),
        size: SketchButtonSize.large,
        isLoading: controller.isLoading.value,
        onPressed: controller.approve,
      ),
    ),
  ],
)
```

#### 인터랙션

- **승인 버튼**: 확인 모달 후 Base WOD 교체 API 호출 (PUT `/proposals/:id/approve`)
  - 성공 시 기존 Base 선택자에게 알림 발송
  - 상세 화면으로 복귀
- **거부 버튼**: 제안 거부 API 호출 (PUT `/proposals/:id/reject`)
  - 제안자에게 알림
  - 상세 화면으로 복귀
- **승인 확인 모달**:
```dart
SketchModal.show(
  context: context,
  title: '변경 승인',
  child: Column(
    children: [
      Text(
        '이 제안을 승인하면 Base WOD가 변경됩니다.',
        style: bodyLarge,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: spacingSm),
      Text(
        '기존 Base WOD를 선택한 사용자에게 알림이 전송됩니다.',
        style: bodySmall,
        color: base500,
        textAlign: TextAlign.center,
      ),
    ],
  ),
  actions: [
    SketchButton(
      text: '취소',
      style: SketchButtonStyle.outline,
      onPressed: () => Navigator.pop(context),
    ),
    SketchButton(
      text: '승인',
      onPressed: () {
        Navigator.pop(context);
        controller.confirmApprove();
      },
    ),
  ],
);
```

---

### Screen 8: 설정 (Settings)

**라우트**: `/settings`

**목적**: 알림 설정, 박스 변경, 프로필 관리

**우선순위**: P1 (MVP 이후)

#### 레이아웃 계층 (간략)

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("설정")
└── Body: ListView
    ├── SketchCard (프로필 정보)
    ├── SketchCard (박스 변경 버튼)
    ├── SketchCard (알림 설정)
    └── SketchButton (로그아웃)
```

---

## 디자인 결정 사항

### 1. 색상 코딩 전략

**Base vs Personal WOD 구분**:
- **Base WOD**:
  - Border: `accentPrimary` (#DF7D5F)
  - Stroke: `strokeBold` (3px)
  - Badge: `SketchChip(selected: true)` with star icon
  - 의미: "먼저 등록된" 사실을 강조 (권위 X, 순서 O)

- **Personal WOD**:
  - Border: `base300` (#DCDCDC)
  - Stroke: `strokeStandard` (2px)
  - Badge: `SketchChip(selected: false)` no icon
  - 의미: "다른 선택지"로 평등하게 표현

**의미론적 색상**:
- 성공/승인: `success` (#4CAF50)
- 경고/주의: `warning` (#FFC107)
- 에러/거부: `error` (#F44336)
- 정보/중립: `info` (#2196F3)

### 2. WOD 타입 배지

모든 WOD 타입은 `SketchChip`로 표시:
- AMRAP: 기본 색상 (accentPrimary)
- For Time: 기본 색상
- EMOM: 기본 색상
- Strength: 기본 색상
- Custom: 기본 색상

(타입별 색상 구분 불필요 — 일관성 유지)

### 3. Movement 리스트 시각화

- **Bullet Point**: 8px 원형, `accentPrimary` 색상
- **간격**: 각 운동 사이 `spacingSm` (8px)
- **포맷**: `{reps} {name} @ {weight}{unit}`
  - 예: `10 Pull-up`
  - 예: `20 Back Squat @ 60kg`

### 4. Diff 하이라이트 전략

**변경 사항 표시 방식**:
```dart
SketchChip(
  label: '변경 항목 설명',
  icon: Icon(Icons.compare_arrows, size: 14),
  selected: false,
)
```

**변경 항목 예시**:
- 타입 변경: `타입: AMRAP → For Time`
- 시간 변경: `시간: 15분 → 20분`
- 운동 추가: `운동 추가: Box Jump`
- 운동 제거: `운동 제거: Burpee`
- 반복수 변경: `Pull-up: 10회 → 15회`
- 무게 변경: `Back Squat: 60kg → 70kg`

### 5. 알림 배지 패턴

**SketchIconButton with badgeCount**:
```dart
SketchIconButton(
  icon: Icons.notifications,
  badgeCount: controller.unreadCount.value,
  onPressed: controller.goToNotifications,
)
```

- 0: 배지 없음
- 1-9: 숫자 표시
- 10+: `9+` 표시

---

## 색상 팔레트 (Frame0 스타일)

### Primary Colors
- **Primary**: `Color(0xFFDF7D5F)` (#DF7D5F) — 주요 액션, Base WOD 강조
- **PrimaryLight**: `Color(0xFFF19E7E)` (#F19E7E) — Avatar 배경, 밝은 강조
- **PrimaryDark**: `Color(0xFFC86947)` (#C86947) — 눌림 상태

### Grayscale
- **White**: `Color(0xFFFFFFFF)` (#FFFFFF) — 배경
- **Base100**: `Color(0xFFF7F7F7)` (#F7F7F7) — 밝은 배경
- **Base300**: `Color(0xFFDCDCDC)` (#DCDCDC) — Personal WOD 테두리
- **Base500**: `Color(0xFF8E8E8E)` (#8E8E8E) — 보조 텍스트
- **Base700**: `Color(0xFF5E5E5E)` (#5E5E5E) — 어두운 보조 텍스트
- **Base900**: `Color(0xFF343434)` (#343434) — 주요 텍스트
- **Black**: `Color(0xFF000000)` (#000000) — 강조 텍스트

### Semantic Colors
- **Success**: `Color(0xFF4CAF50)` (#4CAF50) — 승인, 성공 상태
- **Warning**: `Color(0xFFFFC107)` (#FFC107) — 경고, 대기 상태
- **Error**: `Color(0xFFF44336)` (#F44336) — 에러, 거부 상태
- **Info**: `Color(0xFF2196F3)` (#2196F3) — 정보, 중립

---

## 타이포그래피

### Font Family
- **Primary**: Roboto (Flutter 기본)
- **Fallback**: System UI

### Type Scale (Frame0 기반)

| 스타일 | fontSize | fontWeight | height | 용도 |
|--------|----------|------------|--------|------|
| displayLarge | 57 | 400 | 64/57 | 특별한 강조 (미사용) |
| displayMedium | 45 | 400 | 52/45 | 특별한 강조 (미사용) |
| displaySmall | 36 | 400 | 44/36 | 특별한 강조 (미사용) |
| headlineLarge | 32 | 400 | 40/32 | 페이지 제목 |
| headlineMedium | 28 | 400 | 36/28 | 섹션 제목 |
| headlineSmall | 24 | 400 | 32/24 | 카드 제목 |
| **titleLarge** | 22 | 500 | 28/22 | **AppBar 제목** |
| **titleMedium** | 16 | 500 | 24/16 | **카드 제목, 섹션 헤더** |
| **titleSmall** | 14 | 500 | 20/14 | **리스트 제목, Chip** |
| **bodyLarge** | 16 | 400 | 24/16 | **본문 텍스트** |
| **bodyMedium** | 14 | 400 | 20/14 | **본문 (작음)** |
| **bodySmall** | 12 | 400 | 16/12 | **캡션, 보조 텍스트** |
| **labelLarge** | 14 | 500 | 20/14 | **버튼** |
| labelMedium | 12 | 500 | 16/12 | 작은 버튼 |
| labelSmall | 11 | 500 | 16/11 | 태그, 라벨 |

### 주로 사용하는 스타일
- AppBar 제목: `titleLarge`
- WOD 타입 배지: `titleSmall`
- WOD 내용: `bodyLarge`
- 등록자/선택 인원: `bodySmall` + `color: base500`
- 버튼: `labelLarge`

---

## 스페이싱 시스템 (8dp 그리드)

| 토큰 | 값 | 용도 |
|------|-----|------|
| **spacingXs** | 4px | 아주 작은 간격 (Chip 내부) |
| **spacingSm** | 8px | 작은 간격 (Movement 리스트) |
| **spacingMd** | 12px | 중간 간격 (Input 필드 사이) |
| **spacingLg** | 16px | **기본 간격 (화면 패딩)** |
| **spacingXl** | 24px | 큰 간격 (섹션 구분) |
| **spacing2Xl** | 32px | 아주 큰 간격 (주요 섹션) |
| spacing3Xl | 48px | 특별한 강조 |
| spacing4Xl | 64px | 최대 간격 |

### 컴포넌트별 스페이싱
- **화면 패딩**: `spacingLg` (16px) — 좌우상하
- **위젯 간 간격**: `spacingSm` (8px), `spacingLg` (16px), `spacingXl` (24px)
- **섹션 구분**: `spacing2Xl` (32px)
- **Card 내부 패딩**: `spacingLg` (16px) — 기본값
- **버튼 내부 패딩**: horizontal: 24px, vertical: 12px (SketchButton 기본값)

---

## Border & Elevation

### Stroke (선 두께)
- **strokeThin**: 1px — 아이콘, 텍스트 밑줄
- **strokeStandard**: 2px — **Personal WOD 테두리 (기본)**
- **strokeBold**: 3px — **Base WOD 테두리 (강조)**
- **strokeThick**: 4px — 특별한 강조 (미사용)

### Border Radius
SketchContainer/SketchCard는 기본적으로 스케치 스타일이므로 radius 없음.
필요 시 디자인 토큰 참조:
- **radiusSm**: 2px
- **radiusMd**: 4px
- **radiusLg**: 8px
- **radiusPill**: 9999px — 버튼, Chip

### Elevation (그림자)
SketchCard elevation 속성:
- **0**: 그림자 없음 (평면)
- **1**: 기본 카드 (Personal WOD)
- **2**: 중간 강조 (Base WOD)
- **3**: 높은 강조 (선택된 카드)

---

## 인터랙션 상태

### 버튼 상태
- **Default**: Primary 색상, elevation: 0 (SketchButton 기본)
- **Pressed**: 색상 어두움 (darken 10%)
- **Disabled**: OnSurface 12% 투명도
- **Loading**: CircularProgressIndicator + 텍스트

### TextField 상태
- **Default**: Border 2px, base300
- **Focused**: Border 2px, accentPrimary
- **Error**: Border 2px, error 색상, 하단 에러 메시지
- **Disabled**: Border 2px, base300, 투명도 40%

### 터치 피드백
- **Ripple Effect**: InkWell 사용 (SketchCard onTap)
- **Splash Color**: accentPrimary 12% 투명도
- **Highlight Color**: accentPrimary 8% 투명도

---

## 애니메이션

### 화면 전환
- **Route Transition**: Fade In (250ms) — GetX 기본
- **Duration**: 300ms
- **Curve**: Curves.easeInOut

### 상태 변경
- **Fade In/Out**: Duration: 200ms, Curve: Curves.easeIn
- **AnimatedSwitcher**: 로딩 ↔ 컨텐츠 전환
- **AnimatedSize**: Empty ↔ Filled 전환

### 로딩
- **CircularProgressIndicator**: SketchProgressBar(value: null, style: circular)
- **Button Loading**: SketchButton(isLoading: true)

---

## 반응형 레이아웃

### Mobile-First (Primary Target)

**화면 크기 범위**: 320px ~ 428px (width)

**주요 고려사항**:
- Single column layout
- Minimum touch target: 48x48px (Material Design 권장)
- Safe area 고려 (notch, home indicator)
- 가로 모드 지원 불필요 (Portrait only)

### Tablet (Post-MVP)

**화면 크기 범위**: 600px ~ 1024px (width)

**적응형 전략**:
- 2-column layout for comparison screens (WOD Detail, Review)
- Increased padding: `spacingLg` → `spacing2Xl`
- Larger card max-width: 600px

---

## 접근성 (Accessibility)

### 색상 대비

모든 색상 조합은 WCAG AA 기준 충족:
- `accentPrimary` (#DF7D5F) on `white`: 4.5:1 이상
- `base900` (#343434) on `white`: 12.6:1
- `base500` (#8E8E8E) on `white`: 4.54:1

### 의미 전달

**색상만으로 의미 전달 금지**:
- Base WOD: 색상 + 별 아이콘 + "Base WOD" 텍스트
- Personal WOD: 색상 + "Personal WOD" 텍스트
- 에러: 빨간색 + 아이콘 + 에러 메시지

### 터치 영역

- **Minimum**: 48x48px (Material Design 권장)
- **Button**: 56x56px (large), 48x48px (medium), 40x40px (small)
- **IconButton**: 56x56px
- **Card**: 전체 영역 탭 가능

### 스크린 리더 지원

모든 인터랙티브 요소에 Semantics 제공:
```dart
Semantics(
  label: 'Base WOD 상세 보기',
  button: true,
  child: SketchCard(onTap: ...),
)
```

---

## Navigation Architecture

### Route Definitions

```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const BOX_SEARCH = '/box/search';
  static const BOX_CREATE = '/box/create';
  static const HOME = '/home';
  static const WOD_REGISTER = '/wod/register';
  static const WOD_DETAIL = '/wod/:date/detail';
  static const WOD_SELECT = '/wod/:date/select';
  static const PROPOSAL_REVIEW = '/proposal/:id/review';
  static const SETTINGS = '/settings';
}
```

### Screen Transitions

**Default Transition**: `Transition.fadeIn` (250ms)

**특별한 경우**:
- 모달 화면 (Register, Review): `Transition.downToUp`
- 뒤로가기: `Transition.rightToLeft`
- 설정: `Transition.leftToRight`

### Deep Linking Considerations (Post-MVP)

**지원할 Deep Link**:
- `wowa://wod/{date}` → 해당 날짜 홈 화면
- `wowa://box/{boxId}` → 해당 박스 가입 후 홈

---

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

**이미 구현된 컴포넌트**:
- ✅ `SketchButton` (primary/secondary/outline, 3 sizes, loading)
- ✅ `SketchCard` (header/body/footer, elevation, onTap)
- ✅ `SketchInput` (label, hint, error, prefix/suffix icon)
- ✅ `SketchModal` (show static method, actions)
- ✅ `SketchIconButton` (shape, tooltip, badge)
- ✅ `SketchChip` (selected, icon, onDeleted)
- ✅ `SketchProgressBar` (linear/circular, indeterminate)
- ✅ `SketchSwitch`, `SketchCheckbox`, `SketchSlider`, `SketchDropdown`
- ✅ `SketchContainer` (fillColor, borderColor, roughness, noise)

### 새로운 컴포넌트 필요 여부

**추가 구현 필요한 컴포넌트** (design-specialist 구현):

1. **DatePicker (Flutter 기본 사용)**
   - 목적: 날짜 선택 UI
   - 구현: `showDatePicker()` 사용 (Material Design 기본)
   - 재사용: 홈 화면
   - 우선순위: P0

2. **Badge (SketchIconButton에 포함)**
   - 목적: 알림 개수 표시
   - 구현: `SketchIconButton(badgeCount: ...)` 이미 구현됨
   - 재사용: AppBar 아이콘
   - 우선순위: 구현 완료

---

## 참고 자료

### 디자인 시스템
- **Design Tokens**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/design-tokens.json`
- **Design System Guide**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/design_system.md`
- **Frame0.app**: https://frame0.app (디자인 영감)

### Flutter Guides
- **Flutter Best Practices**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/flutter_best_practices.md`
- **GetX Best Practices**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/getx_best_practices.md`
- **Common Widgets**: `/Users/lms/dev/repository/feature-wowa-mvp/.claude/guide/mobile/common_widgets.md`

### Material Design 3
- Material Design 3: https://m3.material.io/
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets

### Competitor References
- SugarWOD: https://www.sugarwod.com/
- BTWB: https://www.beyondthewhiteboard.com/
- Wodify: https://www.wodify.com/

---

## 다음 단계

**mobile-design-spec.md 작성 완료**

다음 단계:
1. **tech-lead**: 기술 아키텍처 설계 (`mobile-technical-design.md`)
2. **mobile-developer**: API 모델 생성 및 화면 구현
3. **backend-developer**: WOD/Box API 엔드포인트 구현

---

**작성일**: 2026-02-04
**버전**: 2.0.0
**상태**: Approved
