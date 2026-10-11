<!-- template_type: rule-enhancement -->
<!-- 任务书口径 template_type=rule-enhancement-type（文件名形态）；check-template-type.sh 机读白名单值=rule-enhancement（由 templates/variant/*-type.md 去 -type.md 派生） -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule 50「内容要求权重分级与评级」（Rule 50 条款 + 3 媒体 variant 模板消费点 + goal-gate VC 分级语义 + 新建 selftest 守护 + SKILL 联动；零新 config 键） -->
<!-- 沉淀出处: task-v074 沉淀 rule-enhancement variant；本任务为该 variant 第 N 次复用（v122 Rule 47 / v123 Rule 48 / v126 Rule 49 同套路） -->

# Task Plan: Rule 50 内容要求权重分级与评级（复合需求原子拆解 × 权重分级 × 分级评级）

<!-- plan_tier: standard -->
<!-- execution_lane: L1（新增 Rule 条款 + 模板消费点，38.7 明示不适用 L0） -->

## Goal
为 task-planner 技能增加「内容要求权重分级与评级」能力：对同时携带存在性约束与程度/强度约束的需求（如"人物脸上有泪痣"+"不注意看不到"）做属性拆解 × 权重分级 × 分级评级，杜绝验收只看存在性、忽略约束强度导致的人物/成品设计缺陷。

**解决的用户诉求（原话）**：「我同时存在两个要求：要求人物脸上有泪痣；不注意看不到。当前只关注有泪痣，完全忽略了后者（不注意看不到）。要求的限制大小被忽略导致人物设计缺陷」（"后期要钱的"按语音转写歧义=「后期要求的」，见 findings §Requirements）。

**缺陷本质（findings §Requirements）**：同一对象上的复合要求 = 存在性约束（有泪痣）+ 程度/强度约束（不注意看不到=显隐度/大小上限）；现行 VC 表达与 QC 判定双断链 → 生成侧为满足可检项把泪痣做显眼 → 成品缺陷。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含新建 .sh 守护脚本） |
| `session_id` | `<启动时生成，注册表追踪>` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v127` |
| `scope_files` | `skills/task-planner/references/critical-rules.md`, `skills/task-planner/SKILL.md`, `skills/task-planner/templates/variant/image-type.md`, `skills/task-planner/templates/variant/character-design-type.md`, `skills/task-planner/templates/variant/qc-defect-type.md`, `skills/task-planner/references/goal-gate.md`, `skills/task-planner/scripts/selftest-requirement-grading.sh`, `skills/task-planner/scripts/selftest-registry.tsv`, `skills/task-planner/scripts/selftest-plan-tier.sh`, `skills/task-planner/scripts/selftest-conclusion-discipline.sh`, `skills/task-planner/scripts/selftest-ask-default-timeout.sh` |
| `interaction_mode` | `ask`（用户显式 $task-planner 调用） |
| `对齐审查` | Phase 4 S9 对全部产出跑 alignment-review（Rule 42.6.2 标准收尾）；变更记录随交付落盘 |
| `自动超时默认项` | D1 权重刻度候选：默认项=候选 A（1-5 分×权重，仿 methodology.md:193-212 Q4），超时 5 分钟（Rule 44.1）；其余询问点低区分度直接裁决登记（44.2） |
| `质量审查工具` | Rule 42.2 四级检测：代码组面（新建 .sh）→ 用户级 `code-quality-review` skill 在位 → 终验 Code Review Gate 消费；文档面=alignment-review（review-library 池成员）Phase 4 消费 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Phase 4 fresh 会话复跑），主进程既有上下文自测不作为有效验收（Rule 33.3）。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 50 条款完整：`### 50 ` 标题 + 50.1-50.6 子条在位，范式对齐 49（子条动词短语，末条「机制」声明零新键+selftest）；既有 Rules 1-49 原文零改动（纯增量，Rule 36.5） | `grep -c '^50\.'` ≥6 + `git diff` 仅追加行 | `skills/task-planner/references/critical-rules.md`（文末 :520 后追加） |
| VC-2 | 零新 config 键：config.json properties 计数与基线一致（40） | `jq '.properties \| length'` 前后对比 | `skills/task-planner/config.json` |
| VC-3 | 原子验收条目表契约 + 泪痣样例在位：条目表四列 `\|条目\|类型:存在性P/程度E\|层级:硬约束H/评分项S\|权重\|判定刻度\|`；泪痣案例拆出 **P/H**（有泪痣=存在性·硬约束）与 **E/H**（不注意看不到=程度·硬约束）双条目，且带评级语义（PASS/PARTIAL/FAIL，程度条目双向判：过显眼=FAIL / 不可见亦=FAIL） | `grep` 条款+3 模板含 `P/H`、`E/H`、`双向` 锚 + Read 契约节 | `critical-rules.md`（Rule 50 块）+ 3 媒体 variant 模板 |
| VC-4 | 消费侧落点：3 媒体 variant 模板（image/character-design/qc-defect）各含「评级契约区块」=原子条目表+逐条评级+加权判定；`goal-gate.md` 含 VC 分级语义 1 行（二元三态之上补分级/加权形态） | `grep -l '原子验收条目\|逐条评级'` 三模板命中 + `grep '分级'` goal-gate | 3 模板 + `references/goal-gate.md` |
| VC-5 | SKILL.md 联动在位：frontmatter 全集 `1-49`→`1-50` + 摘要区 Rule 50 bullet + 媒体路由行消费点（Rule 47 路由行指向新评级契约）；净增 ≤10 行，`wc -l` 复核 | grep 锚 `1-50`/Rule 50 bullet/消费点 + `wc -l` | `skills/task-planner/SKILL.md` |
| VC-6 | 级联锚扩口径使 `1-50` 合法且全量回归 0 FAIL：`selftest-plan-tier.sh:78`(PT-08)、`selftest-conclusion-discipline.sh:66/69-70`(CD-11)、`selftest-ask-default-timeout.sh:66-69`(RT-08) 三锚同步（v121 预扩先例）；全量 selftest 逐脚本跑、逐 Total 行求和，FAIL=0（独立 fresh 会话复跑复核，禁采信执行期自报总数） | 三脚本单跑全 PASS + `for f in selftest-*.sh` 循环逐 Total 求和 + fresh 复跑 | `progress.md` Selftest Log / `verification.md` |
| VC-7 | 新建守护落地：`selftest-requirement-grading.sh` 全绿（RG-01..NN 静态断言：条款锚/泪痣双条目锚/三模板契约锚/零新键）+ `selftest-registry.tsv` 登记行（+1）在位 | 跑新 selftest 全 PASS + `wc -l selftest-registry.tsv` = 基线+1 | `scripts/selftest-requirement-grading.sh` + `scripts/selftest-registry.tsv` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required` → 终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 — 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `skills/task-planner/references/critical-rules.md`（文末 :520 后追加 Rule 50 块 ~25 行） | 改既有 Rules 1-49 任何语义（含 47 媒体派发 / 49 单元线） |
| SKILL | `skills/task-planner/SKILL.md`（**净增 ≤10 行**：frontmatter 索引字面 1-49→1-50、摘要区 Rule 50 bullet +1、媒体路由行消费点行内追加） | 大段新增；动行数上限断言 label 语义 |
| 模板 | `skills/task-planner/templates/variant/image-type.md`、`character-design-type.md`、`qc-defect-type.md`（各加「评级契约区块」，纯增量） | 改三模板既有 Phases/VC 语义 |
| 参考 | `skills/task-planner/references/goal-gate.md`（VC 分级语义 1 行，纯增量） | 改既有五条 VC 规则/退出标准语义 |
| 脚本 | `skills/task-planner/scripts/selftest-requirement-grading.sh`（新建）+ `selftest-registry.tsv`（+1 行）+ 级联锚扩口径三脚本 `selftest-plan-tier.sh` / `selftest-conclusion-discipline.sh` / `selftest-ask-default-timeout.sh`（仅锚宽容化，语义零改动） | 改其他脚本；反转越界断言语义 |
| 配置 | （不动 `config.json` —— 零新键，properties 保持 40） | 动任何既有键 |

**强制约束**:
- 新规则编号=**50**（接续当前最大 Rule；避让 task-v126 的 Rule 49——任务书撰写时 49 标 pending，现已落地 `critical-rules.md:506`；禁碰 48/49）
- ⚠️ **锚定级联防呆**：改 SKILL.md / critical-rules.md 前先 `grep -rn "1-4\[5-9\]\|Rules 1-" skills/task-planner/scripts/selftest-*.sh` 复扫锚断言；三锚因 `1-50` 落体的真实级联=PT-08 `1-4[5-9]` **不匹配** "1-50"（0 命中→bad）、CD-11 计数下降、RT-08 天然不命中（`1-4[0-9]` 不含 "1-4"）；只按 v121 宽容化先例处置（扩为覆盖 1-50），禁改断言语义掩盖问题
- 派发契约：executor prompt 必含计划三文件路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）；单会话单 S-unit（Rule 46.1）；S-unit 表 ID 纯数字、输入列路径 token ≤2、预估时长 NNmin 格式
- 禁触碰既有簿记残留（`plans/task-v116/subagent-state/.dispatch-inflight`、`plans/task-v118/`、`plans/task-v121/`、`plans/task-v124/` 等，他任务资产）；禁触碰 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v124`
- ⚠️ **并行会话在途（2026-10-04 实测）**：v126 已落地 Rule 49（:506-520）；v129（他会话）正在落地 Rule 51；v124（他会话）in_progress 建图像/视频执行体。S1 执行前 `grep -n '^### 49\|^### 51'` 复锚——**Rule 50 块必须插在 Rule 49 块之后、任何 ### 51 块之前**（禁止盲目 EOF 追加）；S2 字面自适应——SKILL.md:9 现值「1-49」→ 改「1-50」，若已被 v129 改为「1-51」则保持 1-51 仅在枚举括注补「50 内容要求权重分级与评级」；合并冲突按 worktree-isolation 合约处理，禁 reset/force

**执行前自我检查:**
- [x] 文件在范围内列表中
- [x] 修改对完成任务必要
- [x] 用户显式要求本能力（2026-10-04 原话）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/行号） | 必读级别 | 已确认 |
|------|-----------|-------------------|---------|--------|
| 项目内部 | Rule 47/48/49 尾部范式（新规则块写法） | `skills/task-planner/references/critical-rules.md:484-520` | 必读 | ☑ 计划期已读 |
| 项目内部 | 仓内既有加权评分先例（Q4 五维评分卡） | `skills/task-planner/references/methodology.md:193-212` | 必读 | ☑ 计划期已读 |
| 项目内部 | Rule 47 媒体派发纪律现文（消费点挂载面） | `skills/task-planner/references/critical-rules.md:484-494` | 必读 | ☑ 计划期已读 |
| 项目内部 | 媒体族模板结构与挂载位 | `skills/task-planner/templates/variant/{image,character-design,qc-defect}-type.md` | 必读 | ☑ 计划期已读骨架 |
| 项目内部 | 级联锚断言现状（PT-08/CD-11/RT-08） | `scripts/selftest-plan-tier.sh:77-78`、`selftest-conclusion-discipline.sh:66-70`、`selftest-ask-default-timeout.sh:60-70` | 必读 | ☑ 计划期已读 |
| 项目内部 | selftest 静态守护范式 | `skills/task-planner/scripts/selftest-media-dispatch.sh` | 参考 | ☐ S5 执行期读 |
| 项目内部 | 外部图像链 QC 现状（六缺口） | findings.md §[sub:02-explore] / `subagent-state/02-explore-skills.md` | 参考 | ☑ 计划期已读 |
| 用户宪法 | §一子代理路由 / §六技能保护 / §十一 worktree | `~/.zcode/AGENTS.md` | 必读 | ☑ |

**填写规则**：① `定位` 可唯一定位（路径+行号）；② `必读` 项缺失 → 停止并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（任务开始前必答）

**核心问题**: 复合内容要求（存在性约束 + 程度/强度约束）在 task-planner 的计划期与 QC 判定期**双断链**——VC 只做存在性二元判定、QC 输出二值 APPROVED/CHANGES_REQUESTED，程度约束（"不注意看不到"）既无条目化表达、无权重分级、无分级评级 → 生成侧为满足可检项放大显眼度 → 成品设计缺陷。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付（复合需求获原子条目表 + 权重分级 + 双向分级评级，QC 逐条判定可机读）
- [x] 核心问题不解决，程度约束持续被忽略，成品缺陷复现（用户诉求不满足）
- [x] 解决方法清晰可执行（Rule 50 条款 + 3 模板消费点 + goal-gate 分级语义 + 新建静态 selftest，纯增量零新键）

**如果无法回答核心问题，禁止开始任务！**

## Current Phase
交付完成（5/5 Phase complete，outcome=COMPLETE）

## Next Step
[无——任务已交付；后续消费点=v124 执行体 QC 工序挂接 Rule 50 条目表（50.5 预留）]

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（全量 selftest 基线）+ git 编排 | 基线定数须主进程留痕可追溯；worktree=白名单① |
| Phase 2 | 主进程（计划系统文件维护） | Rule 25.3 白名单②；本规划即本 Phase 产出 |
| Phase 3 | Agent 子代理 executor(sonnet-1) ×7（S1-S7，可声明并行组） | 条款/模板/脚本判断型产出；S1-S7 文件集不相交、输入只读共享、验收独立——Rule 21.4 四问通过 |
| Phase 4 | code-runner-agent(mini) + executor(fresh) | 机械全量回归与独立验证分档（Rule 33.3 验证独立性） |
| Phase 5 | git 编排 + smart-merge-back --deploy | 合并部署 3 实体位=白名单①② |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——短链串行为主，Phase 3 内 S1-S7 各领独立会话（Rule 46.1 单会话单 S-unit），无需 CreateWorkflow
**/goal 对齐（Rule 40.3）**: 用户未用 /goal 锚定；本计划 Goal+VC 即会话目标证据源

