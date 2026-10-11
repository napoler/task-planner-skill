# S32 组3 A-3 每 Phase 重复检测合并 — 干净上下文验证（三小项）

- 检查点: 全部完成（甲/乙/丙 三小项 + 证据落盘）
- 验证基线: worktree /mnt/data/dev/task-planner-skill-worktrees/task-v091 HEAD=a05bd5e（只读，git status 干净）
- A-3 落地 commit: 53ff783（SKILL 三处+Rule 15/24）/ a243253（check-complete COMPLIANCE-CHECK 段）
- 夹具: /tmp/s32-a3/（已自清）；check-drift.sh 在 53ff783~1→a243253 间 diff=0 行（A-3 零改动，佐证基线成立）

## 判定总表

| 小项 | 期待 | 实测 | 判定 |
|------|------|------|------|
| 甲 流程层 | drift 恰 1 次/Phase（skill 唯一载体、无脚本双跑）；2-Phase 无 plan-resume；C 项仅列脚本未覆盖项 | 全部符合 | **PASS** |
| 乙 机器层 | standard 缺委派统计段 → `[compliance] WARNING` 点名；mini 不误报（分域跳过） | 全部符合（rc=0 warn 不阻断） | **PASS** |
| 丙 三态等价 | ALIGNED/DRIFT/BLOCKED 判定与 critical-rules:38-46 一致，BLOCKED→STOP 不缩水 | 保留侧 Skill 三态表完整承载，STOP 语义在案；三夹具人工判态与契约逐条一致 | **PASS** |

总判定: **PASS（3/3）**

## 甲（流程层）— 2-Phase 样例走一遍 Phase complete

夹具 /tmp/s32-a3/plan-2phase（standard，2 Phase 全 complete，主进程白名单②，VC-1~5 + V-N 映射）：
- `check-complete.sh` rc=0：`[plan] ALL PHASES COMPLETE (2/2)` + `[compliance] OK (…tier=standard 分域: 3-File/VC 行数全量/委派统计段已检/Handoff verify_done已检)`
- `check-plan-dispatch.sh` rc=0：`[plan-dispatch] fail-open: 无派发型 Phase`（非派发型零断言，与 S31 A-3 38.4④ 口径一致）
- `check-3file-gate.sh` rc=0（步骤 4 硬门控）

按修订后 SKILL.md（worktree 行位，内容定位）走 Phase complete 全流程，实际会调用的每个检测：

| 步骤 | 检测/动作 | 出处（worktree SKILL.md 原文定位） |
|------|-----------|------|
| 1-2 | Edit task_plan.md → in_progress + TodoWrite | Phase 循环 步骤1/2 |
| 2.5 | Executor 字段查（白名单②命中，无派发） | 步骤 2.5 委派检查点 |
| 3 | 三文件回填 + ledger-append.sh（执行中留痕，非检测） | 步骤 3a-3c |
| 4 | `check-3file-gate.sh <plan-dir>`（exit 1 禁翻转） | :99 步骤4 硬门控 |
| 4.5 | git commit + `git status --porcelain -- <scope>` 空 | 步骤 4.5（Rule 27） |
| 5 | `sync-todos.sh --index` | 步骤 5 |
| 6 | `Skill("task-drift-guard")` **恰 1 次** | :102 `**[DRIFT CHECK]** 调用 Skill("task-drift-guard")（本触发点唯一检测载体——check-drift.sh 仅作可选佐证，不双跑；C4）` |

