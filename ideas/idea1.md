# 탈모 분석 & 미래 헤어라인 시뮬레이션 웹앱 프롬프트

## 프로젝트 개요

Next.js(App Router) + TypeScript + Tailwind CSS + **shadcn/ui**로 "탈모 운세" 웹앱을 만들어줘.
사진을 업로드하면 AI가 두피 상태를 분석하고, 재미있는 결과 카드 + 10년 뒤 예상 헤어라인 시뮬레이션 이미지를 보여주는 바이럴 웹앱이야.
의료 진단이 아닌 100% 재미 목적. Vercel에 배포할 거야.

---

## 기술 스택

- **프레임워크**: Next.js 14+ (App Router)
- **언어**: TypeScript
- **스타일**: Tailwind CSS
- **UI 컴포넌트**: shadcn/ui (Button, Card, Progress, Badge, Dialog, Skeleton 등 적극 활용)
- **AI**: Google Gemini API (무료 티어)
- **배포**: Vercel
- **기타**: 외부 라이브러리 최소화

---

## 디자인 레퍼런스 & 방향

### 레퍼런스
https://www.al-murphy.com/?ref=godly

### Al Murphy 사이트 디자인 특징 (실제 사이트 분석 기반)
- **배경**: 깨끗한 흰색/크림 배경, 콘텐츠가 돋보이는 넉넉한 여백
- **타이틀**: 모든 섹션 타이틀이 손글씨(handwritten) SVG 이미지로 처리됨 — 폰트가 아니라 실제 손글씨를 스캔한 느낌
- **카피라이팅**: 극단적인 셀프 디프리케이팅 유머 ("recently voted the Best Illustrator In The World at the first annual Al Murphy Illustration Awards")
- **장식 요소**: 옷걸이 SVG, 애니메이션 오리 SVG, 링 모양 floating contact 버튼 등 — 페이지 곳곳에 장난스러운 일러스트 장식
- **카드/썸네일**: 컬러풀한 일러스트 이미지가 심플한 카드 그리드로 배치
- **인터랙션**: floating contact 버튼 (원형, 회전하는 텍스트), 호버 시 부드러운 전환
- **전체 톤**: "진지한 척 하면서 전혀 진지하지 않은" — 프로페셔널한 구조에 장난스러운 콘텐츠

### Al Murphy 스타일에서 가져올 핵심 요소
1. **손글씨(Handwritten) 느낌의 타이포그래피**: 타이틀과 주요 헤딩에 손글씨/스케치 느낌의 폰트 사용 (Google Fonts: "Gaegu", "Hi Melody", "Nanum Pen Script" 등 한국어 손글씨 폰트)
2. **일러스트/낙서 감성**: 배경이나 장식 요소에 손그림 느낌의 SVG 데코레이션 (물결선, 화살표, 별, 밑줄 등을 CSS/SVG로 구현)
3. **장난스럽고 유쾌한 톤**: 과장된 유머, 셀프 디스 느낌의 카피라이팅
4. **텍스처와 질감**: 종이 질감 배경, 노이즈 오버레이, 약간 거친 느낌의 테두리
5. **컬러풀하지만 조화로운 팔레트**: 크림/베이지 베이스 + 채도 높은 포인트 컬러들
6. **의도적으로 완벽하지 않은 레이아웃**: 살짝 기울어진 요소, 불규칙한 간격, 손으로 그린 듯한 테두리

### 구체적 디자인 시스템

