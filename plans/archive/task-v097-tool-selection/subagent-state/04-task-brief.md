# P2-S2 任务书: SKILL.md 四锚同步 + 行数断言级联（task-v097）

任务: worktree 内 SKILL.md 四锚同步 Rule 40 + selftest 行数断言级联上调 + 相关 selftest 复跑验证。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: VC-2 判定标准+强制约束 3/4/5）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读参考）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写,主进程回填）

## 目标文件（全部在 worktree /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection 下）
1. skills/task-planner/SKILL.md（当前 430 行）
2. skills/task-planner/scripts/selftest-skill-split.sh（仅 L41 行数上限一处）

## 硬约束
- **禁止在任何文件写入字面「Rules 1-40」或「1-40」计数措辞**——P1 实测确证: 4 处宽容正则锚（reflect-verify RV-10 `Rules 1-3[5-9]` / error-loop EL-11 / veto VT-10 `Rules 1-3[1-9]` / conclusion-discipline CD-18 `Rules 1-3[5-9]`）+ WF-10 计数（4 索引文档「Rules 1-39」总和 ≥6）全部依赖字面子串「Rules 1-39」。语义更新一律用「Rules 1-39（含 Rule 40 …）」括注形态。
- 既有锚子串逐字保全: L47 的「dynamic-workflows（用户显式点名」（WF-09 断言锚）、L191 的「| C27 |」（WF-08）、L268 的「Rule 39（动态工作流编排」（WF-07）——只增不改这三行。
- 零新 config 键;不动其他任何文件。

## 四锚操作（先 Read SKILL.md 对应行段核实,行号可能有 ±2 漂移,以内容锚定位为准）
1. L47 行（协同路由段 dynamic-workflows 行）之后追加 1 行:
`- **Rule 40 计划期工具面主动选择（harness 工具面清单+🧰 区块+/goal 对齐，Rule 40）**：计划期在「🧰 工具选择与编排」区块逐 Phase 登记执行工具面与选择理由（六类工具面清单见 critical-rules.md Rule 40.1）；分析命中编排条件（独立并行子任务/fan-out/长链复用）时按 Rule 39.4 登记建议 CreateWorkflow（Rule 39.1 显式点名红线不变）；/goal 对齐仅做映射指引（用户侧 harness 命令技能不可代调，40.3 如实披露）；mini 档豁免（Rule 38.3）。`
2. C27 行（合规清单表末行,含「| C27 |」）之后追加 C28 表行:
`| C28 | standard/full 档计划含「🧰 工具选择与编排」区块且逐 Phase 登记工具面与理由、workflow 编排判定与 /goal 对齐两判定行已填（Rule 40.2/40.3/40.4；Executor 字段仍是委派门控机器事实源,区块不替代；mini 档豁免无需记行）；命中建议 CreateWorkflow 时已按 39.4 登记并行豁免（机器面=selftest-tool-selection 静态断言,区块完整性人工核查） | ☐ |`
3. L268 行（「Rule 39（动态工作流编排 — task-v088）」摘要行）之后追加摘要行:
`- **Rule 40（harness 工具面主动选择 — task-v097）**：工具面六类清单（/workflow、/goal、Agent 子代理、卫星技能、MCP、机械守卫脚本）（40.1）；计划期「🧰 工具选择与编排」区块=Executor 上游分析记录,不替代委派门控机器事实源（40.2）；/goal 对齐映射指引+用户侧命令如实披露（40.3）；workflow 编排建议登记制、39.1 显式点名红线不变（40.4）；机器校验边界如实披露（40.5）；零新 config 键+selftest-tool-selection.sh 守护（40.6）`
4. 「（Rules 1-39）」索引行（约 L239,内容含「详见 `references/critical-rules.md`（Rules 1-39）」）行内改: 「Rules 1-39」→「Rules 1-39（含 Rule 40）」（行数 +0）
5. References 表 critical-rules.md 行（约 L292,含「Critical Rules 1-39（含 Rule 13-18/…」）行内改: 枚举末尾「Rule 39 动态工作流编排」后加「 / Rule 40 harness 工具面主动选择」（行数 +0）

## 行数断言级联
- 预期 SKILL.md 430→433（净增 3 行）。完成后 `wc -l` 实测,把 selftest-skill-split.sh L41 的 `-le 430` 改为 `-le <实测值>`,同函数内 `-le 558` 不动,label 字符串「T-主 行数 ≤430 目标且 ≤558 上限」改为「T-主 行数 ≤<实测值>（task-v097 Rule 40 联动 430→<实测值>）且 ≤558 上限」。
- 4 处 ≤558 断言（batch-pilot:55/knowledge-brief:38/skill-collab:82/execution-stability:72）无需改动（433 << 558）,但必须复跑验证。

## acceptance: 验收标准
1) `grep -n 'Rule 40' SKILL.md` ≥3 处（协同路由行/C28/摘要行）
2) `grep -c 'Rules 1-39' SKILL.md` =2（L239/L292 两处字面保留,括注形态）
3) SKILL.md 内 grep '1-40' 零命中
4) WF-07/08/09 锚子串原样在: `grep -c 'Rule 39（动态工作流编排' SKILL.md` ≥1、`grep -c '| C27 |' SKILL.md` ≥1、`grep -c 'dynamic-workflows（用户显式点名' SKILL.md` ≥1
5) worktree scripts/ 下复跑 6 个 selftest 全 0 FAIL: selftest-workflow-orchestration.sh（WF-10 计数+WF-12）/selftest-skill-split.sh（新上限）/selftest-knowledge-brief.sh/selftest-skill-collab.sh/selftest-execution-stability.sh/selftest-batch-pilot.sh——逐脚本 Tail 的 Total/结果行原文记入检查点
6) `git -C <wt> diff --stat` 仅 SKILL.md + selftest-skill-split.sh 两个文件

## checkpoint
完成前把结论与上述命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/04-executor.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
