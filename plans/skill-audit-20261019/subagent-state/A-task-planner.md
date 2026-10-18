# A-task-planner 深度审计检查点（skill-fix 标准）

- 审计时间: 2026-10-19
- 审计对象: `/mnt/data/dev/task-planner-skill/skills/task-planner/`（核心技能）
- 范围: 只读，不改任何文件；已 Read 全部指定文件（SKILL.md 全文 238 行、references/ 6 文件、config.json、install.sh、lib/verify.sh、templates/task_plan.md+verification.md、及 8 个关键 .sh/.ts）
- 方法: 逐文件 Read + grep 定向验证，每条发现带 file:line verbatim 证据

## 0. 前置发现核对结论（主上下文机械扫描的纠偏）

| 前置发现 | 核对结果 |
|---------|---------|
| 1. bun 未安装，36 个 .ts | **部分正确**。bun 确实未装（`command -v bun` → 无）；但「36 个 .ts」错误：task-planner **active** 的 .ts 仅 3 个（scripts/session-catchup.ts、scripts/register-hooks-cj.ts、scripts/sync-ide-folders.ts，全仓含 .backup 快照共 58 个）。其中仅 2 个用 `#!/usr/bin/env bun`（session-catchup.ts、register-hooks-cj.ts），第 3 个 sync-ide-folders.ts 用 `#!/usr/bin/env npx ts-node`。 |
| 2. S75 D1 硬编码 /mnt/data/... 默认值 | **正确且严重**。TASK_PLANNER_ROOT 回退默认值 `/mnt/data/dev/task-planner-skill/skills/task-planner` 出现在 MIGRATION/README/INSTALL/docs 及 templates、selftest 内（见 F3）。 |
| 3. S75 D3 .claude/.zcode 平台混用 | **正确**。SKILL.md、config.json、install.sh、init-session.sh、两个 .ts、smart-merge-back.sh、plan-doctor.sh 均同时含 .claude 与 .zcode（见 F5）。 |
| 4. S64 跨技能引用 ../ 形式 | **正确但需补充**：SKILL.md 顶部路由表确实用 `../卫星/`（正确）；references/ 与 SKILL.md 内部多处用 `skills/卫星/`（无 ../，仓根相对）——同一技能内两套引用并存，见 F4。 |
| 5. task-dispatch frontmatter 用 tools: 而非 allowed-tools: | **未在本审计范围验证**（task-dispatch 是卫星，非本次 task-planner 核心目录）。标注未验证。 |

---

## 发现（按等级）

### [P0/BLOCKED] F1 — 工作流第一步依赖 bun，bun 未安装 → 初始化检测不可运行
- 标准: S74（运行时实证）
- 位置: `scripts/session-catchup.ts:1` + `SKILL.md:40`
- 证据:
  - session-catchup.ts:1 `#!/usr/bin/env bun`
  - session-catchup.ts:13 ` * 用法: bun session-catchup.ts [project-path]`
  - SKILL.md:40 `  - 运行 \`bun scripts/session-catchup.ts\` 检测中断恢复点；创建 \`plans/{task-id}/\`，运行 \`bash scripts/init-session.sh\``
  - `command -v bun` 实测无输出（BUN NOT FOUND）
- 说明: session-catchup.ts 是「计划制作循环 → 初始化」的第一步（中断恢复点检测），bun 缺失则该步不可执行。register-hooks-cj.ts:1 `#!/usr/bin/env bun`（install.sh:162 用 `bun run register-hooks-cj.ts`）仅安装期触发且 install.sh:164 有「bun not found, skipping」降级，影响较小。
- 建议: 将 session-catchup.ts / register-hooks-cj.ts 改写为 node 可运行（node 普遍可用），或提供 bash 等价实现 + bun 可选增强；SKILL.md 流程改为「bun 可用则跑 session-catchup.ts，缺失降级到 5Q Reboot 读三文件」，避免第一步硬依赖缺失运行时。