## 📐 Rule 50 设计契约（执行期 S-unit 材料源；条款文本以本契约为草案基线）

> 定位：本区块是 S1-S5 的执行材料基线（草案摘要），执行期由 executor 依此细化落盘；条文体例对齐 47/48/49（`### NN 标题` + `NN.M **子条名（…）**：…`）。

**50.1 原子验收条目表结构**：计划期把内容/媒体类复合需求拆为原子验收条目表，每条四列机读：
`| 条目 | 类型 | 层级 | 权重 | 判定刻度 |`，其中 类型 ∈ {存在性 P, 程度 E}，层级 ∈ {硬约束 H, 评分项 S}。

**50.2 程度约束词显式成条 + 默认 H**：程度类约束词（不注意看不到 / 不明显 / 轻微 / 小 / 淡 / 低调 / 含蓄）必须显式落为 E 类条目，禁止并入存在性条目；未标注层级时默认 **H**（用户写进要求 = 硬约束，防再次忽略）。

**50.3 逐条评级（PASS/PARTIAL/FAIL）**：每条按判定刻度评级；**程度条目双向判**——过显眼（超上限）→ FAIL，过小到不可见（低于下限）→ 亦 FAIL（同时违反存在性条目），落在目标区间 → PASS。

**50.4 加权判定**：`全 H 过 + S 加权 ≥阈值`；阈值/权重刻度仿 `methodology.md:193-212` Q4 五维评分卡先例（各 1-5 分 × 权重，加权总分 + 三档阈值）。H 类任一 FAIL = 整体 FAIL，不受 S 加权补偿。

