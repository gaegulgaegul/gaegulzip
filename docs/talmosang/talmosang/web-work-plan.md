# 작업 분배 계획: 탈모상 웹 (Web Work Plan)

## 개요

탈모상은 **독립적인 Next.js 16 App Router 프로젝트**로, `apps/web/talmosang/` 디렉토리에 새로 생성됩니다. 어드민 프로젝트(`apps/web/admin/`)와는 별개의 독립 프로젝트이며, 각자의 `package.json`을 가집니다.

**핵심 원칙**:
- Group 1은 프로젝트 초기 설정 및 기반 코드로, 1명의 React Developer가 선행 작업
- Group 2는 기능 모듈 구현으로, 의존성이 없는 컴포넌트는 병렬 작업 가능
- 모든 코드는 TypeScript + Tailwind CSS v4 + shadcn/ui 기반

---

## 실행 그룹

### Group 1 (선행 작업) — 프로젝트 초기 설정 및 기반 코드

| Agent | 모듈 | 설명 |
|-------|------|------|
| react-developer | project-setup | 프로젝트 생성, shadcn/ui 설치, 타입 정의 |
| react-developer | api-routes | Gemini API 통합 (분석, 이미지 생성) |

**작업 내용**:
1. **project-setup**:
   - Next.js 16 프로젝트 생성 (`apps/web/talmosang/`)
   - shadcn/ui 초기화 (new-york 스타일)
   - 타입 정의 (`types/analysis.ts`)
   - 폰트 설정 (`lib/fonts.ts`)
   - 커스텀 CSS (`app/globals.css`)
   - 환경변수 템플릿 (`.env.local.example`)

2. **api-routes**:
   - `app/api/analyze/route.ts` — Gemini 2.5 Flash Vision API (두피 분석)
   - `app/api/generate-image/route.ts` — Gemini 2.0 Flash Exp API (이미지 생성)
   - 에러 처리 유틸리티 (`lib/errors.ts`)

**산출물**:
- `apps/web/talmosang/` 프로젝트 구조 완성
- `types/analysis.ts` — AnalysisResult, AnalyzeRequest, GenerateImageRequest 타입
- `app/api/analyze/route.ts`, `app/api/generate-image/route.ts`
- `lib/fonts.ts`, `lib/errors.ts`
- `app/globals.css` — Tailwind v4 + 커스텀 애니메이션

**검증**:
- `pnpm dev` 정상 실행 확인
- API Routes 로컬 테스트 (Postman 또는 curl)

---

### Group 2 (병렬 작업) — 컴포넌트 및 페이지 구현

| Agent | 모듈 | 설명 | Group 1 의존성 |
|-------|------|------|----------------|
| react-developer | layout-structure | Root layout, 메타데이터, AdSense 스크립트 | types/analysis.ts |
| react-developer | upload-section | 파일 업로드 컴포넌트 (드래그앤드롭, 미리보기) | types/analysis.ts |
| react-developer | loading-section | 로딩 컴포넌트 (애니메이션, 메시지 전환) | 없음 (UI만) |
| react-developer | result-section | 결과 표시 컴포넌트 (공유 기능, 결과 카드) | types/analysis.ts |
| react-developer | main-page | 메인 페이지 (상태 관리, 컴포넌트 통합) | 전체 컴포넌트 |

**작업 내용**:

#### 1. layout-structure
- `app/layout.tsx` — Root layout (폰트, 메타데이터, AdSense 스크립트)
- `components/DisclaimerText.tsx` — 면책 고지 (Server Component)
- `components/AdBanner.tsx` — Google AdSense 광고 (Client Component)
- `app/privacy/page.tsx` — 개인정보처리방침 (정적 페이지)

**산출물**:
- `app/layout.tsx`
- `components/DisclaimerText.tsx`
- `components/AdBanner.tsx`
- `app/privacy/page.tsx`

**검증**:
- Root layout HTML 구조 확인
- 메타데이터 (title, OG 태그) 렌더링 확인
- AdSense 스크립트 로드 확인 (개발자 도구)

