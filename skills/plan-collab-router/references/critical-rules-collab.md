### 39 动态工作流编排（dynamic workflow orchestration routing — task-v088，目标：用户显式点名 /workflow 时路由到 dynamic-workflows 编排，把 task-planner 失败兜底/断点续做/人工升级/模板沉淀四机制映射到 workflow 原生能力；未点名时既有串行派发零改动）

task-planner 执行模型长期只有「串行 Agent() 逐 S-unit 派发」一条路，对多步、有类型化中间结果、需按停止条件循环的编排型任务串行慢、失败重跑全量重付、人工干预无原生通道；harness 已内置 dynamic-workflows 能力（AmendWorkflow cache 导入 / ResumeWorkflowRun 断点 / ResolveWorkflowQuestion 升级 / SaveWorkflow 沉淀），技能层却零路由零映射。本条建立「点名才路由 + 四机制映射 + 并行豁免登记 + 机器校验边界」链路；未点名任务按 Rule 21.4 独立性守门调度（[EVOLVED 2026-10-02] 并行默认+声明制，未声明组=串行槽；本条 Rule 39 路由机制仍为纯增量，Rule 36.5）。

39.1 **触发纪律（显式点名 ∨ 常设授权命中条件——[EVOLVED 2026-10-18 task-v187]）**：本条生效当且仅当以下二者之一：① 用户显式调用 `/workflow` 或明确措辞要求 workflow 编排（官方 L46-55「explicit request is binding」原样有效——点名即强制路由 CreateWorkflow，agent 不得替代为 Agent 派发或自行判断任务过小）；② **用户常设授权命中 39.8 编排条件**（2026-10-18 用户原话授权：「复杂任务应该启用工作流，主动创建工作流来调用，来推进任务」——常设授权等价于显式请求的常驻形态；授权锚=plans/task-v187-workflow-activation-parallel/user-session-log.md #1；用户一句「收回工作流授权」即整体回退至仅①）。未命中①② → 一律按既有 Rule 21.4 调度铁律执行（独立性守门：声明并行组内可并行、未声明组=串行槽），Rule 39 零影响面；单一委托/几个独立查询仍走 Agent 工具。原「agent 不得自主判断启动 workflow」限定语废止——由 39.8 条件门+激活三件套留痕替代（官方默认政策被用户主权常设授权覆盖，覆盖论证与撤销机制见 39.8；官方红线原文披露保留于此，Rule 35.2 防虚构）。
39.2 **前置条件（skill 加载门槛）**：`CreateWorkflow`/`AmendWorkflow`/`SaveWorkflow`/`EvalWorkflowSnippet` 四工具在本会话未 `Skill("dynamic-workflows")` 加载时拒绝运行（官方 L11-12）；运行 `saved:` 来源的 `CreateWorkflow` 是唯一豁免路径（官方 L942-943）。编排前须确认该 skill 可加载；四工具脚本（inline 一次性 / saved / path）提交前必须已加载本 skill（typecheck + 确认窗）。
39.3 **四机制映射（task-planner 机制 → workflow 原生能力，单一权威源表）**：

| task-planner 机制（权威源） | workflow 原生机制 | 映射说明 |
|---|---|---|
| 失败换档/修复续做（Rule 22.3 ①-⑤ / 22.7） | 编辑 `scriptPath` 文件 + `AmendWorkflow` | errored run 不可 resume，须修脚本再 amend；amend 导入旧 run 已完成工作作 cache 零成本回放（官方 L764-767, L787-795） |
| 断点续做（Rule 22.8 resume_from / plan-resume Rule 24） | `ResumeWorkflowRun`（stopped）/ `AmendWorkflow`（errored） | stopped(reason=interrupted) 直接 resume 原样恢复；errored 必须 amend（官方 L764-772）。cache 按 subagent 名+指令字节匹配 → subagent 命名须稳定、可调常数不进 ask 文本（官方 L832-859） |
| 人工升级（Rule 28 D5-D6 询问点） | `ResolveWorkflowQuestion(dwfq-…)` | 子代理升级的阻塞问题带全局唯一 question id；答复文本原样成为该 subagent 调用结果；只停提问的那个 subagent，兄弟与控制流继续；通知丢失用 `GetWorkflowRun.pendingQuestions` 兜底；每个 ask 最多 3 次升级（官方 L861-906） |
| 模板沉淀（Rule 34.3 触发 / 34.4 流程） | `SaveWorkflow`（project `.zcode/workflows/` / global `~/.zcode/workflows/`） | 可复用编排沉淀为 saved workflow（args 声明=调用约定）；官方纪律=绝不主动保存，须用户同意或点名（官方 L1453-1498）；同名覆盖走 Rule 36.4 用户确认 |
| 每 Phase 验收门控 | `phase()` 验收节点图 + `report()` verified/notCovered + `world.run` 确定性门控 | phase() 强制画验收节点图；report() 条目随失败通知送达且不重复；确定性验收用 world.run（cmd 编译期字面量，确认时批准命令集，官方 L968-1346） |

