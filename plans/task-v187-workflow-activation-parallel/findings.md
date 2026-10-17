# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
- R1（目标型）：复杂任务主动创建工作流（CreateWorkflow）推进——现状激活率 0，需规则演进使主动激活可达
- R2（目标型）：工作流创建时按任务难度给子代理选不同档模型，禁全流统一复杂大模型
- R3（目标型）：互不冲突、互不依赖的子代理调用尽量并行同时推进（提效）
- 全文见 task_plan.md §🎯 用户需求原文（逐字）+ user-session-log.md #1（含理解镜像）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| collab.md Rule 39/40/91 现行原文 | skills/plan-collab-router/references/critical-rules-collab.md:1-77 | ☑（诊断轮 grep 精读核心段） | Research Findings §诊断证据 |
| dispatch.md Rule 21.4/68 现行原文 | skills/task-dispatch/references/critical-rules-dispatch.md:25-33,80-96,160-174 | ☑（同上） | Research Findings §诊断证据 |
| SKILL.md 协同路由段 | skills/task-planner/SKILL.md:156,170,207 | ☑（同上） | Research Findings §诊断证据 |
| 官方 CreateWorkflow 工具描述（本会话 schema） | 系统工具定义（subagent_model/max_concurrency/触发条款） | ☑ | Research Findings §官方事实 |
| workflow-model-tiers 用户级技能 | ~/.zcode/skills/workflow-model-tiers/SKILL.md（120 行） | ☐（Phase 1 S-unit 精读） | 待回填 |
| selftest 断言面三脚本 | scripts/selftest-{workflow-orchestration,parallel-scheduling,tool-selection}.sh | ☐（Phase 1 explore 枚举） | 待回填 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 诊断证据（主进程一手取证，2026-10-18 诊断轮）

**根因 1（R1：工作流激活率 0）——规则结构性锁死，非执行滑坡**：
- `skills/plan-collab-router/references/critical-rules-collab.md:5`（Rule 39.1 原文）：「仅当用户显式调用 `/workflow` 或明确措辞要求 workflow 编排……时，本条生效……**agent 不得自主判断启动 workflow**（官方 L46-55「explicit request is binding」）。未点名 → 一律按既有 Rule 21.4 调度铁律执行……Rule 39 零影响面」
- `skills/task-planner/SKILL.md:207`（消费侧摘要行互锁）：「dynamic-workflows 仅用户显式点名 `/workflow` 时路由（Rule 39）」
- `critical-rules-collab.md:32`（Rule 40.4）：计划期仅可登记「**建议** CreateWorkflow」且明文「建议登记 ≠ 自动触发，触发判定权仍在用户」
- 结论：现行三处条款（39.1 主条款/40.4 计划期路径/SKILL.md 摘要行）构成闭环互锁——主动创建被规则本身禁止。用户实测「执行多次从来就没有主动创建过」= 规则设计使然的必然结果。

**根因 2（R2：模型分级空转）——条款在位但无激活时机**：
- `critical-rules-collab.md:37-50`（Rule 91，2026 前任务已收编 workflow-model-tiers）：「workflow 脚本编写期按子代理职责力度显式声明模型档位」——但前提是存在 workflow 脚本；根因 1 导致工作流从不被创建，91 无用武之地
- 官方事实（本会话 CreateWorkflow 工具 schema 一手核验）：`subagent_model` 参数=**run 级单一字段**（"The model for the workflow's subagents"），非 per-subagent；另有 `max_concurrency` 可调并行度（"Only when the user asks"）。与 collab.md 91.2 既有实证一致（官方 SKILL.md:112「there is no per-subagent tool profile or model choice」）
- 结论：诉求 2 落点=①39.8 主动创建时强制联动 91 分档纪律（四档映射按职责分配）②CreateWorkflow 调用时按任务整体难度声明 run 级 subagent_model（用户 2026-10-18 常设授权=「Only when the user asks」的满足）③per-subagent 官方无支持维持 91.2 披露+91.5 验证门（不变量④）

