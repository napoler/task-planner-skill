# Knowledge Brief — task-v091-efficiency-optimization（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：定位 task-planner skill 在简单/复杂任务下执行缓慢的机制性根因，产出经两轮批判+用户裁决的优化提案并纯增量实施，全量 selftest 0 FAIL 且质量门控零削弱。
- 背景/动机：用户指令「效率提升但不可降低质量」；上游 task-v089 全量审查报告已积累效率类发现（goal-gate mini 未同步、VC-GATE 硬编码等）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| Tier A/B 分层 | Tier A=不触用户既有裁决、可直接采纳的提案项；Tier B=涉裁决项，须按 Rule 32.4 引新证据单列交用户 D1 决策 |
| Rule 21.4 串行派发铁律 | 执行期同一时刻至多 1 个活跃子代理，上一 S-unit 三证据验收前禁派下一个（用户 09-12 裁决，P0） |
| Rule 39.4 并行豁免 | 用户显式 /workflow 时，21.4 在该 workflow run 内豁免（登记制：Decisions Made + progress.md 各一行） |
| workflow-evidence/ | 本任务约定的取证/提案产出目录 `<plan-dir>/workflow-evidence/`（01..04 取证 + efficiency-proposal.md；skill 内无既有约定，本任务新建） |
| 纯增量（Rule 36.5） | 技能文件默认只追加不改写；语义变更须逐行登记+新旧对照 |
| 行数断言 4 处 | selftest 对 SKILL.md 行数 ≤558 的四处断言，SKILL 净增须同步上调并注明 task 代号 |

<!-- 只录已验证事实；未验证推测写 progress.md「假设」区 -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| skill 根=仓内 skills/task-planner/（canonical），SKILL.md 558 行，scripts/ 59 个 .sh/.cjs，27 个 selftest 脚本 | 本会话 wc -l / ls 实测（2026-09-25） | 取证路径全部锚定该根；行数统计以实测为准 |
| config.json 40 个开关键（properties 内），样例键 interaction_mode:52 / dispatch_contract_enforce:61 / knowledge_brief_enforce:101 / skill_modify_enforce:317 | 本会话 node 解析+grep 实测 | 守卫/hook 开销取证按这些键位追踪消费脚本 |
| Rule 21.4 串行派发铁律全文在 critical-rules.md:122（用户 09-12 裁决，sess_1316c7f8 实证） | references/critical-rules.md:122 | 提案只可优化单次派发开销；废除/绕过=Tier B（32.4 引本指令为新证据） |
| Rule 18.9 试点先行(:86)/18.10 单件失败禁批量(:87)/18.11 宁慢勿错(:88，用户 09-18 训诫) | references/critical-rules.md:86-88 | 批量/提速类优化不可豁免试点；「为了快」理由自动无效 |
| Rule 26 质量优先于速度门控 | references/critical-rules.md:182（§26 起），26.1 判定式 :186 | 提案质量风险段的对标条款 |
| Rule 32.4 解禁条件（新证据重议须标注否决出处） | references/critical-rules.md:272 | Tier B 每项必须按此格式单列 |
| Rule 39.1 显式点名路由 / 39.4 并行豁免 / 39.5 机器校验边界（workflow 内非 hook 强制） | references/critical-rules.md:347/359/360 | Phase 1 编排合法性依据；workflow 内步骤不靠 check-dispatch 强制 |
| Rule 8.1 D 类判定 | references/critical-rules.md:29 | 本任务 D 类开新计划、旧计划 v089/v090 原样保留 |
| Rule 36.5 保守化修改纪律（默认纯增量） | references/critical-rules.md:315 | Phase 3 实施的默认修改方式 |
| Rule 38 mini 档（38.1 判定/38.4 门控豁免 5 锚/38.5 机制） | references/critical-rules.md:333-339 | 本任务为效率优化对象之一（仪式开销），也是提案候选参照 |
| SKILL.md 行数 ≤558 断言共 4 处 | scripts/selftest-batch-pilot.sh:55、selftest-knowledge-brief.sh:38、selftest-execution-stability.sh:72、selftest-skill-collab.sh:81 | SKILL 净增须 4 处同步上调+label 注 task 代号 |
| 全量 selftest 基线：v089=453/0、v090=457/0（27 脚本） | plans/task-v089-skill-review/verification.md:86、plans/task-v090-workflow-auto-activation/verification.md:21-22 | Phase 3/4 回归底线 ≥457 且 FAIL=0 |
| 部署三实体位均存在 | ~/.zcode/skills/task-planner、~/.claude/skills/task-planner、~/.config/opencode/skills/task-planner（ls 实测） | Phase 4 smart-merge-back --deploy 后 diff -r ×3 |
| v089 审查报告 28 条发现含效率类（goal-gate mini 未同步 L21/38、VC-GATE 硬编码 L49） | plans/task-planner-skill-review/report.md:21,38,49 | Phase 1 S2 综合时的已知慢源输入 |
| 3-File 门控信号优先级=ledger>mtime（19.2） | references/critical-rules.md:96 | 执行期关键动作须 ledger-append，防门控误判 |
| 知识库五段标题 grep -c '^## §' = 5 且 ≤150 行 | scripts/selftest-knowledge-brief.sh:33-34（T1b/T1c） | 本 brief 自身受此约束，执行期回填勿超 |
| workflow-evidence/ 在 skill 与历史计划中均无既有约定 | grep 全 scripts/references/plans 零命中（本会话实测） | 该目录为本任务新建约定，路径=<plan-dir>/workflow-evidence/ |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/SKILL.md | :88-120 | Phase 执行循环 6 步：开 Phase→Todo 同步→2.5 委派检查点→3-File 落盘(3a-3d)→回写+3-File 门控→4.5 提交→Todo+索引→DRIFT CHECK；效率取证的主链路 |
| skills/task-planner/SKILL.md | :210 | 「🆕 用户新指令处理」节入口（计划影响判定，含 D 类分支） |
| skills/task-planner/SKILL.md | :290-291 | 索引行「Rules 1-39」+ 分组摘要行（联动点：规则数变化须改此处） |
| references/critical-rules.md | :122 | Rule 21.4 串行派发铁律全文（至多 1 活跃子代理/三证据验收/首败拆细） |
| references/critical-rules.md | :86-88 | Rule 18.9 试点先行/18.10 单件失败禁批量/18.11 宁慢勿错（09-18 训诫） |
| references/critical-rules.md | :182-186 | Rule 26 质量优先于速度门控 + 26.1 可观察判定式 |
| references/critical-rules.md | :29 | Rule 8.1 D 类新任务边界判定 |
| references/critical-rules.md | :272 | Rule 32.4 解禁条件（新证据重议格式） |
| references/critical-rules.md | :347-365 | Rule 39 动态工作流编排（39.1 触发/39.4 并行豁免/39.5 校验边界/39.6 零新键/39.7.3 观察面） |
| references/critical-rules.md | :307-317 | Rule 36 技能修改保守化（36.1 范围/36.5 纯增量/36.7 机制） |
| references/critical-rules.md | :333-339 | Rule 38 难度分级（38.1 mini 判定/38.4 门控豁免 5 锚/38.5 机制） |
| references/critical-rules.md | :96 | Rule 19.2 3-File 回填门控（ledger>mtime 信号优先级） |
| skills/task-planner/config.json | 全文 440 行 40 键 | 全部开关键；样例 interaction_mode:52/dispatch_contract_enforce:61/knowledge_brief_enforce:101/skill_modify_enforce:317 |
| scripts/selftest-knowledge-brief.sh | :33-38 | T1b 五段标题=5、T1c ≤150 行、T2b SKILL ≤558 断言所在 |
| scripts/selftest-batch-pilot.sh | :54-55 | BP-08 SKILL 行数断言（含 548→558 历次上调谱系注释 :11） |
| plans/task-planner-skill-review/report.md | :21,38,49 | 效率类发现：Rule 16 锚漂移/goal-gate 未同步 mini 降档/VC-GATE 硬编码 5/2 |
| plans/task-v090-workflow-auto-activation/verification.md | :21-22 | 基线 457/0（27 脚本）证据 |
| plans/INDEX.md | :1-5 | 任务索引（sync-todos.sh --index 自动刷新，勿手改） |
| plans/task-v091-efficiency-optimization/workflow-evidence/ | 待建 | Phase 1 产出：01..04-*.md 取证 + efficiency-proposal.md（§5 索引互链） |

