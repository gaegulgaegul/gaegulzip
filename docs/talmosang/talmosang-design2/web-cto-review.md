# CTO 통합 리뷰: talmosang-design2

**검토일**: 2026-02-19
**Feature**: The Weirdos 스타일 랜딩 페이지 레이아웃
**플랫폼**: Web (Next.js App Router + Tailwind CSS v4)
**리뷰어**: CTO

---

## 종합 평가

| 항목 | 점수 | 상태 |
|------|------|------|
| 빌드 성공 여부 | 10/10 | PASS |
| TypeScript 타입 안전성 | 10/10 | PASS |
| ESLint 코드 품질 | 10/10 | PASS |
| Next.js App Router 패턴 | 8/10 | 주의사항 있음 |
| Design Spec 준수도 | 7/10 | 일부 편차 있음 |
| 반응형 레이아웃 | 9/10 | 양호 |
| 성능 | 6/10 | 개선 필요 |
| 기능 보존 | 10/10 | PASS |

**최종 점수: 75/80 — 조건부 승인 (성능 이슈 추적 필요)**

---

## 1. 빌드 성공 여부

### 결과: PASS

```
Route (app)                    Size    First Load JS
┌ ○ /                         13 kB        118 kB
├ ○ /_not-found               998 B        103 kB
├ ƒ /api/analyze              125 B        102 kB
├ ƒ /api/generate-image       125 B        102 kB
└ ○ /privacy                  163 B        106 kB
+ First Load JS shared by all 102 kB
```

- `pnpm build` 성공, 컴파일 에러 없음
- TypeScript 타입 체크 (`tsc --noEmit`) 통과
- ESLint 경고/에러 없음 (`next lint`)
- Static 페이지(`/`, `/privacy`) 와 Dynamic API 라우트 모두 정상 생성

---

## 2. Next.js App Router 패턴 준수

### 주요 구조

```
app/
  layout.tsx      — Server Component (SEO metadata, font variables)
  page.tsx        — 'use client' (상태 관리 필요)
  globals.css     — Tailwind v4 @theme 정의
components/
  CharacterBanner.tsx  — Server Component (순수 표현)
  UploadSection.tsx    — 'use client' (drag-and-drop, refs)
  LoadingSection.tsx   — 'use client' (interval, state)
  ResultSection.tsx    — 'use client' (animation, share API)
  DisclaimerText.tsx   — Server Component (순수 표현)
  AdBanner.tsx         — 'use client' (useEffect for AdSense)
```

### 양호한 점

- `layout.tsx`가 Server Component로 올바르게 유지되어 SEO metadata가 서버에서 생성됨
- `LoadingSection`, `ResultSection`을 `dynamic()` + `ssr: false`로 처리하여 초기 번들 최적화
- `CharacterBanner`와 `DisclaimerText`는 'use client' 없이 Server Component로 유지 (적절)

### 개선 권고 사항

**[경고] `page.tsx`의 `'use client'` 선언이 최상위에 있어 전체 트리가 클라이언트 번들에 포함됨**

현재 구조에서 upload 상태의 `header`, `DisclaimerText`, `CharacterBanner`는 상태 독립적이므로 서버에서 렌더링 가능합니다. 그러나 `useState`/`useEffect`가 최상위에 존재하여 분리가 어려운 상황입니다. 이는 아키텍처적으로 허용 가능한 트레이드오프이며, 현재 앱 규모에서는 문제없습니다.

---

## 3. Tailwind CSS v4 사용 패턴

### 양호한 점

- `@theme` 블록에 디자인 토큰을 올바르게 정의 (`--color-*`, `--font-*`, `--shadow-*`)
- `var(--color-bg-yellow)` 등 CSS 커스텀 프로퍼티를 Tailwind 클래스와 혼용하는 패턴이 일관됨
- `@import "tailwindcss"` 진입점 사용 (v4 방식)

### 확인된 정상 동작

```css
/* globals.css */
@theme {
  --color-bg-yellow: #ffe847;
  --font-black-han: 'Black Han Sans', sans-serif;
  --shadow-4: 12px 12px 0 #000;
}
```

```tsx
/* page.tsx — 올바른 v4 사용 */
className="bg-[var(--color-bg-yellow)]"
style={{ fontFamily: 'var(--font-black-han)' }}
```

---

## 4. Design Spec 준수도

### AC-1: 전폭 히어로 레이아웃 — PASS

- upload 상태에서 `min-h-screen flex flex-col bg-[var(--color-bg-yellow)]` 적용 확인
- `max-w-lg` 제한이 `<main>`에서 제거됨 (업로드 카드 내부에만 `max-w-md`로 제한)

