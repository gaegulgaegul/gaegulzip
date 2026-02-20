# 기술 구현 브리프: 탈모상 디자인 재설계 (Al Murphy 스타일)

## 개요

탈모상 웹앱을 Al Murphy 웹사이트의 대담하고 맥시멀리스트 스타일로 전면 재설계합니다. 현재 **CSS가 전혀 렌더링되지 않는 Critical 이슈**를 최우선으로 해결하고, 이후 디자인 변경 작업을 진행합니다.

**핵심 목표**:
1. CSS 빌드 완전 실패 문제 즉시 해결
2. Tailwind v3 → v4 마이그레이션 완료
3. 폰트 변경 (Nanum Pen Script → Black Han Sans/Jua)
4. 색상 팔레트 변경 (크림 → 밝은 원색)
5. 레이아웃 변경 (좁은 컬럼 → 풀와이드 섹션)
6. UI 컴포넌트 재디자인 (손그림 → 대담한 하드 그림자)

---

## 🚨 Critical 이슈: CSS 빌드 완전 실패

### 현재 상황

**증상**:
- 브라우저에서 흰색 배경, 기본 폰트만 보임
- 네이티브 HTML 파일 인풋 노출 (Choose File 버튼)
- 카드, 테두리, 색상 등 모든 스타일 없음
- 컴파일된 CSS 파일 크기: **9바이트** (빈 파일)

**근본 원인**:
```json
// package.json
"tailwindcss": "^4.0.0"  // v4 설치됨
```

```css
/* globals.css */
@import "tailwindcss";   // v4 문법 사용 중
```

```
❌ postcss.config.mjs 파일 없음
❌ @tailwindcss/postcss 플러그인 미설치
```

**Tailwind CSS v4는 PostCSS 플러그인 방식으로 변경**되었으며, `postcss.config.mjs`가 없으면 CSS가 컴파일되지 않습니다.

---

## 🔧 Group 1: CSS 빌드 수정 (최우선)

### Task 1-1: PostCSS 설정 추가

#### 1. @tailwindcss/postcss 설치

```bash
cd apps/web/talmosang
pnpm add -D @tailwindcss/postcss
```

#### 2. postcss.config.mjs 파일 생성

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

#### 3. 검증: dev 서버 재시작

```bash
pnpm dev
```

**확인 사항**:
- CSS가 정상적으로 컴파일되는지 (빌드 로그)
- 브라우저에서 크림 배경색 (`#FFF8F0`) 보이는지
- 카드 테두리, 버튼 스타일 렌더링되는지

**예상 결과**: 기존 스타일이 모두 복원됨

---

### Task 1-2: Tailwind v4 @theme 마이그레이션

**Tailwind v4 변경점**:
- `tailwind.config.ts`의 `theme.extend`를 CSS `@theme` 지시어로 이동
- CSS 변수 기반 테마 정의

#### 1. globals.css 수정

**파일**: `apps/web/talmosang/app/globals.css`

**Before (현재)**:
```css
@import "tailwindcss";

/* 전역 CSS 변수 */
:root {
  --color-charcoal: #2d2d2d;
  --color-cream: #fff8f0;
  /* ... */
}
```

