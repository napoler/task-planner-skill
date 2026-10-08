---
template_type: rule-enhancement
interaction_mode: silent
parallel_groups: [impl-wave, fix-wave]
code_review: required
---

# Task Plan: task-v150 — 拆分能力增强与池内技能集成（split-pattern-library + Rule 21.6）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「继续优化当前技能对任务的的拆分能力」<sub>（[目标]）</sub>
- **R2**: 「或者直接集成已有的skill 当前有很多现成的skill 需要补充」<sub>（[手段]）</sub>
- **R3**: 「记住将任务拆分细致更加利于解决问题」<sub>（[约束/原则]）</sub>
- **R4**: 「还有就是拆分非」<sub>（消息发送截断，语义不完整；按 R1-R3 主诉求推进，交付时向用户呈报请求澄清）</sub>
- **R5**: 「还有发现新的错误 连最基本的理解都存在缺陷 完全无法正确的认知 必须在执行路径和方法论上彻底规避这种风险」「你这里被错误的理解为 实验犬是一个擅长做实验的犬 这是理解偏差 导致定位出错」「说明无论是剧本创作还是其他都存在严重的幻觉 需要从执行路径上进行要求纠正」<sub>（[目标]——B 类扩展指令 2026-10-09：术语语义幻觉需执行路径级根治；判例=「实验犬」（实际=实验室替代小白鼠做实验的犬，如比格犬）被误读为「擅长做实验的犬」致定位错误）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 拆分模式库文件在位且 Rule 21.6 增量落地（grep 锚可验证），拆分判定从纯数值上限扩展为「数值硬门+模式库判据」双层 |
| R2 | VC-1, VC-3 | ≥8 个池内技能的拆分实践被吸收入库（每模式含来源技能锚）；SKILL.md/派发模板接线锚 grep ≥4 处 |
| R3 | VC-2, VC-4 | Rule 21.6 含边界三判据+步级细化条款；selftest-split-pattern-library.sh 全 PASS |
| R4 | （截断待澄清） | 交付报告呈报截断事实，不含未授权推测范围 |
| R5 | VC-7 | 模式库 P11「术语语义锚定与理解复述」（含实验犬误读反例）+ Rule 21.6.6 术语锚定子条落地 + selftest 断言同步（=11）全 PASS——术语理解回写成为计划期/派发路径的强制动作 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 计划期拆分决策 | 拆分判定只有数值上限（21.1b ≤2f/100l/15min）与三值硬门（59.1），缺「怎么拆得好」的定性判据与已验证模式参考 | Phase 3 模式库（边界三判据+bite-sized+No-Placeholder+伴飞映射）+ Rule 21.6 消费纪律 | VC-1/VC-2 |
| 技能资产复用 | 池内 8+ 个拆分相关技能（writing-plans 等）的已验证实践未被 task-planner 消费，各池技能知识孤岛 | Phase 3 模式库逐条吸收+来源锚；伴飞映射表接入 59.3 技能扫描 | VC-1 |
| 派发质量 | 任务书可能含占位符/模糊描述，低档模型被迫追问或臆测 | Phase 3 S5 派发模板 No-Placeholder 契约行 | VC-3 |
| 守卫与回归 | 新载体无机器守护=纯文档约定易腐化 | Phase 4 selftest-split-pattern-library.sh 静态断言+全量回归 | VC-4 |
| 交付生效 | 修复只落仓未部署=运行位仍旧版 | Phase 6 merge back + 部署位 IDENTICAL 对账 | VC-6 |

<!-- plan_tier: standard -->
## Goal

