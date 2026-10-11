# 03 简单任务全链路取证（trivial 任务为什么仍然慢）

> 审计域：简单任务全链路（SessionStart 哨兵 → init → 计划确认 → 执行 → 终验）步骤数与强制产物计数；Rule 38 mini 轻量档解剖。
> 审计方法：只读审计。① 静态读码（SKILL.md / references/critical-rules.md / scripts/ / templates/ / config.json）；② 本会话实跑命令与计时（selftest、hook 计时、探针）；③ 真实历史计划（plans/task-v090-workflow-auto-activation/）产物计数；④ 本会话自身的 hook 注入实况（本对话每轮可见 `===BEGIN-PLAN-DATA===` 注入与 SessionStart 哨兵消息，属第一手实况证据）。
> 证据边界（如实）：模型侧行为（复述/填表/TodoWrite 次数）不可脚本化实测，其计数来自 SKILL.md 条款逐条推演并标注条款锚；hook 计时为单机实测（本仓 plans/ 40 目录 5.9MB 场景），绝对值随机器/仓库规模变化，但相对量级与 O(N) 增长趋势可复现。

---

## 一、trivial 任务（改 3 行，走 mini 档最优路径）全链路步骤与强制产物计数

下表为「改 3 行」任务按 SKILL.md 执行流程（mini 档、Executor=主进程、ask 默认模式）的最优路径逐步计数。每条带条款锚。

| # | 阶段动作 | 证据锚 | 脚本/命令调用 | 计划侧文件写入 |
|---|---------|--------|--------------|---------------|
| 0 | SessionStart 哨兵写入 + INDEX 待处理提醒 + set-active-plan gc | scripts/zcode-sessionstart.sh:13,18-28,33；task-plan-init.cjs | 2（task-plan-init.cjs + set-active-plan gc） | 1（side 哨兵文件） |
| 1 | 初始化：mkdir + init-session.sh 建 **6 文件**（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief，mini 档同样 6 个并 6/6 复核） | SKILL.md:64；init-session.sh:183-191,240-251（`[init] 6/6 planning files verified`） | 1 | 6（创建） |
| 2 | `bun scripts/session-catchup.ts` 中断恢复检测 | SKILL.md:63 | 1 | 0 |
| 3 | 冲突分析 check-conflicts.sh，结果写 task_plan「隔离决策」 | SKILL.md:71 | 1 | 1（task_plan.md Edit） |
| 4 | S1 Todo 同步：sync-todos.sh --json + TodoWrite 逐 Phase 建 todo | SKILL.md:72；references/todo-sync.md（S1-S5） | 1 | 0（Todo 视图） |
| 5 | 清哨兵 plan-created.cjs | SKILL.md:73 | 1 | 0（删 1 文件） |
| 6 | 填 mini-lite 模板（49 行模板：Goal/VC≥2/范围表/2 Phase/Handoff 表 + V-N 行 + Status/Executor 行） | templates/variant/mini-lite-type.md:1-49；Rule 38.3 | 0 | 1-3（task_plan.md 填充 Edit） |
| 7 | 计划确认：展示全文 + **28.2.1 口头复述思路（≤5 行）** + 等待显式 yes（阻断式交互）+ 登记 Decisions Made | SKILL.md:77-80；critical-rules.md 28.2/28.2.1 | 0 | 1（Decisions 行） |
| 8 | attest 锁定（内部跑 check-plan-dispatch + check-template-type + FMEA gate 三子门控） | attest-plan.sh:66-201 | 1（含 3 子调用） | 1（.plan-attestation） |
| 9 | Phase1 步骤1-2：Edit task_plan→in_progress + TodoWrite S2（禁只做其一） | SKILL.md:89-91 | 0 | 1 + Todo×1 |
| 10 | Phase1 步骤2.5 委派检查点：核对 Executor 字段（主进程须白名单理由） | SKILL.md:91；Rule 25.2/25.3 | 0 | 0 |
| 11 | **任务本体：Edit 业务文件改 3 行** | — | 0 | 1（业务文件） |
| 12 | Phase1 步骤3：findings.md 回填 + progress.md 回填 + ledger-append | SKILL.md:94-96；Rule 19.1/19.8 | 1（ledger-append） | 2（findings+progress） |
| 13 | Phase1 步骤4：check-3file-gate.sh 硬门控 + Edit task_plan→complete | SKILL.md:98-99；check-3file-gate.sh:1-137 | 1 | 1（task_plan） |
| 14 | Phase1 步骤4.5：git add（禁盲扫）+ commit + `git status --porcelain` 校验 | SKILL.md:100；Rule 27.1-27.3 | 3 | 0 |
| 15 | Phase1 步骤5：TodoWrite + sync-todos.sh --index 刷新 INDEX.md | SKILL.md:101；Rule 23.7 | 1 | 1（INDEX 全量重写） |
| 16 | Phase1 步骤6：DRIFT CHECK（Skill("task-drift-guard")；C4a 另列 check-drift.sh --json）+ plan-resume（≤3 Phase 跳过，Rule 24.7） | SKILL.md:102-107；critical-rules.md 24.7 | 1-2 | 0-1（DRIFT 时 progress） |
| 17-24 | **Phase2（验收 Phase）完整同构闭环**：翻转 in_progress→Todo→验证动作→findings/progress 回填→ledger→check-3file-gate→翻转 complete→（无仓内产物记行）→Todo+--index→drift-guard | SKILL.md:88-107；mini-lite 模板固定 2 Phase（Rule 38.3③） | ≈7 | ≈5 |
| 25 | 终验：Read verification.md + 填 **VC 复验表 + 委派统计段 + 质量门控统计段**（三段） | SKILL.md:158-168；Rule 25.4/26.2 | 0 | 1-2（verification.md） |
| 26 | 终验 check-complete.sh：porcelain 预检 + python 段（Phase 计数/Batch/3-File stub）+ 委派 stats + plan-dispatch + FMEA + rescue-chain + VC-GATE + Learning + Reflect + SKILL-MODIFY + mechanism-profile ≈10 道门 | check-complete.sh:18-97,122-376,379-893 | 1（内嵌 4 子脚本） | 0 |
| 27 | git porcelain 终验核验 + 交付结论 COMPLETE + S4 终态 Todo 同步 + sync-todos --index + ledger phase_complete | SKILL.md:167-171,208 | 3-4 | 1（ledger）+1（INDEX） |

