# UI/UX 디자인 명세: QnA (질문과 답변)

## 개요

사용자가 제품 사용 중 궁금한 점을 간편하게 질문할 수 있는 화면을 설계합니다. **최소한의 입력 필드**와 **명확한 피드백**으로 사용자 경험을 단순화하며, Frame0 스케치 스타일의 손그림 감성을 유지합니다.

**핵심 UX 전략**:
- 제목(256자)과 본문(65536자) 2개 입력 필드로 단순화
- 실시간 입력 검증으로 제출 전 에러 방지
- 로딩/성공/실패 상태를 명확한 시각적 피드백으로 표현
- 네트워크 오류 시 재시도 용이성 확보

---

## 화면 구조

### Screen 1: QnA 질문 작성 화면 (QnaSubmitView)

#### 레이아웃 계층

```
Scaffold
├── AppBar
│   ├── leading: IconButton (뒤로가기)
│   │   └── icon: Icons.arrow_back
│   └── title: Text("질문하기")
│
└── body: SafeArea
    └── SingleChildScrollView (키보드 대응)
        └── Padding (horizontal: 24, vertical: 16)
            └── Column (crossAxisAlignment: start)
                ├── SizedBox(height: 8)
                │
                ├── Text (안내 문구)
                │   └── "궁금한 점을 남겨주세요. 빠르게 답변드리겠습니다."
                │
                ├── SizedBox(height: 24)
                │
                ├── SketchInput (제목 입력 필드)
                │   ├── label: "제목"
                │   ├── hint: "질문 제목을 입력하세요 (최대 256자)"
                │   ├── controller: titleController
                │   ├── maxLength: 256
                │   ├── errorText: Obx로 반응형 에러 메시지
                │   └── prefixIcon: Icons.edit
                │
                ├── SizedBox(height: 24)
                │
                ├── SketchInput (본문 입력 필드)
                │   ├── label: "질문 내용"
                │   ├── hint: "구체적으로 작성할수록 빠른 답변을 받을 수 있습니다 (최대 65536자)"
                │   ├── controller: bodyController
                │   ├── maxLength: 65536
                │   ├── minLines: 8
                │   ├── maxLines: 20
                │   ├── errorText: Obx로 반응형 에러 메시지
                │   └── prefixIcon: Icons.description
                │
                ├── SizedBox(height: 12)
                │
                ├── Obx → Text (글자 수 카운터)
                │   └── "본문: ${controller.bodyLength.value} / 65536자"
                │   └── color: 글자 수에 따라 변화 (60000자 초과 시 경고 색상)
                │
                ├── SizedBox(height: 32)
                │
                ├── Obx → SketchButton (제출 버튼)
                │   ├── text: "질문 제출"
                │   ├── icon: Icons.send
                │   ├── size: SketchButtonSize.large
                │   ├── isLoading: controller.isSubmitting.value
                │   ├── onPressed: 조건부 활성화
                │   │   └── 제목/본문이 비어있지 않고, 길이 제한 내일 때만 활성화
                │   └── style: SketchButtonStyle.primary
                │
                └── SizedBox(height: 16)
```

#### 위젯 상세

**AppBar**
- backgroundColor: SketchThemeExtension.of(context).backgroundColor
- elevation: 0 (스케치 스타일은 그림자 최소화)
- leading: IconButton
  - icon: Icons.arrow_back
  - onPressed: Get.back()
- title: Text
  - "질문하기"
  - style: titleLarge (fontSize: 22, fontWeight: 500)

**안내 문구 (Text)**
- text: "궁금한 점을 남겨주세요. 빠르게 답변드리겠습니다."
- style:
  - fontSize: 14 (fontSizeSm)
  - color: SketchDesignTokens.base700 (회색)
  - height: 1.5 (lineHeight)

**SketchInput (제목)**
- label: "제목" (필수 표시 "*" 포함)
- hint: "질문 제목을 입력하세요 (최대 256자)"
- controller: titleController
- maxLength: 256
- textInputAction: TextInputAction.next (다음 필드로 이동)
- keyboardType: TextInputType.text
- prefixIcon: Icons.edit
  - color: SketchDesignTokens.accentPrimary
  - size: 20
