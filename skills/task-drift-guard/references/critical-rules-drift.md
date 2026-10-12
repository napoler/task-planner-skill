# Critical Rules — task-drift-guard（漂移检测与偏移留痕）

> 域=漂移检测与偏移留痕。
> 本文件为 task-drift-guard 卫星技能规则全文，从核心 task-planner `skills/task-planner/references/critical-rules.md` 逐字迁移（标题统一为 `### N 标题`，正文一字未改）；源行区间以 `plans/task-v171-skill-specialization/design-architecture.md` §1 七卫星表（task-drift-guard 行）为准。
> 本批次（task-v171 S30）落盘 4 条：Rule 11,15,61,64。
> 源文件核心 critical-rules.md 原文本批次不删（删除见后续 Phase 删除基线执行，Rule 36.3）。

### 11 漂移检测（周期性）
每个 phase 标记 complete 后、连续 ≥3 次工具调用后、切模块前，调用：
```
派发 `drift-checker` 子代理偏移检查（Rule 61 载体）
```
- ✅ ALIGNED → 继续执行
- ⚠️ DRIFT → 记录到 progress.md，继续但警觉
- 🔴 BLOCKED → STOP，报告用户，等决策

`drift-checker` 是只读检测执行体，不做任何文件写入；发现偏差后输出结构化报告并等待用户决策。

### 15 高频漂移纠正强制（P0）
每完成 2-3 个原生 todo 后必须派发 `drift-checker` 子代理偏移检查（haiku-1 档,主上下文零占用；2026-09-27 task-v091/A-3: 原为 skill 调用唯一载体,`check-drift.sh` 降为可选佐证不双跑；2026-10-08 task-v146/Rule 61: 载体切换为子代理派发——ALIGNED/DRIFT/BLOCKED 三态契约零改动）。纠正条目入 todo：⚠️ DRIFT → 自动追加 `[drift-fix]` 条目；🔴 BLOCKED → 立即 STOP 不自动入 todo,必须报告用户等决策。Phase 级 Rule 11 仍生效,作为粗粒度兜底。**问题背景（task-v095 P6-S2 内敛自 SKILL.md §「高频漂移纠正」段）**：任务执行中上下文变长,主进程视野变窄,容易偏离原计划（改错文件/跳过 VC/做计划外的事）；Phase 级漂移检测太粗,问题累积到 Phase 完成才暴露已晚——详见下方 15.1-15.3。

15.1 **触发时机表（强制密度）**:执行过程中,以下任一条件命中立即派发 `drift-checker` 子代理（haiku-1 档,Rule 61 载体）：

| 触发时机 | 说明 |
|---------|------|
| **每完成 2-3 个原生 todo 条目后** | 最高频,2-3 步内发现问题 |
| **切换模块/文件前** | 确认未越界 |
| **连续 ≥3 次工具调用后** | 防止连续跑偏 |
| **Phase 标记 complete 后** | Phase 级门控（已存在 Rule 11） |
| **用户发出新指令时** | A/B/C 判定后做漂移检查 |

15.2 **纠正条目自动入 Todo**:drift-checker 判定 → 动作对照：✅ ALIGNED 不入 todo,继续；⚠️ DRIFT **自动追加 todo 条目** `[drift-fix] {问题描述}`（activeForm: 纠正漂移）,用户决策后执行；🔴 BLOCKED **立即 STOP**,**不自动入 todo**（避免静默改向）,必须报告用户等决策。

15.3 **为什么高频 / 与 Rule 11 的关系**:Phase 级漂移检测（Rule 11）粗粒度,问题累积数小时才暴露；todo 级纠正（Rule 15）细粒度,2-3 步内发现,代价小；`drift-checker` 是 haiku-1 档子代理,token 便宜,可高频跑且主上下文零占用（Rule 61）；两者并存——Phase 完成 = 粗粒度兜底,todo 完成 = 细粒度主控。

- **15.4 子代理载体（Rule 61 — task-v146）**：15.1 触发点的检查动作由 `drift-checker` 子代理承载（61.1-61.3 契约），主进程不亲自读计划文件做偏移比对；本条触发时机、三态判定与处置链均不变（载体切换≠语义变更）

### 61 偏移检查子代理化（上下文防爆炸 — task-v146）

> 结果级需求：偏移检查不得污染主上下文（用户 2026-10-08：「检查偏移…放入到子代理中检查…保持上下文干净…规避上下文爆炸」）。

