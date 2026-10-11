# 15-code-reviewer-S9 检查点 — task-v151 Rule 66 第二轮全量 CR（带官方 /goal 基准）

<!--
  WHAT: task-v151 Rule 66 全链（条款 848-860/模板/双守卫/attest/selftest/SKILL）第二轮全量 CR 过程与结论（只读审查）。
  WHY: 任务书 16-brief-S9.md §8 断点落盘；本轮新增官方 /goal 文档基准（09 检查点），重点裁决 66.2 口径偏差 + 复验 F1-F3。
  SCOPE: 只读；禁改任何受审文件。本文件=审查产出（非受审对象）。
  需求锚（Rule 51.1a）: R3「使用 VSCode 自带的 /goal 就是目标模式，就是可以让任务朝着这个目标不断地迭代」
-->

## 审查对象与基准
- 审查对象: 主仓 /mnt/data/dev/task-planner-skill，master=ebb5fba（含 101475f Rule 66 落地 + 6cf8cd7 F1-F3 修复）
- 官方基准: subagent-state/09-goal-official-docs.md（zcode.z.ai/cn|en/docs/goal 原文引句）
- 复验面: 11-code-reviewer-S6.md（F1/F2/F3）+ 13-executor-S6fix.md

## V1 偏差裁决对照表（66 锚 | 官方引句 | 定性 | 建议）

### a) 66.2「技能层不可代调/不可读运行态」vs 官方子命令面
- 66 锚: critical-rules.md:852「技能层**不可代调、不可读取其运行态**」
- 官方引句: 09 §1.1「`/goal pause` 暂停 / `/goal resume` 恢复 / `/goal clear` 清除」（均属输入框用户侧子命令）
- 定性: 无偏差（正确 + 兼容）——官方子命令均为用户侧「输入框直接输入」形态，技能层无任何 API 可代调或读态；禁令成立。
- 建议: 无需改。

### b) 「一个会话仅一个目标」vs 66.4「逐 goal 推进」+ Goal 单元表多行
- 66 锚: critical-rules.md:856「执行按 goal 逐个推进」+ :850 六列契约 G1/G2… 多行
- 官方引句: 09 §1.1「一个会话同一时间仅一个目标。」
- 定性: 无真冲突（兼容措辞）——40.3:434 已把机制锚定为「Goal+VC 映射至 /goal **会话目标**（单数）」，66.2:852 明示「Goal 单元表是 /goal 完成审计的**证据源**」；即多行 G 为技能侧任务级分解/调度/证据单元，非多个会话目标。术语同名（goal）易误读为多次 /goal 轮替。
- 建议（建议增强）: 66.2 补一句显式区分——「多 goal 单元=任务级分解与证据源，**不作** /goal replace 轮替；官方 /goal 会话目标同一时间仅一个」。消费方式裁决=只作证据源，非 replace 轮替（轮替会丢审计链且与官方「goal 状态跨会话保留」相悖）。

### c) 官方「todo 未完成不判完成」vs 66.3「[goal:Gn] 证据行门控」
- 66 锚: critical-rules.md:854「status=complete 的 goal 行无对应 [goal:Gn] 证据行=exit 1」
- 官方引句: 09 §1.4「只要还有待办未完成，校验就不会判定完成。」
- 定性: 无冲突（互补确认）——官方以「待办清单完成度」判完成；66.3 以「goal 行证据行」判完成；两者纬度互补（官方=宏观 todo 面，技能=单元证据面），无矛盾。
- 建议: 无需改。

### d) 官方「plan 模式与 goal 模式冲突」vs SKILL/模板提示
- 66 锚: SKILL.md:338（Rule 66 摘要行）+ :218（C45 合规行）+ templates:104（Goal 单元表 WHEN 行）
- 官方引句: 09 §1.6「计划模式与目标模式冲突……**必须先切换执行模式，才能设定目标**；任务运行中也无法设定目标。」
- 定性: 不完整（缺失官方约束提示）——grep 全文 SKILL.md + critical-rules.md「计划模式/plan mode」=0 命中，技能侧未提示「设定 /goal 前须先退出计划模式」。
- 建议（建议增强）: SKILL C45 或 66.2 补一提示行：「/goal 设定须已在执行模式（官方：计划模式与目标模式冲突，任务运行中亦无法设定）」。属用户可操作性提示，不改变门控行为。

