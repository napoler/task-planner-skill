# 全量 selftest 回归对照（task-v143 Phase 4，2026-10-07）

> 执行说明：计划声明 code-runner-agent 派发遇 provider 失败（Model request failed），按 Rule 22.3① 改道主进程执行，输出过滤为 Total+FAIL 断言清单。

## 统计

- 脚本总数：57（两边同）
- A 类（两边全 PASS）：34
- B 类（两边 FAIL 且断言一致，既有漂移）：22 个脚本的既有 FAIL 面
- C 类（worktree 新增 FAIL）：**0（无新增回归）**
- D 类（master FAIL 但 worktree PASS）：selftest-iteration-persistence.sh IP-14（本任务级联演进修复：58.x→59.x 负断言，Rule 58 合法落地使原断言过期）

## B 类既有漂移明细（两边一致，非本任务造成）

| 脚本 | FAIL 断言 | 归属 |
|------|-----------|------|
| selftest-agent-coverage.sh | AC-07 | 既有 |
| selftest-ask-default-timeout.sh | RT-09 | 既有 |
| selftest-capability-persistence.sh | CP-16 | 既有 |
| selftest-iteration-persistence.sh | IP-15（config 键数 42≠40） | task-v142 遗留孤儿键 |
| selftest-lane-advancement.sh | LA-14 | 既有 |
| selftest-media-agents.sh | MA-10 | 既有 |
| selftest-media-dispatch.sh | MD-08 | 既有 |
| selftest-periodic-review.sh | PR-03/04/05/09/10 | v142 合并事故碎片（条款不在现行文件） |
| selftest-registry.sh | T02（periodic-review.sh 未登记 TSV） | v142 合并事故碎片 |
| selftest-reliability-institution.sh | R-12 | 既有 |
| selftest-requirement-coverage.sh | RC-13/RC-15 | 既有 |
| selftest-requirement-grading.sh | RG-07 | 既有 |
| selftest-self-resolution.sh | SR-09/SR-12 | 既有 |
| selftest-tool-selection.sh | TS-12 | 既有 |
| selftest-workflow-orchestration.sh | WF-12 | 既有 |

（NO-TOTAL：selftest-final-gate-hash.sh / selftest-user-instruction-priority.sh——两边一致的结构性无 Total 行，非 FAIL）

## 本任务新增守护

- selftest-evidence-goal-gate.sh：**20/20 PASS**（EG-01..EG-20，worktree 实测）

## 结论

worktree 改动零新增回归；IP-14 为合法级联演进（task-v127 RC-15 ^50→^52 同范式）。既有漂移面归属 v142 合并事故与他账 deferred，不在本任务范围（Rule 53.3 管辖二分）。
