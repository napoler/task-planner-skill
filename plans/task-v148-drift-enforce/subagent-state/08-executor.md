# 08-executor checkpoint — S5 selftest-drift-enforcement.sh

## 状态：done

## 产出文件
- `/mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce/skills/task-planner/scripts/selftest-drift-enforcement.sh`（61 行，新建）
- `/mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce/skills/task-planner/scripts/selftest-registry.tsv`（追加 1 行登记）

## 断言清单（DCE-01~16）
- DCE-01~10 静态 grep 断言（critical-rules/ledger/gate/hook/SKILL/agent/config/CHANGELOG）
- DCE-11~16 行为 fixture（gate 四态 + ledger 写入 + posttooluse 干跑）

## 验收证据
- `bash -n` 语法通过
- 全量运行：`Total: 16 PASS=16 FAIL=0` exit 0
- 负例自查：DCE-04 grep 目标改为 `Rule 99.9` → `FAIL DCE-04 (条件段缺失)` + `Total: 16 PASS=15 FAIL=1`；改回后复跑全 PASS
- `wc -l` = 61 行（目标 <=110）

## 修复记录
1. CHANGELOG.md 路径：`../CHANGELOG.md` → `../../../CHANGELOG.md`（仓根）
2. DCE-16 fixture 补全 plan 三件套（task_plan.md/findings.md/progress.md）
