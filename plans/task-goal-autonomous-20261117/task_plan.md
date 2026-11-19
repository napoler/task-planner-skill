# task-goal-autonomous-20261117: goal/目标迭代模式下选择冲突与询问死循环修复

## 元信息
- plan_tier: mini
- execution_lane: L0-T
- interaction_mode: `ask`（本任务由用户明确指令“修复”启动）
- Status: in_progress

## 🎯 目标
修复 goal/目标迭代模式中“需要用户选择”与自动推进冲突导致的重复询问死循环：在 goal/目标迭代语境下强制静默自治决策（选项取推荐/最优项并留痕），禁止同一未决点跨迭代重复询问；不可自治的硬门单次阻塞并降级收口，不空转。

## 需求锚（用户原话要点）
- /goal 目标迭代模式下出现需用户选择时与自动推进冲突，导致拿不到选择却反复迭代、每轮都提示需要用户选择，形成死循环。
- 正确做法：检测到目标模式激活时所有选择静默由模型自主决策，尽量减少询问用户。
- 判例会话：sess_3cb0a759-b755-41e1-b81f-7b9b1242215d。

## 执行范围
- `skills/task-discipline/references/critical-rules-discipline.md` (Rule 28/44/95 邻接，文本条款)
- `skills/task-planner/references/critical-rules.md` (Rule 66 邻接，文本条款)
- `skills/task-planner/SKILL.md` (交互/goal 行为说明对齐)
- `skills/task-planner/scripts/resolve-interaction-mode.sh` (goal-mode 信号→silent 可选增强)
- 必要自测/锚点对齐（仅既有测试预期因文本锚调整需同步时）

## VC
- [ ] VC1: goal/目标迭代语境下选择点自治且禁重复询问的规则条款在位（28/44/66/95 相关）。
- [ ] VC2: SKILL.md 与 resolve-interaction-mode.sh 行为与规则一致且不破坏既有语义。
- [ ] VC3: 相关自测通过（selftest-interaction.sh, selftest-ask-default-timeout.sh, selftest-goal-unit-goal-mode.sh）。

## Phase
- [x] P1 诊断与定位（已完成，基于 sess_3cb0a759 实证）
- [ ] P2 规则/脚本/SKILL 修复
- [ ] P3 验证与交付说明
