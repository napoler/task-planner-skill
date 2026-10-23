# S14 — CR fix-phase 后全量 selftest --fresh 复跑（checkpoint）

- 日期: 2026-10-23
- 角色: code-runner-agent（子代理）
- 状态: **done / PASS**

## 契约核对
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023`
- HEAD 核验: `7d9a6e4 fix(task-focus-plan-split-20261023): CR fix-phase 全闭环（P1-1 计数口径 75→77、P1-2 二次确认时序、P2×11 注记/判据/留痕、NIT×2、93 表行补登+纪元注释链）` ✔ 与契约一致
- 运行前 `git status --short` = 空（干净）；运行后再次核验 = 空（本次执行零文件改动）✔
- 未修改 worktree 任何文件；计划三文件仅 `grep` 只读参照 ✔

## 执行命令（原文）
```
cd /mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023 && \
timeout -s TERM 540 bash skills/task-planner/scripts/run-selftests.sh --fresh
```
输出落 `/tmp/s14-selftest-fresh.log`（8.0K, 93 行, 无 TRUNCATED）

## 结果
- exit_code: **0**（echo EXIT_CODE=0，未触发 timeout 124）
- 总行原文:
  `Total: 92 PASS=92 FAIL=0 (run=92 reused=0)`
- `reused=0` 证明 `--fresh` 生效（全量重跑，非缓存假绿）
- 日志内 `grep -n "FAIL=[1-9]\|rc=[1-9]\|ERROR\|TRUNCATED\|WARN"` = **零命中**
- 92 个脚本逐条均 `rc=0 FAIL=0`（首行 selftest-absorption-discipline … 末行 selftest-workflow-orchestration PASS=22）
- 耗时: 约 **206s**（3m26s）— 由本次缓存批 mtime 起止 12:18:16.588 → 12:21:42.275 测得
- 关键回归脚本（本次任务相关）均在列且绿:
  - selftest-task-* / selftest-skill-split (PASS=40) / selftest-scorecard 类 / selftest-user-instruction-priority / selftest-source-anchor-discipline / selftest-verify-io

## 判定
- VC-3 终证据成立: exit 0 ∧ Total PASS=92 FAIL=0 ∧ reused=0 ✔
- 与 S8 基线对比: S8 为 91/92（唯一 FAIL=PR-02 账本时序），fix-phase 后 **92/92 全绿**，PR-02 已闭环 ✔

## 风险 / 观察（不影响判定）
1. **[LOW · 显示口径] 5 个脚本在汇总行显示 `PASS=0 FAIL=0`**：`selftest-absorption-discipline`、`selftest-channel-fast-fail`、`selftest-source-anchor-discipline`、`selftest-user-instruction-priority`、`selftest-verify-io`。
   - 归因（已实测复核）: `run-selftests.sh:102` 用 `grep -oE 'PASS=[0-9]+'` 抓计数，而上述脚本输出格式为 `Total: 12 pass, 0 fail` / `=== 总计: 4 PASS, 0 FAIL ===` / `Total: 6  PASS: 6  FAIL: 0`（大小写/分隔符不匹配 `PASS=N`），故 p/f 落 0。
   - 逐条直跑复核: verify-io 4 PASS 0 FAIL、channel-fast-fail 6 PASS 0 FAIL、absorption-discipline 16 pass 0 fail 1 skip、source-anchor-discipline 12 pass 0 fail、user-instruction-priority 7 ✓ ALL PASS——**均真实断言非空跑**。
   - 影响面: 仅 per-script 显示数值；`Total: PASS=92/FAIL=0` 按 rc 计脚本级结果（`run-selftests.sh:140-146` / 并行汇总 `:150-165`），FAIL 判定不受该显示口径影响，故 verdict 仍可信。属既有显示缺陷，射程外（本任务只复跑不改脚本），仅报告。

## 负结果报告
- 尝试: `--fresh` 全量跑批 1 次 + 3 个零计数脚本直跑复核 1 次
- 未发现: 任何 FAIL / 非零 rc / 超时 / 输出截断 / 工作区污染
- 排除: 缓存假绿（reused=0）；空跑假绿（零计数脚本已逐个直跑验证真实断言）

## 结论
S14 完成，PASS。可进入后续收尾。
