# Knowledge Brief — task-v150-split-skill-integration（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：将池内 8 技能的拆分实践集成为 references/split-pattern-library.md（10 模式+伴飞映射表），以 Rule 21.6 纯增量子条接入计划期拆分决策链，使低档模型执行时拿到「明确目标+明确方案」的任务书；标准=selftest 新守卫全 PASS+回归零新增 FAIL+部署位 IDENTICAL
- 背景/动机：本体拆分判定只有数值上限（拆得够小），缺定性判据（拆得对）；池内实践未被消费

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| S-unit | Phase 内一次 Agent() 派发对应的最小执行单元（22.6 表一行） |
| 拆分模式库 | split-pattern-library.md：10 个已验证拆分模式+伴飞映射表，计划期拆分前必读（Rule 21.6.1） |
| 伴飞技能 | 派发任务书 §2 注入 SKILL.md 绝对路径、子代理首动作 Read 的强化技能（Rule 59.2） |
| Right-Sizing | writing-plans 的任务边界定义法：独立可测试+评审者可独立否决（本库 P1） |
| parallel-group | 计划 frontmatter 声明+任务书组标记的并行组（Rule 21.4 声明制） |
| 台账供料 | 基线事实从台账文件取（编号账本/锚点表），禁 prompt 内联重建（Rule 21.2.1） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| critical-rules.md 共 800 行，Rule 21 区段 :142-159，`### 22` 起于 :160 | Explore#2 盘点（master 21f7e6b）+ 主进程 Read :130-204 复验 | 21.6 插入锚=21.5 行（:159）后、`### 22`（:160）前；实施日须在 worktree 内重验行号 |
| 21.1b 步级上限 ≤2f/100l/15min | critical-rules.md:146 | S-unit 粒度三值全部按此上限声明（本计划最大 95l） |
| Rule 65 已被 task-v149 预留 | plans/.rule-reservations.jsonl 末行（台账锚） | 本任务禁占新顶层 Rule，走 21.6 子条 |
| SKILL.md 锚点：2.5 委派检查点 :86 / C43 :213 / Rule 21 摘要 :287 | Explore#2 盘点 | S4 接线三锚定位；行号以 worktree 实施日重验为准 |
| templates/subagent_dispatch.md §3 验收标准段在 :47 | Explore#2 盘点 | S5 契约行插入位置 |
| selftest 先例骨架=selftest-media-dispatch.sh 等 9 个 | scripts/selftest-*.sh | S6 写守卫参照最近先例的 helper+断言模式 |
| attest template-gate 白名单值=rule-enhancement（无 -type 后缀） | attest 输出（本会话 2026-10-08） | 已修正计划 frontmatter；教训入 §4 |
| 编号账本已占 59-65 | plans/.rule-reservations.jsonl | 同上 Rule 65 行 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :142-159 | Rule 21 全子条（21.1/21.1b/21.2/21.2.1/21.3/21.4/21.4.1/21.5）——**S3 设计插入点=：159 之后、:160 `### 22` 之前；供料 2026-10-08，源=master 21f7e6b 主进程 Read 复验；行号以实施日 worktree 内重验为准** |
| skills/task-planner/references/split-pattern-library.md | （新建） | 拆分模式库：头部（定位+消费契约+来源总表）+P1-P10+伴飞映射表——S1/S2 产物 |
| skills/task-planner/SKILL.md | :86 / :213 / :287 / References 表 | S4 接线四点：委派检查点 2.5 对照句 / C43 补句 / Rule 21 摘要提及 / References 表库行 |
| skills/task-planner/templates/subagent_dispatch.md | :47（§3 验收标准段） | S5 No-Placeholder 契约行插入点 |
| skills/task-planner/scripts/selftest-split-pattern-library.sh | （新建） | S6 静态守卫（断言清单见 §5④） |
| CHANGELOG.md | （仓根，追加条目） | Phase 3/6 收尾时登记 Rule 21.6 条目 |

