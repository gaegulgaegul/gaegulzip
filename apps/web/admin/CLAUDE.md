# Web Admin CLAUDE.md

gaegulzip-admin — Next.js 16 어드민 대시보드 (shadcn/ui + Tailwind CSS v4)

## Commands

```bash
pnpm dev                # Development (localhost:3000)
pnpm build              # Production build
pnpm start              # Run production build
pnpm lint               # ESLint
pnpm test:e2e           # Playwright E2E tests
pnpm test:e2e:ui        # Playwright UI mode
```

## Environment Variables

Required in `.env.local`:
- `NEXT_PUBLIC_SERVER_URL` — Express 백엔드 URL (health check + API 호출)

## Testing Policy

**Unit/Component 테스트 작성 금지** — Playwright E2E 테스트만 사용

- 테스트 디렉토리: `./e2e/`
- 설정: `playwright.config.ts` (Chromium only, baseURL: `http://localhost:3000`)
- CI: `forbidOnly`, retry 2회, worker 1개

## Project Structure

```
src/
├── app/
│   ├── layout.tsx              # Root layout (Geist 폰트, 한국어)
│   ├── page.tsx                # / 랜딩 페이지
│   ├── globals.css             # Tailwind v4 + shadcn 테마 변수
│   ├── (auth)/                 # 인증 라우트 그룹
│   │   ├── layout.tsx          # Auth layout
│   │   └── login/page.tsx      # 로그인 페이지
│   ├── (dashboard)/            # 보호된 대시보드 라우트 그룹
│   │   ├── layout.tsx          # Sidebar + Main 레이아웃
│   │   ├── dashboard/page.tsx  # 대시보드 메인
│   │   ├── users/page.tsx      # 사용자 관리
│   │   └── push/page.tsx       # 푸시 알림 관리
│   └── api/auth/login/
│       └── route.ts            # POST /api/auth/login
├── components/
│   ├── app-sidebar.tsx         # 사이드바 네비게이션 (Client Component)
│   └── ui/                     # shadcn/ui 컴포넌트 (수정 금지)
├── lib/
│   ├── auth.ts                 # 비밀번호 검증, 세션 토큰 생성
│   └── utils.ts                # cn() 유틸리티 (clsx + tailwind-merge)
├── middleware.ts               # 인증 미들웨어 (보호 경로 + 리디렉트)
└── instrumentation.ts          # 서버 health check (슬립 방지)
```

## Tech Stack

- **Next.js 16** App Router (React 19, RSC)
- **shadcn/ui** new-york 스타일 + Lucide 아이콘
- **Tailwind CSS v4** + CSS 변수 기반 테마 (oklch 색상)
- **Playwright** E2E 테스트

## Architecture Conventions

### Route Groups
- `(auth)` — 비인증 경로 (로그인 페이지)
- `(dashboard)` — 인증 필요 경로 (sidebar 레이아웃 공유)

### 인증 흐름
```
비밀번호 → POST /api/auth/login → SHA-256 비교 → HttpOnly 쿠키 (7일)
보호 경로 접근 → middleware.ts → 쿠키 확인 → 통과 or /login 리디렉트
```

- 보호 경로: `/dashboard`, `/users`, `/push`
- 세션: `admin-session` HttpOnly 쿠키
- 비밀번호 해시: `lib/auth.ts` 내 상수 (환경변수 불필요)

### 새 페이지 추가 시
1. `src/app/(dashboard)/[새경로]/page.tsx` 생성
2. `middleware.ts`의 `protectedPaths` 배열에 경로 추가
3. `components/app-sidebar.tsx`의 `navItems`에 메뉴 항목 추가

## shadcn/ui

- 스타일: `new-york`, RSC 활성화
- 설정: `components.json`
- UI 컴포넌트 경로: `src/components/ui/`
- `ui/` 디렉토리 내 파일은 직접 수정하지 않음 — `npx shadcn@latest add [component]`로 추가

### 설치된 컴포넌트
`button`, `card`, `input`, `label`, `separator`, `sheet`

## Path Aliases

`@/*` → `./src/*` (tsconfig.json paths)

## Deployment

- Vercel Hobby 플랜 (Serverless Function 12개 제한)
- 비상업적 용도

## Important Notes

- **Unit/Component 테스트 금지** — Playwright E2E만 사용
- **shadcn/ui 컴포넌트 직접 수정 금지** — 커스터마이징은 래퍼 컴포넌트로
- **`@` import alias 사용** — 상대 경로 대신 `@/components`, `@/lib` 사용
- **Server Component 기본** — Client Component 필요 시 `"use client"` 명시
