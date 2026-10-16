# Claude Configuration Index

此索引以当前 `agent/` 文件为准，涵盖配置入口；技能的 references、templates、scripts 随所属技能维护，不重复计为独立配置。路径均相对本文件。

## 目录组织

```text
agent/
├── agents/          # 9 个角色定义，保持原文件名
├── commands/        # 1 个命令入口
├── rules/           # 3 份编码与 Git 规则
├── output-styles/   # 3 种输出风格
├── hooks/           # 10 个生命周期脚本，保持 settings 引用
├── skills/          # 19 个技能目录，每个包含 SKILL.md
│   └── <skill-name>/ # 按技能名直接查找，附属资源随技能保存
├── settings.json    # Claude Code 设置
├── .mcp.json        # MCP 服务器配置
├── statusline.sh    # 状态栏入口
└── README.md        # 分类索引与维护约定
```

技能按本页功能分类查找，按 `name` 定位磁盘目录。通用分析与提交前审查归入 Check；GitHub 分类仅收录平台相关操作；翻译归入 Documentation。保留 `agents/`、`commands/`、`rules/`、`output-styles/` 和 `hooks/` 的入口路径，避免改变命令名称和现有 Hook 引用。

这是配置源目录；部署目标仍使用 `.claude/` 约定。MCP 项目配置需按客户端约定放置到项目根目录；本次不自动安装或覆盖现有配置。

## 来源与维护约定

- Local Markdown 的依据为现有文件署名、仓库 Apache-2.0 许可及已有索引；Hooks、状态栏和设置的本地维护依据为 Git 历史（如 `80faff2`、`a241329`、`1cf2354`、`65be515`、`f52ed88`），未独立署名的文件不推断具体作者。
- External 的依据为文件中的外部署名及已有索引。Hermes Agent 仅能确认来源名称，仓库 URL 与引入 tag/commit 均待确认；blogwatcher 的 homepage 指向工具仓库，不能据此认定技能文件的上游。文件自身 version 不代表引入版本。
- 技能采用 `skills/<skill-name>/SKILL.md`，每个技能与附属资源整体迁移；仅修改仓库分类标签和迁移相关路径，保留运行时字段、外部署名与许可。不向脚本、JSON、模板或参考文档添加 Frontmatter。
- 分类标题使用技能首个标签：Check、GitHub、Dev、Research、Documentation。分类通过标签和本索引表达，不增加技能发现所需的目录层级。

