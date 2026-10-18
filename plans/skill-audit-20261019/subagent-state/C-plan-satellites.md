# 深度审计 — 五个卫星技能（plan-resume / plan-template-kit / plan-cost-guard / plan-collab-router / plan-research-router）

> 审计体：skill-fix 标准（只读，未改任何文件）
> 审计日期：2026-10-19
> 已 Read：各 SKILL.md 全文 + 全部 references/ + 全部 scripts/ + config.json + tests/（plan-resume）
> 已验证：跨 skill 相对路径解析、task-planner/scripts 目标存在性、bun/ts-node 运行时、硬编码路径 grep

## 已读文件清单

- plan-resume：SKILL.md(437 行)、references/critical-rules-resume.md、config.json、README.md、scripts/{scan-plans.sh, extract-meta.sh, score-plans.py, select-and-resume.sh}、tests/smoke.sh
- plan-template-kit：SKILL.md(40 行)、references/{template-guide.md, template-mapping.md, critical-rules-template.md}
- plan-cost-guard：SKILL.md(43 行)、references/{cost-control.md, billing.md, cost_log.md, critical-rules-cost.md}
- plan-collab-router：SKILL.md(44 行)、references/{skill-collaboration.md, critical-rules-collab.md}
- plan-research-router：SKILL.md(45 行)、references/{research-routing.md, critical-rules-research.md}

## S40 前置项核查（frontmatter）

- 五个 skill frontmatter 均只有 `name` + `description`，无 `model`/`tools` 字段；`name` 全部 = 目录名 ✓ 无矛盾。
- plan-resume 无 config/无 hook，正文声明「只读」与「不调 task-planner hooks」自洽 ✓。
- 其余四个为纯知识层，正文「无 config/无 hook/无 scripts」与实测目录一致 ✓（四个均无 config.json/scripts/）。

---

## P1 级发现

### [P1] critical-rules-cost.md 内自身 skill 相对路径双重拼接不解析
- 标准: S64（引用歧义）
- 位置: skills/plan-cost-guard/references/critical-rules-cost.md:9, :18
- 证据: L9 `详见 \`../plan-cost-guard/references/cost-control.md\``；L18 `记录到 \`../plan-cost-guard/references/cost_log.md\``
- 说明: 该文件位于 `skills/plan-cost-guard/references/`，按相对基准解析 `../plan-cost-guard/references/...` = `skills/plan-cost-guard/plan-cost-guard/references/...`（**已用 `test -f` 实测不存在**）。真实目标 `cost-control.md`/`cost_log.md` 就与 critical-rules-cost.md 同目录，正确写法应为裸名 `cost-control.md`。LLM 若按字面 Read 会命中缺失路径。
- 建议: 同目录引用改裸名（`cost-control.md`），或统一用 `../../` 基准（但那是跨到 skills/ 层，不适用）。最简=去 `../plan-cost-guard/` 前缀。

### [P1] critical-rules-template.md 内自身 skill 相对路径双重拼接不解析
- 标准: S64（引用歧义）
- 位置: skills/plan-template-kit/references/critical-rules-template.md:8, :16, :27
- 证据: L8 `决策树见 \`../plan-template-kit/references/template-mapping.md\``；L16 `../plan-template-kit/references/template-mapping.md 决策树与清单、companion/agents/plan-writer.md 映射表、SKILL.md 模板节、../plan-template-kit/references/template-guide.md`；L27 `= \`../plan-template-kit/references/template-mapping.md\` §九`
- 说明: 该文件位于 `skills/plan-template-kit/references/`，`../plan-template-kit/references/...` 解析为 `skills/plan-template-kit/plan-template-kit/references/...`（双重拼接，实测不存在）。同目录目标应为裸名。
- 建议: 同 P1-1，去掉 `../plan-template-kit/` 前缀改裸名；`companion/agents/plan-writer.md` 实为 `task-planner/companion/agents/plan-writer.md`（实测存在），宜补 `../../task-planner/` 前缀。

