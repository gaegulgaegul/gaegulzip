# 기술 아키텍처 설계: 탈모상 (Hair Loss Fortune Telling)

## 개요

"탈모상"은 Google Gemini API를 활용한 바이럴 웹앱으로, Next.js 16 App Router와 shadcn/ui를 기반으로 단일 페이지 상태 전환(업로드 → 로딩 → 결과) 구조를 구현합니다. Server Components와 Client Components를 전략적으로 분리하여 성능과 인터랙션을 최적화합니다.

**핵심 기술 전략**:
- Server/Client Components 명확한 분리
- API Routes를 통한 안전한 Gemini API 통합
- Stateful 상태 관리 (React useState)
- shadcn/ui 커스터마이징으로 손글씨 감성 구현

---

## 프로젝트 구조

```
apps/web/talmosang/
├── app/
│   ├── layout.tsx                    # Root layout (폰트, 메타데이터, AdSense 스크립트)
│   ├── page.tsx                      # 메인 페이지 (Client Component - 상태 관리)
│   ├── globals.css                   # Tailwind + 커스텀 CSS (노이즈, 애니메이션)
│   ├── privacy/
│   │   └── page.tsx                  # 개인정보처리방침 (Server Component)
│   └── api/
│       ├── analyze/
│       │   └── route.ts              # POST - Gemini 2.5 Flash Vision (두피 분석)
│       └── generate-image/
│           └── route.ts              # POST - Gemini 2.0 Flash Exp (이미지 생성)
├── components/
│   ├── UploadSection.tsx             # Client Component (파일 업로드, 프리뷰)
│   ├── LoadingSection.tsx            # Client Component (로딩 애니메이션, 메시지)
│   ├── ResultSection.tsx             # Client Component (결과 표시, 공유)
│   ├── AdBanner.tsx                  # Client Component (AdSense 광고)
│   ├── DisclaimerText.tsx            # Server Component (면책 고지)
│   └── ui/                           # shadcn/ui 컴포넌트 (수정 금지)
│       ├── card.tsx
│       ├── button.tsx
│       ├── progress.tsx
│       ├── badge.tsx
│       └── skeleton.tsx
├── lib/
│   ├── utils.ts                      # cn() 유틸리티 (clsx + tailwind-merge)
│   ├── fonts.ts                      # Next.js 로컬 폰트 설정
│   └── gemini.ts                     # Gemini API 타입 정의
├── types/
│   └── analysis.ts                   # 분석 결과 타입 정의
├── public/
│   ├── noise-texture.svg             # 노이즈 텍스처 오버레이
│   └── decorations/                  # 손그림 SVG (밑줄, 화살표, 별)
├── .env.local                        # 환경변수 (GEMINI_API_KEY, NEXT_PUBLIC_ADSENSE_ID)
├── next.config.ts                    # Next.js 설정
├── tailwind.config.ts                # Tailwind CSS v4 + 커스텀 색상
├── components.json                   # shadcn/ui 설정 (new-york 스타일)
└── package.json
```

---

## Next.js 16 App Router 아키텍처

### Server Components vs Client Components 전략

**기본 원칙**: 모든 컴포넌트는 Server Component가 기본이며, 인터랙션이 필요한 경우만 `"use client"` 사용

#### Server Components (기본)

**장점**:
- Zero JavaScript 전송 (HTML만)
- 빠른 초기 로딩
- SEO 최적화

**사용 컴포넌트**:
- `app/layout.tsx` — Root layout (메타데이터, 폰트)
- `app/privacy/page.tsx` — 정적 페이지
- `components/DisclaimerText.tsx` — 면책 고지 (정적 텍스트)

```tsx
// app/layout.tsx (Server Component)
import type { Metadata } from 'next';
import { Nanum_Pen_Script } from 'next/font/google';
import localFont from 'next/font/local';
import './globals.css';

const nanumPen = Nanum_Pen_Script({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-nanum-pen',
  display: 'swap',
});

const pretendard = localFont({
  src: '../public/fonts/Noto Sans KRVariable.woff2',
  variable: '--font-noto-sans-kr',
  display: 'swap',
});

export const metadata: Metadata = {
  title: '탈모상 - 내가 탈모가 될 상인가?',
  description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
  openGraph: {
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
    images: ['/og-image.png'],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko" className={`${nanumPen.variable} ${pretendard.variable}`}>
      <head>
        {/* Google AdSense */}
        <script
          async
          src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${process.env.NEXT_PUBLIC_ADSENSE_ID}`}
          crossOrigin="anonymous"
        />
      </head>
      <body className="font-noto-sans-kr bg-cream text-charcoal antialiased">
        {/* 노이즈 텍스처 오버레이 */}
        <div className="noise-overlay" aria-hidden="true" />
        {children}
      </body>
    </html>
  );
}
```

#### Client Components (`"use client"`)

**필요 상황**:
- 상태 관리 (`useState`, `useReducer`)
- 이벤트 핸들러 (`onClick`, `onChange`)
- 브라우저 API (`FileReader`, `navigator.share`, `clipboard`)
- 실시간 UI 업데이트 (로딩, 프로그레스)

**사용 컴포넌트**:
- `app/page.tsx` — 메인 페이지 (상태 관리 총괄)
- `components/UploadSection.tsx` — 파일 업로드, 드래그앤드롭
- `components/LoadingSection.tsx` — 로딩 애니메이션, 메시지 전환
- `components/ResultSection.tsx` — 결과 표시, 공유 기능
- `components/AdBanner.tsx` — AdSense 동적 로드

```tsx
// app/page.tsx (Client Component)
'use client';

