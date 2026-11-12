---
id: rule106-docmod-recheck-discipline
title: "Rule 106 文档修改复检与 todo 两组驱动对齐——落地锚点、判例与易错点"
tags: [rule106, verification, todo-sync, 判例, 纪元锚]
sources: [plans/task-docmod-recheck-20261112/knowledge-brief.md, plans/task-docmod-recheck-20261112/findings.md, skills/task-discipline/references/critical-rules-discipline.md]
updated: 2026-11-13
---

# Rule 106 文档修改复检与 todo 两组驱动对齐（task-docmod-recheck-20261112 落地）

> 判例源：sess_1378b365「G22-05a 三方时间口径不一致仍放行」（段标题 40-46s / 台词 41-45s+46-49s / 段末 46s 拆点互矛盾、自检字段仍写 PASS；本体两轮检索未命中=未验证，副本漂移与虚报两态兼容措辞）。
> 五子条：106.1 写后回读门 / 106.2 派生值先定基准 / 106.3 同文件二次修改全量回归 / 106.4 验证对象=交付物本体 / 106.5 两组原生 todo（基线组 B1-B5 门禁挂钩+任务组）。

## 已验证关键事实

| 事实 | 证据 file:line | 影响 |
|------|---------------------|-------------------------------|
| Rule 106 五子条已落 discipline 规则文件 | skills/task-discipline/references/critical-rules-discipline.md:721-734（merge 02d90e2） | 新会话生效；后续规则任务最大编号=106 |
| 106 编号已 land（reserved→landed） | plans/.rule-reservations.jsonl（2026-11-13 land 行） | 下一个新 Rule=107，须先 rule-reserve |
| master selftest 基线非全绿（2 预存 FAIL） | plans/task-docmod-recheck-20261112/findings.md §5+S5 检查点 06（active-plan T11/execution-stability T11b，双仓对照形态一致） | 后续任务基线对照勿把这 2 项归因自身；建议另立任务修 |
| EN-06 断言=纪元语义（随编号走） | skills/task-planner/scripts/selftest-enumerate-first.sh:92-99（翻转后 1-106/,106） | 下次 land 107 需再翻转该断言族 |
| S-unit 表机器列序=10 列（awk $4执行体/$5输入/$7时长/$8粒度） | skills/task-planner/scripts/check-plan-dispatch.sh:246-278 | 写计划禁加列/禁单元格管道转义（v150+本任务双判例） |
| attest vc-gate 判据=verification.md 行首 **Verify command**: 纯命令 | skills/task-planner/scripts/attest-plan.sh:244-285 | VC 命令禁占位/禁真空（test+命令引用产出物） |
| 部署三仓收口 | 源 9126c3c..bdbcfc2 / zcode c8b874d(main) / claude cf28dd5(master) 已 push；cursor 非 git 仓落盘 | 配置仓仍有其他会话在途未提交变更（非本任务 scope） |

## 关键文件锚点表

| 路径 | 行号 | 摘要 |
|------|------|---------------------------|
| skills/task-discipline/references/critical-rules-discipline.md | :721-734 | Rule 106 段（五子条+判例+Why；Rule 107 插入点=本段后） |
| skills/task-planner/SKILL.md | :105 | 3i 修改后复检步（Phase 执行循环过程期门指针） |
| skills/task-planner/SKILL.md | :152 | Rule 20.5 行尾豁免口径（写入确认型重读≠跨字段复检） |
| skills/task-planner/SKILL.md | :173 | 原生 Todo 同步段尾两组结构指针 |
| skills/task-planner/references/todo-sync.md | :29-46 | S1 两组结构契约块（B1-B5+生命周期+门禁挂钩+丢失重建+mini 豁免） |
| skills/verification-gate/references/critical-rules-verification.md | :56 | 84↔106 过程期/终验期互指行 |

## 易错点与禁止假设

1. **Edit 锚点纪律（本任务双犯判例）**：用既有整块做插入锚时 new_string 必须回填锚块原文——两次吞块（user-session-log「消费点」标题、findings 106.4 整段）均靠子代理自审/复检捕获；106.1 两次当场拦截=新条款有效性实证。
2. S-unit 表禁加「96 类别」独立列（列序漂移=整表错位）；类别用目标列内（An）前缀承载。
3. selftest 剩余 2 FAIL=master 既有，禁在无关任务射程内顺手修（Rule 87：报告+另立任务）。
4. G22-05a 文档本体未验证（两轮检索未命中）——禁把「副本漂移 vs 虚报」写成已定事实。
5. merge 遇他任务暂存变更阻断：stash push→merge→stash apply --index 原样恢复（含暂存态），禁 commit 他任务文件。