**After (v4 형식)**:
```css
@import "tailwindcss";

/* Tailwind v4 테마 정의 */
@theme {
  /* 색상 팔레트 (Al Murphy 영감) */
  --color-bg-yellow: #ffe847;
  --color-bg-pink: #ff69b4;
  --color-bg-sky-blue: #87ceeb;
  --color-bg-dark-green: #2d5f3f;
  --color-black: #1a1a1a;
  --color-white: #ffffff;
  --color-accent-red: #ff4444;
  --color-accent-green: #00cc66;
  --color-accent-orange: #ff9800;

  /* 기존 색상 (호환성) */
  --color-charcoal: #2d2d2d;
  --color-cream: #fff8f0;
  --color-cream-light: #fffbf5;
  --color-cream-dark: #f5e6d3;
  --color-coral: #e85d4a;
  --color-deep-blue: #2b4c7e;
  --color-mustard: #f2a541;
  --color-forest-green: #4a7c59;

  /* 폰트 */
  --font-black-han: 'Black Han Sans', sans-serif;
  --font-jua: 'Jua', sans-serif;
  --font-pretendard: 'Pretendard Variable', 'Noto Sans KR', sans-serif;

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

  /* 그림자 (하드 그림자 - Al Murphy 스타일) */
  --shadow-1: 4px 4px 0 #000;
  --shadow-2: 6px 6px 0 #000;
  --shadow-3: 8px 8px 0 #000;
  --shadow-4: 12px 12px 0 #000;
  --shadow-5: 16px 16px 0 #000;
  --shadow-6: 20px 20px 0 #000;
}

/* 전역 스타일 */
body {
  background-color: var(--color-bg-yellow); /* Al Murphy: 노란색 배경 */
  color: var(--color-black);
  font-family: var(--font-pretendard);
}

/* 섹션 배경 (Al Murphy 스타일) */
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

/* 노이즈 텍스처 오버레이 */
.noise-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4'/%3E%3C/filter%3E%3Crect width='100' height='100' filter='url(%23noise)' opacity='0.05'/%3E%3C/svg%3E");
  opacity: 0.05;
  pointer-events: none;
  z-index: 9999;
}

/* 종이 텍스처 (Card) */
.paper-texture {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4'/%3E%3C/filter%3E%3Crect width='100' height='100' filter='url(%23noise)' opacity='0.05'/%3E%3C/svg%3E");
  background-blend-mode: multiply;
}

/* 연필 테두리 → 굵은 검정 테두리 (Al Murphy) */
.pencil-border {
  border: 8px solid var(--color-black);
  box-shadow: var(--shadow-4); /* 12px 12px 0 #000 */
}

/* 손그림 프로그레스 바 → 그라디언트 프로그레스 (Al Murphy) */
.hand-drawn-progress [role='progressbar'] {
  background: linear-gradient(90deg, var(--color-bg-yellow) 0%, var(--color-accent-red) 50%, var(--color-accent-green) 100%);
  border-radius: 20px;
  transition: width 0.5s ease;
}

/* 폴라로이드 프레임 → 하드 그림자 (Al Murphy) */
.polaroid-frame {
  background: white;
  padding: 24px;
  border: 6px solid var(--color-black);
  border-radius: 4px;
  box-shadow: var(--shadow-3); /* 8px 8px 0 #000 */
}

/* 도장 배지 → 원형 스티커 (Al Murphy) */
.stamp-badge {
  background: var(--color-accent-red);
  border: 6px solid var(--color-black);
  border-radius: 50%;
  box-shadow: var(--shadow-3);
  transform: rotate(-8deg);
}

/* 말풍선 → 하드 그림자 (Al Murphy) */
.speech-bubble {
  position: relative;
  background: white;
  border: 8px solid var(--color-black);
  border-radius: 48px;
  padding: 48px;
  box-shadow: var(--shadow-4);
  transform: rotate(1deg);
}

.speech-bubble::after {
  content: '';
  position: absolute;
  bottom: -20px;
  left: 30px;
  width: 0;
  height: 0;
  border-left: 15px solid transparent;
  border-right: 15px solid transparent;
  border-top: 20px solid white;
}

/* 손그림 밑줄 → 굵은 밑줄 (Al Murphy) */
.scribble-underline {
  position: relative;
  display: inline-block;
  width: 100%;
  height: 12px;
  margin-top: 8px;
}

.scribble-underline::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 8px;
  background: var(--color-accent-red);
  clip-path: polygon(
    0% 50%, 5% 40%, 10% 60%, 15% 45%, 20% 55%, 25% 50%,
    30% 40%, 35% 60%, 40% 45%, 45% 55%, 50% 50%, 55% 40%,
    60% 60%, 65% 45%, 70% 55%, 75% 50%, 80% 40%, 85% 60%,
    90% 45%, 95% 55%, 100% 50%
  );
}

/* 손그림 별 → 거대한 별 (Al Murphy) */
.scribble-star {
  display: inline-block;
  width: 80px;
  height: 80px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Cpath d='M16 2 L20 12 L30 16 L20 20 L16 30 L12 20 L2 16 L12 12 Z' fill='%23ffe847' stroke='%23000' stroke-width='3' stroke-linejoin='round'/%3E%3C/svg%3E");
  transform: rotate(-10deg);
}

/* 손그림 화살표 → 굵은 화살표 (Al Murphy) */
.scribble-arrow {
  display: inline-block;
  width: 150px;
  height: 75px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 150 75'%3E%3Cpath d='M10 35 Q40 30 80 38 T130 40 M120 30 L130 40 L120 50' fill='none' stroke='%23000' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  transform: rotate(15deg);
}

/* 버튼 스타일 (Al Murphy: 하드 그림자 + 회전) */
.btn-primary {
  background-color: var(--color-accent-red);
  color: white;
  border: 6px solid var(--color-black);
  border-radius: 60px;
  padding: 32px 80px;
  font-size: 30px;
  font-weight: 900;
  box-shadow: var(--shadow-3);
  transition: all 0.3s ease;
}

.btn-primary:hover {
  background-color: var(--color-bg-yellow);
  color: var(--color-black);
  transform: rotate(-3deg) scale(1.1);
  box-shadow: var(--shadow-4);
  animation: shake 0.5s;
}

.btn-primary:active {
  transform: rotate(0deg) scale(0.95);
  box-shadow: var(--shadow-1);
}

.btn-ghost:hover {
  background-color: white;
  transform: rotate(2deg);
  animation: wiggle 0.5s;
}

/* 머리카락 떨어지는 애니메이션 (크기 증가) */
.hair-falling-container {
  position: relative;
  width: 100%;
  height: 200px;
  overflow: hidden;
}

.hair-strand {
  position: absolute;
  width: 8px; /* 2px → 8px */
  height: 60px; /* 20px → 60px */
  background: var(--color-black);
  animation: fall 5s infinite ease-in; /* 3s → 5s */
}

.hair-strand:nth-child(1) { left: 10%; animation-delay: 0s; }
.hair-strand:nth-child(2) { left: 25%; animation-delay: 1s; }
.hair-strand:nth-child(3) { left: 40%; animation-delay: 2s; }
.hair-strand:nth-child(4) { left: 55%; animation-delay: 3s; }
.hair-strand:nth-child(5) { left: 70%; animation-delay: 4s; }
.hair-strand:nth-child(6) { left: 85%; animation-delay: 0.5s; }

/* 드래그앤드롭 영역 (Al Murphy: 원형 + 하드 그림자) */
.drag-drop-zone {
  width: 400px;
  height: 400px;
  background: var(--color-bg-yellow);
  border: 8px dashed var(--color-black);
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  transform: rotate(-2deg);
  cursor: pointer;
  transition: all 0.3s ease;
  margin: 0 auto;
}

.drag-drop-zone:hover {
  background: var(--color-bg-pink);
  border-style: solid;
  transform: rotate(2deg) scale(1.05);
}

.drag-drop-zone.dragging {
  background: var(--color-accent-green);
  border-style: solid;
  transform: rotate(0deg) scale(1.1);
}

@media (max-width: 640px) {
  .drag-drop-zone {
    width: 300px;
    height: 300px;
  }
}

/* 에러 메시지 (Al Murphy: 하드 그림자) */
.error-message {
  background-color: var(--color-accent-red);
  color: white;
  border: 6px solid var(--color-black);
  border-radius: 24px;
  padding: 32px;
  box-shadow: var(--shadow-3);
}

/* 안심 문구 (Al Murphy: 스티커 스타일) */
.reassurance-text {
  display: flex;
  align-items: center;
  gap: 12px;
  background-color: var(--color-accent-green);
  color: white;
  border: 4px solid var(--color-black);
  border-radius: 24px;
  padding: 16px 32px;
  box-shadow: var(--shadow-2);
  transform: rotate(-2deg);
  margin-top: 24px;
}

/* 광고 컨테이너 (Al Murphy: 하드 그림자) */
.ad-container {
  margin: 32px 0;
  text-align: center;
  background: white;
  border: 4px solid var(--color-black);
  border-radius: 16px;
  padding: 24px;
  box-shadow: var(--shadow-2);
}

.ad-label {
  font-size: 12px;
  color: var(--color-black);
  font-weight: 700;
  margin-bottom: 8px;
}

/* 애니메이션 keyframes */
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

@keyframes fall {
  from {
    top: -60px;
    opacity: 1;
  }
  to {
    top: 100%;
    opacity: 0;
  }
}

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

.animate-fade-in {
  animation: fade-in 0.3s ease-in-out;
}

.animate-fade-scale {
  animation: fade-scale 0.5s ease-out;
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

#### 2. tailwind.config.ts 삭제 또는 최소화

**Tailwind v4에서는 `@theme`으로 모든 설정을 CSS로 이동하므로, `tailwind.config.ts`는 선택 사항입니다.**

**Option A: 파일 삭제 (권장)**
```bash
rm apps/web/talmosang/tailwind.config.ts
```

**Option B: 최소 설정만 유지**
```typescript
// apps/web/talmosang/tailwind.config.ts
import type { Config } from 'tailwindcss';

