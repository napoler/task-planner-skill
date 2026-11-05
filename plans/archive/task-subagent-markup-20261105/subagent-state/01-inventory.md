# 01-inventory — task-planner 技能族「子代理使用点标注」机制覆盖度盘点
（盘点时刻 2026-11-05；全程只读；证据=绝对路径+行号）

## 1. critical-rules-dispatch.md 条款定位
文件：/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md（239 行）

| 规则 | 行号范围 | 核心内容摘要 | 是否已有「显式标注使用点」内容 |
|---|---|---|---|
| Rule 25 委派门控 | 100-109 | 25.1（行103）计划期每个 Phase 必须含 `**Executor:** subagent_type(model)` 行；Executor=主进程必须写例外理由；Executor≠主进程必须附 22.6 S-unit 表；check-plan-dispatch.sh attest 缺表/缺列/执行体空→拒锁。25.2（行104）执行期委派检查点=逐 S-unit 派发+Handoff 登记。25.3（行105）例外理由白名单制。25.4（行106）终验委派率统计+verification.md 落盘。25.4a（行107）白名单豁免机械执行 | **有**——Executor 字段=计划文档显式标注使用点的既有载体（Phase 级） |
| Rule 25.3 六项白名单 | 105 | ① 纯 git/worktree 编排 ② 计划系统文件维护(三件套/INDEX/ledger/attest/plan 模板) ③ 机械验证命令(只读,输出可控) ④ 用户显式要求主进程亲为 ⑤ Rule 22.3 兜底接管(单文件 ≤300 行) ⑥ trivial/mini 直做通道(非保护区;非 mini=单文件 ≤3 行,mini ≤30 行/≤2 文件/单模块/≤15min) | 白名单关键词机判在 check-delegation stats（①-⑥/白名单1~6 编号标识，行447） |
| Rule 52 执行体专业化 | 133-143 | 52.1（行137）选型顺序：先查覆盖矩阵 agent-coverage.md+三登记面，矩阵有专用体→必须用；缺位→族兜底（executor(sonnet-1)）并在 Executor/S-unit 表登记兜底理由；general-purpose 仅限跨域复合/无法归类。52.2（行139）A/B/C 三类缺口机器门。52.4（行143）消费侧=委派检查点（执行循环 2.5）选型对照 | **有**——Executor/S-unit 表登记兜底理由=显式标注；但矩阵本身只被"选型时查"，无模板内联标注要求 |
| Rule 59 拆分粒度硬门 | 148-166 | 59.1（行152）S-unit 表强制三值 `Nf/Nl/Nmin`（模板行 `1f/65l/13min`）超限→check-plan-dispatch enforce 拒锁。59.2（行154）S-unit 表新增「伴飞技能」列，派发任务书 §2 注入技能绝对路径+首动作 Read。59.4（行158）超档先拆细再派。59.6（行162）机器面 selftest 静态守护 | **有**——三值列/伴飞技能列=S-unit 级显式填报面 |
| Rule 96 激活默认档 | 188-216 | 96.1（行192-204）激活默认档矩阵：7 类触发类别→Executor 默认为子代理派发。96.2（行206）计划期正向选档（轻 haiku-1/中 sonnet-1/重 GLM5.3-Opus 备用）。96.3（行210）「前置依赖=-且四问全no 的 S-unit ≥2 个必须声明并行组」。96.4（行212）并行组成员同消息并发派发。96.5（行214）交付前 task_plan「📊 委派统计」追加 激活子代理数/最大并行宽度/串行化例外理由 三行 | **部分有**——96.1 只说"命中类别→默认子代理"，类别判定以 22.6 表「目标」列措辞为准（行204），无逐行标注列；判定面=LLM 行为、零机器门（行188 题注） |

**Rule 96 七类触发类别与默认动作**（行194-204，矩阵 #A1-A7）：
| 类 | 触发类别（可判定口径） | 默认动作 |
|---|---|---|
| A1 | 制定计划/起草规划/方案设计（产出=计划文档/规划草案/设计稿） | 默认派子代理（新增面，13 未覆盖） |
| A2 | 调研分析/证据收集（网络检索/本地普查/根因分析） | 默认派子代理（13「调研」强化） |
| A3 | 多文件搜索定位（位置不确定、需通读多文件） | 默认派子代理（13「搜索/跨文件 Read」强化） |
| A4 | 大文件/长输出消化（>500 行读取/翻日志/长网页提炼） | 默认派子代理（13「大文件读取」强化） |
| A5 | 验证/审查（独立验证视角/代码审查/完成度复核） | 默认派子代理（新增面） |
| A6 | 批量既定步骤（SOP 式批量执行） | 默认派子代理（新增面） |
| A7 | 独立创作单元（文案/文档/媒体等可独立验收创作物） | 默认派子代理（新增面） |

