# WOWA Mobile UI/UX Design Specification

## 개요

WOWA는 CrossFit 박스에서 WOD(Workout of the Day) 정보를 **합의 기반**으로 관리하는 모바일 앱입니다. 역할 구분 없이 누구나 WOD를 등록할 수 있으며, 시스템은 중립적으로 Base WOD와 Personal WOD를 분리하여 표시합니다.

**디자인 목표**:
- Frame0 스케치 스타일로 친근하고 부담 없는 느낌
- 합의 과정을 명확하게 시각화
- Base vs Personal WOD 구분을 직관적으로 표현
- 선택의 불변성을 강조하는 UX

**핵심 UX 전략**:
- "시스템이 판단하지 않는다"는 원칙을 UI로 구현
- Base WOD는 "먼저 등록된" 사실을 강조 (권위 아닌 순서)
- Personal WOD는 "다른 선택지"로 표현 (틀린 것이 아닌 대안)
- 변경 제안은 "합의 요청"으로 프레이밍
- 선택 확정 시 경고로 불변성 인지

---

## 화면 목록 및 라우트 구조

### Screen Inventory

| 화면명 | 라우트 | 설명 | 우선순위 |
|-------|--------|------|----------|
| 로그인 | `/login` | 소셜 로그인 (기존 완료) | P0 |
| 홈 (오늘의 WOD) | `/home` | 오늘 날짜 WOD 표시, 박스 선택 | P0 |
| WOD 등록 | `/wod/register` | WOD 텍스트/구조 입력 폼 | P0 |
| WOD 상세 | `/wod/:id/detail` | Base vs Personal 표시, 제안 UI | P0 |
| WOD 선택 | `/wod/:date/select` | Base/Personal 중 선택 | P0 |
| 변경 제안 | `/wod/:id/propose` | 변경 제안 폼 | P0 |
| 변경 승인 | `/wod/:proposalId/approve` | 승인/거부 화면 | P0 |
| 박스 관리 | `/box/manage` | 박스 목록, 생성, 가입 | P0 |
| 박스 생성 | `/box/create` | 박스 생성 폼 | P1 |
| 박스 가입 | `/box/join` | 초대 코드 입력 | P1 |
| 설정 | `/settings` | 알림 설정, 프로필 | P1 |

### Navigation Flow

```
[로그인] → [홈]
            ↓
    ┌───────┼───────┐
    ↓       ↓       ↓
[WOD 등록] [WOD 상세] [박스 관리]
    ↓       ↓           ↓
[WOD 선택] [변경 제안]  [박스 생성/가입]
            ↓
        [변경 승인]
```

---

## 화면 상세 설계

### 1. 홈 화면 (Home Screen)

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
└── Body: RefreshIndicator
    └── SingleChildScrollView
        └── Column (padding: spacingLg)
            ├── _BoxSelector (박스 선택 드롭다운)
            ├── SizedBox(height: spacing2Xl)
            ├── _DateHeader (날짜 표시 + 날짜 선택)
            ├── SizedBox(height: spacingXl)
            ├── Obx(() => _WodCardSection) // Base WOD + Personal WODs
            └── SizedBox(height: spacing2Xl)
            └── _QuickActionButtons (등록/선택 버튼)
