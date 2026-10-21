# 01-explore-existing — 现有召回/恢复/压缩机制盘点

task: task-v195-spec-recall | 只读侦察 | 2026-10-21

## §1 现有召回/恢复/压缩机制

### SKILL.md (skills/task-planner/SKILL.md, 267 行)
- :78 R 锚定复诵（v168）：开 Phase 时 Read「🎯 用户需求原文」+progress 写 R 锚定行
- :85 3e 上下文卫生（Rule 29）：每 2 Phase 跑 check-context-hygiene.sh
- :86 3f 周期性三文件对照（v168/R3）：每完成一个 S-unit（或每 10 次工具调用）Read task_plan Goal+Phase 与 progress 尾部对照；不符 Rule 65.4 标 [corrected]
- :100 [DRIFT CHECK] 派发 drift-checker，触发时机=Phase complete 后/连续≥3 次工具调用/切换模块前/用户新指令
- :127 恢复读序：task_plan→progress→findings→knowledge-brief（RAM/Disk 原则）
- :141 场景速查（Rule 20.5）：中断/压缩恢复→读全部三文件（Rule 19.3）

### task-discipline/references/critical-rules-discipline.md (588 行)
- Rule 29 (59-68) 上下文与工作文件主动维护：29.1 触发三档（Phase complete/会话恢复/用户显式，每 2 Phase 节流）；29.2 退场 SOP；29.3 压缩 SOP（compaction 前过检查器）；29.5 hook 未接读取
- Rule 33 (94-103) 解决→反思→验证迭代循环：33.1 触发四点；33.2 反思四问；33.3 独立验证
- Rule 65 (333-363) 周期性回顾与前后对照：65.1 每 N 次工具调用（默认 8, config periodic_review_interval_calls）触发回顾；65.2 重读 task_plan/findings/progress；65.4 [corrected] 反向纠正；65.5 periodic-review.sh
- Rule 67 (365-379) 上下文压力主动评估与会话交接：67.1 三档触发（节奏/事件/高危信号，含 compaction 后恢复点）；67.2 三态裁决 HEALTHY/PRESSURE/CONFUSED + [assess] 留痕；67.3 PRESSURE 主动压缩；67.4 CONFUSED 会话交接（session-handoff.md 五段）；67.5 hook 节奏承载（[context-pressure] 随 drift-rhythm 同发）

### task-drift-guard/references/critical-rules-drift.md (70 行)
- Rule 11 漂移检测（周期性）；Rule 15 高频漂移纠正（每 2-3 todo）；Rule 61 子代理化
- Rule 64 (51-67)：64.1 留痕三件套；64.2 Phase complete 第三条件门控；64.3 节奏化提醒每 N=10 次工具调用注入 [drift-rhythm]（状态 <plans>/.drift-rhythm/<sid>.state 三键 count/last_inject/due）；64.4 判定三锚

### task-drift-guard/SKILL.md (91 行)
- :17-23 触发条件 5 条；:90-91 双载体（drift-checker agent vs skill）

### scripts/periodic-review.sh (196 行)
- Rule 65 机器承载：检测 findings.md 与 progress.md 结论一致性（矛盾检测器），输出 JSON，exit 0/1/2。只读。

### drift-checker agent
- ~/.zcode/agents/drift-checker.md (36 行) 与 skills/task-planner/companion/agents/drift-checker.md
- SOP：读 task_plan（+findings/progress）→git 证据→三态判定→写检查点→返回单行 status
- 关键：读取发生在子代理隔离上下文，仅回一行结论（Rule 61 防上下文爆炸）；不矫正主进程上下文

## §2 规范摘要/速查/召回卡类文件
- 无 essentials/速查卡/召回卡 类文件。grep 命中"速查"均为路由速查表（plan-research-router/template-mapping/todo-sync §5），非召回卡
- 最接近：templates/knowledge-brief.md（任务知识简略要点，§1-§6）与 templates/session-handoff.md（五段交接）

## §3 近期并行计划重叠
- task-v193-skill-goal-drift-fix：goal 漂移+媒体产出门控，文本优先不新增 hook；主题不同
- task-v194-subagent-unit-cap：task_plan Goal 仍为模板占位（未填）；未启动
- s77-p2-fix：已 merge（git 42d72b4）
- skill-audit-s77-20261019：只读审查报告；skill-audit-s77-fix-20261019：已 merge
- 结论：无与本任务（规范摘要+周期召回）重叠的在途工作

## §4 模板现状
- templates/ 12 文件 + variant/ 子目录
- task_plan.md 555 行，区块见 grep 输出
- 候选挂载区块：## Current Phase(235)/## Next Step(242)/## Phases(265)/## 🔁 原生 Todo 同步（S1–S5 强制）(388)
