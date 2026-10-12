# task-dispatch 规则全文（子代理派发与拆分调度）

> 来源：skills/task-planner/references/critical-rules.md（task-v171 专业化拆分 Phase 4 迁移）
> 规则编号：12,13,14,21,22,23（S3 批）+ 25,46,52,59,68（S4 批）
> 标题格式统一 `### N 标题`，正文逐字复制。

### 12 冲突即隔离（工作树默认首选）
任务启动前运行 `check-conflicts.sh`；**实现类任务默认建议工作树隔离**（`wt/<task-id>` 分支，`<repo-parent>/<repo>-worktrees/<task-id>` 目录），完成后验证并主动合并回原分支再清理（合约见 `references/worktree-isolation.md`）。纯文档/调研类或用户显式否决时才直接开发。原因：本仓多为运行中基础设施，直接改动可能使功能在工作期间无法使用。

### 13 子代理隔离强制（P0）
调研/搜索/大文件读取/跨文件 Read 必须派子代理。完整路由表见 SKILL.md §「子代理路由与模型分级」。主进程禁止直接 Read >500 行文件后改动、跑测试、接收 `Skill("research-assistant")` 长文。模型档位复用 `~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md` 既有约定。

### 14 代码编辑必须派子代理（P0）
主进程禁止直接 Edit/Write 业务代码（`.ts/.tsx/.js/.jsx/.py/.sh/.go/.rs/.java/.c/.cpp/.h/.hpp`）。详见 SKILL.md §「代码编辑强制隔离」。仅允许主进程 Edit ① 计划系统文件（`plans/**` 三件套/notepad/verification/INDEX/ledger、`.claude/plan-templates/`）② 原生 Todo 同步 ③ 单文件 ≤3 行 trivial 修改（非保护区）④ mini 直做通道（[task-v094 T-B4]：plan_tier=mini 含 auto-tier ∧ 非保护区 → 主进程直做合法；纪律口径 ≤30 行/≤2 文件/单模块由 Executor 登记 25.3 白名单⑥ 承载，机器面=check-delegation pretool ④b 放行，保护区永不放行）；其余 `.md/.json/.yaml`（业务文档/配置/技能文件）默认派子代理，主进程直做须按 Rule 25.3 登记白名单内例外理由。变更规模路由：≤3 文件/≤300 行 → code-assistant（haiku-1）；>3 文件或 >300 行 → executor（sonnet-1）。


### 21 子任务拆分与模型分工（P0）— 小步快跑:大模型拆分、小模型执行
单个任务过大 = 单次上下文内问题复杂度非线性上升,执行质量与成本双输。**计划阶段**(主进程 opus / plan-writer)负责把任务拆到低档模型可独立完成并验收的粒度;**执行阶段**逐个派低档模型子代理执行——拆分用强模型保证"拆得对",执行用弱模型保证"花得少",低成本下提高整体解决质量。

21.1 **单 Phase 粒度上限**:一个 Phase/子任务 = 一次可独立验收的最小交付单元(默认 ≤3 文件且 ≤300 行,或单一可验证产出);超出必须继续拆,直到满足。与 plan-writer「≤7 Phase」约束构成双边界——防单任务过大,也防拆分过细(过细 = 执行阻力大)
21.1b **步级(S-unit)派发粒度上限 — 小模型短上下文友好**:Phase 内每次 `Agent()` 派发对应一个 S-unit(22.6 表一行);单步 ≤`config.json#subagent.step_max_files`(默认 2)文件、≤`step_max_lines`(默认 100)行、预估 ≤`step_max_minutes`(默认 15)分钟——比 21.1 的 Phase 级上限收紧一档。依据:小模型在短上下文与长上下文下执行质量差异巨大,15 分钟内可完成的单步其上下文增长有限;超限 = 计划无效,回炉再拆而**不是**换更大模型。**拆分判定基准 = 预估时间(用户裁决 09-17)**:计划期每个 S-unit 先给出可测的预估时间(工作量按「改/读文件数 × 单文件复杂度」估),再按该预估时间决定是否拆——**预估 ≤15min 且输入 ≤2 文件 → 不拆直接派;预估 >15min 或输入 >2 文件 → 拆成多个更小 S-unit 直至落入上限,而不是把大任务整体派出去**。机器侧:check-plan-dispatch.sh attest 时逐行读预估时长/输入文件数,超限打 SKIPPED 提示(提示不阻断,拆分判断归模型);不可解析 SKIPPED 显式化;[2026-09-17 task-v081 步骤枚举维度]单 S-unit 派发 prompt 内显式步骤枚举(StepN/步骤N/第N步/①-⑮,按序号值去重)>`step_max_steps`(默认 4)=拆分信号——枚举 ≥5 步即单次塞多动作,违背小步快跑,回炉拆成多个 S-unit 再派;机器侧:check-dispatch.sh fine_grain_checks ④ enforce 档硬阻断(任务书豁免场景对任务书文件同步计数,防绕门)+check-plan-dispatch.sh 第三 advisory 维(目标列枚举计数,提示不阻断)
21.2 **拆分产物必须自包含**:每个子任务写明 目标 / 输入(文件路径、上下文摘要)/ 验收标准(可观察证据),使低档模型无需追问即可执行(prompt 自包含);子任务间依赖必须显式声明输入来源,禁止隐式依赖;计划期知识要点沉淀于 `<plan-dir>/knowledge-brief.md`(任务知识简略要点,五段:速览/已验证事实/文件锚点/易错点/S-unit 材料包索引;模板 `templates/knowledge-brief.md` 由 init-session 建档,plan-writer 计划期填写),子任务 prompt 的材料包应引用 brief 对应节锚点(§1-§5)
21.2.1 **台账供料优先(task-v137)**:设计/审计类派发的基线事实(行数定数/Rule 编号/实体清单/selftest 基线)必须经 `<plan-dir>/knowledge-brief.md` §2/§3/§5 从台账供料(台账=编号账本/盘点清单/审计定数/selftest 基线),禁止 prompt 内联重建;台账过期维度(部署位实时状态、锚区间)须重测并带时效戳,禁盲用;禁双份供料由 `templates/subagent_dispatch.md` §9(上下文预算,禁贴全文)承载,本条引用不重述
21.3 **执行一律低档模型**:已拆出的子任务一律派子代理执行(机械型 haiku-1 / 判断型 sonnet-1,复用 agent-model-tiering 既有约定);大模型(opus 主会话)只做拆分、派发、验收,禁止亲自逐个执行已拆出的小任务(联动 Rule 13/14/17)
21.4 **子代理调度铁律(P0;演进链 09-12 串行铁律[task-v061]→09-28 只读分槽豁免[task-v094 T-B1]→10-02 并行默认+独立性守门[task-v110])+逐个执行+即时验收+首败即评估拆细**:
**默认语义([EVOLVED 2026-10-02] 用户裁决:「子代理调度可以并行运行,但必须确保互不影响、互不依赖——用错误的资料或依赖只会产出错误内容」):并行默认允许**——同一时刻可存在多个在飞子代理,当且仅当同一**并行组**内成员通过**独立性四问**(①文件集相交?②资源相争(部署位/分支/同一交付物/同一计划文件锚点)?③输入依赖他者产出?④验收依赖他者结果?——**任一 yes = 不同组,必须串行**:前者三证据验收(执行记录/产出 Read 复核/验证证据)通过后才派发后者);
**声明制(机器承载)**:并行组须在计划 frontmatter 声明(`parallel_groups:` 组名清单)∧ S-unit 行/派发 prompt 含组标记 `[parallel-group:<组名>]`;只读分槽豁免（[task-v094 T-B1] 沿承,预置只读类并行组）:`parallel_readonly: true`+`[readonly-parallel]` 机制保留,越权写残留面以 22.4a 只读契约+验收 Read 复核承载(发现越权写=按 Rule 26 处置);未声明者默认串行——守卫对无组标记派发按串行槽拦截,行为同旧 09-12 铁律(旧 09-12「至多 1 活跃」绝对化串行表述与「互不依赖不构成并行理由」条款均于 10-02 废止,前者由并行组语义替代,后者翻转为并行前提);
**串行保留场景枚举**:① linked 接力(同一上游产物多下游依次消费,四问③)② 写类 S-unit 文件集相交(四问①)③ 同一计划三文件同锚点双写(22.4a 单写者条款)④ 验收链依赖(四问④,如汇总/Aggregator 必须等全部组内成员 complete)⑤ 用户显式要求串行;
**验收纪律不变**:完成一个验收一个(Read 复核产出/命令输出确认),每个并行组成员独立三证据+独立 Handoff 行;后台派发(run_in_background)视为持续占用所在组槽,收取结果前不得派发同组新 S-unit;
**失败兜底链不变**:子任务**首次**失败/超时 → 立即对照 21.1b 评估:触及步级上限或预估超时 → 拆细重派(22.3 ②,不改模型档位);未触及且疑似能力不足 → 22.3 ③ 降档;同一子任务失败 ≥2 次 → 禁止同法重试(联动 Rule 7 三击协议),回计划阶段重拆或升级 Complex Problem Solver(高复杂度规划类亦可升级 complex-planner,GLM5.3/Opus 级备用);换道评估顺序=现成方案(22.3.0)→子代理隔离→拆解逐个击破(22.3.0b)[task-v113];
(机器守护:check-dispatch.sh 串行槽/并行组槽守卫+打包检测——无组标记=按串行槽拦截,有组标记=组内放行且不覆盖他组锁);
**Why 锚(保留)**:09-12 实证 sess_1316c7f8(16 编辑批并行→千级机械残迹)确立质量优先于速度(Rule 26 同源);10-02 演进=该风险由「禁止并行」转为「独立性守门拦截有依赖的并行」——错误跨单元放大风险由四问②③(输入资料/资源依赖)+验收 Read 复核承载;违规(未声明组擅自并行/组内成员四问失守)按 Rule 26 降质惩罚映射处置
21.4.1 **并行创作组声明面与组语义调和（Rule 49 单元线，纯增补；task-v130）**:把「场景段落/关键帧批/资产批」抽象为创作单元 Unit，每个 Unit 一条工序链 lane（写词→生成→质检→放行→组装），并行单位=Unit（lane）、Unit 内工序强串行（Rule 47.1 阶段×生产单元轴 + Rule 49.1 单元线模型，不造新机制）。组名可绑定单元线 id（`parallel_groups` 组名=创作单元 id，如 `u-seg01`）；**lane 内串行由四问③自动保证**——同 lane 后继 S-unit 对前序产物有输入依赖=四问③ yes=本应串行，故「跨 lane 并行、lane 内串行」与 21.4 原义（组内并行/组间串行）不冲突：同 unit-id 组内成员因输入依赖天然落入串行保留场景①。三层声明面（frontmatter `parallel_groups:`+`lanes:` 一次性全声明 / S-unit 表 `[parallel-group:<unit-id>]` 列 / Lane 状态表）与冲突检测清单、引用管理见 Rule 23.9-23.13 + SKILL.md §并行创作组；lane 内串行由 Lane 表前置列 + 49.2 三条件守门。
21.5 **拆分自检(动工前)**:展示计划 / plan-writer 产出时自检——任一 Phase 无法用一句话说清验收标准,即视为粒度过大,回炉重拆后再交用户确认

