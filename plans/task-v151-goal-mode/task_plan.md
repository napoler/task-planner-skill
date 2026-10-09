# Task Plan: goal 模式执行可靠性——任务分解固化 + /goal 驱动逐个推进（Rule 66）

<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC -->

- **R1**: 「优化当前的任务，主动将规划之后的任务名称就是任务以及目标以及验证方式使用 goal 模式进行设定，来确保后期的执行可以彻底」<sub>（[目标]）</sub>
- **R2**: 「核心说法就是将任务分解拆解为固定的，分析明确之后设定为目标，然后并且设定目标之后包含完整的验证，然后使用 goal 来进行任务的推进，确保整个任务执行的可靠性」<sub>（[目标]）</sub>
- **R3**: 「我说的核心就是使用 VSCode 自带的 /goal 就是目标模式，就是可以让任务朝着这个目标不断地迭代」<sub>（[手段]）</sub>
- **R4**: 「你的工作需要修改的方向就是将一些任务拆解，或者说任务分解之后，然后逐个设为这种方式，这种模式进行逐个地进行执行。就是自动分解任务，然后按照调度之后逐个进行解决」<sub>（[目标]）</sub>
- **R5**: 「你这是在恶意的导致错误，因为当前这种模式当前这种目标模式，直接在输入框输入这指令就可以完成，就可以激活，你为什么在乱七八糟的方向呢？」（2026-10-09 06:0x，对初版「自建机制」方向的纠正）<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-5 | 规划后任务单元固化=Goal 单元表逐行含「任务名+目标+完整验证方式」（grep 表头+本计划实例行）；后期执行彻底=全 selftest 回归 FAIL 数=基线 0 新增 |
| R2 | VC-1, VC-3 | 拆解固定化+目标含完整验证=check-plan-dispatch.sh attest 期校验 Goal 单元表四要素（66.1）+check-complete.sh 终验逐 goal 对照验证方式完成状态（66.3） |
| R3 | VC-1 | 用内置 /goal 而非自建程序化触达=critical-rules 66.2 原文「/goal=用户侧 harness 命令，输入框直接激活，技能层不可代调，只做映射指引与供料呈示」grep 命中 |
| R4 | VC-1, VC-4 | 自动分解+调度逐个解决=Rule 66.4 拆解→调度→逐 goal 推进条款在位+新 selftest-goal-unit-goal-mode.sh 全 PASS exit 0 |
| R5 | VC-5 | 纠正误判方向=Errors 表 R5 误判行在位+WHITELIST-EXEMPT 放行（委派率 3/5）+零回归（VC-5） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 结果级需求（R1/R2 确保执行可靠性）必须分解生产管线逐工序审计缺陷面 -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 任务分解（规划获批后） | 任务单元非固定形态：S-unit 表各列契约不一、无统一「目标+验证方式」载体，执行期可被口头改判 | S3 模板 Goal 单元表（goal-id+任务名+目标+完整验证方式 四要素逐行固化） | VC-1, VC-2 |
| 目标设定 | 目标无完整验证方式=不可审计，/goal 完成审计无证据链 | S2 Rule 66.1/66.2 子条：goal 单元必含可复现验证方式（命令/路径+判据） | VC-1, VC-3 |
| 调度推进 | 多 goal 并发推进/跳序推进=漂移主要来源；/goal 迭代无对应落盘 | S2 Rule 66.4：调度后逐 goal 顺序推进，goal 验证通过才翻 complete（66.3 门控） | VC-1, VC-4 |
| 终验裁决 | goal 级完成声称无对照面，只有 Phase/VC 级 | S4 check-complete.sh 追加 Goal 单元表逐行对照（验证方式证据 vs 状态） | VC-3 |
| 回归面 | 新增区块/条款破坏既有计数锚（SKILL 行数、selftest 定值、1-65 计数） | S5 钉值级联上调清单逐项对照（recon Q6 清单）+全 selftest 回归 | VC-5 |