- errorText: Obx(() => controller.titleError.value)
  - 조건:
    - 빈 값: null (에러 없음)
    - 256자 초과: "제목은 256자 이내로 입력해주세요"
- border: OutlineInputBorder
  - borderRadius: 8 (radiusLg)
  - borderSide: SketchDesignTokens.base300, strokeStandard (2px)
- focusedBorder:
  - borderSide: SketchDesignTokens.accentPrimary, strokeBold (3px)

**SketchInput (본문)**
- label: "질문 내용" (필수 표시 "*" 포함)
- hint: "구체적으로 작성할수록 빠른 답변을 받을 수 있습니다 (최대 65536자)"
- controller: bodyController
- maxLength: 65536
- minLines: 8 (최소 8줄 높이 확보)
- maxLines: 20 (최대 20줄까지 확장)
- textInputAction: TextInputAction.done
- keyboardType: TextInputType.multiline
- prefixIcon: Icons.description
  - color: SketchDesignTokens.accentPrimary
  - size: 20
- errorText: Obx(() => controller.bodyError.value)
  - 조건:
    - 빈 값: null
    - 65536자 초과: "본문은 65536자 이내로 입력해주세요"
- border: OutlineInputBorder
  - borderRadius: 8
  - borderSide: SketchDesignTokens.base300, strokeStandard (2px)
- focusedBorder:
  - borderSide: SketchDesignTokens.accentPrimary, strokeBold (3px)

**글자 수 카운터 (Text)**
- text: "본문: ${controller.bodyLength.value} / 65536자"
- style:
  - fontSize: 12 (fontSizeXs)
  - color:
    - 기본: SketchDesignTokens.base500
    - 60000자 초과: SketchDesignTokens.warning (노란색)
    - 65000자 초과: SketchDesignTokens.error (빨간색)
  - fontWeight: 60000자 초과 시 FontWeight.w500
- alignment: right (우측 정렬)

**SketchButton (제출 버튼)**
- text: "질문 제출"
- icon: Icons.send (16x16)
- size: SketchButtonSize.large
  - padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)
- style: SketchButtonStyle.primary
  - fillColor: SketchDesignTokens.accentPrimary
  - foregroundColor: Colors.white
  - roughness: 0.8 (기본 손그림 효과)
- isLoading: Obx(() => controller.isSubmitting.value)
  - true: CircularProgressIndicator (16x16, 흰색) + 텍스트 "제출 중..."
- onPressed: 조건부
  - 활성화 조건:
    1. titleController.text.isNotEmpty
    2. bodyController.text.isNotEmpty
    3. titleController.text.length <= 256
    4. bodyController.text.length <= 65536
    5. !controller.isSubmitting.value
  - 비활성화 시: null (회색 처리)
- elevation: 2 (기본 상태), 4 (pressed 상태)
- borderRadius: 9999 (pill 모양)

---

### Screen 2: 제출 결과 피드백

**성공 시**: BottomSheet 모달 (또는 SketchModal)

```
SketchModal
├── icon: Icons.check_circle
│   └── color: SketchDesignTokens.success (녹색)
│   └── size: 48
├── SizedBox(height: 16)
├── Text (제목)
│   └── "질문이 등록되었습니다"
│   └── style: fontSize: 20, fontWeight: 600
├── SizedBox(height: 8)
├── Text (부제목)
│   └── "빠른 시일 내에 답변드리겠습니다."
│   └── style: fontSize: 14, color: base700
├── SizedBox(height: 24)
└── SketchButton
    ├── text: "확인"
    ├── onPressed: () { Get.back(); Get.back(); } // 모달 닫기 + 화면 닫기
    └── style: primary
```

**실패 시**: BottomSheet 모달 (또는 SketchModal)