## §4 易错点与禁止假设清单
1. **禁改 21.1-21.5 既有文本**——S3 纯追加；验收含 `git diff` 零删除行断言；破坏=Rule 26 回炉
2. **禁假设 SKILL.md/critical-rules 行号恒定**——v149 并行会话可能改 master；所有行号锚实施日在 worktree 内 grep 重验，禁盲用本 brief 行号
3. **章节名/模式名以本 brief §5 设计契约为准**——S1/S2 分两批写同一文件，S2 必须先 Read S1 实际产物再追加，禁凭设计契约盲写（防章节名漂移/重复）
4. **粒度三值格式**——attest 解析器对 `≤NNmin` 前缀部分行 SKIPPED（advisory）；S-unit 声明值人工核对在上限内即合规，不因 SKIPPED 扩写表格格式
5. **禁碰 v149 worktree**（/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit）——并行会话在飞
6. **池内源技能禁改**——本任务只读源 SKILL.md 提炼实践，修改源技能=范围越界（G2）
7. **模式库每模式必须含「对低档模型执行明确性的贡献」一行**（/goal 锚定硬约束，缺=验收 FAIL）
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 4 全量回归遇既有基线 FAIL 误判」行（基线先行+三桶对照分类法）

## §5 S-unit 材料包索引（含设计契约）

### 设计契约冻结（Phase 2 终稿，供 S1-S6 消费）

**① 模式库章节名（冻结名，S1/S2 按此写）**：
- 头部：`# 拆分模式库（split-pattern-library）` + 定位段 + 消费契约段（谁/何时/怎么消费，引 Rule 21.6.1）+ 来源技能总表（8 技能名+绝对路径）
- 模式（`### P<N> <冻结名>`，每模式固定五要素：判据/反例/消费时机/来源锚/对低档模型执行明确性的贡献）：
  - P1 任务边界三判据（Right-Sizing）｜P2 Bite-Sized 步级粒度（2-5min）｜P3 子系统拆分法｜P4 任务书 No-Placeholder 与双明确｜P5 独立性判定法（拆分期域划分）｜P6 派发 Prompt 四要素｜P7 嵌套≤2 层与超时档位｜P8 简单任务禁 spawn（L0 衔接）｜P9 Spec 自审四查（挂 21.5）｜P10 拆细先于升档（本体已有，索引条目）
- 尾部：`## 伴飞映射表`（≥6 行：任务画像→伴飞技能绝对路径）+ `## 未吸收登记`（task-drift-guard 阈值等，53.3 管辖理由）

**② Rule 21.6 五子条文案要点（S3 据此撰写，插于 21.5 后）**：
- 21.6 导语：数值上限（21.1b/59.1）管「拆得够小」，本条管「拆得对」；库=references/split-pattern-library.md
- 21.6.1 模式库强制消费（计划期拆分前必读，选型结论入 kb §5 与任务书）
- 21.6.2 S-unit 边界三判据（独立可验收/独立可理解/接口清晰，任一不满足回炉重切非升档）
- 21.6.3 步内 bite-sized（2-5min 一步，任务书显式步骤 ≤4 联动 21.1b）
- 21.6.4 任务书 No-Placeholder 与双明确（禁 TBD/占位符；低档模型无需追问即知目标+方案+验收；契约行=templates/subagent_dispatch.md §3）
- 21.6.5 伴飞映射表联动（59.3 扫描先查库表再全池；执行期 59.2 伴飞注入）
- 机制句：零新 config 键+selftest-split-pattern-library.sh 守护+管辖声明（拆分质量归 21，派发规模/超时归 22，53.3 二分）

**③ SKILL.md 三锚目标文案（S4）**：References 表加库行（用途=拆分模式库，Rule 21.6）/ 委派检查点 2.5 加「拆分前查模式库+边界三判据自查」短句 / C43 加「拆分前已查模式库」自查项 / Rule 21 摘要行（:287）补 21.6 提及——合计新增 ≤12 行

**④ selftest 断言清单（S6，≥12 条）**：库文件存在 / `grep -c '^### P'`=10 / 伴飞表 ≥6 行且表内路径逐一 -f 存在 / critical-rules grep '21\.6\.[1-5]' ≥5 / `### 22` 结构锚仍在 / 负断言：21.1b 句与 21.4 调度铁律句各 1 锚未被删 / SKILL.md grep 'split-pattern-library' ≥3 / dispatch 模板 No-Placeholder 行 ≥1 / 每模式含来源锚（grep '来源' ≥10）/ 每模式含低档模型贡献行（grep '低档模型' ≥10）/ 库含消费契约段 / 幂等可重复运行

