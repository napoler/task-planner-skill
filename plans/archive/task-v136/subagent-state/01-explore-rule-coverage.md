# 规则覆盖探索检查点 — F1/F2/F3 缺陷面条款证据提取

**执行日期**: 2026-10-05
**执行者**: ZCode Explore (只读研究代理)
**任务**: 为 skill 规则修订提取第一手条款证据（file:line 锚点 + 原句摘录）

---

## 1. references/critical-rules.md 关键条款全文/摘录

### Rule 43.5（行 457）— 提示词/参数优化必须实际生成测试

> 43.5 **提示词/参数优化必须实际生成测试（post-modification generation test）**：一切生成参数类修改——图像/视频生成提示词、生成参数（seed/模型/尺寸/步数等）、技能调用参数——的修改完成后，必须实际执行 ≥1 次真实生成动作并对产物做质检取证（取证三件套=生成成功回执 + 产物实际查看/Read（图像走 image-understand 取证）+ 命中 Rule 50 分级需求时按 50.3 逐条评级），方可声称该修改完成；未执行实测 = 零验证证据，该修改只能以「未测试」显式登记（43.1 同口径），禁止声称完成、禁止按完成交付。判例锚（task-v133，用户 2026-10-05 原话 R2/R3/R5，全文见 plans/task-v133/task_plan.md「🎯 用户需求原文」）：图像生成提示词修改后未做任何测试，未经实战的提示词优化=完全脑补、可信度≈0。

### Rule 43.6（行 458）— 未验证结果禁止作为优点宣传

> 43.6 **未验证结果禁止作为优点宣传（no unverified merit）**：任何未经验证证据支撑的结果——含统计/成本/额度/数量类数据——禁止在交付面（交付总结/交付报告/会话呈报/progress 登记）以优点、成效、收益口吻呈现；「零消耗」「零成本」「零影响」类统计声称必须随附其结论对应的验证动作证据（命令输出/产物查看/复验记录），无附证 = 该声称降级为「未验证」登记项（43.1 口径），禁止优点口吻复述；成本/额度类统计与验证动作属不同平面事实——「0 消耗」往往即「0 测试」，不得以成本统计替代验证证据缺位（Q9 触发面，按 Rule 26.3 惩罚映射语义处置，登记于 53.5；与 51.8② 同面，Q3 伪造档同档）。

### Rule 51 各子条（行 558-570）

**行 558 — Rule 51 标题与判例源**
> ### 51 需求覆盖与完成声称门控（task-v129）
> 判例源：videop1 mvlock 虚假执行（2026-10-04）——声称"停线完成"但核心需求仅 2/18+自挂起+17 次零需求生成；用户定性「流程失控/缺失，非能力问题」。

**行 561 — 51.1 需求原文锚定**
> 51.1 需求原文锚定（目标先行）：计划创建与重规划时必须设「🎯 用户需求原文」区块，逐条编号抄录用户原话（R1..Rn；禁转译/缩写/合并——转译即漂移入口）；每条核心需求映射 ≥1 条 VC（R→VC 映射）。缺该区块或核心需求零 VC 映射=计划无效，先回炉再 attest。

**行 562 — 51.1a 载体双机制**
> 51.1a **载体双机制（task-v131 清账）**: 区块载体=① scripts/init-session.sh 生成时注入（无载体模板自动插脚手架；mini 档豁免；fail-open）② scripts/attest-plan.sh 锁定三锚门（标题/R 行/R→VC 映射缺一拒锁；fail-closed）③ 模板可见区块（主模板+variant 随维护逐个补齐）。

**行 564 — 51.2 验证机制先行**
> 51.2 验证机制先行：每条核心需求在计划期预登记「覆盖判据」——covered 的可观察证据形态（计数=0/文件在位+绝对路径/命令输出形态）；VC 验证方式必须引用判据。先设计验证后执行，禁止"先做完再想怎么算完成"。

**行 565 — 51.3 完成声称对照门**
> 51.3 完成声称对照门：交付终态逐需求条目出「需求覆盖核对表」（covered/partial/uncovered+证据路径）；任一用户显式核心需求 uncovered/partial 且无用户显式让步（Decisions Made 登记）→ 终态禁 COMPLETE，只可 PARTIAL 并显式列未覆盖项与原因；交付总结按 templates/delivery-summary.md「需求覆盖核对」区块输出（缺区块=交付不完整）。

