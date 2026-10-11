# 23 — drift-checker (Phase 3 修复推进面偏移检查)

- 检查时间：2026-10-09（Phase 4 前移在飞时的快照）
- 职责：Rule 61 载体（Rule 22.3① 改派）；只读检查，唯一写入=本检查点
- 需求锚（Rule 51.1a）：R1 系统性审核 / R2 未对齐落后内容全部对齐 / R3 发现必解决
- 判定输入三锚（Rule 64.4）：① Goal 原文（全量对齐+处置闭环+回归无新增 FAIL+部署 IDENTICAL）② 近期动作（worktree a234369/fca4f40 两 commit；15 检查点）③ scope 文件集（task_plan 执行范围表）
- 结论：**DRIFT（低危 / 行政面）** —— 修复内容全部服务 Goal 且可溯源，但存在 3 项边界/簿记偏差，须登记消解

---

## 检查项 1 — worktree 实际改动文件集 vs scope 表

一手命令：`git diff 21f7e6b..HEAD --stat`（worktree，31 文件）

| 判定 | 结果 |
|------|------|
| 落在 scope 内 | 30/31 文件：`skills/task-planner/**`（SKILL.md/README.md/INSTALL.md/MIGRATION.md/docs/ARCHITECTURE.md/lib/install-companion.sh/references/critical-rules.md/references/agent-coverage.md/scripts/* 共 21 项）+ 仓级 `README_zh.md`/`INSTALL_zh.md`/`CLAUDE.md` + `plans/INDEX.md` |
| 越界（scope 表未列） | **1 文件：`examples/full-workflow.md`**（改 `scripts/install.sh`→`skills/task-planner/install.sh`、`scripts/validate.sh`→`skills/task-planner/lib/verify.sh`、`session-catchup.py`→`.ts` 等失效路径） |

**裁定**：`examples/full-workflow.md` 不在「执行范围限制」表白名单（技能本体 `skills/task-planner/**`／仓级五文档／计划系统三处），也不在 Code Review `scope_files`。
但：① 该文件由 Phase 2 S2 审计发现（findings D18，实际落点 = `examples/full-workflow.md`，findings 记为 `docs/full-workflow.md`——路径标注有误）② Phase 3 S10 S-unit 行显式授权「…+full-workflow.md 路径…」。
→ 定性为**计划内部不一致**（S-unit 表授权面 > 执行范围表白名单面），非执行体擅自越界；改动本身服务 R2「落后内容对齐」。

## 检查项 2 — Phase 3 声明 S-unit × 产出/验收证据

声明 16 个 S-unit：S5/S6/S7/S8/S9/S10/S11/S12/S16/S17/S18/S19/S20/S21/S22/S23
检查点目录 `subagent-state/` 实况：21 个 .md，其中 Phase 3 检查点 07–22 段**缺 17**，实存 15 份

| S-unit | 检查点 | 产出（worktree diff 可见） |
|--------|--------|---------------------------|
| S7→07 / S16→08 / S5→09 / S6→10 / S17→11 / S18→12 / S19→13 / S21→14 / S22→15 / S23→16 / S9→18 / S10→19 / S11→20 / S12→21 / S20→22 | 15 份在位 | 全在位 |
| **S8（行号锚批）** | **缺（编号 17 空号）** | 在位：registry:50 锚改写、init-session.sh、selftest-plan-dispatch.sh:37、selftest-reliability-institution.sh:14,80 |

**裁定**：15/16 检查点在位；**S8 无检查点文件**（grep 全 plans 树无「S8」检查点）。S8 产出经 diff 一手核实完好，progress.md 记录「返回消息死循环但文件改动完好，逐 diff 复核采信」——**产出证据在、检查点证据缺**（Rule 22.8 落盘要求未满足）。

## 检查项 3 — 处置表 D1-D36 对应性（抽查 D6/D9/D20/D25）

| 抽项 | 验证命令 | 结果 |
|------|---------|------|
| D6 Rule 65 块 | `grep -n '^### 65' critical-rules.md` + `sed -n '800,840p'` | **在位**：仲裁注 :802、`### 65` :804、65.1–65.8 全文至 :834（文件尾）；编号唯一无撞号 |
| D9 registry:50 锚 | `sed -n '50p' registry` + `sed -n '566,575p' critical-rules.md` + `sed -n '206p;319p' SKILL.md` + `delivery-summary:36` | **在位且属实**：新锚 `SKILL.md:206(C35),319(bullet)` 命中 C35 行/Rule 51 bullet；`critical-rules.md:566-575` 命中 51.1-51.8；`delivery-summary.md:36`=「需求覆盖核对」块。旧值 `:286,201,310 / :522-530 / :35` 已替换 |
| D20 agent-coverage video-fix | `grep -n video-fix references/agent-coverage.md` | **在位**：:36/:50/:120 三处改「未落地：video-fix-executor 实体不存在…[task-v149 D20]」，与 companion 实态（仅 image/video-generation-executor）一致 |
| D25 备份根外移 | `grep -n BACKUP\|COMPANION_DIR lib/install-companion.sh` | **在位**：`BACKUP_DIR="$HOME/.task-planner-backups/companion/$(date…)"`（:65，移出扫描路径）；`COMPANION_DIR` 拼写修正（:20-21）；mkdir/cp 对齐（:121-122） |

**裁定**：4/4 抽项属实，处置表与实际修复一致。

## 检查项 4 — 目标遗忘判定（过度修复/夹带）

- 31 文件改动逐一映射到 D 项（D1/D2-D5/D6-D7/D8/D9-D12/D13/D14-D19/D20/D22/D23/D24/D25/D28/D35/D36），无「无对应发现的额外改动」。
- 未触碰其他技能目录（`skills/task-drift-guard/**` 等零改动）；未手工散改部署位（Phase 5 pending）。
- 唯一 Goal 外延 = `examples/full-workflow.md`（见检查项 1），仍服务「全量对齐」目标，非夹带。
- **未发现过度修复/夹带**；反而发现 1 处**欠对齐残留**：`selftest-registry.tsv:61` 第二字段已改「Rule 65」，第三字段仍写「**57 条款**五维度锚」（描述串残留旧号）。

---

## 附加一致性观察

- **task_plan.md Phase 3 Status 未翻**：task_plan.md Phase 3 `Status: pending`（:177）与 progress.md Phase 3 `Status: complete`（:47）不一致（三文件罗盘 Phase 状态 desync）；Phase 3 S-unit 行状态列亦全为 pending。属簿记滞后，非内容漂移。

## 证据索引

- `git diff 21f7e6b..HEAD --stat`（worktree）：31 文件；含 `examples/full-workflow.md`
- worktree `git log --oneline -3`：fca4f40 / a234369 / 21f7e6b
- critical-rules.md:802 仲裁注、:804 `### 65`、:834 文件尾
- selftest-registry.tsv:50（D9 新锚）、:61（「57 条款」残留）
- references/agent-coverage.md:36,50,120
- lib/install-companion.sh:20-21,65,121-122
- plans/task-v149-skill-alignment-audit/subagent-state/（21 .md，07-22 缺 17）
- task_plan.md:177（Phase 3 pending）/ progress.md:47（Phase 3 complete）

## 未验证项

- S8 行号锚的「逐锚 sed -n 内容匹配」未见独立检查点记录，仅 progress.md 文字采信 + 本检查点抽验 D9（registry:50）属实；init-session:380/plan-dispatch:37/reliability:14,80 三锚未逐一 sed 复核（本检查只读范围可补，但未做）。
- 回归/CR/对齐审查（S13-S15）在飞，未纳入本次判定。
- examples/full-workflow.md 是否应保留（服务目标）vs 回退（守 scope）——需主进程/用户裁决。

## 下一步建议

1. **消解检查项 1**：将 `examples/*.md`（审计发现的滞后文档）补入 task_plan 执行范围表 + Code Review `scope_files`，或在 Phase 5 前回退该文件；并修正 findings D18 的路径标注（`docs/full-workflow.md` → `examples/full-workflow.md`）。
2. **消解检查项 2**：为 S8 补写检查点（记录 4 锚 sed 复核结果）或登记「S8 无检查点+产出 diff 采信」的例外理由（Rule 22.8）。
3. **消解欠对齐残留**：`selftest-registry.tsv:61` 第三字段「57 条款」→「65 条款」。
4. **消解簿记**：task_plan.md Phase 3 Status 翻 complete（与 progress 对齐）。
