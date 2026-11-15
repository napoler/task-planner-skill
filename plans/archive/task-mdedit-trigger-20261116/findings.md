# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!-- 知识库:一切发现/决策/证据的落盘处。Rule 19.1/71 同口径。 -->

## Requirements
- R1（问询锚）：md-edit-ops 已交付部署（`/mnt/data/dev/task-planner-skill/knowledge/entries/md-edit-ops-structured-editing.md`）但触发面有缺口——普通会话随手 Edit .md 文件不保证触发（用户问询实证+上一任务会话行为反例），需封堵触发缺口。[目标]
- R2（授权锚，逐字）：用户通过 2026-11-16 AskUserQuestion 显式选择「A+B 组合 (Recommended)」。[手段/决策授权]
- Scope A（逐字对齐 brief）：**hook 机械提醒**：扩展 `skills/task-planner/scripts/zcode-pretooluse.sh` 的 `Write|Edit|ApplyPatch` 分支头部，纯增量 advisory 块（fail-open exit 0，禁改既有阻断/委派逻辑）——条件：tool∈{Edit,Write} ∧ file_path 以 .md 结尾 ∧ 路径不含 `/plans/` ∧ 满足任一：Edit 且 old_string 或 new_string 含换行符（结构化编辑信号）；Edit 且 old_string+new_string 合计 ≥200 字符；Write 且 content ≥600 字符。命中→stdout 一行 `[md-edit-ops] 提醒: 批量/结构化 markdown 修改优先走 md-edit-ops 指令单（bun/node --experimental-strip-types <技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json；写前预校验/原子/回滚/apply-report；Rule 106.6）；单行小改可直接 Edit`。附 What+Why 注释。
- Scope B（逐字对齐 brief）：**语义接线 2 行**：①`skills/task-discipline/references/execution-recall-card.md` §B「变更与范围」区末尾加 1 行：「- 批量/结构化 markdown 修改优先 md-edit-ops 指令单（Rule 106.6；apply-report 记 [recheck]）；裸 sed/python 0 命中即 FAIL」②`skills/task-discipline/SKILL.md` 速查/原则区加 1 行同义指针（位置自定须锚定）。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| md-edit-ops 事实底座 KB | `plans/archive/task-mdedit-reliability-20261116/knowledge-brief.md` §2/§3 | 是 | Research Findings / Resources |
| zcode-pretooluse hook 脚本 | `skills/task-planner/scripts/zcode-pretooluse.sh`（158 行） | 是 | Research Findings / Technical Decisions |
| md-edit-ops 知识条目 | `knowledge/entries/md-edit-ops-structured-editing.md` | 是 | Research Findings / Resources |
| task-discipline 执行召回卡 | `/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md` | 是 | Research Findings |
| task-discipline SKILL | `/home/terry/.zcode/skills/task-discipline/SKILL.md` | 是（前 120 行） | Research Findings |

## Research Findings
- **hook 现状**（`skills/task-planner/scripts/zcode-pretooluse.sh`）：stdin JSON 经 jq 取 `tool_name/file_path/session_id/cwd`；哨兵检查对非 plans/ 写在 plan-required 下 stderr+exit 2；`Write|Edit|ApplyPatch` case（:28-61）内调用 `check-delegation.sh pretool` 与 `check-skill-modify.sh pretool`，任一 rc=2 透传阻断；`Agent` case 做 dispatch 守卫；`CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet` 为观察 stdout+exit 0；末尾对 Write/Edit 做 Rule 23 并发冲突检测并 `exit 0`。整体 fail-open（异常不阻塞）。
- **插入点约束**：A 要求“分支头部，纯增量 advisory 块...禁改既有阻断/委派逻辑”。可在 `case "Write|Edit|ApplyPatch"` 进入后、`sid`/delegation 检查前读取 tool_input 并按条件命中则 `printf` 一行提醒到 stdout；不得 `exit`/`return`，确保后续 delegation/skill-modify/冲突检测照常执行。
- **条件细节**：仅 tool∈{Edit,Write} 触发（ApplyPatch 不在触发集合，但代码位于同 case，需显式限定）；file_path 以 `.md` 结尾；路径不含 `/plans/`；Edit 命中当 old_string 或 new_string 含换行符，或 old_string+new_string 合计 ≥200 字符；Write 命中当 content ≥600 字符。需从 stdin JSON 取字段（`.tool_input.old_string/.new_string/.content`），对空值容错。
- **recall-card §B**（`/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md:13-19`）：最后一条为“文件尺寸：产出前评估体量，优先沿内聚边界拆分（Rule 92）”；B① 指定新增行内容固定，追加于该区末尾。
- **task-discipline SKILL**（`/home/terry/.zcode/skills/task-discipline/SKILL.md`）：速查/定位信息集中在“定位/域边界/卫星路由/规则索引”段；B② 需同义指针并锚定具体位置（计划建议在“域边界”或“规则索引/速查”邻近显眼处加一行“md-edit-ops 触发与 Rule 106.6 指针”）。
- **md-edit-ops 工具链**（`knowledge/entries/md-edit-ops-structured-editing.md`）：CLI `bun/node --experimental-strip-types <技能位>/md-edit-ops/scripts/md-edit-ops.ts --order <单>.json`；写前预校验/原子/回滚/apply-report；Rule 106.6 协同。

