---
name: dev
description: Automated Flutter development team workflow that executes the complete feature development process from requirements analysis to UI/UX design, implementation, testing, and review. Orchestrates Product Owner → UI/UX Designer → Tech Lead → CTO (Approval) → [User Approval] → Design Specialist (optional) → CTO (Task Planning) → Senior Developer → Junior Developer → Test Scenario Generator → CTO (Review) → Independent Reviewer sequence. Use when the user requests a new Flutter feature with "/dev 'feature description'" format. Outputs all artifacts to docs/flutter/[feature]/ directory including user-stories.md, design-spec.md, brief.md, work-plan.md, test-scenarios.md, cto-review.md, review-report.md, and implemented Flutter code.
---

# Dev - Automated Flutter Development Team Workflow

## Overview

The `/dev` skill automates the complete Flutter feature development lifecycle using a multi-agent team workflow. It takes a feature description and automatically executes requirements analysis, UI/UX design, technical architecture, code implementation (GetX pattern), test scenario generation, code review, and verification.

## Key Differences from Backend Dev Skill

| Aspect | Backend Dev | Flutter Dev |
|--------|-------------|-------------|
| **UI Layer** | ❌ No UI | ✅ UI/UX Designer + View layer |
| **State Management** | Express handlers | GetX Controller + View |
| **Design Phase** | Direct to Tech Lead | PO → **UI/UX Designer** → Tech Lead |
| **Code Generation** | ❌ N/A | ✅ melos generate (Freezed, json_serializable) |
| **Testing** | TDD (unit tests) | ❌ No test code, ✅ Test scenarios document |
| **Implementation** | Senior + Junior (parallel) | Senior → Junior (sequential) |
| **Output Structure** | src/modules/ | apps/wowa/lib/app/modules/ + packages/ |
| **Documentation** | API docs (OpenAPI) | Test scenarios (FlutterTestMcp compatible) |

## Workflow

Execute these steps sequentially, stopping only if an error occurs:

### Step 1: Feature Name Extraction
Extract a concise feature name from the user's description for directory naming.

**Example transformations:**
- "날씨 정보 화면" → `weather`
- "사용자 프로필 조회 및 수정" → `user-profile`
- "로그인 인증" → `login-auth`

**Rules:**
- Use kebab-case (lowercase with hyphens)
- Keep it under 30 characters
- Remove Korean/special characters
- Should reflect the feature/module name

### Step 2: Product Owner - Requirements Analysis
Launch the `product-owner` subagent to analyze requirements and create user stories.

**Input:** User's feature description
**Output:** `docs/flutter/[feature]/user-stories.md`

**Task prompt template:**
```
요구사항 분석해줘:
[user's feature description]

결과를 docs/flutter/[feature]/user-stories.md 파일에 작성해줘.
```

**Expected content:**
- 사용자 스토리 (As a... I want... So that...)
- 비즈니스 요구사항
- 필요한 데이터 정의
- 기능 범위

### Step 3: UI/UX Designer - Design Specification
Launch the `ui-ux-designer` subagent to create detailed UI/UX design specification.

**Input:** `docs/flutter/[feature]/user-stories.md`
**Output:** `docs/flutter/[feature]/design-spec.md`

**Task prompt template:**
```
UI/UX 디자인해줘.
user-stories는 docs/flutter/[feature]/user-stories.md에 있어.

결과를 docs/flutter/[feature]/design-spec.md 파일에 작성해줘.
```

**Expected content:**
- 화면 레이아웃 설계 (위젯 트리 구조)
- 색상 팔레트 (Primary, Secondary, Background, Surface, Error)
- 타이포그래피 스케일 (Headline, Body, Label)
- 스페이싱 시스템 (Padding, Margin, Gap)
- 인터랙션 상태 (Default, Pressed, Disabled)
- Material Design 3 준수

### Step 4: Tech Lead - Technical Architecture Design
Launch the `tech-lead` subagent to design the technical architecture.

**Input:**
- `docs/flutter/[feature]/user-stories.md`
- `docs/flutter/[feature]/design-spec.md`
**Output:** `docs/flutter/[feature]/brief.md`