主进程直做=例外，须命中 96.1 窄白名单三锚（行204）：① 单行命令/单文件 ≤3 行 trivial 微改（25.3⑥同面）② 已知位置单事实查询（定点 Read ≤1 次）③ 命中 25.3 六项白名单且派发开销显著大于收益（理由须点名白名单项号）。

**「在技能/模板/计划文档中显式标注使用点」的既有条款**：
- 计划文档面：Executor 字段（25.1 行103）+ S-unit 表执行体列（22.6 行64，默认"继承"）+ 三值列/伴飞列/前置依赖列（59.1/59.2/68.1）——都是"执行体是谁"的标注，不是"该 S-unit 命中 96 哪类触发类别、为何主进程保留"的标注。
- 技能/模板面：task_plan.md 模板行280/328-339 注释只要求填执行体，无 96.1 类别命中标注列（grep "96.1\|七类\|默认派发" 模板 0 命中）。SKILL.md 行250 仅一段 Rule 96 内联摘要（指针+浓缩，非内联矩阵）。critical-rules-dispatch.md 行188 题注自述"零新机器门"。
- 结论：无"逐行标注子代理使用点（类别+理由）"的条款。

## 2. agent-coverage.md 结构与引用链
文件：/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/agent-coverage.md（130 行）
- 结构（非"覆盖矩阵表格列"，是四节报告式矩阵）：
  - §一（行9-42）类型族×专用体×登记状态表：列=`# | 类型族 | 专用体（登记面） | 登记状态/兜底`，28 行（行11-40）；登记面 D1=SKILL.md 路由表/D2=skill-agent-router/D3=template-mapping §九§十
  - §二（行44-63）三类缺口处置表：A 类=无具名映射→兜底登记；B 类=登记名指向不存在实体（零容忍，test -f 实证）；
  - §三（行65-113）C 类 41 实体纳入/豁免表：列=`# | agent（实体） | 相 | 登记去向 | 纳入/豁免 | 理由`
  - §四（行115-130）零专用体领域清单（9+1 领域，P0/P1/P2 建议优先级）
- 引用链（谁在什么时机读它）：
  1. Rule 52.1（critical-rules-dispatch.md 行137）：计划期/执行期选 S-unit 执行体时**先查**本矩阵+三登记面
  2. Rule 52.4（行143）：消费侧=委派检查点（SKILL.md 执行循环 2.5）选型对照；机器面=selftest-agent-coverage.sh AC-01..09 静态守护
  3. task-planner SKILL.md 行270 References 表：`agent-coverage.md | 执行体覆盖矩阵（Rule 52.1）`（指针）
  4. task-dispatch SKILL.md 行40/60：Rule 52 索引行+文件指针
  5. 矩阵头部自述（行3）维护责任 52.3 change-linkage
  - 时机=选型时按需查（无机器强制读取时机；无 selftest 断言"派发前必须查"）。

## 3. task_plan 模板 Executor 现状
模板：/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md（573 行）
- Phase 级标注：`## Phases` 段（行275起），模板注释行280 要求每 Phase 声明 `**Executor:**`（Rule 25.1），主进程直做必须写例外理由；示例：Phase1 行294 `explore（mini）`、Phase2 行312 `主进程（例外理由:②…）`、Phase3 行325 `code-assistant（haiku-1）`、Phase5 行369 `主进程（例外理由:①git 编排+②簿记）`
- S-unit 表（行328-342，Phase 3 示范）表头行339：`| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |`——**有执行体列，列名「执行体(subagent_type(model))」**；默认填「继承」=Phase Executor（行280/339），示例行340-341 `S1/S2 继承`
- 机器契约注释（行328-338）：时长/输入超限 enforce 拒锁（59.1）、ID 纯数字、三值列逐行校验、伴飞技能列路径校验（59.2）、前置依赖列必填（68.1）、**96.3 并行硬标注**（行337：前置依赖=-且四问全no≥2 个→必须声明并行组+行内 [parallel-group:<组名>]）
- 终验落盘面：行494-507「📊 委派统计（Rule 25.4）」区块含 96.5 三行指标（激活子代理数行505/最大并行宽度行506/串行化例外理由行507）
- **缺口**：① 无「主进程保留 vs 子代理」分工说明区块（唯一分工面=Executor 字段自身+96.1 行为条款）；② 无 96.1 七类触发类别的命中标注列（模板 grep "96.1/七类/默认派发" 0 命中；96 只出现在委派统计 96.5 行与 96.3/96.4 注释行337/34）；③ 执行体列默认值「继承」语义=跟随 Phase，但 96.1 默认档要求命中七类即默认派发——模板示例 S1/S2 填「继承」恰好落在"主进程保留编排"侧无冲突，但模板未提示"命中 A1-A7 类目标时执行体列应写具体子代理类型而非留主进程"。

