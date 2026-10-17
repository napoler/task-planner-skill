# S0 explore 检查点 | task-v187 三诉求规则修订前置侦察（只读）

> WORKTREE=/home/terry/task-planner-skill-worktrees/task-v187-workflow-activation-parallel
> 需求锚 R1 主动创建工作流 / R2 按难度分档模型 / R3 不冲突尽量并行。本单元=断言面+形态面前置侦察。
> 全部行号在 $WORKTREE/skills/ 下 grep 可复现（工作目录已 cd 至 $WORKTREE/skills/）。

## 交付 1 — selftest 断言锚清单（脚本:行号 | 断言要点 | 旧措辞关键词）

CRIT 变量指向（各脚本头部）：
- workflow-orchestration.sh / tool-selection.sh → `plan-collab-router/references/critical-rules-collab.md`
- parallel-scheduling.sh → `task-dispatch/references/critical-rules-dispatch.md`
- SKILLMD（前两者）→ `task-planner/SKILL.md`

### selftest-workflow-orchestration.sh（Rule 39/91 域）
| 行号 | 断言要点 | 旧措辞关键词 |
|------|---------|-------------|
| :48-50 WF-02 | `^39\.1 \*\*触发纪律` 头锚 | 触发纪律 |
| :52 WF-03 | `^39\.3 \*\*四机制映射` | 四机制映射 |
| :54 WF-04 | `^39\.4 \*\*并行豁免` | 并行豁免 |
| :56 WF-05 | `^39\.5 \*\*机器校验边界` | 机器校验边界 |
| :58 WF-06 | `^39\.6 \*\*机制` +「零新 config 键」 | 零新 config 键 |
| :59-60 WF-07 | SKILLMD `^\| plan-collab-router \|` + `Rule [0-9,-]*39`（卫星路由表 collab 行枚举 39） | Rule 39,40,91 |
| :63-64 WF-09 | SKILLMD `dynamic-workflows 仅用户显式点名`（协同路由行） | **仅用户显式点名（R1 关键锚）** |
| :79-82 WF-10 | `Critical Rules 1-(68\|69\|71\|75\|91)` 变体族≥3 + 旧 `Rules 1-39/1-45`=0 | 1-(...91) |
| :99-106 WF-13 | `^39\.7 \*\*动态激活边界与禁自建副本` + 39.7.1/39.7.2/39.7.3 三子条 | 动态激活边界 |
| :135-136 WF-17 | `^### 91 ` +「模型分档」（**Rule 91 头锚**） | 模型分档 |
| :138 WF-18 | `heavy（重）/medium（中）/light（轻）/minimal（最轻）` 四档映射表锚 | 四档 |
| :140 WF-19 | 「官方文档矛盾披露」+ `there is no per-subagent tool profile or model choice` | 91.2 矛盾披露 |
| :142 WF-20 | 「编译期约束」+ `EvalWorkflowSnippet` | 91.5/91.6 |
| :144 WF-21 | `Rule 39`+`Rule 68.3`+`Rule 43.2`（91.9 衔接） | 68.3 |
| :146 WF-22 | SKILLMD `^\| plan-collab-router \|` + `Rule [0-9,-]*91`（路由表枚举 91） | Rule 91 |

### selftest-parallel-scheduling.sh（Rule 68/21.4 域）
| 行号 | 断言要点 | 旧措辞关键词 |
|------|---------|-------------|
| :73 P-01 | `^68\.[1-7] ` 七子条=7（**68.1-68.7 全在位**） | 68.x |
| :80-84 P-02 | 依赖分析/并行分组/异构分摊/组域写隔离 各≥1 | 并行分组 |
| :99-105 P-04 | check-plan-dispatch.sh `Rule 68` + hard串(依赖-同组) + advisory串 各≥1 | 依赖-同组 |
| :116-126 P-05 | SKILLMD `^\| task-dispatch \|`=1 + `Rule [0-9,]*68`≥1 + 全集 1-${skill_max}≥84 | Rule 68 |
| :134 P-06 | selftest-registry.tsv 含本脚本登记行≥1 | 登记 |
| :141 P-07 | config.json `parallel[a-z_-]*\|model[ _-]allocat`=0（零新 config 键负断言） | 零新键 |
| :147-148 P-08 | `未声明者默认串行` 原文锚≥1（**21.4 组间串行语义不回退，R3 关键锚**） | **未声明者默认串行** |
| :155-159 P-09 | split-pattern-library.md `P12` +「依赖分批并行」双锚 | 依赖分批并行 |

