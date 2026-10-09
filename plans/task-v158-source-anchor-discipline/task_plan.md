---
template_type: general
plan_tier: standard
---

# Task Plan: task-v158 把「无源不写·空段占位·写必带锚」制度化进 task-planner 技能层（Rule 71）
<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「按照以下方向修正skill」<sub>（[手段]）</sub>
- **R2**: 「【目标】对 <目标文件绝对路径> 做逐句溯源审计（无来源虚构内容专项）。【审计口径】把文件切成「事实单元」（每条含具体事实的句子/单元格）；逐单元三态判定：有源=附 file:line/URL/命令输出原文/本会话工具调用记录四者之一；无源含事实=无来源却含时间/数字/人名/事件/照片描述等=违规（含「推测的具体化」）；显式占位（「（本任务暂无…）」「未验证」）=合法。【输出】单元位置|事实摘要|三态判定|源锚或「无」|处置建议 + 总计行。【铁律】只读目标文件；无源=删除或降级为占位，禁止「补一个源」蒙混；不确定从严判无源。」<sub>（[目标]）</sub>
- **R3**: 「1. 这段每个具体事实我在本会话有第一手来源吗（工具调用记录/Read 过的文件/子代理返回）？2. 我是否在填模板空段？——空段一律写「（本任务暂无…）」或「未验证」，禁止自由发挥。3. 读者能按我写的锚点复核吗（file:line 可定位/命令可复现）？4. 会话此刻中断，明天重启，这段还能从磁盘证据重建吗？5. 我写的是「我记得/我读到过」还是「我觉得应该有」？——后者一个字不许落盘。最小版：无源不写，空段占位，写必带锚。」<sub>（[目标]）</sub>
- **R4**: 「【防幻觉契约】你的全部事实性输出必须带来源锚（file:line/命令原文/URL/已读区段行号）之一；禁止无来源的具体化（推测写成事实、替调用方补细节、填模板空段）；信息缺失一律显式写「未验证」或「暂无」并说明缺什么；结论区必须「事实+锚点」成对，无锚点行=违规退回；禁止以「合理推断」省略锚点。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1..VC-7 | 全部 VC 通过（手段=机制三载体+守护落盘） |
| R2 | VC-1, VC-6 | Rule 71 七子条在位（grep 子条锚全命中，含三态判定四来源枚举/审计表五列/补源禁令）；溯源 SOP 可派发（fix-prompts 素材锚活） |
| R3 | VC-1, VC-3 | 71.2 五问+口诀在 critical-rules.md 与 findings/progress 模板注释（grep 锚） |
| R4 | VC-2 | subagent_dispatch.md §10 契约段在位（段头+契约行+五问回溯三锚 grep） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则载体（纪律总纲） | v153 仅沉淀 fix-prompts 素材+记忆，技能层无强制条款 → 下个会话仍可无源落盘 | critical-rules.md 追加 Rule 71 七子条（71.1 三态/71.2 五问/71.3 空段/71.4 审计/71.5 契约/71.6 关系/71.7 机制） | VC-1 |
| 派发载体（传播面） | 子代理任务书无防幻觉契约 → 传播面零防线 | dispatch 模板 §10 契约段（禁删） | VC-2 |
| 模板载体（事故温床直填） | findings Visual/Browser Findings / progress 空表无占位指引（v153 记忆称"已强化"但仓内模板实无，见 findings §4） | findings/progress 模板注释追加占位合法形态 | VC-3 |
| 守护载体（防腐） | 无机器断言 → 条款被后续任务静默删除无人知 | 新 selftest 12 断言 + registry 登记 | VC-6 |
| 级联一致性（计数防腐） | SKILL/自检/仓根 19 处计数仍 1-69 → 新 Rule 不在集合=幽灵条款 | 1-69→1-71 逐文件级联+grep=0 验证 | VC-5 |
| 交付簿记 | 无回归证据/无变更记录 → 无法审计"没改坏" | 基线对照跑批+CHANGELOG+delivery-summary | VC-4, VC-7 |