**行 566 — 51.4 自缩水禁令**
> 51.4 自缩水禁令：对用户已明确需求做「挂起/搁置/收口/暂不/降级/有条件不执行」类缩水处置=Rule 41 G4 语义级目标分叉，必须 AskUser/STOP+Decisions Made 登记获确认后才可写入计划；禁止仅把缩水措辞写进计划/进度即视为已处置，禁止按缩水版计划自报完成。（silent 模式对本款不适用：G4 缩水项必须显式等待用户答复，不得按推荐项自走。）

**行 567 — 51.5 生成动作前置盘点**
> 51.5 生成动作前置盘点（媒体/内容族）：任何生成/补制/重建/重制类消耗性动作前，必须先盘点库存（在库/在用同类资产清单落 findings.md）；盘点结论=资产已在库或在用→零生成（触发制口径）；无盘点记录的生成=Rule 26 降质面（资源浪费），回炉+Error Log（判例：17 次生成调用零产出）。

**行 568 — 51.6 机制**
> 51.6 机制：零新 config 键；selftest-requirement-coverage.sh 静态守护（七子条锚+SKILL/模板联动锚+负断言）；消费点=SKILL 合规清单 C35+delivery-summary 模板区块；check-complete 深化解析（自动核对覆盖表）已落地（task-v132 G1 R-COVERAGE 门），不弱化既有终验门控（3-File Gate/19.5 语义不变）。

**行 569 — 51.7 纠正=回锚重译**
> 51.7 **纠正=回锚重译，非设计增量（task-v132，事故判例）**: 用户纠正/补充指令时，纠正原话追加为「🎯 用户需求原文」区块**新 R 行**（禁改写/合并既有 R 行——改写旧行=销毁锚点=事故直接成因）；受影响 VC 同步改写并在 Decisions Made 登记纠正编号与时间；执行体已在途的，重建派发前重过 attest/dispatch 门（含窗口口径 lint）。

**行 570 — 51.8 未测试就声称完成禁令**
> 51.8 **未测试就声称完成禁令（no untested completion）**：覆盖判据属「实际生成/实际测试」形态（43.5 范围）的需求条目，禁止——① 无实测证据（生成回执 + 产物质检取证，43.5 三件套）时声称 covered/完成，缺任一件 = 该条目按 51.3 口径判 uncovered；② 将未测试的结果作为优点宣传（43.6 同面语义）；③ 以成本/额度类统计（如「消耗 0 次生成」）充当覆盖证据——统计 ≠ 验证（51.5 盘点口径的「零生成」指盘点结论=资产已在库故不生成，属需求项本身 0 生成量；本款针对「产物=参数/提示词修改」的条目，此类条目必附真实测试证据，两平面由产物性质区分而非成本数据区分）。违规 = 该条目 uncovered + Rule 26.3 惩罚映射语义（Q9 触发面，登记于 53.5），终态禁 COMPLETE，只可 PARTIAL 并显式列未验证项（51.3 原处置）。判例锚：task-v133（提示词修改未测试 + 零消耗宣传，用户 R2/R3/R5 原话见 plans/task-v133/task_plan.md）。

### Rule 41.3（行 429）— trivial 自主裁定

> 41.3 **trivial 自主裁定（trivial auto-adjudication）**：明显正确的小修（trivial ≤3 行/单行配置增补如 .gitignore/注释同步/一致性收尾）=**主进程直接做+Decisions Made 登记**，禁止以「留用户裁决」「留用户后续处置」类措辞推诿；该类措辞在交付物中仅可用于命中 41.2 四门槛的项（task-v097 CR P2-b .gitignore 一行被推给用户即反例，本条即为其纠正——明显正确的单行增补不构成待决项，做+登记+披露即闭环）。

### Rule 49.2（行 527）— 推进三条件

