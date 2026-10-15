<!-- template_type: mini-lite -->
execution_lane: L0（L0-T 纯文本档，Rule 38.7——规则类诉求落 .md 文本即告完成，零新增脚本/零 config 键/零 hook）
<!-- plan_tier: mini -->
<!-- 适用场景: 轻量任务（≤2 文件 ∧ 预估 ≤15min ∧ 单模块）——跳过中/重仪式区块，中/重任务禁用本模板（Rule 38.2） -->
<!-- 触发关键词: 轻量/小改/单文件/快修/微调/15 分钟/小任务 -->
<!-- 推荐 subagent: 主进程直做（白名单②）或 executor(haiku) 单文件小改；无强制派发 -->
<!-- 38.3 区块白名单: 仅 Goal/VC/执行范围限制表/单 Phase/Handoff 表, 增其他仪式区块=模板违约(selftest-plan-tier 断言); [task-v094 T-B2] 2 Phase→单 Phase(实施+验收合一) -->
<!-- Rule 40.2 豁免声明（task-v097）: mini 档不加「🧰 工具选择与编排」区块——Rule 38.3 轻量模板区块白名单的自然延伸,mini 免计划期工具分析仪式;显式声明以防误判缺区块为违约 -->
<!-- Rule 42.5 豁免声明（task-v099）: mini 档不含「质量审查工具」配置行——Rule 38.3 轻量模板契约的自然延伸（同 40.2 豁免行范式） -->
<!-- Rule 42.6 豁免声明（task-v102）: mini 档不含「对齐审查」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5 豁免行范式） -->
<!-- Rule 44 豁免声明（task-v103）: mini 档不含「自动超时默认项」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5/42.6 豁免行范式） -->

# Task Plan: Rule 88 任务射程契约（执行体动作域与呈报域收敛）

## Goal
把用户裁决的执行偏差（清理类指令下执行体越界代落他域提交 + 呈报夹带他域状态）制度化为 skill 条款——task-discipline 新增 Rule 88（纯增量，既有条款零改动），把「射程 = 指令字面点名内容域」从隐性判据显性化为可对照契约，确保今后同类越界被规则拦截。「预估 ≤20min」。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule 88 条款在位：`skills/task-discipline/references/critical-rules-discipline.md` 含 `### 88 任务射程契约` 头 + 88.1-88.6 子条完整内容 | `grep -c "88\." <file>` + Read 复核 | critical-rules-discipline.md |
| VC-2 | 纯增量零回归：`git diff` 仅含新增行（无删除/修改既有行，85/86 等原文零改动） | `git diff --stat` + `git diff` 目视 | git 输出 |
| VC-3 | 索引面同步：核心 `critical-rules.md` 卫星路由索引 task-discipline 行 + `SKILL.md` 三处 discipline 规则清单均含 88 | `grep -n "88" <files>` | critical-rules.md / SKILL.md |
| VC-4 | 回归零新增 FAIL：既有 selftest 全量 fresh 跑，对照 master 基线 | `bash scripts/run-selftests.sh --fresh` | 终端输出 |

**终验规则**: 全部 VC 通过 → COMPLETE（VC ≥2，无 V-N 映射表；mini 档免逐 Phase V-N 映射，Rule 38.4②）

## ⚠️ 执行范围限制

| 改什么（scope_files ≤2） | 禁碰什么 |
|-------|------|
| `skills/task-discipline/references/critical-rules-discipline.md`（在既有最大 Rule 编号段之后追加 Rule 88 全文，实施时以文件实际末段为准） | 禁改任何具体业务实例/他域代码（用户否定方向）；禁改其他卫星/核心规则正文；禁动 `~/.zcode/` 部署位（部署同步待用户单独授权）；禁新增 selftest/脚本/机器门（L0-T 守护 opt-in） |
| `skills/task-planner/references/critical-rules.md`（仅「卫星路由索引」task-discipline 行规则集 +88）+ `skills/task-planner/SKILL.md`（三处 discipline 规则清单 +88） | 禁改索引/路由表其他行；禁改 SKILL.md 其他段落 |

约束: 单模块；scope_files 实为 3（超出 mini 档 ≤2 机器条件，因索引面同步属本变更必要组成，登记 Decisions Made 说明）→ 若 [plan-tier] MISMATCH 提示属预期

## 🔀 隔离决策
**[2026-10-16 用户裁决修正] 走 worktree（wt/task-v180-scope-contract）**：初版决策为「按 task-v178 先例直接主仓操作」，被用户判为违规（多任务同日竞写同文件时目录级隔离失效，须落点级隔离 + 串行收口）。用户选定「冻结主工作区、串行收口」：先由串行器把 task-v181 的 Rule 89 就地提交（188050b）→ 合并 task-v179 的 Rule 87（b8376a3，并集解冲突）→ 本任务 Rule 88 在 worktree 内落盘（d21150c）→ 合并回 master（62694ef）。三号 87/88/89 顺序入 master，全程无双写。**实施前置（同文件串行化，D4/D5）**：critical-rules-discipline.md 末段是三任务并行追加热点，88 殿后按届时实际最大编号序落地（现落于 87 与 89 之间）。

