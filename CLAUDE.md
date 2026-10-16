# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

oh-my-claude-code 是一套 Claude Code 配置集合，包含自定义 Agents、Skills、Hooks、Rules 和 MCP 服务器配置。

## 目录结构

```
agent/
├── agents/          # 9 个自定义 Agent 定义
├── skills/          # 自定义 Skill
├── hooks/           # 按职责分组的生命周期钩子
├── scripts/         # 状态栏等运行脚本
├── tests/           # 隔离回归测试
├── rules/           # 代码规范（Python、Shell、Git）
├── output-styles/   # 回复风格模板
└── settings.json    # 项目级配置
```

配置源保存在 `agent/`；运行时部署仍使用 `.claude/`，详见 `agent/README.md`。

## 常用命令

```bash
# 安装开发依赖并配置 pre-commit
pip install -e ".[dev]"
pre-commit install

# 运行 pre-commit 检查
pre-commit run --all-files

# Lint 和格式化
ruff check .
ruff format .

# 类型检查
mypy .

# 运行测试
pytest
```

## Agent 定义

9 个自定义 Agent 位于 `agent/agents/`：`architect`、`code-reviewer`、`debugger`、`documentation-writer`、`library-integration`、`performance-analyzer`、`refactor`、`shell-expert`、`test-writer`。

## Hook 生命周期

| 事件 | Hook | 用途 |
|------|------|------|
| SessionStart | `hooks/session/context.sh` | 记录会话开始状态 |
| SessionStart/compact | `hooks/session/context.sh` | compact 后恢复关键上下文 |
| PreToolUse | `hooks/tools/guard-tool.sh` | 拦截危险命令和敏感文件写入 |
| PostToolUse | `hooks/tools/format-file.sh` | 自动格式化 + shellcheck |
| PostToolUse/Bash | `hooks/logging/record-event.sh` | 记录所有 Bash 命令 |
| Notification | `hooks/notifications/notify.sh` | 桌面/语音通知 |
| SessionEnd | `hooks/session/summarize.sh` | 会话摘要推送 |
| StopFailure | `hooks/logging/record-event.sh` | 记录异常停止 |
| ConfigChange | `hooks/logging/record-event.sh` | 审计配置变更 |
| SubagentStart | `hooks/logging/record-event.sh` | 记录 Agent 调用 |

## 代码规范

- Git: Conventional Commits (`type(scope): description`)，见 `agent/rules/git-conventions.md`
- Python: `agent/rules/python-style.md` — 基于 Google Style Guide，Python 3.10+
- Shell: `agent/rules/shell-style.md` — `set -euo pipefail`，`[[ ]]`，双引号变量

## 安全防护

`hooks/tools/guard-tool.sh` 会自动拦截：
- `rm -rf` 操作系统目录
- 写入 `.env` 文件
- `git push --force`
- 直接 push main/master 分支
- 编辑 `package-lock.json` 和 `.git/` 目录