import { useState } from 'react';
import UploadSection from '@/components/UploadSection';
import LoadingSection from '@/components/LoadingSection';
import ResultSection from '@/components/ResultSection';
import type { AnalysisResult } from '@/types/analysis';

type AppState = 'upload' | 'loading' | 'result';

export default function HomePage() {
  const [state, setState] = useState<AppState>('upload');
  const [photo, setPhoto] = useState<File | null>(null);
  const [result, setResult] = useState<AnalysisResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handlePhotoUpload = (file: File) => {
    setPhoto(file);
    setError(null);
  };

  const handleAnalyze = async () => {
    if (!photo) return;

    setState('loading');
    setError(null);

    try {
      // 1. 두피 분석 API 호출
      const analysisResponse = await fetch('/api/analyze', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          image: await fileToBase64(photo),
          mimeType: photo.type,
        }),
      });

      if (!analysisResponse.ok) {
        throw new Error('분석에 실패했습니다');
      }

      const analysisData: AnalysisResult = await analysisResponse.json();

      // 2. 이미지 생성 API 호출 (병렬 처리 가능)
      const imageResponse = await fetch('/api/generate-image', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: analysisData.imagePrompt }),
      });

      if (imageResponse.ok) {
        const { image } = await imageResponse.json();
        analysisData.simulationImage = image;
      }

      setResult(analysisData);
      setState('result');
    } catch (err) {
      setError(err instanceof Error ? err.message : '알 수 없는 오류 발생');
      setState('upload');
    }
  };

  const handleReset = () => {
    setState('upload');
    setPhoto(null);
    setResult(null);
    setError(null);
  };

  return (
    <main className="container mx-auto px-6 py-12 max-w-lg">
      <header className="text-center mb-12">
        <h1 className="font-nanum-pen text-6xl md:text-8xl text-charcoal rotate-[-2deg] mb-4">
          탈모상
          <div className="scribble-underline" />
        </h1>
      </header>

      {state === 'upload' && (
        <UploadSection
          photo={photo}
          error={error}
          onPhotoUpload={handlePhotoUpload}
          onAnalyze={handleAnalyze}
          onReset={handleReset}
        />
      )}

      {state === 'loading' && <LoadingSection />}

      {state === 'result' && result && (
        <ResultSection result={result} onReset={handleReset} />
      )}
    </main>
  );
}

// 유틸리티 함수
async function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result as string;
      resolve(base64.split(',')[1]); // "data:image/jpeg;base64," 제거
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}
```

---

## 컴포넌트 상세 설계

### 1. UploadSection.tsx (Client Component)

**역할**: 파일 업로드, 드래그앤드롭, 사진 미리보기

**Props**:
```tsx
interface UploadSectionProps {
  photo: File | null;
  error: string | null;
  onPhotoUpload: (file: File) => void;
  onAnalyze: () => void;
  onReset: () => void;
}
```

**주요 기능**:
- 드래그앤드롭 핸들링 (`onDragEnter`, `onDragLeave`, `onDrop`)
- 파일 선택 (`<input type="file" accept="image/*" capture="user">`)
- 파일 검증 (타입, 크기)
- 폴라로이드 프레임 미리보기

```tsx
'use client';

import { useState, useRef } from 'react';
import { CloudUpload, ShieldCheck } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

