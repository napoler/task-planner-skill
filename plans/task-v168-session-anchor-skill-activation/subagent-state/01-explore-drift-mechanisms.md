# 01-explore-drift-mechanisms — 漂移/回顾/纠错机制现状清单与缺口分析

> task-v168 只读调研产出。仓库根 = `/mnt/data/dev/task-planner-skill/skills/task-planner/`（下称 SKILL_ROOT）。所有锚点已逐条复核；引用一律带 file:line。

## 0. Hook 挂载全景（config.json @ /home/terry/.zcode/cli/config.json)

| Event | matcher | 脚本 | timeout | 内部再调用 |
|---|---|---|---|---|
| SessionStart | — | zcode-sessionstart.sh（:config.json SessionStart） | 10 | `task-plan-init.cjs` 写哨兵 + `set-active-plan.sh gc`（zcode-sessionstart.sh:13,33） |
| PreToolUse | Write\|Edit\|Agent\|CreateWorkflow\|... | zcode-pretooluse.sh | 5 | Write/Edit → `check-scope.sh`（:18）+ `check-delegation.sh`（:40）+ `check-skill-modify.sh`（:57）+ scope 冲突 awk；Agent → `check-dispatch.sh pretool`（:77） |
| PostToolUse | 全部工具（无 matcher） | zcode-posttooluse.sh | 5 | 不调任何检查脚本；自带 5 档优先级注入（见 §2） |
| UserPromptSubmit | — | zcode-userpromptsubmit.sh | 5 | `resolve-plan-dir.sh`（:43）+ `attest-plan.sh --verify`（:65）+ `check-conflicts.sh --runtime`（:207） |

注册脚本 register-hooks-cj.ts（~/.zcode/skills/task-planner/scripts/register-hooks-cj.ts:113-152）是 Claude Code settings.local.json 的另一套 5-hook（含 Stop→check-complete.sh）；ZCode 运行位以 config.json hooks.events 四事件为准，两套并存。

## 1. 周期性回顾（Rule 65）现状

- **触发间隔**：每 N=8 次工具调用（`periodic_review_interval_calls` 默认 8；Rule 65.1，critical-rules.md:837）。
- **由谁触发**：**无人触发**。规则是"模型自觉"：唯一机器面 = `scripts/periodic-review.sh`（只读检测器）+ `selftest-periodic-review.sh`（静态守护条款/键/存在性，selftest-registry.tsv:61）。全仓 grep 证实：4 个 zcode hook 脚本无一调用 periodic-review.sh；引用点仅 SKILL.md:223(C39 合规行) 与 SKILL.md:362（摘要）。
- **Rule 67 归因段自证**（critical-rules.md:878）：「Rule 29.5 自述 hook 未接读取、**Rule 65 周期回顾亦未接 hook**——主动性能靠纯 LLM 自律不可靠」。
- **配置键死链**：`periodic_review_interval_calls` 与 `periodic_review_enforce` 的唯一读者是 selftest-periodic-review.sh:76-86（仅断言"键存在"），无任何运行时脚本读它们。
- **periodic-review.sh 实际行为**（header :1-7，检测体 :61-161）：只读，对 findings/progress 做启发式前后对照——
  1. findings 每条 `-`/`##` 行取前 20 字符为 keyword，在 progress 中 grep 该 keyword 且同行含"不/否/错误/失败/问题" → CRITICAL `CONCLUSION-CONTRADICTION`（:82-101）；
  2. 反向 progress→findings 同类 → WARNING `ASSUMPTION-CONTRADICTION`（:105-135）；
  3. Goal 前 5 个关键词在 progress 出现 0 次 → WARNING `GOAL-DRIFT`（:138-161）；
  4. 输出单行 JSON（:169-185），exit 0=无矛盾 / 1=有矛盾 / 2=参数错误。**无语义理解、无文件重读、无注入、无消费方**（其 JSON 无任何 hook 或终验 slide 消费）。
