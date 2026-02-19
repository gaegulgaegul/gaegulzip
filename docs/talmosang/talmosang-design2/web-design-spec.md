# Web Design Spec: talmosang-design2

## The Weirdos 스타일 랜딩 페이지

### 1. 전체 레이아웃 구조

```
┌──────────────────────────────────────────────┐
│                                              │
│              "탈모상" (타이틀)                  │
│                                              │
│     "이보시오 관상가 양반,                      │
│      내가 탈모가 될 상인가?"                    │
│                                              │
│   "AI 관상가가 그대의 모발 운명을 점지하리라"     │
│                                              │
│         ┌──────────────────┐                 │
│         │  [이미지 업로드]    │                 │
│         │   사진을 올려주세요  │                 │
│         └──────────────────┘                 │
│                                              │
│    (면책 문구 + 안심 문구)                      │
│                                              │
│  ┌──────┬──────┬──────┬──────┐              │
│  │빡도사 │  킹  │ 동구  │MJart │              │
│  │      │      │      │      │              │
│  └──────┴──────┴──────┴──────┘              │
└──────────────────────────────────────────────┘
```

### 2. 섹션별 상세 스펙

#### 2-1. 배경 & 전체 레이아웃

| 속성 | 값 |
|------|-----|
| 배경색 | `var(--color-bg-yellow)` (#ffe847, CSS 변수 기준) |
| 너비 | 전폭 (full-width), `max-w-lg` 제거 |
| 최소 높이 | `min-h-screen` |
| overflow | `overflow-x: hidden` (캐릭터 잘림 방지) |
| 구조 | `flex flex-col` 세로 배치, 콘텐츠 상단/캐릭터 하단 |

#### 2-2. 타이틀 섹션

- 기존 "탈모상" h1 스타일 유지 (white pill badge, 핑크 하드 섀도우)
- upload 상태: `text-5xl md:text-7xl`, Black Han Sans, 테두리 `border-[5px]`
- loading/result 상태: `text-7xl md:text-9xl`, 테두리 `border-[6px]`
- `rotate-[-3deg]`, `animate-bounce-in`
- upload 상태 상단 패딩: `pt-6 md:pt-10`

#### 2-3. 메인 카피 섹션

| 요소 | 스타일 |
|------|--------|
| 헤드라인 | `text-2xl md:text-5xl`, `font-extrabold`, Black Han Sans |
| 헤드라인 회전 | `rotate-[-1deg]` |
| 서브카피 | `text-sm md:text-lg`, Jua, `text-charcoal/80` |
| 간격 | 헤드라인-서브 간 `mb-1`, 섹션 하단 `mb-3` |
| 정렬 | 모두 `text-center` |

텍스트 내용 (기존 유지):
- 헤드라인: "이보시오 관상가 양반, 내가 탈모가 될 상인가?"
- 서브카피: "AI 관상가가 그대의 모발 운명을 점지하리라"

#### 2-4. 업로드 영역

- The Weirdos의 "join the weird gang" 위치에 배치
- 기존 UploadSection 컴포넌트 기능 100% 유지
- 최대 너비 제한: `max-w-md` (업로드 카드만)
- 기존 Al Murphy 스타일 유지 (hard shadow, 두꺼운 테두리, paper-texture)

#### 2-5. 보조 요소

- 면책 문구 (DisclaimerText): 캐릭터 배너 하단
- 광고 배너 (AdBanner): upload 상태에서 미표시, loading/result 상태에서만 표시

#### 2-6. 캐릭터 배너 (핵심 신규 요소)

```
┌─────────────────────────────────────────────┐
│ ┌──────────────────────────────────────────┐│
│ │        characters.svg (4캐릭터 합본)      ││
│ └──────────────────────────────────────────┘│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
└─────────────────────────────────────────────┘
```

| 속성 | 값 |
|------|-----|
| 배치 | 페이지 최하단, `mt-auto` |
| 컨테이너 | `w-full mt-auto pointer-events-none border-b-[8px] border-black` |
| 구현 방식 | 단일 `characters.svg` (4개 캐릭터 합본) |
| 이미지 스타일 | `w-full block` (좌우 꽉 채움, 자동 비율 유지) |
| 반응형 | SVG 자체 비율로 자동 스케일 (2단계: mobile/desktop) |
| 하단 테두리 | `border-b-[8px] border-black` |
| 포인터 이벤트 | `pointer-events-none` (인터랙션 비활성화) |

### 3. 반응형 브레이크포인트

| 화면 | 레이아웃 | 캐릭터 |
|------|---------|--------|
| Mobile (<768px) | 타이틀 `text-5xl`, 카피 `text-2xl` | characters.svg 자동 비율 |
| Desktop (>=768px) | 타이틀 `text-7xl`, 카피 `text-5xl` | characters.svg 자동 비율 |

### 4. 상태별 레이아웃

| 상태 | 배경 | 캐릭터 표시 |
|------|------|------------|
| upload | 노란색 (bg-yellow) | O (하단 배치) |
| loading | 기존 유지 | X (기존 로딩 UI) |
| result | 기존 유지 | X (기존 결과 UI) |

### 5. 컴포넌트 변경 목록

| 파일 | 변경 내용 |
|------|----------|
| `app/page.tsx` | 전폭 레이아웃, 캐릭터 배너 추가, 조건부 렌더링 |
| `components/CharacterBanner.tsx` | **신규** - 4개 캐릭터 일렬 배치 컴포넌트 |
| `components/UploadSection.tsx` | 변경 없음 (기존 유지) |

### 6. 폰트

- Black Han Sans: 타이틀, 헤드라인 (`var(--font-black-han)`)
- Jua: 서브카피, 본문 (`var(--font-jua)`)