export default function UploadSection({
  photo,
  error,
  onPhotoUpload,
  onAnalyze,
  onReset,
}: UploadSectionProps) {
  const [isDragging, setIsDragging] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const handleDragEnter = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);

    const file = e.dataTransfer.files[0];
    validateAndUpload(file);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) validateAndUpload(file);
  };

  const validateAndUpload = (file: File) => {
    // 파일 타입 검증
    if (!file.type.startsWith('image/')) {
      alert('지원하지 않는 파일 형식입니다. JPG, PNG 파일을 업로드해주시게.');
      return;
    }

    // 파일 크기 검증 (10MB)
    if (file.size > 10 * 1024 * 1024) {
      alert('파일 크기가 너무 크옵니다. 10MB 이하의 이미지를 올려주시게.');
      return;
    }

    onPhotoUpload(file);
  };

  return (
    <section className="upload-section">
      {/* 메인 카피 */}
      <div className="text-center mb-8">
        <p className="text-2xl md:text-3xl font-bold mb-2">
          이보시오 관상가 양반, 내가 탈모가 될 상인가?
        </p>
        <p className="text-lg text-charcoal/70">
          AI 관상가가 그대의 모발 운명을 점지하리라
        </p>
      </div>

      {/* 업로드 카드 */}
      <Card className="paper-texture pencil-border p-8 hover:scale-[1.02] hover:rotate-[-1deg] transition-transform">
        {!photo ? (
          <div
            className={`drag-drop-zone ${isDragging ? 'dragging' : ''}`}
            onDragEnter={handleDragEnter}
            onDragOver={(e) => e.preventDefault()}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
            onClick={() => inputRef.current?.click()}
          >
            <div className="flex flex-col items-center gap-4 cursor-pointer">
              <div className="border-3 border-dashed border-coral rounded-full p-6">
                <CloudUpload className="w-16 h-16 text-coral" />
              </div>
              <p className="text-lg">사진을 드래그하거나 클릭하여 업로드</p>
              <input
                ref={inputRef}
                type="file"
                accept="image/*"
                capture="user"
                className="hidden"
                onChange={handleFileChange}
              />
            </div>
          </div>
        ) : (
          <div className="preview-section">
            {/* 폴라로이드 프레임 */}
            <div className="polaroid-frame rotate-[1.5deg] mb-6">
              <img
                src={URL.createObjectURL(photo)}
                alt="업로드한 사진"
                className="max-w-full rounded"
              />
              <div className="scribble-star absolute top-2 right-2" />
            </div>

            {/* 버튼 */}
            <div className="flex gap-4 justify-center">
              <Button variant="ghost" onClick={onReset}>
                다시 찍기
              </Button>
              <Button variant="primary" onClick={onAnalyze} className="btn-primary">
                관상 보기
              </Button>
            </div>
          </div>
        )}
      </Card>

      {/* 에러 메시지 */}
      {error && (
        <div className="error-message mt-4 p-4 bg-coral/10 border-2 border-coral rounded-lg">
          <p className="text-coral text-center">{error}</p>
        </div>
      )}

      {/* 안심 문구 */}
      <div className="reassurance-text flex items-center gap-2 mt-6 p-3 bg-cream-light rounded-lg">
        <ShieldCheck className="w-5 h-5 text-forest-green" />
        <p className="text-sm text-charcoal/70">
          업로드한 사진은 분석 후 즉시 삭제됩니다
        </p>
      </div>
    </section>
  );
}
```

### 2. LoadingSection.tsx (Client Component)

**역할**: 로딩 애니메이션, 사극 말투 메시지 전환

**상태**: 메시지 인덱스, 프로그레스 (0-100)

```tsx
'use client';

import { useState, useEffect } from 'react';
import { Search } from 'lucide-react';
import { Progress } from '@/components/ui/progress';

const LOADING_MESSAGES = [
  '두피를 살펴보고 있사옵니다...',
  '모발의 운명을 점치고 있사옵니다...',
  '헤어라인의 기운을 감지하고 있사옵니다...',
  '10년 뒤의 모습을 그려보고 있사옵니다...',
  '관상가 양반이 심사숙고 중이옵니다...',
];

export default function LoadingSection() {
  const [messageIndex, setMessageIndex] = useState(0);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    // 메시지 전환 (2초마다)
    const messageInterval = setInterval(() => {
      setMessageIndex((prev) => (prev + 1) % LOADING_MESSAGES.length);
    }, 2000);

    // 프로그레스 증가 (30초 동안 0 → 100)
    const progressInterval = setInterval(() => {
      setProgress((prev) => Math.min(prev + 100 / 300, 100)); // 100ms마다 증가
    }, 100);

    return () => {
      clearInterval(messageInterval);
      clearInterval(progressInterval);
    };
  }, []);

  return (
    <section className="loading-section text-center">
      {/* 로딩 애니메이션 */}
      <div className="loading-animation relative mb-8">
        {/* 머리카락 떨어지는 애니메이션 */}
        <div className="hair-falling-container">
          {[0, 1, 2, 3, 4].map((i) => (
            <div
              key={i}
              className="hair-strand"
              style={{ animationDelay: `${i * 0.6}s` }}
            />
          ))}
        </div>

        {/* 돋보기 아이콘 (회전) */}
        <Search className="w-20 h-20 text-mustard mx-auto animate-spin-slow" />
      </div>

      {/* 로딩 메시지 */}
      <p className="font-nanum-pen text-3xl text-charcoal mb-8 animate-fade-in">
        {LOADING_MESSAGES[messageIndex]}
      </p>

      {/* 프로그레스 바 */}
      <Progress value={progress} className="hand-drawn-progress max-w-md mx-auto" />
    </section>
  );
}
```

### 3. ResultSection.tsx (Client Component)

**역할**: 분석 결과 표시, 공유 기능

**Props**:
```tsx
interface ResultSectionProps {
  result: AnalysisResult;
  onReset: () => void;
}
```

**주요 기능**:
- 결과 카드 렌더링 (등급, 나이, 확률, 유형, 유명인, 팁)
- 10년 뒤 시뮬레이션 이미지 표시
- Web Share API 또는 폴백 (링크 복사, 이미지 다운로드)

```tsx
'use client';

import { useState } from 'react';
import { Share, Link2, Download, Check } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import type { AnalysisResult } from '@/types/analysis';