### [P1] F3 — 硬编码 `/mnt/data/dev/task-planner-skill/` 作为 TASK_PLANNER_ROOT 回退默认（迁移性破洞）
- 标准: S75（D1 硬编码路径）
- 位置: 模板与 selftest（功能性）最严重；文档次之
- 证据:
  - `templates/verification.md:77` `运行 \`bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>\``（同 :81）
  - `templates/task_plan.md:3` `白名单=${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/variant/*-type.md`（同 :29 专档路径、:90 V-N 载体）
  - `scripts/selftest-subagent-return.sh:29` `PLAN="/mnt/data/dev/task-planner-skill/plans/archive/task-v161-subagent-return-format"`
  - `scripts/selftest-decision-drift.sh:98` `elif [ -f /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/task_plan.md ]; then`
  - `MIGRATION.md:11` `| 源 | ~/.claude/skills/task-planner/ + ~/.zcode/skills/task-planner/ 双份独立 | ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/ 单一 canonical |`（README.md/INSTALL.md/docs/ARCHITECTURE.md 同类大量）
- 说明: 核心问题=① 模板层（verification.md / task_plan.md）把机器默认可执行路径写死为某台开发机路径，部署到别处且未设 TASK_PLANNER_ROOT 时命令直贴复制即失效；② selftest 直接写死本机 `plans/archive/...` 与 `plans/task-v156-...` 具体任务路径，换机即缺文件。文档/迁移脚本里的 /mnt 默认值属可接受（env 可覆盖），但模板+selftest 属机器行为面，不应写死。
- 建议: 模板层统一用 `${TASK_PLANNER_ROOT:-$(cd "$(dirname ...)/..")}` 或引导主进程解析为 `<skill>/`；selftest 改用相对 `$(repo-root)/plans/...` 动态解析或在无该 fixture 时 skip（fail-open）而非硬编码绝对路径。

