# Task Plan: task-v160 决策分级与用户打断纪律（Rule 72）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「他将一些无关紧要的东西交给用户去决策，重要的东西，然后毫不犹豫的就给恶意修改掉。比如更换风格，这么严重的这么严重这么重大的决定完全不能询问用户，但是其他毫无根据的，比如说这个地方有错误，是否需要修正，这种莫名其妙的。」<sub>（[目标]）</sub>
- **R2**: 「生成视频的时候，生成是采取哪种方式生成视频？这么重大的决定，自己完全就是不需要仅用户决定，决策进行恶意的修改了。而且这种修改完全违背了之前所有的计划，完全不通知用户。」<sub>（[目标]）</sub>
- **R3**: 「有一些图片的，图片是否存在问题？这种最简单的，比如说最简单的错误，连基础性的错误都无法审核。比如说动物出现了，一个猫咪出现了五条腿，这种错误都审核不出来，让用户去主动审核」<sub>（[目标]）</sub>
- **R4**: 「本来在一小时之内可以执行完成的事情，在运行完运行了十几分钟或者几分钟之后，就因为一个莫名其妙的、无关紧要的事情打断用户的执行。要求用户去抉择。」<sub>（[目标]）</sub>
- **R5**: 「在其他无关紧要的事情上一直骚扰用户，还浪费，还因为这些无关紧要的事情卡住用户的整个执行。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | Rule 72 条文三级表在位；A 级场景（风格/生成方式变更）条款含「必须询问+禁擅自执行」 |
| R2 | VC-1, VC-2 | 「违背既定计划不通知」禁令条款在位（72.2）；变更呈报按 Rule 70 四要素 |
| R3 | VC-1, VC-2 | 基础质检硬门条款在位（72.4）：物理常识错误禁上抛代审 |
| R4 | VC-1, VC-2 | 琐碎上抛禁令条款在位（72.3）：C 级禁 AskUserQuestion+自动消解 |
| R5 | VC-3, VC-4, VC-6, VC-7 | 机器守护在位+全量回归+合并部署+双审查（防复发闭环） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 条文层（规则定义） | Rule 41/44 只约束「何时可不问」，缺正向「哪些必须问」的影响权重轴（5 Whys 根因③） | Rule 72 新条文（S1） | VC-1 |
| 触点层（决策点指令） | D2-D6 选项/升级/熔断呈报无分级引用；44.2 低区分度判据未升级为禁问 | 触点修补 S3-S6（6 文件） | VC-2 |
| 模板层（送审/质检载体） | 媒体送审清单无「基础质检硬门+禁上抛代审」规格 | S5 模板修补 | VC-2 |
| 机器层（守护） | 决策分级零守护 | selftest-decision-grading.sh（S7-S8） | VC-3 |
| 回归层 | 新增行撞既有锚（历史 5 次判例） | 全量回归+级联清账（S9-S10） | VC-4 |
| 分发层 | 部署位漂移 | 合并回+--deploy 对账（P8） | VC-6 |

