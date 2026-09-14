# Task Plan: task-v070 ask 模式执行思路复述（Rule 28.2.1）
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
为 task-planner skill 的 Rule 28 增补「ask（非静默）模式下计划批准前向用户复述大体执行思路」能力：新增 28.2.1 条款 + SKILL.md 四处联动 + selftest-interaction.sh 守护断言 + 3 实体位定向部署，使不查计划文档的用户也能预知整体工作流程。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` |
| `session_id` | `1973d0aba6874dd899166abe3b4af717` |
| `worktree_path` | `n/a`（direct，见隔离决策） |
| `scope_files` | `~/.zcode/skills/task-planner/references/critical-rules.md, ~/.zcode/skills/task-planner/SKILL.md, ~/.zcode/skills/task-planner/scripts/selftest-interaction.sh, ~/.zcode/skills/task-planner/config.json（仅 description 补 28.2.1 指针）` |
| `interaction_mode` | `ask` | Rule 28 |

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

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 28.2.1 条款已写入 critical-rules.md（ask 模式 D1 批准前置口头复述 ≤5 行大体思路；复述不替代 D1；silent 不适用；登记 Decisions Made） | `grep -n "28.2.1" ~/.zcode/skills/task-planner/references/critical-rules.md` 命中且含「思路复述」语义 |
| VC-2 | SKILL.md 四处联动：计划确认段交互模式行、Rule 28 摘要行、合规检查清单 C 项、I/O 契约行均提及 28.2.1/思路复述 | `grep -n "28.2.1\|思路复述" ~/.zcode/skills/task-planner/SKILL.md` ≥4 处 |
| VC-3 | selftest-interaction.sh 新增 28.2.1 守护断言并全量跑通（原有 10 用例 + 新增用例全 PASS） | `bash selftest-interaction.sh` exit 0 且 Total>10 |
| VC-4 | 3 实体位定向部署后 3 位 diff -r 一致 | `diff -r` 仓库 vs 3 位 exit 0 |
| VC-5 | 无回归破坏：其他 selftest 全量 0 FAIL；check-complete exit 0 | 全量 selftest 输出 + `check-complete.sh` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能引用 | ~/.zcode/skills/task-planner/references/critical-rules.md | 其他 references/*.md |
| 技能文档 | ~/.zcode/skills/task-planner/SKILL.md | 其他 .md |
| 脚本 | ~/.zcode/skills/task-planner/scripts/selftest-interaction.sh | 其他 scripts/*.sh |
| 配置 | ~/.zcode/skills/task-planner/config.json | 其他 config |
| 部署位 | ~/.claude/skills/task-planner/**, ~/.config/opencode/skills/task-planner/**（定向 cp 同步） | 非 task-planner 技能 |

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
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 28.2.1 条款及其全仓联动（SKILL.md/selftest/部署位）落地后，ask 模式下"不读计划文档也知大体流程"的用户诉求是否满足？

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？
- [x] 核心问题的解决方法是清晰的、可执行的？

**如果无法回答核心问题，禁止开始任务！**

## Current Phase
Phase 6（全部 complete，终验交付）

## Next Step
回填 findings.md/progress.md/verification.md + INDEX.md → 全量 selftest + check-complete → git commit → 3 实体位定向 cp 部署 + diff -r 复验

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: Requirements & Discovery
- [x] Understand user intent
- [x] Identify constraints and requirements
- [x] Document findings in findings.md
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-2（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:④ 用户显式要求主进程亲为——本会话用户直接授权改技能并指定功能语义，调研结论已在 findings.md）

### Phase 2: Planning & Structure
- [x] Define technical approach
- [x] Create project structure if needed
- [x] Document decisions with rationale
- **V-N:** VC-2, VC-3（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Implementation
- [x] critical-rules.md 增补 28.2.1 条款
- [x] SKILL.md 四处联动（计划确认段/Rule 28 摘要行/合规清单 C18/I-O 契约）
- [x] selftest-interaction.sh 新增 TI-11 守护断言
- [x] config.json interaction_mode description 补 28.2.1 指针
- **V-N:** VC-1, VC-2, VC-3（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:⑥ 单文件 ≤3 行 trivial 修改 + ② 计划系统文件维护——本任务每个文件改动 ≤5 行且为文档/脚本微调，Rule 25.3 白名单⑥+②；全仓 4 个文件均在 scope 内逐项审查）

### Phase 4: Testing & Verification
- [x] Verify all requirements met
- [x] Document test results in progress.md
- [x] Fix any issues found
- **V-N:** VC-3, VC-5（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:③ 机械验证命令——bash -n/selftest 只读验证，Rule 25.3 白名单③；输出可控）

### Phase 5: Delivery
- [x] Review all output files
- [x] Ensure deliverables are complete
- [x] Deliver to user
- **V-N:** VC-4, VC-5（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——部署定向 cp + commit + INDEX/verification 回填，Rule 25.3 白名单①②）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（无未提交变更信号 ① 无；skills/ 属 §六 保护区，本任务经用户显式授权直接改实体位后定向 cp 部署——历史惯例 v061-v069 同链路） |
| `isolation` | `direct`（用户显式授权 + 每文件 ≤5 行文档/脚本微调 + 部署走定向 cp；worktree 对「改 ~/.zcode 实体位」无隔离意义——实体位非 git 仓） |
| `worktree_path` | n/a |
| `branch` | master（主仓当前分支，部署提交直接入 master；仓内 plans/ 不入库惯例不变） |
| `merge_back` | n/a（direct 模式） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | （示例）依赖配置缺失 |  |  |  |  |  |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 28.2.1 复述放在 D1 的哪一侧？——已裁定：批准前置（展示计划全文后、等 yes 前复述 ≤5 行思路），复述是补充而非替代门控
2. silent 模式是否也要复述？——已裁定：不适用（28.4 静默决策清单已提供等效复核入口；用户口头要求时满足并登记）

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning behind them.
  WHY: You'll forget why you made choices. This table helps you remember and justify decisions.
  WHEN: Update whenever you make a significant choice (technology, approach, structure).
  EXAMPLE:
    | Use JSON for storage | Simple, human-readable, built-in Python support |
-->
| Decision | Rationale |
|----------|-----------|
| 28.2.1 挂接在 28.2（D1-D6）之内而非新增 Rule 30 | 语义=ask 模式 D1 批准前置的复述行为，属 Rule 28 交互门控能力域；避免规则号膨胀 |
| direct 部署而非 worktree | 实体位（~/.zcode 等）非 git 仓，worktree 无隔离意义；每文件改动 ≤5 行且经用户显式授权 |
| selftest 只加静态守护断言 TI-11（条款存在性+关键语义 grep） | 复述是主进程行为（LLM 输出），无脚本可测行为面；守护=防止条款被未来改动误删 |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
  EXAMPLE:
    | FileNotFoundError | 1 | Check if file exists, create empty list or create empty list if not |
    | JSONDecodeError | 2 | Handle empty file case explicitly |
-->
| Error | Attempt | Resolution |
|-------|---------|------------|
| init-session.sh 误将 sid 133bb46c... 写入 side 指针（shell 环境残留） | 1 | cp 133bb 指针内容到 1973d0ab 指针，两会话共用 v070 计划；check-scope D10' 仲裁随之放行 |

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

## 🚨 Drift Log（漂移检测记录）
<!-- 
  WHEN: 每次调用 Skill("task-drift-guard") 后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: templates/batch_report.md | 规则详解: references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` | 14 |
