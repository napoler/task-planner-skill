# Verification Contract & Phase Gates

## Goal (1 sentence)

Rule 76「总结阶段格式可读性与审查清单实体化纪律」在用户面三载体（delivery-summary/媒体审查 variant/SKILL 导览）落地，并由 selftest-summary-readability.sh+report-lint 机器守护、零回归交付。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: Rule 76 六子条完整落盘（76.1-76.6 各锚可 grep；适用范围/编号列表规范含但书/审查清单表格/五要素联动/边界/守护机制六域）
  Evidence: `grep -cE '^76\.[1-6] ' critical-rules.md` = 6；标题锚 `Rule 76（总结阶段格式可读性与审查清单实体化纪律 — task-v166）` = 1（critical-rules.md:1003-1018）；sub:3 checkpoint
- [x] VC-2: SKILL.md 接线四处（索引 1-76 三处；Rule 76 bullet 在位；C55 行在位（并集后 Rule 75=C54，Rule 76=C55）；终验交付段联动句在位）
  Evidence: `grep -c '1-76' SKILL.md` = 3；`grep -c 'Rule 76' SKILL.md` = 6；`grep -c '^| C55 | .*Rule 76'` = 1；`grep -qF '用户面总结/呈报的列表一律编号列表'` = 1；sub:4/5 checkpoints
- [x] VC-3: delivery-summary.md 审查清单表格段在位（表头含「文件名」「路径」「描述」三列）；白名单载体装饰圈号清零
  Evidence: delivery-summary.md:51-55（§3 审查清单+三列表头+示例行）；`grep -cE 'Phase [0-9]+: [①-⑨]'` image-type.md=0 / multiview-ref-type.md=0（原 7/5）；主进程独立实测
- [x] VC-4: selftest-summary-readability.sh ≥13 断言 PASS rc=0；registry 登记；registry 自检 PASS
  Evidence: 自跑 `Total: PASS=13 FAIL=0 WARN=0 rc=0`；`selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=77, actual selftest=77)`（并集后 77 脚本；口径校正：计划期预期 74 为算术笔误，机器不变量=rows=实际脚本数，登记于 findings 闭合台账 F-5）
- [x] VC-5: 全量回归两轮独立子代理 ΣFAIL=0（主进程逐行独立求和）；级联脚本各自 PASS
  Evidence: round1（sub:16）76/76 exit=0；round2（sub:18，全新上下文）76/76 且与 round1 Total 行 BYTE-IDENTICAL；round4（sub:24，fix 后）76/76；并集解后 round5（sub:27：77 脚本含 v163 proactive-research）+合并前终跑（sub:29）77/77 rc=0 断言合计 726 PASS/0 FAIL；SRV-12 复验 9/9
- [x] VC-6: 双审 APPROVED（alignment + code-quality）；12 条问题逐条闭合
  Evidence: sub:19 CHANGES_REQUESTED×5 + sub:20 CHANGES_REQUESTED×7 → fix-wave1（21a-21d）+fix-wave2（23a-c）逐条修复→round4 复跑 76/76；闭合台账 findings §[sub:main-23d]
- [x] VC-7: merge-back merged(commit)；部署位对账 diff=0；rule 76 landed；INDEX 登记；delivery-summary 落盘
  Evidence: master merge commit 0d57483（`git log --oneline -1`）；部署位对账=smart-merge-back --deploy 输出「全部部署位 IDENTICAL(基准=主仓 skills/task-planner)」；`rule-reserve.sh land 76 task-v166-summary-readability` → 「rule 76 landed by task-v166-summary-readability (was reserved)」；plans/INDEX.md v166 行（complete 5/5 ✓）+底部队列；plans/task-v166-summary-readability/delivery-summary.md 在档

**终验规则**：全部 VC 通过 → outcome: **COMPLETE**

---

## Phase Gates

### Phase 1: 格式现状审计

**Goal**: 摸清用户面载体圈号分布与审查清单缺失面

**Depends on**: none

**Done when**:
- [x] findings.md §格式现状审计+§variant 审计落盘（file:line 锚齐全）
- [x] v161 边界确认行在档

**Verification**:
- [x] V-1.1: 主进程独立复核 grep 计数一致（image=7/multiview=5/v161=3）→ VC-3
- [x] V-1.2: 缺失面 R1/R3/R4 差距定位 → VC-1/VC-3

Status: `complete` Last verified: 2026-10-11

---

### Phase 2: Rule 76 条文落盘 + SKILL 接线

**Goal**: 六子条入 critical-rules.md + SKILL 四处接线

**Depends on**: Phase 1

**Done when**:
- [x] 六子条 grep=6；索引 1-76×3；C54 在位；联动句在位；互引×2

**Verification**:
- [x] V-2.1: sub:3/4/5 各 3-6 项验收全 PASS → VC-1/VC-2
- [x] V-2.2: 主进程复核（grep 实测+diff 单文件）→ VC-2

