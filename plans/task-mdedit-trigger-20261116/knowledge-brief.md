# Knowledge Brief — task-mdedit-trigger-20261116（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：为 md-edit-ops 补齐普通会话编辑 .md 文件的触发面——在 zcode-pretooluse.sh 增加结构化/批量 .md 编辑 advisory 提醒（A）并在 task-discipline 执行召回卡与 SKILL 增加 md-edit-ops 语义指针（B），使 Rule 106.6 工具链在触发层可被感知。
- 背景/动机：md-edit-ops 执行器与 Rule 106.6 已交付部署，但普通会话随手 Edit/Write .md 不保证触发（问询实证+上一任务行为反例）；用户已授权「A+B 组合 (Recommended)」（2026-11-16 AskUserQuestion）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| advisory 提醒 | hook 向 stdout 输出提示文本但 exit 0 放行，不阻断工具调用（与 stderr+exit 2 阻断相对）。 |
| 结构化编辑信号 | Edit 中 old_string/new_string 含换行、或 old+new 合计≥200 字符、或 Write content≥600 字符，提示可能是批量/结构化 markdown 修改。 |
| md-edit-ops 指令单 | `skills/md-edit-ops/scripts/md-edit-ops.ts` 的 JSON edit-ops 单，支持写前预校验/原子应用/回滚/apply-report。 |
| Rule 106.6 | task-discipline 中 markdown 结构化编辑应走 md-edit-ops 工具链并与 Rule 106 纪律协同的条款（`skills/task-discipline/references/critical-rules-discipline.md:741`）。 |
| worktree 实施 | 在 `<project-root>/tmp/worktrees/<task-id>` 隔离副本内改代码/文档，验收后合并/部署并清理（Rule 100/§十一）。 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 用户授权 A+B 封堵组合（推荐项） | `plans/task-mdedit-trigger-20261116/user-session-log.md` #1（逐字授权锚「A+B 组合 (Recommended)」）；本次 plan brief「授权锚=2026-11-16 AskUserQuestion 答案」 | 方案方向已裁决：必须同时落 hook advisory（A）与 discipline 语义接线（B），不得缩水为单边。 |
| zcode-pretooluse.sh 为 jq 解析 stdin→tool_name 路由的 PreToolUse 适配器；阻断=stderr+exit 2，advisory/观察可 stdout+exit 0；脚本声明 fail-open | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh:1-11,18-23,42-54,83-91,157-158` | A 必须在 `Write|Edit|ApplyPatch` case 头部做纯增量 advisory，命中只 stdout 一行并继续后续既有逻辑，任何异常不得改为阻断；保持 fail-open。 |
| Write|Edit|ApplyPatch 分支现有逻辑：取 sid/lines_arg 后调用 `check-delegation.sh pretool`（rc=2 则 stderr+exit 2）、再 `check-skill-modify.sh pretool`（rc=2 透传），然后落入末尾并发冲突检测段对 Write/Edit 生效 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh:28-61,93-157` | advisory 块须插在分支头部且不 return/exit（除非明确放行后续仍需跑 delegation 等既有检查），不得破坏 rc=2 阻断语义。 |
| hook stdin 含 `.tool_name` 与 `.tool_input`（file_path/old_string/new_string/content 等由工具提供）；jq 读取模式已在脚本中使用 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh:11-12,35-39`；同文件既有 `jq -r '.tool_name ...'` 用法 | 条件判断可用 jq 提取 `tool_input.file_path/old_string/new_string/content`；需防空值/缺字段导致误判，fail-open。 |
| md-edit-ops 工具链已存在且定位明确：指令单执行器 `skills/md-edit-ops/scripts/md-edit-ops.ts`，具备写前预校验/原子/回滚/apply-report | `/mnt/data/dev/task-planner-skill/knowledge/entries/md-edit-ops-structured-editing.md`（What/How）; `plans/archive/task-mdedit-reliability-20261116/knowledge-brief.md` §2/§3 | 提醒文案必须指向该 CLI 与 Rule 106.6，提示“单行小改可直接 Edit”与工具优先场景并存。 |
| Rule 106.6 已落 discipline 规则（markdown 结构化编辑走 md-edit-ops，与 Rule 106 协同） | `/mnt/data/dev/task-planner-skill/knowledge/entries/md-edit-ops-structured-editing.md`（How: `skills/task-discipline/references/critical-rules-discipline.md:741`） | B 侧接线是语义触发补强（召回卡/SKILL 指针），不替代规则正文；措辞须含 Rule 106.6 与 `[recheck]`。 |
| execution-recall-card.md §B「变更与范围」当前末行为「文件尺寸：产出前评估体量，优先沿内聚边界拆分（Rule 92）」 | `/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md:13-19`（§B 标题在 :13，末项在 :19） | B① 要求在 §B 区末尾加指定 1 行；需保持单行 bullet 风格与既有格式。 |
| task-discipline SKILL.md 为纪律域索引/定位文档，含速查性质段落（定位/域边界/规则索引等） | `/home/terry/.zcode/skills/task-discipline/SKILL.md:1-120`（已读） | B② 要求在速查/原则区加 1 行同义指针，位置自定但须锚定；计划需给出明确落点建议以便验收。 |
| 计划目录 7 文件已初始化，sid 指针已绑定 8973c6067dd044a48d8b58f39169cbf7 | `/mnt/data/dev/task-planner-skill/plans/task-mdedit-trigger-20261116/`（ls）；plan brief 元信息 | 计划期只写 5 文件（+必要时 user-session-log 记 R 锚），禁碰 scope 文件与 git。 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh` | :11-12, :28-61 | 解析 stdin tool_name/file_path；`Write|Edit|ApplyPatch` case 执行 delegation/skill-modify 检查，rc=2 走 stderr 阻断；A 的 advisory 需在此分支头部增量插入且 fail-open。 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh` | :83-91, :157-158 | workflow 观察分支与脚本末尾 `exit 0`；保持整体 fail-open 与既有分支语义不变。 |
| `/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md` | :13-19 | §B「变更与范围」红线清单；B① 在末尾（:19 后同级 bullet 位置）追加 md-edit-ops 指令单优先与裸 sed/python FAIL 提醒。 |
| `/home/terry/.zcode/skills/task-discipline/SKILL.md` | :9-27（建议锚） | 定位/域边界/规则路由速查区；B② 在显眼速查段追加同义 md-edit-ops 指针并锚定具体标题/行。 |
| `/mnt/data/dev/task-planner-skill/skills/md-edit-ops/scripts/md-edit-ops.ts` | （文件级） | edit-ops CLI 入口；提醒文案与运行位实弹引用此路径（`<技能位>/md-edit-ops/scripts/md-edit-ops.ts`）。 |
| `/mnt/data/dev/task-planner-skill/knowledge/entries/md-edit-ops-structured-editing.md` | 全文 | md-edit-ops 能力、流水线、触发与部署事实底座；用于对齐文案与验收理解。 |
| `/mnt/data/dev/task-planner-skill/plans/archive/task-mdedit-reliability-20261116/knowledge-brief.md` | §2/§3 | 前序任务已验证事实与锚点，作为本次触发面补丁的背景证据。 |

## §4 易错点与禁止假设清单
1. **禁止改既有阻断/委派逻辑**：A 只能在 `Write|Edit|ApplyPatch` 分支头部做纯增量 advisory；不得改变 `check-delegation.sh`/`check-skill-modify.sh` 的 rc=2 阻断、stderr 文案与 exit 2 行为。
2. **advisory 必须 fail-open**：条件不满足、字段缺失、jq 解析异常等均不得导致非 0 退出或阻断；命中时 stdout 输出一行提醒后继续后续检查链。
3. **条件须逐字对齐 Scope A**：tool∈{Edit,Write}；file_path 以 `.md` 结尾；路径不含 `/plans/`；Edit 满足“old/new 含换行符”或“old+new 合计≥200 字符”；Write 满足“content≥600 字符”。不可擅自放宽/收紧。
4. **提醒文案须与 brief 一致**：包含 md-edit-ops CLI 路径形式、写前预校验/原子/回滚/apply-report、Rule 106.6、以及“单行小改可直接 Edit”提示。
5. **B 侧只加语义接线**：① execution-recall-card.md §B 末尾精确新增指定行；② task-discipline SKILL.md 速查/原则区新增同义指针并锚定位置；不得改动规则正文语义或大段重排。
6. **部署 5 位与对账不得凭空假设路径**：P3 以仓库/环境实际可用技能位为准（计划中明确 5 位目标族与核验方式），运行位实弹须在真实部署位执行并留证据。
7. **计划期约束**：本轮只写计划目录 5 文件（及按要求记录 user-session-log #1），禁碰 scope 实施文件，禁 git。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 1 hook advisory 误伤既有阻断链」「Phase 2 验收用例覆盖不足导致漏检」「Phase 3 多位部署不一致/运行位未实弹」行。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1/S1 | §1, §2, §3, §4 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh`（全文件，重点 :28-61）；本 plan `task_plan.md` Scope A 与 Phase 1 |
| P1/S2 | §1, §2, §3, §4 | `/home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md:13-19`；Scope B① |
| P1/S3 | §1, §2, §3, §4 | `/home/terry/.zcode/skills/task-discipline/SKILL.md`（速查/原则区锚定段）；Scope B② |
| P2/S1 | §1, §2, §4 | worktree 内 `skills/task-planner/scripts/zcode-pretooluse.sh`；`task_plan.md` VC-P2（hook 三正三负命令） |
| P2/S2 | §1, §2, §3, §4 | worktree 内 `execution-recall-card.md` 与 `task-discipline/SKILL.md`；`verification.md` discipline 4 项检查 |
| P3/S1 | §2, §3, §4 | `knowledge/entries/worktree-lifecycle-mergeback.md`（部署/合并对账先例）；`task_plan.md` Phase 3 与 5 位清单 |
| P3/S2 | §1, §4 | `verification.md` 运行位实弹与收尾检查项；`progress.md` 证据回填要求 |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | `/home/terry/.zcode/skills/task-planner/SKILL.md` | 计划制定、VC/Phase 门控与计划文件契约 | 主进程按流程使用 |
| task-discipline | `/home/terry/.zcode/skills/task-discipline/SKILL.md` | Rule 106.6 语义接线、执行召回卡维护与纪律一致性 | 子代理 prompt 挂载 / 规则引用 |
| md-edit-ops | `/mnt/data/dev/task-planner-skill/skills/md-edit-ops/SKILL.md` | 提醒文案与运行位实弹所指向的结构化编辑工具链 | 按需参考/执行期实弹调用 |
| verification-gate | `/home/terry/.zcode/skills/verification-gate/SKILL.md` | VC 可执行化与验收证据组织 | 子代理 prompt 挂载 |
| systematic-debugging | `/home/terry/.agents/skills/systematic-debugging/SKILL.md` | P2/P3 验收或部署不一致时的根因定位 | 子代理 prompt 挂载 |
| using-git-worktrees | `/home/terry/.agents/skills/using-git-worktrees/SKILL.md` | P1 worktree 创建与隔离实施流程 | 子代理 prompt 挂载 |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-mdedit-trigger-20261116>` → 生成 knowledge/entries/_draft-task-mdedit-trigger-20261116.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）
