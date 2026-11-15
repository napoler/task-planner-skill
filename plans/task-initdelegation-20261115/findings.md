# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
### R1 [目标] 初始化阶段委派子代理
- 用户原话锚：user-session-log.md#1
- 拆解：任务初始化阶段（用户需求分析 + 计划相关文档创建）**全部**委派子代理执行；主代理不在主上下文展开分析/建档细节。
- 条款面：在 task-planner 技能「计划制作循环」初始化/计划确认锚面新增“首动作委派”条款，明确 L1+ 适用、触发时机（init 后第一动作）、执行体选择（首选 Plan Writer，provider 失败按判例降级 general-purpose）与派发输入自包含要求。
- 收据契约面：子代理返回收据 `{task_id, files_created[], open_questions[], 摘要}`；主代理只回收收据并据此向用户呈现“创建了哪些文件 + 任务 ID”等最小信息，其余中间过程不进入主上下文。
- 守护面：条款须写明“计划展示/确认仍由主进程完成”的衔接点，避免子代理越权执行会话绑定动作。

### R2 [手段] 动机与收益边界
- 用户原话锚：user-session-log.md#1（“更好地隔离，而且主代理中其实只需要拿到…”“提高子代理里的激活率…降低主代理中的上下文的占用”）
- 拆解：动机=隔离更好 + 提高子代理激活率 + 降低主代理上下文占用。
- 条款面：条款正文需显式声明动机/收益边界，防止将其误读为“所有场景一律加仪式”；必须与 Rule 38.6/38.7 比例原则对齐，L0/mini/trivial 轻量档保持豁免通道不变。
- 守护面：通过执行通道分级与适用条件（L1+）避免轻任务被过度委派。

### R3 [目标] 固化为 task-planner 技能条款
- 用户原话锚：user-session-log.md#1（“继续优化当前技能”）
- 拆解：将 R1 行为固化为 task-planner 技能的可执行条款（SKILL.md 流程条款 + 必要时 core critical-rules 规则条款），而非仅本次临时操作。
- 条款面：修改源仓 `skills/task-planner/SKILL.md`（计划制作循环初始化/计划确认段）并视设计补充 `skills/task-planner/references/critical-rules.md` 新 Rule/子条款；保持与既有四文件罗盘、哨兵、attest、D1 门控语义一致。
- 收据契约面：收据字段与主代理回收动作成为条款组成部分，可复用、可验证。
- 守护面：明确主进程职责边界——skill 激活、init 机械子动作、哨兵/指针/attest/清哨兵等会话绑定脚本与收据回收归主进程；计划子代理仅负责分析与文档产出，不跑会话绑定脚本。

