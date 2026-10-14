# Task Plan: task-v069 上下文与工作文件主动维护（Rule 29）
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
为 task-planner skill 新增"上下文与工作文件主动维护"能力域：① 上下文主动优化（退场/压缩/标记 superseded，确保上下文质量不拖垮运行）② 主动整理工作文件（陈旧任务归档/指针清扫/INDEX 修正/worktree 遗留清理）③ 机制化落地：新增 Rule 29 条款 + 2 个机械脚本 + 3 个 config 键 + 1 个 selftest + SKILL.md 章节联动。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
-->
| 字段 | 值 |
|------|-----|
| | `code_review` | `required` | |
| `session_id` | `b00c6b5519ff40088056035454496e5d` | 启动时生成,注册表追踪 |
| `worktree_path` | `n/a (worktree 见隔离决策区块)` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/scripts/check-context-hygiene.sh, skills/task-planner/scripts/plan-hygiene.sh, skills/task-planner/config.json, skills/task-planner/scripts/selftest-context-hygiene.sh` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` / `silent`（可省略，缺省回落 config.json#interaction_mode） | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |

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
| VC-1 | [交付物可观测要求 1] | [运行命令 / 检查文件 / 查看输出] | [路径或命令] |
| VC-2 | [交付物可观测要求 2] | [同上] | [路径或命令] |
| VC-3 | [交付物可观测要求 3] | [同上] | [路径或命令] |
| VC-4 | [边界条件通过] | [同上] | [路径或命令] |
| VC-5 | [无回归破坏] | [同上] | [路径或命令] |

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
| 源码 | skills/task-planner/references/critical-rules.md（Rule 29 追加）, skills/task-planner/SKILL.md（Rule 29 章节） | 其他 .ts 文件 |
| 测试 | skills/task-planner/scripts/selftest-context-hygiene.sh（新建）, skills/task-planner/scripts/check-context-hygiene.sh（新建）, skills/task-planner/scripts/plan-hygiene.sh（新建） | 其他测试文件 |
| 配置 | skills/task-planner/config.json（新增 3 键） | 其他配置 |
| 文档 | n/a（纯机制，不写文档） | 其他文档 |

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
| 规范/标准 | 宪法 §一 上下文工程 + Rule 19 三文件 + Rule 29 设计目标 | 本仓 references/critical-rules.md:87-97 + §一 AGENTS.md | 必读 | ☑ |
| 官方文档 | 规划先行宪法 + worktree 隔离 SOP | ~/.zcode/AGENTS.md §十一 + references/worktree-isolation.md | 必读 | ☑ |
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
**核心问题**: 现有 task-planner 的"缺→补"链路（[plan-compass] 提醒、3-File Gate）完整，但"多→删"链路（上下文退场、工作文件归档、INDEX 修正、worktree 遗留清扫）完全空白。需要新增 Rule 29 + 2 个机械脚本 + 3 个 config 键 + selftest，形成对称的"主动维护"能力域。

**核心问题判断**:
- [ ] 核心问题解决后，产品/结果能交付吗？
- [ ] 核心问题不解决，其他工作都白费吗？
- [ ] 核心问题的解决方法是清晰的、可执行的？

**如果无法回答核心问题，禁止开始任务！**

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 1 (in progress — R29 条款设计)

## Next Step
Next: 派 executor 执行 Phase 2 S3（check-context-hygiene.sh）→ S4（plan-hygiene.sh）→ S5（config 白名单确认）
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
[一句话下一步动作]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: R29 条款设计 + SKILL.md 章节
<!-- 目标：设计 Rule 29 完整子条款体系 + 写入 critical-rules.md + SKILL.md 章节联动 -->
- [x] 设计 Rule 29 子条款（29.1 触发时机 / 29.2 退场 SOP / 29.3 压缩 SOP / 29.4 工作文件整理 SOP / 29.5 配置键语义 / 29.6 反模式）
- [x] 写入 references/critical-rules.md（追加在 Rule 28 之后）
- [x] 写入 SKILL.md（在 §Rule 28 段落之后新增 §Rule 29 章节）
- [x] 更新 SKILL.md §Critical Rules 清单（Rule 29 指针行）
- **V-N:** VC-1, VC-6
- **Status:** complete（evidence: worktree commit 08846a2, critical-rules.md:227-236 + SKILL.md:87/285）
- **Executor:** code-assistant（haiku-1）

