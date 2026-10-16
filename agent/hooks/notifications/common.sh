#!/bin/bash
# Shared helpers, sourced by notification hooks; this file is not a Hook entry.

load_notification_key() {
    local env_file="$1"
    SCT_SENDKEY=""
    [[ -f "$env_file" ]] || return 0
    # Read the supported key without evaluating shell content or requiring a match.
    SCT_SENDKEY=$(awk '/^SCT_SENDKEY=/{sub(/^SCT_SENDKEY=/, ""); sub(/\r$/, ""); print; exit}' "$env_file")
}

collect_diff_totals() {
    local stats="$1" adds dels rest
    TOTAL_ADDS=0
    TOTAL_DELS=0
    while IFS=$'\t' read -r adds dels rest; do
        # Git uses '-' for binary files; they have no line counts.
        [[ "$adds" =~ ^[0-9]+$ && "$dels" =~ ^[0-9]+$ ]] || continue
        TOTAL_ADDS=$((TOTAL_ADDS + adds))
        TOTAL_DELS=$((TOTAL_DELS + dels))
    done <<< "$stats"
}

send_notification() {
    local title="$1" description="$2"
    [[ -n "${SCT_SENDKEY:-}" ]] || return 0
    command -v curl >/dev/null 2>&1 || return 0
    curl --silent --show-error --connect-timeout 2 --max-time 4 \
        --data-urlencode "title=${title}" \
        --data-urlencode "desp=${description}" \
        "https://sctapi.ftqq.com/${SCT_SENDKEY}.send" \
        -o /dev/null
}
