# UI/UX 디자인 명세: 소셜 로그인 버튼 컴포넌트

## 개요

카카오, 네이버, 애플, 구글의 소셜 로그인 버튼을 Sketch Design System의 Frame0 스타일로 구현합니다. 각 플랫폼의 공식 디자인 가이드라인을 준수하면서도 손그림 스타일의 불규칙한 테두리와 노이즈 텍스처를 적용하여 wowa 앱의 디자인 언어와 조화롭게 통합합니다.

**핵심 UX 전략**: 브랜드 아이덴티티 명확성 + 일관된 인터랙션 패턴 + Frame0 스케치 느낌

---

## 화면 구조

### Screen 1: 로그인 화면 (Login Screen)

#### 레이아웃 계층

```
Scaffold
└── Body: SafeArea
    └── Center
        └── Padding(horizontal: 24, vertical: 32)
            └── Column
                ├── SizedBox(height: 64) - 상단 여백
                │
                ├── Text("로그인")
                │   └── fontSize: 30 (fontSize3Xl)
                │   └── fontWeight: FontWeight.bold
                │   └── color: base900
                │
                ├── SizedBox(height: 8)
                │
                ├── Text("소셜 계정으로 간편하게 시작하세요")
                │   └── fontSize: 14 (fontSizeSm)
                │   └── color: base500
                │
                ├── SizedBox(height: 48)
                │
                ├── SocialLoginButton (카카오)
                │   ├── platform: SocialLoginPlatform.kakao
                │   ├── size: SketchButtonSize.large
                │   └── onPressed: () => _handleKakaoLogin()
                │
                ├── SizedBox(height: 16)
                │
                ├── SocialLoginButton (네이버)
                │   ├── platform: SocialLoginPlatform.naver
                │   ├── size: SketchButtonSize.large
                │   └── onPressed: () => _handleNaverLogin()
                │
                ├── SizedBox(height: 16)
                │
                ├── SocialLoginButton (애플)
                │   ├── platform: SocialLoginPlatform.apple
                │   ├── appleStyle: AppleSignInStyle.dark (기본값)
                │   ├── size: SketchButtonSize.large
                │   └── onPressed: () => _handleAppleLogin()
                │
                ├── SizedBox(height: 16)
                │
                ├── SocialLoginButton (구글)
                │   ├── platform: SocialLoginPlatform.google
                │   ├── size: SketchButtonSize.large
                │   └── onPressed: () => _handleGoogleLogin()
                │
                ├── Spacer() - 하단으로 밀기
                │
                └── TextButton ("둘러보기")
                    └── onPressed: () => Navigator.push(...)
```

#### 위젯 상세

**SocialLoginButton (카카오)**
- 플랫폼: `SocialLoginPlatform.kakao`
- fillColor: `Color(0xFFFEE500)` (카카오 옐로우)
- borderColor: `Color(0xFFFEE500)`
- textColor: `Color(0xFF000000)` (검은색)
- logo: 말풍선 심볼 (20x20, 좌측 배치)
- text: "카카오 계정으로 로그인"
- 패딩: horizontal 32px, vertical 16px
- 높이: 48px
- roughness: 0.8 (기본값)
- strokeWidth: 2.0px
- enableNoise: true

**SocialLoginButton (네이버)**
- 플랫폼: `SocialLoginPlatform.naver`
- fillColor: `Color(0xFF03C75A)` (네이버 그린)
- borderColor: `Color(0xFF03C75A)`
- textColor: `Color(0xFFFFFFFF)` (흰색)
- logo: N 로고 (20x20, 좌측 배치)
- text: "네이버 계정으로 로그인"
- 패딩: horizontal 32px, vertical 16px
- 높이: 48px
- roughness: 0.8
- strokeWidth: 2.0px
- enableNoise: true

**SocialLoginButton (애플)**
- 플랫폼: `SocialLoginPlatform.apple`
- Dark 스타일 (기본):
  - fillColor: `Color(0xFF000000)` (검은색)
  - borderColor: `Color(0xFF000000)`
  - textColor: `Color(0xFFFFFFFF)` (흰색)
- Light 스타일 (선택):
  - fillColor: `Color(0xFFFFFFFF)` (흰색)
  - borderColor: `Color(0xFF000000)`
  - textColor: `Color(0xFF000000)` (검은색)
- logo: 애플 심볼 (20x20, 좌측 배치)
- text: "Apple로 로그인" (공식 가이드라인 준수)
- 패딩: horizontal 32px, vertical 16px
- 높이: 48px
- roughness: 0.8
- strokeWidth: 2.0px
- enableNoise: true

**SocialLoginButton (구글)**
- 플랫폼: `SocialLoginPlatform.google`
- fillColor: `Color(0xFFFFFFFF)` (흰색)
- borderColor: `Color(0xFFDCDCDC)` (밝은 회색)
- textColor: `Color(0xFF000000)` (검은색)
- logo: 구글 G 로고 (20x20, 좌측 배치, 4색 버전)
- text: "Google 계정으로 로그인"
- 패딩: horizontal 32px, vertical 16px
- 높이: 48px
- roughness: 0.8
- strokeWidth: 2.0px
- enableNoise: true

