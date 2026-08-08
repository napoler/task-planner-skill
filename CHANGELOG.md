# 变更日志

所有值得注意的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
本项目遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)。

## [Unreleased]

## [2.0.0] — 2026-08-08

### 新增
- **`scripts/install.sh`** —— 一键安装器，支持 `--target`、`--dry-run`、`--force`、`--source`、`--no-validate`、`--uninstall`。默认安装到 `~/.claude/skills/task-planner/`
- **`scripts/validate.sh`** —— 安装后完整性检查：`.sh`/`.py`/`.ts` 语法检查、JSON 验证、frontmatter 检查、模板存在性、可执行权限
- **`scripts/uninstall.sh`** —— 安全卸载，支持 `--dry-run`、`--force`、`--target`。操作父目录前会询问确认
- **`README.md`** —— 项目概览、功能特性表、快速上手、项目结构、验证契约说明、多任务并行模式、文档索引、配置参考、许可、贡献链接
- **`README_zh.md`** —— 中文版本 README
- **`INSTALL.md`** —— LLM 自动安装代码块 + Linux/macOS/WSL/Windows 手动安装说明
- **`INSTALL_zh.md`** —— 中文版本安装说明
- **`CHANGELOG.md`** —— 本文档
- **`CONTRIBUTING.md`** —— 开发流程、脚本规范、PR 检查清单
- **`CONTRIBUTING_zh.md`** —— 中文版本贡献指南
- **`examples/full-workflow.md`** —— 端到端演示：从请求到规划到执行到验证到交付
- **`CLAUDE.md`** —— 仓库级 Claude Code 指南（目录结构、开发工作流、常用命令）
- **`scripts/check-complete.ps1`** —— `check-complete.sh` 的 PowerShell 镜像（原生 Windows 支持）
- **`scripts/init-session.ps1`** —— `init-session.sh` 的 PowerShell 镜像（原生 Windows 支持）

### 变更
- `README.md` 由 1 句话扩展为完整项目文档
- 任务计划模板注释更新为中英双语标题
- `validate.sh` 中 TypeScript 严格类型检查降级为警告（`sync-ide-folders.ts` 依赖的 `@types/node` 非 Skill 硬依赖）

### 修复
- `init-session.ps1`：硬编码路径 `skills\plan\templates\` 修正为 `skills\task-planner\templates\`
- `init-session.ps1`：补全缺失的 `verification.md` 模板复制（之前只复制 4 个文件，Shell 版复制 5 个）
- `sync-todos.sh`：`stat -c %y` 是 GNU 专属，现增加 macOS BSD stat（`stat -f '%Sm'`）兼容
- `CONTRIBUTING.md`：Python 脚本路径 `scripts/session-catchup.py` 修正为 `skills/task-planner/scripts/session-catchup.py`
- 全部 `<owner>` / `<you>` 占位符替换为实际 GitHub 用户名 `napoler`
- `INSTALL.md`：修复残留中文文本（第 26 行）

### 删除
- 无。所有现有 Skill 文件均保留（详见提交记录中 `skills/task-planner/` 的无操作 diff）。

---

## [1.0.0] — 2026-08-01（初始提交）

- 裸 Skill 包 —— 从内部开发环境复制的 `task-planner` Skill 文件
- 无分发表面（无 README、无安装脚本、无文档）
- 内容：`SKILL.md`、`config.json`、`reference.md`、`examples.md`、`scripts/`、`templates/`、`references/`
