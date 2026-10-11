---
template_type: rule-enhancement
new_rule: 73
interaction_mode: ask
plan_tier: standard
code_review: required
isolation: worktree
session_id: 4ec328fb-b4fa-4c4d-b8aa-49ed84a9d2aa
---

# Task Plan: 执行期决策对齐与不变性纪律（防漂移强化 — task-v156，Rule 73）

<!--
  WHAT: 本计划=用户 2026-10-10 03:3x 三连发反馈（D 类新任务判定，Rule 8.1）的承载计划。
  WHY: 长会话执行期严重漂移实证（调研 6 分钟假完成/视频剪纸风被改 3D 风/参考母图逻辑违背）——根因=决策点未回读设定即下手。
  WHEN: 计划产出后呈 D1-D5 决策点（AskUserQuestion，默认项+5min 超时）；批准后 attest→执行。
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「现在是非常严重…我最近执行了很多的会话，在执行长久之后，就已经严重偏移了…比如说其中的一个搜索调研任务，我要求它调研别的网站内容的为什么好？为什么获得流量排名？他6分钟就给我解决完了…还有一个就是说我做视频生成任务…原本我要求的就是这个剧视频是按照剪纸风格生成的，他莫名其妙的给我改成了3D风格…所以说就是还是需要在设计一套路程上的，就是规范上以及执行步骤上的逻辑来确保确保整个执行前后不变，就是前后不偏移。」<sub>（[目标]）</sub>
- **R2**: 「当前的4套就是4个文件的设计中，应该需要应该需要强化，确保哪些东西是不变的，哪些东西是可变的，哪些东西是执行过程中不断学习到的。这，这种，这些文件必须要强化。毕竟我需要的是真正的完成任务，而不是莫名其妙的给我产出一大堆垃圾内容，完全偏离了任务需求，在各种的方向上乱给我发挥。」<sub>（[目标]）</sub>
- **R3**: 「还有就是当前就是莫名其妙，很多事情就是莫名其妙，我希望进行规范化。我希望就是就是周期性的评判数据，纠正及时发现错误。上面的也是提到过，但是不知道效果没有。」<sub>（[目标]）</sub>
- **R4**: 「我发现，我认为你这个问题核心的错误，就应该处在你每次做出决定，或者说做重大决定的时候，没有做前后的梳理…所以我希望每次每次就是说做选择，或者说做做出选择或者做出更改，以及用户提出的新需求的时候，都需要对齐回，对齐嗯对齐对齐设定以及相关的文件…需要读取分析，确保是做每次做出的决定都不会做偏移。」<sub>（[目标]）</sub>
- **R5**: 「我希望对于可能产生歧义的表述，我希望采用就是消除歧义的方法，比如说使用更加明确的解析的、更加便于理解的词语进行表述。或者在词语后面进行相应的解释，因为你这样可以便于后期不会出现任何的理解出错，也就是为犯错堵住任何的漏洞。」<sub>（[目标]）</sub>
- **R6**: 「当前还存在一个问题，就是一些已经被否定的东西，或者说，比如说被移除的版本、被删除的内容，总是会在存在于当前的文档中…我希望可以创建一个专门的，就是文件系统。之前在之前第4个文件的体系上，增加一个废弃文件、废弃内容的，就是存储的文件，确保后期存储错误内容的时候，可以放在这里。那也就是将错误隔离在正确内容之外，确保后期不会乱存。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|--------------------------|
| R1/R4 | VC-1, VC-2 | 新 Rule 决策点对齐条款在位（变更型决策点定义+对齐三问+决策留痕行 `[align]`）；S-unit 表/模板含「🔒 不变量声明区」 |
| R2 | VC-1, VC-3 | 三态标注（不变量/可变量/学得量）在模板与计划实例可 grep；decision-drift selftest 断言三态区块锚 |
| R3 | VC-4 | 周期性评判强化：既有 65/64.3 节奏面 + 新增强制评判点（变更决策后/Phase complete 前各一次），留痕 `[judge]` 行可查 |
| R5 | VC-5 | 消歧义纪律子条+模板括注范式；对齐/废弃两模板词条均带解释（grep 锚） |
| R6 | VC-2, VC-5 | 新建 `templates/deprecated.md`（或等价第 5 文件）+条款规定否决/推翻/旧版内容只入废弃区并留指针；正常四文件禁止混放错误方案（grep 负锚式声明） |