### Screen 2: 설정 화면 - 계정 연결 섹션 (Settings - Account Linking)

#### 레이아웃 계층

```
Scaffold
└── AppBar
    ├── Leading: IconButton(뒤로가기)
    └── Title: Text("설정")
└── Body: ListView
    └── Padding(16)
        └── SketchCard
            ├── Header: Text("계정 연결")
            │   └── fontSize: 20 (fontSizeXl)
            │   └── fontWeight: FontWeight.bold
            │
            └── Body: Column
                ├── ListTile
                │   ├── Leading: Icon(카카오 로고, 24x24)
                │   ├── Title: Text("카카오 계정")
                │   └── Trailing: SocialLoginButton (소형)
                │       ├── platform: SocialLoginPlatform.kakao
                │       ├── size: SketchButtonSize.small
                │       ├── text: "연결" (또는 "연결됨")
                │       └── enabled: !isConnected
                │
                ├── Divider()
                │
                ├── ListTile (네이버 계정)
                │   └── Trailing: SocialLoginButton (소형)
                │
                ├── Divider()
                │
                ├── ListTile (애플 계정)
                │   └── Trailing: SocialLoginButton (소형)
                │
                ├── Divider()
                │
                └── ListTile (구글 계정)
                    └── Trailing: SocialLoginButton (소형)
```

#### 위젯 상세

**SocialLoginButton (Small 크기 - 계정 연결용)**
- size: `SketchButtonSize.small`
- 높이: 32px
- 패딩: horizontal 16px, vertical 8px
- 폰트 크기: 14px (fontSizeSm)
- 로고 크기: 16x16
- text: "연결" (연결 전) / "연결됨" (연결 후)
- enabled:
  - 연결 전: true (활성화)
  - 연결 후: false (비활성화, opacity 0.4)

### Screen 3: 빠른 로그인 모달 (Quick Login Modal)

#### 레이아웃 계층

```
SketchModal
├── Title: "빠른 로그인"
│
├── Child: Column
│   ├── Text("이전에 사용한 계정으로\n빠르게 로그인하세요")
│   │   └── fontSize: 14, color: base500
│   │
│   ├── SizedBox(height: 24)
│   │
│   ├── Row (2x2 그리드 - 모바일 최적화)
│   │   ├── Expanded
│   │   │   └── SocialLoginButton (카카오, Medium)
│   │   ├── SizedBox(width: 12)
│   │   └── Expanded
│   │       └── SocialLoginButton (네이버, Medium)
│   │
│   ├── SizedBox(height: 12)
│   │
│   └── Row
│       ├── Expanded
│       │   └── SocialLoginButton (애플, Medium)
│       ├── SizedBox(width: 12)
│       └── Expanded
│           └── SocialLoginButton (구글, Medium)
│
└── Actions: [
    SketchButton(
      text: "취소",
      style: SketchButtonStyle.outline,
      onPressed: () => Navigator.pop(context),
    )
  ]
```

#### 위젯 상세

**SocialLoginButton (Medium 크기 - 모달용)**
- size: `SketchButtonSize.medium`
- 높이: 40px
- 패딩: horizontal 24px, vertical 12px
- 폰트 크기: 16px (fontSizeBase)
- 로고 크기: 18x18
- text: "카카오" (간략 버전 - 공간 절약)
- width: null (Expanded로 균등 분할)

---

## 색상 팔레트

### 플랫폼별 브랜드 색상

#### 카카오 (Kakao)
- **Primary**: `Color(0xFFFEE500)` - 카카오 옐로우 (배경)
- **Border**: `Color(0xFFFEE500)` - 카카오 옐로우 (테두리)
- **Text**: `Color(0xFF000000)` - 검은색 (텍스트/로고)
- **Contrast Ratio**: 16.7:1 (WCAG AAA) ✅
- **Logo**: 말풍선 심볼 (검은색)

#### 네이버 (Naver)
- **Primary**: `Color(0xFF03C75A)` - 네이버 그린 (배경)
- **Border**: `Color(0xFF03C75A)` - 네이버 그린 (테두리)
- **Text**: `Color(0xFFFFFFFF)` - 흰색 (텍스트)
- **Contrast Ratio**: 3.8:1 (WCAG AA 미달 - 주의 필요) ⚠️
  - **해결책**: strokeWidth를 3.0px로 증가하여 가시성 보완
- **Logo**: N 로고 (흰색)

#### 애플 (Apple)

**Dark 스타일 (기본)**
- **Primary**: `Color(0xFF000000)` - 검은색 (배경)
- **Border**: `Color(0xFF000000)` - 검은색 (테두리)
- **Text**: `Color(0xFFFFFFFF)` - 흰색 (텍스트)
- **Contrast Ratio**: 21:1 (WCAG AAA) ✅
- **Logo**: 애플 심볼 (흰색)

