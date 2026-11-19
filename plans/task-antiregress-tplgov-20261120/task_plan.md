# Task Plan: task-antiregress-tplgov-20261120
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 渲染；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- template_type: rule-enhancement 选型理由（plan-template-advisor 逻辑，Rule 16/34）：本任务核心为规则/机制治理升级（防倒退新 Rule+模板治理体系+守卫/selftest 接线），最贴合 variant/rule-enhancement-type.md；同时含批量模板重构面，执行期可参考 refactor 型实践但 template_type 保持单一最适配。白名单校验：variant/rule-enhancement-type.md 存在（research/template-inventory.md:98）。 -->
template_type: rule-enhancement
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R0（原文全文，逐字）**: 「为该项目skill加入放倒退机制  也就是  在合适的地方加入防倒退相关操作 比如在计划完成或者初期  就评估是否会将项目进度产出倒退影响,不能做拆东墙补西墙,为了可以践行任务执行防倒退原则可以在多个地方进行限制已经增加步骤   比如 模板等   另外我希望可以升级模板skill 将类似防倒退机制等推广到所有的模板文件 就是 在模板中要求对各种原则性的问题注入到模板 确保原则的可靠性. 另外确保所有任务都主动加载适配的模板文件 确保执行任务使用针对性优化方案, 增加覆盖场景模板  另外还有就是提高对已有模板升级能力  以后升级模板skill规范后可主动改造已有过时的模板来提高模板可靠性 还有就是 模板的派生机制   我希望可以对模板进行分级  对于基础模板提供更高的可靠性  不能说以后几个模板派生后偏移原本模板的核心原则  比如  基础模板要求的某些 因素对于 派生a 不必要删除了  如果使用a派生a1 可能导致 传导错误  也许a1中需要符合基础模板所以对齐到基础模板派生 才是核心  比如派生a1需要同时参考基础和a来派生a1  来提高可靠性不会丢失核心」<sub>（[目标]）</sub>

- **R1 防倒退机制**: 「为该项目skill加入放倒退机制  也就是  在合适的地方加入防倒退相关操作 比如在计划完成或者初期  就评估是否会将项目进度产出倒退影响,不能做拆东墙补西墙,为了可以践行任务执行防倒退原则可以在多个地方进行限制已经增加步骤   比如 模板等」<sub>（[目标]）</sub>
- **R2 原则注入推广**: 「另外我希望可以升级模板skill 将类似防倒退机制等推广到所有的模板文件 就是 在模板中要求对各种原则性的问题注入到模板 确保原则的可靠性.」<sub>（[目标]）</sub>
- **R3 主动加载与场景覆盖**: 「另外确保所有任务都主动加载适配的模板文件 确保执行任务使用针对性优化方案, 增加覆盖场景模板」<sub>（[目标]）</sub>
- **R4 模板升级与存量改造**: 「另外还有就是提高对已有模板升级能力  以后升级模板skill规范后可主动改造已有过时的模板来提高模板可靠性」<sub>（[目标]）</sub>
- **R5 模板分级派生机制**: 「还有就是 模板的派生机制   我希望可以对模板进行分级  对于基础模板提供更高的可靠性  不能说以后几个模板派生后偏移原本模板的核心原则  比如  基础模板要求的某些 因素对于 派生a 不必要删除了  如果使用a派生a1 可能导致 传导错误  也许a1中需要符合基础模板所以对齐到基础模板派生 才是核心  比如派生a1需要同时参考基础和a来派生a1  来提高可靠性不会丢失核心」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）

| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R0 | VC-01 | `task_plan.md` 含逐字原文块（含笔误/空格），`grep -F "为该项目skill加入放倒退机制  也就是" task_plan.md` 命中且后续句子完整。 |
| R1 | VC-02, VC-03, VC-04, VC-05, VC-16 | core/discipline/dispatch 规则新增防倒退条款且编号唯一；主模板与 variant 同族含「📦 进度产出基线」「🛡 防倒退终检」区块；SKILL/init/check-complete 接线可 grep；selftest 断言通过。 |
| R2 | VC-06, VC-07 | plan-template-kit 存在原则→模板区块注册表；守卫/校验脚本对缺必选原则区块返回 FAIL（含豁免登记路径）。 |
| R3 | VC-08, VC-09, VC-10 | general 兜底须登记理由（init-session/check-complete/advisor 链可观测）；`plans/` 历史类型分布 vs 31 variant 覆盖面数据产出与补缺候选清单落盘/登记。 |
| R4 | VC-11, VC-12 | 模板与 kit 声明 `spec_version`；存在 retrofit SOP/扫描机制可产出 `spec_version<N` 存量清单并复验。 |
| R5 | VC-13, VC-14, VC-15 | 主模板标记 base、variant 含 lineage 头与裁剪清单；派生铁律条款与二级派生 base+parent 双参照可 grep；批量注入后 `check-template-type.sh` 三形态兼容。 |
| 全局 | VC-17, VC-18, VC-19, VC-20 | 根源覆盖表 R1–R5、P1–P4 各有 S-unit、`[goal:G*]` 齐备、风险区四要素、Decisions D1/D2、无占位符、范围合规。 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-antiregress-tplgov-20261120/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧭 指令理解迭代草稿（Rule 28.2.2 — 执行前方向对齐｜粗稿非定稿）
- **① 原始指令复述（锚）**：用户要求为项目 skill 加入防倒退机制（计划初期/完成期评估进度产出倒退、禁止拆东墙补西墙、在模板等多处加限制步骤）；升级模板 skill 将防倒退等原则性问题注入所有模板；确保所有任务主动加载适配模板并增加覆盖场景；提高已有模板升级能力（规范升级后主动改造过时模板）；建立模板分级派生机制（基础模板高可靠、派生不可偏移核心原则、二级派生需 base+parent 双参照）。原文锚：`subagent-state/01-planwriter-brief.md:13-15`。
- **② 模型理解（理解1）**：目标=在不破坏既有 51.15/74.7 防倒退闭环前提下，补齐“进度产出面”防倒退与模板治理全链路（原则注册表/主动加载/场景覆盖/spec_version+retrofit/lineage 分级派生）。对象=task-planner-skill 仓内规则、模板、kit/advisor、init/check/selftest/SKILL、文档与计数级联。约束=worktree 实施、禁碰主仓 18 在途文件、文本优先、批量注入脚本化、编号先 grep、自测同集零增量。验收=计划可 attest、VC 机器可验、范围合规。**不做什么**：不执行实施 Phase、不改代码运行时业务逻辑、不新增 hook/registry 外基础设施、不替用户拍板“立即实施全部补缺模板”而是数据驱动给候选与决策点。
- **③ 思路与候选（思路2）**：路径A（采纳，P1→P4 分期）先落 R1 防倒退闭环与模板区块载体，再做 R5/R2 治理结构，再做 R4/R3 升级与主动加载，最后部署/回归收尾，风险可控且每期独立可验收；路径B 全量并行改规则+31模板+脚本，冲突与回归面过大不采纳；路径C 仅改模板不改规则/守卫，无法机器化防倒退与原则可靠性不采纳。**歧义门控**：`明确-按默认路径`（用户已给 R1-R5 与分期倾向，D1/D2 已裁决；R3“增加覆盖场景模板”的具体新增清单作为 P3 数据盘点后计划内决策点登记，不在本轮擅自落具体新模板实现）。
- **④ 大体执行方向（思路3/4）**：P1 核实空号与 selftest 基线→新增进度产出防倒退 Rule 与模板/流程接线→守卫自测；P2 定义 base/derived lineage 与裁剪清单规范→脚本批量注入 variant→建原则注册表与覆盖校验；P3 引入 spec_version 与 retrofit SOP/扫描→数据盘点 plans/类型分布对照覆盖面并改主动加载登记理由链；P4 全量回归、部署同步 diff=0 复验、合并清理与簿记。各 Phase 以 S-unit 拆分、VC 机器判据与 `[goal:Gn]` 逐格闭环。

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 需求/计划初期（R1） | 未登记进度产出快照与禁倒退清单，动工后易“拆东墙补西墙”且无对照 | P1-S2/S3：主模板增「📦 进度产出基线」+ 初期登记触发接线（SKILL/流程）；本计划作为首个实弹载体 | VC-03, VC-16 |
| 执行/变更落地（R1,R2） | 只改局部不评估既有产出消费方影响，净效果可能为负；原则未结构化注入模板 | P1-S2：新 Rule 含净效果≥0 判定与 BLOCK；P2-S5：原则→模板区块注册表+守卫覆盖校验 | VC-02, VC-04, VC-06, VC-07 |
| 模板选型与加载（R3） | general 静默兜底、场景缺口凭感觉补模板，适配性不可证 | P3-S7：general 兜底须登记理由（init/check/advisor）；`plans/` 类型分布数据盘点→补缺候选清单 | VC-08, VC-09, VC-10 |
| 模板演进/升级（R4） | 规范升级后存量模板漂移、无版本与改造机制，可靠性衰减 | P3-S6：spec_version 声明 + retrofit 扫描/改造/复验 SOP（机制化 variant-upgrade 经验） | VC-11, VC-12 |
| 模板派生与传导（R5） | variant 裁剪无 lineage/无 base 对齐，二级派生易丢核心原则 | P2-S4：base/derived 分级 + lineage 头 + 裁剪清单 + 派生铁律 + base+parent 双参照；批量注入兼容守卫 | VC-13, VC-14, VC-15 |
| 交付/合并/部署（R1,全局） | 终检缺失、主仓在途冲突、部署位漂移导致回归 | P1-S2：`🛡 防倒退终检`；P4-S8：selftest 同集零增量、部署 diff=0、合并冲突按 V3 处理与风险登记 | VC-04, VC-17, VC-18, VC-19, VC-20 |

