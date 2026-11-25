# AGENTS.md — task-planner-skill 工作区指南

给本仓库的 ZCode / Claude Code 代理看的精简指南。项目主文档见 `README_zh.md`，开发规范见 `CONTRIBUTING_zh.md`，机制细节见 `CLAUDE.md`。

## 1. 这是什么仓库（先认对项目）

本仓库 **就是 task-planner Skill 家族的源码仓库 / 唯一权威源（canonical source）**。产品不是可执行程序、不是 API、不是 Web/桌面应用——**产品就是 `skills/` 目录里的这一组 Skill 包**。仓库只是把 Markdown + Shell + Python/TS 脚本打包成 Skill，被 Claude Code / ZCode / OpenCode 等工具加载。

核心是 `skills/task-planner/`（文件系统驱动的任务规划框架），其余 20 余个是伴随/卫星 Skill（如 `task-dispatch`、`plan-*`、`verification-gate`、`todo-skill`、`context-corrector` 等）。

## 2. 🔴 最高优先级铁律：源码位置 vs 部署位置（务必分清）

这是本仓库最容易被搞错的一点，改动前必须先判定用户指的是哪一侧：

| 概念 | 位置 | 性质 |
|---|---|---|
| **源码 / 权威源（canonical）** | **本仓库的 `skills/<name>/`** | 用户说「修改本项目的 Skill / 修改 task-planner / 改某个 skill」时，指的是这里。**默认改这里。** |
| 部署位 / 下游产物 | `~/.zcode/skills/<name>/`、`~/.claude/skills/<name>/`、`~/.config/opencode/skills/<name>/`、`~/.cursor/skills/<name>/`、`~/.agents/skills/<name>/` | 由 `install.sh` / `smart-merge-back.sh --deploy` 生成的 stub（软链/薄壳/全量副本）。是派生物，下次部署会被覆盖。 |

**判定规则：**