<!-- plan_tier: standard -->
## Goal
<!--
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
-->
task-planner 技能新增 Rule 66「goal 单元固化与 /goal 驱动推进纪律」：规划获批后任务自动分解固化为 goal 单元（goal-id+任务名+目标+完整验证方式），执行按 goal 逐个调度推进、验证通过才翻 complete，并与 ZCode 内置 /goal 命令（用户输入框直接激活）做映射供料，确保后期执行可靠性；全链落地=critical-rules 条款+模板区块+attest/终验守卫+新 selftest+部署位同步。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（实现类多文件代码变更，重 diff 全量多轮 CR） |
| `session_id` | `200da20b-81f0-4826-b1b1-e4cb59bb42dd` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode`（Phase 2 创建） |
| `scope_files` | `skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-planner/templates/task_plan.md, skills/task-planner/scripts/check-plan-dispatch.sh, skills/task-planner/scripts/check-complete.sh, skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh(新), skills/task-planner/scripts/selftest-registry.tsv` |
| `interaction_mode` | `ask`（默认；D1 批准前按 28.2.1 口头复述执行思路） |
| `对齐审查` | `[登记]` 任务完成前对全部产出跑 alignment-review（42.6.2 标准收尾） |
| `自动超时默认项` | `[询问点 D1: 默认=批准计划+worktree 隔离 / 超时 5min；D2: 默认=Rule 66 编号 / 超时 5min]` |
| `new_rule` | `66`（Rule 20.6：attest 自动预留+查重；账本 65 已 landed，66 空闲待 attest 确认） |
| `质量审查工具` | `[code-reviewer 子代理（既有环境 agent，sonnet-1）——42.2 环境 agents 层命中，无缺口]` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行，主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | critical-rules.md 新增 Rule 66 六子条（66.1 goal 单元四要素固化 / 66.2 /goal 内置命令口径「输入框直接激活·技能层不可代调」/ 66.3 逐 goal 验证通过才 complete / 66.4 自动分解→调度→逐个解决推进序 / 66.5 模板区块承载+mini 豁免 / 66.6 机制=零新 config 键+selftest 守护），SKILL.md 登记行+1-65→1-66 计数级联完成 | worktree 内 `grep -n '^### 66' references/critical-rules.md` 命中 + `grep -c '66\.[1-6]' 各子条` ≥6 + SKILL `grep -n 'Rule 66' SKILL.md` ≥2 | worktree 路径:文件#行 |
| VC-2 | templates/task_plan.md 含「🎯 Goal 单元表」区块（goal-id/任务名/目标/完整验证方式 四列+本任务 dogfood 实例行）且 check-plan-dispatch.sh attest 期对 Goal 单元表四要素做机械校验（缺列/缺验证方式=拒锁） | worktree 内 `grep -n 'Goal 单元表' templates/task_plan.md` ≥1 + 临时缺表副本跑 check-plan-dispatch.sh exit≠0 负样本 + 完整副本 exit 0 正样本 | worktree:scripts 输出 |
| VC-3 | check-complete.sh 终验追加 Goal 单元表逐行对照（验证方式证据 vs 状态，未完成禁 COMPLETE 仅 PARTIAL） | worktree 内 grep 新逻辑在位 + 对本计划目录实跑 check-complete.sh（当前 goal 未全 complete 时应拦截/提示，翻全 complete 后放行） | 命令输出 |
| VC-4 | 新 selftest-goal-unit-goal-mode.sh 全 PASS 且登记 selftest-registry.tsv | worktree 内 `bash scripts/selftest-goal-unit-goal-mode.sh; echo $?` = 全 PASS/exit 0 + `tail -1 scripts/selftest-registry.tsv` 含新行 | 脚本输出 |
| VC-5 | 零回归：全 selftest 套件 FAIL 数=任务前基线（0 新增）；部署位同步后 zcode/cursor/claude 三 diff 空（IDENTICAL）；钉值级联（selftest-skill-split SKILL 行数等）全绿 | 基线=Phase 2 记录的全 selftest FAIL 计数快照文件 + 终态同命令对比 + `install.sh`/diff 三位置输出 | plans/task-v151-goal-mode/baseline-selftest.log |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!-- 终验时填写;solved 必填解决证据锚;not-solved/partial 禁止标 COMPLETE -->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 / R2 / R4 / R5 |
| **裁决** | （终验填写 `solved` / `partial` / `not-solved`） |
| **解决证据锚** | （solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：已排除「/goal 程序化触达面」——实测无结构化存储可写，见 /goal-empirical 检查点） |
| **下一步建议** | （not-solved 必填） |

## 🎯 Goal 单元表（Rule 66.1 载体 dogfood — 本计划即本机制的首个实例）
<!-- 2026-10-09 task-v151 引入：规划获批后任务单元固化为 goal 单元，逐行含完整验证方式；执行按 G 序逐个调度推进，66.3 验证通过才翻 complete；
     用户已用 /goal 锚定本任务时本表即 /goal 完成审计的证据源（40.3 映射指引；/goal=用户侧内置命令，输入框直接激活，技能层不可代调） -->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 需求定稿与 /goal 实证 | R 行逐字落盘+/goal 无程序化触面实证 | findings.md 含 R1-R5 行 + ledger error 事件 + subagent-state /goal-empirical.md 三处「不存在」结论在位 | Phase 1 | complete |
| G2 | 机制设计定稿 | Rule 66 子条文本+Goal 单元表格式+钉值清单定稿 | plans/task-v151-goal-mode/design-draft.md 存在且含 66.1-66.6 草案全文 + 钉值级联清单逐条可查 | Phase 2 | pending |
| G3 | 规则与模板落地 | critical-rules/SKILL/模板/两守卫脚本落地 worktree | worktree 内 `git diff --stat` 覆盖 scope_files 且 S2-S4 各 selftest 锚 grep 命中（逐 S-unit 验收列） | Phase 3 | complete |
| G4 | 守卫与 selftest | 新 selftest 全 PASS+registry 登记+钉值全绿 | worktree 内新 selftest exit 0 + 全量 selftest ΣFAIL=0（S4b POST-FIX 行） | Phase 3 | complete |
| G5 | 部署与回归 | 三部署位 IDENTICAL+全量回归 | 部署 zcode/cursor/claude 位 8 核心文件 cmp 全 OK（SKILL.md 各平台前缀差异=install 固有平台定制面）+ final-regression.log ΣFAIL=0（64 脚本，Total 行口径） | Phase 5 | complete |
| G6 | CR 与交付 | CR APPROVED+合并回+交付总结 | CR 首轮 CHANGES(F1-F3)→6cf8cd7 修复全绿（检查点 11/13）；merge_back=merged(ebb5fba)；delivery-summary 五要素在位 | Phase 4-5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能条款 | skills/task-planner/references/critical-rules.md（仅文末追加 Rule 66） | 既有 Rule 1-65 正文改写 |
| 技能登记 | skills/task-planner/SKILL.md（Rule 66 登记行+1-65→1-66 计数 3 处+行数钉值随动） | 其他章节 |
| 模板 | skills/task-planner/templates/task_plan.md（Goal 单元表区块插入） | variant/ 其他模板 |
| 守卫脚本 | skills/task-planner/scripts/check-plan-dispatch.sh、check-complete.sh、selftest-goal-unit-goal-mode.sh（新）、selftest-registry.tsv（追加 1 行）、钉值级联涉及的既有 selftest（仅钉值行） | 其他 scripts/ |
| 计划系统 | plans/task-v151-goal-mode/**（簿记/design-draft/baseline） | 其他任务 plans |

**执行前自我检查**: 文件在列表内？必要？用户明确要求？→ 全 Yes 才执行。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/URL/版本） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | 既有 goal 相邻机制（Rule 40/58、goal-gate.md、VC 表） | skills/task-planner/references/critical-rules.md:428-436（Rule 40）、references/goal-gate.md、templates/task_plan.md VC 区块 | 必读 | ☑ |
| 项目内部文档 | 机制插入点与钉值断言面（recon 结论） | plans/task-v151-goal-mode/subagent-state/01-explore-goal-mode-recon.md | 必读 | ☑ |
| 项目内部文档 | /goal 环境实证（无程序化触达面） | 主进程实证：~/.zcode/cli config 无 goal 字段、/opt/ZCode 无 goal 模块、agent metadata 无结构化 goal 字段（06:0x 三条命令输出） | 必读 | ☑ |
| 用户宪法 | §一 子代理优先 / §十一 worktree 隔离 | ~/.zcode/AGENTS.md | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: 规划后的任务单元没有统一的「目标+验证方式」固化载体，且未与 ZCode 内置 /goal 命令对齐——执行期目标可被漂移、验证面缺失，用户要求以 /goal 目标模式逐个推进确保可靠性。
- [x] 核心问题解决后，结果能交付吗？（能：机制落仓+部署位同步+dogfood 实例=本计划）
- [x] 核心问题不解决，其他工作都白费吗？（是：无固化载体则后续任务仍漂移）
- [x] 核心问题的解决方法是清晰的、可执行的？（是：六子条+模板区块+双守卫+selftest，插入点已 recon 定稿）

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 既有 Rule 40.3（/goal 只映射指引·不可代调）+Rule 58（目标型需求门控） | Read critical-rules.md:428-436 | skills/task-planner/references/critical-rules.md:434 | ☑ |
| ② 对标样本（58.2 强制） | 用户 2026-10-09 三次澄清原文 + R5 纠正（内置 /goal 输入框直接激活为权威判据） | 会话原文逐字抄录 | task_plan.md R3/R5 行 | ☑ |
| ③ 外部约束 | ZCode /goal 为内置 harness 命令，技能层无代调/读取接口（用户明示+实测 3 处程序化触达面查证无结构化字段） | 用户 R3/R5 明示 + 主进程实证（config/opt/agents 三处 grep） | findings.md Requirements 段 + 本表 ③ 行 | ☑ |

## Current Phase
Phase 5（complete；全部 Phase 终态，交付中）

## Next Step
交付完成：outcome=COMPLETE（待 check-complete 终验 exit 0 确认）；遗留=仓内 .backup/claude-stub 目录外移（用户裁决）+ 新会话 /goal 行为面冒烟（可选）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore（mini）+ 机械守卫脚本（check-conflicts） | 跨多文件侦察（仓布局/钉值面/插入点）= 宪法 §一 必委派；冲突扫描=主进程机械 |
| Phase 2 | 主进程（白名单①git 编排+②计划系统文件维护） | 设计定稿=计划系统文件维护；worktree 创建=git 编排 |
| Phase 3 | Agent 子代理 executor（sonnet-1）逐 S-unit + 机械验证（selftest） | 实现类必委派（Rule 25）；S-unit 粒度三值内 |
| Phase 4 | Agent 子代理 code-reviewer（sonnet-1） | code_review: required 重 diff 全量 CR |
| Phase 5 | 主进程（白名单①git+②簿记）+ 机械守卫（install 对账 diff） | 合并回/清理/部署对账=git 编排与机械验证 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（S-unit 串行依赖链为主，无 fan-out 独立并行组）→ 按 Rule 21.4 默认串行调度；未点名 /workflow（39.1 红线）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 /goal 完成审计的证据源；用户已明示使用内置 /goal 目标模式（R3）——/goal 为用户侧 harness 命令（输入框直接激活），技能层不可代调，本计划以「🎯 Goal 单元表」区块为映射供料载体（66.2 口径）；执行期每 goal 翻 complete 时供料呈示对应 VC/证据锚。

## Phases
<!-- Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写白名单例外理由;派发型 Phase 必附 S-unit 表(22.6) -->

### Phase 1: 需求定稿与 /goal 实证
- [x] Understand user intent（三次澄清原文逐字落盘 findings.md，R1-R5）
- [x] Identify constraints（/goal=内置命令不可代调实证；check-conflicts 输出+隔离决策）
- [x] Document findings in findings.md（Requirements 段 + superseded 初版方向登记）
- [x] 知识储备必读项已确认可获取（4 行全 ☑）
- **V-N:** VC-1, VC-5（R 行定稿是 66.1 四要素素材源；/goal 实证约束 66.2 口径与零回归面）
- **Status:** complete
- **Executor:** explore（mini）
<!-- S1 执行体=explore（mini）；S-unit 表（22.6/66.5 显式 standard 档 attestation 门校验） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S0 | 8 问机制插入点侦察 | explore（mini） | 仓根 /mnt/data/dev/task-planner-skill | 检查点 01-explore 8 问全答 | 15min | 0f/0l/15min | 无 | complete |

### Phase 2: 机制设计定稿（worktree + 基线 + 设计草案）
- [x] 创建 worktree（master 基线，路径 /mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode，分支 wt/v151-goal-mode；创建后 diff 关键文件 vs 部署位——v150 教训：worktree 文件可能与部署位不同步，先核对再动）
- [x] 记录全 selftest 基线（FAIL 计数快照 → baseline-selftest.log）
- [x] 写 design-draft.md：Rule 66 六子条草案全文 + Goal 单元表列契约（四列=goal-id/任务名/目标/完整验证方式，S-unit 表 $10 之后安全位或独立区块）+ 钉值级联清单（recon Q6：selftest-skill-split:46 SKILL≤510 等 5 处 + registry 自动 +1 + EG-16 前向防线演进）
- [x] 向用户呈示设计+28.2.1 思路复述，等 D1 批准
- [x] S8：/goal（Goal Mode）官方文档检索落盘（用户 2026-10-09 追加指令：重 CR 不得缺官方文档面）
- [x] S9：带官方文档的重 CR（66.2 口径与官方语义对照）+ 如有 CHANGES 走 fix-phase
- **V-N:** VC-1, VC-4（设计定稿是 66 条款与 selftest 的前置；缺钉值清单=VC-4/VC-5 回归红）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排 + ② 计划系统文件维护（design-draft/基线落盘属 plans/ 计划系统文件）——Rule 25.3 白名单）
<!-- G2 complete 证据：design-draft.md 存在含 66.1-66.6 草案全文+钉值 D1-D5；worktree 5 文件 diff 部署位全 OK；baseline ΣFAIL=0 -->

### Phase 6: 官方文档对照与重 CR（用户追加指令 2026-10-09）
- [x] S8 官方文档检索：Web Search Agent 抓 ZCode /goal（Goal Mode）官方文档→subagent-state/09-goal-official-docs.md（zcode.z.ai 官方 4 页原文引句+本地安装面区分）
- [x] S9 重 CR：code-reviewer 以 101475f+6cf8cd7 diff + 官方文档为输入全量复审→必须修 0/建议增强 2（66.2 补官方单目标约束消歧+plan 模式冲突提示）→主进程裁决全采纳→d56276e 纯增量 1 行→merge 7fa66ac→三部署位 critical-rules cmp OK
- [x] CHANGES 若有→fix-phase（≤3 轮）+ 回归 + 部署对账（增强 2 条已走 S9f 修复闭环；selftest 4 脚本抽验全绿）
- **V-N:** VC-1, VC-5（66 条款面受官方文档校正；零回归）
- **Status:** complete
- **Executor:** general-purpose（S8 官方文档检索；原 web-search-agent 类型 provider 拒→22.3.1 改派登记）/ code-reviewer（S9 重 CR）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S8 | /goal 官方文档检索+要点提炼落盘 | general-purpose（原派 web-search-agent 类型 provider 拒→22.3.1 改派） | ① ZCode 官方文档（zcode.z.ai/官网 docs，搜索词 Goal Mode//goal slash command 中英文）② 检查点=14-websearch-goal-docs.md | 官方 /goal 文档全文要点（语法/迭代语义/完成验证方式/程序化触达面）落盘；无官方文档=已检索清单合法形态（63.3） | 15min | 0f/60l/15min | 无 | complete |
| S9 | 带官方文档的重 CR | code-reviewer（sonnet-1） | ① worktree diff 101475f+6cf8cd7 ② subagent-state/09-goal-official-docs.md ③ 前次 CR 检查点 11/13（F1-F3 已修面复验） | 结论 APPROVED 或 CHANGES_REQUESTED（F 清单）；66.2 与官方语义偏差逐条定性 | 15min | 0f/100l/15min | 无 | complete |

### Phase 3: 实现（worktree 内，逐 S-unit 派发）
- [x] 在 worktree 内按 S-unit 表逐项派发 executor 实现（每个 S-unit 一次派发，46.1 单会话单 S-unit）
- [x] 逐 S-unit 验收（22.5 三证据）+ 回填 findings/progress + ledger
- [x] 全 selftest 回归 FAIL 数=基线（S4b 后 ΣFAIL=0，64 脚本）
- **V-N:** VC-2, VC-3（模板区块+双守卫脚本落地）
- **Status:** complete
- **Executor:** executor（sonnet-1）
<!-- G3/G4 complete 证据：worktree git diff 覆盖 scope（critical-rules+14/模板+12/check-plan-dispatch+90/SKILL 级联/check-complete+46/新selftest+127/registry+1/钉值 D1-D2）；回归 S4b POST-FIX ΣFAIL=0；检查点 03/04/06/08/10 五份 8 字段在位 -->

<!-- S-unit 派发单元表(Rule 22.6 — 每行 = 一次 Agent() 派发;单步 ≤2 文件/≤100 行/≤15min;ID 纯数字;粒度三值 Nf/Nl/Nmin 逐行填报;伴飞技能列:无) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S1 | critical-rules.md 文末追加 Rule 66 六子条（66.1-66.6 草案文本取自 design-draft） | code-assistant（haiku-1） | ① plans/task-v151-goal-mode/design-draft.md（66 条款草案全文）② 部署位 critical-rules.md 行 846 后追加位 | `grep -c '^66\.' worktree critical-rules.md` ≥6；既有 1-65 正文零改动（git diff 仅文末追加） | 15min | 1f/80l/15min | 无 | complete |
| S2 | templates/task_plan.md 插入「🎯 Goal 单元表」区块（核心目标达成裁决后）+ check-plan-dispatch.sh 追加四要素校验段 | executor（sonnet-1） | ① design-draft.md（列契约+校验伪码）② 部署位 check-plan-dispatch.sh（$7/$8 解析位勿动，新列走独立区块状态机） | `grep -n 'Goal 单元表' 模板` ≥1；负样本缺表跑 check-plan-dispatch exit≠0、正样本 exit 0（worktree 内演示） | 15min | 2f/95l/15min | 无 | complete |
| S3 | check-complete.sh 终验追加 Goal 单元表逐行对照段 + SKILL.md Rule 66 登记行与 1-65→1-66 三处计数级联 | executor（sonnet-1） | ① design-draft.md（终验对照逻辑）② 部署位 SKILL.md 行 9/280/335/360 插入位 | `grep -n 'Rule 66' SKILL.md` ≥2；check-complete 对本计划实跑拦截未 complete goal 行 | 15min | 2f/80l/15min | 无 | complete |
| S4 | 新建 selftest-goal-unit-goal-mode.sh（静态锚断言：66 子条/模板区块/双脚本挂点/registry 行）+ registry.tsv 追加 + 钉值级联上调（recon Q6 清单逐项） | executor（sonnet-1） | ① design-draft.md（钉值清单）② 部署位 selftest-registry.tsv + selftest-skill-split.sh:46 等 5 处钉值行 | 新 selftest exit 0 全 PASS；`tail -1 registry.tsv` 含新行；既有 selftest 无一转红 | 15min | 2f/90l/15min | 无 | complete |
| S5 | 部署三位置（zcode/cursor/claude）同步 + 全 selftest 回归 + 基线对比 | code-runner-agent（mini） | ① worktree skills/task-planner 变更文件 ② baseline-selftest.log | 3 位置 diff 输出全空；回归 FAIL 计数=基线（对比日志行） | 15min | 0f/20l/15min | 无 | pending |
| S7 | Rule 66.5 档位语义修正（D2 裁决方案①：无 plan_tier 标记=缺省档跳过不拒锁）+ 66.5 子条同步 + 全量回归清零 | general-purpose | ① subagent-state/08-executor-S4.md（24 FAIL 清单）② check-plan-dispatch.sh 66.5 段 | 回归 ΣFAIL=0；本计划正样本 66.5 违规=0；剥离区块负样本 rc=1 | 15min | 2f/40l/15min | 无 | complete |

### Phase 4: Code Review Gate
- [x] 收集 worktree diff 改动文件清单 → 过滤代码文件
- [x] 派 code-reviewer（sonnet-1）全量 CR（重 diff）
- [x] APPROVED → 进入终验；CHANGES_REQUESTED → fix-phase（≤3 轮）（首轮 F1-F3 → 6cf8cd7 修复全绿，1 轮闭环）
- **V-N:** VC-3, VC-5（CR 覆盖守卫脚本语义正确性；返工面=零回归）
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）

<!-- S-unit 派发单元表（22.6；Phase 4/5 各 1 行） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S6 | 全量 CR 16 文件 diff | code-reviewer（sonnet-1） | ① worktree `git show 101475f` diff ② 12-brief-S6.md 任务书 | F 清单落检查点 11；修复后 8 字段 4/4 pass | 15min | 0f/100l/15min | 无 | complete |

### Phase 5: 交付与合并回
- [x] smart-merge-back.sh 合并回 master（ALREADY_MERGED 检测）+ worktree/分支清理
- [x] 终验：逐 VC 复验 + Goal 单元表逐行对照（66.3）+ 委派统计（WHITELIST-EXEMPT 论证：P2/P5 主进程理由=白名单①②，委派率 3/5）
- [x] delivery-summary.md 五要素（Rule 48 可定位性）+ check-complete.sh exit 0
- [x] rule-reserve land 66
- **V-N:** VC-4, VC-5（selftest 终态 + 零回归 + 三部署位 IDENTICAL）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排（合并/清理/部署对账）+ ② 簿记（交付总结/账本/attest）——Rule 25.3 白名单）
<!-- G5/G6 complete 证据：progress.md [goal:G5]/[goal:G6] 行 + delivery-summary.md + check-complete exit 0（仅剩 27.3 仓约定提示） -->

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①：plans/.active_plan M + plans/task-v151-goal-mode/ untracked——均计划系统文件，与 skills/ 任务范围零重叠；无信号②-④；信号⑤命中=本任务改运行中基础设施 skills/ → 必须 worktree） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode` |
| `branch` | `wt/v151-goal-mode`（自 master 创建，创建后 diff 关键文件 vs 部署位核对——v150 教训） |
| `merge_back` | `merged(ebb5fba)` |