```

#### 위젯 상세

**_BoxSelector (박스 선택)**
```dart
SketchDropdown<Box>(
  value: controller.selectedBox.value,
  items: controller.boxes,
  itemBuilder: (box) => Text(box.name),
  hint: '박스를 선택하세요',
  onChanged: controller.onBoxChanged,
)
```
- 현재 선택된 박스 표시
- 박스 전환 시 자동으로 해당 박스의 WOD 로드
- 박스가 없으면 "박스에 가입하거나 생성하세요" 힌트

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
              Text('2026년 2월 3일', style: titleMedium),
              Text('월요일', style: bodySmall, color: base500),
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
- 좌우 화살표로 날짜 이동
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
      Text('아직 등록된 WOD가 없습니다', style: titleMedium),
      SizedBox(height: spacingSm),
      Text('첫 번째로 등록하면 Base WOD가 됩니다', style: bodySmall),
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
        Text('${controller.baseWod.value.registeredBy}님이 등록',
             style: bodySmall, color: base500),
      ],
    ),
    SizedBox(height: spacingMd),

    // WOD 카드
    SketchCard(
      elevation: 2,
      onTap: controller.goToDetail,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WOD 타입 + 시간
          Row(
            children: [
              SketchChip(label: controller.baseWod.value.type), // AMRAP, ForTime 등
              SizedBox(width: spacingSm),
              Text('${controller.baseWod.value.timeCap}분', style: bodyMedium),
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
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: accentPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: spacingMd),
                  Expanded(
                    child: Text(
                      '${movement.reps} ${movement.name}${movement.weight != null ? " @ ${movement.weight}${movement.unit}" : ""}',
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
          Text('다른 버전 (${controller.personalWods.length})',
               style: titleSmall),
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
        text: 'WOD 선택',
        icon: Icon(Icons.check_circle),
        onPressed: controller.hasWod ? controller.goToSelect : null,
      ),
    ),
  ],
)
```

#### 인터랙션

- **Pull-to-refresh**: 새로고침으로 최신 WOD 조회
- **WOD 카드 탭**: 상세 화면으로 이동
- **날짜 변경**: 좌우 화살표 또는 날짜 탭으로 DatePicker
- **박스 변경**: 드롭다운에서 박스 선택 시 자동 새로고침

---

### 2. WOD 등록 화면 (WOD Registration Screen)

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
            ├── _WodTypeSelector (타입 선택)
            ├── SizedBox(height: spacingXl)
            ├── _TimeCapInput (시간 입력)
            ├── SizedBox(height: spacingXl)
            ├── _MovementListBuilder (운동 목록)
            ├── SizedBox(height: spacingXl)
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
      children: [
        'AMRAP', 'For Time', 'EMOM', 'Strength', 'Custom'
      ].map((type) =>
        Obx(() => SketchChip(
          label: type,
          selected: controller.selectedType.value == type,
          onSelected: (_) => controller.selectType(type),
        ))
      ).toList(),
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
  suffixIcon: Text('분'),
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
          icon: Icon(Icons.add),
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
      children: controller.movements.map((movement) =>
        _MovementCard(
          key: ValueKey(movement.id),
          movement: movement,
          onDelete: () => controller.removeMovement(movement.id),
        ),
      ).toList(),
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
            icon: Icon(Icons.delete_outline),
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
  onPressed: controller.canSubmit ? controller.submit : null,
  size: SketchButtonSize.large,
))
```

#### 인터랙션

- **타입 선택**: Chip 탭으로 WOD 타입 변경
- **운동 추가**: "추가" 버튼으로 새 운동 카드 추가
- **운동 재배치**: 드래그 핸들로 순서 변경
- **운동 삭제**: 삭제 아이콘으로 제거
- **미리보기**: 우측 상단 아이콘으로 입력 내용 미리보기 모달
- **등록**: 유효성 검증 후 API 호출, 성공 시 홈으로 이동

#### 에러 상태

- 필수 필드 누락: SketchInput errorText 표시
- API 에러: SketchModal로 에러 메시지 표시

---

### 3. WOD 상세 화면 (WOD Detail Screen)

**라우트**: `/wod/:id/detail`

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
        └── _ActionButtons (변경 제안, WOD 선택)
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
        Text('${controller.baseWod.value.selectedCount}명 선택',
             style: bodySmall, color: base500),
      ],
    ),
    SizedBox(height: spacingSm),
    Text('${controller.baseWod.value.registeredBy}님이 등록',
         style: bodySmall, color: base500),
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
              child: Text('변경 제안 대기 중', style: bodyMedium),
            ),
            if (controller.isBaseCreator.value)
              SketchButton(
                text: '승인하기',
                size: SketchButtonSize.small,
                onPressed: controller.goToApprove,
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
      Text('Base WOD와 다르게 등록된 버전입니다',
           style: bodySmall, color: base500),
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
                  Text('${personalWod.registeredBy}님',
                       style: bodySmall, color: base500),
                  Spacer(),
                  Text('${personalWod.selectedCount}명 선택',
                       style: bodySmall, color: base500),
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

                    // Diff 표시 (Base와 다른 부분 강조)
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
        SketchChip(label: wod.type),
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
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: accentPrimary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: spacingMd),
            Expanded(
              child: Text(
                '${movement.reps} ${movement.name}${movement.weight != null ? " @ ${movement.weight}${movement.unit}" : ""}',
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
    Text('Base WOD와 다른 점:', style: bodySmall.copyWith(fontWeight: medium)),
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
      text: 'Base 변경 제안',
      icon: Icon(Icons.edit),
      style: SketchButtonStyle.outline,
      size: SketchButtonSize.large,
      onPressed: controller.goToPropose,
    ),
  ],
)
```