21.6 **拆分模式库与定性判据（task-v150）**:数值上限（21.1b 步级三值 / 59.1 粒度硬门）管「拆得够小」,本条管「拆得对」——拆分质量判据=模式库定性判据+边界三判据+步内粒度+任务书契约;模式库=`references/split-pattern-library.md`（相对技能根,11 模式+伴飞映射库,计划期拆分前强制消费）
21.6.1 **模式库强制消费**:计划期拆分 S-unit 前必读 `references/split-pattern-library.md`——按任务画像（实现类/并行编排/系统设计/子代理管线/嵌套派发/技能修改/对齐审查）选模式,选型结论入 `<plan-dir>/knowledge-brief.md` §5 与派发任务书;机器面=selftest-split-pattern-library.sh 静态守护（库在位/模式锚/消费契约段）
21.6.2 **S-unit 边界三判据**:①独立可验收——一个 S-unit = 一个可独立否决的验收单元（评审者无需读其他 S-unit 即可判定本单元 PASS/FAIL）;②独立可理解——执行者不读其他 S-unit 即理解本单元目标/输入/验收;③接口清晰——输入输出显式列明（文件路径+行号锚+摘要）;任一不满足 = 粒度或切面不当,回炉重切而非升档（联动 21.1b 超限处置）
21.6.3 **步内 bite-sized**:S-unit 内动作 2-5min 一步（写→跑→验→提交,单步只做一个动作）;任务书显式步骤 ≤4（联动 21.1b 枚举上限 `step_max_steps` 默认 4）——低档模型短上下文友好,单步认知负荷可控
21.6.4 **任务书 No-Placeholder 与双明确**:派发 prompt 禁 TBD/待定/占位符/「等」字模糊指代;低档模型拿到的任务书必须无需追问即知 做什么（目标一句）+怎么做（方案/步骤）+做到什么程度（验收可观察证据）;契约行载体=`templates/subagent_dispatch.md` §3 验收标准段
21.6.5 **伴飞映射表联动**:库内置「任务画像→伴飞技能候选」表（≥6 行,绝对路径）;计划期 59.3 技能扫描先查库表再全池扫描（库表命中=直接引用,未命中=全池扫描补充）;执行期按 59.2 伴飞注入任务书 §2（SKILL.md 绝对路径+首动作 Read）

21.6.6 **术语锚定与反幻觉**:拆分前对用户输入关键领域名词做理解回写(语义解释一句+溯源锚);多义/领域词禁凭模型先验赋义,按 63.2 四步检索链查证;创作类任务(剧本/设定/角色定位)的术语理解复述写入派发任务书 §2 作为前置内容;「X 是 Y」类用户断言的 Y 语义必须可溯源(用户原文上下文/检索证据),禁模型自行赋义(task-v150 B 类扩展)

机制句:零新 config 键;selftest-split-pattern-library.sh 静态守护（断言清单见脚本头注释,scripts/selftest-split-pattern-library.sh）;管辖声明=拆分质量判据归 Rule 21、派发规模/超时归 Rule 22,两条线各自独立,本条为 21.1b/59.1 数值硬门的定性补强,不改变其 enforce 语义

### 22 子代理规模限制与交接文件(P0)
子代理任务过长 = 上下文过长 = 执行失败风险上升;规模必须限制 + 交接文件必须自包含。详见 SKILL.md §「子代理路由与模型分级」+ §「超时与失败兜底」。

