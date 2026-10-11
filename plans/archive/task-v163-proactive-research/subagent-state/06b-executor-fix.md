# 检查点: 06b-executor-fix（CR Gate 修复）

- status: done
- date: 2026-10-10
- task: task-v163 CR 修复（06-reviewer CHANGES_REQUESTED → 2 Blocker + 1 Suggestion）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research
- base: ba5ee1c（worktree HEAD；全部改动为工作树未提交变更）

## 目标
修复 CR Gate 的 2 Blocker + 1 Suggestion：
① SKILL.md 合规清单 C52（Rule 75）→ C53（master 已有 C52=Rule 72，撞号避让）
② critical-rules.md 75.7 自述「合规清单 C51」→「合规清单 C53」（对齐 SKILL.md 实态）
③ subagent_dispatch.md 补 Rule 75.2 触点行（落实 75.7 声称的「检索契约行延伸」）

## 改动清单（3 文件，工作树内）
1. skills/task-planner/SKILL.md:235
   `| C52 | 网络调研主动激活自查（Rule 75）` → `| C53 | 网络调研主动激活自查（Rule 75）`（内容不变）
2. skills/task-planner/references/critical-rules.md:990
   `消费侧=SKILL.md 摘要 bullet + 合规清单 C51 + ...` → `... 合规清单 C53 + ...`
3. skills/task-planner/templates/subagent_dispatch.md:28（新行，插于原 :27 检索优先契约行后）
   `- **反死磕触点（Rule 75.2）**：执行中遇阻（不知道/不确定/报错/选型）第一动作=评估网络检索，同一思路连续尝试 ≥2 次无外部输入→必须转入检索，禁以本地死磕为默认路径`

## 验证证据（grep 原文）
- V1 PASS: `grep -n "^| C53 | 网络调研主动激活自查（Rule 75）" SKILL.md` → 235 命中
- V2 PASS: `grep -n "C52.*Rule 75\|C52.*网络调研" SKILL.md` → 无输出（rc=1，无残留）
- V3 PASS: `grep -n "合规清单 C53" critical-rules.md` → 990 命中
- V4 PASS: `grep -n "反死磕触点（Rule 75.2）" subagent_dispatch.md` → 28 命中
- numstat(vs base): SKILL.md 5/3、critical-rules.md 20/0、subagent_dispatch.md 1/0

## Scope 边界（遵守）
- 仅写 3 目标文件；未触 C51（Rule 72，避让归并侧处理）
- 未做任何 git 操作；未网络访问；未改其他文件

## 未决（移交主进程，非本 S-unit scope）
- reviewer blocker④: Rule 73 欠账核实（合并后按实态修正）
- reviewer blocker⑤: worktree 根 plans-baseline.md / regression-baseline.md scratch 清理
- 合并基线重定: master 已前进至 d45e8e2（worktree scope 重叠）

## 产物
- findings: /mnt/data/dev/task-planner-skill/plans/task-v163-proactive-research/findings.md → `#### [sub:06b-executor] CR 修复`
