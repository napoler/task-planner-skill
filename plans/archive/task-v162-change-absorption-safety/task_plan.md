---
template_type: rule-enhancement
new_rule: 74
interaction_mode: silent
plan_tier: standard
code_review: required
isolation: worktree
session_id: task-v162-20261010-de2c5bba
---

<!-- new_rule: 74 -->
# Task Plan: 变更吸收三判纪律 — task-v162，Rule 74（增量默认+变更标注+定稿可行性门）
<!--
  WHAT: 本计划=用户 2026-10-10 两段反馈（D 类新任务判定，Rule 8.1：与在途 v152-159/v160/v161 均无主题重叠）的承载计划。
  WHY: 严重系统性缺陷——用户补充条目被后续条目整体替代（增量vs替代不判），反复污染既有可用内容（技能bug修复把整个技能改错实证）。
  WHEN: 用户 R1-R3 三需求→Rule 74 三支柱（74.2 三判门/74.3 逐条变更标注/74.4 定稿可行性判别门）→条文+接线+模板+守护+回归+双审查。
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「我发现当前接受就是用户新指令之后，尤其修改之后，存在一个严重的缺陷。比如说我需要补充一些，再补充一些条目的时候，非常容易出现后来的条目将之前的条目彻底替代的情况。但是实际的情况，实际情况是后来条目和和之前的条目应该是相互补充的，而不是直接替代的。但是现在的做法直接简单暴力地替代掉之前的方案，导致就是反复地污染…比如说技能中发现了一个bug，我提了之后，后期就把整个技能给我改错了，这就是严重的缺陷。我希望在解决问题的时候，应该先考虑，需要考虑是补充还是替代，就是是增量还是说替代，因为这个非常关键，不能所有的东西都直接选择替代，导致将原本可用的东西给改坏了，不断地产生污染…这是严重的缺陷，必须纠正，确保后期不会出现这种低级错误。」<sub>（[目标]：吸收语义从「默认替代」纠正为「增量优先」）</sub>
- **R2**: 「我希望在以后…所有的修改的时候，在制定方案的时候就直接标注一，哪些东西是修改的，哪些东西删除的，哪些东西是进行更新的。这样后期在执行过程中也不会不会导致偏移，而且更加的安全。」<sub>（[手段]：逐条变更标注表）</sub>
- **R3**: 「还有就是执行方案，方案修改好后，我希望可以主动地交给一个大的判别模型，判别方案的可行性，然后再去执行。这样的话就不会这样就是减少风险。就是在子代理中执行一个判别可行性…只需要再单独的子代理中，嗯，避免隔绝上下文的前提下分析任计划的可行性相对的参考性…以及安全风险就会降低很，就是可靠性就会提高，风险就会降低。」<sub>（[手段]：隔离子代理定稿可行性判别门，档位不强制大模型）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-7, VC-8 | Rule 74 三判门条款在位（增量默认/替代四条件/删除授权）+SKILL 接线+机器守护+全量回归防复发 |
| R2 | VC-3, VC-4, VC-6 | task_plan.md 模板含「📋 变更标注表」六列区块+触点引用（8.1/36.5/56）+selftest 静态守护 |
| R3 | VC-5, VC-6, VC-8 | 74.4 条文+dispatch 可行性判别契约+本计划 Phase 7 可行性门实战 dogfood 证据+双审查 APPROVED |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 条文层（规则定义） | 现有规则管「何时不修改」（36.5 保守化/36.4 删除确认）却无「吸收时先判增量vs替代」的正向门——「补充条目」与「替代方案」走同一通道直写（5 Whys 根因：吸收动作入口无三判门控，默认语义=整段重写） | Rule 74 条文 74.1-74.6（S1） | VC-1, VC-2 |
| 索引层（SKILL 全集/合规清单） | 无 Rule 74 接线面 | SKILL.md 接线+终验段+C51 合规行（S2） | VC-3 |
| 触点层（指令/修订入口） | Rule 8.1（新计划判定）/B 类重规划/36.5 保守化/56 用户指令优先均无「三判门+变更标注表」引用 | 触点修补 S3/S4（critical-rules.md 三处+SKILL 新指令处理段两处） | VC-3 |
| 模板层（计划/派发载体） | task_plan.md 无变更标注区块；subagent_dispatch.md 无法行性判别契约形态 | 模板材料包 S5/S6（2 文件新增区块，纯增量） | VC-4 |
| 机器层（守护） | 吸收语义违规零守护；「1-71」级联 pin 待演进 | selftest-absorption-discipline.sh（S7/S8）+级联清账（S9/S10） | VC-6, VC-7 |
| 回归层 | 新增行撞既有定数/范围断言（历史 5+ 判例） | 全量回归+级联清账（S9/S10） | VC-7 |
| 判别层（执行前把关） | 定稿方案无独立可行性判别；主上下文自我判=累积污染自证 | 74.4 定稿可行性判别门+Phase 7 dogfood（S11） | VC-5 |
| 分发层 | 部署位漂移（v158 遗留债务：部署位 1-69+70 vs 主仓 1-71） | 合并回 master 后部署待用户授权（§六；登记 deferred，禁擅自 --deploy） | VC-8 |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `task-v162-20261010-de2c5bba` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/v162-change-absorption-safety` |
| `scope_files` | `skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-planner/templates/task_plan.md, skills/task-planner/templates/subagent_dispatch.md, skills/task-planner/scripts/selftest-absorption-discipline.sh(新), skills/task-planner/scripts/selftest-registry.tsv`（+级联清账触达的 pinning selftest 脚本，Phase 6 执行期登记清单） |
| `interaction_mode` | `silent`（登记：用户 R1-R3 需求明确无高歧义决策点；设计为需求直接落地；主要静默决策=部署授权 deferred 待用户，按 Rule 28 登记于 Decisions Made） |
| `对齐审查` | `alignment-review`（review-library 池，Phase 7 S13 执行） |
| `自动超时默认项` | `n/a`（本任务 silent 模式无用户询问点；Phase 7 各审查子代理无 2+ 选项场景） |
| `new_rule` | `74`（账本核实：72=v160 在途预留、73=v156 在途预留、74 可用——attest 自动 reserve） |
| `质量审查工具` | `code-quality-review`（Phase 7 S12 消费；池成员，无需补建） |

<!-- plan_tier: standard -->
## Goal
在 task-planner 技能内建立 Rule 74 变更吸收三判纪律：吸收用户指令/修订时增量默认（替代须四条件门、删除须逐项授权）、修订方案逐条变更标注（新增/修改/删除/更新）、定稿方案经隔离子代理可行性判别门三态放行（PASS/PASS-WITH-RISKS/FAIL），并以条文+SKILL 接线+模板区块+selftest 静态守护+全量回归+双审查闭环确保「补充不替代」不再复发。

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）
> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 74 条文完整落盘 critical-rules.md | `grep -cE "^74\.[1-6] " references/critical-rules.md` ≥6 且标题 `### 74 变更吸收三判纪律` 在位（Rule 71 段之后 EOF 追加） | worktree: skills/task-planner/references/critical-rules.md |
| VC-2 | 三判门语义在位 | 条文含三档关键词串：「增量（默认且优先）」/「四条件全满足」/「删除（最高门槛）」+判据句「先问是补充还是替代」各 ≥1 | 同上 grep |
| VC-3 | 触点接线在位 | critical-rules.md 内 Rule 8.1 段、36.5 段、56 段各含「Rule 74」引用（新增命中 ≥3）；SKILL.md 用户新指令处理段含 Rule 74 三判门段+B 类行含「Rule 74」 | worktree: critical-rules.md + SKILL.md |
| VC-4 | 变更标注表模板在位 | templates/task_plan.md 含「📋 变更标注表」区块，六列表头关键词齐备（编号/对象/类型/增量或替代/依据/执行动作）+四类型「新增·修改·删除·更新」 | worktree: templates/task_plan.md |
| VC-5 | 可行性判别门载体在位 | critical-rules.md 74.4 子条+「69.1」分工锚+mini 档豁免措辞；templates/subagent_dispatch.md 含可行性判别契约段（三维关键词可执行性/相容性/风险性+三态 PASS-WITH-RISKS）；SKILL.md 终验段联动半句 | worktree: 两文件 grep |
| VC-6 | 机器守护在位且自跑 | `scripts/selftest-absorption-discipline.sh` 存在+chmod+x+自跑 exit 0（AD 断言 ≥12 全 PASS）；registry.tsv 含登记行；config.json 零新键 | worktree: scripts/ |
| VC-7 | 无回归 | worktree 内 `for f in scripts/selftest-*.sh; do bash $f; done` 跑批 ΣFAIL=0；SKILL.md『1-74』pin ≥2 命中且级联 pinning 脚本锚全清 | worktree 跑批输出 |
| VC-8 | 双审查+合并回+覆盖核对 | code-reviewer 与 alignment-review verdict=APPROVED；smart-merge-back 合并 master；verification.md VC 逐条复验+R 覆盖核对表全勾 | plans/task-v162-change-absorption-safety/verification.md |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1（吸收语义纠正：补充不替代） |
| **裁决** | `solved` / `partial` / `not-solved`（终验时三选一必填） |
| **解决证据锚** | （终验时填：file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （终验时填：partial/not-solved 必填） |
| **已排除路径** | （终验时填：not-solved 必填） |
| **下一步建议** | （终验时填：not-solved 必填，按 Rule 70 四要素：对象路径+看点+动作） |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 三判条文 | Rule 74.1-74.6 写入 critical-rules.md EOF | `grep -cE "^74\.[1-6] " critical-rules.md` ≥6 且标题行在位 | S1/Phase 2 | pending |
| G2 | SKILL 接线 | SKILL.md 全集/索引/References/新指令段/合规清单/C51/终验段全线接线 | grep "Rule 74" SKILL.md ≥5 命中且 C51 行在位且『1-74』≥2 | S2/Phase 2 | pending |
| G3 | 触点接线 | 8.1/36.5/56 三处+SKILL 新指令段+B 类行共 5 触点引 Rule 74 | critical-rules.md grep "Rule 74" 新增 ≥3；SKILL.md 用户新指令处理段+B 类行各 ≥1 | S3,S4/Phase 3 | pending |
| G4 | 变更标注表 | task_plan.md 模板含六列变更标注区块 | grep "📋 变更标注表" =1 且六列关键词齐备+四类型串在位 | S5/Phase 4 | pending |
| G5 | 可行性契约 | subagent_dispatch.md 含可行性判别契约段 | grep "可行性判别" =1 且三维+三态关键词在位 | S6/Phase 4 | pending |
| G6 | 机器守护 | selftest-absorption-discipline.sh 自跑 exit 0+registry 登记 | bash 脚本 exit 0（AD ≥12 PASS）+registry.tsv grep 行+config 零新键 | S7,S8/Phase 5 | pending |
| G7 | 回归清账 | 全量 selftest ΣFAIL=0+级联 pin 全清 | 跑批输出 ΣFAIL=0；grep 『1-71』SKILL.md=0；pinning 脚本『1-71』字面=0 或宽容覆盖 | S9,S10/Phase 6 | pending |
| G8 | 门控实战 | 可行性判别门 dogfood 三态结论落盘+双审查 APPROVED | checkpoint  verdict 行+findings.md 落点+两审查 verdict=APPROVED | S11-S14/Phase 7 | pending |
| G9 | 合并终验 | 合并回 master+rule-reserve land 74+VC 复验+交付总结 | git log merge commit+verification.md 核对表全勾+delivery-summary 在位 | 主进程/Phase 8 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码（技能本体） | `skills/task-planner/references/critical-rules.md`、`skills/task-planner/SKILL.md`、`skills/task-planner/templates/task_plan.md`、`skills/task-planner/templates/subagent_dispatch.md`、`skills/task-planner/scripts/selftest-absorption-discipline.sh`（新建）、`skills/task-planner/scripts/selftest-registry.tsv`、Phase 6 级联清账触达的 pinning selftest 脚本（执行期登记清单） | 其他技能文件、其他 .sh 文件、config.json（零新键） |
| 计划文档 | `plans/task-v162-change-absorption-safety/*`（六文件） | 其他 plans/ 目录（v160/v156/v163 等在途任务禁触） |
| 规则账本 | `plans/.rule-reservations.jsonl`（attest/rule-reserve.sh 自动写入，非手改） | 手改账本 |
| 配置 | 无（74.6 零新 config 键） | `skills/task-planner/config.json` 任何写入 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/版本） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | critical-rules.md Rule 8.1/36.5/51.1/56/69.1/71 原文 | skills/task-planner/references/critical-rules.md（master a538a3a 或 worktree 快照） | 必读 | ☑ |
| 项目内部文档 | SKILL.md §用户新指令处理（:238）+§Critical Rules（:294）+References 表（:382）+合规清单 C48-C50 | skills/task-planner/SKILL.md | 必读 | ☑ |
| 项目内部文档 | templates/task_plan.md + subagent_dispatch.md | skills/task-planner/templates/ | 必读 | ☑ |
| 项目内部文档 | pinning selftest 锚现状（self-resolution/lane-advancement/requirement-coverage/source-anchor SA-07/context-pressure/workflow-orchestration/research-first 七处） | skills/task-planner/scripts/selftest-*.sh | 必读 | ☑（Phase 1 执行期逐处 grep 复核校准） |
| 内部知识库 | v160/v156 计划格式基准+并集解判例 | plans/task-v160-decision-grading/task_plan.md、plans/task-v156-drift-shield/task_plan.md | 参考 | ☑ |
| 项目内部文档 | 系统级判例：Rule 20.6 账本/v128 编号预留/锚级联历史判例 | plans/.rule-reservations.jsonl | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: 用户补充指令被后续条目整体替代（增量vs替代不判）导致既有可用内容被反复污染，如何以规则+机制根治并防复发？

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？→ 能：Rule 74 三支柱落盘即可根治吸收语义缺陷
- [x] 核心问题不解决，其他工作都白费吗？→ 白费：每次吸收动作都可能回写污染（技能改错实证）
- [x] 核心问题的解决方法是清晰的、可执行的？→ 清晰：三判门（条文）+标注表（模板）+可行性门（机制）+守护（selftest）四层闭环

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 当前技能吸收机制文本现状：SKILL.md:238-262 新指令处理段（D/A/B/C 四分类）+Rule 8.1/36.5/51.1/56/69.1/71 原文+7 pinning selftest 锚+check-plan-dispatch/attest 定数断言 | Explore(mini) 子代理逐处 grep+通读 | findings.md §吸收现状审计 | ☐（S0） |
| ② 对标样本（58.2 强制） | 历史同类判例≥1 可指名：v149/v155 合并冲突并集解判例（增量优先先例）；v131 锚级联 5 犯判例（新增行撞定数断言）；Rule 36.5/v079 保守化修改纪律（默认纯增量先例）；Rule 51.1 逐条抄录（需求侧增量先例） | 子代理读 plans/ 历史计划+规则原文交叉比对 | findings.md §对标判例 | ☐（S0） |
| ③ 外部约束 | 用户 R1-R3 原话（补充不替代/逐条标注/隔离子代理判别）+宪法 §四（防漂移）§六（保护区）§十一（worktree 隔离）+Rule 20.6 编号账本 | 用户指令原文+宪法文件 | findings.md §外部约束 | ☑ |

