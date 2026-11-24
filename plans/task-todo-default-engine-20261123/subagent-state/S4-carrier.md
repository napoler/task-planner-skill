# S4 完成检查点 — 三层载体：sync-todos.sh 产出器 + task_plan 模板露出

日期：2026-11-23
任务书：`plans/task-todo-default-engine-20261123/subagent-state/S4-task.md`

## 1. status
PASS（全部 4 项验收实跑通过，另加 2 项混合/回归验证通过）

## 2. acceptance
| 项 | 命令 | 结果 |
|----|------|------|
| A1 | `bash -n skills/task-planner/scripts/sync-todos.sh` | exit 0 |
| A2 | `bash skills/task-planner/scripts/sync-todos.sh --json plans/task-todo-default-engine-20261123` | 输出含 B1…B8 八个 task_id；python3 解析 `baseline_count=8`，`baseline_ids=B1,B2,B3,B4,B5,B6,B7,B8`，`baseline_fields_ok=True` |
| A3 | `grep -n 'B6\|B7\|B8' skills/task-planner/templates/task_plan.md` | 命中 469/470/471 三行，exit 0 |
| A4（附加） | 混合 fixture（phase entries + baseline）`--json /tmp/s4-fixture/plans` | `total_entries=9`（1 phase + 8 baseline），JSON 合法，逗号拼接正确 |
| A5（附加） | human 模式 `bash sync-todos.sh /tmp/s4-fixture/plans` | 输出不含 B 组，主流程行为未变 |

## 3. files
| 文件 | 行数变化（git numstat） | 改动摘要 |
|------|------------------------|---------|
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh` | +21/-1 | ① `--help` 增 1 行说明 `--json` 含 B1-B8；② JSON 输出分支前构造 `baseline_entries`（B1-B8，字段 `task_id`/`phase`/`status`/`subject`，phase=0，status=baseline）+ 空组保护拼接，仅替换 `echo "[$json_entries]"`，未动 task entries 构造（原 156-198 行）与主流程 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md` | +4/-0 | 在 `> 契约详见 ...todo-sync.md` 引用行前插入基线组清单锚（B1-B8 全列 + B6/B8 门禁 + 缺失=S3 当次重建），`{{TASK_PLANNER_ROOT}}` 变量未破坏 |

## 4. evidence（命令 + 原始输出行）
```
===== [1] bash -n =====
bash_n_exit=0

===== [2] --json RAW OUTPUT =====
[{"task_id":"B1","phase":0,"status":"baseline","subject":"修改后验证"},{"task_id":"B2","phase":0,"status":"baseline","subject":"Phase翻转校验"},{"task_id":"B3","phase":0,"status":"baseline","subject":"终验VC复验"},{"task_id":"B4","phase":0,"status":"baseline","subject":"收尾回读"},{"task_id":"B5","phase":0,"status":"baseline","subject":"Todo终态"},{"task_id":"B6","phase":0,"status":"baseline","subject":"引擎检测"},{"task_id":"B7","phase":0,"status":"baseline","subject":"对齐核查"},{"task_id":"B8","phase":0,"status":"baseline","subject":"worktree核验"}]

===== [2b] python3 parse =====
total_entries=8
baseline_count=8
baseline_ids=B1,B2,B3,B4,B5,B6,B7,B8
baseline_fields_ok=True
py_parse_exit=0

===== [3] grep template =====
469:**基线组 B1-B8（S1 建组必含，B1-B5 逐字保留）**：
470:B1 修改后验证 / B2 Phase翻转校验 / B3 终验VC复验 / B4 收尾回读 / B5 Todo终态 / B6 引擎检测（OpenSpec/Superpowers）/ B7 对齐核查 / B8 worktree核验。
471:门禁：B6 未留痕不得声称按引擎推进；B8 未勾实现类不得直接改主树；缺失=S3 当次重建。
grep_exit=0

===== [4] --help =====
Usage: sync-todos.sh [--json|--index] [/path/to/plans/dir]
  (default)  emit Phase→Todo sync report (human, or machine via --json)
             --json also emits the B1-B8 baseline group (task_id/phase/status/subject)
  --index    write plans/INDEX.md cross-task registry + print summary
             (the resume entry point: read INDEX.md to see what needs processing)

===== [5] mixed case (1 phase + baseline) =====
[{"task_id":"task-s4-concat-fixture","phase":1,"status":"in_progress","subject":"task-s4-concat-fixture/Phase 1: 冒烟阶段"},{"task_id":"B1","phase":0,"status":"baseline","subject":"修改后验证"},...B8]
total_entries=9
baseline_count=8
baseline_fields_ok=True

===== [6] human mode =====
[sync-todos] task-s4-concat-fixture | Phase 1 | in_progress | task-s4-concat-fixture/Phase 1: 冒烟阶段
[sync-todos] Total: 1 phases to sync
```
（[5] 原始输出见本文件 evidence 省略号处仅为此处摘要；实跑完整原文见工具输出记录。）

## 5. checkpoint
- 检查点路径：本文件（S4-carrier.md）
- 落盘时机：两个文件 Edit 完成 + 回读锚点 + 全部验收命令实跑通过后立即落盘
- 回读锚点：sync-todos.sh 第 200-223 行（基线构造块）；task_plan.md 第 469-473 行（清单锚 + 契约引用行）
- 状态：complete，可断点续接（无需重做）

## 6. findings_written
无额外 findings 文件；全部结论直接写入本检查点与最终 8 字段返回。未改动任务书之外的任何文件。

## 7. blockers
无。

## 8. confidence
高。依据：bash -n exit 0；python3 json.load 成功解析且 baseline_count 精确等于 8（空 phase 组与混合组两种路径均验证）；模板 grep 命中；human 模式回归未变；git numstat 确认仅 2 个目标文件变更（+21/-1、+4/-0）。
