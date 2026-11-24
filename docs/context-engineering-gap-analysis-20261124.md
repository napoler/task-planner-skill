# task-planner Skill 家族：长上下文处理机制诊断与差距分析（2026-11-24）

> 只读诊断。未修改任何 `skills/` 源码或既有文档。全部结论带 `file:line` 证据，文末列复现命令。
> 仓库根：`/mnt/data/dev/task-planner-skill`。

---

## 0. 结论先行

用户投诉「长上下文弊端没解决好」成立，但根因不是「没有机制」，而是**三层断裂**：

| 层 | 判断 | 分类 |
|---|---|---|
| 恢复注入 | 用 **61KB 技能全文**无条件内联对抗压缩，方向与目标相悖 | 机制存在但**方向错** |
| 消费读回 | 写入门齐备，读回靠人肉规则且 mini/L0 可豁免 | 机制存在但**弱/被架空** |
| 运行时预算 | 只有派发 prompt 字符预算，**无会话级 token 水位/预算/主动摘要** | **根本没实现** |

一句话：本项目把长上下文治理做成了「文档卫生 + 规则重读 + 压缩后全文回填」，而业界方案的核心是「可观测的 token 预算 + 分层记忆 + 检索式召回」。前者管的是**文件**，后者管的是**上下文窗口本身**。

---

## 1. 扫描范围、方法与负结果

### 1.1 实际扫描

- 目录：`skills/`（21 个 skill 全量顶层 + task-planner 的 `scripts/ references/ templates/ lib/`）、仓库根文档、`plans/`（在途任务 + 抽样归档）、`knowledge/entries/`、`docs/`、`.zcode/plans/`、`.claude/`、部署位 `~/.zcode/cli/config.json`、平台记忆 `~/.zcode/cli/memories/projects/task-planner-skill-*/memory/`。
- 模式：`recover|recover-skill|sessionstart|SKILL.md|inject`、`context.*budget|token.*budget|上下文预算|max_tokens|压缩阈值|上下文窗口`、`PRESSURE|CONFUSED|\[assess\]`、`RETRIEVAL_EXCLUDE`、`knowledge_use|消费|未消费`、`auto-tier|从未触发|修4`、`user-session-log|knowledge-brief|notepad|MEMORY.md|findings.md|progress.md`。
- 方法：先 `find/wc` 定规模，再 `grep -n` 定行，`Read` 取原文，最后 `grep` 复现（见 §6）。

### 1.2 负结果（明确报告未发现项）

1. **未发现**任何运行时 token 计数器、水位百分比、上下文占用日志或自动摘要触发器：`skills/task-planner/scripts/` + `skills/task-planner/SKILL.md` 对上述预算模式 **严格零命中**（复现 V3b）。
2. **未发现** `RETRIEVAL_EXCLUDE.md` 的任何脚本调用点：`skills/*/scripts/` 全域零命中（复现 V4）；它只是 SKILL.md 里的文本规则。
3. **未发现** `~/.zcode/cli/config.json` 有 Stop/SessionEnd hook；结束提示只能靠主进程规则+模板（该事实另由记忆 `agent-failure-ledger-20261123.md:22` 独立记录）——但**这不构成风险结论**，因为本机 hook 事件面本身不支持。
4. **排除的可能性**：不认为「子代理委派门 / CLI-planctl / SP-OS 是长上下文问题的根因」。一手诊断记忆 `task-perf-tiers-20261124.md:14-15` 明确「慢的是编排不是脚本」「SP/OS 是思考骨架非加速器，问题是审计失控不是缺 spec」；根因是编排无边界与分级错配，不是这三项机制本身。
5. **排除**：不把 `tmp/worktrees/**`、`skills/task-planner/.backup/**` 的副本当作权威源（依项目 AGENTS.md §2 源码位置铁律）；它们只在核对「是否部署/是否同一份」时作旁证。

---

## 2. 机制盘点（现状全貌）

### 2.1 压缩恢复链路

