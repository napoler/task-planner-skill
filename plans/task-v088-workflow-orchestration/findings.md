# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### dynamic-workflows 工具契约提炼（Phase 1，Explore 子代理产出，官方文档行号锚点）

> 权威源：`/opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/SKILL.md`（1521 行）。以下为可被 Rule 39 直接消费的事实，逐条带官方行号锚点。

**工具全集（7 个 + TaskOutput/GetWorkflowRun）**：`CreateWorkflow`(script/saved/path 三来源互斥) / `AmendWorkflow`(修订既有 run, cache 导入) / `SaveWorkflow`(沉淀) / `ListSavedWorkflows` / `ListWorkflowRuns` / `GetWorkflowRun`(即时快照, 从不阻塞) / `ResumeWorkflowRun`(仅 stopped) / `ResolveWorkflowQuestion`(答子代理升级) / `EvalWorkflowSnippet`(同步编译片段) / `ListModels`。

**关键事实锚点**：
1. **路由红线（L46-55）**：「Only an explicit request starts a workflow… never with your own judgement」——只有用户明确点名 workflow（"/workflow"、"use a workflow"、"用工作流"）才启动；哪怕 Agent 就能办也照办，但**不得由 agent 自主判断启动**。单一委托/几个独立查询仍走 Agent 工具。
2. **skill 加载前置（L11-12, L920-921）**：Create/Amend/Save/EvalSnippet 四工具在本会话未加载 dynamic-workflows skill 时**拒绝运行**；唯一例外=跑 `saved:` 来源的 CreateWorkflow。
3. **facade 脚本契约（§16.2, L968-1346）**：`agent(name?, persona?)`→`Agent`（每次全新上下文）；`agent.ask<T>(instructions)`；`phase(name)` **强制**（每 phase ≥1 ask 或 world.run）；`report(item)`（日志式, 失败也随通知送达）；`world.run(cmd,args,{timeoutMs})`（非零退出=值非异常；cmd 必须编译期字面量, 确认时批准命令集）；`files.{glob,read,grep}`；`git.{changedFiles,diff,status,log}`（只读）；顶层可 `await`，最终 `return` 携带完成通知值。
4. **终态三态（L761-776）**：`completed`（脚本 return）/ `errored`（脚本自身失败, **不可 resume**, 须编辑 scriptPath + AmendWorkflow）/ `stopped`（reason: user/model/interrupted/provider；interrupted=宿主进程退出, resume 即可）。`superseded`=被 Amend 取代的旧 run。
5. **Amend cache 复用（L787-795, L104-108）**：AmendWorkflow 导入旧 run 已完成工作作缓存（按 subagent 名+指令字节匹配, 零 token 回放）；活动写/活动 world.run 后缓存 world 读失效；**可调常数放控制流, 别插进 ask 文本**, 否则 amend 全下游缓存失配重付。
6. **人工升级（§14, L861-906）**：每个 subagent 能升级阻塞问题（`submit_result` 注入）；升级通知带 `dwfq-…` 全局唯一 question id；**只停提问的那个 subagent**, 兄弟与控制流继续；无超时（要么答要么 run 取消）；答法=`ResolveWorkflowQuestion(question_id)` 文本原样成为该 ask 结果；通知丢失用 `GetWorkflowRun.pendingQuestions` 兜底；每个 ask 最多 3 次升级, 第 4 次返回「额度用尽, 按你最佳判断继续」。
7. **SaveWorkflow 沉淀（§16.5, L1453-1498）**：scope=`project`→`.zcode/workflows/<name>.dwf.ts`（随仓库提交）/`global`→`~/.zcode/workflows/`；args 声明（string/number/boolean/json）=调用约定；**绝不主动保存**（须用户同意或点名才调）。
8. **并发（L955-959）**：`max_concurrency` 只在用户要求限制并行时设置；`subagent_model` 是 run 级统一设置（非逐 agent）。
9. **未提及项**：官方文档（SKILL.md/examples/patterns）**未提及** check-dispatch.sh hook 或 task-planner 派发守卫——workflow 内部 subagent 是否受 check-dispatch 约束，文档层面无答案。

### Rule 39 定稿草稿（P2 派发时逐字贴入 critical-rules.md 尾部 Rule 38 之后）

