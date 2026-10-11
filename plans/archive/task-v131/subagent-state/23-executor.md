# 23-executor 检查点 — task-v131/Phase 7 S-unit1: 全量 selftest 回归跑批

<!-- 改派痕迹: 原派 code-runner-agent(mini 档) 被 provider 拒绝, 按 Rule 22.3① 改派 executor。
     跑批时间: 2026-10-05; 执行位置: /home/terry/task-planner-skill-worktrees/task-v131 (wt/task-v131 @ da161eb)
     执行方式: for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done
     只读跑批: worktree git status --short = 空 (跑批后复验 clean); 逐脚本日志留档 /tmp/v131-selftest-full/ -->

## 0. 总览（主进程求和复核的汇总数 — 原始逐脚本数据见 §1）

- 脚本总数: **51**
- 全 PASS 脚本数（FAIL=0 且 exit=0）: **44**
- 带 FAIL 用例脚本数: **7**（active-plan / dispatch / execution-stability / fine-grain-steps / methodology / plan-dispatch / final-gate-hash）
- FAIL 用例总数: **10**（1+1+2+1+4+1+0）
- SKIP（环境/setup 中止）: **1 个脚本** = final-gate-hash（exit 2「沙箱建立失败」，0 用例执行；根因与 51.1 夹具缺口同链，非 SKIP≙FAIL，见 §3 判定）
- 明确 SKIP 用例（脚本内 SKIPPED 计数 >0）: **0**（全量 SKIPPED=0；仅 agent-coverage 行显式打出 SKIPPED=0）
- registry 一致性: PASS（registry rows=51, actual selftest=51，selftest-registry.sh exit=0）

## 1. 逐脚本 Total 行完整清单（原始数据，求和复核用）

