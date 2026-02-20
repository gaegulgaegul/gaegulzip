# UI/UX 디자인 명세: 탈모상 (Al Murphy 스타일 재설계)

## 개요

"탈모상"은 Al Murphy 웹사이트(https://www.al-murphy.com)의 대담하고 맥시멀리스트 스타일에서 영감을 받아 전면 재설계한 바이럴 웹앱입니다. "진지한 척 하면서 전혀 진지하지 않은" 사극 말투로 사용자에게 재미있는 탈모 관상 결과를 제공하며, 즉각적인 공유를 유도합니다.

**디자인 목표**: 밝은 원색 배경, 거대하고 대담한 타이포그래피, 풀와이드 레이아웃, 풍부한 일러스트 장식으로 강렬한 첫인상과 바이럴 확산을 극대화합니다.

**핵심 UX 전략**: 단일 페이지에서 상태 전환(업로드 → 로딩 → 결과)으로 매끄러운 경험 제공, 섹션별 배경색 변화로 시각적 리듬 생성, 모바일 우선 설계.

---

## 디자인 철학: Al Murphy 영감

### 기존 vs 새로운 디자인

| 요소 | 기존 디자인 | Al Murphy 재설계 |
|------|-----------|----------------|
| **배경색** | 크림 (#FFF8F0) - 은은함 | 밝은 노란색 (#FFE847) + 섹션별 다른 색상 |
| **타이포그래피** | 나눔펜스크립트 (가는 손글씨) | 굵은 마커체 + 거대한 사이즈 (7xl~9xl) |
| **레이아웃** | max-w-lg (512px) 단일 컬럼 | 풀와이드 섹션, 섹션별 배경색 전환 |
| **일러스트** | 작은 CSS 별/화살표 | 대형 SVG 캐릭터, 낙서, 스티커 가득 |
| **에너지** | 은은하고 따뜻한 | 대담하고 혼란스럽게 재미있는 (맥시멀리스트) |
| **색상 채도** | 낮은 채도, 파스텔 | 높은 채도, 원색 (노란, 핑크, 하늘색) |
| **장식 요소** | 미세한 노이즈 텍스처 | 거대한 스티커, 낙서, 손그림 캐릭터 |

### Al Murphy 핵심 디자인 언어

1. **밝은 노란색 배경** (#FFE847) - 메인 배경색, 강렬한 첫인상
2. **섹션별 배경색 전환** - 노란색 → 핫핑크 (#FF69B4) → 하늘색 (#87CEEB) → 그라디언트
3. **거대한 핸드레터링** - 손글씨 타이틀이 화면 대부분 차지, 회전/기울어짐
4. **풀와이드 레이아웃** - 화면 전체 폭 활용, 좁은 컨테이너 없음
5. **대형 일러스트 캐릭터** - 귀여운 캐릭터, 몬스터, 낙서가 페이지 곳곳에
6. **스티커/배지 스타일** - 도장, 스탬프, 스티커 느낌의 요소들
7. **대담한 테두리** - 굵은 검정 테두리, 의도적으로 삐뚤어진 느낌
8. **원형/캡슐 형태** - 버튼, 배지, 타이틀 배경이 둥글고 대담함

---

## 화면 구조 (풀와이드 섹션)

이 앱은 **단일 페이지**에서 3가지 상태로 전환되며, 각 상태는 **독립된 풀와이드 섹션**으로 구성됩니다.

### 전체 레이아웃 구조 (풀와이드)

```
<body> (노란색 배경)
└── <section className="hero-section"> (풀와이드, 노란색 배경)
    ├── <header>
    │   └── AppTitle (거대한 손글씨 "탈모상" + 캐릭터 일러스트)
    │
    └── {state === 'upload' && <UploadSection />}

└── <section className="loading-section"> (풀와이드, 핫핑크 배경)
    └── {state === 'loading' && <LoadingSection />}

└── <section className="result-section"> (풀와이드, 하늘색 배경)
    └── {state === 'result' && <ResultSection />}

└── <footer className="footer-section"> (풀와이드, 다크 그린 배경)
    ├── DisclaimerText
    └── AdPlacement
```

---

## 섹션 1: Hero Section (업로드 화면)

### 배경 디자인

- **배경색**: `#FFE847` (밝은 노란색) - Al Murphy 메인 컬러
- **레이아웃**: 풀와이드, 상하 패딩 80px (모바일: 48px)
- **장식 요소**:
  - 좌측 상단: 관상가 할아버지 캐릭터 일러스트 (200x200px)
  - 우측 하단: 머리카락 캐릭터 일러스트 (150x150px)
  - 배경 전체에 작은 낙서 (별, 화살표, 느낌표) 흩뿌림

### 레이아웃 계층

```
<section className="hero-section bg-yellow-primary min-h-screen relative">
  {/* 배경 장식 */}
  <div className="absolute top-8 left-8">
    <CharacterIllustration type="fortune-teller" /> {/* 관상가 할아버지 */}
  </div>
  <div className="absolute bottom-8 right-8">
    <CharacterIllustration type="hair-monster" /> {/* 머리카락 캐릭터 */}
  </div>

  {/* 메인 콘텐츠 */}
  <div className="max-w-4xl mx-auto px-8 py-20">
    {/* 앱 타이틀 */}
    <header className="text-center mb-16">
      <h1 className="giant-handwriting rotate-[-3deg]">탈모상</h1>
      <div className="scribble-underline-thick" /> {/* 굵은 손그림 밑줄 */}
    </header>

    {/* 메인 카피 */}
    <div className="speech-bubble-large mb-12">
      <p className="headline-bold">이보시오 관상가 양반, 내가 탈모가 될 상인가?</p>
      <p className="body-text">AI 관상가가 그대의 모발 운명을 점지하리라</p>
    </div>

    {/* 업로드 카드 */}
    <div className="upload-card-huge">
      {!photo && <DragDropZoneLarge />}
      {photo && <PreviewSectionLarge />}
    </div>

    {/* 안심 문구 */}
    <div className="reassurance-badge">
      <ShieldCheckIcon />
      <p>업로드한 사진은 분석 후 즉시 삭제됩니다</p>
    </div>
  </div>

  {/* 하단 광고 */}
  <AdBanner position="bottom" />
</section>
```

### 위젯 상세

#### AppTitle (거대한 손글씨 타이틀)

**Before (기존):**
- 폰트: Nanum Pen Script, 64px
- 회전: -2deg

**After (Al Murphy 스타일):**
- **폰트**: Black Han Sans (굵은 한글 폰트) 또는 Jua
- **크기**:
  - 데스크톱: `text-9xl` (128px)
  - 태블릿: `text-8xl` (96px)
  - 모바일: `text-7xl` (72px)
- **색상**: `#1a1a1a` (거의 검정)
- **변형**:
  - `transform: rotate(-3deg)` (더 크게 기울어짐)
  - `text-shadow: 4px 4px 0 #FF69B4` (핫핑크 그림자로 입체감)
- **테두리**: 6px solid black (둘러싸기)
- **배경**: 흰색 타원형 배경 (`background: white; border-radius: 50%; padding: 32px 64px`)
- **애니메이션**: 페이지 로드 시 `bounce` 효과

```css
.giant-handwriting {
  font-family: 'Black Han Sans', 'Jua', sans-serif;
  font-size: clamp(72px, 15vw, 128px);
  font-weight: 900;
  color: #1a1a1a;
  text-shadow: 4px 4px 0 #FF69B4;
  transform: rotate(-3deg);
  background: white;
  border: 6px solid black;
  border-radius: 50%;
  padding: 32px 64px;
  display: inline-block;
  animation: bounce 1s ease-out;
}
```

#### ScribbleUnderlineThick (굵은 손그림 밑줄)

- **두께**: 8px (기존 3px에서 증가)
- **색상**: `#FF4444` (밝은 빨강)
- **스타일**: 더 불규칙하고 울퉁불퉁한 파형
- **크기**: 전체 타이틀 폭의 120% (양옆으로 삐져나감)

#### SpeechBubbleLarge (거대한 말풍선)

**Before (기존):**
- 작은 크림색 박스 + 손그림 테두리

**After (Al Murphy 스타일):**
- **배경**: 흰색
- **테두리**: 8px solid black (매우 굵음)
- **border-radius**: 48px (매우 둥글게)
- **내부 패딩**: 48px (모바일: 32px)
- **그림자**: `12px 12px 0 #000` (하드 그림자, 만화 스타일)
- **회전**: `transform: rotate(1deg)` (살짝 기울어짐)
- **크기**: max-width: 800px (넓게)

```css
.speech-bubble-large {
  background: white;
  border: 8px solid black;
  border-radius: 48px;
  padding: 48px;
  box-shadow: 12px 12px 0 #000;
  transform: rotate(1deg);
  max-width: 800px;
  margin: 0 auto;
}
```

#### HeadlineBold (메인 카피 텍스트)

- **폰트**: Pretendard ExtraBold (기존 Bold에서 업그레이드)
- **크기**:
  - 데스크톱: `text-4xl` (36px)
  - 모바일: `text-3xl` (30px)
- **색상**: `#1a1a1a` (검정)
- **line-height**: 1.2 (타이트하게)

#### UploadCardHuge (거대한 업로드 카드)

**Before (기존):**
- 점선 테두리 + 종이 텍스처
- max-width: 512px

**After (Al Murphy 스타일):**
- **배경**: 흰색
- **테두리**: 10px solid black (매우 굵음)
- **border-radius**: 32px (매우 둥글게)
- **내부 패딩**: 64px (모바일: 40px)
- **그림자**: `16px 16px 0 #000` (하드 그림자)
- **회전**: `transform: rotate(-1deg)` (살짝 기울어짐)
- **크기**: max-width: 900px (넓게)
- **배경 패턴**: 흰색 + 작은 노란색 별 패턴 (subtle)

```css
.upload-card-huge {
  background: white url('data:image/svg+xml,...') repeat; /* 노란 별 패턴 */
  border: 10px solid black;
  border-radius: 32px;
  padding: 64px;
  box-shadow: 16px 16px 0 #000;
  transform: rotate(-1deg);
  max-width: 900px;
  margin: 0 auto;
}
```

#### DragDropZoneLarge (거대한 드래그앤드롭 영역)

**Before (기존):**
- 점선 원 + 작은 아이콘 (64px)

**After (Al Murphy 스타일):**
- **아이콘**: 거대한 카메라 일러스트 SVG (200x200px)
- **텍스트**:
  - "사진을 드래그하거나 클릭하여 업로드"
  - 폰트: Pretendard Bold, `text-2xl` (24px)
  - 색상: `#1a1a1a`
- **원형 배경**:
  - 배경색: `#FFE847` (노란색)
  - 테두리: 8px dashed black
  - 크기: 400x400px (모바일: 300x300px)
  - 회전: `transform: rotate(-2deg)`
- **Hover 효과**:
  - 배경색: `#FF69B4` (핫핑크로 변경)
  - `transform: rotate(2deg) scale(1.05)` (회전 방향 반전 + 확대)
  - 테두리: 8px solid black (실선으로 변경)

```css
.drag-drop-zone-large {
  width: 400px;
  height: 400px;
  background: #FFE847;
  border: 8px dashed black;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  transform: rotate(-2deg);
  cursor: pointer;
  transition: all 0.3s ease;
}

.drag-drop-zone-large:hover {
  background: #FF69B4;
  border-style: solid;
  transform: rotate(2deg) scale(1.05);
}
```

#### PolaroidFrameLarge (거대한 폴라로이드 프레임)

- **테두리**: 24px solid white (매우 두껍게)
- **외곽 테두리**: 6px solid black
- **그림자**: `12px 12px 0 #000` (하드 그림자)
- **회전**: `transform: rotate(2deg)` (기존 1.5deg에서 증가)
- **이미지 크기**: 최대 너비 700px (기존 400px에서 증가)
- **데코레이션**:
  - 우측 상단: 거대한 별 스티커 SVG (80x80px)
  - 좌측 하단: "관상 보러 가자!" 손글씨 화살표 SVG

#### Button (거대한 버튼)

**"관상 보기" 버튼 (Primary CTA)**

**Before (기존):**
- 배경: coral (#E85D4A)
- border-radius: 24px (캡슐)
- 패딩: 48px x 16px
- 폰트: 18px

**After (Al Murphy 스타일):**
- **배경**: `#FF4444` (밝은 빨강)
- **텍스트 색상**: white
- **폰트**: Pretendard ExtraBold, `text-3xl` (30px)
- **패딩**: horizontal: 80px, vertical: 32px (거대하게)
- **border**: 6px solid black
- **border-radius**: 60px (더 둥글게)
- **그림자**: `8px 8px 0 #000` (하드 그림자)
- **Hover**:
  - 배경: `#FFE847` (노란색으로 변경)
  - 텍스트: black
  - `transform: rotate(-3deg) scale(1.1)` (회전 + 확대)
  - 그림자: `12px 12px 0 #000` (그림자 증가)
- **Active**: `transform: rotate(0deg) scale(0.95)`

```css
.btn-primary-huge {
  background: #FF4444;
  color: white;
  font-family: 'Pretendard ExtraBold';
  font-size: 30px;
  padding: 32px 80px;
  border: 6px solid black;
  border-radius: 60px;
  box-shadow: 8px 8px 0 #000;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-primary-huge:hover {
  background: #FFE847;
  color: black;
  transform: rotate(-3deg) scale(1.1);
  box-shadow: 12px 12px 0 #000;
}

.btn-primary-huge:active {
  transform: rotate(0deg) scale(0.95);
  box-shadow: 4px 4px 0 #000;
}
```

**"다시 찍기" 버튼 (Ghost)**

- **배경**: transparent
- **텍스트**: black
- **테두리**: 4px solid black
- **폰트**: Pretendard Bold, `text-xl` (20px)
- **패딩**: 16px 40px
- **border-radius**: 40px
- **Hover**:
  - 배경: white
  - `transform: rotate(2deg)`

#### ReassuranceBadge (안심 배지)

**Before (기존):**
- 작은 크림색 박스 + 아이콘

**After (Al Murphy 스타일):**
- **스타일**: 스티커 느낌
- **배경**: `#00CC66` (밝은 초록)
- **테두리**: 4px solid black
- **border-radius**: 24px
- **패딩**: 16px 32px
- **아이콘**: ShieldCheckIcon, 32px, white
- **텍스트**: Pretendard Bold, 16px, white
- **그림자**: `4px 4px 0 #000`
- **회전**: `transform: rotate(-2deg)`

---

## 섹션 2: Loading Section (로딩 화면)

### 배경 디자인

- **배경색**: `#FF69B4` (핫핑크) - Al Murphy 섹션 2 컬러
- **레이아웃**: 풀와이드, 중앙 정렬, min-height: 100vh
- **장식 요소**:
  - 배경 전체에 반투명 별 패턴 흩뿌림
  - 좌우에 응원하는 캐릭터 일러스트 (예: 응원봉 들고 있는 머리카락)

### 레이아웃 계층

```
<section className="loading-section bg-pink-primary min-h-screen relative">
  {/* 배경 장식 */}
  <div className="star-pattern-overlay" />

  {/* 메인 콘텐츠 */}
  <div className="max-w-4xl mx-auto px-8 py-20 text-center">
    {/* 로딩 애니메이션 */}
    <div className="loading-animation-large mb-16">
      <HairFallingAnimationLarge />
      <MagnifyingGlassIconHuge />
    </div>

    {/* 로딩 메시지 */}
    <div className="message-bubble-large mb-12">
      <p className="loading-message-text">{currentMessage}</p>
    </div>

    {/* 프로그레스 바 */}
    <ProgressBarHuge value={progress} />

    {/* 광고 */}
    <AdBanner position="center" />
  </div>
</section>
```

### 위젯 상세

#### LoadingAnimationLarge (거대한 로딩 애니메이션)

- **HairFallingAnimationLarge**:
  - 머리카락 SVG 크기: 8px x 60px (기존 2px x 20px에서 증가)
  - 개수: 10-15개 (기존 3-5개에서 증가)
  - 색상: black
  - 애니메이션: 더 느리게 (4s → 5s)

- **MagnifyingGlassIconHuge**:
  - 크기: 200px (기존 80px에서 증가)
  - 색상: black
  - 배경: 흰색 원형 (`background: white; border-radius: 50%; padding: 40px`)
  - 테두리: 6px solid black
  - 그림자: `8px 8px 0 #000`
  - 애니메이션: `rotate` (2s linear infinite)

#### MessageBubbleLarge (거대한 메시지 말풍선)

- **배경**: white
- **테두리**: 8px solid black
- **border-radius**: 48px
- **패딩**: 48px
- **그림자**: `12px 12px 0 #000`
- **텍스트**:
  - 폰트: Jua (손글씨 느낌), `text-4xl` (36px)
  - 색상: black
  - 애니메이션: Fade in/out (300ms)

#### ProgressBarHuge (거대한 프로그레스 바)

**Before (기존):**
- 높이: 12px
- 손그림 느낌 clip-path

**After (Al Murphy 스타일):**
- **배경**: white
- **테두리**: 6px solid black
- **높이**: 48px (기존 12px에서 증가)
- **border-radius**: 24px
- **진행 바**:
  - 배경: `linear-gradient(90deg, #FFE847 0%, #FF4444 50%, #00CC66 100%)` (노란→빨강→초록)
  - 테두리: 없음
  - border-radius: 20px (내부)
  - 애니메이션: `slide-in` (좌→우로 이동)
- **그림자**: `8px 8px 0 #000`
- **퍼센트 표시**:
  - 위치: 프로그레스 바 중앙
  - 폰트: Pretendard ExtraBold, `text-2xl` (24px)
  - 색상: black
  - 텍스트: "{progress}%"

```css
.progress-bar-huge {
  position: relative;
  width: 100%;
  height: 48px;
  background: white;
  border: 6px solid black;
  border-radius: 24px;
  box-shadow: 8px 8px 0 #000;
  overflow: hidden;
}

.progress-bar-huge .progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #FFE847 0%, #FF4444 50%, #00CC66 100%);
  border-radius: 20px;
  transition: width 0.5s ease;
}

.progress-bar-huge .progress-percent {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-family: 'Pretendard ExtraBold';
  font-size: 24px;
  color: black;
  z-index: 10;
}
```

---

## 섹션 3: Result Section (결과 화면)

### 배경 디자인

- **배경색**: `#87CEEB` (하늘색) - Al Murphy 섹션 3 컬러
- **레이아웃**: 풀와이드, 상하 패딩 80px
- **장식 요소**:
  - 배경 전체에 구름 일러스트 흩뿌림
  - 좌우에 축하하는 캐릭터 일러스트

### 레이아웃 계층

```
<section className="result-section bg-sky-blue min-h-screen relative">
  {/* 배경 장식 */}
  <div className="cloud-pattern-overlay" />

  {/* 메인 콘텐츠 */}
  <div className="max-w-5xl mx-auto px-8 py-20">
    {/* 결과 제목 */}
    <header className="text-center mb-16">
      <h2 className="result-title-huge">관상 결과가 나왔사옵니다!</h2>
      <div className="star-decoration-large" />
    </header>

    {/* 결과 카드들 (각각 독립된 큰 박스) */}
    <div className="result-cards-grid">
      {/* 등급 카드 */}
      <ResultCardHuge type="grade">
        <GradeBadgeHuge grade={grade} />
      </ResultCardHuge>

      {/* 모발 나이 카드 */}
      <ResultCardHuge type="hair-age">
        <HairAgeDisplay hairAge={hairAge} />
      </ResultCardHuge>

      {/* 확률 카드 */}
      <ResultCardHuge type="probability">
        <ProbabilityDisplay probability={probability} />
      </ResultCardHuge>

      {/* 유명인 카드 */}
      <ResultCardHuge type="celebrity">
        <CelebritySpeechBubbleHuge celebrity={celebrity} />
      </ResultCardHuge>

      {/* 관리 팁 카드 */}
      <ResultCardHuge type="tips">
        <TipsChecklistHuge tips={tips} />
      </ResultCardHuge>
    </div>

    {/* 종합 코멘트 */}
    <div className="comment-box-huge mb-16">
      <QuoteIconHuge />
      <p className="comment-text-large">{overallComment}</p>
    </div>

    {/* 광고 */}
    <AdBanner position="middle" />

    {/* 시뮬레이션 이미지 */}
    <div className="simulation-card-huge mb-16">
      <SimulationScrollFrame />
    </div>

    {/* 액션 버튼 */}
    <div className="action-buttons-large">
      <Button variant="secondary-huge" onClick={retry}>다시 관상 보기</Button>
      <Button variant="primary-huge" onClick={share}>공유하기</Button>
    </div>

    {/* 광고 */}
    <AdBanner position="bottom" />
  </div>
</section>
```

### 위젯 상세

#### ResultTitleHuge (거대한 결과 제목)

- **폰트**: Jua (손글씨), `text-7xl` (72px) (모바일: `text-5xl` 48px)
- **색상**: black
- **텍스트 그림자**: `4px 4px 0 #FFE847` (노란색 그림자)
- **테두리**: 8px solid black
- **배경**: white
- **border-radius**: 48px
- **패딩**: 32px 64px
- **그림자**: `12px 12px 0 #000`
- **회전**: `transform: rotate(-2deg)`
- **애니메이션**: Bounce + Fade (1s)

#### ResultCardHuge (거대한 결과 카드)

**Before (기존):**
- 단일 카드에 모든 결과
- 종이 텍스처 + 연필 테두리

**After (Al Murphy 스타일):**
- **각 결과 항목을 독립된 카드로 분리**
- **배경**: white
- **테두리**: 8px solid black
- **border-radius**: 32px
- **내부 패딩**: 48px (모바일: 32px)
- **그림자**: `12px 12px 0 #000`
- **회전**: 각 카드마다 다르게 (-2deg, 1deg, -1deg 등)
- **간격**: 카드 간 32px
- **레이아웃**: 데스크톱에서는 2열 그리드 (grid-cols-2), 모바일은 1열

```css
.result-card-huge {
  background: white;
  border: 8px solid black;
  border-radius: 32px;
  padding: 48px;
  box-shadow: 12px 12px 0 #000;
  transition: transform 0.3s ease;
}

.result-card-huge:nth-child(1) { transform: rotate(-2deg); }
.result-card-huge:nth-child(2) { transform: rotate(1deg); }
.result-card-huge:nth-child(3) { transform: rotate(-1deg); }

.result-card-huge:hover {
  transform: rotate(0deg) scale(1.05);
  box-shadow: 16px 16px 0 #000;
}

.result-cards-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 32px;
  margin-bottom: 64px;
}

@media (max-width: 768px) {
  .result-cards-grid {
    grid-template-columns: 1fr;
  }
}
```

#### GradeBadgeHuge (거대한 등급 배지)

**Before (기존):**
- 도장 스탬프 SVG, 120x120px

**After (Al Murphy 스타일):**
- **크기**: 300x300px (거대하게)
- **스타일**: 스티커 느낌
- **배경**:
  - A등급: `#00CC66` (초록)
  - B등급: `#FFE847` (노란)
  - C등급: `#FF9800` (오렌지)
  - D등급: `#FF4444` (빨강)
- **테두리**: 10px solid black
- **border-radius**: 50% (원형)
- **그림자**: `12px 12px 0 #000`
- **회전**: `transform: rotate(-8deg)` (더 크게 기울어짐)
- **내부 구조**:
  - 등급 텍스트: Pretendard ExtraBold, `text-7xl` (72px), white
  - 설명 텍스트: Pretendard Bold, `text-2xl` (24px), white
  - 아이콘: 100x100px (거대 이모지)

```css
.grade-badge-huge {
  width: 300px;
  height: 300px;
  background: var(--grade-color);
  border: 10px solid black;
  border-radius: 50%;
  box-shadow: 12px 12px 0 #000;
  transform: rotate(-8deg);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

.grade-badge-huge .grade-text {
  font-family: 'Pretendard ExtraBold';
  font-size: 72px;
  color: white;
}

.grade-badge-huge .grade-icon {
  font-size: 100px;
}
```

#### HairAgeDisplay (모발 나이 표시)

- **레이아웃**: 세로 중앙 정렬
- **Label**: "모발 나이" (Pretendard Bold, `text-3xl` 30px, black)
- **Value**:
  - 폰트: Pretendard ExtraBold, `text-9xl` (128px), black
  - 텍스트 그림자: `4px 4px 0 #FFE847`
  - 카운트업 애니메이션: 0 → 실제 값 (2초)
- **Comparison**:
  - "실제 나이보다 5살 젊음" (Pretendard Bold, `text-2xl` 24px)
  - 색상: 젊으면 `#00CC66`, 많으면 `#FF4444`
  - 배경: 작은 스티커 느낌 (`background: white; border: 4px solid black; border-radius: 20px; padding: 8px 16px`)

#### ProbabilityDisplay (확률 표시)

- **Label**: "5년 내 탈모 확률" (Pretendard Bold, `text-3xl` 30px)
- **Progress Bar**: 앞서 정의한 ProgressBarHuge 재사용
- **Value**:
  - 폰트: Pretendard ExtraBold, `text-8xl` (96px)
  - 색상:
    - 0-30%: `#00CC66` (안전)
    - 31-60%: `#FFE847` (주의)
    - 61-100%: `#FF4444` (위험)
  - 배경: 원형 스티커 (`border-radius: 50%; background: white; border: 6px solid black; width: 200px; height: 200px`)

#### CelebritySpeechBubbleHuge (거대한 유명인 말풍선)

- **배경**: white
- **테두리**: 8px solid black
- **border-radius**: 48px
- **패딩**: 40px
- **그림자**: `12px 12px 0 #000`
- **꼬리**: CSS ::after로 삼각형 (크기 증가: 30px)
- **텍스트**: Pretendard Bold, `text-3xl` (30px), black
- **아이콘**: UserIcon (80px, 좌측)
- **배경 패턴**: 작은 하트 패턴 (subtle)

#### TipsChecklistHuge (거대한 관리 팁 체크리스트)

- **li 스타일**:
  - 아이콘: CheckIcon, 48px, `#00CC66`
  - 텍스트: Pretendard Medium, `text-2xl` (24px), black
  - 간격: 24px
  - 배경: white
  - 테두리: 4px solid black
  - border-radius: 24px
  - 패딩: 20px 32px
  - 그림자: `6px 6px 0 #000`
  - 각 항목마다 살짝 다른 회전 (-1deg, 1deg, 0deg)

#### CommentBoxHuge (거대한 종합 코멘트 박스)

- **배경**: white
- **테두리**: 8px solid black
- **border-radius**: 32px
- **패딩**: 64px
- **그림자**: `16px 16px 0 #000`
- **QuoteIconHuge**:
  - 크기: 120px
  - 색상: `#FFE847` (노란색, 50% 투명도)
  - 위치: 좌측 상단
- **텍스트**:
  - 폰트: Pretendard Medium, `text-3xl` (30px)
  - 색상: black
  - line-height: 1.6
  - 스타일: italic

#### SimulationScrollFrame (시뮬레이션 족자 프레임)

**Before (기존):**
- 오래된 양피지 느낌, 나무 프레임

**After (Al Murphy 스타일):**
- **배경**: 흰색
- **테두리**: 12px solid black (매우 굵음)
- **border-radius**: 48px
- **패딩**: 64px
- **그림자**: `20px 20px 0 #000` (최대 그림자)
- **Title**:
  - "10년 뒤의 그대 모습"
  - 폰트: Jua, `text-6xl` (60px), black
  - 텍스트 그림자: `4px 4px 0 #FF69B4`
- **Image**:
  - 최대 너비: 800px
  - border-radius: 24px
  - 테두리: 6px solid black
  - 그림자: `8px 8px 0 #000`
- **Decoration**:
  - 우측 하단: 거대한 화살표 SVG (150x75px)
  - 좌측 상단: "OMG!" 손글씨 스티커

#### ActionButtonsLarge (거대한 액션 버튼)

**"다시 관상 보기" 버튼 (Secondary)**

- **배경**: white
- **텍스트**: black
- **테두리**: 6px solid black
- **폰트**: Pretendard ExtraBold, `text-2xl` (24px)
- **패딩**: 24px 64px
- **border-radius**: 48px
- **그림자**: `8px 8px 0 #000`
- **Hover**:
  - 배경: `#FFE847` (노란색)
  - `transform: rotate(-2deg) scale(1.05)`

**"공유하기" 버튼 (Primary)**

- **배경**: `#FF4444` (빨강)
- **텍스트**: white
- **테두리**: 6px solid black
- **폰트**: Pretendard ExtraBold, `text-3xl` (30px)
- **패딩**: 32px 80px
- **border-radius**: 60px
- **그림자**: `12px 12px 0 #000`
- **아이콘**: ShareIcon (48px, 좌측)
- **Hover**:
  - 배경: `#00CC66` (초록색)
  - `transform: rotate(3deg) scale(1.1)`
  - 그림자: `16px 16px 0 #000`

---

## 색상 팔레트 (Al Murphy 영감)

### Primary Colors (섹션 배경)

- **Yellow Primary** (`--color-bg-yellow`): `#FFE847` — 메인 배경 (Hero Section)
- **Pink Primary** (`--color-bg-pink`): `#FF69B4` — 로딩 섹션 배경
- **Sky Blue** (`--color-bg-sky-blue`): `#87CEEB` — 결과 섹션 배경
- **Dark Green** (`--color-bg-dark-green`): `#2D5F3F` — 푸터 배경

### Accent Colors (UI 요소)

- **Black** (`--color-black`): `#1a1a1a` — 텍스트, 테두리 (거의 모든 곳)
- **White** (`--color-white`): `#FFFFFF` — 카드 배경, 버튼 텍스트
- **Red Accent** (`--color-accent-red`): `#FF4444` — CTA 버튼, 위험 상태
- **Green Accent** (`--color-accent-green`): `#00CC66` — 안전 상태, 성공
- **Orange Accent** (`--color-accent-orange`): `#FF9800` — 주의 상태

### Semantic Colors

- **Success**: `--color-accent-green` (#00CC66)
- **Warning**: `--color-accent-orange` (#FF9800)
- **Error**: `--color-accent-red` (#FF4444)
- **Info**: `--color-bg-sky-blue` (#87CEEB)

### 기존 크림색 제거

기존 디자인의 크림 색상 (`#FFF8F0`, `#FFFBF5`, `#F5E6D3`)은 **완전히 제거**하고, 위 원색 팔레트로 대체합니다.

---

## 타이포그래피 (대담하고 거대하게)

### 폰트 패밀리

- **손글씨/타이틀 폰트**:
  - **Black Han Sans** (주요 타이틀) - 굵은 한글 폰트
  - **Jua** (로딩 메시지, 결과 제목) - 둥글고 귀여운 손글씨
- **본문 폰트**: Pretendard (본문, 버튼, 라벨)
  - ExtraBold (900) - CTA 버튼, 큰 숫자
  - Bold (700) - 제목, 강조
  - Medium (500) - 본문

### Type Scale (거대하게 증가)

#### Display (손글씨 폰트)

- **display-giant** (앱 타이틀):
  - fontSize: `text-9xl` (128px) → 모바일 `text-7xl` (72px)
  - fontWeight: 900
  - fontFamily: Black Han Sans

- **display-large** (결과 제목):
  - fontSize: `text-7xl` (72px) → 모바일 `text-5xl` (48px)
  - fontWeight: 700
  - fontFamily: Jua

- **display-medium** (로딩 메시지):
  - fontSize: `text-4xl` (36px) → 모바일 `text-3xl` (30px)
  - fontWeight: 400
  - fontFamily: Jua

#### Headline (본문 폰트)

- **headline-huge** (메인 카피):
  - fontSize: `text-4xl` (36px) → 모바일 `text-3xl` (30px)
  - fontWeight: 900 (ExtraBold)
  - fontFamily: Pretendard

- **headline-large** (카드 제목):
  - fontSize: `text-3xl` (30px) → 모바일 `text-2xl` (24px)
  - fontWeight: 700 (Bold)
  - fontFamily: Pretendard

#### Body

- **body-huge** (종합 코멘트):
  - fontSize: `text-3xl` (30px) → 모바일 `text-2xl` (24px)
  - fontWeight: 500 (Medium)
  - lineHeight: 1.6
  - fontFamily: Pretendard

- **body-large** (일반 본문):
  - fontSize: `text-2xl` (24px) → 모바일 `text-xl` (20px)
  - fontWeight: 400
  - lineHeight: 1.5
  - fontFamily: Pretendard

#### Label

- **label-huge** (CTA 버튼):
  - fontSize: `text-3xl` (30px) → 모바일 `text-2xl` (24px)
  - fontWeight: 900 (ExtraBold)
  - fontFamily: Pretendard

- **label-large** (일반 버튼):
  - fontSize: `text-2xl` (24px) → 모바일 `text-xl` (20px)
  - fontWeight: 700 (Bold)
  - fontFamily: Pretendard

---

## 스페이싱 시스템 (넉넉하게)

### Padding/Margin (기존의 2배)

- **xs**: 8px (기존 4px)
- **sm**: 16px (기존 8px)
- **md**: 32px (기존 16px)
- **lg**: 48px (기존 24px)
- **xl**: 64px (기존 32px)
- **2xl**: 96px (기존 48px)
- **3xl**: 128px (기존 64px)

### 컴포넌트별 스페이싱

- **섹션 패딩**: 80px (좌우상하) (모바일: 48px)
- **카드 내부 패딩**: 48px (데스크톱), 32px (모바일)
- **카드 간 간격**: 32px
- **버튼 내부 패딩**:
  - Primary Huge: horizontal 80px, vertical 32px
  - Secondary Large: horizontal 64px, vertical 24px
  - Ghost: horizontal 40px, vertical 16px

---

## Border Radius (둥글게)

- **small**: 16px (기존 8px)
- **medium**: 24px (기존 12px)
- **large**: 32px (기존 16px)
- **xlarge**: 48px (기존 24px)
- **huge**: 60px (새로 추가, 거대한 버튼)
- **round**: 50% (원형)

---

## Elevation (하드 그림자)

**기존 soft 그림자 제거**, Al Murphy 스타일의 **하드 그림자** 사용:

- **Level 0**: none
- **Level 1**: `4px 4px 0 #000` — 작은 요소 (배지, 작은 버튼)
- **Level 2**: `6px 6px 0 #000` — 리스트 항목
- **Level 3**: `8px 8px 0 #000` — 일반 버튼, 작은 카드
- **Level 4**: `12px 12px 0 #000` — 큰 카드, 말풍선
- **Level 5**: `16px 16px 0 #000` — 최상위 레이어 (종합 코멘트)
- **Level 6**: `20px 20px 0 #000` — 시뮬레이션 프레임

---

## 인터랙션 상태

### 버튼 상태 (대담하게)

**Primary Huge Button**

- **Default**:
  - 배경 `#FF4444`, 텍스트 white
  - 테두리 6px solid black
  - 그림자 Level 3 (`8px 8px 0 #000`)
- **Hover**:
  - 배경 `#FFE847`, 텍스트 black
  - `transform: rotate(-3deg) scale(1.1)`
  - 그림자 Level 4 (`12px 12px 0 #000`)
- **Active**:
  - `transform: rotate(0deg) scale(0.95)`
  - 그림자 Level 1 (`4px 4px 0 #000`)

### 카드 상태

**UploadCardHuge**

- **Default**:
  - 테두리 10px solid black
  - 그림자 Level 5 (`16px 16px 0 #000`)
  - `transform: rotate(-1deg)`
- **Hover**:
  - 배경 약간 밝아짐
  - `transform: rotate(1deg) scale(1.02)`
  - 그림자 Level 6 (`20px 20px 0 #000`)

### 드래그앤드롭 영역

- **Default**:
  - 배경 `#FFE847`
  - 테두리 8px dashed black
  - `transform: rotate(-2deg)`
- **Hover**:
  - 배경 `#FF69B4`
  - 테두리 8px solid black
  - `transform: rotate(2deg) scale(1.05)`
- **Active (드래그 중)**:
  - 배경 `#00CC66`
  - 테두리 8px solid black
  - `transform: rotate(0deg) scale(1.1)`

---

## 애니메이션 (더 대담하게)

### 화면 전환

- **Fade In/Out**:
  - Duration: 400ms (기존 300ms)
  - Curve: ease-in-out

- **Bounce**:
  - Duration: 1s
  - Curve: cubic-bezier(0.68, -0.55, 0.265, 1.55)
  - 사용: 타이틀 등장

```css
@keyframes bounce {
  0% {
    opacity: 0;
    transform: scale(0.3) rotate(-45deg);
  }
  50% {
    transform: scale(1.1) rotate(5deg);
  }
  70% {
    transform: scale(0.9) rotate(-3deg);
  }
  100% {
    opacity: 1;
    transform: scale(1) rotate(-3deg);
  }
}
```

### 요소 애니메이션

**Shake (기존 유지, 더 강하게)**
```css
@keyframes shake {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(5deg); } /* 기존 2deg → 5deg */
  75% { transform: rotate(-5deg); }
}
```

**Wiggle (좌우 흔들림)**
```css
@keyframes wiggle {
  0%, 100% { transform: translateX(0) rotate(0deg); }
  25% { transform: translateX(-8px) rotate(-2deg); } /* 기존 -4px → -8px */
  75% { transform: translateX(8px) rotate(2deg); }
}
```

**Rotate (회전)**
```css
@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
```

---

## 반응형 레이아웃

### Breakpoints

- **Mobile**: width < 640px
- **Tablet**: 640px ≤ width < 1024px
- **Desktop**: width ≥ 1024px

### 적응형 레이아웃 전략

#### Mobile (< 640px)

- **단일 컬럼**: 모든 카드 세로 배치
- **섹션 패딩**: 48px (좌우상하)
- **폰트 크기**: 작은 사이즈 (예: `text-9xl` → `text-7xl`)
- **버튼**: 전체 너비 (width: 100%), 세로 배치
- **카드**: 전체 너비, 패딩 32px
- **결과 카드 그리드**: 1열

#### Tablet (640px - 1023px)

- **단일 컬럼 또는 2열**: 컨텐츠에 따라
- **섹션 패딩**: 64px
- **결과 카드 그리드**: 2열 (작은 카드는 계속 1열)

#### Desktop (≥ 1024px)

- **2열 레이아웃**: 결과 카드 그리드
- **섹션 패딩**: 80px
- **최대 너비**:
  - Hero/Loading: max-w-4xl (896px)
  - Result: max-w-5xl (1024px)
- **카드**: 최대 너비 제한 없음 (그리드에 맞춤)

---

## 접근성 (Accessibility)

### 색상 대비

- **Black (#1a1a1a) on Yellow (#FFE847)**: 대비 약 10:1 (WCAG AAA)
- **Black on Pink (#FF69B4)**: 대비 약 8:1 (WCAG AAA)
- **Black on Sky Blue (#87CEEB)**: 대비 약 9:1 (WCAG AAA)
- **White on Red (#FF4444)**: 대비 약 5.5:1 (WCAG AA)

### 의미 전달

- **색상 + 아이콘 + 텍스트** 병행 사용
- 에러: 빨간색 배경 + AlertCircle 아이콘 + "오류 발생" 텍스트
- 성공: 초록색 배경 + CheckCircle 아이콘 + "완료" 텍스트

### 키보드 내비게이션

- **Tab 순서**: 위→아래, 좌→우
- **Focus 스타일**:
  - 테두리: 4px solid black
  - 배경: `#FFE847` (노란색 하이라이트)
  - Outline: 4px solid black (접근성)

---

## 장식 요소 (SVG 일러스트)

### 캐릭터 일러스트 (CSS/SVG로 구현)

#### FortunetellerCharacter (관상가 할아버지)

- **크기**: 200x200px
- **스타일**: 간단한 SVG 캐릭터
- **색상**: black (선), white (채우기), `#FF69B4` (장식)
- **특징**: 수염, 두루마기, 돋보기 들고 있음
- **위치**: Hero Section 좌측 상단

```html
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <!-- 머리 (원형) -->
  <circle cx="100" cy="80" r="40" fill="white" stroke="black" stroke-width="4"/>

  <!-- 수염 (곡선 패스) -->
  <path d="M70 100 Q100 120 130 100" fill="none" stroke="black" stroke-width="4"/>

  <!-- 두루마기 (사각형) -->
  <rect x="60" y="120" width="80" height="70" fill="#FF69B4" stroke="black" stroke-width="4" rx="10"/>

  <!-- 돋보기 (원 + 손잡이) -->
  <circle cx="140" cy="150" r="20" fill="none" stroke="black" stroke-width="4"/>
  <line x1="155" y1="165" x2="170" y2="180" stroke="black" stroke-width="4"/>
</svg>
```

#### HairMonsterCharacter (머리카락 캐릭터)

- **크기**: 150x150px
- **스타일**: 귀여운 머리카락 덩어리 캐릭터 (눈, 입)
- **색상**: black (머리카락), white (눈), `#FF4444` (입)
- **특징**: 곱슬머리, 웃는 얼굴
- **위치**: Hero Section 우측 하단, Result Section 좌우

### 스티커/배지 SVG

#### StickerBurst (스티커 효과)

- **크기**: 80x80px
- **스타일**: 별모양 터짐 효과
- **색상**: `#FFE847`, `#FF69B4`, `#87CEEB` (다채롭게)
- **사용**: 카드 모서리 장식

### 낙서 요소 (Doodle)

#### DoodleStars (작은 별 낙서)

- **크기**: 24x24px
- **개수**: 배경 전체에 15-20개 흩뿌림
- **색상**: black (50% 투명도)
- **회전**: 랜덤 (-20deg ~ 20deg)

#### DoodleArrows (화살표 낙서)

- **크기**: 60x30px
- **스타일**: 손그림 구불구불 화살표
- **색상**: black
- **사용**: 주목해야 할 요소 옆

---

## shadcn/ui 컴포넌트 커스터마이징

### Card (완전히 재설계)

기존 shadcn/ui Card의 soft 스타일 대신 **Al Murphy 하드 스타일** 적용:

```tsx
// components/ui/card-huge.tsx
export function CardHuge({ className, children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        "bg-white",
        "border-[8px] border-black",
        "rounded-[32px]",
        "p-12",
        "shadow-[12px_12px_0_#000]",
        "transition-all duration-300",
        "hover:shadow-[16px_16px_0_#000]",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
```

### Button (완전히 재설계)

```tsx
// components/ui/button-huge.tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center font-extrabold transition-all duration-300 cursor-pointer",
  {
    variants: {
      variant: {
        "primary-huge": [
          "bg-[#FF4444] text-white",
          "border-[6px] border-black",
          "rounded-[60px]",
          "px-20 py-8",
          "text-3xl",
          "shadow-[8px_8px_0_#000]",
          "hover:bg-[#FFE847] hover:text-black",
          "hover:rotate-[-3deg] hover:scale-110",
          "hover:shadow-[12px_12px_0_#000]",
          "active:rotate-0 active:scale-95",
          "active:shadow-[4px_4px_0_#000]",
        ],
        "secondary-huge": [
          "bg-white text-black",
          "border-[6px] border-black",
          "rounded-[48px]",
          "px-16 py-6",
          "text-2xl",
          "shadow-[8px_8px_0_#000]",
          "hover:bg-[#FFE847]",
          "hover:rotate-[-2deg] hover:scale-105",
        ],
      },
    },
    defaultVariants: {
      variant: "primary-huge",
    },
  }
);
```

### Progress (재설계)

```tsx
// components/ui/progress-huge.tsx
export function ProgressHuge({ value }: { value: number }) {
  return (
    <div className="relative w-full h-12 bg-white border-[6px] border-black rounded-[24px] shadow-[8px_8px_0_#000] overflow-hidden">
      <div
        className="h-full bg-gradient-to-r from-[#FFE847] via-[#FF4444] to-[#00CC66] rounded-[20px] transition-all duration-500"
        style={{ width: `${value}%` }}
      />
      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 font-extrabold text-2xl text-black z-10">
        {value}%
      </div>
    </div>
  );
}
```

### Badge (스티커 스타일)

```tsx
// components/ui/badge-sticker.tsx
export function BadgeSticker({ children, color }: { children: React.ReactNode; color: string }) {
  return (
    <div
      className="inline-flex items-center justify-center bg-white border-[4px] border-black rounded-[20px] px-6 py-2 shadow-[4px_4px_0_#000] rotate-[-2deg] font-bold text-lg"
      style={{ backgroundColor: color }}
    >
      {children}
    </div>
  );
}
```

---

## 에러 처리 UI (대담하게)

### 에러 메시지 스타일

- **배경**: `#FF4444` (빨강)
- **테두리**: 6px solid black
- **border-radius**: 24px
- **패딩**: 32px
- **그림자**: `8px 8px 0 #000`
- **아이콘**: AlertCircleIcon, 64px, white
- **텍스트**:
  - 폰트: Pretendard Bold, `text-2xl` (24px)
  - 색상: white
  - 사극 말투: "아이고, 관상가 양반이 잠시 자리를 비웠사옵니다!"

### 에러 종류별 메시지 (기존과 동일, 스타일만 변경)

모든 에러 메시지는 위 스타일 적용, 텍스트는 기존과 동일 유지.

---

## 광고 배치

### Google AdSense 영역 (스타일 변경)

**광고 컨테이너 스타일**

- **배경**: white
- **테두리**: 4px solid black
- **border-radius**: 16px
- **패딩**: 24px
- **그림자**: `6px 6px 0 #000`
- **label**: "광고" (Pretendard Bold, 12px, black, 상단 중앙)

**위치 및 크기 (기존과 동일)**

1. Hero Section 하단
2. Loading Section 하단
3. Result Section 중간
4. Result Section 하단

---

## 면책 고지 (Disclaimer)

### 위치 및 스타일

- **위치**: Footer (다크 그린 배경 섹션)
- **배경**: `#2D5F3F` (다크 그린)
- **텍스트**: white, Pretendard Regular, 14px
- **테두리**: 4px solid white
- **border-radius**: 16px
- **패딩**: 32px
- **정렬**: center

---

## Web Share API (기존과 동일)

기존 명세 유지, 버튼 스타일만 Al Murphy 스타일 적용.

---

## 성능 최적화 (기존과 동일)

기존 명세 유지.

---

## 다크 모드

**지원하지 않음** — Al Murphy 스타일은 밝은 원색 배경에 최적화.

---

## Tailwind CSS v4 설정

### globals.css

```css
@import "tailwindcss";

/* Al Murphy 색상 변수 */
@theme {
  --color-bg-yellow: #FFE847;
  --color-bg-pink: #FF69B4;
  --color-bg-sky-blue: #87CEEB;
  --color-bg-dark-green: #2D5F3F;
  --color-black: #1a1a1a;
  --color-white: #FFFFFF;
  --color-accent-red: #FF4444;
  --color-accent-green: #00CC66;
  --color-accent-orange: #FF9800;

  /* 폰트 */
  --font-black-han: 'Black Han Sans', sans-serif;
  --font-jua: 'Jua', sans-serif;
  --font-pretendard: 'Pretendard Variable', sans-serif;

  /* 스페이싱 */
  --spacing-xs: 8px;
  --spacing-sm: 16px;
  --spacing-md: 32px;
  --spacing-lg: 48px;
  --spacing-xl: 64px;
  --spacing-2xl: 96px;
  --spacing-3xl: 128px;

  /* Border Radius */
  --radius-sm: 16px;
  --radius-md: 24px;
  --radius-lg: 32px;
  --radius-xl: 48px;
  --radius-huge: 60px;

  /* 그림자 (하드 그림자) */
  --shadow-1: 4px 4px 0 #000;
  --shadow-2: 6px 6px 0 #000;
  --shadow-3: 8px 8px 0 #000;
  --shadow-4: 12px 12px 0 #000;
  --shadow-5: 16px 16px 0 #000;
  --shadow-6: 20px 20px 0 #000;
}

/* 전역 스타일 */
body {
  background-color: var(--color-bg-yellow);
  color: var(--color-black);
  font-family: var(--font-pretendard);
}

/* 섹션 배경 */
.bg-yellow-primary {
  background-color: var(--color-bg-yellow);
}

.bg-pink-primary {
  background-color: var(--color-bg-pink);
}

.bg-sky-blue {
  background-color: var(--color-bg-sky-blue);
}

.bg-dark-green {
  background-color: var(--color-bg-dark-green);
}

/* 애니메이션 */
@keyframes bounce {
  0% {
    opacity: 0;
    transform: scale(0.3) rotate(-45deg);
  }
  50% {
    transform: scale(1.1) rotate(5deg);
  }
  70% {
    transform: scale(0.9) rotate(-3deg);
  }
  100% {
    opacity: 1;
    transform: scale(1) rotate(-3deg);
  }
}

@keyframes shake {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(5deg); }
  75% { transform: rotate(-5deg); }
}

@keyframes wiggle {
  0%, 100% { transform: translateX(0) rotate(0deg); }
  25% { transform: translateX(-8px) rotate(-2deg); }
  75% { transform: translateX(8px) rotate(2deg); }
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.animate-bounce-in {
  animation: bounce 1s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

.animate-shake {
  animation: shake 0.5s ease-in-out;
}

.animate-wiggle {
  animation: wiggle 0.5s ease-in-out;
}

.animate-rotate {
  animation: rotate 2s linear infinite;
}
```

### postcss.config.mjs

```js
export default {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
```

---

## 참고 자료

### 디자인 영감

- **Al Murphy 웹사이트**: https://www.al-murphy.com — 메인 레퍼런스
- **Kittl Graphic Design Trends 2026**: https://www.kittl.com/blogs/graphic-design-trends-2026/
- **99designs Hand-drawn Websites**: https://99designs.com/inspiration/websites/hand-drawn

### 한국어 폰트

- **Black Han Sans**: https://fonts.google.com/specimen/Black+Han+Sans
- **Jua**: https://fonts.google.com/specimen/Jua
- **Pretendard**: https://github.com/orioncactus/pretendard

### 기술 문서

- **Next.js 16 App Router**: https://nextjs.org/docs
- **Tailwind CSS v4**: https://tailwindcss.com/
- **shadcn/ui**: https://ui.shadcn.com/

---

## 다음 단계

이 디자인 명세를 기반으로:

1. **Tech Lead**가 `tech-brief.md` 작성 (Tailwind CSS v4 마이그레이션, 폰트 설정, 컴포넌트 구조)
2. **Web Developer**가 컴포넌트 재구현 시작

**출력물**: `docs/talmosang/talmosang-design/web-design-spec.md`

---

## 핵심 변경 요약

| 항목 | 기존 | Al Murphy 재설계 |
|------|------|----------------|
| **배경색** | 크림 (#FFF8F0) | 노란 (#FFE847) + 섹션별 색상 |
| **레이아웃** | max-w-lg (512px) | 풀와이드 (max-w-4xl~5xl) |
| **타이포** | text-4xl (36px) | text-9xl (128px) |
| **테두리** | 2px soft | 6-10px solid black |
| **그림자** | soft blur | hard shadow (12px 12px 0 #000) |
| **버튼** | 24px radius, 16px padding | 60px radius, 32px padding |
| **색상** | 파스텔 | 원색 (red, yellow, pink, green) |
| **장식** | 미세한 노이즈 | 대형 일러스트 캐릭터 |
| **카드** | 단일 큰 카드 | 독립된 여러 카드 (2열 그리드) |

이 명세는 Al Murphy의 대담하고 맥시멀리스트 스타일을 탈모상에 완전히 적용하여, 강렬한 첫인상과 바이럴 확산을 극대화하는 것을 목표로 합니다.

---

## 캐릭터 시스템 (page-design v2)

> 추가일: 2026-02-16 | 기반: page-design-research.md

### 컴포넌트 구조

```
components/
├── characters/
│   ├── FortuneTeller.tsx      # 관상가 영감 (메인 가이드)
│   ├── HairFairy.tsx          # 머리카락 요정 (type prop으로 3종 구분)
│   ├── ScalpGuardian.tsx      # 두피 수호신 장군
│   ├── BaldnessGoblin.tsx     # 탈모 도깨비
│   └── SpeechBubble.tsx       # 캐릭터 대사 말풍선
├── effects/
│   ├── ResultReveal.tsx       # 결과 극적 리빌
│   ├── ScrollParallax.tsx     # 스크롤 패럴랙스 래퍼
│   └── Particles.tsx          # 등급별 파티클 효과
```

### 공통 SVG 규칙
- stroke: `#1a1a1a`, strokeWidth: `3`
- 각 파츠 `<g>` 그룹 + data 속성 (`data-part="beard"`)
- `forwardRef`로 GSAP 접근 지원
- CSS class로 크기 제어 (`w-24 h-24` ~ `w-48 h-48`)
- `aria-hidden="true"` (장식용)

### 캐릭터 1: 관상가 영감 (FortuneTeller)

**SVG 파츠:**
```
<svg viewBox="0 0 200 260">
  <g data-part="hat">         갓 (검정 타원 + 모자)
  <g data-part="face">        둥근 얼굴 (#FFD5B5)
  <g data-part="eyes">        둥근 눈 2개
  <g data-part="beard">       흰 수염 3가닥
  <g data-part="body">        도포 (#87CEEB)
  <g data-part="arm-right">   오른팔 + 돋보기
  <g data-part="magnifier">   돋보기 (#ffe847 테두리)
```

**Props:** `mood: 'idle' | 'examining' | 'happy' | 'worried'`

**등장 위치:**
| 화면 | 위치 | mood | 애니메이션 |
|------|------|------|-----------|
| upload | 헤더 우측 | idle | 수염 흔들림, 눈 깜빡 |
| upload (사진 선택 후) | 미리보기 옆 | examining | 돋보기 좌우 이동 |
| loading | 프로그레스 바 위 | examining | 수염 만지기 |
| result (A/B) | 결과 카드 좌측 | happy | bounce |
| result (C/D) | 결과 카드 좌측 | worried | shake |

**대사 풀 (클릭 시 랜덤):**
- "허허, 어디 한번 살펴보겠소이다"
- "오호라, 이 관상이 범상치 않구려"
- "두피의 기운이 묘하게 흐르고 있사옵니다"
- "관상은 팔자를 이기는 법이오"
- "모발의 운명은 관리에 달렸사옵니다"

### 캐릭터 2: 머리카락 요정 (HairFairy)

**Props:** `type: 'healthy' | 'normal' | 'danger'`

| type | 몸통색 | 표정 | 등장 조건 |
|------|--------|------|----------|
| healthy | #00cc66 | 활짝 웃음 | 등급 A |
| normal | #ffe847 | 보통 | 등급 B-C |
| danger | #ff4444 | 걱정 | 등급 D |

**SVG 파츠:** 길쭉한 곡선 몸통, 둥근 얼굴, 짧은 팔다리 (60-80px)

### 캐릭터 3: 두피 수호신 (ScalpGuardian)

**Props:** `pose: 'guard' | 'celebrate' | 'chase'`

**SVG 파츠:** 투구(검정+빨강 깃털), 갑옷(초록), 방패(노랑 "守")

**등장 위치:** 안심 문구 옆, 관리 팁 헤더, 공유 버튼 옆

### 캐릭터 4: 탈모 도깨비 (BaldnessGoblin)

**Props:** `pose: 'snipping' | 'threatening' | 'fleeing'`

**SVG 파츠:** 뿔 2개(빨강), 대머리, 호피무늬, 가위(빨강)

**등장 위치:**
| 화면 | 조건 | pose |
|------|------|------|
| loading | 항상 | snipping |
| result (D) | 확률 60%+ | threatening |
| result (A) | 확률 30%- | fleeing |

### 캐릭터 상호작용
- 도깨비 ↔ 수호신: A등급 시 수호신이 도깨비 쫓아냄
- 도깨비 ↔ 요정: 도깨비가 위험 요정 위협
- 관상가 ↔ 도깨비: 관상가가 부적으로 봉인

---

## 인터랙티브 효과 (page-design v2)

### 효과 1: 결과 극적 리빌 (ResultReveal)

**인터페이스:**
```tsx
interface ResultRevealProps {
  grade: 'A' | 'B' | 'C' | 'D';
  onRevealComplete: () => void;
  children: React.ReactNode;
}
```

**GSAP Timeline 시퀀스 (3초):**
```
T+0.0s: 검정 오버레이 fade-in
T+0.3s: 두루마리 SVG 펼침 (scaleY: 0→1, ease: back.out)
T+0.5s: 제목 스탬프 (scale: 3→1, rotation -15→0)
T+1.0s: 등급 뱃지 bounce-in (elastic.out)
T+1.2s: 캐릭터 리액션 등장 (x: -100→0)
T+1.5s: 오버레이 fade-out + 카드 stagger 공개
```

**등급별 파티클:**
| 등급 | 파티클 | 색상 | 수량 |
|------|--------|------|------|
| A | 별+폭죽 | 금색(#FFD700) | 30 |
| B | 작은 별 | 은색(#C0C0C0) | 15 |
| C | 나뭇잎 | 노랑(#ffe847) | 10 |
| D | 머리카락 | 검정(#1a1a1a) | 20 |

**카드 stagger 순서:**
1. 등급 뱃지 (0ms)
2. 모발 나이 (200ms)
3. 5년 확률 (400ms)
4. 탈모 유형 (600ms)
5. 닮은 유명인 (800ms)
6. 관리 팁 (1000ms)
7. 종합 코멘트 (1200ms)

### 효과 2: 스크롤 패럴랙스 (ScrollParallax)

**레이어:**
```
Layer 0: 노랑 배경 (고정)
Layer 1: 구름/산 실루엣 (0.2x)
Layer 2: 캐릭터들 (0.5x)
Layer 3: 메인 콘텐츠 (1x)
Layer 4: 장식 요소 (1.3x)
```

**스크롤 트리거:**
| 트리거 | 캐릭터 | 효과 |
|--------|--------|------|
| `.upload-section` | 관상가 | 좌측 슬라이드 인 |
| `.drag-drop-zone` | 도깨비 | 우측 peek |
| `.reassurance-text` | 수호신 | 하단 슬라이드 업 |
| `footer` | 요정 삼총사 | 손 흔들며 퇴장 |

**접근성:** `prefers-reduced-motion: reduce` → 패럴랙스/리빌 비활성화, 즉시 표시

### 기술 스택
| 패키지 | 용도 |
|--------|------|
| gsap ^3.14 | 애니메이션 엔진 |
| @gsap/react ^2.1 | useGSAP hook |