### P1+P2 实施与复检结论（2026-11-16）
- **hook advisory 块**：worktree zcode-pretooluse.sh Write/Edit/ApplyPatch 分支头部纯增量 +30 行（主仓对照 0 删，advisory @L53）；条件=Edit/Write ∧ .md ∧ 非 plans/ ∧（多行∨old+new≥200∨Write≥600）；stdout 提醒+fail-open（无 exit 改动）；换行检测=bash 字符串匹配适配（jq test("\n") 环境不稳）。
- **语义接线**：recall-card §B 末尾 + task-discipline SKILL.md「卫星路由」段各 +1 行（均含 md-edit-ops+Rule 106.6）。
- **P2 独立复检 verdict=PASS-with-preexisting-exemption**：6+1 模拟例独立构造全符合（正 3 命中/负 4 静默）；N3 表观 exit 差异经同 cwd 交叉验证=既有委派门控上下文效应（两侧 hook 一致），非本改动；execution-stability T11b=主仓预存（log diff 无差异）；3 文件 3 处增量、无目标外改动。
- **部署注意（P3 输入）**：hook 脚本→5 位 task-planner/scripts（zcode 位=运行位 LIVE，改完即对本会话生效）；recall-card+SKILL→task-discipline 位族 4 位（opencode/agents 无 task-discipline 的按实态跳过并登记）。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| template_type=rule-enhancement, plan_tier=standard, execution_lane=L1 | 任务为 hook advisory 门控补强+纪律语义接线，属规则/守护触发面增强；虽为紧凑补丁但含 worktree、3 Phase、5 位部署与多项 VC，超 mini 判定。 |
| P1 在 worktree `tmp/worktrees/task-mdedit-trigger-20261116` 实施 A+B，Executor=code-assistant(haiku-1) | 实现类改动遵循 worktree 隔离；改动面小（1 脚本+2 文档行）适合轻档执行体，主进程仅派发与复核。 |
| P2 以 code-runner-agent(mini) 或主进程机械命令执行 hook 三正三负与 discipline 4 项检查 | 验收为确定性命令跑测，证据可复现；VC 绑定可执行命令。 |
| P3 部署 5 位+对账+运行位实弹由主进程执行（白名单：部署/簿记/归档编排）并收口 | 涉及多技能位同步与运行位验证，需对照实际路径与证据汇总；收尾按体量决定 kb/归档动作并留痕。 |
| R 锚双锚记录：task_plan R1/R2 + user-session-log.md #1 逐字锚 | 满足 brief 要求与 Rule 51.1/80 可追溯性；授权锚保留「A+B 组合 (Recommended)」原文。 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 问询原话未在本 subagent 可见上下文中以完整引号逐字给出 | 在 user-session-log.md #1 与 task_plan R1 中忠实记录 brief 提供的问询实质锚与触发缺口描述，并保留 R2 授权原文「A+B 组合 (Recommended)」；执行期如需补全可追加新条目（append-only）。 |

## Resources
- `plans/archive/task-mdedit-reliability-20261116/knowledge-brief.md`（§2/§3）
- `skills/task-planner/scripts/zcode-pretooluse.sh`
- `knowledge/entries/md-edit-ops-structured-editing.md`
- `/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md`
- `/home/terry/.zcode/skills/task-discipline/SKILL.md`
- `skills/md-edit-ops/scripts/md-edit-ops.ts`

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）
