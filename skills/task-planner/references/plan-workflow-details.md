

## 计划制作循环（完整细节，自 SKILL.md 迁入，2026-11-28 task-skill-fix-defs-20261128）

<!-- [2026-11-28 task-skill-fix-defs-20261128] What: 自 SKILL.md 逐字迁入计划制作循环完整细节；Why: SKILL.md 瘦身门控；主干保留于 SKILL.md，本节作按需加载细节。 -->

## 计划制作循环

> **[P0] 两段式修复拆分判定（D1' 分级全覆盖 + D5 阶段二启动，强制）**：收到实现/修复/优化类请求时先做拆分判定，**禁止跳过**。
> - **分级全覆盖（D1'）**：修复类请求（报错/改错/bug/回归/异常）= 阶段一快修表层 + 产出完整根因线索包 + 阶段二从底层根治；非修复类请求 = 阶段一产出可用结果并尽早**合并回 master**、**不阻塞**下游 + 阶段二独立同族风险/隐患排雷（无风险以 `N/A`+证据收口）。
> - **升档铁律**：修复类请求命中 L0/mini/trivial/L0-E，**一律先升 L1 standard 复核，再走两段式**；不得以轻量档豁免跳过拆分判定（本判定优先于 :98-107 豁免块）。
> - **阶段一**：快刀修表层、快速产出；VC 复验通过后**立即合并回 master**，让依赖该成果的下游任务不被阻塞。
> - **阶段二**：独立 task-id（建议 `<A-id>-rc`），新 worktree 从底层排查根因、全面排雷，确保不再犯同类错误；与阶段一解耦，阶段二失败不影响阶段一结果。
> - **双向 tag 登记**：阶段一计划登记 `rootcause-followup:<B-id>`；阶段二计划登记 `followup-of:<A-id>`（INDEX 与计划元数据同步）。**根因线索包机器标记契约**：阶段一须用 `planctl add --section findings` 把线索包登记为 `[rootcause-followup:PASS] 线索包已落盘` 字面标记（非修复类无风险用 `[rootcause-followup:N/A]` + 理由），`planctl render` 后自动写入 findings.md 供 rootcause 消费门校验；禁只登记 tag 不写标记（门读 findings 正文，不读索引 key）。
> - **阶段二启动四要素（D5）**：执行者=阶段一主进程；触发时点=阶段一合并回 master 完成且 VC 复验通过后同轮；命令=`git worktree add <项目根>/tmp/worktrees/<A-id>-rc -b wt/<A-id>-rc master`（`--base master`）；失败口径=派发失败/会话结束仅在 INDEX 与 tag 登记 `pending`（`followup-of:<A-id>`），**不改阶段一 outcome、不回滚**。

- [ ] [M] **初始化（哨兵机制）— 机械子动作**：跑脚本建目录/设 env/校验在位/清哨兵
  > `[2026-09-10 task-planrequired-race]` 哨兵会话私有化：SessionStart 写会话私有哨兵 `plans/.plan_required_side/<sidkey>.plan_required`（sidkey=uuid core）；legacy `<root>/.plan-required` 仅兼容读取
  <!-- [task-perf-default-mini 2026-11-24] What: 分级缺省=mini，去掉 trivial/纯文档主观闸门；Why: 用户裁决默认简单 SOP、升级依据=客观运行时间而非主观判断 -->
  - 运行 `node --experimental-strip-types scripts/session-catchup.ts` 检测中断恢复点；创建 `plans/{task-id}/`，运行 `bash scripts/init-session.sh "<任务名>"`（任务名=$1，渲染进产物；**分级缺省=mini**（task-perf-default-mini 2026-11-24：默认简单 SOP、不做主观判断；④排除 `TASK_TIER_EXCLUDE=1` 或显式 `TASK_PLAN_TIER=standard` / `TASK_AUTO_TIER=0` 才落 standard）；升档双判据（软阈值默认 15min，`TASK_PLANNER_TIER_UPGRADE_MINUTES` 可调，须联合步骤门：phase complete / findings/research 落盘 / delegations 非空；无信号时硬兜底默认 45min，`TASK_PLANNER_TIER_UPGRADE_HARD_MINUTES` 可调；至少完成调研后升档才有参考价值，2026-11-24/25 用户裁决）由 posttooluse hook 自动升级 standard 检查面）
  - **无 hook 工具位升档自查（task-tier-deadzone-fix-20261125）**：claude/cursor/opencode 位无 zcode 的 posttooluse tier hook（其 PostToolUse 挂 check-doc-sync.sh 零 tier 逻辑）——主进程在三时机自查升档：①Phase 翻转后 ②每 10 次工具调用（S3 节奏）③收尾回读前；判据同 hook 双判据（时长>15min ∧ 步骤门[phase complete ∨ findings/research 落盘 ∨ delegations 非空] ∨ >45min 硬兜底），命中即 `planctl set --field plan_tier --value standard` + render + Decisions 登记 +（mini 骨架先补 R/VC 区块）重 attest；`tier-upgrade-check.sh` 已随技能部署可手动跑（plain text 输出，幂等 per-plan）。本条款=hook 不可用时的文本兜底，非 hook 位升级责任在主进程，禁以「无 hook」为由永不升档
  - **模板检索前置**：init 前先 `bash scripts/template-catalog.sh list --json --scope all` 取清单再选 `template_type`；细则见 references/plan-workflow-details.md §命令速查与脚本索引。
  - **脚本侧渲染（tplrender）**：init 自动替机械占位符（6 变量+8 旧形态映射）；模型禁手修机械占位，仅填语义占位；细则见 references/plan-workflow-details.md §命令速查与脚本索引。
  - **auto-tier env 变量**：`TASK_AUTO_TIER=1`+体量 env（`TASK_EST_MINUTES/TASK_SCOPE_FILES/TASK_SCOPE_MODULES/TASK_SCOPE_FILE_LIST/TASK_EST_LINES/TASK_TIER_EXCLUDE`）；细则见 references/plan-workflow-details.md §命令速查与脚本索引。
  - **会话隔离指针**：活跃计划经 `resolve-plan-dir.sh [root] [sid]` 双参解析（side 指针优先于全局 fallback；残留由 `set-active-plan.sh gc` 清扫）；**上下文压缩恢复（2026-11-24 task-session-regression-20261124 / task-compact-skill-always）**：压缩后 SessionStart hook 注入 `[compact-recovery]`——技能正文 SKILL.md 全文**无条件注入**（`planctl.py recover-skill`，无在途计划也注入，因压缩会冲掉整个技能体系）；有在途计划时再附加任务核心状态（权威源 `plan-state.json` 经 `planctl.py recover`），以包内字段为准续做，禁仅凭摘要续做
  - **模板优先级**（init-session.sh 自动处理，三层）：**项目级 → 用户级 → 内置**；当前 Agent=ZCode 时优先项目 `<项目>/.zcode/plan-templates/` 与用户 `~/.zcode/plan-templates/`（`.claude/plan-templates/` 仅兼容探测）→ 兜底 `<platform-home>/skills/task-planner/templates/`。选型先分析任务再按该顺序扫描匹配；模板生成/派生须经调研前置并获用户明确审核授权后方可落盘（禁 silent 自动落盘；选型/生命周期权威源=卫星 `plan-template-kit`，Rule 16/34）
  → 模板检索与选型细则（按需加载）→ 详见 references/plan-workflow-details.md §template-catalog；触发：制作/审计计划需要模板选型细则、template-catalog 操作或 JSON 模板 SOP 时；关键词：模板选型 template-catalog 变体 render JSON
  - **验证**：7 文件在位（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief/user-session-log，Rule 80）
  - **S1 同步**：`bash scripts/sync-todos.sh --json` → 每 Phase 一条原生 Todo；**禁止只建计划不建 Todo**
  - **进度产出基线登记（Rule 111）**：计划期登记 `📦 进度产出基线`，禁倒退清单随计划 attest 锁定（交付/合并/返工均不得就地删降替）
  - **检索排除清单纪律（Rule 112）**：任何检索前先读项目根 `RETRIEVAL_EXCLUDE.md` 并按「可排除/必须纳入」条件排除（跨调研/执行/回找多域，L0-T 文本锚；详见 references/critical-rules.md Rule 112）；触发：执行检索前需确认排除清单或判定可排除/必须纳入边界时；关键词：检索排除 RETRIEVAL_EXCLUDE Rule112
  - **清除哨兵**：`node scripts/plan-created.cjs`（双清除 side+legacy）；哨兵存在期间 PreToolUse hook 拦截非 plans/ 路径 Write/Edit（exit 2）

  → 初始化委派细则（按需加载）→ 详见 references/plan-workflow-details.md §init-delegation；触发：计划初始化需委派 plan-writer、收窄主代理职责或处理计划期单写者边界时；关键词：初始化 委派 plan-writer 收据 单写者
  - **可选前置（历史经验）**：L1+ 新任务主题涉同类改造/既有机制扩展/曾犯错领域时，建议先 Skill("plan-history-recall") 产出 history-brief 再定方案；不强制，L0-T/mini 跳过

