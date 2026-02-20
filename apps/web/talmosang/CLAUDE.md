# 탈모상 — AI 두피 분석 엔터테인먼트 웹앱

## 제품 개요

- **목적**: 사진 업로드로 AI가 두피 상태를 재미있게 분석해주는 바이럴 엔터테인먼트 서비스
- **대상 사용자**: 일반 사용자 (바이럴/재미 목적)
- **핵심 기능**:
  - 사진 업로드 및 클라이언트 리사이즈
  - Gemini 2.5 Flash Vision API 기반 두피 분석 (사극 말투)
  - 등급 판정 (숲/풀밭/사막/바위), 모발 나이, 5년 내 탈모 확률
  - 닮은 대머리 유명인, 관리 팁, 종합 판결
  - 시뮬레이션 이미지 생성 (현재 비활성 — 무료 티어 제한)
  - Google AdSense 광고

## Commands

```bash
pnpm dev              # 개발 서버 (http://localhost:3000)
pnpm build            # 프로덕션 빌드
pnpm test:e2e         # Playwright E2E 테스트
pnpm test:e2e:ui      # Playwright UI 모드
```

## Environment Variables

| 변수 | 설명 | 필수 |
|------|------|------|
| `GEMINI_API_KEY` | Google Gemini API 키 (서버 전용) | Yes |
| `NEXT_PUBLIC_ADSENSE_ID` | Google AdSense 클라이언트 ID | No |

## Project Structure

```
app/
├── layout.tsx              # RootLayout — 메타데이터, JSON-LD, AdSense, 폰트
├── page.tsx                # 메인 페이지 — 3단계 상태 전환 (upload/loading/result)
├── error.tsx               # 에러 바운더리
├── privacy/page.tsx        # 개인정보처리방침
├── robots.ts, sitemap.ts   # SEO
└── api/
    ├── analyze/route.ts    # POST /api/analyze — Gemini Vision 두피 분석
    └── generate-image/route.ts  # POST /api/generate-image — 시뮬레이션 이미지 (비활성)
components/
├── UploadSection.tsx       # 사진 업로드 UI
├── LoadingSection.tsx      # 분석 중 로딩 (dynamic import)
├── ResultSection.tsx       # 분석 결과 표시 (dynamic import)
├── CharacterBanner.tsx     # 캐릭터 배너
├── AdBanner.tsx            # Google AdSense 배너
├── DisclaimerText.tsx      # 면책 문구
├── effects/                # 애니메이션 효과 (Particles, ResultReveal, ScrollParallax)
└── ui/                     # 공통 UI (badge, button, card, progress, skeleton)
lib/
├── errors.ts               # 에러 메시지 상수 (사극 말투)
├── fonts.ts                # Google Fonts 설정 (Black Han Sans, Jua, Noto Sans KR)
├── image-utils.ts          # 이미지 리사이즈, Base64 변환
└── utils.ts                # 유틸리티
types/
└── analysis.ts             # AnalysisResult, AnalyzeRequest 타입 정의
```

## Architecture

- **프레임워크**: Next.js 15 App Router
- **스타일링**: Tailwind CSS v4 + CSS 변수
- **상태 관리**: React useState (단일 페이지 앱)
- **API**: Route Handler (서버 컴포넌트에서 Gemini API 호출)
- **최적화**: dynamic import로 LoadingSection/ResultSection 코드 분할
- **SEO**: 메타데이터, JSON-LD 구조화 데이터, sitemap, robots
- **CSP**: Content-Security-Policy 헤더 설정 (next.config.ts)
- **애니메이션**: GSAP (gsap, @gsap/react)

## 새 화면/기능 추가 시

1. `app/` 디렉토리에 라우트 폴더 생성 (App Router 컨벤션)
2. 재사용 컴포넌트는 `components/`에 추가
3. 타입은 `types/`에 정의
4. 에러 메시지는 `lib/errors.ts`에 사극 말투로 추가

## Deployment

- **호스팅**: Vercel (Hobby plan)
- **URL**: `https://gaegulzip-talmosang.vercel.app`
- 12개 serverless function 제한 (Hobby plan)

## Important Notes

- 테스트는 **Playwright E2E만** 사용 (유닛/컴포넌트 테스트 금지)
- 의료 진단이 아닌 **100% 엔터테인먼트** 목적 (면책 문구 포함)
- 시뮬레이션 이미지 생성은 현재 비활성 (무료 티어 미지원)
- 이미지 파일 크기 제한: 10MB, 허용 형식: JPEG, PNG, WebP