39.4 **并行豁免与 Rule 21.4 调和**（[EVOLVED 2026-10-02] 调和改写：workflow run 内部并行原即 21.4 默认语义，豁免登记制保留为留痕手段）：workflow subagent 默认可并行（fan-out / `Promise.all`，官方 L308-310）；当用户显式点名 workflow 编排时，该 workflow run 内部并行符合 21.4 独立性守门默认语义（成员须通过独立性四问；10-02 演进后 21.4 并行默认允许）——仍保留豁免一行登记 Decisions Made + progress.md（留痕，非 21.4 原文改写前置条件）；用户同时要求串行 → 传 `max_concurrency: 1`（官方 L955-959）。原「Rule 21.4 文本零改动」条款随 10-02 演进失效（21.4 已于 task-v110 改写为调度铁律）。
39.5 **机器校验边界（Rule 35.2 防虚构）**：workflow 内部 subagent 是否受 `check-dispatch.sh` 派发守卫 hook 约束 = **官方文档未提及**（已 grep 核实 SKILL.md/examples/patterns）；禁止在 Rule 39 声称机器守卫覆盖 workflow 内部。机器校验归 harness 侧（`ListWorkflowRuns`/`GetWorkflowRun` 终态与 pendingQuestions 可查）；派发契约（九字段 prompt / 8 字段返回，Rule 22.4/22.4b）由脚本作者在 persona/ask 文本内自行内嵌，**非 hook 强制**——这是与 Agent() 派发的关键区别，须如实披露。[2026-09-25 task-v090] 观察面扩展=39.7.3（PreToolUse matcher 加入 workflow 四工具的观察分支，exit 0 恒放行、零阻断）；本段守卫面边界表述维持不变——观察面扩展 ≠ 守卫面扩展。
39.6 **机制（零新 config 键 — 与 task-v087 同范式）**：判定面=LLM 行为（显式点名才触发，非机器）；机器面=dynamic-workflows 官方自身约束（skill 加载前置 / 确认窗 / typecheck 拒跑，官方 L11-12, L920-921），无需再造开关键。守护=`scripts/selftest-workflow-orchestration.sh` 静态断言（39.x 条款锚 + SKILL 协同路由行 + Rule 39 摘要行 + C27 + 「Rules 1-39」索引 + 零 config 键 + 行数上限）；消费侧=SKILL.md 🤝 协同路由矩阵 dynamic-workflows 行 + C27。
39.7 **动态激活边界与禁自建副本（task-v090，纯追加子条）**：
  - **39.7.1 /workflow 自动激活=系统内置链路，零技能侧补建**：ZCode harness 自带 `/workflow` 系统命令（命令正文注入 "Required skills: dynamic-workflows. Before following the command body, call the Skill tool for dynamic-workflows"），dynamic-workflows 官方 skill 随 ZCode 宿主分发（bundled skills 目录），每轮会话恒在可用列表——「/workflow 点名 → 强制加载 → CreateWorkflow 门控放行」链路闭环在 harness 侧完成，**技能侧无需也不得补建激活机制**（用户级 slash command 覆盖系统命令属越层，官方 skill 本体不得复制进用户目录）。
  - **39.7.2 禁自建 dynamic-workflows 副本（P0 锚，防遮蔽）**：资源发现顺序 `~/.zcode/skills` → `~/.agents/skills` → 工作区 → 插件，**用户级目录优先于 bundled**——在 `~/.zcode/skills/` 或 `~/.agents/skills/` 下自建 `dynamic-workflows/` 目录会遮蔽官方版本，宿主升级后官方 skill 更新而副本不跟随，形成永久漂移。**禁止**以任何理由（"确保可加载"、"固化版本"、"防宿主变动"）在用户级/工作区 skills 目录创建 dynamic-workflows 副本；发现已存在 → 报告用户 + 删除走 Rule 36.4 逐项确认。selftest 守护：WF-14（负断言：用户级两目录无 dynamic-workflows 目录）。
  - **39.7.3 唯一允许的操作面=matcher 观察扩展（用户授权项，零阻断语义）**：39.5 机器校验边界不变（workflow 内部非 hook 强制）；用户显式授权后可把 ZCode 运行位（`~/.zcode/cli/config.json` PreToolUse entry，命令=zcode-pretooluse.sh）的 matcher 扩至 `Write|Edit|Agent|CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet`，zcode-pretooluse.sh 对 workflow 四工具仅注入一行观察提醒（39.7.3 观察分支，「39.4 并行豁免登记 Decisions Made+progress」），**exit 0 恒放行、不阻断、不新增 config 键**；register-hooks-cj.ts（Claude 运行位注册器）PreToolUse 亦同步扩围 matcher 但 command 保持 check-scope.sh（workflow 四工具无 file_path → check-scope 空路径 exit 0 天然放行，零阻断）——观察面扩展 ≠ 守卫面扩展（39.5 原文披露维持）。
