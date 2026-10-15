<!-- template_type: mini-lite -->
execution_lane: L0（L0-T 纯文本档，Rule 38.7——规则类诉求落 .md 文本即告完成，零新增脚本/零 config 键/零 hook）
<!-- plan_tier: mini -->
<!-- auto_tier: mini -->
<!-- 适用场景: 轻量任务（≤2 文件 ∧ 预估 ≤15min ∧ 单模块）——跳过中/重仪式区块，中/重任务禁用本模板（Rule 38.2） -->
<!-- 推荐 subagent: 主进程直做（白名单②）；无强制派发 -->
<!-- Rule 40.2/42.5/42.6/44 豁免声明: mini 档免「工具编排/质量审查工具/对齐审查/自动超时默认项」仪式区块（Rule 38.3 区块白名单自然延伸） -->
<!-- 触发 /goal 对齐: 本计划 Goal+VC 即 session goal 的证据源（Rule 40.3）；/goal 自主模式=用户目标指令即全流程授权（P0-1），interaction_mode=silent -->

# Task Plan: Rule 89 前后逻辑一致性与已确立事实禁反言（根治「思路混乱」自相矛盾缺陷）

## Goal
把用户 2026-10-16 /goal「彻底解决 思路混乱问题」（判例：图片链接下载成功后又声称「不确定链接是否可用」= 已确立事实无新证据反言）制度化为 skill 条款——task-discipline 域新增 **Rule 89 前后逻辑一致性与已确立事实禁反言**（89.1-89.6，纯增量，既有规则条目零正改）+ 主仓 master SKILL.md 全集索引级联（1-86→1-89、其余 72→73 条），确保今后「已确立事实短窗内被无依据否定」类思路混乱被规则拦截。预估 ≤15min。

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录）
- **R1**: 「彻底解决 思路混乱问题 比如 一个简单的 上面刚刚说 图片是通过链接下载到本地的 然后声称 不确定图片连接是否可用,按照前后逻辑 前面下载成功后面链接短时间默认是可以的 再进行否定说明很不合理」<sub>（[目标]）</sub>（逐字另见 user-session-log.md #1）

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3 | Rule 89 全文在位（89.1-89.6 子条 grep ≥6）+ 已确立事实禁反言判例锚在位（R1 图片链接反言）+ 既有规则条目零正改（git diff 纯增量）+ 索引级联 + selftest 全量零回归 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule 89 全文在 `skills/task-discipline/references/critical-rules-discipline.md`：`### 89` 标题 + 89.1-89.6 六子条齐备 + 建制含 R1 图片链接反言判例锚 | `grep -cE '^### 89 \|^- \*\*89\.' <file>` ≥7；Read 抽查 | critical-rules-discipline.md |
| VC-2 | 纯增量零回归：既有 Rule 4-86 条目文本零改动（`git diff` 仅含新增行）+ 主仓 master SKILL.md 索引级联 `1-86→1-89`/`其余 72→73 条` 到位 | `git diff --stat` + `grep -c "1-89" skills/task-planner/SKILL.md` ≥1 | git 输出 + grep |
| VC-3 | 交付前 fresh 全量 selftest 零新增 FAIL（对照 master 基线 81 脚本全绿） | `bash skills/task-planner/scripts/run-selftests.sh --fresh` | 终端 Total 行 |

**终验规则**: 全部 VC 通过 → COMPLETE（mini 档免逐 Phase V-N 映射，Rule 38.4②）

## 🎯 核心目标达成裁决（Rule 58.5 — 含 [目标] 需求）
| 字段 | 值 |
|------|-----|
| 目标型需求 | R1 |
| 裁决 | solved（Rule 89 文本条款在位即制度层交付物，Rule 31.8：制度层诉求交付=规则文本变更） |
| 解决证据锚 | `grep -cE '^### 89 ' skills/task-discipline/references/critical-rules-discipline.md` ≥1 + 89.1 总则文本 |
| 未解决面 | 部署位（~/.zcode/skills 等）同步=遗留待用户授权（对齐 v177/v178 先例）；守护机器化=opt-in（89.6 L0-T 未授权） |

## ⚠️ 执行范围限制（强制 — scope_files）

| 类别 | 允许的文件 | 禁止 |
|------|-----------|------|
| 规则文本 | `skills/task-discipline/references/critical-rules-discipline.md`（Rule 89 全文落点，Rule 86 后追加） | 其他任何 skill 规则文件正改；既有 Rule 4-86 条目正改 |
| 索引级联 | `skills/task-planner/SKILL.md`（master 全集索引 1-86→1-89、其余 72→73 条、纪律域 +Rule 89，仅数字/清单级联） | 改其他 SKILL 段落；critical-rules.md/task-discipline SKILL.md 清单（本任务范围外，留待一致化 pass） |
| 计划档案 | `plans/task-v181/**`、`plans/.rule-reservations.jsonl`（reserve/land 89） | 计划区外文件 |
| 部署位 | 无（`~/.zcode/skills/**` 同步=遗留待用户授权） | 部署位写入 |

