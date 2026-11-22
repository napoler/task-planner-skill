# Task Plan: 弃旧开新（restart-from-baseline）机制固化
plan_tier: mini
<!-- L0-lite stub（Rule 38.7/轻量豁免）：制度层纯文本条款固化，4 落点，零脚本；派发契约载体 -->

## 🎯 用户需求原文
长链任务改到一定时限、确认方向根本错误后，主动放弃错误路线——从当前混乱状态提取有效数据、用 Git 从干净基线牵出新版本、创建新计划从头做，抛弃错误历史负担。延续 git-rework-guard 思路，作为其补充出口。

## Goal
在 task-planner 技能固化 §4.6 弃旧开新机制（触发三级门/有效数据白名单/从基线牵新版本命令序列/旧线冻结登记/反模式）+ SKILL 4.5 交叉锚 + 双模板锚，纯文本零脚本。

## 隔离决策
- worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-restart-baseline-20261122`（分支 `wt/task-restart-baseline-20261122`，基线 master）
- 主仓 24 未提交变更全在 plans/.zcode 会话态（hook 写入），与落点 skills/ 零重叠 → 跳过 ①-备份（stash 会破坏 hook 活跃指针），登记理由
- 信号②/③ 遗留 wt/tplsys-upgrade-20261117 属他任务，不触碰

## scope files（worktree 内）
1. `skills/task-planner/references/worktree-isolation.md` — 新增 §4.6（主落点）
2. `skills/task-planner/SKILL.md` — 步骤 4.5 交叉锚
3. `skills/task-planner/templates/task_plan.md` — Git checkpoint 条目追加
4. `skills/task-planner/templates/progress.md` — Git checkpoint 行追加 [restart] 留痕位

## Decisions Made
- 触发授权=阈值命中→评估→用户 yes（未答澄清项按推荐自决，不可逆守 §五）
- 旧计划 outcome=RESTARTED（非 CANCELLED/SUPERSEDED）+链接新计划；错误分支留档不物理删除
- 定位=git-rework-guard 补充出口 §4.6，非独立新机制

## Verification Contract
- VC-1: §4.6 五要素齐（核心原则/触发三级门/有效数据白名单/牵新版本序列/旧线冻结登记/反模式）
- VC-2: 三处交叉锚在位（SKILL 4.5 / task_plan.md / progress.md）
- VC-3: 全量 selftest fresh FAIL 集与基线 96/8 同集零新增
- VC-4: init 渲染冒烟新条目进派生 MD + 四部署位 diff=0
- VC-5: worktree status 干净→合并 master→清理→记忆落盘
