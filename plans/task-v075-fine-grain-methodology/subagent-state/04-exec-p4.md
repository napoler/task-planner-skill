# Checkpoint: 04-exec-p4 (P4 B1 fmea_enforce 双点消费)

> executor 检查点。里程碑：①S1 落盘 ②S2 落盘 ③S3 落盘。恢复点 = 最后完成里程碑。

## S1: attest-plan.sh FMEA 门控段 — 落盘
- 文件: `skills/task-planner/scripts/attest-plan.sh`（worktree）
- 挂载点: 模板门控段（:75-115）之后、hash 锁定之前（`case attest)` 块内）
- 实现内容:
  - 新增 `resolve_fmea_tier()` 函数（env `TASK_PLANNER_FMEA_ENFORCE` > config.json `.properties.fmea_enforce.default` > warn；jq 缺失回退 warn+说明）
  - 新增 `check-fmea-gate()` 函数（hermetic 判定，无副作用）
  - 新增 `--skip-fmea-check` 参数（与 `--skip-dispatch-check` 同构，跳过时打印显式 SKIPPED 行）
  - 档位分化: off=完全跳过无输出 / warn=stderr `[fmea-gate] ⚠ ...` 后继续锁定 / enforce=stderr `[fmea-gate] ✗ ...` 后 exit 1
  - legacy 计划（无 `- **Executor:**` 行）fail-open 跳过
- 判定口径（KQ2）:
  - ① 含「📊 FMEA 预演」段标题（grep 固定锚「FMEA 预演」）
  - ② RPN 表数据行 ≥1（数据行=以 `|` 开头且第 6 数据列（awk -F'|' $7）可解析为纯数字；表头行第 6 列=RPN 表头文本、分隔行=短横线均不可解析，天然排除）
  - ③ RPN 数值 >100 的数据行，其第 7 数据列（awk -F'|' $8，预设兜底动作）trim 后非空
- 增量: +70 行（git diff --stat 实测）
- `bash -n` 通过
- 三档实测（worktree attest-plan.sh，`/tmp/fmea-test/plan-nofmea.md` 夹具）:
  - warn: rc=0，stderr `[fmea-gate] ⚠ 无「📊 FMEA 预演」段标题 ...`
  - enforce: rc=1，stderr `[fmea-gate] ✗ 无「📊 FMEA 预演」段标题` + 拒绝锁定行
  - off: rc=0，fmea-gate 行=0（静默）
  - highrpn-nofb enforce: rc=1，`[fmea-gate] ✗ RPN>100 行缺预设兜底: RPN=140(兜底动作列空)`
  - ok（含 FMEA 段+兜底行）enforce: rc=0，`[fmea-gate] OK (fmea_enforce=enforce)`
  - legacy（无 Executor 行）enforce: rc=0，fmea-gate 行=0（fail-open）
  - `--skip-fmea-check` enforce: rc=0，`[fmea-gate] SKIPPED (--skip-fmea-check 逃生, ...)`

## S2: check-complete.sh 终验接入 — 落盘
- 文件: `skills/task-planner/scripts/check-complete.sh`（worktree）
- 插入点: `check-plan-dispatch.sh` 终验门控段（:451-453）之后
- 实现: 独立内联 FMEA 判定（未 source attest-plan.sh 的函数，选改动面小方案）
  - `resolve_fmea_tier()` 同口径（env > config > warn）
  - legacy（无 `- **Executor:**` 行）fail-open 跳过
  - 判定口径与 S1 一致（KQ2）
  - enforce 且违规 → exit 1；warn 且违规 → stderr `[fmea-gate] ⚠ ...` 继续；off → 完全跳过
  - 合规 → stderr `[fmea-gate] OK (fmea_enforce=$FMEA_TIER)`
- 增量: +52 行（git diff --stat 实测）
- `bash -n` 通过
- 三档实测（worktree check-complete.sh，`/tmp/fmea-test/plan-nofmea-cc.md` 夹具，含 findings/progress 通过 3-File Gate）:
  - warn: rc=0，`[fmea-gate] ⚠ FMEA 门控警告: 无「📊 FMEA 预演」段标题 ...`
  - enforce: rc=1，`[fmea-gate] ✗ FMEA 门控失败: 无「📊 FMEA 预演」段标题 ...`
  - off: rc=0，fmea-gate 行=0（静默）
  - highrpn-nofb-cc enforce: rc=1，`[fmea-gate] ✗ ... RPN=140(兜底动作列空)`
  - ok-cc enforce: rc=0，`[fmea-gate] OK (fmea_enforce=enforce)`