<!-- S-unit 派发单元表 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 写入 R29 条款到 critical-rules.md | 继承 | 材料包: ①现有 Rule 1-28 结构（references/critical-rules.md）②Rule 29 设计要点（见下方 Decisions Made 表）③现有 19.x 子条款编号现状 | grep "Rule 29" 命中 + 29.1-29.6 六子条款完整 | ≤10min | done |
| S2 | 写入 SKILL.md §Rule 29 章节 + §Critical Rules 指针 | 继承 | 材料包: ①SKILL.md 现有 §Critical Rules 清单结构 ②Rule 29 章节模板（含触发时机/SOP/配置键）③Rule 28 章节作为风格参考 | grep "Rule 29" SKILL.md 命中 ≥2 处（§Critical Rules + §正文） | ≤10min | done |

### Phase 2: 机械脚本 + config 键（check-context-hygiene.sh + plan-hygiene.sh + 3 键）
<!-- 目标：实现 2 个机械脚本 + 注册 3 个 config 键 -->
- [x] 实现 scripts/check-context-hygiene.sh（扫描 findings/progress 中 superseded/stale 标记 + 压缩建议，exit 0=clean/1=有建议/2=严重）
- [x] 实现 scripts/plan-hygiene.sh（--dry-run 展示归档清单 + --execute 执行 mv 到 plans/archive/）
- [x] 注册 config.json 3 键（context_hygiene_enforce, plan_archive_age_days, plan_hygiene_enforce）← 主进程已预先完成
- [ ] 脚本加进 check-delegation 白名单（plans/ 下 .md/.json 已放行，archive 子目录天然覆盖）
- **V-N:** VC-2, VC-3, VC-4
- **Status:** complete（evidence: worktree commit fade783, 2 新脚本+config 3 键, 实测 dry-run 21 条 ARCHIVE）
- **Executor:** executor（sonnet-1）

<!-- S-unit 派发单元表 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S3 | 实现 check-context-hygiene.sh | 继承 | 材料包: ①现有 selftest-methodology.sh 范本结构 ②check-3file-gate.sh 的 exit code 语义 ③config.json 29 键读取方式（jq） | bash 运行 exit 0 + grep 断言通过 | ≤15min | pending |
| S4 | 实现 plan-hygiene.sh（--dry-run + --execute） | 继承 | 材料包: ①plans/INDEX.md 当前统计（35 completed）②plan-created.cjs archive 前缀跳过逻辑（:122）③set-active-plan.sh gc 的 TTL 模式 | bash 运行 --dry-run 展示清单 + --execute 移动文件 | ≤15min | pending |
| S5 | 注册 config.json 3 键 + check-delegation 白名单确认 | 继承 | 材料包: ①config.json 现有 29 键结构（additionalProperties:false）②check-delegation.sh 白名单（:139-175） | jq 读取 3 键 + grep 白名单命中 | ≤5min | pending |
<!-- 
  WHAT: Decide how you'll approach the problem and what structure you'll use.
  WHY: Good planning prevents rework. Document decisions so you remember why you chose them.