**Task prompt template:**
```
기술 설계해줘.
user-stories는 docs/flutter/[feature]/user-stories.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.

결과를 docs/flutter/[feature]/brief.md 파일에 작성해줘.
```

**Expected content:**
- GetX Controller 설계 (.obs 변수, 메서드)
- 위젯 트리 기술 구현 방법
- API 통합 필요 여부 (packages/api)
- Design System 컴포넌트 필요 여부 (packages/design_system)
- 라우팅 설계 (route name, parameters)
- 상태 관리 플로우
- 에러 처리 전략

### Step 5: CTO - Design Approval
Launch the `cto` subagent to review and approve the technical design.

**Input:** `docs/flutter/[feature]/brief.md`
**Output:** Approval decision (stdout)

**Task prompt template:**
```
설계 검토해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.

CLAUDE.md 표준 준수 여부, GetX 패턴 준수 여부, 모노레포 패키지 의존성을 확인하고 승인/거부를 결정해줘.
```

If CTO rejects the design, return to Step 4 with feedback.

### Step 6: User Approval (Design Phase)
Present the design documents to the user for approval using AskUserQuestion tool.

**Question:**
```
설계가 완료되었습니다.

📄 생성된 문서:
- docs/flutter/[feature]/user-stories.md (요구사항)
- docs/flutter/[feature]/design-spec.md (UI/UX 디자인)
- docs/flutter/[feature]/brief.md (기술 아키텍처)

계속 진행할까요?
```

**Options:**
- "승인 - 계속 진행" → proceed to Step 7
- "수정 필요 - 다시 설계" → specify what needs to be changed and return to appropriate step

### Step 7: Design Specialist - Reusable Components (Optional)
**Condition:** Only if `brief.md` indicates that new reusable components are needed in `packages/design_system`.

If needed, launch the `design-specialist` subagent to create reusable widgets.

**Input:** `docs/flutter/[feature]/design-spec.md`
**Output:** `packages/design_system/lib/src/components/[component].dart`

**Task prompt template:**
```
재사용 위젯 만들어줘.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.
brief는 docs/flutter/[feature]/brief.md에 있어.

brief에 명시된 재사용 컴포넌트를 packages/design_system/에 구현해줘.
```

**Skip this step if:**
- brief.md does not mention new design system components
- Feature uses only existing components

### Step 8: CTO - Task Planning and Distribution
Launch the `cto` subagent to create detailed work plan with task distribution.

**Input:** `docs/flutter/[feature]/brief.md`
**Output:** `docs/flutter/[feature]/work-plan.md`

**Task prompt template:**
```
작업 분배해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.

Senior Developer와 Junior Developer의 작업을 명확히 나누고, 작업 의존성, 인터페이스 계약을 정의해줘.
결과를 docs/flutter/[feature]/work-plan.md 파일에 작성해줘.
```

**Expected content:**
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

### Step 9: Senior Developer - Core Implementation
Launch the `senior-developer` subagent to implement API models, Controller, and business logic.

**Input:** `docs/flutter/[feature]/work-plan.md`
**Output:**
- `packages/api/lib/src/models/[feature]_model.dart` (if API needed)
- `packages/api/lib/src/clients/[feature]_client.dart` (if API needed)
- `apps/wowa/lib/app/modules/[feature]/controllers/[feature]_controller.dart`
- `apps/wowa/lib/app/modules/[feature]/bindings/[feature]_binding.dart`
- Generated files: `*.freezed.dart`, `*.g.dart`

**Task prompt template:**
```
API 모델과 Controller 구현해줘.
work-plan은 docs/flutter/[feature]/work-plan.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.

work-plan의 Senior Developer 작업 항목을 모두 구현해줘.
API가 필요하면 packages/api/에 Freezed 모델과 Dio 클라이언트를 만들고 melos generate를 실행해줘.
```

**Important:**
- Senior Developer MUST read `.claude/guides/` files before starting
- MUST execute `cd apps/wowa && melos generate` if API models are created
- NO TEST CODE (CLAUDE.md policy)

