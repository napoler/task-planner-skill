# Verification Contract & Phase Gates

## Goal (1 sentence)

落地 Rule 35 执行结论纪律（能力否定三关 + 大输入落盘引用补救 + 四点同步 + 新 selftest 守护），全量 selftest 0 FAIL 后合并 master、部署 3 实体位并 push GitHub。

---

## Verification Contract（终验复验 2026-09-16）

- [x] VC-1: critical-rules.md 新增 `### 35 执行结论纪律` 含 35.1-35.6 六子条
  Evidence: worktree 提交 ee606b7（已并入 master be5cfbf）；主进程 Read 复核 L292 标题 + L294-299 六子条逐字在位；`grep -c '^35\.[1-6] \|^### 35 '` = 7
- [x] VC-2: SKILL.md 四点同步且 ≤540 行
  Evidence: 提交 ee606b7；wc -l = 538（净增恰 3：C23=L197、Rule 35 列表行=L303、兜底注=L412）；`grep -c '1-35'` = 3 且 `grep '1-34'` 零命中（L9 全集/L278/L327 三写法全覆盖）
- [x] VC-3: check-dispatch.sh L258 超限提示附落盘补救指引且 selftest-dispatch 全 PASS
  Evidence: 提交 ee606b7；L258 原行一字未动（`grep -cF '⚠ prompt 长度 $pchar > $pmax'` = 1）+ L259 补救行（Rule 35.3）；主进程复跑 selftest-dispatch = 22 PASS / 0 FAIL
- [x] VC-4: selftest-conclusion-discipline.sh PASS + 全量 20 脚本逐 Total 求和 0 FAIL
  Evidence: 提交 e41be0e；CD-01..17 全过（主进程复跑）；P4 全量 20 脚本全 rc=0，主进程 awk 机械求和 = **330 PASS / 0 FAIL**（=313 基线 + 17 CD；runner 自报 313 系算术错已修正，awk 输出 total_lines=20 PASS=330 FAIL=0）
- [x] VC-5: smart-merge-back 合并 master + 3 部署位 diff=0 + push origin
  Evidence: merge commit **be5cfbf**（V1-V6 预检全过）；`git push` 输出 e8b10a7..be5cfbf master->master，`git status -sb` 本地=远端；三部署位 diff -r 复验 IDENTICAL（~/.zcode 显式 rm+cp 重部署；~/.claude、~/.config/opencode 脚本对账假 IDENTICAL 后主进程 diff 实证 DRIFT 并重部署，见 progress Error Log）；worktree remove + branch -d 零残留

**终验规则**: 全部 VC 通过 → COMPLETE ✓

---

## 委派统计复验（Rule 25.4）

JSON（check-delegation.sh stats 原文摘要）：phases_total=5, phases_delegated=2, main_direct_count=3, delegation_rate=0.400, violations=[], **verdict=ok**
- [x] 主进程直做 Phase 白名单理由：P1=①纯 git/worktree 编排；P4=③机械验证/簿记（求和+CHANGELOG 1 行）；P5=①git 编排+③簿记——全部命中 Rule 25.3 六项白名单 → **WHITELIST-EXEMPT 放行**
- [x] 实际子代理派发 8 次（Explore 考古/plan-writer/code-runner×2/executor×4），严格串行零并行
- [x] 委派率 < 0.7 但全直做理由在册且 verdict=ok → check-complete 不阻断

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查：触发 0 项（无降质行为：无伪造证据——全部产出主进程 Read/复跑复核；无静默失败——2 处部署对账假 IDENTICAL 与 runner 算术错均即时曝光修正）
- [x] Evidence 抽查 ≥3 条：critical-rules.md L292-299（Read）、三部署位 diff -r（命令复现）、awk 求和 330/0（命令复现）——均可复现
- [x] 豁免登记：无
- [x] 未处置违规：无 → outcome 不降级

## Goal Gate（终验）

```
## Goal Verification — Rule 35 执行结论纪律交付
- [x] VC-1: critical-rules.md:292-299 + L127（grep 7 锚）→ PASS
- [x] VC-2: SKILL.md 538 行四处同步（grep 1-35×3、1-34×0）→ PASS
- [x] VC-3: check-dispatch.sh:258-259 + selftest-dispatch 22/22 → PASS
- [x] VC-4: CD 17/17 + 全量 20 脚本 330/0（awk 求和）→ PASS
- [x] VC-5: merge be5cfbf + 3 位 IDENTICAL + push 完成 → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

Deferred（不阻塞交付，登记后续）：
1. README.md:67 / references/batch-quality-gate.md:130 的 `Rules 1-27` 滞后静态描述（早于本任务存在，非锚断言）
2. smart-merge-back.sh --deploy 对账基准疑报假 IDENTICAL（本次 claude/opencode 位实际为合并前内容，主进程 diff 实证后重部署；建议后续轮核查其对账比对基准）
3. plan-writer 派发契约需补「S-unit ID=纯数字」（本次已在 CD selftest 头注释沉淀，plan-writer agent 契约行下轮同步）