将池内 8 个高价值技能（writing-plans / subagent-driven-development / dispatching-parallel-agents / brainstorming / sub-agent-protocol / task-drift-guard / skill-handoff / skill-skill-tool）中「任务拆分」相关已验证实践集成为 `references/split-pattern-library.md`（拆分模式库），以 Rule 21.6（纯增量子条）接入计划期拆分决策链，使 S-unit 拆分从纯数值上限升级为「数值硬门 + 模式库定性判据」双层；回归无新增 FAIL，部署位同步 IDENTICAL。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `865e3f21-1892-4596-ac92-941eea25ee63` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration` |
| `scope_files` | `skills/task-planner/references/split-pattern-library.md`(新), `skills/task-planner/references/critical-rules.md`(追加 21.6), `skills/task-planner/SKILL.md`(接线), `skills/task-planner/templates/subagent_dispatch.md`(+契约行), `skills/task-planner/scripts/selftest-split-pattern-library.sh`(新), `CHANGELOG.md`(条目) |
| `interaction_mode` | `silent`（判例=v149 前例；自主会话场景，静默决策清单随交付呈报） |
| `对齐审查` | Phase 5 对全部产出与更新文档跑 alignment-review（42.6.2 标准收尾流程）；文档追加前版本一致性已由设计契约冻结锚点承载 |
| `自动超时默认项` | 本任务 silent 模式无 2+ 选项询问点；CR 修复策略等低区分度决策按 41.3 直接裁决并登记 Decisions Made |
| `new_rule` | （留空——本任务扩展 Rule 21 子条 21.6，不新增顶层 Rule；Rule 65 已被 task-v149 预留，避让撞号） |
| `质量审查工具` | 检测结论：代码审查=code-reviewer agent（环境 agents 在位）；对齐审查=alignment-review 技能（review-library 池 11 成员，`~/.zcode/skills/alignment-review/SKILL.md` 在位）；无需补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | `references/split-pattern-library.md` 在 master 落地：≥8 个源技能实践吸收（每模式含来源技能名+原技能小节锚+判据+反例+消费时机），含伴飞映射表（≥6 行「任务画像→伴飞技能绝对路径」） | grep 计数 + Read 抽查 | `grep -c '^### P' split-pattern-library.md ≥ 8`；伴飞表行数 |
| VC-2 | Rule 21.6 增量落地 critical-rules.md（21.6.1-21.6.5 五子条），且 21.1-21.5 既有文本零改动（纯追加） | git diff master...worktree 该文件仅含新增行；grep 21.6 命中 | `git diff 21f7e6b..HEAD -- skills/task-planner/references/critical-rules.md` 无删除行 |
| VC-3 | SKILL.md 接线 ≥3 锚（References 表行 / 委派检查点 2.5 或 Rule 21 摘要对照 / C43 补句）+ subagent_dispatch.md 含 No-Placeholder 契约行 | grep 锚点 | `grep -c 'split-pattern-library' SKILL.md ≥ 3`；dispatch 模板 grep 命中 |
| VC-4 | `selftest-split-pattern-library.sh` 全 PASS + 全量回归相对 Phase 1 基线零新增 FAIL | 运行输出 | worktree 内 `bash scripts/selftest-split-pattern-library.sh` exit 0；全量对比表 |
| VC-5 | Code Review APPROVED + alignment-review 通过（或修复闭环后复验通过） | 审查结论 | Handoff 登记行 + 修复 commit |
| VC-6 | master 合并完成 + 部署位同步 IDENTICAL（smart-merge-back --deploy 对账输出） | git log + 部署对账 | `merge_back=merged(<commit>)`；对账输出 diff=0 |
| VC-7 | 术语语义锚定机制落地：库 P11（含实验犬误读反例+63.2 检索联动）+ Rule 21.6.6 子条 + selftest 断言同步（模式数=11）全 PASS | grep + selftest 输出 | `grep -c '^### P'`=11；`grep '21\.6\.6'` 命中；selftest Total FAIL=0 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验必填）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1（优化拆分能力）+ R5（术语语义幻觉根治） |
| **裁决** | `solved` |
| **解决证据锚** | master 998d6e4：库 126 行（P1-P11+伴飞表）/critical-rules 21.6.1-21.6.6/SKILL 四锚/dispatch 契约/selftest 13 断言全 PASS；拆分判定=数值硬门+定性判据双层；R5=21.6.6 术语回写+溯源锚为派发前置（verification.md 🎯 区块） |
| **未解决面+原因** | R4 截断句待用户澄清（不属未解决面）；行为面冒烟待新会话（frontmatter 行为需新会话加载生效） |
| **已排除路径** | 新开顶层 Rule（Rule 65 被 v149 预留）；运行时直调池内技能单轨方案（改双轨） |
| **下一步建议** | 新会话以真实任务验证 21.6.1 模式库消费与 21.6.6 术语回写行为面 |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件（worktree 内相对路径） | 禁止 |
|-------|------------|------|
| 技能文档 | `skills/task-planner/references/split-pattern-library.md`（新建）、`skills/task-planner/references/critical-rules.md`（仅追加 21.6，禁改 21.1-21.5 与其他 Rule）、`skills/task-planner/SKILL.md`（仅计划声明锚点，≤4 处） | 其他 references/*.md、其他 Rule 区段 |
| 模板 | `skills/task-planner/templates/subagent_dispatch.md`（仅追加 1 契约行） | 其他模板文件 |
| 脚本 | `skills/task-planner/scripts/selftest-split-pattern-library.sh`（新建） | 其他 scripts/*.sh（回归只读运行） |
| 仓级文档 | `CHANGELOG.md`（追加 1 条目） | README 等其他文档 |
| 簿记 | `plans/task-v150-split-skill-integration/**`（主仓，主进程单写者） | 其他 plans/ 目录 |
| 部署 | 由 `smart-merge-back.sh --deploy` 机械同步（对账输出留证），不手工编辑部署位 | 手改 `~/.zcode/skills/**` 等部署位文件 |

**执行前自我检查:** 文件在列表中？修改必要？用户要求？——全部 Yes 才执行；其他 worktree（含 task-v149）一律禁碰。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 池内源技能 | writing-plans | `/home/terry/.zcode/skills/writing-plans/SKILL.md`（176 行） | 必读 | ☑（Explore 已盘点） |
| 池内源技能 | subagent-driven-development | `/home/terry/.agents/skills/subagent-driven-development/SKILL.md`（419 行） | 必读 | ☑ |
| 池内源技能 | dispatching-parallel-agents | `/home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md`（186 行） | 必读 | ☑ |
| 池内源技能 | brainstorming | `/home/terry/.zcode/skills/brainstorming/SKILL.md`（161 行） | 必读 | ☑ |
| 池内源技能 | sub-agent-protocol | `/home/terry/.zcode/skills/sub-agent-protocol/SKILL.md`（204 行） | 必读 | ☑ |
| 池内源技能 | task-drift-guard / skill-handoff / skill-skill-tool | 各自 SKILL.md（86/116/125 行） | 参考 | ☑ |
| 本体载体 | critical-rules.md Rule 21 区段 | `skills/task-planner/references/critical-rules.md:142-159`（master 21f7e6b） | 必读 | ☑（已 Read） |
| 机器面参照 | selftest 先例 + check-plan-dispatch 粒度校验 | `scripts/selftest-media-dispatch.sh` 等；`scripts/check-plan-dispatch.sh:274-301` | 参考 | ☑ |
| 对齐审查 | alignment-review 技能 | `~/.zcode/skills/alignment-review/SKILL.md` | 参考 | ☑ |

## ⚠️ 核心问题定义（强制）

**核心问题**: task-planner 的拆分判定只有数值上限与三值硬门（管"拆得够不够小"），缺"拆得对不对"的定性判据与已验证模式库；同时池内 8+ 拆分相关技能的实践未被消费——拆分能力提升有现成资产可集成，无需从零发明。

**核心问题判断**:
- [x] 核心问题解决后，拆分能力（R1）可交付：模式库+21.6 接入计划期决策链
- [x] 核心问题不解决，单纯调数值上限无法提升拆分质量（R3 诉求落空）
- [x] 解决方法清晰可执行：吸收式集成（模式库）+ 纯增量接线（21.6）+ 机器守卫（selftest）

## 🔍 证据面清单（Rule 58.1）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | task-planner 既有拆分机制（21.1b/59.1/analyze-splits.sh） | Explore 仓内盘点（本会话） | findings.md §R1 自身面 | ☑ |
| ② 对标样本（58.2 强制） | 池内 8 技能 SKILL.md 原文（writing-plans 等，绝对路径见知识储备表） | Explore 全文盘点（本会话，288k tokens 子代理） | findings.md §R2 对标面（逐技能机制清单） | ☑ |
| ③ 外部约束 | 编号预留账本（59-65 已占）/ v149 在飞 worktree / Rule 36 保护区纪律 | rule-reservations.jsonl + check-conflicts 输出 | findings.md §约束面 | ☑ |

## Current Phase

Phase 6

## Next Step

VC 逐条复验 → smart-merge-back --deploy 合并部署 → 簿记+delivery-summary 交付

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（selftest 基线跑批）+ 主进程簿记 | 基线输出重定向文件，主进程只读摘要（③ 白名单） |
| Phase 2 | 主进程 git 编排（worktree 创建①）+ 规划职责（设计契约冻结） | 隔离编排与设计决策是主进程本职 |
| Phase 3 | Agent 子代理 executor(sonnet-1)×4 [parallel-group:impl-wave] + 串行 S2 | 设计契约冻结后四 S-unit 过独立性四问（文件集互斥/无输入依赖） |
| Phase 4 | Agent 子代理 code-assistant(haiku-1) 写守卫 + code-runner-agent(mini) 回归 | 机械断言 haiku 承载；回归跑批 mini |
| Phase 5 | Agent 子代理 code-reviewer(sonnet-1) + general-purpose(sonnet-1, 伴飞 alignment-review) | CR 与对齐审查均隔离上下文 |
| Phase 6 | 机械守卫脚本（smart-merge-back --deploy）+ 主进程簿记 | 合并/部署/对账是白名单①② |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（无长链多 skill 接力、无用户点名）→ 按 Rule 21.4 独立性守门调度（声明组 impl-wave 组内并行，其余串行）
**/goal 对齐（Rule 40.3）**: 用户已用 /goal 锚定（2026-10-08）——「核心就是解决 执行时候 在低质量模型也可以取得更加明确的执行效果 确保执行的时候都有明确的目标和方案 简单高效」→ 映射：本计划 Goal+VC 即该 goal 的证据源；设计契约硬约束=模式库每模式须声明「对低档模型执行明确性的贡献」，任务书模式（No-Placeholder+双明确：目标明确+方案明确）为必选入库模式；R1/R3 与该 goal 同源