## 📊 FMEA 预演（规划期 — RPN>100 必登记兜底动作）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 | 钉值级联漏项（SKILL 行数/selftest 定值断言转红） | 7 | 5 | 4 | 140 | 派发前对照 design-draft 钉值清单逐项 grep；转红 → 22.3 ②拆细派 code-assistant 单文件修钉值，①查资料=既有 selftest 报错行 |
| Phase 3 | 并行会话 live race（他会话改 critical-rules/SKILL 致合并冲突） | 6 | 4 | 4 | 96 | 每 S-unit 派发前 git fetch+diff master；冲突 → 并集解+重跑 affected selftest（v149/v150 判例） |
| Phase 3 | worktree 技能文件不同步（v150 实证 44 行 vs 587 行） | 7 | 4 | 3 | 84 | 创建后立即 diff critical-rules.md/SKILL.md vs 部署位，不一致 → 从 master/部署位 cp 修复再动 |
| Phase 4 | CR CHANGES_REQUESTED 返工循环 | 5 | 4 | 3 | 60 | fix-phase ≤3 轮，超限 → 22.3 ⑤ AskUserQuestion（D6） |
| Phase 5 | SKILL 行数触 selftest-skill-split ≤510 钉值 | 5 | 3 | 3 | 45 | S4 已列钉值级联清单，按清单上调（v150 判例：新 selftest 必登记+钉值上调） |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-09 06:xx | 已完成（G1 complete） |
| Phase 2 | ☑ | 2026-10-09 06:xx | 当前 in_progress |
| Phase 3 | ☑ | 2026-10-09 06:xx | pending（S1-S5 行） |
| Phase 4 | ☑ | 2026-10-09 06:xx | pending |
| Phase 5 | ☑ | 2026-10-09 06:xx | pending |