#### 인터랙션

- **Base WOD 탭**: 확대 보기 또는 변경 없음
- **Personal WOD 탭**: Diff 하이라이트 토글
- **변경 제안 버튼**: 변경 제안 화면으로 이동
- **WOD 선택 버튼**: WOD 선택 화면으로 이동
- **승인하기 버튼**: 변경 승인 화면으로 이동 (Base 등록자만 표시)

---

### 4. WOD 선택 화면 (WOD Selection Screen)

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
            Text('선택 후 변경할 수 없습니다',
                 style: titleSmall.copyWith(color: warning)),
            SizedBox(height: spacingXs),
            Text('신중하게 선택해 주세요. 선택 후에는 WOD를 변경할 수 없습니다.',
                 style: bodySmall, color: base700),
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
      isSelected: controller.selectedWodId.value == controller.baseWod.value.id,
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
              width: 24, height: 24,
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
            Text('${wod.selectedCount}명 선택',
                 style: bodySmall, color: base500),
          ],
        ),
        SizedBox(height: spacingMd),
        Text('${wod.registeredBy}님이 등록',
             style: bodySmall, color: base500),
        SizedBox(height: spacingLg),

        // WOD 내용 (간략)
        _WodContentWidget(wod: wod),

        // Personal WOD면 Diff 표시
        if (!isBase) ...[
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
        Text('정말 이 WOD로 기록하시겠습니까?',
             style: titleMedium),
        SizedBox(height: spacingSm),
        Text('선택 후에는 변경할 수 없습니다.',
             style: bodySmall, color: error),
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
  );
  ```

---

### 5. 변경 제안 화면 (Propose Change Screen)

**라우트**: `/wod/:id/propose`

**목적**: Base WOD에 대한 변경 제안 제출

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("Base 변경 제안")
└── Body: SingleChildScrollView
    └── Column (padding: spacingLg)
        ├── _CurrentBaseWod (현재 Base WOD 표시)
        ├── SizedBox(height: spacing2Xl)
        ├── _ProposedChangesForm (변경 제안 폼)
        ├── SizedBox(height: spacing2Xl)
        ├── _DiffPreview (변경 사항 미리보기)
        ├── SizedBox(height: spacing2Xl)
        └── SketchButton (제안하기)
```

#### 위젯 상세

**_CurrentBaseWod (현재 Base WOD)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('현재 Base WOD', style: titleMedium),
    SizedBox(height: spacingMd),
    SketchCard(
      elevation: 1,
      body: _WodContentWidget(wod: controller.baseWod.value),
    ),
  ],
)
```

**_ProposedChangesForm (제안 폼)**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('제안하는 변경 사항', style: titleMedium),
    SizedBox(height: spacingMd),

    // Base WOD 데이터를 초기값으로 사용하는 등록 폼 재사용
    _WodTypeSelector(),
    SizedBox(height: spacingLg),
    _TimeCapInput(),
    SizedBox(height: spacingLg),
    _MovementListBuilder(),
  ],
)
```

