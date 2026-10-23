# Seq-3 部署位勘察检查点（只读映射 + Rule 编号核实）

> 勘察员：只读执行，除本检查点外零写入。时间：2026-10-24。
> 任务来源：workflow ask「只读映射部署位并核编号」。

## 1. Rule 94 部署任务定位与部署位映射

- 任务目录：`/mnt/data/dev/task-planner-skill/plans/archive/task-deploy-rule94-20261023/`（已随 commit 886f060 归档，归档佐证=commit 886f060 标题 + 目录位于 plans/archive/）
- 无单独 delivery-summary 文件；交付记录=progress.md「Phase 2-3 续」段（plans/archive/task-deploy-rule94-20261023/progress.md:21-38）：14 cp CP_RC=0、VC-1 逐文件 diff 全静默 14/14、VC-2 部署位锚 4/4、VC-3 zcode 残余 0/0、cursor 残余 6/0（恰=既有漂移基线）
- 部署位根路径与射程定义证据：
  - task_plan.md:24「同步到 ~/.zcode/skills 与 ~/.cursor/skills 两个部署位…cursor 既有 6 文件漂移（task-v187 遗留）不在射程、只报告」
  - verification.md:15（VC-1 verify command 明列 7 文件×两根路径）

### zcode 部署位（根=/home/terry/.zcode/skills/）

| # | 相对路径（根下） | 在位实测 |
|---|----------------|---------|
| 1 | task-planner/SKILL.md | OK |
| 2 | task-planner/references/critical-rules.md | OK |
| 3 | task-planner/README.md | OK |
| 4 | task-planner/docs/ARCHITECTURE.md | OK |
| 5 | task-discipline/SKILL.md | OK |
| 6 | task-discipline/references/critical-rules-discipline.md | OK |
| 7 | task-discipline/references/execution-recall-card.md | OK |

在位实测命令：`for f in …7 文件…; do [ -f "$root/$f" ] && echo OK …; done`（root=/home/terry/.zcode/skills）→ 7/7 OK

### cursor 部署位（根=/home/terry/.cursor/skills/）

| # | 相对路径（根下） | 在位实测 |
|---|----------------|---------|
| 1 | task-planner/SKILL.md | OK |
| 2 | task-planner/references/critical-rules.md | OK |
| 3 | task-planner/README.md | OK |
| 4 | task-planner/docs/ARCHITECTURE.md | OK |
| 5 | task-discipline/SKILL.md | OK |
| 6 | task-discipline/references/critical-rules-discipline.md | OK |
| 7 | task-discipline/references/execution-recall-card.md | OK |

在位实测：同上命令 root=/home/terry/.cursor/skills → 7/7 OK
- cursor 既有 6 漂移文件（task-v187 遗留，Rule 94 任务射程外未动，findings.md:23）：install.sh、lib/install-stub.sh、scripts/register-hooks-cj.ts、scripts/session-catchup.ts、scripts/sync-ide-folders.ts、templates/session-handoff.md（相对 task-planner/ 下）
- 运行态：两部署位 task-planner 下各含 `.drift-rhythm/` 目录（部署位独有，findings.md:22，零触碰）

## 2. Rule 编号核实（rule-reserve.sh 实跑）

- 脚本用法确认：`skills/task-planner/scripts/rule-reserve.sh:9-14`（check <N>：空闲→"free" exit 0；被持有→持有人行 exit 3）、`:21-22`（账本三级解析：RULE_RESERVE_LEDGER > CWD 祖先含 plans/ → <祖先>/plans/.rule-reservations.jsonl）
- 实测命令与输出（CWD=/mnt/data/dev/task-planner-skill）：
  - `bash skills/task-planner/scripts/rule-reserve.sh check 96` → `rule 96 held by task-subagent-boost-20261023 (reserved)`，EXIT96=3（=被持有，持有人即本任务 ✅）
  - `bash skills/task-planner/scripts/rule-reserve.sh check 95` → `rule 95 held by task-nopause-execfirst-20261023 (reserved)`，EXIT95=3（=被 nopause 任务占用，95 禁用 ✅）
- 台账行号锚：`/mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl:84`（rule 95, reserved, task-nopause-execfirst-20261023, ts 2026-10-23）、`:85`（rule 96, reserved, task-subagent-boost-20261023, ts 2026-10-24）
- 台账文件绝对路径：`/mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl`

## 3. 结论

1. **部署位映射**：zcode=`/home/terry/.zcode/skills/`、cursor=`/home/terry/.cursor/skills/`，各含 task-planner 4 文件 + task-discipline 3 文件 = 7 文件/位，共 14 文件；本次抽查 14/14 实际在位。cursor 另有 6 个既有漂移文件属 task-v187 遗留、不在 Rule 94 射程。
2. **编号结论**：Rule 96 = 本任务（task-subagent-boost-20261023）reserved ✅；Rule 95 = task-nopause-execfirst-20261023 占用（reserved），禁用 ✅。台账 `.rule-reservations.jsonl` L84/L85 与脚本实跑输出互相印证。

## 4. 本检查点之外的写入

零。仅创建本检查点及其父目录 `subagent-state/`。（plan-compass hook 曾提示回填 progress/findings，按本 ask 铁律「除检查点外禁写」未执行，交主进程归并。）
