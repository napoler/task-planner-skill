---
id: draft-task-model-tier-dispatch-20261119
title: "（draft）task-model-tier-dispatch-20261119 知识蒸馏待精炼"
tags: [draft, 未精炼]
sources: [plans/archive/task-model-tier-dispatch-20261119/knowledge-brief.md, plans/archive/task-model-tier-dispatch-20261119/findings.md]
updated: 2026-11-19
---

# （draft）task-model-tier-dispatch-20261119 知识蒸馏（来源: plans/archive/task-model-tier-dispatch-20261119/knowledge-brief.md）

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| {示例：init-session.sh 建 5 文件} | scripts/init-session.sh:120 | 新增第 6 文件须同步 :120 复核列表与 :131 文案 |
| {台账供料源示例：Rule 53 已被 task-v131 占用} | plans/.rule-reservations.jsonl:10（台账锚）+ critical-rules.md:581（原文重验锚） | 新增条款走 21.2.1 子条款，禁新占 Rule 编号 |
| {事实} | {file:line} | {影响} |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
<!-- 设计插入点+范式锚（台账供料，Rule 21.2.1）：设计类 S-unit 行必含 ①目标文件插入点锚 ②最新范式块锚（来源=编号账本推最大 landed Rule → 文尾块行号）③时效戳（供料日期+快照来源）；锚区间会漂移且部署位在途写入，过期锚须重测不得盲用 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| {示例：scripts/init-session.sh} | :90-98 | 4 文件循环建立（findings/progress/notepad-learnings/verification） |
| {设计插入点示例：references/critical-rules.md} | :<起-止> | 最新范式块 ### <NN>（插入点=21.2 后；供料 <日期>，源=编号账本最大 landed 号；行号以实施日重验为准） |
| {路径} | :{行号} | {摘要} |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. {示例：禁止改 22.4a 三文件契约原文（KQ2 轻量方案裁定，KQ2 波及面=check-dispatch 7 处+selftest 5 组）}
2. {易错点/禁止假设}
3. {易错点/禁止假设}
- FMEA RPN>100 兜底指针：{→ task_plan.md FMEA 表「{Phase} {失败模式}」行}

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
<!-- 台账供料（Rule 21.2.1）：设计类 S-unit 行「额外材料路径」列直接填台账产物绝对路径（替代 prompt 内联），「应读本 brief 哪节」精确到 §2/§3 供料行 -->

<!-- 精炼指引: 合并去重 → 主题化 → 补证据锚行号 → 去除 draft 前缀改名后重跑 kb-rebuild-index.sh -->
