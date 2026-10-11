# 035-code-assistant-crfix1 — Phase 6 CR-fix S-unit（task-v170，ARCHIVE-GATE _ag_ptr_hit 泄漏修复）

派发锚: 034-code-reviewer-s14 MAJOR-1（CHANGES_REQUESTED blocker）；worktree /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans。
PATH NOTE: 任务书写 task-v070，磁盘实为 task-v170（034 已立先例），按实态执行。

## T1 里程碑（时间戳）
- 2026-10-11 T1-01 Edit 完成: check-complete.sh:1621-1626（while 体首行插入 6 行：Rule 45 注释 5 行 + `_ag_ptr_hit=""` 复位行 1 行），bash -n → SYNTAX_OK；grep 确认 `_ag_ptr_hit` 现 3 处引用（:1626 复位 / :1650 置 1 / :1654 判空）。
- 2026-10-11 T1-02 fixture 构建（/tmp/crfix1-agfixture-A 乱序: 指针目录 task-a 在候选 task-p1/task-p2 sort 序之前；/tmp/crfix1-agfixture-B 顺序: 指针目录 task-z 在候选 task-m/task-p1 之后；各含 3 目录 = 1 侧指针 active + 2 complete 候选，目录内 task_plan.md 全 complete + findings/progress 各 ≥3 实质行过 3-File Gate）。
- 2026-10-11 T1-03 因果对照: `git show HEAD:…check-complete.sh`（修复前版，_ag_ptr_hit 仅 :1644/:1648 两处引用）实跑 fixture A → `[ARCHIVE-GATE] OK: 0 个待归档`（假阴性复现，034 的 count=0）；修复版实跑 fixture A → `[ARCHIVE-GATE] WARN: 2 个已完成计划未归档…`（转绿，exit=0）；fixture B → 同 WARN: 2，exit=0。
- 2026-10-11 T1-04 回归: `bash -n` 通过；exit 语义不变（fixture 实跑 ALL PHASES COMPLETE → exit 0；既有 `exit $python_rc` 汇合点 :1670 未动，gate 段零 rc 赋值）；selftest-execution-stability `Total: 19 PASS=19 FAIL=0` rc=0；selftest-drift-check-subagent `Total: 20 PASS=20 FAIL=0` rc=0。
- 2026-10-11 T1-05 git add（无 index.lock 冲突，0 次重试）+ commit `de1eed1`（1 file changed, 6 insertions），message 按授权原文。
- 2026-10-11 T5 最终结论（见下 §7 同块）。

## 修复 diff（前后）
```diff
--- a/skills/task-planner/scripts/check-complete.sh  (HEAD dd14673 口径)
+++ b/skills/task-planner/scripts/check-complete.sh  (de1eed1)
@@ while IFS= read -r _ag_name; do
+            # 2026-10-11 CR-fix (034-code-reviewer-s14 MAJOR-1): 现象=侧指针命中某任务后,
+            # 其后 sort 序候选目录均因 _ag_ptr_hit 残留被 continue 丢弃, 计数假阴性
+            # (复现: 1 active 指针任务 + 2 complete 候选 → count=0, 期望 2);
+            # 根因=while 体在当前 shell 执行, 变量跨迭代不自动清零, 标志一旦置 1 永不复位;
+            # 修法=每轮目录判定前复位, 语义收窄为「当前目录是否被 active 指针指向」
+            _ag_ptr_hit=""
             # 与 archive-plan.sh:166-189 同枚举口径：…
```
- 位置: check-complete.sh:1621-1626（while 体首行，守卫② for 循环之前）
- 置信度: HIGH（034 CR 意见原案修法一致：while 体首行复位）

## 复现脚本与输出（fixture 于 /tmp，禁改真实 plans/）
```bash
# fixture 布局（A 乱序 / B 顺序，构建脚本见 T1-02）
# A: plans/{task-a(侧指针 active), task-p1, task-p2, .active_plan_side/task-a.active_plan}
# B: plans/{task-m, task-p1, task-z(侧指针 active), .active_plan_side/task-z.active_plan}
# 目录内: task_plan.md('- **Status:** complete') + findings.md/progress.md(各3实质行)

# (1) 修复前版因果对照（git show HEAD 版脚本, 实跑 fixture A）:
bash <HEAD版check-complete.sh> /tmp/crfix1-agfixture-A-pre/plans/task-p1/task_plan.md
#   → [plan] ALL PHASES COMPLETE (1/1)  ;  [ARCHIVE-GATE] OK: 0 个待归档   ← 假阴性(期望 2)

# (2) 修复版实跑 fixture A（乱序, 指针目录 sort 序在前）:
bash /tmp/crfix1-agfixture-A/scripts/check-complete.sh /tmp/crfix1-agfixture-A/plans/task-p1/task_plan.md; echo $?
#   → [ARCHIVE-GATE] WARN: 2 个已完成计划未归档，运行 bash scripts/archive-plan.sh --batch --dry-run 查看
#   → exit=0

# (3) 修复版实跑 fixture B（顺序, 指针目录 sort 序在后）:
bash /tmp/crfix1-agfixture-B/scripts/check-complete.sh /tmp/crfix1-agfixture-B/plans/task-m/task_plan.md
#   → [ARCHIVE-GATE] WARN: 2 个已完成计划未归档… ; exit=0

# (4) 回归:
bash -n <worktree>/skills/task-planner/scripts/check-complete.sh        # SYNTAX_OK
bash <worktree>/skills/task-planner/scripts/selftest-execution-stability.sh     # Total: 19 PASS=19 FAIL=0
bash <worktree>/skills/task-planner/scripts/selftest-drift-check-subagent.sh    # Total: 20 PASS=20 FAIL=0
```

## 负结果 / 排除项
- 检查依赖文件: check-complete.sh gate 段（:1606-1670）与 exit 汇合点；archive-plan.sh:88-123 guard 口径（fixture 构造对齐）；两 selftest 全文 grep "check-complete" = 0 直接引用（其回归风险面=脚本语法/既有断言面，实跑验证）。
- 未发现: exit 通路被 gate 段改动（`exit $python_rc` :1670 原文在位，gate 段零 rc 赋值）；MINOR-1（selftest-veto.sh task-v070→v170 笔误）属本 S-unit 范围外，未动（Scope 禁改清单仅限目标文件）。
- 排除: shellcheck（未安装，034 同判）；无 set -u 崩溃面（该脚本无 set -u，034 已排除）。

## 最终结论（§7 同块）
status: done
acceptance: 3/3 pass
files: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/check-complete.sh (+6/-0, commit de1eed1)
evidence: check-complete.sh:1626 `_ag_ptr_hit=""` 复位行（bash -n → SYNTAX_OK）；修复前 HEAD 版实跑 fixture A → `[ARCHIVE-GATE] OK: 0 个待归档`（假阴性复现），修复后乱序 fixture A + 顺序 fixture B 均 → `[ARCHIVE-GATE] WARN: 2 个已完成计划未归档` 且 exit=0（复现转绿）；selftest-execution-stability `Total: 19 PASS=19 FAIL=0` + selftest-drift-check-subagent `Total: 20 PASS=20 FAIL=0`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/035-code-assistant-crfix1.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
