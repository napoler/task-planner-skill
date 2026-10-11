# Task Plan: task-v148 — Rule 64 偏移检查留痕强制与节奏化触发纪律落地

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「嗯，对防偏移进行加强。」<sub>（[目标]）</sub>
- **R2**: 「在当前我发现执行任务的时候，真的是防偏移这个东西非常容易。」<sub>（[目标]；口语截断，语境=防偏移容易失效/被忽略——客观转译锚=调研实证 25 Phase 执行率 0%，见 findings.md B 面）</sub>
- **R3**: 「需要进行时刻记得纠正」<sub>（[目标]）</sub>
- **R4（执行补充，主进程归类）**: 载体复用既有 drift-checker 子代理（Rule 61），不另造执行体<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-5, VC-7 | 条款在位 grep 锚全命中 + 接线点在位 + 部署位 IDENTICAL |
| R2 | VC-2, VC-3, VC-6 | ledger drift_check 行为可写 + gate fixture 四态行为级证据 + 回归零新增 FAIL |
| R3 | VC-3, VC-4, VC-6 | gate 收口强制 + hook 节奏注入干跑证据 + selftest 行为断言全 PASS |
| R4 | VC-5 | drift-checker 判定输入锚在位（仓内副本），Rule 61 契约零改动 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

结果级需求 = R1-R3「防偏移必被检测、必被纠正、必留证据」。生产链工序审计（调研 01-explore 实证）：

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 触发工序 | 无机械计数器/hook，派发纯靠模型自觉（0% 实证） | 64.3 posttooluse [drift-rhythm] 节奏注入（S3） | VC-4 |
| 留痕工序 | 执行无证据链，做没做过不可核查 | 64.1 留痕三件套（S1 条款+ledger 枚举 S2） | VC-1, VC-2 |
| 消费工序 | 判定结果无机器消费通道（gate/check-complete 不查） | 64.2 check-3file-gate 第三条件门控（S2） | VC-3 |
| 判定工序 | 无输入契约，ALIGNED 可为空口 | 64.4 三锚输入契约（S4 agent 增补） | VC-5 |
| 守护工序 | selftest 只守措辞不守执行行为 | 64.5 selftest-drift-enforcement.sh 静态+行为双断言（S5） | VC-6 |