## 🧮 根源覆盖表（Rule 53.1）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 决策触发 | 变更型决策（改风格/改范围/接受新需求）无「先回读设定」强制步骤 | S2 Rule 73.1-73.2：决策点分类+对齐三问（读什么→判什么→验什么） | VC-1 |
| 不变量守护 | 四文件无「哪些不变」显式声明，Goal/VC/风格约束与执行细节混排 | S2 73.3 三态标注+模板「🔒 不变量声明区」区块（Goal/VC/用户原话/风格约束=不变量，声明后改动须走对齐三问） | VC-1, VC-3 |
| 周期评判 | 65 周期回顾存在但无「数据评判清单+强制评判点」，效果不可观测 | S2 73.4+check-complete/hook 承载的强制评判点（变更决策后、Phase complete 前、合并回前） | VC-4 |
| 废弃隔离 | 被否/推翻/旧版内容散落 findings/progress/notepad 正文，正确错误混放致理解混乱 | S3 新建废弃文件模板+73.5 只入不出规则（废弃区=唯一存放点+指针回指） | VC-2, VC-5 |
| 消歧义 | 条款/任务书歧义词无解释层，下游理解分叉 | S2 73.6 消歧义表述纪律（歧义词=括注同义词+判据+反例）+两模板示范 | VC-5 |
| 回归面 | 新区块/模板/selftest 撞既有钉值（init 6 文件计数/SKILL 1-7X/registry/C 编号让位） | S4-S6 级联批（同 v152 判例：编号让位+锚演进并集） | VC-1..5 全局 |

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 本计划三态声明——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；本任务自身即为 Rule 73 载体，先以本计划 dogfood 三态范式（S2 模板区块同款）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ① Goal=六位一体闭环全链落地；② VC-1~VC-5 判定标准；③ R1-R6 用户需求原文逐字；④ 执行范围限制表七类文件边界；⑤ Rule 36.3 纯增量零删除基线；⑥ D1-D5 已裁决事项（worktree 隔离/新 Rule 73/模板按需/双承载/新会话执行） | task_plan.md 对应段 |
| 🔀 可变量 | S-unit 拆分粒度微调/派发排期/dogfood 补建时点/基线快照细节 | progress.md 登记 |
| 📈 学得量 | 侦察锚/K 级联清单/误 attest 事故教训/06b 缺陷修正经验 | findings.md |

## Goal

把用户 2026-10-10 三连发反馈（R1-R6：执行前后不偏移/四文件三态强化/周期性评判/决策前对齐回读/消歧义/废弃隔离）制度化为 task-planner 技能 Rule 73「执行期决策对齐与不变量纪律」全链落地——critical-rules 条款（73.1-73.7）+deprecated.md 新模板+🔒 不变量声明区+check-complete/hook 双承载+新 selftest+registry+SKILL 计数级联，回归 FAIL=基线、部署位 diff=0。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|--------------|
| VC-1 | critical-rules.md 新增 Rule 73（73.1 决策点定义/73.2 对齐三问+[align] 留痕/73.3 三态标注/73.4 周期评判+[judge]/73.5 废弃只入不出/73.6 消歧义/73.7 机制），含「对齐」「不变量」关键词；既有条款零改动 | grep+Read+git diff | `grep -cE '^71\.[1-7] '`=7；`grep -c '对齐'`≥3；diff 仅文末追加 |
| VC-2 | templates/deprecated.md 五段废弃模板在位（废弃条目=原内容指针+废弃原因+日期+替代锚）+73.5 只入不出规则 | 文件 Read+grep | 五段标题 grep；`grep -c '废弃'`≥5 |
| VC-3 | general 模板+计划实例含「🔒 不变量声明区」三态标注（不变量/可变量/学得量三关键词各≥1） | grep | `grep -c '不变量\|可变量\|学得量' task_plan 模板`≥3 |
| VC-4 | 强制评判点可执行：check-complete.sh 或 posttooluse 注入含 [judge] 评判提醒；留痕格式定义 | bash -n+grep+冒烟 | 承载文件 grep≥1；若 hook 档=单行 JSON 双段冒烟 |
| VC-5 | selftest-decision-drift.sh（新）全 PASS+registry 加行+SKILL 73 摘要/C 让位行级联+全量回归 FAIL=0 | 跑批+diff 对账 | 新 selftest exit 0；回归 FAIL=基线；部署 diff=0 |