> 归因结论（为什么污染会发生：默认替代通道）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## 📋 变更标注表（Rule 74.3 自举示范 —— 本计划为首批 consumer；S1-S14 逐行消费）
<!--
  WHAT: Rule 74.3(a) 的模板区块在本计划内的一次真实填写示范——制定方案时逐条标注类型/增量或替代/依据/执行动作。
  WHY: 本任务引入的规则自己先消费：无标注表=无效方案；本表兼任 Phase 8 验收清单。
-->
| # | 对象（文件+锚点） | 类型 | 增量或替代 | 依据 | 执行动作 |
|---|------------------|------|-----------|------|---------|
| CA-1 | skills/task-planner/references/critical-rules.md EOF（Rule 71 段之后） | 新增 | 增量 | R1 三判门需求 | 追加 Rule 74 条文 74.1-74.6（S1） |
| CA-2 | skills/task-planner/SKILL.md L9 全集行「1-69+70」 | 更新 | 替代（旧值过时缺 71——Phase 1 grep 实证；替代四条件：71 已被 v158 落地证伪旧值②；Read 旧行③；改后回归④） | R1+级联清账 | 更新为「1-74」+枚举尾部补 Rule 71/74（S2） |
| CA-3 | SKILL.md L296/L382「1-71」 | 更新 | 增量（数值演进 71→74，非语义替换——旧值语义仍真） | R1+级联 | 改「1-74」+尾部补 Rule 74（S2） |
| CA-4 | SKILL.md 合规清单 C50 行之后 | 新增 | 增量 | R1-R3 | 追加 C51 行（S2） |
| CA-5 | critical-rules.md Rule 8.1 段末 | 修改 | 增量（追加引用句，旧文逐字不动） | R1 | 补「变更吸收语义门（Rule 74）」引用（S3） |
| CA-6 | critical-rules.md Rule 36.5 段 | 修改 | 增量（追加关系说明半句） | R1 | 补 74.2 是上位总则说明（S4） |
| CA-7 | critical-rules.md Rule 56 段（56.1 末） | 修改 | 增量（追加括注） | R1 | 补增量默认消费引用（S4） |
| CA-8 | templates/task_plan.md（「执行范围限制」区块之后） | 新增区块 | 增量 | R2 | 加「📋 变更标注表」区块+四条填写规则（S5） |
| CA-9 | templates/subagent_dispatch.md 尾部 | 新增区块 | 增量 | R3 | 加「定稿可行性判别模式」契约段（S6） |
| CA-10 | scripts/selftest-absorption-discipline.sh | 新增文件 | 增量 | VC-6/74.6 | 新建 AD-01..14 断言脚本（S7/S8） |
| CA-11 | scripts/selftest-registry.tsv 末行 | 新增行 | 增量 | 74.6 机制 | 登记新脚本行（S8） |
| CA-12 | 7 个 pinning selftest 的『1-71』/『1-[67][0-9]』锚 | 更新 | 增量（数值演进，宽容形态覆盖） | VC-7 | Phase 1 取证实际清单→Phase 6 级联清账（S10） |
| CA-13 | skills/task-planner/config.json | 不改 | - | 74.6 零新键 | 无动作（AD-10 断言守护） |
| CA-14 | 部署位（~/.zcode/skills、~/.agents/skills、opencode 位等） | 暂不 | - | §六保护区+v158 遗留债务+部署需用户显式授权 | deferred 登记待用户授权；Phase 8 仅合并回 master |