export default function ResultSection({ result, onReset }: ResultSectionProps) {
  const [copied, setCopied] = useState(false);

  const handleShare = async () => {
    // Web Share API 지원 여부 확인
    if (navigator.share) {
      try {
        await navigator.share({
          title: '내 탈모 관상 결과',
          text: `모발 등급: ${result.grade}, 5년 내 탈모 확률: ${result.baldProbability5yr}%`,
          url: window.location.href,
        });
      } catch (err) {
        console.error('공유 실패:', err);
      }
    } else {
      // 폴백: 링크 복사
      handleCopyLink();
    }
  };

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error('링크 복사 실패:', err);
    }
  };

  const handleDownloadImage = () => {
    // TODO: html2canvas로 ResultCard 캡처 → PNG 다운로드
  };

  return (
    <section className="result-section">
      {/* 결과 제목 */}
      <h2 className="font-nanum-pen text-4xl text-center mb-8 animate-fade-scale">
        <span className="scribble-star inline-block mr-2" />
        관상 결과가 나왔사옵니다!
        <span className="scribble-star inline-block ml-2" />
      </h2>

      {/* 결과 카드 */}
      <Card className="paper-texture pencil-border p-8 mb-8 rotate-[-0.5deg]">
        {/* 모발 등급 배지 */}
        <div className="grade-badge text-center mb-6">
          <Badge variant="stamp" className="stamp-badge text-2xl px-6 py-3">
            {result.gradeEmoji} {result.grade}
          </Badge>
          <p className="text-lg mt-2">{result.gradeVerdict}</p>
        </div>

        {/* 모발 나이 */}
        <div className="hair-age mb-6">
          <span className="label text-charcoal/70">모발 나이:</span>
          <span className="value text-4xl font-bold text-deep-blue ml-2">
            {result.hairAge}세
          </span>
          <span className="comparison text-sm ml-2 text-forest-green">
            실제 나이보다 5살 젊음
          </span>
        </div>

        {/* 탈모 확률 */}
        <div className="probability mb-6">
          <span className="label text-charcoal/70 block mb-2">5년 내 탈모 확률:</span>
          <Progress
            value={result.baldProbability5yr}
            className="hand-drawn-progress mb-2"
          />
          <span className="value text-2xl font-bold text-coral">
            {result.baldProbability5yr}%
          </span>
        </div>

        {/* 탈모 유형 */}
        <div className="hair-type mb-6">
          <span className="label text-charcoal/70">탈모 유형:</span>
          <Badge variant="type" className="ml-2">
            {result.baldType}
          </Badge>
        </div>

        {/* 닮은 유명인 */}
        <div className="celebrity mb-6">
          <span className="label text-charcoal/70 block mb-2">닮은 유명인:</span>
          <div className="speech-bubble bg-cream border-2 border-deep-blue rounded-lg p-4">
            {result.celebrity}
          </div>
        </div>

        {/* 관리팁 */}
        <div className="tips">
          <span className="label text-charcoal/70 block mb-2">관리 팁:</span>
          <ul className="checklist space-y-2 bg-cream-light p-4 rounded-lg">
            {result.tips.map((tip, index) => (
              <li key={index} className="flex items-start gap-2">
                <Check className="w-5 h-5 text-forest-green flex-shrink-0 mt-0.5" />
                <span>{tip}</span>
              </li>
            ))}
          </ul>
        </div>
      </Card>

      {/* 종합 코멘트 */}
      <div className="comment mb-8 bg-cream border-2 border-dashed border-deep-blue rounded-lg p-6 italic">
        <p className="text-lg">&ldquo;{result.comment}&rdquo;</p>
      </div>

      {/* 광고 */}
      <AdBanner position="middle" />

      {/* 10년 뒤 시뮬레이션 */}
      <Card className="simulation-card paper-texture p-8 mb-8">
        <h3 className="font-nanum-pen text-3xl text-center mb-4">
          10년 뒤의 그대 모습
        </h3>
        {result.simulationImage ? (
          <div className="scroll-frame">
            <img
              src={result.simulationImage}
              alt="10년 뒤 시뮬레이션"
              className="max-w-full rounded-lg shadow-lg"
            />
            <div className="scribble-arrow absolute bottom-4 right-4" />
          </div>
        ) : (
          <div className="placeholder text-center p-12 bg-cream-dark rounded-lg">
            <p className="text-charcoal/50">
              시뮬레이션 이미지를 준비할 수 없사옵니다
            </p>
          </div>
        )}
      </Card>

      {/* 액션 버튼 */}
      <div className="action-buttons flex gap-4 justify-center mb-8">
        <Button variant="secondary" onClick={onReset}>
          다시 관상 보기
        </Button>
        <Button variant="primary" onClick={handleShare} className="btn-primary">
          <Share className="w-4 h-4 mr-2" />
          공유하기
        </Button>
      </div>

      {/* 공유 폴백 버튼 (Web Share API 미지원 시) */}
      {!navigator.share && (
        <div className="share-fallback flex gap-4 justify-center mb-8">
          <Button variant="outline" onClick={handleCopyLink}>
            <Link2 className="w-4 h-4 mr-2" />
            {copied ? '복사됨!' : '링크 복사'}
          </Button>
          <Button variant="outline" onClick={handleDownloadImage}>
            <Download className="w-4 h-4 mr-2" />
            이미지 다운로드
          </Button>
        </div>
      )}
    </section>
  );
}
```

---

## API Routes 설계

### 1. POST /api/analyze (두피 분석)

**역할**: Gemini 2.5 Flash Vision API로 두피 이미지 분석

**Request Body**:
```typescript
interface AnalyzeRequest {
  image: string;      // Base64 인코딩된 이미지
  mimeType: string;   // "image/jpeg" | "image/png"
}
```

**Response**:
```typescript
interface AnalysisResult {
  grade: string;              // "A등급", "B등급" 등
  gradeEmoji: string;         // "🌳", "🌿", "🏜️", "🪨"
  gradeVerdict: string;       // "탄탄한 모발", "풀밭 같은 두피" 등
  hairAge: number;            // 모발 나이 (실제 나이와 비교)
  baldProbability5yr: number; // 5년 내 탈모 확률 (0-100)
  baldType: string;           // "M자형 초기 단계", "정수리형" 등
  celebrity: { name: string; comment: string };  // { name: "송중기", comment: "초기 헤어라인" }
  tips: string[];             // 관리팁 3-5개
  comment: string;            // 종합 코멘트
  imagePrompt: string;        // Gemini 이미지 생성용 프롬프트
}
```

**구현**:
```typescript
// app/api/analyze/route.ts
import { NextRequest, NextResponse } from 'next/server';

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_VISION_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

