# 7-executor checkpoint — task-v118 selftest-dispatch-grain.sh 守护脚本 + registry 登记

status: done
date: 2026-10-03

## 任务
1. 新建 `skills/task-planner/scripts/selftest-dispatch-grain.sh`（守护 Rule 46 条款锚 + check-dispatch.sh 守卫②④收窄行为，GR-01..GR-09 共 9 断言）
2. `skills/task-planner/scripts/selftest-registry.tsv` 追加一行登记

## 结果
- 新 selftest: `Total: 9 PASS=9 FAIL=0` exit 0
- GR-07 fixture: 任务书含 S1/S2 → `exit 2` + stderr「任务书检出 2 个 S-unit ID（Rule 46.2 任务书豁免收窄）」
- GR-08 fixture: 任务书 6 个行首 markdown 编号 → `exit 2` + stderr「步骤枚举超限(6>4)」
- GR-09 fixture: 自由 prompt 6 个行首编号（无「任务书」双条件）→ `exit 0` 静默（自由口径不拦，46.2 边界）
- registry: `Total: 5 PASS=5 FAIL=0 (registry rows=43, actual selftest=43)` exit 0（T02 无缺失 43+1=44 行全登记，含表头 44）
- 抽查 selftest-dispatch.sh: `Total: 31 PASS=31 FAIL=0` exit 0
- 抽查 selftest-veto.sh: `Total: 13 PASS=13 FAIL=0` exit 0

## 关键实现决策
- fixture prompt 骨架（mk_prompt）：三文件绝对路径 + status:/acceptance:/checkpoint: + subagent-state/ 字面，过 scan_missing 七项缺项扫描，隔离测 ②④（范式=SG-06 PBOOK）
- GR-07/08 任务书引用行用 ASCII 括号闭合 `按落盘任务书执行(任务书: <path>)`，与 check-dispatch.sh ②③ sed 去尾标点类 `[),。，；;「”]` 对齐，保证提取路径 -f 命中
- 每断言前 `rm -f .dispatch-inflight` + sid 带 `$$-$RANDOM`，防串行槽锁跨断言串扰
- GR-06 锚定实际实现 `count_step_markers "$tb" tb`（check-dispatch.sh:373）
- 头注释三段式（校验面/档位/依据）+ Rule 45 双层注释标准（What+Why）

## worktree git status（2026-10-03）
```
M skills/task-planner/scripts/selftest-ask-default-timeout.sh   ← 非本任务改动（他工作流预存）
M skills/task-planner/scripts/selftest-plan-tier.sh             ← 非本任务改动（他工作流预存）
M skills/task-planner/scripts/selftest-registry.tsv             ← 本任务
?? skills/task-planner/scripts/selftest-dispatch-grain.sh       ← 本任务
```
本任务仅动 2 个文件；其余 2 个 M 为预存变更，未触碰。

## 负结果排查（registry T02 曾报 44 行？）
registry 输出 `registry rows=43, actual selftest=43`：TSV 表头 1 + 数据 43 = 44 行；任务书「42+1=43」指数据行 43 全部登记，T02/T03/T04 全 PASS 无缺失无孤儿。