> 验收映射（兼任验收清单）：Phase 8 终验时逐行勾核——类型=新增而产物缺失、类型=增量而旧内容被改，均判 FAIL（74.3(c)）。

## 📜 Rule 74 条文草案（S1 材料包 — 逐字采用，插入位置=critical-rules.md Rule 71 段之后 EOF）

```markdown
### 74 变更吸收三判纪律（P0，2026-10-10 task-v162，目标：吸收用户指令/修订时增量默认——补充条目只追加不替代既有条目；替代须过四条件门；删除须逐项授权；修订方案逐条变更标注；定稿方案经隔离子代理可行性判别门三态放行后方可执行）

74.1 **适用范围（五类吸收场景）**：① 用户新指令/补充条目并入既有计划/规则/模板/清单（"补充一些/再加一条/还有"类措辞）；② 对已批准计划的修订（Phase 重规划/VC 变更/范围调整）；③ 合并冲突裁决（并行任务并集解/worktree 合并回）；④ 子代理产出并入主上下文或文件（findings 回填/Handoff 合并/knowledge-brief 蒸馏）；⑤ 模板与规范版本更新（追加行 vs 重写段）。五类场景之外的写入按 Rule 36.5 保守化纪律执行；本规则是吸收语义的上位总则，36.5 为技能保护区特化（冲突时 36.5 更严）。
74.2 **变更三判门控（每处吸收动作前必答，答案登记变更标注表「增量或替代」列）**：(a) **增量（默认且优先）**：用户措辞含"补充/再加/还有/另外/同时"或语义为新增条目→只追加、既有条目逐字保留不动；"补充一些条目"类指令永远走本档，禁以"整合/去重/顺手重构/格式化"名义回写既有条目。(b) **替代（禁默认，四条件全满足才可）**：① 既有内容被新证据或回归测试证伪，或已被用户明示否决/作废（Rule 32 有据）；② 替代范围完整覆盖旧场景（覆盖论证写入 Decisions Made）；③ 替代前已 Read 旧内容全文（禁凭印象覆盖）；④ 替代后既有守护/selftest 全绿。缺任一→回落 (a) 增量。(c) **删除（最高门槛）**：必须取得用户逐项授权（同 Rule 36.4 门槛）；未授权只可停用/标记，禁物理删除。(d) 判据一句话：**先问是补充还是替代——补充是常态，替代是例外，删除是特许**；未做三判即写入 = P0 违规。
74.3 **逐条变更标注（修订方案无标注=无效，禁入执行）**：(a) 任何对既有文件/条目的变更，制定方案时必须在 task_plan.md「📋 变更标注表」逐条登记：编号/对象（文件+锚点）/类型（新增·修改·删除·更新）/增量或替代/依据（用户原话或证据）/执行动作。(b) 无变更标注表的修订方案=无效方案，禁入执行（attest 锁定与派发前由计划自检+selftest-absorption-discipline.sh 静态守护）。(c) 标注表兼任验收清单：执行后逐行勾核，类型=新增而产物缺失、类型=增量而旧内容被改，均判 FAIL。(d) 用户新指令到达时先把指令逐条转成标注表行，再动任何文件——**先标注后执行**（Rule 8 A 类流程入口）。
74.4 **定稿可行性判别门（子代理隔离上下文，执行前硬门）**：(a) 时机三拍：① 新建计划 attest 锁定后、Phase 1 首次派发前；② 计划重大修订后（影响 >2 Phase 或 scope_files 扩容）；③ 合并回 master 前的最终把关。(b) 载体：派发独立子代理——推理上下文与主会话隔离（避免主上下文累积污染传入判别），但材料包完整传入（计划全文+涉及规则/模板原文）；模型档位按 Rule 43.2 min 档即可，判别质量由三维判据保障而非模型规模（用户 2026-10-10 明示）。(c) 判别三维：**可执行性**（每 Phase/S-unit 有明确输入/验收/边界，无空段占位——Rule 71.1）、**相容性**（与既有规则/模板/守护无冲突，引用锚真实存在）、**风险性**（爆炸半径=触及文件数×运行中基础设施权重；回滚路径存在且可执行）。(d) 三态结论：PASS（放行）/ PASS-WITH-RISKS（登记风险项+缓解措施后放行）/ FAIL（禁执行，回炉修订后重判）。(e) 结果 30 秒内落盘 findings.md+progress.md（Rule 22.5 绑定）；与 Rule 69.1 T1 的分工：T1 判多个候选方案孰优，本门判单个定稿方案能否安全落地，互补不重复。(f) 豁免：mini 档任务（Rule 38.3）或单文件 ≤3 行 trivial 修改，可登记一行理由跳过。
74.5 **与既有规则关系（入口与语义分层，互补不重叠）**：Rule 8.1 判「新建计划 vs 改当前计划」（入口层），本规则管「一旦确定要改，怎么改才不污染」（语义层）；Rule 51.1 需求原文逐条抄录本身就是增量纪律（新需求只追加 R 行）；合并冲突裁决先试并集解（增量），并集不可行才逐 hunk 判替代（v149/v155 判例上升为条例）；Rule 56「用户指令优先」与本规则 (b) 替代门不冲突——用户明示的替代指令本身就是 (b)① 的授权形态。
74.6 **机制与守护（零新 config 键）**：① scripts/selftest-absorption-discipline.sh（AD 断言：74.x 条款锚/变更标注表模板锚/触点引用锚/可行性契约锚/SKILL 接线 pin/registry 自登记/零新键）；② templates/task_plan.md「📋 变更标注表」区块；③ templates/subagent_dispatch.md 可行性判别契约段；④ SKILL.md Rules 全集演进至 1-74+合规清单 C51+用户新指令处理段三判门指引。违规按 Rule 26 降质处置。
```

