# S6 检查点 — 守卫断言新增（L-3 + L-4）

- task: task-kb-cr-lits-20261023 / Phase 1 S-unit S6
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023 (branch wt/task-kb-cr-lits-20261023, base master 923aa54)
- 时间: 2026-10-23
- 状态: **DONE**

## 修改文件（仅 1 个，范围内）

`skills/task-planner/scripts/selftest-requirement-coverage.sh`（+21/-1 行，diff 已复核）

### L-3：新增 RC-28（:589 起）

仿 RC-24..RC-27 范式（行锚=1 + 行内语义锚 scoped grep，ok()/bad() 结构逐同构）：

```bash
_rc28_line="$(grep -c '^51\.13 ' "$CRIT" || true)"
_rc28_a="$(grep '^51\.13 ' "$CRIT" | grep -c '51\.9-51\.13 子条文本锚' || true)"
_rc28_b="$(grep '^51\.13 ' "$CRIT" | grep -c '0 母图即 COMPLETE' || true)"
_rc28_c="$(grep '^51\.13 ' "$CRIT" | grep -c '零新 config 键' || true)"
if [ "$_rc28_line" -eq 1 ] && ...; then ok 28 ...; else bad 28 ...; fi
```

**锚实测依据（写锚前逐一无臆造确认）**：
- `grep -c '^51\.13 ' critical-rules.md` = **1**（51.13 段起始行真实形态实测在 `references/critical-rules.md:106`，行首 `51.13 **机制（零新 config 键...` 纯行首无缩进，形态同 51.9-51.12）
- scoped 到 :106 行的 3 个语义锚各自实测 =1：
  - `51.9-51.13 子条文本锚`（机制段自我声明的守护面）
  - `0 母图即 COMPLETE`（事故判例锚；**全局命中=2**：:98 是 51.9 标题行、:106 是 51.13 机制段——故必须 scoped 到 51.13 行断言 =1，避免全局 grep 误报；与 RC-24 对 51.9 行的判例锚成对守护）
  - `零新 config 键`（零新键承诺锚，与 RC-08 全局锚同词但 scoped 落点=51.13 机制段）

### L-4：头注 :8 `RC-01..RC-23` → `RC-01..RC-28`

## 验证输出

1. `bash skills/task-planner/scripts/selftest-requirement-coverage.sh`：
   - RC-28 行：`RC-28 PASS critical-rules.md 51.13 行锚=1 且行内语义锚「51.9-51.13 子条文本锚」「0 母图即 COMPLETE」「零新 config 键」在位（机制段 L0-T 零新键范式）`
   - 末行：`Total: 28 PASS=28 FAIL=0`，exit=0 ✅
2. 全量入口 `bash scripts/run-selftests.sh --fresh`（92 个 selftest 脚本全量重跑，无缓存复用）：
   - 末行：`Total: 92 PASS=92 FAIL=0 (run=92 reused=0)`，PIPELINE_DONE ✅
   - 全量 0 FAIL，无既有 FAIL 面，故无新增 vs 存量 FAIL 区分需求

## 级联自查结果

- `grep -rn 'RC-27|RC-01..RC-23|RC-28' skills/task-planner/`（排除 subagent-state）：**唯一命中=本脚本自身**（头注 :8 已修 + :576 RC-27 注释）；
- 扩展面 `grep -rn 'RC-27|RC-01..RC-23|RC-28|requirement-coverage|PASS=2[0-9]'`（*.sh/*.md/*.tsv/*.json）：
  - `references/critical-rules.md:94/:106` 命中=51.6/51.13 条款对本脚本名的引用（脚本名未改，不受 RC 计数影响，无需动）；
  - `scripts/selftest-registry.tsv:48` 本脚本登记行提及 `RC-16..20` 子集字面（无 Total 计数钉值、无 RC 上限钉值，不受影响，**不需改**）；
  - SKILL.md / run-selftests.sh / selftest-registry.sh / config.json 中**无任何 RC Total 计数钉值或 `RC-01..RC-23` 头注**（RC-11 主锚是 'Critical Rules 1-80' 全集索引，与 RC 编号无关）。
- 结论：**无范围外 blocker**，级联面=0 个依赖 RC 计数的既有守卫。

## 遗留 / 风险

- 遗留：无。L-3/L-4 均已闭环。
- 风险标记：
  1. RC-28 事故判例锚 `0 母图即 COMPLETE` 依赖 critical-rules.md :98 与 :106 两处同词分布——若未来 51.9 标题行措辞改动删去该词，RC-28 因 scoped 到 51.13 行不受影响（=1 仅要求 :106 在位），无耦合风险；反向若 :106 机制段改写删去该词，RC-28 FAIL 报警=预期行为。
  2. registry.tsv:48 描述面仍写「八子条（51.1-51.8）」（历史注释口径，已有 task-v149/v170/v171 行号锚校准注记先例），非 RC 计数钉值，不在本次 S6 范围内——**登记为可观察项**：若后续任务要求 registry 描述面同步到十三子条口径再动（当前 PASS 无碍）。
  3. worktree 内存在其他 S-unit 已落盘的 modified 文件（README.md/ARCHITECTURE.md/check-*.sh 等 7 个），均为既有 S-unit 产物，本 S6 未触碰；未 commit（按任务约束）。