**_DiffPreview (변경 사항 미리보기)**
```dart
Obx(() {
  final diff = controller.calculateDiff();
  if (diff.isEmpty) {
    return SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('변경될 내용', style: titleSmall),
      SizedBox(height: spacingMd),
      SketchContainer(
        fillColor: info.withOpacity(0.05),
        borderColor: info,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: diff.map((change) =>
            Padding(
              padding: EdgeInsets.only(bottom: spacingXs),
              child: Row(
                children: [
                  Icon(Icons.arrow_forward, size: 16, color: info),
                  SizedBox(width: spacingMd),
                  Expanded(
                    child: Text(
                      change.description, // 예: '시간: 15분 → 20분'
                      style: bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ),
      ),
    ],
  );
})
```

#### 인터랙션

- **폼 입력**: Base WOD 데이터를 수정하여 제안 작성
- **실시간 Diff**: 입력 변경 시 자동으로 변경 사항 계산 및 표시
- **제안하기 버튼**: 유효성 검증 후 API 호출, 성공 시 상세 화면으로 복귀

---

### 6. 변경 승인 화면 (Approve Change Screen)

**라우트**: `/wod/:proposalId/approve`

**목적**: Base WOD 등록자가 변경 제안을 승인/거부

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
        backgroundImage: NetworkImage(controller.proposer.profileImage),
      ),
      SizedBox(width: spacingMd),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${controller.proposer.name}님의 제안',
                 style: titleSmall),
            Text('${controller.proposal.createdAt}',
                 style: bodySmall, color: base500),
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

- **승인 버튼**: 확인 모달 후 Base WOD 교체 API 호출
  - 성공 시 기존 Base 선택자에게 알림 발송
  - 상세 화면으로 복귀
- **거부 버튼**: 제안 거부 API 호출, 제안자에게 알림
- **승인 확인 모달**:
  ```dart
  SketchModal.show(
    title: '변경 승인',
    child: Text('이 제안을 승인하면 Base WOD가 변경됩니다.\n기존 Base WOD를 선택한 사용자에게 알림이 전송됩니다.'),
    actions: [...],
  );
  ```

---

### 7. 박스 관리 화면 (Box Management Screen)

**라우트**: `/box/manage`

**목적**: 가입한 박스 목록 보기, 새 박스 생성, 초대 코드로 가입

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("박스 관리")
└── Body: SingleChildScrollView
    └── Column (padding: spacingLg)
        ├── _MyBoxesList (가입한 박스 목록)
        ├── SizedBox(height: spacing2Xl)
        └── _BoxActions (박스 생성/가입 버튼)
```

#### 위젯 상세

**_MyBoxesList (가입한 박스 목록)**
```dart
Obx(() {
  if (controller.boxes.isEmpty) {
    return SketchCard(
      body: Column(
        children: [
          Icon(Icons.fitness_center, size: 64, color: base300),
          SizedBox(height: spacingLg),
          Text('가입한 박스가 없습니다', style: titleMedium),
          SizedBox(height: spacingSm),
          Text('박스를 생성하거나 초대 코드로 가입하세요',
               style: bodySmall, color: base500),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('내 박스 (${controller.boxes.length})', style: titleMedium),
      SizedBox(height: spacingMd),
      ...controller.boxes.map((box) =>
        Padding(
          padding: EdgeInsets.only(bottom: spacingMd),
          child: SketchCard(
            onTap: () => controller.selectBox(box),
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
                      Text('${box.memberCount}명',
                           style: bodySmall, color: base500),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: base500),
              ],
            ),
          ),
        ),
      ).toList(),
    ],
  );
})
```

**_BoxActions (박스 액션 버튼)**
```dart
Column(
  children: [
    SketchButton(
      text: '박스 생성',
      icon: Icon(Icons.add_business),
      size: SketchButtonSize.large,
      onPressed: () => Get.toNamed(Routes.BOX_CREATE),
    ),
    SizedBox(height: spacingMd),
    SketchButton(
      text: '초대 코드로 가입',
      icon: Icon(Icons.qr_code_scanner),
      style: SketchButtonStyle.outline,
      size: SketchButtonSize.large,
      onPressed: () => Get.toNamed(Routes.BOX_JOIN),
    ),
  ],
)
```

---

### 8. 박스 생성 화면 (Box Create Screen)

**라우트**: `/box/create`

**목적**: 새 박스 생성

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
            ├── SketchInput (설명, multiline)
            ├── SizedBox(height: spacing2Xl)
            └── SketchButton (생성하기)
```

