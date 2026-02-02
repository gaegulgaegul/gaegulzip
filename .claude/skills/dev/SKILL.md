---
name: dev
description: 통합 개발 팀 워크플로우. Server(Node.js/Express), Mobile(Flutter/GetX), Fullstack 모두 지원. 플랫폼 자동 감지 또는 명시적 지정 가능. "/dev '기능 설명'" 또는 "/dev server|mobile|fullstack '기능 설명'" 형식으로 호출.
---

# Dev - 통합 개발 팀 워크플로우

## 개요

`/dev` 스킬은 Plan 모드와 멀티 에이전트 팀 워크플로우를 사용하여 전체 기능 개발 생명주기를 자동화합니다.

**지원 플랫폼**:
- **Server**: Node.js/Express/Drizzle ORM (TDD 기반)
- **Mobile**: Flutter/GetX/Melos 모노레포
- **Fullstack**: Server + Mobile 동시 개발

**주요 특징**:
- 모든 커뮤니케이션은 한국어로 진행
- Plan 모드에서 요구사항 분석, 기술 설계, 작업 분배 처리
- 플랫폼별 서브에이전트 자동 라우팅
- Fresh Eyes 검증

---

## 플랫폼 감지

### 명시적 지정
```
/dev server "Refresh Token 추가"
/dev mobile "날씨 정보 화면"
/dev fullstack "소셜 로그인"
```

### 자동 감지
`/dev "기능 설명"` 형식일 때 키워드로 플랫폼을 자동 판단:

| 플랫폼 | 키워드 |
|--------|--------|
| **Server** | API, endpoint, handler, database, schema, migration, 서버, 백엔드, 인증 토큰 |
| **Mobile** | screen, widget, UI, view, controller, 화면, 앱, 네비게이션, 디자인 |
| **Fullstack** | 양쪽 키워드 모두 포함, 또는: 로그인, 인증, auth, 소셜 로그인 |

**판단 불가 시**: AskUserQuestion으로 플랫폼 확인

---

## 워크플로우

다음 단계를 순차적으로 실행하되, 오류 발생 시 중단합니다.

### Step 1: 기능명 추출 + 플랫폼 감지

사용자 입력에서:
1. **플랫폼** 결정 (명시적 또는 자동 감지)
2. **기능명** 추출 (kebab-case, 30자 이내, 한글/특수문자 제거)

**변환 예시:**
- "Refresh Token 추가" → `refresh-token` (server)
- "날씨 정보 화면" → `weather-info` (mobile)
- "소셜 로그인" → `social-login` (fullstack)

### Step 2-4: Plan 모드 - 요구사항 분석, 기술 설계, 작업 분배

EnterPlanMode를 호출하여 Plan 모드로 진입합니다.

**Plan 모드에서 수행할 작업:**

#### 3-1. 요구사항 분석 (Product Owner 역할)

플랫폼별 product-owner 에이전트 역할로 직접 분석:

**Server**:
- 사용자 스토리 (As a / I want / So that)
- RESTful API 명세 (method, path, request/response)
- 수락 기준, 엣지 케이스
- 출력: `docs/server/[feature]/user-story.md`

**Mobile**:
- 사용자 스토리 + 사용자 시나리오 (step-by-step)
- UI/UX 요구사항, 필요한 데이터
- 비기능 요구사항 (성능, 접근성)
- 출력: `docs/flutter/[feature]/user-stories.md`

**Fullstack**:
- Server + Mobile 양쪽 모두 작성
- 출력: `docs/fullstack/[feature]/user-story.md` + `docs/fullstack/[feature]/user-stories.md`

#### 3-2. [Mobile/Fullstack] UI/UX 디자인

Mobile 또는 Fullstack인 경우 디자인 명세 작성:
- 화면 레이아웃, 색상, 타이포그래피
- 인터랙션 패턴, 상태 변화
- Material Design 3 컴포넌트
- 출력: `docs/flutter/[feature]/design-spec.md` (또는 `docs/fullstack/[feature]/design-spec.md`)

#### 3-3. 기술 설계 (Tech Lead 역할)

**Server**:
- 아키텍처 설계 (Express 미들웨어 기반)
- DB 스키마 설계 (Drizzle ORM)
- 보안 메커니즘, 에러 처리 전략
- 출력: `docs/server/[feature]/brief.md`

**Mobile**:
- GetX Controller 설계, 위젯 트리
- 모노레포 패키지 배치 (core/api/design_system/wowa)
- 라우팅, 바인딩 구조
- 출력: `docs/flutter/[feature]/brief.md`

