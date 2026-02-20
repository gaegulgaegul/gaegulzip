#!/bin/bash
# context-recovery.sh — SessionStart(compact) Hook
# 컨텍스트 압축 후 핵심 정보를 재주입합니다.
# 소스: PDCA 상태 + Serena 메모리 + claude-mem + git log + auto memory
# 출력: stdout → Claude의 additionalContext로 주입
# 제한: 2000자 이내 (컨텍스트 효율성)

set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
MAX_CHARS=2000
OUTPUT=""

append() {
    local section="$1"
    local current_len=${#OUTPUT}
    local section_len=${#section}
    if (( current_len + section_len < MAX_CHARS )); then
        OUTPUT+="$section"
    fi
}

# ─── 1. PDCA 상태 (가장 중요) ───
STATUS_FILE="$PROJECT_ROOT/docs/.pdca-status.json"
if [ -f "$STATUS_FILE" ]; then
    PDCA_INFO=$(python3 -c "
import json
try:
    with open('$STATUS_FILE') as f:
        data = json.load(f)
    primary = data.get('primaryFeature', '')
    features = data.get('features', {})
    lines = []
    for name, info in features.items():
        phase = info.get('phase', '?')
        platform = info.get('platform', '?')
        mr = info.get('matchRate')
        ft = info.get('frontendType', '')
        if phase not in ('completed', 'archived'):
            entry = f'{name}({platform}'
            if ft: entry += f'/{ft}'
            entry += f', {phase}'
            if mr is not None: entry += f', {mr}%'
            entry += ')'
            lines.append(entry)
    if lines:
        print('[PDCA] ' + ', '.join(lines[:3]))
    if primary:
        print(f'[Primary] {primary}')
except Exception:
    pass
" 2>/dev/null)
    [ -n "$PDCA_INFO" ] && append "$PDCA_INFO
"
fi

# ─── 2. Serena 메모리 (프로젝트 지식) ───
SERENA_DIR="$PROJECT_ROOT/.serena/memories"
if [ -d "$SERENA_DIR" ]; then
    MEMORY_FILES=$(ls "$SERENA_DIR"/*.md 2>/dev/null)
    if [ -n "$MEMORY_FILES" ]; then
        SERENA_INFO="[Serena] Memories: "
        NAMES=""
        for f in $MEMORY_FILES; do
            basename_f=$(basename "$f" .md)
            if [ -n "$NAMES" ]; then NAMES+=", "; fi
            NAMES+="$basename_f"
        done
        SERENA_INFO+="$NAMES (read_memory로 조회 가능)"
        append "$SERENA_INFO
"
    fi
fi

# ─── 3. claude-mem 최근 결정/버그 (sqlite3) ───
CLAUDE_MEM_DB="$HOME/.claude-mem/claude-mem.db"
if [ -f "$CLAUDE_MEM_DB" ] && command -v sqlite3 &>/dev/null; then
    # 이 프로젝트의 최근 결정(decision)과 버그픽스(bugfix)를 가져옴
    PROJECT_NAME=$(basename "$PROJECT_ROOT")
    MEM_INFO=$(sqlite3 "$CLAUDE_MEM_DB" "
        SELECT type || ': ' || title
        FROM observations
        WHERE project LIKE '%${PROJECT_NAME}%'
          AND type IN ('decision', 'bugfix', 'feature')
        ORDER BY created_at_epoch DESC
        LIMIT 5;
    " 2>/dev/null | head -5)
    if [ -n "$MEM_INFO" ]; then
        append "[claude-mem] Recent:
"
        while IFS= read -r line; do
            append "  - $line
"
        done <<< "$MEM_INFO"
    fi
fi

# ─── 4. git 최근 커밋 ───
if command -v git &>/dev/null && [ -d "$PROJECT_ROOT/.git" ]; then
    GIT_LOG=$(cd "$PROJECT_ROOT" && git log --oneline -5 2>/dev/null || echo "")
    if [ -n "$GIT_LOG" ]; then
        append "[git] Recent commits:
"
        while IFS= read -r line; do
            append "  $line
"
        done <<< "$GIT_LOG"
    fi
fi

# ─── 5. auto memory 핵심 정보 ───
AUTO_MEM="$HOME/.claude/projects/-Users-lms-dev-repository-gaegulzip/memory/MEMORY.md"
if [ -f "$AUTO_MEM" ]; then
    # 첫 번째 ## 헤더까지만 읽어서 핵심 요약 추출
    MEM_SUMMARY=$(head -5 "$AUTO_MEM" 2>/dev/null | tr '\n' ' ')
    if [ -n "$MEM_SUMMARY" ]; then
        append "[auto-memory] $MEM_SUMMARY
"
    fi
fi

# ─── 6. 복구 우선순위 안내 ───
append "[Recovery] 압축 후 복구 우선순위: (1) .pdca-status.json (2) work-plan.md/brief.md (3) git diff (4) CLAUDE.md
"

# ─── 출력 ───
if [ -n "$OUTPUT" ]; then
    # 최종 길이 제한
    if (( ${#OUTPUT} > MAX_CHARS )); then
        OUTPUT="${OUTPUT:0:$((MAX_CHARS - 3))}..."
    fi
    echo "$OUTPUT"
fi

exit 0
