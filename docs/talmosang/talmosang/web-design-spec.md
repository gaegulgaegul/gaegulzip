# UI/UX 디자인 명세: 탈모상 (Hair Loss Fortune Telling)

## 개요

"탈모상"은 Al Murphy 웹사이트 스타일에서 영감을 받아 손글씨 폰트, 크림/베이지 배경, 장난스러운 낙서 감성을 활용한 바이럴 웹앱입니다. "진지한 척 하면서 전혀 진지하지 않은" 사극 말투로 사용자에게 재미있는 탈모 관상 결과를 제공하며, 즉각적인 공유를 유도합니다.

**디자인 목표**: 의도적으로 완벽하지 않은(살짝 기울어진) 레이아웃과 종이 텍스처, 손그림 데코레이션으로 따뜻하고 인간적인 느낌을 전달하여 바이럴 확산을 극대화합니다.

**핵심 UX 전략**: 단일 페이지에서 상태 전환(업로드 → 로딩 → 결과)으로 매끄러운 경험 제공, 모바일 우선 설계.

---

## 화면 구조

이 앱은 **단일 페이지**에서 3가지 상태로 전환됩니다:
1. **UploadSection** (메인 업로드)
2. **LoadingSection** (분석 중)
3. **ResultSection** (결과 화면)

### 전체 레이아웃 구조

```
<body> (노이즈 텍스처 오버레이)
└── <main className="container">
    ├── <header>
    │   └── AppTitle (탈모상 - 손글씨 폰트, 살짝 기울어짐)
    │
    ├── {state === 'upload' && <UploadSection />}
    ├── {state === 'loading' && <LoadingSection />}
    ├── {state === 'result' && <ResultSection />}
    │
    └── <footer>
        ├── DisclaimerText (면책 고지 - 작은 글씨)
        └── AdPlacement (광고 영역)
```

---

## 상태 1: UploadSection (메인 업로드 화면)

### 레이아웃 계층

```
<section className="upload-section">
  ├── <header>
  │   ├── <h1 className="app-title">탈모상</h1> (손글씨 폰트, 살짝 회전)
  │   ├── <p className="main-copy">이보시오 관상가 양반, 내가 탈모가 될 상인가?</p>
  │   └── <p className="sub-copy">AI 관상가가 그대의 모발 운명을 점지하리라</p>
  │
  ├── <Card className="upload-card"> (shadcn/ui Card + 커스텀 스타일)
  │   ├── {!photo && <DragDropZone>}
  │   │   ├── <CloudUploadIcon /> (점선 원 안에)
  │   │   ├── <p>사진을 드래그하거나 클릭하여 업로드</p>
  │   │   └── <input type="file" accept="image/*" capture="user" />
  │   │
  │   └── {photo && <PreviewSection>}
  │       ├── <div className="polaroid-frame"> (폴라로이드 느낌 프레임)
  │       │   ├── <img src={photoUrl} alt="업로드한 사진" />
  │       │   └── <ScribbleDecoration /> (손그림 별 데코)
  │       │
  │       ├── <Button variant="ghost" onClick={reset}>다시 찍기</Button>
  │       └── <Button variant="primary" onClick={analyze}>관상 보기</Button>
  │
  ├── <div className="reassurance-text">
  │   ├── <ShieldCheckIcon />
  │   └── <p>업로드한 사진은 분석 후 즉시 삭제됩니다</p>
  │
  └── <AdPlacement position="bottom" /> (하단 광고)
```

### 위젯 상세

