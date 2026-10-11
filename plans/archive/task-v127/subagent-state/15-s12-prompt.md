# task-v127/S12 任务书 — v129 合流级联修复（5 脚本各 1 FAIL）

## 1. 目标
在 **worktree**（已完成 master 合流 merge 7b356e5，Rule 50+51 并存、SKILL.md 全集行=1-51、452 行）修复合流级联的 5 个 selftest FAIL，每个先跑出 FAIL 原文定位，再最小修复（锚宽容化/行号重锚，断言语义零改动），修复后复跑归零。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（Decisions D8 同类授权：锚过窄→宽容化）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §4
- FAIL 清单（合流后实测）:
  - selftest-plan-tier.sh（PT-08 锚 `1-4[5-9]|1-50` 不匹配现值 "1-51" → 扩 `1-5[0-9]`）
  - selftest-conclusion-discipline.sh（CD-11 n45 同因 → 扩 `1-5[0-9]`，合计 ≥3 语义不变）
  - selftest-requirement-grading.sh（RG-06 '1-50' 字面 → 改 `1-5[0-9]` 宽容；registry 行描述已同步）
  - selftest-lane-advancement.sh（FAIL 详情自行跑出定位——疑似 SKILL.md 行数/锚漂移，按其断言语义最小修复）
  - selftest-requirement-coverage.sh（v129 的脚本，FAIL 自行定位——疑似 SKILL.md/critical-rules.md 行号锚因 Rule 50 块插入而漂移，重锚到实际行号，label 注明 task-v127 合流重锚）
- 禁改对象: critical-rules.md / SKILL.md / 模板 / goal-gate / registry 内容语义（只许脚本侧适配，禁反向改内容迁就锚——除非定位证明是合流丢内容，此时 STOP 报告）
## 3. 验收标准(3 条)
- [ ] 5 脚本修复后单跑全 PASS rc=0（贴每脚本修复前 FAIL 行原文 + 修复后 Total 行原文）
- [ ] 修复全部为锚/行号级适配（git diff 逐文件 ≤4 行变更；无断言语义反转；无内容文件改动）
- [ ] `git -C <worktree> status --porcelain` 仅这 5 个脚本文件
## 4. Scope 禁改清单
- 禁改上述 5 脚本外任何文件；主仓 plans/ 只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 20 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/3 pass — [1:PASS ...]
   统计/测试类: acceptance 只准贴逐项原文行（修复前 FAIL 行+修复后 Total 行逐条列出），禁自报汇总数字
files: <5 绝对路径>
evidence: <修复前 FAIL 行×5 + 修复后 Total 行×5 + git diff --stat>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/15-s12-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/15-s12-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 每脚本 grep 定位断言区段读局部（±15 行）；禁全文通读