```
### 39 动态工作流编排（dynamic workflow orchestration routing — task-v088，目标：用户显式点名 /workflow 时路由到 dynamic-workflows 编排，把 task-planner 失败兜底/断点续做/人工升级/模板沉淀四机制映射到 workflow 原生能力；未点名时既有串行派发零改动）

task-planner 执行模型长期只有「串行 Agent() 逐 S-unit 派发」一条路，对多步、有类型化中间结果、需按停止条件循环的编排型任务串行慢、失败重跑全量重付、人工干预无原生通道；harness 已内置 dynamic-workflows 能力（AmendWorkflow cache 导入 / ResumeWorkflowRun 断点 / ResolveWorkflowQuestion 升级 / SaveWorkflow 沉淀），技能层却零路由零映射。本条建立「点名才路由 + 四机制映射 + 并行豁免登记 + 机器校验边界」链路；未点名任务保持 Rule 21.4 串行铁律零改动（Rule 36.5 纯增量）。

39.1 **触发纪律（显式点名才路由 — 官方红线复刻）**：仅当用户显式调用 `/workflow` 或明确措辞要求 workflow 编排（"use a workflow"/"用工作流"）时，本条生效，路由到 `CreateWorkflow`（编排替代纯串行 Agent 派发）；**agent 不得自主判断启动 workflow**（官方 L46-55「explicit request is binding」）。未点名 → 一律走既有 Rule 21.4 串行派发，Rule 39 零影响面；单一委托/几个独立查询仍走 Agent 工具。
39.2 **前置条件（skill 加载门槛）**：`CreateWorkflow`/`AmendWorkflow`/`SaveWorkflow`/`EvalWorkflowSnippet` 四工具在本会话未 `Skill("dynamic-workflows")` 加载时拒绝运行（官方 L11-12）；运行 `saved:` 来源的 `CreateWorkflow` 是唯一豁免路径（官方 L942-943）。编排前须确认该 skill 可加载；四工具脚本（inline 一次性 / saved / path）提交前必须已加载本 skill（typecheck + 确认窗）。
39.3 **四机制映射（task-planner 机制 → workflow 原生能力，单一权威源表）**：

| task-planner 机制（权威源） | workflow 原生机制 | 映射说明 |
|---|---|---|
| 失败换档/修复续做（Rule 22.3 ①-⑤ / 22.7） | 编辑 `scriptPath` 文件 + `AmendWorkflow` | errored run 不可 resume，须修脚本再 amend；amend 导入旧 run 已完成工作作 cache 零成本回放（官方 L764-767, L787-795） |
| 断点续做（Rule 22.8 resume_from / plan-resume Rule 24） | `ResumeWorkflowRun`（stopped）/ `AmendWorkflow`（errored） | stopped(reason=interrupted) 直接 resume 原样恢复；errored 必须 amend（官方 L764-772）。cache 按 subagent 名+指令字节匹配 → subagent 命名须稳定、可调常数不进 ask 文本（官方 L832-859） |
| 人工升级（Rule 28 D5-D6 询问点） | `ResolveWorkflowQuestion(dwfq-…)` | 子代理升级的阻塞问题带全局唯一 question id；答复文本原样成为该 subagent 调用结果；只停提问的那个 subagent，兄弟与控制流继续；通知丢失用 `GetWorkflowRun.pendingQuestions` 兜底；每个 ask 最多 3 次升级（官方 L861-906） |
| 模板沉淀（Rule 34.3 触发 / 34.4 流程） | `SaveWorkflow`（project `.zcode/workflows/` / global `~/.zcode/workflows/`） | 可复用编排沉淀为 saved workflow（args 声明=调用约定）；官方纪律=绝不主动保存，须用户同意或点名（官方 L1453-1498）；同名覆盖走 Rule 36.4 用户确认 |
| 每 Phase 验收门控 | `phase()` 验收节点图 + `report()` verified/notCovered + `world.run` 确定性门控 | phase() 强制画验收节点图；report() 条目随失败通知送达且不重复；确定性验收用 world.run（cmd 编译期字面量，确认时批准命令集，官方 L968-1346） |

39.4 **并行豁免与 Rule 21.4 调和**：workflow subagent 默认可并行（fan-out / `Promise.all`，官方 L308-310）；当用户显式点名 workflow 编排时，Rule 21.4 串行铁律在**该 workflow run 内部**豁免（显式调用期登记制，非改写 21.4 原文）——豁免一行登记 Decisions Made + progress.md；用户同时要求串行 → 传 `max_concurrency: 1`（官方 L955-959）。Rule 21.4 文本零改动（Rule 36.5 纯增量）。
39.5 **机器校验边界（Rule 35.2 防虚构）**：workflow 内部 subagent 是否受 `check-dispatch.sh` 派发守卫 hook 约束 = **官方文档未提及**（已 grep 核实 SKILL.md/examples/patterns）；禁止在 Rule 39 声称机器守卫覆盖 workflow 内部。机器校验归 harness 侧（`ListWorkflowRuns`/`GetWorkflowRun` 终态与 pendingQuestions 可查）；派发契约（九字段 prompt / 8 字段返回，Rule 22.4/22.4b）由脚本作者在 persona/ask 文本内自行内嵌，**非 hook 强制**——这是与 Agent() 派发的关键区别，须如实披露。
39.6 **机制（零新 config 键 — 与 task-v087 同范式）**：判定面=LLM 行为（显式点名才触发，非机器）；机器面=dynamic-workflows 官方自身约束（skill 加载前置 / 确认窗 / typecheck 拒跑，官方 L11-12, L920-921），无需再造开关键。守护=`scripts/selftest-workflow-orchestration.sh` 静态断言（39.x 条款锚 + SKILL 协同路由行 + Rule 39 摘要行 + C27 + 「Rules 1-39」索引 + 零 config 键 + 行数上限）；消费侧=SKILL.md 🤝 协同路由矩阵 dynamic-workflows 行 + C27。
```