> 49.2 **推进三条件（全满足才可派发该单元线下一工序）**：① **已验收**——该单元线当前工序已通过 21.4 三证据验收（执行记录/产出 Read 复核/验证证据，22.5 口径）；② **前置在位**——目标工序的直接前置产物实际存在且非空（依赖本单元线前序工序产物即可推进；目标工序消费他单元线产物的=汇合点，走 49.4① 强串行，不适用本条）；③ **互不干扰**——目标工序 S-unit 通过 21.4 独立性四问（对照全部在飞子代理，含其他单元线已前移者）。

### Rule 53.3（行 588）— 决策管辖二分

> 53.3 **决策管辖二分（反推诿）**: 决策点管辖以 Rule 41.2 四门槛为唯一权威边界：**用户专属=G1-G4 之一**（真实偏好二选属 G4 语义级目标分叉范畴；D6 硬停点按其既定语义等待确认，不适用 Rule 44 自动超时），四门槛外**一律代理可判**——判别参考（非并行体系，防自设出口）：可逆或影响局部/有客观判据或领域默认可循/信息在手/在任务范围内。代理可判项必须代理裁决并在 Decisions Made 登记决策+一句理由，禁止把代理可判项包装成「待用户确认/提供选项」推给用户（惰性违规，按 Rule 26.3 惩罚映射语义处置：触发面=Q7 惰性推诿，登记于 53.5，不扩 26.1 枚举）；与 41.3/44.2 联动（低区分度选项必须直接裁决）；升级呈报前按 41.4 消解清单附「已尝试清单」。

### Rule 26 触发清单（行 228-234）— 与伪造/完成声称相关

**行 228 — 26.1 触发条件**
> 26.1 **触发条件(可观察判定式)**:

**行 229 — Q1 跳过 VC 复验**
> - **Q1 跳过 VC 复验**:task_plan.md 中 `**Status:** complete` 的 Phase,其在 verification.md 对应段的 V-N 项存在未勾选 `- [ ]` 或 Evidence 字段为空(grep + Read 可判)

**行 231 — Q3 证据不实(伪造/篡改)**
> - **Q3 证据不实(伪造/篡改)**:抽查 ≥3 条 Evidence(VC 总数 <3 时全查),任一条路径 Read 失败、或重跑命令输出与声称结论矛盾、或引用内容在指定 file:line 处不存在

**行 238-246 — 26.3 惩罚映射**
> | 触发 | 处置 |
> |------|------|
> | Q1/Q2/Q4 首次、单 Phase | 强制回炉:撤销 complete → 补做验证/Read 复核 → 重走 Rule 19.2 回填 |
> | Q1/Q2/Q4 会话内累计 ≥2 Phase | outcome 最高 PARTIAL |
> | Q3 证据不实 | 最高档:不得自判 COMPLETE/PARTIAL,以 BLOCKED 上报 + STOP 等用户裁决;禁止以"补做验证"恢复 |

---

## 2. critical-rules.md grep 关键词命中（与 F1/F2/F3 相关）