**Fullstack**:
- 양쪽 모두 설계
- 출력: `docs/fullstack/[feature]/brief-server.md` + `docs/fullstack/[feature]/brief-mobile.md`

#### 3-4. CTO 설계 승인

CLAUDE.md 표준 준수 확인:

**Server 체크리스트**:
- Express 미들웨어 기반, Controller/Service 패턴 사용 안 함
- Drizzle ORM 적절히 사용, TDD 사이클
- JSDoc 주석 (한국어), `src/modules/[feature]/` 구조

**Mobile 체크리스트**:
- GetX Controller/View/Binding 분리
- 모노레포 구조, const 최적화, Obx 범위 최소화
- design-spec.md와 brief.md 정합성

#### 3-5. 작업 분배 (CTO 역할)

**Server** (선택적 - 복잡한 경우에만):
- Feature 단위 분리, Node Developer 분배
- 출력: `docs/server/[feature]/work-plan.md`

**Mobile** (핵심):
- 모듈 단위 분할, Flutter Developer 분배
- Controller-View 연결점 정의
- 의존성/병렬 실행 구분
- 출력: `docs/flutter/[feature]/work-plan.md`

**Fullstack**:
- 양쪽 통합 작업 계획
- 출력: `docs/fullstack/[feature]/work-plan.md`

**Plan 모드 종료:**
- ExitPlanMode 호출
- 사용자에게 계획 승인 요청

**중요:**
- 모든 커뮤니케이션은 한국어로 진행
- CLAUDE.md 가이드 준수
- 실제 에이전트를 호출하지 않고 Plan 모드에서 직접 분석/설계

---

### Step 5: 구현 (플랫폼별 분기)

#### [SERVER] Node Developer

`server/node-developer` 서브에이전트를 실행:

```
Task(subagent_type="server/node-developer", prompt="""
기능 구현해줘 (TDD).
brief는 docs/server/[feature]/brief.md에 있어.
handlers + router + tests를 모두 구현해줘.
""")
```

**출력:**
- `apps/server/src/modules/[module]/handlers.ts`
- `apps/server/src/modules/[module]/index.ts` (Router)
- `apps/server/src/modules/[module]/schema.ts` (필요시)
- `apps/server/tests/unit/[module]/handlers.test.ts`

**병렬:** 여러 feature가 있으면 여러 Node Developer를 동시 실행

#### [MOBILE] Flutter Developer

`mobile/flutter-developer` 서브에이전트를 실행:

```
Task(subagent_type="mobile/flutter-developer", prompt="""
기능 구현해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.
Models + Client + Controller + View + Binding + Routing을 모두 구현해줘.
""")
```

**출력:**
- `apps/mobile/packages/api/lib/src/models/[feature]_model.dart`
- `apps/mobile/packages/api/lib/src/clients/[feature]_client.dart`
- `apps/mobile/apps/wowa/lib/app/modules/[feature]/controllers/`
- `apps/mobile/apps/wowa/lib/app/modules/[feature]/views/`
- `apps/mobile/apps/wowa/lib/app/modules/[feature]/bindings/`

**병렬:** 여러 모듈이 있으면 여러 Flutter Developer를 동시 실행

#### [FULLSTACK] 양쪽 동시 실행

단일 메시지에 Server + Mobile Task를 모두 호출하여 병렬 실행

### Step 6: 구현 요약

사용자에게 구현 완료 요약을 제시합니다.

### Step 7: 사용자 승인 (리뷰 단계)

```
구현이 완료되었습니다.
리뷰 및 문서화를 진행할까요?
```

**선택지:**
- "승인 - 계속 진행" (Step 8로)
- "수정 필요" (적절한 단계로 복귀)

---

### Step 8-9: 검증 및 문서화 (플랫폼별 분기)

#### [SERVER]

**Step 8s: Independent Reviewer**
```
Task(subagent_type="independent-reviewer", prompt="""
Server 모드로 검증해줘.
brief는 docs/server/[feature]/brief.md에 있어.
구현된 코드가 요구사항을 충족하는지 Fresh Eyes로 검증해줘.
""")
```
출력: `docs/server/[feature]/review-report.md`

**Step 9s: API Documenter**
```
Skill(api-documenter)
```
출력: `docs/server/[feature]/api-doc.yaml`

#### [MOBILE]

**Step 8m: Test Scenario Generator**
```
Skill(test-scenario-generator)
```
출력: `docs/flutter/[feature]/test-scenarios.md`

**Step 9m: Independent Reviewer**
```
Task(subagent_type="independent-reviewer", prompt="""
Mobile 모드로 검증해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.
test-scenarios는 docs/flutter/[feature]/test-scenarios.md에 있어.
구현이 요구사항을 충족하는지 Fresh Eyes로 검증해줘.
""")
```
출력: `docs/flutter/[feature]/review-report.md`