22.1 **单次派发规模上限**:单 Phase 内 `Agent()` 派发次数 ≤`config.json#subagent.max_per_phase`(默认 5);超出 → 回炉拆 Phase 或 AskUser;单任务触及文件 >`max_files_per_dispatch`(默认 3)或行数 >`max_lines_per_dispatch`(默认 300)→ 拆子任务或升 subagent
22.2 **超时档位**:按 subagent_type 映射超时:explore/只读 ≤30min / editor 编辑/重构 ≤60min / debugger 调试 ≤60min / executor 批量执行 ≤120min(见 `config.json#subagent.timeout_by_type`);超时 → 立即报告用户,禁止静默重试
22.3 **失败兜底**(优先级顺序 — 拆细先于升档):超时/失败 → ① 改派(换更合适的 subagent 类型)→ ② **拆细**(子任务触及 21.1b 步级上限或预估超 `step_max_minutes` → 回计划层拆成更小 S-unit 重派,**不改模型档位**;每子任务拆细限 1 次防无限拆分,拆细后仍失败 → ③)→ ③ 降档(升一档 model,如 haiku→sonnet)→ ④ 主进程接管(单文件 ≤300 行主进程 Edit)→ ⑤ AskUserQuestion;达 `config.json#subagent.retry_limit`(默认 2)→ 必须 AskUser,禁继续同法重试。理念:子代理失败的第一假设是"任务太大/上下文太长"而非"模型不够强"——升档治标且贵,拆细治本且保持小模型低成本执行。任一档位连续失败 ≥2 次 → 先走 22.3.0 资料先行档评估换道（task-v113）
22.3.0 **资料先行档（research-first rescue，task-v113，用户裁决 2026-10-02；宪法 §七「调研驱动」执行层落点）**：工具持续报错或同一方法/档位连续失败（≥2 次，联动 Rule 7 三击第 2 击「换方法」与 21.4/22.7 失败计数）时，进入下一 22.3 档位或 22.3.3 技能族接管前，先走资料档两步——第一步 本地帮助面：查工具 help（--help/-h 全文，非试错式单 flag 探测）/man 页/项目官方文档与 README（工具/库/框架报错文本逐条查，禁止凭训练记忆或单次失败下断言——35.2 三关①适用）；第二步 网络现成方案：research-assistant（多源）/ Doc Search Agent（官方文档）/ web-search（报错文本检索，GitHub issue/PR 优先）检索同类失败既有解法，评估借鉴后回入既有档位执行（借鉴结果按 19.1 落 findings）。衔接声明：本档=宪法 §七「遇到问题第一动作是上网查资料…穷尽 ≥3 种策略」的执行层机制化落点；与 35.2/35.6 分工——35.2 管「能力否定」查证面、35.6 管探针最小化，22.3.0 管「失败换道」的资料检索动作序；22.3.1/22.3.2/22.3.3 各档在触发前提「已评估本地帮助面与网络现成方案」时引用本档而非重述动作（引用化，零重复定义）。前置评估动作档（LLM 行为面），五机械档 ①-⑤ 序号不变，不进 subagent-fallback.sh tier_order（机械面 6 项）
22.3.0b **换道义务（anti-stall，task-v113）**：同一方法/档位失败 ≥2 次 = Rule 7 三击第 2 击强制换道——禁止第 3 次同法；换道评估顺序（按序先命中先用）：① 资料先行档现成方案（22.3.0）② 子代理隔离（换 subagent_type，即 ① 改派语义内「换更合适类型」优先读法，或派 Debugger/Explore 隔离上下文体）③ 拆解逐个击破（22.3 ② 拆细/21.1 拆 S-unit）；连续 3 次失败 = 禁止第 4 次同法 + 强制登记换道理由（Handoff 表 rescue 列 + progress.md Error Log 一行 [switch-path]：已试 N 次/换道理由/新路径）。Rule 7 保留为「不重复同法」通用纪律条款不动，本条为 21.4/22.7 失败计数面的换道评估序定义（引用化，零重复定义）
22.3.1 **provider 失败主动 Scaling(task-v055-fallback,用户裁决 09-08)**:provider/网络类失败(ECONNREFUSED / other side closed / 400 rejected / Headers Timeout,即日志 `model.network.failed`)→ **先 ①-fb**:派发前可选 `bash <skill>/scripts/subagent-fallback.sh probe --plan-dir <plan-dir>` 预检(快速失败优于 ~5 分钟静默挂起);失败后 `next <type> provider` 取健康 fallback 通道决策,`bind` 生成 `<type>-fb` 变体 agent(指定 fallback 模型,幂等,登记 `~/.zcode/agents/.task-planner-fallback-meta.json`),**零消耗改派,不计 retry_limit**;无健康通道/无 health → 走 22.3 ④/⑤(主进程接管/AskUser)。**边界(如实)**:变体 agent 定义随会话启动固化——bind 后当前会话 `Agent(subagent_type="<type>-fb")` 不可见,新会话起可用;当前会话内兑现 = 新开会话派发或主进程接管;连续 2 个通道全灭 → 22.7 STOP;22.3.2 **provider 全灭挽救档**:provider 全灭且任务超 ④ 上限(单文件 ≤300 行)时,禁止直接 STOP——先回计划层拆细到每片 ≤300 行单文件,再逐片 ④ 主进程接管;拆细后仍无法接管的部分登记未完成清单交付(降级交付点,禁裸 BLOCKED)
22.3.3 **协同技能接管评估(task-v066)**:位于 ④主进程接管 与 ⑤AskUserQuestion 之间的兜底档——④ 接管不可行(任务超单文件 ≤300 行上限且 22.3.2 拆细后仍无法接管)或 ④ 接管后仍失败时,⑤ AskUser/STOP 之前,主进程必须先评估「是否存在更适配的专业技能族可接管」:① 任务整体超载/需跨会话托管 → `Skill("comet")`(先跑 CLI 探针)② 需求/规格层反复返工 → `Skill("openspec-propose")` 规格化 ③ 单点能力缺口(调试/TDD/审查)→ superpowers 对应成员技能(systematic-debugging/test-driven-development/requesting-code-review 等)。探针前置:`command -v comet` / `command -v openspec`,CLI 缺失或项目未激活 → 该族标记不可接管并评估下一族,禁止假设已装。接管语义:把剩余工作连同 task_plan 快照(Goal+VC+已完成 Phase 摘要)交目标技能,Handoff 登记表加 `skill:<name>` 行;接管成功 → 剩余 Phase 由目标工作流推进;接管失败 → 才允许 ⑤ AskUser(silent 模式按 28.4.1 降级交付,禁空等)。约束:接管调用计入 Rule 17 opus 节流;接管后执行体仍受 Rule 13/14 约束;本评估为 22.7 穷尽集合的组成部分(①②③④+22.3.3)。触发矩阵/移交 vs 嵌入合约/反模式唯一权威源 = `../plan-collab-router/references/skill-collaboration.md`
22.4 **派发 prompt 必须自包含且短**(Rule 21.2 强化):Agent() 派发时 prompt 含九字段 —— 目标(1 句)/输入(**首块 = 计划三文件绝对路径,22.4a** + 材料包路径 + findings.md 摘要 ≤10 行,取自 S-unit 表计划期预写;brief 存在时材料包摘要应引用 `<plan-dir>/knowledge-brief.md` 对应节锚点(§1-§5))/验收标准(2-5 条可观察证据)/Scope 禁改清单/工作路径(worktree 绝对路径)/时长预算/返回格式(**8 固定字段严格模板,22.4b**)/checkpoint 落盘路径(`<plan-dir>/subagent-state/{seq}-{agent_type}.md`,见 22.8)/**上下文预算**(prompt 总长 ≤`config.json#subagent.prompt_max_chars`,默认 3000 字符;只注入本步所需材料,**禁止**把 task_plan/findings 全文或大段源码贴进 prompt——小模型短上下文执行是质量前提,材料应在计划期拆成"路径 + 摘要"而非执行期整包投喂;步骤枚举纪律(task-v081):单 prompt 显式步骤枚举(StepN/① 等,序号去重)≤`step_max_steps`(默认 4),待办清单式罗列超限=回炉拆 S-unit,check-dispatch ④ 硬拦);缺任一字段 → 禁止派发（机器校验已生效：check-dispatch.sh 校验 prompt 字符数 vs prompt_max_chars 与多 S-unit 打包，挂 dispatch_contract_enforce 档位）；超限补救=Rule 35.3 大输入落盘引用（内容写文件+prompt 只放路径与 Read 指令），禁止失败收场
22.4a **计划三文件必传与读写契约**(输入字段首块,缺 = 禁止派发):prompt 必含当前计划的三个绝对路径 —— `<plan-dir>/task_plan.md`(子代理**只读**:对齐 Goal/VC/Scope/S-unit 表;状态字段由主进程单写者翻转,禁止修改)/`<plan-dir>/findings.md`(可读;可写 = 仅追加自己的小节 `#### [sub:{seq}-{type}] <标题>` 到对应段末尾,禁止改动既有内容)/`<plan-dir>/progress.md`(可读;可写 = 仅在当前 Phase 段「Actions taken」下追加 `[sub:{seq}]` 子项,禁止改 Status/Started)。读按需 Read 相关段不通读(受 ⑨ 预算约束);写只追加不改写,各子代理只写自己的锚点(派发本身按 21.4 独立性守门:声明并行组内可并行、未声明按串行槽,10-02);主进程终验以检查点为准复核(22.5)。[2026-09-27 task-v091 B-2] 单写者澄清:findings.md/progress.md 的追加(22.4a 允许的 `#### [sub:…]` 小节与 `[sub:seq]` 子项)由子代理**必做**;主进程仅在子代理未自写时兜底回填(缺漏兜底,见 19.1/22.5),**禁止双侧同写同一锚点**——同文件同段双侧并发追加 = 双写不确定性;主进程 Read 复核义务(22.5 30s Read 实际产出 + 复核/回填 findings)不变
22.4b **严格返回格式**(取代"结论摘要 ≤3 行"类宽泛描述):子代理必须按 `templates/subagent_dispatch.md` §7 的 **8 个固定字段**逐字段返回 —— `status:`(done|partial|failed|timeout)/`acceptance:`(n/total pass + 逐项 PASS/FAIL 及 ≤20 字原因;统计/测试类任务 acceptance 只准贴逐项原文行(禁自报汇总数字,汇总由主进程机械求和——子代理算术错多次实证))/`files:`(绝对路径 +N/-M)/`evidence:`(file:line 或 命令→关键输出)/`checkpoint:`(绝对路径 + status)/`findings_written:`(小节锚点|none)/`blockers:`(none|一句话)/`confidence:`(HIGH|MED|LOW);字段名与顺序不得改、不得增删、无内容填 none、不加标题/前言/总结;派发 prompt 必须附模板路径引用(`templates/subagent_dispatch.md`);已填示例以 `references/dispatch-examples.md` §1 落盘承载,派发 prompt 只放路径、需对照示例时 Read(原句「必须附该模板与一份已填示例」语义改写为路径引用,与 dispatch-examples.md 同 commit,静态断言 selftest-dispatch.sh DX 组;[2026-09-27 task-v091 B-1])。主进程收到缺字段或自由文本 → 视为 partial,以检查点「最终结论」段(同一 8 字段块,22.8.2 T5)为准(22.8.5)
【污染三面与主进程动作闭环（task-v161）】返回格式污染三面分治：①派发 prompt「返回格式」段填写污染——段内被填 ①②③ 任务要点清单而非 8 字段模板块（机器判据=check-dispatch.sh prompt 侧段结构校验：标题唯一+段内含 status:/acceptance:/checkpoint:/confidence: 四 key）②agent 定义层输出模板与本节竞争（executor 步骤进度/general-purpose 任务交付报告/Explore 发现列表等——优先级声明与点名禁令见 templates/subagent_dispatch.md §7 追加条款，两套格式冲突时以 §7 为唯一返回格式）③返回回收零机械校验。主进程动作闭环：收到子代理返回后先过 scripts/check-subagent-return.sh（8 字段齐全/契约外字段/块尾无附加/值域四判据）——PASS 才采信；VIOLATION = 按 22.8.5 视为 partial，打回重报一次并以检查点「最终结论」段兜底回填，同时在 Handoff 登记表「结论摘要」列记违规形态（契约外字段/块后附加/纯自然语言），30s Read 复核义务（22.5）不变
22.4c **派发契约机械守卫**:PreToolUse hook 对 `Agent` 工具调用运行 `scripts/check-dispatch.sh`——检查 prompt 含当前活跃计划的三文件绝对路径(22.4a)、`status:`/`acceptance:`/`checkpoint:` 三个返回字段名(22.4b)、`subagent-state/` 检查点路径(22.8.1);缺项按 `config.json#dispatch_contract_enforce`:enforce = exit 2 阻断并列出缺项 / warn = 放行 + 告警计数 / off = 跳过;无活跃计划或解析异常 → 放行(fail-open);[task-planrequired-race] 计划目录三级解析:`TASK_PLANNER_PLAN_DIR` env 显式或 prompt 自声明锚定(三文件目录真实存在)→ enforce 档;均未锚定 → resolve 链兜底降级 warn(stderr `[dispatch-guard] ⚠` + exit 0 放行,根治跨会话互顶指针误拦);[task-path-identity] 三文件缺项扫描按文件身份判定(存在→stat device:inode 比对、不存在→目录 inode / realpath -m 规范串,bind mount 双拼写免疫)。hook matcher 须含 `Agent`(INSTALL 记录);依据:纯文本约束不被遵守(v056 实测 12 次派发 0 次传三文件)
22.5 **交接登记**:每次 Agent() 派发前填 Subagent Handoff 登记表(时间/subagent_type/type/目标/状态(queued/pending/running/done/timeout/failed/scaling-redispatch)/结论/证据/findings 落点/checkpoint 路径/rescue(档位/结果/时间,failed|timeout 行必填)/retry_count/verify_done☐);子代理返回 30s 内主进程必须 Read 实际产出 **并复核/回填 findings**:子代理已按 22.4a 自写 `#### [sub:…]` 小节 → Read 该小节复核并把锚点填入「findings 落点」列(复核替代回填);未自写 → 主进程紧邻 Edit findings.md 回填(兜底);两动作完成才可勾 verify_done;未 Read → findings.md 记"未验证";Handoff 登记表含「checkpoint 路径」列(22.8.1),failed/timeout 行必须回填该列供断点重试定位
22.6 **Phase 内 S-unit 派发单元表(计划期必填 — Subtasks 转正)**:凡 Executor ≠ 主进程的 Phase,**计划期必须**展开 S-unit 表,每行 = 一次 `Agent()` 派发:`| ID | 目标(≤1 句) | 执行体(subagent_type(model),可写"继承"=Phase Executor,或逐行如 explore(mini)/executor(sonnet-1)) | 输入(路径 + ≤10 行摘要,计划期预写材料包) | 验收(可观察) | 预估时长 | 状态 |`;单步上限按 21.1b(≤step_max_files 文件 / ≤step_max_lines 行 / ≤step_max_minutes 分钟),超限回炉再拆;派发型 Phase 产出 >1 文件或预估 >30 分钟 → 必拆步;无 S-unit 表的派发型 Phase = 计划无效(联动 25.1);单子任务 ≥3 文件或 ≥300 行 → 升级为独立 Phase(21.1)。**预估时长列=拆分决策主依据(用户裁决 09-17)**:写表时先给每行一个可测的预估(NNmin),模型按「预估时间是否超 15min / 输入是否超 2 文件」自行决定拆不拆——机侧 SKIPPED 提示只是复述该判断,供 review 时对照;提示行出现而未拆 = 计划期拆分决策未兑现（机器校验已生效：check-plan-dispatch.sh 校验执行体列+S-unit 数值门控）;步骤枚举维度(task-v081):目标列显式步骤枚举(序号去重)>`step_max_steps`(默认 4)同样打 SKIPPED 提示——提示行出现而未拆,同上视为拆分决策未兑现
22.7 **连续失败 STOP**:子代理连续失败 ≥2 次 → 未走完 22.3 ①-④（含 22.3.0 评估）档位与 22.3.3 协同接管评估时,禁止直接 STOP:必须换档重试(跳过已失败档位,逐档留痕于 Handoff 表 rescue 列);已穷尽 ①-④ 与 22.3.3 评估仍失败 → ⑤ STOP 报告用户,不进入 Chain block 交接,不继续派发;上报须附 22.7.1 已尝试挽救清单
22.7.1 **STOP 上报最小集**:任何因子代理失败触发的 STOP/BLOCKED 上报必须含 6 字段——① 失败子任务(Phase/S-unit 定位) ② 已尝试档位清单(22.3 ①-④ 含 22.3.0 评估记录 与 22.3.3 逐档:动作+结果+失败原因) ③ 检查点路径+已落盘里程碑数(无检查点=违规) ④ 剩余未尝试档位或不适用原因 ⑤ 建议下一步(拆细方案/接管范围/所需决策) ⑥ 证据 file:line;缺任一字段 = 摆烂上报(违反 Rule 6),接收方(用户/下一会话)可拒绝受理
22.8 **检查点落盘与断点重试协议(P0)**:子代理上下文易失(中途被杀 = 产出全丢),中间产出必须执行中落盘到检查点文件,失败后基于落盘数据断点重试,禁止无谓从零重做
22.8.1 **检查点路径**:每次派发在 prompt 中指定 `<plan-dir>/subagent-state/{seq}-{agent_type}.md`(每子代理一文件,seq 为 Handoff 表行号);路径同步登记到 Handoff 登记表「checkpoint 路径」列(见 22.5)
22.8.2 **执行中落盘时机**(子代理侧纪律,写入派发 prompt):T1 每完成一个文件的 Edit/Write → 追加里程碑行;T2 每次搜索/调研得出结论 → 追加;T3 中间判断/决策(根因定位、方案取舍)→ 追加;T4 遇错无法继续 → 写「错误与受阻」段(现象 + 已尝试方案)并置 status: failed;T5 任务结束 → 写「最终结论」段(= 22.4b 同一 8 字段块,逐字段)并置 status: done——**T5 必做,防返回消息本身丢失;短任务豁免（[task-v094 T-B5]）：预估 ≤step_max_minutes(15min) 的 S-unit 免 T5 落盘,8 字段返回消息即最终结论,三证据以「返回消息+主进程 Read 实际产出复核」承载(22.5 复核义务不变);T1-T4 与 checkpoint 路径仍必做**
22.8.3 **检查点文件格式**:纯 markdown 分段(头部 status 行 / 已完成里程碑 append-only 带时间戳 / 进行中 / 产出文件清单 / 错误与受阻 / 最终结论),人读为主,无 frontmatter
22.8.4 **断点重试**:子代理 failed/timeout/返回异常时,主进程兜底动作(22.3)执行前必须**先 Read 检查点文件**——有实质进度(≥1 条里程碑或已有产出文件)→ 重试 prompt 注入 resume_from 段(已完成清单[禁止重做] + 已有产出文件[直接复用/续写] + 剩余任务);无进度 → 按 22.3 正常兜底;resume_from 注入不重置 22.3 的 retry_limit 计数
22.8.5 **返回缺失兜底**:主进程 30s Read 产出复核(22.5)时,若返回消息缺失但检查点 status: done,以检查点「最终结论」段为准完成回填
22.9 **活跃计划解析会话隔离(active-plan-race,2026-09-10)**:hook 解析"当前活跃计划"经 `resolve-plan-dir.sh [root] [sid]` 双参——第 2 可选参 sid 缺省取 `CLAUDE_CODE_SESSION_ID`(规范化=剥非字母数字取前 40,与 hook 状态文件命名一致;[task-planrequired-race] sid 以 `sess` 开头时再剥该前缀——sidkey=uuid core,与哨兵文件名 canon 四处对齐);解析链 = ① 会话层 `plans/.active_plan_side/<sid>.active_plan`(mtime TTL 24h 过期跳过)→ ② 全局 fallback `plans/.active_plan`(工作树内瞬态兜底,cron/纯脚本单会话场景;[2026-10-10 task-v164] 原措辞以 legacy 单例描述该层,实为路径随 $PWD 本地化的瞬态 fallback,untracked+gitignore 与 .active_plan_side/ 同族)→ ③ mtime 最新 → ④ 项目根 legacy;会话层优先(正常路径=side 会话私有指针,2026-10-07 fix-pointer-race 后权威层),[2026-10-10 task-v164] 消除并行会话后写者赢覆写全局层致 check-dispatch 误拦(09-09 实锤 7 次);退役"移交/互顶全局指针"叙事(该叙事=并行可见漂移来源)。写入侧:UserPromptSubmit hook 按 sid 自动认领本会话 side 指针(mktemp+mv 原子写;`.session-owner` 属主校验防他会话越权认领);`set-active-plan.sh` 提供 set <task-id> [--sid s] / --show / --clear / gc(清扫 >24h 残留,SessionStart 顺带执行;[task-planrequired-race] gc 同语义扩展清扫 `plans/.plan_required_side/` 中 >24h 的 side 哨兵 `*.plan_required`)

### [2026-10-10 task-v164] 瞬态状态文件合并规则
- 范围：`plans/.active_plan` 及同族瞬态运行态（`.active_plan_side/`、`.plan_required_side/`、`.drift-rhythm/`、`plans/**/.session-owner`）一律不入库（.gitignore 在册）
- 合并纪律：worktree 合并回 master 时如遇瞬态文件冲突（含 untracking 导致的删除态冲突），一律按瞬态处置——取删除/忽略态，**禁抢救指针值**；各会话指针由 `set-active-plan.sh set` 再生
- 依据：git log 实证 8 次 chore 移交/收尾噪音（f6d6158…26878fe）；2026-10-10 用户指令 R4「合并时忽略掉这个状态临时文件」

### 23 并行任务检测与冲突规避(P0)
并发执行多 plan 时,同文件/同 worktree/同名 task-id 会产生难以追踪的冲突。必须通过自动检测 + 规避建议提前暴露风险(Rule 23 落地到 hooks + 注册表)。

23.1 **检测时机**:plan 创建时(run check-conflicts.sh --runtime)+ 每次 PreToolUse 写入时
23.2 **四级冲突**:A 同文件(scope_files 交集非空,硬)/ B 同 worktree 路径(硬)/ C 同 task-id/plans 目录重名(硬)/ D 环境信号(软,复用现有五信号)
23.3 **规避建议**:A/B/C 级 → 串行或新建 worktree/改名;D 级 → 处理信号后继续
23.4 **session_id 必须写进 frontmatter**(注册表追踪,Rule 23.5 前提)
23.5 **scope_files 必须从「执行范围限制」解析**(交集检测基础,Rule 23.2 前提)
23.6 **fan-out 必须含 Aggregator Phase**(check-complete.sh 硬校验,否则 exit 1)
23.7 **注册表心跳**:sync-todos.sh --index 每 10 次工具调用自动刷新一次,保持 INDEX.md 活跃 plan 最新
23.8 **Hook 自动检测**:UserPromptSubmit 启动新 plan 时自动跑 --runtime 模式;PreToolUse 写入时检查 scope 交集

23.9 **并行创作组声明面（intra-plan 单元 manifest — 衔接 Rule 21.4/21.4.1/47/49，纯增补；task-v130）**:把「场景段落/关键帧批/资产批」建模为创作单元 Unit，每个 Unit 一条工序链 lane（写词→生成→质检→放行→组装）；并行单位=Unit（lane），Unit 内工序强串行。三层声明面：① frontmatter `parallel_groups: [<unit-id>,...]`（组名=创作单元 id）∧ `lanes: [...]`（单元线名册，Rule 49），**一次性声明全部 lane**（frontmatter 受 SHA-256 attest 锁定 Rule 20，执行期追加触发重锁）；② S-unit 表（22.6）增「单元/并行组」列，每行填 `[parallel-group:<unit-id>]`（Rule 21.4 机器可消费组标记，check-dispatch.sh 消费；check-plan-dispatch.sh 只硬校验「执行体」列，加列安全）；③ task_plan.md「📐 创作单元并行表（Lane 状态表）」区块（Rule 49.1，主进程单写者）——列=单元 id/工序链/当前工序/前置 S-unit/前置验收证据/组标记/共享引用集/预估烧秒/状态/最后推进时间。
23.10 **单元级冲突检测清单（两 Unit 可并行 ⇔ 独立性四问全 no）**:① 文件集相交——写集∩写集≠∅→串行（产出命名空间隔离：每单元写自己的 `output/<ep>/<unit>/` 与 `tmp/<task>/<unit>/`，禁两单元写同一文件）；② 资源相争——同 worktree/分支、同交付物、同计划文件锚点、同预算 piece_id、同 NAS/VERSIONS.md、**同额度窗口**（生成额度=全局共享资源，Σ 在飞 lane 预算 ≤ 当日剩余额度，AGENTS 约束 4）→串行；③ 输入依赖——u2 输入含 u1 产物→串行（21.4 串行保留场景①）；④ 验收依赖——u2 验收需 u1 结果→串行（21.4 场景④，汇合/Aggregator 等齐）。**项目专属冲突类（必须显式枚举，不能只靠通用四问）**：a) 锚件换代（换装/装备变体/母图重抽，共享且可变）→强串行+冻结锁（见 23.12⑥）；b) 同场景组连续成片（AGENTS 约束 9「≤12s 场景组连续成片」）→同场景组镜头=同一 lane 内串行，跨场景组可并行；c) 同单元内 生成→质检→放行→视频 工序依赖→强串行；d) 人工门（草稿门约束 14/试水门约束 16/G1）→lane 内屏障不可并行越过（跨 lane 可同批呈示，降低用户打断次数）；e) 生成额度→资源相争的媒体实例。
23.11 **三检测时机（静态+动态+验收后）**:① 计划期（静态）——全部 Unit 两两跑 RefSet 交集，把写集/资源 id 喂给 check-conflicts.sh 的 A 级同文件检测（23.2，扩展为支持 intra-plan 单元 manifest，零新 config 键）；② 派发期（动态，唯一能覆盖跨 Phase 前移的时机）——49.2③ 要求目标 S-unit 对**全部在飞子代理**（含已前移的其它 lane）过四问；③ 验收后——49.2① 三证据验收（执行记录/产出 Read 复核/验证证据，22.5 口径）。
23.12 **共享引用管理（RefSet 冻结 + 单写者 + 换代协议）**:每个 Unit 建引用集 RefSet(u)={只读共享锚件[id+版本+sha256] / 产出写集 / 可变共享资源[预算 piece_id 命名空间、masters-registry/upload-map 行、master-prompt-store 条目] / 上游输入 / 验收依赖}，登记于 Lane 表「共享引用集」列。规则：① **只读共享+版本冻结**——共享锚件（角色/场景母图、道具 sheet、风格锚、关键帧件）以 `id+版本+sha256` 冻结，引用时登记 sha256，子代理对共享锚件只读（写进派发 prompt §4 Scope 禁改清单，templates/subagent_dispatch.md）；② **单写者原则**——共享可变资源（masters-registry/upload-map/master-prompt-store/VERSIONS.md/Lane 表/计划三文件）由主进程单写者维护，子代理只追加自己锚点（22.4a 与 49.4②）；③ **共享引用登记表**（task_plan.md 新增区块）——每行=资源 id/类型/路径/sha256/引用单元清单/状态(现役|frozen|stale)，用于锚件换代时批量定位受影响单元；④ **产出命名空间隔离**——汇合件（整片/成片/VERSIONS.md/台账）由 Aggregator 单写；⑤ **预算账本隔离**——每单元独立 piece_id 命名空间（如 `ep8-<unit>-*`），禁两单元共用同一 piece_id（AGENTS 约束 19）；⑥ **锚件换代协议（stale 广播+冻结锁）**——任一单元需改共享锚→先过 G1 人工门+单写者登记+对引用该锚的单元广播 stale；换代期间该锚加冻结锁禁止其它单元并行消费；换代完成后按 sha 差集重跑 stale 单元（引用同步：grep 旧 sha 0 命中方可提交，对齐 AGENTS 约束 13③ 引用同步条款）；⑦ **引用同步验证**——单元完成时 grep 其引用集 sha 是否=现役 sha，不等=stale，禁标 complete。
23.13 **机器守卫边界（如实披露，Rule 35.2 防虚构）**:`scripts/check-dispatch.sh` 的 `serial_slot_check` 只有一个全局锁 `subagent-state/.dispatch-inflight`（120s age），组标记命中即放行，**不区分组名、不做四问机器校验**（21.4 机器守护段同述；该函数内注释明写「守卫信任标记不做四问机器校验」）。结论：机器层只能「放行有标记的派发」，冲突检测责任在计划期声明+执行期四问（LLM 行为面）。若要机器兜底 lane 内串行，建议把单一时间戳锁升级为 `{lane: ts}` 映射、派发时校验「同 lane 无在飞」——零新 config 键，仅加富锁文件格式（后续任务项，本规则不实现）。**fan-out Aggregator 硬校验（23.6/18.7）现已生效**（check-complete.sh 校验正则 `Phase \d+:.*Aggregator|聚合`，缺失 exit 1）：fan-out 计划必须预置 Aggregator Phase 占位。


### 25 子代理委派门控（P0）— 计划期声明执行体,执行期强制检查,终验期统计委派率
Rule 13/14 定义"什么活必须派子代理",本规则把委派做成**流程门控**:不经委派决策点,工作不得开始。目标:主进程 = 调度器,实际工作由子代理承载,提高 haiku-1/sonnet-1 子代理 token 占比。

25.1 **计划期 — Executor 字段强制 + S-unit 表强制**:task_plan.md 每个 Phase 必须含 `**Executor:** subagent_type(model)` 行(默认按 SKILL.md 路由表选型);Executor=主进程必须写例外理由(白名单见 25.3,如"① 纯 git/worktree 编排"/"② 计划系统文件维护");Executor≠主进程的 Phase 还必须含 22.6 S-unit 派发单元表(计划期拆步,每行一次派发);无 Executor 字段或派发型 Phase 缺 S-unit 表 = 计划无效,plan-writer 产出校验失败;每个 S-unit 行「执行体」列非空(继承或具体类型);计划批准时 `bash scripts/check-plan-dispatch.sh <task_plan.md>` 机械校验派发型 Phase 的 S-unit 表与执行体列(缺表/缺列/执行体空 → 拒绝锁定 attest,Rule 22.6 机制化)（attest 门控范围 2026-09-16 起=S-unit 表+执行体+数值门控；fmea_enforce 消费方=attest-plan.sh+check-complete.sh 双点）
25.2 **执行期 — 委派检查点**:Phase 执行循环步骤 2.5(SKILL.md):开始实际工作前先查 Executor → 非主进程立即按 Rule 22.4 九字段模板**逐 S-unit** 派发(每次派发对应 22.6 表一行;所有 S-unit 按 Rule 21.4 调度铁律派发([EVOLVED 2026-10-02]——声明并行组内成员可并行(独立性四问通过)、组间及未声明者串行,一次验收一组成员再派下一组成员;'互不影响、互不依赖'为并行前提(10-02 用户裁决));每个仍须独立 Read 复核 + 独立 Handoff 行)+ Handoff 登记表登记;派发型 Phase 无 S-unit 表 → 计划无效,先回炉补表并重跑 attest 再动;禁止"先自己干,干不动再派",禁止把多个 S-unit 合并成一次大派发
25.3 **例外理由登记（白名单制）**:主进程直做的 Phase,例外理由必须写在计划 Executor 字段内(计划确认时用户可见);**有效理由仅限六项白名单**——① 纯 git/worktree 编排 ② 计划系统文件维护(三件套/INDEX/ledger/attest/plan 模板) ③ 机械验证命令(只读,输出可控) ④ 用户显式要求主进程亲为 ⑤ Rule 22.3 兜底接管(单文件 ≤300 行) ⑥ trivial/mini 直做通道(非保护区;非 mini 档=单文件 ≤3 行,mini 档 ≤30 行/≤2 文件/单模块/≤15min——[task-v094 T-B4]);白名单外理由(如"效率高""顺手")视为未登记,按 25.4/26 Q5 处置;执行期新增例外 → 先回填计划再继续
25.4 **终验期 — 委派率统计**:交付前统计「子代理执行 Phase 数 / 总 Phase 数」+ 主进程直做清单(含理由)写入 verification.md「委派统计」段;委派率 < `config.json#delegation_rate_floor`(默认 0.7)或主进程直做清单含白名单外理由 → outcome 最高 PARTIAL;全部直做理由均在白名单内 → 不降级(编排/簿记型任务属正常形态)
25.4a **白名单豁免的机械执行(check-complete.sh 终验,2026-09-10)**:rate<floor 时,主进程直做清单全空或每条理由均命中 25.3 六项白名单关键词(①git/worktree 编排 ②计划系统文件 ③机械验证 ④用户显式 ⑤兜底接管 ⑥trivial)→ 输出 `DELEGATION RATE WHITELIST-EXEMPT` 标记并放行(不降级);任一理由未命中白名单 → 保持 FAILED;jq 缺失 → fail-closed 不豁免(维持旧行为)
25.5 **与 Rule 13/14/21 关系**:13/14 管"哪些活必须派",21 管"拆到多小",25 管"流程上必须过委派决策点"——三者叠加,25 是执行入口的最后防线
25.6 **失败联动**:委派检查点发现无法派发(Agent 工具不可用/连续失败)→ 按 Rule 22.3 兜底顺序处理并在 progress.md 记录,禁止静默转主进程亲为