- **发现矛盾后强制动作**（Rule 65.4，critical-rules.md:850-853）：progress.md 标 `[corrected]` 条目（原结论+新结论+原因）→ 自动回到错误步骤重执行 → 报告用户。纯 LLM 行为面，无格式锚机检（`[corrected]` 无 selftest 断言）、无回滚隔离。
- **档位**（65.6，critical-rules.md:857）：`periodic_review_enforce` 默认 warn（config.json properties）；enforce="发现矛盾立即阻断"——但无 hook 消费 exit 1，enforce 档实际空转。

## 2. 偏移检查（drift）机制全景

- **主载体 = drift-checker 子代理**（Rule 61，critical-rules.md:743-752；agent 定义 companion/agents/drift-checker.md）。派发时机（Rule 15.1，:60-68）：每 2-3 个原生 todo / 切换模块前 / 连续 ≥3 次工具调用 / Phase complete 后 / 用户新指令 A/B/C 判定后。三态裁决 ALIGNED/DRIFT/BLOCKED（:70-71, 15.2）。
- **drift-checker agent 契约**（drift-checker.md:1-7 头, :16-19 硬约束, :22-29 SOP）：haiku-1 档、read+自身检查点唯一写、10min 预算、git status/diff 取证据、判定输入三锚（Goal 原文锚/progress 尾部动作锚/scope 锚，Rule 64.4，:36）。
- **check-drift.sh 定位 = 仅降级佐证**（critical-rules.md:751, 61.5；脚本自注 :20-22）：drift-checker 失败→读检查点→重试 1 次→仍失败才由主进程跑 `check-drift.sh`（只消费输出）并登记债务。平时"不与子代理双跑"（SKILL.md:188 C4）。其内容 = 5 项文本启发式（VC 覆盖/Phase 越级/Goal 词覆盖≥30%/scope 字符串匹配/同错误 ≥3 次 ERROR-LOOP，check-drift.sh:83-308）。
- **留痕三件套**（Rule 64.1，critical-rules.md:817）：① 检查点 `subagent-state/{seq}-drift-checker.md` ② ledger `drift_check` 事件（ledger-append.sh:30 VALID_EVENTS 含 drift_check）③ task_plan.md「🚨 Drift Log」表一行。**缺任一 = 本次检查视为未执行**。
- **机器门**（Rule 64.2，critical-rules.md:819；check-3file-gate.sh:251-282 第 6 条件）：Phase complete 窗口内必须存在 drift 痕迹（ledger `drift_check` 行优先 / `*-drift-checker.md` mtime 兜底 / `drift_exempt:` 声明 / `plan_tier: mini` 豁免），否则默认 exit 1。这是全 drift 体系唯一的硬拦截点——且只在"翻 Phase complete"时刻生效。
- **PostToolUse 每 N 次注入什么**（zcode-posttooluse.sh:334-366，Rule 64.3+67.5+73.4）：`.drift-rhythm/<sid>.state` 计数，每满 N=10 次工具调用（env `TASK_PLANNER_DRIFT_RHYTHM_N`）经 additionalContext 注入单行：
  - `[drift-rhythm] 距上次偏移检查已 ≥N 次工具调用：…按 Rule 15 派发 drift-checker 并按 Rule 64.1 留痕三件套`
  - `[context-pressure] 主动评估（Rule 67.2）…HEALTHY/PRESSURE/CONFUSED`（默认 on，env off 可关，:352-357）
  - `[judge] 变更型决策点评判（Rule 73.1/73.4）…留 [align]/[judge] 行`（默认 on，:360-362）
  - 均为**软提醒**（additionalContext 无拦截力，Rule 64.3 自述 :821 "拦截力由 64.2 承载"）。