| 文件:行 | 做什么 | 状态 |
|---|---|---|
| `/home/terry/.zcode/cli/config.json:29-46` | SessionStart 注册两个 command hook：`zcode-sessionstart.sh`（timeout 10s）+ `zcode-sp-inject.sh`（8s，SP-OS 注入）。部署位，非仓库源码。 | 在位 |
| `skills/task-planner/scripts/zcode-sessionstart.sh:9-14` | 读 stdin `session_id` → sid 经 env 透传 `task-plan-init.cjs`，写会话私有哨兵。 | 在位 |
| `skills/task-planner/scripts/zcode-sessionstart.sh:16-19` | 注释明确「本 hook 每次上下文压缩后触发」；旧逻辑只注入开场白，实证「压缩后 6 分钟未读计划专档并误删既有设定事实」。 | 在位（问题驱动补丁） |
| `skills/task-planner/scripts/zcode-sessionstart.sh:29` | `RECOVER_FIELDS` 定义 9 个注入字段：`skill_contract,requirements,goal,phase,recent_actions,next_step,decisions,mustkeep,git_baseline`。 | 在位 |
| `skills/task-planner/scripts/zcode-sessionstart.sh:31-56` | 向上最多 10 层找 `plans/`，用 side 指针定位在途计划，调 `planctl recover --max-lines 150`。 | 在位 |
| `skills/task-planner/scripts/zcode-sessionstart.sh:112-122` | 无在途计划时调 `planctl recover-skill`，**无条件注入 SKILL.md 全文**（2026-11-24 补丁）。 | 在位（争议点） |
| `skills/task-planner/scripts/zcode-sessionstart.sh:132` | 把全部注入包装为 `{"additionalContext": ...}` 进会话；`exit 0` fail-open。 | 在位 |
| `skills/task-planner/scripts/planctl.py:862-869` | 恢复字段/标记常量；`RECOVER_ACTION_TAIL=8`、`RECOVER_ACTION_CHARS=200`；`RECOVER_SKILL_END` 兼作「被平台截断」检测锚。 | 在位 |
| `skills/task-planner/scripts/planctl.py:896-925` | `_recover_skill_text()` 解析 canonical 源（部署位薄壳→源仓 SKILL.md）。 | 在位 |
| `skills/task-planner/scripts/planctl.py:992-1101` | `cmd_recover`：恢复纪律头 + 权威源核心状态 + 技能正文全文，落盘 `.compact-recovery.md`（只落任务状态）。 | 在位 |
| `skills/task-planner/scripts/planctl.py:1073-1078` | 限幅只作用于**任务状态块**（150 行），超出尾部截断并给追读路径。 | 在位 |
| `skills/task-planner/scripts/planctl.py:1082-1089` | **技能正文全文内联，`lines.extend(body.splitlines())`，不参与限幅**。 | 在位（核心缺口） |
| `skills/task-planner/scripts/planctl.py:1104-1131` | `cmd_recover_skill`：无在途计划时也注入恢复纪律 + 全文，不读权威源、不落盘。 | 在位（核心缺口） |
| `skills/task-planner/scripts/planctl.py:2272-2289` | 两个子命令注册（recover / recover-skill）与 CLI 帮助。 | 在位 |

### 2.2 记忆体系（写入/读回载体）

