#!/bin/bash
# auto-validate.sh — PostToolUse Hook (Edit|Write)
# TS/Dart 파일 수정 시 자동 타입체크 + 린트 실행
# stdin: JSON with tool_input.file_path

set -euo pipefail

# stdin에서 JSON 읽기
INPUT=$(cat)

# file_path 추출 (Edit/Write 도구의 tool_input에서)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # tool_input.file_path 또는 tool_input.filePath
    ti = data.get('tool_input', {})
    print(ti.get('file_path', ti.get('filePath', '')))
except:
    print('')
" 2>/dev/null)

# 파일 경로가 비어있으면 종료
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# 확장자 추출
EXT="${FILE_PATH##*.}"

case "$EXT" in
    ts|tsx)
        # TypeScript: tsc --noEmit
        PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)

        # 파일이 어느 앱에 속하는지 판별
        if [[ "$FILE_PATH" == *"apps/server/"* ]]; then
            TSCONFIG="$PROJECT_ROOT/apps/server/tsconfig.json"
        elif [[ "$FILE_PATH" == *"apps/web/admin/"* ]]; then
            TSCONFIG="$PROJECT_ROOT/apps/web/admin/tsconfig.json"
        elif [[ "$FILE_PATH" == *"apps/web/talmosang/"* ]]; then
            TSCONFIG="$PROJECT_ROOT/apps/web/talmosang/tsconfig.json"
        else
            exit 0
        fi

        if [ -f "$TSCONFIG" ]; then
            OUTPUT=$(cd "$(dirname "$TSCONFIG")" && npx tsc --noEmit --pretty 2>&1) || {
                echo "[auto-validate] TypeScript 타입 에러 발견:"
                echo "$OUTPUT"
                exit 0  # Hook은 exit 0으로 피드백만 제공
            }
        fi
        ;;

    dart)
        # Dart: dart analyze (가장 가까운 pubspec.yaml 기준)
        SEARCH_DIR="$FILE_PATH"
        while [ "$SEARCH_DIR" != "/" ]; do
            SEARCH_DIR=$(dirname "$SEARCH_DIR")
            if [ -f "$SEARCH_DIR/pubspec.yaml" ]; then
                OUTPUT=$(cd "$SEARCH_DIR" && dart analyze --no-fatal-infos 2>&1) || {
                    echo "[auto-validate] Dart 분석 에러 발견:"
                    echo "$OUTPUT"
                    exit 0
                }
                break
            fi
        done
        ;;

    md|json|yaml|yml|sh|txt|html|css|env|gitignore|lock)
        # 비코드 파일 → 즉시 통과
        exit 0
        ;;

    *)
        exit 0
        ;;
esac

exit 0
