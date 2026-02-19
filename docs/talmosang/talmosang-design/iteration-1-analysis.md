# Iteration 1: Design Gap 수정 분석 보고서

## Iteration 정보

- **Feature**: talmosang-design
- **Platform**: Web (Next.js)
- **Iteration**: 1/5
- **시작 Match Rate**: 85%
- **목표 Match Rate**: 90%+
- **Status**: ✅ 완료

## Gap 분석 결과

총 5개 카테고리의 Gap이 `apps/web/talmosang/components/ResultSection.tsx` 파일에 집중되어 있었습니다.

### Gap 1: --font-nanum-pen 폰트 참조 3건

**문제점**:
- `fonts.ts`에서 Nanum Pen Script가 제거되고 Black Han Sans, Jua로 교체됨
- `ResultSection.tsx`에 `var(--font-nanum-pen)` 참조가 3곳 남아있음

**수정 위치**:
1. Line 172: 유명인 섹션 제목 (`미래의 당신은...`)
2. Line 207: 시뮬레이션 카드 제목 (`🔮 10년 뒤 그대의 상`)
3. Line 226: Placeholder 텍스트 (`미래의 상을 그리는 데 실패하였으나...`)

**적용된 수정**:
```tsx
// 변경 전
style={{ fontFamily: 'var(--font-nanum-pen)' }}

// 변경 후
style={{ fontFamily: 'var(--font-jua)' }}
```

**근거**: Al Murphy 스타일에서는 서브타이틀/본문에 `--font-jua`(Jua) 사용

---

### Gap 2: 크림 배경색 4건

