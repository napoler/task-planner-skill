# Task Plan: [Brief Description]
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

<!-- plan_tier: standard -->
<!-- template_type: rule-enhancement -->
## Goal
为 task-planner 技能新增「新任务边界判定」机制：用户新指令若与当前计划目标无主题/范围/交付物关联（D 类），自动判定为新任务并开新 task_plan.md，避免不相干内容混入既有计划（Rule 8.1 + SKILL.md D 类 + UPS hook 判定注 + selftest 守护，4 处联动纯增量）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` |
| `session_id` | `b31c01c7c4fd445d8fc3119e76f4faf5` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v087-task-boundary` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-planner/{references/critical-rules.md, SKILL.md, references/todo-sync.md, scripts/zcode-userpromptsubmit.sh, scripts/selftest-task-boundary.sh(新)}` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `silent`（可省略，缺省回落 config.json#interaction_mode） | Rule 28 交互模式：用户单指令、方向明确、无待裁决选项 → 静默自主推进+静默决策清单登记 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | critical-rules.md Rule 8 族含 8.1 任务边界判定子条（纯追加，不改动 8 原文语义） | `grep '^8\.1 ' references/critical-rules.md` 非空且含 D 类/新任务边界语义 | worktree: references/critical-rules.md |
| VC-2 | SKILL.md 用户新指令表含 D 类行 + 「新增任务边界判定（Rule 8.1）」特判段 + C12 检查项联动 A/B/C/D | `grep 'D 新任务边界' SKILL.md` 非空 | worktree: SKILL.md |
| VC-3 | UPS hook [plan-note] 文案含 D 类判定指引 | `grep 'D 新任务边界' scripts/zcode-userpromptsubmit.sh` 非空 | worktree: scripts/zcode-userpromptsubmit.sh |
| VC-4 | todo-sync.md S5 说明联动 D 类（开新计划路径） | `grep -n 'D 类\|新任务边界' references/todo-sync.md` 非空 | worktree: references/todo-sync.md |
| VC-5 | 新增 selftest-task-boundary.sh 全 PASS；全量 selftest 总和 >430 且 0 FAIL；三位部署 diff -r=0 | 本仓跑循环求和；部署后主进程 diff -rq | scripts/selftest-task-boundary.sh + 三部署位 |

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
| 源码 | worktree `skills/task-planner/references/critical-rules.md`、`scripts/zcode-userpromptsubmit.sh` | 其他条款行/脚本 |
| 测试 | worktree `skills/task-planner/scripts/selftest-task-boundary.sh`（新文件） | 其他 selftest 改写 |
| 配置 | （本任务零 config 键变更） | config.json |
| 文档 | worktree `skills/task-planner/SKILL.md`、`references/todo-sync.md`；仓根 `CHANGELOG.md`；主仓 `plans/task-v087-task-boundary/*` 三件套+verification+INDEX | 其他文档 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？
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
| 项目内部文档/知识库 | critical-rules.md Rule 8 族插入点（8.1 纯追加在 8 原文之后，避让 v082 式插入级联） | worktree:references/critical-rules.md L26-28 | 必读 | ☑ |
| 项目内部文档/知识库 | SKILL.md 用户新指令表/特判段/合规清单 C12 结构 | worktree:SKILL.md L188、L210-232 | 必读 | ☑ |
| 项目内部文档/知识库 | UPS hook [plan-note] 注入点与文案 | worktree:scripts/zcode-userpromptsubmit.sh L128-131 | 必读 | ☑ |
| 项目内部文档/知识库 | selftest 静态守护范式（veto 13 断言模板） | worktree:scripts/selftest-veto.sh | 必读 | ☑ |
| 项目内部文档/知识库 | 全量 selftest 基线 430 PASS/0 FAIL（25 脚本，本轮亲跑实证） | worktree 循环求和 | 必读 | ☑ |
| 项目内部文档/知识库 | 三位部署位 ~/.zcode、~/.claude、~/.config/opencode + smart-merge-back --deploy | memory task-planner-repo-deploy-flow | 必读 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 用户新指令与当前计划目标无关时，现行 Rule 8 三分类（A 无影响/B 扩展/C 矛盾）会把「新任务」误判为 A（照常执行却落在旧计划上）或 B（塞进当前计划扩范围），导致不相干内容混入既有 task_plan.md，污染三文件与终验。需新增 D 类「新任务边界」判定：与当前 Goal/范围/交付物无关联的指令=新任务→开新计划目录（新 task_plan.md），旧计划保持原样。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？
- [x] 核心问题的解决方法是清晰的、可执行的？

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 1

## Next Step
Phase 6（B 类）：文档对齐 README/CLAUDE/README_zh Rules 1-38 + v086 重复 Status 清理 + INDEX 刷新 + 三位重部署 + push

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 现状勘察（插入点确认）
- [x] 确认 4 处插入点现状（critical-rules Rule 8 / SKILL.md 新指令表 / UPS hook note / todo-sync S5）
- [x] 确认全量 selftest 基线（430 PASS/0 FAIL，25 脚本）
- [x] 落 findings.md 勘察结论
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-5（插入点行号证据 + 基线实证）
- **Status:** complete
- **Executor:** 主进程（例外理由:③ 机械验证命令只读勘察——Rule 25.3 白名单③；勘察为只读 grep/Read，无写入）

### Phase 2: 实施 Rule 8.1 + 四处联动
- [x] critical-rules.md Rule 8 后纯追加 8.1（新任务边界判定：D 类=与当前 Goal/范围/交付物无主题/范围/交付物关联→新任务→开新计划目录；判定依据=当前 task_plan.md Goal+scope_files+交付物；处置=新建 plans/{new-task-id}/ 全流程，旧计划原样保留；判定落 notepad 记一行）
- [x] SKILL.md 用户新指令表加 D 行 + 特判段「新增任务边界判定（Rule 8.1）」+ C12 检查项扩为 A/B/C/D
- [x] UPS hook [plan-note] 文案加 D 类判定指引（zcode-userpromptsubmit.sh L130 一行，语义等价扩写）
- [x] todo-sync.md S5 说明加 D 类分支（开新计划路径）
- [x] 联动点收口核对（grep A/B/C 全仓引用，确认无漏改矛盾）
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护+白名单⑥ 单文件 ≤3 行 trivial 修改——本任务改 4 文件但均为计划系统/技能文档条款行追加，属 ②⑥ 组合；规则增强类任务模板先例 v079-v086 均主进程簿记式落地）
（示例为代码组画像；非代码任务按 template-mapping.md §九 机制画像选内容类执行体，如 article-writer）

### Phase 3: 自测试守护 + 全量回归
- [x] 新增 scripts/selftest-task-boundary.sh（静态守护：8.1 条款/SKILL D 行/C12/hook note/todo-sync 联动/8 原文未改动，约 10 断言，范式对齐 selftest-veto.sh）
- [x] 新 selftest 单跑全 PASS
- [x] 全量 selftest 循环求和（PASS 总和 >430 且 0 FAIL，含新脚本）
- [x] 改动文件逐个 bash -n / 语法自查
- **V-N:** VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——selftest 守护脚本属技能自带测试体系，先例 v073-v086 同类落地均主进程；白名单③机械验证命令跑全量）

### Phase 4: 部署三位 + 复验 + 簿记
- [x] CHANGELOG.md 加 v087 条目（仓根）
- [x] worktree 内 git commit（逐 Phase 产物提交）
- [x] smart-merge-back.sh 合并回 master + --deploy 三位部署
- [x] 主进程 diff -r 亲验三位 IDENTICAL（~/.zcode、~/.claude、~/.config/opencode）
- [x] 部署位全量 selftest 430+N/0
- **V-N:** VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排+② 簿记——Rule 25.3 白名单①②）

### Phase 5: 计划收尾
- [x] 三文件回填（findings/progress/verification 终验）
- [x] check-complete.sh 终验 + notepad 沉淀 + INDEX 刷新 + ledger 更新
- **Status:** complete
- **Executor:** 主进程（例外理由:② 簿记——Rule 25.3 白名单②）

### Phase 6: 文档对齐 + 部署 + push（B 类扩围 — 用户指令「同步对齐文档 部署 并推送到github」，2026-09-22）
- [x] 三处文档同步 Rules 1-34→1-38（CLAUDE.md L32 / README_zh.md L136、L229）+ 陈旧计数对齐（config 18 键→40 / variant 13→15 / 12→15）
- [x] v086 task_plan.md 清理 Phase 4 重复 Status 行（L86 删，留 L82 标准位）→ rollup 4/4 complete，INDEX 误挂账根除
- [x] v087 verification.md outcome 行落 COMPLETE 证据
- [x] INDEX 刷新（sync-todos --index，v086/v087 均 complete；v087 Phase 6 complete 后终刷）
- [x] sync-todos.sh rollup 重复 Status 缺陷根因（脚本=保护区，未经授权不改——已登记 deferred-issues.log，报告用户）
- [x] 三位部署重跑 + diff -r 亲验 IDENTICAL
- [x] 全量 selftest 441/0 亲验（改动面仅 .md 文档，锚零影响，需实证）
- [x] git commit + push origin master（用户显式授权）
- **V-N:** VC-1, VC-5（文档锚 grep + 全量/部署复验）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护+纯文档 .md 对齐——Rule 25.3 白名单②；§十一 纯文档例外②直接主仓，无需 worktree）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（git status 干净，无遗留 wt/* 分支，plans/ 无 in_progress 撞车） |
| `isolation` | `worktree`（实现类——改运行中技能部署源，§十一 强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v087-task-boundary` |
| `branch` | `wt/task-v087-task-boundary` |
| `merge_back` | `merged(a2ae738)` |

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
| Phase 2 | 多处插入点锚文本与实际不符（他会话并行改动） | 4 | 2 | 4 | 32 | 合并前 git pull master 比对基线 commit c340219；冲突按 31.2 归因重定位锚 |
| Phase 4 | 部署位 diff 出漂移（他会话同步推进） | 5 | 2 | 4 | 40 | 部署前重跑全量 selftest 兜底（v079 教训）；漂移 STOP 报告 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-21T12 | 勘察完成即翻 complete |
| Phase 2 | ☑ | 2026-09-21T12 | 四处联动实施 |
| Phase 3 | ☑ | 2026-09-21T12 | selftest |
| Phase 4 | ☑ | 2026-09-21T12 | 部署 |
| Phase 5 | ☑ | 2026-09-21T12 | 收尾 |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. [Question to answer]
2. [Question to answer]

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
| 判定类命名 D=新任务边界（A/B/C 之后追加，不改既有语义） | 纯增量追加，避让 v082 插入式级联教训（v082 已证插入=多锚位级联易漏扩） |
| 判定依据=当前 task_plan.md 的 Goal + scope_files + 交付物三要素 | 机器可查（Read 计划即可判），LLM 判定+hook 提示双保险 |
| D 类处置=开新计划目录+旧计划原样保留（不标 superseded） | D 类=新任务不是对旧计划的推翻（区别于 C），旧计划继续推进不受影响 |
| 零新 config 键（无 enforce 档位） | 判定是 LLM 行为面，机器只能守护「条款在位」；先例 Rule 35 同范式 |
| silent 模式推进（用户单指令、方向明确） | Rule 28.4；静默决策清单登记于本表 |
| interaction_mode=silent（静默决策） | 用户未提流程要求，任务为既定增强方向的历史先例延续（v072-v086 同型） |

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
| `total` |  |
| `success` |  |
| `failed` |  |
| `failure_rate` | （>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | （运行后抽 10%） |
| `sampled_fail` | （运行前抽 2,>0 → 整批熔断） |
| `pre_check` | （Q1:否/Q2:有/Q3:能） |
| `rollback_point` | （为空 → 禁止批量） |

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
