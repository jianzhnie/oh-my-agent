#!/bin/bash
# SessionStart hook: initialize startup state or restore context after compaction.
set -euo pipefail

INPUT=$(cat)
SOURCE=$(jq -r '.source // empty' <<<"$INPUT")
case "$SOURCE" in
    startup|compact) ;;
    *) exit 0 ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
STATE_DIR="$PROJECT_DIR/.claude"
PROJECT_NAME=$(basename "$PROJECT_DIR")

if [[ "$SOURCE" == "startup" ]]; then
    mkdir -p "$STATE_DIR"
    date -u +%s > "$STATE_DIR/.session-start"
    COMMAND_LOG="$STATE_DIR/command-log.txt"
    if [[ -f "$COMMAND_LOG" ]]; then
        wc -l < "$COMMAND_LOG" | tr -d ' ' > "$STATE_DIR/.session-cmd-start"
    else
        echo "0" > "$STATE_DIR/.session-cmd-start"
    fi
    :> "$STATE_DIR/.session-edits"
    echo "## Session started: ${PROJECT_NAME}"
    echo "Python: $(python --version 2>/dev/null || echo 'N/A')"
else
    echo "## Post-compaction restore — ${PROJECT_NAME}"
fi

echo ""
echo "Branch: $(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo 'N/A')"
STATUS=$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null || true)
CHANGES=$(grep -c . <<< "$STATUS" || true)
echo "Uncommitted changes: ${CHANGES} file(s)"
if [[ "$SOURCE" == "startup" ]]; then
    [[ -z "$STATUS" ]] || git -C "$PROJECT_DIR" status --short 2>/dev/null || true
else
    STASHES=$(git -C "$PROJECT_DIR" stash list 2>/dev/null || true)
    STASH_COUNT=$(grep -c . <<< "$STASHES" || true)
    [[ "$STASH_COUNT" -eq 0 ]] || echo "Stashes: ${STASH_COUNT}"
    echo ""
    echo "### Recent commits"
    git -C "$PROJECT_DIR" log --oneline -5 2>/dev/null || echo "(no git history)"
    echo ""
    echo "### Reference"
    echo "- CLAUDE.md, .claude/rules/, .claude/agents/ for full conventions"
fi
exit 0
