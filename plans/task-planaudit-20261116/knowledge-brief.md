# Knowledge Brief — task-planaudit-20261116（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；本文件为计划期 plan-writer 产出，R1 修订后增量更新 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：为 task-planner 技能在 L1+ 计划产出后、D1 前增加独立子代理审计迭代门（分档、可观察达标判据、留痕、降级/升级出口），并将“未经审计产出禁交用户”原则（已识别覆盖面非穷尽，未列面默认简版复核）增量贯彻到全流程审核面。
- 背景/动机：消除主上下文分析偏差导致的不合理计划直达用户，并确保任何需审核产出在交付前经独立审计保障完整性与可靠性；同时按比例原则避免轻量任务仪式膨胀。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 计划独立审计门（plan-audit gate） | L1+ 计划进入 D1 用户审核前由独立子代理在独立上下文复核合理性，不通过则打回修正再审直到达标；钉死插入点=智能子动作完成后、D1 展示前 |
| D1（计划确认门） | SKILL.md 中计划展示后等待用户授权/确认并 attest 锁定的门控点；审计门不适用 44.3 自动通过（未达标禁自动放行） |
| 审计分档（比例原则） | L1+ 强制审计门；mini/L0/trivial 轻量复核或登记豁免；L0-E 豁免（对齐 SKILL.md:51,57） |
| 达标判据与裁决转换 | 达标=0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）⇒APPROVED，否则 REJECTED（审计体出具，REJECTED 附问题清单；主进程只登记不自判） |
| 升级出口与降级链 | 争议→decision-arbiter；连续≥3 轮无实质进展→呈报用户裁决；审计体不可用：critic→重试1→decision-arbiter→general-purpose→AskUser（逐级留痕） |
| 固定留痕 | `progress.md [plan-audit-R<N>]` 固定段，字段=轮次/审计体/结论/问题清单/修复对照（R1 已为首例） |
| critic | 用户级审计 agent（`/home/terry/.zcode/agents/critic.md`），触发词含“审查计划/review文档”，只读挑刺输出报告 |
| decision-arbiter | 判断裁决子代理（Rule 69.1），用于方案/审查/CR 分歧等裁决（含 T6） |
| 全流程审核面（已识别，非穷尽） | 计划面、执行产物面、终验面、报告/总结面、上抛裁决面为已识别面；未列面按总则默认适用简版独立复核+判定规则 |
| 文本优先铁律 | 规则/偏好落入指令载体即完成；新增脚本/hook/守卫/selftest/机器门属范围扩张，未经用户显式要求禁实施 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 当前计划制作循环在首动作委派后为“主进程盘上复核→计划确认(D1)展示/授权”，无 D1 前独立审计迭代步骤 | `skills/task-planner/SKILL.md:50-75`（[A] 初始化首动作委派/边界/收据）与 `:61-75`（智能子动作、[A] 计划确认/D1 门控、attest） | R1 缺口明确：需在智能子动作完成后、D1 展示前插入 `计划独立审计门` 并阻断未审计计划展示 |
| critic agent 明确支持计划/文档审查且为只读挑刺体（含“审查计划”“review文档”触发） | `/home/terry/.zcode/agents/critic.md:4-6,23-69` | 可作为计划审计门主审计体；修正由主进程驱动 Plan Writer 重派执行，critic 不改文件 |
| 执行产物已有双轮质检机制（自审+全新子代理独立复检，升档与简洁任务书） | `skills/task-planner/SKILL.md:118`（3h Rule 103）；`:142,247`（终验衔接与全集索引含 Rule 103） | 执行产物面为已识别覆盖，可映射 Rule 103；需声明与计划审计门边界不叠加 |
| 终验与子代理验证已有 verification-gate/Rule 84、Rule 108 链路 | `skills/task-planner/SKILL.md:139-145,247,262,267`；卫星路由 `:243` | 终验面为已识别覆盖，需在全流程原则中映射独立验证证据要求 |
| CR 分歧与裁决分歧已有 decision-arbiter/Rule 69 触点 | `skills/task-planner/SKILL.md:129`（CR 分歧 Rule 69.1 T6→decision-arbiter）；`:247`（Rule 108/69 索引） | 上抛裁决面为已识别覆盖；审计争议/无进展升级出口可复用 decision-arbiter/用户裁决 |
| 活跃代码库当前无 Rule 109 定义；判别性专有 token 基线为 0（改动前） | 计划期 grep：`skills/task-planner/references/*.md` 无 `^### 109`；`SKILL.md`/`references` 无 `计划独立审计门`、`audit-before-delivery`；命中仅 `plans/archive/task-initdelegation-20261115/*` 历史记录 | VC-1/3/4 具判别性；新增 Rule 109 增量编号执行期按 Rule 20.6 reserve/land |
| 规则/流程变更默认增量，文本优先，机器面扩展需显式授权 | `skills/task-planner/SKILL.md:26`；Rule 74/82 口径见 `references/critical-rules.md:176-182`；宪法文本优先铁律 | 落地策略：SKILL/critical-rules 文本增量为主；selftest/attest 接线列 CA-6 待授权候选 |
| R1 独立审计已实证 REJECTED 且留痕在位（门控首例） | `plans/task-planaudit-20261116/progress.md:102-123`（`[plan-audit-R1]`：18 发现 B2/M7/m9，修复对照=打回修订） | VC-2/VC-6 首例证据；负向验证“未达标阻断进入 D1”成立；最终达标轮复审待执行（如 R3） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `skills/task-planner/SKILL.md` | `:38-59` | 计划制作循环：[M] 初始化与 [A] 初始化首动作委派（Plan Writer 产出、盘上复核、主代理职责收窄） |
| `skills/task-planner/SKILL.md` | `:61-75` | 初始化智能子动作（冲突分析/Spec 判定）与 [A] 计划确认（D1 授权/attest/目标绑定）——`计划独立审计门` 插入钉死区间（智能子动作完成后、D1 展示前） |
| `skills/task-planner/SKILL.md` | `:118,129,142` | 执行期 3h Rule 103 双轮质检、CR 分歧→decision-arbiter（:129）、终验衔接 Rule 103/84 |
| `skills/task-planner/SKILL.md` | `:170-184` | 合规检查清单 G1-G10——需对齐“L1+ 计划审计通过”前置（执行期落地） |
| `skills/task-planner/SKILL.md` | `:247,256-259` | Critical Rules 指针与 Rule 103/84/108/80/81 等摘要索引——新增 Rule 109 时需同步 |
| `skills/task-planner/references/critical-rules.md` | `:1-10` | 核心域定义与核心在位规则清单（当前 14 条：1,2,3,5,19,20,26,51,62,66,80,81,82,83；证据锚见 `:180` 边界段） |
| `skills/task-planner/references/critical-rules.md` | `:140-208` | Rule 80/81/82/83 尾段与卫星路由索引——追加 Rule 109 `audit-before-delivery` 的邻接范式与索引同步位置参考 |
| `skills/task-planner/references/critical-rules.md` | `:176-182` | Rule 82 建制/边界/回归防线——Rule 109 归属定稿依据（计划制作域条款+全流程总则可入核心，跨域细则引用卫星） |
| `/home/terry/.zcode/agents/critic.md` | `:1-70` | critic 定位、触发词（含审查计划/review文档）、输出/证据/禁止行为（只读不改）——计划审计主执行体 |
| `plans/task-planaudit-20261116/progress.md` | `:102-123` | `[plan-audit-R1]` 固定留痕段——R1 REJECTED 首例、18 发现与修复对照（F17 引用） |
| `plans/task-planaudit-20261116/user-session-log.md` | `:11-16` | R1-R3 用户原话与理解镜像——需求权威锚（Rule 80/51） |