| 文件:行 | 做什么 | 状态 |
|---|---|---|
| `skills/task-planner/SKILL.md:33-36` | 四文件罗盘定义：`task_plan`(目标)/`findings`(决策)/`progress`(进度)/`knowledge-brief`(学习)；「四文件写入分流铁律」。 | 在位 |
| `skills/task-planner/SKILL.md:57` | 初始化在位校验 7 文件：含 `notepad-learnings` / `knowledge-brief` / `user-session-log`。 | 在位 |
| `skills/task-planner/SKILL.md:109-110` | 3b 每 2 次 view/browser/search 写 `findings.md`；3c 关键动作随做随记 `progress.md`。 | 写入门 |
| `skills/task-planner/SKILL.md:151` | 调研蒸馏知识落 `knowledge-brief.md` §2/§3/§4（主进程单写者）。 | 写入门 |
| `skills/task-planner/SKILL.md:164,177` | `user-session-log.md` append-only 逐字记录，新指令首动作；G9 自查。 | 写入门 |
| `skills/task-planner/SKILL.md:230` | Rule 80：恢复先读用户会话专档。 | 读回门（文本） |
| `skills/task-planner/references/plan-workflow-details.md:131` | **3f' 周期性会话记忆回顾**：每 3 个 Todo/S-unit 重读四载体（findings + knowledge-brief §2-4 + user-session-log 尾部 ≤30 行 + progress 尾部），梳理/纠偏/反思/留痕；**mini/L0 档豁免**。 | 读回门（人肉+可豁免） |
| `skills/task-planner/references/plan-workflow-details.md:132` | **3g 规范召回（Rule 93）**：每 3 S-unit 或 Phase 翻转亲自 Read 召回卡；compaction 恢复后第一动作先读；**mini/L0 档豁免**。 | 读回门（人肉+可豁免） |
| `skills/task-discipline/references/execution-recall-card.md:1-54` | 54 行规范蒸馏卡（A-F 六节），用户 2026-10-21 采纳的「摘要卡」方案，冲突以原文为准。 | 在位 |
| `skills/task-discipline/references/execution-recall-card.md:44` | 恢复读序：`user-session-log→task_plan→progress→findings→knowledge-brief`。 | 读回门（文本） |
| `skills/task-planner/SKILL.md:137` | Rule 84.14 收尾六文档全量回读（mini/L0 缩为两文档）；「知识」维核对 knowledge_use purpose。 | 读回门（终验时） |
| `/home/terry/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/MEMORY.md` | 平台记忆索引，实测 **94071 字节**，收录上述判例条目。平台侧文件，不在 `skills/` 内。 | 在位（体量问题） |

### 2.3 上下文纠错 / 漂移检测

| 文件:行 | 做什么 | 状态 |
|---|---|---|
| `skills/task-planner/SKILL.md:29` | **每轮 Goal 锚**：「每次回答前（含工具调用后的续答）先复述当前任务 Goal 与 Requirements 首条用户原话（≤2 行）」；定位不到锚先读 plan-state/恢复包。 | 纯文本规则 |
| `skills/task-planner/SKILL.md` `[DRIFT CHECK]` 步骤（L125 附近） | 触发时机=Phase complete 后/连续 ≥3 次工具调用/切换模块前；留痕三件套缺一=未执行。 | 文本 + agent 派发 |
| `skills/context-corrector/SKILL.md:11-23` | T1 显式否定 / T2 自主矛盾两类触发判据。 | 在位 |
| `skills/context-corrector/SKILL.md:25-73` | SOP 六步：基线锚定→污染面枚举→处置三分→即时落盘→下游阻断→复验清零；Step 6 用 grep 核旧结论命中=0。 | 在位（SOP） |
| `skills/context-corrector/SKILL.md:88` | **非目标声明：「零新增机器守卫……未获用户授权，不新增脚本/hook/自测断言/registry 机器门」**。 | 明确无机器门 |
| `skills/task-drift-guard/SKILL.md:17-23` | 触发条件：连续 ≥3 次工具调用未回读计划 / Todo 完成 / 同问题 ≥2 次 / 10 分钟无产出等。 | 在位 |
| `skills/task-drift-guard/SKILL.md:54-81` | 比对判三态 ALIGNED/DRIFT/BLOCKED，只读不写。 | 在位 |
| `skills/task-drift-guard/SKILL.md:89-91` | task-planner 流程中检测由 `drift-checker` 伴随 agent 承载，本 skill 仅独立场景直用。 | 双载体 |
| `skills/task-discipline/references/critical-rules-discipline.md:380-390` | Rule 67：67.1 主动评估触发；67.2 **四信号自评**；67.3 PRESSURE 主动压缩；67.4 CONFUSED 会话交接；67.5 hook 节奏；67.6 env 开关。 | 在位（自评） |
| `skills/task-planner/scripts/zcode-posttooluse.sh:367-371` | 每 64.3 节奏发一行 `[context-pressure]` 提醒文本（可由 `TASK_PLANNER_CONTEXT_PRESSURE=off` 关闭）。 | 在位（只提醒，不测量） |