- **61.1 载体强制**：Rule 15.1 全部触发点的偏移检查一律派发 `drift-checker` 伴随 agent（haiku-1 档）在子代理隔离上下文执行（SKILL 路由表「漂移检测」行同步）；主进程禁止为偏移比对 Read task_plan.md 全文或收集 git diff 大输出；主进程只消费单行判定 + 检查点指针
- **61.2 派发契约**：按 Rule 22.4 九字段模板派发，增补 drift 专用四字段=用户目标原话（≤200 字）+当前 Phase/S-unit 一行+近期动作摘要（≤5 行）+触发点类型；prompt ≤3000 字符（21.1b 沿用）；检查点=`<plan-dir>/subagent-state/{seq}-drift-checker.md`（22.8 命名沿用）
- **61.3 产出契约**：drift-checker 只读仓库（唯一写权限=自身检查点）；检查点含判定+证据+建议；返回单行 status: `ALIGNED|DRIFT|BLOCKED` + evidence=检查点绝对路径；三态语义与处置链（15.2 追加 [drift-fix] / BLOCKED→STOP）不变；`task-drift-guard` skill 保留为交互/独立场景载体（双载体三态一致，selftest 守护）
- **61.4 防自触发**：偏移检查的派发与回收不计入「连续 ≥3 次工具调用」累计；每次检查完成后计数清零（检查即新基线），防高频检查自我触发死循环
- **61.5 失败兜底**：drift-checker 失败/超时 → 先 Read 检查点（22.8.4）→ 重试 1 次 → 仍失败降级主进程跑 `check-drift.sh`（只消费脚本输出，禁读计划全文）并登记债务；同 Phase 连续 3 次降级 → 按 Rule 41 评估上报
- **61.6 机制**：零新 config 键；`selftest-drift-check-subagent.sh` 静态守护（六处载体锚+负断言+三态一致+覆盖矩阵行+hook 文案）；SKILL.md 路由表/合规清单 C4/References 同步措辞；锚定级联护栏=索引括注扩展头部 `Rules 1-39` 不动

<!-- Rule 64 (task-v148 2026-10-08): 纯增量新增；判例=task-v141~v145 共 25 Phase drift-check 执行率 0%（软触发不可靠实证）；用户 2026-10-08 裁决「防偏移容易失效，需要时刻记得纠正」 -->

### 64 偏移检查留痕强制与节奏化触发纪律（P0, 2026-10-08 task-v148，目标：drift-check 从「软触发靠自觉」升级为「留痕可查+门控强制+节奏提醒」三层机械闭环，根除「条款在位执行率 0%」缺陷；判定面=LLM 行为+check-3file-gate 第三条件+posttooluse 注入+selftest 静态与行为双断言、零新 config 键；衔接 Rule 11/15/19.2/61，既有条款原文零改动）

本条源于用户 2026-10-08 反馈原话（逐字抄录于 plans/task-v148-drift-enforce/task_plan.md「🎯 用户需求原文」，51.1 口径）：「对防偏移进行加强」；「在当前我发现执行任务的时候，真的是防偏移这个东西非常容易（口语截断，语境=容易失效/被忽略）」；「需要进行时刻记得纠正」。归因（实证）：task-v141~v145 共 25 Phase drift-check 执行率 0%（drift-checker 检查点 0 个、[DRIFT CHECK] 记录 0 处）；机制面 18 项中 16 项软性——触发靠模型记得、判定结果无机器消费通道、selftest 只守措辞不守执行行为。载体（Rule 61）与触发时机（15.1）在位但无执行证据链 = 条款死文。

64.1 **留痕三件套强制（execution evidence chain）**：每次合规 drift-checker 派发返回后（无论 verdict=ALIGNED/DRIFT/BLOCKED），主进程 30s 内完成三痕迹：① 检查点 `<plan-dir>/subagent-state/{seq}-drift-checker.md`（61.2 契约既有）② 工作账本事件 `bash <skill>/scripts/ledger-append.sh <plan-dir> drift_check "<verdict>+一句话结论" --phase N`（64.5 枚举增补）③ task_plan.md「🚨 Drift Log」表追加一行（时间/结果/涉及VC/结论）。三痕迹缺任一 = 本次偏移检查视为未执行（64.2 门控按未执行处理；豁免/降档使用须 progress.md 记一行理由，44.3 五要素精神）。What=执行必留机器可查证据；Why=0% 执行率直接成因是无痕迹要求——「做没做过」无任何下游可核查，软条款退化为死文；三痕迹全部复用既有载体（检查点/ledger/Drift Log 表）零新增面。

