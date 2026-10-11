# 034-code-reviewer-s14 — Phase 6 CR Gate（task-v170 归档机制）

范围: worktree /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans, diff 618df79..ebdf4f4 (32 文件, 全 skills/task-planner/**)
PATH NOTE: 任务书写 task-v070/v070, 磁盘实为 task-v170 (worktree HEAD=ebdf4f4 匹配范围末端, 计划目录同名) — 已按实态执行。

## (a) 安全性与正确性 — PASS
- archive-plan.sh guard_reason (scripts/archive-plan.sh:88-123) fail-closed: missing-src/active-pointer(全局+side)/live-owner(mtime<1440)/status-none/status-incomplete 全拒绝; 幂等仅 archive 目标准入 (L141-144)。
- Status 判据=全 `- **Status:**` 行 equal 计数且 total>0 (L113-121), 禁 grep -m1 已落实。
- 无数据丢失窗口: do_archive (L126-135) git 跟踪→`git mv`, 未跟踪→`mv` 同 FS rename; mkdir -p archive 先行; 批量任一 FAIL→exit 1 (L210-212)。
- 权威契约对照 progress.md Phase 2 段五条: 逐条命中 (CLI/守卫/执行/批量/退出码)。

## (b) 契约符合 — PASS
- SKILL.md 接入 (SKILL.md:185 终验交付段, check-complete exit 0 后归档步骤) 与 Rule 81.1 一致; C56 行在位 (SKILL.md:247)。
- [ARCHIVE-GATE] 恒 exit 0 未被绕过: gate 段 check-complete.sh:1606-1660 仅 printf, 不改 python_rc; `exit $python_rc` (check-complete.sh:1664) 原样保留; python_rc 定义于 :411, gate 后零赋值。

## (c) 级联完整性 — PASS
- SKILL.md 实值 559 (wc -l), 钉值 584 = 实值+25 先例, 4 钉文件 (batch-pilot/drift-check-subagent/knowledge-brief/execution-stability/skill-collab) 一致。
- `1-(7[4-9]|8[01])` 三处锚 (SKILL.md:9/:314/:406) 实测命中=3, AD-04 ≥3 满足; 负样本 82/90 属越界不放开 (8[01] 精化)。
- AD-12 pin 字面在 tool-selection/requirement-coverage/lane-advancement 三文件在位 (grep -cF ≥3); self-resolution 两臂字面按现态 pin 并留 cascade 注释 (selftest-absorption-discipline.sh S10p)。
- registry 锚校准一致: selftest-registry.tsv C35→L225 / Rule51 bullet→L356 与 SKILL.md 实态 grep 一致 (sed -n '225p;356p' 命中 C35/Rule 51 摘要行)。

## (d) 质量面 — FAIL（见 MAJOR-1）
- Rule 45 双层注释齐备 (archive-plan.sh 头注 What/Why; check-complete gate 段含 What/Why)。
- set -u: check-complete.sh 无 `set -u` (grep 'set -' 空), 故 gate `[ -n "$PLAN_DIR_GUESS" ]` (unset 时为 empty) 安全, 非缺陷。
- shellcheck 未安装 (which shellcheck → rc=1) → 该项「未验证」, 未安装。
- **MAJOR-1**: check-complete.sh:1644 `_ag_ptr_hit=1` 跨迭代未复位 (全文仅 2 处引用, 无重置), 见意见清单。

## (e) 终审二元结论 — CHANGES_REQUESTED

## 意见清单
MAJOR-1 [check-complete.sh:1644,1648] `_ag_ptr_hit` 未按迭代复位 → gate 计数假阴性
- 原文: `_ag_ptr_hit=1` ... `[ -z "${_ag_ptr_hit:-}" ] || continue`
- 原因: while 体在当前 shell (process substitution) 执行, `_ag_ptr_hit` 一旦被任一侧指针命中置 1 后再不清零, 其后 (sort 序) 所有候选目录均被 continue 丢弃 → [ARCHIVE-GATE] WARN 计数被严重低估, 可能误报 "OK: 0 个待归档", 削弱 Rule 81 防复发可见性 (用户 R2 堆积诉求的兜底提醒失效)。已复现: 侧指针命中 task-a 后, task-b/task-c 两候选计数=0 (期望 2)。exit 码不受影响 (warn-only)。
- 修复: while 体首行加 `_ag_ptr_hit=""` (或在侧指针 for 前重置), 例如: `while IFS= read -r _ag_name; do _ag_ptr_hit=""; ...`。
- 置信度: HIGH

MINOR-1 [selftest-veto.sh:13,52,53] 新注释笔误 "task-v070" 应为 "task-v170"
- 原文: `[2026-10-11 task-v070 S10o 扩 81 纪元`
- 原因: 派发 prompt 路径笔误残留 (progress.md L83 事故面), 属注释漂移; 断言体本身用 task-v170 语义无行为影响。同文件 :13/:52/:53 三处。
- 修复: 统一改为 task-v170。
- 置信度: HIGH

## 负结果 / 排除项
- 检查了: archive-plan.sh 全文, selftest-archive-plan.sh 全文, check-complete.sh gate 段+exit 面, sync-todos.sh/resolve-plan-dir.sh/set-active-plan.sh archive 跳过, init-session.sh 锚注释, SKILL.md/critical-rules.md/registry 接线, 6 钉文件 + 14 epoch 脚本 diff。
- 未发现: 守卫绕过路径; git mv/mv 数据丢失窗口; 批量失败不可回退; exit-code 被 gate 篡改; 命令注入/路径遍历 (id 来自 CLI 但仅作 plans 下子目录名 + guard fail-closed)。
- 排除: PLAN_DIR_GUESS set -u 崩溃 (该脚本无 set -u)。
- 未验证: shellcheck (未安装); 全量 78/78 未在本轮重跑 (基于 030-code-runner-s11r2 检查点采信)。selftest-archive-plan.sh 本轮实跑 16/16 PASS 复核通过。

## 复现证据
- `sed -n '1620,1660p' check-complete.sh` → 循环体无 `_ag_ptr_hit=""` 复位行。
- `grep -n _ag_ptr_hit check-complete.sh` → 仅 1644(置 1)/1648(判空)。
- 复现脚本 (侧指针+2 候选) → `TOTAL candidate count=0 (expected 2)`。
- `wc -l SKILL.md` → 559; `grep -nE '1-(7[4-9]|8[01])' SKILL.md` → :9/:314/:406。
- `bash scripts/selftest-archive-plan.sh` → `Total: 16 PASS=16 FAIL=0`。

## 最终结论
status: done
acceptance: 4/5 pass
files: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/034-code-reviewer-s14.md
evidence: check-complete.sh:1644 `_ag_ptr_hit=1`（无复位, grep 仅 2 处引用）→ 复现 `count=0 (expected 2)`; check-complete.sh:1664 `exit $python_rc` 未被 gate 篡改
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/034-code-reviewer-s14.md (status: done)
findings_written: none
blockers: CHANGES_REQUESTED — [ARCHIVE-GATE] `_ag_ptr_hit` 跨迭代泄漏致计数假阴性，需一处复位修复后过 CR
confidence: HIGH