### SKILL 联动定稿文案（P3 派发时逐字贴入，共 5 处）

> SKILL.md 相对仓根 `skills/task-planner/SKILL.md`。净增 ≤8 行。

**S3-1 ① 协同路由矩阵（§🤝 专业技能协同路由）追加 1 行**（在 CLI 探针前置那行后）：
```
- **dynamic-workflows（用户显式点名 /workflow 才路由 — Rule 39）**：用户显式调用 `/workflow` 或明确措辞要求 workflow 编排 → 先 `Skill("dynamic-workflows")` 加载，再 `CreateWorkflow` 编排（多步类型化中间结果 / 停止条件循环 / fan-out→fan-in 的任务）；未点名一律走既有 Rule 21.4 串行 Agent 派发（Rule 39.1 触发纪律）。四机制映射（失败→AmendWorkflow cache / 断点→ResumeWorkflowRun / 升级→ResolveWorkflowQuestion / 沉淀→SaveWorkflow）见 `references/critical-rules.md` Rule 39。
```

**S3-1 ② Critical Rules 摘要行（Rule 38 行后追加 1 行，位于 L~288 附近 Critical Rules 列表内）**：
```
- **Rule 39（动态工作流编排 — task-v088）**：用户显式点名 `/workflow` 才路由 dynamic-workflows 编排（未点名=既有 21.4 串行零改动）；skill 加载前置门槛（39.2）；四机制映射 失败/断点/升级/沉淀→AmendWorkflow/ResumeWorkflowRun/ResolveWorkflowQuestion/SaveWorkflow（39.3 表）；21.4 并行豁免登记（39.4）；机器校验边界=官方文档未提及 check-dispatch 覆盖 workflow 内部（39.5）；零新 config 键，selftest-workflow-orchestration.sh 守护（39.6）
```

**S3-1 ③ 合规检查清单追加 C27（C26 行后）**：
```
| C27 | 用户显式点名 /workflow 编排时已按 Rule 39 路由：Skill("dynamic-workflows") 已加载、CreateWorkflow 三来源其一提交、21.4 并行豁免已登记 Decisions Made+progress（39.4）；未点名 → 本项 N/A 记一行（走 21.4 串行） | ☐ |
```

