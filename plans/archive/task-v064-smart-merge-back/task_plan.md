# Task Plan: task-v064-smart-merge-back — 合并回智能门（已合并检测+预检+可选自动部署对账）

## Goal
把 task-planner 的"合并回 master"手工三步升级为智能门 `scripts/smart-merge-back.sh`：V1-V6 结构化预检（worktree 干净/scope 无重叠/master 前进检测）+ **已合并自动检测**（merge-base --is-ancestor → ALREADY_MERGED 跳过合并，机制化 v062 双窗口事故教训）+ --no-ff 合并执行 + 可选 --deploy 自动重部署 3 位+diff 对账；hermetic selftest 7 用例守护；联动 worktree-isolation.md 合并回合约 + SKILL.md 两处合并回 bullets + README 脚本计数；**本任务自身合并回用该脚本 dogfood**；与并行任务 task-v063 scope 隔离（只碰合并回区/新脚本/selftest/README 计数）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（新增 shell 逻辑：智能门脚本 + hermetic selftest） |
| `session_id` | 980c720af6794511a6ceb88f5289be17（sid=sess1274ca817faf413eb3450d67537dd452，side 指针已指向本计划） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back` |
| `interaction_mode` | `silent`（用户已通过选项澄清锁定方案 A，分叉点已消解；静默决策逐条登记） |
| `scope_files` | `skills/task-planner/scripts/smart-merge-back.sh`(新), `skills/task-planner/scripts/selftest-smart-merge.sh`(新), `skills/task-planner/references/worktree-isolation.md`, `skills/task-planner/SKILL.md`(仅 :158/:216 两处 bullet), `skills/task-planner/README.md`(仅 :36/:80 计数) |
| `template_type` | bugfix（技能增强——合并回机制化，v059-v064 维护范式同构） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 智能门脚本落地：V1-V6 检查序列 + ALREADY_MERGED/MERGED/MASTER_AHEAD/SCOPE_OVERLAP/PRECHECK_DIRTY/PRECHECK_INVALID/MERGE_CONFLICT/DEPLOY_DRIFT 全部判定路径 + 结构化输出 + 显式退出码（2-7） | Read 复核对照 findings 设计 + 手工场景抽查 | findings 设计段 + progress |
| VC-2 | selftest 7 用例全过：hermetic 临时 git 仓，SM-01..07 覆盖脏树/正常合并/已合并/master 前进/重叠/部署对账/清理提示 | `bash scripts/selftest-smart-merge.sh` EXIT=0 | selftest 输出 |
| VC-3 | 无回归：6 套既有 selftest 全量 fail=0（≥106 用例）+ verify.sh 无新增 fail | 7 套件全跑 | 输出记 progress |
| VC-4 | 联动完整：worktree-isolation.md §4 合并回合约接入脚本（人工路径保留为逃生）；SKILL.md :158/:216 指针；README 计数 16→17 ×2；宽口径"合并回\|merge"扫描无失效引用 | grep + Read 逐处 | 分类表入 verification |
| VC-5 | dogfood 实证：本任务合并回由 smart-merge-back.sh 执行（MERGED 或 ALREADY_MERGED 路径真实验证）+ --deploy 3 位 IDENTICAL + verify 25/0×3 | 脚本输出 + diff -rq | progress Phase 6 段 |
| VC-6 | 合并回 + 部署对账：master merge commit + worktree/分支清理；plan-writer agent 2 位与 companion 6 位无新差异 | git + diff | verification 终验段 |
| VC-7 | 全程隔离与簿记：全程串行派发、Handoff 实时登记（v062 教训）、Rule 27 逐 Phase 提交、INDEX/attest/ledger 齐备 | git + Handoff 表 | git 输出 |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留 → PARTIAL；≥1 VC 三试无效 → BLOCKED。
> `code_review: required`：终验前必须过 Code Review Gate（scope 内新 .sh）。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | worktree 内 `scripts/smart-merge-back.sh`(新)、`scripts/selftest-smart-merge.sh`(新) | 其他脚本（含 set-active-plan.sh——其 bug 只登记不修） |
| 文档 | worktree 内 `references/worktree-isolation.md`（§4 合并回合约区）、`SKILL.md`（仅 :158/:216 两处）、`README.md`（仅 :36/:80 计数） | critical-rules.md（不新增 Rule，零冲突面）、templates、companion、config.json、task-v063 计划目录 |
| 部署位 | 写目标：3 位 task-planner 部署位（Phase 6 --deploy dogfood）；只读：plan-writer agent 2 位 + companion 6 位 | 其他任何技能目录 |
| plans | 本计划三件套 + INDEX + ledger/attest | task-v063 目录（并行任务，指针已归还全局） |

**执行前自我检查**：[x] 在列表内 [x] 必要 [x] 用户明确要求（"智能合并"→选项 A 已确认）

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部 | 智能门设计全文（V1-V6/退出码/selftest 7 用例/联动嵌入点原文） | 本目录 `findings.md` | 必读 | ☑ |
| 项目内部 | 部署 SOP 与中性 CWD 口径 | memory task-planner-repo-deploy-flow.md | 必读 | ☑ |
| 项目内部 | hermetic selftest 范式 | scripts/selftest-dispatch.sh（只读参考） | 参考 | ☑ |
| 项目内部 | 双窗口事故全记录（被机制化对象） | plans/task-v062-interaction-modes/progress.md | 参考 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 合并回 master 是手工三步（merge+清理+重部署对账），无预检无已合并感知——v062 双窗口事故（续跑窗口已合并、本窗口不知情、人工 git 考古）证明该流程在并行会话下不可靠；用户要求机制化为智能门。

**核心问题判断**:
- [x] 解决后能交付吗？（脚本 + selftest + 联动 + dogfood 全链闭环）
- [x] 不解决其他都白费吗？（合并回是每个 worktree 任务的必经步骤，可靠性问题会反复发生）
- [x] 方法清晰可执行？（V1-V6 判据全部有 git 原生命令支撑，hermetic 可测）

## Current Phase
Phase 1

## Next Step
attest 锁定后创建 worktree task-v064-smart-merge-back，基线核对（README 计数/SKILL bullets/worktree-isolation §4 行号）。

## Phases

### Phase 1: worktree 创建与基线核对
- [x] 创建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back`（branch `wt/task-v064-smart-merge-back`，基线 master 3391f64）
- [x] 基线核对：4 项全部与 findings 嵌入点一致（脚本 0 存在/bullets 2 处/README 16×2/合约 §4 在位）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排 + ③ 机械验证命令——Rule 25.3 白名单）