| 行号 | 关键词 | 原句摘录 |
|------|--------|----------|
| 95 | 阻塞 | 18.3 **失败隔离硬约束**:单单元失败不阻塞其他单元,但累计 failure_rate;>5% → STOP 报告等决策;>20% → 自动熔断 + 回滚 |
| 166 | silent | 22.3.3 ...接管失败 → 才允许 ⑤ AskUser(silent 模式按 28.4.1 降级交付,禁空等) |
| 174 | 里程碑 | 22.7.1 **STOP 上报最小集**:...③ 检查点路径+已落盘里程碑数(无检查点=违规)... |
| 177 | 里程碑 | 22.8.2 **执行中落盘时机**...T1 每完成一个文件的 Edit/Write → 追加里程碑行... |
| 178 | 里程碑 | 22.8.3 **检查点文件格式**:纯 markdown 分段(头部 status 行 / 已完成里程碑 append-only 带时间戳...) |
| 179 | 里程碑 | 22.8.4 **断点重试**:...有实质进度(≥1 条里程碑或已有产出文件)→ 重试 prompt 注入 resume_from 段... |
| 181 | cron | 22.9 ...② 全局 legacy `plans/.active_plan`(兜底,cron/纯脚本单会话场景)... |
| 196 | 额度 | 23.10 ...② 资源相争——...**同额度窗口**（生成额度=全局共享资源，Σ 在飞 lane 预算 ≤ 当日剩余额度，AGENTS 约束 4）→串行... |
| 210 | 阻塞 | 24.6 **失败兜底**:plan-resume 调用失败...不阻塞当前 Phase 推进 |
| 260 | 阻塞 | 27.3 **提交校验**:...非空 = 有遗漏,补提交或说明原因... |
| 261 | deferred | 27.4 **豁免**:仅两种——① 计划内声明 `git_commit: deferred`... |
| 267 | silent | 28.1 **模式定义与解析优先级**:两种模式——`ask`...与 `silent`(静默:不询问、自主决策、登记清单)... |
| 268 | silent | 28.2 **ask 模式询问点(D1-D6)**:...silent 模式按推荐项继续不中断... |
| 269 | silent | 28.2.1 ...silent 模式不适用本条... |
| 271 | silent | 28.4 **silent 模式语义**:除 D6 外不调用 AskUserQuestion;每个被跳过的询问点按"推荐项"自主决策,并登记「静默决策清单」... |
| 272 | silent | 28.4.1 **D6 的 silent 例外(禁静默空等)**:...③ 计划 outcome 判 PARTIAL(不得虚判 COMPLETE)... |
| 291 | 阻塞 | 30.2 ...账本被项目 gitignore 忽略 → 记「账本未入库」一行提醒，不阻塞。 |
| 311 | silent | 32.1 ...含 ask 模式用户否决推荐项、silent 模式用户事后否决... |
| 338 | silent | 34.7 ...全自动不 AskUserQuestion，silent 合法... |
| 357 | silent | 36.4 ...silent 模式同样不得跳过（D6 两模式一致）。 |
| 400 | 阻塞 | 39.3 ...子代理升级的阻塞问题带全局唯一 question id... |
| 427 | 阻塞 | 41.1 **消解优先原则**...遇到问题（执行失败/异常/阻塞/不确定）的第一反应=**自动消解**... |
| 428 | silent | 41.2 **升级四门槛**...silent 模式按 T3 推荐项自动+登记... |
| 431 | silent | 41.5 **打包呈报**...未答复项按推荐项登记 silent 决策继续... |
| 444 | silent | 42.6.1 ...silent 模式=按 Rule 44 自动超时裁决... |
| 458 | 额度 | 43.6 ...含统计/成本/额度/数量类数据...「零消耗」「零成本」「零影响」类统计声称必须随附其结论对应的验证动作证据... |
| 464 | 阻塞 | 44.3 **超时自动选择**...不阻塞等待、不擅自降级... |
| 529 | 阻塞 | 49.3 ...派发不被 Phase 栅栏阻塞... |
| 566 | silent | 51.4 ...（silent 模式对本款不适用：G4 缩水项必须显式等待用户答复，不得按推荐项自走。） |
| 570 | 额度 | 51.8 ...③ 以成本/额度类统计（如「消耗 0 次生成」）充当覆盖证据——统计 ≠ 验证... |

---

## 3. SKILL.md 关键行

### 交付总结五要素段（行 160）
> - **交付总结（五要素）**：按 `templates/delivery-summary.md` 向用户输出任务交付总结（任务说明/产出清单/审查信息/风险点/下一步建议；数据引 verification.md/progress.md/subagent-state/ 指针不重写；风险点区块必须列举，无则逐项写「无」；需存证时落 plans/<task-id>/delivery-summary.md；**可定位性（Rule 48）**：全体指针必须为绝对路径/URL/可执行命令（禁裸文件名、模糊指代、未解析占位符）；下一步建议与待裁决项逐条带「对象路径/URL+看点+动作」，审查类条目必须含审查对象路径或网址）

### Rule 51 摘要行（行 305）
> - **Rule 51（需求覆盖与完成声称门控 — task-v129）**：自缩水禁令+生成前置盘点+未测试就声称完成禁令八子条（51.1-51.8，含 51.7 纠正=回锚重译/窗口口径 lint 增补 task-v132；51.8 未测试就声称完成禁令 task-v133）；零新 config 键+selftest-requirement-coverage.sh 守护（51.6）

