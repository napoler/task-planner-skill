# OpenSpec 技能族权威事实（只读盘点）

- 盘点时间语境：本机文件快照（2026-11-15）。
- 盘点范围：`/home/terry/.zcode/skills/openspec-*`（11个）；`/home/terry/.agents/skills/openspec-*` 不存在（`ls` 无匹配，事实）。
- 证据方式：`SKILL.md` frontmatter/正文逐字提取并标注 `绝对路径:行号`。未找到的信息标 `UNKNOWN`。

## 1. 家族完整清单

| 技能名(name) | SKILL.md 绝对路径 | 一句话职责（源 description） | 调用名(技能/命令) |
|---|---|---|---|
| openspec-apply-change | /home/terry/.zcode/skills/openspec-apply-change/SKILL.md | Implement tasks from an OpenSpec change. Use when the user wants to start implementing, continue implementation, or work through tasks. | 技能 `openspec-apply-change`；slash `/opsx:apply` (`:2-3`; onboard 列表 `onboard:477,529`) |
| openspec-archive-change | /home/terry/.zcode/skills/openspec-archive-change/SKILL.md | Archive a completed change in the experimental workflow. Use when the user wants to finalize and archive a change after implementation is complete. | 技能 `openspec-archive-change`；`/opsx:archive` (`:2-3`; `onboard:478,530`) |
| openspec-bulk-archive-change | /home/terry/.zcode/skills/openspec-bulk-archive-change/SKILL.md | Archive multiple completed changes at once. Use when archiving several parallel changes. | 技能 `openspec-bulk-archive-change` (`:2-3`)；未见独立 `/opsx:*` 名称 `UNKNOWN`（清单未列，`onboard:472-488`） |
| openspec-continue-change | /home/terry/.zcode/skills/openspec-continue-change/SKILL.md | Continue working on an OpenSpec change by creating the next artifact. Use when the user wants to progress their change, create the next artifact, or continue their workflow. | 技能 `openspec-continue-change`；`/opsx:continue` (`:2-3`; `onboard:485,508,537`) |
| openspec-explore | /home/terry/.zcode/skills/openspec-explore/SKILL.md | Enter explore mode - a thinking partner for exploring ideas, investigating problems, and clarifying requirements. Use when the user wants to think through something before or during a change. | 技能 `openspec-explore`；`/opsx:explore` (`:2-3`; `onboard:476,528`) |
| openspec-ff-change | /home/terry/.zcode/skills/openspec-ff-change/SKILL.md | Fast-forward through OpenSpec artifact creation. Use when the user wants to quickly create all artifacts needed for implementation without stepping through each one individually. | 技能 `openspec-ff-change`；`/opsx:ff` (`:2-3`; `onboard:486,538`) |
| openspec-new-change | /home/terry/.zcode/skills/openspec-new-change/SKILL.md | Start a new OpenSpec change using the experimental artifact workflow. Use when the user wants to create a new feature, fix, or modification with a structured step-by-step approach. | 技能 `openspec-new-change`；`/opsx:new` (`:2-3`; `onboard:484,536`) |
| openspec-onboard | /home/terry/.zcode/skills/openspec-onboard/SKILL.md | Guided onboarding for OpenSpec - walk through a complete workflow cycle with narration and real codebase work. | 技能 `openspec-onboard`；`/opsx:onboard` (`:2-3`; `onboard:32`) |
| openspec-propose | /home/terry/.zcode/skills/openspec-propose/SKILL.md | Propose a new change with all artifacts generated in one step. Use when the user wants to quickly describe what they want to build and get a complete proposal with design, specs, and tasks ready for implementation. | 技能 `openspec-propose`；`/opsx:propose` (`:2-3`; `onboard:475,527,493`) |
| openspec-sync-specs | /home/terry/.zcode/skills/openspec-sync-specs/SKILL.md | Sync delta specs from a change to main specs. Use when the user wants to update main specs with changes from a delta spec, without archiving the change. | 技能 `openspec-sync-specs` (`:2-3`)；未见独立 `/opsx:*` 名称 `UNKNOWN`（`onboard:472-488`） |
| openspec-verify-change | /home/terry/.zcode/skills/openspec-verify-change/SKILL.md | Verify implementation matches change artifacts. Use when the user wants to validate that implementation is complete, correct, and coherent before archiving. | 技能 `openspec-verify-change`；`/opsx:verify` (`:2-3`; `onboard:487`) |

