# P2-S1 任务书: review-library/general-review/SKILL.md 范式技能（task-v100）

任务: 在 worktree 内新建 `skills/task-planner/review-library/general-review/SKILL.md`（通用综合质量审核技能,兜底池范式标杆——后续 9 个技能按本范式产出）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/task_plan.md（只读: Goal 区四要素合约+VC-1/VC-2）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/progress.md（子代理禁写）

## 目标文件（新建）
/mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/review-library/general-review/SKILL.md
（review-library/ 目录不存在,连同父目录一起创建）

## 四要素硬性合约（缺一不可）
1. **frontmatter**: `---` 包裹,含 `name: general-review` 与 `description: 通用综合质量审核技能（兜底池）——…一句话用途`（YAML 合法,无 tab）
2. **触发条件段**: 说明何时使用本技能（Rule 42.2 四级检测命中本技能时;任务无更专用审核技能时的通用兜底;描述触发场景）
3. **审查清单段**: ≥10 条具体可执行的检查项（每条一行 `- [ ] 检查项: 说明` 格式,通用综合面——覆盖正确性/完整性/一致性/可维护性/文档/测试/安全基线/性能基线/可回滚性/证据留痕十个维度,每维度 1 条具体化措辞,禁空洞套话）
4. **输出合约段**: 审查结论二值 `APPROVED` / `CHANGES_REQUESTED`;CHANGES_REQUESTED 时逐条问题清单（[P0/P1/P2] 文件:行 — 问题 — 建议修法）;**证据要求**: 每条结论必须附机器可复现证据（file:line/命令+输出,呼应 Rule 43.1 证据先行——引用「Rule 43.1」字样）

## 质量要求（范式标杆——S2-S4 的 9 个技能将按本文件范式对标产出）
- 总行数 50-70 行;语言:中文为主,结构化标题（## 触发条件 / ## 审查清单 / ## 证据要求 / ## 输出合约）
- 无空话套话;每条清单可直接执行（有明确检查动作）
- 文末注明来源行: `<!-- task-v100-review-library 兜底池成员 1/10;Rule 42.2 第④层消费;范式锚定文件 -->`
- 禁出现「1-4x」越界数字字面;禁改动本文件外任何文件

## acceptance: 验收标准
1) 文件存在且 50-70 行
2) frontmatter 合法（head -5 可见 name+description,无 tab）
3) 四要素 grep: 「## 触发条件」「## 审查清单」「## 证据要求」「## 输出合约」各 ≥1
4) 审查清单 `- [ ]` 条目 ≥10
5) 「APPROVED」与「CHANGES_REQUESTED」各 ≥1;「Rule 43.1」≥1
6) `ls review-library/` 恰 1 目录
7) `git -C <wt> status --short` 仅该文件 untracked

## checkpoint
完成前把结论与验收命令输出写入 /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/01-exec-p2s1.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
