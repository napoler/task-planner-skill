# Verification Contract & Phase Gates

## Goal (1 sentence)

修复两类守卫误报（提醒链已交付计划误报 + check-dispatch 打包检测误计示例 ID），各自 selftest 守护，全量 0 FAIL 后合并 master、主仓副本执行部署 3 位并 push。

---

## Verification Contract（终验复验 2026-09-17）

- [x] VC-1: zcode-posttooluse.sh verification.md 兜底豁免
  Evidence: worktree 提交（并入 master af49bf9）；L103-105 新增兜底分支（复用既有 plan_dir 变量，同 `outcome:` 正则 grep -qi）；`grep -n 'verification.md'` = 3 处；行为三重因果对照（有 COMPLETE→无提醒 / 无 verification.md→仍提醒 / 禁用新分支对照→仍提醒）
- [x] VC-2: check-dispatch.sh 打包检测双条件豁免
  Evidence: L264-277（「任务书」+`subagent-state/` 双条件 → SKIPPED 提示不计数，既有逻辑进 else 分支零改动）；enforce 双向实测：豁免 prompt RC=0+SKIPPED 文案 / 去豁免词对照 RC=2+S-unit ID 文案
- [x] VC-3: selftest-dispatch.sh FG-05 新增 + FG-03 回归保护
  Evidence: 主进程复跑 `Total: 23 PASS=23 FAIL=0`（FG-03 无豁免词仍被检测、FG-05 豁免生效）
- [x] VC-4: selftest-execution-stability.sh T13a/T13b 行为用例
  Evidence: 首版非密闭缺陷（固定 sid state 持久 → 重跑落冷却窗口）主进程复跑 FAIL 实证、bash -x 确诊、ST13_SID 唯一化修正后主进程连续两遍 `Total: 19 PASS=19 FAIL=0`（密闭性证明）；T11a/b 无回归
- [x] VC-5: 全量 20 脚本 0 FAIL + merge + 3 部署位 diff=0 + push
  Evidence: 主进程 awk `PASS=340 FAIL=0`（=337 基线+FG-05 1+T13a/b 2，逐行=p4-regression.md）；merge commit **af49bf9**（主仓副本执行，部署输出含 v077 新基准文案）；diff -r 三位亲验 IDENTICAL；push 187194b..af49bf9；worktree 清零（v079 并行会话 worktree 属他者不碰）

**终验规则**: 全部 VC 通过 → COMPLETE ✓

---

## 委派统计复验（Rule 25.4）

JSON（check-delegation.sh stats）：phases_total=5, phases_delegated=2, delegation_rate=0.400, violations=[], **verdict=ok**
- [x] 主进程直做 Phase 白名单理由：P1=①git 编排+③机械求和；P4=②簿记+③求和；P5=①git 编排+③簿记 → 全部命中 Rule 25.3 → **WHITELIST-EXEMPT 放行**
- [x] 子代理派发 8 次（Explore 1 / plan-writer 1 / code-runner 2 / executor 4 / code-assistant 1），严格串行
- [x] 流程偏差披露：委派守卫 enforce 化后，S7 主进程直做 CHANGELOG 被拦 → 按守卫指引改派 code-assistant（Handoff 行 8 登记）；S5 诊断由主进程 bash -x 完成、机械修正派发 executor（Handoff 行 6 rescue 列登记）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查：触发 0 项（T13 非密闭缺陷在交付前被主进程复跑捕获并修正；variant 游离改动留档还原——均无静默）
- [x] Evidence 抽查 ≥3 条：T13b 因果对照（复跑两遍 19/0）、打包豁免 enforce 双向实测（RC0/RC2）、awk 340/0（命令复现）
- [x] 豁免登记：无
- [x] 未处置违规：无 → outcome 不降级

## Goal Gate（终验）

```
## Goal Verification — v077 deferred 两项守卫误报修复
- [x] VC-1: 提醒链 verification.md 兜底（grep=3 + 行为三重对照）→ PASS
- [x] VC-2: 打包双条件豁免（enforce 双向实测）→ PASS
- [x] VC-3: FG-05 + FG-03 回归保护（23/23）→ PASS
- [x] VC-4: T13a/T13b 密闭化（19/0 连续两遍）→ PASS
- [x] VC-5: 340/0 + merge af49bf9 + 三位 IDENTICAL + push → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

Deferred（不阻塞交付，登记后续）：
1. plans/task-v079-skill-modify-conservatism/ 并行会话存根与其 worktree（属他者会话，本任务全程未碰；若为用户所建请自行推进）
2. 修复前历史遗留的 zcode 挂账：lib/verify.sh 全量口径与 selftest-*.sh 逐个跑口径并存（本次沿用后者，无回归）