<!-- plan_tier: standard -->
## Goal
task-planner 技能建立 Rule 72 决策分级与用户打断纪律：A 级重大变更（推翻已确认计划要素/不可逆/对外）必须询问用户、禁擅自执行；C 级琐碎事项（有明确对错的局部修复/质检结果）禁止上抛用户、必须自动消解+登记；媒体产物基础性质检（物理常识错误）设为执行体硬门、不合格禁送审代审。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 代码文件，重 diff 全量 CR） |
| `session_id` | `task-v160-20261010-bc12ebe6` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v160-decision-grading` |
| `scope_files` | 见「⚠️ 执行范围限制」表 |
| `interaction_mode` | `ask`（默认；D1 按 Rule 44.3 自治自动裁决并登记五要素，见 Decisions Made） |
| `对齐审查` | P7/S12 alignment-review（review-library 池），CHANGES 闭环复验 |
| `自动超时默认项` | D1 计划批准：默认项=按本计划执行（推荐）/超时 5min；其余询问点：默认=推荐项/5min；自治会话一律按 44.3 自动裁决+登记五要素，D6 硬停点除外 |
| `new_rule` | `72`（账本核实：70=v155 landed、71=v158 预留、72 可用——已 reserve） |
| `质量审查工具` | 四级检测：项目级无专用→用户级 review-library 池命中 `code-quality-review`（代码面）+`alignment-review`（对齐面）；执行期 P7 必须用登记工具；无待补建缺口 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行，主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 72 条文在位：`^## Rule 72` 段落含 72.1-72.6 子条锚，三级关键词（A 级必须询问/C 级禁止询问/基础质检硬门）各 ≥1 命中 | grep 命令 | `cd <worktree>/skills/task-planner && grep -cE "72\.[1-6]" references/critical-rules.md` ≥6 |
| VC-2 | 触点修补零缺口：6 文件（critical-rules 28.3/41.2/41.3/44.2/44.5、media 模板×2、companion×2）逐一含 Rule 72 引用或分级结构补齐 | 逐一 grep | `grep -l "Rule 72" <6 文件逐一>` 全命中，缺口计数=0 |
| VC-3 | 机器守护在位：selftest-decision-grading.sh 存在可执行且自跑 exit 0；registry.tsv 有登记行 | 运行命令+grep | `bash skills/task-planner/scripts/selftest-decision-grading.sh; echo $?` → 0 |
| VC-4 | 全量回归零破坏：worktree 内全部 selftest 脚本 ΣFAIL=0（合并后预期 68 脚本） | 批量运行 | `for f in skills/task-planner/scripts/selftest-*.sh; do bash $f; done` 汇总 |
| VC-5 | 行为实证：A 级场景条款（风格/生成方式变更必须询问）与 C 级场景条款（错别字修复禁 AskUserQuestion）文本在位且语义完整 | grep 抽查 | `grep -c "必须询问" critical-rules.md` ≥1 且 `grep -c "禁止.*AskUserQuestion\|禁.*上抛" critical-rules.md` ≥1 |
| VC-6 | 合并回+部署：master 存在 --no-ff merge commit；部署位逐位 diff=0（IDENTICAL） | git log+diff | `git log --oneline -3` + 逐位 `diff -r` 对账 |
| VC-7 | 双审查 APPROVED：code-quality-review 与 alignment-review 双 verdict=APPROVED（CHANGES_REQUESTED 已修复并复验闭环） | 审查 verdict | checkpoint 文件 + findings.md 审查段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3/R4/R5（全部 [目标]） |
| **裁决** | （终验填写：solved / partial / not-solved） |
| **解决证据锚** | （终验填写：VC-1..VC-7 证据行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填） |
| **下一步建议** | （not-solved 必填） |

> 判据（58.4 问题解决判据）：重大变更（风格/生成方式/范围）未经询问即执行=违规可机器检出；琐碎事项上抛用户=违规可机器检出；基础质检不合格送审=违规可机器检出。

