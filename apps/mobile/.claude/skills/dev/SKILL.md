---
name: dev
description: Flutter 기능 개발 자동화 워크플로우. 요구사항 분석부터 UI/UX 디자인, 구현, 테스팅, 리뷰까지 전체 개발 프로세스를 자동화합니다. Plan 모드에서 설계(Product Owner → UI/UX Designer → Tech Lead → CTO 승인 → 작업 분배)를 완료한 후, 사용자 승인을 받아 실제 구현(Design Specialist → Senior/Junior Developer → 테스트 → 리뷰)을 진행합니다. "/dev '기능 설명'" 형식으로 사용하며, docs/flutter/[feature]/ 디렉토리에 모든 산출물을 생성합니다. 항상 한국어로 소통합니다.
---

# Dev - Flutter 개발팀 자동화 워크플로우

## 개요

`/dev` skill은 Flutter 기능 개발의 전체 라이프사이클을 자동화하는 다중 에이전트 팀 워크플로우입니다. 기능 설명을 입력받아 요구사항 분석, UI/UX 디자인, 기술 아키텍처 설계, 코드 구현(GetX 패턴), 테스트 시나리오 생성, 코드 리뷰 및 검증을 자동으로 수행합니다.

**주요 특징:**
- 모든 소통은 한국어로 진행
- 설계 단계는 plan 모드에서 진행하여 사용자 승인 후 구현
- GetX 패턴 기반 Controller-View 구조
- Melos 모노레포 아키텍처 준수

## 백엔드 개발 Skill과의 주요 차이점

| 측면 | 백엔드 개발 | Flutter 개발 |
|--------|-------------|-------------|
| **UI 레이어** | ❌ 없음 | ✅ UI/UX Designer + View 레이어 |
| **상태 관리** | Express 핸들러 | GetX Controller + View |
| **설계 단계** | Tech Lead로 직접 | PO → **UI/UX Designer** → Tech Lead |
| **코드 생성** | ❌ 해당없음 | ✅ melos generate (Freezed, json_serializable) |
| **테스팅** | TDD (unit tests) | ❌ 테스트 코드 없음, ✅ 테스트 시나리오 문서 |
| **구현 방식** | Senior + Junior (병렬) | Senior → Junior (순차) |
| **출력 구조** | src/modules/ | apps/wowa/lib/app/modules/ + packages/ |
| **문서화** | API 문서 (OpenAPI) | 테스트 시나리오 (FlutterTestMcp 호환) |

## 워크플로우

다음 단계를 순차적으로 실행하며, 에러 발생 시에만 중단합니다:

### 1단계: 기능명 추출
사용자의 기능 설명에서 간결한 기능명을 추출하여 디렉토리 이름을 결정합니다.

**변환 예시:**
- "날씨 정보 화면" → `weather`
- "사용자 프로필 조회 및 수정" → `user-profile`
- "로그인 인증" → `login-auth`

**규칙:**
- kebab-case 사용 (소문자 + 하이픈)
- 30자 이내로 제한
- 한글/특수문자 제거
- 기능/모듈 이름을 반영

### 2단계: Plan 모드 진입
EnterPlanMode를 사용하여 plan 모드로 전환합니다.

**이유:** 요구사항 분석, UI/UX 디자인, 기술 설계, 작업 분배는 실제 코드를 작성하기 전에 계획하고 사용자 승인을 받아야 합니다.

### 3단계: 설계 문서 생성 (Plan 모드 내)
Plan 모드에서 다음 문서들을 순차적으로 생성합니다:

#### 3-1: Product Owner - 요구사항 분석
`product-owner` subagent를 실행하여 요구사항 분석 및 사용자 스토리를 작성합니다.

**입력:** 사용자의 기능 설명
**출력:** `docs/flutter/[feature]/user-stories.md`

**Task 프롬프트:**
```
요구사항 분석해줘:
[사용자 기능 설명]

결과를 docs/flutter/[feature]/user-stories.md 파일에 작성해줘.
```

**포함 내용:**
- 사용자 스토리 (As a... I want... So that...)
- 비즈니스 요구사항
- 필요한 데이터 정의
- 기능 범위

#### 3-2: UI/UX Designer - 디자인 명세
`ui-ux-designer` subagent를 실행하여 상세 UI/UX 디자인 명세를 작성합니다.

**입력:** `docs/flutter/[feature]/user-stories.md`
**출력:** `docs/flutter/[feature]/design-spec.md`

