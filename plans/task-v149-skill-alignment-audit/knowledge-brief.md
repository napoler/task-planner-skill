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
- 任务一句话：系统性审核 task-planner 技能全载体并修复全部未对齐/过时/错误之处，发现必解决（fixed 或登记理由），回归无新增 FAIL+部署位 IDENTICAL。
- 背景/动机：v118→v148 高频演进后跨载体一致性无全面盘点，已知遗留 ≥16 项散落 memory，用户 2026-10-08 指令要求全量对齐。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 三文件罗盘 | task_plan(目标)/findings(结论)/progress(动作)——主子代理数据流转协议介质（Rule 62） |
| attest 锁定 | 计划 SHA-256 锁定防篡改；执行期改计划=B 类重规划+重跑 attest-plan.sh |
| selftest 守护面 | 62 个 selftest-*.sh 静态断言脚本，ΣFAIL 基线是回归硬指标（v147 时点=4） |
| 部署位 | 仓→运行位同步（在役确认 ~/.zcode/skills/task-planner；.agents 位不存在） |
| 幽灵条目 | INDEX.md 状态列与 git 实际终态不一致的陈旧行（本任务 L1 修复对象） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| master 基点=21f7e6b（v146/v147/v148 均已合并） | git log --oneline（2026-10-08 实测）；v146=e54973d、v147=e18045d、v148=f3a8686 | INDEX v143/v144/v146/v147 状态行全部落后=幽灵条目（findings L1） |
| INDEX.md:89-113 幽灵状态行实证 | plans/INDEX.md:89(v133)/91(v135)/94(v138)/97(v142)/98(v143)/99(v144)/101(v146 pending!)/102(v147) + :106-113 待处理区 | S5 逐行修;v133/v135/v138/v142 真实终态需先核对各自 plan 目录 |
| 部署位在役事实 | ls 一手实证+lib/detect-tools.sh:17-26（S4 对账 2026-10-08）：候选五工具 claude/zcode/opencode/cursor/continue；在役三位 zcode/claude/opencode 全量 IDENTICAL（20:28 同步 21f7e6b）；cursor 位实存但陈旧 10-05（Phase 5 重同步）；continue 未部署 | 部署对账按「五位候选、三在役、cursor 待重同步」口径 |
| 规则预留账本：63/64 已 land | plans/.rule-reservations.jsonl（63/64 reserved+landed） | 本任务占用 **65**（reserved 2026-10-08，恢复 v142 条款）；下一可用编号 66 |
| selftest 守护面=62 脚本 | ls skills/task-planner/scripts/selftest-*.sh \| wc -l = 62 | 基线 ΣFAIL=4（全 periodic，已被本任务 Rule 65 恢复修复）；config properties=42（非 40，CR 实测） |
| check-plan-dispatch 解析契约 | scripts/check-plan-dispatch.sh:242（\| S<n> \| 数据行正则）/:261（^[0-9]+min$）/:120（粒度 ^Nf/Nl/Nmin$） | 计划 S-unit 表格式硬约束：S+纯数字/NNmin/三值列 |
| v148 hook 运行态已 gitignore | .gitignore 尾行 plans/.drift-rhythm/（commit 21f7e6b） | hook 计数器不入库，git status 干净 |
| 他会话陈旧指针现场 | plans/.plan_required_side/bb1908c6….plan_required（指向已完结 v145，<24h 被 plan-created 保留） | L12 set-active-plan 缺陷复发证据;本会话 sid 护栏不动他会话状态 |

## §3 文件锚点（禁凭记忆改文件——先 Read 再改）

| 文件 | 用途 | 关键区锚 |
|------|------|---------|
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 技能主文件（L2/L3/L4 修复对象） | frontmatter 描述行/Rules 索引/References 表 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | Rule 1-64 权威源 | Rule 15/61/63/64 块 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv | 守护注册表（L4 DCE 行/L7 行号锚） | 尾部行 |
| /mnt/data/dev/task-planner-skill/plans/INDEX.md | 任务索引（L1 修复对象） | :89-113 状态行 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/periodic-review.sh + selftest-periodic-review.sh | L5 修复对象 | — |
| /mnt/data/dev/task-planner-skill/skills/task-planner/install.sh + INSTALL.md | 部署通道（S4/L9 核实对象） | — |

## §4 易错点与排雷

| 易错点 | 排雷动作 |
|--------|---------|
| attest 拒锁三连（时长 ≤ 前缀/字母 ID/缺 S-unit 表） | 本会话实证——写计划表严格 NNmin + S<纯数字> + 每派发型 Phase 带表 |
| CWD 漂移（cd 计划目录后残留） | 全程绝对路径操作 |
| 锚级联（改 SKILL 行数断言/计数断言） | 任何行改前先 grep 断言消费面（selftest 全集），改后回归（Rule 45/变更联动审计） |
| 他会话状态护栏 | 不动 bb1908c6 哨兵/side 文件；只读登记 |
| 粒度三值超限 enforce 拒锁 | S-unit 保持 ≤2f/≤100l/≤15min，超量拆行 |
| worktree 基点漂移 | 基点=master 21f7e6b 创建后立即 git log 复验（worktree-branch-desync 教训） |

## §5 S-unit 材料包索引

| S-unit | 该读哪节 | 材料包 |
|--------|---------|--------|
| S1 一致性扫描 | §2 全部+§3 | 仓根绝对路径+62 脚本清单+账本锚 |
| S2 文档滞后 | §3 | 仓根文档清单（README_zh/INSTALL_zh/CHANGELOG/CLAUDE/CONTRIBUTING*） |
| S3 三面对齐 | §3 | SKILL/critical-rules/templates/companion/scripts 路径 |
| S4 部署对账 | §2 部署位行+§3 | install.sh/INSTALL.md/v148 delivery-summary 路径 |
| S5-S12 修复批 | §2+§4 | findings.md §遗留核对表 L# 对应行 |

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