## Phases

### Phase 1: 调研落盘与基线
- [x] 池内技能调研（2× Explore 子代理已完成并返回）
- [x] 仓内拆分机制载体盘点（Explore 已返回锚点清单）
- [x] findings.md 回填三方证据面 + knowledge-brief.md 蒸馏（§2 台账事实/§4 易错点/§5 设计契约材料）
- [x] 基线：worktree 建立前先跑 master 全量 selftest 记基线（输出重定向 plans/task-v150-split-skill-integration/baseline-selftest.log，主进程只读 FAIL 汇总行）
- [x] 知识储备必读项已确认（上表 ☑）
- **V-N:** VC-4（基线可对照）, VC-1（调研证据面齐备）
- **Status:** complete
- **Executor:** 主进程（例外理由：②计划系统文件维护（findings/kb 回填）+③机械验证命令（基线跑批输出重定向，摘要级消费）——Rule 25.3 白名单；调研已由 Explore 子代理完成，本 Phase 仅归集落盘）

### Phase 2: worktree 创建与设计契约冻结
- [ ] 创建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration`（分支 `wt/task-v150-split-skill-integration`，基于 master 21f7e6b）；若 master 已前进则以当时 master HEAD 为基
- [ ] 设计契约冻结（落 knowledge-brief §5 + Decisions Made）：①库名与 10 模式章节标题清单（P1-P10 冻结名）②Rule 21.6 五子条文案要点与插入锚（21.5 行后、`### 22` 前）③SKILL.md 三锚点的目标文案 ④selftest 断言清单 ⑤伴飞映射表 6+ 行内容
- [x] 冲突分析：v149 worktree 在飞（HEAD a234369）——合并序策略=本任务先合并则 v149 自行 rebase；若 v149 先合并则本任务 worktree rebase master 后再合并（登记 FMEA 兜底）
- **V-N:** VC-2（插入锚冻结）, VC-1（章节名冻结）
- **Status:** complete
- **Executor:** 主进程（例外理由：①git/worktree 编排 + 规划设计决策=主进程本职（拆分决策属 Rule 21 计划阶段职责）——Rule 25.3 白名单）

