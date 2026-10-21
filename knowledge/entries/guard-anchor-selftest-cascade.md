---
id: guard-anchor-selftest-cascade
title: "锚点级联与 selftest 锁步规律"
tags: [锚点级联, 宽容锚, selftest, 纪元扩容, 撞号恢复]
sources:
  - plans/archive/task-v158-source-anchor-discipline/delivery-summary.md
  - plans/archive/task-v158-source-anchor-discipline/findings.md
  - plans/archive/task-v158-source-anchor-discipline/subagent-state/15c-ss-rf.md
  - plans/archive/task-v149-skill-alignment-audit/findings.md
  - plans/archive/task-v171-skill-specialization/task_plan.md
  - plans/archive/task-v079-skill-modify-conservatism/knowledge-brief.md
  - plans/archive/task-planner-skill-review/report.md
  - plans/archive/task-skill-audit-20261021/findings.md
updated: 2026-10-22
---

# 锚点级联与 selftest 锁步规律

## 结论（可直接复用）

**1｜锚有四种形态，各有不同失效面（引用面分级）**（来源：task-v149 / task-v158 / task-v171 / task-skill-audit-20261021）
- 精确锚 `grep -c '1-35'`：改一个字即 FAIL，与 selftest 1:1 绑定；宽容锚（纪元锚）`Rules 1-3[1-5]`、`1-[89][0-9]`：跨版本不误报但掩盖真实漂移（实测「Rules 1-80」亦 PASS）；负断言 `grep -c '1-34'` = 0：改文本须同步尾部负断言（`^65`→`^66`）；行号窗口型断言（`SKILL.md:524`、registry.tsv 行号锚）：文档插一行即漂移，须改内容锚。

**2｜改规则文本时 selftest 必须同批锁步**（来源：task-v079 / task-v149 / task-v066）
selftest 守护面就是「文本锚的消费者」：规则集上界或编号一改，消费面必炸。动作：改前 `grep -rn "Rules 1-" skills/task-planner/scripts/` 全扫一次修齐（严格锚+宽容锚共 7 处，漏一处 = CD/RV 自测 FAIL）；改后回归只认「零新增 FAIL」。
级联清单筛选口径必须同时覆盖「计数形态 + 宽锚形态 + 尾部负断言形态」，只按上界字面筛会漏（v149 D38：MA-08 断言「6 个伴生」实为 7、CD-19 宽锚 1-3[5-8] 对 1-65，两条都是本任务自身改动新引入的 FAIL）。机制类改动同理：tier_order 由 5 扩 6 项 → selftest-fallback.sh:125 精确全序字符串 + :126 `tier_order length==5` 必须同批改（断言只增不减）。

**3｜纪元锚 1-N 上限会炸，扩容有固定范式**（来源：task-v158 / task-v171 / task-skill-audit）
- 扩容实例：`Rules 1-(3[0-9]|[4-7][0-9])`（覆盖 3x~7x）、`Rules 1-3[1-6]`（v079）、`'1-80'→'1-8[01]'`（v171，17 脚本，负样本 1-82 不命中）；一次扩容 = 14 个 selftest 文件 / 五类形态（v158 S15a-g），且必须把先例写进注释防钉死；已知纪元债：`40-[567][0-9]` 类锚在全集跨 80 时需再扩。
- 反面判例：20 个脚本用 `1-[89][0-9]` 宽锚 → 「Rules 1-80」实测亦 PASS → 计数守卫 100% 失效；且 selftest-absorption-discipline.sh:85-96 把宽字面钉死 → 想收紧锚反被假 FAIL。

**4｜撞号合并会静默丢文本，恢复走「零改动重编号」**（来源：task-v149）
v142 的 Rule 57（周期性回顾）在 v141 的 Rule 57（迭代测试轮次落盘）占号后条款文本消失，selftest-periodic-review.sh 仍断言幽灵文本 = 永久 FAIL 根因面。恢复四步：①`git show 1a92ef3` 考古原文 ②按 critical-rules.md:676 仲裁先例「内容零改动重编号」重编为 Rule 65 ③预留 new_rule=65 避开已占号 ④补回被撞号丢失的合规项 C39。并行合流先例：v169「epoch 80/81 双纪元」并集解；master 并行落地 Rule 81 时 merge 前强制 master→wt 并集解，否则静默回退并行成果。

