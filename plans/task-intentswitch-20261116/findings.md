# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- **R1 [目标]**（plans/task-intentswitch-20261116/user-session-log.md#1, 2026-11-16）：会话执行计划 A 期间若用户提出与 A 无关的新需求 B（前说 A 现改说 B），应**主动**挂起 A、激活新计划执行 B，实现任务隔离——不同任务混同一计划产生不必要负担。
- **痛点**：该能力此前已存在但实际使用中「不是很明显」——需诊断「不明显」根因后强化意图识别与切换显性度。
- **范围**：增强既有机制，非从零新建；实现面限 skills/** 等受管载体（本轮产出诊断与增强计划，实际改动留执行期 worktree）。
- **活体样本**：本指令本身即 A→B 切换触发点（前任务 task-veriffirst-20261116 已 COMPLETE/fc37133，本指令已按 Rule 102.0 D 类处置建本计划目录）。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| task-planner SKILL.md 新指令处理/DRIFT CHECK | skills/task-planner/SKILL.md:122,188-201 | 已消费 | Research Findings 机制全景 M1-M4,M11；H1/H2/H3/H4 |
| task-discipline Rule 8/8.1/8.1.1 | skills/task-discipline/references/critical-rules-discipline.md:18-23 | 已消费 | 机制全景 M5-M6；H1/H2 |
| task-discipline Rule 94 | skills/task-discipline/references/critical-rules-discipline.md:607-618 | 已消费 | 机制全景 M7；H2/H3/H6 |
| task-discipline Rule 102 | skills/task-discipline/references/critical-rules-discipline.md:695-706 | 已消费 | 机制全景 M8；H1/H2/H5/H6 |
| task-drift-guard Rule 11/15/61/64 | /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:8-68 | 已消费 | 机制全景 M9-M10；H4 |
| plan-resume SKILL.md | /home/terry/.zcode/skills/plan-resume/SKILL.md:1-80,33,65-69 | 已消费 | 机制全景 M12；H2/H3 |
| UPS hook [plan-note] | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:283,285,287 | 已消费 | 机制全景 M13；H1/H5 |
| skill-collaboration 初筛 | skills/plan-collab-router/references/skill-collaboration.md:1-60 | 已消费 | 机制全景 M14（无意图切换专条） |

## Research Findings

### 现有机制全景表（条款→载体→文件:行号→覆盖场景）

| # | 条款/机制 | 载体 | 文件:行号 | 覆盖场景 | 性质 |
|---|-----------|------|-----------|----------|------|
| M1 | 新指令统一收口序列（单入口定序）：①逐字落盘 user-session-log→②D/A/B/C/E 判定→③计划文档同步→④Todo S5→⑤103.6；A 类仅①②+登记；顺序不可倒置禁拆散 | skills/task-planner/SKILL.md | skills/task-planner/SKILL.md:190 | 所有新指令入口顺序 | LLM 行为门（文本流程） |
| M2 | D/A/B/C 判定表：D=与 Goal/范围/交付物均无关联→开新计划 init 全流程、旧计划原样保留、禁混入；B 扩展先重规划；C 矛盾停止写入对比确认；A 无影响照常 | skills/task-planner/SKILL.md | skills/task-planner/SKILL.md:192-197 | 任务边界/扩展/矛盾/无关分类 | LLM 行为门 |
| M3 | 判定顺序先 D 再 A/B/C；仅活跃计划适用 D；稳定性铁律「禁止口头接受新指令、计划与 Todo 不动」；错误先 STOP 走 31.2 | skills/task-planner/SKILL.md | skills/task-planner/SKILL.md:199 | 分流与落盘义务 | LLM 行为门 |
| M4 | 目标切换判定 E 类（P0）：三可判定触发①新站点/域名/平台与 Goal 零交集 ②指示词+新对象词与 Goal 零交集 ③宾语变更→禁止自行归类 D/A/B/C，须复述+等显式 yes；确认后按 Rule 94（94.3 可与确认合并：新开计划隔离推荐/并入重规划/暂挂） | skills/task-planner/SKILL.md | skills/task-planner/SKILL.md:201 | 用户换目标域显性确认门 | LLM 行为门（P0） |
| M5 | Rule 8.1 新任务边界 D 类：D 先于 A/B/C；三要素均无关联→D；处置①禁混入 ②开新计划 init ③旧计划原样保留 ④落 notepad+Decisions；仅活跃计划适用 | skills/task-discipline/references/critical-rules-discipline.md | skills/task-discipline/references/critical-rules-discipline.md:21 | D 类判定细则与处置载体 | LLM 行为门 |
| M6 | Rule 8.1.1 目标切换可判定触发：D 前先过三判，任一命中=scope 扩张→禁止自行归类 D 开新计划，须复述+等显式 yes | skills/task-discipline/references/critical-rules-discipline.md | skills/task-discipline/references/critical-rules-discipline.md:23 | 含糊指令擅自换目标防线 | LLM 行为门 |
| M7 | Rule 94 任务专注性与计划隔离：94.1 单计划单垂直域；94.2 重大偏差判据（目标实体/交付物变更/BLOCKED 或连续两次 DRIFT 指向他域）；94.3 主动询问拆分（silent 默认隔离+登记）；94.4 隔离处置（旧计划封存待 plan-resume/新目标独立 init/跨计划禁交叉写入/混写补救）；94.7 范围扩张确认门 | skills/task-discipline/references/critical-rules-discipline.md | skills/task-discipline/references/critical-rules-discipline.md:607-618 | 跨计划级偏差「确认后怎么拆怎么隔离」处置动作 | LLM 行为门（文本纪律） |
| M8 | Rule 102 新请求计划同步与反思门：102.0 反思门五问（含⑤对照 user-session-log 既有原话/已裁决 Rule 80.8②）+B/C/D/E 先落盘后执行；102.1 五类+D 打断接续（断点检查点/顺序执行/挂起 deferred）；102.1e 取消；102.2 落盘后自检行 `本指令→类→改动文档`；102.3 痕迹累积；102.4 hook 逐 prompt 承载 | skills/task-discipline/references/critical-rules-discipline.md | skills/task-discipline/references/critical-rules-discipline.md:695-706 | 新指令执行闭环（判定→文档同步→落盘后执行） | LLM 行为门 + hook 提示 |
| M9 | Rule 64 偏移留痕与目标漂移拦截：64.1 三件套；64.2 Phase complete 门控；64.2.1 目标漂移不可豁免（Goal 与 user-session-log 最近原话零交集）；64.4 四锚输入含④用户原话对照锚；64.7 专档缺失/空/零交集→ALIGNED 无效并 BLOCKED | /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md | /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:51-68 | 执行期偏移证据与目标漂移安全网 | LLM 行为门 + 部分脚本/hook 机制 |
| M10 | Rule 11/15/61 漂移检测：drift-checker 子代理只读 ALIGNED/DRIFT/BLOCKED；触发含「用户新指令时」但语义为执行偏移比对；主进程不读计划全文 | /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md | /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:8-47 | 计划内执行偏移检测（非意图切换发起） | 子代理 + 流程门 |
| M11 | DRIFT CHECK 步骤顺序：用户新指令时先过「用户新指令处理」判定再派 drift-checker；留痕三件套缺一=未执行 | skills/task-planner/SKILL.md | skills/task-planner/SKILL.md:122 | 新指令触发点与偏移检查衔接顺序 | 流程文本 |
| M12 | plan-resume：中断/过期计划扫描与续推；恢复触发点自主选 Top 1 续推；旧计划封存待 resume；执行中被动扫描只报告 | /home/terry/.zcode/skills/plan-resume/SKILL.md | /home/terry/.zcode/skills/plan-resume/SKILL.md:1-80,33,65-69 | 旧计划挂起后的恢复入口（非切换发起者） | 技能流程 |
| M13 | UPS hook [plan-note] 逐 prompt 提示：:283 取消/E 类同步；:285 邻近引用→B 类；:287 默认「先做反思门 Rule 102.0」+D 类开新计划+断点检查点+不相干内容禁混入+对照 user-session-log 既有条目(80.8②)；无快速 Goal↔最新原话零交集锚句、无显性通告模板 | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:283,285,287 | 每 prompt 反思提示（机制面唯一 hook 助推，仅提示不强制） | hook 机制 |
| M14 | skill-collaboration 初筛：复杂度主轴 comet/OpenSpec/superpowers 路由；无「会话中用户意图变更 A→B 切换」专用分流条款 | skills/plan-collab-router/references/skill-collaboration.md | skills/plan-collab-router/references/skill-collaboration.md:1-60 | 协同路由，不覆盖意图切换场景 | 不覆盖 |
| M15 | 留痕载体现状：user-session-log（逐字+镜像+80.8 消费点）、Decisions/notepad/progress、旧计划保留待 resume；无标准化「意图切换登记」区块或独立切换日志（旧→新ID/触发锚/判定类/确认方式/时间） | 计划模板与既有约定 | plans/task-intentswitch-20261116/user-session-log.md（消费点表）；skills/task-planner/SKILL.md:194；skills/task-discipline/references/critical-rules-discipline.md:703 | 切换痕迹分散，事后审计需拼凑 | 载体缺口 |

### 关键证据摘录
- **SKILL.md:190**「新指令统一收口序列…①逐字落盘→②D/A/B/C/E 判定→③文档同步→④Todo S5→⑤103.6…顺序不可倒置…禁拆散单做」。
- **SKILL.md:194** D：「开新计划 `plans/{new-task-id}/`（init 全流程）；旧计划原样保留…判定落 notepad+Decisions；禁混入当前计划」。
- **SKILL.md:201** E 类：「目标切换…→禁止自行归类为 D/A/B/C 并执行，必须先复述解读 + 等用户显式 yes…确认后按 Rule 94…94.3 询问门可与本类确认合并为一次询问（新开计划隔离执行（推荐）/并入当前计划重规划/暂挂）」。
- **discipline:21 (Rule 8.1)**「D 先于 A/B/C…处置①禁混入 ②开新计划 init 全流程 ③旧计划原样保留 ④落 notepad+Decisions」。
- **discipline:23 (Rule 8.1.1)**「D 类判定前必须先过目标切换三判…任一命中=scope 扩张→禁止自行归类 D 类开新计划，必须先复述解读+等用户显式 yes」。
- **discipline:614 (Rule 94.3)**「禁止默默并入…也禁止未经询问自行开新计划——必须主动询问用户…silent 档…默认按『新开计划隔离执行』处置并在 silent 决策清单登记三判结果」。
- **discipline:615 (Rule 94.4)**「旧计划原样封存…待 plan-resume；新目标独立建计划 init 全流程；跨计划禁交叉写入；混写补救」。
- **discipline:700 (Rule 102.0)** 反思门五问含⑤「与专档既有原话是否冲突/已被裁决——对照 user-session-log.md…Rule 80.8②」；B/C/D/E 先落盘后执行。
- **discipline:701 (Rule 102.1)** D 子场景打断接续：断点检查点落盘→B 入计划→顺序执行义务（在途单元做完或显式挂起 deferred），禁止 A 执行一半 B 直接开做。
- **discipline:703 (Rule 102.2)** 落盘后自检行 `本指令→<类>→改动文档: <文件:行>×N→执行入口`。
- **UPS hook :287**「[plan-note] 新指令到达 — 先做反思门(Rule 102.0)… D 新任务边界→开新计划目录+旧任务断点检查点… 不相干内容禁止混入当前计划(Rule 8.1)。新指令到达时先对照专档(user-session-log.md)既有条目…」。
- **drift-guard:59 (Rule 64.2.1)**「目标漂移=Goal 与 user-session-log.md 最近用户原话零交集…目标漂移检查的豁免须用户显式裁决」。
- **drift-guard:63 (Rule 64.4)** 第四锚「④ 用户原话对照锚（user-session-log.md 最近含目标/指令类内容条目号+一句话摘要）」。
- **drift-guard:68 (Rule 64.7)** 专档空/零交集时 ALIGNED 无效并叠加 🔴BLOCKED 升级用户。
- **plan-resume:33,65-69** 恢复触发点自主选 Top 1 续推至交付/执行中只报告；承担旧计划恢复而非切换发起。

## H1-H6 诊断结论（逐条：结论 + 证据）

### 结论速览（V-1.1 判据形态）
| 假设 | 结论 |
|------|------|
| H1 | verified（触发面弱=主因） |
| H2 | verified（流程面散=主因） |
| H3 | partially verified（感知面弱） |
| H4 | verified（边界混淆） |
| H5 | partially verified（hook 锚句缺） |
| H6 | verified（登记载体缺） |

### 详表（结论 + 证据 + 诊断）

| 假设 | 结论 | 证据（路径:行号） | 诊断 |
|------|------|-------------------|------|
| H1：D 类/E 类判定全是模型行为门，默认惯性走 A 类导致切换不触发 | **verified** | skills/task-planner/SKILL.md:190-201；skills/task-discipline/references/critical-rules-discipline.md:21,23,607-618,695-706（判定/处置均 LLM 行为门+文本纪律）；/home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:283,285,287（仅 [plan-note] 提示，无机器判定/拦截） | 判定依赖模型每轮自觉执行 102.0 五问并分流；长上下文与任务惯性易吸收为 A 类。hook 只提醒不校验，无法阻止误判后继续执行。 |
| H2：切换动作清单分散在 Rule 94/102/E 类/plan-resume 多处，无单入口定序 | **verified** | skills/task-planner/SKILL.md:190（序列）+ :194(D表) + :201(E 类确认后按94)；skills/task-discipline/references/critical-rules-discipline.md:21(8.1),614-615(94.3-94.4),700-703(102.0-102.2/D 子场景)；/home/terry/.zcode/skills/plan-resume/SKILL.md:33,65-69（恢复语义） | 单入口序列存在但 D 类具体步骤需跨 4+ 载体拼合，缺「切换执行清单」逐步 checklist 与统一显性收口点，易漏断点登记/挂起状态/通告/留痕。 |
| H3：切换发生时对用户无显性通告环节（会话面无感） | **partially verified** | skills/task-planner/SKILL.md:201；skills/task-discipline/references/critical-rules-discipline.md:614（E 类/94.3 有复述+询问；silent 默认隔离但仅登记 silent 决策清单）对比 skills/task-discipline/references/critical-rules-discipline.md:21 与 skills/task-planner/SKILL.md:194（纯 D 类语义切换未要求会话面显性通告模板） | E 类可判定触发路径有交互门；但非 E 类三判形式的纯语义 D 类切换、及 silent 默认处置场景缺「已挂起 A→新建 B」的会话面显性通告，造成“功能有但不明显”。 |
| H4：drift-checker 面向执行偏移，不面向用户意图变更——两场景正交混用 | **verified** | /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:8-47（11/15/61：执行偏移 ALIGNED/DRIFT/BLOCKED；用户新指令为触发时机但仍做偏移比对）+ :59,63,68（64.2.1/64.4/64.7 目标漂移零交集拦截=安全网/事后基线校验）+ skills/task-planner/SKILL.md:122（先过用户新指令处理判定再派 drift-checker） | drift-checker 负责执行偏移与目标漂移拦截，非意图切换发起器；顺序正确但职责边界在文案中不够显性，易误作切换触发/误用。 |
| H5：hook [plan-note] 措辞只说「先做反思门」无快速判定锚句，未强制读 user-session-log #1 对照 | **partially verified** | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:287（已含 D 类开新计划+断点检查点+禁混入+对照 user-session-log 既有条目 80.8②） | 非完全空白：已提 D 类与专档对照；缺口为缺少可扫描的快速锚句（如“Goal/范围/交付物三要素均无关=立即 D 类切换”）且未强制“读 user-session-log 最新/#1 与当前 Goal 做零交集对照”作为首动作，提示冗长显性不足。 |
| H6：无「意图切换日志/切换登记」载体——切换发生后无持久痕迹可审计 | **verified** | skills/task-discipline/references/critical-rules-discipline.md:21,703（落 notepad+Decisions/落盘后自检行）+ :615（旧计划封存/新计划 init）对比计划模板与现有载体（无标准字段：旧→新计划ID/触发原话#N/判定类/确认方式/挂起状态/时间） | 痕迹分散于 Decisions/progress/notepad/目录，缺统一切换登记结构，事后审计与用户感知均弱。 |

## Technical Decisions

### 根因排序（R-1 ~ R-5）
1. **R-1（主因，触发面弱）**：判定/处置以 LLM 行为门为主，hook 仅提示不校验；缺快速判定锚句与强提醒，长上下文下 A 类惯性压过 D 类分流（H1, H5）。
2. **R-2（主因，流程面散）**：切换步骤分散于 SKILL.md/Rule 8.1/94/102/plan-resume，无单一可执行 checklist 与统一收口点，易漏挂起/通告/留痕（H2, H6）。
3. **R-3（次因，感知面弱）**：非 E 类可判定触发的纯语义 D 类切换及 silent 默认路径缺会话面显性通告模板，切换“无感”（H3）。
4. **R-4（次因，边界混淆）**：drift-checker 为执行偏移+目标漂移安全网，与意图切换发起正交但文案边界不够显性（H4）。
5. **R-5（次因，证据面弱）**：无统一切换登记载体，切换后不可审计、难复盘，放大“不明显”（H6）。

### 关键决策
| Decision | Rationale |
|----------|-----------|
| template_type=general, plan_tier=standard, execution_lane=L1 | 跨多条款/多载体诊断与增强，非 mini；general 合法兜底（Rule 34.1）。 |
| isolation=worktree（tmp/worktrees/task-intentswitch-20261116, wt/task-intentswitch-20261116） | skills/** 保护区改动且 check-conflicts.sh risk（①22未提交/⑤基础设施5/③遗留wt分支1/④未完成任务12）→ 宪法 §十一必须隔离。 |
| 增强策略：单入口主载体 + 交叉锚收敛 + hook 快速锚 + 登记字段模板化（推荐 S-A） | 直击 R-1~R-3/R-5，改动集中回归可控；不复制细则避免 94/102 漂移。 |
| drift-checker 语义不改，仅补边界说明 | 64.2.1/64.7 已具目标漂移安全网；H4 为职责边界显性问题，改判定逻辑风险/收益不匹配。 |

### 候选方案（≥2，含取舍）

| 方案 | 设计要点 | 优点 | 风险/代价 | 结论 |
|------|----------|------|-----------|------|
| **S-A 最小增强（推荐）** | ① SKILL.md:188-201「用户新指令处理」顶部增 **意图切换快速判定卡**（读专档最新原话→对照 Goal/范围/交付物三要素零交集→D/E 分流）+ **显性通告模板**（挂起计划ID/触发#N/新计划ID/下一步/确认方式）+ **切换登记最小字段**指引（写入 Decisions/progress 统一行格式）；② Rule 94/102 保留权威细则，仅增“切换执行以 SKILL.md 单入口清单为序”反向锚；③ UPS hook :287 压缩为快速锚句（Goal↔最新专档原话三要素比对→D 切换/可判定触发→E 确认）；④ 复用既有载体登记 intent_switch 行，不新建文件 | 集中改入口显性度高；回归面小；与 :190 单入口对齐；直接覆盖 R-1~R-3/R-5 | 仍以 LLM 行为门为主，非 100% 机器强制；需多处措辞一致性复核 | **推荐落地**（满足“增强既有机制、提升明显度”） |
| **S-B 结构化重构（备选/演进）** | ① 抽独立 `references/intent-switch.md`（或专用 SOP）统一 checklist+登记 schema；② SKILL.md/94/102/hook 全改指针；③ 增 `selftest-intent-switch.sh` 静态锚；④ plan-resume 增挂起态字段识别 | 单一事实源、可审计可守护、长期防漂移最强 | 改动面大（新文件/脚本/registry）、结构插段与回归风险高、粒度易超；本轮一次性完成成本高 | **备选**：S-A 验收后若仍不明显再升级；本计划可预留可选加固 S-unit（静态锚/登记 schema 文本化） |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| hook 源码不在仓库 scripts/ | 取证路径为 /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:283,285,287（全局部署位） |
| check-conflicts.sh 返回 risk | 采纳为隔离决策依据：worktree + tmp/worktrees/task-intentswitch-20261116 |
| H3/H5 证据显示部分机制已存在但不充分 | 结论标记 partially verified，避免夸大“完全缺失” |

## Resources
- skills/task-planner/SKILL.md:122,188-201
- skills/task-discipline/references/critical-rules-discipline.md:18-23,607-618,695-706
- /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:8-68
- /home/terry/.zcode/skills/plan-resume/SKILL.md:1-80
- /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:283,285,287
- skills/plan-collab-router/references/skill-collaboration.md:1-60
- plans/task-intentswitch-20261116/user-session-log.md#1
- bash /home/terry/.zcode/skills/task-planner/scripts/check-conflicts.sh（2026-11-16, risk ①⑤③④）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）