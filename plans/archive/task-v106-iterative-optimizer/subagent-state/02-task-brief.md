# P2-S2 任务书: selftest-iterative-optimizer.sh + registry 登记（task-v106）

任务: worktree 内新建 `task-planner/scripts/selftest-iterative-optimizer.sh`（IL-01..08,断言对象=顶层 skills/iterative-optimizer/SKILL.md）+ selftest-registry.tsv 追加 1 行。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v106-iterative-optimizer/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
1. /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer/skills/task-planner/scripts/selftest-iterative-optimizer.sh（新建）
2. /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer/skills/task-planner/scripts/selftest-registry.tsv（EOF +1 行,4 列 TSV 照既有行形态）

## 硬约束
- **断言对象路径必须相对解析**: `SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"` → `TARGET="$SKILL_ROOT/../iterative-optimizer/SKILL.md"`；**禁止写死 /home/terry**（S75-D1）
- 范式照 selftest-reliability-institution.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad()、`Total: 8 PASS=8 FAIL=0`、exit $((FAIL > 0))、set -u）
- 只动 2 个目标文件;禁「1-4x」越界字面

## 断言清单（IL-01..08,动手前先 Read S1 产出实测锚）
- IL-01: 文件存在且 frontmatter `name: iterative-optimizer`（head -5 内 grep）
- IL-02: 行数 90-120（wc -l 区间断言）
- IL-03: 五步锚——「评估 (evaluate)」≥1、「诊断弱点 (diagnose」≥1、「定向改进 (improve」≥1、「门控判定 (gate」≥1
- IL-04: 状态文件锚 `plans/loop-<task-id>-state.md` ≥1
- IL-05: 输入契约锚——「≥3 条」≥1、「机器可检查」≥1、「max_iterations」≥1、「默认 5」≥1
- IL-06: 门控铁律——「禁止宣称 RESOLVED」=1、「连续 2 轮」≥1
- IL-07: 摘要表头「改了什么 (what)」≥1、「为什么 (why」≥1、「门控结果」≥1
- IL-08: banned 词负断言——`grep -c '更好\|大致\|应该\|足够'` = 0
头注释: 脚本定位+IL-01..08 描述+「静态只读零写入」声明。Total 行 `Total: 8 PASS=8 FAIL=0` 形态。

## registry 行（4 列,列结构照既有行,描述准确）
`selftest-iterative-optimizer.sh<TAB>iterative-optimizer 循环迭代优化 skill 静态守护<TAB>五步闭环/输入契约/门控铁律/迭代摘要锚（task-v106）<TAB>顶层 skills/iterative-optimizer/SKILL.md;八断言 IL-01..08`

## acceptance: 验收标准
1) `bash scripts/selftest-iterative-optimizer.sh` → `Total: 8 PASS=8 FAIL=0` exit 0
2) `bash -n` 语法过;`grep -c '/home/terry'`=0（禁写死）
3) registry 行数 43（=42 脚本+表头,SR-12 动态口径咬合）且 `grep -c 'selftest-iterative-optimizer' registry`=1
4) worktree 复跑: selftest-iterative-optimizer+selftest-self-resolution（SR-12 动态咬合验证）全 0 FAIL
5) `git -C <wt> status --short`: 新增 1 脚本+M registry（iterative-optimizer/SKILL.md 为 S1 存量 untracked→此时应已 git add?不——S1 未 add;你只负责你的 2 文件）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v106-iterative-optimizer/subagent-state/02-exec-p2s2.md（含 Total 行原文）。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: Total 行+SR-12 复跑输出
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
