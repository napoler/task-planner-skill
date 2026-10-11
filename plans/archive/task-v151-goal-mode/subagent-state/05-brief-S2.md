# 任务书 S2：模板插入 Goal 单元表 + check-plan-dispatch 66.5 校验段

## 1. 目标
在 worktree 内落地 task-v151 的 S2 单任务：模板插入「🎯 Goal 单元表」区块 + check-plan-dispatch.sh 追加 Rule 66.5 校验段。
- 需求锚（Rule 51.1a）：R2「核心说法就是将任务分解拆解为固定的，分析明确之后设定为目标，然后并且设定目标之后包含完整的验证，然后使用 goal 来进行任务的推进，确保整个任务执行的可靠性」

## 2. 输入
- task_plan（只读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/task_plan.md
- findings（只读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/findings.md（本 S2 无调研结论，findings_written=none）
- progress（只读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/progress.md
- 材料包：
  - ① 设计蓝本 /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/design-draft.md —— §3「Goal 单元表列契约与模板区块草案」代码块照抄入模板；§4.1「check-plan-dispatch.sh 伪码」语义实现
  - ② S1 产物 /mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode/skills/task-planner/references/critical-rules.md 行 848-860（Rule 66：66.1 六列契约 / 66.5 mini 豁免与 --skip-goal-check 逃生口语义）
- 伴飞技能：无（纯机械单元）
- 检索优先契约（Rule 63）：脚本既有范式不确定 → 先 Read 脚本内同类段（awk 状态机写法 / --skip-* 逃生口 / 档位判定），禁凭记忆；无解写 blockers+已检索清单，禁编造
- 并行组：无（串行槽）

## 3. 验收标准
- A1：worktree 内 skills/task-planner/templates/task_plan.md 的「## 🎯 核心目标达成裁决」区块结束后（`> 纯手段型任务…` 行后）、「## ⚠️ 执行范围限制」前插入 design §3 代码块完整内容（注释+表头+示例行）；git diff 该文件仅 + 行
- A2：worktree 内 skills/task-planner/scripts/check-plan-dispatch.sh 追加独立「Rule 66.5 Goal 单元表校验段」（挂点=S-unit 校验段之后、最终 exit 判定前）：
  - ① 区块存在性：awk 状态机抽「^## 🎯 Goal 单元表」区块（参照脚本既有状态机写法，禁区间 next 坍缩范式）；缺区块 → 输出含「Rule 66.5」提示行
  - ② 六列表头锚 grep：goal-id/任务名/目标/完整验证方式/对应 S-unit/状态 关键词各命中
  - ③ 数据行校验：goal-id 匹配 `^G[0-9]+$` 且序号连续；「完整验证方式」列非空且不含未填占位（尖括号 `<` 起头）与黑名单词「检查没问题」
  - ④ `--skip-goal-check` 逃生口（对齐脚本内既有 --skip-* 的 echo 登记实现方式）
  - ⑤ mini 档位：脚本内无现成 mini 判定逻辑时按保守口径=非 mini 声明缺区块仅 WARN 提示行不硬拒锁，并在此检查点披露
  - 既有 S-unit 校验段与 $3/$4/$5/$7/$8 解析位零改动
- A3：三态试跑输出原文入检查点：
  - 正样本 `bash 脚本 /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/task_plan.md`（含 G1-G6 六行 Goal 单元表且验证方式列全填）→ 66 段不报 FAIL
  - 负样本：mktemp 副本用 sed 删除「## 🎯 Goal 单元表」到下一 `^## ` 区块 → 报 66.5 缺失
  - 负样本 + `--skip-goal-check` → 跳过（输出含 skip 登记行）
- A4：新段头注释含 What+Why（Rule 45：校验什么 / Rule 66.5 出处 / mini 豁免 / 逃生口语义）

## 4. Scope 禁改
- 禁止修改：worktree 内 check-complete.sh、SKILL.md、selftest*、critical-rules.md、模板外其他文件
- 禁止操作：git add/commit/checkout/reset（只读 git diff/status 允许）；禁改既有 S-unit 校验段

## 5. 工作路径
- worktree：/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode；目标=其下 skills/task-planner/{templates/task_plan.md,scripts/check-plan-dispatch.sh}；不切 CWD

## 6. 时长预算
- 编辑+脚本类 → 超时 25 分钟；超时立即返回 partial 报告未完成部分

## 7. 返回格式（严格 8 字段，字段后无内容，备注入 blockers/checkpoint）
```
status: done | partial | failed
acceptance: <n>/4 pass — [A1:PASS A2:PASS A3:PASS A4:PASS]
files: <绝对路径>(+N/-M); ...
evidence: <file:line 或 命令→关键输出行>; 正/负/逃生三态各一行
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/04-executor-S2.md
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint
- 路径 /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/04-executor-S2.md：每完成一个文件追加里程碑行（带时间戳）；遇错写「错误与受阻」（现象+已尝试）；结束写「最终结论」段=同一 8 字段块并置 status

## 9. 上下文预算
- 只 Read 本节列出的路径与区段（模板行 85-110 区、check-plan-dispatch.sh 全文、design-draft §3/§4.1、critical-rules 行 848-860）；禁贴计划全文/大段源码
- 完成后 Read 修改的 2 文件确认落盘；files: 列绝对路径