**根因 3（R3：并行率低）——声明制摩擦+无惰性防线**：
- `critical-rules-dispatch.md:27`（Rule 21.4 声明制）：并行组须 frontmatter `parallel_groups` 声明∧S-unit 行含组标记；「**未声明者默认串行——守卫对无组标记派发按串行槽拦截**」
- `critical-rules-dispatch.md:92-96`（Rule 23.9-23.13）：机器面只「放行有标记的派发」，check-dispatch 单一全局锁不区分组名——计划期没声明组=执行期全串行，且**无执行期扩组通道**（frontmatter 受 SHA-256 attest 锁定，追加触发重锁=高摩擦）
- `critical-rules-dispatch.md:164`（Rule 68.2）：已有「分组目标=在依赖约束下最大化并行度……杜绝『全计划默认串行』的惰性分组」——但仅为目标语，**无论证义务/无回炉条件**，惰性全串行计划可无阻力通过
- 结论：诉求 3 落点=①21.4.2 执行期扩组协议（新识别独立单元→Decisions 登记→补标记→重锁→并行）②68.2 惰性串行论证义务（S-unit ≥3 且零并行组须论证否则回炉）③既有独立性四问+组间串行语义不变（不变量⑤）

**官方红线张力（设计输入）**：官方工具描述「Without such an explicit request, do not start a workflow」与用户诉求直接冲突。裁决序=宪法 §四 P0-1（用户当前指令）> 官方默认政策。合规化路径=常设授权三元组（来源锚 user-session-log #1 + 可撤销声明 + 每次激活留痕），39.1 保留官方原文披露+覆盖论证，不掩埋冲突。

### S0 断言面侦察结论（explore 子代理，2026-10-18，检查点 subagent-state/0-explore.md）

**selftest 硬断言锚（改写即破，须级联）**：
| 锚 | 位置 | 断言内容 |
|----|------|---------|
| WF-09 | selftest-workflow-orchestration.sh:64 | 「dynamic-workflows 仅用户显式点名」SKILL 摘要行锚（R1） |
| TS-06 | selftest-tool-selection.sh:89 | 同 R1 锚（tool-selection 侧） |
| TS-03 | selftest-tool-selection.sh:51 | §40.4 行含「显式点名」（40.4 锚——注意非「建议 CreateWorkflow」字样） |
| P-08 | selftest-parallel-scheduling.sh:147 | 「未声明者默认串行」≥1（R3 21.4 语义锚） |

**四形态族 A 类命中（将改写面）**：collab.md:5/27/32/70、dispatch.md:27、task-planner/SKILL.md:207——与诊断轮一致。
**B 类引用面（级联风险三处+排除项）**：
- templates/task_plan.md:262（「🧰」区块 workflow 编排判定模板行——40.4 语义镜像）
- plan-template-kit/references/template-guide.md:254 + template-mapping.md:312/321（40.4「建议 CreateWorkflow/未命中=串行」镜像）
- 排除项：complex-planner.md:16「用户显式点名」=模型规划语境非 workflow 语义，**勿误改**（级联排除清单登记）
**脚本内「建议 CreateWorkflow」「未声明默认串行」0 命中**——40.4 措辞在脚本层仅经 TS-03「显式点名」间接锚定。
**CCR 四档**（workflow-model-tiers→Rule 91.1 已收编）：heavy=opus-1 / medium=sonnet-1 / light=fast / minimal=haiku-1；官方 run 级 subagent_model 无 per-task 覆盖（91.2 矛盾披露维持）。

### 方案定稿（主进程单写者，Phase 2 执行体照单修订——六段全文）