**50.5 QC 链消费**：条目表随任务书派发；image-understand 对生成产物**取证**（描述图中特征）后逐条评级，image-review 沿用其质量门，二者的判定输入由本条产出的机读条目表提供——补「需求清单 + 生成产物 → 逐需求判定」编排层断链（findings §[sub:02-explore] 六缺口之⑥）。

**50.6 机制（零新 config 键 — 与 43.4/44.4/47.4 同范式）**：判定面=LLM 行为（计划期条目化/分级/评级，非机器触发）；机器面=`scripts/selftest-requirement-grading.sh` 静态断言（50.1-50.6 子条文本锚 + 泪痣双条目锚 + 三模板契约锚 + 零新键）；SKILL.md 摘要/路由消费点锚。既有 Rules 原文零改动。

**样式样例（泪痣案例 — P/H + E/H 双条目，VC-3 判定对象）**：

| 条目 | 类型 | 层级 | 权重 | 判定刻度 | 评级语义 |
|------|------|------|------|---------|---------|
| 人物脸上有泪痣 | **P**（存在性） | **H**（硬约束） | 必过 | 有=1 / 无=0 | 无泪痣 → FAIL；有泪痣 → PASS |
| 泪痣不注意看不到（显隐度上限） | **E**（程度） | **H**（硬约束） | 必过 | 显隐度刻度（0=不可见 … 5=极显眼），目标区=不显眼 | 过显眼 → **FAIL**；低到不可见 → **FAIL**（连带违反上行 P 条目）；目标区 → PASS |