### Step 10: Junior Developer - View Implementation
Launch the `junior-developer` subagent to implement View and UI widgets.

**Input:**
- `docs/flutter/[feature]/work-plan.md`
- Senior's Controller (must read it first!)
**Output:**
- `apps/wowa/lib/app/modules/[feature]/views/[feature]_view.dart`
- `apps/wowa/lib/app/routes/app_routes.dart` (updated)
- `apps/wowa/lib/app/routes/app_pages.dart` (updated)

**Task prompt template:**
```
View 구현해줘.
work-plan은 docs/flutter/[feature]/work-plan.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.

Senior Developer가 구현한 Controller를 읽고, work-plan의 Junior Developer 작업 항목을 모두 구현해줘.
```

**Important:**
- Junior Developer MUST read Senior's Controller first
- MUST read `.claude/guides/` files before starting
- MUST match Controller method names and .obs variable names exactly
- NO TEST CODE (CLAUDE.md policy)

### Step 11: Implementation Summary
Present an implementation summary to the user:

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
- apps/wowa/lib/app/routes/ (updated)
[- packages/api/lib/src/models/ (if API used)]
[- packages/design_system/lib/src/components/ (if new components)]

다음: 테스트 시나리오 생성 및 리뷰 단계
```

### Step 12: User Approval (Review Phase)
Ask user for approval to proceed with test scenario generation and review.

**Question:**
```
구현이 완료되었습니다.

🧪 테스트 시나리오 생성 및 리뷰를 진행할까요?
- 테스트 시나리오 자동 생성
- CTO 통합 리뷰
- Independent Reviewer 검증

계속 진행하시겠습니까?
```

**Options:**
- "승인 - 계속 진행" → proceed to Step 13
- "수정 필요" → specify what needs to be changed and return to appropriate step

### Step 13: Test Scenario Generator - Generate Test Scenarios
**Use the Skill tool** to invoke the `test-scenario-generator` skill.

**Input:**
- `docs/flutter/[feature]/user-stories.md`
- `docs/flutter/[feature]/design-spec.md`
- `docs/flutter/[feature]/brief.md`
**Output:** `docs/flutter/[feature]/test-scenarios.md`

**Skill invocation:**
```
Skill(skill="test-scenario-generator", args="docs/flutter/[feature]")
```

**Expected content:**
- Given-When-Then 시나리오 (Happy Path, Edge Case, Error Case)
- 수동 테스트 절차
- FlutterTestMcp 자동화 스크립트 (npx -y flutter-test-mcp)
- @mobilenext/mobile-mcp UI 검증 스크립트 (npx -y @mobilenext/mobile-mcp)
- 접근성 테스트 (WCAG AA)
- 성능 테스트 기준

### Step 14: CTO - Integration Review
Launch the `cto` subagent to perform integration review.

**Input:**
- `docs/flutter/[feature]/work-plan.md`
- Implemented code
**Output:** `docs/flutter/[feature]/cto-review.md`

**Task prompt template:**
```
통합 리뷰해줘.
work-plan은 docs/flutter/[feature]/work-plan.md에 있어.

Senior/Junior 코드 통합 확인, Controller-View 연결 정확성, GetX 패턴 준수, 앱 빌드 성공 여부를 검증해줘.
결과를 docs/flutter/[feature]/cto-review.md 파일에 작성해줘.
```

**Expected checks:**
- Controller-View 인터페이스 일치
- GetX 패턴 준수 (.obs, Obx, GetView, Binding)
- import 정확성
- `cd apps/wowa && flutter run --debug` 성공 여부
- Hot reload 동작 확인

### Step 15: Independent Reviewer - Fresh Eyes Verification
Launch the `independent-reviewer` subagent to verify implementation against requirements.

**Input:**
- `docs/flutter/[feature]/brief.md` (ONLY this file!)
- `docs/flutter/[feature]/design-spec.md`
- `docs/flutter/[feature]/test-scenarios.md`
- Implemented code (to execute tests)
**Output:** `docs/flutter/[feature]/review-report.md`

**Task prompt template:**
```
Fresh Eyes 검증해줘.
brief는 docs/flutter/[feature]/brief.md에 있어.
design-spec은 docs/flutter/[feature]/design-spec.md에 있어.
test-scenarios는 docs/flutter/[feature]/test-scenarios.md에 있어.

