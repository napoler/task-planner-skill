# 2-insert-S3 checkpoint — drift 卫星三处插改

## 目标文件
- `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115/skills/task-drift-guard/references/critical-rules-drift.md`

## 改动行号与内容
1. **L68 (64.7)**：整行替换为草案 §3 64.7 v2 全文（单行，无裸换行）。
   - old 前缀：`- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=\`user-session-log.md\` 最近条目号+一句话摘要…`
   - new 前缀：`…最近含目标/指令类内容的条目号+一句话摘要（跳过寒暄/确认类条目；同号条目优先——与 51.3 双锚口径一致；…`
2. **L63 (64.4 片段 1)**：在原三锚输入段 `③ scope 文件集锚…；` 后插入第四锚及分工说明，末尾改为 `——四锚合计为「四锚输入」，缺任一即不完整；`。
   - old 片段：`drift-checker 任务书（61.2 派发契约之上）必须内嵌三锚输入：① Goal 原文锚（task_plan.md Goal 段绝对路径+行锚，或 ≤3 行原文摘录）② 最近动作清单锚（progress.md 尾部 N 行路径锚）③ scope 文件集锚（执行范围表路径）；`
   - new 片段：在该片段后紧接 `上述三锚外新增第四锚 ④ 用户原话对照锚（user-session-log.md 最近含目标/指令类内容条目号+一句话摘要，专档未建档(tier) 时显式记 \`专档=未建档(tier)\`，取样口径与留痕处置见 64.7；与 64.2.1 分工：64.2.1 管 Goal∩原话零交集判定与不可豁免门控面，本锚提供证据面）——四锚合计为「四锚输入」，缺任一即不完整；`
3. **L63 (64.4 片段 2)**：句尾 `三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。` 后追加四锚同步基线说明。
   - old 片段：`无输入锚的检查=形式过场，三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。`
   - new 片段：`无输入锚的检查=形式过场，三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。扩展为四锚后（含 ④ 用户原话对照锚）判定基线与 64.2.1/64.7 同步：Goal∩专档原话双锚可复核，防对污染基线自证 ALIGNED。`

## 自验命令与输出原文

### 1) `grep -cF '含目标/指令类内容的' <文件>` 期望 ≥1
```text
1
```
**结果：PASS (1 >= 1)**

### 2) `grep -cF '四锚合计为「四锚输入」' <文件>` 期望 1
```text
1
```
**结果：PASS**

### 3) `grep -cF '专档=未建档(tier)' <文件>` 期望 ≥1
```text
2
```
**结果：PASS (2 >= 1)**

### 4) `git -C … diff --numstat -- skills/task-drift-guard/references/critical-rules-drift.md` 期望 `2 2`
```text
2	2	skills/task-drift-guard/references/critical-rules-drift.md
```
**结果：PASS**