- **历史执行率实证**（critical-rules.md:815）：task-v141~v145 共 25 Phase drift-check 执行率 **0%**（检查点 0、[DRIFT CHECK] 记录 0），v148 用户原话「防偏移这个东西非常容易（失效/被忽略）」「需要进行时刻记得纠正」。
- **执行率风险仍在**：61.5（751 行）明示同 Phase 连续 3 次降级→Rule 41 上报；但触发端（15.1 五个时机）仍无机器计数器，靠模型自觉。

## 3. 错误纠正机制现状

- **Rule 31 错误学习闭环触发条件**（31.1，critical-rules.md:322）：仅四类——① 用户指出产出/执行有误；② 同一问题用户重复反馈 ≥2 次；③ 用户执行中打断补充新数据推翻结论；④ `check-drift.sh` 输出 ERROR-LOOP（同错误同 Phase ≥3 次）。**"执行中工具报错/测试 FAIL"不在触发条件内**——且第 ④ 条依赖 check-drift.sh 被跑，而按 61.5「不双跑」原则正常流程不跑它，故该信号源在正常路径近乎死信。
- **执行中错误的实际兜底链**（无强制根因分析条款）：记账 = Rule 6 / 19.4（progress.md Error Log 立即写，critical-rules.md:115）；防重复 = Rule 7 三击协议 + 22.3 五档兜底（:23-24, :177-181）；换道 = 22.3.0 资料先行 / 22.3.0b（:178-179）；迭代测试结果每轮落盘 = Rule 57（:673-681，判定面=LLM 行为+selftest 静态）。**缺"工具报错/测试 FAIL → 立即 4 维根因分析"强制条款**。
- **Rule 33 reflect-verify**（critical-rules.md:340-349）：触发 = ① 问题解决动作完成后/标记完成前 ② bugfix 类每 Phase complete 前 ③ 计划声明 `reflect_verify: required` 时每 Phase。落盘 = progress.md 固定两行 `- [reflect] 反思:` / `- [reflect] 验证:`（:346）。机器面 = check-complete.sh REFLECT-GATE（:1213-1252）：**仅当计划声明 reflect_verify: required 才校验**（未声明=SKIPPED），且 `reflect_verify_enforce` 默认 warn（config.json properties）不阻断。
- **progress.md Error Log 字段**（templates/progress.md:42-47）：`| Timestamp | Error | Attempt | Resolution | Root Cause | Prevention |`；Root Cause=31.2 四问压缩版，Prevention 初写 `<待沉淀>` 占位。
- **check-complete.sh Learning Gate 校验什么**（:1103-1209）：Error Log 节数据行 **Root Cause 列非空且 != `<待沉淀>`**（:1169）；档位 env `TASK_PLANNER_ERROR_LOOP_ENFORCE` > config `error_loop_enforce` > warn（:1110-1118）；默认 warn=仅 stderr 告警计数不阻断（:1201-1203）；无表头/无 Error Log = PASS 静默（:1105）；L0 微变更通道整体跳（:1120-1125）。相邻门：goal-gate（66.3，:1402-1452，standard/full 硬校验 exit 1）、judge-gate（73.4，:1491-1516，默认 warn）、CR-GATE/LANE-L0 GATE（task-v167，:1077-1101, :1455-1489）。
- **结论**：错误纠正链 = 「用户指出才完整闭环（31.1→31.2→31.3→31.4→31.5）+ 机器只兜底 Root Cause 非空（warn 档）」；执行期机器可观察的错误信号（工具报错、测试 FAIL）无强制根因+纠正条款。

## 4. 治"长会话幻觉"的现有手段分层