```
SketchModal
├── icon: Icons.error_outline
│   └── color: SketchDesignTokens.error (빨간색)
│   └── size: 48
├── SizedBox(height: 16)
├── Text (제목)
│   └── "질문 등록에 실패했습니다"
│   └── style: fontSize: 20, fontWeight: 600
├── SizedBox(height: 8)
├── Text (에러 메시지)
│   └── Obx(() => controller.errorMessage.value)
│   └── 예시:
│       - "네트워크 연결을 확인해주세요"
│       - "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
│       - "제목과 내용을 확인해주세요"
│   └── style: fontSize: 14, color: error
├── SizedBox(height: 24)
└── Row (버튼 2개)
    ├── Expanded → SketchButton
    │   ├── text: "닫기"
    │   ├── style: outline
    │   └── onPressed: Navigator.pop(context)
    └── SizedBox(width: 12)
    └── Expanded → SketchButton
        ├── text: "재시도"
        ├── style: primary
        └── onPressed: controller.submitQuestion()
```

---

## 색상 팔레트 (Frame0 스케치 스타일)

### Primary Colors
- **accentPrimary**: `#DF7D5F` - 주요 액션 버튼, 포커스 테두리
- **accentLight**: `#F19E7E` - 버튼 hover/pressed 상태
- **accentDark**: `#C86947` - 강조, 활성화 상태

### Background Colors
- **white**: `#FFFFFF` - 앱 배경, 입력 필드 배경
- **base100**: `#F7F7F7` - Surface 배경 (카드, 시트)
- **base200**: `#EBEBEB` - 비활성화 배경

### Border Colors
- **base300**: `#DCDCDC` - 기본 테두리 (unfocused)
- **base500**: `#8E8E8E` - 구분선, 비활성화 텍스트
- **base700**: `#5E5E5E` - 보조 텍스트

### Text Colors
- **black**: `#000000` - 주요 텍스트 (제목, 본문)
- **base900**: `#343434` - 보조 텍스트
- **base700**: `#5E5E5E` - 힌트, 안내 문구

### Semantic Colors
- **success**: `#4CAF50` - 성공 상태 (등록 완료)
- **error**: `#F44336` - 에러 상태 (등록 실패, 검증 오류)
- **warning**: `#FFC107` - 경고 상태 (글자 수 초과 임박)
- **info**: `#2196F3` - 정보 표시

---

## 타이포그래피 (Frame0 Type Scale)

### Headline
- **headlineSmall**: fontSize: 24, fontWeight: 400, height: 32/24 - 모달 제목

### Title
- **titleLarge**: fontSize: 22, fontWeight: 500, height: 28/22 - AppBar 제목
- **titleMedium**: fontSize: 16, fontWeight: 500, height: 24/16 - 섹션 제목

### Body
- **bodyLarge**: fontSize: 16, fontWeight: 400, height: 24/16 - 입력 필드 본문
- **bodyMedium**: fontSize: 14, fontWeight: 400, height: 20/14 - 안내 문구, 부제목
- **bodySmall**: fontSize: 12, fontWeight: 400, height: 16/12 - 글자 수 카운터, 에러 메시지

### Label
- **labelLarge**: fontSize: 14, fontWeight: 500, height: 20/14 - 버튼 텍스트
- **labelMedium**: fontSize: 12, fontWeight: 500, height: 16/12 - 입력 필드 레이블

---

## 스페이싱 시스템 (8px 그리드)

### Padding/Margin
- **xs**: 4px - 작은 간격 (아이콘 내부)
- **sm**: 8px - 최소 간격 (위젯 내부)
- **md**: 12px - 작은 구분 (입력 필드 간격)
- **lg**: 16px - 기본 간격 (버튼 내부 padding, 섹션 간격)
- **xl**: 24px - 큰 간격 (화면 패딩, 섹션 구분)
- **2xl**: 32px - 특별한 강조 (제출 버튼 위 여백)

### 컴포넌트별 스페이싱
- **화면 패딩**: horizontal: 24px, vertical: 16px
- **위젯 간 간격**:
  - 입력 필드: 24px (명확한 구분)
  - 안내 문구 → 입력 필드: 24px
  - 글자 수 카운터 → 버튼: 32px
- **입력 필드 내부 패딩**: 12px (좌우상하)
- **버튼 내부 패딩**: horizontal: 32px, vertical: 16px (large)

---

## Border Radius

