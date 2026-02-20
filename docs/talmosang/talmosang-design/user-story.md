# 탈모상 디자인 개선 계획 (talmosang-design)

## 현재 상황 분석

### Playwright 스크린샷 비교 결과

**참조 사이트 (Al Murphy - https://www.al-murphy.com):**
![Al Murphy Desktop](/tmp/al-murphy-desktop.png)
- 밝은 노란색 배경 (#FFE135 계열)
- 굵고 대담한 손그림 타이포그래피 (SVG 핸드레터링)
- 다채로운 카툰/일러스트 캐릭터 곳곳에 배치
- 섹션별로 다른 배경색 (노란색, 핫핑크, 텍스처)
- 스티커/배지 스타일 요소 ("BUY PRINTS", "BUY STICKERS")
- 풀 와이드 레이아웃, 여러 섹션으로 구분
- 의도적으로 유치하고 대담한(maximalist) 에너지
- 낙서 테두리, 캐릭터 일러스트 장식

**현재 탈모상:**
![Talmosang Desktop](/tmp/talmosang-desktop.png)
- CSS가 전혀 렌더링되지 않음 (흰색 배경, 기본 폰트)
- 네이티브 HTML 파일 인풋 노출 (Choose File 버튼)
- 카드, 테두리, 텍스처, 색상 전무
- 드래그앤드롭 영역 스타일 없음
- 사실상 raw HTML 상태

---

## 문제 1: CSS 빌드 완전 실패 (Critical)

### 근본 원인
- `tailwindcss: ^4.0.0` 설치됨 (Tailwind CSS v4)
- `globals.css`에서 `@import "tailwindcss"` 사용 (v4 문법)
- **`@tailwindcss/postcss` 플러그인 미설치**
- **`postcss.config.mjs` 파일 없음**
- Next.js는 PostCSS를 통해 CSS 처리 → PostCSS 설정 없이 Tailwind 동작 불가
- 결과: 컴파일된 CSS = **9바이트** (빈 파일)

### 해결 방안
1. `@tailwindcss/postcss` 설치
2. `postcss.config.mjs` 생성
3. `tailwind.config.ts` (v3 형식) → CSS `@theme` 지시어 (v4 형식)으로 마이그레이션
4. 모든 기존 스타일 렌더링 확인

---

## 문제 2: 디자인 컨셉 근본적 차이

### Al Murphy 핵심 디자인 언어
| 요소 | Al Murphy | 현재 탈모상 (설계) |
|------|-----------|-----------------|
| **배경색** | 밝은 노란색, 핫핑크, 다양한 강렬한 색 | 크림 (#FFF8F0) - 은은함 |
| **타이포** | 굵고 거대한 핸드레터링 SVG | 나눔펜스크립트 (가는 손글씨) |
| **일러스트** | 대담한 카툰 캐릭터 가득 | 작은 CSS 장식 (별, 화살표) |
| **레이아웃** | 풀 와이드, 섹션별 배경 | 좁은 단일 컬럼 (max-w-lg) |
| **에너지** | 대담, 혼란스럽고 재미있는 | 은은하고 따뜻한 |
| **장식** | 대형 스티커, 낙서, 캐릭터 | 미세한 노이즈 텍스처 |
| **색상 채도** | 높은 채도, 원색 | 낮은 채도, 파스텔 |

---

## 구현 계획

### Group 1: CSS 빌드 수정 (필수 선행)

#### Task 1-1: Tailwind CSS v4 + PostCSS 설정 수정
```
1. pnpm add -D @tailwindcss/postcss
2. postcss.config.mjs 생성:
   export default { plugins: { "@tailwindcss/postcss": {} } }
3. tailwind.config.ts 내용을 globals.css의 @theme로 마이그레이션
4. 기존 커스텀 색상, 폰트, 애니메이션을 @theme 블록으로 이동
5. dev 서버 재시작 후 기존 스타일 렌더링 확인
```

#### Task 1-2: Playwright 스크린샷으로 CSS 수정 검증
```
기존 스타일(크림 배경, 카드 테두리, 드래그앤드롭 등)이 올바르게 렌더링되는지 확인
```

### Group 2: Al Murphy 디자인 언어 적용

#### Task 2-1: 색상 팔레트 대폭 변경
```
Before:
  --color-cream: #FFF8F0 (은은한 크림)
  --color-coral: #E85D4A (산호색)

After (Al Murphy 영감):
  --color-bg-primary: #FFE847 (밝은 노란색 - 메인 배경)
  --color-bg-section-2: #FF69B4 (핫핑크 - 섹션 구분)
  --color-bg-section-3: #87CEEB (하늘색 - 변형)
  --color-text: #1a1a1a (진한 검정)
  --color-accent: #FF4444 (밝은 빨강)
  --color-accent-2: #00CC66 (밝은 초록)

핵심: 채도 높은 원색 사용, 섹션별 다른 배경색
```

#### Task 2-2: 타이포그래피 강화 - 굵고 대담한 손글씨
```
Before: Nanum Pen Script 400 (가는 손글씨)
After:
  - 메인 타이틀: 커스텀 SVG 핸드레터링 또는 Black Han Sans/Jua 폰트
  - 크기 대폭 확대: text-4xl → text-7xl~8xl
  - 섹션 제목도 거대한 손글씨 SVG
  - 핵심: "가녀린 손글씨" → "굵고 거대한 마커 글씨"
```

#### Task 2-3: 일러스트/캐릭터 장식 요소 추가
```
Before: 작은 CSS 별/화살표 (32px)
After:
  - 대형 SVG 캐릭터 일러스트 추가 (대머리 캐릭터, 머리카락 캐릭터 등)
  - 낙서 스타일 데코레이션 대폭 추가
  - 스티커/배지 스타일 요소 (탈모상 스탬프, 등급 스티커)
  - 페이지 곳곳에 재미있는 doodle 흩뿌리기
  - 핵심: "미니멀 장식" → "맥시멀 일러스트"
```

#### Task 2-4: 레이아웃 전면 개편
```
Before: max-w-lg mx-auto (512px 단일 좁은 컬럼)
After:
  - 풀 와이드 섹션 (각 섹션이 화면 전체 폭 차지)
  - 섹션별 다른 배경색
  - 콘텐츠 영역은 max-w-2xl~3xl로 확대
  - 섹션 간 시각적 구분 (색상 변화, wave/zigzag divider)
  - 핵심: "좁은 카드" → "넓고 대담한 풀 와이드"
```

#### Task 2-5: 업로드 섹션 재디자인
```
Before: dashed border 카드, 작은 카메라 아이콘
After:
  - 대형 일러스트와 함께 배치
  - 업로드 영역에 캐릭터 일러스트 (예: 관상가 캐릭터)
  - 큰 텍스트, 대담한 CTA 버튼
  - Al Murphy 스타일의 스티커/배지 느낌
```

#### Task 2-6: 결과 섹션 재디자인
```
Before: paper-texture 카드, 작은 배지
After:
  - 각 결과 항목을 독립된 풀와이드 섹션으로
  - 대형 등급 스탬프 (캐릭터 일러스트 포함)
  - 확률 바를 대형 일러스트로 시각화
  - 유명인 비교를 말풍선 캐릭터로 표현
  - 공유 버튼을 스티커 스타일로
```

### Group 3: 검증

#### Task 3-1: Playwright 스크린샷 비교 검증
```
변경 후 다시 스크린샷 캡처하여 Al Murphy와 비교
- 데스크톱/모바일 모두 확인
- 색상 채도, 일러스트 비중, 레이아웃 폭 비교
```

#### Task 3-2: E2E 테스트 확인
```
기존 Playwright E2E 테스트가 통과하는지 확인
기능(업로드, 분석, 결과) 동작 검증
```

---

## 우선순위

1. **[P0] CSS 빌드 수정** - 이거 없이는 아무것도 보이지 않음
2. **[P1] 색상 + 레이아웃** - 가장 큰 시각적 차이
3. **[P2] 타이포그래피** - 존재감 있는 글씨
4. **[P3] 일러스트/장식** - Al Murphy 감성의 핵심
5. **[P4] 섹션별 재디자인** - 세부 완성도

---

## 참고: SVG 일러스트 접근법

Al Murphy 사이트의 핵심은 **직접 그린 일러스트**입니다. 탈모상에서는:
- CSS/SVG로 제작 가능한 간단한 캐릭터 일러스트 사용
- 또는 AI 생성 SVG 일러스트 활용
- 핵심 캐릭터: 관상가 할아버지, 대머리 캐릭터, 머리카락 캐릭터
- 스티커/배지: "탈모 위험!", "안전!", 등급별 스티커
