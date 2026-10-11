
#### [sub:CR] 审查单元 V2 — Rule 68 全量 diff Code Review（2026-10-09）

**范围**：worktree `git diff master` 中本任务新增/改动 15 文件（skills/task-planner 下 SKILL.md / references/critical-rules.md / references/split-pattern-library.md / references/dispatch-examples.md / scripts/check-plan-dispatch.sh / scripts/selftest-parallel-scheduling.sh(新) / scripts/selftest-registry.tsv / scripts/selftest-goal-unit-goal-mode.sh / 另 5 个 selftest 计数级联 + templates/task_plan.md + CHANGELOG.md）。审查基准=design-rule68.md。

**执行证据**：65/65 selftest 全 PASS（含新 selftest-parallel-scheduling 9/9、goal-unit 9/9）；`bash -n check-plan-dispatch.sh` 语法通过；抽取守卫新段逐字复跑 6 组夹具（H1/H2/H3/H4 触发、W1 触发、注解形态静默）。
**结论：CHANGES_REQUESTED**（1 MAJOR + 6 MINOR，无 BLOCKER）。

发现清单：
1. MAJOR `scripts/check-plan-dispatch.sh:545` — 组标记消费口径不一致：H3 用全文件 grep（`grep -qF "[parallel-group:${rule68_g}]" "$PLAN_FILE"`），而 H4/W1/W2 的行组归属只来自「并行组」列或行内标记（:512 `rule68_g="$rule68_f5"`）。模板无「并行组」列（grep -c '并行组' templates/task_plan.md=0）且 21.4 允许注解行承载标记 → 注解形态下 rule68_gv 全空，H4（hard）与 W1/W2（advisory）静默失效，而 H3 可被散文标记满足。建议：H4/W1/W2 的组归属增加「注解行 `[parallel-group:X]` 引用的单元 ID 列表」解析，或模板强制「并行组」列。
2. MINOR `scripts/check-plan-dispatch.sh` awk in_tbl — 连续无空行分隔的两张表会沿用陈旧列位：第二表数据行按第一表 dep/ex 列位解析，产生假 H2。建议：遇新表头（`^| ID |`）或空行即重置/重算列位。
3. MINOR `scripts/selftest-parallel-scheduling.sh` P-04/P-09 — 双层 SOFT 逻辑自指：判定「已落位」用的锚正是被守护对象本身，anchor 被删即 SOFT（exit 不受影响）而非 FAIL，无法区分「未施工」与「回归删除」。建议：落位标志改为与锚无关的持久标记，或落位后改硬断言。
4. MINOR `scripts/selftest-parallel-scheduling.sh` P-04 — 硬/软串探针（`依赖-同组|组内全同`）命中守卫自身注释头文字，注释留存即可 PASS，断言可腐化。建议：探针锚定可执行代码行（如 add_violation 调用/echo WARN 行）而非全文。
5. MINOR `references/critical-rules.md:872` — 68.5 引证 `SK.md:321-345`，仓内无 SK.md，缩写悬空（实指 dynamic-workflows SKILL.md:321-345，经核该区间确含唯一 join 原则）。建议：写全文件名。
6. MINOR `SKILL.md:9` — 「Critical Rules 全集 1-68」枚举漏列 Rule 66/67（65 直接跳 68），且 design §四 明列「追加 66 goal 单元固化」。建议：补 66 条目。
7. MINOR `scripts/selftest-workflow-orchestration.sh:70` — WF-10 计数锚仍钉 `Critical Rules 1-65`（未随本次级联），仅因 CLAUDE.md/README_zh 残留 1-65 才 PASS。建议：同步 1-68。
另：design §二 H2 要点「单元格含裸管道按 violation 提示」未落地（守卫无裸管道检测，grep '裸管道|管道'=0）— MINOR，与知识库易错点③呼应。

负结果：未发现安全面问题（无注入/路径遍历/凭据）；无 API 破坏；无数据丢失/竞态（守卫为只读解析，仅标准/全档运行，legacy/mini 跳过）；既有校验路径未破坏（65/65 selftest 回归零失败）。