> **本计划尚未 attest**——D1-D5 决策点待确认（ask 模式，Rule 44.3 默认项+5min 超时）。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验填写）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1-R6（六条均 [目标]） |
| **裁决** | `solved` |
| **解决证据锚** | R1→73.1/73.2（critical-rules.md:944 起）;R2→73.3+templates/task_plan.md:31 🔒 区块;R3→73.4+[judge-gate]+hook 双 harness 实证;R4→73.2 三问+本任务 [align]×2 自我执行;R5→73.6+模板词条解释层;R6→73.5+deprecated.md 五段（证据明细=verification.md VC-1~5 行） |
| **未解决面+原因** | 运行期行为效果（真实会话漂移率下降）=实战效果面,超出本任务机器可验证范围;73.7 已如实披露机器边界;机制存在性全证,不冒充问题解决 |
| **已排除路径** | 无（六需求均有直接交付物） |
| **下一步建议** | 新会话实战冒烟六机制;drift-checker provider 恢复后补派（61.5 债务）;部署四端 diff 对账见交付总结 |

## 🎯 Goal 单元表（Rule 66.1 — standard 必填）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|-------------------|------|
| G1 | 侦察与设计 | Rule 29/65/68/69/70 与承载点侦察结论+design-draft.md（73.x 草案+deprecated 五段草案+🔒 区块草案+D4 施工图）落位 | design-draft.md 七段齐全+插入锚 file:line 可复验 | Phase 1 | pending |
| G2 | 条款 | Rule 73 七子条落位 critical-rules.md 文末 | grep -cE '^73\.[1-7] ' =7；对齐关键词 ≥3；diff 仅文末追加 | S1/Phase 3 | pending |
| G3 | 接线与模板 | SKILL 接线+task_plan 模板 🔒 区块+deprecated.md 新模板三落点 | grep "Rule 73" SKILL ≥4；三关键词各 ≥1；deprecated 五段标题 grep | S2-S3/Phase 3 | pending |
| G4 | 承载 | check-complete 强制评判点+hook 单行注入双承载 | 两文件 grep [judge] 各≥1；bash -n exit 0；hook 双段冒烟 | S4/Phase 3 | pending |
| G5 | 机器守护 | selftest-decision-drift.sh+registry+全量回归 FAIL=基线 | 新 selftest exit 0；registry 行在位；ΣFAIL=基线 | S5/Phase 3-4 | pending |
| G6 | 双审查 | CR+alignment-review 双 APPROVED | 两检查点 verdict 行 | Phase 5-6 | pending |
| G7 | 合并交付 | smart-merge-back --deploy+三部署位 IDENTICAL+land 73+58.5 裁决+交付五要素 | merge commit+逐位 diff=0+rule-reserve land 73+delivery-summary | Phase 6 | pending |

## 🧰 工具选择与编排（Rule 40.2 — standard 档必填）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|------------------------|---------|
| Phase 1 | 主进程（白名单② 计划系统文件）+ Explore 子代理（只读侦察） | 侦察=多文件只读定位（Rule 13）；design-draft.md 属 plans/ 白名单② |
| Phase 2 | Bash（git worktree 编排，白名单①）+ Bash（全量 selftest 基线，白名单③ 机械只读） | 建仓/对账/基线快照均编排或只读类 |
| Phase 3 | Agent 子代理（executor sonnet-1，逐 S-unit 串行派发） | 派发型 Phase 委派铁律；单会话单 S-unit（46.1）；同 worktree 写域禁并行（21.4 四问②） |
| Phase 4 | Agent 子代理（code-runner-agent mini） | 跑测类专职路由（最小可承载档，43.2） |
| Phase 5 | Agent 子代理（code-reviewer sonnet-1） | Code Review Gate 上下文隔离审查 |
| Phase 6 | 主进程（白名单① git 合并编排+② 簿记）+ drift-checker（haiku-1，Rule 61 载体） | 合并回属 git 编排；偏移检查按 Rule 61 子代理化 |

- **workflow 编排判定**：用户未显式点名 /workflow → 不路由 CreateWorkflow（Rule 39.1 红线；按 21.4 调度铁律执行）
- **/goal 对齐**：本任务=rule-enhancement 型技能条款建设，无 /goal 命令映射需求（40.3 如实披露：不适用）

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 条款 | `skills/task-planner/references/critical-rules.md`（文末追加 Rule 73） | 既有 Rule 1-70 正文改写 |
| SKILL 接线 | `skills/task-planner/SKILL.md`（73 摘要 bullet+标签级联+C 编号让位行+决策点对齐段） | 其他章节语义改写 |
| 模板 | `skills/task-planner/templates/deprecated.md`（新）、`templates/task_plan.md`（🔒 不变量声明区块，纯增量） | 其他主模板/variant |
| 门控/hook | `scripts/zcode-posttooluse.sh` 或 `scripts/check-complete.sh`（D4 决策择一承载） | `/home/terry/.zcode/cli/config.json`（禁改） |
| 守卫 | `scripts/selftest-decision-drift.sh`（新）、`selftest-registry.tsv`（+1 行） | 无关节 selftest |
| 计划系统 | `plans/task-v156-drift-shield/**` | 其他任务 plans |