**Task 프롬프트:**
```
UI/UX 디자인해줘.
user-stories는 docs/flutter/[feature]/user-stories.md에 있어.

결과를 docs/flutter/[feature]/design-spec.md 파일에 작성해줘.
```

**포함 내용:**
- 화면 레이아웃 설계 (위젯 트리 구조)
- 색상 팔레트 (Primary, Secondary, Background, Surface, Error)
- 타이포그래피 스케일 (Headline, Body, Label)
- 스페이싱 시스템 (Padding, Margin, Gap)
- 인터랙션 상태 (Default, Pressed, Disabled)
- Material Design 3 준수

#### 3-3: Tech Lead - 기술 아키텍처 설계
`tech-lead` subagent를 실행하여 기술 아키텍처를 설계합니다.

**입력:**
- `docs/flutter/[feature]/user-stories.md`
- `docs/flutter/[feature]/design-spec.md`
**출력:** `docs/flutter/[feature]/brief.md`

**Task 프롬프트:**
```
기술 설계해줘.
user-stories는 docs/flutter/[feature]/user-stories.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.

결과를 docs/flutter/[feature]/brief.md 파일에 작성해줘.
```

**포함 내용:**
- GetX Controller 설계 (.obs 변수, 메서드)
- 위젯 트리 기술 구현 방법
- API 통합 필요 여부 (packages/api)
- Design System 컴포넌트 필요 여부 (packages/design_system)
- 라우팅 설계 (route name, parameters)
- 상태 관리 플로우
- 에러 처리 전략

#### 3-4: CTO - 설계 승인
`cto` subagent를 실행하여 기술 설계를 검토하고 승인합니다.

**입력:** `docs/flutter/[feature]/brief.md`
**출력:** 승인 결정 (stdout)

**Task 프롬프트:**
```
설계 검토해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.

CLAUDE.md 표준 준수 여부, GetX 패턴 준수 여부, 모노레포 패키지 의존성을 확인하고 승인/거부를 결정해줘.
```

CTO가 설계를 거부하면 피드백과 함께 3-3단계로 돌아갑니다.

#### 3-5: CTO - 작업 계획 및 분배
`cto` subagent를 실행하여 상세 작업 계획 및 작업 분배를 수행합니다.

**입력:** `docs/flutter/[feature]/brief.md`
**출력:** `docs/flutter/[feature]/work-plan.md`

**Task 프롬프트:**
```
작업 분배해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.

Senior Developer와 Junior Developer의 작업을 명확히 나누고, 작업 의존성, 인터페이스 계약을 정의해줘.
결과를 docs/flutter/[feature]/work-plan.md 파일에 작성해줘.
```

**포함 내용:**
- Senior Developer 작업:
  - API 모델 작성 (Freezed + json_serializable)
  - Dio 클라이언트 구현 (필요 시)
  - melos generate 실행
  - GetX Controller 구현
  - Binding 작성
- Junior Developer 작업:
  - View 작성 (GetView 패턴)
  - Obx 반응형 UI 구현
  - Routing 업데이트
- 작업 의존성: Senior 완료 → Junior 시작
- 인터페이스 계약: Controller 메서드, .obs 변수 목록

### 4단계: Plan 모드 종료 및 사용자 승인
ExitPlanMode를 사용하여 plan을 제출하고 사용자 승인을 요청합니다.

**생성된 문서:**
- `docs/flutter/[feature]/user-stories.md` (요구사항)
- `docs/flutter/[feature]/design-spec.md` (UI/UX 디자인)
- `docs/flutter/[feature]/brief.md` (기술 아키텍처)
- `docs/flutter/[feature]/work-plan.md` (작업 계획)

사용자가 승인하면 5단계로 진행, 수정 필요 시 3단계의 해당 하위 단계로 돌아갑니다.

### 5단계: Design Specialist - 재사용 컴포넌트 (선택적)
**조건:** `brief.md`에서 `packages/design_system`에 새로운 재사용 컴포넌트가 필요하다고 명시된 경우에만 실행.

필요한 경우 `design-specialist` subagent를 실행하여 재사용 위젯을 생성합니다.

**입력:** `docs/flutter/[feature]/design-spec.md`
**출력:** `packages/design_system/lib/src/components/[component].dart`

**Task 프롬프트:**
```
재사용 위젯 만들어줘.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.
brief는 docs/flutter/[feature]/brief.md에 있어.

brief에 명시된 재사용 컴포넌트를 packages/design_system/에 구현해줘.
```

