# 8-alignment-b 检查点（[sub:9] 对齐审查·模板/日志面）

status: CHANGES_REQUESTED

## 审查范围（只读）
worktree = /mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first
- skills/task-planner/templates/subagent_dispatch.md:27（检索优先契约行）vs findings.md §「subagent_dispatch.md §2 检索契约行」锚（:74）
- CHANGELOG.md:12（Rule 63 条目）/ :13（Rule 64 条目）vs skills/task-planner/references/critical-rules.md:769-783（Rule 63）/ :786-800（Rule 64）原文
- skills/task-planner/scripts/selftest-registry.tsv:62-63（尾两行）

## 证据（机器可复现）
1. dispatch 契约行逐字 = findings 锚：`sed -n '27p' subagent_dispatch.md` 与 `sed -n '74p' findings.md` 一致；插入点=knowledge-brief 行（:26）后，与计划 S3 锚一致。
2. CHANGELOG Rule 63 条目逐字 = findings:69 锚：`sed -n '12p' CHANGELOG.md | md5sum` = `sed -n '69p' findings.md | md5sum` = 17049216789046ec7033887ec47f0530。
3. CHANGELOG Rule 63 条目术语逐项对齐 63.1 目标公理 / 63.2 四步检索链（本地→帮助面→官方文档/网络→社区）/ 63.3 反推诿禁令 / 63.4 有理有据边界（58.5 三态 not-solved）。
4. CHANGELOG Rule 64 条目术语对齐 Rule 64 原文（标题/64.1-64.6/判例「25 Phase 执行率 0%」）。
5. registry:62（research-first）「RF-01..12」= `grep -oE 'RF-[0-9]+' selftest-research-first.sh | sort -u | wc -l` = 12 ✓；dep_anchors 5 条全存在 ✓。
6. registry:63（drift-enforcement）「静态 DCE-01~10 + 行为 DCE-11~16」≠ 实态：`grep -oE 'DCE-[0-9]+' selftest-drift-enforcement.sh | sort -u | wc -l` = 23（DCE-01..23），且 ≠ 条款原文 critical-rules.md:798「DCE-01~23」。同源 stale 文案亦在脚本头注 selftest-drift-enforcement.sh:2。
7. 参考（超范围）：registry:55（EG 行）「EG-01..20」≠ 实际 EG 标签 21（同型 range 漂移先例）。

## 发现项
- [P1] skills/task-planner/scripts/selftest-registry.tsv:63 — DCE 区间描述（16）与实态（23）及 Rule 64.5 原文（DCE-01~23）不符 — 改「DCE-11~23」并同步脚本头注 :2。
- [P2] CHANGELOG.md:12 — Rule 63 条目记 v147 中间态（FF-16 ^63\.→^64\.、SKILL 1-62→1-63），worktree 净态为 ^65\. / 1-64；:13 Rule 64 条目未记二次级联 — 在 Rule 64 条目补记或改净态。
- [P2] SKILL.md:214 + subagent_dispatch.md:27 「Rule 26 Q3」 vs critical-rules.md:779 原文「Rule 26.3 Q3」（Rule 28.2 有「Rule 26 Q3」先例）— 建议统一/低优先。

## 结论
v147 模板/日志面三产物（dispatch 契约行 / CHANGELOG Rule 63 条目 / registry research-first 行）逐字保真通过；唯一 P1 = v148 drift-enforcement 登记行描述漂移，建议合并前修。