## 🧩 接线材料包（S2 逐字采用；措辞按宿主文件语体微调，禁弱化语义）
- **全集行（SKILL.md L9）**：「Critical Rules 全集 1-69+70（67-70 均经并行任务合流落地）」→「Critical Rules 全集 1-74（67-71 均经并行任务合流落地）」，并在该行枚举尾部「Rule 36 技能修改保守化与功能删除防护）」前补「、Rule 71 无源不写·空段占位·写必带锚纪律、Rule 74 变更吸收三判纪律」。
- **Critical Rules 索引段（SKILL.md L296）**：「Critical Rules 1-71（含 Rule 40-71 全集，…Rule 71 无源不写·空段占位·写必带锚纪律）」→「Critical Rules 1-74（含 Rule 40-74 全集，…）」并在尾部「Rule 71 …」后补「 / Rule 74 变更吸收三判纪律」。
- **References 表 critical-rules 行（SKILL.md L382）**：「Critical Rules 1-71（含 Rule 13-18/…/Rule 65 周期性回顾与前后对照）」→「Critical Rules 1-74（含 Rule 13-18/…）」并在「）」前补「 / Rule 74 变更吸收三判纪律」。
- **Critical Rules 索引段条目行（L296 段内 Rule 71 行后）**新增一行：
  `- **Rule 74（变更吸收三判纪律 — task-v162）**：吸收用户指令/修订先过三判门——增量默认（"补充/再加"措辞强制增量）/替代四条件全满足/删除逐项授权（74.2）；修订方案逐条变更标注无表禁执行（74.3）；定稿方案经隔离子代理可行性判别门三态放行（74.4）；机器面=selftest-absorption-discipline.sh，零新 config 键（74.6）（详见 references/critical-rules.md Rule 74）`
- **终验交付段（Completion Gate，L360 附近）**：交付总结 bullet 后补一句「会话内一切吸收动作（补充条目/计划修订/合并冲突/子代理产出并入）按 Rule 74 三判门处置：增量默认、替代四条件、删除授权；定稿方案过 74.4 可行性判别门」。
- **合规清单新增行（C50 行之后）**：
  `| C51 | 变更吸收三判自查（Rule 74）：吸收用户指令/修订前已过三判门且答案登记变更标注表（74.2）；修订方案含「📋 变更标注表」逐条标注（74.3）；定稿方案已过可行性判别门或登记豁免（74.4）（机器面=selftest-absorption-discipline.sh 静态断言，判别过程人工核查；mini 档豁免） | ☐ |`

## 🧩 触点指针材料包（S3/S4 逐字采用；纯增量追加，宿主旧文逐字不动）
- **T1 Rule 8.1 段末（critical-rules.md:29 行所在段）**追加：`变更吸收语义门（Rule 74）：指令并入既有计划（A/B 类）时，对既有计划/规则/模板的每一处变更先过 74.2 三判门——增量默认、替代四条件、删除授权；答案登记 task_plan.md 变更标注表（74.3），无标注表禁入执行。`
- **T2 Rule 36.5 段末（critical-rules.md:374）**追加：`本条是 Rule 74.2 在技能保护区的特化（替代四条件+删除确认的同位实现）；技能区以外的吸收场景按 74.2 上位总则执行。`
- **T3 Rule 56.1 末（56.1 行尾「不添加人工审查步骤。」后）**追加括注：`（吸收用户指令时的变更语义按 Rule 74.2 三判门处置：增量默认、替代四条件、删除授权）`
- **T4 SKILL.md 用户新指令处理段（L262 配套提醒 bullet 之前）**新增一段：
  `**变更吸收三判门（Rule 74 — task-v162）**：B/C 类重规划时，对既有计划/规则/模板/清单的每一处吸收先过三判（增量默认/替代四条件/删除授权）并逐条登记 task_plan.md「📋 变更标注表」；修订方案无标注表=无效，禁入执行；attest 锁定后按 74.4 派独立子代理过定稿可行性判别门（PASS/PASS-WITH-RISKS/FAIL，FAIL 禁执行）。完整条款见 references/critical-rules.md Rule 74。`