export default {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
} satisfies Config;
```

#### 3. 검증: CSS 빌드 확인

```bash
pnpm dev
```

**확인 사항**:
- 브라우저에서 배경색이 밝은 노란색 (`#FFE847`)으로 변경되는지
- 하드 그림자가 렌더링되는지
- 폰트가 적용되는지 (다음 Task에서 설정)

---

## 🎨 Group 2: 폰트 변경

### Task 2-1: Google Fonts 추가 (Black Han Sans, Jua)

**파일**: `apps/web/talmosang/lib/fonts.ts`

**Before (현재)**:
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

**After (Al Murphy 스타일)**:
```typescript
import { Black_Han_Sans, Jua, Noto_Sans_KR } from 'next/font/google';

/**
 * Black Han Sans (굵은 타이틀 폰트)
 *
 * 용도: 앱 타이틀, 섹션 제목
 * Al Murphy 스타일: 굵고 대담한 손글씨
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
 *
 * 용도: 로딩 메시지, 결과 제목
 * Al Murphy 스타일: 귀여운 손글씨
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
 *
 * 용도: 일반 텍스트, 버튼, 라벨
 */
export const notoSansKr = Noto_Sans_KR({
  weight: ['400', '500', '700', '900'], // ExtraBold 추가
  subsets: ['latin'],
  variable: '--font-pretendard',
  display: 'swap',
});
```

