# Task Plan: task-v117 v107 遗留终清 + 三裁决口径落地 + 部署位同步

<!-- template_type: general -->
<!-- plan_tier: standard -->

## Goal

清偿 2026-10-02 系统性对齐核查（sub:60，检查点 plans/task-v116/subagent-state/60-explore-v107-legacy.md）发现的全部未对齐项：
① 8 处文档面残留（R-05/R-07/R-09/R-10/R-01/R-15/D6-19 漏网）；
② 用户已授权三裁决口径落地：P-5 frontmatter 具名枚举补 37-45 / T-2 variant 区块级联补齐（委派统计 27 家 + Handoff 登记表 12 家）/ C-P6 session-catchup 全路径统一；
③ 三宿主部署位 selftest-workflow-orchestration.sh 同步至 v116 版。
全部完成后 v107 遗留项真实清零。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 .md 文档面 + 部署 cp，零逻辑变更） |
| `session_id` | c12b36ba449844ab871b7a427b2606e8 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v117` |
| `scope_files` | `skills/task-planner/references/critical-rules.md`(:320/:326)、`skills/task-planner/references/batch-quality-gate.md`(:111)、`skills/plan-cost-guard/references/cost-control.md`(:168)、cost_log.md(锚点 :7/:69,实位以 grep 为准)、`skills/plan-template-kit/references/template-mapping.md`(:39)、`CONTRIBUTING.md`/`CONTRIBUTING_zh.md`(:47/:52/:137)、`CLAUDE.md`(:81 + 目录树 knowledge-brief 行)、`CHANGELOG.md`(:108 删除段)、`skills/task-planner/SKILL.md`(:9 frontmatter + :57)、`skills/plan-resume/SKILL.md`(:246)、`skills/plan-cost-guard/references/billing.md`(:40,57)、`skills/task-planner/templates/variant/*.md`(T-2 批次 27+12 家) |
| `interaction_mode` | `ask`（D1 已获用户「好的接受你的建议」授权=计划+执行授权） |
| `对齐审查` | 终验前 alignment-review（fresh 子代理） |
| `自动超时默认项` | 本任务无剩余 2+ 选项询问点（三裁决已由用户接受推荐项，余下为机械执行）——豁免登记 |
| `质量审查工具` | alignment-review（fresh 收尾） |

## ✅ Verification Contract

| # | 判定标准 | 验证 |
|---|----------|------|
| VC-1 | 8 处残留逐条修复且旧表述 grep 零残留（「13 变体」×2 / 裸 references/critical-rules.md 引用 / bash scripts/validate.sh / --force / --target / py_compile session-catchup / CHANGELOG 删除段=(无) / batch 枚举无 video） | grep 实测 |
| VC-2 | P-5：SKILL.md:9 frontmatter 具名枚举覆盖 37-45（与正文 :305 索引面同口径）；C-P6：三处 session-catchup 统一「task-planner scripts/session-catchup.ts」全路径口径 | Read :9 + grep |
| VC-3 | T-2：29 variant 中「委派统计」区块 28/29 在位（mini-lite 设计豁免留痕）；「Handoff 登记表」27/29 在位（v115 族 12 家补齐 + mini-lite 豁免留痕）；批次按 18.9 试点先行 | 逐文件 grep -q 双区块 |
| VC-4 | 全量 42 selftest 0 FAIL（合并后主仓场，含 T-2 批次触发的行数锚级联修正） | 42 rc |
| VC-5 | 三宿主 selftest-workflow-orchestration.sh 与主仓 v116 版 md5 一致（同步=单向 cp，部署位 skills 面 diff 归零） | md5sum×3 |
| VC-6 | 合并回 master + worktree/分支清理 + 部署位 skills 面（含 plan-resume/plan-cost-guard/plan-template-kit 改动面）同步 + porcelain 干净 + INDEX 刷新 + memory 清账行 | git status + INDEX |
| VC-7 | 对齐审查通过（fresh） | checkpoint |

## ⚠️ 执行范围限制

上表 scope_files 全集；T-2 批次区块文本从主模板 task_plan.md 复制，零自造内容；selftest 仅允许「行数锚数值级联」（label 注明 task-v117，断言语义零改动）；宿主侧仅单向 cp 部署，禁改宿主独有内容。

## 📚 必要知识储备

sub:60 检查点（plans/task-v116/subagent-state/60-explore-v107-legacy.md）A~E 全节锚点实测；R-09 install.sh 实 flag 集=--canonical/--tools/--no-verify/--no-backup/--dry-run；主模板三区块锚 task_plan.md:336(DriftLog)/:363(委派统计)/:375(Handoff)。

## ⚠️ 核心问题定义

v116 声称「v107 R 系列全部清零」偏乐观（v116 findings:69 自认残留），系统性复核查实测出 8 处漏网 + 3 个待裁决口径 + 1 处部署未跟上。本任务=真实清零收口。
- [x] 能交付 [x] 必要 [x] 方法清晰

## Current Phase

终验: COMPLETE

## Next Step

worktree 创建 → Phase 1 残留修复（executor）

## 🔀 隔离决策

check-conflicts：主仓 porcelain 干净、无额外 worktree、无遗留 wt 分支。本任务改 skills/（被三宿主部署消费的运行中基础设施）= §11.1 命中 5 → **worktree 隔离**（v116 同款先例）。CWD 不迁移。

## 🧰 工具选择与编排（Rule 40）

| Phase | 工具面 | 理由 |
|-------|----------------------|------|
| Phase 1 | executor fresh（worktree 内 8 残留 + P-5 + C-P6，含 selftest 行数锚级联自查） | 跨 10 文件机械文档修正，主上下文保留编排 |
| Phase 2 | executor fresh（T-2 批次 18.9 试点先行+Batch Report） | 39 文件批次=批量质量门控场景 |
| Phase 3 | executor fresh（回归 42 selftest）+ 主进程（合并/部署/簿记白名单①②） | 机械面+编排 |

**workflow 编排判定**: 未命中；**/goal**: 未使用；**parallel_groups**: 无（Phase 间依赖串行；Phase 1/2 文件集重叠=critical-rules.md 与 SKILL.md 被两 Phase 触碰，独立性四问文件集 yes→串行）