## Phases

### Phase 1: Requirements & Discovery
- [x] Understand user intent（泪痣案例复合要求缺陷，findings §Requirements）
- [x] Identify constraints and requirements（Rule 编号避让/零新键/媒体族落点）
- [x] Document findings in findings.md（§Requirements + §Research Findings 双 explore 结论）
- [x] 知识储备必读项已确认可获取（勾选「必要知识储备」表"已确认"列）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单；发现阶段调研由 explore 执行，见 Handoff #1/#2）
- **Evidence:** findings.md §Requirements/§Research Findings；`subagent-state/01-explore-repo.md` + `02-explore-skills.md`（均 status: done）

### Phase 2: Planning & Structure
- [x] Define technical approach（Rule 50 设计契约：50.1-50.6 + 泪痣双条目样例）
- [x] Create project structure if needed（scope_files/隔离决策/S-unit 拆分）
- [x] Document decisions with rationale（Decisions Made 表 D1-D6）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）
- **Evidence:** 本文件（VC 表 + Rule 50 设计契约 + S-unit 表）；knowledge-brief.md 五段；用户 yes 批准 2026-10-04（attest 锁定见 progress）
<!-- 本 Phase = 本次 plan-writer 规划动作，产出 task_plan.md + knowledge-brief.md 后即 complete -->

