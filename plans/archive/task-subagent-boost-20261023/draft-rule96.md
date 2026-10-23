# draft-rule96 — Rule 96 全文 + 可执行编辑计划 + selftest 设计

- 任务：task-subagent-boost-20261023（Rule 96 = 子代理激活默认档 + 并行推进强化；编号已预留 `plans/.rule-reservations.jsonl:85`，95 被 task-nopause-execfirst-20261023 占用禁用——`rule-reserve.sh check 96/95` 实跑佐证见检查点 3 §2）
- 起草：规则起草员（S4），2026-10-24；行号基线 = worktree `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023`（= master 886f060 + 未提交增量，本会话 Read/grep/sed 实测）
- 实现铁律：以下编辑全部落在 worktree 内；实现者禁 `git commit`（合并由后续阶段统一做）；禁改写 Rule 21.4/22/46/52 既有语义（本计划全部为追加/枚举扩员/行内随动，无一处触碰既有条款正文语义）

---

## 0. 落点校正声明（对任务书的一处证据校正）

任务书原文「critical-rules.md（新 Rule 96 段）」按证据校正为：**Rule 96 段落全文落卫星 `skills/task-dispatch/references/critical-rules-dispatch.md`（文件尾 Rule 68 之后）**，核心 `skills/task-planner/references/critical-rules.md` 只动 :193 卫星路由行枚举（追加 96）。

依据（亲读）：Rule 21.4/22/46/52 权威全文在卫星 dispatch.md（:25-32/:48-79/:112-130/:133-143），核心文件仅 14 条核心域规则，且核心 Rule 82 分层纪律明文「禁止在核心文件留存非核心域规则正文或镜像副本」「新规则先过 Rule 20.6 查重，再入其归属域文件，禁直接写入核心」（核心 critical-rules.md:177）。96 主题（子代理激活与并行调度）命中 task-dispatch 域（核心 critical-rules.md:193 调用条件「涉及子代理拆分/派发/并行调度…时」）。

## 1. 证据基座（全部为本会话 worktree 内实读亲证；检查点 1/2/3 已消费）

| 锚 | 位置 | 内容 |
|---|---|---|
| E1 | dispatch.md:4 | 头注「规则编号：12,13,14,21,22,23（S3 批）+ 25,46,52,59,68（S4 批）」 |
| E2 | dispatch.md:11 | Rule 13 强制类别仅「调研/搜索/大文件读取/跨文件 Read」四类 |
| E3 | dispatch.md:24 | Rule 21.3 两档缺省（机械 haiku-1/判断 sonnet-1） |
| E4 | dispatch.md:25-32 | Rule 21.4 调度铁律（并行默认+四问+声明制；:27「未声明者默认串行」；:30 失败兜底链含「GLM5.3/Opus 级备用」） |
| E5 | dispatch.md:64 | Rule 22.6 S-unit 表（执行体列 `subagent_type(model)`） |
| E6 | dispatch.md:103-107 | Rule 25.1 Executor 强制/25.3 白名单六项/25.4 Phase 级委派率 |
| E7 | dispatch.md:137/:139 | Rule 52.1 选型顺序（agent-coverage.md 矩阵优先）/52.2 机器门 |
| E8 | dispatch.md:152/:154/:158 | Rule 59.1 三值硬门/59.2 伴飞/59.4 超档拆细不升档 |
| E9 | dispatch.md:173-185 | Rule 68.1 前置依赖列/68.2 惰性全串行论证义务+「本条不新建机器门」opt-in/68.5 playbook/68.6 hard(H3)+advisory(W1/W2) |
| E10 | 核心 critical-rules.md:193 | task-dispatch 卫星行枚举尾 `…,59,68）` |
| E11 | SKILL.md:9/:209/:251 | 纪元字面 `1-94`（grep 恰 3 处）；:9/:209「其余 77 条」 |
| E12 | SKILL.md:16/:195 | task-dispatch 卫星行枚举 `Rule 12,13,14,21,22,23,25,46,52,59,68` |
| E13 | SKILL.md:80/:117/:244 | 步骤 2.5 委派检查点/委派率统计/「派发与执行纪律指针」段 |
| E14 | SKILL.md 行数钉 | selftest-batch-pilot.sh:63-65 BP-08 `≤275`；实值 `wc -l`=267，边距 8 行 |
| E15 | subagent_dispatch.md:34 | 并行组声明段（尾=「未声明组=串行槽」） |
| E16 | task_plan.md:318-331 | S-unit 表注释块（:326「Rule 68.1 前置依赖列必填」）+ :328 十列表头（无并行组列） |
| E17 | task_plan.md:483-493 | 「📊 委派统计（Rule 25.4）」区块（三行表） |
| E18 | check-plan-dispatch.sh:425 | 自认「模板无『并行组』列，真实计划以注解形态承载」 |
| E19 | check-plan-dispatch.sh:439-441/:618-622 | frontmatter `parallel_groups:` 解析/H3 组标记存在性 hard |
| E20 | check-dispatch.sh:646 | `subagent-state/.dispatch-inflight` 单一全局串行锁 |
| E21 | run-selftests.sh:11/:79 | 注释钉「76 脚本」/「72 脚本」（新增 selftest 时随动） |
| E22 | selftest-plan-tier.sh:114 | 对「委派统计」仅关键词存在断言（模板加行安全）；check-complete.sh 委派门读 verification.md（:1724），非 task_plan 行级 |
| E23 | 基线零噪声 | `grep -nE '1-96([^0-9]|$)' SKILL.md`=0；dispatch.md 无 `96.[1-6]` 编号命中——selftest 断言无误命中风险 |