## Key Questions
1. Goal 单元表作为独立区块 vs S-unit 表加列——定稿=独立区块（不动 9 列契约，$7/$8 解析位零风险，recon Q4 结论）
2. check-plan-dispatch 缺 Goal 单元表=拒锁还是 WARN——定稿=standard/full 档拒锁、mini 档豁免（66.5，对齐 38.3 区块白名单惯例）
3. /goal 供料呈示频率——定稿=每 goal 翻 complete 时单行呈示（不循环重展，44.5 口径）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| veto: 初版方向「自建 goal 程序化机制+调研 /goal 触达面」全部废弃 | 用户 R5 纠正（2026-10-09）：/goal=内置命令输入框直接激活可迭代，自建=「乱七八糟的方向」；223 同法≥2 次命中（两次纠正），回炉重写 |
| 方向定稿=「机制面：任务分解固化为 Goal 单元表（任务名+目标+完整验证方式）+ 逐 goal 调度推进 66.3 门控 + /goal 只做映射供料呈示（40.3 口径不代调）」 | 兼容用户三次澄清全语义（R1 固化/R2 完整验证/R3 用内置 /goal/R4 分解调度逐个解决）；R3 手段=内置命令直接激活，技能层零程序化触达（实证 3 处无字段） |
| `new_rule: 66`（Rule 20.6 attest 自动预留） | 账本 65 已 landed（v149），66 空闲；attest 期 check-reserve 确认 |
| Goal 单元表=独立区块（核心目标达成裁决后），不动 S-unit 表 9 列契约 | recon Q4：check-plan-dispatch $7/$8 解析位固定，加列有风险；独立区块+模板锚 grep 校验零波及 |
| 隔离=worktree（自 master 创建） | check-conflicts 信号⑤命中（改运行中基础设施）；v150 教训：创建后 diff 关键文件 vs 部署位 |
| 本计划自我 dogfood：「🎯 Goal 单元表」区块已按新契约填写 G1-G6 | 66.1 载体首实例=本计划本身，终验即首验（Rule 51.5 盘点记录=本表 6 行） |
| veto: 同会话多目标观测定界（「多目标最可能是迭代桶面板」假设） | 用户 2026-10-10 否决：「不要纠结这个问题了，你没有能力去处理这个问题，跳过执行下一个」——不再推测，转入下一个遗留项；该观测面留待 ZCode 官方渠道（如适用）单独裁定，不阻塞本任务 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| R1 语义误判：「设定 goal 模式」读成「自建 goal 机制+调研 /goal 程序化接口」，设计 3 轮后 R5 纠正 | 1 | 2026-10-09 06:0x 方向回炉：findings superseded 初版方向，计划全文重写为「固化+内置 /goal 供料」；ledger error 事件已落 | → progress.md Error Log（根因=用户素材角色误判：内置命令当自建目标；预防=用户原话含「自带/输入/指令」词先确认载体=内置命令，Rule 63.2 本地检索链第一步+素材角色判定先声明） |