| # | 脚本 | exit | Total 行原文 |
|---|------|------|--------------|
| 1 | selftest-active-plan.sh | 1 | Total: 19 PASS=18 FAIL=1 |
| 2 | selftest-agent-coverage.sh | 0 | Total: 9 PASS=9 FAIL=0 SKIPPED=0 |
| 3 | selftest-ask-default-timeout.sh | 0 | Total: 9 PASS=9 FAIL=0 |
| 4 | selftest-batch-pilot.sh | 0 | Total: 10 PASS=10 FAIL=0 |
| 5 | selftest-check-conflicts.sh | 0 | Total: 7 PASS=7 FAIL=0 |
| 6 | selftest-check-drift.sh | 0 | Total: 6 PASS=6 FAIL=0 |
| 7 | selftest-conclusion-discipline.sh | 0 | Total: 24 PASS=24 FAIL=0 |
| 8 | selftest-context-hygiene.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| 9 | selftest-delegation.sh | 0 | Total: 38    PASS=38  FAIL=0 |
| 10 | selftest-dispatch-grain.sh | 0 | Total: 10 PASS=10 FAIL=0 |
| 11 | selftest-dispatch.sh | 1 | Total: 31 PASS=30 FAIL=1 |
| 12 | selftest-error-loop.sh | 0 | Total: 16 PASS=16 FAIL=0 |
| 13 | selftest-execution-stability.sh | 1 | Total: 19  PASS=17  FAIL=2 |
| 14 | selftest-fallback.sh | 0 | Total: 31  PASS=31  FAIL=0 |
| 15 | selftest-final-gate-hash.sh | 2 | (no Total line) — 前置 PASS×1 后「[selftest] 沙箱建立失败」exit 2 |
| 16 | selftest-fine-grain-steps.sh | 1 | Total: 11 PASS=10 FAIL=1 |
| 17 | selftest-interaction.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| 18 | selftest-iterative-optimizer.sh | 0 | Total: 8 PASS=8 FAIL=0 |
| 19 | selftest-knowledge-brief.sh | 0 | Total: 16  PASS=16  FAIL=0 |
| 20 | selftest-lane-advancement.sh | 0 | Total: 14 PASS=14 FAIL=0 |
| 21 | selftest-mechanism-profile.sh | 0 | Total: 19 PASS=19 FAIL=0 |
| 22 | selftest-media-agents.sh | 0 | Total: 10 PASS=10 FAIL=0 |
| 23 | selftest-media-dispatch.sh | 0 | Total: 9 PASS=9 FAIL=0 |
| 24 | selftest-methodology.sh | 1 | Total: 16 PASS=12 FAIL=4 |
| 25 | selftest-plan-dispatch.sh | 1 | Total: 12 PASS=11 FAIL=1 |
| 26 | selftest-plan-tier.sh | 0 | Total: 32 PASS=32 FAIL=0 |
| 27 | selftest-reflect-verify.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| 28 | selftest-registry.sh | 0 | Total: 5 PASS=5 FAIL=0 (registry rows=51, actual selftest=51) |
| 29 | selftest-reliability-institution.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| 30 | selftest-requirement-coverage.sh | 0 | Total: 15 PASS=15 FAIL=0 |
| 31 | selftest-requirement-grading.sh | 0 | Total: 7 PASS=7 FAIL=0 |
| 32 | selftest-rescue-chain.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| 33 | selftest-review-library.sh | 0 | Total: 15 PASS=15 FAIL=0 |
| 34 | selftest-root-resolution.sh | 0 | Total: 15 PASS=15 FAIL=0 |
| 35 | selftest-rule23-conflict-scan.sh | 0 | Total: 3 PASS=3 FAIL=0 |
| 36 | selftest-rule-reserve.sh | 0 | Total: 10 PASS=10 FAIL=0 |
| 37 | selftest-self-resolution.sh | 0 | Total: 13 PASS=13 FAIL=0 |
| 38 | selftest-shared-tracker.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| 39 | selftest-skill-collab.sh | 0 | Total: 25  PASS=25  FAIL=0 |
| 40 | selftest-skill-modify.sh | 0 | Total: 9 PASS=9 FAIL=0 (SKIP=0) |
| 41 | selftest-skill-split.sh | 0 | Total: 41  PASS=41  FAIL=0 |
| 42 | selftest-smart-merge.sh | 0 | Total: 17 PASS=17 FAIL=0 |
| 43 | selftest-sync-index.sh | 0 | Total: 13 PASS=13 FAIL=0 |
| 44 | selftest-task-boundary.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| 45 | selftest-template-lifecycle.sh | 0 | Total: 24 PASS=24 FAIL=0 |
| 46 | selftest-template-sense.sh | 0 | Total: 8 PASS=8 FAIL=0 |
| 47 | selftest-tier-b.sh | 0 | Total: 18 PASS=18 FAIL=0 |
| 48 | selftest-tool-selection.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| 49 | selftest-vc-gate.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| 50 | selftest-veto.sh | 0 | Total: 13 PASS=13 FAIL=0 |
| 51 | selftest-workflow-orchestration.sh | 0 | Total: 16 PASS=16 FAIL=0 |

求和核对（awk 复算于 51 行 summary）: PASS 用例合计=**736**, FAIL 用例合计=**10**（1+1+2+1+4+1=10, final-gate-hash 无 Total 行未入和）; SKIPPED 合计=0; exit=0 脚本=44, exit≠0 脚本=7。

## 2. FAIL 用例原文摘录（7 脚本 10 用例，禁概括 — 逐字摘录）

### 2.1 selftest-active-plan.sh（exit=1, T11）
原文:
```
T11 FAIL rc=1 att_bb=no att_aa=
```
断言（脚本 :131-146）: T11 [task-v065/V-8]「attest-plan.sh 在 side 指针存在时锁定指针计划」——side 指向 bb、touch aa 使 mtime 最新，注入 CLAUDE_CODE_SESSION_ID=s11 跑 attest --skip-dispatch-check，期望 rc=0 且仅 bb 产生 .plan-attestation。实测 rc=1 且 bb/aa 两侧均无 .plan-attestation → attest 被拒。

