# Knowledge Brief — task-v137（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/<task-id>/knowledge-brief.md 后即按 §1-§5 填写；
     计划期填 §1/§4/§5 骨架，§2/§3 执行期每个 S-unit 完成后持续回填（新事实/新锚点当日入账）。
  ② 为何设计成五段: 子代理 prompt 只能带「路径 + 摘要」（Rule 22.4 §9 上下文预算），
     五段=小模型可消费的知识最小集——§1 对齐术语、§2 只放已验证事实（带证据锚点，
     未验证推测禁入=防把假设当事实注入）、§3 定位文件（禁凭记忆改文件）、§4 提前
     排雷（历史教训+FMEA 兜底指针）、§5 把「S-unit → 该读哪节」互链到 S-unit 表。
  ③ 为何独立于三文件: 知识维与决策维(findings)/进度维(progress)/目标维(task_plan)
     分账存放——执行期重读任务时只读本文件即可恢复知识底座，不翻全会话/全 findings。 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

<!-- 填写说明：一句话说明本任务做什么 + 为什么做（≤2 行）；下方术语表每条 ≤1 行，只收录「不解释会读不懂后续 S-unit 材料包」的术语 -->
## §1 任务速览与核心概念
- 任务一句话：在 4 个模板/条款文件落「设计简报=台账供料」机制（brief 模板供料行型 + dispatch 注入纪律行 + critical-rules 21.2.1 子条款 + rule-enhancement-type 必读表行），全量 selftest 0 FAIL 后合并部署
- 背景/动机：设计/审计类代理派发反复内联重建基线定数与重复读规范原文（v116 A2 变体实证、审计轮三通道重复），台账已有这些事实——供料收窄替代重读（提案 plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md）

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 台账供料 | 派发前把台账（编号账本/盘点清单/审计定数/selftest 基线）最小事实集填进 brief，子代理经 brief §5 引用消费，替代 prompt 内联与原文重读 |
| 设计简报 | 本机制产物形态=knowledge-brief §2/§3/§5 的台账供料行型，非新文件 |
| 21.2.1 | Rule 21.2 的新子条款「台账供料优先」，非新 Rule（53 已被 task-v131 占用） |
| A2 变体 | v116 的 prompt 内联基线反模式（variant=29/40 键/81 脚本逐项内联），本任务收口对象 |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 机制设计/落点/守卫唯一权威源=收窄方案提案 | plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md（全 19KB） | 执行体只读提案 + 本 brief 即可动手，禁凭会话记忆 |
| critical-rules.md 现 590 行：21.2@:145、22.4@:167、22.4b@:169；Rule 53@:581 已被 task-v131 占用 | wc -l + grep -n '^21\.2 \|^22\.4 \|^### 53'（2026-10-05 实测） | 21.2.1 插 :145 后；T6 窗口 100<line<200 仍安全；禁新增 Rule 编号 |
| subagent_dispatch.md 现 76 行：📚 知识储备表@:32-36（:36 行含「brief 存在时必读其索引节(§5)」） | sed -n '19,40p'（2026-10-05 实测） | 纪律行加在 📚 表内；§2 三文件块（:22-27）与 §7 八字段块零改动 |
| knowledge-brief.md 模板 61 行五段锚：§2@:33、§3@:41、§5@:56 | grep -n '^## §'（2026-10-05 实测） | 落点 1 只改填写说明与表行，五段锚数必须保持 =5（T1b） |
| rule-enhancement-type.md 122 行，必读表标题@:93 | grep -n '必要知识储备'（2026-10-05 实测） | 落点 4 行加在 :93 表内 |
| SKILL.md 478 行恰压 selftest-skill-split.sh T2 钉 ≤478 | sed -n '38,44p' selftest-skill-split.sh | 本任务 SKILL.md 零改动（VC-5 复核 wc -l=478 不变） |
| 全量 selftest 基线=51 脚本（v132 后），0 FAIL | task-v132 簿记（MEMORY: 51 脚本 777/0） | Phase 3 求和对照该基线，禁采信子代理自报总数 |
| 并发在途：wt/task-v134、wt/task-v135（均改 critical-rules/SKILL，与本任务 hunk 不重叠） | git worktree list（2026-10-05） | 合并期按 hunk 解冲突；部署前重验 |
| 部署位（zcode）落后源仓 1-3 行（v133 部署滞后，方向安全） | wc -l 对照（SKILL 477/478、CR 587/590） | Phase 4 部署一并吸收，IDENTICAL 对账 |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/templates/knowledge-brief.md | :32-38 | §2 已验证关键事实表（填写说明+:33 段标题+表体）——S1 加「台账供料源」行型 |
| skills/task-planner/templates/knowledge-brief.md | :40-46 | §3 关键文件锚点表——S1 加「设计插入点+范式锚+时效戳」行型 |
| skills/task-planner/templates/knowledge-brief.md | :55-61 | §5 S-unit 材料包索引——S1 加「台账产物绝对路径」行型 |
| skills/task-planner/templates/subagent_dispatch.md | :32-36 | 📚 必要知识储备上下文包表（:36 行=brief 必读 §5 条款）——S2 在表内加注入纪律行 |
| skills/task-planner/references/critical-rules.md | :145 | 21.2 拆分产物自包含条款全文（单行超长）——S3 在其后插 21.2.1 ≤3 行 |
| skills/task-planner/templates/variant/rule-enhancement-type.md | :93-98 | 📚 必要知识储备表——S4 加台账供料简报行 |
| skills/task-planner/scripts/selftest-knowledge-brief.sh | :33-61 | T1b 五段锚=5/T1c ≤150/T2a/T2b ≤558/T6 行号窗口/T7 断言——Phase 3 回归主对象 |
| skills/task-planner/scripts/selftest-skill-split.sh | :41 | SKILL.md 行数钉 ≤478（label 含演进链）——零改动承诺验证锚 |
| plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md | 全文 | 机制 §二/落点 §三/节省 §四/实施清单 §5.3——唯一权威源 |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. 禁止改 subagent_dispatch.md §2 三文件必传块（:22-27）与 §7 八字段块——22.4a/22.4b 硬契约，check-dispatch 7 处+selftest 5 组消费（KQ2 判例）
2. 禁止在 knowledge-brief.md 模板新增 `## §` 段（T1b 五段锚=5 必碎）；只改填写说明注释与表行
3. 禁止采信提案内旧行号动手——一律以本 brief §3 实测锚点为准（v131/v132/v133 已使锚漂移两轮：21.2 :144→:145、dispatch 73→76 行、必读表 :84→:93）
4. 禁止新增 Rule 编号/新 config 键/新文件（53 被 task-v131 占用；零新键承诺；反目标=机制不得引入新读取环节）
5. 禁止改 SKILL.md（478 压钉，净增 1 行即碎）
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「锚漂移致 selftest 碎」行（实施前逐锚重验，不符即 STOP 回报）与「合并冲突」行（hunk 级手工合流+全量回归）

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §2 + §3 + §4 | /mnt/data/dev/task-planner-skill/plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md（§2.2 三条格式约定） |
| S2 | §1 + §2 + §3 + §4 | 同上提案（落点 2 行 + §2.3 执行期行） |
| S3 | §1 + §2 + §3 + §4 | 同上提案（§2.3 权威条款承载段 + §三 落点 3） |
| S4 | §1 + §2 + §3 + §4 | 同上提案（落点 4 行） |
| Phase 3 回归 | §2 + §3（守卫锚行） | worktree 内 scripts/selftest-knowledge-brief.sh、scripts/selftest-skill-split.sh |