## Notes
- 每 goal 翻 complete 时供料呈示 /goal 对应证据锚（44.5 单行不循环）
- 既有 1-65 条款零改写（Rule 36.5 纯增量）；所有断言先 grep 实态再动手
- 合并回后 rule-reserve land 66 + 部署位三 diff 对账

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-09 06:xx | 主进程自判（B 类重规划：方向转向，非 drift-checker 派发点） | 全部 R/VC | 初版自建机制方向 veto，回炉定稿=固化+内置 /goal 供料；计划全文重写 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（P1 explore、P3 executor、P4 code-reviewer） |
| 主进程直做 Phase 清单 | P2（例外:①git 编排+②计划系统文件维护）、P5（例外:①git 编排+②簿记）——均 Rule 25.3 白名单内 |
| 委派率 | 0.6 < floor 0.7 → 全直做理由命中白名单①② → WHITELIST-EXEMPT 放行（25.4） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 05:xx | explore | 机制插入点与部署位侦察（8 问） | done | 8 问全答：仓布局/Rule 64-65 插入位/SKILL 3 处 1-65/S-unit 9 列契约/钉值清单 5 处+registry | plans/task-v151-goal-mode/subagent-state/01-explore-goal-mode-recon.md | Research Findings §1 | subagent-state/01-explore-goal-mode-recon.md | verify_done ☑ |
| 2 | 06:xx | explore | /goal 内置命令机制面实证 | done | 无程序化触达面：/opt/ZCode 无 goal 模块、~/.zcode/cli config 无字段、agent metadata 无结构化 goal（grep 命中均为 prompt 文本）；/goal=纯用户侧命令，与 40.3 口径一致 | 主进程 3 命令输出（ls ~/.zcode/cli + grep goal config + find /opt/ZCode -iname *goal* 空） | Research Findings §2 | subagent-state/02-explore-goal-command-mechanism.md（本检查点由主进程实证代写：子代理已取消，实证面=主进程直查 3 处均「不存在」合法形态） | verify_done ☑（实证代写登记） |
| 3 | 06:5x | code-assistant | S1 critical-rules 文末追加 Rule 66 六子条 | done | 848-860 +14 行，1-65 零改动；grep 6 子条=6 | subagent-state/03-executor-S1.md | Research Findings §3 | subagent-state/03-executor-S1.md | verify_done ☑ |
| 4 | 06:5x | executor | S2 模板 Goal 单元表+66.5 校验段 | done | 模板 +12/check-plan-dispatch +90；三态试跑全过（任务书 05-brief-S2 落盘重派，首派 inline 被 dispatch-guard 拦截） | subagent-state/04-executor-S2.md | Research Findings §3 | subagent-state/04-executor-S2.md | verify_done ☑ |
| 5 | 07:2x | executor | S3 check-complete [goal-gate] 段+SKILL 级联 | done | +46/+5-3；两态试跑符合语义（任务书 07-brief-S3） | subagent-state/06-executor-S3.md | Research Findings §3 | subagent-state/06-executor-S3.md | verify_done ☑ |
| 6 | 07:5x | executor | S4 新 selftest+registry+钉值级联 | partial→改派 | 5/6 pass；A5 回归 24 FAIL（66.5 档位语义波及 7 行为级 selftest）→ 22.3.1 provider 面改派 general-purpose（任务书 09-brief-S4） | subagent-state/08-executor-S4.md | Issues Encountered §1 | subagent-state/08-executor-S4.md | verify_done ☑（partial 登记） |
| 7 | 08:1x | general-purpose | S4b 66.5 档位三分支修正（D2 裁决方案①） | done | ΣFAIL=24→0（64 脚本）；正样本 66.5 违规=0、剥离区块负样本 rc=1 | subagent-state/10-executor-S4b.md | Research Findings §4 | subagent-state/10-executor-S4b.md | verify_done ☑ |
| 8 | 21:3x | code-reviewer | S6 全量 CR（101475f） | done | CHANGES_REQUESTED：F1 attest 逃生口未接线/F2 goal-gate 档位口径分叉/F3 死变量（V2 FAIL，余 V1/V3/V4/V5 PASS） | subagent-state/11-code-reviewer-S6.md | Issues Encountered §2 | subagent-state/11-code-reviewer-S6.md | verify_done ☑ |
| 9 | 21:5x | general-purpose | S6fix F1-F3 修复 | done | commit 6cf8cd7（+20/-5 三文件）；三态复测全过；回归 64 ΣFAIL=0 | subagent-state/13-executor-S6fix.md | Research Findings §4 | subagent-state/13-executor-S6fix.md | verify_done ☑ |
| 10 | 22:4x | general-purpose | S8 /goal 官方文档检索（原 web-search-agent 类型 provider 拒→22.3.1 改派登记） | done | 官方 4 页引句落盘（zcode.z.ai/cn+en/docs/goal 等）；本地 goal.md=用户自建命令区分面 | subagent-state/09-goal-official-docs.md | Research Findings §5 | subagent-state/09-goal-official-docs.md | verify_done ☑ |
| 11 | 23:1x | code-reviewer | S9 带官方文档重 CR | done | 必须修 0/建议增强 2（66.2 单目标约束消歧+plan 模式冲突提示）→主进程采纳→d56276e | subagent-state/15-code-reviewer-S9.md | Research Findings §5 | subagent-state/15-code-reviewer-S9.md | verify_done ☑ |

## 🔗 Chain 区块交接配置（可选）
<!-- 单 skill 单任务，删除本区块内容（区块保留） -->

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