## Phases

### Phase 1: 文档面残留修复 + P-5 + C-P6（worktree）
- **S-unit 表**
| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|---|------|--------|------|------|----------|------|
| S1 | worktree add wt/task-v117 | 主进程(git 白名单①) | master | git worktree list 在位 | 5min | complete |
| S{n} | critical-rules.md:320/:326「13 变体」→29 口径 | executor | critical-rules.md | grep「13 变体」0 命中 | 15min | pending |
| S{n} | R-07 裸引用×4 修实位路径（cost-control.md:168 / cost_log.md:7,69 / template-mapping.md:39，实位以 grep 为准） | executor | cost-control.md template-mapping.md | grep 裸引用 0 命中 | 10min | pending |
| S{n} | R-09 CONTRIBUTING 幽灵命令/flag×6 修实位（:47/:52/:137，validate.sh→lib/verify.sh、flag 按 install.sh 实测集） | executor | CONTRIBUTING.md CONTRIBUTING_zh.md | grep validate.sh --force --target 0 命中 | 10min | pending |
| S{n} | CLAUDE.md:81 py_compile→bun + 树补 knowledge-brief 行 | executor | CLAUDE.md | grep 双锚复现 | 10min | pending |
| S{n} | batch-quality-gate.md:111 批量枚举 +video/video-fix | executor | batch-quality-gate.md | 行含 video | 5min | pending |
| S{n} | CHANGELOG.md:108 删除段补 2337ce0 回填 | executor | CHANGELOG.md | grep 删除段非(无) | 10min | pending |
| S{n} | P-5 SKILL.md:9 frontmatter 具名枚举补 37-45（与 :305 索引面同口径） | executor | SKILL.md | Read :9 复现 | 10min | pending |
| S{n} | C-P6 session-catchup 全路径统一（SKILL.md:57 + billing.md:40,57 口径「task-planner scripts/session-catchup.ts」） | executor | SKILL.md billing.md | grep 三处口径 | 10min | pending |
| S{n} | C-P6 plan-resume/SKILL.md:246 裸名→全路径口径 | executor | SKILL.md | grep 复现 | 5min | pending |
| S{n} | selftest 行数锚级联自查 | executor | selftest-registry.tsv | 锚断言语义零改动 label 注明 v117 | 15min | pending |
| S{n} | worktree commit 逐 Phase 产物 | executor | git | porcelain 干净 | 5min | pending |
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** executor fresh（worktree 绝对路径必含于 prompt；检查点 subagent-state/1-executor.md）