### 2.2 selftest-dispatch.sh（exit=1, FG-01）
原文:
```
FG-01 FAIL (rc=0 out=[] err=[[dispatch-guard] ⚠ 派发 prompt 未含「需求锚」字段（Rule 51.1a：需求相关 S-unit 须逐字引用治理 R 条目；纯机械单元可写「不适用（纯机械单元）」）——advisory 不阻断] wf=无)
```
断言: 合规短 prompt + 无 knowledge-brief → 期望 pretool 零细粒度输出（stdout/stderr 双空, rc=0, 无 wf 文件）；实测 rc=0 但 stderr 打出 Rule 51.1a 需求锚 advisory（Phase 6 L-1 新增, fail-open 不阻断）→ 夹具 prompt 未含需求锚字段, 测试期望未随 L-1 更新。

### 2.3 selftest-execution-stability.sh（exit=1, T11a/T11b）
原文:
```
[FAIL] T11a B1 正例: 相对含 slash 路径 Edit → 自动重锁(attested_by_sid=sessabc123 且 plan_sha256=新文件哈希)
[FAIL] T11b B1 负例: 改内容后 owner=othersid999 → 重锁不命中(plan_sha256 仍为旧值 且 attested_by_sid 重置为空, 不被洗白)
```
（同文件其余 T10a/T10b/T12/T13a/T13b 均 PASS；T12 三侧 canon 一致 PASS, 说明 hash 链路本身未坏, 失败点在「Edit 后自动重 attest 重锁」步骤——重锁调 attest-plan.sh, 夹具计划缺 51.1 四锚 → 重锁不落。）

### 2.4 selftest-fine-grain-steps.sh（exit=1, SG-04）
原文:
```
SG-04 FAIL rc=0 err=[dispatch-guard] ⚠ 派发 prompt 未含「需求锚」字段（Rule 51.1a：需求相关 S-unit 须逐字引用治理 R 条目；纯机械单元可写「不适用（纯机械单元）」）——advisory 不阻断
```
与 2.2 同签名: advisory 新增后期望「零输出」的夹具未补需求锚字段。

### 2.5 selftest-methodology.sh（exit=1, M-08/M-09/M-10/M-11 共 4 例）
原文:
```
M-08 FAIL 无 FMEA 段计划: warn 档锁定成功且 stderr 有 ⚠ (实测 rc=1 attested=n)
M-09 FAIL 无 FMEA 段计划: enforce 档 (env TASK_PLANNER_FMEA_ENFORCE=enforce) attest exit 1
M-10 FAIL 高 RPN(>100) 无兜底行 enforce 档 exit 1; 有兜底行通过 (实测 rc=1/1)
M-11 FAIL off 档: 无 FMEA 段计划静默锁定成功 (实测 rc=1)
```
共性: 四类 FMEA 档位用例全部以 attest 收尾, 实测 attest rc=1（连 off 档「静默锁定成功」也 rc=1）→ 夹具计划缺 51.1 区块+第 4 锚「🧮 根源覆盖表」, 51.1 fail-closed 硬门先于 FMEA 门拒锁, 与 FMEA 档位无关。

### 2.6 selftest-plan-dispatch.sh（exit=1, T06）
原文:
```
T06 FAIL attest 集成 (rc=1, attest=no):  | [attest] WARN: --skip-dispatch-check 跳过 S-unit 执行体校验
[attest] ✗ 缺 Rule 51.1 用户需求原文区块或第 4 锚「🧮 根源覆盖表」（Rule 53.1 载体, critic P1-3 对称性修复）；mini 档豁免——先回炉补区块再锁定
[attest] ✗ 缺失锚:· 标题「## 🎯 用户需求原文」缺失 · R 需求行(≥1, 正则 ^- \*\*R[0-9])缺失 · 「R→VC 映射」段缺失 · 「🧮 根源覆盖表」缺失（第 4 锚, Rule 53.1 载体；非结果级须写「不适用（非结果级）」+定性理由, 该声明亦算在位） (fail-closed 硬门, 无 --skip 逃生口; 补区块或声明 plan_tier: mini 后重 attest)
```
此条即 51.1 四锚门原文, 直接印证根因签名。