## 2. Rule 96 全文（追加到 dispatch.md 文件尾，E9 的 68.7 之后；含溯源注释行，对齐仓内 `<!-- Rule 59 (task-v144…) -->` 先例）

```markdown
<!-- Rule 96 (task-subagent-boost-20261023 2026-10-24): 纯增量新增；判例=用户 2026-10-23 两点诉求原话（抄录于 plans/task-subagent-boost-20261023/task_plan.md「🎯 用户需求原文」区块，51.1 口径）——①「子代理激活率低——制定计划/调研分析等类别应默认派发子代理，主进程亲自执行应为例外（子代理还可按任务复杂度切大/小模型，提质省成本）」；②「并行推进率低——无互相依赖的任务应组成并行组、同消息并发派发，实践中经常只开 1 个并行子代理」 -->

### 96 子代理激活默认档与并行推进强化（P0, 2026-10-24 task-subagent-boost-20261023，目标：①治「激活率低」——按可判定任务类别立激活默认档矩阵，主进程亲自执行收窄为例外白名单并登记理由；②治「并行推进率低」——计划期并行组硬标注 + 执行期同消息并发派发 + 两项指标留痕；判定面=LLM 行为+既有 attest/check-dispatch 既有档位（零新机器门、零新 config 键）；衔接 Rule 13/14/21.3/21.4/22.6/25/46/52/59.2/59.4/68，既有条款原文零改动、判定语义零改写）

**建制（为什么有这条）**：Rule 13/14/25 已立「什么活必须派/流程门控」，实测仍存两点缺口——① 缺「任务类别→默认派发」正清单：计划制定与调研分析类工作常由主进程亲自执行，25.3 白名单②「计划系统文件维护」等出口覆盖面宽，25.4 只统计 Phase 级占比、无类别级激活度量；② 并行语义止于「组内可并行」（21.4），68.2 惰性全串行论证义务仅约束「零声明需论证」，无「应声明而未声明」的正向硬条款，亦无「组内成员同消息并发派发」的执行形态条款——实践中单并行子代理串行推进不违任何现行条款。本条为上述条款的执行强化层：只加行为条款，不改写被引条款任何判定语义（96.6）。

96.1 **激活默认档矩阵（activation default matrix）**：Phase/S-unit 触发下列任一**可判定类别** → Executor 默认为子代理派发（主进程保留编排/路由/结论回收/最终决策四项职责，联动 Rule 25.5）：

| # | 触发类别（可判定口径） | 与既有条款关系 |
|---|---|---|
| A1 | 制定计划/起草规划/方案设计（产出=计划文档/规划草案/设计稿） | 新增面（13 未覆盖） |
| A2 | 调研分析/证据收集（网络检索/本地普查/根因分析） | 13「调研」类强化确认 |
| A3 | 多文件搜索定位（不确定具体位置、需通读多文件） | 13「搜索/跨文件 Read」强化确认 |
| A4 | 大文件/长输出消化（>500 行读取、翻日志、长网页提炼） | 13「大文件读取」强化确认 |
| A5 | 验证/审查（独立验证视角/代码审查/完成度复核） | 新增面 |
| A6 | 批量既定步骤（SOP 式批量执行） | 新增面 |
| A7 | 独立创作单元（文案/文档/媒体单元等可独立验收创作物） | 新增面 |

类别判定以 22.6 表「目标」列措辞为准，任一 S-unit 命中多类按最先命中登记；**执行体选型一律按 52.1 顺序（agent-coverage.md 矩阵优先→族兜底）**，本矩阵只定「派不派」不定「派谁」。**主进程亲自执行=例外**，须命中窄白名单并在 Executor 字段登记一句话理由：① 单行命令/单文件 ≤3 行 trivial 微改（非保护区，25.3⑥ 同面）② 已知位置的单事实查询（定点 Read ≤1 次可得）③ 25.3 白名单六项命中且派发开销显著大于收益（理由句须点名命中的白名单项号）。未命中白名单的主进程直做按 25.3 未登记处置（26 Q5 映射不变，本条不另设惩罚）。

96.2 **模型分档（计划期正向档判）**：计划期为每个派发型 S-unit 按「复杂度定性→档位」正向选档，落 22.6 表执行体列 `subagent_type(model)` 的 model 段：**轻档**=机械型（haiku-1，21.3 既有）；**中档**=判断型（sonnet-1，21.3 既有）；**重档**=复杂推理/多轮试错型（复杂疑难排查、高复杂度规划），按 agent-model-tiering 与 agent-coverage.md 既有约定选型（GLM5.3/Opus 级备用通道为 21.4 失败兜底链既有口径，非本条新设）。约束不变：59.4 超档拆细不升档、22.3 拆细先于升档、68.3 组内异构分摊、43.2 最小可承载档位优先——本条只补「计划期缺省档的正向判定」缺口（21.3 仅有两档缺省、升档只出现在失败后 22.3③），不改任何既有升降档语义。

96.3 **计划期并行硬标注（parallel annotation hard requirement）**：22.6 表「前置依赖」列（68.1）定稿后必须推导并行分组——**「前置依赖」为 `-` 且独立性四问全 no 的 S-unit ≥2 个时，必须声明并行组**：frontmatter `parallel_groups:` 追加组名 ∧ S-unit 行内组标记 `[parallel-group:<组名>]`（21.4 声明制既有形态承载，check-plan-dispatch.sh 解析/校验既有）；**未声明且未按 68.2 登记全串行论证 = 计划缺陷**，attest 前回炉补 68.1/68.2 分析。衔接声明：68.2 惰性全串行论证义务不废除，但论证通过 ≠ 鼓励全串行——默认动作是声明并行组，论证只是纯线性依赖链等例外场景的登记通道；机器面沿用 68.6 既有两档（H3 组标记存在性 hard + W1/W2 advisory），零新机器门（opt-in 口径与 68.2 一致）。

96.4 **执行期同消息并发（same-turn concurrent dispatch）**：并行组成员 S-unit 的派发必须在**同一消息内并发发起多个 Agent() 调用**——禁止把同组可并行成员串成顺序派发（逐个等返回再派下一个）。派发前逐成员过四问（21.4 既有）+ 68.5 先收窄再 fan-out；并发派发不改变验收纪律（21.4：完成一个验收一个、独立三证据+独立 Handoff 行；46.1 单会话单 S-unit 不变）。**澄清（不改写）**：25.2/SKILL.md 步骤 2.5「逐 S-unit 派发」指派发对应关系（一次派发=22.6 表一行），非时间串行——组内成员的时间形态按本条同消息并发，组间与未声明者仍按 21.4 串行槽；check-dispatch.sh 串行槽守卫行为不变（`.dispatch-inflight` 全局锁消费面不在本条射程）。确须串行化的例外（收窄未完成/额度窗口/槽位受限）逐组在 progress.md 登记一句话理由。

96.5 **指标留痕（metrics ledger）**：交付前在 task_plan.md「📊 委派统计」区块（Rule 25.4 既有落点）追加三行——① **激活子代理数**（Agent() 派发总次数）② **最大并行宽度**（并行组数/最宽组宽，如 `2 组 / 最宽 3`）③ **串行化例外理由**（96.4 登记汇总，无则 none）；交付总结按 templates/delivery-summary.md 输出时必须报告「激活子代理数」与「最大并行宽度」两项指标（25.4 Phase 级委派率照旧统计，两者叠加非替代）。

96.6 **管辖边界（jurisdiction）**：本条为 Rule 13/14（必须派）、21/21.3/21.4（拆分与调度）、22.6（S-unit 表）、25（委派门控）、46（单会话单 S-unit）、52（选型矩阵）、59.2/59.4（伴飞与超档）、68（依赖分析与分组）的**执行强化层**——只加「默认派发、档位正向判定、并行硬标注、同消息并发、指标留痕」五面行为条款，不改写被引条款任何判定语义；冲突时以被引条款为准（并行合规判定永远以 21.4 独立性四问为权威）。
```