### 跨需求约束（实施必须遵守）
- 轻量豁免：L0/mini/trivial 不新增首动作委派仪式（Rule 38.6/38.7）。
- 本派发即 dogfood 首实例：证据=本次 plan-writer/general-purpose 派发与产出收据。
- 计划书执行域隔离：改 skills/ 保护区源文件走 §十一 worktree；会话绑定脚本（attest/set-active/init/plan-created/哨兵清理）仍属主进程职责。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| task-planner 主技能流程 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:36-80,194-202 | ✅ 已读 | Requirements / Research Findings |
| 核心规则索引与编号上下文 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:1-120,尾部路由段 | ✅ 已读 | Research Findings / Technical Decisions |
| Plan Writer agent 定义 | /home/terry/.zcode/agents/plan-writer.md | ✅ 已读 | Research Findings（执行体/降级语境） |
| 规则编号账本查询 | `bash skills/task-planner/scripts/rule-reserve.sh next` → 109（只读查询，2026-11-15） | ✅ 已读 | Technical Decisions / S-unit 预留步骤 |
| 用户原始需求 | plans/task-initdelegation-20261115/user-session-log.md#1 | ✅ 已读 | Requirements |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- 计划制作循环当前将初始化拆为 `[M] 机械子动作`（init-session/check-conflicts/sync-todos/清哨兵等）与 `[A] 智能子动作`（体量分级与隔离决策），随后进入 `[A] 计划确认`（展示计划、等 yes、attest、交互模式、规则编号预留等）。锚点：`skills/task-planner/SKILL.md:36-80`。R1 要求的“需求分析+计划文档创建委派子代理”需作为 L1+ 首动作插入该循环，并与现有机械子动作/会话绑定职责重新切分。
- SKILL.md 已存在 L0/mini/trivial/L0-E 等比例原则与豁免口径（如 `:42` auto-tier、`:194-202` 投诉响应与 L0 边界），新条款必须显式豁免轻量档，避免仪式膨胀（对齐 R2）。
- 计划确认段当前包含 D1 门控、目标绑定确认、attest-plan.sh（含 check-plan-dispatch）、交互模式与 new_rule 预留逻辑（`SKILL.md:55-63`）；会话绑定脚本（attest/指针/清哨兵 plan-created.cjs）在现有流程中由主进程/机械步骤承载——条款需固化“计划子代理不执行会话绑定脚本，主进程回收收据后完成展示/确认/attest”边界。
- core critical-rules 维护四文件罗盘域与核心 Rule 全集索引；`rule-reserve.sh next` 当前返回 109（只读，2026-11-15），若实施采用新增 core Rule 需在改条款前 `reserve` 并在落地后 `land`（Rule 20.6）。账本路径机制见 `skills/task-planner/scripts/rule-reserve.sh:37+` 用法说明。
- Plan Writer agent 定义位于 `~/.zcode/agents/plan-writer.md`（model: custom sonnet-1），可作为 L1+ 初始化计划子代理首选执行体；本次派发记录显示首派 Plan Writer 失败 `reason=reasoning-level-missing` 后改派 general-purpose 完成计划产出（dogfood 降级证据，见 progress.md）。
- 源仓存在 97 个 `skills/task-planner/scripts/selftest*.sh`（`ls ... | wc -l`，2026-11-15），实施前后需做相关/全量自测基线与零增量 FAIL 对账；具体受影响 selftest 集合由 Phase 1 锚定后定稿。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 采用 SKILL.md 流程条款 + core Rule 候选条款双锚固化 | SKILL.md「计划制作循环」是执行入口（R1/R3 直接命中）；core critical-rules 可承载可编号、可守护的契约语义（收据/边界/豁免），便于后续 selftest 与审计引用；具体是否新占 Rule 109 在 Phase 1 定稿并按 Rule 20.6 reserve。 |
| 首动作委派仅适用于 L1+（standard/full 且非 L0/mini/trivial 豁免） | 满足 R1/R2 同时遵守 Rule 38.6/38.7 比例原则，避免轻任务仪式化与上下文/时间浪费。 |
| 执行体优先 Plan Writer，失败降级 general-purpose 并记录证据 | 复用现成专职计划 agent（~/.zcode/agents/plan-writer.md）提升质量与激活率；provider/能力失败时降级保证可用性，降级原因写入收据/进度留痕（本次 dogfood 已验证）。 |
| 会话绑定脚本与收据回收归主进程 | init-session/attest/set-active/plan-created/哨兵清理与 D1 确认具会话态副作用，子代理不可安全代办；边界写入条款防越权。 |
| 实施改动走 worktree + 源仓后部署对账 | 修改 `skills/task-planner/**` 属保护区/运行基础设施，遵守 §十一；源仓为权威修改面，部署位 ~/.zcode 与 ~/.agents 需 diff 对账。 |

### S1 锚点锁定：首动作委派条款插入点与措辞要点（Phase 1 定稿，2026-11-15）

**证据来源（实测）**：`nl -ba skills/task-planner/SKILL.md | sed -n '30,80p'`（只读）；行号基线=当前仓库 SKILL.md（283 行文件中“计划制作循环”段）。

**① 精确插入点（建议）**：在「计划制作循环」中，于 **`[M] 初始化（哨兵机制）— 机械子动作` 块结束之后、`[A] 计划确认` 块之前**新增一个 **`[A]` 子动作 bullet**（推荐命名：`[A] **初始化首动作委派（L1+）— 智能子动作**`）。该位置承接 init 已完成态（7 文件/S1 同步/哨兵已清的机械前提由 init-session+sync-todos+plan-created.cjs 完成），在 D1 展示确认前完成需求分析与计划文档填写的委派与收据回收，保持“机械建档骨架→智能委派填充→主进程展示/确认/attest”顺序清晰。

