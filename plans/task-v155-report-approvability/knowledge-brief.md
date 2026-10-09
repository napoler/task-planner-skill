# Knowledge Brief — task-v155-report-approvability（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：为 task-planner 技能新增 Rule 70（用户呈报可审批性：①待审项清单+简介 ②可定位地址 ③看点 ④动作+默认项），修补全工作流 ~13 个呈报触点文件并建机器守护，达成标准=VC-1..VC-7 全过。
- 背景/动机：用户第二次反馈同缺陷类（2026-10-03 v123 只修交付总结单点）——呈报请求无清单/无地址，用户无从审批。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 呈报触点 | 工作流中一切请求用户审批/审查/确认或知情通报的输出点（Rule 70.1） |
| 四要素 | ①待审项清单+逐项简介 ②可定位地址（绝对路径/URL/命令）③看点（看什么/判什么）④动作+默认项 |
| report-lint | check-complete.sh 内新增的交付总结轻量校验（fail-open warn，不改 exit 语义） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 70 编号已预留本任务 | plans/.rule-reservations.jsonl（2026-10-10 reserve 行）+ 66=landed/67=v152/68=v153/69=v154 | 条文用 70；SKILL 范围口径写「1-66+70（67-69 并行预留）」 |
| 技能根=仓内 skills/task-planner/ 子目录 | /mnt/data/dev/task-planner-skill/skills/task-planner/（Explore 审计确认） | 所有路径以此为准，禁写仓根 |
| 金标准=delivery-summary 模板 | skills/task-planner/templates/delivery-summary.md:8-20（Rule 48.2 五条硬规则） | 条文措辞与 48.2 同口径（禁裸文件名/占位符/模糊指代） |
| check-complete 既有 fail-open 先例 | skills/task-planner/scripts/check-complete.sh:819-931（rcov-gate printf SKIPPED/WARNING 模式） | report-lint 照此范式，exit 语义零改动 |
| registry.tsv 4 列制 | skills/task-planner/scripts/selftest-registry.tsv 头行 script/domain/trigger_scenarios/dep_anchors | S15 登记行按 4 列填 |
| 时长列格式=裸 NNmin | attest 实测 2026-10-10（≤15min 不可解析 SKIPPED） | S-unit 表时长列禁带 ≤ |
| SKILL.md=511 行/critical-rules.md=860 行/64 selftest 脚本 | wc -l 实测 2026-10-10（worktree=master 5afba9c） | 新增行后跑全量回归清级联 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| references/critical-rules.md | 文末 Rule 66 段后 | Rule 70 插入点（行号以实施日重验为准，禁硬编码进条文） |
| SKILL.md | :9 | Rules 全集索引行（1-66 口径，S2 改 1-66+70） |
| SKILL.md | :72-74 | D1 计划确认段（S3 T1 指针插入点） |
| SKILL.md | :105 | drift BLOCKED STOP 行（S3 T2） |
| SKILL.md | :150 | CR Gate 失败处理行（S3 T3） |
| SKILL.md | :232-233 | B/C 变更确认（S3 T4） |
| SKILL.md | 合规清单 C45 行后 | C46 插入点 |
| scripts/check-complete.sh | :931 后 | rcov-gate 段尾=report-lint 插入点 |
| templates/variant/image-type.md | :87 附近 | 送审清单规格（S7 T9） |
| templates/variant/multiview-ref-type.md | :25 附近 | 收尾送审规格（S7 T9） |

## §4 易错点与禁止假设清单
1. 禁止在条文内硬编码行号锚（v148 判例；RRV-03 断言拦截）。
2. 禁止改 config.json（零新键）；禁止碰 v152/153/154 三个并行 worktree。
3. 触点修补只加指针行不改既有行语义（Rule 36.5 纯增量；改动既有口径会撞守卫，v117 判例）。
4. delivery-summary.md 是金标准，本任务禁改。
5. 派发 prompt 禁出现非本 S-unit 的编号字面（v129 判例）；时长列禁 ≤ 前缀（本任务 attest 实测）。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 2-6 锚级联」行（Phase 7 全量回归+S17 修复档）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §2+§3(插入点行) | plans/task-v155-report-approvability/task_plan.md §📜 Rule 70 条文草案（逐字采用） |
| S2 | §2+§3(SKILL 锚点) | 同上 §🧩 接线材料包 |
| S3 | §3(SKILL 锚点) | 同上 §🧩 触点指针材料包 T1-T4 |
| S4 | §3 | 同上 T5-T6 |
| S5-S7 | §3 | 同上 T7-T9 |
| S8-S11 | §3 | 同上 T10-T13 |
| S12-S13 | §2+§4 | 同上 §🛡️ 守护断言清单（RRV-01..13） |
| S14 | §2(rcov 先例) | 同上 |
| S15 | §2(registry 4 列) | 同上 |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| （无命中） | — | 本任务为技能条文/守卫编辑，扫描 ~/.zcode/skills 与 ~/.agents/skills 无匹配强化技能；审查面已由计划「质量审查工具」行登记 code-quality-review/alignment-review（P8 消费） | — |
