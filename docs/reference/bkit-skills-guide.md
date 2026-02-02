# bkit Skills 가이드 (gaegulzip 프로젝트)

> **bkit PDCA 워크플로우** + **gaegulzip 커스텀 agents** 통합

---

## 📑 빠른 시작

### PDCA 워크플로우

```bash
# Server 개발
/pdca research user-management    # 연구 (복잡한 기능 시)
/pdca plan user-management        # 계획 (Product Owner)
/pdca design user-management      # 설계 (CTO 라우팅 → Server 자동 결정 → Tech Lead)
/pdca do user-management          # 구현 (Node Developer)
/pdca analyze user-management     # 검증 (Gap Detector + Independent Reviewer)
/pdca iterate user-management     # 자동 수정 (Match Rate < 90% 시)
/pdca report user-management      # 리포트

# Mobile 개발
/pdca plan weather-screen         # 계획 (Product Owner)
/pdca design weather-screen       # 설계 (CTO 라우팅 → Mobile 자동 결정 → UI/UX + Tech Lead)
/pdca do weather-screen           # 구현 (Flutter Developer)
/pdca analyze weather-screen      # 검증
```

---

## PDCA 단계별 Agent 매핑

### Server

| PDCA 단계 | 명령어 | 실행 Agent | 결과물 |
|-----------|--------|-----------|--------|
| Research | `/pdca research` | `bkit/research-director` | `docs/pdca/00-research/{feature}.research.md` |
| Plan | `/pdca plan` | `product-owner` | `docs/server/{feature}/user-story.md` |
| **CTO 라우팅** | `/pdca design` (자동 선행) | `cto` ⓪ 플랫폼 라우팅 | `.pdca-status.json` (platform 필드) |
| Design | `/pdca design` | `server/tech-lead` | `docs/server/{feature}/brief.md` |
| Do | `/pdca do` | `server/node-developer` | `src/modules/{feature}/*` + tests |
| Check | `/pdca analyze` | `bkit/gap-detector` → `independent-reviewer` | `docs/server/{feature}/review-report.md` |
| Act | `/pdca iterate` | `bkit/pdca-iterator` | 자동 수정 코드 |
| Report | `/pdca report` | `bkit/report-generator` | `docs/04-reports/{feature}-completion-report.md` |

### Mobile

| PDCA 단계 | 명령어 | 실행 Agent | 결과물 |
|-----------|--------|-----------|--------|
| Research | `/pdca research` | `bkit/research-director` | `docs/pdca/00-research/{feature}.research.md` |
| Plan | `/pdca plan` | `product-owner` | `docs/flutter/{feature}/user-stories.md` |
| **CTO 라우팅** | `/pdca design` (자동 선행) | `cto` ⓪ 플랫폼 라우팅 | `.pdca-status.json` (platform 필드) |
| Design | `/pdca design` | `mobile/ui-ux-designer` → `mobile/tech-lead` | `design-spec.md` + `docs/flutter/{feature}/brief.md` |
| Do | `/pdca do` | `mobile/flutter-developer` | `apps/wowa/lib/app/modules/{feature}/*` |
| Check | `/pdca analyze` | `bkit/gap-detector` → `independent-reviewer` | `docs/flutter/{feature}/review-report.md` |
| Act | `/pdca iterate` | `bkit/pdca-iterator` | 자동 수정 코드 |
| Report | `/pdca report` | `bkit/report-generator` | `docs/04-reports/{feature}-completion-report.md` |

---

## gaegulzip 커스텀 Agents

### 공통

#### Product Owner
- **역할**: 사용자 스토리 작성
- **Server**: API 엔드포인트 중심
- **Mobile**: UI/UX 중심

#### CTO
- **역할**: 설계 승인, 작업 분배(Mobile 핵심), 통합 리뷰
- **도구**: Supabase MCP(읽기 전용), interactive-review MCP

#### Independent Reviewer (Fresh Eyes)
- **역할**: 구현 과정 모르고 최종 검증
- **원칙**: brief.md만 참조, 과거 컨텍스트 참조 금지
- **Mobile 도구**: `npx -y flutter-test-mcp`, `npx -y @mobilenext/mobile-mcp`

---

### Server Agents

#### Tech Lead
- 기술 아키텍처 + DB 스키마 설계
- `brief.md` 작성 (Architecture, DB Schema, API Plan, Test Scenarios)
- Express 미들웨어 기반, Drizzle ORM, TDD

#### Schema Designer
- Drizzle ORM 스키마 작성 (`schema.ts`)

#### Migration Generator
- `pnpm drizzle-kit generate` 실행
- 사용자가 직접 마이그레이션 실행

#### Node Developer
- handlers, router, tests 작성
- TDD 사이클, Feature 단위 병렬 작업 가능

---

### Mobile Agents

#### UI/UX Designer
- `design-spec.md` 작성
- Material Design 3, 화면 레이아웃, 색상, 타이포그래피

#### Tech Lead (Mobile)
- GetX 상태 관리 설계
- `brief.md` 작성 (Controller, API 통합, Routing)

#### Senior Developer
- API 모델(Freezed), Controller, Binding 작성

#### Flutter Developer
- 전체 스택(API 모델 → View) 담당
- Module 단위 병렬 작업 가능

#### Design Specialist
- Design System 재사용 컴포넌트 작성 (`packages/design_system/`)

---

## 커스텀 Skills (오버라이드)

### api-documenter
- **용도**: Express + Drizzle ORM → OpenAPI 3.0 문서 자동 생성
- **사용**: `/api-documenter users`
- **결과**: `docs/openapi.yaml`

