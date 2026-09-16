# Verification Contract & Phase Gates

## Goal (1 sentence)

逐项修复 v076 交付登记 4 个问题（smart-merge-back 部署源假 IDENTICAL 根因 / 两处 Rules 1-27 滞后 / S-unit ID 纯数字契约缺失 / 统计类禁自报汇总缺失）并守护、回归、部署 push。

---

## Verification Contract（终验复验 2026-09-17）

- [x] VC-1: smart-merge-back.sh 部署源与对账基准换为主仓 skills/task-planner
  Evidence: worktree 提交 496b8b0（并入 master 6a37279）；`grep -c 'DEPLOY_SRC'` = 10；cp（L528）/diff（L555）换源，fail-closed 源缺失分支显式 DRIFT（L367-371，禁回退 SKILL_ROOT）；自位 REJECTED 消息带处置指引；头注释 L15-17/L44/L84/L89 与尾注同步；主进程 Read 复核 + 手工冒烟三条全过
- [x] VC-2: selftest-smart-merge.sh 新增 SM-14（陈旧副本运行→槽位终态==主仓内容）PASS 且 SM-01..13 全 PASS
  Evidence: 主进程一手复跑 `Total: 15 PASS=15 FAIL=0`；SM-14 行原文 `slotB-SKILL_MARKER=canonical-v077(期望canonical-v077非stale-content)` PASS；SM-06 fixture 修复后恢复 PASS
- [x] VC-3: 两处 Rules 1-27→Rules 1-35 且全仓活跃文件 0 残留
  Evidence: skills/task-planner/README.md:67 与 references/batch-quality-gate.md:130 改 1-35（主进程 Read 复核）；`grep -rn 'Rules 1-2[0-9]' skills/ README*.md` = 0
- [x] VC-4: 四契约点就位 + CD selftest 新增断言全 PASS
  Evidence: plan-writer.md:117（s_unit_id 行）/ templates/task_plan.md:187（④ 注释）/ subagent_dispatch.md:55（禁自报汇总）/ critical-rules.md:129（22.4b 行内子句）；CD selftest 主进程复跑 `Total: 23 PASS=23 FAIL=0`（CD-18..23 逐行核过，计数 17→23 头注释同步）
- [x] VC-5: 全量 20 脚本 0 FAIL + merge master + 3 部署位 diff=0 + push origin
  Evidence: 主进程 awk 机械求和 `total_lines=21 PASS=337 FAIL=0`（=330 基线+CD6+SM14，逐行=p4-regression.md）；merge commit **6a37279**（V1-V6 全过）；**主仓副本执行 --deploy 三位 IDENTICAL sm-rc=0（修复生产首跑即生效，.zcode 位不再 REJECTED）**；主进程 diff -r 三位亲验=0；push 5ad18f6..6a37279；worktree/分支清零

**终验规则**: 全部 VC 通过 → COMPLETE ✓

---

## 委派统计复验（Rule 25.4）

JSON（check-delegation.sh stats）：phases_total=5, phases_delegated=2, delegation_rate=0.400, violations=[], **verdict=ok**
- [x] 主进程直做 Phase 白名单理由：P1=①git 编排+③机械求和；P4=②CHANGELOG 簿记+③求和；P5=①git 编排+③簿记 → 全部命中 Rule 25.3 → **WHITELIST-EXEMPT 放行**
- [x] 子代理派发 7 次（Explore 1 / plan-writer 1 / code-runner 2 / executor 3），严格串行；过程中 3 次派发守卫拦截均按提示修正（brief 引用/干净路径/35.3 任务书落盘）
- [x] plan-writer 空响应事故按 22.8 落盘核查后主进程白名单②补写 knowledge-brief（Error Log 有档）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查：触发 0 项（无伪造证据——全部产出主进程 Read/复跑/复核；无静默失败——Handoff token 误报、compass 指向已交付计划等均即时曝光登记）
- [x] Evidence 抽查 ≥3 条：SM-14 反 regression 钉子（复跑 15/15）、三位 diff -r（命令复现）、awk 337/0（命令复现）——均可复现
- [x] 豁免登记：无
- [x] 未处置违规：无 → outcome 不降级

## Goal Gate（终验）

```
## Goal Verification — v076 deferred 4 项逐个修复交付
- [x] VC-1: DEPLOY_SRC 换源 + fail-closed + 注释同步（grep=10 + Read）→ PASS
- [x] VC-2: SM-14 钉子 + SM 15/15（主进程复跑）→ PASS
- [x] VC-3: 两处 1-35 + 全扫 0 残留 → PASS
- [x] VC-4: 四契约点 + CD 23/23（主进程复跑）→ PASS
- [x] VC-5: 337/0 + merge 6a37279 + 三位 IDENTICAL + push → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

Deferred（不阻塞交付）：
1. plan-compass 提醒链对已交付（complete）计划无豁免，反复误报 v076 文件——建议下轮加 complete 状态豁免（Error Log 有档）
2. check-dispatch 打包检测把契约条文中的示例 ID（S2a 等）计为打包——本次以 35.3 任务书落盘绕过；如需根治可下轮给 check-dispatch 加引用文件豁免扫描（登记候选）