### 2.7 selftest-final-gate-hash.sh（exit=2, 无 Total, 归类 SKIP-setup）
原文（全日志仅 4 行）:
```
==== selftest-final-gate-hash (task-v091/S20 C-2) ====
  [PASS] 前置-键④完整性: 两脚本 jq .properties.* 消费集合==五键枚举 (fmea_enforce plan_tier_enforce subagent.step_max_files subagent.step_max_minutes subagent.step_max_steps )
[selftest] 沙箱建立失败
```
**第一手复现（主证据）**: 手工重放该脚本 setup_sandbox 同夹具（复制 skill 树 + 同内容 task_plan.md 夹具 + 调 worktree 内 attest-plan.sh）→ attest rc=1, stderr 打出与 2.6 逐字相同的「✗ 缺 Rule 51.1 用户需求原文区块或第 4 锚…」硬门拒锁消息 → setup_sandbox 内 `bash attest-plan.sh` 不置失败码但 .plan-attestation 未生成, 后续 `grep -q 'plan_sha256=' .plan-attestation` 前置检查走「沙箱建立失败」分支 exit 2。**判定: SKIP（setup 中止, 0 用例执行）而非用例 FAIL；根因同 51.1 夹具缺口, 非环境依赖（jq 在 /usr/bin/jq 可用、非 ~/.zcode 运行态依赖）。**

## 3. 根因归类（第一手证据支持程度: HIGH/MEDIUM）

统一根因链（证据 HIGH, 2.6/2.7 为第一手逐字原文+复现）:
- **根因 A（51.1 夹具缺口, 8 例）**: Phase 2 attest-plan.sh 新增 51.1 三锚门+第 4 锚「🧮 根源覆盖表」(critic P1-3 对称性修复) fail-closed 硬门, 但 6 个 selftest 脚本的夹具计划（active-plan T11 / execution-stability T11a-T11b / methodology M-08..11 / plan-dispatch T06 / final-gate-hash 夹具）未随门更新——夹具缺「## 🎯 用户需求原文」区块+「🧮 根源覆盖表」→ attest 拒锁 → 下游用例连锁 FAIL。
- **根因 B（L-1 advisory 期望漂移, 2 例）**: Phase 6 check-dispatch 新增需求锚 advisory（L-1 注释修正+advisory warn fail-open, commit da161eb 明示「需求锚 advisory」）, dispatch FG-01 与 fine-grain-steps SG-04 的「零输出/零细粒度」期望未补「纯机械单元可写『不适用（纯机械单元）』」字段 → advisory 打出即 FAIL。advisory 本身 rc=0 不阻断, 属测试期望滞后, 非产品行为回归。
- 排除项: registry 一致性 PASS（51=51）; execution-stability T12 三侧 canon 一致 PASS 排除 hash 链路损坏; methodology M-06/07/12/13 PASS 排除条文锚漂移; 无 jq/环境缺失（jq 可用）。

## 4. 建议（供主进程决策, 本 S-unit 不写入仓内）

Phase 7 CR 前需清账: 6 脚本夹具补 51.1 四锚（或声明 plan_tier: mini 走豁免）+ dispatch/fine-grain 两脚本夹具 prompt 补需求锚字段「不适用（纯机械单元）」→ 回归复跑 7 脚本验证全绿。

## 5. 收尾自检

- worktree `git status --short` = 空（跑批后复验, clean）; 仅写 /tmp 日志 + 本检查点
- 逐脚本日志存 /tmp/v131-selftest-full/（51 个 .log + summary.txt 逐行 名|exit|Total）