## 🎯 Goal 单元表（Rule 66.1 — standard 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 调研与归因 | 决策分级缺陷 5 Whys 归因落盘 | findings.md §决策分级归因段在位 | S0/Phase 1 | complete |
| G2 | 条文与索引 | Rule 72 条文+SKILL 接线落位 | grep 72.1-72.6 锚 ≥6；SKILL 索引含 Rule 72 | S1-S2/Phase 2 | complete |
| G3 | 引用面触点 | critical-rules 四处决策点补 72 引用 | 4 处 grep Rule 72 命中 | S3-S4/Phase 3 | complete |
| G4 | 模板与管线触点 | 媒体送审+companion 补分级规格 | 4 文件 grep Rule 72 命中 | S5-S6/Phase 4 | complete |
| G5 | 机器守护 | selftest-decision-grading+registry 落位 | selftest 自跑 exit 0+registry 行在位 | S7-S8/Phase 5 | complete |
| G6 | 回归清账 | 全量 selftest ΣFAIL=0 | 跑批记录（progress.md Round 行四要素） | S9-S10/Phase 6 | complete |
| G7 | 双审查 | 代码面+对齐面双 APPROVED | 两 checkpoint verdict=APPROVED | S11-S13/Phase 7 | complete |
| G8 | 合并交付 | 合并+部署 IDENTICAL+终验交付 | merge commit+逐位 diff=0+delivery-summary | P8 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 条文/索引（worktree 内） | skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md | 其他技能文件 |
| 引用面（worktree 内） | skills/task-planner/references/critical-rules.md（28.3/41.2/41.3/44.2/44.5 段） | 其他 references |
| 模板面（worktree 内） | skills/task-planner/templates/variant/image-type.md、templates/variant/multiview-ref-type.md | 其他模板 |
| 管线面（worktree 内） | skills/task-planner/companion/agents/article-batch-publisher.md、companion/agents/article-field-fixer.md | 其他 companion |
| 守护面（worktree 内） | skills/task-planner/scripts/selftest-decision-grading.sh（新建）、scripts/selftest-registry.tsv | 其他脚本；config.json（零新键，禁改） |
| 簿记（主仓） | plans/task-v160-decision-grading/*（计划系统文件，Rule 25.3 白名单②） | 其他 plans/ 目录（v152/153/154/156/157/158/159 并行在途，禁碰） |
| 部署位 | 仅 P8 合并后由 smart-merge-back.sh --deploy 流程写入 | 手工直改部署位 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？（用户 2026-10-10 显式「批准」）
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | critical-rules.md Rule 41/44/47/50/69/70（决策/质检/呈报既有条文） | <技能根>/references/critical-rules.md | 必读 | ☑ |
| 项目内部文档 | Rule 70 条文（v155 刚落地，72.2 消费） | 同上 Rule 70 段 | 必读 | ☑ |
| 项目内部文档 | v155 决策分级归因（5 Whys 根因） | /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/findings.md §新投诉归因 | 必读 | ☑ |
| 项目内部文档 | selftest 范式与 registry 登记纪律 | <技能根>/scripts/selftest-report-reviewability.sh + selftest-registry.tsv | 必读 | ☑ |
| 项目内部文档 | worktree 隔离 SOP | <技能根>/references/worktree-isolation.md | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: 决策点缺「影响权重」分级轴——重大变更（推翻已确认计划要素）不询问即执行、琐碎事项（有明确对错的局部修复）反复上抛用户、基础质检（物理常识错误）推给用户代审。解决后能交付：能——三级纪律+机器守护落地且可验证（VC-1/2/3）。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？（只修条文不修触点=第三次复发）
- [x] 核心问题的解决方法是清晰的、可执行的？

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本技能决策点全量（41/44/47/50/69/70 条文+媒体模板+companion） | 主进程直读（v155 已建审计方法） | findings.md#决策分级归因 | ☑ |
| ② 对标样本（58.2 强制） | v155 Rule 70 呈报四要素（同仓成功先例：条文→触点→守护三层闭环） | 主进程直读 | findings.md#决策分级归因 | ☑ |
| ③ 外部约束 | selftest 锚级联纪律（历史 5 次判例）+registry 登记纪律+并行任务编号预留 | 记忆+账本核实 | findings.md#Resources | ☑ |

## Current Phase
Phase 8（全部 complete）

## Next Step
交付完成（见 delivery-summary.md；下一步=用户确认第三条反馈总结模板面立项方式）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini) | 决策点全量审计（Rule 13 隔离）——已完成 |
| Phase 2 | Agent 子代理 executor(sonnet-1) | 条文落位为判断型文本写入（材料包内联于本计划） |
| Phase 3-4 | Agent 子代理 code-assistant(haiku-1) | ≤2 文件/≤15 行机械指针补丁（最小可承载档，43.2） |
| Phase 5 | Agent 子代理 executor(sonnet-1) | 新 selftest 为判断型脚本编写 |
| Phase 6 | Agent 子代理 code-runner-agent(mini)+executor | 跑批与级联修复分离 |
| Phase 7 | Agent 子代理 code-reviewer(sonnet-1)+general-purpose(对齐审查) | 独立审查视角 |
| Phase 8 | 主进程（白名单①git 编排+②簿记） | smart-merge-back/deploy/簿记为编排动作 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（用户未点名 /workflow；子任务同文件强串行为主）→ 按 Rule 21.4 独立性守门调度；写集均不相交的 S-unit 按声明组并行（S3‖S4、S5‖S6、S11‖S12），其余串行
**/goal 对齐（Rule 40.3）**: 本计划 Goal+Goal 单元表即 session goal 证据源；用户未用 /goal 锚定；技能层不可代调

## Phases

### Phase 1: 调研审计与归因
- [x] 决策点全量审计（引用 v155 findings 触点审计方法+本任务归因）
- [x] Rule 31 四维归因（5 Whys 根因=41/44 单向「少打扰」机制缺反向轴）
- [x] 结论落盘 findings.md
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S0 | 决策分级缺陷 5 Whys 归因 | explore(mini) | skills/task-planner/（41/44/47/50/69/70 条文+媒体模板+companion 扫描） | 归因段落落盘 findings.md | 15min | 0f/0l/15min | 无 | - | complete |

