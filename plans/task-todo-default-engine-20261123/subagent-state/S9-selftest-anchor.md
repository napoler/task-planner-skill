# S9 checkpoint — selftest 守护加锚（B6 引擎检测）

## status
COMPLETE（改动完成、实跑验证通过、无阻塞）

## acceptance
全部满足：
1. selftest-skill-collab.sh 新增 B6 引擎检测锚断言组（T13a/T13b），沿用脚本既有 `t "<描述>" <command>` 框架与 `$ROOT` 变量，未自创语法。
2. 头部断言计数注释已更新（陈旧 19 → 实态 27，并说明校正原因）。
3. selftest-registry.tsv 第 23 行 trigger_scenarios + dep_anchors 两列均补 B6 引擎检测锚，保持 TSV 4 列 tab 分隔。
4. 只修改任务书指定的 2 个文件；未新增守护脚本。
5. 实跑 selftest：exit 0，27/27 PASS（含新增 T13a/T13b）。
6. 依赖锚时序：S2/S3 的 B6 落盘已确认在位，新增断言当前 PASS，无需强行改断言。

## files
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh  (+11 / -1)
  - L5-L7：断言计数注释由「10 组 T1-T10，共 19 断言」校正为「13 组 T1-T13，共 27 断言」，并附 2026-11-23 task-todo-default-engine-20261123 S9 校正说明（旧 19 为 T11/T12 加入前陈旧值；实测基线 25，加 T13 两项后 27）。
  - L114-L120：新增 T13 组（B6 引擎检测锚守护），含 What+Why 双层注释（双载体理由、路径解析依据）；两条断言：
    - `t "T13a todo-sync 含 B6 引擎检测" grep -q 'B6' "$ROOT/references/todo-sync.md"`
    - `t "T13b Rule106.5 含 B6" grep -q 'B6' "$ROOT/../task-discipline/references/critical-rules-discipline.md"`
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv  (+1 / -1)
  - L23：trigger_scenarios 追加「/ B6 引擎检测锚（todo-sync.md 或 Rule 106.5）改动」；dep_anchors 追加 `;references/todo-sync.md;../task-discipline/references/critical-rules-discipline.md`（原有三项保留，无重复）。

仅上述 2 文件由本单元改动；`git diff --stat` 限定两文件输出：`2 files changed, 12 insertions(+), 2 deletions(-)`。

## evidence
命令 1（基线，改动前）：
```
cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/selftest-skill-collab.sh
```
原始输出尾部：
```
[PASS] T12a collab 矩阵 research-assistant 行
[PASS] T12b collab 矩阵 browser-use 行
Total: 25  PASS=25  FAIL=0
RC=0
```

命令 2（依赖锚落盘核验）：
```
grep -n 'B6' skills/task-planner/references/todo-sync.md
grep -n 'B6' skills/task-discipline/references/critical-rules-discipline.md
```
原始输出关键行：
```
todo-sync.md:35: ...B6 引擎检测/B7 对齐/B8 worktree 核验...
todo-sync.md:36: ...B6 建 todo 时检测引擎适配性（OpenSpec 规格化/Superpowers 方法论），结论落盘 Decisions...
todo-sync.md:37: ...B6 未留痕=不得声称按专业引擎推进...
todo-sync.md:40: ...B6/B7/B8 同步见 Rule 106.5（task-discipline）语义锚
critical-rules-discipline.md:748: ...**B6** 引擎适配性检测（建 todo 时判断是否适用 OpenSpec 规格化/Superpowers 方法论技能，结论落盘 Decisions）...
critical-rules-discipline.md:750: ...B6 未留痕=不得声称按专业引擎推进...
```
结论：S2/S3 锚已落盘；新增断言在任何时序下均基于真实在位锚，PASS 合法。

命令 3（registry 结构核验，改动后）：
```
awk -F'\t' 'NR==23{print "NF=" NF; for(i=1;i<=NF;i++) printf "COL%d=[%s]\n", i, $i}' skills/task-planner/scripts/selftest-registry.tsv
```
原始输出：
```
NF=4
COL1=[selftest-skill-collab.sh]
COL2=[协同路由面]
COL3=[skill-collaboration.md 条款措辞改动 / B6 引擎检测锚（todo-sync.md 或 Rule 106.5）改动]
COL4=[../plan-collab-router/references/skill-collaboration.md;references/critical-rules.md;config.json;references/todo-sync.md;../task-discipline/references/critical-rules-discipline.md]
```

命令 4（终验 selftest，改动后）：
```
cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/selftest-skill-collab.sh
```
原始输出尾部：
```
[PASS] T12a collab 矩阵 research-assistant 行
[PASS] T12b collab 矩阵 browser-use 行
[PASS] T13a todo-sync 含 B6 引擎检测
[PASS] T13b Rule106.5 含 B6
Total: 27  PASS=27  FAIL=0
RC=0
```

命令 5（语法 + 范围核对）：
```
bash -n skills/task-planner/scripts/selftest-skill-collab.sh
git diff --stat -- skills/task-planner/scripts/selftest-skill-collab.sh skills/task-planner/scripts/selftest-registry.tsv
```
原始输出：
```
syntax OK rc=0
 skills/task-planner/scripts/selftest-registry.tsv    |  2 +-
 skills/task-planner/scripts/selftest-skill-collab.sh | 12 +++++++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)
```

## checkpoint
本文件即 S9 checkpoint（路径：plans/task-todo-default-engine-20261123/subagent-state/S9-selftest-anchor.md）。里程碑=改动完成 + 27/27 PASS 终验通过。无断点续跑需求。

## findings_written
发现 1（已在本 checkpoint 与返回中如实记录，未改动范围外文件）：任务书第 7/16 行假设脚本为「T1-T10 共 19 断言」，但真实脚本已含 T11（task-v080 网络调研，4 项）与 T12（2 项），基线实测 25 断言；头部注释「19 断言」为陈旧值。处置：新组命名 T13（避开与既有 T11/T12 冲突），计数按实态校正为 27，并在注释中写明校正原因。未擅自改 selftest 中任何既有断言。

发现 2：无基线 FAIL（基线 25/25 PASS），无与本次改动无关的遗留失败项。

未另写 findings 报告文件（任务书未要求；仅写本 checkpoint）。

## blockers
无。

## confidence
高。理由：改动完全落在 2 个指定文件内；断言沿用脚本既有框架与变量；终验 27/27 PASS 且 rc=0；bash -n 通过；registry 4 列结构与去重已核验；B6 依赖锚在位已由第一手 grep 证据确认。