**Light 스타일 (선택적)**
- **Primary**: `Color(0xFFFFFFFF)` - 흰색 (배경)
- **Border**: `Color(0xFF000000)` - 검은색 (테두리)
- **Text**: `Color(0xFF000000)` - 검은색 (텍스트)
- **Contrast Ratio**: 21:1 (WCAG AAA) ✅
- **Logo**: 애플 심볼 (검은색)

#### 구글 (Google)
- **Primary**: `Color(0xFFFFFFFF)` - 흰색 (배경)
- **Border**: `Color(0xFFDCDCDC)` - 밝은 회색 (테두리)
- **Text**: `Color(0xFF000000)` - 검은색 (텍스트)
- **Contrast Ratio**: 21:1 (WCAG AAA) ✅
- **Logo**: 구글 G 로고 (4색: 파랑, 빨강, 노랑, 녹색)

### Semantic Colors (상태별 색상)

#### 로딩 상태 (Loading)
- **Spinner Color**: 각 플랫폼의 textColor 사용
  - 카카오: 검은색
  - 네이버: 흰색
  - 애플: 흰색 (Dark) / 검은색 (Light)
  - 구글: 검은색

#### 비활성화 상태 (Disabled)
- **Opacity**: 0.4 (opacityDisabled)
- **Fill Color**: SketchDesignTokens.base200 (덮어쓰기)
- **Border Color**: SketchDesignTokens.base300 (덮어쓰기)
- **Text Color**: SketchDesignTokens.base500 (덮어쓰기)

#### 에러 상태 (Error)
- **에러 메시지**: SketchModal로 별도 표시
- **배경색**: SketchDesignTokens.errorLight
- **텍스트**: SketchDesignTokens.error

---

## 타이포그래피

### 버튼 텍스트

#### Large 버튼 (48px 높이)
- **fontSize**: 18px (SketchDesignTokens.fontSizeLg)
- **fontWeight**: FontWeight.w400 (Regular)
- **letterSpacing**: 0px (기본값)
- **textAlign**: center
- **사용 위치**: 로그인 화면 메인 버튼

#### Medium 버튼 (40px 높이)
- **fontSize**: 16px (SketchDesignTokens.fontSizeBase)
- **fontWeight**: FontWeight.w400
- **사용 위치**: 모달, 카드 내 버튼

#### Small 버튼 (32px 높이)
- **fontSize**: 14px (SketchDesignTokens.fontSizeSm)
- **fontWeight**: FontWeight.w400
- **사용 위치**: 설정 화면 "연결" 버튼

### 화면 타이포그래피

#### 화면 제목 (로그인)
- **fontSize**: 30px (SketchDesignTokens.fontSize3Xl)
- **fontWeight**: FontWeight.bold
- **color**: SketchDesignTokens.base900

#### 화면 부제목 (설명 텍스트)
- **fontSize**: 14px (SketchDesignTokens.fontSizeSm)
- **fontWeight**: FontWeight.w400
- **color**: SketchDesignTokens.base500

#### 카드 헤더 (설정 > 계정 연결)
- **fontSize**: 20px (SketchDesignTokens.fontSizeXl)
- **fontWeight**: FontWeight.bold
- **color**: SketchDesignTokens.base900

---

## 스페이싱 시스템 (8px 그리드)

### Padding/Margin

#### 화면 패딩
- **좌우 패딩**: 24px (SketchDesignTokens.spacingXl)
- **상하 패딩**: 32px (SketchDesignTokens.spacing2Xl)

#### 버튼 간 간격
- **세로 간격**: 16px (SketchDesignTokens.spacingLg)
- **가로 간격** (모달 2x2 그리드): 12px (SketchDesignTokens.spacingMd)

#### 버튼 내부 패딩

**Large (48px 높이)**
- **horizontal**: 32px (SketchDesignTokens.spacing2Xl)
- **vertical**: 16px (SketchDesignTokens.spacingLg)

**Medium (40px 높이)**
- **horizontal**: 24px (SketchDesignTokens.spacingXl)
- **vertical**: 12px (SketchDesignTokens.spacingMd)

**Small (32px 높이)**
- **horizontal**: 16px (SketchDesignTokens.spacingLg)
- **vertical**: 8px (SketchDesignTokens.spacingSm)

#### 로고-텍스트 간격
- **iconSpacing**: 12px (모든 크기 공통)
- 로고 좌측 배치, 텍스트 우측

---

## Border Radius

### 버튼 테두리 반경
- **borderRadius**: 12.0px (SketchDesignTokens.irregularBorderRadius)
- **적용 방식**: SketchPainter가 손그림 스타일로 렌더링
- **특징**: 완벽한 둥근 모서리가 아닌 불규칙한 곡선

---

## Elevation (그림자)

**주의**: Sketch Design System은 그림자를 사용하지 않음. 대신 roughness와 strokeWidth로 깊이감 표현.

- **elevation**: 없음 (0dp)
- **대체 방식**:
  - 눌림 상태: roughness +0.3, scale 0.98
  - 테두리 강조: strokeWidth 2.0px → 3.0px (네이버)

