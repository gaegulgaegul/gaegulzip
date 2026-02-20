# 기술 아키텍처 설계: SEO 최적화 (탈모상)

## 개요

Next.js 15 App Router의 내장 SEO 기능(Metadata API, robots.ts, sitemap.ts)을 활용하여 검색엔진 색인 최적화, 소셜 공유 미리보기 강화, 구조화 데이터 삽입을 구현한다. 비주얼 UI 변경 없이 순수 기술 설정만으로 완료 가능하다.

---

## 현재 상태 분석

### 현재 layout.tsx 메타데이터

```typescript
// 현재 (apps/web/talmosang/app/layout.tsx)
export const metadata: Metadata = {
  metadataBase: new URL('https://gaegulzip-talmosang.vercel.app'),
  title: '탈모상 - 내가 탈모가 될 상인가?',
  description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
  keywords: ['탈모', 'AI 관상', '두피 분석', '헤어라인', '바이럴 게임'],
  openGraph: {
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
    type: 'website',
    images: ['/og-image.png'],
  },
  twitter: {
    card: 'summary_large_image',
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description: 'AI 관상가가 그대의 모발 운명을 점지하리라',
    images: ['/og-image.png'],
  },
};
```

### 현재 미비 사항

| 항목 | 현재 상태 | 목표 상태 |
|------|-----------|-----------|
| robots.txt | 없음 | `/api/*` 차단, 정적 페이지 허용 |
| sitemap.xml | 없음 | `/`, `/privacy` 포함 |
| JSON-LD 구조화 데이터 | 없음 | WebApplication 타입 삽입 |
| canonical URL | 없음 | 각 페이지에 명시 |
| og:locale | 없음 | `ko_KR` 설정 |
| og:image 크기 명시 | 없음 | width/height 명시 |
| description | 짧은 문구 | 클릭 욕구 자극 문구로 보강 |
| privacy 메타데이터 | title/description만 있음 | canonical, OG 추가 |

### OG 이미지 현황

`public/og-image.png` 파일이 존재함. `metadataBase`가 설정되어 있으므로 Next.js가 상대 경로 `/og-image.png`를 절대 URL `https://gaegulzip-talmosang.vercel.app/og-image.png`로 자동 변환함. 별도 작업 불필요.

---

## 1. robots.ts 설계

**파일**: `apps/web/talmosang/app/robots.ts`

Next.js App Router의 `MetadataRoute.Robots` 타입을 사용하여 `/robots.txt` 응답을 생성한다.

```typescript
import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: '/api/',
      },
    ],
    sitemap: 'https://gaegulzip-talmosang.vercel.app/sitemap.xml',
  };
}
```

**생성되는 /robots.txt 출력 예시**:
```
User-agent: *
Allow: /
Disallow: /api/

Sitemap: https://gaegulzip-talmosang.vercel.app/sitemap.xml
```

**설계 근거**:
- `allow: '/'`로 전체 허용 후 `disallow: '/api/'`로 API 라우트만 차단
- `sitemap` 필드로 크롤러에게 사이트맵 위치를 명시
- `userAgent: '*'`는 모든 크롤러에 적용

---

## 2. sitemap.ts 설계

**파일**: `apps/web/talmosang/app/sitemap.ts`

Next.js App Router의 `MetadataRoute.Sitemap` 타입을 사용하여 `/sitemap.xml` 응답을 생성한다.

```typescript
import type { MetadataRoute } from 'next';

const BASE_URL = 'https://gaegulzip-talmosang.vercel.app';

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: BASE_URL,
      lastModified: new Date('2026-02-20'),
      changeFrequency: 'monthly',
      priority: 1.0,
    },
    {
      url: `${BASE_URL}/privacy`,
      lastModified: new Date('2026-02-20'),
      changeFrequency: 'yearly',
      priority: 0.3,
    },
  ];
}
```

**생성되는 /sitemap.xml 출력 예시**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://gaegulzip-talmosang.vercel.app/</loc>
    <lastmod>2026-02-20</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://gaegulzip-talmosang.vercel.app/privacy</loc>
    <lastmod>2026-02-20</lastmod>
    <changefreq>yearly</changefreq>
    <priority>0.3</priority>
  </url>
</urlset>
```

**설계 근거**:
- 메인 페이지는 `priority: 1.0`, `changeFrequency: 'monthly'` (서비스 핵심 페이지)
- privacy 페이지는 `priority: 0.3`, `changeFrequency: 'yearly'` (법적 문서, 변경 빈도 낮음)
- 동적 분석 결과 페이지는 서버에 저장되지 않아 고유 URL 없음 — 포함하지 않음
- `lastModified`는 현재 날짜(2026-02-20)로 설정, 향후 실질적 변경 시 업데이트

---

## 3. JSON-LD 구조화 데이터 설계

**삽입 위치**: `apps/web/talmosang/app/layout.tsx`의 `<head>` 섹션

### JSON-LD 스키마 (WebApplication 타입)

```json
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "탈모상",
  "alternateName": "탈모상 - 내가 탈모가 될 상인가?",
  "url": "https://gaegulzip-talmosang.vercel.app",
  "description": "AI 관상가가 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 분석해드립니다. 재미로 즐기는 AI 두피 분석 서비스.",
  "applicationCategory": "EntertainmentApplication",
  "operatingSystem": "Web",
  "inLanguage": "ko-KR",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "KRW"
  }
}
```

### layout.tsx 삽입 코드

```typescript
// apps/web/talmosang/app/layout.tsx의 <head> 섹션에 추가

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebApplication',
  name: '탈모상',
  alternateName: '탈모상 - 내가 탈모가 될 상인가?',
  url: 'https://gaegulzip-talmosang.vercel.app',
  description:
    'AI 관상가가 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 분석해드립니다. 재미로 즐기는 AI 두피 분석 서비스.',
  applicationCategory: 'EntertainmentApplication',
  operatingSystem: 'Web',
  inLanguage: 'ko-KR',
  offers: {
    '@type': 'Offer',
    price: '0',
    priceCurrency: 'KRW',
  },
};

