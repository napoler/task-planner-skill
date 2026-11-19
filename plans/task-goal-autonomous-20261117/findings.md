# Findings — task-goal-autonomous-20261117

## Root Cause
- 判例 sess_3cb0a759-b755-41e1-b81f-7b9b1242215d：`/goal` 目标迭代自动推进，但反复呈示“请回复授权/确认执行”类选择/确认且未获答复仍续推，导致每轮都问的死循环。
- 机制缺口：Rule 28/44/66 未对 goal 语境规定“强制自治、同问禁复发、不可越权时单次降级收口停止迭代”；resolver 无 goal 语境强制 silent 入口。

## Fix
- 新增 Rule 28.8（discipline）：goal 语境交互等效 silent；可裁决选择按推荐项静默自治留痕；同问禁复发；不可越权硬门仅单次阻塞降级收口并停止该目标迭代（禁空转重问）。
- 44.3/44.5 续行补充 goal 收紧；66.2 补充 goal 迭代自治；SKILL.md Rule 28 行显式提示；resolve-interaction-mode.sh 增加 `TASK_PLANNER_GOAL_MODE`(goal/1/true)→silent（不改既有优先级/config 键）。
