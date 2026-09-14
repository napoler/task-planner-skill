# Task Plan: task-v071 共享内容认领追踪集成（Rule 30 + progress-tracker 接入）
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
让 task-planner 设计期主动识别「共享内容维护」场景（本次只认领一部分的发布/优化任务），接入用户已创建的 progress-tracker skill（.zcode/ledger/ JSONL 账本）作为项目级认领追踪权威源：30.1 识别条件 + 30.2 创建/复用语义 + 30.3 认领登记 + 30.4 防冲突，杜绝后期重复混乱。

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
| `scope_files` | `~/.zcode/skills/task-planner/references/critical-rules.md, ~/.zcode/skills/task-planner/SKILL.md, ~/.zcode/skills/task-planner/config.json, ~/.zcode/skills/task-planner/scripts/selftest-shared-tracker.sh(新建), ~/.zcode/skills/task-planner/templates/shared-tracker.md(新建), ~/.zcode/skills/task-planner/references/skill-collaboration.md` |
| `interaction_mode` | `ask` | Rule 28 |
| `shared_tracker_topic` | `task-planner-maintenance` | 本任务自身的共享追踪主题（.zcode/ledger/task-planner-maintenance/） |

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
| VC-1 | 30.x 条款已写入 critical-rules.md（30.1 识别条件/30.2 创建复用/30.3 认领登记/30.4 防冲突，权威源=progress-tracker `.zcode/ledger/` 账本，不另造新文件） | `grep -n "30\.1\|30\.2\|30\.3\|30\.4" ~/.zcode/skills/task-planner/references/critical-rules.md` 命中 4 行 |
| VC-2 | SKILL.md 联动（Critical Rules 摘要行 + 设计期检查点 + References 表 progress-tracker 行）且 skill-collaboration.md 登记协同关系 | `grep -n "30\|progress-tracker" ~/.zcode/skills/task-planner/SKILL.md` ≥3 处；skill-collaboration.md 含 progress-tracker 行 |
| VC-3 | selftest-shared-tracker.sh 新建并全量跑通（30.x 存在性 + 语义锚点 + config 键 + 模板存在） | `bash selftest-shared-tracker.sh` exit 0 |
| VC-4 | 3 实体位定向部署后 3 位 diff -r 一致 + 双仓 commit+push | diff -r exit 0；`git rev-parse HEAD origin/master` 一致；zcode 仓同 |
| VC-5 | 无回归破坏：全量 selftest 0 FAIL；check-complete exit 0 | 全量 selftest 输出 + check-complete.sh |

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
| 技能引用 | ~/.zcode/skills/task-planner/references/critical-rules.md（Rule 30 新增） | 其他 references/*.md |
| 技能文档 | ~/.zcode/skills/task-planner/SKILL.md（3 处联动） | 其他 .md |
| 配置 | ~/.zcode/skills/task-planner/config.json（shared_tracker_enforce 键） | 其他 config |
| 脚本 | ~/.zcode/skills/task-planner/scripts/selftest-shared-tracker.sh（新建） | 其他 scripts/*.sh |
| 模板 | ~/.zcode/skills/task-planner/templates/shared-tracker.md（新建） | 其他 templates/*.md |
| 协同 | ~/.zcode/skills/task-planner/references/skill-collaboration.md（progress-tracker 行） | 其他 references |
| 部署位 | ~/.claude/skills/task-planner/**, ~/.config/opencode/skills/task-planner/**（定向 cp） | 非 task-planner 技能 |
| 进度账本 | <project>/.zcode/ledger/task-planner-maintenance/（本任务自身的追踪条目） | 其他主题 |

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
**核心问题**: Rule 30 + progress-tracker 接入后，「共享内容维护类任务」是否在设计期被识别并复用/创建 .zcode/ledger/ 账本，杜绝后期重复混乱？

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？
- [x] 核心问题的解决方法是清晰的、可执行的？

**如果无法回答核心问题，禁止开始任务！**

## Current Phase
Phase 5（全部 complete，终验交付）

## Next Step
填写 Phases/隔离决策/Decisions → D1 复述思路(28.2.1) → 等待 yes → attest → 执行

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 设计裁定（30.x 措辞 + config 键 + 模板 + selftest 设计）
- [x] 敲定 30.1-30.5 措辞（30.1 识别条件 / 30.2 创建复用 / 30.3 认领登记 / 30.4 防冲突 / 30.5 机制，权威源=progress-tracker `.zcode/ledger/` 账本，不另造新文件）
- [x] 敲定 config 键 shared_tracker_enforce（默认 warn）+ templates/shared-tracker.md + selftest-shared-tracker.sh 断言设计
- [x] findings.md 记录设计决策
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（例外理由:② 设计裁定+计划系统文件——Rule 25.3 白名单②）

### Phase 2: 实现 S1（6 文件）
<!-- 计划创建时已批准；执行中 -->
- [x] critical-rules.md 新增 Rule 30（30.1 识别/30.2 创建复用/30.3 认领登记/30.4 防冲突/30.5 机制）
- [x] SKILL.md 3 处联动：Critical Rules 摘要行（Rule 30）+ 设计期检查点（计划确认段后「共享内容追踪检查」行）+ References 表 progress-tracker 行
- [x] config.json +1 键 shared_tracker_enforce（warn，32→33 键）
- [x] templates/shared-tracker.md 新建（认领追踪区块模板：topic/target/status/认领 task-id/认领时间/effect）
- [x] scripts/selftest-shared-tracker.sh 新建（≤60 行：30.x 存在性+语义锚点 grep+config 键+模板存在+progress-tracker 技能存在探针）
- [x] references/skill-collaboration.md 登记 progress-tracker 协同行（「嵌入」族：共享内容维护场景调用入口）
- [x] dogfood：本任务自身 .zcode/ledger/task-planner-maintenance/ 追加 1 条 in_progress 条目（30.3 实证）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由:⑥ 单文件 ≤40 行文档/脚本微调 + ② 计划系统文件——Rule 25.3 白名单⑥②；6 文件均在 scope 内逐项审查）

### Phase 3: 回归验证
- [x] 全量 selftest（15 脚本含新增 shared-tracker）0 FAIL
- [x] check-complete.sh exit 0（3-File Gate exit 0；check-complete 终验留 Phase 4 交付段）
- [x] 修复回归问题（若有）
- **V-N:** VC-3, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:③ 机械验证命令——Rule 25.3 白名单③）

### Phase 4: 交付（部署 + 双仓 push + 簿记）
- [x] 3 实体位定向 cp（~/.zcode canonical + ~/.claude + ~/.config/opencode，仅 Phase 2 变更文件）+ diff -r 复验
- [x] canonical 仓 commit 760c2a3 + push origin/master；~/.zcode 仓 commit bf43250 + push origin/main
- [x] 三文件回填 + INDEX.md + ledger 条目翻 done + 记忆文件 + attest 终锁
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单①②）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（skills/ 属 §六 保护区；经用户显式授权直接改实体位 + 定向 cp 部署，v070 先例） |
| `isolation` | `direct`（实体位非 git 仓 + 每文件 ≤40 行 + 用户显式授权；worktree 对「改 ~/.zcode 实体位」无隔离意义） |
| `worktree_path` | n/a |
| `branch` | master（canonical 仓）/ main（~/.zcode 仓），直接提交 |
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

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 追踪文件放哪？——已裁定：复用 progress-tracker 的 `.zcode/ledger/<topic>/<topic>.jsonl`（用户已建，不另造 shared-tracker/ 目录）
2. 规则号用 30 还是挂 29.x？——已裁定：Rule 30（30 是「共→认领」语义独立；29 是「多→退场」，混挂语义污染）

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
| 追踪权威源 = progress-tracker skill（.zcode/ledger/ JSONL） | 用户已创建该技能，schema 已定（topic/target/action/status/effect），Rule 30 只做「识别+调用」不重造文件 |
| Rule 30 独立（不挂 29.x） | 「共→认领」与 29「多→退场」语义不同；独立规则号防域膨胀 |
| 本任务自身也登记 .zcode/ledger/task-planner-maintenance/ | dogfood 验证 Rule 30 可用 + 为后续 task-planner 维护任务提供复用入口 |
| 不加新 hook（沿用门控+指针范式） | 30.x 是设计期流程层强制（计划确认前检查），selftest 静态守护防误删，与 v063/v068 范式一致 |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
  EXAMPLE:
    | FileNotFoundError | 1 | Check if file exists, create empty list if not |
    | JSONDecodeError | 2 | Handle empty file case explicitly |
-->
| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

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