Status: `complete` Last verified: 2026-10-11

---

### Phase 3: 模板面改造

**Goal**: delivery-summary 审查清单表格化 + variant 编号列表化 + report-lint 扩展

**Depends on**: Phase 2

**Done when**:
- [x] §3 表段在位、段落编号连续、装饰圈号清零、report-lint 三查 fail-open

**Verification**:
- [x] V-3.1: 表头三列+§1-6 连续（主进程复核）→ VC-3
- [x] V-3.2: harness 四态 RC=0（SKIPPED/缺陷/合规/注入）→ VC-4

Status: `complete` Last verified: 2026-10-11

---

### Phase 4: 机器守护 + 两轮回归

**Goal**: SRV 13 断言+级联锚扩+两轮独立回归

**Depends on**: Phase 3

**Done when**:
- [x] 12 脚本 anchor 演进；round1/round2 独立 76/76；双审问题 12 条闭合；round4 76/76

**Verification**:
- [x] V-4.1: SRV 夹具实证（缺表 FAIL/圈号 FAIL）→ VC-4
- [x] V-4.2: round1+round2+round4 三轮 ΣFAIL=0 → VC-5

Status: `complete` Last verified: 2026-10-11

---

### Phase 5: 双审 + 合并回 + 簿记

**Goal**: 双审 APPROVED 后合并回主仓并落盘全部簿记

**Depends on**: Phase 4

**Done when**:
- [x] 12 条问题闭合（fix-wave1/2）
- [x] worktree 提交 6bf39a5（19 文件）+并集 merge 0a2d583+索引修正 5a7fc29
- [x] merge-back 0d57483 --deploy（部署位 IDENTICAL）+rule 76 land+INDEX 登记+delivery-summary 在档

**Verification**:
- [x] V-5.1: 双审 verdict+闭合台账 → VC-6
- [x] V-5.2: merge commit 0d57483 + land 输出 + INDEX 行 → VC-7

Status: `complete` Last verified: 2026-10-11

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| Rule 70 条文 | 76.2 但书+互引指针[:938] | 符合（子条编号引用豁免语义一致） |
| Rule 72 条文 | 互引指针[:980] | 符合 |
| delivery-summary.md 模板全文 | §3 改造+编号顺延 | 符合（五要素/定位三要素不变量保留） |
| selftest-report-reviewability.sh 范式 | 新脚本骨架 | 符合（chk/ok/ng/Total/rc 范式一致） |

## 委派统计复验（Rule 25.4）

```bash
bash <skill>/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":3,"main_direct_count":2,"delegation_rate":0.600,"main_direct":[{"phase":"Phase 2","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单"},{"phase":"Phase 5","reason":"例外理由:① git 编排+② 簿记——Rule 25.3 白名单"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单：②计划系统文件维护+①git 编排②簿记）
- [x] 委派率 0.600 < floor 0.7 但全部直做理由命中白名单 → WHITELIST-EXEMPT 放行（stats verdict=ok violations=0）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（无质量违规触发面）
- [x] Evidence 抽查 ≥3 条:抽查 5 条（critical-rules.md:1003 六子条/SKILL.md:9 索引/delivery-summary.md:51 表段/variant grep=0/selftest 自跑 13/13），路径可 Read、结论可复现
- [x] 豁免登记:项号/范围/理由/日期 — P2-b variant HTML 头注释圈号（Rule 76.1 适用范围外）/2026-10-11（findings §[sub:main-23d]）
- [x] 无未处置违规

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — Rule 76 用户面总结格式可读性与审查清单实体化落地
对照 Verification Contract 逐条复验：
- [x] VC-1: grep=6+标题锚 → PASS
- [x] VC-2: 1-76×3/Rule76×6/C54/联动句 → PASS
- [x] VC-3: §3 三列表头+装饰圈号 0/0（原 7/5） → PASS
- [x] VC-4: SRV 13/13 rc=0+registry rows=76=脚本数 → PASS
- [x] VC-5: round1/2/4 三轮 76/76 ΣFAIL=0（双轮独立 BYTE-IDENTICAL） → PASS
- [x] VC-6: 双审 12 条闭合+round4 复跑 76/76 → PASS
- [x] VC-7: merge-back+land+INDEX+delivery-summary → PASS（合并回后回填）

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

> **验证独立性**：终验核查动作（两轮独立回归/双审/round3+round4）由全新独立子代理执行（sub:16/18/19/20/22/24），主进程仅编排与簿记。

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 5 收尾（merge-back+land+INDEX+delivery-summary） |
| 2 | Where am I going? | VC-7 回填后 check-complete 全门 → COMPLETE |
| 3 | What's the goal? | Rule 76 三载体落地+机器守护+零回归 |
| 4 | What have I learned? | findings.md（第二轮级联教训+P2-b 豁免） |
| 5 | What have I done? | progress.md（P1-P4 complete） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