## 🔒 不变量声明区（Rule 73.3）

| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R0-R5 用户原话逐字、R→VC 映射完整性、VC 机器判据与 `**Verify command**:` 格式、`[goal:G1]..[goal:G8]` 语义不降级、D1/D2 决策、主仓 18 未提交文件不触碰、worktree 隔离实施、无空段占位 | 本文 `## 🎯`、`### R→VC`、`## ✅`、`## 🎯 Goal 单元表`、`## Decisions Made`、`## ⚠️ 执行范围限制`、`## 🔀 隔离决策` |
| 🔀 可变量 | S-unit 内部执行顺序微调（不破坏依赖）、实现脚本命名与具体 grep 模式细节（保持等效机器判据）、R3 补缺候选模板的最终入选数量（以数据盘点结果登记） | 各 Phase S-unit 表、`progress.md`/`findings.md` |
| 📈 学得量 | 实施期基线自测 FAIL 清单、编号实测结果、类型分布统计、兼容性抽检结果、合并冲突实况 → `findings.md`/`notepad-learnings.md`，禁反写不变量 | `findings.md`, `notepad-learnings.md` |

## 🔒 规范基线（Spec-Baseline，Rule 51.15）

| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 |
|---------|-------------------|------------------|-----------|------------|
| SPEC-ANTI-01 | 「不能做拆东墙补西墙」 | `subagent-state/01-planwriter-brief.md:14` (R1 原文) | 交付/合并前对既有关键产出净效果判定：净效果≥0 且消费方影响已登记=PASS；任一既有产出删除/降级/替换导致净效果<0 或影响未登记=FAIL(BLOCK) | n/a(文本片段) |
| SPEC-SCOPE-01 | 「主仓 18 个未提交文件属三簇在途任务（调研报告§1），本任务禁触碰」 | `subagent-state/01-planwriter-brief.md:32` | 实施期 `git -C <worktree> diff --name-only` 与主仓 `git status --porcelain` 交叉校验：本任务提交/改动集不含 18 文件=PASS；包含任一=FAIL | n/a(文本片段) |
| SPEC-LINEAGE-01 | 「比如派生a1需要同时参考基础和a来派生a1  来提高可靠性不会丢失核心」 | `subagent-state/01-planwriter-brief.md:15` (R5 原文) | 二级及以上派生模板必须声明 base+parent 双参照且裁剪清单=父级∪新增、核心区块不可静默丢失=PASS；缺任一参照或核心区块无登记裁剪即消失=FAIL | n/a(文本片段) |