<!-- plan_tier: standard -->
## Goal
把 v153 事故的修复提示词组（fix-prompts A/B/C）制度化为 task-planner 技能层 Rule 71「无源不写·空段占位·写必带锚」，三载体（规则条/派发契约/模板占位）+机器守护落盘，全量回归 FAIL=0。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（交付=规则条款/模板注释/静态守护脚本，无业务代码逻辑；验证=selftest 机械断言+alignment-review 对齐审查兜底，Rule 37 通用组画像） |
| `session_id` | `sess1cefd1cf1c2b4e4c8e1739e777fce697`（ZCode hook 侧 sid） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v158-source-anchor-discipline` |
| `scope_files` | 见「⚠️ 执行范围限制」表（19 处级联目标以 grep 实锚为准） |
| `interaction_mode` | `silent`（用户非实时在场，两次「继续」已授权自主推进；静默决策清单随 delivery 呈报） |
| `对齐审查` | `alignment-review`（Rule 42.6 收尾消费：42.2 四级检测命中用户级 alignment-review 技能） |
| `自动超时默认项` | silent 模式无 2+ 选项询问点；执行期若现低区分度决策按 41.3 直接裁决并登记 Decisions（44.3） |
| `new_rule` | `71`（已 rule-reserve：`rule 71 reserved by task-v158-source-anchor-discipline`，2026-10-10） |
| `质量审查工具` | `alignment-review`（用户级技能，~/.zcode/skills/alignment-review/SKILL.md 在位）+ 内置 selftest 跑批兜底 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 71 七子条完整在位且要素齐（71.1 四来源枚举+从严/71.2 五问+口诀/71.3 占位合法/71.4 审计表五列+补源禁令/71.5 契约/71.6 关系/71.7 零新键+边界披露） | grep 子条锚逐条命中 | `grep -n "### 71\|71\.[1-7]" skills/task-planner/references/critical-rules.md` |
| VC-2 | dispatch 模板 §10 防幻觉契约段在位（段头/契约行/五问回溯三锚） | grep 三锚 | `grep -n "## 10. 防幻觉契约\|无锚点行=违规退回\|写入前五问" skills/task-planner/templates/subagent_dispatch.md` |
| VC-3 | findings/progress 模板各含 2 处 Rule 71 占位注释锚 | grep 四锚 | `grep -n "Rule 71" skills/task-planner/templates/findings.md skills/task-planner/templates/progress.md` |
| VC-4 | 全量 selftest 回归 FAIL=0（对照基线 66/66） | 跑批对照 | `for s in skills/task-planner/scripts/selftest-*.sh; do bash $s || echo FAIL; done` vs baseline-selftest.log |
| VC-5 | 计数级联完整：SKILL.md 详见行+References 行=1-71、C48 行在位；skills/ 内 grep "1-69"=0（级联目标文件）；仓根 3 处=1-71 | grep 计数 | `grep -rn "1-69" skills/ *.md \| grep -v CHANGELOG`（预期 0 命中）+ `grep -c "1-71" skills/task-planner/SKILL.md` |
| VC-6 | 新 selftest-source-anchor-discipline.sh PASS + registry 登记行在位 + 零新 config 键负断言过 | 运行脚本 | `bash skills/task-planner/scripts/selftest-source-anchor-discipline.sh` exit 0 |
| VC-7 | CHANGELOG Rule 71 条目 + delivery-summary 五要素 + 计划三文件终态（Phase/Goal 单元表/[goal:Gn] 证据行）齐 | 文件存在+锚检查 | `plans/task-v158-source-anchor-discipline/delivery-summary.md` + `grep "\[goal:" progress.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R2 / R3 / R4 |
| **裁决** | 终验时填（solved / partial / not-solved） |
| **解决证据锚** | 终验时填（VC-1/2/3 证据行） |
| **未解决面+原因** | 终验时填（如有） |
| **已排除路径** | 终验时填（如有） |
| **下一步建议** | 终验时填（如有） |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 基线复验 | 独立子代理复验级联面/编号/部署位基线并回填 findings | findings.md §3/§5 有 explore 复验行+锚 | S1/Phase 1 | complete |
| G2 | 规则层 | critical-rules.md 追加 Rule 71 七子条+SKILL.md 四处 | grep 71.1-71.7 锚全命中+1-71×2+C48 | S2,S3/Phase 2 | complete |
| G3 | 模板层 | dispatch §10 契约段+findings/progress 占位注释 | grep 三锚+四锚 | S4,S5/Phase 3 | complete |
| G4 | 守护层 | 新 selftest 12 断言+registry+19 处级联 | selftest exit 0+grep 1-69=0 | S9-S14/Phase 4 | pending |
| G5 | 回归 | 全量 selftest FAIL=0 对照基线 | 跑批 log 66/66 PASS | S8/Phase 5 | pending |
| G6 | 交付 | CHANGELOG+delivery-summary+合并回主仓+簿记 | delivery-summary 在位+merge commit | Phase 6 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则 | skills/task-planner/references/critical-rules.md（文末追加） | 改既有 Rule 条款任何行 |
| 登记 | skills/task-planner/SKILL.md（详见行/bullet/C48/References 四处） | 其他 SKILL 行 |
| 模板 | skills/task-planner/templates/subagent_dispatch.md、findings.md、progress.md（注释追加） | 其他模板文件 |
| 守护 | skills/task-planner/scripts/selftest-source-anchor-discipline.sh（新建）、selftest-registry.tsv（+1 行） | 既有 selftest 逻辑行 |
| 级联 | grep "1-69" 命中的 skills/ 文件与仓根 CLAUDE.md、README_zh.md（仅计数标签数值） | 计数标签外的任何内容 |
| 簿记 | CHANGELOG.md（[Unreleased] 条目）、plans/task-v158-source-anchor-discipline/**、主仓 plans/task-v150-split-skill-integration/task_plan.md（仅 Decisions 簿记行+重锁） | 其他 plans/ 目录（v152/v154/v155/v156/v157 在途禁触碰） |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | fix-prompts A/B/C 素材 | plans/task-v153-parallel-scheduling/fix-prompts.md（worktree 内同路径） | 必读 | ☑ |
| 项目内部文档 | Rule 71 实施稿 | plans/task-v158-source-anchor-discipline/design-rule71.md | 必读 | ☑ |
| 项目内部文档 | 仓内 Rule 追加先例（Rule 68/69 形态） | skills/task-planner/references/critical-rules.md:853-876 与 SKILL.md:345-346 | 必读 | ☑ |
| 项目内部文档 | 级联先例（v152/v154 计数演进） | plans/INDEX.md 各行 scope 列 | 参考 | ☑ |
| 用户宪法 | §三 反造谣铁律（本 Rule 的总纲） | /home/terry/.zcode/AGENTS.md §三 | 必读 | ☑ |
| 跨会话记忆 | hallucination-placeholder-discipline-20261009 | ~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/ | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: task-planner 技能层对「无来源虚构内容（幻觉补位）」无执行机制——v153 只沉淀了提示词素材与记忆，规则/派发契约/模板三层缺位，同类事故（模板空段被无源内容填充）无复发防线。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（机制三载体+守护落盘=可交付的防幻觉纪律层）
- [x] 核心问题不解决，其他工作都白费吗？（素材与记忆会被新会话遗忘，无强制层=无防线）
- [x] 核心问题的解决方法是清晰的、可执行的？（Rule 71 七子条+三载体+12 断言守护，design-rule71.md 已定稿）

## 🔍 证据面清单（Rule 58.1）
n/a（纯执行类——机制建设任务，产出=规则条款/模板/脚本，非调研/归因/评估类结论；对标面=仓内 Rule 68/69 追加先例已在「必要知识储备」表消费）

## Current Phase
Phase 4

## Next Step
派 S11（code-assistant haiku-1）级联 requirement-coverage.sh+tool-selection.sh 计数 1-69→1-71

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(haiku-1) | 独立上下文复验基线（Rule 33.3 验证独立性；主进程既有结论不作有效验收） |
| Phase 2 | Agent 子代理 code-assistant(haiku-1)×2 | 规则条款/登记行落盘，单文件小改 |
| Phase 3 | Agent 子代理 code-assistant(haiku-1)×2 | 模板注释追加 |
| Phase 4 | Agent 子代理 code-assistant(haiku-1)×2 | 守护脚本+级联 sed |
| Phase 5 | 机械守卫脚本（selftest 跑批 run_in_background）+ Agent 子代理 code-runner-agent(haiku-1) | 66 脚本跑批为长耗时命令（§十二已固化：Bash run_in_background/code-runner） |
| Phase 6 | 主进程 | git 编排+簿记（Rule 25.3 白名单①②） |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度；S2/S3 共写 SKILL.md（输入依赖）→ 串行；S4/S5 与 S2/S3 无文件交集 → 可声明并行组（Phase 2∥Phase 3 执行），组内异构已满足（同为 haiku-1 时按 agent 类型同档——68.3 禁整组全「继承」，S-unit 执行体列已逐行具体化）；S9-S14 依赖 S2-S5 产物 → 串行后置。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定；技能层不代调。

## Phases

### Phase 1: Requirements & Discovery（基线复验）
- [x] Understand user intent（R1-R4 录入+素材定位=fix-prompts A/B/C）
- [x] Identify constraints and requirements（保护区/worktree/零新键/编号避让）
- [x] Document findings in findings.md（§1-§5 已落盘）
- [x] 知识储备必读项已确认可获取（上表 ☑）
- **V-N:** VC-1（复验后 71.1-71.7 要素清单冻结进 design）, VC-5（级联面实锚清单）
- **Status:** complete
- **Executor:** explore（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 独立复验：级联 1-69 分布/Rule 71 编号 free/C48 占用/部署位 ~/.zcode 现状 | explore(haiku-1) | plans/task-v158-…/findings.md §2-§5（既有快照+锚，子代理逐条复核并回填差异行） | findings.md 回填"复验"行：四处结论与 grep/命令输出一致或差异已标注 | 15min | 1f/30l/15min | 无 | - | done |

### Phase 2: 规则层实施
- [x] critical-rules.md 文末追加 Rule 71 七子条（design §一原文）
- [x] SKILL.md 四处（详见行 1-69→1-71+Rule 71 bullet+C48 行+References 行）
- **V-N:** VC-1, VC-5
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S2 | critical-rules.md 文末追加 Rule 71 七子条（design §一 逐字） | code-assistant(haiku-1) | plans/task-v158-source-anchor-discipline/design-rule71.md §一（Rule 71 全文 ~95 行） | grep 子条锚（### 71 及 71.1 至 71.7）全命中；git diff 零删除既有行 | 15min | 1f/95l/15min | 无 | S1 | done |
| S3 | SKILL.md 四处改动（详见行计数+Rule 71 bullet+C48 行+References 行，design §二） | code-assistant(haiku-1) | plans/task-v158-source-anchor-discipline/design-rule71.md §二（4 处精确稿） | grep 计数标签 1-71 命中 2 处以上；C48 行与 bullet 行均在；diff 仅 4 处 | 15min | 1f/12l/15min | 无 | S2 | done |

### Phase 3: 模板层实施
- [x] subagent_dispatch.md §9 后插 §10 防幻觉契约段（design §三原文）
- [x] findings.md/progress.md 模板注释追加（design §四 4 处锚）
- **V-N:** VC-2, VC-3
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S4 | dispatch 模板插 §10 防幻觉契约段（不打乱九字段编号） | code-assistant(haiku-1) | plans/task-v158-source-anchor-discipline/design-rule71.md §三（段全文+插入位） | grep 三锚命中：段头编号 10 防幻觉契约、无锚点行违规退回、写入前五问 | 10min | 1f/12l/10min | 无 | S1 | done |
| S5 | findings/progress 模板各加 2 处 Rule 71 占位注释（design §四） | code-assistant(haiku-1) | plans/task-v158-source-anchor-discipline/design-rule71.md §四（4 锚精确稿） | 两模板 grep Rule 71 共 4 锚以上 | 10min | 2f/6l/10min | 无 | S1 | done |

### Phase 4: 守护层实施+冒烟
- [ ] 新建 selftest-source-anchor-discipline.sh（design §五 12 断言）+ registry.tsv 登记
- [ ] 19 处 1-69→1-71 级联（grep 实锚逐文件 sed + git diff 逐 hunk 目审）
- [ ] 新 selftest 冒烟 PASS
- **V-N:** VC-6, VC-5
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | 新建 selftest 脚本（SA-01..12 断言，≤95 行紧凑实现） | code-assistant(haiku-1) | plans/task-v158-source-anchor-discipline/design-rule71.md §五（断言清单） | bash selftest-source-anchor-discipline.sh 输出 exit 0（脚本先可容缺 registry 行再补） | 15min | 1f/95l/15min | 无 | S2,S4,S5 | pending |
| S10 | registry.tsv 登记+worktree 幂等重 reserve 71 | code-assistant(haiku-1) | plans/task-v158-source-anchor-discipline/design-rule71.md §五 SA-11（登记行格式，参考既有行） | registry.tsv 新行在；rule-reserve check 71 输出含本任务 | 5min | 2f/3l/5min | 无 | S9 | done |
| S11 | 级联 1-69→1-71：requirement-coverage.sh（4 处）+tool-selection.sh（3 处） | code-assistant(haiku-1) | plans/task-v158-source-anchor-discipline/design-rule71.md §六（grep 实锚法） | 两文件 grep 1-69 命中 0；diff 仅计数标签行 | 10min | 2f/7l/10min | 无 | S2 | done |
| S12 | 级联：self-resolution.sh（3 处）+lane-advancement.sh（3 处） | code-assistant(haiku-1) | 同 §六 | 同上（两文件 1-69 清零） | 10min | 2f/6l/10min | 无 | S2 | done |
| S13 | 级联：research-first.sh（2 处）+仓根 CLAUDE.md 33 行（1-68→1-71） | code-assistant(haiku-1) | 同 §六 | 同上（两文件清零；CLAUDE 行为 1-68 基线） | 10min | 2f/3l/10min | 无 | S2 | done |
| S14 | 级联：README_zh.md 136 与 229 行（1-68→1-71） | code-assistant(haiku-1) | 同 §六 | 该两行 1-68 清零且为 1-71 | 5min | 1f/2l/5min | 无 | S2 | pending |

### Phase 5: Testing & Verification
- [ ] 全量 selftest 跑批（66+1 脚本）对照基线 FAIL=0
- [ ] VC-1..VC-6 逐条复验并记录 progress.md
- **V-N:** VC-4, VC-6
- **Status:** pending
- **Executor:** code-runner-agent（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S8 | 全量 selftest 跑批输出 PASS/FAIL 逐行清单（禁自报汇总） | code-runner-agent(haiku-1) | plans/task-v158-source-anchor-discipline/baseline-selftest.log（基线 66/66） | 回传逐行 rc 清单：新增脚本 PASS 且原 66 脚本全 PASS | 15min | 1f/70l/15min | 无 | S9,S10,S11,S12,S13,S14 | pending |

### Phase 6: Delivery
- [ ] CHANGELOG [Unreleased] 追加 Rule 71 条目
- [ ] delivery-summary.md 五要素落盘
- [ ] VC 终验 + 58.5 裁决 + 委派统计
- [ ] 合并回主仓（--no-ff）+ 部署位对账 + 清理 worktree
- **V-N:** VC-7, VC-4
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号②：v152/v154/v155 三个在途 worktree 均可能改 critical-rules.md/SKILL.md/selftest 钉值；v154 已于本任务执行中合入 master 演进 1-68→1-69 实证冲突面活跃） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v158-source-anchor-discipline` |
| `branch` | `wt/task-v158-source-anchor-discipline` |
| `merge_back` | `pending`（合并策略=并集解，v149/v150 先例；合并前 rebase 最新 master 并重跑基线） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | Rule 71 与既有 Rule 26/43.1/63 语义重叠或冲突 | 8 | 6 | 4 | 192 | 71.6 关系条显式声明边界 + Phase 6 alignment-review 对齐审查兜底（42.6） |
| Phase 4 | 级联漏改/错改（并行基线漂移） | 8 | 6 | 4 | 192 | S11-S14 验收 grep 1-69=0 硬门 + S9 selftest 计数断言 + diff 逐 hunk 目审 |
| Phase 5 | 并行会话再合入致回归红 | 7 | 8 | 5 | 280 | 合并前 rebase master 重跑基线；红项按 master 对照分类（基线漂移 vs 本任务引入），22.3 ①-⑤ |
| Phase 6 | 合并冲突（v152/v155 在途） | 6 | 7 | 4 | 168 | 并集解（v149/v150 先例）；冲突超 10 hunk → STOP 呈报用户 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-10 05:08 | S1 done；Phase 1 complete |
| Phase 2 | ☑ | 2026-10-10 05:20 | S2/S3 done，Phase 2 complete |
| Phase 3 | ☑ | 2026-10-10 05:36 | S4/S5 done，Phase 3 complete |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |
| Phase 6 | ☐ |  |  |

## Key Questions
1. Rule 71 与既有 Rule 26/43.1/51/54/63 的语义边界？→ 71.6 关系条（总纲→禁令→细则三层，不替代不回退）
2. 三态判定能否机检？→ 71.7 机器边界如实披露（语义面不可静态机检，守护只锚载体存在性）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 新 Rule 71 而非扩展现有 Rule | 现有规则覆盖「禁编造」总纲但无「写入前自检+空段占位+审计 SOP」执行细则；71.6 显式关系防重叠 |
| 三载体联动（规则条+派发契约+模板注释） | 规则=总纲（人读）、契约=传播面（子代理必读）、模板注释=事故温床直填点（v153 事故即 Visual/Browser Findings 空段） |
| 合规编号 C48（非 C47） | C47 已被 v154 Rule 69 占用（5280cb3 合入实证）；编号预留台账 71 free |
| 不建新 agent（YAGNI） | 审计派发已可由通用体承载（fix-prompts.md:29 八字段形态）；agent 化登记为 future candidate |
| interaction_mode=silent | 用户非实时在场，连续「继续」即授权；静默决策随 delivery 呈报 |
| worktree 从 master 创建后必须与主仓 HEAD 对账 | 本任务实证：初建落 f6d6158，master 随即前进至 5280cb3（v154 合入），已 merge 同步 |
| v150 重锁（Phase 6 簿记） | attest 后两个簿记提交（02c61d7/1a87387）未重锁致 PLAN TAMPERED 告警；按 Rule 51.7 登记+重锁消音 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （本任务暂无错误——未验证项随执行期登记） | 1 | - | → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-10 05:08 | 主进程自查：目标=Rule 71 制度化三载体+守护；当前步=Phase 1 基线复验 complete；scope=worktree 内 6 类目标文件+簿记 | VC-1..7 | ALIGNED（无漂移；Phase 1→2 换道前留痕，Rule 64.2） |
| 2026-10-10 05:20 | 主进程自查：Phase 2 产出=critical-rules.md:888-902+SKILL.md 四处；与 Goal/VC-1/VC-5 对照一致；无范围外文件 | VC-1, VC-5 | ALIGNED（S2/S3 双 verify_done；Phase 2→3 换道前留痕） |
| 2026-10-10 05:36 | 主进程自查：Phase 3 产出=dispatch:88-91+findings:6,41+progress:6；与 VC-2/VC-3 对照一致；无范围外文件 | VC-2, VC-3 | ALIGNED（S4/S5 双 verify_done；Phase 3→4 换道前留痕） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 5 / 6 |
| 主进程直做 Phase 清单 | Phase 6（例外理由:① git 编排+② 簿记——Rule 25.3 白名单） |
| 委派率 | 0.83（≥ delegation_rate_floor 0.7） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-10 04:55 | explore(haiku-1) | S1 基线独立复验（级联/编号/C48/插入位 4 项） | done | 4/4 PASS；仓根 3 处仍 1-68（主进程快照有误已修正 design §六）；worktree 台账无 71 行（S10 幂等重 reserve 处置） | subagent-state/01-explore-baseline-reverify.md 汇总段 | findings.md #### [sub:01-explore] 段 | 同左 | - / 0 / ☑ |
| 2 | 2026-10-10 05:12 | code-assistant(haiku-1) | S2 critical-rules.md 追加 Rule 71 七子条 | done | 4/4 PASS：:888 标题+71.1-71.7 全在；diff +16/-0 纯追加（69.6 后）；轻微同义措辞偏差语义无漂移 | critical-rules.md:888-902 | findings.md（S2 未写 findings 段，返回 none，结论以 checkpoint 为准） | subagent-state/02-code-assistant-rule71.md | - / 0 / ☑ |
| 3 | 2026-10-10 05:18 | code-assistant(haiku-1) | S3 SKILL.md 四处（详见行/bullet/C48/References） | done | 5/5 PASS：:225 C48/:287 详见行 1-71/:347 bullet/:370 References 1-71（原 1-66 实锚纠偏已披露）；1-69 残留=0；C47/68/69 零改动 | SKILL.md:225,287,347,370 | findings.md #### [sub:03-code] 段 | subagent-state/03-code-assistant-skill-md.md | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP（初判：本次为单 Rule 制度化，与 rule-enhancement 类 variant 高度同构，倾向不沉淀新 variant 而消费既有形态——终验正式登记）