| 机制 | 层 | 有 hook/机器校验？ |
|---|---|---|
| Rule 71 无源不写（critical-rules.md:943-957） | 流程 | 71.2 五问自检=纯 LLM；71.4 溯源审计 SOP=人工/子代理；机器面仅 selftest-source-anchor-discipline.sh 静态守护（71.7 自述「**不声称自动判幻觉**」:957） |
| Rule 43 证据铁律（:478-487） | 流程 | 43.4 自述「判定面=LLM 行为…**非机器触发**」；selftest-reliability-institution.sh 静态断言 |
| Rule 19 三文件落盘（:109-119） | 流程+机器 | 19.2 门控=check-3file-gate.sh 真机器门（exit 1）；19.1/19.4=流程 |
| Rule 73 [align]/[judge]（:983-997） | 流程+弱机器 | 留痕行=LLM；judge-gate 仅对照行数且默认 warn；73.7 自述「语义面不可静态机检」 |

**周期性重新注入用户原始指令的机制 = 只有 Rule 20 turn-start smart 注入一个渠道**：
- UserPromptSubmit hook **每个用户 prompt 提交轮**注入（zcode-userpromptsubmit.sh:84-162；无节流，节流只作用于 [plan-note] 备注 :164-202）。内容（20.4，critical-rules.md:127；脚本 :151-156）：`Goal` / `Next Step` / `Current Phase` / in_progress Phase 全文 / Decisions 末 3 行 / progress 尾 5 行，`===BEGIN-PLAN-DATA===/END===` 包裹标记为数据非指令（20.3 :126）。
- **三重收窄（缺口种子）**：
  1. **仅在用户发言轮注入**——长会话执行期（一次指令→几十次工具调用）中间不注入；
  2. **Goal 只取 `## Goal` 节第一个非空行**（zcode-userpromptsubmit.sh:113），多行 Goal 被截断；
  3. **注入字段集不含**：用户需求原文 R 条目（Rule 51.1）、「🔒 不变量声明区」（Rule 73.3，critical-rules.md:989）、notepad「🚫 被否决方案」段（Rule 32）、deprecated.md——即「用户最初指令」在上下文中只有原始那一轮，压缩/漂移后无任何回注通道。
- attest 校验（20.1：:124；hook :64-82）：SHA-256 不符→只注入 [PLAN TAMPERED] 并拒绝注入计划内容——防篡改，但不解决"原话丢失"。
- PostToolUse 全链路（zcode-posttooluse.sh:245-366）**没有任何一处重新注入用户指令/Goal**：优先级 1-4 只检 mtime 陈旧（plan 15min/findings 20min/progress 25min）+ todo 同步（每 10 次）；drift-rhythm/context-pressure/judge 三条也只是软提醒文案，无 Goal 原话载荷。

## 5. 缺口清单（按 P0/P1/P2，每条附证据）

### P0（直接导致两类实战缺陷的缺口）
1. **Rule 65 周期回顾无任何触发载体**：「每 8 次工具调用」无人计数——PostToolUse 只计数 drift-rhythm/todo-sync，4 个 hook 零调用 periodic-review.sh；`periodic_review_interval_calls`/`periodic_review_enforce` 仅被 selftest 断言键存在。证据：grep `periodic-review` 全仓引用仅 SKILL.md:223,362 + selftest；critical-rules.md:878（Rule 67 自证「未接 hook」）。→ 缺陷①「结论自相矛盾无人周期性发现」无机器面。
2. **执行期错误（工具报错/测试 FAIL）无强制根因+纠正条款**：Rule 31.1 四触发条件全为用户侧信号（critical-rules.md:322）；可机器观察的错误信号无任何条款/hook 挂钩；31.1④ 的 ERROR-LOOP 信源（check-drift.sh）按 61.5「不双跑」在正常路径不执行。→ 缺陷②「错误不能及时纠正」中"执行期机器可观察错误"这一最大面零覆盖。
3. **用户原始指令/不变量无周期性回注**：smart 注入仅 Goal 首行且只在用户发言轮（zcode-userpromptsubmit.sh:113,151）；R 条目原话、🔒 不变量声明区（critical-rules.md:989）、否决禁令段均不在任何注入字段集；PostToolUse 执行期零回注。→ 缺陷①「长会话忘记最初指令/主题漂移」直接根因。
4. **reflect-verify 默认不生效**：REFLECT-GATE 仅 `reflect_verify: required` 计划进入且默认 warn（check-complete.sh:1216-1226,1248-1252）；rule 33 触发①的"问题解决后"无留痕机检。→ 缺陷②「解决=解决得对」无门。
5. **Learning Gate/judge-gate/error_loop 默认 warn 均不阻断**：`error_loop_enforce=warn`（config.json properties）、Learning Gate warn 档仅 stderr（check-complete.sh:1201-1203）；judge-gate 默认 warn（:1501-1508）。机器"看见"违规但不"拦住"。