公共事实：`compatibility: Requires openspec CLI.`（各 `SKILL.md:6`）；`allowed-tools: Bash(openspec:*)`（各 `:4`）；`metadata.generatedBy: "1.6.0"` 见多数技能（如 `propose:10`、`apply:10`、`onboard:10`），`archive/bulk-archive/explore` 未见该字段（各文件头）。

## 2. 项目初始化 / CLI 依赖（重点）

| 项目 | 事实 | 来源 |
|---|---|---|
| CLI 存在性检查 | `openspec --version 2>&1 \|\| echo "CLI_NOT_INSTALLED"`（Unix/macOS），PowerShell 备选 | /home/terry/.zcode/skills/openspec-onboard/SKILL.md:21-29 |
| 未安装时行为 | “OpenSpec CLI is not installed. Install it first, then come back to `/opsx:onboard`.” 并停止 | /home/terry/.zcode/skills/openspec-onboard/SKILL.md:31-34 |
| `openspec init` 命令 | `UNKNOWN`（在全部 `openspec-*/SKILL.md` 中 `grep "openspec init"` 无命中） | grep 证据：无匹配 |
| `openspec update` 命令 | `UNKNOWN`（grep 无命中） | grep 证据：无匹配 |
| npm 包名/安装命令/版本要求 | `UNKNOWN`（grep `npm|pnpm|yarn|install` 仅命中 onboard 的 “CLI is not installed. Install it first…” 未给出包名/命令/版本） | /home/terry/.zcode/skills/openspec-onboard/SKILL.md:22,31-32,34 |

## 3. 规格工作流（重点）

### openspec-propose（`propose:14-16,40-45,47-54,55-86,90-98`）
- 触发/输入：用户请求含 kebab-case change 名或要构建/修复的描述；无清晰输入则用 AskUserQuestion 询问，从描述派生 kebab-case 名（`propose:27-39`）。
- 动作：`openspec new change "<name>"` 创建 scaffolded change（`propose:40-45`）；`openspec status --change "<name>" --json` 获取 `applyRequires/artifacts/planningHome/changeRoot/artifactPaths/actionContext`（`propose:46-54`）；按依赖顺序取 `openspec instructions <artifact-id> --change "<name>" --json` 生成工件直至 `applyRequires` 全部 `done`（`propose:55-86`）。
- 产物：`proposal.md` (what & why), `design.md` (how), `tasks.md` (implementation steps)（`propose:16-19`）；实际写路径以 `resolvedOutputPath`/`artifactPaths` 为准（`propose:53,71-75`）。
- 完成态：`/opsx:apply` 开始实现（`propose:21,98`）。

### openspec-new-change（`new-change:14,41-53,54-62`）
- 触发/输入：同需 change 名或描述；默认 schema（省略 `--schema`），仅用户明确要求时才指定/列出 `openspec schemas --json`（`new-change:18-39`）。
- 动作/产物：`openspec new change "<name>"` 创建 change；`openspec status --change "<name>" --json` 展示 `planningHome/changeRoot/artifactPaths/nextSteps`；取首个 ready 工件的 `openspec instructions <first-artifact-id> --change "<name>"` 后**停止等待用户**，不创建工件（`new-change:41-77`）。
- 落盘目录：不假设 repo-local 路径，使用 CLI 返回的 `planningHome/changeRoot/artifactPaths`（`new-change:46,52`）。

### 产物落盘目录结构（`openspec/` 下）
- Onboard 教学示例：`Created: <changeRoot...>`，结构 `proposal.md`、`design.md`、`specs/`、`tasks.md`（/home/terry/.zcode/skills/openspec-onboard/SKILL.md:174-195）。
- 规范化路径：由 `openspec status --json` 的 `planningHome/changeRoot/artifactPaths/actionContext` / `resolvedOutputPath` 决定，不假设固定 repo-local 路径（`propose:53,71`; `new-change:52`; `apply:37,47,59`; `continue:44,69,75`; `verify:38,47`）。
- Delta specs：`artifactPaths.specs.existingOutputPaths`（`sync-specs:41`; `archive:59`; `bulk:50`）。
- 主 specs 同步目标：`openspec/specs/<capability>/spec.md`（/home/terry/.zcode/skills/openspec-sync-specs/SKILL.md:57,79-82）。
- 归档：`<planningHome.changesDir>/archive/YYYY-MM-DD-<name>/`（`archive:74-87`; `bulk:131-135`；`onboard:431-443`）。

