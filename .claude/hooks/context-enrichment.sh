#!/bin/bash
# context-enrichment.sh — UserPromptSubmit Hook
# PDCA 상태 + 단계별 코칭 힌트 + 목표 반복 주입(Recitation Pattern) + 최근 git 변경사항
# 프롬프트 코칭 지시는 CLAUDE.md Core Principles에서 관리 (더 강한 권한)
# 1500자 이내

set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
STATUS_FILE="$PROJECT_ROOT/docs/.pdca-status.json"

# PDCA 상태 추출
PDCA_INFO=""
if [ -f "$STATUS_FILE" ]; then
    PDCA_INFO=$(python3 -c "
import json, sys
try:
    with open('$STATUS_FILE') as f:
        data = json.load(f)
    primary = data.get('primaryFeature', '')
    features = data.get('features', {})
    active = []
    for name, info in features.items():
        phase = info.get('phase', '?')
        platform = info.get('platform', '?')
        mr = info.get('matchRate', '-')
        if phase != 'completed' and phase != 'archived':
            active.append(f'{name}({platform}/{phase})')
    if active:
        print(f'Active: {\", \".join(active[:3])}')
    if primary and primary in features:
        p = features[primary]
        print(f'Primary: {primary} phase={p.get(\"phase\",\"?\")} platform={p.get(\"platform\",\"?\")}')
except Exception as e:
    print(f'PDCA: error reading status')
" 2>/dev/null)
fi

# 최근 git 변경사항
GIT_LOG=""
if command -v git &>/dev/null && [ -d "$PROJECT_ROOT/.git" ]; then
    GIT_LOG=$(cd "$PROJECT_ROOT" && git log --oneline -3 2>/dev/null || echo "")
fi

# PDCA 단계별 가이드 힌트 생성 + Recitation Pattern (목표 반복 주입)
PHASE_HINT=""
if [ -f "$STATUS_FILE" ]; then
    PHASE_HINT=$(python3 -c "
import json, glob, os

PROJECT_ROOT = '$PROJECT_ROOT'

try:
    with open('$STATUS_FILE') as f:
        data = json.load(f)
    primary = data.get('primaryFeature', '')
    if primary and primary in data.get('features', {}):
        p = data['features'][primary]
        phase = p.get('phase', '')
        mr = p.get('matchRate', '')
        platform = p.get('platform', '')
        ft = p.get('frontendType', '')

        # 단계별 네비게이션 힌트
        hints = {
            'research': 'Tip: research 완료 후 /pdca plan 으로 사용자 스토리 작성',
            'plan': 'Tip: Plan 승인 후 /pdca design 으로 설계 시작',
            'design': 'Tip: 설계 완료 후 /pdca do 로 구현 시작',
            'do': 'Tip: 구현 완료 후 /pdca analyze 로 갭 분석',
            'analyze': f'Tip: matchRate={mr}% — ' + ('/pdca iterate 로 자동 개선' if mr and int(mr) < 90 else '/pdca report 로 완료 보고서'),
            'completed': 'Tip: /pdca archive 로 문서 아카이브 가능'
        }
        hint = hints.get(phase, '')
        if hint:
            print(hint)

        # Recitation: do/check 단계에서 work-plan 목표 요약 주입
        if phase in ('do', 'analyze'):
            # 플랫폼별 work-plan 파일 탐색
            wp_prefixes = []
            if platform in ('server', 'fullstack'):
                wp_prefixes.append('server')
            if platform == 'mobile' or (platform == 'fullstack' and ft == 'mobile'):
                wp_prefixes.append('mobile')
            if platform == 'web' or (platform == 'fullstack' and ft == 'web'):
                wp_prefixes.append('web')
            for prefix in wp_prefixes:
                wp_pattern = os.path.join(PROJECT_ROOT, 'docs', '*', primary, f'{prefix}-work-plan.md')
                wp_files = glob.glob(wp_pattern)
                if wp_files:
                    with open(wp_files[0]) as wf:
                        groups = [l.strip().lstrip('#').strip() for l in wf if l.startswith('## ')]
                    if groups:
                        print(f'Goal({prefix}): ' + ' → '.join(groups[:4]))

        # 프롬프트 코칭: 현재 단계에서 프롬프트에 포함하면 좋은 구체 항목
        coaching = {
            'research': 'Coach: 포함 권장 → [핵심 사용자] [해결할 문제] [성공 기준]. 범위 넓으면 v1/v2로 분리',
            'plan': 'Coach: 포함 권장 → [구체적 제약조건] [시간 한계] [하지 말 것]. 모호하면 결과도 산만',
            'design': 'Coach: 포함 권장 → [참고 앱/화면] [기존 패턴 재사용 여부] [금지 사항]',
            'do': 'Coach: 포함 권장 → [변경 파일 범위] [영향 범위] [에러 처리 수준]. 컨텍스트 비대 시 /compact',
            'check': 'Coach: 포함 권장 → [걱정되는 부분] [엣지 케이스] [성능 기준]',
            'iterate': 'Coach: 포함 권장 → [우선 수정할 Finding] [수용할 트레이드오프]. 전체보다 핵심만 집중'
        }
        coach = coaching.get(phase, '')
        if coach:
            print(coach)
except:
    pass
" 2>/dev/null)
fi

# 핵심 규칙 강제 주입 (CLAUDE.md는 "관련 없으면 무시" 래퍼로 약화되므로 hook으로 보강)
CORE_RULES="RULES(필수): 한국어로 대화 | TODO(human) 금지—의사결정은 질의응답 | 삭제 파일은 명령어 제시 후 사용자에게 요청 | 요청된 것만 구현(Simplicity First) | 요청 관련 코드만 변경(Surgical Changes) | Serena 시맨틱 도구 우선 사용"

# additionalContext JSON 출력
python3 -c "
import json
rules = '''$CORE_RULES'''.strip()
pdca = '''$PDCA_INFO'''.strip()
git_log = '''$GIT_LOG'''.strip()
hint = '''$PHASE_HINT'''.strip()
ctx = [rules]
if pdca:
    ctx.append(pdca)
if hint:
    ctx.append(hint)
if git_log:
    ctx.append('Recent commits: ' + git_log.replace('\n', ' | '))
msg = '; '.join(ctx)
if len(msg) > 1500:
    msg = msg[:1497] + '...'
print(json.dumps({'hookSpecificOutput': {'hookEventName': 'UserPromptSubmit', 'additionalContext': msg}}))
" 2>/dev/null

exit 0