**컬러 팔레트:**
- 배경: 크림/따뜻한 베이지 (#FFF8F0 ~ #F5E6D3) — 종이 느낌
- 텍스트: 진한 차콜 (#2D2D2D) — 잉크 느낌
- 포인트 1: 따뜻한 코랄/레드 (#E85D4A) — 강조, CTA
- 포인트 2: 딥 블루 (#2B4C7E) — 링크, 정보
- 포인트 3: 머스타드 옐로우 (#F2A541) — 배지, 하이라이트
- 포인트 4: 포레스트 그린 (#4A7C59) — 긍정 결과
- 노이즈/그레인 오버레이: 전체 페이지에 미세한 노이즈 텍스처

**타이포그래피:**
- 타이틀/헤딩: 한국어 손글씨 폰트 (Nanum Pen Script 또는 Gaegu)
- 본문: 깔끔한 한국어 폰트 (Pretendard 또는 Noto Sans KR)
- 숫자/강조: 굵은 모노스페이스 또는 디스플레이 폰트

**장식 요소 (CSS/SVG로 구현):**
- 텍스트 아래 손그림 느낌의 물결 밑줄
- 카드 주변 불규칙한 점선 테두리
- 화살표, 별, 느낌표 등의 낙서 데코
- 살짝 회전된(rotate) 요소들 (1~3도)

**shadcn/ui 커스터마이징:**
- Card: 종이 텍스처 배경 + 연필 느낌 테두리 (border를 dashed 또는 hand-drawn 스타일로)
- Button: 둥글고 약간 기울어진 느낌, hover 시 살짝 흔들리는 애니메이션
- Progress: 손으로 색칠한 듯한 프로그레스 바
- Badge: 도장 찍힌 느낌 또는 스티커 느낌
- Skeleton: 연필 스케치 느낌의 로딩 플레이스홀더

---

## 프로젝트 구조

```
app/
├── layout.tsx          # 기본 레이아웃 (폰트, 메타데이터, 노이즈 오버레이)
├── page.tsx            # 메인 페이지 (업로드 → 분석 중 → 결과 3단계를 상태로 관리)
├── api/
│   ├── analyze/
│   │   └── route.ts    # Gemini 2.5 Flash Vision - 두피 분석
│   └── generate-image/
│       └── route.ts    # Gemini 2.0 Flash Exp - 미래 헤어라인 이미지 생성
├── components/
│   ├── UploadSection.tsx    # 사진 업로드 UI
│   ├── LoadingSection.tsx   # 분석 중 로딩 화면
│   └── ResultSection.tsx    # 결과 카드 + 시뮬레이션 이미지
├── components/ui/           # shadcn/ui 컴포넌트들
└── globals.css              # 노이즈 텍스처, 손글씨 밑줄 등 커스텀 CSS
.env.local                   # GEMINI_API_KEY=your_key_here
```

---

## 화면 플로우 (3단계, 단일 페이지에서 상태로 전환)

### 1단계: 메인 업로드 화면 (UploadSection)

- 앱 타이틀: "탈모 운세 🔮" (손글씨 폰트, 살짝 기울어짐)
- 서브카피: "AI가 예측하는 당신의 모발 운명" (연필로 쓴 느낌)
- 재미있는 일러스트/데코 요소가 타이틀 주변에 배치 (별, 모발 아이콘 등 SVG)
- 사진 업로드 영역:
  - shadcn/ui Card 기반, 점선 테두리로 손그림 느낌
  - 드래그앤드롭 지원
  - 클릭하여 파일 선택
  - 모바일 카메라 촬영 지원 (accept="image/*")
  - 업로드 후 미리보기 표시 (살짝 기울어진 폴라로이드 느낌)
- 하단 안심 문구: "📷 사진은 분석 후 즉시 삭제되며 어디에도 저장되지 않습니다"
- 면책 고지: "본 서비스는 재미 목적이며 의료 진단이 아닙니다"
- "분석 시작" 버튼: shadcn/ui Button, 코랄 색상, hover 시 살짝 흔들리는 애니메이션

### 2단계: 분석 중 화면 (LoadingSection)

- 중앙에 재미있는 CSS 애니메이션 (머리카락이 하나씩 떨어지는 느낌, 또는 돋보기가 왔다갔다)
- 단계별 메시지가 2초 간격으로 변경 (손글씨 폰트):
  1. "두피를 스캔하는 중... 🔍"
  2. "모낭을 하나하나 세는 중... 🧬"
  3. "당신의 미래를 예측하는 중... 🔮"
  4. "10년 뒤 모습을 그리는 중... 🎨"
- shadcn/ui Progress 바 (손으로 색칠하는 느낌의 애니메이션)

### 3단계: 결과 화면 (ResultSection)

**분석 결과 카드 (shadcn/ui Card 기반, 종이 텍스처 배경)**

- 모발 등급: 크게 표시, 도장 찍힌 느낌의 Badge
  - 🌳 숲 (건강) — 초록 도장
  - 🌿 풀밭 (양호) — 연두 도장
  - 🏜️ 사막 (주의) — 주황 도장
  - 🪨 바위 (위험) — 빨강 도장
- 모발 나이: "실제 나이 32세 → 모발 나이 47세!" (숫자 카운트업 애니메이션, 큰 손글씨)
- 5년 내 탈모 확률: N% + shadcn/ui Progress (애니메이션 fill, 색상 그라데이션)
- 탈모 유형: M자 / O자 / 정수리 / 원형 / 해당없음 (Badge로 표시)
- 닮은 대머리 유명인: "미래의 당신은... 브루스 윌리스 🎬" + 한줄 코멘트 (말풍선 느낌)
- 관리 팁: 3개 짧은 조언 (체크리스트 느낌, 손글씨 체크마크)
- 종합 코멘트: AI의 유머러스한 한 마디 (큰 따옴표로 감싸기)

**시뮬레이션 이미지 (별도 Card)**
- "🔮 10년 뒤 예상 모습" 타이틀 (손글씨)
- AI 생성 이미지 표시 영역 (폴라로이드/스케치북 프레임)
- 이미지 생성 중이면 shadcn/ui Skeleton (연필 스케치 느낌)
- 이미지 생성 실패 시: "이미지 생성에 실패했지만 당신의 미래는 밝습니다 ✨"

**액션 버튼**
- "다시 테스트하기" 버튼 (shadcn/ui Button variant="outline")
- "결과 공유하기" 버튼 (shadcn/ui Button, Web Share API 또는 클립보드 복사)

---

## API Routes 상세

### POST /api/analyze

**요청**: JSON body
```json
{
  "image": "base64_encoded_image_string",
  "mimeType": "image/jpeg"
}
```

**Gemini API 호출**:
- 모델: `gemini-2.5-flash`
- 엔드포인트: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`
- 요청 body:
```json
{
  "contents": [{
    "parts": [
      {
        "inlineData": {
          "mimeType": "image/jpeg",
          "data": "{base64_image}"
        }
      },
      {
        "text": "시스템 프롬프트 (아래 참조)"
      }
    ]
  }],
  "generationConfig": {
    "temperature": 1.0,
    "responseMimeType": "application/json"
  }
}
```

**분석 프롬프트 (text 파트에 포함)**:
```
너는 재미있는 탈모 운세 분석가야. 업로드된 사진을 보고 유머러스하게 모발 상태를 분석해줘.
이건 의료 진단이 아니라 100% 재미/엔터테인먼트 목적이야. 과장되고 웃기게 분석해줘.

사진이 두피/머리카락이 아니더라도, 사진 속 어떤 요소든 창의적으로 연결해서 재미있게 분석해줘.
예를 들어 고양이 사진이면 "고양이의 털 상태로 보아..." 식으로.

반드시 아래 JSON 형식으로만 응답해. 다른 텍스트는 절대 포함하지 마.

{
  "grade": "숲" | "풀밭" | "사막" | "바위" 중 하나,
  "gradeEmoji": "🌳" | "🌿" | "🏜️" | "🪨" 중 grade에 맞는 것,
  "hairAge": 모발 추정 나이 (숫자, 20~80 사이),
  "baldProbability5yr": 5년 내 탈모 확률 (숫자, 0~100),
  "baldType": "M자" | "O자" | "정수리" | "원형" | "해당없음" 중 하나,
  "celebrity": {
    "name": "닮은 대머리 유명인 이름 (한국/해외 유명인)",
    "comment": "유머러스한 한줄 코멘트"
  },
  "tips": ["관리팁1", "관리팁2", "관리팁3"],
  "comment": "종합 코멘트 - 웃기고 위트 있는 한 마디 (2~3문장)",
  "imagePrompt": "10년 뒤 이 사람의 예상 헤어라인을 시뮬레이션한 일러스트를 생성하기 위한 영어 프롬프트. 분석 결과를 반영하여 구체적으로 작성. 예: 'Illustration of a Korean man in his 40s with a receding M-shaped hairline, realistic style, front view portrait'. 반드시 영어로 작성."
}
```

**응답**: Gemini 응답에서 JSON 파싱 후 클라이언트에 반환

### POST /api/generate-image

**요청**:
```json
{
  "prompt": "분석 결과에서 받은 imagePrompt 문자열"
}
```

**Gemini API 호출**:
- 모델: `gemini-2.0-flash-exp`
- 엔드포인트: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${GEMINI_API_KEY}`
- 요청 body:
```json
{
  "contents": [{
    "parts": [{
      "text": "{prompt}\n\nGenerate an illustration image based on the description above. Style: Semi-realistic digital illustration, warm lighting, front-facing portrait view."
    }]
  }],
  "generationConfig": {
    "responseModalities": ["TEXT", "IMAGE"]
  }
}
```

**응답 처리**:
- Gemini 응답의 parts 배열에서 `inlineData` (이미지)를 찾아 base64 추출
- 클라이언트에 `{ image: "data:image/png;base64,..." }` 형태로 반환
- 이미지가 없으면 `{ image: null, error: "이미지 생성 실패" }` 반환

---

## 환경변수

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

Google AI Studio(https://aistudio.google.com/apikey)에서 무료 발급.

---

## 에러 처리

- API 키 미설정: "서버 설정을 확인해주세요" 메시지
- Gemini API 실패: "AI가 잠시 낮잠 중이에요... 다시 시도해주세요 😴" 메시지
- 이미지 생성 실패: 분석 카드는 정상 표시, 이미지 영역에 재미있는 폴백 메시지
- 사진이 아닌 파일 업로드: "이미지 파일만 올려주세요! 📸" 메시지
- Rate Limit 초과: "오늘 너무 인기가 많아요! 잠시 후 다시 오세요 🔥" 메시지
- 모든 에러는 shadcn/ui의 적절한 컴포넌트(Alert, Toast 등)로 표시

---

## 주의사항

- API 키는 절대 클라이언트에 노출하지 말 것 (API Route에서만 사용)
- 업로드된 이미지는 메모리에서만 처리하고 서버에 저장하지 말 것
- 모든 UI 텍스트는 한국어
- SEO 메타데이터 포함 (og:title, og:description, og:image 등)
- Vercel 배포 기준 최적화
- shadcn/ui 컴포넌트는 Al Murphy 스타일에 맞게 커스터마이징할 것 (globals.css에서 CSS 변수 오버라이드)