**5｜引用面取证纪律**（来源：task-v158 / task-v171）
级联面以执行时 grep 实锚为准，禁凭快照数硬套（v154 合流后分布已变：快照 30 处/12 文件，实测 16 处/6 文件）；引用面清单按全扩展名扫描（.sh/.md/.json）禁抽样，先建清单再切 S-unit；预估会低估（预估「5 script 引用面」实测 7 caller + 2 随迁 selftest）。

**6｜锚的注释/代码/文案必须三处同步**（来源：task-planner-skill-review）
selftest-conclusion-discipline.sh 头注称 `1-3[5-7]`、CD-11/CD-18 代码用 `[5-9]`、CD-19 grep 模式 `[5-8]` 且文案写 `1-3[5-8]`——当前全过纯属巧合（SKILL.md 现值 1-39 三种区间都命中）。

## 证据锚

| 结论 | 证据锚（file:line） |
|------|---------------------|
| 1/3 宽锚失效 + 宽字面被钉死 | plans/archive/task-skill-audit-20261021/findings.md:74（A-01） |
| 1 尾部负断言级联 | plans/archive/task-v149-skill-alignment-audit/findings.md:51（D8：1-64→1-65 + ^65→^66，涉 6 守卫） |
| 2 改前全扫 7 处锚 | plans/archive/task-v079-skill-modify-conservatism/knowledge-brief.md:28,:52 |
| 2 三形态漏筛判例 | plans/archive/task-v149-skill-alignment-audit/findings.md:81（D38 + 教训行） |
| 2 机制改动锁步 | plans/archive/task-v066-skill-collab-routing/findings.md:38（S4：T10a 精确字符串 + T10b length 5→6） |
| 3 7x 扩容与纪元债 | plans/archive/task-v158-source-anchor-discipline/delivery-summary.md:18,:31 |
| 3 扩容形态与 ERE 通道 | plans/archive/task-v158-source-anchor-discipline/subagent-state/15c-ss-rf.md:9-18,:38 |
| 3 1-80→1-8[01] 负样本 | plans/archive/task-v171-skill-specialization/task_plan.md:408 |
| 4 撞号丢文本与恢复 | plans/archive/task-v149-skill-alignment-audit/findings.md:49（D6）、:102（L5 根因面） |
| 4 并集解先例 | plans/archive/task-v171-skill-specialization/task_plan.md:405,:407 |
| 5 快照失效实证 | plans/archive/task-v158-source-anchor-discipline/findings.md:49,:51（§3 级联面一手清点） |
| 5 引用面低估/全扩展名扫描 | plans/archive/task-v171-skill-specialization/task_plan.md:413-415 |
| 6 注释/代码/文案三方漂移 | plans/archive/task-planner-skill-review/report.md:67（领域 4 第 28 条） |

## 易错点

1. 症状：只改 1 行规则文本却大面积 selftest FAIL → 根因＝锚的消费面没同批锁步；动作＝取该 selftest 旧基线拿 FAIL 清单逐条改锚，禁改断言松紧度绕过。
2. 症状：想收紧宽锚反而假 FAIL → 根因＝宽字面被另一 selftest 钉死；动作＝找钉死方一起改，禁单边收紧。
3. 症状：新规则落地后旧规则正文「不见了」 → 根因＝撞号合并静默丢失；动作＝按结论 4 考古 + 重编号恢复，禁新造一条覆盖旧条。
4. 症状：批量替换后某处没换（python replace 无匹配不报错） → 动作＝替换后必 grep 计数核对（本仓实证：一次计划 S-unit 行插入静默失配被 hard 门拦截后修复）。
5. 症状：级联清单已改完仍 FAIL → 根因＝筛选漏掉宽锚/负断言/行号锚形态；动作＝按结论 2 的三形态重筛。
6. 禁：凭计划期快照数硬套当前分布；禁把宽容锚扩到「永真」——宽锚失效判例已证明它会掩盖真实漂移。

## 适用场景

- 新增/修改 Rule 后评估「会炸哪些 selftest 与文档锚」；见到 selftest 大面积 FAIL 但实际改动很小；
- 规则编号撞号、条款文本疑似丢失或被合并覆盖；规则集计数上界（Rules 1-N / 全集 N 条）演进；
- 技能文件搬迁/重构（规则从核心迁往卫星）导致锚失效。
