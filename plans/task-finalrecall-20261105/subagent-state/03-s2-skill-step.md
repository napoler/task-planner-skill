# 03-s2-skill-step — SKILL.md 终验交付插入 Rule 84.14 全文档收尾回读梳理

## 状态
completed

## 目标
在 `skills/task-planner/SKILL.md` 的「终验交付 — 智能子动作」段中，于「按卫星 `verification-gate` 终验 SOP 执行（Rule 84.5 Step 3）」行之后、「交付结论 COMPLETE/PARTIAL/BLOCKED」行之前插入 Rule 84.14「全文档收尾回读梳理（P0 迭代门）」步骤（逐字按任务要求）。

## 执行记录
- 定位锚点：`grep -n '终验交付 — 智能子动作|84.5 Step 3|交付结论 COMPLETE'` 命中 L123/L124/L128（worktree 文件）。
- Read L123-134 确认上下文与插入点（84.5 Step 3 行后接双轮质检 L126，需插入在 L124 与 L126 之间，且位于「交付结论 COMPLETE」L129 之前）。
- Edit 纯插入一行（old_string = `84.5 Step 3` 行 + 下一行「双轮质检」前缀；new_string 在两者间插入目标行）。终验链其余步骤与全部其他区块未改。

## 验收自证
1. `grep -n "全文档收尾回读梳理" /mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105/skills/task-planner/SKILL.md`
   - 命中 1 行：`125:  - **全文档收尾回读梳理（Rule 84.14，P0 迭代门）**：...`
2. `grep -n "84.14" /mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105/skills/task-planner/SKILL.md`
   - 命中 1 行：`125:  - **全文档收尾回读梳理（Rule 84.14，P0 迭代门）**：...`（>=1）
3. 插入位置核查（`sed -n '123,129p'`）：
   - L123: `- [ ] [A] **终验交付 — 智能子动作**：...`
   - L124: `  - **按卫星 \`verification-gate\` 终验 SOP 执行（Rule 84.5 Step 3）**：...`
   - L125: `  - **全文档收尾回读梳理（Rule 84.14，P0 迭代门）**：...`（新增）
   - L126: `  - **双轮质检与同步完整性终验衔接（Rule 103）**：...`
   - L127: `  - **质量门控统计（Rule 26）**：...`
   - L128: `  - **委派率统计（Rule 25，细则→task-dispatch）**：...`
   - L129: `  - 交付结论 COMPLETE/PARTIAL/BLOCKED；...`
   => 新行位于「84.5 Step 3」(L124) 之后、且在「交付结论 COMPLETE」(L129) 之前，符合要求。
4. `git -C /mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105 diff --stat -- skills/task-planner/SKILL.md`
   - ` skills/task-planner/SKILL.md | 1 +` / `1 file changed, 1 insertion(+)`（仅此文件）

## 修改文件清单
- `/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105/skills/task-planner/SKILL.md` (+1/-0)

## 未完成面/风险
- 无。本 S2 为纯插入且已通过全部 4 项自证；终验链其余步骤与禁改区块未触碰。
- 备注：84.14 规则正文需在 `verification-gate` 卫星侧落地（S1 范畴）以与本步骤引用对齐；本单元仅负责 SKILL.md 步骤插入。

## 下次动作建议
- 进入 S3/S4 等后续单元（按计划依赖）；合并前可统一跑 selftest/grep 复核 Rule 84.14 在 SKILL + 卫星两侧均在位。
