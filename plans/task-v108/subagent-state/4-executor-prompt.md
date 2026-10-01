# 批次三修复任务书（subagent-state/4-executor-prompt.md 别名，实际为 Handoff 行 4 之前最后一批修复）

执行体：executor · WT = /mnt/data/dev/task-planner-skill-worktrees/task-v108

## 修复项（M-07/M-08/M-12/M-13：全部增量类——补缺失区块/行/原则表述）

**M-07** — 9 个无 Drift Log 的 variant，节末（文件最末）补「## 🚨 Drift Log（漂移检测记录）」节：
- 文件：WT/skills/task-planner/templates/variant/{bugfix,code-edit,deployment,migration,performance-tuning,refactor,rule-enhancement,schema-migration,test-writing}-type.md
- 节内容对齐主模板 task_plan.md:334-341 范式（标题+WHEN/FORMAT 注释+四列表头+空行），四列=时间/检测结果/涉及VC/结论，一律精简两行版（标题+表头+空行，注释可省）

**M-08** — 15 个缺 Handoff 节的 variant（除 mini-lite 外全部），节末（Drift Log 之后或文件最末）补「## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）」节：
- 对齐主模板 task_plan.md:373-387 范式，精简版=节标题+说明一行（「每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)」）+九列表头（#/时间/subagent_type/任务目标(≤1 句)/状态/结论摘要(≤3 行)/证据(file:line)/findings 落点/checkpoint 路径）+备注列合并省略+空行 2 行
- 高风险联动告知：check-complete.sh:1014 以「Subagent Handoff 登记表」字样为节锚——补节后机器门对 variant 计划生效（正向修复）；节标题字样必须逐字含「Subagent Handoff 登记表」

**M-12** — 15 个标准 variant「🔍 Code Review 配置」表（各文件约 :12-14 区域）补 3 行（对齐主模板 :31-33 行范式，可精简注释列）：
- `| \`对齐审查\` | \`[登记]\` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |`
- `| \`自动超时默认项\` | \`[询问点: 默认选项/超时值]\` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |`
- `| \`质量审查工具\` | \`[检测结论]\` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |`
- 同时每文件在「🧰 工具选择与编排」缺失处（VC 表后、Phases 前的合适位置）补「## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）」精简区块：说明一行（逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免）+三列表头（Phase/命中工具面/选择理由）+示例行 1 行。注意与 mini-lite 无关（不动 mini-lite）
- 15 文件=除 mini-lite 外全部 variant（bugfix/code-edit/deployment/diagnostic/migration/performance-tuning/publish/refactor/research/rule-enhancement/schema-migration/test-writing/video-fix/video/writing）

**M-13** — 验证独立性原则双落点（增量）：
- A: WT/skills/task-planner/templates/verification.md 「## Goal Gate (终验，所有 phase complete 后执行)」段（约 :98-108）末尾追加一行：`> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）`
- B: WT/skills/task-planner/templates/task_plan.md VC 段「## ✅ Verification Contract」标题行后（约 :35 引导注释后）追加一行：`> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）`

## 验收
1. `git -C WT diff --stat` 本批新增改动涉及 15 个 variant + verification.md + task_plan.md = 17 文件（此前批次文件不再计入新增）
2. 机械计数：`grep -Lc "Drift Log" WT/.../variant/*-type.md` 仅 mini-lite 1 个缺（7 原有+9 新补=16 有）；`grep -lc "Subagent Handoff 登记表"` 16/16 含（15 新补+mini-lite 原有）；3 行配置 15/15；「验证独立性」两落点 grep 各 1 命中
3. `bash WT/skills/task-planner/scripts/selftest-template-lifecycle.sh` → 18/18 PASS；`bash WT/skills/task-planner/scripts/selftest-plan-tier.sh` → 全 PASS（mini-lite 白名单未破坏）
4. checkpoint 落盘含最终结论 8 字段块

## Scope 禁改
只改 17 文件（15 variant+verification.md+task_plan.md）；mini-lite-type.md 不动；主模板 task_plan.md 只加 M-13-B 一行；禁止 git add/commit；禁动 worktree 外文件

## 返回格式（8 字段，无内容填 none，8 字段后不得有任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<4> pass — 逐项原文行
files: <绝对路径>(+N/-M); ...
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:4-executor]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