## 3. 编辑计划（6 处，逐条 = 目标文件绝对路径 + 现状锚 + 操作）

实现一律在 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023` 内进行；行号为当前 worktree 实测。

### 编辑 1 — Rule 96 全文落卫星（本文件 §2 全文原样追加）

- 文件：`/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-dispatch/references/critical-rules-dispatch.md`
- 锚：文件尾 = `68.7 **机制（mechanism）**：…` 行（:185，全文件最后一行）
- 操作：文件末尾**追加** §2 全文（溯源注释 + 空行 + `### 96 …` 段），零改写既有行
- 随动：头注 :4 `> 规则编号：12,13,14,21,22,23（S3 批）+ 25,46,52,59,68（S4 批）` → `> 规则编号：12,13,14,21,22,23（S3 批）+ 25,46,52,59,68（S4 批）+ 96（task-subagent-boost-20261023 批）`

### 编辑 2 — 核心卫星路由行枚举扩员

- 文件：`/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/references/critical-rules.md`
- 锚：:193 行内唯一片段 `（Rule 12,13,14,21,22,23,25,46,52,59,68）`
- 操作：替换为 `（Rule 12,13,14,21,22,23,25,46,52,59,68,96）`（仅行内枚举追加，其余零改动）

### 编辑 3 — SKILL.md 纪元级联（1-94→1-96 + 77→78 条 + 枚举扩员 ×2）

