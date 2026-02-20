# 기술 명세: SEO 최적화 (탈모상)

## 개요

이 기능은 **UI 변경이 없는 순수 기술적 SEO 작업**입니다. 비주얼 디자인 변경 사항은 없으며, 검색엔진 색인 최적화 및 소셜 공유 미리보기 개선을 위한 메타데이터/파일 설정이 전부입니다.

---

## 구현할 SEO 요소 목록

### 1. robots.ts (신규 파일)

- **경로**: `apps/web/talmosang/app/robots.ts`
- **역할**: 검색엔진 크롤러가 크롤링 가능한 범위를 명시
- **허용**: 메인 페이지(`/`), 개인정보처리방침(`/privacy`)
- **차단**: API 라우트 전체(`/api/*`)

### 2. sitemap.ts (신규 파일)

- **경로**: `apps/web/talmosang/app/sitemap.ts`
- **역할**: 검색엔진에 페이지 목록과 우선순위를 전달
- **포함 페이지**: `/`, `/privacy`
- **동적 결과 페이지 제외**: 결과가 서버에 저장되지 않아 고유 URL 없음

### 3. JSON-LD 구조화 데이터 (layout.tsx 수정)

- **역할**: 검색엔진이 탈모상의 서비스 유형을 의미론적으로 이해하도록 지원
- **타입**: `WebApplication`
- **삽입 위치**: `layout.tsx`의 `<head>` 내 `<script type="application/ld+json">`

### 4. layout.tsx 메타데이터 개선

- **canonical URL 추가**: `alternates.canonical` 설정
- **og:locale 추가**: `ko_KR`로 설정하여 한국어 서비스 명시
- **og:image URL 개선**: 상대 경로 `/og-image.png`는 `metadataBase`와 결합되어 절대 URL로 처리됨 (현재 동작 확인)
- **description 보강**: 클릭 욕구를 자극하는 문구로 개선
- **keywords 보강**: 더 많은 검색 키워드 추가

### 5. privacy/page.tsx 메타데이터 보강

- **canonical URL 추가**: `/privacy` 페이지 독립 canonical
- **og:title, og:description 추가**: 소셜 공유 대응

---

## 파일 변경 범위

| 파일 | 변경 유형 | 내용 |
|------|-----------|------|
| `app/robots.ts` | 신규 생성 | 크롤링 정책 정의 |
| `app/sitemap.ts` | 신규 생성 | 사이트맵 정의 |
| `app/layout.tsx` | 수정 | JSON-LD 추가, 메타데이터 개선 |
| `app/privacy/page.tsx` | 수정 | canonical, OG 메타데이터 추가 |

---

## 비시각적 작업 확인

- 브라우저 렌더링 화면에 변화 없음
- 사용자 인터랙션 변경 없음
- 스타일링 변경 없음
- 컴포넌트 추가/삭제 없음
