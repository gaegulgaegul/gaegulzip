# 웹 통합 리뷰: 탈모상 (Hair Loss Fortune Telling)

**리뷰 일시**: 2026-02-14
**리뷰어**: CTO
**플랫폼**: Web (Next.js 16)
**Feature**: talmosang

---

## 1. 빌드 성공 여부

### ✅ Pass

```bash
pnpm --filter talmosang build
```

**결과**:
- ✓ Compiled successfully in 2.1s
- ✓ Linting and checking validity of types 통과
- ✓ Static pages 생성 성공 (7/7)
- ✓ Production 빌드 완료

**번들 크기**:
- First Load JS: 102 kB (shared)
- Main page (`/`): 15.8 kB → 총 121 kB
- API routes: 125 B each

**경고**:
- ⚠ `metadataBase` 미설정 → OG 이미지 절대 URL 생성 불가
  - **권고**: `layout.tsx`에 `metadataBase: new URL('https://gaegulzip-talmosang.vercel.app')` 추가

---

## 2. 코드 품질

### ✅ Pass (Minor Issues)

#### TypeScript 타입 안전성

**✅ 강점**:
- 모든 컴포넌트에 명확한 인터페이스 정의 (`AnalysisResult`, `UploadSectionProps` 등)
- API 응답 타입 정의 완비 (`types/analysis.ts`)
- `any` 사용 없음
- Generic 타입 적절히 활용 (예: `useState<AppStep>`)