- **small**: 4px - 아주 작은 요소
- **medium**: 8px (radiusLg) - 입력 필드, 작은 카드
- **large**: 12px (radiusXl) - 큰 카드, 모달
- **pill**: 9999px - 버튼 (완전한 라운드)

---

## Elevation (그림자)

**Frame0 스케치 스타일에서는 그림자를 최소화**하지만, 버튼과 모달에서 약간의 깊이감 표현:

- **Level 0**: 0px - 입력 필드, 배경
- **Level 1**: 1px (md) - 기본 카드, 작은 강조
- **Level 2**: 2px - 버튼 기본 상태
- **Level 3**: 4px - 버튼 pressed 상태
- **Level 4**: 8px - 모달 다이얼로그

---

## 인터랙션 상태

### SketchButton 상태

| 상태 | fillColor | borderColor | elevation | 설명 |
|------|-----------|-------------|-----------|------|
| **Default** | accentPrimary | accentPrimary | 2 | 기본 상태 |
| **Hover** | accentLight | accentLight | 2 | (웹/데스크탑) 마우스 오버 |
| **Pressed** | accentDark | accentDark | 4 | 터치 눌림 |
| **Disabled** | base200 | base300 | 0 | 비활성화 (조건 미충족) |
| **Loading** | accentPrimary | accentPrimary | 2 | CircularProgressIndicator 표시 |

### SketchInput 상태

| 상태 | border | errorText | 설명 |
|------|--------|-----------|------|
| **Default** | base300, 2px | null | 기본 상태 |
| **Focused** | accentPrimary, 3px | null | 포커스 (입력 중) |
| **Error** | error, 3px | 에러 메시지 표시 | 검증 실패 |
| **Disabled** | base300, 1px | null | 비활성화 |

### 터치 피드백
- **InkWell Ripple**: accentPrimary 12% 투명도
- **Splash Color**: accentLight 8% 투명도
- **Highlight Color**: accentPrimary 8% 투명도

---

## 애니메이션

### 화면 전환
- **Route Transition**: Cupertino 슬라이드 (iOS 스타일)
- **Duration**: 300ms
- **Curve**: Curves.easeInOut

### 모달 표시
- **Fade In**: Duration: 200ms, Curve: Curves.easeIn
- **Slide Up**: Duration: 250ms, Curve: Curves.easeOut (Bottom Sheet)

### 로딩
- **CircularProgressIndicator**: 기본 Material 스피너 (16x16, 흰색)
- **Duration**: 무한 회전

### 입력 검증 에러
- **Shake Animation** (선택적): Duration: 300ms, 3회 진동 (에러 발생 시 입력 필드 흔들림)
- **Fade In**: 에러 텍스트 표시 시 200ms

---

## 반응형 레이아웃

### Breakpoints (모바일 중심)
- **Mobile Portrait**: width < 600px (기본)
- **Mobile Landscape**: 600px ≤ width < 768px
- **Tablet**: width ≥ 768px (향후 확장)

### 적응형 레이아웃 전략
- **세로 모드**: 기본 1열 레이아웃, 화면 패딩 24px
- **가로 모드**:
  - 화면 패딩 32px (좌우 더 넓게)
  - 입력 필드 최대 너비 제한 (600px) - 중앙 정렬
- **키보드 대응**: SingleChildScrollView로 키보드 노출 시 자동 스크롤

### 터치 영역
- **최소 크기**: 48x48px (Material Design 가이드라인)
- **버튼 크기**: 56px 높이 (large)
- **아이콘 크기**: 20x20px (입력 필드 prefix), 48x48px (모달 아이콘)

---

## 접근성 (Accessibility)

### 색상 대비
- **주요 텍스트 (black) 대 배경 (white)**: 21:1 (WCAG AAA)
- **버튼 텍스트 (white) 대 accentPrimary**: 4.5:1 (WCAG AA)
- **에러 텍스트 (error) 대 배경**: 6.7:1 (WCAG AA)

### 의미 전달
- **필수 입력 표시**: 레이블에 "*" 문자 추가 (색상만으로 표시 금지)
- **에러 표시**: 빨간색 테두리 + 에러 아이콘 + 텍스트 메시지 병행
- **로딩 상태**: 스피너 + "제출 중..." 텍스트