**생략 조건:**
- brief.md에 새로운 design system 컴포넌트 언급 없음
- 기존 컴포넌트만 사용하는 기능

### 6단계: Senior Developer - 핵심 구현
`senior-developer` subagent를 실행하여 API 모델, Controller, 비즈니스 로직을 구현합니다.

**입력:** `docs/flutter/[feature]/work-plan.md`
**출력:**
- `packages/api/lib/src/models/[feature]_model.dart` (API 필요 시)
- `packages/api/lib/src/clients/[feature]_client.dart` (API 필요 시)
- `apps/wowa/lib/app/modules/[feature]/controllers/[feature]_controller.dart`
- `apps/wowa/lib/app/modules/[feature]/bindings/[feature]_binding.dart`
- 생성 파일: `*.freezed.dart`, `*.g.dart`

**Task 프롬프트:**
```
API 모델과 Controller 구현해줘.
work-plan은 docs/flutter/[feature]/work-plan.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.

work-plan의 Senior Developer 작업 항목을 모두 구현해줘.
API가 필요하면 packages/api/에 Freezed 모델과 Dio 클라이언트를 만들고 melos generate를 실행해줘.
```

**중요:**
- Senior Developer는 시작 전 `.claude/guides/` 파일 필독
- API 모델 생성 시 `cd apps/wowa && melos generate` 실행 필수
- 테스트 코드 작성 금지 (CLAUDE.md 정책)

### 7단계: Junior Developer - View 구현
`junior-developer` subagent를 실행하여 View와 UI 위젯을 구현합니다.

**입력:**
- `docs/flutter/[feature]/work-plan.md`
- Senior의 Controller (먼저 읽어야 함!)
**출력:**
- `apps/wowa/lib/app/modules/[feature]/views/[feature]_view.dart`
- `apps/wowa/lib/app/routes/app_routes.dart` (업데이트)
- `apps/wowa/lib/app/routes/app_pages.dart` (업데이트)

**Task 프롬프트:**
```
View 구현해줘.
work-plan은 docs/flutter/[feature]/work-plan.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.

Senior Developer가 구현한 Controller를 읽고, work-plan의 Junior Developer 작업 항목을 모두 구현해줘.
```

**중요:**
- Junior Developer는 반드시 Senior의 Controller를 먼저 읽어야 함
- 시작 전 `.claude/guides/` 파일 필독
- Controller 메서드명과 .obs 변수명을 정확히 일치시켜야 함
- 테스트 코드 작성 금지 (CLAUDE.md 정책)

### 8단계: 구현 요약
사용자에게 구현 요약을 제시합니다:

```
✅ 구현 완료: [feature name]

📁 생성된 파일:
[문서]
- docs/flutter/[feature]/user-stories.md
- docs/flutter/[feature]/design-spec.md
- docs/flutter/[feature]/brief.md
- docs/flutter/[feature]/work-plan.md

[구현 코드]
- apps/wowa/lib/app/modules/[feature]/controllers/
- apps/wowa/lib/app/modules/[feature]/views/
- apps/wowa/lib/app/modules/[feature]/bindings/
- apps/wowa/lib/app/routes/ (업데이트)
[- packages/api/lib/src/models/ (API 사용 시)]
[- packages/design_system/lib/src/components/ (새 컴포넌트 시)]

다음: 테스트 시나리오 생성 및 리뷰 단계
```

### 9단계: 테스트 및 리뷰 승인
테스트 시나리오 생성 및 리뷰 진행을 위한 사용자 승인을 요청합니다.

**질문:**
```
구현이 완료되었습니다.

🧪 테스트 시나리오 생성 및 리뷰를 진행할까요?
- 테스트 시나리오 자동 생성
- CTO 통합 리뷰
- Independent Reviewer 검증

계속 진행하시겠습니까?
```

**옵션:**
- "승인 - 계속 진행" → 10단계로 진행
- "수정 필요" → 수정할 내용을 지정하고 해당 단계로 복귀

### 10단계: Test Scenario Generator - 테스트 시나리오 생성
**Skill 도구를 사용**하여 `test-scenario-generator` skill을 실행합니다.

**입력:**
- `docs/flutter/[feature]/user-stories.md`
- `docs/flutter/[feature]/design-spec.md`
- `docs/flutter/[feature]/brief.md`
**출력:** `docs/flutter/[feature]/test-scenarios.md`

**Skill 실행:**
```
Skill(skill="test-scenario-generator", args="docs/flutter/[feature]")
```