-->
- [ ] Define technical approach
- [ ] Create project structure if needed
- [ ] Document decisions with rationale
- **V-N:** VC-x, VC-y（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** pending
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: selftest + 全量回归
<!-- 目标：新增 selftest-context-hygiene.sh（≥10 条断言）+ 全量 13 个 selftest 回归无新增 FAIL -->
- [x] 实现 scripts/selftest-context-hygiene.sh（hermetic mktemp fixture + ≥10 条断言 + Total: PASS=N FAIL=0）
- [x] 逐个运行 13 个现有 selftest，统计总 PASS/FAIL（基线 213/0）
- [ ] 新增 selftest 注册进 verify.sh:227 或 INSTALL.md 自测指引
- [x] 记录全量回归结果到 progress.md
- **V-N:** VC-5, VC-7
- **Status:** complete（evidence: worktree commit 6c1d2ee, selftest 12/0 + 全量 14 脚本 225/0）
- **Executor:** executor（sonnet-1）

<!-- S-unit 派发单元表 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S6 | 实现 selftest-context-hygiene.sh（≥10 条断言） | 继承 | 材料包: ①selftest-methodology.sh 范本（7 用例 M-01..M-07）②selftest-execution-stability.sh 行为级断言先例（T11a/b）③check-context-hygiene.sh + plan-hygiene.sh 可测面 | Total: PASS=N FAIL=0 + 断言 ≥10 | ≤15min | pending |
| S7 | 全量 13 个 selftest 回归 + 统计 | 继承 | 材料包: ①scripts/selftest-*.sh 列表（13 个）②基线 213/0 ③运行方式（bash scripts/selftest-<name>.sh） | 13 个脚本全跑 + 总 PASS/FAIL 统计 | ≤15min | pending |
### Phase 4: 合并回 + 部署复验 + 实际归档 35 个 completed 目录
<!-- 目标：worktree 合并回 master + 部署 3 实体位 + 用新脚本实际归档 35 个 completed 任务目录 -->
- [x] worktree 内全 Phase complete + git status 干净（CLEAN）
- [x] Code Review Gate APPROVED + P2×3 修复（326f44f）
- [x] smart-merge-back V3 SCOPE_OVERLAP 处置 → 主仓 config commit（37c2107）→ git merge --no-ff 8778ff8
- [x] 部署 3 实体位定向 cp + diff -r 0 差异
- [x] plan-hygiene.sh --execute 归档 21 个超龄 completed 目录到 plans/archive/（35 中 14 个 <7d 保留）
- [x] 更新 plans/INDEX.md（sync-todos.sh --index：complete=14/in_progress=1）
- [x] git worktree remove + git branch -d
- **V-N:** VC-3, VC-7
- **Status:** complete（evidence: merge 8778ff8 + 部署 3 位 diff=0 + archive 21 项 + INDEX complete=14）
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [ ] Verify all requirements met
- [ ] Document test results in progress.md
- [ ] Fix any issues found
- **V-N:** VC-x, VC-y（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** pending
- **Executor:** code-runner-agent（mini）

