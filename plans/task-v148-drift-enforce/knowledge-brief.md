# Knowledge Brief — {task-id}（任务知识简略要点）
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
- 任务一句话：落地 Rule 64「偏移检查留痕强制与节奏化触发纪律」——把 drift-check 从软触发升级为「留痕三件套 + Phase complete 硬门控 + hook 节奏提醒」机械闭环，全量 selftest 零回归后合并 master 并部署 IDENTICAL
- 背景/动机：用户 2026-10-08 裁决「执行任务时防偏移非常容易失效，需要时刻记得纠正」；实测 v141~v145 25 Phase 执行率 0%

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| drift-check 留痕三件套 | 检查点文件 + ledger drift_check 事件 + task_plan Drift Log 表行，缺一=未执行（64.1） |
| drift_exempt | task_plan.md 内声明行 `drift_exempt: <Phase 清单>`，门控放行豁免 Phase（纯簿记/调研/交接） |
| [drift-rhythm] | posttooluse hook 每 N=10 次工具调用注入的节奏提醒（软提醒，拦截力在 64.2 门控） |
| DCS 断言 | selftest-drift-check-subagent.sh 的 20 条措辞守护（v146），改 SKILL.md 措辞前必查防级联 |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实（行数/Rule 编号/计数/selftest 基线）证据列优先填台账路径锚（如 plans/.rule-reservations.jsonl:10、plans/task-vXXX/subagent-state/…），并保留原文重验锚并列 -->
<!-- 台账缺口维度（Rule 条款正文/模板区块结构/config 键语义）禁用台账行顶替，须如实填原文锚（file:line） -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 63 已被 task-v147 预留（检索优先与反推诿，attest cacfb3cf） | plans/.rule-reservations.jsonl 尾行（台账锚）+ plans/task-v147-research-first/task_plan.md（原文重验锚） | 本任务 new_rule=64，禁用 63 |
| critical-rules.md 765 行，尾部现行块=Rule 59（合并序范式「按合并时间序列文件尾」） | wc -l + tail 实测（2026-10-08 11:40） | S1 插入点=文件尾追加，块头格式对齐 59 块 |
| ledger-append.sh VALID_EVENTS 位于 :28，:20 有 kb_distill 增补先例注释 | skills/task-planner/scripts/ledger-append.sh:20,:28 | S2 于值尾追加 drift_check，既有枚举零改动 |
| check-3file-gate.sh 199 行；锚=progress in_progress Phase `Started:` 时间戳；条件 5=--require-kb（60.5） | scripts/check-3file-gate.sh docblock :7-15 | S2 第 6 条件复用 Started 锚与条件 5 范式；Started 缺失退化 stale 阈值 |
| zcode-posttooluse.sh 有 additionalContext 注入 helper（:155），:13 注明平台 stdout JSON 严格校验 | scripts/zcode-posttooluse.sh:13,:155 | S3 复用注入 helper；输出必须 JSON 包装 |
| drift-checker 仓内副本=skills/task-planner/companion/agents/drift-checker.md；部署位=~/.zcode/agents/drift-checker.md | find 实测（2026-10-08 11:40） | S4 只改仓内副本；部署位属 §六保护区，Phase 5 部署通道专属 |
| DCS-01~20 字面锚=selftest-drift-check-subagent.sh（v146 守护措辞） | scripts/selftest-drift-check-subagent.sh | S4 前先跑基线 20/20，追加后复跑必须全绿 |
| 机制面 18 项：机械 2/软性 16；25 Phase 执行率 0% | findings.md B1 表 + subagent-state/01-explore.md | 条款设计的问题定义基线（51.1/58.1 已锚定） |
| config.json 现无任何 drift 键 | 01-explore A 面锚 18 | DCE-09 负断言基线；零新键维持 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | 文件尾（765 行处后追加） | 尾部现行块=Rule 59（合并序范式）；S1 在此追加 Rule 64 块 |
| skills/task-planner/scripts/ledger-append.sh | :20, :28 | :20 事件增补先例注释；:28 VALID_EVENTS 枚举串 |
| skills/task-planner/scripts/check-3file-gate.sh | :7-15 docblock；条件段依实现 | 19.2 门控：findings/progress mtime vs Started 锚 + --require-kb；S2 追加条件 6 |
| skills/task-planner/scripts/zcode-posttooluse.sh | :13, :155 | 平台 JSON 校验注释；additionalContext 包装 helper；S3 追加计数段 |
| skills/task-planner/SKILL.md | Phase 循环第 6 步 [DRIFT CHECK] 块 + 合规清单 C4 行 | 2 处纯追加（64.1 留痕行 + C4 留痕句），禁改既有行 |
| skills/task-planner/companion/agents/drift-checker.md | 判定纪律段后 | ≤3 行判定输入要求追加（64.4） |
| skills/task-planner/scripts/selftest-drift-enforcement.sh | 新建 | DCE-01~16 静态+行为断言（S5） |
| CHANGELOG.md | 版本条目区顶部 | 追加 Rule 64 条目（S1） |
<!-- 设计插入点：critical-rules.md 尾部为合并序位（v144 判例），行号以实施日重验为准；hook/ledger/gate 行号实测于 2026-10-08 11:40 -->

## §4 易错点与禁止假设清单
1. 禁改 SKILL.md 既有行与 C4 行原文——DCS-01~20 字面锚 + v146 六守卫锚（只允许行末/块内追加；先跑 DCS 基线再动文本）
2. 锚级联高发面：新文本禁触碰 `drift-checker 子代理偏移检查`、`1-62`、`40-6x`、`Rule 61 载体` 等既有 label；S6 全量回归对照 master 基线（基线可能非零，只认零新增 FAIL）
3. zcode-posttooluse.sh=运行中基础设施：worktree 内修改，合并部署前主仓行为不变（§十一 隔离意义）
4. 部署位 ~/.zcode/agents/** 属 §六保护区：S4 禁碰部署位，Phase 5 经部署通道同步
5. worktree 创建后先核对 critical-rules.md/SKILL.md 与主仓一致（worktree-branch-desync 判例）；从 master HEAD 创建
6. gate fixture 必须先满足既有条件 1-5（findings/progress mtime 新鲜+Started 锚），才能孤立测试条件 6（DCE-11~14）
- FMEA RPN>100 兜底指针：本表最高 RPN=80（部署竞态）→ task_plan.md FMEA 表对应行；合并冲突/锚级联两行 RPN=72 均已预设兜底

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §2 + §3 | /mnt/data/dev/task-planner-skill/plans/task-v148-drift-enforce/rule64-draft.md（§0 落点/§1 条款全文/§7 CHANGELOG） |
| S2 | §2 + §3 | rule64-draft.md §2（接线规格） |
| S3 | §2 + §3 | rule64-draft.md §3 |
| S4 | §4 | rule64-draft.md §4（含 DCS 基线前置动作） |
| S5 | §2 + §4 | rule64-draft.md §5（断言清单）+ scripts/selftest-four-file-dataflow.sh（fixture 范式） |
| S6 | §4 | rule64-draft.md §6（回归清单） |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| （扫描结论：无匹配） | - | 本任务画像=规则条款落地+守卫脚本，无头脑风暴/内容强化需求；task-drift-guard 为本任务审查对象本体非伴飞技能 | - |