export async function POST(req: NextRequest) {
  if (!GEMINI_API_KEY) {
    return NextResponse.json(
      { error: '관상가가 아직 준비 중이옵니다' },
      { status: 500 }
    );
  }

  try {
    const { image, mimeType } = await req.json();

    // Gemini API 요청 페이로드
    const payload = {
      contents: [
        {
          parts: [
            {
              text: `당신은 사극 말투를 쓰는 재미있는 AI 관상가입니다. 업로드된 사진의 두피 상태를 재미있게 분석하고, 다음 JSON 형식으로 응답하세요:

{
  "grade": "A등급", // A-F 등급
  "gradeEmoji": "🌳", // 등급 이모지 (A:🌳, B:🌿, C:🏜️, D:🪨)
  "gradeVerdict": "탄탄한 모발", // 등급 설명
  "hairAge": 28, // 모발 나이
  "baldProbability5yr": 35, // 5년 내 탈모 확률 (0-100)
  "baldType": "M자형 초기 단계", // 탈모 유형
  "celebrity": "송중기 초기 헤어라인", // 닮은 유명인
  "tips": ["tip1", "tip2", "tip3"], // 관리팁 3-5개
  "comment": "종합 코멘트 (사극 말투)", // 한 줄 코멘트
  "imagePrompt": "10년 후 예상 헤어라인 이미지 생성용 프롬프트 (영어)"
}

**중요**: 반드시 재미있고 긍정적인 톤으로, 의료 진단이 아닌 엔터테인먼트임을 명확히 하세요.`,
            },
            {
              inline_data: {
                mime_type: mimeType,
                data: image,
              },
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 1.0,
        responseMimeType: 'application/json',
      },
    };

    const response = await fetch(`${GEMINI_VISION_ENDPOINT}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Gemini API 오류:', errorData);

      // Rate Limit 에러 처리
      if (response.status === 429) {
        return NextResponse.json(
          { error: '많은 사람들이 관상을 보고 있사옵니다. 잠시 후 다시 시도해주시게.' },
          { status: 429 }
        );
      }

      throw new Error('Gemini API 호출 실패');
    }

    const data = await response.json();
    const analysisResult = JSON.parse(data.candidates[0].content.parts[0].text);

    return NextResponse.json(analysisResult);
  } catch (error) {
    console.error('분석 오류:', error);
    return NextResponse.json(
      { error: '아이고, 관상가 양반이 잠시 자리를 비웠사옵니다. 잠시 후 다시 시도해주시게.' },
      { status: 500 }
    );
  }
}
```

### 2. POST /api/generate-image (이미지 생성)

**역할**: Gemini 2.0 Flash Exp API로 10년 뒤 헤어라인 시뮬레이션 이미지 생성

**Request Body**:
```typescript
interface GenerateImageRequest {
  prompt: string; // 이미지 생성 프롬프트 (영어)
}
```

**Response**:
```typescript
interface GenerateImageResponse {
  image: string | null;  // "data:image/png;base64,..." 또는 null
  error?: string;
}
```

**구현**:
```typescript
// app/api/generate-image/route.ts
import { NextRequest, NextResponse } from 'next/server';

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_IMAGE_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

export async function POST(req: NextRequest) {
  if (!GEMINI_API_KEY) {
    return NextResponse.json(
      { image: null, error: '이미지 생성 서비스가 준비 중입니다' },
      { status: 500 }
    );
  }

  try {
    const { prompt } = await req.json();

    const payload = {
      contents: [
        {
          parts: [
            {
              text: prompt,
            },
          ],
        },
      ],
      generationConfig: {
        responseModalities: ['TEXT', 'IMAGE'],
      },
    };

    const response = await fetch(`${GEMINI_IMAGE_ENDPOINT}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      console.error('Gemini 이미지 생성 실패:', await response.text());
      return NextResponse.json(
        { image: null, error: '이미지 생성에 실패했습니다' },
        { status: 500 }
      );
    }

    const data = await response.json();
    const imagePart = data.candidates[0].content.parts.find(
      (part: any) => part.inline_data
    );

    if (!imagePart) {
      return NextResponse.json(
        { image: null, error: '이미지 생성에 실패했습니다' },
        { status: 500 }
      );
    }

    const imageBase64 = imagePart.inline_data.data;
    const imageUrl = `data:image/png;base64,${imageBase64}`;

    return NextResponse.json({ image: imageUrl });
  } catch (error) {
    console.error('이미지 생성 오류:', error);
    return NextResponse.json(
      { image: null, error: '이미지 생성 중 오류가 발생했습니다' },
      { status: 500 }
    );
  }
}
```

---

## 타입 정의

```typescript
// types/analysis.ts

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
  celebrity: { name: string; comment: string };

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

---

## shadcn/ui 커스터마이징 전략

### 설치 및 설정

```bash
cd apps/web/talmosang

# shadcn/ui 초기화
npx shadcn@latest init

# 설정 선택
# - Style: new-york
# - Base color: neutral
# - CSS variables: yes

# 컴포넌트 설치
npx shadcn@latest add card button progress badge skeleton
```

### components.json

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils"
  }
}
```

### 커스텀 스타일 (globals.css)

```css
/* app/globals.css */
@import "tailwindcss";

/* CSS 변수 (shadcn/ui + 커스텀) */
@theme {
  /* 색상 팔레트 */
  --color-charcoal: #2d2d2d;
  --color-cream: #fff8f0;
  --color-cream-light: #fffbf5;
  --color-cream-dark: #f5e6d3;
  --color-coral: #e85d4a;
  --color-deep-blue: #2b4c7e;
  --color-mustard: #f2a541;
  --color-forest-green: #4a7c59;

  /* 폰트 */
  --font-nanum-pen: var(--font-nanum-pen);
  --font-noto-sans-kr: var(--font-noto-sans-kr);
}

/* 노이즈 텍스처 오버레이 */
.noise-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url('/noise-texture.svg');
  opacity: 0.05;
  pointer-events: none;
  z-index: 9999;
}

