# P2-S2+S3 任务书: SKILL.md 四锚联动 + 行数级联（task-v098）

任务: worktree 内 SKILL.md 四锚联动 Rule 41 + selftest-skill-split.sh 行数上限级联。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/task_plan.md（只读: VC-2 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v098-auto-resolution 下）
1. skills/task-planner/SKILL.md（当前 433 行;锚位以内容锚定位,±3 漂移正常）
2. skills/task-planner/scripts/selftest-skill-split.sh（仅 :41 断言行）

## 硬约束
- 禁在任何新文本产生「1-40」子串;「Rules 1-39」字面 2 处（约 :241/:295）只允许行内括注形态改写（字面子串必须保留）。
- 既有锚子串逐字保全: 「Rule 40（harness 工具面主动选择」「| C28 |」「dynamic-workflows（用户显式点名」「Rule 39（动态工作流编排」——只增不改这些行。
- 零新 config 键;不动其他任何文件。

## 四锚操作（S2）
1. C28 行（含「| C28 |」的表行）之后追加 C29 表行:
`| C29 | 本任务执行中出现失败/阻塞/升级冲动时已按 Rule 41 过消解链与升级四门槛：升级用户仅限 G1 破坏性不可逆/G2 范围越界/G3 对外不可撤回发布/G4 语义级目标分叉,门槛外自动消解+登记禁呈报（41.2/41.3）；任何 AskUserQuestion/STOP 前已过 41.4 消解清单并在上报附「已尝试清单」；多待决项打包呈报附推荐（41.5）（机器面=selftest-self-resolution 静态断言,消解过程人工核查） | ☐ |`
2. Rule 40 摘要行（含「Rule 40（harness 工具面主动选择」的行）之后追加 Rule 41 摘要行:
`- **Rule 41（问题自主消解与升级纪律 — task-v098）**：消解优先链=重读计划→22.3 ①-④ 兜底→最小探针→拆细→替代路径,升级用户是最后手段非默认出口（41.1）；升级四门槛 G1 破坏性不可逆/G2 范围越界/G3 对外不可撤回发布/G4 语义级目标分叉,门槛外自动消解+登记（41.2）；trivial 小修直接做+登记,禁「留用户裁决」推诿（41.3）；升级前必过消解清单并附「已尝试清单」,D6 硬停点语义保留不弱化（41.4）；多待决项打包呈报附推荐（41.5）；零新 config 键+selftest-self-resolution.sh 守护（41.6）`
3. 索引行内含「（含 Rule 40）」的行（约 :241）: 「含 Rule 40」→「含 Rule 40/41」（行数 +0）
4. References 表 critical-rules.md 行（约 :295,含「/ Rule 40 harness 工具面主动选择」）: 枚举末尾追加「 / Rule 41 问题自主消解与升级纪律」（行数 +0）

## 行数级联（S3）
S2 完成后 `wc -l SKILL.md` 取实测值 N（预期 433→436,净增 3）,把 selftest-skill-split.sh:41 的 `-le 433` 改为 `-le N`,label「T-主 行数 ≤433（task-v097 Rule 40 联动 430→433）且 ≤558 上限」→「T-主 行数 ≤N（task-v098 Rule 41 联动 433→N）且 ≤558 上限」。级联值以 wc 实测为准禁手估。

## acceptance: 验收标准
1) `grep -c 'Rule 41' SKILL.md` ≥3 且 `grep -c '| C29 |' SKILL.md` =1
2) `grep -c 'Rules 1-39' SKILL.md` =2 且 `grep -c '1-40' SKILL.md` =0
3) `grep -c '含 Rule 40/41' SKILL.md` ≥1
4) 既有锚保全: 「Rule 40（harness 工具面主动选择」「| C28 |」「dynamic-workflows（用户显式点名」「Rule 39（动态工作流编排」各 grep -c ≥1
5) selftest-skill-split.sh 断言值=wc 实测且 label 含 task-v098;worktree scripts/ 复跑 6 脚本全 0 FAIL: selftest-skill-split/selftest-workflow-orchestration/selftest-knowledge-brief/selftest-skill-collab/selftest-execution-stability/selftest-batch-pilot
6) `git -C <wt> diff --stat` 现累计仅 SKILL.md + selftest-skill-split.sh 2 文件（critical-rules.md 为并行 Wave 的另一 agent 写入,不算本任务书范围）

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/subagent-state/03-executor-p2s2s3.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2S3
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