64.2 **Phase complete 第三条件门控（machine gate）**：`check-3file-gate.sh` 在 19.2 既有双条件与 60.5 kb 条件之后追加第 6 条件——标记 complete 的 Phase 时间窗（progress.md 该 Phase `Started:` 时间戳锚；锚缺失退化既有 stale 阈值锚）内必须存在 ≥1 条 drift_check 痕迹（ledger `event="drift_check"` 行优先，`<plan-dir>/subagent-state/*-drift-checker.md` 检查点 mtime 兜底）；缺失 → 默认 exit 1 禁止翻转 complete。豁免（满足其一）：(a) task_plan.md 声明行 `drift_exempt: <Phase 清单>`（纯簿记/纯调研/纯交接 Phase 逐个列出）；(b) `plan_tier: mini` 任务整体豁免（38.3 同口径）；(c) env `TASK_PLANNER_DRIFT_ENFORCE=warn`（stderr 提示不阻断）`|off`（跳过）——降档/豁免使用须 progress.md 记一行。What=没留痕就不许翻 complete；Why=「时刻纠正」的收口兜底——即使 64.3 提醒被忽略，Phase 收口处机器强制必查（19.2 同族先例：3-File 门从软要求升硬门后执行率归一）；默认 enforce 对齐 51 R-COVERAGE/59.1 硬门先例，三档豁免保轻任务零增负。

64.3 **节奏化提醒（rhythm nudge——「时刻」载体）**：`zcode-posttooluse.sh` 在存在有效活跃计划（会话 side 指针解析出 plan-dir）时维护会话级计数状态 `<plans>/.drift-rhythm/<sidkey>.state`（三键 `{count, last_inject, due}`，due=待投递标志——分支命中轮延迟投递的持久位；fail-open：目录不可写/解析失败即静默跳过），每满 N=10 次工具调用（env `TASK_PLANNER_DRIFT_RHYTHM_N` 可覆盖）经既有 additionalContext 通道注入单行提醒 `[drift-rhythm] 距上次偏移检查已 ≥N 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套` 并重置计数（last_inject=count）。注入=软提醒不拦截（PostToolUse additionalContext 无拦截力是平台事实），拦截力由 64.2 承载——两层分工：64.3 管「时刻」（高频可见性），64.2 管「必查」（收口强制）。性能约束：状态文件三键读写 O(1)+指针解析复用既有函数，禁止全仓扫描或大文件解析。

64.4 **判定输入契约（anti-vacuous-ALIGNED）**：drift-checker 任务书（61.2 派发契约之上）必须内嵌三锚输入：① Goal 原文锚（task_plan.md Goal 段绝对路径+行锚，或 ≤3 行原文摘录）② 最近动作清单锚（progress.md 尾部 N 行路径锚）③ scope 文件集锚（执行范围表路径）；agent 侧判定必须逐锚引用证据写检查点（对照结论可复核），无证据锚的 ALIGNED 判定无效 = 按 64.1 未执行处理。配套：drift-checker agent 定义增补判定输入要求段（纯增量 ≤3 行，部署位随 Phase 5 同步）。What=判定必须可复核；Why=历史偏移案例（task-v075/v095/v096）多发生在「未对照 Goal 的自由执行」，无输入锚的检查=形式过场，三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。

64.5 **机制守护（mechanism guard）**：机器面五接线——`ledger-append.sh` VALID_EVENTS 增 `drift_check` 枚举（值尾追加，锚行随实现漂移以 grep VALID_EVENTS 为准，既有枚举零改动）；`check-3file-gate.sh` 追加第 6 条件段（既有条件 1-5 语义零改动）；`zcode-posttooluse.sh` 追加计数段（复用既有 additionalContext 注入 helper）；`companion/agents/drift-checker.md` 判定输入段；SKILL.md 接线 2 处（Phase 循环第 6 步 [DRIFT CHECK] 块内追加 64.1 留痕行 + 合规清单 C4 行末追加留痕句——DCS-01~20 字面锚零触碰）。守护面=`scripts/selftest-drift-enforcement.sh`（静态断言+行为级 fixture（DCE-01~23，随守护面演进），fixture 范式对照 selftest-four-file-dataflow.sh）+ selftest-registry.tsv 登记。What=每处接线挂既有管线+静态与行为双断言；Why=53.2 根治判据=机制·守卫·载体三件齐，条款无挂点=死文（59.6 同范式）；行为 fixture 防「守措辞不守行为」错位复发（根因③）。

64.6 **零新 config 键与既有 Rules 关系**：不新增任何 config.json 键——降档与调参走 env（`TASK_PLANNER_DRIFT_ENFORCE` / `TASK_PLANNER_DRIFT_RHYTHM_N`），豁免走计划声明行 `drift_exempt`（59.7/43.4/44.4 同范式：键膨胀=配置面失控面）。关系：Rule 11/15 触发时机与三态判定原文零改动（本条只加证据链与节奏）；Rule 61 载体契约零改动（64.4 只加输入要求）；Rule 19.2 门控=第三条件追加非改写；Rule 62 四文件流转正交；SKILL.md 上界计数措辞（「1-62」等）本次不动（63 未落地避免计数失真，v146 同款遗留延续）。