### [P1] F4 — 跨技能（卫星）引用同一技能内混用 `../卫星/` 与 `skills/卫星/` 两种形式 → 歧义
- 标准: S64（跨 skill 引用应统一加 ../ 前缀；歧义=P1）
- 位置: SKILL.md:158 vs :165-175；references/* 全用 skills/ 形式
- 证据:
  - 正确形式（加 ../）: `SKILL.md:165` `| task-dispatch | ... \`../task-dispatch/references/critical-rules-dispatch.md\` |`；`SKILL.md:234` `\`../task-dispatch/references/agent-coverage.md\``
  - 歧义形式（无 ../，仓根相对）: `SKILL.md:158` `现权威位置=\`skills/plan-template-kit/references/critical-rules-template.md:45\` + \`skills/task-discipline/references/critical-rules-discipline.md:191\``
  - `references/critical-rules.md:183` `规则全文见 \`skills/task-dispatch/references/critical-rules-dispatch.md\``（:184-193 全 11 卫星同形式）
  - `references/completion-gate.md:5` `**全文权威位置**：\`skills/verification-gate/references/critical-rules-verification.md\` Rule 84.4`（goal-gate.md:5 同）
- 说明: 这些文件位于 `skills/task-planner/`（或其 `references/`），`skills/task-dispatch/...` 相对本文件在文件系统上不存在（须从仓根解析），只有 `../task-dispatch/...` 才相对本目录正确。同一技能内两种写法并存 = 读者无法判断基准目录。
- 建议: 统一为 `../卫星/` 相对形式（与 SKILL.md 顶部路由表一致），把 critical-rules.md/completion-gate.md/goal-gate.md/SKILL.md:158 的 `skills/卫星/` 全部改为 `../卫星/`。

### [P1] F5 — .claude 与 .zcode 平台路径混用（非纯示例文字）
- 标准: S75（D3 平台混用；示例文字豁免）
- 位置: 多处，功能性代码为主
- 证据:
  - `SKILL.md:21` `# See: ~/.claude/skills/task-planner/SKILL.md (Claude Code) / ~/.zcode/skills/task-planner/SKILL.md (ZCode)`
  - `SKILL.md:43` `项目级 \`.claude/plan-templates/\` 或 \`.zcode/plan-templates/\` 覆盖`
  - `SKILL.md:47` `**清除哨兵**：\`node ~/.zcode/skills/task-planner/scripts/plan-created.cjs\``
  - `config.json:347` `账本权威源=progress-tracker 技能（.zcode/ledger/ 或 .claude/ledger/ 多平台跟随）`
  - `scripts/register-hooks-cj.ts:5` `settingsPath: ~/.claude/settings.local.json`；`scripts/session-catchup.ts:5` `~/.claude/projects/...`
  - `scripts/smart-merge-back.sh:388` `SLOTS="$HOME/.zcode/skills/task-planner:$HOME/.claude/skills/task-planner:$HOME/.config/opencode/skills/task-planner"`
- 说明: install.sh / plan-doctor.sh / smart-merge-back.sh 的双平台探测属「多工具安装器/部署位白名单」合理设计意图（有 .backup/claude-stub 佐证双部署模型）。但 SKILL.md:47 把哨兵清除命令写死 `~/.zcode/...`，init-session.sh:67 项目模板只找 `.claude/plan-templates`（find_project_templates 不含 .zcode），与 SKILL.md:43「.claude 或 .zcode 覆盖」表述不符——正文承诺与脚本实现平台覆盖不一致。
- 建议: 正文（SKILL.md）避免把平台路径写进可执行指引（改用 `${TASK_PLANNER_ROOT}`）；功能性脚本的双平台分支保留但需注释说明属多工具部署模型；修正 init-session.sh 项目模板发现与 SKILL.md:43 的 .zcode 口径矛盾（当前 find 只找 .claude）。

### [P1] F6 — I/O 契约为纯文本，无 JSON Schema + verify_io（机器可校验 I/O 缺失）
- 标准: S67（有契约的子能力应有 JSON Schema + verify_io；缺=P1）
- 位置: `SKILL.md:201-203`（## I/O 契约）
- 证据: `SKILL.md:203` `输入=任务描述/CWD/已有 plan（恢复时用）；输出=规划→plan+思路复述（28.2.1，ask 模式）/执行→checkbox+错误/完成→全部 [x]+验证。...示例：\`mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh\``
- 说明: S2（Input+Output+Example）已满足（三要素齐）。但 task-planner 有明确子能力契约（init 产出 7 文件、attest 锁定、check-complete 终验门控）却没有机器可校验的 JSON Schema + verify_io 门控；契约全靠 LLM 行为 + 各 check-*.sh 分散守。S67 要求「有契约的子能力」配 schema+verify_io。
- 建议: 最低成本=给「四文件罗盘 7 文件产出契约」和「check-complete 终验输入/输出」配 verify_io 断言脚本或 JSON Schema；至少登记为已知缺口（当前为提示级，非阻断）。

### [P1] F7 — 执行中自我纠正无 L1/L2/L3 分级术语（≥2 Phase 需有）
- 标准: S68（≥2 Phase 需 L1/L2/L3 自我纠正；缺=P1）
- 位置: 全文 grep `L1|L2|L3` 无命中（references/ 亦无）；替代机制散见
- 证据: 无 L1/L2/L3 分级；相关但非等价机制: `SKILL.md:151` `## 投诉响应协议与 L0 边界审查`、`SKILL.md:156` `通道不可用快速失败（Rule 83）`、`references/critical-rules.md:178` `83.3 禁 ≥2 次同法重试`
- 说明: task-planner 有投诉响应、Rule 83 快速失败、Rule 22.3 换道、drift-checker 偏移检查等「纠偏」能力，但未按 S68 的 L1/L2/L3 分层显式建模（何种偏差走轻量纠偏 vs 回炉 vs 升级用户）。判定为「机制存在但未按 L1/L2/L3 术语组织」——未验证是否 skill-fix 允许等价替代，保守标 P1。
- 建议: 若 skill-fix 严格要求 L1/L2/L3 术语，则补一节把现有 Rule 83/22.3/decision-arbiter 映射到 L1（单 Phase 内自纠）/L2（跨 Phase 回炉）/L3（升级用户 STOP）；否则登记为术语层面缺口（提示级）。

### [P2] F8 — S40 frontmatter 一致性基本合规，但触发词正交性需跨技能对照（未验证）
- 标准: S40 / S25
- 位置: `SKILL.md:1-22`（frontmatter）
- 证据: `SKILL.md:2` `name: task-planner`（=目录名，合规）；`SKILL.md:5` `allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch"`；`SKILL.md:4` `description: Use when planning, decomposing, or organizing multi-step projects ... more than 5 tool calls. Also use when resuming work after /clear.`
- 说明: S40 无矛盾（name 与目录一致，allowed-tools 与正文 Agent/Skill/TodoWrite/AskUserQuestion 用法一致）。S56 满足（含 Agent() 与 ≥3 Phase，且 allowed-tools 声明了 TaskCreate/Update/List/Get）。S25 触发词与 11 卫星（task-dispatch/task-discipline/verification-gate 等）是否重叠——本次未读卫星 SKILL.md，标注**未验证**。
- 建议: 触发词正交性留待卫星逐一审计时对照（task-dispatch 与 task-planner 都涉及「派发/规划」，重点核查是否互抢）。

### [P2] F9 — S56 满足但 Task* 工具仅 frontmatter 声明、正文未显式流程化
- 标准: S56
- 位置: `SKILL.md:5`（allowed-tools）vs 正文（TodoWrite 为主）
- 证据: `SKILL.md:132` `原生 Todo（\`TodoWrite\`/Task）=执行视图`；`references/todo-sync.md:9` `默认（单会话、Claude/ZCode 通用） | \`TodoWrite\``
- 说明: frontmatter 声明了 TaskCreate/TaskUpdate/TaskList/TaskGet，正文/契约以 TodoWrite 为默认执行视图、Task 系统用于跨会话/子代理。S56 机械满足（工具已声明），但正文未给出「何时切到 TaskCreate」的显式分流（todo-sync.md:10 有场景表，较弱）。
- 建议: 提示级——可保留现状；若要强化 S56，在计划制作循环初始化步明确「跨会话/多任务 → TaskCreate 建持久任务，单会话 → TodoWrite」。

### [P2] F10 — 小：内部注释拼写/行号漂移
- 标准: 内容质量
- 位置: `scripts/check-conflicts.sh:17`；`references/methodology.md:4`
- 证据:
  - check-conflicts.sh:17 `# [2026-09-27 task-v091 S16 C-1c] ... 见 lib/plan-parse.sh`（:2 "task-planner 任务启动前" 应为 "task-planner"，拼写笔误）
  - methodology.md:4 `> **指针入口**：SKILL.md:82（Poka-Yoke 前置门）/ SKILL.md:159 后（内容质量门控）`——当前 SKILL.md 仅 238 行且 Poka-Yoke 在 :56，行号锚已漂移（init-session.sh:385 亦自我标注「SKILL.md:505 已失真」，说明行号锚长期未随文同步是系统性问题）
- 建议: 提示级——注释拼写修正；行号锚建议改为「段落锚/关键词锚」而非易漂移的 SKILL.md:NN 绝对行号。

---

## 未验证项清单（诚实标注）
1. task-dispatch frontmatter 是否误用 `tools:`（前置发现 5）——属卫星，本次范围外。
2. S25 触发词与 11 卫星的正交性——需读各卫星 SKILL.md。
3. references/methodology.md:4 引用的 SKILL.md:82/159 具体指向内容——仅能确认行号漂移，未逐条核对语义。
4. S68 是否 skill-fix 允许「Rule 83/22.3/decision-arbiter」作为 L1/L2/L3 等价替代——取决于 skill-fix 判定口径，保守标 P1。
5. 36 个 .ts 的原始出处（前置发现）——实测 active 仅 3 个，「36」疑似把 .backup/ 快照（全仓 58 .ts）误计入。

## 已验证合规项（供主上下文回收）
- S40 frontmatter name=目录名 ✓；allowed-tools 含 S56 要求的 Task 四件套 ✓
- S56 满足（Agent() + ≥3 Phase + Task* 已声明）✓
- S63 执行流程图 ✓：「计划制作循环」为 markdown `- [ ]` 任务列表，含 初始化/计划确认/执行/终验 ≥4 phase 及门控（attest 锁定、3-File Gate、VC-GATE、drift check）
- S2 I/O 契约三要素（Input/Output/Example）✓（S67 缺 schema）
- S64 引用的 11 卫星目录、references/6 文件、templates 均实际存在 ✓；仅引用形式（../ vs skills/）不一致（F4）
- config.json 本身为 JSON Schema draft-07，additionalProperties:false，required 声明完整，未见平台混用于键值（仅 description 文本提及 .zcode/.claude，见 F5）