#### 39.1 重写文（collab.md:5 整段替换）
39.1 **触发纪律（显式点名 ∨ 常设授权命中条件——[EVOLVED 2026-10-18 task-v187]）**：本条生效当且仅当以下二者之一：① 用户显式调用 `/workflow` 或明确措辞要求 workflow 编排（官方 L46-55「explicit request is binding」原样有效——点名即强制路由 CreateWorkflow，agent 不得替代为 Agent 派发或自行判断任务过小）；② **用户常设授权命中 39.8 编排条件**（2026-10-18 用户原话授权：「复杂任务应该启用工作流，主动创建工作流来调用，来推进任务」——常设授权等价于显式请求的常驻形态；授权锚=plans/task-v187-workflow-activation-parallel/user-session-log.md #1；用户一句「收回工作流授权」即整体回退至仅①）。未命中①② → 一律按既有 Rule 21.4 调度铁律执行（独立性守门：声明并行组内可并行、未声明组=串行槽），Rule 39 零影响面；单一委托/几个独立查询仍走 Agent 工具。原「agent 不得自主判断启动 workflow」限定语废止——由 39.8 条件门+激活三件套留痕替代（官方默认政策被用户主权常设授权覆盖，覆盖论证与撤销机制见 39.8；官方红线原文披露保留于此，Rule 35.2 防虚构）。

#### 39.8 新增子条（collab.md §39.7 系列后新增）
39.8 **常设授权主动激活（proactive activation under standing authorization — task-v187 [EVOLVED 2026-10-18]）**：用户常设授权（39.1 ②）下的主动创建通道。**激活三条件（命中任一即主动路由 CreateWorkflow）**：a) 计划期依赖分析（Rule 68.1）判定 ≥3 个 S-unit 同波独立可并行（独立性四问全 no）——fan-out 有实质收益；b) 长链编排型任务（≥3 阶段且阶段间有类型化中间结果/需按停止条件循环——39.3 四机制映射任一命中形态）；c) 用户显式点名（=39.1 ①原路径，强制）。**激活义务三件套（缺一=违规激活）**：① 留痕——Decisions Made 一行 `[workflow-activation] 条件 {a|b|c} 命中依据` + 39.4 并行豁免登记（progress.md 同步）；② 模型分档——CreateWorkflow 调用按 Rule 91.6 联动声明 run 级 `subagent_model`（按 91.1 CCR 四档整体定档，禁默认 heavy 全流）；③ 环境前置——激活前过 Rule 83 通道探测（`Skill("dynamic-workflows")` 可用性）+39.2 加载门槛，不可用快速失败三选项（禁 ≥2 次同法重试）。**回落边界（不命中不激活，防滥用）**：L0/mini/trivial 轻量通道任务（Rule 38.7 边界不动）、S-unit <3 或强依赖链计划、单文件小修——一律 Agent 调度（21.4）；禁止为用 workflow 而拆分制造虚假并行（Rule 26 降质映射）。

#### 40.4 升级文（collab.md:32 整段替换）
40.4 **workflow 编排计划期路径（[EVOLVED 2026-10-18 task-v187] 建议登记面→主动路由义务）**：计划期工具分析命中 39.8 激活三条件（独立并行 ≥3 S-unit 可 fan-out / 长链编排型可复用 / 用户点名）之一时，「🧰」区块登记「CreateWorkflow 路由（39.8 条件 {a|b|c} 命中）」，执行期按 39.8 激活义务三件套**主动创建**；未命中且用户未点名 → 按 Rule 21.4 独立性守门调度（并行默认+声明制，未命中编排条件不登记 CreateWorkflow）。原「建议登记 ≠ 自动触发，触发判定权仍在用户」条款废止——触发判定=39.8 条件门（用户常设授权）∨ 用户点名，非仅点名；Rule 36.5 纯增量语义由本演进条目承接（同文件同条目内演进，非跨条改写）。模板镜像同步：templates/task_plan.md「workflow 编排判定」行与 plan-template-kit 镜像面（template-guide.md/template-mapping.md）随本条演进（task-v187 CA-10）。