/* 종이 텍스처 (Card) */
.paper-texture {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4'/%3E%3C/filter%3E%3Crect width='100' height='100' filter='url(%23noise)' opacity='0.05'/%3E%3C/svg%3E");
  background-blend-mode: multiply;
}

/* 연필 테두리 (Card) */
.pencil-border {
  border: 3px solid var(--color-charcoal);
  border-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M0,1 Q2,0.5 4,1 T8,1' stroke='%232d2d2d' fill='none'/%3E%3C/svg%3E") 3;
}

/* 손그림 프로그레스 바 */
.hand-drawn-progress [role="progressbar"] {
  background: linear-gradient(90deg, var(--color-coral), var(--color-mustard));
  clip-path: polygon(0% 0%, 98% 2%, 100% 50%, 98% 98%, 2% 100%, 0% 50%);
}

/* 폴라로이드 프레임 */
.polaroid-frame {
  background: white;
  padding: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border-radius: 4px;
}

/* 도장 배지 */
.stamp-badge {
  background: radial-gradient(circle, var(--color-coral), #d14d3a);
  border-radius: 50%;
  filter: opacity(0.9);
  transform: rotate(-5deg);
}

/* 말풍선 */
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

/* 애니메이션 */
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes fade-scale {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes shake {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(2deg); }
  75% { transform: rotate(-2deg); }
}

@keyframes wiggle {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-4px); }
  75% { transform: translateX(4px); }
}

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

/* 유틸리티 클래스 */
.animate-fade-in {
  animation: fade-in 0.3s ease-in-out;
}

.animate-fade-scale {
  animation: fade-scale 0.5s ease-out;
}

.btn-primary {
  @apply bg-coral text-white hover:bg-coral/90 hover:scale-105 transition-all;
  box-shadow: 0 4px 8px rgba(232, 93, 74, 0.3);
}

.btn-primary:hover {
  animation: shake 0.5s;
}

.btn-ghost:hover {
  animation: wiggle 0.5s;
}

.hair-strand {
  position: absolute;
  width: 2px;
  height: 20px;
  background: var(--color-charcoal);
  animation: fall 3s infinite ease-in;
}

.animate-spin-slow {
  animation: spin 2s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
```

---

## SEO 및 성능 최적화

### 메타데이터 (layout.tsx)

```typescript
export const metadata: Metadata = {
  title: '탈모상 - 내가 탈모가 될 상인가?',
  description: 'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 업로드만으로 재미있는 두피 분석 결과를 확인하세요.',
  keywords: ['탈모', 'AI 관상', '두피 분석', '헤어라인', '바이럴 게임'],
  openGraph: {
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
    type: 'website',
    url: 'https://talmosang.vercel.app',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: '탈모상 OG 이미지',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
    images: ['/og-image.png'],
  },
};
```

### 이미지 최적화

```typescript
// 클라이언트 측 이미지 리사이즈
async function resizeImage(file: File, maxWidth: number = 800): Promise<File> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');

    img.onload = () => {
      const ratio = maxWidth / img.width;
      canvas.width = maxWidth;
      canvas.height = img.height * ratio;

      ctx?.drawImage(img, 0, 0, canvas.width, canvas.height);

      canvas.toBlob((blob) => {
        if (blob) {
          resolve(new File([blob], file.name, { type: file.type }));
        } else {
          reject(new Error('이미지 리사이즈 실패'));
        }
      }, file.type);
    };

    img.onerror = reject;
    img.src = URL.createObjectURL(file);
  });
}
```

### 폰트 로딩 (next/font)

```typescript
// lib/fonts.ts
import { Nanum_Pen_Script } from 'next/font/google';
import localFont from 'next/font/local';