### silent 模式相关行
- **行 74**: ...silent 模式本门控自动通过——计划照常 `bash scripts/attest-plan.sh` 锁定后直接执行，无需等待确认；计划全文落盘可查，交付报告须附「静默决策清单」（Decisions Made 表 `silent:` 前缀行）供用户复核...
- **行 146**: ...交互模式语义见 Rule 28（ask=选项化询问并回填 Decisions；silent=按推荐项自主处置并登记 `silent:` 决策行，D6 硬停点除外）
- **行 186**: | C18 | ask 模式计划批准前已按 28.2.1 口头复述大体执行思路...（silent 模式不适用；复述为人工动作） | ☐ |
- **行 285**: - **Rule 28（P0）交互模式与询问门控**：ask（默认：D1-D6 关键决策点给选项供用户选...）| silent（静默：自主决策+登记静默决策清单）；解析优先级 env > 计划配置表 > config.json > 默认 ask；D6 硬停点...两模式一致不可豁免...
- **行 320**: ...输出 = 规划→plan+思路复述（28.2.1，ask 模式）+确认（silent 模式按 Rule 28 自动通过）...
- **行 427**: | 5 | **AskUserQuestion** | ...交互模式见 Rule 28（ask=选项化询问并回填 Decisions；silent=按推荐项自主处置并登记 silent 决策行；D6 触发时按 28.4.1 降级交付...禁静默空等） | AskUserQuestion 工具 |

---

## 4. scripts/ 下 selftest-*.sh 全清单（51 个）

### 与「完成声称/需求覆盖/可靠性/根因」主题相关

| 脚本 | 主题覆盖 |
|------|----------|
| selftest-requirement-coverage.sh | **需求覆盖/完成声称** — Rule 51 八子条静态守护 |
| selftest-reliability-institution.sh | **可靠性** — Rule 42/43 执行可靠性制度化静态守护 |
| selftest-root-resolution.sh | **根因** — Rule 53 根源解决与决策管辖静态守护 |
| selftest-conclusion-discipline.sh | **完成声称** — Rule 35 执行结论纪律静态守护 |
| selftest-execution-stability.sh | **可靠性** — 环境级中断自愈面守护 |
| selftest-final-gate-hash.sh | **完成声称** — 终验重复门四元内容键 SKIP-BY-HASH |
| selftest-vc-gate.sh | **需求覆盖** — check-complete.sh 终验 VC/V-N 门控自测 |
| selftest-reflect-verify.sh | **可靠性** — Rule 33 解决→反思→验证迭代循环 |
| selftest-error-loop.sh | **根因** — Rule 31 错误学习闭环静态守护 |
| selftest-self-resolution.sh | **可靠性** — Rule 41 问题自主消解与升级纪律 |
| selftest-media-dispatch.sh | **需求覆盖** — Rule 47 媒体制作任务派发纪律 |
| selftest-media-agents.sh | **需求覆盖** — Rule 47.2 媒体双专业执行体 |
| selftest-lane-advancement.sh | **需求覆盖** — Rule 49 单元线多路并行推进 |
| selftest-requirement-grading.sh | **需求覆盖** — Rule 50 内容要求权重分级与评级 |
| selftest-dispatch.sh | **可靠性** — check-dispatch.sh + zcode-pretooluse Agent 分支自测 |
| selftest-delegation.sh | **可靠性** — 委派门控自测 |
| selftest-rescue-chain.sh | **可靠性** — check-rescue-chain.sh 自测 |
| selftest-fallback.sh | **可靠性** — subagent-fallback.sh 自测 |
| selftest-review-library.sh | **可靠性** — Rule 42 质量审查兜底池 |
| selftest-iterative-optimizer.sh | **可靠性** — 顶层 iterative-optimizer 循环迭代优化 skill |
| selftest-batch-pilot.sh | **可靠性** — Rule 18 批量试点先行硬门 |
| selftest-plan-dispatch.sh | **可靠性** — check-plan-dispatch.sh + attest-plan.sh 集成自测 |
| selftest-task-boundary.sh | **需求覆盖** — Rule 8.1 新任务边界判定(D 类) |
| selftest-veto.sh | **可靠性** — Rule 32 用户否决与禁令追踪 |
| selftest-skill-modify.sh | **可靠性** — Rule 36 技能修改保守化与功能删除防护 |
| selftest-template-lifecycle.sh | **可靠性** — Rule 34 模板生命周期 |
| selftest-template-sense.sh | **可靠性** — 三时点模板感知网（Rule 34.7） |
| selftest-mechanism-profile.sh | **可靠性** — Rule 37 任务类型机制画像 |
| selftest-tool-selection.sh | **可靠性** — Rule 40 harness 工具面主动选择 |
| selftest-workflow-orchestration.sh | **可靠性** — Rule 39 动态工作流编排 |
| selftest-ask-default-timeout.sh | **可靠性** — Rule 44 用户选择点默认项与自动超时 |
| selftest-interaction.sh | **可靠性** — resolve-interaction-mode.sh 解析优先级自测 |
| selftest-active-plan.sh | **可靠性** — active-plan-race 会话私有指针自测 |
| selftest-agent-coverage.sh | **需求覆盖** — Rule 52 执行体专业化优先 + 覆盖矩阵 |
| selftest-check-conflicts.sh | **可靠性** — check-conflicts.sh 五类信号行为级自测 |
| selftest-check-drift.sh | **可靠性** — check-drift.sh 三 quirk 修复行为级回归 |
| selftest-context-hygiene.sh | **可靠性** — Rule 29 上下文与工作文件主动维护面 |
| selftest-dispatch-grain.sh | **可靠性** — Rule 46 子代理单任务专注度 |
| selftest-fine-grain-steps.sh | **可靠性** — 步骤枚举门控（step_max_steps） |
| selftest-knowledge-brief.sh | **可靠性** — 任务知识简略要点(knowledge-brief)面 |
| selftest-methodology.sh | **可靠性** — methodology 门控面 hermetic 守护 |
| selftest-plan-tier.sh | **可靠性** — Rule 38 任务难度分级与轻量档 |
| selftest-rule-reserve.sh | **可靠性** — Rule 20.6 规则编号预留登记机制 |
| selftest-rule23-conflict-scan.sh | **可靠性** — Rule 23 运行时并发冲突扫描 |
| selftest-shared-tracker.sh | **可靠性** — Rule 30 共享内容认领追踪 |
| selftest-skill-collab.sh | **可靠性** — 协同路由面守护 |
| selftest-skill-split.sh | **可靠性** — 技能拆分终态守护 |
| selftest-smart-merge.sh | **可靠性** — smart-merge-back.sh 智能门 hermetic 自测 |
| selftest-sync-index.sh | **可靠性** — sync-todos.sh --index 行为级自测 |
| selftest-tier-b.sh | **可靠性** — task-v094 Tier B 全 7 项守护 |
| selftest-registry.sh | **可靠性** — selftest 分域 registry 一致性自守护 |

