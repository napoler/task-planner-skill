# 01-explore-enumerate-first — Rule 105（可枚举集合全量枚举优先纪律 ls-first）Phase 1 调研

执行体=Explore 只读；worktree=/mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106（wt/task-enumerate-first-20261106，基于 master a948308）。
下简称 skills/ 路径均相对该 worktree 根。

## 节 A：既有检索相关条款覆盖面（防 Rule 82 镜像副本判定）

关键词族 grep 面（`全量枚举|ls 命令|关键词检索|搜索面|命名族|盲搜|存在性|零命中|没搜到|不存在` @ skills/*/references/critical-rules-*.md + skills/*/SKILL.md）：

| 文件:行号 | 条款 | 内容摘要 | 与 Rule 105 关系 |
|---|---|---|---|
| skills/task-discipline/references/critical-rules-discipline.md:109-115（35.1/35.2/35.4/35.6） | Rule 35 执行结论纪律：能力否定查证 | 35.1 触发=以「不存在/无法」类否定收场前强制生效；35.2 三关②CRUD 命名变体逐一尝试、③替代路径「list 全量+本地过滤」；35.4 失败上报必须区分「任务失败」与「能力不存在」，禁止把「我没找到」写成「不存在」 | **部分覆盖（最近邻）**：覆盖「零命中≠不存在，须扩大查证面后复核」的否定结论面，但对象是 API/CLI/接口能力声称，未管「本地小候选集合的检索方式选择（ls 全量 vs 关键词盲搜）」。105 须引 35 不重述其判定面 |
| skills/plan-research-router/references/critical-rules-research.md:32（63.2） | Rule 63 检索优先 | 知识缺口第一反应=主动检索，链序 ①本地（代码库 Grep/Read、memory）→②--help→③官方文档/网络→④社区 | **不覆盖 105 核心面**：63.2 本地步把「Grep/Read」列为手段且默认先查局部知识缺口，未禁止关键词盲搜、未要求可枚举集合先 ls 全量枚举；触发面=知识缺口（事实/报错/用法），非本地素材集合选型 |
| skills/plan-research-router/references/critical-rules-research.md:42-82（75.1/75.2/75.3/75.10/75.15） | Rule 75 网络调研主动激活 | 75.1 调研三态 LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT；75.15①「本地盘点」为调研阶段三步之首；75.10 网络通道降级链 | **不覆盖 105 核心面**：75 族对象=外部/网络数据获取（GitHub/浏览器/文档），75.15① 本地盘点只是盘点「已有材料」，未规定盘点动作本身必须全量枚举、禁盲搜；「零命中回退全量复核」义务在 75.10 网络侧有对应（单通道失败≠不可用），本地侧无对应条款 |
| skills/plan-research-router/references/critical-rules-research.md:8-24（58.1/58.3） | Rule 58 调研证据面 | 调研/归因类任务证据面清单（自身/对标/外部约束三基线）+结论-证据锚定反证 | **不覆盖**：58 管结论的证据维度完备性（证据面清单），不管取证动作的检索方式；「自身样本第一手取证」不预设 ls 全量枚举 |
| skills/task-discipline/references/critical-rules-discipline.md:681（100.6） | Rule 100.6 垃圾桶机制 | 「后期正常检索/回找数据（Explore/grep/glob/ls 扫描/素材选型）必须排除 trash/」 | **正交**：检索卫生面（排除 trash/），105 落地可引 100.6 作为「枚举面=ls 扫描时排除 trash/」的交叉锚 |
| skills/task-discipline/references/critical-rules-discipline.md:298（60.1 族） | Rule 60 主动解决问题 | 遇障碍主动枚举**替代方案**并按质量损失排序 | **不覆盖**：枚举对象=障碍的替代方案（行动层），非候选素材/文件集合（对象层） |
| skills/task-discipline/references/critical-rules-discipline.md:168（43.3） | Rule 43.3 方案预验证 | 提推荐前枚举 ≥2 候选方案过最轻验证 | **不覆盖**：候选=方案（须 ≥2 可判），非「已知全集枚举后从中选择」 |
| skills/plan-research-router/references/critical-rules-research.md:67（75.8） | Rule 75.8 方向粒度 | 调研方向枚举=计划期表逐行登记 | **不覆盖**：方向=网络调研方向拆分，非本地集合 |
| skills/task-planner/SKILL.md:241（Scope Guard 口径更正） | —（注释性） | 「grep 零命中」判 check-scope.sh 无拦截逻辑 | **不覆盖**：「零命中」仅出现为调研方法注记（同上；task-discipline:370 同形态），无任何条款把「零命中≠不存在→全量复核」立为本地检索义务 |