#### 2. upload-section
- `components/UploadSection.tsx` — 파일 업로드, 드래그앤드롭, 미리보기 (Client Component)
- 파일 검증 로직 (타입, 크기)
- 폴라로이드 프레임 미리보기
- 이미지 리사이즈 유틸리티 (클라이언트 측)

**산출물**:
- `components/UploadSection.tsx`
- `lib/image-utils.ts` — resizeImage() 함수

**검증**:
- 드래그앤드롭 동작 확인
- 파일 검증 (타입, 크기 초과 시 에러 메시지)
- 미리보기 렌더링 확인
- 모바일 브라우저 카메라 촬영 (capture="user") 동작 확인

#### 3. loading-section
- `components/LoadingSection.tsx` — 로딩 애니메이션, 메시지 전환 (Client Component)
- 머리카락 떨어지는 애니메이션 (CSS keyframes)
- 사극 말투 메시지 2초마다 전환
- 프로그레스 바 (0 → 100, 30초 동안)

**산출물**:
- `components/LoadingSection.tsx`

**검증**:
- 로딩 애니메이션 렌더링 확인
- 메시지 전환 동작 (2초마다)
- 프로그레스 바 증가 애니메이션 확인

#### 4. result-section
- `components/ResultSection.tsx` — 결과 표시, 공유 기능 (Client Component)
- 결과 카드 렌더링 (등급, 나이, 확률, 유형, 유명인, 팁)
- 10년 뒤 시뮬레이션 이미지 표시
- Web Share API 또는 폴백 (링크 복사, 이미지 다운로드)
- html2canvas 이미지 다운로드 기능

**산출물**:
- `components/ResultSection.tsx`

**검증**:
- 결과 카드 렌더링 확인
- Web Share API 동작 확인 (모바일 브라우저)
- 링크 복사, 이미지 다운로드 폴백 동작 확인 (데스크톱 브라우저)

#### 5. main-page
- `app/page.tsx` — 메인 페이지 (Client Component)
- 상태 관리 (upload, loading, result)
- 컴포넌트 통합 (UploadSection, LoadingSection, ResultSection)
- API 호출 로직 (분석, 이미지 생성)

**산출물**:
- `app/page.tsx`

**검증**:
- 전체 플로우 동작 확인 (업로드 → 로딩 → 결과)
- 에러 처리 확인 (API 오류, 네트워크 오류)
- 상태 전환 애니메이션 확인

---

## 모듈 계약 (Module Contracts)

### 타입 정의 (types/analysis.ts)

**Group 1에서 정의**, 모든 컴포넌트에서 참조:

```typescript
/**
 * 두피 분석 요청
 */
export interface AnalyzeRequest {
  image: string;      // Base64 인코딩된 이미지
  mimeType: string;   // "image/jpeg" | "image/png"
}

/**
 * 두피 분석 결과
 */
export interface AnalysisResult {
  /** 모발 등급 (A-F) */
  grade: string;

  /** 등급 이모지 (🌳, 🌿, 🏜️, 🪨) */
  gradeEmoji: string;

  /** 등급 설명 */
  gradeVerdict: string;

  /** 모발 나이 */
  hairAge: number;

  /** 5년 내 탈모 확률 (0-100) */
  baldProbability5yr: number;

  /** 탈모 유형 */
  baldType: string;

  /** 닮은 유명인 */
  celebrity: string;

  /** 관리팁 (3-5개) */
  tips: string[];

  /** 종합 코멘트 */
  comment: string;

  /** 이미지 생성 프롬프트 */
  imagePrompt: string;

  /** 10년 뒤 시뮬레이션 이미지 (옵셔널) */
  simulationImage?: string | null;
}

/**
 * 이미지 생성 요청
 */
export interface GenerateImageRequest {
  prompt: string;
}

/**
 * 이미지 생성 응답
 */
export interface GenerateImageResponse {
  image: string | null;
  error?: string;
}
```

### 컴포넌트 Props 인터페이스