### Phase 2: Rule 72 条文与 SKILL 主索引
- [ ] critical-rules.md 追加 Rule 72 条文（§72.1-72.6，材料=本计划「📜 Rule 72 条文草案」节）
- [ ] SKILL.md 主索引接线（Rules 全集行/References 表/终验交付段联动/合规清单 C49）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | Rule 72 条文写入 critical-rules.md（Rule 70 段之后追加，不硬编码行号锚） | executor(sonnet-1) | skills/task-planner/references/critical-rules.md + plans/task-v160-decision-grading/task_plan.md（§条文草案逐字采用） | `grep -cE "72\.[1-6]" references/critical-rules.md` ≥6 | 15min | 1f/60l/15min | 无 | - | pending |
| S2 | SKILL.md 接线：Rules 全集行加「Rule 72 决策分级与用户打断纪律（task-v160）」条目+范围改「1-72」、References 表 critical-rules 行同步、终验交付段补 Rule 72 联动半句、合规清单新增 C49 行（材料=本计划 §接线材料包） | executor(sonnet-1) | skills/task-planner/SKILL.md + plans/task-v160-decision-grading/task_plan.md（§接线材料包） | grep "Rule 72" SKILL.md ≥4 命中且 C49 行在位 | 15min | 1f/12l/10min | 无 | S1 | pending |

### Phase 3: 触点修补 A（引用面决策点）
- [ ] critical-rules.md 28.3（D2-D6 选项）/41.2-41.3（升级门槛）/44.2（低区分度）/44.5（阻塞点）补 Rule 72 分级引用
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S3 | critical-rules.md 28.3 选项呈报段+41.2/41.3 升级门槛段各补「按 Rule 72 分级：A 级必须询问/B 级默认项/C 级禁问」指针（T1-T2） | code-assistant(haiku-1) | skills/task-planner/references/critical-rules.md + plans/task-v160-decision-grading/task_plan.md | 2 处 grep "Rule 72" 新增命中 | 10min | 1f/8l/10min | 无 | S1 | pending |
| S4 | critical-rules.md 44.2 低区分度段+44.5 阻塞点段补 Rule 72 C 级禁问引用（T3-T4） | code-assistant(haiku-1) | skills/task-planner/references/critical-rules.md + plans/task-v160-decision-grading/task_plan.md | 2 处 grep "Rule 72" 新增命中 | 10min | 1f/8l/10min | 无 | S3 | pending |

### Phase 4: 触点修补 B（模板与管线）
- [ ] 媒体送审模板补「基础质检硬门+禁上抛代审」规格
- [ ] companion 熔断呈报补 Rule 72 分级引用
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | image-type.md 与 multiview-ref-type.md 送审清单补「基础质检硬门（Rule 72.4）：物理常识错误（肢体数量/文字乱码/构图破损）必须执行体 QC 完成+留证据，不合格禁上抛代审」规格（T5） | code-assistant(haiku-1) | skills/task-planner/templates/variant/image-type.md + skills/task-planner/templates/variant/multiview-ref-type.md | 两文件 grep "Rule 72" 命中 | 8min | 2f/12l/8min | 无 | - | pending |
| S6 | article-batch-publisher.md 与 article-field-fixer.md 熔断/跳过呈报点补 Rule 72 分级引用（T6） | code-assistant(haiku-1) | skills/task-planner/companion/agents/article-batch-publisher.md + skills/task-planner/companion/agents/article-field-fixer.md | 两文件 grep "Rule 72" ≥2 | 5min | 2f/8l/5min | 无 | - | pending |

### Phase 5: 机器守护
- [ ] 新建 selftest-decision-grading.sh（DG 断言：条文锚/接线锚/触点锚/registry/零新键）
- [ ] registry.tsv 登记新脚本行
- **V-N:** VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S7 | 新建 scripts/selftest-decision-grading.sh 上半（DG-01..07：Rule 72 条款锚+SKILL 接线锚+registry 自登记断言；范式=selftest-report-reviewability.sh） | executor(sonnet-1) | skills/task-planner/scripts/selftest-report-reviewability.sh + plans/task-v160-decision-grading/task_plan.md（§守护断言清单） | 脚本存在且 bash 语法检查通过 | 15min | 1f/90l/15min | 无 | - | pending |
| S8 | 追加上半（DG-08..12：6 触点文件锚断言+registry 登记行+config 零新键）+chmod+x+自跑 | executor(sonnet-1) | skills/task-planner/scripts/selftest-decision-grading.sh + plans/task-v160-decision-grading/task_plan.md | 自跑 exit 0 | 10min | 1f/70l/10min | 无 | S7 | pending |