**⑤ 伴飞映射表内容（S2 据此写，路径已验证存在）**：实现类计划→writing-plans（/home/terry/.zcode/skills/writing-plans/SKILL.md）；并行编排计划→dispatching-parallel-agents（/home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md）；新系统设计拆分→brainstorming（/home/terry/.zcode/skills/brainstorming/SKILL.md）；子代理管线设计→subagent-driven-development（/home/terry/.agents/skills/subagent-driven-development/SKILL.md）；嵌套/长时派发→sub-agent-protocol（/home/terry/.zcode/skills/sub-agent-protocol/SKILL.md）；技能本体修改→writing-skills（/home/terry/.agents/skills/writing-skills/SKILL.md）；对齐审查收尾→alignment-review（/home/terry/.zcode/skills/alignment-review/SKILL.md）

**⑥ 术语锚定扩展契约（B 类扩展 2026-10-09，R5/VC-7，供 S8/S9 消费）**：
- P11 术语语义锚定与理解复述（追加为库第 11 模式，五要素格式与前 10 模式一致）：
  - 判据：用户输入中的关键领域名词（定位/设定/角色/题材类）在拆分与任务书编写前必须完成「理解回写」——一句话语义解释 + 溯源锚（用户原文上下文或检索证据）；多义词/领域词禁凭模型先验赋义
  - 反例（真实判例，逐字保留）：用户要求「比格犬是实验犬」——实际语义=狗狗定位为出逃的、实验室替代小白鼠的实验犬；执行体误读为「实验犬=擅长做实验的犬」，理解偏差致定位错误
  - 消费时机：计划期需求转译时 + 任务书编写时（创作类任务=剧本/设定/角色定位的术语理解复述为派发前置）
  - 来源：task-v150 用户判例（2026-10-09）+ 本体 Rule 63.2 检索优先联动
  - 对低档模型执行明确性的贡献：术语语义被显式锚定后，低档模型不再自行赋义，定位类幻觉从源头消除
- 21.6.6 术语锚定与反幻觉（插于 21.6.5 后、机制句前，纯增量 1-2 行）：拆分前对用户输入关键领域名词做理解回写（语义解释一句+溯源锚）；多义/领域词禁凭模型先验赋义，按 63.2 四步检索链查证；创作类任务（剧本/设定/角色定位）的术语理解复述写入派发任务书 §2 作为前置内容；「X 是 Y」类用户断言的 Y 语义必须可溯源（用户原文上下文/检索证据），禁模型自行赋义
- S9 断言同步说明：selftest-split-pattern-library.sh 中 SP-02（`grep -c '^### P'` 期望 =10→=11）与 SP-11（'对低档模型执行明确性的贡献' 计数 =10→=11）两处数值改 11；如实现为变量/阈值形式则同步其常量；改后复跑 Total FAIL=0

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1（库上半） | §5① + §2 | /home/terry/.zcode/skills/writing-plans/SKILL.md、/home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md、/home/terry/.zcode/skills/brainstorming/SKILL.md |
| S2（库下半） | §5① + §5⑤ + §4.3 | S1 产物（worktree 内绝对路径，派发时注入） |
| S3（Rule 21.6） | §5② + §3 锚点行 + §4.1 | worktree 内 skills/task-planner/references/critical-rules.md |
| S4（SKILL 接线） | §5③ + §3 锚点行 + §4.2 | worktree 内 skills/task-planner/SKILL.md |
| S5（dispatch 模板） | §5③ 尾行 + §3 | worktree 内 skills/task-planner/templates/subagent_dispatch.md |
| S6（selftest） | §5④ | worktree 内 scripts/selftest-media-dispatch.sh（骨架参照）+ §3 各产物 |
| S7-S9 | §4 + 对应 Phase 计划行 | task_plan.md + baseline-selftest.log |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| writing-skills | /home/terry/.agents/skills/writing-skills/SKILL.md | 技能文件撰写/改进画像命中（S1/S3/S4 文档类 S-unit） | 子代理 prompt 挂载（伴飞） |
| alignment-review | /home/terry/.zcode/skills/alignment-review/SKILL.md | Phase 5 对齐审查（42.6.2） | S9 伴飞（首动作 Read） |
| writing-plans | /home/terry/.zcode/skills/writing-plans/SKILL.md | 计划撰写参考（本计划已消费其判据） | 已吸收（§5①） |
| skill-creator | /home/terry/.zcode/cli/plugins/cache/zcode-plugins-official/skill-creator/0.1.0/skills/skill-creator/SKILL.md | 技能创建官方规范（S1 库文件结构参考，可选） | 子代理按需 Read |