### 46 子代理单任务专注度（P0, 2026-10-03 task-v118，目标：单会话单 S-unit、批次连做禁止——保证子代理单任务专注度与执行可靠性；判定面=LLM 行为+check-dispatch.sh 机器面、零新 config 键；衔接 Rule 25.2/35.3/21.4，既有 Rules 原文零改动）

本条源于 task-v117 实证（1-executor 单会话连领 S2-S10 分 4 批次追加 checkpoint，逐 prompt 守卫全失明）+ task-v116/v113/v115 反例（任务书豁免打包门+markdown 编号漏检、12-19KB 复合「普查+方案」单检查点）：S-unit 粒度纪律（Rule 21.1b/25.2）只管单次派发 prompt，对「同一执行会话内批次式连做」结构性失明——本条把单会话单 S-unit 立为制度面（衔接不复制，Rule 36.5 纯增量）。

46.1 **单会话单 S-unit（批次追加禁止）**：一次子代理执行会话（Agent() 派发到返回）只领取 S-unit 表一行；完成后交回主进程验收，再派下一个 S-unit（Rule 25.2 既有口径的会话级延伸，Why: 防 task-v117 批次形态）。禁止同一会话内「批次追加」——多 S-unit 需求=多次独立 Agent() 派发；并行合规面仍按 Rule 21.4 独立性四问判定。
46.2 **守卫豁免收窄（check-dispatch.sh 承载，Why: 收口 task-v116「任务书豁免+markdown 编号双漏检」形态）**：Rule 35.3 落盘任务书场景下打包检测不整体豁免——任务书文件可解析时对其内容做 distinct S-unit ID 计数（≥2 即打包拦截）与步骤枚举计数（行首 markdown 编号列表计入任务书口径）；文件不可解析保留 SKIPPED（fail-open，既有 FG-05 fixture 不破）；自由 prompt 的行首 markdown 编号排除口径不变（防误伤既有合法 prompt 形态）。
46.3 **拆分单一性（计划期 S-unit 目标单一化，Why: task-v113/v115 复合「普查+方案」12-19KB 单检查点反例）**：调研与产出分离——普查/分析类 S-unit 禁捆绑方案设计与修订产出；单 S-unit 预估超 15min 或目标句含「并/且/再」连接的复合动作，回炉拆分（Rule 21.1b 口径延伸，超限时先拆后派）。
46.4 **模板显式引导（templates/subagent_dispatch.md，Why: 弱因兜底——引导语缺位时小模型无会话粒度纪律自觉）**：目标段含「本会话只执行本 S-unit，完成后交回主进程再派下一个」引导语；checkpoint 段禁批次追加——每会话单检查点，追加批次即违反 46.1。
46.5 **机制（零新 config 键，Why: 与 43.4/44.4 同范式——判定面主体=LLM 行为，机器面挂既有档位管线不新增键）**：46.2 机器面挂 check-dispatch.sh（既有 dispatch_contract_enforce 三档：off/warn/enforce）；selftest-dispatch-grain.sh 静态守护（46.1 至 46.4 四子条文本锚+46.2 守卫行为 fixture）；与 Rule 21.4 关系澄清：并行组=「多个独立会话各领 1 个 S-unit」，与单会话连领多 S-unit 本质不同（并行合规≠批次合规）。