- [ ] [A] **初始化（哨兵机制）— 智能子动作**：体量分级判定与隔离决策
  - **冲突分析**：`bash scripts/check-conflicts.sh` → 结果+隔离决策写入 task_plan.md「🔀 隔离决策」（实现类默认首选 worktree；首动作委派子代理已起草时=复核/校正，不重写）
  → 冲突分析与隔离决策细则（按需加载）→ 详见 references/plan-workflow-details.md §conflict-isolation-options；触发：初始化判定 worktree 隔离或 Spec 模式路由、需要隔离选项思路时；关键词：隔离 worktree 冲突 Spec 路由

- [ ] [A] **计划独立审计门（D1 前强制 — audit-before-delivery，Rule 109）**：L1+ 计划在展示/授权前必须经独立子代理审计迭代达标，未经审计的产出禁交用户
  - **触发**：计划产出（主进程盘上复核 Rule 84.4 完成后）且智能子动作（冲突分析+隔离决策复核+Spec 判定）完成之后、本区块「[A] 计划确认」展示之前；B/C/D/E 类任何计划（再）展示/确认前同样过门，修订重审可用简版（仅审变更增量+上轮问题清单闭环）
  - **分档豁免（Rule 38.7 比例原则）**：L1+ 强制；mini/L0/trivial 类档位下仍需按实际改动类型判断——其中 **L0-E（零仓库受管变更且仅机械产物区/gitignore 区操作）** 可豁免审计门等轻量流程，但 **工作树隔离判定不因“trivial/L0”而绕过**：交付型 Markdown（小说/写作/长文档/多章节）或预计改动 >2 行/多文件 → 仍 **REQUIRED worktree**（详见 `references/worktree-isolation.md` §2，2026-11-27 用户裁决）；仅非交付型过程文档且 ≤2 行 trivial 可豁免。
  <!-- [task-perf-default-mini 2026-11-24] What: 审计收敛依据改挂脚本锚；Why: 与 critical-rules/plan-workflow-details 口径对齐，避免「不设上限」被误读为无刹车 -->
  - **审计体（独立上下文，只读）**：首选 critic（「审查计划/review 文档」触发在位）；不可用降级链=critic 失败→重试 1 次→decision-arbiter→general-purpose→AskUser（逐级留痕）；审计分歧→decision-arbiter（Rule 69.1）；修正执行=主进程驱动 Plan Writer 重派（22.4a/62.2 计划期单写者不变）；**审计轮次脚本刹车（2026-11-24 task-perf-default-mini）**：累计 2 轮 REJECTED 且无 APPROVED → planctl 写入打印 [audit-cap]，Agent 派发被 PreToolUse 拦截（decision-arbiter 例外），直到登记 [audit-converge]；「轮次不设上限」仅指有实质进展的迭代。96.7/109 门不变。
  → 计划独立审计门细则（按需加载）→ 详见 references/plan-workflow-details.md §audit-gate-details；触发：L1+ 计划进入 D1 前审计、判定 APPROVED/REJECTED 或处理审计无进展刹车时；关键词：审计 audit APPROVED REJECTED 刹车

- [ ] [A] **计划确认**
  - 展示 `task_plan.md`（Phase 列表+VC 表）给用户，附计划文件绝对路径+待审项清单+看点+动作（Rule 70 四要素）；**VC 每项须含可执行验证命令（Rule 84.1）**——验证域规则与 SOP 详见卫星 `verification-gate`（`Skill("verification-gate")`）；触发：计划确认前需核对 VC 可执行命令或查验验证域 SOP 时；关键词：计划确认 VC 验证门 verification-gate
  - **指令理解对齐（Rule 28.2.2）**：计划确认前须已完成/呈示 3-4 轮理解迭代草稿（原始指令→理解→思路与候选+歧义门控→大体方向，粗稿非定稿）以暴露方向供纠偏。**goal/目标迭代（28.8）优先覆盖**：明确或歧义/多候选均**禁止**向用户提问/列选项请求确认/等待回复，按推荐项或可逆安全默认静默自决并留痕后直接继续推进（歧义仅内收敛+登记假设）；同问禁复发；预算外硬门（28.9②）不停表——登记待授权清单后继续，收到续推指令按 28.9③-⑤ 幂等处理。**非 goal**：明确任务不因本模块新增停等确认（无歧义时提示可纠偏后继续），仅歧义/多候选(典型3-4)或关键范围不明时按选项确认（28.3）；silent/44.3 自动通过/mini 缺省 silent 场景按 28.2.2 降级留痕与推荐项自决，不做多轮阻塞。
  → 计划确认与指令对齐细则（按需加载）→ 详见 references/plan-workflow-details.md §plan-confirm-alignment；触发：计划确认前做指令理解对齐、交互模式判定或 goal 静默自治决策时；关键词：计划确认 对齐 交互模式 goal 自治
  - **交互模式（Rule 28）**：ask 模式在计划全文后口头复述大体执行思路（≤5 行，28.2.1）并登记 Decisions Made；silent 模式自动通过+交付附静默决策清单；解析优先级 env > 计划配置表 > config.json > 默认 ask；**goal/目标迭代语境强制自治（28.8）**：/goal 续推下选择/确认全静默按推荐项自治并留痕，禁止询问阻塞与同问重复，预算外硬门不停表——按 28.9② 登记待授权清单后继续；宿主 goal verifier 续推指令一律按 28.9③-⑤（差异归因一次→固定点应答），用户授权消息到达按 28.9⑦ 立即执行预案（D6 类项须逐项显式确认）（见 critical-rules-discipline 28.8/28.9/44.3/44.5）
  - **规则编号预留（Rule 20.6）**：新增 Rule 编号在计划声明 `new_rule: <NN>`；attest 自动查重登记（账本 `plans/.rule-reservations.jsonl`）
  <!-- [task-output-example-contract-20261125] What: 计划确认前核对 output_examples；Why: 防「声明输出格式却无样例」的表面专业实质不可用（Rule 113） -->
  - **输出示例契约核对（Rule 113/113.10）**：**第一动作=先向用户展示产出示例实物**（真实路径/可读代码块 + 同结构占位模板 + 审查命令与预期输出），再写条款/方案；权威形态见 `examples/json-template-upgrade/review.md`。产出计划前核对 `output_examples`——凡交付物声明输出格式（JSON/Markdown/表格/API 等）必须已有完整示例 + 同结构可复用模板，禁只写格式不给样例、禁仅标题 token；示例经 `planctl add --section output_examples` 写入并由 `planctl render` 派生到 task_plan.md 同名区块（模板见 `templates/variant/` 同名区块；mini/L0 极简档至少 1 条）；新计划锁定经 `attest-plan.sh [example-gate]` 拒缺/空/占位