### AC-2: 메인 카피 텍스트 — 부분 준수

| 스펙 | 구현 | 일치 여부 |
|------|------|-----------|
| 헤드라인 `text-4xl md:text-6xl` | `text-2xl md:text-5xl` | **불일치** |
| 서브카피 `text-lg md:text-xl` | `text-sm md:text-lg` | **불일치** |
| 헤드라인 회전 `rotate-[-1deg]` | `rotate-[-1deg]` | 일치 |
| Black Han Sans 폰트 | 적용 | 일치 |
| 타이틀 `text-7xl md:text-9xl` | `text-5xl md:text-7xl` | **불일치** |

**평가**: 디자인 스펙 대비 텍스트 크기가 전반적으로 축소 구현되었습니다. 개발자가 실제 화면에서 컴팩트한 레이아웃을 선택한 것으로 보이며, 캐릭터 배너가 뷰포트 내에 들어오도록 조정한 의도로 해석됩니다. 기능상 문제는 없으나 디자인 의도와 차이가 있습니다.

### AC-3: 이미지 업로드 영역 — PASS

- `UploadSection` 기능 100% 보존 (드래그앤드롭, 파일선택, 미리보기, 카메라 촬영)
- 파일 타입 검증 (`image/jpeg`, `image/png`, `image/webp`)
- 10MB 파일 크기 제한
- 에러 표시 로직 정상

### AC-4: 캐릭터 배치 — 구현 방식 변경

| 스펙 | 구현 |
|------|------|
| 개별 4개 SVG (`bbakdosa.svg`, `king.svg`, `donggu.svg`, `MJart.svg`) | 단일 통합 `characters.svg` |
| `flex justify-center items-end` | `w-full block` (이미지 전폭 확장) |
| `h-[120px] sm:h-[180px] md:h-[250px]` 반응형 높이 | 자동 비율 유지 (`w-full`) |

**평가**: 개별 SVG를 하나로 합친 방식은 HTTP 요청 수를 줄이는 장점이 있습니다. 그러나 912KB SVG가 base64 인코딩된 PNG를 포함하고 있어 심각한 성능 문제가 발생합니다 (아래 성능 섹션 참조).

### AC-5: 기존 기능 유지 — PASS

- 3단계 상태 전환 (upload → loading → result) 정상 동작
- 에러 처리, Rate Limit 처리, 네트워크 오류 처리 보존
- `previewUrl` cleanup (`URL.revokeObjectURL`) 정상
- `ResultReveal` GSAP 애니메이션 + `prefers-reduced-motion` 접근성 처리 유지

### 스펙 누락 요소

- **`overflow-x: hidden`**: 스펙에 명시되었으나 `<main>` 또는 상위 컨테이너에 적용되지 않음. `CharacterBanner`의 `w-full` 이미지가 모바일 뷰포트에서 가로 스크롤을 유발할 수 있음
- **`AdBanner` upload 상태 미표시**: 스펙(web-brief.md)에 `AdBanner` 위치가 명시되어 있으나 upload 상태에서 렌더링되지 않음. loading/result 상태에서만 표시됨. 의도적 생략이면 문서화 필요

---

## 5. 성능 이슈

### [심각] characters.svg 파일 용량: 912KB

```
/public/characters.svg — 912KB (SVG 내부에 base64 PNG 포함)
```

현재 `characters.svg`는 순수 벡터 SVG가 아니라 **base64 인코딩된 PNG 데이터를 내포한 SVG 래퍼**입니다. 이는:

1. **초기 페이지 로드 시 912KB를 동기 차단없이 다운로드해야 함** — 모바일 3G 환경에서 약 4~8초 소요
2. SVG 특유의 용량 절감 이점이 없음 (사실상 PNG를 SVG로 포장한 것)
3. Next.js의 이미지 최적화(`next/image`)가 적용되지 않아 WebP 변환, lazy loading, srcset 생성이 불가능

**권고**: `characters.svg`를 실제 벡터 SVG로 교체하거나, PNG/WebP로 변환하여 `next/image`의 최적화를 활용하세요.

```tsx
// 현재 (최적화 불가)
<img src="/characters.svg" alt="..." className="w-full block" />

// 권고 (next/image + PNG/WebP)
import Image from 'next/image';
<Image
  src="/characters.png"
  alt="탈모상 캐릭터들 - 빡도사, 킹, 동구, MJ아트"
  width={1248}
  height={374}
  className="w-full"
  priority={false}
/>
```

### [중간] 번들 크기 확인