## Phases

### Phase 1: 侦察深化+设计定稿
- **Status:** complete
- [x] Read Rule 29/65/68/69/70 与既有 check-complete/posttooluse 承载点，确认插入位与冲突面（findings.md [sub:main-recon] 行=file:line 锚全集）
- [x] 写 `design-draft.md`（73.1-73.7 草案+deprecated.md 五段草案+🔒 区块草案+对齐三问/评判点/消歧义范式+D4 择一施工图+DD-01~22 断言+K1-K8 级联+合并预案）
- [x] D1-D5 已裁决（44.3 超时自动：批准+worktree/新 Rule 73/模板按需/双承载/新会话执行——Decisions 表 08:0x 两行）
- **V-N:** VC-1, VC-2
- **Executor:** 主进程（例外理由:② 计划系统文件维护——design-draft.md 属 plans/）

### Phase 2: worktree 创建与基线快照
- **Status:** complete
- [x] `git worktree add /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment -b wt/v156-decision-alignment master`（建前先核 master 现实态：并行 v153-v160 高频落地，基线以建点时 master 为准）
- [x] 四关键文件与 master/部署位一致性核对+全量 selftest 基线快照（71/71 rc=0 ΣFAIL=0 ΣPASS=1039，baseline-selftest.log）
- **V-N:** VC-4, VC-5
- **Executor:** 主进程（例外理由:① git/worktree 编排）

### Phase 3: 实施（worktree 内，逐 S-unit 派发）
- **Status:** complete
- [x] S1 条款（critical-rules 文末 Rule 73 七子条）—commit 917ff95（+16/-0）
- [x] S2 SKILL 接线+task_plan 模板🔒区块—commit 759f8cb（K1-K6 六级联+🔒 区块；SKILL +8/-3 均为计数行原地改写）
- [x] S3 deprecated.md 新模板—commit e91b6cc（+32/-0 五段，与设计稿 §2 逐字一致）
- [x] S4 承载（D4 档：check-complete 强制评判点+hook 单行注入）—commit 68c446d（含 06b 零匹配捕获缺陷修正，三档冒烟过）
- [x] S5 selftest-decision-drift.sh+registry+SKILL 钉值级联（C 编号让位按 master 现实态）—commit f6bf03e（DD-01~22 全 PASS+registry 行;C51=master 现实态 tail）
- [x] 逐单元验收（22.5）+worktree 改动集=scope 核对（每 S-unit 独立复跑+逐 commit;改动集=5 文件全在执行范围限制表内）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|-----------|------------------------------|------------------------|-------------|---------|-----------|---------|---------|------|
| S1 | critical-rules.md 文末（Rule 71 段后）追加 Rule 73 七子条：73.1 变更型决策点定义/73.2 对齐三问+[align] 留痕/73.3 三态标注（不变量/可变量/学得量）/73.4 强制评判点+[judge]/73.5 废弃只入不出/73.6 消歧义/73.7 机制 | executor(sonnet-1) | skills/task-planner/references/critical-rules.md（文末追加，禁改既有条款）+ plans/task-v156-drift-shield/design-draft.md（73.x 草案逐字采用） | `grep -cE '^73\.[1-7] '`=7；`grep -c '对齐'`≥3；git diff 仅文末追加 | 15min | 1f/65l/15min | 无 | - | pending |
| S2 | SKILL.md 接线（Rule 73 摘要 bullet+计数级联「1-73」+C 编号让位行+决策点对齐段+References 表行）+ templates/task_plan.md 增「🔒 不变量声明区」区块 | executor(sonnet-1) | skills/task-planner/SKILL.md + skills/task-planner/templates/task_plan.md | grep "Rule 73" SKILL.md ≥4 命中；templates/task_plan.md 中「不变量」「可变量」「学得量」三关键词各 ≥1（grep -e 分次计数） | 15min | 2f/30l/15min | 无 | S1 | pending |
| S3 | 新建 templates/deprecated.md 五段废弃模板（废弃条目=原内容指针+废弃原因+日期+替代锚；只入不出规则示范） | executor(sonnet-1) | skills/task-planner/templates/deprecated.md（新）+ templates/subagent_dispatch.md（契约段范式参考） | 文件存在；五段标题 grep 命中；grep -c '废弃' ≥5 | 10min | 1f/45l/10min | 无 | S1 | pending |
| S4 | D4 档双承载：check-complete.sh 强制评判点（[judge] 评判提醒，变更决策后/Phase complete 前）+ zcode-posttooluse.sh 单行 JSON 节奏注入 | executor(sonnet-1) | skills/task-planner/scripts/check-complete.sh + skills/task-planner/scripts/zcode-posttooluse.sh | 两文件 grep '[judge]' 各≥1；bash -n 两脚本 exit 0；hook 单行 JSON 双段冒烟通过 | 15min | 2f/30l/15min | 无 | S1 | pending |
| S5 | 新建 selftest-decision-drift.sh（断言≥20：73.x 子条锚+模板占位+deprecated 五段+🔒 区块+registry 登记+零新键负断言）+ selftest-registry.tsv +1 行 | executor(sonnet-1) | skills/task-planner/scripts/selftest-decision-drift.sh（新）+ skills/task-planner/scripts/selftest-registry.tsv | 新 selftest exit 0 断言全 PASS；grep 'decision-drift' selftest-registry.tsv =1 | 15min | 2f/90l/15min | 无 | S1,S2,S3,S4 | pending |

- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Executor:** executor（sonnet-1）
- **并行声明：** 未声明 parallel_groups（S2-S5 均依赖 S1 产物且同 worktree 写域，独立性四问②命中→全链串行，21.4 默认语义）

### Phase 4: 验证（独立执行体）
- **Status:** complete
- [ ] 新 selftest 全 PASS+全量回归 FAIL=基线零新增+hook 冒烟（若 D4=hook 档）+properties=42
- **V-N:** VC-4, VC-5
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|-----------|------------------------------|------------------------|-------------|---------|-----------|---------|---------|------|
| S6 | 新 selftest 自跑全 PASS + check-complete.sh / zcode-posttooluse.sh 改动段冒烟（bash -n + [judge] 注入实测） | code-runner-agent(mini) | skills/task-planner/scripts/selftest-decision-drift.sh（S5 产物）+ plans/task-v156-drift-shield/baseline-selftest.log（Phase 2 基线） | selftest exit 0 断言全 PASS；bash -n 两脚本 exit 0；[judge] 注入行可 grep | 10min | 2f/0l/10min | 无 | S5 | pending |
| S7 | 全量 selftest 回归跑批+与 Phase 2 基线对比（FAIL 数零新增）+properties=42 快照 | code-runner-agent(mini) | skills/task-planner/scripts/（全量跑批入口）+ plans/task-v156-drift-shield/baseline-selftest.log | ΣFAIL=基线值；progress.md Round 行四要素落盘（57.1） | 15min | 0f/0l/15min | 无 | S6 | pending |
| S9 | 级联修复：5 个存量 selftest 的 SKILL 计数锚/上界解析按「+73」插入形态宽容化（DCS-11/R-09/RF-07/RR-09/P-05，同族批修例外登记在案——59.1 例外放行，单文件≤3 行同类锚改写） | executor(sonnet-1) | 5 个 selftest 失败断言行（drift-check-subagent/parallel-scheduling/reliability-institution/research-first/root-resolution）+ design-draft.md §6 K9 | 五脚本 rc=0 且负断言语义保留（不回退放宽判据） | 15min | 5f/10l/15min 例外登记 | 无 | S1,S2 | pending |

### Phase 5: Code Review Gate
- **Status:** complete
- [x] code-reviewer 重 diff 全量 CR（条款语义+不变量声明可执行性+废弃隔离规则自洽+消歧义示范有效性）—首轮 CHANGES_REQUESTED(MAJOR×1+MINOR×1+Nit×1)→S10 fix-phase(a2bd2ba)→复检 **APPROVED**(0 MAJOR/0 BLOCKER/0 新发现)
- **V-N:** VC-1, VC-5
- **Executor:** code-reviewer（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|-----------|------------------------------|------------------------|-------------|---------|-----------|---------|---------|------|
| S8 | 对 worktree 全量 diff 做 CR：Rule 73 条款语义自洽性+不变量声明区可执行性+废弃只入不出规则闭环+消歧义示范有效性，出 APPROVED/CHANGES_REQUESTED | code-reviewer(sonnet-1) | worktree 全量 git diff（master..wt/v156-decision-alignment）+ plans/task-v156-drift-shield/design-draft.md | verdict 行落 subagent-state 检查点；APPROVED 才进 Phase 6 | 15min | 0f/0l/15min | 无 | S6,S7,S9 | pending |

