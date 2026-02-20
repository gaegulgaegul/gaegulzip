# report (Completion Report) — report-generator Agent

1. Verify matchRate >= 90% (warn if below)
2. **Call report-generator Agent**
3. Integrated report of Plan, Design, Implementation, Analysis
4. **CHANGELOG 자동 생성**
5. Create Task: `[Report] {feature}`
6. Update status: phase = "completed"

**Output Path**: `docs/{product}/{feature}/report.md`

**Step 3.5: report.md 추가 섹션 (MANDATORY)**

report-generator가 생성한 report.md에 아래 3개 섹션을 반드시 포함합니다:

```markdown
## 배포 가이드
- 배포 환경 및 절차 (Vercel, App Store, Play Store 등)
- 필요한 환경변수/시크릿 목록
- 배포 전 체크리스트

## 유지보수 가이드
- 주요 파일 위치 및 역할 요약
- 수정 시 주의사항 (의존성, 사이드이펙트)
- 모니터링/로깅 포인트

## v2 개선 제안
- 구현 중 발견한 개선 가능 사항
- Plan 단계에서 v2로 분류했던 "Nice to Have" 항목 재검토
- 사용자 피드백 기반 우선순위 제안
```

> 이 섹션들은 사용자가 이 대화 이후에도 독립적으로 제품을 유지/발전시킬 수 있도록 하는 "핸드오프" 역할을 합니다.

**Step 4: CHANGELOG 자동 생성**

Feature 시작 이후의 git 변경사항을 추출하여 CHANGELOG.md에 추가합니다.

```
# Feature 시작 시점 확인
Read(".pdca-status.json") → features.{feature}.startedAt

# git log에서 해당 시점 이후 변경사항 추출
Bash("git log --oneline --after={startedAt} --format='%h %s'")

# CHANGELOG.md에 추가 (파일 상단에)
## [{feature}] - {date}

### Added
- {새로 추가된 기능}

### Changed
- {변경된 기능}

### Fixed
- {수정된 버그}

### Documents
- Plan: docs/{product}/{feature}/user-story.md
- Design: docs/{product}/{feature}/{platform}-brief.md
- Analysis: docs/{product}/{feature}/analysis.md
- Report: docs/{product}/{feature}/report.md
```
