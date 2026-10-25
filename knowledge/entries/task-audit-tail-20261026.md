---
id: task-audit-tail-20261026
title: "审计尾批处置判例：删除前实况核查推翻「幽灵副本」误判/P01 封存/素材换词语义安全判据"
tags: [判例, 删除前核查, 僵尸计划, selftest素材]
sources: [plans/archive/task-audit-tail-20261026/, plans/archive/task-v190-skill-audit-legacy-fix/]
updated: 2026-10-26
---

# task-audit-tail-20261026 知识蒸馏

## §2 已验证关键事实
| 事实 | 证据 | 影响 |
|------|------|------|
| v190「幽灵副本」误判教训：仅比对 progress.md 单文件即断言「逐字节副本零独立工作」→ 删除前全目录 diff 推翻（delivery-summary 独立标题+git 链 3b50e02+复验实证 3 项 legacy 落地） | plans/archive/task-v190-skill-audit-legacy-fix/findings.md（纠正段） | 删除/否决类处置必须先做全目录实况核查（§五 看目标铁律）；单文件比对不足以支撑「无独立工作」结论 |
| selftest 素材换词语义安全判据：命令词表 \b(bash\|bun\|node\|python)\b 含 node → `bun run x`→`node x` 为等价命令词单信号，断言零改动可过（23/23+93/93 实证） | check-complete.sh:1845；selftest-evidence-goal-gate.sh:29,309,357,362,366,368 | 改测试 fixture 字符串前先核对被测机制的词表/正则——在表内即等价替换，语义不破 |
| P01 封存范式：superseded 计划（从未执行+目标已被他者落地）处置=顶部 SUPERSEDED 横幅（含活证据指针+deviation 登记）+git mv archive，不翻 Status 作完成声称 | plans/archive/task-P01-evidence-anchor/task_plan.md:3 | 「封存」≠「完成」——横幅如实声明未执行+覆盖证据，绕开 archive Status 门的 deviation 由用户显式授权承载 |

## §4 易错点与禁止假设清单
1. 禁止单文件 diff 推断整计划无独立工作（v190 判例）；2. 禁止把封存计划 Status 翻 complete（虚报）；3. 用户授权基于失实前提时：纠正事实→改处置→呈报，不机械执行原授权动作。