### [P1] plan-template-kit/SKILL.md 跨 skill 引用缺 ../task-planner/ 前缀
- 标准: S64（跨 skill 引用应加 ../ 前缀）
- 位置: skills/plan-template-kit/SKILL.md:24, :26
- 证据: L24 `一致性由 task-planner \`scripts/selftest-template-lifecycle.sh\` 守护`；L26 `计数级联要求=selftest-template-lifecycle TL-17`
- 说明: `scripts/selftest-template-lifecycle.sh` 为裸路径，实际位于 `task-planner/scripts/selftest-template-lifecycle.sh`（**实测存在**，主仓 143 个脚本之一）。卫星本身无 scripts/ 目录，裸 `scripts/...` 语义歧义（易被误读为卫星自身脚本）。
- 建议: 补前缀 `../task-planner/scripts/selftest-template-lifecycle.sh`。

### [P1] plan-resume 引用的 session-catchup.ts 需 bun（缺失）→ S74 BLOCKED
- 标准: S74（运行时实证）+ S64
- 位置: skills/plan-resume/SKILL.md:246（指针）；实体在 skills/task-planner/scripts/session-catchup.ts
- 证据: SKILL.md L246 `task-planner scripts/session-catchup.ts | 该脚本扫 Claude session jsonl...互补`；session-catchup.ts L1 `#!/usr/bin/env bun`、L7 `用法: bun session-catchup.ts [project-path]`；实测 `bun: NOT INSTALLED`、`ts-node: NOT INSTALLED`
- 说明: 文件**存在**（非缺失，主上下文前置发现 #4「缺失」为误报），但 shebang 与文档均要求 `bun` 执行，本机无 bun → 该运行时引用 BLOCKED。注意 scope：session-catchup.ts 属 task-planner 侧，plan-resume 仅将其列为「互补」非自身依赖，plan-resume 自身 4 个可执行脚本为 .sh/.py（无需 bun，可用）。
- 建议: plan-resume 侧无需修复；若需在 ZCode 会话内实际跑 session-catchup.ts，须先装 bun（或把 .ts 转 .sh/.py）。

### [P1] template-guide.md 13 处默认值写死本机绝对路径（S75 D1）
- 标准: S75（迁移性：禁硬编码 /home//Users//mnt/）
- 位置: skills/plan-template-kit/references/template-guide.md:13, 117, 130, 139, 143, 265, 295, 296, 313, 314, 315, 316, 317
- 证据: 形如 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/{filename}`（grep `TASK_PLANNER_ROOT:-/mnt/data` 命中 13 处）
- 说明: 主上下文前置发现 #1 记「12 处」，**实测 13 处**。默认值兜底为本机路径，`TASK_PLANNER_ROOT` 未设时落回 `/mnt/data/...`，迁移到他机即失效。
- 建议: 默认值改用 `$HOME/dev/task-planner`（template-mapping.md L47/92/113 等已用 `:-$HOME/dev/task-planner`，口径应统一）或去掉硬编码默认值。

### [P1] template-mapping.md 硬编码到其他项目 article-generation（S75 D1）
- 标准: S75（迁移性）
- 位置: skills/plan-template-kit/references/template-mapping.md:118, 120
- 证据: L118 `mkdir -p /mnt/data/dev/article-generation/.claude/plan-templates/`；L120 `cp ... /mnt/data/dev/article-generation/.claude/plan-templates/task_plan.md  # （示例路径，仅作格式示意）`
- 说明: 写死到**另一个项目**的 `.claude/plan-templates/`。L120 已标「示例路径，仅作格式示意」（部分豁免），但 L118 的 `mkdir -p /mnt/data/dev/article-generation/...` 是可执行形态且无豁免注，命中 P1。
- 建议: 两行统一改占位符（`/path/to/project/...`，与 template-guide.md L114/120 的 `/path/to/project/.claude/` 一致）或补「示例，仅作格式示意」注。