<!-- plan_tier: standard -->
## Goal
落地 Rule 64「偏移检查留痕强制与节奏化触发纪律」——把 drift-check 从软触发升级为三层机械闭环（64.1 留痕三件套 + 64.2 Phase complete 硬门控 + 64.3 hook 节奏提醒 + 64.4 判定输入契约），载体复用 Rule 61 drift-checker 语义零改动；全量 selftest 零新增回归后合并回 master 并部署三实体位 IDENTICAL。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 门控/hook 脚本=代码文件） |
| `session_id` | `d3615459cf06411db9ba7b1a9898b7c1` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce` |
| `scope_files` | `skills/task-planner/references/critical-rules.md`; `skills/task-planner/scripts/ledger-append.sh`; `skills/task-planner/scripts/check-3file-gate.sh`; `skills/task-planner/scripts/zcode-posttooluse.sh`; `skills/task-planner/scripts/selftest-drift-enforcement.sh`(新建); `skills/task-planner/scripts/selftest-registry.tsv`(追加 1 行，13:56 drift 检查观察项采纳补登); `skills/task-planner/SKILL.md`; `skills/task-planner/companion/agents/drift-checker.md`; `CHANGELOG.md`; `plans/task-v148-drift-enforce/**`(计划系统文件豁免) |
| `interaction_mode` | `silent`（config.json#interaction_mode=silent；交付附静默决策清单） |
| `对齐审查` | 已登记（Phase 4 S8：全部产出与更新文档过 alignment-review 标准收尾） |
| `自动超时默认项` | 本任务无 2+ 选项询问点（silent 模式，D6 硬停点除外）——登记豁免理由 |
| `new_rule` | `64`（63 已被 task-v147 预留「检索优先与反推诿」；attest 自动预留+查重） |
| `质量审查工具` | 检测结论：code-reviewer（用户级 agents 在位）+ alignment-review（review-library 池在位）+ drift-checker（本任务审查对象本体）；无缺口，免补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 64 条款块在 critical-rules.md 尾部在位（`### 64` 块头 + 64.1~64.6 六子条锚 grep 全命中），且 git diff 该文件零删除行（纯增量 36.5） | grep + git diff --numstat | `grep -c '64\.[1-6] \*\*' <critical-rules>` = 6；`git diff --numstat` 删除列=0 |
| VC-2 | ledger-append.sh VALID_EVENTS 含 drift_check；行为级：临时目录 drift_check 事件写入成功且可 grep | 命令 | `ledger-append.sh <tmp> drift_check "ALIGNED 测试" --phase 1` + `grep drift_check <ledger>` |
| VC-3 | check-3file-gate.sh 64.2 第三条件四态行为级：无痕迹→exit 1；有检查点痕迹→exit 0；drift_exempt 声明→exit 0；env warn→exit 0 | selftest fixture（DCE-11~14） | `bash scripts/selftest-drift-enforcement.sh` 对应断言 PASS 行 |
| VC-4 | posttooluse [drift-rhythm] 计数段：静态锚在位 + 干跑（构造 count≥N 状态）stdout JSON 含 drift-rhythm | 干跑命令 + grep | DCE-16 fixture PASS 输出 |
| VC-5 | SKILL.md 接线 ≥2 处（64.1 留痕行 + C4 追加句）+ companion/agents/drift-checker.md 判定输入锚在位 | grep | `grep -c '64.1 留痕三件套\|留痕三件套已落实' SKILL.md` ≥2；agent 文件含判定输入锚 |
| VC-6 | selftest-drift-enforcement.sh 全 PASS（DCE-01~16），且 worktree 全量 selftest 对照 master 基线零新增 FAIL | 跑套件输出对照 | Round N 落盘 progress.md（57.2 四要素）+ 基线对照表 |
| VC-7 | 部署位同步：task-planner 技能部署位与 agents 部署位 diff=IDENTICAL（相对 worktree 合并后 master） | diff -r | 部署对账输出（Phase 5） |
| VC-8 | 既有 DCS 20 断言全绿（v146 载体措辞零破坏） | selftest | `bash scripts/selftest-drift-check-subagent.sh` 20/20 PASS |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> `code_review: required` → 终验前必须先通过 Code Review Gate（S7 APPROVED），否则不得标 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 / R2 / R3 |
| **裁决** | solved |
| **解决证据锚** | ① 部署位实弹：ledger tick 8 drift_check 事件+gate 对本计划 Phase 5 exit0（64.1→64.2 活体闭环）② gate 四态+mini 豁免独立复跑全过 ③ hook 投递必达 A/B（delivered 0→2）+单轮单 JSON ④ master 回归 60P/1F 零新增 |
| **未解决面+原因** | （partial 时必填） |
| **已排除路径** | （not-solved 必填） |
| **下一步建议** | （not-solved 必填） |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能规则 | skills/task-planner/references/critical-rules.md（尾部追加） | 其他 references/*.md；既有行改写/删除 |
| 技能脚本 | skills/task-planner/scripts/{ledger-append,check-3file-gate,zcode-posttooluse}.sh；scripts/selftest-drift-enforcement.sh(新建) | 其他脚本；既有条件 1-5 语义 |
| 技能入口 | skills/task-planner/SKILL.md（2 处纯追加） | 既有行改写（DCS 字面锚） |
| 伴飞 agent | skills/task-planner/companion/agents/drift-checker.md（≤3 行追加） | 部署位 ~/.zcode/agents/**（Phase 5 部署通道专属） |
| 文档 | CHANGELOG.md（追加条目） | 其他文档 |
| 计划文件 | plans/task-v148-drift-enforce/** | plans/ 其他任务目录（含 task-v147，只读禁写） |

**执行前自我检查:** 文件在列表中？修改必要？用户要求（防偏移加强授权范围）？——全部 Yes 才执行。

## 📚 必要知识储备（任务知识库对齐）

| 类别 | 名称/主题 | 定位（路径/版本） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部 | critical-rules.md Rule 11/15/61/59.6/59.7（载体范式+零新键范式） | skills/task-planner/references/critical-rules.md（:37-74, :716-765） | 必读 | ☑（01-explore 消费） |
| 项目内部 | check-3file-gate.sh 结构（Started 锚机制） | skills/task-planner/scripts/check-3file-gate.sh（199 行，docblock :7-15） | 必读 | ☑（本轮 Read） |
| 项目内部 | ledger-append.sh 事件枚举 | skills/task-planner/scripts/ledger-append.sh（:20,:28） | 必读 | ☑（本轮 grep） |
| 项目内部 | zcode-posttooluse.sh 注入先例 | skills/task-planner/scripts/zcode-posttooluse.sh（:13 JSON 校验, :155 additionalContext helper） | 必读 | ☑（本轮 grep） |
| 项目内部 | DCS 20 断言基线（DCS-01~20 字面锚） | skills/task-planner/scripts/selftest-drift-check-subagent.sh | 必读（S4 前跑基线） | ☐ |
| 项目内部 | gate fixture 范式 | skills/task-planner/scripts/selftest-four-file-dataflow.sh（v145） | 参考 | ☐ |
| 项目内部 | 部署位与合并回合约 | ~/.zcode/skills/task-planner/references/worktree-isolation.md + plans/task-v146-drift-check-subagent/delivery-summary.md（三部署位+双 agents 位判例） | 参考 | ☐ |
| 项目内部 | 派发九字段契约 | skills/task-planner/templates/subagent_dispatch.md | 必读（派发时） | ☐ |

## ⚠️ 核心问题定义

**核心问题**: 防偏移机制「条款在位但从不执行」（18 项机制 16 项软性、25 Phase 执行率 0%）——软触发无机械证据链与消费闭环，等于无机制。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（Rule 64 三层闭环落地+部署=交付）
- [x] 核心问题不解决，其他工作都白费吗？（不解决则 drift-check 永远 0%，偏移持续靠旁路运气兜住）
- [x] 核心问题的解决方法是清晰的、可执行的？（三层接线点已第一手探明：ledger:28/gate Started 锚/hook :155 注入先例）

## 🔍 证据面清单（Rule 58.1）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | task-v141~v145 全部 Phase 的 drift-check 执行痕迹 | plans/*/subagent-state 枚举 + progress grep | findings.md「2026-10-08 防偏移机制面盘点」B1 表 | ☑ |
| ② 对标样本（58.2） | 正例=task-v085/progress.md:39 唯一手工 [DRIFT CHECK]；机制同族先例=Rule 19.2 3-File 门（软要求→硬门后执行率归一） | Read 对照 | findings.md B2 案例段 + 本表 | ☑ |
| ③ 外部约束 | ZCode hook stdout JSON 校验（posttooluse :13 平台事实）；§六 agents 保护区；零新 config 键惯例（59.7） | 脚本注释+宪法条款 | findings.md A 面锚 11/12 + rule64-draft.md 64.6 | ☑ |

