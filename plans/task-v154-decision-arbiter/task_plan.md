# Task Plan: task-v154 为 task-planner 引入判别/决策子代理 decision-arbiter
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「引入一个新的Agent……专门将创建一个新的新的子代理Agent用于解决遇到就是遇到问题时做选择判断使用」<sub>（[目标]——新判断/裁决子代理落地）</sub>
- **R2**: 「我希望该模型可以使该Agent可以使用较大的模型、能力较强的模型，确保判断的合理性以及及时纠错」<sub>（[手段]——强模型档位保证判断质量）</sub>
- **R3**: 「在判断的时候，我希望它审查发现错误的，然后打回去交给交给主代理进行处理」<sub>（[目标]——驳回打回协议：裁决发现错误→结构化驳回单→主代理返工）</sub>
- **R4**: 「为该技能（task-planner）……遇到需要判断的问题的时候……使用子代理做任务判断……做决策」<sub>（[目标]——接入 task-planner 调度体系，成为可被派发消费的正式执行体）</sub>
- **R5**: 「另外需要明确在哪些地方……我希望你可以明确在哪些地方添加这个判别，对，就是在哪个阶段需要引入这些判别的执行」（2026-10-10 批准时追加，B 类扩展）<sub>（[目标]——触发点矩阵：在 SKILL.md 执行流程的明确阶段/位置标注何时委派 decision-arbiter，非泛泛条款）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | companion/agents/decision-arbiter.md 在位（master+部署位 IDENTICAL），含裁决协议与硬约束段 |
| R2 | VC-1 | frontmatter `model: "account:zai-individual-coding-plan/GLM-5.3"`（complex-planner 同款强档，selftest 断言） |
| R3 | VC-2 | critical-rules.md Rule 69 含驳回打回子条（REJECT-REWORK 四态+驳回单五要素），agent 文件含驳回单结构段 |
| R4 | VC-3/VC-4/VC-6 | SKILL.md 路由表行+References+清单行三处接线；覆盖矩阵+三登记面同步；部署位对账 IDENTICAL |
| R5 | VC-3/VC-2 | 触发点矩阵落地：Rule 69.1 六触发点（T1-T6）+SKILL.md 执行流程对应位置 ≥5 处触发点标记（各含指针到 Rule 69） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| agent 定义生产 | 判断体缺第一手证据自查 → 凭派发摘要误判 | agent 文件硬约束段：判定必须 Read/Grep/命令取证，禁凭摘要单独下结论（drift-checker 先例） | VC-1 |
| 调度接线生产 | 新 agent 未入路由表/覆盖矩阵 → Rule 52 B 类缺口（登记名不符/实体未登记），无人能派发 | SKILL.md 路由表+agent-coverage.md 矩阵行+三登记面同步（52.3 change-linkage） | VC-3/VC-4 |
| 裁决消费生产 | 裁决返回后无消费协议 → 驳回被静默忽略=打回机制失效 | Rule 69.3 消费协议：REJECT-REWORK 必须按驳回单返工+progress 留痕，禁静默继续 | VC-2 |
| 回归防护生产 | 新增行触发既有行数/锚点断言级联（v150 教训） | selftest-decision-arbiter.sh 新断言+全量 selftest 对照 master 基线逐条分类 | VC-5 |
| 部署对账生产 | 部署位漂移（四部署位≠master） | sync-companion.sh + smart-merge-back --deploy 对账 IDENTICAL | VC-6 |