### selftest-tool-selection.sh（Rule 40/39 域）
| 行号 | 断言要点 | 旧措辞关键词 |
|------|---------|-------------|
| :45 TS-01 | `^40\.` 六子条=6（Rule 40.1-40.6） | 40.x |
| :49 TS-02 | 40.3「不可代调」≥1 | 不可代调 |
| :51 TS-03 | `^40\.4` 行含「显式点名」+ `^40\.6` 行含「零新 config 键」 | **显式点名（40.4 行内）** |
| :61-63 TS-04 | SKILLMD `^\| plan-collab-router \|`+`Rule [0-9,-]*40` + CRIT `^### 40 `=1 | Rule 40 |
| :79-80 TS-05 | `1-[89][0-9]`≥1 且 `1-39`=0（索引字面负断言） | 1-39=0 |
| :89-94 TS-06 | `dynamic-workflows 仅用户显式点名` + `（Rule 39）` + 卫星路由表 collab 行 | **仅用户显式点名（R1 关键锚）** |
| :106 TS-09 | templates/variant/mini-lite-type.md「Rule 40.2 豁免声明」=1 | 40.2 豁免 |

### 步骤 1 关键负发现
- 「建议 CreateWorkflow」/「建议登记」 三个 selftest 脚本内**均无字面断言**（grep `建议` 零命中）。40.4 唯一断言 = TS-03 锚定 `^40\.4` 行的「显式点名」四字。⇒ 修订 40.4「建议登记 ≠ 自动触发」措辞不直接触发 selftest 失败；但若从 40.4 行删除「显式点名」，TS-03 将 FAIL（须保留该四字或同步改 TS-03 锚）。
- R1「仅用户显式点名」短语 = WF-09(:63) 与 TS-06(:89) 两处 selftest 硬断言 + task-planner/SKILL.md:207 单点承载；改写 SKILL.md:207 该短语即破两条断言。

## 交付 2 — 四形态族全仓扫描（A/B 分类）

探针六词：仅用户显式点名 / 不得自主判断 / 显式点名才路由 / 建议登记 / 未声明者默认串行（含「未声明默认串行」=0 命中）/ 仅当用户显式调用。补充级联词：串行槽 / CreateWorkflow / dynamic-workflows / 显式点名。

### A 类（= 修订目标，将改写）
| 文件:行号 | 原句片段 |
|-----------|---------|
| plan-collab-router/references/critical-rules-collab.md:5 | 39.1「**agent 不得自主判断启动 workflow**（官方 L46-55 explicit request is binding）…未点名→一律按既有 Rule 21.4 调度铁律…未声明组=串行槽」 |
| critical-rules-collab.md:5 | 39.1「显式点名才路由」「仅当用户显式调用 /workflow 或明确措辞要求 workflow 编排」 |
| critical-rules-collab.md:27 | 「40.4 只增计划期**建议登记**面，不改 39.1「显式点名才路由」的触发纪律原文」 |
| critical-rules-collab.md:32 | 40.4「登记「建议 CreateWorkflow」…Rule 39.1「显式点名才路由」原文不变：建议登记 ≠ 自动触发，触发判定权仍在用户」 |
| critical-rules-collab.md:70 | 91「39 管编排触发与机制（显式点名才路由/加载门槛/四机制映射），91 管脚本内每 subagent 用什么档位」 |
| task-planner/SKILL.md:207 | 「dynamic-workflows 仅用户显式点名 /workflow 时路由（Rule 39）」 |
| plan-collab-router/SKILL.md:3 | 「不用于 /workflow 动态编排（走 Rule 39 dynamic-workflows）」 |
| task-dispatch/references/critical-rules-dispatch.md:27 | 21.4「**未声明者默认串行**——守卫对无组标记派发按串行槽拦截」 |
| critical-rules-dispatch.md:162-174 | 68.1-68.7（并行分组/串行槽/21.4 组间串行语义不变不回退/零新 config 键） |
| task-planner/scripts/selftest-{workflow-orchestration,parallel-scheduling,tool-selection}.sh | 交付 1 全部断言行（R1 措辞改后须同步 TS-06/WF-09「仅用户显式点名」+ TS-03「显式点名」+ P-08「未声明者默认串行」锚） |

