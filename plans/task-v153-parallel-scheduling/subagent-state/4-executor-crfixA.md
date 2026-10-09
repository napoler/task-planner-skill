#### [sub:CR修复A] 修复A单元 — CR V2 发现 F1-F5 收口（2026-10-09）

范围（worktree 技能根 /mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling/skills/task-planner）：
- scripts/check-plan-dispatch.sh（F1/F2/F8）
- scripts/selftest-parallel-scheduling.sh（F3/F4）
- references/critical-rules.md（F5，仅一处串替换）

落位清单：
- F1（MAJOR 组标记消费口径统一）：新增注解形态组归属兜底——awk 扫描计划内 `[parallel-group:<组名>]`
  后随「= 单元ID 列表」（逗号/顿号/全角逗号分隔，支持同前缀区间展开）的注解行，建立 单元ID→组名 映射；
  行组归属取值优先级=行内标记 >「并行组」列 > 注解兜底（并入列位解析同一映射表）。注解形态夹具
  /tmp/fix-f1.md（无「并行组」列）实测触发 hard H4；原实现（/tmp/orig-guard.sh）同夹具静默 → 修复对照成立。
- F2（MINOR awk 列位陈旧）：遇非 S-unit 表头（^| ID | 但无「执行体」，如 Goal 单元表）或空行即关闭表状态
  并清列位状态；连续两表夹具 /tmp/fix-f2.md 实测无假 H2（原实现同夹具产生 G 行假 H2，已对照）。
- F8（MINOR 裸管道列数漂移）：记录表头列数，数据行按 | 切分列数≠表头列数即标漂移 → violation
  「格式漂移/裸管道」（design §二 H2 承诺落地）；夹具 /tmp/fix-f8.md 实测触发。
- F3（MINOR 双层 SOFT 收敛）：selftest P-04/P-09 由「锚在位→硬、缺失→SOFT」收敛为硬断言，锚缺失即 FAIL；
  注释同步注明 2026-10-09 收敛原因（施工窗口结束，锚缺失=回归删除）；移除未用 soft() 助手。
- F4（MINOR 探针锚点）：P-04 hard/advisory 探针改锚可执行代码行（add_violation/echo 调用行），不再被注释
  头文字满足；负例夹具 /tmp/selftest-neg/（注释保留 + 代码行删除）实测 P-04 FAIL exit 1。
- F5（MINOR 悬空缩写）：68.5 内 `SK.md:321-345` → `dynamic-workflows SKILL.md:321-345`（仅此串，其余零改动）。

验收原文（关键行）：
- bash -n check-plan-dispatch.sh exit=0；bash -n selftest-parallel-scheduling.sh exit=0
- selftest: `Total: 9 PASS=9 FAIL=0`（exit 0）
- F1: `Rule 68.2: 依赖-同组矛盾——行 …（hard H4）`
- F2: 无 Rule 68 行（无假 H2）
- F8: `Rule 68.1: 行 … 列数漂移——…（格式漂移/裸管道，hard F8）`
- F4 负例: `P-04 FAIL …` + `Total: 9 PASS=8 FAIL=1`（exit 1）
- 真实计划（--skip-goal-check）：无 Rule 68 violation 行（零误报，exit 0）
- `grep -n 'dynamic-workflows SKILL.md:321-345' references/critical-rules.md` → 872 命中
- 净改动（vs HEAD）：check-plan-dispatch.sh 85+/15-、selftest-parallel-scheduling.sh 28+/32-、
  critical-rules.md 1+/1-

未越界：git status 仅上述三 scope 文件为本次新增改动（其余 modified 为前置单元既有改动）；无新增未跟踪文件。

open_issues: none