### Phase 2: smart-merge-back.sh 实现
- [x] 按 findings 设计实现 V1-V6 检查序列 + --deploy + 结构化输出 + 退出码 2-7（255 行，commit 9d60da2，主进程独立复测 MERGED/ALREADY_MERGED 双路径）
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 智能门脚本实现（1 文件） | 继承 | worktree 内 findings「smart-merge-back.sh 设计」段（逐字规格） | bash -n 过；手工抽查 ALREADY_MERGED/PRECHECK_DIRTY 两场景 | ≤20min | pending |

### Phase 3: selftest-smart-merge.sh 新套件
- [x] hermetic 7 用例（SM-01..07，commit 19a929e，主进程独立复跑 7/7）
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | selftest 编写（1 文件） | 继承 | worktree 内 findings「selftest 设计」段 + smart-merge-back.sh 接口 + selftest-dispatch.sh 范式 | 裸跑 7/7 EXIT=0；连跑两遍一致 | ≤20min | pending |

### Phase 4: 联动（worktree-isolation + SKILL + README）
- [x] worktree-isolation.md §4 合并回合约接入脚本（机制化入口段纯插入，合约原文零改动）；SKILL.md :158/:216 指针；README :36/:80 计数 16→17（commit 928febb）
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 三文档联动（3 文件 5 处） | 继承 | worktree 内三文件 + findings 嵌入点原文摘录 | grep smart-merge-back 三文件各 ≥1；README 17 ×2；diff 不越界 | ≤15min | pending |

### Phase 5: 全量自测 + Code Review Gate
- [x] 7 套 selftest 全量 fail=0（113/113，verify 22/3=部署滞后预期项）
- [x] Code Review Gate：**6 轮闭环**（R1-R5 CHANGES_REQUESTED：P0 rm-rf 无防呆→守卫重写→别名规范化→break2→selftest 质量；R6 **APPROVED** HIGH+变异测试证 SM-12/13 鉴别力）；修复轮 6 个 commit（cd70ce5/583305c/bb5bdf9/6664aa8/e2a0bf1 等）
- **Status:** complete
- **Executor:** executor + code-reviewer

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | 全量自测 | executor | worktree 内 7 套件清单 | 各 EXIT=0 fail=0 | ≤15min | pending |
| S2 | Code Review Gate | code-reviewer | 新增 2 .sh diff | APPROVED | ≤15min | pending |