### 2.4 历史召回

| 文件:行 | 做什么 | 状态 |
|---|---|---|
| `skills/plan-history-recall/SKILL.md:4,11-15` | 跨任务挖 `plans/`（含 archive）+ git 历史；显式触发 / L1+ 规划期**建议**触发；L0-T/mini 不触发。 | 在位（按需） |
| `skills/plan-history-recall/SKILL.md:29-48` | 五步：INDEX/git log 双路候选 ≤8 → `history-miner` ≤3 并行挖掘 → 综合简报 ≤150 行 → 落盘。 | 在位 |
| `skills/plan-history-recall/SKILL.md:58-60` | 成本护栏硬数字（候选≤8 / 3×3 / 简报≤150 / 卡≤60）。 | 在位 |
| `skills/plan-history-recall/SKILL.md:75` | 派发执行体 `companion/agents/history-miner.md`（只读+卡落盘）。 | 在位 |
| `skills/task-planner/SKILL.md` 2.5b（L98） | 派发前 Read `knowledge-brief.md` §6 可用技能清单。 | 在位（消费点） |

### 2.5 检索排除

| 文件:行 | 做什么 | 状态 |
|---|---|---|
| `RETRIEVAL_EXCLUDE.md:3-4` | 定义「检索前先读清单」，要求每条写明可排除/必须纳入场景。 | 在位（文本） |
| `RETRIEVAL_EXCLUDE.md:8-10` | **唯一条目 = `trash/`**。 | 覆盖面极窄 |
| `skills/task-planner/SKILL.md:60,131` | Rule 112 文本引用（初始化阶段 + 终验阶段）。 | 在位（文本） |
| `skills/*/scripts/` 全域 | **零引用**（复现 V4）。 | 无机器消费 |

### 2.6 惰性加载（部分实现）

| 文件:行 | 做什么 | 状态 |
|---|---|---|
| `skills/task-planner/SKILL.md:21,56,63,68,...` | 大量「→ 详细步骤/表格/示例按需 Read `references/plan-workflow-details.md §xxx`」指针；`references` 不预铺。 | 在位（references 层惰性） |
| `skills/task-planner/SKILL.md`（**文件整体**） | 实测 **62139 字节 / 289 行**（超长行），本身无惰性：每次压缩全文注入。 | 入口层非惰性 |
| `skills/task-planner/references/plan-workflow-details.md` | 307 行细节，按需加载。 | 在位 |
| `skills/task-discipline/references/execution-recall-card.md` | 54 行摘要卡，正确方向但**只用于规则规范，不用于恢复包**。 | 在位（未接入恢复） |

---

## 3. 真实缺口（关键分析）

### G1 — 恢复包用 61KB 全文对抗压缩，方向错

**[ARCH]** `skills/task-planner/scripts/planctl.py:1082-1089`
- 原文: `# ⑤ 技能正文全文内联（不参与限幅）` / `lines.extend(body.splitlines())`；`cmd_recover` docstring `:996` 写得更直白：`--max-lines 只限「任务状态」块（默认 150）；技能正文不参与限幅（规则残缺比多占上下文更糟）。`
- 影响: 每次压缩恢复注入 ≈62.9KB（实测 `recover-skill` 输出 **62943 字节**；SKILL.md 本身 62139 字节），约 15k token。压缩刚腾出的窗口被立即回填，且优先挤掉的是本轮任务细节；这与「小模型短上下文友好」的项目支柱直接冲突。
- 置信度: **HIGH**（字节数实测、代码直读）。
- 分类: **机制存在但方向错**。

**[RISK]** `skills/task-planner/scripts/planctl.py:867,1014,1120`
- 原文: `RECOVER_SKILL_END = "【技能正文·结束】"   # 未见此标记=技能正文被平台截断，消费端须 Read 补全`；恢复纪律第③条同源。
- 影响: 代码自己承认 61KB 注入可能被平台截断。一旦截断，模型还要再 Read SKILL.md 补全，形成「压缩→全文注入→截断→再读全文」的膨胀闭环。
- 置信度: **HIGH**（注释与消费纪律双锚）。
- 分类: **机制存在但方向错**（自我承认的失效边界）。