- [ ] [M] **Poka-Yoke 前置检查**（`references/methodology.md` §R1/R2）：依赖文件存在/上 Phase 产物非空/必要配置在位；高风险 Phase（FMEA RPN>100）须登记预设兜底动作；不满足先修前置

  - **用户否决与禁令追踪（Rule 32）**：用户否决方案登记 notepad「🚫 被否决方案」段；复用前先查否决记录，禁静默改回。  <!-- [2026-11-28 FIX-2 R2 补迁] -->
  - **专业技能协同路由**：协同路由权威源=`plan-collab-router/references/skill-collaboration.md`；触发：任务涉及 comet/OpenSpec/superpowers/dynamic-workflows 协同路由时；关键词：skill-collaboration 协同路由。  <!-- [2026-11-28 FIX-2 R2 补迁（SKILL 瘦身迁移）] -->
  → 拆分模式库（按需加载）→ 详见 `../task-dispatch/references/split-pattern-library.md`；触发：计划期拆分 S-unit、选拆分模式或查粒度判据时；关键词：split-pattern-library 拆分模式 粒度 P1-P13  <!-- [2026-11-28 FIX-2 R2 补迁（SKILL 瘦身迁移）] -->
- [ ] [A] **思维方法论解构**（`references/methodology.md` T1-T5，指针）：计划期已按问题先行三问+5 Whys+结论先行附推导链完成解构，答案落 task_plan「核心问题定义」+findings.md；方案终裁（Rule 69.1 T1）≥2 候选难决→委派 decision-arbiter，不硬决不直接 AskUser
  → 思维方法论 T1-T5 细则（按需加载）→ 详见 references/plan-workflow-details.md §methodology-t1-t5；触发：计划期做问题解构、5 Whys、结论先行或方案终裁需要方法论支撑时；关键词：方法论 T1-T5 5Whys 解构 终裁

- [ ] [M] **共享内容追踪检查点（Rule 30）— 机械子动作**：命中则 `Skill("progress-tracker")` 建/用项目级账本（`.zcode/ledger/`），逐 target 认领登记+收尾 Todo；未命中 → Decisions Made 记不适用理由
- [ ] [A] **共享内容追踪检查点（Rule 30）— 智能子动作**：判定是否命中 30.1 识别条件（可枚举共享资源只认领一部分 / 同类任务 ≥3 次）
  → 共享内容追踪检查点细则（按需加载）→ 详见 references/plan-workflow-details.md §shared-tracker-options；触发：判定是否命中共享追踪条件、需要建立项目级账本或认领登记时；关键词：共享追踪 账本 progress-tracker 认领

