# S2 任务书：SKILL.md 四锚联动（task-v126 Phase 2）

你是 task-v126 计划 S-unit S2 执行体。任务：对 SKILL.md 做 Rule 49 联动的五处编辑（净增 ≤10 行，行内改写优先，禁动主锚字面）。

## 路径与纪律
- 目标文件绝对路径：/home/terry/task-planner-skill-worktrees/task-v126/skills/task-planner/SKILL.md（当前 447 行）
- 禁止触碰 worktree 外任何文件；禁止改动五处之外的任何行
- 主锚红线：文件中 `Rules 1-39` 字样两处必须原样保留（不可改写为其他数字）；禁止出现新增的 `1-40` 字样
- 计划三文件（只读对齐）：/mnt/data/dev/task-planner-skill/plans/task-v126/task_plan.md、/mnt/data/dev/task-planner-skill/plans/task-v126/findings.md、/mnt/data/dev/task-planner-skill/plans/task-v126/progress.md
- 你的检查点：/mnt/data/dev/task-planner-skill/plans/task-v126/subagent-state/2-executor.md（里程碑即落盘）

## 五处编辑（先 Read 目标文件对应行段确认上下文，再逐处 Edit）

编辑甲（frontmatter references 行，约第 9 行）：该行内 `Critical Rules 全集 1-48` 改为 `Critical Rules 全集 1-49`；同一行内 `、48 交付总结可定位性与实用性` 后追加 `、49 单元线多路并行推进`（行内改写，净增 0 行）。

编辑乙（执行循环步骤 2.5 行，约第 85 行，以 `2.5 **委派检查点（强制 — Rule 25）**` 开头的长行）：行尾追加以下文字（行内追加，净增 0 行）：
；**验收后推进检查（Rule 49）**：每完成一个 S-unit 验收（22.5 三证据），立即核对该单元线下一工序是否满足推进三条件（49.2 已验收+前置在位+独立性四问），满足即派发不等批（跨 Phase 前移按 49.3 双登记，汇合点按 49.4① 等齐）

编辑丙（合规清单 C33 行后，约第 199 行）：C33 行（以 `| C33 |` 开头）之后插入新行（净增 1 行）：
| C34 | 单元线推进检查（Rule 49）：多单元线任务每个跨 Phase 前移已过推进三条件（已验收/前置在位/独立性四问）并双登记（Lane 表或 progress [advance] 行）；汇合点工序已等齐上游验收；单单元线任务登记豁免理由（机器面=selftest-lane-advancement 静态断言，推进核查人工；mini 档豁免） | ☐ |

编辑丁（Critical Rules 摘要列表，约第 282 行，`- **Rule 47（媒体制作任务派发纪律 — task-v122）**` 行后）：插入新行（净增 1 行）：
- **Rule 49（单元线多路并行推进 — task-v126）**：可枚举生产单元×序贯工序任务族启用 lane 模型（49.1）；推进三条件=已验收+前置在位+独立性四问（49.2）；满足即派发不等批、跨 Phase 前移双登记、Phase 翻转语义不变（49.3）；汇合点强串行+单写者/单 S-unit 不变（49.4）；零新 config 键+selftest-lane-advancement.sh 守护（49.5）

编辑戊（References 表，约第 306 行，以 `| \`references/critical-rules.md\` |` 开头的行）：行内 `Rule 48 交付总结可定位性与实用性）` 改为 `Rule 48 交付总结可定位性与实用性 / Rule 49 单元线多路并行推进）`（净增 0 行）。

## 验收自查（执行后必须跑并贴输出）
- grep -n 'Rule 49' 目标文件 命中 ≥4 处（:9 区域/:85 括注/:199 C34/:282 bullet/:306 References）
- grep -c 'Rules 1-39' 目标文件 = 2（主锚不动）
- grep -c '1-40' 目标文件 = 0
- wc -l 目标文件 = 449（447+2）
- cd /home/terry/task-planner-skill-worktrees/task-v126 && git diff --stat 仅 SKILL.md 一文件
- 结果写入检查点 2-executor.md

## 返回格式（8 字段严格模板）
status: done|partial|failed
summary: 一句话产出
files_changed: 绝对路径清单
acceptance: 验收自查命令与结果
evidence: 关键输出原文粘贴
issues: 无或问题清单
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v126/subagent-state/2-executor.md
next: 建议下一步