**[INFO]** 裁决张力（平台记忆，非仓库文件）：
- `/home/terry/.zcode/cli/memories/.../task-v195-spec-recall-rule93.md:13`：`用户两方案：①每 N 轮重载技能文件（否决——全量重载复现上下文膨胀）`
- `/home/terry/.zcode/cli/memories/.../split-before-upgrade-small-steps.md:10`：`小模型在短上下文和长上下文区别巨大`、`prompt 只带路径+≤10 行摘要，禁贴全文`（:14）
- `/home/terry/.zcode/cli/memories/.../task-perf-tiers-20261124.md:14`：`hook 注入税（SessionStart 63KB、每次调用 0.1-0.35s）`
- 影响: 2026-10-21 用户已否决「周期性全量重载」，2026-11-24 又为「压缩后必须重新注入技能」实现了**全文**注入。目标（压缩后恢复技能语义）正当，手段（61KB 全文）与既有裁决/实测注入税冲突。注意：两条裁决语义不同（周期重载 vs 压缩后恢复），不能简单判为违背裁决；但**手段选择**绕过了用户同期采纳的摘要卡方案。
- 置信度: **HIGH**（一手记忆 + 实测字节）。
- 分类: **方向错**（非「违背裁决」的法律判断）。

### G2 — 写入门齐备、读回门薄弱（消费断裂）

**[DEBT]** `skills/task-planner/references/plan-workflow-details.md:131-132`
- 原文: `3f' 周期性会话记忆回顾……主进程重读会话记忆四载体……` / `3g 规范召回（Rule 93）……mini/L0 档豁免`。
- 影响: 读回是**人肉周期规则**（每 3 S-unit），且 mini/L0 显式豁免。长会话中最需要复位的恰恰是被判为轻量/长尾的任务；一旦疲劳或压缩，规则本身先被遗忘——恢复包里没有「上次消费了什么、还欠哪些未消费」这一字段。
- 置信度: **HIGH**（条款原文 + 豁免字面）。
- 分类: **机制存在但弱**。

**[INFO]** 历史结论独立坐实（平台记忆）：
- `/home/terry/.zcode/cli/memories/.../resource-utilization-consumption-anchor-20261123.md:14`：`核心一句话：写入门齐备、消费门空`
- 同文件 `:36`：`消费是认知行为，字符串门不可靠判定`；`:50`：「确保」判据在认知行为层不可机器证。
- 影响: 说明这不是新发现，而是 11-23 已确认、11-24 仍未解的结构性问题；且**不能用加 hook/机器门「根治」**——用户已否决该路径（同文件 :19）。
- 置信度: **HIGH**。
- 分类: **机制存在但弱 + 结构性上限**。

**[DEBT]** `skills/task-planner/SKILL.md:108`（knowledge_use 消费锚）
- 原文: `purpose 留空或缺失视为该采集未闭环，收尾回读门（84.14）逐条核对`。
- 影响: 消费点是「回填时声明去向」的字符串，平台记忆 `resource-utilization-consumption-anchor-20261123.md:36` 已承认「purpose 字段仍可写成『已用』而实际未用」。可审计 ≠ 已消费。
- 置信度: **HIGH**。
- 分类: **机制存在但弱**。

### G3 — 机制写了但从没执行 / 被吞 / 无机器消费

**[RISK]** `RETRIEVAL_EXCLUDE.md:8-10`（唯一条目 `trash/`）+ 复现 V4 零脚本引用
- 原文: `| \`trash/\` | 判废数据/媒体落选稿垃圾桶（Rule 100.6） |`
- 影响: 平台记忆 `resource-utilization-consumption-anchor-20261123.md:15` 已把它列为 `CL-05`：`RETRIEVAL_EXCLUDE 零脚本引用——用户刚建即成摆设活标本`。而且唯一排除项是 `trash/`，真正制造长会话噪音的 `plans/archive/`（数百目录）、`skills/task-planner/.backup/`（多层嵌套副本）、`tmp/worktrees/` 均不在清单内。
- 置信度: **HIGH**（零引用复现 + 记忆 CL-05 + 目录实测）。
- 分类: **机制架空 + 覆盖面错**。