## §4 易错点与禁止假设清单
1. 禁止废除/绕过 Rule 21.4 原文（用户 09-12 裁决）——涉串行/并行的优化一律 Tier B 单列，按 32.4 标注否决出处（critical-rules.md:122）
2. 禁止假设「workflow 内也受 check-dispatch.sh 强制」——39.5 明示 workflow 内非 hook 强制，派发契约须在编排 prompt 文本内自带
3. awk 区间提取用状态机式（标志位进入/退出区间），禁用行号硬编码区间——SKILL.md 行号会随上游任务漂移
4. Bash 一律子 shell+绝对路径：agent 线程 cwd 每次调用重置，`cd` 组合命令可能触发权限提示
5. SKILL.md 行数变更联动 4 处 selftest 行数断言（≤558），漏改任意一处=回归 FAIL；上调时 label 注明 task-v091
6. 非 Edit 工具改计划文件=attest TAMPERED，须重锁（attest-plan.sh）后才过门控
7. 禁碰旧计划 task-v089/v090 目录（D 类判定=旧计划原样保留）；禁改部署位散拷——只走 smart-merge-back --deploy
8. selftest 总数以主进程逐脚本 Total 行求和为准，禁采信子代理自报总数（VC-4 明文）
9. plans/INDEX.md 由脚本刷新勿手改；本 brief 受 ≤150 行约束，回填超限时压缩旧条目而非加行
- FMEA RPN>100 兜底指针：本计划 standard 模板未设 FMEA 段（v091 无 FMEA 表）；最高风险项=「提案削弱质量门控」→ 兜底动作见 task_plan.md 强制约束②③与 VC-3 质量护栏段

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| Phase1-S1（4 领域取证） | §1 + §2 + §3 全表 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md、references/critical-rules.md、scripts/、config.json |
| Phase1-S2（综合+3 方案） | §2（基线 457/慢源事实）+ §3 | /mnt/data/dev/task-planner-skill/plans/task-planner-skill-review/report.md |
| Phase1-S3（两轮批判） | §2（Rule 26/18.9/32.4 行）+ §4 第 1 条 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:86-88,122,182,272 |
| Phase1-S4（终稿提案） | §2 + §4 全部 | /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/workflow-evidence/efficiency-proposal.md（预期产出路径） |
| Phase2（精修+裁决） | §2（32.4 格式）+ §4 第 1/7 条 | /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/workflow-evidence/efficiency-proposal.md |
| Phase3（实施，B 类重规划后回填 S-unit 行） | §3 行数断言锚 + §4 第 3/4/5/6/8 条 | worktree 内 skills/task-planner/（路径待 Phase 3 建立后回填） |