### Phase 6: dogfood 合并回（脚本自身执行）+ 部署对账
- [x] **主进程接管执行**（executor 派发 2×ECONNREFUSED → Rule 22.3④ + 白名单①③）：dogfood 首跑 **[V4] ALREADY_MERGED 真实触发**（外部窗口已合并修复轮 6 → 零考古判定）；--deploy 3 位 IDENTICAL rc=0；verify 25/0 + 部署位套件 14/14+18/18
- [x] [CLEANUP] 清理完成（worktree remove + branch -d was f0b76dc）；companion 6 位/agent 2 位无新差异
- **Status:** complete
- **Executor:** 主进程（2026-09-12 22:4x 事实修正：原计划 executor(sonnet-1)，provider 故障 2 次后按白名单①③接管；Handoff #14 为准）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收 | 预估 | 状态 |
|----|------------|--------|------|------|------|------|
| S1 | dogfood 合并 + --deploy 对账 | 继承(executor) | worktree 内脚本 + 本任务 worktree 路径 + 3 部署位 | 脚本输出 MERGED + [DEPLOY] IDENTICAL×3；verify 25/0×3（中性 CWD） | ≤20min | pending |
| S2 | 清理 + agent 2 位/companion 6 位复验 | 继承(executor) | [CLEANUP] 提示行 + agent/companion 路径 | worktree list 无残留 + wt 分支删除 + agent zcode 一致/claude 仅 model 行 + 6 位无差异 | ≤10min | pending |

