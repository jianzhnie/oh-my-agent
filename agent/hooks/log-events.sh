#!/bin/bash
# PostToolUse/Bash and SubagentStart hook: append events to the session command log
set -euo pipefail

INPUT=$(cat)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT")

case "$EVENT" in
    PostToolUse)
        TOOL_NAME=$(jq -r '.tool_name // empty' <<<"$INPUT")
        [[ "$TOOL_NAME" != "Bash" ]] && exit 0
        MESSAGE=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
        [[ -z "$MESSAGE" ]] && exit 0
        ;;
    SubagentStart)
        AGENT_TYPE=$(jq -r '.agent_type // "unknown"' <<<"$INPUT")
        MESSAGE="agent:spawn ${AGENT_TYPE}"
        ;;
    *) exit 0 ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$MESSAGE" >> "${PROJECT_DIR}/.claude/command-log.txt"
exit 0