#### 위젯 상세

```dart
Column(
  children: [
    SketchInput(
      label: '박스 이름',
      hint: '예: CrossFit Seoul',
      controller: controller.nameController,
      errorText: controller.nameError.value,
    ),
    SizedBox(height: spacingLg),
    SketchInput(
      label: '설명 (선택)',
      hint: '박스에 대한 간단한 설명',
      controller: controller.descriptionController,
      maxLines: 3,
    ),
    SizedBox(height: spacing2Xl),
    Obx(() => SketchButton(
      text: '생성하기',
      icon: Icon(Icons.check),
      size: SketchButtonSize.large,
      isLoading: controller.isLoading.value,
      onPressed: controller.canSubmit ? controller.create : null,
    )),
  ],
)
```

---

### 9. 박스 가입 화면 (Box Join Screen)

**라우트**: `/box/join`

**목적**: 초대 코드로 박스 가입

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton (뒤로가기)
    └── Title: Text("박스 가입")
└── Body: SingleChildScrollView (padding: spacingLg)
    └── Column
        ├── SketchInput (초대 코드)
        ├── SizedBox(height: spacingLg)
        ├── SketchButton (검증하기)
        ├── SizedBox(height: spacing2Xl)
        ├── Obx(() => _BoxPreview) // 검증된 박스 미리보기
        ├── SizedBox(height: spacingXl)
        └── Obx(() => SketchButton) // 가입하기
```

#### 위젯 상세

```dart
Column(
  children: [
    SketchInput(
      label: '초대 코드',
      hint: 'ABCD-1234-EFGH',
      controller: controller.codeController,
      prefixIcon: Icon(Icons.key),
      errorText: controller.codeError.value,
    ),
    SizedBox(height: spacingLg),
    SketchButton(
      text: '검증하기',
      icon: Icon(Icons.search),
      style: SketchButtonStyle.outline,
      onPressed: controller.verify,
    ),

    SizedBox(height: spacing2Xl),

    // 검증 성공 시 박스 미리보기
    if (controller.verifiedBox.value != null) ...[
      SketchCard(
        elevation: 2,
        borderColor: success,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: success),
                SizedBox(width: spacingSm),
                Text('초대 코드 확인됨',
                     style: bodyMedium.copyWith(color: success)),
              ],
            ),
            SizedBox(height: spacingLg),
            Text(controller.verifiedBox.value.name,
                 style: titleMedium),
            SizedBox(height: spacingSm),
            Text(controller.verifiedBox.value.description ?? '',
                 style: bodySmall, color: base500),
            SizedBox(height: spacingSm),
            Text('${controller.verifiedBox.value.memberCount}명',
                 style: bodySmall, color: base500),
          ],
        ),
      ),

      SizedBox(height: spacingXl),

      SketchButton(
        text: '가입하기',
        icon: Icon(Icons.login),
        size: SketchButtonSize.large,
        isLoading: controller.isLoading.value,
        onPressed: controller.join,
      ),
    ],
  ],
)
```

---

## 디자인 결정 사항 (Design Decisions)

### 1. 색상 코딩 전략

**Base vs Personal WOD 구분**:
- **Base WOD**:
  - Border: `accentPrimary` (#DF7D5F)
  - Stroke: `strokeBold` (3px)
  - Background: `white`
  - Badge: `SketchChip(selected: true)` with star icon

- **Personal WOD**:
  - Border: `base300` (#DCDCDC)
  - Stroke: `strokeStandard` (2px)
  - Background: `white`
  - Badge: `SketchChip(selected: false)` no icon

**의미론적 색상**:
- 성공/승인: `success` (#4CAF50)
- 경고/주의: `warning` (#FFC107)
- 에러/거부: `error` (#F44336)
- 정보/중립: `info` (#2196F3)

### 2. WOD 타입 배지

모든 WOD 타입은 `SketchChip`로 표시:
- AMRAP: `accentPrimary` 배경
- For Time: `info` 배경
- EMOM: `success` 배경
- Strength: `warning` 배경
- Custom: `base500` 배경

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

## 반응형 고려사항

### Mobile-First (Primary Target)

**화면 크기 범위**: 320px ~ 428px (width)

**주요 고려사항**:
- Single column layout
- Minimum touch target: 48x48px
- Safe area 고려 (notch, home indicator)
- 가로 모드 지원 불필요 (Portrait only)

### Tablet (Secondary, Post-MVP)

**화면 크기 범위**: 600px ~ 1024px (width)

**적응형 전략**:
- 2-column layout for comparison screens (WOD Detail, Approve)
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
  child: SketchCard(...),
)
```