### Phase 3: 实现波（模式库+接线）
- [x] 按 S-unit 表派发；S1/S3/S4/S5 同批 [parallel-group:impl-wave] 并行（独立性四问：写集互斥{split-pattern-library.md / critical-rules.md / SKILL.md / subagent_dispatch.md}、无共享可变资源、输入=设计契约各自内联、验收独立）；S2 待 S1 验收后串行派发（同文件追加，四问③）
- [x] 每 S-unit 三证据验收（22.5）+ findings 回填
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S1 | 创建 references/split-pattern-library.md：头部（定位+消费契约+来源技能总表）+ 模式 P1-P5（每模式=判据/反例/消费时机/来源锚） | executor(sonnet-1) | worktree 内设计契约（kb §5 路径+要点）；源技能 SKILL.md 路径清单（kb §2） | 文件在位；`grep -c '^### P'` =5；头部含消费契约段 | ≤15min | 1f/95l/15min | 无 | pending |
| S2 | 同文件追加模式 P6-P10 + 伴飞映射表（任务画像→伴飞技能绝对路径 ≥6 行）+ 消费自查清单 | executor(sonnet-1) | S1 产物（追加不改写）+ 设计契约 P6-P10 要点 | `grep -c '^### P'` =10；伴飞表 ≥6 行且路径存在 | ≤15min | 1f/95l/15min | 无 | pending |
| S3 | [parallel-group:impl-wave] critical-rules.md 纯增量追加 21.6（21.6.1 模式库强制消费/21.6.2 边界三判据/21.6.3 步内 bite-sized/21.6.4 No-Placeholder/21.6.5 伴飞映射联动 59.3），插于 21.5 行后 `### 22` 前 | executor(sonnet-1) | 设计契约 21.6 五子条文案要点（kb §5）+ critical-rules.md:159 插入锚 | grep '21.6\.' ≥5 命中；`git diff master -- 该文件` 零删除行；21.1-21.5 文本未动 | ≤10min | 1f/30l/10min | 无 | pending |
| S4 | [parallel-group:impl-wave] SKILL.md 接线三锚：References 表加库行、委派检查点 2.5 加模式库对照短句、C43 补「拆分前已查模式库」自查句、Rule 21 摘要行（:287）补 21.6 提及 | executor(sonnet-1) | 设计契约三锚目标文案（kb §5）+ SKILL.md 对应行号锚 | `grep -c 'split-pattern-library' SKILL.md` ≥3；新增行 ≤12 | ≤10min | 1f/12l/10min | 无 | pending |
| S5 | [parallel-group:impl-wave] templates/subagent_dispatch.md §3 验收标准段追加 No-Placeholder 契约行（任务书禁 TBD/待定/占位符，材料必须实指路径+摘要） | executor(sonnet-1) | 设计契约契约行文案（kb §5） | grep '占位\|TBD' 命中新行；新增 ≤4 行 | ≤5min | 1f/4l/5min | 无 | pending |

### Phase 4: 守卫与全量回归
- [x] 撰写 selftest-split-pattern-library.sh（断言清单=设计契约④：库存在/模式锚/伴飞表路径存在性/critical-rules 21.6 子条锚/SKILL.md ≥3 锚/dispatch 模板契约行/负断言）
- [x] 全量回归 `scripts/selftest-*.sh` 全跑，对照 Phase 1 基线逐条分类（已知基线 FAIL 不算新增）——S7 抓 3 新增 FAIL→S10 清零，终态新增 FAIL=0
- [x] 每轮测试结果按 Rule 57 当次落盘 progress.md（Round 1-3）
- **V-N:** VC-4, VC-2（负断言守护）, VC-7
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S6 | 撰写 scripts/selftest-split-pattern-library.sh（静态断言 ≥12 条，紧凑实现 ≤95 行） | code-assistant(haiku-1) | 设计契约断言清单（kb §5④）+ scripts/selftest-media-dispatch.sh（参照骨架） | worktree 内运行 exit 0，输出断言计数 | ≤15min | 1f/95l/15min | 无 | done（13/13 PASS，78 行） |
| S8 | 扩展波（B 类 2026-10-09）：库追加 P11 术语语义锚定与理解复述（实验犬误读反例）+ critical-rules 21.6.6 术语锚定子条 | executor(sonnet-1) | kb §5⑥（术语锚定设计契约）+ 库文件/critical-rules 实态 | `grep '^### P11'`+`grep '21\.6\.6'` 命中；既有内容零改动（diff 零删除） | ≤15min | 2f/18l/15min | 无 | pending |
| S9 | selftest 断言同步（SP-02/SP-11 的 =10→=11）+ 复跑全绿 | code-assistant(haiku-1) | S6 产物 + kb §5⑥ 断言同步说明 | selftest Total: 15 PASS=15 FAIL=0 | ≤5min | 1f/4l/5min | 无 | pending |
| S7 | 全量回归跑批（S8/S9 后执行，覆盖扩展产物）：逐个运行 selftest-*.sh，产出 PASS/FAIL 对照基线分类表 | code-runner-agent(mini) | 基线清单（findings §基线，含已知 FAIL 集） | 分类表落 progress.md；新增 FAIL =0 | ≤10min | 0f/0l/10min | 无 | done（63 脚本：3 新增 FAIL 全部定位根因，S10 承接清零） |
| S10 | 锚级联修复（S7 发现）：selftest-registry.tsv 登记新脚本行（解 registry+self-resolution 两条同源 FAIL）+ selftest-skill-split.sh:44 SKILL 行数钉值 500→510（502 实测，≤558 总上限内，脚本注释「钉值随内容演进同步上调」先例）+ 复跑 3 脚本全绿 | code-assistant(haiku-1) | S7 回归明细（findings [sub:16] 段）+ selftest-registry.tsv 表头格式 + selftest-skill-split.sh:40-48 | 3 脚本复跑 rc=0；全量对账新增 FAIL=0 | ≤10min | 2f/6l/10min | 无 | pending |

