---
name: shell-check
description: "Validate shell scripts with both syntax check (bash -n) and static analysis (shellcheck). Usage: /shell-check [file_or_dir] — defaults to tracked and untracked, non-ignored .sh files in the current Git repository."
version: 1.0.0
author: Robin
license: Apache-2.0
platforms: [linux, macos, windows]
metadata:
  tags: [Check, Skill, Shell, Lint, Static-Analysis]
  related_skills: [check]
---
Run both bash syntax validation and shellcheck static analysis on the specified target.

## If the user provides a file path

Run both checks on that single file:

```bash
bash -n "$TARGET" 2>&1
shellcheck "$TARGET" 2>&1
```

## Directory or default repository target

Use Bash and NUL-delimited filenames so spaces and nested paths are handled correctly.
Check that `shellcheck` is installed before running; report it as unavailable if missing,
and still run `bash -n`. Do not report a missing tool as a passing check.

For a directory argument, collect files using:

```bash
find "$TARGET" -type f -name '*.sh' -print0
```

With no argument, collect tracked and untracked, non-ignored Shell files from
`git rev-parse --show-toplevel`. Outside a Git repository, request a target directory.

```bash
git ls-files --cached --others --exclude-standard -z -- '*.sh'
```

Consume the selected file list with a Bash loop, running both checks for each
existing file. Continue after individual failures and aggregate the results:

```bash
while IFS= read -r -d '' file; do
    [[ -f "$file" ]] || continue
    bash -n "$file"
    shellcheck "$file"
done < <(find "$TARGET" -type f -name '*.sh' -print0)
```

The loop is an execution pattern, not a pass/fail summary: record each command's
exit status explicitly, and do not enable `set -e` in a way that stops at the first
failure. For repository mode, run from the repository root and replace `find`
with the `git ls-files` command above. Deduplicate filenames before checking if
the selected source yields duplicates.

## Reporting

For each file, report:
- **Syntax check** (`bash -n`): PASS or FAIL with parse error details
- **Static analysis** (`shellcheck`): PASS or clean, or list issues with file, line, severity (error/warning/info), and message

Give a final summary: total files checked, syntax pass/fail count, shellcheck clean/issue count.
