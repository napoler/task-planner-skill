---
id: task-clause-generalize-20261115
title: "94.7/51.14/64.7 泛化修订与落位教训"
tags: [rule-landing, clause-generalize, vc-gate, insert-discipline]
sources:
  - plans/archive/task-clause-generalize-20261115/findings.md
  - plans/archive/task-clause-generalize-20261115/task_plan.md
  - plans/archive/task-clause-generalize-20261115/clause-drafts-v2.md
  - plans/review-clause-generality-20261115.md
  - skills/task-discipline/references/critical-rules-discipline.md
  - skills/task-planner/references/critical-rules.md
  - skills/task-drift-guard/references/critical-rules-drift.md
  - skills/task-planner/SKILL.md
  - skills/task-discipline/references/execution-recall-card.md
updated: 2026-11-15
---

## 结论（可直接复用）
- 三条款泛化修订落位（源仓 2042fdc→2afedb2→e4235af→b2e138c）：94.7=对象状态分区与规模跳变确认门（跨域状态集/单位判据/≥10×/全集级动作、显式覆盖豁免与包装禁令）；51.14=操作类型档位表 L1-L4+物理可行性 `÷K`（K 并发数须写明依据）+trivial 豁免/适用面；64.7=取样口径（最近含目标/指令类内容条目，同号优先）+与 64.2.1 分工（门控/证据）+trivial/空专档缺失处置。
- 级联四点同步：SKILL.md 51.14 bullet、recall card A/B/E 三行锚、drift 64.4 四锚输入、discipline 94.5 衔接；部署 5 文件×3 位 diff=0。

## 证据锚
- plans/archive/task-clause-generalize-20261115/findings.md:F1-F5（起草/插改复核、复检 APPROVED+R-1/F4/F7 分流、回归 comm=0、alignment 候选）
- plans/archive/task-clause-generalize-20261115/task_plan.md:Decisions/VC-1..5/§0 映射（15 授权项）
- plans/archive/task-clause-generalize-20261115/clause-drafts-v2.md:§0-§6（old→new 唯一事实源）

## 易错点
1. 判据串禁凭记忆：64.6 实际行文 `64.6 **零新 config 键`（无 `-` 前缀）曾误写 VC 判据；verification.md VC 判据写前先 grep 实测。
2. 部署位路径=`$pos/<skill>/…`，禁 `$pos/skills/$f` 双重前缀（VC-5 曾犯）。
3. attest vc-gate 计数面：凡 `- [ ] VC-/V-` 行都需可执行 Verify command；描述性「见 VC-x」/模板残留块同样计缺。
4. append 类回填 old_string 锚用既有行尾部片段，禁整行替换（F2/F3 两犯）。
5. 复检残留分流：R-1/F4/F7 类「授权改写自引入矛盾」句尾保真修复在授权内；新语义需求（alignment F2/F3/F5/F6 等 11 项）一律登记候选待授权。

## 适用场景
- 对既有判例条款做跨域泛化修订并级联 SKILL/card/锚行时；需写 VC 判据、部署同步、过 attest vc-gate 或分流复检残留时快速复用。