#### AppTitle (앱 제목)
- **폰트**: Nanum Pen Script (손글씨 느낌) 또는 Gaegu
- **크기**: 64px (모바일: 48px)
- **색상**: --color-charcoal (#2D2D2D)
- **변형**: `transform: rotate(-2deg)` (살짝 기울어짐)
- **텍스트**: "탈모상"
- **데코**: 텍스트 아래 손그림 물결 밑줄 (SVG)

#### MainCopy (메인 카피)
- **폰트**: Pretendard Bold
- **크기**: 24px (모바일: 20px)
- **색상**: --color-charcoal
- **텍스트**: "이보시오 관상가 양반, 내가 탈모가 될 상인가?"
- **말풍선 느낌**: 배경 크림색 박스 + 손그림 테두리

#### SubCopy (서브 카피)
- **폰트**: Pretendard Regular
- **크기**: 16px (모바일: 14px)
- **색상**: --color-charcoal (80% 투명도)
- **텍스트**: "AI 관상가가 그대의 모발 운명을 점지하리라"

#### UploadCard (업로드 카드)
- **shadcn/ui Card** 기본 구조 사용
- **배경**: 종이 텍스처 이미지 또는 CSS 노이즈 필터
- **테두리**: 점선 테두리 `border: 2px dashed var(--color-coral)` + `border-radius: 16px`
- **내부 패딩**: 32px (모바일: 24px)
- **Hover 효과**: `transform: scale(1.02)` + 미세한 회전 (-1deg)

#### DragDropZone (드래그앤드롭 영역)
- **레이아웃**: Flexbox, 세로 중앙 정렬
- **아이콘**: CloudUploadIcon (Lucide), 크기 64px, 색상 --color-coral
- **점선 원**: `border: 3px dashed var(--color-coral)`, `border-radius: 50%`, padding: 24px
- **텍스트**: "사진을 드래그하거나 클릭하여 업로드" (Pretendard Regular, 16px)
- **Input**: `<input type="file" accept="image/*" capture="user" />` (숨김 처리)
- **모바일**: `capture="user"`로 전면 카메라 기본 활성화

#### PolaroidFrame (폴라로이드 프레임)
- **구조**: 흰색 두꺼운 테두리 + 그림자
- **배경**: white
- **테두리**: 16px solid white
- **그림자**: `box-shadow: 0 4px 12px rgba(0,0,0,0.15)`
- **회전**: `transform: rotate(1.5deg)` (약간 기울어짐)
- **이미지**: 최대 너비 400px, 비율 유지, `border-radius: 4px`
- **데코**: 우측 상단에 손그림 별 SVG

#### Button (버튼)
- **shadcn/ui Button** 기본 구조 사용

**"다시 찍기" 버튼 (variant="ghost")**
- **배경**: transparent
- **텍스트 색상**: --color-deep-blue
- **테두리**: 없음
- **Hover**: 배경 --color-cream (10% 투명도), 살짝 흔들리는 애니메이션 (`animation: wiggle 0.5s ease-in-out`)

**"관상 보기" 버튼 (variant="primary")**
- **배경**: --color-coral (#E85D4A)
- **텍스트 색상**: white
- **패딩**: horizontal: 48px, vertical: 16px
- **border-radius**: 24px (캡슐 형태)
- **폰트**: Pretendard Bold, 18px
- **그림자**: `box-shadow: 0 4px 8px rgba(232,93,74,0.3)`
- **Hover**:
  - 배경 darken 10%
  - `transform: scale(1.05)` + `animation: shake 0.5s`
- **Active**: `transform: scale(0.95)`
- **Loading**: CircularProgressIndicator (16x16, white) + "분석 중..." 텍스트

#### ReassuranceText (안심 문구)
- **레이아웃**: Flex row, 아이콘 + 텍스트
- **아이콘**: ShieldCheckIcon (Lucide), 20px, --color-forest-green
- **텍스트**: "업로드한 사진은 분석 후 즉시 삭제됩니다" (Pretendard Regular, 14px, --color-charcoal 70%)
- **배경**: --color-cream, padding: 12px 16px, `border-radius: 8px`

---

## 상태 2: LoadingSection (분석 중 화면)

### 레이아웃 계층

```
<section className="loading-section">
  ├── <div className="loading-animation">
  │   ├── <HairFallingAnimation /> (CSS 애니메이션 - 머리카락 떨어지는 느낌)
  │   └── <MagnifyingGlassIcon /> (돋보기 아이콘, 회전)
  │
  ├── <p className="loading-message">{currentMessage}</p> (사극 말투, 2초마다 전환)
  │
  ├── <Progress value={progress} max={100} /> (shadcn/ui Progress + 커스텀 스타일)
  │
  └── <AdPlacement position="center" /> (중앙 광고)
```

### 위젯 상세

#### LoadingAnimation (로딩 애니메이션)
- **HairFallingAnimation**:
  - 작은 머리카락 SVG 3-5개가 위에서 아래로 천천히 떨어짐
  - CSS keyframes: `@keyframes fall { from { top: -20px; opacity: 1; } to { top: 100%; opacity: 0; } }`
  - `animation: fall 3s infinite ease-in`
  - 각 머리카락은 다른 delay로 시작
- **MagnifyingGlassIcon**:
  - Lucide 아이콘, 크기 80px, 색상 --color-mustard
  - `animation: rotate 2s linear infinite`

#### LoadingMessage (로딩 메시지)
- **폰트**: Nanum Pen Script (손글씨), 24px (모바일: 20px)
- **색상**: --color-charcoal
- **텍스트 배열** (2초마다 순환):
  1. "두피를 살펴보고 있사옵니다..."
  2. "모발의 운명을 점치고 있사옵니다..."
  3. "헤어라인의 기운을 감지하고 있사옵니다..."
  4. "10년 뒤의 모습을 그려보고 있사옵니다..."
  5. "관상가 양반이 심사숙고 중이옵니다..."
- **애니메이션**: Fade in/out (200ms)

#### Progress (프로그레스 바)
- **shadcn/ui Progress** 기본 구조 사용
- **배경**: --color-cream-dark (어두운 크림색)
- **진행 바**: 손으로 색칠한 느낌
  - 배경: linear-gradient(90deg, --color-coral 0%, --color-mustard 100%)
  - 높이: 12px
  - `border-radius: 6px`
  - 불규칙한 테두리 느낌: `clip-path: polygon(...)` (약간 울퉁불퉁)
- **애니메이션**: 0%에서 100%까지 20-30초 동안 증가

---

## 상태 3: ResultSection (결과 화면)

### 레이아웃 계층

```
<section className="result-section">
  ├── <h2 className="result-title">관상 결과가 나왔사옵니다!</h2>
  │
  ├── <Card className="result-card"> (shadcn/ui Card + 커스텀 스타일)
  │   ├── <div className="grade-badge">
  │   │   ├── <Badge variant="stamp">{grade}</Badge> (도장 느낌)
  │   │   └── <p>{gradeDescription}</p>
  │   │
  │   ├── <div className="hair-age">
  │   │   ├── <span className="label">모발 나이:</span>
  │   │   ├── <span className="value">{hairAge}세</span> (카운트업 애니메이션)
  │   │   └── <span className="comparison">실제 나이보다 {diff}살 {younger ? '젊음' : '많음'}</span>
  │   │
  │   ├── <div className="probability">
  │   │   ├── <span className="label">5년 내 탈모 확률:</span>
  │   │   ├── <Progress value={probability} max={100} />
  │   │   └── <span className="value">{probability}%</span>
  │   │
  │   ├── <div className="hair-type">
  │   │   ├── <span className="label">탈모 유형:</span>
  │   │   └── <Badge variant="type">{hairType}</Badge>
  │   │
  │   ├── <div className="celebrity">
  │   │   ├── <span className="label">닮은 유명인:</span>
  │   │   └── <div className="speech-bubble">{celebrity}</div> (말풍선)
  │   │
  │   └── <div className="tips">
  │       ├── <span className="label">관리 팁:</span>
  │       └── <ul className="checklist">
  │           {tips.map(tip => <li><CheckIcon />{tip}</li>)}
  │
  ├── <div className="comment">
  │   ├── <QuoteIcon /> (큰 따옴표)
  │   └── <p className="comment-text">{overallComment}</p> (종합 코멘트)
  │
  ├── <AdPlacement position="middle" /> (광고)
  │
  ├── <Card className="simulation-card"> (시뮬레이션 이미지)
  │   ├── <div className="scroll-frame"> (족자/두루마리 프레임)
  │   │   ├── <h3>10년 뒤의 그대 모습</h3>
  │   │   ├── <img src={simulationUrl} alt="10년 뒤 시뮬레이션" />
  │   │   └── <ScribbleDecoration /> (손그림 화살표)
  │   │
  │   └── {!simulationUrl && <Placeholder>}
  │       ├── <ImageOffIcon />
  │       └── <p>시뮬레이션 이미지를 준비할 수 없사옵니다</p>
  │
  ├── <div className="action-buttons">
  │   ├── <Button variant="secondary" onClick={retry}>다시 관상 보기</Button>
  │   └── <Button variant="primary" onClick={share}>공유하기</Button>
  │
  └── <AdPlacement position="bottom" /> (하단 광고)
```

### 위젯 상세

#### ResultTitle (결과 제목)
- **폰트**: Nanum Pen Script, 32px (모바일: 28px)
- **색상**: --color-charcoal
- **텍스트**: "관상 결과가 나왔사옵니다!"
- **데코**: 좌우에 별 SVG 데코레이션
- **애니메이션**: Fade in + Scale up (500ms)

#### ResultCard (결과 카드)
- **shadcn/ui Card** 기본 구조 사용
- **배경**: 종이 텍스처 + 미세한 노이즈
- **테두리**: 연필 느낌 `border: 3px solid var(--color-charcoal)` + 불규칙한 느낌 (약간 삐뚤어진)
- **내부 패딩**: 32px (모바일: 24px)
- **그림자**: `box-shadow: 0 8px 24px rgba(0,0,0,0.1)`
- **회전**: `transform: rotate(-0.5deg)` (약간 기울어짐)

#### GradeBadge (모발 등급 배지)
- **shadcn/ui Badge** 기본 구조 사용, variant="stamp"
- **배경**: 도장 찍힌 느낌
  - 배경 이미지: 빨간색 원형 도장 스탬프 SVG
  - 색상: --color-coral (red gradient)
- **텍스트**:
  - 등급: "A등급", "B등급" 등 (흰색, Bold, 20px)
  - 설명: "탄탄한 모발", "풀밭 같은 두피" 등 (Pretendard Regular, 14px, --color-charcoal)
- **아이콘**:
  - A등급: 🌳 (숲)
  - B등급: 🌿 (풀밭)
  - C등급: 🏜️ (사막)
  - D등급: 🪨 (바위)
- **크기**: 120x120px (원형)
- **회전**: `transform: rotate(-5deg)`

#### HairAge (모발 나이)
- **레이아웃**: Flex row, label + value + comparison
- **Label**: "모발 나이:" (Pretendard Medium, 16px, --color-charcoal 70%)
- **Value**: "32세" (Pretendard Bold, 32px, --color-deep-blue)
  - 카운트업 애니메이션: 0에서 실제 값까지 1초 동안 증가
- **Comparison**: "실제 나이보다 5살 젊음" (Pretendard Regular, 14px, --color-forest-green if younger else --color-coral)

#### Probability (탈모 확률)
- **Label**: "5년 내 탈모 확률:" (Pretendard Medium, 16px)
- **Progress**: shadcn/ui Progress
  - 배경: --color-cream-dark
  - 진행 바:
    - 0-30%: --color-forest-green (안전)
    - 31-60%: --color-mustard (주의)
    - 61-100%: --color-coral (위험)
  - 높이: 20px, `border-radius: 10px`
- **Value**: "35%" (Pretendard Bold, 24px, 색상은 확률 구간에 따라)

#### HairTypeBadge (탈모 유형 배지)
- **shadcn/ui Badge**, variant="type"
- **배경**: --color-mustard (황색)
- **텍스트**: "M자형 초기 단계" (Pretendard Medium, 14px, --color-charcoal)
- **테두리**: `border: 2px solid var(--color-charcoal)`
- **패딩**: 8px 16px
- **border-radius**: 16px (캡슐 형태)

#### CelebritySpeechBubble (닮은 유명인 말풍선)
- **구조**: 말풍선 모양의 div + 꼬리
- **배경**: --color-cream
- **테두리**: 3px solid --color-deep-blue
- **border-radius**: 16px
- **패딩**: 16px
- **꼬리**: CSS ::after pseudo-element로 삼각형 구현
- **텍스트**: "송중기 초기 헤어라인" (Pretendard Regular, 16px)
- **아이콘**: UserIcon (Lucide) 좌측에

#### TipsChecklist (관리 팁 체크리스트)
- **구조**: `<ul>` + `<li>` (3-5개 항목)
- **li 스타일**:
  - Flex row, 아이콘 + 텍스트
  - 아이콘: CheckIcon (Lucide), 20px, --color-forest-green
  - 텍스트: Pretendard Regular, 14px, --color-charcoal
  - 간격: 12px
- **전체 배경**: --color-cream-light, padding: 16px, `border-radius: 12px`

#### Comment (종합 코멘트)
- **레이아웃**: 큰 따옴표 + 텍스트
- **QuoteIcon**: " (큰 따옴표), 48px, --color-coral (30% 투명도)
- **텍스트**:
  - 폰트: Pretendard Regular, 18px (모바일: 16px)
  - 색상: --color-charcoal
  - 스타일: italic (기울임)
- **배경**: --color-cream, padding: 24px, `border-radius: 16px`
- **테두리**: 손그림 느낌 점선 `border: 2px dashed var(--color-deep-blue)`

#### SimulationCard (시뮬레이션 이미지 카드)
- **shadcn/ui Card** 기본 구조 사용
- **ScrollFrame** (족자/두루마리 프레임):
  - 배경: 오래된 양피지 느낌 (베이지 그라디언트)
  - 테두리: 나무 프레임 느낌 (진한 갈색)
  - 상하단: 장식 패턴 (SVG)
- **Title**: "10년 뒤의 그대 모습" (Nanum Pen Script, 24px)
- **Image**:
  - 최대 너비 500px
  - `border-radius: 8px`
  - 그림자: `box-shadow: 0 4px 12px rgba(0,0,0,0.2)`
- **ScribbleDecoration**: 손그림 화살표 SVG (우측 하단)
- **Placeholder** (이미지 생성 실패 시):
  - ImageOffIcon (Lucide), 64px, --color-charcoal (30%)
  - 텍스트: "시뮬레이션 이미지를 준비할 수 없사옵니다" (Pretendard Regular, 16px)
  - 배경: --color-cream-dark, padding: 48px

#### ActionButtons (액션 버튼)
- **레이아웃**: Flex row, 간격 16px, 중앙 정렬

**"다시 관상 보기" 버튼 (variant="secondary")**
- **배경**: transparent
- **텍스트 색상**: --color-deep-blue
- **테두리**: 2px solid --color-deep-blue
- **패딩**: horizontal: 32px, vertical: 14px
- **border-radius**: 24px
- **Hover**: 배경 --color-deep-blue, 텍스트 white

**"공유하기" 버튼 (variant="primary")**
- **배경**: --color-coral
- **텍스트 색상**: white
- **패딩**: horizontal: 40px, vertical: 14px
- **border-radius**: 24px
- **아이콘**: ShareIcon (Lucide) 좌측에
- **Hover**: 배경 darken 10%, `transform: scale(1.05)`

---

## 색상 팔레트

### Primary Colors
- **Charcoal** (`--color-charcoal`): `#2D2D2D` — 메인 텍스트, 잉크 느낌
- **Cream** (`--color-cream`): `#FFF8F0` — 기본 배경, 따뜻한 종이 느낌
- **Cream Light** (`--color-cream-light`): `#FFFBF5` — 밝은 배경
- **Cream Dark** (`--color-cream-dark`): `#F5E6D3` — 어두운 배경, 경계

### Accent Colors
- **Coral** (`--color-coral`): `#E85D4A` — CTA 버튼, 강조, 에너지
- **Deep Blue** (`--color-deep-blue`): `#2B4C7E` — 링크, 정보, 신뢰
- **Mustard** (`--color-mustard`): `#F2A541` — 배지, 하이라이트, 주의
- **Forest Green** (`--color-forest-green`): `#4A7C59` — 긍정 결과, 안전

### Semantic Colors
- **Success**: `--color-forest-green` — 성공 상태, 긍정 피드백
- **Warning**: `--color-mustard` — 주의 상태
- **Error**: `--color-coral` — 에러 상태, 위험
- **Info**: `--color-deep-blue` — 정보 상태

### Grayscale
- **Charcoal 70%**: `rgba(45, 45, 45, 0.7)` — 보조 텍스트
- **Charcoal 30%**: `rgba(45, 45, 45, 0.3)` — 플레이스홀더, 비활성

---

## 타이포그래피

### 폰트 패밀리
- **손글씨 폰트**: Nanum Pen Script (주요 타이틀, 로딩 메시지) 또는 Gaegu (대체)
- **본문 폰트**: Pretendard (본문, 버튼, 라벨)
- **Next.js 로컬 폰트**: `next/font/google`로 Nanum Pen Script, Pretendard 로드
- **Fallback**: system-ui, -apple-system, sans-serif

### Type Scale

#### Display (손글씨 폰트)
- **display-large**:
  - 용도: 앱 타이틀 "탈모상"
  - fontSize: 64px (모바일: 48px)
  - fontWeight: 400
  - lineHeight: 1.2
  - fontFamily: Nanum Pen Script

- **display-medium**:
  - 용도: 결과 제목
  - fontSize: 32px (모바일: 28px)
  - fontWeight: 400
  - lineHeight: 1.3
  - fontFamily: Nanum Pen Script

- **display-small**:
  - 용도: 로딩 메시지
  - fontSize: 24px (모바일: 20px)
  - fontWeight: 400
  - lineHeight: 1.4
  - fontFamily: Nanum Pen Script

#### Headline (본문 폰트)
- **headline-large**:
  - 용도: 메인 카피
  - fontSize: 24px (모바일: 20px)
  - fontWeight: 700 (Bold)
  - lineHeight: 1.4
  - fontFamily: Pretendard

- **headline-medium**:
  - 용도: 카드 제목
  - fontSize: 20px (모바일: 18px)
  - fontWeight: 700
  - lineHeight: 1.4
  - fontFamily: Pretendard

#### Body
- **body-large**:
  - 용도: 종합 코멘트
  - fontSize: 18px (모바일: 16px)
  - fontWeight: 400
  - lineHeight: 1.6
  - fontFamily: Pretendard

- **body-medium**:
  - 용도: 일반 본문, 설명
  - fontSize: 16px (모바일: 14px)
  - fontWeight: 400
  - lineHeight: 1.5
  - fontFamily: Pretendard

- **body-small**:
  - 용도: 보조 텍스트, 안심 문구
  - fontSize: 14px (모바일: 12px)
  - fontWeight: 400
  - lineHeight: 1.5
  - fontFamily: Pretendard

#### Label
- **label-large**:
  - 용도: 버튼 텍스트
  - fontSize: 18px (모바일: 16px)
  - fontWeight: 700 (Bold)
  - lineHeight: 1.2
  - fontFamily: Pretendard

- **label-medium**:
  - 용도: 배지, 라벨
  - fontSize: 16px (모바일: 14px)
  - fontWeight: 500 (Medium)
  - lineHeight: 1.2
  - fontFamily: Pretendard

- **label-small**:
  - 용도: 작은 라벨, 면책 문구
  - fontSize: 12px (모바일: 11px)
  - fontWeight: 400
  - lineHeight: 1.3
  - fontFamily: Pretendard

---

## 스페이싱 시스템 (8px 그리드)

### Padding/Margin
- **xs**: 4px — 아주 작은 간격 (아이콘-텍스트)
- **sm**: 8px — 작은 간격 (리스트 항목)
- **md**: 16px — 기본 간격 (카드 내부, 위젯 간격)
- **lg**: 24px — 큰 간격 (섹션 구분)
- **xl**: 32px — 아주 큰 간격 (화면 패딩)
- **2xl**: 48px — 특별한 강조 (메인 타이틀 상하)
- **3xl**: 64px — 최대 간격 (섹션 전환)

### 컴포넌트별 스페이싱
- **Container 패딩**:
  - 데스크톱: 80px (좌우), 48px (상하)
  - 모바일: 24px (좌우), 32px (상하)
- **Card 내부 패딩**: 32px (데스크톱), 24px (모바일)
- **Section 간격**: 64px (데스크톱), 48px (모바일)
- **위젯 간 간격**: 16px (기본), 8px (밀집), 24px (여유)
- **버튼 내부 패딩**:
  - Primary: horizontal 48px, vertical 16px
  - Secondary: horizontal 32px, vertical 14px
  - Ghost: horizontal 24px, vertical 12px

---

## Border Radius

- **small**: 8px — 배지, 작은 요소
- **medium**: 12px — 카드, 입력 필드
- **large**: 16px — 큰 카드, 말풍선
- **xlarge**: 24px — 버튼 (캡슐 형태)
- **round**: 50% — 원형 요소 (아이콘 배경, 도장)

---

## Elevation (그림자)

- **Level 0**: none — 평면 요소
- **Level 1**: `0 2px 4px rgba(0,0,0,0.1)` — 약간 떠있는 느낌
- **Level 2**: `0 4px 8px rgba(0,0,0,0.15)` — 기본 카드
- **Level 3**: `0 8px 16px rgba(0,0,0,0.2)` — 강조 카드
- **Level 4**: `0 12px 24px rgba(0,0,0,0.25)` — 모달
- **Level 5**: `0 16px 32px rgba(0,0,0,0.3)` — 최상위 레이어

### 특별 그림자
- **버튼 그림자**: `0 4px 8px rgba(232,93,74,0.3)` (코랄 색상 그림자)
- **종이 그림자**: `0 4px 12px rgba(0,0,0,0.15)` (폴라로이드, 카드)

---

## 인터랙션 상태

### 버튼 상태

**Primary Button (variant="primary")**
- **Default**:
  - 배경 --color-coral
  - 텍스트 white
  - 그림자 Level 2
- **Hover**:
  - 배경 darken 10% (#D14D3A)
  - `transform: scale(1.05)`
  - `animation: shake 0.5s` (흔들림)
  - 그림자 Level 3
- **Active**:
  - `transform: scale(0.95)`
  - 그림자 Level 1
- **Disabled**:
  - 배경 --color-charcoal (30%)
  - 텍스트 --color-charcoal (50%)
  - 그림자 none
- **Loading**:
  - CircularProgressIndicator (16x16, white) 좌측에
  - 텍스트 "분석 중..." (disable 클릭)

**Secondary Button (variant="secondary")**
- **Default**:
  - 배경 transparent
  - 텍스트 --color-deep-blue
  - 테두리 2px solid --color-deep-blue
- **Hover**:
  - 배경 --color-deep-blue
  - 텍스트 white
- **Active**:
  - 배경 darken 10%

**Ghost Button (variant="ghost")**
- **Default**:
  - 배경 transparent
  - 텍스트 --color-deep-blue
- **Hover**:
  - 배경 --color-cream (20%)
  - `animation: wiggle 0.5s`

### 카드 상태

**UploadCard**
- **Default**:
  - 테두리 점선 --color-coral
  - 그림자 Level 2
- **Hover** (드래그앤드롭 영역):
  - 배경 --color-coral (5%)
  - `transform: scale(1.02) rotate(-1deg)`
  - 그림자 Level 3
- **Active** (드래그 중):
  - 배경 --color-coral (10%)
  - 테두리 solid --color-coral

**ResultCard**
- **Default**:
  - 테두리 3px solid --color-charcoal
  - 그림자 Level 3
  - `transform: rotate(-0.5deg)`

### 터치 피드백

- **Ripple Effect**: 커스텀 ripple (손그림 느낌 확산)
- **Splash Color**: --color-coral (10% 투명도)
- **Highlight Color**: --color-cream-dark

---

## 애니메이션

### 화면 전환 (상태 변경)
- **Fade In/Out**:
  - Duration: 300ms
  - Curve: ease-in-out
  - Opacity: 0 → 1 (Fade In), 1 → 0 (Fade Out)

- **Slide Up**:
  - Duration: 500ms
  - Curve: ease-out
  - Transform: translateY(20px) → translateY(0)

### 요소 애니메이션

**Shake (흔들림)**
```css
@keyframes shake {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(2deg); }
  75% { transform: rotate(-2deg); }
}
```
- Duration: 0.5s
- 사용: 버튼 hover

**Wiggle (살랑살랑)**
```css
@keyframes wiggle {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-4px); }
  75% { transform: translateX(4px); }
}
```
- Duration: 0.5s
- 사용: Ghost 버튼 hover

**CountUp (숫자 증가)**
- Duration: 1s
- Curve: ease-out
- JavaScript로 구현 (0에서 목표값까지)

**HairFalling (머리카락 떨어짐)**
```css
@keyframes fall {
  from {
    top: -20px;
    opacity: 1;
  }
  to {
    top: 100%;
    opacity: 0;
  }
}
```
- Duration: 3s
- Iteration: infinite
- 사용: 로딩 화면

**Rotate (회전)**
```css
@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
```
- Duration: 2s
- Iteration: infinite
- 사용: 돋보기 아이콘

### 로딩

- **CircularProgressIndicator**:
  - 크기: 16x16px (버튼 내), 80px (로딩 화면)
  - 색상: white (버튼), --color-coral (로딩 화면)
  - 애니메이션: 회전 (linear, infinite)

- **Skeleton**:
  - 배경: --color-cream-dark
  - 애니메이션: 펄스 (1.5s, ease-in-out, infinite)
  - 사용: 이미지 로딩 중 플레이스홀더

---

## 반응형 레이아웃

### Breakpoints
- **Mobile**: width < 640px (Tailwind sm)
- **Tablet**: 640px ≤ width < 1024px (Tailwind md)
- **Desktop**: width ≥ 1024px (Tailwind lg)

### 적응형 레이아웃 전략

#### Mobile (< 640px)
- **단일 컬럼**: 모든 요소 세로 배치
- **Container 패딩**: 24px (좌우), 32px (상하)
- **폰트 크기**: 작은 사이즈 사용 (예: 48px → 36px)
- **버튼**: 전체 너비 (width: 100%)
- **카드**: 전체 너비, 패딩 24px
- **액션 버튼**: 세로 배치, 간격 12px

#### Tablet (640px - 1023px)
- **단일 컬럼 유지**: 복잡도 최소화
- **Container 패딩**: 48px (좌우), 40px (상하)
- **폰트 크기**: 중간 사이즈
- **카드**: 최대 너비 600px, 중앙 정렬
- **액션 버튼**: 가로 배치, 간격 16px

#### Desktop (≥ 1024px)
- **단일 컬럼 유지**: 집중력 유지
- **Container 최대 너비**: 800px, 중앙 정렬
- **Container 패딩**: 80px (좌우), 48px (상하)
- **폰트 크기**: 큰 사이즈
- **카드**: 최대 너비 700px
- **액션 버튼**: 가로 배치, 간격 16px

### 터치 영역
- **최소 크기**: 44x44px (iOS Human Interface Guidelines)
- **권장 크기**: 48x48px (Material Design)
- **버튼**: 최소 높이 48px
- **아이콘 버튼**: 48x48px
- **체크박스**: 24x24px (터치 영역 44x44px)

---

## 접근성 (Accessibility)

### 색상 대비
- **텍스트 대 배경**:
  - Charcoal (#2D2D2D) on Cream (#FFF8F0) — 대비 13.5:1 (WCAG AAA)
  - Charcoal (70%) on Cream — 대비 9:1 (WCAG AAA)
- **버튼 텍스트 대 배경**:
  - White on Coral (#E85D4A) — 대비 4.8:1 (WCAG AA)
- **아이콘 대 배경**: 최소 3:1 (WCAG AA)

### 의미 전달
- **색상만으로 의미 전달 금지**:
  - 에러: 빨간색 + 에러 아이콘 + 텍스트 "오류 발생"
  - 성공: 초록색 + 체크 아이콘 + 텍스트 "완료"
  - 경고: 황색 + 느낌표 아이콘 + 텍스트 "주의"

### 키보드 내비게이션
- **Tab 순서**: 논리적 순서 (위→아래, 좌→우)
- **Focus 스타일**:
  - 테두리: 2px solid --color-deep-blue
  - 그림자: 0 0 0 4px rgba(43,76,126,0.2)
  - Outline: 2px solid transparent (기본 outline 제거)
- **Skip to Content**: 페이지 상단에 "본문으로 건너뛰기" 링크 (숨김, focus 시 표시)

### 스크린 리더 지원
- **Semantics**: 모든 인터랙티브 요소에 ARIA label 제공
- **Button**:
  - "관상 보기 버튼"
  - "다시 관상 보기 버튼"
  - "공유하기 버튼"
- **Input**:
  - "사진 업로드 영역, 드래그하거나 클릭하여 파일 선택"
- **Progress**:
  - "분석 진행 중, {progress}% 완료"
- **Image**:
  - "업로드한 사진 미리보기"
  - "10년 뒤 헤어라인 시뮬레이션 이미지"
- **Live Region**:
  - 로딩 메시지 변경 시 자동 알림 (`aria-live="polite"`)
  - 에러 발생 시 즉시 알림 (`aria-live="assertive"`)

### 대체 텍스트
- **이미지**: 모든 `<img>` 태그에 적절한 alt 속성
- **아이콘**: 의미 있는 아이콘은 `aria-label` 추가
- **데코레이션**: 순수 장식 요소는 `aria-hidden="true"`

---

## 장식 요소 (CSS/SVG)

### 노이즈 텍스처 (전체 페이지)
- **구현**: CSS filter 또는 SVG overlay
- **CSS filter 방법**:
  ```css
  body::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-image: url('data:image/svg+xml,...'); /* 노이즈 SVG */
    opacity: 0.05;
    pointer-events: none;
    z-index: 9999;
  }
  ```
- **효과**: 종이 느낌, 미세한 그레인

### 손그림 밑줄 (ScribbleUnderline)
- **SVG Path**: 불규칙한 물결 모양
- **색상**: --color-coral
- **두께**: 3px
- **위치**: 텍스트 아래 4px 간격
- **사용**: 앱 타이틀 "탈모상" 아래

### 손그림 화살표 (ScribbleArrow)
- **SVG Path**: 구불구불한 화살표
- **색상**: --color-mustard
- **크기**: 80x40px
- **위치**: 시뮬레이션 이미지 우측 하단
- **회전**: `transform: rotate(15deg)`

### 손그림 별 (ScribbleStar)
- **SVG Path**: 손으로 그린 듯한 별 모양 (5개 끝)
- **색상**: --color-coral
- **크기**: 32x32px
- **위치**: 폴라로이드 프레임 우측 상단, 결과 제목 좌우
- **회전**: `transform: rotate(-10deg)`

### 말풍선 꼬리 (SpeechBubbleTail)
- **CSS ::after**:
  ```css
  .speech-bubble::after {
    content: '';
    position: absolute;
    bottom: -10px;
    left: 30px;
    width: 0;
    height: 0;
    border-left: 10px solid transparent;
    border-right: 10px solid transparent;
    border-top: 10px solid var(--color-cream);
  }
  ```
- **위치**: 말풍선 하단 좌측

### 도장 스탬프 (StampBadge)
- **SVG 원형**: 불규칙한 원 (손으로 찍은 느낌)
- **색상**: --color-coral (radial gradient)
- **텍스트**: 중앙 정렬, 흰색
- **효과**: `filter: opacity(0.9)` (약간 투명)
- **회전**: `transform: rotate(-5deg)`

---

## shadcn/ui 컴포넌트 커스터마이징

### Card
- **기본 스타일**: `src/components/ui/card.tsx` (variant 확장 허용)
- **커스터마이징**:
  - `className="paper-texture"` 클래스 추가
  - CSS:
    ```css
    .paper-texture {
      background-image: url('data:image/svg+xml,...'); /* 종이 텍스처 SVG */
      background-blend-mode: multiply;
    }
    .pencil-border {
      border: 3px solid var(--color-charcoal);
      border-image: url('data:image/svg+xml,...') 3; /* 불규칙한 테두리 */
    }
    ```

### Button
- **기본 스타일**: `src/components/ui/button.tsx` (variant 확장 허용)
- **커스터마이징**:
  - Tailwind 클래스로 커스터마이징
  - 예: `className="bg-coral text-white hover:bg-coral-dark hover:scale-105 transition-all duration-200"`
  - 흔들림 애니메이션은 `globals.css`에 정의 후 적용

### Progress
- **기본 스타일**: `src/components/ui/progress.tsx` (variant 확장 허용)
- **커스터마이징**:
  - `className="hand-drawn-progress"` 클래스 추가
  - CSS:
    ```css
    .hand-drawn-progress [role="progressbar"] {
      background: linear-gradient(90deg, var(--color-coral), var(--color-mustard));
      clip-path: polygon(0% 0%, 98% 2%, 100% 50%, 98% 98%, 2% 100%, 0% 50%); /* 울퉁불퉁 */
    }
    ```

### Badge
- **기본 스타일**: `src/components/ui/badge.tsx` (variant 확장 허용)
- **커스터마이징**:
  - variant="stamp" (새 variant 추가)
  - 래퍼 컴포넌트 `<StampBadge>` 생성:
    ```tsx
    export function StampBadge({ children }: { children: React.ReactNode }) {
      return (
        <Badge className="stamp-style relative bg-coral text-white">
          <div className="stamp-background absolute inset-0" />
          {children}
        </Badge>
      );
    }
    ```

### Skeleton
- **기본 스타일**: `src/components/ui/skeleton.tsx` (추가 필요)
- **커스터마이징**:
  - 연필 스케치 느낌
  - CSS:
    ```css
    .skeleton-sketch {
      background: repeating-linear-gradient(
        45deg,
        var(--color-cream-dark),
        var(--color-cream-dark) 10px,
        var(--color-cream) 10px,
        var(--color-cream) 20px
      );
      animation: sketch-pulse 1.5s ease-in-out infinite;
    }
    @keyframes sketch-pulse {
      0%, 100% { opacity: 0.6; }
      50% { opacity: 1; }
    }
    ```

---

## 에러 처리 UI

### 에러 메시지 스타일
- **배경**: --color-coral (10%)
- **테두리**: 2px solid --color-coral
- **아이콘**: AlertCircleIcon (Lucide), 24px, --color-coral
- **텍스트**:
  - 폰트: Pretendard Medium, 16px
  - 색상: --color-coral
  - 사극 말투: "아이고, 관상가 양반이 잠시 자리를 비웠사옵니다."
- **버튼**: "다시 시도" (variant="secondary", 색상 --color-coral)

### 에러 종류별 메시지

**파일 형식 오류**
- 텍스트: "지원하지 않는 파일 형식입니다. JPG, PNG 파일을 업로드해주시게."
- 아이콘: FileWarningIcon

**파일 크기 초과**
- 텍스트: "파일 크기가 너무 크옵니다. 10MB 이하의 이미지를 올려주시게."
- 아이콘: AlertTriangleIcon

**얼굴 인식 실패**
- 텍스트: "얼굴을 찾을 수 없사옵니다. 정면 사진으로 다시 시도해주시게."
- 아이콘: UserXIcon

**AI API 오류**
- 텍스트: "아이고, 관상가 양반이 잠시 자리를 비웠사옵니다. 잠시 후 다시 시도해주시게."
- 아이콘: ServerCrashIcon

**네트워크 오류**
- 텍스트: "통신이 원활하지 않사옵니다. 네트워크 연결을 확인해주시게."
- 아이콘: WifiOffIcon

**Rate Limit 초과**
- 텍스트: "많은 사람들이 관상을 보고 있사옵니다. 잠시 후 다시 시도해주시게."
- 아이콘: ClockIcon

---

## 광고 배치

### Google AdSense 영역

**광고 1: 메인 화면 하단**
- **위치**: UploadSection 하단, DisclaimerText 위
- **크기**:
  - 모바일: 320x100 (banner)
  - 데스크톱: 728x90 (leaderboard)
- **스타일**:
  - 배경: --color-cream-light
  - 테두리: 1px solid --color-cream-dark
  - border-radius: 8px
  - margin: 32px 0

**광고 2: 로딩 화면 하단**
- **위치**: LoadingSection 하단
- **크기**:
  - 모바일: 300x250 (medium rectangle)
  - 데스크톱: 336x280 (large rectangle)
- **스타일**:
  - 중앙 정렬
  - 배경: --color-cream-light
  - margin: 24px auto

**광고 3: 결과 화면 중간**
- **위치**: Comment와 SimulationCard 사이
- **크기**:
  - 모바일: 320x100 (banner)
  - 데스크톱: 728x90 (leaderboard)
- **스타일**:
  - 배경: --color-cream-light
  - margin: 32px 0

**광고 4: 결과 화면 하단**
- **위치**: ActionButtons 아래, Footer 위
- **크기**:
  - 모바일: 300x250 (medium rectangle)
  - 데스크톱: 728x90 (leaderboard)
- **스타일**:
  - 중앙 정렬
  - margin: 32px 0

### 광고 컴포넌트 구조
```tsx
<div className="ad-container">
  <p className="ad-label">광고</p> {/* 작은 글씨, 상단 */}
  <ins className="adsbygoogle"
    style={{ display: 'block' }}
    data-ad-client="ca-pub-XXXXXXXX"
    data-ad-slot="XXXXXXXXX"
    data-ad-format="auto"
    data-full-width-responsive="true">
  </ins>
</div>
```

---

## 면책 고지 (Disclaimer)

### 위치
- **Footer**: 페이지 최하단
- **UploadCard 하단**: 업로드 영역 아래 (작은 글씨)

### 스타일
- **폰트**: Pretendard Regular, 12px
- **색상**: --color-charcoal (50% 투명도)
- **배경**: --color-cream-light
- **패딩**: 16px
- **텍스트 정렬**: center
- **테두리**: 1px solid --color-cream-dark
- **border-radius**: 8px

### 텍스트
"본 서비스는 재미 목적의 엔터테인먼트 콘텐츠이며, 의료 진단이 아닙니다. 업로드한 사진은 분석 후 즉시 삭제되며, 서버에 저장되지 않습니다. 실제 두피 상태가 궁금하시면 전문의와 상담하시기 바랍니다."

---

## Web Share API (공유 기능)

### 지원 브라우저
- **Web Share API 지원**: 모바일 Safari, 모바일 Chrome, Android 브라우저
- **Web Share API 미지원**: 데스크톱 Chrome, Firefox, Edge

### 공유 구현

**Web Share API 지원 시**
```tsx
if (navigator.share) {
  await navigator.share({
    title: '내 탈모 관상 결과',
    text: `모발 등급: ${grade}, 5년 내 탈모 확률: ${probability}%`,
    url: window.location.href,
  });
}
```

**Web Share API 미지원 시**
- **대체 옵션**:
  1. "링크 복사" 버튼 (Clipboard API)
  2. "결과 이미지 다운로드" 버튼 (Canvas → PNG)

**링크 복사 버튼**
- **텍스트**: "링크 복사"
- **아이콘**: LinkIcon (Lucide)
- **클릭 시**:
  - `navigator.clipboard.writeText(window.location.href)`
  - 토스트 알림: "링크가 복사되었습니다!" (2초 표시)

**이미지 다운로드 버튼**
- **텍스트**: "결과 이미지 다운로드"
- **아이콘**: DownloadIcon (Lucide)
- **클릭 시**:
  - html2canvas로 ResultCard 캡처
  - Canvas → Blob → 다운로드 트리거
  - 파일명: `talmosang-result-${timestamp}.png`

---

## 성능 최적화

### 이미지 최적화
- **Next.js Image 컴포넌트**:
  - 업로드한 사진: `<Image>` 태그 사용, `priority={true}` (LCP 개선)
  - 시뮬레이션 이미지: `<Image>` 태그 사용, `loading="lazy"`
- **포맷**: WebP (fallback JPEG)
- **크기**:
  - 업로드 이미지: 최대 800x800px로 리사이즈 (클라이언트 측)
  - 시뮬레이션 이미지: API 응답 그대로 사용

### 폰트 로딩
- **next/font/google**:
  - Nanum Pen Script: `display: 'swap'`, `weight: '400'`
  - Pretendard: `display: 'swap'`, `weight: ['400', '500', '700']`
- **Preload**: 타이틀 폰트(Nanum Pen Script)는 `<link rel="preload">` 추가

### CSS 최적화
- **Tailwind CSS Purge**: 사용하지 않는 클래스 제거
- **Critical CSS**: 첫 화면(UploadSection)의 CSS는 인라인으로 포함
- **CSS 변수**: 색상, 스페이싱은 CSS 변수로 관리

### JavaScript 최적화
- **Code Splitting**:
  - LoadingSection: dynamic import
  - ResultSection: dynamic import
- **Lazy Load**:
  - 광고 스크립트: `<script async>`
  - 이미지: `loading="lazy"`

---

## 다크 모드

**지원하지 않음** — 크림/베이지 배경과 손글씨 느낌은 라이트 테마에 최적화되어 있으며, 다크 모드는 디자인 컨셉과 맞지 않음.

---

## 참고 자료

### 디자인 영감
- **Al Murphy 웹사이트**: 손글씨 폰트, 크림 배경, 장난스러운 낙서 감성 (레퍼런스)
- **2026 디자인 트렌드**:
  - 손그림 스타일, 레트로 감성, "진지한 척 하는 유머" ([Kittl Graphic Design Trends 2026](https://www.kittl.com/blogs/graphic-design-trends-2026/))
  - 불완전하고 인간적인 디자인, 감정적 연결 ([ReallyGoodDesigns Graphic Design Trends 2026](https://reallygooddesigns.com/graphic-design-trends-2026/))

### 기술 문서
- **Next.js 16 App Router**: [Next.js Documentation](https://nextjs.org/docs)
- **shadcn/ui**: [shadcn/ui Documentation](https://ui.shadcn.com/)
- **Tailwind CSS v4**: [Tailwind CSS Documentation](https://tailwindcss.com/)
- **Web Share API**: [MDN Web Share API](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share)

### 한국어 폰트
- **Nanum Pen Script**: [Google Fonts](https://fonts.google.com/specimen/Nanum+Pen+Script)
- **Gaegu**: [Google Fonts](https://fonts.google.com/specimen/Gaegu)
- **Pretendard**: [Pretendard GitHub](https://github.com/orioncactus/pretendard)

---

## 다음 단계

이 디자인 명세를 기반으로:
1. **Tech Lead**가 `web-brief.md` 작성 (Next.js App Router, Gemini API 통합, AdSense 설정)
2. **Web Developer**가 컴포넌트 구현 시작

**출력물**: `docs/talmosang/talmosang/web-design-spec.md`

---

## Sources
- [Kittl Graphic Design Trends 2026](https://www.kittl.com/blogs/graphic-design-trends-2026/)
- [ReallyGoodDesigns Graphic Design Trends 2026](https://reallygooddesigns.com/graphic-design-trends-2026/)
- [99designs Hand-drawn Websites](https://99designs.com/inspiration/websites/hand-drawn)
- [UXPilot Web Design Trends 2026](https://uxpilot.ai/blogs/web-design-trends-2026)