#### 91.12 新增子条（collab.md §91.11 后新增；[S2 执行发现修正 2026-10-18] 原蓝本编号 91.6 撞号——91 族现已编至 91.11，顺延 91.12）
91.12 **主动激活联动（39.8 → 91 分档强制 — task-v187）**：经 39.8 常设授权主动创建的 workflow，创建动作强制过本条分档纪律：① CreateWorkflow 调用按任务整体难度声明 run 级 `subagent_model`（官方 schema 唯一模型字段——91.2 披露的 per-subagent 官方不支持维持；档位按 91.1 CCR 四档：heavy=opus-1/medium=sonnet-1/light=fast/minimal=haiku-1，重编排 medium 以上、轻量编排 light/minimal，全流统一强档违 91.8 既有条款）；② 脚本内按 91.1 四档映射为各 subagent 职责配档（model() 写法维持 91.5 验证前置门+91.6 编译期约束）；③ 授权锚=用户 2026-10-18 原话「确保不会使用，都使用复杂大模型解决」（user-session-log #1）。与 68.3 异构分摊分工：68.3 管 Agent 派发路径组内异构，本条管 workflow 路径整体定档+脚本内配档。

#### 21.4.2 新增子条（dispatch.md §21.4.1 后新增）
21.4.2 **执行期扩组协议（parallel-uplift — task-v187 [EVOLVED 2026-10-18] 用户裁决：「只要任务不冲突，就是不互相依赖的前提下，可以提高并行」）**：执行期新识别的并行机会（原计划未声明组，但目标 S-unit 批独立性四问全 no）按四步升级：① 主进程在 Decisions Made 登记 `[parallel-uplift] <S-unit 清单> + 四问 ①-④ 全 no 依据各一行`；② task_plan.md 对应 S-unit 行补组标记 `[parallel-group:<组名>]` + frontmatter `parallel_groups:` 追加组名；③ 重跑 attest-plan.sh 重锁（Rule 20 锁定机制——执行期改 frontmatter/S-unit 表须重锁；Decisions 已登记扩组理由=合法重锁非篡改，Rule 51.7）；④ 按 21.4 组语义并行派发（组内并行+逐个验收+首败评估拆细，验收纪律不变）。**只读豁免通道保持**：只读类并行（Explore/grep/调研）继续走 parallel_readonly 豁免（task-v094 T-B1 沿承），免重锁。**禁止**：未经四问登记擅自并行（守卫对无标记派发仍按串行槽拦截）；为并行而拆碎不可独立单元（Rule 26 降质映射）。

#### 68.2 尾部追加（dispatch.md:164 段尾）
**惰性全串行论证义务（task-v187 [EVOLVED 2026-10-18] 用户裁决：「尽量提高非互相影响的子代理的并行效率」）**：S-unit 总数 ≥3 且 `parallel_groups` 零声明的计划，attest 前必须在 Decisions Made 登记全串行论证（资源相争/输入依赖/风险放大三轴至少一轴逐 S-unit 说明，或明示「依赖链拓扑=纯线性」依据）；无论证=惰性分组，计划回炉重做 68.1/68.2 分析。判定面=LLM 行为+attest 人工核查；机器 WARN（check-plan-dispatch advisory）=opt-in 待用户显式授权（宪法 §四.6 文本优先铁律），本条不新建机器门。

#### S4 消费侧同步段（两 SKILL.md + 模板镜像，S0 侦察补充）
- task-planner/SKILL.md:207 原句「dynamic-workflows 仅用户显式点名 /workflow 时路由（Rule 39）」→ 新句「dynamic-workflows 于用户点名 /workflow 或命中 Rule 39.8 编排条件（常设授权）时主动路由——激活按 39.8 三件套（留痕/91.12 分档/83 探测）（Rule 39,40,91）」[编号修正：S4 执行时按旧蓝本写了 91.6，S3 收口时同步改 91.12]
- plan-collab-router/SKILL.md：grep「显式点名/仅用户」定位路由行，同语义同步（S0 未报具体行号，执行体现场定位）
- task-planner/SKILL.md:170 协同路由表行「（Rule 39,40,91）」无锁死措辞——不动；:156 Rule 83 行无锁死措辞——不动
- CA-10 模板镜像三处：templates/task_plan.md:262 判定行改「命中 39.8 条件 → 登记『CreateWorkflow 路由（39.8 条件命中）』并执行期主动创建（39.8 三件套）；未命中 → Rule 21.4 声明制调度」；template-guide.md:254 + template-mapping.md:312/321 同语义镜像同步
- 级联排除项：complex-planner.md:16（模型规划语境）勿改