- [ ] **Phase 执行循环（每 Phase 独立闭环）**
  1. [M] **开启 Phase**：`planctl phase-start --id P<n>` 后 `render`（task_plan.md=派生视图，禁手工 Edit）；**R 锚定复诵**（v168）：Read「🎯 用户需求原文」→ 经 `planctl add --section actions` 落盘 `- **R 锚定**：本 Phase 服务 R<n>「<一句话复述>」`（随 render 入 progress 视图）；与 Goal 或当前动作不符=先修计划再开工
  2. [M] **同步 Todo（S2）**：对应 todo→in_progress；步骤 1/2 必须紧邻执行
  2.5 [A] **委派检查点（Rule 25）**：Phase Executor≠主进程 → 立即按九字段模板逐 S-unit 派发子代理（路由表/粒度门/伴飞/返回校验/兜底详见卫星 `task-dispatch`）；触发：Phase Executor 非主进程需派发子代理或查派发路由/兜底时；关键词：委派 子代理 派发 路由 兜底。主进程只保留派发/回填三文件/验收 Read；无 Executor 字段=计划无效先回炉；禁止"先自己干再派"
     **使用点标注速查（Rule 104.2 就地版 — 默认执行体，偏离须 `[markup-exempt] 理由`）**：
  → 执行体使用点标注速查（按需加载）→ 详见 references/plan-workflow-details.md §execution-agent-quickref；触发：派发 Phase 前确认默认执行体、伴飞标注或 markup-exempt 豁免时；关键词：执行体 派发 标注 executor 豁免
  2.5b [A] **技能激活确认**（v168）：派发前 Read knowledge-brief.md §6 可用强化技能清单 → 择优伴飞激活并登记 Handoff（用户触发型技能仅提示不代激活）；**资料消费锚（task-resource-utilization-20261123）**：本节命中并复用 kb/findings 既有条目时，同轮 `planctl add --section knowledge_use --json '{"id":"KU<n>","phase":"<P>","source":"<kb:§N|findings锚>","purpose":"<消费点>"}'`（复用既有 section，零新字段/新门；未命中无需记）
  2.5c [A] **动作相关性三问**（v168）：新文件/新命令/新 S-unit 动手前过三问——① 服务本 Phase R 锚定？② 在 scope_files 内？③ 用户原话要求过？任一 No→记录不执行
  2.5d [A] **变更类型判定（Rule 74 三判门，P0）**：对既有文件/条目的每处变更，执行前必须判定变更类型（增量/替代/删除），答案登记 task_plan.md「📋 变更标注表」：
     - **增量（默认且优先）**：用户措辞含"补充/再加/还有/另外/同时"或语义为新增条目 → 只追加、既有条目逐字保留不动；"补充一些条目"类指令永远走本档，禁以"整合/去重/顺手重构/格式化"名义回写既有条目
     - **替代（禁默认，四条件全满足才可）**：① 既有内容被新证据或回归测试证伪，或已被用户明示否决/作废；② 替代范围完整覆盖旧场景；③ 替代前已 Read 旧内容全文；④ 替代后既有守护/selftest 全绿。缺任一 → 回落增量
     - **删除（最高门槛）**：必须取得用户逐项授权；未授权只可停用/标记，禁物理删除
  → 变更类型判定与合规门细则（按需加载）→ 详见 references/plan-workflow-details.md §change-type-compliance-gate；触发：对既有文件做增量/替代/删除判定或填写变更标注表合规四元组时；关键词：变更类型 增量 替代 删除 合规门
  2.5e [M] **Agent 失败会话级留痕（task-agent-failure-ledger-20261123，用户裁决）**：主进程每次 `Agent()` 调用**返回失败**（provider 限流/超时/UNKNOWN_ERROR/输出不可信被驳回等任何非成功返回）时，**紧邻一次** `bash <skill>/scripts/agent-failure-ledger.sh append <plan-dir> <sid> <agentType> "<失败原因>"`，把 `{ts, agentType, reason}` 追加到本任务 `.agent-failures/<sid>.jsonl`。
  → Agent 失败会话级留痕细则（按需加载）→ 详见 references/plan-workflow-details.md §agent-failure-ledger-details；触发：Agent 调用返回失败需要 append 留痕或交付时汇总失败台账时；关键词：Agent失败 留痕 ledger 失败台账
  3. [M] **执行 Phase 工作**（内嵌 3-File 落盘，Rule 19）：
     - **3a 子代理产出回填（19.1）**：每次子代理/调研 Skill 返回后**紧邻一次 `planctl add --section research`（结论摘要+证据路径）+ `render`**；回填完成才勾 Handoff `verify_done`（Read 产出+findings 双条件）；验收争议（Rule 69.1 T4）→ decision-arbiter 仲裁。**采集→消费闭环（task-resource-utilization-20261123）**：每条采集结论回填 research 时同轮补一条 `planctl add --section knowledge_use --json '{"id":"KU<n>","phase":"<P>","source":"<research锚>","purpose":"<下游消费点;未消费写「未消费 因__」>"}'`——把「查了却悄悄丢掉」变为「回填时显式声明去向」；purpose 留空或缺失视为该采集未闭环，收尾回读门（84.14）逐条核对。复用既有 section/schema/render（planctl.py knowledge_use），零新增脚本/门/hook。
     - **3b 2-Action Rule（Rule 3）**：每 config.json#max_view_browser_before_save（默认 2）次 view/browser/search 后写 findings.md；多模态内容立即转文字落盘
     - **3c 动作留痕**：关键动作随做随记 progress.md；错误**立即**写 Error Log（19.4）并同轮完成四步（v168：记错误原文→Rule 31.2 四问根因→纠正→复验回填，未完禁下一动作）；关键动作同步 `bash <skill>/scripts/ledger-append.sh <plan-dir> <event> <summary> [--phase N]`
     - **3d hook 响应**：`[plan-sync]`→按 `references/todo-sync.md` §4 协议回写；`[plan-compass]`（findings/progress 陈旧，Rule 19.7）→立即回填再继续
     - **3e 上下文卫生（Rule 29，细则→task-discipline）**：每 2 个 Phase 跑 `bash scripts/check-context-hygiene.sh`；工作文件整理在会话恢复/用户指令时运行
     - **3f 周期性三文件对照**（v168/R3）：每完成一个 S-unit（或每 10 次工具调用），Read task_plan Goal+Phase 状态与 progress 尾部对照；不符按 Rule 65.4 标 `[corrected]` 回错误步并一句话记 progress
  → Phase 上下文回想细则（按需加载）→ 详见 references/plan-workflow-details.md §phase-context-recall；触发：Phase 执行中做周期性三文件对照、回想目标或纠偏漂移时；关键词：上下文回想 三文件 对照 漂移 纠偏
  - **3h 双轮质检（Rule 103）**：子代理返回→核 checkpoint 自审段（103.2）→Read 产出（84.4）→派全新复检体（103.3，升档 103.4/简洁五要素 103.5）→复检回执落 checkpoint；多文件变更集附同步核对清单（103.6）。复检体全文回读被改文件并整体分析（103.3a 义务，2026-11-14 task-audit-fullreread-20261114）。
  - **3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量（106.1-106.4）；同文件 ≥2 次修改后全量回归（106.3）——细则→task-discipline Rule 106；结构文件插段另守 106.1a
  4. [M] **回写计划**：Phase→`complete`+勾选+证据路径；**⚠️ 3-File 回填门控（19.2）**：翻转前 progress Phase 段已回填（Actions/Files/Test Results）+ findings 本 Phase 有实质增量，`bash <skill>/scripts/check-3file-gate.sh <plan-dir>` exit 0 才可翻转（信号优先级 ledger 语义证据 > mtime；纯实施 Phase 一行 `[implementation-only]` 声明计增量）；**V-N 校验（Rule 84.3/84.4）**：翻转前逐项执行 verification.md 当前 Phase 段的 V-N 验证命令（SOP→卫星 `verification-gate` Step 2），V-N 未全 PASS→禁止翻转；**多文件变更集（≥2 受管文件）翻转前先过 103.6 同步核对清单（清单全绿才可翻转，Rule 103.6）**；**Git 差异门（2026-11-24 task-session-regression-20261124）**：Phase 翻转前由 check-3file-gate 第 8 条件自动跑 Git 差异分析，unresolved>0 拒翻
  - **对齐必选步骤**：修改完成后强制对齐——任何受管文件修改完成后、Phase 翻转 complete 前必须执行对齐核查，逐项核对关联面四族+部署位+引用面（字面/引用/部署镜像/断言面）同步完整性，清单全绿才可翻转，杜绝部分改部分丢弃（机器门=check-complete.sh ALIGN-ANCHOR GATE；mini 档豁免）
  4.5 [M] **提交工作产物（Rule 27 / git-rework-guard）**：实现类 Phase 翻转 complete 前 commit 本 Phase 产物（禁跨 Phase 攒批、禁 `git add -A` 盲扫、只 add scope 文件）；**单个 S-unit/大改动完成即 commit（不等整 Phase），让每个可回退点进版本历史**；非 git 记行跳过；deferred/用户显式豁免须写入计划。**返工第一动作=Git 找回**：QC FAIL/方向错/需回退 → 先 `git log --oneline` 定位正确 commit + `git checkout <commit> -- <file>` 精确找回，禁凭记忆重做；方向彻底错→丢弃 wt/<task-id> 分支（不污染 master）；细则→`references/worktree-isolation.md` §4.5+§4.6；**方向根本错误且阈值命中（96.7/103.8b）→走 §4.6 弃旧开新**：评估归因+用户确认→提取有效数据(salvage-manifest)→从基线牵新 wt/<task-id>-rN→新计划 restarted_from 登记，旧计划 outcome=RESTARTED(非 CANCELLED)（细则→§4.6）；**检查点（2026-11-24 task-session-regression-20261124）**：单个 S-unit/Phase 产物提交后执行 `bash <skill>/scripts/git-baseline.sh checkpoint <plan-dir> --label <S-unit 或 Phase id>`
  5. [M] **同步 Todo+索引（S2/S4）**：todo→completed；`bash scripts/sync-todos.sh --index` 刷新 INDEX.md
  6. [A] **[DRIFT CHECK]** 派发 `drift-checker` 偏移检查（载体 Rule 61/64，详见卫星 `task-drift-guard`）；触发：Phase complete 后或连续调用/切模块前需做偏移检查时；关键词：漂移检查 drift-checker ALIGNED BLOCKED。✅ALIGNED→继续；⚠️DRIFT→记 progress 警觉继续（「警觉 vs 返工」拿不准→decision-arbiter 裁决）；🔴BLOCKED→STOP 报告用户等决策。触发时机=Phase complete 后立即/连续 ≥3 次工具调用/切换文件模块前/用户新指令时（先过「用户新指令处理」判定）；留痕三件套（检查点+`ledger-append.sh drift_check`+Drift Log 行）缺一=未执行
     drift-checker=执行偏移/目标漂移的安全网（Rule 61/64），**非意图切换发起器**——用户新指令的意图变更走上方快速判定卡判定归属，偏移检查只在判定归属当前计划后才派发。
  → Drift Check 执行选项细则（按需加载）→ 详见 references/plan-workflow-details.md §drift-check-options；触发：Phase complete 后派发 drift-checker、处理 ALIGNED/DRIFT/BLOCKED 结论时；关键词：drift-checker 偏移 ALIGNED BLOCKED 留痕