**UploadSection**:
```typescript
interface UploadSectionProps {
  photo: File | null;
  error: string | null;
  onPhotoUpload: (file: File) => void;
  onAnalyze: () => void;
  onReset: () => void;
}
```

**ResultSection**:
```typescript
interface ResultSectionProps {
  result: AnalysisResult;
  onReset: () => void;
}
```

**AdBanner**:
```typescript
interface AdBannerProps {
  position: 'bottom' | 'middle' | 'center';
}
```

### API Routes 엔드포인트

**POST /api/analyze**:
- Request: `{ image: string, mimeType: string }`
- Response: `AnalysisResult`

**POST /api/generate-image**:
- Request: `{ prompt: string }`
- Response: `{ image: string | null, error?: string }`

---

## shadcn/ui 컴포넌트 설치

Group 1의 project-setup에서 설치:

```bash
npx shadcn@latest init
# 설정: new-york, neutral, CSS variables: yes

npx shadcn@latest add card button progress badge skeleton
```

**설치 컴포넌트**:
- `card` — 업로드 카드, 결과 카드
- `button` — CTA 버튼 (관상 보기, 공유하기, 다시 관상 보기)
- `progress` — 로딩 프로그레스 바, 탈모 확률 바
- `badge` — 등급 배지, 탈모 유형 배지
- `skeleton` — 이미지 로딩 플레이스홀더

---

## 생성 파일 목록

### Group 1 (project-setup + api-routes)

```
apps/web/talmosang/
├── .env.local.example          # 환경변수 템플릿
├── package.json                # 의존성 (Next.js 16, shadcn/ui, lucide-react)
├── next.config.ts              # CSP 설정
├── tsconfig.json               # TypeScript 설정
├── tailwind.config.ts          # Tailwind v4 + 커스텀 색상
├── components.json             # shadcn/ui 설정
├── app/
│   ├── globals.css             # Tailwind v4 + 커스텀 CSS
│   └── api/
│       ├── analyze/
│       │   └── route.ts        # POST /api/analyze
│       └── generate-image/
│           └── route.ts        # POST /api/generate-image
├── types/
│   └── analysis.ts             # 타입 정의
├── lib/
│   ├── fonts.ts                # Next.js 폰트 설정
│   ├── errors.ts               # 에러 메시지 상수
│   └── utils.ts                # cn() 유틸리티 (shadcn/ui)
└── components/
    └── ui/                     # shadcn/ui 컴포넌트 (자동 생성)
```

### Group 2 (컴포넌트 및 페이지)

```
apps/web/talmosang/
├── app/
│   ├── layout.tsx              # Root layout
│   ├── page.tsx                # 메인 페이지 (상태 관리)
│   └── privacy/
│       └── page.tsx            # 개인정보처리방침
├── components/
│   ├── UploadSection.tsx       # 파일 업로드 컴포넌트
│   ├── LoadingSection.tsx      # 로딩 컴포넌트
│   ├── ResultSection.tsx       # 결과 컴포넌트
│   ├── AdBanner.tsx            # AdSense 광고
│   └── DisclaimerText.tsx      # 면책 고지
├── lib/
│   └── image-utils.ts          # 이미지 리사이즈 유틸리티
└── public/
    ├── noise-texture.svg       # 노이즈 텍스처 오버레이
    ├── og-image.png            # OG 이미지
    └── decorations/            # 손그림 SVG (밑줄, 화살표, 별)
```

---

## 작업 순서 및 의존성

### 의존성 그래프

```
Group 1: project-setup → api-routes
         ↓
Group 2: layout-structure, upload-section, loading-section, result-section (병렬)
         ↓
         main-page (전체 통합)
```

### 작업 순서

1. **Group 1 완료 후** → types/analysis.ts, API Routes 완성
2. **Group 2 병렬 시작** → layout-structure, upload-section, loading-section, result-section (의존성 없음)
3. **Group 2 main-page** → 모든 컴포넌트 완성 후 통합

---

## 주요 기술 스택

