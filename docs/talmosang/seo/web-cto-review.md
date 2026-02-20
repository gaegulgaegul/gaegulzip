# CTO 통합 리뷰: SEO 최적화 (탈모상)

- **Feature**: seo
- **Platform**: web
- **Product**: talmosang
- **리뷰 일자**: 2026-02-20
- **리뷰어**: CTO

---

## 종합 판정

**승인 (Approved)**

4개 구현 파일 모두 설계 명세를 충실히 따랐으며, 빌드가 오류 없이 완료되었습니다. TypeScript 타입 안전성, Next.js App Router 패턴, SEO 표준, 보안 요건이 전부 충족되었습니다.

---

## 1. 빌드 성공 여부

```
✓ Compiled successfully in 2.8s
✓ Generating static pages (9/9)
```

| 라우트 | 타입 | 크기 |
|--------|------|------|
| `/` | Static | 13.2 kB |
| `/privacy` | Static | 163 B |
| `/robots.txt` | Static | 130 B |
| `/sitemap.xml` | Static | 130 B |
| `/api/analyze` | Dynamic | 130 B |
| `/api/generate-image` | Dynamic | 130 B |

`robots.txt`와 `sitemap.xml`이 정적으로 사전 렌더링되었습니다. 런타임 오버헤드가 없고 CDN 캐시 친화적입니다.

---

## 2. 코드 품질 — TypeScript 타입 안전성

### robots.ts

```typescript
import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots { ... }
```

- `MetadataRoute.Robots` 타입을 명시적으로 사용하여 반환값의 구조를 컴파일 타임에 검증합니다.
- `type`만 import하는 `import type` 패턴으로 런타임 번들 크기에 영향을 주지 않습니다.
- 판정: **적합**

### sitemap.ts

```typescript
import type { MetadataRoute } from 'next';

const BASE_URL = 'https://talmosang.vercel.app';

export default function sitemap(): MetadataRoute.Sitemap { ... }
```

- `MetadataRoute.Sitemap` 타입 사용으로 `changeFrequency` 열거형 값, `priority` 범위가 컴파일 타임에 검사됩니다.
- `BASE_URL` 상수를 분리하여 URL 중복을 제거했습니다.
- 판정: **적합**

### layout.tsx

```typescript
import type { Metadata } from 'next';
export const metadata: Metadata = { ... };
const jsonLd = { ... };
```

- `Metadata` 타입이 명시되어 모든 필드 구조가 검증됩니다.
- `jsonLd`는 별도 상수로 분리하여 JSX와 데이터가 혼재하지 않습니다.
- 판정: **적합**

### privacy/page.tsx

- `export const metadata: Metadata` 선언이 서버 컴포넌트에 올바르게 위치합니다.
- `'use client'` 선언이 없으므로 metadata export가 정상 작동합니다.
- 판정: **적합**

---

## 3. Next.js 패턴 준수

### App Router 파일 규칙

| 파일 | 규칙 | 준수 여부 |
|------|------|-----------|
| `app/robots.ts` | default export 함수, `MetadataRoute.Robots` 반환 | 준수 |
| `app/sitemap.ts` | default export 함수, `MetadataRoute.Sitemap` 반환 | 준수 |
| `app/layout.tsx` | `export const metadata`, Server Component | 준수 |
| `app/privacy/page.tsx` | `export const metadata`, Server Component | 준수 |

### Server/Client Component 경계

- `layout.tsx`: `'use client'` 없음, Server Component로 올바르게 유지되었습니다.
- `privacy/page.tsx`: `'use client'` 없음, `metadata` export가 가능합니다.
- `page.tsx` (메인): `'use client'` 선언이 유지되어 있으며, 메인 페이지 메타데이터를 `layout.tsx`에서 관리하는 설계 결정이 올바르게 적용되었습니다.

### `dangerouslySetInnerHTML` 사용 적정성

