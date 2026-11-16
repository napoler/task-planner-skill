---
id: task-planaudit-20261116
title: "计划审计门与 Rule 109 独立审计门落地（audit-before-delivery 全流程原则）"
tags: [task-planner, rule-109, audit-gate, 计划审计, 验证契约]
sources: [plans/archive/task-planaudit-20261116/task_plan.md, plans/archive/task-planaudit-20261116/progress.md, plans/archive/task-planaudit-20261116/findings.md]
updated: 2026-11-16
---

# 计划审计门与 Rule 109 独立审计门落地（task-planaudit-20261116 COMPLETE）

## 落地终态（合并回 master 4eb441b，部署位 IDENTICAL，check-complete exit=0）

| 交付物 | 终态锚 |
|--------|--------|
| 计划审计门（SKILL.md 流程） | `skills/task-planner/SKILL.md:68-77`（D1 前强制：L1+ 分档/critic 主审计/降级链/输入材料包/六审计维度/裁决映射/迭代闭环+留痕/阻断语义+44.3 不适用/103 边界）；G1 前置 `:185`；D1 排除括注 `:81` |
| Rule 109 独立审计门（audit-before-delivery） | `skills/task-planner/references/critical-rules.md:194-212`（109.1 总则三要素/109.2 计划面强制门/109.3 分档豁免/109.4 已识别覆盖面五面映射/109.5 未列面判定规则/109.6 留痕/109.7 文本优先+机器面待授权）+ Why |
| 索引联动 | 核心 15 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83,109）/全集 1-109/其余 90 条（critical-rules.md:180 + SKILL.md:9/258/302 四处一致） |
| 编号台账 | Rule 109 reserve/land（plans/.rule-reservations.jsonl，主仓共享账本） |

## 核心机制速记

- **审计门**：L1+ 计划在「智能子动作（冲突分析+隔离决策+Spec 判定）完成后、D1 展示前」必须交独立子代理审计（首选 critic，只读）；B/C/D/E 再展示同样过门（修订重审可简版=仅审变更增量+上轮问题闭环）。
- **裁决映射（审计体出具，主进程只登记不得自判达标）**：`0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED，否则 REJECTED`；新发现=新增 CRITICAL/IMPORTANT（WARNING/QUESTION/NIT 留档不阻断）；达标=0C/0I 且连续一轮零新发现。
- **迭代闭环**：REJECTED→打回修正（主进程驱动 Plan Writer 重派，22.4a/62.2 单写者不变）→再审；连续 ≥3 轮无实质进展→呈报用户裁决；每轮留痕 `progress.md [plan-audit-R<N>]`（轮次/审计体/结论/问题清单/修复对照）。
- **分档**：mini/L0/trivial=轻量复核或 `[plan-audit-skip]` 登记豁免；L0-E 天然豁免（Rule 38.7 比例原则）。
- **未列面判定（109.5）**：①用户可见含判断结论 ②错误传导代价高 ③产出者利益相关——命中任一→简版独立复核+`[audit-before-delivery]` 留痕。

## 端到端首例判例（审计门以本计划自身实跑验证）

R1 critic 审计 **REJECTED**（18 发现 B2/M7/m9：比例原则缺口/VC 基线即 PASS/Rule 109 归属自相矛盾/留痕预写违例等）→ 修订 → R2 **REJECTED**（12 新发现：粒度 110l>100 硬门/Handoff 执行体后缀致 delegation violation 等）→ 修复轮 2+微修 → R3 **APPROVED**（0C/0I）。负向验证：REJECTED 期间计划被阻断进入 D1（44.3 自动裁决在 R3 后才登记）。

## 可复用教训（三条铁律级）

1. **子代理收据必须盘上 grep 复核**：Plan Writer 微修轮曾以纯文本「修改要点」冒充落盘收据（盘上实测 0 命中）——收据含「应落点/待执行」措辞=未完成信号；打回时显式要求 Edit 实际执行+粘贴真实命令输出。
2. **验证命令须正反双态模拟实测判别性**：VC-6 tac 形态靠旧段「APPROVED/REJECTED」枚举词偶然命中=伪判别；awk 末段聚合三态实测（真实 FAIL/模拟 PASS/相对路径 FAIL）才可冻结。run-verification runner 将 `**Verify command**:` 整行经 bash -c 执行——**Verify command 禁止反引号包裹**（反引号→命令替换→输出被当命令再执行→127）。
3. **共享状态文件主仓权威**：rule-reservations.jsonl 等台账在 worktree 侧是分支点快照（check 109=free 伪缺陷）；landed 状态核查以主仓执行为准。另：check-complete 要求 progress.md 逐 `### Phase` 段含 `- **R 锚定**：` 行且计数对齐；模板残留空骨架段会触发计数失配。

## 易错点清单（继承 kb §4，执行期验证有效）

1. D1 前展示≠审计替代；审计门不适用 44.3 自动通过。2. critic 只读，修正=Plan Writer 重派。3. 原则禁落成封闭枚举（非穷尽+未列面默认简版复核，防 51.9 自缩水）。4. 机器面（selftest/attest 接线）未经显式授权禁实施（CA-6 保持待授权）。5. 增量落地禁改既有语义（Rule 74）；归属先定稿再冻结验收判据。6. 103 与计划审计门不叠加：计划面逃逸 103.3 由审计门承载，执行期产物仍归 103。