## Agents

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| architect | [agents/architect.md](agents/architect.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | System architect for high-level design decisions. |
| code-reviewer | [agents/code-reviewer.md](agents/code-reviewer.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Expert code review specialist. |
| debugger | [agents/debugger.md](agents/debugger.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Debugging specialist for errors, test failures, crashes, and unexpected behavior. |
| doc-writer | [agents/doc-writer.md](agents/doc-writer.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Writes and updates documentation, docstrings, and inline comments. |
| library-integration | [agents/library-integration.md](agents/library-integration.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Specializes in integrating third-party libraries, SDKs, and APIs into a project. |
| perf-analyzer | [agents/perf-analyzer.md](agents/perf-analyzer.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Performance analysis specialist. |
| refactor | [agents/refactor.md](agents/refactor.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Safe code refactoring specialist. |
| shell-expert | [agents/shell-expert.md](agents/shell-expert.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Shell script specialist. |
| test-writer | [agents/test-writer.md](agents/test-writer.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Writes unit and integration tests. |

## Commands

提交前检查统一使用 `/check`（见 Skills / Check），原 `/precheck` 入口已合并。

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| status | [commands/status.md](commands/status.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Show current project status at a glance. |

## Output Styles

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Chinese-Concise | [output-styles/chinese-concise.md](output-styles/chinese-concise.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | 中文回复，简洁直接，不啰嗦不总结。适合日常开发交互。 |
| Code-Only | [output-styles/code-only.md](output-styles/code-only.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | 只输出代码和必要的 shell 命令，不解释不总结。适合明确知道要什么的快速实现场景。 |
| Diagrams-First | [output-styles/diagrams-first.md](output-styles/diagrams-first.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | 解释架构、数据流或代码结构时，先用 Mermaid 图展示，再文字说明。 |

## Rules

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| git-conventions | [rules/git-conventions.md](rules/git-conventions.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Git commit conventions for the project, including Conventional Commits format and commit rules. |
| python-style | [rules/python-style.md](rules/python-style.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Python coding style guide based on Google Python Style Guide, adapted for modern Python 3.10+. |
| shell-style | [rules/shell-style.md](rules/shell-style.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Shell script coding style guide based on Google Shell Style Guide, adapted for bash 4.2+ compatibility. |

## Skills

技能入口统一位于 `skills/<skill-name>/SKILL.md`。每个目录内的 `scripts/`、`references/`、`templates/` 保持原相对结构。

### Check

质量检查、代码库分析及提交前审查。

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| check | [skills/check/SKILL.md](skills/check/SKILL.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | 运行项目已配置的 pre-commit 检查，用中文报告结果及修复提示。 |
| shell-check | [skills/shell-check/SKILL.md](skills/shell-check/SKILL.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Validate shell scripts with both syntax check (bash -n) and static analysis (shellcheck). |
| codebase-inspection | [skills/codebase-inspection/SKILL.md](skills/codebase-inspection/SKILL.md) | 1.0.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Inspect codebases w/ pygount: LOC, languages, ratios. |
| requesting-code-review | [skills/requesting-code-review/SKILL.md](skills/requesting-code-review/SKILL.md) | 2.0.0 | Hermes Agent (adapted from obra/superpowers + MorAlekss) | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Pre-commit review: security scan, quality gates, auto-fix. |

### GitHub

GitHub 认证、Issue、PR 与仓库操作。

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| github-auth | [skills/github-auth/SKILL.md](skills/github-auth/SKILL.md) | 1.1.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | GitHub auth setup: HTTPS tokens, SSH keys, gh CLI login. |
| github-code-review | [skills/github-code-review/SKILL.md](skills/github-code-review/SKILL.md) | 1.1.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Review PRs: diffs, inline comments via gh or REST. |
| github-issues | [skills/github-issues/SKILL.md](skills/github-issues/SKILL.md) | 1.1.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Create, triage, label, assign GitHub issues via gh or REST. |
| github-pr-workflow | [skills/github-pr-workflow/SKILL.md](skills/github-pr-workflow/SKILL.md) | 1.1.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | GitHub PR lifecycle: branch, commit, open, CI, merge. |
| github-repo-management | [skills/github-repo-management/SKILL.md](skills/github-repo-management/SKILL.md) | 1.1.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Clone/create/fork repos; manage remotes, releases. |

### Dev

开发规划、调试、重构与测试方法。

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| karpathy-guidelines | [skills/karpathy-guidelines/SKILL.md](skills/karpathy-guidelines/SKILL.md) | 1.0.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Behavioral guidelines to reduce common LLM coding mistakes. |
| plan | [skills/plan/SKILL.md](skills/plan/SKILL.md) | 2.0.0 | Hermes Agent (writing-craft adapted from obra/superpowers) | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Plan mode: write an actionable markdown plan to .hermes/plans/, no execution. |
| python-debugpy | [skills/python-debugpy/SKILL.md](skills/python-debugpy/SKILL.md) | 1.0.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Debug Python: pdb REPL + debugpy remote (DAP). |
| simplify-code | [skills/simplify-code/SKILL.md](skills/simplify-code/SKILL.md) | 1.0.0 | Hermes Agent (inspired by Claude Code /simplify) | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Parallel 3-agent cleanup of recent code changes. |
| systematic-debugging | [skills/systematic-debugging/SKILL.md](skills/systematic-debugging/SKILL.md) | 1.1.0 | Hermes Agent (adapted from obra/superpowers) | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | 4-phase root cause debugging: understand bugs before fixing. |
| test-driven-development | [skills/test-driven-development/SKILL.md](skills/test-driven-development/SKILL.md) | 1.1.0 | Hermes Agent (adapted from obra/superpowers) | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | TDD: enforce RED-GREEN-REFACTOR, tests before code. |

### Research

论文检索、信息订阅与知识库维护。

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| arxiv | [skills/arxiv/SKILL.md](skills/arxiv/SKILL.md) | 1.0.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Search arXiv papers by keyword, author, category, or ID. |
| blogwatcher | [skills/blogwatcher/SKILL.md](skills/blogwatcher/SKILL.md) | 2.0.0 | JulienTant (fork of Hyaxia/blogwatcher) | MIT | External | 工具 homepage：[JulienTant/blogwatcher-cli](https://github.com/JulienTant/blogwatcher-cli)；技能上游仓库及引入版本待确认 | Monitor blogs and RSS/Atom feeds via blogwatcher-cli tool. |
| llm-wiki | [skills/llm-wiki/SKILL.md](skills/llm-wiki/SKILL.md) | 2.1.0 | Hermes Agent | MIT | External | 来源：Hermes Agent（现有署名/索引）；仓库 URL、引入版本待确认 | Karpathy's LLM Wiki: build/query interlinked markdown KB. |

### Documentation

技术文档翻译与本地化。

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| tech-doc-translator | [skills/tech-doc-translator/SKILL.md](skills/tech-doc-translator/SKILL.md) | 1.0.0 | Robin | Apache-2.0 | Local | — | Use when translating English technical documentation (AI/ML, developer tools, API docs) into Chinese Markdown. |

## Hooks

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| compact-restore | [hooks/compact-restore.sh](hooks/compact-restore.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | SessionStart compact hook: re-inject critical context after compaction. |
| config-audit | [hooks/config-audit.sh](hooks/config-audit.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | ConfigChange hook: audit configuration modifications. |
| log-events | [hooks/log-events.sh](hooks/log-events.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | 记录 Bash 命令与子代理启动事件，保留原日志格式。 |
| notify | [hooks/notify.sh](hooks/notify.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | Notification hook: WeChat + desktop + voice when Claude needs attention. |
| post-tool-use | [hooks/post-tool-use.sh](hooks/post-tool-use.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | PostToolUse hook: auto-format edited files and shellcheck .sh files. |
| pre-tool-use | [hooks/pre-tool-use.sh](hooks/pre-tool-use.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | PreToolUse hook: block dangerous commands and protect sensitive files. |
| reload-env | [hooks/reload-env.sh](hooks/reload-env.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | Reload environment variables when directory or .envrc/.env changes. |
| session-init | [hooks/session-init.sh](hooks/session-init.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | SessionStart hook: initialize session with project context. |
| session-summary | [hooks/session-summary.sh](hooks/session-summary.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | SessionEnd hook: send session summary to WeChat via Server酱. |
| stop-failure | [hooks/stop-failure.sh](hooks/stop-failure.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | StopFailure hook: log API errors during session. |

## Settings & MCP & Status Line

| Name | Path | Version | Author | License | Type | External Info | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| settings.json | [settings.json](settings.json) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | Claude Code 权限、Hooks、插件与状态栏配置。 |
| .mcp.json | [.mcp.json](.mcp.json) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | MCP 服务器启动配置。 |
| statusline.sh | [statusline.sh](statusline.sh) | — | 待确认 | Apache-2.0（仓库许可） | Local | — | 显示上下文用量、Git 状态与模型信息。 |

## Frontmatter Standard

以下示例适用于加载器兼容的本地 Markdown 配置入口；合并元数据时保留运行时字段和未知字段。外部配置保留原作者、版本、许可、平台和归属声明。

```yaml
---
name: <config-name>
description: <brief-description>
version: <semver>
author: <author-name>
license: <spdx-license>
platforms: [linux, macos, windows]
metadata:
  tags: [<category>, <tag1>, <tag2>]
  related_skills: [<skill1>, <skill2>]
---
```

## 已知差异与待确认项

- 根目录 README 和 CLAUDE.md 仍描述 `.claude/`，Git 提交 `f4e748f` 已将配置迁至 `agent/`。本次只更新本目录索引，未修改部署行为。
- settings 和脚本仍含 `.claude/` 运行时路径；本目录是配置集合，不据此自动修改这些路径。技能入口已改为单层目录；尚未进行实际客户端加载验证。
- 已删除旧索引中的 MLOps、vLLM Skills 条目：当前目录无对应配置，不重新创建。
- `python-debugpy` 原始平台为 `[linux, macos]`，保留外部声明，不扩展为 Windows。
- Shell 相关本地技能依赖 Bash、shellcheck 等工具；平台列表不代表已完成各操作系统实测。
- 外部技能的上游仓库及引入 tag/commit 需要来源记录才能补齐；不使用技能 version 代替。
- Hooks、状态栏、JSON 设置未独立声明作者，表中保留“待确认”；许可按仓库根 LICENSE 标注，不向源文件补写署名。

### 未收录的上游关联技能

以下 8 处引用来自外部配置的 `metadata.hermes.related_skills`，属于上游技能生态关联；保留原始值，不声称仓库内可用。若需使用，须另行核实来源并引入。

| 当前技能 | 本仓库未收录的关联 |
| --- | --- |
| requesting-code-review | subagent-driven-development |
| arxiv | ocr-and-documents |
| llm-wiki | obsidian |
| plan | subagent-driven-development |
| python-debugpy | node-inspect-debugger、debugging-hermes-tui-commands |
| systematic-debugging | subagent-driven-development |
| test-driven-development | subagent-driven-development |