export const nanumPen = Nanum_Pen_Script({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-nanum-pen',
  display: 'swap',
  preload: true, // 중요 폰트 preload
});

export const pretendard = localFont({
  src: '../public/fonts/Noto Sans KRVariable.woff2',
  variable: '--font-noto-sans-kr',
  display: 'swap',
});
```

### Code Splitting

```typescript
// app/page.tsx
'use client';

import { lazy, Suspense } from 'react';

// LoadingSection은 lazy load (초기 번들 크기 감소)
const LoadingSection = lazy(() => import('@/components/LoadingSection'));
const ResultSection = lazy(() => import('@/components/ResultSection'));

export default function HomePage() {
  // ...

  return (
    <main>
      {state === 'upload' && <UploadSection {...props} />}

      {state === 'loading' && (
        <Suspense fallback={<div>로딩 중...</div>}>
          <LoadingSection />
        </Suspense>
      )}

      {state === 'result' && result && (
        <Suspense fallback={<div>결과 준비 중...</div>}>
          <ResultSection result={result} onReset={handleReset} />
        </Suspense>
      )}
    </main>
  );
}
```

---

## 에러 처리 전략

### 에러 타입별 메시지

```typescript
// lib/errors.ts

export const ERROR_MESSAGES = {
  FILE_TYPE: '지원하지 않는 파일 형식입니다. JPG, PNG 파일을 업로드해주시게.',
  FILE_SIZE: '파일 크기가 너무 크옵니다. 10MB 이하의 이미지를 올려주시게.',
  FACE_NOT_FOUND: '얼굴을 찾을 수 없사옵니다. 정면 사진으로 다시 시도해주시게.',
  API_ERROR: '아이고, 관상가 양반이 잠시 자리를 비웠사옵니다. 잠시 후 다시 시도해주시게.',
  NETWORK_ERROR: '통신이 원활하지 않사옵니다. 네트워크 연결을 확인해주시게.',
  RATE_LIMIT: '많은 사람들이 관상을 보고 있사옵니다. 잠시 후 다시 시도해주시게.',
  IMAGE_GENERATION_FAILED: '시뮬레이션 이미지를 준비할 수 없사옵니다',
  CAMERA_PERMISSION_DENIED: '카메라 권한이 필요하옵니다. 브라우저 설정에서 권한을 허용해주시게.',
} as const;
```

### 에러 UI 컴포넌트

```typescript
// components/ErrorMessage.tsx
import { AlertCircle } from 'lucide-react';

interface ErrorMessageProps {
  message: string;
  onRetry?: () => void;
}

export default function ErrorMessage({ message, onRetry }: ErrorMessageProps) {
  return (
    <div className="error-message bg-coral/10 border-2 border-coral rounded-lg p-4 flex items-start gap-3">
      <AlertCircle className="w-6 h-6 text-coral flex-shrink-0" />
      <div className="flex-1">
        <p className="text-coral font-medium">{message}</p>
        {onRetry && (
          <button
            onClick={onRetry}
            className="mt-2 text-sm text-coral underline hover:no-underline"
          >
            다시 시도
          </button>
        )}
      </div>
    </div>
  );
}
```

---

## Google AdSense 통합

### 광고 컴포넌트

```typescript
// components/AdBanner.tsx
'use client';

import { useEffect } from 'react';

interface AdBannerProps {
  position: 'bottom' | 'middle' | 'center';
}

export default function AdBanner({ position }: AdBannerProps) {
  useEffect(() => {
    try {
      (window.adsbygoogle = window.adsbygoogle || []).push({});
    } catch (err) {
      console.error('AdSense 로드 실패:', err);
    }
  }, []);

  const adSlotId = {
    bottom: process.env.NEXT_PUBLIC_ADSENSE_SLOT_BOTTOM,
    middle: process.env.NEXT_PUBLIC_ADSENSE_SLOT_MIDDLE,
    center: process.env.NEXT_PUBLIC_ADSENSE_SLOT_CENTER,
  }[position];

  return (
    <div className="ad-container my-8 text-center">
      <p className="text-xs text-charcoal/50 mb-2">광고</p>
      <ins
        className="adsbygoogle"
        style={{ display: 'block' }}
        data-ad-client={process.env.NEXT_PUBLIC_ADSENSE_ID}
        data-ad-slot={adSlotId}
        data-ad-format="auto"
        data-full-width-responsive="true"
      />
    </div>
  );
}
```

---

## 환경변수 설정

```env
# .env.local

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

