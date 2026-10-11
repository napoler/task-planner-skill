# task-v127/S5 任务书 — 新建 selftest-requirement-grading.sh [parallel-group:impl-wave2]

## 1. 目标
在 **worktree** 新建 `scripts/selftest-requirement-grading.sh`（静态断言守护 Rule 50 落地物）+ `scripts/selftest-registry.tsv` 表尾登记 1 行。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（§Rule 50 设计契约=断言依据）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §5
- 范式参照（worktree 内，**只读**）: scripts/selftest-lane-advancement.sh（v126 最新静态 selftest 范式：PASS/FAIL 行+Total 汇总+set -u 安全写法）；scripts/selftest-registry.tsv（行格式）
- 断言对象（worktree 内）: references/critical-rules.md / SKILL.md / references/goal-gate.md / templates/variant/{image-type,character-design-type,qc-defect-type}.md / config.json
## 3. 验收标准(4 条)
- [ ] 新脚本在 worktree 运行全 PASS，至少含以下 RG 系列断言：
  - RG-01: critical-rules.md 含 '### 50 内容要求权重分级与评级'
  - RG-02: grep -c '^50\.' ≥6
  - RG-03: 泪痣双条目锚（'人物脸上有泪痣'∧'泪痣不注意看不到'∧'双向'）
  - RG-04: 三模板各含 '评级契约（Rule 50）'∧'原子验收条目'∧'双向'
  - RG-05: goal-gate.md 含 '分级'∧'Rule 50'
  - RG-06: SKILL.md 含 '1-50'∧'Rule 50'≥2 处
  - RG-07: config.json properties 计数=40（零新键）
- [ ] 脚本头注释含 What/Why（守护对象+任务号 task-v127）+ 输出范式=逐断言 PASS/FAIL 行 + `Total: N/N` 汇总 + 全过 exit 0/任一 FAIL exit 1
- [ ] selftest-registry.tsv 表尾 +1 行（格式对齐既有行：脚本名/守护对象/登记日期 2026-10-04/task-v127），总行数 46→47
- [ ] `git -C <worktree> diff --stat` 仅这两个文件（新脚本 untracked+registry 1 行修改）；registry 既有 46 行零改动
## 4. Scope 禁改清单
- 禁改 worktree 内其他文件（含三个级联锚脚本 selftest-plan-tier.sh/selftest-conclusion-discipline.sh/selftest-ask-default-timeout.sh——另一并行任务的文件，勿碰）；主仓 plans/ 只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 15 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS ...]
   统计/测试类: acceptance 只准贴逐项原文行（各断言 rc 与 Total: 行逐条列出），禁自报汇总数字
files: <两绝对路径>
evidence: <新脚本运行输出全文 + wc -l registry 前后值>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/08-s5-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/08-s5-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read §2 列出文件；范式脚本读结构（头注+断言函数+汇总段），禁全文背诵；断言对象用 grep 验证不全文读