### Task 2-2: layout.tsx 폰트 적용

**파일**: `apps/web/talmosang/app/layout.tsx`

**Before (현재)**:
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

### Task 2-3: 검증: 폰트 렌더링 확인

```bash
pnpm dev
```

**확인 사항**:
- 개발자 도구 → Elements → `<html>` 태그에 `--font-black-han`, `--font-jua`, `--font-pretendard` 변수 존재
- 앱 타이틀 "탈모상"이 Black Han Sans로 렌더링되는지

---

## 🎨 Group 3: 컴포넌트 수정

### Task 3-1: 앱 타이틀 재디자인

**파일**: `apps/web/talmosang/app/page.tsx`

**Before (현재)**:
```tsx
<h1
  className="text-4xl md:text-5xl text-charcoal rotate-[-2deg]"
  style={{ fontFamily: 'var(--font-nanum-pen)' }}
>
  탈모상
</h1>
<div className="scribble-underline mx-auto max-w-[120px]" />
```

**After (Al Murphy 스타일)**:
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
- 크기: `text-4xl` → `text-7xl` (모바일), `text-5xl` → `text-9xl` (데스크톱)
- 배경: 흰색 타원형 배경 추가
- 테두리: 6px solid black
- 그림자: 핫핑크 그림자 (`4px 4px 0 #FF69B4`)
- 회전: -2deg → -3deg (더 크게)
- 애니메이션: bounce 효과 추가

### Task 3-2: UploadSection 재디자인

**파일**: `apps/web/talmosang/components/UploadSection.tsx`

**주요 변경 사항**:

#### 1. 메인 카피 텍스트 크기 증가

**Before**:
```tsx
<p className="text-2xl md:text-3xl font-bold mb-2">
```

**After**:
```tsx
<p className="text-3xl md:text-4xl font-extrabold mb-4">
```

#### 2. 드래그앤드롭 영역 재디자인

**Before**:
```tsx
<div className="drag-drop-zone">
  <div className="border-3 border-dashed border-coral rounded-full p-6">
    <CloudUpload className="w-16 h-16 text-coral" />
  </div>
</div>
```

**After**:
```tsx
<div className="drag-drop-zone">
  <CloudUpload className="w-32 h-32 text-black" /> {/* 아이콘 크기 증가 */}
  <p className="text-2xl font-bold text-black mt-4">
    사진을 드래그하거나 클릭하여 업로드
  </p>
</div>
```

**CSS 수정 (이미 globals.css에 반영됨)**:
```css
.drag-drop-zone {
  width: 400px;
  height: 400px;
  background: var(--color-bg-yellow);
  border: 8px dashed var(--color-black);
  border-radius: 50%;
  /* ... */
}
```

#### 3. 폴라로이드 프레임 재디자인

**Before**:
```tsx
<div className="polaroid-frame rotate-[1.5deg] mb-6">
```

