# 任务书 S3：check-complete.sh 终验对照段 + SKILL.md 级联

## 1. 目标
task-v151 的 S3 单任务：worktree 内 check-complete.sh 追加「Rule 66.3 Goal 单元表终验对照段」+ SKILL.md 级联（Rule 66 登记行 + 1-65→1-66 计数三处 + C45 合规行）。
- 需求锚（Rule 51.1a）：R2「...设定目标之后包含完整的验证，然后使用 goal 来进行任务的推进，确保整个任务执行的可靠性」

## 2. 输入
- 计划三文件（只读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/{task_plan.md,findings.md,progress.md}
- 材料包：
  - ① 设计蓝本 /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/design-draft.md —— §4.2「check-complete.sh 伪码」+ §4.3「SKILL.md 级联（4 处）」全文照做
  - ② S1 产物 critical-rules.md 行 848-860（Rule 66 条款，66.3 三证据/66.4 G 序语义）
  - ③ S2 产物：check-plan-dispatch.sh 行 314 起的 66.5 段（模板区块格式参考：`^## 🎯 Goal 单元表` 标题锚、六列表头、G 行数据行样式）
- 伴飞技能：无（纯机械单元）；并行组：无（串行槽）
- 检索优先契约（Rule 63）：awk 状态机写法参照 check-complete.sh 内既有「用户需求原文」区块提取段（行 806 附近状态机范式，禁区间 next 坍缩）；不确定先读同类实现再写

## 3. 验收标准
- A1：worktree skills/task-planner/scripts/check-complete.sh 追加 goal-gate 段（挂点=既有终验段内、输出行前缀 `[goal-gate]`）：
  - ① awk 状态机抽「^## 🎯 Goal 单元表」区块（区块缺失=该段静默跳过+一行提示；mini 档整段跳过）
  - ② status=complete 的 goal 行 → 在 progress.md grep `[goal:Gn]` 证据行，缺 → 输出 `[goal-gate] ✗ G<n> complete 无 [goal:Gn] 证据行` 并使脚本 exit 1（与 64.2 门控同档语义）
  - ③ 存在 status=pending 的 goal 行 → 输出 `[goal-gate] ⚠ 有 goal 未 complete，终态最高 PARTIAL`（提示行，不单独 exit 1，降级语义对齐 58.5）
- A2：worktree skills/task-planner/SKILL.md 级联 4 处（design §4.3 原文位）：
  - ① 行 9（References 区）/行 280（Critical Rules 总述）/行 360（References 表 critical-rules.md 行）：`1-65`→`1-66`（先 grep -n '1-65' SKILL.md 确认全部命中行，v149 判例：计数锚级联须覆盖全部形态）
  - ② Rule 65 摘要行（约行 335）后插 Rule 66 一行摘要（一句话版：goal 单元固化六列契约+/goal 内置命令映射供料口径（40.3 延伸）+逐 goal 验证通过门 66.3+分解→调度→逐个解决推进序 66.4；机器面=check-plan-dispatch/check-complete+selftest-goal-unit-goal-mode.sh，零新 config 键）
  - ③ 合规清单 `| C44 |` 行后追加 `| C45 |` 行（goal 单元自查：66.1 六列填写 / 66.3 [goal:Gn] 证据行逐落 / 66.4 G 序推进 / 66.2 禁 /goal 代调声称；机器面=check-plan-dispatch 硬门+check-complete 对照+selftest-goal-unit-goal-mode.sh 静态守护；mini 档豁免）
  - 既有 1-65 条款正文零改写
- A3：试跑输出原文入检查点：
  - `bash 脚本 /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/task_plan.md`（该计划 G1/G2 complete 但 progress 无 [goal:Gn] 行 → 应输出 [goal-gate] ✗ 提示且 exit 1——这是正确行为，记录为符合语义）
  - 同计划 + sed 临时副本删 Goal 单元表区块 → 段静默跳过提示（不 exit 1）
- A4：改动文件注释含 What+Why（Rule 45）

## 4. Scope 禁改
- 只动 worktree 内 scripts/check-complete.sh + SKILL.md 两文件；禁 git 写操作；禁改 check-plan-dispatch/critical-rules/模板（已交付面）；SKILL.md 除级联 4 处外零其他改动

## 5. 工作路径
worktree=/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode（不切 CWD）

## 6. 时长预算
脚本+文档级联 → 25 分钟；超时返回 partial

## 7. 返回格式（严格 8 字段，字段后无内容）
```
status: done | partial | failed
acceptance: <n>/4 pass — [A1:PASS A2:PASS A3:PASS A4:PASS]
files: <绝对路径>(+N/-M); ...
evidence: <file:line 或 命令→关键输出行>; 两态试跑各一行
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/06-executor-S3.md
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint
/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/06-executor-S3.md：里程碑带时间戳；遇错写「错误与受阻」；结束写「最终结论」=同一 8 字段块

## 9. 上下文预算
只 Read 本节列出路径与区段（check-complete.sh 全文、SKILL.md 行 5-15/275-345/355-365 区、design §4.2/§4.3、critical-rules 行 848-860、check-plan-dispatch 行 314-404）；禁贴计划全文/大段源码；完成前 Read 两目标文件确认落盘