**문제점**:
- Al Murphy 스타일에서는 크림색(#FFF8F0) 대신 원색 사용
- `bg-cream-light`, `bg-cream-dark` 등 크림 계열 클래스 4곳 남아있음

**수정 위치**:
1. Line 134: 모발 나이 섹션 배경 (`bg-cream-light`)
2. Line 185: 관리 팁 리스트 배경 (`bg-cream-light`)
3. Line 197: 종합 코멘트 배경 (`bg-cream-dark`)
4. Line 222: Placeholder 배경 (`bg-cream-dark`)

**적용된 수정**:
```tsx
// 1. 모발 나이 섹션
// 변경 전: bg-cream-light rounded-lg
// 변경 후: bg-white border-[6px] border-black rounded-[32px] shadow-[8px_8px_0_#000]

// 2. 관리 팁 리스트 (개별 카드로 재구성)
// 변경 전: <ul className="space-y-3 bg-cream-light p-5 rounded-lg">
// 변경 후: <ul className="space-y-3"> (각 li가 독립 카드)

// 3. 종합 코멘트
// 변경 전: bg-cream-dark border-2 border-dashed border-deep-blue rounded-xl
// 변경 후: bg-white border-[8px] border-black rounded-[32px] shadow-[16px_16px_0_#000]

// 4. Placeholder
// 변경 전: bg-cream-dark rounded-lg
// 변경 후: bg-white border-[6px] border-black rounded-[32px] shadow-[8px_8px_0_#000]
```

**근거**: Al Murphy 하드 그림자 스타일 규칙 (흰 배경 + 검정 테두리 + 하드 그림자)

---

### Gap 3: 유명인 말풍선 구 스타일

**문제점**:
- 현재: `border-2 border-deep-blue rounded-xl` (얇은 테두리, 파란색)
- 디자인: `border-[8px] border-black rounded-[48px] shadow-[12px_12px_0_#000]` (하드 그림자)

**수정 위치**:
- Line 176: `.speech-bubble` 클래스

**적용된 수정**:
```tsx
// 변경 전
<div className="speech-bubble bg-cream border-2 border-deep-blue rounded-xl p-5">

// 변경 후
<div className="speech-bubble bg-white border-[8px] border-black rounded-[48px] p-5 shadow-[12px_12px_0_#000]">
```

**근거**: Al Murphy 하드 그림자 규칙 (shadow-4: 12px)

---

### Gap 4: 종합 코멘트 구 스타일

**문제점**:
- 현재: `border-2 border-dashed border-deep-blue` (점선 테두리)
- 디자인: `border-[8px] border-black rounded-[32px] shadow-[16px_16px_0_#000]`

**수정 위치**:
- Line 197: `.comment` 섹션

**적용된 수정**:
```tsx
// 변경 전
<div className="comment mb-8 bg-cream-dark border-2 border-dashed border-deep-blue rounded-xl p-6 md:p-8">

// 변경 후
<div className="comment mb-8 bg-white border-[8px] border-black rounded-[32px] p-6 md:p-8 shadow-[16px_16px_0_#000]">
```

**근거**: Al Murphy 하드 그림자 규칙 (shadow-5: 16px)

---

### Gap 5: 관리 팁 리스트 스타일

**문제점**:
- 현재: 단순 리스트 형태 (전체가 하나의 배경색 영역)
- 디자인: 각 항목을 독립 카드 + 하드 그림자로 표시

**수정 위치**:
- Line 185-192: `.tips` 섹션 `<li>` 요소들

**적용된 수정**:
```tsx
// 변경 전
<ul className="space-y-3 bg-cream-light p-5 rounded-lg">
  <li key={index} className="flex items-start gap-3">
    <Check className="w-5 h-5 text-forest-green flex-shrink-0 mt-0.5" />
    <span className="text-sm md:text-base">{tip}</span>
  </li>
</ul>

// 변경 후
<ul className="space-y-3">
  <li key={index} className="flex items-start gap-3 bg-white border-[4px] border-black rounded-[24px] p-4 shadow-[6px_6px_0_#000]">
    <Check className="w-5 h-5 text-forest-green flex-shrink-0 mt-0.5" />
    <span className="text-sm md:text-base">{tip}</span>
  </li>
</ul>
```

**근거**: Al Murphy 하드 그림자 규칙 (shadow-2: 6px, 작은 카드용)

---

## Al Murphy 하드 그림자 스타일 규칙 정리

`globals.css`에 정의된 변수:

| 변수 | 값 | 용도 |
|------|-----|------|
| `--shadow-1` | `4px 4px 0 #000` | 작은 요소 (버튼 등) |
| `--shadow-2` | `6px 6px 0 #000` | 중소 카드 (관리 팁 항목) |
| `--shadow-3` | `8px 8px 0 #000` | 중간 카드 (모발 나이, placeholder) |
| `--shadow-4` | `12px 12px 0 #000` | 큰 카드 (유명인 말풍선, 등급 원형) |
| `--shadow-5` | `16px 16px 0 #000` | 가장 큰 카드 (종합 코멘트) |

**공통 규칙**:
- 테두리: 항상 검정색 (`border-black`)
- 테두리 두께: 4px~10px
- border-radius: 24px~48px
- 폰트: `--font-black-han` (타이틀), `--font-jua` (서브타이틀/본문)

---

## 빌드 검증

```bash
pnpm build
```

**결과**: ✅ 성공

```
Route (app)                                 Size  First Load JS
┌ ○ /                                    12.9 kB         118 kB
├ ○ /_not-found                            998 B         103 kB
├ ƒ /api/analyze                           125 B         102 kB
├ ƒ /api/generate-image                    125 B         102 kB
└ ○ /privacy                               163 B         105 kB
+ First Load JS shared by all             102 kB

○  (Static)   prerendered as static content
ƒ  (Dynamic)  server-rendered on demand
```

---

## 변경 파일 요약

### 수정된 파일 (1개)

- `apps/web/talmosang/components/ResultSection.tsx`
  - 5개 Gap 카테고리 모두 수정
  - 크림색 배경 제거 → 흰색 + 하드 그림자로 교체
  - Nanum Pen Script 폰트 제거 → Jua 폰트로 교체
  - 얇은/점선 테두리 제거 → 두꺼운 검정 테두리 + 하드 그림자로 교체
  - 관리 팁 리스트: 개별 카드 스타일로 재구성

---

## 다음 단계 제안

1. **재평가 필요**: Gap 수정 후 Match Rate 재측정 필요
   - 예상 Match Rate: 95%+ (5개 카테고리 모두 수정 완료)

2. **시각적 검증**: Dev 서버 실행 후 UI 확인
   ```bash
   cd /Users/lms/dev/repository/feature-talmosang-mvp/apps/web/talmosang
   pnpm dev
   ```

3. **추가 Gap 확인**: 다른 컴포넌트에서 유사한 스타일 이슈 검색
   - `HeroSection.tsx`
   - `UploadSection.tsx`
   - `globals.css` (크림색 변수 정의 제거 여부)

4. **완료 조건 확인**:
   - Match Rate >= 90% ✓ (예상)
   - 빌드 성공 ✓
   - 모든 Gap 해결 ✓

---

## Iteration 1 결과

**Status**: ✅ 성공

**수정 항목**: 5/5 완료
- [✓] Gap 1: --font-nanum-pen 참조 제거
- [✓] Gap 2: 크림 배경색 제거
- [✓] Gap 3: 유명인 말풍선 스타일 수정
- [✓] Gap 4: 종합 코멘트 스타일 수정
- [✓] Gap 5: 관리 팁 리스트 스타일 수정

**빌드 상태**: ✅ 성공

**예상 Match Rate**: 95%+

**소요 시간**: ~5분

---

_Report generated: 2026-02-14_
_Agent: pdca-iterator_
_Phase: Act (Iteration 1)_
