# 推荐方案落地清单（S16 / P6）— 待批，本轮不实施（S17 评审后修订版）

> 对应方案 A（见 improvement-options.md）；每条 `DRIVE-POINT` 说明如何把「必须每次发生」变成机器可触发（C5）。
> **本版修正依据**：S17 critic 逐轮 NOT APPROVED（R1 1C/6I/5W/3N、R2 0C/3I/4W/1N、R3 0C/1I/6W/5N）经主进程盘上复核成立——B9-B11 已被 commit 5915e78a 占用、部署位是漂移副本、H4 改 .bashrc 是 no-op、check-dispatch 跳过条件在 :588、plan-writer 义务在 companion/agents 而非 references 等，逐条采纳。
> 路径纪律：一律改 **canonical 源**（`<repo>/skills/...`），部署位由 install.sh 派生，禁直改（仓库 AGENTS.md §2）。

## H1 — 入口无驱动点
FILE-CHANGE `/home/terry/.zcode/cli/config.json` events.SessionStart（`:29-40`）：新增一条 hook 调用独立脚本 `zcode-sp-inject.sh`（新建 FILE-CHANGE 见下），在现有 zcode-sessionstart.sh 之后注入 using-superpowers；对齐上游 `hooks.json` 的 `run-hook.cmd session-start`。
DRIVE-POINT 会话创建/clear/compact 由 SessionStart 事件强制注入 → 每次会话必触发，不依赖执行体记得调用。
FILE-CHANGE `/home/terry/.zcode/cli/config.json` events.UserPromptSubmit（`:69`）：注入文本增「先扫描相关技能再响应」——**标注为辅助提示、非 C5 硬门**（W-1：文本注入不构成机器门，真正的门在 H3 基线组）。
DRIVE-POINT 每条指令到达时由 hook 提示辅助扫描；硬拦截由 H3 的 B12/B13 fail-closed 门承担（W-1 修正）。
FILE-CHANGE new `<repo>/skills/task-planner/scripts/zcode-sp-inject.sh`：输出 using-superpowers 注入文本（新建 vs 扩 zcode-sessionstart.sh 的选择：新建，避免改现有会话初始化逻辑，W-2/N-1 修正：统一 `<repo>/` 前缀）。
FILE-CHANGE `<repo>/skills/task-planner/install.sh` + `<repo>/skills/task-planner/lib/verify.sh`：新增该脚本的部署与对账步骤（W-3 修正：config.json:34 命令指向部署位 `/home/terry/.zcode/skills/task-planner/scripts/…`，仅落 canonical 源则首次 SessionStart 即 ENOENT；须随部署链同步并 verify）。
DRIVE-POINT 独立脚本可被 SessionStart 直接调用且不干扰现有哨兵逻辑；部署位同步后 hook 不再指向空文件。

## H2 — 路由触发面窄
FILE-CHANGE `<repo>/skills/task-planner/references/spec-mode.md` §1：文本路由表落成 `scripts/check-spec-route.sh` 运行时判定（输出=应路由技能族）。**指认调用点（I-3/N-W-1/W-2 修正）**：`init` 期的 `cmd_init`（`planctl.py:780-808`）仅消费 task_id/tier/lane/template_body、拿不到「需求特征」，故规定两级——`init` 做 **tier 粗筛**并产出初判收据（实测 `planctl.py:1950 add_cmd("init", ...)` 存在）；**需求特征级判定后移至 B13 基线组**（H3 的 `sync-todos.sh` 执行期，此时需求已产出）产出终判收据；与 B13 职能不重叠而是分级互补（W-2 修正原「init 输入需求特征、与 B13 重叠」）。`spec-mode.md` §1 文本路由表为该脚本判定的唯一事实源（NIT 修正），脚本不在运行时另立规则。
DRIVE-POINT 计划期由脚本判定路由并产出收据 → 条件命中必触发，非 SKILL.md:114 文本指针。
FILE-CHANGE `<repo>/skills/plan-collab-router/references/skill-collaboration.md:60,68`（canonical 源，非部署副本，I-1 修正）：OpenSpec CLI 探针升级为 `check-spec-route.sh` 运行时步骤；**探针内按可移植顺序解析：`$(npm config get prefix)/bin/openspec` → `command -v openspec` → 本机已观测绝对路径兜底；失败记「不可接管」状态**（I-2/W-4 修正：不硬编码 `/home/terry/.npm-global/bin/openspec`，不依赖 PATH/.bashrc，换机与多工具部署不失效）。
DRIVE-POINT 探针每次路由必执行、失败显式留痕 → 消除静默跳过，PATH 问题可观测且不被 no-op 修复掩盖。

