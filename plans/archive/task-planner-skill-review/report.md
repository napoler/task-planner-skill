# task-planner 技能审查报告

> 产出位置：`plans/task-planner-skill-review/report.md`（本报告路径按任务指定创建）。
> 基线 commit：`f926af6`（本次会话实跑 `git rev-parse --short HEAD` 确认）。
> 依据材料：四领域审计 + 两轮批判意见。本报告只使用给定材料中列出的事实，不新增未列明的结论。

## ① 总体结论

4 个领域共 28 条汇总发现（27 confirmed + 1 unconfirmed，计数与材料一致），方向总体正确，但经两轮批判指出存在同一根因重复计数（`dwf.ts:90` 门命令把 7 个非 shell 脚本纳入 `bash -n` 被 5 条 finding 各计一次，按根因去重后实质 distinct 约 17 条）、4 个遗漏维度，以及数字口径与证据充分性问题。关键可复核事实：仓侧 66 个 `.sh` 全部通过 `bash -n`、27 个 selftest 共 453 条断言 PASS=453 FAIL=0（材料记载已实跑复验）；"门未全绿" 的唯一根因是门命令的语言误判（`.cjs` 应改用 `node --check`），该门本身恒定假阳性。需注意结论的 as-of 边界：'全仓 453/0 全绿' 在部署位 `/home/terry/.zcode/skills/task-planner` 不成立（WF-10 部署位 FAIL，见 ② 领域 4 与 ④），且 v090 草案（09-25 生成、未运行）落地后部分结论会系统性失效。

## ② 按领域分节

### 领域 1：SKILL.md、README 与 12 个 references/ 文档

材料记载：门未全绿的原因已定位（`bash -n` 门把 7 个非 shell 脚本——2×.ps1 / 2×.cjs / 3×.ts——也当 bash 语法检查；66 个 `.sh` 全部通过；27 个 selftest 共 453 条断言 PASS=453 FAIL=0，与题述一致，已实跑复验）。文档侧 7 处有证据的漂移。`references/` 12 篇单篇均 <500 行，SKILL.md 558 行是唯一超线文件。

