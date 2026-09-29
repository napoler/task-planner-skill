# P2-S1 任务书: Rule 40 六子条写入（task-v097）

任务: 在 worktree 内 critical-rules.md 末尾纯追加 Rule 40「harness 工具面主动选择」六子条全文。禁 git 操作（提交由后续步骤统一处理）。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读材料: Goal 段=六子条定义权威源;「强制约束」段=硬约束清单）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读参考;本任务结论由主进程回填,子代理禁写）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写,主进程回填）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection/skills/task-planner/references/critical-rules.md（当前 391 行,EOF=39.7.3 子条）

## 硬约束
只在该文件 EOF 后追加, L1-391 一个字符都不许动;禁写上列三文件与仓库其他任何文件。

## 必读材料（动手前先读）
1. 该文件 L339-390（Rule 39 全节）——格式范式必须同构: 节头 `### 40 …（… — task-v097，目标：…）`,子条行首 `40.1 **标题**：内容`（行首直接 40.N,保证 `grep -c '^40\.'` =6）
2. /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/knowledge-brief.md §1 概念表 + §4 易错点 1/10

## 六子条内容骨架（据此撰写完整条款文本,语言风格对齐 Rule 39,可适度扩写但不偏离语义）

引言一句: 与 Rule 39 的关系——39 管编排机制与纪律,40 管「计划期选哪个工具」的主动分析;40.4 不改 39.1 触发纪律。

- 40.1 **工具面清单**: 六类——/workflow 动态工作流（CreateWorkflow/AmendWorkflow/ResumeWorkflowRun/ResolveWorkflowQuestion/SaveWorkflow,触发纪律见 39.1/40.4）; /goal 会话目标（用户侧 harness 命令:目标锚定+完成审计,技能层仅做 40.3 映射指引）; Agent 子代理（默认执行体,路由表=SKILL §子代理路由与模型分级,纪律 Rule 21/22/25）; 卫星技能（plan-collab-router/plan-research-router/plan-template-kit/plan-cost-guard,主路由见各自 SKILL）; MCP/平台工具（web_reader 网页转 markdown / node_repl 浏览器控制 / documents 图像搜索等,环境事实以用户级 AGENTS.md §十 为准）; 机械守卫脚本（scripts/check-*.sh 与 selftest-*.sh 只读验证与门控,Rule 25.3 白名单③）。
- 40.2 **计划期主动分析**: standard/full 档计划须含「🧰 工具选择与编排」区块（general 模板承载）;逐 Phase 标注命中工具面与选择理由;workflow 编排判定与 /goal 对齐两判定行必填。区块定位=Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;mini 档豁免（Rule 38.3 区块白名单）。
- 40.3 **/goal 对齐**: 计划 Goal+VC 表是 session goal 完成审计的证据源;计划确认与交付时提示用户可将 Goal+VC 映射至 /goal 会话目标;**如实披露: /goal 是用户侧 harness 会话命令,技能层不可代调、不可读取其运行态**（Rule 35.2 防虚构）。
- 40.4 **workflow 编排计划期路径**: 计划期工具分析命中编排条件（独立并行子任务可 fan-out / 长链多 skill 接力可复用 / 用户点名）→ 计划「🧰」区块登记"建议 CreateWorkflow"并按 Rule 39.4 做并行豁免登记,执行期据此路由;未命中且用户未点名 → 维持 Rule 21.4 串行。**Rule 39.1「显式点名才路由」原文不变**,本条只增计划期建议登记面,不新增自动路由（Rule 36.5 纯增量）。
- 40.5 **机器校验边界（如实披露）**: 「🧰」区块为 LLM 行为面,check-dispatch/check-complete 不机器校验其存在性;守护=selftest-tool-selection.sh 静态断言（模板区块锚/mini-lite 豁免锚/plan-writer 契约锚/零新 config 键）;/goal 运行态不可从技能层读取,对齐证据=计划 VC 证据链。
- 40.6 **机制（零新 config 键 — 与 task-v087/v088 同范式）**: 判定面=LLM 行为（计划期分析,非机器触发）;机器面=selftest-tool-selection.sh 静态断言;消费侧=plan-writer 契约（companion/agents/plan-writer.md 工具选择区块撰写义务）+ general 模板区块 + template-mapping 工具选择映射。

## acceptance: 验收标准
1) `grep -c '^40\.' <目标文件>` 输出 6
2) `git -C /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection diff --stat` 仅该 1 文件且纯增（deletions=0）
3) `git diff` 中 L339-391 零变化
4) 40.3 含「不可代调」披露措辞
5) 40.6 含「零新 config 键」+「selftest-tool-selection.sh」

## checkpoint
完成前把结论写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/03-executor.md（含 grep/wc/diff 实际输出文本）。禁 git commit/add。

## 返回 8 字段模板（22.4b,标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