- **插入点前锚（块尾，实测 L47-L48，插入应置于 L48 之后）**：
  - L47：`	  - **清除哨兵**：`node scripts/plan-created.cjs`（双清除 side+legacy）；哨兵存在期间 PreToolUse hook 拦截非 plans/ 路径 Write/Edit（exit 2）`
  - L48：`	`（空行，分隔 `[M] 初始化` 与 `[A] 初始化（智能子动作）`）

- **插入点后锚（现有后续块首，实测 L49-L50，插入后应保持其相对顺序或按设计微调但须保留语义）**：
  - L49：`	- [ ] [A] **初始化（哨兵机制）— 智能子动作**：体量分级判定与隔离决策`
  - L50：`	  - **冲突分析**：`bash scripts/check-conflicts.sh` → 结果+隔离决策写入 task_plan.md「🔀 隔离决策」（实现类默认首选 worktree）`

> Phase 2 实施时需明确：现有 L49 `[A] 初始化—智能子动作`（体量分级/隔离决策）与新增“首动作委派”子动作的先后/合并关系——建议将“首动作委派（需求分析+计划文档填写）”作为 init 后第一智能动作，并与隔离决策衔接（隔离决策可由主进程在 init 机械步骤后判定或作为委派输入约束，避免子代理越权改隔离结论）；以最小破坏现有 D1/attest 顺序为准。

**② 条款措辞要点（供 Phase 2 直接使用）**：
- **触发**：`L1+` 任务（standard/full，非 L0/mini/trivial/L0-E 轻量档）在 `init-session.sh` 完成后**第一动作**执行。
- **动作**：派发计划子代理执行「用户指令复述 + 需求分析 + 计划文档填写」；执行体**首选 Plan Writer**（`~/.zcode/agents/plan-writer.md`），provider/档位/能力失败时按判例降级 `general-purpose`，降级原因与证据留痕（progress/Error Log 或派发回执）。
- **主代理职责收窄**：仅保留 skill 激活、init 机械子动作（建目录/渲染/校验/S1 同步/清哨兵等脚本链按现有契约）、派发、**收据回收（盘上复核）**、计划展示、D1 确认、`attest-plan.sh` 锁定；中间分析/文档填写细节不在主上下文展开。
- **收据契约**：子代理返回 `{task_id, files_created[], open_questions[], 摘要}`，**≤20 行**；主进程对 `files_created`/关键产物做盘上 Read/存在性复核后再展示与确认。
- **边界**：**会话绑定脚本**（`init-session.sh`/`attest-plan.sh`/`set-active-plan.sh`/`plan-created.cjs`/哨兵清理等会话态操作）**禁由子代理执行**（会话态竞争/副作用风险）；D1 确认、attest 锁定、收据回收与展示归主进程。
- **豁免**：`L0/mini/trivial/L0-E` 轻量档**不适用**本条款（Rule 38.6/38.7 比例原则与既有豁免通道不变，避免轻任务仪式化）。
- **动机面**：隔离更好、提高子代理激活率、降低主代理上下文占用；禁止将本条款误读为“所有场景一律加仪式”。

**③ 编号/守护备注（S2 联动）**：`bash skills/task-planner/scripts/rule-reserve.sh next`（2026-11-15，只读）返回 `109`（编号水位）；本次 Q1 已定 **SKILL-only 不占号**，Phase 2 若仅改 SKILL.md 流程条款则不 reserve/land；若后续扩展到 core critical-rules 新 Rule 须按 Rule 20.6 先 reserve 再落地。

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| Plan Writer 首派失败（reason=reasoning-level-missing） | 按用户要求改派 general-purpose 继续完成计划文档；在 progress.md 与收据中留痕，计划内将该降级路径固化为条款允许的 fallback。 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/rule-reserve.sh
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/set-active-plan.sh
- /home/terry/.zcode/agents/plan-writer.md
- /mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/user-session-log.md
- /mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/task_plan.md

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