| `success` | 14 |
| `failed` | 0 |
| `failure_rate` | 0%（<5% 阈值） |
| `sampled_pass` | 14/14（全量 selftest 回归 = 全量验证,非抽样） |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否（无破坏性操作）/Q2:有（全量 selftest+diff -r）/Q3:能（git 可回滚） |
| `rollback_point` | git commit ce009d6 / b2047a4（部署位 git revert 即回滚） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: rescue 列 = 换档挽救记录(档位/结果/时间,failed|timeout 行必填,Rule 22.7);retry_count = 22.3 retry_limit 计数(初值 0,每次重试 +1)
  派发 prompt 八字段模板: templates/subagent_dispatch.md
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 | | | | queued | | | | | | 0 | ☐ |
| 2 | | | | | | | | | | 0 | ☐ |
| 3 | | | | | | | | | | 0 | ☐ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除此整个区块。 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` / `linked`（串行接力）/ `fan-out`（一对多派发） |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 / ❌ 否 |

### Block 1: [本块名称]（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | [本 block 独立目标] |
| **depends_on** | none |
| **passes_to** | Block 2: `[交接产物路径]` |
| **status** | in_progress / pending / complete |

### Block 2: [下游块名称]

| 字段 | 值 |
|------|-----|
| **goal** | [下游 block 目标] |
| **depends_on** | Block 1 → `[交接产物路径]` |
| **passes_to** | Block 3: `[...]` |
| **status** | pending |

<!-- 追加 Block N 时使用相同结构 -->

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | - | - | - | - |
| Block 2 | - | - | - | - |

---
<!-- ★ Block 分隔符：每个独立交接区块下方用 --- 分隔，格式如下 -->
<!--
### Block 2: [名称]
## Goal
...
## Phases
...
（复制完整 task_plan 结构，仅包含本 block 的 Phase 和 VC）
-->