- 文件：`/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/SKILL.md`
- 3a 锚 `:9`：`Rules 1-94 全集索引` → `Rules 1-96 全集索引`；同处 `其余 77 条按域归 11 卫星` → `其余 78 条按域归 11 卫星`
- 3b 锚 `:16`（frontmatter 卫星行）：`Rule 12,13,14,21,22,23,25,46,52,59,68` → `Rule 12,13,14,21,22,23,25,46,52,59,68,96`（:16 与 :195 两处同片段，逐处替换或 replace_all 限定该片段）
- 3c 锚 `:195`（卫星路由表行）：同 3b 片段追加 `,96`
- 3d 锚 `:209`：`Rules 1-94 全集索引` → `Rules 1-96 全集索引`；同处 `其余 77 条已按域迁至上表 11 卫星` → `其余 78 条已按域迁至上表 11 卫星`（纪律域枚举 `Rule 85/86/…/94` 不动——96 归 dispatch 域非纪律域）
- 3e 锚 `:251`（References 表行）：`Critical Rules 核心域 1-94 全集索引` → `Critical Rules 核心域 1-96 全集索引`
- 3f 编排段指针句（任务书点名）：「派发与执行纪律指针（卫星 authoritative）」段（:239-244）末条 bullet（:244）之后追加一行：
  `- **子代理激活默认档/模型分档/并行硬标注/同消息并发/指标留痕** → 卫星 task-dispatch Rule 96（七类触发类别默认派发；主进程直做=窄白名单登记例外；≥2 个无依赖 S-unit 必须声明并行组；并行组成员同消息并发派发；交付报告激活子代理数与最大并行宽度）`
- 行数预算：267 + 1 = 268 ≤275（BP-08 边距 7 行，免调钉；实测见 E14）

### 编辑 4 — task_plan.md 模板（并行硬标注锚 + 指标留痕三行）

