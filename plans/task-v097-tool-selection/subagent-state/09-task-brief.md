# P5-S1 任务书: 新建 selftest-tool-selection.sh（task-v097）

任务: worktree 内新建 scripts/selftest-tool-selection.sh（Rule 40 静态断言守护,对齐 selftest-workflow-orchestration.sh 范式）并跑通全 PASS。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: VC-1/VC-5 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写）

## 目标文件
新建: /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection/skills/task-planner/scripts/selftest-tool-selection.sh

## 硬约束
- 先 Read scripts/selftest-workflow-orchestration.sh 全文——格式/ok-bad-Total 结构/路径解析方式（相对脚本目录定位仓根）必须同构。
- 静态只读断言（grep/wc）,零仓库写入;如需临时文件必须 mktemp+trap 清理。
- `bash -n` 语法检查通过。
- 断言锚必须先 grep 实际文件确认存在再写进脚本（P4 教训: 验收锚先对产物自测）。

## 断言清单（TS-01..TS-12,锚子串以 worktree 实际文件为准,±微调需保语义）
- TS-01: critical-rules.md `grep -c '^40\.'` = 6
- TS-02: critical-rules.md 含 40.3 披露措辞「不可代调」≥1
- TS-03: critical-rules.md 40.4 行含「显式点名」≥1 且 40.6 行含「零新 config 键」≥1
- TS-04: SKILL.md `grep -c 'Rule 40'` ≥3
- TS-05: SKILL.md `grep -c 'Rules 1-39'` = 2 且 `grep -c '1-40'` = 0（对策 b 字面锚——关键负断言）
- TS-06: SKILL.md 三个既有锚子串各 ≥1: 「Rule 39（动态工作流编排」「| C27 |」「dynamic-workflows（用户显式点名」
- TS-07: SKILL.md 含「| C28 |」≥1
- TS-08: templates/task_plan.md 含「🧰 工具选择与编排」≥1 且含「上游分析记录」≥1
- TS-09: templates/variant/mini-lite-type.md 含「Rule 40.2 豁免声明」=1 且 wc -l ≤80
- TS-10: templates/subagent_dispatch.md 含「工具面提示」≥1
- TS-11: plan-template-kit 两文档: template-mapping.md 含「工具选择映射」≥1;template-guide.md 含「工具选择与编排」≥1;companion/agents/plan-writer.md 含「工具选择与编排区块」=1
- TS-12: 零新 config 键——config.json 顶层 properties 键数 = 40（与 WF-12 同口径,参考 selftest-workflow-orchestration.sh 的实现方式）

## acceptance: 验收标准
1) `bash scripts/selftest-tool-selection.sh` 输出 Total 行 PASS=12 FAIL=0（或 ≥12 断言全 PASS）
2) `bash -n scripts/selftest-tool-selection.sh` rc=0
3) 脚本结尾输出与 WF 范式同构的 `Total: N PASS=x FAIL=y` 行
4) 断言路径用相对脚本目录解析（`cd "$(dirname "$0")"` 或等价）,仓根定位与 WF 范式一致
5) `git -C <wt> status --short` 仅新增该 1 文件（untracked）,零其他写入

## checkpoint
完成前把结论与 Total 行输出写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/09-executor.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: Total 行与 bash -n 输出
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