### Phase 2: T-2 variant 区块级联补齐（试点先行，18.9 硬门）
- **S-unit 表**
| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|---|------|--------|------|------|----------|------|
| S1 | 试点 bugfix-type.md 补「委派统计」区块（文本从 task_plan.md:363 区复制） | executor | task_plan.md bugfix-type.md | 主进程 Read 验收后放行批量 | 15min | pending |
| S2 | 批量 27 家补「委派统计」（mini-lite 豁免留痕 notepad-learnings.md） | executor | task_plan.md | 逐文件 grep -q 委派统计 | 15min | pending |
| S3 | 12 家 v115 族补「Handoff 登记表」（:375 区文本）+ Batch Report 八字段双采样 | executor | task_plan.md | grep -q 双区块 + Report 落盘 | 15min | pending |
| S4 | worktree commit | executor | git | porcelain 干净 | 5min | pending |
- **V-N:** VC-3
- **Status:** complete
- **Executor:** executor fresh（试点验收前批量=禁止；检查点 subagent-state/2-executor.md）

### Phase 3: 回归 + 合并 + 部署 + 对齐审查 + 终验簿记
- **S-unit 表**
| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|---|------|--------|------|------|----------|------|
| S1 | 42 selftest 全量（worktree 场）0 FAIL | executor | selftest-registry.tsv | 42 rc=0 | 15min | pending |
| S2 | smart-merge-back + worktree/branch 清理 | 主进程(git 白名单①) | worktree | merge_back=merged(commit) | 10min | pending |
| S3 | 部署三宿主：selftest-workflow-orchestration.sh + 本任务 skills 面改动文件单向 cp | 主进程(git 白名单①) | 主仓 skills 面 | md5 一致×3 | 10min | pending |
| S4 | 主仓场 42 selftest 复跑 + md5 部署验证 + alignment-review | executor | selftest-registry.tsv | 42 rc + md5 + 审查 checkpoint | 15min | pending |
| S5 | INDEX 刷新 + 计划三文件 commit + memory 清账行 | 主进程(计划系统白名单②) | INDEX.md | INDEX 含 v117 complete | 10min | pending |
- **V-N:** VC-4, VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** executor fresh（S1/S4）+ 主进程（S2/S3/S5 白名单①②）

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type | 目标 | S-unit | checkpoint 路径 | 状态 | findings 落点 | verify_done |
|------|--------------|------|--------|----------------|------|--------------|-------------|
| - | executor | 残留修复+裁决落地 | P1-S2..S10 | plans/task-v117/subagent-state/1-executor.md | pending | findings.md §P1 | ☐ |
| - | executor | T-2 批次 | P2-S1..S4 | plans/task-v117/subagent-state/2-executor.md | pending | findings.md §P2 | ☐ |
| - | executor | 回归×2 | P3-S1,S4 | plans/task-v117/subagent-state/3-executor.md | pending | findings.md §P3 | ☐ |

## Decisions Made

| 时间 | 决策 | 依据 |
|------|------|------|
| 2026-10-02 | 三裁决取推荐项：P-5 补具名 / T-2 全部级联补齐 / C-P6 统一全路径 | 用户「好的接受你的建议」授权 |
| 2026-10-02 | 隔离=worktree（§11.1-5 命中） | 改 skills/=运行中基础设施 |
| 2026-10-02 | 自动超时豁免登记：无剩余 2+ 选项询问点 | 44.1 |