对照判定：
1. **drift 恰 1 次/Phase、无脚本双跑** ✓ —— :102 原文 + C4 表行（:179）双处在案：「`check-drift.sh` 仅作可选佐证，不再与 skill 双跑」。Phase 循环段（:87-140）内 `check-drift.sh` 零调用点。
2. **无 plan-resume** ✓ —— Phase 循环段内 plan-resume 零出现；全文件仅 3 处（:136 chain 交接「恢复触发点…按 Rule 24.5 自主续推（per-block 扫描已收敛）」/ :188 C13 / :301 Rule 24 摘要）。2-Phase 样例 = ≤3 Phase 命中 24.7「本次任务 ≤3 个 phase → 跳过」+ 非交付终态/会话恢复触发点 → 0 次调用。与提案 R2/R7/A-3 收益面「仅 >3 Phase 构成节省，≤3 Phase 已由 24.7 豁免」一致。
3. **C 项仅列脚本未覆盖项** ✓ —— C1-C27 表（:176-204）已完成「机器门承载/人工保留」标注改造；逐条归类（人工核读原文）：
   - 机器门承载（8 条）: C5（check-complete 终验抽查）/C6（逐条校验）/C7（终态判定）/C9（全 Phase complete）/C14（check-delegation stats 终验）/C17（porcelain 终验预检）/C19（Learning Gate）/C21（REFLECT-GATE）
   - 混合（机器门承载+人工，4 条）: C16/C22/C24/C26
   - 人工保留（纯人工 9 条）: C8/C10/C11/C12/C15/C18/C20/C23/C25（其中 C15/C20 明示「无机器门承载，人工保留不收敛」= 终审轮1 #4 verify_done 类登记在案）
   - 条件性无记行（3 条）: C1/C2/C3（天然人工）+ C27「未点名则…无需记行」
   - 人工面 9~10 条 ≈ 提案 L92「仅脚本未覆盖 ≈10 项人工」预估，量级一致 ✓
   - 附注（观察项，非 FAIL）: C1/C2/C3/C13 未加承载标注；C13 为 skill 触发项（24.5 自主续推）天然人工，C27 已带「无需记行」注，不影响「C 项仅列脚本未覆盖项」预期。
4. N/A 形式化记行条款已删 ✓ —— 全 SKILL.md grep「N/A 记行」「强制记行」0 命中（仅 :227 Rule 8.1 正文「D 类 N/A（天然开新计划）」属判定语义非记行条款）；36.4③ 删除性行为已闭环。

## 乙（机器层）— 缺 C 项产物计划跑 check-complete.sh

脚本接口: `bash check-complete.sh <task_plan.md>`（SKILL_ROOT/CONFIG_JSON 由脚本自解析，:101-104；COMPLIANCE-CHECK 段 :963-1025，仅 python_rc=0 后执行）。

**standard 缺项负例**（/tmp/s32-a3/plan-standard，verification.md 故意无「委派统计」字面量，2 主进程白名单 Phase 全 complete）：
```
[compliance] WARNING (task-v091 A-3 终验抽查, warn 档不阻断, tier=standard 分域): 抽查缺项点名 —  verification.md 委派统计段缺失(C14/Rule 25)
rc=0
```
→ `[compliance] WARNING` 点名缺失项 ✓（warn 档不阻断 = 提案「先加后删」护栏语义；exit 码仍为 python_rc）

**正例对照**（同夹具补回「## 委派统计」段后重跑）：
```
[compliance] OK (task-v091 A-3 终验抽查通过, tier=standard 分域: 3-File/VC 行数全量/委派统计段已检/Handoff verify_done已检)
rc=0
```

**mini 豁免项缺失不误报**（/tmp/s32-a3/plan-mini，`<!-- plan_tier: mini -->`，无委派统计段、Handoff 表无 verify_done 列/无数据行）：
```
[compliance] OK (task-v091 A-3 终验抽查通过, tier=mini 分域: 3-File/VC 行数降档阈值/委派统计段豁免跳过/Handoff verify_done豁免跳过)
rc=0
```
→ tier=mini 分域: ③④ 两项按 38.4③/mini-lite 口径跳过，无误报 ✓（终审 #8 互锁达成：mini 计划缺豁免项产物不产生新断言）。源码印证: :1003 `if [ "${PLAN_TIER_MINI:-0}" != 1 ]` 包裹 ③委派统计段 + ③b S-unit + ④Handoff verify_done。

补充: 委派率门控同域降档在案 —— standard 侧 `DELEGATION GATE PASSED (rate=0.000 … WHITELIST-EXEMPT)`；mini 侧 `floor=0.0`（:116-121 plan_tier:mini → floor 0.7→0.0），两脚本口径一致。

## 丙（三态等价）— 保留侧检测 vs critical-rules:38-46 契约