**[RISK]** 平台记忆 `task-perf-tiers-20261124.md:13,26`
- 原文: `:13` `variant 反转吞掉 auto-tier 的 mini（产物丢 plan_tier: mini，④b/D10 双门失效）`；`:26` `他会话 opt-out 也从未部署`。
- 影响: auto-tier（自动降档以缩短上下文）曾长期不触发/未部署，属于「代码/文本在位但执行层为零」的判例；同文件 `:14` 另记 `Rule 96.7 文本完备但零执行层 Agent 计数`。这是用户任务点名的「修4 前从未触发」的实证。
- 置信度: **HIGH**（一手记忆，标注为历史判例而非当前状态；当前是否仍如此需运行时复核，本报告不下此断言）。
- 分类: **机制架空（历史）**。

**[DEBT]** `skills/task-planner/scripts/check-context-hygiene.sh:78-85`
- 原文: `echo "${PFX} 汇总: 严重项命中 → exit 2"` / `clean: 无退场建议`。
- 影响: 只输出建议并按退出码分级，**无自动压缩/折叠动作**；Rule 29 的 `context_hygiene_enforce` 默认为 `warn`（`skills/task-discipline/references/critical-rules-discipline.md:76`：``context_hygiene_enforce(enforce/warn/off,默认 warn)``）。等于检测器只报警不执行。
- 置信度: **HIGH**。
- 分类: **机制存在但无执行层**。

**[INFO]** `skills/context-corrector/SKILL.md:88`
- 原文: `零新增机器守卫：本技能为纯文本 SOP 条款档……未获用户授权，不新增脚本/hook/自测断言/registry 机器门。`
- 影响: 这是**合规的**设计选择（用户否决加门），不是缺陷本身；但它意味着上下文纠错完全依赖模型主动触发，长会话后段触发概率下降。
- 置信度: **HIGH**。
- 分类: **结构性上限（非缺陷）**。

### G4 — 运行时 token 预算：根本没实现

**[RISK]** `skills/task-planner/scripts/` + `skills/task-planner/SKILL.md`（严格零命中，复现 V3b）
- 原文（对照项）: `skills/task-planner/config.json:477` `"description": "Max chars of one dispatch prompt — small-model short-context budget..."`；`skills/task-planner/templates/subagent_dispatch.md:111` `## 9. 上下文预算(强制 — Rule 22.4 第 ⑨ 字段,小模型短上下文友好)`。
- 影响: 现有「预算」只管**单次派发 prompt 的字符数**，不管**主会话窗口已用多少**。没有 token 计数、没有水位百分比、没有阈值触发的自动摘要/截断、没有注入前后差额记录。长会话只能靠 Rule 67 四信号自评（轮数/行数/失败次数）与被动等平台压缩。
- 置信度: **HIGH**（零命中复现 + 命中项类型辨析；`subagent-fallback.sh:98` 的 `max_tokens:1` 是模型可用性 ping，不是预算门）。
- 分类: **根本没实现**。

**[INFO]** `skills/task-discipline/references/critical-rules-discipline.md:382,388`
- 原文: `:382` `三态裁决（assessment contract）：按四信号自评——① 距上次回顾的工具调用轮数；② 计划三文件行数与陈旧度……`；`:388` `hook 节奏承载（rhythm nudge 接线）……追加单行`。
- 影响: 已有正确的「主动评估」骨架，但输入信号全是**代理指标**（轮数、文件行数），不是窗口实占；hook 只发提醒文本（`zcode-posttooluse.sh:371`），不测量。
- 置信度: **HIGH**。
- 分类: **机制方向对、测量通道缺**。

### G5 — 压缩触发时机：被动恢复 + 主动「文件压缩」，无窗口水位管理