- **Next.js 16** — App Router, Server/Client Components
- **React 19** — Server Components, Suspense
- **TypeScript** — 전체 코드 타입 안전성
- **Tailwind CSS v4** — CSS 변수 기반 테마, oklch 색상
- **shadcn/ui** — new-york 스타일, RSC 지원
- **Lucide React** — 아이콘 라이브러리
- **Google Gemini API** — 두피 분석 (Gemini 2.5 Flash Vision), 이미지 생성 (Gemini 2.0 Flash Exp)
- **next/font** — Nanum Pen Script (손글씨), Pretendard (본문)

---

## 테스트 전략

**Playwright E2E 테스트만 사용** (단위 테스트 금지)

### 테스트 시나리오

1. **업로드 플로우**:
   - 파일 선택 → 미리보기 표시 → "관상 보기" 버튼 활성화
   - 파일 타입 검증 (오류 메시지 표시)
   - 파일 크기 검증 (오류 메시지 표시)

2. **분석 플로우**:
   - "관상 보기" 클릭 → 로딩 화면 표시
   - 20-30초 후 결과 화면 표시
   - 결과 카드 모든 필드 렌더링 확인

3. **공유 플로우**:
   - "공유하기" 버튼 클릭 → Web Share API 실행 (모바일)
   - "링크 복사" 버튼 클릭 → 클립보드 복사 확인 (데스크톱)

4. **에러 처리**:
   - AI API 오류 시 에러 메시지 표시
   - 네트워크 오류 시 에러 메시지 표시
   - 이미지 생성 실패 시 플레이스홀더 표시

---

## 환경변수

`.env.local`:

```env
# Google Gemini API 키 (필수)
GEMINI_API_KEY=your_gemini_api_key_here

# Google AdSense Publisher ID (필수)
NEXT_PUBLIC_ADSENSE_ID=ca-pub-XXXXXXXXXXXXXXXX

# AdSense 광고 슬롯 ID
NEXT_PUBLIC_ADSENSE_SLOT_BOTTOM=XXXXXXXXX
NEXT_PUBLIC_ADSENSE_SLOT_MIDDLE=XXXXXXXXX
NEXT_PUBLIC_ADSENSE_SLOT_CENTER=XXXXXXXXX
```

---

## 참고 문서

- `docs/talmosang/talmosang/user-story.md` — 사용자 스토리, 시나리오
- `docs/talmosang/talmosang/web-design-spec.md` — UI/UX 디자인 명세
- `docs/talmosang/talmosang/web-brief.md` — 기술 아키텍처 설계
- `apps/web/admin/CLAUDE.md` — 웹 프로젝트 컨벤션 (참조용)

---

## 다음 단계

1. **Group 1 실행**: React Developer가 프로젝트 초기 설정 및 API Routes 구현
2. **검증**: `pnpm dev` 실행, API Routes 로컬 테스트
3. **Group 2 실행**: 컴포넌트 병렬 구현 (layout-structure, upload-section, loading-section, result-section)
4. **통합**: main-page 구현하여 전체 플로우 완성
5. **E2E 테스트**: Playwright 테스트 작성 및 실행
6. **배포**: Vercel 배포, AdSense 설정

---

## 중요 원칙

1. **Server/Client Components 분리** — 기본은 Server Component, 인터랙션 필요 시 `"use client"`
2. **shadcn/ui 컴포넌트 직접 수정 금지** — 커스터마이징은 래퍼 컴포넌트 또는 Tailwind 클래스로
3. **타입 안전성** — 모든 API 응답, Props는 TypeScript 타입 정의 필수
4. **에러 처리** — 모든 에러는 사극 말투로 사용자 친화적 메시지 제공
5. **성능 최적화** — 이미지 리사이즈, 폰트 preload, Code Splitting, Lazy Loading
6. **접근성** — 키보드 내비게이션, alt 텍스트, ARIA 레이블, 색상 대비 WCAG AA 준수

---

## 산출물

- `apps/web/talmosang/` — 완성된 Next.js 16 프로젝트
- Playwright E2E 테스트
- Vercel 배포 준비 완료
- Google AdSense 통합 완료