**契约原文**（worktree references/critical-rules.md:38-46，Rule 11）：
```
每个 phase 标记 complete 后、连续 ≥3 次工具调用后、切模块前，调用：
```
```
Skill("task-drift-guard")
```
- ✅ ALIGNED → 继续执行
- ⚠️ DRIFT → 记录到 progress.md，继续但警觉
- 🔴 BLOCKED → STOP，报告用户，等决策
```

**保留侧实现**（task-drift-guard/SKILL.md:52-54 三态表 + :74-75 Step 6 动作 + 铁律「只读。不改任何文件」+ worktree task-planner SKILL.md:107「发现 BLOCKED 时必须等用户明确决策后再继续」）：
```
| ✅ ALIGNED | 与计划一致 | 继续 |
| ⚠️ DRIFT | 偏离但未阻塞 | 询问用户 |
| 🔴 BLOCKED | 严重偏离，关键路径被跳过 | STOP 等决策 |
- ✅ → 继续
- ⚠️ → 问用户：纠正/继续/STOP
- 🔴 → STOP 所有写入，等用户决策
```
→ 三态枚举、判定原则（改计划外文件/与 VC 不符/跳过关键路径做低优先级，drift-guard SKILL Step 4「漂移判定三原则」）、BLOCKED→STOP 语义（STOP 所有写入 + 等用户决策）**全部在案，无缩水** ✓

**三夹具人工判态**（按 SKILL 修订后 C4 描述 = 保留侧 Skill 形态判三态；夹具 /tmp/s32-a3/drift-{aligned,drift,blocked}）：

| 夹具 | 构造 | 人工判态 | 契约动作（critical-rules:42-44） | 一致 |
|------|------|---------|--------------------------------|------|
| ALIGNED | 2 Phase 全 complete，文件全在「执行范围限制」内，Goal 关键词 100% 命中 progress | ✅ ALIGNED | 继续执行 | ✓ |
| DRIFT | progress 记「顺手修改了 web/src/index.js（计划范围外）」= 三原则①改计划外文件 | ⚠️ DRIFT | 记录 progress.md，继续但警觉 | ✓ |
| BLOCKED | 用户第 2 次反馈「还是不行」（31.1② 重复反馈形）+ Phase 1 回归验证 pending 却跳过直接 complete Phase 2 = 三原则③跳过关键路径 | 🔴 BLOCKED | STOP，报告用户，等决策 | ✓ |

3/3 判态与契约逐条一致。BLOCKED 双重命中（用户重复反馈 + 关键路径跳过）下 STOP 语义不缩水——SKILL.md:107 与 :229「B/C 类处理完必须再跑 Skill("task-drift-guard")」+ :530 高频段「🔴 BLOCKED → 立即 STOP；不自动入 todo（避免静默改向），必须报告用户等决策」均在案。

**佐证（可选侧，如实报告）**：check-drift.sh（当前仅作可选佐证）输出为二元 [DRIFT] score>0 / rc 0|1，全文无 ALIGNED/BLOCKED 字面量 → 三态契约本就只能由 Skill 侧承载，A-3「留脚本弃 skill」不存在语义缩水路径。脚本侧两既存 quirk（非 A-3 引入，git diff 53ff783~1..a243253 对 check-drift.sh = 0 行）：① `check_phase_order` 初值 `prev_status="pending"` 使全 complete 序列恒误报 CRITICAL PHASE-SKIP（ALIGNED 夹具也被误报 rc=1）；② `check_scope_breach` 提取范式对两列范围表取不到「允许的文件」列（恒 SCOPE-NONE 跳过）。脚本既降级为可选佐证，两 quirk 不损 A-3 验收；但若操作者以脚本输出为准会误判，建议后续任务加固。

## 残留风险/观察
1. **（low）check-drift.sh 既存 quirk ①②**（见上）——非 A-3 范围；「可选佐证」定位下会误导，建议立后续任务修复或移除佐证地位。
2. **（cosmetic）compliance WARNING 双空格**：`抽查缺项点名 —  verification.md`（`%s` 前自带前导空格 + 模板已有空格），仅显示问题。
3. **（low）C 表标注一致性**：C1/C2/C3/C13 无「承载」标注（C13 天然 skill 触发、C1-C3 天然人工，语义不受影响）。
4. 未验证面：selftest 锚 token 10 个文件（终审 #5 清单）本节点未跑——属 S32 其他组职责；A-3 两 commit 未触碰 selftest 目录（--stat 实证）。

## 验证证据索引
- 提案验证设计段: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/workflow-evidence/efficiency-proposal.md L90-98（A-3「子代理干净上下文验证设计」原文：甲=drift 恰 1 次/无 plan-resume/C 项仅列脚本未覆盖项；乙=warn 点名；丙=三态判定与被删侧一致、BLOCKED→STOP 不缩水）
- 关键原文均附 file:line（worktree 坐标）+ 引用，见上文三节
- 置信度: 甲/乙/丙 判定 HIGH（命令输出直接回贴 + 源码 Read 复核双证据）