**[ARCH]** `skills/task-planner/scripts/zcode-sessionstart.sh:16-19` + `skills/task-discipline/references/critical-rules-discipline.md:384`
- 原文: hook 注释 `本 hook 每次上下文压缩后触发`；规则 `:384` `PRESSURE 主动压缩整理（compress-now，命中即执行）……当次执行——a) 跑 29.2 退场 SOP 三类动作（superseded 标记/≥5 条同主题折叠入 ## 压缩归档…）`。
- 影响: 「主动压缩」压的是 **findings/progress 文件行数**，不是上下文窗口内容；真正的窗口压缩只能等平台触发，随后靠 61KB 全文回填。缺少「窗口逼近阈值前，主动做一次结构化摘要并把摘要写回权威源」的环节。
- 置信度: **HIGH**。
- 分类: **机制存在但层级错配**（管文件，不管窗口）。

---

## 4. 与业界方案的差距及落地切入点（仅建议，不实现）

> 对齐业界常识：RAG/检索式召回、分层 memory（工作记忆/情节/语义）、摘要压缩（recursive summarization）、结构化状态（scratchpad）、可观测 token 预算。本仓最缺以下 3 项；切入点均选**已存在的脚本/文本**，遵守「文本优先铁律」与「用户否决新增 hook/机器门」的裁决。

### C1（最高优先）运行时上下文预算与可观测水位

- 差距: 业界把上下文当**可测量资源**（token 计数、占用阈值、超阈自动摘要）；本仓只有 prompt 字符预算与轮数代理指标（G4）。
- 切入点 1: `skills/task-planner/scripts/zcode-posttooluse.sh:367-371` —— 已有 `[context-pressure]` 单行注入，把「四信号自评」扩为「注入字节账本 + 阈值分级」；**不新增 hook**，复用现有通道。
- 切入点 2: `skills/task-planner/scripts/check-context-hygiene.sh:1-25,78-85` —— 已有行数扫描与 exit 0/1/2，扩展为「注入体量记账 + 分级摘要建议」；保持只读、不加强制门（默认 warn 语义不变）。
- 切入点 3: `skills/task-planner/scripts/planctl.py:1073-1078` —— 现有 `--max-lines` 只数行；可增加**字符/体量预算**参数（默认向后兼容），让「状态块」与「技能块」共用同一预算口径。
- 预期效果: 把「是否该压缩」从主观自评变为可复现数据，同时止住恢复包膨胀。

### C2 分层记忆 + 检索式召回，替代全文重注入

- 差距: 业界分层（热=少量结构化状态、温=摘要、冷=可检索档案），按需召回；本仓是「冷档案全量塞回热区」（G1）。
- 切入点 1: `skills/task-planner/scripts/planctl.py:1082-1089` —— 把「技能正文全文内联」改为「`execution-recall-card.md`（54 行）内联 + SKILL.md 路径按需 Read 指针」；这正是用户 2026-10-21 已采纳的摘要卡方案（`task-v195-spec-recall-rule93.md:13,16`），且能复用 93.3「压缩后第一动作读召回卡」的既有纪律（`plan-workflow-details.md:132`）。
- 切入点 2: `skills/task-planner/scripts/planctl.py:862-865` / `zcode-sessionstart.sh:29` —— `RECOVER_FIELDS` 增加「未消费项/上次召回」字段，把消费状态带入恢复包（补 G2）。
- 切入点 3: `RETRIEVAL_EXCLUDE.md:8-10` —— 扩表：把 `plans/archive/`、`skills/task-planner/.backup/`、`tmp/worktrees/` 按「可排除/必须纳入」条件登记（**纯文本增量**，零新脚本，符合用户否决加门的裁决）。
- **裁决提示**: 11-24 用户明确要求「每次压缩后必须重新注入当前技能」（`planctl.py:1110` 注释）。改为摘要卡属于**改变注入内容形态**，须先取得用户裁决；本报告不主张擅自替换。

### C3 消费闭环从「声明」升级为「可审计的残余风险清单」

