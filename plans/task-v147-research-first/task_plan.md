# Task Plan: task-v147 — Rule 63 检索优先与反推诿纪律落地

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「优化当前技能中，优化当前技能，明确技能是用来解决问题的，也就是说，是解决问题，要想尽一切办法解决问题，这是不变的目。当抑制任何形式的就是推诿以及各种就是不作为的行为。」<sub>（[目标]）</sub>
- **R2**: 「遇到问题需要主动去探索，主动去检索资料。因为当前我发现一个非常大的缺陷，就是遇到问题的时候不去不去查找资料，这是严重的缺陷，需要将查找资料列为是一个非常首要的信息来源。因为当前的Agent它是拥有网络访问权限，拥有网络访问权限就是它可以访问的资料基本就属于无限制的。」<sub>（[目标]）</sub>
- **R3**: 「不要告诉我不知道这个，不知道那个的，这都是无限，这都是推诿的。在拥有网络权限之后，除非有，除非是用户的私人数据，其他的就是其他的数据应该是基本都可以查得到的，不要告诉我不知道这个不知道那个的。记住的，记住，不知道的事情去网上查，不清楚的事情去网络上查，或者说找寻找资料。」<sub>（[目标]）</sub>
- **R4**: 「我想表达的不是让你去胡编乱造，就是不能无法解决的问题，不是让你去胡编乱造，而是让你在有理有据的情况下去解决，所有的事情都需要有理有据。」<sub>（[目标]）</sub>
- **R5**: 「那就是存在的问题就是没有能够充分利用网络资源，网络上什么都有，记住。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | critical-rules.md 含 63.1 目标公理 + 63.3 反推诿禁令条款文本（grep `^### 63 ` 与 `63.1`-`63.6` 锚全在位） |
| R2 | VC-1, VC-3 | 63.2 检索优先条款（含四步检索链与网络无限制公理）在位；subagent_dispatch.md 检索契约行在位（grep "Rule 63"） |
| R3 | VC-1, VC-2 | 63.3「不知道」合法形态约束在位；SKILL.md 摘要 bullet + 合规清单 C44 在位（grep 1-63 计数=3） |
| R4 | VC-1 | 63.4 有理有据边界条款（禁编造+not-solved 诚实收场）在位 |
| R5 | VC-4, VC-6 | selftest-research-first.sh PASS FAIL=0 + 部署三位 IDENTICAL（规则生效到运行位） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则本体（行为公理层） | 规则体系只有「失败后检索」（22.3.0 换道档/Rule 60 障碍替代）而无「第一反应检索」公理条款——知识缺口场景无条款约束，agent 以「不知道」收场合规 | Rule 63 全六子条（63.1 目标公理/63.2 检索优先/63.3 反推诿禁令/63.4 有理有据边界/63.5 衔接/63.6 机制） | VC-1 |
| 传播面（主进程消费） | 条款落在 references 深处，SKILL 主文档无摘要锚 → 主进程不可见 | SKILL.md 三处 1-62→1-63 + Rule 63 摘要 bullet + 合规清单 C44 | VC-2 |
| 传播面（子代理消费） | 子代理任务书无检索义务字段 → 派发执行体延续「不知道」行为 | subagent_dispatch.md §2 检索优先契约行 | VC-3 |
| 守护面 | 新条款无静态守护 = 条款死文（53.2 根治判据）；且 FF-16 负断言 `^63\.[0-9] ` 会误拦新规则（锚级联） | 新增 selftest-research-first.sh + registry 登记 + FF-16 宽容化 63.x→64.x | VC-4, VC-5 |
| 生效面 | 规则只落仓不部署 = 运行位（~/.zcode/skills 等）行为不变 | smart-merge-back --deploy 三位对账 IDENTICAL | VC-6 |