구현된 코드가 요구사항을 충족하는지 Fresh Eyes로 검증해줘.
FlutterTestMcp와 @mobilenext/mobile-mcp를 사용해서 UI 검증도 수행해줘.
결과를 docs/flutter/[feature]/review-report.md 파일에 작성해줘.
```

**Important:**
- Independent Reviewer MUST NOT read work-plan.md, cto-review.md, or source code context
- MUST NOT use claude-mem MCP (to avoid implementation bias)
- Uses FlutterTestMcp and @mobilenext/mobile-mcp for automated testing

### Step 16: User Approval (Final)
Ask user for final approval to complete the workflow.

**Question:**
```
🎉 테스트 및 리뷰가 완료되었습니다!

📊 검증 결과:
- ✅ CTO 통합 리뷰: docs/flutter/[feature]/cto-review.md
- ✅ Independent Reviewer 검증: docs/flutter/[feature]/review-report.md
- ✅ 테스트 시나리오: docs/flutter/[feature]/test-scenarios.md

작업을 완료할까요?
```

**Options:**
- "완료" → proceed to Step 17
- "추가 작업 필요" → specify what needs to be done

### Step 17: Completion
Present final completion summary:

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
- apps/wowa/lib/app/routes/app_routes.dart (updated)
- apps/wowa/lib/app/routes/app_pages.dart (updated)
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

## Error Handling

If any step fails:
1. Stop the workflow immediately
2. Report the error to the user with the failed step name
3. Ask if they want to retry that step or abort

**Example error message:**
```
❌ Step 9 (Senior Developer) 실패: [error details]

다음 중 선택해주세요:
- 재시도
- 수정 후 재시도 (어떤 부분을 수정할지 알려주세요)
- 중단
```

**Common error scenarios:**
- **melos generate 실패**: Check Freezed/json_serializable syntax, re-run melos bootstrap
- **flutter run 실패**: Check import errors, GetX binding issues
- **Controller-View 미스매치**: Senior와 Junior 간 인터페이스 불일치

## Output Directory Structure

All artifacts are saved in `docs/flutter/[feature]/`:

```
docs/flutter/
└── [feature]/
    ├── user-stories.md          # Step 2: Product Owner
    ├── design-spec.md            # Step 3: UI/UX Designer
    ├── brief.md                  # Step 4: Tech Lead
    ├── work-plan.md              # Step 8: CTO (Task Planning)
    ├── test-scenarios.md         # Step 13: Test Scenario Generator
    ├── cto-review.md             # Step 14: CTO (Integration Review)
    └── review-report.md          # Step 15: Independent Reviewer
```

Implementation files follow the project structure:
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

## Usage Examples

**Example 1: Simple UI feature**
```
User: /dev "날씨 정보를 보여주는 화면"

Process:
1. Extract feature name: weather
2. Product Owner → docs/flutter/weather/user-stories.md
3. UI/UX Designer → docs/flutter/weather/design-spec.md
4. Tech Lead → docs/flutter/weather/brief.md
5. CTO approves design
6. [User approves design]
7. [Design Specialist skipped - no new components needed]
8. CTO → docs/flutter/weather/work-plan.md
9. Senior Dev → API models + Controller + Binding
10. Junior Dev → View + Routing
11. Implementation summary
12. [User approves review phase]
13. Test Scenario Generator → docs/flutter/weather/test-scenarios.md
14. CTO → docs/flutter/weather/cto-review.md
15. Independent Reviewer → docs/flutter/weather/review-report.md
16. [User gives final approval]
17. Completion summary
```

**Example 2: Feature with API integration**
```
User: /dev "사용자 프로필 조회 및 수정"

Process:
1. Extract feature name: user-profile
2-8. Same as Example 1
9. Senior Dev:
   - packages/api/lib/src/models/user_profile_model.dart (Freezed)
   - packages/api/lib/src/clients/user_profile_client.dart (Dio)
   - melos generate (generates .freezed.dart, .g.dart)
   - apps/wowa/lib/app/modules/user_profile/controllers/user_profile_controller.dart
   - apps/wowa/lib/app/modules/user_profile/bindings/user_profile_binding.dart