**S3-1 ④ L288「详见 `references/critical-rules.md`（Rules 1-38）」→「（Rules 1-39）」**
**S3-1 ⑤ L340 表行 `| `references/critical-rules.md` | Critical Rules 1-38（…+ Rule 38 任务难度分级与轻量档） |` → 末尾追加 ` / Rule 39 动态工作流编排`，并把 `Critical Rules 1-38` → `Critical Rules 1-39`**

**S3-2 CLAUDE.md L32** `├── critical-rules.md ← Rules 1-38 核心执行约束` → `Rules 1-39`（可加 `（+39 动态工作流编排）`）
**S3-2 README_zh.md L136** `├── critical-rules.md ← Rules 1-38 核心执行约束` → `Rules 1-39`
**S3-2 README_zh.md L229** `| `skills/task-planner/references/critical-rules.md` | Rules 1-38 —— 自定义前必读 |` → `Rules 1-39`

**S3-3 skills/task-planner/README.md L67** `│   ├── critical-rules.md # Rules 1-38（… + 38 任务难度分级与轻量档）` → `Rules 1-39（… + 38 任务难度分级与轻量档 + 39 动态工作流编排）`

### WF selftest 断言清单（P4 派发时逐字建成 scripts/selftest-workflow-orchestration.sh，参照 selftest-plan-tier.sh 的 t() helper 结构）

```
WF-01: critical-rules.md 含 "### 39 动态工作流编排" 锚
WF-02: critical-rules.md 含 "39.1 **触发纪律" 锚
WF-03: critical-rules.md 含 "39.3 **四机制映射" 锚
WF-04: critical-rules.md 含 "39.4 **并行豁免" 锚
WF-05: critical-rules.md 含 "39.5 **机器校验边界" 锚
WF-06: critical-rules.md 含 "39.6 **机制" 且含 "零新 config 键"
WF-07: SKILL.md 含 "Rule 39"（摘要行存在）
WF-08: SKILL.md 含 "C27"（合规清单项存在）
WF-09: SKILL.md 协同路由含 "dynamic-workflows" 行
WF-10: 全仓 "Rules 1-39" 命中 ≥6（SKILL×2 + CLAUDE + README_zh×2 + skills/task-planner/README）
WF-11: 全仓 "Rules 1-38" 在 SKILL/CLAUDE/README 三文档残留 = 0（selftest 脚本历史注释不含 1-38 字样，不受影响）
WF-12: config.json properties 键数 = 40（零新增，jq -r '.properties|keys|length'）
```

### CHANGELOG 条目草稿（P4 派发时贴入 CHANGELOG.md 头部）

```
## v088 — task-planner 接入 /workflow（动态工作流编排 Rule 39）
- 新增 Rule 39 动态工作流编排：用户显式点名 /workflow 才路由 dynamic-workflows（CreateWorkflow 编排），未点名保持 21.4 串行派发零改动（39.1 触发纪律，复刻官方 "explicit request is binding"）
- 39.2 skill 加载前置门槛（Create/Amend/Save/EvalSnippet 未加载 dynamic-workflows 时拒绝；saved: 唯一豁免）
- 39.3 四机制映射表：失败→AmendWorkflow cache / 断点→ResumeWorkflowRun / 人工升级→ResolveWorkflowQuestion(dwfq) / 模板沉淀→SaveWorkflow；每 Phase 验收→phase()+report()+world.run
- 39.4 21.4 串行铁律在 workflow run 内部豁免（显式调用期登记制，非改写 21.4 原文）；用户要求串行传 max_concurrency=1
- 39.5 机器校验边界如实披露：官方文档未提及 check-dispatch 覆盖 workflow 内部，机器校验归 harness 侧
- 39.6 零新 config 键（与 v087 同范式）；守护 scripts/selftest-workflow-orchestration.sh（WF-01..12 静态断言）
- SKILL 联动：协同路由矩阵 dynamic-workflows 行 + Rule 39 摘要行 + C27 + 「Rules 1-38」→「1-39」索引级联 6 处（SKILL×2/CLAUDE/README_zh×2/skills/task-planner/README）
- 4 既有 selftest 行数上限锚 555→563（batch-pilot/execution-stability/knowledge-brief/skill-collab）
- 部署：三位实体位 IDENTICAL + push 远端
```
EOF
cat /tmp/v088-drafts.md >> /dev/null; echo staged $(wc -l < /tmp/v088-drafts.md) lines

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