| # | 严重度 | 状态 | 发现与证据 |
|---|--------|------|-----------|
| 1 | high | confirmed | `skills/task-planner/scripts/{check-complete.ps1, init-session.ps1, plan-created.cjs, task-plan-init.cjs, register-hooks-cj.ts, session-catchup.ts, sync-ide-folders.ts}`：确定性门中 `bash -n` 失败项全部来自把 7 个非 shell 脚本纳入 bash 语法检查；`.sh` 零失败。门规则或文件集需要区分语言。 |
| 2 | medium | confirmed | `references/critical-rules.md:49`：Rule 12 仍写已废止的旧 worktree 路径 `../<repo>-wt-<task-id>`，与 worktree-isolation.md §3「旧约定已废止」及用户宪法 §11.2 强制的集中目录 `<repo-parent>/<repo>-worktrees/<task-id>` 直接矛盾；新路径在 SKILL.md 与 references/*.md 全文 grep 无命中，正文任何条款都未声明新路径。 |
| 3 | medium | confirmed | `references/critical-rules.md:61`：Rule 16 的 grep 验收锚「= 21」已漂移为 22，且该验收条款指向「template-mapping.md §八」，但 template-mapping.md 内并无此 grep 断言（断言主体只在 critical-rules，指针落空）。「全部模板标配知识储备」与 mini-lite / knowledge-brief / shared-tracker 三个模板实际缺失该段也矛盾。 |
| 4 | medium | confirmed | `README.md:23,32,35,37,107,205,228`：README 多处数字与仓库现状脱节（规则篇数 / 脚本数 / 提交数 / smoke 断言数 / 行号 / 模板段覆盖），读者按 README 复核会全部对不上。 |
| 5 | medium | confirmed | `references/goal-gate.md:7`：goal-gate「≥5 条 VC」未同步 Rule 38.2/38.4② 的 mini 档豁免（VC 下限 5→2），按 goal-gate 字面执行会把合法 mini 计划判为不合规。 |
| 6 | low | confirmed | `SKILL.md:70`：「确认创建了 5 个文件」与同文件 L352/L556「init-session 第 6 文件 knowledge-brief.md」及 init-session.sh 头注释「5 文件→6 文件」矛盾，校验步骤清单缺 knowledge-brief。 |
| 7 | low | confirmed | `SKILL.md:455`：两处行号前向引用陈旧——L455 指「代码编辑」三行为 322-324 实为 372-374；L507 指「§反模式 353-361 行」实为 402-412（标题 402、条目 404-412），按所给行号 Read 复核会读到无关内容。 |
| 8 | low | confirmed | `reference.md:235`：「§ 五问重启测试」标题与首句称 5 问，表内实际 6 行（第 6 问「哪些任务待处理」为后补未改名）；SKILL.md L8/L342 frontmatter 与 References 表仍以「5Q」称呼该节，名称/内容/称呼三方不齐。另 SKILL.md 558 行已超题述 500 行健康边界，而全仓 selftest 无 SKILL.md 行数守护（grep 0 命中），该边界目前无机器兜底。 |

### 领域 2：critical-rules 与 11 个模板

材料记载：selftest 侧复跑全绿（27 脚本 453/0 断言 PASS、exit 全 0）；唯一门失败项是 `bash -n` 扫描对 `scripts/*.cjs`（plan-created.cjs / task-plan-init.cjs）的误判——它们被当 shell 脚本解析必失败，`node --check` 均通过；纯 shell 脚本（`scripts/*.sh` + `lib/*.sh`）`bash -n` 零失败。另发现 6 条文档/门控漂移（按重要性）：门命令 cjs 误解析 [high] > Rule 16 计数 21→22 [medium] > video 类型未入 §九矩阵/决策树（Rule 34.2 四点同步缺口）[medium] > worktree 旧路径示例残留 [medium] > goal-gate 未同步 mini 降档 [low] > SKILL『5 个文件』未随第 6 文件更新 [low]。模板 Status/V-N/checkbox 字面量与 check-complete.sh、check-plan-dispatch.sh、check-3file-gate.sh 的解析口径（`### Phase` / `- **Status:**` / `- [ ] V-P.N:` 与 `- **V-N:**` 紧凑式 / 模板行剔除）经读码比对为兼容。

| # | 严重度 | 状态 | 发现与证据 |
|---|--------|------|-----------|
| 9 | high | confirmed | `.zcode/workflow-drafts/task-planner-技能审查.dwf.ts:88-92`（门命令）→ `scripts/plan-created.cjs`、`task-plan-init.cjs`：门的 `bash -n` 扫描把 `scripts/*.cjs` 当 shell 脚本解析，两个 Node CJS 文件必然语法报错，导致该门恒定显示『存在失败项』，但脚本本身无语法错误。 |
| 10 | medium | confirmed | `references/critical-rules.md:61`：Rule 16 的知识储备段验收命令写死 `grep -rl "## 📚 必要知识储备" templates/ \| wc -l` = 21，实际当前计数已漂移为 22，验收锚点失准。 |
| 11 | medium | confirmed | `references/template-mapping.md` §九机制适用性矩阵（L204 起）与 §一 决策树：video 类型模板（`templates/variant/video-type.md`）既不在 §九 矩阵也不在 §一 决策树，违反 Rule 34.2『新增/沉淀模板类型时四点同步』。 |
| 12 | medium | confirmed | `references/critical-rules.md:49` 与 `templates/task_plan.md:232`：Rule 12 与 task_plan 模板隔离决策表仍以已废止的旧 worktree 路径约定 `../<repo>-wt-<task-id>` 为例值，与强制的集中目录 `<repo-parent>/<repo>-worktrees/<task-id>` 直接矛盾。 |
| 13 | low | confirmed | `references/goal-gate.md:7-8`：goal-gate 权威源写死『≥5 条 VC、每 phase ≥2 条 V-N』，未反映 Rule 38.4② 的 mini 档降档；模板 mini-lite 用户照 goal-gate 判读会与机器门控行为不一致。 |
| 14 | low | confirmed | `SKILL.md:70`：SKILL 初始化流程『确认创建了 5 个文件』未随 task-v067 第 6 计划文件（knowledge-brief.md）更新，脚本实际校验/复制 6 个文件。 |

### 领域 3：config.json、scripts/ 与 lib/

材料记载：对 skills/task-planner 的 config.json/scripts/lib 做了只读审计。复跑结果：全仓 75 个 `.sh` 逐文件 `bash -n` 全部通过（0 失败）——「bash -n 语法检查存在失败项」无法在 `.sh` 范围内复现，失败只会出现在把 7 个 `.cjs/.ts/.ps1` 也纳入 `bash -n` 的情形（全部 7 个报语法错，实测有错误输出）；27 个 selftest 逐一执行，Total 行求和 = 453 断言、0 FAIL、27 个脚本全 rc=0（与「453/453 PASS」记载一致）；tests/smoke.sh 17 pass / 0 fail。

| # | 严重度 | 状态 | 发现与证据 |
|---|--------|------|-----------|
| 15 | high | confirmed | `scripts/subagent-fallback.sh:46-52`：load_config 四层 jq 单层路径全部解析为 null，config 覆盖静默失效；且 T08 校验便捷路径 `.default.enabled` 未捕获漂移。 |
| 16 | high | confirmed | `scripts/check-plan-dispatch.sh:115-116`：step_max_minutes / step_max_files（及 check-dispatch.sh:268 prompt_max_chars）jq 单层路径得 null 后经 `//` 兜底静默回退默认值，用户 config 覆盖不生效；同文件 :118 已修正为双层，两种写法并存。 |
| 17 | medium | confirmed | `scripts/check-complete.sh:549-550`：VC-GATE 阈值硬编码 5/2（mini 2/1），从不读 config.json 的 max_vc / min_verification_per_phase；config description 声称与门控联动但实际脱钩。 |
| 18 | medium | confirmed | `config.json:6-50`：约 13 个 config 键在 scripts/ lib/ 无任何消费者（顶层 7 键 + subagent 块 6 键，retry_limit 仅注释/输出文字提及）。**批判意见 ④ 已指出该条证据不足（见 ④ 第 5 条），应按逐键消费者清单补证或降级为「抽样未验证」。** |
| 19 | medium | confirmed | `scripts/check-doc-sync.sh:12`：头部注释引用不存在的 config 键 sync_interval_calls；实现实读 plan_update_interval_minutes 且 10 分钟兜底与 config default=15 不一致。 |
| 20 | medium | confirmed | 门控总览 `bash -n`（ask 材料第 6 条）：门控 `bash -n` 失败项无法在 `.sh` 范围复现——75 个 `.sh` 全绿，失败只能来自把 7 个非 shell 文件纳入 `bash -n` 检查（与领域 1 第 1 条、领域 2 第 9 条同根因，批判意见 ① 判定为重复计数）。 |
| 21 | low | confirmed | `references/cost-control.md:143-152`：§七 声明 3 个 hook 注入点但两个 hook 脚本中对应标记 0 命中，表与代码脱同步（文件自注承认未实现）。 |
| 22 | low | confirmed | `scripts/selftest-*.sh`：check-conflicts / check-drift / check-doc-sync / ledger-append 4 个守卫脚本无 selftest 覆盖；现有 config 键守护（T08 等）未覆盖 jq 路径正确性。 |

### 领域 4：27 个 selftest 的覆盖与可运行性

材料记载：只读审计 27 个 `scripts/selftest-*.sh`；本次实跑 3 轮全部通过，每轮断言 453 条 PASS=453 FAIL=0（与门总览 453 一致）；`bash -n` 对 27 个 selftest 及全部 `scripts/*.sh`、`lib/*.sh`、install/uninstall.sh 均通过。门总览『`bash -n` 存在失败项 / 门未全绿』是假阳性（dwf.ts:90 把 2 个 .cjs 喂给 bash -n 必报 SYNTAX-FAIL，node --check 实跑通过）；不存在需要定位的失败 selftest。

| # | 严重度 | 状态 | 发现与证据 |
|---|--------|------|-----------|
| 23 | high | confirmed | `.zcode/workflow-drafts/task-planner-技能审查.dwf.ts:90`：语法检查命令 `for f in scripts/*.sh scripts/*.cjs lib/*.sh; do bash -n "$f"` 把 2 个 .cjs JavaScript 文件（plan-created.cjs、task-plan-init.cjs）也纳入 `bash -n`，必报 SYNTAX-FAIL，导致门总览固定出现『`bash -n` 语法检查存在失败项』『门未全绿』的假阳性；.cjs 应改用 `node --check`。 |
| 24 | medium | confirmed | `scripts/selftest-skill-modify.sh:60`：Total 行格式不一致——skill-modify 的 Total 含 SKIP 计数（Total=PASS+FAIL+SKIP）并带 `(SKIP=%d)` 尾巴，与其余 26 个脚本 Total=PASS+FAIL 口径不同；且家族内 echo/printf、1 空格/2 空格共 4 种变体并存。 |
| 25 | medium | **unconfirmed** | `SKILL.md:290`（Rules 1-39 索引）：19 条 Rule 没有任何专属 selftest 守护（Rules 1-7、9-17、19-21、23、24、26、27）——本条为 28 条中唯一的 unconfirmed 标注。 |
| 26 | medium | confirmed | `.zcode/workflow-drafts/task-planner-技能审查.dwf.ts:131`（门总览判定语句）：『门未全绿，请重点定位失败脚本』的判定基于 F1 的 `bash -n` 假阳性；27 个 selftest 本身全绿，不存在需要定位的失败脚本。 |
| 27 | medium | confirmed | `scripts/check-conflicts.sh`、`check-drift.sh`、`check-doc-sync.sh`、`plan-doctor.sh`：4 个被接线/被引用的脚本在 27 个 selftest 中零引用（无行为测试亦无静态锚守护），与其他 check-*.sh 脚本（check-dispatch / check-plan-dispatch / check-rescue-chain / check-3file-gate / check-template-type 均有 selftest 引用）形成覆盖落差。**批判意见 ⑤ 指出『plan-doctor 被接线』措辞无据（未查接线证据），应改为「5 个脚本零 selftest 引用」口径（补上 ledger-append）。** |
| 28 | low | confirmed | `scripts/selftest-conclusion-discipline.sh:63,79,80`：宽容锚注释/代码/文案三方区间漂移 [5-7]/[5-8]/[5-9]（头部注释 L9/L17/L25 称 '1-3[5-7]'，CD-11/CD-18 实际代码用 [5-9]，CD-19 的 grep 模式仍是 [5-8] 且消息文案写 1-3[5-8]）；当前全部通过是巧合（SKILL.md 现值 '1-39' 三种区间都命中）。 |

## ③ 确定性门结果

| 检查 | 结果 | 证据（材料记载） |
|------|------|-----------------|
| selftest 断言总数 / 通过数 | 27 个 selftest 共 453 条断言，PASS=453 FAIL=0；27 个脚本全 rc=0 | 领域 3 记载「逐一执行，Total 行求和 = 453、0 FAIL」；领域 4 记载「实跑 3 轮，每轮 453 PASS」；领域 1 记载「与题述一致，已实跑复验」 |
| `bash -n` 语法检查 | 仓侧 `.sh` 全绿：66 个 `.sh` 全通过（领域 1 口径）/ 75 个 `.sh` 逐文件全通过 0 失败（领域 3 口径）；27 个 selftest 及 install/uninstall.sh 亦通过 | 失败项**全部**来自 7 个非 shell 文件（2×.cjs + 2×.ps1 + 3×.ts）被纳入 `bash -n`（dwf.ts:90 门命令）；`node --check` 两个 .cjs 均通过 |
| tests/smoke.sh | 17 pass / 0 fail | 领域 3 记载；批判意见另指出 README 宣称 16/16，即为「数字漂移」finding 之一 |
| 门总览结论 | 「门未全绿」判定为假阳性，无失败的 selftest 需要定位 | dwf.ts:90 假阳性 + dwf.ts:131 判定语句（领域 4 第 23、26 条） |

## ④ 两轮批判意见摘要与处置

**批判结论**：4 领域 28 条汇总（27 confirmed + 1 unconfirmed，计数与材料一致），总体方向正确，但存在系统性重复计数与 4 个遗漏维度，且「selftest 全绿 453/0」结论在 2026-09-25 部署位已被现场事实击穿。批判意见共 10 项，逐条处置如下：

| # | 批判意见 | 处置 |
|---|---------|------|
| 1 | **重复计数·主因**：`dwf.ts:90` 门命令（`for f in scripts/*.sh scripts/*.cjs lib/*.sh; do bash -n`）把 7 个非 shell 文件纳入 bash -n 是唯一根因，被 5 条 finding 各计一次（docs/high、critical/high、config/medium、selftests/high+medium）；批判者实跑复现（7 个文件逐个 FAIL、node --check 两个 .cjs 均 OK）；去重后 28 条实质 distinct 约 17 条 | 本报告 ② 中第 1、9、20、23、26 条在对应行标注「同根因/重复计数」；汇总数字 28 保留（与材料一致），但读者应按约 17 条 distinct 理解 |
| 2 | **跨轮矛盾+遗漏维度（部署位 vs 仓侧）**：双跑 selftest-workflow-orchestration.sh——仓侧 Total=12 PASS=12 FAIL=0（WF-10 命中总和 6≥6）；部署位 `/home/terry/.zcode/skills/task-planner` Total=12 PASS=11 FAIL=1（WF-10「Rules 1-39 命中总和 3 <6」）。根因：WF-10 按 `SKILL_ROOT/../../CLAUDE.md`、`SKILL_ROOT/../../README_zh.md` 相对路径解析，部署位 `../../` 落到 `/home/terry/.zcode/`，该处无 CLAUDE.md/README_zh.md（ls 确认），缺失计 0 导致 3<6。「全绿」结论须加 as-of 部署位限定；「selftest 对运行位置不鲁棒（WF-10 相对路径假设）」应提为 1 条新 confirmed/high | 本报告 ① 已加 as-of 边界声明；该条为新发现（材料 28 条未含），列为新 confirmed/high，见 ⑤ 未覆盖项说明 |
| 3 | **内部矛盾·无人指出**：Rule 16「全部模板标配知识储备」与 README.md:23「全部 25 个模板统一含必要知识储备」与实测矛盾——验收命令复跑 = 22，`grep -L` 反查缺失 3 个：`templates/variant/mini-lite-type.md`、`templates/knowledge-brief.md`、`templates/shared-tracker.md`；「计数 21→22」与「正文声称全部标配」与「README 全部 25 个」实为同一根因，又被 critical 领域与 README 漂移 finding 各计一次（重复计数） | 本报告 ② 领域 1 第 3、4 条对应「同根因」；正文声明失实部分并入 ⑤ 未覆盖项说明 |
| 4 | **数字口径错**：「config.json 440 键」实为 440 行（wc -l=440；jq 顶层 6 键、properties 40 键），错植于 v089 task_plan 知识表并被 dwf.ts:118 带入 config 领域 brief | 凡引用「440 键」的发现需降级；本报告 ② 第 18 条（config 死键）的基数口径应为「440 行 / properties 40 键」 |
| 5 | **证据不足**：「约 13 个死键」无逐键消费者清单；批判者抽查 8 个可疑键中 7 个有消费者（provider_fallback 3 个文件、findings_stale_minutes 2、progress_stale_minutes 2、plan_update_interval_minutes 2、prompt_note_interval 1、todo_sync_interval_calls 1），仅 max_tool_calls_before_refresh 实测 0 消费者；该条应降级为「抽样未验证」并补逐键 grep 清单 | 本报告 ② 第 18 条已按此降级标注 |
| 6 | **证据不足**：「plan-doctor.sh 被接线但 27 个 selftest 零引用」——批判者未查任何接线证据（hook/installer 引用面），措辞无据，应改为「5 个脚本零 selftest 引用」（check-conflicts/check-drift/check-doc-sync/ledger-append/plan-doctor，selftest grep 全 0 引用） | 本报告 ② 第 27 条已按此口径标注 |
| 7 | **流程矛盾：汇总先行 vs 源计划未闭环**：批判时刻 `plans/task-planner-skill-review/` 目录不存在（ls 确认 No such file，task_plan VC-1 要求的交付报告未落盘）；task-v089 task_plan.md Phase 1=in_progress、Next Step=「提交修正后的工作流脚本并等待用户确认运行」；findings.md / progress.md 仍为空模板；INDEX.md 完成列表止于 task-v088 且 grep v089 无命中——VC-4（三文件回填 + INDEX 刷新）未满足，28 条汇总先于计划闭环产生 | 本报告落盘即履行报告交付；v089 三文件回填与 INDEX 刷新属后续闭环动作，列入 ⑤ 未覆盖项说明 |
| 8 | **遗漏维度 1：as-of 时间戳 + 基线 commit**：仓 HEAD=f926af6；28 条 confirmed 无一携带审计时刻与基线 commit；09-25 已有未落地的 v090 草案 task-planner-workflow-auto-activation.dwf.ts（09-25 03:49 生成），无时间戳的结论在 v090 落地后会系统性失效 | 本报告头部标注基线 commit f926af6；as-of 限定在 ① 与 ⑤ 中声明 |
| 9 | **遗漏维度 2：v090 草案与 v089 的重复计数风险**：v090 草案（task-v090，09-25 生成、未运行、plans/ 下无 task-v090 目录）的 5 维缺口清单与 v089「机器守卫/selftest 覆盖」「Rule 39 文档漂移」维度高度重叠，尤其 WF-10 部署位 FAIL 本身就是「机器层 1-39 级联漂移」实证；两份产出合并需按 文件:行 锚点做 finding 级去重 | 本报告 ⑤ 中作为未覆盖/后续事项列出 |
| 10 | **遗漏维度 3 + 4：汇总自身可复核性 / 前轮批判材料缺失**：按仓内 verification.md「随机抽 3 条 Read 原始锚点复现」纪律，材料 28 条无一附 文件:行 原始证据，抽查不可执行，confirmed/unconfirmed 标注在实现上无区分力；前轮 Critique JSON 原文未附，无法核对前轮意见是否被本轮处置（材料未提供，如实标注） | 本报告 ② 各 finding 均携带材料给出的 文件:行 锚点以支持复核；前轮批判 JSON 原文缺失在 ⑤ 中如实标注 |

## ⑤ 未覆盖项说明

1. **新 confirmed/high（批判者提出、28 条未含）**：selftest-workflow-orchestration.sh 在部署位 `/home/terry/.zcode/skills/task-planner` WF-10 断言 FAIL（命中总和 3<6），根因是 WF-10 按 `SKILL_ROOT/../../` 相对路径解析仓根文档、部署位路径不可达；「仓侧 453/0 全绿」结论须限定为 as-of 仓侧，且「selftest 对运行位置不鲁棒」应立为独立 finding。该条由批判者实跑复现，本报告未另行复跑。
2. **正文声明失实（批判意见 ③，未单列为 finding）**：critical-rules Rule 16「全部模板标配知识储备」与 README.md:23「全部 25 个模板统一含『📚 必要知识储备』章节」两处正文声明与实测缺失的 3 个模板（mini-lite-type / knowledge-brief / shared-tracker）矛盾。
3. **源计划 v089 未闭环**：批判时刻 `plans/task-planner-skill-review/` 目录不存在、task-v089 的 findings.md / progress.md 为空模板、INDEX.md 止于 task-v088，VC-4（三文件回填 + INDEX 刷新）未满足；本报告落盘履行报告交付，v089 三文件回填与 INDEX 刷新属后续动作。
4. **v090 草案未运行**：`.zcode/workflow-drafts/task-planner-workflow-auto-activation.dwf.ts`（task-v090，09-25 03:49 生成）与 v089 维度重叠，若并行产出需按 文件:行 锚点做 finding 级去重；v090 落地后本报告部分结论会失效。
5. **汇总可复核性受限**：材料 28 条原始汇总未附 文件:行 锚点（本报告 ② 已按材料给出的锚点逐条列出）；前轮 Critique JSON 原文材料未提供，无法核对前轮意见的处置情况（如实标注）。
6. **口径修正待全文传播**：「440 键」→「440 行 / properties 40 键」需修正 v089 task_plan 知识表与 dwf.ts:118 中的引用；「13 个死键」需补逐键消费者 grep 清单后方可维持 confirmed 标注。
7. **本报告未执行的检查**：本报告撰写过程中仅实跑了目录创建与 `git rev-parse`（基线 commit 确认）；③ 中的 selftest 453/0、`bash -n` 全绿、smoke 17/0 均为审计材料记载的结果（材料称已实跑复验），本报告未在其基础上再次重跑全量 selftest 或逐文件 `bash -n`。