- [ ] [A] **Code Review Gate**（仅 `code_review: required`）：全部 Phase complete 后、终验交付前触发；轻 diff（代码 ≤3 文件且合计 ≤50 行）单轮轻量审查，重 diff 全量多轮；`Skill("code-quality-review")` 输出 APPROVED 才可进入终验交付；CHANGES_REQUESTED→追加 fix-phase 回执行循环；CR 分歧（Rule 69.1 T6）→decision-arbiter

- [ ] [M] **终验交付 — 机械子动作**：跑终验门脚本/合并回/提交核验/Read 产出/归档
  - **3-File Gate（19.5）/GIT-BASELINE GATE（2026-11-24 task-session-regression-20261124）**：check-complete.sh 内置校验 findings/progress 非 stub（缺失/stub→exit 1→STOP 回填禁交付），终验自动跑全量 Git 差异分析并核 sidecar（B9/B10 缺证或 B11 unresolved>0→exit 1→STOP 禁出 outcome）
  - **隔离任务合并回**：worktree 内全 VC 复验且无未提交变更→`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`→清理 worktree/分支→主仓 Read 复验（合约见 `references/worktree-isolation.md`）；触发：worktree 任务终验合并回主仓、清理分支或复验合并结果时；关键词：合并回 worktree merge 清理 复验
  → 终验机械子动作细则（按需加载）→ 详见 references/plan-workflow-details.md §final-verification-mechanical；触发：终验交付跑门脚本、合并回、归档或防倒退终检时；关键词：终验 机械门 合并 归档 防倒退
  - **防倒退终检（Rule 111/106.8）**：交付/合并前执行 `🛡 防倒退终检`，对照 `📦 进度产出基线` 逐项判定净效果≥0，禁拆东墙补西墙
  - **检索排除清单（Rule 112）**：检索前先读 `RETRIEVAL_EXCLUDE.md` 按条件排除，避免临时/资料文件淹没会话
  - **计划归档（Rule 81.1）**：check-complete exit 0 后运行 `bash scripts/archive-plan.sh <task-id>` 将完成任务目录移入 plans/archive/——target 已存在=幂等报 `ALREADY_ARCHIVED` 视为通过；守卫拒绝（active 指针 / .session-owner 活跃 / Status 未全 complete，fail-closed）→ 保持原位并登记拒绝理由，禁止强移。Why：「在途在根、历史在 archive/」是 plans/ 存量唯一健康形态，防无限堆积致索引失真（task-v170；详见 references/critical-rules.md Rule 81）；触发：终验交付后归档完成计划或处理归档守卫拒绝时；关键词：归档 archive Rule81 守卫 plans