**포함 내용:**
- Given-When-Then 시나리오 (Happy Path, Edge Case, Error Case)
- 수동 테스트 절차
- FlutterTestMcp 자동화 스크립트 (npx -y flutter-test-mcp)
- @mobilenext/mobile-mcp UI 검증 스크립트 (npx -y @mobilenext/mobile-mcp)
- 접근성 테스트 (WCAG AA)
- 성능 테스트 기준

### 11단계: CTO - 통합 리뷰
`cto` subagent를 실행하여 통합 리뷰를 수행합니다.

**입력:**
- `docs/flutter/[feature]/work-plan.md`
- 구현된 코드
**출력:** `docs/flutter/[feature]/cto-review.md`

**Task 프롬프트:**
```
통합 리뷰해줘.
work-plan은 docs/flutter/[feature]/work-plan.md에 있어.

Senior/Junior 코드 통합 확인, Controller-View 연결 정확성, GetX 패턴 준수, 앱 빌드 성공 여부를 검증해줘.
결과를 docs/flutter/[feature]/cto-review.md 파일에 작성해줘.
```

**검증 항목:**
- Controller-View 인터페이스 일치
- GetX 패턴 준수 (.obs, Obx, GetView, Binding)
- import 정확성
- `cd apps/wowa && flutter run --debug` 성공 여부
- Hot reload 동작 확인

### 12단계: Independent Reviewer - Fresh Eyes 검증
`independent-reviewer` subagent를 실행하여 요구사항 대비 구현을 검증합니다.

**입력:**
- `docs/flutter/[feature]/brief.md` (이 파일만!)
- `docs/flutter/[feature]/design-spec.md`
- `docs/flutter/[feature]/test-scenarios.md`
- 구현된 코드 (테스트 실행용)
**출력:** `docs/flutter/[feature]/review-report.md`

**Task 프롬프트:**
```
Fresh Eyes 검증해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.
test-scenarios는 docs/flutter/[feature]/test-scenarios.md에 있어.

구현된 코드가 요구사항을 충족하는지 Fresh Eyes로 검증해줘.
FlutterTestMcp와 @mobilenext/mobile-mcp를 사용해서 UI 검증도 수행해줘.
결과를 docs/flutter/[feature]/review-report.md 파일에 작성해줘.
```

**중요:**
- Independent Reviewer는 work-plan.md, cto-review.md, 소스코드 컨텍스트를 읽지 않아야 함
- claude-mem MCP 사용 금지 (구현 편향 방지)
- FlutterTestMcp와 @mobilenext/mobile-mcp를 사용한 자동화 테스트 수행

### 13단계: 최종 승인
작업 완료를 위한 최종 사용자 승인을 요청합니다.

**질문:**
```
🎉 테스트 및 리뷰가 완료되었습니다!

📊 검증 결과:
- ✅ CTO 통합 리뷰: docs/flutter/[feature]/cto-review.md
- ✅ Independent Reviewer 검증: docs/flutter/[feature]/review-report.md
- ✅ 테스트 시나리오: docs/flutter/[feature]/test-scenarios.md

작업을 완료할까요?
```

**옵션:**
- "완료" → 14단계로 진행
- "추가 작업 필요" → 필요한 작업 지정

### 14단계: 완료
최종 완료 요약을 제시합니다:

```
🎉 작업 완료: [feature name]

📁 생성된 모든 파일:

[문서]
- docs/flutter/[feature]/user-stories.md
- docs/flutter/[feature]/design-spec.md
- docs/flutter/[feature]/brief.md
- docs/flutter/[feature]/work-plan.md
- docs/flutter/[feature]/test-scenarios.md
- docs/flutter/[feature]/cto-review.md
- docs/flutter/[feature]/review-report.md

[구현 코드]
- apps/wowa/lib/app/modules/[feature]/
  - controllers/[feature]_controller.dart
  - views/[feature]_view.dart
  - bindings/[feature]_binding.dart
- apps/wowa/lib/app/routes/app_routes.dart (업데이트)
- apps/wowa/lib/app/routes/app_pages.dart (업데이트)
[- packages/api/lib/src/models/[feature]_model.dart]
[- packages/api/lib/src/clients/[feature]_client.dart]
[- packages/design_system/lib/src/components/...]

✅ 다음 단계:
1. 앱 실행: cd apps/wowa && flutter run
2. Hot reload 테스트: r (hot reload), R (hot restart)
3. 수동 테스트: docs/flutter/[feature]/test-scenarios.md 참조
4. 자동화 테스트:
   - npx -y flutter-test-mcp
   - npx -y @mobilenext/mobile-mcp
5. 필요 시 코드 생성 재실행: melos generate
```

