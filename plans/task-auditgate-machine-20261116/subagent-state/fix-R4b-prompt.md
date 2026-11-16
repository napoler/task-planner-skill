# 微修轮 4b 任务书 — task-auditgate-machine-20261116

你是本计划的 Plan Writer（微修轮 4b）。工作目录 /mnt/data/dev/task-planner-skill。只修改计划文档（plans/task-auditgate-machine-20261116/ 六文件+检查点），禁碰 skills/** 与其他目录，禁创建仓库脚本。

## 背景（自包含）

- 用户需求逐字锚（plans/task-auditgate-machine-20261116/user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」。计划需求锚 R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」。任务=计划审计门机器强门（checker+attest 接线+selftest）+测试。plan_tier=standard / execution_lane=L1。
- 历轮：R1 REJECTED 14→修复；R2 REJECTED 6→修复；R3 REJECTED 1+3N→修复；R4 REJECTED（C-1/I-1/W-1/W-2/N-1/N-2）→修复轮 4 已完成（VC-6 两段式/S2 内嵌命令/`$` 锚/rc 捕获/VC-1 r2/:269 清理——主进程已盘上复核在位）。
- 本轮=**微修轮 4b，单一主题**：修复轮 4 风险披露 #1 的确定性冲突。

## 唯一主题：VC-6 回归判据 vs 存量基线冲突

**事实（主进程已一手实测 2026-11-17）**：`bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh --fresh` → `Total: 99 PASS=92 FAIL=7`，末行 `Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability`。7 个失败全部为**其他在途任务遗留**（如 selftest-registry 的 T03 孤儿行 selftest-md-edit-ops.sh 属 task-mdedit-reliability-20261116 在途未实现面），消解属 `skills/**` 保护区+他任务射程，R3 范围边界明确排除。

**冲突**：VC-6 现行回归判据「全量 selftest --fresh 回归 0 FAIL」（verify command 中 `FAIL=0`）与存量债确定性冲突——Phase 5 终验必 FAIL，outcome 禁 COMPLETE。

**处置方向（项目既有「同集零增量」惯例；非放宽规避——断言仍是全量回归，只是冻结已知失败基线、判无新增）**：

1. **task_plan.md Phase 1 基线冻结段**新增「selftest 基线冻结」条目：
   - 上述 Total 行原文 + `Failed:` 行原文（7 名单逐字）
   - 冻结日期 2026-11-17
   - 归属说明：他任务在途遗留，本任务射程外（R3 边界）
2. **verification.md VC-6**：
   - 判据描述行「全量 selftest `--fresh` 回归 0 FAIL」→「全量 selftest `--fresh` 同集零增量（`Failed:` 集合==Phase 1 冻结基线，无新增 FAIL）」
   - Verify command 回归断言段：`FAIL=0` 改为 `FAIL=7` 精确匹配 **且** `Failed:` 行与冻结 7 名单整行精确相等（形态参考：`grep -qE "^Total: [0-9]+ PASS=[0-9]+ FAIL=7 " ` + `grep -q "^Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability$"`）
   - Evidence 行同步
3. **基线漂移条款**（task_plan.md Phase 5 S2 验收或 Notes + verification.md VC-6 Evidence 任一合适处）：若执行期基线已因其他任务收口而变化（FAIL<7 或名单不同），由主进程重跑冻结新基线、progress.md 留 `[baseline-shift]` 行（新 Total 行+名单+原因），按新基线判同集零增量；**禁静默放宽**。
4. **实测收据（真实输出）**：
   - 正向：新判据对当前真实基线 dry-run → rc=0
   - 负向：/tmp 构造含新增假 FAIL 名（如 `selftest-fake-new`）的模拟输出 → 新判据 rc≠0
   - 同时贴旧判据（FAIL=0）对当前基线 → rc≠0（冲突确证）

## acceptance:

- 三处修改实际 Edit 落盘，收据含 grep -n 锚定位+实测 rc，禁「应落点/待执行」措辞
- 正反态 dry-run 真实执行贴输出
- 三约束保持并自证：R1-R3 逐字锚 task_plan.md:16-18 未动、user-session-log.md 全文未动、无 `结论: **APPROVED**` 审计段级预写
- 机械门重跑贴真实 rc（至少 check-rvc-coverage.sh、check-vc-nonvacuous.sh、check-tier-consistency.sh；其余三门 check-plan-dispatch/check-delegation stats/check-template-type/check-step-placeholders/check-goal-cjk 若涉及改动面也重跑）

## checkpoint:

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/fix-R4b.md — 动工前写（轮次/范围/开始时间），完成后追加处置与实测输出。

## 输入材料（绝对路径）

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/verification.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/progress.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/knowledge-brief.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/notepad-learnings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/fix-R4.md（上轮检查点，含上下文）

## 完成后追加

1. progress.md 末尾追加「## 2026-11-17 R4b 微修轮（VC-6 同集零增量对齐存量基线）」段（处置/文件/未改/机械门真实输出/基线漂移条款落点）。
2. findings.md 补本发现与处置对照。
3. knowledge-brief.md 补教训（绝对 FAIL=0 vs 同集零增量的判据设计：跨任务共享仓的回归判据必须冻结基线集合，绝对零判据会被他任务在途债确定性击穿）。
4. notepad-learnings.md 同步。

## 输出格式（8 字段返回模板）

- status: COMPLETE/FAILED
- result: 处置摘要
- evidence: 落点 grep -n+实测输出
- files_modified: 清单
- verification_results: 正反态 dry-run 真实输出
- learnings: 新教训
- next_steps: 无
- risks: 风险披露（无则"无"）