#### [sub:S4-code-assistant] S4 执行记录
- A) task-planner/SKILL.md:207 单行内句替换=蓝本 :88 新句逐字一致（python 逐字核验 `bp in line`=True；`git diff --stat` task-planner/SKILL.md=2 +-（+1/-1 单行级））
- B) plan-collab-router/SKILL.md：`grep -n "显式点名\|仅用户"` exit 1=零命中（全文 44 行 Read 复核），无锁死措辞，0 处替换、该文件零写入
- 验证：`grep -c "仅用户显式点名"` 两文件合计=0；双模式 `显式点名\|仅用户` 两文件 0 命中；`grep -cE "主动路由|39\.8" task-planner/SKILL.md`=1（:207 行）
- :156（Rule 83 行）与 :170（协同表行）原文在位未动；worktree 余下 diff（collab/dispatch/templates）=S1/S2/S3/S5/S9 既有写入面，非 S4 写入
- S4 done（2026-10-18，task-v187 pg-w2）

#### [sub:S5-executor] S5 执行记录
- 21.4.2 子条插入 critical-rules-dispatch.md:34（21.4.1 段后独立长行；蓝本=本文件 :82，diff 空=逐字一致）
- 68.2 尾部追加接在 68.2 长行行末（插入后行号 :165；蓝本=本文件 :85，diff 空=逐字一致）
- 验证输出：grep -c "21\.4\.2"=1（仅插入段，全文无前文引用，属蓝本「可能的前文引用」为 0 情形）；grep -c "parallel-uplift"=1；grep -c "惰性全串行论证义务"=1；§21.4（:25-32）与 §68.1（:163）原文未动
- worktree `git status --short`=仅 `M critical-rules-dispatch.md`；`git diff --stat`=+2/-1（=21.4.2 新增行 1 + 68.2 改行 1 删 1），除 dispatch.md 外零写入
- S5 done（2026-10-18，task-v187 pg-w1）

#### [sub:S1-executor] S1 执行记录
- collab.md:5 整段替换=蓝本 :70 全文，`diff` 空=逐字一致；39.2/39.3/39.4/39.5/39.6/39.7 行号不变（6/7/17/18/19/20）；§40.4(:32) 未动（S3 范围）
- 验证：`grep -c "常设授权"`=1（行计；§39 段首无 10-18 演进描述）→ 检查点回退条款：39.1 行内出现 4 次 ≥2 ✓；旧禁止语「agent 不得自主判断启动 workflow」grep 计数=1=蓝本自身废止引语「原「…」限定语废止」（有意保留），生效条款形态（带官方 L46-55 锚）计数=0 ✓
- 旁证：同 worktree dispatch.md 21.4.2(:34)/68.2(:165) 写入与蓝本 :82/:85 逐字一致（=S5 记录段所述），S1 写入面=仅 collab.md 1 行
- S1 done（2026-10-18，task-v187 pg-w1）

#### [sub:S2-executor] S2 执行记录
- 39.8 蓝本行（findings:73 逐字，diff 空=一致）插入 collab.md:24（39.7.3 子条末 :23 后、§40 标题行前；插入后 §40 顺延 :25→:26，内容未动）
- 验证：`grep -c "^39\.8"`=1；`grep -c "常设授权"`=2；三要素逐词 grep -c=各 1（同处新行 24：激活三条件/激活义务三件套/回落边界）；`grep -n "^### 40"`=:26 ✓
- git diff hunk 面：collab 文件共 2 hunk（@@ -5 +5 @@=S1 既有 39.1 替换；@@ -23,0 +24 @@=本单元纯插入 0 删除）→ 39.1-39.7/§40 既有内容零移动；worktree 另 M dispatch.md（S5）/ M task_plan.md（S9 CA-10），非本单元写入
- S2 done（2026-10-18，task-v187 pg-w2；checkpoint subagent-state/4-executor.md）