- **T5 SKILL.md B 类表格行**：B 行「先重规划再执行」格尾追加括注「（变更吸收按 Rule 74 三判门+变更标注表）」——追加括注形态，单元格旧文不动。

## 🧩 模板材料包（S5/S6 逐字采用；纯增量新增区块，模板旧区块逐字不动）
- **T6 templates/task_plan.md「执行范围限制」区块之后新增**：
  `## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）`
  `任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。`
  表头六列：`| # | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 增量或替代 | 依据（用户原话或证据） | 执行动作 |`
- **T7 templates/subagent_dispatch.md 尾部新增**：
  `## 定稿可行性判别模式（Rule 74.4 — 计划定稿后/重大修订后/合并回前派发）`
  `派发独立子代理（上下文与主会话隔离，材料包=计划全文+涉及规则/模板原文完整传入，禁只传摘要）；判别三维：可执行性（每 Phase/S-unit 有明确输入/验收/边界，无空段占位）/相容性（与既有规则/模板/守护无冲突，引用锚真实存在）/风险性（爆炸半径=触及文件数×运行中基础设施权重；回滚路径存在）；三态结论：PASS（放行）/PASS-WITH-RISKS（登记风险项+缓解后放行）/FAIL（禁执行，回炉修订后重判）；结果 30 秒内落盘 findings.md+progress.md；档位按 Rule 43.2 min 档即可；豁免=mini 档或单文件 ≤3 行 trivial（登记一行理由）。`

## 🛡️ 守护断言清单（S7/S8 材料包 — AD 断言规格，范式=selftest-source-anchor-discipline.sh/selftest-decision-grading.sh）
- AD-01 critical-rules.md 含 `### 74 变更吸收三判纪律` 标题行，且 `74.1`-`74.6` 六子条锚各 ≥1
- AD-02 条文三档关键词：「增量（默认且优先）」/「四条件全满足才可」/「删除（最高门槛）」+判据句「先问是补充还是替代」各 ≥1
- AD-03 条文内禁硬编码行号锚（`:\d+` 引用形态=FAIL）
- AD-04 SKILL.md 接线锚 ≥5：全集行 1-74 / Critical Rules 索引段 1-74 / References 表 1-74 / 用户新指令处理段含「Rule 74」/ 合规清单 C51 行
- AD-05 触点锚：critical-rules.md 的 Rule 8.1 段、36.5 段、56 段 grep「Rule 74」新增命中 ≥3；SKILL.md B 类行含「Rule 74」；B/C 类新段含「可行性判别门」
- AD-06 templates/task_plan.md 含「📋 变更标注表」且六列关键词齐备（编号/对象/类型/增量或替代/依据/执行动作）+四类型串「新增·修改·删除·更新」
- AD-07 templates/subagent_dispatch.md 含「定稿可行性判别模式」+三维关键词（可执行性/相容性/风险性）+三态串（PASS-WITH-RISKS）
- AD-08 74.4 分工与豁免锚在位：「69.1」引用+「mini 档」豁免措辞各 ≥1
- AD-09 registry.tsv 含 selftest-absorption-discipline.sh 登记行（脚本名+守护面描述串）
- AD-10 config.json 零新键（grep「absorption」键名=0）
- AD-11 SKILL.md『1-71』字面残留=0（全集行/索引段/References 表三处已演进）
- AD-12 pinning selftest 脚本『1-71』字面=0 或宽容形态覆盖（执行期按 S0 取证的实际清单逐个断言；预期七处：self-resolution/lane-advancement/requirement-coverage/source-anchor SA-07/context-pressure/workflow-orchestration/research-first）
- AD-13 自举消费：plans/task-v162-change-absorption-safety/task_plan.md 变更标注表含 ≥10 行 CA-n 条目
- AD-14 脚本自身 chmod+x 且 `bash -n` 语法通过（自跑 exit 0）

## Current Phase
Phase 8（全部 complete）

## Next Step
任务完成（outcome=COMPLETE）。下一步=用户授权后部署同步（CA-14 deferred）。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini) | 跨多文件读取+归因，「读得多要得少」，隔离上下文防主上下文污染 |
| Phase 2-3 | Agent 子代理 executor(sonnet-1) | 条文/触点写入为明确步骤清单+材料包，批量两文件 |
| Phase 4 | Agent 子代理 code-assistant(haiku-1) | 模板双文件小改，材料包逐字采用 |
| Phase 5 | Agent 子代理 executor(sonnet-1) | 新脚本+登记两 S-unit，范式明确 |
| Phase 6 | Agent 子代理 code-runner-agent(mini) | 全量跑批长耗时，隔离执行 |
| Phase 6(修复) | Agent 子代理 executor(sonnet-1) | 级联清账按 FAIL 清单逐项修，单次 ≤2 文件 |
| Phase 7 | Agent 子代理 general-purpose(sonnet-1)+code-reviewer(sonnet-1)+alignment(general-purpose) | 74.4 隔离可行性判别+Rule 42 双审查 |
| Phase 8 | 主进程（例外理由:① git/worktree 编排+② 计划系统簿记——Rule 25.3 白名单） | 合并回+账本+交付 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（规则增强 sequential pipeline；Phase 7 三审查输入同为最终 diff 且存在串行因果——FAIL 需回炉，Rule 21.4 独立性四问=输入相关→串行；未声明 parallel_groups 默认串行）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源

## Phases

### Phase 1: 调研审计与归因
- [x] 吸收现状审计（SKILL:238-262 新指令处理段全文+Rule 8.1/36.5/51.1/56/69.1/71 原文+11 pinning selftest 锚逐处 grep 校准）
- [x] 三对标判例取证（v149/v155 并集解+v131 锚级联判例+36.5/v079 保守化先例）
- [x] 5 Whys 归因（根因=吸收入口无三判门控+无机器门守护，B 类扩展语义未区分追加/替代）
- [x] 结论落盘 findings.md §吸收现状审计（pinning 清单精确到 file:line，11 处）
- **V-N:** VC-1, VC-2（现状=条文缺失根因）
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S0 | 吸收机制现状审计+三对标取证+5 Whys 归因，pinning 清单精确到 file:line 落盘 findings.md | explore(mini) | skills/task-planner/SKILL.md（§用户新指令处理:238-262+§Critical Rules:294+References:382） | findings.md §吸收现状审计含 5 Whys 表+pinning 七处 file:line 清单+三判例引用 | 15min | 0f/0l/15min | 无 | - | pending |