JSON-LD 삽입에 `dangerouslySetInnerHTML`을 사용하는 것은 Next.js 공식 문서에서 권장하는 방식입니다. `jsonLd` 객체는 외부 입력이 아닌 코드 내 하드코딩된 상수이므로 XSS 위험이 없습니다.

---

## 4. SEO 표준 준수

### robots.txt 형식

설계 명세와 구현이 일치합니다:

```
User-agent: *
Allow: /
Disallow: /api/
Sitemap: https://talmosang.vercel.app/sitemap.xml
```

- `allow: '/'` 전체 허용 후 `disallow: '/api/'` 부분 차단 순서가 올바릅니다.
- `sitemap` 필드로 크롤러에 사이트맵 위치를 명시했습니다.

### sitemap.xml 형식

| 엔트리 | priority | changeFrequency | lastModified |
|--------|----------|-----------------|--------------|
| `/` | 1.0 | monthly | 2026-02-20 |
| `/privacy` | 0.3 | yearly | 2026-02-20 |

- 우선순위 배분이 적절합니다 (메인 1.0 / 법적 문서 0.3).
- 동적 분석 결과 페이지는 서버에 저장되지 않아 고유 URL이 없으므로 제외가 올바른 판단입니다.

### JSON-LD 유효성 (schema.org WebApplication)

```json
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "탈모상",
  "alternateName": "탈모상 - 내가 탈모가 될 상인가?",
  "url": "https://talmosang.vercel.app",
  "applicationCategory": "EntertainmentApplication",
  "operatingSystem": "Web",
  "inLanguage": "ko-KR",
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "KRW" }
}
```

- 필수 속성 `@context`, `@type`, `name` 모두 포함되었습니다.
- `applicationCategory: "EntertainmentApplication"` 분류가 서비스 성격과 일치합니다.
- `offers.price: "0"`으로 무료 서비스 표기가 올바릅니다 (Google Rich Results 활용 가능).

### canonical URL

| 페이지 | canonical | 설정값 |
|--------|-----------|--------|
| `/` | `alternates.canonical` | `https://talmosang.vercel.app` |
| `/privacy` | `alternates.canonical` | `https://talmosang.vercel.app/privacy` |

중복 색인 방지를 위한 canonical이 각 페이지에 올바르게 설정되었습니다.

### OG / Twitter 메타데이터

| 필드 | 값 | 평가 |
|------|-----|------|
| `og:locale` | `ko_KR` | 한국어 서비스 명시 |
| `og:site_name` | `탈모상` | 소셜 공유 시 출처 표시 |
| `og:image` width/height | 1200 x 630 | 소셜 플랫폼 권장 크기 |
| `og:image alt` | `탈모상 - AI 두피 분석 서비스` | 접근성 준수 |
| `twitter:card` | `summary_large_image` | 대형 이미지 카드 표시 |

모든 소셜 메타데이터가 설계 명세에 따라 완성되었습니다.

---

## 5. 보안

### API 라우트 차단

`robots.ts`의 `disallow: '/api/'` 설정으로 검색엔진이 `/api/analyze`, `/api/generate-image`를 크롤링하지 않습니다. 빌드 결과에서 두 API 라우트가 `Dynamic` 타입으로 정상 작동함을 확인했습니다.

### XSS 위험

`dangerouslySetInnerHTML`에 삽입되는 `jsonLd` 객체는 코드 내 하드코딩된 상수이며, 사용자 입력 데이터를 포함하지 않습니다. `JSON.stringify(jsonLd)`는 특수 문자를 자동 이스케이프하므로 XSS 위험이 없습니다.

### CSP (Content-Security-Policy)

`next.config.ts`에 이미 적용된 CSP 설정이 JSON-LD `<script>` 태그를 허용합니다 (`script-src 'self' 'unsafe-inline'`). AdSense 스크립트와 충돌하지 않습니다.

---

## 6. 기존 코드와의 호환성