### Phase 5: 审查闭环（CR + 对齐审查 + 修复轮）
- [x] Code Review：审查 worktree 内改动文件（S11 CHANGES_REQUESTED 7 发现）
- [x] alignment-review 对齐审查（42.6.2）：对全部产出与更新文档（S12 ISSUES_FOUND 6 条）
- [x] CHANGES_REQUESTED → 修复波 S13/S14/S15（fix-wave 并行）+重锁 attest → S16 复审 **APPROVED**（11/11 闭环）
- [x] 变更记录输出（42.6.3 三要素）随交付物落盘（CHANGELOG 条目已入 fix commit；delivery-summary 待 Phase 6）
- **V-N:** VC-5, VC-4（修复后复跑守卫）
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S11 | Code Review：审查 worktree 内改动文件的正确性/一致性/守卫健壮性（含扩展波 P11/21.6.6） | code-reviewer(sonnet-1) | git diff master...HEAD 摘要 + 改动文件清单 | 8 字段返回含 APPROVED 或逐条修复清单 | ≤15min | 0f/0l/15min | 无 | pending |
| S12 | 对齐审查：按 alignment-review 标准审查全部产出文档（跨载体一致性/引用有效性） | general-purpose(sonnet-1) | 改动文档清单 + alignment-review SKILL.md 路径 | 8 字段返回含通过或逐条问题清单 | ≤15min | 0f/0l/15min | `/home/terry/.zcode/skills/alignment-review/SKILL.md`（首动作 Read） | done（ISSUES_FOUND 6 条，与 CR 去重后 9 修复点全采纳） |
| S13 | 修复波1 [parallel-group:fix-wave]：SP-04 扩 [1-6]≥6+SP-03 阈值 ≥7→≥6 对齐契约+registry 描述「五子条」→「21.6.1-21.6.6」 | code-assistant(haiku-1) | CR F2/F3+align P2（findings [sub:19][sub:20] 段） | selftest 复跑 Total FAIL=0；diff 仅数值/描述 | ≤10min | 2f/6l/10min | 无 | pending |
| S14 | 修复波2 [parallel-group:fix-wave]：critical-rules「10 模式」→「11 模式」+机制句去 53.3 错配改直述+kb 瞬态指针改脚本头注释；SKILL References「11 模式」+C43a 行补 Rule/机器面/豁免结构 | code-assistant(haiku-1) | CR F1/F4/F5/F6（findings [sub:19] 段） | grep '11 模式' ×2 命中；grep '53.3' 于 21.6 区段零命中；C43a 含机器面锚 | ≤10min | 2f/8l/10min | 无 | pending |
| S15 | 修复波3 [parallel-group:fix-wave]：库文件补尾换行+表后空行+「53.3 管辖二分」标题改直述+P10 四档表述修正；CHANGELOG.md 追加 task-v150 条目（对齐既有条目格式） | code-assistant(haiku-1) | CR F7/F8/F9（findings [sub:19][sub:20] 段）+ CHANGELOG 尾部格式 | tail -c1 为换行；awk 空行检查过；CHANGELOG grep task-v150 命中 | ≤10min | 2f/12l/10min | 无 | pending |
| S16 | CR 复审（fix 后）：复核 S13-S15 全部修复点+回归 3 脚本 | code-reviewer(sonnet-1) | git diff（fix commit）+ S11 问题清单 | VERDICT: APPROVED | ≤15min | 0f/0l/15min | 无 | pending |