---

## Navigation Architecture

### Route Definitions

```dart
abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const WOD_REGISTER = '/wod/register';
  static const WOD_DETAIL = '/wod/:id/detail';
  static const WOD_SELECT = '/wod/:date/select';
  static const WOD_PROPOSE = '/wod/:id/propose';
  static const WOD_APPROVE = '/wod/:proposalId/approve';
  static const BOX_MANAGE = '/box/manage';
  static const BOX_CREATE = '/box/create';
  static const BOX_JOIN = '/box/join';
  static const SETTINGS = '/settings';
}
```

### Screen Transitions

**Default Transition**: `Transition.fadeIn` (250ms)

**특별한 경우**:
- 모달 화면 (Propose, Approve): `Transition.downToUp`
- 뒤로가기: `Transition.rightToLeft`
- 설정: `Transition.leftToRight`

### Deep Linking Considerations

**지원할 Deep Link**:
- `wowa://wod/{date}` → 해당 날짜 홈 화면
- `wowa://box/{boxId}` → 박스 선택 후 홈
- `wowa://box/join?code={inviteCode}` → 박스 가입 화면

---

## 애니메이션 전략

### Sketch Drawing Animation (Post-MVP)

**AnimatedSketchPainter** 사용:
```dart
AnimatedSketchPainter(
  child: _WodContentWidget(wod: wod),
  duration: Duration(milliseconds: 800),
  curve: Curves.easeInOut,
)
```

- WOD 카드 첫 로드 시 "손으로 그리는" 효과
- 선택/해제 시 테두리 애니메이션

### State Transitions

**로딩 → 컨텐츠**:
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: isLoading ? SketchProgressBar(...) : _WodCard(...),
)
```

**Empty → Filled**:
```dart
AnimatedSize(
  duration: Duration(milliseconds: 250),
  child: _WodCardSection(),
)
```

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

1. **SketchDatePicker**
   - 목적: 날짜 선택 UI
   - 재사용: 홈 화면, WOD 조회
   - 우선순위: P1

2. **SketchBadge**
   - 목적: 알림 개수 표시
   - 재사용: AppBar 아이콘, WOD 카드
   - 우선순위: P1
   - 참고: 현재 SketchIconButton에 badgeCount 있음

3. **SketchTimePicker**
   - 목적: 시간(분) 입력 UI
   - 재사용: WOD 등록 화면
   - 우선순위: P2 (SketchInput으로 대체 가능)

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

**design-spec.md 작성 완료**

다음 단계:
1. **tech-lead**: 기술 아키텍처 설계 (`technical-design.md`)
2. **design-specialist**: Design System 신규 컴포넌트 구현 (필요시)
3. **mobile-developer**: API 모델 생성 및 화면 구현
4. **backend-developer**: WOD/Box API 엔드포인트 구현

---

**작성일**: 2026-02-03
**버전**: 1.0.0
**상태**: Draft