<!-- plan_tier: standard -->
## Goal
落地 Rule 63「检索优先与反推诿纪律」（用户 2026-10-08 裁决：解决问题是唯一不变目标，不知道先查不说不知道、联网检索=首要信息源、一切有理有据禁编造）——条款文本+SKILL/派发模板传播+selftest 守护+守卫锚宽容化，全量 selftest 无回归增量后合并回 master 并部署 3 实体位 IDENTICAL。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本：selftest-research-first.sh 新增 + selftest-four-file-dataflow.sh 宽容化） |
| `session_id` | `adee1adf8a8c4489` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first` |
| `scope_files` | 见「⚠️ 执行范围限制」 |
| `interaction_mode` | `silent`（本任务按 Rule 56 用户指令优先自动执行；用户显式指令=授权；静默决策清单随交付呈报） |
| `对齐审查` | `alignment-review（review-library 池/用户级技能在位）——Phase 4 收尾全文档过审（42.6.2）` |
| `自动超时默认项` | `审查修复循环询问点：默认=按 CR/对齐意见修复，超时 5 分钟；低区分度步骤差异选项按 44.2 直接裁决登记` |
| `new_rule` | `63`（rule-reserve check=free，2026-10-08；attest 自动预留） |
| `质量审查工具` | `code-reviewer（既有 agent，审 .sh diff）+ alignment-review（用户级技能，42.2 检测在位），执行期用登记工具` |
| `template_type` | `rule-enhancement` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | critical-rules.md 含 Rule 63 全六子条（`^### 63 ` 头 + 63.1-63.6 锚；含目标公理/四步检索链/「不知道」合法形态/禁编造边界） | `grep -cE '^63\.[1-6] ' critical-rules.md` = 6 且 `^### 63 ` = 1 | worktree/主仓 `skills/task-planner/references/critical-rules.md` |
| VC-2 | SKILL.md 三处 `1-62`→`1-63` + Rule 63 摘要 bullet + 合规清单 C44 | `grep -c "1-63" SKILL.md` ≥3 且 `grep -c "Rule 63" SKILL.md` ≥3 且 C44 行在位 | `skills/task-planner/SKILL.md` |
| VC-3 | subagent_dispatch.md 含检索优先契约行（引用 Rule 63，含「不知道先检索+来源锚+禁编造」语义） | `grep -n "Rule 63" templates/subagent_dispatch.md` ≥1 | `skills/task-planner/templates/subagent_dispatch.md` |
| VC-4 | selftest-research-first.sh 在位且全 PASS（Total 行 PASS=N FAIL=0）+ selftest-registry.tsv 登记行在位 | `bash scripts/selftest-research-first.sh` Total 行 + `grep research-first selftest-registry.tsv` | worktree `scripts/` |
| VC-5 | 无回归破坏：全量 selftest ΣFAIL ≤ 基线 4（periodic PR-03/04/05/10 基线预存）；selftest-four-file-dataflow.sh 18/18 PASS（FF-16 宽容化后） | 逐脚本 Total 行求和（Rule 57 Round 记录）；FF 脚本单独跑 | worktree `scripts/selftest-*.sh` |
| VC-6 | 合并回 master + `--deploy` 全位 IDENTICAL（脚本 exit 0） | smart-merge-back.sh 输出逐位 IDENTICAL + exit 0 | 主仓运行日志 |
| VC-7 | rule-reserve land 63 账本行在案 + CHANGELOG [Unreleased]/新增 含 Rule 63 条目 | `grep '"rule":63' plans/.rule-reservations.jsonl` 含 landed + `grep -n "Rule 63" CHANGELOG.md` | `plans/.rule-reservations.jsonl`、`CHANGELOG.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`——终验前必须先通过 Code Review Gate（APPROVED），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1-R5（全部 [目标]） |
| **裁决** | solved |
| **解决证据锚** | verification.md VC-1..7 全 PASS；master=e18045d；三位部署 diff=0；运行位冒烟 63 六子条在位 |
| **未解决面+原因** | 无（登记债 4 项见 verification.md，均非本任务目标面） |
| **已排除路径** | 不适用 |
| **下一步建议** | 见交付总结下一步建议段 |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文档 | `skills/task-planner/references/critical-rules.md`（尾部追加 Rule 63 + 必要头注计数联动） | 其他 references/*.md |
| 技能主文档 | `skills/task-planner/SKILL.md`（1-62→1-63 三处 + Rule 63 bullet + C44） | 其他段落 |
| 派发模板 | `skills/task-planner/templates/subagent_dispatch.md`（§2 检索契约行 ≤4 行） | 其他模板 |
| 守护脚本 | `skills/task-planner/scripts/selftest-research-first.sh`（新增）、`scripts/selftest-four-file-dataflow.sh`（FF-16 宽容化）、`scripts/selftest-registry.tsv`（追加行）、锚扫描命中的其他 `selftest-*.sh`（宽容化，≤2 个，逐个登记） | 其他 scripts/*.sh 业务逻辑 |
| 变更日志 | `CHANGELOG.md`（仓根，[Unreleased]/新增 头部条目） | 其他文档 |
| plans/ | `plans/task-v147-research-first/**`（计划系统文件，主进程白名单②） | 其他 plans/ 目录 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部 | 既有衔接规则（Rule 60/22.3.0/35/41/54/58 全文） | `skills/task-planner/references/critical-rules.md`（master e54973d） | 必读 | ☑ 主进程已读 |
| 项目内部 | SKILL.md 联动三锚点（:9/:275/:346）与合规清单尾（C43 后） | `skills/task-planner/SKILL.md` | 必读 | ☑ 主进程已读 |
| 项目内部 | FF-16 负断言行（:27 注释/:108 断言） | `skills/task-planner/scripts/selftest-four-file-dataflow.sh` | 必读 | ☑ S4 执行体开工前 Read |
| 项目内部 | selftest 脚本范式与 registry 三列格式 | `scripts/selftest-four-file-dataflow.sh` + `scripts/selftest-registry.tsv` | 参考 | ☑ |
| 项目内部 | 派发任务书 §2 契约行结构 | `skills/task-planner/templates/subagent_dispatch.md` | 参考 | ☑ 主进程已读 |
| 用户级规范 | 宪法 §七 调研驱动链路（检索工具优先级） | `~/.zcode/AGENTS.md` §七 | 参考 | ☑ 已载 |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 技能规则体系缺「检索优先/反推诿」公理层条款——既有规则只覆盖「失败后换道检索」（22.3.0）与「遇障碍枚举替代」（Rule 60），agent 遇知识缺口以「不知道」作答不违反任何现行条款；用户裁决这是严重缺陷。解决后交付 = Rule 63 条款+传播+守护+部署生效，结果可交付。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？
- [x] 核心问题的解决方法是清晰的、可执行的？

## 🔍 证据面清单（Rule 58.1）

> `n/a（纯执行类）`——本任务产出=条款文本+脚本+部署，非调研/归因结论；Rule 63 条款内容本身的「证据」=用户本会话原话（R1-R5 逐字抄录于需求原文区）+既有规则衔接面第一手 Read（必要知识储备表）。

## Current Phase

Phase 5

## Next Step

交付总结呈报（终态：solved，全 VC PASS）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（init-session/attest/rule-reserve）+ 计划系统文件 | 白名单②③，主进程 |
| Phase 2 | Agent 子代理 executor(sonnet-1)×3 + code-assistant(haiku-1)×1（并行组 u-land） | 四个 S-unit 文件集互不相交、输入独立、验收独立 → 组内并行；git commit 收敛主进程单写者规避 index.lock 相争 |
| Phase 3 | Agent 子代理 executor(sonnet-1) | selftest 撰写为判断型，依赖 Phase 2 产物在位 |
| Phase 4 | Agent 子代理 code-reviewer + general-purpose(sonnet-1) 伴飞 alignment-review（并行组 u-review）+ 主进程机械回归（白名单③只读 Total 行采集） | 双审查只读且文件集不相交可并行；回归=机械验证命令白名单③ |
| Phase 5 | 机械守卫脚本（smart-merge-back --deploy / rule-reserve land / sync-todos --index） | 白名单①git 编排+②簿记 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（无用户点名 /workflow、无长链复用）→ 按 Rule 21.4 独立性守门调度（声明组并行，未声明=串行）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定

## Phases

### Phase 1: 计划与基线锁定
- [x] 用户指令复述与复杂度评估（高风险文件=skills → task-planner 全流程）
- [x] 仓库状态盘点（v146 COMPLETE 遗留簿记未提交=无并行冲突；Rule 63 空闲；interaction_mode=null）
- [x] 既有规则衔接面 Read（Rule 60/22.3.0/35/41/54/58 定位互补分工）
- [x] 六文件初始化 + task_plan/findings/knowledge-brief 填充
- [x] attest 锁定（SHA cacfb3cf…；new_rule 行解析 fail-open → rule-reserve reserve 63 手动补登，账本 reserved 行在案）
- [ ] 知识储备必读项已确认（见上表 ☑）
- **V-N:** VC-7（预留登记部分）, VC-1（条款草案就绪）
- **Status:** complete
- **Executor:** 主进程（例外理由: ② 计划系统文件维护（六文件/attest/rule-reserve）——Rule 25.3 白名单）

### Phase 2: worktree 创建与规则文本落地
- [ ] 创建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first`（分支 `wt/task-v147-research-first`，基点 master e54973d）
- [ ] S1-S4 并行落地（组 u-land；子代理只写文件不 commit，Phase 收口主进程按 scope 清单统一提交——规避 git index.lock 相争，四问②化解）
- [x] 主进程逐 S-unit 三证据验收（Read 产出+grep 断言）+ 按 Rule 27 提交
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S1 | critical-rules.md 尾部追加 Rule 63 全六子条（按 findings「条款草案」锚逐字落地） | executor(sonnet-1) [parallel-group:u-land] | `<worktree>/skills/task-planner/references/critical-rules.md`（尾部锚=Rule 59 段末行 766）；条款草案=`plans/task-v147-research-first/findings.md` §Rule 63 条款草案 | `grep -cE '^63\.[1-6] '` =6、`^### 63 ` =1、头注 1-62 计数联动、既有行零改动（`git diff` 仅追加） | 14min | 1f/75l/14min | 无 | done |
| S2 | SKILL.md 三处计数 1-62→1-63 + Rule 63 摘要 bullet + 合规清单 C44 + 仓根 CHANGELOG [Unreleased] 条目 | executor(sonnet-1) [parallel-group:u-land] | `<worktree>/skills/task-planner/SKILL.md`（锚 :9/:275/:346+Critical Rules bullet 尾+C43 后）；`<worktree>/CHANGELOG.md`（Unreleased/新增 头部）；bullet 与 C44 文案=findings §SKILL 联动文案锚 | grep "1-63" ≥3、"Rule 63" ≥3、C44 行在位、CHANGELOG 条目在位；两文件其余行零改动 | 12min | 2f/22l/12min | 无 | done |
| S3 | subagent_dispatch.md §2 增检索优先契约行（≤4 行） | code-assistant(haiku-1) [parallel-group:u-land] | `<worktree>/skills/task-planner/templates/subagent_dispatch.md`（插入点=§2 knowledge-brief 行后）;文案=findings §SKILL 联动文案锚 | grep "Rule 63" ≥1 且含「检索/不知道/来源」语义词；其余行零改动 | 6min | 1f/5l/6min | 无 | done |
| S4 | 守卫锚宽容化：selftest-four-file-dataflow.sh FF-16 负断言 `^63\.` → `^64\.`（含 :27 注释）+ 全 selftest 扫描 `1-62`/`40-62`/`63\.` 断言点并宽容化（命中 ≤2 文件逐个登记） | executor(sonnet-1) [parallel-group:u-land] | `<worktree>/skills/task-planner/scripts/selftest-four-file-dataflow.sh`（:27/:108）;扫描 selftest-*.sh 中旧计数与 63.x 负断言残留（模式清单见 brief §5 S4 行） | selftest-four-file-dataflow.sh 全 PASS（18/18）;扫描输出登记 progress;改动仅断言宽容化行+注释 | 10min | 2f/10l/10min | 无 | done |

### Phase 3: selftest 守护新增
- [x] S5 新增 selftest-research-first.sh（RF-01..12 断言）+ registry 登记行
- **V-N:** VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S5 | 新增 scripts/selftest-research-first.sh（断言 Rule 63 六子条锚+dispatch 契约行+SKILL C44+FF-16 宽容化后前向断言+零新键声明）+ registry 追加行 | executor(sonnet-1) | 范式参照=`<worktree>/skills/task-planner/scripts/selftest-four-file-dataflow.sh`（Total 行输出格式+断言函数式）；registry 三列格式=`scripts/selftest-registry.tsv` 尾行；断言清单=findings §RF 断言清单锚 | `bash selftest-research-first.sh` Total: PASS=N FAIL=0；registry 尾行含 research-first；不触碰既有脚本断言（防锚级联，55.6 范式） | 15min | 2f/95l/15min | 无 | pending |

### Phase 4: 回归+双审查（u-review）
- [x] 主进程全量回归（白名单③，仅采 Total 行）：ΣPASS=969/ΣFAIL=4 对照基线 934/4（+12 RF+23 v148 守护；FAIL=4=periodic 基线），Round 1-3 记录在 progress
- [x] S6 code-reviewer 审 .sh diff（APPROVED）；S7/S9 对齐审查（APPROVED/CHANGES_REQUESTED→已处置）
- [x] 审查意见修复闭环（EG 注解/SKILL:9/CHANGELOG 三处，S8 由主进程 trivial 通道承载）
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S6 | Code Review：审查 selftest-research-first.sh 新增与 FF-16 宽容化 diff（正确性/断言语义/级联面） | code-reviewer(sonnet-1) [parallel-group:u-review] | `<worktree>/skills/task-planner/scripts/selftest-research-first.sh` + `git diff wt 基点..HEAD -- scripts/selftest-four-file-dataflow.sh` | 返回 APPROVED 或 CHANGES_REQUESTED+逐条意见（8 字段返回） | 12min | 2f/0l/12min | 无 | pending |
| S7 | 对齐审查（文档面）：Rule 63 条款文本 vs SKILL.md 联动点一致性+版本一致性校验（42.6.1→42.6.2）；dispatch/CHANGELOG 联动面交 S9 | general-purpose(sonnet-1) [parallel-group:u-review] | `<worktree>/skills/task-planner/references/critical-rules.md`（Rule 63 段）+`<worktree>/skills/task-planner/SKILL.md`（联动点）；流程=伴飞技能 SKILL.md 首动作 Read | 返回 APPROVED 或意见清单；发现项逐条带 file:line | 12min | 2f/0l/12min | alignment-review | pending |
| S8 | （预留）CR/对齐审查意见修复——实际由主进程 ≤3 行 trivial 通道承载（EG 注解/SKILL:9/CHANGELOG 三处） | 主进程（白名单⑥） | 意见清单（Handoff 表结论列） | 逐条意见闭环（fix 后复跑对应 selftest PASS） | 14min | 2f/30l/14min | 无 | done |
| S9 | 对齐审查（模板/日志面）：subagent_dispatch.md 检索契约行与 CHANGELOG 条目 vs Rule 63 原文一致性 | general-purpose(sonnet-1) [parallel-group:u-review] | `<worktree>/skills/task-planner/templates/subagent_dispatch.md`（§2 契约行）+`<worktree>/CHANGELOG.md`（Unreleased 条目）；对照=findings §SKILL 联动文案锚 | 返回 APPROVED 或意见清单；发现项逐条带 file:line | 8min | 2f/0l/8min | 无（技能路径改 prompt 内联） | done |

### Phase 5: 合并回+部署+收口
- [x] worktree 内 git status 干净 → smart-merge-back 合并（master=e18045d）；claude/opencode 两位 IDENTICAL，zcode 位运行位自保护 REJECTED→手动原子换位（v126/v129 先例）后三位 diff=0
- [x] worktree 清理（worktree remove+branch -d 完成）；遗留 companion .backup-* 六目录按用户规则移出扫描路径（~/skill-deploy-backups-taskv147-companion）
- [x] rule-reserve land 63（landed 行在案）；sync-todos --index 完成
- [x] 终验：VC-1..7 全 PASS+委派统计（0.6 WHITELIST-EXEMPT）+需求覆盖 5/5 covered+核心裁决 solved+质量门控抽查——见 verification.md
- [ ] 交付总结（五要素）→ 会话交付
- **V-N:** VC-6, VC-7
- **Status:** complete
- **Executor:** 主进程（例外理由: ① 纯 git/worktree 编排 + ② 计划系统文件簿记（INDEX/verification/land）+ ③ 机械验证命令——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk→可控`：主仓有 v146 遗留未提交簿记（plans/task-v146-*/与 INDEX/reservations——均为 plans/ 系文件，与本任务 scope 零交集；v146 已 COMPLETE 无并行会话）；无遗留 wt 分支 |
| `isolation` | `worktree`（skills 修改=§十一 P0 强制隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first` |
| `branch` | `wt/task-v147-research-first` |
| `merge_back` | `merged(e18045d)` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | S1 条款与既有规则语义重叠/冲突 | 7 | 4 | 3 | 84 | 衔接面已第一手 Read（63.5 分工条）；对齐审查兜底（Phase 4 S7） |
| Phase 3 | S5 断言写错/锚漂移致 FAIL | 5 | 4 | 2 | 40 | 主进程重跑定位 → 22.3 ① 改派修复 |
| Phase 4 | 全量回归 FAIL 增量（未知级联锚） | 6 | 3 | 2 | 36 | 扫描命令先行（S4）；FAIL 归因后回炉修复（22.3.0 资料先行+拆细） |
| Phase 5 | 部署位 REJECTED/DRIFT | 8 | 3 | 2 | 48 | smart-merge-back 逐位对账输出定位；基准=主仓 skills/task-planner 复核后重部署 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-08 | S1 映射已建 |
| Phase 2 | ☑ | 2026-10-08 | S1 映射已建 |
| Phase 3 | ☑ | 2026-10-08 | S1 映射已建 |
| Phase 4 | ☑ | 2026-10-08 | S1 映射已建 |
| Phase 5 | ☑ | 2026-10-08 | S1 映射已建 |

## Key Questions

1. Rule 63 与 Rule 60/22.3.0/41 的边界？→ 已答：触发面互补（知识缺口即时检索 vs 障碍替代 vs 失败后换道 vs 升级收敛），63.5 衔接条写明，引用不重述。
2. FF-16 负断言如何宽容化而不破守护？→ 断言窗口 63.x→64.x（v121/v146 括注演进先例），注释登记 task-v147。
3. 并行组与 git 提交冲突？→ 子代理只写文件，commit 收敛主进程 Phase 收口单次按 scope 清单提交。

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 新规则编号=63 | rule-reserve check 63=free（2026-10-08）；attest 自动预留，合并后 land |
| 规则名「检索优先与反推诿纪律」 | 覆盖 R1-R5 全诉求；与 Rule 60（障碍替代）/22.3.0（失败换道）分工写进 63.5，引用不重述零语义重复 |
| interaction_mode=silent 自动执行 | Rule 56 用户指令优先与自动执行（task-v140 用户裁决：不添加人工审查步骤）+ 用户本会话显式指令=授权；计划全文落盘可查，静默决策清单随交付呈报复核 |
| 条款草案主进程预写落 findings，派发经锚供料 | 21.2.1 台账供料优先+22.4 §9 prompt 预算（草案 ~2.5K 字符超预算）；Rule 36.5 纯增量（仅尾部追加，零删改） |
| S1-S4 组内并行、commit 收敛主进程 | 21.4 四问：文件集/输入/验收互不相交=可并行；git index 写面=资源相争②→单写者化解 |
| 思路复述已呈示 | 28.2.1：用户指令复述+五 Phase 序列+执行体档位+门控兜底已在会话开头呈现（silent 模式等效登记） |
| silent: scope 微扩展+selftest-requirement-coverage.sh（RC-15 宽容化） | S4 扫描发现第 3 处同型 63.x 负断言（:172 grep -c），Rule 63 落地后必 FAIL；同范式机械平移零风险，不扩则 Phase 4 回归必红——按根源解决（53.2）当轮修复，计划 scope 行「≤2 个」由本行扩展为「≤3 个」 |
| silent: drift-checker provider 拒绝改派 general-purpose | 22.3① 改派（v127/v129 先例同型）；检测契约逐字不变 |
| silent: 派发 prompt 补 [parallel-group:u-land] 组标记 | 首轮派发 prompt 漏带计划已声明的组标记致串行槽拦截——契约执行缺口纠正，非规则变更 |
| silent: S5 主进程接管（25.3 白名单⑤） | executor 两轮零产出（规格歧义推理空转/产出停留回复文本）——Rule 7 两败换道，22.3 兜底接管（单文件 ~120 行 ≤300 上限）|
| silent: scope 扩展至全部锚级联守卫（+6 脚本） | Rule 63 落地后 6 守卫字面锚断言必 FAIL（回归 Round 1 实测归因）——级联系确定性强制而非可选；同 53.2 根治判据当轮修复 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| 首次盘点命令以 plans/ 子目录为 CWD 致相对路径 miss | 1 | 改绝对路径重跑 | → progress.md Error Log |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 10-08 | ALIGNED | 全部 | Phase 1 complete：动作全落职责面，写入面仅 plans/ 白名单②（checkpoint 0-drift-checker.md） |
| 10-08 | ALIGNED | VC-1/2/3 | Phase 2 complete：8 文件全落 scope，锚级联豁免已授权（checkpoint 10-drift-checker-p2.md） |
| 10-08 | ALIGNED | VC-4/5 | Phase 4 complete：双审闭环+969/4=基线，15 diff 文件全落 scope（checkpoint 12-drift-checker-p4.md） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5 |
| 主进程直做 Phase 清单 | Phase 1（②计划系统文件）、Phase 5（①git 编排+②簿记+③机械验证）；执行中白名单接管（S5=⑤）与 trivial 修复（⑥）各已登记 |
| 委派率 | 0.6——WHITELIST-EXEMPT（全部直做理由命中 25.3 白名单①②③⑤⑥） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 10-08 | executor(sonnet-1) | S1 Rule 63 条款落地 | done | 63.1-63.6 逐字落地 +18/-0 纯追加 | 主进程复验 grep=6/1+diff+抽验首句 | findings [sub:1-executor] | subagent-state/1-executor.md | - / 0 / ☑ |
| 2 | 10-08 | executor(sonnet-1) | S2 SKILL+CHANGELOG 联动 | done | 四锚+CHANGELOG 落位；AC2 系判据过度指定，计划 VC-2 实测过 | 主进程复验 VC-2 三判据 | findings [sub:2-executor] | subagent-state/2-executor.md | - / 0 / ☑ |
| 3 | 10-08 | code-assistant(haiku-1) | S3 派发模板契约行 | done | :27 单行逐字插入 +1/-0 | grep+diff 复验 | findings [sub:3-code-assistant]（主进程兜底） | subagent-state/3-code-assistant.md | - / 0 / ☑ |
| 4 | 10-08 | executor(sonnet-1) | S4 守卫锚宽容化 | done | FF-16/EG-16/IP-14 三文件 63.x→64.x 共 10 处；FF 复跑 18/18 PASS；RC-15 登记未改（超 ≤2 上限）→ 已授权续做 | checkpoint T3-T6 + 主进程复跑 FF=18/18、RC=23/23 | findings #### [sub:4-executor]（含 RC-15 追加） | subagent-state/4-executor.md | - / 0 / ☑ |
| 5 | 10-08 | executor(sonnet-1) | S5 selftest 新增+registry | done | 两轮派发零产出（规格歧义空转×2）→ 22.3⑤ 主进程接管：脚本+registry 落地，12/12 PASS | 主进程实跑 Total 行+exit=0 | findings [sub:5-executor] | subagent-state/5-executor.md（未建，接管） | rescue=attempt1 空转/attempt2 空转/接管⑤ / 2 / ☑ |
| 6 | 10-08 | code-reviewer(sonnet-1) | S6 .sh diff 审查 | done | APPROVED；P2 EG 注解已修/P1 v148 头注豁免转交 | checkpoint+主进程修后复跑 EG 21/21 | findings [sub:6-code-reviewer] | subagent-state/6-code-reviewer.md | - / 0 / ☑ |
| 7 | 10-08 | general-purpose(sonnet-1) | S7 对齐审查（文档面） | done | APPROVED；P2 SKILL:9 枚举已修/债定性登记 | checkpoint | findings [sub:7-alignment] | subagent-state/7-alignment.md | - / 0 / ☑ |
| 8 | 10-08 | general-purpose(sonnet-1) | S9 对齐审查（模板/日志面） | done | CHANGES_REQUESTED→P2a CHANGELOG 净态已修；P1 v148 描述偏差豁免转交 | checkpoint | findings [sub:9-alignment-b] | subagent-state/8-alignment-b.md | - / 0 / ☑ |
| 9 | | executor(sonnet-1) | S8 意见修复（预留） | queued | | | | plans/task-v147-research-first/subagent-state/9-executor.md | - / 0 / ☐ |
| 10 | 10-08 | executor(sonnet-1) | 守卫锚 1-63 级联宽化（回归归因后追加） | done | 6 脚本宽化全绿+RF 12/12；Round 2 回归 946/4=基线 | 主进程 Round 2 全量复跑 | findings [sub:10-executor] | subagent-state/10-executor.md | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 任务类型判定: rule-enhancement（29 类已知类型——技能规则/条款增强，触发词命中）
- Rule 34.3: 已知类型，无沉淀预登记义务；如本任务产生新范式（如守卫锚宽容化 SOP 变体）按 34.3① 同类第 2 次触发再评估
- 处置登记: rule-enhancement 为已知类型，无需沉淀（2026-10-08）