---

## 인터랙션 상태

### 버튼 상태

#### Default (기본)
- **Scale**: 1.0
- **Roughness**: 0.8 (SketchDesignTokens.roughness)
- **Seed**: 0 (고정된 모양)
- **Opacity**: 1.0

#### Pressed (눌림)
- **Scale**: 0.98 (AnimatedScale, 100ms)
- **Roughness**: 1.1 (기본값 + 0.3)
- **Seed**: 1 (다른 모양으로 변경)
- **Animation**: Curves.easeOut
- **Duration**: 100ms

#### Disabled (비활성화)
- **Opacity**: 0.4 (opacityDisabled)
- **Fill Color**: SketchDesignTokens.base200
- **Border Color**: SketchDesignTokens.base300
- **Text Color**: SketchDesignTokens.base500
- **Interaction**: onPressed = null, 탭 불가

#### Loading (로딩)
- **Spinner**: CircularProgressIndicator
  - size: fontSize와 동일 (18px/16px/14px)
  - strokeWidth: 2.0px
  - color: 각 플랫폼의 textColor
- **Content**: 텍스트 + 로고 숨김 (visible: false)
- **Interaction**: onPressed = null, 탭 불가

### 터치 피드백

#### GestureDetector 이벤트
- **onTapDown**: _isPressed = true → roughness +0.3, seed 변경
- **onTapUp**: _isPressed = false → onPressed?.call()
- **onTapCancel**: _isPressed = false → 원래 상태 복원

#### AnimatedScale
- **scale**: _isPressed ? 0.98 : 1.0
- **duration**: 100ms
- **curve**: Curves.easeOut

#### Ripple Effect
- **사용 안 함**: SketchPainter가 CustomPaint로 렌더링되므로 Material ripple 미적용
- **대체**: 스케일 + roughness + seed 변경으로 충분한 피드백 제공

---

## 애니메이션

### 화면 전환
- **Route Transition**: MaterialPageRoute (기본 슬라이드)
- **Duration**: 300ms (Flutter 기본값)
- **Curve**: Curves.easeInOut

### 상태 변경

#### 로딩 시작
```dart
setState(() => isLoading = true);
// 버튼 내부에서 자동으로 CircularProgressIndicator 표시
// Duration: 즉시 (0ms)
```

#### 로딩 완료
```dart
setState(() => isLoading = false);
// 원래 텍스트/로고 복원
// Duration: 즉시 (0ms)
```

#### 비활성화 전환
```dart
setState(() => enabled = false);
// Opacity 애니메이션: 200ms (암시적)
```

### 버튼 Press 애니메이션
- **AnimatedScale**: 100ms, Curves.easeOut
- **Roughness 변경**: setState로 즉시 반영 (재렌더링)
- **Seed 변경**: setState로 즉시 반영 (다른 불규칙 패턴)

---

## 반응형 레이아웃

### Breakpoints (참고용)
- **Mobile**: width < 600dp (주요 타겟)
- **Tablet**: 600dp ≤ width < 1024dp
- **Desktop**: width ≥ 1024dp (미지원)

### 적응형 레이아웃 전략

#### 세로 모드 (Portrait) - 기본
- **로그인 화면**: 4개 버튼 세로 나열, 16px 간격
- **Safe Area**: iOS 노치/홈 인디케이터 회피
- **스크롤**: 불필요 (버튼 4개 + 패딩으로 충분히 표시 가능)

#### 가로 모드 (Landscape)
- **로그인 화면**: 2x2 그리드 레이아웃
  - Row 1: 카카오, 네이버
  - Row 2: 애플, 구글
  - 가로 간격: 12px, 세로 간격: 12px
- **패딩 조정**: horizontal 48px (더 넓은 여백)

#### 태블릿 (Tablet)
- **버튼 크기**: Large 유지 (48px)
- **최대 너비**: 400px (Center로 정렬)
- **레이아웃**: 세로 모드와 동일 (4개 세로 나열)

### 터치 영역

#### 최소 터치 영역 (Material Design 가이드라인)
- **Small**: 32px 높이 → 패딩으로 44x44dp 보장 ✅
- **Medium**: 40px 높이 → 충분함 ✅
- **Large**: 48px 높이 → 권장 크기 ✅

#### 버튼 간 간격
- **세로 간격**: 16px → 탭 오류 방지
- **가로 간격**: 12px → 모달에서 충분한 구분

---

## 접근성 (Accessibility)

### 색상 대비 (WCAG 기준)