**After**:
```tsx
<div className="polaroid-frame rotate-[2deg] mb-6">
  {/* 스티커 장식 추가 */}
  <div className="scribble-star absolute top-4 right-4" />
</div>
```

#### 4. 버튼 재디자인

**Before**:
```tsx
<Button variant="primary" onClick={onAnalyze} className="btn-primary">
  관상 보기
</Button>
```

**After**:
```tsx
<Button
  variant="primary"
  onClick={onAnalyze}
  className="btn-primary text-3xl px-20 py-8"
>
  관상 보기
</Button>
```

### Task 3-3: LoadingSection 재디자인

**파일**: `apps/web/talmosang/components/LoadingSection.tsx`

**주요 변경 사항**:

#### 1. 로딩 메시지 폰트 변경

**Before**:
```tsx
<p className="font-nanum-pen text-3xl text-charcoal mb-8 animate-fade-in">
```

**After**:
```tsx
<p
  className="text-4xl md:text-5xl text-black mb-8 animate-fade-in"
  style={{ fontFamily: 'var(--font-jua)' }}
>
```

#### 2. 로딩 애니메이션 크기 증가

**Before**:
```tsx
<Search className="w-20 h-20 text-mustard mx-auto animate-spin-slow" />
```

**After**:
```tsx
<div className="w-[200px] h-[200px] mx-auto bg-white border-[6px] border-black rounded-full flex items-center justify-center shadow-[8px_8px_0_#000]">
  <Search className="w-24 h-24 text-black animate-rotate" />
</div>
```

#### 3. 프로그레스 바 재디자인

**Before**:
```tsx
<Progress value={progress} className="hand-drawn-progress max-w-md mx-auto" />
```

**After**:
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

### Task 3-4: ResultSection 재디자인

**파일**: `apps/web/talmosang/components/ResultSection.tsx`

**주요 변경 사항**:

#### 1. 결과 제목 재디자인

**Before**:
```tsx
<h2 className="font-nanum-pen text-4xl text-center mb-8 animate-fade-scale">
```

**After**:
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

#### 2. 결과 카드 재디자인

**Before**:
```tsx
<Card className="paper-texture pencil-border p-8 mb-8 rotate-[-0.5deg]">
```

**After**:
```tsx
<div className="bg-white border-[8px] border-black rounded-[32px] p-12 mb-8 shadow-[12px_12px_0_#000] rotate-[-0.5deg]">
```

#### 3. 등급 배지 재디자인

**Before**:
```tsx
<Badge variant="stamp" className="stamp-badge text-2xl px-6 py-3">
  {result.gradeEmoji} {result.grade}
</Badge>
```

**After**:
```tsx
<div className="w-[300px] h-[300px] mx-auto bg-[var(--color-accent-green)] border-[10px] border-black rounded-full shadow-[12px_12px_0_#000] rotate-[-8deg] flex flex-col items-center justify-center">
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

<div
  className="w-[300px] h-[300px] ..."
  style={{ backgroundColor: gradeColor }}
>
```

#### 4. 버튼 재디자인

**Before**:
```tsx
<Button variant="secondary" onClick={onReset}>
  다시 관상 보기
</Button>
<Button variant="primary" onClick={handleShare} className="btn-primary">
  <Share className="w-4 h-4 mr-2" />
  공유하기
</Button>
```

**After**:
```tsx
<Button
  variant="secondary"
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
  <Share className="w-6 h-6 mr-3" />
  공유하기
</Button>
```

---

## 🎨 Group 4: 레이아웃 변경 (선택적)

### Task 4-1: 풀와이드 섹션 적용 (Advanced)

**현재 레이아웃**: 단일 컬럼 (`max-w-lg`)

**Al Murphy 레이아웃**: 풀와이드 섹션, 섹션별 배경색

**파일**: `apps/web/talmosang/app/page.tsx`

**Before**:
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

## 📋 새로 추가할 파일

### 1. SVG 캐릭터 컴포넌트 (선택적)

**파일**: `apps/web/talmosang/components/CharacterIllustration.tsx`

