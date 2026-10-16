#!/bin/bash
# Notification hook: WeChat + desktop + voice when Claude needs attention
set -euo pipefail

HOOK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=agent/hooks/notifications/common.sh
source "$HOOK_DIR/common.sh"

INPUT=$(cat)
NOTIFY_TYPE=$(jq -r '.notification_type // "task"' <<<"$INPUT")
MESSAGE=$(jq -r '.message // ""' <<<"$INPUT")

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROJECT=$(basename "$PROJECT_DIR")
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "N/A")

case "$NOTIFY_TYPE" in
    permission) VOICE_TEXT="需要授权" ;;
    *)          VOICE_TEXT="任务完成，请确认" ;;
esac

# WeChat notification via Server酱
load_notification_key "$PROJECT_DIR/.claude/.env"
if [[ -n "$SCT_SENDKEY" ]]; then
    UNCOMMITTED=$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    # Single git diff call, single while-read pass computes both adds + dels
    DIFF_STATS=$(git -C "$PROJECT_DIR" diff --numstat 2>/dev/null || true)
    collect_diff_totals "$DIFF_STATS"

    STATS="📝 ${UNCOMMITTED}未提交"
    [[ "$TOTAL_ADDS" -gt 0 || "$TOTAL_DELS" -gt 0 ]] && STATS="📈 +${TOTAL_ADDS} −${TOTAL_DELS}  ${STATS}"

    TITLE="[Claude] ${VOICE_TEXT}"
    DESP="## ${PROJECT} · ${BRANCH}

> ${MESSAGE:-Claude 需要你的关注}

${STATS}"

    (send_notification "$TITLE" "$DESP" || true) >/dev/null 2>&1 &
fi

# Pass message text as an argument, not as executable AppleScript source.
if command -v osascript >/dev/null 2>&1; then
    osascript - "${MESSAGE:-Claude 需要你的关注}" <<'APPLESCRIPT' 2>/dev/null || true
on run argv
    display notification (item 1 of argv) with title "Claude Code"
end run
APPLESCRIPT
fi

if command -v say >/dev/null 2>&1; then
    nohup say "$VOICE_TEXT" >/dev/null 2>&1 &
fi
exit 0
