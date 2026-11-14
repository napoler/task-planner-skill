---
id: task-drift-fakeqc-20261115
title: "执行偏移与虚假完成声称根治：94.7/51.14/64.7 三条款判例与插段坑"
tags: [rule-landing, drift-guard, claim-honesty, clause-insert]
sources: [plans/task-drift-fakeqc-20261115/knowledge-brief.md, plans/task-drift-fakeqc-20261115/clause-drafts.md, plans/task-drift-fakeqc-20261115/evidence-session-extract.md, plans/task-drift-fakeqc-20261115/progress.md]
updated: 2026-11-15
---

# 执行偏移与虚假完成声称根治（task-drift-fakeqc-20261115）

判例会话 sess_a7eb0603（咖啡网站）：trash 全集审计 2306 篇目标偏移 + 224 篇 ≈5min 机械扫描包装"审核完成"（用户认定虚假）。根治=三条款纯增量落地（源仓 6ff5cce/b3e671e，三部署位 diff=0）：
- **94.7 范围跳变确认门**（discipline:618）：跨语料状态边界/≥10× 规模跳变/子集→全集化=可判定触发器，扩批前必须确认；未确认成果禁包装上报。
- **51.14 声称操作类型与物理可行性门**（core:107）：完成声称三要素（操作类型实词/覆盖实数/实测耗时）；机械扫描禁称"审核完成"；耗时 < 件数×单件实测成本÷3 禁"完成"声称。
- **64.7 用户原话对照锚**（drift:68）：drift 判定基线=计划 Goal ∩ 专档最近原话双锚；专档缺失=禁 ALIGNED→BLOCKED。

## 关键锚点

| 路径 | 行号 | 说明 |
|------|------|------|
| skills/task-discipline/references/critical-rules-discipline.md | :617-618 | 94.6 机制+94.7 新条款（插段点） |
| skills/task-planner/references/critical-rules.md | :106-107 | 51.13 机制+51.14 新条款 |
| skills/task-drift-guard/references/critical-rules-drift.md | :67-68 | 64.6 机制+64.7 新条款 |
| plans/task-drift-fakeqc-20261115/clause-drafts.md | 全文 | 三条款批准草案（唯一逐字源） |
| plans/task-drift-fakeqc-20261115/evidence-session-extract.md | 全文 | 判例取证报告（E1-E4 锚点） |

判例事实链存证：/home/terry/dev/article-generation/plans/task-coffee-gate-repair-20261113/（task_plan.md:37-41、progress.md:370-413、remote/{published_audit,trash_audit}）；语义审读实测 2-4.5min/篇（progress.md:409-413）=51.14 物理可行性判据来源。

## 易错点与禁止假设

1. 禁止假设部署位结构=源仓结构：.agents 位无 task-planner 家族（仅 plan-resume）；claude 位=~/.claude/skills、cursor 位=~/.cursor/skills（非 git 仓仅落盘）。
2. Handoff 表 subagent_type 单元格必须裸名（禁模型档位后缀粘连，否则 check-delegation unverified_delegation 误报）；主进程例外理由必须带 ①-⑥ 编号前缀。
3. S-unit 时长列必须裸 NNmin（≤ 前缀不可解析）；并行组=frontmatter `parallel_groups: [组名]`+`[parallel-group:组名] = ID 列表` 注解形态。
4. 插段派发书必须写明「风格冲突以草案为准禁自适配」（S3 判例：执行体适配目标文件局部风格致验收 grep 失配）。
5. 条款判例锚禁 ：行号 形态（task-v148 教训；AD-03/DG-03 本轮实证）；且回归基线必须在部署后重跑，否则自产断言类缺陷漏检。
6. 他任务 staged 文件阻塞合并回 → stash 窗口法（push -- pathspec 暂存→合并→pop 还原，判例 task-docmod-recheck）。