### Phase 6: 合并部署与簿记
- [x] worktree 内全 VC 复验（VC-1..7 全绿）+ `git status` 干净 → `smart-merge-back.sh --deploy` → master=998d6e4
- [x] 部署位 IDENTICAL 对账：claude/opencode IDENTICAL（脚本输出）+ zcode 原子换位后 ZCODE-IDENTICAL（备份 ~/skill-deploy-backups-task-v150/）；主仓 Read 关键文件复验（守卫 13/13+21.6×6+SKILL×4）
- [x] 簿记：INDEX 刷新、ledger-append、rule land（无新号跳过）、verification.md 终验（VC 全过+裁决 solved）、delivery-summary.md 落盘
- [x] worktree 清理（`git worktree remove` + `git branch -d`）
- [x] Rule 34.3 沉淀评估登记（不沉淀理由：既有 rule-enhancement 变体已覆盖本次模式）
- **V-N:** VC-6, VC-1（master 终态 grep）
- **Status:** complete
- **Executor:** 主进程（例外理由：①git/worktree 编排+②计划系统簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号②③：v149 worktree 在飞 HEAD a234369 且其审计 scope 与本任务载体面有潜在交集；信号①：plans/ 未提交簿记属计划系统文件非踩踏面） |
| `isolation` | `worktree`（实现类+保护区技能文件，Rule 36/§十一 命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration` |
| `branch` | `wt/task-v150-split-skill-integration` |
| `merge_back` | `merged(998d6e4)`（2026-10-09 smart-merge-back --deploy；v149 未 land 无冲突；三部署位 IDENTICAL） |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 | S2 追加时未基于 S1 实际产物（章节名漂移/重复写） | 6 | 4 | 3 | 72 | S2 派发 prompt 注入 S1 验收后实际文件锚（行号+章节名清单）；验收 grep 计数双检（22.3①改派/②拆细） |
| Phase 4 | 全量回归遇既有基线 FAIL 误判为新增 | 5 | 6 | 4 | 120 | 基线先行（Phase 1 log 落盘）→ 对照分类法（已知基线/待修/环境性三桶）；歧义 FAIL 主进程对照 master 复跑裁定（22.3 ④ 接管范围=分类判定非修改） |
| Phase 5/6 | v149 并行会话先合并 master，本任务合并撞 critical-rules.md/SKILL.md | 7 | 4 | 2 | 56 | 合并前 `git log master` 复查；若 v149 已 land → 本 worktree rebase master（冲突按「纯增量语义」手工解：两任务新增区段并存）后再 merge（Phase 2 已登记策略） |
| Phase 3 | executor 写 critical-rules.md 误改既有行（破坏 21.1-21.5） | 8 | 3 | 2 | 48 | S-unit 验收含 `git diff` 零删除行断言；违规即回炉（Rule 26）；selftest 负断言兜底 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-08 | S1 建 6 条 |
| Phase 2 | ☑ | 2026-10-08 | 同批建 |
| Phase 3 | ☑ | 2026-10-08 | 同批建 |
| Phase 4 | ☑ | 2026-10-08 | 同批建 |
| Phase 5 | ☑ | 2026-10-08 | 同批建 |
| Phase 6 | ☑ | 2026-10-08 | 同批建 |

## Key Questions

1. 模式库选哪些模式入库？→ 已定：10 模式=边界三判据(Right-Sizing)/bite-sized 步级/子系统拆分法/No-Placeholder/独立性判定法/prompt 四要素映射/嵌套≤2 层+超时档位/简单任务禁 spawn/Spec 自审四查/漂移量化阈值（Phase 2 设计契约冻结细节）
2. 集成方式=吸收成库 vs 运行时直接调池内技能？→ 双轨：模式库承载已蒸馏判据（计划期消费），伴飞映射表指向源技能 SKILL.md（执行期按 59.2 伴飞 Read 原文）——吸收式集成不重复造轮子，伴飞保源技能可深读
3. 为什么扩展 Rule 21 而非新 Rule 66？→ Rule 65 已被 v149 预留（编号竞态防线 Rule 20.6），且拆分语义本属 Rule 21 管辖；子条纯增量零撞号风险

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D 类新任务边界判定（2026-10-08） | 本指令与 v149 审计 Goal 不同（能力增强 vs 对齐修复）→ 开新计划目录，v149 原样保留（Rule 8.1） |
| interaction_mode: silent | v149 判例+自主会话场景（用户非实时在场）；静默决策清单随交付呈报供复核 |
| 集成载体=split-pattern-library.md（吸收式）+ 伴飞映射表（引用式）双轨 | 模式库=蒸馏判据低成本消费；伴飞=59.2 既有机制复用，不新造调度机制（YAGNI） |
| Rule 21.6 子条扩展而非新 Rule 66 | 避让 v149 已预留 Rule 65（rule-reserve 账本 2026-10-08）；语义归属=Rule 21 拆分管辖；纯增量零撞号 |
| 思路复述已呈示,silent 模式豁免等待（28.2.1 ask 专属） | silent 模式 D1 自动通过，计划全文落盘可查 |
| R4 截断不扩范围 | 用户末句「还有就是拆分非」截断，按 R1-R3 主诉求推进+交付时呈报请求澄清（禁假设理解扩围） |
| /goal 锚定=A 类登记（2026-10-08） | 「低质量模型也可取得明确执行效果+明确目标方案+简单高效」与本计划方向同源无范围变更；映射入 🧰 区块 /goal 对齐行；设计契约新增硬约束=模式须声明对低档模型执行明确性的贡献 |
| template_type 修正 rule-enhancement-type→rule-enhancement（2026-10-08） | attest template-gate 白名单实值=rule-enhancement（variant 文件名带 -type 后缀但白名单值无后缀）；warn 档不阻断但按 C22 如实修正后重锁 |
| B 类扩展：术语语义幻觉根治（2026-10-09） | 用户报告执行体对「实验犬」语义误读（实际=实验室替代小白鼠的实验犬，误读=擅长做实验的犬）致定位错误 → 与本任务 Goal 同域，B 类扩展而非 D 类新任务：R5/VC-7 入表，Phase 4 增 S8（库 P11+21.6.6）/S9（selftest 同步），S7 回归调至 S8/S9 后 |
| S4 锚点适配追认（2026-10-09） | C43 以独立行 C43a 呈现、Rule 21.6 以独立摘要条目呈现——比行内追加更清晰且语义等价，追认为合理适配 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （暂无） | - | - | → progress.md Error Log |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-09 00:01 | ALIGNED | VC-1/VC-4 | Phase 1 动作与 Goal/scope 一致，交付面零触碰；检查点=subagent-state/03-drift-checker.md（原 drift-checker provider 拒绝，22.3① 改派 general-purpose 承载） |
| 2026-10-09 00:05 | ALIGNED | VC-2/VC-1 | Phase 2 worktree 编排+锚点重验+契约冻结与 VC 一致；检查点=subagent-state/08-drift-checker-p2.md |
| 2026-10-09 00:40 | ALIGNED | VC-1/VC-2/VC-3 | Phase 3 提交 d4fb622 仅 4 scope 文件 132+/0-，10 模式/21.6×5/SKILL×4/dispatch 契约全达门限；检查点=subagent-state/10-drift-checker-p3.md |
| 2026-10-09 02:10 | ALIGNED | VC-7 | B 类扩展（术语语义幻觉根治）与 Goal 同域，P11+21.6.6+selftest 全链路恰覆盖诉求未越界；检查点=subagent-state/13-drift-checker-b.md |
| 2026-10-09 03:00 | ALIGNED | VC-4/VC-7 | Phase 4 提交 788a4bd 仅 5 scope 文件 +93/-1；回归门拦截 3 级联 FAIL→S10 清零全链路无跳步；检查点=subagent-state/18-drift-checker-p4.md |
| 2026-10-09 04:05 | ALIGNED | VC-5 | Phase 5 fix commit 1e5dd98 恰 6 scope 文件 +20/-17，S16 APPROVED 11/11；检查点=subagent-state/25-drift-checker-p5.md |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 6（Phase 3/4/5 子代理承载；Phase 5 含审查子代理） |
| 主进程直做 Phase 清单 | Phase 1（②簿记+③机械验证基线）、Phase 2（①git 编排+规划职责）、Phase 6（①②合并部署簿记） |
| 委派率 | 0.5（<0.7 但主进程直做全部命中 Rule 25.3 白名单①②③+规划职责 → 预期 WHITELIST-EXEMPT 放行，终验复核） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-08 | Explore(mini) | 盘点池内拆分相关技能实践 | done | 22 技能扫描、8 个 ★高价值吸收源+Top10 排序 | agent 返回报告 | findings §R2 对标面 | （Explore 只读调研,短任务免 checkpoint） | - / 0 / ☑ |
| 2 | 2026-10-08 | Explore(mini) | 盘点仓内拆分机制载体锚点 | done | 12 项锚点清单（Rule 21/46/47/49/59 位置+脚本+模板+编号账本） | agent 返回报告 | findings §R1 自身面 | （同上） | - / 0 / ☑ |
| 3 | 2026-10-09 00:00 | general-purpose（drift-checker 改派，22.3①） | Phase 1 偏移检查（Rule 61/64 载体） | done | ALIGNED——动作与 Goal/scope 一致，交付面零触碰 | subagent-state/03-drift-checker.md | progress.md Phase 1（ledger drift_check tick2） | subagent-state/03-drift-checker.md | provider 拒绝改派 / 0 / ☑ |
| 4 | 2026-10-09 00:06 | drift 检查（general-purpose 承载） | Phase 2 偏移检查 | done | ALIGNED——worktree 交付面零写入，锚点/契约与 VC 一致 | subagent-state/08-drift-checker-p2.md | task_plan.md Drift Log 第 2 行 | subagent-state/08-drift-checker-p2.md | - / 0 / ☑ |
| 5 | 2026-10-09 00:07 | executor(sonnet-1) | S1 模式库上半（头部+P1-P5） | queued | | | | subagent-state/04-executor-S1.md | [parallel-group:impl-wave] / 0 / ☐ |
| 6 | 2026-10-09 00:07 | executor(sonnet-1) | S3 Rule 21.6 纯增量插入 | queued | | | | subagent-state/05-executor-S3.md | [parallel-group:impl-wave] / 0 / ☐ |
| 7 | 2026-10-09 00:07 | executor(sonnet-1) | S4 SKILL.md 四点接线 | queued | | | | subagent-state/06-executor-S4.md | [parallel-group:impl-wave] / 0 / ☐ |
| 8 | 2026-10-09 00:07 | executor(sonnet-1) | S5 dispatch 模板 No-Placeholder 契约行 | done | 3 行追加（主行+双明确+验收可观察子行），零删除 | git diff +3/-0 | findings [sub:07-executor-S5] | subagent-state/07-executor-S5.md | [parallel-group:impl-wave] / 0 / ☑ |
| 9 | 2026-10-09 00:25 | executor(sonnet-1) | S2 模式库下半（P6-P10+伴飞表+未吸收登记） | done | 115 行总（+55），P1-P10 齐、伴飞表 7 行路径 -f 全过；首派 provider 失败但已写入，重试验证后未重复追加 | wc/grep 计数+主进程防双写复核 | findings [sub:09-executor-S2] | subagent-state/09-executor-S2.md | S1 后串行 / 0 / ☑ |
| 10 | 2026-10-09 00:45 | code-assistant(haiku-1) | S6 selftest-split-pattern-library.sh 撰写 | done | 78 行 13 断言 SP-01..13 全 PASS 幂等（自跑 2 次一致） | bash 自跑 Total: 13 PASS=13 FAIL=0 | findings [sub:11-code-assistant-S6] | subagent-state/11-code-assistant-S6.md | - / 0 / ☑ |
| 11 | 2026-10-09 02:12 | executor(sonnet-1) | S8 扩展波：库 P11+Rule 21.6.6 | done | P11 五要素（实验犬真实反例 :105）+21.6.6（:168）；12+/0- | git numstat 9+0/3+0 | findings [sub:14-executor-S8] | subagent-state/14-executor-S8.md | B 类扩展 / 0 / ☑ |
| 12 | 2026-10-09 02:35 | code-assistant(haiku-1) | S9 selftest 断言同步=11 并复跑 | done | SP-02/SP-11 期望 10→11（按实态字符串比较形态改）+头部描述；复跑 13/13 | bash Total: 13 PASS=13 | findings [sub:15-code-assistant-S9] | subagent-state/15-code-assistant-S9.md | S8 后串行 / 0 / ☑ |
| 13 | 2026-10-09 02:12 | code-runner-agent(mini) | S7 全量回归（重派，首派被取消） | done | 63 脚本三桶分类：已知基线 1（periodic 4 FAIL）+新增 3（registry/self-resolution/skill-split 钉值）机械 diff 定位根因 | regression-worktree.log | findings [sub:16-code-runner-S7] | subagent-state/16-code-runner-S7.md | S9 后串行 / 1 / ☑ |
| 14 | 2026-10-09 02:50 | code-assistant(haiku-1) | S10 锚级联修复（registry 登记+钉值上调） | done | tsv+1 行同构登记；钉值 500→510；4 脚本复跑 rc=0（执行体+主进程双源核验） | 4×Total FAIL=0 | findings [sub:17-code-assistant-S10] | subagent-state/17-code-assistant-S10.md | - / 0 / ☑ |
| 15 | 2026-10-09 03:20 | code-reviewer(sonnet-1) | S11 Code Review | done | CHANGES_REQUESTED：7 发现（2 计数漂移+守卫覆盖缺口+53.3 错配+C43a 格式+文件卫生等），逐条 file:line 取证 | subagent-state/19-code-reviewer-S11.md | findings [sub:19-code-reviewer-S11] | subagent-state/19-code-reviewer-S11.md | - / 0 / ☑ |
| 16 | 2026-10-09 03:20 | general-purpose(sonnet-1) | S12 对齐审查（alignment-review 伴飞） | done | ISSUES_FOUND 6 条（3 P1 含 CHANGELOG 缺失/3 P2）；互引 59.2/59.3/63.2 验证匹配 | subagent-state/20-alignment-S12.md | findings [sub:20-alignment-S12] | subagent-state/20-alignment-S12.md | - / 0 / ☑ |
| 17 | 2026-10-09 03:40 | code-assistant(haiku-1) | S13 修复波1（SP-04/SP-03/registry 描述） | queued | | | | subagent-state/21-code-assistant-S13.md | [parallel-group:fix-wave] / 0 / ☐ |
| 18 | 2026-10-09 03:40 | code-assistant(haiku-1) | S14 修复波2（critical-rules+SKILL 措辞） | queued | | | | subagent-state/22-code-assistant-S14.md | [parallel-group:fix-wave] / 0 / ☐ |
| 19 | 2026-10-09 03:40 | code-assistant(haiku-1) | S15 修复波3（库卫生+CHANGELOG） | done | 尾换行+空行+标题去 53.3+P10 措辞；CHANGELOG task-v150 条目（S15+主进程措辞 trivial 修正） | tail 0a+awk+grep 验证 | findings [sub:23] | subagent-state/23-code-assistant-S15.md | [parallel-group:fix-wave] / 0 / ☑ |
| 20 | 2026-10-09 03:55 | code-reviewer(sonnet-1) | S16 CR 复审 | done | VERDICT: APPROVED——11/11 闭环，残留 grep 零命中，三守卫 rc=0；nit（脚本注释 53.3/kb 3 行）登记 deferred | subagent-state/24-code-reviewer-S16.md | findings [sub:24-code-reviewer-S16] | subagent-state/24-code-reviewer-S16.md | - / 0 / ☑ |

**S-unit 验收补记（主进程 22.5 复核，2026-10-09）**：S1=60 行库上半 Read 复核五要素齐（含每模式低档模型贡献行）；S3=:160-168 五子条+机制句，`### 22` 顺移 :169，diff 零删除；S4=4 处新增（2.5 句/C43a 行/Rule 21.6 摘要条目/References 表行）——C43a 独立行与独立摘要条目为对既定锚点的合理适配，登记 Decisions Made；S5=3 行契约追加。全部证据：worktree git diff（16 insertions, 0 deletions）。

## 🔗 Chain 区块交接配置

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
