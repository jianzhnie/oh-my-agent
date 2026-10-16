#!/bin/bash
# SessionEnd hook: send session summary to WeChat via Server酱
set -euo pipefail

HOOK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=agent/hooks/notifications/common.sh
source "$HOOK_DIR/../notifications/common.sh"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SESSION_FILE="${PROJECT_DIR}/.claude/.session-start"

# Load SCT_SENDKEY
load_notification_key "$PROJECT_DIR/.claude/.env"
[[ -z "${SCT_SENDKEY:-}" ]] && exit 0

# --- Collect data ---

# Duration
if [[ -f "$SESSION_FILE" ]]; then
    START_TIME=$(cat "$SESSION_FILE")
    END_TIME=$(date +%s)
    DURATION_SEC=$((END_TIME - START_TIME))
    if (( DURATION_SEC < 60 )); then
        DURATION="${DURATION_SEC}s"
    else
        DURATION="$((DURATION_SEC / 60))m$((DURATION_SEC % 60))s"
    fi
    rm -f "$SESSION_FILE"
else
    DURATION="?"
fi

# Commands run this session
CMD_COUNT=0
CMD_START_FILE="${PROJECT_DIR}/.claude/.session-cmd-start"
if [[ -f "${PROJECT_DIR}/.claude/command-log.txt" && -f "$CMD_START_FILE" ]]; then
    START_LINES=$(cat "$CMD_START_FILE")
    END_LINES=$(wc -l < "${PROJECT_DIR}/.claude/command-log.txt" | tr -d ' ')
    CMD_COUNT=$((END_LINES - START_LINES))
    [[ $CMD_COUNT -lt 0 ]] && CMD_COUNT=0
    rm -f "$CMD_START_FILE"
fi

# Git info — single status call
cd "$PROJECT_DIR"
BRANCH=$(git branch --show-current 2>/dev/null || echo "?")

# Use git status --porcelain=v2 for richer parseable output in one call
STATUS_OUT=$(git status --porcelain=2 --branch 2>/dev/null || true)
# Count ordinary, renamed, conflicted and untracked entries, excluding headers.
UNCOMMITTED=$(grep -cE '^[12u?]' <<< "$STATUS_OUT" || true)

# Sum text line counts; binary files remain in the file list.
DIFF_STATS=$(git diff --numstat 2>/dev/null || true)
DIFF_FILES=""
collect_diff_totals "$DIFF_STATS"
while IFS=$'\t' read -r adds dels file; do
    [[ -z "$file" ]] && continue
    DIFF_FILES+="  \`${file}\` +${adds} −${dels}\n"
done <<< "$DIFF_STATS"
FILE_COUNT=$(wc -l <<< "$DIFF_STATS" | tr -d ' ')
[[ "$DIFF_STATS" == "" ]] && FILE_COUNT=0

# Staged diff stats: single awk pass
STAGED_STATS=$(git diff --cached --numstat 2>/dev/null || true)
STAGED_ADDS=$(awk '{s+=$1}END{print s+0}' <<< "$STAGED_STATS")
STAGED_DELS=$(awk '{s+=$2}END{print s+0}' <<< "$STAGED_STATS")
STAGED_FILES=$(wc -l <<< "$STAGED_STATS" | tr -d ' ')
[[ "$STAGED_STATS" == "" ]] && STAGED_FILES=0

# Commits this session
COMMITS=""
if [[ -n "${START_TIME:-}" ]]; then
    COMMITS=$(git log --max-count=5 --oneline --since="@${START_TIME}" 2>/dev/null || true)
fi

# Edited files this session
EDIT_LOG="${PROJECT_DIR}/.claude/.session-edits"
EDIT_SUMMARY=""
if [[ -f "$EDIT_LOG" && -s "$EDIT_LOG" ]]; then
    TOTAL_EDITS=$(wc -l < "$EDIT_LOG" | tr -d ' ')
    EDIT_FILES=$(awk -F'|' '{files[$1]++} END{for(f in files) printf "  \`%s\` ×%d\n", f, files[f]}' "$EDIT_LOG" | sort)
    EDIT_SUMMARY="📝 **编辑** ${TOTAL_EDITS}次 / $(echo "$EDIT_FILES" | wc -l | tr -d ' ')个文件
${EDIT_FILES}

"
    rm -f "$EDIT_LOG"
fi

# --- Build message ---

PROJECT=$(basename "$PROJECT_DIR")

# Build diff stat line
DIFF_LINE=""
if [[ "${FILE_COUNT:-0}" -gt 0 ]]; then
    DIFF_LINE="📈 **变更** +${TOTAL_ADDS} −${TOTAL_DELS} / ${FILE_COUNT}文件"
    [[ "${STAGED_FILES:-0}" -gt 0 ]] && DIFF_LINE+="  (已暂存 +${STAGED_ADDS} −${STAGED_DELS})"
fi

TITLE="[Claude] ${PROJECT} · ${BRANCH}"

DESP="## ${PROJECT} · ${BRANCH}

> ⏱ ${DURATION}  ⚡ ${CMD_COUNT}命令  📝 ${UNCOMMITTED}未提交"

[[ -n "$DIFF_LINE" ]] && DESP+="
${DIFF_LINE}"

[[ -n "$DIFF_FILES" ]] && DESP+="

### 📁 文件变更
${DIFF_FILES}"

[[ -n "$EDIT_SUMMARY" ]] && DESP+="

${EDIT_SUMMARY}"

[[ -n "$COMMITS" ]] && DESP+="
### 📦 提交
\`\`\`
${COMMITS}
\`\`\`"

# Truncate
MAX_LEN=2000
if [[ ${#DESP} -gt $MAX_LEN ]]; then
    DESP="${DESP:0:$MAX_LEN}..."
fi

# --- Send ---
send_notification "$TITLE" "$DESP" || true

# Cleanup
rm -f "${PROJECT_DIR}"/.claude/tmp-*.txt 2>/dev/null || true