---

## 5. companion/ 目录清单

### agents/ 目录（6 个文件）
- article-batch-publisher.md
- article-field-fixer.md
- complex-planner.md
- image-generation-executor.md
- plan-writer.md
- video-generation-executor.md

### image-generation-executor.md 相关条款

| 行号 | 主题 | 原句摘录 |
|------|------|----------|
| 12 | 状态汇报 | > 超时约束：单会话执行 120 分钟上限；到点未完成返回 partial 并报告已完成件数与断点位置。 |
| 18 | 额度窗口 | - **试水门与预算**: 批次第 1 件过完整三检才扩批；单件重抽 ≤20 次（超限冻结=唯一合法 STOP 上报） |
| 36 | 汇报纪律 | - **静默执行**：批次内 0 打断（冻结/D6 除外）；只落检查点不回传叙事；批次末单份收尾报告 |
| 50-56 | 禁止行为 | ## 禁止行为（无提示词/无核词直接批量生成、首件未过三检即扩批、自创主体属性、超预算静默重抽、静默吞错、代表用户验收） |
| 58-60 | 证据要求 | ## 证据要求（强制）— 每件产物：URL/路径 + 三检逐项结论 + 重抽计数；关键判断附 file:line 或命令→输出行；无第一手证据的结论标注「未验证」；禁止把推测写成已通过 |
| 62-64 | 验证协议 | ## 验证协议 — 交付前自查：产物 URL 可达性（HEAD 探测）/本地文件存在性；三检结论与产物一一对应；抽检揭露：任一「三检 PASS」无对应证据 → 自降为未验证并上报 |
| 66-67 | 负结果报告 | ## 负结果报告 — 连续 2 件同维度 FAIL 或 API 持续报错 → 停止扩批，输出 `HARD_BLOCK: <现象+已尝试>`，等待主进程改派/升级（Rule 22.3） |