## 에러 처리

단계 실패 시:
1. 워크플로우를 즉시 중단
2. 실패한 단계명과 함께 에러를 사용자에게 보고
3. 재시도 또는 중단 여부 확인

**에러 메시지 예시:**
```
❌ 6단계 (Senior Developer) 실패: [에러 상세 내용]

다음 중 선택해주세요:
- 재시도
- 수정 후 재시도 (어떤 부분을 수정할지 알려주세요)
- 중단
```

**일반적인 에러 시나리오:**
- **melos generate 실패**: Freezed/json_serializable 문법 확인, melos bootstrap 재실행
- **flutter run 실패**: import 에러, GetX binding 문제 확인
- **Controller-View 미스매치**: Senior와 Junior 간 인터페이스 불일치

## 출력 디렉토리 구조

모든 산출물은 `docs/flutter/[feature]/`에 저장됩니다:

```
docs/flutter/
└── [feature]/
    ├── user-stories.md          # 3-1단계: Product Owner
    ├── design-spec.md            # 3-2단계: UI/UX Designer
    ├── brief.md                  # 3-3단계: Tech Lead
    ├── work-plan.md              # 3-5단계: CTO (작업 계획)
    ├── test-scenarios.md         # 10단계: Test Scenario Generator
    ├── cto-review.md             # 11단계: CTO (통합 리뷰)
    └── review-report.md          # 12단계: Independent Reviewer
```

구현 파일은 프로젝트 구조를 따릅니다:
```
apps/wowa/lib/app/modules/[feature]/
├── controllers/[feature]_controller.dart
├── views/[feature]_view.dart
└── bindings/[feature]_binding.dart

packages/api/lib/src/
├── models/[feature]_model.dart
└── clients/[feature]_client.dart

packages/design_system/lib/src/components/
└── [component].dart
```

## 사용 예시

**예시 1: 간단한 UI 기능**
```
사용자: /dev "날씨 정보를 보여주는 화면"

프로세스:
1. 기능명 추출: weather
2. Plan 모드 진입
3. 설계 문서 생성:
   3-1. Product Owner → docs/flutter/weather/user-stories.md
   3-2. UI/UX Designer → docs/flutter/weather/design-spec.md
   3-3. Tech Lead → docs/flutter/weather/brief.md
   3-4. CTO 설계 승인
   3-5. CTO → docs/flutter/weather/work-plan.md
4. Plan 모드 종료 [사용자 승인]
5. [Design Specialist 생략 - 새 컴포넌트 불필요]
6. Senior Dev → API 모델 + Controller + Binding
7. Junior Dev → View + Routing
8. 구현 요약
9. 테스트 및 리뷰 승인 [사용자 승인]
10. Test Scenario Generator → docs/flutter/weather/test-scenarios.md
11. CTO → docs/flutter/weather/cto-review.md
12. Independent Reviewer → docs/flutter/weather/review-report.md
13. 최종 승인 [사용자 승인]
14. 완료 요약
```

**예시 2: API 통합 기능**
```
사용자: /dev "사용자 프로필 조회 및 수정"

프로세스:
1. 기능명 추출: user-profile
2-4. 예시 1과 동일
5. [Design Specialist 생략]
6. Senior Dev:
   - packages/api/lib/src/models/user_profile_model.dart (Freezed)
   - packages/api/lib/src/clients/user_profile_client.dart (Dio)
   - melos generate (.freezed.dart, .g.dart 생성)
   - apps/wowa/lib/app/modules/user_profile/controllers/user_profile_controller.dart
   - apps/wowa/lib/app/modules/user_profile/bindings/user_profile_binding.dart
7-14. 예시 1과 동일
```

**예시 3: 새로운 디자인 시스템 컴포넌트**
```
사용자: /dev "공통으로 사용할 프로필 카드 컴포넌트"

프로세스:
1-4. 예시 1과 동일
5. Design Specialist:
   - packages/design_system/lib/src/components/profile_card.dart
   - Material Design 3 준수 재사용 위젯
6-14. 예시 1과 동일
```

## 중요 사항

### Plan 모드 사용
- **설계 단계(3단계)는 plan 모드에서 진행**
- EnterPlanMode로 plan 모드 진입
- 모든 설계 문서 생성 후 ExitPlanMode로 사용자 승인 요청
- 사용자 승인 후 구현 단계(5-7단계) 진행

