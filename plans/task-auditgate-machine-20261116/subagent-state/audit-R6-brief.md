# R6 复审任务书 — task-auditgate-machine-20261116

你是本计划的独立审计体（R6 复审轮）。工作目录 /mnt/data/dev/task-planner-skill。除检查点外只读审查，禁修改任何仓库文件。

## 背景与需求锚

用户需求逐字锚（plans/task-auditgate-machine-20261116/user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」。计划需求锚 R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」（范围边界仅此两项）。plan_tier=standard / execution_lane=L1。

历轮：R1 REJECTED 14→修复；R2 REJECTED 6→修复；R3 REJECTED 1+3N→修复；R4 REJECTED 6→修复轮 4+微修 4b；R5 REJECTED 8（C-1 VC-2 断言顺序污染 / I-1 S2 留痕 EOF↔VC-6 段锚不兼容 / W-1 漂移条款防滥用 / W-2 会话恢复块 stale / Q-1 V-1.1 时点注记 / N-1 config rc=2 fail-open / N-2 N-3 历史段括注）→**修复轮 5 已完成**（progress.md 有 [plan-audit-R1..R5] 全轨迹与各修复轮段）。

## R6 复审范围（增量简版，禁重审全计划）

只审三面：
①R5 八发现的修复闭环（修复轮 5，progress.md「R5 修复轮」段）：
- C-1：verification.md:21 VC-2 断言捕获时点重排——负例断言组（`n=$?`）须在 fixture 写入与正例执行**之前**、紧跟 r1；正例断言组（`p=$?`）紧跟 r2。**重点核验：同 fixture 下两断言组不再共享被后续用例改写的状态；原有元素未丢**（前置清缓存/awk fixture/enforce env/rm -rf 收尾）。可 /tmp mock 干跑（mock attest 实现，仅替换 A= 路径）正反态。
- I-1：verification.md:37 VC-6 首段改全文件严格 token 正则（`^\[scope-check\] <ISO8601>Z SCOPE-OK diff=[0-9]+ untracked=[0-9]+$`）——核验与 task_plan.md S2 内嵌命令产出形态逐字互洽（task_plan:296/:306/:310/:407 与 progress.md:69 槽位行）；六态自测（无留痕/段内/EOF/缺 token 成分/畸形前缀）。
- W-1：task_plan.md:253 + verification.md:36 漂移双闸（逐名归因+critic 简版复审）语义完整、`[baseline-shift]` 行格式三要素。
- W-2：verification.md:198/:207-211 会话恢复块与当前实态一致。
- Q-1：verification.md:53 V-1.1 时点注记。
- N-1：verification.md:37 config 断言显式 rc 捕获（0 败/1 过/2 败 fail-closed）；chmod 000 三态可复测（本机 uid=1000 非 root）。
- N-2/N-3：progress.md:177/:196 历史段行尾括注/指针（不改写历史正文）。
②修复是否引入新缺陷（主进程已盘上复核：R1-R3 逐字锚 task_plan.md:16-18 未动、user-session-log.md 未动、progress.md 无审计段级 APPROVED 预写——你可独立复核；另核验本轮命令改动是否破坏 check-vc-nonvacuous 判定或引入反引号包裹——run-verification runner 整行 bash -c 执行，Verify command 禁反引号包裹（历史三犯判例））。
③历轮 W/Q/NIT 遗留升级必要性（有新论据才升，无则留档）。

## 输入材料（绝对路径，只读）

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/verification.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/progress.md（[plan-audit-R1..R5]+各修复轮段=审计轨迹）
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/knowledge-brief.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/（audit-R4/audit-R5/fix-R4/fix-R4b/fix-R5 检查点）

可对命令形态做 /tmp 沙箱模拟实测（禁写入仓库目录）。

## 裁决映射（审计体出具，主进程只登记）

`0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED，否则 REJECTED`；WARNING/QUESTION/NIT 留档不阻断。

## checkpoint:（唯一允许写入点）

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/audit-R6.md — 动工前写（轮次/审计体=critic/开始时间/复审范围），完成后追加裁决与发现清单。

## 输出格式（8 字段返回模板）

- status: COMPLETE/FAILED
- result: R6 裁决与核心判断
- evidence: 每项判断的命令+输出锚（盘上实测，禁凭印象）
- files_modified: 仅检查点路径
- verification_results: /tmp 模拟实测命令与结果（如做）
- learnings: 本轮新教训（无则"无"）
- next_steps: 无（裁决归主进程登记）
- risks: 风险披露（无则"无"）

发现清单逐条：编号+严重度+文件:行+一句描述+修复建议；末行唯一裁决行 `结论: **APPROVED**` 或 `结论: **REJECTED**`。
