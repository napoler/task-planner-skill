# Task Learnings: task-v100-review-library

## New Requests
- 2026-09-30（D 类新任务,silent）:「补充10个通用的质量审核技能 用于后期没有覆盖时候进行兜底质量 提高质量」+B 类澄清「十个不同的质量审查skill 覆盖不同的场景 比如 代码审查 撰写审查 图片审查 等」→ review-library 10 技能兜底池（general/code/test/security/image/content/documentation/data/ui/release）+Rule 42.2 四级化,已交付（merge 9b17c05+CR P1 ecae12d 已 push）

## What Worked
- S1 范式锚定→S2-S4 对标产出: 10 技能结构/质量一致性高（CR 专项 1 全 PASS「领域互异,每条有动作+判定标准」）
- CR 隔离审查抓出主进程自查遗漏的 P1（枚举残留）——隔离视角价值实证;fix-phase→SendMessage 原 reviewer 复验闭环高效
- SR-12 动态口径根治: 硬编码行数改「=脚本数+表头」动态比较,永久消除每任务一次的级联断裂（v099/v100 两连断后根治）

## What Didn't Work
- **B 类澄清未回溯已产出工件**[规则缺位]: 用户「performance→image」澄清到达时 S1 已交付,general-review 枚举残留 performance 未回溯修正,被 CR P1 抓出。根因=B 类变更 SOP 只覆盖「未开工面」,无「已产出物回溯检查」步骤。预防=已沉淀 notepad 防线（见下）;建议未来 B 类变更条款化（Rule 20 B 类追回溯检查子步）
- **worktree 首建撞分支残留**[执行偏差]: 分支已建目录未建的部分失败态→worktree prune+branch -D 重建。预防=worktree add 失败先 prune+查 branch 再重试

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
-

## Files Modified
-

## Verification Results
- Verified: [specific change confirmed]
- Failed: [specific issue and resolution]

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口:

## Notes for Next Time
- 触发=B 类澄清/清单变更指令到达且部分 S-unit 已交付: 防线=变更落地前 grep 已产出物中的被替换词,命中即回溯修正（本任务 CR P1 教训）
- 触发=新任务向 registry 登记新 selftest: 防线=SR-12 已改动态口径（=脚本数+表头）,无需再改锚值;但新登记脚本名禁 selftest- 前缀 helper 化（CR P2-b 备忘）
- 触发=批量新建技能/模板类文件: 防线=先写 1 个范式标杆经主进程验审,再批量对标产出（S1→S4 范式锚定范式有效）
- 触发=worktree add 报 fatal: 防线=worktree prune+branch -D 残留分支后重建