## H3 — 功能同构竞争（编号已按 C-1 修正）
FILE-CHANGE `<repo>/skills/task-planner/scripts/sync-todos.sh`（canonical 源 :303 附近的 B1-B11 构造段）：基线组从 B1-B11 扩 **B12「SP/OS 技能到达检查」+ B13「Spec 路由命中核查」**（**避开已合并 B9-B11**，C-1 修正；与 5915e78a 的 Git 基线步骤无语义重叠）。B12/B13 沿用 11 条记录的 evidence/command 字段形态。
DRIVE-POINT 计划创建时脚本强制建 B12/B13 原生 Todo → 每次执行必检查技能到达，复用已验证基线组驱动模式。
FILE-CHANGE `<repo>/skills/task-planner/references/todo-sync.md`（canonical 源 :35,37 门禁段）：门链增 B12/B13——B12 未留痕=禁声称完成；B13 命中路由未勾=禁 Phase complete（对齐既有 B1-B11 门禁语，C-1 修正）。
DRIVE-POINT fail-closed 门拦截无技能到达证据的完成声称 → 基线组从「提示」升为「硬门」。
FILE-CHANGE `<repo>/skills/task-planner/references/todo-sync.md` B12 证据判据增「**技能步骤产物承接收据**」：不仅查 SKILL.md 文件存在/Read，还要求该技能步骤的产出物（如 brainstorming 的选项文档、systematic-debugging 的根因报告）在计划文件/actions 中有登记（I-5 修正：覆盖 R4「被调用并用于推进」验收，S14「调用后未承接」类）。
DRIVE-POINT 承接收据缺=门不通过 → 「用于推进」成为可验证驱动点，而非仅到达。

## H4 — OpenSpec 落点缺失（PATH 修复已按 I-2 重写）
FILE-CHANGE 目标项目根（实施时按项目 README/AGENTS 判定，判定标准见下）：`openspec init` 建 `openspec/`，作为 OpenSpec propose/explore 落点（S4 scratch-init 实测 rc=0）。**项目判定标准（W-5 修正）**：以「存在 package.json/pyproject.toml 且有 specs/ 或 openspec/ 约定」的工程仓根为准，实施前由 plan-writer 在计划中登记绝对路径。
DRIVE-POINT 有落点目录=CLI 产物有处可写 → 消除「无处落地」。
DECISION-REGISTER（非 FILE-CHANGE，N-W-4 修正）：不改 `~/.bashrc`（I-2：其 :127 已有该 export 且 probe 仍 rc=1，属 no-op）；改为在 H2 的 `check-spec-route.sh` 探针内**按可移植顺序解析 openspec（`$(npm config get prefix)/bin/openspec` → `command -v` → 观测路径兜底，不硬编码单一绝对路径，W-4 修正）并把「PATH 不可达但可执行文件存在」作为已知状态写入实施任务的 Decisions**。
DRIVE-POINT 探针以可移植解析链为事实源 → H2 的探针驱动点获得真实可用输入，避免无效 PATH 改动与硬编码失效。