### 스크린 리더 지원
- **Semantics Label**: 모든 인터랙티브 요소에 명확한 레이블 제공
  - AppBar leading: "뒤로 가기 버튼"
  - SketchInput (제목): "질문 제목 입력 필드, 필수 항목, 최대 256자"
  - SketchInput (본문): "질문 내용 입력 필드, 필수 항목, 최대 65536자"
  - SketchButton: "질문 제출 버튼"

---

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)
| 컴포넌트 | 사용 위치 | 속성 |
|---------|----------|------|
| **SketchButton** | 제출 버튼 | text, icon, isLoading, onPressed, size: large |
| **SketchInput** | 제목/본문 입력 필드 | label, hint, controller, maxLength, errorText, prefixIcon |
| **SketchModal** | 성공/실패 모달 | title, child, actions, showCloseButton |
| **SketchContainer** | (선택적) 입력 필드 래퍼 | fillColor: white, borderColor: base300 |

### 새로운 컴포넌트 필요 여부
현재 Design System의 기존 컴포넌트로 모든 UI 구현 가능.

**추가 제안** (향후 확장 시):
- **SketchTextArea**: multiline 전용 입력 필드 (SketchInput 확장)
- **SketchCharCounter**: 글자 수 카운터 위젯 (재사용 가능)

---

## 인터랙션 플로우

### 1. 기본 입력 플로우

```
사용자 액션                      시스템 반응
┌─────────────────────────────────────────────────────────┐
│ 1. "질문하기" 화면 진입       → QnaSubmitView 렌더링     │
│                                  - 제목/본문 입력 필드 표시│
│                                  - 제출 버튼 비활성화     │
│                                                            │
│ 2. 제목 입력 (포커스)          → border: accentPrimary 3px│
│    - 첫 글자 입력              → 제목 에러 해제           │
│                                                            │
│ 3. 본문 입력 (포커스)          → border: accentPrimary 3px│
│    - 첫 글자 입력              → 본문 에러 해제           │
│    - 글자 수 증가              → 카운터 실시간 업데이트   │
│    - 60000자 초과              → 카운터 색상: warning     │
│    - 65000자 초과              → 카운터 색상: error       │
│                                                            │
│ 4. 제목/본문 모두 입력 완료    → 제출 버튼 활성화        │
│                                  (accentPrimary 색상)      │
│                                                            │
│ 5. "질문 제출" 버튼 탭         → 다음 플로우로 이동       │
└─────────────────────────────────────────────────────────┘
```

### 2. 제출 및 로딩 플로우

```
사용자 액션                      시스템 반응
┌─────────────────────────────────────────────────────────┐
│ 1. "질문 제출" 버튼 탭         → isSubmitting = true     │
│                                  - 버튼 텍스트: "제출 중..│
│                                  - CircularProgressIndicator │
│                                  - 버튼 비활성화 (중복 방지)│
│                                  - 입력 필드 비활성화     │
│                                                            │
│ 2. API 호출 진행               → 로딩 상태 유지 (1-5초)  │
│                                                            │
│ 3-A. 성공 시                   → isSubmitting = false    │
│                                  → 성공 모달 표시         │
│                                  → "확인" 버튼 탭 시:     │
│                                     - 모달 닫기           │
│                                     - 이전 화면으로 이동  │
│                                                            │
│ 3-B. 실패 시                   → isSubmitting = false    │
│                                  → 실패 모달 표시         │
│                                  → 에러 메시지 표시       │
│                                  → 재시도 옵션 제공       │
└─────────────────────────────────────────────────────────┘
```

### 3. 입력 검증 (실시간)

```
검증 조건                         에러 메시지 표시
┌─────────────────────────────────────────────────────────┐
│ 제목 필드:                                                │
│ - 빈 값 + 제출 시도            → "제목을 입력해주세요"    │
│ - 256자 초과                  → "제목은 256자 이내로..."  │
│                                                            │
│ 본문 필드:                                                │
│ - 빈 값 + 제출 시도            → "질문 내용을 입력해주세요"│
│ - 65536자 초과                → "본문은 65536자 이내로..." │
│                                                            │
│ 제출 버튼:                                                │
│ - 제목/본문 중 하나라도 빈 값  → 버튼 비활성화 (회색)    │
│ - 길이 제한 초과               → 버튼 비활성화            │
│ - 모든 조건 충족               → 버튼 활성화 (accentPrimary)│
└─────────────────────────────────────────────────────────┘
```

