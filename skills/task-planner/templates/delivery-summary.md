<!-- delivery-summary.md — 任务交付总结五要素模板（SKILL 终验交付段配套，用户面） -->
<!-- 使用方式: 终验结论（COMPLETE/PARTIAL/BLOCKED）判定后、会话退出前，按本模板向用户输出交付总结；
     需要跨会话存证/独立子代理验收（VC 类条款要求落盘）时，同步落 plans/<task-id>/delivery-summary.md -->
<!-- 定位: 用户面总结 = 引用机器面档案而非重写——数据源指针: verification.md（VC/委派/门控/Goal Gate）、
     progress.md（每 Phase Files created-modified/Error Log）、subagent-state/（独立验证 checkpoint）、
     report.md / memory-hygiene-report.md（如有）；本模板不复述证据原文，只写指针+一句话结论 -->
<!-- 详略标准: 以「用户可独立决策」为准——用户读完不查三文件即可回答: 产出物在哪/哪些可信/风险是什么/我下一步做什么 -->
<!-- 头部形态: HTML 注释指引区（同 batch_report.md/knowledge-brief.md 根模板惯例），无 <!-- template_type: -->
     （非计划模板，不进 check-template-type 白名单，不入 25 模板口径） -->

# Delivery Summary — {task-id}（任务交付总结）

## 1. 任务说明
- **Goal 回顾**: [一行，引 task_plan.md Goal 原文]
- **执行过程摘要**: [Phase 序列 + 各 Phase 执行体（子代理/主进程）+ 关键裁决点（含 silent 自动裁决清单，
  Decisions Made 表 `silent:` 前缀行逐项列出），3-6 行；数据源 = progress.md Phase 段 + task_plan.md Decisions Made]
- **交付结论**: COMPLETE / PARTIAL / BLOCKED [引 verification.md Goal Gate outcome]

## 2. 产出清单（文件级）
| 文件（绝对/仓内路径） | 变更摘要（新增/修改/删除 + 一句话） | 验证状态 |
|----------------------|-----------------------------------|----------|
| ... | ... | VC-N PASS / N selftest rc=0 / grep 锚实测 / Read 复验 |

[数据源 = progress.md 每 Phase「Files created/modified」+ verification.md VC Evidence 逐条指针；
 合并类任务附 merge commit hash（如 5a30382）]

## 3. 审查信息（尽量详细）
- **VC 复验**: N/N 条 PASS（指针: verification.md Goal Gate 段）
- **回归**: <N> 个 selftest / SUM-ASSERTIONS=<数值>（独立子代理 sub:<k>，checkpoint: subagent-state/<k>-<agent>.md）
- **对齐审查**: verdict（APPROVED / CHANGES_REQUESTED + 处置项清单）（指针: checkpoint sub:<k>）
- **委派统计**: check-delegation.sh stats JSON 原文（phases_total/delegated/rate/verdict）+ 白名单豁免判定行
- **质量门控**: Q1-Q6 触发/豁免/未处置计数 + Evidence 抽查 ≥3 条记录（指针: verification.md 质量门控统计段）
- **验证独立性**: 本任务验证动作由 <N> 个全新独立子代理执行，主进程零自测替代验收（2026-09-26 裁决）

## 4. 风险点（必须列举；无则逐项写「无」，禁止整块省略）
- **已知遗留**: [PARTIAL 的已知缺陷 / 未授权零修复的候选清单指针 / 无]
- **待裁决**: [需用户拍板的事项逐项列出（部署同步/D6 授权等），带上下文一句话]
- **失效条件**: [本任务结论何时会过时——如「基线 42 脚本 660/0 — 失效条件: 任一新增/删除 selftest 脚本或计数漂移」；
 逐条给失效判据，消费方看到触发即重验，不盲信]
- **回滚方式**: [git revert <merge-hash> / 分支保留策略 / 备份文件路径（如 MEMORY.md.backup）/ 无]

## 5. 下一步建议（用户可执行行动项，按推荐排序；默认项排第 1 位并标注「推荐」）
1. **[推荐]** <行动项 1 — 一句话可执行，含触发条件>
2. <行动项 2>
3. ...
[多待决项按 Rule 41.5 打包呈报 + Rule 44.1 默认项排序；无待决项时写「本任务无待用户行动项」]
