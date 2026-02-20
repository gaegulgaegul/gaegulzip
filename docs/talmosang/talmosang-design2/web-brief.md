# Web Brief: talmosang-design2

## 구현 개요

탈모상 메인 페이지(upload 상태)를 The Weirdos 스타일 전폭 히어로 + 캐릭터 배너 레이아웃으로 변경합니다.

## 변경 대상 파일

### 1. `app/page.tsx` (수정)

**변경 사항:**
- `<main>` 태그의 `max-w-lg mx-auto` 클래스를 조건부로 적용
  - `upload` 상태: 전폭 레이아웃 (`min-h-screen flex flex-col`)
  - `loading`/`result` 상태: 기존 `max-w-lg mx-auto` 유지
- upload 상태일 때 배경색을 `bg-[var(--color-bg-yellow)]`로 설정
- upload 상태 하단에 `CharacterBanner` 컴포넌트 렌더링
- 메인 카피를 `UploadSection` 밖으로 꺼내어 page.tsx에서 직접 렌더링
  - 헤드라인: `text-4xl md:text-6xl font-extrabold`
  - 서브카피: `text-lg md:text-xl`
- 콘텐츠 영역은 `flex-1`로 상단, 캐릭터는 `mt-auto`로 하단 고정

**레이아웃 구조 (upload 상태):**
```tsx
<main className="min-h-screen flex flex-col bg-[var(--color-bg-yellow)] overflow-x-hidden relative">
  {/* 콘텐츠 영역 */}
  <div className="flex-1 flex flex-col items-center px-4 pt-6 md:pt-10 pb-8 md:pb-12">
    <header> {/* 타이틀 - text-5xl md:text-7xl, border-[5px] */} </header>
    {/* 메인 카피 */}
    <div className="text-center mt-2 mb-3">
      <h2 className="text-2xl md:text-5xl font-extrabold mb-1 rotate-[-1deg]">이보시오 관상가 양반...</h2>
      <p className="text-sm md:text-lg text-charcoal/80">AI 관상가가...</p>
    </div>
    {/* 업로드 영역 - max-w-md로 제한 */}
    <div className="w-full max-w-md">
      <UploadSection ... />
    </div>
  </div>
  {/* 캐릭터 배너 - 하단 고정 */}
  <CharacterBanner />
  {/* 면책 문구 - 캐릭터 하단 */}
  <div className="w-full px-4 py-2">
    <DisclaimerText />
  </div>
</main>
```

**레이아웃 구조 (loading/result 상태):**
```tsx
<main className="min-h-screen px-4 py-8 max-w-lg mx-auto">
  {/* 기존과 동일 */}
</main>
```

### 2. `components/CharacterBanner.tsx` (구현 완료)

**역할:** 4개 캐릭터가 합쳐진 단일 SVG를 하단에 좌우 꽉 채워 배치

**구현 (현행):**
```tsx
export default function CharacterBanner() {
  return (
    <div className="w-full mt-auto pointer-events-none border-b-[8px] border-black">
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src="/characters.svg"
        alt="탈모상 캐릭터들 - 빡도사, 킹, 동구, MJ아트"
        className="w-full block"
      />
    </div>
  );
}
```

**스타일:**
- 컨테이너: `w-full mt-auto pointer-events-none border-b-[8px] border-black`
- 이미지: `w-full block` (좌우 꽉 채움, SVG 자체 비율로 자동 스케일)
- 이미지 소스: `/characters.svg` (개별 SVG 4개 → 단일 합본으로 변경)
- next/image 대신 `<img>` 태그 사용 (SVG이므로 최적화 불필요)

### 3. `components/UploadSection.tsx` (수정 최소)

**변경 사항:**
- 메인 카피 (`<h2>`, `<p>`) 제거 → page.tsx로 이동
- 나머지 기능 100% 유지

## 구현 순서

1. `CharacterBanner.tsx` 신규 생성
2. `UploadSection.tsx`에서 메인 카피 제거
3. `page.tsx` 레이아웃 변경 (조건부 전폭/기존)

## 기술 제약사항

- SVG 파일이 1024x1024로 큼 → img 태그의 height로 제어, width는 auto
- Tailwind CSS v4 사용 중 → `@theme` 토큰 활용
- `overflow-x: hidden` 필수 (캐릭터가 화면 밖으로 나갈 수 있음)
- `next/image`는 SVG에 불필요 → `<img>` 태그 + eslint-disable 주석

## 검증 항목

- [x] upload 상태에서 노란 배경 전폭 표시
- [x] 타이틀 + 카피 + 업로드 존이 중앙 정렬
- [x] characters.svg가 하단에 좌우 꽉 채워 배치
- [x] loading/result 상태에서 기존 레이아웃 유지
- [x] overflow-x: hidden 적용 (캐릭터 잘림 방지)
- [x] 모바일/데스크톱 반응형 정상 (2단계 브레이크포인트)
- [x] 파일 업로드, 분석 등 기존 기능 정상 동작