- 文件：`/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/templates/task_plan.md`
- 4a 锚 `:326`（S-unit 表注释块内 `  - Rule 68.1 前置依赖列必填,无依赖填 -（多依赖顿号分隔）` 行后）追加一行：
  `  - Rule 96.3 并行硬标注:前置依赖为 - 且独立性四问全 no 的 S-unit ≥2 个 → 必须声明并行组（frontmatter parallel_groups: 组名 + 行内注解 [parallel-group:<组名>];未声明且未按 Rule 68.2 登记全串行论证=计划缺陷,回炉补分析再 attest）`
- 4b 锚 `:493`（委派统计表末行 `| 委派率 | … |` 之后）追加三行：
  `| 激活子代理数（Rule 96.5） | （Agent() 派发总次数） |`
  `| 最大并行宽度（Rule 96.5） | （并行组数 / 最宽组宽,如 2 组 / 最宽 3） |`
  `| 串行化例外理由（Rule 96.4） | （逐组一句话;无则写 none） |`
- 安全性：委派统计区块仅 selftest-plan-tier.sh:114 关键词存在断言（E22）、check-complete 委派门读 verification.md——加行零破坏（E22）；S-unit 表头不加「并行组」列（E18 脚本自认注解形态承载，加列=机器面结构变更，非本条射程）

### 编辑 5 — subagent_dispatch.md 模板（同消息并发锚定措辞）

- 文件：`/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/templates/subagent_dispatch.md`
- 锚 `:34`（§2 并行组声明行，句尾 `未声明组=串行槽。` 处）
- 操作：句尾追加 `并行组成员由主进程在同一消息内并发派发（Rule 96.4）,本任务书被并发派发属正常形态,验收仍逐成员独立三证据（Rule 21.4）。`

### 编辑 6 — scripts 随动（仅注释，Rule 45 惯例）

- `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/scripts/run-selftests.sh`
  - :11 注释 `（76 脚本 × 5-12s ≈ 6-15min/轮）` → `（77 脚本 × 5-12s ≈ 6-15min/轮）`
  - :79 注释 `其余 72 脚本 串行` → `其余 73 脚本 串行`
- 自检脚本 `/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/scripts/selftest-subagent-activation.sh` 新建（§4 全文）

## 4. 新 selftest 设计 — selftest-subagent-activation.sh

### 4.1 断言清单（15 条：SA-01..13 正断言 + SA-14/15 负断言）

| # | 类型 | 断言（对象=worktree 内文件） |
|---|---|---|
| SA-01 | 正 | dispatch.md 含行首 `^### 96 子代理激活默认档与并行推进强化`（grep -q） |
| SA-02 | 正 | dispatch.md 含 `96.1` ∧ `激活默认档矩阵` |
| SA-03 | 正 | dispatch.md 七类触发类别锚 ≥6 命中：`制定计划`/`调研分析`/`多文件搜索`/`大文件`/`验证/审查`/`批量既定步骤`/`独立创作单元`（grep -cE 计数） |
| SA-04 | 正 | dispatch.md 主进程白名单窄列：`单行命令` ∧ `单事实查询` ∧ `一句话理由` |
| SA-05 | 正 | dispatch.md `96.2` ∧ `模型分档` ∧ `sonnet-1` |
| SA-06 | 正 | dispatch.md `96.3` ∧ `计划缺陷` |
| SA-07 | 正 | dispatch.md `96.4` ∧ `同一消息` ∧ `并发` |
| SA-08 | 正 | dispatch.md `96.5` ∧ `并行宽度` |
| SA-09 | 正 | dispatch.md `96.6` ∧ `执行强化层` |
| SA-10 | 正 | 核心 critical-rules.md 含 `52,59,68,96`（枚举扩员） |
| SA-11 | 正 | SKILL.md `1-96([^0-9]|$)` 计数 ≥3（三处纪元字面；基线=0 见 E23） |
| SA-12 | 正 | SKILL.md `52,59,68,96` 计数 ≥2（:16/:195）∧ `其余 78 条` 计数 ≥2（:9/:209） |
| SA-13 | 正 | task_plan.md 模板含 `96.3` ∧ `并行组` ∧ `并行宽度`；subagent_dispatch.md 含 `96.4` ∧ `同一消息` |
| SA-14 | 负 | 防改写/回删：dispatch.md `未声明者默认串行` 计数 ≥1（21.4 原文在位）∧ `超档拆细不升档` 计数 ≥1（59.4 在位）；SKILL.md `Rules 1-94` 计数 =0（级联无残留） |
| SA-15 | 负 | 防越界：dispatch.md `^96\.7` 计数 =0（子条上限 6）；selftest-registry.tsv 含 `selftest-subagent-activation.sh` 行 |

