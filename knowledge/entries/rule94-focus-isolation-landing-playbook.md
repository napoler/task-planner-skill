---
id: rule94-focus-isolation-landing-playbook
title: "Rule 94 任务专注性与计划隔离：落地内容与新规则级联 SOP 升级（task-focus-plan-split-20261023 蒸馏）"
tags: [rule-landing, task-planner, 计划隔离, 级联SOP, rule-reserve]
sources: [plans/task-focus-plan-split-20261023/task_plan.md, plans/task-focus-plan-split-20261023/subagent-state/, skills/task-discipline/references/critical-rules-discipline.md]
updated: 2026-10-23
---

# Rule 94 落地与新规则级联 SOP（task-focus-plan-split-20261023，merge cea71e9）

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（后续任务如何消费） |
|------|---------------------|-------------------------------|
| Rule 94 已落地 discipline 卫星（六子条：单计划单垂直域/重大偏差判据/主动询问拆分/隔离处置/衔接/L0-T 机制） | skills/task-discipline/references/critical-rules-discipline.md:605-615 | 遇「目标 A→B 重大偏差」场景直接引用 94.2 判据+94.3 询问门+94.4 隔离处置；判例锚=plans/task-focus-plan-split-20261023/user-session-log.md #1 |
| 主 SKILL.md「其余 N 条」口径=11 卫星规则文件 `^### N` 实测 dedup 合计（当前 77，非 SKILL 旧字面 74/75） | 11 卫星 grep -cE "^### [0-9]+ " 合计=77；14+77=91=94−3 废弃（77/78/79） | 后续纪元级联时先实测卫星合计再改 SKILL/README/ARCH 三处口径，禁按旧字面 +1 |
| 新规则级联面（Rule 93 判例 10 文件基础上的升级面） | master cea71e9 diff（10 文件）：正文+卫星 SKILL 计数×3+卫星规则索引表行+核心 critical-rules.md 枚举+主 SKILL 5 处+E 类段指针句+CLAUDE/README_zh/README/ARCH+召回卡蒸馏行+rule-reserve 账本 | 新 Rule landing 按此清单走；判例库升级=Rule 93 判例+本条 |
| rule-reserve 可前置 land 到 worktree（账本与正文同一 merge 入 master） | plans/.rule-reservations.jsonl "rule":94 两行（reserved+landed）；提交 571ad73 | 新规则任务在 worktree 内 land+提交，selftest PR-02 预合并即绿；语义与「合并后 land」等价 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-discipline/references/critical-rules-discipline.md | :605-615 | Rule 94 正文（94.1 总纲+94.2 判据+94.3 询问门+94.4 隔离处置+94.5 衔接+94.6 L0-T 机制） |
| skills/task-planner/SKILL.md | :174 | E 类目标切换段「确认切换后的处置（Rule 94）」指针句（询问门可合并授权锚） |
| skills/task-discipline/SKILL.md | :74-78 | 规则索引表 92/93/94 三行+落盘状态句（索引表行=级联新发现面） |
| skills/task-planner/scripts/run-selftests.sh | :53-65,:100 | 指纹缓存（脚本哈希+HEAD+porcelain）；仅 rc=0 写缓存——回归证据必须 --fresh |
| skills/task-planner/scripts/attest-plan.sh | :244-290 | VC 门：verification.md 内 `- [ ] VC-N` 行数须=非占位 `**Verify command**:` 行数 |

## §4 易错点与禁止假设清单
1. attest 位置参数必须传 task_plan.md **文件路径**（传目录=「no task_plan.md found」）；S-unit 表预估时长列须裸 `NNmin`（`≤15min` 不可解析=SKIPPED）
2. Executor 字段括注含「主进程」token 即被 check-delegation 判 self_declared violation——事实上的派发 Phase 禁在括注写「主进程」字样（用「S1 侦察已派发完成=本 Phase 执行面」口径）
3. S-unit 粒度 ≤2 文件是 attest 硬门：同批派发实际触 3 文件时拆两行表行+Decisions 注记「同批派发表行拆分」，禁伪装为两次派发
4. 历史注释与演进史行（`<!-- 纪元演进 -->`、ARCH 演进史 bullet）一律保留——WF-10 锚依赖；活跃正文 1-9x 改判须排除注释行后 grep 复核
5. 会话 side 指针缺失时 resolve-plan-dir 回落全局指针；attest 按会话解析失败先查 plans/.active_plan_side/<sidkey>.active_plan 在位性
6. knowledge-brief 未填时 kb-sync 产出纯骨架 draft——精炼=按本条 §2/§3/§4 结构重写实质内容而非润色占位符
- FMEA RPN>100 兜底指针：本任务 FMEA 最高 RPN=72（级联 Edit 锚失配）未触发 >100 兜底义务；实际锚失配 0 次（侦察材料包+判例先例生效）
