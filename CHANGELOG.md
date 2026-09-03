# 变更日志

所有值得注意的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
本项目遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 新增

- **`companion/skills/plan-resume/`** — 中断/过期计划扫描技能。与 task-planner 协同:扫描 `plans/*/task_plan.md` 等 3 处存储位置,通过「时间衰减 / 代码环境失效 / 目标已被取代」三维判定过期项,产出报告让用户决策(不替用户 resume/archive/drop)。参考 `companion/skills/plan-resume/SKILL.md`。
- **`scripts/sync-companion.sh` + `lib/install-companion.sh` 同步器改用 `find -maxdepth 2`** — 修复 companion skills 只扫顶层文件的限制,支持子目录(`scripts/`)。向后兼容 `companion/skills/task-drift-guard/`(只含顶层 3 文件)。详见 `skills/task-planner/docs/ARCHITECTURE.md` §4.5.2。

### 变更

- **`plan-resume` v0.3 多格式扫描**: `scan-plans.sh` 新增 openspec(`openspec/changes/*/tasks.md`)与 spec-kit(`specs/*/tasks.md` + `specs/*/spec.md`)两个扫描位置(共 3 种存储格式:task-planner / openspec / spec-kit)。openspec 默认跳过 `archive/`(加 `--include-archived` 可开启)。
- **`extract-meta.sh` 三后端**:新增 `format=openspec` / `format=spec-kit` 分派,openspec 后端读 `.openspec.yaml` goal + tasks.md 完成度,spec-kit 后端读 spec.md 的 `**Status**` 字段与 tasks.md 完成度;原 `format=task-planner` 后端完全保留。
- **SKILL.md 报告模板**:在推荐清单表格里新增 `Format` 列 + 混合格式展示示例;报告元信息加 `格式覆盖` 行;§1 计划位置补 openspec / spec-kit 两条;§1.1 用户参数映射加 `--include-archived`;§2.1 提取字段表扩展为 7 字段 + 格式判定表。
- **`tests/smoke.sh` 5 项新测试**: openspec format / task_id;spec-kit format / 完成度 / spec.md Status 字段;加上 `--help` 检查。

### 修复

(无)

### 删除

(无)


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