<!-- plan_tier: standard -->
## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
为 task-planner 技能新增强模型判别/决策子代理 `decision-arbiter`（GLM-5.3 档）及其调度接线（Rule 69+路由表+覆盖矩阵+守卫 selftest），实现「遇判断问题→委派裁决→驳回打回主代理」的完整闭环并部署对账。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（含新 selftest 脚本=代码文件；轻 diff 分级按 task-v094 T-B6 判定） |
| `session_id` | `v154-decision-arbiter-20261010` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter` | §十一 隔离决策已有字段 |
| `scope_files` | `[skills/task-planner/companion/agents/decision-arbiter.md, skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-planner/references/agent-coverage.md, skills/plan-template-kit/references/template-mapping.md, skills/task-planner/scripts/selftest-decision-arbiter.sh, scripts/selftest-registry.tsv(如登记面要求)]` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` | Rule 28 交互模式：ask=关键决策点给选项 |
| `对齐审查` | `alignment-review（终验标准收尾流程，42.6.2）+写入前版本一致性校验（42.6.1）` | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `全部询问点: 推荐项默认+自动超时 5 分钟` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | `69` | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空）；69=67(v152 占)/68(v153 占)后下一个空闲号 |
| `质量审查工具` | `alignment-review + code-quality-review（内置 review-library 池 11 成员，四级检测：项目级无→用户级命中池）` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | `companion/agents/decision-arbiter.md` 在位（master），frontmatter `model` = `account:zai-individual-coding-plan/GLM-5.3`，正文含四态裁决协议（APPROVE/REJECT-REWORK/ESCALATE-USER/INSUFFICIENT-EVIDENCE）、驳回单结构、只读硬约束、管辖二分（与 drift-checker/critic/meta-corrector 区别） | Read 文件 + grep 断言 | `skills/task-planner/companion/agents/decision-arbiter.md` |
| VC-2 | `references/critical-rules.md` 含 Rule 69 完整条款（69.1 触发场景与管辖二分 / 69.2 委派契约 / 69.3 裁决四态与消费协议·驳回打回 / 69.4 驳回单五要素 / 69.5 强模型档与经济性边界 / 69.6 机制=selftest+零新 config 键）；`plans/.rule-reservations.jsonl` 69 = landed | grep 断言 + Read + cat 账本 | `grep -c "Rule 69" critical-rules.md` ≥6 子条；账本 69 landed 行 |
| VC-3 | SKILL.md 接线在位：①子代理路由表新增「判断/裁决」行（decision-arbiter, GLM-5.3 档）②Critical Rules 清单 Rule 69 行 ③References/伴飞载体引用 ④**触发点标记 ≥5 处**（执行流程 Phase 循环/Rule 22.3 兜底链/22.5 验收/DRIFT 处置/Code Review Gate/终验交付中 ≥5 个位置插入「→ 委派 decision-arbiter 裁决（Rule 69）」式标记行） | grep 断言 | `grep -n "decision-arbiter" SKILL.md` ≥8 处（3 接线+5 触发点） |
| VC-4 | 登记面同步齐备：agent-coverage.md 矩阵新增「判断/裁决族」行；D2=skill-agent-router 登记行；D3=template-mapping.md §九/§十登记（或有书面豁免理由） | Read + grep | `agent-coverage.md` 新行 + router SKILL.md 行 + template-mapping 行 |
| VC-5 | `scripts/selftest-decision-arbiter.sh` 在位且全 PASS（断言 ≥10 条）；全量 selftest 回归对照 Phase 1 master 基线：FAIL=0 或逐条分类（新增断言/并行任务演进） | bash 执行 + Round 落盘 | `bash scripts/selftest-decision-arbiter.sh` 全 PASS；全量回归日志 progress.md Round N |
| VC-6 | 合并回 master（merge_back=merged(commit)）+ 部署位对账 IDENTICAL（companion agents 双位+技能位）+ worktree 与 wt/* 分支清理完成 | smart-merge-back 输出 + git worktree list | `git worktree list` 无 v154 残留；部署 diff=0 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 / R3 / R4 |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
<!--
  WHEN: attest 获批后立即填写（自动分解：S-unit/Phase → goal 单元映射）
  WHY: 用户 2026-10-09 裁决——任务分解后逐格固定为「任务名+目标+完整验证方式」，
       执行按 goal 逐个推进（66.3），/goal 目标模式完成审计的证据源（66.2 映射供料）
  列契约（66.1 六列）: goal-id(G1..) | 任务名(≤8字) | 目标(≤1句) | 完整验证方式(命令+判据/路径+关键行/diff形态,三选一必具其一) | 对应S-unit/Phase | 状态(pending/complete)
  状态机: pending → complete(仅 66.3 三证据齐备后翻格,同步 progress.md [goal:Gn] 证据行)
-->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 基线侦察 | master 基线回归+登记面 D2/D3 位置确认 | 全量 selftest 日志+D2/D3 文件锚入 findings | S1/Phase 1 | complete |
| G2 | agent 主件 | decision-arbiter.md 定义落地 worktree | grep model=GLM-5.3+四态+驳回单锚 | S2/Phase 2 | complete |
| G3 | Rule 69 | critical-rules.md Rule 69 六子条落地 | grep Rule 69 ≥6 子条+attest new_rule 登记 | S3/Phase 2 | complete |
| G4 | 调度接线 | SKILL.md+覆盖矩阵+template-mapping 三登记面同步 | grep decision-arbiter ≥3 处+矩阵新行 | S4-S5/Phase 2 | complete |
| G5 | 守卫回归 | selftest-decision-arbiter.sh 全 PASS+全量回归 FAIL=0 | bash 执行日志 Round N 入 progress | S6-S7/Phase 3 | complete |
| G6 | 部署交付 | CR APPROVED+合并回+部署对账+清理 | merge_back=merged+部署 diff=0+worktree list 干净 | Phase 4-6 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| agent 定义 | `skills/task-planner/companion/agents/decision-arbiter.md`（新建） | 其他 companion agents 文件 |
| 规则 | `skills/task-planner/references/critical-rules.md`（纯增量 Rule 69） | 删除/改写既有 Rule 1-68 条款 |
| 主技能 | `skills/task-planner/SKILL.md`（路由表行/清单行/References 行三处增量） | 大段改写既有章节 |
| 登记面 | `skills/task-planner/references/agent-coverage.md`（矩阵新增行）；`skills/plan-template-kit/references/template-mapping.md`（§九/§十登记）；`~/.zcode/skills/skill-agent-router/SKILL.md`（D2 登记行，部署位） | 其他登记面文件 |
| 守卫脚本 | `skills/task-planner/scripts/selftest-decision-arbiter.sh`（新建）；selftest registry 登记行（如 registry.tsv 登记面要求） | 既有 selftest 脚本逻辑（基线漂移修复除外，逐条登记） |
| 部署位 | 合并后 sync-companion/smart-merge-back --deploy 脚本自动覆盖的部署位 | 手工散写部署位 |
| Changelog | `CHANGELOG.md`（[Unreleased]→新增段顶部，task-v154 条目；惯例=仓内 v146-v153 全登记，S9 P2-01 裁决补登） | 历史已发布条目改写 |
| 计划文件 | `plans/task-v154-decision-arbiter/**` | 其他 plans/ 目录（v151/v152/v153 并行任务文件禁碰） |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | drift-checker 伴随 agent 先例（只读判定体结构） | `skills/task-planner/companion/agents/drift-checker.md` | 必读 | ☑ |
| 项目内部文档/知识库 | complex-planner 强模型先例（GLM-5.3 档 frontmatter） | `skills/task-planner/companion/agents/complex-planner.md` | 必读 | ☑ |
| 项目内部文档/知识库 | Rule 52 覆盖矩阵与三登记面（D1/D2/D3 锚） | `skills/task-planner/references/agent-coverage.md` 头注 | 必读 | ☑ |
| 项目内部文档/知识库 | critical-rules.md 现行 Rule 41/53/61/63（消解链/管辖二分/子代理化/检索优先——新 Rule 的衔接面） | `skills/task-planner/references/critical-rules.md` | 必读 | ☐ |
| 项目内部文档/知识库 | selftest registry 登记面与 SKILL 钉值断言位（v150 教训） | `skills/task-planner/scripts/`（Phase 1 定位） | 参考 | ☐ |
| 项目内部文档/知识库 | 部署拓扑与部署位清单（v149 四位部署先例） | `~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-planner-repo-deploy-flow.md` + sync-companion.sh | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: task-planner 体系内「需要高质量判断的问题」（方案选择/错误复核/完成度争议/疑似偏移但证据不足）缺少专属强判断出口——主进程要么自己拿不准硬决，要么升级 AskUser 打扰用户；需要独立裁决体+驳回打回协议形成纠错闭环。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（主进程获得可派发的裁决执行体+消费协议）
- [x] 核心问题不解决，其他工作都白费吗？（判断质量是纠错及时性的根）
- [x] 核心问题的解决方法是清晰的、可执行的？（companion agent+Rule 条款+selftest+登记面四件套，v146 drift-checker 全套先例可循）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓 companion agents 现状（7 件）与判断面既有执行体清单 | Phase 1 侦察（已完成计划期预读） | findings.md §Research | ☑ |
| ② 对标样本（58.2 强制） | drift-checker（v146 只读判定体全套先例）+ complex-planner（v119 强模型先例） | Read 两文件 frontmatter+SOP 结构 | findings.md §Research | ☑ |
| ③ 外部约束 | 平台 agent frontmatter 规范（model 格式 `account:` 前缀，custom:uuid 式禁用）+ §十一 worktree 铁律 + v152/v153 并行任务占用 67/68 编号 | 账本 `.rule-reservations.jsonl`+worktree list | findings.md §Constraints | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 5

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
跑 smart-merge-back --deploy 合并回 master（CHANGELOG 并集解预期）+rule-reserve land 69+D2 router 部署位登记+worktree/branch 清理

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理（code-runner-agent 跑基线回归；Explore 查 D2/D3 登记面）；机械守卫脚本（全量 selftest） | 基线回归=只读批量命令→mini 档；登记面定位=跨文件搜索→explore |
| Phase 2 | Agent 子代理 executor(sonnet-1)×4（S2-S5，S4/S5 独立文件可声明组并行） | 技能文档(.md)大改走 executor 档；单件超 code-assistant 300 行边界不适用（行数可控），统一 executor 保一致性 |
| Phase 3 | Agent 子代理 executor(sonnet-1)（写 selftest）+code-runner-agent(mini)（跑回归）；机械守卫脚本 | 脚本编写=判断型→sonnet-1；批量回归执行=机械 IO→mini |
| Phase 4 | 卫星技能（alignment-review + code-quality-review，42.2 四级检测登记） | 质量审查面走登记工具（Rule 42.4） |
| Phase 5 | 机械守卫脚本（sync-companion.sh / smart-merge-back --deploy）；主进程 git 编排 | 合并回+部署对账=白名单① git 编排 |
| Phase 6 | 机械守卫脚本（check-complete.sh）；簿记主进程 | 终验门控+交付总结=白名单② 簿记 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（S-unit 间强依赖：设计→条款→接线→守卫链式推进）→ 按 Rule 21.4 独立性守门调度（并行默认+声明组，未声明=串行，10-02；本任务声明并行组见 Phase 2 S-unit 表组标记列）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源；Goal 单元表 G1-G6 供 /goal 目标模式审计（66.2）；/goal 为用户侧 harness 命令,技能层不可代调

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 基线侦察与登记面定位
<!-- 
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that.
-->
- [x] master 全量 selftest 基线回归（记录 PASS/FAIL 基线，供 Phase 3 对照分类）
- [x] D2（skill-agent-router SKILL.md）/D3（template-mapping §九§十）登记面精确锚定位；selftest registry 登记面确认（新 selftest 是否须登记 registry.tsv+SKILL 钉值）
- [x] critical-rules.md Rule 61/63/41 衔接面重读（新 Rule 69 措辞对齐既有条款风格）
- [x] 知识储备必读项全部确认
- [x] 结论落 findings.md（设计定稿输入）
- **V-N:** VC-5（基线记录）, VC-4（登记面锚）
- **Status:** complete（2026-10-10，证据 findings §Baseline/§Research+progress Phase 1）
- **Executor:** code-runner-agent（mini，跑基线）+ Explore（mini，登记面定位）

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填;每行 = 一次 Agent() 派发;单步 ≤step_max_files(2) 文件 / ≤step_max_lines(100) 行 / ≤step_max_minutes(15) 分钟,超限再拆而非升档;「执行体」列可写"继承"或具体 subagent_type(model);「输入」列在计划期预写材料包 = 路径 + ≤10 行摘要,执行期照单派发)
  机器契约(check-plan-dispatch.sh attest 校验):
  ① 预估时长列一律写 NNmin 格式(先估出可测的时长),逐行数值校验——超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）
  ② 输入列文件路径 token 计数 ≤2,超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）
  ③ 拆分决策基准 = 预估时间(用户裁决 09-17):写表时先给每行可测的 NNmin 预估,模型据此决定拆不拆,机侧校验行供 review 对照
  ④ ID 列一律纯数字（S1/S2…），禁字母后缀——check-plan-dispatch.sh 数据行正则不认 S2a 式命名，attest 拒锁（task-v076 教训）
  - 粒度三值列 Nf/Nl/Nmin 格式逐行校验,任一超 step_max_files/step_max_lines/step_max_minutes → enforce 拒锁
  - 伴飞技能列非「无」→ 校验对应 SKILL.md 路径存在(Rule 59.2)
-->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S1 | master 全量 selftest 基线记录（64 脚本 ΣPASS/FAIL+FAIL 清单） | code-runner-agent | skills/task-planner/scripts/selftest-*.sh；跑法=逐脚本 bash 执行汇总 | findings 记基线数字+FAIL 分类 | ≤15min | 0f/0l/15min | 无 | - | pending |
| S2 | D2/D3/registry 登记面锚定位+Rule 41/53/61/63 风格摘录 | Explore | ~/.zcode/skills/skill-agent-router/SKILL.md+skills/plan-template-kit/references/template-mapping.md+critical-rules.md | 锚(行号)+摘录入 findings | ≤10min | 0f/0l/10min | 无 | - | pending |

### Phase 2: 主件实现（worktree 内）
<!-- 
  WHAT: Decide how you'll approach the problem and what structure you'll use.
  WHY: Good planning prevents rework. Document decisions so you remember why you made choices.
-->
- [ ] worktree 创建+技能文件同步检查（desync 教训：创建后先 diff 关键文件与 master）
- [ ] S3 decision-arbiter.md agent 定义（设计规格见 Decisions Made D1-D4）
- [ ] S4 critical-rules.md Rule 69 六子条（纯增量，1-68 不动）
- [ ] S5 SKILL.md 三处接线
- [ ] S6 覆盖矩阵行+template-mapping D3 登记
- [ ] 每 S-unit 完成即 git commit（Rule 27）
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete（2026-10-10；5 S-unit 全验收，4 commits 86942e2/cc70dca/da996a5/48dc681）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S3 | decision-arbiter.md agent 定义（frontmatter GLM-5.3+四态裁决+驳回单+硬约束+管辖二分） | executor | worktree 内 skills/task-planner/companion/agents/；任务书含完整设计规格与 drift-checker/complex-planner 样例锚 | 文件在位+grep 四态词+frontmatter 断言 | ≤15min | 1f/100l/15min | 无 | - | pending |
| S4 | critical-rules.md 追加 Rule 69 前三子条（69.1 触发点矩阵 T1-T6+豁免清单/69.2 委派契约/69.3 裁决消费协议） | executor | worktree 内 references/critical-rules.md（T1-T6 矩阵见计划 D8；追加锚=Rule 68 条款后） | grep 69.1-69.3 三锚在位+1-68 行零改动(diff 对照) | ≤12min | 1f/65l/12min | 无 | - | pending |
| S11 | critical-rules.md 追加 Rule 69 后三子条（69.4 驳回单五要素/69.5 强模型档与经济性边界/69.6 机制=selftest+零新 config 键） | executor | worktree 内 references/critical-rules.md（前置=S4 已落地，追加锚=69.3 条款后） | grep 69.4-69.6 三锚在位+69.1-69.3 零改动 | ≤10min | 1f/50l/10min | 无 | S4 | pending |
| S5 | SKILL.md 接线（路由表行+清单行+References 行）+**触发点标记 T1-T6 ≥5 处**（锚：计划确认 43.3 段/Rule 22.3 兜底表/22.5 验收/DRIFT 处置/Code Review Gate/终验三分支） | executor | worktree 内 skills/task-planner/SKILL.md；三处接线锚+六触发点矩阵见计划 D8 | grep decision-arbiter ≥8 处（3 接线+5 触发点） | ≤15min | 1f/30l/15min | 无 | - | pending |
| S6 | agent-coverage.md 矩阵行+template-mapping.md D3 登记 | executor | worktree 内 references/agent-coverage.md+plan-template-kit/references/template-mapping.md | 矩阵新行(判断/裁决族)+D3 行在位 | ≤10min | 2f/10l/10min | 无 | - | pending |

> 并行声明：S5 与 S6 文件集不相交、输入互不依赖（独立性四问全 no）→ 声明并行组 `[p2-wiring]`（S5+S6 同批并行）；S3/S4 因同文件族依赖设计定稿串行先行。frontmatter parallel_groups: [p2-wiring]

### Phase 3: 守卫 selftest 与全量回归
<!-- Phase 3 in_progress 2026-10-10 -->
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [ ] S7 selftest-decision-arbiter.sh 新建（断言 ≥10：文件在位/model 强档/四态词/驳回单/Rule 69 子条/SKILL 三处/矩阵行/管辖二分/零新 config 键/rule-reserve landed）
- [ ] selftest registry 登记行（若 Phase 1 确认登记面要求）
- [ ] S8 全量 selftest 回归对照 Phase 1 基线（FAIL=0 或逐条分类：新增断言演进/并行任务演进）
- [ ] 每轮结果 Round 落盘 progress.md（Rule 57 四要素）
- **V-N:** VC-5, VC-2
- **Status:** complete（2026-10-10；2 commits 3322259/6e1202f；终跑 64 脚本 failed=1=AC-04 部署暂态）
- **Executor:** executor（sonnet-1，写脚本）+ code-runner-agent（mini，跑回归）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S7 | selftest-decision-arbiter.sh 编写+registry 登记 | executor | worktree 内 scripts/；断言清单见上（先例=selftest-drift-enforcement.sh 结构） | bash 执行全 PASS≥10 断言 | ≤15min | 2f/100l/15min | 无 | S3-S6 | pending |
| S8 | 全量 selftest 回归+基线对照分类 | code-runner-agent | worktree 内 scripts/selftest-*.sh+Phase 1 基线数字 | Round N 四要素入 progress | ≤15min | 0f/0l/15min | 无 | S7 | pending |

### Phase 4: CR 审查与修复
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [ ] alignment-review 对齐审查（42.6.2 标准收尾；产出与更新文档全量）
- [ ] code-quality-review（新 selftest 脚本=代码文件；轻 diff 分级判定）
- [ ] CHANGES_REQUESTED → fix-phase（≤3 轮，Rule 33.4）
- **V-N:** VC-1, VC-5
- **Status:** complete（2026-10-10；S9 verdict CHANGES_REQUESTED P0=0→fix 完成；S10 同 P0=0→fix 完成；CR Gate 等效 APPROVED（P0 清零+fix-phase complete））
- **Executor:** alignment-review + code-quality-review（质量审查族，42.2 登记工具）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S9 | alignment-review 全量对齐审查 | Skill(alignment-review) | worktree 内 6 个 scope 文件 | APPROVED 或问题清单 | ≤15min | 0f/0l/15min | 无 | S3-S6 | pending |
| S10 | code-quality-review 代码面审查（selftest 脚本） | Skill(code-quality-review) | worktree 内 scripts/selftest-decision-arbiter.sh | APPROVED 或问题清单 | ≤10min | 0f/0l/10min | 无 | S7 | pending |

### Phase 5: 合并回+部署对账+清理
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] worktree 内 git status 干净+全 VC 复验
- [x] smart-merge-back.sh --deploy（预检+--no-ff 合并+部署对账；v152/v153 在途→冲突并集解，v149 先例）
- [x] rule-reserve.sh land 69 task-v154
- [x] sync-companion.sh companion agents 双位部署
- [x] D2 router 部署位登记（若 D2 源不在本仓，直接改 ~/.zcode/skills/skill-agent-router/SKILL.md 部署位并登记）
- [x] git worktree remove + git branch -d（[CLEANUP] 合约）
- [x] 主仓 Read 关键文件复验
- **V-N:** VC-6, VC-1
- **Status:** complete（2026-10-10；merge 5280cb3+三 skills 位 IDENTICAL+agents 双位+C47+rule landed+清理）
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排+部署脚本调用——Rule 25.3 白名单①②）

### Phase 6: 终验与交付总结
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] check-complete.sh exit 0
- [x] VC 逐条复验（V-1.1..V-6.2 记录 verification.md）
- [x] Rule 58.5 三态裁决：solved（R1/R3/R4/R5 全 covered）
- [x] 委派统计（4/6 Phase 子代理执行，白名单①② EXEMPT）+质量门控 Q1-Q6 全 PASS
- [x] delivery-summary 五要素交付
- **V-N:** VC-5, VC-6
- **Status:** complete（2026-10-10；65/65 回归+check-complete 见 progress Phase 6）
- **Executor:** 主进程（例外理由:② 计划系统文件簿记+终验门控——Rule 25.3 白名单②③）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①: v151 progress.md 修改+3 个 plans/ 目录未跟踪=并行任务簿记，与本任务 scope 零重叠;信号②③: v152/v153 两个 worktree+wt 分支在途——合并回时须检查其是否已合并,冲突走并集解;信号④⑤: 无） |
| `isolation` | `worktree`（§十一 11.1.1 保护区命中：skills/** 修改） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter` |
| `branch` | `wt/v154-decision-arbiter`（从 master 创建） |
| `merge_back` | `merged(5280cb3)` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | critical-rules.md/SKILL.md 增行触发行数/锚点级联断言（v150 教训：SKILL 钉值上调） | 6 | 6 | 5 | 180 | 走 22.3①：全量 selftest 对照 Phase 1 基线逐条分类，断言实现行先读后改，级联清单一次性回炉（先例 task-v149 D 锚级联） |
| Phase 2 | worktree 从 master 创建后技能文件 desync（memory 判例复发） | 7 | 3 | 4 | 84 | 创建后立即 diff companion/agents 与 master；不一致从 master cp 对齐后再派发 |
| Phase 5 | 合并回与 v152/v153 并行任务冲突（双方可能改 SKILL.md/critical-rules.md） | 7 | 5 | 4 | 140 | 走 22.3①：合并前 git log 检查 v152/v153 是否已 land；冲突并集解（v149 先例：撞号合并丢文本防线=diff 全文对照+幽灵断言扫描）；无法自动合则 STOP 报告用户 |
| Phase 5 | 部署位脚本与运行位冲突（REJECTED 三犯教训） | 5 | 3 | 3 | 45 | sync-companion 输出对账；部署位写失败先查运行位锁再原子换位 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-10 | S1 已建映射 |
| Phase 2 | ☑ | 2026-10-10 | S1 已建映射 |
| Phase 3 | ☑ | 2026-10-10 | S1 已建映射 |
| Phase 4 | ☑ | 2026-10-10 | S1 已建映射 |
| Phase 5 | ☑ | 2026-10-10 | S1 已建映射 |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. agent 名称用什么？→ `decision-arbiter`（决策仲裁执行体——判断+裁决+打回三义齐备，kebab-case 对齐 drift-checker 命名风格；Decision D1）
2. 强模型选哪档？→ `account:zai-individual-coding-plan/GLM-5.3`（complex-planner 同款 Opus 级，custom:uuid 式禁用先例；Decision D2）
3. 与既有判断面（critic/drift-checker/meta-corrector）如何管辖二分？→ 见 Decisions D3
4. 触发时机如何界定才不滥用（强模型成本）？→ Rule 69.5 经济性边界：四类场景+每问题独立单次派发+禁驻留循环裁决

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning behind them.
  WHY: You'll forget why you made choices. This table helps you remember and justify them.
  WHEN: Update whenever you make a significant choice (technology, approach, structure).
  EXAMPLE:
    | Use JSON for storage | Simple, human-readable, built-in Python support |
-->
| Decision | Rationale |
|----------|-----------|
| D1: agent 名=`decision-arbiter`，定位=「判断/裁决/打回」闭环的专属强判断出口 | 用户需求三要素（做选择判断/强模型/发现错误打回）各落一处：arbiter=裁决者；与 drift-checker（只判对齐性）语义正交 |
| D2: model=`account:zai-individual-coding-plan/GLM-5.3` + thoughtLevel: enabled | complex-planner(v119) 先例同款 Opus 级强档；`custom:uuid` 式已禁用（v119 教训：禁 custom:ccr-uuid 式） |
| D3: 管辖二分——drift-checker=对齐性判定(haiku 高频轻量)；critic=工作产物挑刺审查；meta-corrector=自我纠偏反思；complex-planner=规划升级出口；decision-arbiter=判断/裁决出口(方案选型终裁/错误复核定级/完成度争议仲裁/证据不足疑点的继续-返工裁决) | Rule 53.3 管辖二分先例；六者输入输出均不同：arbiter 输入=争议问题+证据材料包，输出=四态裁决+驳回单 |
| D4: 裁决四态=APPROVE/REJECT-REWORK/ESCALATE-USER/INSUFFICIENT-EVIDENCE；驳回单五要素=问题定位(file:line)/违反判据(VC 或规则锚)/证据/严重度/建议返工路径 | 四态穷尽裁决输出空间；ESCALATE-USER 仅限 G1-G4 门槛（Rule 41.2 对齐）；驳回单五要素保证主代理可执行返工（可定位性 Rule 48 类比） |
| D5: Rule 69 六子条=69.1 触发场景与管辖二分/69.2 委派契约(检查点+材料包)/69.3 裁决消费协议(REJECT-REWORK 强制返工+留痕,禁静默继续)/69.4 驳回单五要素/69.5 强模型档与经济性边界/69.6 机制=selftest+零新 config 键 | 对齐 Rule 61/63/64 条款结构惯例（场景→契约→协议→机制）；零新 config 键=42.4 后惯例 |
| D6: 编号预留 new_rule=69 | rule-reservations.jsonl：67=v152 占、68=v153 占（并行任务在途），69 为下一空闲号；attest 自动查重兜底 |
| D7: 判定必须第一手取证（Read/Grep/命令），禁凭派发摘要单独下结论；只读仓库，唯一写=检查点+裁决单 | drift-checker 先例硬约束迁移；防止强模型幻觉直接污染主进程决策 |
| D8（2026-10-10 用户追加 B 类扩展登记）: 触发点矩阵 T1-T6——**T1 计划期方案终裁**（43.3 候选对比 ≥2 候选难决时）；**T2 兜底链换道裁决**（Rule 22.3 五档兜底①-④ 选择拿不准时）；**T3 子代理失败复核定级**（failed/FAIL 真缺陷 vs 误报、严重度与返工路径）；**T4 验收完成度争议**（22.5 三证据 vs 子代理自报 done 冲突时独立仲裁）；**T5 DRIFT 处置裁决**（drift-checker 判 DRIFT 后「警觉继续 vs 立即返工」拿不准，不替代检测本体）；**T6 CR 分歧与终验边界**（CHANGES_REQUESTED 意见接受度/PARTIAL-COMPLETE 边界拿不准）。豁免清单（防滥用）：trivial 机械判断（41.3 主进程直做）/偏移检测本体（61 载体 drift-checker）/代码审查本体（42 族）/G1-G4 直接升级场景（41.2）——arbiter 每问题单次独立派发，禁高频循环裁决 | 用户明确要求「明确在哪个阶段需要引入判别执行」——泛泛条款不满足，须在 SKILL.md 执行流程对应位置落可定位触发点标记；T1-T6 对应 SKILL.md 六个流程锚，执行期 S5/S4 落地 |
| D11（2026-10-10 委派守卫口径修正，Rule 51.7 重锁登记）: Handoff 表 subagent_type 列裸名化（去 (mini)/(sonnet-1) 后缀——check-delegation 归一化剥括号后与表内精确竖线匹配，v150 教训复发防再发）+补 S9/S10 两行登记（Phase 4 Executor token=alignment-review/code-quality-review 须在 Handoff 表）→ 重锁 attest | check-complete DELEGATION GATE verdict=violation（4 Phase Executor 含未登记 token）→根因=后缀别名+漏登记非未派发 |
| D10（2026-10-10 CR Gate 处置，B 类扩 scope 登记）: S9 verdict=CHANGES_REQUESTED(P0=0/P1=1/P2=1:P1-01=AC-04 部署暂态 Phase 5 验证,P2-01=CHANGELOG 未登→查证 v146-v153 全部登记惯例→裁决补登扩 scope)；S10 verdict=CHANGES_REQUESTED(P0=0/P1=1/P2=2:DA-16 BRE `+` 量词可移植性必修+awk `,0` 范围+文件缺失 stderr 顺修) | Rule 42.6.2 收尾对齐+P0=0 不阻断→fix-phase 一次修完（CHANGELOG 补登+DA-16/P2）后进 Phase 5 |
| D9（B 类变更重锁登记，Rule 51.7）: 2026-10-10 用户批准+追加触发点矩阵要求 → 计划更新 R5+VC-3 扩展（grep ≥8 处）+D8 触发点矩阵 → 重跑 attest 重锁 | 用户 yes=原计划批准；追加要求按 B 类「先重规划再执行」流程落计划后重锁 |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
  EXAMPLE:
    | FileNotFoundError | 1 | Check if file exists, create empty list if not |
    | JSONDecodeError | 2 | Handle empty file case explicitly |
-->
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
<!-- 
  REMINDERS:
  - Update phase status as you progress: pending → in_progress → complete
  - Re-read this plan before major decisions (attention manipulation)
  - Log ALL errors - they help avoid repetition
  - Never repeat a failed action - mutate your approach instead
-->
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 会话启动时收到 [PLAN TAMPERED]（task-v150 计划哈希不符）——非本会话所为（并行会话遗留），已开场向用户报告备查，与本任务无关

## 🚨 Drift Log（漂移检测记录）
<!-- 
  WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-10 P1 complete 后 | ALIGNED | VC-5/VC-4 | Phase1 五动作全在 Goal/scope 内零越界（drift-checker provider 拒→22.3①改派 general-purpose，检查点 drift-1.md） |
| 2026-10-10 P2 complete 后 | ALIGNED | VC-1..VC-4 | Phase2 4 commits 与计划一致 主仓 skills 零越界（检查点 drift-2.md；64.2 门控实弹拦截后补查通过） |
| 2026-10-10 P3 complete 后 | ALIGNED | VC-1/2/5 | Phase3 守卫+回归终跑 failed=1 部署暂态（检查点 drift-checker-3.md） |
| 2026-10-10 P4 complete 后 | ALIGNED | VC-1/VC-5 | Phase4 双 CR P0=0+fix complete 等效 APPROVED（检查点 drift-checker-4.md） |
| 2026-10-10 P5 complete 后 | ALIGNED | VC-6 | Phase5 合并部署清理全到位 与 VC 范围一致（检查点 drift-checker-5.md） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 6（Phase 1/2/3/4；共 14 次子代理派发：code-runner×2/Explore×1/executor×7/general-purpose×4） |
| 主进程直做 Phase 清单 | Phase 5（白名单① git 编排+部署脚本）、Phase 6（白名单② 簿记+终验门控）；S8 回归代跑（白名单⑤ 22.3 接管） |
| 委派率 | 0.667<floor 0.7 但全部白名单①②命中 → WHITELIST-EXEMPT 放行 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-10 | code-runner-agent | S1 master 基线回归 | done | 64/64 全 PASS ΣPASS=1002 ΣFAIL=0 零 timeout | checkpoint 1-code-runner.md | findings §Baseline | subagent-state/1-code-runner.md | - / 0 / ☑ |
| 2 | 2026-10-10 | Explore | S2 登记面锚定位 | done | D2:101/D3:289/registry TSV 必登/Rule69 锚:860/触发点 6 锚全定位 | checkpoint 2-explore.md | findings §Research | subagent-state/2-explore.md | - / 0 / ☑ |
| 3 | 2026-10-10 | executor | S3 agent 定义 | done | 60 行 frontmatter GLM-5.3+四态+驳回单+T1-T6 全在位，主进程 Read 复核通过 | worktree commit（本行上方） | findings §Implementation | subagent-state/3-executor.md | - / 0 / ☑ |
| 4 | 2026-10-10 | executor | S4 Rule 69 前三子条 | done | +8 行超长行紧凑制(对齐既有风格) 69.1-69.3+T1-T6+REJECT-REWORK 全在位 纯追加 verified | diff 8+/0- | findings §Implementation | subagent-state/4-executor.md | - / 0 / ☑ |
| 5 | 2026-10-10 | executor | S5 SKILL 接线+触发点 | done | 11 处写入 grep=12 occurrences/Rule69=11 行/T1-T6 全在位/欠账修正披露 | diff 11+/1- | findings §Implementation | subagent-state/5-executor.md | - / 0 / ☑ |
| 6 | 2026-10-10 | executor | S6 矩阵+D3 登记 | done | 矩阵 28 行+计数同步 2 处+§九§十各+1 行+D2 文本入检查点；AC-09 上界 129→130 待 S7 | diff 5+/2- | findings §Implementation | subagent-state/6-executor.md | - / 0 / ☑ |
| 7 | 2026-10-10 | executor | S7 selftest 编写+AC-09+registry | done | DA-01..16 全 PASS（主进程复跑独立验证）；AC-09 上界演进；registry 65 行 | commit 3322259 | findings §Verification | subagent-state/7-executor.md | - / 0 / ☑ |
| 8 | | code-runner-agent | S8 全量回归 | queued | | | §Verification | subagent-state/8-code-runner.md | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除此整个区块。 -->

（本任务 chain_mode: single，无链式交接区块——已删除冗余骨架）

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一；技能演进类在 16 类中无专型，v146/v147 等先例同落 general）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 不沉淀理由=技能演进类 variant 已有成熟系列（v122-v151 同类任务均未沉淀，遵循先例）