- 用户说「修改这个项目的 Skill」「改 task-planner」「改某个 skill」→ 一律编辑 **本仓库 `skills/<name>/`**，绝不要一上来就去改 `~/.zcode/`、`~/.claude/` 或 `~/.agents/` 下的副本。那些是部署目的地，不是源码。
- 只有用户**明确**要求「安装 / 部署 / 同步到某工具 / reinstall」时，才动部署位；流程是「改本仓源码 → `install.sh` 或 `smart-merge-back.sh --deploy` → `verify.sh` 对账」，而不是直接编辑部署位文件。
- **goal 模式部署预授权（2026-11-24 用户裁决）**：`/goal` 任务中，为使目标生效而把**已合并进 master 且相关 selftest 通过**的 `skills/` 内容同步到部署位，属 `/goal` 已预授权范围，不必等待显式部署指令；护栏=逐位 diff 判向、禁止整文件覆盖、部署前备份、部署后 `verify.sh` 对账（全文见 task-discipline Rule 28.9②）。agent 定义的 model / frontmatter 不在此列，仍须显式授权。
- 直接改部署位 = 制造漂移（drift），会在下次部署被冲掉；且 `~/.zcode/skills/**`、`~/.agents/skills/**` 属全局宪法保护区，未经明确授权禁止改。
- 「本项目的 Skill」≠「已安装到某个 AI 工具里的那份 Skill」。二者同源，但**编辑目标永远是仓库内的 `skills/`**。
- **本文件（仓库根 `AGENTS.md`）自身不进部署链路**：`install.sh` / `smart-merge-back.sh --deploy` 只部署 `skills/<name>/` 下的 `SKILL.md`、`scripts/`、`references/`、`templates/`、`config.json`，从不拷贝/软链本文件。它只在「以本仓库为工作目录」时被加载；端点上的技能执行以**部署位的 SKILL.md + references/ + scripts/** 为准，与本文件无同步关系——不存在「本文件没同步到端点导致执行不一致」的问题。真正会导致端点跑旧版的是「改了 `skills/` 源码却没 redeploy」，靠 §4 闭环 + verify.sh/对账门防。

## 2.5 🔴 项目级强制：所有计划必须先展示产出示例实物（2026-11-25 用户裁决）

本仓库项目级强制（standard / mini / L0-lite 均不豁免）：计划创建/审核第一动作=向用户展示可审查的产出示例实物，再写条款/方案；无实物 = 计划不合格，禁止进入执行。

**单一事实源（随 skill 部署生效）**：完整判定式、FAIL 情形、机器门与存量兼容边界见 `skills/task-planner/references/critical-rules.md` Rule 113.10；权威可审查示例与 C1–C8 审查命令见 `examples/json-template-upgrade/review.md`。本节只作导航，禁止在此复制或改写条款——避免仓库项目指令与端点规范形成双源漂移。

## 3. 主要目录

- `skills/` — 产品本体。每个子目录一个 Skill；`task-planner/` 是核心。
- `skills/task-planner/review-library/` — 复用的 review 类 skill 集合（软链挂载）。
- `skills/task-planner/companion/agents/` — 伴生子代理定义。
- `plans/` — 该框架自身的任务运行记录（task-planner 用它做「工作记忆」）；`plans/INDEX.md` 为多任务协调者。
- `.zcode/` — 运行时状态：`ledger/`（进度台账）、`plans/`（会话计划快照）、`plan-templates/`、`workflow-drafts/`、`workflow-runs/`。
- `scripts/` — 仓库级知识库工具（`kb-*.sh`）。**注意**：Skill 自己的脚本在 `skills/task-planner/scripts/`，不在这里。
- `knowledge/`、`docs/`、`examples/`、`forensics/`、`tmp/` — 知识条目、设计提案、示例、取证记录、临时产物。
- 根目录文档：`README_zh.md`（主）、`INSTALL_zh.md`、`CONTRIBUTING_zh.md`、`CHANGELOG.md`、`CLAUDE.md`、`RETRIEVAL_EXCLUDE.md`。

### `skills/task-planner/` 内部

- `SKILL.md` — Skill 入口（frontmatter + 工作流）；只放单行调用指令。
- `config.json` — 运行时阈值（max_vc、retry_count、escalation_threshold…），JSON Schema `additionalProperties: false`，拼错即报错。
- `scripts/` — 可执行逻辑：`planctl.py`（计划状态权威写入 + 18 子命令）、各 `check-*.sh` 门控/hook、`init-session.sh`、`attest-plan.sh`、`smart-merge-back.sh`、`run-selftests.sh`、`selftest-*.sh`（100+ 断言脚本）。
- `templates/` — 计划渲染模板；`templates/variant/` 为各 `template_type` 变体。
- `references/` — `critical-rules.md`（Rules 1-113）、`completion-gate.md`（子代理验证协议）、`goal-gate.md`（VC / COMPLETE·PARTIAL·BLOCKED 判定）、`worktree-isolation.md` 等。 <!-- skill-fix 2026-11-25：规则区间对齐至 Rules 1-113，Rule 111/112/113 已落地 -->
- `lib/` — 安装/检测/备份/验证（`install.sh` 调用的 `detect-tools.sh`、`verify.sh` 等）。
- `tests/smoke.sh` — 冒烟测试。

## 4. 常用命令（在仓库根执行）

```bash
# 语法检查（提交前必做）
bash -n skills/task-planner/scripts/*.sh
python3 -m py_compile skills/task-planner/scripts/*.py
bun build --no-bundle skills/task-planner/scripts/session-catchup.ts --outdir /tmp  # 无 bun 可跳过

# config schema 校验（jsonschema 缺失时告警即可，不得因此失败）
python3 -c "import jsonschema,json; jsonschema.validate({},json.load(open('skills/task-planner/config.json')))"

# 安装到本地工具（默认 flags：--canonical / --tools / --no-verify / --no-backup / --dry-run）
bash skills/task-planner/install.sh --dry-run
bash skills/task-planner/install.sh --no-backup

# 验证安装（实位入口 = lib/verify.sh，必须带 TASK_PLANNER_ROOT）
TASK_PLANNER_ROOT=$PWD/skills/task-planner bash skills/task-planner/lib/verify.sh
# 预期：[verify] summary: N pass / 0 fail，退出码 0

# 全量 selftest 回归（发布前用 --fresh）
bash skills/task-planner/scripts/run-selftests.sh            # 命中缓存则复用
bash skills/task-planner/scripts/run-selftests.sh --fresh    # 忽略缓存全量重跑
bash skills/task-planner/scripts/run-selftests.sh --only dispatch
```

标准闭环：**改 `skills/` 源码 → 语法检查 → 重新安装（install.sh）→ verify.sh → 相关 selftest → 提交**。

## 5. 编辑约束（影响改法的架构边界）

- **可执行逻辑外置**：≥10 行或含循环/条件/IO 的逻辑放 `scripts/`，`SKILL.md` 只保留单行调用。
- **计划状态以 JSON 为权威**：`plan-state.json`（经 `planctl.py` 写入）是权威源；`task_plan.md`/`verification.md`/`findings.md`/`progress.md` 是渲染出的派生视图，**禁止手工 Edit**，改后须 `planctl.py render` 刷新。
- **脚本规范**：Shell 顶部 `set -euo pipefail`；`--dry-run` 为安全默认；退出码 0 成功/1 用户错误/2 环境错误/3 验证失败；shell 脚本不得依赖 Python/Node；Python 3.8+ 且无第三方依赖。
- **模板登记**：`templates/variant/` 新增 `<type>-type.md` 需按 `critical-rules.md` Rule 34.2 做三点登记（template-mapping / plan-writer 映射表 / 模板节）；init 白名单从该目录动态派生，无需改脚本。
- **CLI 向后兼容**：脚本新增参数须带默认值，不改现有行为。
- **规范基线机制内聚**：spec-scan/spec-brief/check-spec-baseline/B19 属 task-planner 内聚机制，改动须跑 `selftest-spec-baseline.sh`。
- **修改敏感区前先读文档**：`README_zh.md`、`CONTRIBUTING_zh.md`、`CLAUDE.md`，以及 `skills/task-planner/references/critical-rules.md`（Rules 1-113）、`worktree-isolation.md`。改 references/ 可能影响已有计划，须配合版本号升级。 <!-- skill-fix 2026-11-25：规则区间对齐至 Rules 1-113，Rule 111/112/113 已落地 -->

## 6. Git / 分支坑

- 当前工作在 **`master`** 分支。`main` 与 `master` **无共同祖先**（`git merge-base master main` 为空）——历史无关，**不要把 main 合进 master**，也不要假设 `main` 是 PR 基线。远端同时存在 `origin/main` 和 `origin/master`。
- 实现类改动按项目约定在 `tmp/worktrees/<task-id>` 的 worktree 中进行（`wt/<task-id>` 分支），完成后合并回 `master` 并清理。
