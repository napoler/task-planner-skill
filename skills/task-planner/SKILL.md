---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch"
user-invocable: true
references:
- reference.md: Manus context engineering 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件
- references/critical-rules.md: Critical Rules 核心域——Rules 1-94 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83，含 Rule 82 分层纪律 + Rule 83 通道快速失败；其余 75 条按域归 11 卫星，见文末「卫星路由表」）
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复）
- references/completion-gate.md: 子代理验证（指针；全文→卫星 `../verification-gate/` Rule 84.4，2026-10-14 task-v173 迁移）
- references/goal-gate.md: Goal Gate + VC 规则（指针；全文→卫星 `../verification-gate/` Rule 84.3，2026-10-14 task/v173 迁移）
- references/todo-sync.md: 原生 Todo 同步契约（S1-S5 强制同步时机 + 映射规则 + hook 提醒响应协议）
- references/worktree-isolation.md: 冲突分析与工作树隔离契约（实现类默认首选 + 合并回合约）
- references/methodology.md: 思维方法论 T1-T5 指针 + 内容质量 Q3/Q4 + FMEA/Poka-Yoke
- 卫星技能 task-dispatch: 子代理派发/拆分/调度/超时兜底/返回校验/代码编辑隔离（`../task-dispatch/`，Rule 12,13,14,21,22,23,25,46,52,59,68）
- 卫星技能 task-discipline: 执行纪律/错误闭环/批量质量/反思/注释/可靠性/能力沉淀/变更吸收（`../task-discipline/`，Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-76,85,86,87,88,89,90,92,93,94）
- 卫星技能 media-planner: 媒体制作派发/单元线并行/内容分级（`../media-planner/`，Rule 47,49,50）
- 卫星技能 verification-gate: 任务验证全链路——VC 可执行化设计/执行期 V-N 校验/终验 VC 复验/子代理验证/统一验证入口（`../verification-gate/`，Rule 84）
# hooks: <TOOL-ADAPTED — stub files per tool register hooks via platform-specific config>
# See: ~/.claude/skills/task-planner/SKILL.md (Claude Code) / ~/.zcode/skills/task-planner/SKILL.md (ZCode)
model: opus
---

**[P0]** 禁止跨项目污染 · 禁止虚构 · 修改前必须 Read 并展示 diff · 技能文件修改需逐项授权。发现缺失=STOP 报告，禁止补全。

**Goal**：产出结构化 `task_plan.md`（含 Phases/VC/V-N），按 phase 推进，全 phase complete 后逐条复验 VC，交付 COMPLETE/PARTIAL/BLOCKED。

## 定位：核心 = 四文件罗盘管理（task-v171 分层后）

> **核心定位**：本技能 = **四文件罗盘的唯一管理域**——`task_plan.md`（目标维：状态与指针）/ `findings.md`（决策维：调研结论与证据）/ `progress.md`（进度维：动作与测试）/ `knowledge-brief.md`（知识维：可复用知识底座）四文件 = 主代理↔子代理数据流转**唯一协议介质**（Rule 62.1）；`verification.md`（终验维）与 `user-session-log.md`（用户原话维，append-only 只写不改，Rule 80）同属记录文档域。子代理上下文=RAM，四文件=Disk。
> **非核心域已分层至卫星**：派发/拆分/调度→`task-dispatch`；执行纪律/错误闭环→`task-discipline`；媒体制作→`media-planner`；其余见文末「卫星路由表」。分层纪律=Rule 82（建制/边界/回归防线：禁回潮、禁镜像副本）。

**四文件写入分流铁律**：状态与指针→task_plan.md（控制面板：只放目标/Phase 状态/VC/范围/一行摘要，Rule 19.6）；调研与结论→findings.md；动作与测试→progress.md；可复用知识→knowledge-brief.md。外部内容只进 findings.md（Rule 20.2）；结论禁只留会话记忆（Rule 19.1）。

## 计划制作循环

