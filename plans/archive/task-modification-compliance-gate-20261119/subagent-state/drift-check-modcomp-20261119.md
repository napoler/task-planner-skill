# Drift Check — task-modification-compliance-gate-20261119

- time: 2026-11-19
- trigger: independent goal-alignment three-state check (post-change, worktree dirty set review)
- task_id: task-modification-compliance-gate-20261119
- checkpoint: /mnt/data/dev/task-planner-skill/plans/task-modification-compliance-gate-20261119/subagent-state/drift-check-modcomp-20261119.md

## 判定
- **status: ALIGNED**
- P0: 无
- P1: 无
- P2/info: plan bookkeeping 未完全回填（不构成改动偏移）

## 需求锚对照（Rule 80/51.1 双源）
- R1 原话锚（权威，来自 findings.md:12 Requirements）：用户逐字「核心问题就是 为什么会将一个原本有理有据的 模型能力限制 被恶意的修改了这才是关键 必须解决这个问题 也就是修改是否合规 连合规性都没有就做恶意修改 只会导致投毒 破坏原本可以正确任务被恶意篡改 我的目的以后不会出现这种 合规性都没有就做恶意修改」→ 诉求=通用“修改前合规论证+授权”硬门，杜绝无依据放宽/投毒。
- task_plan.md:20-21 仍为模板占位 `<用户原话第 1 条...>`（R1/R2 未逐字回填）；task_plan.md R→VC 映射仅示例 VC-1 (task_plan.md:23-26)。findings.md:12 与本单元目标/改动一致承载 R1。
- user-session-log.md:11-17 无真实 `## #N` 数字条目，仅格式示例行；无逐字原话可对照（证据不足点，非改动漂移）。
- progress.md:15 Phase 1 in_progress、Actions/Files/Test Results 为空占位（progress.md:18-26）。

## 证据面（git + 逐文件盘上取证）
- git 脏集（worktree /mnt/data/dev/task-planner-skill/tmp/worktrees/task-modification-compliance-gate-20261119）：`M skills/task-discipline/references/critical-rules-discipline.md`、`M skills/task-dispatch/references/critical-rules-dispatch.md`、`M skills/task-planner/SKILL.md`、`M skills/task-planner/references/critical-rules.md`；`git diff --stat`=4 files, 6 insertions(+), 3 deletions(-)；无新增脚本/无 config 变更。
- 1) 74.7 通用修改合规门（四元组+无依据放宽 P0+与 51.15 分工）：skills/task-discipline/references/critical-rules-discipline.md:494 新增 `74.7 **通用修改合规门...**`（紧随 74.6:493），登记合规四元组（对象+当前值verbatim→拟变更值+依据+影响评估+处置）、`无依据放宽=禁止落地（P0）`、删下界/抬上界/改单边/软豁免均属放宽→`[MODIFICATION NON-COMPLIANT]`、STOP→授权→登记→(命中基线按51.15)重attest、先过74.7再判叠加51.15、禁“先改后补”、零新脚本零新config；74.6 原文保留:493。
- 2) 51.15 跨域指针+登记前置强化：skills/task-planner/references/critical-rules.md:109 在原 51.15 段尾追加“登记前置强化：…候选约束逐条登记…无基线候选须显式写 `none-justified`，禁静默遗漏”+“通用修改合规门跨域指针：…先过纪律域 Rule 74.7…互补，禁以‘未登记’为由绕过合规论证”；原双向显式铁律/四环绑定文本保留为前缀（diff 为同段扩展）。
- 3) SKILL 执行期改规范必补合规四元组 + 51.15 联动：skills/task-planner/SKILL.md:122 在 2.5d 变更类型判定下新增要点“通用修改合规门（Rule 74.7，P0）…落地前必须先补『📋 变更标注表』合规四元组…无用户逐字授权+证据的放宽禁落地；若命中🔒规范基线同步走 51.15 STOP→授权→Decisions→更新→重attest。禁‘先改后补’…”。
- 4) dispatch 22.4e 执行体禁自行改规范口径、回传主进程：skills/task-dispatch/references/critical-rules-dispatch.md:66 原 22.4e 段尾追加“执行体禁自行改规范口径（Rule 74.7 派发面联动）：…禁止自行落地，须回传主进程按 74.7 合规四元组 +（命中基线则）51.15 路径处置…子代理就地放宽=`[MODIFICATION NON-COMPLIANT]`（P0）”；原“禁止子代理自行重建/转译/放宽基线”文本保留。
- 5) 106.7 通用放宽判据延伸：skills/task-discipline/references/critical-rules-discipline.md:757 原 106.7 末句后追加“通用放宽判据（Rule 74.7 纪律域，本门延伸）：区间约束缺上下界（如仅 `≤上限` 无 `≥下限`）或引入‘超拍登记/NOTE 保留/叙事必要’类软豁免，等同无依据放宽，按本门 STOP——不限于已登记基线，适用于所有已确立规范/阈值/区间。”

## 判据核对
- (1) 覆盖取证 C2 最小修复面：满足（74.7 四元组@discipline:494；51.15 跨域指针+none-justified 登记前置@planner-critical-rules:109；SKILL 2.5d 执行期回填+51.15 联动@SKILL.md:122；dispatch 22.4e 执行体回传禁自行改口径@dispatch:66；106.7 通用放宽判据@discipline:757）。
- (2) 命中用户核心诉求/无范围漂移：满足——建立修改前合规论证+授权硬门并 P0 禁无依据放宽/就地放宽/单边与软豁免，直指“合规性都没有就做恶意修改→投毒”；改动仅上述 4 个规则/技能文本文件，未见改 A 却改 B 的范围漂移。
- (3) P0 级问题：① 内部矛盾未见（74.7↔51.15 互补分工一致：先过74.7再判叠加51.15；106.7 延伸与 74.7 口径一致；22.4e/SKILL 联动路径一致）。② 编号撞号未见——`74.7` 仅 discipline:494 一处，`74.6` 仍在:493，`106.7` 仍唯一在:757（仅段尾扩展）。③ 既有条款原文未删改——git diff 显示 22.4e/106.7/51.15 为同段前缀保留+尾部追加（`-`旧行内容完整包含于`+`新行前缀），74.7 与 SKILL 要点为纯新增行；未见删除既有条款。④ 零新脚本/零新 config 键：满足（仅 4 个 .md 文本改动）。
- (4) 计划三文件与改动目标对齐：目标/知识/取证（findings.md:12,28-34; knowledge-brief.md §2-§4; forensics/modification-compliance-gap-20261119.md C2/C3）均指向通用修改合规门与 C2 修复面，实际改动逐项落地；task_plan.md R1/R2/VC/Phase 仍模板占位、progress 未回填属计划簿记状态（P2/info），非需求或改动方向漂移。

## 建议
- 主进程后续按 Rule 51.1/80 将 task_plan.md R1/R2 逐字回填并补 user-session-log 真实 #N 条目、R→VC 映射与 progress 证据，以闭合簿记面；不影响本次文本改动对齐结论。
