# User Story: talmosang-design2

## Feature: The Weirdos 스타일 랜딩 페이지 레이아웃

### 개요

탈모상 메인 페이지를 "The Weirdos" (https://theweirdos.wtf) 웹사이트 스타일로 재설계합니다.
4개의 커스텀 캐릭터 SVG를 하단에 배치하고, 중앙에 히어로 텍스트와 이미지 업로드 영역을 배치합니다.

### 레퍼런스

- **이미지**: `prompt/archives/img.png` (The Weirdos 웹사이트 캡처)
- **레이아웃 특징**:
  - 노란 배경, 전폭 (full-width) 섹션
  - 큰 볼드 타이틀 텍스트 (중앙)
  - CTA 영역 (중앙) → **이미지 업로드 영역으로 대체**
  - 캐릭터 일러스트 일렬 배치 (하단)
  - 메뉴 바 → **제외**

### 캐릭터 에셋

| 파일 | 캐릭터명 | 크기 |
|------|---------|------|
| `public/characters/bbakdosa.svg` | 빡도사 (관상가) | 1024x1024 |
| `public/characters/king.svg` | 킹 (두피 수호신) | 1024x1024 |
| `public/characters/donggu.svg` | 동구 | 1024x1024 |
| `public/characters/MJart.svg` | MJ아트 | 1024x1024 |

- 모든 캐릭터 배경은 투명 처리

### 사용자 스토리

**AS A** 탈모상 방문자
**I WANT TO** The Weirdos 스타일의 비주얼리 임팩트 있는 랜딩 페이지를 보고
**SO THAT** 서비스에 대한 첫 인상이 강렬하고, 자연스럽게 사진 업로드로 이어진다

### 수용 기준 (Acceptance Criteria)

#### AC-1: 전폭 히어로 레이아웃
- [ ] 페이지 배경이 노란색(bg-yellow)으로 전체를 채움
- [ ] 기존 `max-w-lg` 제한 제거, 전폭 섹션 기반 레이아웃
- [ ] 중앙에 큰 타이틀 텍스트 배치 (기존 "탈모상" 타이틀 유지)

#### AC-2: 메인 카피 텍스트
- [ ] The Weirdos의 "IT'S DEFINITELY NOT A CULT" 위치에 기존 카피 배치
  - 메인: "이보시오 관상가 양반, 내가 탈모가 될 상인가?"
  - 서브: "AI 관상가가 그대의 모발 운명을 점지하리라"
- [ ] 텍스트는 굵고 큰 사이즈, Black Han Sans / Jua 폰트 사용

#### AC-3: 이미지 업로드 영역
- [ ] The Weirdos의 "join the weird gang" CTA 위치에 이미지 업로드 존 배치
- [ ] 기존 UploadSection의 기능 (드래그앤드롭, 파일선택, 카메라) 유지
- [ ] 업로드 영역 디자인은 현재 스타일 유지 (hard shadow, 두꺼운 테두리)

#### AC-4: 캐릭터 배치
- [ ] 4개 캐릭터가 페이지 하단에 일렬로 배치
- [ ] The Weirdos처럼 캐릭터들이 페이지 너비를 채우며 나란히 서있는 형태
- [ ] 각 캐릭터는 적절한 크기로 리사이징 (약 200-300px 높이)
- [ ] 모바일에서도 캐릭터가 보이도록 반응형 처리

#### AC-5: 기존 기능 유지
- [ ] 3단계 상태 전환 (upload → loading → result) 정상 동작
- [ ] 광고 배너, 면책 문구 등 기존 요소 유지
- [ ] 에러 처리, 파일 검증 등 기존 로직 보존

### 범위 제외 (Out of Scope)

- 인터랙티브 효과 (호버, 스크롤 애니메이션 등) → 후속 작업
- 캐릭터 애니메이션 → 후속 작업
- Loading/Result 섹션 레이아웃 변경 → 이번에는 Upload 상태만

### 기술 참고

- 플랫폼: Web (Next.js App Router)
- 스타일: Tailwind CSS v4 + 커스텀 CSS
- 폰트: Black Han Sans (타이틀), Jua (본문)
- 현재 레이아웃: `max-w-lg mx-auto` (좁은 단일 컬럼)
- 목표 레이아웃: 전폭 섹션 기반, 캐릭터 하단 고정