### AdSense 설정 유지

```tsx
{process.env.NEXT_PUBLIC_ADSENSE_ID && (
  <script
    async
    src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${process.env.NEXT_PUBLIC_ADSENSE_ID}`}
    crossOrigin="anonymous"
  />
)}
```

기존 AdSense 스크립트가 JSON-LD 삽입 이후에 위치하며, 조건부 렌더링 패턴이 그대로 유지되었습니다.

### 폰트 설정 유지

```tsx
<html lang="ko" className={`${blackHanSans.variable} ${jua.variable} ${notoSansKr.variable}`}>
```

`blackHanSans`, `jua`, `notoSansKr` 세 폰트 CSS 변수가 모두 유지되었습니다. `lib/fonts.ts`의 기존 폰트 정의에 변경이 없습니다.

### 기존 메타데이터 유지

기존 `title`, `description`, `keywords`, `openGraph`, `twitter`, `metadataBase` 설정이 모두 보존되었으며, 신규 필드(`alternates.canonical`, `og:locale`, `og:siteName`, `og:image` 크기/alt)가 추가되었습니다.

---

## 7. 설계 명세 체크리스트 검증

### robots.ts

- [x] `userAgent: '*'` 규칙 정의
- [x] `allow: '/'` 설정
- [x] `disallow: '/api/'` 설정
- [x] `sitemap` URL 설정

### sitemap.ts

- [x] 메인 페이지(`/`) 엔트리 — priority 1.0
- [x] privacy 페이지(`/privacy`) 엔트리 — priority 0.3
- [x] `lastModified`, `changeFrequency` 설정
- [x] `BASE_URL` 상수로 중복 제거

### layout.tsx

- [x] `jsonLd` 상수 정의
- [x] `<script type="application/ld+json">` 삽입
- [x] `metadata.description` 문구 보강
- [x] `metadata.keywords` 10개로 보강
- [x] `metadata.alternates.canonical` 추가
- [x] `metadata.openGraph.url` 추가
- [x] `metadata.openGraph.locale` 추가 (`ko_KR`)
- [x] `metadata.openGraph.siteName` 추가
- [x] `metadata.openGraph.images` width/height/alt 추가

### privacy/page.tsx

- [x] `metadata.description` 보강
- [x] `metadata.alternates.canonical` 추가
- [x] `metadata.openGraph` 추가 (title, description, type, url, locale)

---

## 8. 지적 사항

### 경미한 사항 (즉각 수정 불필요)

**sitemap.ts의 `lastModified` 하드코딩**

현재 `new Date('2026-02-20')`으로 하드코딩되어 있습니다. 기능적으로 문제는 없으나, 향후 콘텐츠 변경 시 수동으로 날짜를 업데이트해야 합니다. 현재 서비스 규모에서는 허용 가능한 수준이며, 설계 명세에도 동일하게 명시된 방식입니다.

**JSON-LD `description`과 `metadata.description` 문구 불일치**

`jsonLd.description`과 `metadata.description`이 의도적으로 다르게 작성되었습니다. `metadata.description`은 검색 결과 스니펫용(클릭 유도 문구), `jsonLd.description`은 schema.org 의미론적 설명용으로 목적이 다르므로 정상적인 설계입니다.

---

## 최종 점수

| 항목 | 점수 |
|------|------|
| 빌드 성공 | 10 / 10 |
| TypeScript 타입 안전성 | 10 / 10 |
| Next.js 패턴 준수 | 10 / 10 |
| SEO 표준 준수 | 10 / 10 |
| 보안 | 10 / 10 |
| 기존 코드 호환성 | 10 / 10 |
| 설계 명세 충족도 | 10 / 10 |
| **총점** | **70 / 70** |

**판정: 승인 (Approved)**

배포 준비 완료입니다. 배포 후 Google Rich Results Test와 Open Graph Debugger로 외부 검증을 수행하면 됩니다.