### 4. 에러 처리 플로우

```
에러 유형                         사용자 피드백
┌─────────────────────────────────────────────────────────┐
│ 네트워크 오류:                                            │
│ - timeout, connection error   → "네트워크 연결을 확인해주세요"│
│                                  → 재시도 버튼 표시       │
│                                                            │
│ 서버 오류 (5xx):                                          │
│ - GitHub API 장애             → "일시적인 오류가 발생했습니다│
│                                    잠시 후 다시 시도해주세요"│
│                                  → 재시도 버튼 표시       │
│                                                            │
│ 입력 검증 오류 (4xx):                                     │
│ - 제목/본문 누락               → "제목과 내용을 확인해주세요"│
│                                  → 모달 닫기 (재입력 유도)│
│                                                            │
│ 재시도 버튼 탭:                                           │
│                                  → 실패 모달 닫기         │
│                                  → submitQuestion() 재호출│
│                                  → 로딩 플로우 재시작     │
└─────────────────────────────────────────────────────────┘
```

---

## GetX 반응형 상태 관리

### Controller의 .obs 변수
| 변수명 | 타입 | 초기값 | 역할 |
|--------|------|--------|------|
| `isSubmitting` | `RxBool` | `false` | 제출 로딩 상태 |
| `titleError` | `RxString` | `''` | 제목 에러 메시지 |
| `bodyError` | `RxString` | `''` | 본문 에러 메시지 |
| `bodyLength` | `RxInt` | `0` | 본문 글자 수 |
| `errorMessage` | `RxString` | `''` | API 에러 메시지 |

### Obx로 반응형 렌더링되는 위젯
1. **제출 버튼**: `isSubmitting.value`에 따라 로딩 상태 표시
2. **글자 수 카운터**: `bodyLength.value`에 따라 색상 변경
3. **에러 텍스트**: `titleError.value`, `bodyError.value` 표시
4. **실패 모달**: `errorMessage.value` 표시

---

## const 최적화

정적 위젯은 const 생성자 사용으로 불필요한 리빌드 방지:

```dart
// const 사용 가능
const SizedBox(height: 24)
const Text('안내 문구') // 변경되지 않는 텍스트
const Icon(Icons.edit)

// const 사용 불가 (동적 값)
Obx(() => Text(controller.bodyLength.value)) // .obs 반응형
SketchButton(
  isLoading: controller.isSubmitting.value, // 동적 상태
)
```

---

## 참고 자료

### Material Design 가이드라인
- Text Field: https://m3.material.io/components/text-fields
- Buttons: https://m3.material.io/components/buttons
- Snackbars: https://m3.material.io/components/snackbar

### Flutter Widget Catalog
- TextField: https://api.flutter.dev/flutter/material/TextField-class.html
- Form Validation: https://docs.flutter.dev/cookbook/forms/validation

### 관련 레퍼런스
- Frame0.app: https://frame0.app (스케치 스타일 영감)
- 로그인 화면 구현: `apps/mobile/apps/wowa/lib/app/modules/login/views/login_view.dart`
- Design System 가이드: `.claude/guide/mobile/design_system.md`
- User Story: `docs/core/qna/user-story.md`

---

## 다음 단계

이제 **tech-lead 에이전트**가 이 디자인 명세를 기반으로 기술 아키텍처를 설계합니다:

1. **API 모델 정의** (LoginRequest/Response 패턴 참고)
2. **QnaController 설계** (LoginController 패턴 참고)
3. **QnaSubmitView 구현 계획**
4. **에러 처리 전략** (NetworkException, AuthException 패턴 활용)
5. **라우팅 설정** (app_routes.dart, app_pages.dart 업데이트)

**출력 파일**: `docs/core/qna/mobile-tech-design.md`
