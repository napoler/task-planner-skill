# Verification Contract & Phase Gates

## Goal (1 sentence)
落地 Rule 51「需求覆盖与完成声称门控」六子条+delivery-summary 需求覆盖核对区块+SKILL 四锚+selftest 守护，全量 selftest 0 FAIL 后合并 master 并部署 3 位 IDENTICAL，根治 videop1 式虚假完成。

---

## Verification Contract (终验复验记录，2026-10-04)

- [x] VC-1: Rule 51 六子条完整（51.1-51.6 纯增量追加 :521-530，范式对齐 Rule 49）
  Evidence: `grep -c '^51\.'` =6；`grep -n '^### 51 '` = critical-rules.md:522；numstat 10/0；Rule 49 块 `^49\.`=5 零损伤 → **PASS**
- [x] VC-2: SKILL.md 四锚 + 行数断言级联
  Evidence: :201 C35 行（`^| C35 |`，含 ☐ 状态列）、:249 括注 `…/47/48/49/51`、:286 bullet（术语=需求原文锚定）、:310 表行 51 前插；`grep -c 'Rules 1-39'`=2 且 `'1-40'`=0；SKILL=451 行=selftest-skill-split.sh:41 断言 ≤451（41/41 PASS）→ **PASS**
- [x] VC-3: delivery-summary「需求覆盖核对」区块
  Evidence: templates/delivery-summary.md:35-41（无编号标题），`grep -cE '^## [1-5]\.'`=5（TL-19 保持）、TL-22 三锚在位；RC-12 断言 `^## 需求覆盖核对（Rule 51.3` 锚定标题形态 → **PASS**
- [x] VC-4: selftest-requirement-coverage.sh + registry + 全量回归
  Evidence: 新脚本 15 断言 `Total: 15 PASS=15 FAIL=0`；registry.tsv=47 行（NF=4）；**主进程三次独立复算 46 脚本 PASS_SUM=717 FAIL_SUM=0**（702 基线+15 新增，与 S6 自报一致）→ **PASS**
- [x] VC-5: 合并回 master + 部署 3 位 IDENTICAL + 清理 + 簿记
  Evidence: merge 6410f8c（--no-ff，`master..wt/task-v129`=0）；三位对账 zcode/claude/opencode 全 IDENTICAL（zcode 位 selftest=46，运行位自保护 REJECTED 后按脚本指引手动原子换位）；worktree 已 remove+branch -d；INDEX 已刷 → **PASS**
- [x] VC-6: Rule 31 学习闭环 + dogfood 首例
  Evidence: progress.md Error Log 7 行 Root Cause 全非占位（含 videop1 本案归因）；findings F-5 四维归因表；notepad What Didn't Work 3 条+Notes for Next Time 4 条；本文件下方「需求覆盖核对表」=R1-R4 逐条判定（51.3 首例实践）→ **PASS**

---

## 🎯 需求覆盖核对表（Rule 51.3 dogfood 首例 — 逐用户需求判定）

| 需求# | 用户原话（摘） | 判定 | 证据路径 |
|-------|--------------|------|---------|
| R1 | 「我要求的归档非多维只保留多维视图 你完全没有做」 | **covered** | 治理面：51.4 自缩水禁令在位（critical-rules.md:528，含 silent 注记）+判例文本入条款；现场面：videop1 masters/characters 现工作区非多维残留=0（归档随 3845ce9 等提交入库，archive/characters 137 件） |
| R2 | 「主角图都使用了多次你做什么 浪费时间吗？」 | **covered** | 51.5 生成前置盘点在位（critical-rules.md:529，零需求禁生成+判例 17 次生成）；浪费根因入 Error Log 行 1+findings F-2/F-5 |
| R3 | 「先设定目标以及设计验证…流程的失控或者说缺失」 | **covered** | 51.1/51.2/51.3 三子条（:525-527）+C35（SKILL:201）+delivery-summary 区块（:35）+RC-01..15 守护；check-complete「需求」零命中缺口的机器深化登记 deferred（计划 Decisions 已裁决，非缩水——正文条款+人工门+模板区块三层已落地） |
| R4 | videop1 只取证不改动（跨项目隔离） | **covered** | 本任务全程零写入 videop1（CR/S7 审查亦只读）；其收尾由 videop1 侧会话自行完成（归档已入库） |

> 判定规则：任一用户显式核心需求 uncovered/partial 且无用户让步登记 → 禁 COMPLETE。本表 4/4 covered。

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| SKILL.md 全文（C 清单+Rule 摘要） | Phase 2 锚扫描+Phase 3 联动落地 | 符合 |
| critical-rules.md Rule 45-49 范式 | S1 追加块格式对齐（`### 51 `/行首 `51.`） | 符合 |
| v126/v128 计划范式与编号注记 | 编号 51 裁决引用 v128 :7 注记 | 符合 |
| videop1 事故档案+用户原话 | findings R1-R4+F-1/F-2 全程引用 | 符合 |
| selftest-lane-advancement.sh 范式 | S5 新脚本结构同构（S7 审查确认） | 符合 |

## 委派统计复验（Rule 25.4）
- 子代理执行 Phase：Phase 3（S1-S5 五派发）+ Phase 4（S6/S7/S8 三派发+2 fix-phase）= 2/5
- 主进程直做：Phase 1（白名单② 簿记+取证回填）/ Phase 2（白名单⑤ 设计决策）/ Phase 5（白名单① git 编排+② 簿记+部署原子换位=脚本指引的手动动作）——全部计划 Executor 字段登记白名单内理由
- 委派率 0.4 < 0.7 → **WHITELIST-EXEMPT**（直做理由均命中 Rule 25.3 六项白名单②⑤①；派发子代理 9 次成功+7 次守卫拦截重派全部留痕 Handoff 表）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 核查：触发 0 项违规；Rule 43 证据先行全 VC 附机器可复现证据；Rule 18 非批量任务不适用
- [x] Evidence 抽查 ≥3 条：VC-1 grep 复跑=6 / VC-4 主进程复算 46/717/0 / VC-5 三位 diff 均可复现
- [x] 豁免登记：无用户文字豁免项；deferred 5 项（见交付总结风险区）均不阻断本 VC

## Goal Gate (终验)
```
## Goal Verification — Rule 51 落地+部署
- [x] VC-1 → PASS（grep 51.x=6；:522 标题）
- [x] VC-2 → PASS（四锚+451=断言值；主锚 2/0）
- [x] VC-3 → PASS（:35 区块；TL-19=5）
- [x] VC-4 → PASS（15/15+47 行+46/717/0）
- [x] VC-5 → PASS（merge 6410f8c；三位 IDENTICAL；清理完成）
- [x] VC-6 → PASS（Error Log/notepad/四维表/覆盖核对表首例）
 outcome: COMPLETE
```

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 5 终验（全 Phase complete） |
| 2 | Where am I going? | check-complete → memory → 交付总结 |
| 3 | What's the goal? | Rule 51 需求覆盖与完成声称门控落地（本文件 Goal） |
| 4 | What have I learned? | findings.md F-1~F-7 |
| 5 | What have I done? | progress.md Phase 1-5 |
| 6 | Which tasks need processing? | v124/v125/v127/v128 在途（他会话）；本案无遗留阻塞 |
