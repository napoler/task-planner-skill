# 08-exec-p9 checkpoint（task-v074 P9 两个修复项）

- 执行时间: 2026-09-16
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v074-p9
- 分支变更: 7 文件 modified，未 commit（遵守禁止 commit 约束）
  git status: M SKILL.md / M references/batch-quality-gate.md / M references/critical-rules.md / M scripts/check-complete.sh / M scripts/selftest-template-lifecycle.sh / M templates/batch_report.md / M templates/variant/rule-enhancement-type.md

## 项 1: Rule 34.2 三点同步 → 四点同步（补 template-guide.md 第 4 落点）

改动点（共 6 处 + selftest 3 处）:
1. references/critical-rules.md :286 — 34.2 同步纪律「三点同步——…SKILL.md 模板节」→「四点同步——…SKILL.md 模板节、template-guide.md 变体表与计数」
2. references/critical-rules.md :288 — 34.4「完成 34.2 三点登记」→「完成 34.2 四点登记」
3. SKILL.md :216 — 「提炼新 variant 模板入库+三点同步」→「…+四点同步」（行内替换，wc -l 保持 535）
4. SKILL.md :301 — 「三点同步(34.2)」→「四点同步(34.2)」且「模板+三点同步」→「模板+四点同步」（行内，未增行）
5. templates/variant/rule-enhancement-type.md :37 — 「如涉三点同步」→「如涉四点同步」；:60 — 「三点同步 + 全量回归」→「四点同步 + 全量回归」
6. scripts/selftest-template-lifecycle.sh — TL-03 断言改为四点：grep 34.2 行须含 四点同步 + template-mapping + plan-writer + template-guide 四关键词（label 同步改「34.2 四点同步」）；头部注释 TL-03 行与「16 断言」→「17 断言」并补 TL-17 注释行（编号接续）；新增 TL-17: references/template-guide.md 含 `rule-enhancement` 且含「13 个」（四落点防腐化计数锚）；Total 断言数由 16→17

自测证据:
- bash scripts/selftest-template-lifecycle.sh → Total: 17 PASS=17 FAIL=0, EXIT=0（TL-17 PASS「template-guide.md 含 rule-enhancement 且计数 13 个」）
- grep -rn "三点同步\|三点登记" critical-rules/SKILL/rule-enhancement-type/selftest → 无命中（exit 1）；全 worktree skills/ 内无残留
- wc -l SKILL.md = 535（不变）
- references/template-guide.md 计数核查: :60 「5 核心 + 3 辅助 + 13 variant = 21 个模板」为 P8 已修正值，无 11/12 个残留漂移

## 项 2: Batch Report 零单元逃生（Rule 18.6 门控）

改动点:
1. scripts/check-complete.sh python 块（:221-241 段）— 提取 Batch Report 段文本后新增判定：段内含「不适用」且含「无批量」→ batch_missing 保持 []（跳过 8 字段校验，合法零单元声明）；否则维持既有 8 字段逐字校验（fail-closed 不变）。注释锚 `[2026-09-16 task-v074 P9 Rule 18.6 零单元逃生]`
2. templates/batch_report.md 头部注释区 +1 行：「零单元任务可整段声明一行：`不适用（无批量生成单元）`，跳过 8 字段校验（check-complete.sh Rule 18.6 逃生，2026-09-16）」
3. references/batch-quality-gate.md — 18.6 行后就近 +1 行引用块说明（零单元逃生语义 + fail-closed 保留）

行为级自测（/tmp 最小计划夹具，参照 selftest-vc-gate.sh 构造方式: findings/progress 非 stub + Handoff 表 + 全 Phase complete + 完整 VC5 表，Batch Report 段为唯一变量）:
- case1: 段仅一行「不适用（无批量生成单元）」→ 输出无 "Batch Report" 行（grep -c = 0），ALL PHASES COMPLETE 正常输出，零单元逃生命中
- case2: 段存在但无 8 字段且无不适用声明（仅一行占位文字）→ 输出 `[plan] Batch Report incomplete (Rule 18.6) — missing: total, success, failed, failure_rate, sampled_pass, sampled_fail, pre_check, rollback_point` → fail-closed 保持
- case3: 八字段模板形式（`| \`field\` | value |`）齐全 → 输出无 Batch Report 不完整行，`ALL PHASES COMPLETE (2/2)`（无 8 字段缺失告警；rc=1 由后续 delegation 检查环节产生，与 Batch 门控无关，三 case 同态）
- bash -n scripts/check-complete.sh → OK
- bash scripts/selftest-vc-gate.sh → Total: 11 PASS=11 FAIL=0（不回归）
- /tmp 夹具目录（/tmp/batch-case.*）已清理

## 恢复点
若需重跑: 所有改动已完成且自测通过，无半成品；commit 由主进程合并回阶段执行（本项禁止 commit）。