### 生命周期（综合）
- 典型节奏：explore(可选) → new/propose/ff 创建 change 与工件(proposal/specs/design/tasks, 依 schema) → apply 实现任务 → verify 验证 → archive 归档（可含 spec sync）（`onboard:456-463,472-488`; `propose:14-21`; `new-change:14`; `ff:14`; `apply:54,92,123`; `verify:14`; `archive:14,57-71`）。
- 细分命令：`continue` 逐个创建下一工件（`continue:14,58-77`）；`ff/propose` 一次性到 apply-ready（`ff:14,46-73`; `propose:55-81`）；`sync-specs` 将 delta 合并到主 specs 可独立于归档（`sync-specs:14-16,141`）；`bulk-archive` 批量归档与冲突处理（`bulk:14-16`）。

## 4. 与既有代码/文档变更执行的衔接（apply-change）

- 读取 `openspec status --change "<name>" --json` 与 `openspec instructions apply --change "<name>" --json`，获取 schema、`planningHome/changeRoot/actionContext`、`contextFiles`、进度/任务与动态指令（/home/terry/.zcode/skills/openspec-apply-change/SKILL.md:31-55）。
- 读取 `contextFiles` 中列出的每个工件文件（spec-driven 常见 proposal/specs/design/tasks，依 schema 而定）作为实现上下文（`apply:57-63,148,154`）。
- 循环实现待办任务：做最小范围代码变更，完成后将任务文件勾选 `- [ ]`→`- [x]`；遇不清/设计问题/阻塞则暂停并建议更新工件（`apply:72-93,146-155`）。
- 流式工作流：可在工件未全完成但 tasks 存在时介入；实现暴露设计问题可回头更新工件，非严格阶段锁定（`apply:156-161`）。

## 5. ZCode/Claude Code 调用形态

- 技能族以 `SKILL.md` 形式存在于 `/home/terry/.zcode/skills/openspec-*`（本机已安装）；`.agents/skills` 下无 openspec 副本（目录盘点事实）。
- Slash 命令形态（onboard 文档）：`/opsx:onboard|propose|explore|apply|archive|new|continue|ff|verify`（/home/terry/.zcode/skills/openspec-onboard/SKILL.md:32,159,472-488,508-509,527-538）；各技能亦可按技能名调用（frontmatter `name`）。
- Store 选择：若指定/位于已注册 store，先 `openspec store list --json` 取 id，对读写 specs/changes 的命令传 `--store <id>`（如 `new change/status/instructions/list/show/validate/archive/doctor/context`），命令输出的 hint 保留该 flag（各技能开头 “Store selection” 段，如 `propose:25`, `apply:16`, `new-change:16`）。
- 依赖前提：`Requires openspec CLI`，`Bash(openspec:*)`（各 `:4,6`）；具体安装来源/版本 `UNKNOWN`（见第2节）。

## UNKNOWN / 线索
- `openspec init`/`openspec update`：未在技能文档中出现（grep 无命中）。
- CLI npm 包名、安装命令、最低版本：未在技能文档中出现；仅提示 “Install it first” (`onboard:32`)。线索：需在系统中查 `openspec` 可执行来源或官方文档（本次只读未执行外部查找）。
- `openspec-bulk-archive-change`、`openspec-sync-specs` 的 `/opsx:*` slash 别名：`onboard` 命令表未列出，标 `UNKNOWN`。

## 6. NET 补采：安装/初始化权威命令（主进程 2026-11-15 真实抓取，75.7 来源留痕）
- 来源：https://github.com/Fission-AI/OpenSpec README（web_reader 抓取，2026-11-15）
- 安装（三选一，逐字）：`curl -fsSL https://openspec.dev/cli/install.sh | sh`（macOS/Linux）；`npm install -g @fission-ai/openspec@latest`（需 Node.js ≥22.12.0）；`brew install openspec`
- 项目初始化（逐字）：`cd your-project && openspec init`
- 生命周期（逐字）：`/opsx:explore` → `/opsx:propose <name>`（生成 `openspec/changes/<name>/`：proposal.md、specs/、design.md、tasks.md）→ `/opsx:apply` → `/opsx:archive`（归档至 `openspec/changes/archive/<date>-<name>/`）
- 本地实测（2026-11-15）：`command -v openspec` 无命中（CLI 未装，命中用户 R5「遇到没有→直接安装」场景）；npm registry ECONNREFUSED（本环境无 npm 直连，安装命令以官方源记载形态落条款）
- 第 2 节 UNKNOWN 项就此部分关闭：init/包名/安装命令已获权威来源；`/opsx:*` 别名覆盖面仍以 onboard 命令表为准
