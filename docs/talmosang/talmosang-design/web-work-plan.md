# 탈모상 디자인 개선 작업 분배 계획 (Al Murphy 스타일)

**Feature**: talmosang-design
**Platform**: Web
**Framework**: Next.js 16 + Tailwind CSS v4 + shadcn/ui
**작성일**: 2026-02-14

---

## 개요

탈모상 웹앱을 Al Murphy 웹사이트(https://www.al-murphy.com)의 대담하고 맥시멀리스트 스타일로 전면 재설계합니다.

**현재 Critical 이슈**:
- CSS가 전혀 렌더링되지 않음 (Tailwind v4 PostCSS 플러그인 누락)
- 브라우저에서 흰색 배경, 기본 폰트만 보임
- 컴파일된 CSS 파일 크기: **9바이트** (빈 파일)

**디자인 목표**:
- 밝은 원색 배경 (#FFE847 노란색)
- 거대하고 대담한 타이포그래피 (text-9xl, Black Han Sans)
- 풀와이드 레이아웃 (섹션별 배경색)
- 하드 그림자 스타일 (12px 12px 0 #000)

---

## 실행 그룹

### Group 1 (순차) — CSS 빌드 수정 (Critical, 최우선)

**목적**: Tailwind CSS v4 PostCSS 설정 추가하여 CSS 빌드 활성화

| 작업 | 담당 | 설명 | 예상 시간 |
|------|------|------|----------|
| Task 1-1: PostCSS 설정 | react-developer | `@tailwindcss/postcss` 설치, `postcss.config.mjs` 생성 | 5분 |
| Task 1-2: 검증 | react-developer | dev 서버 재시작 후 기존 스타일 복원 확인 | 5분 |

**순차 실행 이유**: 이 작업 없이는 CSS가 전혀 동작하지 않으므로 모든 작업의 선행 조건

**검증 기준**:
- `pnpm dev` 실행 시 CSS 컴파일 성공
- 브라우저에서 크림 배경색 (#FFF8F0) 렌더링
- 카드 테두리, 버튼 스타일 복원

---

### Group 2 (순차) — Tailwind v4 마이그레이션 + 폰트 변경

**목적**: Tailwind v3 → v4 마이그레이션, Al Murphy 색상 팔레트 적용, 폰트 변경

**의존성**: Group 1 완료 후 진행

| 작업 | 담당 | 설명 | 예상 시간 |
|------|------|------|----------|
| Task 2-1: globals.css 수정 | react-developer | `@theme` 블록 추가, Al Murphy 색상/그림자 정의 | 10분 |
| Task 2-2: 폰트 변경 | react-developer | Black Han Sans, Jua 추가, `lib/fonts.ts` 수정 | 5분 |
| Task 2-3: layout.tsx 폰트 적용 | react-developer | 폰트 변수 적용 | 3분 |
| Task 2-4: tailwind.config.ts 삭제/최소화 | react-developer | Tailwind v4는 `@theme` 사용, config 파일 불필요 | 2분 |
| Task 2-5: 검증 | react-developer | 노란색 배경, Black Han Sans 폰트, 하드 그림자 확인 | 5분 |

**순차 실행 이유**: 폰트와 색상 시스템이 확립되어야 컴포넌트 수정 가능

**검증 기준**:
- 배경색이 밝은 노란색 (#FFE847)으로 변경
- 타이틀 "탈모상"이 Black Han Sans로 렌더링
- 하드 그림자 (12px 12px 0 #000) 렌더링

---

### Group 3 (순차) — 컴포넌트 수정

**목적**: 기존 컴포넌트를 Al Murphy 스타일로 재디자인

**의존성**: Group 2 완료 후 진행 (폰트/색상 시스템 필요)

| 작업 | 담당 | 설명 | 예상 시간 |
|------|------|------|----------|
| Task 3-1: 앱 타이틀 재디자인 | react-developer | `app/page.tsx` 수정, 거대한 타이틀 (text-9xl) + 흰색 배경 + 핑크 그림자 | 10분 |
| Task 3-2: UploadSection 재디자인 | react-developer | `components/UploadSection.tsx` 수정, 원형 드래그존 + 거대한 버튼 | 15분 |
| Task 3-3: LoadingSection 재디자인 | react-developer | `components/LoadingSection.tsx` 수정, 그라디언트 프로그레스 바 + Jua 폰트 | 10분 |
| Task 3-4: ResultSection 재디자인 | react-developer | `components/ResultSection.tsx` 수정, 원형 등급 배지 + 카드 그리드 | 20분 |
| Task 3-5: 검증 | react-developer | 각 섹션별 스타일 확인, 애니메이션 동작 확인 | 10분 |

**순차 실행 이유**: 컴포넌트 간 스타일 일관성 유지, 충돌 방지

**검증 기준**:
- 타이틀이 text-9xl 크기로 렌더링
- 드래그앤드롭 영역이 원형 (border-radius: 50%)
- 버튼이 거대한 빨간색 (px-20 py-8)
- 프로그레스 바가 그라디언트 (노란→빨강→초록)
- 등급 배지가 원형 (300x300px)

---

### Group 4 (선택적) — 레이아웃 변경

**목적**: 풀와이드 섹션 적용, 섹션별 배경색 전환

**의존성**: Group 3 완료 후 진행 (컴포넌트 스타일 확정 필요)

**⚠️ 주의**: 이 작업은 선택적이며, 전체 레이아웃을 재구성하므로 신중히 진행

| 작업 | 담당 | 설명 | 예상 시간 |
|------|------|------|----------|
| Task 4-1: 풀와이드 섹션 적용 | react-developer | `app/page.tsx` 전면 재구성, 섹션별 배경색 적용 | 20분 |
| Task 4-2: 반응형 레이아웃 테스트 | react-developer | 모바일/태블릿/데스크톱 확인 | 10분 |
| Task 4-3: 검증 | react-developer | 섹션별 배경색 (노란→핑크→하늘색→다크 그린) 확인 | 5분 |

**순차 실행 이유**: 레이아웃 변경은 전체 구조에 영향을 미치므로 마지막 단계에서 진행

**검증 기준**:
- Hero Section 배경: #FFE847 (노란색)
- Loading Section 배경: #FF69B4 (핫핑크)
- Result Section 배경: #87CEEB (하늘색)
- Footer 배경: #2D5F3F (다크 그린)

---

## 상세 작업 내용

### Group 1: CSS 빌드 수정

#### Task 1-1: PostCSS 설정 추가

**변경 파일**: 신규 생성

**1. 의존성 설치**

```bash
cd /Users/lms/dev/repository/feature-talmosang-mvp/apps/web/talmosang
pnpm add -D @tailwindcss/postcss
```

**2. postcss.config.mjs 생성**

**파일**: `apps/web/talmosang/postcss.config.mjs`

```javascript
/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: {
    '@tailwindcss/postcss': {},
  },
};

export default config;
```

**3. 검증**

```bash
pnpm dev
```

브라우저에서 크림 배경색 (#FFF8F0), 카드 테두리, 버튼 스타일이 복원되는지 확인

---

### Group 2: Tailwind v4 마이그레이션 + 폰트 변경

#### Task 2-1: globals.css 수정

**변경 파일**: `apps/web/talmosang/app/globals.css`

**변경 사항**:
1. `@theme` 블록 추가 (Tailwind v4 형식)
2. Al Murphy 색상 팔레트 정의
3. 하드 그림자 변수 정의
4. 기존 CSS 클래스 수정 (하드 그림자 적용)

**상세 내용**: `web-brief.md` Task 1-2 참조 (Line 94-526)

**핵심 변경점**:
- 배경색: `--color-cream` (#FFF8F0) → `--color-bg-yellow` (#FFE847)
- 그림자: soft blur → hard shadow (`12px 12px 0 #000`)
- 테두리: 3px → 8-10px solid black
- Border Radius: 증가 (24px → 48px)

#### Task 2-2: 폰트 변경

**변경 파일**: `apps/web/talmosang/lib/fonts.ts`

**Before** (현재):
```typescript
import { Nanum_Pen_Script, Noto_Sans_KR } from 'next/font/google';

export const nanumPen = Nanum_Pen_Script({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-nanum-pen',
  display: 'swap',
  preload: true,
});

export const pretendard = Noto_Sans_KR({
  weight: ['400', '500', '700'],
  subsets: ['latin'],
  variable: '--font-pretendard',
  display: 'swap',
});
```

**After** (Al Murphy 스타일):
```typescript
import { Black_Han_Sans, Jua, Noto_Sans_KR } from 'next/font/google';

/**
 * Black Han Sans (굵은 타이틀 폰트)
 */
export const blackHanSans = Black_Han_Sans({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-black-han',
  display: 'swap',
  preload: true,
});

/**
 * Jua (둥근 손글씨 폰트)
 */
export const jua = Jua({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-jua',
  display: 'swap',
  preload: true,
});

/**
 * Noto Sans KR (본문 폰트)
 */
export const notoSansKr = Noto_Sans_KR({
  weight: ['400', '500', '700', '900'], // ExtraBold 추가
  subsets: ['latin'],
  variable: '--font-pretendard',
  display: 'swap',
});
```

#### Task 2-3: layout.tsx 폰트 적용

**변경 파일**: `apps/web/talmosang/app/layout.tsx`

**Before**:
```typescript
import { nanumPen, pretendard } from '@/lib/fonts';

// ...

<html lang="ko" className={`${nanumPen.variable} ${pretendard.variable}`}>
```

**After**:
```typescript
import { blackHanSans, jua, notoSansKr } from '@/lib/fonts';

// ...

<html
  lang="ko"
  className={`${blackHanSans.variable} ${jua.variable} ${notoSansKr.variable}`}
>
```

#### Task 2-4: tailwind.config.ts 삭제/최소화

**변경 파일**: `apps/web/talmosang/tailwind.config.ts`

**Option A: 파일 삭제 (권장)**
```bash
rm apps/web/talmosang/tailwind.config.ts
```

**Option B: 최소 설정만 유지**
```typescript
import type { Config } from 'tailwindcss';

export default {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
} satisfies Config;
```

---

### Group 3: 컴포넌트 수정

#### Task 3-1: 앱 타이틀 재디자인

**변경 파일**: `apps/web/talmosang/app/page.tsx`

**Before** (Line 176-184):
```tsx
<h1
  className="text-4xl md:text-5xl text-charcoal rotate-[-2deg]"
  style={{ fontFamily: 'var(--font-nanum-pen)' }}
>
  탈모상
</h1>
<div className="scribble-underline mx-auto max-w-[120px]" />
```

**After** (Al Murphy 스타일):
```tsx
<h1 className="inline-block text-7xl md:text-9xl text-black rotate-[-3deg] animate-bounce-in">
  <span
    className="inline-block bg-white border-[6px] border-black rounded-full px-16 py-8 shadow-[4px_4px_0_#FF69B4]"
    style={{ fontFamily: 'var(--font-black-han)' }}
  >
    탈모상
  </span>
</h1>
<div className="scribble-underline mx-auto max-w-[200px]" />
```

**변경 사항**:
- 폰트: Nanum Pen Script → Black Han Sans
- 크기: text-4xl → text-7xl (모바일), text-5xl → text-9xl (데스크톱)
- 배경: 흰색 타원형 배경 추가
- 테두리: 6px solid black
- 그림자: 핑크 그림자 (`4px 4px 0 #FF69B4`)
- 회전: -2deg → -3deg
- 애니메이션: bounce 효과

#### Task 3-2: UploadSection 재디자인

**변경 파일**: `components/UploadSection.tsx`

**주요 변경점**:

**1. 메인 카피 텍스트 크기 증가** (Line 110-115)

Before: `text-2xl md:text-3xl font-bold`
After: `text-3xl md:text-4xl font-extrabold`

**2. 드래그앤드롭 영역 재디자인**

globals.css의 `.drag-drop-zone` 클래스가 이미 Al Murphy 스타일로 변경됨 (원형, 노란색 배경)

아이콘 크기만 증가:
```tsx
<CloudUpload className="w-32 h-32 text-black" /> {/* w-16 h-16 → w-32 h-32 */}
<p className="text-2xl font-bold text-black mt-4">
  사진을 드래그하거나 클릭하여 업로드
</p>
```

**3. 폴라로이드 프레임에 스티커 장식 추가** (Line 149-158)

```tsx
<div className="polaroid-frame rotate-[2deg] mb-6 relative mx-auto max-w-md">
  {previewUrl && (
    <img src={previewUrl} alt="업로드한 사진" className="w-full rounded" />
  )}
  {/* 스티커 장식 추가 */}
  <div className="scribble-star absolute top-4 right-4" />
</div>
```

**4. 버튼 크기 증가** (Line 172-178)

```tsx
<Button
  onClick={onAnalyze}
  className="btn-primary text-3xl px-20 py-8"
>
  관상 보기
</Button>
```

#### Task 3-3: LoadingSection 재디자인

**변경 파일**: `components/LoadingSection.tsx`

**주요 변경점**:

**1. 로딩 메시지 폰트 변경** (Line 66-68)

Before:
```tsx
<p className="font-nanum-pen text-xl md:text-2xl text-charcoal mb-8 animate-fade-in">
```

After:
```tsx
<p
  className="text-4xl md:text-5xl text-black mb-8 animate-fade-in"
  style={{ fontFamily: 'var(--font-jua)' }}
>
```

**2. 로딩 애니메이션 크기 증가** (Line 59-61)

Before:
```tsx
<Search className="w-20 h-20 text-mustard animate-spin-slow" />
```

After:
```tsx
<div className="w-[200px] h-[200px] mx-auto bg-white border-[6px] border-black rounded-full flex items-center justify-center shadow-[8px_8px_0_#000]">
  <Search className="w-24 h-24 text-black animate-rotate" />
</div>
```

**3. 프로그레스 바 재디자인** (Line 71-77)

Before:
```tsx
<Progress value={progress} className="hand-drawn-progress h-4" />
```

After:
```tsx
<div className="relative w-full max-w-2xl h-12 bg-white border-[6px] border-black rounded-[24px] shadow-[8px_8px_0_#000] overflow-hidden mx-auto">
  <div
    className="h-full bg-gradient-to-r from-[var(--color-bg-yellow)] via-[var(--color-accent-red)] to-[var(--color-accent-green)] rounded-[20px] transition-all duration-500"
    style={{ width: `${progress}%` }}
  />
  <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 font-extrabold text-2xl text-black z-10">
    {progress}%
  </div>
</div>
```

#### Task 3-4: ResultSection 재디자인

**변경 파일**: `components/ResultSection.tsx`

**주요 변경점**:

**1. 결과 제목 재디자인** (Line 98-105)

Before:
```tsx
<h2 className="font-[family-name:var(--font-nanum-pen)] text-4xl md:text-5xl text-center mb-8 animate-fade-scale">
```

After:
```tsx
<h2
  className="text-5xl md:text-7xl text-black text-center mb-8 animate-bounce-in inline-block bg-white border-[8px] border-black rounded-[48px] px-16 py-8 shadow-[12px_12px_0_#000] rotate-[-2deg]"
  style={{ fontFamily: 'var(--font-jua)' }}
>
  <span className="scribble-star inline-block mr-4" />
  관상 결과가 나왔사옵니다!
  <span className="scribble-star inline-block ml-4" />
</h2>
```

**2. 등급 배지 재디자인** (Line 110-120)

Before:
```tsx
<Badge variant="stamp" className="text-xl md:text-2xl px-6 py-3 mb-3">
  {result.gradeEmoji} {result.grade}
</Badge>
```

After:
```tsx
<div
  className="w-[300px] h-[300px] mx-auto border-[10px] border-black rounded-full shadow-[12px_12px_0_#000] rotate-[-8deg] flex flex-col items-center justify-center"
  style={{ backgroundColor: gradeColor }}
>
  <span className="text-7xl md:text-9xl font-extrabold text-white">
    {result.grade}
  </span>
  <span className="text-5xl mt-4">{result.gradeEmoji}</span>
</div>
<p className="text-2xl md:text-3xl font-bold mt-4 text-center">
  {result.gradeVerdict}
</p>
```

**등급별 배경색**:
```tsx
const gradeColor = {
  'A': 'var(--color-accent-green)',
  'B': 'var(--color-bg-yellow)',
  'C': 'var(--color-accent-orange)',
  'D': 'var(--color-accent-red)',
}[result.grade[0]] || 'var(--color-accent-green)';
```

**3. 버튼 재디자인** (Line 225-232)

Before:
```tsx
<Button variant="outline" onClick={onReset} className="text-base px-8 py-6 rounded-3xl">
  다시 관상 보기
</Button>
<Button variant="primary" onClick={handleShare} className="text-base px-8 py-6 rounded-3xl">
  <Share2 className="w-5 h-5" />
  {copied ? '복사 완료!' : '관상 결과 공유하기'}
</Button>
```

After:
```tsx
<Button
  variant="outline"
  onClick={onReset}
  className="bg-white text-black border-[6px] border-black rounded-[48px] px-16 py-6 text-2xl font-extrabold shadow-[8px_8px_0_#000] hover:bg-[var(--color-bg-yellow)] hover:rotate-[-2deg] hover:scale-105"
>
  다시 관상 보기
</Button>
<Button
  variant="primary"
  onClick={handleShare}
  className="btn-primary"
>
  <Share2 className="w-6 h-6 mr-3" />
  {copied ? '복사 완료!' : '관상 결과 공유하기'}
</Button>
```

---

### Group 4: 레이아웃 변경 (선택적)

#### Task 4-1: 풀와이드 섹션 적용

**변경 파일**: `apps/web/talmosang/app/page.tsx`

**Before** (Line 174):
```tsx
<main className="min-h-screen px-4 py-8 max-w-lg mx-auto">
```

**After**:
```tsx
<main className="min-h-screen">
  {/* Hero Section (노란색 배경) */}
  <section className="bg-yellow-primary min-h-screen px-8 py-20">
    <div className="max-w-4xl mx-auto">
      {/* 헤더 + 업로드 */}
      <header className="text-center mb-8">
        <h1 className="inline-block text-7xl md:text-9xl text-black rotate-[-3deg] animate-bounce-in">
          <span
            className="inline-block bg-white border-[6px] border-black rounded-full px-16 py-8 shadow-[4px_4px_0_#FF69B4]"
            style={{ fontFamily: 'var(--font-black-han)' }}
          >
            탈모상
          </span>
        </h1>
        <div className="scribble-underline mx-auto max-w-[200px]" />
      </header>

      <AdBanner className="mb-6" />
      <DisclaimerText />

      {step === 'upload' && (
        <UploadSection
          photo={photo}
          previewUrl={previewUrl}
          error={error}
          onPhotoUpload={handlePhotoUpload}
          onAnalyze={handleAnalyze}
          onReset={handleReset}
        />
      )}
    </div>
  </section>

  {/* Loading Section (핫핑크 배경) */}
  {step === 'loading' && (
    <section className="bg-pink-primary min-h-screen px-8 py-20">
      <div className="max-w-4xl mx-auto">
        <LoadingSection />
      </div>
    </section>
  )}

  {/* Result Section (하늘색 배경) */}
  {step === 'result' && result && (
    <section className="bg-sky-blue min-h-screen px-8 py-20">
      <div className="max-w-5xl mx-auto">
        <ResultSection result={result} onReset={handleReset} />
      </div>
    </section>
  )}

  {/* Footer (다크 그린 배경) */}
  <footer className="bg-dark-green text-white text-center py-12 px-8">
    <DisclaimerText />
    <p className="text-sm mt-6 opacity-70">
      © 2026 탈모상 | <Link href="/privacy" className="underline">개인정보처리방침</Link>
    </p>
  </footer>
</main>
```

**주의**: 이 변경은 전체 레이아웃을 재구성하므로, 다른 작업이 완료된 후 적용하는 것을 권장합니다.

---

## 검증 체크리스트

### Group 1 완료 후

- [ ] `pnpm dev` 실행 시 CSS 컴파일 성공
- [ ] 브라우저에서 크림 배경색 (#FFF8F0) 보임
- [ ] 카드 테두리 렌더링됨
- [ ] 버튼 스타일 적용됨
- [ ] 콘솔에 CSS 에러 없음

### Group 2 완료 후

- [ ] 배경색이 밝은 노란색 (#FFE847)으로 변경됨
- [ ] 타이틀 "탈모상"이 Black Han Sans로 렌더링됨
- [ ] 로딩 메시지가 Jua 폰트로 렌더링됨
- [ ] 하드 그림자 (12px 12px 0 #000) 보임
- [ ] 개발자 도구에서 `--font-black-han`, `--font-jua` 변수 확인됨

### Group 3 완료 후

- [ ] 앱 타이틀이 거대하고 흰색 배경 + 핑크 그림자로 렌더링됨
- [ ] 드래그앤드롭 영역이 원형 + 노란색 배경으로 렌더링됨
- [ ] 버튼이 거대하고 빨간색 배경 + 하드 그림자로 렌더링됨
- [ ] Hover 시 버튼이 노란색으로 변하고 회전함
- [ ] 로딩 메시지가 큰 텍스트 (text-4xl)로 보임
- [ ] 프로그레스 바가 그라디언트 + 퍼센트 표시됨
- [ ] 결과 제목이 거대한 말풍선 스타일로 렌더링됨
- [ ] 등급 배지가 원형 + 하드 그림자로 렌더링됨

### Group 4 완료 후 (선택적)

- [ ] 업로드 섹션 배경이 노란색 (#FFE847)임
- [ ] 로딩 섹션 배경이 핫핑크 (#FF69B4)임
- [ ] 결과 섹션 배경이 하늘색 (#87CEEB)임
- [ ] 푸터 배경이 다크 그린 (#2D5F3F)임
- [ ] 각 섹션이 풀와이드로 렌더링됨

---

## 최종 검증: E2E 테스트

```bash
cd /Users/lms/dev/repository/feature-talmosang-mvp/apps/web/talmosang
pnpm test:e2e
```

**확인 사항**:
- 기존 E2E 테스트가 통과하는지 (업로드, 분석, 결과)
- 스크린샷이 Al Murphy 스타일과 유사한지

---

## 참조 문서

- **사용자 스토리**: `docs/talmosang/talmosang-design/user-story.md`
- **디자인 명세**: `docs/talmosang/talmosang-design/web-design-spec.md`
- **기술 브리프**: `docs/talmosang/talmosang-design/web-brief.md`
- **Al Murphy 웹사이트**: https://www.al-murphy.com

---

## 예상 총 소요 시간

- Group 1: 10분
- Group 2: 25분
- Group 3: 65분
- Group 4 (선택적): 35분

**총 필수 작업**: 100분 (약 1시간 40분)
**선택적 작업 포함**: 135분 (약 2시간 15분)

---

## 주의사항

1. **순차 실행 필수**: 각 Group은 반드시 순서대로 진행해야 함 (의존성)
2. **Group 1 최우선**: CSS 빌드 수정 없이는 아무것도 보이지 않음
3. **검증 단계 필수**: 각 Group 완료 후 반드시 검증 체크리스트 확인
4. **Group 4는 선택적**: 기본 작업 완료 후 판단

---

**작성자**: CTO
**다음 담당자**: React Developer (react-developer 서브에이전트)
