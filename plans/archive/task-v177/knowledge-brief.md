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

## §1 任务速览与核心概念（2026-10-15 回填）
把「可测问题禁问+无推荐禁上抛」制度化：新 Rule 86（task-discipline 域）+ media 47.5 迭代环 + selftest 守护。核心：能靠执行-比对-量化回答的问题=模型自主；仅偏好/不可逆/预算/合规四类可上抛；上抛必带推荐三件套。

## §2 已验证关键事实（2026-10-15 回填）
- Rule 44 只管选择点呈现（默认项+超时），禁问面总纲缺口=Rule 72 接缝（:170-171）
- 触点 10 处：3 个 variant 模板是投诉模式（image-type.md:73/81/88 选定vs重抽；video-fix-type.md:45 用户三选项）
- Rule 86 编号已自动预留（.rule-reservations.jsonl）
- 索引级联 4 处含 SKILL「Rules 1-84」三处陈旧（85 欠账一并刷）

## §3 关键文件锚点表（2026-10-15 回填）
| 文件 | 锚 | 用途 |
|------|-----|------|
| skills/task-discipline/references/critical-rules-discipline.md | :508（85 尾） | Rule 86 全文追加点 |
| skills/media-planner/references/critical-rules-media.md | :15-17（47.3/47.4） | 47.5 插入+措辞顺延 |
| skills/task-planner/references/critical-rules.md | :182 | 卫星路由枚举 85→86 |
| skills/task-planner/SKILL.md | :17/:162/:9/:175/:217 | 枚举+1-86 三处刷 |
| skills/task-discipline/SKILL.md | :24/:15/:69/:80（36 条→38） | 索引+计数 |
| skills/media-planner/SKILL.md | :32-34/:36-42/:46 | 索引+联动表 |
| skills/task-planner/templates/variant/image-type.md | :73/81/88 | 改自选定范式 |
| templates/variant/video-fix-type.md | :45 | 改用户三选项 |
| scripts/selftest-four-file-dataflow.sh | :55-110 | selftest 断言范式 |
| scripts/selftest-registry.tsv | 表头 4 列 tab | 登记格式 |

## §4 易错点与禁止假设清单（2026-10-15 回填）
- C 编号体系已退役（G 表），Rule 86 机制行禁引 C 号
- 「Rules 1-84」是陈旧措辞（85 未级联），改 86 时顺手刷 1-86 勿只加 86
- discipline SKILL 计数口径=「共 N 条」三处同刷（15/69/80）
- 47.5 插入后 47.4 的「四子条」措辞需顺延为「五子条」+selftest-media-dispatch 子条计数锚级联

## §5 S-unit 材料包索引（2026-10-15 回填）
- S1 落点：subagent-state/1-explore.md（已 done）
- S2/Rule 86 land：findings.md Rule 86 草稿段+CA-1/3/4/5/6
- S3/media SOP：CA-2+47.5 草稿
- S4/selftest：CA-7+selftest-four-file-dataflow.sh:55-110 范式