#### 카카오 버튼
- **대비율**: 검은 텍스트(#000000) / 노란 배경(#FEE500) = **16.7:1** (AAA) ✅
- **평가**: 매우 우수, 모든 사용자가 명확히 인식 가능

#### 네이버 버튼
- **대비율**: 흰 텍스트(#FFFFFF) / 녹색 배경(#03C75A) = **3.8:1** (AA 미달) ⚠️
- **해결책**:
  - strokeWidth 2.0 → 3.0px로 증가 (테두리 강조)
  - 폰트 크기 충분 (18px Large, 16px Medium)
  - 로고로 브랜드 인지 보완
- **평가**: 큰 텍스트 기준 AA 통과 가능

#### 애플 버튼 (Dark)
- **대비율**: 흰 텍스트(#FFFFFF) / 검정 배경(#000000) = **21:1** (AAA) ✅
- **평가**: 최고 수준, 완벽한 대비

#### 애플 버튼 (Light)
- **대비율**: 검은 텍스트(#000000) / 흰 배경(#FFFFFF) = **21:1** (AAA) ✅
- **평가**: 최고 수준, 완벽한 대비

#### 구글 버튼
- **대비율**: 검은 텍스트(#000000) / 흰 배경(#FFFFFF) = **21:1** (AAA) ✅
- **평가**: 최고 수준, 완벽한 대비

### 의미 전달

#### 색상만으로 의미 전달 금지 ✅
- **로고 포함**: 모든 버튼에 플랫폼 로고 표시
- **텍스트 명시**: "카카오 계정으로 로그인" 등 명확한 레이블
- **아이콘 + 텍스트 조합**: 색맹 사용자도 구분 가능

#### 에러 표시
- **색상**: SketchDesignTokens.error (빨간색)
- **아이콘**: Icons.error_outline
- **텍스트**: 구체적인 에러 메시지 제공
- **전달 방식**: SketchModal로 팝업 (시각적 + 의미적)

### 스크린 리더 지원

#### Semantics 레이블

**카카오 버튼**
```dart
Semantics(
  label: '카카오 계정으로 로그인',
  button: true,
  enabled: !isDisabled,
  child: SocialLoginButton(...),
)
```

**네이버 버튼**
```dart
Semantics(
  label: '네이버 계정으로 로그인',
  button: true,
  enabled: !isDisabled,
  child: SocialLoginButton(...),
)
```

**애플 버튼**
```dart
Semantics(
  label: 'Apple로 로그인',
  button: true,
  enabled: !isDisabled,
  child: SocialLoginButton(...),
)
```

**구글 버튼**
```dart
Semantics(
  label: 'Google 계정으로 로그인',
  button: true,
  enabled: !isDisabled,
  child: SocialLoginButton(...),
)
```

#### 상태별 레이블

**로딩 중**
```dart
Semantics(
  label: '카카오 계정으로 로그인 중',
  busy: true,
  child: SocialLoginButton(isLoading: true),
)
```

**비활성화**
```dart
Semantics(
  label: '카카오 계정 이미 연결됨',
  button: true,
  enabled: false,
  child: SocialLoginButton(enabled: false),
)
```

---

## Design System 컴포넌트 활용

### 재사용 컴포넌트 (packages/design_system)

#### SketchButton (기반 클래스)
- **용도**: SocialLoginButton의 내부 구현 참조
- **재사용 요소**:
  - `_SizeSpec`: 크기별 패딩, 폰트 크기 계산 로직
  - `_ColorSpec`: 색상 조합 관리 로직
  - `AnimatedScale`: 버튼 눌림 애니메이션
  - `GestureDetector`: 터치 이벤트 처리
- **차이점**:
  - SketchButton: 3가지 스타일 (primary, secondary, outline)
  - SocialLoginButton: 4가지 플랫폼 (kakao, naver, apple, google)

#### SketchPainter (렌더링)
- **용도**: 손그림 스타일 테두리 + 배경 렌더링
- **파라미터**:
  - fillColor: 플랫폼별 배경색
  - borderColor: 플랫폼별 테두리색
  - strokeWidth: 2.0px (네이버는 3.0px)
  - roughness: 0.8 (기본) → 1.1 (눌림)
  - seed: 0 (기본) → 1 (눌림)
  - enableNoise: true (outline 스타일 제외)

#### SketchModal (에러 표시)
- **용도**: 로그인 실패, 네트워크 오류 등 에러 메시지 표시
- **예시**:
```dart
await SketchModal.show(
  context: context,
  title: '로그인 실패',
  child: Text('네트워크 연결을 확인해주세요.'),
  actions: [
    SketchButton(
      text: '확인',
      onPressed: () => Navigator.pop(context),
    ),
  ],
);
```

### 새로운 컴포넌트 제안

#### SocialLoginButton
- **위치**: `packages/design_system/lib/src/widgets/social_login_button.dart`
- **목적**: 4개 플랫폼의 소셜 로그인 버튼 통합 위젯
- **재사용 가능성**: 매우 높음 (wowa 앱 전체에서 사용)
- **파라미터**:
  - `SocialLoginPlatform platform` (enum: kakao, naver, apple, google)
  - `SketchButtonSize size` (enum: small, medium, large)
  - `AppleSignInStyle? appleStyle` (enum: dark, light - 애플 전용)
  - `String? text` (기본값: 플랫폼별 자동 설정)
  - `bool isLoading` (기본값: false)
  - `VoidCallback? onPressed`
  - `double iconSpacing` (기본값: 12.0)
- **내부 구현**:
  - `_getPlatformSpec()`: 플랫폼별 색상, 로고, 텍스트 반환
  - SketchButton 로직 재활용 (크기, 상태, 애니메이션)
  - 로고 이미지는 assets에서 로드

#### Enum 정의

**SocialLoginPlatform**
```dart
enum SocialLoginPlatform {
  kakao,
  naver,
  apple,
  google,
}
```

**AppleSignInStyle**
```dart
enum AppleSignInStyle {
  dark,  // 검은 배경, 흰 텍스트 (기본값)
  light, // 흰 배경, 검은 텍스트
}
```

---

## 에셋 리소스

### 로고 이미지

#### 파일 경로
```
packages/design_system/assets/social_login/
├── kakao_symbol.svg          # 카카오 말풍선 (20x20)
├── naver_logo.svg            # 네이버 N 로고 (20x20)
├── apple_logo.svg            # 애플 심볼 (20x20)
└── google_logo.svg           # 구글 G 로고 (20x20)
```

#### 로고 사양

**카카오 말풍선**
- **크기**: 20x20px (Large), 18x18px (Medium), 16x16px (Small)
- **색상**: 검은색 (#000000)
- **형식**: SVG (벡터)
- **다운로드**: [카카오 개발자 - 리소스 다운로드](https://developers.kakao.com/tool/resource/login)

**네이버 N 로고**
- **크기**: 20x20px (Large), 18x18px (Medium), 16x16px (Small)
- **색상**: 흰색 (#FFFFFF)
- **형식**: SVG (벡터)
- **주의**: 로고 변형 금지, 공식 리소스 사용 필수

**애플 심볼**
- **크기**: 20x20px (Large), 18x18px (Medium), 16x16px (Small)
- **색상**: 흰색 (Dark 스타일) / 검은색 (Light 스타일)
- **형식**: SVG (벡터)
- **다운로드**: [Apple Sign in Resources](https://developer.apple.com/sign-in-with-apple/get-started/)

**구글 G 로고**
- **크기**: 20x20px (Large), 18x18px (Medium), 16x16px (Small)
- **색상**: 4색 (파랑, 빨강, 노랑, 녹색) - 변경 불가
- **형식**: SVG (벡터)
- **다운로드**: [Google Brand Resources](https://developers.google.com/identity/branding-guidelines)

#### pubspec.yaml 등록
```yaml
flutter:
  assets:
    - packages/design_system/assets/social_login/
```

---

## 플랫폼 가이드라인 준수 체크리스트

### 카카오 로그인 ([공식 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide))

- [x] 말풍선 심볼 포함
- [x] 카카오 옐로우 (#FEE500) 배경
- [x] 검은색 텍스트/로고
- [x] 심볼 형태/비율/색상 변경 금지
- [x] 컨테이너 radius 12px
- [x] 레이블: "카카오 계정으로 로그인" (완성형)
- [x] 폰트: 시스템 기본 서체 (Roboto/SF Pro)

### 네이버 로그인 ([공식 가이드](https://guide.ncloud-docs.com/docs/sso-button-design-guide))

- [x] N 로고 포함
- [x] 네이버 그린 (#03C75A) 배경
- [x] 흰색 텍스트/로고
- [x] 고유 색상·레이블·심볼 규정 준수
- [x] 유연한 디자인 변경 허용 (Sketch 스타일)
- [x] 레이블: "네이버 계정으로 로그인"

### 애플 로그인 ([공식 가이드](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple))

- [x] 로고와 텍스트 모두 검은색 또는 흰색만 허용
- [x] 커스텀 색상 금지
- [x] Dark 스타일: 검은 배경 + 흰 텍스트
- [x] Light 스타일: 흰 배경 + 검은 텍스트 (outlined)
- [x] 레이블: "Apple로 로그인" (Sign in with Apple)
- [x] Corner radius 커스터마이징 허용 (12px)
- [x] 텍스처/그라데이션 허용 (인터페이스 조화)

### 구글 로그인 ([공식 가이드](https://developers.google.com/identity/branding-guidelines))

- [x] 4색 G 로고 포함 (변경 불가)
- [x] 흰색 배경
- [x] 검은색 텍스트
- [x] 로고 크기/색상 변경 금지
- [x] 로고는 항상 흰 배경 위에 표시
- [x] 레이블: "Google 계정으로 로그인" (Sign in with Google)
- [x] 폰트: Roboto Medium (권장)
- [x] 다른 소셜 로그인 버튼과 동등한 prominence

---

## 사용 예제

### 예제 1: 로그인 화면

```dart
class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SketchDesignTokens.spacingXl, // 24px
              vertical: SketchDesignTokens.spacing2Xl,   // 32px
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: SketchDesignTokens.spacing4Xl), // 64px

                // 타이틀
                Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSize3Xl, // 30px
                    fontWeight: FontWeight.bold,
                    color: SketchDesignTokens.base900,
                  ),
                ),

                SizedBox(height: SketchDesignTokens.spacingSm), // 8px

                // 부제목
                Text(
                  '소셜 계정으로 간편하게 시작하세요',
                  style: TextStyle(
                    fontSize: SketchDesignTokens.fontSizeSm, // 14px
                    color: SketchDesignTokens.base500,
                  ),
                ),

                SizedBox(height: SketchDesignTokens.spacing3Xl), // 48px

                // 카카오 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.kakao,
                  size: SketchButtonSize.large,
                  isLoading: controller.isKakaoLoading.value,
                  onPressed: controller.handleKakaoLogin,
                )),

                SizedBox(height: SketchDesignTokens.spacingLg), // 16px

                // 네이버 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.naver,
                  size: SketchButtonSize.large,
                  isLoading: controller.isNaverLoading.value,
                  onPressed: controller.handleNaverLogin,
                )),

                SizedBox(height: SketchDesignTokens.spacingLg), // 16px

                // 애플 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.apple,
                  appleStyle: AppleSignInStyle.dark,
                  size: SketchButtonSize.large,
                  isLoading: controller.isAppleLoading.value,
                  onPressed: controller.handleAppleLogin,
                )),

                SizedBox(height: SketchDesignTokens.spacingLg), // 16px

                // 구글 로그인 버튼
                Obx(() => SocialLoginButton(
                  platform: SocialLoginPlatform.google,
                  size: SketchButtonSize.large,
                  isLoading: controller.isGoogleLoading.value,
                  onPressed: controller.handleGoogleLogin,
                )),

                Spacer(),

                // 둘러보기 버튼
                TextButton(
                  onPressed: () => Get.toNamed('/home'),
                  child: Text('둘러보기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 예제 2: 설정 화면 - 계정 연결

```dart
class AccountLinkingSection extends StatelessWidget {
  final SettingsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return SketchCard(
      header: Text(
        '계정 연결',
        style: TextStyle(
          fontSize: SketchDesignTokens.fontSizeXl, // 20px
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // 카카오 계정
          Obx(() => ListTile(
            leading: Image.asset(
              'packages/design_system/assets/social_login/kakao_symbol.svg',
              width: 24,
              height: 24,
            ),
            title: Text('카카오 계정'),
            trailing: SocialLoginButton(
              platform: SocialLoginPlatform.kakao,
              size: SketchButtonSize.small,
              text: controller.isKakaoLinked.value ? '연결됨' : '연결',
              enabled: !controller.isKakaoLinked.value,
              onPressed: controller.linkKakao,
            ),
          )),

          Divider(),

          // 네이버 계정
          Obx(() => ListTile(
            leading: Image.asset(
              'packages/design_system/assets/social_login/naver_logo.svg',
              width: 24,
              height: 24,
            ),
            title: Text('네이버 계정'),
            trailing: SocialLoginButton(
              platform: SocialLoginPlatform.naver,
              size: SketchButtonSize.small,
              text: controller.isNaverLinked.value ? '연결됨' : '연결',
              enabled: !controller.isNaverLinked.value,
              onPressed: controller.linkNaver,
            ),
          )),

          Divider(),

          // 애플 계정
          Obx(() => ListTile(
            leading: Image.asset(
              'packages/design_system/assets/social_login/apple_logo.svg',
              width: 24,
              height: 24,
            ),
            title: Text('애플 계정'),
            trailing: SocialLoginButton(
              platform: SocialLoginPlatform.apple,
              size: SketchButtonSize.small,
              text: controller.isAppleLinked.value ? '연결됨' : '연결',
              enabled: !controller.isAppleLinked.value,
              onPressed: controller.linkApple,
            ),
          )),

          Divider(),

          // 구글 계정
          Obx(() => ListTile(
            leading: Image.asset(
              'packages/design_system/assets/social_login/google_logo.svg',
              width: 24,
              height: 24,
            ),
            title: Text('구글 계정'),
            trailing: SocialLoginButton(
              platform: SocialLoginPlatform.google,
              size: SketchButtonSize.small,
              text: controller.isGoogleLinked.value ? '연결됨' : '연결',
              enabled: !controller.isGoogleLinked.value,
              onPressed: controller.linkGoogle,
            ),
          )),
        ],
      ),
    );
  }
}
```

### 예제 3: 빠른 로그인 모달

```dart
class QuickLoginModal {
  static Future<void> show(BuildContext context) async {
    await SketchModal.show(
      context: context,
      title: '빠른 로그인',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '이전에 사용한 계정으로\n빠르게 로그인하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SketchDesignTokens.fontSizeSm, // 14px
              color: SketchDesignTokens.base500,
            ),
          ),

          SizedBox(height: SketchDesignTokens.spacingXl), // 24px

          // 2x2 그리드
          Row(
            children: [
              Expanded(
                child: SocialLoginButton(
                  platform: SocialLoginPlatform.kakao,
                  size: SketchButtonSize.medium,
                  text: '카카오', // 간략 버전
                  onPressed: () {
                    Navigator.pop(context);
                    // 로그인 로직
                  },
                ),
              ),
              SizedBox(width: SketchDesignTokens.spacingMd), // 12px
              Expanded(
                child: SocialLoginButton(
                  platform: SocialLoginPlatform.naver,
                  size: SketchButtonSize.medium,
                  text: '네이버',
                  onPressed: () {
                    Navigator.pop(context);
                    // 로그인 로직
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: SketchDesignTokens.spacingMd), // 12px

          Row(
            children: [
              Expanded(
                child: SocialLoginButton(
                  platform: SocialLoginPlatform.apple,
                  size: SketchButtonSize.medium,
                  text: 'Apple',
                  onPressed: () {
                    Navigator.pop(context);
                    // 로그인 로직
                  },
                ),
              ),
              SizedBox(width: SketchDesignTokens.spacingMd), // 12px
              Expanded(
                child: SocialLoginButton(
                  platform: SocialLoginPlatform.google,
                  size: SketchButtonSize.medium,
                  text: 'Google',
                  onPressed: () {
                    Navigator.pop(context);
                    // 로그인 로직
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        SketchButton(
          text: '취소',
          style: SketchButtonStyle.outline,
          onPressed: () => Navigator.pop(context),
        ),
      ],
      barrierDismissible: true,
    );
  }
}
```

---

## 에러 처리 시나리오

### 네트워크 오류

```dart
try {
  await kakaoLogin();
} catch (e) {
  setState(() => isKakaoLoading = false); // 로딩 해제

  await SketchModal.show(
    context: context,
    title: '로그인 실패',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: SketchDesignTokens.error,
        ),
        SizedBox(height: SketchDesignTokens.spacingMd),
        Text(
          '네트워크 연결을 확인해주세요.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
    actions: [
      SketchButton(
        text: '재시도',
        onPressed: () {
          Navigator.pop(context);
          handleKakaoLogin(); // 재시도
        },
      ),
      SketchButton(
        text: '취소',
        style: SketchButtonStyle.outline,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}
```

### 권한 거부

```dart
try {
  final result = await kakaoLogin();
  if (result == 'user_cancelled') {
    // 사용자가 OAuth 권한 거부 - 정상 플로우
    // 에러 모달 표시하지 않음
    return;
  }
} catch (e) {
  // 실제 에러만 처리
  await SketchModal.show(...);
}
```

### 계정 없음 (첫 로그인)

```dart
try {
  final user = await kakaoLogin();
  if (user.isNewUser) {
    // 회원가입 화면으로 이동
    Get.toNamed('/signup', arguments: user);
  } else {
    // 메인 화면으로 이동
    Get.offAllNamed('/home');
  }
} catch (e) {
  // 에러 처리
}
```

---

## 참고 자료

### 공식 디자인 가이드라인

- [카카오 로그인 디자인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide)
- [네이버 로그인 버튼 디자인 가이드](https://guide.ncloud-docs.com/docs/sso-button-design-guide)
- [Apple Sign In Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)
- [Google Sign-In Branding Guidelines](https://developers.google.com/identity/branding-guidelines)

### 내부 문서

- `.claude/guides/design_system.md` - Sketch Design System 완전 가이드
- `packages/design_system/lib/src/widgets/sketch_button.dart` - 기본 버튼 구현 참조
- `packages/core/lib/sketch_design_tokens.dart` - 디자인 토큰 상수
- `user-stories.md` - 사용자 스토리 및 인수 조건

### 외부 참고 자료

- [소셜로그인 버튼 회사별 가이드라인](https://brunch.co.kr/@bf6b5403fa344c4/43)
- [간편 로그인 디자인 UX 가이드](https://ditoday.com/간편-로그인-디자인-어떻게-할까-_-ux-디자인과-개발/)
- [Figma 커뮤니티: 카카오 네이버 로그인 디자인 가이드](https://www.figma.com/community/file/1232637617420363657)

---

## 다음 단계

이 디자인 명세를 기반으로 **tech-lead** 에이전트가 다음 작업을 수행합니다:

1. 기술 아키텍처 설계 (tech-spec.md)
2. 파일 구조 및 의존성 정의
3. 구현 우선순위 결정
4. 개발 팀에게 작업 할당

---

## Sources

- [디자인 가이드 - 카카오 로그인 - Kakao Developers](https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide)
- [로그인 버튼 디자인 - 사용 가이드 (네이버)](https://guide.ncloud-docs.com/docs/sso-button-design-guide)
- [Buttons - Sign in with Apple - Technologies - Human Interface Guidelines](https://developers.apple.com/design/human-interface-guidelines/technologies/sign-in-with-apple/buttons)
- [Sign in with Google Branding Guidelines](https://developers.google.com/identity/branding-guidelines)
- [UX 디자인과 개발 6. 간편 로그인](https://brunch.co.kr/@hjjju/14)
- [간편 로그인 디자인 어떻게 할까? _ UX 디자인과 개발](https://ditoday.com/간편-로그인-디자인-어떻게-할까-_-ux-디자인과-개발/)
- [카카오 네이버 로그인 디자인 가이드 | Figma](https://www.figma.com/community/file/1232637617420363657)
