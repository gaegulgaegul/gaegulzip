# iterate (Act Phase) — Severity-Based Agent Dispatch

matchRate < 90% 시 FINDINGS를 기반으로 적절한 에이전트에 자동 디스패치합니다.

**Step 1: FINDINGS 파싱**
```
Read("docs/{product}/{feature}/analysis.md")
# Structured FINDINGS 섹션에서 모든 FINDING 항목 추출
```

**Step 2: Severity 순 정렬**
정렬 순서: CRITICAL → HIGH → MEDIUM → LOW

**Step 3: Finding → Agent 매핑 + 디스패치**

| Category | Agent |
|----------|-------|
| SECURITY | security-specialist |
| PERFORMANCE | performance-optimizer |
| BUILD_ERROR / TYPE_ERROR / LINT_ERROR | bug-fixer |
| LOGIC_GAP / DESIGN_GAP | node-developer / flutter-developer / react-developer (플랫폼별) |
| CONTRACT_MISMATCH | 양쪽 developer 재투입 |
| UX_POLISH | node-developer / flutter-developer / react-developer (플랫폼별) |
| EDGE_CASE | node-developer / flutter-developer / react-developer (플랫폼별) |

**Step 4: Severity별 처리**
- **CRITICAL / HIGH**: 즉시 수정 필수. 수정 후 재분석 실행
  ```
  Task(subagent_type="{mapped-agent}", prompt="""
  Fix FINDING-{id}:
  Category: {category}
  Severity: {severity}
  File: {file}
  Description: {description}
  Suggested Fix: {suggested_fix}

  Feature: {feature}
  Brief: docs/{product}/{feature}/{platform}-brief.md
  """)
  ```
- **MEDIUM**: 1회 시도. 실패해도 진행 가능
- **LOW**: 리포트에 기록만 (수정 시도 안 함)

**Step 5: 재분석**
수정 완료 후 gap-detector 재실행하여 matchRate 갱신

**Step 6: 중단 조건**
- Match Rate >= 90% 도달 → 중단, report로 진행
- 최대 5회 이터레이션 도달 → 중단, 현재 상태로 report

**Alternative: Ralph Loop 반복 개선**

FINDINGS가 단일 플랫폼에 집중되어 있거나, 에이전트 디스패치 오버헤드가 큰 경우 Ralph Loop로 대체할 수 있습니다:

```
AskUserQuestion(
  question: "Iterate 실행 방식을 선택해주세요.",
  options: [
    "에이전트 디스패치 (Recommended)" — 카테고리별 전문 에이전트 투입,
    "Ralph Loop 자율 수정" — 단일 에이전트가 FINDINGS를 순회하며 수정
  ]
)
```

**Ralph Loop Iterate 실행 시:**
```
PROMPT = """
Feature: {feature}
Analysis: docs/{product}/{feature}/analysis.md
Brief: docs/{product}/{feature}/{platform}-brief.md

analysis.md의 FINDINGS를 Severity 순(CRITICAL → HIGH → MEDIUM)으로 수정하세요.
LOW severity는 수정하지 않습니다.
각 FINDING 수정 후 검증 명령어를 실행하세요.

모든 CRITICAL/HIGH FINDINGS 수정 완료 후 <promise>ITERATE COMPLETE</promise>를 출력하세요.
"""

Skill("ralph-loop:ralph-loop", args="{PROMPT} --max-iterations 10 --completion-promise 'ITERATE COMPLETE'")

# 완료 후 gap-detector 재실행하여 matchRate 갱신
```

| 상황 | 권장 방식 | 이유 |
|------|----------|------|
| FINDINGS가 여러 카테고리에 분산 | 에이전트 디스패치 | 전문성 활용 (보안→security-specialist 등) |
| FINDINGS가 단일 플랫폼에 집중 | Ralph Loop | 컨텍스트 전환 없이 연속 수정 |
| CRITICAL 보안 이슈 포함 | 에이전트 디스패치 | security-specialist의 전문 지식 필수 |
| 빌드/린트 에러 다수 | Ralph Loop | 반복 빌드→수정 사이클에 최적 |

**Step 7: Task 생성**
`TaskCreate: [Act-N] {feature}` (N = iteration count)