### B 类（其他文件引用面 = 需评估级联）
| 文件:行号 | 原句片段 | 级联风险 |
|-----------|---------|---------|
| task-planner/templates/task_plan.md:262 | 「workflow 编排判定（Rule 40.4）: …命中→登记『建议 CreateWorkflow』…未命中→按 Rule 21.4 独立性守门调度（未声明=串行）」 | **高**：40.4 措辞改→模板判定行须同改 |
| plan-template-kit/references/template-guide.md:254 | 「workflow 编排判定行（Rule 40.4）: …命中写『建议 CreateWorkflow』…未命中写『按 Rule 21.4…未声明=串行』」 | 高：40.4 镜像 |
| plan-template-kit/references/template-mapping.md:312,321 | 「≥3 独立同构单元…→建议 CreateWorkflow」「编排判定倾向=命中才登记『建议 CreateWorkflow』…未命中按 Rule 21.4 守门」 | 高：CreateWorkflow 建议面 |
| task-planner/companion/agents/plan-writer.md:45 | 「workflow 编排判定（40.4: 命中→建议 CreateWorkflow+39.4 豁免登记）」 | 中：agent 指令 |
| task-planner/templates/subagent_dispatch.md:34 | 21.4「未声明组=串行槽」 | 中：串行槽措辞 |
| task-planner/references/critical-rules.md:173,176 | 83.x「CreateWorkflow 无 Skill 工具 3 次重试全拦」「/workflow 请求先探测 dynamic-workflows 是否可用」 | 低：Rule 83 快速失败=独立条款，仅共用 CreateWorkflow 名 |
| task-planner/companion/agents/complex-planner.md:16 | 「用户显式点名要求大模型深度规划」 | 低：非 workflow 语境（模型规划点名），勿误改 |
| task-planner/SKILL.md:156,170 | Rule 83 /workflow 快速失败 + 路由表 collab 行「Rule 39,40,91」 | 中：路由表枚举须与 39/40/91 一致（WF-07/WF-22 断言） |
| plan-collab-router/SKILL.md:42,44 | 卫星路由域标题「Rule 39,40,91」+ 调用条件 | 中：×2 SKILL 消费面 |
| task-planner/README.md:73 / docs/ARCHITECTURE.md:105 | 路由表「comet/OpenSpec/superpowers/dynamic-workflows 路由（Rule 39,40）」 | 低：文档表 |
| task-dispatch/references/split-pattern-library.md:116 | 「Rule 68.1-68.7 + 68.5 parallel playbook（dynamic-workflows patterns.md:45-54、SK.md:321-345 同源）+ 21.4 组间串行默认」 | 中：P-09 双锚承载面 |

## 交付 3 — workflow-model-tiers CCR 四档摘要（≤10 行）

读 ~/.zcode/skills/workflow-model-tiers/SKILL.md（120 行；CCR provider 前缀 `9e221f47-3040-4ea7-b742-20b813fb79aa`）：
1. 四档：heavy=opus-1（规划员/架构分析/综合写作/深度分析/最终报告）｜medium=sonnet-1（开发/调试/评审/测试修复/内容撰写）｜light=fast（查找/数据提取/格式化/简单汇总/模板填充）｜minimal=haiku-1（分诊路由/二元判断/关键词提取/格式校验）。
2. model() 写法：参数=编译期 string literal，禁变量拼接（`model(PREFIX+"/opus-1")` 编译失败），每条写死完整 id；`subagent_model`=run 级单一字段兜底，脚本内 `agent(name,{model})` 逐子代理覆盖（官方 run 级字段无 per-task 覆盖）。
3. 用法 A=固定映射（拓扑已知，≤5 子代理）；用法 B=MODELS 表+分诊路由（分诊器恒 minimal，fan-out 内 1:1 链式执行，分诊器只选已批准档位不写模型名）。
4. 反模式：全流统一强档（不设档也不设 subagent_model）/分诊格式化上 opus/变量拼接/运行中 try/catch 降档/换机直接复用 UUID。
5. 衔接 Rule 91：91.1 四档映射表=本表；91.2 披露官方矛盾「there is no per-subagent tool profile or model choice」（官方 SKILL.md:112，本技能 §119 同披露）；91.5 验证前置门=EvalWorkflowSnippet；91.6 编译期约束=model() literal；91.9 衔接 Rule 39/68.3/43.2。

## 完成状态
- 步骤 1/2/3 全部完成：交付 1 锚清单全带可 grep 复现行号，交付 2 A/B 分类落点齐全（六探针词命中全落 A 类；补充级联词揭示 B 类 11 处引用面），交付 3 四档摘要 5 行 ≤10 行。
- 零文件修改（唯一写入=本检查点 0-explore.md）；未触碰其他 worktree。
- status: done