### Subagent 호출
- 적절한 subagent_type과 함께 Task tool 사용
- 각 subagent 완료를 기다린 후 다음 단계 진행
- Subagent 에러 포착 및 처리
- test-scenario-generator는 Skill tool 사용

### 순차 실행 (중요!)
**Senior Developer가 완료된 후에만 Junior Developer 시작.**

이유:
- Junior는 View 구현을 위해 Senior의 Controller를 읽어야 함
- Controller가 View가 의존하는 .obs 변수와 메서드를 정의
- 병렬 실행 시 인터페이스 미스매치 에러 발생

### 파일 구조
- 기능명이 docs/flutter/ 하위 디렉토리 결정
- 일관성을 위해 kebab-case 사용
- 시작 전 docs/flutter/[feature]/ 존재 여부 확인
- 확인 없이 기존 기능 덮어쓰기 방지

### 사용자 상호작용 지점
**3개의 승인 지점:**
1. **4단계 (설계 단계)**: Plan 모드 종료 시 user-stories.md, design-spec.md, brief.md, work-plan.md 검토
2. **9단계 (리뷰 단계)**: 테스트 및 리뷰 진행 승인
3. **13단계 (최종)**: cto-review.md와 review-report.md 검토

### 코드 생성 (melos generate)
- Senior Developer가 API 모델 생성 후 `melos generate` 실행
- `.freezed.dart`와 `.g.dart` 파일 생성
- `apps/wowa` 디렉토리 또는 프로젝트 루트에서 실행 필수
- 생성 실패 시 Freezed/json_serializable 문법 확인

### 테스팅 정책 (CLAUDE.md 준수)
**테스트 코드 작성 금지:**
- ❌ Unit test, Widget test, Integration test
- ❌ test/ 디렉토리 Dart 파일
- ✅ 테스트 시나리오 문서 (test-scenarios.md)
- ✅ 테스트 자동화 스크립트 (FlutterTestMcp, @mobilenext/mobile-mcp)

### 에러 복구
- 재시도 시 완료된 단계 보존
- 재시도 전 사용자가 요구사항 수정 가능
- 디버깅을 위한 명확한 에러 컨텍스트 제공
- melos generate 실패 시 `melos bootstrap` 먼저 제안

### GetX 패턴 검증
모든 구현이 GetX 패턴을 따르는지 확인:
- **Controller**: `GetxController` 상속, 반응형 상태에 `.obs` 사용
- **View**: `GetView<Controller>` 상속, 반응형 UI에 `Obx()` 사용
- **Binding**: `Bindings` 상속, 의존성 주입에 `Get.lazyPut()` 사용
- **Routing**: `app_pages.dart`에서 `GetPage`와 함께 named route 사용

### 디자인 시스템 가이드라인
새 컴포넌트 필요 시:
- Material Design 3 준수
- 재사용 가능하고 조합 가능
- 기존 디자인 토큰과 일관성 유지
- 예시와 함께 잘 문서화

## 문제 해결

### 일반적인 문제

**1. "Controller not found" 에러**
- `app_pages.dart`에 Binding이 제대로 등록되었는지 확인
- Binding에 `Get.lazyPut<Controller>(() => Controller())` 있는지 확인
- Route가 `binding: FeatureBinding()`와 함께 정의되었는지 확인

**2. "melos generate" 실패**
- 먼저 `melos bootstrap` 실행
- Freezed 문법 확인 (factory constructor, fromJson)
- `part` directive가 올바른지 확인
- dev_dependencies에 `build_runner` 있는지 확인

**3. Hot reload 작동 안 함**
- `R`로 앱 재시작 (hot restart)
- 잘못된 라이프사이클을 가진 stateful widget 확인
- GetX Controller의 onClose()가 제대로 구현되었는지 확인

**4. UI 업데이트 안 됨**
- 변수가 `.obs`인지 확인 (예: `final count = 0.obs`)
- UI를 `Obx(() => ...)`로 감싸기 (단순히 `Obx(...)`가 아님)
- Controller에서 `.value`로 접근하는지 확인
- Obx 내부에 const widget 사용 금지

**5. Import 에러**
- 의존성 추가 후 `melos bootstrap` 실행
- pubspec.yaml dependencies 확인
- lib/[package].dart의 package export 확인

## 관련 Skills

- `/test-scenario-generator` - 테스트 시나리오 별도 생성
- `/커밋` - 논리적 단위로 변경사항 커밋