```tsx
interface CharacterProps {
  type: 'fortune-teller' | 'hair-monster';
  className?: string;
}

export default function CharacterIllustration({ type, className = '' }: CharacterProps) {
  if (type === 'fortune-teller') {
    return (
      <svg
        viewBox="0 0 200 200"
        xmlns="http://www.w3.org/2000/svg"
        className={`w-[200px] h-[200px] ${className}`}
      >
        {/* 관상가 할아버지 SVG 경로 */}
        <circle cx="100" cy="80" r="40" fill="white" stroke="black" strokeWidth="4"/>
        <path d="M70 100 Q100 120 130 100" fill="none" stroke="black" strokeWidth="4"/>
        <rect x="60" y="120" width="80" height="70" fill="#FF69B4" stroke="black" strokeWidth="4" rx="10"/>
        <circle cx="140" cy="150" r="20" fill="none" stroke="black" strokeWidth="4"/>
        <line x1="155" y1="165" x2="170" y2="180" stroke="black" strokeWidth="4"/>
      </svg>
    );
  }

  // hair-monster
  return (
    <svg
      viewBox="0 0 150 150"
      xmlns="http://www.w3.org/2000/svg"
      className={`w-[150px] h-[150px] ${className}`}
    >
      {/* 머리카락 캐릭터 SVG 경로 */}
      <circle cx="75" cy="75" r="60" fill="black" stroke="black" strokeWidth="4"/>
      <circle cx="60" cy="70" r="10" fill="white" stroke="black" strokeWidth="2"/>
      <circle cx="90" cy="70" r="10" fill="white" stroke="black" strokeWidth="2"/>
      <path d="M50 90 Q75 100 100 90" fill="none" stroke="#FF4444" strokeWidth="3"/>
    </svg>
  );
}
```

**사용 예시**:
```tsx
// UploadSection.tsx
import CharacterIllustration from './CharacterIllustration';

<div className="absolute top-8 left-8">
  <CharacterIllustration type="fortune-teller" />
</div>
```

---

## 📦 의존성 변경

### 설치

```bash
cd apps/web/talmosang
pnpm add -D @tailwindcss/postcss
```

### 삭제 (없음)

기존 패키지는 모두 유지합니다.

---

## 🚀 실행 순서

### Group 1: CSS 빌드 수정 (필수)

**순서**:
1. `pnpm add -D @tailwindcss/postcss`
2. `postcss.config.mjs` 생성
3. `pnpm dev` 실행
4. 브라우저 확인: 기존 스타일 복원되는지

**예상 소요 시간**: 5분

**검증 방법**:
- 브라우저에서 크림 배경색 보이는지
- 카드 테두리, 버튼 스타일 렌더링되는지

---

### Group 2: Tailwind v4 마이그레이션 + 폰트 변경

**순서**:
1. `globals.css` 수정 (위 Task 1-2 내용 복사)
2. `lib/fonts.ts` 수정 (위 Task 2-1 내용 복사)
3. `app/layout.tsx` 수정 (위 Task 2-2 내용 복사)
4. `pnpm dev` 재시작
5. 브라우저 확인: 노란색 배경 + Black Han Sans 폰트

**예상 소요 시간**: 10분

**검증 방법**:
- 배경색이 밝은 노란색 (`#FFE847`)으로 변경되는지
- 타이틀 폰트가 Black Han Sans로 렌더링되는지
- 하드 그림자가 보이는지

---

### Group 3: 컴포넌트 수정

**순서**:
1. `app/page.tsx` 수정 (Task 3-1: 앱 타이틀)
2. `components/UploadSection.tsx` 수정 (Task 3-2)
3. `components/LoadingSection.tsx` 수정 (Task 3-3)
4. `components/ResultSection.tsx` 수정 (Task 3-4)
5. 각 파일 수정 후 브라우저에서 Hot Reload 확인

**예상 소요 시간**: 30분

**검증 방법**:
- 각 섹션별 스타일이 Al Murphy 디자인과 유사한지
- 버튼, 카드, 배지의 하드 그림자 렌더링되는지
- 애니메이션이 정상 동작하는지

---

### Group 4: 레이아웃 변경 (선택적)

**순서**:
1. `app/page.tsx` 레이아웃 재구성 (Task 4-1)
2. 각 섹션별 배경색 확인
3. 반응형 레이아웃 테스트 (모바일, 태블릿, 데스크톱)

**예상 소요 시간**: 20분

**검증 방법**:
- 섹션별 배경색이 올바르게 적용되는지
- 풀와이드 레이아웃이 모든 화면 크기에서 동작하는지

---

## ✅ 검증 방법

### 각 단계별 확인 사항

#### Group 1 (CSS 빌드 수정) 완료 후

```bash
pnpm dev
```