- First Load JS: 118KB (압축 전)
- GSAP + @gsap/react가 포함되나 `dynamic()`으로 분리되어 초기 로드에 영향 없음
- 현재 규모에서 허용 가능한 수준

### [낮음] `useEffect` 의존성 패턴

`page.tsx`의 `previewUrl` cleanup `useEffect`:

```tsx
useEffect(() => {
  return () => {
    if (previewUrl) {
      URL.revokeObjectURL(previewUrl);
    }
  };
}, [previewUrl]);
```

`previewUrl`이 변경될 때마다 이전 URL을 revoke하는 패턴은 정상이나, `handlePhotoUpload` 내에서도 `URL.revokeObjectURL(previewUrl)`을 명시적으로 호출하고 있어 **이중 revoke 가능성**이 있습니다. 단, 이미 revoke된 URL을 다시 revoke해도 에러가 발생하지 않으므로 실질적 버그는 아닙니다.

---

## 6. 반응형 레이아웃

### 양호한 점

- `UploadSection`의 드래그앤드롭 존이 미디어 쿼리(`@media (max-width: 640px)`)로 150x150px로 조정됨
- 카드 높이: `h-[220px] md:h-[250px]` — 모바일/데스크톱 모두 적절
- `px-4` 좌우 패딩으로 모바일에서 콘텐츠 클리핑 방지

### 우려 사항

- **`overflow-x: hidden` 미적용**: `characters.svg`가 `w-full block`으로 렌더링될 때 SVG viewBox (`1248x374`)와 뷰포트 너비 불일치 시 가로 스크롤 발생 가능. 설계 스펙에서 `overflow-x: hidden`을 명시했으나 구현에 누락됨

---

## 7. 코드 품질

### 양호한 점

- JSDoc 한국어 주석이 주요 함수 (`handlePhotoUpload`, `handleAnalyze`, `handleReset`)에 적절히 작성됨
- `ERROR_MESSAGES` 상수를 별도 파일로 분리하여 에러 문구 중앙 관리
- `validateFile` 함수가 순수 함수로 분리되어 테스트 용이
- `eslint-disable-next-line @next/next/no-img-element` 주석이 의도적 `<img>` 사용 위치에 명시됨
- TypeScript interface (`UploadSectionProps`, `ResultSectionProps`)가 명확히 정의됨

### 개선 권고

**[낮음] `UploadSection.tsx`의 `alert()` 사용:**

```tsx
// 현재
if (validationError) {
  alert(validationError);
  return;
}
```

`alert()`은 브라우저 기본 다이얼로그로 UX가 좋지 않고 스타일 커스터마이즈가 불가능합니다. `onError` prop을 통해 `page.tsx`의 `setError`로 전달하거나, 직접 에러 상태를 표시하는 방식이 더 일관성 있습니다. 기존 `error` prop과 병행 사용 중이어서 에러 처리 경로가 이원화되어 있습니다.

---

## 8. 승인/수정 사항 정리

### 즉시 수정 권고 (릴리스 전 필수)

1. **`overflow-x: hidden` 추가** — `<main>` 태그에 누락된 속성 추가
   ```tsx
   <main className="min-h-screen flex flex-col bg-[var(--color-bg-yellow)] relative overflow-x-hidden">
   ```

### 중기 개선 권고 (다음 이터레이션)

2. **`characters.svg` 최적화** — 912KB base64 내포 SVG를 최적화된 이미지(PNG/WebP 또는 순수 벡터 SVG)로 교체하여 LCP(Largest Contentful Paint) 개선

3. **텍스트 크기 스펙 재협의** — 현재 구현(`text-2xl md:text-5xl`)이 스펙(`text-4xl md:text-6xl`)보다 작음. 디자이너와 실제 레이아웃 의도 재확인 후 수정 또는 스펙 업데이트

### 낮은 우선순위

4. **`alert()` 대체** — 파일 검증 에러를 `onError` 콜백 또는 `setError`로 통일

5. **`next lint` deprecation 경고 대응** — `next lint`가 Next.js 16에서 제거 예정. ESLint CLI 마이그레이션 사전 계획 수립

---

## 최종 판정

**조건부 승인 (Conditional Approval)**

- 빌드, TypeScript, ESLint 모두 통과
- 핵심 기능 (3단계 전환, 업로드, 분석, 결과) 완전 보존
- `overflow-x: hidden` 누락은 모바일 가로 스크롤 버그 유발 가능성이 있어 **릴리스 전 수정 필요**
- `characters.svg` 912KB 성능 이슈는 중기 이터레이션에서 해결 권고

수정 완료 후 별도 리뷰 없이 배포 가능합니다.