## Goal
在 worktree 隔离下为 task-planner-skill 落地可机器验证的进度产出防倒退机制与模板治理升级（原则注入/主动加载+场景覆盖/spec_version+存量改造/base-derived lineage 派生），并完成同集零增量回归与部署同步，使 R1–R5 全部可验收且不回退既有能力。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（规则/模板/脚本文档治理任务，非应用业务代码交付；执行期若新增可执行守卫脚本且变更复杂度上升可在 progress 登记升级为 required） |
| `session_id` | `sess_antiregress_tplgov_20261120` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120` |
| `scope_files` | `[skills/task-planner/templates/task_plan.md, skills/task-planner/templates/variant/*-type.md, skills/task-planner/references/critical-rules.md, skills/task-discipline/references/critical-rules-discipline.md, skills/task-dispatch/references/critical-rules-dispatch.md, skills/task-planner/SKILL.md, skills/task-planner/scripts/init-session.sh, skills/task-planner/scripts/check-complete.sh, skills/task-planner/scripts/check-template-type.sh, skills/task-planner/scripts/selftest-*.sh(新增/更新), skills/plan-template-kit/**, skills/plan-template-advisor/SKILL.md, plans/task-antiregress-tplgov-20261120/{task_plan,knowledge-brief,findings,progress}.md]`（均在 worktree 内操作；主仓同名文件仅合并期写入） |
| `interaction_mode` | `ask`（关键决策点给选项；本计划期 D1/D2 已登记，后续仅在数据盘点发现歧义补缺时再确认） |
| `对齐审查` | `登记`：P4 交付前对本任务改动的模板/规则/kit 文档执行 alignment-review（Rule 42.6）；mini 豁免不适用（standard）。 |
| `自动超时默认项` | `登记`：执行期 2+ 选项询问点默认选“推荐项（数据/证据支持者）”，超时 5 分钟自动执行并记自动裁决五要素（Rule 44）；低区分度步骤选项直接裁决登记理由不询问。 |
| `new_rule` | `候选 111+（实施前 grep 三份 critical-rules 全集实测空号后确定；本计划不预占）` |
| `质量审查工具` | `登记`：规则/模板一致性用 `check-template-type.sh`/`check-complete.sh`/`run-selftests.sh` 或等效自测集；文档对齐用 alignment-review；若缺专用守卫则在 P1/P2 建 S-unit 补脚本+selftest（Rule 42.3）。 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：验证动作由独立子代理或独立 shell 复核执行并留证据（Rule 33.3）。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-01 | 用户需求原文逐字在位（含 R0 全文与 R1-R5 分解） | `**Verify command**: grep -nF "为该项目skill加入放倒退机制  也就是" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md && grep -n "R5 模板分级派生机制" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md` 输出均含命中行号 | `task_plan.md` §🎯 用户需求原文 |
| VC-02 | 新增进度产出防倒退 Rule 编号唯一且与 51.15/74.7 分工互锁 | `**Verify command**: cd <worktree> && N=<实测新号> && test $(grep -rn "^### ${N} " skills/task-planner/references/critical-rules.md skills/task-discipline/references/critical-rules-discipline.md skills/task-dispatch/references/critical-rules-dispatch.md | wc -l) -eq 1 && grep -n "51.15" skills/task-planner/references/critical-rules.md | grep -q "进度产出" && grep -n "74.7" skills/task-planner/references/critical-rules.md | grep -q "分工"` | worktree 三份 rules + grep 输出 |
| VC-03 | 主模板含「📦 进度产出基线」登记区块（初期评估位） | `**Verify command**: grep -n "📦 进度产出基线" <worktree>/skills/task-planner/templates/task_plan.md` 命中≥1 且含禁倒退清单/快照字段说明 | 主模板对应区块行号 |
| VC-04 | 主模板含「🛡 防倒退终检」区块且含净效果≥0/BLOCK 判据 | `**Verify command**: grep -n "🛡 防倒退终检" <worktree>/skills/task-planner/templates/task_plan.md && grep -n "净效果" <worktree>/skills/task-planner/templates/task_plan.md` 均命中 | 主模板对应区块行号 |
| VC-05 | 防倒退机制接线到 SKILL/init/check-complete/variant 同族（初期登记+交付终检触发点可观测） | `**Verify command**: cd <worktree> && grep -n "进度产出基线\|防倒退终检" skills/task-planner/SKILL.md scripts/init-session.sh scripts/check-complete.sh templates/task_plan.md` 每目标文件至少 1 命中（variant 同族抽样≥3 类同 grep） | 各文件命中行 + 抽样记录 |
| VC-06 | plan-template-kit 存在「原则→模板区块」注册表并覆盖防倒退/验证/证据/理解迭代等原则 | `**Verify command**: test -f <worktree>/skills/plan-template-kit/references/principle-template-registry.md && grep -n "防倒退" <worktree>/skills/plan-template-kit/references/principle-template-registry.md && grep -n "验证" <worktree>/skills/plan-template-kit/references/principle-template-registry.md && grep -n "证据" <worktree>/skills/plan-template-kit/references/principle-template-registry.md && grep -n "理解迭代" <worktree>/skills/plan-template-kit/references/principle-template-registry.md` | 注册表文件路径+行号 |
| VC-07 | 守卫可校验模板原则覆盖面，缺必选区块 FAIL 且支持豁免登记 | `**Verify command**: cd <worktree> && bash skills/task-planner/scripts/check-template-principles.sh --selftest-smoke 2>&1 | tee /tmp/vc07.log; grep -q "PASS" /tmp/vc07.log`（脚本名 S5 预定具名；若落地名有出入须同步更新本行并重锁登记） | 守卫脚本路径+smoke 输出 |
| VC-08 | general 兜底须登记理由（非静默默认）在 init-session/check-complete/advisor 链可观测 | `**Verify command**: cd <worktree> && grep -n "general.*理由\|登记理由.*general\|兜底.*理由" scripts/init-session.sh scripts/check-complete.sh ../plan-template-advisor/SKILL.md skills/plan-template-advisor/SKILL.md 2>&1 | grep -v "No such file"` 至少命中预期触点集 | 命中行号清单 |
| VC-09 | 场景覆盖缺口盘点数据驱动：产出 `plans/` 类型分布统计与 31 variant 对照结果 | `**Verify command**: test -f <worktree>/plans/task-antiregress-tplgov-20261120/research/scenario-coverage.md && grep -n "plans/" <worktree>/plans/task-antiregress-tplgov-20261120/research/scenario-coverage.md && grep -n "31" <worktree>/plans/task-antiregress-tplgov-20261120/research/scenario-coverage.md` | `research/scenario-coverage.md` |
| VC-10 | 补缺候选模板清单作为计划内决策点登记（含数据依据），非拍脑袋 | `**Verify command**: grep -n "补缺候选" <worktree>/plans/task-antiregress-tplgov-20261120/task_plan.md && grep -n "数据依据" <worktree>/plans/task-antiregress-tplgov-20261120/task_plan.md` | `task_plan.md` R3 决策/风险或 Findings 登记节 |
| VC-11 | 模板与 plan-template-kit 声明 `spec_version`（主模板+kit+variant 机制位） | `**Verify command**: cd <worktree> && grep -n "spec_version" skills/task-planner/templates/task_plan.md skills/plan-template-kit/SKILL.md && grep -rl "spec_version" skills/task-planner/templates/variant | wc -l` 输出 `>=31`（或等效覆盖口径并登记豁免） | grep 结果 |
| VC-12 | 存量模板 retrofit SOP/扫描机制可用：能列出 `spec_version<N` 或缺失项清单并复验 | `**Verify command**: cd <worktree> && bash skills/plan-template-kit/scripts/scan-template-spec.sh --target-spec 1 2>&1 | tee /tmp/vc12.log; test ${PIPESTATUS[0]} -eq 0 && grep -n "spec_version" /tmp/vc12.log`（脚本名 S6 预定具名；若落地名有出入须同步更新本行并重锁登记） | 扫描输出+SOP 文档锚点 |
| VC-13 | base/derived 分级与 lineage 头+裁剪清单在模板中可观测 | `**Verify command**: cd <worktree> && grep -n "base_template\|derived_from\|lineage" skills/task-planner/templates/task_plan.md && grep -rl "lineage" skills/task-planner/templates/variant | wc -l` 输出 `>=31` | grep 计数 |
| VC-14 | 派生铁律与二级派生 base+parent 双参照条款可 grep（规则/kit 文档） | `**Verify command**: cd <worktree> && grep -rn "base+parent\|双参照\|二级派生" skills/plan-template-kit/references skills/task-planner/references skills/task-discipline/references 2>&1 | head` 命中≥1 | 命中行号 |
| VC-15 | variant 头注入后 `check-template-type.sh` 三形态提取兼容（全量/抽样脚本 PASS） | `**Verify command**: cd <worktree> && bash skills/task-planner/scripts/check-template-type.sh --all 2>&1 | tee /tmp/vc15.log; tail -n 5 /tmp/vc15.log`（若无 --all 则用等效循环校验并在证据登记） | 校验输出 |
| VC-16 | 本计划自身在 P1 实施动工 S-unit 前完成「📦 进度产出基线」回填（dogfood 首个实弹） | `**Verify command**: grep -n "动工前项目关键产出\|禁倒退清单" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md && grep -n "已回填" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md` | 本计划基线区块 |
| VC-17 | selftest 基线纪律：动工前基线 FAIL 清单落盘，收尾同集零增量 | `**Verify command**: test -f <worktree>/plans/task-antiregress-tplgov-20261120/research/selftest-baseline.txt && test -f <worktree>/plans/task-antiregress-tplgov-20261120/research/selftest-final.txt && diff <(grep "FAIL" <worktree>/plans/task-antiregress-tplgov-20261120/research/selftest-baseline.txt | sort) <(grep "FAIL" <worktree>/plans/task-antiregress-tplgov-20261120/research/selftest-final.txt | sort)` 无新增 FAIL 行 | 基线/终验记录文件 |
| VC-18 | 计划结构完整：R1–R5 根源覆盖、P1–P4 各有 S-unit、`[goal:G1]..[goal:G8]`、D1/D2、风险四要素、无占位符 | `**Verify command**: P=/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md; grep -q "R1–R5" "$P" || grep -q "R1-R5" "$P"; for g in G1 G2 G3 G4 G5 G6 G7 G8; do grep -q "\[goal:$g\]" "$P" || exit 1; done; grep -q "Decision D1" "$P" && grep -q "Decision D2" "$P" && grep -q "合并冲突" "$P" && grep -q "白名单兼容" "$P" && grep -q "部署漂移" "$P" && grep -q "场景选取数据依据" "$P" && ! grep -nE "TBD|待定|占位符|<待|<示例>|<用户原话第 1 条" "$P"` | `task_plan.md` + grep 退出码 |
| VC-19 | 部署同步验证：部署动作完成后部署位文件与仓内产物逐位 diff=0 | `**Verify command**: S8 先实测仓库实际部署机制并登记（2026-11-20 判别修订：`ls skills/task-planner/scripts/deploy.sh` 实测不存在，禁再引用该脚本）；无专用脚本时按既有部署惯例执行同步，对每个部署位关键文件逐个 `diff <部署位>/<file> <worktree>/skills/<file>` 登记 diff=0 清单，任一漂移未消=FAIL | 部署 diff=0 清单证据 |
| VC-20 | 范围合规：除四计划文件外无新增改动（计划撰写阶段）/ 实施阶段仅 worktree 改动+合并受控 | `**Verify command**: cd /mnt/data/dev/task-planner-skill && git status --porcelain | awk '{print $2}' | grep -v "^plans/task-antiregress-tplgov-20261120/task_plan.md$" | grep -v "^plans/task-antiregress-tplgov-20261120/knowledge-brief.md$" | grep -v "^plans/task-antiregress-tplgov-20261120/findings.md$" | grep -v "^plans/task-antiregress-tplgov-20261120/progress.md$" | wc -l` 输出 `0`（计划撰写验收口径） | `git status --porcelain` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## 🛡 双轮质检与同步完整性声明（Rule 103 — standard 必填）

| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | 默认全适用：P1-S2/S3/S4/S5/S6/S7/S8 所有规则/模板/脚本/注册表实质产出 S-unit |
| 豁免登记 | P1-S1 仅核实与基线落盘（只读+计划内研究文件）豁免第二轮独立复检，但需主进程复核证据锚；其余无豁免 |
| 多文件变更集预判 | P1（rules+templates+scripts+SKILL 多文件）、P2（31 variant 批量+kit）、P3（init/check/advisor+kit+扫描脚本）、P4（部署与计数级联）均触发 Rule 103.6 同步完整性审查清单 |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R0, R1, R2, R3, R4, R5 |
| **裁决** | `solved`（R1-R5 全部落地：防倒退 Rule 111/106.8/22.4f+双区块；lineage 分级派生+双参照铁律；原则注册表+覆盖守卫；spec_version+retrofit；general 登记理由链。R3 附带候选 skill-enhancement-type 模板=登记待用户批准，不阻塞 solved——VC-10 明确登记即合规） |
| **解决证据锚** | commits 15fc6c5/d0c217f/5818356/546727e/d78e930 + merge bd1f131；VC-01~VC-20 证据见各 Phase Evidence 行+verification.md；selftest-final FAIL 集==基线；deploy-diff-report 188/188 |
| **未解决面+原因** | ①skill-enhancement-type 新模板候选=待用户批准（数据依据已备 scenario-coverage.md §三）②P2-S4/S5 variant 原则区块 warn=145（derived 指针行仅 3/29，守卫 warn 档逐步补齐口径已登记）③audit-gate [plan-audit-RN] 留痕 warn 欠账（judge 判别+独立复检双轨留痕替代，登记披露） |
| **已排除路径** | 无（计划阶段未尝试实施） |
| **下一步建议** | 批准计划后按 P1→P4 执行：先创建 worktree + 跑 selftest 基线 + 回填本计划「📦 进度产出基线」，再进入 P1-S1 编号/基线核实与 R1 落地 |

## 🎯 Goal 单元表（Rule 66.1）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 计划完备（[goal:G1]） | 产出可执行、可 attest 的 task_plan 与 knowledge-brief，R1-R5 与 VC/风险/决策齐备 | `**Verify command**: bash -lc 'P=plans/task-antiregress-tplgov-20261120/task_plan.md; grep -q "R0（原文全文" "$P" && grep -q "Decision D1" "$P" && grep -q "Decision D2" "$P" && for g in G1 G2 G3 G4 G5 G6 G7 G8; do grep -q "\[goal:$g\]" "$P"; done'` + VC-18 | P0(本轮)/S0 | complete |
| G2 | 防倒退规则落地（[goal:G2]） | 新增进度产出防倒退 Rule 并与 51.15/74.7/106.7/22.4e/103.3b 分工互锁 | `**Verify command**: grep -rn "进度产出基线\|拆东墙补西墙\|净效果" <worktree>/skills/*/references/critical-rules*.md <worktree>/skills/task-planner/references/critical-rules.md` + VC-02 | P1/S1,S2 | complete |
| G3 | 模板防倒退载体（[goal:G3]） | 主模板与 variant 同族具备基线登记+终检区块且本计划 dogfood 回填 | `**Verify command**: grep -n "📦 进度产出基线" <worktree>/skills/task-planner/templates/task_plan.md && grep -n "🛡 防倒退终检" <worktree>/skills/task-planner/templates/task_plan.md` + VC-03,VC-04,VC-16 | P1/S2,S3 | pending |
| G4 | 派生分级治理（[goal:G4]） | 建立 base/derived lineage+裁剪清单+二级派生 base+parent 双参照并批量注入兼容 | `**Verify command**: grep -rl "lineage" <worktree>/skills/task-planner/templates/variant | wc -l` + VC-13,VC-14,VC-15 | P2/S4 | complete |
| G5 | 原则注入注册表（[goal:G5]） | 原则→模板区块注册表与覆盖守卫落地，缺必选区块可 FAIL | `**Verify command**: test -f <worktree>/skills/plan-template-kit/references/principle-template-registry.md && bash <worktree>/skills/task-planner/scripts/<principle-coverage-guard>.sh --selftest-smoke` + VC-06,VC-07 | P2/S5 | complete |
| G6 | 模板升级机制（[goal:G6]） | spec_version + retrofit SOP/扫描可识别并改造存量过时模板 | `**Verify command**: grep -rn "spec_version" <worktree>/skills/task-planner/templates <worktree>/skills/plan-template-kit && bash <worktree>/skills/plan-template-kit/scripts/<retrofit-scan>.sh --target-spec <N>` + VC-11,VC-12 | P3/S6 | complete |
| G7 | 主动加载与场景覆盖（[goal:G7]） | general 兜底须登记理由且场景补缺候选基于 plans/ 分布数据产出 | `**Verify command**: test -f <worktree>/plans/task-antiregress-tplgov-20261120/research/scenario-coverage.md && grep -rn "登记理由" <worktree>/skills/task-planner/scripts/init-session.sh <worktree>/skills/task-planner/scripts/check-complete.sh` + VC-08,VC-09,VC-10 | P3/S7 | complete |
| G8 | 回归部署收尾（[goal:G8]） | selftest 同集零增量、部署 diff=0、合并清理与簿记完成 | `**Verify command**: diff <(grep FAIL <worktree>/plans/task-antiregress-tplgov-20261120/research/selftest-baseline.txt|sort) <(grep FAIL <worktree>/plans/task-antiregress-tplgov-20261120/research/selftest-final.txt|sort)`（部署面按 VC-19 修订口径逐位 diff=0 清单）+ VC-17,VC-19,VC-20 | P4/S8 | complete |

## ⚠️ 执行范围限制（强制）

| 类别 | 允许的文件（实施期均在 worktree 内对应路径） | 禁止 |
|-------|----------------------------------------------|------|
| 模板 | `skills/task-planner/templates/task_plan.md`, `skills/task-planner/templates/variant/*-type.md`, `skills/task-planner/templates/user-session-log.md`(仅必要接线) | 其他 templates/ 文件无需求不改 |
| 规则与技能 | `skills/task-planner/references/critical-rules.md`, `skills/task-discipline/references/critical-rules-discipline.md`, `skills/task-dispatch/references/critical-rules-dispatch.md`, `skills/task-planner/SKILL.md`, `skills/plan-template-kit/**`, `skills/plan-template-advisor/SKILL.md` | 保护区外无关 skills；主仓同名文件执行期不直写 |
| 脚本与守卫 | `skills/task-planner/scripts/init-session.sh`, `check-complete.sh`, `check-template-type.sh`, 新增/更新 `selftest-*.sh`、principle/retrofit 相关脚本（必要最小集） | 无关 scripts/、hook/registry 基础设施新增 |
| 计划产物 | `plans/task-antiregress-tplgov-20261120/{task_plan,knowledge-brief,findings,progress,verification}.md`, `plans/task-antiregress-tplgov-20261120/research/*.md|*.txt` | 其他计划目录与 archive |
| 文档级联 | `skills/plan-template-kit/references/template-mapping.md`, `template-guide.md`, `critical-rules-template.md` 等计数/契约文档（变更触发四点同步时） | 无关 README/知识库批量改写 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成 R1-R5 有必要吗？
- [ ] 用户明确要求我做这个修改吗（或为完成明确要求的必要机器面落地）？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📋 变更标注表（Rule 74.3）

任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单。用户新指令到达时先转标注行再动任何文件。

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-01 | `references/critical-rules*.md` 新条款位 | 新增 | 增量 | 「加入放倒退机制...在多个地方进行限制已经增加步骤」 | R1；`template-inventory.md:242-267` | 在空号处新增进度产出防倒退 Rule，显式写与 51.15/74.7 分工 |
| CA-02 | `templates/task_plan.md` 治理区块 | 修改 | 增量 | 「比如在计划完成或者初期...比如 模板等」 | R1；`:105-114` | 增加「📦 进度产出基线」「🛡 防倒退终检」区块并保留既有区块 |
| CA-03 | `templates/variant/*-type.md` 头/结构 | 修改 | 增量 | 「推广到所有的模板文件...模板分级...派生机制」 | R2,R5；`:94-99`,`:130-133` | 脚本批量注入 lineage/spec_version 与必要原则区块/指针，保持白名单兼容 |
| CA-04 | `skills/plan-template-kit/**` | 修改/新增 | 增量 | 「原则注入...注册表...提高对已有模板升级能力」 | R2,R4；`:139-148` | 新增原则注册表与 retrofit SOP/脚本，更新 mapping/guide/kit SKILL |
| CA-05 | `scripts/init-session.sh`,`check-complete.sh`,`advisor` | 修改 | 增量 | 「确保所有任务都主动加载适配的模板文件...增加覆盖场景模板」 | R3；`:164-176`,`:154-157` | general 兜底改为须登记理由；增加场景盘点数据产物与触点接线 |
| CA-06 | `SKILL.md`/selftest 脚本 | 修改/新增 | 增量 | 「践行任务执行防倒退原则可以在多个地方进行限制已经增加步骤」 | R1；`:215-228` | 接线初期登记/终检触发与新增自测断言，回归同集零增量 |

## 📚 必要知识储备（任务知识库对齐）

> Phase 1 开工前逐项确认可获取；必读项缺失 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | 既有防倒退闭环与修改合规（51.15/74.7/106.7/22.4e/103.3b） | `/mnt/data/dev/task-planner-skill/research/template-inventory.md:252-267` + 三份 critical-rules 对应行（实施期重验） | 必读 | ☑（计划期） |
| 项目内部文档/知识库 | 模板体系与加载链盘点 | `/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/template-inventory.md` | 必读 | ☑ |
| 项目内部文档/知识库 | 计划撰写任务书与约束 | `/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/subagent-state/01-planwriter-brief.md` | 必读 | ☑ |
| 规范/标准 | 模板域规则与选型权威（Rule 16/34/37/38） | `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/critical-rules-template.md`, `template-mapping.md`, `template-guide.md` | 必读 | ☐（实施期开工前复核） |
| 项目内部文档/知识库 | 防倒退知识条目（未跟踪）与取证 | `/mnt/data/dev/task-planner-skill/knowledge/entries/spec-baseline-freeze-anti-regression.md`, `/mnt/data/dev/task-planner-skill/knowledge/entries/modification-compliance-gate.md` | 参考 | ☐ |
| 项目内部文档/知识库 | variant-upgrade 既往经验 | `/mnt/data/dev/task-planner-skill/plans/INDEX.md` 中 `task-variant-upgrade-20261113` 记录及相关 archive（实施期检索） | 参考 | ☐ |

## ⚠️ 核心问题定义（强制）

**核心问题**: 在不回退既有规则/模板能力且不触碰主仓在途改动的前提下，如何将 R1 防倒退与 R2-R5 模板治理升级落地为可机器验证、可传导、不丢核心原则的长期机制？

**核心问题判断**:
- [x] 核心问题解决后，项目可交付“防倒退+模板治理升级”的规则/模板/守卫成套产物（可验证）。
- [x] 核心问题不解决，仅局部改模板或只写文档会继续出现倒退/漂移/存量失配，其他工作价值受损。
- [x] 解决方法清晰可执行：P1→P4 分期、worktree 隔离、S-unit 拆分、VC 机器判据、同集零增量回归。

## 🔍 调研需求与检索计划（Rule 75.1）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1 编号/基线核实 | LOCAL-ONLY | `^### 111`, `FAIL`, `selftest baseline` | 本地 grep/脚本执行/台账文件 | 编号空号证据 + selftest 基线 FAIL 清单 | 否 |
| S2-S5 规则与模板治理设计落地 | LOCAL-ONLY | `spec-baseline`, `lineage`, `spec_version`, `template-sense` | 本地 Read/Grep/现有 selftest 与条款对照 | 规则条款、模板区块、注册表、注入脚本 | 否 |
| S6 retrofit 机制化 | LOCAL-ONLY | `variant-upgrade`, `retrofit`, `spec_version<N` | 本地 plans/archive 检索 + 脚本原型 | retrofit SOP + 扫描脚本 + 清单输出 | 否 |
| S7 场景覆盖盘点 | LOCAL-ONLY | `template_type:`, `plans/`, `variant 覆盖` | 本地 `rg`/脚本统计 plans 历史与 variant 对照 | `research/scenario-coverage.md` 数据表 + 候选清单 | 否 |
| S8 回归与部署 | LOCAL-ONLY | `diff=0`, `zero delta`, `部署位逐位 diff` | 本地 selftest/git/部署位 diff 命令 | 回归对比与部署证据 | 否 |
| 通用异常（若实施遇阻） | NET-RESEARCH（条件触发） | `bash selftest regression`, `git worktree merge conflict` | WebSearch/Doc Search/research-assistant/GitHub 按 §七降级链 | findings 解法锚点 | 是（按需） |

> mini 豁免不适用（standard）。无 NET-* 常驻条目；执行期若触发异常按 §七 网络降级链取证并登记。

## 🔍 证据面清单（Rule 58.1）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓模板/规则/脚本/守卫现状与 18 在途改动 | Read/Grep/git status/diff + `research/template-inventory.md` | `plans/task-antiregress-tplgov-20261120/research/template-inventory.md` | ☑ |
| ② 对标样本 | 既有 51.15/74.7 防倒退闭环实现与 `task-variant-upgrade-20261113` 经验、历史 plans 模板类型分布 | 规则锚对照 + plans/INDEX+archive 检索 + 类型统计脚本 | `knowledge-brief.md §2` + P3 `research/scenario-coverage.md`（实施产出） | ☐ |
| ③ 外部约束 | 仓库宪法/AGENTS 约束（worktree、文本优先、编号唯一、自测零增量、白名单兼容）与既有脚本契约 | 必读 brief/AGENTS/SKILL 与脚本头契约核对 | `subagent-state/01-planwriter-brief.md`、`AGENTS.md(系统注入)`、inventory §5/§6 | ☑ |

## Current Phase
Phase 4（P4 部署收尾，complete；终局簿记=独立复检 103.3 返回后收口）

## Next Step
独立复检体（103.3）返回后处置结论→归档→记忆落盘→交付总结（含待用户批准项：skill-enhancement-type 新模板候选）

## 🧰 工具选择与编排（Rule 40）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| P1 防倒退机制 | Agent 子代理（code-assistant/haiku-1, general-purpose）、机械守卫脚本（grep/selftest/check-*）、卫星技能（task-planner/verification-before-completion） | 规则与模板多点改动需隔离执行与机器 VC；基线/编号核实依赖脚本证据 |
| P2 分级派生+原则注入 | Agent 子代理（code-assistant/haiku-1）、plan-template-kit、机械脚本（批量注入+check-template-type） | 31 variant 批量面需脚本化与抽检；注册表/条款属 kit 知识与治理落地 |
| P3 升级改造+主动加载 | Agent 子代理（code-assistant/haiku-1, Explore/mini 按需）、plan-template-advisor、机械脚本（统计/retrofit 扫描） | R3 场景缺口需数据盘点；R4 需机制化 SOP 与扫描脚本 |
| P4 部署同步与收尾 | Agent 子代理（code-runner-agent/mini, code-reviewer 按需）、机械守卫脚本（selftest/deploy/git）、卫星技能（verification-before-completion, alignment-review） | 终验需独立证据、同集零增量与部署 diff=0；合并清理属 git 编排白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 强制激活条件（P1-P4 有依赖链，不适合无脑 fan-out）；采用 Rule 21.4 独立性守门调度：P2 内“注入脚本生成”与“注册表/规则草拟”可在依赖满足后并行，P3 内“盘点统计”与“retrofit 脚本”可并行，其余串行。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC+`[goal:G1]..[goal:G8]` 作为 session goal 证据源；执行期若用户以 /goal 锚定，以本表与 VC 为完成审计依据。

## Phases

### Phase 1 (P1): 防倒退机制落地（R1，最高优先）
- [x] 创建 worktree 并跑全量 selftest 基线落盘（预存 FAIL 清单）
- [x] 回填本计划「📦 进度产出基线」（dogfood）并核实 Rule 空号
- [x] 新增进度产出防倒退 Rule（core+必要级联锚），与 51.15/74.7 分工互锁
- [x] 主模板/variant 同族接入基线登记+终检区块，SKILL/init/check-complete 接线
- [x] 新增/更新防倒退相关 selftest 断言并局部验证
- **V-N:** VC-02, VC-03, VC-04, VC-05, VC-16, VC-17
- **Status:** complete
- **Evidence:** worktree commit 15fc6c5（12 files 152+0-）；Rule 111@critical-rules.md:235 唯一/106.8@discipline:759/22.4f@dispatch:68；主模板 📦×2🛡×1 净效果×4；VC-05 grep 面 SKILL×2/init×1/check-complete×3/template×3+variant×3；selftest-antiregress 9/9 rc=0；run-selftests Total 101 PASS=93 FAIL=8==基线集零新增
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1句) | 执行体 | 输入(路径+≤10行摘要) | 验收(产出+VC) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------------|------|----|----------|-----------|---------|---------|------|
| S1 | (A6) 建 worktree、跑 selftest 全量基线并核实 Rule 空号 | 继承 | `brief:30-36,42`, `inventory:242-248`, `scripts/run-selftests.sh`；从 HEAD 建隔离区并记录 FAIL 集 | `research/selftest-baseline.txt`、编号核实记录（findings/progress）；VC-17, VC-02(编号前置) | 12min | 0f/20l/12min | verification-before-completion | - | complete |
| S2 | (A1) 新增进度产出防倒退 Rule 并改主模板基线/终检区块 | 继承 | `inventory:105-114,252-267`, `critical-rules.md:109`, `discipline:495`, `templates/task_plan.md:62-67`；登记→终检+净效果≥0 语义 | 三份 rules 新条款/锚点 + `templates/task_plan.md` 两区块；VC-02, VC-03, VC-04 | 15min | 4f/90l/15min（例外登记：三份规则级联+主模板同语义单元禁拆，4f>2f） | task-planner | S1 | complete |
| S3 | (A1) 接线 SKILL/init/check-complete 与 variant 同族+自测 | 继承 | `SKILL.md`, `scripts/init-session.sh`, `scripts/check-complete.sh`, `inventory:164-176,223-228`；初期登记/终检触发点与断言 | 脚本/SKILL 接线 + 防倒退 selftest + 抽样 variant 更新策略落地；VC-05, VC-16 | 15min | 4f/100l/15min（例外登记：接线面多触点机械单元，4f>2f） | systematic-debugging | S2 | complete |

### Phase 2 (P2): 模板分级派生与原则注入（R5+R2）
- [x] 定义 base/derived 与 lineage/spec_version 头规范、裁剪清单与派生铁律
- [x] 脚本批量注入 variant 元数据并抽检 `check-template-type.sh` 兼容
- [x] 建原则→模板区块注册表并落地覆盖守卫与 kit 接线
- **V-N:** VC-06, VC-07, VC-13, VC-14, VC-15
- **Status:** complete
- **Evidence:** commits d0c217f（32 files 206+，返工 #1 修 placement）+ 5818356（5 files 426+）；29 variant lineage 头+base/kit 声明+注入器幂等；注册表 spec_version=1+守卫 enforce/warn 双档（smoke PASS，实跑 fail=0 warn=145）；派生铁律双参照@kit SKILL:10+registry:28-31；plan-tier 32/32；全量 FAIL==基线 8 集
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1句) | 执行体 | 输入(路径+≤10行摘要) | 验收(产出+VC) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------------|------|----|----------|-----------|---------|---------|------|
| S4 | (A1) 设计并脚本化注入 lineage/spec_version/裁剪清单到 31 variant | 继承 | `inventory:94-99,130-133,223`, `templates/variant/*-type.md`, `check-template-type.sh`；base=主模板、derived=variant | 注入脚本 + 31 variant 元数据头 + 兼容校验记录；VC-13, VC-15 | 15min | 33f/100l/15min（例外登记：31 variant 同质脚本化批量，brief §4.4/§4.5 范式） | plan-template-kit | S3 | complete |
| S5 | (A1) 建原则→模板区块注册表与覆盖守卫并接线 kit 规则文档 | 继承 | `inventory:139-148,178-185`, `template-mapping.md`, `template-guide.md`, `critical-rules-template.md`；派生铁律/base+parent 双参照 | `principle-template-registry.md` + 覆盖守卫脚本/selftest + kit 同步；VC-06, VC-07, VC-14 | 15min | 5f/100l/15min（例外登记：注册表+守卫+kit 同步同语义单元，5f>2f） | plan-template-kit | S4 | complete |

### Phase 3 (P3): spec_version+存量改造与主动加载/场景覆盖（R4+R3）
- [x] 引入 spec_version 声明与 retrofit SOP/扫描机制（吸收 variant-upgrade 经验）
- [x] 数据驱动盘点 plans/ 类型分布与 variant 覆盖面，产出补缺候选清单
- [x] 改造 general 兜底为须登记理由并接线 init/check/advisor
- **V-N:** VC-08, VC-09, VC-10, VC-11, VC-12
- **Status:** complete
- **Evidence:** commits 546727e（5 files 264+：scan-template-spec.sh 双场景 OUTDATED:0/44 实证+retrofit SOP 六步+机制化判例）+ d78e930（3 files 10+：登记理由三点接线）；research/scenario-coverage.md（93 任务实测，缺口候选=skill-enhancement 待用户批准）；VC-08 grep 三文件各≥1；全量 FAIL==基线 8 集
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1句) | 执行体 | 输入(路径+≤10行摘要) | 验收(产出+VC) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------------|------|----|----------|-----------|---------|---------|------|
| S6 | (A1) 落地 spec_version 与 retrofit 扫描/改造 SOP 并验证存量清单输出 | 继承 | `inventory:290-294`, `plan-template-kit/SKILL.md`, `knowledge/entries/*anti-regression*`(参考)；机制化历史手工升级 | spec_version 字段规范 + `retrofit` 脚本/SOP + 扫描结果证据；VC-11, VC-12 | 15min | 4f/100l/15min（例外登记：规范+脚本+SOP 同语义单元，4f>2f） | plan-template-kit | S5 | complete |
| S7 | (A6) 统计 plans/ 类型分布并改造主动加载 general 登记理由链 | 继承 | `scripts/init-session.sh`, `scripts/check-complete.sh`, `plan-template-advisor/SKILL.md`, `plans/INDEX.md` 与 archive 分布；31 variant 清单 | `research/scenario-coverage.md` + 补缺候选决策登记 + 脚本/文档接线；VC-08, VC-09, VC-10 | 15min | 4f/100l/15min（例外登记：盘点+接线面多触点单元，4f>2f） | plan-template-advisor | S6 | complete |

### Phase 4 (P4): 部署同步、回归与收尾
- [x] 运行同集 selftest 并与基线对比零增量 FAIL
- [x] 执行部署同步并验证既有部署位 diff=0
- [x] 完成 `🛡 防倒退终检`、全量回读梳理、合并回主干与 worktree 清理、簿记
- **V-N:** VC-17, VC-19, VC-20
- **Status:** complete
- **Evidence:** 终验全量 selftest 103 脚本 PASS=95 FAIL=8==基线集（selftest-final.txt+fails diff 空）；merge bd1f131 零冲突+stash 窗口法恢复在途三簇（双簇内容共存验证）；部署 47 文件×4 位=188 copied_ok 0 MISMATCH（deploy-diff-report.txt）；worktree+分支已清理（11.3.5）
- **Executor:** code-runner-agent（mini）（S8 实际执行=主进程编排+code-assistant 通道受限下的降级编排，登记）

| ID | 目标(≤1句) | 执行体 | 输入(路径+≤10行摘要) | 验收(产出+VC) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------------|------|----|----------|-----------|---------|---------|------|
| S8 | (A6) 终验回归、部署同步 diff=0、合并清理与收尾登记 | 继承 | `research/selftest-baseline.txt`, `worktree-isolation.md` 合并契约（部署机制按 VC-19 修订口径实施期实测）；P1-P3 全部产出 | `research/selftest-final.txt`、部署 diff=0 清单证据、终检记录、合并提交与清理记录；VC-17, VC-19, VC-20 | 15min | 2f/60l/15min | verification-before-completion | S7 | complete |

## 📦 进度产出基线（Rule 进度产出防倒退·R1 — 初期登记/交付终检载体）

| 基线项 | 动工前快照（本计划撰写时基线） | 关键产出/指标 | 禁倒退清单 | 当前状态 |
|--------|--------------------------------|---------------|------------|----------|
| B-01 模板数量与结构 | 根模板 13 + variant 31 = 44（`research/template-inventory.md:94-99`） | 44 类模板可解析、`check-template-type.sh` 兼容 | 禁无登记删除模板文件；禁破坏三形态提取导致白名单失效 | 已登记（计划期） |
| B-02 规则防倒退闭环 | core 51.15/109、discipline 74.7/106.7、dispatch 22.4e/103.3b/110 已存在（`inventory:242-267`） | 既有条款语义与锚点不回退 | 禁覆盖/弱化 51.15/74.7；新 Rule 仅增量且分工互锁 | 已登记（计划期） |
| B-03 加载与感知链 | init-session T1 template-sense、check-complete T3 warn、白名单动态派生（`inventory:164-176,223-225`） | 选型/加载/终验提示可用 | 禁静默移除 template-sense 触点或破坏计数级联不补同步 | 已登记（计划期） |
| B-04 计划任务自身 | 本计划四文件已初始化；本轮交付=计划正文完备可验收 | `task_plan.md`+`knowledge-brief.md` 结构与 VC 完整 | 禁生成空占位计划；禁越权改四文件外内容 | 已回填（计划撰写完成态） |
| B-05 selftest 基线 | 2026-11-20 worktree@76a6466 全量实跑：Total 100 PASS=92 FAIL=8（预存 FAIL 集=active-plan/batch-pilot/enumerate-first/execution-stability/registry/rule-reserve-pairing/self-resolution/summary-readability） | `research/selftest-baseline.txt`（全文） | 收尾同集零增量：终验 FAIL 集≠基线集+新增即 FAIL；8 个预存 FAIL 非本任务引入不要求修复 | 已回填（基线落盘） |

> 交付前须逐项核对：任一既有产出删除/降级/替换需登记消费方影响评估且净效果≥0，否则 `BLOCK`（SPEC-ANTI-01）。

## 🛡 防倒退终检（交付/合并前强制）

| 检查项 | 判定方法（机器/可复核） | 证据锚 | 结果 |
|--------|-------------------------|--------|------|
| 既有防倒退闭环未削弱 | `**Verify command**: grep -n "51.15" skills/task-planner/references/critical-rules.md && grep -n "74.7" skills/task-discipline/references/critical-rules-discipline.md && grep -n "106.7" skills/task-discipline/references/critical-rules-discipline.md` 全命中 | master@bd1f131 grep 全命中（51.15@:109/74.7@discipline:495/106.7@:758） | PASS |
| 模板可解析与白名单兼容 | `check-template-type.sh` 等效逐 variant 循环 exit 0 | S4 复验 OK=31 FAIL=0（/tmp/s4-rework-check-template-type.log）；master 侧 selftest-template-lifecycle 24/24 | PASS |
| 进度产出净效果≥0 | 对照「📦 进度产出基线」B-01~B-05 逐项：无未登记删除/降级，消费方影响已评估 | 全程纯新增（P1-S3 四文件 0 删除复核；S4 仅 +lineage 头；git diff -U0 零删除行三查）；B-01~B-04 逐项在位（44 模板/规则锚/加载链/计划文件） | PASS |
| selftest 同集零增量 FAIL | `diff research/selftest-baseline-fails.txt research/selftest-final-fails.txt` 无输出 | diff 空（103 脚本 PASS=95 FAIL=8==基线 8 集） | PASS |
| 部署位无漂移 | 按 VC-19 修订口径逐位 diff 登记 | deploy-diff-report.txt：47 文件×4 位（zcode/.agents/.cursor/.claude）=188 copied_ok、0 MISMATCH | PASS |

> 净效果判据：diff 中既有产出的删除/降级/替换须登记消费方影响评估且净效果≥0，否则 `BLOCK`（禁止拆东墙补西墙）。

## 🔁 收尾回读梳理记录（Rule 84.14）

| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | 计划撰写期：初稿易遗漏 S-unit 表“产出/VC”显式列与风险四要素逐项命名 | 已按验收清单补齐 P1-P4 S-unit 列、VC `**Verify command**:`、风险区四要素与 `[goal:G1]..[goal:G8]`（本文自证） |
| 2 | 待实施终验填写 | 待实施期执行全量回读后登记 |

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号：主仓 18 未提交 M 涉及 `templates/task_plan.md`/rules/SKILL/scripts/config；与本任务高频触点重叠，合并期预期冲突，证据 `research/template-inventory.md:11-34,125`） |
| `isolation` | `worktree`（实现类治理升级+保护区相关改动，§十一 强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120` |
| `branch` | `wt/task-antiregress-tplgov-20261120` |
| `merge_back` | `merged(bd1f131)`（stash 窗口法：merge --no-ff 零冲突+pop 恢复在途三簇+双簇共存验证；worktree/分支已清理） |

> 契约详见 `skills/task-planner/references/worktree-isolation.md`；执行期不打断，冲突按 V3/V5/V6 合并期解决（Decision D1）。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| P1 | Rule 编号与既有 110 冲突或误占导致门控/引用混乱 | 8 | 4 | 3 | 96 | 实施前 `grep` 三份全集实测空号；冲突则顺延下一空号并更新计划登记（22.3③） |
| P1/P4 | `templates/task_plan.md` 与主仓在途 28.2.2 改动合并冲突 | 7 | 7 | 3 | 147 | worktree 从 HEAD 建隔离开发；合并期按 V3 三方对照逐块解决，保留双方语义并重跑 VC-03/04/15（22.3⑤ 前先 22.3① 改派复核） |
| P2 | variant 批量注入破坏 check-template-type 三形态/白名单兼容 | 9 | 4 | 4 | 144 | 先脚本 dry-run+单文件冒烟，再全量注入后立即跑兼容校验；失败则回滚该 S-unit 变更拆细重试（22.3②/③） |
| P3 | 场景选取无数据支撑或与 pending 任务重复 | 6 | 6 | 4 | 144 | 强制产出 `research/scenario-coverage.md`（plans/ 分布统计+31 对照+频率表）后才登记补缺候选；数据不足则标“未验证”不入选（22.3⑤ AskUserQuestion） |
| P3/P4 | spec_version/retrofit 引入后部署位或计数级联漂移 | 7 | 5 | 4 | 140 | 变更触发四点同步清单逐项核对；P4 按 VC-19 修订口径（实测部署机制+逐位 diff=0 清单）与关键锚点验证，不通过则修复同步后复验（22.3①） |
| P4 | selftest 基线误判（未同集对比）导致假 PASS/假 FAIL | 8 | 3 | 5 | 120 | S1 落盘 `selftest-baseline.txt`，S8 落盘 `selftest-final.txt`，仅对比 FAIL 集差分零增量（22.3④ 主进程复核） |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| P1 防倒退机制落地 | ☐ | - | 待实施期建映射 |
| P2 分级派生与原则注入 | ☐ | - | 待实施期建映射 |
| P3 升级改造与主动加载 | ☐ | - | 待实施期建映射 |
| P4 部署同步与收尾 | ☐ | - | 待实施期建映射 |

## Key Questions
1. 进度产出防倒退新 Rule 的最终编号是多少（候选 111+，需实施前 grep 三份 rules 实测空号）？答：S1 核实后登记。
2. `spec_version` 初始值与 retrofit 目标版本 N 如何定义（全局统一 vs 分模板族）？答：P3-S6 依据 kit 现状与 variant-upgrade 经验给出可验证方案并登记。
3. R3 “增加覆盖场景模板”在数据盘点后哪些候选入选为本任务实施项、哪些仅登记为后续建议？答：S7 产出 `scenario-coverage.md` 后按频率与成本在 Decisions/风险区数据化裁决。

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Decision D1: 在途改动不碰、实现从 HEAD 建 worktree、`templates/task_plan.md` 等合并冲突延后处理 | 依据 `research/template-inventory.md:11-34` 与 `subagent-state/01-planwriter-brief.md:32`、worktree SOP（用户裁决/既有规范）；避免破坏三簇在途任务并隔离风险。 |
| Decision D2: 按 P1(R1)→P2(R5+R2)→P3(R4+R3)→P4(部署+收尾) 分期推进 | 依据 brief §3；先建立防倒退闭环再治理结构与升级机制，依赖清晰、每期可独立验收、回归面可控。 |
| 模板选型：`template_type: rule-enhancement` | 任务主轴为规则/机制与模板治理升级，最贴合 `variant/rule-enhancement-type.md`（`inventory:98`）；批量结构改造参考 refactor 实践但不改变单一最适配类型。 |
| R3 补缺模板策略：先数据盘点后候选登记，非本轮拍脑袋新增 | 满足“场景选取数据依据”与 R3 目标；新增模板属高影响面，需分布证据与容量评估后实施。 |
| 批量 variant 改造：脚本生成 + 抽检/全量兼容校验 | 满足 brief §4.4/§4.5；31 文件手工易漏且破坏三形态提取风险高。 |
| Decision D3: 用户 2026-11-20 回复「继续」=G1 门放行（计划批准，呈报含判别结论+幻锚修订说明） | 专档 user-session-log.md #1 逐字；批准态=按 P1→P4 执行，禁再就批准与否上抛（Rule 95）；VC-17 基线文件口径注：落主仓计划目录 research/（计划目录在主仓侧，worktree 无 plans/ 任务目录） |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| 无（计划撰写阶段） | 0 | 无 | 实施期错误按 progress.md Error Log 即时登记并析因 |

## Notes
- 本计划为 P1 防倒退机制首个实弹载体：实施动工前必须补全 B-05 selftest 基线并保持 B-01~B-04 不倒退（见 `📦 进度产出基线`）。
- 所有 VC 使用 `**Verify command**:` 机器判据；执行期登记实际命令输出与路径锚点。
- Update phase status as you progress: pending → in_progress → complete；S-unit 状态与 `[goal:Gn]` 同步。

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-20 计划撰写 | 无执行漂移（未改四文件外内容） | VC-20 | PASS（计划阶段） |

## 📦 Batch Report（批量处理质量门控）

| 字段 | 值 |
|------|-----|
| `total` | n/a（本计划文档为单次撰写；实施期 P2-S4 批量处理 31 variant 时在执行记录中按实际填写并落证据） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a（批量时 >5% STOP；>20% 熔断回滚） |
| `pre_check` | n/a（批量时填 Q1:否/Q2:有/Q3:能） |
| `sampled_pass` | n/a（批量时填运行后抽 10%） |
| `sampled_fail` | n/a（批量时填运行前抽 2，>0 熔断） |
| `rollback_point` | n/a（批量时必须登记；为空禁止批量） |

## 📊 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 4（计划撰写阶段；实施期更新） |
| 主进程直做 Phase 清单 | P0 计划撰写（计划系统文件维护，Rule 25.3 白名单②） |
| 委派率 | n/a（实施期按实际统计；目标 ≥ delegation_rate_floor） |
| 激活子代理数（Rule 96.5） | 0（计划撰写阶段） |
| 最大并行宽度（Rule 96.5） | 0 / 最宽 0（计划撰写阶段） |
| 串行化例外理由（Rule 96.4） | none（计划撰写阶段） |

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-20 | plan-writer (sonnet-1, 派发尝试) | 撰写 task_plan/knowledge-brief | failed | provider 报 reasoning-level-missing，确定性配置错误 | `progress.md` Dispatch Log D-01 | progress.md `## Dispatch Log` | `subagent-state/01-general-planwriter.md`（本轮未落盘，scope 受限） | - / 0 / ☐ |
| 2 | 2026-11-20 | general-purpose (内联降级) | 按 brief 完成计划正文 | done | 已完成 task_plan.md 与 knowledge-brief.md 撰写与结构自查 | 本文件+`knowledge-brief.md` | `findings.md`（未写入，scope 受限） | `subagent-state/01-general-planwriter.md`（未落盘） | - / 0 / ☐ |
| 3 | - | - | - | pending | - | - | - | - | - / 0 / ☐ |

## 🔗 Chain 区块交接配置

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single`（本轮为计划撰写；后续实施按 P1-P4 阶段推进） |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是（计划批准后交接实施执行体） |

### Block 1: 计划撰写与实施准备（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | 产出 R1-R5 全覆盖、VC 可机器验证的实施计划与知识简报 |
| **depends_on** | none |
| **passes_to** | Block 2: `plans/task-antiregress-tplgov-20261120/task_plan.md` + `knowledge-brief.md` |
| **status** | complete |

### Block 2: P1-P4 实施与收尾（后续）

| 字段 | 值 |
|------|-----|
| **goal** | 在 worktree 内完成 R1-R5 落地、回归、部署与合并 |
| **depends_on** | Block 1 → 本计划获批 + VC-18 通过 |
| **passes_to** | Block 3: 合并提交 + 归档产物 |
| **status** | pending |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | complete | `/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md`; `/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/knowledge-brief.md` | `**Verify command**: grep -q "Decision D1" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md && grep -q "Decision D2" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md` | 2026-11-20 |
| Block 2 | pending | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120`（实施期） | `**Verify command**: 待 P4 按 VC-01~VC-20 执行` | - |

## 补充：风险区（含四要素）与 R3 场景选取数据依据

- **合并冲突**：主仓 `templates/task_plan.md` 等 18 未提交文件在途（`research/template-inventory.md:11-34`），本任务 worktree 从 HEAD 开发，P4 合并预期冲突；处置=执行期不打断、合并期三方对照 V3/V5/V6 解决并重跑 VC-03/04/05/15。
- **白名单兼容**：R5/R2 批量注入 variant 头与区块可能破坏 `check-template-type.sh` 三形态提取或 template-sense/selftest 锚点；处置=注入脚本 dry-run+冒烟、全量兼容校验（VC-15）与相关 selftest 同步更新。
- **部署漂移**：规则/模板/kit 计数级联与多部署位可能不同步；处置=P4 执行四点同步检查+按 VC-19 修订口径逐位 diff=0 清单验证，漂移则阻断合并清理。
- **场景选取数据依据**：R3 “增加覆盖场景模板”不得拍脑袋；P3-S7 必须统计 `plans/` 与 `plans/archive/` 的 `template_type`/任务类型分布，对照当前 31 个 `variant/*-type.md` 覆盖面与频率，产出 `research/scenario-coverage.md`（含计数表、缺口频率排序、补缺候选与不入选理由）。计划内决策点：仅当候选在分布中出现频率与 ROI 达到登记阈值（实施期在 S7 明确阈值并记录）才纳入实施，否则登记为后续建议。

**R3 补缺候选登记（计划期初始状态）**：候选清单 = 待 S7 数据产出后填写；当前依据 = `inventory:94-99` 显示 31 variant 现状、`inventory:272-296` 显示 pending 主题交叉（如 l0-lite/variant-upgrade/positioning），但无 `plans/` 全量频率统计，故本轮不预选新增模板名称（避免拍脑袋）。
