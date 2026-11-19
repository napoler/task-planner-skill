# Knowledge Brief — task-model-tier-dispatch-20261119（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-model-tier-dispatch-20261119/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-model-tier-dispatch-20261119/knowledge-brief.md 后即按 §1-§5 填写；
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
- 任务一句话：{做什么 + 达成标准，一行}
- 背景/动机：{为什么做，一行}

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| {示例：worktree} | git 隔离开发区，实现类任务必须在其中开发（Rule §十一） |
| {术语} | {≤1 行解释} |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实（行数/Rule 编号/计数/selftest 基线）证据列优先填台账路径锚（如 plans/.rule-reservations.jsonl:10、plans/task-vXXX/subagent-state/…），并保留原文重验锚并列 -->
<!-- 台账缺口维度（Rule 条款正文/模板区块结构/config 键语义）禁用台账行顶替，须如实填原文锚（file:line） -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| {示例：init-session.sh 建 5 文件} | scripts/init-session.sh:120 | 新增第 6 文件须同步 :120 复核列表与 :131 文案 |
| {台账供料源示例：Rule 53 已被 task-v131 占用} | plans/.rule-reservations.jsonl:10（台账锚）+ critical-rules.md:581（原文重验锚） | 新增条款走 21.2.1 子条款，禁新占 Rule 编号 |
| {事实} | {file:line} | {影响} |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
<!-- 设计插入点+范式锚（台账供料，Rule 21.2.1）：设计类 S-unit 行必含 ①目标文件插入点锚 ②最新范式块锚（来源=编号账本推最大 landed Rule → 文尾块行号）③时效戳（供料日期+快照来源）；锚区间会漂移且部署位在途写入，过期锚须重测不得盲用 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| {示例：scripts/init-session.sh} | :90-98 | 4 文件循环建立（findings/progress/notepad-learnings/verification） |
| {设计插入点示例：references/critical-rules.md} | :<起-止> | 最新范式块 ### <NN>（插入点=21.2 后；供料 <日期>，源=编号账本最大 landed 号；行号以实施日重验为准） |
| {路径} | :{行号} | {摘要} |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. {示例：禁止改 22.4a 三文件契约原文（KQ2 轻量方案裁定，KQ2 波及面=check-dispatch 7 处+selftest 5 组）}
2. {易错点/禁止假设}
3. {易错点/禁止假设}
- FMEA RPN>100 兜底指针：{→ task_plan.md FMEA 表「{Phase} {失败模式}」行}

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
<!-- 台账供料（Rule 21.2.1）：设计类 S-unit 行「额外材料路径」列直接填台账产物绝对路径（替代 prompt 内联），「应读本 brief 哪节」精确到 §2/§3 供料行 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| {示例：S1} | §1 + §2 + §3 | /abs/path/to/material.md |
| {示例：S2 设计任务} | §2(基线) + §3(锚点) | plans/.rule-reservations.jsonl + <审计台账 align-audit 路径>（台账产物路径，替代 prompt 内联基线） |
| {S-unit ID} | {§x} | {路径} |
<!-- 填写说明：任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills 索引，把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）入表——What=执行前技能扫描先于派发；Why=技能库 200+ 若从不扫描匹配，强化执行能力（头脑风暴/流程强化）永远处于「从未激活」的闲置状态（Rule 59.3，对应用户 R5） -->
<!-- 用户触发型判别（Rule 59.3 判别条款）：comet 族等 frontmatter 声明 disable-model-invocation（用户显式触发）设计的技能，「激活方式」列只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活——治理解法=显式可见性（扫描入表供用户与执行体择用），而非越权代触发 -->
## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| {示例：brainstorming} | ~/.agents/skills/brainstorming/SKILL.md | {本任务画像中哪一点命中该技能} | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| {示例：comet} | ~/.zcode/skills/comet/SKILL.md | {匹配点} | 用户手动触发（仅提示） |
| {技能名} | {SKILL.md 绝对路径} | {匹配点} | {激活方式} |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-model-tier-dispatch-20261119>` → 生成 knowledge/entries/_draft-task-model-tier-dispatch-20261119.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）


## §1 Rule 110 批准稿全文（S1 落盘材料包——写入 critical-rules-dispatch.md 末段，Rule 104 段之后）

### 110 任务分级×模型档位强制匹配（P0, 2026-11-19 task-model-tier-dispatch-20261119，目标：把「任务类别→模型档位」从模型临场自判改为强制匹配契约——机械类禁用重档/创作契约模型禁出创作域/混合任务强制拆分/继承档位传染禁止/临场派发同约束，根治「纯机械操作整体丢大模型子代理」的资源滥用；判定面=LLM 行为（零新机器面，文本优先铁律 2026-10-15），机器面候选待授权；衔接 Rule 21.3/22.6/59.1/59.4/68.3/96.2/104，既有条款原文零改动）

> **Why（判例锚 sess_a7eb0603-cbcc-4be1-9072-03d1692b7073，2026-11-19 用户裁决）**：agent_4224ef20（2026-11-18T23:25Z）以 article-content-editor + `deepseekv4anthropic/deepseek-v4-pro` 执行「删 1 句重复句 + 8 步机械操作」（定位备份 .pre-recheck-886d / 写替换脚本 / sha256 双写 / 双文件同步替换 / gate --strict / push posts update / API 回读校验 / 报告+探针复验）——实际文字变化仅 -7 词（-0.60%，1173→1166），其余 8/9 步骤为纯机械操作却整体占用创作契约级大模型；agent_4f8cfac1（2026-11-14T22:12Z）同模型执行「data 块卫生比对」同病。既有分档条款未防住的三环：① Rule 96.2 触发面仅计划期 S-unit 表，判例为**执行期临场派发**绕过（article-generation plans/task-coffee-gate-repair-20261113/task_plan.md 无对应 S-unit）；② 无可操作任务分类判据，「删 1 句」按表面动作名被判作编辑类；③ 契约模型边界（agent-model-tiering 2026-08-27 用户裁决：deepseek-v4-pro=article-writer **内容创作契约专用**）仅存记忆文件，未进规则体系，跨项目无约束力。用户原话：「有哪一步是真正的内容创作 完全是被滥用 必须纠正 这种方案导致模型被大量浪费」。

110.1 **任务三分类与产出物判定基准（classification by deliverable）**：每个 S-unit / 临场派发任务在选档前必须先分类，**判定基准=产出物（deliverable），禁止按表面动作名判定**：
- **机械类（mechanical）**：产出物不新增、不修改任何自然语言文字语义——定位/备份/校验和（sha256）/字符串或 JSON 字段替换/文件搬运/格式转换/批量 IO/跑门（gate/lint/test 执行）/API 推送（push/update）/回读比对/探针复验/对账/词面统计/机械报告汇总/按既定 SOP 的簿记。判例：「删 1 句重复句」表面为编辑动作，但其 S-unit 产出物 = -7 词删除 + 8 项机械产物，机械步骤占比 8/9 → 判机械类（且按 110.3 应拆分）。
- **判断类（judgment）**：需要理解/取舍/推理但产出物非自然语言创作——调试归因/方案审查/选型/拆分设计/代码逻辑修改/风险判定/裁决辅助。
- **创作类（creative）**：产出物为新增或修改自然语言文字语义——撰写正文/改写重构表达/润色/翻译/AI 痕迹净化/按审查意见逐条改写既有文字（用户口径 2026-11-19：「只有撰写文章或者修正文章文字部分使用」大模型）。

110.2 **档位强制匹配与契约模型边界（tier matching & contract-model boundary）**：分类后按 96.2 三档表强制匹配，**禁跨类选档**：机械类→轻档（haiku-1/mini，agent-model-tiering 既有约定）；判断类→中档（sonnet-1）；创作类→重档合法。**契约模型边界条款（升格记忆约定为规则）**：内容创作管线契约模型（如 article-writer 的 deepseek-v4-pro）**仅限产出物=自然语言文字语义新增/修改的 S-unit**；机械类与判断类步骤禁用契约模型——即使该 agent（如 article-content-editor）绑定该模型，其任务面内混入的机械步骤必须按 110.3 拆出改派低档执行体，禁止"顺带用同一个重档 agent 把机械活也干了"（本条直接堵判例滥用形态）。

110.3 **混合任务强制拆分（mixed-task split mandate）**：单个 S-unit 或临场派发 prompt 内步骤枚举混合 ≥2 个类别（如「删 1 句+sha256+替换+push+回读」= 创作/机械混合）→ **必须拆成类别纯一的多个 S-unit**，各自按 110.2 匹配档位派发，禁止混合单元整体派出。与 Rule 59.1 三值门互补：59.1 量体量（Nf/Nl/Nmin），本条量**类别**——体量达标但类别混合同样回炉。拆分判定锚=逐步骤产出物词面（哪些步骤产出文字语义变化、哪些只产出机械产物）；**任一步骤属创作类即触发本条拆分义务**（未拆分而整体按单一类别派出=违规），占比口径仅用于审计叙述。

110.4 **继承档位传染禁止（inheritance contagion ban）**：机械类 S-unit **禁止以"继承"（Rule 22.6 继承=Phase Executor）获得重档执行体**——Phase Executor 为重档（含创作契约模型）时，其 S-unit 表内的机械类行必须逐行写具体低档执行体（如 `cli-executor-agent(mini)`/`code-assistant(haiku-1)`），"继承"仅对与 Phase Executor 同类别的行合法。判断类同理禁继承重档创作契约模型。

110.5 **临场派发同约束（ad-hoc dispatch parity）**：执行期未预排 S-unit 的临场 `Agent()` 派发（96.2 触发面之外）与本规则同等受约束：派发前主进程必须先按 110.1 分类并在 prompt 首行留痕 token `[tier-class:mechanical|judgment|creative]`（零机器面下的最小可审计形态：token 进 prompt 文本可 grep 可审计，未来机器拦截的挂载点）；机械/判断类禁传重档 model 参数与创作契约模型 agent。本条堵 96.2 计划期触发面漏洞（判例 886 修复即临场派发绕过）。

110.6 **例外与争议判定（edge adjudication）**：类别争议按「产出物的自然语言文字语义是否变化」单一判据裁决——语义变化=创作类；仅删除/搬运/校验/格式重排（语义不变）=机械类；修改代码逻辑/配置语义=判断类。拿不准时从低档起派，失败走 22.3 兜底链升档（拆细先于升档），禁止"预防性升档"。例外（如单条 S-unit 确需跨类原子完成，例如文字修改与替换必须同事务）须在 task_plan Decisions 登记理由+类别占比。**判定对象=任务目标物**（文章正文/代码/配置等交付物）；过程性报告/日志/checkpoint 文本不属本判据「产出物」，防机械报告被误判创作类而预防性升档。

110.7 **管辖边界与机器面声明（jurisdiction & mechanism）**：本条为 Rule 21.3（执行一律低档）/96.2（计划期正向档判）/59.4（超档拆细）/68.3（组内异构）/104.2（使用点显式标注）的**任务类别匹配强化层**——只加「分类判据+档位匹配+拆分/继承/临场三堵点」，不改写被引条款判定语义，冲突时以被引条款为准。零新 config 键/零新脚本/零新 selftest 断言（文本优先铁律）；机器面候选（check-dispatch.sh 对 `[tier-class:` token 与 model 参数的冲突校验）登记为**待授权项**，未经用户显式授权不实施。