#### [sub:S10-general] S10 重派执行记录
- 替换行清单: template-guide.md:254（1 行）；template-mapping.md:312,:321（2 行）；合计 3 行 = git diff 3 ins/3 del，其余行零变化
- 替换语义 = 命中 39.8 激活条件→登记 CreateWorkflow 路由并执行期按 39.8 三件套主动创建；未命中→Rule 21.4 声明制调度（与 findings §S4 CA-10 蓝本一致；「未命中→串行/建议≠自动触发/建议登记」旧语义全清）
- 验证: grep -c "39\.8" 两文件合计=3（guide=1,mapping=2）≥2 ✓；「建议 CreateWorkflow」guide=0/mapping=0（40.4 语境全清，非 40.4 语境无残留，无未改项）
- git diff -U0=6 行（3- /3+）=替换行数；行格式与前后缀保持，仅语义短语替换；S10 done（2026-10-18，task-v187 pg-w2；checkpoint subagent-state/9-general-purpose.md）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 常设授权三元组（详见 task_plan D1-D7） | 见 task_plan.md §Decisions Made——论证主体在计划侧（attest 锁定），本表不重复 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 开场 UserPromptSubmit hook 报 [PLAN TAMPERED]（task-v184 计划哈希不符） | 与本任务无关的既有事实：v184=complete 5/5 已完结（INDEX:15 确认），git status clean，.plan-attestation mtime 13:45 vs task_plan.md 14:05=收尾簿记提交（16951ff 部署同步批次）改文件未重锁——非恶意篡改（修改已入 git 历史）。处置=已向用户报告；建议随 v184 归档动作重锁或忽略；不阻塞本任务 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- skills/plan-collab-router/references/critical-rules-collab.md（Rule 39:1-23 / 40:25-33 / 91:37-50）
- skills/task-dispatch/references/critical-rules-dispatch.md（Rule 21.4:25-33 / 23.9-23.13:92-96 / 68:160-174）
- skills/task-planner/SKILL.md:156,207（消费侧待同步行）
- ~/.zcode/skills/workflow-model-tiers/SKILL.md（CCR 四档映射，Phase 1 消费）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:S9-code-assistant] S9 执行记录
- templates/task_plan.md:262 判定行方括号整体替换=定稿蓝本新语义（39.8 激活条件命中→登记 CreateWorkflow 路由+执行期三件套主动创建；未命中→Rule 21.4 声明制），前缀与行格式保持
- 验证：grep -c "39.8"=1 ≥1 ✓；旧措辞「建议 CreateWorkflow」grep -c=0 ✓；git diff 该文件=1 行（+1/-1）
- S9 done（2026-10-18，task-v187 pg-w2）

#### [sub:S3-executor] S3 执行记录
- A) collab.md:33 40.4 整段替换=蓝本 :76 逐字（diff 空）；91.12 整段插入 :79（91.11 :78 后、文件尾；蓝本 :79 逐字 diff 空）
- B) task-planner/SKILL.md:207「留痕/91.6 分档/83 探测」→「留痕/91.12 分档/83 探测」单字面修正
- 验证全过：grep -c "39\.8" collab=4(≥3，行 5/24/33/79)；"subagent_model"=4(≥2)；"^91\.12"=1；SKILL "91\.6 分档"=0 且 "91\.12 分档"=1；"^91\."=12 行=91.1-91.11 既有 11(:42-:78)+91.12 新增(:79)；39.1(:5)/39.8(:24) 与蓝本 :70/:73 逐字 diff 空=零改动
- 遗留：collab.md:24（39.8 段内）「Rule 91.6 联动」为 S2 逐字插入的旧编号残留（91.6 现行=编译期约束非分档强制条），S3 白名单不含 39.8 改动，建议后续单元（或用户裁决）同步改 91.12；S3 范围外未动
- S3 done（2026-10-18，task-v187 串行槽；checkpoint subagent-state/8-executor.md）