## 4. check-plan-dispatch.sh 校验逻辑
脚本：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-dispatch.sh（676 行）
- 触发与对象：attest-plan.sh 锁定 + check-complete.sh 终验调用（头注行13）；逐 `### Phase` 块状态机扫描（行211-311）
- Phase 分类（行232-234,186-201）：Phase 内首个 `**Executor:**` 行含「主进程」=主进程 Phase（免检，S190 return）；不含=派发型（无 Executor 行按派发型从严，行6）；缺 S-unit 表（表头须为 `| ID |` 开头且含「执行体」列，行237-241）或数据行 0 → 违规"缺 S-unit 表或数据行(Rule 22.6)"（行198-199）→ exit 1 拒锁
- 执行体列校验（行243-250）：`| S<n> |` 数据行按 `awk -F'|'` 第 4 字段取执行体列，空或 `-` → 违规"行 S<n> 执行体为空"
- 数值门控（仅派发型 Phase 数据行）：① 预估时长列（$7，NNmin 格式）超 step_max_minutes(15)→SKIPPED 提示不阻断（行261-268）；② 输入列（$5）文件路径 token>step_max_files(2)→SKIPPED（行270-273）；③ 粒度三值列（$8，`Nf/Nl/Nmin`）任一超限→**add_violation 拒锁**（Rule 59.1，行278-297；「例外登记」在案行降为 SKIPPED 行283-286；格式不可解析/未填报=SKIPPED fail-open 行298-301）；④ 目标列步骤枚举>step_max_steps(4)→SKIPPED（行303-309）
- 档位门控（仅显式 plan_tier: standard|full 执行）：Rule 66.5 Goal 单元表区块六列硬校验（行333-412）；Rule 68 段 H1「前置依赖」列存在/H2 逐行非空/F8 列数漂移/H3 组标记存在性/H4 依赖-同组矛盾=hard 拒锁，W1 组内全同执行体/W2 全部「继承」=advisory WARN（行414-651）；Rule 75.1 调研区块 advisory（行660-664）
- mini 档豁免：plan_tier mini 且全 Phase Executor=主进程→S-unit 表缺失视为合规（行85-97）
- **不校验**：执行体值是否命中 96.1 七类、是否按 52.1 专用体优先（选"继承"还是具体类型无机械判据，W2 只对组内全「继承」打 WARN）；Executor 列写「主进程」但目标命中 A1-A7 的情况无拦截。