### 5) `git -C … diff -- <该文件>` 目检：仅 64.7/64.4 两行变化，64.6 行不在 diff 中
```diff
diff --git a/skills/task-drift-guard/references/critical-rules-drift.md b/skills/task-drift-guard/references/critical-rules-drift.md
index 71a5e56..40c941e 100644
--- a/skills/task-drift-guard/references/critical-rules-drift.md
+++ b/skills/task-drift-guard/references/critical-rules-drift.md
@@ -60,10 +60,10 @@
 
 64.3 **节奏化提醒（rhythm nudge——「时刻」载体）**：`zcode-posttooluse.sh` 在存在有效活跃计划（会话 side 指针解析出 plan-dir）时维护会话级计数状态 `<plans>/.drift-rhythm/<sidkey>.state`（三键 `{count, last_inject, due}`，due=待投递标志——分支命中轮延迟投递的持久位；fail-open：目录不可写/解析失败即静默跳过），每满 N=10 次工具调用（env `TASK_PLANNER_DRIFT_RHYTHM_N` 可覆盖）经既有 additionalContext 通道注入单行提醒 `[drift-rhythm] 距上次偏移检查已 ≥N 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套` 并重置计数（last_inject=count）。注入=软提醒不拦截（PostToolUse additionalContext 无拦截力是平台事实），拦截力由 64.2 承载——两层分工：64.3 管「时刻」（高频可见性），64.2 管「必查」（收口强制）。性能约束：状态文件三键读写 O(1)+指针解析复用既有函数，禁止全仓扫描或大文件解析。
 
-64.4 **判定输入契约（anti-vacuous-ALIGNED）**：drift-checker 任务书（61.2 派发契约之上）必须内嵌三锚输入：① Goal 原文锚（task_plan.md Goal 段绝对路径+行锚，或 ≤3 行原文摘录）② 最近动作清单锚（progress.md 尾部 N 行路径锚）③ scope 文件集锚（执行范围表路径）；agent 侧判定必须逐锚引用证据写检查点（对照结论可复核），无证据锚的 ALIGNED 判定无效 = 按 64.1 未执行处理。配套：drift-checker agent 定义增补判定输入要求段（纯增量 ≤3 行，部署位随 Phase 5 同步）。What=判定必须可复核；Why=历史偏移案例（task-v075/v095/v096）多发生在「未对照 Goal 的自由执行」，无输入锚的检查=形式过场，三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。
+64.4 **判定输入契约（anti-vacuous-ALIGNED）**：drift-checker 任务书（61.2 派发契约之上）必须内嵌三锚输入：① Goal 原文锚（task_plan.md Goal 段绝对路径+行锚，或 ≤3 行原文摘录）② 最近动作清单锚（progress.md 尾部 N 行路径锚）③ scope 文件集锚（执行范围表路径）；上述三锚外新增第四锚 ④ 用户原话对照锚（user-session-log.md 最近含目标/指令类内容条目号+一句话摘要，专档未建档(tier) 时显式记 `专档=未建档(tier)`，取样口径与留痕处置见 64.7；与 64.2.1 分工：64.2.1 管 Goal∩原话零交集判定与不可豁免门控面，本锚提供证据面）——四锚合计为「四锚输入」，缺任一即不完整；agent 侧判定必须逐锚引用证据写检查点（对照结论可复核），无证据锚的 ALIGNED 判定无效 = 按 64.1 未执行处理。配套：drift-checker agent 定义增补判定输入要求段（纯增量 ≤3 行，部署位随 Phase 5 同步）。What=判定必须可复核；Why=历史偏移案例（task-v075/v095/v096）多发生在「未对照 Goal 的自由执行」，无输入锚的检查=形式过场，三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。扩展为四锚后（含 ④ 用户原话对照锚）判定基线与 64.2.1/64.7 同步：Goal∩专档原话双锚可复核，防对污染基线自证 ALIGNED。
 
 64.5 **机制守护（mechanism guard）**：机器面五接线——`ledger-append.sh` VALID_EVENTS 增 `drift_check` 枚举（值尾追加，锚行随实现漂移以 grep VALID_EVENTS 为准，既有枚举零改动）；`check-3file-gate.sh` 追加第 6 条件段（既有条件 1-5 语义零改动）；`zcode-posttooluse.sh` 追加计数段（复用既有 additionalContext 注入 helper）；`../../task-planner/companion/agents/drift-checker.md` 判定输入段；SKILL.md 接线 2 处（Phase 循环第 6 步 [DRIFT CHECK] 块内追加 64.1 留痕行 + 合规清单 C4 行末追加留痕句——DCS-01~20 字面锚零触碰）。守护面=`scripts/selftest-drift-enforcement.sh`（静态断言+行为级 fixture（DCE-01~23，随守护面演进），fixture 范式对照 selftest-four-file-dataflow.sh）+ selftest-registry.tsv 登记。What=每处接线挂既有管线+静态与行为双断言；Why=53.2 根治判据=机制·守卫·载体三件齐，条款无挂点=死文（59.6 同范式）；行为 fixture 防「守措辞不守行为」错位复发（根因③）。
 
 64.6 **零新 config 键与既有 Rules 关系**：不新增任何 config.json 键——降档与调参走 env（`TASK_PLANNER_DRIFT_ENFORCE` / `TASK_PLANNER_DRIFT_RHYTHM_N`），豁免走计划声明行 `drift_exempt`（59.7/43.4/44.4 同范式：键膨胀=配置面失控面）。关系：Rule 11/15 触发时机与三态判定原文零改动（本条只加证据链与节奏）；Rule 61 载体契约零改动（64.4 只加输入要求）；Rule 19.2 门控=第三条件追加非改写；Rule 62 四文件流转正交；SKILL.md 上界计数措辞（「1-62」等）本次不动（63 未落地避免计数失真，v146 同款遗留延续）。
-- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近条目号+一句话摘要（61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失/空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效（64.1 未执行同口径），按 🔴BLOCKED 处置升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md 的 trash 审计任务项条目（取证报告 E6-02/E6-03）+E6-06（专档 NOT FOUND）。
+- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近含目标/指令类内容的条目号+一句话摘要（跳过寒暄/确认类条目；同号条目优先——与 51.3 双锚口径一致；61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失且 plan 属 trivial 代码修复档（init-session.sh user-session-log 按需创建档）→ 检查点记 `专档=未建档(tier)` 并按 64.1 留痕即可，不判 BLOCKED；专档在位但空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效，按 64.1 未执行处置（64.2 门控拦截）并叠加 🔴BLOCKED 升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。**与 64.2.1 分工**：64.2.1 管零交集的判定与不可豁免（门控面），本条管检查点留痕字段与专档缺失处置（证据面）；同一事实由 64.2.1 定级、本条留痕，惩罚不双计。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md 的 trash 审计任务项条目（取证报告 E6-02/E6-03）+E6-06（专档 NOT FOUND）（判例=task-drift-fakeqc-20261115 判例）。
```
**结果：PASS**（仅 64.4 与 64.7 两处行变化；64.6 行未出现在 diff 中）

### 6) 64.7 v2 行必须单行（无裸换行）
```text
LINE68_SINGLE: True
LINE68_ENDS_WITH_NEWLINE: True
LINE68_CONTAINS_EMBEDDED_NEWLINE: False
LINE68_PREFIX: - **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-check
```
**结果：PASS**

## 总结
- Edit①②③ 均已按草案 §3/§4.5 落盘，new 文本未做任何字词改动。
- 未修改 64.6 行及其他行；未执行 git 写操作。
- 自验 6 项全部 PASS。