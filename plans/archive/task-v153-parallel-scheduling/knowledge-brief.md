# Knowledge Brief — task-v153-parallel-scheduling（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：给 task-planner 新增 Rule 68（计划期依赖分析→并行分组→组内异构分摊→组域写一致性），条款+模板列+守卫+selftest 四面落地，全量回归零新增失败。
- 背景/动机：用户执行慢——现状并行分组靠 LLM 自觉声明（未声明默认串行）、组内全同模型、并行更新无组域协议；借鉴 dynamic-workflows 分组思想但纠正其单模型缺陷（其 subagent_model 为 run 级无 per-task 覆盖）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 前置依赖列 | S-unit 表新列（68.1）：显式声明本单元依赖哪些他单元产出，无依赖填 `-` |
| parallel_groups | frontmatter 并行组声明（21.4），68.2 起必须由依赖分析推导 |
| 组内异构分摊 | 68.3：同组成员 subagent_type 或 model 档位至少一项不同 |
| 组域写隔离 | 68.4：成员只写 checkpoint/findings append/scope 文件，计划三文件由主进程按组串行回写 |
| 唯一 join | 68.5：每组仅一个汇合点（组批验收/Aggregator），禁多 barrier |
| serial_slot | check-dispatch 全局单锁（120s age），组间串行载体；组标记 `[parallel-group:X]` 双条件放行 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 68 已预留 held by task-v153 | plans/.rule-reservations.jsonl（2026-10-09 21:43 reserve 行） | attest new_rule 解析 fail-open 不影响；Phase 5 land 68 手动执行 |
| master=ebb5fba 已含 v151 Rule 66（Goal 单元表 attest 硬门生效） | git log -3 master；attest 首锁拒（缺 🎯 Goal 单元表）实测 | 部署位同步 v151；本计划已补 G1-G8；66.5 档位口径=standard 硬拒锁 |
| critical-rules.md 文末=66.6（基线 860 行）；段头格式 `### 66 …` | references/critical-rules.md:850-860 | S1 追加位=66.6 之后；施工日以 worktree 实测为准 |
| SKILL 计数锚四处（:9 全集行 / 列表 bullet 区 / :281 详见行 / :362 References 表）+合规清单 C45 已占 | SKILL.md:9,217-218,281,362 | S2 级联上界递推 1-6X→合并后实际最大；新行=C46 |
| check-plan-dispatch 66.5 校验段=314-406（awk 状态机范式） | scripts/check-plan-dispatch.sh:314-406 | S4 新段插其后；禁区间坍缩范式 |
| 模板 S-unit 表头=行 278（9 列，无前置依赖） | templates/task_plan.md:278 | S3 插列位置=伴飞技能与状态之间 |
| registry=scripts/selftest-registry.tsv 65 行；P 模式库 P1-P11 | scripts/selftest-registry.tsv；references/split-pattern-library.md | S5 追加 1 行；S6 新模式=P12 |
| 仓内源=skills/task-planner/ 与部署位 ~/.zcode IDENTICAL（diff -q 实测） | /mnt/data/dev/task-planner-skill/skills/task-planner/ | worktree 基于此仓路径；合并后 cp 部署 ~/.zcode+~/.claude |
| plan-writer(custom:9e221f47/sonnet-1) 与 drift-checker(haiku-1) 本日 provider 故障 | Handoff #1 + 1c 检查点；rescue=general-purpose 两例成功 | Phase 3 派发前预判同类 provider 拒绝→按 22.3.1 改派，勿原地重试超 2 次 |
| workflow 单模型缺陷 schema 级证实 | findings §A A4（SKILL.md:115,960-963,1023 引证） | 68.3 条款依据；禁把 subagent_model 引入本技能 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| references/critical-rules.md | :860（文末） | 66.6 机制段结束=Rule 68 追加点（供料 2026-10-09，源=master ebb5fba；实施日 worktree 重验） |
| references/critical-rules.md | :150-157 | Rule 21.4 声明制原文（68.2 引用其默认串行语义，勿改） |
| SKILL.md | :217-218 | 合规清单 C44/C45 行（C46 追加位） |
| scripts/check-plan-dispatch.sh | :314-406 | Rule 66.5 Goal 表校验段（awk 状态机范式=68 校验段参照系） |
| templates/task_plan.md | :278 | S-unit 表头（插「前置依赖」列） |
| plans/task-v153-parallel-scheduling/design-rule68.md | 全文 | 条款 68.1-68.7 全文+守卫六校验点+diff+级联表+T1-T9+P12 草案（本任务施工总图） |

## §4 易错点与禁止假设清单
1. 禁止硬编码计数当前态（1-66/67/65 行数）——v152（Rule 67）随时可能合并，一切计数锚「合并时从 master 实际值递推」。
2. 禁止在计划表格单元格里写裸管道 `|`（含 grep `\|`）——列位挤漂实证（本计划 S4/S6 首锁失败原因）；用顿号或分行表述。
3. S4/S5 派发用注册类型名（executor/code-assistant），禁带后缀括注；Handoff 表同口径（v150 教训 32 处误报）。
4. 新 selftest 必须登记 registry.tsv + 若 SKILL 有「NN 脚本」总数钉值则 +1（v150 教训）。
5. 派发守卫契约=三文件绝对路径+字面 `status:`/`acceptance:`/`checkpoint:`+subagent-state/ 路径+（计划含 kb 时）knowledge-brief §锚；步骤枚举（①-⑮/StepN/任务书行首编号）≤4（本会话被拦 5 次实证）。
6. provider 拒绝（reasoning-level-missing/rejected）同法 ≤2 次即 22.3.1 改派 general-purpose，勿原地重试；串行槽锁 120s age，改派前先等锁过期。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 3 计数级联冲突」「Phase 5 合并冲突」「Phase 2 worktree 分支不同步」三行

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1（条款） | §2+§3+§4 | plans/task-v153-parallel-scheduling/design-rule68.md §一 |
| S2（SKILL 级联） | §2+§3+§4 | design-rule68.md §四 |
| S3（模板加列） | §2+§3 | design-rule68.md §三 |
| S4（守卫） | §2+§3+§4 | design-rule68.md §二 |
| S5（selftest） | §2+§3+§4 | design-rule68.md §五 |
| S6（模式库+示例） | §2+§3 | design-rule68.md §六/§七 |
| V1/V2（验证） | §2 | plans/task-v153-parallel-scheduling/baseline-selftest.log（Phase 2 产出） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| verification-before-completion | /home/terry/.zcode/skills/verification-before-completion/SKILL.md | V1/V2 完成声称前证据核对 | 子代理 prompt 挂载 |
| code-quality-review | /home/terry/.zcode/skills/code-quality-review/SKILL.md | CR 面（守卫脚本 bash 质量） | CR 执行体挂载 |
| comet | /home/terry/.zcode/skills/comet/SKILL.md | 无命中（本任务单规则增强非跨模块） | 用户手动触发（仅提示） |