### 52 执行体专业化优先与覆盖矩阵维护（P0, 2026-10-04 task-v125，目标：派发选型「专用体优先」机制化——覆盖矩阵为选型单一事实源、三类缺口机器守护，消除「有体不用/映射指向不存在实体/无映射落泛兜底」；判定面=LLM 行为+selftest 静态守护、零新 config 键；衔接 Rule 21/25/37/47，既有 Rules 原文零改动）

本条源于用户 2026-10-03 反馈：「很多任务总是喜爱使用通用的 Agent……确保后期再次拆分子代理执行任务的时候，可以使用更对应的专业代理进行执行」。审计实证（task-v125）：代理资产 87 个（14 族），但 41 个实体未入任一登记面（有体不用）、5 条登记指向不存在/名不符实体、媒体族 11 类无具名映射——「专用体不够用」实为「映射与登记脱节」+provider 可用性叠加（v124 已补媒体执行体=首个联动先例）。

52.1 **选型顺序（专用体优先）**：计划期/执行期为 S-unit 选择执行体时，必须先查覆盖矩阵（`references/agent-coverage.md`）与三登记面（SKILL.md 路由表/skill-agent-router/template-mapping §九§十）：矩阵列有专用体 → 必须用专用体；专用体缺位 → 按族兜底（一等候选=具备工序 SOP 的 executor(sonnet-1) 组合）并在 Executor/S-unit 表登记兜底理由；general-purpose 仅限跨领域复合/无法归类（对齐宪法 §一 与 Rule 47.2，禁「路由表无匹配行」式默认落泛）。