### Phase 7: 簿记收尾与交付
- [x] verification.md 终验 VC-1..7（全 PASS）+ 委派统计（0.571 + WHITELIST-EXEMPT 如实登记）+ 联动扫描表
- [x] INDEX/attest/ledger + 簿记 commit + 记忆更新
- [x] 交付报告：智能门用法/判定路径/dogfood 结果
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（worktree task-v063 在册但零编辑且 scope 隔离设计——见 findings Technical Decisions；side 指针已指向本计划，全局指针归还 v063） |
| `isolation` | `worktree`（改 canonical 技能源码，§十一 命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back` |
| `branch` | `wt/task-v064-smart-merge-back` |
| `merge_back` | `merged(c878dd3)`（经 smart-merge-back.sh ALREADY_MERGED 判定确认外部窗口已合并；--deploy 3 位 IDENTICAL；worktree/分支已清理） |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步 | 备注 |
|-------|-----------|---------|------|
| Phase 1-7 | ☑ | 2026-09-12 | S1 七条映射 |

## Key Questions
1. MASTER_AHEAD 为何默认中止？→ 自动代 merge master 入分支 = 代替用户做策略分叉（D2 语义）；--force 逃生，冲突仍 STOP。
2. 清理为何不进脚本？→ ALREADY_MERGED 场景可能需先补簿记；脚本输出 [CLEANUP] 提示行，主进程择机执行。
3. 与 v063 并行如何保证不冲突？→ scope 网格隔离（findings Technical Decisions 末行）+ 双方都走 worktree；若 merge 时冲突 → 合约 STOP 报告用户。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 方案 A 合并回智能门（用户选项确认 2026-09-12） | 直接机制化 v062 双窗口事故教训；合并回是每个 worktree 任务必经步骤 |
| 不新增 config 键、不改 critical-rules | 最小联动面；与 v063 并行零冲突设计 |
| dogfood：本任务合并回用脚本自身执行 | MERGED/ALREADY_MERGED/预检路径的真实验证优于合成测试 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 7（Phase 2/3/4/5 子代理执行，含 6 轮 Gate 修复） |
| 主进程直做 Phase 清单 | Phase 1（例外理由:① git/worktree 编排 + ③ 机械验证——白名单）;Phase 6（例外理由:① git 编排 + ③ 机械验证——白名单;provider 故障 2×ECONNREFUSED 接管，Handoff #14）;Phase 7（例外理由:② 计划系统文件维护——白名单） |
| 委派率 | 0.571 < floor 0.7 → WHITELIST-EXEMPT（全部直做理由命中 25.3 白名单 ①③②，不降级；provider 故障属不可抗） |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|-------------|
| 1 | 2026-09-12 18:40 | code-assistant | smart-merge-back.sh 智能门实现 | done | 255 行,5 场景自检+主进程双路径复测,HIGH | commit 9d60da2 | findings「smart-merge-back.sh 设计」 | plans/task-v064-smart-merge-back/subagent-state/02-code-assistant.md | ☑ |
| 2 | 2026-09-12 18:52 | code-assistant | selftest-smart-merge.sh hermetic 7 用例 | done | 7/7 EXIT=0 ×2;主进程独立复跑一致 | commit 19a929e | findings「selftest 设计」 | plans/task-v064-smart-merge-back/subagent-state/03-code-assistant.md | ☑ |
| 3 | 2026-09-12 18:58 | code-assistant | 三文档联动（worktree-isolation/SKILL/README） | done | 4/4 PASS;合约原文零改动;主进程复核 | commit 928febb | findings「嵌入点原文摘录」 | plans/task-v064-smart-merge-back/subagent-state/04-code-assistant.md | ☑ |
| 4 | 2026-09-12 19:02 | executor | Phase 5 S1 全量自测（7 套件+verify） | done | 113/113 fail=0;verify 22/3=部署滞后预期;主进程清理其泄漏的 wt/task-test | subagent-state/05-executor.md | progress Phase5 段 | plans/task-v064-smart-merge-back/subagent-state/05-executor.md | ☑ |
| 5 | 2026-09-12 19:15 | code-reviewer | Phase 5 S2 Gate（2 新 .sh） | done | R1 CHANGES_REQUESTED(P0 rm-rf 无防呆等 12 项)→触发修复 | 复审报告(已入 progress) | verification 质量门控段 | plans/task-v064-smart-merge-back/subagent-state/06-code-reviewer.md | ☑ |
| 6 | 2026-09-12 19:5x | code-assistant | 修复轮 1-2（P0/P1 重写+祖先守卫） | done | cd70ce5+583305c;主进程实证 REJECTED | git log | progress Phase5 段 | plans/task-v064-smart-merge-back/subagent-state/07-code-assistant.md | ☑ |
| 7 | 2026-09-12 20:5x | code-reviewer | Gate 第 3 轮复审 | done | CHANGES_REQUESTED(P0 别名规范化绕过+home 豁免过宽等 14 项) | 复审报告 | 同上 | （复审无 checkpoint,结论入 progress） | ☑ |
| 8 | 2026-09-12 21:1x | code-assistant | 修复轮 3（规范化+守卫分级） | done | bb5bdf9;selftest 12/12;主进程独立抽验 | commit bb5bdf9 | 同上 | plans/task-v064-smart-merge-back/subagent-state/08-code-assistant.md | ☑ |
| 9 | 2026-09-12 21:4x | code-reviewer | Gate 第 4 轮复审 | done | CHANGES_REQUESTED(break 2 单词级 P0+3P3) | 复审报告 | 同上 | plans/task-v064-smart-merge-back/subagent-state/(复审入 progress) | ☑ |
| 10 | 2026-09-12 21:5x | code-assistant | 修复轮 5（continue 2+SM-12/13） | done | 6664aa8;selftest 14/14 ×3 | commit 6664aa8 | 同上 | plans/task-v064-smart-merge-back/subagent-state/10-code-assistant.md | ☑ |
| 11 | 2026-09-12 22:1x | code-reviewer | Gate 第 5 轮复审 | done | CHANGES_REQUESTED(仅 selftest 质量 4 项;continue 2 本体确认正确) | 复审报告 | 同上 | （复审入 progress） | ☑ |
| 12 | 2026-09-12 22:2x | code-assistant | 修复轮 6（selftest 记账+SM-13 真形态;中断恢复后主进程验证残留修改收尾:59） | done | e2a0bf1;14/14+/tmp 口径 13 全过 | commit e2a0bf1 | 同上 | plans/task-v064-smart-merge-back/subagent-state/11-code-assistant.md(中断缺失,残留修改经主进程逐项验证采纳) | ☑ |
| 13 | 2026-09-12 22:3x | code-reviewer | Gate 第 6 轮复审 | done | **APPROVED**(HIGH;变异测试证 SM-12/13 鉴别力;余 5 P3 注释类不阻断) | 复审报告 | verification 质量门控段 | （复审入 progress） | ☑ |
| 14 | 2026-09-12 22:4x | 主进程(接管) | Phase 6 dogfood 合并+部署对账（executor 2×ECONNREFUSED 后白名单①③接管） | done | ALREADY_MERGED 真实触发+deploy IDENTICAL×3+verify 25/0;[CLEANUP] 已执行 | progress Phase 6 段 | progress Phase 6 段 | （主进程直做,无 checkpoint） | ☑ |

## 🔗 Chain 区块配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