- [ ] [M] **初始化（哨兵机制）— 机械子动作**：跑脚本建目录/设 env/校验在位/清哨兵
  > `[2026-09-10 task-planrequired-race]` 哨兵会话私有化：SessionStart 写会话私有哨兵 `plans/.plan_required_side/<sidkey>.plan_required`（sidkey=uuid core）；legacy `<root>/.plan-required` 仅兼容读取
  - 运行 `node --experimental-strip-types scripts/session-catchup.ts` 检测中断恢复点；创建 `plans/{task-id}/`，运行 `bash scripts/init-session.sh`（trivial 判定：≤15min ∧ ≤2 文件 ∧ 单模块 ∧ 非④排除 → `TASK_AUTO_TIER=1` 四条件闸门自动降 mini，Rule 38.6）
  - **auto-tier env 变量（主进程调用 init 前以 env 提交任务体量事实）**：`TASK_AUTO_TIER=1`（opt-in 开关）+ `TASK_EST_MINUTES`（预估分钟）+ `TASK_SCOPE_FILES`（scope 文件数）+ `TASK_SCOPE_MODULES`（模块数）+ `TASK_TIER_EXCLUDE=1`（④排除）。[task-perf-opt Change #1] 新增 `TASK_SCOPE_FILE_LIST`（逗号分隔的文件名列表，如 `fix-bug.sh`）与 `TASK_EST_LINES`（预估变更行数）两个 env：主进程从用户指令解析 scope 文件列表与预估行数以 env 传入，init 在 auto-tier 块读取；四条件 ∧ 单文件代码（.sh/.ts/.cjs/.js/.py/.json）∧ ≤3 行 → 第四条件命中 mini+L0+trivial 三文件缩减档（Rule 38.6）
  - **会话隔离指针**：活跃计划经 `resolve-plan-dir.sh [root] [sid]` 双参解析（side 指针优先于全局 fallback；残留由 `set-active-plan.sh gc` 清扫）
  - **模板优先级**（init-session.sh 自动处理）：项目级 `.claude/plan-templates/` 或 `.zcode/plan-templates/` 覆盖 → 兜底 `<platform-home>/skills/task-planner/templates/`（选型权威源=卫星 `plan-template-kit`，Rule 16/34）
  - **验证**：7 文件在位（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief/user-session-log，Rule 80）
  - **S1 同步**：`bash scripts/sync-todos.sh --json` → 每 Phase 一条原生 Todo；**禁止只建计划不建 Todo**
  - **清除哨兵**：`node scripts/plan-created.cjs`（双清除 side+legacy）；哨兵存在期间 PreToolUse hook 拦截非 plans/ 路径 Write/Edit（exit 2）

- [ ] [A] **初始化（哨兵机制）— 智能子动作**：体量分级判定与隔离决策
  - **冲突分析**：`bash scripts/check-conflicts.sh` → 结果+隔离决策写入 task_plan.md「🔀 隔离决策」（实现类默认首选 worktree）
  **可选思路**：
  1. 思路 A：按 §十一 硬条款判定——命中保护区/基础设施/并行开发任一条 → 选 worktree 隔离（适用场景：实现类任务、改运行行为、用户并行开发时）
  2. 思路 B：命中 §11.5 例外（纯文档/纯调研/单文件 ≤3 行 trivial）→ 直接在主工作树进行（适用场景：不产生运行行为变更、无并行冲突风险时）

- [ ] [A] **计划确认**
  - 展示 `task_plan.md`（Phase 列表+VC 表）给用户，附计划文件绝对路径+待审项清单+看点+动作（Rule 70 四要素）；**VC 每项须含可执行验证命令（Rule 84.1）**——验证域规则与 SOP 详见卫星 `verification-gate`（`Skill("verification-gate")`）
  - **门控**：等待用户显式 `"yes"`——无授权禁止执行；**D1 超时自动通过（Rule 44.3，2026-10-22 用户授权 P3）**：完成性指令/单步机械指令场景下按 44.1 默认 5 分钟超时自动通过（默认项=按已展示计划执行），自动通过须登记「自动裁决记录」五要素（超时值/推荐项/触发时间/裁决理由/被覆盖的未决选项）——D1 不再是「只能无限等 yes」的死等门；真分叉（D2/D5）与破坏性动作（D6 硬停点）仍必须等待用户答复，不适用本款。确认后 `bash scripts/attest-plan.sh` 锁定（内置 check-plan-dispatch.sh 校验派发型 Phase 的 S-unit 执行体列，缺失拒锁，`--skip-dispatch-check` 逃生）
  - **目标绑定确认（D1 升级，P0）**：D1 显式 yes 前，必须口头复述「本计划 Goal = <Goal 行原文>，服务用户指令 = <user-session-log.md 最近一条用户原话>」并等用户确认（该确认等待同样适用 44.3 超时自动通过口径：超时按已展示计划执行并登记自动裁决记录）；确认后 attest-plan.sh 锁定，锁定记录须含 Goal 原文 + 用户原话摘录 + 确认时间（落 .active_plan 绑定或 attest 记录）。**禁止**在用户确认前清哨兵（plan-created.cjs）。Why: RCA 缺失环节 2——D1 显式 yes 是 LLM 行为门（SKILL.md:49-51），可被跳过或默认「用户已同意」；本条把 D1 从行为门升级为需落盘的用户确认锚，缺确认锚不认。
  - **交互模式（Rule 28）**：ask 模式在计划全文后口头复述大体执行思路（≤5 行）并登记 Decisions Made；silent 模式自动通过+交付附静默决策清单；解析优先级 env > 计划配置表 > config.json > 默认 ask
  - **规则编号预留（Rule 20.6）**：新增 Rule 编号在计划声明 `new_rule: <NN>`；attest 自动查重登记（账本 `plans/.rule-reservations.jsonl`）

- [ ] [M] **Poka-Yoke 前置检查**（`references/methodology.md` §R1/R2）：依赖文件存在/上 Phase 产物非空/必要配置在位；高风险 Phase（FMEA RPN>100）须登记预设兜底动作；不满足先修前置

- [ ] [A] **思维方法论解构**（`references/methodology.md` T1-T5，指针）：计划期已按问题先行三问+5 Whys+结论先行附推导链完成解构，答案落 task_plan「核心问题定义」+findings.md；方案终裁（Rule 69.1 T1）≥2 候选难决→委派 decision-arbiter，不硬决不直接 AskUser
  **就地触发条件摘要**（全文→`references/methodology.md` §思维方法论 T1-T5）：
  - **T1 问题先行**：新任务 T0 规划时 / 任何方案提出前 / 任何修复动手前 → 三问自检（①问题是什么 ②解决到什么程度算好 ③不解决/解决错的代价）
  - **T2 解构四问**：计划创建（task_plan「核心问题定义」段）/ 复杂问题动手前 → 四问逐级作答（问题→本质[连问≥5 为什么]→解决方案[≥1 候选+取舍]→执行方案[S-unit 化+可验证]）
  - **T3 金字塔**：方案陈述 / 选项呈现 / 报告组织 → 结论先行 / 以上统下 / MECE / 逻辑递进
  - **T4 逐步推导**：T2②③作答 / FMEA 推演 / Rule 31.2 根因 / 复杂调试 → 推导链显式化落 findings，断点标「未验证」
  - **T5 消费点**：①规划先行的 T1 ②计划创建的 T2 ③方案候选的 T3 ④Phase 执行前的 Poka-Yoke ⑤失败纠偏的 T4

- [ ] [M] **共享内容追踪检查点（Rule 30）— 机械子动作**：命中则 `Skill("progress-tracker")` 建/用项目级账本（`.zcode/ledger/`），逐 target 认领登记+收尾 Todo；未命中 → Decisions Made 记不适用理由
- [ ] [A] **共享内容追踪检查点（Rule 30）— 智能子动作**：判定是否命中 30.1 识别条件（可枚举共享资源只认领一部分 / 同类任务 ≥3 次）
  **可选思路**：
  1. 思路 A：从 scope_files 反查共享资源——多 Phase 触碰同一文件/目录/资源 → 判命中（适用场景：改动集中在少数文件、资源易枚举时）
  2. 思路 B：从任务类型判定——同类任务重复 ≥3 次（批量站点/批量文档等）→ 判命中（适用场景：批量同类操作、资源分散难枚举时）

- [ ] **Phase 执行循环（每 Phase 独立闭环）**
  1. [M] **开启 Phase**：`Edit task_plan.md` 状态→`in_progress`；**R 锚定复诵**（v168）：Read「🎯 用户需求原文」→ progress 段首行写 `- **R 锚定**：本 Phase 服务 R<n>「<一句话复述>」`；与 Goal 或当前动作不符=先修计划再开工
  2. [M] **同步 Todo（S2）**：对应 todo→in_progress；步骤 1/2 必须紧邻执行
  2.5 [A] **委派检查点（Rule 25）**：Phase Executor≠主进程 → 立即按九字段模板逐 S-unit 派发子代理（路由表/粒度门/伴飞/返回校验/兜底详见卫星 `task-dispatch`）；主进程只保留派发/回填三文件/验收 Read；无 Executor 字段=计划无效先回炉；禁止"先自己干再派"
  2.5b [A] **技能激活确认**（v168）：派发前 Read knowledge-brief.md §6 可用强化技能清单 → 择优伴飞激活并登记 Handoff（用户触发型技能仅提示不代激活）
  2.5c [A] **动作相关性三问**（v168）：新文件/新命令/新 S-unit 动手前过三问——① 服务本 Phase R 锚定？② 在 scope_files 内？③ 用户原话要求过？任一 No→记录不执行
  2.5d [A] **变更类型判定（Rule 74 三判门，P0）**：对既有文件/条目的每处变更，执行前必须判定变更类型（增量/替代/删除），答案登记 task_plan.md「📋 变更标注表」：
     - **增量（默认且优先）**：用户措辞含"补充/再加/还有/另外/同时"或语义为新增条目 → 只追加、既有条目逐字保留不动；"补充一些条目"类指令永远走本档，禁以"整合/去重/顺手重构/格式化"名义回写既有条目
     - **替代（禁默认，四条件全满足才可）**：① 既有内容被新证据或回归测试证伪，或已被用户明示否决/作废；② 替代范围完整覆盖旧场景；③ 替代前已 Read 旧内容全文；④ 替代后既有守护/selftest 全绿。缺任一 → 回落增量
     - **删除（最高门槛）**：必须取得用户逐项授权；未授权只可停用/标记，禁物理删除
     - **判据**：先问是补充还是替代——补充是常态，替代是例外，删除是特许；未做三判即写入 = P0 违规
  3. [M] **执行 Phase 工作**（内嵌 3-File 落盘，Rule 19）：
     - **3a 子代理产出回填（19.1）**：每次子代理/调研 Skill 返回后**紧邻一次 `Edit findings.md`**（结论摘要+证据路径）；回填完成才勾 Handoff `verify_done`（Read 产出+findings 双条件）；验收争议（Rule 69.1 T4）→ decision-arbiter 仲裁
     - **3b 2-Action Rule（Rule 3）**：每 2 次 view/browser/search 后写 findings.md；多模态内容立即转文字落盘
     - **3c 动作留痕**：关键动作随做随记 progress.md；错误**立即**写 Error Log（19.4）并同轮完成四步（v168：记错误原文→Rule 31.2 四问根因→纠正→复验回填，未完禁下一动作）；关键动作同步 `bash <skill>/scripts/ledger-append.sh <plan-dir> <event> <summary> [--phase N]`
     - **3d hook 响应**：`[plan-sync]`→按 `references/todo-sync.md` §4 协议回写；`[plan-compass]`（findings/progress 陈旧，Rule 19.7）→立即回填再继续
     - **3e 上下文卫生（Rule 29，细则→task-discipline）**：每 2 个 Phase 跑 `bash scripts/check-context-hygiene.sh`；工作文件整理在会话恢复/用户指令时运行
     - **3f 周期性三文件对照**（v168/R3）：每完成一个 S-unit（或每 10 次工具调用），Read task_plan Goal+Phase 状态与 progress 尾部对照；不符按 Rule 65.4 标 `[corrected]` 回错误步并一句话记 progress
     - **3g 规范召回（Rule 93）**：每完成 3 个 S-unit 或 Phase 翻转 complete（先到者），主进程亲自 Read `../task-discipline/references/execution-recall-card.md` 并 progress 留 `[recall]` 行（可与 3f 同拍执行）；compaction 恢复/会话恢复/[assess]≥PRESSURE 后第一动作先读召回卡（93.3）；mini/L0 档豁免
  4. [M] **回写计划**：Phase→`complete`+勾选+证据路径；**⚠️ 3-File 回填门控（19.2）**：翻转前 progress Phase 段已回填（Actions/Files/Test Results）+ findings 本 Phase 有实质增量，`bash <skill>/scripts/check-3file-gate.sh <plan-dir>` exit 0 才可翻转（信号优先级 ledger 语义证据 > mtime；纯实施 Phase 一行 `[implementation-only]` 声明计增量）；**V-N 校验（Rule 84.3/84.4）**：翻转前逐项执行 verification.md 当前 Phase 段的 V-N 验证命令（SOP→卫星 `verification-gate` Step 2），V-N 未全 PASS→禁止翻转
  4.5 [M] **提交工作产物（Rule 27）**：实现类 Phase 翻转 complete 前 commit 本 Phase 产物（禁跨 Phase 攒批、禁 `git add -A` 盲扫、只 add scope 文件）；非 git 记行跳过；deferred/用户显式豁免须写入计划
  5. [M] **同步 Todo+索引（S2/S4）**：todo→completed；`bash scripts/sync-todos.sh --index` 刷新 INDEX.md
  6. [A] **[DRIFT CHECK]** 派发 `drift-checker` 偏移检查（载体 Rule 61/64，详见卫星 `task-drift-guard`）：✅ALIGNED→继续；⚠️DRIFT→记 progress 警觉继续（「警觉 vs 返工」拿不准→decision-arbiter 裁决）；🔴BLOCKED→STOP 报告用户等决策。触发时机=Phase complete 后立即/连续 ≥3 次工具调用/切换文件模块前/用户新指令时（先过「用户新指令处理」判定）；留痕三件套（检查点+`ledger-append.sh drift_check`+Drift Log 行）缺一=未执行
  **可选思路**：
  1. 思路 A：按 Executor 字段机械派发——Phase 有 Executor 字段即派子代理，主进程只回填三文件+验收 Read（适用场景：派发型 Phase、S-unit 边界清晰时）
  2. 思路 B：主进程直做——命中直做白名单（trivial/单文件小改）或 Executor=主进程时自执行（适用场景：改动小、派发开销大于收益时）

- [ ] [A] **Code Review Gate**（仅 `code_review: required`）：全部 Phase complete 后、终验交付前触发；轻 diff（代码 ≤3 文件且合计 ≤50 行）单轮轻量审查，重 diff 全量多轮；`Skill("code-review")` 输出 APPROVED 才可进入终验交付；CHANGES_REQUESTED→追加 fix-phase 回执行循环；CR 分歧（Rule 69.1 T6）→decision-arbiter

- [ ] [M] **终验交付 — 机械子动作**：跑终验门脚本/合并回/提交核验/Read 产出/归档
  - **3-File Gate（19.5）**：check-complete.sh 内置校验 findings/progress 非 stub，缺失/stub→exit 1→STOP 回填禁交付
  - **隔离任务合并回**：worktree 内全 VC 复验且无未提交变更→`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`→清理 worktree/分支→主仓 Read 复验（合约见 `references/worktree-isolation.md`）
  - **git 提交核验+编号账本**：scope 文件无未提交变更（或已按 Rule 27 逐 Phase 提交）；新增编号 `bash scripts/rule-reserve.sh land <NN> <task-id>`
  - subagent 返回 "done" → **必须 Read 实际产出文件**，禁止信任自报
  - **退出前**：`bash scripts/check-complete.sh`——exit 0 正常结束；exit 1→STOP 报告未完成任务
  - **计划归档（Rule 81.1）**：check-complete exit 0 后运行 `bash scripts/archive-plan.sh <task-id>` 将完成任务目录移入 plans/archive/——target 已存在=幂等报 `ALREADY_ARCHIVED` 视为通过；守卫拒绝（active 指针 / .session-owner 活跃 / Status 未全 complete，fail-closed）→ 保持原位并登记拒绝理由，禁止强移。Why：「在途在根、历史在 archive/」是 plans/ 存量唯一健康形态，防无限堆积致索引失真（task-v170；详见 references/critical-rules.md Rule 81）

- [ ] [A] **终验交付 — 智能子动作**：VC 复验判定、质量门控与委派率核查、outcome 判定
  - **按卫星 `verification-gate` 终验 SOP 执行（Rule 84.5 Step 3）**：Read `verification.md`，逐条复验 VC（每条带证据路径+可执行命令）；统一入口 `bash <verification-gate>/scripts/run-verification.sh <plan-dir>` 自动执行 VC 命令并汇总 PASS/FAIL
  - **质量门控统计（Rule 26）**：核查 Q1-Q6 触发与豁免登记；抽查 ≥3 条 Evidence（路径可 Read、结论可复现）；未处置违规按 Rule 26.3 降级 outcome，Q3→BLOCKED+STOP
  - **委派率统计（Rule 25，细则→task-dispatch）**：子代理执行 Phase 占比 < `config.json#delegation_rate_floor`（默认 0.7）或直做含白名单外理由→check-complete exit 1 回炉；**纯执行 S-unit 权重 0（P4，2026-10-22 用户授权）**：命中 L0-E 档（零仓库受管变更 ∧ 仅调用既有工具 ∧ 产物落 gitignore 区）的 S-unit **既不计入分子也不计入分母**——若计入分母会拉低委派率，方向与「机械操作免强制派子代理/免终验回炉」的豁免意图相反（审计判例 F9）；机器面=计划 Executor 行标 `L0-E`（或括注含「纯执行」）即识别，`check-delegation.sh stats` 已按此口径实现（分母扣减 + 该单元不判 violation + 整批皆纯执行时 rate=1.000 视为达标）
  - 交付结论 COMPLETE/PARTIAL/BLOCKED；**交付总结五要素**（Rule 48：全体指针绝对路径/可执行命令）按 `templates/delivery-summary.md` 输出
  - 决策分级（Rule 72）/呈报四要素（Rule 70）/变更吸收三判（Rule 74）/编号列表规范（Rule 76）按卫星 `task-discipline` 全文执行
  **可选思路**：
  1. 思路 A：严格按门脚本 exit code 判定——全门 exit 0 → COMPLETE，任一门非 0 → 回炉修复（适用场景：门覆盖充分、产出可机器校验时）
  2. 思路 B：门通过后加人工复核——对关键 Evidence 抽样复现，发现门未覆盖的缺陷即降级 outcome（适用场景：交付面广、门可能漏检内容型缺陷时）

### 📄 产出落盘映射（3-File Pattern）

> 原则：**Context Window = RAM（易失），Filesystem = Disk（持久）**；恢复读序：task_plan（在哪/去哪）→ progress（做过什么）→ findings（已知什么）→ knowledge-brief（可复用什么）。

| 产出类型 | 写入 findings.md 段落 | 写入时机 |
|---------|---------------------|---------|
| 调研结论/搜索结果摘要 | `## Research Findings` | 子代理返回后**紧邻** |
| 根因分析/排查结论 | `## Issues Encountered`（Issue+Resolution） | 根因定位后 |
| 技术选型/方案决策 | `## Technical Decisions`（+task_plan Decisions Made 双写） | 决策时 |
| URL/文件路径/API 引用 | `## Resources` | 发现时 |
| 截图/网页等多模态信息 | `## Visual/Browser Findings`（转文字） | **立即**（多模态不持久） |
| 用户需求拆解 | `## Requirements` | Phase 1 期间 |
| 调研蒸馏知识（可复用事实/锚点/易错点） | `knowledge-brief.md` §2/§3/§4（主进程单写者蒸馏，Rule 62.3 双落盘） | 22.5 复核时，Handoff 记双锚 `findings锚\|kb:§N` |

### 📖 Read vs Write 决策矩阵（Rule 20.5 — 省 token）

> 权威源=`references/critical-rules.md` Rule 20.5。场景速查：刚写完的文件→**不要再 Read**（内容还在上下文）；看过的图/PDF/网页/搜索返回→立即写 findings；开新 Phase→读 plan+findings；出错→读相关文件；中断/压缩恢复→读全部三文件（Rule 19.3）＋执行规范召回卡（Rule 93.3）。

### 合规检查清单（核心域，每 Phase 开始前逐项确认）

| # | 检查项 | 状态 |
|---|--------|------|
| G1 | 用户任务已复述目标无歧义；task_plan.md 存在且含 Phase+VC 表；计划已展示并获用户显式授权 | ☐ |
| G1b | 计划 Goal 的站点/域名词/目标实体与 user-session-log.md 最近用户原话有交集（目标绑定）；新建计划已过目标切换三判（E 类） | ☐ |
| G2 | 本 Phase R 锚定复诵已写；动作相关性三问已过（v168 两锚点） | ☐ |
| G3 | Phase 委派检查点已过：Executor 字段在位非主进程已派发；白名单直做已登记例外理由 | ☐ |
| G4 | DRIFT CHECK 已派+留痕三件套齐（检查点/ledger drift_check/Drift Log 行） | ☐ |
| G5 | 子代理结论已落 findings（含多模态转文字）；ledger 关键动作已追加 | ☐ |
| G6 | complete 前 `check-3file-gate.sh` exit 0（progress 回填+findings 增量，19.2）；Handoff verify_done 已勾（Read+回填双条件） | ☐ |
| G7 | 本 Phase 无未处置质量违规（Rule 26 Q1-Q6 或已豁免登记）；产物已 commit（Rule 27） | ☐ |
| G8 | 原生 Todo 已同步（S2）；用户新指令已过 D/A/B/C 判定（如有） | ☐ |
| G9 | 用户会话逐字记录自查（Rule 80，原 C56 并集承载）：每次用户发言已逐字落盘 user-session-log.md（80.1）；写入=append-only 历史条目零改写零删除零重排（80.2）；会话恢复先读专档再读 task_plan.md（80.4）；理解镜像已同号配对（80.7）（机器面=selftest-session-log.sh+check-complete SESSION-LOG GATE，记录内容人工核查；mini 档豁免） | ☐ |
| G10 | 计划完成后归档自查（Rule 81，原 C57 并集承载）：check-complete exit 0 后已执行 `bash scripts/archive-plan.sh <task-id>`（81.1，guard/ALREADY_ARCHIVED 幂等路径走通）；守卫拒绝（active 指针/活会话标记/Status 未全 complete，81.3）时保持原位不归档并登记拒绝理由，禁强移；归档后已重跑 `sync-todos.sh --index`（81.4）（机器面=selftest-archive-plan.sh+check-complete [ARCHIVE-GATE] warn，归档动作与拒绝登记人工核查；mini 档豁免） | ☐ |
> 非核心域合规项（派发/纪律/媒体/模板/调研/协同族）随规则迁至各卫星 `critical-rules-*.md` 全文——按需 Read 对应归属文件，勿回填本表。

### 🔁 原生 Todo 同步（强制）

计划文档=唯一事实源，原生 Todo（`TodoWrite`/Task）=执行视图。五个强制同步时机：**S1** 计划创建后建映射→**S2** Phase 状态变更后紧邻同步→**S3** `[plan-sync]` hook 提醒立即回写→**S4** 会话结束前终态同步+`--index`→**S5** 用户新指令影响计划后先改计划再重映射。映射规则与响应协议详见 `references/todo-sync.md`。

### 🆕 用户新指令处理（计划影响判定 — 强制）

| 类 | 判定 | 强制动作 |
|----|------|----------|
| D 新任务边界 | 与当前计划 Goal/范围/交付物均无关联（Rule 8.1） | **开新计划** `plans/{new-task-id}/`（init 全流程）；旧计划原样保留（不标 superseded）；判定落 notepad+Decisions；禁混入当前计划 |
| A 无影响 | 闲聊/追问/与当前计划无关 | 正常执行，不改计划 |
| B 扩展 | 新需求/加范围/改交付物 | 先重规划（Rule 74 三判门+变更标注表）→ S5 同步 Todo→复述变更→再执行 |
| C 矛盾 | 与已确认计划/VC/用户先前决策冲突 | 停止写入：更新计划中被推翻部分（标 superseded）→同步 Todo→展示新旧对比获确认后执行 |

**判定顺序**：先 D 再 A/B/C（指令与目标有关联哪怕小→回退 A/B/C）；仅存在活跃计划时 D 类适用。B/C 变更前过 Rule 73.2 对齐三问+[align] 行，处理完再派 drift-checker。**稳定性铁律**：禁止"口头接受新指令、计划与 Todo 不动"。用户指出错误（Rule 31）→先 STOP 走 31.2 四维归因再修（完整闭环见 task-discipline Rule 31/32/33/74）。

**目标切换判定（E 类，P0 铁律）**：用户指令命中以下任一**可判定**条件 = 目标切换 = **scope 扩张动作** → **禁止自行归类为 D/A/B/C 并执行**，必须先复述解读 + 等用户显式 yes（D1 门控）：① 指令含**新站点/域名/平台名词**，与当前活跃计划 Goal 的站点/域名词**零交集**（实体提取：Goal 行 + 指令中的域名/站点名/产品名）；② 指令含**指示词**（「其他」「另外」「换个」「别的」「新的」）+ **新对象词**，且该新对象词与当前计划 Goal **零交集**；③ 指令的**宾语**从当前计划 Goal 的宾语变为另一宾语（Goal 宾语 = 站点/产品/项目名）。处置：复述「我理解您的指令是 X（切换到 Y），对吗？」→ 等用户 yes → 才可按 D 类开新计划或 B 类扩范围。**禁止**在用户确认前新建计划目录、写 task_plan.md、清哨兵。**确认切换后的处置（Rule 94，2026-10-23）**：确认目标切换后按 Rule 94 任务专注性与计划隔离纪律处置——94.3 询问门可与本类确认合并为一次询问（新开计划隔离执行（推荐）/并入当前计划重规划/暂挂当前计划），同意拆分则按 94.4 隔离（旧计划封存待 plan-resume、新目标独立 init、跨计划禁交叉写入），禁把新目标就地吸收进当前计划。Why: RCA 缺失环节 1——D5 歧义条款与 D/A/B/C 判定均为 LLM 行为门，机器不可判，含糊指令被宽泛归类后 agent 直接执行；本条给出**可判定的触发条件**（换站点/换目标域/新目标实体词），把「目标切换」从模糊判定中抽出为独立可判类别，在「新建计划」前强制停下确认。与宪法 §四 P0-1（用户说 A 做 A）和 §二（规划先行）绑定。

### 🔀 冲突分析与工作树隔离（默认首选）

**实现类任务一律首选 git worktree 隔离**——本仓多为运行中基础设施（skills/hooks/config 被所有会话实时使用），直接改动有半残风险；仅纯文档/调研类（只写 plans/ 与 .md）可直接开发；用户显式否决才直接开发。初始化 `bash scripts/check-conflicts.sh`（五类冲突信号）→ 隔离决策写入 task_plan「🔀 隔离决策」随计划展示；隔离期间 CWD 不迁移、文件操作用 worktree 绝对路径、计划文档留主仓 plans/。完成合并：全 VC 复验→`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`→清理 worktree/分支→主仓 Read 复验。合约详见 `references/worktree-isolation.md`。

## 投诉响应协议与 L0 边界审查（[task-perf-opt 2026-10-13 Change #10]）

> **元根因守护（Rule 38.7 比例原则的行为面）**：用户投诉「慢」时，不仅修补当前症状，还检查既有通道边界（L0/mini/trivial）是否覆盖该场景，未覆盖则扩展边界而非叠加新门控。

- **投诉响应协议**：每次用户投诉「慢 / 好几个小时解决一个最简单的问题」时——① 复述用户原话 → ② 检查既有通道（L0 微变更 / mini 轻量档 / trivial 代码修复档）是否覆盖该场景 → ③ 未覆盖则扩展既有通道边界（如 Change #1 的 trivial 代码修复第四条件），而非叠加新的门控/仪式。
- **通道不可用快速失败（Rule 83）**：`/workflow` 请求先探测当前环境 Skill 工具面（`Skill(skill="dynamic-workflows")` 是否可用），缺失即登记环境缺口 + 给三选项（换环境 / Agent 替代授权 / 主进程直执行授权），禁 ≥2 次同法重试（videop1 D6 判例：CreateWorkflow 无 Skill 工具 3 次重试全拦）。
- **L0 通道定期边界审查触发**：每 10 个任务或每月，检查「最常见的简单场景」是否被既有通道排除（如代码文件改动被 lane-detect.sh:86 禁滥用条款排除 → 已补 trivial 第四条件）。审查留痕于 findings.md。
- **L0-E 纯执行档（2026-10-22 用户授权 task-videop1-protectfix-001 新增；Rule 38.7 通道族新增档，本处为 SKILL 侧摘要口径，全文锚=卫星 Rule 38.7「执行通道分级」段（plan-template-kit / task-discipline 逐字双载））**：判定三条件**全满足**=纯执行任务——① 零仓库受管文件变更（不新增/修改任何入库文件）∧ ② 仅调用既有工具（`tools/*.py` 等已存在脚本/API，无新代码、无新语义）∧ ③ 产物全落 gitignore 区（`tmp/` `output/` 等）；命中=**免计划免 attest**（不建 `task_plan.md`、不跑 attest-plan.sh），主进程直做，产物按「生成物展示规则」呈示 + progress 一行登记（`[L0-E] <动作>×<产物路径>×<日期>`）；已有计划目录的批次仅对该 S-unit 豁免委派率统计（P4 口径：权重 0，既不计入分子也不计入分母）。**禁滥用**：任一条件不满足（含功能性代码变更/新增脚本/产物落仓库受管区）即回落 L1 standard 通道；机器面=计划头 `execution_lane: L0-E` 声明（`check-delegation.sh` ④c 直做通道 + stats 权重 0 已接线）。Why（判例=videop1 机械合图停摆投诉 session_a40eae17265b5414c27e8c45d2c27b5c）：机械操作零仓库变更却被 L0/L1 全量仪式拦住——流程开销与变更体量严重失衡（Rule 38.7 比例原则）。
- **验证锚新位置（Rule 38.7 执行通道分级）**：原核心 `references/critical-rules.md` 锚已失效（task-v171 专业化拆分后 0 命中）。现权威位置=`../plan-template-kit/references/critical-rules-template.md:45` + `../task-discipline/references/critical-rules-discipline.md:195`（逐字双载，域归属=模板域+执行纪律域）。后续 grep 检查 Rule 38.7 应命中这两处，勿再 grep 核心 critical-rules.md。
- **§六 保护区约束**：本技能 SKILL.md 是技能文件，修改须走 §十一 worktree 铁律（git worktree add → 修改 → selftest → 合并回 master）；不修改 `~/.zcode/` 下的记忆文件（§六 保护区）。

## 卫星路由表（11 卫星 — 非核心域规则全文按需 Read）

| 卫星 | 域 | 规则全文路径 | 调用条件 |
|------|----|------------|---------|
| task-dispatch | 子代理派发与拆分调度 | `../task-dispatch/references/critical-rules-dispatch.md` | 拆分/派发/并行/粒度校验/执行体选型/超时兜底/代码编辑隔离（Rule 12,13,14,21,22,23,25,46,52,59,68） |
| task-discipline | 执行纪律与工作产物维护 | `../task-discipline/references/critical-rules-discipline.md` | 执行纪律/错误闭环/证据/调研/批量/反思/注释/可靠性/能力沉淀/变更吸收（Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-76,85,86,87,88,89,90,92,93,94） |
| media-planner | 媒体制作任务派发 | `../media-planner/references/critical-rules-media.md` | 视频/图片/剧集创作媒体轴拆分与执行体路由（Rule 47,49,50） |
| plan-research-router | 调研分析与证据纪律 | `../plan-research-router/references/critical-rules-research.md` | 调研/分析/评估/归因证据面覆盖与反推诿（Rule 58,63,75） |
| plan-template-kit | 模板生命周期与难度分级 | `../plan-template-kit/references/critical-rules-template.md` | 模板选取/沉淀入库/难度分级/轻量档判定（Rule 16,34,37,38） |
| plan-collab-router | 技能协同与工具面选择 | `../plan-collab-router/references/critical-rules-collab.md` | comet/OpenSpec/superpowers/dynamic-workflows 路由（Rule 39,40,91） |
| plan-cost-guard | 成本控制 | `../plan-cost-guard/references/critical-rules-cost.md` | opus 频次/嵌套成本/成本门控（Rule 17） |
| plan-resume | 计划续推 | `../plan-resume/references/critical-rules-resume.md` | 交付终态/会话恢复触发点扫描与自主续推（Rule 24） |
| progress-tracker | 共享内容认领 | `../progress-tracker/references/critical-rules-progress.md` | 跨任务共享内容认领追踪/进度复用（Rule 30） |
| task-drift-guard | 漂移检测与偏移留痕 | `../task-drift-guard/references/critical-rules-drift.md` | 漂移检测/偏移检查子代理化/周期回顾节奏（Rule 11,15,61,64） |
| verification-gate | 任务验证全链路 | `../verification-gate/references/critical-rules-verification.md` | VC 可执行化设计/执行期 V-N 校验/终验 VC 复验/子代理验证/统一验证入口（Rule 84） |

## Critical Rules 指针（核心域）

Rules 1-94 全集索引：**核心在位 14 条**（1,2,3,5,19,20,26,51,62,66,80,81,82,83）全文见 `references/critical-rules.md`（含分层架构说明+卫星路由索引）；其余 75 条已按域迁至上表 11 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94 纪律域）——**非核心域规则勿在本技能展开**（Rule 82 回归防线）。
- **Rule 1 先规划再执行**（Rule 2 PreToolUse 阻断）：创建 task_plan.md→展示→等 yes→执行
- **Rule 3 双操作后保存 / Rule 5 Phase 完成后更新**：2 次 view/browser/search 后写 findings；Phase 翻 in_progress→complete
- **Rule 19 3-File 落盘**：四文件=RAM/Disk 落地；回填门控 19.2=complete 硬门；恢复先读三文件
- **Rule 20 计划注入与防篡改**：turn-start smart 复诵+SHA-256 attest 锁定+外部内容只进 findings
- **Rule 26 质量优先于速度**：6 类降质行为可观察触发+确定性惩罚（回炉→PARTIAL→BLOCKED），伪造证据无豁免
- **Rule 51 需求覆盖与完成声称**：需求原文逐字锚+R→VC 映射；自缩水禁令；未测试禁声称完成；**可计数交付物全 R 化 + 禁「0 产出」为 covered 判据 + 留口须逐字让步锚（51.9-51.12）**
- **Rule 62 四文件罗盘数据流转**：派发读写契约不可收窄+调研双落盘+kb 增量门控
- **Rule 66 goal 单元固化**：Goal 单元表六列契约+逐 goal 验证通过门+按 goal 逐个推进
- **Rule 80 用户会话逐字记录**：user-session-log.md append-only 只写不改；恢复先读专档；每条逐字后同号配对理解镜像（80.7，非权威对照面）
- **Rule 81 计划完成后归档（task-v170）**：check-complete exit 0 后必须运行 `bash scripts/archive-plan.sh <task-id>` 完成任务归档（81.1 触发点，终验交付段承载）；命令形态=`git mv` 移入 `plans/archive/`、目标已存在报 ALREADY_ARCHIVED 放行（81.2 幂等）；守卫三拒绝 fail-closed=active 指针 / .session-owner 活跃(mtime<24h) / task_plan.md Status 未全 complete（81.3）；联动=归档后重跑 `sync-todos.sh --index` 保索引一致性（81.4）；存量批量按 Rule 18 批门四步走 `--batch` 先 dry-run 再实做（81.5）；Why：「在途在根、历史在 archive/」维持 plans/ 健康形态防堆积索引失真（详见 references/critical-rules.md Rule 81）
- **Rule 82 技能专业化分层纪律**：核心只管四文件罗盘域；删留原子配对；禁回潮禁镜像

## Completion Gate

详见卫星 `verification-gate` `references/critical-rules-verification.md` Rule 84.4（2026-10-14 task-v173 从 completion-gate.md 迁移）。subagent 返回 "done" 后必须 Read 实际文件验证变更，才能标记 complete。

## Scope Guard / Goal Gate

- **Scope Guard**：`check-scope.sh Write "<file>" task_plan.md` → exit 0=放行 / 1=拦截 / 2=no plan。**口径更正（P7，2026-10-22 用户授权）**：`scope_files` 约束**不由运行时停摆门承载**——实测 `check-scope.sh`/`check-delegation.sh` 均无 scope_files 运行时拦截逻辑（grep 零命中），原表述「不在 scope→停，获授权扩 scope」是死文，会诱导执行体按不存在的门停摆请示；实际约束由三处承载：① 主进程派发前的范围声明（Executor/scope_files 字段）② 收口审计 ③ `git show --stat` 越界自检。scope 越界的唯一合法出口=收口审计发现越界后按 Rule 74 变更标注表处理，不是执行期停下问用户。
- **Goal Gate**：每个 `task_plan.md` 必须含 **Verification Contract**（VC 表），每项含可执行验证命令（Rule 84.1）。详见卫星 `verification-gate` `references/critical-rules-verification.md` Rule 84.3（2026-10-14 task-v173 从 goal-gate.md 迁移）。

## I/O 契约

输入=任务描述/CWD/已有 plan（恢复时用）；输出=规划→plan+思路复述（28.2.1，ask 模式）/执行→checkbox+错误/完成→全部 [x]+验证。`config.json#escalation_threshold` 次失败→AskUserQuestion（交互模式语义见 Rule 28）。示例：`mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh`。机器面=`scripts/schemas/check-delegation-stats.schema.json`（check-delegation stats JSON 契约）+ `scripts/verify_io.sh <plan-dir>`（7 文件在位 + delegation stats JSON 断言，`scripts/selftest-verify-io.sh` 守护，task-v189 F11 修复）

## Chain 模式与协同路由（指针）

`chain_mode` 默认 `single`（单 block）；`linked`（多 skill 串行接力）/`fan-out`（一对多派发，成员按 Rule 21.4 声明组并行）的值语义与 block 交接合约权威源=`reference.md § Chain Handoff Contract`。专业技能协同（comet/OpenSpec/superpowers/dynamic-workflows）权威源=`../plan-collab-router/references/skill-collaboration.md`，主路由 `Skill("plan-collab-router")`；dynamic-workflows 于用户点名 /workflow 或命中 Rule 39.8 编排条件（常设授权）时主动路由——激活按 39.8 三件套（留痕/91.12 分档/83 探测）（Rule 39,40,91）。调研 SOP=卫星 `plan-research-router`（`references/research-routing.md`）；模板库=卫星 `plan-template-kit`（本技能 `templates/` 机械层留守）。

## 派发与执行纪律指针（卫星 authoritative）

- **子代理派发/路由表/模型档位/超时兜底/返回校验/代码编辑隔离/provider 故障 scaling/hook 自愈** → 卫星 `task-dispatch`（SKILL.md+`references/agent-coverage.md` 覆盖矩阵+`references/split-pattern-library.md` 模式库；五档兜底=改派→拆细→降档→接管→AskUser）
- **执行纪律/错误闭环/批量质量门控（batch-quality-gate.md）/反思验证/注释规范/可靠性/能力落盘/上下文压力/用户否决/决策分级/变更吸收** → 卫星 `task-discipline`
- **媒体制作/单元线并行/内容权重分级** → 卫星 `media-planner`
- 主进程铁律摘要：任务执行一律 `Agent()` 派发（白名单外 Write/Edit 被 `check-delegation.sh` 拦截，enforce=exit 2）；bypass 仅显式 `allow-direct.sh on --confirm-user-requested`；六项白名单全文见 task-dispatch Rule 25.3

## References

| 文档 | 用途 |
|------|------|
| `reference.md` | Manus 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 |
| `references/critical-rules.md` | Critical Rules 核心域 1-94 全集索引（14 条核心全文+分层架构说明+卫星路由索引） |
| `references/methodology.md` | 思维方法论 T1-T5 + 内容质量 Q3/Q4 + FMEA/Poka-Yoke |
| `references/completion-gate.md` | 子代理验证 + 串行同步 |
| `references/goal-gate.md` | Goal Gate + VC 规则 + 退出标准 |
| `references/todo-sync.md` | 原生 Todo 同步契约（S1-S5/映射/hook 响应） |
| `references/worktree-isolation.md` | 工作树隔离契约（实现类默认首选+合并回合约） |
| `templates/knowledge-brief.md` | 知识底座模板（init 第 6 文件；五段） |
| `templates/user-session-log.md` | 用户会话逐字记录专档模板（第 7 文件；append-only，Rule 80） |
| `templates/delivery-summary.md` | 终验交付总结五要素模板 |
| `templates/shared-tracker.md` | 共享内容认领追踪区块模板（Rule 30） |
| `templates/deprecated.md` | 废弃内容隔离区（Rule 73.5 只入不出；非白名单，不计入 grep 锚计数） |
| `templates/session-handoff.md` | 会话交接文档（Rule 67.4 CONFUSED 触发；写回 Decisions Made + progress [handoff]） |
| `examples.md` | 实际示例 |
| `../task-dispatch/references/agent-coverage.md` | 执行体覆盖矩阵（Rule 52.1） |
| `../task-discipline/references/batch-quality-gate.md` | 批量处理质量门控详解（Rule 18） |
| `../plan-collab-router/references/skill-collaboration.md` | 专业技能协同路由权威源 |
| 外部 skill/agent | `drift-checker`（Rule 61）/`decision-arbiter`（Rule 69）/`Skill("plan-resume")`（Rule 24）/`Skill("progress-tracker")`（Rule 30）/`code-review` skill |