## Current Phase
（全部 complete — outcome: COMPLETE）

## Next Step
（已交付——遗留 3 项登记于 verification.md；v147 合并尾部冲突提示已转达）

## 🧰 工具选择与编排（Rule 40）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore（mini） | 机制面盘点+取证=跨文件搜索提炼，主上下文零占用 |
| Phase 2 | 机械守卫脚本（主进程白名单②） | 规则体系草案强语境依赖，派发 prompt 预算超限（v147 同款例外） |
| Phase 3 | Agent 子代理 code-assistant(haiku-1)/executor(sonnet-1)/code-runner(mini) | S1/S4=锚定文本追加（haiku 可载）；S2/S3/S5=门控逻辑（sonnet）；S6=跑测（mini） |
| Phase 4 | Agent 子代理 code-reviewer(sonnet-1) + Skill(alignment-review) | CR Gate 强制 + 42.6.2 标准收尾 |
| Phase 5 | 机械守卫脚本（git/install） | 主进程白名单① git 编排 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——S1→S2/S3→S4/S5→S6 为文件依赖链（S5 fixture 消费 S2/S3 产物），串行派发单 Phase 内完成度高；按 Rule 21.4 独立性守门调度，未声明并行组=串行。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定，n/a。

## Phases

### Phase 1: 调研与机制面盘点
- [x] 现行防偏移机制面全量盘点（18 项：机械 2/软性 16）
- [x] 失效取证（25 Phase 执行率 0% + 历史偏移案例 4 例）
- [x] 根因三连与接线锚点探明（H1-H7）
- [x] findings/checkpoint/knowledge-brief 三落盘
- [x] 知识储备必读项已确认可获取（上表 ☑ 项）
- **V-N:** VC-1（条款设计输入齐备——根因+锚点+范式判例）, VC-6（基线对照口径确立——master 基线先行）
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S0 | 防偏移机制面盘点+失效取证（A/B 双面） | explore(mini) | skills/task-planner 规则/脚本面+plans 近期任务（brief 派发时未建，检查点代偿） | 检查点+findings 双落盘（主进程代回填） | 9min | 0f/0l/9min | 无 | done |

