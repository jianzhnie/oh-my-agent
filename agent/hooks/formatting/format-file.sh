#!/bin/bash
# PostToolUse hook: auto-format edited files and shellcheck .sh files
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")
TOOL_NAME=$(jq -r '.tool_name // "Edit"' <<<"$INPUT")
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
[[ -z "$FILE_PATH" ]] && exit 0
if [[ "$FILE_PATH" != /* ]]; then
    FILE_PATH="$PROJECT_DIR/$FILE_PATH"
fi

# File must exist and be a regular file
[[ ! -f "$FILE_PATH" ]] && exit 0

# Skip binary and non-text files (images, archives, compiled files, etc.)
case "${FILE_PATH##*.}" in
    pyc|so|o|a|dylib|wasm|bin|exe|dll) exit 0 ;;
    png|jpg|jpeg|gif|svg|ico|webp|bmp)  exit 0 ;;
    zip|tar|gz|bz2|xz|7z|rar)            exit 0 ;;
    woff|woff2|ttf|eot|otf)             exit 0 ;;
    mp3|mp4|wav|avi|mov|webm)           exit 0 ;;
    pdf|doc|docx|xls|xlsx|pptx)         exit 0 ;;
esac

# Log edits; the session summary groups repeated file paths.
EDIT_LOG="$PROJECT_DIR/.claude/.session-edits"
echo "${FILE_PATH}|${TOOL_NAME}" >> "$EDIT_LOG"

OUTPUT=""

# Step 1: run pre-commit auto-format on all edited files
if command -v pre-commit >/dev/null 2>&1; then
    FORMAT_RESULT=$(cd "$PROJECT_DIR" && pre-commit run --files "$FILE_PATH" 2>&1) || true
else
    FORMAT_RESULT="Skipped formatting: pre-commit is not installed."
fi
if [[ -n "$FORMAT_RESULT" ]]; then
    OUTPUT+="${FORMAT_RESULT}"
fi

# Step 2: run shellcheck on .sh files
if [[ "$FILE_PATH" == *.sh ]] && command -v shellcheck >/dev/null 2>&1; then
    SHELLCHECK_RESULT=$(shellcheck "$FILE_PATH" 2>&1) || true
    if [[ -n "$SHELLCHECK_RESULT" ]]; then
        [[ -n "$OUTPUT" ]] && OUTPUT+=$'\n'
        OUTPUT+="${SHELLCHECK_RESULT}"
    fi
fi

# Report aggregated results
if [[ -n "$OUTPUT" ]]; then
    jq -nc --arg msg "$OUTPUT" \
        '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
fi

exit 0