## 5. check-delegation.sh Executor 识别口径
脚本：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh（692 行）
- **pretool 模式（行274-400）**=执行期拦截主进程直做（不读 Executor 字段，靠会话侧识别）：sid≠.session-owner→判定子代理→放行（行294-315，取舍注释：子代理在 prompt 授权范围内写入，验 owner 之外即误伤）；主进程（owner==sid）走白名单链：plans/*.md|.json、.claude/plan-templates、.zcode/plans、memories、SKILL_ROOT（行149-180）→trivial ≤3 行（行323-328）→④b mini 直做通道（行335-363，plan_tier mini∧非保护区∧new_string≤30 行）→④c L0-E 纯执行档机械产物区（行365-378，tmp//output//.cache/∧gitignore）→.allow-direct 30min（行380-383）→enforce exit 2/warn 注入（行385-399）
- **stats 模式（行538-664）=终验委派率，读 Phase 级 `**Executor:**` 行**（行607-615 正则 `\*\*Executor:\*\*[[:space:]]*(.+)`，括号内=例外理由）：
  - **主进程判据=Executor 值含字面「主进程」**（行428）；理由空→missing_reason 违规；理由无 ①-⑥/白名单[1-6] 编号标识→self_declared_reason 违规（行444-451；L0-E/纯执行标记免编号要求 行424-443）
  - **子代理判据=Executor 值不含「主进程」即计 delegated++**（行479）——无白名单子代理类型串，任意非主进程字符串均算；识别子代理类型：去 `:` 冒号前缀与（）括注（行482-485），复合值按 `+` 拆分（行497），每个 token 须以 `| <token> |` 形态出现在 Handoff 登记表（行506 grep），缺任一→unverified_delegation 违规且 delegated 回退（行518-533）
  - 委派率公式（行633-645）：`delegated/(delegated + main_direct - pure_exec)`；pure_exec（L0-E 权重 0）整批皆纯执行时 rate=1.000 视为达标；verdict=violations 非空→violation（exit 1）
  - **注意：stats 只扫 Phase 级 `**Executor:**` 行，不消费 S-unit 表执行体列**——S-unit 级"继承"标注对委派率统计不可见。

## 6. selftest 锚点布局
目录：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/（selftest-*.sh 全在此，无独立 scripts/selftest/ 目录；注册表 selftest-registry.tsv，运行器 run-selftests.sh 行113 glob 枚举）

| 脚本 | 断言主题 | 一行 |
|---|---|---|
| selftest-plan-dispatch.sh | check-plan-dispatch+attest 集成 | T01-T12：合规/缺表/执行体空/legacy/数值门控（时长16min/输入3路径/空时长 SKIPPED/合规行） |
| selftest-dispatch.sh | check-dispatch+pretooluse Agent 分支 | T01-T12 派发 prompt 必检七项缺失/三档 enforce-warn-off/PLAN_DIR 归一化 |
| selftest-delegation.sh | check-delegation 双模式 | T01-T16 无计划放行/子代理 sid 放行/白名单/trivial/allow-direct/复合 Executor Handoff 交叉校验 |
| selftest-subagent-activation.sh | Rule 96 静态守护（registry 行94） | SA-01..15：96 段标题/96.1 七类锚≥6命中/窄白名单三锚/96.2 中档锚/96.3 并行硬标注/96.4 同消息并发/96.5 指标留痕/SKILL.md 纪元 1-103 级联/模板承载（task_plan 96.3 注释+96.5 指标行、subagent_dispatch 96.4 句）/负断言 |
| selftest-agent-coverage.sh | Rule 52 覆盖矩阵守护（registry 行49） | AC-01..09：矩阵在位/SKILL 六族行/B类零残留/§一实体 test -f/C类41行处置/52 四子条/config properties=42 零新键 |
| selftest-dispatch-grain.sh | Rule 46 单任务专注度（registry 行43） | GR-01..：46.1-46.6 六子条锚/单会话单 S-unit 双锚/check-dispatch 守卫②④收窄 fixture |
| selftest-subagent-granularity-skill-escort.sh | Rule 59（registry 行55） | SG-01..23：59 子条锚/模板粒度三值+伴飞双列/knowledge-brief §6/任务书九字段/check-dispatch enforce 提示串 |
| selftest-subagent-return.sh | 22.4b 返回格式（registry 行75） | A 组：check-subagent-return 四判据+dispatch 段结构+任务书 §7 三反污染条款 |
| selftest-media-dispatch.sh / media-agents.sh | Rule 47/47.2 媒体执行体 | 四子条/双媒体 agent frontmatter/路由面联动 |
| selftest-parallel-scheduling.sh | Rule 68（registry 行66） | P-01..09：68 子条锚/模板前置依赖列/check-plan-dispatch 68 守卫段/SKILL C46 |
| selftest-drift-check-subagent.sh | Rule 61 偏移检查子代理化（registry 行57） | SKILL 六处措辞/61 六子条/drift-checker.md 载体/负断言禁回主上下文 |
| selftest-goal-unit-goal-mode.sh | Rule 66（registry 行64） | 66 条款锚/模板区块/check-plan-dispatch 联动 |
| selftest-verify-io.sh | I/O 契约（registry 行93） | check-delegation stats JSON schema（schemas/check-delegation-stats.schema.json）+verify_io 7 文件在位 |
| selftest-registry.sh | 注册表双向配对 | 每个 selftest-*.sh 须登记 selftest-registry.tsv |

与 dispatch/Executor 直接相关的=selftest-{plan-dispatch,dispatch,delegation,subagent-activation,agent-coverage,dispatch-grain,subagent-granularity-skill-escort,subagent-return,parallel-scheduling}。

## 7. SKILL.md 引用形态
文件：/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（273 行）
| 关键词 | 行号 | 形态 |
|---|---|---|
| 16（卫星行） | 16 | 指针：`卫星 task-dispatch（Rule 12,13,14,21,22,23,25,46,52,59,68,96）` 全规则号枚举 |
| 2.5 委派检查点 | 81 | 内联摘要（3 行浓缩）：Phase Executor≠主进程→九字段模板逐 S-unit 派发；主进程只保留派发/回填/验收；细则→卫星 |
| Executor | 81,103,120,152,249 | 指针+摘要混合；行103「思路 A：按 Executor 字段机械派发」 |
| 直做白名单 | 104 | 内联摘要（1 行）：思路 B 命中直做白名单（trivial/单文件小改）或 Executor=主进程时自执行 |
| 六项白名单全文 | 249 | 纯指针：「六项白名单全文见 task-dispatch Rule 25.3」 |
| 96 | 16,200,250 | 行250 内联摘要（4 行浓缩）：七类触发类别默认派发/主进程直做=窄白名单登记例外/≥2 无依赖 S-unit 必须并行组/同消息并发/两项指标——**未内联七类类别名本身，未内联窄白名单三条** |
| 52 | 16,200,270 | 仅行号枚举与 References 表指针（行270 `agent-coverage.md | 执行体覆盖矩阵（Rule 52.1）`）；SKILL.md 无 52.1 内联摘要 |
| 52.1 | 270 | 指针（文件名括注规则号） |
| 七类 | 250 | 只在 Rule 96 摘要句里出现字面「七类触发类别」，无类别清单 |
| 默认派发 | 250 | 同上，仅 Rule 96 摘要句 |

结论：SKILL.md 对 96/52 均为"指针+4 行浓缩"，对 25.3 白名单为纯指针——执行循环 2.5（行81）触发委派决策时，主进程需跳读卫星 critical-rules-dispatch.md 全文才能完成 96.1 类别判定与窄白名单匹配（跨文件跳转成本=判例中"默认回退主进程直做"的机制性诱因之一）。

## 8. 缺口分析（现有机制 vs「显式标注子代理使用点」诉求）

### 维度 1：计划期标注（模板 Executor 列）
- **G1** S-unit 表执行体列只有「执行体是谁」，无「该目标命中 96.1 哪类（A1-A7）/主进程保留理由」标注列。证据：task_plan.md 模板行339 表头 10 列无类别命中列；critical-rules-dispatch.md 行204"类别判定以 22.6 表「目标」列措辞为准"=判定靠 LLM 读目标列，无机器可见标注面。
- **G2** 96.1 默认档在计划期无落盘区块：task_plan.md 无「触发类别命中表」（模板 grep 96.1/七类 0 命中）；96 在模板的落点只有 96.3 注释（行337）与 96.5 指标行（行505-507，且为交付前回填，非计划期填报）。
- **G3** check-plan-dispatch.sh 不校验 96.1：Executor 列写「主进程」且目标命中 A1-A7 时零拦截（脚本行232-234 仅按「主进程」关键字分类，无类别维度）；96.1 自述"判定面=LLM 行为、零新机器门"（行188）——计划期默认派发靠自觉，判例 session_83f64e 的"本应委派的工作主进程硬扛"在此面合法通过 attest。

### 维度 2：执行期标注（SKILL/规则内联）
- **G4** SKILL.md 执行循环 2.5（行81）委派检查点未内联 96.1 七类清单与窄白名单三条，全部指针化（行250 摘要不含类别名）——执行期做"派/不派"决策必须跨文件读 critical-rules-dispatch.md 行192-204，上下文成本诱发跳过判定直接主进程直做。
- **G5** 52.1 选型查矩阵同样纯指针（SKILL.md 行270/246 仅文件名）；agent-coverage.md 行3 只写维护责任，无"派发检查点必读"时机钩子（52.4 行143"消费侧=委派检查点选型对照"无机器锚——selftest-agent-coverage 只断言矩阵在位，不断言 SKILL 2.5 步骤含查矩阵动作）。
- **G6** 无逐 S-unit 派发时的"标注回写"要求：96.4 同消息并发（行212）与 Handoff 登记（22.5 行63）均无"本 S-unit 命中 A? / 为何并发"字段；96.5 三行指标只在 task_plan 委派统计区块交付前回填（模板行505-507），执行中无逐 S-unit 激活留痕面。

### 维度 3：默认值语义（建议 vs 硬禁）
- **G7** 96.1"默认派发"是行为条款+主进程直做需登记例外，但例外登记无机器校验：check-delegation stats（行444-451）只校验主进程理由含 ①-⑥ 编号标识，不校验理由是否命中 96.1 窄白名单三条（写"② 计划系统文件维护"即可绕过窄白名单——25.3②覆盖面宽正是 96 建制段自认的缺口，critical-rules 行190①"25.3 白名单②…覆盖面宽"）。
- **G8** 默认值方向缺硬门：96.3 只对"应声明并行组而未声明"设 hard（H3 行619-624 校验的是组标记存在性，且仅 standard/full 档执行，行465）；"主进程直做未登记"在 enforce 档下依赖 check-delegation pretool 拦截 Write/Edit（行385-399）——**只拦写动作，不拦读/分析/规划类工作**（Rule 13 行11 的"调研/搜索/大文件读取必须派子代理"无 pretool 拦截，Agent 工具使用量无任何计数门——96 行188"零新机器门"明言）。
- **G9** 无"默认值建议"的软层：现有机制只有"违规硬拦"（enforce exit 2）与"提示"（SKIPPED/WARN 行264/645）两极，缺"默认应派子代理（建议档，登记即合法放行）"的中间语义——判例会话"子代理使用频率过低"即建议不生效的实证。

### 维度 4：弹性微调出口
- **G10** 主进程例外出口只有两条且都不成体系：allow-direct.sh 30 分钟窗口（check-delegation 行188-220，须 --confirm-user-requested）+「例外登记」三值列 token（check-plan-dispatch 行283-286，仅粒度三值超限场景）。96.1 窄白名单③"派发开销显著大于收益"无逐 S-unit 登记格式（理由句自由文本，stats 侧只认 ①-⑥ 编号，行447）——"微调出口"与"违规判定"共用 ①-⑥ 编号但语义口径不同（25.3 六项 vs 96.1 三条窄白名单），出口判定无机器一致性。
- **G11** 执行期降档/撤派无登记面：22.3 兜底链（改派→拆细→降档→接管）登记在 Handoff 表 rescue 列（行63），但"原派发被撤销改回主进程"（比接管更极端的例外）只有 25.3"执行期新增例外→先回填计划再继续"（行105）一句，无 task_plan/progress 固定登记格（无「例外变更记录」区块）。
- **G12** 指标无回控：96.5 两指标（激活数/并行宽度）交付前回填（行214/模板行505-507）后无消费方——check-complete.sh 终验不校验 96.5 三行非空（grep "96.5" check-complete.sh 0 命中；selftest-subagent-activation SA-13 只断言模板行在位，不断言终验消费），指标形同虚填，"弹性微调"无反馈闭环。

### 缺口×载体矩阵（落地建议锚点）
| 缺口 | 建议载体 | 既有锚 |
|---|---|---|
| G1/G2 计划期类别命中列 | task_plan.md S-unit 表加「96 类别」列（96.1 A1-A7 或 `-`=主进程保留） | 模板行339 表头 / check-plan-dispatch H1-H4 段（行564-616）同管线 |
| G3 默认档软门 | check-plan-dispatch 加 advisory 档：目标列命中 A1-A7 且执行体=主进程/继承自主进程→WARN 不拒锁（opt-in，对齐 68.2 advisory 先例行465） | 脚本行232-234 分类点 |
| G4 执行期内联 | SKILL.md 行81 步骤 2.5 内联七类 1 行速查表+窄白名单三条（指针保留全文） | selftest-subagent-activation SA-03/SA-04 锚扩员 |
| G5 查矩阵钩子 | 2.5 委派检查点加"选型先查 agent-coverage.md"动作锚 | selftest-agent-coverage 加 SKILL 锚断言 |
| G7/G10 例外登记一致化 | 96.1 窄白名单③给出编号 token（如 `96③`），check-delegation stats 白名单编号判定扩认 | 脚本行447 正则 |
| G8 读/分析类拦截面 | 不新增 pretool 拦截（宪法零新键），改 96.5 指标终验消费（G12）形成回控 | check-complete 终验段 |
| G12 指标回控 | check-complete 终验校验委派统计 96.5 三行非空+激活数≥Phase 数下限（advisory 起） | 模板行505-507 |
