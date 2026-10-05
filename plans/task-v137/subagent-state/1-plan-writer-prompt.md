# task-v137 计划撰写任务书（plan-writer 用，2026-10-05）

## 目标
为 task-v137 填写计划文档。只写 2 个文件：task_plan.md（替换 rule-enhancement variant 占位符为实内容）+ knowledge-brief.md（填五段实内容）。其余 4 个已初始化文件（findings/progress/notepad/verification）禁改。不执行 Phase、不派子代理。

## 任务背景（R 原文逐字，Rule 51.1——原样抄入 task_plan.md「🎯 用户需求原文」区块）
- R1:「$task-planner 以下是一次执行task =planner 任务你时候的消耗分析 太多消耗冗余 : 另外说清楚一件容易被忽略的事：这轮跑掉的 1478 万 token 里，绝大部分花在盘点代理读仓（每个 20 万到 66 万 token）和门禁补强设计代理（341 万单个）上。如果这条链路要反复迭代，下一个真正省钱的地方是把设计代理的输入收窄——现在它每次都要重读大批规范文件，而这个信息在盘点台账里已经有了。」
- R2:「继续」（2026-10-05，对呈示的「落点 1-4 + critical-rules 21.2.1 子条款」实施范围的授权指令）

## 材料包（必读，全以它为准）
/mnt/data/dev/task-planner-skill/plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md——机制、落点、守卫约束、实施清单 §5.3。

## 实施时点锚点（2026-10-05 实测，覆盖提案中的旧值；须写入 knowledge-brief §3 与计划锚点注记）
- skills/task-planner/references/critical-rules.md 共 590 行：21.2@:145、22.4@:167、22.4b@:169（插 21.2.1 ≤3 行后 T6 窗口 100<line<200 仍安全）；Rule 53 已被 task-v131 占用（:581）——本任务不新增 Rule、走 21.2.1 子条款、无 new_rule 声明
- skills/task-planner/templates/subagent_dispatch.md 共 76 行：📚 必要知识储备上下文包表@:32-36（:36 行含「brief 存在时必读其索引节(§5)」）
- skills/task-planner/templates/variant/rule-enhancement-type.md 共 122 行：必读表标题「## 📚 必要知识储备」@:93
- skills/task-planner/templates/knowledge-brief.md 61 行五段锚未变：§2@:33、§3@:41、§5@:56
- skills/task-planner/SKILL.md 478 行，selftest-skill-split.sh T2 钉 ≤478——本任务 SKILL.md 零改动（提案落点 5 推荐零改动）

## Phase / S-unit 结构（「执行体」列必填——attest 的 check-plan-dispatch 硬校验）
- Phase 1 隔离区实施（4 个 S-unit，串行派发 executor(sonnet-1)；worktree 绝对路径 /home/terry/task-planner-skill-worktrees/task-v137，分支 wt/task-v137）：
  - S1 knowledge-brief.md 模板 §2/§3/§5 加「台账供料行型」填写说明与示例（+10~15 行；守卫：T1b 五段锚 `^## §` 保持 =5、T1c 模板 ≤150 行）
  - S2 subagent_dispatch.md 📚 表（:32-36）加注入纪律行（基线定数一律经 brief §2/§3 台账路径锚供料、prompt 禁内联重建，收口 v116 A2 变体）
  - S3 critical-rules.md 21.2@:145 后插 21.2.1「台账供料优先」子条款（≤3 行、引用化不重述 21.2）
  - S4 rule-enhancement-type.md :93 必读表加台账供料简报行
- Phase 2 回归验证（执行体 code-runner-agent，worktree 内）：selftest-knowledge-brief.sh 全组（T1a-T1c/T2a/T2b/T6/T7）+ selftest-skill-split.sh + check-dispatch.sh 冒烟 + 全量 selftest（51 脚本全绿基线）
- Phase 3 合并部署与簿记（执行体：主进程，白名单①git 编排）：smart-merge-back --deploy + INDEX/ledger 簿记

## 必填区块（缺一 attest 拒绝）
1. 「🎯 用户需求原文」：R1/R2 逐字 + R→VC 映射表（每条 R ≥1 VC；VC 全部可观察证据形态）
2. 「🧮 根源覆盖表」（Rule 53.1）：结果级需求→工序审计（本轮=设计简报供料机制消除设计/审计代理重复读仓）
3. 「🔀 隔离决策」：冲突扫描三信号结论=未提交变更 22 个均 plans/ 簿记与本任务技能文件范围零重叠；wt/task-v134、wt/task-v135 在途（它们改 critical-rules/SKILL，与本任务 hunk 不重叠，合并期按 hunk 解冲突）；决策=worktree 隔离（CWD 不迁移，计划文档留主仓）
4. 「📊 FMEA 预演」（高风险项：锚漂移致 selftest 碎→兜底=实施前逐锚重验；合并冲突→兜底=hunk 级手工合流）
5. 「🧰 工具选择与编排」（standard 档 Rule 40，逐 Phase 登记执行工具面与理由）
6. 「质量审查工具」行：登记 alignment-review 为收尾对齐审查工具（Rule 42/C32）
7. 「Decisions Made」三行：①用户会话内「继续」=对呈示落点范围的实际授权（D1 门控依据）；②走 21.2.1 子条款而非新 Rule（依据=Rule 53 已被 task-v131 占用+提案时效补记）；③部署吸收 v133 部署滞后，部署后跑 IDENTICAL 对账
8. VC 表（Phase 完成判据，逐条可观察）
9. Rule 36 纯增量声明：全部改动为纯增行/加行，无删除无语义改写（36.5）
10. Rule 20.6：无 new_rule 声明（不加编号登记行）

## 验收标准（完成前自检）
1. task_plan.md 无模板占位符残留
2. R1/R2 逐字在「🎯 用户需求原文」内，R→VC 映射完整
3. 每个 Phase 有 **Executor:** 字段，派发型 Phase 的 S-unit 表含「执行体」列且无空
4. 上述 10 项必填区块齐备
5. knowledge-brief.md §1-§5 实内容，§3 锚点表含上述实测行号

## Scope 禁改
仅 task_plan.md + knowledge-brief.md；禁改 plans/ 其他文件、skills/**、提案文件。
