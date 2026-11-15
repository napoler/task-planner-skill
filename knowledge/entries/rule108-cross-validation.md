---
id: rule108-cross-validation
title: "Rule 108 交叉验证纪律——隔离上下文双视角识别执行错误与虚构（落地锚+实弹判例）"
tags: [verification, rule-108, cross-validation, anti-fabrication, task-crossvalidate-20261115]
sources: [skills/verification-gate/references/critical-rules-verification.md, plans/archive/task-crossvalidate-20261115/cross-validation-report.md, plans/archive/task-crossvalidate-20261115/findings.md]
updated: 2026-11-15
---

# Rule 108 交叉验证纪律（2026-11-15 task-crossvalidate-20261115 land）

## §2 已验证关键事实

| 事实 | 证据 file:line | 影响 |
|------|---------------|------|
| Rule 108 五子条全文落 verification-gate 卫星规则文 | skills/verification-gate/references/critical-rules-verification.md:60-70（108.1:62/108.2:64/108.3:66/108.4:68/108.5:70） | 验证域新增交叉比对与分歧处置总框架，与 84.4/84.7/103 互补不复写 |
| 触发面=①终验含 L2+ 完成声称 ②≥2 受管文件终验 ③子代理验证产出采信前 ④用户要求；mini/L0 豁免 | critical-rules-verification.md:62（108.1） | 终验与子代理产出采信前强制双路径交叉；mini/L0 免仪式 |
| 机器守护 CV-01..06（块锚+段局部化断言，负向实测过） | skills/task-planner/scripts/selftest-cross-validation.sh:16-50 | 删锚/删接线→FAIL，断言非真空防 test-gaming |
| 模板承载「交叉验证记录」步骤区块 | skills/task-planner/templates/verification.md:131 | 每个验证计划默认携带双路径记录字段 |
| 级联口径=其余 91 条（非 94） | skills/task-planner/SKILL.md:9/:237+critical-rules.md:141（77/78/79 预留未落地） | 纪元演进计数=落地规则数−预留未落地−核心 14，禁按编号上界直减 |

## §3 关键文件锚点表

| 路径 | 行号 | 摘要 |
|------|------|------|
| skills/verification-gate/references/critical-rules-verification.md | :60-70 | ### 108 块（五子条+判例锚 fabricated-output-20261103） |
| skills/verification-gate/SKILL.md | :3/:32 | description 触发词+调用时机第 7 条（交叉验证触发） |
| skills/task-planner/SKILL.md | :9/:233（路由行 84,108）/:237 | 1-108 纪元+91 条口径+卫星枚举句 |
| skills/task-planner/templates/verification.md | :131 | ## 交叉验证记录（Rule 108）区块 |
| scripts/selftest-cross-validation.sh | :16-50 | CV-01..06 断言（块锚+sed 段局部化） |

## §4 易错点与禁止假设清单

1. **级联计数禁直减**：108−14=94 是错的——77/78/79 预留未落地须扣除（判例=本次主进程转译稿 94 被 critic 双路径拦下，108.4 处置闭环；先例=archive/task-serial-sync 1-107→90）
2. **EN-06 纪元耦合**：selftest-enumerate-first.sh 断言 SKILL.md '1-108'≥3+discipline ',107'——Rule 落非 discipline 卫星时 ',107' 断言不动，勿顺手改（草案曾误改，侦察 F3 纠偏）
3. **验证命令路径须实测**：verification.md V-3.2 曾写预想 checkpoint 路径（p3s2-critic-checkpoint.md）实际落盘 8-critic-r2.md——验证命令引用真实产出物路径以盘上实测为准（108.2 自反适用）
4. **并行会话归档暂存态挡合并**：staged deletions 使 pathspec stash 失配（index 无路径）——消解链=核 archive/ 副本在位后代为落账删除半程（判例=initdelegation/specmode 0545712）
5. **合并回 live race**：master 被并行推进→V5 MASTER_AHEAD 循环（本轮 3 次）——每次 worktree merge master 后重跑 smart-merge-back；「Already up to date」不代表终态，对账 merge-base 而非 log
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表 Phase 2 插段吞锚行（106.1a 三规约）/Phase 3 分账误判行（基线先跑）/Phase 4 合并冲突行（三自检+STOP 呈报）