## Phases（固定 1：实施+验收合一，[task-v094 T-B2]；3-File 双条件在本 Phase 照常一次，Rule 19.2 降档）

### Phase 1: 实施+验收（合一）
- Edit `skills/task-discipline/references/critical-rules-discipline.md`：在既有最大 Rule 编号段之后追加 Rule 88 任务射程契约（前置=D4/D5 串行化：task-v179 的 87 与 task-v181 的 89 均已收口进 master）（六子条：射程定义/动作域收敛/呈报域收敛/并行会话 git 手术禁/与既有规则关系/L0-T 机制，含用户裁决判例锚）
- Edit 核心 `critical-rules.md` 卫星路由索引 + `SKILL.md` 三处 discipline 清单：+88（叠加在 task-v179 已落地的 +87 之上）
- `rule-reserve.sh reserve 88 task-v180-scope-contract`（✅ 已预留成功，台账第 72 行）→ 实施 → `land 88 task-v180-scope-contract`
- Read 回填复核 + `git diff` 纯增量核验
- 跑 `run-selftests.sh --fresh` 全量，对照基线零新增 FAIL
- **V-N:** VC-1, VC-2, VC-3, VC-4（总计 ≥2，允许集中映射）
- **Status:** complete
- **Executor:** 主进程（白名单②⑥登记——L0-T 纯文本，无强制派发）
- **完成记录（2026-10-16）:** Rule 88 落 `critical-rules-discipline.md`（插于 87 与 89 之间，88.1-88.6）；索引级联三处（core `critical-rules.md` 卫星索引 + `task-planner/SKILL.md` 两处清单 + `task-discipline/SKILL.md` 三处计数 39→41）；worktree `wt/task-v180-scope-contract` commit d21150c → merge 62694ef；`land 88`（a060ba8）；全量 selftest 81/81 PASS 0 FAIL。

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|--------------|----------------|------|---------|----------------|
| 1 | 无（全程主进程，L0-T 轻量档） | | - | | |

## new_rule
new_rule: 88（Rule 88 任务射程契约；已 `rule-reserve.sh reserve 88 task-v180-scope-contract` 登记成功（台账第 72 行），实施后 land 88）

## Decisions Made

| # | 决策 | 理由 | 来源 |
|---|------|------|------|
| D1 | 落点=task-discipline（执行纪律域）新 Rule 88，非并入既有子条、非 task-drift-guard | 射程契约横跨「动作域+呈报域+并行 git 手术」三面，无单一既有规则统辖；执行体执行期读 task-discipline（task-drift-guard 为只读检测载体，非执行体读取面）；task-v156 Rule 73「防漂移强化」同域先例 | 本任务分析 |
| D2 | 采用新 Rule 编号而非子条扩展 | 与 Rule 31.8（并入既有 Rule 31）不同：31.8 是 Rule 31「修正路由」的自然子面；射程契约为独立纪律面，独立编号可发现性更高；编号初判 87，经查与在途 task-v179（Karpathy 准则收编）撞号——87 归其所有（先预留，台账第 71 行），本任务改用 88（reserve 成功，台账第 72 行） | rule-reserve.sh check 87 → held by task-v179（exit 3） |
| D3 | scope_files=3 超 mini ≤2 机器条件，仍走 mini-lite + L0-T | 索引面同步（核心索引 + SKILL 三处）是本变更不可分割的组成（否则规则成孤儿、路由表失真）；L0-T 档允许 ≤3 文件 | Rule 38.7 |
| D4 | 计划目录 task-v179-scope-contract → task-v180-scope-contract 改名 + Rule 号 87→88（2026-10-16 撞号处置） | 与在途 task-v179 双撞号（任务号+Rule 号）：task-v179 为 Karpathy 准则收编任务（已在 wt/task-v179 提交 f0a4393），Rule 87 归其所有（rule-reserve first-come-first-served）；改名+改号双消解，并登记同文件追加串行化前置（隔离决策段） | 撞号排查：台账 71/72 行 + `check 87` → held by task-v179（exit 3）实证 |
| D5 | 实施顺位=殿后（待 87/89 均收口进 master 后再追加 88） | 2026-10-16 复查发现第三个并行任务 task-v181（Rule 89 前后逻辑一致性禁反言）已直接追加主仓 discipline 文件（工作区未提交 diff 实证）——同文件三任务并行追加，88 殿后按届时实际最大编号序落地；v179 合并时预期与 89 主仓改动冲突，归 v179 会话并集解处置 | git diff critical-rules-discipline.md + plans/task-v181/task_plan.md 实证（台账 73 行） |
| D6 | 走 worktree（推翻初版「直接主仓」隔离决策）+ 参与串行收口 | 用户 2026-10-16 判初版「直接主仓操作」为违规（多任务竞写同文件时目录级隔离失效）；裁定「冻结主工作区、串行收口」；Rule 88 在 wt/task-v180-scope-contract 落盘后合并回 master，三号 87/88/89 顺序入 master 无双写 | 用户裁决（本会话 option 1） |
