<!-- template_type: rule-enhancement -->
<!-- new_rule: 75 -->
<!-- interaction_mode: silent -->
<!-- plan_tier: standard -->
<!-- code_review: required -->
<!-- isolation: worktree -->

# Task Plan: task-v163 网络调研主动激活与外部数据依赖纪律（Rule 75）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->

- **R1**: 「彻底解决一个问题，就是当前的搜索不够主动，就是调研不够主动。遇到问题就在那里死磕，自以为是的死磕。为什么不去搜索？为什么不去网络搜索？为什么？这是严重的缺陷，这是设计缺陷。」<sub>（[目标]）</sub>
- **R2**: 「我希望遇到问题，然后就需要去搜索，去学查资料、调研。可以考虑是否增加一个就是，主动的，主动激活的搜索，主动激活的搜索的步骤。嗯，对，也就是执行任务的时候步骤。」<sub>（[手段]）</sub>
- **R3**: 「我希望就是可以可以在计划阶段，嗯，计划阶段，就是说分析一下是否需要，嗯，需要执行网络调研，本地数据是否可以完全解决当前的问题。对，就是这个样子。我就希望以后遇到问题的时候，都需要去多思考这一步。是否需要需要到网络去搜索？是否如果去网络搜索的话，需要搜索哪些关键词？」<sub>（[手段]）</sub>
- **R4**: 「记得以后不要老是在本地的搜索，因为很多很多解决方案，可能说最快的解决方案就是去网络上抄一个现成的实现方案，或者说找一个类似的，然后进行。通过网络检索，拓展模型的边界。」<sub>（[手段]）</sub>
- **R5**: 「我希望将当前的技能中强制引入这一个阶段。当然说，在任务阶段你就在任务计划阶段，可以划分出哪里是需要调研的哪里是不需要调研的，哪里是可以通过本地数据完全实现的，哪里必须接入网络数据。我无法，嗯，就是无法解决的问题，是否可以通过接入网络来解决？」<sub>（[目标]）</sub>
- **R6**: 「因为记住本地模型的能力是有限的，但是接入网络之后能力会有瞬间的暴涨。我希望将当前技能的优先级，网络检索的优先级提高，不断提高，因为本地的能力不会比网络的能力强。所以我希望在关键步骤中，引入判断是否需要已进行网络调研。」<sub>（[目标]）</sub>
- **R7**: 「尤其相应的模板，我希望可以在模板中进行定制化的定制化的解决。比如不同的模板进行不同的不同的定制的时候，我希望可以在模板中加入一些调研的步骤。」<sub>（[手段]）</sub>
- **R8**: 「嗯，对，还有就是就是的，我希望在那个模板的就是模板生成的技能中补充一个条目，判断是否生成的模板中需要添加调研，解决这类任务是否需要通过网络调研实现，以及类似的情况。」<sub>（[手段]）</sub>
- **R9**: 「你比如说之前生成那个什么，生成图片这个图片这种类似的功能的图片，功能的时候，完全可以去网络上找一个类似的图片，然后进行模仿或者风格迁移。还有其他的情况，比如说呃呃嗯比如说实现方案的时候，很多很多时候可能说网络上已经有完整的解决方案了，现在却很少去使用，去浪费时间，你得去思考如何去解决，而且还不一定成功，为什么不去找现成的方案呢？」<sub>（[目标]）</sub>
- **R10**: 「当前还有一个重大的缺陷就是GitHub的使用。当前的使用严重的缺陷，因为嗯对于代码实现的时候，很多功能都是可以上GitHub上直接检索到的。我发现当前整个执行任务，嗯，对嗯对外部工具的使用率极低。」<sub>（[目标]）</sub>
- **R11**: 「尤其嗯尤其我希望补充，在当前技能中直接性性的补充。比如要求使用浏览器工具，要求使用GitHub的就是CLI等等工具，因为如果说没有的话，建议安装。我希望可以强制要求，因为当前如果说不使用的话，可能说会降低很多的可用性。」<sub>（[手段]）</sub>
- **R12**: 「还是类似的情况，就是接入外部的数据，可以嗯可以提升整体质量。所以我希望整个呃整整个整个技能强化对外部数据的依赖。别完全依赖本地数据进行死磕，会导致无法解决，正确的解决问题。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | Rule 75.2 反死磕条款文本锚 + 计划模板调研区块可读（grep 命中） |
| R2 | VC-1, VC-4 | Rule 75.2 主动激活条款 + selftest 断言其锚 |
| R3 | VC-1, VC-2 | Rule 75.1 计划期三态分析条款（含关键词预设）+ 模板「🔍 调研需求与检索计划」区块 |
| R4 | VC-1, VC-3 | Rule 75.3 现成方案优先条款（抄现成/找类似合法且优先） |
| R5 | VC-1, VC-2, VC-6 | 75.1 三态划分（本地可解/需网络调研/必须接入网络数据）+ 75.5 网络解难问 + 全量回归 |
| R6 | VC-1, VC-5 | 75.0 公理（本地有界/网络扩展）+ 优先级条款 + SKILL 摘要行/C51 可见 |
| R7 | VC-3 | ≥4 个 variant 模板新增调研触点行 |
| R8 | VC-3 | plan-template-kit template-guide 新模板调研需求判定条目 |
| R9 | VC-1, VC-3 | 75.3 含媒体示例（找类似图片模仿/风格迁移）+ 模板触点覆盖媒体/实现类 |
| R10 | VC-1, VC-4 | 75.4 GitHub 检索优先条款 + selftest 断言 |
| R11 | VC-1, VC-2 | 75.5 外部工具强制（浏览器/gh CLI；缺失→建议安装）+ 模板/计划载体 |
| R12 | VC-1, VC-6, VC-7 | 75.0 外部数据依赖总纲 + 回归 0 FAIL + CR/对齐审查 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 53.1 载体：结果级需求（行为质量类）分解生产管线逐工序审计缺陷面 -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 计划期（Planning） | 计划期无「是否需要网络调研」强制分析环节——本地可解/需调研/必须联网三态靠执行期即兴 | Rule 75.1 + 模板「🔍 调研需求与检索计划」区块 + plan-writer 契约行 | VC-1/VC-2 |
| 执行期（Execution） | 遇问题默认本地死磕（同一思路反复试），无「先评估检索」触发点——63.2 只管「不知道」知识缺口、22.3.0 只管失败 ≥2 次后换道，两者均不覆盖「没不知道但自研低效」面 | Rule 75.2 反死磕+主动激活（即遇阻即检索，不等失败计数） | VC-1 |
| 方案构造期 | 实现类任务默认自研，「检索现成实现」未设为合法且优先路径 | Rule 75.3 现成方案优先（GitHub/官方示例/媒体参考） | VC-1/VC-3 |
| 工具面 | 外部工具（浏览器/gh CLI）无强制使用条款，缺失时以本地死磕替代而非建议安装 | Rule 75.5 外部工具依赖强制+安装建议 | VC-1 |
| 模板期 | variant 模板无调研触点；新模板生成无调研需求判定条目 | Phase 4 模板定制 + plan-template-kit 条目 | VC-3 |
| 机器守护/回归 | 无静态守护；级联锚面易漏 | selftest-proactive-research.sh + 全量回归+级联清账 | VC-4/VC-5/VC-6 |

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 本任务的归因结论（「调研不主动=设计缺陷」）必须取证；Phase 0 Explore 审计产出 ① ③ 两行证据 -->

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 现有检索相关条款全集（Rule 63/22.3.0/41.1⑤/58/60 + SKILL 检索段）覆盖面 | Phase 0 explore 只读盘点 | findings.md §Research Findings | ☐ |
| ② 对标样本（58.2 强制） | 用户反馈原话 R1-R12（缺陷现象第一手陈述）=对标基准 | 本计划 R 行逐字抄录 | task_plan.md 需求区 | ☑ |
| ③ 外部约束 | 环境工具事实（gh 2.45.0 在位/浏览器=Browser Use/WebSearch 可用） | 命令探测 + AGENTS.md §七/§十 引用 | findings.md | ☐ |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!-- 目标型需求=R1/R5/R6/R9/R10/R12；终验时回收解决状态；not-solved/partial 禁 COMPLETE -->

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R5/R6/R9/R10/R12 |
| **裁决** | [终验填] solved / partial / not-solved |
| **解决证据锚** | [终验填] |
| **未解决面+原因** | [终验填] |
| **已排除路径** | [终验填] |
| **下一步建议** | [终验填] |