约束: 单模块；任一机器条件不满足 → [plan-tier] MISMATCH 提示，改回 standard 全量模板。

## 🔀 隔离决策
L0-T 纯文本单规则追加 + 主仓索引级联 → 按 task-v177（4bbc1f6，纯文本主仓 master 直接提交，未开 worktree）/task-v178 先例，直接主仓 master 操作；worktree 完整流程开销与本变更体量不成比例（宪法 §四.6 文本优先铁律）。§11.1(1) 命中（改 `~/.zcode/skills/**`）针对**部署位**——本任务只改**源码仓** `skills/`（非运行中部署），源码仓提交=既有全部 task-vNNN 先例，不触发 worktree。

## Phases（固定 1：实施+验收合一，[task-v094 T-B2]）

### Phase 1: 实施+验收（合一）
- [x] `rule-reserve.sh reserve 89 task-v181`（已原子预留，账本在位）
- [x] Edit critical-rules-discipline.md：Rule 86 后追加 Rule 89 全文（89.1-89.6，含 R1 判例锚 + L0-T 机制子条 89.6）
- [x] Edit task-planner/SKILL.md：master 全集索引 1-86→1-89、其余 72→73 条、纪律域 +Rule 89（3 处）
- [x] Edit critical-rules-discipline.md 复核 + git diff 纯增量核验（VC-2：discipline +12/-0；SKILL 3 行替换）
- [x] `run-selftests.sh --fresh` 全量对照基线：80/81 PASS，唯一 FAIL=rule-reserve-pairing PR-02（89 已 land 配对后剩 88，属在途 v180，非本笔回归）（VC-3）
- [x] `rule-reserve.sh land 89 task-v181` + commit（Rule 89 经跨会话协调并入 master commit 188050b，b8376a3 与 Rule 87 并集解冲突，7d12747 落账 land 89）
- **V-N:** VC-1, VC-2, VC-3（集中映射）
- **Status:** complete
- **Executor:** 主进程（白名单② 计划系统文件维护+文本落盘——Rule 25.3；L0-T 单规则纯文本，无强制派发）

## 📦 Subagent Handoff 登记表（Rule 22.5）

| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|--------------|----------------|------|---------|----------------|
| 1 | 无（全程主进程，L0-T 轻量档） | | - | | |

## new_rule
`89`（Rule 20.6 编号预留：`rule-reserve.sh reserve 89 task-v181` 已原子预留；终验 land；撞号/占位=同 rule 取最后一条，89 实测 free 后预留）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 新增独立 Rule 89（top-level）而非并入既有 Rule 54/65 作子条 | 「思路混乱/前后逻辑一致」= 独立执行纪律域缺陷，对齐 Rule 85/86 先例（新行为纪律=新编号）；87/88 已被 task-v179/task-v180-scope-contract 占用，89 为实测 free |
| 域归属=执行纪律域（task-discipline 卫星），不进核心 critical-rules.md | Rule 82 分层纪律：前后逻辑一致性属执行纪律域（同 85/86） |
| 零新增守护脚本/config 键/selftest 断言 | §四.6 文本优先铁律 + 86.7 范式：L0-T 守护机器化=opt-in，用户 /goal 未显式要求 |
| 索引级联仅动 master SKILL.md（1-89/73 条），critical-rules.md 卫星清单与 task-discipline SKILL.md 清单留待一致化 | 最小竞争面（v179/v180 并行占用 master，减少冲突）；被跳过的清单=簿记级 doc-lag，无 selftest 影响（实测「其余 N 条」/清单均非 selftest 断言） |
| 直接主仓 master 提交（非 worktree） | L0-T 源码仓纯文本，v177/v178 先例；§11 worktree 针对部署位非源码仓 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|-----------|
| `check 88` 显示 rule 88 已被 task-v180-scope-contract 占用（并行会话在途） | 1 | 改取 `next`=89，`reserve 89 task-v181` 原子预留成功 | Rule 20.6 预留前必 `check`/`next` 实测；live-race 下用 `reserve` 原子锁 |
| Edit 技能文件触发 Rule 36 skill-modify-warn（未登记计划范围） | 1 | 本计划 scope_files 已登记 critical-rules-discipline.md，attest 锁定后放行 | Rule 36.2 归因+36.4：改技能文件前先在计划范围表登记 |