**체크리스트**:
- [ ] 개발 서버가 정상 실행되는지
- [ ] 브라우저에서 크림 배경색 (`#FFF8F0`) 보이는지
- [ ] 카드 테두리가 렌더링되는지
- [ ] 버튼 스타일이 적용되는지
- [ ] 콘솔에 CSS 에러가 없는지

#### Group 2 (마이그레이션 + 폰트) 완료 후

**체크리스트**:
- [ ] 배경색이 밝은 노란색 (`#FFE847`)으로 변경되는지
- [ ] 타이틀 "탈모상"이 Black Han Sans로 렌더링되는지
- [ ] 로딩 메시지가 Jua 폰트로 렌더링되는지
- [ ] 하드 그림자가 보이는지 (카드, 버튼)
- [ ] 개발자 도구 → Computed → `font-family` 확인

#### Group 3 (컴포넌트 수정) 완료 후

**체크리스트**:
- [ ] 앱 타이틀이 거대하고 흰색 배경 + 핑크 그림자로 렌더링되는지
- [ ] 드래그앤드롭 영역이 원형 + 노란색 배경으로 렌더링되는지
- [ ] 버튼이 거대하고 빨간색 배경 + 하드 그림자로 렌더링되는지
- [ ] Hover 시 버튼이 노란색으로 변하고 회전하는지
- [ ] 로딩 메시지가 큰 텍스트로 보이는지
- [ ] 프로그레스 바가 그라디언트 + 퍼센트 표시되는지
- [ ] 결과 제목이 거대한 말풍선 스타일로 렌더링되는지
- [ ] 등급 배지가 원형 + 하드 그림자로 렌더링되는지

#### Group 4 (레이아웃 변경) 완료 후

**체크리스트**:
- [ ] 업로드 섹션 배경이 노란색인지
- [ ] 로딩 섹션 배경이 핫핑크인지
- [ ] 결과 섹션 배경이 하늘색인지
- [ ] 푸터 배경이 다크 그린인지
- [ ] 각 섹션이 풀와이드로 렌더링되는지

### 최종 검증: Playwright E2E 테스트

```bash
pnpm test:e2e
```

**확인 사항**:
- 기존 E2E 테스트가 통과하는지 (업로드, 분석, 결과)
- 스크린샷이 Al Murphy 스타일과 유사한지

---

## 🎯 예상 결과

### Before (현재)

- CSS 빌드 실패 → 흰색 배경, 기본 폰트
- 네이티브 HTML 인풋만 보임
- 스타일 전무

### After (Group 1 완료)

- CSS 정상 컴파일 → 크림 배경, 카드 테두리, 버튼 스타일
- 기존 디자인 복원

### After (Group 2 완료)