### [P1] plan-resume/tests/smoke.sh 硬编码 /home/terry 本机路径（S75 D1）
- 标准: S75（迁移性）
- 位置: skills/plan-resume/tests/smoke.sh:65, 72, 80, 83, 89, 97, 98, 103
- 证据: L65 `sc_check "scan-plans /home/terry/.zcode 产 >=1" /home/terry/.zcode '^/home'`；L80 `em_check ... /home/terry/.zcode/plans/task-skillfix-bun-finish/task_plan.md`；L89 `"$SCAN" /home/terry/openspec`；L103 `cp /home/terry/.local/share/uv/tools/specify-cli/lib/python3.13/site-packages/...`
- 说明: 自检脚本对真实用户目录 `/home/terry/` 断言（`.zcode/plans`、`openspec/changes`、uv site-packages），换机即 FAIL。属测试夹具但为可执行脚本，非「示例文字」，命中 P1（主上下文前置发现未列此项，本次补登）。
- 建议: 改由环境变量注入根目录（`SCANNING_ROOT` 缺省 `~/.zcode`），或降级为 skip 提示而非断言失败。

---

## P2 级发现（提示级）

### [P2] plan-resume SKILL.md 437 行，远超「核心执行指南 ≤100 行」建议
- 标准: S63（执行流程可读性）/ 长度约定
- 位置: skills/plan-resume/SKILL.md（全文 437 行，其中 §7「自主推进模式」约 170 行、§7.10「自主决策框架」约 30 行）
- 证据: `wc -l` = 437；§7 起于 L269 到 L434；正文含 6 步工作流 + §7.x 十节
- 说明: 主上下文前置发现 #5 复现。§7 决策自主化契约密度高，与 §5/§6 报告格式存在内容重叠（§7.6 报告输出 与 §5.1 报告格式 双份描述）。
- 建议: 将 §7.1-7.10 抽到 `references/autonomous-mode.md`，SKILL.md 保留触发矩阵 + 指针行（对齐其余四卫星「正文瘦、references 厚」范式）。

### [P2] plan-resume 有 6 步执行工作流，但无 markdown 任务清单、无显式门控标记
- 标准: S63（执行流程图：markdown 任务列表，≥2 phase，含门控）
- 位置: skills/plan-resume/SKILL.md「## 工作流(六步)」L40 起
- 证据: `grep -c '^\s*- \[ \]' SKILL.md` = 0；`grep -c '门控\|gate' SKILL.md` = 0（门控语义散落在 §7 circuit-break 与 §7.10 四项测试，非独立 checklist 形态）
- 说明: 门控逻辑存在（circuit-break 五条件、§7.10 T1-T4、单次 ≤1 plan、跨仓只报告），但未以「markdown 任务列表 + 每 phase 门控」形式收敛。属提示级，非硬违规。
- 建议: 若按 S63 强化，可在六步工作流处补一张 `- [ ]` 门控清单。

### [P2] 四个纯知识/路由卫星无显式 I/O 契约（Input+Output+Example）
- 标准: S2（I/O 契约）— 缺=提示
- 位置: plan-template-kit / plan-cost-guard / plan-collab-router / plan-research-router 各 SKILL.md
- 证据: grep Input/输出/Example：四者 `Input=0`，Output 计 0-1，Example 计 0-1
- 说明: 四卫星为「查表路由」型（读 references 给决策），本身无机器 I/O；但缺 Input/Output/Example 契约块，与 plan-resume（有 §5.1 报告格式 + 脚本 I/O）不对称。提示级。
- 建议: 可选补「Input=用户路由问题 / Output=命中 reference 段 + 决策 / Example=一句话」契约行；优先级低。

### [P2] plan-cost-guard/SKILL.md L29 描述的 `references/critical-rules.md` 字面形式与文档实态不符
- 标准: S64（自描述一致性）
- 位置: skills/plan-cost-guard/SKILL.md:29
- 证据: L29 `本技能文档中的 \`references/critical-rules.md\` 指针指向主技能 task-planner/references/critical-rules.md（跨技能指针...）`
- 说明: 实际 cost-guard 各 references（cost-control.md L168、cost_log.md L7/L69）用的是 `../../task-planner/references/critical-rules.md`（**正确、可解析**），并无裸 `references/critical-rules.md` 字面。L29 描述的形式在文档中不存在，属描述漂移。提示级（不阻断）。
- 建议: L29 改为「本技能 references 用 `../../task-planner/references/critical-rules.md` 指向主侧 Rule 17 载体」。