## H5 — 伴飞字段载体三处断链
FILE-CHANGE `<repo>/skills/task-planner/scripts/planctl.py:127-128` s_units 默认键增 `escort_skills`，类型定为**字符串数组**（NIT 修正：对应 `planctl.py:162` `STR_LIST_FIELD`，与 `s_units` 其他数组字段一致，非单一字符串）（N-I-3 修正锚：同步 `<repo>/skills/task-planner/schemas/plan-state.schema.json:542-558` 的 `s_unit_item`——其 `additionalProperties:false` 且仅 10 键，以及 `<repo>/skills/task-planner/scripts/planctl.py:555-558` 的硬编码 known 键清单、`:587-591` 未知键报错——只改默认面会导致 add/set 与 schema 双拒；沿用 `escort_skill_path`/`escort_skill` 词表 W-4）。
DRIVE-POINT 编码期有专用字段且 add/set/schema 三处均接纳 → 伴飞路径可写入权威源（I-6/N-I-3 修正）。
FILE-CHANGE `<repo>/skills/task-planner/companion/agents/plan-writer.md`「## 掌握的技能」节（I-1 修正：该文件 `ls` 实存、`:37` 节存在；原写的 `references/plan-writer.md` 经 ls=ENOENT 剔除）：增「S-unit 表『伴飞技能』列填 `escort_skills` 中 `.md` 绝对路径」的填列义务（N-I-2 写入口目标；该文件现 grep 伴飞/escort=0，属真实缺口）。
FILE-CHANGE `<repo>/skills/task-planner/templates/task_plan.md:369,387`（写入口承载面，W-1 修正）：模板与 variant **31 个中 28 个本已含「伴飞技能」列**（`l0-lite-type.md`/`mini-lite-type.md`/`longform-continuity-type.md` 3 个轻量类型无 S-unit 表、故无该列，无需补），不新增列；`templates/subagent_dispatch.md:37-39` 本已有伴飞节；`PD/plan-brief.md` 是本审计一次性目录、改它对未来计划零作用，剔除。
DRIVE-POINT plan-writer 有填列义务 + 模板已有承载列 → 字段非空=门有输入，修复「写入口缺失」断链且不重复造列。
FILE-CHANGE `<repo>/skills/task-planner/scripts/planctl.py:1271`：渲染第 8 列由 `_cell(s.get("parallel",""))` 改为渲染 escort_skills 路径；**parallel 组标识改落既有「前置依赖」列的行内注解（Rule 68.1/96.3 已有约定），零列变更、无需动 SUNIT_HEADERS/31 个 variant（W-1 修正原「19 个」不符：variant 实为 31 个，28 有列/3 轻量无表；NIT 修正：`s_units` 当前无 `depends` 字段、「前置依赖」列由 `:1271` 同行恒渲 `-`，实施须由 `parallel` 合成组标记或另加字段，否则 `check-plan-dispatch` 的非 ID token 处置会触发 H3）**（N-W-3 修正：比新增第 11 列更省且无列序风险）。
DRIVE-POINT 渲染的「伴飞技能」列真正含 `.md` 路径 → 修复「parallel 占列」断链。
FILE-CHANGE `<repo>/skills/task-planner/scripts/check-dispatch.sh:588`（canonical 源，点名真正跳过条件，I-4/N-1/N-W-2 修正）：现 `:580/585` 已能提取 `.md` token 并 `-f` 校验，需改 `:588` 的 `esrcs` 判空逻辑——当 `s_units[].escort_skills` 非空（显式意图信号）但 esrcs 为空时判违规（fail-closed），而非跳过。
DRIVE-POINT 意图信号非空却无有效路径时拦截 → 修复「无 token 跳过」断链，Rule 59.2 首动作 Read 得以制度性注入。

## 合规声明（S17 评审面预告，已按修订版逐条自查）
- C1：本清单只写 PD/，未改任何受管文件；实施时才动 canonical 源且须授权。
- C2：全部改动表述为「技能缺哪个驱动点/门」，无「执行方跳过/模型未遵守」归因。
- C4（S17 独立核实通过）：未提砍委派率硬门、未改主进程直做、未降级 planctl、未直改 4 个 MD 派生视图——planctl:1271 是修渲染非降级，仍以 planctl 为派生视图唯一写者。
- C5：H3 用 B12/B13（避开已合并 B9-B11）必选基线组成员 + fail-closed 门，符合「必须每次发生→基线组+脚本驱动」形态。
- R-BLIND-1：未把 99 次 Skill 调用写成 SP/OS 调用或零调用；未把文本提及当调用证据。
- D-3：交方案待批本轮不实施；hook 配置 / `~/.zcode/skills/**` 等保护区改动须单独立项授权。
