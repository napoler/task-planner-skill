# Verification Contract & Phase Gates

## Goal (1 sentence)

按标准 4+3 方案拆分 task-planner 技能：4 卫星技能承接非核心段落 + 3 段内敛，主 SKILL.md 556→429 行（-22.8%），selftest 全绿 + 锚点全在 + 机械门控零改动为行为不变判据。

---

## Verification Contract (final checks)

- [x] VC-1: 主 SKILL.md ≤430 行且锚点全在
  Evidence: `wc -l skills/task-planner/SKILL.md` = **429**（master aa092cc+bea7341）；锚点全集 24 项逐条 grep 全在位（progress.md P6 段：Rule 摘要行/C19/C25/C26/Rules 1-3×2/T-B6 双固定串/knowledge-brief=2/collab.md=5/skill_collab_enforce=1/四族名等）；subagent-state/81-p8-cr.md CR 复核 22 项锚全命中
- [x] VC-2: 全量 selftest 0 FAIL 且 ≥ 基线
  Evidence: P1 基线 34 脚本 543/0（progress.md Phase 1 段）；终验 **35 脚本 584 PASS / 0 FAIL**（543+41 新增 selftest-skill-split 断言；P7-S2 主进程独立复验）；部署位 .zcode 实跑 selftest-skill-split 41/41+registry 5/0
- [x] VC-3: 4 卫星目录存在且 frontmatter 合规 + 迁移映射 100% tick
  Evidence: skills/{plan-research-router,plan-template-kit,plan-cost-guard,plan-collab-router}/{SKILL.md,references/} 在 master 与三部署位；frontmatter name=目录名（selftest-skill-split T1 机检 41/41）；findings.md 迁移映射表 M1-M13 全 tick（M1-M12 执行期勾验，M13 P7 兑现）
- [x] VC-4: 三部署位 diff -r 与 canonical 一致
  Evidence: 五技能×三位 diff -rq = **15/15 IDENTICAL**（progress.md Phase 7 段）；CR 风险②「逐字节 diff」由本次 diff -rq 兜住（CR 时点仅存在性验证，S4 后补全）
- [x] VC-5: check-skill-modify 保护 pattern 覆盖卫星路径（行为级）
  Evidence: P7-S1 验证链 c——卫星路径 warn 档注入 [skill-modify-warn]/enforce 档 BLOCKED exit 2/非保护路径静默，三分支实测（subagent-state/71-p7-s1.md）
- [x] VC-6: CR APPROVED
  Evidence: code-reviewer verdict=**APPROVED**（0 Blocker/0 Suggestion/2 Nit；subagent-state/81-p8-cr.md）；Nit1（重复行）已修 bea7341+selftest 9/0+41/0；Nit2（config.json:99 描述文本）按 config 零改动约束登记 deferred

---

## Phase Gates（8/8 complete，明细见 task_plan.md Phases 区块与 progress.md 各段）