39.8 **常设授权主动激活（proactive activation under standing authorization — task-v187 [EVOLVED 2026-10-18]）**：用户常设授权（39.1 ②）下的主动创建通道。**激活三条件（命中任一即主动路由 CreateWorkflow）**：a) 计划期依赖分析（Rule 68.1）判定 ≥3 个 S-unit 同波独立可并行（独立性四问全 no）——fan-out 有实质收益；b) 长链编排型任务（≥3 阶段且阶段间有类型化中间结果/需按停止条件循环——39.3 四机制映射任一命中形态）；c) 用户显式点名（=39.1 ①原路径，强制）。**激活义务三件套（缺一=违规激活）**：① 留痕——Decisions Made 一行 `[workflow-activation] 条件 {a|b|c} 命中依据` + 39.4 并行豁免登记（progress.md 同步）；② 模型分档——CreateWorkflow 调用按 Rule 91.12 联动声明 run 级 `subagent_model`（按 91.1 CCR 四档整体定档，禁默认 heavy 全流）；③ 环境前置——激活前过 Rule 83 通道探测（`Skill("dynamic-workflows")` 可用性）+39.2 加载门槛，不可用快速失败三选项（禁 ≥2 次同法重试）。**回落边界（不命中不激活，防滥用）**：L0/mini/trivial 轻量通道任务（Rule 38.7 边界不动）、S-unit <3 或强依赖链计划、单文件小修——一律 Agent 调度（21.4）；禁止为用 workflow 而拆分制造虚假并行（Rule 26 降质映射）。

### 40 harness 工具面主动选择（proactive harness tooling selection — task-v097，目标：计划期按任务类型主动分析并登记各 Phase 命中的执行工具面（六类），与 /goal 会话目标对齐、按 Rule 39 纪律衔接 workflow 编排；判定面=LLM 行为、机器面=selftest 静态守护、零新 config 键；Rule 39 原文零改动）

Rule 39 管「编排机制与纪律」（显式点名∨常设授权命中才路由、加载门槛、四机制映射、并行豁免登记、机器校验边界），本条 40 管「计划期主动选哪个工具面」（工具面清单 + 计划期分析区块 + /goal 对齐 + workflow 编排计划期路径），二者为上下游关系：39 是机制与红线，40 是计划期的主动分析面；**40.4 已演进为主动路由义务（39.8 联动：计划期登记 CreateWorkflow 路由+执行期按三件套主动创建），与 39.1② 常设授权触发面承接对齐**（原「只增建议登记面」表述随 2026-10-18 演进废止；Rule 36.5 纯增量语义由 40.4 演进条目承接）。

