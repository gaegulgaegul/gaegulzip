#!/bin/bash
# sql-injection-check.sh — PostToolUse Hook (Edit|Write)
# TS/TSX 파일에서 SQL 인젝션 위험 패턴 탐지
# stdin: JSON with tool_input.file_path

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('file_path', ti.get('filePath', '')))
except:
    print('')
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

EXT="${FILE_PATH##*.}"

# TS/TSX 파일만 검사
if [[ "$EXT" != "ts" && "$EXT" != "tsx" ]]; then
    exit 0
fi

# 파일이 존재하는지 확인
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

WARNINGS=""

# 패턴 1: sql`...${  (템플릿 리터럴 내 변수 삽입)
if grep -Pn 'sql`[^`]*\$\{' "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}\n- sql 템플릿 리터럴 내 직접 변수 삽입 (sql\`...\${var}\`) 발견. Drizzle의 파라미터 바인딩을 사용하세요."
fi

# 패턴 2: .raw( 뒤에 변수 삽입
if grep -Pn '\.raw\s*\([^)]*\$\{' "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}\n- .raw() 호출 내 변수 삽입 발견. 파라미터화된 쿼리를 사용하세요."
fi

# 패턴 3: 문자열 연결로 SQL 구성
if grep -Pn '(SELECT|INSERT|UPDATE|DELETE|WHERE|FROM)\s*["\x27]\s*\+' "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}\n- 문자열 연결로 SQL 쿼리 구성 발견. ORM 또는 파라미터 바인딩을 사용하세요."
fi

# 패턴 4: execute(` 내 변수 삽입
if grep -Pn 'execute\s*\(\s*`[^`]*\$\{' "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}\n- execute() 내 템플릿 리터럴 변수 삽입 발견. 파라미터 바인딩을 사용하세요."
fi

if [ -n "$WARNINGS" ]; then
    echo "[sql-injection-check] SQL 인젝션 위험 패턴 탐지:"
    echo -e "$WARNINGS"
    echo ""
    echo "권장: Drizzle ORM의 쿼리 빌더 또는 sql\`\${placeholder}\` 패턴을 사용하세요."
fi

exit 0