### P1（设计在位、实战软化）
6. **drift 提醒无拦截力且依赖 Phase 收口**：64.3 节奏提醒自述"软提醒不拦截"（critical-rules.md:821）；唯一硬门 64.2 在 Phase complete 时刻（check-3file-gate.sh:269-282）。长任务若跨 Phase 长跑（不翻 complete），「时刻纠正」仍靠自觉——v148 判例（25 Phase 执行率 0%）后加了提醒但未改软性质。
7. **drift-checker 派发触发无机器计数**：15.1 五时机全靠模型自觉（critical-rules.md:60-68）；61.4 只规定"防自触发"，无 hook 计数佐证已派发。
8. **67.1 高危信号档含"periodic-review 判 CONTRADICTION"（critical-rules.md:880）→ 信源死链**：65 无触发 → 67.1③ 永远不命中；连锁压制上下文压力主动评估的有效信号面。
29.2/29.3 压缩 SOP 依赖的 check-context-hygiene.sh 亦 hook 未接（29.5 自述流程层，critical-rules.md:305；67.3 命中才手动跑）。
9. **periodic-review.sh 输出无消费方**：JSON 报告（脚本:169-185）无 hook/终验读取；启发式粗糙（keyword 前 20 字符+否定词，:82-101）双高误报漏报，且作为 67.2 信号④ 被引用而无人产。
10. **smart 注入 Goal 单行截断**：多行 Goal 仅首行进上下文（zcode-userpromptsubmit.sh:113）；progress 尾 5 行若为机械记账，注入复诵含金量低。
11. **UserPromptSubmit 对完结/超 24h 计划零注入**（zcode-userpromptsubmit.sh:52,55）——跨天长会话 Goal 复诵也停。

### P2（粗糙但可接受/后续项）
12. check-drift.sh 文本启发式（GOAL-DRIFT 30% 阈值、scope 字符串匹配、VC grep 覆盖）语义粗；定位=降级佐证可接受（critical-rules.md:751）。
13. Rule 65.4「自动回到错误步骤重执行」无机器承载与越界防护；`[corrected]` 格式无 selftest 锚（仅 selftest-periodic-review.sh 守 65.1-65.5 文本锚）。
14. drift-rhythm/context-pressure/judge 三条提醒同轮合并、单轮单 JSON（:363）——载荷密度高但每条均为软文案，无状态检查。

## 6. 对 task-v168 的设计输入（结论）

两类缺陷的机器面病灶同源：**执行期（turn 内）没有任何周期信号把"Goal/用户原始指令/近期结论"重新呈现给主进程，也没有任何机器面消费"矛盾/错误"信号**。现有可复用资产：drift-rhythm 计数状态机（zcode-posttooluse.sh:70-113，O(1) 三键）、check-3file-gate.sh 第 6 条件范式（ledger 语义信号）、ledger-append.sh 事件枚举（含 drift_check）、UserPromptSubmit smart 注入 awk 字段提取、templates/session-handoff.md 交接载体（67.4 引用）。建议新机制优先挂 PostToolUse 计数 + UserPromptSubmit 字段扩展 + ledger/终验消费三点，零新 config 键（沿 Rule 64.6/67.6 env 降档范式）。