## 배포 설정 (Vercel)

### next.config.ts

```typescript
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'generativelanguage.googleapis.com',
      },
    ],
  },
  // CSP 설정
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://pagead2.googlesyndication.com",
              "style-src 'self' 'unsafe-inline'",
              "img-src 'self' data: https:",
              "connect-src 'self' https://generativelanguage.googleapis.com",
              "frame-src https://googleads.g.doubleclick.net",
            ].join('; '),
          },
        ],
      },
    ];
  },
};

export default nextConfig;
```

---

## 파일별 구현 가이드

### 1단계: 프로젝트 초기화

```bash
# 프로젝트 생성
npx create-next-app@latest apps/web/talmosang --typescript --tailwind --app --no-src-dir

cd apps/web/talmosang

# shadcn/ui 초기화
npx shadcn@latest init

# 컴포넌트 설치
npx shadcn@latest add card button progress badge skeleton

# 추가 패키지 설치
pnpm add lucide-react clsx tailwind-merge
```

### 2단계: 타입 정의 (types/analysis.ts)

위 "타입 정의" 섹션 코드 복사

### 3단계: API Routes 구현

- `app/api/analyze/route.ts` — 위 "API Routes 설계" 섹션 코드
- `app/api/generate-image/route.ts` — 위 "API Routes 설계" 섹션 코드

### 4단계: 컴포넌트 구현

- `components/UploadSection.tsx` — 위 "컴포넌트 상세 설계" 섹션 코드
- `components/LoadingSection.tsx` — 위 "컴포넌트 상세 설계" 섹션 코드
- `components/ResultSection.tsx` — 위 "컴포넌트 상세 설계" 섹션 코드
- `components/AdBanner.tsx` — 위 "Google AdSense 통합" 섹션 코드
- `components/DisclaimerText.tsx` — 정적 면책 문구 컴포넌트

### 5단계: 메인 페이지 (app/page.tsx)

위 "Server Components vs Client Components 전략" 섹션 코드

### 6단계: 레이아웃 (app/layout.tsx)

위 "Server Components" 섹션 코드

### 7단계: 스타일 (app/globals.css)

위 "shadcn/ui 커스터마이징 전략" 섹션 코드

### 8단계: 환경변수 설정

`.env.local` 파일 생성 후 위 "환경변수 설정" 섹션 참조

### 9단계: 배포 설정

`next.config.ts` — 위 "배포 설정" 섹션 코드

---

## 검증 기준

- [ ] Next.js 16 App Router 패턴 준수 (Server/Client Components 분리)
- [ ] API Routes를 통한 안전한 Gemini API 통합 (키 노출 방지)
- [ ] shadcn/ui 컴포넌트 활용 및 커스터마이징 (손글씨 감성)
- [ ] 단일 페이지 상태 전환 (upload → loading → result)
- [ ] 에러 처리 완비 (사극 말투 메시지)
- [ ] SEO 메타데이터 설정 (OG 이미지, Twitter Card)
- [ ] 성능 최적화 (이미지 리사이즈, 폰트 preload, Code Splitting)
- [ ] Google AdSense 통합 (3-4개 광고 영역)
- [ ] 반응형 디자인 (모바일 우선)
- [ ] 접근성 준수 (키보드 내비게이션, alt 텍스트, ARIA 레이블)

---

## 다음 단계

1. **Web Developer**가 위 파일별 구현 가이드를 따라 코드 작성
2. 로컬 환경에서 테스트 (`pnpm dev`)
3. Gemini API 키 설정 및 분석 테스트
4. Vercel 배포 및 AdSense 설정
5. 실제 사용자 피드백 수집 및 개선

---

## 참고 자료

### Next.js 16 App Router
- [Next.js 16 App Router 공식 문서](https://nextjs.org/docs/app)
- [Server and Client Components 가이드](https://nextjs.org/docs/app/getting-started/server-and-client-components)

### Google Gemini API
- [Gemini 2.5 Flash 모델 문서](https://ai.google.dev/gemini-api/docs/models)
- [Gemini 2.5 Flash Image 소개](https://developers.googleblog.com/introducing-gemini-2-5-flash-image/)

### shadcn/ui
- [shadcn/ui Next.js 설치 가이드](https://ui.shadcn.com/docs/installation/next)

### 디자인 영감
- [Al Murphy 웹사이트](https://www.al-murphy.com) — 손글씨 폰트, 크림 배경, 낙서 감성
- [2026 디자인 트렌드](https://www.kittl.com/blogs/graphic-design-trends-2026/) — 손그림 스타일, 레트로 감성

---

## Sources

- [Next.js 16 App Router Documentation](https://nextjs.org/docs/app)
- [Server and Client Components Guide](https://nextjs.org/docs/app/getting-started/server-and-client-components)
- [Gemini 2.5 Flash Model Documentation](https://ai.google.dev/gemini-api/docs/models)
- [Introducing Gemini 2.5 Flash Image](https://developers.googleblog.com/introducing-gemini-2-5-flash-image/)
- [shadcn/ui Installation Guide](https://ui.shadcn.com/docs/installation/next)