40.1 **工具面清单（六类 harness 执行工具面）**：① /workflow 动态工作流（= CreateWorkflow 族：CreateWorkflow/AmendWorkflow/ResumeWorkflowRun/ResolveWorkflowQuestion/SaveWorkflow，触发纪律见 39.1、40.4，加载门槛见 39.2）；② /goal 会话目标（用户侧 harness 命令：目标锚定 + 完成审计，技能层仅做 40.3 映射指引，不可代调）；③ Agent 子代理（默认执行体；路由表 = SKILL「子代理路由与模型分级」，纪律 = Rule 21/22/25；Phase 的 Executor 字段是委派门控机器事实源）；④ 卫星技能（plan-collab-router/plan-research-router/plan-template-kit/plan-cost-guard，主路由见各自 SKILL 与 🤝 协同路由矩阵）；⑤ MCP/平台工具（web_reader 网页转 markdown、node_repl 浏览器控制、documents 图像搜索等；环境事实以用户级 AGENTS.md §十 为准，禁止假设不存在的工具）；⑥ 机械守卫脚本（scripts/check-*.sh 与 selftest-*.sh 的只读验证与门控，Executor 理由面 = Rule 25.3 白名单③「机械验证」）。
40.2 **计划期主动分析（「🧰 工具选择与编排」区块）**：standard/full 档计划须含「🧰 工具选择与编排」区块（general 模板承载）：逐 Phase 标注命中工具面与选择理由，且「workflow 编排判定」（40.4）与「/goal 对齐」（40.3）两判定行必填。区块定位声明：该区块是 Executor 字段的**上游分析记录，不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变；区块内不得出现 `### Phase N:` / `**Status:**` / `**Executor:**` 三形态伪行，防状态机误读）。mini 档豁免该区块（Rule 38.3 区块白名单，mini-lite-type.md 以声明行明确豁免，未加区块不构成违约）。
40.3 **/goal 对齐（映射指引 + 如实披露）**：计划的 Goal + Verification Contract 表是 /goal 会话目标完成审计的证据源；计划确认与交付时提示用户可将 Goal+VC 映射至 /goal 会话目标。**如实披露（Rule 35.2 防虚构）：/goal 是用户侧 harness 会话命令，技能层不可代调、不可读取其运行态**——对齐证据 = 计划 VC 证据链本身，禁止声称「技能已设置 /goal」「/goal 状态为 …」等无第一手证据的表述。
40.4 **workflow 编排计划期路径（[EVOLVED 2026-10-18 task-v187] 建议登记面→主动路由义务）**：计划期工具分析命中 39.8 激活三条件（独立并行 ≥3 S-unit 可 fan-out / 长链编排型可复用 / 用户点名）之一时，「🧰」区块登记「CreateWorkflow 路由（39.8 条件 {a|b|c} 命中）」，执行期按 39.8 激活义务三件套**主动创建**；未命中且用户未点名 → 按 Rule 21.4 独立性守门调度（并行默认+声明制，未命中编排条件不登记 CreateWorkflow）。原「建议登记 ≠ 自动触发，触发判定权仍在用户」条款废止——触发判定=39.8 条件门（用户常设授权）∨ 用户点名，非仅点名；Rule 36.5 纯增量语义由本演进条目承接（同文件同条目内演进，非跨条改写）。模板镜像同步：templates/task_plan.md「workflow 编排判定」行与 plan-template-kit 镜像面（template-guide.md/template-mapping.md）随本条演进（task-v187 CA-10）。
40.5 **机器校验边界（如实披露）**：「🧰」区块为 LLM 行为面，check-dispatch/check-complete **不机器校验其存在性**（缺区块 = 无违规，不做门控阻断）；守护 = `scripts/selftest-tool-selection.sh` 静态断言（模板区块锚 / mini-lite 豁免锚 / plan-writer 契约锚 / 零新 config 键，selftest-workflow-orchestration.sh WF 断言范式）；/goal 运行态不可从技能层读取，对齐证据 = 计划 VC 证据链（40.3）。
40.6 **机制（零新 config 键 — 与 task-v087/v088 同范式）**：判定面 = LLM 行为（计划期分析，非机器触发，无需开关键；config.json properties=42 维持，WF-12 断言全绿）；机器面 = `selftest-tool-selection.sh` 静态断言；消费侧 = plan-writer 契约（../../task-planner/companion/agents/plan-writer.md 工具选择区块撰写义务行）+ general 模板「🧰」区块 + template-mapping 工具选择映射节。[2026-10-09 task-v149 对齐修复] 本文件 40.6/41.6/42.5/43.4/44.4 五处 config 键数锚 40 统一改为 42（实态 42，base 即 42；本任务 registry 10 行及多脚本注释已改 42，口径同步声明即为真）。


### 91 workflow 脚本内 per-subagent 模型分档纪律（workflow script per-subagent model tiering — 收编 workflow-model-tiers 用户级技能为 task-planner Rule 体系正式条款；目标：workflow 编排型任务在 CreateWorkflow 脚本编写期按子代理职责力度显式声明模型档位，重任务用好模型、轻任务用轻模型，避免全流统一档位资源浪费；同时如实披露官方文档与用户级技能在 per-subagent model 机制上的矛盾，设验证前置门；判定面=LLM 行为+本条款文本锚、零新 config 键、守护=selftest-workflow-orchestration.sh WF-17..22 静态断言；衔接 Rule 39（编排触发/机制）/68.3（组内异构分摊）/22.3（失败兜底——禁悄悄降档）/43.2（最小可承载档位），既有规则条目原文零改动）

