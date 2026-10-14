# Session Handoff — <task-id>（会话交接文档）
<!--
  WHAT: 当前会话无法继续时的结构化交接产物（Rule 67.4 CONFUSED 触发）。
  WHY: 会话上下文易失（RAM），本文件=持久断点快照（Disk）——新会话凭它免重做、免重复失败。
  WHEN: 写入 <plan-dir>/session-handoff.md；新会话第一动作=Read 本文件。
  旧会话职责: 写完+登记（Decisions Made + progress [handoff] 行）+呈报路径；深水执行停止。
-->

## 1. 目标锚（Goal）
- task_plan 绝对路径: <abs>/task_plan.md（sha256 或最后锁定时间）
- Goal 一句话: <照抄 task_plan Goal 段>
- 需求原文指针: task_plan.md「🎯 用户需求原文」R1..Rn（禁转述替代）

## 2. 已完成与证据
| Phase/S-unit | 状态 | 验收证据锚（file:line / 命令输出） |
|---|---|---|
| <逐行> | complete/partial | <三证据> |

## 3. 当前断点（新会话从这里继续）
- 断点一句话: <卡在哪>
- 最后一次失败现场: <错误关键行原文 + 尝试次数>
- 相关检查点: <subagent-state/ 绝对路径>
- 已排除路径: <22.3 试过什么+为何不行（防重复失败）>

## 4. 未决问题
- <问题 + 候选方案 + 推荐项>
- 禁令核对: notepad-learnings.md「🚫 被否决方案」段（Rule 32.2，提方案前必查）

## 5. 新会话恢复指令（逐条照做）
1. `cd <repo> && bun ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/session-catchup.ts`（中断点检测）
2. 按四文件读序恢复（Rule 62.1，绝对路径）：
   Read <abs>/task_plan.md → <abs>/progress.md → <abs>/findings.md → <abs>/knowledge-brief.md
3. `Skill("plan-resume")` 自主续推 Top 1（Rule 24.5；config autonomous_resume=true）
4. 从 §3「当前断点」继续；**禁止重复 §2 已完成步骤**（防重做）
5. 恢复后首动作: 运行 `bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-context-hygiene.sh <plan-dir>` 确认上下文基线
---
交接登记（写回）: task_plan.md Decisions Made 加一行 `session-handoff: <路径>+<触发原因>, <时间>`；
progress.md 加 `[handoff]` 行；新会话恢复后在该行尾追加 `→ resumed by <新会话>`。