### [P2] 五卫星均无 TaskCreate/TaskUpdate/TaskList/TaskGet（S56 提示级）
- 标准: S56（含 Agent() 或 ≥3 Phase 须含 Task* 三件套）
- 位置: 五个 SKILL.md
- 证据: `grep -rn 'TaskCreate\|TaskUpdate\|TaskList\|TaskGet'` 五目录命中 0
- 说明: 五卫星无 `Agent()` 直接派发（cost-guard/collab-router 中 `Agent(...)` 仅为表格描述非调用）；plan-resume 的「六步」为程序步骤非 task-planner Phase，实际 Phase 执行委派给 task-planner。故 S56 触发面弱，判提示级而非硬违规。若 plan-resume §7 自主续推被视作多 Phase 编排，建议补 Task* 追踪条款。

---

## S74 运行时实证（BLOCKED）

- 本机 `bun: NOT INSTALLED`、`ts-node: NOT INSTALLED`。
- 五卫星自身可执行物：plan-resume 4 脚本（scan-plans.sh / extract-meta.sh 为 bash，score-plans.py 为 python3，select-and-resume.sh 为 bash）——**均不依赖 bun**，可用；score-plans.py 需 `python3`（本机在位即可）。
- BLOCKED 项：仅 `task-planner/scripts/session-catchup.ts`（`#!/usr/bin/env bun`）需 bun，且属 task-planner 侧非本审计五技能本体。

## S25 触发词正交性（PASS，附注）

- 五卫星触发词彼此正交：plan-resume=「继续上次任务/扫一下计划/stale plans」、template-kit=「计划模板/加任务类型/模板定制」、cost-guard=「技能成本/计费/opus 成本控制」、collab-router=「该用 comet 吗/技能协同路由」、research-router=「调研路由/怎么查资料/找 issue」。
- 未发现跨卫星误触发重叠。与 task-planner 核心的边界各 SKILL.md 均有「排除」声明（template-kit 排除执行期建计划、cost-guard 排除性能优化、research-router 排除已知 URL 简读、collab-router 排除 /workflow 动态编排）。PASS。

## 主上下文 5 条前置发现 核验结论

1. S75 D1 硬编码 — **复现并扩证**：template-guide.md 实测 13 处（非 12）+ template-mapping.md 2 处跨项目 + smoke.sh 8 处 /home（补登）。
2. plan-cost-guard SKILL.md L29 跨技能引用 — **降级为 P2**：实际文档用正确的 `../../task-planner/`，L29 仅为描述漂移。
3. plan-template-kit 引用 selftest-template-lifecycle.sh「缺失」— **误报**：文件存在于 task-planner/scripts/（143 脚本之一）；实为「裸路径缺 ../ 前缀」P1 歧义（见 P1-3）。
4. plan-resume 引用 session-catchup.ts「缺失」— **误报**：文件存在于 task-planner/scripts/；实为「需 bun，S74 BLOCKED」（见 P1-4）。
5. plan-resume SKILL.md 437 行 — **复现**：P2 提示级（见 P2-1）。

## 未发现违规（明确 PASS 项）

- frontmatter name=目录名：五者全部一致 ✓
- 跨 skill `../../task-planner/references/critical-rules.md` 引用：cost-control.md L168、cost_log.md L7/L69、template-mapping.md L43 均解析正确 ✓
- 六核心目标脚本/文件全部存在（session-catchup.ts、selftest-template-lifecycle.sh、29 个 variant 模板、13 个顶层模板）✓
- 触发词正交、无跨卫星重叠 ✓
- 五卫星无 `.zcode`/`.claude` 混用违规（template-guide 双平台说明为「示例文字」，S75 豁免）✓