### Phase 3: Implementation
- [x] 落 Rule 50 条款块 + SKILL 联动 + 3 模板消费点 + goal-gate 分级语义（S1-S4 波 1，commit 211f59d）
- [x] 新建 selftest-requirement-grading.sh + registry 登记 + 三锚扩口径（S5-S7 波 2，commit 见 worktree log）
- [x] 逐 S-unit 交回主进程验收后派下一个（Rule 46.1 单会话单 S-unit；并行组分两波各验收后派发）
- **V-N:** VC-1, VC-3, VC-4, VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** executor（sonnet-1）
- **Evidence:** worktree commits 211f59d+波2；findings §[sub:wave1-impl]；主进程第一手复核（Rule 50 条款全文 Read、SKILL 三锚 grep、新 selftest 7/7 rc=0 亲跑、registry 47 行、PT-08/CD 32/0+24/0）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | `critical-rules.md` 文末追加 Rule 50 块（50.1-50.6，含原子条目表+泪痣样例+加权阈值+程度双向判+机制） | 继承 | `plans/task-v127/task_plan.md`（§Rule 50 设计契约全文）；`skills/task-planner/references/critical-rules.md`（插入点=:520 文末） | `grep -c '^50\.'` ≥6；`git diff` 仅追加；既有 1-49 零改动 | 15min | done |
| S2 | `SKILL.md` 联动：frontmatter 1-49→1-50 / 摘要 Rule 50 bullet / 媒体路由行消费点 | 继承 | `plans/task-v127/task_plan.md`（联动草案）；`skills/task-planner/SKILL.md`（frontmatter :9 / 摘要区 / 路由表媒体行） | grep 锚 1-50+bullet+消费点各≥1；净增 ≤10 行且 wc -l 复核 | 10min | done |
| S3 | 2 媒体模板各加「评级契约区块」（原子条目表+逐条评级+加权判定） | 继承 | `skills/task-planner/templates/variant/image-type.md`；`skills/task-planner/templates/variant/character-design-type.md`（各挂 VC 段后/Phases 前） | 两文件 grep 锚「原子验收条目」+「逐条评级」命中；既有 Phases 零改动 | 8min | done |
| S4 | `qc-defect-type.md` 加评级契约区块 + `goal-gate.md` 加 VC 分级语义 1 行 | 继承 | `skills/task-planner/templates/variant/qc-defect-type.md`；`skills/task-planner/references/goal-gate.md`（:13 退出标准后纯增量） | 两文件 grep 锚命中；goal-gate 既有五规则/三态零改动 | 8min | done |
| S5 | 新建 `selftest-requirement-grading.sh`（RG-01..NN 静态断言）+ registry 登记行 | 继承 | `skills/task-planner/scripts/selftest-requirement-grading.sh`（新建）；`skills/task-planner/scripts/selftest-registry.tsv`（表尾 +1 行） | 新脚本运行全 PASS；registry 行数=基线+1（46→47 行含表头） | 15min | done |
| S6 | 扩 PT-08/CD-11/RT-08 三锚口径使 `1-50` 合法（宽容化，语义零改动） | 继承 | `skills/task-planner/scripts/selftest-plan-tier.sh`；`skills/task-planner/scripts/selftest-ask-default-timeout.sh` | 两脚本单跑全 PASS；PT-08 命中 "1-50"；RT-08 越界仍 0 | 12min | done |
| S7 | 扩 CD-11 锚口径（`1-4[5-9]` 计数含 `1-50`） | 继承 | `plans/task-v127/task_plan.md`（级联说明）；`skills/task-planner/scripts/selftest-conclusion-discipline.sh`（:66-70） | 脚本单跑全 PASS；`1-3[5-9]`+`1-4[5-9]`/`1-50` 合计 ≥3 | 10min | done |

<!-- parallel_groups: [S1,S2,S3,S4,S5,S6,S7]（Rule 21.4 声明制；文件集两两不相交、输入=task_plan.md 只读共享、验收各自独立 → 四问通过；组内各=独立 Agent 会话各领 1 行，Rule 46.1 合规） -->