### Phase 2: Rule 74 条文与 SKILL 主索引
- [x] critical-rules.md 追加 Rule 74 条文（§74.1-74.6，S1 grep=6 PASS，diff 字节级逐字）
- [x] SKILL.md 主索引接线七处（S2 grep "Rule 74"=7 PASS / 1-74=3 / C51=1 / 1-71 残留=0；含 T4 新指令处理段）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | Rule 74 条文写入 critical-rules.md（Rule 71 段之后 EOF 追加，不硬编码行号锚） | executor(sonnet-1) | skills/task-planner/references/critical-rules.md + plans/task-v162-change-absorption-safety/task_plan.md（§条文草案逐字采用） | `grep -cE "^74\.[1-6] " critical-rules.md` ≥6 且标题行在位 | 15min | 1f/70l/15min | 无 | S0 | pending |
| S2 | SKILL.md 接线七处（全集行 1-74+枚举补 71/74/索引段+References 表+新指令段三判门段+B 类行括注+C51+终验段半句） | executor(sonnet-1) | skills/task-planner/SKILL.md + plans/task-v162-change-absorption-safety/task_plan.md（§接线材料包逐字采用） | grep "Rule 74" SKILL.md ≥7 命中且『1-74』≥2 且 C51 行在位 | 15min | 1f/45l/15min | 无 | S1 | pending |

### Phase 3: 触点接线（规则引用面）
- [x] Rule 8.1 段末+Rule 36.5 段末+Rule 56.1 末三处补 Rule 74 引用（T1-T3，S3 grep=3 PASS，纯行尾追加）
- [x] SKILL.md B 类行追加括注（T5，S4 PASS；T4 已由 S2 落地，grep=1 去重确认）
- **V-N:** VC-3, VC-2
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S3 | critical-rules.md Rule 8.1 段末+36.5 段末+56.1 末三处追加 Rule 74 引用句/括注（T1-T3，旧文逐字不动） | code-assistant(haiku-1) | skills/task-planner/references/critical-rules.md + plans/task-v162-change-absorption-safety/task_plan.md（§触点材料包 T1-T3） | 三段 grep "Rule 74" 新增 ≥3 命中且旧文 diff=追加形态 | 10min | 1f/9l/10min | 无 | S2 | pending |
| S4 | SKILL.md B 类行追加括注（T5，追加形态；T4 已由 S2 落地，执行前先 grep "变更吸收三判门（Rule 74" SKILL.md 去重，已存在则仅补 T5） | code-assistant(haiku-1) | skills/task-planner/SKILL.md + plans/task-v162-change-absorption-safety/task_plan.md（§触点材料包 T5） | B 类行含「Rule 74」且 T4 不重复（grep 计数不变） | 10min | 1f/4l/10min | 无 | S3 | pending |

### Phase 4: 模板层（变更标注表+可行性判别契约）
- [x] templates/task_plan.md 新增「📋 变更标注表」区块（T6，S5 三项 grep PASS，置于执行范围限制之后 :137-145）
- [x] templates/subagent_dispatch.md 新增「定稿可行性判别模式」契约段（T7，S6 三项 grep PASS，EOF 追加）
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | templates/task_plan.md「执行范围限制」区块后新增「📋 变更标注表」区块（T6，六列表头+填写规则） | code-assistant(haiku-1) | skills/task-planner/templates/task_plan.md + plans/task-v162-change-absorption-safety/task_plan.md（§模板材料包 T6） | grep "📋 变更标注表"=1 且六列关键词齐备 | 10min | 1f/12l/10min | 无 | S2 | pending |
| S6 | templates/subagent_dispatch.md 尾部新增「定稿可行性判别模式」契约段（T7，三维+三态+落盘） | code-assistant(haiku-1) | skills/task-planner/templates/subagent_dispatch.md + plans/task-v162-change-absorption-safety/task_plan.md（§模板材料包 T7） | grep "定稿可行性判别模式"=1 且三维/三态关键词齐备 | 10min | 1f/10l/10min | 无 | S2 | pending |

### Phase 5: 机器守护
- [x] 新建 selftest-absorption-discipline.sh（S7 上半 AD-01..07 + S8 下半 AD-08..14，自跑 14 pass/0 fail exit 0）
- [x] registry.tsv 登记新脚本行（4 列制表符对齐）
- **V-N:** VC-6, VC-2
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S7 | 新建 scripts/selftest-absorption-discipline.sh 上半（AD-01..07：74.x 条款锚+三档关键词+接线锚≥5+触点锚+模板双锚；范式=selftest-source-anchor-discipline.sh） | executor(sonnet-1) | skills/task-planner/scripts/selftest-source-anchor-discipline.sh + plans/task-v162-change-absorption-safety/task_plan.md（§守护断言清单） | 脚本存在且 bash -n 语法通过 | 15min | 1f/95l/15min | 无 | S3 | pending |
| S8 | 追加上半（AD-08..14：分工豁免锚+registry 登记+零新键+级联 pin+自举消费）+registry.tsv 登记行+chmod+x+自跑 exit 0 | executor(sonnet-1) | skills/task-planner/scripts/selftest-absorption-discipline.sh + plans/task-v162-change-absorption-safety/task_plan.md | 自跑 exit 0 且 registry.tsv 含登记行 | 10min | 1f/85l/10min | 无 | S7 | pending |

### Phase 6: 全量回归与级联清账
- [x] worktree 内全量 selftest 跑批（S9：72 脚本，62 PASS/10 FAIL，ΣFAIL=12——FMEA RPN=126 预期命中）
- [x] FAIL 清单级联修复→重跑至 ΣFAIL=0（S10：10 文件/12 断言全修复，ΣPASS=1094，72 rc=0）
- **V-N:** VC-4, VC-3
- **Status:** complete
- **Executor:** code-runner-agent（mini）+executor（sonnet-1，条件修复）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | worktree 内全量 selftest 跑批（for f in scripts/selftest-*.sh）+FAIL 清单落盘 subagent-state 检查点 | code-runner-agent(mini) | skills/task-planner/scripts/selftest-*.sh（跑批，禁逐文件罗列） | 输出含每脚本 PASS/FAIL 与 ΣFAIL 计数 | 15min | 0f/0l/15min | 无 | S8 | pending |
| S10 | （条件：ΣFAIL>0）按 FAIL 清单修锚级联（单次派发 ≤2 文件，超限再拆多轮）→重跑至 ΣFAIL=0 | executor(sonnet-1) | plans/task-v162-change-absorption-safety/subagent-state/（S9 检查点 FAIL 清单执行期回填路径） | 重跑 ΣFAIL=0 且级联 pin 全清 | 15min | 2f/40l/15min | 无 | S9 | pending |