| Phase | 内容 | Status | 关键证据 |
|-------|------|--------|---------|
| P1 | 基线冻结+隔离区 | complete | 543/0 基线；worktree@5c1cdcd；v094 已合并 F3 解除 |
| P2 | 试点 plan-research-router | complete | 556→519；T11×3 断链修复；543/0 |
| P3 | plan-template-kit | complete | git mv×2+计数 16；TL18/MP19/KB16/白名单 17/attest exit0 |
| P4 | plan-cost-guard | complete | 三件套迁移+九处指针化；543/0 |
| P5 | plan-collab-router | complete | 七文件同步+WF-09 意外修复；543/0 |
| P6 | 收尾内敛 | complete | SKILL.md 429 行；锚点 24 项；T6 窗口随迁 |
| P7 | 安装面+合并+部署 | complete | 584/0；merge aa092cc；15/15 IDENTICAL |
| P8 | CR+终验 | complete | APPROVED；Nit1 修复；本文件 |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 结构测绘报告（01-explore §A-D） | 各 S-unit 派发均引用其锚点行号；三处测绘外内容锚（T11/TB-11/WF-09/T6）由预防性断言清点兜住 | 符合（清单不全的缺口已被预防措施补偿，见 Error Log） |
| 计划撰写简报（02-brief §2.3 硬约束） | P6-S3 锚点全集逐条 grep=24 项全在位；机械层零改动经 CR diff --name-status 核实 | 符合 |
| skill-creator 规范 | 4 卫星 frontmatter name=目录名/description 触发词+排除项/正文 34-41 行薄/**<500** | 符合（CR 第 4 项 PASS） |

## 委派统计复验（Rule 25.4 — 机器事实源）

```json
{"phases_total":8,"phases_delegated":5,"main_direct_count":3,"delegation_rate":0.625,"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均登记白名单内例外理由（P1=①③基线验证/worktree 管理；P7=③git 合并+①部署+③机械验证；P8=⑤CR 编排+②终验簿记）——rate 0.625<0.7 但全部直做理由命中 Rule 25.3 白名单 → **WHITELIST-EXEMPT 放行**
- [x] violations=0（Handoff 22 行纯 token 登记完整；executor(sonnet-1) 括号后缀教训第 3 次复发已当场修正并记 Error Log）

## 质量门控统计（Rule 26）

- [x] Q1-Q6 核查：触发 1 项（Q2 类=subagent 汇报口径误差「35 脚本」glob 误计，已当场纠正并以主进程实测为准，不构成违规）；豁免 0 项；未处置 0 项
- [x] Evidence 抽查 ≥3 条：① VC-1 行数 429（master 实测 wc）② VC-4 部署 15/15 IDENTICAL（progress P7 段命令级记录）③ CR 检查点 81-p8-cr.md 锚点 22 项 grep 明细——均可 Read 复现
- [x] 豁免登记：无用户显式豁免项；Q3（内容质量门控）不适用（refactor 类型非 writing/research/publish）
- [x] 未处置违规：无（outcome 无需降级）

## Goal Gate（终验）

```
## Goal Verification — 4+3 拆分，SKILL.md ≤430 且行为不变
- [x] VC-1 → PASS（429 行+锚点 24 项）
- [x] VC-2 → PASS（35 脚本 584/0 ≥ 基线 543/0）
- [x] VC-3 → PASS（4 卫星合规+M1-M13 全 tick）
- [x] VC-4 → PASS（15/15 IDENTICAL）
- [x] VC-5 → PASS（守卫三分支行为级实测）
- [x] VC-6 → PASS（CR APPROVED+Nit1 闭环）

 outcome: COMPLETE
```

**遗留披露（非阻塞，均基线既有或已登记 defer）**：
1. config.json:99 description 内 2 处旧路径文本——受「config 零改动」硬约束保护未动，后续 config 授权维护时同步
2. docs/ARCHITECTURE.md「12 个变体」计数与 §九机制矩阵缺 mini-lite/video/video-fix 行——基线既有脱节，建议后续任务补齐
3. selftest-skill-collab T11a OR 断言 1+2=3 贴线（保护方向正确但脆弱）——后续可升级相对断言
4. selftest-fallback jq 1.7 下 2 条 stderr 噪音（断言仍 PASS）——基线既有
5. uninstall.sh 默认 TASK_PLANNER_ROOT 与真实仓路径不符——基线既有（测绘发现，超出本任务范围）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 8 终验完成，交付 COMPLETE |
| 2 | Where am I going? | 簿记收尾（INDEX/ledger/memory/push） |
| 3 | What's the goal? | 见顶部 Goal |
| 4 | What have I learned? | findings.md + notepad-learnings.md |
| 5 | What have I done? | progress.md（8 Phase 全记录） |
| 6 | Which tasks need processing? | plans/INDEX.md（本任务将标记 complete） |