**⚠ 개선 필요**:
1. **celebrity 타입 불일치** (Gap 분석 #1)
   - **설계**: `celebrity: string` (간단한 문자열)
   - **실제 구현**: `celebrity: { name: string, comment: string }` (객체)
   - **영향**: 설계 문서와 구현이 불일치하지만, 실제로는 구현이 더 나은 구조
   - **권고**: 설계 문서(`web-brief.md`, `web-design-spec.md`)를 구현에 맞춰 업데이트

2. **이미지 생성 에러 처리 타입**
   - `app/page.tsx:115-121`: 이미지 생성 실패 시 `null` 할당만 하고 에러 타입 체크 없음
   - **권고**: `GenerateImageResponse`의 `error` 필드 활용

#### 컴포넌트 구조

**✅ 강점**:
- Server/Client Components 명확히 분리 (gap 분석 "Server Component 전략 준수")
- 단일 책임 원칙 준수 (UploadSection, LoadingSection, ResultSection 분리)
- Custom Hooks 활용 (`useCountUp` 애니메이션)
- 메모리 누수 방지 (`useEffect` cleanup으로 `URL.revokeObjectURL`)

**⚠ 개선 필요**:
1. **에러 경계(Error Boundary) 부재**:
   - API 에러는 catch하지만 컴포넌트 렌더링 에러는 처리 안 됨
   - **권고**: `app/error.tsx` 추가로 전역 에러 처리

2. **LoadingSection 상태 관리**:
   - 로딩 메시지 전환 로직이 컴포넌트 내부에 하드코딩
   - **권고**: 별도 훅 분리 또는 상수화

#### 상태 관리 패턴

**✅ 강점**:
- React Hook(`useState`) 적절히 사용
- 상태 전환 로직 명확 (`upload` → `loading` → `result`)
- Props drilling 최소화

**⚠ 개선 필요**:
1. **공유 버튼 상태 관리**:
   - `copied` 상태가 `ResultSection` 컴포넌트 내부에만 존재
   - Web Share API fallback 로직이 다소 복잡
   - **권고**: 별도 `useShare` 훅으로 추출

---

## 3. Server/Client Component 경계

### ✅ Pass

**Server Components** (정확히 사용):
- `app/layout.tsx`: Root layout, 메타데이터, 폰트 로드
- `app/privacy/page.tsx`: 정적 개인정보처리방침 페이지
- `components/DisclaimerText.tsx`: 정적 면책 문구
- `app/api/analyze/route.ts`, `app/api/generate-image/route.ts`: API Routes

**Client Components** (`'use client'` 정확히 사용):
- `app/page.tsx`: 상태 관리 총괄
- `components/UploadSection.tsx`: 파일 업로드, 드래그앤드롭
- `components/LoadingSection.tsx`: 로딩 애니메이션, 메시지 전환
- `components/ResultSection.tsx`: 결과 표시, 공유 기능, 카운트업 애니메이션
- `components/AdBanner.tsx`: AdSense 동적 로드

**검증 결과**:
- ✅ 인터랙션이 필요한 컴포넌트만 Client Component로 선언
- ✅ 불필요한 `'use client'` 선언 없음
- ✅ Server Component에서 Client Component로 props 전달 패턴 정확

**Zero JavaScript 최적화**:
- Server Components가 HTML만 전송하여 초기 로딩 최적화 달성

---

## 4. shadcn/ui 사용

### ⚠ Warning (직접 수정 발견)

#### shadcn/ui 컴포넌트 커스터마이징 방식 검증

**✅ 적절한 사용**:
1. **Button 컴포넌트**:
   - 기본 variant 사용 + `primary` variant 추가
   - CSS 클래스(`btn-primary`)로 커스터마이징
   - **방식**: globals.css에 `.btn-primary` 정의 후 variant 확장 ✅

2. **Badge 컴포넌트**:
   - `stamp`, `type` variant 추가
   - **방식**: `badgeVariants`에 새 variant 추가 ✅

3. **Card 컴포넌트**:
   - `paper-texture`, `pencil-border` 클래스로 커스터마이징
   - **방식**: className prop으로 추가 스타일 적용 ✅

4. **Progress 컴포넌트**:
   - `hand-drawn-progress` 클래스로 손그림 느낌 구현
   - **방식**: CSS selector로 내부 요소 스타일링 ✅

#### ⚠ 직접 수정 발견 (Gap 분석 #7)

**파일**: `components/ui/button.tsx`, `components/ui/badge.tsx`

**수정 내용**:
1. **button.tsx**:
   - `primary` variant 추가 (line 20: `primary: 'btn-primary'`)
   - **평가**: 설계상 허용된 확장이지만, 설계 문서에서는 "수정 금지" 명시

2. **badge.tsx**:
   - `stamp`, `type` variant 추가 (lines 16-17)
   - **평가**: 필요한 커스터마이징이지만, 설계 문서 위반

**설계 문서 vs 실제**:
- **설계 (`web-brief.md` line 36)**: `└── ui/ # shadcn/ui 컴포넌트 (수정 금지)`
- **설계 (`web-design-spec.md` lines 870, 886, 905)**: "기본 스타일: ... (수정 금지)"
- **실제**: variant 추가로 컴포넌트 직접 수정

**권고**:
1. **단기**: 현재 구현 유지 (variant 확장은 shadcn/ui 권장 패턴)
2. **장기**: 설계 문서 업데이트하여 "variant 확장은 허용" 명시
3. **Best Practice**:
   - Wrapper 컴포넌트 생성: `<PrimaryButton>`, `<StampBadge>` 등
   - 기본 shadcn/ui 컴포넌트는 수정 없이 유지

---

## 5. 보안

### ✅ Pass

#### API 키 노출 방지

**✅ 강점**:
1. **Gemini API 키 보호**:
   - 환경 변수로 관리 (`process.env.GEMINI_API_KEY`)
   - Server-side API Routes에서만 사용 (클라이언트 노출 없음)
   - `.env.local.example` 제공으로 개발자 가이드 완비

2. **AdSense ID**:
   - `NEXT_PUBLIC_*` prefix로 클라이언트 노출 허용 (공개 정보이므로 문제없음)

#### XSS (Cross-Site Scripting) 방지

**✅ 강점**:
- React의 기본 XSS 보호 활용 (JSX 자동 escape)
- 코드베이스 전체에서 위험한 HTML 삽입 패턴 사용 안 함

**⚠ 개선 필요**:
1. **이미지 src 검증**:
   - `ResultSection.tsx:204`: `result.simulationImage`를 직접 `src`에 삽입
   - Gemini API 응답 신뢰하지만, data URI 형식 검증 추가 권장
   - **권고**: 정규식으로 `data:image/(png|jpeg|webp);base64,` 패턴 검증

2. **사용자 입력 이미지**:
   - 파일 업로드 검증은 MIME type만 체크
   - **권고**: 파일 시그니처(magic number) 추가 검증

#### 입력 검증

**✅ 강점**:
1. **파일 타입 검증** (`UploadSection.tsx:44`):
   - `allowedTypes = ['image/jpeg', 'image/png', 'image/webp']`

2. **파일 크기 제한** (`UploadSection.tsx:49`):
   - 최대 10MB

**⚠ 개선 필요**:
1. **API 입력 검증 부재**:
   - `app/api/analyze/route.ts:56`: `image`, `mimeType` 검증 없음
   - **권고**: Zod 스키마 추가로 타입, 길이 검증

#### CSP (Content Security Policy)

**✅ 강점** (`next.config.ts:14-33`):
- `script-src`: AdSense 허용, `'unsafe-eval'` 제한적 사용
- `img-src`: data URI, https 허용
- `connect-src`: Gemini API만 허용

**⚠ 개선 필요**:
1. **`'unsafe-inline'`, `'unsafe-eval'` 사용**:
   - Next.js 자체 요구사항이지만, Vercel 배포 시 nonce 기반 CSP로 전환 권장

---

## 6. 성능

### ✅ Pass (Minor Issues)

#### 이미지 최적화

**✅ 강점**:
1. **클라이언트 리사이즈** (`lib/image-utils.ts`):
   - 업로드 전 800px 리사이즈로 네트워크 부하 감소
   - Canvas API 활용 (WebP 변환 지원)

**⚠ 개선 필요**:
1. **Next.js Image 컴포넌트 미사용** (Gap 분석 관련):
   - `ResultSection.tsx:204`: `<img>` 태그 직접 사용 (Gemini 생성 이미지)
   - `UploadSection.tsx:152`: `<img>` 태그 사용 (미리보기)
   - **이유**: Data URI 사용으로 Next.js Image 최적화 불필요
   - **평가**: 정당한 사용 (외부 이미지가 아닌 base64 data)

2. **OG 이미지 에셋 누락** (Gap 분석 #3):
   - `layout.tsx:13`: `/og-image.png` 참조하지만 파일 없음
   - **영향**: SNS 공유 시 이미지 미표시
   - **우선순위**: **High** (바이럴 확산에 필수)

#### 메모리 관리

**✅ 강점**:
1. **Object URL 정리**:
   - `app/page.tsx:34-40`: `useEffect` cleanup으로 `URL.revokeObjectURL` 호출
   - 메모리 누수 방지 완벽

2. **이미지 리사이즈 메모리 최적화**:
   - Canvas 사용 후 즉시 Blob 변환

#### 번들 크기

**✅ 강점**:
- First Load JS: 121 kB (허용 범위)
- shadcn/ui 컴포넌트 Tree-shaking 적용 (사용하는 것만 포함)
- Tailwind CSS Purge 활성화 (미사용 클래스 제거)

**⚠ 개선 가능**:
1. **Lazy Loading 미사용** (Gap 분석 관련):
   - `app/page.tsx`: `LoadingSection`, `ResultSection`을 정적 import
   - **설계 문서 (`web-brief.md` lines 1277-1307)**: dynamic import 권장
   - **영향**: 초기 번들에 불필요한 코드 포함 (약 10-15 kB 추가)
   - **권고**: dynamic import 적용

#### 폰트 로딩

**⚠ 개선 필요** (Gap 분석 #5):
1. **Pretendard → Noto Sans KR 변경**:
   - **설계**: Pretendard (로컬 폰트, woff2)
   - **실제**: Noto Sans KR (Google Fonts)
   - **영향**: 네트워크 요청 추가, 로딩 시간 증가 (Pretendard 로컬 폰트가 더 빠름)
   - **평가**: Noto Sans KR은 Google Fonts CDN 캐싱으로 실제 성능 저하 미미
   - **권고**: 설계 문서 업데이트 또는 Pretendard 로컬 폰트로 복원

2. **폰트 preload**:
   - `lib/fonts.ts:13`: `preload: true` 설정 ✅
   - `display: 'swap'` 설정으로 FOIT 방지 ✅

---

## 7. Gap 분석 주요 이슈 검토

### ⛔ High Priority (즉시 수정 필요)

#### 1. E2E 테스트 부재 (Gap 분석 #1)

**현황**:
- Playwright 설정 없음
- 테스트 파일 없음 (`*.test.*`, `*.spec.*`)

**영향**:
- 핵심 유저 플로우(업로드 → 분석 → 결과) 검증 불가
- 리그레션 위험 높음

**권고**:
- Playwright 설치 및 기본 플로우 테스트 작성
- 예상 작업 시간: 4시간

**우선순위**: **Critical** (MVP 배포 전 필수)

---

#### 2. 결과 이미지 다운로드 기능 미구현 (Gap 분석 #2)

**현황**:
- `ResultSection.tsx`: 공유 버튼만 존재
- Web Share API 미지원 브라우저에서 링크 복사만 가능
- 설계 문서(`web-design-spec.md` lines 1094-1100)에 명시된 "이미지 다운로드" 기능 없음

**영향**:
- 데스크톱 사용자 공유 불편 (바이럴 확산 저해)

**권고**:
- html2canvas 라이브러리 추가
- 다운로드 핸들러 구현
- 예상 작업 시간: 3시간

**우선순위**: **High** (바이럴 확산에 중요)

---

#### 3. OG 이미지 에셋 누락 (Gap 분석 #3)

**현황**:
- `app/layout.tsx:13`: `/og-image.png` 참조
- `public/og-image.png` 파일 없음

**영향**:
- SNS 공유 시 기본 이미지 표시 안 됨
- 클릭률(CTR) 저하

**권고**:
1. 1200x630px OG 이미지 생성 (Frame0 스케치 스타일)
2. `public/og-image.png`에 저장
3. `metadataBase` 설정 추가
4. 예상 작업 시간: 2시간

**우선순위**: **High** (바이럴 마케팅 필수)

---

### ⚠ Medium Priority (배포 후 개선)

#### 4. celebrity 타입 변경 (Gap 분석 #4)

**현황**:
- **설계**: `celebrity: string`
- **실제**: `celebrity: { name: string, comment: string }`

**영향**:
- 설계 문서와 불일치 (실제 구현이 더 나음)

**권고**:
- `web-brief.md`, `web-design-spec.md` 업데이트
- API 프롬프트(`app/api/analyze/route.ts:32-38`)가 이미 객체 구조 요청하므로 코드 수정 불필요

**우선순위**: **Medium** (문서 정합성)

---

#### 5. 본문 폰트 변경 (Gap 분석 #5)

**현황**:
- **설계**: Pretendard (로컬 폰트)
- **실제**: Noto Sans KR (Google Fonts)

**영향**:
- 네트워크 요청 추가 (Google Fonts CDN)

**평가**:
- Noto Sans KR도 한글 웹폰트로 적절
- Google Fonts CDN 캐싱으로 실제 성능 저하 미미

**권고**:
- 현재 구현 유지 OR Pretendard 로컬 폰트로 복원
- 설계 문서 업데이트

**우선순위**: **Low**

---

#### 6. Container 최대 너비 변경 (Gap 분석 #6)

**현황**:
- **설계**: `max-w-4xl` (896px)
- **실제**: `max-w-lg` (512px)

**영향**:
- 모바일 우선 디자인 강화 (바이럴 앱에 적합)

**평가**:
- 좁은 너비가 모바일 사용성 향상
- 데스크톱에서도 집중도 높임

**권고**:
- 현재 구현 유지 (실제가 더 나음)
- 설계 문서 업데이트

**우선순위**: **Low**

---

#### 7. shadcn/ui 컴포넌트 직접 수정 (Gap 분석 #7)

**위에서 검토 완료** (섹션 4 참조)

**우선순위**: **Medium** (설계 문서 업데이트)

---

## 8. 종합 평가

### Quality Scores

| 항목 | 점수 | 상태 | 비고 |
|------|------|------|------|
| **빌드 성공** | 10/10 | ✅ Pass | Production 빌드 완료, 타입 체크 통과 |
| **TypeScript 타입 안전성** | 9/10 | ✅ Pass | `any` 사용 없음, 타입 정의 완비 |
| **컴포넌트 구조** | 9/10 | ✅ Pass | Server/Client 분리, 단일 책임 원칙 준수 |
| **Server/Client 경계** | 10/10 | ✅ Pass | 적절한 `'use client'` 사용 |
| **shadcn/ui 활용** | 7/10 | ⚠ Warning | Variant 추가는 적절하나 설계 문서 위반 |
| **보안** | 8/10 | ✅ Pass | API 키 보호, CSP 설정, 입력 검증 (개선 여지 있음) |
| **성능** | 8/10 | ✅ Pass | 번들 크기 양호, 메모리 관리 완벽 (Lazy loading 미사용) |
| **E2E 테스트** | 0/10 | ⛔ Fail | 테스트 없음 (Critical) |
| **기능 완성도** | 7/10 | ⚠ Warning | 핵심 기능 완성, 이미지 다운로드 누락 |
| **설계 준수도** | 7/10 | ⚠ Warning | 주요 설계 준수, 일부 불일치 (개선된 경우 포함) |

**총점**: **75/100** (Pass with Conditions)

---

## 9. 우선순위별 개선 권고안

### 🔴 Critical (배포 전 필수)

1. **E2E 테스트 추가**
   - Playwright 설정
   - 핵심 유저 플로우 테스트 작성 (업로드 → 분석 → 결과)
   - 예상 작업 시간: 4시간

2. **OG 이미지 생성 및 추가**
   - 1200x630px 이미지 디자인 (Frame0 스타일)
   - `public/og-image.png` 저장
   - `metadataBase` 설정
   - 예상 작업 시간: 2시간

---

### 🟠 High (배포 직후 개선)

3. **결과 이미지 다운로드 기능 구현**
   - html2canvas 라이브러리 추가
   - `ResultSection`에 다운로드 버튼 추가
   - Web Share API 미지원 브라우저 대응
   - 예상 작업 시간: 3시간

4. **API 입력 검증 강화**
   - Zod 스키마 추가 (`app/api/analyze/route.ts`)
   - 파일 시그니처 검증 (magic number)
   - 예상 작업 시간: 2시간

5. **에러 경계 추가**
   - `app/error.tsx` 생성
   - 전역 에러 처리 (사극 말투 에러 메시지)
   - 예상 작업 시간: 1시간

---

### 🟡 Medium (2주 내 개선)

6. **설계 문서 업데이트**
   - `celebrity` 타입 수정 (객체 구조로)
   - `max-w-lg` 반영
   - Noto Sans KR 반영
   - shadcn/ui variant 확장 허용 명시
   - 예상 작업 시간: 1시간

7. **Lazy Loading 적용**
   - `LoadingSection`, `ResultSection` dynamic import
   - 초기 번들 크기 10-15 kB 감소
   - 예상 작업 시간: 30분

8. **공유 로직 Custom Hook 분리**
   - `useShare` 훅 생성
   - `ResultSection` 로직 단순화
   - 예상 작업 시간: 1시간

---

### 🟢 Low (향후 개선)

9. **Pretendard 로컬 폰트 복원 검토**
   - 성능 비교 테스트 (Noto Sans KR vs Pretendard)
   - 결과에 따라 선택
   - 예상 작업 시간: 2시간

10. **이미지 src 검증 추가**
    - Data URI 형식 정규식 검증
    - XSS 방지 강화
    - 예상 작업 시간: 1시간

---

## 10. 추가 발견사항

### ✅ 긍정적 측면

1. **Gemini API 통합 우수**:
   - 프롬프트 엔지니어링 훌륭 (사극 말투, 유머, 안전 장치)
   - Rate Limit 처리 완벽
   - 에러 메시지 사용자 친화적

2. **손그림 감성 구현 완벽**:
   - CSS 애니메이션 활용 (`shake`, `wiggle`, `fall`)
   - SVG 데코레이션 (밑줄, 별, 화살표)
   - 종이 텍스처, 연필 테두리

3. **접근성 고려**:
   - `aria-hidden="true"` (노이즈 오버레이)
   - `aria-label` (버튼)
   - 키보드 내비게이션 가능

4. **메모리 관리 우수**:
   - Object URL cleanup 완벽
   - Canvas 메모리 최적화

---

### ⚠ 개선 여지

1. **폰트 파일 누락**:
   - `public/fonts/` 디렉토리 비어있음
   - 설계에서는 Pretendard woff2 파일 요구
   - 현재는 Google Fonts 사용으로 문제없으나, 로컬 폰트 전환 시 필요

2. **광고 실제 ID 없음**:
   - `.env.local.example` 제공하지만 실제 ID 없음
   - 배포 시 설정 필요

3. **개인정보처리방침 페이지 미확인**:
   - `app/privacy/page.tsx` 존재하지만 내용 확인 필요

---

## 11. 최종 의견

### 배포 가능 여부: ⚠ **조건부 승인**

**조건**:
1. E2E 테스트 추가 (Critical)
2. OG 이미지 생성 및 추가 (Critical)

위 2가지 조건 충족 시 **MVP 배포 승인**.

---

### 총평

**강점**:
- Next.js 16 App Router 패턴 정확히 준수
- TypeScript 타입 안전성 우수
- Server/Client Components 분리 완벽
- Gemini API 통합 및 에러 처리 훌륭
- 손그림 감성 디자인 완성도 높음
- 메모리 관리 및 성능 최적화 우수

**약점**:
- E2E 테스트 전혀 없음 (가장 큰 문제)
- OG 이미지 누락 (바이럴 확산 저해)
- 이미지 다운로드 기능 미구현 (공유 편의성 저하)
- 일부 설계 문서와 구현 불일치 (대부분 개선된 변경)

**종합 평가**:
- 핵심 기능 완성도: **90%**
- 코드 품질: **85%**
- 배포 준비도: **70%** (E2E 테스트, OG 이미지 추가 시 95%)

**권고 사항**:
1. **즉시**: E2E 테스트 + OG 이미지 추가 (6시간 소요)
2. **1주 내**: 이미지 다운로드 + 에러 경계 + API 검증 (6시간 소요)
3. **2주 내**: 설계 문서 업데이트 + Lazy Loading + 공유 로직 리팩토링 (2.5시간 소요)

**예상 완전 완성 시점**: 현재 시점 기준 **+2주**

---

## 출력

**문서**: `docs/talmosang/talmosang/web-cto-review.md`
**작성일**: 2026-02-14
**리뷰어**: CTO

**다음 단계**:
1. E2E 테스트 추가 (Web Developer)
2. OG 이미지 생성 (Designer → Web Developer)
3. Critical/High 우선순위 개선 작업 (Web Developer)
4. Independent Reviewer 검증