### Phase 7: 定稿可行性判别门实战+双审查（Rule 74.4 dogfood + Rule 42）
- [x] S11 可行性判别门：PASS-WITH-RISKS（R1-R4 登记+缓解后放行；本计划自身即首批 consumer）
- [x] S12 code-reviewer=APPROVED（2 Suggestion）+S13 alignment-review=CHANGES_REQUESTED（P1×2+P2×6）
- [x] S14 修复档：CHANGES 10 条全数修复，复验 ΣFAIL=0，AD-01..14 全 PASS
- **V-N:** VC-7, VC-4
- **Status:** complete
- **Executor:** general-purpose（sonnet-1）+code-reviewer（sonnet-1）+general-purpose（alignment-review）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S11 | 74.4 可行性判别门实战：隔离子代理对本定稿方案（计划+worktree 全 diff+涉及规则模板原文完整传入）判可执行性/相容性/风险性，三态结论落盘 | general-purpose(sonnet-1) | plans/task-v162-change-absorption-safety/task_plan.md（计划全文）+ worktree git diff（执行期收集） | checkpoint 落 verdict 行（PASS/PASS-WITH-RISKS/FAIL）+findings.md 落点 | 15min | 0f/0l/15min | 无 | S10 | pending |
| S12 | 代码面审查：worktree 内 git diff 的 .sh 改动（selftest 新脚本），输出 APPROVED/CHANGES_REQUESTED+逐条 file:line | code-reviewer(sonnet-1) | skills/task-planner/scripts/selftest-absorption-discipline.sh（worktree 版，执行期给 git diff 基线） | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | S11 | pending |
| S13 | 对齐面审查：按 review-library/alignment-review/SKILL.md 对全部 .md 改动跑对齐审查，输出 verdict+问题清单 | general-purpose(sonnet-1) | skills/task-planner/review-library/alignment-review/SKILL.md + worktree git diff（.md 集合） | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | S12 | pending |
| S14 | （条件：CHANGES_REQUESTED）逐条修复（单次派发 ≤2 文件，超限多轮）→复验→两 verdict 翻 APPROVED | executor(sonnet-1) | plans/task-v162-change-absorption-safety/subagent-state/（两 checkpoint CHANGES 清单执行期回填路径） | 复跑两审查 verdict=APPROVED | 15min | 2f/80l/15min | 无 | S12,S13 | pending |