// layout.tsx의 <head> 내부에 삽입
<head>
  <script
    type="application/ld+json"
    dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
  />
  {/* 기존 Google AdSense 스크립트 */}
  {process.env.NEXT_PUBLIC_ADSENSE_ID && (
    <script
      async
      src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${process.env.NEXT_PUBLIC_ADSENSE_ID}`}
      crossOrigin="anonymous"
    />
  )}
</head>
```

**설계 근거**:
- `WebApplication` 타입은 웹앱/도구 서비스에 가장 적합한 schema.org 타입
- `applicationCategory: 'EntertainmentApplication'`으로 엔터테인먼트 앱 분류
- `offers.price: '0'`으로 무료 서비스임을 명시 (Google Rich Results에서 활용)
- `dangerouslySetInnerHTML` 사용은 Next.js에서 JSON-LD 삽입에 권장되는 방식
- `script` 태그는 렌더링에 영향을 주지 않음

---

## 4. layout.tsx 메타데이터 개선 설계

**파일**: `apps/web/talmosang/app/layout.tsx`

### 변경 전 vs 변경 후 비교

```typescript
// 변경 후 전체 메타데이터 (apps/web/talmosang/app/layout.tsx)
export const metadata: Metadata = {
  metadataBase: new URL('https://gaegulzip-talmosang.vercel.app'),

  title: '탈모상 - 내가 탈모가 될 상인가?',
  description:
    'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 알아보세요.',
  keywords: [
    '탈모',
    '탈모 테스트',
    'AI 두피 분석',
    '탈모 확률',
    'AI 관상',
    '두피 분석',
    '헤어라인',
    '탈모 진단',
    '바이럴 게임',
    '탈모 상',
  ],

  // canonical URL 추가
  alternates: {
    canonical: 'https://gaegulzip-talmosang.vercel.app',
  },

  openGraph: {
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description:
      'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 알아보세요.',
    type: 'website',
    url: 'https://gaegulzip-talmosang.vercel.app',
    locale: 'ko_KR',             // 추가: 한국어 서비스 명시
    siteName: '탈모상',           // 추가: 사이트명
    images: [
      {
        url: '/og-image.png',    // metadataBase와 결합 → 절대 URL 자동 변환
        width: 1200,             // 추가: 소셜 플랫폼 권장 크기 명시
        height: 630,             // 추가
        alt: '탈모상 - AI 두피 분석 서비스',  // 추가: 접근성
      },
    ],
  },

  twitter: {
    card: 'summary_large_image',
    title: '탈모상 - 내가 탈모가 될 상인가?',
    description:
      'AI 관상가가 그대의 모발 운명을 점지하리라. 사진 하나로 탈모 확률, 모발 나이, 닮은 유명인을 알아보세요.',
    images: ['/og-image.png'],
  },
};
```

**변경 사항 요약**:

| 필드 | 변경 내용 |
|------|-----------|
| `description` | 기존 짧은 문구 → 바이럴 유도 + 구체적 기능 설명 보강 |
| `keywords` | 5개 → 10개, 실제 검색어 기반으로 보강 |
| `alternates.canonical` | 신규 추가 (`https://gaegulzip-talmosang.vercel.app`) |
| `openGraph.url` | 신규 추가 |
| `openGraph.locale` | 신규 추가 (`ko_KR`) |
| `openGraph.siteName` | 신규 추가 (`탈모상`) |
| `openGraph.images[].width` | 신규 추가 (`1200`) |
| `openGraph.images[].height` | 신규 추가 (`630`) |
| `openGraph.images[].alt` | 신규 추가 |

---

## 5. privacy/page.tsx 메타데이터 보강 설계

**파일**: `apps/web/talmosang/app/privacy/page.tsx`

### 변경 전

```typescript
export const metadata: Metadata = {
  title: '개인정보처리방침 - 탈모상',
  description: '탈모상 서비스의 개인정보처리방침',
};
```

### 변경 후

```typescript
export const metadata: Metadata = {
  title: '개인정보처리방침 - 탈모상',
  description: '탈모상 서비스의 개인정보 보호 정책을 안내합니다. AI 두피 분석 서비스 탈모상의 데이터 처리 방침.',

  // 독립 canonical URL 추가
  alternates: {
    canonical: 'https://gaegulzip-talmosang.vercel.app/privacy',
  },

  // 소셜 공유 대응 OG 메타데이터 추가
  openGraph: {
    title: '개인정보처리방침 - 탈모상',
    description: '탈모상 서비스의 개인정보 보호 정책을 안내합니다.',
    type: 'website',
    url: 'https://gaegulzip-talmosang.vercel.app/privacy',
    locale: 'ko_KR',
  },
};
```

**설계 근거**:
- privacy 페이지는 `page.tsx`가 서버 컴포넌트이므로 `metadata` export가 정상 동작
- canonical URL을 `/privacy`로 명시하여 중복 색인 방지
- OG 이미지는 layout.tsx의 기본값을 상속하므로 별도 지정 불필요
- description을 보강하여 검색 결과에서 더 구체적인 정보 제공

---

## 메인 페이지 'use client' 제약 대응

**현재 상황**: `apps/web/talmosang/app/page.tsx`는 `'use client'` 선언으로 인해 `metadata` export가 불가능하다.

**대응 전략**: 모든 메인 페이지 메타데이터는 `layout.tsx`에서 관리한다. 이는 현재 구조와 동일하며 추가 변경이 필요 없다. Next.js App Router에서 `layout.tsx`의 메타데이터는 해당 레이아웃을 사용하는 모든 페이지에 적용되므로, 메인 페이지(/)의 메타데이터를 `layout.tsx`에서 설정하는 것은 올바른 접근이다.

---

## 파일 단위 구현 체크리스트

### 신규 생성 파일

- [ ] `apps/web/talmosang/app/robots.ts`
  - [ ] `userAgent: '*'` 규칙 정의
  - [ ] `allow: '/'` 설정
  - [ ] `disallow: '/api/'` 설정
  - [ ] `sitemap` URL 설정 (`https://gaegulzip-talmosang.vercel.app/sitemap.xml`)
  - [ ] `/robots.txt` 접근 시 정상 응답 확인

- [ ] `apps/web/talmosang/app/sitemap.ts`
  - [ ] 메인 페이지(`/`) 엔트리 추가 (priority: 1.0)
  - [ ] privacy 페이지(`/privacy`) 엔트리 추가 (priority: 0.3)
  - [ ] `lastModified`, `changeFrequency` 설정
  - [ ] `/sitemap.xml` 접근 시 정상 응답 확인

### 수정 파일

- [ ] `apps/web/talmosang/app/layout.tsx`
  - [ ] JSON-LD `jsonLd` 상수 정의
  - [ ] `<head>` 내 `<script type="application/ld+json">` 삽입
  - [ ] `metadata.description` 문구 보강
  - [ ] `metadata.keywords` 보강 (10개)
  - [ ] `metadata.alternates.canonical` 추가
  - [ ] `metadata.openGraph.url` 추가
  - [ ] `metadata.openGraph.locale` 추가 (`ko_KR`)
  - [ ] `metadata.openGraph.siteName` 추가
  - [ ] `metadata.openGraph.images` width/height/alt 추가

- [ ] `apps/web/talmosang/app/privacy/page.tsx`
  - [ ] `metadata.description` 보강
  - [ ] `metadata.alternates.canonical` 추가 (`/privacy`)
  - [ ] `metadata.openGraph` 추가

---

## 검증 방법

### 로컬 검증

```bash
# 개발 서버 실행
cd apps/web/talmosang
pnpm dev

# 확인 URL
# http://localhost:3000/robots.txt
# http://localhost:3000/sitemap.xml
```

### 배포 후 외부 도구 검증

| 도구 | 목적 | URL |
|------|------|-----|
| Google Rich Results Test | JSON-LD 구조화 데이터 유효성 | https://search.google.com/test/rich-results |
| Open Graph Debugger (Facebook) | OG 메타데이터 확인 | https://developers.facebook.com/tools/debug/ |
| Twitter Card Validator | Twitter Card 확인 | https://cards-dev.twitter.com/validator |
| Kakao Share Debugger | 카카오 링크 미리보기 캐시 초기화 | https://developers.kakao.com/tool/clear/og |

---

## 패키지 의존성

추가 패키지 설치 불필요. Next.js 15 내장 기능만 사용한다.

- `next` — `MetadataRoute.Robots`, `MetadataRoute.Sitemap`, `Metadata` 타입 모두 내장

---

## 에러 처리

- `robots.ts`, `sitemap.ts`는 Next.js가 빌드 타임에 정적으로 생성하므로 런타임 에러 없음
- JSON-LD는 `<script>` 태그 내 정적 JSON이므로 렌더링 실패 없음
- 모든 메타데이터는 빌드 타임 상수로 정의하여 런타임 의존성 없음

---

## 참고 자료

- Next.js Metadata API: https://nextjs.org/docs/app/api-reference/functions/generate-metadata
- Next.js robots.ts: https://nextjs.org/docs/app/api-reference/file-conventions/metadata/robots
- Next.js sitemap.ts: https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap
- schema.org WebApplication: https://schema.org/WebApplication
- Open Graph Protocol: https://ogp.me