52.2 **三类缺口禁新增（机器门）**：A 类（类型无具名映射）须有兜底登记；B 类（登记名指向不存在/名不符实体）零容忍——所有登记名必须 `test -f` 于 agents 目录（目录缺位 fail-open SKIPPED）；C 类（实体未登记）以矩阵「纳入/豁免」表逐行核对（豁免须一行理由）。任何登记面改动须同任务更新矩阵（change-linkage）。

52.3 **矩阵维护责任**：agent 增/删/改名或登记面改动 → 矩阵与三登记面同任务同步（禁悬空）；新增专用体落地后必须回填矩阵与登记面行（task-v124→v125 联动先例：媒体执行体落地即登记）。

52.4 **机制（零新 config 键 — 与 43.4/44.4/47.4 同范式）**：判定面=LLM 行为（选型查矩阵、兜底登记理由、维护同步）；机器面=`scripts/selftest-agent-coverage.sh` 静态断言（矩阵在位/三登记面锚/B 类实体存在性/C 类处置覆盖/零新键）；消费侧=委派检查点（执行循环 2.5）选型对照与 Handoff 摘要附注；既有 21/25/37/47 原文零改动（Rule 36.5 纯增量）。


<!-- Rule 59 (task-v144 2026-10-08): 纯增量新增；判例=用户 R1-R6 五条缺陷原话（拆分不细致/子代理无技能/上下文叠加/能力不匹配/技能库闲置，全文见 plans/task-v144/task_plan.md「🎯 用户需求原文」） -->

