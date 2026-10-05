# task-v127 plan-writer 任务书（Rule 35.3 落盘版，2026-10-04）

## 1. 目标
为 task-v127 撰写正式 task_plan.md + knowledge-brief.md：在 task-planner 技能落地 **Rule 50「内容要求权重分级与评级」**。

能力设计要点（源自调研，详见 findings §Requirements/§Research Findings）：
- 计划期把内容/媒体类复合需求拆为原子验收条目表（|条目|类型:存在性P/程度E|层级:硬约束H/评分项S|权重|判定刻度|），程度类约束词（不注意看不到/不明显/轻微/淡）必须显式成条；未标注层级默认 H（用户写进要求=硬约束，防再忽略）
- 逐条评级（PASS/PARTIAL/FAIL），程度条目双向判（过显眼 FAIL/不可见也 FAIL）
- 加权判定 = 全 H 过 + S 加权 ≥阈值（仿 methodology.md:193-212 Q4 五维评分卡先例）
- QC 链消费：条目表随任务书派发，image-understand 取证逐条评级 + image-review 质量门

## 2. 输入(计划三文件,绝对路径)
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — **可写=按 variant 模板重写全文**；必须保留既有：Goal 行、Handoff 表已填 2 行(done)、Phase 1 complete 段、Current Phase=Phase 2
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读（设计输入全在此）
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md — 可写=按五段模板重写
- 材料包（brief §5 索引源）：/mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/rule-enhancement-type.md（模板基线，不存在则 Glob templates/variant/ 取最近似）+ skills/task-planner/templates/task_plan.md + plans/task-v122/task_plan.md（同型任务样例）+ skills/task-planner/references/goal-gate.md

## 3. 验收标准(4 条)
- [ ] task_plan.md：frontmatter template_type=rule-enhancement-type；VC 表 ≥5 条可机读（含样例级：泪痣案例拆出 P/H+E/H 双条目并带评级语义）；执行范围限制表；Phase 1 已 complete + Phase 2-5（P2=本规划 Phase 标 in_progress；P3 实现=S-unit 表每行 ≤2 文件/≤15min/执行体列必填+ID 纯数字；P4=44 selftest 全量回归+独立验证；P5=worktree 合并回+3 位部署+簿记）；隔离决策=worktree /mnt/data/dev/task-planner-skill-worktrees/task-v127 分支 wt/task-v127；FMEA；🧰工具选择区块；Decisions 含：Rule 号=50（避让 pending v126 的 49）、零新 config 键（静态 selftest 守护，v122/v123 先例）、SKILL.md 净增 ≤10 行
- [ ] scope_files 明确（建议，按 findings 级联面核对）：skills/task-planner/references/critical-rules.md（EOF :504 后追加 Rule 50 块 ~25 行）+ SKILL.md（≤10 行：摘要 bullet/索引/媒体路由行消费点）+ templates/variant/{image-type,character-design-type,qc-defect-type}（评级契约区块）+ 新建 scripts/selftest-requirement-grading.sh + selftest-registry.tsv(+1 行) + 级联 3 锚扩口径（selftest-plan-tier.sh:78、selftest-conclusion-discipline.sh:66/69-70、selftest-ask-default-timeout.sh:66-69，使 "1-50" 合法——v121 预扩先例）+ 可选 references/goal-gate.md VC 分级语义 1 行
- [ ] knowledge-brief.md 五段完整（速览/已验证事实=findings 锚点/文件锚点/易错点=派发守卫契约+级联锚/S-unit 材料包索引）
- [ ] Executor≠主进程的 Phase 均有 S-unit 表；主进程 Phase 均带 Rule 25.3 白名单例外理由

## 4. Scope 禁改清单
- 禁改 skills/** 任何文件（只读参考）；禁改 findings.md/progress.md；git 只读；禁触碰 worktree

## 5. 工作路径
- cwd: /mnt/data/dev/task-planner-skill（绝对路径操作）

## 6. 时长预算
- 计划撰写 → 60 分钟；超时返回 partial

## 7. 返回格式(严格 8 字段，逐字段填写，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS ...]
files: <绝对路径列表>
evidence: <file:line 或关键内容行>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/03-plan-writer.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW

## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/03-plan-writer.md（唯一额外可写文件）；T5 结束必写「最终结论」段=第 7 节同一 8 字段块

## 9. 上下文预算
- 只 Read 本任务书 §2 列出路径；模板/样例只读结构骨架，勿全文背诵进计划；本任务书自身即 brief 素材源