### Phase 8: 合并回+部署评估+终验簿记交付
- [x] smart-merge-back.sh（11 冲突并集解→MERGED d45e8e2；master 74 脚本 ΣFAIL=0）
- [x] rule-reserve land 74 + verification.md VC 逐条复验 + 需求覆盖核对表（R→VC 映射表全勾）
- [x] 部署位对账评估（CA-14 deferred；v158 遗留债务登记；部署待用户显式授权）
- [x] delivery-summary（Rule 48/70/74 金标准，outcome=COMPLETE）
- **V-N:** VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排+② 计划系统簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①未提交变更=并行任务 plans/ 目录（v156/v160/v163）非本任务范围；信号②活跃 worktree×2=v160/v161 在途；信号③无遗留 wt/* 分支（v161 已合并在 master）；信号④⑤无。本任务 scope 与并行任务在 critical-rules.md EOF/SKILL.md 尾段/合规清单尾行存在可预期合并冲突，按 v149/v155 并集解判例处置） |
| `isolation` | `worktree`（修改运行中基础设施，§十一 P0） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/v162-change-absorption-safety`（§11.2 集中目录） |
| `branch` | `wt/v162-change-absorption-safety` |
| `merge_back` | `pending` |

> 创建后先 diff 关键文件与 master 一致性（worktree-branch-desync 判例）；子代理派发 prompt 必带 worktree 绝对路径+「禁止触碰其他 worktree 内容」约束（§11.4）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2-6 | 新增行撞既有 selftest 定数/范围断言（1-71→1-74 级联，历史 5+ 判例） | 7 | 6 | 3 | 126 | 兜底=Phase 6 全量回归必然暴露（D 层探测）+S10 修复档（22.3④ executor 修，口径扩展非回退范式 v117 判例） |
| Phase 8 | 与并行 v160/v161/v163 在 critical-rules.md/SKILL.md EOF/合规清单尾行合并冲突 | 6 | 7 | 2 | 84 | v149/v155 并集解判例：逐 hunk 并集保三方条文+重跑全量回归；禁 rebase 强推 |
| Phase 1 | Explore 扫不全 pinning 脚本（漏网→Phase 6 才发现） | 6 | 4 | 4 | 96 | S0 验收=pinning 清单逐个 grep 复核；Phase 6 跑批兜底 |
| Phase 4 | task_plan.md 模板加区块撞 check-template-type/check-plan-dispatch 结构断言 | 6 | 5 | 3 | 90 | Phase 6 回归暴露后口径扩展修锚（v117 范式） |
| Phase 7 | 可行性/审查子代理 provider 失败或返回空 | 5 | 4 | 3 | 60 | 22.3 链：改派 general-purpose→主进程接管+登记 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-10 | 计划创建时 S1 建映射（本会话 TodoWrite 8 项） |
| Phase 2 | ☑ | 2026-10-10 | 同上 |
| Phase 3 | ☑ | 2026-10-10 | 同上 |
| Phase 4 | ☑ | 2026-10-10 | 同上 |
| Phase 5 | ☑ | 2026-10-10 | 同上 |
| Phase 6 | ☑ | 2026-10-10 | 同上 |
| Phase 7 | ☑ | 2026-10-10 | 同上 |
| Phase 8 | ☑ | 2026-10-10 | 同上 |

## Key Questions
1. 当前技能在哪些触点吸收用户指令？吸收语义默认值是什么？（S0 答：D/A/B/C 四分类——无三判门，默认=整段重写）
2. 三判门的机器守护做到哪一层？（答：模板自检（74.3b）+selftest-absorption-discipline.sh 静态守护+变更标注内容人工核查，零新 config 键）
3. 可行性判别门如何避免与 Rule 69.1 T1 重叠？（答：分工——T1 判多候选孰优，本门判单方案能否安全落地，74.4(e)）
4. SKILL『1-71』级联 pin 的完整清单与各自宽容形态？（S0 逐处 grep 校准；预期七处：self-resolution/lane-advancement/requirement-coverage/source-anchor SA-07/context-pressure/workflow-orchestration/research-first）
5. 并行任务 v160(72)/v156(73) 落地后，本任务合并回时其条文如何保全？（答：并集解——三方条文逐 hunk 保真+重跑全量回归）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Rule 编号取 74（非 72/73） | Rule 20.6 账本核实：72=v160 在途预留、73=v156 在途预留；查重后取 74（task-v128 编号预留制） |
| interaction_mode: silent | 用户 R1-R3 需求明确、无高歧义决策点；设计为需求直接落地；关键静默决策按 Rule 28 登记（部署授权 deferred 待用户） |
| 可行性判别不强求大模型 | 用户原话「不一定是需要很大模型…只需要单独子代理」；档位按 Rule 43.2 min 档，质量由三维判据保障 |
| 可行性门与 69.1 T1 分工 | T1 判多候选孰优；本门判单方案安全落地；互补不重复（74.4(e)） |
| 部署不回写 | §六 保护区+v158 遗留债务（部署位 1-69+70 vs 主仓 1-71 diff 26 面）；部署需用户显式授权；Phase 8 仅合并回 master+登记 deferred |
| 变更标注表作为本计划验收清单兼任 | 74.3(c)：本任务引入的规则自己先消费（自举验证，≥10 行 CA-n） |
| 级联 pin 宽容形态处理 | source-anchor SA-07『1-71』grep≥2 保留为 ≥2（1-74 命中同形态）；其余按 S0 取证逐个演进（禁一刀切替换） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| cbab959f side 指针被 v153 声称（保护脚本拒写） | 1 | 核实 v153 已 COMPLETE（INDEX.md 5/5）+sidmap 确认属本会话命名空间→`--force` 覆写成功 | 覆写前先查任务终态+命名空间归属（active-plan-pointer-race 判例） |
| UserPromptSubmit hook 注入 v152 旧计划数据 | 1 | 哨兵 sidkey d19337ab 无 side 指针回落全局→`set-active-plan set --sid d19337ab` 指向 v162 | 三 sidkey 逐一 set（de2c5bba/cbab959f/d19337ab） |
| config.json 路径误判（仓根） | 1 | 实际位于 ~/.zcode/skills/task-planner/config.json；值 None→默认 ask/0.7/warn | 配置读取先定位真实路径 |
| Rule 编号误取 72（初案） | 1 | 账本核实 72/73 已被 v160/v156 预留→改取 74 | 新 Rule 任务第一步 check/reserve（Rule 20.6） |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repeating the same mistakes
- Never repeat a failed action - mutate your approach instead
- 本计划变更标注表（CA-1..CA-14）兼任 Phase 8 验收清单：逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL（74.3(c)）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a（不符合 18.1 批量识别条件：条文/触点/模板改动为逐处独立内容，非同质批量单元） |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a（Rule 18 前置 3 问不适用：无同质批量单元） |
| `rollback_point` | n/a（本任务回滚方式=`cd /mnt/data/dev/task-planner-skill && git revert <merge-commit>`，见 verification.md 风险点） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 8 |
| 主进程直做 Phase 清单 | （Phase 8；例外理由:① git/worktree 编排+② 计划系统簿记——Rule 25.3 白名单） |
| 委派率 | （终验前必填；< delegation_rate_floor 默认 0.7 或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-10 11:05 | explore(mini) | S0 吸收现状审计+归因 | done | 触点 13 处+通道 4 条+pinning 11 处+判例 B1-B3+5 Whys 根因 | findings.md §吸收现状审计 | plans/task-v162-change-absorption-safety/subagent-state/01-explore.md | - / 0 / ☑ |
| 2 | 2026-10-10 11:20 | executor(sonnet-1) | S1 Rule 74 条文写入 | done | 条文逐字追加 EOF，grep=6 PASS，diff 字节级 IDENTICAL | findings.md §吸收现状审计（条文锚 critical-rules.md:944-951） | plans/task-v162-change-absorption-safety/subagent-state/02-executor.md | - / 0 / ☑ |
| 3 | 2026-10-10 11:30 | executor(sonnet-1) | S2 SKILL.md 接线 | done | 七处接线全 PASS（Rule 74=7/1-74=3/C51=1/1-71 残留=0）；发现 T4 去重提示已并入 S4 | findings.md §吸收现状审计（接线锚 SKILL.md:9,173,234,264,299,360,386） | plans/task-v162-change-absorption-safety/subagent-state/03-executor.md | - / 0 / ☑ |
| 4 | 2026-10-10 11:40 | code-assistant(haiku-1) | S3 触点三处接线 | done | T1/T2/T3 三处行尾追加，grep "Rule 74"=3 PASS，宿主旧文 0 改动 | findings.md §吸收现状审计（触点锚 critical-rules.md:29,374,644） | plans/task-v162-change-absorption-safety/subagent-state/04-code-assistant.md | - / 0 / ☑ |
| 5 | 2026-10-10 11:45 | code-assistant(haiku-1) | S4 SKILL B 类行括注 | done | B 类行 L248 含 Rule 74 PASS；T4 grep=1 去重确认 | findings.md §吸收现状审计（B 类行锚 SKILL.md:248） | plans/task-v162-change-absorption-safety/subagent-state/05-code-assistant.md | - / 0 / ☑ |
| 6 | 2026-10-10 11:55 | code-assistant(haiku-1) | S5 task_plan 变更标注表 | done | T6 区块三项 grep PASS，旧区块逐字保留 | findings.md §吸收现状审计（模板锚 templates/task_plan.md:137-145） | plans/task-v162-change-absorption-safety/subagent-state/06-code-assistant.md | - / 0 / ☑ |
| 7 | 2026-10-10 12:00 | code-assistant(haiku-1) | S6 dispatch 可行性契约 | done | T7 契约段三项 grep PASS，EOF +3 行追加形态 | findings.md §吸收现状审计（契约锚 templates/subagent_dispatch.md:94-96） | plans/task-v162-change-absorption-safety/subagent-state/07-code-assistant.md | - / 0 / ☑ |
| 8 | 2026-10-10 12:15 | executor(sonnet-1) | S7/S8 selftest 脚本+登记 | done | AD-01..14 自跑 14 pass/0 fail exit 0；registry 登记行在位；AD-12 偏差（已知形态联合断言）诚实登记待 S10 收紧 | findings.md §吸收现状审计（守护锚 scripts/selftest-absorption-discipline.sh） | plans/task-v162-change-absorption-safety/subagent-state/08-executor.md | - / 0 / ☑ |
| 9 | 2026-10-10 12:25 | code-runner-agent(mini) | S9 全量跑批 | done | 72 脚本 62P/10F ΣFAIL=12（FMEA RPN=126 预期命中） | findings.md §吸收现状审计（FAIL 清单） | plans/task-v162-change-absorption-safety/subagent-state/09-code-runner.md | - / 0 / ☑ |
| 10 | 2026-10-10 12:35 | executor(sonnet-1) | S10 级联清账修复 | done | 10 文件/12 断言全修复，ΣFAIL=0 ΣPASS=1094 | findings.md §吸收现状审计（修复对照） | plans/task-v162-change-absorption-safety/subagent-state/10-executor.md | - / 0 / ☑ |
| 11 | 2026-10-10 12:55 | general-purpose(sonnet-1) | S11 可行性判别门 | done | PASS-WITH-RISKS（R1-R4 登记+缓解） | findings.md §S11 | plans/task-v162-change-absorption-safety/subagent-state/11-feasibility.md | - / 0 / ☑ |
| 12 | 2026-10-10 13:00 | code-reviewer(sonnet-1) | S12 代码面审查 | done | APPROVED（2 Suggestion） | findings.md §吸收现状审查（代码面） | plans/task-v162-change-absorption-safety/subagent-state/12-code-reviewer.md | - / 0 / ☑ |
| 13 | 2026-10-10 13:05 | general-purpose(sonnet-1) | S13 对齐面审查 | done | CHANGES_REQUESTED（P1×2+P2×6） | findings.md §吸收现状审查（对齐面） | plans/task-v162-change-absorption-safety/subagent-state/13-alignment.md | - / 0 / ☑ |
| 14 | 2026-10-10 13:10 | executor(sonnet-1) | S14 CHANGES 修复档 | done | 10 条全修复，ΣFAIL=0，AD-01..14 全 PASS | findings.md §吸收现状审查（修复档） | plans/task-v162-change-absorption-safety/subagent-state/14-executor.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
n/a（单 skill 任务——rule-enhancement 全流程在 task-planner 内闭环，无多 skill 接力）