### 59 子代理拆分粒度硬门与技能伴飞纪律（P0, 2026-10-08 task-v144，目标：计划期粒度三值 enforce 硬门 + 派发侧技能伴飞注入 + 执行前技能扫描 + 能力预防判据 + 分段执行锚，根除「单子代理巨量任务/子代理无技能强化/上下文反复叠加/复杂任务超执行体档位能力/200+ 技能库闲置」五缺陷；判定面=LLM 行为+check-dispatch.sh enforce 硬门+selftest 静态守护、零新 config 键；衔接 Rule 21.1b/21.4/22.3/22.4/43.2/46.1，既有 Rules 原文零改动）

本条源于用户 2026-10-08 反馈原话 R1-R6（逐字抄录于 plans/task-v144/task_plan.md「🎯 用户需求原文」区块，51.1 口径）：「没有将子代理任务拆分细致 导致单个子代理解决巨量任务」（R1）；「尤其单个子代理不具备skill」（R2）；「子代理过大也会导致上下文反复叠加」（R3）；「子代理执行复杂任务 导致模型能力不够时候导致无法正确运行」（R4）；「基本没有调研 /comet 技能来进行任务执行的强化执行 我从来没有见过激活 …… supowerpowers 的相关技能也从未激活过 比如 头脑风暴」（R5）；「总之就是存在严重的缺陷 子代理拆分细致拆分 以及 任务分段执行」（R6）。归因（根源覆盖表，task_plan.md）：21.1b 粒度三值仅 SKIPPED 提示不阻断（超限 S-unit 合法流入派发）；22.4 九字段派发任务书无技能字段且工具面事实=仅 3 agent（task-orchestrator/auto-agent/article-research-heavy-agent）具备 Skill 工具而 Read 全量具备；技能库 200+（comet 族/superpowers 族/brainstorming 等）在计划期零扫描零匹配；22.3 拆细先于升档仅是失败后兜底而非计划期预防；46.1 单会话单 S-unit 在位但分段执行未与粒度门成链，大任务书可经任务书豁免 fail-open 溜入。

59.1 **粒度三值硬门（three-value granularity gate，对应用户 R1/R3/R6）**：每个 S-unit 必须在 task_plan.md S-unit 表强制填报三值 `Nf/Nl/Nmin`（文件数/新增行数/预估分钟，模板行格式 `1f/65l/13min`）；三值任一项超 `config.json#subagent.step_max_files`(2)/`step_max_lines`(100)/`step_max_minutes`(15) → check-plan-dispatch.sh attest 时对粒度三值列超限 SKIPPED→enforce 拒锁（本条落地,task-v144）;check-dispatch.sh 派发侧为新增检测（该脚本此前无粒度检查）,prompt 含 Nf/Nl/Nmin token 超限即 enforce（复用既有档位键，超限 S-unit 拒锁回炉重拆，禁止整体派出；行内「例外」登记在案=超限留痕不阻断，见 check-plan-dispatch.sh ⑤-c 注释）。What=超限即拒锁而非提示；Why=R1「单个子代理解决巨量任务」+R3「子代理过大导致上下文反复叠加」——三值超限行流入派发=巨量任务源头，提示不阻断（21.1b 自认「拆分判断归模型」）使守门形同虚设；回炉重拆（而非升档换模型）是 R6「细致拆分」的计划期机器落地。

59.2 **技能伴飞（skill-escort injection，对应用户 R2）**：S-unit 表新增「伴飞技能」列（技能名或 `无`=纯机械单元）；派发任务书 §2 按列值注入伴飞技能 SKILL.md **绝对路径**，子代理任务书规定**首动作 Read 该路径**（工具面事实：全部子代理具备 Read，仅 3 个 agent 具备 Skill 工具——Read 伴飞为唯一可泛化的注入路径，改 agent 定义=动保护区，59.7 同面）；重型技能（SKILL.md 全文 >300 行或含多 variant 文档）禁止要求子代理通读全文，由**主进程提炼 ≤20 行要点内联**进任务书材料包并附全文路径供子代理按需回读。What=技能以「路径+首动作 Read」形态随任务书到达子代理；Why=R2「单个子代理不具备skill」——22.4 九字段无技能字段+子代理多数无 Skill 工具=技能强化全链缺失；主进程提炼要点内联同时防 R3 上下文叠加（子代理只读 20 行要点而非数百行全文）。

59.3 **执行前技能扫描（pre-dispatch skill scan，对应用户 R5）**：任务画像期（plan-writer/knowledge-brief 填写阶段）必须扫描可用技能面（~/.zcode/skills 与 ~/.agents/skills 索引），把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）写入 knowledge-brief「可用强化技能」区块（技能名/路径/匹配点/激活方式四列），供 S-unit 伴飞技能列取值；**用户触发型技能（comet 族等 frontmatter 声明 disable-model-invocation 设计者）仅提示用户可手动激活，禁止主进程/子代理自动代激活**——尊重其设计语义，「从未见过激活」（R5）的治理解法=显式可见性（扫描入 brief 供用户与执行体择用），而非越权代触发。What=计划期技能选型先于派发；Why=R5 技能库 200+ 从不被扫描匹配、comet/superpowers/brainstorming 闲置=强化执行能力存在但无接线。

59.4 **能力预防判据（capability-prevention rule，对应用户 R4）**：计划期预估（59.1 三值 + 任务复杂度定性档 43.2）超出目标执行体档位承载能力（如判断型复杂任务预估需多轮试错/长上下文）时，**先拆细再派，禁止派出去等失败再兜底**——22.3「拆细先于升档」理念前移到计划期预防性执行：预估超档 → 拆成多个低档可载 S-unit（各自过 59.1 硬门）；拆后仍超档才走 22.3 既有兜底链（改派/升档/降档五档）。What=超档复杂度=拆细触发器，非执行后补救信号；Why=R4「子代理执行复杂任务 导致模型能力不够无法正确运行」——既有 22.3 只在失败后兜底，失败时上下文已污染，预防性拆细是唯一不付失败代价的路径。