### Phase 4: Testing & Verification（全量回归 + 独立验证）
- [x] 全量 selftest 回归（46 脚本逐跑：687+22 PASS / 1 FAIL→S10 修锚后 **709/0**，commit 3e782f4）
- [x] fresh 独立会话复跑（S9：4 脚本逐字一致 + alignment-review APPROVED）
- [x] 全部产出跑 alignment-review + 变更记录落盘（APPROVED P0=0 P1=0；checkpoint 12-s9-verifier.md）
- **V-N:** VC-6, VC-7
- **Status:** complete
- **Executor:** code-runner-agent（mini）+ executor（fresh）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S8 | 全量 selftest 回归（逐 Total 求和，新增 FAIL 定位：锚过窄→v121 宽容化 / 内容越界→回炉） | code-runner-agent(mini) | `plans/task-v127/progress.md`（Phase 1 基线段）；`skills/task-planner/scripts/`（selftest-*.sh 全集） | 总 FAIL=0 且总数=基线+1 新脚本；留痕 progress.md | 15min | pending |
| S9 | fresh 会话复跑新脚本 + 抽 3 既有脚本独立确认 + alignment-review 对齐审查 | executor(fresh) | `plans/task-v127/verification.md`（VC 表）；`skills/task-planner/scripts/selftest-requirement-grading.sh` | fresh 复跑 0 FAIL 留痕；alignment-review APPROVED + 变更记录 | 15min | pending |

### Phase 5: Delivery（合并回 + 部署 + 簿记）
- [x] Code Review Gate（S11 隔离审查 4 个 .sh diff → **APPROVED**，零 P0/P1）
- [x] master 合流（v129 Rule 51 撞点：4 文件冲突解=50/51 并存+1-51 纪元+registry 双保留+锚 452；合流级联 5 脚本 S12 修复归零）→ `smart-merge-back` → **merged(38e562e)**；部署 3 位全 IDENTICAL（zcode 运行位自保护 REJECTED→按 SOP 手动 rm+cp 后 0 差异）
- [x] worktree 清理（remove+branch -d 完成）+ INDEX/ledger 簿记 + 记忆沉淀 + 主仓 Read 复验（:522 Rule 50/`^50.`=6/config 40/registry 48 行全过）
- **V-N:** VC-2, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排 + ② 计划系统簿记——Rule 25.3 白名单；CR/合流修复面派子代理 S11/S12）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号① 未提交变更均 `plans/` 簿记残留（v116/v120/v122/v123 及未入库 v118/v121/v124/v125/v128/v129），与技能源码 scope 零重叠；信号②③④⑤ 无） |
| `isolation` | `worktree`（技能文件=保护区 + 宪法 §十一 P0 强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v127` |
| `branch` | `wt/task-v127` |
| `merge_back` | `merged(38e562e)`（2026-10-04，含 master 合流 7b356e5+合流级联修复 4ef8ec8；部署 3 位 IDENTICAL） |

> 契约详见 `skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（对齐 22.3 ①-⑤） |
|-------|---------|---|---|---|-----|-----------------------------|
| Phase 3 | 文末插入点漂移（master 前进致 :520 行号变化） | 4 | 3 | 3 | 36 | 插入前 `grep -n '^### 49'` 复锚，漂移则重新定位（v120 基线漂移复测范式） |
| Phase 3 | 级联锚扩口径后回归 FAIL（`1-50` 未被 `1-4[5-9]` 覆盖） | 6 | 4 | 4 | 96 | 区分锚过窄 vs 内容越界：锚过窄→v121 宽容化（扩为覆盖 1-50，语义零改动）；内容越界→22.3 拆细回炉 |
| Phase 4 | 全量回归未知 FAIL / fresh 复跑不一致 | 6 | 4 | 4 | 96 | 对照 Phase 1 基线定位；新增 FAIL 走 22.3 拆细或锚宽容化；基线既有 FAIL 如实登记不越界硬修 |
| Phase 5 | 部署位 diff≠0 / 合并冲突 | 7 | 3 | 3 | 63 | 停止推进，Read `smart-merge-back` 输出定位；22.3.0 先查脚本头注文档再动 |

（全部 RPN ≤100，兜底已预登记）

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-04 计划创建 | 已完成 |
| Phase 2 | ☑ | 2026-10-04 计划创建 | 本规划 Phase |
| Phase 3 | ☐ |  | S1-S7 逐 S-unit 派发时同步 |
| Phase 4 | ☐ |  | |
| Phase 5 | ☐ |  | |

> 契约详见 `skills/task-planner/references/todo-sync.md`。