- 밝은 노란색 배경 (`#FFE847`)
- Black Han Sans 타이틀 폰트
- Jua 손글씨 폰트 (로딩 메시지)
- 하드 그림자 (12px 12px 0 #000)

### After (Group 3 완료)

- 거대한 타이틀 (text-9xl)
- 원형 드래그앤드롭 영역
- 거대한 버튼 (text-3xl, px-20 py-8)
- 그라디언트 프로그레스 바
- 원형 등급 배지 (300x300px)
- Al Murphy 스타일 완성

### After (Group 4 완료, 선택적)

- 풀와이드 섹션별 배경색
- 노란색 → 핑크 → 하늘색 전환
- 다크 그린 푸터
- 완전한 Al Murphy 레이아웃

---

## 📝 주의사항

### 1. tailwind.config.ts 삭제 시

`tailwind.config.ts`를 삭제하면 Next.js가 경고를 출력할 수 있지만, Tailwind v4에서는 정상 동작합니다. 경고를 제거하려면 빈 설정 파일을 유지하세요.

### 2. 폰트 로딩 시간

Black Han Sans, Jua 폰트는 Google Fonts에서 로딩되므로, 초기 로딩 시 약간의 지연이 있을 수 있습니다. `preload: true` 옵션으로 최적화되어 있습니다.

### 3. 하드 그림자 성능

CSS `box-shadow`를 많이 사용하면 성능에 영향을 줄 수 있지만, 이 정도 수준에서는 문제되지 않습니다. 필요 시 `will-change: transform`을 추가하여 GPU 가속을 활성화할 수 있습니다.

### 4. 반응형 레이아웃

모바일에서는 거대한 요소들이 화면을 벗어날 수 있으므로, 미디어 쿼리로 크기를 조정해야 합니다. 대부분의 클래스는 이미 반응형 (`md:`, `lg:`)으로 설정되어 있습니다.

### 5. 기존 컴포넌트 호환성

shadcn/ui 컴포넌트 (`Card`, `Button`, `Progress`)는 기존 그대로 유지하고, CSS 클래스로 스타일을 덮어씌웁니다. 컴포넌트 파일 자체는 수정하지 않습니다.

---

## 🔗 참고 자료

### Tailwind CSS v4

- [Tailwind CSS v4 공식 문서](https://tailwindcss.com/blog/tailwindcss-v4-alpha)
- [Tailwind CSS v4 PostCSS 플러그인](https://github.com/tailwindlabs/tailwindcss/tree/v4)
- [@theme 지시어 사용법](https://tailwindcss.com/docs/theme)

### 폰트

- [Black Han Sans - Google Fonts](https://fonts.google.com/specimen/Black+Han+Sans)
- [Jua - Google Fonts](https://fonts.google.com/specimen/Jua)
- [Next.js 폰트 최적화](https://nextjs.org/docs/app/building-your-application/optimizing/fonts)

### 디자인 영감

- [Al Murphy 웹사이트](https://www.al-murphy.com)
- [Kittl 2026 디자인 트렌드](https://www.kittl.com/blogs/graphic-design-trends-2026/)

---

## 📊 작업 체크리스트

### Group 1: CSS 빌드 수정 (필수)

- [ ] `pnpm add -D @tailwindcss/postcss` 실행
- [ ] `postcss.config.mjs` 파일 생성
- [ ] `pnpm dev` 재시작
- [ ] 브라우저에서 기존 스타일 복원 확인

### Group 2: Tailwind v4 마이그레이션 + 폰트

- [ ] `globals.css`에 `@theme` 블록 추가
- [ ] `tailwind.config.ts` 삭제 또는 최소화
- [ ] `lib/fonts.ts` 수정 (Black Han Sans, Jua 추가)
- [ ] `app/layout.tsx` 폰트 변수 적용
- [ ] 브라우저에서 노란색 배경 + 새 폰트 확인

### Group 3: 컴포넌트 수정

- [ ] `app/page.tsx` 앱 타이틀 재디자인
- [ ] `components/UploadSection.tsx` 수정
- [ ] `components/LoadingSection.tsx` 수정
- [ ] `components/ResultSection.tsx` 수정
- [ ] 각 컴포넌트별 스타일 확인

### Group 4: 레이아웃 변경 (선택적)

- [ ] `app/page.tsx` 풀와이드 섹션 적용
- [ ] 섹션별 배경색 확인
- [ ] 반응형 레이아웃 테스트

### 최종 검증

- [ ] `pnpm test:e2e` 실행
- [ ] Playwright 스크린샷과 Al Murphy 비교
- [ ] 모든 기능 정상 동작 확인

---

## 🎉 완료 후

모든 작업이 완료되면 다음을 수행하세요:

1. **Git Commit**:
```bash
git add .
git commit -m "feat(talmosang): Al Murphy 스타일 디자인 적용 - CSS 빌드 수정, Tailwind v4 마이그레이션, 폰트/색상/레이아웃 변경"
```

2. **Vercel 배포**:
```bash
git push origin feature/talmosang-mvp
```

3. **스크린샷 캡처**:
```bash
pnpm test:e2e
```

4. **Al Murphy 웹사이트와 비교**:
- 색상 채도, 타이포그래피, 레이아웃 폭, 일러스트 비중 비교
- 추가 개선 사항 도출

---

## 🚀 다음 단계 (향후 개선 사항)

1. **SVG 캐릭터 일러스트 추가**
   - 관상가 할아버지, 머리카락 캐릭터
   - 스티커, 배지, 낙서 요소

2. **섹션별 배경 일러스트**
   - 구름 패턴, 별 패턴
   - 배경 장식 요소

3. **인터랙션 애니메이션 강화**
   - 버튼 Hover 시 회전 효과 증폭
   - 카드 Hover 시 그림자 증가

4. **결과 카드 그리드 레이아웃**
   - 데스크톱에서 2열 그리드
   - 각 카드를 독립된 섹션으로 분리

5. **Accessibility 개선**
   - 색상 대비 검증
   - 키보드 내비게이션 최적화

---

**문서 버전**: 1.0
**작성일**: 2026-02-14
**작성자**: Tech Lead
**다음 담당자**: Web Developer