59.5 **分段执行锚（segmented-execution anchor，对应用户 R6「任务分段执行」）**：多段任务 = 多 S-unit + 多次独立 Agent() 派发 + 检查点链（每段独立 checkpoint 文件 `<plan-dir>/subagent-state/{seq}-{agent_type}.md`，46.1 单会话单 S-unit 口径：段与段之间=会话与会话之间的交接，前段三证据验收后才派后段）；**任务书豁免 fail-open 收窄**：46.2 任务书场景打包检测在文件可解析时不再整体豁免——59.1 三值列与 59.2 伴飞列在任务书内同样受 enforce 硬门约束，豁免仅保留「文件不可解析」fail-open 一档（既有 FG-05 fixture 语义不变）。What=分段=计划结构（S-unit 表行数）而非执行时临时切分；Why=R3/R6 上下文叠加与分段执行诉求——单一大任务书经豁免溜入即分段纪律失效，收窄豁免面使 46.1 与 59.1 成链。

59.6 **机制守护（mechanism guard）**：机器面=`scripts/analyze-splits.sh`（读 S-unit 表三值列输出超限行拆分建议：干净 exit 0 / 有超限 exit 1，吸收 task-v135 丢失的拆分体检目标）+ `scripts/selftest-subagent-granularity-skill-escort.sh`（59.1-59.7 七子条文本锚 + 模板双列锚 + 伴飞子节锚 + check-dispatch enforce 断言 + 零新键声明，静态守护）+ selftest-registry.tsv 登记；消费侧=SKILL.md 合规清单 + 委派检查点（执行循环 2.5）对照。What=新条款挂既有档位管线+静态断言，防锚级联（55.6 同范式：只断言新增锚）；Why=53.2 根治判据载体=守卫（机器校验断言）+机制（三值列成链），条款无挂点=条款死文。

59.7 **零新 config 键（no-new-key constraint）**：本条体系不新增任何 config.json 键——59.1 三值上限直接复用既有 `subagent.step_max_files/step_max_lines/step_max_minutes` 键（现行值 2/100/15），enforce 档位复用既有 dispatch 三档（off/warn/enforce）；伴飞技能列与「可用强化技能」区块为模板/任务书面字段，非机器键。Why=与 43.4/44.4/46.5/47.4/54.6/55.6 同范式（判定面主体=LLM 行为+模板字段，机器面挂既有档位管线不新增键）——键膨胀=配置面失控面，零新键是本体系可演进前提。

59.8 **与既有 Rules 关系（complementary）**：本条与 21.1b（粒度上限）=提示→enforce 升级（原文零改动，升级在脚本档）；与 46.1（单会话单 S-unit）=分段执行锚的会话级载体（46.1 管会话内不连领，59.5 管段间验收链）；与 22.3（失败兜底链）=前移预防（59.4 计划期拆细先于 22.3 执行期兜底，两者串联非替代）；与 52.1（专用体优先选型）正交——52 管「选谁执行」，59 管「怎么拆/带什么技能/分几段」；既有 Rules 原文零改动（Rule 36.5 纯增量；合并序注：58=v143/60=v142 改号/62=v145 先行落地，59 按合并时间序列文件尾）。

<!-- Rule 63 (task-v147 2026-10-08): 纯增量新增；判例=用户 2026-10-08 会话原话 R1-R5（逐字抄录于 plans/task-v147-research-first/task_plan.md「🎯 用户需求原文」区块，51.1 口径）——「不知道的事情去网上查，不清楚的事情去网络上查」「所有的事情都需要有理有据」「网络上什么都有」 -->


### 68 计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律（2026-10-09 task-v153，目标：计划初期显式分析依赖→推导并行分组→组内异构 agent/模型分摊→组内更新防错乱，可并行者并行加速、有依赖者串行逐个击破）

68.1 **计划期强制依赖分析（plan-time dependency analysis）**：S-unit 表定稿后、attest 前，对全部 S-unit 过独立性四问静态版（21.4 四问的计划期口径）——①写集相交（scope_files 交集非空）②资源相争（同部署位/分支/交付物/计划文件锚点/额度窗口）③输入依赖他者产出（本单元输入=他单元输出路径或其产物内容）④验收依赖他者结果（本单元验收证据取自他单元产物）。分析结论显式落 S-unit 表「前置依赖」列（无依赖显式填 `-`，多依赖顿号分隔、引用被依赖单元 ID）；未做分析或该列空白=计划无效回炉（59.1 硬门同档）；分析过程在计划内留痕（依赖分析注记/design 稿引用），禁口头心算（54.5 决策依据落盘）。

68.2 **并行分组推导（group derivation）**：`parallel_groups` 声明必须由 68.1 依赖分析推导——同组成员两两四问全 no 才可入组；「前置依赖」非空者禁止与其被依赖者同组（68.6 hard 档机器可校验）；组间按依赖拓扑排序，前组未齐验收不得派后组（21.4 组间串行语义不变，不回退）；未声明组=串行（21.4 默认不回退）。分组目标=在依赖约束下最大化并行度：优先把经四问判定独立的单元划入同一批准组，杜绝「全计划默认串行」的惰性分组。

68.3 **组内异构分摊（heterogeneous allocation）**：同一并行组内成员的执行体 subagent_type 或 model 档位至少一项互不相同；整组「继承」同一 Phase Executor 禁止——并行组内成员的执行体列必须逐行具体化。43.2 最小可承载档位优先级高于异构：禁止为追求异构而升档/降档；同档可承载时优先按 agent 类型差异实现异构（专用体/通用体分工），模型档位差异其次。依据（如实披露）：把所有并行子任务交给单一模型=资源消耗不可控（dynamic-workflows schema 级实证：其 subagent_model 为 run 级单一字段、agent() 无 per-task 模型/类型覆盖——SKILL.md:115,960-963,1023），异构分摊将并行负载分散到不同 agent/模型档位。

68.4 **组域写隔离与状态一致性（group write isolation）**：组内成员只写三类目标——自己检查点（22.8 subagent-state）、findings.md 追加小节（22.4a 契约）、自己 scope_files；计划三文件（task_plan/findings/progress/verification）的状态列、Subagent Handoff 表、Lane 表一律由主进程**按组串行回写**（单写者原则 49.4② 推广到通用 S-unit）。推进序=成员完成→组批验收（22.5 三证据）→主进程统一翻状态（含 [goal:Gn] 证据行，66.3 联动）；禁止组内并行成员直接 Edit 计划三文件（check-delegation 既有拦截为主、68.6 advisory 检测为辅）；跨组状态变更经主进程协调，任何成员不得代表他组翻格。目标=整段并行运行时状态更新不错乱。

68.5 **借鉴 workflow 编排三要点（parallel playbook）**：先收窄再 fan-out（派发前用 Explore/grep 把候选集收窄到可指名文件集，禁对未收窄全集并行派发——dynamic-workflows patterns.md:45-54 同源）；唯一 join 原则（每并行组仅一个汇合点=组批验收或 Aggregator Phase，禁多 barrier 使最慢成员卡住全组后续——dynamic-workflows SKILL.md:321-345 同源）；结果即落盘（成员每完成一里程碑立即写检查点，中途被杀不丢产出——22.8 检查点纪律在并行语境的重申）。

68.6 **守卫（guard）**：check-plan-dispatch.sh 计划期扩展两档——hard 档（拒锁）：组标记存在性（frontmatter `parallel_groups` 每个组名在 S-unit 表内有对应 `[parallel-group:<组名>]` 标记行）、依赖-同组矛盾（「前置依赖」列非空的行与其被依赖行同组）、「前置依赖」列存在且逐行非空（无依赖显式 `-`）；advisory 档（WARN 不拒锁）：组内执行体全同（同组内 `subagent_type(model)` 列全部相同→提示异构化）、组内成员执行体全部「继承」。机器边界如实披露：守卫只消费表内显式字段，不做文件集交集自动推断（68.1 分析责任在计划者）；串行槽仍为全局单锁、组间串行为 21.4 既有语义（`{组名: ts}` 富锁升级=已登记后续任务项，非本条范围）。

68.7 **机制（mechanism）**：零新 config 键（沿用 25.4/43.4/66.6 零新键纪律）；机器面=check-plan-dispatch.sh 计划期两档校验 + scripts/selftest-parallel-scheduling.sh 静态守护（68.1-68.7 子条锚 / 模板「前置依赖」列锚 / SKILL 摘要行 / C46 合规行 / registry 登记行 / 零新键负断言 / 21.4 语义未回退负断言）+ selftest-registry.tsv 登记；合规清单 C46（SKILL.md 消费侧）；模板承载=templates/task_plan.md S-unit 表「前置依赖」列（68.1 消费面）；模式库承载=split-pattern-library.md P12 依赖分批并行。