## §4 易错点与禁止假设清单
1. 禁止在 D1 前“展示计划给用户”作为审计替代；L1+ 计划独立审计必须 APPROVED 后才可进入 D1（R1 不变量）。审计门不适用 44.3 自动通过。
2. 禁止将 critic 审计结论等同于修正执行：critic 只读不改文件（critic.md:65）；修正由主进程驱动 Plan Writer 重派，遵守计划期单写者与 22.4a/62.2 边界。
3. 禁止把“未经审计产出禁交用户”落成空泛口号或封闭枚举；必须总则+已识别覆盖面（非穷尽）映射，并声明未列面默认简版独立复核+判定规则（Rule 103/84/108/69/新增门）。
4. 禁止未经用户显式授权新增 selftest/attest/脚本门控（文本优先铁律）；CA-6 仅为候选，D1 未授权不得实施。
5. 禁止改写既有规则语义（Rule 74）：Rule 109 与 SKILL 变更必须增量；归属先定稿再冻结 VC-4；索引/计数与实际条款一致，避免漂移。
6. 审计迭代须有可观察达标判据与固定留痕；争议→decision-arbiter，连续≥3 轮无实质进展→呈报用户裁决，禁止静默卡死或自判达标。
7. 再展示/修订重审须过审计门（可简版：仅审变更增量+上轮问题清单闭环）；103 与计划审计门边界不叠加。
8. VC-1/2/3 实施时必须保留判别性（专有 token + 基线负断言记录），防基线即 PASS 伪绿。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 1 覆盖误判」「Phase 2 协议冲突」「Phase 3 门控破坏顺序/44.3冲突」「Phase 4 规则漂移」「Phase 5 伪覆盖/R2未达标推进」各行

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1-S1 | §1, §2, §3 | `skills/task-planner/SKILL.md`（:38-75, :61-75） |
| P1-S2 | §1, §2, §3, §4 | `/home/terry/.zcode/agents/critic.md`；`skills/task-planner/SKILL.md`（:118,129,142,247）；`skills/task-planner/references/critical-rules.md`（:194-208 卫星索引） |
| P1-S3 | §2, §3, §4 | `skills/task-planner/references/critical-rules.md`（:1-10, :140-208, :176-182）；全仓 grep Rule 109/专有 token 基线（执行期复核） |
| P3-S1 | §1, §2, §3, §4 | `skills/task-planner/SKILL.md`（:50-75, :61-75）；Phase 2 定稿协议（Decisions/CA-1,CA-2,不变量） |
| P3-S2 | §2, §3, §4 | `skills/task-planner/SKILL.md`（:68-75, :170-184）；P3-S1 变更结果摘要 |
| P4-S1 | §2, §3, §4 | `skills/task-planner/references/critical-rules.md`（:140-208, :176-182）；Phase 2 Rule 109 草案与已识别覆盖面映射/未列面规则 |
| P4-S2 | §2, §3, §4 | `skills/task-planner/references/critical-rules.md`（:1-10, :194-208）；`skills/task-planner/SKILL.md`（:9, :247, :256-259）；P4-S1 结果 |
| P5-S1 | §2, §3 | 变更后 `skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`；task_plan.md VC 命令与基线记录 |
| P5-S2 | §1, §4 | `plans/task-planaudit-20261116/task_plan.md`、`verification.md`、`progress.md`（含 R1/R2 审计段）、变更标注表勾核状态 |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | `/home/terry/.zcode/skills/task-planner/SKILL.md` | 本任务即优化该技能流程与规则，执行期须按其 Phase/VC/门控纪律推进 | 主进程/执行体按技能流程执行 |
| verification-gate | `/home/terry/.zcode/skills/verification-gate/SKILL.md` | 终验面映射与 VC 复验/SOP 对齐（Rule 84） | 子代理 prompt 挂载 / 主进程按需调用 |
| task-discipline | `/home/terry/.zcode/skills/task-discipline/SKILL.md` | Rule 74 变更吸收、Rule 69 裁决、执行纪律与错误闭环 | 子代理 prompt 挂载 / 按需 Read |
| task-dispatch | `/home/terry/.zcode/skills/task-dispatch/SKILL.md` | Rule 103 双轮质检、派发契约与 S-unit 执行规范 | 子代理 prompt 挂载 / 按需 Read |
| alignment-review | `/home/terry/.zcode/skills/alignment-review/SKILL.md` | 文档更新前后对齐审查（code_review/42.6 登记项） | 子代理 prompt 挂载 / 主进程按需调用 |
| critic（agent） | `/home/terry/.zcode/agents/critic.md` | 计划审计主执行体（R2 复审及后续审计轮次）、终验语义补审 | Agent 派发（只读审查） |
| decision-arbiter（agent） | （Rule 69 执行体，按覆盖矩阵/环境定义） | 审计争议、CR 分歧、连续无进展升级前裁决 | Agent 派发 |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh plans/task-planaudit-20261116` → 生成 `knowledge/entries/_draft-task-planaudit-20261116.md`（若计划已归档则用 archive 路径）
- **精炼**：draft 机械提取后合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 `knowledge/README.md` 与 `knowledge/entry-template.md` (Rule 71 无源不写)