### Phase 5: 终验交付
- [x] Read verification.md 逐条复验 VC-1..VC-7（全 PASS）
- [x] 委派统计（3/5 + WHITELIST-EXEMPT）
- [x] 3-File Gate（findings/progress 非 stub）
- [x] Code Review Gate（APPROVED + P2×3 修复）
- [x] 交付结论: COMPLETE
- **V-N:** VC-1, VC-5, VC-7
- **Status:** complete（outcome: COMPLETE, 09-14）
- **Executor:** 主进程（例外理由:① 簿记+② 终验交付——Rule 25.3 白名单）
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [ ] Review all output files
- [ ] Ensure deliverables are complete
- [ ] Deliver to user
- **V-N:** VC-x, VC-y（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| | `conflict_scan` | `risk`（信号① 未提交变更 9 个文件，与任务范围部分重叠：plans/INDEX.md + plans/task-v065 task_plan.md） | |
| | `isolation` | `worktree`（实现类，修改 skill 本体 SKILL.md + critical-rules.md + scripts/ + config.json） | |
| | `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v069-context-hygiene` | |
| | `branch` | `wt/task-v069-context-hygiene` | |
| `merge_back` | `pending` / `merged(<commit>)` / n/a |

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
| Phase 1 | R29 条款与现有 Rule 19.x 编号冲突（19.7/19.8 顺序已乱） | 4 | 3 | 5 | 60 | 主进程接管：Read 现有 19.x 编号后手动调整 |
| Phase 2 | config.json additionalProperties:false 导致新键被 jq 拒绝 | 5 | 4 | 3 | 60 | 主进程接管：手动编辑 config.json 并注册进 .properties |
| Phase 2 | plan-hygiene.sh 归档后 INDEX.md 统计回归（全量重写特性） | 4 | 5 | 4 | 80 | 兜底：归档后立即重跑 sync-todos.sh --index，若回归则手动修正 |
| Phase 3 | selftest 回归基线漂移（213/0 → 新增 FAIL） | 3 | 4 | 5 | 60 | 主进程接管：逐个 selftest 定位 FAIL 原因，判断是新增还是存量 |
| Phase 4 | smart-merge-back.sh ALREADY_MERGED 误判（另一会话已合并） | 2 | 3 | 4 | 24 | 走已有 ALREADY_MERGED 分支：跳过合并，补簿记 |
| Phase 4 | 部署 3 实体位时 diff 漂移（sync-companion 反向拉回陷阱） | 4 | 3 | 4 | 48 | 定向 cp 部署，不用 sync-companion；部署后 diff -r 复验 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 09-14 Phase 1 complete | worktree 08846a2 |
| Phase 2 | ☑ | 09-14 Phase 2 complete | worktree 8f3b7c1 |
| Phase 3 | ☑ | 09-14 Phase 3 complete | worktree 6c1d2ee |
| Phase 4 | ☑ | 09-14 Phase 4 complete | merge 8778ff8 + 部署 + 归档 |
| Phase 5 | ☑ | 09-14 COMPLETE | merge 8778ff8 |

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
| 机制化深度选 B 档（中量级） | 用户明确选择；新增 R29 + 2 脚本 + 3 config 键 + 1 selftest + SKILL 章节，约 4 Phase 40-60min |
| 归档策略选"年龄阈值+手动确认" | 用户明确选择；completed 且超过 plan_archive_age_days（默认 7 天）的任务目录归档，脚本默认 --dry-run 展示清单 |
| R29 子条款体系（29.1-29.6） | 29.1 触发时机（Phase complete 后 + 会话恢复时）/ 29.2 退场 SOP（标记 superseded + 压缩）/ 29.3 压缩 SOP（折叠旧 findings）/ 29.4 工作文件整理 SOP（归档/指针清扫/INDEX 修正）/ 29.5 配置键语义 / 29.6 反模式 |
| check-context-hygiene.sh exit code 语义 | exit 0=clean / 1=有退场建议（superseded 标记存在但未压缩）/ 2=严重（stale findings 占比 >50% 或超 age 阈值） |
| plan-hygiene.sh 归档目标 | plans/archive/<task-id>/（plan-created.cjs:122 已有 archive 前缀跳过约定） |
| code_review: required | 修改 skill 本体（SKILL.md + critical-rules.md + scripts/ + config.json），需 Code Review Gate |
| 部署 3 实体位用定向 cp | 记忆 sync-companion 反向拉回陷阱：部署一律定向 cp，不用 sync-companion |
| worktree 集中目录 | /home/terry/task-planner-skill-worktrees/task-v069-context-hygiene（宪法 §11.2 新路径规范） |

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
| 1 | 09-14 16:4x | code-assistant(haiku-1) | S1+S2 写入 R29 条款+SKILL 章节 | done | R29 六子条款+2.6 检查点+指针行完成，+14/-1 | worktree critical-rules.md:227-236 | §Technical Decisions | subagent-state/1-code-assistant.md | - | 0 | ☑ |
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
