# S21b Executor Checkpoint — task-v166 selftest-summary-readability.sh 三问题修复

## T1 里程碑: 2026-10-11 11:19:06 (修复启动+输入确认)

### 输入确认
- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability/skills/task-planner/scripts/selftest-summary-readability.sh (177L, 13 断言)
- review  checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/19-code-reviewer.md (F-1/F-2/F-3 详情已 Read)
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability, branch=wt/task-v166-summary-readability

### 修复执行（4 步严格顺序）

**Step 1 — SRV-07 弱守卫→锚定表头行**
- 原: `cnt '文件名' "$DS"` / `cnt '路径' "$DS"` / `cnt '描述' "$DS"` 全文件计数（:100-102）
- 新: awk 定位「## 3. 审查清单」标题行→抽取标题后首个表格首行→对该行 grep -c 三列名
- 效果: §3 表整体被删→表头行不存在→三计数=0→FAIL（消除「路径」「文件名」在指引文亦存在的弱守卫）
- 验证: /tmp/srv07_fixture.md（缺 §3 表）→ SRV07_HEADER='' → FAIL (correct)

**Step 2 — SRV-08/09/13 正则死守卫→ERE**
- 原: `cnt 'Phase [0-9]+: [①-⑨]'`（BRE 下 `[0-9]+` 的 + 按字面解析，`[①-⑨]` 区间不匹配→恒 0）
- 新: 新增 cntE helper（`grep -cE`），三处 `cnt`→`cntE`
- 效果: ERE 下 `[0-9]+` 与 `[①-⑨]` 区间匹配生效→装饰圈号出现时计数≥1→负断言 FAIL
- 验证: /tmp/srv08_fixture.md（含「Phase 1: ①」）→ cntE=1 → FAIL (correct)

**Step 3 — 头注陈旧→实际断言清单**
- 原: `#     · SRV-08..SRV-13: 预留骨架（S10 追加上半）`
- 新: 六条断言简述（SRV-08..SRV-13 各自守护对象）

**Step 4 — 自跑验证**
- bash -n: SYNTAX-OK
- 自跑: Total PASS=13 FAIL=0 WARN=0, rc=0
- SRV-07 夹具: FAIL (correct)
- SRV-08/09/13 夹具: FAIL (correct)

### 变更统计
- 文件: selftest-summary-readability.sh (+9/-6)
- 断言总数: 13→13（不减）
- git 写操作: 无（仅改工作树文件）

## T5 最终结论

```
status: done
acceptance: 4/4 pass — [1:PASS(SRV-07 锚定版,缺 §3 表夹具 FAIL) 2:PASS(SRV-08/09/13 ERE,圆圈夹具 FAIL) 3:PASS(自跑 Total PASS=13 FAIL=0 rc=0) 4:PASS(bash -n SYNTAX-OK)]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability/skills/task-planner/scripts/selftest-summary-readability.sh(+9/-6)
evidence: selftest-summary-readability.sh:99-108(SRV-07 awk 锚定表头行); :50(cntE helper); :110,118,167(cnt→cntE); :14-17(头注改实际断言清单); bash -n→SYNTAX-OK; 自跑→Total: PASS=13 FAIL=0 rc=0; /tmp/srv07_fixture.md→SRV07_HEADER=''→FAIL; /tmp/srv08_fixture.md→cntE=1→FAIL
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/21b-executor.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