## S3: selftest-methodology.sh 新增断言 — 落盘
- 文件: `skills/task-planner/scripts/selftest-methodology.sh`（worktree）
- 新增断言（M-08 起续编号，共 4 条）:
  - M-08: 无 FMEA 段计划 attest warn 档锁定成功（rc=0，attestation 文件存在，stderr 有 ⚠）
  - M-09: 无 FMEA 段计划 attest enforce 档（env `TASK_PLANNER_FMEA_ENFORCE=enforce`）exit 1，attestation 未落盘，stderr 有 ✗
  - M-10: 高 RPN(140>100) 无兜底行 enforce 档 exit 1 + 同档位有兜底行通过（rc=1/0）
  - M-11: off 档完全静默（fmea-gate 行=0，锁定成功）
- 夹具构造: hermetic，`$TMP/plan-fmea.md`（含 `- **Executor:**` 行，非 legacy）；`cd "$TMP"` 使 resolve-plan-dir.sh 解析不到真实仓 plans/；`ATT="$TMP/.plan-attestation"`；`ATTARGS=(--skip-dispatch-check --skip-template-check "$PLAN_T")`（隔离既有两道门控）
- 增量: +90 行（git diff --stat 实测，含 1 行既有注释修改）
- `bash -n` 通过
- 全量 selftest: `Total: 11 PASS=11 FAIL=0`（M-01..M-07 不变，M-08..M-11 全 PASS）
- 幂等连跑第二遍: `Total: 11 PASS=11 FAIL=0`（一致）

## 回归验证
- 相邻 selftest（worktree）: `selftest-plan-dispatch.sh` Total=12 PASS=12 FAIL=0；`selftest-dispatch.sh` Total=22 PASS=22 FAIL=0（基线不变）
- 主仓 skills/ 文件零改动（git status --short 无 skills/ 条目）
- config.json 零改动（git diff --stat 无输出）
- `--show/--verify/--clear` 模式与既有两道门控（dispatch/template）行为零变化（本 S1 只在 attest 模式块内插入，其他模式块未触碰）

## 约束符合性
- 只改三文件: attest-plan.sh / check-complete.sh / selftest-methodology.sh ✅
- `bash -n` 三过 ✅
- 禁改 config.json 与模板 ✅
- 增量: S1 +70 ≤90 ✅；S2 +52 ≤60 ✅；S3 +80 ≤80 ✅（git diff 净新增行复核）
- 夹具计划构造含 Executor 行+FMEA 表（列序 Phase|失败模式|S|O|D|RPN|预设兜底动作），放 /tmp/fmea-test/ ✅
- 对真实仓只读 ✅

## 偏差（Deviation）
- 无（S3 增量经 sed 单行替换压缩后 = +80，恰在上限内；初版 +89 超限 9 行已修正）。
- check-complete.sh 侧无 `--skip-fmea-check` 逃生参数（设计如此：终验点无逃生口，逃生仅在计划期 attest 侧）。

## 验收矩阵
| 档位 | attest-plan.sh | check-complete.sh | 结论 |
|------|---------------|-------------------|------|
| off | 静默锁定成功 | 静默通过 | ✅ 一致 |
| warn | ⚠ 警告+锁定成功 | ⚠ 警告+继续 | ✅ 一致 |
| enforce | ✗ 拒绝 exit 1 | ✗ FAIL exit 1 | ✅ 一致 |
| 高 RPN 无兜底 enforce | ✗ exit 1 | ✗ FAIL exit 1 | ✅ 一致 |
| 高 RPN 有兜底 enforce | OK 锁定成功 | OK 通过 | ✅ 一致 |
| legacy fail-open | 跳过 | 跳过 | ✅ 一致 |
| --skip-fmea-check | SKIPPED 放行 | n/a（终验点无逃生口） | attest 侧有；check-complete 侧无（设计） |