#### [FULLSTACK]

Server + Mobile 검증을 병렬 실행, 이후 cross-platform 연동 확인

---

### Step 10: 최종 사용자 승인

```
리뷰 및 문서화가 완료되었습니다.
작업을 완료할까요?
```

### Step 11: 완료

최종 완료 요약 제시 (생성된 파일 목록 + 다음 단계 안내)

**Server 다음 단계:**
1. `pnpm test` (테스트 실행)
2. `pnpm drizzle-kit migrate` (마이그레이션, 필요시)
3. `pnpm dev` (서버 실행)
4. API 문서 확인

**Mobile 다음 단계:**
1. `melos bootstrap` (의존성)
2. `melos generate` (코드 생성)
3. `flutter run` (앱 실행)

---

## 에러 처리

단계 실패 시:
1. 즉시 워크플로우 중단
2. 실패한 단계명과 함께 사용자에게 에러 보고
3. 재시도 또는 중단 여부 확인

---

## 출력 디렉토리 구조

```
docs/
├── server/[feature]/
│   ├── user-story.md
│   ├── brief.md
│   ├── work-plan.md (선택적)
│   ├── review-report.md
│   └── api-doc.yaml
├── flutter/[feature]/
│   ├── user-stories.md
│   ├── design-spec.md
│   ├── brief.md
│   ├── work-plan.md
│   ├── test-scenarios.md
│   └── review-report.md
└── fullstack/[feature]/
    ├── user-story.md (server)
    ├── user-stories.md (mobile)
    ├── design-spec.md (mobile)
    ├── brief-server.md
    ├── brief-mobile.md
    ├── work-plan.md (combined)
    ├── test-scenarios.md (mobile)
    ├── review-report.md
    └── api-doc.yaml (server)
```

---

## 사용 예시

**예시 1: Server**
```
/dev server "Refresh Token 추가"

1. refresh-token (server)
2-4. Plan 모드 → user-story.md, brief.md
5. Node Developer → handlers + router + tests (TDD)
6-7. 구현 요약 → 사용자 승인
8. Independent Reviewer → review-report.md
9. API Documenter → api-doc.yaml
10-11. 최종 승인 → 완료
```

**예시 2: Mobile**
```
/dev mobile "날씨 정보 화면"

1. weather-info (mobile)
2-4. Plan 모드 → user-stories.md, design-spec.md, brief.md, work-plan.md
5. Flutter Developer → Models + Client + Controller + View + Binding + Routing
6-7. 구현 요약 → 사용자 승인
8. Test Scenario Generator → test-scenarios.md
9. Independent Reviewer → review-report.md
10-11. 최종 승인 → 완료
```

**예시 3: Fullstack**
```
/dev fullstack "소셜 로그인"

1. social-login (fullstack)
2-4. Plan 모드 → 양쪽 문서 모두 작성
5. Node Developer + Flutter Developer 병렬 실행
6-7. 구현 요약 → 사용자 승인
8-9. 양쪽 검증 병렬 실행
10-11. 최종 승인 → 완료
```

**예시 4: 자동 감지**
```
/dev "사용자 프로필 조회 API"
→ "API" 키워드 감지 → Server 모드 자동 선택
```

---

## 중요 사항

### Plan 모드
- Step 2-4에서는 EnterPlanMode를 호출하여 계획 수립
- 요구사항 분석, 기술 설계, 작업 분배를 Plan 모드에서 직접 수행
- ExitPlanMode로 사용자 승인 요청
- 모든 문서 작성은 한국어로 진행

### 서브에이전트 라우팅
- **Server**: `server/node-developer`, `server/tech-lead`, `server/schema-designer`
- **Mobile**: `mobile/flutter-developer`, `mobile/tech-lead`, `mobile/ui-ux-designer`, `mobile/design-specialist`
- **Shared**: `product-owner`, `cto`, `independent-reviewer` (플랫폼 컨텍스트 전달)
- Task 도구를 적절한 subagent_type과 함께 사용

### CLAUDE.md 준수
**Server**:
- 예외 처리: AppException 계층 구조
- API Response: camelCase, null 처리, ISO-8601
- 로깅: Domain Probe 패턴
- DB 설계: 테이블/컬럼 주석, FK 제약조건 제거
- JSDoc: 모든 코드에 한국어 주석

**Mobile**:
- GetX: Controller/View/Binding 분리
- const 최적화, Obx 범위 최소화
- Freezed + json_serializable 모델
- Melos 모노레포 워크플로우
- 테스트 코드 작성 금지
