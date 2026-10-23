---
id: rule95-nopause-execution-first-landing
title: "Rule 95 非必要暂停禁令落地与同日 Rule 96 并集解 SOP"
tags: [rule-landing, media-executor, union-merge, epoch-cascade, deploy]
sources: [plans/task-nopause-execfirst-20261023/findings.md, plans/task-nopause-execfirst-20261023/subagent-state/1-explore.md]
updated: 2026-10-24
---

# Rule 95 非必要暂停禁令落地与同日 Rule 96 并集解 SOP（task-nopause-execfirst-20261023）

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 非必要暂停根因=执行体成本措辞诱导而非显式询问门 | companion/agents/video-generation-executor.md:19（原「配额警示后再批量」） | 修措辞比删门有效；Rule 95.1 执行即探测补"额度不可查询"分支 |
| selftest 纪元锚全用宽容锚 9[0-9]，新增 Rule 编号零 selftest 级联 | subagent-state/1-explore.md §③（15 个 live 锚逐条核） | 真级联面=文档计数（SKILL/README/ARCH/CLAUDE/README_zh），非 selftest |
| 并行会话同日落相邻 Rule 编号=合并必修并集解 | master e319ee3（Rule 96）vs 本任务 95；冲突仅 SKILL.md 五 hunk | 后合并方承担并集级联义务（1-95/78→1-96/79），账本 land 双补 |
| 对方新 selftest 锚未预见并集（SA-12 钉「其余 78 条」） | skills/task-planner/scripts/selftest-subagent-activation.sh:67-69 | 并集解须 grep 对方新增 selftest 的字面计数锚并随动 |
| smart-merge-back --deploy 只覆盖 task-planner（DEPLOY_SRC=:370） | scripts/smart-merge-back.sh:370,385-388 | task-discipline 等兄弟技能改动须文件级 cp 补齐（rule94 先例）；cursor 位=危险路径守卫，走 cp |
| attest 无参运行按全局活跃指针解析——并行会话抢指针后 attest 会锁**别人**的计划 | 本任务 Error Log 二犯记录；plans/.rule-reservations.jsonl rule 96 误登记 | 计划目录脚本必须 cd 进本计划目录同程运行 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-discipline/references/critical-rules-discipline.md | :617-628 | Rule 95 七子条全文（95.0 定性/95.1 执行即探测/95.2 时间衰减额度/95.3 质检自主/95.4 暂停前三问/95.5 真门关系/95.6 泛化禁令）；Rule 94 块 :605-615 为追加格式锚 |
| skills/task-planner/companion/agents/video-generation-executor.md | :19,:43,:58 | 成本纪律=试水 PASS 即自动扩批+执行即探测；额度段不可查询分支；禁令行 |
| skills/task-planner/companion/agents/image-generation-executor.md | :42,:48 | 额度执行即探测分支；质检处置自主化（禁推给用户） |
| skills/task-planner/scripts/run-selftests.sh | （入口） | 全量回归入口：`bash skills/task-planner/scripts/run-selftests.sh --fresh`，期望 FAIL=0（并集后 93 套件） |
| plans/.rule-reservations.jsonl | 尾行 | 编号账本：95/96 均 landed（96 为并集收口代登记） |

## §4 易错点与禁止假设清单
1. 禁止把「每日额度」标注当暂停理由——它是消耗约束；额度不可查询时执行即探测（Rule 95.1/95.2）
2. 并集解时禁取单侧行——SKILL.md 卫星枚举须两侧各取增量（dispatch ,96 + discipline ,95），脚本化替换易吃换行致粘行，改后必须 grep 复读
3. 级联禁碰 batch-quality-gate.md:138「隶属 Rules 1-36」（BP-09 锚 7[0-7] 不含 78，误写即 FAIL）与 CLAUDE/README_zh 历史演进链（WF-10 负样本）
4. 执行体改写禁引入字面「询问…额度」邻接——VC 负锚 `询问.{0,12}额度` 会自伤，用「求证」措辞
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 1 纪元锚形态遗漏」行（多形态族 grep 交叉复核+套件回归兜底，已实证走通）