### e) 官方 goal 写法要点 vs 66.1 六列契约「完整验证方式列」
- 66 锚: critical-rules.md:850「完整验证方式（可复现：命令+判据 或 路径+关键行 或 diff/输出形态）」
- 官方引句: 09 §2「一句话可陈述但需多轮（easy to state in one sentence but takes many rounds）」+「完成判定基于实据：改出来的文件/命令输出/测试结果」
- 定性: 无偏差（增强/对齐关系）——66.1 目标列「≤1 句」↔ 官方「一句话可陈述」；验证方式三选一（命令+判据/路径+关键行/diff 形态）↔ 官方「具体可校验 + 实据判定」；66.3 证据行三要素 ↔ 官方实据。无冲突。
- 建议: 无需改。

### V1 小结
偏差数 = 2（必须修 0 / 建议增强 2：b 术语区分句、d plan 模式提示行）。a/c/e 三面经原文引句比对 = 无偏差。

## V2 F1-F3 修复面复验
- F1（attest-plan.sh 逃生口接线）: `grep -n 'skip_goal\|skip-goal-check'` → :13 Usage / :24 声明 / :33 分支 / :80 透传，四处全在位；:80 `$([ -n "$skip_goal" ] && echo --skip-goal-check)` 与 _REVIEWER 修复建议方案①一致。**未回退** ✔
- F2（check-complete.sh goal-gate 档位口径）: :1229 `if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE"`（原 `[ "${PLAN_TIER_MINI:-0}" != 1 ]` 已替换），else 分支 :1263 同步为「SKIPPED (mini 档豁免…或无 plan_tier: standard|full 标记)」→ 与 CPD:343 三分支口径统一。**未回退** ✔
- F3（死变量 last57line）: `grep -n last57line selftest-iteration-persistence.sh` → rc=1（无命中）= 已删除。**未回退** ✔

## V3 零回归面运行输出原文（4 命令）
```
$ bash -n check-plan-dispatch.sh          → CPD_OK
$ bash -n check-complete.sh               → CC_OK
$ bash -n selftest-goal-unit-goal-mode.sh → GUS_OK
$ bash scripts/selftest-goal-unit-goal-mode.sh ; echo exit=$?
G-01 PASS critical-rules.md '### 66 ' 标题锚 =1
G-02 PASS critical-rules.md '66.x ' 六子条锚 =6
G-03 PASS templates/task_plan.md Goal 单元表区块=1 + 六列表头=1 + 插入位语义（L87<L104<L116）
G-04 PASS SKILL.md 'Rule 66' 计数=2（≥2）+ C45 合规行=1（=1）
G-05 PASS check-plan-dispatch.sh 'Goal 单元表' 锚=10（≥1）+ '--skip-goal-check' 锚=5（≥1）
G-06 PASS check-complete.sh 'goal-gate' 锚=9（≥1）+ '[goal:G' grep 锚=4（≥1）
G-07 PASS selftest-registry.tsv 末行含 selftest-goal-unit-goal-mode.sh
G-08 PASS config.json properties 键名 goal[_-](unit|gate|advance) =0（零新键）
G-09 PASS SKILL.md 行数=511 ≤515（D1 上调后上限）
Total: 9 PASS=9 FAIL=0
exit=0
$ grep -c '^66\.' references/critical-rules.md → 6
```
- 只读约束: 全程未写受审文件；`git status --short` 仅显示 plans/ 下的既有计划产物与未跟踪目录（非本审查写入）。

## V4 官方语义进条款增量建议（只列不改）
1. [建议增强/b] critical-rules.md:852 66.2 末尾补显式区分句（多 goal 单元=证据源，非 /goal 轮替；官方单目标约束）。置信度 MED。
2. [建议增强/d] SKILL.md:218 C45 或 critical-rules.md:852 补「设定 /goal 须先退出计划模式（官方约束）」提示行。置信度 MED。
3.（可选🟡）66.2 可选择性列出官方子命令面 show/pause/resume/clear 作「用户侧能力」说明，便于读者区分「技能层禁令」与「用户侧可用」；纯可读性，非必需。置信度 LOW。

## 最终结论
```
status: done
acceptance: 4/4 pass — [V1:PASS V2:PASS V3:PASS V4:PASS]
files: none（只读）
evidence: bash -n 三脚本→CPD_OK/CC_OK/GUS_OK; selftest-goal-unit-goal-mode.sh→9 PASS/0 FAIL exit=0; grep -c '^66\.'=6; attest :13/:24/:33/:80 四处接线在位(F1未回退); check-complete:1229 grep plan_tier standard|full(F2未回退); grep last57line rc=1(F3未回退); 偏差数=2（必须修 0/建议增强 2: b 术语区分句/d plan模式提示行）+ 结论=CHANGES_REQUESTED(必须修 0/建议增强 2)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/15-code-reviewer-S9.md
findings_written: none
blockers: none
confidence: MED
```