- [ ] [A] **终验交付 — 智能子动作**：VC 复验判定、质量门控与委派率核查、outcome 判定
  - **终验强制对齐**：终验交付判定前必须执行对齐核查，核对本任务全部修改的关联面四族+部署位+引用面同步完整性，零丢弃才可判定 COMPLETE；机器门=check-complete.sh ALIGN-ANCHOR GATE enforce 缺锚阻断
  - **按卫星 `verification-gate` 终验 SOP 执行（Rule 84.5 Step 3）**：Read `verification.md`，逐条复验 VC（每条带证据路径+可执行命令）；统一入口 `bash <verification-gate>/scripts/run-verification.sh <plan-dir>` 自动执行 VC 命令并汇总 PASS/FAIL；触发：终验逐条复验 VC 或运行 verification-gate 统一入口时；关键词：终验 VC复验 verification-gate run-verification
  - **全文档收尾回读梳理（Rule 84.14，P0 迭代门）**：全部 Phase complete 后、outcome 判定前，主进程全量回读六文档体系（用户需求专档 #1→最新/task_plan Goal+R+VC/findings 全结论/knowledge-brief 沉淀/progress 动作线/verification 验收记录）做五维互洽检查（需求↔目标↔执行↔验证↔知识，每维问「有无偏移/遗漏/未利用」）；**mini/纯文档轻量档收窄（2026-11-24 task-perf-tiers）**：plan_tier=mini 或 L0 档的收尾回读只做 task_plan.md Goal+R+VC 与 verification.md VC 记录两文档，其余四文档按需 Read（有偏离迹象才读）；触发：收尾回读按需补读其余四文档时；关键词：收尾回读 按需Read 六文档。五维互洽中"知识"维仅在本 Phase 有 research 采集时核对。标准档/涉及代码/多模块任务仍全量六文档，不变。**「知识」维新增逐条核对（task-resource-utilization-20261123）**：Read progress.md「📚 必要知识储备使用记录」表，本 Phase 每条 research/findings 采集结论应有 knowledge_use 行且 purpose 非空；缺失/空 purpose=补录消费点或在 findings 标注「未消费 因__」后重回读，禁采集后无声丢弃；发现偏移→登记（task_plan「收尾回读梳理记录」区块+progress `[recall-final]` 行）→修复→再梳理；**收敛出口=连续一轮零新发现才可出 outcome**，迭代轮次不设上限（用户裁决「不要怕浪费资源」）；触发：outcome 判定前执行全文档收尾回读与五维互洽时；关键词：收尾回读 五维互洽 Rule84.14 outcome
  - **收尾对齐与清理**：交付前按 task_plan 模板「🧹 收尾对齐与清理」板块执行——①对齐口径 ②清理本任务新增无价值注释（保留契约注，判例归档 forensics）；**清理范围仅限会被 Agent 读进上下文的 Skill 说明 Markdown（SKILL.md/references/templates），代码文件（.py/.sh/.ts 等）里的注释属保护对象、禁止清理**（不进 Agent 上下文、便于后期理解）；执行在 outcome 判定与合并回之前；证据落 progress `[align-final]`/`[cleanup-final]` 行；mini/L0-lite 档豁免。
  - **双轮质检与同步完整性终验衔接（Rule 103）**：终验前核对本计划各多文件变更集的同步核对清单全绿记录（103.6）；双轮质检细则→task-dispatch 卫星 Rule 103。
  - **质量门控统计（Rule 26）**：核查 Q1-Q6 触发与豁免登记；抽查 ≥3 条 Evidence（路径可 Read、结论可复现）；未处置违规按 Rule 26.3 降级 outcome，Q3→BLOCKED+STOP
  - **委派率统计（Rule 25，细则→task-dispatch）**：子代理执行 Phase 占比 < `config.json#delegation_rate_floor`（默认 0.7）或直做含白名单外理由→check-complete exit 1 回炉；**纯执行 S-unit 权重 0（P4，2026-10-22 用户授权）**：命中 L0-E 档（零仓库受管变更 ∧ 仅调用既有工具 ∧ 产物落 gitignore 区）的 S-unit **既不计入分子也不计入分母**——若计入分母会拉低委派率，方向与「机械操作免强制派子代理/免终验回炉」的豁免意图相反（审计判例 F9）；机器面=计划 Executor 行标 `L0-E`（或括注含「纯执行」）即识别，`check-delegation.sh stats` 已按此口径实现（分母扣减 + 该单元不判 violation + 整批皆纯执行时 rate=1.000 视为达标）
  - 交付结论 COMPLETE/PARTIAL/BLOCKED；**交付总结五要素**（Rule 48：全体指针绝对路径/可执行命令）按 `templates/delivery-summary.md` 输出
  - 交付总结模板：`templates/delivery-summary.md`（按需加载）→ 触发：终验交付生成交付总结时；关键词：delivery-summary 交付总结 五要素。  <!-- [2026-11-28 FIX-2 R2 补迁] -->
  - **挂起计划回切检查（intent-switch 回切）**：outcome 判定后、归档前，检查本计划 progress.md/Decisions 的 [intent-switch] 登记链（旧=<id>）与 plans/INDEX.md 待处理区——存在挂起计划则会话面输出【计划回切通告】询问是否切回：用户 yes=释放活跃指针→完成本计划归档/收尾提交→路由 Skill("plan-resume") 定向恢复该计划续推；no=登记保持挂起（[intent-switch] 追加 回切状态=no|保持挂起）。不自动切——切回也是目标变更，须用户显式确认，本回切门优先于 plan-resume 触发点③自主续推（本场景定向恢复须用户显式 yes）。多条挂起链按登记最近一条优先、逐条确认。（本检查须先于 [M] 机械子动作块的归档动作执行；归档置后）
  - 决策分级（Rule 72）/呈报四要素（Rule 70）/变更吸收三判（Rule 74）/编号列表规范（Rule 76）按卫星 `task-discipline` 全文执行
  → 终验智能子动作细则（按需加载）→ 详见 references/plan-workflow-details.md §final-verification-options；触发：终验做 VC 复验判定、质量门控、委派率核查或 outcome 判定时；关键词：终验 VC复验 质量门控 委派率 outcome

### 📄 产出落盘映射（3-File Pattern）

> 原则：**Context Window = RAM（易失），Filesystem = Disk（持久）**；恢复读序：task_plan（在哪/去哪）→ progress（做过什么）→ findings（已知什么）→ knowledge-brief（可复用什么）。

  → 产出落盘映射表细则（按需加载）→ 详见 references/plan-workflow-details.md §output-mapping-table；触发：需要确认某类产出应落盘到哪个计划文件或恢复读序时；关键词：落盘映射 产出 task_plan findings progress
| 调研蒸馏知识（可复用事实/锚点/易错点） | `knowledge-brief.md` §2/§3/§4（主进程单写者蒸馏，Rule 62.3 双落盘） | 22.5 复核时，Handoff 记双锚 `findings锚\|kb:§N` |

  → 读写矩阵细则（按需加载）→ 详见 references/plan-workflow-details.md §read-write-matrix；触发：确认主进程/子代理对计划四文件的读写权限边界时；关键词：读写矩阵 权限 主进程 子代理 四文件
### 合规检查清单（核心域，每 Phase 开始前逐项确认）

| # | 检查项 | 状态 |
|---|--------|------|
  → 合规检查清单 A 细则（按需加载）→ 详见 references/plan-workflow-details.md §compliance-table-a；触发：Phase 开始前逐项核对核心合规检查项 G1-G12 时；关键词：合规检查 清单 G1-G12 Phase 开始
<!-- [task-perf-default-mini 2026-11-24] What: G4 补 mini 档豁免口径；Why: 与 G9-G11 同款措辞，缺省 mini 后 drift-checker 派发豁免需可查 -->
| G4 | DRIFT CHECK 已派+留痕三件套齐（检查点/ledger drift_check/Drift Log 行；机器面=selftest-drift-check-subagent.sh + check-drift.sh，人工核查；mini 档豁免） | ☐ |
| G5 | 子代理结论已落 findings（含多模态转文字）；ledger 关键动作已追加 | ☐ |
| G6 | complete 前 `check-3file-gate.sh` exit 0（progress 回填+findings 增量，19.2）；Handoff verify_done 已勾（Read+回填双条件） | ☐ |
| G7 | 本 Phase 无未处置质量违规（Rule 26 Q1-Q6 或已豁免登记）；产物已 commit（Rule 27） | ☐ |
| G8 | 原生 Todo 已同步（S2）；用户新指令已过 D/A/B/C 判定（如有） | ☐ |
| G9 | 用户会话逐字记录自查（Rule 80，原 C56 并集承载）：每次用户发言已逐字落盘 user-session-log.md（80.1）；写入=append-only 历史条目零改写零删除零重排（80.2）；会话恢复先读专档再读 task_plan.md（80.4）；理解镜像已同号配对（80.7）；**决策前读取已过（80.8 五决策点：上抛裁决/反思门/交付双锚/派发双锚/周期对照，各读取动作有留痕或执行证据）**；（机器面=selftest-session-log.sh+check-complete SESSION-LOG GATE，记录内容人工核查；mini 档豁免） | ☐ |
| G10 | 计划完成后归档自查（Rule 81，原 C57 并集承载）：check-complete exit 0 后已执行 `bash scripts/archive-plan.sh <task-id>`（81.1，guard/ALREADY_ARCHIVED 幂等路径走通）；守卫拒绝（active 指针/活会话标记/Status 未全 complete，81.3）时保持原位不归档并登记拒绝理由，禁强移；归档后已重跑 `sync-todos.sh --index`（81.4）（机器面=selftest-archive-plan.sh+check-complete [ARCHIVE-GATE] warn，归档动作与拒绝登记人工核查；mini 档豁免） | ☐ |
| G11 | 修改完成后对齐核查：所有任务修改完成后已执行对齐核查——关联面四族（字面/引用/部署镜像/断言面）+部署位+引用面同步完整性逐项核对零丢弃，机器门=check-complete.sh ALIGN-ANCHOR GATE（enforce=缺锚阻断，mini 档豁免）；人工面=核对清单全绿 | ☐ |
<!-- [task-output-example-contract-20261125] What: 合规表增 G12 Rule 113 检查项；Why: 为 output_examples 契约提供每 Phase 可勾核的人机双验锚 -->
| G12 | 输出示例契约核对（Rule 113/113.10）：**先展示产出示例实物**（真实路径/可读代码块+占位模板+审查命令），再写条款；凡交付物声明输出格式（JSON/Markdown/表格/API 等）必须已有完整示例 + 同结构可复用模板，禁只写格式/仅标题 token；示例经 `planctl add --section output_examples` 写入并由 `planctl render` 派生；新计划锁定经 `[example-gate]` 校验（mini/L0 极简档至少 1 条） | ☐ |
> 非核心域合规项（派发/纪律/媒体/模板/调研/协同族）随规则迁至各卫星 `critical-rules-*.md` 全文（按需加载）→ 详见上方卫星路由表对应 `references/critical-rules-*.md`；触发：需查非核心域规则全文或判定规则归属卫星时；关键词：卫星规则 critical-rules 按需Read 归属

