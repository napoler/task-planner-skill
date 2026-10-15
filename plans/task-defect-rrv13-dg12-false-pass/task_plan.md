# task_plan — 缺陷修复：RRV-13 / DG-12 selftest 自指断言虚假覆盖（medium）

> 计划来源：dynamic-workflow 子代理缺陷修复 ask（缺陷=两条「TODO 占位注释在位即 PASS」自指恒真断言，
> 对部署位对账面/行为面 fixture 回归面零真实校验却计入 PASS 总数）。
> 本计划同时承担 task-planner 哨兵 PreToolUse 门禁的放行载体（门禁 Steps to proceed 第 1 条「创建计划」）：
> ① 本 task_plan.md mtime > 哨兵 created_epoch(1792099590) → check-scope.sh D10 仲裁放行；
> ② 同目录 `.active_plan_side/dwfdwfrun0f76fcdd63554a0f94492ca10cc.active_plan` 指向本目录
>    → check-skill-modify.sh 会话归属命中 + 下方「执行范围限制」反引号 token 授权三个目标文件。

## 目标
1. `skills/task-planner/scripts/selftest-report-reviewability.sh:221-229` RRV-13：
   自指 grep 自身文件 `TODO(RRVV-14)` 占位注释→PASS，改为诚实 WARN 跳过档（不计 PASS，注释说明跳过原因与启用条件）。
2. `skills/task-planner/scripts/selftest-decision-grading.sh:225-235` DG-12：
   自指 grep `$0` 内 `TODO(DG-13)` 注释行→PASS，同样改为诚实 WARN 跳过档。
3. `skills/task-planner/scripts/selftest-registry.tsv:67/:69` 区间登记同步标注占位跳过档（口径放大修正）。
4. 两脚本头注中 RRV-13/DG-12 的「预留骨架 PASS 档」漂移描述同步修正（旁证项）。
   约束：不改脚本其余断言/计数器/exit 语义；两脚本改后仍 exit=0；禁止 git commit/push。

## 验收
- 两脚本内自指 grep（`cnt "TODO(RRVV-14)" <自身文件>` / `cnt '^# TODO(DG-13)...' "$0"`）已移除，
  RRV-13/DG-12 以 `warn()` 输出「占位跳过…不计 PASS」，TODO(RRVV-14)/TODO(DG-13) 标记注释保留（未来启用锚）
- `bash selftest-report-reviewability.sh` → 末行 `Total: PASS=12 FAIL=0 WARN=1`，EXIT=0
- `bash selftest-decision-grading.sh` → 末行 `Total: PASS=11 FAIL=0 WARN=1`，EXIT=0
- registry :67/:69 已标注「占位跳过 WARN 档不计 PASS」
- 工作树变更仅限上述 3 个目标文件 + 本 plans/ 目录（门禁脚手架）

## 验证
1. `cd skills/task-planner/scripts && bash selftest-report-reviewability.sh; echo EXIT=$?`
2. `cd skills/task-planner/scripts && bash selftest-decision-grading.sh; echo EXIT=$?`
3. `git status --short`（范围确认）
4. Read 三处改动复核

## 执行范围限制
本任务仅允许写入以下文件（check-skill-modify 授权 token，子串匹配目标路径）：
- `selftest-report-reviewability.sh`
- `selftest-decision-grading.sh`
- `selftest-registry.tsv`
门禁脚手架（plans/ 豁免 + 运行态指针，非目标文件）：
- `task_plan.md`（本文件）
- `.active_plan_side/dwfdwfrun0f76fcdd63554a0f94492ca10cc.active_plan`（gitignore 运行态）
