---
id: planflow-plan-lifecycle-gates
title: "计划生命周期与门控"
tags: [计划生命周期, 门控, 归档索引, 上下文压力, 罗盘分账]
sources:
  - plans/archive/task-v170-archive-completed-plans/knowledge-brief.md
  - plans/archive/task-v170-archive-completed-plans/findings.md
  - plans/archive/task-v069-context-hygiene/knowledge-brief.md
  - plans/archive/task-v152-proactive-context/knowledge-brief.md
  - plans/archive/task-v156-drift-shield/findings.md
  - plans/archive/task-v166-summary-readability/findings.md
  - plans/archive/task-plan-resume-v05/findings.md
updated: 2026-10-22
---

# 计划生命周期与门控

## 结论（可直接复用）

1. **四文件罗盘各归其位，RAM 易失 / Disk 持久。** task_plan=目标维、findings=决策维、progress=进度维、notepad=学习维、knowledge-brief=知识维；会话上下文窗口是 RAM（易失），计划目录是 Disk（持久），发现/决策必须落盘而非留在会话记忆。【源：task-v166-summary-readability / task-v156-drift-shield】
2. **废弃内容只入 deprecated.md，不进四文件正文。** 四文件罗盘（task_plan/findings/progress/notepad）正文禁止混放被否决/被推翻/旧版内容；唯一存放点=计划目录 `deprecated.md`，登记五要素=原内容指针+废弃类型+废弃原因+日期+替代锚，规则=只入不出（禁删改既有条目）；改动前提方案/写条款/改文件前必查 deprecated.md + notepad 双源。【源：task-v156-drift-shield】
3. **终验链固定 10 步，3-File Gate 是硬节点。** 顺序=Read verification.md → 逐条复验 VC → 委派率统计 → 3-File Gate → 质量门控 → 合并回+git 提交核验 → 编号账本 → 交付结论 → delivery-summary → 退出前 check-complete.sh；check-complete 常见唯一 exit 1 源=「3-File Gate：findings 待回填」，归档 fixture 亦要求 findings/progress 各 ≥3 实质行才过门。【源：task-v170-archive-completed-plans / task-v074-template-matrix-reflect-loop】
4. **Phase 翻转必须三文件同源。** drift-check 判 DRIFT 的典型形态=task_plan 仍 in_progress / S-unit 未勾 / Next Step 陈旧，而 progress/findings 已推进；修复动作=三文件同步翻 Phase + Current Phase + Next Step + Drift Log 登记。交付 chore 未翻自己 Status 字面量会造成 INDEX 误挂账（已复发第 2 次）。【源：task-v170-archive-completed-plans / task-v074-template-matrix-reflect-loop】
5. **归档守卫三拒绝，一律 fail-closed。** 拒归档三类=① active 指针（全局 + side）② .session-owner 在场 ③ Status≠complete（含无 Status 行的异常目录）；已在 archive 幂等放行（ALREADY_ARCHIVED exit 0）。owner 文件无 TTL，故只按新鲜度拦（<24h，与 side 指针同惯例），历史残留 owner 不永久拦截。【源：task-v170-archive-completed-plans】
6. **索引一致性靠重跑，不靠手改。** 归档后必须重跑 `sync-todos.sh --index`（全量重写特性）；`forward_sync` 用 `find` 无深度限制会扫进 `archive/<id>/task_plan.md` → 需加 `-not -path "*/archive/*"`；`write_index` 用 `-maxdepth 2` 天然不扫 archive。最小修复面=set-active-plan.sh（复核）/ sync-todos.sh forward_sync（真修）/ resolve-plan-dir.sh（只匹配直接子目录，安全无需改）。【源：task-v069-context-hygiene / task-v170-archive-completed-plans】
7. **会话恢复先证伪、再按顺序读。** 恢复前先用 git refs/reflog 逐行比对证伪「某版本已存在」类记忆（实测 v0.5 从未存在）；扫描顺序三处历史不一致（SKILL.md/critical-rules.md/CHANGELOG 各说一次在 DRIFT CHECK 前/后），须以 critical-rules 条文为准统一；plan-resume 默认 dry-run 只产报告不替用户 resume/archive，须用户明确说「续推 task-X」才动。【源：task-plan-resume-v05】
8. **上下文压力三态 + 交接兜底。** HEALTHY（继续）/ PRESSURE（主动压缩整理）/ CONFUSED（写会话交接文档转新会话）；会话级交接文档机制与模板全仓零命中=纯新增面；hook 接线只动技能侧脚本，不改 config.json；新增开关一律 env 降档（零新 config 键，properties=42 被多脚本钉死）。【源：task-v152-proactive-context】
9. **新增门控统一三档 + 档位豁免。** 档位解析顺序 env > config > warn；warn 提示不阻断、enforce 才 exit 1、off 跳过；门控外再套 plan_tier 档位门（mini 档豁免，无 plan_tier 标记视为 legacy 跳过）；计数变量须做非数字归零（`grep -c` 零匹配返回 "0" 且 exit 1，命令替换内 `|| echo 0` 会拼成 "0\n0" 使 `[ -eq 0 ]` 恒假 → 门控对目标失败面静默失效）。【源：task-v156-drift-shield / task-v074-template-matrix-reflect-loop】