用户级技能 workflow-model-tiers（`~/.zcode/skills/workflow-model-tiers/`）提供了 CCR 四档力度映射与两种脚本写法，但长期游离于 task-planner Rule 体系之外——无 selftest 守护、无路由表登记、无规则编号，脚本作者用不用全凭自觉。本条将其核心机制（四档映射表+编译期约束+跨机器迁移）收编为正式 Rule，并补入机器校验面（WF-17..22）与路由表消费侧。关键实证：官方 dynamic-workflows SKILL.md 明确声明「there is no per-subagent tool profile or model choice」（官方 SKILL.md:112），而 workflow-model-tiers 声称其机制为官方支持（引用「SKILL.md §2 Per-subagent model」与「patterns.md #13」）——经核实官方 SKILL.md 无此节（§2=persistent reviewer）、patterns.md 仅 10 模式无 #13，该声称不成立。Rule 91 如实披露此矛盾，设 EvalWorkflowSnippet 验证前置门，不盲信用户级技能声明。

91.1 **四档映射表（CCR 端口 — 本机字面量）**：

| 力度 | CCR 模型（完整字面量） | 典型子代理 | 判据 |
|------|------|------|------|
| heavy（重） | `9e221f47-3040-4ea7-b742-20b813fb79aa/opus-1` | 规划员、架构分析、综合写作、深度分析、最终报告 | 跨模块推理/架构决策/长篇正文/安全审查/最终交付质量兜底 |
| medium（中） | `9e221f47-3040-4ea7-b742-20b813fb79aa/sonnet-1` | 开发/调试/评审/测试修复、内容撰写、质量审查 | 标准开发/调试/评审/测试、常规内容撰写 |
| light（轻） | `9e221f47-3040-4ea7-b742-20b813fb79aa/fast` | 查找、数据提取、格式化、简单汇总、模板填充 | 查找/提取/重排/模板填充/确定性步骤执行 |
| minimal（最轻） | `9e221f47-3040-4ea7-b742-20b813fb79aa/haiku-1` | 分诊/路由、二元判断、关键词提取、格式校验 | 路由分诊/二元裁类型问题/关键词/格式校验 |

91.2 **官方文档矛盾披露（P0 防虚构 — Rule 35.2 配套）**：workflow-model-tiers SKILL.md 声称 `model()` + `agent(name, { model })` 为「dynamic-workflows 官方支持的机制（SKILL.md §2 Per-subagent model 与 patterns.md #13）」。经核实（本任务调研）：官方 SKILL.md:112 明确写「there is no per-subagent tool profile or model choice」；官方 SKILL.md 无「§2 Per-subagent model」节（§2=persistent reviewer for continuity）；官方 patterns.md 仅 10 个模式、无 #13。**结论：该声称不成立，Rule 91 不背书其为官方机制**。Rule 91 将 workflow-model-tiers 定位为「用户级脚本编写约定」，其机制有效性须经 91.5 验证门确认后方可在脚本中使用。

91.3 **用法 A — 固定映射（拓扑已知时）**：子代理职责在写脚本时确定，直接在 `agent(name, { model: "完整字面量" })` 中贴档位。示例：规划员→opus-1、开发员→sonnet-1、格式整理员→fast。优点=零运行时开销、拓扑一眼可读；缺点=改档需逐行 Edit。适用=子代理数量≤5 且职责在编排期已确定。

91.4 **用法 B — MODELS 表 + 分诊路由（多子代理/力度不定时）**：
- **B.1** 脚本顶部声明一次 MODELS 常量（四档各调 `model()` 一次）；AmendWorkflow 改档只动 MODELS 表一行。
- **B.2** 分诊器自身永远用最轻档（minimal/haiku-1），对每个任务输出 typed key（heavy/medium/light/minimal）。
- **B.3** 脚本内 `MODELS[route.tier]` 映射到模型；分诊与执行 1:1 时在 fan-out 回调内链式执行。
- **B.4** 分诊器永不写模型名，只能选用户已批准的档位。
- **B.5** 每个 fan-out 子代理禁止新建 `model()` 调用——声明一次 MODELS 表复用。

