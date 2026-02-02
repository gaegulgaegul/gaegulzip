# gaegulzip

공통 기능은 한 번만 만들고, 비즈니스에 집중해서 제품을 찍어내는 하이브리드 모노레포.

## 왜 이 구조인가

- **인증, 푸시, 디자인 시스템** 같은 공통 기능을 제품마다 다시 만들기 싫었음
- 서버(Node.js)와 모바일(Flutter) 각각의 생태계 도구를 그대로 쓰면서 하나의 저장소로 관리
- 새 제품을 추가할 때 `apps/` 아래에 디렉토리 하나 만들면 공통 인프라를 즉시 사용 가능

## 아키텍처

```
gaegulzip/
├── apps/
│   ├── server/                 # 공통 백엔드 (Express + Drizzle + PostgreSQL)
│   │   └── src/modules/        # 기능 모듈 (auth, push-alert, ...)
│   └── mobile/                 # Flutter 모노레포 (Melos)
│       ├── apps/wowa/          # 제품: 크로스핏 WOD 알리미
│       ├── apps/[next-app]/    # 다음 제품은 여기에
│       └── packages/           # 공유 패키지
│           ├── core/           #   DI, 로깅, 유틸리티
│           ├── api/            #   Dio HTTP 클라이언트, Freezed 모델
│           └── design_system/  #   UI 컴포넌트, 테마
├── turbo.json                  # Turborepo (서버 빌드/테스트 오케스트레이션)
├── pnpm-workspace.yaml         # pnpm 워크스페이스 (Node.js)
└── melos.yaml                  # Melos (Flutter 패키지 관리)
```

### 핵심 설계 결정

| 결정 | 이유 |
|------|------|
| pnpm + Melos 하이브리드 | Node.js와 Flutter 각각 최적의 패키지 매니저 사용 |
| Express 5 (Controller/Service 패턴 없음) | 미들웨어 함수면 충분. 복잡해지면 그때 분리 (YAGNI) |
| Drizzle ORM + FK 없음 | 앱 레벨에서 관계 관리. DB 마이그레이션 유연성 확보 |
| Flutter packages/ 계층 분리 | core → api, design_system → app 단방향 의존. 순환 의존 원천 차단 |
| GetX 통일 | 상태 관리 + DI + 라우팅을 하나로. 패키지 간 일관성 |
| Turborepo | 서버 빌드/테스트 캐싱과 병렬 실행 |

### 의존성 방향 (모바일)

```
core (기반 - 의존성 없음)
  ↑
  ├── api (HTTP, 데이터 모델)
  ├── design_system (UI 컴포넌트)
  └── wowa app (제품 로직)
```

## 빠른 시작

```bash
# 서버
pnpm install
cp apps/server/.env.example apps/server/.env   # 환경변수 설정
pnpm dev:server

# 모바일
cd apps/mobile && melos bootstrap
cd apps/wowa && flutter run
```

## 주요 명령어

### 서버

```bash
pnpm dev:server              # 개발 서버 (hot reload)
pnpm build:server            # 프로덕션 빌드
pnpm test:server             # 테스트 (Vitest)
```

```bash
# apps/server 내에서
pnpm db:generate             # 마이그레이션 생성
pnpm db:migrate              # 마이그레이션 적용
pnpm db:push                 # 스키마 직접 푸시 (개발용)
```

### 모바일

```bash
pnpm mobile:bootstrap        # 의존성 설치 (flutter pub get 대신)
pnpm mobile:generate         # 코드 생성 (Freezed, json_serializable)
pnpm mobile:clean            # 빌드 아티팩트 정리
```

```bash
# apps/mobile 내에서
melos generate:watch         # 코드 생성 watch 모드
melos analyze                # 전체 패키지 정적 분석
```

## 새 제품 추가하는 법

### 모바일 앱

1. `apps/mobile/apps/` 아래에 Flutter 프로젝트 생성
2. `pubspec.yaml`에 공유 패키지 path 의존성 추가:
   ```yaml
   dependencies:
     core:
       path: ../../packages/core
     api:
       path: ../../packages/api
     design_system:
       path: ../../packages/design_system
   ```
3. `melos.yaml`의 packages 경로에 이미 `apps/**`가 포함되어 있으므로 `melos bootstrap`만 실행

### 서버 모듈

1. `apps/server/src/modules/` 아래에 디렉토리 생성
2. `index.ts` (라우터), `handlers.ts` (핸들러), `schema.ts` (DB 스키마) 작성
3. `app.ts`에서 라우터 등록

## 배포

- **서버**: Docker 멀티스테이지 빌드 → Render (싱가포르, free tier)
- **헬스체크**: `GET /health`
- **API 문서**: `GET /api-docs` (Swagger UI)
- 환경변수(`DATABASE_URL`, `JWT_SECRET_FALLBACK` 등)는 Render 대시보드에서 설정

## 환경변수

### 서버 (`apps/server/.env`)

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `PORT` | 서버 포트 | 3001 |
| `DATABASE_URL` | PostgreSQL 연결 문자열 | - |
| `JWT_SECRET_FALLBACK` | JWT 시크릿 | - |
| `SUPABASE_URL` | Supabase 프로젝트 URL | - |
| `SUPABASE_ANON_KEY` | Supabase anon 키 | - |
| `LOG_LEVEL` | 로그 레벨 | info |

## 기술 스택

| 영역 | 기술 |
|------|------|
| 서버 런타임 | Node.js + TypeScript (ES2022) |
| 서버 프레임워크 | Express 5.x |
| ORM / DB | Drizzle ORM + PostgreSQL (Supabase) |
| 모바일 | Flutter (SDK >=3.10.7) |
| 상태 관리 | GetX |
| HTTP 클라이언트 | Dio (api 패키지 격리) |
| 코드 생성 | Freezed + json_serializable |
| 모노레포 | pnpm + Turborepo (서버) / Melos (모바일) |
| 테스트 | Vitest (서버만. 모바일은 테스트 안 함) |
| 배포 | Docker + Render |

## 현재 제품

- **[WOWA (오와)](docs/wowa/prd.md)** — 크로스핏 WOD 알리미. 박스 구성원 누구나 WOD를 등록·수정하고, 합의된 WOD를 기준으로 기록과 선택을 돕는 앱
