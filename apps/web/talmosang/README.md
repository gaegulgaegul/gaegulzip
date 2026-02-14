# 탈모상 (Hair Loss Fortune Telling)

AI 관상가가 그대의 모발 운명을 점지하는 바이럴 웹앱입니다.

## 기술 스택

- **Framework**: Next.js 15 (App Router)
- **UI Library**: shadcn/ui + Tailwind CSS 4
- **Language**: TypeScript
- **AI**: Google Gemini 2.5 Flash Vision, Gemini 2.0 Flash Exp
- **Fonts**: Nanum Pen Script (손글씨), Pretendard (본문)

## 프로젝트 구조

```
apps/web/talmosang/
├── app/
│   ├── layout.tsx              # Root layout
│   ├── page.tsx                # 메인 페이지
│   ├── globals.css             # Tailwind + 커스텀 CSS
│   └── api/
│       ├── analyze/
│       │   └── route.ts        # 두피 분석 API
│       └── generate-image/
│           └── route.ts        # 이미지 생성 API
├── components/
│   └── ui/                     # shadcn/ui 컴포넌트
├── types/
│   └── analysis.ts             # 타입 정의
├── lib/
│   ├── fonts.ts                # 폰트 설정
│   ├── errors.ts               # 에러 메시지 상수
│   └── utils.ts                # 유틸리티 함수
└── public/
    └── fonts/                  # 로컬 폰트 파일
```

## 환경변수 설정

`.env.local` 파일을 생성하고 다음 환경변수를 설정하세요:

```env
# Google Gemini API 키 (필수)
GEMINI_API_KEY=your_gemini_api_key_here

# Google AdSense Publisher ID (선택)
NEXT_PUBLIC_ADSENSE_ID=ca-pub-XXXXXXXXXXXXXXXX
```

## 개발 시작

```bash
# 의존성 설치
pnpm install

# 개발 서버 실행
pnpm dev

# 빌드
pnpm build

# 프로덕션 서버 실행
pnpm start
```

개발 서버는 [http://localhost:3000](http://localhost:3000)에서 실행됩니다.

## API Routes

### POST /api/analyze

두피 이미지를 Gemini 2.5 Flash Vision API로 분석합니다.

**Request:**
```json
{
  "image": "base64_encoded_image",
  "mimeType": "image/jpeg"
}
```

**Response:**
```json
{
  "grade": "숲",
  "gradeEmoji": "🌳",
  "gradeVerdict": "관상 판결문",
  "hairAge": 28,
  "baldProbability5yr": 35,
  "baldType": "M자",
  "celebrity": {
    "name": "닮은 대머리 유명인",
    "comment": "사극풍 코멘트"
  },
  "tips": ["팁1", "팁2", "팁3"],
  "comment": "종합 판결",
  "imagePrompt": "이미지 생성 프롬프트"
}
```

### POST /api/generate-image

Gemini 2.0 Flash Exp API로 10년 뒤 헤어라인 시뮬레이션 이미지를 생성합니다.

**Request:**
```json
{
  "prompt": "10년 뒤 헤어라인 이미지 생성 프롬프트"
}
```

**Response:**
```json
{
  "image": "data:image/png;base64,...",
  "error": null
}
```

## 작업 계획

- [x] **Group 1: 프로젝트 초기 설정 및 기반 코드**
  - [x] Next.js 프로젝트 생성
  - [x] shadcn/ui 초기화 및 컴포넌트 설치
  - [x] 타입 정의 (types/analysis.ts)
  - [x] API Routes 구현 (analyze, generate-image)
  - [x] 폰트, 유틸리티, CSS 설정
  - [x] pnpm workspace 추가

- [x] **Group 2: 컴포넌트 및 페이지 구현**
  - [x] layout-structure (Root layout, AdSense, 개인정보처리방침)
  - [x] upload-section (파일 업로드, 드래그앤드롭)
  - [x] loading-section (로딩 애니메이션)
  - [x] result-section (결과 표시, 공유 기능)
  - [x] main-page (상태 관리, 컴포넌트 통합)

## 디자인 컨셉

- **영감**: Al Murphy 웹사이트 - 손글씨 폰트, 크림 배경, 낙서 감성
- **컬러 팔레트**: 크림(#FFF8F0), 차콜(#2D2D2D), 코랄(#E85D4A), 딥블루(#2B4C7E)
- **폰트**: Nanum Pen Script (손글씨), Pretendard (본문)
- **애니메이션**: 흔들림, 살랑살랑, 머리카락 떨어지는 효과

## 참고 문서

- [web-work-plan.md](../../../docs/talmosang/talmosang/web-work-plan.md) - 작업 분배 계획
- [web-brief.md](../../../docs/talmosang/talmosang/web-brief.md) - 기술 아키텍처
- [web-design-spec.md](../../../docs/talmosang/talmosang/web-design-spec.md) - UI/UX 디자인 명세

## 라이선스

Private