### Phase 6: 终验与交付合并回
- **Status:** complete
- [ ] 逐 VC 复验+58.5 裁决+alignment-review 收尾+smart-merge-back --deploy（预期多轮 master 并集：并行任务仍活跃，合并预案同 v152 判例）+land 73+check-complete exit 0+交付五要素
- **V-N:** VC-3, VC-5
- **Executor:** 主进程（例外理由:① git 编排+② 簿记）

## 🔀 隔离决策
| 字段 | 值 |
|------|------|
| `conflict_scan` | 预判 risk：并行 v153-v160 多任务在册（v159/v160 worktree 实测在列） |
| `isolation` | `worktree`（宪法 §十一 保护区命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment`（Phase 2 从 master 建） |
| `branch` | `wt/v156-decision-alignment` |
| `merge_back` | pending |

## Key Questions
1. 不变量声明区进 task_plan 模板后，attest 是否机械校验非空？（建议 warn 档，防 legacy 误伤）
2. 废弃文件与 notepad「🚫 被否决方案」分账：veto 决策留 notepad、被推翻产物/旧版内容进 deprecated.md（建议此分账）
3. hook 注入与 check-complete 双承载会否重复打扰？（建议 hook 一行+check-complete 终验一次）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| D 类新任务承接用户三连发（Rule 8.1 判定，2026-10-10 03:3x） | 与 v152 Goal（上下文压力评估）无关联，混入=三文件污染；判定已落 v152 notepad |
| 编号避让（2026-10-10 07:6x）：71=v158 已落地（无源不写纪律）、72=v160 已预留（决策分级）→ 本任务占 **73**（账本实测 tail 四行） | 防撞号（v143/v142 判例）；与 v158 71 相邻但异域（71=源锚/空段，73=决策对齐/不变量），与 v160 72 相邻但异域（72=决策分级归属，73=变更前对齐），条款内注明衔接 |
| 自动裁决 D1-D4（2026-10-10 08:0x，Rule 44.3 五要素：超时值 5min/推荐项=下表默认/触发时间=AskUserQuestion 未答复/理由=计划已呈示且用户先行三连发明确诉求/被覆盖选项=D2 并入 29-65、D3 常建第 7 文件、只落条款+模板）：D1=批准计划+worktree 隔离；D2=新 Rule 73 形态；D3=deprecated.md 新模板按需建；D4=check-complete 静态门+hook 单行双承载 | harness 指示 continue best judgment 非拒绝；ask 模式 44.3 条款 |
| 自动裁决 D5（2026-10-10 08:0x）：**新会话执行**——本会话 140+ 工具调用处上下文高压，Rule 67.4 纪律判 CONFUSED 风险区，深水实施转新会话（v152 交付的 session-handoff 机制首个自用例） | 被覆盖选项=本会话立即执行；理由=用户三连发根因即长会话漂移，本条以自身为范 |
| 执行时机预建议：新会话执行（已裁决=新会话） | 本会话工具调用已 >120 轮处上下文高压，按刚交付的 Rule 67.4 纪律，深水实施换新会话——用自己刚立的规矩要求自己 |
| 计划锁定前完备化（2026-10-10 09:5x，本会话 sid=5a364a28）：补 Phase 3 S-unit 表（22.6/59.1/68.1 列：执行体/输入/验收/时长/粒度三值/伴飞/前置依赖/状态）+ 🧰 工具面区块（40.2）+ 📊 FMEA 预演段——均为 attest 机械门要求的计划要素补齐，非范围变更 | attest 前置：check-plan-dispatch 拒锁「派发型 Phase 缺 S-unit 表」；fmea-gate warn「无 FMEA 段」；三段落锁定前补齐 |
| S9 级联修复登记（2026-10-10 11:5x，B 类扩展）：S7 回归实证 S2 的 SKILL 计数改写打破 5 个存量 selftest 宽容锚/上界解析（DCS-11/R-09/RF-07/RR-09/P-05,ΣFAIL 5 非零新增）——design-draft §6 K1-K8 漏列「存量 selftest 锚扩展」面;补 K9+例外登记单元 S9(同族批修,5 文件×≤3 行锚宽容化) | FMEA RPN=210 行实证兑现(级联漏改预警命中);根因=级联清单只列了「写入点」未列「既有 selftest 对写入点的断言语义面」;修复后重跑 S7 复验 |
| 误 attest 事故与还原（2026-10-10 09:50）：attest-plan.sh 未带显式路径，经 env sid 解析链误锁 task-v159（其计划 09:02 后内容未动，SHA 不变=功能无损）；已用 v159 属主 sid（cbab959）重跑 attest 恢复归属元数据，详情落 progress.md Error Log | 事故根因=env sid（CLAUDE_CODE_SESSION_ID=de2c5bba）与 hook sid（5a364a28）双命名空间分叉；防线=attest 恒带显式 plan 路径；已入 FMEA RPN=84 行 |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 兜底动作 |
|-------|---------|---|---|---|-----|---------|
| Phase 3 实施 | 级联漏改：SKILL 钉值/registry/C 编号与 Rule 73 不同步（v158/v149 判例：计数级联必全仓 grep） | 7 | 6 | 5 | 210 | S5 selftest 全量锚定断言+S2/S5 间 grep 对账；漏改即回炉该 S-unit 不进 Phase 4 |
| Phase 3+6 | 并行 worktree 同期落地（v159/v160 在飞）致合并冲突或 Rule 73 撞号 | 8 | 4 | 6 | 192 | 建仓前对账 master HEAD+规则账本；合调用 smart-merge-back 并集解（v152 判例）；撞号即改号+rule-reserve 登记 |
| Phase 2 建仓 | worktree 从 master 建时技能文件与部署位/其他源不同步（v135/v144 判例） | 6 | 5 | 4 | 120 | 建后四关键文件与 master diff 对账+全量 selftest 基线快照，不一致先同步再开工 |
| Phase 6 合并 | attest 误锁其他计划（本会话实证 09:50：env sid 解析链指向 v159 致误 attest） | 7 | 3 | 4 | 84 | attest 恒带显式 plan 路径参数；sid 双命名空间分叉时先 resolve-plan-dir 确认目标再跑 |

RPN>100 三项均已配兜底动作（210/192/120）。

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | 时间 | subagent_type | 任务目标(≤1句) | 状态 | 结论摘要 | checkpoint 路径 | verify_done |
|---|------|---------------|----------------|------|---------|----------------|------------|
| 1 | 10-10 10:5x | drift-checker | Phase 1 偏移检查 | failed | provider 拒启×2（无检查点产出）；按 61.5 Read 检查点→重试 1 次→降级 check-drift.sh 兜底 | subagent-state/01-drift-checker.md（降级兜底,主进程代写） | ☑ |
| 2 | 10-10 11:1x | drift-checker | Phase 2 偏移检查（重试轮） | failed | provider 拒启×1;累计×3 触发 Rule 7/41 换道决策（不再逐 Phase 重试,本会话走 61.5 兜底轨） | subagent-state/02-drift-checker.md（降级兜底,主进程代写） | ☑ |
| 3 | 10-10 11:2x | executor | S1 Rule 73 七子条追加 critical-rules 文末 | done | +16/-0 纯 EOF 追加;grep 73.[1-7]=7;主进程 Read 复核+commit 917ff95 | subagent-state/03-executor-S1.md | ☑ |
| 4 | 10-10 11:3x | executor | S2 SKILL K1-K6 接线+templates/task_plan.md 🔒 区块 | done | SKILL +8/-3(计数行原地改写)+模板 +10/-0;契约 lint 两轮拦截(prompt 超限+多 ID)后过;commit 759f8cb | subagent-state/04-executor-S2.md | ☑ |
| 5 | 10-10 11:4x | executor | S3 新建 templates/deprecated.md 五段废弃模板 | done | +32/-0 与设计稿 §2 逐字一致(VERBATIM_IDENTICAL);步骤枚举 lint 拦截(①-⑤)修正后过;commit e91b6cc | subagent-state/05-executor-S3.md | ☑ |
| 6 | 10-10 11:5x | executor | S4 check-complete [judge-gate]+posttooluse [judge] 双承载 | done | +18/-0 + +5/-1;三档冒烟过;上报设计稿 §4.1 零匹配捕获缺陷(后续 06b 修) | subagent-state/06-executor-S4.md | ☑ |
| 7 | 10-10 11:5x | executor | S4 验收修正:judge-gate 计数行鲁棒化(06b) | done | `|| echo 0`→`|| true`+case 兜底;+2/-1;enforce exit=1/off SKIPPED/warn OK 三冒烟 | subagent-state/06b-executor-S4-fix.md | ☑ |
| 8 | 10-10 11:6x | executor | S5 selftest-decision-drift.sh(DD-01~22)+registry 登记 | done | 22/22 PASS(独立复跑同);+185 +1 行;commit f6bf03e | subagent-state/07-executor-S5.md | ☑ |
| 9 | 10-10 16:0x | code-runner-agent | S6 新 selftest+judge-gate 三档+hook 冒烟(独立验证) | done | 3/3 PASS;字节同源 harness 取证;properties=42 | subagent-state/09-runner-S6.md | ☑ |
| 10 | 10-10 16:1x | code-runner-agent | S7 全量回归 vs 基线 | done(FAIL 结论) | 72 脚本;5 存量 selftest rc=1(级联漏改)→触发 S9;ΣFAIL=5 | subagent-state/10-runner-S7.md | ☑ |
| 11 | 10-10 16:2x | executor | S9 五存量 selftest 锚宽容化(K9,例外登记批修) | done | 5 文件各 1 行;rc 1→0;负断言保留;commit(worktree) | subagent-state/11-executor-S9.md | ☑ |
| 12 | 10-10 17:0x | code-reviewer | S8 CR Gate 首轮全量审查 | done(CHANGES_REQUESTED) | MAJOR×1(judge-gate 缺 plan_tier 门控)+MINOR×1(DD-14 弱)+Nit×1;驳回单五要素齐 | subagent-state/12-code-reviewer-S8.md | ☑ |
| 13 | 10-10 17:2x | executor | S10 CR 修复:档位门控+DD-14b+分隔符 | done | 3 文件 +31/-17;harness 四态过;commit(worktree) | subagent-state/13-executor-S10.md | ☑ |
| 14 | 10-10 17:3x | code-reviewer | S8 CR 复检 | done(APPROVED) | 三发现全 CLOSED;0 MAJOR/0 BLOCKER/0 新发现;23/23 PASS | subagent-state/14-code-reviewer-recheck.md | ☑ |
| 15 | 10-10 17:4x | drift-checker | Phase 5 偏移检查(本轮改派通用执行体替代检查) | failed→fallback | provider 拒启持续;按已登记换道决策走 61.5 兜底(check-drift.sh+三锚对照,主进程代写检查点) | subagent-state/10-drift-checker-p5.md（降级兜底,主进程代写) | ☑ |

> rescue 说明:行 1/2/15 为 drift-checker provider 拒启(22.3 ①改派不可用——同 provider 同模型),按 61.5 降级链处置(Read 检查点→重试 1 次→check-drift.sh 兜底+债务登记),换道决策已登记 Decisions+Drift Log;retry_count 累计见 progress.md。

## 📝 Drift Log（Rule 64.1③ — drift 检查留痕）

| 时间 | 检查点 | 判定 | 依据（三锚对照摘要） | 处置 |
|------|--------|------|---------------------|------|
| 2026-10-10 10:5x | Phase 1 complete | ALIGNED（附注） | Goal=R1-R6→Rule 73 设计稿；动作=侦察+design-draft+计划完备化；scope 内（v159 attest 还原为事故补救已登记）；GOAL-EMPTY 缺口已补 `## Goal` 段 | 继续 Phase 2 |
| 2026-10-10 11:1x | Phase 2 complete | ALIGNED | GOAL-OK 12/12；动作=worktree 建成(a538a3a)+四文件三方 diff=0+基线 71/71 rc=0；scope 内；SCOPE-BREACH=脚本误报（progress 页脚路径文本） | 继续 Phase 3 |
| 2026-10-10 11:0x | 61.5 换道决策（Rule 7+41） | debt | drift-checker provider 拒启累计 ×3（Phase 1×2+Phase 2×1，同因同法）→ 不再逐 Phase 重试，本会话换道 61.5 兜底轨（check-drift.sh+主进程三锚对照） | 后续 Phase 用兜底轨；欠账=新会话/部署位补派 drift-checker 验证 |
| 2026-10-10 12:0x | Phase 3 complete | ALIGNED | GOAL 12/12;五 commit(917ff95..f6bf03e)+scope 一致+零删除既有条款;[align]×2+[judge]×1 留痕（73.4 自我执行） | 继续 Phase 4 |
| 2026-10-10 16:2x | Phase 4 complete | ALIGNED | GOAL 12/12;FAIL→S9→R2 独立回归 72/72 rc=0 ΣFAIL=0 闭环;修复限于例外登记范围 | 继续 Phase 5 |

## Notes
- 六条 R 全部 [目标]；终验必须 58.5 三态裁决，核心需求未 covered 禁 COMPLETE
- 合并预案：v152 已实证三轮并集（标签并集+C 编号让位链+末行假设宽容化）——开工前先读其 findings「五方并集教训」
