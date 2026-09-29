# P5-S1 checkpoint — executor: 新建 selftest-tool-selection.sh（task-v097）

## 结论
- status: done
- 新建 `skills/task-planner/scripts/selftest-tool-selection.sh`（worktree 内）
- `bash -n` rc=0；运行 rc=0
- **Total: 12 PASS=12 FAIL=0**
- `git -C <wt> status --short` 仅 `?? skills/task-planner/scripts/selftest-tool-selection.sh`（untracked，零其他写入，未 commit/add）

## 执行过程证据
1. 先 Read selftest-workflow-orchestration.sh 全文（WF 范式 L19-110：SCRIPT_DIR/SKILL_ROOT 相对脚本目录定位仓根、PASS/FAIL + ok/bad 结构、Total 行、exit $((FAIL>0))）——新脚本与之同构。
2. 逐条 grep 实测 12 个断言锚（worktree 实际文件）：
   - TS-01 `grep -c '^40\.'` CRIT = 6 ✓
   - TS-02 「不可代调」CRIT = 2（≥1）✓
   - TS-03 40.4 行「显式点名」=1 且 40.6 行「零新 config 键」=1 ✓
   - TS-04 SKILL `Rule 40` = 5（≥3）✓
   - TS-05 SKILL `Rules 1-39` = 2 且 `1-40` = 0 ✓
   - TS-06 三既有锚各 =1 ✓
   - TS-07 `| C28 |` = 1 ✓
   - TS-08 task_plan.md 🧰 区块 =1 + 上游分析记录 =1 ✓
   - TS-09 mini-lite 豁免声明 =1 且 45 行 ≤80 ✓
   - TS-10 dispatch 工具面提示 =1 ✓
   - TS-11 mapping/guide/plan-writer 各 =1 ✓
   - TS-12 config.json properties 键数 = 40 ✓
3. 首次全 PASS 即通过，零调试轮次（≤2 轮纪律内）。

## 路径解析核实
脚本用 `$(cd "$SKILL_ROOT/.." && pwd)/plan-template-kit/...` 定位卫星两文档——该解析已单独 ls + grep 复核：三文件均存在于 worktree skills/plan-template-kit 与 skills/task-planner/companion/agents 下，锚各命中 1。

## Total 行原文
```
Total: 12 PASS=12 FAIL=0
```

## git status 原文
```
?? skills/task-planner/scripts/selftest-tool-selection.sh
```

## 未做（不在本 S-unit 范围，交主进程/P5-S2）
- registry 双落点登记（selftest-registry.tsv + selftest-registry.sh）——任务书 09 未含，属 P5-S2。
- 全量 selftest 复跑（P5-S3）。
- 未 git commit/add（硬约束遵守）。