### 4.2 脚本骨架（对齐 selftest-batch-pilot.sh 的 ok/bad 风格，SKILL_ROOT 自定位）

```bash
#!/usr/bin/env bash
# selftest-subagent-activation.sh — Rule 96 子代理激活默认档与并行推进强化静态守护（SA-01..15）
# 断言对象：critical-rules-dispatch.md Rule 96 段 / 核心 critical-rules.md 枚举 / SKILL.md 纪元级联 / 两模板锚 / registry 登记行
# 修改触发：dispatch.md Rule 96 段改动 / SKILL.md 纪元级联改动 / templates 两模板锚改动
set -u
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISPATCH="$SKILL_ROOT/../task-dispatch/references/critical-rules-dispatch.md"
CRIT_C="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL_PLAN="$SKILL_ROOT/templates/task_plan.md"
TPL_DISPATCH="$SKILL_ROOT/templates/subagent_dispatch.md"
REGISTRY="$SKILL_ROOT/scripts/selftest-registry.tsv"
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); echo "PASS SA $1: $2"; }
bad()  { FAIL=$((FAIL+1)); echo "FAIL SA $1: $2"; }
chk()  { # chk <id> <desc> <cmd...>
  local id="$1" desc="$2"; shift 2
  if "$@" >/dev/null 2>&1; then ok "$id" "$desc"; else bad "$id" "$desc"; fi
}
cnt()  { grep -c "$1" "$2" 2>/dev/null || true; }
cntE() { grep -cE "$1" "$2" 2>/dev/null || true; }

# SA-01 标题锚
[ "$(grep -c '^### 96 子代理激活默认档与并行推进强化' "$DISPATCH")" -ge 1 ] && ok 01 "Rule 96 段标题在位" || bad 01 "Rule 96 段标题缺失"
# SA-02..09 子条锚（96.1..96.6 六面齐全）
chk 02 "96.1 激活默认档矩阵"  grep -q '96\.1' "$DISPATCH"  # 实作时逐条展开为 && 链，见下方整段版
# …（SA-03..SA-15 按 4.1 表逐条展开为 grep -q / cnt / cntE 判据；负断言 SA-14/15 用 -eq 0 / -ge 1 阈值翻转）…

echo "Total: $((PASS+FAIL)) / PASS=$PASS / FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
```

（实现时按 4.1 表逐条展开 `chk`/阈值行；脚本只读零副作用，与全仓 92 个 selftest 同构；`grep -q '96\.1' "$DISPATCH" && grep -q '激活默认档矩阵' "$DISPATCH"` 式双键判定防半截落地。）

### 4.3 registry 登记行（追加到 selftest-registry.tsv 尾，TSV 四列，tab 分隔）

```
selftest-subagent-activation.sh	R-01 子代理激活默认档与并行推进强化（Rule 96，SA-01..15）	critical-rules-dispatch.md Rule 96 段改动 / SKILL.md 纪元级联改动 / templates 两模板锚改动	scripts/selftest-subagent-activation.sh
```

（selftest-registry.sh T02 双向配对强制登记——漏登记即 FAIL，机制自动兜底；登记后当前 registry 93 行→94 行。）

### 4.4 纪元级联执行说明（对照检查点 2 冻结清单，1-94→1-96）