## 证据锚

- 四文件罗盘分账与废弃隔离：plans/archive/task-v166-summary-readability/findings.md:3；plans/archive/task-v156-drift-shield/findings.md:50-56
- 终验链 10 步 + 3-File Gate：plans/archive/task-v170-archive-completed-plans/knowledge-brief.md:33；plans/archive/task-v170-archive-completed-plans/findings.md:22；plans/archive/task-v074-template-matrix-reflect-loop/findings.md:41
- Phase 翻转三文件同源：plans/archive/task-v170-archive-completed-plans/findings.md:82；plans/archive/task-v074-template-matrix-reflect-loop/findings.md:90
- 归档三拒绝 + owner 新鲜度：plans/archive/task-v170-archive-completed-plans/findings.md:58,70
- 索引重跑与 archive 扫描面：plans/archive/task-v069-context-hygiene/knowledge-brief.md:44；plans/archive/task-v170-archive-completed-plans/findings.md:47-49
- 会话恢复读序与 dry-run 契约：plans/archive/task-plan-resume-v05/findings.md:109-112
- 上下文压力三态 + 零新键：plans/archive/task-v152-proactive-context/knowledge-brief.md:16,29,32,34
- 门控三档 + 计数缺陷：plans/archive/task-v156-drift-shield/findings.md:63-64,66-68,85,116

## 易错点

1. 把 plans/ 数据面（INDEX 重生 / 批量 mv）放进 worktree 合并：主仓 plans/INDEX.md 常有并行会话未提交变更，会撞车——机制进 worktree，数据面留到合并回后主仓执行。【源：task-v170-archive-completed-plans】
2. 归档在途计划：v168/v169 等「Status=complete 但 .session-owner 在场 / 指针指向」的在途目录必须被守卫拦下，试点只能选确定 complete 且无 owner 的目录。【源：task-v170-archive-completed-plans】
3. 批量归档必须 dry-run → 试点 → 实做，且 dry-run 清单要与实做后 INDEX 对账；实做前先跑 double 采样预检。【源：task-v170-archive-completed-plans】
4. attest-plan.sh 不带显式 plan 路径参数时，会经 env sid 解析链误锁并行会话的其他计划（实证 v159 被误重锁）——attest 恒带显式路径。【源：task-v156-drift-shield】
5. 派发/写入被 check-dispatch 拦截时，先查是否缺字面 token（findings.md / progress.md / acceptance: / checkpoint:）；失败派发泄锁 TTL 120s，禁手删锁。【源：task-v081-fine-grain-step-gate】
6. 守卫判「complete」时把异常当 complete：无 Status 行的目录一律拒（fail-closed），不按 complete 处理。【源：task-v170-archive-completed-plans】

## 适用场景

- 新建/接手一个 task-planner 计划，需要确定文件分工与落盘口径时。
- 计划被 drift-check 判 DRIFT、或三文件进度不一致需要修簿记时。
- plans/ 根目录堆积需要批量归档、或需要设计归档守卫与索引一致性时。
- 会话上下文变长/变乱、准备压缩整理或写交接文档转新会话时。
- 新增任何机械门控脚本，需要三档 + 档位豁免 + 计数鲁棒性的现成范式时。