**合计（mini 最优路径）**：脚本/命令调用 **≈22-26 次**；计划侧文件创建/更新 **≈16-22 次**（task_plan 5-7 次、findings/progress 各 ≥2、verification 1-2、INDEX 2-3、ledger 3-5、6 文件建档、attestation、哨兵）；模型 TodoWrite **4-6 次**；阻断式用户交互 **≥1 次**（D1+复述）；**2 个 Phase 各一次完整 6 步闭环**。
对照：任务本体 = **1 次 Edit（3 行）**。计划侧写入：本体 ≈ **16-22 : 1**。
实证旁证（真实任务 task-v090-workflow-auto-activation）：plan 目录终态 9 个文件 386 行 + ledger + .session-owner；plans/INDEX.md 常驻刷新机制（Rule 23.7 每 10 次工具调用）。

**若未声明 mini（默认路径）**，叠加：general 模板 **419 行**（templates/task_plan.md:419 行实测；13 个 variant 79-152 行）填充、VC≥5 条（check-complete.sh:549 vc_min=5）、FMEA 预演段（attest-plan.sh:130-149 + check-complete.sh:474-511 双点校验）、「必要知识储备」表 + knowledge-brief 五段（SKILL.md:555-557）、委派率 floor 0.7 判定（check-complete.sh:114）。

---

## 二、常驻 hook 税（与档位无关，每工具调用/每轮都付）——本会话实测