1. **必改面（字面改宽容类，检查点 2 §7-1）**：SKILL.md:9/:209/:251 三处 `1-94`→`1-96` + :9/:209 两处 `77 条`→`78 条` + :16/:195 与核心 :193 枚举追加 96（§3 编辑 2/3/4a）。
2. **免改面（宽容正则类，检查点 2 §6 全表已验）**：scripts/ 63 条可执行断言在 96 纪元全部天然覆盖（`1-[89][0-9]`±尾边界、`Rules 1-(3[1-9]|[4-7][0-9]|8[0-9]|9[0-9])` 等 9[0-9] 全开）；`skill_max ≥84` 下限免改（96≥84）；负断言族（1-39/1-40/1-71/1-(51|53|55)/40-[5-8][0-9]/1-79/1-90）与 `1-96` 字面零交集不误伤。
3. **AD-12 pin 家族（检查点 2 §7-4）**：活锚形态不改即免改——实施者禁止把任一 `1-[89][0-9]` 活锚改写为其他形态；若确需演进必须同步 selftest-absorption-discipline.sh:85-94 对应 pin 行。
4. **随动注释（Rule 45 惯例，检查点 2 §7-5）**：run-selftests.sh:11/:79 两处注释随动（编辑 6）；可在受影响 selftest 头注补一行 `[task-subagent-boost Rule 96 级联: 1-94→1-96, 宽容正则已覆盖]`（可选）；**禁止重新钉死宽容锚**。
5. **行数钉（检查点 2 §7-6）**：SKILL.md 267→268 ≤275 免调 BP-08；若实现中指针句拆多行导致超 275，按「实值+25 边距」先例上调 selftest-batch-pilot.sh:65 钉值并在注释记演进史。
6. **回归验收**：实现完成后在 worktree 内跑 `bash skills/task-planner/scripts/run-selftests.sh --fresh`（聚合 runner 全量，检查点 1 §四实测形态），预期全绿；`--only subagent-activation` 可单跑新脚本。

## 5. 开放点与实现者注意事项

1. **frontmatter 不加 `parallel_groups:` 键（推荐已定）**：E19 显示脚本已按「行内 bracket 列表形态」解析该键，但模板加键属机器消费面结构变更；96.3 声明面沿用 21.4 既有形态（计划者按需声明），模板只补注释指引（编辑 4a）——对齐宪法 §四.6 文本优先（流程开销与变更体量成比例）。若实现阶段用户显式要求模板预置空键，另行走机器面变更流程并补 check-plan-dispatch.sh fixture。
2. **S-unit 表不加「并行组」列**：E18 脚本自认「模板无『并行组』列，真实计划以注解形态承载」且组归属取值优先级=行内标记>并行组列>注解行（check-plan-dispatch.sh:424-425）——行内注解形态已是第一优先级，加列无收益。
3. **96.4 与 check-dispatch.sh 全局锁（E20）**：23.13 已如实披露 `serial_slot_check` 单一全局锁不分組名；96.4 是 LLM 行为面条款（同消息并发派发），不触碰该锁的实现——`{组名: ts}` 富锁升级仍是 68.6 登记的后续任务项，不在本条射程。
4. **编辑顺序建议**：编辑 1（Rule 96 段）→ 编辑 2/3（枚举+纪元）→ 编辑 4/5（模板）→ 编辑 6（注释+新脚本）→ registry 登记 → `run-selftests.sh --fresh` 全量回归。
5. **G3 合规行未动**：任务书编辑面未点名 SKILL.md G 行；96 自查自然并入既有 G3（委派检查点）与终验委派统计链，如需显式 G 行属范围扩张，留给用户裁决。

## 6. 本草稿的验证记录（本会话实跑）

- worktree 全文实读：dispatch.md（185 行）、核心 critical-rules.md（203 行）、SKILL.md（267 行）、subagent_dispatch.md（113 行）、task_plan.md（:1-40/:255-374/:470-514）
- `sed -n '423,427p;438,442p;616,623p' check-plan-dispatch.sh` → :425「模板无『并行组』列…注解形态承载」、:439-441 frontmatter 解析、:618-622 H3 hard（实跑确认）
- `sed -n '644,648p' check-dispatch.sh` → :646 `.dispatch-inflight`（实跑确认）
- `grep -n '1-94' SKILL.md` → 恰 :9/:209/:251 三处；`grep -n '77 条'` → 恰 :9/:209（实跑确认）
- `tail -6 selftest-registry.tsv` + `grep -c .` = 93 行（实跑确认）；`sed -n '60,66p' selftest-batch-pilot.sh` → BP-08 `≤275` 钉（实跑确认）；`wc -l SKILL.md` = 267（实跑确认）
- `grep -ln '委派统计' selftest-*.sh` → 仅 selftest-plan-tier.sh:114（关键词存在断言，实跑确认）
- `grep -nE '1-96([^0-9]|$)' SKILL.md` 与 dispatch.md `96.[1-6]` 基线 = 0 命中（实跑确认，selftest 断言无误命中风险）
- 未跑全量 selftest 套件（本 ask 为起草，无源文件变更；实现阶段按 §4.4-6 跑 `run-selftests.sh --fresh`）
