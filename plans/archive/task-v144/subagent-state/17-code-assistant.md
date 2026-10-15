# S17 checkpoint — code-assistant（CR 闭环修复 P1-2+P2-1）

status: done

## 改动（worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v144，git diff 仅 3 文件）
1. **skills/task-planner/scripts/check-plan-dispatch.sh**（P1-2，+47 行级）
   - 阈值区新增 STEP_MAX_LINES 解析（同双层路径范式，回退 100 + SKIPPED 说明）
   - S-unit 行解析区 $7 时长校验之后新增 ⑤-c 粒度三值列（$8）：trim 后匹配 `^([0-9]+)f/([0-9]+)l/([0-9]+)min$`；三值任一超 step_max_files/lines/minutes(2/100/15) → `add_violation`（enforce 拒锁，提示串含「Rule 59.1 粒度三值硬门」）；列空 → `SKIPPED 粒度三值未填报（Rule 59.1 强制）` fail-open；格式漂移 → SKIPPED 提示；**行内含「例外」标记的超限行 → SKIPPED 留痕不阻断**（本计划 S15 `7f/14l/10min 文件数例外登记` 先例，防硬门误杀存量登记行，与验收项 4「本计划 exit 0」自洽）
2. **skills/task-planner/references/critical-rules.md**（P2-1 目标 B + P2-4）
   - 59.1 子条措辞精确化：「check-plan-dispatch.sh attest 时对粒度三值列超限 SKIPPED→enforce 拒锁（本条落地,task-v144）;check-dispatch.sh 派发侧为新增检测（该脚本此前无粒度检查）,prompt 含 Nf/Nl/Nmin token 超限即 enforce」+例外放行口径
   - 文件尾补行尾换行（tail -c1 → 0a）
3. **skills/task-planner/SKILL.md**（P2-1 消费侧三落点）
   - C43 行（L212，C42 之后）：Rule 59 自查（三值强制填报+超限回炉+伴飞注入）
   - 执行循环 2.5 委派检查点（L86）追加「派发前粒度三值与伴飞自查（Rule 59）」指针
   - Critical Rules 摘要 bullet（L320，Rule 58 与 62 bullet 之间）补 Rule 59 一行

## 验证证据
- 三 fixture（/tmp/s17fix/）：over(`3f/150l/20min`)→exit 1 三条 violation 均含「Rule 59.1 粒度三值硬门」；ok(`1f/50l/10min`)→exit 0 ✓；old(无粒度列)→SKIPPED+exit 0
- `bash check-plan-dispatch.sh plans/task-v144/task_plan.md` → exit 0（S15 例外留痕 SKIPPED）；v143 计划回归 exit 0
- `selftest-subagent-granularity-skill-escort.sh` → Total: 23 PASS=23 FAIL=0
- 关联回归：selftest-plan-dispatch 12/12、fine-grain-steps 11/11、plan-tier 32/32、conclusion-discipline 24/24 全 FAIL=0
- **已知残余（非本 S-unit 范围，已登记 findings §[sub:17-code-assistant]）**：selftest-final-gate-hash.sh 键④枚举断言 FAIL=1——check-plan-dispatch.sh 新增消费 `subagent.step_max_lines` 键，FG 五键枚举需同步更新（归后续 S-unit/合并级联面）；基线（git stash 后）PASS=22 FAIL=0，可归因于本键新增
- git diff 仅三目标文件；未 git add/commit

```
status: done
acceptance: 5/5 pass — [1:PASS 三 fixture exit 1/0/0 且超限含 Rule 59.1] [2:PASS 59.1 措辞+尾换行 0a] [3:PASS C43/2.5 指针/Rule59 bullet grep 各命中] [4:PASS escort 23/23 + 本计划 exit 0（S15 例外登记留痕放行）] [5:PASS git diff 仅 3 文件]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v144/skills/task-planner/scripts/check-plan-dispatch.sh(+52/-6 净+47 级); .../references/critical-rules.md(+2/-1+尾换行); .../SKILL.md(+4 行三落点)
evidence: check-plan-dispatch.sh:262-292 ⑤-c 粒度三值 enforce 块（正则+三 add_violation+例外留痕）; critical-rules.md:737 59.1 新措辞; SKILL.md:212 C43 / SKILL.md:86 2.5 指针 / SKILL.md:320 Rule 59 bullet; bash check-plan-dispatch.sh /tmp/s17fix/over.md → 3×「Rule 59.1 粒度三值硬门」exit 1; 本计划 exit 0; escort Total: 23 PASS=23 FAIL=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v144/subagent-state/17-code-assistant.md (status: done)
findings_written: §[sub:17-code-assistant]（findings.md Research Findings 段末=EOF 前追加，L254 起）
blockers: selftest-final-gate-hash 键④枚举漂移 1 项（step_max_lines 新增消费，归后续级联面，已在 findings 登记）
confidence: HIGH
```