#### [sub:S6-executor] S6 执行记录
- A) selftest-workflow-orchestration.sh WF-09（:63-64）期望措辞同步：grep -qF 'dynamic-workflows 仅用户显式点名' → '于用户点名 /workflow 或命中 Rule 39.8 编排条件（常设授权）时主动路由'（=SKILL.md:207 新句逐字子串）+注释 1 行级联注；39.x 机制锚 WF-01..06/13..22 零改动
- B) collab.md:24（39.8 段）「Rule 91.6 联动」→「Rule 91.12 联动」单点字面修正（S3 遗留项清账）；:64/:79 既有 91.6 子条合法引用未动
- 验证：grep -c "91\.6 联动"=0 且 "91\.12 联动"=1；git diff=2 文件 3 ins/2 del，除两文件外零写入（S8 两脚本未碰）
- 脚本第 1 轮：Total: 22 PASS=22 FAIL=0 exit 0（基线唯一 FAIL=WF-09，单轮转绿，未触发 ≤2 轮再同步）
- S6 done（2026-10-18，task-v187 pg-w3；checkpoint subagent-state/11-executor.md）

#### [sub:S8-executor] S8 执行记录
- A) selftest-parallel-scheduling.sh: 零 Edit——P-08「未声明者默认串行」锚预期保持（dispatch.md:27 原 21.4 行未动，计数=1）；脚本无 21.4 子条计数型断言，21.4.2(:34)/68.2 尾部追加(:165) 不漂移 P-01（68.x=7）
- B) selftest-tool-selection.sh: 仅期望措辞同步 2 处零新增断言——TS-03 40.4 行锚「显式点名」→「39.8 激活三条件」（collab.md:33 新 40.4 行内唯一出现=稳定字面）；TS-06「dynamic-workflows 仅用户显式点名」→「dynamic-workflows 于用户点名 /workflow 或命中 Rule 39.8」+「（Rule 39）」→「（Rule 39,40,91）」（SKILL.md:207 现行句）；TS-08/TS-11 模板区块锚（🧰/上游分析记录/工具选择映射/工具选择与编排区块）核验仍 PASS 未改
- 验证: worktree 内双脚本各跑 1 轮全 PASS（FAIL 0 轮）——parallel-scheduling `Total: 9 PASS=9 FAIL=0` exit=0；tool-selection `Total: 12 PASS=12 FAIL=0` exit=0
- git diff 本单元写入面=仅 selftest-tool-selection.sh（断言期望值+注释，逐行复核零新增断言行）；workflow-orchestration.sh 的 M=S6 写入面未碰
- S8 done（2026-10-18，task-v187 pg-w3；checkpoint subagent-state/12-executor.md）

#### [sub:S11-code-assistant] S11 执行记录
- 4 处单点 Edit（超目标 1 处）：collab.md:28 短语 + :28 行内第二处「不改 39.1「显式点名才路由」原文」引用 + :71 短语；plan-writer.md:45 语义段改「命中 39.8 激活条件→登记 CreateWorkflow 路由并执行期主动创建」
- 关键发现：:28 同一行存在 2 处旧短语（需求描述只标 1 处），为满足全文件旧短语=0 断言一并替换；该处为 40 引言对 39.1 的引用面非 39.1 本体，语义无损
- 验证：四断言全过（旧短语=0/新短语=2/plan-writer 旧字样=0/披露引语 :5=1 保留）；selftest-workflow-orchestration 22P0F、tool-selection 12P0F、conclusion-discipline 24P0F、knowledge-brief 16P0F；git status 写入面仅 2 目标文件
- S11 done（2026-10-18）

#### [sub:cr-fix-m1] M-1 修复记录
- collab.md:28 尾句「40.4 只增计划期建议登记面…（Rule 36.5 纯增量）」→「40.4 已演进为主动路由义务（39.8 联动…）承接对齐」逐字替换（+1/-1，行内其余零动）
- 验证：grep -c "只增计划期建议登记面"=0；grep -c "主动路由义务（39.8 联动"=1；selftest-workflow-orchestration `Total: 22 PASS=22 FAIL=0`
- 说明：S11 记录段称 :28 已替换，本 worktree 实态 Read 仍为旧句（worktree 侧未含该改动），本次为实际落点
- cr-fix-m1 done（2026-10-18；checkpoint subagent-state/17-code-assistant.md）
