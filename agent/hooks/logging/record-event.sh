#!/bin/bash
# Record tool, agent, configuration and failure events in their existing logs.
set -euo pipefail

INPUT=$(cat)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT")
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
STATE_DIR="$PROJECT_DIR/.claude"

case "$EVENT" in
    PostToolUse)
        TOOL_NAME=$(jq -r '.tool_name // empty' <<<"$INPUT")
        [[ "$TOOL_NAME" != "Bash" ]] && exit 0
        MESSAGE=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
        [[ -z "$MESSAGE" ]] && exit 0
        LOG_FILE="$STATE_DIR/command-log.txt"
        ;;
    SubagentStart)
        AGENT_TYPE=$(jq -r '.agent_type // "unknown"' <<<"$INPUT")
        MESSAGE="agent:spawn ${AGENT_TYPE}"
        LOG_FILE="$STATE_DIR/command-log.txt"
        ;;
    StopFailure)
        ERROR_TYPE=$(jq -r '.error_type // "unknown"' <<<"$INPUT")
        MESSAGE="StopFailure: ${ERROR_TYPE}"
        LOG_FILE="$STATE_DIR/stop-failure.log"
        ;;
    ConfigChange)
        mkdir -p "$STATE_DIR"
        jq -c '{timestamp: now | todate, source: .source, file: .file_path, change_type: .change_type}' \
            <<<"$INPUT" >> "$STATE_DIR/config-audit.log"
        exit 0
        ;;
    *) exit 0 ;;
esac

mkdir -p "$STATE_DIR"
printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$MESSAGE" >> "$LOG_FILE"
exit 0