## Key Questions
1. Rule 50 编号？→ 取 **50** 接续最大 Rule，避让 task-v126 的 Rule 49（任务书撰写时标 pending，现已落地）；不动 48/49。
2. 权重/评分刻度以何为先例？→ `methodology.md:193-212` Q4 五维内容评分卡（1-5 分 × 权重，加权总分 + 三档阈值），仓内唯一成熟加权评分形态。
3. 程度条目如何判？→ 双向判：过显眼 FAIL / 过小不可见同样 FAIL；H 类任一 FAIL = 整体 FAIL。
4. 是否新增 config 键？→ 否。判定面=LLM 行为，机器面=新建静态 selftest（v122/v123 先例，properties 保持 40）。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| D1 Rule 号=**50**，落 critical-rules.md 文末（:520 后） | 接续当前最大 Rule；避让 task-v126 的 Rule 49（任务书撰写时 49 标 pending，现 `:506` 已落地）；禁碰 48/49 |
| D2 **零新 config 键**（静态 selftest 守护，v122/v123 先例） | 50.6 判定面=LLM 行为，非机器触发；机器面挂 `selftest-requirement-grading.sh`；`config.json` 不入 scope，properties=40 守自 |
| D3 **SKILL.md 净增 ≤10 行**（行位替换优先） | 行数纪律；改 frontmatter 字面 1-49→1-50 + 摘要 bullet + 路由消费点，全部行内/单行追加 |
| D4 评级规范落 **task-planner 编排层**，不新建技能 | findings §[sub:02-explore] 裁定：下游 image-understand（取证）/image-review（质量门）被新 SOP 消费，补的是编排层断链，不重复造轮子 |
| D5 权重/评分形态仿 **methodology.md:193-212 Q4 五维评分卡** | 仓内既有加权评分先例（权重表 + 加权总分 + 三档阈值），新机制直接对齐用户熟悉形态 |
| D6 隔离=**worktree**（宪法 §十一 P0） | 技能文件为运行中基础设施，多会话实时加载 |
| D7 三媒体模板 + goal-gate 作消费点（纯增量） | 媒体族=用户缺陷高发面；goal-gate VC 分级语义补二元三态之上的分级形态；纯增量免语义改写确认 |
| D8（B 类扩围 2026-10-04 Phase 4 实测）`selftest-skill-split.sh` T-主 行数锚 449→450 联动 | S2 使 SKILL.md 449→450 行，S8 全量回归暴露该锚 FAIL（558 钉上限未破=锚过窄非内容越界）；v126 同款机制级联（440→442→444→447→449→450）；FMEA Phase 4 兜底预登记路径；扩围文件=`skills/task-planner/scripts/selftest-skill-split.sh`（仅锚数字+label） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| Plan Writer(sonnet-1) 启动失败 reasoning-level-missing | 1 | Rule 22.3① 改派 general-purpose（继承会话模型）执行同一落盘任务书 03-prompt.md | → progress.md Error Log（provider 失败族 F5；优先继承会话模型执行体） |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions（attention manipulation）
- Log ALL errors - they help avoid repetition
- Phase 1/2 为 主进程直做（白名单②），Phase 3/4 委派子代理；委派率见「委派统计」（白名单豁免口径）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-04 01:58 | ✅ ALIGNED（Phase 1 后：仅动 plans/task-v127/** + INDEX，白名单②；调研产出直接服务 Goal；无计划外文件） | VC-1, VC-3 | 继续 Phase 2 |
| 2026-10-04 03:0x | ✅ ALIGNED（Phase 3 后：实现全在 worktree scope 内 10 文件；计划三文件正常回填；Rule 50/SKILL/模板/脚本与 VC-1/3/4/5/7 一一对应） | VC-1,3,4,5,7 | 继续 Phase 4 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（Phase 3/4；Phase 1 已完成、Phase 2 本规划、Phase 5 合并簿记） |
| 主进程直做 Phase 清单 | Phase 1（白名单② 计划系统文件维护，调研子任务见 Handoff #1/#2）、Phase 2（白名单② 本规划）、Phase 5（白名单①② git/部署/簿记） |
| 委派率 | 0.4 < 0.7 → **WHITELIST-EXEMPT 放行**（直做理由全命中 Rule 25.3 ①②；终验前以 check-delegation 实测为准） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-04 | explore | 调研仓内 task-planner 需求/VC/媒体 QC 面与 Rule 编号现状 | done | 最后 Rule=48(:504)；Rule 47 无 QC 评级语义；Q4 五维评分卡=既有加权先例(methodology:193-212)；PT-08/CD-11/RT-08 三锚需为 Rule 50 扩口径；variant 含媒体族模板 | critical-rules.md:496,504; methodology.md:193-212; selftest-plan-tier.sh:78 | Research Findings §[sub:01-explore] | /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/01-explore-repo.md | guard 拦截重派/1 重试/☑ |
| 2 | 2026-10-04 | explore | 调研 ~/.zcode/skills 图像审查/生成类技能的评级能力现状 | done | 7 技能无需求清单驱动判定；image-review 二值+P0/P1/P2 缺陷级；六缺口（结构化/程度/权重/刻度/契约/断链）；落点=task-planner 编排层 | image-review:9,43-46; prompt-master:60,237,317 | Research Findings §[sub:02-explore] | /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/02-explore-skills.md | 无产出重派/1 重试/☑ |
| 3 | 2026-10-04 | plan-writer | 撰写 task-v127 正式 task_plan.md + knowledge-brief.md（Rule 50） | done | 任务书 §3 四条验收全过；产出 task_plan（VC 7 条含泪痣 P/H+E/H 双条目）+ knowledge-brief 五段 | plans/task-v127/task_plan.md; plans/task-v127/knowledge-brief.md | -（不动 findings） | /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/03-plan-writer.md | 原 plan-writer(sonnet-1) provider 失败→Rule 22.3①改派 general-purpose / 1 / ☑ |
| 4 | 2026-10-04 | executor | S1 Rule 50 条款块落 worktree critical-rules.md | done | +23 行纯增量（:522 起，50.1-50.6+溯源段+泪痣样例表）；既有 1-520 行零改动 | worktree critical-rules.md:522-544; grep '^50\.'=6 | findings §[sub:wave1-impl] | .../subagent-state/04-s1-executor.md | - / 0 / ☑ |
| 5 | 2026-10-04 | executor | S2 SKILL.md 三处联动 | done | :9 全集 1-50+:285 bullet+:359 路由消费点；净增 1 行；1-39 计数锚零变化 | worktree SKILL.md:9,285,359 | findings §[sub:wave1-impl] | .../subagent-state/05-s2-executor.md | - / 0 / ☑ |
| 6 | 2026-10-04 | executor | S3 image/character-design 两模板评级契约区块 | done | 各 +12 行纯追加（VC 后/Phases 前）；锚词全命中 | worktree 两模板 numstat 12 0×2 | findings §[sub:wave1-impl] | .../subagent-state/06-s3-executor.md | 任务书跨 S-unit 引用被拦→修后重派 / 1 / ☑ |
| 7 | 2026-10-04 | executor | S4 qc-defect 模板区块+goal-gate 分级语义行 | done | qc-defect :28 +12 行；goal-gate :18 +1 行（既有 17 行零改动） | worktree qc-defect-type.md:28; goal-gate.md:18 | findings §[sub:wave1-impl] | .../subagent-state/07-s4-executor.md | 同上 / 1 / ☑ |
| 8 | 2026-10-04 | executor | S5 新建 selftest-requirement-grading.sh+registry | done | RG-01..07 全 7/7（主进程亲跑 rc=0）；registry 46→47 | 检查点 08+worktree registry:47 | findings §[sub:wave1-impl] 守卫实测段 | .../subagent-state/08-s5-executor.md | 子代理返回异常但产出完整，一手验收采信 / 1 / ☑ |
| 9 | 2026-10-04 | executor | S6 PT-08 锚扩窗+RT-08 旁证 | done | plan-tier 基线 31/1→32/0；ask-timeout 零改动 9/0 | 检查点 09-s6 | progress Phase 3 Test Results | .../subagent-state/09-s6-executor.md | - / 0 / ☑ |
| 10 | 2026-10-04 | executor | S7 CD-11 锚扩窗 | done | 改前 23/1→改后 24/0（Total 24 不变） | 检查点 10-s7 | progress Phase 3 Test Results | .../subagent-state/10-s7-executor.md | - / 0 / ☑ |
| 11 | 2026-10-04 | code-runner→executor | S8 全量 46 selftest 回归 | done | 687+22 PASS/1 FAIL（skill-split 449 锚过窄）→S10 修后 709/0 | 检查点 11-s8（46 Total 行原文） | progress Phase 4 | .../subagent-state/11-s8-runner.md | code-runner provider 拒绝→22.3① 改派 executor / 1 / ☑ |
| 12 | 2026-10-04 | executor | S9 fresh 复验+alignment-review | done | 4 脚本逐字一致；APPROVED（P0=0 P1=0）；变更记录三要素入 checkpoint | 检查点 12-s9 | progress Phase 4 | .../subagent-state/12-s9-verifier.md | - / 0 / ☑ |
| 13 | 2026-10-04 | executor | S10 skill-split 锚级联 449→450 | done | 40/1→41/0（1+/1-，主进程亲跑复验）；演进链 +450 | 检查点 13-s10 | progress Phase 4 | .../subagent-state/13-s10-executor.md | B 类扩围 D8 / 0 / ☑ |