91.5 **验证前置门（EvalWorkflowSnippet — 91.2 矛盾披露的配套强制）**：脚本作者首次使用 `model()` 或 `agent(name, { model })` 语法前，须以 `EvalWorkflowSnippet` 验证当前 harness 版本 facade 确实接受该语法（typecheck 通过 + ModelRef 解析正常）。验证不通过=禁止在脚本中使用 per-subagent model 语法，退化为 91.3 的 `subagent_model` run 级字段方案（全 run 统一档位）。验证通过后须在脚本注释或 plan progress.md 记录验证结果（日期+snippet 摘要）。

91.6 **编译期约束**：`model()` 参数是编译期 string literal，不能用变量拼接（`model(PREFIX + "/opus-1")` 会编译失败）——必须写死完整 id。

91.7 **运行中模型不可用禁悄悄降档**：运行中模型不可用时不许 try/catch 悄悄降档 fallback——按 Rule 22.3/model-routing 重试报告，保持用户批准的拓扑。

91.8 **禁止全流统一强档**：不设档位也不设 `subagent_model` 属违规——分诊/格式化与架构同价=用户原始痛点；禁止分诊/格式化上 opus——反向浪费：慢且贵，质量溢出。

91.9 **与既有规则衔接**：
- **Rule 39（编排触发/机制）**：91 是 39 的 per-subagent 模型分档深化——39 管编排触发与机制（显式点名∨常设授权命中才路由/加载门槛/四机制映射），91 管脚本内每 subagent 用什么档位。39.5 机器校验边界原文不变：workflow 内部 subagent 非 hook 强制，91 守护=selftest 静态断言非 hook 阻断。
- **Rule 68.3（组内异构分摊）**：68.3 的 model 档位在 Agent() 派发侧靠 frontmatter 实现；workflow 侧 91 通过 `model()` + `agent(name, { model })` 实现。两者共享 Rule 43.2 最小可承载档位原则和「同档可承载时优先 agent 类型差异」优先级。68.3 原文不改。
- **Rule 22.3（失败兜底）**：91.7 引用 22.3 的升档机制——运行中模型不可用按 22.3 链处理，禁悄悄降档。
- **Rule 43.2（最小可承载档位）**：91 四档判据对齐 43.2 的最小可承载档位原则——取可承载该子代理职责的最小档位。

91.10 **跨机器迁移**：CCR 前缀 `9e221f47-3040-4ea7-b742-20b813fb79aa` 是本机特定。跨机器迁移三步：① 目标机 `ListModels` 找本地 ccr 端口下的 opus-1/sonnet-1/fast/haiku-1；② 把脚本 MODELS 表里的前缀换成本机前缀（若该机支持 bare id 可直接写 `model("opus-1")`）；③ 用 EvalWorkflowSnippet 或一次小规模 AmendWorkflow 确认档位解析正常再跑大流。

91.11 **机制（零新 config 键 — 与 Rule 39/40/90 同范式）**：判定面=LLM 行为（脚本作者按本条款编写，非机器触发）；机器面=`scripts/selftest-workflow-orchestration.sh` 静态断言（WF-17..22：Rule 91 头锚/四档映射表锚/官方文档矛盾披露锚/编译期约束锚/验证前置门锚/与 39/68.3 衔接锚 + SKILL.md 路由表 collab 行枚举 Rule 91）；守护零新 config 键（config.json properties 键数维持现状，本任务零新增键；WF-12 断言不变）。消费侧=SKILL.md 卫星路由表 plan-collab-router 行 + plan-collab-router/SKILL.md 域标题行。
91.12 **主动激活联动（39.8 → 91 分档强制 — task-v187）**：经 39.8 常设授权主动创建的 workflow，创建动作强制过本条分档纪律：① CreateWorkflow 调用按任务整体难度声明 run 级 `subagent_model`（官方 schema 唯一模型字段——91.2 披露的 per-subagent 官方不支持维持；档位按 91.1 CCR 四档：heavy=opus-1/medium=sonnet-1/light=fast/minimal=haiku-1，重编排 medium 以上、轻量编排 light/minimal，全流统一强档违 91.8 既有条款）；② 脚本内按 91.1 四档映射为各 subagent 职责配档（model() 写法维持 91.5 验证前置门+91.6 编译期约束）；③ 授权锚=用户 2026-10-18 原话「确保不会使用，都使用复杂大模型解决」（user-session-log #1）。与 68.3 异构分摊分工：68.3 管 Agent 派发路径组内异构，本条管 workflow 路径整体定档+脚本内配档。
