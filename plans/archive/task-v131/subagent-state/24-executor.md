# 24-executor 检查点 — task-v131/Phase 7 S-unit: 回归清账根因 A 批（51.1 四锚夹具补齐）

<!-- 执行位置: /home/terry/task-planner-skill-worktrees/task-v131 (wt/task-v131)
     执行时间: 2026-10-05; 只动 5 文件 (git diff --stat 复验), 未 commit, 未触碰任务范围外文件 -->

## 0. 总览

| 脚本 | 修改点（file:line 为改后行号） | 修法 | 重跑结果 |
|------|-------------------------------|------|----------|
| selftest-active-plan.sh | T11 段 :137+（bb 计划文件 `>>` 追加四锚最小集） | mk_root 裸 '# plan bb' → 追加 51.1 四锚；aa 保持裸文本（T11 仅断言 aa 侧不产生 attestation，不需过门） | Total: 19 PASS=19 FAIL=0 (exit=0) |
| selftest-execution-stability.sh | b1_pos :94-119 / b1_neg :128-147（两处 `echo "goal"` 夹具 → goal 行+四锚最小集） | 原测试目标（自动重锁/归属护栏防洗白）不变；append 'goal v2' 仍与锚区块共存，哈希链路断言不受影响 | Total: 19 PASS=19 FAIL=0 (exit=0) |
| selftest-methodology.sh | M-08..M-11 三处 heredoc 夹具 :115+：引 ANCHORS 变量（四锚最小集+53.1 非结果级「不适用」声明带定性理由） | 原为 3 处 `<<'EOF'` 单引号定界 → 改 `<<EOF` 插值（锚块无 shell 特殊字符，无展开风险；FMEA 表格数据行零改动，M-10 sed 兜底行替换锚点 `| 140 |  |` 未变） | Total: 16 PASS=16 FAIL=0 (exit=0) |
| selftest-plan-dispatch.sh | T02 夹具 P2 :57+（printf 追加四锚 5 行） | T02 原目标（缺 S-unit 表 → check-plan-dispatch exit 1）不受影响；T06 夹具=P2 副本随之过门，attest 锁定成功 | Total: 12 PASS=12 FAIL=0 (exit=0) |
| selftest-final-gate-hash.sh | setup_sandbox 夹具 :70+（heredoc 内追加 51.1 区块于 FMEA 段前） | 原行为：无 51.1 区块 → 四锚门拒 attest → 「沙箱建立失败」exit 2、0 用例；修后 setup PASS + 六夹具全绿 | PASS=22 FAIL=0 (exit=0) |

## 1. 四锚最小集内容（各脚本同口径）

```
## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
- **R1**: 「fixture」   (final-gate-hash 用任务相关 R1 文案)
### R→VC 映射
## 🧮 根源覆盖表
> 不适用（非结果级需求）: ……定性理由（Rule 53.1 口径）
```

判定依据（attest-plan.sh :121-151 第一手）：非 mini 计划 fail-closed 四锚 grep——
`^## 🎯 用户需求原文` / `^- \*\*R[0-9]` / `R→VC 映射` / `根源覆盖表`，任一缺失 exit 1。
各夹具为纯动作型测试目标（非结果级需求），第 4 锚按 53.1 口径写「不适用（非结果级）」
+定性理由（该声明行即算在位，attest-plan.sh :126 注释口径）。未用 plan_tier: mini
豁免路径——按任务书「只让夹具过新门」原则走四锚正解，mini 豁免会绕过门的正向
测试面，与本批清账意图不符。

## 2. 重跑证据（原文）

逐脚本日志 /tmp/v131-sunit1/*.log，Total/结果行原文：

```
selftest-active-plan.sh          Total: 19 PASS=19 FAIL=0            exit=0
selftest-execution-stability.sh  Total: 19  PASS=19  FAIL=0          exit=0
selftest-methodology.sh          Total: 16 PASS=16 FAIL=0           exit=0
selftest-plan-dispatch.sh        Total: 12 PASS=12 FAIL=0           exit=0
selftest-final-gate-hash.sh      ==== 结果: PASS=22 FAIL=0 ====     exit=0
                                  [PASS] setup: 沙箱 skill 副本+夹具计划+attest 锁定就绪
```

交叉复验（消费方脚本零破坏）：selftest-root-resolution 重跑 Total: 15 PASS=15 FAIL=0 exit=0。

## 3. 保留不动说明（「无区块拒锁」类场景排查）

逐夹具核对：5 脚本内无「故意缺 51.1 区块验证拒锁」类负例——51.1 门的负例测试由
上游 S-unit（attest-plan.sh 自身门控）与 selftest 其余脚本覆盖，本批夹具均为
「锁定成功」正向路径的载体。全部补锚，无保留项。

## 4. 负结果/风险排除

- git status --short = 仅 5 个目标文件 M（diff --stat: 5 files, +89/-6），任务范围外零触碰
- methodology M-10 sed 锚点 `| 140 |  |` 在改后夹具中仍在位（M-10 PASS 为证）
- final-gate-hash 夹具⑥ sed 锚点 `- **Executor:** 主进程（白名单①：git 编排）` 未受追加区块影响（PASS=22 全绿为证）
- 未 commit（按任务书要求，留待 Phase 7 CR 合并）

## 5. 收尾自检

- 无新增 /tmp 残留（日志存 /tmp/v131-sunit1/，可清理非必须）
- worktree 工作树仅含本批 5 文件变更，可交主进程回归 7 脚本全量复跑（含根因 B 批
  dispatch FG-01 / fine-grain-steps SG-04 的 L-1 advisory 期望更新，本 S-unit 范围外）