| 测量项 | 命令 | 实测结果 |
|---|---|---|
| PreToolUse hook（每次 Write/Edit） | 8 次 python subprocess 计时，输入 /tmp/noplan | **1.21-1.25s/次**（mean 1.23s） |
| 同上，xtrace 事件定位 | `PS4='+T $EPOCHREALTIME' bash -x` | 249 个命令事件；单一最大项 = check-scope.sh 0.106s + check-delegation.sh 0.064s；**其余 ≈1.0s 分散在 Rule 23 冲突循环 zcode-pretooluse.sh:91-116：对 37 个 plans/*/task_plan.md 逐个 dirname/awk/grep/grep/awk/tr/echo/basename/grep ≈9 次 fork**（本机 0.65s 实测 check-conflicts --runtime 同量级） |
| PostToolUse hook（每次工具调用后） | Edit task_plan 场景 | 0.20s/次 |
| UserPromptSubmit hook（每用户轮） | 真实仓活跃计划，4 次实测 | **0.85-3.06s/轮**（无计划基线 0.085s；内嵌 check-conflicts --runtime 0.65s + attest --verify + 多次 jq/awk） |
| check-complete.sh（终验） | task-v090 计划 | **1.99s**，rc=0 |
| check-dispatch.sh（每次 Agent 派发前） | pretool 模式 | 0.30s |
| check-delegation.sh stats（check-complete 内嵌） | task-v090 | 0.24s |
| selftest-plan-tier.sh（28 断言） | `bash scripts/selftest-plan-tier.sh` | **28 PASS / 0 FAIL**（mini 档行为断言全绿） |

关键事实：
- PreToolUse 的 O(N) 慢点技能自身已登记未修：SKILL.md:451「E4 慢注入(Rule 23 O(N))未修，登记 deferred」。
- 该 hook 还有一个放大因素：zcode-pretooluse.sh:94 用 `CWD="${PWD}"`（进程环境 PWD）而非 stdin JSON 的 `.cwd` 字段——本会话从任意目录触发 Write 时都会扫本仓 37 个计划（xtrace 实证：输入 cwd=/tmp/noplan 仍遍历 /mnt/data/dev/task-planner-skill/plans/*）。
- 对 mini 任务影响折算：全链路 ≈12-16 次工具调用 ×1.2s PreToolUse + ≈4-6 个用户轮 ×0.9-3s UPS ≈ **20-35s 纯 hook 开销**，接近甚至超过任务本体执行时间。
- 随仓库 plans/ 增长线性恶化（plans/ 目录已有 40 个任务目录，本仓按每任务一目录惯例持续增长）。

---

## 三、Rule 38 mini 轻量档解剖——「5 锚点到底豁免了什么」

### 3.1 判定与启用方式
- 判定（38.1）：`plan_tier: mini` ∧ scope_files ≤2 ∧ 预估 ≤15min ∧ 单模块；三条件机器可测（check-plan-dispatch.sh:91-103 MISMATCH 探针）。
- **启用是 opt-in 而非自动**：init-session.sh:99 `PLAN_TIER="${3:-${TASK_PLAN_TIER:-}}"` 需要第 3 位置参或 env；SKILL.md 初始化步骤（:60-75）的初始化命令示例 `bash scripts/init-session.sh` **不带 tier 参数，流程中无任何「判定应走 mini」的步骤**——判定规则只存在于 Rule 38.1 条款与合规清单 C26（SKILL.md:203），靠模型自觉执行。忘传 = 落到 general 419 行模板（selftest PT-15/PT-26 实证缺省产物为 general 源）。

### 3.2 五锚点逐个核对（38.4）
| 锚 | 豁免内容 | 对「主进程直做的 trivial 任务」实际增量 | 证据 |
|---|---|---|---|
| ① attest FMEA 段 | FMEA 段缺失直接 OK（MINI-TIER SKIP） | **真实增量**：省掉计划里 FMEA 表填写（standard 双点校验 attest:130-201 + complete:474-511） | selftest PT-18 实证 SKIP 行 |
| ② VC-GATE | VC ≥5→≥2；V-N 阈值 2→1；无映射行不阻断 | **真实增量**：省 3 行 VC + V-N 映射行（complete.sh:547-550,637-638） | selftest PT-19 实证 PASSED |
| ③ 委派统计 floor 0.7→0.0 | main_direct 理由全部视白名单 | **≈零增量**：standard 路径下主进程理由命中 25.3 六项白名单本就 WHITELIST-EXEMPT 放行（check-complete.sh:424-433；critical-rules.md 25.4a），mini 只是把「理由措辞必须像白名单」这个格式要求也免了 | 完成门豁免逻辑读码 |
| ④ S-unit 表豁免 | Executor 全主进程的 Phase 免 S-unit 表 | **零增量（死代码）**：check-plan-dispatch.sh:172-174 standard 路径已对「主进程 Phase」return 0 不要求表；:178 的 MINI_EXEMPT 分支仅在 MINI_EXEMPT=1（=无任何子代理 Executor）时可达，此时 :172 必然已放行 → 永不可达。实测探针：同一「主进程 Phase 无 S-unit 表」计划，无 plan_tier 时 rc=0 `fail-open: 无派发型 Phase`，加 `plan_tier: mini` 后 rc=0 输出完全一致（除 MISMATCH 提示） | 本会话探针 1/2/3 |
| ⑤ knowledge-brief 降为可选 | brief 降为单段「速览」（流程层） | **半吊子**：init-session.sh:183,240 仍创建 knowledge-brief.md 并 6/6 复核（mini 档无差别），省的只是填写功夫；文件仍在磁盘上成为空档产物 | init-session.sh:183-251 |

结论：5 锚点中真正给 trivial 任务减负的只有 ①②⑤（省 ≈15-20 行计划内容），③④ 对纯主进程任务零增量。**锚点全部落在「计划文档内容」层，没有一个落在「流程步数」层。**

### 3.3 mini 档仍保留的仪式（无任何豁免）
逐项核对 Rule 38.4 与「边界明示」（critical-rules.md:341）+ 全文 grep 无豁免条款：
1. **2 个 Phase 的完整执行闭环**：38.3③ 固定「实施+验收」两 Phase，每 Phase 走 SKILL.md:88-107 全部 6 步（翻转/Todo/委派检查/回填/gate/commit/index/drift）——验收 Phase 对 3 行修改是独立仪式闭环。
2. **3-File 回填门控**（Rule 19.2 仅「降为 Phase 级一次」——mini 本来就 2 个 Phase，仍 = 2 次 findings/progress 回填 + 2 次 check-3file-gate.sh）。
3. **ledger 工作账本**（Rule 19.8，且它是 3-File Gate 主信号——不可简单删除）。
4. **Todo 同步 S1-S5 全套 + sync-todos.sh --json/--index ×2-3 + INDEX.md 全量重写**（SKILL.md:72,101,208；grep Rule 38 无 Todo 豁免）。
5. **attest 锁定 + 3 个子门控**（check-plan-dispatch/check-template-type/FMEA 检查本体仍跑，仅 FMEA 结果对 mini 放行）。
6. **终验 check-complete.sh ≈10 道门中 8 道原样**：mini 只降 VC-GATE 阈值与委派 floor 两处（check-complete.sh:118-120,547-550,637-638 是全脚本仅有的三个 mini 分支）；porcelain/3-File stub/Batch/rescue/Learning/Reflect/SKILL-MODIFY/mechanism-profile 全部照跑。
7. **DRIFT CHECK**：Rule 15 高频漂移（每 2-3 todo/每 3 次工具调用/每 Phase complete）+ C4a check-drift.sh --json——边界明示「漂移检测在 mini 档不变」。
8. **Rule 27 逐 Phase git commit** + porcelain 校验（mini 无豁免）。
9. **D1 用户确认轮 + 28.2.1 复述**（ask 默认，config.json interaction_mode default=ask；38.4 无豁免）。
10. **C1-C27 合规清单 27 项逐项判定**（SKILL.md:175-204，「每 Phase 开始前逐项确认」；对 mini 大多 N/A 但仍需逐项过一遍并记行）。
11. **Handoff 登记表 + 终验委派统计段**：Executor=主进程也要填「（派发时填写；全程主进程填『无』）」行（mini-lite 模板:49）并在 verification.md 写委派统计段。
12. **哨兵门**：SessionStart 哨兵存在期间 PreToolUse 拦截一切非 plans/ 写入（zcode-pretooluse.sh:18-23 + check-scope.sh:92-163 exit 1→hook exit 2）——3 行修改也必须先完成 6 文件建档才能动手。

---

## 四、核心问题回答：为什么有了 mini 档，简单任务还是慢

1. **mini 裁的是「计划文档区块」，不裁「流程步数」**。5 锚点省的是 FMEA 表、VC 3 行、brief 内容（≈15-20 行文档），而全链路 ≈22-26 次脚本调用、≈16-22 次计划侧文件写入、2 个 Phase 闭环、4-6 次 TodoWrite 一个不少。对 3 行修改，时间花在仪式编排而非任务本体。
2. **5 锚点有 2 个对目标场景零增量**：锚③（委派 floor）与 25.4a WHITELIST-EXEMPT 重叠；锚④是死代码（探针实证 standard 已放行同形态计划）。说明 mini 设计核对时未对照既有豁免面，5 锚点里真正的减负密度 ≈3/5。
3. **mini 是 opt-in**：初始化命令、SKILL 主流程、模板路由默认全指向 general/standard；判定规则藏在 Rule 38.1 + C26，模型每任务要主动想起传 `TASK_PLAN_TIER=mini`。未想起 = 419 行 general 模板 + VC≥5 + FMEA 全套。没有「检测到 trivial 自动降档」的机制。
4. **常驻 hook 税与档位正交且是大头**：每次 Write/Edit 1.23s（O(plans) 冲突扫描 fork 风暴，技能自认 E4 deferred 未修）+ 每用户轮 0.85-3.06s UPS。mini 任务全链路 ≈20-35s 纯 hook 开销——即使把计划仪式降为零，hook 税仍在。
5. **终验与 attest 的门控面几乎不随档位收缩**：check-complete ≈10 门中 mini 只松 2 处；attest 3 子门控照跑。每门虽是毫秒级脚本，但「门」背后是回填义务（Learning/Reflect/委派统计/质量门控统计三段填写），这些填写义务对 mini 全保留。
6. **验收 Phase 是制度性重复**：trivial 任务的验收（Read 复核 + 一条回归命令）本来内含于实施动作，mini-lite 却强制独立成 Phase 2 并走完整 6 步闭环（2 次翻转、2 次 Todo、1 次 gate、1 次 index、1 次 drift-guard）。
7. **D1 确认轮是唯一阻断点且无档位豁免**：15 分钟任务也要「展示全文+复述+等 yes」一整轮交互（ask 默认）。

### 对 trivial 任务纯属纯税的仪式清单（建议候选裁剪面，均带锚）
- Phase 2 验收 Phase 的独立闭环（38.3③ 固定 2 Phase）——纯税
- notepad-learnings.md / knowledge-brief.md 的 mini 建档（init-session.sh:183,240；mini 无内容可写，终验也不查二者 stub）——纯税
- C1-C27 清单逐项判定（对 mini ≈2/3 恒 N/A）——纯税
- 28.2.1 复述对 mini 档（可并入 D1 一句话）——近纯税
- check-drift.sh --json（C4a）与 Skill(drift-guard) 对 ≤2 Phase 任务的重复计数——近纯税（保留 Phase complete 级一次即可）
- sync-todos.sh --json + --index ×2-3（INDEX 全量重写对单任务两次无增量）——近纯税
- Handoff 表「无派发」行 + verification.md 委派统计段（对全程主进程任务）——近纯税
- ⚠️ 有质量职能、不可直接裁的：哨兵门、attest、3-File Gate、check-complete 门组、ledger、Rule 27 commit、冲突扫描（但可增量化/指针化消除 O(N)）

### 与上一轮审查报告的交叉
plans/task-planner-skill-review/report.md 已确认相关条目：#5/#13 goal-gate「≥5 条 VC」未同步 mini 降档（文档与机器门控不一致，模型照文档执行会拒绝合法 mini 计划）；#17 check-complete.sh:549-550 VC 阈值硬编码不读 config。本域新增：五锚点增量密度、锚④死代码、mini opt-in 无自动判定、hook O(N) 税的量化。

---

## 五、瓶颈登记（供汇总表引用，条条带锚）

| # | 标题 | 证据锚 | 类别 | 质量耦合 | 影响 |
|---|------|--------|------|---------|------|
| 1 | PreToolUse hook 每次 Write/Edit 1.23s：Rule 23 冲突扫描对全部 plans/*/task_plan.md 逐个 ≈9 fork，O(N) 且误用 $PWD 忽略 stdin cwd | zcode-pretooluse.sh:91-116（:94 `CWD="${PWD}"`）；实测 8 次 mean 1.23s；SKILL.md:451 自认 E4 deferred | both | medium（防并行踩踏职能，可指针化/增量化保留语义） | mini 任务 12-16 次工具调用 ≈15-20s 纯税，随 plans 数线性恶化 |
| 2 | UserPromptSubmit hook 每轮 0.85-3.06s：smart 注入 + check-conflicts --runtime(0.65s) + attest verify + 多次 jq | zcode-userpromptsubmit.sh:39,61,136；实测 4 次 | both | medium（防漂移注入有价值，可缓存/降频） | 每用户轮固定税，长会话累积 |
| 3 | mini 档只裁计划区块不裁流程步数：2 Phase 完整闭环×2、3-File Gate×2、Todo S1-S5×4-6、ledger、attest、check-complete 全保留 | critical-rules.md:341 边界明示；38.4 五锚全部内容层；SKILL.md:88-107 流程无 mini 分支 | simple | medium（3-File/ledger/Todo 是罗盘职能，裁剪需等价替代） | trivial 任务仪式:本体 ≈16-22:1（计划侧文件写入比） |
| 4 | mini 启用 opt-in 无自动判定：init 无 tier 自动路由，SKILL 主流程无判定步骤，默认 general 419 行模板 | init-session.sh:99,164-171；SKILL.md:64 初始化命令无 tier 参；selftest PT-15/26 缺省=general | simple | low | 未主动声明时 trivial 任务走全套重仪式，mini 实际命中率取决于模型自觉 |
| 5 | 终验 check-complete ≈10 门对 mini 仍跑 8 门 + attest 3 子门控无 mini 简化 | check-complete.sh 全文仅 :118-120,:547-550,:637-638 三个 mini 分支；attest-plan.sh:66-201 | simple | high（门控职能本体，不可撤只可降输出/合并） | 终验 2.0s + 各门背后回填义务（委派统计/质量门控统计三段）对 mini 全保留 |
| 6 | 5 锚点中锚④死代码（standard 已免主进程 Phase S-unit 表）、锚③与 25.4a WHITELIST-EXEMPT 重叠 | check-plan-dispatch.sh:172-180；本会话探针 1/2/3（standard rc=0 与 mini 输出一致）；check-complete.sh:424-433 | simple | low | mini 设计减负密度 3/5；改动时应核对既有豁免面防再加冗余 |
| 7 | D1 确认轮 + 28.2.1 复述对 ≤15min 任务无档位豁免（ask 默认阻断交互） | critical-rules.md 28.2/28.2.1；config.json interaction_mode default=ask；SKILL.md:79-80 | simple | medium（批准门有返工防护价值，可对 mini 压缩为单行确认） | trivial 任务 ≥1 次阻断式用户交互 |
| 8 | 验收 Phase 制度性重复：38.3 固定 2 Phase，验收独立走完整 6 步闭环（2 翻转+2 Todo+gate+index+drift） | mini-lite-type.md:31-43；SKILL.md:88-107 | simple | low-medium | 3 行修改的验收本可内含于实施，独立闭环 ≈10 个动作纯税 |
| 9 | 哨兵门强制 6 文件建档先于任何业务写入，其中 notepad/knowledge-brief 对 trivial 是空档产物（mini 不查其 stub） | check-scope.sh:92-163 exit 1→pretooluse:20-23 exit 2；init-session.sh:183-251；check-complete 3-File Gate 只查 findings/progress（:300-329） | simple | high（哨兵门=防无计划乱写的核心门控，不可撤；6 文件→3 文件是文档层裁剪） | 3 行修改也必须先建 6 文件+清哨兵才能动手 |
| 10 | 固定杂仪式：C1-C27 清单 27 项逐项判定、check-drift --json×2+drift-guard≥2 次、sync-todos --json/--index×2-3、Handoff「无派发」行+委派统计段 | SKILL.md:175-204,101-107,161；mini-lite-type.md:45-49 | simple | low | 每任务固定 ≈6-8 个动作，单项小、合计可观且挤占上下文 |

---

## 六、未竟事项（如实）
- 未实测 ZCode 宿主对 hook stdout 的 JSON 校验与注入延迟（宿主侧行为，本审计只能测脚本本体耗时）；实际每轮感知延迟 = 脚本耗时 + 宿主开销，只会更大。
- 未模拟完整一次「模型执行 mini 任务」的端到端计时（模型侧行为不可脚本化）；第一节计数为条款推演 + 真实计划（task-v090）产物侧证，非秒表实测。
- UPS hook 首测 3.06s 与复测 0.85-1.55s 的差异未做归因（疑冷缓存/磁盘），取区间报告。
- 检查过 check-delegation.sh / check-dispatch.sh / sync-todos.sh / ledger-append.sh 仅按调用链与行数引用，未逐行审读其内部正确性（属其他领域）。