### Phase 2: 方案设计与条款草案
- [x] Rule 64 六子条条款全文定稿（What+Why 双层，Rule 45）
- [x] S2/S3/S4/S5 接线规格与断言清单定稿（rule64-draft.md §2-§5）
- [x] 编号避让确认（63=v147 预留 → 本任务 64）
- [x] attest 锁定（现行 SHA 70bf2e87@11:59 重锁；首次 9b547d58@11:52；rule-reserve 64 括注解析 fail-open → 手动补登 reserved 在案）
- **V-N:** VC-1（草案文本=VC-1 验收的供料源）, VC-5（接线文本定稿）
- **Status:** complete
- **Executor:** 主进程（例外理由: ② 计划系统文件维护+规则体系草案（21.2.1 台账供料+22.4 §9 prompt 预算超限）——Rule 25.3 白名单）

### Phase 3: 实现落地（worktree 隔离）
- [ ] worktree 创建（wt/task-v148-drift-enforce，自 master HEAD）
- [ ] S1-S6 逐单元派发与验收（22.5 三证据）
- [x] dogfood：ledger drift_check 事件枚举部署前以 note 代偿（tick 4），检查点+Drift Log 双痕迹已落；部署后实弹
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** executor（sonnet-1）

<!-- S-unit 派发单元表(Rule 22.6)；单步 ≤2 文件/≤100 行/≤15min（59.1 三值硬门）；输入列=材料包路径+摘要，供料唯一锚=rule64-draft.md -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|
| S1 | critical-rules.md 尾部追加 Rule 64 条款块（§1 全文）+ CHANGELOG 条目 | code-assistant(haiku-1) | plans/task-v148-drift-enforce/rule64-draft.md §0/§1/§7（条款全文逐字供料+落点格式）+ kb §3 | grep `### 64`+`64.1`~`64.6` 全命中；git diff 零删除行 | 13min | 2f/75l/13min | 无 | done |
| S2 | ledger-append.sh 增 drift_check 枚举 + check-3file-gate.sh 追加第 6 条件段 | executor(sonnet-1) | rule64-draft.md §2（接线规格+判定序+文案）+ kb §3 锚点表 | 手跑 fixture 两态：无痕迹 exit 1/有痕迹 exit 0 | 14min | 2f/45l/14min | 无 | done |
| S3 | zcode-posttooluse.sh 追加 [drift-rhythm] 计数注入段 | executor(sonnet-1) | rule64-draft.md §3（状态文件两键+fail-open+文案）+ kb §3 | 干跑：构造 count≥N → stdout JSON 含 drift-rhythm | 13min | 1f/50l/13min | 无 | done（S3b 修正后）|
| S4 | SKILL.md 2 处纯追加 + companion/agents/drift-checker.md 判定输入段 | code-assistant(haiku-1) | rule64-draft.md §4（追加文本逐字供料+DCS 基线前置动作） | 追加后 selftest-drift-check-subagent.sh 20/20 | 10min | 2f/12l/10min | 无 | done |
| S5 | 新建 scripts/selftest-drift-enforcement.sh（DCE-01~16）+ registry 登记 | executor(sonnet-1) | rule64-draft.md §5（断言清单逐条）+ selftest-four-file-dataflow.sh fixture 范式 | 自跑全 PASS | 15min | 2f/95l/15min | 无 | done |
| S6 | 全量 selftest 回归 + 锚级联扫描（对照 master 基线） | code-runner-agent(mini) | rule64-draft.md §6（回归清单）+ kb §4 | FAIL 集 ⊆ master 基线 FAIL 集 | 15min | 0f/0l/15min | 无 | done（主进程③接管）|

