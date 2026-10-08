# S7-final 终审检查点 — task-v148 防偏移加强（F9/F10 终审；22.7 换道重派）
# worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce (branch wt/task-v148-drift-enforce, 基点 master e54973d)
# 对象: `git diff master` 全量（8 改 1 新；本轮增量=zcode-posttooluse.sh + selftest-drift-enforcement.sh）
# 只读审查；除本检查点零写入；无 git 写操作。

verdict: CHANGES_REQUESTED

## 摘要
- F9（BLOCKER 双行 JSON）：**字面缺陷已消解** —— 任一调用路径 stdout ≤1 行合法 JSON（6 路径实测）。
- F10（静默守卫绕过）：**已消解** —— 完结/超龄三场景 bytes=0 且 due=0；既有守卫逐字零改动。
- 前轮 F1/F3/F4/F6/F7 抽验在位、无回退；计数语义达标；四 selftest 基线全绿。
- **新发现 N1（阻断）**：F9 修复把 rhythm emit 延迟到「所有优先级分支之后」，而优先级 1-4 命中即 exit 0，
  该轮 rhythm 提醒**不投递**、due 残留，下一轮被 else 分支 clobber 为 0 → 提醒静默丢失。
  默认配置（rhythm N=10 == todo_sync 缺省 10，结构性同频）下 **Rule 64.3 节奏提醒永不投递**（实测 30 次调用 0 次）。
  → 违反 Rule 64.3 明文（critical-rules.md:777「每满 N=10 次工具调用…注入单行提醒」）与 R1 锚点；F9 修复自述契约（hook:309「此处统一 emit」）不可达。

## F9 逐路径实测（harness: mktemp fixture；plan=test-plan；预置 rhythm count=10 last_inject=0 → 本轮 due=1）
| 路径 | 命中分支 | lines | JSON(jq -e) | due_after | 本轮提醒 |
|------|---------|-------|-------------|-----------|---------|
| P1 | 计划陈旧 | 1 | ok | 1（残留） | plan-sync（rhythm 丢失） |
| P2 | findings 陈旧 | 1 | ok | 1（残留） | plan-compass（rhythm 丢失） |
| P3 | progress 陈旧 | 1 | ok | 1（残留） | plan-compass（rhythm 丢失） |
| P4 | count≥todo_n | 1 | ok | 1（残留） | plan-sync（rhythm 丢失） |
| 无分支（control） | end-emit | 1 | ok | 0 | drift-rhythm ✅ |
| F10-a/b/c | 完结/超龄 | 0 | — | 0 | 静默 ✅ |
→ 「≤1 行合法 JSON」**全路径成立**（F9 字面消解，master 同场景 call10=2 行的回归已消除）。
→ 但 P1-P4 四路径 rhythm 均未投递、due 残留（见 N1）。

## 新发现 N1 [阻断] — 默认配置下 [drift-rhythm] 提醒永不投递
- 位置: zcode-posttooluse.sh:302-306（优先级 4 emit+exit）早于 :308-332（rhythm 延迟 emit）；due 写入 :83-87（含下一轮 else 写 due 0 的 clobber）。
- 复现（默认 N=10/todo_n=10，干净主 state，30 次顺序调用）: `rhythm_delivered=0, plan-sync=3, maxlines=1`。
  对照（同 harness，N=3 非整倍）: `rhythm_delivered=4, maxlines=1` → 机制在「非重合轮」可投递，**重合轮必丢**（根因=相位锁定）。
- 根因链: ① 早调用写 due=1；② 该轮优先级分支命中并 exit 0，永不到 :316 end-emit；③ 下一轮早调用 count+1、
  `count-last_inject(=1)<N` → 走 else（:86）写 due=0，clobber 未投递的 due。N=10 与 todo_n 缺省 10 同起点、各自满 10 重置 → 每次阈值轮均撞优先级 4。
- 影响面: Rule 64.3（R1「防偏移加强」的可见性层）在目标「活跃执行期」场景静默失效，成为死文；
  DCE-19 仅断言 lines=1、未断言投递，故 21/21 无法暴露此洞。
- 最小修法（择一）: (a) 优先级 1-4 的 emit 前，若 due=1 则将 rhythm 文案**并入同一 additionalContext 单行**；
  (b) 将 end-emit 块上移至优先级 1 之前（due 每轮至多 1，仍 ≤1 行）；改后补断言「重合轮 rhythm 文本确实出现 + due 经投递清零」。

## F10 三场景实测（独立复现，非采信 executor 回执）
- task_plan.md `- **outcome: COMPLETE**` → bytes=0 due=0 ✅（DCE-20 一致）
- verification.md `- **outcome: COMPLETE**` → bytes=0 due=0 ✅
- task_plan.md mtime -25h → bytes=0 due=0 ✅（DCE-21 一致）
- 既有守卫 :169/:172/:177 相较 master 逐字零改动；F10 新块（:148-167）为纯增量「同条件重查清 due」，零 stdout。

## 计数语义 / 前轮项 / 断言真实性 / 基线
- 计数语义 VERIFIED: 优先级分支命中轮 rhythm count 仍自增（lockstep call10: 9→10 且 due=1；P1-P3 同）→ F5 诉求达成。
- 前轮项抽验（无回退）: F1 gate:265 `plan_tier: mini` 豁免在位；F3 selftest:35 `date -d '-1 hour'`；F4 :60 `dce16$$`；
  F6 ledger:9 枚举含 `drift_check`；F7 drift-checker.md:35-36 空行+`- ` 前缀齐备。本轮仅动 hook+selftest，上述文件未触。
- DCE 断言真实性: DCE-19 确实构造 due=1+P4 命中（本人独立复现同构）→ 断言真实但**不完整**（漏投递断言，须补强）；
  DCE-20/21 与本人独立 F10 复现一致（非恒真）。
- 基线（本人复跑）: drift-enforcement 21/21、drift-check-subagent 20/20、four-file-dataflow 18/18、registry 5/5(rows=61=actual)；bash -n x4 OK。
- 负结果: 零新 config 键（DCE-09 grep=0）；rhythm 文本为固定字面量仅插值数字，无注入面。

## 判定
- F9 字面（≤1 行合法 JSON）✅；F10 ✅；前轮项无回退 ✅；计数语义达标 ✅；四基线无回归 ✅。
- 但 F9 修复未闭环：延迟 emit 被优先级 1-4 的 exit 0 绕过 → 默认配置下 [drift-rhythm] 永不投递（N1，阻断，违 Rule 64.3 明文与 R1）。
- 须修 N1（并补 DCE-19 投递断言）后方可 APPROVED。
verdict: CHANGES_REQUESTED
