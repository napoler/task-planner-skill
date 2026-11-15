---
id: anchor-discipline-plan-history-recall
title: "锚纪律与子代理产锚幻觉治理（plan-history-recall dogfood 判例）"
tags: [kb, anchor-discipline, plan-history-recall, subagent-fabrication, vc6-vacuous-gate]
sources: [plans/task-history-recall-20261116/design.md, plans/task-history-recall-20261116/findings.md, plans/task-history-recall-20261116/progress.md, skills/plan-history-recall/SKILL.md]
updated: 2026-11-16
---

# 锚纪律与子代理产锚幻觉治理（task-history-recall-20261116 dogfood 判例）

## 判例链
- 子代理产锚幻觉 8/13 锚越界（specmode findings 实 73 行引 :114-121 等）；critic 独立解析器复现；主进程「4 锚抽查」以偏概全作过强声称（已撤回）
- 门命令恒真反例：VC-6 tail -1 取 Failed 行+两侧空串相等即过+基线跨树缺失 → 三条失效路径全封堵（grep ^Total:+双侧非空守卫+baseline 入 worktree），真实执行点双向实测（worktree VC6_PASS A=FAIL=5 B=FAIL=5；主仓 pre-merge fail-closed）
- 长中文表格+路径混排单次生成字符污染 6+ 处 → 分段写入+每段乱码扫描

## 治理条款
1. 子代理产锚必须机器重取（grep -n 实取+行号 ≤ wc -l+多点锚逐 token）；机械门只保「存在+越界+多点」，内容对位=人工/独立抽查面（critic 抽查=该面执行者）
2. 门命令写完先自跑正例+负例（恒真/恒假审查），在真实执行点双向实测
3. 长中文产物分段写入，每段乱码扫描；损坏须重写
4. HPR-09 三态语义：机械层门（缺产物树 WARN 跳过，仅含产物树实检）

## 回链
- 技能=skills/plan-history-recall/；dogfood 产物=plans/task-history-recall-20261116/history-recall/
- 判例同构 [[subagent-verifier-fabricated-output-20261103]]（记忆域）