**空白区判定：Rule 105 为空白区（确认无镜像副本风险）。**
- 「可枚举本地集合→禁关键词盲搜、先 ls 全量枚举后选择」：全仓 critical-rules*/SKILL.md 零条款（`全量枚举|盲搜|搜索面|命名族|ls 命令|关键词检索` 全零命中，「全量」命中均为回归测试/收尾回读等无关义项）。
- 「零命中≠不存在须回退全量复核」：仅 Rule 35（能力否定面，discipline:109-115）与 75.10（网络降级链）有同形先例，本地小集合面无人管辖。
- Rule 75/63/58 均管「知识缺口→外部渠道」；本地可枚举集合的检索方式选择是它们未覆盖的第三区。105 条款写法建议：引 Rule 35（否定结论口径）/63.2①（本地步）/75.15①（本地盘点）不重述，只立「枚举优先+零命中回退」两条本体。

## 节 B：级联锚面清单（104→105 计数演进）

### B1 纪元字面锚 `1-104`（*.md + *.sh 全仓 grep）
命中 1 文件 3 处，全部在 skills/task-planner/SKILL.md（scripts/*.sh 零命中）：
| 文件:行号 | 现值 | 需改成（方向） |
|---|---|---|
| skills/task-planner/SKILL.md:9 | frontmatter references 行「Rules 1-104 全集索引（…其余 87 条按域归 11 卫星…）」 | `1-104`→`1-105`；`其余 87 条`→`88 条`（14 核心不变；非核心 90-3 预留废弃号(77/78/79)=88） |
| skills/task-planner/SKILL.md:222 | 正文「Rules 1-104 全集索引：核心在位 14 条…其余 87 条已按域迁至上表 11 卫星（…Rule 104 子代理使用点显式标注域（dispatch 卫星））」 | `1-104`→`1-105`；`87 条`→`88 条`；括注追加「Rule 105 <条款名>（<task-discipline/plan-research-router> 卫星）」 |
| skills/task-planner/SKILL.md:265 | References 表「Critical Rules 核心域 1-104 全集索引（14 条核心全文+…）」 | `1-104`→`1-105` |

### B2 宽锚容差形态（`1-10[0-9]` 型顶锚窗口）
- 29 个 selftest-*.sh 已含 `10[0-9]` 分支（task-crossprojauth R5/R8 预放宽 10x/11x 窗），主锚形态=`1-(8[0-9]|9[0-9]|10[0-9]|11[0-9])([^0-9]|$)`：
  代表性锚点（逐文件 10[0-9] 命中计数）：selftest-anti-deferral.sh:1（AD-09 @86）、selftest-subagent-activation.sh:1（SA-11 @65）、selftest-execution-honesty.sh:2、selftest-research-first.sh:3（RF-07 @86-87）、selftest-root-resolution.sh:4（@126-127/198-204）、selftest-verification-gate.sh:2、selftest-requirement-grading.sh:2，其余 23 脚本各 2-14（全清单见 worktree grep `10\[0-9\]` 输出：decision-drift/absorption-discipline/conclusion-discipline/drift-check-subagent/capability-persistence/context-pressure/error-loop/reflect-verify/lane-advancement/iteration-persistence/plan-tier/requirement-coverage/reliability-institution/self-resolution/session-log/skill-split/source-anchor-discipline/summary-readability/veto/tool-selection/parallel-scheduling）。
- **判定：1-105 落在既有 11x 窗内 → 全部 selftest 脚本零改动**（先例=AD-09 链注「纪元 1-102→1-103 随动，顶锚 11x 窗已覆盖零级联」）。
- 计数正则 `其余 [89][0-9] 条`（anti-deferral.sh:89 / subagent-activation.sh:68）：88 在 [89] 窗内 → **零改动**；仅需在对应链注补一行「87→88：Rule 105 并入 <域>」史注（可选，随 L0-T 口径）。

### B3 SKILL.md 全集索引行 + 卫星路由表计数表述（精确行号）
| 文件:行号 | 现值 | 需改成 |
|---|---|---|
| skills/task-planner/SKILL.md:9 | 见 B1 | 见 B1 |
| skills/task-planner/SKILL.md:222 | 见 B1 | 见 B1 |
| skills/task-planner/SKILL.md:265 | 见 B1 | 见 B1 |
| skills/task-planner/SKILL.md:17 | frontmatter 卫星行「task-discipline: …（`../task-discipline/`，Rule 4,6,…,97,98）」（枚举止于 98，未含 99-102，既有不对称） | 若 105→discipline 域：行尾枚举追加 `105` |
| skills/task-planner/SKILL.md:209 | 卫星路由表 task-discipline 行「…（Rule 4,6,…,97,98,99,100,101）」 | 追加 `,105` |
| skills/task-planner/SKILL.md:211 | 路由表 plan-research-router 行「（Rule 58,63,75）」 | 若 105→research 域：改「Rule 58,63,75,105」 |
| skills/task-planner/SKILL.md:255 | 「派发与执行纪律指针」段「执行纪律/…/git 使用加强（Rule 101）→ 卫星 task-discipline」 | 追加「/可枚举集合全量枚举优先（Rule 105）」 |
| skills/task-planner/scripts/selftest-batch-pilot.sh:11/63/64/66 | BP-08 行数钉：断言 `[ "$lines" -le 285 ]`（@66），实值 281 行（margin 4） | 105 级联进 SKILL.md 净增 ≤4 行即破钉——若 105 级联（B1×3 行同址改写=净 0 行 + B3 路由行追加同址改写=净 0 行）则实值不变，**BP-08 零改动**；仅当在 SKILL 正文净增行（如 255 段加长不算净增行）超限才需 285→实值+25 |
| 卫星侧文件 | skills/task-discipline/references/critical-rules-discipline.md（现 705 行，止于 Rule 102 @694-705）或 skills/plan-research-router/references/critical-rules-research.md（现 82 行，止于 75.15） | 新增 `### 105` 条款本体（域判定见节 C）+ 文件头规则编号行（research 文件头 L4「规则编号：58, 63, 75」需补 105；discipline 文件头迁移注记无需动，但 skills/task-discipline/SKILL.md 规则索引表需加 105 行） |
| 对应 selftest 纪元断言 | selftest-anti-deferral.sh:13-14（AD-09/AD-10 链注）、selftest-subagent-activation.sh:14-15（SA-11/SA-12 链注） | 仅链注补史（零断言面改动，11x 窗已覆盖）；**默认 L0-T 零新增 selftest/registry 行**（机器可判但用户未显式要求时不建，对齐 98/99/100/101/102 先例范式） |

### B4 selftest-registry.tsv 现状
- 路径=skills/task-planner/scripts/selftest-registry.tsv；**tab 分隔，4 列**：`script / domain / trigger_scenarios / dep_anchors`（header @L1；dep_anchors 列内部=分号 `;` 分隔路径清单）；共 96 数据行。
- 尾 10 行（L88-97）：selftest-step-placeholders.sh(P-03) / selftest-goal-cjk.sh(P-06) / selftest-gate-degraded.sh(P-07) / selftest-rvc-coverage.sh(P-08) / selftest-tier-consistency.sh(P-09) / selftest-gate-injection.sh / selftest-verify-io.sh / selftest-subagent-activation.sh(R-01) / selftest-anti-deferral.sh(Rule 97) / selftest-dual-qc.sh(DQ, Rule 103) / **末行 L97=selftest-file-disposal.sh**（Rule 100.6 垃圾桶 FD-01..06；dep_anchors=critical-rules-discipline.md;critical-rules-media.md;templates/variant/image-type.md;templates/variant/video-type.md;templates/deprecated.md;.gitignore;scripts/selftest-file-disposal.sh）。
- registry 内 `1-104`/编号上限类断言：**零命中**（tsv 无纪元列；仅 anti-deferral 行 domain 列含史注「1-97 纪元」过期文，无机器断言消费）。selftest-*.sh 中纪元上限断言全部为 B2 型宽窗正则（11x 预放宽），`1-104` 字面在 scripts/ 零命中。
- Rule 105 默认不落 registry（L0-T 零新增）；若建新 selftest（用户显式要求时）→ tsv 追加 1 行 4 列（script=selftest-enumerate-first.sh，dep_anchors 含归属卫星规则文件+SKILL.md+tsv 自身）。

### B5 SKILL 钉值 BP-08
- 定义/断言=skills/task-planner/scripts/selftest-batch-pilot.sh:66 `if [ "$lines" -le 285 ]`（实值 281，margin 4）；演进链注 @11/63/64（558→275（v171 瘦身）→285（2026-11-05 Rule 104 就地速查表+7 行，实值 280））。
- 105 级联若全为同址改写（B1/B3 行内替换）→ SKILL.md 行数不变 → BP-08 零改动；若净增行 >4 行 → 需「285→实值+25」升钉并随动 :11 链注。

### 级联修改清单汇总（104→105）
1. SKILL.md:9（1-104→1-105；87 条→88 条）
2. SKILL.md:222（1-104→1-105；87 条→88 条；括注追加 Rule 105 域归属句）
3. SKILL.md:265（1-104→1-105）
4. SKILL.md:17 或 211（依域判定二选一，路由表枚举追加 105；:209 同追）
5. SKILL.md:255（指针段追加 105，同址加长）
6. 归属卫星 critical-rules-*.md 新增 `### 105` 本体 + 域头编号行/规则索引表同步（discipline→SKILL.md 规则索引表+1 行；research→文件头「规则编号：58,63,75,105」+plan-research-router/SKILL.md 卫星路由行「域=…（Rule 58,63,75）」需补 105）
7. scripts/：零改动（11x 窗预放宽覆盖 1-105；「其余 [89][0-9] 条」覆盖 88）——仅在 anti-deferral/subagent-activation 链注补史（可选）
8. selftest-registry.tsv：默认零改动
9. BP-08：净增 ≤4 行内零改动

## 节 C：归属卫星确认（task-discipline vs plan-research-router）

**两文件域边界描述（原文锚）：**
- skills/task-discipline/SKILL.md:12-16（「定位/域边界」）：「管『执行过程的纪律与工作产物』——除四文件数据流转（核心，Rule 62）与子代理拆分/派发/调度（task-dispatch）之外的**所有执行期纪律**（全量兜底口径）」；critical-rules-discipline.md:1-3 域=「执行过程纪律与工作产物维护」，现辖 52 条（含 35/41/54/60/97/98/99/100/101/102）。
- skills/plan-research-router/SKILL.md:2-4 + 12（frontmatter description）：「网络调研与 github 调研路由 SOP…不用于**纯本地**单文件问答或已知 URL 的简单读取」；critical-rules-research.md:1-4「规则编号：58, 63, 75」域=「调研分析与证据纪律」——三条全部以**知识缺口/外部数据/网络通道**为触发面（63=知识缺口检索义务；75=网络调研激活+外部工具；58=调研证据面）。

**Rule 105 语义匹配判定：→ task-discipline（执行纪律域）。** 依据：
1. 触发面=执行期本地候选集合（素材/文件/名称仅几十项）的检索动作选择——属「执行期纪律」，命中 discipline 域「所有执行期纪律」兜底边界；research 域 SKILL.md:4 明文排除「纯本地」场景。
2. 105 最近邻=Rule 35（capability 否定三关，discipline:109-115，「我没找到」≠「不存在」）与 Rule 60（替代方案枚举）——零命中回退全量复核与 35 同源同域，放 research 会制造 82 分层跨域引用；research 侧 63/75 只保留「本地步 63.2①→可枚举时先 ls」的交叉指认句即可（引 105 不重述）。
3. 编号形态连续性：discipline 域 98/99/100/101/102 连续五号均为用户执行卫生类指令纪律（上下文整理/跨项目授权/tmp/git/新请求同步），105 为同类执行动作纪律；103/104 归 dispatch（子代理标注面），research 域止于 75（2026-11-05 前）且三条皆为网络面。
4. 反证（research 侧唯一论据）：「禁关键词盲搜」措辞靠近 63.2 检索链 → 但 63.2 管「知识缺口是否检索」（义务面），105 管「检索动作怎么执行」（方式面），方式面=执行纪律；且 research 域新增 105 会把「纯本地检索」拉进网络调研 SOP 卫星，违背其 SKILL.md:4 自述边界。
**结论：Rule 105 落 task-discipline/references/critical-rules-discipline.md 尾部（Rule 102 之后），research 侧 63.2① 加一句交叉指认（可选，L0-T）。**

## 自审段
- 节 A：关键词族 10 词全跑；命中 8 条款逐一判定（35/63/75/58/100.6/60/43.3/75.8）；空白区判定有 grep 零命中证据支撑（全量枚举/盲搜/搜索面/命名族 全零）。遗留缺口：未逐字核对 75.15① 与 105 判据重叠边界（已标「盘点动作」vs「检索方式」差异，写法时以 105 本体定义覆盖 75.15① 本地盘点步即可，无镜像风险）；「不存在」义项多（账本/路径/实体存在性），已按义项甄别，未见管「本地小集合检索方式」者。
- 节 B：B1 `1-104` 全仓 grep=1 文件 3 处（仅 SKILL.md，scripts 零）；B2 宽窗 29 脚本命中（10[0-9] 分支全在，11x 预放宽覆盖 1-105 零脚本改动）；B3 索引行 3 处（9/222/265）+路由表 17/209/211/255 行号均 Read 核实；B4 registry=tab/4 列/96 数据行/末行 selftest-file-disposal.sh 已核；B5 BP-08 @selftest-batch-pilot.sh:66（≤285，实值 281）已核。遗留缺口：「其余 87 条」→88 的推算基于 77/78/79 预留废弃（ARCHITECTURE.md:4 注释「全集 14+80=94（77/78/79 已废弃不计）」+后续追加），落地时按 105 后 14 核心+88 非核心=104 有效号+3 废弃号 复核一遍。
- 节 C：两卫星 SKILL.md 域边界段 + 两 references 文件头均 Read 原文；判定 4 条依据带行号。遗留缺口：task-discipline/SKILL.md 规则索引表（L30 起）105 行格式未逐列核（落地时照 102 行格式抄写即可）。