### Phase 6: 全量回归与锚级联清账
- [ ] worktree 内全量 selftest 跑批（Round 1，结果四要素落 progress.md）
- [ ] FAIL 清单级联修复→重跑至 ΣFAIL=0（条件执行）
- **V-N:** VC-4, VC-3
- **Status:** complete
- **Executor:** code-runner-agent（mini）+executor（sonnet-1，条件修复）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | worktree 内全量 selftest 跑批（for f in selftest-*.sh）+FAIL 清单落盘 subagent-state 检查点 | code-runner-agent(mini) | skills/task-planner/scripts/selftest-*.sh（跑批，禁逐文件罗列） | 输出含每脚本 PASS/FAIL 与 ΣFAIL 计数 | 15min | 0f/0l/15min | 无 | - | pending |
| S10 | （条件：ΣFAIL>0）按 FAIL 清单修锚级联（单次派发 ≤2 文件，超限再拆多轮派发）→ 重跑至 ΣFAIL=0 | executor(sonnet-1) | 检查点 FAIL 清单（S9 产出路径执行期回填）+涉及断言脚本 | 重跑 ΣFAIL=0 | 15min | 2f/30l/15min | 无 | S9 | pending |

### Phase 7: 双审查（Code Review Gate）
- [ ] 代码面审查（本次改动 .sh 文件）
- [ ] 对齐面审查（全部条款/文档改动 vs 既有规范口径）
- [ ] CHANGES 处置（条件）
- **V-N:** VC-7, VC-4
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）+general-purpose（alignment-review）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S11 | 代码面审查：worktree 内 git diff 的 .sh 改动（selftest 新脚本），输出 APPROVED/CHANGES_REQUESTED+逐条 file:line | code-reviewer(sonnet-1) | worktree 内 skills/task-planner/scripts/*.sh（本次改动 2 文件，执行期给 git diff 基线） | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | - | pending |
| S12 | 对齐面审查：按 review-library/alignment-review/SKILL.md 对全部 .md 改动跑对齐审查，输出 verdict+问题清单 | general-purpose(sonnet-1) | skills/task-planner/review-library/alignment-review/SKILL.md + worktree git diff（.md 集合） | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | - | pending |
| S13 | （条件：CHANGES_REQUESTED）逐条修复（单次派发 ≤2 文件，超限多轮）→复验→两 verdict 翻 APPROVED | executor(sonnet-1) | 两 checkpoint 的 CHANGES 清单（执行期回填路径） | 复跑两审查 verdict=APPROVED | 15min | 2f/80l/15min | 无 | S11,S12 | pending |

### Phase 8: 合并回+部署+终验簿记交付
- [x] smart-merge-back.sh --deploy（预期与并行任务尾段冲突→并集解，v149/v155 判例）
- [x] 部署位逐位对账 IDENTICAL
- [x] rule-reserve land 72 + verification.md VC 复验 + 需求覆盖核对表
- [x] delivery-summary（本任务交付总结本身按 Rule 48/70/72 金标准输出）
- **V-N:** VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排+② 计划系统簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①未提交变更=并行任务 plans/ 目录非本任务范围；信号②额外 worktree×N=v152/153/154/156/157/158/159 在途；信号③遗留 wt 分支×N=同上在途非遗留；信号④⑤无。本任务 scope 与并行任务在 critical-rules.md/SKILL.md 尾段存在可预期合并冲突，按 v149/v155 并集解判例处置） |
| `isolation` | `worktree`（修改运行中基础设施，§十一 P0） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v160-decision-grading` |
| `branch` | `wt/v160-decision-grading` |
| `merge_back` | `pending` |

> 创建后先 diff 关键文件与 master 一致性（worktree-branch-desync 判例）；子代理派发 prompt 必带 worktree 绝对路径+「禁止触碰其他 worktree」约束（§11.4）。

## 📊 FMEA 预演（规划期）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2-5 | 新增行撞既有 selftest 定数断言（SKILL 行数/规则范围 1-70/合规清单计数——历史 5 次级联判例） | 7 | 6 | 3 | 126 | 兜底=Phase 6 全量回归必然暴露（D 层探测）+S10 修复档（22.3④ 主进程协调 executor 修，口径扩展非回退范式 v117 判例） |
| Phase 8 | 与并行 v152-159 在 critical-rules.md/SKILL.md 尾段合并冲突 | 6 | 7 | 2 | 84 | v149/v155 并集解判例：逐 hunk 并集保三方条文+重跑全量回归；禁 rebase 强推 |
| Phase 8 | worktree 基础文件与 master 不同步（desync 判例） | 7 | 3 | 2 | 42 | 创建后立即 diff 关键文件（critical-rules/SKILL/registry），不一致从 master 取正确版本 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-10 | 计划创建时 S1 建映射 |
| Phase 2 | ☑ | 2026-10-10 | 同上 |
| Phase 3 | ☑ | 2026-10-10 | 同上 |
| Phase 4 | ☑ | 2026-10-10 | 同上 |
| Phase 5 | ☑ | 2026-10-10 | 同上 |
| Phase 6 | ☑ | 2026-10-10 | 同上 |
| Phase 7 | ☑ | 2026-10-10 | 同上 |
| Phase 8 | ☑ | 2026-10-10 | 同上 |

## Key Questions
1. Rule 72 编号是否可用？→ 已核实账本：70 landed、71=v158 预留、72 可用（已 reserve 2026-10-10）。
2. 触点修补采用全文复制还是指针引用？→ 指针引用（72.5 单一权威源，防口径漂移）。
3. 机器守护会不会破坏既有交付门控？→ 只增静态断言+warn，exit 语义零改动。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| D 类新任务边界判定：用户 2026-10-10「批准」第二条反馈修复 → 开 task-v160 新计划 | Rule 8.1；v155 已 COMPLETE（呈报信息面），本任务=决策分级面，不同规则域 |
| 编号顺延 v160（非 v156） | v156-drift-shield 已被并行会话占用（范围=漂移愤怒案例，不同族）；v157/158/159 同被占用；取下一可用号 |
| Rule 72 编号 | 账本核实：70 landed、71=v158 预留、72 可用（已 reserve） |
| 新增 Rule 72 而非扩写 Rule 41/44 | 41/44 是「消解/默认项」机制，72 是「分级」元规则；独立编号便于触点统一引用（72.5） |
| 机器守护只增静态断言+warn | 对齐 v155 判例：exit 语义是交付门控承重墙 |
| Rule 36.3 删除性行为清单 | **无删除性行为**：零文件删除/零条款删除；SKILL 索引口径演进（1-69+70→1-72）、C49→C51 编号让位均为并集新增非删除；selftest 改造全部为锚扩展（断言条数不减：DG 12/CD 24/RF 12/P 9/RR 17/EL 16/CP 20/SA 12/TS 12/LA 14/RC 23/SR 13/RV 12/SS 41/VT 13） |
| D1 计划批准按 Rule 44.3 自动裁决 | 五要素：超时值=即时（自治会话无在线用户）/推荐项=按本计划执行/触发时间=2026-10-10/理由=harness 自治指令+用户显式「批准」/被覆盖选项=等待显式 yes；D6 硬停点不受影响 |
| D 类判定②：用户 2026-10-10 第三条反馈（总结阶段模板缺陷=审查清单不列/圆圈数字格式混乱/派发模板为源头）→ 立项 task-v161（Rule 73 方向：总结格式可读性+审查清单实体化+派发模板格式源修正） | Rule 8.1——超出本计划 Goal/VC 范围；用户原话与实锤（subagent_dispatch.md 返回格式段 ①②③）已记 findings.md §第三条反馈立案材料；本计划先收尾交付 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （暂无） | 1 | | → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 本任务交付总结本身必须按 Rule 48/70/72 金标准输出（以身作则）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a（不符合 18.1 批量识别条件：触点修补为逐文件独立内容，非同质批量单元） |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a（Rule 18 前置 3 问不适用：无同质批量单元） |
| `rollback_point` | n/a（本任务回滚方式=`cd /mnt/data/dev/task-planner-skill && git revert <merge-commit>`，见 verification.md 风险点） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 7 / 8（P1-P7 全部子代理；P8 主进程白名单） |
| 主进程直做 Phase 清单 | Phase 8（例外理由：① git/worktree 编排+② 计划系统簿记——Rule 25.3 白名单①②） |
| 委派率 | 0.875（≥0.7 达标；verdict=PASS） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-10 | explore | S0 决策分级归因 | done | 5 Whys 根因+修法方向落盘 | findings.md#决策分级归因 | Research Findings/决策分级归因 | （探索类无检查点，结论已回填 findings） | - / 0 / ☑ |
| 2 | | | S1 Rule 72 条文 | queued | | | | plans/task-v160-decision-grading/subagent-state/1-executor.md | - / 0 / ☐ |
| 3 | | | S2 SKILL 接线 | queued | | | | plans/task-v160-decision-grading/subagent-state/2-executor.md | - / 0 / ☐ |
| 4 | | | S3-S4 引用面触点 | queued | | | | plans/task-v160-decision-grading/subagent-state/3-code-assistant.md | - / 0 / ☐ |
| 5 | | | S5-S6 模板管线触点 | queued | | | | plans/task-v160-decision-grading/subagent-state/5-code-assistant.md | - / 0 / ☐ |
| 6 | | | S7-S8 机器守护 | queued | | | | plans/task-v160-decision-grading/subagent-state/7-executor.md | - / 0 / ☐ |
| 7 | | | S9 全量回归 | queued | | | | plans/task-v160-decision-grading/subagent-state/9-code-runner.md | - / 0 / ☐ |
| 8 | | | S11/S12 双审查 | queued | | | | plans/task-v160-decision-grading/subagent-state/11-code-reviewer.md | - / 0 / ☐ |

## 🔗 Chain 区块交接配置
不适用（chain_mode: single，单 skill 任务，区块删除合规）。

## 📜 Rule 72 条文草案（S1 材料包 — 逐字采用，插入位置=critical-rules.md Rule 70 段之后）

```markdown
## Rule 72（决策分级与用户打断纪律 — task-v160）

> **决策** = 工作流中一切需要用户拍板或知情的输出点。本条全工作流适用；呈报内容规格仍以 Rule 70 为权威源，本条不重复定义。

### 72.1 决策分级表（三级，影响权重轴）
- **A 级（必须询问，禁擅自执行）**：① 推翻/更改用户已确认的计划要素（风格、生成方式、工具链、范围、交付物形态）；② 不可逆破坏性操作（D6 级既有）；③ 对外发布（G3 既有）；④ 语义级目标分叉（G4 既有）。A 级未询问即执行 = 违规（Rule 26 降质处置）。
- **B 级（默认项+自动超时，44 既有）**：有多个合理方案但差异不影响计划已确认要素；按 44.1 默认项+44.3 自动裁决执行。
- **C 级（禁止询问，必须自动消解+登记）**：① 有明确对错的局部修复（错别字/小 bug/格式）；② 执行体职责内的基础质检结果；③ 低区分度路径差异（44.2 既有）。C 级问题上抛用户 = 违规。

### 72.2 A 级变更呈报禁令
A 级变更执行前必须：① 按 Rule 70 四要素呈报（待审项清单+可定位地址+看点+动作）；② 获用户显式确认；③ 登记 Decisions Made。违背既定计划的重大变更未询问即执行 = 最高档违规（回炉+PARTIAL）。

### 72.3 琐碎上抛禁令
C 级问题必须自动修复+登记（Decisions Made `auto:` 行或 progress.md），禁止 AskUserQuestion；单任务非 A 级打断预算 = 0（D6 硬停点除外）。

### 72.4 基础质检硬门
媒体/内容产物基础性质检清单（物理常识错误：肢体数量/文字乱码/构图破损/比例失调等）必须由执行体 QC 工序完成并留证据；质检不合格禁止上抛用户代审，必须回炉重生成或修复后重检。

### 72.5 与既有规则关系
41.2 升级四门槛（G1-G4）与 72.1 A 级对齐；44.1 默认项=72.1 B 级消费；44.2 低区分度=72.1 C 级；47.3 试点先行+50 评级=72.4 消费；70 呈报=72.2 消费；69 判断裁决=72.1 A 级场景的裁决出口。

### 72.6 机制
零新 config 键。机器面 = scripts/selftest-decision-grading.sh（DG 断言：条款锚+触点锚静态守护）。决策分级违规按 Rule 26 降质处置。
```

## 🧩 接线材料包（S2 逐字采用）
- **Rules 全集行（SKILL.md 顶部 references 索引行）**：「Critical Rules 全集 1-69+70」→「Critical Rules 全集 1-72」，并在该行 Rule 70 条目后追加「、72 决策分级与用户打断纪律」；References 表 critical-rules 行「Critical Rules 1-69+70（含…）」同步加「+Rule 72 决策分级与用户打断纪律（task-v160）」。
- **终验交付段**：交付总结 bullet 后补一句「会话内一切决策点（选项/升级/熔断/质检送审）按 Rule 72 分级：A 级必须询问、C 级禁问自动消解」。
- **Critical Rules 索引段**：Rule 70 行后新增一行：
  `- **Rule 72（决策分级与用户打断纪律 — task-v160）**：决策三级=A 必须询问（推翻已确认计划要素/不可逆/对外）/B 默认项+超时/C 禁问自动消解（72.1）；A 级变更呈报禁令（72.2）；琐碎上抛禁令（72.3）；基础质检硬门（72.4）；机器面=selftest-decision-grading.sh，零新 config 键（72.6）（详见 references/critical-rules.md Rule 72）`
- **合规清单新增行（C48 之后）**：
  `| C49 | 决策分级与用户打断（Rule 72）：一切决策点已按三级分类——A 级（推翻已确认计划要素/不可逆/对外）必须询问禁擅自执行、B 级默认项+自动超时、C 级（明确对错局部修复/质检结果）禁问自动消解；基础质检硬门（物理常识错误禁上抛代审）（机器面=selftest-decision-grading.sh 静态断言，决策分级内容人工核查；mini 档豁免） | ☐ |`

## 🧩 触点指针材料包（S3-S6 逐字采用；措辞按宿主文件语体微调，禁弱化分级语义）
- **T1 28.3 选项呈报**：`选项呈报按 Rule 72 分级：A 级（推翻已确认计划要素/不可逆/对外）必须询问；B 级默认项+自动超时；C 级禁问。`
- **T2 41.2/41.3 升级门槛**：`升级四门槛（G1-G4）与 Rule 72.1 A 级对齐：门槛内场景必须询问用户，禁擅自执行。`
- **T3 44.2 低区分度**：`低区分度选项（产出一致仅步骤/耗时差异）按 Rule 72.1 C 级处置：直接裁决+登记，禁止 AskUserQuestion。`
- **T4 44.5 阻塞点**：`阻塞点展示按 Rule 72 分级：A 级阻塞（目标分叉/不可逆）必须询问；C 级阻塞（明确对错的局部问题）自动消解+登记。`
- **T5 送审清单（image-type.md/multiview-ref-type.md）**：`基础质检硬门（Rule 72.4）：物理常识错误（肢体数量/文字乱码/构图破损/比例失调）必须由执行体 QC 完成+留证据；不合格禁上抛代审，回炉重生成或修复后重检。`
- **T6 companion article-batch-publisher.md/article-field-fixer.md**：`熔断/跳过呈报按 Rule 72 分级：A 级（推翻已确认计划要素/不可逆/对外）必须询问；C 级（明确对错的局部问题）禁问自动消解。`

## 🛡️ 守护断言清单（S7/S8 材料包 — DG 断言规格）
- DG-01 critical-rules.md 含 `^## Rule 72` 与 `72.1`-`72.6` 六子条锚（各 ≥1）
- DG-02 条文含三级关键词：A 级必须询问/C 级禁止询问/基础质检硬门 各 ≥1
- DG-03 条文内禁硬编码行号锚（`:\d+` 引用形态=FAIL）
- DG-04 SKILL.md 接线锚 ≥4（Rules 全集行/References 表/终验段/合规清单 C49）
- DG-05 触点锚：6 文件清单（critical-rules.md 28.3/41.2/41.3/44.2/44.5 段、image-type.md、multiview-ref-type.md、article-batch-publisher.md、article-field-fixer.md）逐一 grep "Rule 72" 命中（数组遍历断言）
- DG-06 registry.tsv 含 selftest-decision-grading.sh 行；config.json 零新键（grep 新键名=0）
- DG-07..12 按触点分组锚（引用面/模板面/管线面各自断言）