### video-generation-executor.md 相关条款

| 行号 | 主题 | 原句摘录 |
|------|------|----------|
| 12 | 状态汇报 | > 超时约束：单会话执行 120 分钟上限；到点返回 partial 并报告已完成镜头与断点。 |
| 19 | 额度窗口 | - **成本纪律**: 视频调用昂贵——单镜试水先行（smoke-test 不裸调），配额警示后再批量；中文 prompt 先译英文 |
| 51-57 | 禁止行为 | ## 禁止行为（无放行登记发起 video 调用、未 smoke-test 裸调、同会话兼做草稿 QC、自行裁决四级处置、超配额无警示批量扩散、静默吞错） |
| 59-61 | 证据要求 | ## 证据要求（强制）— 每镜：放行 grep 行 + video_id/URL + QC 结论 + 处置建议；关键判断附 file:line/命令输出；未验证项显式标注；禁止推测包装 |
| 63-65 | 验证协议 | ## 验证协议 — 交付前自查：产物 URL 可达/文件在位；QC 结论与产物一一对应；放行核验行在回执可见；抽检揭露：任何「QC PASS」无证据 → 自降未验证并上报 |
| 67-68 | 负结果报告 | ## 负结果报告 — 连续 2 镜同型 FAIL / 轮询超时 / 配额拒绝 → 停止批量，`HARD_BLOCK: <现象+已尝试>` 上报（Rule 22.3 处置） |

---

## 6. F1/F2/F3 三档判定

### F1 — 代理产物冒充完成（准备物/中间产物完成被包装成需求推进）

**已覆盖条款**:
- Rule 43.5（行 457）: 生成参数类修改必须实际生成测试，未执行实测 = 零验证证据，禁止声称完成
- Rule 51.8（行 570）: 未测试就声称完成禁令——无实测证据时声称 covered/完成 = 违规
- Rule 51.3（行 565）: 完成声称对照门——交付终态逐需求条目出核对表
- Rule 43.1（行 453）: 证据先行反幻觉——未验证内容只能以『未验证』显式登记

**部分覆盖**:
- Rule 51.5（行 567）: 生成动作前置盘点——覆盖「准备物/中间产物」的盘点义务，但未明确「准备物完成 ≠ 需求推进」的判定

**未发现覆盖**:
- 无直接条款禁止「把准备物/中间产物完成包装成需求推进」的表述

---

### F2 — 未阻塞工作连带推迟（独立资源窗口不阻塞却整体推迟）

**已覆盖条款**:
- Rule 23.10（行 196）: 单元级冲突检测清单——同额度窗口 = 资源相争 → 串行
- Rule 49.2（行 527）: 推进三条件——已验收 + 前置在位 + 互不干扰
- Rule 49.3（行 529）: 推进动作与登记——三条件满足 → 立即派发，不等同 Phase 其他单元线完成

**部分覆盖**:
- Rule 41.1（行 427）: 消解优先原则——覆盖「遇到问题第一反应=自动消解」，但未明确「独立资源窗口不阻塞」的判定

**未发现覆盖**:
- 无直接条款要求「逐项给阻塞证据」或「独立资源窗口不连带推迟」

---

### F3 — 仪式性进展冒充实质进展（建 spec 文件+设 cron 包装为里程碑）

**已覆盖条款**:
- Rule 43.6（行 458）: 未验证结果禁止作为优点宣传——「零消耗」「零成本」类统计声称必须随附验证动作证据
- Rule 51.8（行 570）: 未测试就声称完成禁令——以成本/额度类统计充当覆盖证据 = 违规

**部分覆盖**:
- Rule 53.3（行 588）: 决策管辖二分——覆盖「反推诿」，但未明确「仪式性进展 ≠ 实质进展」

**未发现覆盖**:
- 无直接条款禁止「把建 spec 文件+设 cron 包装为里程碑」

---

**检查点写入完成**: 2026-10-05