### Phase 4: 验证与审查
- [x] S7 Code Review Gate（required）：四轮闭环 F1-F8→F9/F10→N1→N2，终轮 APPROVED（18-code-reviewer.md）
- [x] S8 alignment-review 对齐审查（42.6.2 标准收尾）+ 2 处 P2 联动同步（64.5 陈旧锚/枚举+hook 两键注释）
- [x] CR/align 发现项修复闭环（S7-fix/S7-fix2/S7-fix3/N2-fix/align-fix 五轮回执齐）
- **V-N:** VC-6, VC-8
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入 | 验收 | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|------|------|------|------|------|------|
| S7 | Code Review：wt 分支全量 diff 审查 | code-reviewer(sonnet-1) | `git diff master...wt/task-v148-drift-enforce` + scope_files 清单 | APPROVED 或修复闭环 | 15min | 0f/0l/15min | 无 | done（主进程③接管）|
| S8 | alignment-review 对齐审查（主进程 Skill 调用） | 主进程（例外理由: ③ 机械验证+42.6.2 标准收尾流程载体） | 全部产出文件清单 | APPROVED + 变更记录三要素 | 15min | 0f/0l/15min | 无 | done（主进程③接管）|

### Phase 5: 合并部署与交付
- [x] smart-merge-back 合并回 master ×2（5200380 主合并 + 18b281d dce10 增补；v147 未合，尾部冲突留其会话按 63→64 序手解）
- [x] 部署三实体位（zcode/claude/opencode）8 文件 IDENTICAL + agents 双位内容同步（model 行平台适配保留）
- [x] rule-reserve land 64 + dogfood 实弹（ledger tick 8 drift_check+gate exit0）+ 交付总结（delivery-summary.md 落盘）
- **V-N:** VC-7, VC-1（合并后复验）
- **Status:** complete
- **Executor:** 主进程（例外理由: ① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 17 文件未提交=v146 簿记+v147 计划目录，与本 scope 零重叠；信号②/③ task-v147 worktree 与 wt 分支在位=并行任务产物不触碰；信号④ INDEX 7 未完成含 stale；信号⑤ 无） |
| `isolation` | `worktree`（skills/scripts/hook=运行中基础设施，§十一 P0 强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce` |
| `branch` | `wt/task-v148-drift-enforce` |
| `merge_back` | `pending` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。注意 memory 判例：worktree 创建后先核对关键文件与主仓一致（worktree-branch-desync 判例）。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 | critical-rules.md 尾部与 v147（Rule 63 在途）合并冲突 | 4 | 6 | 3 | 72 | 合并序手解（63 先 64 后）+master Read 复验；v144/v145/v146 三方同日合流先例；22.3④ 接管 |
| Phase 3 | S4/S6 锚级联（DCS 断言/上界措辞/计数锚被新文本破坏） | 4 | 6 | 3 | 72 | 先跑 DCS 基线再动文本；跨脚本 grep 旧 label 宽容化范式（v121/v146 判例）；22.3② 拆细回炉 |
| Phase 3 | gate 第三条件误伤既有流程 | 6 | 3 | 3 | 54 | fixture 四态先行（DCE-11~14）+drift_exempt 豁免+env 降档三出口 |
| Phase 3 | hook 源不在仓（基础设施直改风险） | 6 | 1 | 2 | 12 | 已排除：scripts/zcode-posttooluse.sh 仓内在位实测（本轮 grep） |
| Phase 5 | 部署位竞态（他会话并行写部署位） | 5 | 4 | 4 | 80 | 部署前基点 diff 核对+IDENTICAL 对账（v138 live race 判例）；异常即 STOP 报告 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；本表最高 80，全部已预设兜底。执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-08 11:20（初建）/11:35（complete） | |
| Phase 2 | ☑ | 2026-10-08 11:36 | |
| Phase 3 | ☑ | 2026-10-08 11:36 | attest 后映射 |
| Phase 4 | ☑ | 2026-10-08 11:36 | |
| Phase 5 | ☑ | 2026-10-08 11:36 | |

## Key Questions
1. gate 默认档 enforce 还是 warn？→ **enforce+三档豁免**（用户「时刻纠正」诉求+51/59 硬门先例+轻任务零增负）
2. 节奏 N 值？→ 10（对齐 todo_sync_interval_calls 缺省量级），env 可调
3. 与 v147（Rule 63 在途）冲突？→ 编号已避让（64）；critical-rules.md 尾部合并冲突按合并序手解（FMEA 首行）
4. 为何不改 Rule 15/61 原文？→ 36.5 纯增量+载体语义零改动（条款死文根因在证据链不在条款文本）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| D 类判定（Rule 8.1）：防偏移加强 ≠ task-v147（Rule 63 检索优先），开 task-v148，v147 原样保留 | 证据：v147 task_plan.md Goal 段 + .rule-reservations.jsonl rule=63 行；11:23 实测无活跃写入 |
| 交互模式 silent，attest 后直接执行 | config.json#interaction_mode=silent；交付附静默决策清单 |
| 方案形态=新增 Rule 64（编号避让 63），不改 Rule 11/15/61 原文 | Rule 36.5 纯增量；根因在证据链缺失非条款文本缺失 |
| 零新 config 键，env 降档口（TASK_PLANNER_DRIFT_ENFORCE/_RHYTHM_N） | 59.7/43.4/44.4 同范式（键膨胀=配置面失控面） |
| Phase 2 条款草案主进程预写（rule64-draft.md 供料） | 21.2.1 台账供料+22.4 §9 prompt 预算超限（v147 同款白名单例外） |
| drift_exempt=计划声明行机制（不改模板） | 规避 Rule 34 模板级联（模板锚计数 35 口径）；gate grep task_plan.md token |
| SKILL.md 上界计数措辞（1-62 等）本次不动 | v146 同款遗留延续；63 未落地避免计数失真+DCS 级联 |
| 本任务自身 dogfood：Phase 3 complete 起按 64.1 留痕 | 新机制自证（VC-3/VC-4 的活体证据） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| 01-explore 子代理未按落盘契约写检查点/findings（过度遵守只读约束） | 1 | 主进程代落盘（返回消息全文蒸馏+复核） | → progress.md Error Log：落盘契约与只读约束并存时，子代理倾向更严约束——契约措辞应显式声明「findings 自写小节不属于只读禁区」 |
| Rule 27 逐 Phase 提交遗漏（S1-S6 全部产物攒到终验补提交） | 1 | f3a8686 终验补提交（message 注明）；丢弃上限已收敛为全任务增量，无实际损失 | → progress.md Error Log：主进程在每 Phase complete 簿记批次中漏了 commit 动作——Phase complete 仪式应含「scope 文件 git status 核对+提交」固定步 |
| 部署 cp 路径错拼（$D/$f 双重 skills/ 嵌套） | 1 | diff 对账暴露→核验垃圾目录仅含本次 24 文件→rm -rf→正确路径重部署→三位置 IDENTICAL | → progress.md Error Log：部署目标=部署位根+去「skills/」前缀子路径；对账 diff 是唯一可靠防线（本轮正是它抓住的） |
| provider 通道大面积不稳（haiku drift-checker×2 拒、sonnet executor/CR 滞挂×4） | 各 1-2 | 全部 22.3①/22.7 换道 general-purpose 成功（今日 5/5） | → progress.md Error Log：换道矩阵应按「当日通道实绩」动态选路，非固定档位表 |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 12:04 | ALIGNED（Phase 1-2 合并检查，22.3① 改派 general-purpose） | 全部 | 三锚对照零范围外写入；2 项簿记观察项（SHA 记法已同步修正/worktree 时序登记）；检查点 subagent-state/02-drift-checker.md |
| 13:56 | ALIGNED（Phase 3 收口，drift-checker(haiku) provider 拒→22.3① 改派 general-purpose） | VC-1..5 | worktree 9 文件全在 scope、零范围外写入、S1-S6 独立复验证据齐全；观察项=registry.tsv 已补入 scope_files；检查点 10-drift-checker.md |
| 17:12 | ALIGNED（Phase 4 收口） | VC-6/8 | scope 9 文件一一对应零范围外；CR 四轮+align 闭环结论链连续（11/13/16/18/19/20 检查点齐）；观察项=progress 缺 Phase 4 段已在本轮回填；检查点 21-drift-checker.md |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（P1 explore、P3 六单元、P4 CR/fix 九轮） |
| 主进程直做 Phase 清单 | P2（②计划/规则体系草案）、P5（①git 编排+②簿记+部署对账）、S6/S8 部分（③机械验证接管）——全部 Rule 25.3 白名单内 |
| 委派率 | 0.6<0.7 → WHITELIST-EXEMPT（直做理由全部命中白名单 ①②③，v141 同款判定） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 11:22 | explore | 防偏移机制面盘点+失效取证 | done | 18 项机制机械 2/软性 16；25 Phase 执行率 0% 实证；根因三连+H1-H7 接线锚 | findings.md B1 表；task-v085/progress.md:39 | 「2026-10-08 防偏移机制面盘点与失效取证（01-explore）」 | plans/task-v148-drift-enforce/subagent-state/01-explore.md | - / 0 / ☑（主进程代落盘+复核） |
| 2 | 12:02 | drift-checker(haiku-1)→general-purpose | Phase 1-2 目标对齐三态判定 | done | 首派 provider 拒绝（12s），22.3① 改派 general-purpose → **ALIGNED**：三锚对照零范围外写入 | 检查点 02-drift-checker.md 全文 | Drift Log 12:04 行 | plans/task-v148-drift-enforce/subagent-state/02-drift-checker.md | rescue:改派 haiku→general / 1 / ☑ |
| 3 | 12:06 | code-assistant(haiku-1) | S1 critical-rules.md Rule 64 条款+CHANGELOG | done | 18+2 行纯增/0 删除；锚 6/6；块头 :769；findings 回执在位 | numstat 2f/0d+18f/0d；grep ^64.[1-6]=6 | findings「S1 执行回执」 | subagent-state/03-code-assistant.md | - / 0 / ☑（主进程独立复验） |
| 4 | 12:14 | executor(sonnet-1) | S2 ledger drift_check 枚举+gate 条件 6 | done | 四态行为实测：无痕迹 exit1/warn 0/exempt 0/ledger 0；-1 行=VALID_EVENTS 值尾改写（7 项原样） | 主进程独立复跑四态全过（12:21） | findings「S2 执行回执」 | subagent-state/04-executor.md | - / 0 / ☑（主进程独立复验） |
| 5 | 12:22 | executor(sonnet-1) | S3 posttooluse [drift-rhythm] 计数段 | done | +41/-0；注入/静默两态过；S3b 回炉=状态目录迁 plans 根（条款一致性）| 主进程五项复验全过（12:46）| findings「S3 执行回执」「S3b 执行回执」| subagent-state/05-executor.md、06-executor.md | rescue:S3b 滞留 22.3④ 接管 / 1 / ☑ |
| 6 | 12:52 | code-assistant(haiku-1) | S4 SKILL.md 2 处追加+agent 判定输入段 | done | 锚 1/1/1；DCS 前后 20/20；C4 行末追加=内容级零删除（前缀程序化验证）| 主进程独立复跑 DCS 20/20（12:57）| findings「S4 执行回执」 | subagent-state/07-code-assistant.md | - / 0 / ☑ |
| 7 | 12:58 | executor(sonnet-1) | S5 selftest-drift-enforcement.sh 新建 | done | 61 行/16 断言/负例自查有效/registry 登记；滞留 23min 后完成 | 主进程独立复跑 16/16（13:22）| findings「S5 执行回执」 | subagent-state/08-executor.md | rescue:滞留观察（未停） / 1 / ☑ |
| 9 | 14:00 | code-reviewer(sonnet-1) | S7 Code Review 全量 diff | done | CHANGES_REQUESTED：F1 MAJOR(mini 豁免未实现)+F2-F7 MINOR+F8 规格固有 | 检查点 11-code-reviewer.md | progress Phase 4 | subagent-state/11-code-reviewer.md | - / 0 / ☑ |
| 10 | 14:20 | executor(sonnet-1) | S7-fix F1-F7 修复 | done | 18/18+20/20+18/18；F5 引入新缺陷（复审发现 F9/F10）| 主进程独立复验（14:49）| findings「S7-fix 执行回执」 | subagent-state/12-executor.md | - / 0 / ☑ |
| 11 | 14:52 | code-reviewer(sonnet-1) | S7-re 复审 F1-F7 | done | CHANGES_REQUESTED：F1-F4/F6/F7 ✅；F5 PARTIAL→F9 BLOCKER(双行 JSON)+F10(守卫绕过) | 检查点 13-code-reviewer.md | progress Phase 4 | subagent-state/13-code-reviewer.md | - / 0 / ☑ |
| 12 | 15:27 | executor(sonnet-1)→general-purpose | S7-fix2 F9+F10 修复 | done | 首派 72min provider 失败→22.7 换道 general-purpose 3min 闭环；21/21+20/20+18/18+单轮单 JSON+F10 三场景 | 主进程独立复跑（15:31）| findings「S7-fix2 执行回执」 | subagent-state/14-executor.md(失败)、15-executor.md(成功) | rescue:22.7 换道 sonnet→general / 2 / ☑ |
| 13 | 15:35 | executor(sonnet-1)→general-purpose | S7-fix3 N1 投递饥饿修复 | done | 根因=else 分支 clobber due；读-改-写持久化；DCE 23 断言+A/B 对照 delivered 0→2 | 主进程独立复跑 23/23（17:05）| findings「S7-fix3 执行回执」 | subagent-state/17-executor.md | rescue:22.7 换道 / 3 / ☑ |
| 14 | 16:20 | code-reviewer(sonnet-1)→general-purpose | S7 四轮终审 | done | 首派 75min 挂起停用→general-purpose APPROVED（N1 闭环+零回退+N2 minor）| 检查点 16/18-code-reviewer.md | progress Phase 4 | subagent-state/16、18-code-reviewer.md | rescue:22.7 换道 / 4 / ☑ |
| 15 | 16:55 | general-purpose | N2-fix+align-fix（三键同步+64.5 陈旧锚/枚举） | done | 两轮全过；23/23+20/20 保持 | 主进程 alignment 清单机械验证 | findings「N2-fix」「align-fix」回执 | subagent-state/19、20-executor.md | - / 0 / ☑ |
| 16 | 17:12 | general-purpose | Phase 4 收口 drift 检查 | done | ALIGNED：scope 9 文件一一对应零范围外 | 检查点 21 | Drift Log 17:12 行 | subagent-state/21-drift-checker.md | - / 0 / ☑ |
| 17 | 17:15 | general-purpose | dce10-fix 部署布局自适应 | done | +6/-1；A/B（CHANGELOG 缺席=SKIP）23/23 恒定 | 主进程部署位三处复跑 23/23 | findings「dce10-fix 回执」 | subagent-state/22-executor.md | - / 0 / ☑ |
| 8 | 13:33 | code-runner-agent(mini) | S6 全量回归+锚级联扫描 | done | 滞留 15min 零检查点 → TaskStop；主进程白名单③并行接管：60P/1F FAIL集=基线零新增 | /tmp/wt148-regression.txt+progress Phase 3 段 | progress「Phase 3」Test Results | （无检查点，主进程代账） | rescue:22.3③/④ 接管 / 1 / ☑ |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 触发信号: rule-enhancement 类（在册 variant rule-enhancement-type.md，v147 同族先例）
- Rule 34.3②: 沉淀预登记——rule-enhancement variant 已存在，无新类型沉淀；本任务沿用既有 variant，登记不沉淀理由=类型已在库
- 处置登记处: 本行即登记（check-complete T3 检索 [template-sense] 时对照）
