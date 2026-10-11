# Knowledge Brief — task-v097-tool-selection（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出（2026-09-30），执行期持续回填。
> 内容来源：本 brief 全部条目来自 plan-writer 于 2026-09-30 实际 Read 过的仓库文件（critical-rules.md / SKILL.md / templates/ / scripts/selftest-* / config.json / check-delegation.sh / smart-merge-back.sh / plan-template-kit 两文档 / companion/agents/plan-writer.md / plans/task-v096 同族计划），证据锚以当日 master 工作区实测为准，执行期动手前先 grep 复核漂移。

## §1 任务速览与核心概念

- 任务一句话：在 critical-rules.md 纯增量落地 Rule 40「harness 工具面主动选择」（40.1-40.6 六子条，零新 config 键），同步 SKILL.md 四锚 + 模板三落点 + 卫星两文档 + plan-writer 契约 + 新建 selftest-tool-selection.sh，全量 0 FAIL 后合并回 master 并部署三实体位。
- 背景/动机：用户要求 task-planner 计划期能结合 /workflow、/goal 等 harness 工具动态优化执行，并按任务类型主动分析选择最合适的执行工具——现状计划期只有「串行 Agent 派发」一条默认路，工具面无清单无分析区块。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 工具面（40.1） | harness 已有的六类执行工具：/workflow（=CreateWorkflow 族）、/goal 会话目标、Agent 子代理、卫星技能、MCP（web_reader/node_repl）、机械守卫脚本 |
| 「🧰 工具选择与编排」区块（40.2） | general 模板新增区块，plan-writer 计划期逐 Phase 标注执行工具与理由；是 Executor 字段的**上游分析记录，不替代**其委派门控机器事实源地位 |
| /goal 对齐（40.3） | 计划 Goal+VC 与 /goal 自主会话 session goal 的映射指引；必须如实披露 /goal 是用户侧 harness 命令，技能层不可代调（Rule 35.2 防虚构） |
| workflow 编排计划期路径（40.4） | 计划期工具分析命中编排条件（独立并行子任务/fan-out/长链复用）时**建议登记** CreateWorkflow 并按 39.4 做并行豁免登记；Rule 39.1「用户显式点名才路由」原文不动 |
| 零新 config 键（40.6） | 与 task-v087/v088 同范式：判定面=LLM 行为无需门控键，机器面只加 selftest 静态守护；WF-12 断言 config properties=40 维持 |
| mini-lite 豁免 | Rule 38.3 轻量模板区块白名单超限=模板违约；mini-lite-type.md 须以声明行明确豁免不加「🧰」区块 |
| 三位部署 | ~/.zcode/skills/task-planner、~/.claude/skills/task-planner、~/.config/opencode/skills/task-planner（smart-merge-back --deploy SLOTS 三路）；companion/agents/*.md 另经 install-companion.sh 部署到各位 agents/ |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 本仓默认分支是 master（非 main） | `git -C /mnt/data/dev/task-planner-skill branch` 实测 main/master 双本地分支,`* master` 当前;worktree-isolation 命名 SOP | worktree 建立命令须 `-b wt/task-v097-tool-selection master`;smart-merge-back 默认 --base master 兼容 |
| selftest 共 37 个 .sh 文件（含 selftest-registry.sh 自守护）,tsv 37 行含表头 | `ls scripts/ \| grep selftest` 计 37;`wc -l selftest-registry.tsv` =37 | 新增 selftest-tool-selection.sh 后 registry 须 +1 行且 rows=actual 双向核对;全量基线数=37+1=38 预期（以 P1 实测为准） |
| v096 收官基线=36 脚本 592 PASS/0 FAIL | plans/task-v096-template-auto-record/task_plan.md:141「36 脚本 592/0」 | 仅作记忆参考,本任务基线以 P1 worktree 内实跑逐 Total 行求和为准 |
| SKILL.md 行数 ≤558 断言共 5 处（另有 skill-split ≤430 目标线） | selftest-knowledge-brief.sh:38、selftest-skill-collab.sh:82、selftest-skill-split.sh:41（≤430 目标+≤558 上限）、selftest-execution-stability.sh:72、selftest-batch-pilot.sh:55;SKILL.md 实测 430 行 | P2-S2 净增行数必同步上调这 5 处上限（label 注明 task-v097）;同时 430 目标线已被 v095 拆分压到 430,净增预算紧张,行位替换优先 |
| 「Rules 1-39」级联锚:SKILL.md 2 处（L239/L292）+ CLAUDE.md 1 处（L32）+ README_zh.md 2 处（L136/L229）+ skills/task-planner/README.md 1 处（L67）;WF-10 要求 4 索引文档命中总和 ≥6,WF-11 要求「Rules 1-38」残留=0 | selftest-workflow-orchestration.sh:52-66 | P2-S2 更新计数措辞时 4 索引文档全要动（CLAUDE/README_zh/README.md 不在本计划 scope_files——需扩围或以「1-39→1-40 宽容措辞避免」处理:WF 断言只查 ≥6 与残留 0,若 SKILL 两处改 1-40 则总和降为 4 <6 → **必须把 4 索引文档列入 P2 修改集**（scope 扩围登记）或保留「1-39（含 40）」式措辞维持计数）;此为计划期最大不确定点,见 §4 条 2 |
| Rule 39 现行六子条+39.7 位于 CRIT 尾部（### 39 节 L339-390,文件共 391 行） | critical-rules.md:339-390 实测 | Rule 40 纯追加在 L391 后;39.1（L373）与 39.7.2 原文逐字保全 |
| WF 自检断言锚清单（新增 Rule 40 同款守护要覆盖） | selftest-workflow-orchestration.sh:35-66（WF-01..12:条款头/39.1/39.3/39.4/39.5/39.6/摘要行/C27/协同路由行/Rules 1-39 ≥6/1-38 残留 0/config=40） | selftest-tool-selection.sh 照此范式写 TS-01..N;WF-07..09 断言的旧锚子串（「Rule 39（动态工作流编排」「\| C27 \|」「dynamic-workflows（用户显式点名」）在 P2 行内改时必须保全 |
| check-delegation stats 委派率=delegated/(delegated+全部 main_direct),白名单理由关键词正则=`白名单[①②③④⑤⑥]\|git 编排\|worktree\|计划系统文件\|三件套\|机械验证\|用户显式\|兜底接管\|trivial` | check-delegation.sh:542-547 + check-complete.sh:419-435（25.4a WHITELIST-EXEMPT） | 本计划主进程直做 P1/P6/P7-S2 的 Executor 理由必须含上述关键词（已按「①…③…」格式写）,否则终验 violations;预期 rate≈0.64<0.7 依赖豁免放行 |
| general 模板 Phases 段前插入点:Next Step 段后、「## Phases」头（L133）前 | templates/task_plan.md:117-139 实测 | P3-S1 区块插此;模板 420 行;下游 check-template-type 消费 frontmatter/表格/注释三形态与区块无关,兼容风险低（FMEA RPN 96 预演） |
| mini-lite 模板 44 行,≤80 断言 | templates/variant/mini-lite-type.md:1-8 + selftest-plan-tier.sh:82-83 | P3-S2 豁免声明行只加注释行不破 80 上限 |
| rule-enhancement 模板既有骨架与 VC 范式（含锚定级联强制约束②原文） | templates/variant/rule-enhancement-type.md:40-44 | 本计划 VC/约束已按其 5 条 VC 范式扩为 7 条;级联强制约束继承其 grep 先行原则 |
| smart-merge-back --deploy:三位 SLOTS 硬编码=HOME/.zcode:.claude:.config/opencode 下 skills/task-planner;对账基准=主仓 skills/task-planner;DRIFT exit 6 fail-closed | smart-merge-back.sh:377,395（DEPLOY_SRC=$MAIN_REPO/skills/task-planner）,:86-91（exit 语义） | P6-S2 直接 `--deploy`;companion/agents 不在其覆盖面 → P6-S3 需 install-companion.sh 或对位复制+diff 复验 |
| companion 部署路径=companion/agents/*.md → ~/.zcode/agents/ 或 ~/.claude/agents/ | lib/install-companion.sh:5 注释 | opencode 位 agents/ 是否有 plan-writer.md 未核实（ls 见 EO-planner.md 等异构内容）→ KQ4 留 P6-S3 实测 |
| plan-writer.md 契约锚:自我介绍段+掌握的技能段（L38-66）+产出契约表（L103+）;既有 selftest 消费锚:M-16「问题解构四问」、CD-20「纯数字」 | companion/agents/plan-writer.md:38-66 + selftest-methodology.sh:214-218 + selftest-conclusion-discipline.sh:82-83 | P4-S2 加义务行时禁动这两个既有锚子串;工具选择义务行加在「掌握的技能」bullet 列表内 |
| 卫星插入点:template-mapping.md §九矩阵表后（L205-230,文件 230 行）;template-guide.md §五场景示例后/§六 Checklist 前（L143-223 之间） | template-mapping.md:205-230 + template-guide.md:143-279 目录实测 | P4 插入;mapping 无行数断言,guide 路径引用须绝对路径规范（§七） |
| config.json 键结构:properties 内 40 键,delegation_rate_floor=0.7 默认;interaction_mode 键在位 | config.json:36-41,52-59 + selftest-workflow-orchestration.sh:64-67（WF-12 properties=40） | 零新键红线;WF-12 全绿维持 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/critical-rules.md | :339-390 | ### 39 动态工作流编排节:引言段+39.1 显式点名纪律+39.2 加载门槛+39.3 四机制映射表+39.4 并行豁免+39.5 机器校验边界+39.6 机制+39.7 动态激活边界三小条——Rule 40 直接对标范式 |
| skills/task-planner/references/critical-rules.md | :391（EOF） | 文件末行=39.7.3;Rule 40 纯追加插入点在其后 |
| skills/task-planner/SKILL.md | :44-47 | 🤝 专业技能协同路由段:主路由 plan-collab-router + dynamic-workflows 行（Rule 39 触发描述）——P2 在 L47 后加 Rule 40 行 |
| skills/task-planner/SKILL.md | :186-191 | 合规清单 C22-C27 行（C27=Rule 39 路由合规）——P2 在 C27 后加 C28 |
| skills/task-planner/SKILL.md | :239 | 「详见 references/critical-rules.md（Rules 1-39）」索引行——计数措辞更新点① |
| skills/task-planner/SKILL.md | :266-268 | Critical Rules 摘要行 Rule 37/38/39——P2 在 L268 后加 Rule 40 摘要行 |
| skills/task-planner/SKILL.md | :292 | References 表 critical-rules.md 行（Rules 1-39 全列举）——计数措辞更新点② |
| skills/task-planner/templates/task_plan.md | :117-139 | Next Step 段尾→「## Phases」头+Executor 字段说明注释——「🧰」区块插入点（Phases 头前） |
| skills/task-planner/templates/variant/mini-lite-type.md | :1-8 | 头部注释区（template_type/plan_tier/适用场景/38.3 白名单声明）——豁免声明行加在注释区 |
| skills/task-planner/templates/subagent_dispatch.md | :10-18 | §2 输入段（三文件契约+材料包行）——工具面提示行加在此段尾 |
| skills/task-planner/templates/variant/rule-enhancement-type.md | :40-44 | 强制约束段（编号接续/锚定级联/行数纪律/派发契约）——本计划约束继承源 |
| skills/plan-template-kit/references/template-mapping.md | :205-230 | §九 机制适用性矩阵（Rule 37 权威源,16 类型表+注脚）——「工具选择映射」节插其后 |
| skills/plan-template-kit/references/template-guide.md | :143-223 | §五 常见场景定制示例（场景1-4）——区块定制指南插其后（§六 Checklist 前 L223） |
| skills/task-planner/companion/agents/plan-writer.md | :38-66 | 「掌握的技能」bullet 列表（模板选择/任务分解/VC 设计/Scope/隔离决策/knowledge-brief 产出）——工具选择撰写义务行插此列表 |
| skills/task-planner/scripts/selftest-workflow-orchestration.sh | :23-80 | WF-01..16 静态断言全貌（条款锚/SKILL 联动/索引计数/config 键数）——selftest-tool-selection 范式源 |
| skills/task-planner/scripts/selftest-registry.tsv | :1-37 | tsv 四列（script/domain/trigger_scenarios/dep_anchors）——新脚本登记格式源 |
| skills/task-planner/scripts/smart-merge-back.sh | :347-395 | --deploy 段:DEPLOY_SRC=主仓/SLOTS 三位/DRIFT fail-closed——P6-S2 核心机制 |
| skills/task-planner/scripts/check-delegation.sh | :330-400 | _flush_phase 白名单理由判定（①-⑥ 编号标识命中即登记）——Executor 理由措辞约束源 |
| skills/task-planner/config.json | :36-41 | delegation_rate_floor=0.7——委派率预期 0.64 依赖 25.4a 豁免 |
| plans/task-v096-template-auto-record/task_plan.md | :40-148 | 同族任务全流程先例（8 Phase/约束 10 条/FMEA/教训）——执行期遇范式问题先查此 |

## §4 易错点与禁止假设清单

1. 禁止动 Rule 1-39 任何语义与编号（Rule 36.5 纯增量;39.1 L373 / 39.7.2 原文逐字保全,改前快照 diff 对账——P2-S1 验收硬性含 diff 证明）。
2. 禁止假设「Rules 1-39→1-40」只改 SKILL.md 两处即可:WF-10 要求 4 索引文档（SKILL/CLAUDE/README_zh/skills-task-planner-README）命中总和 ≥6,SKILL 两处改 1-40 后总和降至 4 必 FAIL——P1-S2 必须实测并三选一：a) 4 索引文档全部列入 P2 修改集（scope 扩围,登记 Decisions Made）b) 采用「Rules 1-39（含 Rule 40 …）」保持子串计数 c) 上调 WF-10 口径（改动面最大,不推荐）。计划期默认选 b（零 scope 扩围,断言零改）,P1 实测后若不可行再切 a。
3. 禁止只盯 ≤558 一处行数断言:共 5 处（knowledge-brief/skill-collab/skill-split/execution-stability/batch-pilot）+ skill-split 的 ≤430 目标线;当前 SKILL.md=430 行恰在目标线上,净增预算极紧——行位替换优先,能并入既有行就不新开行;上调上限时 label 必注明 task-v097（先例格式见 selftest-knowledge-brief.sh:38 历史链）。
4. 派发 prompt subagent_type 只写纯 token（executor/code-reviewer/code-assistant）,禁括号模型后缀——括号后缀会被 check-delegation Handoff 交叉校验按 token 剥离逻辑误伤+v095 实证教训;模型档位写在 prompt 正文。
5. selftest 全量总数=主进程逐脚本 Total 行机械求和,禁采信子代理自报（v096 硬约束 9 原文）;P5-S3 executor 自报仅参考,P6/终验以主进程复跑为准。
6. 单用例调试 ≤2 轮,超则记 blockers 交主进程（22.3）;selftest 新脚本必须 mktemp+trap 沙箱,零仓库写入（对齐 selftest-workflow 范式）。
7. mini-lite 80 行上限:豁免声明用注释行（不进正文区块数）;38.3 白名单断言在 selftest-plan-tier T11,加行后复跑该脚本。
8. 部署位禁手改:三位 skills/task-planner 走 smart-merge-back --deploy;companion/agents 走 install-companion.sh 或对位复制——绕开脚本手 Edit 部署位=宪法 §六 保护区违规。
9. 「🧰」区块必须含「不替代 Executor 委派门控机器事实源」定位声明——这是用户 40.2 原话约束,CR 专项核对点;check-delegation 状态机只认 `### Phase N:` 头+`**Status:**`+`**Executor:**` 三要素（check-delegation.sh:494-526 实测）,区块内表格不得出现这三形态的伪行。
10. /goal 披露纪律（Rule 35.2）:40.3 措辞禁止声称技能可代调 /goal 或读取其运行态;/goal 是用户侧 harness 会话命令,技能层只有映射指引。
11. worktree 内 CWD 不迁移,文件操作全部绝对路径;计划文档（本目录）留主仓 plans/ 不进 worktree;逐 Phase commit 禁 `git add -A`（Rule 27,scope 文件白名单式 add）。
12. registry 双落点:tsv +1 行后必须复跑 selftest-registry.sh（T02 无缺失/T03 无孤儿）,rows=actual 双向核对。
- FMEA RPN>100 兜底指针：{→ task_plan.md FMEA 表「Phase 2 SKILL 行数断言级联遗漏（RPN 120）」行——P1 级联清单先行+P2-S2 输入列强制携带,FAIL 时 22.3① 改派回炉单处上限}

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1-S1 | §1 + §2（F1 行） | /mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md |
| P1-S2 | §2（F2/F3/F4/F5 行）+ §3（selftest-workflow 行） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-workflow-orchestration.sh |
| P2-S1 | §1 + §3（CRIT 两行）+ §4 条 1/10 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md（L339-391）;本计划 Goal 段（六子条定义） |
| P2-S2 | §2（F4/F5 行）+ §3（SKILL 五行）+ §4 条 2/3/4 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（L44-47/186-191/239/266-268/292）;P1-S2 级联清单（progress.md Phase 1 段） |
| P3-S1 | §1（区块六要素）+ §3（task_plan.md 行）+ §4 条 9 | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md（L117-139）;本计划「🧰」区块实例 |
| P3-S2 | §2（mini-lite 行）+ §3（mini-lite/dispatch 行）+ §4 条 7 | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/mini-lite-type.md（全文）;templates/subagent_dispatch.md（§2） |
| P4-S1 | §3（mapping 行）+ §1（映射表内容） | /mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-mapping.md（L205-230） |
| P4-S2 | §2（plan-writer 契约行）+ §3（guide/plan-writer 行）+ §4 条 8 | /mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-guide.md（L143-223）;companion/agents/plan-writer.md（L38-66） |
| P5-S1 | §2（WF 范式行）+ §3（selftest-workflow/registry 行）+ §4 条 6/12 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-workflow-orchestration.sh（全文范式）;selftest-registry.tsv |
| P5-S2 | §2（F2 行）+ §4 条 12 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.sh（T02/T03 口径） |
| P6-S2 | §2（smart-merge 行）+ §4 条 11 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/smart-merge-back.sh（L347-395） |
| P6-S3 | §2（companion 行）+ §3（install-companion） | /mnt/data/dev/task-planner-skill/skills/task-planner/lib/install-companion.sh |
| P7-S1 | §4 条 1/9/10（CR 专项三核对点） | `git diff master..wt/task-v097-tool-selection`（worktree 内） |