10-17. Same as Example 1
```

**Example 3: Feature with new design system component**
```
User: /dev "공통으로 사용할 프로필 카드 컴포넌트"

Process:
1-6. Same as Example 1
7. Design Specialist:
   - packages/design_system/lib/src/components/profile_card.dart
   - Reusable widget with Material Design 3
8-17. Same as Example 1
```

## Important Notes

### Subagent Invocation
- Always use Task tool with appropriate subagent_type
- Wait for each subagent to complete before proceeding
- Capture and handle subagent errors
- For test-scenario-generator, use Skill tool instead

### Sequential Execution (Critical!)
**Senior Developer MUST complete before Junior Developer starts.**

This is because:
- Junior needs to read Senior's Controller to implement View
- Controller defines .obs variables and methods that View depends on
- Parallel execution will cause interface mismatch errors

### File Organization
- Feature name determines the docs/flutter/ subdirectory
- Use kebab-case for consistency
- Check if docs/flutter/[feature]/ already exists before starting
- Avoid overwriting existing features without confirmation

### User Interaction Points
**Three approval points:**
1. **Step 6 (Design Phase)**: User reviews user-stories.md, design-spec.md, brief.md
2. **Step 12 (Review Phase)**: User approves proceeding to testing and review
3. **Step 16 (Final)**: User reviews cto-review.md and review-report.md

### Code Generation (melos generate)
- Senior Developer executes `melos generate` after creating API models
- Generates `.freezed.dart` and `.g.dart` files
- MUST be run from `apps/wowa` directory or project root
- If generation fails, check Freezed/json_serializable syntax

### Testing Policy (CLAUDE.md Compliance)
**NO TEST CODE ALLOWED:**
- ❌ Unit tests, Widget tests, Integration tests
- ❌ test/ directory Dart files
- ✅ Test scenario documents (test-scenarios.md)
- ✅ Test automation scripts (FlutterTestMcp, @mobilenext/mobile-mcp)

### Error Recovery
- Preserve completed steps when retrying
- Allow user to modify requirements before retry
- Provide clear error context for debugging
- If melos generate fails, suggest `melos bootstrap` first

### GetX Pattern Verification
Ensure all implementations follow GetX patterns:
- **Controller**: Extends `GetxController`, uses `.obs` for reactive state
- **View**: Extends `GetView<Controller>`, uses `Obx()` for reactive UI
- **Binding**: Extends `Bindings`, uses `Get.lazyPut()` for dependency injection
- **Routing**: Uses named routes with `GetPage` in `app_pages.dart`

### Design System Guidelines
When new components are needed:
- Material Design 3 compliance
- Reusable and composable
- Consistent with existing design tokens
- Well-documented with examples

## Troubleshooting

### Common Issues

**1. "Controller not found" error**
- Check if Binding is properly registered in `app_pages.dart`
- Verify `Get.lazyPut<Controller>(() => Controller())` in Binding
- Ensure route is defined with `binding: FeatureBinding()`

**2. "melos generate" fails**
- Run `melos bootstrap` first
- Check Freezed syntax (factory constructor, fromJson)
- Ensure `part` directives are correct
- Verify `build_runner` is in dev_dependencies

**3. Hot reload not working**
- Restart app with `R` (hot restart)
- Check for stateful widgets with incorrect lifecycle
- Verify GetX Controller onClose() is properly implemented

**4. UI not updating**
- Ensure variable is `.obs` (e.g., `final count = 0.obs`)
- Wrap UI in `Obx(() => ...)` not just `Obx(...)`
- Check if accessing `.value` in Controller
- Avoid const widgets inside Obx

**5. Import errors**
- Run `melos bootstrap` after adding dependencies
- Check pubspec.yaml dependencies
- Verify package exports in lib/[package].dart

## Related Skills

- `/test-scenario-generator` - Generate test scenarios separately
- `/커밋` - Commit changes in logical units
