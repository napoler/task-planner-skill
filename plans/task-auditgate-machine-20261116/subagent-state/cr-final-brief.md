# CR 终检任务书 — task-auditgate-machine-20261116（Rule 103.3 独立复检 + 42.7 CR Gate）

你是本计划的独立复检体（CR）。工作目录 /mnt/data/dev/task-planner-skill。除检查点外只读审查，禁修改任何文件。

## 需求锚（逐字）

用户原话（plans/task-auditgate-machine-20261116/user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」——①授权 CA-6 机器面接线（计划审计门机器强门）②审计门测试。R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」（范围边界仅此两项）。

## 交付终态（已落盘）

- merge commit cf697f7（master），worktree b0e7caf 已合并+清理
- 主仓新增/修改 6 文件：skills/task-planner/scripts/check-plan-audit-gate.sh（新建判定器）、scripts/selftest-plan-audit-gate.sh（新建 16 断言）、scripts/attest-plan.sh（[audit-gate] 接线 4 处增量）、scripts/selftest-registry.tsv（+1 行）、SKILL.md（审计门机器门行）、references/critical-rules.md（109.8 六子项）
- 部署位 IDENTICAL（smart-merge-back --deploy post-verify）
- 终验 run-verification PASS=6 FAIL=0（证据 plans/task-auditgate-machine-20261116/evidence/VC-1..6.out）
- VC-5 自举：主仓新 attest+enforce 对本 plan-dir rc=0+`[audit-gate] PASS: 末段审计留痕 [plan-audit-R8] APPROVED`
- 全量回归：Total 100 PASS=93 FAIL=7，Failed=冻结基线 7 名单逐名一致（含新增 selftest 全过）
- 审计轨迹：[plan-audit-R1..R8] 全录 progress.md（14→6→1→2→2→APPROVED→2I→APPROVED）

## CR 复检范围（终检三面，只抽样+门链复核，禁重审全史）

①**需求覆盖双锚**：R1（授权机器面）→ checker/attest 接线/selftest 三件套+109.8+SKILL 行落地（CA-7~CA-12 逐行对照）；R2（测试）→ selftest 16 断言+VC-2 行为断言+VC-5 自举+run-verification PASS=6；R3（范围）→ git show cf697f7 --stat 恰 6 文件无越界。
②**机器证据抽查**：亲跑 ≤6 条核心命令交叉验证（bash -n 三脚本；checker 对本 plan-dir rc=0；selftest Total FAIL=0；run-selftests --fresh Total 行与 Failed 行=冻结基线逐字一致；VC-5 attest enforce rc=0；`grep -c "^### 109 "`=1）——贴真实输出。
③**完成声称核查**：progress.md Phase 1-5 全 complete 与证据对应；[plan-audit-R8] 为末审计段且锚定 APPROVED；user-session-log.md 未改（mtime/sha）；未完成项披露真实性（provider 限流兜底/存量 7 FAIL 归属/self-resolution flaky）。

## 裁决映射（复检体出具，主进程只登记）

0 CRITICAL 且 0 IMPORTANT ⇒ **CR APPROVED**，否则 CR REJECTED（W/Q/N 留档）。

## checkpoint:（唯一写入点）

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/cr-final.md（动工前登记+完成回填）

## 输出格式（8 字段）

- status:/result:/evidence:/files_modified:/verification_results:/learnings:/next_steps:/risks:
末行唯一裁决行 `结论: **APPROVED**` 或 `结论: **REJECTED**`。