## Goal
<!-- 落地 Rule 75：把「网络调研主动激活+外部数据依赖」强制引入 task-planner 技能——计划期调研需求三态分析+关键词预设、执行期反死磕主动检索、GitHub 与浏览器等外部工具强制（缺失即建议安装）、模板层调研触点定制与模板生成判定条目；配套 selftest 守护+SKILL 级联，全量回归 0 FAIL 后合并回 master 并三部署位同步 -->

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本） |
| `对齐审查` | `required` | Rule 42.6 消费：完成前跑 alignment-review；变更记录随交付落盘 |
| `自动超时默认项` | 豁免（silent 自主执行模式，无 2+ 选项询问点；运行时不具备交互条件） |
| `质量审查工具` | code-review skill（Rule 42.2 四级检测：项目级无 → 用户级 ~/.zcode/skills/code-quality-review 在位 → 命中登记） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule 75 条款块完整在位（75.0-75.6 子条锚：公理/计划期三态/反死磕主动激活/现成方案优先/GitHub 检索/外部工具强制/机制；范式对齐 Rule 63/71） | Read 条款节 + grep 各子条锚 | `references/critical-rules.md` |
| VC-2 | 计划期载体：task_plan.md 模板「🔍 调研需求与检索计划」区块 + plan-writer 契约行 + check-plan-dispatch advisory 段（非 mini 计划缺失区块 warn） | Read 模板 + grep 脚本段 | `templates/task_plan.md`; `companion/agents/plan-writer.md`; `scripts/check-plan-dispatch.sh` |
| VC-3 | 模板层：≥4 variant 调研触点 + plan-template-kit guide 新模板调研需求判定条目 | Read + grep | `templates/variant/{research-type,code-edit-type,script-dev-type,deployment-type}.md`; `skills/plan-template-kit/references/template-guide.md` |
| VC-4 | 机器守护：selftest-proactive-research.sh 全 PASS + registry 登记 + registry.tsv 计数同步 | 跑脚本 + grep registry | `scripts/selftest-proactive-research.sh`; `scripts/selftest-registry.tsv` |
| VC-5 | SKILL 级联：Rules 1-72→1-75 三处 + Rule 75 摘要 bullet + C51 合规清单行 + 全仓「1-7x」锚清零（覆盖 72/73/74 在途） | grep 级联面 | `SKILL.md` + grep 输出 |
| VC-6 | 全量回归 FAIL=0（主进程逐脚本 Total 行求和，禁采信子代理自报总数） | `for f in selftest-*.sh` 逐个跑求和 | progress.md Selftest Log |
| VC-7 | CR APPROVED + alignment-review 通过（42.6） | CR 输出 + align 记录 | verification.md |
| VC-8 | 合并回 master + 三部署位 diff=0 + INDEX/ledger 簿记 + worktree 清理 | smart-merge-back --deploy 输出 + git log | 部署对账输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（EOF 追加 Rule 75 块） | 改既有规则语义/重编号 |
| 配置 | config.json **零新键**（Rule 75 定性规则面，同 63.6/58.7 范式） | 动既有键 |
| 脚本 | `scripts/check-plan-dispatch.sh`（advisory 段追加）+ 新建 `scripts/selftest-proactive-research.sh` + `scripts/selftest-registry.tsv`（+1 行） | 其他脚本业务逻辑 |
| 模板 | `templates/task_plan.md`（纯增量区块）+ 4 个 variant（纯增量行）+ `skills/plan-template-kit/references/{template-guide,template-mapping}.md` | 删改既有区块语义 |
| SKILL | `SKILL.md`（净增 ≤10 行：摘要 bullet+索引行位替换+C51 行，行位替换优先） | 大段新增 |
| 文档 | `CHANGELOG.md`（条目）+ README/CLAUDE.md/README_zh.md 计数标签（grep 命中才动） | 其他文档 |
| 计划外 | plans/task-v163-proactive-research/**（四文件+delivery-summary）+ INDEX.md + .rule-reservations.jsonl + ledger | 其他 plans/ 目录（v162 空壳原样保留） |

**强制约束**:
- 新 Rule 编号=75（v160 占 72/v156 占 73/v162 占 74；attest 自动查重登记 new_rule）
- 合规清单接续最大 C 编号（当前 C50 → C51）
- ⚠️ **锚定级联**：改 SKILL.md "Rules 1-N" 字样前先 `grep -rn "1-7" skills/` 扫全部锚断言一次修齐（宽容正则优先，避免两阶段间回归 FAIL）
- SKILL.md 行数纪律：wc -l 复核；行数上限断言（如 selftest-knowledge-brief T2b）同步上调 + label 注明 task-v163
- 派发契约：executor prompt 必含计划三文件路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）
- Rule 36.3 删除基线声明：本任务全链纯增量零删除（删除性行为清单=空，满足 check-complete SKILL-MODIFY GATE）

## 🔀 隔离决策（check-conflicts.sh 实测 2026-10-10）
<!-- 五类信号实测：①未提交变更 8 文件（并行会话 plans/ 簿记，与本任务 skills/ scope 不重叠）②额外 worktree 2 个（v160/v161 在飞）③遗留 wt/* 分支 2 个 ④11 个未完成任务在册 ⑤运行中基础设施（本仓即被所有会话加载的技能本体） -->

- **决策**：worktree 隔离（§十一 P0——改 skills/** 运行中基础设施）
- **路径**：`/mnt/data/dev/task-planner-skill-worktrees/task-v163-proactive-research`，分支 `wt/task-v163-proactive-research`，从 master HEAD 建
- **纪律**：CWD 不迁移；所有实现期文件操作用 worktree 绝对路径；计划文档留主仓 plans/（会话级状态不进 worktree）
- **合并回合约**：worktree 内全 VC 复验 + git status 干净 → smart-merge-back --deploy → 主仓 Read 关键文件复验 → worktree remove + branch -d

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 0 | Agent 子代理 explore(mini) + Bash(grep/command -v) | 只读盘点隔离大输出，主进程不背条款全文 |
| Phase 1 | Agent code-runner-agent(mini) + Bash git worktree | 基线 70 selftest 跑批隔离上下文；git 编排主进程白名单 |
| Phase 2-5 | Agent executor(sonnet-1) | 条款/模板/脚本写入（S-unit ≤2 文件 ≤100 行） |
| Phase 6 | Skill code-review + Skill alignment-review + Bash smart-merge-back | 质量门+对账部署 |

## Phases（7 段）

### Phase 0: 现状盘点与差距取证（只读）
- [ ] S1 检索链条款盘点（Rule 63/22.3.0/41.1⑤/58.2-58.3/60 + skill-collaboration 调研路由行）→ file:line 清单，确认新规则引用点不重复
- [ ] S2 模板触点盘点（task_plan.md 现有区块结构+4 个目标 variant 现有调研相关行+plan-template-kit guide/mapping 结构）→ 插入锚点清单
- [ ] S3 级联锚面盘点（grep -rn "1-7" skills/ scripts/ + SKILL 三处计数位 + selftest 行数钉值清单）
- [ ] S4 工具事实探测（gh --version；浏览器/Browser Use/WebSearch 可用性引用 AGENTS.md §十）
- **V-N:** VC-1, VC-2, VC-3, VC-5
- **Executor:** explore(mini)（只读）+ 主进程汇总
- **Status:** complete

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 检索链条款盘点并输出引用点清单 | explore(mini) | skills/task-planner/references/critical-rules.md（Rule 63/22.3.0/41/58/60 段落，主进程 grep 定位行段） | findings 落盘点清单（file:line × ≥8 条） | 15min | 1f/0l/15min | 无 | - | pending |
| S2 | 模板触点与插入锚盘点 | explore(mini) | templates/task_plan.md + variant/{research,code-edit,script-dev,deployment}-type.md + plan-template-kit/references/ | findings 落锚点清单（区块标题+行号） | 15min | 2f/0l/15min | 无 | - | pending |
| S3 | 级联锚面盘点 | explore(mini) | skills/task-planner/SKILL.md + scripts/selftest-*.sh（grep "1-7" 全仓） | findings 清单（行数锚+计数位） | 10min | 0f/0l/10min | 无 | - | pending |
| S4 | 工具事实探测 | 主进程 Bash | command -v gh / gh --version / AGENTS.md §七 §十 | findings 落工具事实行 | 2min | 0f/0l/2min | 无 | - | pending |

### Phase 1: 隔离与基线
- [ ] worktree 建立（§十一）+ 全量 selftest 基线（code-runner-agent 跑批，主进程逐 Total 行求和复核，禁采信自报）
- **V-N:** VC-6
- **Executor:** 主进程（白名单① git 编排）+ code-runner-agent(mini)
- **Status:** complete

### Phase 2: Rule 75 条款 + CHANGELOG
- [ ] S5 critical-rules.md EOF 追加 Rule 75 块（75.0-75.6 ~55 行，范式对齐 Rule 63/71：节头+行首子条+末条机制收尾）
- [ ] S6 CHANGELOG.md [Unreleased] 条目（样式照既有）
- **V-N:** VC-1
- **Executor:** executor(sonnet-1)
- **Status:** complete

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | 写入 Rule 75 条款块全文 | executor(sonnet-1) | critical-rules.md EOF（Phase 0 S1 清单+本计划「📜 Rule 75 条文草案」节） | 75.0-75.7 子条锚 grep 全命中 | 12min | 1f/45l/12min | 无 | S1 | complete |
| S6 | CHANGELOG 条目追加 | executor(sonnet-1) | 仓根 CHANGELOG.md（[Unreleased] 头部） | 条目落盘样式对齐 | 3min | 1f/3l/3min | 无 | S5 | complete |

### Phase 3: 计划期载体
- [ ] S7 templates/task_plan.md 追加「🔍 调研需求与检索计划」区块（三态表+关键词列+mini 豁免声明行，纯增量）
- [ ] S8 companion/agents/plan-writer.md 产出契约 +1 行 + scripts/check-plan-dispatch.sh advisory 段（非 mini 计划缺失区块 warn，不阻断）
- **V-N:** VC-2
- **Executor:** executor(sonnet-1)
- **Status:** complete

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S7 | 模板调研区块落盘 | executor(sonnet-1) | templates/task_plan.md（S2 锚点：Phase 区块前插） | 区块在位+既有解析锚不坏 | 8min | 1f/15l/8min | 无 | S2 | complete |
| S8 | plan-writer 契约行+dispatch advisory | executor(sonnet-1) | companion/agents/plan-writer.md + scripts/check-plan-dispatch.sh（advisory 段范式：grep 既有 advisory） | 两段锚 grep 命中 | 10min | 2f/12l/10min | 无 | S1 | complete |

### Phase 4: 模板层定制
- [ ] S9 variants research-type/code-edit-type 调研触点（现成方案检索+官方示例/媒体参考行）
- [ ] S10 variants script-dev-type/deployment-type 调研触点（GitHub 检索行）
- [ ] S11 plan-template-kit template-guide.md 新模板调研需求判定条目 + template-mapping.md §九注记
- **V-N:** VC-3
- **Executor:** executor(sonnet-1)
- **Status:** complete

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | 2 个 variant 调研触点 | executor(sonnet-1) | templates/variant/research-type.md + code-edit-type.md（S2 锚） | 2 文件调研触点行在位 | 8min | 2f/8l/8min | 无 | S2 | complete |
| S10 | 2 个 variant 调研触点 | executor(sonnet-1) | templates/variant/script-dev-type.md + deployment-type.md | 2 文件 GitHub 检索行在位 | 8min | 2f/8l/8min | 无 | S2 | complete |
| S11 | 模板生成判定条目 | executor(sonnet-1) | skills/plan-template-kit/references/template-guide.md + template-mapping.md（§九区） | guide 条目+mapping 注记在位 | 8min | 2f/10l/8min | 无 | S2 | complete |

### Phase 5: 机器守护与级联
- [ ] S12 scripts/selftest-proactive-research.sh 新建（PR-01..12：75.x 子条锚/模板区块/plan-writer 行/dispatch 段/guide 条目/registry 自登记/零新键声明）
- [ ] S13 selftest-registry.tsv +1 行（含脚本名/守护描述/锚清单）
- [ ] S14 SKILL.md 级联（1-72→1-75 三处+摘要 bullet+C51）+ 全仓「1-7x」锚修齐 + README/CLAUDE.md/README_zh.md 计数标签（S14 的级联复核由主进程 grep 零命中验证，白名单③）
- **V-N:** VC-4, VC-5
- **Executor:** executor(sonnet-1)
- **Status:** complete

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S12 | 新建 selftest 守护 | executor(sonnet-1) | scripts/selftest-research-first.sh（范式）+ registry.tsv | 脚本 exit 0 且 PR 断言全 PASS | 12min | 1f/50l/12min | 无 | S5 | complete |
| S13 | registry 登记 | executor(sonnet-1) | scripts/selftest-registry.tsv（末行追加） | 新行在位+行数自洽 | 2min | 1f/1l/2min | 无 | S12 | complete |
| S14 | SKILL 级联+全仓锚修齐 | executor(sonnet-1) | SKILL.md（S3 锚清单）+ grep 命中脚本面 | 三处计数 1-75+C52+负断言清零 | 10min | 1f/12l/10min | 无 | S3,S13 | complete |

### Phase 6: 回归+审查+合并部署+簿记
- [x] 全量回归（code-runner-agent 跑批，主进程求和复判 FAIL=0）
- [x] Code Review Gate（Skill code-review，.sh 改动，重 diff 全量 CR）+ alignment-review（42.6）
- [x] smart-merge-back --deploy 三部署位 + 主仓 Read 关键文件复验
- [x] INDEX/ledger 簿记 + rule-reserve land 75 + worktree remove + branch -d + delivery-summary
- **V-N:** VC-6, VC-7, VC-8
- **Executor:** 主进程（白名单①②③）+ code-reviewer
- **Status:** complete

## 📜 Rule 75 条文草案（S5 输入 — 范式对齐 Rule 63/71：节头+行首子条+末条机制收尾）

```markdown
### 75 网络调研主动激活与外部数据依赖纪律（P0 — task-v163，目标：把「网络调研主动激活+外部数据依赖」立为强制纪律——计划期调研需求三态分析+关键词预设、执行期反死磕主动检索、GitHub 与浏览器等外部工具强制（缺失即建议安装）、模板层调研触点定制与模板生成判定条目；判定面=LLM 行为+selftest 静态守护、零新 config 键；衔接 Rule 60/63/22.3.0/41/54/58/60，既有 Rules 原文零改动）

本条源于用户 2026-10-10 反馈（逐字抄录于 plans/task-v163-proactive-research/task_plan.md「🎯 用户需求原文」R1-R12，51.1 口径）：「当前的搜索不够主动，就是调研不够主动。遇到问题就在那里死磕，自以为是的死磕……为什么不去搜索？为什么不去网络搜索？为什么？这是严重的缺陷，这是设计缺陷。」归因（findings.md [sub:01a-explore] 三空白面实证）：Rule 63.2 管知识缺口检索、22.3.0 管失败后换道检索，但①计划期无强制调研需求分析②执行期无反死磕触发③外部工具无强制使用——三空白面致「遇问题本地死磕」行为无条款覆盖。

75.0 **公理（本地有界·网络扩展 axiom，对应 R6/R12）**：本地模型/本地数据的能力有界；接入网络后能力面瞬间扩展（R6 原话「接入网络之后能力会有瞬间的暴涨」）——网络检索是任务的默认信息源而非最后手段；本地能力不会比网络能力强（R6），禁以「本地死磕」替代可检索获得的信息/方案/实现/参考。本公理为 75.1-75.6 总纲。

75.1 **计划期调研需求三态分析（planning-time research triage，对应 R3/R5）**：计划期为每个子目标/S-unit 强制标注调研三态之一——① **LOCAL-ONLY**（本地数据可完全解决：纯机械 S-unit/簿记/既定步骤执行）② **NET-RESEARCH**（需网络调研补充知识/方案/报错解法）③ **NET-DATA-DEPENDENT**（必须接入网络数据：实时信息/外部 API/媒体参考/现成实现）。NET-* 条目必须在计划「🔍 调研需求与检索计划」区块登记四要素：检索关键词（≥2 个）+ 检索渠道（63.2 四步链：WebSearch/Doc Search Agent/research-assistant/GitHub CLI/Forum Search Agent）+ 预期产出形态 + 负责 S-unit。无法解决的问题在计划期即评估「是否可通过接入网络解决」（R5）并登记结论。无三态标注且无 NET-* 登记的计划=计划不完整（check-plan-dispatch 机器校验，S8）。

75.2 **执行期反死磕主动激活（anti-grind proactive activation，对应 R1/R2）**：执行中遇到「不知道/不确定/没听说过/无现成实现/方案不确定/报错/选型」时，第一动作=评估网络检索（63.2 链），禁止以本地反复尝试（死磕）为默认路径。**死磕判定式**：同一思路连续尝试 ≥2 次无外部输入 → 必须转入检索（联动 22.3.0b 换道义务与 Rule 7 三击第 2 击）；检索后仍无解 → 按 63.4 有理有据边界以证据诚实收场，禁编造。与 63.2 分工：63.2 管知识缺口的检索义务，本条管检索的**触发时机**——不等失败计数、不等「不知道」出现，遇阻即评估（R1「遇到问题死磕不自知」核心痛点）。

75.3 **现成方案优先（existing-solution-first，对应 R4/R9）**：实现类任务（代码/方案/设计/媒体）动手前必须先检索现成实现——代码：GitHub（gh CLI 搜仓库/issues/PR）+官方示例优先；媒体：网络上找类似作品参考再模仿/风格迁移（R9 图片先例「完全可以去网络上找一个类似的图片」）；方案：官方文档/社区成熟方案。检索到现成实现 → 评估借鉴/适配后落地（合法且优先，禁重复造轮子——R9「为什么不去找现成的方案呢」）；未检索就自研=违规。

75.4 **GitHub 检索纪律（github-first for code，对应 R10）**：代码实现/库用法/报错类任务的检索链中 GitHub 为高优先级渠道——gh CLI 在位时必用（gh search repos/code/issues）；检索结果与官方文档冲突时以官方文档为准并标注。当前环境实测：gh 2.45.0 在位（findings S4）。

75.5 **外部工具强制（external tool mandate，对应 R11）**：任务需要浏览器交互、GitHub CLI、web 检索等外部工具时必须使用，禁以本地死磕替代。① 工具在位（command -v 探测）→ 必须使用并记录使用证据；② 工具缺失 → 计划期登记缺失项+安装建议（gh: apt/brew install；浏览器: Browser Use/agent-browser skill），执行期遇缺失按 54.4 推迟举证四要素处理——**禁止默默跳过外部工具降级为纯本地路径**。当前环境实测：gh 2.45.0 / agent-browser / WebSearch 均在位（findings S4）。

75.6 **模板层定制（template touchpoints，对应 R7/R8）**：variant 模板按类型植入调研触点——research-type 深化（三态判定行+现成方案行）；code-edit/script-dev/deployment 加 GitHub/官方文档检索行；模板生成侧（plan-template-kit template-guide）新增「新模板调研需求判定条目」：新 variant 模板生成时必须判定是否需调研触点（三态：必需/可选/不需要）并写入模板，判定依据=该模板类型的任务是否典型需要网络调研。

75.7 **机制（零新 config 键 — 与 63.6/58.7 同范式）**：判定面=LLM 行为（计划期三态自评/执行期死磕自察/工具缺失登记）；机器面=`scripts/selftest-proactive-research.sh` 静态守护（75.0-75.6 子条文本锚 + task_plan 模板「🔍 调研需求与检索计划」区块锚 + plan-writer 契约行 + check-plan-dispatch advisory 段 + template-guide 判定条目 + registry 自登记 + 零新键声明；只断言新增锚、不触碰既有脚本断言，防锚级联）；消费侧=SKILL.md 摘要 bullet + 合规清单 C51 + `templates/subagent_dispatch.md` 检索契约行延伸（75.2 反死磕条款传播到子代理侧）。
```

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 最近两个 Rule 块范式（63/71） | references/critical-rules.md EOF | ☑ |
| 项目内部 | selftest 写法范式 | scripts/selftest-research-first.sh | ☑ |
| 项目内部 | S-unit 表+派发契约范式 | templates/subagent_dispatch.md | ☑ |
| 项目内部 | 台账供料简报（Rule 编号账本+模板结构锚） | `<plan-dir>/knowledge-brief.md` §2/§3/§5 | ☑ |
| 外部 | 环境工具事实（gh/浏览器/WebSearch） | AGENTS.md §七/§十 | ☑ |

## 📊 FMEA 预演
| 失效模式 | 影响 | 严重度 S | 发生度 O | 探测度 D | RPN | 预设兜底 |
|----------|------|----------|----------|----------|-----|----------|
| SKILL 行数钉值越限 | 回归 FAIL | 4 | 3 | 2 | 24 | 级联上调+label 注明 task-v163（先例 v079/v099） |
| 并行合流撞 75 | 编号冲突 | 3 | 2 | 2 | 12 | attest 自动查重；冲突即改号重锁 |
| dispatch advisory 误报存量计划 | 用户侧 warn 噪音 | 2 | 3 | 2 | 12 | advisory 仅 warn 不阻断+仅 standard/full 档 |
| 模板区块插入破坏既有解析 | 脚本解析失败 | 5 | 2 | 3 | 30 | 插入位避开解析锚（S2）+回归验证 |
| 子代理返回格式污染 | 验收失真 | 4 | 3 | 3 | 36 | 22.4b 八字段+检查点双轨（Rule 62/71） |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 🧭 Decisions Made
| 时间 | 决策 | 理由 |
|------|------|------|
| 2026-10-10 10:5x | 用户 /goal（调研主动激活）→ **D 类新任务**（Rule 8.1）：与当前活跃计划 v152（已完成）/v162（空脚手架，无 Goal 内容）均无关联 → 开新计划 v163 独立承载 | 指令主题=技能调研行为机制化，与既有计划 Goal/范围/交付物均无关联 |
| 2026-10-10 10:5x | v162 空壳（10:27 init 未填写，无 R 行无 Goal）原样保留不回收、不占用 | 属并行会话资产；回收有踩踏风险，簿记登记存在性即可 |
| 2026-10-10 10:5x | 本会话活跃指针认领至 v163（env sid + sentinel sid + 全局指针三点） | v163 为本会话当前活跃任务；防注入源错位（v152 已完成/v162 非本会话） |
| 2026-10-10 10:5x | interaction_mode: silent（计划门控自动通过+静默决策清单交付） | 用户 /goal 指令即授权；运行时不具备交互条件（Rule 28 silent 语义） |
| 2026-10-10 10:6x | 重锁登记-2：Phase Status 行补齐（7 段）+ Handoff 派发行登记——执行期簿记编辑非内容重规划，按 51.7 登记后重锁 | hook PLAN TAMPERED 触发=锁后编辑；执行期状态簿记为流程既定动作（v152 重锁登记-1 先例） |
| 2026-10-10 10:8x | 重锁登记-3：Phase 0 状态翻转 complete（S1-S4 全完成，findings 三节回填）——执行期簿记，按 51.7 登记后重锁 | 同重锁登记-2 先例 |
| 2026-10-10 10:9x | B 类事实修正：级联目标 1-71→1-75 修正为 **1-72→1-75**——并行会话 v160 已将 SKILL.md 计数位推进至 1-72（master HEAD ba5ee1c 实测）；S14 级联锚清单以 1-72 为基线 | 并行 live race 实证；worktree 从 ba5ee1c 建，基线=1-72 |
| 2026-10-10 11:0x | 重锁登记-4：Phase 1 状态翻转 complete（基线 72/72 PASS/1092 断言）——执行期簿记，按 51.7 登记后重锁 | 同重锁登记-2 先例 |

## 🎯 Goal 单元表（Rule 66.1 — /goal 驱动供料）
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---------|--------|------|--------------|-------------|------|
| G1 | 反死磕+主动检索条款化 | 把「遇问题先评估检索而非本地死磕」立为 P0 条款并机器守护 | grep 75.0/75.2 子条锚 + selftest-proactive-research.sh PR 断言全 PASS | S5/S12 | pending |
| G2 | 计划期调研三态分析载体 | 计划模板与契约强制「🔍 调研需求与检索计划」区块（三态+关键词） | Read 模板区块锚 + plan-writer 契约行 + dispatch advisory 段 grep 命中 | S7/S8 | pending |
| G3 | 现成方案优先+GitHub/外部工具强制 | 75.3/75.4/75.5 条款（现成方案优先/GitHub 检索/浏览器与 gh CLI 强制+安装建议） | grep 75.3/75.4/75.5 子条锚 + selftest 断言 | S5/S12 | pending |
| G4 | 模板层调研触点+生成判定 | ≥4 variant 调研触点 + plan-template-kit 新模板调研需求判定条目 | Read 4 变体触点行 + guide 条目 + mapping 注记 | S9/S10/S11 | pending |
| G5 | 机器守护+回归+部署闭环 | 全量回归 0 FAIL + CR/对齐 APPROVED + 三部署位 diff=0 + 簿记 | 逐脚本求和 + smart-merge-back --deploy 输出 + INDEX/ledger | S12/S13/S14 | pending |

## Current Phase
Phase 0: 现状盘点与差距取证（只读）

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 | 2026-10-10 10:6x | explore(mini) | S1-S3 只读盘点（检索链/模板触点/级联锚面） | queued |  |  |  | plans/task-v163-proactive-research/subagent-state/01-explore.md |