<!-- [task-perf-default-mini 2026-11-24] What: 汇总散落 mini 豁免为单一常置指针表；Why: 缺省 mini 后逐处翻规则成本高，冲突裁决以各门脚本为准 -->
> **mini 缺省档最小流程（2026-11-24 缺省 mini 后的常置口径）**：init 产物即 mini → 免计划独立审计体（Rule 75 轻量复核）、免双轮质检复检体（103.7 豁免面）、免 drift-checker 派发（G4）、免归档（G10）、收尾回读两文档（Rule 84.14，L141）、基线 todo 裁 6 条（B2/B6/B7/B8/B15/B16，sync-todos）；运行 >15min 且命中步骤门（phase complete / findings/research 落盘 / delegations 非空任一），或无信号运行 >45min 硬兜底，由 hook 自动升级 standard（[tier-upgrade] 注入；两阈值 env 可调），升级后以上全部恢复标准档。无 hook 的工具位主进程按三时机自查升档（Phase 翻转/每 10 次工具调用/收尾回读，判据同 hook 双判据，命中即 set standard+render+登记+重 attest；tier-upgrade-check.sh 已随技能部署可手动跑）。散落豁免以此表为索引，冲突以各门脚本为准。

### 🔁 原生 Todo 同步（强制）

计划文档=唯一事实源，原生 Todo（`TodoWrite`/Task）=执行视图。五个强制同步时机：**S1** 计划创建后建映射→**S2** Phase 状态变更后紧邻同步→**S3** `[plan-sync]` hook 提醒立即回写→**S4** 会话结束前终态同步+`--index`→**S5** 用户新指令影响计划后先改计划再重映射。映射规则与响应协议详见 `references/todo-sync.md`；触发：执行 Todo 同步 S1-S5、处理 [plan-sync] 提醒或核对映射规则时；关键词：Todo同步 S1-S5 plan-sync 映射。S1 两组结构（任务组+基线组 B1-B18，Rule 106.5）详见 references/todo-sync.md；触发：创建/核对基线 Todo B1-B18 结构时；关键词：基线Todo B1-B18 结构；B9-B11 的完成以 `git-baseline.sh` 写入的 sidecar 证据为准，非 todo 勾选（2026-11-24 task-session-regression-20261124）；B14 = 根因/风险线索包已落盘 + 后续任务已登记（非修复类标 N/A + 证据）；B12/B13 归方案A/H3（SP/OS 技能到达 + Spec 路由命中），两组语义不重叠。B16 = 合并回主分支+合并后回归核验（merge --no-ff/worktree 清理/selftest 不增 FAIL），合并证据读 plan-state.json 的 isolation.merge_back。B17 = 口径对齐（交付前拉平触及的过期计数与冲突条款，冲突锚 grep 无新增命中，证据 `[align-final]`）；B18 = 垃圾清理（Skill 说明 Markdown 历史旁注清理；代码注释保护不清理，证据 `[cleanup-final]`）[2026-11-25 task-skill-deploy-fix A7]।

### 🆕 用户新指令处理（计划影响判定 — 强制）

> **两段式拆分判定（同「计划制作循环」P0 条款，单一口径）**：新指令进入实现/修复/优化路径时，在 ② 判定前先过两段式拆分判定。修复类（报错/改错/bug/回归/异常）与非修复类均分两阶段（D1' 分级全覆盖）：阶段一快修表层/产出可用结果→VC 复验通过后立即**合并回 master**、**不阻塞**下游；阶段二独立 task-id（`<A-id>-rc`）新 worktree 从底层根治/同族排雷，双向 tag `rootcause-followup:<B-id>` / `followup-of:<A-id>`。**修复类命中 L0/mini/trivial/L0-E 一律先升 L1 standard 复核再走两段式**。阶段二启动四要素（D5）：执行者=阶段一主进程；触发=阶段一合并回 master 完成且 VC 复验通过后同轮；命令=`git worktree add <项目根>/tmp/worktrees/<A-id>-rc -b wt/<A-id>-rc master`（`--base master`）；失败=仅 INDEX/tag 登记 `pending`（`followup-of:<A-id>`），不改阶段一 outcome、不回滚。

**新指令统一收口序列（强制，单入口定序）**：① 逐字落盘 user-session-log.md（80.1，含理解镜像 80.7）→ ①a 入站字面/语义筛查（同音错字/专有名词/语义合理性，逐字对照追加登记，唯一合理修正自主执行不问用户；歧义影响目标/范围才确认）→ 入站指令筛查细则（按需加载）→ 详见 references/plan-workflow-details.md §inbound-instruction-screen；触发：收到用户新指令需做字面/语义筛查或疑似误发预检时；关键词：入站筛查 误发 语义 预检 → ② D/A/B/C/E 判定（判定前先过 8.1.2 入站预检：疑似误发/项目定位明显错位 → 先分析偏移点并询问是否纠正，再判定；下表；A 类无影响=走 ①② 后登记一行即完成，③-⑤ 仅 B/C/D/E 适用；E 类目标切换先过确认门、用户 yes 后按 D 处置再进序列）→ ③ **指令理解迭代（Rule 28.2.2，执行前方向对齐）**：完成 3-4 轮理解迭代草稿（原始指令复述→模型理解[目标/范围/约束/不做什么]→模型思路与候选+歧义门控→大体执行方向，粗稿非定稿）并按模式处理。**goal/目标迭代（28.8）优先覆盖**：无论明确或歧义/多候选，**禁止**向用户提问/列选项请求确认/等待回复，直接按推荐项或可逆安全默认静默自决并留痕后继续（歧义仅内收敛+登记假设），同问禁复发（预算外硬门按 28.9② 登记待授权清单后继续，不停表；续推与授权到达按 28.9③-⑦）。**非 goal**：ask 模式展示供早纠偏，无实质歧义时不因本模块新增阻塞确认（提示可纠偏后继续），有歧义/多候选(典型3-4)时才按选项确认（28.3）；silent/44.3 自动通过/mini 缺省 silent 下不阻塞等待，收敛并留痕且歧义按推荐项与可逆安全默认自决→ ④ 计划文档同步（task_plan/progress/需求锚）→ ⑤ Todo S5 重映射 → ⑥ 触发修改轮时衔接 Rule 103.6 同步完整性审查。两义务一体执行、顺序不可倒置（记录先于转译，防转译覆盖原话）；禁拆散单做（漏序=缺口）。