### test-scenario-generator
- **용도**: Flutter 테스트 시나리오 자동 생성
- **사용**: `/test-scenario-generator`
- **결과**: `test-scenarios.md` (Given-When-Then + FlutterTestMcp + @mobilenext/mobile-mcp)

---

## 실전 예시

### Server API 개발

```bash
# 1. 계획
/pdca plan user-management
→ Product Owner: user-story.md

# 2. 설계 (CTO 라우팅 자동 실행)
/pdca design user-management
→ CTO ⓪: 플랫폼 라우팅 → "Server" 결정 (API 키워드 매칭)
→ Tech Lead: brief.md

# 3. 구현
/pdca do user-management
→ Schema Designer + Migration Generator (병렬)
→ 사용자: pnpm drizzle-kit push
→ Node Developer: handlers.ts + tests

# 4. 검증
/pdca analyze user-management
→ Gap Detector: Match Rate 계산
→ Independent Reviewer: Fresh Eyes 검증

# 5. 개선 (필요 시)
/pdca iterate user-management
→ 자동 수정 (최대 5회)

# 6. 문서화
/api-documenter users
```

---

### Mobile 화면 개발

```bash
# 1. 계획
/pdca plan weather-screen
→ Product Owner: user-stories.md

# 2. 설계 (CTO 라우팅 자동 실행)
/pdca design weather-screen
→ CTO ⓪: 플랫폼 라우팅 → "Mobile" 결정 (화면 키워드 매칭)
→ UI/UX Designer: design-spec.md
→ Tech Lead: brief.md (GetX 설계)

# 3. 구현
/pdca do weather-screen
→ Senior Developer: API 모델, Controller, Binding
→ Flutter Developer: View, UI 위젯, Routing

# 4. 검증
/pdca analyze weather-screen
→ Gap Detector: Match Rate
→ Independent Reviewer: flutter run + FlutterTestMcp + @mobilenext/mobile-mcp

# 5. 테스트 시나리오 (선택)
/test-scenario-generator
```

---

### Fullstack 기능 개발 (증분 개발)

```bash
# 1. 계획
/pdca plan user-profile
→ Product Owner: user-story.md + user-stories.md

# 2. 설계 (CTO 라우팅 자동 실행)
/pdca design user-profile
→ CTO ⓪: 기존 코드 분석 → Server API 존재, Mobile 신규 → "Fullstack" 결정
→ Server Tech Lead: brief.md (API 수정)
→ Mobile UI/UX Designer + Tech Lead: design-spec.md + brief.md

# 3. 구현 (양쪽 순차)
/pdca do user-profile
→ Server: Node Developer (API 수정)
→ Mobile: Flutter Developer (새 화면)

# 4. 검증
/pdca analyze user-profile
→ 양쪽 모두 Gap 분석 + Fresh Eyes 검증
```

---

## 주요 특징

### 1. 자동 플랫폼 라우팅 (CTO ⓪)
- Plan(PO) → Design 사이에서 Server/Mobile/Fullstack 자동 결정
- 4단계 신뢰도: 명시적 키워드 → claude-mem 학습 → 추정+확인 → 분석+확인
- 증분 개발 지원: 한쪽이 이미 있을 때 API 분석 후 확장 여부 판단
- 결정 결과를 claude-mem에 저장하여 다음 세션 자동 선택

### 2. Research 단계 (자동 트리거)
- 복잡한 기능 감지 시 자동 실행
- `bkit/research-director` 실행
- Tier 1-3 (복잡도별 연구 심화)

### 3. 병렬 작업 지원
- Server: Feature 단위 병렬 개발
- Mobile: Module 단위 병렬 개발
- CTO가 work-plan.md로 작업 분배

### 4. Fresh Eyes 검증
- Independent Reviewer가 구현 과정 모르고 검증
- brief.md만 참조, 선입견 없는 검증

### 5. TDD (Server) vs MCP 도구 (Mobile)
- Server: 단위 테스트 작성 (Red-Green-Refactor)
- Mobile: 테스트 코드 작성 안 함, MCP 도구로 검증

---

## bkit 기본 vs gaegulzip

| 구분 | bkit 기본 | gaegulzip |
|------|----------|-----------|
| 워크플로우 | PDCA | PDCA (동일) |
| Research | ❌ | ✅ (복잡도 감지) |
| Plan | bkit agents | `product-owner` |
| **CTO 라우팅** | ❌ | ✅ (4단계 신뢰도 기반 자동 플랫폼 결정) |
| Design | bkit agents | `tech-lead` / `ui-ux-designer` + `tech-lead` |
| Do | bkit agents | `node-developer` / `flutter-developer` |
| Check | `gap-detector` | `gap-detector` + `independent-reviewer` (Fresh Eyes) |
| 병렬 작업 | ❌ | ✅ (Feature/Module 단위) |
| Mobile 테스트 | 테스트 코드 | MCP 도구 (FlutterTestMcp, @mobilenext/mobile-mcp) |

---

## 참고 자료

- **bkit GitHub**: [popup-studio-ai/bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code)
- **프로젝트 CLAUDE.md**: [../CLAUDE.md](../../CLAUDE.md)
- **Server 가이드**: [../apps/server/CLAUDE.md](../../apps/server/CLAUDE.md)
- **Mobile 가이드**: [../apps/mobile/CLAUDE.md](../../apps/mobile/CLAUDE.md)
- **설정 파일**: [../bkit.config.json](../../bkit.config.json)

---

**마지막 업데이트:** 2026-02-03

**변경 이력:**
- 2026-02-03: CTO ⓪ 플랫폼 라우팅 추가 (Plan → Design 사이 자동 Server/Mobile/Fullstack 결정)
- 2026-02-02: 초기 작성
