#!/bin/bash
# context-enrichment.sh — UserPromptSubmit Hook
# PDCA 상태 + 최근 git 변경사항을 additionalContext로 주입
# 500자 이내

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

# additionalContext JSON 출력 (500자 이내)
python3 -c "
import json
pdca = '''$PDCA_INFO'''.strip()
git_log = '''$GIT_LOG'''.strip()
ctx = []
if pdca:
    ctx.append(pdca)
if git_log:
    ctx.append('Recent commits: ' + git_log.replace('\n', ' | '))
msg = '; '.join(ctx)
# 500자 제한
if len(msg) > 500:
    msg = msg[:497] + '...'
if msg:
    print(json.dumps({'additionalContext': msg}))
" 2>/dev/null

exit 0