- 差距: 业界用引用链/召回命中率度量知识是否被用；本仓 knowledge_use 只是字符串声明，且记忆已判定「认知行为不可机器证」（G2）。
- 切入点 1: `skills/task-planner/SKILL.md:108` + `skills/task-planner/references/plan-workflow-details.md:131` —— 在既有 3f'/84.14 条款内增加「未消费项显式点名 + 下轮消费点预约」，**不新增门**。
- 切入点 2: `skills/task-planner/scripts/planctl.py:1073-1078` —— 恢复包任务状态块尾部追加「上次未消费清单」，让每次压缩都把欠账带到新窗口（把断裂点从「记忆」变成「权威源字段」）。
- **诚实边界**: 平台记忆 `resource-utilization-consumption-anchor-20261123.md:36,50` 已确认无法用字符串门「确保」消费；本方案只能把「无声丢弃」变成「显式欠账 + 可追溯」，残余风险须如实列入验收口径，不得宣称根治。

---

## 5. 红线与不可建议项

依平台记忆 `agent-failure-ledger-20261123.md:12-16` 与 `task-perf-tiers-20261124.md:17`（用户 P0 裁决），本报告**明确不主张**：

1. 砍子代理委派门 / Rule 96.7 预算门（「子代理执行必要——绝不可砍」）。
2. 砍 CLI / planctl 工具或回退到纯 Markdown 编辑（「绝不可投毒回纯 Markdown 编辑」）。
3. 砍 SP-OS / OpenSpec 思考骨架，或动 `zcode-sp-inject.sh`（cli/config.json:41）。
4. 新增 hook、执行前预检、机器强制门（用户多次否决；`context-corrector/SKILL.md:88` 与记忆 `resource-utilization-consumption-anchor-20261123.md:19,36` 均按此执行）。
5. 以「优化」为名重写既有规则原文或扩大改动范围（文本优先铁律 / 写入最小化）。

所有切入点均落在**现有脚本的既有分支、现有文本条款的增量、现有配置字段**，不含删除/替换上述红线机制。

---

## 6. 验证记录（Grep 复现，2026-11-24）

| 编号 | 复现命令（在仓库根） | 结果 |
|---|---|---|
| V1 | `wc -c skills/task-planner/SKILL.md`；`python3 skills/task-planner/scripts/planctl.py recover-skill \| wc -c` | 62139 / 62943 字节 |
| V2 | `grep -n '技能正文不参与限幅\|技能正文全文内联\|无条件注入技能正文' skills/task-planner/scripts/planctl.py` | `:996 :1082 :2289` 三处命中 |
| V3a | `grep -rn -i 'token.*budget\|...' skills/` | 命中均为**派发 prompt 字符预算**（config.json:477 / subagent_dispatch.md:111）与 ping（subagent-fallback.sh:98），无会话级预算 |
| V3b | 同模式限定 `skills/task-planner/scripts/ skills/task-planner/SKILL.md` | **零命中** |
| V4 | `grep -rln 'RETRIEVAL_EXCLUDE' skills/*/scripts/` | **零命中** |
| V5 | `sed -n '131,132p' skills/task-planner/references/plan-workflow-details.md` | 3f'/3g 原文 + 两处 `mini/L0 档豁免` |
| V6 | `grep -n 'context-pressure\|CONTEXT_PRESSURE' skills/task-planner/scripts/zcode-posttooluse.sh` | `:15-16 :367-371` — 只注入提醒文本 |
| V7 | `grep -n 'context_hygiene_enforce' skills/task-discipline/references/critical-rules-discipline.md` | `:76` 默认 `warn` |
| V8 | `sed -n '29,46p' /home/terry/.zcode/cli/config.json` | SessionStart 双 hook 注册 |
| V9 | 平台记忆 `grep -n '写入门齐备、消费门空\|消费是认知行为' .../resource-utilization-consumption-anchor-20261123.md` | `:14 :36` 命中 |

> 所有「已实现但没生效 / 根本没实现 / 机制存在但方向错」的归类均基于上述一手复现；未复现的历史判例（auto-tier 曾未触发）已标注为「历史判例，当前运行时状态需另行复核」，不作当前状态断言。