**意图切换快速判定卡（新指令首动作，先于 A/B/C 细分）**：⓪ 前置预检（8.1.2）：指令任务类型/交付物与项目定位、当前任务域、最近原话三源比对——明显错位或疑似误发 → 先输出≤5 行分析（意图+偏移点）并询问是否纠正（澄清优先，86.4 三件套），确认后回落下方判定；无错位 → 直接进判定（[align-scan] 留痕）。提取新指令的「Goal/范围/交付物」三要素，与当前活跃计划 Goal 行及 user-session-log.md 最新原话比对——三要素均无交集 → 立即判 **D 类新任务边界**，按下方「意图切换执行清单」处置（禁吸收进当前计划）；含可判定换目标信号（新站点/域名/新对象词/宾语变更）→ **E 类**先确认再切换；有交集 → 回落 A/B/C 常规判定。

| 类 | 判定 | 强制动作 |
|----|------|----------|
| D 新任务边界 | 与当前计划 Goal/范围/交付物均无关联（Rule 8.1） | **开新计划** `plans/{new-task-id}/`（init 全流程）；旧计划原样保留（不标 superseded）；判定落 notepad+Decisions；禁混入当前计划 |
| A 无影响 | 闲聊/追问/与当前计划无关 | 正常执行，不改计划 |
| B 扩展 | 新需求/加范围/改交付物 | 先重规划（Rule 74 三判门+变更标注表）→ S5 同步 Todo→复述变更→再执行 |
| C 矛盾 | 与已确认计划/VC/用户先前决策冲突 | 停止写入：更新计划中被推翻部分（标 superseded）→同步 Todo→展示新旧对比获确认后执行；记录面按 Rule 98 触发面整理（`Skill("context-corrector")`，98.3 组织先于继续） |

  → 意图切换模板细则（按需加载）→ 详见 references/plan-workflow-details.md §intent-switch-templates；触发：判定 D/E 类意图切换、需要切换通告模板或回切检查时；关键词：意图切换 D类 E类 模板 回切

**判定顺序**：先 D 再 A/B/C（指令与目标有关联哪怕小→回退 A/B/C）；仅存在活跃计划时 D 类适用。B/C 变更前过 Rule 73.2 对齐三问+[align] 行，处理完再派 drift-checker。**稳定性铁律**：禁止"口头接受新指令、计划与 Todo 不动"。用户指出错误（Rule 31）→先 STOP 走 31.2 四维归因再修（完整闭环见 task-discipline Rule 31/32/33/74）。命中 Rule 98 触发面（用户否定 ∨ 自主前后文矛盾）→ 调用 `Skill("context-corrector")` 整理上下文与历史文档（记录面专职 SOP，98.3 组织先于继续）。

**目标切换判定（E 类，P0 铁律）**：用户指令命中以下任一**可判定**条件 = 目标切换 = **scope 扩张动作** → **禁止自行归类为 D/A/B/C 并执行**，必须先复述解读 + 等用户显式 yes（D1 门控）：① 指令含**新站点/域名/平台名词**，与当前活跃计划 Goal 的站点/域名词**零交集**（实体提取：Goal 行 + 指令中的域名/站点名/产品名）；② 指令含**指示词**（「其他」「另外」「换个」「别的」「新的」）+ **新对象词**，且该新对象词与当前计划 Goal **零交集**；③ 指令的**宾语**从当前计划 Goal 的宾语变为另一宾语（Goal 宾语 = 站点/产品/项目名）。处置：复述「我理解您的指令是 X（切换到 Y），对吗？」→ 等用户 yes → 才可按 D 类开新计划或 B 类扩范围。**禁止**在用户确认前新建计划目录、写 task_plan.md、清哨兵。**确认切换后的处置（Rule 94，2026-10-23）**：确认目标切换后按 Rule 94 任务专注性与计划隔离纪律处置——94.3 询问门可与本类确认合并为一次询问（新开计划隔离执行（推荐）/并入当前计划重规划/暂挂当前计划），同意拆分则按 94.4 隔离（旧计划封存待 plan-resume、新目标独立 init、跨计划禁交叉写入）；封存=挂起登记+删除旧计划 `.session-owner` 释放会话占用（回切 attest 口径同 D 类①），禁把新目标就地吸收进当前计划。Why: RCA 缺失环节 1——D5 歧义条款与 D/A/B/C 判定均为 LLM 行为门，机器不可判，含糊指令被宽泛归类后 agent 直接执行；本条给出**可判定的触发条件**（换站点/换目标域/新目标实体词），把「目标切换」从模糊判定中抽出为独立可判类别，在「新建计划」前强制停下确认。与宪法 §四 P0-1（用户说 A 做 A）和 §二（规划先行）绑定。

### 🔀 冲突分析与工作树隔离（默认首选）

**实现类任务一律首选 git worktree 隔离**——本仓多为运行中基础设施（skills/hooks/config 被所有会话实时使用），直接改动有半残风险。**隔离判定不以文件扩展名为准（2026-11-27 用户裁决）**：交付型 Markdown（小说/写作/长文档/多章节/手册类交付物）或预计改动 **> 2 行**或**多文件** → **REQUIRED worktree**；仅**非交付型过程文档且 ≤ 2 行** trivial 修改可豁免为 direct（须在计划/备注登记“非交付型 + ≤2 行 trivial”）。用户显式要求“直接改不用 worktree”仍按 AGENTS.md §11.5 处理，但**不因 .md 后缀自动生效**。初始化 `bash scripts/check-conflicts.sh`（五类冲突信号）→ 隔离决策写入 task_plan「🔀 隔离决策」并**默认按隔离执行，不就该安全默认向用户发起确认/询问**；仅当命中上述豁免且符合 §11.5 时才直改并登记理由。**创建前先 git 备份主仓未提交改动**（推荐 `git -C <project> stash push -u -m "pre-wt-backup:<task-id>" -- . ':(exclude)plans' ':(exclude)tmp'`，引用登记隔离决策；已干净则跳过）以稳定基线并利于合并回。隔离期间 CWD 不迁移、文件操作用 worktree 绝对路径、计划文档留主仓 plans/；**worktree 执行期不因并行冲突/Rule 23 `[conflict]` 注入而中断或询问，冲突仅记录、统一延后至合并回阶段**（`smart-merge-back.sh` V3/V5/V6 + Rule 101.2）解决。完成合并：全 VC 复验→`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`→清理 worktree/分支→主仓 Read 复验（按需恢复备份前先重跑同落点盘点）。合约详见 `references/worktree-isolation.md`；触发：创建/使用/合并 worktree 隔离区或判定隔离豁免时；关键词：worktree 隔离 合并回 check-conflicts 豁免

