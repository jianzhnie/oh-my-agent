---
name: check
description: Run the project's configured pre-commit checks before committing and report failures with fix hints. Equivalent to pre-commit run --all-files.
version: 1.0.0
author: Robin
license: Apache-2.0
platforms: [linux, macos, windows]
metadata:
  tags: [Check, Skill, Pre-commit, Lint, Quality]
  related_skills: [shell-check]
---
Run the complete pre-commit check suite for the project:

```bash
pre-commit run --all-files
```

Use `/check` as the unified entry point for pre-commit checks; it replaces `/precheck`.

Report results in Chinese, including each hook's actual result: PASS, FAIL, or SKIPPED.
If all applicable checks pass, report “所有检查均已通过”. If any hook fails, list
the affected files, specific issues, and fix hints. If a hook modifies files,
report those changes and rerun the checks before declaring success. Recommend
only fixers relevant to the project's configured hooks; do not assume tools such
as shellcheck, black, isort, or mypy are included.
